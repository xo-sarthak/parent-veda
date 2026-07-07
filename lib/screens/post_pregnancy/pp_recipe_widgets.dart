// =============================================================================
//  Recipes - shared widgets: the list row and the carousel card. Both open the
//  recipe page for their RecipeItem. Warm-toned variant for sick-day comfort
//  meals. Isolated to the post_pregnancy module.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_recipes_data.dart';
import 'recipe_page_screen.dart';

const Color _clayA = Color(0xFFF6E9E2);
const Color _clayB = Color(0xFFFBF3EE);
const Color _clayBorder = Color(0xFFF0DED3);

Widget _meta(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: ppSoft),
      const SizedBox(width: 4),
      Text(text, style: ppBody(12)),
    ]);

void _openRecipe(BuildContext context, RecipeItem r) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => RecipePageScreen(recipe: r)));

/// A recipe list row: 96px thumb + title + subtitle + time/difficulty/meal.
/// [warm] uses the clay palette for sick-day comfort meals.
class PpRecipeRow extends StatelessWidget {
  const PpRecipeRow(this.recipe, {super.key, this.warm = false, this.top = false, this.bottom = false});
  final RecipeItem recipe;
  final bool warm;
  final bool top;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openRecipe(context, recipe),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(top: top ? 20 : 0, bottom: 20),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: warm ? _clayBorder : const Color(0xFFECE5F2))),
            clipBehavior: Clip.antiAlias,
            child: PpStriped(height: 100, colorA: warm ? _clayA : ppStripeA, colorB: warm ? _clayB : ppStripeB),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(recipe.title, style: ppJakarta(16).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(recipe.subtitle, style: ppBody(12, color: warm ? ppPurple : ppSoft, w: warm ? FontWeight.w600 : FontWeight.w400)),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 4, children: [
                _meta(Icons.schedule, '${recipe.minutes} min'),
                _meta(Icons.speed_outlined, recipe.difficulty),
                _meta(Icons.restaurant_outlined, recipe.meal),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// A recommended-carousel card: 230px, image + badges + title + meta.
class PpRecipeCard extends StatelessWidget {
  const PpRecipeCard(this.recipe, {super.key});
  final RecipeItem recipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openRecipe(context, recipe),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 230,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ppBorder),
            boxShadow: ppCardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              const PpStriped(height: 130),
              if (recipe.hasVideo)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.play_arrow_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 3),
                      Text('${recipe.minutes >= 10 ? 3 : recipe.minutes}-min',
                          style: ppBody(10, color: Colors.white, w: FontWeight.w600)),
                    ]),
                  ),
                ),
              if (recipe.healthier)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                    child: Text('Healthier', style: ppBody(10, color: ppBrown, w: FontWeight.w700)),
                  ),
                ),
            ]),
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(recipe.title, style: ppJakarta(16).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Wrap(spacing: 10, children: [
                  _meta(Icons.schedule, '${recipe.minutes} min'),
                  _meta(Icons.speed_outlined, recipe.difficulty),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
