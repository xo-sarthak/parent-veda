// =============================================================================
//  FoodSavedScreen - saved recipes + recently cooked
// -----------------------------------------------------------------------------
//  The parent's favourites and meal-prep shortlist, plus what they've cooked
//  lately. Reflects the FoodStore live. Reached from the Food home.
// =============================================================================

import 'package:flutter/material.dart';

import 'food_common.dart';
import 'food_recipe_screen.dart';
import 'pp_common.dart';
import 'pp_food_data.dart';
import 'pp_recipes_screen.dart' show PpRecipeListScreen;

class FoodSavedScreen extends StatelessWidget {
  const FoodSavedScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  // The one recipe list (2026-10-21): the same photo cards as Recipes, on the
  // tool shell. "Recently cooked" is not shown: nothing in the app records a
  // dish as cooked, and the list only ever held two seeded demo dishes.
  @override
  Widget build(BuildContext context) => PpRecipeListScreen(
        eyebrow: 'Saved',
        title: 'Your saved dishes',
        recipes: () => FoodStore.instance.saved,
        splitByAge: false,
        empty: 'Tap the bookmark on any recipe and it waits here.',
      );

  // The page before, kept for revert.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: foodListenable,
          builder: (context, _) {
            final store = FoodStore.instance;
            final saved = store.saved;
            final cooked = store.recentlyCooked;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Recipes')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('Saved', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Your recipes', style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 22),

                _pad(foodSectionHeader('Saved recipes')),
                const SizedBox(height: 14),
                if (saved.isEmpty)
                  _pad(Text('Tap the bookmark on any recipe to keep it here.', style: ppBody(14, color: ppMuted)))
                else
                  _pad(Column(children: [
                    for (final r in saved) FoodListCard(recipe: r, onTap: () => _push(context, FoodRecipeScreen(recipe: r))),
                  ])),

                const SizedBox(height: 20),
                _pad(foodSectionHeader('Recently cooked')),
                const SizedBox(height: 14),
                if (cooked.isEmpty)
                  _pad(Text('Meals you cook will show here, ready to make again.', style: ppBody(14, color: ppMuted)))
                else
                  _pad(Column(children: [
                    for (final r in cooked) FoodListCard(recipe: r, onTap: () => _push(context, FoodRecipeScreen(recipe: r))),
                  ])),
              ],
            );
          },
        ),
      ),
    );
  }
}
