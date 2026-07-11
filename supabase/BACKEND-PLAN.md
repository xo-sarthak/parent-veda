# ParentVeda — Backend Implementation Plan (store → table)

This is the working reference for migrating the local stores to Supabase. It
holds the **design decisions**, the **table schemas**, and a **progress
checklist**. Migrations live in `supabase/migrations/`; the shared cloud helper
is `lib/services/remote/supabase_repo.dart`.

> Status: **migrations 0001–0008 run; ALL core stores wired to `SupabaseRepo`
> (compile-clean across the whole project).** symptom / calendar / reminders were
> app-tested end-to-end; the rest are compile-verified (app-test deferred).
> **Deferred:** `kegel_history` (no-id append-only log) and `photo_memories`
> (pure-file, no text) → revisit alongside files in Phase 3.
>
> **Known issue (minor):** timestamps are stored as local-time ISO without an
> offset, so when read back from a `timestamptz` column on a *different* device
> they shift by the local UTC offset. Cosmetic for now (the app mostly uses the
> local cache). Fix later by storing UTC (`toUtc().toIso8601String()`).
>
> Next: Phase 1 leftovers (father role/login/sign-out) → pairing → files→Storage.

---

## Design decisions (apply to every data table)

1. **`user_id`** — every data table has `user_id uuid references auth.users(id) on delete cascade`. This is the backbone: it links each row to its owner and powers RLS.
2. **Primary key** —
   - Tables whose model already has a string `id` → **`id text primary key`** (we reuse the app's own client-generated id, so the local cache row and the cloud row share one id → trivial sync).
   - "One row per user" tables (settings-like) → **`user_id` IS the primary key** (use `SupabaseRepo.upsert`).
   - "One row per (user, key)" tables (a value per day, per scan, etc.) → **composite PK `(user_id, <key>)`**.
   - Models with no id (e.g. kegel history) → **`id uuid default gen_random_uuid()`** (server-generated).
3. **Column names** — snake_case (Postgres convention). The app's JSON uses camelCase, so each store gets a tiny camel↔snake map at wiring time (mechanical).
4. **Nested lists / objects** (e.g. a contractions array, kick timestamps, tags) → **`jsonb`** columns, stored exactly as the app already serializes them.
5. **Files on disk** (photos, voice notes) → **`text` URL columns** (or `jsonb` for lists of them). For now they hold whatever the app has; **Phase 3** swaps local paths for Supabase **Storage** URLs.
6. **Every table** also gets: `grant select, insert, update, delete ... to authenticated`, RLS enabled, and 4 own-row policies on `auth.uid() = user_id`. (The GRANT is mandatory for SQL-created tables — skipping it = "permission denied", code 42501.)

## ⚠️ Latent bug found during the scan (flagged, not fixed)

`JournalStore` (`models/journal_entry.dart`) **and** `MemoryStore`
(`models/memory_models.dart`) both persist under the **same** shared_preferences
key `'journal_entries'` with **different** shapes — so on-device they can clobber
each other. In Supabase we model them as **two separate tables**
(`journal_entries` and `weekly_journal_notes`). Worth cleaning up the local
collision separately at some point.

---

## How to run (when you're back)

Run the migration files **in order** in the Supabase SQL Editor (each is a fresh
paste). `0001` is already applied (profiles). Then we wire stores to
`SupabaseRepo` one at a time.

---

## Tables by migration file

### `0002_journal.sql`
- **journal_entries** ← `JournalStore` (rich timeline entry; `id text`). Files: `image_url`, `audio_url`, `image_urls[]`, `audio_urls[]`.
- **weekly_journal_notes** ← `MemoryStore.JournalEntry` (one note per week; `id text`). Files: `photos[]`.
- **photo_memories** ← `MemoryStore.PhotoMemory` (`id text`). File: `path`.

### `0003_trackers.sql` (from `ToolsStore`)
- **weight_profile** — one row per user (PK = user_id). `pre`, `height`.
- **weight_entries** — `id text`. `date_iso`, `time_iso`, `week`, `weight`, `notes`.
- **movement_sessions** — kick tracking; `id text`. `start_iso`, `end_iso?`, `times jsonb`.
- **kegel_state** — one row per user (PK = user_id). counters + adjustments + `this_week jsonb`.
- **kegel_history** — `id uuid` (model has no id). `hold/relax/repetitions`, `feedback` (easy/comfortable/difficult).
- **contraction_sessions** — `id text`. `contractions jsonb` (nested), `labor_response?` (yes/no).

### `0004_daily.sql` (from `DailyStore`)
- **daily_moods** — value per day; PK `(user_id, day)`. `mood_id`.
- **baby_talk** — "Dear Baby" messages; `id text`. `day`, `week`, `prompt`, `text`, `date_iso`, `spoken`.
- **kept_affirmations** — saved strings; PK `(user_id, text)`.
- **daily_movement_responses** — value per day; PK `(user_id, day)`. `response` (yes/not_yet).

### `0005_health.sql`
- **medications** ← `MedicineStore` (`id text`). `type` (supplement/medication/custom), schedule fields, `preset_key?`, dates, `is_active`.
- **medication_logs** ← `MedicineStore` (`id text`). FK `medication_id` → medications.
- **symptom_logs** ← `SymptomStore` (`id text`). `symptom_id`, `date_key`, `severity` (mild/moderate/severe), `notes`.

### `0006_scans_appointments.sql` (from `ScansStore`)
- **completed_scans** — PK `(user_id, scan_id)`. `date_iso`, `notes`.
- **appointments** — `id text`. `title`, `date_iso`, `time`, `location`, `doctor`, `type`, `status`.

### `0007_calendar_reminders.sql`
- **calendar_personal_events** ← `CalendarStore` (only 4 persisted fields). `id text`, `title`, `description`, `date`.
- **reminders** ← `ReminderStore` (`id text`). time fields, `repeat`, `category`, `times jsonb`, `weekdays jsonb`, etc.

### `0008_bump.sql`
- **bump_photos** ← `BumpStore` (`id text`). File: `image_url`. `week_number`, `date`, `caption`, `is_favorite`.

### `0015_whatsapp.sql` (WhatsApp notifications — B1)
- **profiles** (ALTER) — adds `phone`, `language`, `timezone`, `baby_dob`, `wa_opt_in`, `wa_marketing_opt_in`, `wa_consent_at`, `wa_consent_source`. Existing RLS (own + partner select) already covers them.
- **wa_message_log** — one row per attempted send (`id uuid`). Server-written only (service_role); app reads own rows. `template_name`, `category`, `variables jsonb`, `status`, `provider`, `dedupe_key` (partial-unique per user → no double-send).
- **wa_message_templates** — global registry of our Meta templates (`name` PK). `category`, `language`, `variables jsonb`, `body`, `meta_status`. Read-all RLS; seeded with `weekly_guide_en/hi` drafts.
- Note: the send engine (scheduler + sender + webhook) is **server-side** (Edge Function / worker with service_role) — not in the Flutter client, which has no service_role key.

### `0016_whatsapp_scheduler.sql` (WhatsApp notifications — B3, the "who's due" brain)
- **`wa_pregnancy_week(due, as_of)`** — mirrors the app's `currentWeek` (`40 - floor((due-today)/7)`), so WhatsApp and app never disagree.
- **`wa_enqueue_weekly_guide(as_of)`** — the daily brain: finds opted-in mothers (role=mother, phone set, due_date set, week 4–40), inserts one `queued` row per (mother, ISO week) into `wa_message_log`. `security definer`; idempotent via the `dedupe_key` partial-unique index (re-run = 0 new rows). **Enqueues only — does not send.**
- Reconciles the `0015` template seeds to the 2-var MVP shape `["name","week"]` (fruit/rich content deferred; not duplicating the Week Stack).
- Next: **B4** = the sender/drainer (mock first) that reads `queued` rows and marks them; **B5** = `pg_cron` calls `wa_enqueue_weekly_guide()` daily.

### `0017_whatsapp_mock_sender.sql` (WhatsApp notifications — B4, the mock drainer)
- **`wa_render(template, vars)`** — fills a template's `{{1}},{{2}}` from the variables object (position→name→value). Preview/mock only; the real MSG91 send passes values and Meta renders.
- **`wa_message_preview`** (view) — joins log rows to recipient phone/name + rendered text, so you can SEE what would go out.
- **`wa_send_mock()`** — drains all `queued` rows, marks them `mock` (nothing leaves the DB). Mirrors the real sender (B6), which will set `sent` after a successful MSG91 call. Returns count drained.
- Proves enqueue→drain→mark end-to-end for free. Next: **B5** (pg_cron schedule), then **B6** (real sender = Edge Function → MSG91).

### `0018_whatsapp_schedule.sql` (WhatsApp notifications — B5, the daily timer)
- Enables `pg_cron` and schedules **`wa-weekly-guide-daily`** — runs `wa_enqueue_weekly_guide()` at 03:30 UTC (09:00 IST) daily. Named job = upsert (safe re-run).
- Daily (not weekly) on purpose: ISO-week `dedupe_key` caps it at one guide/mother/week, so daily catches new opt-ins and self-heals missed days.
- **Enqueues only** — the sender stays manual (mock) until B6, which gives the real Edge Function its own trigger. Until mothers are opted in, the daily run enqueues 0 rows (armed + waiting).
- Inspect: `select * from cron.job;` / `cron.job_run_details`. Remove: `select cron.unschedule('wa-weekly-guide-daily');`

---

## Progress checklist

Legend: ⬜ todo · 🟦 table created (SQL run) · ✅ wired to SupabaseRepo + tested

| Store / table | Table created | Wired + tested |
|---|---|---|
| profiles | ✅ | ✅ |
| journal_entries | ✅ | ✅ (compile-clean; files→Phase 3) |
| weekly_journal_notes | ✅ | ✅ (compile-clean; files→Phase 3) |
| photo_memories | ⏸️ deferred (pure-file → Phase 3) | — |
| weight_profile | ✅ | ✅ (compile-clean) |
| weight_entries | ✅ | ✅ (compile-clean) |
| movement_sessions | ✅ | ✅ (compile-clean) |
| kegel_state | ✅ | ✅ (compile-clean) |
| kegel_history | ⏸️ deferred (no-id append-only; stats live in kegel_state) | — |
| contraction_sessions | ✅ | ✅ (compile-clean) |
| daily_moods | ✅ | ✅ (compile-clean) |
| baby_talk | ✅ | ✅ (compile-clean) |
| kept_affirmations | ✅ | ✅ (compile-clean) |
| daily_movement_responses | ✅ | ✅ (compile-clean) |
| medications | ✅ | ✅ (compile-clean; app-test deferred) |
| medication_logs | ✅ | ✅ (compile-clean; app-test deferred) |
| symptom_logs | ✅ | ✅ |
| completed_scans | ✅ | ✅ (compile-clean; app-test deferred) |
| appointments | ✅ | ✅ (compile-clean; app-test deferred) |
| calendar_personal_events | ✅ | ✅ |
| reminders | ✅ | ✅ |
| bump_photos | ✅ | ✅ (compile-clean; image→Phase 3) |

## Deferred (post-core)
Saved/liked/bookmark state (reading, videos, can_i, garbh, expert follows,
hospital bag, journey dates), shopping (products/cart/bought/checklists),
community, father side. Same pattern — add when their UI settles.

## Phase 3 — files → Storage (later)
Buckets: `journal-media` (journal images/audio), `memory-photos`,
`bump-photos`. The `*_url` / `photos[]` / `path` columns will hold the Storage
URLs instead of local file paths.
