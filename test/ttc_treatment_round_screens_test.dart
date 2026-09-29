// =============================================================================
//  A treatment round on screen (docs/TTC-TREATMENT-FLOW.md B3 and B4)
// -----------------------------------------------------------------------------
//  Widget tests for the start flow, the plan's timeline, the result, the
//  check-in and the home's round card, each at 360dp, plus a reachability
//  test that greps the call sites (CLAUDE.md, the wiring gate: a test count
//  is not evidence a screen can be reached).
//
//  The user's rule of 2026-09-26 is what most of these hold: nothing changes
//  silently (nothing is saved before "Okay"; the statement says from when),
//  every option does what its label says, a close is confirmed with the
//  consequence restated, and Undo puts the round back exactly.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_round_home_card.dart';
import 'package:parentveda/screens/ttc/ttc_round_strings.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_treatment_round_screens.dart';
import 'package:parentveda/screens/ttc/ttc_treatment_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _plus(int n) {
  final t = _today();
  return DateTime(t.year, t.month, t.day + n);
}

Future<void> pumpAt360(WidgetTester tester, Widget child,
    {double height = 3200}) async {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull, reason: 'threw or overflowed');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('the start flow: kind, first date, what we will show', () {
    testWidgets('nothing is saved until "Okay", and the statement says so',
        (tester) async {
      await pumpAt360(tester, const TtcTreatmentStartScreen());
      expect(find.text(kTtcStartKindTitle), findsOneWidget);
      // Continue waits for a choice.
      await tester.tap(find.byKey(const ValueKey('ttc_start_next')));
      await tester.pump();
      expect(find.text(kTtcStartKindTitle), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('ttc_start_kind_ivfFresh')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_start_next')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(kTtcStartDateTitle), findsOneWidget);
      expect(find.text('Baseline scan'), findsOneWidget);
      expect(TtcTreatmentStore.instance.cycle.isEmpty, isTrue,
          reason: 'nothing saved while she is still choosing');

      await tester.tap(find.byKey(const ValueKey('ttc_start_later')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(kTtcStartReviewTitle), findsOneWidget);
      expect(find.text(ttcStartWhatChanges(null, DateTime.now())),
          findsOneWidget);
      expect(TtcTreatmentStore.instance.cycle.kind, isNull);

      // "Add a date" goes back, and still saves nothing.
      await tester.tap(find.byKey(const ValueKey('ttc_start_change_date')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(kTtcStartDateTitle), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_start_later')));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const ValueKey('ttc_start_save')));
      await tester.pumpAndSettle();
      expect(TtcTreatmentStore.instance.cycle.kind, TtcRoundKind.ivfFresh);
      expect(TtcStore.instance.path, TtcPath.ivf);
      expect(find.byType(TtcTreatmentScreen), findsOneWidget,
          reason: 'lands on the plan');
      expect(tester.takeException(), isNull);
    });

    test('the statement names the first treatment day, or today', () {
      final now = _today();
      expect(ttcStartWhatChanges(_plus(5), now),
          contains('From ${ttcRoundDate(_plus(5))} (your first treatment day)'));
      expect(ttcStartWhatChanges(_plus(5), now),
          contains('Fertile days and period predictions will pause'));
      expect(ttcStartWhatChanges(now, now), contains('from today'));
      expect(ttcStartWhatChanges(null, now), contains('Nothing changes yet'));
    });

    testWidgets('an open round is named before a new one replaces it',
        (tester) async {
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.iui,
          dates: {TtcTreatmentStep.stimStart: _plus(-2)});
      await pumpAt360(tester, const TtcTreatmentStartScreen());
      expect(find.text(kTtcStartClosesCurrent), findsOneWidget);
    });
  });

  // ===========================================================================
  //  2026-09-29, the user on build 19: "Once I click on Start my round … I
  //  cannot unselect them if I have selected them; I have to go back to
  //  unselect them." Every answer toggles in place, a greyed Next says why,
  //  and a step back keeps what she chose.
  group('every answer can be taken back in place', () {
    Finder kind(String name) => find.byKey(ValueKey('ttc_start_kind_$name'));
    bool nextOn(WidgetTester tester) =>
        tester.widget<TtcRoundButton>(find.byKey(const ValueKey('ttc_start_next'))).onTap !=
        null;
    bool chosen(WidgetTester tester, String name) =>
        tester.widget<TtcRoundOption>(kind(name)).selected;

    Future<void> addDate(WidgetTester tester, String step) async {
      await tester.tap(find.byKey(ValueKey('ttc_start_date_$step')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    testWidgets('the kind: choose, clear by a second tap, choose again',
        (tester) async {
      await pumpAt360(tester, const TtcTreatmentStartScreen());
      // Nothing chosen: Next waits and says why; every option wears a ring.
      expect(nextOn(tester), isFalse);
      expect(find.text(kTtcStartKindNeeded), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNWidgets(7));
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing,
          reason: 'an answer is not a link');

      await tester.tap(kind('iui'));
      await tester.pump();
      expect(chosen(tester, 'iui'), isTrue);
      expect(nextOn(tester), isTrue);
      expect(find.text(kTtcStartKindNeeded), findsNothing);
      expect(find.text(kTtcStartKindClearHint), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);

      // The same tap again clears it, on this screen.
      await tester.tap(kind('iui'));
      await tester.pump();
      expect(chosen(tester, 'iui'), isFalse);
      expect(find.byIcon(Icons.radio_button_checked_rounded), findsNothing);
      expect(nextOn(tester), isFalse);
      expect(find.text(kTtcStartKindNeeded), findsOneWidget);

      // And again chooses it.
      await tester.tap(kind('iui'));
      await tester.pump();
      expect(chosen(tester, 'iui'), isTrue);
      expect(nextOn(tester), isTrue);

      // Another kind moves the choice: one at a time.
      await tester.tap(kind('notSure'));
      await tester.pump();
      expect(chosen(tester, 'iui'), isFalse);
      expect(chosen(tester, 'notSure'), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a step back keeps the kind and the dates, even across a '
        'change of mind', (tester) async {
      await pumpAt360(tester, const TtcTreatmentStartScreen());
      await tester.tap(kind('ivfFresh'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_start_next')));
      await tester.pump(const Duration(milliseconds: 300));

      // No date yet: Next waits and says why, and "later" is the way on.
      expect(nextOn(tester), isFalse);
      expect(find.text(kTtcStartDateNeeded), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_start_later')), findsOneWidget);

      await addDate(tester, 'baselineScan');
      expect(nextOn(tester), isTrue);
      expect(find.text(kTtcStartDateNeeded), findsNothing);
      expect(find.byKey(const ValueKey('ttc_start_later')), findsNothing,
          reason: '"later" can no longer wipe a date she added');

      // Back by the system gesture: the kind is still chosen.
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(kTtcStartKindTitle), findsOneWidget);
      expect(chosen(tester, 'ivfFresh'), isTrue);

      // She changes her mind to IUI and back: the IVF date survives.
      await tester.tap(kind('iui'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_start_next')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Add date'), findsOneWidget,
          reason: 'the IUI rows show only IUI dates');
      // The shell's back arrow does the same as the gesture (2026-09-29: the
      // worded link it replaced is commented out). Kept for revert:
      //   // The worded back link does the same as the gesture.
      //   await tester.tap(find.byKey(const ValueKey('ttc_start_back')));
      await tester.tap(find.byKey(const ValueKey('ttc_tool_back')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(chosen(tester, 'iui'), isTrue);
      await tester.tap(kind('ivfFresh'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_start_next')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(ttcRoundDate(_today())), findsOneWidget,
          reason: 'the baseline scan she added is still there');
      expect(nextOn(tester), isTrue);

      // The date clears in place too, and Next waits again.
      await tester.tap(find.byTooltip('Remove this date'));
      await tester.pump();
      expect(nextOn(tester), isFalse);
      expect(find.byKey(const ValueKey('ttc_start_later')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 5)); // the Undo snack
    });

    testWidgets('only the chosen kind\'s dates are saved', (tester) async {
      await pumpAt360(tester, const TtcTreatmentStartScreen());
      await tester.tap(kind('ivfFresh'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_start_next')));
      await tester.pump(const Duration(milliseconds: 300));
      await addDate(tester, 'baselineScan');
      // Kept for revert (2026-09-29):
      //   await tester.tap(find.byKey(const ValueKey('ttc_start_back')));
      await tester.tap(find.byKey(const ValueKey('ttc_tool_back')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(kind('iui'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_start_next')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const ValueKey('ttc_start_later')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const ValueKey('ttc_start_save')));
      await tester.pumpAndSettle();
      final c = TtcTreatmentStore.instance.cycle;
      expect(c.kind, TtcRoundKind.iui);
      expect(c[TtcTreatmentStep.baselineScan], isNull,
          reason: 'an IVF date is never saved into an IUI round');
    });

    testWidgets('the clinic name, filled from the last round, clears in one '
        'tap', (tester) async {
      await pumpAt360(tester, const TtcTreatmentStartScreen());
      await tester.tap(kind('iui'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_start_next')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const ValueKey('ttc_start_later')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('ttc_start_clinic_clear')), findsNothing);
      await tester.enterText(
          find.byKey(const ValueKey('ttc_start_clinic')), 'Nova IVF');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_start_clinic_clear')));
      await tester.pump();
      expect(find.text('Nova IVF'), findsNothing);
      expect(find.byKey(const ValueKey('ttc_start_clinic_clear')), findsNothing);
    });

    testWidgets('the embryo day, before moving to Pregnancy, toggles and '
        'stays on screen', (tester) async {
      TtcTreatmentStore.instance.startRound(kind: TtcRoundKind.ivfFresh, dates: {
        TtcTreatmentStep.stimStart: _plus(-30),
        TtcTreatmentStep.transfer: _plus(-12),
        TtcTreatmentStep.betaTest: _plus(-1),
      });
      await pumpAt360(tester, const TtcRoundPregnancyScreen());
      const d3 = ValueKey('ttc_to_preg_embryo_3');
      const d5 = ValueKey('ttc_to_preg_embryo_5');
      await tester.tap(find.byKey(d3));
      await tester.pump(const Duration(milliseconds: 300));
      expect(TtcTreatmentStore.instance.cycle.embryoDay, 3);
      expect(find.byKey(d3), findsOneWidget,
          reason: 'the question stays, so a mis-tap can be changed here');
      await tester.tap(find.byKey(d3));
      await tester.pump(const Duration(milliseconds: 300));
      expect(TtcTreatmentStore.instance.cycle.embryoDay, isNull);
      await tester.tap(find.byKey(d5));
      await tester.pump(const Duration(milliseconds: 300));
      expect(TtcTreatmentStore.instance.cycle.embryoDay, 5);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow on any start screen at 360dp and 1.5x text',
        (tester) async {
      tester.view.physicalSize = const Size(360, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: w!,
        ),
        home: const TtcTreatmentStartScreen(),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'kind page, empty');
      await tester.tap(kind('fetNatural'));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'kind page, chosen');
      await tester.tap(find.byKey(const ValueKey('ttc_start_next')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'date page');
      await tester.tap(find.byKey(const ValueKey('ttc_start_later')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
          find.byKey(const ValueKey('ttc_start_clinic')), 'A long clinic name, Bengaluru');
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'review page');
    });
  });

  // ===========================================================================
  group('the plan: "Here\'s how your round usually goes"', () {
    testWidgets('dated rows show their date, the rest "Your clinic will tell '
        'you", at 360dp', (tester) async {
      TtcTreatmentStore.instance.startRound(kind: TtcRoundKind.ivfFresh, dates: {
        TtcTreatmentStep.stimStart: _plus(-3),
        TtcTreatmentStep.trigger:
            DateTime(_plus(6).year, _plus(6).month, _plus(6).day, 21, 15),
      });
      await pumpAt360(tester, const TtcTreatmentScreen(), height: 5000);
      expect(find.byKey(const ValueKey('ttc_round_timeline')), findsOneWidget);
      expect(find.text(kTtcRoundPlanTitle), findsOneWidget);
      expect(find.text('First stimulation injection'), findsOneWidget);
      expect(find.text('Egg collection'), findsOneWidget);
      expect(find.text(kTtcRoundClinicWillTell.toUpperCase()), findsWidgets);
      expect(find.textContaining('9:15PM'), findsOneWidget,
          reason: 'the trigger keeps its minute');
      expect(find.byKey(const ValueKey('ttc_round_header')), findsOneWidget);
      // The header counts the day since the tool rebuild (2026-09-27), as
      // the IVF door's panel does. Was:
      //   expect(find.text('Stimulation'), findsOneWidget, ...);
      expect(find.text('Stimulation · day 4'), findsOneWidget,
          reason: 'the step, derived from her dates');
      // The old chooser and questions are gone (decision 2).
      expect(find.byType(TtcPathChooser), findsNothing);
      expect(find.byType(TtcPathwayQuestions), findsNothing);
    });

    testWidgets('with no round, the screen opens on "Starting treatment?"',
        (tester) async {
      await pumpAt360(tester, const TtcTreatmentScreen());
      expect(find.byKey(const ValueKey('ttc_start_treatment_card')),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_start_treatment_card')));
      await tester.pumpAndSettle();
      expect(find.byType(TtcTreatmentStartScreen), findsOneWidget);
    });

    testWidgets('a legacy round keeps its rows and is asked its kind',
        (tester) async {
      TtcTreatmentStore.instance
          .setDate(TtcTreatmentStep.betaTest, _plus(9));
      await pumpAt360(tester, const TtcTreatmentScreen(), height: 5000);
      expect(find.byKey(const ValueKey('ttc_round_legacy_kind')),
          findsOneWidget);
      // The legacy rows use the round's names since 2026-09-27 ("Blood test").
      // Was: find.text(TtcTreatmentStep.betaTest.label(false)).
      expect(find.text(ttcStepLabel(TtcTreatmentStep.betaTest, null)),
          findsWidgets);
    });

    testWidgets('pausing is confirmed, closes into history, and undoes',
        (tester) async {
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.stimStart: _plus(-3)});
      final before = TtcTreatmentStore.instance.cycle.toJson();
      await pumpAt360(tester, const TtcTreatmentScreen(), height: 5000);
      await tester.tap(find.byKey(const ValueKey('ttc_round_pause')));
      await tester.pumpAndSettle();
      final (_, body, _) = ttcConfirmClose(TtcRoundOutcome.paused);
      expect(find.text(body), findsOneWidget,
          reason: 'the consequence is restated before anything changes');
      await tester.tap(find.byKey(const ValueKey('ttc_round_confirm_no')));
      await tester.pumpAndSettle();
      expect(TtcTreatmentStore.instance.cycle.isEmpty, isFalse,
          reason: '"Keep it open" keeps it open');

      await tester.tap(find.byKey(const ValueKey('ttc_round_pause')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_round_confirm_yes')));
      await tester.pumpAndSettle();
      expect(TtcTreatmentStore.instance.cycle.isEmpty, isTrue);
      expect(TtcTreatmentStore.instance.history.single.outcome,
          TtcRoundOutcome.paused);
      expect(find.byKey(const ValueKey('ttc_round_undo_card')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_round_undo')));
      await tester.pumpAndSettle();
      expect(TtcTreatmentStore.instance.cycle.toJson(), before,
          reason: 'undo restores the round exactly');
      expect(TtcTreatmentStore.instance.history, isEmpty);
    });
  });

  // ===========================================================================
  group('the result', () {
    testWidgets('three labelled choices; "Not this time" is confirmed, then '
        'closes', (tester) async {
      TtcTreatmentStore.instance.startRound(kind: TtcRoundKind.ivfFresh, dates: {
        TtcTreatmentStep.stimStart: _plus(-30),
        TtcTreatmentStep.betaTest: _plus(-1),
      });
      await pumpAt360(tester, const TtcTreatmentResultScreen());
      expect(find.text(kTtcResultTitle), findsOneWidget);
      for (final line in [
        kTtcResultPositiveLine,
        kTtcResultNegativeLine,
        kTtcResultRepeatLine,
      ]) {
        expect(find.text(line), findsOneWidget, reason: line);
      }
      await tester.tap(find.byKey(const ValueKey('ttc_result_negative')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_round_confirm_yes')));
      await tester.pumpAndSettle();
      final h = TtcTreatmentStore.instance.history.single;
      expect(h.outcome, TtcRoundOutcome.negative);
      expect(h.closedOn, _today());
    });

    testWidgets('"I\'d rather not say now" changes nothing', (tester) async {
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.iui,
          dates: {TtcTreatmentStep.betaTest: _plus(-1)});
      await pumpAt360(tester, const TtcTreatmentResultScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_result_later')));
      await tester.pumpAndSettle();
      expect(TtcTreatmentStore.instance.cycle.isClosed, isFalse);
      expect(TtcTreatmentStore.instance.history, isEmpty);
    });

    testWidgets('with no round open, it says so and offers the way back',
        (tester) async {
      await pumpAt360(tester, const TtcTreatmentResultScreen());
      expect(find.text(kTtcSeeRound), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the check-in sheet', () {
    Future<void> openSheet(WidgetTester tester) async {
      await pumpAt360(
          tester,
          Scaffold(
            body: Builder(
              builder: (c) => TextButton(
                key: const ValueKey('open'),
                onPressed: () => showTtcCheckInSheet(c),
                child: const Text('open'),
              ),
            ),
          ),
          height: 1400);
      await tester.tap(find.byKey(const ValueKey('open')));
      await tester.pumpAndSettle();
    }

    void quietRound() {
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {
            TtcTreatmentStep.stimStart: _plus(-40),
            TtcTreatmentStep.betaTest: _plus(-10),
          },
          now: _plus(-40));
    }

    testWidgets('three labelled answers, each doing what it says',
        (tester) async {
      quietRound();
      final store = TtcTreatmentStore.instance;
      expect(store.checkInDue(), isTrue);
      await openSheet(tester);
      for (final line in [
        kTtcCheckInStillLine,
        kTtcCheckInPausedLine,
        kTtcCheckInOverLine,
      ]) {
        expect(find.text(line), findsOneWidget, reason: line);
      }
      expect(find.text(kTtcCheckInAddDate), findsOneWidget);
      expect(find.text(kTtcCheckInLater), findsOneWidget);

      // Still going: keeps following, nothing closes, the ask goes quiet.
      await tester.tap(find.byKey(const ValueKey('ttc_sheet_still')));
      await tester.pumpAndSettle();
      expect(store.cycle.isClosed, isFalse);
      expect(store.checkInDue(), isFalse);
      expect(store.checkInDue(now: _plus(7)), isTrue);
    });

    testWidgets('"It\'s over" is confirmed, then closes and goes back to her '
        'own cycle', (tester) async {
      quietRound();
      await openSheet(tester);
      await tester.tap(find.byKey(const ValueKey('ttc_sheet_over')));
      await tester.pumpAndSettle();
      final (_, body, _) = ttcConfirmClose(TtcRoundOutcome.ended);
      expect(find.text(body), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_round_confirm_yes')));
      await tester.pumpAndSettle();
      expect(TtcTreatmentStore.instance.history.single.outcome,
          TtcRoundOutcome.ended);
      expect(find.text(ttcClosedLine(TtcRoundOutcome.ended)), findsOneWidget,
          reason: 'the close is announced, with its undo');
    });

    testWidgets('"Ask me later" holds it for a few days, and closes nothing',
        (tester) async {
      quietRound();
      await openSheet(tester);
      await tester.tap(find.byKey(const ValueKey('ttc_sheet_later')));
      await tester.pumpAndSettle();
      final store = TtcTreatmentStore.instance;
      expect(store.checkInDue(), isFalse);
      expect(store.checkInDue(now: _plus(3)), isTrue);
      expect(store.cycle.isClosed, isFalse);
    });
  });

  // ===========================================================================
  group('the home\'s round card', () {
    testWidgets('"Your home now follows your round" once, with what changed',
        (tester) async {
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.baselineScan: _plus(-1)},
          now: _plus(-3));
      await pumpAt360(tester, const Scaffold(body: TtcRoundHomeCard()),
          height: 900);
      expect(find.byKey(const ValueKey('ttc_round_notice_active')),
          findsOneWidget);
      await tester.tap(find.text(kTtcActiveWhatChanged));
      await tester.pumpAndSettle();
      for (final line in kTtcActiveChanges) {
        expect(find.text(line), findsOneWidget, reason: line);
      }
      await tester.tap(find.byKey(const ValueKey('ttc_what_changed_got_it')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_round_notice_active')),
          findsNothing,
          reason: 'said once');
    });

    testWidgets('the check-in card leads when it is due', (tester) async {
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.iui,
          dates: {TtcTreatmentStep.stimStart: _plus(-30)},
          now: _plus(-30));
      await pumpAt360(tester, const Scaffold(body: TtcRoundHomeCard()),
          height: 900);
      expect(find.byKey(const ValueKey('ttc_round_notice_checkIn')),
          findsOneWidget);
    });

    testWidgets('nothing at all for someone trying naturally', (tester) async {
      await pumpAt360(tester, const Scaffold(body: TtcRoundHomeCard()),
          height: 600);
      expect(find.byType(TtcRoundNoticeCard), findsNothing);
    });
  });

  // ===========================================================================
  //  The wiring gate: grep the call sites
  // ===========================================================================
  group('every way in is wired', () {
    String src(String path) => File(path).readAsStringSync();
    Iterable<String> live(String body) =>
        body.split('\n').where((l) => !l.trimLeft().startsWith('//'));
    bool calls(String path, String what) =>
        live(src(path)).any((l) => l.contains(what));

    test('the IVF door carries "Starting treatment?"', () {
      expect(
          calls('lib/ttc/focus/ttc_focus_ivf.dart',
              "kTtcIvfTopCardSurface = 'ttc_treatment/start'"),
          isTrue);
      // 2026-09-26 (B7): the door draws `TtcIvfRoundPanel`, which draws the
      // card when no round exists. Kept for revert: the door called
      // `TtcStartTreatmentCard(` itself.
      expect(
          calls('lib/screens/ttc/doors/ttc_door_screen.dart',
              'TtcIvfRoundPanel('),
          isTrue);
      expect(
          calls('lib/screens/ttc/ttc_treatment_round_screens.dart',
              'return TtcStartTreatmentCard(onTap: onStart)'),
          isTrue);
      expect(
          calls('lib/screens/ttc/doors/ttc_door_screen.dart',
              'kTtcIvfTopCardSurface'),
          isTrue);
    });

    test('the home: the round card, the hidden row, the result', () {
      const home = 'lib/screens/ttc/ttc_home_v3.dart';
      expect(calls(home, 'const TtcRoundHomeCard()'), isTrue);
      expect(calls(home, 'ttcHomeHidesQuickRow(selected)'), isTrue);
      expect(calls(home, 'openTtcTreatmentResult(context)'), isTrue);
      expect(calls(home, 'ttcRoundHeroCopy(line, selected)'), isTrue);
      expect(calls(home, 'TtcTreatmentStore.instance.noteOpened()'), isTrue);
    });

    test('You has a Treatment row (TTC only)', () {
      const you = 'lib/screens/profile/pv_you_content.dart';
      final body = src(you);
      final trying = body.substring(body.indexOf('final PvYouStageContent _trying'),
          body.indexOf('final PvYouStageContent _pregnancy'));
      expect(trying, contains("title: 'Treatment',"));
      expect(trying, contains("openTtcSurface(c, 'ttc_treatment')"));
    });

    test('the chats\' clinic branches open the round', () {
      expect(
          calls('lib/screens/ttc/chats/ttc_period_came_chat.dart',
              "open: ['ttc_treatment']"),
          isTrue);
      expect(
          calls('lib/screens/ttc/chats/ttc_should_test_chat.dart',
              "open: ['ttc_treatment']"),
          isTrue);
    });

    test('the router and the labels know the new surfaces', () {
      const router = 'lib/screens/ttc/ttc_surface_router.dart';
      expect(calls(router, "'ttc_treatment/start' => const TtcTreatmentStartScreen()"),
          isTrue);
      expect(calls(router, "'ttc_treatment/result' => const TtcTreatmentResultScreen()"),
          isTrue);
      const labels = 'lib/services/ttc_surfaces.dart';
      expect(calls(labels, "'ttc_treatment/start'"), isTrue);
      expect(calls(labels, "'ttc_treatment/result'"), isTrue);
    });

    test('the treatment screen reaches every round action', () {
      const screen = 'lib/screens/ttc/ttc_treatment_screen.dart';
      for (final what in [
        'const TtcStartTreatmentCard()',
        'openTtcTreatmentStart(context)',
        'showTtcPlanChangedSheet(context)',
        'openTtcTreatmentResult(context)',
        'ttcConfirmCloseRound(context, TtcRoundOutcome.paused)',
        'showTtcCheckInSheet(context)',
        'TtcRoundTimeline(round: round)',
      ]) {
        expect(calls(screen, what), isTrue, reason: what);
      }
      // The chooser and the two questions are commented out, kept for revert.
      expect(calls(screen, 'ttcToolPad(const TtcPathChooser())'), isFalse);
      expect(src(screen), contains('// ttcToolPad(const TtcPathChooser()),'));
    });

    test('a period logged while the check-in is due asks first', () {
      // 2026-09-28: `logTtcPeriod` delegates to the period sheet, which opens
      // the check-in after a new period. Kept for revert:
      //   calls('lib/screens/ttc/ttc_today_screen.dart',
      //       'await showTtcCheckInSheet(context);')
      expect(
          calls('lib/screens/ttc/ttc_today_screen.dart',
              'showTtcHomePeriodSheet(context)'),
          isTrue);
      expect(
          calls('lib/screens/ttc/ttc_cycle_companion.dart',
              'await showTtcCheckInSheet(navigator.context);'),
          isTrue);
    });

    test('the route names are the ones the brief names', () {
      const f = 'lib/screens/ttc/ttc_treatment_round_screens.dart';
      expect(calls(f, "RouteSettings(name: 'ttc/treatment/start')"), isTrue);
      expect(calls(f, "RouteSettings(name: 'ttc/treatment/result')"), isTrue);
      expect(
          calls('lib/screens/ttc/ttc_treatment_screen.dart',
              "RouteSettings(name: 'ttc/treatment')"),
          isTrue);
    });
  });
}
