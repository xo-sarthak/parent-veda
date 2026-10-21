// =============================================================================
//  The relevance brain (2026-10-21, Wave 4, pp_relevance.dart). Parenting is
//  ordered by where the child is, and nothing is ever removed.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tile_order.dart';
import 'package:parentveda/services/pv_read_store.dart';

const _titles = [
  'When to start, and how to begin',
  'Making up a bottle safely',
  'After a C-section, the first weeks',
  'Milestones for babies born early',
  'Getting the latch right',
];

List<String> _order(PpSituation s, {String? Function(String)? readId}) =>
    ppRelevanceOrder(_titles.toList(), situation: s, text: (t) => t, readId: readId);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every item comes back, whatever the situation', () {
    for (final sig in [<PpSignal>{}, PpSignal.values.toSet(), {PpSignal.formula}]) {
      final out = _order(PpSituation(ageMonths: 7, daysOld: 210, signals: sig));
      expect(out.toSet(), _titles.toSet(), reason: '$sig');
      expect(out.length, _titles.length);
    }
  });

  test('with no signal, the writers\' order is untouched (stable)', () {
    expect(_order(const PpSituation(ageMonths: 7, daysOld: 210)), _titles);
  });

  test('a born-early baby\'s page leads; a formula family\'s bottle page leads', () {
    expect(_order(const PpSituation(ageMonths: 7, daysOld: 210, signals: {PpSignal.bornEarly})).first,
        'Milestones for babies born early');
    expect(_order(const PpSituation(ageMonths: 7, daysOld: 210, signals: {PpSignal.formula})).first,
        'Making up a bottle safely');
  });

  test('a C-section mother in the first weeks sees recovery first', () {
    expect(_order(const PpSituation(ageMonths: 0, daysOld: 20, signals: {PpSignal.cSection})).first,
        'After a C-section, the first weeks');
  });

  test('the child\'s own band leads, then the next, then earlier', () {
    final items = [
      ('earlier', PpBandDistance.earlier),
      ('later', PpBandDistance.further),
      ('now', PpBandDistance.now),
      ('next', PpBandDistance.next),
    ];
    final out = ppRelevanceOrder(items,
        situation: const PpSituation(ageMonths: 15, daysOld: 456), text: (x) => x.$1, band: (x) => x.$2);
    expect([for (final x in out) x.$1], ['now', 'next', 'earlier', 'later']);
  });

  test('a finished read sinks below the ones she has not read', () {
    PvReadStore.instance.setProgress('read_latch', 1.0);
    final out = _order(const PpSituation(ageMonths: 1, daysOld: 30),
        readId: (t) => t == 'Getting the latch right' ? 'read_latch' : null);
    expect(out.last, 'Getting the latch right');
    expect(out.toSet(), _titles.toSet());
  });

  test('the moved card says why, in a few words', () {
    const s = PpSituation(ageMonths: 7, daysOld: 210, signals: {PpSignal.formula});
    expect(ppRelevanceWhy(s, 'Making up a bottle safely'), 'On formula');
    expect(ppRelevanceWhy(s, 'Getting the latch right'), isNull, reason: 'not her signal');
  });

  test('home door tiles: born early lifts Development', () {
    const ids = ['parenting_sleep', 'parenting_feeding', 'parenting_health', 'parenting_development'];
    final plain = ppTileOrder(ids, ageInDays: 210);
    final early = ppTileOrder(ids, ageInDays: 210, signals: {PpSignal.bornEarly});
    expect(early.indexOf('parenting_development'), lessThan(plain.indexOf('parenting_development')));
    expect(early.toSet(), ids.toSet());
  });

  testWidgets('a door no longer hides the other bands: the next is open, the rest fold', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 215)));
    t.view.physicalSize = const Size(1200, 9000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    final door = ppDoorFor('parenting_feeding')!;
    await t.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, onSurface: (_, _) {})));
    await t.pumpAndSettle();
    // Some tab of the feeding door has another band to show; walk the tabs
    // until one does, so the test does not pin which tab holds what.
    var found = false;
    for (final label in [for (final tab in door.tabs) tab.label]) {
      final f = find.text(label);
      if (f.evaluate().isEmpty) continue;
      await t.tap(f.first);
      await t.pumpAndSettle();
      if (find.text('Coming up next').evaluate().isNotEmpty ||
          find.byWidgetPredicate((w) => w.key is ValueKey && '${(w.key! as ValueKey).value}'.startsWith('pp_door_band_fold_')).evaluate().isNotEmpty) {
        found = true;
        break;
      }
    }
    expect(found, isTrue, reason: 'another band is reachable from the door');
    expect(t.takeException(), isNull);
  });
}
