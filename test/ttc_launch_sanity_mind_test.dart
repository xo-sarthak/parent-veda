// =============================================================================
//  Launch sanity, Mind & body and the practice players (2026-09-28)
// -----------------------------------------------------------------------------
//  One test per row fixed in docs/TTC-LAUNCH-SANITY.md, so each fails loudly
//  if it slides back:
//   · MB18  the home's "Today's movement", the Sanskar's "Today's breath" and
//           Mind & body › Today name the same practice on the same day;
//   · MB10  the player's time-and-place line sits clear of the sheet's top;
//   · MB11  the movement ring shows the time for the step she is on;
//   · MB12  "Ready" is centred in the breathing disc;
//   · MB13  the breath player's header field stays in the blue family;
//   · MB14  ring, then the step and its controls, then all steps, then done;
//   · MB6   no kind chip repeats the heading above a Today card;
//   · MB8   "Getting ready" is a pill that says where it goes;
//   · MB21  the TTC psychologist's cover is not the glum face;
//   · H15   the ritual page wears the home's name and one sentence.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/learn/pv_learn_images.dart';
import 'package:parentveda/data/learn/pv_learn_view.dart';
import 'package:parentveda/screens/brackets/hub/hub_intent_art.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/ttc/ttc_mind_today_screen.dart';
import 'package:parentveda/screens/ttc/ttc_practice_player.dart';
import 'package:parentveda/screens/ttc/ttc_practice_screen.dart';
import 'package:parentveda/screens/ttc/ttc_ritual_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_garbh_course_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_mind_today.dart';
import 'package:parentveda/ttc/ttc_practice_data.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/widgets/breathing_circle.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {double width = 360, double height = 4000}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump(const Duration(milliseconds: 300));
}

/// Source lines that are not whole-line comments.
String _live(String path) => File(path)
    .readAsLinesSync()
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

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

  final breath = ttcPracticeById('mb_longout')!;
  final move = ttcPracticeById('mb_loosen')!;

  // ===========================================================================
  group('MB18: one picker for today', () {
    test('the home movement is the Today movement, every day of a year', () {
      for (var d = 0; d < 366; d++) {
        final day = DateTime(2026, 1, 1).add(Duration(days: d));
        expect(ttcTodaysMoveTip(on: day).titleEn, ttcTodaysMove(on: day).title);
      }
    });

    test('the Sanskar breath is the Today breath, in every chapter', () {
      for (final c in TtcChapter.values) {
        final items = ttcSanskarItems(c);
        final b = items.where((i) => i.part == TtcRitualPart.breath);
        if (b.isEmpty) continue;
        expect(b.single.textEn, startsWith(ttcTodaysBreathe().title));
        // The other four parts are the chapter's own words.
        final original = ttcRituals[c]!;
        for (var i = 0; i < items.length; i++) {
          if (items[i].part != TtcRitualPart.breath) {
            expect(items[i].textEn, original[i].textEn);
          }
        }
      }
    });

    test('the home reads the picker (wiring gate)', () {
      final home = _live('lib/screens/ttc/ttc_home_v3.dart');
      expect(home, contains('final m = ttcTodaysMoveTip(on: selected);'));
      expect(home, contains('final items = ttcSanskarItems(chapter);'));
      final ritual = _live('lib/screens/ttc/ttc_ritual_screen.dart');
      expect(ritual, contains('ttcSanskarItems(chapter)'));
    });

    testWidgets("Today's two headings match the home's names", (tester) async {
      await _pump(tester, const TtcMindTodayScreen());
      expect(find.text("Today's movement"), findsOneWidget);
      expect(find.text("Today's breath"), findsOneWidget);
      // MB6: no chip inside the card repeats the heading.
      expect(find.text('Move'), findsNothing);
      expect(find.text('Breathe'), findsNothing);
    });
  });

  // ===========================================================================
  group('the players', () {
    testWidgets('MB10: the time-and-place line sits inside the sheet',
        (tester) async {
      await _pump(tester, TtcPracticeScreen(practice: move));
      final meta = find.text('${move.duration} · ${move.setting}');
      expect(meta, findsOneWidget);
      final sheet = find.ancestor(
          of: meta,
          matching: find.byWidgetPredicate((w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).borderRadius ==
                  const BorderRadius.vertical(top: Radius.circular(28))));
      expect(sheet, findsOneWidget);
      final gap =
          tester.getTopLeft(meta).dy - tester.getTopLeft(sheet).dy;
      expect(gap, greaterThanOrEqualTo(16),
          reason: 'the line sat on the rounded edge');
    });

    testWidgets('MB11: the movement ring shows the time for the step',
        (tester) async {
      await _pump(tester, TtcPracticeScreen(practice: move));
      final per = (move.anim.seconds / move.steps.length).ceil();
      final clock = '${per ~/ 60}:${(per % 60).toString().padLeft(2, '0')}';
      expect(find.text(clock), findsOneWidget);
      expect(find.text('Step 1 of ${move.steps.length}'), findsOneWidget);
    });

    testWidgets('MB12: "Ready" is centred in the disc', (tester) async {
      await _pump(tester, TtcPracticeScreen(practice: breath));
      final ready = find.text('Ready');
      expect(ready, findsOneWidget);
      final disc = tester.getCenter(find.byType(PvBreathingCircle));
      final word = tester.getCenter(ready);
      expect((word.dy - disc.dy).abs(), lessThan(2));
      expect((word.dx - disc.dx).abs(), lessThan(2));
    });

    testWidgets('MB13: the breath header field is painted from the blue hue',
        (tester) async {
      await _pump(tester, TtcPracticeScreen(practice: breath));
      final s = tester.widget<TtcToolScaffold>(find.byType(TtcToolScaffold));
      expect(s.hue, kTtcBreatheFieldHue);
      // The field's second stop is 34 degrees round; it must stay blue, short
      // of the lilac that 206 + 34 = 240 painted.
      expect(s.hue + 34, lessThan(230));
      expect(s.hue + 34, greaterThan(kTtcBreatheHue));
    });

    testWidgets('MB14: ring, then the step and its controls, then the list',
        (tester) async {
      await _pump(tester, TtcPracticeScreen(practice: move));
      double top(Finder f) => tester.getTopLeft(f.first).dy;
      final ring = tester.getBottomLeft(find.byType(TtcPracticeSession)).dy;
      final step = top(find.text(move.steps.first));
      final prev = top(find.text('Previous step'));
      final all = top(find.text('All steps'));
      final done = top(find.text('Mark done today'));
      expect(ring, lessThan(step));
      expect(step, lessThan(prev));
      final stepBottom =
          tester.getBottomLeft(find.text(move.steps.first).first).dy;
      expect(prev - stepBottom, lessThan(60),
          reason: 'the controls sit right under the step she is on');
      expect(prev, lessThan(all));
      expect(all, lessThan(done));
      // Both settings are labelled switches.
      expect(find.text('The steps move along with the timer.'),
          findsOneWidget);
    });

    testWidgets('MB14: a breath practice shows its vibration as a switch',
        (tester) async {
      await _pump(tester, TtcPracticeScreen(practice: breath));
      expect(find.byType(TtcVibrateSwitch), findsOneWidget);
      expect(find.textContaining('Vibrate on each breath:'), findsNothing);
    });

    testWidgets('MB6: the player names the kind as the Today heading does',
        (tester) async {
      await _pump(tester, TtcPracticeScreen(practice: move));
      expect(find.text('MOVEMENT'), findsOneWidget);
      await _pump(tester, TtcPracticeScreen(practice: breath));
      expect(find.text('BREATH'), findsOneWidget);
    });
  });

  // ===========================================================================
  testWidgets('MB8: Getting ready is a pill that says where it goes',
      (tester) async {
    await _pump(tester, const TtcMindTodayScreen());
    expect(find.text('What to eat, in Getting ready'), findsOneWidget);
    expect(find.textContaining('What to eat is in Getting ready'),
        findsNothing);
    expect(_live('lib/screens/ttc/ttc_mind_today_screen.dart'),
        contains("openTtcDoor(context, kTtcGettingReadyDoorId,\n"
            "              initialGroup: 'diet')"));
  });

  test('MB21: the TTC psychologist is not drawn as a glum face', () {
    final v = PvLearnCatalog.instance.byId('ttc_psych_consult')!;
    expect(pvLearnMarkFor(v.topics, v.kind), isNot(IntentMark.moodArc));
    // Other stages keep their mark.
    expect(pvLearnMarkFor(const ['mental'], PvLearnKind.consult),
        IntentMark.moodArc);
  });

  testWidgets('H15: the ritual page wears the home name, in one sentence',
      (tester) async {
    await _pump(tester,
        const TtcRitualScreen(chapter: TtcChapter.tryingTogether));
    expect(find.text(const TtcS(false).sanskarTitle.toUpperCase()),
        findsOneWidget);
    expect(find.text('Picked for your fertile days.'), findsOneWidget);
  });
}
