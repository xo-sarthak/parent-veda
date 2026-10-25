-- =============================================================================
--  0114 — One row per pregnancy (R1, 2026-10-25, sync log step 18)
-- -----------------------------------------------------------------------------
--  Until now a pregnancy was not a thing the database could name. It was
--  profiles.due_date + life_stage + profiles.pregnancy_ended_at: one slot per
--  person. So a pregnancy after a loss carried the lost one's bump photos,
--  scans and bag, and a second pregnancy overwrote the first's due date
--  (FAMILY-MODEL §3 named this table as owed).
--
--  A row here is one pregnancy: when it started, its due date and how that
--  date was set (DueDateSource), when and how it ended, the child it became,
--  and an ARCHIVE of the few records that cannot be told apart by date (the
--  hospital bag, the birth plan, scans ticked by catalogue id, moods keyed by
--  pregnancy day). Records that carry a date are NOT copied: a record belongs
--  to the pregnancy whose window [started_on, ended_on] holds its date, and
--  the app filters by that window when it reads (BACKEND-PATTERNS §16oo).
--
--  WHY NO pregnancy_id ON THE RECORD TABLES. It would be exact, but it is a
--  column and a backfill on some twenty shipped tables and a change to every
--  writer. Every pregnancy record already carries its date, so the window
--  answers "whose" with no change to them.
--
--  Keyed per person, (user_id, id), the B9 rule (0113): the phone makes the
--  id from the start date, so two people's ids can be the same.
--
--  Policies: her own rows in full, and a READ for her partner, so his phone
--  knows the windows (the same shape as journey_timeline, 0041). Guarded by
--  0100's newer-wins trigger, soft-deleted with removed_at, and on the 90-day
--  purge list. Additive and safe to re-run.
-- =============================================================================

create table if not exists public.pregnancies (
  user_id         uuid        not null references auth.users (id) on delete cascade,
  id              text        not null,
  started_on      date        not null,
  due_date        date,
  due_date_source text,
  ended_on        date,
  -- 'ongoing' | 'loss' | 'birth'
  outcome         text        not null default 'ongoing',
  child_id        text,
  archive         jsonb       not null default '{}'::jsonb,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  removed_at      timestamptz,
  primary key (user_id, id)
);

grant select, insert, update, delete on public.pregnancies to authenticated;
alter table public.pregnancies enable row level security;

drop policy if exists "pregnancies own or partner select" on public.pregnancies;
create policy "pregnancies own or partner select" on public.pregnancies
  for select using (auth.uid() = user_id or user_id = public.my_partner_id());

drop policy if exists "pregnancies own insert" on public.pregnancies;
create policy "pregnancies own insert" on public.pregnancies
  for insert with check (auth.uid() = user_id);

drop policy if exists "pregnancies own update" on public.pregnancies;
create policy "pregnancies own update" on public.pregnancies
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "pregnancies own delete" on public.pregnancies;
create policy "pregnancies own delete" on public.pregnancies
  for delete using (auth.uid() = user_id);

-- The server-side guard (0100). `test/sync_guard_contract_test.dart` reads it.
drop trigger if exists pregnancies_newer_wins on public.pregnancies;
create trigger pregnancies_newer_wins before insert or update on public.pregnancies
  for each row execute function public.pv_sync_newer_wins();

-- ---- The purge (0109, 0110) takes the new table ----------------------------
-- The same function as 0110 with `pregnancies` added at the end. The cron job
-- calls it by name, so nothing about the schedule changes.

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
    -- 0101, 0104: Parenting (never `children`, see 0109)
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
    'contraction_sessions',
    -- 0110: records that used to live only on the phone
    'memories',
    'garbh_journal_entries',
    -- 0114: one row per pregnancy
    'pregnancies'
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

revoke execute on function public.pv_purge_removed(int) from public, anon, authenticated;

notify pgrst, 'reload schema';

-- -----------------------------------------------------------------------------
--  CHECK IT (optional): one row, guarded true, five policies, pk user_id,id.
-- -----------------------------------------------------------------------------
-- select (select count(*) from pg_policies where tablename = 'pregnancies') as policies,
--        exists (select 1 from pg_trigger where tgname = 'pregnancies_newer_wins') as guarded,
--        (select string_agg(a.attname, ',' order by k.ord)
--           from pg_index i
--           cross join lateral unnest(i.indkey) with ordinality as k(attnum, ord)
--           join pg_attribute a on a.attrelid = i.indrelid and a.attnum = k.attnum
--          where i.indrelid = 'public.pregnancies'::regclass and i.indisprimary) as pk;
