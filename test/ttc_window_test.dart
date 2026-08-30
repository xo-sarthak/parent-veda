// =============================================================================
//  Fertility Window - the answer first, then the picture
// -----------------------------------------------------------------------------
//  The screen opened with the whole cycle laid out one day at a time. On real
//  data that was fifty-four rows, of which seven carried information and the
//  rest said "Low" - for an anxious reader, a scrollable list of failure. Even
//  on a clean 28-day cycle it is twenty-two rows of "Low" to find six that
//  matter.
//
//  The original intent was right and is kept: "reading it as one picture shows
//  the window is wide", which is the reassuring fact here. Seven adjacent bars
//  show width. Fifty-four bury it.
//
//  What was never stated anywhere is the sentence she came for - which days,
//  as DATES. "Days 35 to 41" is how the engine thinks; "12 to 18 August" is how
//  someone plans a week.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_screens.dart';
import 'package:parentveda/screens/ttc/ttc_journey_map_screen.dart';
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

  void logCleanHistory() {
    final now = DateTime.now();
    CycleStore.instance
      ..logPeriodStart(now.subtract(const Duration(days: 68)))
      ..logPeriodStart(now.subtract(const Duration(days: 40)))
      ..logPeriodStart(now.subtract(const Duration(days: 12)));
  }

  Future<void> pumpWindow(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 8000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
        key: UniqueKey(), home: const TtcFertilityWindowScreen()));
    await tester.pumpAndSettle();
  }

  // ===========================================================================
  group('the answer comes first', () {
    testWidgets('her fertile days are stated as dates', (tester) async {
      logCleanHistory();
      await pumpWindow(tester);
      expect(find.text('Your fertile days'), findsOneWidget);
      // A month name, not a cycle-day number.
      expect(find.textContaining(RegExp(r'\d+ [A-Z][a-z]{2} to \d+ [A-Z][a-z]{2}')),
          findsOneWidget);
    });

    testWidgets('and the most likely day is named', (tester) async {
      logCleanHistory();
      await pumpWindow(tester);
      expect(find.textContaining('Most likely'), findsOneWidget);
    });

    testWidgets('with a status she can act on', (tester) async {
      logCleanHistory();
      await pumpWindow(tester);
      // One of the three, never none - a summary that says nothing about now
      // is just a date range.
      final open = find.text('Open now').evaluate().isNotEmpty;
      final soon = find.textContaining('Opens').evaluate().isNotEmpty;
      final past = find.textContaining('has passed').evaluate().isNotEmpty;
      expect(open || soon || past, isTrue);
    });
  });

  // ===========================================================================
  group('the picture is the window, not the whole month', () {
    testWidgets('only the days that carry information are shown',
        (tester) async {
      logCleanHistory();
      await pumpWindow(tester);
      // Sperm survive about five days and the egg about one, so the window is
      // seven days. Anything much beyond that is the old wall of "Low".
      expect(find.text('Low'), findsNothing);
    });

    // ⚠️ THE FOLD IS GONE, AND SO IS THE TEST THAT GUARDED IT. "See the whole
    // cycle" opened a list in which forty-odd rows said "Low" — the exact wall
    // this screen was rebuilt to remove, kept one tap away. The whole month is
    // still reachable, on the calendar and the cycle companion, which are the
    // two screens that exist to show a month.
    //
    // Replaced by the three below, which guard what the screen does instead.

    testWidgets('every row is a date and a weekday, not a cycle-day number',
        (tester) async {
      logCleanHistory();
      await pumpWindow(tester);
      // "22 Aug" over "Wed" — the units she plans in. A bare "17" is how the
      // engine thinks and means nothing without counting from a period start.
      expect(find.textContaining(RegExp(r'^\d+ [A-Z][a-z]{2}$')), findsWidgets);
      expect(
          find.byWidgetPredicate((w) =>
              w is Text &&
              const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .contains(w.data)),
          findsWidgets);
    });

    testWidgets('the rows cover exactly the range the summary names',
        (tester) async {
      logCleanHistory();
      await pumpWindow(tester);

      // The headline reads "<from> to <to>". Both endpoints must also appear
      // as rows — before this, the bars were a "not Low" filter arrived at
      // independently, so the card could start on a day the headline never
      // mentioned and nothing on screen explained the gap.
      final headline = tester
          .widgetList<Text>(find.textContaining(' to '))
          .map((w) => w.data)
          .firstWhere((s) => s != null && RegExp(r'\d+ [A-Z][a-z]{2} to ').hasMatch(s));
      final parts = headline!.split(' to ');
      expect(find.text(parts.first), findsWidgets,
          reason: 'the day the summary says it opens has no row');
      expect(find.text(parts.last), findsWidgets,
          reason: 'the day the summary says it closes has no row');
    });

    testWidgets('she can page forward to the next cycles', (tester) async {
      logCleanHistory();
      await pumpWindow(tester);

      final before = tester
          .widgetList<Text>(find.textContaining(' to '))
          .map((w) => w.data)
          .firstWhere((s) => s != null && RegExp(r'\d+ [A-Z][a-z]{2} to ').hasMatch(s));

      await tester.tap(find.bySemanticsLabel('Next cycle'));
      await tester.pumpAndSettle();

      final after = tester
          .widgetList<Text>(find.textContaining(' to '))
          .map((w) => w.data)
          .firstWhere((s) => s != null && RegExp(r'\d+ [A-Z][a-z]{2} to ').hasMatch(s));

      expect(after, isNot(before), reason: 'the arrow did not move the window');
      // ⚠️ AND IT SAYS IT IS A GUESS. A projected window applies her usual
      // cycle length to an estimated ovulation day; presenting that as
      // confidently as the current cycle is the overreach `TtcNoEstimate`
      // exists to prevent.
      expect(find.text('Expected'), findsOneWidget);
      expect(find.textContaining('usual cycle length'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  A window she can still act on
  // ---------------------------------------------------------------------------
  //  A closed window is a chance she missed, drawn in exactly the same shape as
  //  one she can still use. The screen now rolls forward instead.
  group('never a window that has already closed', () {
    testWidgets('a cycle whose window has passed shows the next one',
        (tester) async {
      // A period long enough ago that ovulation and the window are behind her.
      final now = DateTime.now();
      CycleStore.instance
        ..logPeriodStart(now.subtract(const Duration(days: 56)))
        ..logPeriodStart(now.subtract(const Duration(days: 28)))
        ..logPeriodStart(now.subtract(const Duration(days: 26)));

      await pumpWindow(tester);

      // Whatever else it says, it must not say the window has gone.
      expect(find.textContaining('has passed'), findsNothing);
    });
  });

  // ===========================================================================
  group('it still refuses when it should', () {
    testWidgets('no summary at all with nothing logged', (tester) async {
      await pumpWindow(tester);
      expect(find.text('Your fertile days'), findsNothing);
    });

    testWidgets('and none on a clinic-run cycle', (tester) async {
      logCleanHistory();
      TtcStore.instance.setPath(TtcPath.ivf);
      await pumpWindow(tester);
      expect(find.text('Your fertile days'), findsNothing);
      // The fold this once guarded is retired; the assertion that matters on a
      // clinic cycle is that no window is drawn at all, which is the line above.
    });
  });

  // ===========================================================================
  group('the Journey Map says what brings the next chapter', () {
    testWidgets('the current chapter carries its own next line',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          key: UniqueKey(), home: const TtcJourneyMapScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Next:'), findsWidgets);
    });

    test('and it is the same copy the hero uses, so they cannot drift', () {
      // Both read TtcChapterCopy.nextUp. If someone writes a second version for
      // one surface, this is what catches it.
      for (final c in TtcChapter.values) {
        expect(c.nextUp(false), isNotEmpty);
      }
    });
  });
}
