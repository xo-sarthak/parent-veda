-- =====================================================================
-- 0096_recipes_doc_fields.sql — the Drive recipe-doc format on public.recipes
-- (2026-10-15, the 7–8 month band, Mixed dal khichdi pilot)
-- ---------------------------------------------------------------------
-- The recipe docs in Drive ("Recipes (not reviewed)") carry six things the
-- FoodRecipe model did not: a photo, a separate "How much" column per
-- ingredient, the texture, the meal role, the extra categories a dish is
-- tagged into, and the doc's own id. The app reads all six forgivingly
-- (RecipeStore.fromMap defaults each to empty), and recipes are still
-- ContentOwner.bundled, so nothing breaks before this is run. It exists
-- so a row edited in Directus can carry the same page the bundled dish does.
--
-- `amounts` is jsonb to match `ingredients` (index i of one is index i of
-- the other); `also_in` is text[] like `tags`.
--
-- PREREQ: 0047_recipes.sql.
-- =====================================================================

alter table public.recipes
  add column if not exists photo     text,
  add column if not exists amounts   jsonb  not null default '[]'::jsonb,
  add column if not exists texture   text,
  add column if not exists meal_role text,
  add column if not exists also_in   text[] not null default '{}',
  add column if not exists doc_id    text;
