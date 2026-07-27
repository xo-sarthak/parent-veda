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

  /// The exact history that produced "ovulation around day 40" on a device.
  void logTheRealDefect() {
    for (final d in [
      DateTime(2026, 4, 17),
      DateTime(2026, 4, 24),
      DateTime(2026, 5, 8),
      DateTime(2026, 7, 1), // 54-day gap - nothing logged in between
      DateTime(2026, 7, 5),
      DateTime(2026, 7, 7),
      DateTime(2026, 7, 8),
      DateTime(2026, 7, 13),
      DateTime(2026, 7, 16),
      DateTime(2026, 7, 22),
      DateTime(2026, 7, 25),
    ]) {
      CycleStore.instance.logPeriodStart(d);
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
      final s = TtcStore.instance.state(on: DateTime(2026, 7, 27));
      expect(engine.hasUnreliableHistory(s), isTrue);
      expect(engine.estimatedOvulationDay(s), isNull,
          reason: 'this is where "ovulation around day 40" came from');
      expect(engine.whyNoEstimate(s), TtcNoEstimate.historyLooksOff);
    });

    test('so no fertility grade rides on it either', () {
      logTheRealDefect();
      final s = TtcStore.instance.state(on: DateTime(2026, 7, 27));
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
      expect(find.textContaining('day 40'), findsNothing);
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
    test('the store says which gaps it counted', () {
      logTheRealDefect();
      // The 54-day gap counts; the three-day one does not.
      expect(CycleStore.instance.gapBefore(DateTime(2026, 7, 1))?.counted,
          isTrue);
      expect(CycleStore.instance.gapBefore(DateTime(2026, 7, 5))?.counted,
          isFalse);
    });

    test('the oldest entry is neither counted nor discarded', () {
      logTheRealDefect();
      expect(CycleStore.instance.gapBefore(DateTime(2026, 4, 17)), isNull);
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
