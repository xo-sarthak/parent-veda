-- =============================================================================
--  0110 — merge where the data is serialized; two records get tables
--  (sync log step 13, 2026-10-22)
-- -----------------------------------------------------------------------------
--  PART 1: pv_state_merge, a per-item merge for `user_state`.
--
--  Since 0011 the light stores (hospital bag, saved readings, answers, ...)
--  keep one JSON blob each in `user_state`, and a sync replaced the whole
--  blob. Two phones that each ticked a different item both uploaded their
--  whole blob, and the second erased the first's tick (STILL-OPEN-BACKEND §2).
--
--  The new shape: the blob is a map of ITEMS, each `{v, t, d}`:
--    v  the item's value (any JSON)
--    t  when it was last edited, phone time in epoch milliseconds
--    d  true when the item was removed (a tombstone, so the removal travels)
--  Two copies merge item by item and the newer `t` wins. That is a
--  last-writer-wins map, one of the simplest CRDTs: any two copies merged in
--  any order end up the same.
--
--  WHY THE MERGE RUNS HERE AND NOT ON THE PHONE. A phone that reads the blob,
--  merges, and writes it back races another phone doing the same: both read
--  the old blob, both write, and the second write drops the first's new
--  items. This function locks the row (`for update`), merges and writes in
--  one transaction, so two phones are serialized and neither is lost. The
--  general rule: merge where the writes are already put in order. The other
--  answer, compare-and-swap from the phone (write only if the version is
--  still the one I read), also works but costs a retry loop on every clash.
--
--  The phone sends only the items it changed and gets the whole merged map
--  back, so one call is both the push and the pull.
--
--  SECURITY INVOKER: it runs as the caller, so 0011's own-row policies still
--  decide what it may touch. It can only ever reach the caller's own rows.
--
--  Rules, the same as the row tables:
--    * a `t` more than 5 minutes in the future is pulled back to now
--      (0100's guard);
--    * a tie keeps the server's copy;
--    * tombstones older than 90 days are dropped (0109's window; the phones
--      drop theirs at 80).
--  The Dart mirror is `MergedItems.merge` in
--  lib/services/remote/cloud_merged_store.dart, held to the same cases by
--  test/cloud_merged_store_test.dart.
--
--  PART 2: two records move off the phone into tables.
--  Memories and Garbh journal entries were kept only on the phone, so a
--  sign-out or a new phone lost them for good. Each is a growing list of
--  things she made one at a time, with a file attached (a photo, a
--  recording), so each gets rows (soft delete, newer wins, OwnRowLedger), not
--  items in a blob. Small lists that never grow far (BMI readings, answers)
--  stay items in the merged blob above: the same per-item guarantees without
--  a table each.
--
--  The record itself rides in `data jsonb`. The trade, named: Postgres cannot
--  check or index the fields inside, and a column added later is a change in
--  the app, not the schema. What it buys: these records are only ever read
--  back whole by their owner, their shapes still move, and one table shape
--  serves both. A record the server needs to query belongs in columns.
--
--  The key is `(user_id, key)`, not a global id: the phone makes the ids, and
--  two people's phones could make the same one.
--
--  PART 3: profiles.pregnancy_ended_at. "If your pregnancy has ended" was
--  kept only on the phone, so a new phone went back to showing a growing
--  baby. It now lives on her profile. 0009 lets a linked partner read her
--  profile, so his app can respect it too.
-- =============================================================================

-- ---- Part 1: the merge -------------------------------------------------------

create or replace function public.pv_state_merge(p_key text, p_items jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  uid     uuid   := auth.uid();
  now_ms  bigint := (extract(epoch from now()) * 1000)::bigint;
  keep_ms bigint := now_ms - 90::bigint * 86400000;
  cur     jsonb;
  k       text;
  v       jsonb;
  vt      bigint;
begin
  if uid is null then
    raise exception 'pv_state_merge: not signed in';
  end if;
  if p_key is null or p_key = '' then
    raise exception 'pv_state_merge: no store key';
  end if;
  if p_items is null then
    p_items := '{}'::jsonb;
  end if;
  if jsonb_typeof(p_items) <> 'object' then
    raise exception 'pv_state_merge: items must be an object';
  end if;

  insert into public.user_state (user_id, store_key, data)
  values (uid, p_key, '{}'::jsonb)
  on conflict (user_id, store_key) do nothing;

  select data into cur
    from public.user_state
   where user_id = uid and store_key = p_key
     for update;
  if cur is null or jsonb_typeof(cur) <> 'object' then
    cur := '{}'::jsonb;
  end if;

  for k, v in select * from jsonb_each(p_items) loop
    if jsonb_typeof(v) <> 'object' then
      continue;
    end if;
    vt := coalesce((v->>'t')::numeric, 0)::bigint;
    -- A clock from the future: pull it back to the server's.
    if vt > now_ms + 300000 then
      vt := now_ms;
      v := jsonb_set(v, '{t}', to_jsonb(vt));
    end if;
    -- Newer wins; a tie keeps the server's copy.
    if not (cur ? k) or vt > coalesce((cur->k->>'t')::numeric, 0)::bigint then
      cur := cur || jsonb_build_object(k, v);
    end if;
  end loop;

  -- Tombstones past the window go.
  select coalesce(jsonb_object_agg(e.key, e.value), '{}'::jsonb)
    into cur
    from jsonb_each(cur) as e
   where not (coalesce((e.value->>'d')::boolean, false)
              and coalesce((e.value->>'t')::numeric, 0)::bigint < keep_ms);

  update public.user_state
     set data = cur, updated_at = now()
   where user_id = uid and store_key = p_key;

  return cur;
end;
$$;

revoke execute on function public.pv_state_merge(text, jsonb) from public, anon;
grant execute on function public.pv_state_merge(text, jsonb) to authenticated;

-- ---- Part 2: the record tables -------------------------------------------------

create table if not exists public.memories (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  key        text        not null,
  data       jsonb       not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  removed_at timestamptz,
  primary key (user_id, key)
);

create table if not exists public.garbh_journal_entries (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  key        text        not null,
  data       jsonb       not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  removed_at timestamptz,
  primary key (user_id, key)
);

-- Own rows only, and the newer-wins guard (0100) on each.
do $$
declare
  t text;
begin
  foreach t in array array[
    'memories',
    'garbh_journal_entries'
  ]
  loop
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists %I on public.%I', t || ' own select', t);
    execute format('create policy %I on public.%I for select using (auth.uid() = user_id)',
                   t || ' own select', t);
    execute format('drop policy if exists %I on public.%I', t || ' own insert', t);
    execute format('create policy %I on public.%I for insert with check (auth.uid() = user_id)',
                   t || ' own insert', t);
    execute format('drop policy if exists %I on public.%I', t || ' own update', t);
    execute format('create policy %I on public.%I for update using (auth.uid() = user_id) '
                   'with check (auth.uid() = user_id)', t || ' own update', t);
    execute format('drop policy if exists %I on public.%I', t || ' own delete', t);
    execute format('create policy %I on public.%I for delete using (auth.uid() = user_id)',
                   t || ' own delete', t);
    execute format('drop trigger if exists %I on public.%I',
                   t || '_newer_wins', t);
    execute format(
      'create trigger %I before insert or update on public.%I '
      'for each row execute function public.pv_sync_newer_wins()',
      t || '_newer_wins', t);
  end loop;
end $$;

-- ---- Part 3: pregnancy ended -------------------------------------------------

alter table public.profiles
  add column if not exists pregnancy_ended_at timestamptz;

-- ---- The purge (0109) takes the three new tables -------------------------------
-- The same function as 0109 with the new tables added at the end. The cron
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
    'garbh_journal_entries'
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

-- =============================================================================
--  CHECKS (optional). Every line in this block that is not SQL stays a
--  comment when you uncomment the SQL, so it can be pasted and run as is.
-- =============================================================================
-- -- 1. The merge exists and only signed-in users may call it:
-- select proname, prosecdef from pg_proc where proname = 'pv_state_merge';
--
-- -- 2. The two tables, each with its guard trigger (expect 2 rows):
-- select event_object_table, trigger_name from information_schema.triggers
--  where trigger_name in ('memories_newer_wins', 'garbh_journal_entries_newer_wins');
--
-- -- 3. The new column:
-- select column_name from information_schema.columns
--  where table_name = 'profiles' and column_name = 'pregnancy_ended_at';
