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
