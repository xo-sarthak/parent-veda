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
| `calendar_store.dart` | `calendar_personal_events` |
| `bump_store.dart` | `bump_photos` |
| `daily_store.dart` | `daily_moods`, `baby_talk`, `kept_affirmations`, `daily_movement_responses`, `father_missions` |
| `medicine_store.dart` | `medications`, `medication_logs` |
| `memory_store.dart` | `weekly_journal_notes` |
| `reminder_store.dart` | `reminders` |
| `scans_store.dart` | `completed_scans`, `appointments` |
| `symptom_store.dart` | `symptom_logs` |
| `tools_store.dart` | `weight_profile`, `weight_entries`, `movement_sessions`, `kegel_state`, `contraction_sessions` |

`daily_moods`, `daily_movement_responses`, `weight_profile` and `kegel_state` already have `updated_at` (0003, 0004),
but it is not used as a merge clock. The rest have neither column.

### Parenting (`lib/screens/post_pregnancy/`)

| Store | Tables |
|---|---|
| ~~`pp_care_log_data.dart`~~ | ~~`pp_nappy_logs`, `pp_pump_logs`, `pp_tummy_logs`~~ **DONE 2026-10-17 (0101)** |
| ~~`pp_feeding_data.dart`~~ | ~~`pp_feed_logs`~~ **DONE 2026-10-17 (0101)** |
| ~~`pp_sleep_data.dart`~~ | ~~`pp_sleep_logs`~~ **DONE 2026-10-17 (0101)** |
| ~~`pp_growth_data.dart`~~ | ~~`pp_growth_measurements`~~ **DONE 2026-10-17 (0101)** |
| `pp_documents_data.dart` | `pp_documents` |
| `pp_health_data.dart` | `pp_medications`, `pp_prescriptions`, `pp_allergies`, `pp_symptoms`, `pp_reports`, `pp_doctor_visits`, `pp_doctor_questions`, `pp_emergency_cards` |
| `pp_milestones_data.dart` | `pp_milestone_observations` (composite key) |
| `pp_vaccine_data.dart` | `pp_vaccine_doses` (composite key) |
| `pp_names_data.dart` | `pp_name_votes` |
| `pp_child_profile.dart` | `children` (shared read with the partner) |

Child records are shared between both parents (FAMILY-MODEL.md), so two people really can edit the same row; see §6
before choosing the merge.

**Already correct (do not touch):**
- `journal_store.dart` and `father_journal_store.dart`: newer-wins, tombstones, a seen-set (§16l).
- `saved_store.dart`: `updated_at` plus `removed_at` (§16d).
- `ttc_doctor_questions_store.dart`: 0092 (§16r).

---

## 2. Blob stores: cloud replaces local wholesale (MEDIUM: an offline change can be lost)

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

- **Soft-deleted rows stay in the cloud tables for good.** Applies to `ttc_cycles`, `ttc_cycle_signals` and
  `ttc_logs` (0097), and to `saved_items` and `ttc_doctor_questions`. `saved_items` already purges after 30 days
  (0081:93); the TTC tables don't. For one person's cycle that's tens of rows a year: harmless, but worth a purge.
  - **Fix:** a scheduled function (or `pg_cron`) that hard-deletes rows with `removed_at < now() - interval '90 days'`.
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
  append-only, so two parents almost never edit the same row (2026-10-17, step 5). Still open: documents,
  health, milestones, vaccines, names and the child profile, where per-field may be worth asking about.
- **Every couple-scoped store must keep the row's owner on push.** Check this before converting any `pp_*` or
  supplements store; the flip is silent.

---

## 7. Smaller items found on the way

- **The resume pull re-runs every registered store** (about 30 queries), throttled to once a minute. Fine today.
  If it grows, pull only the stores for the current stage, or use a "changed since" query on `updated_at`.
- **Signal rows (`ttc_cycle_signals`) must keep `cycle_day` between 1 and 90**, even when soft-deleted; the client
  sends 1 for a removed row. If that check ever changes, keep the removed-row value valid.
- **The trigger reminders** (`TtcTreatmentStore` reminder ids 918001/918002) are not cancelled by the store reset.
  `NotificationService.silenceForSignOut` probably covers them; confirm on a device.
- **`DeleteAccount.run` keeps an unused `local_wipe.dart` import** (marked `// ignore`); drop it in the next pass
  there.

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

1. ~~**§1 TTC tables** (records, appointments, ritual)~~ **DONE 2026-10-17 (0098), with their §3 waiting sets.**
   ~~Supplements and the timeline~~ **DONE 2026-10-17 (0099).** All of TTC's row tables are now converted.
2. ~~**§3 dirty sets** for the same stores~~ done with step 1.
3. ~~**§2 push-before-pull**~~ **DONE 2026-10-17 (step 3).** Next in §2: per-item merge for the curated lists.
4. ~~**§1 Parenting logs**, append-only first (feeds, nappies, sleep, growth), one migration.~~ **DONE 2026-10-17
   (step 5, 0101 run 2026-10-17).** Next in Parenting: documents, health, milestones and vaccines, still on
   `ChildSync.merge`; the composite-key tables (vaccines, milestones) need `pushKeyed` reworked too.
5. **§1 Pregnancy tables**, one migration.
6. **§4, §5, §7** as tidy-up.

For each step: write a pure merge test with no network (like `test/ttc_row_merge_test.dart`), extend
`ttc_schema_contract_test` (or the stage's own contract test) to read the new migration, and walk two phones on one
account before calling it done.
