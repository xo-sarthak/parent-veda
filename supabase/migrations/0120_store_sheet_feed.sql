-- =============================================================================
--  0120 · The store's sheet feed and the retailer's own listing facts
--  (store Track A, slice 2, 2026-10-28)
-- -----------------------------------------------------------------------------
--  PLUG AND PLAY. The affiliate catalogue moves out of the app's code into
--  this table, so a new product (or a changed link) reaches every phone
--  without a release:
--
--    the product sheet (Excel)
--      → tools/products/import_store_sheet.py   (validates, writes SQL)
--      → products rows with domain = 'store'
--      → the app (PvCatalogStore.loadFromCloud): a row REPLACES the built-in
--        product with the same id, or is added as a new one.
--
--  `domain = 'store'` marks rows the sheet owns. The 23 older parenting rows
--  (0049) stay as they are and the app does not read them, so nothing on
--  screen changes until the first import.
--
--  NEW COLUMNS
--    programme   amazon | flipkart | inrdeals | cuelinks | direct — decides
--                how the link opens and whose price rules apply.
--    placements  where in the app a moment-of-need card may show it
--                (the sheet's "where it shows" column). Stored now, read by
--                the placement cards in a later slice.
--    ext_title, ext_features, ext_image
--                THE RETAILER'S OWN LISTING, written only by affiliate-refresh
--                from Amazon's Creators API: the listing title, the "About
--                this item" bullets, the main photo. Amazon's terms allow
--                these on our page only when they come from its API and are
--                kept fresh, so nothing else writes them, and the app shows
--                them labelled "From Amazon".
--
--  Additive and idempotent; safe to run twice. Runs after 0108.
-- =============================================================================

alter table public.products
  add column if not exists programme    text   not null default '',
  add column if not exists placements   text[] not null default '{}',
  add column if not exists ext_title    text,
  add column if not exists ext_features jsonb  not null default '[]'::jsonb,
  add column if not exists ext_image    text;

alter table public.products
  drop constraint if exists products_programme_check,
  add  constraint products_programme_check
    check (programme in ('', 'amazon', 'flipkart', 'inrdeals', 'cuelinks', 'direct'));

-- The app reads the sheet's rows only.
create index if not exists products_store_domain_idx
  on public.products (domain) where domain = 'store';
