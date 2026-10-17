-- =============================================================================
--  0100 — the server keeps "newer wins" too, and refuses a clock from the
--  future (2026-10-17, sync log step 4)
-- -----------------------------------------------------------------------------
--  Every synced row table merges "newer wins" on updated_at, the time of the
--  edit written by the phone (0081, 0092, 0097, 0098, 0099). Until now only
--  the PHONE applied that rule, on a pull. Two gaps followed:
--
--   1. AN OLDER WRITE COULD OVERWRITE A NEWER ROW. Phone A edits offline at
--      10:00; phone B edits the same row at 10:05 and uploads. A reconnects
--      and uploads its 10:00 copy before it next pulls: the upsert replaces
--      B's newer row. B repairs it on its next sync, but until B opens, the
--      cloud holds the older version, and a third phone would take it.
--   2. A PHONE WITH A WRONG CLOCK WON FOREVER. A phone set to next year
--      stamps next year on every edit, and "newer wins" then lets it beat
--      every real edit until that date.
--
--  The fix is one trigger function on every such table, run BEFORE the row
--  is written:
--
--   · a stamp more than 5 minutes ahead of the server's clock is pulled back
--     to the server's now() (clamped, not refused: a refused row would sit
--     on that phone waiting forever, and her change would never land);
--   · on an UPDATE, a row whose stamp is OLDER than the one already stored is
--     SKIPPED. A BEFORE trigger that returns NULL makes Postgres skip that
--     row quietly: no error, so the phone counts the upload as confirmed,
--     and its next pull takes the newer row. That is exactly "newer wins",
--     now decided in one place for every phone.
--
--  ⚠️ EQUAL STAMPS ARE ALLOWED THROUGH. An app version from before the clock
--  existed sends no updated_at, so its update keeps the stored stamp (NEW
--  equals OLD), and refusing that would stop old installs syncing at all.
--
--  ⚠️ NO TRIGGER SETS updated_at TO now() ON EVERY WRITE, still on purpose
--  (see 0097): that would stamp the upload time, not the edit time. Only a
--  stamp from the future is touched.
--
--  Safe to re-run: `create or replace` and `drop trigger if exists`.
--  A self-contained check that runs in a transaction and leaves nothing
--  behind is at the bottom, commented out; see docs/BACKEND-SYNC-LOG.md
--  step 4.
-- =============================================================================

create or replace function public.pv_sync_newer_wins()
returns trigger
language plpgsql
as $$
begin
  -- A clock from the future: pull it back to the server's.
  if new.updated_at > now() + interval '5 minutes' then
    new.updated_at := now();
  end if;

  -- An older copy never replaces a newer one. NULL = skip this row.
  if tg_op = 'UPDATE' and new.updated_at < old.updated_at then
    return null;
  end if;

  return new;
end;
$$;

-- One trigger per table whose updated_at is the phone's edit time.
-- ⚠️ A NEW SYNCED TABLE BELONGS IN THIS LIST: `test/sync_guard_contract_test.dart`
-- fails if a table the app writes with updated_at + removed_at has no trigger.
do $$
declare
  t text;
begin
  foreach t in array array[
    'ttc_cycles',
    'ttc_cycle_signals',
    'ttc_logs',
    'ttc_doctor_questions',
    'ttc_records',
    'ttc_appointments',
    'ttc_ritual',
    'ttc_supplements',
    'ttc_supplement_taken',
    'journey_timeline',
    'saved_items',
    'journal_entries',
    'father_journal_entries'
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

-- -----------------------------------------------------------------------------
--  CHECK IT (optional): paste this block alone into the SQL editor. It makes
--  a throwaway table, tries an older write and a future clock, prints the
--  results, and rolls everything back.
-- -----------------------------------------------------------------------------
-- begin;
--   create temp table pv_guard_check (id text primary key, v text,
--     updated_at timestamptz not null);
--   create trigger pv_guard_check_newer_wins before insert or update
--     on pv_guard_check for each row execute function public.pv_sync_newer_wins();
--   insert into pv_guard_check values ('a', 'newer', now());
--   -- an older copy arrives: must be skipped
--   insert into pv_guard_check values ('a', 'OLDER', now() - interval '1 hour')
--     on conflict (id) do update set v = excluded.v, updated_at = excluded.updated_at;
--   -- a phone a year ahead: must be clamped to about now
--   insert into pv_guard_check values ('b', 'future', now() + interval '1 year');
--   select id, v, updated_at <= now() + interval '5 minutes' as clock_ok
--     from pv_guard_check order by id;
--   -- expect:  a | newer  | true      b | future | true
-- rollback;
