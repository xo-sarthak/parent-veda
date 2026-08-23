-- =====================================================================
-- 0078_consult_sessions.sql -- who actually turned up, and for how long.
-- ---------------------------------------------------------------------
-- THE DEFECT. A booking's status moved from 'upcoming' to 'attended' for
-- one reason: the clock passed its end time. The client says so plainly:
--
--     // we cannot yet know real attendance, so ended == attended
--
-- So a consultation nobody joined — the parent forgot, the doctor never
-- came, the app crashed on connect — is written into her permanent
-- history as ATTENDED. And `BookingStatus.missed` has been declared in
-- the model since the engine was built and set by absolutely nothing.
--
-- That is not a cosmetic wrong label. It is the record every later
-- decision reads: whether a credit was consumed, whether a refund is
-- owed, whether a doctor is reliable, what "6 consultations" on a
-- sponsor dashboard actually counts.
--
-- 0075's header anticipated exactly this table:
--
--     "the moment someone adds a 'joined at' audit row above the guard..."
--
-- This is that row.
--
-- ---------------------------------------------------------------------
-- WHY THE APP REPORTS IT RATHER THAN LIVEKIT
-- ---------------------------------------------------------------------
--
-- The rigorous answer is LiveKit webhooks: the media server knows who
-- was in the room and cannot be lied to by a client. It also needs a
-- public endpoint, signature verification, and a deployment we do not
-- have yet.
--
-- The app reporting its own join is weaker — a client could claim a join
-- that did not happen — and it is worth being precise about how much
-- that matters HERE. This record decides whether a mother's own history
-- says "attended"; it is not a payment authority and nothing pays out
-- from it. The realistic failure is a missed row (the app was killed
-- before it could write), not a forged one, and a missed row degrades to
-- exactly the behaviour we have today.
--
-- So: honest attendance now, verifiable attendance when webhooks land.
-- The table shape does not change when they do — only who inserts.
--
-- ---------------------------------------------------------------------
-- KNOWN GAP, STATED RATHER THAN HIDDEN
-- ---------------------------------------------------------------------
--
-- settle_my_bookings() below marks a session attended when the PARENT
-- joined. If she joined and the doctor never did, that still reads
-- 'attended' — which is better than today (it is at least true that she
-- turned up) but is not the whole truth, and it is the case that most
-- deserves a refund. Doctor no-shows are handled deliberately, by the
-- doctor, through expert_cancel_booking (0077); detecting them
-- automatically needs the counterpart's row to be trustworthy, which is
-- the webhook work above. Not fixed here, and not pretended otherwise.
--
-- PREREQ: 0029 (booking_bookings, booking_slots), 0073 (my_expert_ids).
-- =====================================================================

create table if not exists public.consult_sessions (
  id          text        primary key,
  booking_id  text        not null,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  role        text        not null,          -- 'parent' | 'expert'
  joined_at   timestamptz not null default now(),
  left_at     timestamptz
);

create index if not exists consult_sessions_booking_idx
  on public.consult_sessions (booking_id);
create index if not exists consult_sessions_user_idx
  on public.consult_sessions (user_id);

grant select on public.consult_sessions to authenticated;
alter table public.consult_sessions enable row level security;

-- Read your own rows. Not the counterpart's: whether a doctor joined at
-- 14:02 or 14:09 is not the parent's business, and the aggregate question
-- ("did this happen?") is answered by booking_bookings.status instead.
--
-- No INSERT or UPDATE policy at all, deliberately, exactly as 0032 does
-- for prescriptions: every write goes through the definer functions
-- below, so a client cannot invent an attendance row for a booking it
-- does not hold.
create policy "consult_sessions own select" on public.consult_sessions
  for select using (user_id = auth.uid());


-- ---------------------------------------------------------------------
-- record_consult_join() -- "I am in the room."
--
-- Authorised the same way the room itself is: the parent who booked it,
-- or the expert hosting it via my_expert_ids(). Returns the row id the
-- client passes back to record_consult_leave, or null if refused —
-- refusal is silent for the same reason join_room_for_booking's is.
-- ---------------------------------------------------------------------
create or replace function public.record_consult_join(
  p_id         text,
  p_booking_id text
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid    uuid := auth.uid();
  v_owner  uuid;
  v_slot   text;
  v_expert text;
  v_role   text;
begin
  if v_uid is null then return null; end if;

  select b.user_id, b.slot_id into v_owner, v_slot
    from public.booking_bookings b
   where b.id = p_booking_id;
  if v_slot is null then return null; end if;

  if v_owner = v_uid then
    v_role := 'parent';
  else
    select s.expert_id into v_expert
      from public.booking_slots s where s.id = v_slot;
    if v_expert is null
       or v_expert not in (select public.my_expert_ids()) then
      return null;
    end if;
    v_role := 'expert';
  end if;

  -- The id is minted by the CLIENT, like booking ids and prescription
  -- ids, so a retry after a dropped response re-writes the same row
  -- instead of logging a second arrival. Rejoining after a network drop
  -- is the common case here, not the exception.
  insert into public.consult_sessions (id, booking_id, user_id, role)
  values (p_id, p_booking_id, v_uid, v_role)
  on conflict (id) do nothing;

  return p_id;
end;
$$;

revoke all on function public.record_consult_join(text, text) from public;
grant execute on function public.record_consult_join(text, text)
  to authenticated;


-- ---------------------------------------------------------------------
-- record_consult_leave() -- "...and I am out."
--
-- Own rows only, and only once: a second call cannot rewrite a departure
-- time, so a late-arriving duplicate cannot stretch a session.
-- ---------------------------------------------------------------------
create or replace function public.record_consult_leave(p_id text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.consult_sessions
     set left_at = now()
   where id = p_id
     and user_id = auth.uid()
     and left_at is null;
end;
$$;

revoke all on function public.record_consult_leave(text) from public;
grant execute on function public.record_consult_leave(text) to authenticated;


-- ---------------------------------------------------------------------
-- settle_my_bookings() -- turn "it is past" into "it happened, or it did
-- not", from evidence.
--
-- Replaces the client's ended == attended assumption for the CALLER's own
-- bookings. Returns how many rows it settled, so the app can log it.
--
-- Only touches sessions whose end is comfortably behind us: a
-- consultation that has just finished may still be writing its leave
-- row, and settling it mid-write would be the same guess with extra
-- steps.
-- ---------------------------------------------------------------------
create or replace function public.settle_my_bookings()
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_n   int  := 0;
begin
  if v_uid is null then return 0; end if;

  with settled as (
    update public.booking_bookings b
       set status = case
             when exists (
               select 1 from public.consult_sessions cs
                where cs.booking_id = b.id
                  and cs.user_id = v_uid
             ) then 'attended'
             else 'missed'
           end
     where b.user_id = v_uid
       and b.status = 'upcoming'
       and b.starts_utc
           + make_interval(mins => b.duration_min)
           + interval '30 minutes' < now()
    returning 1
  )
  select count(*) into v_n from settled;

  return v_n;
end;
$$;

revoke all on function public.settle_my_bookings() from public;
grant execute on function public.settle_my_bookings() to authenticated;

comment on function public.settle_my_bookings() is
  'Settles the caller''s past bookings from evidence: attended if a consult_sessions row shows they joined, missed otherwise. Replaces the client assumption that a booking whose end time has passed was attended, which wrote "attended" into a mother''s permanent history for consultations nobody joined and left BookingStatus.missed permanently unused. Waits 30 minutes past the scheduled end so a just-finished call is not settled mid-write. Does NOT detect a doctor no-show — see the header.';


-- =====================================================================
-- VERIFY
--
--   -- Join, then leave:
--   select public.record_consult_join('cs_1', 'bkg_...');   -> cs_1
--   select public.record_consult_leave('cs_1');
--   select joined_at, left_at from public.consult_sessions where id = 'cs_1';
--
--   -- Twice is once (client-minted id):
--   select public.record_consult_join('cs_1', 'bkg_...');   -> cs_1
--   select count(*) from public.consult_sessions where id = 'cs_1';  -> 1
--
--   -- Somebody else's booking:
--   select public.record_consult_join('cs_x', 'bkg_theirs');  -> null
--
--   -- Settling, on a booking that ended over half an hour ago:
--   select public.settle_my_bookings();      -> 1
--   select status from public.booking_bookings where id = 'bkg_...';
--     -> attended   (or 'missed' with no session row)
--
--   -- A client cannot write the table directly:
--   insert into public.consult_sessions (id, booking_id, user_id, role)
--   values ('cs_forged', 'bkg_...', auth.uid(), 'parent');
--     -> new row violates row-level security policy
-- =====================================================================
