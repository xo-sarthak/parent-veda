// =============================================================================
//  What is Today FOR?
// -----------------------------------------------------------------------------
//  The whole reshape came out of one measurement that contradicted the
//  assumption behind it. TTC's Today had eleven sections; the parenting home has
//  about eleven too. Identical. So "TTC shows too much" was never about
//  quantity.
//
//  The real difference: parenting renders almost everything as ROWS — six
//  compact row builders — while TTC gave every single topic a full-height card
//  with an eyebrow, a title, a paragraph and a fold.
//
//      A row is a line you scan. A card is a small article you have to read.
//
//  Eleven cards feels like far more than eleven rows at the same word count.
//  That is structural, and no amount of capping paragraphs fixes it.
//
//  So the question stopped being "how much text" and became "what is this
//  screen for". The answer: where am I, what is worth doing, what is happening
//  in my body — everything else one tap in.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_products_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_parts.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_store.dart';

String codeOf(String path) => File(path)
    .readAsLinesSync()
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

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
  group('the reading is a list of rows', () {
    testWidgets('four rows, one card', (tester) async {
      await pumpToday(tester);
      expect(find.byType(TtcTodayRow), findsNWidgets(4));
    });

    testWidgets('each opens the same content in a sheet', (tester) async {
      // Nothing was removed by collapsing them. If a row opened nothing, this
      // would have deleted content rather than folded it — the one thing the
      // density work was not allowed to do.
      await pumpToday(tester);
      await tester.tap(find.byType(TtcTodayRow).first);
      await tester.pumpAndSettle();
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('and the one with a real destination goes there instead',
        (tester) async {
      // Today's Pick already had a screen behind it. A sheet would have been
      // a worse answer than the thing that exists.
      await pumpToday(tester);
      await tester.tap(find.byType(TtcTodayRow).last);
      await tester.pumpAndSettle();
      expect(find.byType(TtcProductsScreen), findsOneWidget);
    });

    test('a row stays a row — capped, but not cut mid-sentence', () {
      // Started at one line, which was stricter than the reference: parenting's
      // own rows wrap to two. On the device the myth row read "Irregular
      // periods mean you cannot conc…", truncating the claim mid-word — and for
      // a myth the statement IS the hook.
      //
      // Two is the cap. Not three, because at three it stops being scannable
      // and becomes the paragraph this whole exercise was removing.
      final src = codeOf('lib/screens/ttc/ttc_today_parts.dart');
      final row = src.substring(src.indexOf('class TtcTodayRow'));
      expect(row, contains('maxLines: 2'));
      expect(row, isNot(contains('maxLines: 3')));
      expect(row, contains('TextOverflow.ellipsis'));
    });
  });

  // ===========================================================================
  group('but the DOING keeps its cards', () {
    // Density work has to know the difference between something you read and
    // something you use. The ritual has per-item checkboxes, a count and a
    // streak; the journal has four shortcut circles. Collapsing either into a
    // row would remove the ability to do the thing from Today - that is taking
    // away function, not compacting it.
    test('the ritual and journal cards are still built', () {
      final src = codeOf('lib/screens/ttc/ttc_today_screen.dart');
      expect(src, contains('_RitualCard(t: t, chapter: chapter)'));
      expect(src, contains('_JournalCard(t: t, chapter: chapter)'));
    });

    testWidgets('and the ritual can still be ticked from Today',
        (tester) async {
      await pumpToday(tester);
      // Its checkboxes are what make it a card rather than a row.
      expect(find.byType(TtcTodayRow), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  group('the video card is gone, and that is not the empty-state rule', () {
    test('it is not rendered', () {
      final src = codeOf('lib/screens/ttc/ttc_today_screen.dart');
      expect(src, isNot(contains('_VideoCard(t: t')));
    });

    test('but it is kept for revert, not deleted', () {
      // "Comment out, never delete" - the content returns the day videos do.
      final raw = File('lib/screens/ttc/ttc_today_screen.dart')
          .readAsStringSync();
      expect(raw, contains('_VideoCard'));
      expect(raw, contains('KEPT FOR REVERT'));
    });

    test('the superseded cards are all kept the same way', () {
      final raw = File('lib/screens/ttc/ttc_today_screen.dart')
          .readAsStringSync();
      for (final c in [
        '_MythCard',
        '_NutritionCard',
        '_MovementCard',
        '_ProductCard',
      ]) {
        expect(raw, contains(c), reason: '$c was deleted rather than parked');
      }
    });
  });

  // ===========================================================================
  group('the hero orients and the sheet explains', () {
    testWidgets('the hero no longer carries the category label',
        (tester) async {
      // "FOCUS · Health and habits" told her which drawer she was in, which the
      // title already does. It is the one of the four fragments with no content
      // worth moving, so it is the only one actually dropped.
      await pumpToday(tester);
      expect(find.text(const TtcS(false).currentFocus.toUpperCase()),
          findsNothing);
    });

    testWidgets('nor the static 28-day action line', (tester) async {
      await pumpToday(tester);
      expect(find.text(TtcChapter.preparingTogether.goal(false)), findsNothing);
    });

    testWidgets('and both of those are in the sheet instead', (tester) async {
      await pumpToday(tester);
      await tester.tap(find.byType(TtcChapterInfoButton));
      await tester.pumpAndSettle();
      expect(find.text(TtcChapter.preparingTogether.goal(false)),
          findsOneWidget);
    });

    test('every chapter has a reassurance, in both languages', () {
      // The sentence that was nowhere on the screen at all, and is probably the
      // most useful one in each chapter: the thing she is worried she is doing
      // wrong is not a thing that can be done wrong.
      for (final c in TtcChapter.values) {
        expect(c.reassurance(false), isNotEmpty, reason: '$c English');
        expect(c.reassurance(true), isNotEmpty, reason: '$c Hinglish');
        expect(c.reassurance(false), isNot(c.reassurance(true)),
            reason: '$c was never translated');
        expect(c.reassurance(false).length, greaterThan(80),
            reason: '$c is too short to reassure anyone');
      }
    });

    test('and none of them promises an outcome', () {
      for (final c in TtcChapter.values) {
        final s = c.reassurance(false).toLowerCase();
        expect(s, isNot(contains('will happen')));
        expect(s, isNot(contains('chance')));
        expect(s, isNot(contains('guarantee')));
      }
    });
  });

  // ===========================================================================
  test('every new string is bilingual', () {
    const en = TtcS(false);
    const hi = TtcS(true);
    for (final p in [
      (en.infoWhatThisIs, hi.infoWhatThisIs),
      (en.infoWhatMovesYouOn, hi.infoWhatMovesYouOn),
      (en.infoWorthDoing, hi.infoWorthDoing),
      (en.infoNotToWorry, hi.infoNotToWorry),
      (en.todayList, hi.todayList),
    ]) {
      expect(p.$1, isNotEmpty);
      expect(p.$2, isNotEmpty);
      expect(p.$1, isNot(p.$2), reason: 'never translated: ${p.$1}');
    }
  });
}
