-- =====================================================================
-- 0125_mind_mood_entries.sql — her mood check-ins and worry journal
-- ---------------------------------------------------------------------
-- MindMoodStore (lib/data/mind_mood_data.dart), from the Mind door's
-- "Mood check-in" (Pregnancy tools pass, P5, 2026-10-28). Until now it
-- lived only on the phone, so a new phone lost every check-in and every
-- journal entry.
--
-- The user's decisions:
--   D2 "what if the person wants to change the device ... they just lose
--      access to the essential sensitive stuff that they wrote": it syncs.
--   D3 "its personal and private": OWNER-ONLY.
--
-- ⚠️ OWNER-ONLY EVEN INSIDE A SHARED FAMILY (BACKEND-PATTERNS §3(a)).
-- All four policies are auth.uid() = user_id. NOT widened to the partner,
-- unlike scans (0012_share_scans.sql), and no security-definer function
-- reaches across. This is the reverse of the baby-name votes (§7): there a
-- function combines two private rows into one shared answer; here nothing
-- ever does. The screen promises "No one reads this but you", and the
-- policies are what make that sentence true.
--
-- One table, two kinds:
--   kind 'mood'    one per day: id = 'mood_<date_key>', so two phones
--                  checking in on the same day write ONE row (newer wins);
--   kind 'journal' one per entry: id = the app's microsecond id.
--
-- Born with the sync clock (0097/0104): updated_at is the phone's edit
-- time, removed_at a soft delete that travels (Undo uploads like any other
-- change), 0100's guard skips an older write, and the purge (0109) takes it.
-- The key is (user_id, id), never id alone (0113, sync step 14): an id made
-- from a date is the same on two people's phones.
--
-- PREREQ: 0100 (pv_sync_newer_wins), 0109/0114/0115 (pv_purge_removed).
-- Additive and safe to re-run.
-- =====================================================================

create table if not exists public.mind_mood_entries (
  id              text        not null,
  user_id         uuid        not null references auth.users (id) on delete cascade,
  kind            text        not null check (kind in ('mood','journal')),

  -- mood: the day (yyyy-MM-dd) and the word she picked
  date_key        text,
  mood_id         text,
  -- journal: what she wrote, and the prompt she started from, if any
  body            text,
  prompt_id       text,

  created_at_iso  text        not null,
  updated_at      timestamptz not null default now(),
  removed_at      timestamptz,
  created_at      timestamptz not null default now(),
  primary key (user_id, id)
);

grant select, insert, update, delete on public.mind_mood_entries to authenticated;
alter table public.mind_mood_entries enable row level security;

drop policy if exists "mind_mood_entries own select" on public.mind_mood_entries;
drop policy if exists "mind_mood_entries own insert" on public.mind_mood_entries;
drop policy if exists "mind_mood_entries own update" on public.mind_mood_entries;
drop policy if exists "mind_mood_entries own delete" on public.mind_mood_entries;

create policy "mind_mood_entries own select" on public.mind_mood_entries for select
  using (auth.uid() = user_id);
create policy "mind_mood_entries own insert" on public.mind_mood_entries for insert
  with check (auth.uid() = user_id);
create policy "mind_mood_entries own update" on public.mind_mood_entries for update
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "mind_mood_entries own delete" on public.mind_mood_entries for delete
  using (auth.uid() = user_id);

-- The server-side guard (0100's function). `test/sync_guard_contract_test.dart`
-- reads this list.
do $$
declare
  t text;
begin
  foreach t in array array[
    'mind_mood_entries'
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
-- The same function as 0115 with mind_mood_entries added at the end. The
-- cron job calls it by name, so nothing about the schedule changes.

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
    'pp_food_tries',
    -- 0125: her mood check-ins and worry journal
    'mind_mood_entries'
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
--  CHECK IT (optional): four policies, guarded true, pk user_id,id, and no
--  policy that mentions a partner or a family.
-- -----------------------------------------------------------------------------
-- select (select count(*) from pg_policies where tablename = 'mind_mood_entries') as policies,
--        (select bool_and(qual not ilike '%partner%' and qual not ilike '%family%')
--           from pg_policies where tablename = 'mind_mood_entries' and qual is not null) as own_only,
--        exists (select 1 from pg_trigger where tgname = 'mind_mood_entries_newer_wins') as guarded,
--        (select string_agg(a.attname, ',' order by k.ord)
--           from pg_index i
--           cross join lateral unnest(i.indkey) with ordinality as k(attnum, ord)
--           join pg_attribute a on a.attrelid = i.indrelid and a.attnum = k.attnum
--          where i.indrelid = 'public.mind_mood_entries'::regclass and i.indisprimary) as pk;
