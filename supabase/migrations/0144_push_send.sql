-- 0144 — Phase 6b, B4: the sender's side of the database (2026-10-30).
-- docs/NOTIFICATIONS-6B-PLAN.md, "For B4", "For B4, agreed with Community
-- phase 3", "As built: B4".
--
-- WHY: 0143 books tonight's campaign in push_sends at 10:00 IST. Nothing
-- sends it. The edge function push-send (supabase/functions/push-send) does,
-- and this file is everything it touches: ONE function that hands it the due
-- rows, ONE that takes the result back. The sender knows no table, so
-- Community (phase 3) adds its own queue as a branch in these two functions
-- and never edits the sender. The outbox-and-worker shape.
--
-- WHAT:
--   push_sends.claimed_at   the lease: a row being sent is not handed out twice.
--   push_tests              a second queue: pv_campaign_test's sends to your
--                           own phone. Not push_sends, because a test there
--                           would use up your real booking of that campaign
--                           (one campaign reaches a person once) and count
--                           toward the weekly cap.
--   pv_push_due(limit)      claims and returns due rows, every queue, one shape.
--   pv_push_mark(...)       records a send; drops dead tokens.
--   pv_push_tick()          the every-minute cron. Ends the late rows itself,
--                           and calls push-send ONLY when something is due.
--   pv_campaign_test(id, email)   your own devices, now, whatever the targeting.
--
-- ⚠️ AT LEAST ONCE, NEVER LOST. A row is claimed for 5 minutes. If the sender
-- dies mid-run, the claim lapses and the next minute sends it again. The
-- price: a crash after FCM accepted but before the mark sends twice. The
-- Android tag (collapse_key) makes the second replace the first on her phone
-- instead of stacking. Losing a message was the worse failure.
--
-- SETUP (the user, once; docs/NOTIFICATIONS-6B-PLAN.md "As built: B4"):
--   select vault.create_secret('https://<ref>.supabase.co/functions/v1/push-send', 'push_send_url');
--   select vault.create_secret('<the same value as PUSH_SEND_SECRET>', 'push_send_secret');
-- No secret: the tick still ends late rows and calls nothing.
--
-- PREREQ: 0140, 0143, pg_cron (0018), pg_net (0128). Safe to re-run.
-- =====================================================================

-- 1) The lease on push_sends -------------------------------------------

-- Set by pv_push_due when it hands a row out; cleared by pv_push_mark. A row
-- claimed more than 5 minutes ago is free again (the sender died).
alter table public.push_sends add column if not exists claimed_at timestamptz;

-- 2) push_tests: the test queue ----------------------------------------

create table if not exists public.push_tests (
  id           uuid primary key default gen_random_uuid(),
  -- cascade: a test is not a record worth keeping past its campaign.
  campaign_id  text not null references public.push_campaigns (id) on delete cascade,
  user_id      uuid not null references auth.users (id) on delete cascade,
  status       text not null default 'queued'
               check (status in ('queued', 'sent', 'failed', 'skipped')),
  error        text,
  devices_sent int  not null default 0,
  sent_at      timestamptz,
  claimed_at   timestamptz,
  -- A test not sent within 10 minutes is stale: you have moved on.
  send_before  timestamptz not null default now() + interval '10 minutes',
  created_at   timestamptz not null default now()
);

alter table public.push_tests enable row level security;
revoke all on table public.push_tests from anon, authenticated;

-- 3) pv_push_due: every due row, one shape -----------------------------

-- Claims up to p_limit due rows across every queue and returns them. The
-- sender sends each to `tokens` and reports back through pv_push_mark.
--
--   queue         which branch the row came from ('push_sends', 'push_tests')
--   row_id        its id in that queue; also goes into the push data
--   user_id       who it is for
--   tokens        her devices that can open the link (never empty)
--   title, body   the text
--   data          FCM data, all strings: link_kind, link_id, queue, row_id.
--                 B5's tap fills tapped_at from queue + row_id.
--   collapse_key  FCM collapse_key and the Android tag: a repeat replaces
--   priority      'normal' or 'high' (Community's crisis alerts)
--   channel       the Android channel, or null for FCM's default
--
-- ⚠️ A BRANCH OWNS ITS RULES. The 19:00 start, the cutoff, which devices can
-- open the link: all here, per queue. The sender only sends.
-- ⚠️ ROWS THAT CAN NO LONGER GO ARE ENDED HERE, not handed out: past the
-- cutoff -> skipped 'past_cutoff'; no device left -> skipped 'no_device'.
create or replace function public.pv_push_due(p_limit int default 500)
returns table (
  queue        text,
  row_id       uuid,
  user_id      uuid,
  tokens       text[],
  title        text,
  body         text,
  data         jsonb,
  collapse_key text,
  priority     text,
  channel      text
)
language plpgsql
security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  -- A claim older than this belongs to a sender that died.
  lease interval := interval '5 minutes';
  n     int := greatest(coalesce(p_limit, 500), 1);
begin
  -- -- push_sends: tonight's campaign bookings (0143) --------------------

  -- Past the cutoff: never a night buzz (row 20).
  update public.push_sends s
     set status = 'skipped', error = 'past_cutoff', claimed_at = null
   where s.status = 'queued' and now() >= s.send_before;

  -- No device left that can open the link (signed out, uninstalled).
  update public.push_sends s
     set status = 'skipped', error = 'no_device', claimed_at = null
    from public.push_campaigns c
   where c.id = s.campaign_id
     and s.status = 'queued'
     and now() >= (s.send_on + time '19:00') at time zone 'Asia/Kolkata'
     and not exists (
           select 1 from public.push_devices d
            where d.user_id = s.user_id
              and d.link_version >= public.pv_push_link_needs(c.link_kind));

  return query
  with due as (
    select s.id
      from public.push_sends s
     where s.status = 'queued'
       -- 19:00 IST on its evening, or later, and before its cutoff.
       and now() >= (s.send_on + time '19:00') at time zone 'Asia/Kolkata'
       and now() <  s.send_before
       and (s.claimed_at is null or s.claimed_at < now() - lease)
     order by s.send_on, s.id
     limit n
     -- Two senders at once each take different rows, never the same one.
     for update of s skip locked
  ),
  claimed as (
    update public.push_sends s
       set claimed_at = now()
      from due
     where s.id = due.id
    returning s.id, s.campaign_id, s.user_id
  )
  select 'push_sends'::text,
         k.id,
         k.user_id,
         array(select d.token from public.push_devices d
                where d.user_id = k.user_id
                  and d.link_version >= public.pv_push_link_needs(c.link_kind)
                order by d.last_seen_at desc),
         c.title,
         c.body,
         jsonb_build_object('link_kind', c.link_kind, 'link_id', c.link_id,
                            'queue', 'push_sends', 'row_id', k.id::text),
         'campaign-' || c.id,
         'normal'::text,
         null::text
    from claimed k
    join public.push_campaigns c on c.id = k.campaign_id;

  -- -- push_tests: pv_campaign_test, now, your own devices ---------------

  update public.push_tests t
     set status = 'skipped', error = 'past_cutoff', claimed_at = null
   where t.status = 'queued' and now() >= t.send_before;

  update public.push_tests t
     set status = 'skipped', error = 'no_device', claimed_at = null
    from public.push_campaigns c
   where c.id = t.campaign_id
     and t.status = 'queued'
     and not exists (
           select 1 from public.push_devices d
            where d.user_id = t.user_id
              and d.link_version >= public.pv_push_link_needs(c.link_kind));

  return query
  with due as (
    select t.id
      from public.push_tests t
     where t.status = 'queued'
       and now() < t.send_before
       and (t.claimed_at is null or t.claimed_at < now() - lease)
     order by t.created_at
     limit n
     for update of t skip locked
  ),
  claimed as (
    update public.push_tests t
       set claimed_at = now()
      from due
     where t.id = due.id
    returning t.id, t.campaign_id, t.user_id
  )
  select 'push_tests'::text,
         k.id,
         k.user_id,
         array(select d.token from public.push_devices d
                where d.user_id = k.user_id
                  and d.link_version >= public.pv_push_link_needs(c.link_kind)
                order by d.last_seen_at desc),
         c.title,
         c.body,
         jsonb_build_object('link_kind', c.link_kind, 'link_id', c.link_id,
                            'queue', 'push_tests', 'row_id', k.id::text),
         'campaign-' || c.id,
         'normal'::text,
         null::text
    from claimed k
    join public.push_campaigns c on c.id = k.campaign_id;
end;
$$;

-- 4) pv_push_mark: the result ------------------------------------------

-- p_status:
--   'sent'     at least one device took it (fills sent_at)
--   'failed'   every device refused it for a reason a retry will not fix
--   'skipped'  nothing to send to (every token was dead)
--   'queued'   a short failure (FCM busy, network): the claim is released and
--              the next minute tries again, until the cutoff ends it
-- p_dead_tokens: tokens FCM answered UNREGISTERED for. Deleted wherever they
-- are: the app is gone from that phone, so the row only costs a failed send.
--
-- Only a row still queued changes: a late mark never overwrites a cancel
-- (pv_campaign_cancel) or a cutoff that came first.
create or replace function public.pv_push_mark(
  p_queue        text,
  p_row_id       uuid,
  p_status       text,
  p_devices_sent int  default 0,
  p_error        text default null,
  p_dead_tokens  text[] default '{}'
)
returns void
language plpgsql
security definer set search_path = ''
as $$
begin
  if p_status not in ('sent', 'failed', 'skipped', 'queued') then
    raise exception 'pv_push_mark: unknown status %', p_status;
  end if;

  if coalesce(cardinality(p_dead_tokens), 0) > 0 then
    delete from public.push_devices d where d.token = any (p_dead_tokens);
  end if;

  if p_queue = 'push_sends' then
    update public.push_sends s
       set status       = p_status,
           devices_sent = coalesce(p_devices_sent, 0),
           error        = left(p_error, 500),
           sent_at      = case when p_status = 'sent' then now() else s.sent_at end,
           claimed_at   = null
     where s.id = p_row_id and s.status = 'queued';
  elsif p_queue = 'push_tests' then
    update public.push_tests t
       set status       = p_status,
           devices_sent = coalesce(p_devices_sent, 0),
           error        = left(p_error, 500),
           sent_at      = case when p_status = 'sent' then now() else t.sent_at end,
           claimed_at   = null
     where t.id = p_row_id and t.status = 'queued';
  else
    raise exception 'pv_push_mark: unknown queue %', p_queue;
  end if;
end;
$$;

-- 5) pv_campaign_test: your own phone, now -----------------------------

-- Queues one test of a campaign (a draft too: the point is to see it before
-- approving) to every device of the account with this email, whatever the
-- targeting, consent or hour. The SQL editor has no auth.uid(), so you name
-- yourself. The next minute's tick sends it. Returns the test row's id:
--   select * from public.push_tests where id = '<it>';
create or replace function public.pv_campaign_test(p_id text, p_email text)
returns uuid
language plpgsql
security definer set search_path = ''
as $$
declare
  v_user uuid;
  v_id   uuid;
begin
  if not exists (select 1 from public.push_campaigns c where c.id = p_id) then
    raise exception 'pv_campaign_test: no campaign %', p_id;
  end if;
  select u.id into v_user
    from auth.users u
   where lower(u.email) = lower(btrim(p_email));
  if v_user is null then
    raise exception 'pv_campaign_test: no account with email %', p_email;
  end if;
  if not exists (select 1 from public.push_devices d where d.user_id = v_user) then
    raise exception 'pv_campaign_test: % has no registered device (open the app signed in, with Firebase configured)', p_email;
  end if;
  insert into public.push_tests (campaign_id, user_id)
  values (p_id, v_user)
  returning id into v_id;
  return v_id;
end;
$$;

-- 6) pv_push_tick: the every-minute cron -------------------------------

-- Is anything due right now, in any queue? Cheap: two indexed exists.
-- Community adds its queue here as well as in pv_push_due.
create or replace function public.pv_push_any_due()
returns boolean
language sql
stable
security definer set search_path = ''
as $$
  select exists (
           select 1 from public.push_sends s
            where s.status = 'queued'
              and now() >= (s.send_on + time '19:00') at time zone 'Asia/Kolkata'
              and now() <  s.send_before
              and (s.claimed_at is null or s.claimed_at < now() - interval '5 minutes'))
      or exists (
           select 1 from public.push_tests t
            where t.status = 'queued'
              and now() < t.send_before
              and (t.claimed_at is null or t.claimed_at < now() - interval '5 minutes'));
$$;

-- ⚠️ AN IDLE MINUTE COSTS ONE QUERY. The HTTP call to push-send (an edge
-- function invocation) happens only when a row is due, so campaigns cost a
-- handful of calls an evening, not 1,440 a day. The late rows are ended here
-- too, so a night with no sender still closes its bookings at 21:00.
-- pg_net is asynchronous: the call is queued and this returns at once.
-- A failure to call is swallowed: the rows stay queued and the next minute
-- tries again, which is the guarantee.
create or replace function public.pv_push_tick()
returns boolean
language plpgsql
security definer set search_path = ''
as $$
declare
  v_url    text;
  v_secret text;
begin
  update public.push_sends
     set status = 'skipped', error = 'past_cutoff', claimed_at = null
   where status = 'queued' and now() >= send_before;
  update public.push_tests
     set status = 'skipped', error = 'past_cutoff', claimed_at = null
   where status = 'queued' and now() >= send_before;

  if not public.pv_push_any_due() then
    return false;
  end if;

  begin
    select max(ds.decrypted_secret) filter (where ds.name = 'push_send_url'),
           max(ds.decrypted_secret) filter (where ds.name = 'push_send_secret')
      into v_url, v_secret
      from vault.decrypted_secrets ds
     where ds.name in ('push_send_url', 'push_send_secret');
  exception when others then
    v_url := null;
  end;
  if coalesce(v_url, '') = '' or coalesce(v_secret, '') = '' then
    return false;
  end if;

  begin
    perform net.http_post(
      url     := v_url,
      body    := '{}'::jsonb,
      headers := jsonb_build_object(
                   'Content-Type', 'application/json',
                   'Authorization', 'Bearer ' || v_secret),
      -- Long enough that pg_net does not drop the connection mid-run.
      timeout_milliseconds := 150000);
  exception when others then
    return false;
  end;
  return true;
end;
$$;

-- ⚠️ NONE OF THESE IS FOR THE APP. pv_push_due hands out tokens; a phone
-- that could call it could read everyone's. Supabase grants new functions to
-- anon and authenticated by default, so revoke, then grant the sender's role.
revoke all on function public.pv_push_due(int) from public, anon, authenticated;
revoke all on function public.pv_push_mark(text, uuid, text, int, text, text[]) from public, anon, authenticated;
revoke all on function public.pv_campaign_test(text, text) from public, anon, authenticated;
revoke all on function public.pv_push_any_due() from public, anon, authenticated;
revoke all on function public.pv_push_tick() from public, anon, authenticated;
grant execute on function public.pv_push_due(int) to service_role;
grant execute on function public.pv_push_mark(text, uuid, text, int, text, text[]) to service_role;
grant execute on function public.pv_campaign_test(text, text) to service_role;
grant execute on function public.pv_push_any_due() to service_role;
grant execute on function public.pv_push_tick() to service_role;

-- 7) The every-minute cron ---------------------------------------------

-- A named job, so re-running this file updates it instead of adding a second.
create extension if not exists pg_net with schema extensions;
create extension if not exists pg_cron;
select cron.schedule(
  'push-send-every-minute',
  '* * * * *',
  $$ select public.pv_push_tick(); $$
);

-- =====================================================================
-- USEFUL COMMANDS (SQL editor)
-- =====================================================================
--   select public.pv_campaign_test('garbh-class-nov', 'you@example.com');
--   select status, devices_sent, error, sent_at from public.push_tests
--    order by created_at desc limit 5;
--   select status, error, count(*) from public.push_sends
--    where send_on = (now() at time zone 'Asia/Kolkata')::date group by 1, 2;
--   select * from net._http_response order by created desc limit 5;  -- pg_net's log
--   select jobname, schedule, active from cron.job where jobname = 'push-send-every-minute';
-- Verify: supabase/seed/verify_push_send.sql
-- =====================================================================
