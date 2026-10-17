-- =============================================================================
--  0104 — the rest of the child's record: documents, health, milestones,
--  vaccines and the emergency card sync "newer wins" (2026-10-17, sync log
--  step 6)
-- -----------------------------------------------------------------------------
--  Step 5 (0101) fixed the six logs. The rest of Parenting still synced the
--  old way: a union pull that can never take anything away, a hard delete
--  fired once, and an upsert that wrote `user_id = me` over the other
--  parent's rows. Each also had its own bug:
--
--   · doctor questions were matched by TEXT, so removing one removed every
--     copy, and the same question asked twice became one;
--   · the emergency card took the cloud copy whenever there was one, so an
--     offline edit was lost, and Clear never reached the cloud at all;
--   · un-ticking a milestone came back on the next pull;
--   · the vaccine pull only ever ADDED doses, so un-ticking never reached
--     the other phone.
--
--  Decisions (the user, 2026-10-17): health rows and documents, latest edit
--  wins (whole row); the emergency card, latest save wins (whole card) and
--  Clear syncs; vaccine reminders are SHARED, so both parents' phones buzz.
--
--  This adds:
--   · updated_at (the edit time on the phone; no trigger stamps now(), see
--     0097) and removed_at (a soft delete) on the nine id-keyed and keyed
--     tables below;
--   · removed_at on pp_emergency_cards, which already has updated_at (0095);
--   · updated_at and reminder_at on pp_vaccine_doses. reminder_at is the
--     moment the alarm fires, so the other parent's phone arms the same one.
--     A dose row is state, not a list item: un-ticking sends done = false,
--     so it needs no removed_at;
--   · 0100's guard (skip an older update, clamp a future clock) on all 11.
--
--  RLS is unchanged. Insert stays "only as yourself", so the app sends the
--  other parent's rows as a plain UPDATE (0101's header explains why an
--  upsert would be refused). The emergency card's UPDATE policy also pins
--  user_id to the caller, so the card is always saved as the last editor.
--
--  Additive and safe to re-run.
-- =============================================================================

do $$
declare
  t text;
begin
  foreach t in array array[
    'pp_documents',
    'pp_medications',
    'pp_prescriptions',
    'pp_allergies',
    'pp_symptoms',
    'pp_reports',
    'pp_doctor_visits',
    'pp_doctor_questions',
    'pp_milestone_observations'
  ]
  loop
    execute format(
      'alter table public.%I add column if not exists updated_at timestamptz not null default now()', t);
    execute format(
      'alter table public.%I add column if not exists removed_at timestamptz', t);
  end loop;
end $$;

alter table public.pp_emergency_cards
  add column if not exists removed_at timestamptz;

alter table public.pp_vaccine_doses
  add column if not exists updated_at timestamptz not null default now();
alter table public.pp_vaccine_doses
  add column if not exists reminder_at timestamptz;

-- The server-side guard (0100's function). `test/sync_guard_contract_test.dart`
-- reads this list.
do $$
declare
  t text;
begin
  foreach t in array array[
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
    'pp_vaccine_doses'
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
--  CHECK IT (optional): 11 rows. Every row should say true for has_clock and
--  guarded; has_removed_at is true for all but pp_vaccine_doses, which has
--  reminder_at instead.
-- -----------------------------------------------------------------------------
-- select c.table_name,
--        bool_or(c.column_name = 'updated_at') as has_clock,
--        bool_or(c.column_name = 'removed_at') as has_removed_at,
--        bool_or(c.column_name = 'reminder_at') as has_reminder_at,
--        exists (select 1 from pg_trigger g
--                 where g.tgname = c.table_name || '_newer_wins') as guarded
--   from information_schema.columns c
--  where c.table_schema = 'public'
--    and c.table_name in ('pp_documents','pp_medications','pp_prescriptions',
--                         'pp_allergies','pp_symptoms','pp_reports',
--                         'pp_doctor_visits','pp_doctor_questions',
--                         'pp_milestone_observations','pp_emergency_cards',
--                         'pp_vaccine_doses')
--  group by c.table_name order by c.table_name;
