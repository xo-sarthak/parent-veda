// =============================================================================
//  Cycle Companion — the four states, and the data that outlives a mis-tap
// -----------------------------------------------------------------------------
//  ⚠️ THE TESTS THAT MATTER HERE ARE THE ONES ABOUT LOSING THINGS.
//
//  Bleed length, the LH strip and the temperature shift are all keyed by the
//  period's START DATE. That makes two ordinary-looking operations dangerous:
//
//    · **Correcting a date.** Done as a remove and an add — which is what it
//      looks like from the outside — it silently drops all three, because
//      `removePeriodStart` clears them on the way out. Nudging a date by one
//      day would erase everything she recorded about that cycle, and nothing
//      would look wrong afterwards.
//    · **Undo.** Restoring only the date gives her back a row that has lost its
//      length. An undo that does not undo is worse than no undo, because she
//      stops checking.
//
//  Both are asserted below on the DETAIL, never on the date alone.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_companion.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_screens.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_cycle_report.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
  });

  DateTime ago(int days) {
    final n = DateTime.now().subtract(Duration(days: days));
    return DateTime(n.year, n.month, n.day);
  }

  /// Three clean 28-day cycles with today mid-cycle.
  void healthy() {
    CycleStore.instance
      ..logPeriodStart(ago(68))
      ..logPeriodStart(ago(40))
      ..logPeriodStart(ago(12));
  }

  // ===========================================================================
  group('bleed length is recorded, and it is not the assumption', () {
    test('nothing is stored until she says', () {
      healthy();
      expect(CycleStore.instance.bleedDaysFor(ago(12)), isNull,
          reason: 'a default would be the app answering for her');
    });

    test('a length she gives replaces the assumed five', () {
      healthy();
      expect(ttcBleedDaysFor(ago(12)), kTtcAssumedBleedDays);
      CycleStore.instance.logBleedDays(ago(12), 3);
      expect(ttcBleedDaysFor(ago(12)), 3);
    });

    test('"still on" falls back rather than growing a band', () {
      // ⚠️ A PERIOD THAT HAS NOT FINISHED HAS NO LENGTH YET. Banding it with a
      // number that climbs each morning would be the app inventing the fact it
      // is waiting for.
      healthy();
      CycleStore.instance.logBleedDays(ago(12), kBleedStillOn);
      expect(CycleStore.instance.bleedDaysFor(ago(12)), kBleedStillOn);
      expect(ttcBleedDaysFor(ago(12)), kTtcAssumedBleedDays);
    });

    test('and it moves the period band on the picture', () {
      healthy();
      CycleStore.instance.logBleedDays(ago(12), 3);
      final spans = ttcCyclePhaseSpans();
      final period = spans.firstWhere((s) => s.phase == TtcPhase.period);
      expect(period.days, 3,
          reason: 'the band still used the assumption after she answered');
    });

    test('a length for a date that is not logged is refused', () {
      // A stale screen must not be able to create a record keyed to a date the
      // list does not hold.
      CycleStore.instance.logBleedDays(ago(500), 4);
      expect(CycleStore.instance.bleedDaysFor(ago(500)), isNull);
    });
  });

  // ===========================================================================
  group('correcting a date keeps what hangs off it', () {
    test('a move carries the bleed length across', () {
      healthy();
      CycleStore.instance
        ..logBleedDays(ago(12), 4)
        ..movePeriodStart(ago(12), ago(13));

      expect(CycleStore.instance.bleedDaysFor(ago(13)), 4,
          reason: 'correcting the date by one day erased her answer');
      expect(CycleStore.instance.bleedDaysFor(ago(12)), isNull);
      expect(CycleStore.instance.periodStarts, contains(ago(13)));
      expect(CycleStore.instance.periodStarts, isNot(contains(ago(12))));
    });

    test('and a remove-then-add would not have', () {
      // ⚠️ THE COUNTER-EXAMPLE, ASSERTED. This is what the obvious
      // implementation does, and it is why `movePeriodStart` exists.
      healthy();
      CycleStore.instance
        ..logBleedDays(ago(12), 4)
        ..removePeriodStart(ago(12))
        ..logPeriodStart(ago(13));
      expect(CycleStore.instance.bleedDaysFor(ago(13)), isNull);
    });

    test('a move onto a date already logged does nothing', () {
      healthy();
      CycleStore.instance.movePeriodStart(ago(12), ago(40));
      expect(CycleStore.instance.periodStarts.length, 3,
          reason: 'two periods collapsed into one');
    });
  });

  // ===========================================================================
  group('undo puts the whole row back', () {
    test('the date and its length both return', () {
      healthy();
      CycleStore.instance.logBleedDays(ago(12), 6);
      final kept = CycleStore.instance.detailsFor(ago(12));
      expect(kept.bleed, 6);

      CycleStore.instance.removePeriodStart(ago(12));
      expect(CycleStore.instance.periodStarts, isNot(contains(ago(12))));

      CycleStore.instance.restorePeriodStart(ago(12),
          bleed: kept.bleed, lh: kept.lh, temp: kept.temp);
      expect(CycleStore.instance.periodStarts, contains(ago(12)));
      expect(CycleStore.instance.bleedDaysFor(ago(12)), 6,
          reason: 'an undo that loses her answer is not an undo');
    });

    test('restoring a date that is already there does not duplicate it', () {
      healthy();
      CycleStore.instance.restorePeriodStart(ago(12));
      expect(
          CycleStore.instance.periodStarts.where((d) => d == ago(12)).length, 1);
    });
  });

  // ===========================================================================
  group('the four states render at phone width', () {
    Future<void> pump(WidgetTester tester) async {
      // ⚠️ 360, THE NARROWEST REAL PHONE.
      tester.view.physicalSize = const Size(360, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TtcCycleScreen()));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    }

    testWidgets('empty invites one date, and says what it buys',
        (tester) async {
      await pump(tester);
      expect(find.text('Add a period date'), findsOneWidget);
      expect(find.textContaining('Your cycle day, every day'), findsOneWidget,
          reason: 'the empty state did not say what the first date is worth');
    });

    testWidgets('healthy draws the cycle and links the report', (tester) async {
      healthy();
      await pump(tester);
      expect(find.text('This cycle'), findsOneWidget);
      // One name for the report, 2026-09-27 (tools pass). Was:
      //   expect(find.text('See this month in full'), findsOneWidget,
      expect(find.text('See your cycle report'), findsOneWidget,
          reason: 'the report was unreachable from here, which is the gap this '
              'rebuild existed to close');
      // All four stretches, named.
      for (final phase in TtcPhase.values) {
        expect(find.text(phase.label), findsWidgets);
      }
    });

    testWidgets('the picture can be switched to days', (tester) async {
      healthy();
      await pump(tester);
      // "Calendar" since 2026-09-27, the report's word. Was:
      //   await tester.tap(find.text('Days'));
      await tester.tap(find.text('Calendar'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('when the next period is expected'),
          findsOneWidget);
    });

    testWidgets('a clinic-run cycle refuses, and says who is guiding',
        (tester) async {
      healthy();
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      await pump(tester);

      expect(find.text('Your clinic is tracking this cycle'), findsOneWidget);
      // ⚠️ THE REFUSAL IS STRUCTURAL. No picture, no stretches — not a hidden
      // widget somewhere off screen.
      expect(find.text('This cycle'), findsNothing);
      // Her own dates survive the refusal.
      expect(find.text('Your dates'.toUpperCase()), findsOneWidget);
    });

    testWidgets('and her rhythm survives a refusal', (tester) async {
      // The numbers describe her history, not this cycle, so a refusal to draw
      // this cycle is no reason to withhold them.
      healthy();
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      await pump(tester);
      expect(find.text('Your rhythm'.toUpperCase()), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the log sheet', () {
    testWidgets('offers a length and a "still on"', (tester) async {
      tester.view.physicalSize = const Size(360, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TtcCycleScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Add a period date'));
      await tester.pumpAndSettle();

      expect(find.text('When did your period start?' /* was 'When did it start?' */), findsOneWidget);
      // ⚠️ THE DEFINITION IS ON THE SCREEN THAT ASKS. Every derived number in
      // this stage hangs off her reading day 1 the same way we do.
      expect(find.text('The first day of real bleeding, not spotting.'),
          findsOneWidget);
      expect(find.text('Still on'), findsOneWidget);
      for (final n in kTtcBleedChoices) {
        expect(find.text(n == kTtcBleedChoices.last ? '$n+' : '$n'),
            findsWidgets);
      }
    });
  });
}
