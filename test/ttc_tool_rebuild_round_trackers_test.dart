// =============================================================================
//  The tool rebuild, 2026-09-27: the treatment round, the tracker screen
//  (What you're working on, Weight, Partner health) and the Ovulation tests
//  tool (the Tools tile "Ovulation companion")
// -----------------------------------------------------------------------------
//  Each group opens the tool the way a first-time user meets it (empty), then
//  adds, changes and removes, and holds the defects the rebuild fixed: a
//  round saved with no dates that came back as "Starting treatment?", a
//  clinic name that could only be typed once, past rounds that opened
//  nothing, one scan removable only from the end, a kind change whose Undo
//  left the path behind; a tracker that logged today only and a Clear with
//  no way back; a strip log that kept one date a cycle and never met the
//  daily log's own strips.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_screens.dart';
import 'package:parentveda/screens/ttc/ttc_ovulation_screen.dart';
import 'package:parentveda/screens/ttc/ttc_round_strings.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tracker_screen.dart';
import 'package:parentveda/screens/ttc/ttc_treatment_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';
import 'package:parentveda/ttc/ttc_trackers_data.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _plus(int n) {
  final t = _today();
  return DateTime(t.year, t.month, t.day + n);
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 360,
  double height = 5000,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull, reason: 'threw or overflowed');
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcPartnerMode.instance.on = false;
  });

  // ===========================================================================
  group('the tracker screen', () {
    testWidgets('first open: says what it is, logs today, nothing past yet', (
      tester,
    ) async {
      await _pump(tester, TtcTrackerScreen(tracker: ttcTrackerById('weight')!));
      // The eyebrow is the Tools tile's name.
      expect(find.text('WEIGHT'), findsOneWidget);
      expect(find.text(kTtcTrackerIntro), findsOneWidget);
      expect(find.textContaining('Logging for today'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_tracker_view_past')));
      await _settle(tester);
      expect(find.text(kTtcTrackerEntriesEmpty), findsOneWidget);
    });

    testWidgets('a day on the strip is the day she logs', (tester) async {
      await _pump(tester, TtcTrackerScreen(tracker: ttcTrackerById('habits')!));
      final yesterday = _plus(-1);
      await tester.tap(
        find.byKey(
          ValueKey('ttc_tracker_day_${TtcLogStore.dayKey(yesterday)}'),
        ),
      );
      await _settle(tester);
      expect(find.textContaining('Logging for yesterday'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_preset_hours_7')));
      await tester.pump();
      final log = TtcLogStore.instance;
      expect(log.valueFor('habits', 'hours', on: yesterday)?.value, 7);
      expect(
        log.valueFor('habits', 'hours'),
        isNull,
        reason: 'only today could be logged before the rebuild',
      );
      await tester.tap(find.byKey(const ValueKey('ttc_tracker_back_today')));
      await _settle(tester);
      expect(find.textContaining('Logging for today'), findsOneWidget);
    });

    testWidgets('Clear says so and Undo puts the value back', (tester) async {
      TtcLogStore.instance.log('habits', 'hours', 6.5);
      await _pump(tester, TtcTrackerScreen(tracker: ttcTrackerById('habits')!));
      await tester.tap(find.byKey(const ValueKey('ttc_tracker_clear_hours')));
      await _settle(tester);
      expect(TtcLogStore.instance.valueFor('habits', 'hours'), isNull);
      expect(find.text('Hours slept cleared.'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await _settle(tester);
      expect(TtcLogStore.instance.valueFor('habits', 'hours')?.value, 6.5);
    });

    testWidgets('typing a number saves it for the chosen day', (tester) async {
      await _pump(tester, TtcTrackerScreen(tracker: ttcTrackerById('weight')!));
      await tester.tap(find.byKey(const ValueKey('ttc_tracker_type_kg')));
      await _settle(tester);
      await tester.enterText(
        find.byKey(const ValueKey('ttc_tracker_type_field')),
        '61.5',
      );
      await tester.tap(find.byKey(const ValueKey('ttc_tracker_type_save')));
      await _settle(tester);
      expect(TtcLogStore.instance.valueFor('weight', 'kg')?.value, 61.5);
    });

    testWidgets('the past four weeks list each entry, and a tap opens it', (
      tester,
    ) async {
      final d = _plus(-3);
      TtcLogStore.instance
        ..log('weight', 'kg', 62, on: d)
        ..log('weight', 'kg', 61, on: _plus(-1));
      await _pump(tester, TtcTrackerScreen(tracker: ttcTrackerById('weight')!));
      await tester.tap(find.byKey(const ValueKey('ttc_tracker_view_past')));
      await _settle(tester);
      // Weight is a line scaled to her range, not bars from zero.
      expect(
        find.byKey(const ValueKey('ttc_tracker_weight_line')),
        findsOneWidget,
      );
      expect(find.text(kTtcTrackerEntriesTitle), findsOneWidget);
      await tester.tap(
        find.byKey(ValueKey('ttc_tracker_entry_${TtcLogStore.dayKey(d)}')),
      );
      await _settle(tester);
      expect(find.text(ttcTrackerDayLine(d, _today())), findsOneWidget);
      expect(
        find.byKey(const ValueKey('ttc_tracker_clear_kg')),
        findsOneWidget,
        reason: 'the entry opened on its own day, ready to change or clear',
      );
    });

    testWidgets('Partner health: one name, and said to him when he looks', (
      tester,
    ) async {
      expect(ttcTrackerById('partner_health')!.title(false), 'Partner health');
      await _pump(
        tester,
        TtcTrackerScreen(tracker: ttcTrackerById('partner_health')!),
      );
      expect(find.text('PARTNER HEALTH'), findsOneWidget);
      expect(find.text(kTtcTrackerPartnerWho), findsOneWidget);
      TtcPartnerMode.instance.on = true;
      await tester.pump();
      expect(find.text('YOUR HEALTH'), findsOneWidget);
      expect(find.text(kTtcTrackerPartnerWhoHim), findsOneWidget);
    });

    testWidgets('every tracker builds at 360dp, both views', (tester) async {
      for (final t in ttcTrackers) {
        await _pump(tester, TtcTrackerScreen(tracker: t));
        await tester.tap(find.byKey(const ValueKey('ttc_tracker_view_past')));
        await _settle(tester);
        expect(tester.takeException(), isNull, reason: t.id);
      }
    });
  });

  // ===========================================================================
  group('the treatment round', () {
    testWidgets('a round saved with no dates shows its plan, not "Start"', (
      tester,
    ) async {
      TtcTreatmentStore.instance.startRound(kind: TtcRoundKind.iui);
      await _pump(tester, const TtcTreatmentScreen());
      expect(
        find.byKey(const ValueKey('ttc_start_treatment_card')),
        findsNothing,
        reason: '"I\'ll add it later" came back as "Starting treatment?"',
      );
      expect(find.byKey(const ValueKey('ttc_round_header')), findsOneWidget);
      expect(find.text(kTtcPanelNoDatesTitle), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_round_timeline')), findsOneWidget);
      expect(find.text('Add date'), findsWidgets);
      // Nothing to pause on an empty round; the kind can still be fixed.
      expect(find.byKey(const ValueKey('ttc_round_pause')), findsNothing);
      expect(
        find.byKey(const ValueKey('ttc_round_change_kind')),
        findsOneWidget,
      );
    });

    testWidgets('today is said, with the next date and how far off', (
      tester,
    ) async {
      TtcTreatmentStore.instance.startRound(
        kind: TtcRoundKind.ivfFresh,
        dates: {TtcTreatmentStep.stimStart: _plus(-2)},
        scans: [_today(), _plus(2)],
      );
      await _pump(tester, const TtcTreatmentScreen());
      expect(find.text('Today: Monitoring scan.'), findsOneWidget);
      expect(find.textContaining('(in 2 days)'), findsOneWidget);
    });

    testWidgets('the clinic can be added after the start, with Undo', (
      tester,
    ) async {
      TtcTreatmentStore.instance.startRound(
        kind: TtcRoundKind.ivfFresh,
        dates: {TtcTreatmentStep.stimStart: _plus(-1)},
      );
      await _pump(tester, const TtcTreatmentScreen());
      expect(find.text('No clinic added'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_round_clinic')));
      await _settle(tester);
      await tester.enterText(
        find.byKey(const ValueKey('ttc_clinic_field')),
        'Nova Clinic',
      );
      await tester.tap(find.byKey(const ValueKey('ttc_clinic_save')));
      await _settle(tester);
      expect(TtcTreatmentStore.instance.cycle.clinic, 'Nova Clinic');
      expect(find.text('Nova Clinic'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await _settle(tester);
      expect(TtcTreatmentStore.instance.cycle.clinic, '');
    });

    testWidgets('any scan can be changed or removed, with Undo', (
      tester,
    ) async {
      final a = _plus(1), b = _plus(3), c = _plus(5);
      TtcTreatmentStore.instance.startRound(
        kind: TtcRoundKind.ivfFresh,
        dates: {TtcTreatmentStep.stimStart: _plus(-1)},
        scans: [a, b, c],
      );
      await _pump(tester, const TtcTreatmentScreen());
      expect(find.text('3 SCANS'), findsOneWidget);
      // The middle one: the old link removed only the last.
      await tester.tap(
        find.byKey(ValueKey('ttc_round_scan_${b.toIso8601String()}')),
      );
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('ttc_sheet_remove')));
      await _settle(tester);
      expect(TtcTreatmentStore.instance.cycle.scans, [a, c]);
      await tester.tap(find.text('Undo'));
      await _settle(tester);
      expect(TtcTreatmentStore.instance.cycle.scans, containsAll([a, b, c]));
    });

    testWidgets('a past round opens to look back at, and cannot be edited', (
      tester,
    ) async {
      final store = TtcTreatmentStore.instance;
      store.startRound(
        kind: TtcRoundKind.iui,
        dates: {
          TtcTreatmentStep.trigger: DateTime(
            _plus(-20).year,
            _plus(-20).month,
            _plus(-20).day,
            21,
          ),
          TtcTreatmentStep.betaTest: _plus(-6),
        },
        clinic: 'City IVF',
      );
      store.closeRound(
        TtcRoundOutcome.negative,
        now: DateTime.now().subtract(const Duration(days: 30)),
      );
      await _pump(tester, const TtcTreatmentScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_round_past_1')));
      await _settle(tester);
      expect(find.byType(TtcPastRoundScreen), findsOneWidget);
      expect(find.text('City IVF'), findsOneWidget);
      expect(find.text('Pregnancy test'), findsOneWidget);
      expect(find.text('Change date'), findsNothing);
      expect(find.text('Add date'), findsNothing);
      expect(
        find.text(kTtcRoundClinicWillTell.toUpperCase()),
        findsNothing,
        reason: 'a record shows the dates it had, not the steps it lacked',
      );
    });

    testWidgets('the wrong kind can be fixed, and Undo puts the path back', (
      tester,
    ) async {
      TtcStore.instance.setPath(TtcPath.ivf);
      TtcTreatmentStore.instance.startRound(
        kind: TtcRoundKind.ivfFresh,
        dates: {TtcTreatmentStep.stimStart: _plus(-1)},
      );
      await _pump(tester, const TtcTreatmentScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_round_plan_changed')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('ttc_sheet_kind')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('ttc_sheet_fetMedicated')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('ttc_round_confirm_yes')));
      await _settle(tester);
      expect(TtcTreatmentStore.instance.cycle.kind, TtcRoundKind.fetMedicated);
      expect(TtcStore.instance.path, TtcPath.frozenEmbryoTransfer);
      expect(
        TtcTreatmentStore.instance.cycle[TtcTreatmentStep.stimStart],
        _plus(-1),
        reason: 'every date stays',
      );
      await tester.tap(find.text('Undo'));
      await _settle(tester);
      expect(TtcTreatmentStore.instance.cycle.kind, TtcRoundKind.ivfFresh);
      expect(
        TtcStore.instance.path,
        TtcPath.ivf,
        reason: 'Undo restored the kind and left the path on the new one',
      );
    });

    testWidgets('"Remove these dates" asks first in the round\'s own dialog', (
      tester,
    ) async {
      TtcTreatmentStore.instance.startRound(
        kind: TtcRoundKind.ivfFresh,
        dates: {TtcTreatmentStep.stimStart: _plus(-1)},
      );
      await _pump(tester, const TtcTreatmentScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_round_remove')));
      await _settle(tester);
      expect(find.text(kTtcRoundRemoveBody), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_round_confirm_no')));
      await _settle(tester);
      expect(TtcTreatmentStore.instance.hasDates, isTrue);
      await tester.tap(find.byKey(const ValueKey('ttc_round_remove')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('ttc_round_confirm_yes')));
      await _settle(tester);
      expect(TtcTreatmentStore.instance.hasDates, isFalse);
    });
  });

  // ===========================================================================
  group('Ovulation tests', () {
    void cycles({int dayNow = 13}) {
      CycleStore.instance
        ..logPeriodStart(_plus(-(dayNow - 1) - 56))
        ..logPeriodStart(_plus(-(dayNow - 1) - 28))
        ..logPeriodStart(_plus(-(dayNow - 1)));
    }

    testWidgets('with no period it says what to do, and the button is there', (
      tester,
    ) async {
      await _pump(tester, const TtcOvulationScreen());
      expect(find.text(kTtcOvTitle), findsOneWidget);
      expect(find.text(kTtcOvNoPeriod), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_ov_log_period')), findsOneWidget);
    });

    testWidgets('a positive today moves her fertile days, said with Undo', (
      tester,
    ) async {
      cycles();
      await _pump(tester, const TtcOvulationScreen());
      await tester.tap(find.text(kTtcOvPositiveLabel));
      await _settle(tester);
      expect(CycleStore.instance.lhPositiveDay, 13);
      expect(
        TtcLogStore.instance
            .valueFor(kTtcSymptomTracker, kTtcOvPositive)
            ?.value,
        1,
        reason: 'the daily log\'s own key, one truth for both screens',
      );
      expect(find.text(kTtcOvMoved), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await _settle(tester);
      expect(CycleStore.instance.lhPositiveDay, isNull);
      expect(ttcOvResultOn(_today()), isNull);
    });

    testWidgets('an earlier day is logged from the strip', (tester) async {
      cycles();
      await _pump(tester, const TtcOvulationScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_ov_day_10')));
      await _settle(tester);
      await tester.tap(find.text(kTtcOvNegativeLabel));
      await tester.pump();
      expect(ttcOvResultOn(_plus(-3)), kTtcOvNegative);
      expect(CycleStore.instance.lhPositiveDay, isNull);
    });

    testWidgets('clearing the positive puts the estimate back, with a notice', (
      tester,
    ) async {
      cycles();
      ttcOvSetResult(_today(), kTtcOvPositive);
      CycleStore.instance.logLhPositive(13);
      await _pump(tester, const TtcOvulationScreen());
      await tester.tap(find.text(kTtcOvPositiveLabel));
      await _settle(tester);
      expect(ttcOvResultOn(_today()), isNull);
      expect(CycleStore.instance.lhPositiveDay, isNull);
      expect(find.text(kTtcOvBack), findsOneWidget);
    });

    testWidgets('a positive from the daily log is offered, never adopted', (
      tester,
    ) async {
      cycles();
      ttcOvSetResult(_plus(-2), kTtcOvPositive);
      await _pump(tester, const TtcOvulationScreen());
      expect(CycleStore.instance.lhPositiveDay, isNull);
      expect(find.byKey(const ValueKey('ttc_ov_adopt')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_ov_adopt_yes')));
      await tester.pump();
      expect(CycleStore.instance.lhPositiveDay, 11);
      // Launch sanity T3: day 11 against an estimate of day 14 is close, so
      // nothing extra is said.
      expect(find.byKey(const ValueKey('ttc_ov_adopt_far')), findsNothing);
    });

    // Launch sanity T3 (2026-09-28): a positive far from her pattern.
    test('a positive far from the estimate is named early or late', () {
      expect(ttcOvPositiveFar(6, 14), TtcOvFar.early);
      expect(ttcOvPositiveFar(12, 14), isNull);
      expect(ttcOvPositiveFar(16, 14), isNull);
      expect(ttcOvPositiveFar(19, 14), TtcOvFar.late);
      expect(ttcOvPositiveFar(6, null), isNull, reason: 'no estimate, no word');
    });

    testWidgets('an early positive is said before Use it, once, and Not now '
        'moves nothing', (tester) async {
      cycles(dayNow: 7);
      ttcOvSetResult(_plus(-1), kTtcOvPositive); // cycle day 6
      await _pump(tester, const TtcOvulationScreen());
      expect(find.byKey(const ValueKey('ttc_ov_adopt')), findsOneWidget,
          reason: 'the offer is drawn once');
      expect(find.byKey(const ValueKey('ttc_ov_adopt_far')), findsOneWidget);
      expect(find.textContaining("That's early for your cycle"),
          findsOneWidget);
      // It sits with the strip, above the Negative / Positive buttons.
      expect(
          tester.getTopLeft(find.byKey(const ValueKey('ttc_ov_adopt'))).dy,
          lessThan(tester.getTopLeft(find.text(kTtcOvPositiveLabel)).dy));
      await tester.tap(find.byKey(const ValueKey('ttc_ov_adopt_not_now')));
      await tester.pump();
      expect(CycleStore.instance.lhPositiveDay, isNull);
      expect(find.byKey(const ValueKey('ttc_ov_adopt')), findsNothing);
    });

    testWidgets('it says when to start testing, from her own cycle', (
      tester,
    ) async {
      cycles(dayNow: 5);
      await _pump(tester, const TtcOvulationScreen());
      // Two 28-day cycles: ovulation around day 14, so start around day 11.
      expect(ttcOvStartTestingDay(14), 11);
      expect(
        find.textContaining('Start testing around day 11'),
        findsOneWidget,
      );
    });

    testWidgets('the temperature rise is added, and removed with Undo', (
      tester,
    ) async {
      cycles();
      await _pump(tester, const TtcOvulationScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_ov_temp_add')));
      await _settle(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Today'),
        ),
      );
      await _settle(tester);
      expect(CycleStore.instance.temperatureShiftDay, 13);
      await tester.tap(find.byKey(const ValueKey('ttc_ov_temp_remove')));
      await _settle(tester);
      expect(CycleStore.instance.temperatureShiftDay, isNull);
      await tester.tap(find.text('Undo'));
      await _settle(tester);
      expect(CycleStore.instance.temperatureShiftDay, 13);
    });

    testWidgets('a fully medicated round logs nothing and says why', (
      tester,
    ) async {
      cycles();
      TtcStore.instance.setPath(TtcPath.ivf);
      TtcTreatmentStore.instance.setDate(
        TtcTreatmentStep.betaTest,
        DateTime.now().add(const Duration(days: 20)),
      );
      await _pump(tester, const TtcOvulationScreen());
      expect(find.byKey(const ValueKey('ttc_ov_medicated')), findsOneWidget);
      expect(find.text(kTtcOvTestsHeading), findsNothing);
    });
  });
}
