// =============================================================================
//  TTC - Journey Map, milestones, the Family Timeline and the Calendar
// -----------------------------------------------------------------------------
//  The milestone rules are the ones worth pinning: they are DERIVED rather than
//  asked for, and exactly one of them is an outcome. Both are easy to erode one
//  well-meaning addition at a time.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_calendar_screen.dart';
import 'package:parentveda/screens/ttc/ttc_journey_map_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_timeline_screen.dart';
import 'package:parentveda/services/family_timeline.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart' show TtcRitualPart;
import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_milestones.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';

Future<void> pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcJournalStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcSupplementsStore.instance.resetForTest();
    FamilyTimeline.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('milestones reflect effort, not outcome', () {
    test('exactly one milestone is an outcome, and it is the positive test',
        () {
      final outcomes = ttcMilestones.where((m) => m.isOutcome).toList();
      expect(outcomes.length, 1);
      expect(outcomes.single.id, 'positive_test');
    });

    test('a couple who has not conceived can still reach almost all of them',
        () {
      // The point of the list: two years in, there is still plenty to see.
      final reachable = ttcMilestones.where((m) => !m.isOutcome).length;
      expect(reachable, greaterThanOrEqualTo(9));
    });

    test('every milestone is bilingual', () {
      for (final m in ttcMilestones) {
        expect(m.title(true), isNotEmpty, reason: m.id);
        expect(m.title(false), isNotEmpty, reason: m.id);
        expect(m.body(true), isNot(m.body(false)), reason: m.id);
      }
    });

    test('nothing is achieved before anything has been done', () {
      expect(const TtcMilestoneEngine().achieved, isEmpty);
    });
  });

  // ===========================================================================
  group('milestones are derived, never asked for', () {
    const engine = TtcMilestoneEngine();

    test('starting the journey', () {
      expect(engine.isAchieved('journey_started'), isFalse);
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
      expect(engine.isAchieved('journey_started'), isTrue);
    });

    test('adding a supplement', () {
      expect(engine.isAchieved('supplements_started'), isFalse);
      TtcSupplementsStore.instance.add('Folic acid');
      expect(engine.isAchieved('supplements_started'), isTrue);
    });

    test('logging a period, then completing a cycle', () {
      CycleStore.instance.logPeriodStart(DateTime(2026, 5, 1));
      expect(engine.isAchieved('first_cycle_logged'), isTrue);
      expect(engine.isAchieved('first_cycle_complete'), isFalse);
      CycleStore.instance.logPeriodStart(DateTime(2026, 5, 29));
      expect(engine.isAchieved('first_cycle_complete'), isTrue);
    });

    test('recording a body signal', () {
      CycleStore.instance.logPeriodStart(DateTime.now());
      expect(engine.isAchieved('ovulation_learned'), isFalse);
      CycleStore.instance.logLhPositive(14);
      expect(engine.isAchieved('ovulation_learned'), isTrue);
    });

    test('writing something', () {
      expect(engine.isAchieved('wrote_something'), isFalse);
      TtcJournalStore.instance.add(kind: TtcEntryKind.memory, text: 'x');
      expect(engine.isAchieved('wrote_something'), isTrue);
    });

    test('a week of the ritual', () {
      expect(engine.isAchieved('ritual_week'), isFalse);
      for (var i = 0; i < 7; i++) {
        TtcRitualStore.instance.toggle(TtcRitualPart.breath,
            on: DateTime.now().subtract(Duration(days: i)));
      }
      expect(engine.isAchieved('ritual_week'), isTrue);
    });

    test('the positive test', () {
      expect(engine.isAchieved('positive_test'), isFalse);
      TtcStore.instance.confirmPregnancy();
      expect(engine.isAchieved('positive_test'), isTrue);
    });

    test('nothing still ahead is described as missing', () {
      // Structural: `ahead` is simply the complement of `achieved`, and there
      // is no "overdue" or "missed" concept anywhere in the engine.
      TtcJournalStore.instance.add(kind: TtcEntryKind.memory, text: 'x');
      expect(engine.achieved.length + engine.ahead.length,
          ttcMilestones.length);
    });
  });

  // ===========================================================================
  group('the Family Timeline', () {
    test('is append-only and idempotent on the event id', () {
      final tl = FamilyTimeline.instance;
      for (var i = 0; i < 3; i++) {
        tl.add(
          id: 'x',
          stage: LifeStage.tryingToConceive,
          kind: TimelineKind.action,
          titleEn: 'Started folic acid',
          titleHi: 'Folic acid shuru kiya',
        );
      }
      expect(tl.count, 1);
    });

    test('reads oldest first - the order a life is lived in', () {
      final tl = FamilyTimeline.instance;
      tl.add(
          id: 'b',
          stage: LifeStage.pregnancy,
          kind: TimelineKind.milestone,
          titleEn: 'Week 12',
          titleHi: 'Hafta 12',
          on: DateTime(2027, 3, 1));
      tl.add(
          id: 'a',
          stage: LifeStage.tryingToConceive,
          kind: TimelineKind.milestone,
          titleEn: 'We decided',
          titleHi: 'Humne socha',
          on: DateTime(2026, 1, 1));
      expect(tl.events.first.titleEn, 'We decided');
      expect(tl.recent.first.titleEn, 'Week 12');
    });

    test('holds every stage in one log, not one log per stage', () {
      final tl = FamilyTimeline.instance;
      for (final stage in LifeStage.values) {
        tl.add(
            id: stage.id,
            stage: stage,
            kind: TimelineKind.milestone,
            titleEn: stage.id,
            titleHi: stage.id);
      }
      expect(tl.count, LifeStage.values.length);
      for (final stage in LifeStage.values) {
        expect(tl.forStage(stage).length, 1, reason: stage.id);
      }
    });

    test('an event round-trips through encoding', () {
      final tl = FamilyTimeline.instance;
      tl.add(
          id: 'x',
          stage: LifeStage.parenting,
          kind: TimelineKind.written,
          titleEn: 'First word',
          titleHi: 'Pehla shabd',
          detailEn: 'She said "maa"');
      final e = tl.events.single;
      final back = TimelineEvent.fromJson(e.toJson());
      expect(back!.titleEn, e.titleEn);
      expect(back.stage, LifeStage.parenting);
      expect(back.kind, TimelineKind.written);
      expect(back.detail(false), 'She said "maa"');
    });

    test('a corrupt row is dropped rather than taking the story down', () {
      expect(TimelineEvent.fromJson('nonsense'), isNull);
      expect(TimelineEvent.fromJson({'id': 1}), isNull);
    });

    test('reaching milestones writes them into the story', () {
      TtcSupplementsStore.instance.add('Folic acid');
      TtcJournalStore.instance.add(kind: TtcEntryKind.memory, text: 'x');
      const TtcMilestoneEngine().syncToTimeline();
      expect(FamilyTimeline.instance.has('ttc_ms_supplements_started'), isTrue);
      expect(FamilyTimeline.instance.has('ttc_ms_wrote_something'), isTrue);
    });

    test('syncing repeatedly does not duplicate the story', () {
      TtcSupplementsStore.instance.add('Folic acid');
      const engine = TtcMilestoneEngine();
      engine.syncToTimeline();
      final n = FamilyTimeline.instance.count;
      engine.syncToTimeline();
      engine.syncToTimeline();
      expect(FamilyTimeline.instance.count, n);
    });
  });

  // ===========================================================================
  group('the Journey Map', () {
    testWidgets('builds and shows all five chapters', (tester) async {
      await pumpTall(tester, const TtcJourneyMapScreen());
      for (final c in TtcChapter.values) {
        expect(find.text(c.title(false)), findsWidgets, reason: '$c');
      }
    });

    testWidgets('marks the current chapter', (tester) async {
      await pumpTall(tester, const TtcJourneyMapScreen());
      expect(find.text(const TtcS(false).chapterYouAreHere), findsOneWidget);
    });

    testWidgets('an achieved milestone appears under "what you have done"',
        (tester) async {
      TtcSupplementsStore.instance.add('Folic acid');
      await pumpTall(tester, const TtcJourneyMapScreen());
      expect(find.text('Started your supplements'), findsOneWidget);
    });

    testWidgets('opening the map writes achieved milestones to the timeline',
        (tester) async {
      TtcSupplementsStore.instance.add('Folic acid');
      expect(FamilyTimeline.instance.count, 0);
      await pumpTall(tester, const TtcJourneyMapScreen());
      expect(FamilyTimeline.instance.count, greaterThan(0));
    });
  });

  // ===========================================================================
  group('the Family Timeline screen', () {
    testWidgets('invites rather than showing a blank page', (tester) async {
      await pumpTall(tester, const TtcTimelineScreen());
      expect(find.text(const TtcS(false).timelineEmptyTitle), findsOneWidget);
    });

    testWidgets('groups by year, not by stage', (tester) async {
      final tl = FamilyTimeline.instance;
      tl.add(
          id: 'a',
          stage: LifeStage.tryingToConceive,
          kind: TimelineKind.milestone,
          titleEn: 'We decided',
          titleHi: 'Humne socha',
          on: DateTime(2026, 1, 1));
      tl.add(
          id: 'b',
          stage: LifeStage.pregnancy,
          kind: TimelineKind.milestone,
          titleEn: 'Week 12',
          titleHi: 'Hafta 12',
          on: DateTime(2027, 3, 1));
      await pumpTall(tester, const TtcTimelineScreen());
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('2027'), findsOneWidget);
      // Both stages present in one continuous list.
      expect(find.text('We decided'), findsOneWidget);
      expect(find.text('Week 12'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the Calendar', () {
    testWidgets('builds with no data at all', (tester) async {
      await pumpTall(tester, const TtcCalendarScreen());
      expect(tester.takeException(), isNull);
      // "Today" is both the nav tab and the selected-day panel's heading.
      expect(find.text(const TtcS(false).calendarToday), findsWidgets);
      expect(find.text(const TtcS(false).calendarNothing), findsOneWidget);
    });

    test('a period start is recognised on its day', () {
      final d = DateTime(2026, 7, 1);
      CycleStore.instance.logPeriodStart(d);
      expect(ttcFactsFor(d).isPeriodStart, isTrue);
      expect(ttcFactsFor(d.add(const Duration(days: 1))).isPeriodStart, isFalse);
    });

    test('the fertile window on the calendar matches the engine', () {
      // 28-day cycles → ovulation day 14, window 9-15.
      CycleStore.instance
        ..logPeriodStart(DateTime(2026, 5, 1))
        ..logPeriodStart(DateTime(2026, 5, 29))
        ..logPeriodStart(DateTime(2026, 6, 26));
      final start = DateTime(2026, 6, 26);
      expect(ttcFactsFor(start.add(const Duration(days: 13))).isOvulation, isTrue);
      expect(ttcFactsFor(start.add(const Duration(days: 12))).fertility,
          FertilityLevel.peak);
      expect(ttcFactsFor(start.add(const Duration(days: 2))).fertility,
          FertilityLevel.low);
    });

    test('the expected next period is projected only from the current cycle',
        () {
      CycleStore.instance
        ..logPeriodStart(DateTime(2026, 5, 1))
        ..logPeriodStart(DateTime(2026, 5, 29));
      // 28-day cycle from the LAST start → expected on day 29 of that cycle.
      expect(ttcFactsFor(DateTime(2026, 6, 26)).isExpectedPeriod, isTrue);
      // Never projected from an older cycle that has already ended.
      expect(ttcFactsFor(DateTime(2026, 5, 29)).isExpectedPeriod, isFalse);
    });

    test('a logged tracker and a journal entry both surface on their day', () {
      final d = DateTime(2026, 7, 10);
      TtcLogStore.instance.log('mood', 'mood', 3, on: d);
      TtcJournalStore.instance
          .add(kind: TtcEntryKind.memory, text: 'a good day', on: d);
      final facts = ttcFactsFor(d);
      expect(facts.loggedTrackers, contains('mood'));
      expect(facts.journalEntries.length, 1);
      expect(facts.hasAnything, isTrue);
    });

    test('an empty day is honestly empty', () {
      expect(ttcFactsFor(DateTime(2026, 2, 3)).hasAnything, isFalse);
    });
  });
}
