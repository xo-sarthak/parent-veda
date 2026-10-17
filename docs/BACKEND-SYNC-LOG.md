# BACKEND-SYNC-LOG: what the sync work changed, step by step

A running record of the data-safety work listed in `docs/STILL-OPEN-BACKEND.md`, kept from 2026-10-17 at the
user's request because the change is large and more steps follow. **Newest step at the bottom.** Each entry says
what changed, why, which files, what the user must run, and what is still owed.

- `STILL-OPEN-BACKEND.md` is the list of what is *left*.
- `BACKEND-PATTERNS.md` §16ii explains the *pattern*.
- This file is the *history*: what was done, in order.

Before this log: the cycle and daily-log sync (commit `853650e`, migration 0097). That is summarised in
STILL-OPEN-BACKEND §0.

---

## Step 1: TTC records, appointments, ritual (2026-10-17, CODE DONE; 0098 to run, two-phone walk owed)

**Problem (STILL-OPEN-BACKEND §1, §3, §6).** `TtcRecordsStore`, `TtcAppointmentsStore` and `TtcRitualStore`
pulled with a union and removed with a one-shot hard delete. A removal made offline, racing an upload, or undone
by a second phone came back on the next pull. Every push re-sent every row, and uploads failed silently, so the
sign-out warning could not see them.

**Found on the way: the ownership flip.** All three tables are couple-scoped (either partner may write a row). The
old push wrote `user_id: <me>` on every row the phone held, including rows pulled from the partner. An upsert by
`id` therefore rewrote his result as hers, and the ritual push did the same with his ticks.

**Decisions (user):**
- Records and appointments: row-level, latest edit wins.
- Ritual: the shared part ("Today's conversation") is the couple's, so the newest tick or un-tick by either partner
  wins. The four individual parts are each person's own.

**Done so far:**
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

**Verified:**
- `flutter analyze` is clean on the 4 lib files.
- 89 tests pass across the merge, contract and row-merge files.
- The 29 other TTC test files that use these stores pass (311 + 323), `ttc_no_repetition_test` included.
- Wiring: all three stores override `hasPendingPush`, every `pullFromCloud` goes through `applyCloudRows`, and no
  live hard delete remains.

**Not verified yet:** the two-phone walk on one account. It waits on 0098 being run and the phone being free.

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

**User must run:** 0098 in the Supabase SQL editor. Until it runs, uploads from these three stores are refused
(the new columns are unknown), so changes wait on the phone and the sign-out sheet says so. Nothing is lost.

**Still owed after this step:** supplements and `journey_timeline` (the timeline needs an update grant), the
Pregnancy and Parenting tables, and the blob stores (§2).
