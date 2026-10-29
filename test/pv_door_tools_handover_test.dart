// The tools terminal's hand-over to the doors (2026-10-29): PG3, PG4, the
// partner bag card, the timer's one name, the after-loss lines on Labour and
// Getting ready, and two router calls that now pass what they know.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/ready_for_birth_data.dart';
import 'package:parentveda/data/symptoms/symptom_normal.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';

PvDoorToolTile _tool(PvDoorPage d, String title) =>
    d.allTiles.whereType<PvDoorToolTile>().firstWhere((t) => t.title == title);

void main() {
  final router = File(
    'lib/screens/doors/pv_door_router.dart',
  ).readAsStringSync();

  test('PG4: each door books its own 1:1, not the Scans one', () {
    final ids = {
      kScansSurfaceConsult,
      kLabourSurfaceConsult,
      kCondSurfaceConsult,
    };
    expect(ids.length, 3, reason: 'one shared id opened "Talk it through"');
    for (final id in ids) {
      expect(pvDoorSurfaceResolves(id), isTrue, reason: id);
    }
    expect(router, contains("title: 'A 1:1 about the birth'"));
    expect(router, contains("title: 'Your condition, explained'"));
  });

  test(
    'PG3: the Garbh door rows no longer draw a button that does nothing',
    () {
      final live = router
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(live, isNot(contains('onOpenLibrary: () {}')));
    },
  );

  test('the partner bag card opens the bag on Partner and extras', () {
    expect(
      _tool(kLabourDoor, 'What to pack for whoever comes with you').surfaceId,
      kLabourSurfaceBagPartner,
    );
    expect(pvDoorSurfaceResolves(kLabourSurfaceBagPartner), isTrue);
    expect(router, contains("initialCategory: 'partner'"));
    expect(readyCategoryFromName('partner'), ReadyCategory.partnerExtras);
  });

  test('the timer has one name on the Labour door', () {
    final names = {
      for (final t in kLabourDoor.allTiles)
        if (t is PvDoorToolTile && t.surfaceId == kLabourSurfaceTimer) t.title,
    };
    expect(names, {'Contraction timer'});
  });

  test('after a loss, Labour and Getting ready carry a line of their own', () {
    for (final d in [kLabourDoor, kGettingReadyDoor]) {
      expect(d.heroBlurbEnded, isNotNull, reason: d.heroTitle);
      expect(d.heroBlurbEnded, isNot(d.heroBlurb));
      expect(d.heroBlurbEnded, contains('kept'));
    }
  });

  test('the router passes what it knows', () {
    expect(router, contains('SymptomsCallingScreen(pregnancy: c)'));
    expect(
      router,
      contains(
        'kReadySurfaceNames => const BabyNamingHomeScreen(afterLossNote: true)',
      ),
    );
  });

  test('Is this normal? says the count it has', () {
    expect(kNormalQuestions.length, 11);
    final src = File('lib/data/doors/pv_door_symptoms.dart').readAsStringSync();
    expect(src, contains("inlineLabel: '11 questions'"));
  });
}
