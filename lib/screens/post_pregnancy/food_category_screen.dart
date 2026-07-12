// =============================================================================
//  FoodCategoryScreen - a single food category's feed
// -----------------------------------------------------------------------------
//  A calm vertical feed of the recipes in one kind (First Foods, Snacks, …).
//  Reached from the Food home's category chips.
// =============================================================================

import 'package:flutter/material.dart';

import 'food_common.dart';
import 'food_recipe_screen.dart';
import 'pp_common.dart';
import 'pp_food_data.dart';

class FoodCategoryScreen extends StatelessWidget {
  const FoodCategoryScreen({super.key, required this.category});
  final String category;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final recipes = foodByCategory(category);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Recipes')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('Category', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text(category, style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 6),
            _pad(Text('${recipes.length} ${recipes.length == 1 ? 'recipe' : 'recipes'} for his stage', style: ppBody(13))),
            const SizedBox(height: 22),
            if (recipes.isEmpty)
              _pad(Text('More for this kind is on the way.', style: ppBody(14, color: ppMuted)))
            else
              _pad(Column(children: [
                for (final r in recipes) FoodListCard(recipe: r, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => FoodRecipeScreen(recipe: r)))),
              ])),
          ],
        ),
      ),
    );
  }
}
