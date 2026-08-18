// =============================================================================
//  Labour prep — the review, as tests
// -----------------------------------------------------------------------------
//  Four things came out of one paragraph of review, and three of them are order
//  or destination rather than content — which is exactly the kind of thing that
//  gets quietly undone by the next person adding a step.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/hubs/pregnancy_hubs.dart';
import 'package:parentveda/data/journeys/pregnancy_journeys.dart';
import 'package:parentveda/screens/brackets/hub/hub_solution_cards.dart';
import 'package:parentveda/screens/brackets/hub/journey_config.dart';

void main() {
  final steps = kPgBirthPrep.steps;
  final questions = [for (final s in steps) s.question.en];

  group('the two removed steps are gone', () {
    test('no birth-plan step, and no "what do I get to choose"', () {
      // Both were owed placeholders in the middle of a journey whose job is to
      // get her ready. The reading they carried is now the rotating pool below.
      expect(questions, isNot(contains('What do I get to choose?')));
      expect(questions, isNot(contains('Can I write it down?')));
    });
  });

  group('the class sits above the hospital bag', () {
    // ⚠️ THE ORDER IS THE REVIEW. "Join a birth class section seems like
    // unimportant, but for us it is most important." Putting the free, obvious
    // step in front of the paid, valuable one is how it read as an afterthought.
    test('being taught comes before packing', () {
      final taught =
          questions.indexOf('I would rather be taught this properly');
      final bag = questions.indexOf('What do I need to have ready?');
      expect(taught, greaterThanOrEqualTo(0));
      expect(bag, greaterThanOrEqualTo(0));
      expect(taught, lessThan(bag),
          reason: 'the birthing class must sit above the hospital bag');
    });
  });

  group('the tool is taught before it is handed over', () {
    late JourneyStep timer;

    setUp(() => timer = steps.firstWhere(
        (s) => s.question.en.contains('contraction timer')));

    test('there is a step for the contraction timer at all', () {
      expect(timer.elements.length, 2,
          reason: 'the video and the tool are one step with two elements');
    });

    test('and the video comes first, the tool second', () {
      // ⚠️ WITHIN a step, order is the whole point here: "have a video first
      // explaining the tool and then tool below and ask user to try". A tool
      // above its own explainer is the state we were already in — a timer nobody
      // opens until labour, which is the one moment it is too late to learn it.
      expect(timer.elements.first.type, SolutionType.watch);
      expect(timer.elements.last.type, SolutionType.tool);
    });

    test('and the tool is the timer we already built, not a new one', () {
      expect(timer.elements.last.surfaceId, 'contractions',
          reason: 'the review says "the one we have already built"');
      expect(timer.elements.last.owed, isFalse,
          reason: 'a shipped tool must not render as coming soon');
    });
  });

  group('the reading rotates instead of being a step', () {
    test('the pool is bigger than what is shown', () {
      expect(kPgBirthPrep.reads.length, greaterThan(3),
          reason: '"keep them coming up" needs more topics than fit on screen');
    });

    test('three are shown at a time', () {
      expect(kPgBirthPrep.shownReads(DateTime(2026, 8, 17)).length, 3);
    });

    // ⚠️ ROTATES, DOES NOT SHUFFLE. A `Random()` would re-draw on every rebuild:
    // she scrolls down, scrolls back, and the section has changed under her —
    // which reads as a bug and loses whatever she was about to tap.
    test('the same day always gives the same three', () {
      final a = kPgBirthPrep.shownReads(DateTime(2026, 8, 17));
      final b = kPgBirthPrep.shownReads(DateTime(2026, 8, 17, 23, 59));
      expect([for (final r in a) r.title.en], [for (final r in b) r.title.en]);
    });

    test('and a different day gives a different three', () {
      final a = [
        for (final r in kPgBirthPrep.shownReads(DateTime(2026, 8, 17)))
          r.title.en
      ];
      final b = [
        for (final r in kPgBirthPrep.shownReads(DateTime(2026, 8, 20)))
          r.title.en
      ];
      expect(a, isNot(equals(b)));
    });

    test('every topic in the pool comes up eventually', () {
      // A rotation that skipped part of the pool would be a list with extra
      // steps. Walk a full cycle and check nothing is stranded.
      final seen = <String>{};
      for (var d = 0; d < kPgBirthPrep.reads.length; d++) {
        for (final r in kPgBirthPrep.shownReads(
            DateTime(2026, 1, 1).add(Duration(days: d)))) {
          seen.add(r.title.en);
        }
      }
      expect(seen.length, kPgBirthPrep.reads.length);
    });

    test('a journey with no pool renders no section', () {
      expect(kPgMoodCheck.shownReads(DateTime(2026, 8, 17)), isEmpty);
    });
  });

  group('"Join a birthing class" opens a class', () {
    // ⚠️ THE DEFECT THIS GROUP EXISTS FOR. The hub's closing offer used
    // `kPgActConsult` under a "Join a birthing class" label, so it opened a
    // gynaecologist's booking page — and the comment one line above it said the
    // offer should be "a class rather than a doctor". A comment is not a test.
    test('the closing action is the class action, not the consult', () {
      expect(kPgLabour.closing?.action, kPgActBirthClass);
      expect(kPgLabour.closing?.action, isNot(kPgActConsult));
    });

    test('and the class has its own action so the two cannot be confused', () {
      expect(kPgActBirthClass, isNot(kPgActConsult));
    });
  });
}
