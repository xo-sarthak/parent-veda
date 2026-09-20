// =============================================================================
//  Nutrition — the recipe rail, and the list under it
// -----------------------------------------------------------------------------
//  A `PvDoorSection.inline` rail: the recipes for her (diet respected, the
//  unticked needs leading), as `PvDoorRailCard`s with the recipe's photo —
//  the door's own card at the door's own height, so the symmetry test and
//  the eye both see one rail. The chart's advice sentences never appear
//  here; a card is a dish.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/nutrition/nutrition_photos.dart';
import '../../../data/nutrition/nutrition_plate.dart';
import '../../../data/nutrition_data.dart';
import '../../../services/family_profile.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../widgets/pv_feedback.dart';
import '../../doors/pv_door_chrome.dart';
import '../../v2/v2_palette.dart';
import 'recipe_cook_screen.dart';

class NutritionRecipeRail extends StatelessWidget {
  const NutritionRecipeRail({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([V2PaletteStore.instance, FamilyProfileStore.instance, NutritionDayStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final diet = FamilyProfileStore.instance.diet;
          final store = NutritionDayStore.instance;
          final today = DateTime.now();
          final unticked = kPlateNeeds.where((n) => !store.ticked(today, n.id)).map((n) => n.recipeTag).toSet();
          final mine = [for (final r in kRecipes) if (recipeSuits(r, diet)) r]
            ..sort((a, b) {
              final ah = a.tags.any(unticked.contains) ? 0 : 1;
              final bh = b.tags.any(unticked.contains) ? 0 : 1;
              return ah.compareTo(bh);
            });
          return SizedBox(
            height: kPvRailCardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
              itemCount: mine.length,
              separatorBuilder: (_, _) => const SizedBox(width: kPvRailGap),
              itemBuilder: (_, i) => PvDoorRailCard(
                p: p,
                hue: 104,
                index: i,
                icon: Icons.soup_kitchen_outlined,
                chip: 'RECIPE',
                title: mine[i].name.en,
                meta: mine[i].nutritionGlance.isEmpty ? null : mine[i].nutritionGlance.first,
                imageUrl: nutritionRecipePhoto(mine[i].id, mine[i].name.en),
                onTap: () {
                  pvCommitFeedback();
                  openRecipe(context, mine[i], pregnancy);
                },
              ),
            ),
          );
        },
      );
}
