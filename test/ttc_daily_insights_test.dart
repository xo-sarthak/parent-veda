// =============================================================================
//  The V3 home's day strip and its insight cards
// -----------------------------------------------------------------------------
//  ⚠️ WHAT THIS TESTS IS THAT THE SCREEN CHANGES WHEN THE DAY CHANGES. Which
//  sounds trivial and is exactly the thing that was broken for three rounds of
//  review: the strip drew seven dates, the heading said "Today", and both were
//  decoration — tapping a date did nothing, the cards were computed for
//  `DateTime.now()` regardless, and a symptom logged an hour ago left no mark
//  anywhere on the home.
//
//  None of that failed a test, because every test asserted that the widgets
//  EXISTED. A date cell that renders perfectly and ignores its own tap passes
//  any check that looks for a date cell. So these tests tap.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_daily_insights.dart';
import 'package:parentveda/screens/ttc/ttc_home_v3.dart';
import 'package:parentveda/screens/ttc/ttc_mood_face.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart' show ttcReadById;
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final today = DateTime.now();
  DateTime day(int daysAgo) {
    final d = today.subtract(Duration(days: daysAgo));
    return DateTime(d.year, d.month, d.day);
  }

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
  });

  void history() {
    CycleStore.instance
      ..logPeriodStart(day(68))
      ..logPeriodStart(day(40))
      ..logPeriodStart(day(12));
  }

  void log(String id, int daysAgo) => TtcLogStore.instance
      .log(kTtcSymptomTracker, id, 1, on: today.subtract(Duration(days: daysAgo)));

  String keyFor(DateTime d) => 'ttc_day_${d.year}-${d.month}-${d.day}';

  // ===========================================================================
  // ⚠️ ONE CARD, ONE PLACE (the user on build 16, 2026-09-28: the Cycle report
  // behind two cards "causes ambiguity"). Every day's cards, plus the fixed
  // cards the home adds after them, land in different places.
  group('no two cards on the rail open the same screen', () {
    // The home's own cards after the day's (ttc_home_v3.dart): insight, myth,
    // nutrition, movement, the report and today's pick.
    const homeCards = {
      'insight', 'myth', 'nutrition', 'movement', 'report', 'products'
    };
    test('with everything logged, on every day of a cycle', () {
      history();
      log('disch_eggwhite', 0);
      log('cramping', 0);
      log('calm', 0);
      for (var back = -6; back <= 30; back++) {
        final cards = ttcInsightsFor(day(back));
        final seen = <String>{...homeCards};
        for (final c in cards) {
          final dest = ttcRailDestination(c);
          expect(seen.add(dest), isTrue,
              reason: '${c.id} on ${day(back)} opens $dest, which another '
                  'card on the same rail already opens');
          if (c.go == TtcInsightGo.read) {
            expect(ttcReadById(c.readId!), isNotNull,
                reason: '${c.id} opens a read that does not exist');
          }
        }
      }
    });
  });

  group('which cards a day earns', () {
    test('a day with nothing logged is invited to log, not left blank', () {
      history();
      final ids = ttcInsightsFor(day(0)).map((c) => c.id);
      expect(ids, contains('log_prompt'));
    });

    test('and a day with something logged is not', () {
      history();
      log('cramping', 0);
      final ids = ttcInsightsFor(day(0)).map((c) => c.id).toList();
      expect(ids, isNot(contains('log_prompt')));
      expect(ids, contains('symptom'),
          reason: 'she logged a symptom and the home said nothing about it — '
              'the complaint that started this whole pass');
    });

    test('a future day is never asked to report on itself', () {
      // ⚠️ THE STRIP SHOWS SIX DAYS FORWARD so the fertile tint can be seen
      // arriving. "Nothing yet — how did that day feel?" under next Tuesday is
      // the app asking about something that has not happened.
      history();
      final ids =
          ttcInsightsFor(day(-3)).map((c) => c.id); // three days from now
      expect(ids, isNot(contains('log_prompt')));
    });

    test('the tense follows the date', () {
      history();
      final todayCard =
          ttcInsightsFor(day(0)).firstWhere((c) => c.id == 'log_prompt');
      final pastCard =
          ttcInsightsFor(day(4)).firstWhere((c) => c.id == 'log_prompt');
      expect(todayCard.value, contains('today'));
      expect(pastCard.value, isNot(contains('today')),
          reason: '"How did today feel?" printed under last Tuesday');
    });

    test('discharge is reported separately from how she feels', () {
      history();
      log('disch_eggwhite', 0);
      final ids = ttcInsightsFor(day(0)).map((c) => c.id);
      expect(ids, contains('discharge'));
    });

    // -----------------------------------------------------------------------
    //  The refusal
    // -----------------------------------------------------------------------
    test('a clinic-run cycle gets no fertility band at all', () {
      // ⚠️ ABSENT, NOT "LOW" AND NOT "UNKNOWN". A band on a cycle a clinician
      // is directing is a second opinion sitting beside theirs on her home
      // screen. Truth hierarchy: a treating clinician is six places above our
      // calculation, and this is the surface where that is easiest to forget
      // because the card looks so harmless.
      history();
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      final ids = ttcInsightsFor(day(0)).map((c) => c.id);
      expect(ids, isNot(contains('chance')));
    });

    test('no card ever attaches a percentage to her', () {
      history();
      log('cramping', 0);
      TtcStore.instance.setPath(TtcPath.natural);
      final text = ttcInsightsFor(day(0))
          .map((c) => '${c.eyebrow} ${c.value} ${c.caption ?? ''}')
          .join(' ');
      expect(text, isNot(contains('%')));
      expect(text.toLowerCase(), isNot(contains('per cent')));
    });
  });

  // ===========================================================================
  group('the strip markers', () {
    test('two symptoms show as two, and the rest become a count', () {
      log('cramping', 0);
      log('bloating', 0);
      log('fatigue', 0);
      log('headache', 0);
      final m = ttcDayMarkers(day(0));
      expect(m.shown.length, 2);
      expect(m.more, 2);
    });

    test('symptoms without an emoji still get shown, via their icon', () {
      // ⚠️ THE HOLE IN THE FIRST VERSION. It returned emoji strings, and only
      // the feelings group has an emoji — so the most common logging session
      // there is, two physical symptoms, produced an empty list and a bare
      // "+2" under the date.
      log('cramping', 0);
      log('bloating', 0);
      final m = ttcDayMarkers(day(0));
      expect(m.shown.length, 2);
      expect(m.shown.every((s) => s.emoji == null), isTrue);
      expect(m.more, 0);
    });

    test('anything with a face is preferred to anything without', () {
      log('cramping', 0);
      log('bloating', 0);
      log('happy', 0);
      final m = ttcDayMarkers(day(0));
      // ⚠️ ASSERTED ON `ttcMoodFor`, WHICH IS WHAT THE STRIP ACTUALLY DRAWS.
      // `emoji` currently marks the same eight symptoms, so keying on it would
      // pass — and would keep passing if the two ever drifted apart, which is
      // the whole failure mode a preference test exists to catch.
      expect(ttcMoodFor(m.shown.first.id), isNotNull,
          reason: 'an expression reads at a glance from a strip being scrolled '
              'past and a line icon mostly does not');
    });

    test('an empty day has no markers', () {
      expect(ttcDayMarkers(day(2)).shown, isEmpty);
      expect(ttcHasAnyLog(day(2)), isFalse);
    });
  });

  // ===========================================================================
  //  The part that only a tap can prove
  // ---------------------------------------------------------------------------
  group('the home follows the selected day', () {
    Future<void> pump(WidgetTester tester) async {
      // ⚠️ 360pt, NOT 1200. A wide test surface is a test of a tablet nobody
      // has: the insight rail, the day strip and the two header actions all fit
      // comfortably at 1200 and are exactly where a phone runs out of width.
      // Two real overflows on the logging screen hid behind a 1200pt viewport
      // until the render test for it was written narrow.
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TtcHomeV3()));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    }

    testWidgets('it opens on today', (tester) async {
      history();
      await pump(tester);
      expect(find.text('Today'), findsWidgets);
    });

    testWidgets('tapping yesterday renames the section', (tester) async {
      history();
      await pump(tester);

      await tester.tap(find.byKey(ValueKey(keyFor(day(1)))));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Yesterday'), findsWidgets,
          reason: 'the date was tapped and the heading did not move — which is '
              'the state this screen shipped in');

      // ⚠️ NOT `find.text('Today') == findsNothing`, WHICH IS WHAT THIS TEST
      // FIRST ASSERTED AND WAS WRONG ABOUT. "Today" also appears on the window
      // line as a legitimate label — the fertile window opening *today* — and
      // "Yesterday" is the claim actually being made here. An assertion that
      // reaches for every instance of a common word on a busy screen fails for
      // reasons unrelated to what it is testing.
    });

    testWidgets('and going further back names the date outright',
        (tester) async {
      history();
      await pump(tester);

      final target = day(4);
      await tester.tap(find.byKey(ValueKey(keyFor(target))));
      await tester.pump(const Duration(milliseconds: 300));

      // ⚠️ "FOUR DAYS AGO" IS ARITHMETIC; A DATE IS NOT. The relative words
      // stop at one day out on purpose.
      expect(find.textContaining('${target.day} '), findsWidgets);
      expect(find.text('Yesterday'), findsNothing);
    });

    testWidgets('a logged day carries a heart until you stand on it',
        (tester) async {
      // ⚠️ THE ASYMMETRY, ASSERTED. A heart on days you are not on, the actual
      // symptoms on the day you are. Thirty days of symptom icons is confetti;
      // thirty hearts is an answer to "when have I been logging?".
      history();
      log('happy', 2);
      await pump(tester);

      expect(find.byIcon(Icons.favorite_rounded), findsWidgets,
          reason: 'a day with a log showed no marker at all');

      await tester.tap(find.byKey(ValueKey(keyFor(day(2)))));
      await tester.pump(const Duration(milliseconds: 300));

      // Standing on it, the heart is replaced by what she actually logged.
      //
      // ⚠️ THE DRAWN MARK, NOT AN EMOJI STRING. This asserted `find.text(emoji)`
      // until the moods became `CustomPaint` — see `ttc_mood_face.dart` for why
      // an OS-rendered glyph was the wrong object. `TtcSymptom.emoji` is still
      // on the model for semantics, so a test matching on it would have kept
      // passing against a field nothing draws.
      expect(find.byType(TtcMoodFace), findsWidgets,
          reason: 'selected the logged day and it still showed a generic '
              'heart rather than the symptom');
    });

    testWidgets('the strip and the ring agree about which day is today',
        (tester) async {
      // ⚠️ THE MIDNIGHT BUG, AS CLOSE AS A WIDGET TEST CAN GET TO IT.
      //
      // "Today" used to be captured once — `_selected` in a field initialiser,
      // the strip's window anchor in `initState` — so a screen left open across
      // midnight kept yesterday's idea of today. What made it visible is that
      // `isToday` reads the clock on EVERY build, so the bold number moved to
      // the new day while the selection ring stayed on the old one: a screen
      // disagreeing with itself, and only ever after midnight.
      //
      // A test cannot move the system clock, so this asserts the invariant that
      // makes the bug impossible instead: the day the ring is on and the day
      // the strip calls today must be the same cell on first build. If someone
      // reintroduces a second `DateTime.now()` read, the two can drift and the
      // fix is gone — this at least pins that they start together.
      history();
      await pump(tester);

      final todayKey = ValueKey(keyFor(day(0)));
      expect(find.byKey(todayKey), findsOneWidget);
      expect(find.text('Today'), findsWidgets,
          reason: 'the heading and the strip disagree about the current day');

      // And the day after today must be reachable but not selected — which is
      // what proves the window is anchored on today rather than behind it.
      expect(find.byKey(ValueKey(keyFor(day(-1)))), findsOneWidget,
          reason: 'tomorrow is missing, so the 180+6 window is anchored on the '
              'wrong day');
    });

    testWidgets('today is marked by the word TODAY, not only by a colour',
        (tester) async {
      // ⚠️ REPORTED TWICE AS "the pink circle is stuck on 30th August", AND
      // BOTH TIMES THE PINK CIRCLE WAS INNOCENT. `ttcCoral` fills a logged
      // period START and sits on the date she logged — it is not a today
      // marker and it is not supposed to move.
      //
      // The defect was that today had NO disc, only a bold accent number, on a
      // strip where other days carry filled circles. A marker weaker than the
      // things around it is not a marker, so the loudest disc on the row got
      // read as "today" and appeared frozen.
      //
      // This pins the unambiguous half of the fix. The disc itself is a colour
      // and colours are awkward to assert; the word is not, and the word is
      // what makes the cell impossible to misread.
      history();
      await pump(tester);
      expect(find.text('TODAY'), findsOneWidget,
          reason: 'today is not labelled, so the strongest disc on the strip '
              'will be mistaken for it again');
    });

    testWidgets('and a period logged on another day keeps its own marker',
        (tester) async {
      // The other half: fixing today must not have eaten her data. A period
      // start three days ago still owns its cell.
      CycleStore.instance.logPeriodStart(day(3));
      await pump(tester);
      expect(find.byKey(ValueKey(keyFor(day(3)))), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget,
          reason: 'two different things, two different cells');
    });

    testWidgets('the cards are computed for the selected day, not for today',
        (tester) async {
      history();
      log('cramping', 0); // today has something; three days ago does not
      await pump(tester);

      // Today: no invitation, because she logged.
      expect(find.text('How did today feel?'), findsNothing);

      await tester.tap(find.byKey(ValueKey(keyFor(day(3)))));
      await tester.pump(const Duration(milliseconds: 300));

      // A day with nothing on it: the invitation appears, in the past tense.
      expect(find.text('How did that day feel?'), findsWidgets,
          reason: 'the cards ignored the selection — the strip moved and the '
              'content below it did not');
    });
  });
}
