-- =============================================================================
--  0098 — her results, her visits and the daily ritual stop coming back after
--  she removes them: a merge clock and soft deletes (2026-10-17)
-- -----------------------------------------------------------------------------
--  The same fix 0097 made on the cycle tables, now on the next three. All
--  three pulled with a union and removed with a one-shot hard delete, so a
--  removal made offline, or racing an upload, or undone by the other phone
--  that still held the row, came back on the next sync (STILL-OPEN-BACKEND §1).
--
--   · updated_at is the MERGE CLOCK: the time of the edit, written by the
--     phone. The newer copy wins, in both directions;
--   · removed_at is a SOFT DELETE: a removal is a row, so it reaches every
--     phone and an older upload cannot undo it.
--
--  ⚠️ NO TRIGGER SETS updated_at, ON PURPOSE, for the reason 0097 gives: a
--  trigger stamps the UPLOAD time, so an offline Monday edit uploaded on
--  Wednesday would beat an online Tuesday one. See BACKEND-PATTERNS §16ii.
--
--  All three tables are COUPLE-SCOPED (0041, 0042): either partner may write
--  a row. The app now keeps each row's owner when it uploads, rather than
--  stamping its own user_id on the partner's rows, and the ritual's shared
--  part ("Today's conversation") is decided by the newest row across both
--  partners, so neither phone ever writes the other's tick.
--
--  Additive and safe to re-run. Existing rows get updated_at = now(), so on
--  the first sync after this the cloud copy wins over a phone's older copy.
--  RLS and grants are unchanged: 0041 and 0042 already grant update.
-- =============================================================================

-- ---- ttc_records ---------------------------------------------------------------
alter table public.ttc_records
  add column if not exists updated_at timestamptz not null default now();
alter table public.ttc_records
  add column if not exists removed_at timestamptz;   -- null = a result she kept

-- ---- ttc_appointments ----------------------------------------------------------
alter table public.ttc_appointments
  add column if not exists updated_at timestamptz not null default now();
alter table public.ttc_appointments
  add column if not exists removed_at timestamptz;   -- null = a visit still on

-- ---- ttc_ritual ----------------------------------------------------------------
alter table public.ttc_ritual
  add column if not exists updated_at timestamptz not null default now();
alter table public.ttc_ritual
  add column if not exists removed_at timestamptz;   -- null = a part ticked

-- Reload PostgREST's schema cache so the app can write the new columns at once.
notify pgrst, 'reload schema';
