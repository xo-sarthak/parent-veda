-- =====================================================================
-- 0128_learning_live_and_recordings.sql -- L3 of the learning work
-- (docs/LEARNING-ARCHITECTURE.md §7). Who was in the room, what happens
-- when the host is not, how big the room may get, where a recording
-- goes, and when a consult time is really free.
-- ---------------------------------------------------------------------
--
--   1. LA-16  attendance is written by LiveKit, not by the phone
--   2. LA-17  the host who never arrives (+10 notice, +20 host_missed)
--   3. LA-18  the room's size comes from the server
--   4.        open_session_room takes only the slot (expand; L3 promise)
--   5. LA-19 / LA-9  recordings: egress -> private bucket -> Mux -> signed
--   6. LA-29  a consult start must fit the doctor's schedule (SQL port of
--             DoctorSchedule.generateSlots, held equal by a parity table)
--   7. LA-32  book_slot's phone arguments get defaults (expand)
--   8. LA-28  every new internal function is closed to users
--
-- User decisions (2026-10-29, "go for recommended"):
--   D1 a class recording starts by itself when the host joins; consults
--      are never recorded; the host can stop it.
--   D2 the team is told through an ops_alerts row, posted to a Discord or
--      Slack incoming webhook when one is configured (pg_net + Vault).
--   D3 the +10 / +20 host rule covers 1:1 consults too.
--   D4 the original file stays in the bucket after Mux imports it.
--
-- PREREQ: 0078 (consult_sessions), 0079, 0123, 0126.
-- One transaction: if any statement fails, nothing is applied.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. LA-16 -- attendance is written by the media server.
--
-- 0078 built consult_sessions for the phone to report its own join, and
-- said so: "honest attendance now, verifiable attendance when webhooks
-- land. The table shape does not change when they do -- only who
-- inserts." Nearly true. Three columns are added, all additive:
--   slot_id          a class HOST has no booking, but was in the slot
--   source           'app' (the phone said so) | 'livekit' (the server saw)
--   participant_sid  LiveKit's id for one connection, so a reconnect is a
--                    second row and a duplicate delivery is not
-- booking_id becomes nullable for the host's rows.
--
-- WHY THE WEBHOOK WINS. A phone can claim a join that never happened;
-- LiveKit's server cannot be argued with, and since L2b money depends on
-- attendance (an expert is paid for a held session, not for a no-show).
-- The phone's row stays as the FALLBACK: for a slot LiveKit saw nobody
-- in -- the webhook not configured, or a delivery lost -- the phone's
-- word is used as before. See _settle_slot.
-- ---------------------------------------------------------------------
alter table public.consult_sessions
  add column if not exists slot_id         text,
  add column if not exists source          text not null default 'app',
  add column if not exists participant_sid text;

alter table public.consult_sessions alter column booking_id drop not null;

do $$
begin
  if not exists (select 1 from pg_constraint
                  where conname = 'consult_sessions_source_check') then
    alter table public.consult_sessions
      add constraint consult_sessions_source_check
      check (source in ('app', 'livekit'));
  end if;
end $$;

create index if not exists consult_sessions_slot_idx
  on public.consult_sessions (slot_id);

-- The app's rows so far carry only the booking; give them the slot.
update public.consult_sessions cs
   set slot_id = b.slot_id
  from public.booking_bookings b
 where b.id = cs.booking_id and cs.slot_id is null;

-- Why a booking was cancelled, when the parent did not do it.
-- 'host_missed' is the first value (LA-17).
--
-- WHY NOT A NEW STATUS. The app reads booking status with
--     BookingStatus.values.firstWhere(..., orElse: () => upcoming)
-- so an installed app would show a 'host_missed' booking as UPCOMING,
-- for ever. A new enum value is a breaking change for every client
-- already installed. 'cancelled' is true, the old app shows it
-- correctly, and the 0084 earnings trigger already reverses the
-- expert's accrual on 'cancelled' -- which is exactly "the expert is
-- not paid", with no new money path.
alter table public.booking_bookings
  add column if not exists cancel_reason text;

-- What became of a session as a whole: 'held' (the host was there) or
-- 'host_missed'. Null until decided.
alter table public.booking_slots
  add column if not exists outcome    text,
  add column if not exists outcome_at timestamptz;

do $$
begin
  if not exists (select 1 from pg_constraint
                  where conname = 'booking_slots_outcome_check') then
    alter table public.booking_slots
      add constraint booking_slots_outcome_check
      check (outcome is null or outcome in ('held', 'host_missed'));
  end if;
end $$;

-- Every LiveKit delivery, once. LiveKit retries a delivery it thinks
-- failed, so the same event can arrive twice; its id is the key.
create table if not exists public.livekit_webhook_events (
  id          text        primary key,
  event       text        not null,
  room        text,
  received_at timestamptz not null default now()
);
alter table public.livekit_webhook_events enable row level security;
revoke all on public.livekit_webhook_events from anon, authenticated;

-- The phone's report, now also stamped with the slot. Copied from 0078
-- (the last definition); the only change is slot_id.
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

  insert into public.consult_sessions (id, booking_id, user_id, role, slot_id, source)
  values (p_id, p_booking_id, v_uid, v_role, v_slot, 'app')
  on conflict (id) do nothing;

  return p_id;
end;
$$;

revoke all on function public.record_consult_join(text, text) from public;
grant execute on function public.record_consult_join(text, text)
  to authenticated;

-- One LiveKit webhook event, from the livekit-webhook edge function
-- (service role, after it has checked LiveKit's signature).
--
-- WHO SOMEONE IS. The participant identity is the Supabase user id
-- (livekit-token sets `sub` to it). The ROLE comes from the
-- participant's metadata, which livekit-token wrote into the token
-- after the database had decided it -- the token is signed with our
-- secret and participants cannot edit their own metadata, so this is
-- the server's earlier answer coming back, not the phone's claim.
-- Identities that are not user ids (the egress recorder) are skipped.
create or replace function public.record_room_event(p jsonb)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_event  text  := p->>'event';
  v_id     text  := coalesce(nullif(p->>'id', ''), md5(p::text));
  v_room   text  := p->'room'->>'name';
  v_part   jsonb := p->'participant';
  v_ident  text  := p->'participant'->>'identity';
  v_sid    text  := p->'participant'->>'sid';
  v_slot   text;
  v_uid    uuid;
  v_meta   jsonb;
  v_role   text;
  v_booking text;
  v_at     timestamptz;
  v_joined timestamptz;
begin
  insert into public.livekit_webhook_events (id, event, room)
  values (v_id, coalesce(v_event, ''), v_room)
  on conflict (id) do nothing;
  if not found then return 'duplicate'; end if;

  if v_room is null or v_room not like 'bkroom\_%' then return 'not_ours'; end if;
  v_slot := substr(v_room, 8);

  if v_event = 'room_finished' then
    perform public._settle_slot(v_slot);
    return 'settled';
  end if;
  if coalesce(v_event, '') not in ('participant_joined', 'participant_left') then
    return 'ignored';
  end if;

  if v_ident is null
     or v_ident !~ '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' then
    return 'not_a_person';
  end if;
  v_uid := v_ident::uuid;
  if not exists (select 1 from auth.users u where u.id = v_uid) then
    return 'unknown_user';
  end if;

  begin
    v_meta := nullif(v_part->>'metadata', '')::jsonb;
  exception when others then
    v_meta := null;
  end;
  v_role := case when v_meta->>'role' in ('host', 'expert') then 'expert' else 'parent' end;

  if v_role = 'parent' then
    select b.id into v_booking from public.booking_bookings b
     where b.slot_id = v_slot and b.user_id = v_uid
     order by (b.status <> 'cancelled') desc, b.created_at desc
     limit 1;
  end if;

  -- LiveKit stamps times as whole seconds (int64, sent as a string).
  v_at := case when coalesce(p->>'createdAt', '') ~ '^[0-9]+$'
               then to_timestamp((p->>'createdAt')::bigint) else now() end;
  v_joined := case when coalesce(v_part->>'joinedAt', '') ~ '^[0-9]+$'
                    and (v_part->>'joinedAt')::bigint > 0
                   then to_timestamp((v_part->>'joinedAt')::bigint) else v_at end;

  if v_event = 'participant_joined' then
    insert into public.consult_sessions
      (id, booking_id, user_id, role, joined_at, slot_id, source, participant_sid)
    values
      ('lk_' || coalesce(v_sid, v_id), v_booking, v_uid, v_role, v_joined,
       v_slot, 'livekit', v_sid)
    on conflict (id) do nothing;
    return 'joined';
  end if;

  -- participant_left. Deliveries are not ordered: a 'left' can arrive
  -- before its 'joined', so it writes the whole row if there is none.
  update public.consult_sessions
     set left_at = v_at
   where id = 'lk_' || coalesce(v_sid, v_id) and left_at is null;
  if not found then
    insert into public.consult_sessions
      (id, booking_id, user_id, role, joined_at, left_at, slot_id, source, participant_sid)
    values
      ('lk_' || coalesce(v_sid, v_id), v_booking, v_uid, v_role, v_joined, v_at,
       v_slot, 'livekit', v_sid)
    on conflict (id) do nothing;
  end if;
  return 'left';
end;
$$;


-- ---------------------------------------------------------------------
-- 2. Settling a session from evidence.
--
-- ONE RULE, used by the webhook (room_finished), by the minute sweep
-- below, and by the phone's settle_my_bookings: if LiveKit saw anyone in
-- this room, LiveKit's record decides who attended; if it saw nobody,
-- the phone's report decides, exactly as 0078 did.
--
-- Why "anyone in this room" and not "this person": if the webhook is
-- working, a parent LiveKit did not see was not there, whatever her
-- phone says. If the webhook is NOT working for this room, LiveKit saw
-- nobody at all, and the only evidence is the phone's.
-- ---------------------------------------------------------------------
create or replace function public._host_seen(p_slot_id text)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.consult_sessions cs
                  where cs.slot_id = p_slot_id and cs.role = 'expert');
$$;

create or replace function public._settle_slot(p_slot_id text)
returns int
language plpgsql
security definer set search_path = ''
as $$
declare
  v_seen boolean;
  v_n    int;
begin
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

-- The phone's call. Same answer as before for the caller, from the same
-- rule as the server. It settles each of the caller's ended slots whole,
-- which is fine: the rule is evidence, not the caller's say-so.
create or replace function public.settle_my_bookings()
returns int
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := auth.uid();
  v_before int;
  v_after  int;
  r        record;
begin
  if v_uid is null then return 0; end if;

  select count(*) into v_before from public.booking_bookings b
   where b.user_id = v_uid and b.status = 'upcoming';

  for r in
    select distinct b.slot_id from public.booking_bookings b
     where b.user_id = v_uid
       and b.status = 'upcoming'
       and b.starts_utc + make_interval(mins => b.duration_min)
           + interval '30 minutes' < now()
  loop
    perform public._settle_slot(r.slot_id);
  end loop;

  select count(*) into v_after from public.booking_bookings b
   where b.user_id = v_uid and b.status = 'upcoming';

  return v_before - v_after;
end;
$$;

revoke all on function public.settle_my_bookings() from public;
grant execute on function public.settle_my_bookings() to authenticated;


-- ---------------------------------------------------------------------
-- 3. LA-17 -- the host who never arrives.
--
-- +10 min, no host in the room: the team is told (an ops_alerts row,
--      posted to the team's chat when a webhook URL is set). The waiting
--      room says so too; it reads the clock and the room itself.
-- +20 min, LiveKit saw attendees and no host: the session is
--      host_missed. Every seat is cancelled with the reason, every
--      credit comes back, the expert's accrual is reversed by the 0084
--      trigger, and the refund rule says yes whatever the date.
--
-- ABSENCE OF EVIDENCE COUNTS ONLY WHEN THE WITNESS WAS THERE. "No host
-- seen" means the host was absent only if LiveKit was reporting on this
-- room at all. If it saw nobody -- the webhook down, or nobody joined --
-- "no host seen" means "we cannot see", and cancelling the class and
-- docking the doctor's pay on it would be a guess with consequences. So
-- that case raises a 'host_unknown' notice for a person to look at, and
-- changes nothing.
-- ---------------------------------------------------------------------
create table if not exists public.ops_alerts (
  id          bigint      generated always as identity primary key,
  kind        text        not null
                check (kind in ('host_late', 'host_missed', 'host_unknown',
                                'recording_failed')),
  slot_id     text,
  ref_id      text,
  title       text        not null,
  detail      jsonb       not null default '{}'::jsonb,
  created_at  timestamptz not null default now(),
  sent_at     timestamptz,
  send_error  text,
  resolved_at timestamptz
);
-- One notice per kind per session: the sweep runs every minute.
create unique index if not exists ops_alerts_once
  on public.ops_alerts (kind, coalesce(slot_id, ''), coalesce(ref_id, ''));
alter table public.ops_alerts enable row level security;
revoke all on public.ops_alerts from anon, authenticated;
grant select, update on public.ops_alerts to directus_cms;
drop policy if exists "ops_alerts cms" on public.ops_alerts;
create policy "ops_alerts cms" on public.ops_alerts
  for all to directus_cms using (true) with check (true);

-- D2: posting to the team's chat. pg_net makes an HTTP call from the
-- database, asynchronously (the request is queued; the insert does not
-- wait for Discord). The URL is a secret, so it lives in Supabase Vault,
-- not in this file:
--   select vault.create_secret('<webhook url>', 'team_alert_webhook_url');
-- No secret, or no Vault: the row is the record and nothing is posted.
-- A failure to post is written on the row, never raised: a raise here
-- would roll back the sweep that found the late host.
create extension if not exists pg_net with schema extensions;

create or replace function public._send_ops_alert()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
declare
  v_url  text;
  v_text text := new.title || coalesce(E'\n' || (new.detail->>'line'), '');
begin
  begin
    select ds.decrypted_secret into v_url
      from vault.decrypted_secrets ds
     where ds.name = 'team_alert_webhook_url'
     limit 1;
  exception when others then
    v_url := null;
  end;
  if v_url is null or v_url = '' then return new; end if;

  begin
    perform net.http_post(
      url     := v_url,
      -- Discord reads `content`, Slack reads `text`.
      body    := case when v_url like '%discord%'
                      then jsonb_build_object('content', v_text)
                      else jsonb_build_object('text', v_text) end,
      headers := '{"Content-Type": "application/json"}'::jsonb);
    update public.ops_alerts set sent_at = now() where id = new.id;
  exception when others then
    update public.ops_alerts set send_error = sqlerrm where id = new.id;
  end;
  return new;
end;
$$;

drop trigger if exists ops_alerts_send on public.ops_alerts;
create trigger ops_alerts_send
  after insert on public.ops_alerts
  for each row execute function public._send_ops_alert();

-- The words on a notice: what, who, when (IST).
create or replace function public._slot_line(p_slot_id text)
returns text
language sql stable security definer set search_path = ''
as $$
  select coalesce((select b.title from public.booking_bookings b
                    where b.slot_id = s.id order by b.created_at limit 1), s.offering_id)
         || ' with ' || coalesce((select ep.name from public.expert_profiles ep
                                   where ep.expert_id = s.expert_id), s.expert_id)
         || ', ' || to_char(s.starts_utc at time zone 'Asia/Kolkata', 'DD Mon HH12:MI AM')
         || ' IST · ' || (select count(*) from public.booking_bookings b
                           where b.slot_id = s.id and b.status = 'upcoming')
         || ' booked · slot ' || s.id
    from public.booking_slots s where s.id = p_slot_id;
$$;

create or replace function public._declare_host_missed(p_slot_id text)
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
  if s.id is null or s.outcome is not null then return 0; end if;

  update public.booking_slots
     set outcome = 'host_missed', outcome_at = now()
   where id = p_slot_id;

  for b in
    select bb.id from public.booking_bookings bb
     where bb.slot_id = p_slot_id and bb.status = 'upcoming'
     for update
  loop
    -- The status change fires the 0084 trigger: the expert's accrued
    -- earning for this seat is reversed. That IS "the expert is not paid".
    update public.booking_bookings
       set status = 'cancelled', cancel_reason = 'host_missed'
     where id = b.id;
    -- Her credit comes back whatever the hour (0077's rule for a
    -- clinician-side cancellation).
    update public.consult_credits
       set booking_id = null, spent_at = null
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

-- Every minute, from pg_cron. Returns what it did, for the run log.
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
                            'unknown', v_unknown, 'settled', v_settled);
end;
$$;

select cron.schedule(
  'live-sessions-sweep',                          -- job name (re-running replaces it)
  '* * * * *',                                    -- every minute
  $cron$ select public.sweep_live_sessions(); $cron$
);

-- The waiting room's question: has the host come, and if not, what now?
-- The booking's owner only.
create or replace function public.session_state(p_booking_id text)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  b public.booking_bookings;
  s public.booking_slots;
begin
  select * into b from public.booking_bookings x
   where x.id = p_booking_id and x.user_id = auth.uid();
  if b.id is null then return null; end if;
  select * into s from public.booking_slots where id = b.slot_id;
  return jsonb_build_object(
    'status',        b.status,
    'cancel_reason', b.cancel_reason,
    'outcome',       s.outcome,
    'host_seen',     public._host_seen(s.id),
    'starts_utc',    s.starts_utc,
    'paid_by',       b.paid_by,
    'server_now',    now());
end;
$$;

revoke all on function public.session_state(text) from public, anon, authenticated;
grant execute on function public.session_state(text) to authenticated;

-- The refund rule (0126, the last definition), with one rule added in
-- front: a purchase whose session the host missed can be refunded at
-- any time. Everything after the new block is 0126's text.
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
  if exists (
    select 1 from public.booking_bookings bb
     where bb.user_id = p_purchase.user_id
       and bb.offering_id = p_purchase.offering_id
       and bb.cancel_reason = 'host_missed'
  ) then
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


-- ---------------------------------------------------------------------
-- 4. LA-18 -- the room's size, and the host's door.
--
-- Capacity used to be only a number in the token's metadata: nothing
-- stopped a leaked or forwarded token from being the forty-first
-- person in a forty-seat class. livekit-token now creates the room
-- itself, before minting, with LiveKit's own maxParticipants -- so the
-- MEDIA SERVER refuses the extra connection. Defence in depth: the
-- database already refuses the booking; this refuses the connection.
--
-- seats + hosts + 1. The +1 is for the egress recorder, which joins the
-- room to record it; whether LiveKit counts it against the limit is not
-- documented clearly enough to bet a host's own seat on.
-- ---------------------------------------------------------------------
create or replace function public.room_max_participants(p_slot_id text)
returns int
language sql stable security definer set search_path = ''
as $$
  select s.capacity
         + greatest(coalesce((
             select count(*)::int from public.programme_experts pe
               join public.programmes p on p.id = pe.programme_id
              where pe.status = 'accepted'
                and (p.offering_id = s.offering_id or p.id = s.offering_id)), 0), 1)
         + 1
    from public.booking_slots s where s.id = p_slot_id;
$$;

revoke all on function public.room_max_participants(text) from public, anon, authenticated;
grant execute on function public.room_max_participants(text) to authenticated;

-- EXPAND. The host's route with the one argument it reads. 0123 kept
-- five ignored arguments so the deployed livekit-token kept resolving;
-- PostgREST picks an overload by the argument NAMES sent, so the old
-- deploy (six names) still reaches the 6-argument version and the new
-- deploy (one name) reaches this one. CONTRACT: the 6-argument version
-- is dropped by the next learning migration, once the new livekit-token
-- is deployed. Body = 0123's, plus the host_missed refusal.
create or replace function public.open_session_room(p_slot_id text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := auth.uid();
  v_now  timestamptz := now();
  v_lead interval := interval '30 minutes';
  v_tail interval := interval '15 minutes';
  v_slot public.booking_slots;
  v_ends timestamptz;
begin
  if v_uid is null then
    return null;
  end if;

  select * into v_slot from public.booking_slots s where s.id = p_slot_id;
  if v_slot.id is null then
    return null;
  end if;

  if v_slot.expert_id is null
     or v_slot.expert_id not in (select public.my_expert_ids()) then
    return null;
  end if;

  -- (0128) The session was closed at +20 and everyone has their seat
  -- back. Opening the room now would teach an empty class.
  if v_slot.outcome = 'host_missed' then
    return jsonb_build_object('ok', false, 'reason', 'host_missed',
      'starts_utc', to_char(v_slot.starts_utc, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'));
  end if;

  v_ends := v_slot.starts_utc
            + make_interval(mins => greatest(coalesce(v_slot.duration_min, 60), 1));

  if v_now < (v_slot.starts_utc - v_lead) then
    return jsonb_build_object(
      'ok',         false,
      'reason',     'too_early',
      'opens_utc',  to_char(v_slot.starts_utc - v_lead,
                            'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
      'starts_utc', to_char(v_slot.starts_utc, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
    );
  end if;
  if v_now > (v_ends + v_tail) then
    return jsonb_build_object(
      'ok',       false,
      'reason',   'ended',
      'ends_utc', to_char(v_ends, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
    );
  end if;

  return jsonb_build_object(
    'ok',          true,
    'slot_id',     v_slot.id,
    'role',        case when v_slot.capacity > 1 then 'host' else 'expert' end,
    'can_publish', true,
    'capacity',    v_slot.capacity,
    'starts_utc',  to_char(v_slot.starts_utc, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    'ends_utc',    to_char(v_ends, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    'counterpart', ''
  );
end;
$$;

revoke all on function public.open_session_room(text) from public, anon;
grant execute on function public.open_session_room(text) to authenticated;


-- ---------------------------------------------------------------------
-- 5. LA-19 / LA-9 -- recordings.
--
-- THE PIPE. The host joins a class -> livekit-webhook starts LiveKit
-- egress (room composite, MP4) into the private `recordings` bucket ->
-- egress ends -> the webhook hands Mux a 24-hour signed URL to that file
-- and asks for an asset with a SIGNED playback policy -> Mux's webhook
-- says ready -> the playback id is written here. A course lesson video
-- is the same row with lesson_id set, registered by the team after an
-- upload in the Mux dashboard.
--
-- THE RULE (LA-9). Nothing about a recording is readable by a client.
-- Playback goes through the recording-playback edge function, which asks
-- recording_for_playback / lesson_video (below) and only then signs a
-- Mux token that lives two hours. A copied link stops working; a
-- refunded parent's next request is refused (has_course_access reads
-- the receipt's status).
--
-- D4: the MP4 stays in the bucket after Mux has it. It is the master
-- copy, and the way out if Mux is ever replaced. ~1 GB a class hour.
-- ---------------------------------------------------------------------
create table if not exists public.programme_recordings (
  id              text        primary key
                    default ('rec_' || replace(gen_random_uuid()::text, '-', '')),
  programme_id    text        not null references public.programmes (id) on delete cascade,
  run_id          text,
  session_id      text,
  slot_id         text,
  lesson_id       text,
  is_preview      boolean     not null default false,
  title           text        not null default '',
  status          text        not null default 'starting'
                    check (status in ('starting', 'recording', 'uploaded',
                                      'importing', 'ready', 'failed')),
  egress_id       text        unique,
  storage_path    text,
  mux_asset_id    text        unique,
  mux_playback_id text,
  duration_s      numeric,
  error           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  check (slot_id is not null or lesson_id is not null)
);
create unique index if not exists programme_recordings_slot_uidx
  on public.programme_recordings (slot_id) where slot_id is not null;
create unique index if not exists programme_recordings_lesson_uidx
  on public.programme_recordings (programme_id, lesson_id) where lesson_id is not null;

alter table public.programme_recordings enable row level security;
revoke all on public.programme_recordings from anon, authenticated;
grant select, insert, update on public.programme_recordings to directus_cms;
drop policy if exists "programme_recordings cms" on public.programme_recordings;
create policy "programme_recordings cms" on public.programme_recordings
  for all to directus_cms using (true) with check (true);

-- Private, and no storage policies at all: only the service role (the
-- edge functions) and the S3 keys egress uses can reach it.
insert into storage.buckets (id, name, public)
values ('recordings', 'recordings', false)
on conflict (id) do nothing;

-- Claim the recording of a slot, once. Returns {id, programme_id} when
-- the caller should start egress, null when it should not: a consult
-- (D1: never recorded), a slot with no programme, a session the host
-- missed, or one already recording. A FAILED start may be claimed again,
-- so a host who reconnects gets a second try.
create or replace function public.begin_recording(p_slot_id text)
returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  s       public.booking_slots;
  v_prog  text;
  v_run   text;
  v_sess  text;
  v_title text;
  v_id    text;
begin
  select * into s from public.booking_slots where id = p_slot_id;
  if s.id is null or s.capacity <= 1 or s.outcome = 'host_missed' then
    return null;
  end if;

  select ps.programme_id, ps.run_id, ps.id, coalesce(nullif(ps.title, ''), p.title)
    into v_prog, v_run, v_sess, v_title
    from public.programme_sessions ps
    join public.programmes p on p.id = ps.programme_id
   where 'ps_' || ps.id = p_slot_id;

  if v_prog is null then
    select p.id, p.title into v_prog, v_title from public.programmes p
     where p.offering_id = s.offering_id or p.id = s.offering_id
     order by (p.offering_id = s.offering_id) desc
     limit 1;
  end if;
  if v_prog is null then return null; end if;

  insert into public.programme_recordings
    (programme_id, run_id, session_id, slot_id, title, status)
  values
    (v_prog, v_run, v_sess, p_slot_id, coalesce(v_title, ''), 'starting')
  on conflict (slot_id) where slot_id is not null
  do update set status = 'starting', error = null, egress_id = null, updated_at = now()
     where public.programme_recordings.status = 'failed'
  returning id into v_id;

  if v_id is null then return null; end if;
  return jsonb_build_object('id', v_id, 'programme_id', v_prog);
end;
$$;

revoke all on function public.begin_recording(text) from public, anon, authenticated;
grant execute on function public.begin_recording(text) to service_role;

-- Who may watch. THE access rule is has_course_access(..., 'recording')
-- (0126); two cases sit beside it, both stated here so there is still
-- one place to read:
--   * a preview lesson (course lesson 1) is open to everyone;
--   * whoever held a seat in that session (attended or missed -- the
--     recording exists for the one who missed it) may watch it, which
--     covers a seat paid for with a credit, where there is no receipt.
-- A refund cancels her seat and revokes the receipt, so both doors shut.
create or replace function public._recording_access(r public.programme_recordings)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select r.is_preview
      or public.has_course_access(r.programme_id, 'recording')
      or (r.slot_id is not null and exists (
            select 1 from public.booking_bookings b
             where b.slot_id = r.slot_id and b.user_id = auth.uid()
               and b.status in ('upcoming', 'attended', 'missed')));
$$;

create or replace function public.recording_for_playback(p_recording_id text)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  r public.programme_recordings;
begin
  if auth.uid() is null then return null; end if;
  select * into r from public.programme_recordings where id = p_recording_id;
  if r.id is null or r.status <> 'ready' or r.mux_playback_id is null
     or not public._recording_access(r) then
    return null;
  end if;
  return jsonb_build_object('recording_id', r.id, 'playback_id', r.mux_playback_id,
                            'title', r.title, 'duration_s', r.duration_s);
end;
$$;

create or replace function public.lesson_video(p_programme_id text, p_lesson_id text)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  r public.programme_recordings;
begin
  if auth.uid() is null then return null; end if;
  select * into r from public.programme_recordings
   where programme_id = p_programme_id and lesson_id = p_lesson_id;
  if r.id is null or r.status <> 'ready' or r.mux_playback_id is null
     or not public._recording_access(r) then
    return null;
  end if;
  return jsonb_build_object('recording_id', r.id, 'playback_id', r.mux_playback_id,
                            'title', r.title, 'duration_s', r.duration_s);
end;
$$;

-- Your bookings › Past: every session recording she may watch, with its
-- state, so a row can say "on its way" before it says "watch". Never the
-- playback id: that is only handed out signed.
create or replace function public.my_recordings()
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
           'id', r.id, 'slot_id', r.slot_id, 'programme_id', r.programme_id,
           'title', r.title, 'status', r.status, 'duration_s', r.duration_s)
         order by r.created_at desc), '[]'::jsonb)
    from public.programme_recordings r
   where auth.uid() is not null
     and r.slot_id is not null
     and r.status in ('recording', 'uploaded', 'importing', 'ready')
     and public._recording_access(r);
$$;

-- The host's "Stop recording": the egress to stop, for a moderator of
-- the slot only (can_moderate_slot, 0079).
create or replace function public.recording_egress_for_slot(p_slot_id text)
returns text
language sql stable security definer set search_path = ''
as $$
  select r.egress_id from public.programme_recordings r
   where r.slot_id = p_slot_id and r.status = 'recording'
     and public.can_moderate_slot(p_slot_id);
$$;

revoke all on function public.recording_for_playback(text) from public, anon, authenticated;
revoke all on function public.lesson_video(text, text) from public, anon, authenticated;
revoke all on function public.my_recordings() from public, anon, authenticated;
revoke all on function public.recording_egress_for_slot(text) from public, anon, authenticated;
grant execute on function public.recording_for_playback(text) to authenticated;
grant execute on function public.lesson_video(text, text) to authenticated;
grant execute on function public.my_recordings() to authenticated;
grant execute on function public.recording_egress_for_slot(text) to authenticated;

comment on column public.programme_sessions.recording_url is
  'Superseded by programme_recordings (0128): a URL cannot be a signed, short-lived playback. Kept, unused, for revert.';


-- ---------------------------------------------------------------------
-- 6. LA-29 -- a consult start must fit the doctor's schedule.
--
-- book_slot made a real-expert consult slot at whatever minute the
-- parent's phone named: the right expert, price and length, but any
-- time at all -- 3 AM on a Sunday, the middle of her holiday. The rule
-- that turns a schedule into bookable times is ~200 lines of Dart
-- (generateSlots, lib/doctor/doctor_schedule.dart). This is that rule
-- in SQL, line for line, in the doctor's clock (IST).
--
-- ONE RULE IN TWO LANGUAGES drifts unless something holds the copies
-- together. Both answer the same case table:
-- test/fixtures/schedule_parity_cases.json. The Dart test runs it
-- through generateSlots; _schedule_parity_selftest() below runs the
-- copy embedded in this file through this function; and the Dart test
-- fails if the two copies of the table differ.
--
-- The pure function works in wall-clock `timestamp` (no zone): the
-- doctor's "10:00" is 10:00 in her clinic. India keeps one offset all
-- year, so `at time zone 'Asia/Kolkata'` at the edge is exact.
-- ---------------------------------------------------------------------

-- DoctorSchedule.starter: what the app assumes for a doctor with no row.
create or replace function public._starter_schedule()
returns jsonb
language sql immutable set search_path = ''
as $$
  select jsonb_build_object(
    'byWeekday', (select jsonb_object_agg(d::text,
                    case when d <= 6
                         then '{"sessions":[{"start":600,"end":780},{"start":1020,"end":1200}]}'::jsonb
                         else '{"sessions":[]}'::jsonb end)
                    from generate_series(1, 7) d),
    'rules', '{}'::jsonb, 'timeOff', '[]'::jsonb, 'overrides', '{}'::jsonb,
    'paused', false);
$$;

-- _sessionsFor(): time off, then a date override, then the weekday.
create or replace function public._sessions_for_day(p_schedule jsonb, p_day date)
returns jsonb
language plpgsql immutable set search_path = ''
as $$
declare
  v_ov jsonb;
begin
  if exists (
    select 1 from jsonb_array_elements(coalesce(p_schedule->'timeOff', '[]'::jsonb)) t
     where p_day between left(t->>'from', 10)::date and left(t->>'to', 10)::date
  ) then
    return '[]'::jsonb;
  end if;
  v_ov := p_schedule->'overrides'->to_char(p_day, 'YYYY-MM-DD');
  if v_ov is not null and coalesce((v_ov->>'closed')::boolean, false) then
    return '[]'::jsonb;
  end if;
  if v_ov is not null and jsonb_typeof(v_ov->'sessions') = 'array' then
    return v_ov->'sessions';
  end if;
  return coalesce(p_schedule->'byWeekday'->(extract(isodow from p_day)::int::text)->'sessions',
                  '[]'::jsonb);
end;
$$;

-- DaySchedule.spillMin: how far the day's latest session runs past midnight.
create or replace function public._spill_min(p_sessions jsonb)
returns int
language sql immutable set search_path = ''
as $$
  select coalesce(max(greatest((s->>'end')::int - 1440, 0)), 0)
    from jsonb_array_elements(coalesce(p_sessions, '[]'::jsonb)) s;
$$;

-- generateSlots(), asked about ONE start: would the parent have been
-- offered it? Walks the two days the start could belong to (its own,
-- and the day before, whose late session may run past midnight), in
-- the same order generateSlots walks them.
create or replace function public._slot_fits_schedule(
  p_schedule jsonb,
  p_booked   timestamp[],
  p_now      timestamp,
  p_start    timestamp
) returns boolean
language plpgsql immutable set search_path = ''
as $$
declare
  r          jsonb := coalesce(p_schedule->'rules', '{}'::jsonb);
  v_slot     int := coalesce((r->>'slotMinutes')::int, 30);
  v_before   int := coalesce((r->>'bufferBeforeMin')::int, 0);
  v_after    int := coalesce((r->>'bufferAfterMin')::int, 5);
  v_max_day  int := coalesce((r->>'maxPerDay')::int, 8);
  v_max_run  int := coalesce((r->>'maxConsecutive')::int, 4);
  v_notice   int := coalesce((r->>'minNoticeMinutes')::int, 120);
  v_window   int := coalesce((r->>'advanceWindowDays')::int, 30);
  v_stride   int;
  v_today    date := p_now::date;
  v_earliest timestamp;
  v_latest   timestamp;
  v_booked   timestamp[] := coalesce(p_booked, '{}');
  v_day      date;
  v_sessions jsonb;
  v_from0    timestamp;
  v_to0      timestamp;
  v_left     int;
  v_rank     int;
  v_s        jsonb;
  v_s_start  int;
  v_s_end    int;
  v_cursor   int;
  v_start    timestamp;
  v_run      int;
  v_probe    timestamp;
begin
  if p_schedule is null or p_start is null or p_now is null then return false; end if;
  if coalesce((p_schedule->>'paused')::boolean, false) then return false; end if;
  if v_slot <= 0 then return false; end if;

  v_stride   := v_before + v_slot + v_after;
  v_earliest := p_now + make_interval(mins => v_notice);
  v_latest   := v_today + make_interval(days => v_window);

  foreach v_day in array array[p_start::date - 1, p_start::date] loop
    -- The walk covers today .. today + window - 1 (days = window, and it
    -- stops past `latest`). Yesterday is never walked.
    continue when v_day < v_today or v_day > v_today + (v_window - 1);

    v_sessions := public._sessions_for_day(p_schedule, v_day);
    continue when jsonb_array_length(v_sessions) = 0;

    -- The day's cap counts the SHIFT: from where yesterday's night ended
    -- to where tonight's ends.
    v_from0 := v_day + make_interval(mins => public._spill_min(
                 public._sessions_for_day(p_schedule, v_day - 1)));
    v_to0   := (v_day + 1) + make_interval(mins => public._spill_min(v_sessions));
    select v_max_day - count(distinct b) into v_left
      from unnest(v_booked) b where b >= v_from0 and b < v_to0;
    continue when v_left <= 0;

    v_rank := 0;
    for v_s in select e.value from jsonb_array_elements(v_sessions) with ordinality e
                order by e.ordinality loop
      v_s_start := (v_s->>'start')::int;
      v_s_end   := (v_s->>'end')::int;
      -- Session.isValid
      continue when not (v_s_start >= 0 and v_s_start < 1440 and v_s_end > v_s_start
                         and v_s_end - v_s_start <= 1440);

      v_cursor := v_s_start + v_before;
      while v_cursor + v_slot <= v_s_end loop
        v_start  := v_day + make_interval(mins => v_cursor);
        v_cursor := v_cursor + v_stride;

        continue when v_start = any (v_booked);
        continue when v_start < v_earliest;
        continue when v_start > v_latest;
        if v_max_run > 0 then
          v_run := 0;
          v_probe := v_start;
          while v_run < v_max_run loop
            v_probe := v_probe - make_interval(mins => v_stride);
            exit when not (v_probe = any (v_booked));
            v_run := v_run + 1;
          end loop;
          continue when v_run >= v_max_run;
        end if;

        -- Offered, in this order; the day keeps only the first v_left.
        v_rank := v_rank + 1;
        if v_start = p_start and v_rank <= v_left then
          return true;
        end if;
      end loop;
    end loop;
  end loop;

  return false;
end;
$$;

-- The question book_slot asks, against the live data: the doctor's
-- schedule (the starter clinic when she has none, as the app assumes)
-- and every consult she already has.
create or replace function public.slot_fits_schedule(p_expert_id text, p_start timestamptz)
returns boolean
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_sched  jsonb;
  v_booked timestamp[];
begin
  select ds.schedule into v_sched from public.doctor_schedule ds
   where ds.expert_id = p_expert_id;
  if not found then v_sched := public._starter_schedule(); end if;

  select array_agg(distinct b.starts_utc at time zone 'Asia/Kolkata') into v_booked
    from public.booking_bookings b
    join public.booking_slots s on s.id = b.slot_id
   where s.expert_id = p_expert_id and s.capacity = 1
     and b.status <> 'cancelled'
     and b.starts_utc > now() - interval '2 days';

  return public._slot_fits_schedule(v_sched, v_booked,
    (now() at time zone 'Asia/Kolkata'), (p_start at time zone 'Asia/Kolkata'));
end;
$$;

-- The shared case table, byte for byte the fixture's meaning.
create or replace function public._schedule_parity_cases()
returns jsonb
language sql immutable set search_path = ''
as $fn$
  select $cases$
[
 {
  "name": "first morning slot, exactly at the notice edge",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-02T04:30:00Z",
  "expect": true
 },
 {
  "name": "inside the notice period",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T03:00:00Z",
  "booked": [],
  "start": "2026-11-02T04:30:00Z",
  "expect": false
 },
 {
  "name": "off the grid",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-02T04:45:00Z",
  "expect": false
 },
 {
  "name": "last slot that fits the morning session",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-02T06:50:00Z",
  "expect": true
 },
 {
  "name": "would run past the session end",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-02T07:25:00Z",
  "expect": false
 },
 {
  "name": "first evening slot",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-02T11:30:00Z",
  "expect": true
 },
 {
  "name": "ninth slot of the day is past maxPerDay",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-02T13:15:00Z",
  "expect": false
 },
 {
  "name": "Sunday is closed",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-08T04:30:00Z",
  "expect": false
 },
 {
  "name": "a later weekday on the stride",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-03T05:05:00Z",
  "expect": true
 },
 {
  "name": "time off removes the day",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [
    {
     "from": "2026-11-04T00:00:00.000",
     "to": "2026-11-04T00:00:00.000",
     "reason": "Conference"
    }
   ],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-04T04:30:00Z",
  "expect": false
 },
 {
  "name": "a closed date override",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {
    "2026-11-05": {
     "date": "2026-11-05T00:00:00.000",
     "closed": true
    }
   },
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-05T04:30:00Z",
  "expect": false
 },
 {
  "name": "override hours replace the weekday",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {
    "2026-11-06": {
     "date": "2026-11-06T00:00:00.000",
     "closed": false,
     "sessions": [
      {
       "start": 840,
       "end": 900
      }
     ]
    }
   },
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-06T08:30:00Z",
  "expect": true
 },
 {
  "name": "override hours drop the weekday's",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {
    "2026-11-06": {
     "date": "2026-11-06T00:00:00.000",
     "closed": false,
     "sessions": [
      {
       "start": 840,
       "end": 900
      }
     ]
    }
   },
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-06T04:30:00Z",
  "expect": false
 },
 {
  "name": "paused takes nothing",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": true
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-03T04:30:00Z",
  "expect": false
 },
 {
  "name": "last day inside the advance window",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-12-01T04:30:00Z",
  "expect": true
 },
 {
  "name": "first day past the advance window",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-12-02T04:30:00Z",
  "expect": false
 },
 {
  "name": "an already booked time",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [
   "2026-11-03T05:05:00Z"
  ],
  "start": "2026-11-03T05:05:00Z",
  "expect": false
 },
 {
  "name": "four back to back force a break",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [
   "2026-11-03T04:30:00Z",
   "2026-11-03T05:05:00Z",
   "2026-11-03T05:40:00Z",
   "2026-11-03T06:15:00Z"
  ],
  "start": "2026-11-03T06:50:00Z",
  "expect": false
 },
 {
  "name": "three back to back still allow a fourth",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [
   "2026-11-03T04:30:00Z",
   "2026-11-03T05:05:00Z",
   "2026-11-03T05:40:00Z"
  ],
  "start": "2026-11-03T06:15:00Z",
  "expect": true
 },
 {
  "name": "the day's cap keeps the earliest free slots",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [
   "2026-11-03T04:30:00Z",
   "2026-11-03T05:05:00Z",
   "2026-11-03T05:40:00Z",
   "2026-11-03T11:30:00Z",
   "2026-11-03T12:05:00Z",
   "2026-11-03T12:40:00Z"
  ],
  "start": "2026-11-03T06:50:00Z",
  "expect": true
 },
 {
  "name": "the day's cap drops the later ones",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [
   "2026-11-03T04:30:00Z",
   "2026-11-03T05:05:00Z",
   "2026-11-03T05:40:00Z",
   "2026-11-03T11:30:00Z",
   "2026-11-03T12:05:00Z",
   "2026-11-03T12:40:00Z"
  ],
  "start": "2026-11-03T13:15:00Z",
  "expect": false
 },
 {
  "name": "a night session's slot after midnight belongs to the evening",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 1320,
       "end": 1560
      }
     ]
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-02T20:00:00Z",
  "expect": true
 },
 {
  "name": "a night session's slot past its end",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 1320,
       "end": 1560
      }
     ]
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-02T20:35:00Z",
  "expect": false
 },
 {
  "name": "the night's cap counts across midnight",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 1320,
       "end": 1560
      }
     ]
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 2,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [
   "2026-11-02T16:30:00Z",
   "2026-11-02T17:05:00Z"
  ],
  "start": "2026-11-02T18:50:00Z",
  "expect": false
 },
 {
  "name": "yesterday's night is not offered after midnight",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 1320,
       "end": 1560
      }
     ]
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 0,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 0,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T18:40:00Z",
  "booked": [],
  "start": "2026-11-02T20:00:00Z",
  "expect": false
 },
 {
  "name": "buffers move the grid",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 10,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-02T04:40:00Z",
  "expect": true
 },
 {
  "name": "buffers move the grid off the old time",
  "schedule": {
   "byWeekday": {
    "1": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "2": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "3": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "4": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "5": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "6": {
     "sessions": [
      {
       "start": 600,
       "end": 780
      },
      {
       "start": 1020,
       "end": 1200
      }
     ]
    },
    "7": {
     "sessions": []
    }
   },
   "rules": {
    "slotMinutes": 30,
    "bufferBeforeMin": 10,
    "bufferAfterMin": 5,
    "maxPerDay": 8,
    "maxConsecutive": 4,
    "minNoticeMinutes": 120,
    "advanceWindowDays": 30,
    "autoConfirm": true
   },
   "timeOff": [],
   "overrides": {},
   "paused": false
  },
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-02T04:30:00Z",
  "expect": false
 },
 {
  "name": "no schedule row means the starter clinic",
  "schedule": null,
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-03T12:05:00Z",
  "expect": true
 },
 {
  "name": "an empty schedule offers nothing",
  "schedule": {},
  "now": "2026-11-02T02:30:00Z",
  "booked": [],
  "start": "2026-11-03T04:30:00Z",
  "expect": false
 }
]
$cases$::jsonb;
$fn$;

-- Run once after this migration: every row's ok must be true.
--   select * from public._schedule_parity_selftest() where not ok;   -> no rows
create or replace function public._schedule_parity_selftest()
returns table (name text, expected boolean, got boolean, ok boolean)
language sql stable set search_path = ''
as $$
  select c->>'name',
         (c->>'expect')::boolean,
         public._slot_fits_schedule(
           case when jsonb_typeof(c->'schedule') = 'null' or c->'schedule' is null
                then public._starter_schedule() else c->'schedule' end,
           array(select (b #>> '{}')::timestamptz at time zone 'Asia/Kolkata'
                   from jsonb_array_elements(c->'booked') b),
           (c->>'now')::timestamptz at time zone 'Asia/Kolkata',
           (c->>'start')::timestamptz at time zone 'Asia/Kolkata'),
         public._slot_fits_schedule(
           case when jsonb_typeof(c->'schedule') = 'null' or c->'schedule' is null
                then public._starter_schedule() else c->'schedule' end,
           array(select (b #>> '{}')::timestamptz at time zone 'Asia/Kolkata'
                   from jsonb_array_elements(c->'booked') b),
           (c->>'now')::timestamptz at time zone 'Asia/Kolkata',
           (c->>'start')::timestamptz at time zone 'Asia/Kolkata')
           = (c->>'expect')::boolean
    from jsonb_array_elements(public._schedule_parity_cases()) c;
$$;


-- ---------------------------------------------------------------------
-- 7. book_slot -- LA-29 + LA-32. Copied from 0126 (the last definition).
--
-- LA-29: a new consult slot must fit the doctor's schedule.
--
-- LA-32, EXPAND. Expert, start, length, capacity, stage and title get
-- defaults. PostgREST finds a function by the argument NAMES it is sent,
-- so while they had none the app could not stop sending them. Postgres
-- requires every argument after the first defaulted one to have a
-- default too, which is why stage and title are in the list: the server
-- can name them (price_offering) when the phone does not. Adding a
-- default is allowed by `create or replace` (removing one is not), and
-- the argument types are unchanged, so this REPLACES the function rather
-- than adding a second overload beside it.
-- CONTRACT, later: the app stops sending them once this is run (it
-- still sends the start for a consult -- that is her pick).
--
-- The 0066 credit claim is carried forward (test/
-- learning_security_contract_test.dart reads this, the last definition).
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
-- 8. LA-28 -- this file's internals are closed to users, every overload.
-- (Supabase grants every new function to anon and authenticated by
-- name; a revoke from PUBLIC alone closes nothing. See 0126 §12.)
-- ---------------------------------------------------------------------
revoke all on function public.record_room_event(jsonb) from public, anon, authenticated;
grant execute on function public.record_room_event(jsonb) to service_role;
revoke all on function public._host_seen(text) from public, anon, authenticated;
revoke all on function public._settle_slot(text) from public, anon, authenticated;
revoke all on function public._send_ops_alert() from public, anon, authenticated;
revoke all on function public._slot_line(text) from public, anon, authenticated;
revoke all on function public._declare_host_missed(text) from public, anon, authenticated;
revoke all on function public.sweep_live_sessions() from public, anon, authenticated;
revoke all on function public._recording_access(public.programme_recordings) from public, anon, authenticated;
revoke all on function public._starter_schedule() from public, anon, authenticated;
revoke all on function public._sessions_for_day(jsonb, date) from public, anon, authenticated;
revoke all on function public._spill_min(jsonb) from public, anon, authenticated;
revoke all on function public._slot_fits_schedule(jsonb, timestamp[], timestamp, timestamp) from public, anon, authenticated;
revoke all on function public.slot_fits_schedule(text, timestamptz) from public, anon, authenticated;
revoke all on function public._schedule_parity_cases() from public, anon, authenticated;
revoke all on function public._schedule_parity_selftest() from public, anon, authenticated;


-- =====================================================================
-- VERIFY (SQL editor), after running this file.
--
-- A. One read-only query. Every column should be true.
--
--   select
--     (select count(*) = 0 from public._schedule_parity_selftest() where not ok)
--                                                                       as parity_ok,
--     (select bool_and(prosrc like '%slot_fits_schedule%'
--                  and prosrc like '%for update skip locked%')
--        from pg_proc where proname = 'book_slot')                      as book_slot_ok,
--     (select count(*) = 1 from pg_proc where proname = 'book_slot')    as one_book_slot,
--     (select count(*) = 2 from pg_proc where proname = 'open_session_room')
--                                                                       as room_expanded,
--     exists (select 1 from cron.job where jobname = 'live-sessions-sweep')
--                                                                       as sweep_scheduled,
--     exists (select 1 from storage.buckets where id = 'recordings' and not public)
--                                                                       as bucket_private,
--     not has_function_privilege('authenticated',
--       'public.record_room_event(jsonb)', 'execute')                   as webhook_server_only,
--     not has_function_privilege('authenticated',
--       'public.sweep_live_sessions()', 'execute')                      as sweep_server_only,
--     has_function_privilege('authenticated',
--       'public.session_state(text)', 'execute')                        as waiting_room_can_ask;
--
-- B. The sweep runs. After two minutes:
--   select status, return_message, start_time from cron.job_run_details
--    where jobid = (select jobid from cron.job where jobname = 'live-sessions-sweep')
--    order by start_time desc limit 3;                  -> succeeded
--
-- C. (D2, when you have a Discord or Slack webhook URL)
--   select vault.create_secret('<url>', 'team_alert_webhook_url');
--   insert into public.ops_alerts (kind, ref_id, title)
--   values ('host_unknown', 'test_' || now(), 'ParentVeda alert test');
--   -> a message in the channel; the row's sent_at is set.
-- =====================================================================
