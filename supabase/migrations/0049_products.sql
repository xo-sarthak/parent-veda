-- =====================================================================
-- 0049_products.sql -- the parenting product catalogue, editor-owned.
-- ---------------------------------------------------------------------
-- The strongest case yet for content living in a database rather than a
-- release: a product's price, its retailer and whether it is still sold
-- go stale on their own, without anyone editing anything. Every other
-- content type decays slowly; this one decays on a schedule set by
-- somebody else.
--
-- PARENTING ONLY, for the same reason reads was narrowed. The pregnancy
-- catalogue (lib/data/product_data.dart, `Product`) is a different model
-- - a ParentVeda Score out of ten, review summaries, an affiliate flag,
-- price as a preformatted string. This one carries brand, retailer,
-- star ratings and side-by-side compare specs. Sharing a table would
-- mean a row that has to explain which half of itself is meaningful.
--
-- A NOTE ON PRICE. `price_inr` is WHOLE RUPEES, matching the bundled
-- Dart exactly so the flip changes nothing on screen. This is
-- deliberately NOT the `price_paise` convention used by the booking
-- engine, where money is charged and integer paise avoid float error.
-- Nothing is charged here - these are display prices for a catalogue
-- that links out to a retailer. The column is named for its unit so the
-- two can never be confused by someone reading only the schema.
--
-- WHAT STAYS IN DART: kPpCategories / kPpConcerns / kPpStages. They map
-- categories to icons and to the concern and stage filters - structure
-- and code, not content. An editor files a product under an existing
-- category; inventing one would mean a new row of the UI that nothing
-- renders.
--
-- PREREQ: 0045 (directus_cms), 0046 (cms_sync_media).
-- =====================================================================

create table if not exists public.products (
  id           uuid        primary key default gen_random_uuid(),
  source_key   text        unique,
  status       varchar(32) not null default 'published',
  domain       text        not null default 'parenting',

  name         text        not null,
  name_hi      text,
  brand        text        not null default '',
  category     text        not null default '',      -- kPpCategories id, e.g. 'Sleep'
  sub          text        not null default '',      -- sub-category display name

  -- ---- the commercial facts, the ones that rot ---------------------
  price_inr    int         not null default 0,       -- WHOLE RUPEES (see header)
  retailer     text        not null default '',      -- 'Amazon' | 'FirstCry' | ...
  rating       numeric(2,1) not null default 0,      -- 0.0-5.0
  reviews      int         not null default 0,

  -- ---- editorial standing ------------------------------------------
  verified     boolean     not null default false,
  parent_veda  boolean     not null default false,   -- a ParentVeda product
  bestseller   boolean     not null default false,
  badge        text        not null default '',      -- 'Best overall' | 'Best value' | ...
  best_for     text        not null default '',      -- one-line "who this suits"
  summary      text        not null default '',

  -- ---- the honest half ---------------------------------------------
  -- pros AND cons, together. tool/export_ttc_corpus.dart states the rule
  -- for TTC products -- "watchOut is exported with the SAME weight" --
  -- because a catalogue listing only what is good about a thing is an
  -- advert. The parenting corpus was NOT honouring it (it grounded Ask
  -- Veda on pros alone); fixed in parenting_veda.dart alongside this
  -- migration. Keeping both halves in one row is what lets the rule be
  -- checked rather than remembered.
  pros         jsonb       not null default '[]'::jsonb,
  cons         jsonb       not null default '[]'::jsonb,
  specs        jsonb       not null default '{}'::jsonb,  -- {"Weight":"1.2 kg"}

  -- ---- side-by-side compare fields (populated per category) --------
  spec_sound       text,
  spec_auto_off    boolean,
  spec_volume_lock boolean,
  spec_power       text,

  hero_image   text,
  hero_file    uuid,
  sort         int         not null default 0,

  published_at timestamptz not null default now(),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  constraint products_status_check
    check (status in ('draft', 'published', 'archived')),
  constraint products_rating_check
    check (rating >= 0 and rating <= 5),
  -- Price and rating are shown to a parent deciding what to buy. A
  -- negative price is not a discount, it is a typo that would render as
  -- "₹-1,899" on a card nobody proofread.
  constraint products_price_check
    check (price_inr >= 0),
  constraint products_reviews_check
    check (reviews >= 0)
);

comment on table public.products is
  'Editor-owned parenting product catalogue. Categories/concerns/stages stay in Dart - they carry icons and drive filters.';
comment on column public.products.price_inr is
  'WHOLE RUPEES, not paise. Display only; nothing is charged here. The booking engine uses price_paise and the two must not be confused.';
comment on column public.products.cons is
  'The "worth knowing" half. A product with pros and no cons reads as an advert - keep it filled.';

create index if not exists products_published_idx
  on public.products (status, domain, category, sort);


-- ---- access ---------------------------------------------------------
alter table public.products enable row level security;

drop policy if exists "products public read" on public.products;
create policy "products public read"
  on public.products for select
  to anon, authenticated
  using (status = 'published');

grant select on public.products to anon, authenticated;

grant select, insert, update, delete on public.products to directus_cms;

drop policy if exists "products cms write" on public.products;
create policy "products cms write"
  on public.products for all
  to directus_cms using (true) with check (true);


-- ---- image picker sync (0046 pattern) --------------------------------
drop trigger if exists products_media_sync on public.products;
create trigger products_media_sync
  before insert or update of hero_file on public.products
  for each row execute function public.cms_sync_media('hero_file', 'hero_image');


-- =====================================================================
-- SEEDING
--
--     flutter test tool/export_content_seed.dart
--     -> build/seed_products.sql
--
--   select count(*) from public.products;   -- expect 23
-- =====================================================================
