// =============================================================================
//  "Trying again" from the family (STAGE-TRANSITIONS R1, 2026-10-25)
// -----------------------------------------------------------------------------
//  A mother in Parenting starts trying for another baby. The stage moves to
//  trying, her child stays a profile of its own, the TTC side's old "pregnant"
//  mark is cleared and its three questions are owed again, and the undo puts
//  every one of those back as it was.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_intro_flow.dart' show TtcIntroGate;
import 'package:parentveda/screens/v2/pv_try_again.dart';
import 'package:parentveda/services/family_timeline.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/stage_moves.dart';
import 'package:parentveda/ttc/ttc_store.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final today = _day(DateTime.now());
  final birthday = today.subtract(const Duration(days: 400));
  final firstConfirmed = birthday.subtract(const Duration(days: 250));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LifeStageStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    FamilyTimeline.instance.resetForTest();
    await TtcIntroGate.resetForTest();
    // She tried on ParentVeda for her first child: the intro was seen and the
    // TTC side confirmed that pregnancy. Then the birth.
    await TtcIntroGate.markSeen();
    TtcStore.instance.confirmPregnancy(on: firstConfirmed);
    LifeStageStore.instance.setStage(LifeStage.parenting, at: birthday);
  });

  group('who is offered it', () {
    test('her, in Parenting or the learning space', () {
      expect(tryingAgainOfferedFor(stage: LifeStage.parenting, father: false), isTrue);
      expect(tryingAgainOfferedFor(stage: LifeStage.skilling, father: false), isTrue);
    });

    test('not him, not while pregnant, not while already trying', () {
      expect(tryingAgainOfferedFor(stage: LifeStage.parenting, father: true), isFalse);
      expect(tryingAgainOfferedFor(stage: LifeStage.pregnancy, father: false), isFalse);
      expect(tryingAgainOfferedFor(stage: LifeStage.tryingToConceive, father: false), isFalse);
      expect(tryingAgainOfferedFor(stage: null, father: false), isFalse);
    });
  });

  group('the move', () {
    test('trying from today; the old mark cleared; the questions owed; the story dated', () async {
      await startTryingFromFamily(today: today);
      expect(LifeStageStore.instance.stage, LifeStage.tryingToConceive);
      expect(_day(LifeStageStore.instance.enteredAt!), today);
      expect(TtcStore.instance.pregnancyConfirmedOn, isNull,
          reason: 'else the TTC home opens on "A new beginning"');
      expect(await TtcIntroGate.owed(), isTrue,
          reason: 'she is asked her last period, not shown a cycle from years ago');
      final id = 'trying_again:${today.toIso8601String().substring(0, 10)}';
      expect(FamilyTimeline.instance.byId(id), isNotNull);
      expect(await tryingCameFromFamily(), isTrue);
    });

    test('the undo: back to Parenting at the birthday, the mark and the intro as they were', () async {
      await startTryingFromFamily(today: today);
      await undoTryingFromFamily();
      expect(LifeStageStore.instance.stage, LifeStage.parenting);
      expect(_day(LifeStageStore.instance.enteredAt!), birthday);
      expect(TtcStore.instance.pregnancyConfirmedOn, firstConfirmed);
      expect(await TtcIntroGate.owed(), isFalse);
      final id = 'trying_again:${today.toIso8601String().substring(0, 10)}';
      expect(FamilyTimeline.instance.byId(id), isNull);
      expect(await tryingCameFromFamily(), isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kTryingFromStageKey), isNull);
    });

    test('from the learning space, the undo goes back there', () async {
      LifeStageStore.instance.setStage(LifeStage.skilling, at: birthday);
      await startTryingFromFamily(today: today);
      await undoTryingFromFamily();
      expect(LifeStageStore.instance.stage, LifeStage.skilling);
    });

    test('a family who never saw the TTC side keeps owing its introduction after the undo', () async {
      await TtcIntroGate.resetForTest();
      await startTryingFromFamily(today: today);
      await undoTryingFromFamily();
      expect(await TtcIntroGate.owed(), isTrue);
    });

    test('a birth forgets the move, so no undo reaches back past it', () {
      final src = _code('lib/services/stage_moves.dart');
      final birth = src.substring(src.indexOf('Future<void> recordBirth('), src.indexOf('Future<void> recordLoss('));
      expect(birth, contains('await _forgetTryingMove();'));
    });
  });

  group('the page', () {
    test('one child, then two: the words', () {
      final one = tryAgainWords(['Meera']);
      expect(one.title, 'Trying for another baby');
      expect(one.changes.join(' '), contains('Meera keeps their own home'));
      final two = tryAgainWords(['Meera', 'Kabir']);
      expect(two.changes.join(' '), contains('Meera and Kabir keep their own homes'));
      // No promise of a chance, ever (clinical invariant).
      for (final w in [one.line, ...one.changes]) {
        expect(w.toLowerCase(), isNot(contains('chance')));
      }
    });

    test('the TTC home becomes the root, and so does the home the undo goes back to', () {
      final src = _code('lib/screens/v2/pv_try_again.dart');
      final root = src.substring(src.indexOf('void openTtcAsRoot('));
      expect(root.substring(0, 300), contains('pushAndRemoveUntil'));
      final back = src.substring(src.indexOf('void openFamilyRootAfterTryingUndo('));
      expect(back.substring(0, 600), contains('pushAndRemoveUntil'));
      expect(back.substring(0, 600), contains("'pp/my_child'"));
    });
  });

  group('wiring (the wiring gate)', () {
    test('the drawer, the family sheet and You all open the one page', () {
      expect(_code('lib/screens/post_pregnancy/next_baby_screens.dart'),
          contains('intent == NextBabyIntent.ovulation && tryingAgainOffered()'));
      expect(_code('lib/screens/post_pregnancy/next_baby_screens.dart'),
          contains('openTryAgain(context, replace: true);'));
      final sheet = _code('lib/screens/v2/pv_family_switch.dart');
      expect(sheet, contains("ValueKey('pv_family_switch_try_again')"));
      expect(sheet, contains('openTryAgain(context);'));
      final you = _code('lib/screens/profile/pv_you_content.dart');
      expect(you, contains('journeyThings: [_expectingAgain(), _tryingAgain(), _keptPregnancies()],'));
      expect(you, contains('journeyThings: [_notTryingAfterAll(), _keptPregnancies()],'));
    });

    test('the move stays in stage_moves.dart (M40)', () {
      expect(_code('lib/screens/v2/pv_try_again.dart'), isNot(contains('setStage(')));
    });
  });
}
