// =============================================================================
//  Supplements and the family timeline: removals that stay removed (0099)
// -----------------------------------------------------------------------------
//  Step 2 of STILL-OPEN-BACKEND §1 (docs/BACKEND-SYNC-LOG.md). Two things this
//  pins beyond step 1's pattern:
//   · a supplement's ticks no longer vanish by cascade, so removing or merging
//     a supplement must mark its ticks removed itself;
//   · the timeline could never sync (no UPDATE grant before 0099), so every
//     moment the phone holds must wait to upload on the first pull.
//
//  Network-free: the stores' merges take cloud rows directly.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/family_timeline.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/ttc_author.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';

const _old = '2020-01-01T00:00:00.000Z';
const _new = '2100-01-01T00:00:00.000Z';

String _day(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Map<String, dynamic> _supRow(String id,
        {String at = _old, String? removed, String owner = 'her'}) =>
    {
      'id': id,
      'user_id': owner,
      'for_partner': false,
      'name': 'Folic acid',
      'dose': '400 mcg daily',
      'updated_at': at,
      'removed_at': removed,
    };

Map<String, dynamic> _tickRow(String supId, String day,
        {String at = _old, String? removed, String owner = 'her'}) =>
    {
      'user_id': owner,
      'supplement_id': supId,
      'taken_on': day,
      'updated_at': at,
      'removed_at': removed,
    };

Map<String, dynamic> _momentRow(String id,
        {String at = _old, String? removed, String owner = 'her'}) =>
    {
      'id': id,
      'user_id': owner,
      'stage': 'trying',
      'kind': 'milestone',
      'happened_on': '2026-09-01',
      'title_en': 'Started trying',
      'title_hi': 'Started trying',
      'updated_at': at,
      'removed_at': removed,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcSupplementsStore.instance.resetForTest();
    FamilyTimeline.instance.resetForTest();
  });

  // ===========================================================================
  group('supplements', () {
    final store = TtcSupplementsStore.instance;
    final today = _day(DateTime.now());

    test('removing one removes its ticks too, and older copies stay away', () {
      final s = store.add('Folic acid', dose: '400 mcg daily');
      store.toggleTaken(s.id);
      store.remove(s.id);
      final k = '${s.id}|$today';
      expect(store.takenBookForTest.removed, contains(k),
          reason: 'no cascade any more: the tick is removed by the app');
      store.applyCloudRows([_supRow(s.id)], [_tickRow(s.id, today)]);
      expect(store.items, isEmpty);
      expect(store.isTaken(s.id), isFalse);
      expect(store.hasPendingPush, isTrue);
    });

    test('a newer un-tick from the other phone is taken', () {
      final s = store.add('Folic acid');
      store.toggleTaken(s.id);
      store.applyCloudRows(
          [_supRow(s.id, at: _new)], [_tickRow(s.id, today, at: _new, removed: _new)]);
      expect(store.isTaken(s.id), isFalse);
    });

    test('a duplicate merge moves each tick as a removal plus an add', () {
      const a = TtcSupplement(id: 'ttcs_a', name: 'Folic acid', dose: '');
      const b = TtcSupplement(id: 'ttcs_b', name: 'folic acid', dose: '400 mcg');
      store.addRawForTest(a);
      store.addRawForTest(b);
      store.toggleTaken('ttcs_b');
      final kept = store.merge(store.duplicates().single);
      expect(kept!.id, 'ttcs_a');
      expect(store.isTaken('ttcs_a'), isTrue);
      expect(store.takenBookForTest.removed, contains('ttcs_b|$today'));
      expect(store.takenBookForTest.dirty, contains('ttcs_a|$today'));
      expect(store.bookForTest.removed, contains('ttcs_b'));
    });

    test("the partner's supplement and tick keep his owner", () {
      store.applyCloudRows([
        _supRow('ttcs_his', owner: 'him', at: _new)
          ..['for_partner'] = true,
      ], [
        _tickRow('ttcs_his', today, owner: 'him', at: _new),
      ]);
      expect(store.forAuthor(TtcAuthor.partner).single.id, 'ttcs_his');
      expect(store.isTaken('ttcs_his'), isTrue);
      expect(store.bookForTest.owners['ttcs_his'], 'him');
      expect(store.takenBookForTest.owners['ttcs_his|$today'], 'him');
    });
  });

  // ===========================================================================
  group('family timeline', () {
    final tl = FamilyTimeline.instance;
    void addStarted() => tl.add(
          id: 'ttc_started',
          stage: LifeStage.tryingToConceive,
          kind: TimelineKind.milestone,
          titleEn: 'Started trying',
          titleHi: 'Started trying',
          on: DateTime(2026, 9, 1),
        );

    test('a moment the cloud never got waits to upload (it never synced)', () {
      addStarted();
      tl.bookForTest.dirty.clear();
      tl.bookForTest.stamps.clear(); // as held before this release
      tl.applyCloudRows(const []);
      expect(tl.has('ttc_started'), isTrue);
      expect(tl.hasPendingPush, isTrue);
    });

    test('a removal is not undone by an older cloud copy', () {
      addStarted();
      tl.remove('ttc_started');
      tl.applyCloudRows([_momentRow('ttc_started')]);
      expect(tl.has('ttc_started'), isFalse);
    });

    test('a removal on the other phone is taken here', () {
      addStarted();
      tl.applyCloudRows([_momentRow('ttc_started', at: _new, removed: _new)]);
      expect(tl.has('ttc_started'), isFalse);
    });

    test('a date correction now waits to upload', () {
      addStarted();
      tl.bookForTest.dirty.clear();
      tl.refreshDerived('ttc_started', on: DateTime(2026, 8, 19));
      expect(tl.hasPendingPush, isTrue);
    });

    test("a partner's moment is shown and remembered as his", () {
      tl.applyCloudRows([_momentRow('ttc_his', owner: 'him')]);
      expect(tl.has('ttc_his'), isTrue);
      expect(tl.bookForTest.owners['ttc_his'], 'him');
    });
  });
}
