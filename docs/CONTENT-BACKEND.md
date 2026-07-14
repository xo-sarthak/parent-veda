# ParentVeda — Content Backend & Admin Panel Architecture

> The "content delivery" system: how growing content (articles, recipes, videos, +
> future types) is authored in an admin panel and delivered to the app **without
> shipping an app-store update**. This is separate from the *user-data* backend
> (journals, trackers, health) documented in `supabase/BACKEND-PLAN.md`.
>
> Living doc — updated as we build. Last updated: 2026-07-13.

---

## Why this exists

Today, app content is **bundled JSON compiled into the app binary**. Changing one
word means rebuilding + shipping through the store (days of review; users must
update). This system moves *growing* content onto servers so the app **fetches it
at runtime** — an editor publishes, the user reloads, they see it. No release.

**Fixed content stays bundled** (weekly pregnancy stack, Garbh Sanskar, leap/dev
definitions) — it's a printed book, authored once. Only *growing* content moves:
articles, recipes, videos, and any future type.

---

## The four locked pillars (decided 2026-07-13)

| Pillar | Tool | Notes |
|---|---|---|
| **Content data** (text + references) | **Supabase** (Postgres) | Content tables live beside user-data tables. Public-read of published rows. |
| **Admin panel** (editing UI) | **Directus** (self-hosted) | Free (open-source, <$5M-revenue grant). Runs on a small host (Railway/Render, ~$0–7/mo). Points at Supabase. Only editors use it — **never faces app users**. |
| **Content images** | **Cloudflare R2** (+ Cloudflare CDN) | Chosen while there are ZERO images = zero-migration, permanent. Free egress forever. Directus uploads here (S3-compatible). |
| **Video** | **Bunny Stream** | Transcode + adaptive (HLS) + CDN pipeline, rented. Row stores `video_host` + `video_ref` only — decoupled, host-agnostic. |
| *(User's own media)* | *Supabase Storage* | Private journal/health photos — RLS-protected, already built. NOT part of this system. |

**Key architectural fact:** the app reads content **from Supabase directly**, not
from Directus. So Directus load depends on the number of *editors* (a handful), not
*users* (any number). Directus can be a cheap, sleepy box forever.

---

## Data model — content tables (per-type, shared spine)

Every content table shares a common "spine"; each type adds its own fields.

**Shared spine:** `id`, `status` (draft|published), `domain` (pregnancy|parenting|universal|… — **free text**, so a new app layer is a new tag value with no migration; each app side fetches only its own domain), `title_en`, `title_hi`,
`summary_en`, `summary_hi`, `category`, `tags`, `hero_image` (→ R2 URL), `age_min`,
`age_max`, `featured`, `sort`, `published_at`, `created_at`, `updated_at`.

- **articles** + `body_en`, `body_hi`, `read_mins`
- **recipes** + `ingredients` (jsonb), `steps` (jsonb), `prep_mins`, `cook_mins`, `veg`, `nutrition` (jsonb)
- **videos** + `video_host`, `video_ref`, `duration_secs`, `kind` (short|long), `thumbnail`

**Adding a new type later (extensibility):** 4-step recipe, ~1hr each —
1. create the table (spine + type fields), 2. add published-read RLS,
3. Directus auto-detects it, 4. app: add fetch + store + screen.

---

## The flow — two directions

### A. Editing (content goes IN)
1. Editor (incl. non-technical) logs into **Directus** in a browser.
2. Creates/edits an item:
   - text → row in **Supabase**
   - hero image → uploaded to **R2**, URL stored in the row
   - video → uploaded to **Bunny Stream**, its id pasted into `video_ref`
3. Sets **Status = Published**, saves.
4. Done — no code, no developer, no app release.

### B. Delivery (content comes OUT to the app)
1. App opens / user pulls to refresh.
2. App fetches published rows from **Supabase** (incremental via `updated_at`).
3. App **caches** locally → instant load + offline.
4. Images: app loads the R2 URL → **Cloudflare CDN** serves (edge-cached) → device caches.
5. Video: app takes `video_ref` → **Bunny Stream** streams adaptively (HLS) via its CDN.
6. User sees new/updated content — **no app-store update**, because content is fetched at runtime, not compiled in.

```
EDITOR → Directus → (text→Supabase | image→R2 | video→Bunny) → Publish
APP ← Supabase (text+refs, cached) ← R2/CDN (images) ← Bunny/CDN (video)
```

---

## Build phases

- **P1 — Articles, end to end** (keystone): `articles` table + RLS + app fetch/cache/offline engine + switch article screens. Seed via SQL first.
- **P2 — Stand up Directus** (self-hosted on Railway/Render, pointed at Supabase; storage → R2).
- **P3 — Recipes** (copy the pattern).
- **P4 — Videos** (`video_ref` + Bunny).
- **P5 — Document the add-a-type recipe.**

---

## What scales vs. what's permanent

Scaling = turning dials on the SAME design, never rebuilding:
- Supabase: bump compute tier as users grow.
- Images: R2 is already free-egress; *add* Cloudflare Images (auto-resize) if wanted — same URLs.
- Video: Bunny cost grows with watch-time (the main variable).
- Directus: unchanged — never faces users.

This is the entry-tier of the industry-standard "three pillars" (headless CMS +
image storage/CDN + video pipeline). Big companies do a pricier version of the
same shape (Contentful/Sanity + Cloudinary/imgix + Mux). Same architecture,
right-sized.

---

## Status

- 2026-07-13: architecture finalized (this doc).
- 2026-07-14: **Phase 1 DONE (migration run).** `0019_articles.sql` = articles table + `domain` tag + public-read RLS + 6 pregnancy articles seeded. `ContentRepo` + `ArticleStore` (cache/offline, bundled fallback). Pregnancy weekly-reads carousel now reads from the DB. Parenting "Learn" not wired yet (later phase).
- 2026-07-14: **Phase 2 DONE — Directus LIVE.** Self-hosted Directus (Core/free) on Render (free tier, image `directus/directus:latest`), connected to Supabase via Session-pooler env vars. `articles` registered as a collection; editing title/body → app shows it. Admin at `https://parentveda-cms.onrender.com/admin`. (Gotcha: blank admin in normal browser = ad-block extension; use incognito or whitelist.)
- 2026-07-14: **Refresh added** — `ArticleStore.refresh()` → pull-to-refresh (View-all reads) + app-resume (MainScaffold lifecycle), so edits appear without a relaunch.
- Next: recipes / videos content types · parenting "Learn" wiring (`domain='parenting'`) · images → R2.
