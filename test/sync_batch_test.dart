// =============================================================================
//  SyncBatch: waiting rows go up in batches (sync log step 11, 2026-10-21)
// -----------------------------------------------------------------------------
//  The rule, without a network: rows of one shape go together, 100 at a time;
//  a refused batch is retried row by row so one bad row cannot hold back the
//  rest; and "no answer" stops the round at once.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/remote/sync_batch.dart';

Map<String, Map<String, dynamic>> rows(int n, {String prefix = 'r'}) => {
      for (var i = 0; i < n; i++) '$prefix$i': {'id': '$prefix$i', 'v': i},
    };

void main() {
  test('250 rows of one shape go in three requests', () async {
    final sizes = <int>[];
    final took = await SyncBatch.push(rows(250), (b) async {
      sizes.add(b.length);
      return SyncSend.ok;
    });
    expect(sizes, [100, 100, 50]);
    expect(took.length, 250);
  });

  test('rows with different columns never share a request', () async {
    final mixed = {
      ...rows(3),
      'x': {'id': 'x', 'v': 1, 'removed_at': null},
    };
    final shapes = <Set<String>>[];
    await SyncBatch.push(mixed, (b) async {
      final keys = b.map((r) => (r.keys.toList()..sort()).join(',')).toSet();
      expect(keys.length, 1, reason: 'one column list per request');
      shapes.add(keys);
      return SyncSend.ok;
    });
    expect(shapes.length, 2);
  });

  test('one bad row is found and the good ones still land', () async {
    var requests = 0;
    final took = await SyncBatch.push(rows(5), (b) async {
      requests++;
      return b.any((r) => r['id'] == 'r2') ? SyncSend.refused : SyncSend.ok;
    });
    expect(took, {'r0', 'r1', 'r3', 'r4'});
    expect(requests, 1 + 5, reason: 'the batch, then each row once');
  });

  test('offline stops the round at once: no request storm', () async {
    var requests = 0;
    final took = await SyncBatch.push(rows(300), (b) async {
      requests++;
      return SyncSend.offline;
    });
    expect(took, isEmpty);
    expect(requests, 1);
  });

  test('going offline during the row-by-row retry also stops it', () async {
    var requests = 0;
    final took = await SyncBatch.push(rows(5), (b) async {
      requests++;
      if (b.length > 1) return SyncSend.refused;
      return b.single['id'] == 'r0' ? SyncSend.ok : SyncSend.offline;
    });
    expect(took, {'r0'});
    expect(requests, 3);
  });

  test('nothing waiting sends nothing', () async {
    var requests = 0;
    final took = await SyncBatch.push({}, (b) async {
      requests++;
      return SyncSend.ok;
    });
    expect(took, isEmpty);
    expect(requests, 0);
  });
}
