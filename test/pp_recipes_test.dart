// =============================================================================
//  Recipes: one browse, one recipe page, both on the shared tool shell
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/pp_recipe_docs/band_7_8m.dart';
import 'package:parentveda/screens/post_pregnancy/food_common.dart' show FoodPhotoCard, FoodThumb;
import 'package:parentveda/screens/post_pregnancy/food_recipe_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_common.dart';
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
    // The pilot was approved 2026-10-17: the whole band wears the doc format,
    // and every older dish keeps the old page and card.
    expect(kFoodRecipes.where((x) => x.docFormat).map((x) => x.id), [for (final b in kRecipeBand78m) b.id]);
  });

  // ---- the whole 7-8 month band (2026-10-17) ---------------------------------
  test('all 28 of the band are in, each a complete doc page', () {
    expect(kRecipeBand78m, hasLength(28));
    expect([for (final r in kRecipeBand78m) r.docId],
        [for (var i = 1; i <= 28; i++) '7-8M-REC-${i.toString().padLeft(2, '0')}']);
    for (final r in kRecipeBand78m) {
      expect(foodCatalog.where((x) => x.id == r.id), hasLength(1), reason: '${r.id} reaches the catalogue once');
      expect(r.amounts.length, r.ingredients.length, reason: r.id);
      expect(r.steps, isNotEmpty, reason: r.id);
      expect(r.nutrients, isNotEmpty, reason: r.id);
      expect(r.texture, isNotNull, reason: r.id);
      expect(r.mealRole, isNotNull, reason: r.id);
      expect(ppRecipeAgeRange(r.ageTag), isNotNull, reason: r.id);
    }
    // The two egg dishes are eggetarian, not vegetarian and not non-veg.
    final eggs = kRecipeBand78m.where((r) => r.egg).map((r) => r.docId);
    expect(eggs, ['7-8M-REC-07', '7-8M-REC-14']);
    expect(kRecipeBand78m.where((r) => r.egg).every((r) => !r.veg), isTrue);
  });

  test('a replaced dish leads to the dish that replaced it', () {
    expect(kFoodRecipeMoved, hasLength(6));
    kFoodRecipeMoved.forEach((old, now) {
      expect(foodCatalog.any((r) => r.id == old), isFalse, reason: '$old is retired');
      expect(foodRecipeById(old).id, now, reason: old);
    });
  });

  test('a saved or cooked old dish carries over to the new one', () {
    final store = FoodStore.instance;
    store.applyCloudData({
      'saved': ['tomatocarrotsoup', 'pp_7_8m_tomato_carrot_soup', 'ragipancake'],
      'cooked': ['idli_fingers'],
      'shopping': <String, bool>{},
      'vegOnly': false,
    });
    expect(store.isSaved('pp_7_8m_tomato_carrot_soup'), isTrue);
    expect(store.isSaved('tomatocarrotsoup'), isFalse);
    expect(store.saved.map((r) => r.id), ['pp_7_8m_tomato_carrot_soup', 'ragipancake'],
        reason: "one bookmark, not two, and never the catalogue's first dish");
    expect(store.recentlyCooked.single.id, 'pp_7_8m_soft_idli_pieces');
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
        findsWidgets,
        reason: cat,
      );
    }
    expect(t.takeException(), isNull);
  });

  // ---- no old look left on the doc page (the user, 2026-10-17: "old UI hints,
  // the lavender background some places, pink purple") ------------------------
  final oldLook = [ppPurple, ppPanel, ppMuted, ppHair, ppBorder].map((c) => c.toARGB32()).toSet();

  List<String> oldColours(Iterable<Widget> widgets) {
    final hits = <String>[];
    void check(Color? c, String where) {
      if (c != null && oldLook.contains(c.toARGB32())) hits.add('$where $c');
    }

    void box(Decoration? d, String where) {
      if (d is! BoxDecoration) return;
      check(d.color, '$where fill');
      final b = d.border;
      if (b is Border) {
        for (final s in [b.top, b.right, b.bottom, b.left]) {
          check(s.color, '$where border');
        }
      }
    }

    for (final w in widgets) {
      if (w is Icon) check(w.color, 'Icon');
      if (w is Text) check(w.style?.color, 'Text "${w.data}"');
      if (w is RichText) check(w.text.style?.color, 'RichText');
      if (w is Container) box(w.decoration, 'Container');
      if (w is DecoratedBox) box(w.decoration, 'DecoratedBox');
      if (w is AnimatedContainer) box(w.decoration, 'AnimatedContainer');
    }
    return hits;
  }

  for (final id in ['pp_7_8m_mixed_dal_khichdi', 'pp_7_8m_suji_kheer']) {
    testWidgets('$id: no lilac, lavender or purple anywhere on the page', (t) async {
      await _pump(t, FoodRecipeScreen(recipe: foodRecipeById(id)));
      expect(oldColours(t.allWidgets), isEmpty);
      // The tinted stripes (peach, lavender, blush) never stand in for a photo.
      expect(find.byType(FoodThumb), findsNothing);
      await t.scrollUntilVisible(find.byKey(const ValueKey('pp_recipe_doc_related')), 300,
          scrollable: find.byType(Scrollable).first);
      expect(oldColours(t.allWidgets), isEmpty);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('the doc cards in a rail carry no old colour either', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 228)));
    await _pump(t, const PpRecipesScreen());
    final cards = find.byType(FoodPhotoCard);
    expect(cards, findsWidgets);
    expect(find.descendant(of: cards.first, matching: find.byType(FoodThumb)), findsNothing);
    final inCards = find.descendant(of: cards, matching: find.byWidgetPredicate((_) => true));
    expect(oldColours(inCards.evaluate().map((e) => e.widget)), isEmpty);
  });
}
