-- =====================================================================
-- 0028_profile_events.sql -- the profile-analytics sink (write-only)
-- ---------------------------------------------------------------------
-- Raw behavioural events from the progressive-profiling strips on BOTH
-- sides of the app (pregnancy + parenting): a strip was shown, a strip
-- was answered, a completeness snapshot. Deliberately dumb - raw rows,
-- no aggregation. Rates are DERIVED later by the queries at the bottom,
-- never computed on the client. Spec: docs/PERSONALIZATION.md section 10.
--
-- NO user_id, ON PURPOSE. install_id is a random, anonymous, pre-auth id
-- that persists per install; session_id is random per launch. When real
-- accounts land, install_id can be joined to a user server-side without
-- the client ever having sent an identity it did not need to.
--
-- THE SHAPE THAT MATTERS: INSERT-ONLY, NEVER READABLE.
--   * INSERT  - allowed for the app whether logged OUT (anon) or in
--               (authenticated), because the strips run pre-auth.
--   * SELECT  - nobody. No select policy exists, so with RLS on every
--               read is denied at the row layer. This table is queried
--               only from the Supabase dashboard (service_role bypasses
--               RLS), never read back into the app.
-- If a select policy ever appears here, a client could pull the whole
-- behavioural log. It must not. This is the one line to get exactly
-- right - see the RLS block below.
--
-- PREREQ: none (no user_id, no functions). Standalone.
-- =====================================================================


create table public.profile_events (
  id           bigserial   primary key,
  install_id   text        not null,   -- random, anonymous, persists per install
  session_id   text        not null,   -- random, new each launch
  event        text        not null,   -- stripShown | stripAnswered | completenessSnapshot | ...
  field        text,                   -- pregHealth | diet | parity | ...
  value        text,                   -- the option chosen; enum labels only (no free text)
  surface      text,                   -- symptom_companion | tools_hub | ...
  percent      int,                    -- completeness snapshots only
  at           timestamptz not null,   -- client UTC instant of the event
  created_at   timestamptz not null default now()
);

create index profile_events_install_at_idx   on public.profile_events (install_id, at);
create index profile_events_event_surface_idx on public.profile_events (event, surface);


-- ---------------------------------------------------------------------
-- Privileges: INSERT ONLY, for both app roles. No select/update/delete
-- grant is issued, so those verbs are refused at the privilege layer
-- before RLS is even consulted.
--
-- The sequence grant is not optional: `id bigserial` fills itself by
-- calling nextval() on its sequence, and without USAGE on that sequence
-- the insert fails with "permission denied for sequence
-- profile_events_id_seq". Easy to forget, since the table grant looks
-- complete on its own.
-- ---------------------------------------------------------------------
grant insert on public.profile_events to anon, authenticated;
grant usage  on sequence public.profile_events_id_seq to anon, authenticated;

alter table public.profile_events enable row level security;


-- ---------------------------------------------------------------------
-- RLS -- the one policy, and the deliberate absence of the others.
--
-- INSERT is open: there is no user_id to tie a row to, so `with check
-- (true)` simply lets any app session write an event. The worst a bad
-- actor can do is insert junk analytics - a nuisance, not a leak.
--
-- There is intentionally NO select/update/delete policy. With RLS
-- enabled, a table with no policy for a verb DENIES that verb entirely.
-- So nobody using the anon or authenticated key can ever read, change or
-- remove a row. Reads happen only from the dashboard under service_role,
-- which bypasses RLS by design.
--
-- IMPORTANT client-side pairing: the app inserts with `return=minimal`
-- (it never chains .select()), so the insert does not try to read the
-- new row back. If a client DID select the row back, PostgREST would
-- need SELECT and the call would fail - which is a feature here, not a
-- bug: it means the write-only contract is enforced end to end.
-- ---------------------------------------------------------------------
create policy "profile_events insert only" on public.profile_events for insert
  to anon, authenticated
  with check (true);


-- ---------------------------------------------------------------------
-- The questions this table exists to answer (run from the dashboard).
-- ---------------------------------------------------------------------
-- Completion rate per surface, counted per MOTHER (install) not per view.
-- A big gap between two placements means the PLACEMENT is wrong.
--   select surface,
--          count(distinct install_id) filter (where event = 'stripAnswered')::float
--        / nullif(count(distinct install_id) filter (where event = 'stripShown'), 0)
--            as completion_rate
--   from public.profile_events
--   where field = 'pregHealth'
--   group by surface;
--
-- What mothers actually want help with (content-commissioning signal).
--   select value, count(distinct install_id) as mothers
--   from public.profile_events
--   where event = 'stripAnswered' and field = 'pregPriorities'
--   group by value order by mothers desc;
--
-- Are profiles filling up over time?
--   select date_trunc('week', at) as week, avg(percent)
--   from public.profile_events
--   where event = 'completenessSnapshot'
--   group by 1 order by 1;
