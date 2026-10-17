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
| 2026-10-17 | Step 2: supplements, family timeline | 0099 | pending | not yet |

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

**Dates:** started 2026-10-17 · built 2026-10-17 · commit pending · 0099 not run yet · two-phone walk owed.

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

**User must run:** 0099 in the Supabase SQL editor. Until it runs, uploads from these two stores are refused, so
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
