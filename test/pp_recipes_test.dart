// =============================================================================
//  Recipes: one browse, one recipe page, both on the shared tool shell
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/food_common.dart' show FoodPhotoCard;
import 'package:parentveda/screens/post_pregnancy/food_recipe_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_recipes_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(360 * 3, 3600 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.5)), child: MaterialApp(home: w)));
  await t.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('age tags read as ranges', () {
    expect(ppRecipeAgeRange('6 to 12 mo'), (6, 12));
    expect(ppRecipeAgeRange('12 mo+'), (12, 999));
    expect(ppRecipeAgeRange('6+ mo'), (6, 999));
  });

  testWidgets('browse: rails for the age, search turns into a grid', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 400)));
    await _pump(t, const PpRecipesScreen());
    expect(find.byType(PregToolScaffold), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_recipes_for_now')), findsOneWidget);
    await t.enterText(find.byKey(const ValueKey('pp_recipes_search')), 'ragi');
    await t.pumpAndSettle();
    expect(find.textContaining('agi'), findsWidgets);
    expect(t.takeException(), isNull);
  });

  testWidgets('a recipe page: stats, save, list, steps', (t) async {
    await _pump(t, FoodRecipeScreen(recipe: kFoodRecipes.first));
    expect(find.byType(PregToolScaffold), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_recipe_save')), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Steps'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  // ---- the Drive doc format, piloted on Mixed dal khichdi (2026-10-15) -------
  FoodRecipe khichdi() => kFoodRecipes.firstWhere((r) => r.id == 'pp_7_8m_mixed_dal_khichdi');

  test('the pilot dish is in the catalogue the app reads, copied from the doc', () {
    final r = foodCatalog.firstWhere((r) => r.id == 'pp_7_8m_mixed_dal_khichdi');
    expect(r.docId, '7-8M-REC-11');
    expect(r.docFormat, isTrue);
    expect(r.amounts.length, r.ingredients.length, reason: 'the How much column runs parallel to the items');
    expect(r.steps, hasLength(4));
    expect([r.inCategory('Lunch'), r.inCategory('Dinner'), r.inCategory('First Foods')], everyElement(isTrue));
    expect(ppRecipeAgeRange(r.ageTag), (7, 8));
    // Every older dish keeps the old page and card until the pilot is approved.
    expect(kFoodRecipes.where((x) => x.docFormat).map((x) => x.id), ['pp_7_8m_mixed_dal_khichdi']);
  });

  test('water never lands on the shopping list', () {
    expect(foodShoppable('Water'), isFalse);
    expect(foodShoppable('Water or breastmilk/formula'), isFalse);
    expect(foodShoppable('Rice'), isTrue);
    expect(foodShoppable('3 tbsp milk or water'), isTrue);
  });

  testWidgets('the doc page renders every doc section, for the child the age fits', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 228)));
    await _pump(t, FoodRecipeScreen(recipe: khichdi()));
    expect(find.byKey(const ValueKey('pp_recipe_doc_page')), findsOneWidget);
    expect(find.byType(PregToolScaffold), findsNothing);
    for (final h in [
      'Why this is good for him',
      'What you need',
      'How to make it',
      'What’s in it',
      'Good to know',
      'Take care',
      'You can swap',
      'More on ParentVeda',
    ]) {
      await t.scrollUntilVisible(find.text(h), 300, scrollable: find.byType(Scrollable).first);
      expect(find.text(h), findsOneWidget, reason: h);
    }
    await t.scrollUntilVisible(find.byKey(const ValueKey('pp_recipe_doc_agefit')), -300, scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Right for'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('the age-fit line follows a younger child, derived not asked', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 155)));
    await _pump(t, FoodRecipeScreen(recipe: khichdi()));
    expect(find.textContaining('One to keep for when he gets there'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('each ingredient adds itself to the list, water has no button', (t) async {
    await _pump(t, FoodRecipeScreen(recipe: khichdi()));
    final add = find.byKey(const ValueKey('pp_recipe_add_Rice'));
    await t.scrollUntilVisible(add, 300, scrollable: find.byType(Scrollable).first);
    await t.tap(add);
    await t.pump();
    expect(FoodStore.instance.shopping.containsKey('Rice'), isTrue);
    await t.tap(add);
    await t.pump();
    expect(FoodStore.instance.shopping.containsKey('Rice'), isFalse);
    expect(find.byKey(const ValueKey('pp_recipe_add_Water')), findsNothing);
    expect(find.text('½ tbsp (about 6 g)'), findsNWidgets(2));
  });

  testWidgets('cook step by step walks all four steps', (t) async {
    await _pump(t, FoodRecipeScreen(recipe: khichdi()));
    await t.tap(find.byKey(const ValueKey('pp_recipe_cook')));
    await t.pumpAndSettle();
    expect(find.text('STEP 1 OF 4'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await t.tap(find.byType(FilledButton));
      await t.pumpAndSettle();
    }
    expect(find.text('Enjoy it.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('the new card leads the Lunch, Dinner and First Foods rails', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 228)));
    await _pump(t, const PpRecipesScreen());
    for (final cat in ['First Foods', 'Lunch', 'Dinner']) {
      final rail = find.byKey(ValueKey('pp_recipes_rail_$cat'));
      await t.scrollUntilVisible(rail, 300, scrollable: find.byType(Scrollable).first);
      expect(
        find.descendant(of: rail, matching: find.byType(FoodPhotoCard)),
        findsOneWidget,
        reason: cat,
      );
    }
    expect(t.takeException(), isNull);
  });
}
