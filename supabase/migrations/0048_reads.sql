-- =====================================================================
-- 0048_reads.sql -- the parenting Reading Experience, editor-owned.
-- ---------------------------------------------------------------------
-- A NARROWER SCOPE THAN PLANNED, DELIBERATELY.
--
-- The plan said one `reads` type would absorb three files:
-- pp_reading_data.dart, read_next_data.dart and spiritual_reading_data.dart.
-- Reading the three models made that look wrong:
--
--   ReadArticle (parenting)   collection + age + nested sections with inline
--                             tips and myth-vs-fact cards
--   ReadItem (pregnancy)      week-targeted, typed, priority, rating,
--                             a different set of reader blocks again
--   SpiritualTradition        tradition -> read -> section, nested two deep
--
-- Forcing all three into one table produces ~50 columns where every
-- consumer uses half, and every read has to defend against fields that
-- are meaningless for it. That is the shape CLAUDE.md warns about: a
-- model that can express more states than the product has is a bug
-- surface, not flexibility.
--
-- So this table is the PARENTING reading experience only. The other two
-- become their own types when they earn it — the engine makes that ~1
-- hour each, which is exactly why it was worth building first.
--
-- WHAT STAYS IN DART: kReadCollections. Seven curated collections that
-- carry an IconData — code, not content — and act as the structure
-- articles are filed under. An editor assigns an article to a collection
-- by id; they do not invent collections, because a new collection is a
-- new shelf in the UI, not a new article on an existing one.
--
-- PREREQ: 0045 (directus_cms), 0046 (cms_sync_media).
-- =====================================================================

create table if not exists public.reads (
  id           uuid        primary key default gen_random_uuid(),
  source_key   text        unique,
  status       varchar(32) not null default 'published',
  domain       text        not null default 'parenting',

  title        text        not null,
  title_hi     text,
  teaser       text        not null default '',     -- one-line hook
  teaser_hi    text,
  why_today    text        not null default '',     -- "why this matters today"
  why_today_hi text,

  collection   text        not null default '',     -- kReadCollections id (Dart-owned)
  kind         text        not null default 'article',
  age_tag      text        not null default '',
  age_min_months int,
  age_max_months int,
  minutes      int         not null default 5,

  author       text        not null default '',
  author_role  text        not null default '',
  evidence     text,                                 -- plain-language evidence note

  -- The article body. A list of blocks:
  --   { heading, paragraphs[], tip{title,body}, mythFact{myth,fact}, image }
  -- jsonb rather than columns because this is authored structure that only
  -- a human writes and the reader renders — SQL never looks inside it.
  sections     jsonb       not null default '[]'::jsonb,

  related_activity   text,
  related_video_id   text,                           -- embedded mid-article
  related_video_ids  text[] not null default '{}',   -- the "Related videos" block
  related_recipe_id  text,
  related_product_id text,
  related_community  text,

  hero_image   text,
  hero_file    uuid,
  shuffle_seed int         not null default 0,
  sort         int         not null default 0,

  published_at timestamptz not null default now(),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  constraint reads_status_check
    check (status in ('draft', 'published', 'archived')),
  -- Matches the ReadKind enum. A typo here would drop the article out of
  -- every type filter at once while still looking published.
  constraint reads_kind_check
    check (kind in ('article', 'bookSummary', 'research'))
);

comment on table public.reads is
  'Editor-owned articles for the parenting Reading Experience. Collections stay in Dart (kReadCollections) - they are structure, and carry icons.';
comment on column public.reads.collection is
  'A kReadCollections id. Unknown values file the article nowhere - offer this as a dropdown in Directus, never a free-text box.';

create index if not exists reads_published_idx
  on public.reads (status, domain, collection, sort);


-- ---- access (identical shape to 0019 / 0047) -------------------------
alter table public.reads enable row level security;

drop policy if exists "reads public read" on public.reads;
create policy "reads public read"
  on public.reads for select
  to anon, authenticated
  using (status = 'published');

grant select on public.reads to anon, authenticated;

grant select, insert, update, delete on public.reads to directus_cms;

drop policy if exists "reads cms write" on public.reads;
create policy "reads cms write"
  on public.reads for all
  to directus_cms using (true) with check (true);


-- ---- image picker sync (0046 pattern) --------------------------------
drop trigger if exists reads_media_sync on public.reads;
create trigger reads_media_sync
  before insert or update of hero_file on public.reads
  for each row execute function public.cms_sync_media('hero_file', 'hero_image');


-- =====================================================================
-- SEEDING
--
--     flutter test tool/export_content_seed.dart
--     -> build/seed_reads.sql        (and build/seed_recipes.sql)
--
-- Generated, guarded with `on conflict (source_key) do nothing`, and
-- parity-tested against the Dart (test/reads_seed_test.dart).
--
--   select count(*) from public.reads;   -- expect 10
-- =====================================================================
