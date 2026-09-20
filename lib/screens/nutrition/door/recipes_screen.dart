// =============================================================================
//  Nutrition — all the recipes, hers first
// -----------------------------------------------------------------------------
//  A two-across photo grid (Crouton's All Recipes) with need chips across
//  the top — iron, calcium, protein, fibre — because "what gives me iron" is
//  the question, not "show me Bengali". Diet is respected without a chip:
//  a vegetarian never sees the fish curry to have to filter it out.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/nutrition/nutrition_photos.dart';
import '../../../data/nutrition/nutrition_plate.dart';
import '../../../data/nutrition_data.dart';
import '../../../services/family_profile.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../doors/pv_door_chrome.dart';
import '../../v2/v2_palette.dart';
import 'nutrition_widgets.dart';
import 'recipe_cook_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String? _tag;

  @override
  Widget build(BuildContext context) {
    final diet = FamilyProfileStore.instance.diet;
    final mine = [for (final r in kRecipes) if (recipeSuits(r, diet) && (_tag == null || r.tags.contains(_tag))) r];
    return PvDoorToolScaffold(
      hue: 104,
      eyebrow: 'Nutrition · Recipes',
      title: 'Recipes to actually cook',
      intro: diet == null
          ? 'Everyday Indian dishes, each with a reason it helps now. Tap one to cook it.'
          : '${diet.label.en} dishes from an everyday Indian kitchen, each with a reason it helps now.',
      children: [
        Builder(builder: (context) {
          final p = V2PaletteStore.instance.current;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
                children: [
                  NutritionChip(label: 'All', p: p, selected: _tag == null, onTap: () => setState(() => _tag = null)),
                  for (final n in kPlateNeeds) ...[
                    const SizedBox(width: 8),
                    NutritionChip(
                        label: n.label,
                        p: p,
                        selected: _tag == n.recipeTag,
                        onTap: () => setState(() => _tag = _tag == n.recipeTag ? null : n.recipeTag)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (mine.isEmpty)
              pvDoorPad(Text('Nothing tagged for that yet — the plate\'s swaps still cover it.',
                  style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)))
            else
              pvDoorPad(GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 18, crossAxisSpacing: 12, childAspectRatio: 0.78),
                itemCount: mine.length,
                itemBuilder: (_, i) => RecipeCard(
                  p: p,
                  width: double.infinity,
                  name: mine[i].name.en,
                  line: mine[i].whyNow.en,
                  url: nutritionRecipePhoto(mine[i].id, mine[i].name.en),
                  onTap: () => openRecipe(context, mine[i], widget.pregnancy),
                ),
              )),
            const SizedBox(height: 24),
            pvDoorPad(PvDoorDisclaimer(p: p, text: 'Recipes are everyday food, not treatment. If you have a condition plan, it comes first.')),
          ]);
        }),
      ],
    );
  }
}
