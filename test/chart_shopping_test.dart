// A diet chart's meals become a shopping list (2026-09-30, the PDF's "7-day plan
// she can follow, day by day ... with a shopping list button").
//
// The ingredient names are for a NUTRITIONIST TO VERIFY (docs/STILL-OPEN.md
// §81.20). These tests pin the structure, not the nutrition: that nothing is left
// without a list, that pantry basics never appear, and that the parsing rules do
// what their comments say.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/diet_chart_content.dart';
import 'package:parentveda/data/nutrition/chart_ingredients.dart';
import 'package:parentveda/data/nutrition_data.dart';
import 'package:parentveda/screens/nutrition/door/diet_chart_plan_screen.dart';
import 'package:parentveda/screens/nutrition/door/shopping_list_screen.dart';
import 'package:parentveda/services/nutrition_day_store.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the meal reader', () {
    test('every meal of every chart says what to buy', () {
      var meals = 0;
      for (final e in kChartContent.entries) {
        for (final d in e.value.days) {
          for (final m in d.meals) {
            meals++;
            expect(chartMealIngredients(m.items.en), isNotEmpty, reason: '${e.key}: ${m.items.en}');
          }
        }
      }
      expect(meals, greaterThan(200));
    });

    test('every chart the door lists has content, and every day of it has a list', () {
      for (final c in kDietCharts) {
        final content = kChartContent[c.id];
        if (content == null) continue; // "still being written" is the screen's own state
        for (final d in content.days) {
          expect(chartDayIngredients(d), isNotEmpty, reason: '${c.id} ${d.label.en}');
        }
        expect(chartWeekIngredients(content), isNotEmpty, reason: c.id);
      }
    });

    test('pantry basics are never a thing to buy', () {
      const basics = ['salt', 'oil', 'water', 'sugar', 'tea'];
      for (final e in kChartContent.entries) {
        for (final i in chartWeekIngredients(e.value)) {
          for (final b in basics) {
            // "Mustard oil" is a named ingredient of one Bengali line; "Coconut
            // water", "Lemon water" and "Buttermilk" are the point of theirs.
            if (i == 'Mustard oil' || i.startsWith('Coconut water')) continue;
            expect(RegExp('\\b$b\\b', caseSensitive: false).hasMatch(i), isFalse, reason: '${e.key}: $i');
          }
        }
      }
    });

    test('a named vegetable replaces "seasonal vegetables", not joins it', () {
      expect(chartMealIngredients('Dal with rice, lauki sabzi'), contains('Bottle gourd (lauki)'));
      expect(chartMealIngredients('Dal with rice, lauki sabzi'), isNot(contains('Seasonal vegetables')));
      expect(chartMealIngredients('Dal with rice, one light sabzi'), contains('Seasonal vegetables'));
    });

    test('a named fruit replaces "seasonal fruit", and "papaya is best avoided" is not a purchase', () {
      final r = chartMealIngredients('A seasonal fruit: banana, or orange, apple or chikoo (papaya is best avoided)');
      expect(r, containsAll(['Bananas', 'Apples', 'Chikoo']));
      expect(r, isNot(contains('Seasonal fruit')));
      expect(r.any((i) => i.toLowerCase().contains('papaya')), isFalse);
    });

    test('milk does not fire inside buttermilk, and a food the chart leaves out is not bought', () {
      expect(chartMealIngredients('Buttermilk with jeera'), isNot(contains('Milk')));
      expect(chartMealIngredients('Dry cornflakes, no milk yet'), ['Cornflakes']);
      expect(chartMealIngredients('Oats porridge with almonds, no dates'), isNot(contains('Dates')));
    });

    test('a makki or ragi roti is made of its own flour, not atta', () {
      final m = chartMealIngredients('Sarson saag with makki roti, curd');
      expect(m, contains('Makki atta (maize flour)'));
      expect(m, isNot(contains('Whole wheat flour (atta)')));
      final r = chartMealIngredients('Ragi roti with dal and sabzi');
      expect(r, contains('Ragi flour'));
      expect(r, isNot(contains('Whole wheat flour (atta)')));
      expect(chartMealIngredients('Two rotis, dal'), contains('Whole wheat flour (atta)'));
    });

    test('fish keeps the chart\'s own safety words, and the list adds no food', () {
      expect(chartMealIngredients('Fish curry with rice, well cooked'),
          contains('Fish (a low-mercury kind: rohu, surmai or pomfret)'));
      expect(chartMealIngredients('Coconut water, or lemon water with a pinch of salt'),
          ['Coconut water (tender coconut)', 'Lemons']);
    });

    test('a day is each thing once, and the week is each thing once', () {
      final veg = kChartContent['vegetarian_chart']!;
      final day = chartDayIngredients(veg.days.first);
      expect(day.toSet().length, day.length);
      final week = chartWeekIngredients(veg);
      expect(week.toSet().length, week.length);
      expect(week.length, greaterThanOrEqualTo(day.length));
      expect(day, contains('Paneer'));
      expect(day, contains('Rajma'));
    });
  });

  group('the list', () {
    test('a chart day files under its own id, which round-trips', () {
      expect(chartListId('vegetarian_chart', dayIndex: 1), 'chart:vegetarian_chart:d2');
      expect(chartListId('vegetarian_chart'), 'chart:vegetarian_chart');
      expect(parseChartListId('chart:vegetarian_chart:d2')!.dayIndex, 1);
      expect(parseChartListId('chart:vegetarian_chart')!.dayIndex, isNull);
      expect(parseChartListId('some_recipe_id'), isNull, reason: 'a recipe id is never a chart id');
      for (final r in kRecipes) {
        expect(isChartListId(r.id), isFalse, reason: r.id);
      }
    });

    test('the list names a chart group by chart and day, and a recipe by its name', () {
      expect(shoppingGroupTitle('chart:vegetarian_chart:d2'), contains('Day 2'));
      expect(shoppingGroupTitle('chart:vegetarian_chart'), contains('every day'));
      expect(shoppingGroupTitle(kRecipes.first.id), kRecipes.first.name.en);
      expect(shoppingGroupTitle('unknown_id'), 'unknown_id');
    });
  });

  group('the button', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final s = NutritionDayStore.instance;
      s.removeRecipeFromList(chartListId('vegetarian_chart', dayIndex: 0));
      s.removeRecipeFromList(chartListId('vegetarian_chart'));
      await s.init();
    });

    Future<void> pump(WidgetTester t) async {
      t.view.physicalSize = const Size(360, 2400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      final chart = kDietCharts.firstWhere((c) => c.id == 'vegetarian_chart');
      await t.pumpWidget(MaterialApp(home: DietChartPlanScreen(chart: chart)));
      await t.pump(const Duration(milliseconds: 300));
    }

    testWidgets('shows what Day 1 needs and adds it under Day 1, once', (t) async {
      await pump(t);
      final day1 = chartDayIngredients(kChartContent['vegetarian_chart']!.days.first);
      expect(find.text('To buy for Day 1'), findsOneWidget);
      expect(find.text('Paneer'), findsWidgets);
      await t.ensureVisible(find.byKey(const ValueKey('chart_add_day')));
      await t.tap(find.byKey(const ValueKey('chart_add_day')));
      await t.pump();
      final on = NutritionDayStore.instance.shopping.where((s) => s.recipeId == 'chart:vegetarian_chart:d1');
      expect(on.map((s) => s.name).toSet(), day1.toSet());
      expect(find.textContaining('On your list'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('"Add all days" files every day under the chart, and can be read back as text', (t) async {
      await pump(t);
      await t.ensureVisible(find.byKey(const ValueKey('chart_add_week')));
      await t.tap(find.byKey(const ValueKey('chart_add_week')));
      await t.pump();
      final week = chartWeekIngredients(kChartContent['vegetarian_chart']!);
      final on = NutritionDayStore.instance.shopping.where((s) => s.recipeId == 'chart:vegetarian_chart');
      expect(on.map((s) => s.name).toSet(), week.toSet());
      expect(find.textContaining('Every day is on your list'), findsOneWidget);
    });

    testWidgets('fits at 320 wide with large text', (t) async {
      t.view.physicalSize = const Size(320, 2400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      final chart = kDietCharts.firstWhere((c) => c.id == 'vegetarian_chart');
      await t.pumpWidget(MaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(size: Size(320, 2400), textScaler: TextScaler.linear(1.3)),
            child: DietChartPlanScreen(chart: chart)),
      ));
      await t.pump(const Duration(milliseconds: 300));
      expect(t.takeException(), isNull);
    });
  });

  test('the button is on the screen and the nutritionist note is where the tables are', () {
    final screen = _code('lib/screens/nutrition/door/diet_chart_plan_screen.dart');
    expect(screen, contains('chartDayIngredients('));
    expect(screen, contains("ValueKey('chart_add_day')"));
    final src = File('lib/data/nutrition/chart_ingredients.dart').readAsStringSync();
    expect(src, contains('NUTRITIONIST TO VERIFY'));
  });
}
