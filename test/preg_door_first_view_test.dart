// Relevance Batch 2 (2026-10-27): a Pregnancy door opens on her week.
// docs/door-relevance/README.md, PREGNANCY-GAP.md §4. The weeks are clinical
// facts; each door's `openingGroupFor` cites its guidance next to the code.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/preg_band.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_partner.dart';
import 'package:parentveda/data/doors/pv_door_twins.dart';
import 'package:parentveda/screens/doors/pv_door_carousel.dart';
import 'package:parentveda/screens/doors/pv_door_chips.dart';
import 'package:parentveda/screens/doors/pv_door_rail.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart';
import 'package:parentveda/screens/doors/pv_door_tiles.dart';
import 'package:parentveda/screens/pregnancy/preg_learn_screen.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _weeks = [6, 14, 24, 34, 40];

/// The opening tab at each of [_weeks], per door. Null: no rule, first tab.
final Map<PvDoorPage, List<String>> _expected = {
  // Information before term, the timer at term (37).
  kLabourDoor: ['birth', 'birth', 'birth', 'signs', 'timer'],
  // Names, then buying (20-31), then home and help (32 on).
  kGettingReadyDoor: ['names', 'names', 'buy', 'home', 'home'],
  // An information door: the calm "By month" explanation at every week.
  kComplicationsDoor: ['when', 'when', 'when', 'when', 'when'],
  // Work, then leave and rights from 28.
  kWorkMoneyDoor: ['work', 'work', 'work', 'leave', 'leave'],
  // Carrying, then care (20-31), then the birth (32 on, NICE NG137).
  kTwinsDoor: ['carrying', 'carrying', 'care', 'birth', 'birth'],
  // His week, then labour and birth from 36.
  kPartnerDoor: ['week', 'week', 'week', 'week', 'birth'],
};

int _selected(WidgetTester t) {
  for (final f in [
    find.byType(PvDoorRail),
    find.byType(PvDoorTiles),
    find.byType(PvDoorChips),
    find.byType(PvDoorCarousel),
  ]) {
    if (f.evaluate().isEmpty) continue;
    final w = t.widget(f.first);
    return switch (w) {
      PvDoorRail(:final selected) => selected,
      PvDoorTiles(:final selected) => selected,
      PvDoorChips(:final selected) => selected,
      PvDoorCarousel(:final selected) => selected,
      _ => -1,
    };
  }
  return -1;
}

Future<PregnancyController> _at(int week) async {
  final today = DateTime.now();
  final due = DateTime(today.year, today.month, today.day)
      .add(Duration(days: (40 - week) * 7));
  final c = PregnancyController();
  await c.setDueDate(due);
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the opening tab follows her week (data)', () {
    _expected.forEach((door, tabs) {
      test(door.bracketId, () {
        final ids = {for (final g in door.groups) g.id};
        for (var i = 0; i < _weeks.length; i++) {
          final got = door.openingGroupFor!(_weeks[i]);
          expect(got, tabs[i], reason: 'week ${_weeks[i]}');
          expect(ids, contains(got), reason: 'a real tab');
        }
      });
    });

    test('every rule names its clinical source beside it', () {
      for (final f in [
        'labour',
        'getting_ready',
        'complications',
        'work_money',
        'twins',
        'partner',
      ]) {
        final s = File('lib/data/doors/pv_door_$f.dart').readAsStringSync();
        final at = s.indexOf('openingGroupFor:');
        expect(at, greaterThan(0), reason: f);
        final before = s.substring((at - 1400).clamp(0, at), at);
        expect(RegExp(r'NICE|ACOG|WHO|NHS|RCOG|Maternity Benefit').hasMatch(before),
            isTrue,
            reason: '$f: the weeks are a clinical fact; cite it');
      }
    });
  });

  group('the screen opens there', () {
    Future<void> open(WidgetTester t, PvDoorPage door, PregnancyController c,
        {String? named}) async {
      t.view.physicalSize = const Size(360, 780);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        home: PvDoorScreen(
          page: door,
          bracket: bracketById(door.bracketId)!,
          pregnancy: c,
          initialGroup: named,
        ),
      ));
      await t.pump();
    }

    for (final week in [6, 38]) {
      testWidgets('Labour at week $week', (t) async {
        final c = await _at(week);
        await open(t, kLabourDoor, c);
        final want = kLabourDoor.openingGroupFor!(c.currentWeek);
        expect(_selected(t),
            kLabourDoor.groups.indexWhere((g) => g.id == want));
      });
    }

    testWidgets('a named tab still wins', (t) async {
      final c = await _at(6);
      await open(t, kLabourDoor, c, named: 'timer');
      expect(_selected(t), 0);
    });

    testWidgets('no due date: the first tab, as before', (t) async {
      await open(t, kLabourDoor, PregnancyController());
      expect(_selected(t), 0);
    });
  });

  group('week tags added in Batch 2', () {
    PvDoorSection sec(PvDoorPage d, String h) =>
        d.sections.firstWhere((s) => s.heading == h);

    test('itching leads Skin changes in the third trimester', () {
      final order = kBellySkinDoor.sectionsFor('skin', 32);
      expect(order.first.heading, 'Itching');
      expect(sec(kBellySkinDoor, 'Itching').weeks!.from, 28);
    });

    test('leave leads from 28; telling work before', () {
      expect(kWorkMoneyDoor.sectionsFor('work', 16).first.heading,
          'Telling work, and planning your leave');
      expect(sec(kWorkMoneyDoor, 'Your maternity leave').weeks!.from, 28);
    });

    test('twins: finding out is first-trimester', () {
      expect(sec(kTwinsDoor, 'Finding out').weeks, PregBand.firstTrimester);
    });
  });

  test('Learn orders each shelf by her week, as the door does', () {
    final scans = pregLearnPiecesOf(kScansDoor, week: 34);
    final plain = pregLearnPiecesOf(kScansDoor);
    expect(scans.length, plain.length, reason: 'ranking only, nothing hidden');
    expect(File('lib/screens/pregnancy/preg_learn_screen.dart')
            .readAsStringSync(),
        contains('pregLearnTopics(week: _c.isDueDateSet ? _c.currentWeek : null)'));
  });
}
