-- =============================================================================
--  0130 — a child's other answers live on the child (PP 22, 2026-10-29)
-- -----------------------------------------------------------------------------
--  The rest of the move 0129 made for conditions (PP 21) and 0102 for birth
--  mode and born-early weeks. How the child feeds, how they sleep, the vaccine
--  schedule the parents follow, a NICU stay, a twin and "born early" were kept
--  per child on the mother's phone only, inside her own family_profile cloud
--  items, so the other parent's phone never learned them: his home,
--  recommendations and Ask Veda went without, and the vaccine tracker could
--  show him a different schedule for the same baby.
--
--  Separate columns, not one jsonb "answers" blob, as 0102 and 0129 did. A
--  column is something a contract test can pin (onboarding_schema_contract,
--  pp22_child_answers_test) and a last-writer-wins row merges whole anyway.
--  The cost: each new fact about a child is a migration.
--
--  ⚠️ NULL IS "NOT SAID", FOR EVERY COLUMN, THE BOOLEANS INCLUDED.
--    null        = no phone has said; each phone falls back to its own answers.
--    '{}'/false  = she said none / no; it beats a stale answer on the other
--                  phone. So no column has a default.
--
--  No check on the values, deliberately (same as 0129 and saved_items.kind):
--  the vocabularies are the app's FeedingMethod, SleepPattern and VaxSchedule
--  enums, old apps skip a name they do not know, and a check constraint would
--  make a NEWER app's new value fail silently here (writes are fire-and-forget).
--
--  No policy change: "children own or partner select/update" (0021) already
--  lets either parent read and edit the row.
--
--  After running: set kChildAnswersColumns = true in
--  lib/screens/post_pregnancy/pp_child_profile.dart.
-- =============================================================================

alter table public.children add column if not exists feedings text[];
alter table public.children add column if not exists sleeps text[];
alter table public.children add column if not exists vax_schedule text;
alter table public.children add column if not exists nicu boolean;
alter table public.children add column if not exists multiple boolean;
alter table public.children add column if not exists premature boolean;

comment on column public.children.feedings is
  'FeedingMethod names (app enum), in pick order. null = not said on any phone; empty = said none. PP 22.';
comment on column public.children.sleeps is
  'SleepPattern names (app enum), in pick order. null = not said on any phone; empty = said none. PP 22.';
comment on column public.children.vax_schedule is
  'VaxSchedule name (app enum). null = not said on any phone. PP 22.';
comment on column public.children.nicu is
  'A NICU stay. null = not said on any phone; false = said no. PP 22.';
comment on column public.children.multiple is
  'A twin or more. null = not said on any phone; false = said no. PP 22.';
comment on column public.children.premature is
  'Born early. null = not said on any phone; false = said no. Weeks stay in born_weeks (0102). PP 22.';
