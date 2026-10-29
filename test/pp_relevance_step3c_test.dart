// =============================================================================
//  Parenting relevance, Step 3c (docs/door-relevance/PARENTING-GAP.md)
// -----------------------------------------------------------------------------
//  PP 6  Ask Veda gets the child's context: the corrected age next to the
//        birthday age, and what the family told us, as ids from a closed list
//        (never prose, never the name: the service's cache is shared).
//        Two-repo change; the service half is parentveda-askveda
//        tests/test_child_context.py, which pins the same vocabulary.
//
//  Clock injected (now:). Source scans pin the wiring (CLAUDE.md, wiring gate).
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/askveda_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/services/pregnancy_records.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_store.dart';

String _src(String path) => File(path).readAsStringSync();

/// Mirrors FAMILY_SIGNALS / CHILD_CONDITIONS in parentveda-askveda
/// app/prompt.py. Add an id to both sides or it is dropped by the service.
const _kSignals = {
  'born_early', 'c_section', 'formula', 'breastfeeding', 'twins',
  'after_treatment', 'two_at_home', 'after_loss',
};

final _now = DateTime(2026, 10, 29, 9);

/// 35 weeks before [_now]: 8 months by birthday.
final _eightMonthsAgo = _now.subtract(const Duration(days: 245));

void _clean() {
  ChildProfileStore.instance.resetForTest();
  PregnancyRecords.instance.debugReset();
  TtcStore.instance.setPath(TtcPath.natural);
  final fam = FamilyProfileStore.instance;
  fam.clearConditions();
  fam.setGentle(null);
  fam.setFeeding(null);
  fam.setBirth(multiple: false, premature: false, nicu: false);
  fam.setBirthDetails(early: false, mode: BirthMode.notSaid);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final kids = ChildProfileStore.instance;
  final fam = FamilyProfileStore.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _clean();
  });
  tearDown(_clean);

  group('PP 6: the corrected age next to the birthday age', () {
    test('born at 32 weeks, 8 months old: 6 months corrected', () {
      kids.debugSetDob(_eightMonthsAgo);
      fam.setBirthDetails(early: true, bornWeeks: 32);
      final ctx = ppAskVedaContext(now: _now);
      expect(ctx.ageMonths, 8, reason: 'birthday age, which vaccines follow');
      expect(ctx.correctedMonths, 6, reason: '8 weeks taken off');
      expect(ctx.signals, contains('born_early'));
    });

    test('no corrected age at term, or from 24 months', () {
      kids.debugSetDob(_eightMonthsAgo);
      expect(ppAskVedaContext(now: _now).correctedMonths, isNull);

      fam.setBirthDetails(early: true, bornWeeks: 32);
      kids.debugSetDob(_now.subtract(const Duration(days: 760))); // 25 months
      expect(ppAskVedaContext(now: _now).correctedMonths, isNull);
    });

    test('the ages follow the clock it is given', () {
      kids.debugSetDob(_eightMonthsAgo);
      fam.setBirthDetails(early: true, bornWeeks: 32);
      final later = ppAskVedaContext(now: _now.add(const Duration(days: 61)));
      expect(later.ageMonths, 10);
      expect(later.correctedMonths, 8);
    });
  });

  group('PP 6: ids from a closed list, never prose', () {
    test('every signal is on the list the service knows', () {
      kids.debugSetDob(_now.subtract(const Duration(days: 30)));
      fam.setBirthDetails(early: true, bornWeeks: 34, mode: BirthMode.cSection);
      fam.setFeeding(FeedingMethod.mixed);
      fam.setBirth(multiple: true);
      final ctx = ppAskVedaContext(now: _now);
      expect(ctx.signals,
          containsAll(['born_early', 'c_section', 'formula', 'breastfeeding', 'twins']));
      expect(_kSignals.containsAll(ctx.signals), isTrue);
      for (final s in ctx.signals) {
        expect(s, isNot(contains(kids.name)), reason: 'never the name');
      }
    });

    test('conditions go as their names, sorted', () {
      kids.debugSetDob(_eightMonthsAgo);
      fam.toggleCondition(HealthCondition.reflux);
      fam.toggleCondition(HealthCondition.eczema);
      expect(ppAskVedaContext(now: _now).conditions, ['eczema', 'reflux']);
    });

    test('her onboarding "be gentle" answer stays in the app; a recorded loss goes', () {
      kids.debugSetDob(_eightMonthsAgo);
      fam.setGentle('loss');
      expect(PpSituation.now().signals, contains(PpSignal.afterLoss),
          reason: 'the home may still use it');
      expect(ppAskVedaContext(now: _now).signals, isNot(contains('after_loss')));

      PregnancyRecords.instance.debugReset(rows: [
        PregnancyRecord(
            id: 'preg_a',
            startedOn: DateTime(2024, 1, 1),
            endedOn: DateTime(2024, 3, 1),
            outcome: PregnancyOutcome.loss),
        PregnancyRecord(
            id: 'preg_b',
            startedOn: DateTime(2025, 1, 1),
            outcome: PregnancyOutcome.birth,
            childId: kids.activeChildId),
      ]);
      expect(ppAskVedaContext(now: _now).signals, contains('after_loss'));
    });
  });

  group('PP 6: two children (conditions per child since PP 21)', () {
    test('one child: her noted conditions go', () async {
      await kids.addChild(name: 'Dev', isBoy: true, dob: _eightMonthsAgo);
      fam.toggleCondition(HealthCondition.eczema);
      expect(ppAskVedaContext(now: _now).conditions, ['eczema']);
    });

    // Kept for revert (step 3c, superseded by PP 21 on 2026-10-29: the
    // conditions are the active child's, so two children no longer silence
    // them):
    // test('two children: none go, whichever child is open', () async {
    //   final older = await kids.addChild(
    //       name: 'Riya', isBoy: false, dob: _now.subtract(const Duration(days: 1100)));
    //   final baby = await kids.addChild(name: 'Dev', isBoy: true, dob: _eightMonthsAgo);
    //   fam.toggleCondition(HealthCondition.eczema);
    //   fam.toggleCondition(HealthCondition.hearing);
    //   await kids.switchTo(baby.id);
    //   final ctx = ppAskVedaContext(now: _now);
    //   expect(ctx.conditions, isEmpty,
    //       reason: 'the eczema may be the older child\'s, not the baby\'s');
    //   expect(ctx.signals, everyElement(isIn(_kSignals)),
    //       reason: 'no extra-support signal derived from those conditions');
    //   await kids.switchTo(older.id);
    //   expect(ppAskVedaContext(now: _now).conditions, isEmpty);
    // });

    test("two children (PP 21): each child's own conditions go, never the other's", () async {
      // The app's init registers the child-switch listener that swaps buckets.
      await fam.init();
      final older = await kids.addChild(
          name: 'Riya', isBoy: false, dob: _now.subtract(const Duration(days: 1100)));
      final baby = await kids.addChild(name: 'Dev', isBoy: true, dob: _eightMonthsAgo);
      await kids.switchTo(baby.id);
      fam.toggleCondition(HealthCondition.eczema);
      await kids.switchTo(older.id);
      fam.toggleCondition(HealthCondition.hearing);
      expect(ppAskVedaContext(now: _now).conditions, ['hearing']);
      await kids.switchTo(baby.id);
      final ctx = ppAskVedaContext(now: _now);
      expect(ctx.conditions, ['eczema'], reason: "the baby's, not the older child's");
      expect(ctx.signals, everyElement(isIn(_kSignals)));
    });
  });

  group('PP 6: the screen says what the answer used', () {
    test('a line only from what the service says it used', () {
      expect(askVedaUsedLine(const []), isNull);
      expect(askVedaUsedLine(const ['corrected_age', 'formula', 'eczema']),
          'Answered with what you told us: corrected age, formula, eczema.');
      expect(askVedaUsedLine(const ['some_future_id']), isNull,
          reason: 'an unknown id is left out, never shown raw');
    });
  });

  group('PP 6: wiring', () {
    test('the request carries the new fields and reads used_context back', () {
      final s = _src('lib/services/remote/ask_veda_service.dart');
      for (final key in [
        "'child_age_corrected_months'",
        "'family_signals'",
        "'child_conditions'",
        "map['used_context']",
      ]) {
        expect(s, contains(key));
      }
    });

    test('Parenting Ask Veda sends the context, and never the prose summary', () {
      final s = _src('lib/screens/post_pregnancy/askveda_screen.dart');
      expect(s, contains('final ctx = ppAskVedaContext();'));
      expect(s, contains('childAgeCorrectedMonths: ctx.correctedMonths'));
      expect(s, contains('familySignals: ctx.signals'));
      expect(s, contains('childConditions: ctx.conditions'));
      expect(s, contains('askVedaUsedLine(f.usedContext)'));
      expect(s, contains('ChildProfileStore.instance.ageLabelWithCorrection'));
      expect(s, isNot(contains('aiContext()')));
    });

    test('every signal id the builder can send is on the list', () {
      final s = _src('lib/screens/post_pregnancy/pp_relevance.dart');
      final start = s.indexOf('PpAskVedaContext ppAskVedaContext(');
      final body = s.substring(start, s.indexOf('return PpAskVedaContext(', start));
      final sent = RegExp(r"\)\s*'([a-z_]+)',").allMatches(body).map((m) => m.group(1)!);
      expect(sent.toSet(), _kSignals);
    });
  });
}
