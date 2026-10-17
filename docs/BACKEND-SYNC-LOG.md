# BACKEND-SYNC-LOG: what the sync work changed, step by step

A running record of the data-safety work listed in `docs/STILL-OPEN-BACKEND.md`, kept from 2026-10-17 at the
user's request because the change is large and more steps follow. **Newest step at the bottom; every item
carries its date.** Each entry says what changed, why, which files, what the user must run, and what is still
owed.

- `STILL-OPEN-BACKEND.md` is the list of what is *left*.
- `BACKEND-PATTERNS.md` §16ii / §16ii-b explain the *pattern*.
- This file is the *history*: what was done, in order, and when.

---

## Dated summary

| Date | What | Migration | Commit | User ran it |
|---|---|---|---|---|
| 2026-10-17 | Before this log: the cycle and daily-log sync | 0097 | `853650e` | yes |
| 2026-10-17 | Step 1: records, appointments, ritual | 0098 | `01fceb2` | yes (2026-10-17) |
| 2026-10-17 | Step 2: supplements, family timeline | 0099 | `6a36b7f` | yes (2026-10-17) |
| 2026-10-17 | Step 3: blob stores push before pull | none | `f32af1e` | nothing to run |
| 2026-10-17 | Step 4: the server enforces newer-wins and refuses future clocks | 0100 | `a0eb5b9` | yes (2026-10-17) |

Owed across steps:
- **The two-phone walk** for steps 1 and 2, when the phone is free. Not yet done.

---

## Step 1: TTC records, appointments, ritual

**Dates:** built 2026-10-17 · committed `01fceb2` on 2026-10-17 · 0098 run by the user on 2026-10-17 · two-phone
walk owed.

**Problem (STILL-OPEN-BACKEND §1, §3, §6).** `TtcRecordsStore`, `TtcAppointmentsStore` and `TtcRitualStore`
pulled with a union and removed with a one-shot hard delete. A removal made offline, racing an upload, or undone
by a second phone came back on the next pull. Every push re-sent every row, and uploads failed silently, so the
sign-out warning could not see them.

**Found on the way (2026-10-17): the ownership flip.** All three tables are couple-scoped (either partner may write
a row). The old push wrote `user_id: <me>` on every row the phone held, including rows pulled from the partner. An
upsert by `id` therefore rewrote his result as hers, and the ritual push did the same with his ticks.

**Decisions (user, 2026-10-17):**
- Records and appointments: row-level, latest edit wins.
- Ritual: the shared part ("Today's conversation") is the couple's, so the newest tick or un-tick by either partner
  wins. The four individual parts are each person's own.

**Done (all 2026-10-17):**
- [x] `supabase/migrations/0098_ttc_records_ritual_sync_clock.sql`: `updated_at` (the merge clock, written by
  the phone, no trigger) and `removed_at` (the soft delete) on `ttc_records`, `ttc_appointments` and
  `ttc_ritual`. Additive and re-runnable.
- [x] `lib/ttc/ttc_row_merge.dart`: `TtcRowBook`, the bookkeeping one synced table keeps beside its rows. It holds
  edit stamps, removals, the removed row's columns (for NOT NULL), each row's owner, and the waiting set. Its
  `merge()` is the newer-wins pull, built on `ttcMergePlan`.
- [x] `lib/ttc/ttc_records_store.dart`: both stores on `TtcRowBook`.
  - `remove` is a soft delete; the hard `SupabaseRepo.delete` is commented out and kept for revert.
  - `add`, `replace`, `update` and `restore` stamp the edit time. Undo is just a newer edit, which ends the old
    delete-vs-upsert race.
  - The pull is newer-wins through `applyCloudRows` (network-free). It keeps local-only fields: a record's
    attachments, and an appointment's reminder switch and time. A visit moved on the other phone gets its
    reminder worked out again; one removed there has its reminder cancelled here.
  - The push sends only waiting rows, each confirmed, with the owner's `user_id` (fixes the flip). Nulls are
    sent, so clearing a note clears it everywhere.
  - `hasPendingPush` now feeds the sign-out sheet and Settings.
  - Union pull and push-all are kept as `_pullUnionKept` / `_pushAllKept`.
- [x] `lib/ttc/ttc_ritual_store.dart`: her own ticks (`_mine`, on `TtcRowBook`), plus the partner's rows held
  read-only (`_partner`).
  - Individual parts show her ticks only.
  - `conversation` shows the newest row across both of them.
  - The streak still counts either person's ticks, so the `ritual_week` milestone is unchanged.
  - The push writes her own rows only.
  - The shared set is `kTtcSharedRitualParts` in `lib/ttc/ttc_daily_data.dart`.
  - Visible change: the partner's breath, reflection, gratitude or action tick no longer shows as hers.
- [x] Tests:
  - `test/ttc_schema_contract_test.dart` now reads 0097 + 0098 and pins the new columns.
  - New `test/ttc_records_ritual_merge_test.dart` (21 cases, network-free): removals that stay removed, Undo,
    owner kept, attachments and reminder kept, a reminder cancelled on a remote removal, and ritual shared vs
    individual.
- [x] Docs:
  - STILL-OPEN-BACKEND: §0 done, §1 table, §6 decisions, §8 refreshed, suggested order.
  - BACKEND-PATTERNS: new §16ii-b, couple-scoped rows.

**Verified (2026-10-17):**
- `flutter analyze` is clean on the 4 lib files.
- 89 tests pass across the merge, contract and row-merge files.
- The 29 other TTC test files that use these stores pass (311 + 323), `ttc_no_repetition_test` included.
- Wiring: all three stores override `hasPendingPush`, every `pullFromCloud` goes through `applyCloudRows`, and no
  live hard delete remains.

**Not verified yet:** the two-phone walk on one account. 0098 has run (2026-10-17); the walk waits for the phone.

**Files:**
- `supabase/migrations/0098_ttc_records_ritual_sync_clock.sql`
- `lib/ttc/ttc_row_merge.dart`
- `lib/ttc/ttc_records_store.dart`
- `lib/ttc/ttc_ritual_store.dart`
- `lib/ttc/ttc_daily_data.dart`
- `test/ttc_schema_contract_test.dart`
- `test/ttc_records_ritual_merge_test.dart`
- `docs/STILL-OPEN-BACKEND.md`
- `docs/BACKEND-PATTERNS.md`
- `docs/BACKEND-SYNC-LOG.md`

---

## Step 2: TTC supplements and the family timeline

**Dates:** started 2026-10-17 · built 2026-10-17 · committed `6a36b7f` on 2026-10-17 · 0099 run by the user on 2026-10-17 ·
two-phone walk owed.

**Problem.** The same as step 1: a union pull, hard deletes, every row re-sent, and uploads failing silently. Both
stores are couple-scoped, so the step 1 owner flip applies too.

**Found on the way (2026-10-17):**
- **The timeline has (very likely) never synced.** 0041 gave `journey_timeline` no UPDATE grant ("append-only").
  The app uploads with an upsert (`INSERT ... ON CONFLICT DO UPDATE`). Postgres checks every privilege a
  statement *might* need before it runs, so an upsert needs UPDATE even for a new row, and every upload was
  refused silently. To confirm on the live DB: `select count(*) from journey_timeline;`.
- **Supplement ticks relied on a cascade.** `ttc_supplement_taken` rows were removed by the database when their
  supplement was hard-deleted. A soft delete doesn't cascade, so the app must mark those ticks removed itself
  (on remove, and on a duplicate merge).

**Decision (user, 2026-10-17):** the timeline gets UPDATE on **own rows only**. The partner still reads but can't
change someone else's moment. "Never rewrite what she wrote" stays an app rule. The trade-off: that rule now lives
in code, not in the database.

**Done (all 2026-10-17):**
- [x] `supabase/migrations/0099_ttc_supplements_timeline_sync_clock.sql`:
  - `updated_at` and `removed_at` on `ttc_supplements`, `ttc_supplement_taken` and `journey_timeline`;
  - an own-row UPDATE policy and grant on `journey_timeline`.
- [x] `lib/ttc/ttc_supplements_store.dart`: two `TtcRowBook`s, one for the list (by id) and one for the ticks (by
  `supplementId|day`).
  - `remove` soft-deletes the supplement **and each of its ticks** (`_removeTicksOf`).
  - The duplicate `merge` records each moved tick as an old-tick removal plus a new-tick add, and soft-deletes
    the dropped rows.
  - A tick is one row per (supplement, day) whoever ticked it, so the newer tick or un-tick wins and its owner
    is kept.
  - The push sends supplements before ticks, because of the foreign key. A tick that reaches the cloud before
    its supplement is refused and waits for the next push.
  - The union pull and push-all are kept for revert.
- [x] `lib/services/family_timeline.dart`: soft `remove`, newer-wins `applyCloudRows`.
  - `add` and `refreshDerived` stamp the edit, so date corrections now travel.
  - The push sends **her own moments only**. A partner's moment is shown but never uploaded; if she removes
    one, it goes from her phone only.
  - The old comments are kept and marked superseded.
  - On the first push after 0099, every moment the phone holds uploads, because the cloud likely has none.
- [x] Tests:
  - `test/ttc_schema_contract_test.dart` reads 0099 and pins the new columns.
  - Its "the timeline stays append-only" test is commented out (kept for revert) and replaced by "everyone updates
    only their own moments (0099)". That test fails if the update policy ever mentions `my_partner_id`.
  - New `test/ttc_supplements_timeline_merge_test.dart` (9 cases):
    - a removal takes its ticks with it;
    - a newer remote un-tick is taken;
    - a duplicate merge moves each tick;
    - the partner's owner is kept;
    - the timeline's never-synced moments wait to upload;
    - removals hold both ways;
    - a date correction waits to upload.
- [x] Docs: STILL-OPEN-BACKEND and BACKEND-PATTERNS updated.

**Verified (2026-10-17):**
- `flutter analyze` is clean on both lib files.
- 55 contract tests pass, plus the 9 new cases.
- The 13 existing test files that use these stores pass, with `sync_reset_coverage_test` and step 1's merge test:
  389 tests.

**Also in this pass (2026-10-17, the user's ask, not sync work):** `lib/screens/ttc/ttc_home_v3.dart` had three
analyzer notes, reported by the other terminal:
- the unused `ttc_treatment_round.dart` import is commented out (kept for revert);
- the two route names `'hub/' + id` and `'journey/' + action` now use interpolation. The strings are unchanged,
  which matters because the route names are load-bearing.

Analyze is clean on that file, and the 20 test files that touch the home pass (557, 11 skipped).

**User must run:** 0099 in the Supabase SQL editor (DONE 2026-10-17). Until it runs, uploads from these two stores are refused, so
changes wait on the phone and the sign-out sheet says so. Nothing is lost. After it runs, it's worth re-running
`select count(*) from journey_timeline;` once the app has opened. It should then be close to the number of
moments on the phone.

**Files:**
- `supabase/migrations/0099_ttc_supplements_timeline_sync_clock.sql`
- `lib/ttc/ttc_supplements_store.dart`
- `lib/services/family_timeline.dart`
- `lib/screens/ttc/ttc_home_v3.dart` (the three analyzer lines only)
- `test/ttc_schema_contract_test.dart`
- `test/ttc_supplements_timeline_merge_test.dart`
- `docs/STILL-OPEN-BACKEND.md`
- `docs/BACKEND-PATTERNS.md`
- `docs/BACKEND-SYNC-LOG.md`

**Still owed after this step:**
- the Pregnancy and Parenting tables (§1);
- the blob stores (§2, push-before-pull first);
- the tidy-ups (§4, §5, §7).

---

## Step 3: Blob stores push before pull (the 38 `CloudSyncedStore`s)

**Dates:** started 2026-10-17 · built 2026-10-17 · committed `f32af1e` on 2026-10-17 · no migration · two-phone walk owed.

**Problem (STILL-OPEN-BACKEND §2).** The 38 blob stores (one JSON blob per user per store in `user_state`, such as
the hospital bag, cart, saved readings and journeys) push on every change, fire-and-forget, and their sync is
"cloud wins". Nothing remembered whether a push had landed. So a change made offline failed to upload, nothing
retried it, and the next resume or launch took the cloud's older blob over it. The change was lost, silently.

**Found on the way (2026-10-17):** the fix is not just reordering `SyncRegistry.resyncOnResume`, because the store
didn't know it had anything to push. "Push before pull" needs a record of what's waiting first. Also, two pushes
in flight at once could land out of order and leave the cloud with the older blob.

**Done (all 2026-10-17):**
- [x] `lib/services/remote/cloud_synced_store.dart`, the mixin, so all 38 stores get it at once:
  - **A waiting mark per store, kept on disk** (`pv_blob_waiting_<cloudKey>`). A change sets it. Only a
    confirmed upload of the newest state clears it: an edit counter, so a change mid-upload keeps it set.
  - **Push before pull:** `syncStateFromCloud`, which runs at launch, login and resume, uploads this phone's
    blob when a change is waiting, instead of taking the cloud's.
  - **One upload at a time** (`_uploadWaiting`, with a fold-in for changes that arrive mid-upload).
  - **It feeds `SyncRegistry.hasPendingChanges`**, so the sign-out sheet and Settings now cover the blob stores
    too.
  - The sign-out reset clears the mark. The key is wiped with the rest of the phone's data (`LocalWipe`).
  - `CloudBlobIo`: a test seam over the three cloud calls.
  - The old `_pushNow` is kept for revert.
- [x] Tests: new `test/blob_push_before_pull_test.dart` (5 cases):
  - cloud still wins when nothing waits;
  - an offline change survives the next sync and uploads first;
  - the mark survives a relaunch;
  - a change mid-upload ends in the newest blob;
  - a sign-out reset clears it.

**Verified (2026-10-17):**
- `flutter analyze` is clean on the mixin and the test.
- All 60 test files that name one of the 38 blob stores pass (1,080 tests), as do the sync, journal and sign-out
  tests (143).
- Wiring: every file declaring a `CloudSyncedStore` calls `syncStateFromCloud()`, so every store registers its
  waiting mark.

**The trade-off, named:** still one blob per store. With two phones, the one whose change is waiting now wins
whole, and an edit made on the other phone in the meantime is overwritten. Before, the offline phone always lost,
silently. Per-item merge inside the blob, for curated lists (hospital bag, checklists, cart, saved readings),
is the remaining §2 work.

**User runs:** nothing; no migration.

**Files:**
- `lib/services/remote/cloud_synced_store.dart`
- `test/blob_push_before_pull_test.dart`
- `docs/STILL-OPEN-BACKEND.md`
- `docs/BACKEND-PATTERNS.md`
- `docs/BACKEND-SYNC-LOG.md`

**Still owed after this step:**
- per-item merge for the curated blob lists (§2);
- Parenting logs, then Pregnancy tables (§1);
- the tidy-ups (§4, §5, §7).

---

## Step 4: The server enforces "newer wins" and refuses a clock from the future

**Dates:** asked for by the user 2026-10-17 (after an industry-standards review) · built 2026-10-17 · committed
`a0eb5b9` on 2026-10-17 · 0100 run by the user on 2026-10-17.

**Problem (found in the 2026-10-17 review, not in STILL-OPEN-BACKEND before).** Every synced row table merges
"newer wins" on the phone's edit time, but only the *phone* applied the rule, and only on a pull.
1. **An older write could overwrite a newer row.** Phone A edits offline at 10:00, phone B edits the same row at
   10:05 and uploads. A reconnects and uploads its 10:00 copy before it next pulls, and the upsert replaces B's
   newer row. B repairs it on its next sync; until then the cloud holds the older version.
2. **A phone with a wrong clock won forever.** A phone set a year ahead stamps every edit a year ahead, so it
   would beat every real edit until that date.

**Done (all 2026-10-17):**
- [x] `supabase/migrations/0100_sync_guard_newer_wins.sql`: one trigger function, `pv_sync_newer_wins`, run
  `before insert or update` on 13 tables:
  - `ttc_cycles`, `ttc_cycle_signals`, `ttc_logs`, `ttc_doctor_questions`;
  - `ttc_records`, `ttc_appointments`, `ttc_ritual`;
  - `ttc_supplements`, `ttc_supplement_taken`, `journey_timeline`;
  - `saved_items`, `journal_entries`, `father_journal_entries`.

  What it does:
  - **A stamp more than 5 minutes ahead** of the server is pulled back to the server's `now()`. It's clamped, not
    refused: a refused row would wait on the phone forever, and her change would never land.
  - **An update older than the stored row is skipped** (the trigger returns NULL). Postgres skips that row
    without an error, so the phone counts the upload as confirmed, and its next pull takes the newer row.
  - **Equal stamps pass**, so app versions from before the clock (which send no `updated_at`) still sync.
  - Nothing stamps the upload time: only a future stamp is ever changed.
  - A self-contained check block sits at the bottom of the migration, commented out. It runs in a transaction and
    rolls back.
- [x] New `test/sync_guard_contract_test.dart` (5 cases), which fails the build:
  - if a TTC table written with `updated_at` + `removed_at` has no trigger;
  - if any migration gives a table `removed_at` by `alter table` without adding the trigger;
  - if saved items or the journals lose it;
  - if the rule changes shape: no clamp, no skip, or a second assignment to `updated_at`.

**Verified (2026-10-17):** `flutter analyze` is clean on the new test; the guard and schema contract tests pass.
**Verified live (2026-10-17):** the user ran the check block on the production database. Result: `a | newer | true`
and `b | future | true`. The older write was skipped and the future clock clamped, exactly as designed.

**Not verifiable in the repo itself:** the trigger running on Postgres. There's no local database in this repo, so the check
block in the migration is how to see it working live.

**Known cost, named:** with a phone more than 5 minutes fast, every edit of that row is clamped to the server's
time. The phone keeps its own (future) stamp, so on later syncs it thinks its copy is newer and re-uploads the row.
That costs one extra upload per affected row per sync, never wrong data. It goes away when the phone's clock is
right.

**User runs:**
1. 0100 in the Supabase SQL editor (DONE 2026-10-17).
2. Optional: the check block at the bottom of the file, pasted on its own. Expect `a | newer | true` and
   `b | future | true`.

**Files:**
- `supabase/migrations/0100_sync_guard_newer_wins.sql`
- `test/sync_guard_contract_test.dart`
- `docs/BACKEND-SYNC-LOG.md`
- `docs/BEFORE-LAUNCH.md` (new; see below)
- `CLAUDE.md` (one row in "Where the detail lives")

**Also on 2026-10-17:** `docs/BEFORE-LAUNCH.md` was created at the user's request. It's one list of everything that
must be done or decided before real users, from this review and from every other doc. It's maintained from now on.
