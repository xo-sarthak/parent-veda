// =============================================================================
//  SyncRowBook: the bookkeeping one synced table keeps beside its rows
//  (2026-10-17; moved here from lib/ttc/ttc_row_merge.dart in sync log step 5)
// -----------------------------------------------------------------------------
//  Every row table that syncs "newer wins" needs the same four things next to
//  its own rows:
//
//    · stamps:  when each row was last changed ON THIS PHONE;
//    · removed: which rows were removed, and when (a soft delete), so the
//               removal can upload and an older live copy cannot bring it back;
//    · owners:  WHOSE row it is, for tables two people write (a couple's TTC
//               records, a child's logs), so the push never rewrites the
//               partner's row as ours;
//    · dirty:   which rows the cloud has not confirmed yet.
//
//  It was born as `TtcRowBook` (0098). Parenting's logs (0101) need exactly the
//  same book, so it lives here now, beside the other sync plumbing, and
//  `TtcRowBook` is a typedef of it. One rule, one implementation: two copies
//  would drift.
//
//  Pure Dart and network-free, so the merge decision is unit-tested directly
//  (`test/ttc_records_ritual_merge_test.dart`, `test/pp_logs_merge_test.dart`).
// =============================================================================

/// The time a row the phone held before the sync clock existed is given:
/// older than anything, so the cloud's copy wins wherever there is one.
final DateTime syncEpoch = DateTime.utc(2000);

/// A cloud timestamp column, read safely. Null when absent or unreadable.
DateTime? syncParseStamp(Object? v) {
  final s = v?.toString();
  if (s == null || s.isEmpty) return null;
  return DateTime.tryParse(s)?.toUtc();
}

class SyncRowBook {
  /// id -> when it was last changed on this phone (ms since epoch, UTC).
  final Map<String, int> stamps = {};

  /// id -> when it was removed. A removed id stays here so the removal can
  /// upload and so an older live copy cannot bring it back.
  final Map<String, int> removed = {};

  /// id -> the row's own columns at the moment it was removed, so the upload
  /// can still fill the table's NOT NULL columns. Dropped once confirmed.
  final Map<String, Map<String, dynamic>> removedRows = {};

  /// id -> the cloud's `user_id`, for rows the partner may have written.
  final Map<String, String> owners = {};

  /// ids the cloud has not confirmed yet.
  final Set<String> dirty = {};

  static int _now() => DateTime.now().toUtc().millisecondsSinceEpoch;

  /// A live change: added, edited, or put back by an Undo. The Undo is just a
  /// newer change, so it wins over the removal it reverses everywhere.
  void touch(String id, {int? at}) {
    stamps[id] = at ?? _now();
    removed.remove(id);
    removedRows.remove(id);
    dirty.add(id);
  }

  /// A removal, with the row's columns as they were.
  void remove(String id, Map<String, dynamic> columns, {int? at}) {
    final t = at ?? _now();
    stamps[id] = t;
    removed[id] = t;
    removedRows[id] = columns;
    dirty.add(id);
  }

  /// The upload's two times for [id], in the shape the columns take.
  ({String updatedAt, String? removedAt}) times(String id) {
    String iso(int ms) =>
        DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();
    final r = removed[id];
    return (
      updatedAt: iso(stamps[id] ?? _now()),
      removedAt: r == null ? null : iso(r),
    );
  }

  /// After an upload of [id] that was sent with stamp [sent]: it leaves the
  /// waiting set only if the cloud took it and nothing has changed it since.
  void confirmed(String id, {required bool ok, required int? sent}) {
    if (!ok || stamps[id] != sent) return;
    dirty.remove(id);
    removedRows.remove(id);
  }

  /// Merges the cloud's [rows] (each with `id`, `updated_at`, `removed_at`,
  /// `user_id`) against the ids this phone holds live, newer wins per id.
  ///
  /// Returns the cloud rows the store must take: a row with `removed_at` set
  /// means "remove it here", any other means "replace it with this". Ids the
  /// phone holds that are newer, or that the cloud has never seen, are added
  /// to [dirty] for the next upload.
  ///
  /// [inScope], when given, limits which of the book's removals take part:
  /// a pull that fetched only part of the table (one child's rows) must not
  /// read a removal from another part as "the cloud has never seen this".
  List<Map<String, dynamic>> merge(
    Iterable<String> liveIds,
    List<Map<String, dynamic>> rows, {
    bool Function(String id)? inScope,
  }) {
    final cloudStamp = <String, DateTime>{};
    final cloudRow = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      final id = row['id'];
      if (id is! String) continue;
      final owner = row['user_id']?.toString();
      if (owner != null && owner.isNotEmpty) owners[id] = owner;
      final stamp = syncParseStamp(row['updated_at']) ?? syncEpoch;
      final seen = cloudStamp[id];
      if (seen != null && !stamp.isAfter(seen)) continue;
      cloudStamp[id] = stamp;
      cloudRow[id] = row;
    }
    DateTime at(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    final local = <String, DateTime>{
      for (final id in liveIds)
        id: stamps[id] == null ? syncEpoch : at(stamps[id]!),
      for (final e in removed.entries)
        if (inScope == null || inScope(e.key))
          e.key: at(stamps[e.key] ?? e.value),
    };
    final take = <String>{};
    final push = <String>{};
    for (final k in {...local.keys, ...cloudStamp.keys}) {
      final l = local[k];
      final c = cloudStamp[k];
      if (c == null) {
        if (l != null) push.add(k);
      } else if (l == null || c.isAfter(l)) {
        take.add(k);
      } else if (l.isAfter(c)) {
        push.add(k);
      }
    }
    final taken = <Map<String, dynamic>>[];
    for (final id in take) {
      final row = cloudRow[id]!;
      stamps[id] = cloudStamp[id]!.millisecondsSinceEpoch;
      final gone = syncParseStamp(row['removed_at']);
      if (gone != null) {
        removed[id] = gone.millisecondsSinceEpoch;
      } else {
        removed.remove(id);
      }
      removedRows.remove(id);
      dirty.remove(id);
      taken.add(row);
    }
    dirty.addAll(push);
    for (final id in cloudStamp.keys) {
      if (!take.contains(id) && !push.contains(id)) dirty.remove(id);
    }
    dropSettled();
    return taken;
  }

  /// How long this phone remembers a removal the cloud has confirmed
  /// (sync log step 12, 2026-10-21). SHORTER than the server's purge (0109,
  /// 90 days) on purpose, and the order matters:
  ///
  ///   · phone forgets first (day 80): the cloud still has the removed row,
  ///     so the next pull simply reads the removal again, and this drops it
  ///     again at the end of the same merge. Harmless.
  ///   · server forgets first: a phone still holding the removal would see
  ///     "the cloud has never heard of this", upload it, and undo the purge,
  ///     every day, for ever (see [merge]: a removal the cloud lacks is
  ///     pushed). That is the case 80 < 90 rules out.
  static const Duration keepRemovals = Duration(days: 80);

  /// Forgets removals the cloud has confirmed (not [dirty]) and that are
  /// older than [keepRemovals]. Returns the ids it dropped, so a ledger can
  /// drop its own notes about them. Before step 12 a removal stayed in the
  /// phone's book for ever.
  Set<String> dropSettled({int? nowMs}) {
    final cutoff = (nowMs ?? _now()) - keepRemovals.inMilliseconds;
    final drop = <String>{
      for (final e in removed.entries)
        if (e.value < cutoff && !dirty.contains(e.key)) e.key,
    };
    for (final id in drop) {
      removed.remove(id);
      stamps.remove(id);
      owners.remove(id);
      removedRows.remove(id);
    }
    return drop;
  }

  void clear() {
    stamps.clear();
    removed.clear();
    removedRows.clear();
    owners.clear();
    dirty.clear();
  }

  /// The local cache: one JSON object beside the store's own rows.
  Map<String, Object?> toJson() => {
        'stamps': stamps,
        'removed': removed,
        'removedRows': removedRows,
        'owners': owners,
        'dirty': dirty.toList(),
      };

  void loadJson(Object? raw) {
    clear();
    if (raw is! Map) return;
    void ints(Object? m, Map<String, int> into) {
      if (m is! Map) return;
      for (final e in m.entries) {
        if (e.value is num) into[e.key.toString()] = (e.value as num).toInt();
      }
    }

    ints(raw['stamps'], stamps);
    ints(raw['removed'], removed);
    final rr = raw['removedRows'];
    if (rr is Map) {
      for (final e in rr.entries) {
        if (e.value is Map) {
          removedRows[e.key.toString()] =
              Map<String, dynamic>.from(e.value as Map);
        }
      }
    }
    final ow = raw['owners'];
    if (ow is Map) {
      for (final e in ow.entries) {
        owners[e.key.toString()] = e.value.toString();
      }
    }
    final d = raw['dirty'];
    if (d is List) dirty.addAll(d.map((e) => e.toString()));
  }
}
