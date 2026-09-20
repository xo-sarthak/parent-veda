// =============================================================================
//  Food values — a number under every meal (2026-09-20)
// -----------------------------------------------------------------------------
//  The estimator is only worth having if it answers for every meal the
//  charts name and never reads absurdly. These hold both, plus the rules
//  that keep it a fact about the food rather than a target for her.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/diet_chart_content.dart';
import 'package:parentveda/data/nutrition/food_values.dart';
import 'package:parentveda/data/nutrition_data.dart';

void main() {
  group('every chart meal has a number', () {
    test('no meal in any chart is a miss', () {
      final misses = <String>[];
      for (final c in kChartContent.values) {
        for (final d in c.days) {
          for (final m in d.meals) {
            if (estimateMeal(m.items.en) == null) misses.add(m.items.en);
          }
        }
      }
      expect(misses, isEmpty, reason: 'add these dishes to kFoodValues');
    });

    test('every recipe estimates above zero, and none above a feast', () {
      for (final r in kRecipes) {
        final v = estimateRecipe(r);
        expect(v.kcal, greaterThan(10), reason: r.id);
        expect(v.kcal, lessThan(900), reason: '${r.id} reads like two meals');
        expect(v.protein, lessThan(60), reason: r.id);
      }
    });
  });

  group('the sentence rules', () {
    test('"X or Y" is one food, not two', () {
      final one = estimateMeal('Orange')!;
      final either = estimateMeal('Orange or sweet lime')!;
      expect(either.kcal, closeTo(one.kcal, 1));
    });

    test('a count word multiplies: two rotis is twice one roti', () {
      final one = estimateMeal('Dal with a roti')!;
      final two = estimateMeal('Dal with two rotis')!;
      final dal = estimateMeal('Dal')!;
      expect(two.kcal - dal.kcal, closeTo((one.kcal - dal.kcal) * 2, 2));
    });

    test('the longest phrase wins: curd rice is not curd plus rice', () {
      final cr = estimateMeal('Curd rice')!;
      final sum = estimateMeal('Curd')! + estimateMeal('Rice')!;
      expect(cr.kcal, isNot(closeTo(sum.kcal, 5)));
    });

    test('a tempering of spices is not an iron supplement', () {
      final v = estimateMeal('Cumin seeds')!;
      expect(v.iron, lessThan(1));
    });
  });

  group('the words', () {
    test('the glance is energy, protein, and one strength', () {
      final g = nutritionGlance(estimateMeal('Two boiled eggs, toast, milk')!);
      expect(g, startsWith('≈ '));
      expect(g, contains('kcal'));
      expect(g, contains('g protein'));
      expect(g.split('·').length, 3);
    });

    test('the reference is one line, in "roughly", and no surface draws a bar against it', () {
      expect(pregnancyReferenceLine(), contains('roughly'));
      for (final f in [
        'lib/screens/nutrition/door/nutrition_today_body.dart',
        'lib/screens/nutrition/door/meal_sheet.dart',
        'lib/screens/nutrition/door/diet_chart_plan_screen.dart',
        'lib/screens/nutrition/door/recipe_cook_screen.dart',
      ]) {
        final src = File(f).readAsStringSync();
        expect(src, isNot(contains('kPregnancyDayReference')), reason: '$f compares her plate to the reference');
        expect(src, isNot(contains('LinearProgressIndicator')), reason: '$f draws a bar');
      }
    });

    test('the estimate note is on every surface that shows the grid', () {
      final w = File('lib/screens/nutrition/door/nutrition_widgets.dart').readAsStringSync();
      expect(w, contains('kNutritionEstimateNote'));
    });
  });
}
