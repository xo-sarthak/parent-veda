// =============================================================================
//  P5, Pregnancy daily check-ins (2026-10-28)
// -----------------------------------------------------------------------------
//  docs/preg-ttc-tool-plans/P5-daily-checkins.md. What this pins:
//
//    · M1  the mood log loads through the tab, and an early write is held
//          and replayed, never saved over what was on the phone;
//    · D2  the mood log syncs: a round trip with a soft delete and Undo;
//    · D3  0125 is owner-only, and every column the app sends exists;
//    · G1  any answer but "Not at all" to the safety question reaches the
//          crisis path;
//    · S1  the when-to-call lines and the one fixed rule (from 20 weeks);
//    · S2  "What to say when you call" shows her week and her movements;
//    · D1  the Tools "Check in" group, and every new path is wired;
//    · D5  after a loss, no baby and no week in the four tools.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/mind_mood_data.dart';
import 'package:parentveda/data/symptoms/symptom_call_rules.dart';
import 'package:parentveda/data/symptoms/symptom_library.dart';
import 'package:parentveda/screens/mind_mood/mm_crisis_path.dart';
import 'package:parentveda/screens/mind_mood/mm_talk_tab.dart';
import 'package:parentveda/screens/mind_mood/mm_track_tab.dart';
import 'package:parentveda/screens/symptoms/door/symptoms_screens.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';

String _src(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(1200, 9000);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: Scaffold(body: w)));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    MindMoodStore.instance.resetForTest();
  });

  // ===========================================================================
  //  M1 · the mood log loads, and never writes before it has read
  // ===========================================================================

  group('M1: the mood log never loses what the phone held', () {
    final saved = {
      'mm_mood_entries': jsonEncode([
        {'d': '2026-10-01', 'm': 'heavy', 't': 1},
        {'d': '2026-10-02', 'm': 'light', 't': 2},
      ]),
      'mm_journal_entries': jsonEncode([
        {'id': '111', 't': 3, 'x': 'the scan on Tuesday'},
      ]),
    };

    test('a mood logged before the read is replayed on top of it', () async {
      SharedPreferences.setMockInitialValues(saved);
      final store = MindMoodStore.instance;
      // The bug: the first tap saved an empty list over the key.
      store.logMood('bright');
      await store.init();
      expect(store.moodHistory().length, 3);
      expect(store.todayMoodId, 'bright');
      expect(store.journalEntries.single.text, 'the scan on Tuesday');
      final prefs = await SharedPreferences.getInstance();
      final onDisk = jsonDecode(prefs.getString('mm_mood_entries')!) as List;
      expect(onDisk.length, 3, reason: 'the save kept the two earlier days');
    });

    testWidgets('the tab loads its own store (the door draws it directly)',
        (t) async {
      SharedPreferences.setMockInitialValues(saved);
      await _pump(t, const MmTrackTab(embedded: true));
      await t.pumpAndSettle();
      expect(find.text('the scan on Tuesday'), findsOneWidget);
    });

    test('the tab calls init, in source', () {
      expect(_src('lib/screens/mind_mood/mm_track_tab.dart'),
          contains('_store.init();'));
    });
  });

  // ===========================================================================
  //  D2 · it syncs: newer wins, a delete travels, Undo wins it back
  // ===========================================================================

  group('D2: the mood log and journal sync', () {
    test('a mood is one row per day, the same id on every phone', () async {
      final store = MindMoodStore.instance;
      await store.init();
      store.logMood('steady');
      store.logMood('tender'); // same day: the same row, changed
      final up = store.pendingUploadsForTest();
      final moods = up.keys.where((k) => k.startsWith('mood_')).toList();
      expect(moods.length, 1);
      expect(up[moods.single]!['mood_id'], 'tender');
      expect(up[moods.single]!['kind'], 'mood');
    });

    test('a delete is a soft delete that uploads, and Undo puts it back',
        () async {
      final store = MindMoodStore.instance;
      await store.init();
      store.addJournalEntry('worried');
      final e = store.journalEntries.single;
      final gone = store.deleteJournalEntry(e.id);
      expect(gone, isNotNull);
      expect(store.journalEntries, isEmpty);
      expect(store.pendingUploadsForTest()[e.id]!['removed_at'], isNotNull);

      store.restoreJournalEntry(gone!);
      expect(store.journalEntries.single.text, 'worried');
      expect(store.pendingUploadsForTest()[e.id]!['removed_at'], isNull);
      expect(store.journalEntries.single.ts, e.ts, reason: 'same date back');
    });

    test('a newer removal from another phone removes it here', () async {
      final store = MindMoodStore.instance;
      await store.init();
      store.addJournalEntry('old thought');
      final e = store.journalEntries.single;
      final later = DateTime.now().toUtc().add(const Duration(minutes: 5));
      store.applyCloudRowsForTest([
        {
          ...MindMoodStore.journalToRow(e),
          'user_id': 'me',
          'updated_at': later.toIso8601String(),
          'removed_at': later.toIso8601String(),
        },
      ]);
      expect(store.journalEntries, isEmpty);
    });

    test('a row only the cloud has arrives on a new phone', () async {
      final store = MindMoodStore.instance;
      await store.init();
      store.applyCloudRowsForTest([
        {
          'id': 'mood_2026-10-20',
          'kind': 'mood',
          'date_key': '2026-10-20',
          'mood_id': 'light',
          'created_at_iso': '2026-10-20T09:00:00.000',
          'user_id': 'me',
          'updated_at': '2026-10-20T09:00:00.000Z',
          'removed_at': null,
        },
        {
          'id': '222',
          'kind': 'journal',
          'body': 'written on the old phone',
          'prompt_id': 'p1',
          'created_at_iso': '2026-10-19T21:00:00.000',
          'user_id': 'me',
          'updated_at': '2026-10-19T21:00:00.000Z',
          'removed_at': null,
        },
      ]);
      expect(store.moodHistory().single.moodId, 'light');
      expect(store.journalEntries.single.text, 'written on the old phone');
      expect(store.journalEntries.single.promptId, 'p1');
    });

    test('what the phone held before this build uploads on first sync',
        () async {
      SharedPreferences.setMockInitialValues({
        'mm_journal_entries': jsonEncode([
          {'id': '333', 't': 5, 'x': 'from before'},
        ]),
      });
      final store = MindMoodStore.instance;
      await store.init();
      // The cloud has nothing yet: the merge marks the local row to push.
      store.applyCloudRowsForTest(const []);
      expect(store.pendingUploadsForTest().keys, contains('333'));
    });
  });

  // ===========================================================================
  //  D3 · 0125: owner-only, and the columns agree
  // ===========================================================================

  group('D3: mind_mood_entries is owner-only and matches the client', () {
    final sql = _src('supabase/migrations/0125_mind_mood_entries.sql');
    final body = sql.substring(
        sql.indexOf('create table if not exists public.mind_mood_entries'),
        sql.indexOf('\n);', sql.indexOf('create table if not exists')));

    test('every column the app sends exists', () {
      final cols = <String>{
        ...MindMoodStore.moodToRow(
                const MmMoodEntry(dateKey: '2026-10-28', moodId: 'x', ts: 0))
            .keys,
        ...MindMoodStore.journalToRow(
                const MmJournalEntry(id: '1', ts: 0, text: 'x'))
            .keys,
        'user_id',
        'updated_at',
        'removed_at',
      };
      for (final c in cols) {
        expect(RegExp('^\\s*$c\\s', multiLine: true).hasMatch(body), isTrue,
            reason: '$c is sent but 0125 has no such column');
      }
    });

    test('keyed per person, and all four policies are own-row only', () {
      expect(body, contains('primary key (user_id, id)'));
      final policies = RegExp(r'create policy "mind_mood_entries own \w+"[^;]*;')
          .allMatches(sql)
          .map((m) => m.group(0)!)
          .toList();
      expect(policies.length, 4);
      for (final p in policies) {
        expect(p, contains('auth.uid() = user_id'));
        expect(p.toLowerCase(), isNot(contains('partner')));
        expect(p.toLowerCase(), isNot(contains('family')));
        expect(p.toLowerCase(), isNot(contains('security definer')));
      }
    });

    test('the table the store writes is the table 0125 makes', () {
      expect(MindMoodStore.kTable, 'mind_mood_entries');
    });
  });

  // ===========================================================================
  //  G1 · the safety question
  // ===========================================================================

  group('G1: any non-zero answer reaches the crisis path', () {
    final safety = kMmScreenerQuestions.firstWhere((q) => q.isSafetyQuestion);

    test('the rule, option by option', () {
      for (final o in safety.options) {
        expect(mmScreenerOpensCrisis(safety, o), o.severity >= 1,
            reason: o.label.en);
      }
      final other = kMmScreenerQuestions.firstWhere((q) => !q.isSafetyQuestion);
      for (final o in other.options) {
        expect(mmScreenerOpensCrisis(other, o), isFalse);
      }
    });

    for (final answer in ['A fleeting thought', 'Yes, more than once',
        'Yes, and it frightens me']) {
      testWidgets('"$answer" opens the crisis path', (t) async {
        await _pump(t, const MmScreenerScreen());
        for (var i = 0; i < kMmScreenerQuestions.length - 1; i++) {
          await t.tap(find.text(kMmScreenerQuestions[i].options.first.label.en));
          await t.pumpAndSettle();
        }
        await t.tap(find.text(answer));
        await t.pumpAndSettle();
        expect(find.byType(MmCrisisPathScreen), findsOneWidget);
      });
    }

    testWidgets('"Not at all" ends on her result, no crisis path', (t) async {
      await _pump(t, const MmScreenerScreen());
      for (var i = 0; i < kMmScreenerQuestions.length; i++) {
        await t.tap(find.text(kMmScreenerQuestions[i].options.first.label.en));
        await t.pumpAndSettle();
      }
      expect(find.byType(MmCrisisPathScreen), findsNothing);
    });

    test('the top tier names the doctor and the helpline', () {
      expect(mmScreenerGuidance(kMmScreenerMiddleTierMax + 1).en,
          contains('doctor'));
      final talk = _src('lib/screens/mind_mood/mm_talk_tab.dart');
      expect(talk, contains('kMmScreenerTellDoctor'));
      expect(talk, contains("ValueKey('mm_screener_helpline')"));
    });

    test('G2: no tab that no longer exists is named', () {
      for (final total in [0, 5, 12]) {
        for (final afterLoss in [false, true]) {
          expect(mmScreenerGuidance(total, afterLoss: afterLoss).en,
              isNot(contains('Feel tab')));
        }
      }
    });
  });

  // ===========================================================================
  //  S1 · when to call
  // ===========================================================================

  group('S1: the when-to-call lines and the one rule', () {
    test('headache with blurred vision or swelling, from 20 weeks only', () {
      expect(symptomTogetherRule(['headache', 'blurryVision'], week: 20), isTrue);
      expect(symptomTogetherRule(['headache', 'swelling'], week: 32), isTrue);
      expect(symptomTogetherRule(['headache', 'blurryVision'], week: 19), isFalse);
      expect(symptomTogetherRule(['headache'], week: 30), isFalse);
      expect(symptomTogetherRule(['blurryVision', 'swelling'], week: 30), isFalse);
    });

    test('each call-condition symptom gets its line, from a real symptom', () {
      for (final id in ['blurryVision', 'itching', 'redPalms', 'swelling',
          'spotting', 'cramps']) {
        expect(symptomById(id), isNotNull, reason: id);
        expect(symptomCallLine(id, week: 10), isNotNull, reason: id);
      }
      expect(symptomById('headache'), isNotNull);
      expect(symptomCallLine('headache', week: 19), isNull);
      expect(symptomCallLine('headache', week: 20), isNotNull);
      expect(symptomCallLine('nausea', week: 30), isNull,
          reason: 'a symptom with no call condition keeps its tip');
    });

    test('the rule is shown, and the rows read the lines', () {
      final body = _src('lib/screens/symptoms/door/symptoms_today_body.dart');
      expect(body, contains('symptomTogetherRule('));
      expect(body, contains('SymptomTogetherCard('));
      expect(body, contains('callLine: symptomCallLine(s.id, week: week)'));
    });

    test('never a probability', () {
      final rules = _src('lib/data/symptoms/symptom_call_rules.dart');
      for (final w in ['%', 'chance', 'likely', 'risk score']) {
        expect(rules.contains(RegExp('[\'"][^\'"]*$w')), isFalse, reason: w);
      }
    });
  });

  // ===========================================================================
  //  S2 · What to say when you call
  // ===========================================================================

  group('S2: her own facts on the calling screen', () {
    setUp(() => PregnancyEndedStore.instance.resetForTest());

    test('line 1 is her week and due date', () async {
      final c = PregnancyController();
      await c.setDueDate(DateTime.now().add(const Duration(days: 16 * 7)));
      expect(SymptomsCallingScreen.weeksLine(c), startsWith("You're 24 weeks"));
    });

    test('a clinic-owned date is shown as theirs', () async {
      final c = PregnancyController();
      await c.setDueDate(DateTime.now().add(const Duration(days: 16 * 7)),
          source: DueDateSource.scan);
      expect(SymptomsCallingScreen.weeksLine(c), contains('your clinic gave'));
    });

    test('line 4 from 24 weeks, as her observation, never "normal"', () async {
      final c = PregnancyController();
      await c.setDueDate(DateTime.now().add(const Duration(days: 14 * 7)));
      final line = SymptomsCallingScreen.movementLine(
          c, (count: 7, last: DateTime(2026, 10, 28, 15, 40)))!;
      expect(line, 'Today you logged 7 movements, the last at 3:40 pm.');
      expect(line.toLowerCase(), isNot(contains('normal')));

      final early = PregnancyController();
      await early.setDueDate(DateTime.now().add(const Duration(days: 20 * 7)));
      expect(
          SymptomsCallingScreen.movementLine(
              early, (count: 3, last: DateTime(2026, 10, 28, 9))),
          isNull);
    });

    test('after a loss neither line shows', () async {
      final c = PregnancyController();
      await c.setDueDate(DateTime.now().add(const Duration(days: 10 * 7)));
      await PregnancyEndedStore.instance.markEnded();
      expect(SymptomsCallingScreen.weeksLine(c), isNull);
      expect(
          SymptomsCallingScreen.movementLine(
              c, (count: 3, last: DateTime(2026, 10, 28, 9))),
          isNull);
    });
  });

  // ===========================================================================
  //  D1 · Tools, and the wiring gate
  // ===========================================================================

  group('D1 and the wiring gate', () {
    test('Tools has a Check in group with the three rows', () {
      final hub = _src('lib/screens/tools_hub_screen.dart');
      expect(hub, contains("const String kPregCheckInGroup = 'Check in';"));
      expect(hub, contains('_ToolGroup(kPregCheckInGroup'));
      for (final row in ["'Symptoms today'", "'Mood check-in'",
          "'Your plate today'"]) {
        expect(hub, contains(row));
      }
      expect(hub, contains('pvDoorScreenFor(kMindSurfaceTrack, controller)'));
      expect(hub, contains('pvDoorScreenFor(kDietSurfaceToday, controller)'));
    });

    test('Mood check-in opens the gentle check-in', () {
      final track = _src('lib/screens/mind_mood/mm_track_tab.dart');
      expect(track, contains('builder: (_) => const MmScreenerScreen()'));
      expect(track, contains('onTap: _openCheckIn'));
    });

    test('the Symptoms grid points Mood swings to Mood check-in', () {
      final body = _src('lib/screens/symptoms/door/symptoms_today_body.dart');
      expect(body,
          contains('openPvDoorSurface(context, kMindSurfaceTrack, c)'));
    });

    test('S3: the Calendar opens the Symptoms door, not the old companion', () {
      final cal = _src('lib/screens/pregnancy/calendar/preg_cal_sheets.dart');
      expect(cal, contains('openPvDoorPage(context, kSymptomsBracketId, p)'));
      expect(
          RegExp(r'^\s*context, .calendar/symptoms., \(_\) => SymptomCompanionScreen',
                  multiLine: true)
              .hasMatch(cal),
          isFalse);
    });

    test('S4: the week grid draws every row', () {
      final week = _src('lib/screens/symptoms/door/symptoms_week_body.dart');
      expect(week, contains('final shown = rows;'));
    });

    test('S6, M3, N1: each tap says what it did', () {
      expect(_src('lib/screens/symptoms/door/symptoms_today_body.dart'),
          contains('logged. What helps is below.'));
      expect(_src('lib/screens/mind_mood/mm_track_tab.dart'),
          contains("action: 'Undo'"));
      expect(kMmMoodSavedToast, 'Saved for today. Only you can see this.');
      expect(_src('lib/screens/nutrition/door/nutrition_today_body.dart'),
          contains('"Logged. Here\'s what helps."'));
    });
  });

  // ===========================================================================
  //  D5 · after a loss
  // ===========================================================================

  group('D5: after a loss, no baby and no week', () {
    test('the safety question drops "your baby"', () {
      final q = mmScreenerQuestions(afterLoss: true)
          .firstWhere((q) => q.isSafetyQuestion);
      expect(q.prompt.en.toLowerCase(), isNot(contains('baby')));
      expect(q.options, kMmScreenerQuestions.last.options,
          reason: 'same answers, same routing');
    });

    test('the guidance drops "pregnancy"', () {
      for (final total in [0, 5, 12]) {
        expect(mmScreenerGuidance(total, afterLoss: true).en.toLowerCase(),
            isNot(contains('pregnancy')));
      }
    });

    test('the four tools carry the after-loss branch', () {
      expect(_src('lib/screens/symptoms/door/symptoms_today_body.dart'),
          contains("'COMMON ONES'"));
      expect(_src('lib/screens/symptoms/door/symptoms_today_body.dart'),
          contains('PregAfterLossNote(kAfterLossSymptoms)'));
      expect(_src('lib/screens/symptoms/door/symptoms_week_body.dart'),
          contains('PregnancyEndedStore.instance.ended'));
      expect(_src('lib/screens/mind_mood/mm_track_tab.dart'),
          contains('PregAfterLossNote(kAfterLossMood)'));
      final plate = _src('lib/screens/nutrition/door/nutrition_today_body.dart');
      expect(plate, contains('PregAfterLossNote(kAfterLossPlate)'));
      expect(plate, contains('"All five today. That\'s a good day."'));
    });
  });
}
