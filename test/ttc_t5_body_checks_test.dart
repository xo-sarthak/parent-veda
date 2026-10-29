// =============================================================================
//  T5 — TTC body checks (2026-10-29)
// -----------------------------------------------------------------------------
//  docs/preg-ttc-tool-plans/T5-body-checks.md. One test per finding the plan
//  lists for this file: the red flags and their near-misses (S1, S2, S3),
//  Done's line (S6), the numbers she typed (BW1, BW2, BW4-BW6, BW8), the PCOS
//  check (PC1-PC7), the BMI context (BW3, BW7, PC5, the clinic line, PH3),
//  the couple (Q1: the share store, the query the store keeps, the partner
//  filter), the router's gate (S4/D5) and focus (S5), and the wiring gate.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_partner_log_view.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/screens/ttc/ttc_symptom_log_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tracker_screen.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_bmi_rules.dart';
import 'package:parentveda/ttc/ttc_bmi_store.dart';
import 'package:parentveda/ttc/ttc_log_share_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_pcos_check_rules.dart';
import 'package:parentveda/ttc/ttc_pcos_check_store.dart' show TtcPcosCheckStore;
import 'package:parentveda/ttc/ttc_pcos_stand.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';
import 'package:parentveda/ttc/ttc_symptom_flags.dart';
import 'package:parentveda/ttc/ttc_trackers_data.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _ago(int n) {
  final t = _today();
  return DateTime(t.year, t.month, t.day - n);
}

String _src(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// The source with every comment line dropped, so a "kept for revert" line
/// never counts as a call site.
String _live(String path) => _src(path)
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void _chip(String id, DateTime day) =>
    TtcLogStore.instance.log(kTtcSymptomTracker, id, 1, on: day);

TtcSymptomFlag? _flagOn(DateTime day,
        {List<DateTime> starts = const [],
        int usual = 28,
        TtcTreatmentCycle? round}) =>
    ttcSymptomFlag(day,
        logs: TtcLogStore.instance,
        periodStarts: starts,
        usualCycleLength: usual,
        round: round);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcLogStore.instance.resetForTest();
    CycleStore.instance.resetForTest();
    TtcPcosCheckStore.instance.reset();
    TtcBmiStore.instance.resetForTest();
    TtcLogShareStore.instance.resetForTest();
    TtcPartnerMode.instance.on = false;
    FamilyProfileStore.instance.setDob(null);
  });

  // ===========================================================================
  group('S1: the red flags fire on their pattern, never on a near-miss', () {
    test('ectopic: pain and spotting after a positive test', () {
      final d = _today();
      _chip('pt_positive', _ago(3));
      _chip('pelvic_pain', d);
      _chip('disch_spotting', d);
      expect(_flagOn(d), TtcSymptomFlag.ectopic);
    });

    test('ectopic: pain and spotting with a period 7 or more days late', () {
      final d = _today();
      _chip('pelvic_pain', d);
      _chip('disch_spotting', d);
      expect(_flagOn(d, starts: [_ago(35)], usual: 28), TtcSymptomFlag.ectopic);
      expect(_flagOn(d, starts: [_ago(34)], usual: 28), isNull,
          reason: '6 days late is not 7');
    });

    test('near-misses: pain alone, spotting alone, a test with no pain', () {
      final d = _today();
      _chip('pt_positive', d);
      expect(_flagOn(d), isNull, reason: 'a positive test alone');
      _chip('pelvic_pain', d);
      expect(_flagOn(d), isNull, reason: 'pain with no bleeding');
      TtcLogStore.instance.clear(kTtcSymptomTracker, 'pelvic_pain', on: d);
      _chip('disch_spotting', d);
      expect(_flagOn(d), isNull, reason: 'spotting with no pain');
    });

    test('a positive test more than 14 days back does not count', () {
      final d = _today();
      _chip('pt_positive', _ago(14));
      _chip('pelvic_pain', d);
      _chip('disch_spotting', d);
      expect(_flagOn(d), isNull);
    });

    test('OHSS: bloating, nausea and pain after egg collection', () {
      final d = _today();
      for (final c in ['bloating', 'nausea', 'cramping']) {
        _chip(c, d);
      }
      final round = TtcTreatmentCycle(dates: {
        TtcTreatmentStep.stimStart: _ago(14),
        TtcTreatmentStep.retrieval: _ago(2),
      }, kind: TtcRoundKind.ivfFresh);
      expect(_flagOn(d, round: round), TtcSymptomFlag.ohss);
    });

    test('OHSS near-misses: no open round, before collection, a closed round',
        () {
      final d = _today();
      for (final c in ['bloating', 'nausea', 'pelvic_pain']) {
        _chip(c, d);
      }
      expect(_flagOn(d), isNull, reason: 'no round at all');
      final early = TtcTreatmentCycle(dates: {
        TtcTreatmentStep.stimStart: _ago(5),
        TtcTreatmentStep.retrieval: _ago(-3),
      });
      expect(_flagOn(d, round: early), isNull, reason: 'before collection');
      final closed = TtcTreatmentCycle(dates: {
        TtcTreatmentStep.stimStart: _ago(14),
        TtcTreatmentStep.retrieval: _ago(2),
      }, closedOn: _ago(1));
      expect(_flagOn(d, round: closed), isNull, reason: 'a closed round');
    });
  });

  // ===========================================================================
  group('S3: fever', () {
    TtcTreatmentCycle open() => TtcTreatmentCycle(
        dates: {TtcTreatmentStep.stimStart: _ago(5)}, kind: TtcRoundKind.ivfFresh);

    test('38.0 or above on an open round', () {
      final d = _today();
      TtcLogStore.instance.log('bbt', 'celsius', 38.0, on: d);
      expect(_flagOn(d, round: open()), TtcSymptomFlag.fever);
    });

    test('37.9 on a round, or 38.5 with no round, stays a record', () {
      final d = _today();
      TtcLogStore.instance.log('bbt', 'celsius', 37.9, on: d);
      expect(_flagOn(d, round: open()), isNull);
      TtcLogStore.instance.log('bbt', 'celsius', 38.5, on: d);
      expect(_flagOn(d), isNull, reason: 'BBT is her normal use');
    });

    test('Unwell with a fever in the wait after a transfer, round closed', () {
      final d = _today();
      TtcLogStore.instance.log('bbt', 'celsius', 38.2, on: d);
      _chip('illness', d);
      final closed = TtcTreatmentCycle(
          dates: {TtcTreatmentStep.transfer: _ago(4)}, closedOn: _ago(1));
      expect(_flagOn(d, round: closed), TtcSymptomFlag.fever);
    });

    test('every card says who to call, in the plan\'s words', () {
      expect(ttcSymptomFlagText(TtcSymptomFlag.ectopic),
          contains('early pregnancy unit today'));
      expect(ttcSymptomFlagText(TtcSymptomFlag.ohss),
          contains('get urgent help (112)'));
      expect(ttcSymptomFlagText(TtcSymptomFlag.fever),
          'A temperature of 38 or above during treatment is worth a call to '
          'your clinic today.');
    });
  });

  // ===========================================================================
  group('S2: two heavy weeks', () {
    void lowOn(int days) {
      for (var i = 0; i < days; i++) {
        _chip(i.isEven ? 'low' : 'tearful', _ago(i));
      }
    }

    test('8 of 14 days fires, 7 does not', () {
      lowOn(7);
      expect(ttcLowMoodDue(TtcLogStore.instance, _today(), null), isFalse);
      _chip('anxious', _ago(10));
      expect(ttcLowMoodDue(TtcLogStore.instance, _today(), null), isTrue);
    });

    test('once a week: stays the day it shows, then waits 7 days', () {
      lowOn(9);
      final log = TtcLogStore.instance;
      expect(ttcLowMoodDue(log, _today(), _today()), isTrue,
          reason: 'the same day it first showed');
      expect(ttcLowMoodDue(log, _today(), _ago(3)), isFalse);
      expect(ttcLowMoodDue(log, _today(), _ago(7)), isTrue);
    });

    test('the line names a free number and no condition', () {
      expect(kTtcLowMoodLine, contains('14416'));
      expect(kTtcLowMoodLine.toLowerCase(), isNot(contains('depress')));
    });
  });

  // ===========================================================================
  group('S6: Done says what this visit changed', () {
    test('added and removed', () {
      expect(ttcLogVisitLine(added: 2, removed: 1, dayName: 'Today'),
          '2 added, 1 removed for today');
      expect(ttcLogVisitLine(added: 0, removed: 1, dayName: 'Today'),
          '1 removed for today',
          reason: 'it speaks when she only removed things');
      expect(ttcLogVisitLine(added: 0, removed: 0), isNull);
    });
  });

  // ===========================================================================
  group('S4/D5 and S5: the router', () {
    test('his phone gets her private note, hers gets her tools', () {
      expect(ttcScreenForSurface('ttc_symptom_log'),
          isA<TtcSymptomLogScreen>());
      TtcPartnerMode.instance.on = true;
      expect(ttcScreenForSurface('ttc_symptom_log'), isA<TtcHerPrivateNote>());
      expect(ttcScreenForSurface('ttc_pcos_check'), isA<TtcHerPrivateNote>());
      expect(ttcScreenForSurface('ttc_symptom_log/measurements'),
          isA<TtcHerPrivateNote>());
      expect(ttcInlineToolFor('ttc_pcos_check'), isA<TtcHerPrivateNoteBody>());
    });

    test('a labelled entry opens on its card; an unknown card opens nothing',
        () {
      final w = ttcScreenForSurface('ttc_symptom_log/measurements');
      expect(w, isA<TtcSymptomLogScreen>());
      expect((w! as TtcSymptomLogScreen).focusGroup, 'measurements');
      expect(
          (ttcScreenForSurface('ttc_symptom_log/pregnancy_test')!
                  as TtcSymptomLogScreen)
              .focusGroup,
          'pregnancy_test');
      expect(ttcScreenForSurface('ttc_symptom_log/nope'), isNull);
    });

    test('the two labels name the card', () {
      expect(_live('lib/screens/ttc/ttc_journey_map_screen.dart'),
          contains("surface: 'ttc_symptom_log/measurements'"));
      expect(_live('lib/screens/ttc/chats/ttc_should_test_chat.dart'),
          contains("['ttc_symptom_log/pregnancy_test']"));
    });
  });

  // ===========================================================================
  group('BW1, BW2: units', () {
    test('62.0 kg toggled reads 136.7 lb, and the BMI is unchanged', () {
      final lb = bmiConvertWeight(62.0, toKg: false);
      expect(lb.toStringAsFixed(1), '136.7');
      final kgBmi = calculateBmi(const BmiInput(
          heightUnit: BmiHeightUnit.cm,
          weightUnit: BmiWeightUnit.kg,
          cm: 165,
          kg: 62.0))!;
      final lbBmi = calculateBmi(BmiInput(
          heightUnit: BmiHeightUnit.cm,
          weightUnit: BmiWeightUnit.lb,
          cm: 165,
          lb: double.parse(lb.toStringAsFixed(1))))!;
      expect(lbBmi.display, kgBmi.display);
    });

    test('the toggles convert, not just relabel', () {
      final s = _live('lib/screens/ttc/ttc_bmi_screen.dart');
      expect(s, contains('onTap: _switchWeight'));
      expect(s, contains('onTap: _switchHeight'));
    });

    test('182 cm is 6 ft 0 in; no height ever prefills 12 inches', () {
      expect(bmiFeetInches(1.82), (6, 0));
      for (var cm = 120; cm <= 220; cm++) {
        final (_, inch) = bmiFeetInches(cm / 100);
        expect(inch, inInclusiveRange(0, 11), reason: '$cm cm');
      }
    });
  });

  // ===========================================================================
  group('BW4-BW6, BW8, BW9: the numbers she typed', () {
    final weight = ttcTrackerById('weight')!;
    final kg = weight.fields.single;

    test('text that will not parse, or a number out of range, saves nothing',
        () {
      expect(ttcNumberError(kg, '62..5', weight: true), isNotNull);
      expect(ttcNumberError(kg, '.', weight: true), isNotNull);
      expect(ttcNumberError(kg, '250', weight: true),
          'That looks like a mis-tap: weights here are 30 to 200 kg');
      expect(ttcNumberError(kg, '25', weight: true), isNotNull);
      expect(ttcNumberError(kg, '62.5', weight: true), isNull);
    });

    test('the saves say what changed', () {
      expect(ttcWeightSavedLine(62.5, null, _today()), '62.5 kg saved for today');
      expect(ttcWeightSavedLine(62.5, 62.0, _today()),
          '62.5 kg saved for today (changed from 62.0)');
      expect(ttcWeightRemovedLine(_today()), 'Weight removed for today');
      expect(ttcBmiSavedLine('62.0 kg'),
          'Saved. 62.0 kg added to your Weight log for today.');
    });

    test('BW6: the first tap starts from her weight, never from 30', () async {
      expect(ttcWeightStart(weight, kg), isNull,
          reason: 'nothing held: the screen opens the sheet');
      await TtcBmiStore.instance.save(
          const BmiCalculation(bmi: 22.8, metres: 1.65, kilograms: 62.0));
      expect(ttcWeightStart(weight, kg), 62.0);
      TtcLogStore.instance.log('weight', 'kg', 63.5, on: _ago(2));
      expect(ttcWeightStart(weight, kg), 63.5);
      expect(_live('lib/screens/ttc/ttc_tracker_screen.dart'),
          contains('_showTypeSheet(context, tracker, field, day, current);'));
    });

    test('BW8: a BMI save logs the weight; a newer weight moves the row',
        () async {
      expect(_live('lib/screens/ttc/ttc_bmi_screen.dart'),
          contains('kTtcWeightTracker, kTtcWeightField, calc.kilograms'));
      await TtcBmiStore.instance.rememberHeight(1.65);
      TtcLogStore.instance.log('weight', 'kg', 68.0, on: _today());
      expect(ttcBmiFromLatestWeight()!.toStringAsFixed(1), '25.0');
    });
  });

  // ===========================================================================
  group('BW3, BW7, PC5, the clinic line, PH3: the BMI reading', () {
    const calc = BmiCalculation(bmi: 26.0, metres: 1.6, kilograms: 66.6);

    test('pregnant or under 18 refuses a category', () {
      expect(interpretBmi(calc, const BmiContext(isPregnant: true)).interpreted,
          isFalse);
      expect(interpretBmi(calc, const BmiContext(isMinor: true)).interpreted,
          isFalse);
      final s = _live('lib/screens/ttc/ttc_bmi_screen.dart');
      expect(s, contains('isPregnant: TtcStore.instance.pregnancyConfirmed'));
      expect(s, contains('isMinor: (FamilyProfileStore.instance.age ?? 99) < 18'));
    });

    test('BW7: NICE is no longer said to use 25', () {
      final e = kBmiStandardsExplainer.en;
      expect(e, contains('The NHS uses 27.5 for obesity in South Asian adults'));
      expect(e, isNot(contains('NICE all')));
    });

    test('PC5: no "pattern" from a check that promises no verdict', () {
      final r = interpretBmi(calc, const BmiContext(hasPcosPattern: true));
      expect(r.contextNote!.en,
          startsWith('Your PCOS check noted some signs worth raising.'));
    });

    test('the clinic line shows only on a clinic path', () {
      expect(interpretBmi(calc, const BmiContext()).clinicNote, isNull);
      expect(
          interpretBmi(calc, const BmiContext(onClinicPath: true))
              .clinicNote!
              .en,
          kBmiClinicPathLine);
    });

    test('PH3: his reading, his line, no pregnancy guard', () {
      final r = interpretBmi(
          calc, const BmiContext(forHim: true, isPregnant: true));
      expect(r.interpreted, isTrue);
      expect(r.himNote!.en, kBmiHisLine);
      expect(r.clinicNote, isNull);
    });
  });

  // ===========================================================================
  group('PC1-PC7: the PCOS check', () {
    const noLogs = PcosCycleFacts(
        regularity: PcosRegularity.notEnoughData,
        completedCycles: 0,
        longestGapDays: null);

    test('PC1: her "yes" reaches her result with no logs', () {
      final a = PcosStandAnswers()..longGaps = PcosYesNo.yes;
      final r = pcosBuildStand(a, facts: noLogs);
      expect(r.cycleLine, startsWith('You said'));
      expect(r.nudge, isNotNull);
      expect(r.checklist[1].value,
          'You said: 3 months or more without a period');
    });

    test('PC2: clear takes the shared answers and the date; Undo puts back',
        () async {
      await (PcosStandAnswers()
            ..acne = PcosDegree.mild
            ..trying = PcosTrying.underSix)
          .writeThrough();
      await TtcPcosCheckStore.instance.answer('q_eval_result', 'pcos');
      final store = TtcPcosCheckStore.instance;
      expect(store.hasCompleted, isTrue);
      final taken = await store.takeAnswers(kPcosStandQids);
      expect(store.answerFor('q_acne'), isNull);
      expect(store.hasCompleted, isFalse);
      expect(store.answerFor('q_eval_result'), 'pcos',
          reason: 'the older check\'s answers are not the short check\'s');
      await store.putBack(taken.$1, taken.$2);
      expect(store.answerFor('q_acne'), 'sometimes');
      expect(store.hasCompleted, isTrue);
    });

    test('PC3: un-ticking on a retake removes the old answer', () async {
      await (PcosStandAnswers()..acne = PcosDegree.mild).writeThrough();
      expect(TtcPcosCheckStore.instance.answerFor('q_acne'), 'sometimes');
      await PcosStandAnswers().writeThrough();
      expect(TtcPcosCheckStore.instance.answerFor('q_acne'), isNull);
    });

    test('PC4: the pill question writes q_contraception and the engine caps',
        () async {
      final a = PcosStandAnswers()..contraception = PcosContraception.yes;
      await a.writeThrough();
      final store = TtcPcosCheckStore.instance;
      expect(store.answerFor('q_contraception'), 'yes');
      expect(interpretPcos(store.answers).cappedByContext, isTrue);
      expect(pcosBuildStand(a, facts: noLogs).capped, kPcosCappedBody);
      expect(
          pcosBuildStand(PcosStandAnswers(), facts: noLogs).capped, isNull);
      await (PcosStandAnswers()..contraception = PcosContraception.stopped)
          .writeThrough();
      expect(store.answerFor('q_contraception'), 'stopped');
    });

    test('PC6: the fast-change line is on every result', () {
      expect(pcosBuildStand(PcosStandAnswers(), facts: noLogs).fastChange,
          kPcosFastChangeLine);
    });

    test('PC7: a long gap from years ago no longer keeps the nudge on', () {
      // One 151-day gap three years ago, then a period every 28 days since.
      final now = _today();
      CycleStore.instance.logPeriodStart(DateTime(now.year - 3, 1, 1));
      var d = DateTime(now.year - 3, 6, 1);
      while (d.isBefore(now)) {
        CycleStore.instance.logPeriodStart(d);
        d = DateTime(d.year, d.month, d.day + 28);
      }
      final f = pcosCycleFacts();
      expect(f.longestGapDays, greaterThan(90));
      expect(f.hasLongGap, isFalse);
    });

    test('PC11: family history is in her notes', () {
      final r = pcosBuildStand(PcosStandAnswers()..family = PcosFamily.yes,
          facts: noLogs);
      expect(r.checklist.last.label, 'PCOS in my family');
    });
  });

  // ===========================================================================
  group('Q1: sharing, by her own choice', () {
    test('only the two habit logs can be shared', () {
      final s = TtcLogShareStore.instance;
      s.set('symptoms', true);
      expect(s.sharedFor('symptoms'), isNull);
      s.set('habits', true);
      expect(s.sharedFor('habits'), isTrue);
      expect(kTtcShareableTrackers, {'partner_health', 'habits'});
    });

    test('the row is 0131\'s, and the newer answer wins on a pull', () {
      final s = TtcLogShareStore.instance;
      s.set('habits', true, now: DateTime.utc(2026, 10, 29, 10));
      expect(
          TtcLogShareStore.rowFor('me', 'habits', true, DateTime.utc(2026))
              .keys,
          ['user_id', 'tracker', 'shared', 'updated_at']);
      s.applyOwnRows([
        {'tracker': 'habits', 'shared': false, 'updated_at': '2026-10-28T00:00:00Z'},
      ]);
      expect(s.sharedFor('habits'), isTrue, reason: 'an older cloud row loses');
      s.applyOwnRows([
        {'tracker': 'habits', 'shared': false, 'updated_at': '2026-10-30T00:00:00Z'},
      ]);
      expect(s.sharedFor('habits'), isFalse);
    });

    test('her store still pulls her own rows only', () {
      final pull = _live('lib/ttc/ttc_log_store.dart');
      final i = pull.indexOf('Future<void> pullFromCloud()');
      final body = pull.substring(i, pull.indexOf('\n  }\n', i));
      expect(body, contains('SupabaseRepo.fetch(TtcTables.logs'));
      expect(body, isNot(contains('fetchShared')));
      expect(_live('lib/screens/ttc/ttc_partner_log_view.dart'),
          contains('SupabaseRepo.fetchByUser(TtcTables.logs, pid'));
    });

    test('the partner view keeps the tracker, its folded ids, and live rows',
        () {
      final day = TtcLogStore.dayKey(_ago(1));
      final rows = ttcPartnerLogRows([
        {'tracker': 'habits', 'field': 'hours', 'logged_on': day, 'value': 7},
        {'tracker': 'sleep', 'field': 'quality', 'logged_on': day, 'value': 3},
        {
          'tracker': 'habits',
          'field': 'stress',
          'logged_on': day,
          'value': 2,
          'removed_at': '2026-10-28T00:00:00Z'
        },
        {'tracker': 'symptoms', 'field': 'low', 'logged_on': day, 'value': 1},
        {
          'tracker': 'habits',
          'field': 'hours',
          'logged_on': TtcLogStore.dayKey(_ago(40)),
          'value': 6
        },
      ], 'habits', DateTime.now());
      expect(rows.map((r) => r.field).toList(), ['hours', 'quality']);
    });

    testWidgets('the ask card waits for a partner and a first save',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(body: TtcShareAskCard(tracker: 'habits'))));
      expect(find.byKey(const ValueKey('ttc_share_ask')), findsNothing);
      TtcLogStore.instance.log('habits', 'hours', 7);
      TtcLogShareStore.instance.setPartnerForTest('him', const {});
      await tester.pump();
      expect(find.byKey(const ValueKey('ttc_share_ask')), findsOneWidget);
      expect(find.text(ttcShareAskLine(him: false)), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_share_yes')));
      await tester.pump();
      expect(TtcLogShareStore.instance.sharedFor('habits'), isTrue);
      expect(find.byKey(const ValueKey('ttc_share_ask')), findsNothing);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('the partner view is read-only and says when it is empty',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: TtcPartnerLogView(
              tracker: 'partner_health', load: () async => const [])));
      await tester.pumpAndSettle();
      expect(find.text(kTtcPartnerNothingLogged), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });

  // ===========================================================================
  group('wiring gate: every new piece has a call site', () {
    test('the logger draws the flag card, the low-mood line and the visit line',
        () {
      final s = _live('lib/screens/ttc/ttc_symptom_log_screen.dart');
      expect(s, contains('TtcSymptomFlagCard('));
      expect(s, contains('ttcSymptomFlag('));
      expect(s, contains('text: kTtcLowMoodLine'));
      expect(s, contains('final line = _doneLine();'));
    });

    test('the tracker page draws the ask card, the partner card, his BMI row',
        () {
      final s = _live('lib/screens/ttc/ttc_tracker_screen.dart');
      expect(s, contains('TtcShareAskCard(tracker: tracker.id)'));
      expect(s, contains("TtcPartnerLogCard(tracker: 'partner_health')"));
      expect(s, contains("TtcPartnerLogCard(tracker: 'habits')"));
      expect(s, contains('TtcWeightBmiRow(forHim: true)'));
      expect(s, contains('const TtcBmiScreen(forHim: true)'));
      expect(_live('lib/screens/ttc/ttc_partner_log_view.dart'),
          contains('TtcPartnerLogView(tracker: tracker)'));
    });

    test('You has the two switches; the router has the private note', () {
      final you = _live('lib/screens/profile/pv_data_privacy_screen.dart');
      expect(you, contains('title: kTtcSharedWithPartnerTitle'));
      expect(you, contains('TtcLogShareStore.instance.set(tracker, on)'));
      expect(_live('lib/screens/ttc/ttc_surface_router.dart'),
          contains('return const TtcHerPrivateNote();'));
    });

    test('the PCOS check asks the ninth question and shows the two lines', () {
      final s = _live('lib/screens/ttc/ttc_pcos_stand_screen.dart');
      expect(s, contains("ValueKey('ttc_pcos_stand_contraception')"));
      expect(s, contains('text: result.capped!'));
      expect(s, contains('text: result.fastChange'));
      expect(s, contains('takeAnswers(kPcosStandQids)'));
    });

    testWidgets('the flag card renders the plan\'s sentences', (tester) async {
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(
              body: TtcSymptomFlagCard(flag: TtcSymptomFlag.fever))));
      expect(find.text(kTtcFlagHeading), findsOneWidget);
      expect(find.textContaining('worth a call to your clinic today'),
          findsOneWidget);
    });
  });
}
