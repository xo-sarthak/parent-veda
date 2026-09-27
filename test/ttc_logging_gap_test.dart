// =============================================================================
//  The logging and partner gap work (gap analysis, 2026-09-26)
// -----------------------------------------------------------------------------
//  Holds the seven items from "Behind — Logging" and "Behind — Partner":
//
//   · New symptom ids exist, and every OLD id is exactly where it was. Ids are
//     persisted and synced; a rename orphans every day it was ever tapped.
//   · The gentle line shows after three days running, and not after two.
//   · The whole-cycle temperature chart lays out at 360pt, shades only where
//     we are allowed to, and never shades a clinic's cycle.
//   · The partner's question, the picture of his day, the share text.
//   · The pairing promise: see the skipped test at the bottom and why.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/ttc/ttc_mood_face.dart';
import 'package:parentveda/screens/ttc/ttc_partner_day_example.dart';
import 'package:parentveda/screens/ttc/ttc_partner_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_symptom_log_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_cycle_report.dart';
import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_logging_extras.dart';
import 'package:parentveda/ttc/ttc_partner_data.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcJournalStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcPartnerMode.instance.on = false;
    TtcLang.instance.hinglish = false;
  });

  List<String> idsOf(String groupId) => kTtcSymptomGroups
      .firstWhere((g) => g.id == groupId)
      .symptoms
      .map((s) => s.id)
      .toList();

  DateTime daysAgo(int n) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - n);
  }

  void cleanHistory() {
    final now = DateTime.now();
    CycleStore.instance
      ..logPeriodStart(now.subtract(const Duration(days: 68)))
      ..logPeriodStart(now.subtract(const Duration(days: 40)))
      ..logPeriodStart(now.subtract(const Duration(days: 12)));
  }

  // ⚠️ 360 WIDE, AND TALL ENOUGH THAT THE LIST BUILDS ITS LAST CARD. A
  // `ListView` only builds what is near the viewport, so a finder for the
  // chart at the bottom finds nothing at phone height, offstage or not. The
  // width is what this test is about; the height only has to hold the list.
  Future<void> pumpLogger(WidgetTester tester, {DateTime? day}) async {
    tester.view.physicalSize = const Size(360, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: TtcSymptomLogScreen(day: day)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  Future<void> scrollThrough(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull, reason: 'threw while scrolling');
    }
  }

  // ===========================================================================
  group('ids: new ones added, old ones untouched', () {
    test('the four feelings of trying exist, after the original eight', () {
      expect(idsOf(kTtcFeelingGroup), [
        'calm', 'happy', 'energetic', 'low',
        'anxious', 'irritated', 'mood_swings', 'tearful',
        'hopeful', 'guilty', 'cant_stop_thinking', 'hard_on_myself',
      ]);
    });

    test('Kegels and Breathing are in the rest of the day', () {
      expect(idsOf('life'), [
        'exercise', 'yoga', 'walk', 'stress',
        'travel', 'alcohol', 'illness', 'meditation',
        'kegels', 'breathing',
      ]);
    });

    test('every other group is exactly as it was', () {
      expect(idsOf('body'), [
        'all_fine', 'cramping', 'breast', 'headache', 'fatigue', 'backache',
        'bloating', 'acne', 'cravings', 'insomnia', 'nausea', 'pelvic_pain',
      ]);
      expect(idsOf('discharge'), [
        'disch_none', 'disch_eggwhite', 'disch_watery', 'disch_creamy',
        'disch_sticky', 'disch_spotting', 'disch_unusual',
      ]);
      expect(idsOf('sex'), [
        'sex_none', 'sex_unprotected', 'sex_protected',
        'sex_high_drive', 'sex_low_drive',
      ]);
      expect(idsOf('ovulation_test'), ['ov_none', 'ov_positive', 'ov_negative']);
      expect(idsOf(kTtcPregnancyTestGroup),
          ['pt_none', 'pt_positive', 'pt_negative', 'pt_faint']);
    });

    test('ids are unique across every group', () {
      final all = [for (final g in kTtcSymptomGroups) ...g.symptoms.map((s) => s.id)];
      expect(all.toSet().length, all.length);
    });

    test('the heavy three are real feeling ids, and hopeful is not one', () {
      final feelings = idsOf(kTtcFeelingGroup).toSet();
      expect(feelings.containsAll(kTtcHardThoughtIds), isTrue);
      expect(kTtcHardThoughtIds.contains('hopeful'), isFalse);
    });

    test('the new feelings draw faces, and carry no emoji', () {
      for (final id in ['hopeful', 'guilty', 'cant_stop_thinking', 'hard_on_myself']) {
        expect(ttcMoodFor(id), isNotNull, reason: id);
        expect(ttcSymptomById(id)!.emoji, isNull, reason: id);
      }
    });
  });

  // ===========================================================================
  group('the gentle line after three days running', () {
    void log(String id, int ago) => TtcLogStore.instance
        .log(kTtcSymptomTracker, id, 1, on: daysAgo(ago));

    test('two days is not enough', () {
      log('guilty', 0);
      log('hard_on_myself', 1);
      expect(ttcHardThoughtsRunOn(daysAgo(0)), isFalse);
    });

    test('three days running, any mix of the three, is', () {
      log('guilty', 0);
      log('hard_on_myself', 1);
      log('cant_stop_thinking', 2);
      expect(ttcHardThoughtsRunOn(daysAgo(0)), isTrue);
    });

    test('a gap breaks the run', () {
      log('guilty', 0);
      log('guilty', 1);
      log('guilty', 3);
      expect(ttcHardThoughtsRunOn(daysAgo(0)), isFalse);
    });

    test('other feelings do not count, hopeful included', () {
      log('guilty', 0);
      log('hopeful', 1);
      log('low', 1);
      log('guilty', 2);
      expect(ttcHardThoughtsRunOn(daysAgo(0)), isFalse);
    });

    testWidgets('the logger shows it only after the third day',
        (tester) async {
      log('guilty', 0);
      log('guilty', 1);
      await pumpLogger(tester);
      expect(find.text(kTtcHardThoughtsLine), findsNothing);

      log('cant_stop_thinking', 2);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(kTtcHardThoughtsLine), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the logger', () {
    testWidgets('the long feeling label fits the four-across row at 360pt',
        (tester) async {
      await pumpLogger(tester);
      expect(find.text("Can't stop thinking about it"), findsOneWidget);
      expect(find.text('Hard on myself'), findsOneWidget);
    });

    testWidgets('the faint-line link sits under the pregnancy test card',
        (tester) async {
      await pumpLogger(tester);
      expect(find.text(kTtcFaintLineLink, skipOffstage: false), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the morning temperature chart', () {
    test('no period, no cycle to draw on', () {
      final c = ttcBuildTempChart();
      expect(c.hasCycle, isFalse);
      expect(c.state, TtcReportState.noPeriod);
    });

    test('a known cycle shades the period and the fertile days', () {
      cleanHistory();
      for (var d = 0; d < 10; d++) {
        TtcLogStore.instance.log(kTtcTempTracker, kTtcTempField, 36.3,
            on: daysAgo(d + 2));
      }
      final c = ttcBuildTempChart();
      expect(c.hasCycle, isTrue);
      expect(c.periodTo, isNotNull);
      expect(c.fertileFrom, isNotNull);
      expect(c.fertileFrom! > c.periodTo!, isTrue,
          reason: 'a bleeding day must never be painted fertile');
      expect(c.days >= 28, isTrue, reason: 'the whole cycle, not days so far');
      expect(c.points, isNotEmpty);
    });

    test('a clinic-run cycle gets no shading and no average', () {
      cleanHistory();
      for (var d = 0; d < 10; d++) {
        TtcLogStore.instance.log(kTtcTempTracker, kTtcTempField, 36.3,
            on: daysAgo(d + 2));
      }
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      final c = ttcBuildTempChart();
      expect(c.state, TtcReportState.clinicHeld);
      expect(c.periodTo, isNull);
      expect(c.fertileFrom, isNull);
      expect(c.averageBefore, isNull);
      expect(c.points, isNotEmpty, reason: 'her readings still show');
    });

    testWidgets('renders at 360pt with readings, and says the one line',
        (tester) async {
      cleanHistory();
      for (var d = 0; d < 12; d++) {
        TtcLogStore.instance.log(
            kTtcTempTracker, kTtcTempField, 36.2 + (d.isEven ? 0.05 : 0),
            on: daysAgo(d));
      }
      await pumpLogger(tester);
      expect(find.text(kTtcTempChartTitle, skipOffstage: false), findsOneWidget);
      expect(find.text(kTtcTempChartNote, skipOffstage: false), findsOneWidget);
      await scrollThrough(tester);
    });

    testWidgets('and empty, with no period logged', (tester) async {
      await pumpLogger(tester);
      expect(find.text(kTtcTempChartNoCycle, skipOffstage: false),
          findsOneWidget);
      await scrollThrough(tester);
    });

    test('the old sparkline call is kept for revert, commented out', () {
      final src =
          File('lib/screens/ttc/ttc_symptom_log_screen.dart').readAsStringSync();
      expect(src, contains('//   SizedBox(height: 38, child: _Spark('));
    });
  });

  // ===========================================================================
  group('partner', () {
    test('thirty questions, no repeats, no dashes, no emoji', () {
      expect(kTtcTonightQuestions.length, 30);
      expect(kTtcTonightQuestions.toSet().length, 30);
      final dash = RegExp('—|–| - ');
      final emoji = RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
          unicode: true);
      for (final q in kTtcTonightQuestions) {
        expect(dash.hasMatch(q), isFalse, reason: q);
        expect(emoji.hasMatch(q), isFalse, reason: q);
        expect(q.endsWith('?'), isTrue, reason: q);
        expect(q.toLowerCase().contains('tested'), isFalse, reason: q);
      }
    });

    test('the question rotates daily', () {
      final a = ttcTonightQuestion(now: DateTime(2026, 9, 26));
      final b = ttcTonightQuestion(now: DateTime(2026, 9, 27));
      expect(a, isNot(b));
    });

    testWidgets('his view carries tonight\'s question', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          const MaterialApp(home: TtcPartnerTodayScreen()));
      await tester.pump();
      expect(find.text(kTtcTonightLabel.toUpperCase()), findsOneWidget);
      expect(find.text(ttcTonightQuestion()), findsOneWidget);
    });

    testWidgets('the picture of his day renders at 360pt', (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(
              body: Padding(
                  padding: EdgeInsets.all(20),
                  child: TtcPartnerDayExample()))));
      await tester.pump();
      expect(tester.takeException(), isNull);
      // The mission is read from the real list, not retyped.
      expect(find.text('Laptop off your lap'), findsOneWidget);
      expect(find.text(kTtcTonightQuestions.first), findsOneWidget);
    });

    test('the picture of his day shows no day count he would never see', () {
      expect(RegExp(r'\d').hasMatch(kTtcPartnerDayToday), isFalse);
    });

    test('the pairing share text carries no emoji', () {
      final s = S(AppLanguage.english).pairingShareText('ABC123');
      final emoji = RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
          unicode: true);
      expect(emoji.hasMatch(s), isFalse, reason: s);
      expect(s, contains('ABC123'));
    });

    // ⚠️ SKIPPED UNTIL THE LEAD APPLIES IT. The pairing screen lives in
    // `lib/screens/profile/pv_partner_screen.dart`, which another helper owns
    // this round. Remove the skip in the same change that edits the lists.
    test('the pairing promise is true: private journal never, shared journal yes',
        () {
      final src =
          File('lib/screens/profile/pv_partner_screen.dart').readAsStringSync();
      expect(src, contains("'Your private journal'"));
      expect(src,
          contains("'The shared journal, only what either of you writes there'"));
    });
  });
}
