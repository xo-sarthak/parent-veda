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
| 2026-10-17 | Step 5: Parenting logs (feeds, sleeps, nappies, pumping, tummy time, growth) | 0101 | `f7ed88e` | yes (2026-10-17) |
| 2026-10-18 | Step 6: the rest of the child record (documents, health, milestones, vaccines, emergency card) | 0104 | `af76d8f` | yes (2026-10-18) |
| 2026-10-20 | Step 7: the child profile (soft delete + restore) and the name votes | 0105 | `d76594b` | yes (2026-10-20) |
| 2026-10-20 | Step 8: Pregnancy part 1 (calendar, bump photos, the daily tables, weekly notes, reminders) | 0106 | pending | **not yet** |

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

---

## Step 5: Parenting logs (feeds, sleeps, nappies, pumping, tummy time, growth)

**Date:** 2026-10-17. **Migration:** 0101 (run 2026-10-17). **Commit:** `f7ed88e`.

**The problem (STILL-OPEN-BACKEND §1, Parenting row):** the six child-scoped log stores synced the way the TTC
tables did before 0097. All six go through one helper, `ChildSync`:
- **The pull was a union** (`ChildSync.merge`). It added what the phone lacked and kept what it held, so it could
  never take anything away. A feed one parent deleted came back from the other parent's phone.
- **A delete was one hard delete** (`ChildSync.remove`), fired once. Offline, or racing an upload, it was lost.
- **Every upsert wrote `user_id = me`**, so correcting a feed the partner logged rewrote "logged by" to you.
- **Nothing told the sign-out sheet** that a log was still waiting to upload.

**Decision (§6, 2026-10-17):** row-level, newer wins. These logs are append-only, and two parents almost never
edit the same feed, so per-field merging would cost complexity and buy nothing. This falls under the rule agreed
in step 1: ask only if a table is genuinely co-edited. None of these six is.

**Done (2026-10-17):**
- [x] Migration `0101_pp_logs_sync_clock.sql`:
  - `updated_at` and `removed_at` on `pp_feed_logs`, `pp_sleep_logs`, `pp_nappy_logs`, `pp_pump_logs`,
    `pp_tummy_logs` and `pp_growth_measurements`;
  - 0100's `pv_sync_newer_wins` trigger attached to all six;
  - RLS unchanged and still strict (insert only as yourself, update any row of your child);
  - a check query at the bottom, commented out.
- [x] `SyncRowBook` (`lib/services/remote/sync_row_book.dart`): the book `TtcRowBook` was, moved beside the rest
  of the sync plumbing so both stages share one implementation. `TtcRowBook` is now a typedef of it; the
  original class is commented out in `lib/ttc/ttc_row_merge.dart`, kept for revert. One addition: `merge` takes
  an optional `inScope` filter (see the child point below). Without it, the behaviour is identical, and every
  TTC merge test still passes.
- [x] `ChildLogLedger` (in `lib/services/remote/child_scoped_store.dart`): the per-store bookkeeping for the six
  log tables. It holds stamps, soft deletes, owners, the waiting set, and **which child each row belongs to**.
  - `pull` fetches one child's rows (removed ones included) and merges newer-wins.
  - `push` uploads waiting rows one at a time; a change made during an upload gets a second pass.
  - `uploadFor` is the pure upload decision, so it's unit-tested.
- [x] **Which child.** A store's cache can hold rows of several children, but a pull fetches one child. The
  ledger remembers each row's child. A pull of child A then neither re-uploads child B's rows under A nor
  mistakes B's removals for rows "the cloud has never seen".
- [x] **Whose row: a correction found while building, not in the plan.** The plan was "send the partner's
  `user_id` back unchanged", as in step 1. Checking the Postgres docs showed that would be **refused**:
  `insert ... on conflict do update` checks the INSERT policy's `WITH CHECK` on every proposed row, even one
  that ends up updating. These tables insert only as yourself (`auth.uid() = user_id`).
  - So a row the partner owns now goes up as a **plain UPDATE** with no `id` or `user_id` in it, through the new
    `SupabaseRepo.updateSharedConfirmed`.
  - Our own rows are still upserted.
  - The trigger guards both paths.
  - Step 1's TTC tables didn't hit this, because their policies are `for all` with "me or my partner" on both
    sides.
- [x] The six stores (`pp_feeding_data.dart`, `pp_sleep_data.dart`, `pp_growth_data.dart`, and `NappyStore`,
  `PumpStore` and `TummyStore` in `pp_care_log_data.dart`):
  - add marks the row waiting and uploads; remove is a soft delete that uploads like any other change;
  - each registers `hasPending` with `SyncRegistry` (the sign-out sheet and Settings);
  - reset clears the ledger;
  - the old `ChildSync.merge`, `.push` and `.remove` calls are commented out, kept for revert.
- [x] Not changed: `ChildSync.merge` itself, still used by documents, health, milestones and vaccines (the rest
  of the Parenting row in §1).
- [x] Tests:
  - New `test/pp_logs_merge_test.dart` (14 cases): a removal survives an older live copy; the partner's newer
    removal removes it here; newer edits win both ways; a pre-release cached row loses to the cloud; a pull of one
    child leaves another's rows alone; Undo ends live; the partner's row goes as an UPDATE with no `user_id`; ours
    is an upsert; a removal carries its NOT NULL columns; nothing is sent before a child exists; seed rows never
    enter the book; the book survives a restart; a source scan checks all six stores are wired and call none of
    the old helpers.
  - `test/sync_guard_contract_test.dart` now reads the trigger list from every migration that attaches the guard
    (0100 and 0101), plus one new case for the six tables.

**Verified (2026-10-17):**
- `flutter analyze` is clean on every touched file.
- 1,038 tests pass: every `pp_*` and `post_pregnancy_*` file, plus all the sync and TTC merge tests.

**Known limits, named:**
- **Mixed versions.** Until both parents update, the old app still hard-deletes and still writes `user_id = me`.
  A row the old app hard-deleted, but the new app holds with a stamp, is re-uploaded. That's the union's old
  behaviour, not a new loss.
- **Rows cached before this release** carry no stamp. Where the cloud has a copy, the cloud's copy wins.

**User runs:**
1. 0101 in the Supabase SQL editor (DONE 2026-10-17).
2. Optional: the check query at the bottom of the file. Expect six rows, all `true`.

**Verified live (2026-10-17):** the user ran the check query on the production database. All six tables
(`pp_feed_logs`, `pp_growth_measurements`, `pp_nappy_logs`, `pp_pump_logs`, `pp_sleep_logs`, `pp_tummy_logs`)
returned `true` for `has_updated_at`, `has_removed_at` and `guarded`.

**Owed:** the two-phone walk for a parenting log (both parents on one child): log a feed on A, delete it on B,
sync A, and check it stays gone. Then correct a feed the other parent logged, and check "logged by" doesn't
change.

**Files:**
- `supabase/migrations/0101_pp_logs_sync_clock.sql` (new)
- `lib/services/remote/sync_row_book.dart` (new)
- `lib/services/remote/child_scoped_store.dart`
- `lib/services/remote/supabase_repo.dart`
- `lib/ttc/ttc_row_merge.dart`
- `lib/screens/post_pregnancy/pp_feeding_data.dart`, `pp_sleep_data.dart`, `pp_growth_data.dart`,
  `pp_care_log_data.dart`
- `test/pp_logs_merge_test.dart` (new), `test/sync_guard_contract_test.dart`
- `docs/BACKEND-SYNC-LOG.md`, `docs/STILL-OPEN-BACKEND.md`, `docs/BEFORE-LAUNCH.md`, `docs/BACKEND-PATTERNS.md`

---

## Step 6: The rest of the child's record (documents, health, milestones, vaccines, emergency card)

**Date:** 2026-10-18 (planned and approved 2026-10-17). **Migration:** 0104 (run 2026-10-18). **Commit:** `af76d8f`.

**Numbering note:** this was written as 0103. The other terminal created `0103_ttc_partner_cannot_delete.sql` at
the same time, so this one became 0104. The two touch different tables.

**The problem (STILL-OPEN-BACKEND §1, the rest of the Parenting row).** Everything step 5 found, plus one bug
each:

| Area | Bug |
|---|---|
| Documents; health records (medicines, prescriptions, allergies, symptoms, reports, doctor visits) | Union pull, hard delete, and an upsert as me over the other parent's rows (step 5's three bugs) |
| Doctor questions | Matched by **text**, with no client id: removing one removed every copy, and the same question asked twice became one |
| Emergency card | The cloud copy always won, so an offline edit was lost; **Clear never reached the cloud**, so the card came back |
| Milestones | The cloud overwrote everything, so un-ticking came back |
| Vaccines | The pull only ever **added** doses, so un-ticking never reached the other phone. A synced reminder showed "Alarm set" on a phone with no alarm armed |

**Decisions (the user, 2026-10-17):**
- Health rows and documents: **latest edit wins**, whole row.
- Emergency card: **latest save wins**, whole card, and Clear syncs.
- Vaccine reminders: **shared**. "Both should" buzz. So the reminder time syncs, and each phone arms its own
  alarm.

**Done (2026-10-18):**
- [x] Migration `0104_pp_records_sync_clock.sql`:
  - `updated_at` + `removed_at` on documents, the six health tables, questions and milestone observations;
  - `removed_at` on the card, which already had `updated_at`;
  - `updated_at` + `reminder_at` on vaccine doses. A dose row is state, so un-ticking sends `done = false`, and
    the table needs no `removed_at`;
  - 0100's guard on all 11 tables;
  - RLS unchanged, and a check query at the bottom.
- [x] **`ChildLogLedger` gains a keyed mode** (`keyColumn`) for the composite-key tables. The book id is
  `<child>|<key>`, so the same milestone of two children is two rows.
  - The upsert conflicts on `child_id,<key>`.
  - A row the other parent owns is an UPDATE matched on child + key, through the new
    `SupabaseRepo.updateChildRowConfirmed`.
  - `lastRows` keeps a changed row's columns, so a child not on screen can still upload.
  - `keysFor(child)` lists every key the book remembers. Without it, a dose un-ticked here (now in no local set)
    would lose to the cloud's older "done".
  - Defaults unchanged, so step 5's six stores are untouched.
- [x] **`ownerIsLastEditor`** for the emergency card: its UPDATE policy also requires `auth.uid() = user_id`, so it
  can't be saved under the other parent's name. It's always upserted as us, and "owner" means last editor.
  **`hasRemovedAt: false`** for vaccine doses.
- [x] Stores:
  - **`BabyDocumentsStore`**: add and edit touch; remove is a soft delete.
  - **`HealthStore`**: one ledger per table.
    - The six record tables pull with `_pullTable`. `_push` and `_remove` now go through the ledger, so the
      add/edit call sites didn't change. Removals carry their columns.
    - **Questions** now have ids (`_questionIds`, index for index, so no screen changed). On the first sync after
      the update, `adoptQuestionIds` gives a question saved before ids the id of a live cloud row with the same
      text. Two equal questions claim two rows, or get a new id.
    - **The card**: save touches, and Clear is a soft delete that syncs.
    - The old `_mergeTable`, `_mergeQuestions`, `_mergeEmergency`, `_pushEmergency`, `_pushKept` and
      `_removeKept` are kept for revert.
  - **`MilestoneStore`**: keyed ledger; un-ticking is a soft delete.
  - **`VaxStore`**: keyed ledger. Each row carries `done`, `done_at`, `reminder` and `reminder_at`.
    - **The store arms the alarm now, not the screens.** `setReminder(id, on, at:)` arms or cancels it.
    - After every pull, the pure `vaxAlarmChanges(before, after, now)` says which alarms to arm, re-arm or
      cancel. A time already passed is never armed. A dose marked given cancels its alarm.
    - The alarm text moved into `vaxReminderText`, so both phones write the same reminder.
    - `vaxAlarmId` is one id helper, with the same value as before, so alarms armed by older versions can
      still be cancelled.
- [x] **Found on the way and fixed:** switching a vaccine reminder **off never cancelled the phone alarm**. The
  screens armed it, and nothing ever cancelled it. The store now cancels it.
- [x] **Planned but not done, on purpose:** "keep this phone's attachments when taking a cloud row". Reading
  `pp_attachments.dart` showed attachments already upload to Storage and sync as storage paths (closed
  2026-10-07). So they sync like any other column, and the rule would have been wrong.
- [x] Tests:
  - New `test/pp_records_merge_test.dart` (22 cases), covering:
    - **keyed tables:** an un-ticked milestone stays un-ticked; two children, two rows; the other parent's keyed
      row is an UPDATE on child + key; our own upserts on the composite key; a child not on screen still
      uploads; no child, no booking;
    - **vaccines:** an un-ticked dose beats an older "done", and sends no `removed_at`; the dose row
      round-trips the reminder time;
    - **the card:** always saved as us; Clear uploads with the card; the other parent's newer Clear clears it
      here;
    - **questions:** adoption by text; two equal questions stay two; a removed row is never adopted;
    - **the alarm plan:** arm, cancel, move, no-op, skip-past, and one id;
    - **a source scan** that the four stores are wired and the two screens no longer arm alarms.
  - `test/sync_guard_contract_test.dart`:
    - it now reads only the `do $$` block that creates the trigger (0104 also loops to add columns);
    - one new case for the 11 tables.

**Verified (2026-10-18):**
- `flutter analyze` is clean on every touched file.
- 1,119 tests pass across 110 files: every Parenting test, plus every sync, schema and TTC merge test.

**Known limits, named:**
- **One row, two facts.** A vaccine row holds both "given" and "reminder". Under row-level newer-wins, if one
  parent marks the dose given while the other sets its reminder at the same moment, the later save wins whole.
  That's rare, and it's what the user chose for health rows.
- **Mixed versions.** Until both phones update, the old app still hard-deletes and still writes `user_id = me`,
  as in step 5.

**User runs (DONE 2026-10-18):**
1. 0104 in the Supabase SQL editor.
2. Optional: the check query at the bottom. Expect 11 rows. `has_clock` and `guarded` should be true on every row;
   `has_removed_at` true on all but `pp_vaccine_doses`, which has `has_reminder_at` instead.

**Verified live (2026-10-18):** the user ran 0104 and the check query. All 11 rows have `has_clock` and
`guarded` true; `has_removed_at` is true on all but `pp_vaccine_doses`, which has `has_reminder_at` instead, as
expected.

**Owed (the two-phone walk):**
- set a vaccine reminder on phone A; phone B buzzes at the same time;
- switch the reminder off on B; A stops too;
- un-tick a dose on B; A shows it un-ticked;
- clear the emergency card on A; it stays cleared on B;
- remove an allergy offline; it stays removed.

**Files:**
- `supabase/migrations/0104_pp_records_sync_clock.sql` (new)
- `lib/services/remote/child_scoped_store.dart`, `lib/services/remote/supabase_repo.dart`
- `lib/screens/post_pregnancy/pp_documents_data.dart`, `pp_health_data.dart`, `pp_milestones_data.dart`,
  `pp_vaccine_data.dart`, `vax_detail_screen.dart`, `vax_tracker_screen.dart`
- `test/pp_records_merge_test.dart` (new), `test/sync_guard_contract_test.dart`
- `docs/BACKEND-SYNC-LOG.md`, `docs/STILL-OPEN-BACKEND.md`. `docs/BEFORE-LAUNCH.md` and `docs/BACKEND-PATTERNS.md`
  follow once the other terminal has committed its edits to them.

---

## Step 7: The child profile and the name votes

**Date:** 2026-10-20 (planned and approved 2026-10-20). **Migration:** 0105 (run 2026-10-20). **Commit:** `d76594b`.

**The problem (STILL-OPEN-BACKEND §1, the last two Parenting rows).**

| Area | Bug |
|---|---|
| Child profile (`children`) | The pull took the cloud copy whole, so an **offline edit was lost** |
| | A removed child **came back**: the other parent's phone still held it and inserted it again, now under their own name |
| | The removal was a **hard delete**, which took the id out of `my_child_ids()`. Every `pp_*` policy gates on it, and no `pp_*` table has a foreign key to `children`, so the child's records stayed in the database where **neither parent could read them** |
| | Logging growth wrote the child row as an edit, so under newer-wins a weight logged on a phone that hadn't pulled would undo the other parent's rename |
| Name votes (`pp_name_votes`) | The pull adopted only "liked" rows and re-uploaded every name still liked on the phone, so a **skip made offline, or on the other phone, came back as a like** |
| | Likes were never saved on the phone (only in the cloud), and stayed in memory after a sign-out |

**Decisions (the user, 2026-10-20):**
- Child profile: **whole row, latest edit wins**. The growth figures **don't count as an edit**.
- Removing a child: **soft delete**, records kept, **with a way to restore**.
- Name votes needed no decision: 0027 makes them own-rows-only (neither parent can read the other's), so it's
  single-person data.

**Done (2026-10-20):**
- [x] Migration `0105_pp_children_votes_sync_clock.sql`:
  - `updated_at` + `removed_at` on `children`; `updated_at` on `pp_name_votes` (a skip is `liked = false`, so no
    `removed_at`);
  - 0100's guard on both;
  - **`my_child_ids()` deliberately unchanged**, so a removed child's records stay reachable and a restore brings
    them back. RLS unchanged. Check query at the bottom.
- [x] **`ChildProfileStore`** (`pp_child_profile.dart`):
  - A `SyncRowBook`, saved beside the children (`pp_children_sync`), feeding the sign-out pending check.
  - Pure `childrenMerge` (newer wins per child, removals included) and `childUploadFor`: a child the other parent
    created goes as a plain UPDATE with **no `id` or `user_id`**; any other is upserted as us.
  - `addChild`, `update`: stamp, then push through the book. `deleteChild`: soft delete; the child moves to a
    `_removed` list (`pp_children_removed`). New `restoreChild` and `removedChildren`.
  - New **`setMeasures`**: changes the figures and queues the row **without a new stamp** (the guard lets an equal
    stamp through, skips an older one). A taken cloud row keeps this phone's figures. `pp_growth_data.dart` calls it
    in place of `update`.
  - The old insert / `updateShared` / `deleteShared` calls and the old pull (`_syncFromCloudOld`) are kept for
    revert.
- [x] **`NameMatchStore`** (`pp_names_data.dart`):
  - A `_skipped` set and a `SyncRowBook` keyed by name, saved on the phone (`pp_name_votes_local`) with the likes.
  - Pure `nameVotesMerge`; `like`, `skip` and `crown` stamp the vote; only waiting votes go up, as us, through
    `upsertRowConfirmed` on `user_id,name`. Matches refresh after.
  - A sign-out now clears the votes in memory too. The crown stays in the blob (step 10).
- [x] **Restore in the UI** (pattern from Messages' "Recently Deleted" and Notion's Trash, via Mobbin):
  - The remove dialog on the child's page now says the records are kept and where to bring the child back; after
    removing, an Undo toast.
  - The You screen shows a **"Removed children"** row (only while there is one) in both the Pregnancy and
    Parenting children groups. It opens a sheet with one row per child and a Restore pill; restoring says
    "<name> is back, with their records."
- [x] Tests:
  - New `test/pp_children_sync_test.dart` (12 cases): offline edit survives; the other parent's newer edit wins; a
    taken row keeps this phone's figures; a removal stays removed when the other phone holds the child; a restore
    beats the older removal; a removal uploads with `removed_at` and its columns; the other parent's child goes as
    an UPDATE with no `user_id`; a new child is upserted as ours; a skip made offline stays skipped; a stale like
    doesn't bring a name back; a new like waits to upload; a source scan of the wiring.
  - `test/sync_guard_contract_test.dart`: both tables guarded, and 0105 doesn't redefine `my_child_ids()`.

**Verified (2026-10-20):**
- `flutter analyze` on every touched file: no new issues (one older `dead_code` warning at
  `pv_you_screen.dart:2525`, an `if (false)` kept for revert).
- 221 tests pass across 20 files: the child, profile, names, growth and You tests, plus every sync, merge, reset and
  schema contract test.

**Known limits, named:**
- **Whole row.** Two parents editing different fields of the profile at the same moment: the later save wins whole.
  Rare; the user chose it.
- **The growth figures in the cloud can lag.** They go up only with an equal-or-newer stamp. Each phone works them
  out from the growth log, so nothing reads the cloud copy (only `delete-account` touches `children` server-side).
- **Mixed versions.** Until both phones update, the old app still hard-deletes and inserts a missing child again.

**User runs (DONE 2026-10-20):** the user ran 0105. The optional check query result was not reported.

1. 0105 in the Supabase SQL editor, **before** installing a build with this change (until then the uploads carry
   columns the table lacks, are refused, and simply wait).
2. Optional: the check query at the bottom. Expect 2 rows, `has_clock` and `guarded` true on both, `has_removed_at`
   true for `children` only.

**Owed (the two-phone walk):**
- rename the child on A while B logs a weight → the new name holds on both;
- remove a child on A → it stays gone on B; restore it on B → it's back on A, with its feeds and vaccines;
- skip a liked name offline → it stays skipped after reconnecting, and on the other phone signed in to the same
  account.

**Files:**
- `supabase/migrations/0105_pp_children_votes_sync_clock.sql` (new)
- `lib/screens/post_pregnancy/pp_child_profile.dart`, `pp_names_data.dart`, `pp_growth_data.dart`
- `lib/screens/profile/pv_child_screen.dart`, `pv_you_screen.dart`, `pv_you_sheets.dart`
- `test/pp_children_sync_test.dart` (new), `test/sync_guard_contract_test.dart`
- `docs/BACKEND-SYNC-LOG.md`, `docs/STILL-OPEN-BACKEND.md`, `docs/BACKEND-PATTERNS.md` (§16ii-h, reading list 38),
  `docs/BEFORE-LAUNCH.md`

---

## Step 8: Pregnancy part 1 (calendar, bump photos, the daily tables, weekly notes, reminders)

**Date:** 2026-10-20 (planned and approved 2026-10-20). **Migration:** 0106 (**not yet run**). **Commit:** pending.

**No merge decision was needed.** All nine tables are own-only: every policy is `auth.uid() = user_id`, and none
mentions `my_partner_id()`. The father's phone writes only his own rows. So the rule is her cycle's: the phone's
edit time wins (§16ii).

**The problem (STILL-OPEN-BACKEND §1, the first half of the Pregnancy rows):**

| Table | Store | Bug |
|---|---|---|
| `calendar_personal_events` | `CalendarStore` | Cloud wins per id, and a row only this phone holds is inserted again, so a deleted note comes back. The delete is a one-shot hard delete |
| `bump_photos` | `BumpStore` | Same, and the hard delete **left the photo in Storage** for good |
| `baby_talk` | `DailyStore` | Re-saving a day did a hard delete then an insert **under a new id**, so two phones each held a different "today" |
| `daily_moods` | `DailyStore` | Local days were never dropped, so a mood cleared on another phone was pushed back |
| `kept_affirmations` | `DailyStore` | A **union**: an un-kept affirmation could never leave |
| `daily_movement_responses` | `DailyStore` | The cloud overwrote local answers, and the existing `updated_at` was never used |
| `father_missions` | `DailyStore` (his phone) | A union, so un-done came back. **No UPDATE policy**, so an upsert would be refused (the 0099 trap) |
| `weekly_journal_notes` | `MemoryStore` | Cloud wins per id, and a local row is inserted again; hard delete |
| `reminders` | `ReminderStore` | Same, and a reminder removed on one phone **kept buzzing** on the other |

None of the five stores fed the sign-out "unsent changes" warning.

**Done (2026-10-20):**
- [x] **New `OwnRowLedger`** (`lib/services/remote/own_row_ledger.dart`). It is `ChildLogLedger` without the child:
  - no "which child" and no "whose row"; every row is upserted as us;
  - keyed mode (`keyColumn: 'day'` or `'text'`): the key's value is the book id, and the upsert conflicts on
    `user_id,<key>`;
  - state mode (`hasRemovedAt: false`): no `removed_at` is sent, and every stamped key takes part in the merge;
  - `onRemovalConfirmed`: a clean-up that must wait until the cloud has taken the removal (a Storage file).
  - Step 9 reuses it. `ChildLogLedger` is untouched.
- [x] Migration `0106_preg_part1_sync_clock.sql`:
  - `updated_at` where it was missing;
  - `removed_at` on all but `daily_movement_responses` (a state answer);
  - **an own-row UPDATE policy on `father_missions`**;
  - 0100's guard on all nine;
  - a check query at the bottom.
- [x] Stores, with the old calls and the old pull (`_syncFromCloudOld`) kept for revert:
  - **`CalendarStore`**: add and edit stamp the row; delete is soft.
  - **`BumpStore`**:
    - add, favourite, caption and the media backfill stamp the row; delete is soft;
    - **the Storage file is removed once the cloud confirms the removal**, so a failed upload never leaves the other
      phone with a row pointing at nothing;
    - a removal taken from the cloud deletes this phone's local file.
  - **`DailyStore`**: five ledgers.
    - `saveTalk` **keeps the day's id** and edits in place.
    - Clearing a mood, un-keeping an affirmation and un-doing a mission are soft deletes.
    - Movement is state.
  - **`MemoryStore`**:
    - add and edit stamp the row; delete is soft;
    - local files go at once, the Storage copies after confirmation;
    - a removal taken from the cloud deletes this phone's copies.
  - **`ReminderStore`**: upsert, toggle and the reword stamp the row; remove is soft. **The pull keeps the alarms in
    step**: a reminder taken from the cloud cancels this phone's alarm, then re-arms it if it is on (§16ii-g).
  - Every store registers `SyncRegistry.registerPending` and clears its ledger on sign-out.
- [x] Tests:
  - New `test/own_row_ledger_test.dart` (13 cases):
    - newer wins either way;
    - a removal stays removed;
    - the other phone's removal is taken;
    - a legacy row takes the cloud's copy;
    - a new row waits;
    - the upload carries times and columns;
    - keyed rows get their key and conflict target;
    - a cleared mood uploads with its typed key;
    - an un-kept affirmation stays gone;
    - a state row sends no `removed_at` and is never beaten by an older answer;
    - logged out, nothing is sent.
  - New `test/preg_part1_sync_test.dart` (5 cases):
    - re-saving a day's talk keeps one id;
    - every store uses the ledger and reports pending;
    - no live hard delete is left;
    - the reminder pull cancels and re-arms;
    - Storage waits for confirmation.
  - `test/sync_guard_contract_test.dart`: the nine tables are guarded; `father_missions` has its UPDATE policy.

**Verified (2026-10-20):**
- `flutter analyze` is clean on the six source files and three test files.
- 237 tests pass across 18 files: the Pregnancy store tests (bump ritual, Dear Baby vault, letter book, calendar
  hub, messages, sign-out mute, reminder words), the reset coverage, and every sync, merge and schema test.

**Known limits, named:**
- **The media backfill stamps the row.** When a photo first reaches Storage, the new path is a real change other
  phones need, so it counts as an edit. A caption changed at that same moment on another phone could lose to it.
  Rare: the backfill runs on the phone that took the photo, soon after.
- **Calendar dates are sent without an offset** (unchanged from before). Worth a look if her two phones are ever in
  different time zones.
- **Mixed versions.** Until both phones update, the old app still hard-deletes and re-inserts.

**User runs (OWED):**
1. 0106 in the Supabase SQL editor, **before** installing a build with this change. Until then the uploads carry
   columns the tables lack, are refused, and simply wait.
2. Optional: the check query at the bottom. Expect 9 rows:
   - `has_clock` and `guarded` true on every row;
   - `has_removed_at` true on all but `daily_movement_responses`;
   - `has_update_policy` true for `father_missions`.

**Owed (the two-phone walk, one account):**
- delete a calendar note offline → it stays gone;
- clear today's mood on A → cleared on B;
- un-keep an affirmation → it stays un-kept;
- remove a reminder on A → B stops buzzing;
- delete a bump photo → it's gone on B, and its file is gone from Storage.

**Files:**
- `supabase/migrations/0106_preg_part1_sync_clock.sql` (new)
- `lib/services/remote/own_row_ledger.dart` (new)
- `lib/services/calendar_store.dart`, `bump_store.dart`, `daily_store.dart`, `memory_store.dart`,
  `reminder_store.dart`
- `test/own_row_ledger_test.dart` (new), `test/preg_part1_sync_test.dart` (new),
  `test/sync_guard_contract_test.dart`
- `docs/BACKEND-SYNC-LOG.md`, `docs/STILL-OPEN-BACKEND.md`, `docs/BACKEND-PATTERNS.md` (§16ii-i, reading list 39),
  `docs/BEFORE-LAUNCH.md`
