-- =============================================================================
--  0117 · How long she has been trying: her pick, and the worked-out start
--  (T1, 2026-10-27; docs/preg-ttc-tool-plans/00-MASTER.md, TT1)
-- -----------------------------------------------------------------------------
--  The app now leaves her own pregnancies out of "how long have you been
--  trying", and lets her change what it counts from. Three columns on her
--  journey row:
--
--    trying_count_from      'again' | 'own', or null for the default
--                           (since she first started). Her "Change" pick.
--    trying_count_date      the date that pick counts from.
--    trying_effective_start the start that gives her count with nothing left
--                           out. Published so his phone shows the same number
--                           WITHOUT her pregnancy dates ever leaving her row,
--                           the same pattern as current_chapter.
--
--  A fact and a basis, never a rewritten fact: journey_start stays as she gave
--  it. No new policy: 0103 already lets the partner read and only the owner
--  write this row.
--
--  Runs after 0041, 0044 and 0103.
-- =============================================================================

alter table public.ttc_journeys
  add column if not exists trying_count_from text;

alter table public.ttc_journeys
  add column if not exists trying_count_date date;

alter table public.ttc_journeys
  add column if not exists trying_effective_start date;

alter table public.ttc_journeys
  drop constraint if exists ttc_journeys_trying_count_from_check;

alter table public.ttc_journeys
  add constraint ttc_journeys_trying_count_from_check
  check (trying_count_from is null or trying_count_from in ('again', 'own'));
