// =============================================================================
//  FoodHomeScreen - ParentVeda Food companion ("what to feed my child today?")
// -----------------------------------------------------------------------------
//  Not a recipe list - a food companion. Opens on Today's Meals (the five-slot
//  plan), a daily Nutrition Focus (the educational core), personalised
//  recommendations, the Smart Meal Builder, dynamic meal plans, category browse,
//  and the shopping list + saved. Reached from the Explore drawer. Recipes V2 -
//  the existing Recipes module is left untouched.
// =============================================================================

import 'package:flutter/material.dart';

import 'food_builder_screen.dart';
import 'food_category_screen.dart';
import 'food_common.dart';
import 'food_mealplan_screen.dart';
import 'food_nutrition_screen.dart';
import 'food_recipe_screen.dart';
import 'food_saved_screen.dart';
import 'food_shopping_screen.dart';
import 'pp_common.dart';
import 'pp_food_data.dart';

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: FoodStore.instance,
          builder: (context, _) {
            final store = FoodStore.instance;
            final meals = todaysMeals();
            final focus = todaysFocus();
            return ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Explore')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('ParentVeda Food', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('What to feed Aarav today', style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 6),
            _pad(Text('Not just recipes - what to cook, why it’s good, and how it helps him grow.', style: ppBody(14, h: 1.5))),

            const SizedBox(height: 16),
            _pad(_vegToggle(store)),

            // 1 - Today's meals
            const SizedBox(height: 26),
            _pad(foodSectionHeader("Today's meals", action: 'Meal plan →', onAction: () => _push(context, const FoodMealPlanScreen()))),
            const SizedBox(height: 14),
            SizedBox(
              height: 218,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: kFoodSlots.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  final slot = kFoodSlots[i];
                  final r = meals[slot]!;
                  return _mealCard(context, slot, r);
                },
              ),
            ),

            // 2 - Nutrition focus
            const SizedBox(height: 30),
            _pad(foodSectionHeader("Today's nutrition focus")),
            const SizedBox(height: 14),
            _pad(_focusCard(context, focus)),

            // Smart Meal Builder
            const SizedBox(height: 26),
            _pad(_builderCard(context)),

            // 3 - Recommended
            const SizedBox(height: 30),
            _pad(foodSectionHeader('Chosen for his stage')),
            const SizedBox(height: 4),
            _pad(Text('For his age, the season and what he’s eaten lately.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 16),
            _pad(Column(children: [
              for (final r in recommendedFood.take(5))
                FoodListCard(recipe: r, onTap: () => _push(context, FoodRecipeScreen(recipe: r))),
            ])),

            // 5 - Categories
            const SizedBox(height: 14),
            _pad(foodSectionHeader('Explore by kind')),
            const SizedBox(height: 14),
            _pad(_categories(context)),

            // Shopping + saved
            const SizedBox(height: 30),
            _pad(_shoppingLink(context)),
            const SizedBox(height: 12),
            _pad(_savedLink(context)),
          ],
        );
          },
        ),
      ),
    );
  }

  // ---- vegetarian toggle --------------------------------------------------
  Widget _vegToggle(FoodStore store) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Row(children: [
          Icon(Icons.eco_outlined, size: 18, color: store.vegOnly ? ppPurple : ppMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Vegetarian only', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Show only veg meals, plans & suggestions', style: ppBody(12)),
            ]),
          ),
          const SizedBox(width: 10),
          GestureDetector(onTap: store.toggleVeg, behavior: HitTestBehavior.opaque, child: ppSwitch(store.vegOnly)),
        ]),
      );

  // ---- today's meal card --------------------------------------------------
  Widget _mealCard(BuildContext context, String slot, FoodRecipe r) => GestureDetector(
        onTap: () => _push(context, FoodRecipeScreen(recipe: r)),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 178,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FoodThumb(seed: r.seed, height: 108),
            const SizedBox(height: 10),
            Text(slot.toUpperCase(), style: ppBody(9.5, color: ppCoral, w: FontWeight.w800).copyWith(letterSpacing: 0.7)),
            const SizedBox(height: 3),
            Text(r.title, style: ppJakarta(13.5).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            foodMeta(r),
          ]),
        ),
      );

  // ---- nutrition focus card ----------------------------------------------
  Widget _focusCard(BuildContext context, NutritionFocus f) => GestureDetector(
        onTap: () => _push(context, FoodNutritionScreen(focus: f)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFF7ECEF)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.eco_outlined, size: 16, color: ppPurple),
              const SizedBox(width: 8),
              ppEyebrow('Nutrient of the day', color: ppPurple, spacing: 1.0),
            ]),
            const SizedBox(height: 12),
            Text(f.nutrient, style: ppFraunces(24, h: 1.1)),
            const SizedBox(height: 4),
            Text(f.oneLine, style: ppBody(13.5, color: ppSoft, w: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(f.why, style: ppBody(13.5, h: 1.55), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 14),
            Row(children: [
              Text('Learn about ${f.nutrient.toLowerCase()}', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
            ]),
          ]),
        ),
      );

  // ---- smart meal builder card -------------------------------------------
  Widget _builderCard(BuildContext context) => GestureDetector(
        onTap: () => _push(context, const FoodBuilderScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: ppInk, borderRadius: BorderRadius.circular(22)),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.auto_awesome, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Smart Meal Builder', style: ppJakarta(15.5, color: Colors.white)),
                const SizedBox(height: 3),
                Text('Tell us the time you have and what’s in the kitchen - we’ll do the thinking.',
                    style: ppBody(12.5, color: Colors.white.withValues(alpha: 0.8), h: 1.4)),
              ]),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white.withValues(alpha: 0.8)),
          ]),
        ),
      );

  Widget _categories(BuildContext context) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final c in kFoodCategories)
            GestureDetector(
              onTap: () => _push(context, FoodCategoryScreen(category: c.$1)),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: ppHair)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(c.$2, size: 15, color: ppPurple),
                  const SizedBox(width: 7),
                  Text(c.$1, style: ppBody(12.5, color: ppInk, w: FontWeight.w600)),
                ]),
              ),
            ),
        ],
      );

  Widget _shoppingLink(BuildContext context) => AnimatedBuilder(
        animation: FoodStore.instance,
        builder: (context, _) {
          final left = FoodStore.instance.shoppingLeft;
          return GestureDetector(
            onTap: () => _push(context, const FoodShoppingScreen()),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
              child: Row(children: [
                const Icon(Icons.shopping_basket_outlined, size: 20, color: ppPurple),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Shopping list', style: ppJakarta(15)),
                    const SizedBox(height: 2),
                    Text(left == 0 ? 'Add ingredients from any recipe' : '$left ${left == 1 ? 'item' : 'items'} to buy', style: ppBody(12)),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
              ]),
            ),
          );
        },
      );

  Widget _savedLink(BuildContext context) => GestureDetector(
        onTap: () => _push(context, const FoodSavedScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            const Icon(Icons.bookmark_outline_rounded, size: 20, color: ppPurple),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Saved & recently cooked', style: ppJakarta(15)),
                const SizedBox(height: 2),
                Text('Your favourites and meal-prep lists', style: ppBody(12)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}
