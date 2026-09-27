// =============================================================================
//  The care pathway is REACHABLE
// -----------------------------------------------------------------------------
//  The single worst defect in the audit, and the one this repo's wiring gate
//  exists to prevent.
//
//  `TtcStore.setPath()` had no caller anywhere in the app - only tests. And
//  `TtcTreatmentEntryCard`, the card that leads to the pathway questions,
//  rendered only `if (today.clinicInvolved)` - which is true only once a
//  non-natural path is already set. The only way in was through a door that
//  could not open until you were already through it.
//
//  So every user was permanently on `natural`, and all of this was dead code
//  in a shipped build: TimingOwnership, the seven behaviour flags, both pathway
//  questions, the treatment cycle, the two trigger reminders, the Taken tick,
//  the beta countdown, the clinic-led card. Forty-seven tests passed over the
//  top of it.
//
//  A woman on IVF therefore got the natural-cycle experience: a fertile window,
//  an ovulation estimate, and a countdown to a period her progesterone was
//  delaying. That is the original defect the whole design was built to fix.
//
//  These tests assert the DOOR, not the destination. A destination nobody can
//  open is what got us here.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/screens/ttc/ttc_treatment_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  void logCleanHistory() {
    final now = DateTime.now();
    CycleStore.instance
      ..logPeriodStart(now.subtract(const Duration(days: 68)))
      ..logPeriodStart(now.subtract(const Duration(days: 40)))
      ..logPeriodStart(now.subtract(const Duration(days: 12)));
  }

  Future<void> pumpTall(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1200, 9000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
    await tester.pumpAndSettle();
  }

  // ===========================================================================
  group('the door exists on a natural path', () {
    testWidgets('Today offers a way to say a clinic is involved',
        (tester) async {
      logCleanHistory();
      expect(TtcStore.instance.path, TtcPath.natural);
      await pumpTall(tester, const TtcTodayScreen());
      expect(find.text('Having treatment?'), findsOneWidget,
          reason: 'there was no way to declare a pathway at all');
    });

    testWidgets('and it opens the treatment screen', (tester) async {
      logCleanHistory();
      await pumpTall(tester, const TtcTodayScreen());
      await tester.tap(find.text('Having treatment?'));
      await tester.pumpAndSettle();
      // 2026-09-26 (docs/TTC-TREATMENT-FLOW.md decision 2): the chooser is
      // commented out of the treatment screen; the start flow asks the kind
      // of round. The door still lands on the treatment screen, which opens
      // on "Starting treatment?". Kept for revert:
      //   expect(find.byType(TtcPathChooser), findsOneWidget);
      expect(find.byType(TtcTreatmentScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_start_treatment_card')),
          findsOneWidget);
    });
  });

  // ===========================================================================
  group('choosing a pathway actually reaches the store', () {
    testWidgets('every path can be selected', (tester) async {
      await pumpTall(tester, const TtcPathChooser());
      for (final path in TtcPath.values) {
        await tester.tap(find.text(path.label(false)));
        await tester.pumpAndSettle();
        expect(TtcStore.instance.path, path,
            reason: '${path.name} did not reach setPath');
      }
    });

    testWidgets('and it is reversible - a cycle can go back to natural',
        (tester) async {
      await pumpTall(tester, const TtcPathChooser());
      await tester.tap(find.text(TtcPath.ivf.label(false)));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TtcPath.natural.label(false)));
      await tester.pumpAndSettle();
      expect(TtcStore.instance.path, TtcPath.natural);
    });

    testWidgets('choosing natural does not read as an admission',
        (tester) async {
      await pumpTall(tester, const TtcPathChooser());
      // "No clinic involved this cycle" - a fact, not a shortfall.
      expect(find.text('No clinic involved this cycle'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('and the whole system wakes up behind it', () {
    testWidgets('declaring IVF suppresses the fertile window', (tester) async {
      logCleanHistory();
      expect(TtcStore.instance.today.fertility, isNotNull);

      await pumpTall(tester, const TtcPathChooser());
      await tester.tap(find.text(TtcPath.ivf.label(false)));
      await tester.pumpAndSettle();

      // 2026-09-26: the tap sets the label, and the label alone is her own
      // cycle; the first date from her clinic hands the timing over. Kept for
      // revert: the three expectations below held straight after the tap.
      expect(TtcStore.instance.path, TtcPath.ivf);
      expect(TtcStore.instance.today.clinicInvolved, isFalse);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);

      // This is the defect the design existed to fix, now actually reachable.
      expect(TtcStore.instance.today.fertility, isNull);
      expect(TtcStore.instance.today.estimatedOvulationDay, isNull);
      expect(TtcStore.instance.today.clinicInvolved, isTrue);
    });

    // 2026-09-26 (decision 2): the two questions are worked out from the
    // round's kind and trigger, and are no longer on the treatment screen.
    // The widget is kept (commented out of the screen) for revert. Kept for
    // revert: `expect(find.byType(TtcPathwayQuestions), findsOneWidget);`
    testWidgets('and the two questions are no longer asked', (tester) async {
      logCleanHistory();
      TtcStore.instance.setPath(TtcPath.iui);
      await pumpTall(tester, const TtcTreatmentScreen());
      expect(find.byType(TtcPathwayQuestions), findsNothing);
      expect(find.byKey(const ValueKey('ttc_start_treatment_card')),
          findsOneWidget);
    });

    // ⚠️ REPLACED 2026-09-26. Her answers now pick the tier once her clinic's
    // dates are in; they do not decide on their own whether the window shows.
    // Kept for revert:
    //
    // testWidgets('answering them can hand the window back', (tester) async {
    //   logCleanHistory();
    //   await pumpTall(tester, const TtcPathChooser());
    //   await tester.tap(find.text(TtcPath.iui.label(false)));
    //   await tester.pumpAndSettle();
    //   expect(TtcStore.instance.today.fertility, isNull,
    //       reason: 'the default is to withhold');
    //
    //   // Unmonitored, unmedicated: her body still owns the timing.
    //   TtcStore.instance
    //     ..setClinicMonitors(false)
    //     ..setMedicationControlsOvulation(false);
    //   expect(TtcStore.instance.today.fertility, isNotNull,
    //       reason: 'the middle tier is the whole point of the model');
    // });
    testWidgets('clearing her clinic dates hands the window back',
        (tester) async {
      logCleanHistory();
      await pumpTall(tester, const TtcPathChooser());
      await tester.tap(find.text(TtcPath.iui.label(false)));
      await tester.pumpAndSettle();
      expect(TtcStore.instance.today.fertility, isNotNull,
          reason: 'a label with no clinic dates is her own cycle');
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      expect(TtcStore.instance.today.fertility, isNull,
          reason: 'a clinic date for this cycle withholds it');
      TtcTreatmentStore.instance.clearCycle();
      expect(TtcStore.instance.today.fertility, isNotNull,
          reason: 'the round is over: her own cycle again');
    });

    test('the ownership tiers are all reachable from the chooser', () {
      // Every tier the model defines must be arrivable at through the UI, or
      // part of it is still dead code.
      TtcStore.instance.setPath(TtcPath.ivf);
      expect(TtcStore.instance.pathway.ownership,
          TimingOwnership.clinicControlled);

      TtcStore.instance
        ..setPath(TtcPath.frozenEmbryoTransfer)
        ..setClinicMonitors(true)
        ..setMedicationControlsOvulation(false);
      expect(TtcStore.instance.pathway.ownership, TimingOwnership.clinicGuided);

      TtcStore.instance
        ..setPath(TtcPath.natural)
        ..setClinicMonitors(false)
        ..setMedicationControlsOvulation(false);
      expect(TtcStore.instance.pathway.ownership, TimingOwnership.parentveda);
    });
  });
}
