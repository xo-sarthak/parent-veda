// The pregnancy home's door tiles lead with what she chose and what her week
// needs (2026-09-30, gap analysis "Order the door tiles by her week and her
// answers"): choices first, then the trimester, then the table's own order.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/brackets/pregnancy_brackets.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/services/preg_tile_order.dart';

List<String> _ids(int week, [Set<PregPriority> chose = const {}]) => [
      for (final b in orderPregnancyTiles(kPregnancyBrackets, week: week, priorities: chose)) b.id,
    ];

void main() {
  final table = [for (final b in kPregnancyBrackets) b.id];

  group('the rule', () {
    test('second trimester and no answers: the table order, untouched', () {
      expect(_ids(20), table);
    });

    test('first trimester leads with Symptoms, Is it safe?, Scans & tests', () {
      expect(_ids(8).take(3), ['pregnancy_symptoms', 'pregnancy_is_it_safe', 'pregnancy_scans_tests']);
      expect(_ids(13).take(3), ['pregnancy_symptoms', 'pregnancy_is_it_safe', 'pregnancy_scans_tests']);
      // …and the rest keep the table's order behind them.
      final rest = _ids(8).skip(3).toList();
      expect(rest, [
        for (final id in table)
          if (!{'pregnancy_symptoms', 'pregnancy_is_it_safe', 'pregnancy_scans_tests'}.contains(id)) id,
      ]);
    });

    test('Labour prep leads from week 32, and not before', () {
      expect(_ids(32).first, 'pregnancy_labour');
      expect(_ids(40).first, 'pregnancy_labour');
      expect(_ids(31), table, reason: 'the PDF names nothing for weeks 14 to 31');
      expect(_ids(28), table);
    });

    test('her onboarding choices come before the trimester', () {
      // Week 8 would lead with Symptoms; she asked for food and worry.
      final o = _ids(8, {PregPriority.nutrition, PregPriority.anxiety});
      expect(o.take(2), ['pregnancy_nutrition', 'pregnancy_mental_health'],
          reason: 'her choices lead, in the table order between themselves');
      expect(o.skip(2).take(3), ['pregnancy_symptoms', 'pregnancy_is_it_safe', 'pregnancy_scans_tests']);
    });

    test('a chosen door that is also the trimester lead sits once, in her tier', () {
      final o = _ids(34, {PregPriority.birthPrep});
      expect(o.first, 'pregnancy_labour');
      expect(o.where((i) => i == 'pregnancy_labour').length, 1);
    });

    test('two answers pointing at one door do not duplicate it', () {
      final o = _ids(20, {PregPriority.sleep, PregPriority.symptoms});
      expect(o.first, 'pregnancy_symptoms');
      expect(o.length, table.length);
    });
  });

  group('ranking, never hiding', () {
    test('every bracket comes back exactly once, whatever the week or answers', () {
      for (var week = 1; week <= 42; week++) {
        for (final chose in [
          <PregPriority>{},
          {PregPriority.nutrition},
          Set<PregPriority>.of(PregPriority.values),
        ]) {
          final o = _ids(week, chose);
          expect(o.length, table.length, reason: 'week $week');
          expect(o.toSet(), table.toSet(), reason: 'week $week');
        }
      }
    });

    test('every onboarding answer points at a door that exists', () {
      for (final p in PregPriority.values) {
        expect(kPregPriorityDoor[p], isNotNull, reason: '$p has no door');
        expect(table, contains(kPregPriorityDoor[p]), reason: '$p points at a missing door');
      }
    });

    test('the same inputs always give the same order', () {
      expect(_ids(33, {PregPriority.fitness}), _ids(33, {PregPriority.fitness}));
    });
  });

  group('wired', () {
    test('the home orders its doors through the rule, by the week she is in', () {
      final src = File('lib/screens/home_v3_screen.dart')
          .readAsStringSync()
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(src, contains('orderPregnancyTiles('));
      expect(src, contains('pregnancy.currentWeek'),
          reason: 'the strip is a browsing tool: tiles must not follow the selected day');
      expect(src, contains('FamilyProfileStore.instance,'),
          reason: 'a change in Profile has to reorder the tiles');
    });
  });
}
