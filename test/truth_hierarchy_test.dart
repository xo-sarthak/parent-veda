// =============================================================================
//  Truth hierarchy - when two sources disagree, which one wins
// -----------------------------------------------------------------------------
//  The rule exists because we kept writing it one case at a time: LH beats the
//  calendar, a temperature shift beats the calendar, clinic dates beat
//  everything. Each was written separately and none knew about the others.
//
//  The most valuable test here is the last one: the hierarchy and the TTC engine
//  must AGREE. A second opinion about who to believe would be worse than not
//  having named the rule at all.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/services/journey_state.dart';
import 'package:parentveda/services/truth_hierarchy.dart';

void main() {
  DateTime at(int day) => DateTime(2026, 7, day);

  TruthClaim<String> claim(
    TruthSource source,
    String value, {
    Inferable about = Inferable.fertilityTiming,
    int day = 1,
  }) =>
      TruthClaim(
          about: about, source: source, value: value, recordedAt: at(day));

  // ===========================================================================
  group('the order itself', () {
    test('a clinician outranks everything', () {
      for (final other in TruthSource.values) {
        if (other == TruthSource.treatingClinician) continue;
        expect(TruthSource.treatingClinician.outranks(other), isTrue,
            reason: 'clinician should beat $other');
      }
    });

    test('our own calculation is near the bottom, on purpose', () {
      // Only a population estimate is weaker. If this ever inverts, somebody has
      // quietly decided our arithmetic beats a lab result.
      final below = TruthSource.values
          .where((s) => TruthSource.parentvedaDerived.outranks(s))
          .toList();
      expect(below, [TruthSource.populationEstimate]);
    });

    test('a population estimate is the weakest thing we can say', () {
      for (final other in TruthSource.values) {
        if (other == TruthSource.populationEstimate) continue;
        expect(other.outranks(TruthSource.populationEstimate), isTrue);
      }
    });

    test('what she recorded beats what a device recorded', () {
      // She knows the context a sensor cannot - a bad night, an illness, a
      // reading taken late.
      expect(TruthSource.userObservation.outranks(TruthSource.deviceData),
          isTrue);
    });

    test('imaging beats our arithmetic, which is the pregnancy case', () {
      expect(TruthSource.imaging.beatsOurCalculation, isTrue);
      expect(TruthSource.parentvedaDerived.beatsOurCalculation, isFalse);
    });

    test('every source has a label in both languages', () {
      for (final s in TruthSource.values) {
        expect(s.label(false), isNotEmpty);
        expect(s.label(true), isNotEmpty);
      }
    });
  });

  // ===========================================================================
  group('resolving', () {
    test('nothing in, nothing out', () {
      expect(TruthHierarchy.resolve(const <TruthClaim<String>>[]), isNull);
    });

    test('the strongest source wins regardless of order', () {
      final ours = claim(TruthSource.parentvedaDerived, 'day 14');
      final hers = claim(TruthSource.userObservation, 'day 12');
      expect(TruthHierarchy.resolve([ours, hers])!.value, 'day 12');
      expect(TruthHierarchy.resolve([hers, ours])!.value, 'day 12');
    });

    test('equal rank is broken by recency, not list order', () {
      final old = claim(TruthSource.laboratoryResult, 'first', day: 1);
      final fresh = claim(TruthSource.laboratoryResult, 'repeat', day: 9);
      expect(TruthHierarchy.resolve([fresh, old])!.value, 'repeat');
      expect(TruthHierarchy.resolve([old, fresh])!.value, 'repeat');
    });

    test('claims about different facts do not compete', () {
      final timing = claim(TruthSource.treatingClinician, 'ovulation',
          about: Inferable.fertilityTiming);
      final dating = claim(TruthSource.parentvedaDerived, 'week 12',
          about: Inferable.gestationalAge);
      // The clinician outranks us, but says nothing about gestational age -
      // so ours still stands there.
      expect(
          TruthHierarchy.resolveFor(
                  Inferable.gestationalAge, [timing, dating])!
              .value,
          'week 12');
    });
  });

  // ===========================================================================
  group('when we must step aside', () {
    test('alone, our estimate stands', () {
      expect(
          TruthHierarchy.weMustDefer(Inferable.fertilityTiming,
              [claim(TruthSource.parentvedaDerived, 'day 14')]),
          isFalse);
    });

    test('a scan means we stop offering a second opinion', () {
      // The pregnancy case, named before it shipped: a dating scan beats
      // counting from a last period, and the clinic owns the scan.
      final claims = [
        claim(TruthSource.parentvedaDerived, 'week 11 by dates',
            about: Inferable.gestationalAge),
        claim(TruthSource.imaging, 'week 12 by scan',
            about: Inferable.gestationalAge),
      ];
      expect(
          TruthHierarchy.weMustDefer(Inferable.gestationalAge, claims), isTrue);
      expect(
          TruthHierarchy.resolveFor(Inferable.gestationalAge, claims)!.value,
          'week 12 by scan');
    });

    test('with no claims at all there is nothing to defer to', () {
      expect(
          TruthHierarchy.weMustDefer(
              Inferable.fertilityTiming, const <TruthClaim<String>>[]),
          isFalse);
    });
  });

  // ===========================================================================
  group('what lost is kept, not deleted', () {
    test('superseded claims come back strongest-first', () {
      final claims = [
        claim(TruthSource.parentvedaDerived, 'ours'),
        claim(TruthSource.treatingClinician, 'theirs'),
        claim(TruthSource.userObservation, 'hers'),
      ];
      final rest =
          TruthHierarchy.superseded(Inferable.fertilityTiming, claims);
      // The clinician won; the other two survive in order.
      expect(rest.map((c) => c.value), ['hers', 'ours']);
    });

    test('a lone claim supersedes nothing', () {
      expect(
          TruthHierarchy.superseded(Inferable.fertilityTiming,
              [claim(TruthSource.imaging, 'only')]),
          isEmpty);
    });
  });

  // ===========================================================================
  group('it agrees with the rules already written', () {
    test('a body signal outranking the calendar IS this hierarchy', () {
      // TtcChapterEngine.confidence returns high the moment an LH strip or a
      // temperature shift exists, overriding calendar arithmetic. That was
      // written before the hierarchy and must still follow it.
      expect(
          TruthSource.userObservation.outranks(TruthSource.parentvedaDerived),
          isTrue);
    });

    test('clinic dates outranking anything we compute IS this hierarchy', () {
      // TtcTreatmentStore carries dates the clinic named and never calculates
      // one. Same rule, stated once.
      expect(
          TruthSource.treatingClinician.outranks(TruthSource.parentvedaDerived),
          isTrue);
      expect(
          TruthSource.verifiedMedication.outranks(TruthSource.parentvedaDerived),
          isTrue);
    });

    test('anything that beats us also beats a population estimate', () {
      // Otherwise a surface could suppress our estimate for a stronger source
      // and then fall back to a general statistic that outranks it. Nonsense,
      // and the kind of nonsense a hierarchy exists to prevent.
      for (final s in TruthSource.values) {
        if (!s.beatsOurCalculation) continue;
        expect(s.outranks(TruthSource.populationEstimate), isTrue);
      }
    });
  });
}
