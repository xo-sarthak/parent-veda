// =============================================================================
//  Nutrition — one need: what counts
// -----------------------------------------------------------------------------
//  Behind each tick. Alma's nutrient page lists the foods that contributed;
//  we do not measure, so the page is turned round: the everyday foods that
//  WOULD count (the nutrient guide's own list), the recipes tagged for it,
//  the guide's one paragraph and its supplement note, and the tick itself
//  at the foot so she can mark it from here.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/nutrition/nutrition_photos.dart';
import '../../../data/nutrition/nutrition_plate.dart';
import '../../../data/nutrition_data.dart';
import '../../../services/family_profile.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../../services/pregnancy_controller.dart';
import '../../doors/pv_door_chrome.dart';
import '../../v2/v2_palette.dart';
import 'nutrition_widgets.dart';
import 'recipe_cook_screen.dart';

class NeedScreen extends StatelessWidget {
  const NeedScreen({super.key, required this.need, required this.pregnancy});
  final PlateNeed need;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final guide = kNutrientGuides.where((g) => g.id == need.id).firstOrNull;
    final foods = plateFoodsFor(need);
    final recipes = plateRecipesFor(need, diet: FamilyProfileStore.instance.diet);
    return PvDoorToolScaffold(
      hue: 104,
      eyebrow: 'Did you get… · ${need.label}',
      title: need.label,
      intro: guide?.whatItDoes.en ?? need.line,
      children: [
        ListenableBuilder(
          listenable: NutritionDayStore.instance,
          builder: (context, _) {
            final p = V2PaletteStore.instance.current;
            final store = NutritionDayStore.instance;
            final ticked = store.ticked(DateTime.now(), need.id);
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              pvDoorPad(nutritionHeading(p, 'What counts', sub: 'Any one of these today, and the tick is honest.')),
              const SizedBox(height: 12),
              pvDoorPad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final f in foods)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: p.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: p.line)),
                    child: Text(f.en, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
                  ),
              ])),
              if (recipes.isNotEmpty) ...[
                const SizedBox(height: 26),
                pvDoorPad(nutritionHeading(p, 'Recipes that give it')),
                const SizedBox(height: 12),
                SizedBox(
                  height: 196,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
                    itemCount: recipes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => RecipeCard(
                      p: p,
                      name: recipes[i].name.en,
                      line: recipes[i].whyNow.en,
                      url: nutritionRecipePhoto(recipes[i].id, recipes[i].name.en),
                      onTap: () => openRecipe(context, recipes[i], pregnancy),
                    ),
                  ),
                ),
              ],
              if (guide != null) ...[
                const SizedBox(height: 26),
                pvDoorPad(nutritionHeading(p, 'About the tablet')),
                const SizedBox(height: 8),
                pvDoorPad(Text(guide.supplementNote.en, style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1))),
              ],
              const SizedBox(height: 26),
              pvDoorPad(FilledButton.icon(
                onPressed: () {
                  pvCommitFeedback();
                  store.toggleTick(DateTime.now(), need.id);
                },
                icon: Icon(ticked ? Icons.check_rounded : Icons.add_rounded, size: 18),
                label: Text(ticked ? 'Done for today' : 'I had some today'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              )),
              const SizedBox(height: 8),
              pvDoorPad(Text(
                  ticked ? 'Tap again if that was a mistake.' : 'No amounts, no grams. A serving of any of the above is the tick.',
                  style: pvManrope(fontSize: 12, color: p.ink3))),
              const SizedBox(height: 22),
              pvDoorPad(PvDoorDisclaimer(
                  p: p,
                  text: 'General guidance. Your prenatal tablet and any dose are your doctor\'s to set; this page never replaces them.')),
            ]);
          },
        ),
      ],
    );
  }
}
