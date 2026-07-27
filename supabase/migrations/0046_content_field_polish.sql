-- =====================================================================
-- 0046_content_field_polish.sql -- make the panel usable by someone who
--                                  does not write SQL.
-- ---------------------------------------------------------------------
-- Three changes, each closing a way an editor can silently lose work:
--
--   1. `status` becomes a constrained dropdown instead of a free-text
--      box. Today an editor can type "Published" or "publish" or
--      "pubished" and the row simply never appears -- no error, no
--      warning, and the public-read policy (`status = 'published'`)
--      quietly excludes it forever. That is the worst class of bug in a
--      CMS: it looks like the publish button is broken.
--
--   2. Image fields gain a real file picker WITHOUT pointing the app at
--      Directus. See the long note in section 2 -- this is the part
--      that is easy to get wrong in a way that costs money and speed.
--
--   3. `has_hi` turns "bilingual from the first string" from an
--      aspiration into a filterable worklist.
--
-- NOT DONE HERE, on purpose: converting `content_posts.category` to a
-- dropdown. It already has a foreign key to content_categories(slug),
-- so Directus can present it as a Many-to-One relational picker, which
-- is strictly better for an editor than a dropdown (it shows the
-- category's display name, and new categories appear automatically).
-- Changing the column type would mean altering a primary key and a
-- foreign key to buy a worse interface. Configure the M2O in Directus
-- instead -- no migration required.
--
-- PREREQ: 0019 (articles), 0020 (content_posts), 0045 (the CMS role).
-- Safe to re-run.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. status -> varchar + CHECK.
--
-- Directus offers the Dropdown interface only for `string` (varchar)
-- columns, not `text`. That is the whole reason for the type change --
-- it was snagged and deferred once before (see the deferred list in
-- docs/CONTENT-BACKEND.md) because the dependent policy blocks the
-- ALTER.
--
-- The order that works: drop the policies that REFERENCE the column,
-- alter, recreate. The CMS policies added in 0045 use `using (true)`
-- and do not reference `status`, so they survive the alter untouched.
--
-- THE VOCABULARY IS DELIBERATELY SHORT. draft / published / archived.
-- No in_review, no approved, no scheduled -- there is no medical
-- reviewer in the workflow yet, and CLAUDE.md is explicit that a config
-- able to express more states than the product actually has is a bug
-- surface rather than flexibility. Adding a state later is one line
-- here; the public-read policy stays `= 'published'` either way, so
-- every new state is invisible to the app, the website and the RAG by
-- construction.
--
-- `archived` earns its place now because it is the honest alternative
-- to deleting: content that is retired but may be wanted back, without
-- an editor reaching for DELETE.
-- ---------------------------------------------------------------------

-- articles ----------------------------------------------------------
drop policy if exists "articles public read" on public.articles;

alter table public.articles
  alter column status type varchar(32) using status::varchar(32);

alter table public.articles drop constraint if exists articles_status_check;
alter table public.articles add  constraint articles_status_check
  check (status in ('draft', 'published', 'archived'));

create policy "articles public read"
  on public.articles for select
  to anon, authenticated
  using (status = 'published');

-- content_posts -----------------------------------------------------
drop policy if exists "content_posts public read" on public.content_posts;

alter table public.content_posts
  alter column status type varchar(32) using status::varchar(32);

alter table public.content_posts drop constraint if exists content_posts_status_check;
alter table public.content_posts add  constraint content_posts_status_check
  check (status in ('draft', 'published', 'archived'));

create policy "content_posts public read"
  on public.content_posts for select
  to anon, authenticated
  using (status = 'published');


-- ---------------------------------------------------------------------
-- 2. Image fields: a picker for the editor, a CDN URL for the app.
--
-- THE TRAP THIS AVOIDS
--
-- The obvious way to add an image picker is to point the app at
-- Directus's asset endpoint -- `<directus>/assets/<file-id>`. Do that
-- and every image every user ever loads is served by the free-tier
-- Render box. That box is allowed to SLEEP precisely because nothing
-- user-facing depends on it: the whole architecture rests on "the app
-- reads Supabase directly, never Directus". Routing images through it
-- would silently make Directus a user-facing CDN -- slow, sleeping, and
-- the one component sized for a handful of editors rather than every
-- mother.
--
-- So: `hero_image` stays a plain text URL and remains the ONLY thing
-- the app reads. `hero_file` is added purely so Directus can show a
-- File picker (uploads land in R2, which is already configured as
-- Directus storage). A trigger derives the public R2 URL from the
-- uploaded file and writes it into `hero_image`.
--
-- A TRIGGER, NOT A DIRECTUS FLOW. Both live in the same database, so a
-- trigger is not extra infrastructure -- and unlike a Flow it cannot be
-- disabled from an admin UI, cannot fail silently while an editor
-- watches a green tick, and runs for a SQL edit too.
-- ---------------------------------------------------------------------

-- Where R2 serves media from. Set this ONCE to your public R2 / CDN
-- origin, no trailing slash, e.g.
--   create or replace function public.cms_media_base() returns text
--   language sql immutable as $$ select 'https://media.parentveda.in' $$;
--
-- Until it returns a non-empty value the trigger deliberately does
-- NOTHING -- an unconfigured base must not overwrite a working
-- hand-entered URL with a broken one.
create or replace function public.cms_media_base()
returns text language sql immutable as $$
  select ''::text            -- TODO: set to the public R2 bucket origin
$$;

comment on function public.cms_media_base() is
  'Public origin for admin-uploaded media (Cloudflare R2). Empty = image sync disabled. Never point this at Directus.';

alter table public.articles      add column if not exists hero_file uuid;
alter table public.content_posts add column if not exists hero_file uuid;
alter table public.content_posts add column if not exists og_image_file uuid;

-- content_posts has no hero_image column today (the website renders its own
-- art). Added BEFORE the triggers below, because jsonb_populate_record ignores
-- keys the record type does not have — so a missing target column would make
-- the sync silently do nothing rather than fail loudly.
alter table public.content_posts add column if not exists hero_image text;

comment on column public.articles.hero_file is
  'Directus File picker only. The app reads hero_image; this syncs into it.';

-- Resolve a directus_files id to its public R2 URL.
-- Guarded on directus_files existing so this migration does not depend
-- on Directus having booted yet.
create or replace function public.cms_file_url(p_file uuid)
returns text language plpgsql stable as $$
declare
  v_base text := public.cms_media_base();
  v_disk text;
begin
  if p_file is null or coalesce(v_base, '') = '' then
    return null;
  end if;
  if to_regclass('public.directus_files') is null then
    return null;
  end if;

  execute 'select filename_disk from public.directus_files where id = $1'
     into v_disk using p_file;

  if v_disk is null or v_disk = '' then
    return null;
  end if;
  return v_base || '/' || v_disk;
end $$;

-- Keep the text URL in step with the picker. Only ever writes when it
-- can resolve a real URL, so clearing the picker or an unconfigured
-- base leaves whatever was already there.
create or replace function public.cms_sync_media()
returns trigger language plpgsql as $$
declare
  v_url text;
begin
  if tg_argv[0] is not null then
    v_url := public.cms_file_url((to_jsonb(new) ->> tg_argv[0])::uuid);
    if v_url is not null then
      new := jsonb_populate_record(new, jsonb_build_object(tg_argv[1], v_url));
    end if;
  end if;
  return new;
end $$;

drop trigger if exists articles_media_sync      on public.articles;
drop trigger if exists content_posts_media_sync on public.content_posts;
drop trigger if exists content_posts_og_sync    on public.content_posts;

create trigger articles_media_sync
  before insert or update of hero_file on public.articles
  for each row execute function public.cms_sync_media('hero_file', 'hero_image');

create trigger content_posts_media_sync
  before insert or update of hero_file on public.content_posts
  for each row execute function public.cms_sync_media('hero_file', 'hero_image');

create trigger content_posts_og_sync
  before insert or update of og_image_file on public.content_posts
  for each row execute function public.cms_sync_media('og_image_file', 'og_image');

-- Recommended sizes, so slots stay consistent as content grows:
--   hero      1200 x 630   (also the OG card size -- one image, two jobs)
--   thumbnail  640 x 360
--   avatar     256 x 256


-- ---------------------------------------------------------------------
-- 3. A worklist for missing Hinglish.
--
-- "Bilingual from the first string" is a house rule, and right now the
-- only way to find English-only rows is to read them all. A generated
-- column plus a saved filter in Directus turns that into a list an
-- editor can work through.
--
-- articles only: content_posts is the WEBSITE's table and is
-- English-only by design today. When the site goes bilingual it gains
-- title_hi/body_hi and the same column.
-- ---------------------------------------------------------------------
alter table public.articles drop column if exists has_hi;
alter table public.articles
  add column has_hi boolean
  generated always as (
    coalesce(title_hi, '') <> '' and coalesce(body_hi, '') <> ''
  ) stored;

comment on column public.articles.has_hi is
  'Derived. Directus filter preset "Missing Hinglish" = has_hi is false.';


-- ---------------------------------------------------------------------
-- 4. The new columns need the CMS grant too.
--
-- Column-level privileges are not implied by a table-level grant made
-- BEFORE the column existed in every case, and being explicit here
-- costs nothing. (0045 granted at table level, which does cover new
-- columns -- this is belt and braces, and a reminder that step 4 of the
-- add-a-type recipe exists.)
-- ---------------------------------------------------------------------
grant select, insert, update, delete on public.articles      to directus_cms;
grant select, insert, update, delete on public.content_posts to directus_cms;


-- =====================================================================
-- VERIFY
--
--   -- a bad status is now rejected instead of silently unpublished
--   insert into public.articles (title, body, status)
--   values ('x', 'y', 'Published');        -- expect: check constraint violation
--
--   -- the worklist
--   select count(*) from public.articles where has_hi is false;
--
--   -- image sync, once cms_media_base() is set and a file is uploaded
--   select hero_file, hero_image from public.articles where hero_file is not null;
--
-- DIRECTUS SIDE (after running this):
--   * articles.status / content_posts.status -> interface "Dropdown",
--     choices draft | published | archived.
--   * content_posts.category -> interface "Many to One" on
--     content_categories, display template {{name}}.
--   * hero_file / og_image_file -> interface "File", folder = the R2
--     storage adapter. Hide hero_image / og_image from the editor form
--     (read-only, derived) so there is one obvious way to set an image.
--   * Saved filter preset on articles: has_hi = false, named
--     "Missing Hinglish".
-- =====================================================================
