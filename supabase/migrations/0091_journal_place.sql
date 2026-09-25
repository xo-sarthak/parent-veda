-- =============================================================================
--  0091 — a journal entry's place reaches the cloud (2026-09-23)
-- -----------------------------------------------------------------------------
--  The compose screen has stamped "Where was this?" on an entry since the
--  journal rework, and the app model carries it — but neither journal table
--  had a column for it, so a place lived only on the phone it was typed on,
--  and a sync that rebuilt the list from the cloud erased it there too.
--
--  EXPAND ONLY. A nullable column with no default: every existing row is
--  valid as it stands, and an app build that does not send `place` keeps
--  working. The app tolerates the other order as well — if it ships before
--  this runs, a write refused for the missing column is retried without it
--  (`journalUpsert`, lib/services/journal_sync.dart), so nothing else fails.
--
--  No policy change: the row-level policies already scope every column of a
--  row to its owner (and the father's rows to his paired partner for reading).
-- =============================================================================

alter table public.journal_entries
  add column if not exists place text;

alter table public.father_journal_entries
  add column if not exists place text;
