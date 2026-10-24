-- =============================================================================
--  0113 — rows keyed per person: primary key (user_id, id)
--  (sync log step 14, STAGE-TRANSITIONS B9, 2026-10-24)
-- -----------------------------------------------------------------------------
--  THE BUG. A primary key is unique across the WHOLE table, not per user.
--  The phone makes its own row ids (so a local row and its cloud copy share
--  one identity), and some ids are built from a date or a fixed name:
--  `ttcc_2026-10-24`, `pregnancy_started`, `sl_2026-10-24_nausea`,
--  `symptoms_evening`. The first account to upload such an id owns that row
--  for ever. Every other account's `upsert ... on conflict (id)` lands on the
--  conflict path, RLS refuses to update someone else's row, the write fails,
--  and the phone keeps the row waiting and retries for ever. Cloud writes are
--  fire-and-forget, so nothing shows: the second woman to log a period on any
--  given day silently never gets it into the cloud.
--
--  WHY THE KEY CHANGES AND NOT THE IDS. The date-built ids are deliberate: the
--  same period logged on her phone and on her tablet must be ONE row, and a
--  fixed `pregnancy_started` keeps one entry per event. The ids are meant to be
--  unique within one person, so the key now says exactly that. 0110 did the
--  same for `memories` and `garbh_journal_entries` from the start.
--
--  WHICH TABLES (17). Collide today, ids from a date or a name:
--    ttc_cycles, ttc_cycle_signals, journey_timeline, symptom_logs,
--    journal_entries, reminders, weight_entries, movement_sessions.
--  The rest of the tables the phone syncs through OwnRowLedger, whose ids are
--  timestamps today. They change too because the ledger's conflict target is
--  ONE rule (`user_id,<key>`), and a flag per table is what the next table
--  forgets:
--    bump_photos, calendar_personal_events, baby_talk, medications,
--    medication_logs, weekly_journal_notes, appointments, contraction_sessions.
--  And father_journal_entries, which shares the journal's upsert.
--
--  LEFT ALONE, on purpose:
--    * ttc_records, ttc_appointments, ttc_doctor_questions, ttc_supplements:
--      random ids, read by the couple; ttc_supplements also has a foreign key
--      in from ttc_supplement_taken.
--    * children and the child-scoped pp_* tables: random ids, shared by both
--      parents through my_child_ids(), which reads `children.id` alone.
--    * orders, bookings, can_i_misses (uid in the id) and uuid-default tables.
--
--  SAFE ON EXISTING DATA. Ids are unique today, so (user_id, id) is too.
--  Nothing is rewritten. The new key's index leads with user_id, so it also
--  serves every store's `where user_id = ...` read. Unchanged: RLS, the
--  0100 newer-wins trigger (it compares updated_at only), the 0109/0110 purge
--  (it deletes by removed_at time), the extra unique keys on cycles and
--  signals. No foreign key points at any of these 17 tables.
--
--  THE ROLLOUT, NAMED. An app build that still sends `on conflict (id)` fails
--  against these tables once this runs (no unique key on `id` alone is left).
--  Its rows stay waiting on the phone, so nothing is lost; they upload once
--  the new build is installed. Pre-launch the only old builds are the team's,
--  so: run this, then install the next build. After launch the same change
--  would take two releases (add the new key alongside, ship, then drop the old).
--
--  CHECK AFTERWARDS (expect 17 rows, each `user_id,id`):
--    select c.conrelid::regclass as tbl,
--           string_agg(a.attname, ',' order by k.ord) as pk
--    from pg_constraint c
--    cross join lateral unnest(c.conkey) with ordinality as k(attnum, ord)
--    join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum
--    where c.contype = 'p'
--      and c.conrelid::regclass::text in (
--        'ttc_cycles','ttc_cycle_signals','journey_timeline','symptom_logs',
--        'journal_entries','reminders','weight_entries','movement_sessions',
--        'bump_photos','calendar_personal_events','baby_talk','medications',
--        'medication_logs','weekly_journal_notes','appointments',
--        'contraction_sessions','father_journal_entries')
--    group by c.conrelid order by 1;
-- =============================================================================

do $$
declare
  t    text;
  pk   text;
begin
  foreach t in array array[
    'ttc_cycles',
    'ttc_cycle_signals',
    'journey_timeline',
    'symptom_logs',
    'journal_entries',
    'reminders',
    'weight_entries',
    'movement_sessions',
    'bump_photos',
    'calendar_personal_events',
    'baby_talk',
    'medications',
    'medication_logs',
    'weekly_journal_notes',
    'appointments',
    'contraction_sessions',
    'father_journal_entries'
  ] loop
    -- The constraint's real name, not a guessed `<t>_pkey`.
    select conname into pk
    from pg_constraint
    where conrelid = ('public.' || t)::regclass and contype = 'p';

    execute format(
      'alter table public.%I drop constraint %I, add primary key (user_id, id)',
      t, pk);
  end loop;
end $$;
