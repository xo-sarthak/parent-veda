// =============================================================================
//  SyncBatch: upload waiting rows in batches, not one request each
//  (2026-10-21, sync log step 11)
// -----------------------------------------------------------------------------
//  Every ledger used to upload its waiting rows one request at a time. Fine for
//  the one or two rows a normal edit leaves, but a FIRST sync (a new phone, a
//  reinstall, months of offline use) queues every row the phone holds: months
//  of feeds, nappies and logs, hundreds to thousands of round trips in a row.
//
//  A batch is one statement, and a statement is all-or-nothing: if ONE row
//  breaks a check (the Symptoms door's 'strong' did, step 9), Postgres refuses
//  the other 99 with it. So a refused batch is retried row by row, which finds
//  the bad row and lets every good one through. The bad one stays waiting, as
//  it would have before, and keeps the sign-out sheet honest.
//
//  "Refused" and "no answer" are told apart (`SyncSend`): offline, a row-by-row
//  retry would be a hundred more failing requests, so the round stops and the
//  next sync tries again.
//
//  Pure apart from [send], so the rule is unit-tested without a network
//  (`test/sync_batch_test.dart`).
// =============================================================================

/// How an upload went.
enum SyncSend {
  /// The server took it.
  ok,

  /// The server answered no: a check, a policy, a column it lacks.
  refused,

  /// No answer at all: offline, or the backend is not there.
  offline,
}

class SyncBatch {
  SyncBatch._();

  /// Rows per request. Small enough for any request size limit, big enough
  /// that a year of logs is a handful of requests.
  static const int size = 100;

  /// Uploads [rows] (key -> row) through [send] and returns the keys the
  /// server took. Rows go in groups of the same column set, [chunk] at a
  /// time; a refused chunk is retried row by row; the round stops at the
  /// first sign of being offline.
  static Future<Set<String>> push(
    Map<String, Map<String, dynamic>> rows,
    Future<SyncSend> Function(List<Map<String, dynamic>> rows) send, {
    int chunk = size,
  }) async {
    final took = <String>{};
    // One request needs one column list: group by the set of keys.
    final groups = <String, List<String>>{};
    for (final e in rows.entries) {
      final shape = (e.value.keys.toList()..sort()).join('\u0001');
      (groups[shape] ??= <String>[]).add(e.key);
    }
    for (final keys in groups.values) {
      for (var i = 0; i < keys.length; i += chunk) {
        final part = keys.sublist(i, i + chunk > keys.length ? keys.length : i + chunk);
        final r = await send([for (final k in part) rows[k]!]);
        if (r == SyncSend.ok) {
          took.addAll(part);
          continue;
        }
        if (r == SyncSend.offline) return took;
        // Refused: one row in it is bad. Find it, let the rest through.
        if (part.length == 1) continue;
        for (final k in part) {
          final one = await send([rows[k]!]);
          if (one == SyncSend.ok) took.add(k);
          if (one == SyncSend.offline) return took;
        }
      }
    }
    return took;
  }
}
