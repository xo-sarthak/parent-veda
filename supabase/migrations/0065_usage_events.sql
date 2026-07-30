-- =====================================================================
-- 0065_usage_events.sql -- measuring engagement without building a
--                          surveillance product.
-- ---------------------------------------------------------------------
-- WHY THIS EXISTS AT ALL, since the answer changed during the design.
--
-- The first instinct was: do not build it. An employer wants "average
-- time our people spend in the app", and answering that means recording
-- that a named person spent twelve minutes in a pregnancy app. Once
-- those rows exist, somebody will eventually be asked for them.
--
-- That was too strong, and the correction matters. There is no technical
-- reason a per-user measurement cannot be exposed only as an aggregate
-- -- sponsor_dashboard() has done exactly that for consultations since
-- 0060, and the rows behind it have never left the database. Refusing to
-- measure was refusing to answer a question ParentVeda needs for itself:
-- you cannot improve a product you cannot see being used.
--
-- So it is built, and it is built FOR PARENTVEDA, with the sponsor view
-- as one downstream consumer. That order is the whole design:
--
--   * Shaped around HR's questions, it would answer them and nothing
--     else -- and the day you want to know why people drop off at week
--     12, you would start over.
--   * Shaped around the product, HR's question is a query on top.
--
-- HOW IT DIFFERS FROM profile_events (0028), WHICH HAS NO user_id
--
-- 0028 answers "do the profiling strips work" -- a question about
-- SCREENS, which needs no identity, so it deliberately carries none.
--
-- This answers "is this person coming back", which is a question about
-- PEOPLE. Without an identity, twelve sessions could be twelve people
-- or one person twelve times, and those are opposite findings. It also
-- has to join to sponsor_members to answer anything per company, and
-- that table is keyed on user_id.
--
-- So the identity is necessary rather than convenient -- which is the
-- only acceptable reason to record one. Four constraints hold the line:
--
--   1. INSERT ONLY. No select grant and no select policy, exactly like
--      0028. A client cannot read this back, ever. If a select policy
--      appears here, the log becomes downloadable -- this is the one
--      line to get right.
--   2. NO CONTENT, ONLY SHAPE. `surface` is a screen name from a fixed
--      vocabulary. There is no free text, no query string, no article
--      id, no answer text. "She opened Ask Veda" is recorded; what she
--      asked is not, and cannot be, because there is no column for it.
--   3. NEVER GRANTED TO THE CMS. Not a form, not a report, not an
--      export. Ops has no reason to see it and Directus is not where a
--      behavioural log should be browsable.
--   4. IT EXPIRES. prune_usage_events() below. A log with no retention
--      limit is a liability that grows on its own.
--
-- ⚠️ WHAT THE APP MUST NOT SEND. Anything identifying CONTENT. A
-- surface name says which room someone walked into; a document id says
-- what they read. The first is a product metric, the second is a
-- medical record. See UsageEvents in lib/services/usage_events.dart --
-- the vocabulary is a const list there for this reason.
--
-- PREREQ: 0001 (profiles/auth), 0058 (sponsor_members), 0060
--         (my_sponsor_admin_id, sponsor_analytics_config).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The log.
-- ---------------------------------------------------------------------
create table if not exists public.usage_events (
  id          bigserial   primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  -- Random per launch. Lets sessions be counted and timed without
  -- reconstructing a person's day from timestamps.
  session_id  text        not null,
  -- session_start | session_end | screen_view. A short, closed
  -- vocabulary on purpose: an open one becomes a place to put anything.
  event       text        not null,
  -- WHICH ROOM, NEVER WHAT WAS IN IT. 'ask_veda', 'weekly', 'journal' --
  -- a screen name. Never an article id, a question, or a search term.
  surface     text,
  -- pregnancy | parenting | ttc. Cheap, and it is the first cut every
  -- product question needs.
  stage       text,
  -- Filled on session_end only. Clamped on the way in (see the CHECK):
  -- a client clock that has jumped must not produce a nine-hour session
  -- and drag an average with it.
  duration_ms int,
  at          timestamptz not null,
  created_at  timestamptz not null default now(),
  constraint usage_events_duration_sane
    check (duration_ms is null or (duration_ms >= 0 and duration_ms <= 14400000))
);

comment on table public.usage_events is
  'Engagement shape, insert-only. Which screens, how often, how long -- never what was read, asked or searched. Built for ParentVeda product questions; the sponsor aggregation is a downstream consumer that can only read totals.';

create index if not exists usage_events_user_at_idx
  on public.usage_events (user_id, at desc);
create index if not exists usage_events_session_idx
  on public.usage_events (session_id);
create index if not exists usage_events_at_idx
  on public.usage_events (at desc);


-- ---------------------------------------------------------------------
-- 2. Privileges: write, never read.
--
-- INSERT is granted and SELECT is not, so a read is refused at the
-- privilege layer before RLS is even consulted. The insert policy still
-- pins user_id to the caller, because a grant says WHICH TABLE and a
-- policy says WHICH ROWS -- without the policy, an authenticated client
-- could log events against somebody else's id.
-- ---------------------------------------------------------------------
alter table public.usage_events enable row level security;

grant insert on public.usage_events to authenticated;
grant usage, select on sequence public.usage_events_id_seq to authenticated;

drop policy if exists "usage_events own insert" on public.usage_events;
create policy "usage_events own insert" on public.usage_events
  for insert to authenticated with check (auth.uid() = user_id);

-- No select, update or delete policy. Deliberate, and load-bearing.

-- Not anon: unlike the profiling strips, there is no pre-auth case here
-- -- an event with no user is not answering any question this table
-- exists for, and 0028 already covers anonymous UX measurement.
revoke all on public.usage_events from anon;

-- NEVER the CMS. Not a form, not a report, not an export.


-- ---------------------------------------------------------------------
-- 3. Retention.
--
-- A behavioural log that keeps everything forever is a liability that
-- grows without anyone deciding it should. 400 days by default: long
-- enough for a year-on-year comparison plus a month of slack, short
-- enough that the oldest row is never a surprise.
--
-- Not scheduled here. pg_cron is already used for the WhatsApp outbox
-- (0018), so wiring it is one line -- but a delete job that starts
-- running the moment a migration lands is how a backfill disappears
-- overnight. Turn it on deliberately.
-- ---------------------------------------------------------------------
create or replace function public.prune_usage_events(p_keep_days int default 400)
returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare v_n int;
begin
  delete from public.usage_events
   where at < now() - (greatest(coalesce(p_keep_days, 400), 30) || ' days')::interval;
  get diagnostics v_n = row_count;
  return jsonb_build_object('ok', true, 'deleted', v_n);
end;
$$;

revoke execute on function public.prune_usage_events(int) from public;

comment on function public.prune_usage_events(int) is
  'Deletes usage_events older than p_keep_days (min 30). Run it on a schedule once you mean to: select cron.schedule(''prune-usage'', ''17 3 * * *'', $$select public.prune_usage_events(400)$$);';


-- ---------------------------------------------------------------------
-- 4. What a sponsor may see: totals, and only where they are anonymous.
--
-- The question HR asks is "are our people actually using this". The
-- answer is three numbers, and none of them is a row.
--
-- SUPPRESSION IS ON THE MONTH'S COHORT, not the programme's. A company
-- with 40 activated people passes any whole-programme test, but a month
-- in which 3 of them opened the app is still 3 identifiable people --
-- and "average session 22 minutes" across 3 people, in an office where
-- one person is visibly pregnant, is a sentence about her.
--
-- Note there is no per-surface breakdown. "Your people spent most of
-- their time in the Health section" sounds harmless and is not: in a
-- small team it narrows down who is worried about what. The product
-- gets that question answered from the raw table as service_role; the
-- employer does not get it at all.
-- ---------------------------------------------------------------------
create or replace function public.sponsor_engagement(p_months int default 6)
returns table (
  month             date,
  active_people     int,    -- distinct people who opened the app
  sessions          int,
  avg_session_min   numeric
)
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_id  text := public.my_sponsor_admin_id();
  v_min int;
  v_n   int := least(greatest(coalesce(p_months, 6), 1), 24);
begin
  if v_id is null then
    return;
  end if;

  select min_cohort into v_min from public.sponsor_analytics_config
   where id = 'default';
  v_min := coalesce(v_min, 5);

  return query
  with months as (
    select generate_series(
             date_trunc('month', now()) - ((v_n - 1) || ' months')::interval,
             date_trunc('month', now()),
             '1 month'::interval
           )::date as m
  ),
  ev as (
    select date_trunc('month', u.at)::date        as m,
           count(distinct u.user_id)              as people,
           count(distinct u.session_id) filter (where u.event = 'session_start') as sess,
           avg(u.duration_ms) filter (where u.event = 'session_end')             as avg_ms
      from public.usage_events u
      join public.sponsor_members sm
        on sm.user_id = u.user_id
       and sm.sponsor_id = v_id
       and sm.status = 'active'
     group by 1
  )
  select
    months.m,
    -- The headcount of a cohort is itself behavioural here -- "2 people
    -- opened the app in July" is not a contract fact the way "2 people
    -- activated" is -- so it is suppressed along with everything else.
    case when coalesce(ev.people, 0) < v_min then null
         else ev.people::int end,
    case when coalesce(ev.people, 0) < v_min then null
         else coalesce(ev.sess, 0)::int end,
    case when coalesce(ev.people, 0) < v_min then null
         else round((ev.avg_ms / 60000.0)::numeric, 1) end
  from months
  left join ev on ev.m = months.m
  order by months.m;
end;
$$;

grant execute on function public.sponsor_engagement(int) to authenticated;


-- =====================================================================
-- WHAT PARENTVEDA CAN ASK, as service_role in the SQL editor. These are
-- the reason the table exists; the sponsor view is the by-product.
--
--   -- Weekly active people, all users:
--   select date_trunc('week', at)::date w, count(distinct user_id)
--     from public.usage_events group by 1 order by 1 desc limit 12;
--
--   -- Median session length (avg is dragged by the long tail):
--   select percentile_cont(0.5) within group (order by duration_ms) / 60000.0
--     from public.usage_events where event = 'session_end';
--
--   -- Which surfaces get opened, by stage -- the feature-adoption
--   -- question the employer never gets to ask:
--   select stage, surface, count(*) from public.usage_events
--    where event = 'screen_view' group by 1, 2 order by 3 desc limit 30;
--
--   -- Retention: of people first seen in a month, how many returned 30+
--   -- days later. The number that actually says whether this works.
--   with first as (select user_id, min(at) f from public.usage_events group by 1)
--   select date_trunc('month', f)::date cohort,
--          count(*) as joined,
--          count(*) filter (where exists (
--            select 1 from public.usage_events u
--             where u.user_id = first.user_id and u.at > first.f + interval '30 days'
--          )) as returned_after_30d
--     from first group by 1 order by 1;
--
-- VERIFY
--
--   -- A client cannot read it back. As an app session:
--   select * from public.usage_events;      -> permission denied
--
--   -- And cannot log against somebody else:
--   insert into public.usage_events (user_id, session_id, event, at)
--   values ('00000000-0000-0000-0000-000000000000', 's', 'session_start', now());
--     -> new row violates row-level security policy
--
--   -- Suppression holds on a small month:
--   select * from public.sponsor_engagement(3);
-- =====================================================================
