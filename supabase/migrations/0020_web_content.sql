-- =====================================================================
-- 0020_web_content.sql — content for the ParentVeda WEBSITE (SEO guides).
-- ---------------------------------------------------------------------
-- The website (Next.js) reads these tables the same way the app reads
-- `articles`: PUBLIC-READ of published rows, authored in the shared
-- Directus panel. This is SEPARATE from the app's `articles` table
-- (richer: SEO fields, categories, verdicts) but lives in the SAME
-- Supabase project. Modeled 1:1 on the website's src/lib/guides.ts so
-- its existing structure + SEO carry over. See docs/CONTENT-BACKEND.md.
--
-- Post body is Markdown (comfortable to edit in Directus; the website renders
-- it with a standard markdown component). Recipe / source / book_meta stay as
-- JSON, matching the website's optional RecipeMeta / source / bookMeta fields.
-- =====================================================================

-- ---- content_categories (mirrors GuideCategory) ---------------------
create table public.content_categories (
  slug        text        primary key,                    -- article | recipe | ...
  name        text        not null,                        -- plural display
  singular    text        not null default '',
  tagline     text        not null default '',
  description text        not null default '',             -- SEO meta for the category page
  icon        text        not null default '',             -- IconKey
  tint        text        not null default '',             -- Tint
  sort        int         not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

alter table public.content_categories enable row level security;
create policy "content_categories public read"
  on public.content_categories for select to anon, authenticated using (true);
grant select on public.content_categories to anon, authenticated;

-- ---- content_posts (mirrors GuidePost + SEO/taxonomy fields) --------
create table public.content_posts (
  id            uuid        primary key default gen_random_uuid(),
  status        text        not null default 'published',  -- draft | published
  category      text        not null references public.content_categories (slug),
  slug          text        not null,
  title         text        not null,                       -- H1 + SEO title base
  description   text        not null default '',            -- meta description (<=160)
  excerpt       text        not null default '',            -- listing excerpt
  body          text        not null default '',            -- Markdown (rendered by the website)
  author        text        not null default '',
  reading_time  text        not null default '',
  tags          text[]      not null default '{}',          -- theme tags
  -- taxonomy (forward-looking, from the content plan; nullable)
  trimester     text,                                        -- 1 | 2 | 3 | 4
  week_tag      int,                                         -- ties to the app week stack
  verdict       text,                                        -- yes|moderation|avoid-some|avoid (Can-I posts)
  -- type-specific (optional, JSON, matching the TS optional fields)
  recipe        jsonb,                                       -- RecipeMeta
  source        jsonb,                                       -- { label, href }
  book_meta     jsonb,                                       -- { title, author }
  -- SEO extras (nullable → fall back to sensible defaults on the site)
  meta_title    text,                                        -- overrides title for <title>
  og_image      text,                                        -- per-post social image
  og_image_alt  text,
  canonical_path text,
  -- dates
  published_at  timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  created_at    timestamptz not null default now(),
  unique (category, slug)                                    -- one slug per category (the URL)
);

alter table public.content_posts enable row level security;
-- Public read of PUBLISHED rows only (drafts hidden). Writes via Directus /
-- service-role. The website reads with the anon/publishable key.
create policy "content_posts public read"
  on public.content_posts for select to anon, authenticated
  using (status = 'published');
grant select on public.content_posts to anon, authenticated;

create index content_posts_category_idx on public.content_posts (category);
create index content_posts_published_idx on public.content_posts (published_at desc);

-- ---- Seed the 5 categories (from src/lib/guides.ts CATEGORIES) -------
insert into public.content_categories (slug, name, singular, tagline, description, icon, tint, sort) values
('article', 'Articles', 'Article',
  $$Stage-aware, gentle reads for every week.$$,
  $$Calm, evidence-informed pregnancy and parenting articles — nutrition, symptoms, trimesters and more, in plain English and Hinglish.$$,
  'book', 'brand', 1),
('research-summary', 'Research Summaries', 'Research Summary',
  $$The science, gently distilled.$$,
  $$Plain-language summaries of pregnancy and parenting research — what the studies actually say, and what it means for you.$$,
  'shield', 'earth', 2),
('book-summary', 'Book Summaries', 'Book Summary',
  $$Big pregnancy books, in a calm few minutes.$$,
  $$Short, honest summaries of the best-loved pregnancy and parenting books — key takeaways you can use today.$$,
  'star', 'coral', 3),
('recipe', 'Recipes', 'Recipe',
  $$Trimester-friendly food and dadi-maa ke nuskhe.$$,
  $$Simple, nourishing pregnancy recipes and traditional Indian nushkhe — trimester-friendly, easy to digest and made with love.$$,
  'bowl', 'earth', 4),
('parenting-faq', 'Parenting FAQ', 'FAQ',
  $$Clear, calm answers to the questions every parent asks.$$,
  $$Honest, evidence-informed answers to common pregnancy and parenting questions — the "Can I…?" and "Is it safe…?" worries, gently settled.$$,
  'chat', 'brand', 5);
