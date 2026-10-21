-- =============================================================================
--  0109 — purge soft-deleted rows after 90 days (sync log step 12, 2026-10-21)
-- -----------------------------------------------------------------------------
--  Steps 1–9 made every delete SOFT: the row stays, with `removed_at` set, so
--  the removal can travel to her other phone and an older copy there cannot
--  bring the row back (BACKEND-PATTERNS §16ii). That mark has to live long
--  enough for every phone to see it. It does not have to live forever, and
--  until now nothing ever removed one: 0081 wrote `saved_items_prune()` but
--  it was never scheduled.
--
--  THE WINDOW IS A PROMISE. Cassandra calls the same setting
--  `gc_grace_seconds`: a replica that is away for longer than the window
--  comes back with a live copy of something everyone else has forgotten was
--  deleted, and resurrects it. Here a "replica" is a phone. A phone offline
--  for more than 90 days that still holds a row deleted elsewhere will upload
--  it again. That is the trade: 90 days covers any realistic gap, and the
--  cost of the rare miss is a deleted item coming back, never data lost.
--
--  The phones drop their own record of a removal after 80 days (step 12,
--  `SyncRowBook.dropSettled`). Shorter on purpose: a phone that still held
--  the removal after the server had purged the row would upload it back and
--  undo the purge.
--
--  NEVER `children`. A removed child must stay restorable, and
--  `my_child_ids()` reads removed children too (0105): purging one would
--  strand every record of that child where neither parent can read it.
--  `sponsor_*` tables are not sync tables and are not touched either.
--
--  One foreign key reaches a purged row: `ttc_supplement_taken.supplement_id`
--  references `ttc_supplements` with ON DELETE CASCADE (0041), so purging a
--  supplement she removed 90 days ago takes its ticked doses with it. That is
--  right: they belong to a supplement that no longer exists. No other purged
--  table is referenced by another table (checked 2026-10-21).
--
--  The list is explicit, not "every table with a removed_at column": a purge
--  that discovers its own targets would one day reach a table nobody meant
--  it to. `test/purge_removed_contract_test.dart` checks the list against the
--  migrations, so a new soft-delete table is never silently left out.
-- =============================================================================

create or replace function public.pv_purge_removed(p_days int default 90)
returns table (table_name text, purged bigint)
language plpgsql
security definer
set search_path = public
as $$
declare
  t text;
  n bigint;
begin
  if p_days < 30 then
    raise exception 'pv_purge_removed: keep at least 30 days (got %)', p_days;
  end if;
  foreach t in array array[
    -- 0081, 0092
    'saved_items',
    'ttc_doctor_questions',
    -- 0097–0099: TTC
    'ttc_cycles',
    'ttc_cycle_signals',
    'ttc_logs',
    'ttc_records',
    'ttc_appointments',
    'ttc_ritual',
    'ttc_supplements',
    'ttc_supplement_taken',
    'journey_timeline',
    -- 0101, 0104: Parenting (never `children`, see above)
    'pp_feed_logs',
    'pp_sleep_logs',
    'pp_nappy_logs',
    'pp_pump_logs',
    'pp_tummy_logs',
    'pp_growth_measurements',
    'pp_documents',
    'pp_medications',
    'pp_prescriptions',
    'pp_allergies',
    'pp_symptoms',
    'pp_reports',
    'pp_doctor_visits',
    'pp_doctor_questions',
    'pp_milestone_observations',
    'pp_emergency_cards',
    -- 0106, 0107: Pregnancy
    'calendar_personal_events',
    'bump_photos',
    'baby_talk',
    'kept_affirmations',
    'father_missions',
    'weekly_journal_notes',
    'reminders',
    'daily_moods',
    'medications',
    'medication_logs',
    'completed_scans',
    'appointments',
    'symptom_logs',
    'weight_entries',
    'movement_sessions',
    'contraction_sessions'
  ]
  loop
    execute format(
      'delete from public.%I where removed_at is not null '
      'and removed_at < now() - make_interval(days => $1)', t)
      using p_days;
    get diagnostics n = row_count;
    table_name := t;
    purged := n;
    return next;
  end loop;
end;
$$;

-- Only the scheduler (it runs as the database owner) calls it. No app user.
revoke execute on function public.pv_purge_removed(int) from public, anon, authenticated;

-- 0081's 30-day prune for saved_items stays, unscheduled: saved items now
-- share the 90 days above, because the phone keeps its removal for 80 and a
-- 30-day server window would be shorter than that (the hazard described in
-- the header).

-- pg_cron is on since 0018. A named job: running this again updates it.
-- 04:15 UTC, 09:45 IST, after 0018's 03:30 run.
select cron.schedule(
  'pv-purge-removed',
  '15 4 * * *',
  $$ select public.pv_purge_removed(90); $$
);

-- =============================================================================
--  CHECKS (optional). Every line in this block that is not SQL stays a
--  comment when you uncomment the SQL, so it can be pasted and run as is.
-- =============================================================================
-- -- 1. The job is scheduled (one row, active = true):
-- select jobname, schedule, command, active from cron.job
--  where jobname = 'pv-purge-removed';
--
-- -- 2. What the first run will remove, per table (a dry run, deletes nothing):
-- select 'saved_items' as t, count(*) from public.saved_items
--  where removed_at < now() - interval '90 days'
-- union all select 'ttc_logs', count(*) from public.ttc_logs
--  where removed_at < now() - interval '90 days'
-- union all select 'pp_feed_logs', count(*) from public.pp_feed_logs
--  where removed_at < now() - interval '90 days';
--
-- -- 3. After its first run (tomorrow), the history:
-- select status, return_message, start_time from cron.job_run_details
--  where jobid = (select jobid from cron.job where jobname = 'pv-purge-removed')
--  order by start_time desc limit 5;
