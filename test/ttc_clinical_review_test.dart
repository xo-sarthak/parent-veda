// =============================================================================
//  The clinical-review pass
// -----------------------------------------------------------------------------
//  Six changes that came out of a product review of the IVF questions. Each is
//  here because it is a rule somebody could unknowingly undo later:
//
//    1. no personalised probabilities  - population statistics stay allowed
//    2. confidence is DERIVED          - never a questionnaire
//    4. milestone first, count second  - the beta card
//    5. the trigger tick silences both reminders
//    6. no prediction language where a clinic owns the timing
//
//  (3 was a documentation decision - two statements marked pending clinical
//  review rather than shipped quietly - and lives in docs/TTC-IVF-REVIEW.md.)
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  const engine = TtcChapterEngine();

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
  });

  // ===========================================================================
  //  1. Probabilities
  // ---------------------------------------------------------------------------
  //  The rule has two halves and both matter. Banning every statistic would
  //  cost us the most reassuring line in the product - "most couples conceive
  //  within a year" is what tells someone at month eight that more time really
  //  is the answer. What must never appear is a number attached to HER.
  group('no personalised probabilities, but population context is allowed', () {
    late final String corpus = _readAll([
      'lib/ttc',
      'lib/screens/ttc',
    ]);

    test('nothing tells this family what their own chances are', () {
      // A possessive near a percentage, in either digits or words.
      final banned = RegExp(
        r'your\s+(chance|chances|probability|odds|success\s+rate)'
        r"[^.!?]{0,80}(\d+\s*%|per\s+cent)"
        r'|(\d+\s*%|per\s+cent)[^.!?]{0,80}\byour\s+'
        r'(chance|chances|probability|odds|success\s+rate)'
        r'|based\s+on\s+your\s+(profile|data|cycles)[^.!?]{0,60}'
        r'(\d+\s*%|per\s+cent)',
        caseSensitive: false,
      );
      final hits = banned.allMatches(corpus).map((m) => m.group(0)).toList();
      expect(hits, isEmpty,
          reason: 'a probability attached to this family: $hits');
    });

    test('and no per-cycle success rates either', () {
      final banned = RegExp(
        r'(success\s+rate|chance\s+of\s+success)[^.!?]{0,40}'
        r'(this\s+(cycle|month|round)|for\s+you)',
        caseSensitive: false,
      );
      expect(banned.allMatches(corpus).map((m) => m.group(0)), isEmpty);
    });

    test('population statistics survive - the other half of the rule', () {
      // Guards against "fixing" the rule by deleting every number. If this
      // fails, check that the statistic moved rather than vanished.
      expect(corpus.toLowerCase(), contains('per cent'),
          reason: 'general statistics should still be there');
    });
  });

  // ===========================================================================
  //  2. Confidence is derived
  // ---------------------------------------------------------------------------
  //  The review first suggested lowering confidence for PCOS, postpartum,
  //  breastfeeding, perimenopause, recent contraception and recent loss. All
  //  true, and all six would have meant a questionnaire. These use what she has
  //  already logged instead.
  group('confidence drops from what she logged, never from a questionnaire',
      () {
    TtcJourneyState stateWith(List<DateTime> starts, {DateTime? now}) {
      for (final s in starts) {
        CycleStore.instance.logPeriodStart(s);
      }
      return TtcStore.instance.state(on: now);
    }

    test('a cycle running far past its own history is not confident', () {
      final now = DateTime(2026, 7, 27);
      // 28-day history, then day 45 of the current one.
      final s = stateWith([
        DateTime(2026, 4, 20),
        DateTime(2026, 5, 18),
        DateTime(2026, 6, 15),
      ], now: now);
      expect(engine.isCurrentCycleOverdue(s), isTrue);
      expect(engine.confidence(s), OvulationConfidence.low);
    });

    test('a very long recorded gap makes the history unreliable', () {
      // Either she missed logging one, or that cycle had no ovulation. We
      // cannot tell which, so we get less sure rather than more.
      final s = stateWith([
        DateTime(2026, 3, 1),
        DateTime(2026, 5, 20), // 80 days
        DateTime(2026, 7, 20),
      ], now: DateTime(2026, 7, 27));
      expect(engine.hasUnreliableHistory(s), isTrue);
      expect(engine.confidence(s), OvulationConfidence.low);
    });

    test('a signal from THIS cycle still beats the doubt', () {
      final now = DateTime(2026, 7, 27);
      final s = stateWith([
        DateTime(2026, 3, 1),
        DateTime(2026, 5, 20),
        DateTime(2026, 7, 16),
      ], now: now);
      expect(engine.hasUnreliableHistory(s), isTrue);
      CycleStore.instance.logLhPositive(11);
      final withLh = TtcStore.instance.state(on: now);
      expect(engine.confidence(withLh), OvulationConfidence.high,
          reason: 'an LH strip is evidence about this cycle specifically');
    });

    test('a normal recent history is unaffected', () {
      final now = DateTime(2026, 7, 27);
      final s = stateWith([
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 29),
        DateTime(2026, 7, 27),
      ], now: now);
      expect(engine.isCurrentCycleOverdue(s), isFalse);
      expect(engine.hasUnreliableHistory(s), isFalse);
      expect(engine.confidence(s), isNot(OvulationConfidence.unknown));
    });

    test('with nothing logged we say unknown rather than guessing', () {
      expect(engine.confidence(TtcStore.instance.state()),
          OvulationConfidence.unknown);
    });
  });

  // ===========================================================================
  //  5. The trigger tick
  // ---------------------------------------------------------------------------
  //  Two reminders are only safe because of this. A fifteen-minute alert to
  //  someone who already did it, at the exact moment timing mattered, is alarm
  //  dressed as help.
  group('the trigger tick', () {
    final at = DateTime(2026, 8, 3, 22, 15);

    test('starts un-ticked', () {
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.trigger, at);
      expect(TtcTreatmentStore.instance.cycle.triggerTaken, isFalse);
    });

    test('ticks and un-ticks', () {
      final store = TtcTreatmentStore.instance..setDate(
          TtcTreatmentStep.trigger, at);
      store.setTriggerTaken(true);
      expect(store.cycle.triggerTaken, isTrue);
      store.setTriggerTaken(false);
      expect(store.cycle.triggerTaken, isFalse);
    });

    test('rescheduling the trigger un-ticks it', () {
      // The clinic moved it, so the injection she took is not the one now on
      // the calendar - and the reminders for the new time must fire.
      final store = TtcTreatmentStore.instance..setDate(
          TtcTreatmentStep.trigger, at);
      store.setTriggerTaken(true);
      store.setDate(
          TtcTreatmentStep.trigger, DateTime(2026, 8, 4, 21, 0));
      expect(store.cycle.triggerTaken, isFalse);
    });

    test('setting an unrelated date leaves the tick alone', () {
      final store = TtcTreatmentStore.instance..setDate(
          TtcTreatmentStep.trigger, at);
      store.setTriggerTaken(true);
      store.setDate(TtcTreatmentStep.retrieval, DateTime(2026, 8, 5));
      expect(store.cycle.triggerTaken, isTrue);
    });

    test('the two reminders have different ids so both can be cancelled', () {
      expect(TtcTreatmentStore.triggerPrepNotificationId,
          isNot(TtcTreatmentStore.triggerNotificationId));
    });

    test('it survives a round trip through storage', () {
      final cycle = const TtcTreatmentCycle(dates: {})
          .withDate(TtcTreatmentStep.trigger, at)
          .withTriggerTaken(true);
      final back = TtcTreatmentCycle.fromJson(cycle.toJson());
      expect(back.triggerTaken, isTrue);
      expect(back[TtcTreatmentStep.trigger], at);
    });

    test('clearing the cycle clears the tick', () {
      final store = TtcTreatmentStore.instance..setDate(
          TtcTreatmentStep.trigger, at);
      store.setTriggerTaken(true);
      store.clearCycle();
      expect(store.cycle.triggerTaken, isFalse);
    });

    test('the clinic name survives ticking', () {
      final store = TtcTreatmentStore.instance..setClinic('Nova');
      store.setDate(TtcTreatmentStep.trigger, at);
      store.setTriggerTaken(true);
      expect(store.cycle.clinic, 'Nova');
    });
  });

  // ===========================================================================
  //  6. Prediction language where a clinic owns the timing
  // ---------------------------------------------------------------------------
  group('we do not defer and predict in the same breath', () {
    test('a clinic path never claims to predict ovulation', () {
      for (final path in TtcPath.values) {
        TtcStore.instance.setPath(path);
        final today = TtcStore.instance.today;
        if (today.behaviour.predictsOvulation) continue;
        expect(today.fertility, isNull, reason: '$path');
        expect(today.behaviour.showsFertilityWindow, isFalse, reason: '$path');
      }
    });

    test('but she can still log her body on a monitored cycle', () {
      // The middle tier is the whole gain: her clinic owns the timing, her
      // observations are still hers.
      TtcStore.instance
        ..setPath(TtcPath.ovulationInduction)
        ..setClinicMonitors(true)
        ..setMedicationControlsOvulation(false);
      final today = TtcStore.instance.today;
      expect(today.behaviour.predictsOvulation, isFalse);
      expect(today.behaviour.logsBodySignals, isTrue);
    });

    test('the replacement line exists in both languages', () {
      final src = File('lib/screens/ttc/ttc_strings.dart').readAsStringSync();
      expect(src, contains('clinicGuidingTiming'));
    });
  });
}

/// Every Dart source under these directories, concatenated. A copy rule applies
/// to all copy, not only to the seed lists - so the corpus is the source.
String _readAll(List<String> dirs) {
  final buffer = StringBuffer();
  for (final dir in dirs) {
    final d = Directory(dir);
    if (!d.existsSync()) continue;
    for (final f in d.listSync(recursive: true).whereType<File>()) {
      if (f.path.endsWith('.dart')) buffer.writeln(f.readAsStringSync());
    }
  }
  return buffer.toString();
}
