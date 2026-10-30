-- 0143 — Phase 6b, B3: what to say, who gets it tonight, and the log
-- (2026-10-30). docs/NOTIFICATIONS-6B-PLAN.md, "push_campaigns", "push_sends",
-- "How each rule holds", "Who creates a campaign", decision rows 15 to 22.
--
-- WHY: B2 gave the server its inputs (token, consent, busy evenings, quiet).
-- This is the half that decides. It only WRITES ROWS: push_sends is the
-- booking. B4's push-send drains the queued rows at 19:00 IST. Decide, then
-- send, never in one step (the WhatsApp B3/B4 split): a cron that fires twice
-- hits a unique key and does nothing; a sender that crashes resumes from the
-- rows still queued.
--
-- WHAT:
--   push_campaigns       the text, the link, the targeting, the dates.
--   push_sends           one row per (campaign, person). Own select: the phone
--                        reads its booking (B5).
--   pv_push_holdout      the 10% who never get a campaign (row 15).
--   pv_push_check        EVERY RULE, ONCE. The enqueue and the dry run both
--                        read it, so the two can never disagree.
--   pv_push_enqueue      books tonight. pg_cron, 10:00 IST.
--   pv_campaign_create / _dry_run / _approve / _cancel   the SQL-editor admin.
--
-- ⚠️ THE TEXT RULES ARE TABLE CHECKS, NOT ONLY FUNCTION CHECKS. Directus will
-- later write push_campaigns directly (decision 5) and skip every function.
-- A rule on the table holds for every writer; a rule in a function holds
-- only for the writers who call it.
--
-- ⚠️ CONTENT IS EDITABLE, RULES ARE NOT. Title, body, link, targeting, dates
-- and priority are data. The cap, consent, quiet, holdout, grace, send time
-- and cutoff live in this file and the phone, and no row can change them.
--
-- PREREQ: 0140 (push_devices, push_consent, push_audience), 0016
-- (wa_pregnancy_week), 0110 (pregnancy_ended_at), 0105 (children.removed_at),
-- pg_cron (0018). Run before installing a build with B5. Safe to re-run.
-- =====================================================================

-- 1) push_campaigns ----------------------------------------------------

create table if not exists public.push_campaigns (
  -- A readable slug: 'garbh-sanskar-class-nov'.
  id                text primary key
                    constraint push_campaigns_id_slug
                    check (id ~ '^[a-z0-9][a-z0-9-]{2,63}$'),
  kind              text not null
                    check (kind in ('offer', 'announcement')),
  -- Row 21: a lock screen cuts a title near 50 and a body near 150.
  title             text not null
                    constraint push_campaigns_title_length
                    check (length(btrim(title)) between 1 and 50),
  body              text not null
                    constraint push_campaigns_body_length
                    check (length(btrim(body)) between 1 and 150),
  -- What the tap opens, in the opener's vocabulary (B0, SavedItemOpener).
  link_kind         text not null
                    check (link_kind in ('course', 'product', 'expert', 'read')),
  link_id           text not null check (length(btrim(link_id)) > 0),
  stages            text[] not null
                    constraint push_campaigns_stages
                    check (cardinality(stages) > 0
                           and stages <@ array['trying', 'pregnancy', 'parenting']),
  -- Pregnancy weeks, read for people in pregnancy only.
  week_from         int check (week_from between 0 and 42),
  week_to           int check (week_to between 0 and 42),
  -- A child's age in whole months, read for people in parenting only.
  child_months_from int check (child_months_from between 0 and 72),
  child_months_to   int check (child_months_to between 0 and 72),
  starts_on         date not null,
  ends_on           date not null,
  -- Row 19: two campaigns want one evening: the higher priority, then the
  -- one ending sooner (it has fewer evenings left to reach her).
  priority          int  not null default 0 check (priority between -100 and 100),
  status            text not null default 'draft'
                    check (status in ('draft', 'approved', 'cancelled')),
  created_at        timestamptz not null default now(),
  approved_at       timestamptz,
  cancelled_at      timestamptz,

  constraint push_campaigns_dates check (ends_on >= starts_on),
  constraint push_campaigns_weeks
    check ((week_from is null and week_to is null)
           or ('pregnancy' = any (stages)
               and coalesce(week_from, 0) <= coalesce(week_to, 42))),
  constraint push_campaigns_months
    check ((child_months_from is null and child_months_to is null)
           or ('parenting' = any (stages)
               and coalesce(child_months_from, 0) <= coalesce(child_months_to, 72))),
  -- Decision 10: fixed text. No placeholders...
  constraint push_campaigns_no_placeholders
    check (title !~ '\{\{|\}\}' and body !~ '\{\{|\}\}'),
  -- ...and no week or day number. The same text goes out on many evenings
  -- to people at different points, so "week 20" or "3 days left" is wrong
  -- for most of them, and a week we state must never compete with her
  -- clinic's dating. A hyphenated "7-day trial" is not a count and passes.
  constraint push_campaigns_no_week_or_day_number
    check ((title || ' ' || body) !~*
           '(\m(week|day)s?\s*\d)|(\d\s*(weeks?|days?)\M)|(\d(st|nd|rd|th)\s+(week|day))')
);

alter table public.push_campaigns enable row level security;
revoke all on table public.push_campaigns from anon, authenticated;
grant select on table public.push_campaigns to authenticated;

-- 2) push_sends --------------------------------------------------------

create table if not exists public.push_sends (
  id           uuid primary key default gen_random_uuid(),
  -- restrict, not cascade: the log outlives a mistaken delete.
  campaign_id  text not null references public.push_campaigns (id) on delete restrict,
  user_id      uuid not null references auth.users (id) on delete cascade,
  -- The evening it goes out (IST).
  send_on      date not null,
  -- Row 20: 21:00 IST that evening. B4 skips a row past it: a late sender
  -- must never buzz her at night.
  send_before  timestamptz not null,
  status       text not null default 'queued'
               check (status in ('queued', 'sent', 'failed', 'skipped')),
  error        text,
  devices_sent int  not null default 0,
  sent_at      timestamptz,
  -- Row 16: filled by the phone when she taps (B5).
  tapped_at    timestamptz,
  created_at   timestamptz not null default now(),
  -- One campaign reaches a person at most once, ever.
  constraint push_sends_once unique (campaign_id, user_id)
);

-- ⚠️ ONE CAMPAIGN AN EVENING, AS A RULE OF THE TABLE. pv_push_check already
-- refuses a second booking, but two runs at once could each read "nothing
-- booked" and both insert. A rule a race can break needs a constraint, not
-- only a check. A cancelled (skipped) booking frees the evening.
create unique index if not exists push_sends_one_an_evening
  on public.push_sends (user_id, send_on)
  where status <> 'skipped';

-- B4's sender reads tonight's queued rows.
create index if not exists push_sends_queue
  on public.push_sends (send_on, status);

alter table public.push_sends enable row level security;
revoke all on table public.push_sends from anon, authenticated;
grant select on table public.push_sends to authenticated;

drop policy if exists push_sends_own_select on public.push_sends;
create policy push_sends_own_select on public.push_sends
  for select to authenticated
  using (user_id = (select auth.uid()));

-- She can read a campaign only once it is booked for her: the phone needs
-- tonight's title for Messages, and nothing else.
drop policy if exists push_campaigns_booked_select on public.push_campaigns;
create policy push_campaigns_booked_select on public.push_campaigns
  for select to authenticated
  using (status = 'approved'
         and exists (select 1 from public.push_sends s
                      where s.campaign_id = push_campaigns.id
                        and s.user_id = (select auth.uid())));

-- 3) Small fixed rules -------------------------------------------------

-- Row 15: the holdout. 10% never get a campaign, so push's effect on daily
-- use can be measured against them.
--
-- ⚠️ md5, NOT hashtext. Postgres does not promise hashtext gives the same
-- answer after an upgrade. A holdout that quietly reshuffles mixes the two
-- groups and the measurement is worthless. md5 is the same everywhere,
-- forever. The salt keeps this split independent of any other split on
-- user_id we make later.
create or replace function public.pv_push_holdout(p_user uuid)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select ('x' || left(md5('pv-push-holdout-v1:' || p_user::text), 7))::bit(28)::int % 100 < 10;
$$;

-- The opener version a build needs to open a link kind (push_devices.
-- link_version, PushService.linkVersion). All four kinds open since B0, so 1.
-- When the opener learns a kind, raise the build's number AND add it here.
create or replace function public.pv_push_link_needs(p_kind text)
returns int
language sql
immutable
set search_path = ''
as $$
  select case p_kind
           when 'course'  then 1
           when 'product' then 1
           when 'expert'  then 1
           when 'read'    then 1
           else 2147483647            -- an unknown kind reaches no build
         end;
$$;

-- 4) pv_push_check: every rule, once -----------------------------------

-- One row per (campaign, person in one of its stages). reason is null when
-- every rule passes, else the FIRST rule that failed, in this order:
--
--   not_live          cancelled, or outside its dates
--   no_consent        no "yes" for her current stage (decision 2)
--   no_device         no token on a build that can open the link
--   holdout           the 10% (row 15)
--   new_user          signed up within 7 days (row 17)
--   pregnancy_loss    the 0112 condition (decision 8)
--   phone_quiet       push_audience.quiet: TTC after a loss, the two-week
--                     wait, an active treatment round (row 18)
--   new_baby          a child born in the last 14 days (row 18)
--   not_targeted      pregnancy week or child age outside the range
--   already_reached   this campaign was booked for her before
--   busy_evening      her phone already rings tonight (decision 3)
--   booked_tonight    another campaign has tonight
--   weekly_cap        a campaign in the 7 days ending tonight (row 22)
--
-- With p_campaign null: every approved campaign. With an id: that campaign
-- whatever its status, so a dry run can judge a draft.
--
-- ⚠️ A STAGE THAT DOES NOT MATCH IS NOT A ROW, NOT A REASON: a pregnancy
-- campaign's dry run counts the people in pregnancy, not everyone.
create or replace function public.pv_push_check(p_on date, p_campaign text default null)
returns table (campaign_id text, user_id uuid, reason text, priority int, ends_on date)
language sql
stable
security definer set search_path = ''
as $$
  with k as (
    select 1  as weekly_cap,          -- row 22: ONE a week at launch. The one constant.
           7  as grace_days,          -- row 17
           14 as birth_quiet_days     -- row 18
  ),
  camp as (
    select c.*
      from public.push_campaigns c
     where (p_campaign is null and c.status = 'approved')
        or c.id = p_campaign
  ),
  people as (
    select p.id, p.partner_id, p.due_date, p.pregnancy_ended_at, p.life_stage_at,
           -- No stage is an older sign-up, read as pregnant: the rule the
           -- app's messages and WhatsApp (0111) follow.
           coalesce(p.life_stage, 'pregnancy') as stage
      from public.profiles p
  )
  select
    c.id,
    pp.id,
    case
      when c.status = 'cancelled' or p_on < c.starts_on or p_on > c.ends_on
        then 'not_live'
      when not exists (
             select 1 from public.push_consent pc
              where pc.user_id = pp.id and pc.stage = pp.stage and pc.granted)
        then 'no_consent'
      when not exists (
             select 1 from public.push_devices d
              where d.user_id = pp.id
                and d.link_version >= public.pv_push_link_needs(c.link_kind))
        then 'no_device'
      when public.pv_push_holdout(pp.id)
        then 'holdout'
      when u.created_at is null
        or (u.created_at at time zone 'Asia/Kolkata')::date > p_on - k.grace_days
        then 'new_user'
      when pp.pregnancy_ended_at is not null
       and not (pp.life_stage_at is not null
                and pp.pregnancy_ended_at < pp.life_stage_at)
        then 'pregnancy_loss'
      -- A missing row is NOT quiet: a phone that never uploaded has had no
      -- loss recorded on it either (decision 8).
      when coalesce(a.quiet, false)
        then 'phone_quiet'
      when exists (
             select 1 from public.children ch
              where (ch.user_id = pp.id or ch.user_id = pp.partner_id)
                and ch.removed_at is null
                and ch.dob is not null
                and ch.dob >  p_on - k.birth_quiet_days
                and ch.dob <= p_on)
        then 'new_baby'
      -- The week is read from the stored due date exactly as WhatsApp reads
      -- it. When a clinic dated her, that stored date already is theirs; we
      -- never recompute it.
      when pp.stage = 'pregnancy'
       and (c.week_from is not null or c.week_to is not null)
       and (pp.due_date is null
            or public.wa_pregnancy_week(pp.due_date, p_on)
               not between coalesce(c.week_from, 0) and coalesce(c.week_to, 42))
        then 'not_targeted'
      when pp.stage = 'parenting'
       and (c.child_months_from is not null or c.child_months_to is not null)
       and not exists (
             select 1 from public.children ch
              cross join lateral (
                select (extract(year from age(p_on, ch.dob)) * 12
                        + extract(month from age(p_on, ch.dob)))::int as months
              ) m
              where (ch.user_id = pp.id or ch.user_id = pp.partner_id)
                and ch.removed_at is null
                and ch.dob is not null
                and ch.dob <= p_on
                and m.months between coalesce(c.child_months_from, 0)
                                 and coalesce(c.child_months_to, 72))
        then 'not_targeted'
      when exists (
             select 1 from public.push_sends s
              where s.campaign_id = c.id and s.user_id = pp.id)
        then 'already_reached'
      when p_on = any (coalesce(a.busy_evenings, '{}'))
        then 'busy_evening'
      when exists (
             select 1 from public.push_sends s
              where s.user_id = pp.id and s.send_on = p_on and s.status <> 'skipped')
        then 'booked_tonight'
      -- Seven rolling days, not the calendar week: a Sunday and the Monday
      -- after would be "one a week" twice in two days.
      when (select count(*) from public.push_sends s
             where s.user_id = pp.id
               and s.send_on between p_on - 6 and p_on
               and s.status in ('queued', 'sent')) >= k.weekly_cap
        then 'weekly_cap'
      else null
    end,
    c.priority,
    c.ends_on
  from camp c
  join people pp on pp.stage = any (c.stages)
  cross join k
  left join auth.users u on u.id = pp.id
  left join public.push_audience a on a.user_id = pp.id;
$$;

-- 5) pv_push_enqueue: book tonight -------------------------------------

-- Returns how many bookings it made. Every rule is pv_push_check's; this only
-- picks one campaign per person (row 19) and writes the row.
create or replace function public.pv_push_enqueue(p_on date default null)
returns int
language plpgsql
security definer set search_path = ''
as $$
declare
  v_day  date := coalesce(p_on, (now() at time zone 'Asia/Kolkata')::date);
  -- Row 20: the latest the sender may still send this evening.
  cutoff timestamptz := (v_day + time '21:00') at time zone 'Asia/Kolkata';
  n      int;
begin
  -- Run by hand after 21:00: nothing it booked could go out. Book nothing.
  if cutoff <= now() then
    return 0;
  end if;

  insert into public.push_sends (campaign_id, user_id, send_on, send_before, status)
  select x.campaign_id, x.user_id, v_day, cutoff, 'queued'
    from (
      select c.campaign_id, c.user_id,
             row_number() over (
               partition by c.user_id
               order by c.priority desc, c.ends_on asc, c.campaign_id
             ) as rn
        from public.pv_push_check(v_day) c
       where c.reason is null
    ) x
   where x.rn = 1
  -- Both unique keys: a second run, or a race, books nothing twice.
  on conflict do nothing;

  get diagnostics n = row_count;
  return n;
end;
$$;

-- 6) The admin functions (SQL editor now, Directus later) --------------

-- Creates a draft, or rewrites one that is still a draft. The table checks
-- refuse bad text, links, stages and dates, with their constraint name.
create or replace function public.pv_campaign_create(
  p_id                text,
  p_kind              text,
  p_title             text,
  p_body              text,
  p_link_kind         text,
  p_link_id           text,
  p_stages            text[],
  p_starts_on         date,
  p_ends_on           date,
  p_priority          int default 0,
  p_week_from         int default null,
  p_week_to           int default null,
  p_child_months_from int default null,
  p_child_months_to   int default null
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  n int;
begin
  insert into public.push_campaigns
    (id, kind, title, body, link_kind, link_id, stages, starts_on, ends_on,
     priority, week_from, week_to, child_months_from, child_months_to)
  values
    (p_id, p_kind, btrim(p_title), btrim(p_body), p_link_kind, btrim(p_link_id),
     p_stages, p_starts_on, p_ends_on, coalesce(p_priority, 0),
     p_week_from, p_week_to, p_child_months_from, p_child_months_to)
  on conflict (id) do update
    set kind              = excluded.kind,
        title             = excluded.title,
        body              = excluded.body,
        link_kind         = excluded.link_kind,
        link_id           = excluded.link_id,
        stages            = excluded.stages,
        starts_on         = excluded.starts_on,
        ends_on           = excluded.ends_on,
        priority          = excluded.priority,
        week_from         = excluded.week_from,
        week_to           = excluded.week_to,
        child_months_from = excluded.child_months_from,
        child_months_to   = excluded.child_months_to
    where public.push_campaigns.status = 'draft';
  get diagnostics n = row_count;
  if n = 0 then
    raise exception 'pv_campaign_create: % is already approved or cancelled; use a new id', p_id;
  end if;
  return p_id;
end;
$$;

-- How many people would get it on p_on (default today), and why the rest
-- would not: the first failing rule per person, plus "another_campaign_wins"
-- for people a higher-ranked approved campaign takes tonight.
create or replace function public.pv_campaign_dry_run(p_id text, p_on date default null)
returns table (outcome text, people bigint)
language plpgsql
stable
security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  v_day date := coalesce(p_on, (now() at time zone 'Asia/Kolkata')::date);
begin
  if not exists (select 1 from public.push_campaigns c where c.id = p_id) then
    raise exception 'pv_campaign_dry_run: no campaign %', p_id;
  end if;
  return query
    with mine as (
      select * from public.pv_push_check(v_day, p_id)
    ),
    rivals as (
      select * from public.pv_push_check(v_day) r
       where r.reason is null and r.campaign_id <> p_id
    ),
    judged as (
      select case
               when m.reason is not null then m.reason
               when exists (
                      select 1 from rivals r
                       where r.user_id = m.user_id
                         and (-r.priority, r.ends_on, r.campaign_id)
                           < (-m.priority, m.ends_on, m.campaign_id))
                 then 'another_campaign_wins'
               else 'would_send'
             end as o
        from mine m
    )
    select j.o, count(*)::bigint
      from judged j
     group by j.o
     order by count(*) desc, j.o;
end;
$$;

create or replace function public.pv_campaign_approve(p_id text)
returns void
language plpgsql
security definer set search_path = ''
as $$
begin
  update public.push_campaigns
     set status = 'approved', approved_at = now()
   where id = p_id
     and status = 'draft'
     and ends_on >= (now() at time zone 'Asia/Kolkata')::date;
  if not found then
    raise exception 'pv_campaign_approve: % does not exist, is not a draft, or has already ended', p_id;
  end if;
end;
$$;

-- Stops it. Its queued bookings become skipped (the evening is freed for
-- the next run), and nothing already sent changes. Returns how many bookings
-- were stopped.
create or replace function public.pv_campaign_cancel(p_id text)
returns int
language plpgsql
security definer set search_path = ''
as $$
declare
  n int;
begin
  update public.push_campaigns
     set status = 'cancelled', cancelled_at = now()
   where id = p_id and status <> 'cancelled';
  if not found then
    raise exception 'pv_campaign_cancel: % does not exist or is already cancelled', p_id;
  end if;
  update public.push_sends
     set status = 'skipped', error = 'cancelled'
   where campaign_id = p_id and status = 'queued';
  get diagnostics n = row_count;
  return n;
end;
$$;

-- ⚠️ NONE OF THESE IS FOR THE APP. A function is executable by PUBLIC by
-- default, and Supabase also grants new functions to anon and authenticated.
-- pv_push_check reads everyone's consent and audience, so a phone that could
-- call it could list who said yes. The SQL editor runs as the owner, and the
-- cron as postgres, so neither needs a grant.
revoke all on function public.pv_push_holdout(uuid) from public, anon, authenticated;
revoke all on function public.pv_push_link_needs(text) from public, anon, authenticated;
revoke all on function public.pv_push_check(date, text) from public, anon, authenticated;
revoke all on function public.pv_push_enqueue(date) from public, anon, authenticated;
revoke all on function public.pv_campaign_create(text, text, text, text, text, text, text[], date, date, int, int, int, int, int) from public, anon, authenticated;
revoke all on function public.pv_campaign_dry_run(text, date) from public, anon, authenticated;
revoke all on function public.pv_campaign_approve(text) from public, anon, authenticated;
revoke all on function public.pv_campaign_cancel(text) from public, anon, authenticated;
grant execute on function public.pv_push_holdout(uuid) to service_role;
grant execute on function public.pv_push_link_needs(text) to service_role;
grant execute on function public.pv_push_check(date, text) to service_role;
grant execute on function public.pv_push_enqueue(date) to service_role;
grant execute on function public.pv_campaign_create(text, text, text, text, text, text, text[], date, date, int, int, int, int, int) to service_role;
grant execute on function public.pv_campaign_dry_run(text, date) to service_role;
grant execute on function public.pv_campaign_approve(text) to service_role;
grant execute on function public.pv_campaign_cancel(text) to service_role;

-- 7) The 10:00 IST cron ------------------------------------------------

-- 04:30 UTC = 10:00 IST. Nine hours before the 19:00 send: time for a phone
-- that opens today to learn of its booking (B5) and give the evening away.
-- A named job, so re-running this file updates it instead of adding a second.
create extension if not exists pg_cron;
select cron.schedule(
  'push-enqueue-daily',
  '30 4 * * *',
  $$ select public.pv_push_enqueue(); $$
);

-- =====================================================================
-- USEFUL COMMANDS (SQL editor)
-- =====================================================================
--   select public.pv_campaign_create('garbh-class-nov', 'offer',
--     'Garbh Sanskar, live this Sunday', 'A calm hour with Dr Mehta. Tap to see the class.',
--     'course', 'garbh-sanskar-live', array['pregnancy'], '2026-11-01', '2026-11-15');
--   select * from public.pv_campaign_dry_run('garbh-class-nov');
--   select public.pv_campaign_approve('garbh-class-nov');
--   select public.pv_push_enqueue();            -- book tonight now
--   select public.pv_campaign_cancel('garbh-class-nov');
--   select jobname, schedule, active from cron.job where jobname = 'push-enqueue-daily';
-- Verify: supabase/seed/verify_push_campaigns.sql
-- =====================================================================
