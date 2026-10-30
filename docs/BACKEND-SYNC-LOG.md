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
| 2026-10-20 | Step 8: Pregnancy part 1 (calendar, bump photos, the daily tables, weekly notes, reminders) | 0106 | `d5787b2` | yes (2026-10-21) |
| 2026-10-21 | Step 9: Pregnancy part 2 (medicines, scans and appointments, symptoms, the tools) | 0107 | `a728ec4` | yes (2026-10-21) |
| 2026-10-21 | Steps 11 and 12: every write of her data confirmed, batched first sync, sign-out forgets memory and stops alarms, the 90-day purge | 0109 | `984836f` | yes (2026-10-21) |
| 2026-10-22 | Step 13: nothing she makes lives only on the phone; every light store merges item by item (the non-shopping half of step 10) | 0110 | `8c466d0` | yes (2026-10-22) |
| 2026-10-24 | Step 14: rows keyed per person, so two people's same-named ids never collide (B9) | 0113 | `b474f69` | yes (2026-10-25) |

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

**Date:** 2026-10-20 (planned and approved 2026-10-20). **Migration:** 0106 (run 2026-10-21, checked: 9 of 9). **Commit:** `d5787b2`.

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

**User runs (DONE 2026-10-21: 0106 run, the check query returned all 9 rows as expected):**
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

---

## Step 9: Pregnancy part 2 (medicines, scans and appointments, symptoms, the tools)

**Date:** 2026-10-21 (planned and approved 2026-10-21). **Migration:** 0107 (run 2026-10-21, checked: 10 of 10, and the severity check lists 'strong'). **Commit:** `a728ec4`.

**The policies were read first (step 8's lesson):**
- All ten tables already had an own-row UPDATE policy (0003, 0005, 0006), so there was no `father_missions` trap.
- `completed_scans` and `appointments` are partner-**readable** (0012) but written only by her.
- So no merge decision was needed. Her rows sync newer-wins by the phone clock, and his copy stays a separate
  read-only fetch (BACKEND-PATTERNS §16ii-j).

**The problem (STILL-OPEN-BACKEND §1, the second half of the Pregnancy rows):**

| Table | Store | Bug |
|---|---|---|
| `medications` | `MedicineStore` | Cloud wins per id, and local-only rows were inserted again, so a delete came back. **`alarms` was never sent and the pull dropped it, so every sync wiped her medicine alarms** |
| `medication_logs` | `MedicineStore` | Un-tick was a hard delete; a re-tick made a new `ml_` id, so two phones could hold two logs for one day |
| `completed_scans` | `ScansStore` | Un-mark was a one-shot hard delete, so it came back |
| `appointments` | `ScansStore` | Hard delete. The scan timeline's edit deleted and re-added the row, **dropping doctor, notes and status** |
| `symptom_logs` | `SymptomStore` | A new timestamp id on every log; a severity change was a partial one-shot update. **The door's `'strong'` broke the table's check (`mild/moderate/severe`), so every "Strong" log had been refused since 2026-09-22, silently** |
| `weight_profile` | `ToolsStore` | The cloud overwrote an offline edit, and `updated_at` never moved |
| `weight_entries` | `ToolsStore` | One-shot hard delete; a deleted entry came back |
| `movement_sessions` | `ToolsStore` | Cloud wins per id |
| `kegel_state` | `ToolsStore` | The cloud overwrote an offline change to the routine |
| `contraction_sessions` | `ToolsStore` | An edit that failed offline was overwritten by the cloud |

None of the four stores fed the sign-out "unsent changes" warning. And one failing table in `ToolsStore`'s pull
skipped every table after it.

**Done (2026-10-21):**
- [x] **`OwnRowLedger.single`** (`lib/services/remote/own_row_ledger.dart`) for one-row tables:
  - a constant book key (`'me'`);
  - a conflict on `user_id` alone;
  - no `removed_at`;
  - a pull ordered by `updated_at`.
  - The existing modes are unchanged.
- [x] Migration `0107_preg_part2_sync_clock.sql`:
  - `updated_at` on the eight tables that lacked it;
  - `removed_at` on the eight list tables. Not on `weight_profile` or `kegel_state`, which are state;
  - **`medications.alarms` (jsonb)**;
  - **`symptom_logs.severity` also accepts `'strong'`**;
  - 0100's guard on all ten;
  - check queries at the bottom.
- [x] Stores, with the old calls and the old pull (`_syncFromCloudOld`) kept for revert:
  - **`MedicineStore`**: two ledgers.
    - `alarms` rides on the row. A row from before 0107 (`alarms` null) keeps this phone's alarms and sends them up
      once.
    - Log ids are `ml_<medicine>_<day>`. Un-tick soft-removes every log for that medicine and day, old duplicates
      included.
    - `deleteMed` soft-removes the medicine and its logs.
    - **After a pull, a medicine removed elsewhere cancels its alarms here, and a changed one is re-armed.**
  - **`ScansStore`**: `completed_scans` keyed on `scan_id`, `appointments` on `id`.
    - Un-mark and delete are soft.
    - **The partner's fetch drops his removed rows** (`notRemoved`).
    - `clearAllForTesting` soft-removes through the ledgers.
  - **`scan_timeline_screen.dart`**: an edit is `updateAppointment`, carrying doctor, notes and status across.
  - **`SymptomStore`**: ids are `sl_<day>_<symptom>`. `setOn` is a whole-row edit in place; `log` replaces the day's
    cell (an older timestamp-id entry is soft-removed); `unlogOn` is soft.
  - **`ToolsStore`**: five ledgers, two of them `.single`.
    - A weight entry deletes softly.
    - Movement: only ended sessions with a movement are rows; ending one, or closing a dangling one, stamps it.
    - A contraction save stamps its session.
    - The profile and the kegel routine stamp on every change, and the pull now saves them to the phone (it
      didn't before).
    - **Each table pulls in its own `try`.** Kegel history stays a blob (step 10).
  - Every store registers `SyncRegistry.registerPending` and clears its ledgers on sign-out.
- [x] Tests:
  - `test/own_row_ledger_test.dart`: one-row mode (conflict on `user_id`, no `removed_at` and no `id`; newer cloud
    taken; older cloud loses).
  - New `test/preg_part2_sync_test.dart`:
    - a medicine log id is one per medicine per day;
    - tick, un-tick, tick revives the same row;
    - a severity change keeps one log under one id;
    - the partner's removed rows are hidden;
    - every store uses the ledger and reports pending;
    - no live hard delete or clear is left;
    - alarms ride on the row and are rebuilt after a pull;
    - the scan timeline edits in place;
    - 0107 allows `'strong'` and adds `alarms`.
  - `test/sync_guard_contract_test.dart`: the ten tables are guarded.

**Verified (2026-10-21):**
- `flutter analyze` is clean on the six source files and three test files.
- 485 tests pass across 31 files:
  - every sync, merge and schema test, the reset coverage and the sign-out tests;
  - step 8's tests;
  - the Pregnancy tool screens: movement, kegel, symptoms door, scan journey, scan notes, calendar hub, doctor
    notes, home;
  - the TTC medication and tools tests (they share `MedicineStore`).

**Known limits, named:**
- `weight_entries.time_iso` is sent without a time zone offset, and `contraction_sessions.date_iso` is a `date`
  column, so a contraction session loses its time of day in the cloud. Both predate this step.
- Logs of a medicine deleted on another phone, which this phone never held, stay in the cloud, orphaned. Nothing
  shows them; step 12's purge is the place for them.
- Scan notes (`_notes`) are still local-only (STILL-OPEN §63.9).
- A symptom's Journal entry is never removed when the symptom is (this predates the step).
- The Symptoms Companion's "noted N times this week" now counts days, since a symptom is one log per day.
- **Mixed versions.** Until both phones update, the old app still hard-deletes and uses timestamp ids.

**User runs (DONE 2026-10-21: 0107 run, the check query returned all 10 rows as expected and the severity check lists 'strong'):**
1. 0107 in the Supabase SQL editor, **before** installing a build with this change. Until then the uploads carry
   columns the tables lack, are refused, and simply wait.
2. Optional: the check queries at the bottom.
   - **The first should return 10 rows:**
     - `has_clock` and `guarded` true on every row;
     - `has_removed_at` true on all but `weight_profile` and `kegel_state`;
     - `has_alarms` true for `medications` only.
   - **The second** should list `'strong'` in the severity check.

**Owed (the two-phone walk, one account):**
- set a medicine alarm on A → B buzzes too;
- delete the medicine on A → B stops buzzing;
- tick the same medicine on both offline → one log;
- un-mark a scan → it stays un-marked, and the partner no longer sees it;
- change a symptom to Strong on A → B shows Strong;
- delete a weight entry offline → it stays gone;
- change the kegel routine on A → B has it.

**Files:**
- `supabase/migrations/0107_preg_part2_sync_clock.sql` (new)
- `lib/services/remote/own_row_ledger.dart`
- `lib/services/medicine_store.dart`, `scans_store.dart`, `symptom_store.dart`, `tools_store.dart`
- `lib/screens/brackets/scan_timeline_screen.dart`
- `test/own_row_ledger_test.dart`, `test/preg_part2_sync_test.dart` (new), `test/sync_guard_contract_test.dart`
- `docs/BACKEND-SYNC-LOG.md`, `docs/STILL-OPEN-BACKEND.md`, `docs/BACKEND-PATTERNS.md` (§16ii-j, §16ii-k, reading list
  40–41), `docs/BEFORE-LAUNCH.md`

---

## Steps 11 and 12: uploads nobody watched, batched first sync, sign-out really forgets, the purge

**Date:** 2026-10-21 (planned and approved 2026-10-21). **Migration:** 0109 (run 2026-10-21; `pv-purge-removed` is cron job 3, active, `15 4 * * *`). **Commit:** `984836f`
(one commit for both: `saved_store.dart`, `cycle_store.dart` and `ttc_log_store.dart` carry changes from each).

**Why now, before step 10.** Step 10's shopping half (cart, orders, bought, product checklists) is to be rebuilt as
a marketplace, and designing those twice would waste one of the designs. Steps 11 and 12 touch no shopping code. Two
read-only sweeps found more than the docs listed.

### Step 11: every write of her data is confirmed, and first sync goes in batches (no migration)

- [x] **Batches.**
  - `SyncBatch.push` (`lib/services/remote/sync_batch.dart`) and `SupabaseRepo.upsertRows`, which returns `SyncSend`
    (ok / refused / offline).
  - Rows go 100 per request, grouped by column set.
  - A refused batch is retried row by row, so one bad row cannot hold back 99.
  - Offline stops the round at once.
  - Used by `OwnRowLedger`, `ChildLogLedger` (own rows; partner rows stay single UPDATEs), `CycleStore`,
    `TtcLogStore` and the doctor questions.
  - The row-at-a-time loops are kept for revert, commented out.
- [x] **The last silent writes of her data, now confirmed and each keeping a waiting mark the sign-out sheet reads:**
  - **TTC journey, ready plan, treatment, life stage:** `sendTracked` in the TTC mixin, plus a waiting mark on disk.
    The mixin's `hasPendingPush` used to be a constant `false`.
  - **Doctor questions:** used to re-send every row on every push through `upsertAll`, which swallowed errors. Now
    only rows whose `updatedAt` the cloud has not confirmed go up, and they go in batches.
  - **Saved items:**
    - `upsertRowConfirmed`, a waiting set on disk, and `registerPending`;
    - the old `.catchError(PvSyncHealth.report)` could never fire, because `upsertRow` had already swallowed the
      error.
  - **Journals:** the sync already retried. The pending check was missing: tombstones, entries never seen, and
    failed edits.
  - **Profile writes** (due date, due-date source, the due date cleared, her name, the father's role):
    `PendingProfile.send`, which keeps a failed change and drops an older waiting value of the same column once a
    newer one lands.
- [x] **Found: onboarding's stashed answers were never sent.** Onboarding V3 keeps her name, role, due date and
  WhatsApp choice in `PendingProfile` when the write fails or there is no session yet. Only the retired
  `AuthFlowScreen` ever called `flush()`. `SyncRegistry.resyncAll` now calls it on every sign-in and resume, and the
  sign-out sheet counts it.
- [x] **Guard:** `test/no_silent_user_writes_test.dart`.
  - It scans the live source, skipping comments and the methods kept for revert.
  - A fire-and-forget write fails the build unless its file is on a short list with a reason: orders (marketplace),
    referral, doctor app, Can-I misses, WhatsApp prefs (reports failure), the old auth screen's confirmed write.
- [x] Tests: `test/sync_batch_test.dart` (chunking, column groups, the bad-row fallback, offline stop).

### Step 12: sign-out really forgets, the purge, the small items (migration 0109)

- [x] **Found: sign-out un-muted the phone.**
  - `pvSignOut` set the mute, then the wipe's `prefs.clear()` deleted it. The mute now runs after the wipe.
  - **Found: deletion and account switch never stopped the alarms.** `LocalOwner.wipeThisPhone` now cancels every
    scheduled notification (`NotificationService.cancelAllScheduled`). `DeleteAccount.run` also mutes after its
    wipe.
  - This also covers §7's trigger-shot reminders 918001 and 918002.
- [x] **Phone-only stores forget the person in memory** (§4):
  - 45 singletons now register a memory-only reset, including `TtcReadStore`, found by the scan. The list:
    BreastTimer, prescriptions, care partner + presence, conditions, Garbh journal, memories, referral, birth club,
    the five skilling stores (child + PIN, journal, portfolio, practice, voice), birth plan, Dear Baby vault,
    pregnancy ended, profile photo, checklists, learn progress, the three search stores, tool usage, prepare,
    credits, entitlements, the three messages stores, BMI, fertility help, PCOS check, self-check, vaccines, the
    Garbh course, TTC home prefs, content prefs, symptom categories, tool recents, the last page read, product
    votes, landing focus, the arrival prompt.
  - The files a reset deletes stay on disk; only memory is cleared.
- [x] **Device settings now survive a sign-out** (`LocalWipe.keep`):
  - the install's own ids: Play referrer checked, analytics install id. Wiping them counted one phone as two
    installs;
  - the phone's display and sound settings: FAB hidden, cue sound, size view, block art, baby voice mutes, TTC
    reading language, size set.
  - Each is pinned to its source constant (`purge_removed_contract_test`) and named with its reason
    (`auth_delete_account_test`).
- [x] **Guard:** `sync_reset_coverage_test`.
  - Any singleton that reads prefs must register a reset, use a sync mixin or ledger, or be on a named
    device-settings list.
  - Deferred, each with a reason in the test:
    - **Another terminal's files:** `ttc_learn_screen` (recents), `ttc_strings` (`TtcPartnerMode`),
      `ttc_ready_habits_store`, `global_ask_fab`.
    - **The six doctor-app stores:** their own sign-out, a separate pass.
- [x] **Purge (§5):** `0109_purge_removed.sql`.
  - `pv_purge_removed(90)` runs daily at 04:15 UTC via `pg_cron` over an explicit list of 43 tables. Never
    `children`, never `sponsor_*`.
  - It refuses fewer than 30 days, and no app role can call it.
  - `saved_items` joins the 90 days. 0081's 30-day prune stays unscheduled, because it would be shorter than the
    phone's 80.
  - **Found: that prune had never been scheduled, and the docs said it ran.**
  - One cascade: `ttc_supplement_taken` follows its supplement.
  - Contract test: the list equals every table that has `removed_at` in the migrations.
- [x] **The phones forget too, first:**
  - `SyncRowBook.dropSettled` runs at the end of every merge. It drops confirmed removals older than 80 days.
  - The same rule applies in `CycleStore`, `TtcLogStore` and `SavedStore`.
  - 80 < 90 so a phone can never upload a removal the server has purged (BACKEND-PATTERNS §16ii-m).
- [x] §7: the unused `local_wipe.dart` import is commented out. The wrong "saved items already purge" lines are
  corrected.

**Verified (2026-10-21):**
- Scoped `flutter analyze` is clean on every file touched. The only issues it shows, in `ask_veda_service.dart`,
  were there before.
- Tests:
  - the step 11 set: 391 passed across the sync, journal, saved, TTC and profile tests;
  - the step 12 set: purge contract, sign-out mute, delete account, reset coverage, row merge and logging all
    passed;
  - the reset sweep: 1657 passed across 85 files.
- 2 failures are in another terminal's work, not this step's:
  - `ttc_palette_consistency_test`: `ttcPanel` in `ttc_cycle_hub`, `ttc_ready_week` and `ttc_temp_parts`;
  - `ttc_tab_host_test`: the Learn tab scroll, in `ttc_learn_screen`.

**Known limits, named:**
- **Phone-only personal stores lose their data for good at sign-out.** It never reached the cloud, and the wipe
  clears it. That covers the birth plan, Garbh journal, memories, BMI history, condition answers, the skilling
  journal and portfolio, and more. The sign-out sheet says "It stays saved in your account", which is not true for
  these.
  - The fix is a decision for the user: the `CloudSyncedStore` blob for each, which is the non-shopping half of
    step 10.
  - See STILL-OPEN-BACKEND §4 and BEFORE-LAUNCH.
- A phone offline for more than 90 days can bring back a row deleted elsewhere: the purge window's trade.
- Still fire-and-forget, out of scope: orders (marketplace), referral codes, the doctor app, Can-I misses.

**User runs:**
1. [x] 0109 in the Supabase SQL editor (2026-10-21; `cron.schedule` returned job id 3).
2. [x] The `cron.job` row: one, active (checked 2026-10-21).
3. [ ] After the first night (04:15 UTC), the run history: `succeeded`.

**Owed (device, on the user's word):**
- Sign out with a medicine alarm set: nothing rings.
- Sign in as someone else: no birth plan, search history or messages from the last person.
- A fresh install signs in: the logs upload in a few requests.

**Files:**
- **New:**
  - `lib/services/remote/sync_batch.dart`
  - `supabase/migrations/0109_purge_removed.sql`
  - `test/sync_batch_test.dart`, `test/no_silent_user_writes_test.dart`, `test/purge_removed_contract_test.dart`
- **Sync plumbing:** `supabase_repo.dart`, `own_row_ledger.dart`, `child_scoped_store.dart`, `sync_row_book.dart`,
  `sync_registry.dart`.
- **TTC:** `ttc_sync.dart`, `cycle_store.dart`, `ttc_log_store.dart`, `ttc_store.dart`, `ttc_ready_plan_store.dart`,
  `ttc_treatment_store.dart`, `ttc_doctor_questions_store.dart`.
- **Services:** `life_stage_store.dart`, `saved_store.dart`, `journal_store.dart`, `father_journal_store.dart`,
  `pregnancy_controller.dart`, `notification_service.dart`.
- **Auth:** `pending_profile.dart`, `local_owner.dart`, `local_wipe.dart`, `delete_account.dart`.
- **Screens:** `pv_account_actions.dart`, `pv_you_screen.dart`, `auth_flow_screen.dart`.
- The 45 store files of the reset sweep.
- **Tests:** `pv_sign_out_mute_test.dart`, `auth_delete_account_test.dart`, `sync_reset_coverage_test.dart`.
- **Docs:** this log, STILL-OPEN-BACKEND, BACKEND-PATTERNS (§16ii-l, m, n; reading list 42–44), BEFORE-LAUNCH.

---

## Step 13: nothing she makes lives only on the phone, and no blob erases another phone's edits

**Date:** 2026-10-22 (planned and approved the same day). **Migration:** 0110 (run by the user 2026-10-22). **Commit:** `8c466d0`.

**Why.** Step 12 found that phone-only data (birth plan, Garbh journal, memories, BMI, answers) was lost for good at
sign-out, while the sheet said "it stays saved in your account". The user: "both aren't good practices ... poor
backend". They decided:
- move all of it to the cloud **except Skilling**, kept on the phone pending a consent and legal review for children's
  data;
- in the same pass, give the old whole-blob stores per-item merge (the non-shopping half of step 10).

### The mechanism
- [x] **`pv_state_merge` (0110).** A per-item merge of `user_state`, with the row locked:
  - items are `{v, t, d}`, and the newer edit wins;
  - a future clock is clamped, and a tie keeps the server's copy;
  - tombstones are dropped after 90 days;
  - it is `SECURITY INVOKER`, so the own-row policies apply.
- [x] **`CloudMergedStore`** (`lib/services/remote/cloud_merged_store.dart`):
  - stores declare their items, and the mixin stamps what changed on each notify;
  - it sends only changed items and takes the merged map back;
  - waiting marks persist, so they survive a restart and feed the sign-out warning;
  - phones drop settled tombstones at 80 days;
  - on a phone's first run, what it already holds is stamped `t = 0`;
  - the old blob is read once, and it wins unless the old sync still had a change waiting.
- [x] **Found and fixed while building** (BACKEND-PATTERNS §16ii-q):
  - **a sign-out reset was stamped as deletions** that could reach the next account. `SyncRegistry.resetting` now
    stops that;
  - **`jsonb` reordered map keys**, which made every value look edited. Values are now compared in a canonical form;
  - **stores with demo seeds skipped the old blob** on a new phone. The upgrade now always reads the old blob.

### Phone-only data, now in the cloud
- [x] **Rows (tables in 0110, `OwnRowLedger`, files in Storage):**
  - `memories`, with the photo as type `memory`;
  - `garbh_journal_entries`, with the audio as type `garbh`.
- [x] **On her profile:** "pregnancy ended" is `profiles.pregnancy_ended_at`.
  - It goes up through `PendingProfile.send`.
  - On a phone's first sync, a local "ended" is sent up, never undone by the empty column.
- [x] **Profile photo:** Storage type `avatar`, with its reference as one merged item.
- [x] **Merged items:**
  - **Pregnancy and Parenting:**
    - conditions answers, birth plan (2 s debounce for typing), Dear Baby vault, care-card presence;
    - product-guide votes, landing focus, last page read, arrival prompt, tool usage;
    - learn progress, the three search histories, the Parenting and Pregnancy messages (delivered messages, read
      marks, switches);
    - BMI, the checklists, the Garbh journal's rituals, pins and japa.
  - **TTC:** fertility help, PCOS check, self-checks (one item per whole form), vaccines, the Garbh course, reads,
    home prefs, content prefs, hidden symptom categories, tool recents, learn recents, messages, ready habits (re-arms
    its reminders after a merge).
  - `TtcLearnRecents` and `TtcReadyHabitsStore` now reset on sign-out through the mixin.
- [x] **Sign-out sheet:** when Skilling holds records, one extra line says they are kept only on this phone and
  removed for good. `kPvSkillingKeys` is pinned to the Skilling stores' own keys by a test.

### The old whole-blob stores, now per item (the non-shopping half of step 10)
- [x] **Converted** (same `cloudKey`; the items live at `<key>:items` and the old blob is kept for revert):
  - **Pregnancy and shared:** hospital bag v1 and v2, nutrition day, journey dates, reads done and next, read-to-baby
    and its saved pieces, spiritual prefs, ready-for-birth context, Garbh, book companion, Can-I recents and
    decisions, community, followed experts, the family profile, TTC precheck, readings, scan reports;
  - **Parenting:** daily tip, food, grow, journeys, names (crowned), reco, watch (5 s debounce; positions as ints),
    yoga.
- [x] **Not converted:**
  - `can_i_store` and `video_store` are facades over `SavedStore` and already sync as rows;
  - the shopping stores (cart, orders, bought, product checklists, saved products, Brand Studio, booking) go to the
    marketplace build;
  - `pp_development_data` and `pp_reading_data` were being edited by another terminal. **Still whole-blob, owed.**
    **Done later on 2026-10-22**, once the other terminal committed (`1cd9f2f`):
    - `DevStore` items: `s|<id>` saved, `c|<id>` completed, `q|<question text>` answers. The other terminal's
      `kCheckInRenames` now applies to each answer as it loads, from either path. After a merge the server still
      holds the old wording, so her next change sends the new key and a tombstone for the old one; no extra code;
    - `ReadingStore` items: `p|<article>` progress, `font`, `mode`, with a 5 s debounce because progress moves on
      every scroll. The local blob keeps its shape, because `SavedStore` lifts the old `saved` list from it;
    - tests: two cases in `cloud_merged_store_test` that run the real stores against the fake server, and
      `pp_checkin_rename_test` covering both loading paths. 134 passed across the seven files that name the two
      stores; analyze clean on the touched files.

**Verified (2026-10-22):**
- Scoped `flutter analyze` over every step-13 file: no new issues. Three already there: an unused import in
  `ttc_tools_screen`, two curly-brace infos in `pp_yoga_data`.
- Tests:
  - `test/cloud_merged_store_test.dart`: 17 cases. Two phones, removals, the same answer, offline across a restart,
    `t = 0` seeding, the old blob (including stores with seeds and a waiting old change), the 80-day drop, the
    reset that must not send removals, jsonb key order, and the SQL rule;
  - the helpers' runs over every test naming a converted store: 267 + 769 + 217 + about 200 passed;
  - **the full suite was NOT completed**: the run was stopped by the system for low memory (2026-10-22). Run `flutter test` when the machine is free.

**Known limits, named:**
- A list that grows without bound in one blob (readings) is returned whole by every merge. Past a few hundred items it
  belongs in rows.
- Counters (tool usage, the read-to-baby offset) are last-writer-wins, so two phones counting at once can lose a step.
- Watch collection ids come from a per-phone counter, so two phones creating a collection at once could merge them.
- A shown time on a care card goes up only with the next change that notifies.
- Reading progress is last-writer-wins, not the highest value. Two phones reading the same article offline at once
  can move it back. Each phone already refuses to move its own progress backwards, so this needs both offline.

**User ran (2026-10-22):** 0110 in the Supabase SQL editor; check 3 returned `pregnancy_ended_at`. Check 2 expects 4
rows, not 2: `information_schema.triggers` lists a trigger once per event, and both fire on INSERT and UPDATE (the
comment in 0110 was corrected after the commit).

**Owed (device, on the user's word):**
- Fill in the birth plan, a memory with a photo, a BMI reading and some TTC answers; sign out and back in; everything
  returns.
- Two phones tick different hospital-bag items; both stay.
- With Skilling data present, the sign-out sheet names it.

**Decisions owed:**
- whether Skilling syncs before launch;
- whether "pregnancy ended" on her profile should be visible to her linked partner (0009 lets him read her profile).

**Files:** `lib/services/remote/cloud_merged_store.dart` (new), `supabase/migrations/0110_state_merge_and_records.sql`
(new), `test/cloud_merged_store_test.dart` (new), `supabase_repo.dart` (`mergeState`), `sync_registry.dart`
(`resetting`), about 65 store files, `pv_account_actions.dart`, and the tests updated for the new shape. The exact
list is in the commit.

## Step 14: rows keyed per person, so two people's same-named ids never collide

**Date:** 2026-10-24 (found during the stage-transitions pass as STAGE-TRANSITIONS B9; planned and approved the same
day, the user: "start with b9 plan it well first"). **Migration:** 0113 (run 2026-10-25). **Commit:** `b474f69`.

**Why.** A primary key is unique across the whole table, not per user. The phone makes its own row ids, and some are
built from a date or a name (`ttcc_2026-10-24`, `pregnancy_started`, `sl_2026-10-24_nausea`, `symptoms_evening`). The
first account to upload such an id owned that row for ever; every other account's `upsert ... on conflict (id)` hit
it, RLS refused to update someone else's row, and the write failed silently. With one tester it never shows; with real
users the second woman to log a period on any day never got it into the cloud.

### What changed
- [x] **0113** re-keys 17 tables from `primary key (id)` to `primary key (user_id, id)`, in one `do` block (one
  transaction), looking the constraint name up rather than guessing it:
  - **colliding today:** `ttc_cycles`, `ttc_cycle_signals`, `journey_timeline`, `symptom_logs`, `journal_entries`,
    `reminders`, `weight_entries`, `movement_sessions` (the last two only for legacy migrated rows);
  - **one rule, not a flag per table:** the other OwnRowLedger `id` tables (`bump_photos`, `calendar_personal_events`,
    `baby_talk`, `medications`, `medication_logs`, `weekly_journal_notes`, `appointments`, `contraction_sessions`), and
    `father_journal_entries`, which shares the journal's upsert.
- [x] **The app conflicts on the same pair:** `OwnRowLedger.onConflict` is `user_id,<key>` for every keyed table;
  `CycleStore`, `FamilyTimeline` and `journalUpsert` send `user_id,id`. Deletes already filtered on `id` + `user_id`.
- [x] **The shared timeline keeps one entry per event.** Both partners' `pregnancy_started` can now exist, so
  `FamilyTimeline.preferOwnRows` keeps her own row over the partner's copy of the same id (and his when she has none).
- [x] **Rows already refused upload by themselves.** `SyncRowBook.confirmed(ok: false)` and `SyncBatch.push` keep a
  refused row waiting, so it goes up on the first sync after 0113. No backfill.
- [x] **Found while checking that:** one refused journal row (`sym_...` or `scan_...`) threw out of the journal's whole
  sync every time, so for that account the partner's journal and the media backfill never ran either. Fixed by the
  same key change.

**Left alone, on purpose:** TTC records, appointments, doctor questions and supplements (random ids, couple-read,
and supplements has a foreign key in); `children` and the `pp_*` tables (random ids, shared through
`my_child_ids()`); orders, bookings, `can_i_misses` and uuid tables.

**Verified:** `test/rows_keyed_per_person_test.dart` (new: 0113's list, every ledger table covered, no `id` target
left, the timeline rule), `ttc_schema_contract_test` (reads 0113), `own_row_ledger_test`, and 17 neighbouring sync and
journal files: 200 passed. `flutter analyze` on the 8 touched files: no issues.

**Known limits:**
- **Rollout.** A build that still sends `on conflict (id)` errors against these tables once 0113 runs; its rows wait
  on the phone and upload after the update. Pre-launch that is only the team's phones. After launch the same change
  takes two releases (add the new key alongside the old, ship the app, then drop the old key).
- The TTC tables left on a global `id` have random ids, so they are safe in practice, not by construction.

**User ran (2026-10-25):** `supabase/migrations/0113_rows_keyed_per_person.sql`, then the check query in its header (17 rows,
each `user_id,id`).

**Owed (device, on the user's word):** two accounts log a period on the same day; `select user_id, id from
ttc_cycles where id = 'ttcc_<that day>'` returns two rows.

**Files:** `supabase/migrations/0113_rows_keyed_per_person.sql` (new), `lib/services/remote/own_row_ledger.dart`,
`lib/ttc/cycle_store.dart`, `lib/services/family_timeline.dart`, `lib/services/journal_sync.dart`,
`lib/services/tools_store.dart`, `test/rows_keyed_per_person_test.dart` (new), `test/ttc_schema_contract_test.dart`,
`test/own_row_ledger_test.dart`.

## Step 15: the parenting tools pass: feed reads follow the child, and "ask once" answers sync

**Date:** 2026-10-25 (parenting tools pass, tool 01 and shared piece T0; the user: "make sure the back ends are
working well ... sinking the consent answers"). **Migration:** none. **Commit:** `b11b2ec`.

### What changed
- [x] **Feeds are read per child.** `FeedingStore.all` keeps only rows whose `ChildLogLedger.childOf` is the
  active child (a row the ledger never saw counts as the active child's, the uploader's fallback). Before this,
  twins' feeds blended into one last feed, count and next side. Upload and pull were already child-scoped; only
  the reads were not.
- [x] **An edit is an update of the same row.** `FeedingStore.update` keeps the id and `touch`es it, so newer-wins
  carries the edit to the other phone instead of a removal plus a new feed.
- [x] **"Ask once" answers sync.** `PpUseConsent` adopts `CloudMergedStore`: store key `pp_use_consent`, one item
  per kind (`feeds` today), value `yes` or `no`, unasked = no item. It boots in `main.dart` and registers with
  `SyncRegistry` like every merged store (sign-in, resume, sign-out reset).

**Verified:** `test/pp_use_consent_sync_test.dart` (new: the yes lands on the server as `pp_use_consent:items`
→ `feeds`, and server items come back as her answer), `test/pp_feed_tool_test.dart` (new: twins isolated, an edit
keeps the id), `cloud_merged_store_test`, `pp_logs_merge_test`, `sync_guard_contract_test`: all pass.

- [x] **The same day, all five care stores** (feeds, nappies, pumping, tummy time, sleep) read through one check on
  the ledger, `ChildLogLedger.belongsTo`. The breastfeed timer files its feed under the child it started for
  (`FeedingStore.log(childId:)`). `update()` on nappies, pumping and sleep keeps the row id. Test:
  `test/pp_care_logs_tool_test.dart`. Sleep's live clock (`startAsleep`) is kept on the phone only; the finished
  sleep syncs as a normal row.

**Known limit:** a running sleep clock is per phone, so the other parent sees the sleep only once it is saved.

**Files:** `lib/screens/post_pregnancy/pp_feeding_data.dart`, `lib/services/pp_use_consent.dart` (new),
`lib/main.dart`, `test/pp_use_consent_sync_test.dart` (new), `test/pp_feed_tool_test.dart` (new).

## Step 16: every child's records read per child (B11)

**Date:** 2026-10-25 (STAGE-TRANSITIONS B11, found building F3; the user: "do b11 as its holding incomplete").
**Migration:** none. **Commit:** `c70a791`.

### Why
Step 15 made the five care logs read per child. The other five child stores did not: growth, documents and the
health records kept every child's rows in one list and their getters never asked whose a row was, and milestones,
vaccines and the emergency card were one value for the family, keyed by the milestone, the dose or the child. With
twins or two children, one child's weight, papers, medicines, ticks and doses showed on the other's page, and the
emergency card (blood group, allergies) was one card for both. Uploads were already right: the ledger records each
row's child when it is written.

A second gap, found on the way: every pull fetched only the child on screen. A feed or dose the other parent logged
for the twin not on screen reached this phone only if that twin happened to be open at a sync.

### What changed
- [x] **List stores read through the ledger.** `GrowthStore`, `BabyDocumentsStore` and the six `HealthStore` record
  lists (and the doctor questions) keep only rows `belongsTo` the child on screen. The index-based edits now take
  an index into what the screen shows and find the row behind it (`_at`), so editing row 0 on Meera's page never
  edits Aarav's.
- [x] **Keyed records are kept per child.** `PerChild<T>` (`child_scoped_store.dart`) holds one value per child:
  milestone ticks (`MilestoneStore`), the four vaccine collections (`_VaxChild` in `VaxStore`), the emergency card
  and Health's two "entered" flags. The old fields became getters onto the child on screen's value, so no read or
  write in those classes changed. The prefs blobs gain a `byChild` shape. Health also keeps writing its old flat
  keys, so an older build still reads something.
- [x] **A value from before B11 joins the child on screen.** It has no child, so it waits in the legacy bucket and
  goes to the first child read as the one on screen. That is the child the uploader already filed it under
  (`uploadFor`'s fallback), so screen and cloud agree.
- [x] **Every child is pulled.** `ChildLogLedger.pullEvery` pulls each child in turn into one list (`apply` leaves
  other children's rows alone); the five care stores, growth, documents and health use it. Milestones and vaccines
  loop per child into that child's bucket. The child on screen goes first, so legacy values join it before the
  others merge.
- [x] **Each child's dose alarm is its own.** `vaxAlarmIdFor(visitId, childId:, firstChildId:)`: the first child
  keeps the bare id an older build armed (so it can still be cancelled), and any other child's id names the child.
  `vaxReminderText(child:)` speaks of that child and that child's date.
- [x] **The messages remind every child of their own visits** (`VaxStore.isDoneFor`), not only the one on screen
  (F3 had held that back until this).
- [x] **Found on the way:**
  - `HealthStore._after` awaited the save before the cloud step recorded the row's child, so a switch of child in
    that gap filed the row under the wrong child. The cloud step now starts first.
  - Health said "No measurements yet" over measurements the other parent had logged, because the flag was set only
    by a local add. `growthEntered` and `vaxEntered` now also read the real records.
  - `SkTurningSixPrompt` (F4) registered no sign-out reset.
- [x] Each store redraws on a child switch (`ChildProfileStore.instance.addListener(notifyListeners)`).

**Verified:** `test/pp_child_records_test.dart` (new, 11) covers:
- twins isolated in growth, documents, health, the card, milestones and doses
- an edit by on-screen index reaching the right row
- the legacy bucket rules
- the alarm ids and words
- every child's visits in the messages
- every store pulling every child (source scan)

`pp_records_merge_test` and `pp_messages_family_test` were updated to the per-child rule (the old lines kept as
comments). `sync_reset_coverage_test` also passes.

**Known limits:**
- A record saved before B11 is one value for the family, so it goes to whichever child is on screen at the first
  load. With one child that is always right. With twins logged before this, the earlier blended ticks land on the
  child on screen, as the uploader already filed them.
- If the first child is removed, the next child's alarms take the bare ids. An alarm armed under the old id can
  fire once more.
- One fetch per child per table on each sync: about 14 per child (fine for one to three children).

**Files:** `lib/services/remote/child_scoped_store.dart`, `lib/screens/post_pregnancy/pp_child_profile.dart`,
`pp_growth_data.dart`, `pp_documents_data.dart`, `pp_health_data.dart`, `pp_milestones_data.dart`,
`pp_vaccine_data.dart`, `pp_care_log_data.dart`, `pp_feeding_data.dart`, `pp_sleep_data.dart`,
`lib/services/pp_messages_store.dart`, `lib/screens/skilling/sk_turning_six.dart`,
`test/pp_child_records_test.dart` (new), `test/pp_records_merge_test.dart`, `test/pp_messages_family_test.dart`.


## Step 17: the Health tools: ask once covers what she tells the symptom tool, and edits keep their ids

**Date:** 2026-10-25 (parenting tools pass, Health family; the user's rule: "make sure the back ends are working well").
**Migration:** none. **Commit:** `66a1610`.

### What changed
- [x] **Two new consent kinds,** `nappies` and `changes`, ride the same `PpUseConsent` merged store as `feeds` (step 15). They need no new key: one item per kind under `pp_use_consent`.
- [x] **Saved changes are read only after a yes.** `PpChangesStore.active()` returns nothing without `allows(changes)`. Every reader (home "You told us", the relevance brain) comes through it, so one check covers them. The rows themselves still sync as before (the step-13 merge); a no stops them being used, not stored. Changes she already had stay.
- [x] **`GrowthStore.update`** replaces a measurement in place and `touch`es the same id, so an edit reaches the other phone as an edit (newer wins), not as a removal plus a new row.
- [x] **The emergency card has one source:** allergies and medicines from the child's health record, birth date from the profile, weight from the growth log. The card's own copies of those fields are no longer shown or edited (the columns stay, kept for revert).

**Verified:** `test/pp_symptom_tool_test.dart` (ask once before keeping; a no means saved changes are never read), `pp_wave8_test`, `pp_use_consent_sync_test`, `pp_child_records_test`, `pp_records_merge_test`, `sync_guard_contract_test`: all pass within the 665 run.

**Files:** `lib/services/pp_use_consent.dart`, `lib/screens/post_pregnancy/pp_changes_store.dart`, `pp_growth_data.dart`, `pp_wallet_data.dart`.

## Step 18: one record per pregnancy (R1)

**Date:** 2026-10-25 (STAGE-TRANSITIONS R1; the user: "let them take control of it and delete it permanently if
they want tht, why decide for them?", and "lets keep it 90 days for now"). **Migration:** `0114_pregnancies.sql`
(the user runs it). **Commit:** `656bbb3`.

### Why
A pregnancy was not a thing the database could name: one due date, one stage and one loss flag per person. So a
pregnancy after a loss opened on the lost one's bump photos, scans, hospital bag and letters; day 120 of a second
pregnancy overwrote the first's mood; and there was no way to look back at an earlier pregnancy, or to remove it.

### What changed
- [x] **`pregnancies` (0114).** One row per pregnancy:
  - columns: start, due date, `due_date_source`, end, outcome (`ongoing` | `loss` | `birth` | `ended`), `child_id`,
    `archive jsonb`
  - PK `(user_id, id)` (the B9 rule)
  - her rows in full, plus a read for her partner (as `journey_timeline`, 0041)
  - the newer-wins guard, and on the 90-day purge
- [x] **`PregnancyRecords`** (`lib/services/pregnancy_records.dart`). Synced through `OwnRowLedger`; its sign-out
  reset is registered. On first run, the records an install already implies are derived:
  - each pregnancy the family timeline remembers
  - the one her due date describes
  - a recorded loss or a child born inside it

  The partner's phone uses her records for its windows.
- [x] **The window rule.** Records sort by start, and each owns the time until the next one starts, so the windows
  partition time. Every dated pregnancy store reads through `PregnancyRecords.inCurrent`:
  - bump photos, symptoms, weights, kicks, contractions
  - weekly notes, letters, the journal, his journal
  - appointments, the partner's scans, Garbh recordings

  A removed pregnancy still bounds the windows.
- [x] **Sealing.** When the next pregnancy begins (`startNew`, from `confirmPregnancy`), the undated records are
  copied into the old pregnancy's archive and the live stores start clean, as her edit, so her other phones follow:
  - the hospital bag (both), the birth plan, the birth context, the checklists, journey dates, scan reports
  - scans ticked by catalogue id
  - moods, missions and movement answers keyed by pregnancy day

  `CloudMergedStore.replaceItemsAsEdit` is the new door for the merged stores. The undo ("the test was wrong") puts
  them back.
- [x] **The moves:**
  - `recordLoss` and `undoLoss` end the record and carry it on again
  - `recordBirth` ends it with the child, before the stage moves
  - `setDueDate` re-dates the current record and never starts one
  - `confirmPregnancy` starts the record before the due date moves
- [x] **"Kept for you".** A quiet row at the foot of the Your family sheet, and "Your pregnancies" in You on every
  stage. Neither is ever a switchable profile.
  - `PregnancyKeptScreen` is one view-only page: photos, journal, weekly notes, letters, Garbh, appointments, and an
    "also kept" line.
  - Delete names what goes. Each dated record goes through its store's own delete, so the removals sync and the
    Storage files go. The record is soft-deleted: off her phones now, purged after 90 days.
  - The loss page now says, once, where it is kept.
- [x] **Found on the way:**
  - `MemoryStore` and `JournalStore` cached under the same prefs key (`journal_entries`), so each read the other's
    entries as its own (split once, `journal_key_split.dart`; a source scan now refuses a shared key).
  - The weekly notes' "one per week" migration would have fused two pregnancies' week-12 notes. It now groups by
    week and by date.
  - A second pregnancy's scan of the same kind would have overwritten the first one's journal entry
    (`scan_<id>`). It now gets a dated id.
  - The letter vault reads the letters of the pregnancy that became the child (`dearBabyLetters`).

**Verified:** `test/pregnancy_records_test.dart` (new, 21) covers:
- the backfill cases
- the window partition, with a second pregnancy's bump opening clean
- loss and undo; a new pregnancy sealing and its undo
- the same pregnancy confirmed twice
- delete
- the words, and the wiring (source scans)
- the shared prefs key

**Known limits:**
- A record's date decides its pregnancy. A row dated far from the truth lands in the wrong one, but the app dates
  these itself.
- Her pre-pregnancy weight (one row per person) carries into the next pregnancy, where she can edit it.
- Garbh rituals, pins and favourites carry on, on purpose.
- Personalisation reading `outcome` is still owed.
- On his phone, before she has run the update, he derives records of his own from her due date. Once hers arrive,
  his are what his windows use.

**User ran:** 0114 on 2026-10-25.

**Files:**
- New: `supabase/migrations/0114_pregnancies.sql`, `lib/services/pregnancy_records.dart`,
  `lib/services/pregnancy_archive.dart`, `lib/services/journal_key_split.dart`,
  `lib/screens/pregnancy/pregnancy_kept_screen.dart`, `test/pregnancy_records_test.dart`.
- Changed: the stores named above, plus `stage_moves.dart`, `ttc_transition.dart`, `pregnancy_controller.dart`,
  `cloud_merged_store.dart`, `family_timeline.dart` and `life_stage_store.dart` (`ready`), `main.dart`,
  `pv_family_switch.dart`, `pv_you_content.dart`, `pv_you_screen.dart`, `dear_baby_vault_screen.dart`,
  `pv_door_after_loss.dart`.

## Step 19: the Development tools: a check-in answer and a "we tried this" belong to one child

**Date:** 2026-10-25 (parenting tools pass, Development family 17-21; the user's rule: "make sure the back ends are
working well"). **Migration:** none. **Commit:** `3e7b8a8`.

### Why
`DevStore` (`pp_development`, the step-13 per-item merge) kept the gentle check-in's answers keyed by the question's
wording (`q|<text>`) and one "done" set for the family (`c|<id>`). A sibling in the same age band opened the
check-in with the other child's answers already ticked, and twins shared every "done". It also started every new
install with a fake saved activity (`peekaboo`) and a fake done one (`tummy_play`), which the recommendations then
read as hers.

### What changed
- [x] **The owner rides in the item key.** New items `q|<childId>|<text>` hold `{yes, at}` (the answer and the day),
  and `c|<childId>|<activityId>` holds the day it was tried. The state row is one `user_state` row per person (step
  14), so the item key is the only place a child can be named. No migration: the server merge takes any key.
- [x] **Items from before the split are kept, not moved.** An unowned `q|<text>` or `c|<id>` is never rewritten or
  deleted. It is read only while the family has one child (or none), when it can only be that child's. With two
  children nobody can say whose it was, so neither child inherits it.
- [x] **The fake starter rows are commented out** (kept for revert). Recommendations read the reader's bookmarks
  (`PvReadStore`, `pp_activity_<id>`), which is where an activity is saved now.
- [x] **A new consent kind, `development`** ("Milestones and check-in answers"), on the same `PpUseConsent` merged
  store as feeds, nappies and changes. With a yes, the check-in's "not yet" answers go to the doctor-visit questions
  (`HealthStore.addQuestion`, already per child) and the visit summary lists the milestones seen in the last three
  months. Without it, nothing is read.

- [x] **Found on the way: two children could share one id.** `child_<microseconds>` alone, so two children added
  back to back (twins at onboarding) could land on one tick, and every per-child store then treated them as one
  child. Ids now end in a counter, as feed ids do (`ChildProfileStore._newChildId`). Ids already saved keep their
  shape, and nothing reads an id's parts, so no data moves.

**Verified:** `test/pp_development_tools_test.dart` (two children's answers and tries stay apart; an old answer is read
with one child and not with two, and still goes up unchanged; the item keys on a played server; the rename carries
inside an owned key; no fake starter rows), `test/pp_development_screens_test.dart` (the visit reads development only
after a yes), `cloud_merged_store_test`, `pp_checkin_rename_test`, `pp_use_consent_sync_test`.

**Files:** `lib/screens/post_pregnancy/pp_development_data.dart` (`DevStore`, `DevAnswer`), `pp_child_profile.dart`, `pp_reco_data.dart`,
`health_doctor_visit_screen.dart`, `development_checkin_screen.dart`, `lib/services/pp_use_consent.dart`.

## Step 20: the Food tools: the foods a child has tried, shared with the co-parent

**Date:** 2026-10-25 (parenting tools pass, Food family 22-24; the user's rule: "make sure the back ends are working
well"). **Migration:** `0115_pp_food_tries.sql` (run by the user 2026-10-25). **Commit:** `03976a1`.

### Why
"Can my baby eat this?" told a parent whether a food suits the child's age, and forgot everything the moment she
closed it. Nothing anywhere recorded which foods a child had already had, or whether one caused a reaction. The
user's decision (D1): keep a first-tries log, per child, **and the partner sees it**.

### What changed
- [x] **A new child table, `pp_food_tries`** (0115): one row per `(child_id, food_id)`, `first_tried`, `reaction`
  (`none` / `mild` / `doctor`), `note`, born with 0104's clock (`updated_at`, `removed_at`). RLS through
  `my_child_ids()`, insert only as yourself: the same four policies as `pp_milestone_observations` (0025). On 0100's
  newer-wins guard and on the purge list (`pv_purge_removed`, redefined from 0114's body with one table added).
- [x] **`PpFoodTriesStore`** (`lib/screens/post_pregnancy/pp_food_tries_store.dart`): the `MilestoneStore` shape.
  `PerChild` map in prefs, `ChildLogLedger` keyed by `food_id`, every child pulled (B11's loop), Undo is a soft
  delete that uploads. The food id is the app's own slug of the catalogue name (`ppFoodId`), so a local row and its
  cloud copy share one key. Started in `main.dart` beside `MilestoneStore`.
- [x] **A new consent kind, `foods`** ("Foods tried"), on the same `PpUseConsent` merged store. Readers outside the
  tool (Recipes' "new food" line, the doctor-visit row) check it; the tool's own list always shows.
- [x] **Allergies already on the child's record are read, not stored again** (D2, "always warn"):
  `HealthStore.knownAllergies` is per child since B11, so the checker and Recipes only read it.

**The trade-off.** A `user_state` item (step 19's pattern) would have needed no migration, but `user_state` is one
row per person and own-only, so the partner could never read it. A child table costs a migration and four policies,
and buys the one thing the user asked for: whoever feeds lunch knows egg is no longer new. BACKEND-PATTERNS §16rr.

**Verified:** `test/pp_food_tools_test.dart` (twins never share a try; Undo restores exactly; reactions for the
doctor; works logged out; lenient reaction read; stable ids; the consent kind; every column sent is one 0115
creates; wired in `main.dart`), `test/sync_guard_contract_test.dart` (guarded), `purge_removed_contract_test`.

**Files:** `supabase/migrations/0115_pp_food_tries.sql`, `lib/screens/post_pregnancy/pp_food_tries_store.dart`,
`lib/services/pp_use_consent.dart`, `lib/main.dart`.

## Step 21: the You, Maa tools: a kind on each Kegel session, no seeded yoga saves, a bought-once recorded class

**Date:** 2026-10-25 (parenting tools pass, You, Maa family 25-28; the user's rule: "make sure the back ends are
working well"). **Migration:** none. **Commit:** `96eef2d`.

### Why
Four tools, two with stores. Kegel Care's history could not tell a breathing session from a squeeze session, so
"Easy" on a breath in the first six weeks moved the squeeze routine she would start at six weeks. The Yoga store
started every new mother with two saves she never made, and the first sync wrote them to her account. Five
recorded classes showed ₹299 and played without any purchase.

### What changed
- [x] **`KegelRecord.kind`** (`kegel` | `breath`) in the `tool_kegel_history` blob. A record from before reads
  as `kegel` (the only kind there was): for a JSON blob, the lenient read is the migration. A breath session
  never nudges `_kegelHoldAdjust` / `_kegelRepAdjust`. A finished session left by the back arrow is saved with
  feeling `none`, and the journey shows no feeling tag for it.
- [x] **`YogaStore` starts empty.** The seeded `{'pn_group', 'md_sleep_rec'}` is commented out. Saves already
  synced are untouched: the merge only ever sees what an account holds.
- [x] **A priced recorded yoga class is an offering** (`BookingCatalog._fromYoga`): the masterclass kind ("live
  or recorded, bought once"), format `recorded`, `recordingAccess`, no credits and no slots. The commit bar's
  existing `buyThenPlay` and `ownsRecording` do the rest. No migration: the offering catalogue lives in Dart
  (0066), and money is the server's once payments are live.
- [x] **The mood check's reminder is device-local.** One prefs key, `pp_mood_remind_at` (a date), and one
  scheduled notification. Never synced, never her answers.

**The trade-off (the reminder).** Syncing it would let a second phone of hers know too, and would also let the
co-parent's phone, signed into the same family, learn that she asked to be reminded about her mood. A reminder
belongs to the phone it rings on. BACKEND-PATTERNS §16tt.

**Verified:** `test/pp_maa_tools_test.dart` (an old record reads as a squeeze; a breath "easy" leaves the
offsets; kind and `none` round-trip; leaving saves; no seeded saves; the cloud item shape `saved|<id>` /
`booked|<id>`; every priced recorded class has a slotless offering, a free one has none),
`test/pp_mood_check_test.dart` (one prefs write, the date; cancel clears it).

**Files:** `lib/services/tools_store.dart`, `lib/screens/tools/kegel_care_screen.dart`,
`lib/screens/post_pregnancy/pp_yoga_data.dart`, `lib/booking/booking_catalog.dart`,
`lib/screens/post_pregnancy/pp_mood_check_screen.dart`.

## Step 22: his phone follows her stage and her loss (R2, no migration)
- **What was wrong.** His paired phone read his own `profiles` row for `life_stage`, `life_stage_at` and
  `pregnancy_ended_at`, three facts that are hers. After her birth, her loss or her move to trying his app went on
  showing the pregnancy he paired into.
- **What changed.** `lib/services/partner_side.dart`: `PartnerSide.readStageRow(columns)` reads her row
  (`SupabaseRepo.fetchProfileOf(partner_id, ...)`) on the father phone while paired, else this person's own.
  `LifeStageStore.pullFromCloud` and `PregnancyEndedStore.syncFromCloud` read through it; on his side neither ever
  writes (`PartnerSide.following` skips the stage push; the loss seeding is skipped).
- **No migration.** 0009's policy "view own or partner profile" already allows the read.
- **Edges.** Pairing is symmetric (both rows hold `partner_id`), so the rule uses the role: her phone never
  follows his. Her row unreadable returns no row and the stores keep what they hold; it never falls back to his row.
- **Seen when.** On resume, at most once a minute (`SyncRegistry.resyncOnResume`). The loss swaps his Today live;
  a stage change re-routes his home at the next launch.
- **Test.** `test/partner_stage_test.dart`.

## Step 23: the Other tools: a vote she can take back, a chosen name she gives to the child, a timer that outlives a stop

**Date:** 2026-10-26 (parenting tools pass, the Other family 29-33; the user's rule: "make sure the back ends are
working well"). **Migration:** none. **Commit:** `a224492`.

### Why
Baby names had a backend that worked and a front end that could not use it. A liked name could not be un-liked
(the hearts only ever called `like()`), a pass in the deck recorded nothing, Undo left the like in place, and the
partner matches the database works out (`pp_name_matches`, 0027) were read only by a retired screen. Sleep Sounds'
timer, which lives in the shared player, was cleared by a stop and started on arrival rather than on play.

### What changed
- [x] **Un-like is a tombstone, not a delete.** `NameMatchStore.unlike` writes the row as `liked: false` with a
  newer `updated_at` (the same path as `skip`). A delete would lose to the other phone's older "liked" copy, which
  a newest-wins merge would then bring back. BACKEND-PATTERNS §16vv.
- [x] **A pass is a vote.** The deck calls `skip()`, so a pass is synced and the name is not offered again.
- [x] **Undo forgets the answer on this phone** (`clearVote`). The cloud has no "no vote" row, so the row it holds
  says `liked: false`; her next answer overwrites it.
- [x] **The deck leaves out answered names**, fixed at the start of a session (a live list would shrink under her
  thumb and skip a card).
- [x] **Matches on a screen.** "You both love" heads the shortlist, read from `NameMatchStore.matches`.
- [x] **A name the build does not know is dropped** from a list (`babyNameOrNull`), never shown as "Aarav".
- [x] **The chosen name reaches the child only on her tap.** When a child on record still has the placeholder
  name, the chosen screen asks "Use Aanya as your baby's name?"; Yes calls `ChildProfileStore.update(name:)`,
  which already saves and syncs. No new consent kind: the tap is the consent.
- [x] **The quiz answers are device-local** (`pp_names_taste`). They only order the deck; never synced.
- [x] **Sleep Sounds' timer: the choice and the countdown are two things.** `RagaAudioStore.armSleepTimer` keeps
  her choice (a length, or all night) through a stop; the countdown starts on play. Additive: Garbh's players
  still call `setSleepTimer`. Device-local (§16tt).

**Verified:** `test/pp_other_tools_test.dart` (unlike round-trips as a tombstone and clears the crown; undo
forgets; unknown names drop; the `pp_name_votes` columns match 0027 and 0105; the deck skips answered names; a
pass is recorded; the taste is remembered; "You both love" reads the matches; the name offer only for a
placeholder; the timer counts from play, survives a stop, and keeps "All night"),
`test/post_pregnancy_names_flow_test.dart` (moved onto the live deck), `test/raga_audio_test.dart`.

**Files:** `lib/screens/post_pregnancy/pp_names_data.dart`, `name_journey_feed_screen.dart`,
`name_journey_shortlist_screen.dart`, `name_list_screen.dart`, `name_journey_detail_screen.dart`,
`lib/services/raga_audio_store.dart`, `lib/screens/post_pregnancy/pp_sounds_screen.dart`.

## Step 24: a milestone carries a photo, and one of her own carries its words (R10)

**Date:** 2026-10-26 (STAGE-TRANSITIONS R10, the user's go for "that migration and its sync step").
**Migration:** `0116_pp_milestone_photo.sql`, run by the user. **Commit:** `5824b08`.

### Why
R10 makes Milestones one place per child, where saving one is a moment: a date, an optional photo and a line,
and, with the switch on, one journal memory. A saved milestone held a date and a note only. The user also chose
that a parent may save a milestone of her own ("First time at Nani's"), which has no catalogue entry to take a
title from, so its words have to travel with the row.

### What changed
- [x] **Two nullable columns** on `pp_milestone_observations`: `photo_path` (the Storage object path in the
  private `media` bucket, `<uid>/milestones/<file>`, the journal's rule) and `title` (only on an `own_` id,
  which the app makes). No RLS change: 0025's `my_child_ids()` policies cover every column, so both parents
  read and write them.
- [x] **The app sends the two keys only when they are set** (`MilestoneStore._cols`). A client that sends a
  column the server lacks fails the whole row, and these writes are fire-and-forget, so before 0116 ran,
  every milestone (photo or not) would have stopped syncing without a sound. Leaving the key out keeps a
  photo-less row valid before and after the migration, and keeps an older build from wiping a photo
  (PostgREST updates only the columns it is sent). BACKEND-PATTERNS §16ww.
- [x] **The photo uploads like the journal's**: copied into the app's documents, `StorageService.upload(dest,
  'milestones')`, and a local path left by an offline save is back-filled on the next sync, which touches the
  row so the cloud learns the Storage path.
- [x] **The journal memory keeps its own copy of the photo.** `JournalStore.deleteEntry` deletes an entry's
  images from Storage, so a shared object would let deleting the memory erase the milestone's photo. The memory
  is tied to its milestone by the tag `pp_milestone:<id>` (no new table), so a re-save updates it.
- [x] **Removing a milestone keeps its photo object**, because the Undo toast puts the same record back and a
  deleted object cannot return. The cost is an orphaned file per removed milestone (STILL-OPEN §101.10).
- [x] **`achieved` no longer maps every id through the catalogue** (it threw on an `own_` id); `seen` lists both.

**Verified:** `test/pp_milestones_one_place_test.dart` (the two keys only when set; 0116 adds exactly those
columns; `fromRow` reads them; her own milestone round-trips; one journal memory however often it is saved; the
doctor visit lists her own), `test/pp_records_merge_test.dart`, `test/pp_child_records_test.dart`.

**Files:** `supabase/migrations/0116_pp_milestone_photo.sql`, `lib/screens/post_pregnancy/pp_milestones_data.dart`,
`lib/screens/post_pregnancy/journal_v2/jv2_store.dart`.

**Known limit:** the media bucket lets the uploader and the paired partner read a photo (0013, 0014). A third
caregiver on the child sees the milestone and its day, not its photo.

## Step 25: how long she has been trying, a fact and a basis (T1)

**Date:** 2026-10-27 (Pregnancy and TTC tools pass, T1, the user's word on 2026-10-28).
**Migration:** `0117_ttc_trying_count.sql`, run by the user 2026-10-28. **Commit:** `00b3cc5`.

### Why
After a pregnancy loss she comes back to trying, and the doctor check (six months at 35 or over, twelve under)
kept counting from her old start, so the months she was pregnant counted as trying. Five readers also worked the
number out five ways, and his phone never read her start at all. The push sent `_journeyStart ?? enteredAt` and
the pull wrote that back as her stated start, so after one sync her onboarding answer stopped counting.

### What changed
- [x] **One count**, `TtcStore.tryingTime` (pure `lib/ttc/ttc_trying_time.dart`): her ended pregnancies are left
  out, clipped and merged; every reader (messages, Ask Veda, You, the checklist notes, the doctor check) uses it.
- [x] **Her "Change" pick is stored as a basis** (`trying_count_from`, `trying_count_date`), never a rewritten
  `journey_start`. The stored fact stays as she gave it, and the number is derived on read, so changing her mind
  back loses nothing. BACKEND-PATTERNS §16xx.
- [x] **`trying_effective_start` is published for his phone**: the derived start, not its inputs, so her
  pregnancy dates never leave her row. His phone falls back to her `journey_start`.
- [x] **The push sends only the start she gave**, which ends the write-back loop above.
- [x] **The 0117 keys go only when set**, or as an explicit null when the cloud holds a value to clear (tracked
  by `_cloudHasCount` / `_cloudHasEffective`). A column the server lacks fails the whole row silently, so before
  0117 ran the row kept syncing (§16ww).

**Verified:** `test/ttc_trying_time_test.dart`, `test/ttc_schema_contract_test.dart` (0044 and 0117 columns
pinned, checked per statement).

**Files:** `supabase/migrations/0117_ttc_trying_count.sql`, `lib/ttc/ttc_store.dart`, `lib/ttc/ttc_trying_time.dart`.

## Step 26: her partner reads her birth plan (P2, 0118)

**Date:** 2026-10-28 (Pregnancy and TTC tools pass, P2, the user's word). **Migration:**
`0118_user_state_partner_birth_plan.sql`, run by the user 2026-10-28. **Commit:** `01f33b1`.

### Why
The birth plan lived only on her phone, and the partner's phone showed his own empty plan. A partner rule on
`user_state` as a whole would have shared every store she has.

### What changed
- [x] **One SELECT policy** on `user_state` for `store_key = 'birth_plan'` and her as the owner; beside her own
  policy, not replacing it, and no write policy, so he reads and never writes. BACKEND-PATTERNS §16zza.
- [x] **`SupabaseRepo.loadPartnerState`** reads that one row on his phone; `BirthPlanStore.partnerPlan()` unwraps
  the per-item book (skipping removed items) and shows it as "Her birth plan". Nothing is stored or synced back.
- [x] **Four states on screen**: her plan, an empty plan, not linked, cannot reach (with Try again).

**Verified:** `test/p2_keep_test.dart`.

**Files:** `supabase/migrations/0118_user_state_partner_birth_plan.sql`, `lib/services/remote/supabase_repo.dart`,
`lib/services/birth_plan_store.dart`, `lib/screens/pregnancy/birth_plan_screen.dart`.

---

## Step 27: a checklist that merges per item, a date that stays a date, an edit that waits for the load (P4)

**Date:** 2026-10-28 (Pregnancy and TTC tools pass, P4, the user's word). **Migration:** none; `pv_state_merge`
(0110) already merges any store key. **Commit:** `17238591`.

### Why
- The product checklist synced as one blob, so two phones (or her and her partner) overwrote each other's ticks.
- `contraction_sessions.date_iso` is a `date`; the app sent a full timestamp, Postgres kept only the day, and the
  history re-sorted after a pull.
- `NutritionDayStore.addToList`, reached from a recipe opened by search before any screen had loaded the store,
  saved the near-empty in-memory copy over her real one: water, ticks and the shopping list, gone when logged out.

### What changed
- [x] **`ProductChecklistStore` on `CloudMergedStore`:** keys `list|<id>`, `item|<listId>|<itemId>`, `order`;
  deletions travel as soft-delete tombstones; `legacyBlobKey` reads the old blob once on each phone's first merge,
  so nobody's lists are lost. The old mixin code is kept as comments.
- [x] **Contraction date:** `contractionRowDate` sends `yyyy-MM-dd`; on pull the time comes from the first
  contraction's start; history sorts by that start. `test/preg_contraction_schema_contract_test.dart` pins the
  columns and the `date` type.
- [x] **Nutrition edit before load:** every mutator goes through `_change`; before the read, edits are held,
  `init()` starts, and they replay on top of what was read. `init()` is one shared future.
- [x] Pattern written up: BACKEND-PATTERNS §16zze.

### Verify
- Two phones tick different checklist items offline, then both sync: both ticks survive.
- A session started at 23:50 keeps its time after sign-out and sign-in.
- Logged out, open a recipe from search, add to list, then open the Nutrition door: water and earlier ticks are
  still there.

---

## Step 28: whose supplement it is, from the row's owner; a second vaccine dose as one more item (T3)

**Date:** 2026-10-29 (Pregnancy and TTC tools pass, T3, the user's word). **Migration:** none; no table, column or
item format changed. **Commit:** `ecb47348`.

### Why
- `ttc_supplements` is couple-scoped: both phones read every row. Each row has `user_id` (who first wrote it) and
  `for_partner`. The app read `for_partner` as if it were written from THIS phone's side, so on his phone her folic
  acid read "Yours" and his CoQ10 "Your partner's". An item he added for himself went up as `for_partner: false`
  and landed on her side on her phone.
- Varicella is two doses, four weeks apart, and the month's wait before trying counts from the second.
  `TtcVaccineStore` kept one date per vaccine, so logging dose one showed "clear to try" 28 days later with dose
  two still to come.

### What changed
- [x] **Supplements, read:** `TtcSupplementsStore.authorOf(row, me)`. If the row's owner is this phone's user, the
  flag reads as written; if the owner is the partner, it flips. With no signed-in id (a test, or signed out) the flag
  reads as before. Doctor questions take the author from `user_id` alone, which is right for them (a question is
  always its writer's); a supplement can be added FOR the other person, so it needs both fields.
- [x] **Supplements, write:** `_cloudColumns` writes `for_partner` from the owner's side (`_book.owners[id]`), so
  his phone editing a row she owns does not flip its meaning. `for_partner` is still written, for older builds.
- [x] **Vaccines:** dose two is the id `<vaccine>_2` (`v|varicella_2` -> `[done, date]`) in the same maps and the
  same `ttc_vaccines` merged item set. Every reader walks `kTtcVaccines`, so the extra key is invisible to them.
  Clearing dose one clears dose two; the wait counts from the last dose; with dose two owed there is no
  clear-to-try date.
- [x] Pattern written up: BACKEND-PATTERNS §16zzl.
- [x] Tests: `test/ttc_t3_getting_ready_test.dart` (W11 on his phone and hers; the `<id>_2` cloud round-trip).

### Verify
- Two phones, one couple. She adds folic acid for herself and CoQ10 for him; he adds zinc for himself. On her phone:
  folic acid under "Yours", CoQ10 and zinc under "Your partner's". On his phone: the reverse.
- He edits the dose of her folic acid: it stays on her side on both phones.
- Log varicella dose one, sync, open on a second phone: "Dose 2 is due from". Log dose two: both phones show the
  wait from dose two. Sign out and in: both dates return.

## Step 29: a result's scans travel, each partner writes only their own, and the round has one writer (T4, 0127)

**Date:** 2026-10-29, written up 2026-10-30 (Pregnancy and TTC tools pass, T4, the user's word). **Migration:**
`0127_ttc_records_files_and_own_writes.sql`, run by the user 2026-10-29. **Commit:** `dff5e77a`.

### Why
- **A cache is not a record.** A result's photos and PDFs lived in `toJson` (shared_preferences) only. A sign-out
  runs `LocalWipe` (`prefs.clear()`), the next pull rebuilt each row with `attachments: const []`, and the scans
  sat in the `media` bucket with nothing pointing at them. STILL-OPEN §9.7 had only "not on the next phone".
- **Her round, two writers.** `TtcTreatmentStore.pullFromCloud` decoded only when the phone was empty and took
  `rows.first` from a couple-wide fetch, which returns both partners' rows in no preferred order. Every launch
  pushed this phone's copy stamped `updated_at: now`, so his copy was usually the newest. If she reinstalled she
  pulled his stale copy, and her next push wrote it over her own row, history included.
- **He could change her results.** 0042 gave `ttc_records` one `for all` policy, "mine or my partner's". The user
  (Q2): "he changes his own results and only reads her results".

### What changed
- [x] **0127:** `ttc_records.files jsonb`, nullable (null = a row from before the column; the app keeps its local
  list). One policy per command: select couple-wide, insert, update and delete own-row only.
- [x] **Records:** `_cloudColumns` always sends `files` (an empty list too, so removing the last photo travels);
  `applyCloudRows` reads it through `ttcFilesFromCloud`. A dirty row owned by the other account is dropped from the
  push queue instead of retried for ever, because 0127 refuses it. The UI follows the same owner rule
  (`TtcRecordsStore.isMine`).
- [x] **Treatment round:** `ttcPickTreatmentRow` picks the row: her phone takes her own; his phone (partner mode)
  takes the row that is not his, decoded fresh on every pull. His phone never pushes. A row he wrote before this
  stays in the cloud and is ignored.
- [x] **Alarms:** a stopped medicine schedules nothing (`NotificationService.medicationOccurrences` returns empty
  when `!isActive`), in both stages; his phone cancels any trigger alarm it held.
- [x] **Found in the suite run (2026-10-30):** saving a result raised "Discard this result?" over the saved record
  (Save used `maybePop` while the page's `PopScope` still held the unsaved state), and Discard deleted the photos
  the record had just kept from storage. Save now pops; `test/ttc_records_rebuild_test.dart` holds it.
- [x] Pattern written up: BACKEND-PATTERNS §16zzt.
- [x] Tests: `test/ttc_t4_treatment_records_test.dart` (B1, B3, Q2's SQL and push); `test/ttc_schema_contract_test.dart`
  pins `files` and reads 0127.

### Verify
- Attach a photo to a result, sign out and in: the photo is still on the result.
- Two phones: his shows her round as "Her round", read-only; she changes a date and his phone shows it on the next
  pull. She reinstalls: she gets her own round back.
- On his phone her results have no Edit or Remove; his own result he can change. In SQL as him, an update of her
  row affects 0 rows.

## Step 30: habits shared by each person's own choice, body data private (T5, 0131)

**Date:** 2026-10-29, written up 2026-10-30 (Pregnancy and TTC tools pass, T5, the user's word). **Migration:**
`0131_ttc_log_shares.sql`, run by the user 2026-10-29. **Commit:** `c8c117e5`.

### Why
- The user (Q1): a couple trying together can see each other's habits, "just to be having an accountability
  check", while symptoms, mood, weight, BMI and the PCOS check stay private. Each person decides for their own log.
  Before this, `ttc_logs` was own-row only, and the partner copy promised a view that did not exist.

### What changed
- [x] **0131:** `ttc_log_shares (user_id, tracker, shared, updated_at)`, one row per person and tracker, a check
  constraint allowing only `habits` and `partner_health`. Own row read and write, the partner's row read only.
  `ttc_log_is_shared(owner, tracker)` (security definer) maps the four ids folded into `habits` on 2026-09-28. A
  second SELECT policy on `ttc_logs` adds a read of the partner's rows for a shared tracker while the switch is on.
  No row means private.
- [x] **App:** `TtcLogShareStore` (local-first, upsert on `user_id,tracker`, newer `updated_at` wins, the partner's
  rows read with `fetchByUser` and never pushed). The ask card after the first save offers Share first; You
  changes it. The partner view is read-only by rule as well as by UI.
- [x] **Kept pinned:** `TtcLogStore` still pulls with `SupabaseRepo.fetch` (`.eq('user_id', uid)`), so the widened
  read never merges his rows into hers. The test pins the call, not only the policy.
- [x] Pattern written up: BACKEND-PATTERNS §16zzu.
- [x] Tests: `test/ttc_t5_body_checks_test.dart` (the share store, the pinned query, the partner filter, the ask card
  and the partner view); `test/ttc_schema_contract_test.dart` reads 0131.

### Verify
- Two phones, one couple: she shares her habits, his phone shows them read-only; she switches it off, his view says
  she keeps them to herself. He shares Partner health; her phone shows it. Unpair: neither sees the other's.
- At no point do her symptoms, mood, weight or PCOS answers appear on his phone.

## Step 31: push devices, consent and audience (Notifications 6b B2, 0140)

**Date:** 2026-10-30 (the user's word: "You have my go for B2"). **Migration:**
`0140_push_devices_consent_audience.sql`, run by the user 2026-10-30. **Commit:** `a45e80ea`.

### Why
- 6b's server sends offers as visible pushes (`docs/NOTIFICATIONS-6B-PLAN.md`, decision 1). To keep 6a's promises it
  needs a token to reach the phone, her yes or no per stage as a row it can filter, and the phone's busy evenings and
  TTC quiet flag. B2 stores them. Nothing reads them until B3.

### What changed
- [x] **0140:** `push_devices (user_id, device_id, token unique, platform, link_version, created_at, last_seen_at)`,
  `push_consent (user_id, stage, granted, decided_at, source, updated_at)`, and
  `push_audience (user_id, busy_evenings date[], quiet, planned_at)`. RLS on all three, no direct grants; own select
  on `push_consent` only. Writes through `pv_push_register`, `pv_push_unregister`, `pv_push_consent` (newest
  `decided_at` wins) and `pv_push_audience` (keeps today to 14 days, IST), all `security definer`.
- [x] **App:** `PushWire` (the one transport), `PushService` registers the token on app open, sign-in and rotation
  (only when Firebase is up) and unregisters in `pvSignOut` before the session goes. `PushConsent` is called from all
  three messages stores, with "no" queued until confirmed. `PushAudience` is called from `FamilyPhone` after each
  re-arm. `LocalWipe.keep` holds the device id and the queue.
- [x] Pattern written up: BACKEND-PATTERNS §16zzz-a.
- [x] Tests: `test/push_b2_contract_test.dart`. `auth_delete_account_test` and `sync_reset_coverage_test` list the
  new keys and files, with why.

### Verify
- After running 0140, in the SQL editor: `select * from push_devices;` shows a row after a B2 build signs in (needs
  `google-services.json`). Switching offers off then on in Messages leaves `push_consent.granted = true` with the
  later `decided_at`. Opening Messages fills `push_audience`. Signing out removes the `push_devices` row.
- Offline: switch offers off, kill the app, come back online, open it: the "no" lands.
