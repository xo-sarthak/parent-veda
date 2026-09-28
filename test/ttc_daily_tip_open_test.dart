// =============================================================================
//  Today's myth, nutrition and movement open a story and reads, not sheets
// -----------------------------------------------------------------------------
//  The user (2026-09-28): the three daily cards "only open pop-ups that come
//  from below". The myth now opens the story deck every door myth opens, and
//  the two tips open in the one reader. Held here:
//    · a myth tap on the home opens `TtcStoryScreen`, a tip tap opens
//      `PvReaderScreen`, and no bottom sheet appears;
//    · the myth's slides are what people say, what's true, and the rest;
//    · a tip read carries a short answer, its body and a Read next rail of
//      reads that exist, with nothing invented beyond the seed's words;
//    · the three sheets are commented out in the handler, not live.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/ttc/ttc_daily_tip_open.dart';
import 'package:parentveda/screens/ttc/ttc_home_v3.dart';
import 'package:parentveda/screens/ttc/ttc_story_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_mind_today.dart';
import 'package:parentveda/ttc/ttc_practice_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
  });

  // ===========================================================================
  group('on the home, at 360', () {
    Future<void> pumpHome(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TtcHomeV3()));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    }

    Future<void> tapCard(WidgetTester tester, String eyebrow) async {
      final f = find.text(eyebrow.toUpperCase(), skipOffstage: false);
      expect(f, findsWidgets, reason: '"$eyebrow" is not on the rail');
      await tester.ensureVisible(f.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(f.first, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets("today's myth opens the story deck", (tester) async {
      await pumpHome(tester);
      await tapCard(tester, TtcS.current().todaysMyth);
      expect(find.byType(TtcStoryScreen), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      // H8 (2026-09-28): the cover is labelled MYTH and FACT, as on a door
      // myth. Kept for revert, the old first slide:
      //   expect(find.text(kTtcMythSaySlide, findRichText: true), findsWidgets);
      expect(find.byKey(const ValueKey('ttc_story_myth')), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_story_fact')), findsOneWidget);
    });

    testWidgets("today's nutrition opens the reader", (tester) async {
      await pumpHome(tester);
      await tapCard(tester, TtcS.current().todaysNutrition);
      expect(find.byType(PvReaderScreen), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets("today's movement opens the reader", (tester) async {
      await pumpHome(tester);
      await tapCard(tester, TtcS.current().todaysMovement);
      expect(find.byType(PvReaderScreen), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });
  });

  // ===========================================================================
  group('the myth as slides', () {
    test('what people say, what is true, and the rest', () {
      final m =
          ttcMyths.firstWhere((m) => m.id == 'infertility_is_female');
      final slides = ttcMythSlides(m, false);
      expect(slides.map((s) => s.title).toList(),
          [kTtcMythSaySlide, kTtcMythTrueSlide, kTtcMythMoreSlide]);
      expect(slides[0].body, m.mythEn);
      // Every word of the truth is on a slide, in order, and nothing else.
      expect('${slides[1].body} ${slides[2].body}', m.truthEn);
    });

    test('every myth splits without losing a word', () {
      for (final m in ttcMyths) {
        final s = ttcMythSlides(m, false);
        final truth = s.skip(1).map((c) => c.body).join(' ');
        expect(truth, m.truthEn.trim(), reason: m.id);
        expect(s.length, inInclusiveRange(2, 3));
      }
    });

    testWidgets('H8: the daily myth opens on a labelled MYTH and FACT cover',
        (tester) async {
      final m = ttcMyths.firstWhere((m) => m.id == 'infertility_is_female');
      final (fact, more) = ttcSplitFirstSentence(m.truthEn);
      expect(more, isNotEmpty, reason: 'pick a myth whose truth runs on');
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (c) => TextButton(
            onPressed: () => openTtcMythStory(c, m, false),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final story =
          tester.widget<TtcStoryScreen>(find.byType(TtcStoryScreen));
      expect(story.myth, m.mythEn);
      expect(story.fact, fact);
      expect(story.coverTitle, isNotNull,
          reason: 'the myth and fact draw only on a cover');
      // The rest of the truth follows once, and nothing is said twice.
      expect(story.cards.map((c) => c.body).toList(), [more]);
      expect(find.byKey(const ValueKey('ttc_story_myth')), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_story_fact')), findsOneWidget);
      expect(find.text(m.mythEn), findsOneWidget);
    });

    test('a sentence split does not break inside a number', () {
      expect(ttcSplitFirstSentence('About 0.5 mg a day. Ask first.'),
          ('About 0.5 mg a day.', 'Ask first.'));
      expect(ttcSplitFirstSentence('One sentence only.'),
          ('One sentence only.', ''));
    });
  });

  // ===========================================================================
  group('the tips as reads', () {
    test('nutrition: the meal, the why as the short answer, the kitchen line',
        () {
      for (final n in ttcNutrition) {
        final r = ttcNutritionAsRead(n);
        expect(r.shortAnswer?.en, n.whyEn, reason: n.id);
        expect(r.sections.single.paragraphs.single.en, n.indianEn);
        expect(r.title.en.endsWith('.'), isFalse);
        expect(r.reviewed, isFalse, reason: 'no clinician reviewed a seed');
        expect(r.readNext, isNotEmpty, reason: '${n.id} has nowhere to go');
        for (final id in r.readNext) {
          expect(ttcReadById(id), isNotNull, reason: '${n.id} -> $id');
        }
      }
      expect(ttcNutritionAsRead(
                  ttcNutrition.firstWhere((n) => n.id == 'hydration'))
              .teaser
              .en,
          "Today's food idea: water.");
    });

    test('movement: the first line as the short answer, the rest below', () {
      for (final m in ttcMovements) {
        final r = ttcMovementAsRead(m);
        final body = [
          r.shortAnswer!.en,
          for (final s in r.sections) ...s.paragraphs.map((p) => p.en),
        ].join(' ');
        expect(body, m.bodyEn.trim(), reason: m.id);
        expect(r.teaser.en, ttcMovementTime(m.minutes));
        expect(r.readNext, isNotEmpty, reason: '${m.id} has nowhere to go');
        for (final id in r.readNext) {
          expect(ttcReadById(id), isNotNull, reason: '${m.id} -> $id');
        }
      }
    });

    testWidgets('a tip read opens in the reader with its rail',
        (tester) async {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final m = ttcMovements.firstWhere((m) => m.id == 'stairs');
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (c) => Scaffold(
            body: TextButton(
              onPressed: () => openTtcTipRead(c, ttcMovementAsRead(m)),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(PvReaderScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.text(m.titleEn), findsWidgets);
    });
  });

  // ===========================================================================
  // ⚠️ A PRACTICE READS AS A TIP (the user on build 16, 2026-09-28: "it isn't
  // a 3 min read, it's way less… it says daily tip").
  group("today's movement practice reads as a tip", () {
    test('steps as a numbered list, and a way into the player', () {
      for (final p in ttcPracticesOfKind(TtcPracticeKind.move)) {
        final r = ttcPracticeAsTipRead(p);
        expect(r.shortAnswer!.en, p.blurb, reason: p.id);
        expect(r.sections.single.heading!.en, kTtcTipHowHeading);
        expect(r.sections.single.bullets.length, p.steps.length);
        expect(r.sections.single.bullets.first.en, startsWith('1. '));
        expect(r.nextSteps.single.surfaceId, 'ttc_practice/${p.id}');
      }
    });

    test("the home's movement card lands on today's practice as a tip", () {
      final r = ttcMovementAsRead(ttcTodaysMoveTip());
      expect(r.nextSteps.single.surfaceId,
          'ttc_practice/${ttcTodaysMove().id}');
    });

    testWidgets('the byline says Daily tip and claims no reading time',
        (tester) async {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final p = ttcPracticesOfKind(TtcPracticeKind.move).first;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (c) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  openTtcTipRead(c, ttcPracticeAsTipRead(p)),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.text('Daily tip'), findsOneWidget);
      expect(find.textContaining('Daily tip ·'), findsNothing);
      expect(find.text(kTtcTipHowHeading), findsOneWidget);
    });
  });

  // ===========================================================================
  test('the three sheets are commented out in the handler, not live', () {
    final src = File('lib/screens/ttc/ttc_home_v3.dart').readAsStringSync();
    final at = src.indexOf('void _openInsight(');
    final end = src.indexOf('\nclass _InsightTile', at);
    final handler = src.substring(at, end);
    final live = handler
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    expect(live, isNot(contains('showTtcRowSheet(')));
    expect(live, contains('openTtcMythStory(context, myth, hi)'));
    expect(live, contains('openTtcTipRead(context, ttcNutritionAsRead(n))'));
    expect(live, contains('openTtcTipRead(context, ttcMovementAsRead(m))'));
  });
}
