// =============================================================================
//  The data chain - one bad value used to reach five screens
// -----------------------------------------------------------------------------
//  Real logged data: gaps of 7, 14, 54, 4, 2, 1, 5, 3, 6, 3 days. The store
//  keeps only clinically plausible cycles (15-90 days), so exactly ONE survived
//  - 54 - and it was not a cycle at all but an eight-week stretch where nothing
//  had been logged.
//
//  The engine then did the honest half and the dishonest half together: it
//  worked out the history was unreliable, dropped confidence to `low`, and
//  printed "ovulation around day 40" anyway. That number reached Today, the
//  Cycle Companion, the Ovulation Companion, the Fertility Window and the
//  Calendar.
//
//  Two rules pinned here:
//    1. If we have decided a number is unreliable, we do not show it.
//    2. Every refusal names itself, because a blank with no reason reads as a
//       broken app and tells her nothing about what to do next.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
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
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  /// The eleven starts, as days before today. Named singly below where a test
  /// needs to point at one row rather than at the shape as a whole.
  const kDefectStarts = [101, 94, 80, 26, 22, 20, 19, 14, 11, 5, 2];

  /// The row the 54 days belong to — the cycle that ran across the unlogged
  /// month. `kBeforeTheGap - kAfterTheGap` is 54, and that is the whole
  /// fixture.
  const kBeforeTheGap = 80;

  /// The row on the far side of it, which the screen used to blame for the gap.
  const kAfterTheGap = 26;

  /// The oldest start. Seven days to the next one, so it is not counted.
  const kFirstStart = 101;

  DateTime ago(int days) {
    final d = DateTime.now().subtract(Duration(days: days));
    return DateTime(d.year, d.month, d.day);
  }

  /// The exact history that produced "ovulation around day 40" on a device.
  ///
  /// ⚠️ RELATIVE, AND IT USED TO BE ABSOLUTE. The eleven dates were written
  /// down as they came off the device — 17 April, 24 April, 8 May, then a
  /// 54-day gap. Every other fixture in this file pairs its dates with an
  /// explicit `state(on:)`, so the clock never enters and absolute dates are
  /// harmless. The widget test below is the exception: it renders
  /// `TtcTodayScreen`, which reads `DateTime.now()` itself, so the cycle day on
  /// screen depended on the day the suite happened to run.
  ///
  /// It fired on 2 September 2026, when 25 July became cycle day 40 and the
  /// screen's ordinary "Cycle day 40" readout tripped an assertion written to
  /// catch the phrase "ovulation around day 40". It passed again the next
  /// morning — which is worse than failing permanently, because a test that
  /// fails one day a month gets shrugged at rather than fixed, and this one
  /// guards a clinical defect. It also cost a session: a handoff blamed the
  /// failure on an unrelated change, which is exactly what a test that depends
  /// on the date does to whoever sees it next.
  ///
  /// Only the GAPS ever mattered — the 54-day one especially — so the offsets
  /// below preserve them exactly and hang them off today. The most recent start
  /// sits two days back, which puts today on cycle day 3, the same position the
  /// old fixed reference date of 27 July described.
  void logTheRealDefect() {
    for (final daysAgo in kDefectStarts) {
      CycleStore.instance.logPeriodStart(ago(daysAgo));
    }
  }

  // ===========================================================================
  group('the exact defect, reproduced then refused', () {
    test('the history really does reduce to a single 54-day "cycle"', () {
      logTheRealDefect();
      expect(CycleStore.instance.cycleLengths, [54],
          reason: 'the setup no longer reproduces the original defect');
    });

    test('and we no longer publish a number built on it', () {
      logTheRealDefect();
      final s = TtcStore.instance.state();
      expect(engine.hasUnreliableHistory(s), isTrue);
      expect(engine.estimatedOvulationDay(s), isNull,
          reason: 'this is where "ovulation around day 40" came from');
      expect(engine.whyNoEstimate(s), TtcNoEstimate.historyLooksOff);
    });

    test('so no fertility grade rides on it either', () {
      logTheRealDefect();
      final s = TtcStore.instance.state();
      expect(engine.fertilityFor(s, engine.cycleDay(s)), isNull);
    });

    testWidgets('and Today says WHY rather than showing a hole',
        (tester) async {
      logTheRealDefect();
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          MaterialApp(key: UniqueKey(), home: const TtcTodayScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('looks off'), findsWidgets);
      // ⚠️ THE PHRASE, NOT THE NUMBER. "day 40" also matches the ordinary
      // cycle-day readout Today prints small under its header, which is a
      // perfectly correct thing for it to say. What must never come back is the
      // estimate that was built on an unlogged month.
      expect(find.textContaining('ovulation around day'), findsNothing);
    });
  });

  // ===========================================================================
  group('an overdue cycle is a different refusal', () {
    test('past its own history, we stop estimating', () {
      // A clean 28-day history, then day 45 of the current cycle.
      for (final d in [
        DateTime(2026, 4, 20),
        DateTime(2026, 5, 18),
        DateTime(2026, 6, 15),
      ]) {
        CycleStore.instance.logPeriodStart(d);
      }
      final s = TtcStore.instance.state(on: DateTime(2026, 7, 30));
      expect(engine.isCurrentCycleOverdue(s), isTrue);
      expect(engine.estimatedOvulationDay(s), isNull);
      expect(engine.whyNoEstimate(s), TtcNoEstimate.cycleOverdue);
    });

    test('and it is named as normal, not as a warning', () {
      const t = TtcS(false);
      expect(t.noEstOverdueBody, contains('not a warning sign'));
      // But it still routes onward if it keeps happening.
      expect(t.noEstOverdueBody, contains('doctor'));
    });
  });

  // ===========================================================================
  group('a body signal still beats every doubt', () {
    test('an LH strip this cycle overrides an unreliable history', () {
      logTheRealDefect();
      CycleStore.instance.logLhPositive(11);
      final s = TtcStore.instance.state(on: DateTime(2026, 7, 27));
      expect(engine.hasUnreliableHistory(s), isTrue);
      expect(engine.estimatedOvulationDay(s), 12,
          reason: 'her own observation is evidence about THIS cycle');
      expect(engine.whyNoEstimate(s), TtcNoEstimate.none);
    });
  });

  // ===========================================================================
  group('every refusal has a reason, and the right one', () {
    test('nothing logged', () {
      expect(engine.whyNoEstimate(TtcStore.instance.state()),
          TtcNoEstimate.noPeriodLogged);
    });

    test('a clinic owning the timing is never explained as a data problem', () {
      // "Still learning your rhythm" would be a lie here: we are not learning,
      // we are deferring.
      CycleStore.instance.logPeriodStart(DateTime.now().subtract(
          const Duration(days: 5)));
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      final s = TtcStore.instance.state();
      expect(engine.whyNoEstimate(s), TtcNoEstimate.clinicOwnsTiming);
    });

    test('a clean history produces no refusal at all', () {
      for (final d in [
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 29),
        DateTime(2026, 7, 27),
      ]) {
        CycleStore.instance.logPeriodStart(d);
      }
      final s = TtcStore.instance.state(on: DateTime(2026, 8, 5));
      expect(engine.whyNoEstimate(s), TtcNoEstimate.none);
      expect(engine.estimatedOvulationDay(s), isNotNull);
    });
  });

  // ===========================================================================
  group('the list and the stats can no longer disagree', () {
    test('a cycle belongs to the date it BEGAN on', () {
      logTheRealDefect();
      // The 54 days ran from the row before the gap to the row after it, so
      // they belong to the cycle that BEGAN before it. Attributing them to the
      // later row instead is what made the screen print "54 days · Not counted
      // · too close to the entry before it" - the number describing one cycle
      // and the verdict describing another.
      final across = CycleStore.instance.cycleFrom(ago(kBeforeTheGap));
      expect(across?.days, 54);
      expect(across?.counted, isTrue);
    });

    test('the length shown and the verdict shown are the same fact', () {
      logTheRealDefect();
      // Every row, not just the interesting one: whatever number a row prints,
      // its counted-ness must be about THAT number.
      for (final daysAgo in kDefectStarts.take(5)) {
        final c = CycleStore.instance.cycleFrom(ago(daysAgo))!;
        final plausible = c.days >= CycleStore.minPlausibleCycleDays &&
            c.days <= CycleStore.maxPlausibleCycleDays;
        expect(c.counted, plausible,
            reason: '$daysAgo days ago printed ${c.days} days but judged '
                'otherwise');
      }
    });

    test('short gaps are not quietly counted', () {
      logTheRealDefect();
      // These two were shown with the "counted" dot while the average above
      // them excluded both - the list contradicting the statistic beside it.
      expect(CycleStore.instance.cycleFrom(ago(kFirstStart))?.counted, isFalse,
          reason: '7 days');
      expect(CycleStore.instance.cycleFrom(ago(kAfterTheGap))?.counted, isFalse,
          reason: '4 days');
    });

    test('a too-LONG gap is not explained as too close', () {
      // One string used to cover both directions, so a 100-day gap - almost
      // always a period nobody logged - was explained to her as being too
      // close together. The app visibly not reading her own data.
      const t = TtcS(false);
      expect(t.notCountedWhy(4).toLowerCase(), contains('too close'));
      expect(t.notCountedWhy(120).toLowerCase(), isNot(contains('too close')));
      expect(t.notCountedWhy(120).toLowerCase(), contains('never logged'));
      // And it names the right neighbour: the cycle on this row runs FORWARD.
      expect(t.notCountedWhy(4).toLowerCase(), contains('next entry'));

      const hi = TtcS(true);
      expect(hi.notCountedWhy(4), isNot(hi.notCountedWhy(120)));
    });

    test('the most recent entry has no length yet', () {
      logTheRealDefect();
      // Her current cycle has not ended, so there is no number to print and
      // nothing to judge.
      expect(CycleStore.instance.cycleFrom(DateTime(2026, 7, 25)), isNull);
    });

    test('every counted cycle appears in the average, and no other', () {
      logTheRealDefect();
      final counted = <int>[];
      for (final s in CycleStore.instance.periodStarts) {
        final c = CycleStore.instance.cycleFrom(s);
        if (c != null && c.counted) counted.add(c.days);
      }
      // The one place the two representations meet. If this ever fails, the
      // list and the stats card have started disagreeing again.
      expect(counted..sort(), CycleStore.instance.cycleLengths.toList()..sort());
    });

    test('the gap before a new entry is knowable before it is accepted', () {
      CycleStore.instance.logPeriodStart(DateTime(2026, 7, 1));
      expect(
          CycleStore.instance.daysSincePreviousStart(DateTime(2026, 7, 4)), 3);
      expect(CycleStore.instance.daysSincePreviousStart(DateTime(2026, 6, 1)),
          isNull,
          reason: 'nothing before it to measure against');
    });

    test('"1 day", not "1 days"', () {
      const t = TtcS(false);
      expect(t.cycleDayCount(1), '1 day');
      expect(t.cycleDayCount(28), '28 days');
    });
  });

  // ===========================================================================
  group('the plausibility window is not a secret any more', () {
    test('it is public, because the UI has to explain it', () {
      expect(CycleStore.minPlausibleCycleDays, 15);
      expect(CycleStore.maxPlausibleCycleDays, 90);
    });

    test('and the warning copy names the actual gap', () {
      const t = TtcS(false);
      expect(t.tooCloseWarning(3), contains('3 days'));
    });
  });
}
