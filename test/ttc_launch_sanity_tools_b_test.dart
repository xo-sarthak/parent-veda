// =============================================================================
//  TTC launch sanity (2026-09-28): Tools rows T2, T9, T10, T11
// -----------------------------------------------------------------------------
//  T2  Weight and fertility (BMI) asked for a weight the Weight log already
//      held, and for a height she had given before. It now fills both and says
//      where each came from; and BMI is reached from the Weight page.
//  T9  Courses opened a catalogue (chips, bookmark, profile) around the one
//      course the stage has. With one course, it opens that course.
//  T10 Journey map's "Still ahead" read as goals to tick, ending on "A
//      positive test". Now "Things you can try": doings, never outcomes.
//  T11 Our journal was the one tool on a plain app bar, with two write
//      buttons. It wears the tool shell and has one.
//  (T4 and the Weight page's BMI row are held in ttc_tools_test.dart.)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/learn/pv_learn_screen.dart';
import 'package:parentveda/screens/ttc/ttc_bmi_screen.dart';
import 'package:parentveda/screens/ttc/ttc_garbh_course_screen.dart';
// Kept for revert (2026-09-28, the user: no journal in trying to conceive).
// import 'package:parentveda/screens/ttc/ttc_journal_screen.dart';
import 'package:parentveda/screens/ttc/ttc_journey_map_screen.dart';
import 'package:parentveda/screens/ttc/ttc_prepare_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
// import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart'; // only T11 used it (2026-09-28)
import 'package:parentveda/ttc/ttc_bmi_store.dart';
// import 'package:parentveda/ttc/ttc_daily_data.dart'; // only the journal tests used it (2026-09-28)
// import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {double height = 4000}) async {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'overflow at 360dp');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TtcLang.instance.hinglish = false;
    TtcLogStore.instance.resetForTest();
    TtcBmiStore.instance.resetForTest();
    await TtcBmiStore.instance.load();
    TtcStore.instance.resetForTest();
    // Kept for revert (2026-09-28): TtcJournalStore.instance.resetForTest();
  });

  // ===========================================================================
  group('T2: the BMI screen fills in what the app holds', () {
    testWidgets('her latest Weight log fills the weight, and says so',
        (tester) async {
      TtcLogStore.instance.log('weight', 'kg', 58.5);
      await _pump(tester, const TtcBmiScreen());
      expect(find.widgetWithText(TextField, '58.5'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_bmi_weight_from')), findsOneWidget);
      expect(find.textContaining('From your Weight log'), findsOneWidget);
    });

    testWidgets('her height is remembered without saving a result',
        (tester) async {
      await TtcBmiStore.instance.rememberHeight(1.62);
      await _pump(tester, const TtcBmiScreen());
      expect(find.widgetWithText(TextField, '162'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_bmi_height_from')), findsOneWidget);
    });

    testWidgets('typing a different number takes the "from" line away',
        (tester) async {
      TtcLogStore.instance.log('weight', 'kg', 58.5);
      await _pump(tester, const TtcBmiScreen());
      await tester.enterText(find.widgetWithText(TextField, '58.5'), '60');
      await tester.pump();
      expect(find.byKey(const ValueKey('ttc_bmi_weight_from')), findsNothing);
    });

    testWidgets('working a number out remembers the height', (tester) async {
      await _pump(tester, const TtcBmiScreen());
      await tester.enterText(find.byType(TextField).at(0), '160');
      await tester.enterText(find.byType(TextField).at(1), '55');
      await tester.tap(find.text('See my result').last);
      await tester.pumpAndSettle();
      expect(TtcBmiStore.instance.heightMetres, closeTo(1.60, 0.001));
      expect(TtcBmiStore.instance.history, isEmpty,
          reason: 'remembering the height is not saving the result');
    });

    testWidgets('its eyebrow is the Weight tool it belongs to', (tester) async {
      await _pump(tester, const TtcBmiScreen());
      expect(find.text('WEIGHT'), findsOneWidget);
      expect(find.text('WEIGHT AND FERTILITY'), findsNothing);
    });
  });

  // ===========================================================================
  group('T9: Courses with one course opens the course', () {
    testWidgets('no catalogue around a single course', (tester) async {
      final courses = TtcPrepareScreen.ttcCourses;
      await _pump(tester, const TtcPrepareScreen(onlyCategory: 'courses'));
      if (courses.length == 1) {
        expect(find.byType(PvLearnScreen), findsNothing);
        expect(find.byType(TtcGarbhCourseScreen), findsOneWidget);
      } else {
        expect(find.byType(PvLearnScreen), findsOneWidget,
            reason: 'two or more courses bring the catalogue back');
      }
    });

    testWidgets('consults still open the catalogue', (tester) async {
      await _pump(tester, const TtcPrepareScreen(onlyCategory: 'consults'));
      expect(find.byType(PvLearnScreen), findsOneWidget);
    });
  });

  // ===========================================================================
  group('T10: the map offers things to try, not goals', () {
    testWidgets('no scorecard, and no positive test as an item',
        (tester) async {
      await _pump(tester, const TtcJourneyMapScreen());
      expect(find.text(kTtcMapTryHeading.toUpperCase()), findsOneWidget);
      expect(find.text('STILL AHEAD'), findsNothing);
      // Kept for revert (2026-09-28): 'Whenever it comes.'
      expect(find.text('Whenever your positive test comes.'), findsNothing);
      expect(find.byKey(const ValueKey('ttc_map_try_positive_test')),
          findsNothing);
      expect(find.byKey(const ValueKey('ttc_map_try_first_cycle_complete')),
          findsNothing);
      // Rows are the doing, not the achievement.
      // Kept for revert (2026-09-28, journal out of TTC): the journal's row
      // left the map with the journal.
      //   expect(find.text('Write in the journal'), findsOneWidget);
      expect(find.text('Write in the journal'), findsNothing);
      expect(find.text('Kept the daily ritual for a week'), findsNothing);
      expect(find.text('Open your daily ritual'), findsOneWidget);
    });
  });

  // ===========================================================================
  // Kept for revert (2026-09-28, the user: no journal in trying to conceive).
  // The journal page is commented out, so T11 is too.
  // group('T11: Our journal wears the tool shell, with one write action', () {
  //   testWidgets('the tool header, and one write button', (tester) async {
  //     await _pump(tester, const TtcJournalScreen());
  //     expect(find.byType(TtcToolScaffold), findsOneWidget);
  //     expect(find.byType(AppBar), findsNothing);
  //     expect(find.text('OUR JOURNAL'), findsOneWidget);
  //     expect(find.text('Write something'), findsOneWidget);
  //     expect(find.text('Write about this'), findsNothing,
  //         reason: 'the second write button is gone');
  //     // Today's prompt is still offered, as a line under the button.
  //     final prompt =
  //         ttcPromptForToday(TtcStore.instance.today.chapter).text(false);
  //     expect(find.text(prompt), findsOneWidget);
  //     expect(find.byKey(const ValueKey('ttc_journal_prompt')), findsOneWidget);
  //   });
  //
  //   testWidgets('entries still list under it', (tester) async {
  //     TtcJournalStore.instance
  //         .add(kind: TtcEntryKind.memory, text: 'A quiet evening');
  //     await _pump(tester, const TtcJournalScreen());
  //     expect(find.text('A quiet evening'), findsOneWidget);
  //   });
  // });
}
