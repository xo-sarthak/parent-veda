-- =====================================================================
-- 0116_pp_milestone_photo.sql — a photo on a milestone, and her own ones
-- ---------------------------------------------------------------------
-- R10 (STAGE-TRANSITIONS, 2026-10-26): Milestones become one place per
-- child, and saving one is a moment: a date, an optional photo, a line.
-- The user also chose that a parent may save a milestone of her own
-- ("first time at Nani's"), which has no catalogue entry, so its words
-- travel with the row.
--
--   photo_path  the Storage object path in the private `media` bucket
--               (`<uid>/milestones/<file>`), never a URL: the same rule as
--               journal_entries.image_urls (0002). Null = no photo.
--   title       set only on a milestone of her own (milestone_id starts
--               `own_`, made by the app). Null for a catalogue milestone,
--               whose title is bundled content and may be reworded.
--
-- No RLS change: the four `my_child_ids()` policies from 0025 cover every
-- column of the row, so both parents read and write the new ones.
--
-- ⚠️ THE PHOTO ITSELF IS READ BY ITS STORAGE POLICY, NOT THIS TABLE'S. The
-- media bucket lets the uploader and the paired partner read (0013, 0014).
-- A third caregiver on the child sees the row and its date but not the
-- photo (STILL-OPEN §101.10).
--
-- Safe before the app ships and after: the app sends these keys only when
-- they are set (MilestoneStore._cols), so a photo-less row is valid on a
-- database without this migration, and an older build that never sends
-- them leaves them untouched (PostgREST updates only the columns it gets).
--
-- PREREQ: 0025 (pp_milestone_observations). Additive and safe to re-run.
-- =====================================================================

alter table public.pp_milestone_observations
  add column if not exists photo_path text,
  add column if not exists title      text;
