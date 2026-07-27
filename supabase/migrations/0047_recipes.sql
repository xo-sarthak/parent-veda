-- =====================================================================
-- 0047_recipes.sql -- the second editor-owned content type.
-- ---------------------------------------------------------------------
-- Mirrors 0019_articles.sql: public-read of published rows, no write
-- policy, writes only from Directus / service_role. What is new here is
-- the shape, because a recipe carries far more than an article.
--
-- WHAT MOVES AND WHAT DOES NOT
--
-- lib/screens/post_pregnancy/pp_food_data.dart is ~1500 lines holding
-- three different things, and only one of them belongs in a database:
--
--   * kFoodRecipes -- 28 authored dishes. EDITORIAL. This table.
--   * the helpers (browseRecipes, planForDay, buildMeals, ...) -- the
--     Food companion's ENGINE. Stays in Dart. Which dish is offered for
--     Tuesday lunch is product behaviour, not content, and CLAUDE.md is
--     explicit that rules do not move to the database.
--   * FoodStore -- saved dishes and the shopping list. USER DATA, already
--     cloud-synced per-user. Not this, and never a Directus collection.
--
-- COLUMNS VS JSONB
--
-- Anything the app FILTERS or SORTS on is a column: diet flags, minutes,
-- slot, situations, ingredient keys. Anything an editor AUTHORS as a
-- structure is jsonb: ingredients, steps, storage, mistakes,
-- substitutions, nutrients. The rule of thumb -- if SQL needs to look
-- inside it, it is a column; if only a human writes and a human reads
-- it, it is jsonb. content_posts already splits this way (recipe /
-- source / book_meta are jsonb there).
--
-- source_key IS THE HINGE
--
-- It holds the bundled Dart id ('veggieoats'), which lets the seed use
-- `on conflict (source_key) do nothing` -- so re-running the seed can
-- never overwrite an editor's edit -- and lets related_* references
-- between content keep working while both copies exist.
--
-- PREREQ: 0045 (the directus_cms role).
-- =====================================================================

create table if not exists public.recipes (
  id           uuid        primary key default gen_random_uuid(),
  source_key   text        unique,                     -- the bundled Dart id
  status       varchar(32) not null default 'published',
  domain       text        not null default 'parenting',

  -- ---- what it is -------------------------------------------------
  title        text        not null,
  title_hi     text,
  subtitle     text        not null default '',
  subtitle_hi  text,
  category     text        not null default '',
  slot         text        not null default '',        -- Breakfast | Lunch | ...
  age_tag      text        not null default '',        -- display string, e.g. '6-12 mo'
  age_min_months int,                                   -- filterable form of age_tag
  age_max_months int,

  -- ---- the facts the app filters on -------------------------------
  veg          boolean     not null default true,
  vegan        boolean     not null default false,
  immunity     boolean     not null default false,
  comfort_only boolean     not null default false,      -- sick-day recovery meals
  prep_min     int         not null default 0,
  cook_min     int         not null default 0,
  serves       int         not null default 2,
  difficulty   text        not null default '',
  frequency    text        not null default '',         -- 'A few times a week'

  -- ---- the teaching half ------------------------------------------
  highlight      text      not null default '',         -- 'Iron + calcium'
  why            text      not null default '',
  healthier_note text      not null default '',

  -- ---- authored structure (jsonb) ---------------------------------
  ingredients   jsonb      not null default '[]'::jsonb, -- ["1 cup oats", ...]
  equipment     jsonb      not null default '[]'::jsonb,
  steps         jsonb      not null default '[]'::jsonb,
  storage       jsonb      not null default '[]'::jsonb,
  mistakes      jsonb      not null default '[]'::jsonb,
  substitutions jsonb      not null default '{}'::jsonb, -- {"ragi":"oats"}
  nutrients     jsonb      not null default '[]'::jsonb, -- [{name,amount,note}]

  -- ---- sets the engine matches on ---------------------------------
  tags            text[]   not null default '{}',
  situations      text[]   not null default '{}',        -- Constipation | Fever | ...
  ingredient_keys text[]   not null default '{}',        -- Smart Meal Builder vocabulary

  -- ---- cross-links (ids, resolved in the app) ---------------------
  related_article    text,
  related_video_id   text,
  related_product_id text,
  related_community  text,

  -- ---- presentation ------------------------------------------------
  hero_image   text,
  hero_file    uuid,                                     -- Directus picker (0046 pattern)
  shuffle_seed int         not null default 0,           -- deterministic rotation
  sort         int         not null default 0,

  published_at timestamptz not null default now(),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  constraint recipes_status_check
    check (status in ('draft', 'published', 'archived')),
  -- A recipe cannot be vegan without being vegetarian. The diet marker is
  -- derived from both (vegan -> veg -> nonveg), so the impossible
  -- combination would render as "vegan, non-veg".
  constraint recipes_diet_check
    check (not vegan or veg)
);

comment on table public.recipes is
  'Editor-owned dish catalogue for the Food companion. The MEAL-PLANNING ENGINE stays in Dart (pp_food_data.dart) - only the dishes live here.';
comment on column public.recipes.source_key is
  'The bundled Dart id. Seeds upsert on this, so re-seeding never overwrites an editor.';
comment on column public.recipes.ingredient_keys is
  'Canonical keys the Smart Meal Builder offers. An unknown key silently matches nothing - keep to the existing vocabulary.';

create index if not exists recipes_published_idx
  on public.recipes (status, domain, sort);


-- ---- access ---------------------------------------------------------
alter table public.recipes enable row level security;

-- The app reads with the anon key, logged in or not. Drafts stay hidden.
-- No insert/update/delete policy, deliberately: with RLS on, a verb with
-- no policy is denied outright.
drop policy if exists "recipes public read" on public.recipes;
create policy "recipes public read"
  on public.recipes for select
  to anon, authenticated
  using (status = 'published');

grant select on public.recipes to anon, authenticated;

-- The CMS. Step 2 of the add-a-type recipe -- without BOTH the grant and
-- this policy, the collection either will not appear in Directus at all,
-- or will appear and hide the editor's own drafts.
grant select, insert, update, delete on public.recipes to directus_cms;

drop policy if exists "recipes cms write" on public.recipes;
create policy "recipes cms write"
  on public.recipes for all
  to directus_cms using (true) with check (true);


-- ---- keep the image URL in step with the picker (0046 pattern) -------
drop trigger if exists recipes_media_sync on public.recipes;
create trigger recipes_media_sync
  before insert or update of hero_file on public.recipes
  for each row execute function public.cms_sync_media('hero_file', 'hero_image');


-- =====================================================================
-- SEEDING
--
-- The rows are NOT in this file. They are generated from the bundled
-- Dart by:
--
--     flutter test tool/export_content_seed.dart
--     -> build/seed_recipes.sql
--
-- Two reasons it is generated rather than written here. Transcribing 28
-- dishes x 30 fields by hand introduces exactly the kind of quiet error
-- (a dropped ingredient, a swapped step) that nobody reviews. And the
-- parity test (test/recipes_seed_test.dart) compares the generated SQL
-- against the Dart, so drift is caught rather than assumed away.
--
-- The generated file uses `on conflict (source_key) do nothing`, so it
-- is safe to re-run at any time and can never overwrite an editor.
-- =====================================================================
