-- =====================================================================
-- 0019_articles.sql — the FIRST content table (growing content).
-- ---------------------------------------------------------------------
-- This is the content-delivery backend (separate from the user-data
-- tables 0001-0018). Content is authored in the admin panel (Directus,
-- Phase 2) and served from here; the APP only READS it, DIRECTLY from
-- Supabase (not via Directus). See docs/CONTENT-BACKEND.md.
--
-- Access model (mirror-image of the user tables):
--   user data  = per-user, own-row-private, edited via the app
--   content    = PUBLIC-READ of published rows, admin-write only
-- Writes come from Directus / the service role (which bypasses RLS);
-- the app (anon/publishable key) can only SELECT published rows.
-- =====================================================================

create table public.articles (
  id           uuid        primary key default gen_random_uuid(),
  status       text        not null default 'published',  -- draft | published
  domain       text        not null default 'pregnancy',  -- pregnancy | parenting | universal | <future>
                                                           --   FREE TEXT on purpose: a new app layer is just a new
                                                           --   tag value, no schema change. Each app side fetches its own.
  week         int,                                        -- week-targeted (null = general / parenting)
  emoji        text        not null default '',
  title        text        not null,
  title_hi     text,                                        -- bilingual-ready (filled later)
  read_mins    int         not null default 3,
  body         text        not null,                        -- paragraphs split by a blank line
  body_hi      text,
  category     text,
  hero_image   text,                                        -- R2 URL (later)
  sort         int         not null default 0,              -- order within a week
  published_at timestamptz not null default now(),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

alter table public.articles enable row level security;

-- Public read of PUBLISHED rows only (content is the same for everyone; no
-- login required — the app reads with the anon/publishable key). Drafts stay
-- hidden. There are NO insert/update/delete policies: writes happen only via
-- Directus / the service role, which bypasses RLS.
create policy "articles public read"
  on public.articles for select
  to anon, authenticated
  using (status = 'published');

grant select on public.articles to anon, authenticated;

-- ---------------------------------------------------------------------
-- Seed: the existing bundled "This week's reads" (weeks 20 & 21) so the
-- app shows identical content, now served from the DB. Future articles
-- are added in Directus. (Bundled copy in lib/data/week_articles_data.dart
-- stays as the offline/first-run fallback.)
-- All seeds are domain='pregnancy' (via the column default) — parenting
-- reads will be added later as domain='parenting' rows in this same table.
-- ---------------------------------------------------------------------
insert into public.articles (week, emoji, title, read_mins, sort, body) values
(20, '🎉', $$You're halfway there$$, 3, 1, $$Week 20 - you've reached the halfway mark. It's a lovely moment to pause and take it in: from a single cell to a fully-forming little person, in just twenty weeks.

Your baby is now around the length of a banana - roughly 25 cm from head to heel - and weighs about 300 grams. Fine hair, tiny eyebrows, and even the ridges of fingerprints are forming. They're swallowing small amounts of amniotic fluid, practising for feeding, and settling into cycles of sleep and wakefulness.

For you, this is often the most comfortable stretch of pregnancy - the early tiredness has usually eased, and the bump is proudly showing but not yet heavy. Enjoy it. Take the photo, note how you feel; halfway is worth marking.$$),

(20, '🩺', $$The anatomy scan, explained$$, 4, 2, $$Around now, most mothers have their mid-pregnancy scan - often called the anatomy or anomaly scan. It's usually the most detailed look at your baby in the whole pregnancy, so it's normal to feel both excited and a little nervous.

During it, the sonographer checks your baby's growth and carefully examines the developing organs - the heart, brain, spine, kidneys and more - along with the placenta, the fluid around the baby, and the umbilical cord. It's a thorough, reassuring check that everything is coming along as expected. In many places this is also the scan where you can find out the baby's sex, if you'd like to.

It can take a while, and the sonographer may go quiet as they concentrate - that's routine, not a warning sign. Bring your partner if you can; it's a special one to share. And if the results raise any questions, your doctor will walk you through them - that's exactly what they're there for.$$),

(20, '🍎', $$Eating well in the second trimester$$, 4, 3, $$If your appetite is bouncing back after the queasy early weeks, you're right on time. The second trimester is when many mothers feel more like themselves again - and when your baby is growing fast, so good nourishment matters more than ever.

A few things your body especially needs now: iron, to build your baby's blood supply and keep your energy up (lentils, leafy greens, dates, and lean meat if you eat it); calcium, for those developing bones (milk, yoghurt, paneer, ragi, sesame); and some protein at most meals to support all that growth. Keep water close by - staying hydrated eases many second-trimester niggles.

You don't need to "eat for two" in quantity - just aim for steady, varied, colourful meals. If heartburn creeps in, smaller and more frequent meals help more than large ones. And if you follow a specific diet or have any condition, your doctor or a nutritionist can help you tailor this to you.$$),

(21, '👂', $$Your baby can hear you now$$, 3, 1, $$Around this week, your baby's hearing is coming alive. The tiny bones and nerves that carry sound have formed enough to pick up noises from the world around them - and the one they hear most clearly is you.

Inside, it's far from silent. Your baby is surrounded by the steady thump of your heartbeat, the rush of blood, the gurgle of digestion, and - muffled but real - the sound of your voice. Over the coming weeks they'll begin to recognise it, which is why newborns so often calm at the very voice they heard before birth.

You don't need to do anything special. Talk about your day, read a few lines aloud, hum a song you love. It all reaches them - and it's the start of a conversation that lasts a lifetime.$$),

(21, '🦶', $$Those first flutters and kicks$$, 3, 2, $$Somewhere around now, many mothers feel their baby move for the first time - a moment called "quickening." It rarely feels like a kick at first. Most describe it as bubbles, a flutter, a little pop, or even the feeling of gas - easy to miss, and easy to fall in love with once you notice it.

Early movements come and go without any pattern, and that's completely normal this week. Your baby is small and has plenty of room, so they may be busy one hour and still the next. If this is your first pregnancy, it can take a little longer to recognise the feeling - don't worry if a friend felt it sooner.

As the weeks pass, those flutters grow into unmistakable kicks and rolls. For now, simply enjoy them. And if you ever notice a clear change in your baby's usual movements later in pregnancy, check in with your doctor or midwife - they'd always rather you asked.$$),

(21, '🍎', $$Eating well in the second trimester$$, 4, 3, $$If your appetite is bouncing back after the queasy early weeks, you're right on time. The second trimester is when many mothers feel more like themselves again - and when your baby is growing fast, so good nourishment matters more than ever.

A few things your body especially needs now: iron, to build your baby's blood supply and keep your energy up (lentils, leafy greens, dates, and lean meat if you eat it); calcium, for those developing bones (milk, yoghurt, paneer, ragi, sesame); and some protein at most meals to support all that growth. Keep water close by - staying hydrated eases many second-trimester niggles.

You don't need to "eat for two" in quantity - just aim for steady, varied, colourful meals. If heartburn creeps in, smaller and more frequent meals help more than large ones. And if you follow a specific diet or have any condition, your doctor or a nutritionist can help you tailor this to you.$$);
