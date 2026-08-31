// =============================================================================
//  The symptom logger
// -----------------------------------------------------------------------------
//  ⚠️ THIS PUMPS AT 360pt, WHICH IS THE POINT. The screen holds a `Wrap` of
//  chips, a four-across bubble row, two side-by-side cards in an
//  `IntrinsicHeight`, and two charts — every one of which is a shape that
//  behaves on a wide test surface and runs out of room on a phone. A widget
//  test at 1200pt is a test of a tablet nobody has.
//
//  It also covers the layout class that took the article reader down: a `Row`
//  inside a `ListView` cannot use `CrossAxisAlignment.stretch` without being
//  given a height, and the fix here (`IntrinsicHeight`) is the legal version of
//  the same intent. Legal is not the same as working, so it is pumped.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_symptom_log_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_cycle_report.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
  });

  Future<void> pump(WidgetTester tester, {DateTime? day}) async {
    tester.view.physicalSize = const Size(360, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: TtcSymptomLogScreen(day: day)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  Future<void> scrollThrough(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull, reason: 'threw while scrolling');
    }
  }

  testWidgets('it lays out empty, all the way down', (tester) async {
    await pump(tester);
    await scrollThrough(tester);
  });

  testWidgets('and with readings, so the charts are exercised', (tester) async {
    // ⚠️ TWO SERIES OF DIFFERENT LENGTHS, ONE OF THEM FLAT. A flat series gives
    // lo == hi, which either divides by zero or pins every point to one edge —
    // "her weight did not change" has to draw as a line, not as a broken chart.
    // The short series exercises the "one reading so far" branch, which is the
    // state most users are actually in.
    final now = DateTime.now();
    for (var d = 0; d < 6; d++) {
      TtcLogStore.instance.log(kTtcWeightTracker, kTtcWeightField, 62,
          on: now.subtract(Duration(days: d)));
    }
    TtcLogStore.instance.log(kTtcTempTracker, kTtcTempField, 36.6, on: now);

    await pump(tester);
    await scrollThrough(tester);
  });

  testWidgets('the feelings row holds every mood, not four of them',
      (tester) async {
    // ⚠️ THE MERGE, ASSERTED. There used to be a four-mood "quick pick" row AND
    // a category card below carrying the same eight under a near-identical
    // heading. The row now holds all eight and the card is gone, so every mood
    // is reachable without scrolling past a control that looked like it had
    // already asked.
    await pump(tester);
    final feelings =
        kTtcSymptomGroups.firstWhere((g) => g.id == kTtcFeelingGroup);
    for (final s in feelings.symptoms) {
      expect(find.text(s.label, skipOffstage: false), findsWidgets,
          reason: '"${s.label}" is not on the screen at all');
    }
  });

  testWidgets('and feelings no longer appear twice', (tester) async {
    await pump(tester);
    final feelings =
        kTtcSymptomGroups.firstWhere((g) => g.id == kTtcFeelingGroup);
    // The group's own title is the row's heading now. If the category card came
    // back, this string would render twice.
    expect(find.text(feelings.title, skipOffstage: false), findsOneWidget);
  });

  testWidgets('a future date is clamped to today at the door', (tester) async {
    // ⚠️ THE GUARD LIVES HERE TOO, NOT ONLY ON THE HOME'S BUTTON. A guard at one
    // call site is a guard the next call site removes — and a symptom written
    // against a day nobody has lived sits in her history as a fact.
    await pump(tester, day: DateTime.now().add(const Duration(days: 5)));
    expect(find.text('Today'), findsWidgets,
        reason: 'the logger opened on a date that has not happened');
  });

  testWidgets('tapping a mood records it against the day shown',
      (tester) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await pump(tester, day: yesterday);

    await tester.tap(find.text('Calm'));
    await tester.pump(const Duration(milliseconds: 200));

    final key = TtcLogStore.dayKey(yesterday);
    expect(
        TtcLogStore.instance
            .valuesOn(kTtcSymptomTracker, key)
            .map((v) => v.field),
        contains('calm'),
        reason: 'the tap landed on a different date than the one on screen');
  });
}
