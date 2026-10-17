// =============================================================================
//  Parenting logs sync newer-wins, removals included (0101, sync log step 5)
// -----------------------------------------------------------------------------
//  Feeds, sleeps, nappies, pumping, tummy time and growth used a union pull and
//  a one-shot hard delete, so a log one parent removed came back from the other
//  parent's phone. They now keep a `ChildLogLedger`. These cases run the merge
//  and the upload decision directly, with no network, and read the six stores'
//  source to check they are wired to it.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/remote/child_scoped_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Row = Map<String, dynamic>;

String iso(int ms) =>
    DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();

final t0 = DateTime.utc(2026, 10, 17, 9).millisecondsSinceEpoch;
const minute = 60000;

Row feed(String id, {String note = ''}) =>
    {'id': id, 'time': iso(t0), 'kind': 'breast', 'note': note};

Row cloud(String id,
        {required int at,
        int? removedAt,
        String note = '',
        String owner = 'me',
        String child = 'kid_a'}) =>
    {
      ...feed(id, note: note),
      'child_id': child,
      'user_id': owner,
      'updated_at': iso(at),
      'removed_at': removedAt == null ? null : iso(removedAt),
    };

List<Row> pull(ChildLogLedger l, List<Row> local, List<Row> rows,
        {String child = 'kid_a'}) =>
    l.apply<Row>(
      childId: child,
      local: local,
      rows: rows,
      idOf: (r) => r['id'] as String,
      fromRow: (r) => r,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  ChildLogLedger ledger() => ChildLogLedger('pp_feed_logs', 'test_sync');

  test('a removal survives a pull of an older live copy', () {
    final l = ledger()..touch('f1', 'kid_a');
    l.book.remove('f1', feed('f1'), at: t0 + 2 * minute);
    final out = pull(l, [], [cloud('f1', at: t0 + minute)]);
    expect(out, isEmpty, reason: 'the older live copy must not bring it back');
    expect(l.book.dirty, contains('f1'), reason: 'the removal still uploads');
  });

  test("the other parent's newer removal removes it here", () {
    final l = ledger();
    l.book.touch('f1', at: t0);
    final out = pull(l, [feed('f1')], [
      cloud('f1', at: t0 + minute, removedAt: t0 + minute, owner: 'partner'),
    ]);
    expect(out, isEmpty);
    expect(l.book.dirty, isNot(contains('f1')));
  });

  test('a newer cloud edit replaces the copy here', () {
    final l = ledger();
    l.book.touch('f1', at: t0);
    final out = pull(l, [feed('f1', note: 'old')],
        [cloud('f1', at: t0 + minute, note: 'new')]);
    expect(out.single['note'], 'new');
  });

  test('a newer edit here wins and waits to upload', () {
    final l = ledger();
    l.book.touch('f1', at: t0 + 2 * minute);
    final out = pull(l, [feed('f1', note: 'mine')],
        [cloud('f1', at: t0 + minute, note: 'theirs')]);
    expect(out.single['note'], 'mine');
    expect(l.book.dirty, contains('f1'));
  });

  test('a row cached before this release loses to the cloud; a local-only one uploads', () {
    final l = ledger();
    final out = pull(l, [feed('f1', note: 'cached'), feed('f2')],
        [cloud('f1', at: t0, note: 'cloud')]);
    expect(out.firstWhere((r) => r['id'] == 'f1')['note'], 'cloud');
    expect(l.book.dirty, contains('f2'));
    expect(l.book.dirty, isNot(contains('f1')));
  });

  test("a pull of one child leaves another child's rows and removals alone", () {
    final l = ledger()..touch('b1', 'kid_b');
    l.book.dirty.clear(); // b1 already confirmed
    l.remove('b2', feed('b2'), 'kid_b');
    l.book.dirty.clear(); // b2's removal already confirmed too
    final out = pull(l, [feed('b1')], [cloud('a1', at: t0)]);
    expect(out.map((r) => r['id']), containsAll(['a1', 'b1']));
    expect(l.book.dirty, isEmpty,
        reason: "kid_b's rows are not missing from kid_a's cloud rows");
  });

  test('Undo after a removal ends live everywhere', () {
    final l = ledger()..remove('f1', feed('f1'), 'kid_a');
    l.touch('f1', 'kid_a');
    expect(l.book.removed, isNot(contains('f1')));
    final up = l.uploadFor('f1', {'f1': feed('f1')}, uid: 'me')!;
    expect(up.row['removed_at'], isNull);
  });

  group('the upload', () {
    test("the partner's row is an UPDATE that keeps their name on it", () {
      final l = ledger();
      pull(l, [], [cloud('f1', at: t0, owner: 'partner')]);
      l.book.touch('f1');
      final up = l.uploadFor('f1', {'f1': feed('f1', note: 'fixed')}, uid: 'me')!;
      expect(up.asUpdate, isTrue,
          reason: 'an upsert is checked against the insert policy and refused');
      expect(up.row.containsKey('user_id'), isFalse);
      expect(up.row.containsKey('id'), isFalse);
      expect(up.row['note'], 'fixed');
      expect(up.row['child_id'], 'kid_a');
    });

    test('our own row is an upsert as us', () {
      final l = ledger()..touch('f1', 'kid_a');
      final up = l.uploadFor('f1', {'f1': feed('f1')}, uid: 'me')!;
      expect(up.asUpdate, isFalse);
      expect(up.row['user_id'], 'me');
      expect(up.row['child_id'], 'kid_a');
      expect(up.row['updated_at'], isNotNull);
    });

    test('a removal sends its last columns and removed_at', () {
      final l = ledger()..remove('f1', feed('f1', note: 'last'), 'kid_a');
      final up = l.uploadFor('f1', const {}, uid: 'me')!;
      expect(up.row['note'], 'last');
      expect(up.row['time'], isNotNull, reason: 'time is NOT NULL');
      expect(up.row['removed_at'], isNotNull);
    });

    test('nothing is sent before a child exists', () {
      final l = ledger()..touch('f1', null);
      expect(l.uploadFor('f1', {'f1': feed('f1')}, uid: 'me'), isNull);
      expect(
          l.uploadFor('f1', {'f1': feed('f1')},
              uid: 'me', fallbackChildId: 'kid_a'),
          isNotNull);
    });

    test('seed rows (empty id) never enter the book', () {
      final l = ledger()..touch('', 'kid_a');
      expect(l.hasPending, isFalse);
    });
  });

  test('the book survives a restart', () async {
    final l = ledger()..touch('f1', 'kid_a');
    l.remove('f2', feed('f2'), 'kid_a');
    await l.save();
    final again = ledger();
    await again.load();
    expect(again.book.dirty, containsAll(['f1', 'f2']));
    expect(again.book.removedRows['f2']!['id'], 'f2');
    expect(again.childOf['f1'], 'kid_a');
  });

  test('all six log stores are wired to the ledger', () {
    const files = {
      'lib/screens/post_pregnancy/pp_feeding_data.dart': 1,
      'lib/screens/post_pregnancy/pp_sleep_data.dart': 1,
      'lib/screens/post_pregnancy/pp_growth_data.dart': 1,
      'lib/screens/post_pregnancy/pp_care_log_data.dart': 3,
    };
    for (final e in files.entries) {
      final src = File(e.key).readAsStringSync();
      final live = src
          .split('\n')
          .where((line) => !line.trimLeft().startsWith('//'))
          .join('\n');
      expect(RegExp(r'ChildLogLedger\(').allMatches(live).length, e.value,
          reason: e.key);
      expect(RegExp(r'SyncRegistry\.registerPending\(_hasPending\)')
              .allMatches(live)
              .length,
          e.value,
          reason: '${e.key}: the sign-out sheet must see waiting logs');
      for (final old in ['ChildSync.merge', 'ChildSync.push(', 'ChildSync.remove(']) {
        expect(live, isNot(contains(old)), reason: '${e.key} still calls $old');
      }
    }
  });
}
