// =============================================================================
//  Stage transitions: every move between life stages (2026-10-24)
// -----------------------------------------------------------------------------
//  GLOBAL-CHANGES item 9; the running list is docs/STAGE-TRANSITIONS.md, and
//  each test names its row there (M1..M40, B1..B8).
//
//  Written for the RIGHT behaviour. The loss rows (M20..M24) failed on the code
//  before 2026-10-24: after a loss and "Move to trying to conceive" the TTC
//  home stayed on "A new beginning" with the period ninety days late, and a
//  second pregnancy opened on the loss page with no messages and no story.
//
//  Every group starts with `stage:`, so `flutter test --plain-name "stage:"`
//  runs them all. Plain `test()` throughout: the child store's writes hang
//  inside `testWidgets` (pp_child_profile.dart, `debugSetDob`).
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/pregnancy/preg_hero_extras.dart';
import 'package:parentveda/services/dear_baby_vault_store.dart';
import 'package:parentveda/services/family_timeline.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pp_messages_store.dart';
import 'package:parentveda/services/preg_messages_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/services/stage_moves.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_home_hero.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_transition.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

/// A file's code with whole-line comments removed (the commented-out code
/// kept for revert must not satisfy, or fail, a source check).
String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Lets the stores' un-awaited writes land.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const engine = TtcTransitionEngine();
  late PregnancyController ctrl;
  final today = _day(DateTime.now());

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LifeStageStore.instance.resetForTest();
    PregnancyEndedStore.instance.resetForTest();
    await PregnancyEndedStore.instance.load();
    TtcStore.instance.resetForTest();
    CycleStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    FamilyTimeline.instance.resetForTest();
    ChildProfileStore.instance.resetForTest();
    DearBabyVaultStore.instance.resetForTest();
    ctrl = PregnancyController(now: DateTime.now());
    PregnancyController.current = ctrl;
  });
  tearDown(() => PregnancyController.current = null);

  /// Trying, with three logged periods ending about four months ago.
  void seedTrying() {
    LifeStageStore.instance.setStage(LifeStage.tryingToConceive,
        at: today.subtract(const Duration(days: 400)));
    CycleStore.instance
      ..logPeriodStart(today.subtract(const Duration(days: 176)))
      ..logPeriodStart(today.subtract(const Duration(days: 148)))
      ..logPeriodStart(today.subtract(const Duration(days: 120)));
  }

  // ===========================================================================
  group('stage: A · the stage itself', () {
    test('M1 every stage round-trips through the saved key, skilling too',
        () async {
      for (final s in LifeStage.values) {
        LifeStageStore.instance.resetForTest();
        LifeStageStore.instance.setStage(s);
        await _settle();
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(LifeStageStore.kLifeStageKey), s.id,
            reason: '$s is not saved');
        expect(LifeStageCopy.fromId(s.id), s,
            reason: '$s does not come back on the next launch');
      }
    });

    test('M2 the same stage keeps its date; a given date is used', () {
      final first = DateTime(2026, 1, 5);
      LifeStageStore.instance.setStage(LifeStage.pregnancy, at: first);
      LifeStageStore.instance
          .setStage(LifeStage.pregnancy, at: DateTime(2026, 3, 1));
      expect(LifeStageStore.instance.enteredAt, first);
      LifeStageStore.instance
          .setStage(LifeStage.parenting, at: DateTime(2026, 9, 9));
      expect(LifeStageStore.instance.enteredAt, DateTime(2026, 9, 9));
    });

    test('M4 the auth ids, and unknown or empty ids are ignored', () {
      final s = LifeStageStore.instance;
      s.setStageId('pregnant');
      expect(s.stage, LifeStage.pregnancy);
      s.setStageId('new');
      expect(s.stage, LifeStage.parenting);
      s.setStageId('');
      s.setStageId('nope');
      s.setStageId(null);
      expect(s.stage, LifeStage.parenting);
      s.setStageId('skilling');
      expect(s.stage, LifeStage.skilling);
    });

    test('M5 the splash has a home for every stage, mother and father', () {
      final src = _code('lib/screens/splash_screen.dart');
      final start = src.indexOf('Route<void> _homeFor(');
      expect(start, greaterThan(-1));
      final body = src.substring(start, src.indexOf('\n  }\n', start));
      for (final s in [
        'stage == LifeStage.tryingToConceive.id) return _ttcRoute()',
        'stage == LifeStage.parenting.id) return _parentingRoute()',
        'stage == LifeStage.skilling.id) return _skillingRoute()',
        "role == 'father' && stage == LifeStage.parenting.id",
        "role == 'father' && stage == LifeStage.tryingToConceive.id",
      ]) {
        expect(body, contains(s), reason: 'no home for: $s');
      }
      expect(body, contains('return _mainRoute()'),
          reason: 'pregnancy, and no stage at all, open the pregnancy shell');
      // The route names other code reads (the FAB, `openPpTab`).
      expect(src, contains("settings: const RouteSettings(name: 'pp/my_child')"));
      expect(src, contains("settings: const RouteSettings(name: 'skilling')"));
      expect(src, contains('settings: const RouteSettings(name: ttcHomeRoute)'));
    });
  });

  // ===========================================================================
  group('stage: B · trying to conceive → pregnancy', () {
    test('M6 each way of dating the pregnancy, with its source', () async {
      seedTrying();
      final lmp = CycleStore.instance.lastPeriodStart!;
      var r = await engine.confirmPregnancy(on: today);
      expect(r.dueDate, _day(lmp.add(const Duration(days: 280))));
      expect(ctrl.dueDateSource, DueDateSource.lastPeriod);
      await engine.undo();

      final clinic = today.add(const Duration(days: 200));
      r = await engine.confirmPregnancy(
          on: today, dueDate: clinic, source: DueDateSource.ivfTransfer);
      expect(r.dueDate, clinic);
      expect(ctrl.dueDateSource, DueDateSource.ivfTransfer);
      expect(ctrl.dueDateSource.clinicOwned, isTrue);
      await engine.undo();

      CycleStore.instance.resetForTest();
      r = await engine.confirmPregnancy(on: today);
      expect(r.dueDateWasDerived, isFalse,
          reason: 'no period logged: a guess the page must say is a guess');
      expect(ctrl.dueDateSource, DueDateSource.unknown);
    });

    test('M8 a positive test with a round open goes to the round first', () {
      final src = _code('lib/screens/ttc/ttc_transition_screen.dart');
      final fn = src.substring(src.indexOf('Future<bool> recordPositiveTest('));
      final round = fn.indexOf('openTtcRoundPregnancy(context)');
      final page = fn.indexOf('TtcPositiveTestScreen()');
      expect(round, greaterThan(-1));
      expect(round, lessThan(page),
          reason: 'the round must be checked before the page that moves stage');
    });

    test('M9 confirming twice records the story once', () async {
      seedTrying();
      await engine.confirmPregnancy(on: today);
      await engine.confirmPregnancy(on: today);
      final ids = FamilyTimeline.instance.events
          .where((e) => e.id.startsWith('ttc_positive_test'))
          .toList();
      expect(ids, hasLength(1));
    });

    test('M10 undo removes only THIS pregnancy from the story (B3)', () async {
      seedTrying();
      final first = today.subtract(const Duration(days: 90));
      await engine.confirmPregnancy(on: first);
      // A later pregnancy, after a loss and a new start.
      TtcStore.instance.clearPregnancyConfirmation();
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
      await engine.confirmPregnancy(on: today);
      final tag = today.toIso8601String().substring(0, 10);
      expect(FamilyTimeline.instance.has('ttc_positive_test:$tag'), isTrue,
          reason: 'the second pregnancy was not recorded');
      await engine.undo();
      expect(FamilyTimeline.instance.has('ttc_positive_test:$tag'), isFalse);
      expect(FamilyTimeline.instance.has('pregnancy_started:$tag'), isFalse);
      expect(FamilyTimeline.instance.has('ttc_positive_test'), isTrue,
          reason: 'undo deleted the FIRST pregnancy from her story');
      expect(FamilyTimeline.instance.has('pregnancy_started'), isTrue);
    });
  });

  // ===========================================================================
  group('stage: C · pregnancy → parenting (the birth)', () {
    test('M12 the stage starts on the birthday, with the story and letters',
        () async {
      LifeStageStore.instance.setStage(LifeStage.pregnancy,
          at: today.subtract(const Duration(days: 250)));
      final dob = today.subtract(const Duration(days: 3));
      final child = await ChildProfileStore.instance
          .addChild(name: 'Meera', isBoy: false, dob: dob);
      await recordBirth(dob: dob, name: child.name, childId: child.id);
      expect(LifeStageStore.instance.stage, LifeStage.parenting);
      expect(LifeStageStore.instance.enteredAt, dob,
          reason: 'a baby told on Thursday was born on Monday');
      expect(FamilyTimeline.instance.byId('baby_born')?.titleEn,
          'Meera was born');
      expect(FamilyTimeline.instance.byId('baby_born')?.date, dob);
      expect(DearBabyVaultStore.instance.bornOn, isNotNull);
      expect(ChildProfileStore.instance.hasRealChild, isTrue);
    });

    test('M13 born-early weeks at the edges', () async {
      final due = today.add(const Duration(days: 60));
      await ctrl.setDueDate(due, source: DueDateSource.lastPeriod);
      int? w(int daysEarly) =>
          bornWeeksFor(due.subtract(Duration(days: daysEarly)));
      expect(w(22), 36, reason: '36 weeks 6 days');
      expect(w(21), isNull, reason: '37 weeks is on time');
      expect(w(280 - 20 * 7), 20);
      expect(w(280 - 19 * 7), isNull, reason: 'under 20 weeks is not a birth');
      expect(w(0), isNull);
      expect(w(-10), isNull, reason: 'after the due date is not early');
      expect(bornWeeksFor(today, controller: PregnancyController(now: today)),
          isNull,
          reason: 'with no real due date there is nothing to measure from');
    });

    test('M14 a skipped "boy or girl" is saved as not given', () async {
      final c = await ChildProfileStore.instance.addChild(
          name: 'Baby', isBoy: true, sexGiven: false, dob: today);
      expect(c.sexGiven, isFalse);
    });

    test('M15 + M16 a birth past 42 weeks records; the due date is kept',
        () async {
      final due = today.subtract(const Duration(days: 20));
      await ctrl.setDueDate(due, source: DueDateSource.scan);
      LifeStageStore.instance.setStage(LifeStage.pregnancy,
          at: today.subtract(const Duration(days: 280)));
      final dob = today.subtract(const Duration(days: 1));
      await recordBirth(dob: dob, name: '');
      expect(LifeStageStore.instance.stage, LifeStage.parenting);
      expect(FamilyTimeline.instance.byId('baby_born')?.titleEn,
          'Baby was born');
      expect(bornWeeksFor(dob), isNull);
      expect(ctrl.isDueDateSet, isTrue,
          reason: 'the due date is what "born early" is measured from');
    });

    test('M17 pregnancy messages stop and parenting messages may start',
        () async {
      await ctrl.setDueDate(today.add(const Duration(days: 100)),
          source: DueDateSource.lastPeriod);
      LifeStageStore.instance.setStage(LifeStage.pregnancy);
      expect(PregMessageFacts.fromStores()!.speaks, isTrue);
      await recordBirth(dob: today, name: 'Meera');
      expect(PregMessageFacts.fromStores()!.speaks, isFalse);
      expect(PpMessageFacts.fromStores().inParenting, isTrue);
    });

    test('a second baby on another day gets its own story entry (B3)',
        () async {
      await recordBirth(
          dob: today.subtract(const Duration(days: 800)), name: 'Meera');
      LifeStageStore.instance.setStage(LifeStage.pregnancy);
      await recordBirth(dob: today, name: 'Kabir');
      final tag = today.toIso8601String().substring(0, 10);
      expect(FamilyTimeline.instance.byId('baby_born')?.titleEn,
          'Meera was born');
      expect(FamilyTimeline.instance.byId('baby_born:$tag')?.titleEn,
          'Kabir was born');
    });
  });

  // ===========================================================================
  group('stage: D · a loss, and trying again', () {
    /// Trying → pregnant 60 days ago → a loss reported now.
    Future<void> pregnantThenLoss() async {
      seedTrying();
      await engine.confirmPregnancy(
          on: today.subtract(const Duration(days: 60)));
      await PregnancyEndedStore.instance.markEnded();
    }

    test('M18 a loss keeps the stage and silences the pregnancy', () async {
      await pregnantThenLoss();
      expect(LifeStageStore.instance.stage, LifeStage.pregnancy);
      expect(PregnancyEndedStore.instance.ended, isTrue);
      expect(PregMessageFacts.fromStores()!.speaks, isFalse);
    });

    test('M19 undoing the loss brings the pregnancy back', () async {
      await pregnantThenLoss();
      await PregnancyEndedStore.instance.undo();
      expect(PregnancyEndedStore.instance.ended, isFalse);
      expect(PregMessageFacts.fromStores()!.speaks, isTrue);
    });

    test('M20 "Move to trying to conceive": a clean restart, the loss kept (B2)',
        () async {
      await pregnantThenLoss();
      await moveToTtcAfterLoss();
      expect(LifeStageStore.instance.stage, LifeStage.tryingToConceive);
      expect(TtcStore.instance.pregnancyConfirmed, isFalse,
          reason: 'TTC still believed she was pregnant');
      expect(TtcStore.instance.today.chapter,
          isNot(TtcChapter.aNewBeginning));
      expect(TtcMessageFacts.fromStores().pregnancyConfirmed, isFalse,
          reason: 'TTC messages stay silent while it believes she is pregnant');
      expect(ctrl.isDueDateSet, isFalse,
          reason: 'nothing may count weeks of a pregnancy that has ended');
      expect(PregnancyEndedStore.instance.lossRecorded, isTrue,
          reason: 'the loss is part of her story, never erased');
      expect(PregnancyEndedStore.instance.endedAt, isNotNull);
      expect(CycleStore.instance.restartOn, today);
      expect(CycleStore.instance.lastPeriodStart, isNull,
          reason: 'a period from before the pregnancy is not her cycle now');
      expect(ttcHomeHeroLine().state, TtcHeroState.startHere,
          reason: 'the home invites her to log a period, never "late"');
      expect(TtcMessageFacts.fromStores().periodStarts, isEmpty,
          reason: 'the "late, time to test" message counts from these');
      expect(CycleStore.instance.periodStarts, hasLength(3),
          reason: 'her log is history, kept');
    });

    test('M21 the first period after the restart drives the cycle', () async {
      await pregnantThenLoss();
      await moveToTtcAfterLoss();
      CycleStore.instance.logPeriodStart(today);
      expect(CycleStore.instance.lastPeriodStart, today);
      expect(CycleStore.instance.cycleLengths, [28, 28],
          reason: 'the span across the pregnancy is not a cycle');
      expect(ttcHomeHeroLine().state, isNot(TtcHeroState.startHere));
    });

    test('M22 loss → trying → a new positive: her new pregnancy is hers (B1b, B3)',
        () async {
      await pregnantThenLoss();
      await moveToTtcAfterLoss();
      CycleStore.instance.logPeriodStart(today);
      final next = today.add(const Duration(days: 1));
      await engine.confirmPregnancy(on: next);
      expect(LifeStageStore.instance.stage, LifeStage.pregnancy);
      expect(PregnancyEndedStore.instance.ended, isFalse,
          reason: 'the new pregnancy opened on the loss page');
      expect(PregnancyEndedStore.instance.lossRecorded, isTrue);
      expect(PregMessageFacts.fromStores()!.speaks, isTrue);
      final tag = next.toIso8601String().substring(0, 10);
      expect(FamilyTimeline.instance.has('ttc_positive_test'), isTrue);
      expect(FamilyTimeline.instance.has('ttc_positive_test:$tag'), isTrue,
          reason: 'the second pregnancy is missing from her story');
    });

    test('M22 her new pregnancy gets its weekly messages again (B5)', () {
      final store = PregMessagesStore.instance..resetForTest();
      final old = DateTime(2026, 3, 1, 9);
      PregMessage week8(DateTime at) => PregMessage(
          id: 'week:8',
          kind: PregMessageKind.newWeek,
          at: at,
          week: 8,
          title: 'Week 8 starts today',
          body: '');
      store.apply([week8(old)], old.add(const Duration(hours: 1)));
      final again = DateTime(2026, 10, 1, 9);
      final now = again.add(const Duration(hours: 1));
      store.apply([week8(again)], now, since: DateTime(2026, 8, 20));
      final delivered = store.delivered(now: now);
      expect(delivered.where((m) => m.id == 'week:8'), hasLength(1),
          reason: 'one message per id');
      expect(delivered.firstWhere((m) => m.id == 'week:8').at, now,
          reason: "this pregnancy's week 8 was silenced as already sent");
    });

    test('M23 + M24 the WhatsApp guide: silent after a loss, back for a new pregnancy (B1)',
        () {
      final dir = Directory('supabase/migrations');
      final defs = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .where((f) => f
              .readAsStringSync()
              .contains('create or replace function public.wa_enqueue_weekly_guide'))
          .map((f) => f.path.replaceAll('\\', '/'))
          .toList()
        ..sort();
      expect(defs.last, endsWith('0112_wa_weekly_guide_loss.sql'),
          reason: 'a later migration redefines the guide: carry the loss rule');
      final sql = File(defs.last).readAsStringSync().replaceAll('\r\n', '\n');
      expect(sql, contains("coalesce(p.life_stage, 'pregnancy') = 'pregnancy'"));
      expect(sql, contains('p.pregnancy_ended_at is null'));
      expect(sql, contains('p.pregnancy_ended_at < p.life_stage_at'),
          reason: 'a loss must speak only for the pregnancy it ended');
      // The app sends the stage date the rule compares against.
      expect(_code('lib/services/life_stage_store.dart'),
          contains("'life_stage_at':"));
    });
  });

  // ===========================================================================
  group('stage: E · joining part-way (onboarding)', () {
    final src = _code('lib/screens/auth/onboarding/onboarding_flow.dart');
    final finish = src.substring(src.indexOf('Future<void> _finish('));

    test('M29 a parent: the stage starts on the birthday, the birth recorded (B4)',
        () {
      final dated = finish.indexOf('setStage(LifeStage.parenting,');
      final added = finish.indexOf('ChildProfileStore.instance.addChild(');
      expect(dated, greaterThan(-1),
          reason: 'the parenting stage must be dated to the birthday');
      expect(dated, lessThan(added),
          reason: 'dated before anything re-declares the stage');
      expect(finish, contains('recordBirth('),
          reason: 'onboarding must record the birth the way the birth sheet does');
    });

    test('M25 trying: a period only when she gave one; each intent its path',
        () {
      expect(finish,
          contains('if (!_isPartner && _lmp != null && !_lmpUnknown) {'),
          reason: '"I don\'t remember" or the partner must log no period');
      expect(finish, contains("if (_where == 'trying') ttc.setPath(TtcPath.natural);"));
      for (final p in [
        "'oi': TtcPath.ovulationInduction",
        "'iui': TtcPath.iui",
        "'ivf': TtcPath.ivf",
      ]) {
        expect(finish, contains(p));
      }
      expect(finish, contains('await plan.setPlannedStart(_readyMonth);'),
          reason: 'planning: a planned month, not a path');
    });

    test('M28 twins are saved; a pregnancy after a loss is gentle', () {
      expect(finish, contains('ReadyBirthContextStore.instance.setTwins(true)'));
      final parity = finish.indexOf("contains('subsequent')");
      expect(parity, greaterThan(-1));
      expect(finish.indexOf('profile.setGentle(_gentle)', parity),
          greaterThan(parity));
    });

    test('M30 skilling: the stage is saved and the child gets a birthday', () {
      expect(LifeStageCopy.fromId('skilling'), LifeStage.skilling,
          reason: 'the faf0f04 relaunch fix');
      expect(finish, contains("if (stage == 'skilling' && _childAge != null) {"));
      expect(finish, contains('SkChildStore.instance.update(name: _childName.text, dob: dob)'));
    });

    test('M26 a pregnancy: the dating method decides who owns the date', () {
      expect(finish, contains('source: ddcSourceFor(_method)'));
    });

    test('M27 a due date already passed or far ahead clamps, no crash', () {
      final passed =
          PregnancyController(dueDate: today.subtract(const Duration(days: 20)), now: today);
      expect(passed.currentWeek, 40);
      expect(passed.daysPastDue, 20);
      final ahead =
          PregnancyController(dueDate: today.add(const Duration(days: 300)), now: today);
      expect(ahead.currentWeek, 4);
    });

    test('M31 the family profile maps skilling to parenting (pinned, R5)', () {
      expect(finish, contains('_ => JourneyStage.parenting'));
    });
  });

  // ===========================================================================
  group('stage: F · moves that do not exist yet', () {
    test('M33 the avatar door menu never changes the stage', () {
      final src = _code('lib/services/stage_gateway.dart');
      expect(src, isNot(contains('setStage')));
    });

    test('M34 the developer switches change only the stage', () {
      final src = _code('lib/screens/profile/pv_you_screen.dart');
      final fn = src.substring(src.indexOf('void _switchStage('));
      final body = fn.substring(0, fn.indexOf('\n  }\n'));
      expect(body, contains('setStage('));
      for (final w in ['setDueDate', 'addChild', 'FamilyTimeline', 'markEnded']) {
        expect(body, isNot(contains(w)),
            reason: 'a real move must not hide behind the developer switch');
      }
    });
  });

  // ===========================================================================
  group('stage: G · the systems around the stage', () {
    test('M35 the Ask Veda button stays off the skilling home (B7)', () {
      final src = _code('lib/widgets/global_ask_fab.dart');
      expect(src, contains("name == 'skilling'"));
      expect(src, contains("name.startsWith('sk_')"));
      expect(src, contains("name.startsWith('sk/')"));
    });

    test('M36 a second child gets its own milestones, the first no repeats (B6)',
        () {
      expect(ppMessageIdPrefix('a', 'a'), '');
      expect(ppMessageIdPrefix(null, null), '');
      expect(ppMessageIdPrefix('b', 'a'), 'child:b|');
      final dob = DateTime(2026, 6, 29);
      final now = DateTime(2026, 10, 27);
      PpMessageFacts f(String prefix) => PpMessageFacts(
          dob: dob, name: 'Meera', realChild: true, idPrefix: prefix);
      final first = ppMessageCandidates(f(''), now).map((m) => m.id).toSet();
      final second =
          ppMessageCandidates(f('child:b|'), now).map((m) => m.id).toSet();
      expect(first, contains('age:m4'), reason: 'legacy ids unchanged');
      expect(second, contains('child:b|age:m4'));
      expect(first.intersection(second).where((id) => !id.startsWith('act:')),
          isEmpty,
          reason: "one child's milestone would silence the other's");
    });

    test('M37 the three message stores own separate phone ids', () {
      final preg = {for (final k in PregMessageKind.values) ...k.phoneIds};
      final pp = {for (final k in PpMessageKind.values) ...k.phoneIds};
      final ttc = {for (final k in TtcMessageKind.values) ...k.phoneIds};
      expect(preg.intersection(pp), isEmpty);
      expect(preg.intersection(ttc), isEmpty);
      expect(pp.intersection(ttc), isEmpty,
          reason: 'a stage change cancels its own ids only');
    });

    test('M38 the placeholder moves a week every 7 days and stops at 40',
        () async {
      final anchor = DateTime(2026, 1, 1);
      SharedPreferences.setMockInitialValues({
        PregnancyController.kPlaceholderAnchorKey: anchor.toIso8601String(),
      });
      final c = PregnancyController(now: anchor.add(const Duration(days: 14)));
      await c.load();
      expect(c.isDueDateSet, isFalse);
      expect(c.currentWeek, 22);
      final late = PregnancyController(now: anchor.add(const Duration(days: 300)));
      await late.load();
      expect(late.currentWeek, 40);
    });

    test('M39 past the due date: week 40, days past grow, the arrival card from 37',
        () {
      final c = PregnancyController(
          dueDate: today.subtract(const Duration(days: 9)), now: today);
      expect(c.currentWeek, 40);
      expect(c.isOverdue, isTrue);
      expect(c.daysPastDue, 9);
      final prompt = PregArrivalPrompt.instance..resetForTest();
      expect(prompt.showsFor(36), isFalse);
      expect(prompt.showsFor(37), isTrue);
      expect(PregArrivalPrompt.rest, const Duration(days: 3));
    });
  });

  // ===========================================================================
  group('stage: H · wiring gate', () {
    test('M40 every move goes through its one function', () {
      expect(_code('lib/screens/pregnancy/preg_ended_screen.dart'),
          contains('moveToTtcAfterLoss()'));
      expect(_code('lib/screens/profile/pv_you_sheets.dart'),
          contains('recordBirth('));
      expect(_code('lib/screens/auth/onboarding/onboarding_flow.dart'),
          contains('recordBirth('));
      // F2 (2026-10-25): a pregnancy added from the family, and its undo.
      expect(_code('lib/screens/v2/pv_add_pregnancy.dart'),
          contains('startPregnancyFromFamily('));
      expect(_code('lib/screens/profile/pv_you_content.dart'),
          contains('undoPregnancyFromFamily()'));
    });

    test('M40 nothing else sets the stage (an allow-list)', () {
      // Every file that may call LifeStageStore's setStage, and why. A new
      // caller is a new move: give it a function in stage_moves.dart (and a
      // row in docs/STAGE-TRANSITIONS.md) before adding it here.
      const allowed = {
        'lib/services/life_stage_store.dart', // the store itself
        'lib/services/stage_moves.dart', // the moves
        'lib/ttc/ttc_transition.dart', // TTC → pregnancy and its undo
        'lib/screens/auth/onboarding/onboarding_flow.dart', // joining
        'lib/screens/auth/auth_flow_screen.dart', // legacy join, setStageId
        'lib/screens/profile/pv_you_screen.dart', // developer switches
        'lib/screens/ttc/ttc_profile_screen.dart', // classic, unreached (B8)
        // After recordBirth these re-declare parenting, which is a no-op:
        'lib/screens/pregnancy/preg_hero_extras.dart',
        'lib/screens/pregnancy/preg_messages_screen.dart',
        'lib/screens/profile/pv_you_content.dart',
      };
      final callers = <String>[];
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final path = f.path.replaceAll('\\', '/');
        final code = _code(path);
        if (code.contains('.setStage(') || code.contains('.setStageId(')) {
          if (path.endsWith('family_profile.dart')) continue; // R5, its own
          if (!allowed.contains(path)) callers.add(path);
        }
      }
      expect(callers, isEmpty,
          reason: 'a new place changes the stage outside the moves');
    });

    // B10: every home's avatar opens You. The header chrome falls back to the
    // three-stage menu unless told otherwise, and Skilling's had been.
    test('M41 every home avatar opens You, never the stage menu', () {
      final missing = <String>[];
      for (final f in Directory('lib/screens').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final path = f.path.replaceAll('\\', '/');
        if (path.endsWith('v3_hero_chrome.dart')) continue;
        final code = _code(path);
        // V3Hero in v3_sections.dart is kept for revert and built nowhere.
        if (path.endsWith('v3_sections.dart')) continue;
        if (code.contains('V3HeroChrome(') &&
            code.contains('onProfile:') &&
            !code.contains('avatarOpensProfile: true')) {
          missing.add(path);
        }
        if (code.contains('V3PregHero(') &&
            !path.endsWith('v3_preg_hero.dart') &&
            !code.contains('onAvatar:')) {
          missing.add(path);
        }
      }
      expect(missing, isEmpty);
      expect(_code('lib/screens/post_pregnancy/pp_home_v3.dart'),
          contains("semantic: 'Profile',\n                            onTap: onProfile,"));
      // V3Hero itself is still never built.
      final heroUsers = Directory('lib').listSync(recursive: true).whereType<File>().where((f) =>
          f.path.endsWith('.dart') && !f.path.replaceAll('\\', '/').endsWith('v3_sections.dart') &&
          _code(f.path).contains('V3Hero('));
      expect(heroUsers, isEmpty);
    });
  });
}
