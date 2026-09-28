// =============================================================================
//  The practice card family (2026-09-28)
// -----------------------------------------------------------------------------
//  The user: the Movement and Breath cards "did not have the basics right:
//  placement, font, positioning of text", then "do this Headspace thing for
//  ALL cards like this ... especially Preconception Sanskar and Mind and
//  body". What this holds:
//   · no card in these files paints a large icon behind its words (the
//     watermark the fixed card had), read from the source so a new one fails
//     here before anyone sees it on a phone;
//   · the Sanskar cards on the home, the ritual page and Today build at 360dp
//     with one left edge, and a done part is taken back in words;
//   · leaving her own practice is announced with an Undo.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_home_v3.dart';
import 'package:parentveda/screens/ttc/ttc_mind_today_screen.dart';
import 'package:parentveda/screens/ttc/ttc_ritual_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_garbh_course_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_practice_data.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

/// The files whose cards are the family.
const _files = [
  'lib/screens/ttc/ttc_practice_card_parts.dart',
  'lib/screens/ttc/ttc_home_v3.dart',
  'lib/screens/ttc/ttc_ritual_screen.dart',
  'lib/screens/ttc/ttc_mind_today_screen.dart',
  'lib/screens/ttc/ttc_practice_screen.dart',
  'lib/screens/ttc/ttc_practice_player.dart',
  'lib/screens/ttc/ttc_garbh_course_screen.dart',
];

/// The source with whole-line comments removed. Kept-for-revert code lives in
/// comments on purpose and is not what the app draws. (Only whole lines: a
/// `//` inside a string is a URL, not a comment.)
String _live(String path) => File(
  path,
).readAsLinesSync().where((l) => !l.trimLeft().startsWith('//')).join('\n');

/// The text of the call that opens at [start] (the index of its `(`), to the
/// matching `)`.
String _call(String src, int start) {
  var depth = 0;
  for (var i = start; i < src.length; i++) {
    final c = src[i];
    if (c == '(') depth++;
    if (c == ')') {
      depth--;
      if (depth == 0) return src.substring(start, i + 1);
    }
  }
  return src.substring(start);
}

/// Every `Icon(...)` call's size in [src], where it gives a literal one.
Iterable<double> _iconSizes(String src) sync* {
  for (final m in RegExp(r'(?<![A-Za-z_])Icon\(').allMatches(src)) {
    final body = _call(src, m.end - 1);
    final size = RegExp(r'size:\s*([0-9.]+)').firstMatch(body);
    if (size != null) yield double.parse(size.group(1)!);
  }
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 360,
  double height = 3000,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcGarbhCourseStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  group('no art behind the words', () {
    test('no card paints an Icon larger than 60 inside a Positioned', () {
      for (final path in _files) {
        final src = _live(path);
        for (final m in RegExp(r'(?<![A-Za-z_])Positioned\(').allMatches(src)) {
          final body = _call(src, m.end - 1);
          for (final size in _iconSizes(body)) {
            expect(
              size,
              lessThanOrEqualTo(60),
              reason:
                  '$path: a ${size.toInt()}pt icon inside a Positioned is '
                  'a watermark behind a card\'s words (2026-09-28)',
            );
          }
        }
      }
    });

    test('and no watermark-sized Icon anywhere in these cards', () {
      // The practice player's figure sat UNpositioned in a Stack under
      // "Step 3 of 6"; a Positioned check alone would have missed it.
      for (final path in _files) {
        for (final size in _iconSizes(_live(path))) {
          expect(
            size,
            lessThanOrEqualTo(60),
            reason: '$path: a ${size.toInt()}pt icon',
          );
        }
      }
    });
  });

  group('the Sanskar cards', () {
    testWidgets('home: five cards at 360dp, one left edge, done in words', (
      tester,
    ) async {
      await _pump(tester, const TtcHomeV3(), height: 800);
      final t = TtcS.current();
      final pills = find.text(t.ritualMarkDone, skipOffstage: false);
      for (var i = 0; i < 14 && pills.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(pills, findsNWidgets(TtcRitualStore.instance.total));
      expect(tester.takeException(), isNull);

      // Title, words and button share the card's left edge.
      // Whichever chapter the home is on, its first part is on screen.
      final item = ttcRituals.values
          .map((items) => items.first)
          .firstWhere(
            (i) => find
                .text(i.text(false), skipOffstage: false)
                .evaluate()
                .isNotEmpty,
          );
      await tester.ensureVisible(find.text(item.text(false)));
      await tester.pump();
      final title = tester.getTopLeft(find.text(item.part.title(false))).dx;
      final body = tester.getTopLeft(find.text(item.text(false))).dx;
      final pill = tester.getTopLeft(pills.first).dx;
      expect(body, title);
      // The pill's words sit 16 inside its own left edge.
      expect(pill - 16, title);

      await tester.tap(pills.first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(TtcRitualStore.instance.isDone(item.part), isTrue);
      expect(find.text(t.sanskarDoneToday), findsOneWidget);
      await tester.tap(find.text('Mark not done'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(TtcRitualStore.instance.isDone(item.part), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ritual page: every part opens at 360dp, done shows a chip', (
      tester,
    ) async {
      await _pump(
        tester,
        const TtcRitualScreen(chapter: TtcChapter.tryingTogether),
        height: 3000,
      );
      final t = TtcS.current();
      for (final part in TtcRitualPart.values) {
        await tester.tap(find.text(part.title(false)));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$part');
      }
      // The last part opened is the action: mark it, see the chip.
      await tester.tap(find.text(t.ritualMarkDone));
      await tester.pump();
      expect(find.text(t.sanskarDoneToday), findsOneWidget);
      expect(find.text('Mark not done'), findsOneWidget);
      expect(
        find.text('Tap again to undo.'),
        findsNothing,
        reason: 'the button says it now',
      );
      await tester.tap(find.text('Mark not done'));
      await tester.pump();
      expect(TtcRitualStore.instance.isDone(TtcRitualPart.action), isFalse);
    });
  });

  group('Mind and body Today', () {
    testWidgets('her own practice: leaving it is announced, with Undo', (
      tester,
    ) async {
      final move = ttcPracticesOfKind(TtcPracticeKind.move).first;
      final breathe = ttcPracticesOfKind(TtcPracticeKind.breathe).first;
      TtcGarbhCourseStore.instance.setDailyPractice(
        moveId: move.id,
        breatheId: breathe.id,
        couple: TtcCoupleDaily.gratitude,
      );
      await _pump(tester, const TtcMindTodayScreen());
      expect(tester.takeException(), isNull);
      expect(
        find.text('Together'),
        findsOneWidget,
        reason: 'the couple part is a card of the family, with its chip',
      );

      await tester.tap(find.text('Show a different practice each day'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(TtcGarbhCourseStore.instance.hasPractice, isFalse);
      expect(
        find.text('Today now shows a different practice each day.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(TtcGarbhCourseStore.instance.hasPractice, isTrue);
      expect(TtcGarbhCourseStore.instance.moveId, move.id);
      expect(TtcGarbhCourseStore.instance.couple, TtcCoupleDaily.gratitude);
    });
  });
}
