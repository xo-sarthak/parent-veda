// =============================================================================
//  "Add a pregnancy" from the family (STAGE-TRANSITIONS F2, 2026-10-25)
// -----------------------------------------------------------------------------
//  A mother in Parenting is expecting again. The stage moves to pregnancy and
//  her child stays a profile of its own; the last pregnancy is sealed with its
//  bag and birth plan; the letters do not read as already opened; and "the
//  test was wrong" goes back to her child, dated as before, not to trying.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/v2/pv_add_pregnancy.dart';
import 'package:parentveda/screens/v2/pv_family_switch.dart';
import 'package:parentveda/services/dear_baby_vault_store.dart';
import 'package:parentveda/services/family_timeline.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/preg_messages_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/services/pregnancy_records.dart';
import 'package:parentveda/services/stage_moves.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_transition.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController ctrl;
  final today = _day(DateTime.now());
  final dob = today.subtract(const Duration(days: 200));
  final firstDue = dob.add(const Duration(days: 5));
  late Child meera;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LifeStageStore.instance.resetForTest();
    PregnancyEndedStore.instance.resetForTest();
    await PregnancyEndedStore.instance.load();
    TtcStore.instance.resetForTest();
    FamilyTimeline.instance.resetForTest();
    ChildProfileStore.instance.resetForTest();
    DearBabyVaultStore.instance.resetForTest();
    ctrl = PregnancyController(now: DateTime.now());
    PregnancyController.current = ctrl;

    // Her first pregnancy, dated by a scan, ended in Meera's birth.
    LifeStageStore.instance
        .setStage(LifeStage.pregnancy, at: dob.subtract(const Duration(days: 250)));
    await ctrl.setDueDate(firstDue, source: DueDateSource.scan);
    PregnancyRecords.instance.debugReset(rows: [
      PregnancyRecord(
          id: PregnancyRecord.idFor(firstDue.subtract(const Duration(days: 280))),
          startedOn: firstDue.subtract(const Duration(days: 280)),
          dueDate: firstDue,
          dueDateSource: DueDateSource.scan.name),
    ]);
    meera = await ChildProfileStore.instance
        .addChild(name: 'Meera', isBoy: false, dob: dob);
    await recordBirth(dob: dob, name: meera.name, childId: meera.id);
  });
  tearDown(() {
    PregnancyController.current = null;
    PregnancyRecords.instance.debugReset();
  });

  Future<PregnancyRecord?> add({int weeksAlong = 8}) => startPregnancyFromFamily(
        due: today.add(Duration(days: 280 - weeksAlong * 7)),
        source: DueDateSource.lastPeriod,
        today: today,
      );

  group('F2 · the move', () {
    test('the stage moves to pregnancy today; Meera stays her own profile', () async {
      expect(LifeStageStore.instance.stage, LifeStage.parenting);
      final made = await add();
      expect(LifeStageStore.instance.stage, LifeStage.pregnancy);
      expect(LifeStageStore.instance.enteredAt, today,
          reason: 'a fresh enteredAt is what makes an old loss and old messages not count');
      expect(made, isNotNull);
      expect(made!.outcome, PregnancyOutcome.ongoing);
      expect(PregnancyRecords.instance.current?.id, made.id);

      final profiles = familyProfiles();
      expect(profiles.map((p) => p.id), ['pregnancy', meera.id]);
      expect(profiles.first.home, FamilyHome.pregnancy);
      expect(profiles.last.home, FamilyHome.parenting);
    });

    test('the last pregnancy is sealed as a birth, and the new one starts after it', () async {
      final made = await add();
      final prev = PregnancyRecords.instance.all.firstWhere((r) => r.id != made!.id);
      expect(prev.outcome, PregnancyOutcome.birth);
      expect(prev.endedOn, dob);
      expect(prev.childId, meera.id);
      expect(made!.startedOn.isAfter(dob), isTrue);
      expect(PregnancyRecords.instance.kept.map((r) => r.id), [prev.id],
          reason: 'her last pregnancy is under Your pregnancies');
    });

    test('the due date and its source are the new ones; the story gets its own entry', () async {
      // The first pregnancy already holds the fixed id (B3): this one is dated.
      FamilyTimeline.instance.add(
          id: 'pregnancy_started',
          stage: LifeStage.pregnancy,
          kind: TimelineKind.milestone,
          titleEn: 'Pregnancy began',
          titleHi: 'Pregnancy began',
          on: firstDue.subtract(const Duration(days: 280)));
      await add(weeksAlong: 8);
      expect(ctrl.dueDate, today.add(const Duration(days: 280 - 56)));
      expect(ctrl.dueDateSource, DueDateSource.lastPeriod);
      final dated = 'pregnancy_started:${today.toIso8601String().substring(0, 10)}';
      expect(FamilyTimeline.instance.byId(dated)?.date,
          today.add(const Duration(days: 280 - 56)).subtract(const Duration(days: 280)));
      expect(FamilyTimeline.instance.byId('pregnancy_started'), isNotNull,
          reason: "the first pregnancy's entry stays");
    });

    test('pregnancy messages count from today', () async {
      await add();
      expect(PregMessageFacts.fromStores()?.pregnancyStart, today);
    });

    test('the Dear Baby letters do not read as opened during the new pregnancy', () async {
      expect(DearBabyVaultStore.instance.unlocked, isTrue, reason: 'opened at Meera\'s birth');
      await add();
      expect(DearBabyVaultStore.instance.unlocked, isFalse,
          reason: "Meera's birthday is before this pregnancy began");
      // The next birth opens them again.
      final baby = await ChildProfileStore.instance
          .addChild(name: 'Kabir', isBoy: true, dob: today);
      await recordBirth(dob: today, name: baby.name, childId: baby.id);
      expect(DearBabyVaultStore.instance.unlocked, isTrue);
    });
  });

  group('F2 · the undo', () {
    test('"The test was wrong": back to Meera, dated her birthday, the old date back', () async {
      final made = await add();
      expect(await pregnancyCameFromFamily(), isTrue);
      await undoPregnancyFromFamily();
      expect(LifeStageStore.instance.stage, LifeStage.parenting);
      expect(LifeStageStore.instance.enteredAt, dob,
          reason: "the stage dates from Meera's birthday, not the undo");
      expect(ctrl.dueDate, firstDue, reason: 'what "born early" was measured from');
      expect(ctrl.dueDateSource, DueDateSource.scan);
      expect(PregnancyRecords.instance.all.any((r) => r.id == made!.id), isFalse);
      expect(PregnancyRecords.instance.latest?.sealed, isFalse,
          reason: 'the birth pregnancy gets its bag and birth plan back');
      expect(FamilyTimeline.instance.events.where((e) => e.id.startsWith('pregnancy_started')),
          isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kPregnancyFromStageKey), isNull);
      expect(await pregnancyCameFromFamily(), isFalse);
    });

    test('without the key (another phone) it is still known to be from the family', () async {
      await add();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kPregnancyFromStageKey);
      expect(await pregnancyCameFromFamily(), isTrue,
          reason: 'she has a child and TTC did not confirm this pregnancy');
      await undoPregnancyFromFamily();
      expect(LifeStageStore.instance.stage, LifeStage.parenting);
      expect(LifeStageStore.instance.enteredAt, dob, reason: 'dated from the last birth');
    });

    test("a pregnancy TTC confirmed is TTC's, even with a child", () async {
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive, at: today);
      await const TtcTransitionEngine()
          .confirmPregnancy(on: today, dueDate: today.add(const Duration(days: 250)));
      expect(LifeStageStore.instance.stage, LifeStage.pregnancy);
      expect(await pregnancyCameFromFamily(), isFalse);
    });

    test('the birth of the added pregnancy forgets the move', () async {
      await add(weeksAlong: 39);
      final baby = await ChildProfileStore.instance
          .addChild(name: 'Kabir', isBoy: true, dob: today);
      await recordBirth(dob: today, name: baby.name, childId: baby.id);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kPregnancyFromStageKey), isNull);
    });
  });

  group('F2 · who is offered it, and what date is refused', () {
    test('offered to her in Parenting or the learning space, with no pregnancy going', () {
      bool o(LifeStage s, {bool father = false, bool ongoing = false}) =>
          addPregnancyOfferedFor(stage: s, father: father, pregnancyOngoing: ongoing);
      expect(o(LifeStage.parenting), isTrue);
      expect(o(LifeStage.skilling), isTrue);
      expect(o(LifeStage.parenting, father: true), isFalse, reason: 'he cannot date her pregnancy');
      expect(o(LifeStage.parenting, ongoing: true), isFalse);
      expect(o(LifeStage.tryingToConceive), isFalse, reason: "Trying has its own I'm pregnant");
      expect(o(LifeStage.pregnancy), isFalse);
    });

    test('a due date that passed, is too far, or starts before the birthday is refused', () {
      String? r(DateTime edd) =>
          addPregnancyRefusal(edd: edd, today: today, youngestDob: dob, youngestName: 'Meera');
      expect(r(today.add(const Duration(days: 220))), isNull);
      expect(r(today.subtract(const Duration(days: 1))), contains('passed'));
      expect(r(today.add(const Duration(days: 301))), contains('ten months'));
      expect(r(dob.add(const Duration(days: 200))), contains("Meera's birthday"));
    });

    test('the week and the page words', () {
      expect(addPregnancyWeekFor(today.add(const Duration(days: 280 - 56)), today), 8);
      final w = addPregnancyCelebrationWords(week: 8, sureOfDate: true, childNames: ['Meera']);
      expect(w.title, 'A new pregnancy');
      expect(w.changes.join(' '), contains("Meera's home stays exactly as it is"));
      final unsure = addPregnancyCelebrationWords(week: 4, sureOfDate: false, childNames: const []);
      expect(unsure.line, contains('About week 4'));
    });
  });

  group('F2 · wiring gate', () {
    test('every way in opens the one screen, and the screen makes the one move', () {
      expect(_code('lib/screens/v2/pv_family_switch.dart'), contains('openAddPregnancy(context)'));
      expect(_code('lib/screens/profile/pv_you_content.dart'), contains('open: openAddPregnancy'));
      expect(_code('lib/screens/post_pregnancy/next_baby_screens.dart'),
          contains('openAddPregnancy(context, replace: true)'));
      expect(_code('lib/screens/v2/pv_add_pregnancy.dart'), contains('startPregnancyFromFamily('));
      expect(_code('lib/screens/profile/pv_you_content.dart'),
          contains("case 'wrong' when family:"));
    });
  });

  group('F2 · the screen', () {
    testWidgets('"Not sure yet" adds it and shows the page', (tester) async {
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: PvAddPregnancyScreen(today: today)));
      await tester.tap(find.byKey(const ValueKey('add_preg_way_not_sure')));
      await tester.pump();
      expect(find.textContaining('Week 4 · due'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('add_preg_save')));
      await tester.pumpAndSettle();
      expect(find.text('A new pregnancy'), findsOneWidget);
      expect(LifeStageStore.instance.stage, LifeStage.pregnancy);
      expect(ctrl.dueDateSource, DueDateSource.unknown);
      expect(tester.takeException(), isNull);
    });
  });
}
