// Functional test for the revised Recipes flow. The filter queries (the real
// logic behind the chips) are unit-tested directly; a widget test taps a
// Sick-day situation chip and confirms the visible meal list swaps.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_recipes_data.dart';
import 'package:parentveda/screens/post_pregnancy/sick_days_screen.dart';

void main() {
  group('recipe filter queries', () {
    test('normal recipes exclude sick-day meals', () {
      expect(normalRecipes().every((r) => r.situation == null), isTrue);
    });

    test('category chip narrows the list', () {
      final snacks = normalRecipes(category: 'Snacks').map((r) => r.id);
      expect(snacks, contains('cutlets'));
      expect(snacks, isNot(contains('datekheer')));
      final desserts = normalRecipes(category: 'Desserts').map((r) => r.id);
      expect(desserts, contains('datekheer'));
      expect(desserts, isNot(contains('cutlets')));
    });

    test('diet (veg / vegan / non-veg) + immunity filters narrow the list', () {
      expect(normalRecipes(diet: 'veg').every((r) => r.veg), isTrue);
      expect(normalRecipes(diet: 'veg').map((r) => r.id), isNot(contains('eggbhurji')));
      expect(normalRecipes(diet: 'nonveg').every((r) => !r.veg), isTrue);
      expect(normalRecipes(diet: 'nonveg').map((r) => r.id), contains('eggbhurji'));
      expect(normalRecipes(diet: 'vegan').every((r) => r.vegan), isTrue);
      expect(normalRecipes(diet: 'vegan').map((r) => r.id), contains('tomatosoup'));
      expect(normalRecipes(immunity: true).every((r) => r.immunity), isTrue);
      expect(normalRecipes(immunity: true).map((r) => r.id), contains('tomatosoup'));
    });

    test('sick situation selects the right comfort meals', () {
      expect(sickRecipes('Constipation').map((r) => r.id), containsAll(['khichdi', 'prunepuree', 'ragiporridge']));
      expect(sickRecipes('Fever').every((r) => r.situation == 'Fever'), isTrue);
      expect(sickRecipes('Constipation').map((r) => r.id), isNot(contains('lightkhichdi')));
    });
  });

  testWidgets('Sick-day chip swaps the visible meal list', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: SickDaysScreen()));
    await tester.pump();

    // Constipation is the default
    expect(find.text('Soft moong dal khichdi'), findsOneWidget);
    expect(find.text('Banana & rice mash'), findsNothing);

    await tester.tap(find.text('Loose motion')); // a visible situation chip
    await tester.pump();

    expect(find.text('Soft moong dal khichdi'), findsNothing);
    expect(find.text('Banana & rice mash'), findsOneWidget); // a Loose-motion meal
  });
}
