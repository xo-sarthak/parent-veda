// =============================================================================
//  RecipesScreen - the UNIFIED Recipes home (parenting · Explore)
// -----------------------------------------------------------------------------
//  The single food front door. Merges the old Recipes section and the old Food
//  companion onto one richer model (FoodRecipe / FoodStore, in pp_food_data):
//  search, 3-way diet + immunity + category filters, Today's Meals, a daily
//  Nutrition Focus, the Sick-mode doorway, the Smart Meal Builder, the shopping
//  list, saved & recently cooked, and a recommended carousel - one cohesive
//  scroll. Reached from the Explore drawer's "Recipes" row. Recipe rows/cards
//  open the data-driven FoodRecipeScreen (with its functional Healthier-Version
//  toggle). The standalone Food home (food_home_screen.dart) is retired.
// =============================================================================

import 'package:flutter/material.dart';
import 'pp_child_profile.dart';

import 'food_builder_screen.dart';
import 'food_common.dart';
import 'food_mealplan_screen.dart';
import 'food_nutrition_screen.dart';
import 'food_recipe_screen.dart';
import 'food_saved_screen.dart';
import 'food_shopping_screen.dart';
import 'pp_common.dart';
import 'pp_food_data.dart';
import 'pp_section_extras.dart';
import 'sick_days_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String _diet = 'All'; // 'All' | 'veg' | 'vegan' | 'nonveg'
  bool _immunity = false;
  String _category = 'All';

  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: FoodStore.instance,
            builder: (context, _) {
              final q = _query.trim();
              return ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 40),
                children: [
                  _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    ppBack(context, 'Explore'),
                    ppLangToggle(),
                  ])),

                  // header + sick-mode doorway
                  const SizedBox(height: 22),
                  _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Tagline removed per 17-18 July review - it was
                        // saying nothing the page did not already show.
                        // ppEyebrow('Indian food, for Indian kids'),
                        const SizedBox(height: 10),
                        Text('Recipes', style: ppFraunces(33, h: 1.12)),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    _sickButton(context),
                  ])),
                  const SizedBox(height: 12),
                  _pad(Text('What to cook, why it is good, and how it helps him grow - every dish age-tagged.',
                      style: ppBody(15))),

                  // search (recipe title)
                  const SizedBox(height: 16),
                  _pad(ppSearchField(
                    controller: _searchCtl,
                    hint: 'Search recipes…',
                    onChanged: (v) => setState(() => _query = v),
                  )),

                  if (q.isNotEmpty)
                    ..._searchResults(context, q)
                  else
                    ..._home(context),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  // ---- search results -------------------------------------------------------
  List<Widget> _searchResults(BuildContext context, String q) {
    final items = searchEverydayRecipes(q);
    return [
      const SizedBox(height: 18),
      if (items.isEmpty)
        _pad(Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          alignment: Alignment.center,
          child: Text('No matches for "$q" - try another dish.', textAlign: TextAlign.center, style: ppBody(13, color: ppMuted)),
        ))
      else
        _pad(Column(children: [
          for (final r in items) FoodListCard(recipe: r, onTap: () => _push(context, FoodRecipeScreen(recipe: r))),
        ])),
    ];
  }

  // ---- the home scroll ------------------------------------------------------
  List<Widget> _home(BuildContext context) {
    final meals = todaysMeals();
    final focus = todaysFocus();
    final recommended = recommendedFood;

    final list = browseRecipes(diet: _diet, category: _category, immunity: _immunity);
    final dietLabel = kFoodDiets.firstWhere((d) => d.$2 == _diet, orElse: () => kFoodDiets.first).$1;
    final catWord = _category == 'All' ? 'recipes' : _category.toLowerCase();
    final sectionTitle = '${_diet == 'All' ? 'All' : dietLabel} $catWord${_immunity ? ' · immunity boosters' : ''}';

    return [
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
            return _mealCard(context, slot, meals[slot]!);
          },
        ),
      ),

      // 2 - Nutrition focus
      const SizedBox(height: 30),
      _pad(foodSectionHeader("Today's nutrition focus")),
      const SizedBox(height: 14),
      _pad(_focusCard(context, focus)),

      // 3 - Smart Meal Builder
      const SizedBox(height: 26),
      _pad(_builderCard(context)),

      // 4 - Recommended carousel
      const SizedBox(height: 30),
      _pad(Text('Recommended for ${ChildProfileStore.instance.name}', style: ppJakarta(16))),
      const SizedBox(height: 4),
      _pad(Text('For his age, the season and what he has eaten lately.', style: ppBody(12.5, color: ppMuted))),
      const SizedBox(height: 14),
      SizedBox(
        height: 214,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: recommended.length,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (_, i) => FoodRailCard(recipe: recommended[i], onTap: () => _push(context, FoodRecipeScreen(recipe: recommended[i]))),
        ),
      ),

      _pad(const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: SizedBox(height: 1, child: ColoredBox(color: ppLine)),
      )),

      // 5 - diet filter (All / Veg / Vegan / Non-veg) + immunity
      _pad(Row(children: [
        for (int i = 0; i < kFoodDiets.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _dietSeg(kFoodDiets[i].$1, kFoodDiets[i].$2)),
        ],
      ])),
      const SizedBox(height: 10),
      _pad(Align(alignment: Alignment.centerLeft, child: _immunityChip())),

      // 6 - category chips
      const SizedBox(height: 18),
      _pad(Wrap(spacing: 9, runSpacing: 9, children: [for (final c in kBrowseCategories) _chip(c)])),

      // 7 - filtered browse list
      const SizedBox(height: 26),
      _pad(Text(sectionTitle, style: ppJakarta(16))),
      const SizedBox(height: 14),
      if (list.isEmpty)
        _pad(Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          alignment: Alignment.center,
          child: Text('No recipes match these filters yet - try another combination.', textAlign: TextAlign.center, style: ppBody(13, color: ppMuted)),
        ))
      else
        _pad(Column(children: [
          for (final r in list) FoodListCard(recipe: r, onTap: () => _push(context, FoodRecipeScreen(recipe: r))),
        ])),

      // 8 - shopping + saved
      const SizedBox(height: 14),
      _pad(_shoppingLink(context)),
      const SizedBox(height: 12),
      _pad(_savedLink(context)),

      const SizedBox(height: 22),
      _pad(Text("Nutrition, frequency and cautions on every recipe - in ParentVeda's voice, reviewed by a paediatric nutritionist.",
          textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
    ];
  }

  // ---- sick-mode doorway button --------------------------------------------
  Widget _sickButton(BuildContext context) => GestureDetector(
        onTap: () => _push(context, const SickDaysScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.healing_outlined, size: 18, color: ppPurple),
            const SizedBox(height: 5),
            Text('Sick mode', style: ppBody(10, color: ppPurple, w: FontWeight.w700)),
          ]),
        ),
      );

  // ---- today's meal card ----------------------------------------------------
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

  // ---- nutrition focus card -------------------------------------------------
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
              Flexible(child: Text('Learn about ${f.nutrient.toLowerCase()}', style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
            ]),
          ]),
        ),
      );

  // ---- smart meal builder card ---------------------------------------------
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
                Text('Tell us the time you have and what is in the kitchen - we will do the thinking.',
                    style: ppBody(12.5, color: Colors.white.withValues(alpha: 0.8), h: 1.4)),
              ]),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white.withValues(alpha: 0.8)),
          ]),
        ),
      );

  // ---- filters --------------------------------------------------------------
  Widget _dietSeg(String label, String code) {
    final on = _diet == code;
    return GestureDetector(
      onTap: () => setState(() => _diet = code),
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(12)),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(12.5, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }

  Widget _immunityChip() {
    final on = _immunity;
    const amber = Color(0xFFC98A2B);
    return GestureDetector(
      onTap: () => setState(() => _immunity = !_immunity),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(color: on ? amber : Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: on ? amber : ppLine)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.shield_moon_outlined, size: 15, color: on ? Colors.white : amber),
          const SizedBox(width: 6),
          Text('Immunity boosters', style: ppBody(12.5, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _chip(String c) {
    final on = _category == c;
    return GestureDetector(
      onTap: () => setState(() => _category = c),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(c, style: ppBody(12, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }

  // ---- shopping + saved -----------------------------------------------------
  Widget _shoppingLink(BuildContext context) {
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
  }

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
