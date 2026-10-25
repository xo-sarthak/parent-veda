// =============================================================================
//  Food tools, safety and screens (tools pass 22-24, 2026-10-25)
// -----------------------------------------------------------------------------
//  The audit found "Whole grapes" said Yes from birth, the chart and the
//  checker disagreed on egg and fish, the chart said "salt and sugar lightly"
//  at one, Veggie Maggi (10-12 months) used the masala sachet, nothing said
//  what an allergic reaction looks like, and the chart's page links (choking
//  safety among them) drew "SOON" and did nothing. These hold every fix.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/health_doctor_visit_screen.dart' show ppDoctorVisitFoodsLine;
import 'package:parentveda/screens/post_pregnancy/pp_baby_food_check_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_safety.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_tries_store.dart';
import 'package:parentveda/screens/post_pregnancy/pp_health_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_recipes_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_what_to_feed_screen.dart';
import 'package:parentveda/services/pp_use_consent.dart';

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

/// Source lines that are code, not comments (superseded copy stays commented).
Iterable<String> _live(String path) => File(path)
    .readAsLinesSync()
    .where((l) => !l.trimLeft().startsWith('//'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PpFoodTriesStore.instance.debugReset();
  });

  group('one age table', () {
    test('each verdict the plan fixed, either side of its month', () {
      const ages = {
        'Honey': 12,
        'Cow milk as a drink': 12,
        'Salt': 12,
        'Sugar': 24,
        'Jaggery': 24,
        'Whole nuts': 60,
        'Grapes, quartered': 6,
        'Egg': 6,
        'Fish': 6,
      };
      for (final e in ages.entries) {
        expect(ppBabyFoodVerdict(e.key, e.value - 1), 'notYet', reason: '${e.key} before ${e.value} months');
        expect(ppBabyFoodVerdict(e.key, e.value), 'yes', reason: '${e.key} at ${e.value} months');
      }
    });

    test('before six months no food gets a Yes', () {
      for (final (name, _) in ppBabyFoodEntries()) {
        expect(ppBabyFoodVerdict(name, 5), isNot('yes'), reason: '$name at 5 months');
      }
    });

    test('the chart agrees with the checker on egg, fish and sugar', () {
      final chart = _live('lib/screens/post_pregnancy/pp_feeding_content.dart').join('\n');
      expect(chart, isNot(contains('From about 7 months once yolk is accepted')));
      expect(chart, isNot(contains("('Fish', 'From about 7 months")));
      expect(chart, isNot(contains('salt and sugar can be used lightly')));
      expect(chart, contains('Added sugar can still wait until two'));
    });

    test('no recipe for under one carries the sachet, soda or fruit salt', () {
      for (final r in foodCatalog) {
        final range = ppRecipeAgeRange(r.ageTag);
        if (range == null || range.$1 >= 12) continue;
        for (final i in r.ingredients) {
          final low = i.toLowerCase();
          expect(low.contains('sachet') && !low.contains('skip'), isFalse, reason: '${r.id}: $i');
          expect(low.contains('soda') || low.contains('fruit salt'), isFalse, reason: '${r.id}: $i');
        }
      }
    });
  });

  group('search', () {
    test('one letter is not a search, and near-misses stay out', () {
      expect(ppBabyFoodSearch('m'), isEmpty);
      expect(ppBabyFoodSearch('makhana').where((n) => n.toLowerCase().contains('butter')), isEmpty);
      expect(ppBabyFoodSearch('strawberry').where((n) => n == 'Ber'), isEmpty);
    });

    test('the names people type still land', () {
      expect(ppBabyFoodSearch('sooji'), contains('Suji and dalia'));
      expect(ppBabyFoodSearch('sahad'), contains('Honey'));
      expect(ppBabyFoodSearch('grapes'), contains('Grapes, quartered'));
      expect(ppBabyFoodSearch('egg').first, 'Egg', reason: 'a word-start match comes first');
    });
  });

  group('allergies on file (D2: always warn)', () {
    const egg = Allergy('Egg', AllergyStatus.known, 'Moderate', '');
    const milk = Allergy("Cow's milk protein", AllergyStatus.known, 'Mild', '');

    test('a food matches by name or alias, and only as a whole word', () {
      expect(ppAllergyMatchIn([egg], ['Egg curry and bhurji']), egg);
      expect(ppAllergyMatchIn([egg], ['anda']), egg);
      expect(ppAllergyMatchIn([egg], ['Eggplant', 'baingan']), isNull);
      expect(ppAllergyMatchIn([milk], ['Paneer', 'cottage cheese']), milk);
      expect(ppAllergyMatchIn([milk], ['Moong dal']), isNull);
    });

    test('the common allergens are named in a dish', () {
      expect(ppAllergensIn(['2 tbsp peanut powder', '1 egg']), containsAll(['peanut', 'egg']));
      expect(ppAllergensIn(['nutmeg', 'tilapia']), isEmpty);
    });
  });

  group('recipe landings (D6)', () {
    test('each preset lands on dishes, and an unknown one falls back', () {
      for (final preset in ['sick', 'first', 'ragi', 'weight', 'age/9', 'age/6']) {
        final r = ppRecipePreset(preset, foodCatalog);
        expect(r, isNotNull, reason: preset);
        expect(r!.$2, isNotEmpty, reason: preset);
      }
      for (final r in ppRecipePreset('age/9', foodCatalog)!.$2) {
        expect(ppRecipeFit(r, 9), PpRecipeFit.now, reason: r.id);
      }
      expect(ppRecipePreset('nope', foodCatalog), isNull);
    });

    testWidgets('a preset shows as a chip, and the chip clears it', (t) async {
      _ageMonths(10);
      t.view.physicalSize = const Size(1200, 6000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: PpRecipesScreen(preset: 'sick')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_recipes_preset')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_recipes_preset_hits')), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('pp_recipes_preset')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_recipes_preset')), findsNothing);
    });
  });

  group('first tries reach the doctor only with a yes', () {
    test('the visit lists reactions after the foods yes, never before', () async {
      final kid = await ChildProfileStore.instance.addChild(
          name: 'Aarav', isBoy: true, dob: DateTime.now().subtract(const Duration(days: 260)));
      await ChildProfileStore.instance.switchTo(kid.id);
      PpFoodTriesStore.instance.markTried('egg', reaction: FoodReaction.mild);
      PpFoodTriesStore.instance.markTried('banana');
      PpUseConsent.instance.set(PpUseKind.foods, false);
      expect(ppDoctorVisitFoodsLine(), isNull);
      PpUseConsent.instance.set(PpUseKind.foods, true);
      final line = ppDoctorVisitFoodsLine()!;
      expect(line, contains('Egg'));
      expect(line, contains('a mild reaction'));
      expect(line, isNot(contains('Banana')), reason: 'the doctor needs the reactions');
    });
  });

  group('the screens', () {
    testWidgets('Can my baby eat this? shows the red flags and the disclaimer', (t) async {
      _ageMonths(7);
      t.view.physicalSize = const Size(1200, 9000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: PpBabyFoodCheckScreen()));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_allergy_red_flags')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_food_disclaimer')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_food_tries_empty')), findsOneWidget,
          reason: 'first tries invite before there are any, never hidden');
    });

    testWidgets('Tried it on a food saves a first try for this child', (t) async {
      _ageMonths(7);
      t.view.physicalSize = const Size(1200, 9000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: PpBabyFoodCheckScreen(initialQuery: 'egg')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('pp_food_row_Egg')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('pp_food_tried_Egg')));
      await t.pumpAndSettle();
      expect(PpFoodTriesStore.instance.tried(ppFoodId('Egg')), isTrue);
      expect(find.byKey(const ValueKey('pp_food_tried_done_Egg')), findsOneWidget);
    });

    testWidgets('What to feed: page links open, and newborn signs stay with newborns', (t) async {
      t.view.physicalSize = const Size(1200, 12000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);

      _ageMonths(7);
      await t.pumpWidget(const MaterialApp(home: PpWhatToFeedScreen()));
      await t.pumpAndSettle();
      expect(find.text('SOON'), findsNothing, reason: 'every page link is live');

      _ageMonths(30);
      await t.pumpWidget(const MaterialApp(home: PpWhatToFeedScreen(key: ValueKey('b'))));
      await t.pumpAndSettle();
      expect(find.textContaining('getting enough?'), findsNothing);

      _ageMonths(48);
      await t.pumpWidget(const MaterialApp(home: PpWhatToFeedScreen(key: ValueKey('c'))));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_food_chart_past_three')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_food_disclaimer')), findsOneWidget);
    });
  });
}
