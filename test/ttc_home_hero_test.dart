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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_screens.dart';
import 'package:parentveda/screens/ttc/ttc_chapter_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_journey_map_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_parts.dart';
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

    testWidgets('what is coming next — one tap in, not printed on the hero',
        (tester) async {
      // This USED to assert `Next:` inline on the hero, because that is where I
      // first put it. It has moved into the ⓘ sheet, and that is a fix rather
      // than a regression:
      //
      //   "Next: Knowing Your Rhythm — from the day you log your next period"
      //
      // named an internal chapter the reader has no reason to recognise yet, so
      // it cost two lines of the most valuable space in the stage and explained
      // nothing. In the sheet it can be a sentence with a heading over it.
      //
      // The REQUIREMENT was never "print it on the hero" — it was that a
      // twenty-eight-day chapter must not read as the app having stopped. The
      // segmented bar and "Day N of 28" carry that. So this now asserts the
      // answer is REACHABLE, which is what it always should have asserted.
      await pumpToday(tester);
      expect(find.textContaining('Next:'), findsNothing,
          reason: 'the fragment is back on the hero');

      await tester.tap(find.byType(TtcChapterInfoButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('Next:'), findsWidgets);
      expect(find.text(const TtcS(false).infoWhatMovesYouOn.toUpperCase()),
          findsOneWidget);
    });

    testWidgets('and the sheet answers the question the title raises',
        (tester) async {
      // "What does Preparing Together actually mean?" is a question about the
      // title, so it is answered beside the title.
      await pumpToday(tester);
      await tester.tap(find.byType(TtcChapterInfoButton));
      await tester.pumpAndSettle();
      const t = TtcS(false);
      expect(find.text(t.infoWhatThisIs.toUpperCase()), findsOneWidget);
      expect(find.text(t.infoWorthDoing.toUpperCase()), findsOneWidget);
      // The sentence that was nowhere on the screen at all.
      expect(find.text(t.infoNotToWorry.toUpperCase()), findsOneWidget);
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
      // The Hinglish "Aage:" moved into the sheet with its English twin.
      await tester.tap(find.byType(TtcChapterInfoButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('Aage:'), findsWidgets);
      TtcLang.instance.hinglish = false;
    });
  });

  // ===========================================================================
  group("the hero is the same component as pregnancy's", () {
    testWidgets('it sits under a named eyebrow', (tester) async {
      await pumpToday(tester);
      // Pregnancy has "WEEKLY SNAPSHOT", parenting "HOW YOUR BABY IS TODAY".
      // TTC's hero floated with nothing naming it.
      expect(find.text('YOUR CHAPTER'), findsOneWidget);
    });

    testWidgets('the progress is segmented, one per chapter', (tester) async {
      await pumpToday(tester);
      expect(find.byType(TtcChapterBar), findsOneWidget);
      // Matching pregnancy's T1 / T2 / T3 labels under the bar.
      for (final n in ['1', '2', '3', '4', '5']) {
        expect(find.text(n), findsWidgets, reason: 'segment $n');
      }
    });

    testWidgets('and the shortcuts are circles, like Baby / Mother / next',
        (tester) async {
      await pumpToday(tester);
      expect(find.byType(TtcHeroShortcut), findsNWidgets(3));
    });

    testWidgets('the shortcuts still open the chapter screen', (tester) async {
      await pumpToday(tester);
      await tester.tap(find.byType(TtcHeroShortcut).first);
      await tester.pumpAndSettle();
      expect(find.byType(TtcChapterScreen), findsOneWidget);
    });
  });

  // ===========================================================================
  group('but the bar does NOT accumulate across chapters', () {
    test('only the current segment is ever filled', () {
      // Pregnancy fills T1 then T2 then T3 because a pregnancy only moves
      // forward. Chapters 2-4 come round with every cycle, so a bar that
      // reached 80% and dropped back to 40% would say "you lost ground" on the
      // morning a period arrives. The shape is borrowed; the claim is not.
      const src = 'lib/screens/ttc/ttc_common.dart';
      final text = File(src).readAsStringSync();
      final bar = text.substring(text.indexOf('class TtcChapterBar'));
      expect(bar, contains('if (active)'),
          reason: 'segments fill cumulatively again');
    });
  });
}
