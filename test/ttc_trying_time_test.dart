// =============================================================================
//  How long she has been trying (T1, 2026-10-27)
// -----------------------------------------------------------------------------
//  The user's option A: every month spent trying, leaving out the months she
//  was pregnant, said precisely, and changeable. Losses come from her records.
//  Spec: docs/preg-ttc-tool-plans/00-MASTER.md (TT1, TT2, TC3, TC5).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_ivf_readiness_screen.dart';
import 'package:parentveda/screens/ttc/ttc_intro_flow.dart' show TtcIntroGate;
import 'package:parentveda/screens/ttc/ttc_strings.dart' show TtcPartnerMode;
import 'package:parentveda/services/family_timeline.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_records.dart';
import 'package:parentveda/services/stage_moves.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_ivf_readiness.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_trying_time.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

/// Riya, from the plan: started in January, pregnant April to June, a loss,
/// trying again in July, and it is October.
TtcTryingTime riya({
  TtcTryingBasis? basis,
  DateTime? basisDate,
  List<TtcPregnancySpan>? pregnancies,
  DateTime? now,
}) =>
    ttcTryingTime(
      now: now ?? d(2025, 10, 15),
      defaultStart: d(2025, 1, 15),
      defaultSource: TtcTryingSource.stated,
      basis: basis,
      basisDate: basisDate,
      pregnancies:
          pregnancies ?? [(from: d(2025, 4, 1), to: d(2025, 6, 30))],
    );

PregnancyRecord _rec(String id, DateTime from, DateTime? to,
        PregnancyOutcome outcome) =>
    PregnancyRecord(
        id: id, startedOn: from, endedOn: to, outcome: outcome);

void main() {
  // ===========================================================================
  group('the count (option A)', () {
    test('with no pregnancy, every day from the start, and no "leaving out"', () {
      final t = riya(pregnancies: const []);
      expect(t.days, 273);
      expect(t.gaps, isEmpty);
      expect(t.line, 'Counted from January 2025.');
    });

    test('her pregnancy is left out, and the line names exactly which months', () {
      final t = riya();
      expect(t.days, 273 - 90);
      expect(t.label, 'about 6 months');
      expect(t.heading, 'About 6 months of trying');
      expect(t.line,
          'Counted from January 2025, leaving out April to June 2025, when you were pregnant.');
    });

    test('several pregnancies: each left out, overlaps merged, all named', () {
      final t = ttcTryingTime(
        now: d(2026, 6, 1),
        defaultStart: d(2024, 1, 1),
        defaultSource: TtcTryingSource.stated,
        pregnancies: [
          (from: d(2024, 3, 1), to: d(2024, 5, 1)),
          (from: d(2024, 4, 1), to: d(2024, 5, 20)),
          (from: d(2025, 2, 1), to: d(2025, 3, 15)),
        ],
      );
      expect(t.gaps.length, 2, reason: 'the first two overlap');
      expect(t.gaps.first.to, d(2024, 5, 20));
      expect(t.line,
          'Counted from January 2024, leaving out March to May 2024 and '
          'February to March 2025, when you were pregnant.');
    });

    test('a pregnancy that began before her start: only the overlap is left out', () {
      final t = ttcTryingTime(
        now: d(2025, 10, 1),
        defaultStart: d(2025, 5, 1),
        defaultSource: TtcTryingSource.stated,
        pregnancies: [(from: d(2025, 1, 1), to: d(2025, 6, 1))],
      );
      expect(t.gaps.single.from, d(2025, 5, 1));
      expect(t.days, 153 - 31);
    });

    test('an end the app was never told: not left out, and the line says so', () {
      final t = riya(pregnancies: [(from: d(2025, 4, 1), to: null)]);
      expect(t.days, 273, reason: 'counting it leans toward the conversation');
      expect(t.unknownEnd, isTrue);
      expect(t.line, contains("We couldn't tell when one pregnancy ended"));
    });

    test('"Since I started again" counts from that day', () {
      final t = riya(basis: TtcTryingBasis.again, basisDate: d(2025, 7, 1));
      expect(t.days, 106);
      expect(t.label, 'about 3 months');
      expect(t.line, 'Counted from 1 July 2025, when you started trying again.');
    });

    test('"From a different date" still leaves out pregnancy inside it', () {
      final t = riya(basis: TtcTryingBasis.own, basisDate: d(2025, 3, 1));
      expect(t.source, TtcTryingSource.own);
      expect(t.gaps, isNotEmpty);
      expect(t.line, startsWith('Counted from 1 March 2025, the date you chose, leaving out'));
    });

    test('a planned month still to come: not started, no count', () {
      final t = ttcTryingTime(
          now: d(2025, 10, 1),
          defaultStart: d(2026, 1, 1),
          defaultSource: TtcTryingSource.stated);
      expect(t.plannedAhead, isTrue);
      expect(t.days, 0);
      expect(t.line, 'You plan to start in January 2026.');
    });

    test('a start that is only a guess offers "Add when you really started"', () {
      for (final s in [TtcTryingSource.answer, TtcTryingSource.joined]) {
        final t = ttcTryingTime(
            now: d(2025, 10, 1), defaultStart: d(2025, 4, 1), defaultSource: s);
        expect(t.startIsAGuess, isTrue, reason: '$s');
      }
      expect(riya().startIsAGuess, isFalse);
    });

    test('the published start gives the same days with nothing left out', () {
      final t = riya();
      final his = ttcTryingTime(
          now: d(2025, 10, 15),
          defaultStart: t.effectiveStart,
          defaultSource: TtcTryingSource.partner);
      expect(his.days, t.days);
      expect(his.line, contains('the same as on her phone'));
      expect(his.line, isNot(contains('pregnant')),
          reason: 'her pregnancy dates never reach his phone');
    });

    test('never a probability, never a raw day count', () {
      for (final t in [riya(), riya(pregnancies: const [])]) {
        expect('${t.heading} ${t.line}', isNot(contains('%')));
        expect('${t.heading} ${t.line}', isNot(contains('days')));
        expect('${t.heading} ${t.line}'.toLowerCase(), isNot(contains('chance')));
      }
    });
  });

  // ===========================================================================
  group('the store: one number, everywhere', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      LifeStageStore.instance.resetForTest();
      TtcStore.instance.resetForTest();
      TtcPartnerMode.instance.on = false;
    });
    tearDown(() => PregnancyRecords.instance.debugReset());

    test('daysTrying leaves her ended pregnancies out; an ongoing or deleted one is not counted', () {
      final now = DateTime.now();
      final start = DateTime(now.year - 1, now.month, now.day);
      TtcStore.instance.setJourneyStart(start);
      final full = TtcStore.instance.daysTrying!;
      PregnancyRecords.instance.debugReset(rows: [
        _rec('a', start.add(const Duration(days: 30)),
            start.add(const Duration(days: 90)), PregnancyOutcome.loss),
        _rec('b', start.add(const Duration(days: 200)), null,
            PregnancyOutcome.ongoing),
      ]);
      expect(TtcStore.instance.daysTrying, full - 60);
      expect(TtcFertilityHelpStore.instance.context.daysTrying, full - 60,
          reason: 'the doctor check reads the same number');
      // A deleted record is not in `all`, so it is not counted.
      PregnancyRecords.instance.debugReset();
      expect(TtcStore.instance.daysTrying, full);
    });

    test('her Change pick is saved, and "first" goes back to the default', () async {
      final now = DateTime.now();
      TtcStore.instance.setJourneyStart(DateTime(now.year - 1, now.month, now.day));
      final again = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 40));
      TtcStore.instance.setTryingBasis(TtcTryingBasis.again, date: again);
      expect(TtcStore.instance.daysTrying, 40);
      final prefs = await SharedPreferences.getInstance();
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString('ttc_trying_count_from'), 'again');
      TtcStore.instance.setTryingBasis(TtcTryingBasis.first);
      expect(TtcStore.instance.tryingBasis, isNull);
      expect(TtcStore.instance.daysTrying, greaterThan(360));
    });

    test('his phone shows her published start, never his own', () {
      TtcPartnerMode.instance.on = true;
      expect(TtcStore.instance.tryingTime?.source, isNot(TtcTryingSource.partner),
          reason: 'before her row arrives he falls back to his own phone');
      TtcPartnerMode.instance.on = false;
    });
  });

  // ===========================================================================
  group('losses come from her records (TT2)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      TtcFertilityHelpStore.instance.reset();
    });
    tearDown(() => PregnancyRecords.instance.debugReset());

    IvfReadinessAnswers safe() => IvfReadinessAnswers()
      ..age = FertilityAgeBand.under35
      ..trying = IvfTrying.underSix
      ..cycles = IvfCycles.regular
      ..conditionsChecked = true
      ..semen = IvfSemen.normal
      ..check = IvfCheck.no;
    const ctx = FertilityHelpContext();

    test('one loss is not a flag, and is said kindly', () {
      final a = safe()
        ..recordedLosses = 1
        ..lossesBefore = IvfLossesBefore.none;
      final r = ivfBuildReadiness(a, ctx);
      expect(r.verdict, IvfVerdict.keepTrying);
      expect(r.where, contains(kIvfOneLossLine));
    });

    test('two losses (records plus before) talk to a doctor now, in a whole sentence', () {
      final a = safe()
        ..recordedLosses = 1
        ..lossesBefore = IvfLossesBefore.one;
      final r = ivfBuildReadiness(a, ctx);
      expect(r.verdict, IvfVerdict.flagged);
      expect(r.timing, contains("because you've had two or more pregnancy losses."));
    });

    test('one on record and the earlier ones unanswered does not reassure', () {
      final a = safe()..recordedLosses = 1;
      expect(ivfBuildReadiness(a, ctx).verdict, isNot(IvfVerdict.keepTrying));
    });

    test('a saved "A previous miscarriage" tick becomes one loss, not dropped', () {
      final a = safe()..conditions = {'miscarriage'};
      a.absorbLegacyMiscarriage();
      expect(a.conditions, isEmpty);
      expect(a.lossesBefore, IvfLossesBefore.one);
      final withRecord = safe()
        ..conditions = {'miscarriage'}
        ..recordedLosses = 1;
      withRecord.absorbLegacyMiscarriage();
      expect(withRecord.lossesBefore, isNull,
          reason: 'her record already holds that loss');
    });

    test('the reasons read as sentences', () {
      final a = safe()..conditions = {'pcos'};
      expect(ivfBuildReadiness(a, ctx).timing, contains('because you have PCOS.'));
    });

    test('the notes carry a losses line', () {
      final a = safe()
        ..recordedLosses = 1
        ..lossesBefore = IvfLossesBefore.one;
      final row = ivfBuildReadiness(a, ctx)
          .checklist
          .firstWhere((r) => r.label == 'Pregnancy losses');
      expect(row.value, '2 (1 on record, 1 before)');
    });

    test('the engine counts recorded losses, and an old tick no longer fires known_condition', () async {
      final help = TtcFertilityHelpStore.instance;
      PregnancyRecords.instance.debugReset(rows: [
        _rec('a', d(2024, 1, 1), d(2024, 3, 1), PregnancyOutcome.loss),
        _rec('b', d(2024, 6, 1), d(2024, 8, 1), PregnancyOutcome.loss),
        _rec('c', d(2023, 1, 1), d(2023, 10, 1), PregnancyOutcome.birth),
      ]);
      await help.answer('conditions', 'miscarriage');
      expect(help.recordedLosses, 2, reason: 'a birth is not a loss');
      expect(help.context.priorMiscarriages, 2);
      final ids = firedRules(help.context).map((r) => r.id);
      expect(ids, contains('two_miscarriages'));
      expect(ids, isNot(contains('known_condition')));
    });

    test('an answer about the time before ParentVeda adds to her records', () async {
      final help = TtcFertilityHelpStore.instance;
      PregnancyRecords.instance.debugReset(rows: [
        _rec('a', d(2024, 1, 1), d(2024, 3, 1), PregnancyOutcome.loss),
      ]);
      await help.answer('losses_before_app', '1');
      expect(help.priorLosses, 2);
    });
  });

  // ===========================================================================
  group('trying again from the family side (TC5)', () {
    final today = d(2026, 10, 27);
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      LifeStageStore.instance.resetForTest();
      TtcStore.instance.resetForTest();
      FamilyTimeline.instance.resetForTest();
      await TtcIntroGate.resetForTest();
      TtcStore.instance.setJourneyStart(d(2021, 1, 1));
      LifeStageStore.instance.setStage(LifeStage.parenting, at: d(2022, 3, 1));
    });

    test('counts from the day of the move, and the undo puts her pick back', () async {
      TtcStore.instance.setTryingBasis(TtcTryingBasis.own, date: d(2021, 2, 1));
      await startTryingFromFamily(today: today);
      expect(TtcStore.instance.tryingBasis, TtcTryingBasis.again);
      expect(TtcStore.instance.tryingBasisDate, today);
      await undoTryingFromFamily();
      expect(TtcStore.instance.tryingBasis, TtcTryingBasis.own);
      expect(TtcStore.instance.tryingBasisDate, d(2021, 2, 1));
    });
  });

  // ===========================================================================
  group('the labels and the wiring', () {
    test('TC3: the twelve-month rule says under 35, as it fires', () {
      final r = kFertilityHelpRules.firstWhere((r) => r.id == 'twelve_months');
      expect(r.trigger, 'Twelve months of trying, under 35');
    });

    test('every reader of "how long" goes through the one count', () {
      String src(String p) => File(p).readAsStringSync();
      expect(src('lib/ttc/ttc_messages_store.dart'), contains('store.tryingTime'));
      expect(src('lib/screens/ttc/ttc_askveda_screen.dart'),
          contains('s.tryingTime?.months'));
      expect(src('lib/screens/profile/pv_you_content.dart'),
          contains('TtcStore.instance.tryingTime'));
      expect(src('lib/screens/ttc/ttc_precheck_summary.dart'),
          contains('TtcStore.instance.tryingTime'));
      expect(src('lib/ttc/ttc_store.dart'),
          contains('int? get daysTrying => tryingTime?.days;'));
    });

    test('the store pushes the start she gave, not a fallback', () {
      final s = File('lib/ttc/ttc_store.dart').readAsStringSync();
      expect(s, contains('final start = _journeyStart;'));
      expect(s, contains("'trying_effective_start':"));
      // §16ww: a key the server may lack is sent only when it carries
      // something, so the row keeps syncing before 0117 runs.
      expect(s, contains('if (_countFrom != null || _cloudHasCount)'));
      expect(s, contains('if (sendEffective || _cloudHasEffective)'));
    });
  });

  // ===========================================================================
  group('the screen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      LifeStageStore.instance.resetForTest();
      TtcStore.instance.resetForTest();
      TtcFertilityHelpStore.instance.reset();
    });
    tearDown(() => PregnancyRecords.instance.debugReset());

    testWidgets('the losses question asks only about before ParentVeda when one is on record',
        (tester) async {
      PregnancyRecords.instance.debugReset(rows: [
        _rec('a', d(2025, 1, 1), d(2025, 3, 1), PregnancyOutcome.loss),
      ]);
      TtcStore.instance.setJourneyStart(d(2024, 9, 1));
      await tester.pumpWidget(const MaterialApp(home: TtcIvfReadinessScreen()));
      await tester.pump();
      // Walk the list, as the readiness test does, noting what passes by.
      var line = false, losses = false, oneMore = false;
      for (var i = 0; i < 14; i++) {
        line |= find.byKey(const ValueKey('ttc_trying_line')).evaluate().isNotEmpty;
        losses |= find
            .text('Any pregnancy losses before you used ParentVeda?')
            .evaluate()
            .isNotEmpty;
        oneMore |= find.text('One more').evaluate().isNotEmpty;
        await tester.drag(find.byType(ListView).first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 60));
        expect(tester.takeException(), isNull);
      }
      expect(line, isTrue, reason: 'the count and its Change sit under Q2');
      expect(losses, isTrue);
      expect(oneMore, isTrue);
    });
  });
}
