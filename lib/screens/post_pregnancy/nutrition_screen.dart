// =============================================================================
//  NutritionScreen — nutrition-led, recipes last
// -----------------------------------------------------------------------------
//  Tapping "Nutrition" used to open Recipes, which answers a question the parent
//  of a two-month-old is not asking. Before six months there is nothing to cook;
//  the real question is how much milk, how often, and is this normal.
//
//  So the order here is deliberate and non-negotiable:
//    1. what nutrition is ABOUT at this age
//    2. milk — by route (breast / formula / mixed), with rhythm and volumes
//    3. the nutrients that matter now: why, how much, how to give
//    4. solids, only once they are genuinely relevant
//    5. recipes, LAST, as links out — never the page itself
//
//  Everything is a range with an explicit "he is not an average" caveat, because
//  a parent measuring her baby against a single number is the failure this page
//  exists to prevent.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_food_data.dart';
import 'pp_nutrition_data.dart';
import 'food_recipe_screen.dart';
import 'recipes_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _child = ChildProfileStore.instance;

  /// Which milk route she is on. Not stored as a judgement — it only decides
  /// which paragraph is most useful to show first.
  String _route = 'Breast';

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _child,
      builder: (context, _) {
        final months = _child.ageInMonths;
        final stage = nutritionForAge(months);
        final showRecipes = recipesRelevantAt(months);
        return Scaffold(
          backgroundColor: ppBg,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'My Child')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('Nutrition · ${_child.ageLabel}', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text(stage.headline, style: ppFraunces(29, h: 1.12))),
                const SizedBox(height: 12),
                _pad(Text(stage.focus, style: ppBody(14.5, color: ppInk, h: 1.65))),

                // ---- 2. milk ---------------------------------------------
                const SizedBox(height: 28),
                _pad(Text('Milk', style: ppJakarta(19))),
                const SizedBox(height: 4),
                _pad(Text('Still the foundation at this age. Pick how you feed to see what applies.',
                    style: ppBody(12.5, color: ppMuted))),
                const SizedBox(height: 14),
                _pad(_routeToggle()),
                const SizedBox(height: 14),
                _pad(_card(_routeText(stage))),

                const SizedBox(height: 12),
                _pad(_tinted(
                  Icons.schedule_rounded,
                  'What to expect',
                  stage.milk.rhythm,
                )),

                // ---- 3. nutrients ----------------------------------------
                const SizedBox(height: 28),
                _pad(Text('What matters right now', style: ppJakarta(19))),
                const SizedBox(height: 4),
                _pad(Text('Why it matters at his age, how much, and how to give it.',
                    style: ppBody(12.5, color: ppMuted))),
                const SizedBox(height: 14),
                for (final n in stage.nutrients) _pad(_nutrient(n)),

                // ---- 4. solids -------------------------------------------
                const SizedBox(height: 16),
                _pad(Text('Food', style: ppJakarta(19))),
                const SizedBox(height: 10),
                if (stage.solids == null)
                  _pad(_card(Text(
                    'Nothing to start yet. Solids open up around six months — until then milk covers all of it, and waiting is doing something, not nothing.',
                    style: ppBody(14, color: ppInk, h: 1.6),
                  )))
                else
                  _pad(_card(Text(stage.solids!, style: ppBody(14, color: ppInk, h: 1.6)))),

                // ---- watch-fors ------------------------------------------
                if (stage.watchFor.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _pad(Text('Worth knowing', style: ppJakarta(17))),
                  const SizedBox(height: 12),
                  _pad(Column(children: [
                    for (final w in stage.watchFor)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.info_outline_rounded, size: 15, color: ppCoral),
                          const SizedBox(width: 10),
                          Expanded(child: Text(w, style: ppBody(13.5, color: ppInk, h: 1.5))),
                        ]),
                      ),
                  ])),
                ],

                // ---- 5. recipes, LAST and only when relevant -------------
                if (showRecipes) ...[
                  const SizedBox(height: 26),
                  _pad(ppSectionDivider()),
                  _pad(Row(children: [
                    Expanded(child: Text('Recipes that fit', style: ppJakarta(19))),
                    GestureDetector(
                      onTap: () => _push(const RecipesScreen()),
                      behavior: HitTestBehavior.opaque,
                      child: Row(children: [
                        Text('All recipes', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
                        const SizedBox(width: 2),
                        const Icon(Icons.chevron_right_rounded, size: 17, color: ppPurple),
                      ]),
                    ),
                  ])),
                  const SizedBox(height: 4),
                  _pad(Text('Ways to actually put the above on a plate.', style: ppBody(12.5, color: ppMuted))),
                  const SizedBox(height: 14),
                  _recipeRail(months),
                ],

                const SizedBox(height: 24),
                _pad(_tinted(
                  Icons.favorite_border,
                  'He is not an average',
                  'Every number here is a range that suits most babies. Yours may sit outside it and be perfectly well. Judge by how he is growing and how he seems, not by a figure — and take anything that worries you to your paediatrician.',
                  accent: ppCoral,
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- pieces --------------------------------------------------------------

  Widget _routeToggle() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          for (final r in const ['Breast', 'Formula', 'Mixed'])
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _route = r),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _route == r ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(r,
                      style: ppBody(13, color: _route == r ? ppPurple : ppSoft, w: FontWeight.w700)),
                ),
              ),
            ),
        ]),
      );

  Widget _routeText(NutritionStage s) => Text(
        switch (_route) {
          'Formula' => s.milk.formula,
          'Mixed' => s.milk.mixed,
          _ => s.milk.breast,
        },
        style: ppBody(14, color: ppInk, h: 1.6),
      );

  Widget _nutrient(NutrientFocus n) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ppHair),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n.name, style: ppJakarta(15.5)),
          const SizedBox(height: 9),
          _line('Why it matters now', n.why),
          const SizedBox(height: 9),
          _line('How much', n.howMuch),
          const SizedBox(height: 9),
          _line('How to give it', n.how),
        ]),
      );

  Widget _line(String label, String body) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: ppBody(9, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.7)),
        const SizedBox(height: 3),
        Text(body, style: ppBody(13.5, color: ppInk, h: 1.55)),
      ]);

  Widget _card(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ppHair),
        ),
        child: child,
      );

  Widget _tinted(IconData icon, String title, String body, {Color accent = ppPurple}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.20)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: ppJakarta(15))),
          ]),
          const SizedBox(height: 8),
          Text(body, style: ppBody(13.5, color: ppInk, h: 1.6)),
        ]),
      );

  /// A few recipes suited to his age. Links out — this page is not a cookbook.
  Widget _recipeRail(int months) {
    final picks = kFoodRecipes.where((r) => !r.comfortOnly).take(8).toList();
    if (picks.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: picks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final r = picks[i];
          return GestureDetector(
            onTap: () => _push(FoodRecipeScreen(recipe: r)),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 156,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.restaurant_outlined, size: 24, color: ppPurple),
                ),
                const SizedBox(height: 8),
                Text(r.title, style: ppJakarta(13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Expanded(
                  child: Text(r.ageTag, style: ppBody(11.5, color: ppSoft, h: 1.35), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
