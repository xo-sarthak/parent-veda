// =============================================================================
//  Nutrition — the user's second-pass changes, 2026-09-22
// -----------------------------------------------------------------------------
//  Walked on the phone by the user (STILL-OPEN §70.8). These pin:
//    · Swap opens the swap sheet, the row opens the meal sheet — two sheets
//    · the meal sheet says the numbers once: no "Strong in" heading
//    · a plate row washes with the door's tint when its dish changes
//    · the five needs wear five hues, and the tick shows the reference
//    · the recipe grid carries a legend; bucket tiles wear marks, nine hues
//    · the recipe page: facts line and marks above Ingredients; the grid
//      and the fact below Method
//    · a chart day's dish opens the (read-only) meal sheet
//    · a craving opens as a read
//    · Eating your way is not a section; the preference row sits under the
//      plate's heading and under "What are you after?"
//    · Today and What to eat now wear the sun and the cutlery
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_nutrition.dart';
import 'package:parentveda/data/nutrition/nutrition_plate.dart';
import 'package:parentveda/data/nutrition_data.dart';
import 'package:parentveda/screens/brackets/hub/hub_intent_art.dart';
import 'package:parentveda/screens/nutrition/door/meal_sheet.dart';
import 'package:parentveda/screens/nutrition/door/nutrition_today_body.dart';
import 'package:parentveda/screens/nutrition/door/nutrition_widgets.dart';
import 'package:parentveda/screens/nutrition/door/recipe_cook_screen.dart';
import 'package:parentveda/screens/nutrition/door/recipes_screen.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/nutrition_day_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  group('the plate', () {
    late PregnancyController c;
    setUp(() async {
      c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));
      await NutritionDayStore.instance.init();
    });

    testWidgets('Swap opens the swap sheet; the row opens the meal sheet', (tester) async {
      await pump(tester, NutritionTodayBody(pregnancy: c));
      expect(find.byType(PlateRow), findsWidgets);

      await tester.tap(find.text('Swap').first);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.textContaining('Instead of'), findsOneWidget, reason: 'the swap sheet leads with the alternatives');
      expect(find.text('This meal, estimated'), findsNothing);
      await tester.tapAt(const Offset(180, 40));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      await tester.tap(find.byType(PlateRow).first);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('This meal, estimated'), findsOneWidget, reason: 'the numbers, once');
      expect(find.text('STRONG IN'), findsNothing);
      expect(find.text('Strong in'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Swap'), findsOneWidget);
    });

    testWidgets('a row washes with the tint when its dish changes', (tester) async {
      final p = V2PaletteStore.instance.current;
      Widget row(String items) => PlateRow(
          p: p, slot: 'Lunch', items: items, swapped: false, skipped: false, onTap: () {}, onSwap: () {});
      await pump(tester, row('Dal with two rotis'));
      Color? wash() {
        final c = tester.widgetList<Container>(find.descendant(of: find.byType(PlateRow), matching: find.byType(Container))).first;
        return (c.decoration as BoxDecoration?)?.color;
      }
      expect(wash()?.a ?? 0, 0, reason: 'no flash on first paint');
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: row('Rajma with rice')))));
      await tester.pump(const Duration(milliseconds: 180));
      expect(wash()!.a, greaterThan(0), reason: 'the wash rises on a change');
      await tester.pump(const Duration(milliseconds: 1200));
      expect(wash()!.a, 0, reason: 'and fades');
    });

    testWidgets('Eating your way is a row under the plate, not a section', (tester) async {
      await pump(tester, NutritionTodayBody(pregnancy: c));
      expect(find.text('Eating your way'), findsNothing);
      expect(find.byType(NutritionPreferenceRow), findsOneWidget);
      expect(find.text('Tap to change'), findsOneWidget);
      final row = tester.getRect(find.byType(NutritionPreferenceRow));
      final plate = tester.getRect(find.text('Your plate'));
      final firstRow = tester.getRect(find.byType(PlateRow).first);
      expect(row.top, greaterThan(plate.top));
      expect(row.top, lessThan(firstRow.top));
      // The chart's name is a heading now, not a grey line.
      expect(find.text('THIS PLATE FOLLOWS'), findsOneWidget);
      expect(find.text('See the week'), findsOneWidget);
    });

    testWidgets('the five needs wear five hues and show the reference', (tester) async {
      await pump(tester, NutritionTodayBody(pregnancy: c));
      final hues = kPlateNeeds.map((n) => nutritionNeedHue(n.id)).toSet();
      expect(hues.length, 5, reason: 'one colour per nutrient');
      expect(find.text('27 mg'), findsOneWidget, reason: 'iron, under its tick');
      expect(find.text('60 g'), findsOneWidget, reason: 'protein');
      expect(find.textContaining('A day in pregnancy asks for roughly'), findsNothing,
          reason: 'the paragraph left; the numbers are under the ticks');
      // Across the width: the five tiles span the gutter, not the left half.
      final tiles = tester.getRect(find.byType(NeedTile).last);
      expect(tiles.right, greaterThan(300));
    });
  });

  group('recipes', () {
    late PregnancyController c;
    setUp(() => c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140))));

    test('nine buckets, nine marks, nine hues', () {
      final marks = kRecipeBuckets.map(recipeBucketMark).toSet();
      final hues = kRecipeBuckets.map(recipeBucketHue).toSet();
      expect(marks.length, kRecipeBuckets.length);
      expect(hues.length, kRecipeBuckets.length);
      expect(recipeBucketMark(RecipeMeal.breakfast), IntentMark.chaiMark);
      expect(recipeBucketMark(RecipeKind.sweet), IntentMark.sweetMark);
    });

    testWidgets('the grid carries the legend and the preference row', (tester) async {
      await pump(tester, RecipesGridBody(pregnancy: c));
      expect(find.byType(NutritionMarkLegend), findsOneWidget);
      expect(find.byType(NutritionPreferenceRow), findsOneWidget);
    });

    testWidgets('the recipe page: recipe first, the numbers once above, in full below', (tester) async {
      final r = kRecipes.firstWhere((r) => r.fact != null);
      await tester.pumpWidget(MaterialApp(home: RecipeCookScreen(recipe: r, pregnancy: c)));
      await tester.pump(const Duration(milliseconds: 300));
      final ingredients = tester.getRect(find.text('Ingredients'));
      final facts = tester.getRect(find.textContaining('serves '));
      expect(facts.top, lessThan(ingredients.top), reason: 'the facts line under the title');
      expect(find.text('Strong in'), findsNothing);
      expect(find.text('STRONG IN'), findsNothing);
      // The grid and the fact sit below the method — reached by scrolling
      // past it (a sliver list builds only what is on screen).
      expect(find.text('Per serving, estimated'), findsNothing, reason: 'not above the fold');
      var sawMethod = false;
      for (var i = 0; i < 14 && find.text('Per serving, estimated').evaluate().isEmpty; i++) {
        if (find.text('Method').evaluate().isNotEmpty) sawMethod = true;
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
        await tester.pump();
      }
      expect(sawMethod, isTrue, reason: 'the method came before the grid');
      expect(find.text('Per serving, estimated'), findsOneWidget);
      for (var i = 0; i < 4 && find.text('Did you know').evaluate().isEmpty; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await tester.pump();
      }
      expect(find.text('Did you know'), findsOneWidget);
    });
  });

  group('the door', () {
    test('Today wears the sun, What to eat now the cutlery', () {
      final groups = kNutritionDoor.groups;
      expect(groups.firstWhere((g) => g.id == kDietTabToday).mark, IntentMark.sunMark);
      expect(groups.firstWhere((g) => g.id == kDietTabNow).mark, IntentMark.forkMark);
    });

    test('a recipe for a dish on the plate, when the library has one', () {
      expect(recipeForMeal('Idli with sambar and chutney'), isNotNull);
      expect(recipeForMeal('Vegetable upma, a banana'), isNotNull);
      expect(recipeForMeal('Plain water'), isNull);
    });
  });
}
