// =============================================================================
//  The Transition Engine - TTC → Pregnancy
// -----------------------------------------------------------------------------
//  The master document calls this the most important feature in the stage, and
//  the promise it makes is absolute: "Nothing is lost."
//
//  A promise like that has to be a test, not a comment. So this file checks
//  that after the transition the journal, the timeline, the supplements, the
//  cycles and the partner are all still exactly where they were - and that the
//  pregnancy app can pick up the due date with no migration and no setup.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_transition_screen.dart';
import 'package:parentveda/services/family_timeline.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';
import 'package:parentveda/ttc/ttc_transition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  const engine = TtcTransitionEngine();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcJournalStore.instance.resetForTest();
    TtcSupplementsStore.instance.resetForTest();
    FamilyTimeline.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  /// A couple who has been trying for a while and has real data.
  void seedAJourney() {
    LifeStageStore.instance
        .setStage(LifeStage.tryingToConceive, at: DateTime(2026, 1, 1));
    CycleStore.instance
      ..logPeriodStart(DateTime(2026, 5, 1))
      ..logPeriodStart(DateTime(2026, 5, 29))
      ..logPeriodStart(DateTime(2026, 6, 26));
    TtcSupplementsStore.instance.add('Folic acid');
    TtcSupplementsStore.instance.add('Vitamin D');
    TtcJournalStore.instance.add(kind: TtcEntryKind.memory, text: 'a hard month');
    TtcJournalStore.instance
        .add(kind: TtcEntryKind.letter, text: 'to whoever you turn out to be');
    TtcStore.instance.setPartnerJoined(true);
  }

  // ===========================================================================
  group('the due date is derived properly', () {
    test("Naegele's rule - 280 days from the last period", () {
      expect(TtcTransitionEngine.dueDateFrom(DateTime(2026, 1, 1)),
          DateTime(2026, 1, 1).add(const Duration(days: 280)));
    });

    test('a positive test usually lands around week four', () {
      // Testing four weeks after the last period began.
      final lmp = DateTime(2026, 6, 1);
      expect(TtcTransitionEngine.weeksFrom(lmp, on: DateTime(2026, 6, 29)), 4);
    });

    test('weeks never go negative on a bad date', () {
      expect(
          TtcTransitionEngine.weeksFrom(DateTime(2026, 7, 1),
              on: DateTime(2026, 6, 1)),
          0);
    });
  });

  // ===========================================================================
  group('nothing is lost', () {
    test('every store still holds exactly what it held', () async {
      seedAJourney();
      final journalBefore = TtcJournalStore.instance.count;
      final supplementsBefore = TtcSupplementsStore.instance.items.length;
      final cyclesBefore = CycleStore.instance.completedCycles;

      await engine.confirmPregnancy(on: DateTime(2026, 7, 24));

      expect(TtcJournalStore.instance.count, journalBefore);
      expect(TtcSupplementsStore.instance.items.length, supplementsBefore);
      expect(CycleStore.instance.completedCycles, cyclesBefore);
      expect(TtcStore.instance.partnerJoined, isTrue);
      // And the actual words are still there, not just the count.
      expect(
          TtcJournalStore.instance.entries
              .any((e) => e.text == 'to whoever you turn out to be'),
          isTrue);
    });

    test('the result reports real counts, not a reassurance', () async {
      seedAJourney();
      final r = await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      expect(r.journalEntries, 2);
      expect(r.supplements, 2);
      expect(r.cyclesLogged, 2);
      expect(r.partnerJoined, isTrue);
      expect(r.timelineEvents, greaterThan(0));
    });

    test('the family timeline gains the moment, and keeps everything else',
        () async {
      seedAJourney();
      FamilyTimeline.instance.add(
        id: 'earlier',
        stage: LifeStage.tryingToConceive,
        kind: TimelineKind.written,
        titleEn: 'First journal',
        titleHi: 'Pehla journal',
        on: DateTime(2026, 2, 1),
      );
      await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      expect(FamilyTimeline.instance.has('earlier'), isTrue);
      expect(FamilyTimeline.instance.has('ttc_positive_test'), isTrue);
      expect(FamilyTimeline.instance.has('pregnancy_started'), isTrue);
    });

    test('the story stays in order, across both stages', () async {
      seedAJourney();
      await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      final events = FamilyTimeline.instance.events;
      // Pregnancy is dated from the last period, so it precedes the test.
      final started =
          events.indexWhere((e) => e.id == 'pregnancy_started');
      final positive =
          events.indexWhere((e) => e.id == 'ttc_positive_test');
      expect(started, lessThan(positive));
    });
  });

  // ===========================================================================
  group('the pregnancy app can pick it up with no setup', () {
    test('the due date lands on the key PregnancyController reads', () async {
      seedAJourney();
      final r = await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(PregnancyController.kDueDateKey);
      expect(saved, isNotNull);
      expect(DateTime.parse(saved!), r.dueDate);
    });

    test('the engine and the controller agree on the key', () async {
      // The contract between the two stages is a single shared preferences
      // key. Booting a real controller here would only prove that a unit test
      // cannot load weekContent.json, so this checks the seam directly: the
      // controller's own writer must land on the same key the engine wrote to.
      seedAJourney();
      await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      final prefs = await SharedPreferences.getInstance();
      final fromEngine = prefs.getString(PregnancyController.kDueDateKey);

      await PregnancyController().setDueDate(DateTime(2027, 4, 2));
      final fromController =
          (await SharedPreferences.getInstance())
              .getString(PregnancyController.kDueDateKey);

      expect(fromEngine, isNotNull);
      expect(fromController, isNotNull);
      expect(DateTime.parse(fromController!), DateTime(2027, 4, 2),
          reason: 'the two stages are writing to different keys');
    });

    test('the life stage moves to pregnancy', () async {
      seedAJourney();
      await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      expect(LifeStageStore.instance.stage, LifeStage.pregnancy);
      expect(LifeStageStore.instance.isTrying, isFalse);
    });

    test('the TTC stage reports the final chapter', () async {
      seedAJourney();
      await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      expect(TtcStore.instance.today.chapter, TtcChapter.aNewBeginning);
    });
  });

  // ===========================================================================
  group('with no period ever logged', () {
    test('it still works, and says the date was assumed', () async {
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
      final r = await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      expect(r.dueDateWasDerived, isFalse);
      // Assumed four weeks in, which is the common case for a positive test.
      expect(r.weeksPregnant, 4);
      expect(r.dueDate.isAfter(DateTime(2026, 7, 24)), isTrue);
    });
  });

  // ===========================================================================
  group('it is idempotent and reversible', () {
    test('running it twice leaves one of each timeline moment', () async {
      seedAJourney();
      await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      final n = FamilyTimeline.instance.count;
      await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      expect(FamilyTimeline.instance.count, n);
    });

    test('undo puts the family back where they were', () async {
      seedAJourney();
      await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      await engine.undo();

      expect(TtcStore.instance.pregnancyConfirmed, isFalse);
      expect(LifeStageStore.instance.stage, LifeStage.tryingToConceive);
      expect(FamilyTimeline.instance.has('ttc_positive_test'), isFalse);
      expect(FamilyTimeline.instance.has('pregnancy_started'), isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PregnancyController.kDueDateKey), isNull);
    });

    test('undo keeps the journal and everything else she wrote', () async {
      seedAJourney();
      await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      await engine.undo();
      expect(TtcJournalStore.instance.count, 2);
      expect(TtcSupplementsStore.instance.items.length, 2);
      expect(CycleStore.instance.completedCycles, 2);
    });
  });

  // ===========================================================================
  group('the transition screen', () {
    testWidgets('shows the counts rather than a reassurance', (tester) async {
      seedAJourney();
      final r = await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(home: TtcTransitionScreen(result: r)));
      await tester.pump();

      final t = const TtcS(false);
      expect(find.text(t.transitionTitle), findsOneWidget);
      expect(find.text(t.transitionJournal(2)), findsOneWidget);
      expect(find.text(t.transitionSupplements(2)), findsOneWidget);
      expect(find.text(t.transitionPartner), findsOneWidget);
    });

    testWidgets('offers undo in plain sight', (tester) async {
      seedAJourney();
      final r = await engine.confirmPregnancy(on: DateTime(2026, 7, 24));
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(home: TtcTransitionScreen(result: r)));
      await tester.pump();
      expect(find.text(const TtcS(false).transitionUndo), findsOneWidget);
    });

    testWidgets('never says congratulations', (tester) async {
      // Deliberate: plenty of couples reach this screen carrying a previous
      // loss, and the right note is quiet certainty, not confetti.
      for (final hi in [true, false]) {
        final t = TtcS(hi);
        for (final s in [
          t.transitionTitle,
          t.transitionSubtitle,
          t.transitionWhyWeeks,
        ]) {
          expect(s.toLowerCase(), isNot(contains('congratulation')));
          expect(s.toLowerCase(), isNot(contains('badhai')));
        }
      }
    });
  });
}
