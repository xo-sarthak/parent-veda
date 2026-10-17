-- =============================================================================
--  0097 — her cycle survives a phone switch: a merge clock, soft deletes and
--  bleeding days on the cycle tables (2026-10-17)
-- -----------------------------------------------------------------------------
--  The device walk found an ovulation test she had cleared come back after a
--  reinstall, and an audit of the cycle sync found why, and more:
--
--   · ttc_cycles had no bleeding days, so every period came back on a new
--     phone without its length;
--   · the pull was a union and the push re-sent every row, so a phone that
--     still held an old value pushed it back over an edit or a delete made on
--     another phone;
--   · deletes were hard deletes, so one that did not land (offline, a race
--     with an upload in flight) was undone by the next sync.
--
--  The fix is the shape 0092 (ttc_doctor_questions) and 0081 (saved_items)
--  already use, now on the cycle tables:
--
--   · updated_at is the MERGE CLOCK: the time she made the change, written by
--     the phone. The newer copy wins, in both directions;
--   · removed_at is a SOFT DELETE: a removal is a row, so it reaches every
--     phone and cannot be undone by an older upload;
--   · bleed_days rides on the cycle row (-1 = "still on", null = not said).
--
--  ⚠️ NO TRIGGER SETS updated_at, ON PURPOSE. A server trigger would stamp
--  the UPLOAD time, so a change made offline on Monday and uploaded on
--  Wednesday would beat a change made online on Tuesday. The phone writes the
--  time of the edit. The cost is trusting device clocks, which are right to
--  the second on every phone that syncs time with the network.
--  See docs/BACKEND-PATTERNS.md, section 16ii.
--
--  Additive and safe to re-run: every change is `add column if not exists`
--  or a guarded constraint. Existing rows get updated_at = now(), so on the
--  first sync after this, the cloud copy wins over a phone's older copy.
--
--  Runs after 0041 (the TTC tables). RLS and grants are unchanged: 0041
--  already lets the owner select, insert, update and delete her own rows.
-- =============================================================================

-- ---- ttc_cycles --------------------------------------------------------------
alter table public.ttc_cycles
  add column if not exists updated_at timestamptz not null default now();
alter table public.ttc_cycles
  add column if not exists removed_at timestamptz;   -- null = a period she logged
alter table public.ttc_cycles
  add column if not exists bleed_days int;            -- -1 = still on; null = not said

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'ttc_cycles_bleed_days_check'
  ) then
    alter table public.ttc_cycles
      add constraint ttc_cycles_bleed_days_check
      check (bleed_days is null or bleed_days between -1 and 15);
  end if;
end $$;

-- ---- ttc_cycle_signals ---------------------------------------------------------
alter table public.ttc_cycle_signals
  add column if not exists updated_at timestamptz not null default now();
alter table public.ttc_cycle_signals
  add column if not exists removed_at timestamptz;   -- null = a test she kept

-- ---- ttc_logs ----------------------------------------------------------------
-- updated_at already exists (0041); until now the phone stamped it at upload
-- time. From this release it is the time of the edit.
alter table public.ttc_logs
  add column if not exists removed_at timestamptz;   -- null = a value she logged

-- Reload PostgREST's schema cache so the app can write the new columns at once.
notify pgrst, 'reload schema';
