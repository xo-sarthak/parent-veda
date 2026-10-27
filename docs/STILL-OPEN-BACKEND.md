# STILL-OPEN-BACKEND: sync and data-safety work still owed

Written 2026-10-17, after the TTC cycle sync was rebuilt (commit `853650e`, migration 0097, BACKEND-PATTERNS §16ii).
That work fixed the cycle data and made sign-out safe app-wide. This file lists everything the same audit found that
is **not fixed yet**, in enough depth to pick up cold after a session reset.

Read first:
- **BACKEND-PATTERNS §16ii.** The pattern every item below should copy: an edit-time `updated_at`, a soft delete
  (`removed_at`), newer-wins merge, dirty flags, and confirmed uploads.
- **`lib/ttc/ttc_row_merge.dart`.** The pure merge rule (`ttcMergePlan`) to reuse.
- **`lib/ttc/cycle_store.dart` and `lib/ttc/ttc_log_store.dart`.** The two stores already converted: the worked
  example.

---

## RESUME HERE: the step plan (kept current, updated 2026-10-20)

**A new chat starts here.** This section says which step is next and what each one is. The rest of this file is the
detail behind each step. `docs/BACKEND-SYNC-LOG.md` is the dated history of the steps already done, one entry per
step, newest at the bottom. When a step lands: tick it here, add its log entry there, and update
`docs/BEFORE-LAUNCH.md`.

### Done (all committed, every migration run on the live database; 0105 run 2026-10-20)

| Step | What | Migration | Commit |
|---|---|---|---|
| 1 | TTC records, appointments, ritual | 0098 | `01fceb2` |
| 2 | TTC supplements and the family timeline | 0099 | `6a36b7f` |
| 3 | Blob stores push before they pull | none | `f32af1e` |
| 4 | Server guard `pv_sync_newer_wins` (an older edit can't overwrite a newer one) | 0100 | `a0eb5b9` |
| 5 | Parenting logs: feeds, sleep, nappies, pumping, tummy time, growth | 0101 | `f7ed88e` |
| 6 | Parenting records: documents, health, milestones, vaccines, emergency card | 0104 | `af76d8f`, docs `2ba778e` |
| 7 | Parenting's last two: the child profile (soft delete + Restore) and the name votes | 0105 (run 2026-10-20) | `d76594b` |
| 8 | Pregnancy part 1: calendar, bump photos, the daily tables, weekly notes, reminders (`OwnRowLedger`) | 0106 (run 2026-10-21) | `d5787b2` |
| 9 | Pregnancy part 2: medicines, scans and appointments, symptoms, the tools (`OwnRowLedger.single` for one-row tables) | 0107 (run 2026-10-21) | `a728ec4` |
| 11 + 12 | Every write of her data confirmed and batched; sign-out forgets memory and stops alarms; the 90-day purge (done before 10, see below) | 0109 (run 2026-10-21) | `984836f` |
| 13 | Nothing she makes lives only on the phone (about 40 stores move to the cloud); every non-shopping blob store merges item by item (`CloudMergedStore`, `pv_state_merge`). This is the non-shopping half of step 10 | 0110 (run 2026-10-22) | `8c466d0` |
| 14 | Rows keyed per person (B9, found 2026-10-24): 17 tables move from a table-wide `id` key to `(user_id, id)`, because ids built from a date or a name collided across people and RLS refused the second person's upload. BUILT 2026-10-24, user's word; 0113 run 2026-10-25; **left: install the next build** | 0113 (run 2026-10-25) | `b474f69` |
| 15 | Parenting tools pass: feed reads follow the active child (twins no longer share a log), an edit updates the same row, and the "ask once" consent answers sync per item (`PpUseConsent`, `CloudMergedStore`). The same day: all five care stores read through `ChildLogLedger.belongsTo`, the breastfeed timer files under the child it started for, and edits keep row ids. Next tools add their kinds the same way | none | `b11b2ec` |
| 16 | Every child's records read per child (B11, found 2026-10-25): growth, documents and the health records read through `ChildLogLedger.belongsTo`; milestones, vaccine doses, the emergency card and Health's "entered" flags keep one value per child (`PerChild`); every child-scoped store pulls every child (`pullEvery`), not only the one on screen; each child's dose alarm has its own id and words. BUILT 2026-10-25, user's word | none | `c70a791` |
| 17 | Health tools pass: the symptom tool's saved changes are read only after a yes (`PpChangesStore.active()`), two more consent kinds (nappies, changes) on the same merged store, growth edits keep their id, the emergency card reads one source | none | `66a1610` |
| 18 | One record per pregnancy (R1): the `pregnancies` table (own rows, partner read, newer wins, purged after 90 days); dated pregnancy records read by window, undated ones sealed into the old pregnancy's archive at the next start; "Kept for you" with Delete; the prefs key two journal stores shared. BUILT 2026-10-25, user's word; 0114 run 2026-10-25 | 0114 | `656bbb3` |
| 19 | Development tools pass: `DevStore` keys the check-in's answers and "we tried this" by child in the item key (`q|<childId>|<text>` with the day, `c|<childId>|<id>`); unowned items from before are kept and read only while the family has one child; the fake starter rows are gone; consent kind `development` gates the doctor-visit use | none | `3e7b8a8` |
| 20 | Food tools pass: a first-tries log per child, shared with the co-parent (`pp_food_tries`, `PpFoodTriesStore`, the milestone shape: keyed by `(child_id, food_id)`, newer wins, soft delete, on the guard and the purge list); consent kind `foods`; allergies on file read from `HealthStore`, not copied | `0115` (run 2026-10-25) | `03976a1` |
| 21 | You, Maa tools pass: `KegelRecord.kind` (breath / kegel; a missing kind reads as kegel, so no migration), a breath session never moves the squeeze routine, a session left by back still saves; `YogaStore` starts with no seeded saves; a priced recorded yoga class is a bought-once offering with no slots; the mood check's reminder date is device-local and never synced. BUILT 2026-10-25, user's word | none | `96eef2d` |
| 23 | Other tools pass: a baby-name un-like is a `liked: false` tombstone, a pass is a skip vote, Undo forgets locally, the deck skips answered names, matches are on the shortlist, an unknown name is dropped; the chosen name is written to the child only on her tap (`ChildProfileStore.update`); the names quiz answers and Sleep Sounds' armed timer are device-local. (Row 22 is the R2 partner-side step in the sync log.) BUILT 2026-10-26, user's word | none | `a224492` |
| 24 | Milestones (R10): `pp_milestone_observations` gains `photo_path` (a Storage path) and `title` (her own milestones, `own_` ids); the app sends both only when set, so rows sync before and after the migration; the photo uploads and back-fills like the journal's; the journal memory keeps its own copy, tied by the tag `pp_milestone:<id>`. BUILT 2026-10-26, user's word | `0116` (user runs) | `5824b08` |
| 25 | TTC doctor check (T1): `ttc_journeys` gains `trying_count_from` (`again` / `own`), `trying_count_date` and `trying_effective_start`; her "how long" pick is stored as a basis, never a rewritten `journey_start`; his phone reads `trying_effective_start ?? journey_start`, so her pregnancy dates never leave her row; the keys go only when set or as an explicit null to clear. BUILT 2026-10-27, user's word | `0117` (run 2026-10-28) | `00b3cc5` |

### Still to do, in order

**Steps 11 and 12 are done (2026-10-21), ahead of 10.** Step 10 waits on the marketplace decision below. Each step is the same shape: plan → user decides the merge rule → migration →
store changes → a pure merge test → the user runs the migration and its check query → log entry.

| Step | What | Where the detail is | Size |
|---|---|---|---|
| **10 (ON HOLD, 2026-10-21; non-shopping half DONE as step 13, 2026-10-22)** | **Split by the user's marketplace plan.** The shopping half (cart, orders, bought products, product checklists, saved products, Brand Studio, the booking cache) is handed to the marketplace build, which designs them as server-side rows from the start; nothing is built for them here. The rest was done in step 13. ~~**Two left:** `pp_development_data.dart` and `pp_reading_data.dart` were being edited by another terminal and still use the whole blob.~~ **None left (2026-10-22):** both converted once the other terminal committed. Blob stores, per-item merge for the lists people curate (saved readings, hospital bag, checklists, cart), so two phones editing different items both keep their edits. Records hiding in blobs (orders, scan reports, readings) move to rows | §2 | medium |

Every Pregnancy and Parenting row table is now on a ledger (`OwnRowLedger`, `ChildLogLedger`). Steps 11 and 12 are done. What is left is step 10 (the blobs, split above) and §4's decision on phone-only data. Read BACKEND-PATTERNS §16ii-k (the old sync's mistakes) before step 10. The
backend is then **launch-ready** once the user's checks below are done and the backend items in BEFORE-LAUNCH §1 and
§7 (crash reporting, uptime alerts, backups) are closed.

### Owed by the user (not blocking the next step)

1. **The two-phone walk** for steps 1-6, on one account or as a linked couple. Step 6's list is in the sync log; the
   short version: a vaccine reminder set on phone A buzzes on phone B; switched off on B, A stops too; a dose
   un-ticked on B shows un-ticked on A; the emergency card cleared on A stays cleared on B; an allergy removed
   offline stays removed. Earlier steps: delete something on one phone, it stays gone on the other, including after
   going offline and back.

2. **The family timeline count.** Run in the Supabase SQL editor:
   ```sql
   select count(*) from journey_timeline;
   ```
   Run it once now, then open the app on a phone that has timeline moments, and run it again.
   - **Why:** step 2 found that the family timeline had very likely **never reached the cloud**. Migration 0041 gave
     `journey_timeline` no UPDATE permission ("append-only"). The app uploads with an upsert
     (`INSERT ... ON CONFLICT DO UPDATE`), and Postgres checks every permission a statement *might* need before it
     runs it. So an upsert needs UPDATE even for a brand-new row, and every timeline upload was refused. The app
     swallows upload errors, so nobody saw it.
   - **What the numbers mean:** a first count near zero confirms the bug was real. The second count should be close
     to the number of moments on the phone, which proves 0099's fix works and the backlog uploaded. If the second
     count is still near zero, uploads are still being refused, and that needs looking at before launch.
   - It's also tracked in BEFORE-LAUNCH §1 as a CHECK item.

3. **Choose a crash reporter: Sentry or Firebase Crashlytics.**
   - **Why we need one:** today, when something fails on a user's phone (a crash, or a sync upload the server
     refuses), only that phone knows. `PvSyncHealth` sees a refused upload and tells nobody. That is how the timeline
     bug above went unnoticed. A crash reporter sends the error (which store, which table, the error text, never the
     user's data) to a dashboard we watch, so a broken upload is found in a day, not after launch. It's a BLOCKER in
     BEFORE-LAUNCH §7.
   - **Firebase Crashlytics:** free with no event limit. Strong at native crashes on Android and iOS. Needs the
     Firebase SDK and a Firebase project in the app. Weaker for "handled" errors such as a refused sync, which it
     treats as second-class "non-fatal" events.
   - **Sentry:** a free tier of about 5,000 errors a month, then the Team plan at about $26/month (about ₹2,200).
     Better for handled errors with context (tags like store and table, breadcrumbs of what happened first), has a
     Flutter SDK, and also covers the Ask Veda Python service and the edge functions, so one dashboard sees the whole
     backend.
   - **Recommendation:** Sentry, because what we most need to catch is refused syncs and server errors, not just
     crashes, and it covers both repos. Crashlytics is the right choice if staying at $0 matters more.
   - Once chosen, wiring it in is a dev task: report from `PvSyncHealth` and the global error handler.

---

## 0. What is already done (so it is not redone)

- **Her cycle and daily log.** `CycleStore` (`ttc_cycles`, `ttc_cycle_signals`) and `TtcLogStore` (`ttc_logs`) have
  newer-wins merge, soft deletes, bleed days in the cloud, confirmed uploads with retry, and one push at a time
  (`TtcSyncedStore.runPush`).
- **Pull on resume**, every stage, at most once a minute: `SyncRegistry.resyncOnResume()` from `main.dart`.
- **Whose data is on the phone (`LocalOwner`)**, checked at launch and before every resync. A different account
  means wipe first.
- **Sign-out** asks first, warns about unsaved changes, then wipes the phone and resets every store. Account deletion
  does the same.
- **Every syncing store can be emptied:**
  - `TtcSyncedStore.resetLocal()` and `CloudSyncedStore.cloudEmptyData` are required by the compiler;
  - stores that register by hand call `SyncRegistry.registerReset`;
  - `test/sync_reset_coverage_test.dart` guards it.
- **Settings > ACCOUNT > "Your data"** shows whether changes are waiting.
- **Records, appointments and the ritual (step 1, 2026-10-17, migration 0098).** Same pattern, on `TtcRowBook`.
  Couple-scoped rows keep their owner on push (the old push rewrote the partner's rows as hers). The ritual's
  shared part is the couple's and the other four are each person's. All three feed the pending-changes check. See
  BACKEND-PATTERNS §16ii-b and `docs/BACKEND-SYNC-LOG.md` step 1.
- **Supplements and the family timeline (step 2, 2026-10-17, migration 0099).** Same pattern.
  - Removing a supplement now soft-deletes its ticks, which a hard delete used to cascade.
  - The timeline gained an own-row UPDATE (the user's decision). Without it the upsert upload was always
    refused, so the timeline had very likely never synced.
  - See `docs/BACKEND-SYNC-LOG.md` step 2.
- **Parenting logs (step 5, 2026-10-17, migration 0101, run 2026-10-17).** Feeds, sleeps, nappies, pumping, tummy
  time and growth: same pattern, on `ChildLogLedger` (`child_scoped_store.dart`) over the shared `SyncRowBook`
  (`lib/services/remote/sync_row_book.dart`, which `TtcRowBook` is now a typedef of).
  - The ledger remembers each row's child, so a pull of one child leaves another's rows alone.
  - A row the partner owns goes up as a plain UPDATE: an upsert is checked against the INSERT policy
    (`auth.uid() = user_id`) even when it updates, and would be refused. BACKEND-PATTERNS §16ii-f.
  - See `docs/BACKEND-SYNC-LOG.md` step 5.
- **The rest of the child's record (step 6, 2026-10-18, migration 0104, run 2026-10-18).** Documents, the six health
  tables, doctor questions (now with ids), the emergency card (Clear syncs), milestones and vaccine doses.
  - `ChildLogLedger` gained a keyed mode for the composite-key tables, and an owner-is-last-editor mode for the
    card, whose UPDATE policy pins `user_id`.
  - Vaccine reminders are shared: the time syncs and each phone arms its own alarm. Turning a reminder off now
    cancels the alarm, which it never did.
  - See `docs/BACKEND-SYNC-LOG.md` step 6.
- **The child profile and the name votes (step 7, 2026-10-20, migration 0105, run 2026-10-20).**
  - Removing a child is a soft delete; `my_child_ids()` is unchanged, so the records stay reachable, and "Removed
    children" on the You screen restores one.
  - The growth figures don't move the clock (`setMeasures`).
  - A skipped name stays skipped.
  - See `docs/BACKEND-SYNC-LOG.md` step 7 and BACKEND-PATTERNS §16ii-h.
- **Pregnancy part 1 (step 8, 2026-10-20, migration 0106 run 2026-10-21, `d5787b2`).** Calendar notes, bump photos, the five
  daily tables, weekly notes and reminders, on the new `OwnRowLedger` (all own-only, so newer wins with no
  decision). Bump and note photos leave Storage once the removal is confirmed; reminders re-arm or cancel their
  alarms after a pull; `father_missions` got its missing UPDATE policy. See `docs/BACKEND-SYNC-LOG.md` step 8.
- **Pregnancy part 2 (step 9, 2026-10-21, migration 0107 run 2026-10-21, `a728ec4`).** Medicines and their logs, scans and
  appointments, symptoms, and the four tools, on `OwnRowLedger` (`.single` for the weight profile and kegel
  routine). Medicine alarms now sync and re-arm on each phone (every pull used to wipe them); medicine and symptom
  log ids come from their natural key; the partner's read of scans skips removed rows; 0107 also lets severity be
  'strong', which the server had been refusing. See `docs/BACKEND-SYNC-LOG.md` step 9.

---

## 1. Deletes that come back (HIGH: data reappears after the user removed it)

**The mechanism.** These stores merge by "cloud wins per id, and local-only rows are inserted" (or a plain union).
They have no tombstone and no soft delete. A delete is a one-shot hard `delete` call, so it is lost in three cases:

- the phone is offline;
- the call races an upload that is already in flight;
- another phone still holds the row and pushes it back.

The next pull brings the row back. This is exactly the bug the walk found on the cycle (a cleared ovulation test
reappearing after a reinstall).

**The fix, per table:**
1. Migration: `updated_at timestamptz not null default now()` (where missing) and `removed_at timestamptz`.
2. The store keeps a per-row edit time and a soft delete.
3. Pull with `ttcMergePlan` (or `SavedStore.merge`).
4. Upload only dirty rows through `upsertRowConfirmed`.
5. Write one migration per stage, so each can be run and checked on its own.

### TTC (do these first; they hold her own records)

| Store (file) | Table | Today | Note |
|---|---|---|---|
| ~~`TtcRecordsStore`~~ | `ttc_records` | **DONE 2026-10-17 (0098)** | see §0 |
| ~~`TtcAppointmentsStore`~~ | `ttc_appointments` | **DONE 2026-10-17 (0098)** | see §0 |
| ~~`TtcSupplementsStore`~~ | `ttc_supplements`, `ttc_supplement_taken` | **DONE 2026-10-17 (0099)** | see §0 |
| ~~`TtcRitualStore`~~ | `ttc_ritual` | **DONE 2026-10-17 (0098)** | see §0 |
| ~~`FamilyTimeline`~~ | `journey_timeline` | **DONE 2026-10-17 (0099)**, own-row UPDATE granted | see §0 |

None of these tables has `updated_at` except where noted; all need `removed_at`.

### Pregnancy (`lib/services/`)

| Store | Tables |
|---|---|
| ~~`calendar_store.dart`~~ | ~~`calendar_personal_events`~~ **DONE 2026-10-20 (0106, run 2026-10-21)** |
| ~~`bump_store.dart`~~ | ~~`bump_photos`~~ **DONE 2026-10-20 (0106, run 2026-10-21)** |
| ~~`daily_store.dart`~~ | ~~`daily_moods`, `baby_talk`, `kept_affirmations`, `daily_movement_responses`, `father_missions`~~ **DONE 2026-10-20 (0106, run 2026-10-21)** |
| ~~`medicine_store.dart`~~ | ~~`medications`, `medication_logs`~~ **DONE 2026-10-21 (0107, run 2026-10-21)** |
| ~~`memory_store.dart`~~ | ~~`weekly_journal_notes`~~ **DONE 2026-10-20 (0106, run 2026-10-21)** |
| ~~`reminder_store.dart`~~ | ~~`reminders`~~ **DONE 2026-10-20 (0106, run 2026-10-21)** |
| ~~`scans_store.dart`~~ | ~~`completed_scans`, `appointments`~~ **DONE 2026-10-21 (0107, run 2026-10-21)** |
| ~~`symptom_store.dart`~~ | ~~`symptom_logs`~~ **DONE 2026-10-21 (0107, run 2026-10-21)** |
| ~~`tools_store.dart`~~ | ~~`weight_profile`, `weight_entries`, `movement_sessions`, `kegel_state`, `contraction_sessions`~~ **DONE 2026-10-21 (0107, run 2026-10-21)** |

`daily_moods`, `daily_movement_responses`, `weight_profile` and `kegel_state` already have `updated_at` (0003, 0004),
but it is not used as a merge clock. The rest have neither column.

### Parenting (`lib/screens/post_pregnancy/`)

| Store | Tables |
|---|---|
| ~~`pp_care_log_data.dart`~~ | ~~`pp_nappy_logs`, `pp_pump_logs`, `pp_tummy_logs`~~ **DONE 2026-10-17 (0101)** |
| ~~`pp_feeding_data.dart`~~ | ~~`pp_feed_logs`~~ **DONE 2026-10-17 (0101)** |
| ~~`pp_sleep_data.dart`~~ | ~~`pp_sleep_logs`~~ **DONE 2026-10-17 (0101)** |
| ~~`pp_growth_data.dart`~~ | ~~`pp_growth_measurements`~~ **DONE 2026-10-17 (0101)** |
| ~~`pp_documents_data.dart`~~ | ~~`pp_documents`~~ **DONE 2026-10-18 (0104)** |
| ~~`pp_health_data.dart`~~ | ~~`pp_medications`, `pp_prescriptions`, `pp_allergies`, `pp_symptoms`, `pp_reports`, `pp_doctor_visits`, `pp_doctor_questions`, `pp_emergency_cards`~~ **DONE 2026-10-18 (0104)** |
| ~~`pp_milestones_data.dart`~~ | ~~`pp_milestone_observations` (composite key)~~ **DONE 2026-10-18 (0104)** |
| ~~`pp_vaccine_data.dart`~~ | ~~`pp_vaccine_doses` (composite key)~~ **DONE 2026-10-18 (0104)** |
| ~~`pp_names_data.dart`~~ | ~~`pp_name_votes`~~ **DONE 2026-10-20 (0105, run 2026-10-20)** |
| ~~`pp_child_profile.dart`~~ | ~~`children` (shared read with the partner)~~ **DONE 2026-10-20 (0105, run 2026-10-20)**: soft delete + Restore |

Child records are shared between both parents (FAMILY-MODEL.md), so two people really can edit the same row; see §6
before choosing the merge.

**Already correct (do not touch):**
- `journal_store.dart` and `father_journal_store.dart`: newer-wins, tombstones, a seen-set (§16l).
- `saved_store.dart`: `updated_at` plus `removed_at` (§16d).
- `ttc_doctor_questions_store.dart`: 0092 (§16r).

---

## 2. Blob stores: cloud replaces local wholesale (MEDIUM: an offline change can be lost)

> **DONE 2026-10-22 (step 13, 0110) for every non-shopping store.** They merge item by item on the server
> (`pv_state_merge`, `CloudMergedStore`). Still whole-blob: only the shopping stores (marketplace build).
> `pp_development_data` and `pp_reading_data` were converted later the same day, once another terminal had
> committed its edits to them. The text below is the original finding.

**Mechanism.** The ~35 `CloudSyncedStore` stores keep one JSON blob per user in `user_state`
(`lib/services/remote/cloud_synced_store.dart`).
- **On sync:** if the cloud has a blob, it replaces the phone's state whole. If not, the phone seeds the cloud.
- **On every change:** the store pushes immediately.

That is fine for one phone. With two phones, the blob that synced last wins entirely:
- a change made offline on phone A is overwritten by phone B's older blob the next time A pulls before pushing;
- two phones editing different items both upload whole blobs, so one person's edits erase the other's.

**Stores affected:** Booking, BrandStudio, BookCompanion, Community, Cart, CanIActivity, Bought, JourneyDates,
HospitalBag (v1, v2), Garbh, FamilyProfile, ExpertFollow, ProductChecklist, NutritionDay, SpiritualPrefs,
ReadToBaby, ReadToBabySaved, ScanReports, ReadNext, ReadDone, ReadyBirthContext, Readings, PvOrder, DailyTip, Dev,
Grow, Food, Journeys, NameMatch, Reco, Reading, Watch, Yoga. Find them with `grep -rn "get cloudKey" lib`.

**Already better:**
- `ttc_precheck_store.dart` merges per item with "last answer wins".
- `booking_store.dart` also reads `booking_bookings` rows.

**Fix options (decide per store, by how much it matters):**
- **Leave as is** for preferences and "last seen" values: font scale, last tip shown, playback position. Losing one
  of these is harmless.
- **Per-item newer-wins inside the blob.** Give each item an `updatedAt` and merge item by item on pull, the way
  `TtcPrecheckStore` does. Do this for lists the user curates: saved readings, hospital bag ticks, checklists, cart.
- **Move to rows** with soft deletes for anything that is really a record: orders, scan reports, readings.

~~**Cheapest safety first:** push before pull on resume.~~ **DONE 2026-10-17 (sync log step 3).**
- Each blob store now keeps a waiting mark on disk. A sync that finds it set uploads first instead of taking the
  cloud's blob.
- Uploads run one at a time, and the mark feeds the sign-out warning.
- What's left in §2 is the per-item merge above, for the curated lists. Until then, with two phones, the phone with
  a waiting change wins the whole blob.

---

## 3. Uploads that fail silently in the other stages (MEDIUM: changes may never reach the account)

> **DONE 2026-10-21 (step 11).** Every write of her data is confirmed and keeps a waiting mark the sign-out sheet
> reads; first sync goes in batches of 100 (`SyncBatch`); onboarding's stashed profile is finally sent
> (`PendingProfile.flush` on every resync). `test/no_silent_user_writes_test.dart` holds it. **Still silent, out of
> scope:** orders (`pv_order_store`, the marketplace build), referral codes, the doctor app's availability and
> schedule, Can-I misses. The text below is the original finding.

`SupabaseRepo.upsertRow` swallows every error (`supabase_repo.dart` ~494). Every store that uses it, directly or
through `TtcSyncUtil.upsertAll`, cannot tell that an upload failed. It never retries until the next full sync, and
`PvSyncHealth` never hears of it.

- **Converted so far:** only `CycleStore` and `TtcLogStore` use `upsertRowConfirmed` and keep a dirty set.
- **Fix:** per store, as part of §1, track a dirty set and retry. Each converted store then also reports pending
  changes, so the sign-out warning and the Settings row cover it.
  - **Today only the cycle and the daily log feed that check.** For every other store, the sign-out sheet can say
    "saved" while changes are still unsent.
- **Also:** `TtcSyncUtil.upsertAll` sends rows one by one. For a large first sync on a new phone, batch the upserts
  (PostgREST takes an array) to cut round trips.

---

## 4. Local-only stores keep the last person in memory (LOW: shown, never uploaded)

> **DONE 2026-10-21 (step 12)** for 45 stores (sync log step 12 lists them); `sync_reset_coverage_test` now fails
> any prefs-reading singleton with no reset. **Reset still owed** (deferred, another terminal was editing them):
> `ttc_learn_screen` recents, `TtcPartnerMode` (`ttc_strings`), `ttc_ready_habits_store`, plus the six doctor-app
> stores (their own sign-out). **DECISION OWED (the user): phone-only personal data is LOST at sign-out.** The
> birth plan, Garbh journal, memories, BMI history, condition answers, the skilling journal and portfolio never
> reach the cloud, so the wipe deletes them for good, while the sign-out sheet says "It stays saved in your
> account". The cheap fix is the `CloudSyncedStore` blob per store (the non-shopping half of step 10).
>
> **DECIDED AND DONE 2026-10-22 (step 13, 0110).** The user: phone-only data is not good practice. Every personal
> store now syncs (memories and the Garbh journal as rows with their files in Storage, the rest as merged items),
> except **Skilling**, kept on the phone by decision (consent and legal review for children's data); the sign-out
> sheet now says so when Skilling holds anything. `TtcLearnRecents` and `TtcReadyHabitsStore` got their resets
> through the mixin. Still owed: `TtcPartnerMode` and `GlobalAskFab` (device settings), the doctor-app stores.

Stores that never sync are not in the reset registry. After a sign-out their `shared_preferences` are wiped, but the
singleton still holds the last person's data until the app restarts, so the next person can see it in this session.

- They upload nothing, so there is no leak between accounts in the cloud.
- **Examples:** `TtcPartnerMode` (a testing flag, harmless), and any store that has `_load` from prefs but no
  `SyncRegistry` or mixin.
- **Fix:** let `SyncRegistry.registerReset` take local-only stores too. Find them with
  `grep -rln "SharedPreferences.getInstance" lib`, minus the ones already registered. Extend
  `sync_reset_coverage_test` to require a reset from any singleton that reads prefs keys holding personal data.

---

## 5. Tombstones and soft-deleted rows grow forever (LOW: storage)

> **DONE 2026-10-21 (step 12, 0109, run 2026-10-21, cron job 3 active).** `pv_purge_removed(90)` daily via `pg_cron` over an explicit
> list of 43 tables (never `children`); the phones drop confirmed removals after 80 days, first, on purpose
> (BACKEND-PATTERNS §16ii-m). ⚠️ CORRECTION: the line below saying `saved_items` "already purges" was wrong; 0081's
> prune was never scheduled. The text below is the original finding.

- **Soft-deleted rows stay in the cloud tables for good.** Applies to `ttc_cycles`, `ttc_cycle_signals` and
  `ttc_logs` (0097), and to `saved_items` and `ttc_doctor_questions`. `saved_items` already purges after 30 days
  (0081:93); the TTC tables don't. For one person's cycle that's tens of rows a year: harmless, but worth a purge.
  - **Fix:** a scheduled function (or `pg_cron`) that hard-deletes rows with `removed_at < now() - interval '90 days'`.
  - **Never `children`** (step 7, 2026-10-20). A removed child must stay restorable, and the row is what
    `my_child_ids()` reads: purging it would strand every record of that child where neither parent can read it.
  - **Safe**, because a phone that was offline that long syncs as a fresh install for those rows: the cloud no longer
    has them, so the phone's copy uploads. Pick a window longer than any realistic offline gap.
- **The phones keep removed keys too** (`CycleStore._tombs`, `TtcLogStore._cleared`).
  - **Fix:** drop a local tombstone once the cloud has confirmed it AND it is older than the purge window.

---

## 6. Data two people write (DESIGN DECISION NEEDED before §1 touches it)

Some tables are couple-scoped: both partners can write, through RLS policies with `my_partner_id()`.
- `ttc_supplements`, `ttc_supplement_taken`, `ttc_ritual`, `journey_timeline`;
- in Parenting, every child-scoped `pp_*` table.

Newer-wins by the phone's clock is right for **one person's own data** (§16ii explains why). With two people the
trade-offs change:
- **Clock skew between two phones** decides a real conflict.
- **"Newer wins" can erase the other parent's edit** to a different field of the same row.

**Options:**
- Per-field merge, where each column carries its own time.
- Last-writer-wins, with the server time recorded alongside the phone time.
- For logs that are just appended (feeds, nappies, sleeps), conflicts are rare and row-level newer-wins is fine.

Decide per table. Most Parenting logs are append-only, so row-level is enough. Settings-like rows (the child
profile, emergency cards) may want per-field.

**Decided so far (the user, 2026-10-17):**
- `ttc_records` and `ttc_appointments`: row-level, latest edit wins.
- `ttc_ritual`: shared parts (`conversation`) are the couple's, so the newest row across both wins. Individual
  parts are each person's own. Each phone writes only its own rows (BACKEND-PATTERNS §16ii-b).
- The six Parenting logs (feeds, sleeps, nappies, pumping, tummy time, growth): row-level, newer wins. They are
  append-only, so two parents almost never edit the same row (2026-10-17, step 5).
- Documents and the health records: row-level, latest edit wins. The emergency card: latest save wins, whole
  card, and Clear syncs. Vaccine reminders: shared, so both phones buzz (the user, 2026-10-17, step 6).
- The child profile (`children`): whole row, latest edit wins; the growth figures don't count as an edit. Removing
  a child is a soft delete, with Restore (the user, 2026-10-20, step 7).
- Name votes needed no decision: they are own-rows-only (0027), so single-person data.
- **Every couple-scoped store must keep the row's owner on push.** Check this before converting any `pp_*` or
  supplements store; the flip is silent.

---

## 7. Smaller items found on the way

- **The resume pull re-runs every registered store** (about 30 queries), throttled to once a minute. Fine today.
  If it grows, pull only the stores for the current stage, or use a "changed since" query on `updated_at`.
- **Signal rows (`ttc_cycle_signals`) must keep `cycle_day` between 1 and 90**, even when soft-deleted; the client
  sends 1 for a removed row. If that check ever changes, keep the removed-row value valid.
- ~~**The trigger reminders** (`TtcTreatmentStore` reminder ids 918001/918002) are not cancelled by the store reset.
  `NotificationService.silenceForSignOut` probably covers them; confirm on a device.~~ **DONE 2026-10-21 (step 12):**
  every wipe now cancels all scheduled notifications, and the sign-out mute no longer gets wiped. Device check owed.
- **One vaccine row holds two facts** (given, reminder). Under row-level newer-wins, one parent marking it given
  while the other sets its reminder at the same moment loses one change. Rare; split the row only if it is ever
  seen (step 6, 2026-10-18).
- ~~**`DeleteAccount.run` keeps an unused `local_wipe.dart` import** (marked `// ignore`); drop it in the next pass
  there.~~ **DONE 2026-10-21 (step 12):** commented out, kept for revert.

---

## 8. Failing tests seen on 2026-10-17 (DO NOT FIX until the user says; another terminal is on them)

The full suite run after `853650e` showed these. They are not from the sync work, and the user asked that they be
left alone for now so two sessions don't clash:

- ~~`test/pv_delete_account_flow_test.dart`~~ **FIXED 2026-10-17.** The cause was in the shared toast, not
  delete-account. `PvToast._update` dropped an update made before the notice's host had mounted, so work that failed
  at once (a refused delete, an offline call) left the "working" spinner on screen forever. The update is now kept in
  `_current` and the host reads it when it mounts (`lib/widgets/pv_toast.dart`).
- ~~`test/ttc_no_repetition_test.dart`~~ **Passes as of 2026-10-17 evening** (after `79922cf`). It was: four
  "her home" cases where the home's "New to trying?" rail and a reading row opened the same read.
- ~~`test/ttc_shell_test.dart` yoga import~~ The import is now commented out (`6597c69`); not re-run here.
- `test/ttc_reader_test.dart`: "save is reachable and sticks". The save icon is found twice.
- `test/ttc_shell_test.dart`: `ttc_more_tab.dart` imports `../post_pregnancy/yoga_home_screen.dart` (the yoga
  commit `187919a`).
- ~~`test/tap_feedback_guard_test.dart`~~ **FIXED 2026-10-17.** The yoga screen's "Clear all" is wrapped in
  `PvPress`.

---

## Suggested order

*Superseded 2026-10-18 by "RESUME HERE" at the top of this file, which is the list kept current. Kept below as history.*

1. ~~**§1 TTC tables** (records, appointments, ritual)~~ **DONE 2026-10-17 (0098), with their §3 waiting sets.**
   ~~Supplements and the timeline~~ **DONE 2026-10-17 (0099).** All of TTC's row tables are now converted.
2. ~~**§3 dirty sets** for the same stores~~ done with step 1.
3. ~~**§2 push-before-pull**~~ **DONE 2026-10-17 (step 3).** Next in §2: per-item merge for the curated lists.
4. ~~**§1 Parenting logs**, append-only first (feeds, nappies, sleep, growth), one migration.~~ **DONE 2026-10-17
   (step 5, 0101 run 2026-10-17).** ~~Next in Parenting: documents, health, milestones and vaccines~~ **DONE
   2026-10-18 (step 6, 0104 run 2026-10-18).** ~~Left in Parenting: `pp_name_votes` and the `children` profile (step 7).~~
   **DONE 2026-10-20 (step 7, 0105).**
5. **§1 Pregnancy tables**, one migration. ~~Part 1~~ **DONE 2026-10-20 (step 8, 0106).** ~~Part 2~~ **DONE 2026-10-21 (step 9, 0107).**
6. **§4, §5, §7** as tidy-up.

For each step: write a pure merge test with no network (like `test/ttc_row_merge_test.dart`), extend
`ttc_schema_contract_test` (or the stage's own contract test) to read the new migration, and walk two phones on one
account before calling it done.

---

## 9. Ask Veda: content and the index (added 2026-10-18)

Not user data: our own content, and the index Ask Veda answers from. Same failure shape as the rest of this file,
a copy drifting from its source in silence. Built 2026-10-17: the recipes export is an exact mirror (commit
`fa2be7c`; every column, update on conflict, archive what is gone, a schema contract test), and the Ask Veda ingest
is incremental (askveda repo; `content_hash` fingerprints, embeds only what changed, removes chunks of content that
is gone, never for a table that failed to read). Both SQL files have been run and the recipes table verified:
161 published, 28 new-design (`pp_7_8m_*`), 1 archived (`tomatocarrotsoup`).

### 9.1 Run the ingest once (USER, when the laptop can take it)
```
cd C:\Projects\parentveda-askveda
.venv\Scripts\python.exe -m ingest.ingest
```
The last hot run: every chunk gets its fingerprint for the first time. Expect roughly
`0 unchanged · ~8,900 embedded · 1+ removed`. Every run after that takes seconds. Until it runs, Ask Veda does not
know the 28 new-design dishes and still holds the archived soup. Never run by an agent (it heats the laptop to 95 °C).

### 9.2 Duplicate recipes in the index (DECISION: the user's yes)
The parenting corpus (`parentingCorpus()` in `lib/screens/post_pregnancy/parenting_veda.dart`) still feeds an older
list of 21 dishes (`kRecipes`, `pp_recipes_data.dart`) into `veda_knowledge`. 16 of them share an id with
`kFoodRecipes`, so Ask Veda holds two copies of each dish, and one of the old ones is the retired tomato-carrot soup.
Two copies can fill two of the 2-3 chunks an answer reads, and the older one can win.
Proposed: the corpus export skips a recipe whose id is in `kFoodRecipes` (or in `kFoodRecipeMoved`) and keeps the
5 that exist only in the old list. After the export + import, the incremental ingest removes the 16 by itself.

### 9.3 Write the sync-log step and the patterns note (on the user's word)
A `BACKEND-SYNC-LOG.md` step "Recipes mirror and the short Ask Veda ingest" (the checklist, what the user ran, and
the routine for a new recipe doc), plus a BACKEND-PATTERNS section on the exact-mirror pattern (`do update` + archive,
guarded by ContentOwnership). The text is drafted; it waits for the other terminal's step to land first so the step
numbers do not collide.
