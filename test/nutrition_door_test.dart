// =============================================================================
//  Nutrition door — 2026-09-20
// -----------------------------------------------------------------------------
//   1. The plate is deterministic for a date, different across days, and its
//      meals come from the chart it names.
//   2. The chart chosen respects her: a vegetarian never gets the
//      non-vegetarian chart; a GDM condition wins; nothing falls through to
//      nothing.
//   3. Every worked day has meals, so a plate is never empty.
//   4. Swaps come from the chart, never repeat the current meal.
//   5. Recipe suitability: vegetarian sees no fish; eggetarian sees no meat.
//   6. Needs: five, each with foods behind it.
//   7. The store: glasses fill and empty by tap rule; ticks toggle; the
//      seven-day count never reads as a streak (it counts, it does not
//      compare); the blob round-trips.
//   8. Reachability: the home opens the day door; the door reaches the
//      meal sheet, needs, recipes, list, preference and the library.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parentveda/data/diet_chart_content.dart';
import 'package:parentveda/data/diet_chart_facets.dart';
import 'package:parentveda/data/nutrition/nutrition_photos.dart';
import 'package:parentveda/data/nutrition/nutrition_plate.dart';
import 'package:parentveda/data/nutrition_data.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/services/nutrition_day_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('the plate', () {
    test('is deterministic for a date and changes across days', () {
      final a = plateFor(DateTime(2026, 9, 20), week: 20);
      final b = plateFor(DateTime(2026, 9, 20), week: 20);
      final c = plateFor(DateTime(2026, 9, 21), week: 20);
      expect(a.dayIndex, b.dayIndex);
      expect(a.chart.id, c.chart.id);
      expect(a.dayIndex == c.dayIndex, isFalse);
      expect(a.meals, isNotEmpty);
      for (final m in a.meals) {
        expect(m.chartId, a.chart.id);
        expect(m.items.trim(), isNotEmpty);
      }
    });

    test('every chart with content has meals on every day', () {
      for (final e in kChartContent.entries) {
        expect(e.value.days, isNotEmpty, reason: e.key);
        for (final d in e.value.days) {
          expect(d.meals, isNotEmpty, reason: '${e.key} ${d.label.en}');
        }
      }
    });

    test('a vegetarian never gets the non-vegetarian chart; GDM wins', () {
      final veg = plateChartFor(week: 20, diet: DietPreference.vegetarian);
      expect(facetsFor(veg.id).diet, isNot(ChartDiet.nonVegetarian));
      final jain = plateChartFor(week: 20, diet: DietPreference.jain);
      expect(facetsFor(jain.id).diet, anyOf(isNull, ChartDiet.jain));
      final gdm = plateChartFor(week: 30, diet: DietPreference.vegetarian, condition: ChartCondition.gestationalDiabetes);
      expect(facetsFor(gdm.id).condition, ChartCondition.gestationalDiabetes);
      final none = plateChartFor(week: 10, diet: DietPreference.nonVegetarian, region: ChartRegion.bengali);
      expect(kChartContent.containsKey(none.id), isTrue);
      // no condition → never a condition chart
      expect(facetsFor(plateChartFor(week: 20).id).condition, isNull);
    });

    test('swaps come from the chart and never repeat the meal', () {
      final p = plateFor(DateTime(2026, 9, 20), week: 20);
      for (final m in p.meals) {
        final s = p.swapsFor(m);
        expect(s, isNotEmpty, reason: m.key);
        expect(s.contains(m.items), isFalse);
        expect(s.toSet().length, s.length);
      }
    });
  });

  group('a dish photo for a meal sentence', () {
    test('the dish beats the bread or rice it comes with', () {
      // Seen on the phone 2026-09-20: dinner wore lunch's thali because
      // 'roti' was matched before 'paneer'.
      expect(nutritionDishIdFor('Paneer bhurji with roti'), 'nut_paneer');
      expect(nutritionDishIdFor('Dal, methi sabzi, two rotis, salad'), 'nut_dal');
      expect(nutritionDishIdFor('Curd rice with pickle'), 'nut_curd_rice');
      expect(nutritionDishIdFor('Two rotis with lauki sabzi'), 'nut_roti_sabzi');
      expect(nutritionDishIdFor('Curd with flaxseed'), 'nut_curd');
      expect(nutritionDishIdFor('A cup of warm water'), isNull);
    });
  });

  group('recipes and needs', () {
    test('diet is respected', () {
      for (final r in kRecipes) {
        if (r.id.contains('macher')) {
          expect(recipeSuits(r, DietPreference.vegetarian), isFalse);
          expect(recipeSuits(r, DietPreference.eggetarian), isFalse);
          expect(recipeSuits(r, DietPreference.nonVegetarian), isTrue);
        }
        expect(recipeSuits(r, null), isTrue);
      }
    });

    test('five needs, each with foods behind it', () {
      expect(kPlateNeeds.length, 5);
      for (final n in kPlateNeeds) {
        expect(plateFoodsFor(n), isNotEmpty, reason: n.id);
      }
      expect(plateRecipesFor(kPlateNeeds.first), isNotEmpty);
    });
  });

  group('the store', () {
    final store = NutritionDayStore.instance;
    setUp(store.resetForTest);
    final d = DateTime(2026, 9, 20);

    test('glasses fill up to the tap and empty on the last one', () {
      store.tapGlass(d, 3);
      expect(store.day(d).water, 4);
      store.tapGlass(d, 3);
      expect(store.day(d).water, 3);
      store.tapGlass(d, 7);
      expect(store.day(d).water, 8);
    });

    test('ticks toggle and the week count counts, nothing more', () {
      store.toggleTick(d, 'iron');
      expect(store.ticked(d, 'iron'), isTrue);
      store.toggleTick(d.subtract(const Duration(days: 2)), 'iron');
      expect(store.daysTicked('iron', now: d), 2);
      store.toggleTick(d, 'iron');
      expect(store.daysTicked('iron', now: d), 1);
    });

    test('a swap clears a skip; the blob round-trips', () {
      store.toggleSkip(d, 'k');
      expect(store.isSkipped(d, 'k'), isTrue);
      store.setSwap(d, 'k', 'Poha');
      expect(store.isSkipped(d, 'k'), isFalse);
      store.logCraving('sweet');
      store.logCraving('sweet');
      store.addToList('r1', ['moong', 'ghee']);
      store.setRegion(ChartRegion.gujarati);
      final blob = store.cloudData();
      store.resetForTest();
      store.applyCloudData(blob);
      expect(store.swapFor(d, 'k'), 'Poha');
      expect(store.cravingPattern(now: DateTime.now())?.kind, 'sweet');
      expect(store.shopping.length, 2);
      expect(store.region, ChartRegion.gujarati);
    });
  });

  group('reachability', () {
    final home = File('lib/screens/home_v3_screen.dart').readAsStringSync();
    final door = File('lib/screens/nutrition/door/nutrition_door.dart').readAsStringSync();

    test('the day is the first tab, not a screen of its own', () {
      // 2026-09-20: the standalone day screen stands down for one door
      // language; the router renders NutritionTodayBody on the first tab.
      expect(door, contains('const bool kNutritionDoorAsDay = false;'));
      final router = File('lib/screens/doors/pv_door_router.dart').readAsStringSync();
      expect(router, contains('kDietSurfaceToday => NutritionTodayBody(pregnancy: c)'));
      expect(router, contains('kDietSurfaceRecipeRail => RecipesGridBody(pregnancy: c)'));
      expect(router, contains('kDietSurfaceExperts => NutritionTalkBody(pregnancy: c)'));
      expect(home, contains('kNutritionBracketId && kNutritionDoorAsDay'));
    });

    test('the today body reaches every leaf', () {
      final body = File('lib/screens/nutrition/door/nutrition_today_body.dart').readAsStringSync();
      for (final s in ['showMealSheet(', 'NeedScreen(need: n', 'showPreferenceSheet(context', 'CravingDetailScreen(item', 'DietChartPlanScreen(chart']) {
        expect(body, contains(s), reason: s);
      }
    });

    test('the standalone door still reaches every leaf (kept for revert)', () {
      for (final s in [
        'showMealSheet(',
        'NeedScreen(need: n',
        'openRecipe(context',
        'RecipesScreen(pregnancy',
        'ShoppingListScreen()',
        'showPreferenceSheet(context',
        'DietChartsScreen(pregnancy',
        'FastingScreen()',
        'NutrientsScreen()',
        'CanIScreen(controller',
        'CravingDetailScreen(item',
        'ExpertOptionsBlock()',
      ]) {
        expect(door, contains(s), reason: s);
      }
    });
  });
}
