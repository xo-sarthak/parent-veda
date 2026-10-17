// =============================================================================
//  The cycle hub, the positive-test rule and spotting (2026-10-17)
// -----------------------------------------------------------------------------
//  The user lost a cycle's fertile days to an ovulation test logged on day 2
//  that no cycle screen mentioned, found the test screen two taps deep, and
//  called the cycle screens "bland" and scattered next to Clue's and Flo's.
//  These hold the answers:
//    * a positive moves the window from any door, and says so;
//    * a positive before day 7 is saved but waits for "Use it";
//    * every cycle screen names where the fertile days come from;
//    * spotting is its own answer and never starts a cycle;
//    * the hub draws at phone width, with reduced motion too.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_companion.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_hub.dart';
import 'package:parentveda/screens/ttc/ttc_ovulation_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart' show kTtcSymptomTracker;
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    TtcPartnerMode.instance.on = false;
  });
  tearDown(() => TtcPartnerMode.instance.on = false);

  DateTime ago(int days) {
    final n = DateTime.now().subtract(Duration(days: days));
    return DateTime(n.year, n.month, n.day);
  }

  /// A 28-day history; today is cycle day [day] of the current cycle.
  void history({int day = 12}) {
    CycleStore.instance
      ..logPeriodStart(ago(day - 1 + 56))
      ..logPeriodStart(ago(day - 1 + 28))
      ..logPeriodStart(ago(day - 1));
  }

  Future<BuildContext> pumpContext(WidgetTester t) async {
    late BuildContext ctx;
    await t.pumpWidget(MaterialApp(
        home: Scaffold(body: Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    }))));
    return ctx;
  }

  Future<void> pumpTall(WidgetTester t, Widget home,
      {bool reduceMotion = false}) async {
    t.view.physicalSize = const Size(360, 5200);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      key: UniqueKey(),
      home: MediaQuery(
        data: MediaQueryData(
            size: const Size(360, 5200), disableAnimations: reduceMotion),
        child: home,
      ),
    ));
    await t.pump(const Duration(milliseconds: 900));
    expect(t.takeException(), isNull);
  }

  // ===========================================================================
  group('a positive test, from any door', () {
    testWidgets('from day 7 on it moves the window at once', (t) async {
      history(day: 12);
      final ctx = await pumpContext(t);
      ttcOvSetResult(ago(0), kTtcOvPositive);
      ttcOvPositiveSaved(ctx, ago(0));
      await t.pump();
      expect(CycleStore.instance.lhPositiveDay, 12);
      expect(find.text(kTtcOvMoved), findsOneWidget,
          reason: 'it says the window moved, with Undo');
      expect(ttcWindowSourceLine()!.fromTest, isTrue);
    });

    testWidgets('before day 7 it is saved but does not move the window',
        (t) async {
      history(day: 3);
      final ctx = await pumpContext(t);
      ttcOvSetResult(ago(0), kTtcOvPositive);
      ttcOvPositiveSaved(ctx, ago(0));
      await t.pump();
      expect(CycleStore.instance.lhPositiveDay, isNull,
          reason: 'a day-3 positive waits for "Use it"');
      expect(ttcOvResultOn(ago(0)), kTtcOvPositive,
          reason: 'the strip itself is kept');
      expect(find.text(ttcOvEarlyKeptLine(3)), findsOneWidget);
      await t.tap(find.text('Use this test'));
      await t.pump();
      expect(CycleStore.instance.lhPositiveDay, 3,
          reason: 'her confirmed strip outranks our estimate');
    });

    testWidgets('taking it off sends the window back', (t) async {
      history(day: 12);
      final ctx = await pumpContext(t);
      ttcOvSetResult(ago(0), kTtcOvPositive);
      ttcOvPositiveSaved(ctx, ago(0));
      ttcOvSetResult(ago(0), null);
      ttcOvPositiveCleared(ctx, ago(0));
      await t.pump();
      expect(CycleStore.instance.lhPositiveDay, isNull);
      expect(ttcWindowSourceLine()!.fromTest, isFalse);
    });

    // The device walk (2026-10-17): a cleared test came back after a
    // reinstall, because the union pull put the cloud's copy back. Clearing
    // deletes the cloud row and leaves a tombstone the pull respects.
    test('a cleared test stays cleared across a sync', () {
      final src = File('lib/ttc/cycle_store.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(src, contains("_clearSignal(s, 'lh')"));
      expect(src, contains("_clearSignal(s, 'temperature')"));
      expect(src, contains('SupabaseRepo.delete(TtcTables.signals'));
      expect(src, contains("if (_clearedSignals.contains('\$kind|"));
    });

    test('the daily logger calls the same rule', () {
      final src = File('lib/screens/ttc/ttc_symptom_log_screen.dart')
          .readAsStringSync();
      expect(src, contains('ttcOvPositiveSaved(context, _day'));
      expect(src, contains('ttcOvPositiveCleared(context, _day'));
    });
  });

  // ===========================================================================
  group('every cycle screen says where the window comes from', () {
    testWidgets('the hub, from the period dates', (t) async {
      history();
      await pumpTall(t, const TtcCycleCompanionScreen());
      expect(find.byKey(const ValueKey('ttc_hub_source')), findsOneWidget);
      expect(find.textContaining('Estimated from your period dates'),
          findsOneWidget);
    });

    testWidgets('the hub, from a test, with a way to change it', (t) async {
      history(day: 12);
      CycleStore.instance.logLhPositive(11);
      await pumpTall(t, const TtcCycleCompanionScreen());
      expect(find.textContaining('Based on your positive ovulation test'),
          findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_hub_source_change')),
          findsOneWidget);
    });

    // The device walk (2026-10-17): clearing a test moved the month while
    // the card (a const widget) kept naming the old test.
    testWidgets('clearing the test updates the line at once', (t) async {
      history(day: 12);
      CycleStore.instance.logLhPositive(11);
      await pumpTall(t, const TtcCycleCompanionScreen());
      expect(find.textContaining('Based on your positive ovulation test'),
          findsOneWidget);
      CycleStore.instance.logLhPositive(null);
      await t.pump(const Duration(milliseconds: 900));
      expect(find.textContaining('Based on your positive ovulation test'),
          findsNothing);
      expect(find.textContaining('Estimated from your period dates'),
          findsOneWidget);
    });

    testWidgets('his side names her test and offers no change', (t) async {
      history(day: 12);
      CycleStore.instance.logLhPositive(11);
      TtcPartnerMode.instance.on = true;
      await pumpTall(t, const TtcCycleCompanionScreen());
      expect(find.byKey(const ValueKey('ttc_hub_source_change')), findsNothing);
      expect(find.byKey(const ValueKey('ttc_hub_log')), findsNothing);
    });
  });

  // ===========================================================================
  group('spotting', () {
    testWidgets('"It was spotting" saves no period', (t) async {
      history(day: 12);
      final before = CycleStore.instance.periodStarts.length;
      final ctx = await pumpContext(t);
      showTtcPeriodLogSheet(ctx, initial: ago(2));
      await t.pumpAndSettle();
      final spot = find.byKey(const ValueKey('ttc_period_was_spotting'));
      await t.ensureVisible(spot);
      await t.tap(spot);
      await t.pumpAndSettle();
      expect(CycleStore.instance.periodStarts.length, before,
          reason: 'spotting never starts a cycle');
      expect(ttcSpottingOn(ago(2)), isTrue);
      expect(find.text(ttcSpottingSavedLine(ago(2))), findsOneWidget);
    });

    // The device walk (2026-10-17): every day of the month was drawn teal,
    // because every day carries a grade and "low" counted as fertile.
    test('only the window is fertile in the hub', () {
      history(day: 12); // 28-day cycle: fertile days are days 9 to 14
      expect(ttcHubDay(ago(0)).fertile, isTrue, reason: 'day 12');
      expect(ttcHubDay(ago(10)).fertile, isFalse, reason: 'day 2');
      expect(ttcHubDay(ago(5)).fertile, isFalse, reason: 'day 7');
    });

    test("the month shows the next cycle's fertile days too", () {
      history(day: 12); // 28 days: next period in 17 days
      final w = ttcHubNextWindow()!;
      expect(ttcHubDay(w.opens).fertile, isTrue);
      expect(ttcHubDay(w.ov).ovulation, isTrue);
      expect(w.ov.difference(w.opens).inDays, 5);
    });

    test('the hub marks a spotting day', () {
      history(day: 12);
      ttcLogSpotting(ago(3));
      expect(ttcHubDay(ago(3)).spotting, isTrue);
      expect(ttcHubDay(ago(4)).spotting, isFalse);
      expect(
          TtcLogStore.instance
              .valueFor(kTtcSymptomTracker, kTtcSpottingId, on: ago(3)),
          isNotNull,
          reason: 'one fact: the Discharge chip writes the same key');
    });
  });

  // ===========================================================================
  group('the hub draws', () {
    testWidgets('at 360dp, every block', (t) async {
      history();
      await pumpTall(t, const TtcCycleCompanionScreen());
      for (final k in [
        'ttc_hub_week',
        'ttc_hub_ring',
        'ttc_hub_headline',
        'ttc_hub_predictions',
        'ttc_hub_month_pages',
        'ttc_hub_tracked',
        'ttc_hub_row_tests',
        'ttc_hub_row_history',
        'ttc_hub_row_report',
      ]) {
        expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
      }
    });

    testWidgets('with reduced motion, the ring is simply there', (t) async {
      history();
      await pumpTall(t, const TtcCycleCompanionScreen(), reduceMotion: true);
      expect(find.byKey(const ValueKey('ttc_hub_ring')), findsOneWidget);
    });

    test('the headline never says late or a chance', () {
      for (final day in [2, 9, 14, 20, 27, 31, 36]) {
        CycleStore.instance.resetForTest();
        TtcStore.instance.resetForTest();
        history(day: day);
        final h = ttcHubHeadline();
        if (h == null) continue;
        final all = '${h.big} ${h.part}'.toLowerCase();
        expect(all, isNot(contains('late')), reason: 'day $day: $all');
        expect(all, isNot(contains('chance')), reason: 'day $day: $all');
      }
    });

    testWidgets('picking a day in the month moves the tracked card',
        (t) async {
      history();
      await pumpTall(t, const TtcCycleCompanionScreen());
      final cell =
          find.byKey(ValueKey('ttc_hub_day_${TtcLogStore.dayKey(ago(2))}'));
      await t.ensureVisible(cell.first);
      await t.tap(cell.first);
      await t.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('Tracked on ${ago(2).day} '), findsOneWidget);
    });
  });
}
