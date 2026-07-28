// =============================================================================
//  TTC Calendar - making the fertile window visible
// -----------------------------------------------------------------------------
//  The window was drawn as a tint on each individual day. At "medium" that tint
//  was a hair off white, so the most important days of the month were the least
//  visible thing on the screen - and six separate circles never read as one
//  stretch anyway.
//
//  The pregnancy calendar had already solved this: it draws its birth window as
//  a single soft capsule spanning the row, with week markers in the margin. TTC
//  now does the same.
//
//  Also fixed here: the two stages disagreed about which day the week starts
//  on, the ovulation marker was the only brown in a pink-and-purple palette,
//  "Today" was missing from a legend that was folded shut by default, and a
//  window crossing a month boundary simply vanished at the edge of the grid.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_calendar_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  /// A clean 28-day history so the engine actually produces a window.
  void logCleanHistory() {
    final now = DateTime.now();
    CycleStore.instance
      ..logPeriodStart(now.subtract(const Duration(days: 68)))
      ..logPeriodStart(now.subtract(const Duration(days: 40)))
      ..logPeriodStart(now.subtract(const Duration(days: 12)));
  }

  Future<void> pumpCalendar(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 8000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        MaterialApp(key: UniqueKey(), home: const TtcCalendarScreen()));
    await tester.pumpAndSettle();
  }

  // ===========================================================================
  group('the week starts where the rest of the app starts it', () {
    testWidgets('Sunday first, matching pregnancy', (tester) async {
      await pumpCalendar(tester);
      // S M T W T F S - the first header cell is Sunday.
      final headers = tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data)
          .where((d) => d != null && d.length == 1)
          .take(7)
          .toList();
      expect(headers.first, 'S');
      expect(headers[1], 'M');
    });
  });

  // ===========================================================================
  group('the fertile window is one band, not six faint circles', () {
    testWidgets('a spanning capsule is drawn when there is a window',
        (tester) async {
      logCleanHistory();
      await pumpCalendar(tester);
      expect(find.byType(TtcFertileBand), findsWidgets);
    });

    testWidgets('and none at all when the engine refuses to estimate',
        (tester) async {
      // No history logged: no window, so nothing to draw.
      await pumpCalendar(tester);
      final bands = tester.widgetList(find.byType(TtcFertileBand));
      expect(bands, isEmpty);
    });
  });

  // ===========================================================================
  group('the legend', () {
    testWidgets('is open by default', (tester) async {
      await pumpCalendar(tester);
      // Eight markers with the key folded away is a puzzle, not a legend.
      expect(find.text('Period'), findsWidgets);
    });

    testWidgets('names Today, which is the boldest ring on the grid',
        (tester) async {
      await pumpCalendar(tester);
      // It was absent entirely, so a user saw a purple ring with no key entry.
      expect(find.text('Today'), findsWidgets);
    });

    testWidgets('and can still be folded away once she knows them',
        (tester) async {
      await pumpCalendar(tester);
      await tester.tap(find.textContaining('colours').first);
      await tester.pumpAndSettle();
      expect(find.text('Period'), findsNothing);
    });
  });

  // ===========================================================================
  group('a window that crosses a month boundary says so', () {
    testWidgets('nothing is said when it fits inside the month',
        (tester) async {
      await pumpCalendar(tester);
      expect(find.textContaining('continues into'), findsNothing);
      expect(find.textContaining('began in'), findsNothing);
    });

    test('both directions have copy, in both languages', () {
      const en = TtcS(false);
      const hi = TtcS(true);
      expect(en.continuesInto('August'), contains('August'));
      expect(en.continuedFrom('July'), contains('July'));
      expect(hi.continuesInto('August'), isNot(en.continuesInto('August')));
    });
  });

  // ===========================================================================
  group('copy', () {
    test('the headline is warm, not corporate', () {
      const t = TtcS(false);
      // "Your command centre" sat in a stage whose every other headline is
      // gentle.
      expect(t.calendarTitle.toLowerCase(), isNot(contains('command')));
    });
  });

  // ===========================================================================
  group('the day facts still drive everything', () {
    test('the calendar and the engine cannot disagree', () {
      logCleanHistory();
      final now = DateTime.now();
      const engine = TtcChapterEngine();
      final state = TtcStore.instance.state(on: now);
      final facts = ttcFactsFor(now);
      expect(facts.fertility, engine.fertilityFor(state, engine.cycleDay(state)),
          reason: 'the grid is reading a different engine than Today');
    });

    test('and no expected-period marker exists on a clinic cycle', () {
      logCleanHistory();
      TtcStore.instance.setPath(TtcPath.ivf);
      final future = DateTime.now().add(const Duration(days: 20));
      expect(ttcFactsFor(future).isExpectedPeriod, isFalse);
    });
  });
}
