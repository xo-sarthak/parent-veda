-- =============================================================================
--  0093 — "Boy or girl" can be left unanswered (2026-10-07)
-- -----------------------------------------------------------------------------
--  Parenting gap analysis, P1: onboarding's "Boy or girl — optional" saved a
--  skipped answer as a boy (`is_boy not null default true`, 0021), and every
--  parenting page then said "him". The app now records whether the parent
--  gave the sex at all; when she did not, it uses the child's name or "your
--  baby" and never a he/she.
--
--  WHY A SECOND COLUMN, NOT A NULLABLE `is_boy`: every shipped build reads
--  `is_boy` as a plain boolean, and the growth charts need a sex to pick a
--  WHO table. Leaving `is_boy` as it is keeps every older build working; the
--  new column only adds a fact older builds simply do not read.
--
--  EXPAND ONLY. Nullable-free with a default of true: every existing row (a
--  child whose parent did answer, or was never asked) stays as it is.
--
--  ORDER: run this, THEN set `kChildSexGivenColumn = true` in
--  lib/screens/post_pregnancy/pp_child_profile.dart. Before that flag flips,
--  the app keeps the answer on the phone only and never names the column
--  (PostgREST refuses a row with an unknown column, silently for a
--  fire-and-forget write).
--
--  No policy change: the children policies (0021, my_child_ids()) already
--  cover every column of the row.
-- =============================================================================

alter table public.children
  add column if not exists sex_given boolean not null default true;
