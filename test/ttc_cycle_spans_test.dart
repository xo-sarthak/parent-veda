// =============================================================================
//  The four stretches of a cycle, and the one thing that kept being confused
// -----------------------------------------------------------------------------
//  ⚠️ THE TEST THIS FILE EXISTS FOR IS `covers days that have not happened yet`.
//
//  `TtcCycleReport.days` stops at today, correctly — it is what she LOGGED, and
//  nobody has stood on a scale tomorrow. That clamp was then read as a limit on
//  the whole screen, and the conclusion drawn was that the last stretch of a
//  cycle could not be drawn because it was in the future.
//
//  It is not. The four stretches are arithmetic on two numbers the engine has
//  the moment a period is logged — the estimated ovulation day and the cycle
//  length — and today's date does exactly one job: it decides which stretch
//  carries "You are here". A test that only ever ran on a cycle already over
//  would not have caught the confusion, so the fixtures here deliberately put
//  today in the middle of a cycle and assert about the part that is ahead.
//
//  ⚠️ AND THE REFUSALS ARE ASSERTED AS EMPTINESS, not as a flag. A caller
//  cannot draw bands over a clinic-run cycle because there is nothing to draw.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_report_screen.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_report_v3.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_cycle_report.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
  });

  /// Three clean 28-day cycles, with today sitting on day 13 of the current
  /// one — mid-cycle on purpose, so there is both a past and a future to check.
  void midCycle() {
    final now = DateTime.now();
    CycleStore.instance
      ..logPeriodStart(now.subtract(const Duration(days: 68)))
      ..logPeriodStart(now.subtract(const Duration(days: 40)))
      ..logPeriodStart(now.subtract(const Duration(days: 12)));
  }

  // ===========================================================================
  group('the shape of a whole cycle', () {
    test('covers days that have not happened yet', () {
      midCycle();
      final spans = ttcCyclePhaseSpans();
      expect(spans, isNotEmpty);

      final today = DateTime.now();
      expect(spans.last.lastDay.isAfter(today), isTrue,
          reason: 'the cycle stopped at today — the stretches are the SHAPE of '
              'the cycle, not the list of days she logged');
      expect(spans.any((s) => s.status == TtcSpanStatus.ahead), isTrue,
          reason: 'nothing was left ahead of her, so the last stop would draw '
              'as blank');
    });

    test('the stretches are contiguous and start at day one', () {
      midCycle();
      final spans = ttcCyclePhaseSpans();

      expect(spans.first.firstCycleDay, 1);
      for (var i = 1; i < spans.length; i++) {
        expect(spans[i].firstCycleDay, spans[i - 1].lastCycleDay + 1,
            reason: 'a gap or an overlap between stretch ${i - 1} and $i — the '
                'ring would show bare track, the calendar an uncoloured day');
      }
    });

    test('lengths add up to the cycle, and each one is real', () {
      midCycle();
      final spans = ttcCyclePhaseSpans();
      final total = spans.fold<int>(0, (sum, s) => sum + s.days);
      expect(total, spans.last.lastCycleDay);
      for (final s in spans) {
        expect(s.days, greaterThan(0),
            reason: 'a zero-day stretch was invented to keep the count at four');
      }
    });

    test('the period is first and the waiting days are last', () {
      midCycle();
      final spans = ttcCyclePhaseSpans();
      expect(spans.first.phase, TtcPhase.period);
      expect(spans.last.phase, TtcPhase.afterWindow);
    });

    test('a phase never appears twice', () {
      // Two stretches of one colour on a ring reads as a drawing error, and on
      // the timeline it would number the same stretch twice.
      midCycle();
      final phases = ttcCyclePhaseSpans().map((s) => s.phase).toList();
      expect(phases.toSet().length, phases.length);
    });
  });

  // ===========================================================================
  group('where she is now', () {
    test('exactly one stretch is the current one', () {
      midCycle();
      final spans = ttcCyclePhaseSpans();
      expect(spans.where((s) => s.status == TtcSpanStatus.here).length, 1);
    });

    test('the position inside it is only set on that one', () {
      midCycle();
      for (final s in ttcCyclePhaseSpans()) {
        if (s.status == TtcSpanStatus.here) {
          expect(s.dayInto, isNotNull);
          expect(s.dayInto, inInclusiveRange(1, s.days));
        } else {
          expect(s.dayInto, isNull,
              reason: '"day 3 of 7" on a stretch she is not in is a sentence '
                  'about nothing');
        }
      }
    });

    test('everything before it is done and everything after is ahead', () {
      midCycle();
      final spans = ttcCyclePhaseSpans();
      final at = spans.indexWhere((s) => s.status == TtcSpanStatus.here);
      for (var i = 0; i < spans.length; i++) {
        if (i < at) expect(spans[i].status, TtcSpanStatus.done);
        if (i > at) expect(spans[i].status, TtcSpanStatus.ahead);
      }
    });

    test('a cycle she has paged back to has no current stretch', () {
      midCycle();
      final spans = ttcCyclePhaseSpans(index: 1);
      expect(spans, isNotEmpty);
      expect(spans.every((s) => s.status == TtcSpanStatus.done), isTrue,
          reason: 'a finished cycle claimed she was standing in it');
    });
  });

  // ===========================================================================
  group('the refusals are emptiness, not a flag', () {
    test('no period logged draws nothing', () {
      expect(ttcCyclePhaseSpans(), isEmpty);
    });

    test('a clinic-run cycle draws nothing', () {
      midCycle();
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      expect(ttcCyclePhaseSpans(), isEmpty,
          reason: 'we laid our own stretches over a cycle a clinician is '
              'directing — truth hierarchy, six places');
    });
  });

  // ===========================================================================
  group('the report draws the cycle whenever it can', () {
    // ⚠️ THIS GROUP EXISTS BECAUSE OF A BUG WITH ALMOST NO SYMPTOM. The report
    // gated its new body on `state == ready`, and `ready` degrades to `thin`
    // the moment fewer than three days in the cycle have anything logged — a
    // symptom, a weight, a temperature. That is most people most months, so
    // almost nobody ever saw the redesign, and the only evidence was someone
    // saying "why do I see the old design".
    //
    // The lesson generalises past this screen: "have we enough to SAY
    // something" and "have we enough to DRAW something" are different
    // questions, and a single state enum answering both will silently answer
    // one of them wrong.
    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TtcCycleReportScreen()));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    }

    testWidgets('a cycle with nothing logged still gets the picture',
        (tester) async {
      midCycle();
      // Not one symptom, not one weight. `ttcBuildCycleReport` calls this thin.
      expect(ttcBuildCycleReport().state, TtcReportState.thin,
          reason: 'the fixture no longer reproduces the case that was broken');

      await pump(tester);
      expect(find.text('Dial'), findsOneWidget,
          reason: 'the old report rendered — the picture was withheld because '
              'there were no FINDINGS, which is a different question');
      expect(find.text('The four stretches, in order'), findsOneWidget);
    });

    testWidgets('and it says so instead of leaving the section blank',
        (tester) async {
      midCycle();
      await pump(tester);
      // A section that simply vanishes on a screen which has just drawn a full
      // cycle reads as something failing to load.
      expect(find.text(const TtcS(false).reportThinTitle), findsOneWidget);
    });

    testWidgets('no heading is printed twice', (tester) async {
      // ⚠️ THE CASE THAT SHIPPED IT: numbers absent, symptoms present. The
      // temperature-and-weight section borrowed "What you logged", which is the
      // findings section's own heading, so the same words appeared twice a few
      // inches apart over two different things.
      //
      // Asserted across every heading rather than that one, because the shape
      // of the mistake — a section reaching for a neighbour's title when it has
      // nothing of its own — is not specific to it.
      midCycle();
      for (final d in [1, 2, 3, 4, 5, 6, 7, 8]) {
        TtcLogStore.instance.log(kTtcSymptomTracker, 'cramping', 1,
            on: DateTime.now().subtract(Duration(days: d)));
      }
      await pump(tester);

      const t = TtcS(false);
      for (final heading in [
        t.reportWhatYouLogged,
        t.reportChanges,
        t.reportThisCycle,
        'The four stretches, in order',
      ]) {
        expect(find.text(heading).evaluate().length, lessThanOrEqualTo(1),
            reason: '"$heading" is on the report more than once');
      }
    });

    testWidgets('a clinic-run cycle refuses, and says who is guiding',
        (tester) async {
      midCycle();
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      await pump(tester);

      expect(find.text('Dial'), findsNothing,
          reason: 'phases were drawn over a cycle a clinician is directing');
      expect(find.text('Your doctor is timing this one'), findsOneWidget);
      // ⚠️ HER DAYS AND HER HISTORY BOTH SURVIVE THE REFUSAL. Refusing to
      // interpret is not refusing to show.
      expect(find.text('The days you logged'), findsOneWidget);
      expect(find.text('Your rhythm so far'), findsOneWidget);
    });

    testWidgets('nothing logged teaches instead of apologising',
        (tester) async {
      await pump(tester);
      expect(find.text('A picture of one month'), findsOneWidget);
      expect(find.text('Today gets a name'), findsOneWidget,
          reason: 'the empty state did not say what the first date buys');
      // The picker stays, dimmed, so the header does not change shape.
      expect(find.text('No cycles yet'), findsOneWidget);
    });

    testWidgets('and the two refusals do not share a reason', (tester) async {
      // ⚠️ THE ONE THING THAT MUST NOT BE FLATTENED. Both withhold the phases;
      // one is "we cannot say" about her data and the other is "it is not ours
      // to say" about her clinic. Getting them the wrong way round blames a
      // woman's logging for her clinic's involvement.
      midCycle();
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      await pump(tester);
      expect(find.text("We'd rather not guess"), findsNothing);
      expect(find.textContaining('unlogged'), findsNothing,
          reason: 'the clinic state explained itself as a data problem');
    });
  });

  // ===========================================================================
  group('the pictures render at phone width', () {
    // ⚠️ 360, NOT 1200. Every overflow this stage has shipped was found at
    // phone width or not at all.
    Future<void> pump(WidgetTester tester, Widget child) async {
      tester.view.physicalSize = const Size(360, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: child))));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }

    testWidgets('the dial', (tester) async {
      midCycle();
      await pump(
          tester,
          TtcCycleRing(spans: ttcCyclePhaseSpans(), today: DateTime.now()));
    });

    testWidgets('the calendar', (tester) async {
      midCycle();
      await pump(
          tester,
          TtcCycleGrid(
            spans: ttcCyclePhaseSpans(),
            report: ttcBuildCycleReport(),
            today: DateTime.now(),
          ));
    });

    testWidgets('the four stops, with one of them breathing', (tester) async {
      midCycle();
      await pump(tester, TtcCycleTimeline(spans: ttcCyclePhaseSpans()));
      // The pulse is an endless animation; the test binding will complain at
      // teardown if it is still running, which is the point of stopping it on
      // dispose rather than letting the controller outlive the widget.
      expect(find.textContaining('YOU ARE HERE'), findsOneWidget);
    });

    testWidgets('today is marked NOW on the calendar', (tester) async {
      // ⚠️ THE SAME MARK ON BOTH GRIDS. The report draws the cycle in cycle-day
      // order and the Companion draws it in calendar weeks; they are two
      // pictures of one month, and today looked different on each — one filled
      // and ringed, the other merely outlined. `ttcTodayRings` is the single
      // definition now, and the word is what says WHY the cell is different.
      midCycle();
      await pump(
          tester,
          TtcCycleGrid(
            spans: ttcCyclePhaseSpans(),
            report: ttcBuildCycleReport(),
            today: DateTime.now(),
          ));
      expect(find.text(kTtcNowLabel), findsOneWidget,
          reason: 'today carries no label, so a reader has to guess which of '
              'the coloured squares is the one they are standing on');
    });

    testWidgets('every stretch is named in words, not only in colour',
        (tester) async {
      // ⚠️ THE LEGEND IS NOT THE EXPLANATION. Four colours with four labels
      // tells her which is which; only the timeline says what any of them IS.
      midCycle();
      final spans = ttcCyclePhaseSpans();
      await pump(tester, TtcCycleTimeline(spans: spans));
      for (final s in spans) {
        expect(find.textContaining(s.phase.label), findsWidgets,
            reason: '${s.phase.label} was drawn but never named');
      }
    });
  });
}
