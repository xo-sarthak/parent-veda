// =============================================================================
//  FoodNutritionScreen - a single nutrition focus, explained
// -----------------------------------------------------------------------------
//  The educational core: why the nutrient matters, where to get it, easy foods,
//  gentle signs of deficiency, and the recipes/article that deliver it. Reached
//  from the Food home's Nutrient-of-the-day card.
// =============================================================================

import 'package:flutter/material.dart';

import 'article_reader_screen.dart';
import 'food_common.dart';
import 'food_recipe_screen.dart';
import 'pp_common.dart';
import 'pp_food_data.dart';

class FoodNutritionScreen extends StatelessWidget {
  const FoodNutritionScreen({super.key, required this.focus});
  final NutritionFocus focus;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    final recipes = focus.recipeIds.map(foodRecipeById).toList();
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Recipes')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('Nutrition focus', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text(focus.nutrient, style: ppFraunces(32, h: 1.05))),
            const SizedBox(height: 6),
            _pad(Text(focus.oneLine, style: ppBody(14.5, color: ppSoft, w: FontWeight.w600))),

            const SizedBox(height: 20),
            _pad(Text(focus.why, style: ppBody(15, color: ppInk, h: 1.6))),

            const SizedBox(height: 24),
            _pad(Text('Where to get it', style: ppJakarta(17))),
            const SizedBox(height: 12),
            _pad(Wrap(spacing: 9, runSpacing: 9, children: [for (final s in focus.sources) nutrientChip(s)])),

            const SizedBox(height: 24),
            _pad(Text('Easy wins today', style: ppJakarta(17))),
            const SizedBox(height: 12),
            _pad(Column(children: [
              for (final f in focus.easyFoods)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 16, color: ppPurple),
                    const SizedBox(width: 12),
                    Expanded(child: Text(f, style: ppBody(14, color: ppInk, h: 1.4))),
                  ]),
                ),
            ])),

            const SizedBox(height: 20),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, size: 17, color: ppCoral),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Signs to watch', style: ppBody(12.5, color: ppInk, w: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(focus.deficiency, style: ppBody(13, color: ppSoft, h: 1.5)),
                  ]),
                ),
              ]),
            )),

            const SizedBox(height: 26),
            _pad(Text('Recipes rich in ${focus.nutrient.toLowerCase()}', style: ppJakarta(17))),
            const SizedBox(height: 14),
            _pad(Column(children: [
              for (final r in recipes) FoodListCard(recipe: r, onTap: () => _push(context, FoodRecipeScreen(recipe: r))),
            ])),

            if (focus.article != null)
              _pad(GestureDetector(
                onTap: () => _push(context, const ArticleReaderScreen()),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: ppHair)),
                  child: Row(children: [
                    Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.menu_book_outlined, size: 18, color: ppPurple)),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('ARTICLE', style: ppBody(9.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                        const SizedBox(height: 3),
                        Text(focus.article!, style: ppBody(13.5, color: ppInk, w: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
                  ]),
                ),
              )),
          ],
        ),
      ),
    );
  }
}
