-- =============================================================================
--  0106 — Pregnancy part 1 syncs "newer wins": her calendar, bump photos, the
--  daily tables, weekly journal notes and reminders (2026-10-20, sync log
--  step 8)
-- -----------------------------------------------------------------------------
--  Every table here is OWN-ONLY: all policies are auth.uid() = user_id, and no
--  partner reads or writes them. So no merge decision was needed: the phone's
--  edit time wins, as for her cycle (0097, BACKEND-PATTERNS §16ii).
--
--  What was wrong (the old merges):
--   · calendar events, bump photos, baby talk, journal notes, reminders: the
--     cloud won per id, and any row only this phone held was inserted again.
--     A row deleted on another phone (or offline) came back;
--   · daily moods: a day cleared on another phone was pushed back up;
--   · kept affirmations and father missions: a UNION, which can never take
--     anything away;
--   · re-saving a day's baby talk hard-deleted and re-inserted it, under a
--     new id each time.
--
--  This adds:
--   · updated_at (the edit time on the phone; no trigger stamps now(), see
--     0097) where it is missing. daily_moods and daily_movement_responses
--     already have one (0004);
--   · removed_at (a soft delete) on every table except
--     daily_movement_responses: a movement answer is state ("yes" / "not
--     yet"), never removed, only changed (as pp_vaccine_doses, 0104);
--   · ⚠️ an own-row UPDATE policy on father_missions. 0010 gave it select,
--     insert and delete only. An upsert is checked against UPDATE even for a
--     brand-new row (the family timeline trap, 0099), so without this every
--     mission upload would be refused, silently;
--   · 0100's guard (skip an older update, clamp a future clock) on all nine.
--
--  RLS is otherwise unchanged. Additive and safe to re-run.
-- =============================================================================

do $$
declare
  t text;
begin
  foreach t in array array[
    'calendar_personal_events',
    'bump_photos',
    'baby_talk',
    'kept_affirmations',
    'father_missions',
    'weekly_journal_notes',
    'reminders',
    'daily_moods'
  ]
  loop
    execute format(
      'alter table public.%I add column if not exists updated_at timestamptz not null default now()', t);
    execute format(
      'alter table public.%I add column if not exists removed_at timestamptz', t);
  end loop;
end $$;

drop policy if exists "father_missions own update" on public.father_missions;
create policy "father_missions own update" on public.father_missions
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- The server-side guard (0100's function). `test/sync_guard_contract_test.dart`
-- reads this list.
do $$
declare
  t text;
begin
  foreach t in array array[
    'calendar_personal_events',
    'bump_photos',
    'baby_talk',
    'daily_moods',
    'kept_affirmations',
    'daily_movement_responses',
    'father_missions',
    'weekly_journal_notes',
    'reminders'
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
--  CHECK IT (optional): 9 rows. has_clock and guarded true on every row;
--  has_removed_at true on all but daily_movement_responses; and
--  father_missions has_update_policy true.
-- -----------------------------------------------------------------------------
-- select c.table_name,
--        bool_or(c.column_name = 'updated_at') as has_clock,
--        bool_or(c.column_name = 'removed_at') as has_removed_at,
--        exists (select 1 from pg_trigger g
--                 where g.tgname = c.table_name || '_newer_wins') as guarded,
--        exists (select 1 from pg_policies p
--                 where p.tablename = c.table_name and p.cmd = 'UPDATE')
--          as has_update_policy
--   from information_schema.columns c
--  where c.table_schema = 'public'
--    and c.table_name in ('calendar_personal_events','bump_photos','baby_talk',
--                         'daily_moods','kept_affirmations',
--                         'daily_movement_responses','father_missions',
--                         'weekly_journal_notes','reminders')
--  group by c.table_name order by c.table_name;
