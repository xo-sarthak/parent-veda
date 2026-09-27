// =============================================================================
//  TTC - daily cards and home reads chosen by where she is in her cycle
// -----------------------------------------------------------------------------
//  TTC gap analysis, "Behind: Home & daily", P1. The cards and reads rotated by
//  date alone; now each carries the phases it fits. What these tests hold:
//  every phase has something to show, the phase's own cards lead, every read
//  id in the table resolves, and the new copy keeps the voice rules.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_phase_reads.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

void main() {
  final day = DateTime(2026, 9, 26);
  final phased = TtcDayPhase.values.where((p) => p != TtcDayPhase.any);

  group('phase cards', () {
    test('every phase returns cards', () {
      for (final phase in TtcDayPhase.values) {
        final cards = ttcInsightsForPhase(phase, day);
        expect(cards, hasLength(3), reason: '$phase');
      }
    });

    test('each phase has cards written for it', () {
      int count(TtcDayPhase p) =>
          ttcPhaseInsights.where((i) => i.phases.contains(p)).length;
      expect(count(TtcDayPhase.period), 5);
      expect(count(TtcDayPhase.waiting), 7);
      expect(count(TtcDayPhase.late), 3);
      expect(count(TtcDayPhase.window), 5);
      // beforeWindow has no new cards; the everyday set carries it.
      expect(
          ttcAllInsights.any((i) => i.phases.contains(TtcDayPhase.beforeWindow)),
          isTrue);
    });

    test('phase-tagged cards come first, then any', () {
      for (final phase in phased) {
        final tagged =
            ttcAllInsights.where((i) => i.phases.contains(phase)).length;
        final cards = ttcInsightsForPhase(phase, day, count: tagged + 4);
        expect(cards, hasLength(tagged + 4), reason: '$phase');
        for (var k = 0; k < cards.length; k++) {
          if (k < tagged) {
            expect(cards[k].phases, contains(phase),
                reason: '$phase slot $k: ${cards[k].id}');
          } else {
            expect(cards[k].phases, contains(TtcDayPhase.any),
                reason: '$phase filler $k: ${cards[k].id}');
          }
        }
        expect(cards.map((c) => c.id).toSet(), hasLength(cards.length),
            reason: 'no card twice in $phase');
      }
    });

    test('an unknown phase never shows a card written for one stretch', () {
      final cards = ttcInsightsForPhase(TtcDayPhase.any, day, count: 50);
      for (final c in cards) {
        expect(c.phases, contains(TtcDayPhase.any), reason: c.id);
      }
      for (final c in ttcPhaseInsights) {
        expect(c.phases, isNot(contains(TtcDayPhase.any)), reason: c.id);
      }
    });

    test('stable within a day, and it turns over', () {
      List<String> ids(DateTime d) =>
          ttcInsightsForPhase(TtcDayPhase.waiting, d).map((c) => c.id).toList();
      expect(ids(day), ids(DateTime(2026, 9, 26, 23, 59)));
      expect(ids(day), isNot(ids(day.add(const Duration(days: 1)))));
    });

    test('a count of zero is empty, a year of days never throws', () {
      expect(ttcInsightsForPhase(TtcDayPhase.late, day, count: 0), isEmpty);
      for (var d = 0; d < 366; d++) {
        final on = DateTime(2026).add(Duration(days: d));
        for (final p in TtcDayPhase.values) {
          expect(ttcInsightsForPhase(p, on), isNotEmpty);
          expect(ttcReadIdsForPhase(p, on), hasLength(4));
        }
      }
    });

    test('ids are unique across the everyday and phase cards', () {
      final ids = ttcAllInsights.map((i) => i.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(ttcAllInsights,
          hasLength(ttcInsights.length + ttcPhaseInsights.length));
    });

    test('every existing insight still fits somewhere', () {
      for (final i in ttcInsights) {
        expect(i.phases, isNotEmpty, reason: i.id);
      }
    });
  });

  group('the new copy keeps the voice rules', () {
    String copy(TtcInsight i) => [
          i.titleEn,
          i.bodyEn,
          i.takeawayEn,
          i.titleHi,
          i.bodyHi,
          i.takeawayHi,
        ].join('\n');

    const banned = [
      // ttc_daily_test's blame list
      'you failed', 'you missed', 'missed your fertile', 'you are behind',
      'perfect cycle', 'streak lost', 'try harder', 'should have',
      // docs/TTC-VOICE.md
      'journey', 'navigate', 'empower', 'delve', 'embark', 'game-changer',
      'crucial', "you've got this", 'rest assured', 'we understand how you feel',
      "it's important to note", "it's worth noting", "let's dive in",
      'genuinely', 'actually', 'quietly', 'simply', 'truly',
      'the single most', "here's the thing",
    ];

    test('no banned phrases', () {
      for (final i in ttcPhaseInsights) {
        final text = copy(i).toLowerCase();
        for (final b in banned) {
          expect(text, isNot(contains(b)), reason: '${i.id}: "$b"');
        }
      }
    });

    test('no dashes, exclamation marks or capitals for emphasis', () {
      for (final i in ttcPhaseInsights) {
        final text = copy(i);
        expect(text, isNot(contains('—')), reason: i.id);
        expect(text, isNot(contains('–')), reason: i.id);
        expect(text, isNot(contains(' - ')), reason: i.id);
        expect(text, isNot(contains('!')), reason: i.id);
        expect(RegExp(r'\b(?!hCG\b)[A-Z]{4,}\b').hasMatch(text), isFalse,
            reason: i.id);
      }
    });

    test('never a personal probability', () {
      final chance = RegExp(
          r'your\s+(chance|chances|probability|odds|success\s+rate)',
          caseSensitive: false);
      for (final i in ttcPhaseInsights) {
        expect(chance.hasMatch(copy(i)), isFalse, reason: i.id);
      }
    });

    test('the late cards say when to see a doctor', () {
      final late = ttcPhaseInsights
          .where((i) => i.phases.contains(TtcDayPhase.late))
          .map((i) => i.bodyEn)
          .join(' ');
      expect(late, contains('over a week late'));
      expect(late, contains('same day'));
    });
  });

  group('phase reads for the home rail', () {
    test('every read id in the table exists', () {
      for (final entry in kTtcPhaseReadIds.entries) {
        for (final id in entry.value) {
          expect(ttcReadById(id), isNotNull, reason: '${entry.key}: $id');
        }
        expect(entry.value.toSet(), hasLength(entry.value.length),
            reason: 'duplicate in ${entry.key}');
      }
    });

    test('every phase has a row, and returns four unique reads', () {
      for (final phase in TtcDayPhase.values) {
        expect(kTtcPhaseReadIds[phase], isNotEmpty, reason: '$phase');
        final ids = ttcReadIdsForPhase(phase, day);
        expect(ids, hasLength(4), reason: '$phase');
        expect(ids.toSet(), hasLength(4), reason: '$phase');
      }
    });

    test("the phase's own reads come first", () {
      for (final phase in phased) {
        final own = kTtcPhaseReadIds[phase]!;
        final ids = ttcReadIdsForPhase(phase, day, count: own.length + 2);
        expect(ids.take(own.length).toSet(), own.toSet(), reason: '$phase');
      }
    });

    test('waiting and late lead with testing reads', () {
      expect(kTtcPhaseReadIds[TtcDayPhase.waiting],
          containsAll(['ttc_read_two_week_wait', 'ttc_read_when_to_test']));
      expect(kTtcPhaseReadIds[TtcDayPhase.late],
          containsAll(['ttc_read_how_to_test', 'ttc_read_late_negative']));
    });
  });

  group('the phase comes from the same arithmetic as the cycle picture', () {
    TtcDayPhase on(int cycleDay,
            {TimingOwnership ownership = TimingOwnership.parentveda}) =>
        ttcDayPhaseForCycleDay(
          cycleDay: cycleDay,
          ovulationDay: 14,
          usualLength: 28,
          ownership: ownership,
        );

    test('a 28-day cycle, day by day', () {
      expect(on(1), TtcDayPhase.period);
      expect(on(5), TtcDayPhase.period);
      expect(on(6), TtcDayPhase.beforeWindow);
      expect(on(9), TtcDayPhase.window);
      expect(on(14), TtcDayPhase.window);
      expect(on(16), TtcDayPhase.waiting);
      expect(on(28), TtcDayPhase.waiting);
      // ⚠️ DAY 29 IS THE DUE DAY, NOT LATE (2026-09-26, consistency pass).
      // This asserted `late` on day 29, one day ahead of the hero ("may start
      // today"), the calendar ("Period expected") and the chat ("due today").
      // Late starts the day after the due day, everywhere.
      expect(on(29), TtcDayPhase.waiting);
      expect(on(30), TtcDayPhase.late);
    });

    test('a clinic-run cycle is not phased by us', () {
      expect(on(9, ownership: TimingOwnership.clinicGuided), TtcDayPhase.any);
      expect(
          on(9, ownership: TimingOwnership.clinicControlled), TtcDayPhase.any);
    });

    test('no logged period means no phase', () {
      expect(on(0), TtcDayPhase.any);
    });
  });
}
