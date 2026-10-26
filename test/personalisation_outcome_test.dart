// =============================================================================
//  Personalisation reads how a pregnancy ended (STILL-OPEN §61.1, 2026-10-26)
// -----------------------------------------------------------------------------
//  `PregnancyRecords` knows whether the last pregnancy was a loss, a birth or
//  ended with no reason told. The rankers now use it, ORDER ONLY, and every
//  lift says why on screen (the user, 2026-10-26: what she told the app must
//  be seen to be used, never a reorder she cannot explain):
//  * trying again within 90 days of a loss: After a loss leads the TTC home;
//  * pregnant after a loss (recorded, or told in onboarding): "After IVF or a
//    loss" leads First weeks' Visit tab, and the positive test reads gently;
//  * the older-child reads lead with a child at home, sink for a first baby;
//  * a child whose mother is pregnant again: the sibling pages lead.
//  `ended` is never a loss.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/v2/pv_add_pregnancy.dart';
import 'package:parentveda/services/pregnancy_records.dart';
import 'package:parentveda/ttc/ttc_home_situation.dart';
import 'package:parentveda/ttc/ttc_phase.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

PregnancyRecord _rec(DateTime start, PregnancyOutcome outcome, {DateTime? ended}) =>
    PregnancyRecord(
      id: PregnancyRecord.idFor(start),
      startedOn: start,
      dueDate: start.add(const Duration(days: 280)),
      outcome: outcome,
      endedOn: ended,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final today = _day(DateTime.now());
  final lossStart = today.subtract(const Duration(days: 200));

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => PregnancyRecords.instance.debugReset());

  group('the history getters', () {
    test('a loss closed 10 days ago leads; at 100 days it does not', () {
      final recs = PregnancyRecords.instance;
      recs.debugReset(rows: [
        _rec(lossStart, PregnancyOutcome.loss,
            ended: today.subtract(const Duration(days: 10))),
      ]);
      expect(recs.lastEnded?.outcome, PregnancyOutcome.loss);
      expect(recs.lossRecentlyClosed(now: today), isTrue);
      expect(recs.lossRecentlyClosed(now: today.add(const Duration(days: 90))), isFalse);
      expect(recs.followsLoss, isTrue, reason: 'the positive test, before startNew');
      expect(recs.pregnantAfterLoss, isFalse, reason: 'not pregnant yet');
    });

    test('pregnant after a loss: both readers agree', () {
      final recs = PregnancyRecords.instance;
      recs.debugReset(rows: [
        _rec(lossStart, PregnancyOutcome.loss,
            ended: today.subtract(const Duration(days: 120))),
        _rec(today.subtract(const Duration(days: 50)), PregnancyOutcome.ongoing),
      ]);
      expect(recs.beforeCurrent?.outcome, PregnancyOutcome.loss);
      expect(recs.pregnantAfterLoss, isTrue);
      expect(recs.followsLoss, isTrue);
      expect(recs.lossRecentlyClosed(now: today), isFalse, reason: 'she is pregnant');
    });

    test('a birth or an ended pregnancy never reads as a loss', () {
      for (final o in [PregnancyOutcome.birth, PregnancyOutcome.ended]) {
        final recs = PregnancyRecords.instance;
        recs.debugReset(rows: [
          _rec(lossStart, o, ended: today.subtract(const Duration(days: 10))),
        ]);
        expect(recs.lossRecentlyClosed(now: today), isFalse, reason: o.name);
        expect(recs.followsLoss, isFalse, reason: o.name);
        recs.debugReset(rows: [
          _rec(lossStart, o, ended: today.subtract(const Duration(days: 120))),
          _rec(today.subtract(const Duration(days: 50)), PregnancyOutcome.ongoing),
        ]);
        expect(recs.pregnantAfterLoss, isFalse, reason: o.name);
      }
    });

    test('a first pregnancy has nothing before it', () {
      final recs = PregnancyRecords.instance;
      recs.debugReset(rows: [_rec(lossStart, PregnancyOutcome.ongoing)]);
      expect(recs.beforeCurrent, isNull);
      expect(recs.pregnantAfterLoss, isFalse);
    });
  });

  group('TTC home: After a loss leads, order only', () {
    const ids = ['ttc_conceiving', 'ttc_infertility', 'ttc_after_loss', 'ttc_not_yet'];
    test('first after a loss, the clinic one row down, every door kept', () {
      final out = ttcHomeDoorOrder(ids,
          clinicPathway: true,
          tryingLong: false,
          phase: TtcDayPhase.window,
          afterLoss: true);
      expect(out.take(2), ['ttc_after_loss', 'ttc_infertility']);
      expect(out.toSet(), ids.toSet());
      expect(out.length, ids.length);
    });
    test('without a loss, the door keeps its own place', () {
      final out = ttcHomeDoorOrder(ids,
          clinicPathway: false, tryingLong: false, phase: TtcDayPhase.window);
      expect(out, ids);
    });
    test('the live order reads the records, and the home explains the lead', () {
      expect(_code('lib/ttc/ttc_home_situation.dart'),
          contains('afterLoss: PregnancyRecords.instance.lossRecentlyClosed(now: at)'));
      final home = _code('lib/screens/ttc/ttc_home_v3.dart');
      expect(home, contains("ValueKey('ttc_home_after_loss_why')"));
      expect(home, contains('After a loss is first for now'));
    });
  });

  group('pregnancy doors', () {
    test('after a loss, "After IVF or a loss" leads Visit, and says why', () {
      const h = PregHistory(afterLoss: true);
      final plain = kFirstWeeksDoor.sectionsFor(kFirstTabVisit, 8);
      final led = kFirstWeeksDoor.sectionsFor(kFirstTabVisit, 8, history: h);
      expect(led.first.heading, 'After IVF or a loss');
      expect(led.map((s) => s.heading).toSet(), plain.map((s) => s.heading).toSet());
      expect(plain.first.heading, isNot('After IVF or a loss'));
      expect(pvDoorSectionWhy(led.first, h), 'First here, after your last pregnancy');
      expect(
          pvDoorSectionWhy(led.first,
              const PregHistory(afterLoss: true, lossToldInOnboarding: true)),
          'First here, because you told us about a past loss');
      expect(pvDoorSectionWhy(led.first, PregHistory.none), isNull);
    });

    test('older-child reads: first with a child, last without, never gone', () {
      final family = kFirstWeeksDoor.sections.firstWhere((s) =>
          s.tiles.any((t) => t is PvDoorGuideTile && t.readId == 'preg_ready_read_older_child'));
      bool older(PvDoorTile t) =>
          t is PvDoorGuideTile && kPregOlderChildReads.contains(t.readId);
      final withChild = family.tilesFor(8,
          history: const PregHistory(hasChild: true, childName: 'Meera'));
      final firstBaby = family.tilesFor(8, history: const PregHistory(hasChild: false));
      final unknown = family.tilesFor(8);
      expect(older(withChild.first), isTrue);
      expect(older(firstBaby.last), isTrue);
      expect(unknown, family.tilesFor(8, history: PregHistory.none));
      expect(withChild.length, family.tiles.length);
      expect(firstBaby.length, family.tiles.length);
      expect(pvDoorSectionWhy(family, const PregHistory(hasChild: true, childName: 'Meera')),
          'With Meera at home, this comes first');
      expect(pvDoorSectionWhy(family, const PregHistory(hasChild: false)), isNull,
          reason: 'a section that sank says nothing');
    });

    test('the door screen hands its history to every order and draws the why', () {
      final s = _code('lib/screens/doors/pv_door_screen.dart');
      expect('history: _history'.allMatches(s).length, 3);
      expect(s, contains('pvDoorSectionWhy(section, _history)'));
      expect(s, contains('PregnancyRecords.instance.pregnantAfterLoss || fam.gentleAboutLoss'));
      expect(s, contains('fam.parity == Parity.first'));
    });
  });

  group('the words at the moment', () {
    test('the positive test reads gently after a loss', () {
      final t = TtcS.current();
      expect(t.transitionTitleAfterLoss, isNot(contains('beautiful')));
      expect(t.transitionSubtitleAfterLoss, contains('hope and worry'));
      expect(_code('lib/screens/ttc/ttc_transition_screen.dart'),
          contains('PregnancyRecords.instance.followsLoss'));
    });

    test('add a pregnancy: the kept line only when one is kept; gentle after a loss', () {
      final w = addPregnancyCelebrationWords(
          week: 8, sureOfDate: true, childNames: const ['Meera'], lastKept: false);
      expect(w.changes.join(' '), isNot(contains('Your last pregnancy is kept')));
      final after = addPregnancyCelebrationWords(
          week: 8, sureOfDate: true, childNames: const ['Meera'], afterLoss: true);
      expect(after.line, contains('hope and worry'));
      expect(after.changes.join(' '), contains('Your last pregnancy is kept'));
      expect(_code('lib/screens/v2/pv_add_pregnancy.dart'),
          contains('afterLoss: PregnancyRecords.instance.pregnantAfterLoss'));
    });
  });

  group('parenting: a baby on the way', () {
    test('the sibling pages lead, and the card says why', () {
      final pages = [
        'Bringing your new baby home',
        'Tantrums at two',
        'Jealousy and fighting between siblings',
      ];
      const sit = PpSituation(ageMonths: 24, daysOld: 730, signals: {PpSignal.babyOnTheWay});
      final out = ppRelevanceOrder(pages, situation: sit, text: (p) => p);
      expect(out.first, 'Jealousy and fighting between siblings');
      expect(ppRelevanceWhy(sit, out.first), 'A baby on the way');
      expect(PpSignal.babyOnTheWay.matches('Bringing your new baby home'), isFalse,
          reason: 'newborn pages say "new baby"; they must not lift');
    });

    test('set from her record, and the child keeps its own age', () {
      final s = _code('lib/screens/post_pregnancy/pp_relevance.dart');
      expect(s, contains('child.hasRealChild && PregnancyRecords.instance.current != null'));
      final now = s.substring(s.indexOf('factory PpSituation.now()'),
          s.indexOf('final int ageMonths;'));
      expect(now, isNot(contains('LifeStageStore')),
          reason: "the child's bands follow the child, not the app's stage");
    });
  });
}
