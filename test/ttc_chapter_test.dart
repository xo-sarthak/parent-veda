// =============================================================================
//  TTC Chapter Engine
// -----------------------------------------------------------------------------
//  The spine of the Trying-to-Conceive stage. These tests pin down BOTH halves:
//  the biology (cycle day, ovulation estimate, fertility grading) and the
//  product promises that sit on top of it - that a couple with no data still
//  gets a real answer, that irregular cycles lower confidence rather than
//  disappearing, and that an overdue period never renders as "you are late".
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';

void main() {
  const engine = TtcChapterEngine();
  final today = DateTime(2026, 7, 27);

  /// A journey that started long ago, sitting on a given cycle day.
  TtcJourneyState onDay(
    int day, {
    List<int> cycles = const [],
    int? lh,
    int? shift,
    bool pregnant = false,
  }) =>
      TtcJourneyState(
        journeyStart: today.subtract(const Duration(days: 200)),
        lastPeriodStart: today.subtract(Duration(days: day - 1)),
        cycleLengths: cycles,
        lhPositiveDay: lh,
        temperatureShiftDay: shift,
        pregnancyConfirmed: pregnant,
        today: today,
      );

  group('a couple who has logged nothing', () {
    test('still gets a real answer, in Preparing Together', () {
      final r = engine.resolve(TtcJourneyState(today: today));
      expect(r.chapter, TtcChapter.preparingTogether);
      expect(r.cycleDay, isNull);
      expect(r.confidence, OvulationConfidence.unknown);
    });

    test('we refuse to guess ovulation or fertility rather than inventing one',
        () {
      final r = engine.resolve(TtcJourneyState(today: today));
      expect(r.estimatedOvulationDay, isNull);
      expect(r.fertility, isNull);
      expect(r.inFertileWindow, isFalse);
    });
  });

  group('the opening stretch is Chapter 1 regardless of the cycle', () {
    test('a journey ten days old stays in Preparing Together', () {
      final s = TtcJourneyState(
        journeyStart: today.subtract(const Duration(days: 10)),
        lastPeriodStart: today.subtract(const Duration(days: 13)), // day 14
        today: today,
      );
      expect(engine.resolve(s).chapter, TtcChapter.preparingTogether);
    });

    test('past that, the cycle takes over', () {
      final s = TtcJourneyState(
        journeyStart: today.subtract(const Duration(days: 40)),
        lastPeriodStart: today.subtract(const Duration(days: 13)), // day 14
        today: today,
      );
      expect(engine.resolve(s).chapter, TtcChapter.tryingTogether);
    });
  });

  group('cycle day', () {
    test('day 1 is the first day of the period, not the day after', () {
      expect(engine.cycleDay(onDay(1)), 1);
    });

    test('counts forward from there', () {
      expect(engine.cycleDay(onDay(17)), 17);
    });

    test('a period date in the future is bad input, not day 1', () {
      final s = TtcJourneyState(
        lastPeriodStart: today.add(const Duration(days: 3)),
        today: today,
      );
      expect(engine.cycleDay(s), isNull);
    });
  });

  group('ovulation is estimated backwards from the next period', () {
    test('a 28-day cycle lands on day 14', () {
      expect(engine.estimatedOvulationDay(onDay(5, cycles: [28, 28])), 14);
    });

    test('a 34-day cycle lands on day 20 - not everyone gets "day 14"', () {
      expect(engine.estimatedOvulationDay(onDay(5, cycles: [34, 34])), 20);
    });

    test('a 26-day cycle lands on day 12', () {
      expect(engine.estimatedOvulationDay(onDay(5, cycles: [26, 26])), 12);
    });

    test('only the most recent six cycles describe her', () {
      // Seven cycles: a long-ago 40 must fall out of the average.
      final s = onDay(5, cycles: [40, 28, 28, 28, 28, 28, 28]);
      expect(engine.cycleLengthFor(s), 28);
    });
  });

  group('a body signal beats calendar arithmetic', () {
    test('a positive LH test puts ovulation the following day', () {
      final s = onDay(18, cycles: [28, 28], lh: 16);
      expect(engine.estimatedOvulationDay(s), 17);
      expect(engine.confidence(s), OvulationConfidence.high);
    });

    test('a temperature shift is read back one day - it is seen after', () {
      final s = onDay(18, cycles: [28, 28], shift: 15);
      expect(engine.estimatedOvulationDay(s), 14);
      expect(engine.confidence(s), OvulationConfidence.high);
    });
  });

  group('confidence replaces certainty', () {
    test('irregular cycles lower confidence - they do not hide the tool', () {
      final s = onDay(5, cycles: [26, 40]);
      expect(engine.isIrregular(s), isTrue);
      expect(engine.confidence(s), OvulationConfidence.low);
      // Still answers. A PCOS or irregular cycle must feel equally understood.
      expect(engine.estimatedOvulationDay(s), isNotNull);
    });

    test('a few consistent cycles earn a medium estimate', () {
      expect(engine.confidence(onDay(5, cycles: [28, 29, 28])),
          OvulationConfidence.medium);
    });

    test('one cycle is not enough to lean on', () {
      expect(engine.confidence(onDay(5, cycles: [28])), OvulationConfidence.low);
    });

    test('every confidence level has honest, hedged copy', () {
      for (final c in OvulationConfidence.values) {
        expect(c.phrase(false), isNotEmpty);
        expect(c.phrase(true), isNotEmpty);
        // Never a promise.
        expect(c.phrase(false).toLowerCase(), isNot(contains('will')));
      }
    });
  });

  group('the fertile window is graded, never flagged', () {
    // 28-day cycle → ovulation day 14. Window: days 9-15.
    TtcJourneyState d(int day) => onDay(day, cycles: [28, 28]);

    test('the two peak days are ovulation and the day before', () {
      expect(engine.fertilityFor(d(13), 13), FertilityLevel.peak);
      expect(engine.fertilityFor(d(14), 14), FertilityLevel.peak);
    });

    test('high on either shoulder of the peak', () {
      expect(engine.fertilityFor(d(12), 12), FertilityLevel.high);
      expect(engine.fertilityFor(d(11), 11), FertilityLevel.high);
      expect(engine.fertilityFor(d(15), 15), FertilityLevel.high);
    });

    test('medium at the opening of the window - sperm survive ~5 days', () {
      expect(engine.fertilityFor(d(9), 9), FertilityLevel.medium);
      expect(engine.fertilityFor(d(10), 10), FertilityLevel.medium);
    });

    test('low outside it, on both sides', () {
      expect(engine.fertilityFor(d(4), 4), FertilityLevel.low);
      expect(engine.fertilityFor(d(22), 22), FertilityLevel.low);
    });

    test('no fertility level at all when we have no estimate to stand on', () {
      final s = TtcJourneyState(today: today);
      expect(engine.fertilityFor(s, 14), isNull);
    });

    test('the labels are calm - no danger, no red, no missed', () {
      const banned = ['danger', 'red', 'missed', 'warning', 'fail'];
      for (final f in FertilityLevel.values) {
        for (final hi in [true, false]) {
          final l = f.label(hi).toLowerCase();
          expect(l, isNotEmpty);
          for (final b in banned) {
            expect(l, isNot(contains(b)), reason: '$f said "$l"');
          }
        }
      }
    });
  });

  group('chapters ride the cycle', () {
    // 28-day cycle → ovulation 14, window 9-15.
    TtcChapter at(int day) => engine.resolve(onDay(day, cycles: [28, 28])).chapter;

    test('day 1 to 8 is Knowing Your Rhythm', () {
      expect(at(1), TtcChapter.knowingYourRhythm);
      expect(at(8), TtcChapter.knowingYourRhythm);
    });

    test('the seven-day window is Trying Together', () {
      expect(at(9), TtcChapter.tryingTogether);
      expect(at(14), TtcChapter.tryingTogether);
      expect(at(15), TtcChapter.tryingTogether);
    });

    test('after it, The Waiting Days', () {
      expect(at(16), TtcChapter.theWaitingDays);
      expect(at(27), TtcChapter.theWaitingDays);
    });

    test('a longer cycle moves the window with it, not the calendar', () {
      // 34-day cycle → ovulation 20, window 15-21.
      TtcChapter atLong(int day) =>
          engine.resolve(onDay(day, cycles: [34, 34])).chapter;
      expect(atLong(14), TtcChapter.knowingYourRhythm);
      expect(atLong(20), TtcChapter.tryingTogether);
      expect(atLong(22), TtcChapter.theWaitingDays);
    });
  });

  group('a positive test ends the stage', () {
    test('whatever the cycle would otherwise say', () {
      expect(engine.resolve(onDay(12, cycles: [28, 28], pregnant: true)).chapter,
          TtcChapter.aNewBeginning);
      expect(engine.resolve(onDay(25, cycles: [28, 28], pregnant: true)).chapter,
          TtcChapter.aNewBeginning);
    });
  });

  group('progress never reads as failure', () {
    test('an overdue period does not push progress past complete', () {
      // 28-day cycle, now on day 35 - a full week "late".
      final r = engine.resolve(onDay(35, cycles: [28, 28]));
      expect(r.chapter, TtcChapter.theWaitingDays);
      expect(r.chapterProgress, lessThanOrEqualTo(1.0));
      expect(r.daysIntoChapter, lessThanOrEqualTo(r.chapterLength));
    });

    test('progress stays in range on every day of a long cycle', () {
      for (var day = 1; day <= 45; day++) {
        final r = engine.resolve(onDay(day, cycles: [28, 28]));
        expect(r.chapterProgress, inInclusiveRange(0.0, 1.0),
            reason: 'cycle day $day');
      }
    });
  });

  group('every chapter can be rendered in both languages', () {
    test('title, tagline, focus and goal are all present', () {
      for (final c in TtcChapter.values) {
        for (final hi in [true, false]) {
          expect(c.title(hi), isNotEmpty, reason: '$c');
          expect(c.tagline(hi), isNotEmpty, reason: '$c');
          expect(c.focus(hi), isNotEmpty, reason: '$c');
          expect(c.goal(hi), isNotEmpty, reason: '$c');
        }
      }
    });

    test('English and Hinglish are genuinely different strings', () {
      for (final c in TtcChapter.values) {
        expect(c.title(true), isNot(c.title(false)), reason: '$c');
        expect(c.tagline(true), isNot(c.tagline(false)), reason: '$c');
      }
    });

    test('chapter numbers run 1 to 5 in journey order', () {
      expect(TtcChapter.preparingTogether.number, 1);
      expect(TtcChapter.aNewBeginning.number, 5);
    });
  });
}
