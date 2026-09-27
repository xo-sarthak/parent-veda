// =============================================================================
//  Who owns the due date
// -----------------------------------------------------------------------------
//  A dating scan is more accurate than counting from a last period, and the
//  clinic owns the scan. Until now the app could not tell the two apart: it
//  stored a date and forgot where the date came from.
//
//  The failure this prevents is "my app says 9w2d, my doctor says 8w5d". Being
//  right afterwards does not buy back the trust that costs.
//
//  Same shape as the IVF fertility window, in the stage that has real users.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/tools/due_date_calculator_screen.dart';
import 'package:parentveda/services/journey_state.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/family_timeline.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_transition.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';
import 'package:parentveda/screens/ttc/ttc_transition_screen.dart'
    show TtcTransitionScreen;
import 'package:parentveda/screens/ttc/ttc_treatment_round_screens.dart'
    show TtcRoundPregnancyScreen, ttcDueDateText;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  const engine = JourneyStateEngine();

  // ===========================================================================
  group('which sources a clinic owns', () {
    test('a scan, a transfer and a doctor telling her', () {
      expect(DueDateSource.scan.clinicOwned, isTrue);
      expect(DueDateSource.ivfTransfer.clinicOwned, isTrue);
      expect(DueDateSource.clinician.clinicOwned, isTrue);
    });

    test('our own arithmetic is not', () {
      expect(DueDateSource.lastPeriod.clinicOwned, isFalse);
      expect(DueDateSource.conception.clinicOwned, isFalse);
    });

    test('unknown counts as ours, which is the safe way to be wrong', () {
      // Assuming a clinic gave a date we cannot account for would be the exact
      // wrong error: it would silence our estimate on no evidence, and later
      // make a real disagreement invisible.
      expect(DueDateSource.unknown.clinicOwned, isFalse);
    });
  });

  // ===========================================================================
  group('the calculator already knew - it just was not recording it', () {
    test('every method maps to a source', () {
      for (final m in DdcMethod.values) {
        expect(() => ddcSourceFor(m), returnsNormally, reason: '$m');
      }
    });

    test('ultrasound, IVF and "my doctor told me" are the clinic\'s', () {
      expect(ddcSourceFor(DdcMethod.ultrasound).clinicOwned, isTrue);
      expect(ddcSourceFor(DdcMethod.ivf).clinicOwned, isTrue);
      expect(ddcSourceFor(DdcMethod.known).clinicOwned, isTrue);
    });

    test('last period and conception are ours', () {
      expect(ddcSourceFor(DdcMethod.lmp).clinicOwned, isFalse);
      expect(ddcSourceFor(DdcMethod.conception).clinicOwned, isFalse);
    });
  });

  // ===========================================================================
  group('the controller carries it', () {
    test('a fresh controller has no source', () {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      expect(c.dueDateSource, DueDateSource.unknown);
      expect(c.dueDateFromClinic, isFalse);
    });

    test('setting a scan-derived date hands ownership over', () async {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10), source: DueDateSource.scan);
      expect(c.dueDateSource, DueDateSource.scan);
      expect(c.dueDateFromClinic, isTrue);
    });

    test('setting an LMP-derived date leaves it with us', () async {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10),
          source: DueDateSource.lastPeriod);
      expect(c.dueDateFromClinic, isFalse);
    });

    test('omitting the source does not silently claim a clinic gave it',
        () async {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10));
      expect(c.dueDateFromClinic, isFalse);
    });

    test('a later LMP date takes ownership back from a scan', () async {
      // She re-entered it herself. Whatever that means clinically, we must not
      // keep claiming a scan we no longer have.
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10), source: DueDateSource.scan);
      await c.setDueDate(DateTime(2027, 1, 14),
          source: DueDateSource.lastPeriod);
      expect(c.dueDateFromClinic, isFalse);
    });

    test('resetting clears the source too', () async {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10), source: DueDateSource.scan);
      await c.resetForTesting();
      expect(c.dueDateSource, DueDateSource.unknown);
    });

    test('the source is persisted under its own key', () async {
      SharedPreferences.setMockInitialValues({});
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10), source: DueDateSource.scan);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PregnancyController.kDueDateSourceKey),
          DueDateSource.scan.name);
    });
  });

  // ===========================================================================
  group('and the boundary finally has a writer', () {
    test('without a clinic date we may work out how far along she is', () {
      final s = engine.resolve(const JourneyInputs(stage: LifeStage.pregnancy));
      expect(s.mayInfer(Inferable.gestationalAge), isTrue);
    });

    test('with one, gestational age is theirs', () {
      final s = engine.resolve(const JourneyInputs(
          stage: LifeStage.pregnancy, dueDateFromClinic: true));
      expect(s.mayInfer(Inferable.gestationalAge), isFalse);
      expect(s.mustComeFromClinician(Inferable.gestationalAge), isTrue);
      expect(s.ownership, ClinicalOwnership.shared);
    });

    test('a real controller can answer the question the state asks', () async {
      // The wiring that was missing: something has to KNOW the date came from a
      // scan. Now the calculator records it and the controller reports it.
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10),
          source: ddcSourceFor(DdcMethod.ultrasound));
      final s = engine.resolve(JourneyInputs(
          stage: LifeStage.pregnancy, dueDateFromClinic: c.dueDateFromClinic));
      expect(s.mayInfer(Inferable.gestationalAge), isFalse);
    });

    test('and reports the other way round for a date we counted', () async {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10),
          source: ddcSourceFor(DdcMethod.lmp));
      final s = engine.resolve(JourneyInputs(
          stage: LifeStage.pregnancy, dueDateFromClinic: c.dueDateFromClinic));
      expect(s.mayInfer(Inferable.gestationalAge), isTrue);
    });
  });

  // ===========================================================================
  //  After treatment, the clinic dates it (2026-09-26, docs/TTC-TREATMENT-FLOW
  //  .md B8). CLAUDE.md: "a clinic-owned date is not ours to second-guess".
  //  IVF and frozen transfers are dated from the transfer day and the
  //  embryo's age, stored as the clinic's, and nothing recounts it after.
  // ===========================================================================
  group('a positive after treatment is dated by the clinic', () {
    final transfer = DateTime(2026, 10, 14, 11, 30);
    TtcTreatmentCycle ivf({int? embryo, TtcRoundKind kind = TtcRoundKind.ivfFresh}) =>
        TtcTreatmentCycle(
          dates: {
            TtcTreatmentStep.stimStart: DateTime(2026, 9, 26),
            TtcTreatmentStep.retrieval: DateTime(2026, 10, 9),
            TtcTreatmentStep.transfer: transfer,
            TtcTreatmentStep.betaTest: DateTime(2026, 10, 25),
          },
          kind: kind,
          embryoDay: embryo,
        );

    test('a day-5 transfer is transfer + 261, and the clinic owns it', () {
      final d = ttcRoundDating(ivf(embryo: 5),
          lastPeriod: DateTime(2026, 9, 24));
      expect(d.need, TtcRoundDatingNeed.ready);
      expect(d.due, DateTime(2026, 10, 14).add(const Duration(days: 261)));
      expect(d.source, DueDateSource.ivfTransfer);
      expect(d.source!.clinicOwned, isTrue);
      // Her last period is ignored after IVF: it is not the clinic's clock.
      expect(d.due, isNot(TtcTransitionEngine.dueDateFrom(DateTime(2026, 9, 24))));
    });

    test('a day-3 transfer is transfer + 263; frozen transfers the same', () {
      expect(ttcRoundDating(ivf(embryo: 3)).due,
          DateTime(2026, 10, 14).add(const Duration(days: 263)));
      for (final k in [TtcRoundKind.fetMedicated, TtcRoundKind.fetNatural]) {
        final d = ttcRoundDating(ivf(embryo: 5, kind: k));
        expect(d.due, DateTime(2026, 10, 14).add(const Duration(days: 261)),
            reason: k.name);
        expect(d.source, DueDateSource.ivfTransfer, reason: k.name);
      }
    });

    test('with no embryo day it asks, and never guesses one', () {
      final d = ttcRoundDating(ivf());
      expect(d.need, TtcRoundDatingNeed.embryoDay);
      expect(d.due, isNull);
      expect(ttcRoundDating(ivf(), embryoDay: 5).due,
          DateTime(2026, 10, 14).add(const Duration(days: 261)));
    });

    test('IUI and tablets: the last period, then the IUI or trigger day', () {
      final iui = TtcTreatmentCycle(dates: {
        TtcTreatmentStep.trigger: DateTime(2026, 10, 7, 21),
        TtcTreatmentStep.iui: DateTime(2026, 10, 9),
      }, kind: TtcRoundKind.iui);
      final lmp = DateTime(2026, 9, 24);
      final a = ttcRoundDating(iui, lastPeriod: lmp);
      expect(a.due, TtcTransitionEngine.dueDateFrom(lmp));
      expect(a.source, DueDateSource.lastPeriod);
      final b = ttcRoundDating(iui);
      expect(b.due, DateTime(2026, 10, 9).add(const Duration(days: 266)));
      expect(b.source, DueDateSource.conception);
      final oi = TtcTreatmentCycle(dates: {
        TtcTreatmentStep.trigger: DateTime(2026, 10, 7, 21),
      }, kind: TtcRoundKind.ovulationInduction);
      expect(ttcRoundDating(oi).due,
          DateTime(2026, 10, 8).add(const Duration(days: 266)));
      // Ours, so a dating scan can still update it on the pregnancy side.
      expect(b.source!.clinicOwned, isFalse);
    });

    test('with nothing to count from, no date is invented', () {
      final d = ttcRoundDating(const TtcTreatmentCycle(
          dates: {}, kind: TtcRoundKind.ivfFresh));
      expect(d.need, TtcRoundDatingNeed.noDate);
      expect(d.due, isNull);
    });

    test('the transition stores it as the clinic\'s, and nothing recounts it',
        () async {
      SharedPreferences.setMockInitialValues({});
      CycleStore.instance.resetForTest();
      TtcStore.instance.resetForTest();
      FamilyTimeline.instance.resetForTest();
      LifeStageStore.instance
        ..resetForTest()
        ..setStage(LifeStage.tryingToConceive);
      // A period logged well before: the old engine would have counted from it.
      CycleStore.instance.logPeriodStart(DateTime(2026, 9, 24));
      final d = ttcRoundDating(ivf(embryo: 5),
          lastPeriod: CycleStore.instance.lastPeriodStart);
      final result = await const TtcTransitionEngine().confirmPregnancy(
          on: DateTime(2026, 10, 25), dueDate: d.due, source: d.source);
      final want = DateTime(2026, 10, 14).add(const Duration(days: 261));
      expect(result.dueDate, want);
      expect(result.dueDateWasDerived, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(DateTime.parse(prefs.getString(PregnancyController.kDueDateKey)!),
          want);
      expect(prefs.getString(PregnancyController.kDueDateSourceKey),
          DueDateSource.ivfTransfer.name);

      // The pregnancy side reads it back as the clinic's, and never offers
      // to recount it.
      final c = PregnancyController(now: DateTime(2027, 2, 1));
      await c.load();
      expect(c.isDueDateSet, isTrue);
      expect(c.dueDate, want);
      expect(c.dueDateSource, DueDateSource.ivfTransfer);
      expect(c.dueDateFromClinic, isTrue);
      expect(c.dueDateMayBeStale, isFalse);
      final s = engine.resolve(JourneyInputs(
          stage: LifeStage.pregnancy, dueDateFromClinic: c.dueDateFromClinic));
      expect(s.mayInfer(Inferable.gestationalAge), isFalse);

      // Nothing on the TTC side rewrites it: a period logged later changes
      // no stored date.
      CycleStore.instance.logPeriodStart(DateTime(2026, 11, 20));
      final again = await SharedPreferences.getInstance();
      expect(DateTime.parse(again.getString(PregnancyController.kDueDateKey)!),
          want);
      expect(again.getString(PregnancyController.kDueDateSourceKey),
          DueDateSource.ivfTransfer.name);

      // Undo takes the date and its source away together.
      await const TtcTransitionEngine().undo();
      final after = await SharedPreferences.getInstance();
      expect(after.getString(PregnancyController.kDueDateKey), isNull);
      expect(after.getString(PregnancyController.kDueDateSourceKey), isNull);
    });

    test('"My clinic gave me a due date" is stored as the clinician\'s',
        () async {
      SharedPreferences.setMockInitialValues({});
      CycleStore.instance.resetForTest();
      TtcStore.instance.resetForTest();
      FamilyTimeline.instance.resetForTest();
      LifeStageStore.instance.resetForTest();
      final due = DateTime(2027, 6, 30);
      await const TtcTransitionEngine().confirmPregnancy(
          on: DateTime(2026, 10, 25),
          dueDate: due,
          source: DueDateSource.clinician);
      final c = PregnancyController(now: DateTime(2027, 1, 1));
      await c.load();
      expect(c.dueDate, due);
      expect(c.dueDateSource, DueDateSource.clinician);
      expect(c.dueDateMayBeStale, isFalse);
    });
  });

  // ===========================================================================
  //  Nothing moves silently (the user's rule, 2026-09-26): the screen names
  //  the date and what it counts from BEFORE she moves, a confirmation
  //  restates it, "Not yet" changes nothing, and the move can be undone.
  // ===========================================================================
  group('moving to Pregnancy is announced first', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      CycleStore.instance.resetForTest();
      TtcStore.instance.resetForTest();
      FamilyTimeline.instance.resetForTest();
      TtcTreatmentStore.instance.resetForTest();
      LifeStageStore.instance
        ..resetForTest()
        ..setStage(LifeStage.tryingToConceive);
    });
    tearDown(() => TtcTreatmentStore.instance.resetForTest());

    DateTime day(int n) {
      final t = DateTime.now();
      return DateTime(t.year, t.month, t.day + n);
    }

    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          const MaterialApp(home: TtcRoundPregnancyScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }

    void positiveRound({int? embryo}) {
      final store = TtcTreatmentStore.instance;
      store.startRound(kind: TtcRoundKind.ivfFresh, dates: {
        TtcTreatmentStep.stimStart: day(-30),
        TtcTreatmentStep.retrieval: day(-17),
        TtcTreatmentStep.transfer: day(-12),
        TtcTreatmentStep.betaTest: day(-1),
      });
      if (embryo != null) store.setEmbryoDay(embryo);
      store.closeRound(TtcRoundOutcome.positive);
    }

    testWidgets('the date and its basis are said, and "Not yet" changes nothing',
        (tester) async {
      positiveRound(embryo: 5);
      await pump(tester);
      final due = day(-12).add(const Duration(days: 261));
      expect(find.text('Date it from my transfer'), findsOneWidget);
      expect(find.textContaining('Due ${ttcDueDateText(due)}.'), findsOneWidget);
      expect(find.text('My clinic gave me a due date'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);

      await tester.tap(find.text('Date it from my transfer'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Move to Pregnancy?'), findsOneWidget);
      expect(find.textContaining(ttcDueDateText(due)), findsWidgets);
      expect(find.textContaining('You can undo this'), findsOneWidget);
      await tester.tap(find.text('Not yet'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(LifeStageStore.instance.stage, isNot(LifeStage.pregnancy),
          reason: 'nothing moves without her yes');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PregnancyController.kDueDateKey), isNull);

      // Yes: she moves, dated by the clinic, onto the screen with Undo.
      await tester.tap(find.text('Date it from my transfer'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Move to Pregnancy'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(TtcTransitionScreen), findsOneWidget);
      expect(LifeStageStore.instance.stage, LifeStage.pregnancy);
      final after = await SharedPreferences.getInstance();
      expect(DateTime.parse(after.getString(PregnancyController.kDueDateKey)!),
          due);
      expect(after.getString(PregnancyController.kDueDateSourceKey),
          DueDateSource.ivfTransfer.name);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('with no embryo day it asks first, and never guesses',
        (tester) async {
      positiveRound();
      await pump(tester);
      expect(find.text('Date it from my transfer'), findsNothing);
      expect(find.byKey(const ValueKey('ttc_to_preg_embryo_5')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_to_preg_embryo_3')));
      await tester.pump(const Duration(milliseconds: 300));
      final due = day(-12).add(const Duration(days: 263));
      expect(find.textContaining('Due ${ttcDueDateText(due)}.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
