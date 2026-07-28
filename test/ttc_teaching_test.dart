// =============================================================================
//  What the stage names but never explained
// -----------------------------------------------------------------------------
//  The audit's sharpest finding was not a bug. It was that a woman who does not
//  already know this subject learns nothing: the app says "ovulation strip",
//  "temperature rise", "day 2-3" and defines none of them, then asks her to
//  "mark as done" - a checklist verb for something that is a reading.
//
//  Four gaps closed here:
//    * both signals explained, including that a temperature rise CONFIRMS
//      ovulation after the fact rather than predicting it
//    * a severe symptom acknowledged, because Ask Veda already routes the same
//      words to a doctor while the tracker recorded them in silence
//    * when in the cycle to take a test, on the collapsed card - getting that
//      wrong costs a month, not just a result
//    * a journal prompt on an empty journal, from sixteen that existed in data
//      and never reached a screen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_screens.dart';
import 'package:parentveda/screens/ttc/ttc_journal_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tests_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tracker_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_tests_data.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_trackers_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  Future<void> pumpTall(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1200, 9000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
    await tester.pumpAndSettle();
  }

  // ===========================================================================
  group('the two signals are explained, not just named', () {
    testWidgets('an ovulation strip says what it is and where to get one',
        (tester) async {
      CycleStore.instance
          .logPeriodStart(DateTime.now().subtract(const Duration(days: 8)));
      await pumpTall(tester, const TtcOvulationScreen());
      expect(find.textContaining('pharmacy'), findsOneWidget);
      // A price, because "buy an ovulation strip" is a different sentence when
      // you do not know if it costs thirty rupees or three thousand.
      expect(find.textContaining('₹'), findsWidgets);
    });

    testWidgets('and the temperature says it confirms rather than predicts',
        (tester) async {
      CycleStore.instance
          .logPeriodStart(DateTime.now().subtract(const Duration(days: 8)));
      await pumpTall(tester, const TtcOvulationScreen());
      // The single most important fact about BBT, and it was nowhere.
      expect(find.textContaining('AFTER ovulation'), findsOneWidget);
      expect(find.textContaining('basal thermometer'), findsOneWidget);
    });

    test('both explanations exist in both languages', () {
      const en = TtcS(false);
      const hi = TtcS(true);
      expect(en.ovulationLhWhat, isNot(hi.ovulationLhWhat));
      expect(en.ovulationBbtWhat, isNot(hi.ovulationBbtWhat));
    });

    testWidgets('"Mark as done" is gone - it is a reading, not a task',
        (tester) async {
      CycleStore.instance
          .logPeriodStart(DateTime.now().subtract(const Duration(days: 8)));
      await pumpTall(tester, const TtcOvulationScreen());
      expect(find.text('Record it'), findsNWidgets(2));
      expect(find.text('Mark as done'), findsNothing);
    });
  });

  // ===========================================================================
  group('a severe symptom is acknowledged', () {
    testWidgets('nothing is said when nothing is severe', (tester) async {
      await pumpTall(
          tester, TtcTrackerScreen(tracker: ttcTrackerById('symptoms')!));
      expect(find.textContaining('Worth mentioning'), findsNothing);
    });

    testWidgets('and it appears once the top of a scale is chosen',
        (tester) async {
      await pumpTall(
          tester, TtcTrackerScreen(tracker: ttcTrackerById('symptoms')!));
      await tester.tap(find.text('Severe').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Worth mentioning'), findsOneWidget);
    });

    test('it routes to a doctor without diagnosing anything', () {
      const t = TtcS(false);
      // The tracker's whole premise is notice, never diagnose - so this names
      // the thing worth saying and stops.
      expect(t.severeNoticedBody, contains('does not mean anything is wrong'));
      expect(t.severeNoticedBody, contains('appointment'));
    });
  });

  // ===========================================================================
  group('a test says when in the cycle to take it', () {
    test('every test carries that timing', () {
      for (final test in ttcTests) {
        expect(test.when(false), isNotEmpty, reason: test.name);
        expect(test.when(true), isNotEmpty, reason: test.name);
      }
    });

    testWidgets('and it is visible without expanding the card',
        (tester) async {
      await pumpTall(tester, const TtcTestsScreen());
      // FSH and LH read on the wrong day are not a slightly worse result, they
      // are a repeat test next cycle - so this cannot sit behind a fold.
      final fsh = ttcTests.firstWhere((t) => t.name.contains('FSH'));
      expect(find.textContaining(fsh.when(false).split('.').first),
          findsWidgets);
    });
  });

  // ===========================================================================
  group('an empty journal offers somewhere to start', () {
    testWidgets('a prompt is shown, and it is the one for today',
        (tester) async {
      await pumpTall(tester, const TtcJournalScreen());
      final expected = ttcPromptForToday(TtcStore.instance.today.chapter);
      expect(find.text(expected.text(false)), findsOneWidget,
          reason: 'sixteen prompts existed and none reached the screen');
    });

    testWidgets('phrased as an offer, never a task', (tester) async {
      await pumpTall(tester, const TtcJournalScreen());
      // No streaks, nothing that counts against her for skipping. Eyebrows in
      // this stage are uppercased.
      expect(find.textContaining('IF YOU WANT'), findsOneWidget);
    });
  });
}
