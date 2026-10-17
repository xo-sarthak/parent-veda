-- =============================================================================
--  0099 — supplements and the family timeline: a merge clock, soft deletes,
--  and the timeline may finally sync (2026-10-17)
-- -----------------------------------------------------------------------------
--  Step 2 of STILL-OPEN-BACKEND §1, the same shape as 0097 and 0098:
--
--   · updated_at is the MERGE CLOCK, written by the phone at the time of the
--     edit (no trigger, on purpose: see 0097 and BACKEND-PATTERNS §16ii);
--   · removed_at is a SOFT DELETE, so a removal reaches every phone and an
--     older copy cannot bring it back.
--
--  ---------------------------------------------------------------------------
--  THE TIMELINE GAINS AN OWN-ROW UPDATE, and why (the user, 2026-10-17)
--
--  0041 made journey_timeline append-only, with no UPDATE grant, so that
--  "a life story you can silently rewrite is not a record". Two things
--  followed that nobody saw:
--
--   1. IT COULD NOT SYNC AT ALL. The app uploads with an upsert, which is
--      INSERT ... ON CONFLICT DO UPDATE. Postgres checks every privilege the
--      statement MIGHT need before it runs, so an upsert needs UPDATE even
--      for a brand-new row. Every timeline upload was refused, and the app
--      swallows upload errors, so it was refused silently.
--   2. A soft delete IS an update (it sets removed_at), so without UPDATE a
--      removal can only be a hard delete, which an offline phone or the
--      other phone's copy undoes.
--
--  So UPDATE is granted, and the policy allows it on YOUR OWN rows only: the
--  partner still reads the couple's story and still cannot change a moment
--  that is not theirs. "Never rewrite what she wrote" remains a rule in the
--  app (FamilyTimeline has no edit; only the app's own milestones have their
--  date corrected). The trade-off: that rule now lives in code, not in the
--  database.
--
--  ---------------------------------------------------------------------------
--  Supplements: ttc_supplement_taken's rows cascaded from a hard delete of
--  their supplement. A soft delete does not cascade, so the app now marks
--  the ticks of a removed supplement removed itself.
--
--  Additive and safe to re-run. Existing rows get updated_at = now(), so the
--  cloud copy wins over a phone's older copy on the first sync after this.
-- =============================================================================

-- ---- ttc_supplements -----------------------------------------------------------
alter table public.ttc_supplements
  add column if not exists updated_at timestamptz not null default now();
alter table public.ttc_supplements
  add column if not exists removed_at timestamptz;   -- null = still on the list

-- ---- ttc_supplement_taken ------------------------------------------------------
alter table public.ttc_supplement_taken
  add column if not exists updated_at timestamptz not null default now();
alter table public.ttc_supplement_taken
  add column if not exists removed_at timestamptz;   -- null = a dose ticked

-- ---- journey_timeline ----------------------------------------------------------
alter table public.journey_timeline
  add column if not exists updated_at timestamptz not null default now();
alter table public.journey_timeline
  add column if not exists removed_at timestamptz;   -- null = a moment kept

-- Update: your own moments only. Never the partner's.
drop policy if exists journey_timeline_update on public.journey_timeline;
create policy journey_timeline_update on public.journey_timeline
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

grant update on public.journey_timeline to authenticated;

-- Reload PostgREST's schema cache so the app can write the new columns at once.
notify pgrst, 'reload schema';
