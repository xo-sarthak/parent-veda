// =============================================================================
//  The merge rule for her cycle data: the newer change wins (2026-10-17)
// -----------------------------------------------------------------------------
//  Every row CycleStore and TtcLogStore sync carries two times:
//
//    · updatedAt, when she made the change ON THE PHONE (not when it uploaded);
//    · removedAt, set when the change was a removal (a soft delete).
//
//  A pull compares the phone's time for a row with the cloud's, and the newer
//  one wins, removals included. That is the whole rule, and it is the one the
//  journal (`mergeJournal`), the saved items (`SavedStore.merge`) and the
//  doctor's questions (0092) already follow.
//
//  ⚠️ WHY NOT "UNION": the old pull added whatever the phone lacked and kept
//  whatever it had (`putIfAbsent`). That can never take anything away, so a
//  removal made on one phone was undone by the next phone that still held the
//  row, and an edit lost to an older copy. "Newer wins" can take things away,
//  because a removal is a row with a time like any other change.
//
//  Pure Dart and network-free, so the cases are unit-tested directly
//  (`test/ttc_row_merge_test.dart`).
// =============================================================================

import '../services/remote/sync_row_book.dart';
export '../services/remote/sync_row_book.dart' show SyncRowBook;

/// What a pull should do with one row.
enum TtcMergeStep {
  /// The cloud's copy is newer: take it (its value, or its removal).
  takeCloud,

  /// The phone's copy is newer, or the cloud has none: upload it.
  pushLocal,

  /// Both say the same thing at the same time: nothing to do.
  same,
}

/// The decision for one row, from the phone's time and the cloud's.
///
/// A null time means "this side has no copy". A row the phone has never
/// touched since this release reads as [ttcEpoch], so any cloud copy wins.
TtcMergeStep ttcMergeStep({DateTime? local, DateTime? cloud}) {
  if (cloud == null) return local == null ? TtcMergeStep.same : TtcMergeStep.pushLocal;
  if (local == null) return TtcMergeStep.takeCloud;
  if (cloud.isAfter(local)) return TtcMergeStep.takeCloud;
  if (local.isAfter(cloud)) return TtcMergeStep.pushLocal;
  return TtcMergeStep.same;
}

/// The time a row the phone held before this release is given: older than
/// anything, so the cloud's copy wins wherever there is one.
final DateTime ttcEpoch = DateTime.utc(2000);

/// A cloud timestamp column, read safely. Null when absent or unreadable
/// (a row written before 0097, or before the migration ran).
DateTime? ttcParseStamp(Object? v) {
  final s = v?.toString();
  if (s == null || s.isEmpty) return null;
  return DateTime.tryParse(s)?.toUtc();
}

/// The plan for a whole table: which keys to take from the cloud and which
/// to upload, from each side's time per key. Keys the phone holds that the
/// cloud has never seen are uploaded.
({Set<String> take, Set<String> push}) ttcMergePlan({
  required Map<String, DateTime> local,
  required Map<String, DateTime> cloud,
}) {
  final take = <String>{};
  final push = <String>{};
  for (final k in {...local.keys, ...cloud.keys}) {
    switch (ttcMergeStep(local: local[k], cloud: cloud[k])) {
      case TtcMergeStep.takeCloud:
        take.add(k);
      case TtcMergeStep.pushLocal:
        push.add(k);
      case TtcMergeStep.same:
        break;
    }
  }
  return (take: take, push: push);
}

// =============================================================================
//  TtcRowBook: the bookkeeping one synced table keeps beside its rows
//  (2026-10-17, 0098)
// -----------------------------------------------------------------------------
//  CycleStore and TtcLogStore each carry their own stamp map, removed map and
//  waiting set. The next three stores (records, appointments, the ritual) need
//  exactly the same three, plus one more: WHOSE row it is, because their
//  tables are couple-scoped and either partner may have written a row.
//
//  ⚠️ WHY THE OWNER IS KEPT. The old push wrote `user_id: <me>` on every row
//  it held, including rows it had pulled from the partner. An upsert by id
//  then rewrote his semen analysis as hers. The book remembers the cloud's
//  `user_id` per id, and the push sends that back unchanged; RLS allows it,
//  because the policy is "me or my partner".
//
//  Pure Dart: the store keeps its own rows; the book only keeps times, removals
//  and owners, so the merge decision is unit-tested without a network
//  (`test/ttc_records_ritual_merge_test.dart`).
// =============================================================================

// The book moved to lib/services/remote/sync_row_book.dart on 2026-10-17
// (sync log step 5) so Parenting's logs share it; the TTC stores keep the
// name through this typedef. The original is below, kept for revert.
typedef TtcRowBook = SyncRowBook;

// class TtcRowBook {
//   /// id -> when she last changed it on this phone (ms since epoch, UTC).
//   final Map<String, int> stamps = {};
//
//   /// id -> when it was removed. A removed id stays here so the removal can
//   /// upload and so an older live copy cannot bring it back.
//   final Map<String, int> removed = {};
//
//   /// id -> the row's own columns at the moment it was removed, so the upload
//   /// can still fill the table's NOT NULL columns. Dropped once confirmed.
//   final Map<String, Map<String, dynamic>> removedRows = {};
//
//   /// id -> the cloud's `user_id`, for rows the partner may have written.
//   final Map<String, String> owners = {};
//
//   /// ids the cloud has not confirmed yet.
//   final Set<String> dirty = {};
//
//   static int _now() => DateTime.now().toUtc().millisecondsSinceEpoch;
//
//   /// A live change: added, edited, or put back by an Undo. The Undo is just a
//   /// newer change, so it wins over the removal it reverses everywhere.
//   void touch(String id, {int? at}) {
//     stamps[id] = at ?? _now();
//     removed.remove(id);
//     removedRows.remove(id);
//     dirty.add(id);
//   }
//
//   /// A removal, with the row's columns as they were.
//   void remove(String id, Map<String, dynamic> columns, {int? at}) {
//     final t = at ?? _now();
//     stamps[id] = t;
//     removed[id] = t;
//     removedRows[id] = columns;
//     dirty.add(id);
//   }
//
//   /// The upload's two times for [id], in the shape the columns take.
//   ({String updatedAt, String? removedAt}) times(String id) {
//     String iso(int ms) =>
//         DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();
//     final r = removed[id];
//     return (
//       updatedAt: iso(stamps[id] ?? _now()),
//       removedAt: r == null ? null : iso(r),
//     );
//   }
//
//   /// After an upload of [id] that was sent with stamp [sent]: it leaves the
//   /// waiting set only if the cloud took it and she has not changed it since.
//   void confirmed(String id, {required bool ok, required int? sent}) {
//     if (!ok || stamps[id] != sent) return;
//     dirty.remove(id);
//     removedRows.remove(id);
//   }
//
//   /// Merges the cloud's [rows] (each with `id`, `updated_at`, `removed_at`,
//   /// `user_id`) against the ids this phone holds live, newer wins per id.
//   ///
//   /// Returns the cloud rows the store must take: a row with `removed_at` set
//   /// means "remove it here", any other means "replace it with this". Ids the
//   /// phone holds that are newer, or that the cloud has never seen, are added
//   /// to [dirty] for the next upload.
//   List<Map<String, dynamic>> merge(
//     Iterable<String> liveIds,
//     List<Map<String, dynamic>> rows,
//   ) {
//     final cloudStamp = <String, DateTime>{};
//     final cloudRow = <String, Map<String, dynamic>>{};
//     for (final row in rows) {
//       final id = row['id'];
//       if (id is! String) continue;
//       final owner = row['user_id']?.toString();
//       if (owner != null && owner.isNotEmpty) owners[id] = owner;
//       final stamp = ttcParseStamp(row['updated_at']) ?? ttcEpoch;
//       final seen = cloudStamp[id];
//       if (seen != null && !stamp.isAfter(seen)) continue;
//       cloudStamp[id] = stamp;
//       cloudRow[id] = row;
//     }
//     DateTime at(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
//     final local = <String, DateTime>{
//       for (final id in liveIds)
//         id: stamps[id] == null ? ttcEpoch : at(stamps[id]!),
//       for (final e in removed.entries) e.key: at(stamps[e.key] ?? e.value),
//     };
//     final plan = ttcMergePlan(local: local, cloud: cloudStamp);
//     final take = <Map<String, dynamic>>[];
//     for (final id in plan.take) {
//       final row = cloudRow[id]!;
//       final ms = cloudStamp[id]!.millisecondsSinceEpoch;
//       stamps[id] = ms;
//       final gone = ttcParseStamp(row['removed_at']);
//       if (gone != null) {
//         removed[id] = gone.millisecondsSinceEpoch;
//       } else {
//         removed.remove(id);
//       }
//       removedRows.remove(id);
//       dirty.remove(id);
//       take.add(row);
//     }
//     dirty.addAll(plan.push);
//     for (final id in cloudStamp.keys) {
//       if (!plan.take.contains(id) && !plan.push.contains(id)) {
//         dirty.remove(id);
//       }
//     }
//     return take;
//   }
//
//   void clear() {
//     stamps.clear();
//     removed.clear();
//     removedRows.clear();
//     owners.clear();
//     dirty.clear();
//   }
//
//   /// The local cache: one JSON object beside the store's own rows.
//   Map<String, Object?> toJson() => {
//         'stamps': stamps,
//         'removed': removed,
//         'removedRows': removedRows,
//         'owners': owners,
//         'dirty': dirty.toList(),
//       };
//
//   void loadJson(Object? raw) {
//     clear();
//     if (raw is! Map) return;
//     void ints(Object? m, Map<String, int> into) {
//       if (m is! Map) return;
//       for (final e in m.entries) {
//         if (e.value is num) into[e.key.toString()] = (e.value as num).toInt();
//       }
//     }
//
//     ints(raw['stamps'], stamps);
//     ints(raw['removed'], removed);
//     final rr = raw['removedRows'];
//     if (rr is Map) {
//       for (final e in rr.entries) {
//         if (e.value is Map) {
//           removedRows[e.key.toString()] =
//               Map<String, dynamic>.from(e.value as Map);
//         }
//       }
//     }
//     final ow = raw['owners'];
//     if (ow is Map) {
//       for (final e in ow.entries) {
//         owners[e.key.toString()] = e.value.toString();
//       }
//     }
//     final d = raw['dirty'];
//     if (d is List) dirty.addAll(d.map((e) => e.toString()));
//   }
// }
