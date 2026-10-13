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

    // ⚠️ THE KEY IS ONE LINE NOW, ALWAYS SHOWN (2026-09-27, the calendar
    // redesign): nothing to fold, and nothing hidden behind a title. Kept for
    // revert: this test tapped "What the colours mean" and expected the rows
    // to fold away.
    testWidgets('the key is one line under the grid, always shown',
        (tester) async {
      await pumpCalendar(tester);
      expect(find.textContaining('colours'), findsNothing);
      expect(find.text('Period'), findsWidgets);
      expect(find.text('Today'), findsWidgets);
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

  // ===========================================================================
  //  2026-10-13: the answer first, one scroll of weeks, estimates striped
  // ===========================================================================
  group('the calendar after the Mobbin pass', () {
    testWidgets('a sentence above the grid says where she is and what is next',
        (tester) async {
      logCleanHistory();
      await pumpCalendar(tester);
      expect(find.byKey(const ValueKey('ttc_calendar_summary')), findsOneWidget);
      final line = ttcCalendarSummaryLine()!;
      expect(line, contains('fertile days'));
      expect(line.contains('%'), isFalse, reason: 'never a probability');
    });

    testWidgets('and nothing when there is nothing to estimate from',
        (tester) async {
      await pumpCalendar(tester);
      expect(find.byKey(const ValueKey('ttc_calendar_summary')), findsNothing);
    });

    testWidgets('the weeks scroll, and the arrow steps a month', (tester) async {
      logCleanHistory();
      await pumpCalendar(tester);
      expect(find.byKey(const ValueKey('ttc_calendar_weeks')), findsOneWidget);
      final n = DateTime.now();
      final next = DateTime(n.year, n.month + 1);
      // The next month's 1st is labelled in the run, not on a new page.
      expect(
          find.byKey(ValueKey('ttc_cal_month_label_${next.year}_${next.month}')),
          findsOneWidget);
      await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
      await tester.pumpAndSettle();
      final title = tester.widget<Text>(
          find.byKey(const ValueKey('ttc_calendar_month_title')));
      expect(title.data, endsWith('${next.year}'));
      const names = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
      expect(title.data, startsWith(names[next.month - 1]));
    });

    testWidgets('fertile days still ahead are striped, and the key says so',
        (tester) async {
      logCleanHistory();
      await pumpCalendar(tester);
      expect(find.byKey(const ValueKey('ttc_cal_estimate_stripes')),
          findsWidgets);
      expect(find.text(kTtcCalendarEstimateKey), findsOneWidget);
    });

    test('today is not "ahead"; tomorrow is', () {
      final n = DateTime.now();
      expect(ttcIsAhead(n), isFalse);
      expect(ttcIsAhead(DateTime(n.year, n.month, n.day + 1)), isTrue);
    });
  });
}
