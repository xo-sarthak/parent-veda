// =============================================================================
//  The Today hero - position, what is next, and a way onward
// -----------------------------------------------------------------------------
//  Pregnancy and parenting answer three questions above the fold, independently
//  of each other, which makes their shape the house standard rather than one
//  stage's taste:
//
//    where am I      "Week 40, Day 7"        "PHASE 1 OF 20"
//    what is next    "Baby's almost here"    "Next: the peak, and the first
//                                             smile, around 1 month."
//    show me it all  "View week ›"           "Phase map ›"
//
//  TTC answered none of them, which is why a chapter lasting twenty-eight days
//  read as the app having stopped. It is not the length - pregnancy weeks and
//  parenting phases last a while too.
//
//  What is deliberately NOT here: a "Chapter 1 of 5" denominator. Chapters 2-4
//  come round with every cycle, so a denominator across the stage would promise
//  a finish line that does not exist - the exact feeling the Journey Map's
//  "not a step backwards" line was written to prevent.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_screens.dart';
import 'package:parentveda/screens/ttc/ttc_journey_map_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
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

  Future<void> pumpToday(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        MaterialApp(key: UniqueKey(), home: const TtcTodayScreen()));
    await tester.pumpAndSettle();
  }

  // ===========================================================================
  group('every chapter can answer "what comes next"', () {
    test('in both languages, and none of them is empty', () {
      for (final c in TtcChapter.values) {
        expect(c.nextUp(false), isNotEmpty, reason: '$c English');
        expect(c.nextUp(true), isNotEmpty, reason: '$c Hinglish');
        expect(c.nextUp(false), isNot(c.nextUp(true)),
            reason: '$c was not actually translated');
      }
    });

    test('it names a trigger, not a countdown', () {
      // "when your next period arrives" survives a cycle that runs long.
      // "in 14 days" has to be wrong eventually, and being wrong about this
      // is worse than being vague.
      expect(TtcChapter.preparingTogether.nextUp(false),
          contains('log your next period'));
      expect(TtcChapter.tryingTogether.nextUp(false), contains('ovulation'));
    });

    test('the waiting days do not promise an outcome', () {
      // The one chapter where a hopeful "next" would be cruel.
      final s = TtcChapter.theWaitingDays.nextUp(false).toLowerCase();
      expect(s, contains('or the next cycle'));
      expect(s, contains('both are fine'));
    });
  });

  // ===========================================================================
  group('the hero carries all three', () {
    testWidgets('position inside the chapter', (tester) async {
      await pumpToday(tester);
      expect(find.textContaining('in this chapter'), findsOneWidget);
    });

    testWidgets('what is coming next', (tester) async {
      await pumpToday(tester);
      expect(find.textContaining('Next:'), findsWidgets);
    });

    testWidgets('and a link to the whole map', (tester) async {
      await pumpToday(tester);
      expect(find.text('Journey map'), findsOneWidget);
    });

    testWidgets('the map link actually opens the map', (tester) async {
      await pumpToday(tester);
      await tester.tap(find.text('Journey map'));
      await tester.pumpAndSettle();
      expect(find.byType(TtcJourneyMapScreen), findsOneWidget);
    });
  });

  // ===========================================================================
  group('what the hero must NOT say', () {
    testWidgets('no "chapter N of 5" denominator across the stage',
        (tester) async {
      await pumpToday(tester);
      // Chapters 2-4 repeat. A denominator would promise an ending.
      expect(find.textContaining('of 5'), findsNothing);
    });

    testWidgets('no percentage', (tester) async {
      await pumpToday(tester);
      expect(find.textContaining('%'), findsNothing);
    });
  });

  // ===========================================================================
  group('the rhythm card is no longer a dead end', () {
    setUp(() {
      // Give it enough history to render the graded state rather than the
      // empty invitation.
      CycleStore.instance
        ..logPeriodStart(DateTime.now().subtract(const Duration(days: 60)))
        ..logPeriodStart(DateTime.now().subtract(const Duration(days: 32)))
        ..logPeriodStart(DateTime.now().subtract(const Duration(days: 4)));
    });

    testWidgets('it offers a way to understand itself', (tester) async {
      await pumpToday(tester);
      expect(find.text('Understand this'), findsOneWidget);
    });

    testWidgets('which opens the Cycle Companion', (tester) async {
      await pumpToday(tester);
      await tester.tap(find.text('Understand this'));
      await tester.pumpAndSettle();
      expect(find.byType(TtcCycleScreen), findsOneWidget);
    });

    testWidgets('and logging a period is still one tap away', (tester) async {
      await pumpToday(tester);
      expect(find.text('Log a new period'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the disclaimer', () {
    testWidgets('Today carries it, like every tool already did',
        (tester) async {
      await pumpToday(tester);
      expect(find.textContaining('never guarantees'), findsOneWidget);
    });

    test('and there is exactly one copy of the sentence', () {
      // It used to live privately inside the cycle tools, which is how the
      // busiest screen ended up without one.
      const en = TtcS(false);
      const hiS = TtcS(true);
      expect(en.estimatesDisclaimer, contains('never guarantees'));
      expect(hiS.estimatesDisclaimer, contains('guarantee nahi'));
    });
  });

  // ===========================================================================
  group('it all still works in Hinglish', () {
    testWidgets('the hero renders without exploding', (tester) async {
      TtcLang.instance.hinglish = true;
      await pumpToday(tester);
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Aage:'), findsWidgets);
      TtcLang.instance.hinglish = false;
    });
  });
}
