-- =====================================================================
-- 0024_pp_feed_sleep.sql — feed + sleep logs (the time-series pair)
-- ---------------------------------------------------------------------
-- FeedingStore (pp_feeding_data.dart) and SleepStore (pp_sleep_data.dart)
-- — the "Feeding journey" and "Sleep journey" tools. CHILD-SCOPED +
-- CO-PARENTED: the 2am feed one parent logs is the same row the other
-- sees and can correct. That sharing is the whole point here — night
-- feeds are usually split between two people.
--
-- These are the highest-write tables in the parenting app (several rows
-- a day, for years), hence real tables with proper indexes rather than
-- a re-serialized JSON blob.
--
-- NOT INCLUDED: PpTrackerStore (pp_trackers_data.dart), which models
-- feeds and sleeps a SECOND time for the retired FeedingTrackerScreen /
-- SleepTrackerScreen. Those screens were replaced by the Journey tools
-- and nothing links to them any more (verified — only their own
-- "kept for revert" header comments reference them). Giving them tables
-- would mint two divergent histories for one real-world event.
-- BACKEND-PARENTING-BRIEF §1 lists PpTrackerStore as Tier 1; that entry
-- is stale for this reason.
--
-- PREREQ: 0021_children.sql. Run AFTER 0021.
-- =====================================================================


-- ---------------------------------------------------------------------
-- feed logs — one row per feed. `kind` decides which optional columns
-- are meaningful (breast → side/duration, bottle → milk/amount,
-- solid → food/take), which is why they're all nullable rather than
-- split into three tables: it is one timeline to the parent.
-- ---------------------------------------------------------------------
create table public.pp_feed_logs (
  id           text        primary key,
  child_id     text        not null,
  user_id      uuid        not null references auth.users (id) on delete cascade,

  time         timestamptz not null,
  kind         text        not null default 'breast'
                             check (kind in ('breast','bottle','solid')),

  -- breast
  side         text        check (side in ('left','right','both')),
  duration_min int,

  -- bottle
  milk         text        check (milk in ('formula','expressed','other')),
  amount_ml    int,

  -- solid
  food         text,
  take         text        check (take in ('ate','tasted','refused')),

  note         text,
  created_at   timestamptz not null default now()
);

-- Reads are always "this child's feeds, newest first" (and day buckets).
create index pp_feed_logs_child_time_idx
  on public.pp_feed_logs (child_id, time desc);


-- ---------------------------------------------------------------------
-- sleep logs — one row per stretch of sleep.
-- ---------------------------------------------------------------------
create table public.pp_sleep_logs (
  id         text        primary key,
  child_id   text        not null,
  user_id    uuid        not null references auth.users (id) on delete cascade,

  start_at   timestamptz not null,
  end_at     timestamptz not null,
  kind       text        not null default 'nap'
                           check (kind in ('night','nap','contact','car','stroller')),
  note       text,

  created_at timestamptz not null default now()
);

create index pp_sleep_logs_child_start_idx
  on public.pp_sleep_logs (child_id, start_at desc);


-- ---------------------------------------------------------------------
-- Privileges + RLS
-- ---------------------------------------------------------------------
grant select, insert, update, delete on public.pp_feed_logs  to authenticated;
grant select, insert, update, delete on public.pp_sleep_logs to authenticated;

alter table public.pp_feed_logs  enable row level security;
alter table public.pp_sleep_logs enable row level security;

-- feed logs
create policy "pp_feed_logs child select" on public.pp_feed_logs for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_feed_logs child insert" on public.pp_feed_logs for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_feed_logs child update" on public.pp_feed_logs for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_feed_logs child delete" on public.pp_feed_logs for delete
  using (child_id in (select public.my_child_ids()));

-- sleep logs
create policy "pp_sleep_logs child select" on public.pp_sleep_logs for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_sleep_logs child insert" on public.pp_sleep_logs for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_sleep_logs child update" on public.pp_sleep_logs for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_sleep_logs child delete" on public.pp_sleep_logs for delete
  using (child_id in (select public.my_child_ids()));
