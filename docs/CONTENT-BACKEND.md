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
- 2026-07-14: **Web content tables added** — `0020_web_content.sql` = `content_categories` (5 seeded) + `content_posts` (SEO-rich; modeled 1:1 on the website's `src/lib/guides.ts`; body/recipe/source/book_meta stored as jsonb so the site's renderer is unchanged; + verdict/trimester/week_tag/og_image/meta_title SEO fields). Public-read RLS. For the ParentVeda WEBSITE (Next.js, separate repo `C:\parentveda-web`, Tailwind/App-Router/static-export → moving to Vercel + ISR). Same Supabase, same Directus. App `articles` and web `content_posts` are SEPARATE tables in one project.
- 2026-07-14: **Web content wired in Directus** — `content_posts` + `content_categories` registered as collections; `body` recreated as a **Markdown** field (was jsonb → column altered to `text`, migration 0020 updated to match); a test blog published OK. Deferred: a clean field-polish pass (proper category/status dropdowns — snagged live on text-vs-string type + RLS/FK deps).
- 2026-07-14: **Website wiring handed off** — website terminal (`C:\parentveda-web`) wiring Next.js to read `content_posts`/`content_categories` live from Supabase, body → markdown renderer, remove `output:'export'` → **Vercel + ISR** (`revalidate`, `dynamicParams=true`), migrate the 10 sample `guides.ts` posts in. Old GitHub Pages deploy workflow disabled (kept for revert). User does the Vercel deploy (guided from here).
- 2026-07-14: **AskVeda RAG chatbot handed off** — separate terminal building a FastAPI RAG service (Groq/Together open-LLM, bge/MiniLM embeddings, Chroma, Supabase+pgvector `veda_cache`, Directus content as the knowledge base, app + inbound-WhatsApp channels reusing the MSG91 number). Ingests from `articles` + `content_posts`.

## Parallel workstreams (2026-07-14) — 4 terminals, one shared Supabase + one shared Directus

1. **This terminal — content-system hub.** Owns migrations `0019` (articles) + `0020` (web content). App content backend + Directus + web content tables DONE. Guides the Vercel deploy.
2. **Website terminal** (`C:\parentveda-web`, Next.js) — wiring the site to read content live from Supabase, Vercel + ISR.
3. **Parenting-backend terminal** (app repo) — Supabase persistence for post-pregnancy **USER DATA** (child profile / health / vaccinations / trackers), migrations `0021+`. This is user data, NOT admin-panel content. (Parenting *content* — articles/recipes/videos — is separate and rides the same `articles` table via `domain='parenting'` + Directus.)
4. **AskVeda/WhatsApp terminal** (own repo) — the RAG chatbot backend; reads the shared content.

Migration-number reservation: `0019` articles, `0020` web content (this terminal); parenting starts at **`0021`**; AskVeda's `veda_cache` is a uniquely-named table in its own repo (no number clash).

**Key insight:** one Directus → feeds the app, the website, AND the chatbot. Publish once, everywhere reads it.

---

## AskVeda — the RAG chatbot backend (architecture & learning)

> Added 2026-07-16. AskVeda is being rebuilt from the offline retrieval engine into an **AI chatbot** that answers pregnancy/parenting questions **grounded in this project's own content**, on **two channels: the app and WhatsApp**. It's a NEW, standalone service (own repo `C:\Projects\parentveda-askveda`) that shares only the Supabase DB + Directus — it never touches the app/website code.
>
> **Deep, build-along learning notes (phase by phase) live in the AskVeda repo: `parentveda-askveda/askveda.md`.** This section is the brief; that file is the detail.
>
> **Build progress:** Phase 0 DONE (2026-07-16) — FastAPI skeleton + typed config + `/health` (verified 200 locally). Phase 1 DONE — `veda_setup.sql` run in Supabase: pgvector on + 3 `veda_*` tables live, service_role granted. Phase 2 DONE (2026-07-20) — ingestion pipeline (`db.py`/`embeddings.py`/`chunker.py`/`ingest.py`): fetch published `articles`+`content_posts` → chunk → embed (bge-small, 384-dim, self-hosted CPU via fastembed) → upsert; **19 chunks live in `veda_content_chunks`, verified**. (Model download was ISP-blocked from HuggingFace; fetched once over a VPN, now cached/offline.) Phase 3 DONE (2026-07-20) — retriever + grounded prompt + LLM: `veda_match_function.sql` (pgvector RPC using the HNSW index) + `retriever.py`/`prompt.py`/`llm.py` (OpenAI-compatible client → **Groq `llama-3.1-8b-instant`**) + `scripts/ask.py` CLI. **Verified end-to-end**: grounded hit (anatomy scan, sim 0.73), honest miss (stroller brand → "I don't have that", no hallucination), verdict (papaya → ripe-in-moderation). Token counts captured for Phase 4 cost logging. Phase 4 DONE (2026-07-20) — cache + guardrails + usage log: `veda_cache_function.sql` (semantic-cache RPC) + `cache.py` (exact→semantic ≥0.95, week_key safety, verdict/dosage exact-only) + `guardrails.py` (keyword red-flag routing, 20/day rate limit, global spend cap) + `usage.py` (logs every call to `veda_usage_log`) + `answer.py` (the one-brain orchestrator: rate→spend→red-flag→cache→retrieve→confidence-floor→LLM→store+log). **Verified**: exact + semantic cache hits ($0), red-flag routing, off-topic decline, cost logged (~₹0.01/answer). Phase 5 (app door) DONE for the PARENTING screen (2026-07-20) — backend: `channels/app_api.py` (`POST /ask`) + `auth.py` (Supabase JWT → user_key, dev fallback) + CORS + pyjwt (verified over curl: llm / cache:exact / X-User-Key). App side (THIS repo): new `lib/ask_veda_config.dart` (base-URL const) + `lib/services/remote/ask_veda_service.dart` (graceful null-on-failure) + `http` dep; wired `lib/screens/post_pregnancy/askveda_screen.dart` offline-first-then-augment (swap in grounded answer only when confident; verified tick; stale-guard). analyze clean, **173 tests pass**. Pregnancy flagship `ask_veda_screen.dart` NOW WIRED too (S1 card = children[0] in all 3 answer paths → swap only that slot; calls with domain:'pregnancy'+week so it lights up). Both screens done, analyze clean, Ask Veda tests green. **"ONE MOTHER, ONE JOURNEY" batch DONE (2026-07-21)** — no domain gating anywhere (the mother is one person across pregnancy→parenting; the assistant must never lose knowledge she already had); seeded showcase answers demoted from hardwired answers to ordinary content; answers now come from ONE source (RAG + cache) on both sides, fixing the same-question-two-answers inconsistency. Added: `veda_content_gaps` (+ `NO_ANSWER` sentinel so unanswerable questions are logged with an ask_count = the content to-do list), stage-bucketed cache (`pw24`/`cm3` — T1 vs T3 get different correct answers), stage-as-CONTEXT prompt (correct past/present/future tense), no-cache for personal-data questions. **Content migration**: `tool/export_veda_corpus.dart` (this repo) → `veda_knowledge` table → **927 chunks (831 pregnancy + 83 parenting), up from 19** — the parenting side finally grounds on its own knowledge. Community excluded; Hinglish stored but not embedded yet. **Phase 6 (WhatsApp door) DONE (2026-07-21)** — `app/gateway.py` (`IncomingMessage` + `parse_msg91_inbound`, the one internal shape both channels normalize into) + `app/channels/whatsapp.py` (`POST /whatsapp/webhook` + `send_whatsapp_message`, MOCK by default until the MSG91 number is live) + both doors mounted in `main.py`. `user_key` = `wa:<phone>` (no login on WhatsApp); shared-secret header guards the public URL; always returns 200 (else the provider retries and she gets the answer twice); delivery/read receipts arrive on the same URL and are ignored. Verified on simulated payloads (real question answered + reply sent, receipt ignored, alternate payload shape parsed) — **and both answers came back `cache:exact`, i.e. the cache is shared ACROSS channels**. Known gap: WhatsApp has a phone number, not an app profile, so no stage-aware tense until phone↔profile linking exists (the fields are already plumbed). **Phase 7 (trusted-web fallback + flywheel) DONE (2026-07-22)** — `app/web_fallback.py` (Tavily search restricted via `include_domains` to a WHITELIST: NHS/ACOG/WHO/Mayo/AAP/HealthyChildren + NHP/ICMR/FOGSI — never the open web) + `app/flywheel.py` + `sql/veda_drafts.sql` (review inbox: question, draft body, **source URLs**, status `pending`) + `prompt.build_web_messages` (must name its source) + both gap paths in `answer.py` now try the web before dead-ending. Web answers are cached, so the expensive path is **self-extinguishing**. **Never auto-publishes medical content** — drafts get their OWN table (not `articles` with status=draft) for safety/ownership/audit; register it in Directus as an "AI drafts" inbox. Degrades safely with no Tavily key. Also fixed 2 real prompt bugs found in testing: the model **invented a stage** when none was given ("since you've already had your baby" — upsetting if she's pregnant), and **over-applied the past-tense rule** to non-pregnancy questions. **VERIFIED WORKING (2026-07-22)** — obstetric-cholestasis question (absent from our content) → `source=web`, cites bhrhospitals.nhs.uk + fogsi.org + buckshealthcare.nhs.uk, ~₹0.006. Three bugs found by running it: gap detection was broken (model ignored the `NO_ANSWER` sentinel and wrote padding + "the content doesn't mention X" → now 3 detectors incl. prose forms); conversational queries wreck web search ("what is X?" returned YouTube/WhatsApp; keywords returned the right NHS leaflets → query lead-ins now stripped); and **`include_domains` returned off-whitelist domains anyway → we now re-check every URL's hostname ourselves** (the provider's filter is a request, our check is the guarantee). Tavily auth = `Authorization: Bearer` header. STILL PENDING: run `sql/veda_drafts.sql` (answers work without it; only the editorial draft can't be saved). **Phase 8 (reindex/benchmark/observe) DONE (2026-07-22)** — `ingest.py` refactored + `reindex_source(table,id)`; `POST /reindex` (incremental one-row OR full-in-background; accepts our `{source_table,source_id}` AND Directus `{collection,keys}`) closes the flywheel loop so a Directus publish auto-refreshes search; `GET /metrics` + `app/metrics.py` + `scripts/metrics.py` (cache-hit rate, cost/answer, today's spend, web-fallback rate, top gaps = content to-do list, top cached = FAQs); `scripts/benchmark.py` compared Groq models on real questions → **kept `llama-3.1-8b-instant`** (concise/accurate/~₹0.004 vs verbose 20B ~₹0.02, rich 70B ~₹0.05; qwen-27B is a reasoning model, dropped). Both endpoints guarded by `reindex_secret`. Live so far: 31 answers, 25.8% cache-hit, total ₹0.09. Next: Phase 9 = deploy to Render (public HTTPS URL → point app baseUrl + MSG91 webhook at it). Next: Phase 8 = `POST /reindex` (Directus publish → refresh vectors, closing the flywheel loop), model benchmark, cache-hit-rate/cost reporting.

### The core idea: one brain, two doors
AskVeda's logic lives in **exactly one place — an always-on server**. The app and WhatsApp are just two **doors** into that same brain; neither client contains any RAG logic.
- **App door** = ~30 lines of Dart: a chat screen that POSTs the question and shows the answer.
- **WhatsApp door** = zero app code: user texts the number → MSG91 forwards it to the service's webhook → the service replies via MSG91.
- **The service** = 100% of the intelligence (embeddings, retrieval, prompt, LLM, cache, guardrails).

A **Message Gateway** normalizes both channels into one internal format so they run the **exact same code path** — identical functionality, two entry points.

### Why a separate repo + an always-on server (the "why live")
A static site can be served half-asleep (just files). AskVeda must **do work in the moment, per question** (embed → search → LLM → format) *and* **receive pushes** (WhatsApp shoves an inbound message at the webhook at any second — something must be listening 24/7) *and* hold **secrets** (Groq key, Supabase service_role) that can't ship in an app binary. A laptop can't be the public always-on host; a server can. Hence: its own repo, deployed to an always-on server.

### Render vs Directus — software vs host (the money question)
- **Directus** = admin-panel *software* (open-source). Self-hosting is **free forever**. It runs *on* a host.
- **Render** = the *host* (the machine). This is the only thing with free/paid tiers; one Render account runs multiple services.

| Service on Render | Tier | Why |
|---|---|---|
| **Directus** | **FREE** | Only *editors* use it, and the app/site/AskVeda read content from **Supabase**, not Directus — so if Directus sleeps, users feel nothing (only the editor logging in waits ~40s). |
| **AskVeda** | **PAID (~$7/mo ≈ ₹600)** | *Users* hit it live; a cold-start (sleep → 30–50s wake) breaks chat and drops WhatsApp webhooks. The ₹600 buys "no cold starts." |

So you pay for **one** always-on service (AskVeda). Directus stays free.

### The RAG flow
**Ingestion (offline/batch — not in the request path):**
`articles` + `content_posts` (published) → chunk → embed (bge/MiniLM, self-hosted CPU, free) → store vectors in **Supabase pgvector**. Re-index fires on a **Directus webhook** at publish (+ a manual full re-index script).

**Live request (per question):**
```
app | whatsapp → GATEWAY (normalize)
   → guardrails (scope · red-flag · rate limit · spend cap)
   → CACHE (pgvector: exact → semantic ≥0.95)  ── hit → return, no LLM (₹0)
   → RETRIEVE (embed Q → pgvector top-3 chunks)
   → PROMPT (chunks + Q + "answer ONLY from this")
   → LLM (Groq, open model)
   → RESPOND (format → cache it → route back to the door)
```
The LLM does **reading-comprehension + phrasing**, never fact-recall — every fact comes from our reviewed content.

### The three answer cases
- **A — we have it:** retrieval scores high → grounded answer in our voice. ~$0.00012 ≈ **₹0.01**.
- **B — we don't have it:** scores low → skip the LLM, honest "I don't have that answer," **log the gap**. ~₹0.
- **C — hybrid (the enhancement):** a genuine pregnancy/parenting question we lack → search a **whitelist of trusted sources** (NHS/ACOG/WHO/Mayo/AAP + Indian NHP/ICMR/FOGSI) → answer from *those*, labelled honestly, with a gentle doctor note. ~$0.003–0.005 ≈ **₹0.25–0.45**, rare, and self-extinguishing (see flywheel).

### The content flywheel (self-improving)
Case C doesn't just answer — it **grows the content pool**:
1. **Log every gap** → a ranked, demand-driven content backlog ("41 mothers asked X, we have nothing").
2. **Auto-draft into Directus** as `status=draft` "AI-drafted, needs review" — **never auto-publish medical content**; an editor reviews → publishes.
3. Once published, that question becomes a **Case A** next time (cheap, grounded, ours). So the expensive web path **shrinks over time by design.**

### Safety (health domain)
- Grounded-only; "I don't have that" instead of inventing.
- **Gentle red-flag routing** (bleeding, severe pain, reduced movement) → skip RAG, calm "please check with your doctor" — **no alarm styling; don't scare users.**
- The `verdict` field (`yes|moderation|avoid-some|avoid`) surfaced explicitly for "Can I…?" questions.
- **Cache safety:** answers are **week/trimester-sensitive** ("X at week 8" ≠ "week 30" but they embed alike) → threshold 0.95 + week/trimester folded into the cache key + verdict/dosage = exact-match only.

### Cost model (the whole thing in one line)
```
monthly = (messages × cache-MISS-rate × ₹0.01) + ₹600 Render + (rare web-fallback)
```
The LLM is **a paisa an answer** (an 8B open model is ~50–100× cheaper than a frontier model), so the bill is driven by **volume × cache hit rate**, not model choice. The real risks are **abuse** (→ 20/day per-user limit + global daily spend cap / circuit-breaker) and cache-hit-rate (instrumented from day one). Whole-stack fixed cost: Supabase/Directus/website **free**; only AskVeda's Render (~$7 ≈ ₹600/mo) is paid.

### Locked decisions
Own repo `C:\Projects\parentveda-askveda` · **pgvector for both** index + cache (Chroma dropped — Render's disk is ephemeral) · **Groq** (Together = config swap) · benchmark Qwen-7B vs Llama-8B · Directus-webhook re-index · **app door first** (built + tested locally, free) with the **WhatsApp webhook scaffolded** until MSG91/Meta is live · gentle safety · 20/day + global cap.

### Status
Planned, nothing built yet. **Development is 100% free/local** (Supabase service_role key is free from the dashboard; Groq has a free tier; the laptop is the dev server). The three paid/external things — **Render paid, MSG91 key, Meta verification** — are needed only at **go-live**, at the end.

## Next (this terminal)
- Guide the **Vercel deploy** once the website terminal finishes.
- Then, app content when wanted: recipes / videos content types · parenting "Learn" wiring (`domain='parenting'`) · images → Cloudflare R2 · the deferred Directus field-polish pass.
