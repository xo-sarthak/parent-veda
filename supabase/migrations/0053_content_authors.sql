-- =====================================================================
-- 0053_content_authors.sql -- who wrote this, as a record rather than a
--                             string that has to match.
-- ---------------------------------------------------------------------
-- Today the website enriches a post's plain-text `author` into a full
-- profile by matching it against a hardcoded array in
-- src/lib/authors.ts. Three things follow from that, all bad:
--
--   * adding an author is a code change and a deploy
--   * correcting a credential is a code change
--   * the match is BY NAME STRING. Type "Dr Mahender Singh" without the
--     full stop in Directus and the profile silently does not resolve.
--     No error - the byline just goes bare, on the one element of a
--     health article that carries its authority.
--
-- WHY THIS IS MORE THAN A BYLINE HERE
--
-- ParentVeda's articles are AI-drafted and reviewed by a clinician who
-- is then credited as the author. So this row is not decoration - it is
-- the claim that a named, registered doctor stood behind a piece of
-- health content. It deserves a foreign key, not a string comparison.
--
-- ON PUBLISHING A REGISTRATION NUMBER
--
-- `registration` is public on purpose, and is already rendered on the
-- live site: a medical council number is a credential a doctor wants
-- shown, and it is the thing that makes "Dr." verifiable rather than
-- decorative. Do not confuse it with care_partner_verification (0050),
-- which is private - that table holds KYC references and the paperwork
-- behind an approval. One is a published credential; the other is a
-- professional's file. They are different things and live apart.
--
-- PREREQ: 0020 (content_posts), 0037 (care_partners), 0045, 0046.
-- =====================================================================

create table if not exists public.content_authors (
  slug         text        primary key,          -- 'dr-mahender-singh' → the URL
  status       varchar(32) not null default 'published',
  name         text        not null,             -- 'Dr. Mahender Singh'
  credentials  text        not null default '',  -- 'MBBS, DCH, MD (Paediatrics)'
  role         text        not null default '',  -- the line under the name
  photo        text,                             -- /public path or R2 URL
  photo_file   uuid,                             -- Directus picker (0046 pattern)

  short_bio    text        not null default '',  -- one sentence; used in meta
  bio          jsonb       not null default '[]'::jsonb,  -- one string per paragraph

  specialties     text[]   not null default '{}',
  -- [{degree, institution, year}] — authored structure, never queried
  qualifications  jsonb    not null default '[]'::jsonb,
  memberships     text[]   not null default '{}',
  languages       text[]   not null default '{}',

  experience   text,                             -- '42 years in healthcare'
  registration text,                             -- PUBLIC credential — see header
  practice     text,

  -- When the author is also a Care Partner, link them. Makes the trust
  -- chain traceable: the doctor on the byline is the same verified row
  -- the approval flow acted on, rather than two people who share a name.
  partner_id   text references public.care_partners (id),

  -- The date this clinician agreed to be credited on ParentVeda content.
  -- Recorded, not enforced. It matters because the drafts are AI-written
  -- and the byline is a real person's professional reputation - if that
  -- is ever questioned, "we have a date" is a much better answer than
  -- "we believe so".
  byline_consent_at timestamptz,

  sort         int         not null default 0,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  constraint content_authors_status_check
    check (status in ('draft', 'published', 'archived'))
);

comment on table public.content_authors is
  'Article author profiles. Replaces the hardcoded AUTHORS array in the website repo. Resolution is by author_slug FK, never by matching the name string.';
comment on column public.content_authors.registration is
  'Medical council registration — PUBLIC, and already shown on the site. Private paperwork lives in care_partner_verification (0050), not here.';
comment on column public.content_authors.byline_consent_at is
  'When this clinician agreed to be credited. Drafts are AI-written; the byline is a real reputation.';


-- ---- the post → author relation --------------------------------------
-- `author` (free text) is KEPT: posts bylined "Team ParentVeda" have no
-- profile and should keep rendering as plain unlinked text, exactly as
-- they do now. author_slug is the resolved link when there IS a profile,
-- and the FK means an unknown slug is rejected at write time rather than
-- silently rendering a bare byline at read time.
alter table public.content_posts
  add column if not exists author_slug text
    references public.content_authors (slug);

create index if not exists content_posts_author_slug_idx
  on public.content_posts (author_slug);


-- ---- access ----------------------------------------------------------
alter table public.content_authors enable row level security;

drop policy if exists "content_authors public read" on public.content_authors;
create policy "content_authors public read"
  on public.content_authors for select
  to anon, authenticated
  using (status = 'published');

grant select on public.content_authors to anon, authenticated;

grant select, insert, update, delete on public.content_authors to directus_cms;

drop policy if exists "content_authors cms write" on public.content_authors;
create policy "content_authors cms write"
  on public.content_authors for all
  to directus_cms using (true) with check (true);

drop trigger if exists content_authors_media_sync on public.content_authors;
create trigger content_authors_media_sync
  before insert or update of photo_file on public.content_authors
  for each row execute function public.cms_sync_media('photo_file', 'photo');


-- ---- seed: the one existing author, unchanged ------------------------
-- Transcribed from C:\parentveda-web\src\lib\authors.ts so day one looks
-- identical. `on conflict do nothing`, like every other seed here, so a
-- re-run can never overwrite an edit.
insert into public.content_authors (
  slug, name, credentials, role, photo, short_bio, bio,
  specialties, qualifications, memberships, languages,
  experience, registration, practice, sort
) values (
  'dr-mahender-singh',
  'Dr. Mahender Singh',
  'MBBS, DCH, MD (Paediatrics)',
  'Consultant Child Specialist & Neonatologist',
  '/authors/dr-mahender-singh.jpg',
  'A consultant child specialist and neonatologist with over four decades of practice in newborn and child health.',
  jsonb_build_array(
    'Dr. Mahender Singh is a consultant child specialist and neonatologist who has spent more than four decades caring for children — from the first fragile hours of a newborn''s life through to adolescence.',
    'He completed his MBBS at Sardar Patel Medical College in 1979, returning to the same institution for a Diploma in Child Health in 1983 and an MD in Paediatrics in 1985. In the years since, his practice has centred on neonatal care, routine immunisation, growth and development, and the everyday worries that bring families to a paediatrician''s door.',
    'He practises in both Hindi and English at Child Care, his clinic, and is registered with the Delhi Medical Council.'
  ),
  array['Newborn & neonatal care', 'Child health', 'Immunisation',
        'Growth & development', 'Adolescent health']::text[],
  jsonb_build_array(
    jsonb_build_object('degree', 'MD (Paediatrics)', 'institution', 'Sardar Patel Medical College', 'year', '1985'),
    jsonb_build_object('degree', 'DCH (Diploma in Child Health)', 'institution', 'Sardar Patel Medical College', 'year', '1983'),
    jsonb_build_object('degree', 'MBBS', 'institution', 'Sardar Patel Medical College', 'year', '1979')
  ),
  array['Indian Academy of Paediatrics', 'National Neonatology Forum',
        'Indian Medical Association']::text[],
  array['English', 'Hindi']::text[],
  '42 years in healthcare',
  'Delhi Medical Council — 15446',
  'Child Care',
  0
) on conflict (slug) do nothing;


-- ---- backfill the relation on existing posts -------------------------
-- Matches on the name string ONE LAST TIME, to convert the old scheme
-- into the new one. After this the string match never runs again.
update public.content_posts p
   set author_slug = a.slug
  from public.content_authors a
 where p.author_slug is null
   and lower(trim(p.author)) = lower(trim(a.name));


-- =====================================================================
-- VERIFY
--
--   select slug, name, registration from public.content_authors;
--
--   -- which posts resolved, and which are still plain text
--   select author, author_slug, count(*)
--     from public.content_posts group by 1, 2 order by 1;
--
--   -- an unknown author is now rejected rather than silently unlinked
--   update public.content_posts set author_slug = 'dr-nobody' where false;
--
-- WEBSITE HALF (C:\parentveda-web — a different terminal):
--   * read content_authors from Supabase instead of the AUTHORS array
--   * resolve by post.author_slug, not by matching post.author
--   * DELETE src/lib/authors.ts once it does. Unlike the app, the site
--     has no bundled fallback — a leftover array would look
--     authoritative while changing nothing.
--   * /guides/authors/[slug] currently has dynamicParams = false and
--     generateStaticParams from the hardcoded array; it must flip to
--     dynamicParams = true or a newly added author 404s until the next
--     deploy, which defeats the point of moving the data.
-- =====================================================================
