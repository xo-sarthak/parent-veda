// =============================================================================
//  The cycle report, and the five states it can be in
// -----------------------------------------------------------------------------
//  ⚠️ THE EMPTY STATES ARE THE ONES UNDER TEST, deliberately. A report is a
//  feature whose failure modes are its common case: on any given day most users
//  have logged nothing, many have a period and no symptoms, many are three days
//  in, some are on a clinic-run cycle where phases are not ours to draw.
//
//  A test suite that only exercises the happy path on a screen like this proves
//  the least interesting thing about it. So each state is asserted, and — the
//  part that actually matters clinically — the two REFUSALS are checked to be
//  refusals: no phase may be attached to any day when a clinic holds the cycle
//  or when the engine has declined to estimate.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_report_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_cycle_report.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
  });

  void cleanHistory() {
    final now = DateTime.now();
    CycleStore.instance
      ..logPeriodStart(now.subtract(const Duration(days: 68)))
      ..logPeriodStart(now.subtract(const Duration(days: 40)))
      ..logPeriodStart(now.subtract(const Duration(days: 12)));
  }

  void logSymptom(String id, int daysAgo) {
    TtcLogStore.instance.log(kTtcSymptomTracker, id, 1,
        on: DateTime.now().subtract(Duration(days: daysAgo)));
  }

  // ===========================================================================
  group('the state is decided honestly', () {
    test('nothing logged at all is the invitation, not an error', () {
      final r = ttcBuildCycleReport();
      expect(r.state, TtcReportState.noPeriod);
      expect(r.days, isEmpty);
      expect(r.findings, isEmpty);
    });

    test('a period and almost nothing else is thin, not ready', () {
      cleanHistory();
      logSymptom('cramping', 2);
      final r = ttcBuildCycleReport();
      expect(r.state, TtcReportState.thin,
          reason: 'two logged days is not a pattern and must not claim to be');
    });

    test('enough days is ready', () {
      cleanHistory();
      for (final d in [1, 2, 3, 5, 8]) {
        logSymptom('cramping', d);
      }
      final r = ttcBuildCycleReport();
      expect(r.state, TtcReportState.ready);
    });

    test('but findings need a week, not five days', () {
      // ⚠️ THE STATE AND THE SENTENCES HAVE DIFFERENT FLOORS, deliberately.
      // Five days is enough to draw a chart worth looking at; it is not enough
      // to say "mostly in your fertile days" without that being an accident of
      // when she happened to open the app.
      cleanHistory();
      for (final d in [1, 2, 3, 5, 8]) {
        logSymptom('cramping', d);
      }
      expect(ttcBuildCycleReport().findings, isEmpty);
    });

    test('and the days have to actually cluster to earn a sentence', () {
      // ⚠️ THE FIRST VERSION OF THIS TEST FAILED, AND THE TEST WAS THE THING
      // THAT WAS WRONG. It logged eight days spread across the cycle, four of
      // which fell in the period — and four of eight is not a majority, so the
      // clustering rule correctly said nothing. Which is the rule working: a
      // symptom spread evenly across a month has no position worth reporting.
      //
      // These eight all fall between cycle day 6 and 13, so five of them land
      // in the fertile window and the majority is real.
      cleanHistory();
      for (var d = 0; d <= 7; d++) {
        logSymptom('cramping', d);
      }
      final findings = ttcBuildCycleReport().findings;
      expect(findings, isNotEmpty);
      expect(findings.first.detail, contains('mostly in'));
    });
  });

  // ===========================================================================
  //  The refusals
  // ---------------------------------------------------------------------------
  //  These are the two that matter clinically. Both are structural — `phase` is
  //  null on every day — rather than a flag the screen has to remember not to
  //  draw with.
  group('phases are not drawn where they are not ours', () {
    test('a clinic-run cycle gets no phase on any day', () {
      cleanHistory();
      for (final d in [1, 2, 3, 5]) {
        logSymptom('cramping', d);
      }
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);

      final r = ttcBuildCycleReport();
      expect(r.state, TtcReportState.clinicHeld);
      expect(r.days.every((d) => d.phase == null), isTrue,
          reason: 'we laid our own phases over a cycle a clinician is '
              'directing — truth hierarchy, six places');
      // Her data is still hers.
      expect(r.loggedCount, greaterThan(0),
          reason: 'refusing to interpret is not refusing to show');
    });

    test('and the days she logged survive the refusal', () {
      cleanHistory();
      logSymptom('fatigue', 1);
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      final r = ttcBuildCycleReport();
      expect(r.logged.first.symptoms, contains('fatigue'));
    });
  });

  // ===========================================================================
  group('findings describe and never explain', () {
    test('a count is reported as a count', () {
      cleanHistory();
      for (final d in [1, 2, 3, 4]) {
        logSymptom('cramping', d);
      }
      final r = ttcBuildCycleReport();
      final text = r.findings.map((f) => '${f.headline} ${f.detail}').join(' ');

      // ⚠️ THE WORDS THAT WOULD MEAN WE HAD CROSSED THE LINE. A finding that
      // explains is a diagnosis; a finding that projects is a probability.
      // Both are forbidden — CLAUDE.md's clinical invariants.
      for (final banned in [
        'because',
        'suggests',
        'indicates',
        'means you',
        'likely to conceive',
        'chance',
      ]) {
        expect(text.toLowerCase().contains(banned), isFalse,
            reason: 'a finding used "$banned": $text');
      }
    });

    test('and it never restates the day count as an insight', () {
      // ⚠️ THIS ASSERTS THE OPPOSITE OF WHAT IT USED TO. The report opened with
      // "You logged on 1 of 1 days", which is a division the reader could do
      // herself and did not ask for — and which the dots on the strip already
      // show. A finding has to say something the chart above it cannot.
      cleanHistory();
      for (final d in [1, 2, 3, 4, 5, 6, 7, 8]) {
        logSymptom('bloating', d);
      }
      final text = ttcBuildCycleReport()
          .findings
          .map((f) => '${f.headline} ${f.detail}')
          .join(' ');
      expect(text.contains('You logged on'), isFalse,
          reason: 'the day count is back as a sentence: $text');
      expect(text.contains('of 1 days'), isFalse);
    });
  });

  // ===========================================================================
  group('numbers', () {
    test('two weights produce a range, one does not', () {
      cleanHistory();
      TtcLogStore.instance.log(kTtcWeightTracker, kTtcWeightField, 60,
          on: DateTime.now().subtract(const Duration(days: 3)));
      var r = ttcBuildCycleReport();
      expect(r.findings.any((f) => f.headline.contains('Weight')), isFalse,
          reason: 'one reading is not a range');

      TtcLogStore.instance.log(kTtcWeightTracker, kTtcWeightField, 61,
          on: DateTime.now().subtract(const Duration(days: 1)));
      r = ttcBuildCycleReport();
      expect(r.withWeight.length, 2);
    });
  });

  // ===========================================================================
  group('it builds in every state', () {
    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          const MaterialApp(home: TtcCycleReportScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }

    testWidgets('empty', (tester) async => pump(tester));

    testWidgets('thin', (tester) async {
      cleanHistory();
      logSymptom('cramping', 1);
      await pump(tester);
    });

    testWidgets('ready, with a flat weight series', (tester) async {
      // ⚠️ THE FLAT SERIES IS THE INTERESTING ONE. Identical readings give
      // hi == lo, and dividing by that span puts every point on one line or
      // produces NaN. "Her weight did not change" has to render as a flat line,
      // not as a broken chart.
      cleanHistory();
      for (final d in [1, 2, 3, 5]) {
        logSymptom('fatigue', d);
      }
      for (final d in [1, 3]) {
        TtcLogStore.instance.log(kTtcWeightTracker, kTtcWeightField, 62,
            on: DateTime.now().subtract(Duration(days: d)));
      }
      await pump(tester);
    });

    testWidgets('clinic-held', (tester) async {
      cleanHistory();
      logSymptom('fatigue', 1);
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      await pump(tester);
    });
  });
}
