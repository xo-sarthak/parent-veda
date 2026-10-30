-- 0140 — Phase 6b, B2: where to reach her, her yes or no, and what the phone
-- tells the server (2026-10-30). docs/NOTIFICATIONS-6B-PLAN.md, "The tables".
--
-- WHY: 6b's server sends offers and announcements as visible pushes (decision
-- 1, "can't compromise on iPhone users"). Moving the decision to the server
-- moves its inputs there too: a token to reach the phone, her consent per
-- stage, and the two facts only the phone knows (which evenings already ring,
-- and whether she is in a quiet period after a loss in trying-to-conceive).
-- This migration only stores them. Nothing reads them until B3's
-- pv_push_enqueue.
--
-- WHAT:
--   push_devices   one row per (person, install). No select policy at all:
--                  nothing in the app reads tokens (BACKEND-PATTERNS §8, the
--                  write-only shape).
--   push_consent   one row per (person, stage). Own select, so a phone can
--                  check the server agrees.
--   push_audience  one row per person. No select policy.
--   Every write goes through a security definer function that checks
--   auth.uid() first. No insert/update/delete is granted on any table.
--
-- THE STAGE WORD IS 'trying', NOT 'ttc': the same three words as
-- profiles.life_stage (0041), so B3 joins consent to the profile with a plain
-- equality and no mapping.
--
-- PREREQ: none beyond auth.users. Run before installing a build with B2.
-- =====================================================================

-- 1) push_devices ------------------------------------------------------

create table if not exists public.push_devices (
  user_id      uuid not null references auth.users (id) on delete cascade,
  -- Minted by the app once per install (app-generated ids, CLAUDE.md).
  device_id    text not null check (length(device_id) between 8 and 64),
  -- The FCM token. It rotates; the new one overwrites the row.
  token        text not null check (length(token) between 20 and 4096),
  platform     text not null check (platform in ('android', 'ios')),
  -- Which link kinds this build's opener knows (PushService.linkVersion).
  -- A number raised by hand when the opener learns a kind, so B3 can skip a
  -- build too old to open a campaign's link. A marketing version string
  -- ("1.0.0+2") is the wrong question and awkward to compare in SQL.
  link_version int  not null default 1 check (link_version >= 1),
  created_at   timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  primary key (user_id, device_id)
);

-- ⚠️ ONE TOKEN, ONE ROW, ANYWHERE. A phone signed in as two people one after
-- the other must not keep the first person's offers. pv_push_register deletes
-- the token under any other account; this index makes that a rule of the
-- table and not only of one function.
create unique index if not exists push_devices_token_key
  on public.push_devices (token);

alter table public.push_devices enable row level security;
revoke all on table public.push_devices from anon, authenticated;

-- 2) push_consent ------------------------------------------------------

create table if not exists public.push_consent (
  user_id    uuid not null references auth.users (id) on delete cascade,
  stage      text not null check (stage in ('trying', 'pregnancy', 'parenting')),
  granted    boolean not null,
  -- When she answered, on her phone, not when the write landed. An opt-out
  -- can sit in the phone's retry queue for hours. The DPDP Act record.
  decided_at timestamptz not null,
  source     text not null check (source in ('messages_card', 'messages_switch')),
  updated_at timestamptz not null default now(),
  primary key (user_id, stage)
);

alter table public.push_consent enable row level security;
revoke all on table public.push_consent from anon, authenticated;
grant select on table public.push_consent to authenticated;

drop policy if exists push_consent_own_select on public.push_consent;
create policy push_consent_own_select on public.push_consent
  for select to authenticated
  using (user_id = (select auth.uid()));

-- 3) push_audience -----------------------------------------------------

create table if not exists public.push_audience (
  user_id       uuid primary key references auth.users (id) on delete cascade,
  -- Evenings (IST dates) in the next 14 days where the phone has already set
  -- a 19:00-slot notification. BUSY, not free: an evening missing from the
  -- list, including every one past the upload's horizon, really is free on
  -- that phone, so a phone that has not opened the app in weeks still reads
  -- as free and not as full (decision 13).
  busy_evenings date[]  not null default '{}',
  -- The phone's "no offers now": TTC after a loss, until her first period.
  -- A missing row is NOT quiet; pregnancy loss is read from profiles (0112).
  quiet         boolean not null default false,
  planned_at    timestamptz not null default now()
);

alter table public.push_audience enable row level security;
revoke all on table public.push_audience from anon, authenticated;

-- 4) The functions -----------------------------------------------------

-- Register this install's token. Called on each app open while signed in, and
-- when FCM rotates the token. Refreshes last_seen_at.
create or replace function public.pv_push_register(
  p_device_id    text,
  p_token        text,
  p_platform     text,
  p_link_version int default 1
)
returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'pv_push_register: not signed in';
  end if;
  -- The same token, or the same install, under anyone else goes. RLS could
  -- not let her delete another person's row, and should not; a definer
  -- function can, after the auth.uid() check above.
  delete from public.push_devices d
   where (d.token = p_token or d.device_id = p_device_id)
     and not (d.user_id = uid and d.device_id = p_device_id);

  insert into public.push_devices
    (user_id, device_id, token, platform, link_version, last_seen_at)
  values
    (uid, p_device_id, p_token, p_platform, coalesce(p_link_version, 1), now())
  on conflict (user_id, device_id) do update
    set token        = excluded.token,
        platform     = excluded.platform,
        link_version = excluded.link_version,
        last_seen_at = now();
end;
$$;

-- Sign-out: this install stops receiving. Runs BEFORE the session goes,
-- because afterwards there is no auth.uid() to prove whose row it is.
create or replace function public.pv_push_unregister(p_device_id text)
returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'pv_push_unregister: not signed in';
  end if;
  delete from public.push_devices
   where user_id = uid and device_id = p_device_id;
end;
$$;

-- Her yes or no for one stage. Returns true when it became the stored answer,
-- false when a NEWER answer was already there (another phone decided later).
-- Either way the phone's queued write is done: the server holds her latest.
--
-- ⚠️ THE NEWEST DECISION WINS, BY WHEN SHE DECIDED. A retried write arrives
-- late; without its own timestamp, a "no" queued on one phone would overwrite
-- a "yes" she gave on another phone after it. decided_at is clamped to now(),
-- so a phone with its clock set ahead cannot pin an answer into the future.
-- decided_at only moves when this write wins, so re-sending the same answer
-- keeps the original record.
create or replace function public.pv_push_consent(
  p_stage      text,
  p_granted    boolean,
  p_source     text,
  p_decided_at timestamptz default null
)
returns boolean
language plpgsql
security definer set search_path = ''
as $$
declare
  uid uuid := auth.uid();
  at  timestamptz := least(coalesce(p_decided_at, now()), now());
  n   int;
begin
  if uid is null then
    raise exception 'pv_push_consent: not signed in';
  end if;
  insert into public.push_consent (user_id, stage, granted, decided_at, source, updated_at)
  values (uid, p_stage, p_granted, at, p_source, now())
  on conflict (user_id, stage) do update
    set granted    = excluded.granted,
        decided_at = excluded.decided_at,
        source     = excluded.source,
        updated_at = now()
    where public.push_consent.decided_at <= excluded.decided_at
      and (public.push_consent.granted is distinct from excluded.granted
           or public.push_consent.source is distinct from excluded.source);
  get diagnostics n = row_count;
  if n > 0 then
    return true;
  end if;
  -- No row changed: either the same answer again (it IS the stored answer)
  -- or an older one (it is not).
  return exists (
    select 1 from public.push_consent c
     where c.user_id = uid and c.stage = p_stage and c.granted = p_granted
  );
end;
$$;

-- What the phone just armed. The server keeps only evenings from today to 14
-- days ahead (IST), each once, in order: the phone's plan never looks further,
-- and a date outside that range is a phone clock or a bug, not a booking.
create or replace function public.pv_push_audience(
  p_busy_evenings date[],
  p_quiet         boolean
)
returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  uid   uuid := auth.uid();
  today date := (now() at time zone 'Asia/Kolkata')::date;
  busy  date[];
begin
  if uid is null then
    raise exception 'pv_push_audience: not signed in';
  end if;
  select coalesce(array_agg(distinct d order by d), '{}')
    into busy
    from unnest(coalesce(p_busy_evenings, '{}')) as d
   where d between today and today + 14;

  insert into public.push_audience (user_id, busy_evenings, quiet, planned_at)
  values (uid, busy, coalesce(p_quiet, false), now())
  on conflict (user_id) do update
    set busy_evenings = excluded.busy_evenings,
        quiet         = excluded.quiet,
        planned_at    = now();
end;
$$;

revoke all on function public.pv_push_register(text, text, text, int) from public, anon;
revoke all on function public.pv_push_unregister(text) from public, anon;
revoke all on function public.pv_push_consent(text, boolean, text, timestamptz) from public, anon;
revoke all on function public.pv_push_audience(date[], boolean) from public, anon;
grant execute on function public.pv_push_register(text, text, text, int) to authenticated;
grant execute on function public.pv_push_unregister(text) to authenticated;
grant execute on function public.pv_push_consent(text, boolean, text, timestamptz) to authenticated;
grant execute on function public.pv_push_audience(date[], boolean) to authenticated;
