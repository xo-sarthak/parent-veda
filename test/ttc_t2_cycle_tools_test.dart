// =============================================================================
//  T2: the TTC cycle tools (docs/preg-ttc-tool-plans/T2-cycle-tools.md)
// -----------------------------------------------------------------------------
//  One group per finding the build fixed. Each pins the behaviour, not the
//  pixels: a move onto a logged day changes nothing until she merges, no
//  "next period" on a clinic cycle or a poisoned history, the window states
//  its basis, "Should I test?" after a loss and on his phone, the report chat
//  and the report on one cycle, and nothing hidden after a loss.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/chats/ttc_cycle_report_chat.dart';
import 'package:parentveda/screens/ttc/chats/ttc_should_test_chat.dart';
import 'package:parentveda/screens/ttc/doors/ttc_kind_cards.dart'
    show ttcToolVerb;
import 'package:parentveda/screens/ttc/ttc_askveda_screen.dart'
    show ttcAskVedaWindowSource;
import 'package:parentveda/screens/ttc/ttc_calendar_screen.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_companion.dart';
import 'package:parentveda/screens/ttc/ttc_ovulation_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_window_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_cycle_report.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    PregnancyEndedStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcPartnerMode.instance.on = false;
    TtcLang.instance.hinglish = false;
  });
  tearDown(() => TtcPartnerMode.instance.on = false);

  DateTime ago(int days) {
    final n = DateTime.now().subtract(Duration(days: days));
    return DateTime(n.year, n.month, n.day);
  }

  final today = ago(0);

  /// Three clean 28-day cycles; today is cycle day 12.
  void clean() => CycleStore.instance
    ..logPeriodStart(ago(95))
    ..logPeriodStart(ago(67))
    ..logPeriodStart(ago(39))
    ..logPeriodStart(ago(11));

  /// A clinic owns this cycle: a stimulation date in the round.
  void clinic() {
    CycleStore.instance
      ..logPeriodStart(ago(68))
      ..logPeriodStart(ago(40))
      ..logPeriodStart(ago(12));
    TtcStore.instance.setPath(TtcPath.ivf);
    TtcTreatmentStore.instance
        .setDate(TtcTreatmentStep.stimStart, ago(11));
  }

  /// A history the engine reads as a missed log: a 54-day gap among 28s.
  void poisoned() => CycleStore.instance
    ..logPeriodStart(ago(120))
    ..logPeriodStart(ago(92))
    ..logPeriodStart(ago(38))
    ..logPeriodStart(ago(10));

  /// A loss recorded today, back in trying, with periods from before it.
  Future<void> afterLoss() async {
    CycleStore.instance
      ..logPeriodStart(ago(90))
      ..logPeriodStart(ago(62));
    LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
    await PregnancyEndedStore.instance.markEnded();
  }

  Future<void> pumpTall(WidgetTester t, Widget home) async {
    t.view.physicalSize = const Size(400, 6000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(key: UniqueKey(), home: home));
    await t.pump(const Duration(milliseconds: 400));
  }

  // ===========================================================================
  group('B1: a move onto a logged day', () {
    test('changes neither period, and says it did not', () {
      CycleStore.instance
        ..logPeriodStart(ago(40))
        ..logPeriodStart(ago(12))
        ..logBleedDays(ago(40), 4)
        ..logBleedDays(ago(12), 6);
      expect(CycleStore.instance.movePeriodStart(ago(12), ago(40)), isFalse);
      expect(CycleStore.instance.periodStarts, [ago(40), ago(12)]);
      expect(CycleStore.instance.bleedDaysFor(ago(40)), 4);
      expect(CycleStore.instance.bleedDaysFor(ago(12)), 6);
    });

    test('a move to a free day reports it moved', () {
      CycleStore.instance.logPeriodStart(ago(12));
      expect(CycleStore.instance.movePeriodStart(ago(12), ago(13)), isTrue);
      expect(CycleStore.instance.periodStarts, [ago(13)]);
    });

    test('merge: the target wins, and only what it lacked moves across', () {
      CycleStore.instance
        ..logPeriodStart(ago(40))
        ..logPeriodStart(ago(12))
        ..logBleedDays(ago(12), 6);
      expect(CycleStore.instance.mergePeriodStart(ago(12), ago(40)), isTrue);
      expect(CycleStore.instance.periodStarts, [ago(40)]);
      expect(CycleStore.instance.bleedDaysFor(ago(40)), 6,
          reason: 'the target had no bleed length, so the merged one keeps it');

      CycleStore.instance
        ..logPeriodStart(ago(12))
        ..logBleedDays(ago(12), 3)
        ..logBleedDays(ago(40), 5);
      CycleStore.instance.mergePeriodStart(ago(12), ago(40));
      expect(CycleStore.instance.bleedDaysFor(ago(40)), 5,
          reason: 'what the target already carried stays');
    });

    test('merge refuses unless both days hold a period', () {
      CycleStore.instance.logPeriodStart(ago(12));
      expect(CycleStore.instance.mergePeriodStart(ago(12), ago(40)), isFalse);
      expect(CycleStore.instance.periodStarts, [ago(12)]);
    });
  });

  // ===========================================================================
  group('W1/W2: no next period where we may not predict one', () {
    testWidgets('healthy: Period history names the next period',
        (tester) async {
      clean();
      await pumpTall(tester, const TtcPeriodHistoryScreen());
      expect(find.text('NEXT PERIOD EXPECTED'), findsOneWidget);
    });

    testWidgets('clinic cycle: the lengths stay, the prediction goes',
        (tester) async {
      clinic();
      expect(TtcStore.instance.behaviour.countsToPeriod, isFalse);
      await pumpTall(tester, const TtcPeriodHistoryScreen());
      expect(find.text('NEXT PERIOD EXPECTED'), findsNothing);
      expect(find.text('YOUR RHYTHM'), findsOneWidget);
    });

    testWidgets('a history that looks like a missed log: neither',
        (tester) async {
      poisoned();
      await pumpTall(tester, const TtcPeriodHistoryScreen());
      expect(find.text('NEXT PERIOD EXPECTED'), findsNothing);
      expect(find.text('YOUR RHYTHM'), findsNothing);
    });
  });

  // ===========================================================================
  group('W11: the length note reads the engine', () {
    test('a clean history gets a note', () {
      clean();
      expect(ttcCycleLengthNote(), isNotNull);
    });

    test('a poisoned history gets none', () {
      CycleStore.instance
        ..logPeriodStart(ago(170))
        ..logPeriodStart(ago(142))
        ..logPeriodStart(ago(114))
        ..logPeriodStart(ago(60))
        ..logPeriodStart(ago(32))
        ..logPeriodStart(ago(4));
      expect(ttcCycleLengthNote(), isNull);
    });
  });

  // ===========================================================================
  group('W3/W4/K6/K8: the live fertile window', () {
    testWidgets('clinic cycle: no cycle-day line, no "coloured below"',
        (tester) async {
      clinic();
      await pumpTall(tester, const TtcWindowScreen());
      expect(tester.takeException(), isNull);
      expect(find.textContaining('coloured below'), findsNothing);
      expect(find.textContaining('of your cycle ·'), findsNothing);
      expect(find.byKey(const ValueKey('ttc_window_today_line')), findsNothing);
    });

    testWidgets('a first cycle states its basis', (tester) async {
      CycleStore.instance.logPeriodStart(ago(4));
      expect(ttcWindowBasisLine(),
          'A first estimate from a 28-day cycle. It sharpens after your '
          'next period.');
      await pumpTall(tester, const TtcWindowScreen());
      expect(find.byKey(const ValueKey('ttc_window_basis_line')),
          findsOneWidget);
    });

    test('a stated length is named as hers', () {
      TtcStore.instance.setStatedCycleLength(32);
      CycleStore.instance.logPeriodStart(ago(4));
      expect(ttcWindowBasisLine(), contains('the length you told us'));
    });

    test('irregular cycles say the days are a wide guess', () {
      CycleStore.instance
        ..logPeriodStart(ago(110))
        ..logPeriodStart(ago(88))
        ..logPeriodStart(ago(52))
        ..logPeriodStart(ago(28))
        ..logPeriodStart(ago(3));
      expect(ttcWindowBasisLine(), contains('Your cycles vary'));
    });

    test('a steady history needs no basis line', () {
      clean();
      expect(ttcWindowBasisLine(), isNull);
    });

    testWidgets('the source line is on the window card', (tester) async {
      clean();
      await pumpTall(tester, const TtcWindowScreen());
      expect(find.text('Estimated from your period dates'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('W5/W6/K4: ovulation tests', () {
    testWidgets('a positive on a clinic cycle says who to tell',
        (tester) async {
      clinic();
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }))));
      ttcOvPositiveSaved(ctx, today);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(kTtcOvClinicSaved), findsOneWidget);
      expect(find.text(kTtcOvMoved), findsNothing);
      await tester.pump(const Duration(seconds: 6));
    });

    test('the LH line names the best two days', () {
      final line = const TtcS(false).ovulationLhWhat;
      expect(line, contains('today and tomorrow your best two days'));
      expect(line, isNot(contains('window is opening')));
    });

    test('the silent saves have words', () {
      expect(ttcOvLaterPositiveLine(13), contains('first positive, on day 13'));
      expect(ttcOvOutsideCycleLine(ago(50)),
          contains('Only a test in this cycle'));
    });
  });

  // ===========================================================================
  group('W7: "Should I test?" after a loss', () {
    test('the rule holds until the first period, or six weeks', () async {
      await afterLoss();
      expect(ttcTestAfterLoss(), isTrue);
      expect(
          ttcTestAfterLoss(
              now: today.add(const Duration(days: kTtcAfterLossTestDays))),
          isFalse,
          reason: 'six weeks on, a test reads as usual');
      CycleStore.instance.logPeriodStart(today);
      expect(ttcTestAfterLoss(), isFalse,
          reason: 'her first period after the loss restarts her cycle');
    });

    TtcShouldTestChat lossChat() => TtcShouldTestChat(
        facts: TtcShouldTestFacts(today: today, afterLoss: true));

    test('the first line says it, before anything else', () {
      final s = lossChat().start();
      expect(s.say[1], kTtcAfterLossTestLine);
    });

    test('a positive: no big news, no "I\'m pregnant", a blood test', () {
      final chat = lossChat();
      final positive = chat
          .result(null)
          .choices
          .firstWhere((c) => c.label == 'Positive')
          .next!();
      final said = positive.say.join(' ');
      expect(said, isNot(contains('big news')));
      expect(said, contains('blood test'));
      expect(positive.choices.map((c) => c.label),
          isNot(contains("I'm pregnant")));
    });

    test('a faint line and a negative follow the same rule', () {
      final chat = lossChat();
      final faint = chat
          .result(null)
          .choices
          .firstWhere((c) => c.label == 'A faint line')
          .next!();
      expect(faint.say.join(' '), contains('blood test'));
      expect(faint.say.join(' '), isNot(contains('clearer by then')));
      final negative = chat.negative(null).say.join(' ');
      expect(negative, contains('first period after the loss'));
    });
  });

  // ===========================================================================
  group('W8/K7: "Should I test?" voices', () {
    test('his lines are about her, and nothing records', () {
      final chat = TtcShouldTestChat(
          facts: TtcShouldTestFacts(
              today: today,
              lastStart: ago(20),
              usualLength: 28,
              forHim: true));
      final said = chat.start().say.join(' ');
      expect(said, contains('Her period is due'));
      expect(said, isNot(contains('Your period')));
      expect(chat.positive().choices.map((c) => c.label),
          isNot(contains("I'm pregnant")));
      expect(chat.negative(null).choices.map((c) => c.label),
          isNot(contains('Log the result')));
    });

    test('a length she picks is saved, and the chat says so', () {
      final chat = TtcShouldTestChat(
          facts: TtcShouldTestFacts(today: today, lastStart: ago(10)),
          saveStatedLength: true);
      final s = chat.withLength(28);
      expect(s.say.first, contains('Saved: about 28 days'));
      expect(TtcStore.instance.statedCycleLength, 28);
    });
  });

  // ===========================================================================
  group('W9/W10: the report chat and the report agree', () {
    test('one cycle, one window', () {
      clean();
      final f = TtcCycleReportFacts.fromStores();
      expect(f.index, 1, reason: 'the last finished cycle');
      final w = ttcCycleWindowSpan(index: 1);
      expect(f.fertileFrom, w?.firstDay);
      expect(f.fertileTo, w?.lastDay);
    });
  });

  // ===========================================================================
  group('W12/W13/W14: after a loss, nothing hidden', () {
    testWidgets('Companion keeps her history and offers the one action',
        (tester) async {
      await afterLoss();
      await pumpTall(tester, const TtcCycleCompanionScreen());
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('ttc_companion_after_loss')),
          findsOneWidget);
      expect(find.text(kTtcAfterLossCycleLine), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_companion_after_loss_log')),
          findsOneWidget);
      expect(find.text('YOUR DATES'), findsOneWidget,
          reason: 'her period history stays on screen');
      expect(find.text('Your rhythm starts with one date'), findsNothing);
      await tester.tap(
          find.byKey(const ValueKey('ttc_companion_after_loss_log')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('When did your period start?'), findsOneWidget,
          reason: 'the action opens the period sheet');
    });

    testWidgets('Calendar says the same line, with the action',
        (tester) async {
      await afterLoss();
      await pumpTall(tester, const TtcCalendarScreen());
      expect(tester.takeException(), isNull);
      expect(find.text(kTtcAfterLossCycleLine), findsOneWidget);
      expect(find.text(kTtcLogMyPeriod), findsOneWidget);
    });

    test('his copy says what he really sees', () {
      expect(kTtcPartnerDatesEmpty, contains('Only she sees her period dates'));
      expect(kTtcPartnerDatesEmpty, isNot(contains('once she adds them')));
    });
  });

  // ===========================================================================
  group('W15/K1/K2/K3', () {
    test('the pill names the tool it opens', () {
      expect(ttcToolVerb('ttc_cycle'), 'Open Cycle Companion');
      expect(ttcToolVerb('ttc_calendar'), 'Open the calendar');
    });

    testWidgets('the hub has a one-tap period action', (tester) async {
      clean();
      await pumpTall(tester, const TtcCycleCompanionScreen());
      final action = find.byKey(const ValueKey('ttc_hub_period_started'));
      expect(action, findsOneWidget);
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('When did your period start?'), findsOneWidget);
    });

    test('bleed choices run 2 to 7, plus more than 7', () {
      expect(kTtcBleedChoices.first, 2);
      expect(kTtcBleedChoices.last, kTtcBleedMoreThanSeven);
      expect(ttcBleedDaysLabel(2), '2 bleeding days');
      expect(ttcBleedDaysLabel(kTtcBleedMoreThanSeven),
          'more than 7 bleeding days');
    });

    test('the three doctor lines', () {
      expect(ttcCycleDoctorLines(), isEmpty);

      CycleStore.instance
        ..logPeriodStart(ago(124))
        ..logPeriodStart(ago(84))
        ..logPeriodStart(ago(44))
        ..logPeriodStart(ago(4));
      expect(ttcCycleDoctorLines().join(' '), contains('longer than 35 days'));

      CycleStore.instance.resetForTest();
      CycleStore.instance.logPeriodStart(ago(95));
      expect(ttcCycleDoctorLines().join(' '), contains('more than 90 days'));

      CycleStore.instance.resetForTest();
      clean();
      CycleStore.instance.logBleedDays(ago(11), kTtcBleedMoreThanSeven);
      expect(ttcCycleDoctorLines(), contains(kTtcLongBleedLine));
    });

    test('a steady history has no doctor line, ever a verdict', () {
      clean();
      for (final l in ttcCycleDoctorLines()) {
        expect(l, contains('worth mentioning to a doctor'));
      }
      expect(ttcCycleDoctorLines(), isEmpty);
    });
  });

  // ===========================================================================
  group('Ask Veda learns what placed her window (two repos)', () {
    test('lh, temperature, or nothing', () {
      clean();
      expect(ttcAskVedaWindowSource(), isNull);
      CycleStore.instance.logTemperatureShift(15);
      expect(ttcAskVedaWindowSource(), 'temperature');
      CycleStore.instance.logLhPositive(12);
      expect(ttcAskVedaWindowSource(), 'lh',
          reason: 'a positive LH test wins, as in the engine');
    });

    test('on the wire, optional, and never from his phone', () {
      final service =
          File('lib/services/remote/ask_veda_service.dart').readAsStringSync();
      expect(service, contains("'window_source': ?windowSource"));
      final screen =
          File('lib/screens/ttc/ttc_askveda_screen.dart').readAsStringSync();
      expect(screen,
          contains('windowSource: widget.partnerMode ? null : '
              'ttcAskVedaWindowSource()'));
    });
  });

  test('a clinic-owned cycle is what the fixtures say it is', () {
    clinic();
    expect(TtcStore.instance.ownership, isNot(TimingOwnership.parentveda));
  });
}
