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

## The PARENTING (post-pregnancy) side — from `0021`

> Status: **`0021`–`0026` APPLIED (19 July 2026).** All 14 parenting tables
> exist with RLS, grants and 4 policies each; `public.my_child_ids()` is live.
> Client wiring is in and compile-clean (359 tests). **Not yet exercised against
> the real database** — see "Verifying" below for the order things must happen
> in (sign in → save a child → everything else keys to it).

Everything above is the pregnancy side. The parenting side starts at `0021` and
follows the same rules with **one deliberate deviation**, below.

### `0021_children.sql` — the keystone
- **children** ← `ChildProfileStore` (`id text`). `name`, `is_boy`, `dob`, plus
  flagged mirror columns `weight_kg`/`height_cm`/`head_cm`.
- **`public.my_child_ids()`** — every child the caller may touch (own +
  partner's). THE access key for every child-scoped parenting table:
  `using (child_id in (select public.my_child_ids()))`.

### Deviation: CO-PARENTING (decided 2026-07-14)
Pregnancy rule: a row is yours; your partner may only **read** it
(`0012_share_scans.sql`). That fits — the parents use different interfaces and
the data is personal ("my symptoms", "my journal").

Parenting rule: the app shows **both parents the same screens for the same
baby**, so **either parent may read AND write** the child's data. Therefore:

- **`user_id` on a parenting table is ATTRIBUTION** ("Dad logged this"), *not*
  the access key. Access runs through the **child**.
- **One child row per baby, not one per parent.** If each parent had their own
  row, their `child_id`s would differ and every feed/vaccine/measurement would
  fragment into two sets that never join.
- `SupabaseRepo` gained co-parented variants — `fetchShared`, `fetchByChild`,
  `updateShared`, `deleteShared` — which drop the `.eq('user_id', uid)` filter
  and let RLS scope the rows. **Child-scoped tables only.** Pregnancy tables and
  all `user_state`/KV stores keep the own-user methods.
- **KV/preference stores stay own-only.** Saved lists and prefs are personal.

### `0022_pp_health.sql` — the child's health record
Seven child-scoped, co-parented tables ← `HealthStore`: `pp_medications`,
`pp_prescriptions`, `pp_allergies`, `pp_symptoms`, `pp_reports`,
`pp_doctor_visits`, `pp_doctor_questions`. All gate on
`public.my_child_ids()`. Medication reminder fields are persisted (fixes half
of flag #4). `report_values`, not `values` — the latter is a reserved keyword.

**SEED DATA DECISION (18 July 2026).** The health collections used to start as
copies of `kMedications` / `kAllergies` / `kReports` / `kPrescriptions` /
`kSymptoms`, so persisting them naively would have written **a fictional
child's medications and allergies into every real account** as genuine medical
records — exactly the failure BACKEND-PARENTING-BRIEF §5 warns about. Resolved
with the **empty-id rule**: seed rows carry `id == ''` and are never uploaded;
a parent's row gets a real client-generated id. The store's lists now start
EMPTY, so a parent who has entered nothing sees the invitation state
(`health_records_screen.dart:185` renders an "Add …" CTA — the never-hidden
invariant holds). The seed constants stay in the file as demo/reference.

Side effect: **`hasAnyEntry` now works.** It was true at launch for everyone,
because `_reports` was seeded non-empty — so the flag meant to detect "has she
entered anything" always answered yes. The AI-insights card it gates
(`health_home_screen.dart:537`) correctly stays hidden until there is something
real to comment on, which is what its own comment always claimed it did.

### `0023_pp_growth_vax.sql`
- **pp_growth_measurements** ← `GrowthStore`. The intended single source of
  truth for growth (flag #1).
- **pp_vaccine_doses** ← `VaxStore`. Composite PK `(child_id, vaccine_id)`;
  carries both `done` and `reminder`, so marking is an idempotent upsert.
  Persisting `reminder` closes flag #4.

### `0024_pp_feed_sleep.sql`
- **pp_feed_logs** / **pp_sleep_logs** ← `FeedingStore` / `SleepStore` (the
  Journey tools). Highest-write tables in the app. `PpTrackerStore` gets NO
  table — its screens are retired and unreferenced; two tables for one event
  would fork the history.

### `0025_pp_milestones.sql`
- **pp_milestone_observations** ← `MilestoneStore`. Composite PK
  `(child_id, milestone_id)`. Keepsake data — `note` holds the memory.

### `0026_pp_documents.sql`
- **pp_documents** ← `BabyDocumentsStore`. Rows sync; **files do not yet**
  (flag #5) — `attachments[].path` is still a device temp path until
  StorageService is wired in.

### `0027_pp_name_votes.sql` — baby-name matching between paired parents
One row per (parent, name), `liked` false = an explicit skip. PK
`(user_id, name)` so a re-swipe upserts.

**COUPLE-scoped, not child-scoped** — a deliberate change from
BACKEND-COUPLE-NAMING-BRIEF §4. Its `child_id uuid references children(id)`
would fail outright (`children.id` is TEXT), but the deeper reason is that the
name generator has nothing to do with the child record: it is a standalone
tool that also runs on the pregnancy side, where no child exists. Child-scoping
would have made it silently do nothing for the couples most likely to use it.
The chosen name never writes to `children.name`.

**RLS is own-rows-only in every direction, including SELECT** — stricter than
§4, which widens SELECT to the partner. That would hand the client exactly what
§5 forbids: the partner's individual votes. Matches instead come from
`public.pp_name_matches()`, a `security definer` function returning only the
intersection. The independence the feature depends on is enforced by Postgres,
not by client discipline — there is no query that answers "what did my partner
like?" for an unmatched name. Unpaired → no partner → empty result, and solo
use keeps working.

Client: `NameMatchStore` likes are votes now (the KV blob keeps only the crown,
with a one-time adopt of any pre-existing `liked` so no shortlist is lost);
`matchedCount` finally reads the intersection rather than her own list.

**Seeded likes removed.** The store shipped six liked names and a crowned
"Aarav" — harmless while likes were private, actively wrong once votes are
compared: two accounts starting from the same six seeds would "match" on all
six before either parent swiped. Also fixed: `babyNameByName('')` falls back to
the first catalogue entry, so an uncrowned parent was shown a stranger's name
under "Your favourite", and the header read "You & Ravi" — an invented partner.

### `0028_profile_events.sql` — the analytics sink (write-only)
Behavioural events from the progressive-profiling strips on BOTH sides of the
app. A NEW RLS shape: **insert-only, never readable.**
- **No `user_id`** — keyed to an anonymous `install_id` (pre-auth); join to a
  real user server-side later.
- **INSERT** granted to `anon` AND `authenticated` (the strips run logged-out).
- **SELECT/UPDATE/DELETE**: no policy at all → RLS denies them. Reads happen
  only from the dashboard under `service_role` (bypasses RLS).
- Two gotchas that would fail at runtime: `bigserial` needs `grant usage on
  sequence …_id_seq` or the insert's `nextval()` is denied; and the client must
  NOT chain `.select()` (uses `return=minimal`), else PostgREST needs SELECT and
  the insert-only contract breaks the call.

Client: seam already existed. `SupabaseProfileSink`
(`lib/services/remote/supabase_profile_sink.dart`) implements the backend-blind
`ProfileAnalyticsSink`; `SupabaseRepo.fireEvent` is a fire-and-forget insert
with no `user_id` and no row read-back; wired in `main.dart` with one
`setSink(const SupabaseProfileSink())`. `meta` is stripped (no such column;
enum labels only, so no free text leaks).

### Light (Tier 2) stores — NO migration needed
`DevStore`, `FoodStore`, `WatchStore`, `ReadingStore`, `RecoStore`,
`YogaStore`, `NameMatchStore` now use `CloudSyncedStore` over the existing
`user_state` table (0011), where own-only RLS is correct: a saved recipe or a
reading position is personal, not shared with a partner.

`CloudSyncedStore` gained an opt-in `cloudPushDebounce` (defaults to
`Duration.zero`, so every existing pregnancy store is unchanged). `WatchStore`
sets 5s: it records playback position on every tick, which would otherwise be
one Supabase write per tick.

### ⚠️ New flag — Tier-2 seed state
The light stores are also seeded (`_saved = {'tummytime', 'q_iron'}`, six liked
names, pre-filled wishlists). Unlike health this is low-stakes — starter
content, not fabricated medical records — so it is synced as-is rather than
emptied. Worth a product call on whether a new parent should start with
pre-saved items she never chose.

### Other decisions
- **Journey stores are the real ones.** `FeedingStore`/`SleepStore` (Tools →
  Feeding/Sleep journey) get tables. `PpTrackerStore` backs the retired
  `FeedingTrackerScreen`/`SleepTrackerScreen`, which nothing links to any more →
  **no backend**.
- **Journals stay separate.** Pregnancy journals are untouched; the parenting
  journal is a NEW shared book from birth, co-editable, with an **author column**
  (cheap now, unrecoverable later — otherwise the storybook can never say "Dad
  wrote this").
- **Seeded "Aarav" is never written to the DB** — it's a placeholder until a
  parent saves real details, mirroring the week-20 no-due-date default.

### The no-invented-data rule (19 July 2026)

**Data about the child comes from the parent, and only from the parent.** If she
has not entered something, the app says so and invites her to — it never shows
our demo child's figures as if they were hers.

Done in this pass:
- **Doctor Record** — was the worst case: a fictional name, birth date, **blood
  group**, "13 of 18 vaccines given", a const growth measurement and a seeded
  illness list, on a screen called "Doctor-ready record" and a Share button.
  Now reads the real child, real marked doses, real measurements, her own logged
  symptoms; empty sections say "None recorded". Blood group shows only if she
  entered one.
- **Vaccinations** — `VaxStore._done` no longer seeds from the schedule's own
  `status`. A dose is done only when SHE marks it; a schedule entry that claims
  "done" now reads as **due** for her (true, and an invitation to record it).
- **Health snapshot** — the four tiles were const verdicts ("Overall: Healthy",
  "Up to date"). Derived now; unknown reads "Not recorded".
- **Growth screens** — read `GrowthStore`, not `const kGrowth`. Charts need ≥2
  real points; centiles appear only with a real measurement.
- **The child's name and gender** — `Aarav` and `his` were hardcoded in ~90
  places. Screens interpolate the active child; bundled `const` content uses
  placeholders (`{child}`, `{they}`, `{their}`, `{them}`) filled by **`ppFill`**
  in `pp_common.dart`. Pronouns live on `ChildProfileStore`.

Deliberately NOT changed: baby-name catalogues (there "Aarav" is a *name being
browsed*), and reviewer testimonials ("Priya, mother of Aarav") — a different
problem, see flag #8.

Two real bugs surfaced by this work:
- `SupabaseRepo.userId` **threw** when Supabase was uninitialised, so an
  uninitialised backend crashed instead of degrading to local-only. Now returns
  null, i.e. behaves as logged out.
- A long section title overflowed the Doctor Record header row — invisible until
  empty states made sections short enough for the lazy `ListView` to lay it out.

### Content vs customization (the line, decided 19 July 2026)

Not all hardcoded text is the same, and the split is what decides whether to
replace it:

- **CONTENT — keep.** Recipes, articles, book summaries, videos, courses, yoga,
  the milestone catalogue, the vaccine schedule, product listings. This is our
  editorial work; real versions are being written. The app should NOT look empty
  because this is present, and removing it would make the product worse.
- **CUSTOMIZATION — replace.** Anything asserting a fact about ONE specific
  child: weight, height, head, date of birth, sex, blood group, which vaccines
  were given, what a doctor said. We cannot ship a prefixed baby weight. It comes
  from the parent or it is not shown.

Where content mentions the child it uses placeholders, not fixed text — the copy
stays, only the child is filled in (`ppFill`).

Completed under that line:
- **The seeded child's measurements** (6.4 kg / 63 cm / 41 cm) are gone; 0 now
  means "not recorded" and the UI says so. Name/DOB remain as a placeholder only
  so the app has an age to work from until she saves real details.
- **The child-details sheet** (`post_pregnancy_home`) hardcoded the whole child —
  "8 March 2026", "Boy", "6.4 kg · 50th", "63 cm · 48th", "41 cm · 52nd",
  centiles included. Reads the real profile now.
- **The Emergency Card** was seeded with a blood group, a paediatrician's phone
  and two parents' numbers. It starts empty and is persisted once she fills it
  in — the screen already had the invitation state. This was the most dangerous
  fabricated data in the app.
- **The health timeline** was eleven invented events; it is now built from her
  doctor visits, the doses she marked, and the symptoms she logged.
- **"Add a child"** is real (name + date of birth only — a measurement belongs in
  the dated growth record, not guessed at sign-up). `addChild()` had been
  complete and cloud-writing the whole time; only the form was missing.
- **Attachments upload to Storage** (`uploadAttachments`) on pick, so a
  photographed birth certificate stops living on a temp path the OS deletes.
- **`FamilyProfileStore` is partitioned per child.** Conditions, feeding, sleep
  and learning style describe a CHILD, and enabling multi-child made the bleed
  reachable — a second baby's reflux would have overwritten the first's. The
  in-memory fields still hold the active child's answers, so every getter and
  the reco engine are untouched; only storage is bucketed, swapped on switch.

Layout note: several rows sized themselves around the 5-character "Aarav" and
overflowed once names varied. Those are now Flexible + ellipsis — real names are
not a fixed length, so this was a latent bug, not a new one.

### ⚠️ Parenting flags — status as of 20 July 2026

**STILL OPEN:**
1. **Growth mirror columns not collapsed.** The screens now read `GrowthStore`
   (Doctor Record, health growth, My Child details all fixed), so the *display*
   is consistent. But the `children.weight_kg/height_cm/head_cm` mirror columns
   still exist and are still written by `ChildProfileStore.update`. The intended
   end state — latest growth row is the only truth, mirror columns dropped — is
   not done. Low urgency now that display is correct; finish before relying on
   `children.*` for anything.
2. **`profiles.baby_dob` mirror not wired.** Decision stands (`children` is
   truth, `baby_dob` mirrors the FIRST child for the WhatsApp pg_cron), but **no
   Dart writes `baby_dob`**, so a post-birth WhatsApp trigger can't fire yet.
3. **Duplicate child after late pairing.** Save-before-pairing on both sides →
   two child rows for one baby. Deliberately not auto-merged (could be twins).
   Needs a product call + a resolve-in-UI affordance.
8. **Fake testimonials.** "Priya, mother of Aarav (4 mo)" in `pp_experts_data`,
   `book_detail_screen`, `product_detail_screen`. Left as placeholder CONTENT,
   but invented social proof is legally riskier than invented child data — must
   not ship as-is.
   Tier-2 starter seeds (pre-saved recipes, six liked names, watch progress,
   wishlists) also remain — harmless-ish, a product call on whether a new parent
   starts with items she never chose.

**RESOLVED since first written (kept here so the history reads straight):**
- ~~4. Reminders don't persist~~ → med reminders persist (0022), vax
  done+reminder persist (0023).
- ~~5. Attachments on temp paths~~ → `uploadAttachments` routes bytes to the
  `media` bucket on pick (documents + health records).
- ~~6. "Add a child" is a stub~~ → real name+DOB form in `multichild_sheet`.
- ~~7. FamilyProfileStore not child-keyed~~ → partitioned per child, swapped on
  child switch; getters/reco-engine untouched.
- ~~9. Retired `VaccinationScreen` seeds~~ → dead code, unreachable; V1 naming
  fully retired by the other terminal. Left for revert only.
- ~~10. Seeded health content shown as hers~~ → timeline derived from her
  records; `kUpcomingHealth`/`kVaxStatus`/`kHealthSnapshot` now computed;
  `kHealthInsights` hidden until a real engine exists.

### Guardrails
`test/pp_no_fabricated_child_data_test.dart` locks the rule in: a fresh child has
no measurements, nothing about the child is pre-filled (health, growth, vaccines,
emergency card, timeline), no seeded name likes/crown, a like alone is not a
match, `ppFill` resolves every token, and — by walking the source — no screen can
render a `{child}` placeholder without calling `ppFill`.

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
