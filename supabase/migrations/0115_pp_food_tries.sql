-- =====================================================================
-- 0115_pp_food_tries.sql — the foods a child has tried
-- ---------------------------------------------------------------------
-- PpFoodTriesStore (pp_food_tries_store.dart), from "Can my baby eat
-- this?" (tools pass, Food family 22-24, 2026-10-25). CHILD-SCOPED +
-- CO-PARENTED, like milestones (0025): if Papa gave the first egg at lunch,
-- Maa should not give it again at dinner thinking it was new, and either
-- may note a reaction.
--
-- The user's decision (D1): "Yes, and partner sees it". The other option
-- was an item in the person's own user_state (no migration), which a
-- co-parent cannot read. Who needs to see a record decides its table
-- (BACKEND-PATTERNS §16rr): a child's record that both parents act on is a
-- child table; a person's preference is a user_state item.
--
-- The food CATALOGUE stays bundled in the app as content. Only what a
-- parent OBSERVED is stored: one row per (child, food), so recording a
-- first try is an idempotent upsert and the key is the app's own slug.
--
-- Born with 0104's sync clock: updated_at is the phone's edit time,
-- removed_at a soft delete (Undo uploads like any other change), and
-- 0100's guard skips an older write. The purge (0109) takes it too.
--
-- PREREQ: 0021 (children, my_child_ids), 0100 (pv_sync_newer_wins),
-- 0109/0114 (pv_purge_removed). Additive and safe to re-run.
-- =====================================================================

create table if not exists public.pp_food_tries (
  child_id     text        not null,
  food_id      text        not null,
  user_id      uuid        not null references auth.users (id) on delete cascade,

  first_tried  timestamptz not null,
  -- none | mild | doctor. Free text, read leniently by the app: the app
  -- never draws a conclusion from it, it only lists it for the doctor.
  reaction     text,
  note         text,

  updated_at   timestamptz not null default now(),
  removed_at   timestamptz,
  created_at   timestamptz not null default now(),
  primary key (child_id, food_id)
);

grant select, insert, update, delete on public.pp_food_tries to authenticated;
alter table public.pp_food_tries enable row level security;

drop policy if exists "pp_food_tries child select" on public.pp_food_tries;
drop policy if exists "pp_food_tries child insert" on public.pp_food_tries;
drop policy if exists "pp_food_tries child update" on public.pp_food_tries;
drop policy if exists "pp_food_tries child delete" on public.pp_food_tries;

create policy "pp_food_tries child select" on public.pp_food_tries for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_food_tries child insert" on public.pp_food_tries for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_food_tries child update" on public.pp_food_tries for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_food_tries child delete" on public.pp_food_tries for delete
  using (child_id in (select public.my_child_ids()));

-- The server-side guard (0100's function). `test/sync_guard_contract_test.dart`
-- reads this list.
do $$
declare
  t text;
begin
  foreach t in array array[
    'pp_food_tries'
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

-- ---- The purge (0109) takes the new table --------------------------------------
-- The same function as 0114 with pp_food_tries added at the end. The cron
-- job calls it by name, so nothing about the schedule changes.

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
    'pregnancies',
    -- 0115: the foods a child has tried
    'pp_food_tries'
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
--  CHECK IT (optional): one row, guarded true, four policies, pk child_id,food_id.
-- -----------------------------------------------------------------------------
-- select (select count(*) from pg_policies where tablename = 'pp_food_tries') as policies,
--        exists (select 1 from pg_trigger where tgname = 'pp_food_tries_newer_wins') as guarded,
--        (select string_agg(a.attname, ',' order by k.ord)
--           from pg_index i
--           cross join lateral unnest(i.indkey) with ordinality as k(attnum, ord)
--           join pg_attribute a on a.attrelid = i.indrelid and a.attnum = k.attnum
--          where i.indrelid = 'public.pp_food_tries'::regclass and i.indisprimary) as pk;
