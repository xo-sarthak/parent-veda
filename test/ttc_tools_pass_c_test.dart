// =============================================================================
//  TTC tools pass, helper C (2026-09-27): self-checks, treatment, his semen
//  report, Can I
// -----------------------------------------------------------------------------
//  One focused test per behaviour fix from docs/TTC-TOOLS-UX-NOTES.md:
//    * a closed trigger time picker never invents 9:00pm
//    * a removed clinic date comes back with Undo
//    * a legacy round on an IUI path does not show IVF-only rows
//    * the check results lead with the free step, the paid one second
//    * the BMI save sits under the number and cannot save twice
//    * the semen report names the lab's words and checks a likely unit slip
//    * Can I searches the whole answer, groups it, and its empty state acts
//  Plus the wiring gate: each screen is still reached from a live surface.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_bmi_screen.dart';
import 'package:parentveda/screens/ttc/ttc_can_i_screen.dart';
import 'package:parentveda/screens/ttc/ttc_ivf_readiness_screen.dart';
import 'package:parentveda/screens/ttc/ttc_pcos_stand_screen.dart';
import 'package:parentveda/screens/ttc/ttc_precheck_screen.dart';
import 'package:parentveda/screens/ttc/ttc_round_strings.dart';
import 'package:parentveda/screens/ttc/ttc_semen_report_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_treatment_round_screens.dart';
import 'package:parentveda/screens/ttc/ttc_treatment_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_bmi_store.dart';
import 'package:parentveda/ttc/ttc_can_i_data.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_ivf_readiness.dart';
import 'package:parentveda/ttc/ttc_pcos_stand.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

DateTime _plus(int n) {
  final t = DateTime.now();
  return DateTime(t.year, t.month, t.day + n);
}

Future<void> _pump(WidgetTester tester, Widget child,
    {double width = 400, double height = 6000}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump(const Duration(milliseconds: 300));
}

/// Opens the trigger row's pickers and accepts the date the picker opens on.
Future<void> _pickTriggerDate(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('ttc_round_edit_trigger')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
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
  group('the trigger time is never invented', () {
    testWidgets(
        'closing the clock asks, and "Don\'t save it" saves nothing, with no '
        'reminder time', (tester) async {
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.stimStart: _plus(-3)});
      await _pump(tester, const TtcTreatmentScreen());
      await _pickTriggerDate(tester);

      // The clock is titled for the trigger, then closed without a time.
      expect(find.text(kTtcTriggerTimeHelp), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text(kTtcTriggerNoTimeTitle), findsOneWidget,
          reason: 'a closed clock is asked about, not guessed at');
      await tester.tap(find.byKey(const ValueKey('ttc_round_confirm_no')));
      await tester.pumpAndSettle();

      expect(TtcTreatmentStore.instance.cycle[TtcTreatmentStep.trigger],
          isNull,
          reason: 'the old code saved 9:00pm here and armed reminders');
      expect(find.text(kTtcTriggerNotSaved), findsOneWidget,
          reason: 'nothing silent: it says the date was not saved');
    });

    testWidgets('"Add the time" reopens the clock', (tester) async {
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.stimStart: _plus(-3)});
      await _pump(tester, const TtcTreatmentScreen());
      await _pickTriggerDate(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_round_confirm_yes')));
      await tester.pumpAndSettle();
      expect(find.text(kTtcTriggerTimeHelp), findsOneWidget,
          reason: 'the clock is back');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      final at = TtcTreatmentStore.instance.cycle[TtcTreatmentStep.trigger];
      expect(at, isNotNull);
      expect(at!.hour, 21,
          reason: 'the hour she accepted on the clock, not a silent default');
    });

    test('the source no longer falls back to 21', () {
      for (final f in [
        'lib/screens/ttc/ttc_treatment_round_screens.dart',
        'lib/screens/ttc/ttc_treatment_screen.dart',
      ]) {
        final live = File(f)
            .readAsLinesSync()
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        expect(live.contains('?? 21'), isFalse, reason: f);
      }
    });
  });

  // ===========================================================================
  group('a removed date comes back with Undo', () {
    testWidgets('on the plan', (tester) async {
      final beta = _plus(12);
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.iui, dates: {TtcTreatmentStep.betaTest: beta});
      await _pump(tester, const TtcTreatmentScreen());
      await tester
          .tap(find.byKey(const ValueKey('ttc_round_remove_betaTest')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(TtcTreatmentStore.instance.cycle[TtcTreatmentStep.betaTest],
          isNull);
      expect(find.text('Pregnancy test removed.'), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.text(kTtcRoundUndoCta));
      await tester.pumpAndSettle();
      expect(TtcTreatmentStore.instance.cycle[TtcTreatmentStep.betaTest],
          beta);
    });

    testWidgets('on a legacy row, and IUI shows no transfer row',
        (tester) async {
      TtcStore.instance.setPath(TtcPath.iui);
      final beta = _plus(9);
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest, beta);
      await _pump(tester, const TtcTreatmentScreen());

      // IUI: the retrieval row is named IUI and the transfer row is absent.
      expect(find.text('IUI'), findsWidgets);
      expect(find.text(TtcTreatmentStep.transfer.label(false)), findsNothing);
      expect(find.text('Embryo transfer'), findsNothing);

      await tester
          .tap(find.byKey(const ValueKey('ttc_legacy_clear_betaTest')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(TtcTreatmentStore.instance.cycle[TtcTreatmentStep.betaTest],
          isNull);
      await tester.pumpAndSettle();
      await tester.tap(find.text(kTtcRoundUndoCta));
      await tester.pumpAndSettle();
      expect(TtcTreatmentStore.instance.cycle[TtcTreatmentStep.betaTest],
          beta);
    });

    test('dates carry the weekday', () {
      expect(ttcRoundDate(DateTime(2026, 10, 15)), 'Thu 15 Oct');
    });
  });

  // ===========================================================================
  group('the free step leads, the paid consult is second', () {
    double top(WidgetTester t, String text) =>
        t.getTopLeft(find.text(text)).dy;

    testWidgets('should I get help', (tester) async {
      final result = ivfBuildReadiness(
          IvfReadinessAnswers(), TtcFertilityHelpStore.instance.context);
      expect(result.verdict.pushesToSpecialist, isTrue);
      await _pump(tester, TtcIvfReadinessResultScreen(result: result));
      expect(top(tester, 'What to take with you'),
          lessThan(top(tester, 'Book a fertility specialist')));
    });

    testWidgets('where do I stand, with a free read', (tester) async {
      await _pump(tester,
          TtcPcosStandResultScreen(result: pcosBuildStand(PcosStandAnswers())));
      expect(top(tester, 'What to take with you'),
          lessThan(top(tester, 'Book a PCOS specialist')));
      expect(find.byKey(const ValueKey('ttc_pcos_stand_read')), findsOneWidget);
    });

    testWidgets('the readiness check says the skip up front', (tester) async {
      await _pump(tester, const TtcIvfReadinessScreen());
      expect(find.textContaining("Skip any you'd rather not answer"),
          findsOneWidget);
      expect(find.text("See if it's time to talk to someone"), findsOneWidget);
    });
  });

  // ===========================================================================
  group('BMI', () {
    testWidgets('opens on the fields, saves once from under the number',
        (tester) async {
      await TtcBmiStore.instance.load();
      await TtcBmiStore.instance.clearHistory();
      await _pump(tester, const TtcBmiScreen());
      await tester.pumpAndSettle();
      expect(find.text('Work out your BMI.'), findsOneWidget,
          reason: 'no intro screen before the two fields');

      await tester.enterText(find.byType(TextField).at(0), '160');
      await tester.enterText(find.byType(TextField).at(1), '55');
      await tester.tap(find.text('See my result'));
      await tester.pumpAndSettle();

      expect(find.text('Save this measurement'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_bmi_save')));
      await tester.pumpAndSettle();
      expect(TtcBmiStore.instance.history.length, 1);
      expect(find.text('Saved to your history and checklist'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_bmi_save')));
      await tester.pumpAndSettle();
      expect(TtcBmiStore.instance.history.length, 1,
          reason: 'a second tap does not save the same measurement twice');
      expect(find.text('18.5 to 22.9'), findsOneWidget,
          reason: 'the bands are named under the scale');
    });
  });

  // ===========================================================================
  group('the pre-pregnancy checklist', () {
    testWidgets('opens on the list with no count before anything is marked',
        (tester) async {
      await _pump(tester, const TtcPrecheckScreen());
      await tester.pumpAndSettle();
      expect(find.text('Things to sort out before trying'), findsOneWidget);
      expect(find.textContaining("You've marked"), findsNothing,
          reason: '"0 of 21" read like a debt');
    });
  });

  // ===========================================================================
  group('the semen report', () {
    test('a likely unit slip is asked about, never blocked', () {
      expect(ttcSemenUnitCheck('concentration', {'concentration': 40}),
          isNull);
      expect(ttcSemenUnitCheck('concentration', {'concentration': 300}),
          contains('per ml'));
      expect(ttcSemenUnitCheck('morphology', {'morphology': 140}),
          contains('100 per cent'));
      expect(
          ttcSemenUnitCheck('progressive_motility',
              {'total_motility': 30, 'progressive_motility': 45}),
          contains('swapped'));
    });

    testWidgets('each number names what the lab may call it', (tester) async {
      await _pump(tester, const TtcSemenReportScreen());
      expect(find.textContaining('Kruger'), findsOneWidget);
      expect(find.textContaining('sperm count'), findsOneWidget);
      expect(find.text('The four main numbers'), findsOneWidget);
      expect(find.text('A few details'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('Can I', () {
    test('search reads the why and the India line too', () {
      final hits = [
        for (final e in ttcCanI)
          if (ttcCanIMatches(e, 'henna')) e.id,
      ];
      expect(hits, contains('hair_dye'));
    });

    testWidgets('grouped under three headings', (tester) async {
      await _pump(tester, const TtcCanIScreen());
      for (final (name, _) in kTtcCanIGroups) {
        expect(find.text(name.toUpperCase()), findsOneWidget);
      }
    });

    testWidgets('an empty search offers Ask Veda with her words',
        (tester) async {
      await _pump(tester, const TtcCanIScreen());
      await tester.enterText(find.byType(TextField), 'zzqx');
      await tester.pump();
      expect(find.byKey(const ValueKey('ttc_can_i_ask_veda')), findsOneWidget);
      expect(find.text('Ask Veda: "zzqx"'), findsOneWidget);
    });
  });

  // ===========================================================================
  test('wiring gate: every screen here is reached from a live surface', () {
    final router = File('lib/screens/ttc/ttc_surface_router.dart')
        .readAsStringSync();
    for (final line in [
      "'ttc_pcos_check' => const TtcPcosStandScreen(),",
      "'ttc_precheck' => const TtcPrecheckScreen(),",
      "'ttc_semen_report' => const TtcSemenReportScreen(),",
      "'ttc_bmi' => const TtcBmiScreen(),",
      "'ttc_fertility_help' => const TtcIvfReadinessScreen(),",
      "'ttc_treatment' => const TtcTreatmentScreen(),",
      "'ttc_can_i' => const TtcCanIScreen(),",
    ]) {
      expect(router.contains(line), isTrue, reason: line);
    }
    // The trigger fix is on the path every date row takes.
    final screens = File('lib/screens/ttc/ttc_treatment_round_screens.dart')
        .readAsStringSync();
    expect(screens.contains('ttcPickTriggerTime(context, day'), isTrue);
    final legacy =
        File('lib/screens/ttc/ttc_treatment_screen.dart').readAsStringSync();
    expect(legacy.contains('ttcPickRoundDate(context'), isTrue);
  });
}
