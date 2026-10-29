-- =============================================================================
--  0129 — a child's health conditions live on the child (PP 21, 2026-10-29)
-- -----------------------------------------------------------------------------
--  docs/FAMILY-MODEL.md: the person owns identity, the CHILD owns what is
--  recorded about the child, so both parents see the same baby. A child's
--  conditions (eczema, reflux, a hearing need...) were kept per child on the
--  mother's phone only, inside her own family_profile cloud items, so the
--  other parent's phone never learned them. This is the same move 0102 made
--  for birth_mode and born_weeks.
--
--  ⚠️ NULL IS NOT EMPTY.
--    null  = no phone has said; each phone falls back to its own answers.
--    '{}'  = she said none; it beats a stale answer on the other phone.
--
--  No check on the values, deliberately. The vocabulary is the app's
--  `HealthCondition` enum, and old apps skip a name they do not know. A check
--  constraint would make a NEWER app's new condition fail silently on this
--  database (writes are fire-and-forget), which is worse than a misspelling
--  the client never writes. Same reasoning as saved_items.kind (0081).
--
--  No policy change: "children own or partner select/update" (0021) already
--  lets either parent read and edit the row.
--
--  After running: set kChildConditionsColumn = true in
--  lib/screens/post_pregnancy/pp_child_profile.dart.
-- =============================================================================

alter table public.children add column if not exists conditions text[];

comment on column public.children.conditions is
  'HealthCondition names (app enum). null = not said on any phone; empty = said none. PP 21.';
