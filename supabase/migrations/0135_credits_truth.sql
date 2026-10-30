-- =====================================================================
-- 0135 -- CREDITS TRUTH: a credit or a seat is spent once, returned once,
-- never paid back twice, and the phone is told what really happened.
--
-- The credits audit (2026-10-29, docs/LEARNING-ARCHITECTURE.md §5, LA-35..
-- LA-45) found that the money rules were right in most places and wrong at
-- the edges: a late cancel the phone counted as a refund, a host-missed
-- rule that refunded the same purchase twice, past bookings that could be
-- cancelled, a refund that swallowed other people's credits, slots that
-- could be booked after they closed.
--
-- EVERY FUNCTION HERE IS ITS LAST DEFINITION, COPIED FORWARD WHOLE, with
-- the change marked (0135). `create or replace` swaps the entire body, so
-- an edit written against an older copy silently deletes whatever came
-- between (LA-2). test/credits_truth_contract_test.dart reads the last
-- definition of each and pins the rules below.
--
-- WHAT CHANGES
--   1  cancel_booking returns what happened (credit back or not), refuses
--      anything that is not upcoming, and marks a late cancel that kept
--      its credit 'late_cancel' -- the one fact the phone was guessing.
--   2  booking_terms(): the cancel window, readable by the app. It was a
--      constant on the phone (2 h) and a row on the server (4 h).
--   3  reschedule_booking(): ONE transaction, refused inside the window.
--      It was cancel-then-book from the phone: inside the window that lost
--      the credit and then the booking.
--   4  expert_cancel_booking: upcoming only; reason 'expert_cancelled';
--      a no-show only after the grace period.
--   5  a credit returned through no fault of hers (host missed, expert
--      cancelled) lives at least 30 more days.
--   6  _refund_check: the host-missed rule is scoped to the seat this
--      purchase paid for, in its run, and only when she was not already
--      given another; consults and packs stay support-only (L.24).
--   7  _revoke_purchase cancels only what this purchase paid for.
--   8  book_slot refuses a slot that has started or has an outcome.
--   9  _host_seen: LiveKit's record wins over the doctor app's tap.
--  10  a slot whose host nobody saw, or who left and never came back, is
--      HELD from auto-settling until a person decides (resolve_host_alert).
--  11  the late cancel that keeps her credit pays the doctor, like a
--      no-show (the earnings trigger).
--  12  the 6-argument open_session_room is dropped (0128's contract step).
--
-- PREREQ: 0066, 0077, 0084, 0126, 0128.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. cancel_booking -- the outcome comes back.
--
-- 0066's version returned void, so the phone could not know whether the
-- credit came back and assumed it always did. The return type changes,
-- which `create or replace` cannot do, hence the drop. An installed app
-- that ignores the result keeps working: PostgREST hands it a value it
-- never reads.
--
-- THE GUARD IS THE STATUS, NOT THE CALLER. 0066 refused only 'cancelled',
-- so an ATTENDED booking could be cancelled -- reversing a payable
-- earning and lowering `booked` for a session that happened. "Only
-- upcoming" is one line, and it also makes the function idempotent: a
-- second tap finds 'cancelled' and changes nothing.
-- ---------------------------------------------------------------------
drop function if exists public.cancel_booking(text);

create or replace function public.cancel_booking(p_booking_id text)
returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  v_booking public.booking_bookings;
  v_uid     uuid := auth.uid();
  v_hours   int;
  v_late    boolean;
  v_had     boolean;   -- a credit paid for this seat
  v_kept    boolean := false;
begin
  select * into v_booking from public.booking_bookings
    where id = p_booking_id and user_id = v_uid for update;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_such_booking');
  end if;

  -- (0135) Only an upcoming booking can be cancelled. Idempotent: a
  -- second tap is told what the booking already is.
  if v_booking.status <> 'upcoming' then
    return jsonb_build_object('ok', v_booking.status = 'cancelled',
      'reason', 'already_' || v_booking.status,
      'credit_returned', false);
  end if;
  if v_booking.starts_utc + make_interval(mins => v_booking.duration_min) < now() then
    return jsonb_build_object('ok', false, 'reason', 'ended');
  end if;

  select credit_return_hours into v_hours
    from public.booking_policy where id = 'default';
  v_hours := coalesce(v_hours, 4);
  v_late  := v_booking.starts_utc <= now() + make_interval(hours => v_hours);

  -- Cancel in time and the credit returns to the pool. Cancel twenty
  -- minutes before and it is spent: the clinician's hour is gone either
  -- way, and a no-show that costs nothing is a no-show that happens.
  v_had := exists (select 1 from public.consult_credits
                    where booking_id = p_booking_id);
  if v_late then
    v_kept := v_had;
  else
    update public.consult_credits
       set booking_id = null, spent_at = null
     where booking_id = p_booking_id;
  end if;

  -- One update, status and reason together: the earnings trigger reads
  -- both on the same row (a late cancel that kept the credit pays the
  -- doctor, see section 11).
  update public.booking_bookings
     set status = 'cancelled',
         cancel_reason = case when v_kept then 'late_cancel' else null end
   where id = p_booking_id;
  update public.booking_slots set booked = greatest(booked - 1, 0)
    where id = v_booking.slot_id;

  return jsonb_build_object('ok', true,
    'credit_returned', v_had and not v_late,
    'late', v_late,
    'window_hours', v_hours,
    'reason', case when v_kept then 'late_cancel' else 'cancelled' end);
end;
$$;

revoke all on function public.cancel_booking(text) from public, anon, authenticated;
grant execute on function public.cancel_booking(text) to authenticated;


-- ---------------------------------------------------------------------
-- 2. booking_terms -- the window, from the one place it is set.
--
-- booking_policy is closed to users (0066), so the phone carried its own
-- number, and it was the wrong one. A read-only function exposes the one
-- field the app needs and nothing else in the row.
-- ---------------------------------------------------------------------
create or replace function public.booking_terms()
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select jsonb_build_object(
    'credit_return_hours',
    coalesce((select credit_return_hours from public.booking_policy
               where id = 'default'), 4));
$$;

revoke all on function public.booking_terms() from public, anon, authenticated;
grant execute on function public.booking_terms() to authenticated;


-- ---------------------------------------------------------------------
-- 3. reschedule_booking -- a move is one transaction.
--
-- The phone used to release, then reserve: two calls, two transactions.
-- If the second failed (the time just went), the first had already
-- happened -- and inside the window the first had spent the credit.
--
-- Here both halves sit in one BEGIN ... EXCEPTION block. Postgres runs
-- that block as a SAVEPOINT: if book_slot raises ('slot full', 'slot
-- closed'), everything written since the block began -- the old booking's
-- cancel, the freed credit, the seat count -- is rolled back to the
-- savepoint, and the function returns the reason instead of an error.
-- The old booking is exactly as it was. That is atomicity, used on
-- purpose: "all or nothing" without the phone having to undo anything.
--
-- Inside the window a move is refused (user, 2026-10-30: no free late
-- reschedule). Outside it, the freed credit is the one book_slot spends.
-- ---------------------------------------------------------------------
create or replace function public.reschedule_booking(
  p_booking_id     text,
  p_new_booking_id text,
  p_new_slot_id    text,
  p_starts_utc     timestamptz default null
) returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  v_old   public.booking_bookings;
  v_new   public.booking_bookings;
  v_uid   uuid := auth.uid();
  v_hours int;
begin
  select * into v_old from public.booking_bookings
   where id = p_booking_id and user_id = v_uid for update;
  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_such_booking');
  end if;
  if v_old.status <> 'upcoming' then
    return jsonb_build_object('ok', false, 'reason', 'already_' || v_old.status);
  end if;

  select credit_return_hours into v_hours
    from public.booking_policy where id = 'default';
  v_hours := coalesce(v_hours, 4);
  if v_old.starts_utc <= now() + make_interval(hours => v_hours) then
    return jsonb_build_object('ok', false, 'reason', 'inside_window',
                              'window_hours', v_hours);
  end if;

  begin
    update public.booking_bookings
       set status = 'cancelled', cancel_reason = 'rescheduled'
     where id = p_booking_id;
    update public.booking_slots set booked = greatest(booked - 1, 0)
     where id = v_old.slot_id;
    update public.consult_credits
       set booking_id = null, spent_at = null
     where booking_id = p_booking_id;

    v_new := public.book_slot(
      p_booking_id  => p_new_booking_id,
      p_slot_id     => p_new_slot_id,
      p_offering_id => v_old.offering_id,
      p_starts_utc  => p_starts_utc,
      p_stage       => v_old.stage);
  exception when others then
    return jsonb_build_object('ok', false, 'reason', sqlerrm);
  end;

  return jsonb_build_object('ok', true, 'booking', to_jsonb(v_new));
end;
$$;

revoke all on function public.reschedule_booking(text, text, text, timestamptz)
  from public, anon, authenticated;
grant execute on function public.reschedule_booking(text, text, text, timestamptz)
  to authenticated;

-- ---------------------------------------------------------------------
-- 4 + 5. expert_cancel_booking -- 0077's, three changes marked (0135).
-- ---------------------------------------------------------------------
create or replace function public.expert_cancel_booking(
  p_booking_id text,
  p_outcome    text default 'cancelled'   -- 'cancelled' | 'missed'
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid     uuid := auth.uid();
  v_booking public.booking_bookings;
  v_expert  text;
begin
  if v_uid is null then
    return 'not_authenticated';
  end if;

  if p_outcome not in ('cancelled', 'missed') then
    return 'bad_outcome';
  end if;

  select * into v_booking
    from public.booking_bookings
   where id = p_booking_id
     for update;

  if not found then
    return 'no_such_booking';
  end if;

  -- May THIS login act for the expert hosting this slot? One condition,
  -- not a branch on entity type: my_expert_ids() (0073) already resolves a
  -- solo doctor, a clinician under a hospital, and an organisation account
  -- to the same list of expert ids. A hospital admin cancelling their own
  -- clinician's consult works here for free.
  select s.expert_id into v_expert
    from public.booking_slots s
   where s.id = v_booking.slot_id;

  if v_expert is null
     or v_expert not in (select public.my_expert_ids()) then
    -- Not "no such booking". The caller is a verified clinician asking
    -- about a booking that is not theirs; there is nothing to probe here
    -- that expert_roster() does not already answer, and a distinct code
    -- is the difference between a fixable message and a mystery.
    return 'not_your_patient';
  end if;

  -- Idempotent. Two taps, one cancellation, one credit.
  -- (0135) Only an upcoming booking. 0077 let an ATTENDED one through,
  -- which cancelled a session that happened and handed the credit back.
  if v_booking.status <> 'upcoming' then
    return 'already_' || v_booking.status;
  end if;

  -- (0135) A no-show is a statement about the past: not before the
  -- grace period (ConsultPolicy.kNoShowGrace, 10 minutes) has run.
  if p_outcome = 'missed'
     and now() < v_booking.starts_utc + interval '10 minutes' then
    return 'too_early';
  end if;

  -- (0135) The reason, so the refund rule can see the expert cancelled.
  update public.booking_bookings
     set status = p_outcome,
         cancel_reason = case when p_outcome = 'cancelled'
                              then 'expert_cancelled' end
   where id = p_booking_id;

  update public.booking_slots
     set booked = greatest(booked - 1, 0)
   where id = v_booking.slot_id;

  -- The credit returns ONLY when the clinician cancelled. See the note
  -- above on why the parent-facing time window does not apply here.
  -- (0135) Not her fault: the credit lives at least 30 more days.
  if p_outcome = 'cancelled' then
    update public.consult_credits
       set booking_id = null, spent_at = null,
           expires_at = case when expires_at is null then null
                             else greatest(expires_at, now() + interval '30 days') end
     where booking_id = p_booking_id;
  end if;

  return 'ok';
end;
$$;

-- ---------------------------------------------------------------------
-- 5. _declare_host_missed -- 0128's, plus the statuses it may undo.
--
-- The sweep undoes only 'upcoming' seats (the default). A person
-- resolving a held slot (section 10) may also undo seats the webhook or
-- the phone already settled as attended or missed; the status change
-- fires the 0084 trigger, which reverses a payable earning too.
-- A new argument is a new signature, so the old one is dropped.
-- ---------------------------------------------------------------------
drop function if exists public._declare_host_missed(text);

create or replace function public._declare_host_missed(
  p_slot_id  text,
  p_statuses text[] default array['upcoming']
)
returns int
language plpgsql
security definer set search_path = ''
as $$
declare
  s    public.booking_slots;
  b    record;
  v_n  int := 0;
  v_ln text := public._slot_line(p_slot_id);
begin
  select * into s from public.booking_slots where id = p_slot_id for update;
  -- (0135) The sweep calls this on an open slot; a person resolving a
  -- held one (resolve_host_alert) may find it settled. Once is the rule.
  if s.id is null or s.outcome = 'host_missed' then return 0; end if;

  update public.booking_slots
     set outcome = 'host_missed', outcome_at = now()
   where id = p_slot_id;

  for b in
    select bb.id from public.booking_bookings bb
     where bb.slot_id = p_slot_id and bb.status = any(p_statuses)
     for update
  loop
    -- The status change fires the 0084 trigger: the expert's accrued
    -- earning for this seat is reversed. That IS "the expert is not paid".
    update public.booking_bookings
       set status = 'cancelled', cancel_reason = 'host_missed'
     where id = b.id;
    -- Her credit comes back whatever the hour (0077's rule for a
    -- clinician-side cancellation).
    -- (0135) ... and lives at least 30 more days (a 30-day pack
    -- credit must not come back already expired).
    update public.consult_credits
       set booking_id = null, spent_at = null,
           expires_at = case when expires_at is null then null
                             else greatest(expires_at, now() + interval '30 days') end
     where booking_id = b.id;
    v_n := v_n + 1;
  end loop;

  update public.booking_slots
     set booked = greatest(booked - v_n, 0)
   where id = p_slot_id;

  insert into public.ops_alerts (kind, slot_id, title, detail)
  values ('host_missed', p_slot_id,
          'Host missed: seats returned, refunds offered, expert not paid',
          jsonb_build_object('line', v_ln, 'seats', v_n, 'expert_id', s.expert_id))
  on conflict do nothing;

  return v_n;
end;
$$;

revoke all on function public._declare_host_missed(text, text[]) from public, anon, authenticated;


-- ---------------------------------------------------------------------
-- 6. _refund_check -- 0128's, the host-missed rule scoped (0135).
--
-- 0128's rule: ANY of her bookings on the offering, ever, cancelled for
-- host_missed, made EVERY purchase of it refundable forever. A consult
-- whose credit had already come back could then be refunded in money as
-- well -- compensated twice -- and a masterclass she rebooked and
-- attended stayed refundable. The general fact: a compensation rule must
-- name exactly what it compensates, or it compensates other things too.
-- ---------------------------------------------------------------------
create or replace function public._refund_check(p_purchase public.course_purchases)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  p       public.programmes;
  v_start timestamptz;
  v_until timestamptz;
  v_opens int;
begin
  if p_purchase.status <> 'active' then
    return jsonb_build_object('eligible', false, 'reason', p_purchase.status);
  end if;
  if p_purchase.provider = 'free' then
    return jsonb_build_object('eligible', false, 'reason', 'nothing_paid');
  end if;

  -- (0128) The host did not come: refundable whatever the date (L.14).
  -- (0135) Scoped, so it compensates once:
  --   * a seat THIS purchase paid for (paid_by 'purchase', in its run) --
  --     not any booking she ever had on the offering;
  --   * an expert's cancellation counts the same as a missed host;
  --   * not if she already holds or has used another seat in that run
  --     (she was made whole by the rebooking);
  --   * consults and class packs are not here at all: their credit came
  --     back when the host missed, and their money is support-only (L.24).
  if p_purchase.kind in ('masterclass', 'cohort')
     and exists (
       select 1 from public.booking_bookings bb
        where bb.user_id = p_purchase.user_id
          and bb.offering_id = p_purchase.offering_id
          and bb.paid_by = 'purchase'
          and bb.cancel_reason in ('host_missed', 'expert_cancelled')
          and (p_purchase.run_id is null
               or public._slot_run(bb.slot_id) is not distinct from p_purchase.run_id))
     and not exists (
       select 1 from public.booking_bookings bb
        where bb.user_id = p_purchase.user_id
          and bb.offering_id = p_purchase.offering_id
          and bb.paid_by = 'purchase'
          and bb.status in ('upcoming', 'attended')
          and (p_purchase.run_id is null
               or public._slot_run(bb.slot_id) is not distinct from p_purchase.run_id))
  then
    return jsonb_build_object('eligible', true, 'until', null, 'reason', 'host_missed');
  end if;

  if p_purchase.programme_id is null then
    return jsonb_build_object('eligible', false, 'reason', 'support_only');
  end if;
  select * into p from public.programmes where id = p_purchase.programme_id;

  if p.refund_policy in ('before_start', 'before_first_session') then
    select min(s.starts_utc) into v_start from public.programme_sessions s
     where s.programme_id = p.id
       and (p_purchase.run_id is null or s.run_id is null or s.run_id = p_purchase.run_id);
    -- No timetable yet means nothing has been delivered: refundable.
    if v_start is null then
      return jsonb_build_object('eligible', true, 'until', null, 'reason', 'not_scheduled');
    end if;
    v_until := v_start - case when p.refund_policy = 'before_start'
                              then make_interval(hours => p.refund_window_hours)
                              else interval '0' end;
    return jsonb_build_object('eligible', now() < v_until, 'until', v_until,
      'reason', case when now() < v_until then 'in_window' else 'window_closed' end);
  end if;

  if p.refund_policy = 'course_unopened' then
    v_until := p_purchase.paid_at + make_interval(days => p.refund_days);
    select count(*) into v_opens from public.programme_lesson_opens o
     where o.user_id = p_purchase.user_id and o.programme_id = p.id;
    return jsonb_build_object(
      'eligible', now() < v_until and v_opens <= p.refund_max_lessons,
      'until', v_until,
      'reason', case when now() >= v_until then 'window_closed'
                     when v_opens > p.refund_max_lessons then 'lessons_opened'
                     else 'in_window' end);
  end if;

  return jsonb_build_object('eligible', false, 'reason', 'support_only');
end;
$$;

revoke all on function public._refund_check(public.course_purchases) from public, anon, authenticated;


-- ---------------------------------------------------------------------
-- 7. _revoke_purchase -- 0126's, scoped to what the purchase paid (0135).
-- ---------------------------------------------------------------------
create or replace function public._revoke_purchase(p_purchase_id text, p_status text)
returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  cp public.course_purchases;
  b  record;
begin
  select * into cp from public.course_purchases where id = p_purchase_id for update;
  if cp.id is null then return; end if;

  update public.course_purchases
     set status = p_status,
         refund_requested_at = coalesce(refund_requested_at, now()),
         refunded_at = case when p_status = 'refunded' then now() else refunded_at end
   where id = cp.id;

  if cp.status <> 'active' then return; end if;   -- already revoked once

  -- (0135) Only the seats THIS purchase paid for: its own seat in its
  -- run, or a booking spent from a credit it granted. 0126 cancelled
  -- every upcoming booking on the offering, so a seat paid by a sponsor
  -- or another pack was cancelled with its credit still spent on it.
  for b in
    select bb.id, bb.slot_id from public.booking_bookings bb
     where bb.user_id = cp.user_id and bb.offering_id = cp.offering_id
       and bb.status = 'upcoming'
       and ((bb.paid_by = 'purchase'
             and (cp.run_id is null
                  or public._slot_run(bb.slot_id) is not distinct from cp.run_id))
            or exists (select 1 from public.consult_credits c
                        where c.booking_id = bb.id and c.source_ref = cp.id))
     for update
  loop
    update public.booking_bookings
       set status = 'cancelled', cancel_reason = 'refunded'
     where id = b.id;
    update public.booking_slots set booked = greatest(booked - 1, 0) where id = b.slot_id;
    -- The credit it spent was this purchase's: refunded, so void.
    update public.consult_credits
       set voided_at = now(), void_reason = 'refunded'
     where booking_id = b.id and source_ref = cp.id and voided_at is null;
  end loop;

  update public.consult_credits
     set voided_at = now(), void_reason = 'refunded'
   where user_id = cp.user_id and source_ref = cp.id
     and booking_id is null and voided_at is null;
end;
$$;

revoke all on function public._revoke_purchase(text, text) from public, anon, authenticated;


-- ---------------------------------------------------------------------
-- 8. book_slot -- 0128's, plus the closed-slot refusal (0135). The
-- credit claim (0066, restored in 0123) is untouched; the L2a contract
-- test still reads it here.
-- ---------------------------------------------------------------------
create or replace function public.book_slot(
  p_booking_id   text,
  p_slot_id      text,
  p_offering_id  text,
  p_expert_id    text        default null,
  p_starts_utc   timestamptz default null,
  p_duration_min int         default null,
  p_capacity     int         default null,
  p_stage        text        default null,
  p_title        text        default null,
  p_join_url     text        default null,
  p_price_paise  int         default null
) returns public.booking_bookings
language plpgsql
security definer set search_path = ''
as $$
declare
  v_slot       public.booking_slots;
  v_booking    public.booking_bookings;
  v_uid        uuid := auth.uid();
  v_credit     uuid;
  v_mode       text := public.payment_mode();
  v_price      jsonb := public.price_offering(p_offering_id);
  v_known      boolean;
  v_seat_paise int;
  v_paid_by    text;
  v_stage      text;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;
  v_known := coalesce((v_price->>'known')::boolean, false);

  -- (0128) The phone's stage when it sends one (where she booked from),
  -- else the offering's.
  v_stage := coalesce(p_stage, v_price->>'stage');
  if v_stage is null then
    raise exception 'stage required';
  end if;

  select * into v_slot from public.booking_slots
    where id = p_slot_id for update;

  if v_slot.id is null then
    if v_known and v_price->>'kind' = 'consult' then
      if p_starts_utc is null or p_starts_utc <= now() then
        raise exception 'slot in the past';
      end if;
      -- (0128, LA-29) The time must be one the doctor offers.
      if not public.slot_fits_schedule(v_price->>'expert_id', p_starts_utc) then
        raise exception 'outside schedule';
      end if;
      insert into public.booking_slots
        (id, offering_id, expert_id, starts_utc, duration_min, capacity, join_url)
      values
        (p_slot_id, p_offering_id, v_price->>'expert_id', p_starts_utc,
         coalesce((v_price->>'duration_min')::int, 30), 1, null)
      on conflict (id) do nothing;
    elsif v_mode = 'stub' and p_expert_id is not null and p_starts_utc is not null
          and p_duration_min is not null and p_capacity is not null then
      -- LEGACY, STUB ONLY: today's app books slots it generated itself.
      insert into public.booking_slots
        (id, offering_id, expert_id, starts_utc, duration_min, capacity, join_url)
      values
        (p_slot_id, p_offering_id, p_expert_id, p_starts_utc,
         p_duration_min, p_capacity, p_join_url)
      on conflict (id) do nothing;
    else
      raise exception 'unknown slot';
    end if;

    select * into v_slot from public.booking_slots
      where id = p_slot_id for update;
  end if;

  if v_slot.offering_id <> p_offering_id then
    raise exception 'slot does not belong to this offering';
  end if;

  -- (0135) A slot that has started, or has an outcome (held, host
  -- missed), is closed. 0128 checked the time only when it CREATED a
  -- consult slot; an existing one could be booked after it began.
  if v_slot.starts_utc <= now() or v_slot.outcome is not null then
    raise exception 'slot closed';
  end if;

  if v_slot.booked >= v_slot.capacity then
    raise exception 'slot full';
  end if;

  if exists (
    select 1 from public.booking_bookings
    where slot_id = p_slot_id and user_id = v_uid and status <> 'cancelled'
  ) then
    raise exception 'already booked';
  end if;

  -- What this seat is worth: the server's figure. The phone's only in
  -- stub mode, for an offering the server does not know.
  v_seat_paise := case
    when v_known then (v_price->>'seat_paise')::int
    when v_mode = 'stub' then p_price_paise
    else null end;

  update public.booking_slots set booked = booked + 1 where id = p_slot_id;

  insert into public.booking_bookings
    (id, user_id, offering_id, slot_id, stage, title, starts_utc,
     duration_min, status, paid_by, price_paise)
  values
    (p_booking_id, v_uid, p_offering_id, p_slot_id, v_stage,
     coalesce(v_price->>'title', p_title, ''),
     v_slot.starts_utc, v_slot.duration_min, 'upcoming', 'unpaid', v_seat_paise)
  returning * into v_booking;

  -- CLAIM A CREDIT (0066, restored in 0123). Oldest-expiring first so
  -- nothing is wasted. FOR UPDATE SKIP LOCKED because two simultaneous
  -- bookings by the same person must not queue behind each other for the
  -- same row: the second takes the next credit instead of waiting.
  --
  -- capacity = 1 is how the server knows this is a consultation; 0066
  -- explains why the seat count, not a client-sent `kind`, is the
  -- signal. (0126) A stub-purchase credit is not spendable in live mode.
  select c.id into v_credit
    from public.consult_credits c
   where c.user_id = v_uid
     and c.booking_id is null
     and c.voided_at is null
     and (c.expires_at is null or c.expires_at > now())
     and ((c.offering_scope = '*any_consult' and v_slot.capacity = 1)
          or c.offering_scope = p_offering_id)
     and (v_mode = 'stub' or c.source <> 'stub_purchase')
   order by c.expires_at nulls last, c.granted_at
   limit 1
   for update skip locked;

  if v_credit is not null then
    update public.consult_credits
       set booking_id = v_booking.id, spent_at = now()
     where id = v_credit;
    update public.booking_bookings set paid_by = 'credit'
     where id = v_booking.id
    returning * into v_booking;
    return v_booking;
  end if;

  -- (0126) No credit: a receipt for this run, or a free seat, or nothing.
  v_paid_by := case
    when v_known and v_price->>'kind' in ('masterclass', 'cohort')
         and public.has_course_access(v_price->>'programme_id', 'seat',
                                      public._slot_run(v_slot.id))
      then 'purchase'
    when v_known and v_seat_paise = 0 then 'free'
    else 'unpaid' end;

  if v_paid_by = 'unpaid' and v_mode = 'live' then
    raise exception 'payment required';
  end if;

  if v_paid_by <> 'unpaid' then
    update public.booking_bookings set paid_by = v_paid_by
     where id = v_booking.id
    returning * into v_booking;
  end if;

  return v_booking;
end;
$$;

grant execute on function public.book_slot(
  text, text, text, text, timestamptz, int, int, text, text, text, int)
  to authenticated;


-- ---------------------------------------------------------------------
-- 9. _host_seen -- LiveKit's record wins (0135).
--
-- 0128 counted ANY expert row, including the doctor app's own 'app' row,
-- written when the doctor taps Join -- before the connection is made.
-- A host who tapped and never connected looked present, and the
-- host-missed rule never fired. Same rule as _settle_slot: if LiveKit saw
-- anyone in this room, only LiveKit's record counts; if it saw nobody
-- (the webhook is not reaching us), the app's row is the only evidence.
-- ---------------------------------------------------------------------
create or replace function public._host_seen(p_slot_id text)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select case
    when exists (select 1 from public.consult_sessions cs
                  where cs.slot_id = p_slot_id and cs.source = 'livekit')
    then exists (select 1 from public.consult_sessions cs
                  where cs.slot_id = p_slot_id and cs.role = 'expert'
                    and cs.source = 'livekit')
    else exists (select 1 from public.consult_sessions cs
                  where cs.slot_id = p_slot_id and cs.role = 'expert')
  end;
$$;

revoke all on function public._host_seen(text) from public, anon, authenticated;


-- ---------------------------------------------------------------------
-- 10. A slot nobody can vouch for waits for a person.
--
-- 0128's sweep raised 'host_unknown' (no host at +20, LiveKit saw nobody)
-- and then, at end + 30, settled the slot anyway. The fix is a HOLD: an
-- unresolved host_unknown or host_left alert stops _settle_slot, which
-- every settling path goes through (the sweep, the webhook, the phone).
-- resolve_host_alert is how the hold ends.
--
-- host_left (gap A): the host joined, left with more than 15 minutes of
-- the session to go, and has been gone 15 minutes. Attendees were
-- looking at "the host stepped out" with nothing behind it.
-- ---------------------------------------------------------------------
alter table public.ops_alerts drop constraint if exists ops_alerts_kind_check;
alter table public.ops_alerts add constraint ops_alerts_kind_check
  check (kind in ('host_late', 'host_missed', 'host_unknown', 'host_left',
                  'recording_failed'));

create or replace function public._settle_slot(p_slot_id text)
returns int
language plpgsql
security definer set search_path = ''
as $$
declare
  v_seen boolean;
  v_n    int;
begin
  -- (0135) HELD: the host was not seen, or left and never came back, and
  -- a person has been asked to decide. Settling now would mark seats
  -- attended or missed and make the expert's earning payable -- for a
  -- session that may never have happened -- with nothing to undo it.
  if exists (select 1 from public.ops_alerts a
              where a.slot_id = p_slot_id
                and a.kind in ('host_unknown', 'host_left')
                and a.resolved_at is null) then
    return 0;
  end if;

  v_seen := exists (select 1 from public.consult_sessions cs
                     where cs.slot_id = p_slot_id and cs.source = 'livekit');

  with settled as (
    update public.booking_bookings b
       set status = case
             when (v_seen and exists (
                     select 1 from public.consult_sessions cs
                      where cs.slot_id = b.slot_id and cs.user_id = b.user_id
                        and cs.source = 'livekit'))
               or (not v_seen and exists (
                     select 1 from public.consult_sessions cs
                      where cs.booking_id = b.id and cs.user_id = b.user_id))
             then 'attended'
             else 'missed'
           end
     where b.slot_id = p_slot_id
       and b.status = 'upcoming'
       and b.starts_utc + make_interval(mins => b.duration_min)
           + interval '30 minutes' < now()
    returning 1
  )
  select count(*) into v_n from settled;

  update public.booking_slots s
     set outcome = 'held', outcome_at = now()
   where s.id = p_slot_id and s.outcome is null
     and s.starts_utc + make_interval(mins => s.duration_min)
         + interval '30 minutes' < now()
     and public._host_seen(p_slot_id);

  return v_n;
end;
$$;

revoke all on function public._settle_slot(text) from public, anon, authenticated;

create or replace function public.sweep_live_sessions()
returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  r         record;
  v_late    int := 0;
  v_missed  int := 0;
  v_unknown int := 0;
  v_settled int := 0;
  v_left    int := 0;
begin
  for r in
    select s.id, s.starts_utc from public.booking_slots s
     where s.outcome is null
       and s.starts_utc <= now() - interval '10 minutes'
       and s.starts_utc + make_interval(mins => s.duration_min)
           + interval '30 minutes' > now()
       and exists (select 1 from public.booking_bookings b
                    where b.slot_id = s.id and b.status = 'upcoming')
       and not public._host_seen(s.id)
  loop
    if now() >= r.starts_utc + interval '20 minutes' then
      if exists (select 1 from public.consult_sessions cs
                  where cs.slot_id = r.id and cs.source = 'livekit'
                    and cs.role = 'parent') then
        perform public._declare_host_missed(r.id);
        v_missed := v_missed + 1;
      else
        insert into public.ops_alerts (kind, slot_id, title, detail)
        values ('host_unknown', r.id,
                'No host at +20 min, and LiveKit saw nobody: check by hand',
                jsonb_build_object('line', public._slot_line(r.id)))
        on conflict do nothing;
        if found then v_unknown := v_unknown + 1; end if;
      end if;
    else
      insert into public.ops_alerts (kind, slot_id, title, detail)
      values ('host_late', r.id, 'Host not in the room at +10 min',
              jsonb_build_object('line', public._slot_line(r.id)))
      on conflict do nothing;
      if found then v_late := v_late + 1; end if;
    end if;
  end loop;

  -- (0135) The host who left and did not come back (gap A). LiveKit saw
  -- the host, every host row is closed, the last one closed 15+ minutes
  -- ago, and it closed with 15+ minutes of the session still to run.
  for r in
    select s.id from public.booking_slots s
     where s.outcome is null
       and s.starts_utc <= now()
       and s.starts_utc + make_interval(mins => s.duration_min)
           + interval '30 minutes' > now()
       and exists (select 1 from public.booking_bookings b
                    where b.slot_id = s.id and b.status = 'upcoming')
       and exists (select 1 from public.consult_sessions cs
                    where cs.slot_id = s.id and cs.role = 'expert'
                      and cs.source = 'livekit')
       and not exists (select 1 from public.consult_sessions cs
                        where cs.slot_id = s.id and cs.role = 'expert'
                          and cs.source = 'livekit' and cs.left_at is null)
       and (select max(cs.left_at) from public.consult_sessions cs
             where cs.slot_id = s.id and cs.role = 'expert'
               and cs.source = 'livekit')
           <= least(now(), s.starts_utc + make_interval(mins => s.duration_min))
              - interval '15 minutes'
  loop
    insert into public.ops_alerts (kind, slot_id, title, detail)
    values ('host_left', r.id,
            'Host left and did not come back: settling is held, decide by hand',
            jsonb_build_object('line', public._slot_line(r.id)))
    on conflict do nothing;
    if found then v_left := v_left + 1; end if;
  end loop;

  -- Settle what has ended (the webhook's room_finished usually got there
  -- first; this catches rooms nobody ever opened). A week back at most:
  -- older rows are settle_my_bookings' to finish.
  for r in
    select distinct b.slot_id from public.booking_bookings b
     where b.status = 'upcoming'
       and b.starts_utc + make_interval(mins => b.duration_min)
           + interval '30 minutes' < now()
       and b.starts_utc > now() - interval '7 days'
  loop
    v_settled := v_settled + public._settle_slot(r.slot_id);
  end loop;

  return jsonb_build_object('late', v_late, 'host_missed', v_missed,
                            'unknown', v_unknown, 'host_left', v_left,
                            'settled', v_settled);
end;
$$;

revoke all on function public.sweep_live_sessions() from public, anon, authenticated;

-- The person's half. Service role only (the SQL editor, or an admin tool
-- later): deciding whether a class happened is not a user's call.
--   came = true   the session happened; the hold lifts and it settles
--                 from evidence as usual.
--   came = false  the host missed it: every seat -- upcoming, or already
--                 settled -- is cancelled 'host_missed', credits come
--                 back with 30 more days, earnings are reversed by the
--                 0084 trigger, and the purchase becomes refundable.
-- Idempotent: a second call finds nothing unresolved and nothing upcoming.
create or replace function public.resolve_host_alert(p_slot_id text, p_host_came boolean)
returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  v_alerts int;
  v_n      int := 0;
begin
  update public.ops_alerts
     set resolved_at = now()
   where slot_id = p_slot_id
     and kind in ('host_unknown', 'host_left')
     and resolved_at is null;
  get diagnostics v_alerts = row_count;

  if p_host_came then
    v_n := public._settle_slot(p_slot_id);
  else
    v_n := public._declare_host_missed(p_slot_id,
             array['upcoming', 'attended', 'missed']);
  end if;

  return jsonb_build_object('alerts_resolved', v_alerts,
                            'host_came', p_host_came, 'seats', v_n);
end;
$$;

revoke all on function public.resolve_host_alert(text, boolean) from public, anon, authenticated;
grant execute on function public.resolve_host_alert(text, boolean) to service_role;


-- ---------------------------------------------------------------------
-- 11. The earnings trigger -- 0126's, one branch added (0135).
-- The trigger itself (0084) is unchanged; it calls this by name.
-- ---------------------------------------------------------------------
create or replace function public.expert_earning_from_booking()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
declare
  v_expert    text;
  v_capacity  int;
  v_source    text;
  v_gross     int;
  v_monthly   int;
  v_bps       int;
  v_existing  public.expert_earnings;
  v_kind      text;
  v_programme text;
  v_agree_bps int;
  v_flat      int;
  v_title     text;
begin
  select s.expert_id, s.capacity into v_expert, v_capacity
    from public.booking_slots s where s.id = new.slot_id;
  if v_expert is null then return new; end if;

  if tg_op = 'INSERT' then
    if new.status <> 'upcoming' then return new; end if;

    if v_capacity = 1 then
      v_source := 'consultation';
      select coalesce(new.price_paise, ep.fee_inr * 100, 0) into v_gross
        from public.expert_profiles ep where ep.expert_id = v_expert;
      if v_gross is null then v_gross := coalesce(new.price_paise, 0); end if;
    else
      -- (0126) by offering_id too.
      select p.id, p.kind, coalesce(new.price_paise, p.price_paise, 0)
        into v_programme, v_kind, v_gross
        from public.programmes p
       where p.offering_id = new.offering_id or p.id = new.offering_id
       order by (p.offering_id = new.offering_id) desc
       limit 1;
      -- (0126) the format follows the kind.
      v_source := case v_kind
        when 'cohort'     then 'cohort'
        when 'course'     then 'course'
        when 'class_pack' then 'class_pack'
        else 'masterclass' end;
      if v_gross is null then v_gross := coalesce(new.price_paise, 0); end if;

      -- (0126) the agreement.
      if v_programme is not null then
        select pe.share_bps, pe.share_flat_paise into v_agree_bps, v_flat
          from public.programme_experts pe
         where pe.programme_id = v_programme
           and pe.expert_id = v_expert
           and pe.status = 'accepted';
      end if;
    end if;

    v_title := case when v_source = 'consultation' then 'Consultation' else new.title end;

    if v_flat is not null then
      perform public.write_expert_earning_amount(
        v_expert, v_source, 'booking', new.id, v_title,
        new.starts_utc, v_gross, v_flat, 'accrued', 'Agreed flat amount per seat');
      return new;
    end if;

    select count(*) into v_monthly
      from public.expert_earnings e
     where e.expert_id = v_expert
       and e.source = v_source
       and e.status in ('payable','paid')
       and date_trunc('month', e.occurred_at) = date_trunc('month', new.starts_utc);

    v_bps := coalesce(v_agree_bps, public.resolve_share_bps(
      v_expert, v_source, (new.starts_utc at time zone 'Asia/Kolkata')::date, v_monthly), 0);

    perform public.write_expert_earning(
      v_expert, v_source, 'booking', new.id, v_title,
      new.starts_utc, v_gross, v_bps, 'accrued');
    return new;
  end if;

  -- UPDATE (0084, unchanged)
  if new.status = old.status then return new; end if;

  select * into v_existing from public.expert_earnings e
   where e.ref_kind = 'booking' and e.ref_id = new.id and e.reversal_of is null
   order by e.created_at desc limit 1;
  if v_existing.id is null then return new; end if;

  if new.status in ('attended','missed') and v_existing.status = 'accrued' then
    update public.expert_earnings set status = 'payable' where id = v_existing.id;
  -- (0135) A late cancel that kept her credit: the doctor's hour was
  -- held and cannot be resold, so the doctor is paid, as for a no-show.
  elsif new.status = 'cancelled' and new.cancel_reason = 'late_cancel'
        and v_existing.status = 'accrued' then
    update public.expert_earnings set status = 'payable' where id = v_existing.id;
  elsif new.status = 'cancelled' then
    perform public.write_booking_reversal(v_existing);
  end if;
  return new;
end;
$$;


-- ---------------------------------------------------------------------
-- 12. CONTRACT: the 6-argument open_session_room goes (0128 promised it).
-- livekit-token has sent the slot id alone since 0128 was deployed, so
-- PostgREST resolves every call to the one-argument version.
-- ---------------------------------------------------------------------
drop function if exists public.open_session_room(text, text, text, timestamptz, int, int);


-- =====================================================================
-- VERIFY (each should return true)
--
--   select pg_get_function_result('public.cancel_booking(text)'::regprocedure) = 'jsonb';
--   select public.booking_terms() ? 'credit_return_hours';
--   select has_function_privilege('authenticated',
--     'public.resolve_host_alert(text, boolean)', 'execute') = false;
--   select not exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
--                       where n.nspname = 'public' and p.proname = 'open_session_room'
--                         and p.pronargs = 6);
--   select not exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
--                       where n.nspname = 'public' and p.proname = '_declare_host_missed'
--                         and p.pronargs = 1);
--   select prosrc like '%slot closed%' from pg_proc where proname = 'book_slot';
--   select public.sweep_live_sessions() ? 'host_left';
-- =====================================================================
