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
import 'package:parentveda/screens/ttc/ttc_home_v3.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_fertile_window.dart';
import 'package:parentveda/ttc/ttc_home_hero.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

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
      // Kept for revert (2026-09-28, explicit labels):
      //   expect(find.text('Understand this'), findsOneWidget);
      expect(find.text('Understand your cycle'), findsOneWidget);
    });

    testWidgets('which opens the Cycle Companion', (tester) async {
      await pumpToday(tester);
      // Kept for revert: await tester.tap(find.text('Understand this'));
      await tester.tap(find.text('Understand your cycle'));
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

  // ===========================================================================
  //  The hero speaks on every day of the cycle — 2026-09-05
  // ---------------------------------------------------------------------------
  //  ⚠️ THE BUG THIS GROUP EXISTS FOR WAS INVISIBLE TO EVERY TEST ABOVE. The
  //  hero had five states and the estimate one only distinguished "window open"
  //  from "window opens in N days". Once the window closed, the engine rolled
  //  forward to NEXT cycle's window and the hero said "expected around 20 Sep
  //  to 25 Sep" for the entire two-week wait — a fortnight of one unchanging
  //  sentence about a cycle she was not in.
  //
  //  Nothing failed. Every individual state rendered correctly. The hole was in
  //  the coverage, which is why these walk a whole synthetic cycle DAY BY DAY
  //  rather than checking a handful of interesting days.
  // ===========================================================================
  group('the hero says something different as the cycle turns', () {
    /// Put her on `cycleDay` of a 28-day cycle by backdating the last period.
    ///
    /// ⚠️ THE TWO HISTORICAL STARTS ARE PINNED TO THE CURRENT ONE, NOT TO
    /// TODAY, AND THE FIRST VERSION OF THIS HARNESS GOT IT WRONG. Backdating
    /// them from `DateTime.now()` while the current start moved meant the GAPS
    /// between logged periods changed on every iteration — so the store
    /// recomputed her usual cycle length as 28, then 27, then 26, and the
    /// window slid a day earlier each time.
    ///
    /// The test then failed with "the last fertile day fired on 2 days", which
    /// reads exactly like an off-by-one in the state machine and was not. Worth
    /// remembering: when a test that walks a range fails at one point in the
    /// range, suspect the fixture before the code.
    void onCycleDay(int cycleDay) {
      final start = DateTime.now().subtract(Duration(days: cycleDay - 1));
      CycleStore.instance
        ..resetForTest()
        ..logPeriodStart(start.subtract(const Duration(days: 56)))
        ..logPeriodStart(start.subtract(const Duration(days: 28)))
        ..logPeriodStart(start);
    }

    test('no day of a 28-day cycle falls through to a refusal', () {
      // The whole point. A refusal on day 20 of a perfectly well-logged cycle
      // is the app saying "not enough to say yet" to somebody who has told it
      // everything it asked for.
      for (var day = 1; day <= 28; day++) {
        onCycleDay(day);
        final line = ttcHomeHeroLine();
        expect(
            const {
              TtcHeroState.startHere,
              TtcHeroState.clinicHolds,
              TtcHeroState.noEstimate,
            },
            isNot(contains(line.state)),
            reason: 'day $day of a fully logged cycle refuses to say anything');
      }
    });

    test('and it covers the loop, not just the fertile half', () {
      // Every state the arithmetic can reach must actually be reached inside
      // one ordinary cycle. A state that never fires is dead copy nobody will
      // notice is wrong.
      final seen = <TtcHeroState>{};
      for (var day = 1; day <= 32; day++) {
        onCycleDay(day);
        seen.add(ttcHomeHeroLine().state);
      }
      expect(
          seen,
          containsAll(const [
            TtcHeroState.windowOpensIn,
            TtcHeroState.windowOpen,
            TtcHeroState.windowLastDay,
            TtcHeroState.waiting,
            TtcHeroState.periodDue,
            TtcHeroState.periodLate,
          ]),
          reason: 'a state in the loop is unreachable in a 28-day cycle. Seen: '
              '$seen');
    });

    test('the last fertile day is exactly one day', () {
      var lastDays = 0;
      for (var day = 1; day <= 28; day++) {
        onCycleDay(day);
        if (ttcHomeHeroLine().state == TtcHeroState.windowLastDay) lastDays++;
      }
      expect(lastDays, 1,
          reason: '"your fertile days end today" fired on $lastDays days');
    });

    test('the countdown to the period only ever goes down', () {
      // ⚠️ A COUNTDOWN THAT GOES BACK UP IS WORSE THAN NO COUNTDOWN. It happens
      // when the day arithmetic is off by one across a boundary, and somebody
      // watching it daily notices immediately.
      int? previous;
      for (var day = 15; day <= 28; day++) {
        onCycleDay(day);
        final line = ttcHomeHeroLine();
        if (line.state != TtcHeroState.waiting) continue;
        if (previous != null) {
          expect(line.days, lessThan(previous),
              reason: 'the wait counted up between day ${day - 1} and $day');
        }
        previous = line.days;
      }
      expect(previous, isNotNull, reason: 'the wait never appeared');
    });

    test('the window count includes today and never reads zero', () {
      for (var day = 1; day <= 28; day++) {
        onCycleDay(day);
        final line = ttcHomeHeroLine();
        if (line.state != TtcHeroState.windowOpen) continue;
        expect(line.days, greaterThanOrEqualTo(2),
            reason: 'a window with fewer than two days left is the LAST day, '
                'and has its own state and its own sentence');
      }
    });

    test('a refusal never prints a cycle day', () {
      // A cycle day under "not enough to say yet" is the same overreach in
      // smaller type — it says we do know where she is, having just said we do
      // not.
      CycleStore.instance.resetForTest();
      final line = ttcHomeHeroLine();
      expect(line.state, TtcHeroState.startHere);
      expect(line.cycleDay, isNull);
    });
  });

  // ===========================================================================
  group('the wait counts to a period, never to a test', () {
    test('no state promises an outcome', () {
      // ⚠️ THE LINE THE REFERENCE APP CROSSES AND WE DO NOT. Flo's hero says
      // "Time for a pregnancy test in 10 days" here. That is a countdown to a
      // verdict, and it is the shape that makes a fortnight worse.
      //
      // Scanned rather than reasoned about, because the tempting version of
      // this change is one word.
      final copy = [
        for (var days = 1; days <= 14; days++) ...[
          TtcS.current().headerWaiting(days),
          TtcS.current().headerPeriodLate(days),
        ],
        TtcS.current().headerWaitingBody,
        TtcS.current().headerPeriodDue,
        TtcS.current().headerPeriodDueBody,
        TtcS.current().headerPeriodLateBody,
        TtcS.current().headerWindowLastDay,
        TtcS.current().headerWindowLastDayBody,
      ].join(' ').toLowerCase();

      expect(RegExp(r'\btest in \d|\bin \d+ days? (until|to) (a |your )?test')
          .hasMatch(copy), isFalse,
          reason: 'the hero has grown a countdown to a pregnancy test');
      expect(RegExp(r'chance|odds|likelihood|probabilit').hasMatch(copy),
          isFalse,
          reason: 'the hero has grown a chance framing');
      expect(RegExp(r'fingers crossed|good luck|hopefully|this could be')
          .hasMatch(copy), isFalse,
          reason: 'the hero has started hoping out loud, which makes the '
              'month it does not happen worse');
    });

    test('a missed period is not called late', () {
      // "Late" implies a schedule she failed to keep, and most people read it
      // as a hint. Neither is ours to say.
      for (var d = 1; d <= 10; d++) {
        expect(TtcS.current().headerPeriodLate(d).toLowerCase(),
            isNot(contains('late')));
      }
    });
  });

  // ===========================================================================
  //  The hero follows the day strip — 2026-09-05
  // ---------------------------------------------------------------------------
  //  ⚠️ THE REST OF THE HEADER ALREADY DID. The date above it, the insight
  //  cards, the symptom sheet and the two actions all took `selected`; only the
  //  hero read today. So standing on the 3rd gave a page about the 3rd with one
  //  sentence about the 5th in the middle of it, and nothing said which was
  //  which.
  // ===========================================================================
  group('the hero follows the selected day', () {
    void onCycleDay(int cycleDay) {
      final start = DateTime.now().subtract(Duration(days: cycleDay - 1));
      CycleStore.instance
        ..resetForTest()
        ..logPeriodStart(start.subtract(const Duration(days: 56)))
        ..logPeriodStart(start.subtract(const Duration(days: 28)))
        ..logPeriodStart(start);
    }

    test('a day back in the same cycle describes THAT day', () {
      // The reference behaviour, exactly: on the last fertile day the hero says
      // it ends today; standing two days earlier it says today and 2 more.
      onCycleDay(15);
      final today = ttcHomeHeroLine();
      final twoBack =
          ttcHomeHeroLine(on: DateTime.now().subtract(const Duration(days: 2)));

      expect(today.state, isNot(twoBack.state),
          reason: 'the hero said the same thing on two different days of the '
              'window, which is the bug');
      expect(twoBack.cycleDay, today.cycleDay! - 2);
    });

    test('no argument still means today', () {
      // The whole existing suite depends on this, and so does the screen on
      // first build before anything is tapped.
      onCycleDay(12);
      final a = ttcHomeHeroLine();
      final b = ttcHomeHeroLine(on: DateTime.now());
      expect(a.state, b.state);
      expect(a.days, b.days);
      expect(a.cycleDay, b.cycleDay);
    });

    test('the cycle day tracks the selection, one per day', () {
      onCycleDay(20);
      for (var back = 0; back < 6; back++) {
        final line = ttcHomeHeroLine(
            on: DateTime.now().subtract(Duration(days: back)));
        expect(line.cycleDay, 20 - back);
      }
    });

    test('an earlier cycle names its day, from her own logs', () {
      // ⚠️ THIS ASSERTED A BARE REFUSAL UNTIL 2026-09-05, AND THE REFUSAL WAS
      // OVER-APPLIED. Reported: "why are we still on past cycle?" — the hero
      // said "An earlier cycle" and stopped, which tells her nothing she did
      // not already know from having scrolled there.
      //
      // Her cycle DAY in a past cycle is the date minus whichever logged period
      // contained it. That is arithmetic on her own data and is exactly as true
      // for August as for today.
      onCycleDay(10);
      // 40 days back lands inside the cycle that started 28 days before this
      // one, on its 26th day.
      final line = ttcHomeHeroLine(
          on: DateTime.now().subtract(const Duration(days: 40)));
      expect(line.state, TtcHeroState.pastCycle);
      expect(line.days, 26,
          reason: 'the day of that cycle, counted from the period she was '
              'actually in');
      expect(line.date, isNotNull, reason: 'it must name which cycle');
    });

    test('and still no fertile window, and no grade, for a past cycle', () {
      // ⚠️ THE HALF THAT STAYS REFUSED. A window for a past cycle needs an
      // ovulation estimate for a cycle whose signals are gone — a guess she has
      // no way to identify as one. And the reference app's pairing of a past
      // day number with "low chances of getting pregnant" is the personalised
      // probability CLAUDE.md forbids, which does not become allowed by being
      // in the past.
      onCycleDay(10);
      final line = ttcHomeHeroLine(
          on: DateTime.now().subtract(const Duration(days: 40)));
      expect(
          const {
            TtcHeroState.windowOpensIn,
            TtcHeroState.windowOpen,
            TtcHeroState.windowLastDay,
          },
          isNot(contains(line.state)));
      final copy = (TtcS.current().headerPastCycleDay(17) +
              TtcS.current().headerPastCycleBodyOn('3 Aug'))
          .toLowerCase();
      expect(RegExp(r'chance|odds|likelihood|low|high').hasMatch(copy), isFalse,
          reason: 'the past-cycle hero has grown a fertility grade');
    });

    test('earlier than anything logged has no day to name', () {
      onCycleDay(10);
      final line = ttcHomeHeroLine(
          on: DateTime.now().subtract(const Duration(days: 400)));
      expect(line.state, TtcHeroState.pastCycle);
      expect(line.days, 0);
    });

    test('a future day is never called late', () {
      // The strip runs six days forward. On day 26 of a 28-day cycle, +6 is
      // arithmetically overdue and factually has not happened.
      onCycleDay(26);
      for (var ahead = 1; ahead <= 6; ahead++) {
        final line = ttcHomeHeroLine(
            on: DateTime.now().add(Duration(days: ahead)));
        expect(line.state, isNot(TtcHeroState.periodLate),
            reason: '+$ahead days is in the future and was called late');
        expect(line.state, isNot(TtcHeroState.periodDue));
      }
    });

    test('and a future day inside the window still reads as the window', () {
      onCycleDay(9);
      final line =
          ttcHomeHeroLine(on: DateTime.now().add(const Duration(days: 2)));
      expect(
          const {
            TtcHeroState.windowOpensIn,
            TtcHeroState.windowOpen,
            TtcHeroState.windowLastDay,
          },
          contains(line.state));
    });
  });

  // ===========================================================================
  //  A clinic-run cycle still gets a hero that moves — 2026-09-05
  // ---------------------------------------------------------------------------
  //  ⚠️ THIS GROUP EXISTS BECAUSE THE WHOLE SUITE WAS GREEN WHILE THE FEATURE
  //  WAS DEAD. Nine states were added and tested the day before; not one test
  //  set up a clinic-run account, and on such an account an early return above
  //  all of them meant the hero said "Your clinic holds this" every day
  //  forever. Reported from a device: *"this is the line that I keep seeing
  //  again and again, nothing changes."*
  //
  //  The lesson is about which ACCOUNT a test runs as, not which state it
  //  checks. Every test above ran as the default pathway, so every one of them
  //  agreed with every other one and none of them touched the branch that
  //  mattered.
  // ===========================================================================
  group('a clinic on the cycle does not freeze the hero', () {
    /// ⚠️ A PAST CLINIC DATE IS SEEDED ON PURPOSE — UPDATED 2026-09-05 WHEN
    /// THE TREATMENT STATES LANDED. This group tests the FALL-THROUGH: a clinic
    /// owns the timing, and either there are no upcoming dates or they have all
    /// been and gone. With no dates at all the hero is now an invitation to add
    /// them, which is a better answer and a different test.
    ///
    /// The precedence, once, so nobody has to reconstruct it: her clinic's next
    /// date → the invitation to add one → the cycle-day line. Only the last of
    /// those is `clinicHolds`.
    void seedClinicCycle(int cycleDay) {
      final start = DateTime.now().subtract(Duration(days: cycleDay - 1));
      CycleStore.instance
        ..resetForTest()
        ..logPeriodStart(start.subtract(const Duration(days: 56)))
        ..logPeriodStart(start.subtract(const Duration(days: 28)))
        ..logPeriodStart(start);
      TtcStore.instance.setPath(TtcPath.ivf);
      // ⚠️ THE DATE MOVED INTO THIS CYCLE ON 2026-09-26. The user decided a
      // clinic owns the timing only when the treatment tracker holds a real
      // date for the CURRENT cycle, not on the pathway label. A retrieval 40
      // days back belongs to an earlier cycle, so it no longer makes this one
      // clinic-run. The retrieval is now on cycle day 1: inside this cycle,
      // already behind her from day 2. Kept for revert:
      //   ..setDate(TtcTreatmentStep.retrieval,
      //       DateTime.now().subtract(const Duration(days: 40)));
      TtcTreatmentStore.instance
        ..clearCycle()
        ..setDate(TtcTreatmentStep.retrieval, start);
    }

    tearDown(() {
      TtcTreatmentStore.instance.clearCycle();
      TtcStore.instance.setPath(TtcPath.natural);
    });

    // ⚠️ FOUR TESTS WERE DELETED FROM HERE ON 2026-09-05, AND SAYING WHY
    // MATTERS MORE THAN KEEPING THEM. They asserted that a clinic-run cycle
    // produces `clinicHolds` — "it carries her cycle day", "it says something
    // different every day", "it follows the strip too". All three were written
    // the day before, to hold a fix that made the refusal at least MOVE.
    //
    // That fix is obsolete because the refusal is gone. A clinic account now
    // gets the same cycle messages as everybody else, so tests pinning it to
    // the refusal were pinning the very thing that was being complained about.
    // Rewriting them as "it says something different every day" against the new
    // states would duplicate the cycle-walk group above, which already does it
    // for every day of a 28-day cycle.
    // ⚠️ INVERTED AGAIN ON 2026-09-26 (consistency pass), AND IT NEEDS THE
    // USER'S CONFIRMATION. The 2026-09-05 decision let the hero alone publish
    // a window into a clinic-owned cycle. The consistency brief says clinic-
    // owned cycles get no phase-based prediction anywhere, and with the hero
    // the only surface still predicting, it disagreed with every card, read,
    // calendar mark and message beneath it. The part of the old decision that
    // was about the user's complaint is kept and asserted: the hero is never
    // the clinic refusal sentence. It carries her cycle day (a fact that moves
    // every morning) and the way out, "Not on treatment? Change this".
    // Kept for revert, the old test:
    //   test('the fertile window IS reachable on the hero now — by decision', () {
    //     for (var day = 1; day <= 15; day++) {
    //       seedClinicCycle(day);
    //       final line = ttcHomeHeroLine();
    //       expect(line.state, isNot(TtcHeroState.clinicHolds),
    //           reason: 'day $day still refuses instead of speaking');
    //     }
    //   });
    test('a clinic cycle with no dates ahead carries her cycle day, not a '
        'window', () {
      const window = {
        TtcHeroState.windowOpensIn,
        TtcHeroState.windowOpen,
        TtcHeroState.windowLastDay,
        TtcHeroState.waiting,
        TtcHeroState.periodDue,
        TtcHeroState.periodLate,
        TtcHeroState.periodExpectedBy,
      };
      // From day 2: on day 1 the clinic date (on cycle day 1) is today, and
      // the hero rightly leads on it (2026-09-26, see the seed).
      for (var day = 2; day <= 15; day++) {
        seedClinicCycle(day);
        final line = ttcHomeHeroLine();
        expect(window, isNot(contains(line.state)),
            reason: 'day $day published a prediction into a clinic cycle');
        expect(line.state, TtcHeroState.clinicHolds);
        expect(line.days, day,
            reason: 'day $day: the hero must still move every morning');
      }
      // The sub-line is still a way on, not a dead end. Since 2026-09-26 a
      // label alone cannot reach this state, so the way on is the next clinic
      // date (or clearing the round), not "Not on treatment?". Kept for
      // revert:
      //   expect(TtcS.current().headerNotOnTreatment, contains('Change'), ...);
      expect(TtcS.current().headerClinicDatesPassed, contains('Add the next'),
          reason: 'the clinic line must stay a way out, not a dead end');
    });

    // The old test's reasoning, kept with it for revert:
    //  // ⚠️ THIS INVERTED ON 2026-09-05, AND IT IS A PRODUCT DECISION RATHER
    //  // THAN A DISCOVERY. It asserted that no window state could appear while a
    //  // clinic held the timing, which was the rule everywhere.
    //  //
    //  // It still IS the rule everywhere except one surface. The hero passes
    //  // `ignoreOwnership` — see `ttcFertileWindowNow` for the full reasoning —
    //  // because `ownership` is derived from `path.defaultMedicated`, a guess
    //  // from a label tapped once, and `setPath` clears her real answers so the
    //  // guess always wins. Four rounds of the hero showing a clinic refusal to
    //  // an account with no treatment is what settled it.
    //  //
    //  // What has NOT changed is asserted immediately below.
    //  for (var day = 1; day <= 15; day++) {
    //    seedClinicCycle(day);
    //    final line = ttcHomeHeroLine();
    //    expect(line.state, isNot(TtcHeroState.clinicHolds),
    //        reason: 'day $day still refuses instead of speaking');
    //  }
    //});

    test('and no OTHER surface gained a window', () {
      // The invariant the 36 clinical tests protect, kept: `estimatedOvulationDay`
      // is still withheld, so the cycle companion, the calendar and `Inferable`
      // all still refuse. Only `rawOvulationDay` is readable, and only the hero
      // reads it.
      seedClinicCycle(10);
      expect(TtcStore.instance.today.estimatedOvulationDay, isNull,
          reason: 'the published estimate leaked past the ownership gate');
      expect(ttcFertileWindowNow(), isNull,
          reason: 'the ungated call now returns a window for a clinic cycle');
    });

    test('and the hero never carries the long clinic paragraph', () {
      // It is good writing in the wrong slot: a headline that has to say
      // something new every morning cannot be a two-line explanation of our
      // position. The reasoning lives on `TtcTreatmentEntryCard`, which is
      // where somebody asking "why is there no estimate" actually goes.
      expect(TtcS.current().headerClinicHoldsShort.length, lessThan(60),
          reason: 'the clinic line has grown back into a paragraph');
    });
  });

  // ===========================================================================
  //  The day strip's marker follows the selection — 2026-09-05
  // ===========================================================================
  group('the coral disc is the cursor, and today is still findable', () {
    // ⚠️ `TtcHomeV3`, NOT `TtcTodayScreen`. The first version of this group
    // pumped the helper the rest of this file uses and found neither the strip
    // nor the word TODAY, because they live on a different screen. Two failing
    // assertions that both looked like the feature was broken; neither had
    // rendered it.
    Future<void> pumpHome(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TtcHomeV3()));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    }

    testWidgets('no day cell paints a selection ring any more', (tester) async {
      // ⚠️ ASSERTED AS AN ABSENCE, WHICH IS THE ONLY WAY TO HOLD A REMOVAL.
      // "I don't need that purple outline" is the kind of instruction the next
      // person quietly undoes while adding a focus state.
      //
      // ⚠️ AND SCOPED TO THE STRIP. The first version walked every circular
      // Container on the screen and failed on the two round header buttons,
      // which have always had a hairline border and have nothing to do with
      // this. A scan wide enough to catch anything catches the wrong thing.
      await pumpHome(tester);

      final n = DateTime.now();
      final cells =
          find.byKey(ValueKey('ttc_day_${n.year}-${n.month}-${n.day}'));
      expect(cells, findsOneWidget, reason: 'the strip did not render');

      final inCell = tester.widgetList<Container>(
          find.descendant(of: cells, matching: find.byType(Container)));
      for (final c in inCell) {
        final d = c.decoration;
        if (d is BoxDecoration && d.shape == BoxShape.circle) {
          expect(d.border, isNull,
              reason: 'a day cell has grown a ring back');
        }
      }
    });

    testWidgets('today keeps a mark that is not the disc', (tester) async {
      // The requirement that came with the change: *"keep the today marked as
      // where it is so that I know what day is today"*. With the disc free to
      // follow the selection, today is held by the word above it and by the
      // colour of its digits.
      await pumpHome(tester);
      expect(find.text('TODAY'), findsOneWidget,
          reason: 'the permanent mark on today has gone, and the disc is not '
              'permanent any more');
    });
  });

  // ===========================================================================
  //  The hero leads on her clinic's calendar — 2026-09-05
  // ---------------------------------------------------------------------------
  //  ⚠️ THE FIX FOR THE COMPLAINT THAT HAD TO BE MADE FOUR TIMES. When a clinic
  //  owned the timing the hero SUBTRACTED the fertile window and put nothing in
  //  its place, so the biggest type on the home screen said "Your clinic holds
  //  this" every day forever — to somebody who had an egg retrieval booked and
  //  wanted to know when.
  // ===========================================================================
  group('a treatment cycle leads on the next clinic date', () {
    void seedTreatment(Map<TtcTreatmentStep, DateTime> dates) {
      final start = DateTime.now().subtract(const Duration(days: 8));
      CycleStore.instance
        ..resetForTest()
        ..logPeriodStart(start.subtract(const Duration(days: 56)))
        ..logPeriodStart(start.subtract(const Duration(days: 28)))
        ..logPeriodStart(start);
      TtcStore.instance.setPath(TtcPath.ivf);
      TtcTreatmentStore.instance.clearCycle();
      dates.forEach(TtcTreatmentStore.instance.setDate);
    }

    tearDown(() {
      TtcTreatmentStore.instance.clearCycle();
      TtcStore.instance.setPath(TtcPath.natural);
    });

    test('the next step, counted down to', () {
      seedTreatment({
        TtcTreatmentStep.retrieval:
            DateTime.now().add(const Duration(days: 3)),
        TtcTreatmentStep.transfer:
            DateTime.now().add(const Duration(days: 8)),
      });
      final line = ttcHomeHeroLine();
      expect(line.state, TtcHeroState.treatmentSoon);
      expect(line.step, TtcTreatmentStep.retrieval,
          reason: 'it picked a later step over the nearer one');
      expect(line.days, 3);
    });

    test('a step falling today says today, not "in 0 days"', () {
      seedTreatment({TtcTreatmentStep.trigger: DateTime.now()});
      expect(ttcHomeHeroLine().state, TtcHeroState.treatmentToday);
    });

    test('the beta test is named by date and never counted down to', () {
      // ⚠️ THE RULE: count down to things she DOES, name the date of things
      // that JUDGE. A trigger injection is an action and a shrinking number helps
      // her prepare. The beta is a verdict, and the largest type on the screen
      // counting towards it is the shape that makes a wait worse — the same
      // reason the natural hero counts to a period, never to a test.
      seedTreatment({
        TtcTreatmentStep.betaTest: DateTime.now().add(const Duration(days: 9)),
      });
      final line = ttcHomeHeroLine();
      expect(line.state, TtcHeroState.treatmentBeta);
      expect(line.date, isNotNull);
      expect(TtcS.current().headerBetaOn('18 Sep'), isNot(contains('9 days')));
    });

    // ⚠️ 2026-09-26 (consistency pass): on a clinic-owned cycle "the cycle
    // message" is her cycle day (`clinicHolds`), not a window or a count to a
    // period, which no other surface shows on such a cycle. The window states
    // are kept in the set below for revert and for the natural-cycle reading.
    test('no dates at all falls through to the cycle message', () {
      // ⚠️ THIS TEST ASSERTED THE OPPOSITE YESTERDAY, AND THE OPPOSITE WAS
      // WRONG. It expected an "Add your clinic dates" hero, built on the
      // empty-state rule — a feature is never hidden. That rule is right and
      // this was the wrong place to apply it: the hero is the first thing she
      // reads every morning, not a feature's shelf, and an account that only
      // has a treatment path because of one stray tap got a clinic sentence in
      // the largest type on the screen for its trouble.
      //
      // Her clinic's calendar leads the hero when it has something to say and
      // says nothing when it does not.
      seedTreatment({});
      final line = ttcHomeHeroLine();
      expect(
          const {
            TtcHeroState.windowOpensIn,
            TtcHeroState.windowOpen,
            TtcHeroState.windowLastDay,
            TtcHeroState.waiting,
            TtcHeroState.periodDue,
            TtcHeroState.periodLate,
            TtcHeroState.clinicHolds,
          },
          contains(line.state),
          reason: 'a treatment account with no dates still gets a clinic '
              'sentence instead of its cycle');
      if (TtcStore.instance.today.clinicInvolved) {
        expect(line.state, TtcHeroState.clinicHolds,
            reason: 'a clinic-owned cycle got a prediction on the hero');
        expect(line.days, greaterThan(0),
            reason: 'the clinic hero must carry her cycle day');
      }
    });

    test('it follows the strip, like everything else on the page', () {
      seedTreatment({
        TtcTreatmentStep.retrieval:
            DateTime.now().add(const Duration(days: 4)),
      });
      final back =
          ttcHomeHeroLine(on: DateTime.now().subtract(const Duration(days: 2)));
      expect(back.days, 6,
          reason: 'the hero answered "what is next" from the clock while the '
              'rest of the page answered from the selection');
    });

    test('every date behind her falls through rather than printing a past one',
        () {
      // A cycle whose dates have all passed is BETWEEN cycles. Printing the
      // last one as though it were coming is worse than saying nothing.
      seedTreatment({
        TtcTreatmentStep.retrieval:
            DateTime.now().subtract(const Duration(days: 5)),
      });
      final line = ttcHomeHeroLine();
      expect(
          const {
            TtcHeroState.treatmentToday,
            TtcHeroState.treatmentSoon,
            TtcHeroState.treatmentBeta,
          },
          isNot(contains(line.state)));
    });

    test('and it still never publishes a fertile window', () {
      // The invariant the whole ownership model exists for, kept through all
      // of this.
      seedTreatment({
        TtcTreatmentStep.retrieval:
            DateTime.now().add(const Duration(days: 2)),
      });
      expect(
          const {
            TtcHeroState.windowOpensIn,
            TtcHeroState.windowOpen,
            TtcHeroState.windowLastDay,
          },
          isNot(contains(ttcHomeHeroLine().state)));
    });
  });
}
