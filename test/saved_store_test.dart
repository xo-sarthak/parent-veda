// =============================================================================
//  SavedStore: the merge, the tombstone, the legacy import, the schema.
// -----------------------------------------------------------------------------
//  The behaviours that would fail silently if they drifted: an unsave being
//  resurrected by a stale device, a tester's old saves vanishing on update,
//  and the Dart row shape disagreeing with the SQL columns.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/saved_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

SavedItem _row(SavedKind k, String id, {required int updated, int? saved, bool removed = false}) {
  final u = DateTime.utc(2026, 9, 1).add(Duration(minutes: updated));
  return SavedItem(
    kind: k,
    itemId: id,
    savedAt: DateTime.utc(2026, 9, 1).add(Duration(minutes: saved ?? updated)),
    updatedAt: u,
    removedAt: removed ? u : null,
    title: 't-$id',
  );
}

void main() {
  group('merge — last writer wins, per row, tombstones included', () {
    test('a row only the device has goes up; only the cloud has comes down', () {
      final r = SavedStore.merge(
        local: {'article:a': _row(SavedKind.article, 'a', updated: 1)},
        cloud: {'video:v': _row(SavedKind.video, 'v', updated: 1)},
      );
      expect(r.merged.keys, containsAll(['article:a', 'video:v']));
      expect(r.toPush.map((e) => e.key), ['article:a']);
    });

    test('an unsave on the other device beats a stale save here', () {
      // Phone A saved at t=1 and went offline. Tablet unsaved at t=5.
      final r = SavedStore.merge(
        local: {'article:a': _row(SavedKind.article, 'a', updated: 1)},
        cloud: {'article:a': _row(SavedKind.article, 'a', updated: 5, removed: true)},
      );
      expect(r.merged['article:a']!.live, isFalse,
          reason: 'a union merge would have resurrected it');
      expect(r.toPush, isEmpty);
    });

    test('a newer local unsave beats an older cloud save, and is pushed', () {
      final r = SavedStore.merge(
        local: {'article:a': _row(SavedKind.article, 'a', updated: 9, removed: true)},
        cloud: {'article:a': _row(SavedKind.article, 'a', updated: 2)},
      );
      expect(r.merged['article:a']!.live, isFalse);
      expect(r.toPush.single.removedAt, isNotNull);
    });

    test('a re-save after an unsave is newer than the tombstone and wins', () {
      final r = SavedStore.merge(
        local: {'article:a': _row(SavedKind.article, 'a', updated: 12)},
        cloud: {'article:a': _row(SavedKind.article, 'a', updated: 10, removed: true)},
      );
      expect(r.merged['article:a']!.live, isTrue);
    });

    test('equal timestamps: the cloud copy is kept and nothing is pushed', () {
      final r = SavedStore.merge(
        local: {'article:a': _row(SavedKind.article, 'a', updated: 3)},
        cloud: {'article:a': _row(SavedKind.article, 'a', updated: 3)},
      );
      expect(r.toPush, isEmpty);
    });
  });

  group('save / unsave on the store itself (logged out = local only)', () {
    setUp(() {
      SavedStore.instance.debugReset();
      SharedPreferences.setMockInitialValues({SavedStore.kImportedKey: true});
    });

    test('save, unsave, re-save: live state and savedAt behave', () async {
      final s = SavedStore.instance;
      await s.load();
      await s.save(SavedKind.article, 'x', title: 'How conception actually works');
      expect(s.isSaved(SavedKind.article, 'x'), isTrue);
      final first = s.savedAt(SavedKind.article, 'x');
      await s.unsave(SavedKind.article, 'x');
      expect(s.isSaved(SavedKind.article, 'x'), isFalse);
      expect(s.items(), isEmpty, reason: 'tombstones are never listed');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await s.save(SavedKind.article, 'x');
      expect(s.isSaved(SavedKind.article, 'x'), isTrue);
      expect(s.savedAt(SavedKind.article, 'x')!.isAfter(first!), isTrue,
          reason: 'a re-save is a fresh save, so it moves to the top');
      expect(s.items().single.title, 'How conception actually works',
          reason: 'the snapshot survives an unsave + re-save with no title');
    });

    test('saving twice is one row; the second refreshes the snapshot only', () async {
      final s = SavedStore.instance;
      await s.load();
      await s.save(SavedKind.video, 'v1', title: 'old');
      final at = s.savedAt(SavedKind.video, 'v1');
      await s.save(SavedKind.video, 'v1', title: 'new');
      expect(s.items(kind: SavedKind.video).length, 1);
      expect(s.items(kind: SavedKind.video).single.title, 'new');
      expect(s.savedAt(SavedKind.video, 'v1'), at);
    });

    test('the cache round-trips through prefs', () async {
      final s = SavedStore.instance;
      await s.load();
      await s.save(SavedKind.recipe, 'r1', title: 'Khichdi', stage: 'parenting');
      final p = await SharedPreferences.getInstance();
      final raw = jsonDecode(p.getString(SavedStore.kCacheKey)!) as List;
      expect(raw.single['kind'], 'recipe');
      expect(raw.single['stage'], 'parenting');
      s.debugReset();
      await s.load();
      expect(s.isSaved(SavedKind.recipe, 'r1'), isTrue);
    });

    test('an unknown kind from a newer app is kept in the cache and skipped', () async {
      SharedPreferences.setMockInitialValues({
        SavedStore.kImportedKey: true,
        SavedStore.kCacheKey: jsonEncode([
          {'kind': 'hologram', 'item_id': 'h', 'saved_at': '2026-09-01T00:00:00Z'},
          {'kind': 'article', 'item_id': 'a', 'saved_at': '2026-09-01T00:00:00Z'},
        ]),
      });
      final s = SavedStore.instance;
      await s.load();
      expect(s.items().length, 1);
    });
  });

  group('legacy import — the seven old sets come across once', () {
    setUp(() => SavedStore.instance.debugReset());

    test('every old key is read, in its real shape, and the flag is set', () async {
      SharedPreferences.setMockInitialValues({
        'video_saved': jsonEncode(['v1', 'v2']),
        'video_saved_at': jsonEncode({'v1': 1700000000000}),
        'readnext_saved': jsonEncode({'rn1': 1700000001000}),
        'prod_saved': ['p1'],
        'cani_saved': ['q1'],
        'comm_saved': ['c1'],
        'pv_read_saved': ['conception_how_it_works'],
        'rtb_saved': jsonEncode([
          {'k': 'rtb-key', 't': 'A lullaby', 'b': 'body', 'g': 'Lullaby', 's': 1700000002000},
          {'t': 'Old row with no key', 'b': 'body', 'g': 'Story', 's': 0},
        ]),
      });
      final s = SavedStore.instance;
      await s.load();
      expect(s.isSaved(SavedKind.video, 'v1'), isTrue);
      expect(s.isSaved(SavedKind.video, 'v2'), isTrue);
      expect(s.isSaved(SavedKind.article, 'rn1'), isTrue);
      expect(s.isSaved(SavedKind.product, 'p1'), isTrue);
      expect(s.isSaved(SavedKind.question, 'q1'), isTrue);
      expect(s.isSaved(SavedKind.post, 'c1'), isTrue);
      expect(s.isSaved(SavedKind.article, 'conception_how_it_works'), isTrue);
      expect(s.isSaved(SavedKind.readToBaby, 'rtb-key'), isTrue);
      expect(s.isSaved(SavedKind.readToBaby, 'Old row with no key'), isTrue,
          reason: 'pre-key rows are identified by their English title');
      expect(
          s.items(kind: SavedKind.readToBaby).firstWhere((i) => i.itemId == 'rtb-key').title,
          'A lullaby');
      expect(s.savedAt(SavedKind.video, 'v1'),
          DateTime.fromMillisecondsSinceEpoch(1700000000000, isUtc: true));
      final p = await SharedPreferences.getInstance();
      expect(p.getBool(SavedStore.kImportedKey), isTrue);
      expect(p.getStringList('prod_saved'), ['p1'],
          reason: 'old keys are left intact for a rollback');
    });

    test('the parenting blobs come across too, minus the demo seeds', () async {
      SharedPreferences.setMockInitialValues({
        'pp_watch': jsonEncode({'saved': ['tummytime', 'q_iron', 'sleep4mo'], 'following': []}),
        'pp_reading': jsonEncode({'saved': ['leap4', 'matrescence', 'solids'], 'progress': {}}),
        'pp_daily_tip_v1': jsonEncode({'lastShown': '2026-09-01', 'saved': ['tip_3']}),
      });
      final s = SavedStore.instance;
      await s.load();
      expect(s.isSaved(SavedKind.video, 'sleep4mo'), isTrue);
      expect(s.isSaved(SavedKind.video, 'tummytime'), isFalse, reason: 'demo seed');
      expect(s.isSaved(SavedKind.article, 'solids'), isTrue);
      expect(s.isSaved(SavedKind.article, 'leap4'), isFalse, reason: 'demo seed');
      expect(s.isSaved(SavedKind.tip, 'tip_3'), isTrue);
    });

    test('the cloud blobs are lifted once per account, in each store in its own shape', () async {
      SharedPreferences.setMockInitialValues({SavedStore.kImportedKey: true});
      final s = SavedStore.instance;
      await s.load();
      final blobs = <String, dynamic>{
        'video_saved': {'saved': ['v9'], 'savedAt': {'v9': 1700000000000}},
        'readnext': {'status': {}, 'saved': {'rn9': 1700000001000}},
        'prod_saved': ['p9'],
        'cani_saved': ['q9'],
        'community': {'saved': ['c9'], 'liked': []},
        'rtb_saved': [{'k': 'k9', 't': 'T9', 'b': 'b', 'g': 'g', 's': 1700000002000}],
        'pp_watch': {'saved': ['tummytime', 'w9']},
        'pp_reading': {'saved': ['r9']},
        'pp_daily_tip_v1': {'saved': ['tip_9']},
      };
      final n = await s.importLegacyCloud((k) async => blobs[k]);
      expect(n, 9);
      expect(s.isSaved(SavedKind.video, 'v9'), isTrue);
      expect(s.isSaved(SavedKind.video, 'w9'), isTrue);
      expect(s.isSaved(SavedKind.video, 'tummytime'), isFalse);
      expect(s.isSaved(SavedKind.article, 'rn9'), isTrue);
      expect(s.isSaved(SavedKind.article, 'r9'), isTrue);
      expect(s.isSaved(SavedKind.product, 'p9'), isTrue);
      expect(s.isSaved(SavedKind.question, 'q9'), isTrue);
      expect(s.isSaved(SavedKind.post, 'c9'), isTrue);
      expect(s.isSaved(SavedKind.readToBaby, 'k9'), isTrue);
      expect(s.isSaved(SavedKind.tip, 'tip_9'), isTrue);
      expect(s.savedAt(SavedKind.video, 'v9'),
          DateTime.fromMillisecondsSinceEpoch(1700000000000, isUtc: true));
      // A second pass adds nothing — rows already present are kept.
      expect(await s.importLegacyCloud((k) async => blobs[k]), 0);
    });

    test('the import runs once — a second load does not re-add an unsaved item', () async {
      SharedPreferences.setMockInitialValues({'prod_saved': ['p1']});
      final s = SavedStore.instance;
      await s.load();
      await s.unsave(SavedKind.product, 'p1');
      s.debugReset();
      await s.load();
      expect(s.isSaved(SavedKind.product, 'p1'), isFalse);
    });
  });

  group('schema contract — Dart row shape agrees with 0081', () {
    final sql = File('supabase/migrations/0081_saved_items.sql').readAsStringSync();

    test('every column the Dart row writes exists in the migration', () {
      final row = _row(SavedKind.article, 'a', updated: 1).toRow();
      for (final col in row.keys) {
        expect(RegExp('^\\s+$col\\s').hasMatch(sql) || sql.contains('  $col '), isTrue,
            reason: 'column $col missing from 0081');
      }
    });

    test('every SavedKind id is accepted by the check constraint', () {
      for (final k in SavedKind.values) {
        expect(sql.contains("'${k.id}'"), isTrue, reason: k.id);
      }
    });

    test('the natural key is the primary key, and RLS is own-row on all four verbs', () {
      expect(sql.contains('primary key (user_id, kind, item_id)'), isTrue);
      for (final verb in ['select', 'insert', 'update', 'delete']) {
        expect(sql.contains('saved_items_$verb'), isTrue, reason: verb);
      }
      expect(sql.contains('my_partner_id'), isFalse,
          reason: 'bookmarks are personal — FAMILY-MODEL §5');
    });
  });
}
