// Relevance round 2 for Pregnancy and TTC (2026-10-28).
// docs/door-relevance/PREGNANCY-GAP.md 32-34, TTC-GAP.md 28-30.
//
// Her history beyond a loss moves pages (IVF, twins, a past C-section, sugar
// or BP); a child at home moves TTC's second-baby page; every lift is a list
// of ids; and the content check's fixes hold.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart'
    show pregAfterTreatment;
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart'
    show ttcDoorOrderedGroups;
import 'package:parentveda/services/pregnancy_controller.dart'
    show DueDateSource;
import 'package:parentveda/ttc/ttc_age_rank.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart' show TtcPath;
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

PvDoorSection _section(PvDoorPage d, String heading) =>
    d.sections.firstWhere((s) => s.heading == heading);

String? _first(PvDoorSection s, PregHistory h, {int week = 20}) =>
    pregLiftKey(s.tilesFor(week, history: h).first);

void main() {
  group('Pregnancy: her history beyond a loss', () {
    test('every lifted id is on a door, so a renamed page cannot drop out', () {
      final keys = {
        for (final p in kPvDoorPages)
          for (final s in p.sections)
            for (final t in s.tiles) pregLiftKey(t),
      };
      for (final e in kPregLiftPages.entries) {
        for (final id in e.value) {
          expect(keys, contains(id), reason: '${e.key.name}: $id');
        }
      }
    });

    test('nothing known: nothing moves', () {
      for (final p in kPvDoorPages) {
        for (final g in p.groups) {
          final plain = p.sectionsFor(g.id, 20);
          final none = p.sectionsFor(g.id, 20, history: PregHistory.none);
          expect([for (final s in none) s.heading],
              [for (final s in plain) s.heading]);
          for (final s in plain) {
            expect(pvDoorSectionWhy(s, PregHistory.none), isNull);
          }
        }
      }
    });

    test('after treatment, "After IVF or a loss" leads its tab and says why',
        () {
      const h = PregHistory(afterTreatment: true);
      final led = kFirstWeeksDoor.sectionsFor(kFirstTabVisit, 8, history: h);
      expect(led.first.heading, 'After IVF or a loss');
      expect(pvDoorSectionWhy(led.first, h),
          'First here, because this pregnancy came after fertility treatment');
      // A loss keeps its own line when both are true.
      const both = PregHistory(afterTreatment: true, afterLoss: true);
      expect(pvDoorSectionWhy(led.first, both),
          'First here, after your last pregnancy');
    });

    test('the treatment fact: a transfer date, or TTC on a treatment path', () {
      expect(
          pregAfterTreatment(
              source: DueDateSource.ivfTransfer,
              ttcPath: TtcPath.natural,
              ttcConfirmed: false),
          isTrue);
      expect(
          pregAfterTreatment(
              source: DueDateSource.lastPeriod,
              ttcPath: TtcPath.iui,
              ttcConfirmed: true),
          isTrue);
      // A path left over from trying, with no TTC confirmation, says nothing.
      expect(
          pregAfterTreatment(
              source: DueDateSource.lastPeriod,
              ttcPath: TtcPath.ivf,
              ttcConfirmed: false),
          isFalse);
      expect(
          pregAfterTreatment(
              source: DueDateSource.scan,
              ttcPath: TtcPath.natural,
              ttcConfirmed: true),
          isFalse);
    });

    test('twins: "Carrying twins" leads the Scans tab; for one baby it is last',
        () {
      const h = PregHistory(twins: true);
      final led = kScansDoor.sectionsFor(kScansTabScan, 20, history: h);
      expect(led.first.heading, 'Carrying twins');
      expect(pvDoorSectionWhy(led.first, h),
          "First here, because you're expecting twins");
      final one = kScansDoor.sectionsFor(kScansTabScan, 20);
      expect(one.first.heading, isNot('Carrying twins'));
    });

    test('twins: the Labour card opens the birth page, and leads its section',
        () {
      final s = _section(kLabourDoor, 'If plans change on the day');
      expect(s.tiles.whereType<PvDoorToolTile>(), isEmpty,
          reason: 'it opened the whole Twins door');
      // It was already first in the writers' order, where the door card sat;
      // with twins it stays first, and nothing claims it moved.
      expect(_first(s, const PregHistory(twins: true)), 'preg_twins_read_birth');
      expect(pvDoorSectionWhy(s, const PregHistory(twins: true)), isNull);
    });

    test('a past C-section puts the VBAC page first, and says why', () {
      const h = PregHistory(pastCsection: true);
      final s = _section(kLabourDoor, 'If plans change on the day');
      expect(_first(s, h), 'preg_labour_read_vbac');
      expect(pvDoorSectionWhy(s, h),
          'Moved up, because you told us about a C-section before');
    });

    test('sugar or BP: the readings log leads Living with it, and says why', () {
      for (final h in const [PregHistory(sugar: true), PregHistory(bp: true)]) {
        final led =
            kComplicationsDoor.sectionsFor(kCondTabLiving, 20, history: h);
        expect(led.first.heading, 'Track your readings');
        expect(pvDoorSectionWhy(led.first, h), startsWith('First here'));
      }
      expect(kComplicationsDoor.sectionsFor(kCondTabLiving, 20).first.heading,
          isNot('Track your readings'));
    });

    test('sugar and BP lift their pages on Complications and Nutrition', () {
      const sugar = PregHistory(sugar: true);
      const bp = PregHistory(bp: true);
      expect(
          _first(_section(kComplicationsDoor, 'Middle months'), sugar), 'gdm');
      expect(
          _first(_section(kComplicationsDoor, 'Later months'), bp), 'high_bp');
      expect(
          _first(_section(kComplicationsDoor, 'Living with a condition'), sugar),
          'preg_cond_read_sugar_india');
      final food = _section(kNutritionDoor, 'Food for a health condition');
      expect(_first(food, sugar), 'gestational_diabetes');
      expect(_first(food, bp), 'high_bp_preeclampsia');
      // BP's food page was fifth and moves; sugar's was already first.
      expect(pvDoorSectionWhy(food, bp),
          'Moved up, because you told us about high blood pressure');
      expect(
          pvDoorSectionWhy(food, const PregHistory(sugar: true, bp: true)),
          'Moved up, because you told us about pregnancy sugar and high '
          'blood pressure');
      expect(pvDoorSectionWhy(food, sugar), isNull,
          reason: 'already first: nothing claims it moved');
    });

    test('order only: every lift is a permutation of the tiles', () {
      const all = PregHistory(
          afterTreatment: true,
          twins: true,
          pastCsection: true,
          sugar: true,
          bp: true);
      for (final p in kPvDoorPages) {
        for (final s in p.sections) {
          final out = s.tilesFor(20, history: all);
          expect(out.length, s.tilesFor(20).length, reason: s.heading);
          expect(out.toSet(), s.tilesFor(20).toSet(), reason: s.heading);
        }
        for (final g in p.groups) {
          expect(p.sectionsFor(g.id, 20, history: all).toSet(),
              p.sectionsFor(g.id, 20).toSet());
        }
      }
    });

    test('wiring gate: the door screen hands every fact in', () {
      final src =
          File('lib/screens/doors/pv_door_screen.dart').readAsStringSync();
      for (final f in [
        'afterTreatment: pregAfterTreatment(',
        'twins: pregExpectingTwins',
        'PregCondition.previousCsection',
        'BirthMode.cSection',
        'PregCondition.gestationalDiabetes',
        'PregCondition.hypertension',
        'history: _history',
      ]) {
        expect(src, contains(f), reason: f);
      }
    });
  });

  group('TTC: a child already at home', () {
    final notYet =
        kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_not_yet');
    final ivf =
        kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_infertility');

    test('the second-baby page is on Not yet, and leads there with a child', () {
      final time = [for (final s in notYet.sections) if (s.group == 'time') s];
      final out = ttcChildAtHomeOrderSections(time, true);
      final s = out.firstWhere(
          (s) => s.heading == 'How long does trying usually take?');
      expect(ttcTileKey(s.tiles.first),
          'ttc_tile_why_a_second_baby_can_take_longer');
      expect(ttcIsForChildAtHome(s.tiles.first, true), isTrue);
      expect(ttcIsForChildAtHome(s.tiles.first, false), isFalse);
      expect(ttcChildAtHomeOrderSections(time, false), same(time));
    });

    test('on IVF, "What about a second baby?" leads Age and second baby', () {
      final age = [for (final s in ivf.sections) if (s.group == 'age') s];
      final out = ttcChildAtHomeOrderSections(age, true);
      expect(out.first.heading, 'What about a second baby?');
      expect(out.length, age.length);
    });

    test('the Age and second baby tab moves up with a child at home', () {
      final groups = ivf.groups!;
      final out = ttcDoorOrderedGroups(groups,
          bracketId: ivf.bracketId, ageBand: null, childAtHome: true);
      expect(out[1].label, 'Age and second baby');
      expect(
          ttcDoorOrderedGroups(groups, bracketId: ivf.bracketId, ageBand: null),
          same(groups));
    });

    test('wiring gate: the door reads a child she added, not "trying again"',
        () {
      final src = File('lib/screens/ttc/doors/ttc_door_screen.dart')
          .readAsStringSync();
      expect(src, contains('ChildProfileStore.instance.hasRealChild'));
      expect(src, contains('ttcChildAtHomeOrderSections('));
      expect(src, contains('childAtHome: _childAtHome'));
    });
  });

  group('Content check', () {
    test('the retitled TTC pages carry the words of the cards that open them',
        () {
      const titles = {
        'ttc_read_stress_fertility': 'Can stress stop you getting pregnant?',
        'ttc_read_timing_myths':
            'How often to have sex, and the advice you can let go of',
        'ttc_read_trying_again': 'When to try again, and who decides',
        'ttc_read_heat_habits': 'Heat, habits and time: what changes sperm',
        'ttc_read_case_for_testing': 'The case for an early sperm test',
        'ttc_read_result_abnormal': 'If his first semen test is abnormal',
        'ttc_read_result_normal': 'If his semen result is normal',
        'ttc_read_three_months': 'What his three months of changes look like',
        'ttc_read_supplement_timing': 'When to start each supplement',
      };
      titles.forEach((id, title) {
        expect(ttcReadById(id)?.title.en, title, reason: id);
      });
    });

    test('Move gives the stop-and-call page one name', () {
      final names = {
        for (final s in kMoveDoor.sections)
          for (final t in s.tiles.whereType<PvDoorGuideTile>())
            if (t.readId == 'preg_move_read_when_to_stop') t.title,
      };
      expect(names, {'When to stop and call your doctor'});
    });
  });
}
