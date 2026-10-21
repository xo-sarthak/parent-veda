-- =============================================================================
--  0107 — Pregnancy part 2 syncs "newer wins": medicines and their logs,
--  scans and appointments, symptoms, and the tools (weight, movement, kegel,
--  contractions) (2026-10-21, sync log step 9)
-- -----------------------------------------------------------------------------
--  Every WRITE here is own-only: insert, update and delete are all
--  auth.uid() = user_id, and every table already has its own UPDATE policy
--  (0003, 0005, 0006), so an upsert is never refused. completed_scans and
--  appointments are partner-READABLE (0012), but the partner never writes
--  them, so her rows still sync by her phone's edit time (0097, BACKEND-
--  PATTERNS §16ii) and the partner's copy stays a separate, read-only fetch.
--
--  What was wrong (the old merges):
--   · every table: the cloud won per id, and any row only this phone held was
--     inserted again. A row deleted on another phone (or offline) came back;
--   · medications: alarms were never sent, so every pull wiped them and her
--     medicine reminders stopped;
--   · symptom logs: a severity change deleted the row and inserted a new one
--     under a new id;
--   · weight profile and kegel routine: the cloud overwrote an offline change.
--
--  This adds:
--   · updated_at (the edit time on the phone; no trigger stamps now(), see
--     0097) where it is missing. weight_profile and kegel_state already have
--     one (0003);
--   · removed_at (a soft delete) on the eight list tables. Not on
--     weight_profile or kegel_state: one row per person, state that is
--     changed, never removed;
--   · medications.alarms (jsonb): the alarm settings are a fact that syncs,
--     and each phone rebuilds its own OS alarms from it (§16ii-g). Null means
--     an old row written before this column: the phone keeps its own alarms;
--   · symptom_logs.severity accepts 'strong' (the Symptoms door's word);
--   · 0100's guard (skip an older update, clamp a future clock) on all ten.
--
--  RLS is unchanged. Additive and safe to re-run.
-- =============================================================================

do $$
declare
  t text;
begin
  foreach t in array array[
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
      'alter table public.%I add column if not exists updated_at timestamptz not null default now()', t);
    execute format(
      'alter table public.%I add column if not exists removed_at timestamptz', t);
  end loop;
end $$;

alter table public.medications add column if not exists alarms jsonb;

-- ⚠️ The Symptoms door (2026-09-22) writes severity 'strong'; 0005 allows
-- only mild / moderate / severe, so every "Strong" log has been refused by
-- the server, silently (fire-and-forget). With confirmed uploads it would
-- wait forever and keep the sign-out sheet warning. Allow both: the old
-- companion still writes 'severe'.
alter table public.symptom_logs
  drop constraint if exists symptom_logs_severity_check;
alter table public.symptom_logs
  add constraint symptom_logs_severity_check
  check (severity in ('mild','moderate','severe','strong'));

-- The server-side guard (0100's function). `test/sync_guard_contract_test.dart`
-- reads this list.
do $$
declare
  t text;
begin
  foreach t in array array[
    'medications',
    'medication_logs',
    'completed_scans',
    'appointments',
    'symptom_logs',
    'weight_profile',
    'weight_entries',
    'movement_sessions',
    'kegel_state',
    'contraction_sessions'
  ]
  loop
    execute format('drop trigger if exists %I on public.%I',
                   t || '_newer_wins', t);
    execute format(
      'create trigger %I before insert or update on public.%I '
      'for each row execute function public.pv_sync_newer_wins()',
      t || '_newer_wins', t);
  end loop;
end $$;

notify pgrst, 'reload schema';

-- -----------------------------------------------------------------------------
--  CHECK IT (optional): 10 rows. has_clock and guarded true on every row;
--  has_removed_at true on all but weight_profile and kegel_state; has_alarms
--  true for medications only.
-- -----------------------------------------------------------------------------
-- select c.table_name,
--        bool_or(c.column_name = 'updated_at') as has_clock,
--        bool_or(c.column_name = 'removed_at') as has_removed_at,
--        bool_or(c.column_name = 'alarms') as has_alarms,
--        exists (select 1 from pg_trigger g
--                 where g.tgname = c.table_name || '_newer_wins') as guarded
--   from information_schema.columns c
--  where c.table_schema = 'public'
--    and c.table_name in ('medications','medication_logs','completed_scans',
--                         'appointments','symptom_logs','weight_profile',
--                         'weight_entries','movement_sessions','kegel_state',
--                         'contraction_sessions')
--  group by c.table_name order by c.table_name;
--
--  And the severity check, which should list 'strong':
-- select pg_get_constraintdef(oid) from pg_constraint
--  where conname = 'symptom_logs_severity_check';
