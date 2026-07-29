// =============================================================================
//  The reader, and the home that feeds it
// -----------------------------------------------------------------------------
//  A-50. TTC's reader was a title, a body and a takeaway on a fixed white page.
//  Parenting has progress, contents, font size, light/sepia/dark, read-next and
//  save. Same company, two readers, and the poorer one was attached to the more
//  anxious audience.
//
//  The related half is density. Parenting's home caps text in fourteen places
//  and follows each with an explicit link; TTC's Today capped five times across
//  nine cards, and five of those cards printed their body uncapped. That is why
//  one reads as a menu and the other as a wall.
//
//  What these pin is the PRINCIPLE, not the component list — see the note on
//  the table of contents below.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_insight_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_read_store.dart';

/// A Dart file with its comments removed.
///
/// Every source-scanning assertion in this repo needs this, and three separate
/// tests today failed by matching their own explanation: a check for "no table
/// of contents" tripped on the comment saying why there isn't one, and a check
/// that a store has no `TtcSyncedStore` tripped on the comment saying it
/// deliberately doesn't.
///
/// The lesson generalises past Dart. **A test that greps source is reading
/// prose as well as code**, and prose about a thing contains the name of the
/// thing. Assert against what executes.
String codeOf(String path) => File(path)
    .readAsLinesSync()
    .where((l) => !l.trimLeft().startsWith('//'))
    .where((l) => !l.trimLeft().startsWith('///'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcReadStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  Future<void> pumpReader(WidgetTester tester, TtcInsight i) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        MaterialApp(key: UniqueKey(), home: TtcInsightScreen(insight: i)));
    await tester.pumpAndSettle();
  }

  // ===========================================================================
  group('the reader has what parenting has', () {
    testWidgets('it builds, with the piece on it', (tester) async {
      final i = ttcInsights.first;
      await pumpReader(tester, i);
      expect(tester.takeException(), isNull);
      expect(find.text(i.title(false)), findsOneWidget);
    });

    testWidgets('save is reachable and sticks', (tester) async {
      final i = ttcInsights.first;
      await pumpReader(tester, i);
      expect(TtcReadStore.instance.isSaved(i.id), isFalse);
      await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
      await tester.pumpAndSettle();
      expect(TtcReadStore.instance.isSaved(i.id), isTrue);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    });

    testWidgets('reading settings open, with size and background',
        (tester) async {
      await pumpReader(tester, ttcInsights.first);
      await tester.tap(find.byIcon(Icons.text_fields_rounded));
      await tester.pumpAndSettle();
      const t = TtcS(false);
      expect(find.text(t.readSettings), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text(t.readModeSepia), findsOneWidget);
      expect(find.text(t.readModeDark), findsOneWidget);
    });

    testWidgets('and finishing one leads somewhere', (tester) async {
      // The payoff of putting content behind a tap: a piece must not dead-end
      // on the back button.
      await pumpReader(tester, ttcInsights.first);
      expect(find.text(const TtcS(false).readNext.toUpperCase()),
          findsOneWidget);
    });
  });

  // ===========================================================================
  group('but NOT what would be ceremony here', () {
    test('no table of contents on a sixty-second read', () {
      // Parenting's reader has one, and copying it would have been the easy
      // call. A TTC insight has no sections - a contents list on it is a
      // control that exists to look thorough and answers a question nobody has.
      //
      // Match the other stage's standard of care, not its component list.
      final src = codeOf('lib/screens/ttc/ttc_insight_screen.dart')
          .toLowerCase();
      expect(src, isNot(contains('icons.toc')));
      expect(src, isNot(contains('_opentoc')));
    });

    test('and no completion metric anywhere', () {
      // Progress exists to resume, never to score. "3 of 25 read" would turn
      // reading into a streak in a product whose whole posture is that this is
      // not a performance.
      final store = codeOf('lib/ttc/ttc_read_store.dart');
      expect(store, isNot(contains('percentRead')));
      expect(store, isNot(contains('completedCount')));

      // No percentage rendered anywhere. On a health article it invites her to
      // judge whether the rest is worth finishing.
      final src = codeOf('lib/screens/ttc/ttc_insight_screen.dart');
      expect(src, isNot(contains("'%'")));
      expect(src, isNot(contains('* 100')));
    });
  });

  // ===========================================================================
  group('progress is for resuming, not for grading', () {
    test('it only ever moves forward', () {
      // Scrolling back to re-read a paragraph is not losing your place, and a
      // value that fell on every upward flick would make the bar jitter.
      const id = 'x';
      TtcReadStore.instance.setProgress(id, 0.6);
      TtcReadStore.instance.setProgress(id, 0.2);
      expect(TtcReadStore.instance.progressOf(id), 0.6);
    });

    test('and is clamped to something meaningful', () {
      TtcReadStore.instance.setProgress('y', 4.0);
      expect(TtcReadStore.instance.progressOf('y'), 1.0);
    });

    test('"in progress" excludes barely-started and finished', () {
      TtcReadStore.instance.setProgress('a', 0.01);
      TtcReadStore.instance.setProgress('b', 0.5);
      TtcReadStore.instance.setProgress('c', 0.99);
      expect(TtcReadStore.instance.isInProgress('a'), isFalse);
      expect(TtcReadStore.instance.isInProgress('b'), isTrue);
      expect(TtcReadStore.instance.isInProgress('c'), isFalse);
    });

    test('the store stays local — no table, no sync mixin', () {
      final src = codeOf('lib/ttc/ttc_read_store.dart');
      expect(src, isNot(contains('TtcSyncedStore')));
      expect(src, isNot(contains('SupabaseRepo')));
    });
  });

  // ===========================================================================
  group('Today stops printing whole paragraphs', () {
    test('every uncapped card body now folds', () {
      // The five that printed their body with no cap: Rhythm, Video, Myth,
      // Nutrition, Movement. Four now fold (the video card's body is a single
      // "coming soon" line, which has nothing to fold).
      final src =
          File('lib/screens/ttc/ttc_today_screen.dart').readAsStringSync();
      expect(RegExp('TtcExpandableText').allMatches(src).length,
          greaterThanOrEqualTo(4));
    });

    testWidgets('the control only appears when something is behind it',
        (tester) async {
      // A "More" that reveals nothing is worse than no control at all.
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            child: TtcExpandableText(text: 'Short.', t: const TtcS(false)),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text(const TtcS(false).showMore), findsNothing);
    });

    testWidgets('and it opens in place when there is', (tester) async {
      const long =
          'A cycle is not a countdown to a period. It is two halves, and the '
          'second one is fairly fixed in length while almost all of the '
          'variation sits in the first, in how long an egg takes to be ready. '
          'That is why a cycle that shifts by a few days is ordinary.';
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: TtcExpandableText(text: long, t: TtcS(false)),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text(const TtcS(false).showMore), findsOneWidget);
      await tester.tap(find.text(const TtcS(false).showMore));
      await tester.pumpAndSettle();
      expect(find.text(const TtcS(false).showLess), findsOneWidget);
    });

    test('nothing was hidden that has nowhere to go', () {
      // The rule this batch turns on: you can only hide what has somewhere to
      // live. Movement and the myth have no detail screen, so they expand in
      // place rather than truncating into nothing.
      // Asserted against the widget's own contract rather than a sentence in a
      // comment - the same mistake `codeOf` exists to stop.
      final src = codeOf('lib/screens/ttc/ttc_common.dart');
      expect(src, contains('class TtcExpandableText'));
      expect(src, contains('didExceedMaxLines'),
          reason: 'the control must only appear when text is actually folded');
    });
  });

  // ===========================================================================
  test('every new string is bilingual', () {
    const en = TtcS(false);
    const hi = TtcS(true);
    for (final p in [
      (en.readSettings, hi.readSettings),
      (en.readTextSize, hi.readTextSize),
      (en.readMode, hi.readMode),
      (en.readNext, hi.readNext),
      (en.showMore, hi.showMore),
      (en.showLess, hi.showLess),
    ]) {
      expect(p.$1, isNotEmpty);
      expect(p.$2, isNotEmpty);
      expect(p.$1, isNot(p.$2), reason: 'never translated: ${p.$1}');
    }
  });
}
