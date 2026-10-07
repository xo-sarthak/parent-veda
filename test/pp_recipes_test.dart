// =============================================================================
//  Recipes: one browse, one recipe page, both on the shared tool shell
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
