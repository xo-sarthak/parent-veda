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
import '../../../data/nutrition/food_values.dart';
import '../../../data/nutrition/nutrition_plate.dart';
import '../../../data/nutrition_data.dart';
import '../../../services/family_profile.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../services/saved_store.dart';
import '../../../widgets/pv_feedback.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../doors/pv_door_chrome.dart';
import '../../brackets/hub/hub_intent_art.dart';
import '../../v2/v2_palette.dart';
import 'nutrition_today_body.dart' show NutritionPreferenceRow;
import 'nutrition_widgets.dart';
import 'recipe_cook_screen.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final diet = FamilyProfileStore.instance.diet;
    return PvDoorToolScaffold(
      hue: 104,
      eyebrow: 'Nutrition · Recipes',
      title: 'Recipes to actually cook',
      intro: diet == null
          ? 'Everyday Indian dishes, each with a reason it helps now. Tap one to cook it.'
          : '${diet.label.en} dishes from an everyday Indian kitchen, each with a reason it helps now.',
      children: [RecipesGridBody(pregnancy: pregnancy)],
    );
  }
}

/// The library as a grid — the Recipes tab's inline tool AND the pushed
/// screen's body. 2026-09-20, after the user asked whether a rail was the
/// right way to show recipes: it is not. Crouton, Kitchen Stories,
/// Woolworths and CREME all show a recipe library as a PHOTO GRID you can
/// filter, led by one "cook today" card; a rail hides all but two. So:
/// the lead (hers first, the unticked needs leading), the need chips, then
/// two across.
class RecipesGridBody extends StatefulWidget {
  const RecipesGridBody({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<RecipesGridBody> createState() => _RecipesGridBodyState();
}

/// A meal-type or kind tile on the grid: what she taps when she wants "a
/// breakfast" or "a soup" rather than "iron". Seven of them, the library's
/// order (Lifesum, Yazio, Blinkit, Woolworths): the four meals, then the
/// three kinds that are not a meal.
const List<Object> kRecipeBuckets = [
  RecipeMeal.breakfast,
  RecipeMeal.lunch,
  RecipeMeal.dinner,
  RecipeMeal.snack,
  RecipeKind.sweet,
  RecipeKind.drink,
  RecipeKind.soup,
];

String recipeBucketLabel(Object b) => b is RecipeMeal ? b.label : (b as RecipeKind).label;

bool recipeInBucket(Recipe r, Object b) => b is RecipeMeal ? r.meals.contains(b) : r.kind == b;

class _RecipesGridBodyState extends State<RecipesGridBody> {
  String? _tag;

  /// The tile she picked: a [RecipeMeal] or a [RecipeKind]. Both filters
  /// stack — "breakfast" AND "iron" is a real question.
  Object? _bucket;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([V2PaletteStore.instance, FamilyProfileStore.instance, SavedStore.instance, NutritionDayStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final diet = FamilyProfileStore.instance.diet;
          final store = NutritionDayStore.instance;
          final today = DateTime.now();
          final unticked = kPlateNeeds.where((n) => !store.ticked(today, n.id)).map((n) => n.recipeTag).toSet();
          final all = [for (final r in kRecipes) if (recipeSuits(r, diet)) r]
            ..sort((a, b) {
              final ah = a.tags.any(unticked.contains) ? 0 : 1;
              final bh = b.tags.any(unticked.contains) ? 0 : 1;
              return ah.compareTo(bh);
            });
          final lead = all.isEmpty ? null : all.first;
          final mine = [
            for (final r in all)
              if ((_tag == null || r.tags.contains(_tag)) && (_bucket == null || recipeInBucket(r, _bucket!))) r
          ];
          final filtering = _tag != null || _bucket != null;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ---- cook today ---------------------------------------------
            if (lead != null && !filtering) ...[
              pvDoorPad(nutritionHeading(p, 'Cook today',
                  sub: unticked.isEmpty ? 'Something for the evening.' : 'Picked for what you have not had yet today.')),
              const SizedBox(height: 12),
              pvDoorPad(PvPress(
                child: InkWell(
                  onTap: () {
                    pvCommitFeedback();
                    openRecipe(context, lead, widget.pregnancy);
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                        color: p.surfaceAlt, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(fit: StackFit.expand, children: [
                      NutritionPhoto(
                          url: nutritionRecipePhoto(lead.id, lead.name.en), p: p, icon: Icons.soup_kitchen_outlined, iconSize: 48),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.62)],
                              stops: const [0.4, 1],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 14,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(lead.name.en,
                              style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(lead.whyNow.en,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(fontSize: 12.5, height: 1.4, color: Colors.white.withValues(alpha: 0.9))),
                          const SizedBox(height: 4),
                          Text(nutritionGlance(estimateRecipe(lead)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(
                                  fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.85))),
                        ]),
                      ),
                    ]),
                  ),
                ),
              )),
              const SizedBox(height: 26),
            ],
            // ---- the ones she kept --------------------------------------
            // Blinkit's "Bookmarked Recipes · see all" (2026-09-22). It is
            // the top section there because a saved recipe is the one she
            // has already decided about. It renders only when she has one:
            // an empty rail of hearts would be an instruction, not an
            // invitation, and the tab already opens with "Cook today".
            if (!filtering) ...[
              Builder(builder: (context) {
                final saved = [for (final r in all) if (SavedStore.instance.isSaved(SavedKind.recipe, r.id)) r];
                if (saved.isEmpty) return const SizedBox.shrink();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  pvDoorPad(nutritionHeading(p, 'The ones you kept',
                      sub: '${saved.length} saved. They stay here and in Saved.')),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
                      itemCount: saved.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => RecipeCard(
                        p: p,
                        recipeId: saved[i].id,
                        minutes: saved[i].minutes,
                  name: saved[i].name.en,
                        line: saved[i].whyNow.en,
                        url: nutritionRecipePhoto(saved[i].id, saved[i].name.en),
                        values: estimateRecipe(saved[i]),
                        onTap: () => openRecipe(context, saved[i], widget.pregnancy),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                ]);
              }),
            ],
            // ---- what she wants: a meal, or a kind ----------------------
            pvDoorPad(nutritionHeading(p, 'What are you after?',
                sub: 'A meal, a sweet, a soup — then by what you need.')),
            const SizedBox(height: 10),
            // The same two chips as under the plate's heading on Today: her
            // diet and region steer this grid too, and "Non-vegetarian only"
            // in a subtitle told her what was filtering and not how to
            // change it (the user, 2026-09-22).
            pvDoorPad(NutritionPreferenceRow(p: p, store: store)),
            const SizedBox(height: 14),
            // ⚠️ A GRID, NOT A RAIL (2026-09-22, the user with Blinkit's
            // Recipes open: "our recipe section resonates very much with
            // theirs — can we not do it the way they have").
            //
            // Blinkit shows its six meal times as a 3x2 grid, all of them at
            // once, and that is the argument: a bucket rail hid four of nine
            // behind a swipe, so "what am I after?" was answered with a
            // question. The same reasoning is already written above this
            // file's recipe grid — a rail hides all but two — and the buckets
            // were the one place it had not been applied.
            //
            // The old rail is kept below, commented, for revert.
            pvDoorPad(GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 14, crossAxisSpacing: 12, childAspectRatio: 0.64),
              itemCount: kRecipeBuckets.length,
              itemBuilder: (_, i) {
                final b = kRecipeBuckets[i];
                // A drawn mark in its own hue, not the first recipe's photo
                // — two tiles wore one photo and read as one thing (the
                // user, 2026-09-22). `url` stays on the tile for revert.
                return _BucketTile(
                  p: p,
                  label: recipeBucketLabel(b),
                  count: all.where((r) => recipeInBucket(r, b)).length,
                  url: null,
                  mark: recipeBucketMark(b),
                  hue: recipeBucketHue(b),
                  selected: _bucket == b,
                  onTap: () => setState(() => _bucket = _bucket == b ? null : b),
                );
              },
            )),
            // Kept for revert — the buckets as a horizontal rail:
            // SizedBox(height: 118, child: ListView.separated(
            //   scrollDirection: Axis.horizontal,
            //   padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
            //   itemCount: kRecipeBuckets.length, ...))
            const SizedBox(height: 18),
            // ---- the grid ----------------------------------------------
            pvDoorPad(nutritionHeading(p,
                _bucket == null ? 'Every recipe' : recipeBucketLabel(_bucket!),
                sub: _bucket == null ? 'By what you need.' : '${mine.length} to cook. Narrow by what you need.')),
            const SizedBox(height: 10),
            // The key to the marks on the cards below — "what is what".
            pvDoorPad(NutritionMarkLegend(p: p)),
            const SizedBox(height: 12),
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
            const SizedBox(height: 18),
            if (mine.isEmpty)
              pvDoorPad(Text(
                  _bucket != null && _tag != null
                      ? 'Nothing that is both yet. Try one without the other.'
                      : 'Nothing tagged for that yet. The plate has swaps that cover it.',
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
                  recipeId: mine[i].id,
                  minutes: mine[i].minutes,
                  name: mine[i].name.en,
                  line: mine[i].whyNow.en,
                  url: nutritionRecipePhoto(mine[i].id, mine[i].name.en),
                  values: estimateRecipe(mine[i]),
                  onTap: () => openRecipe(context, mine[i], widget.pregnancy),
                ),
              )),
            const SizedBox(height: 8),
          ]);
        },
      );
}

/// A meal or kind: a square photo with an ink ring when chosen, the label
/// and a count under. The photo is the bucket's first recipe's — no second
/// set of pictures to pick.
class _BucketTile extends StatelessWidget {
  const _BucketTile({
    required this.p,
    required this.label,
    required this.count,
    required this.url,
    required this.selected,
    required this.onTap,
    this.mark,
    this.hue,
  });
  final V2Palette p;
  final String label;
  final int count;
  final String? url;
  final bool selected;
  final VoidCallback onTap;

  /// The drawn mark in a tinted well, in the bucket's own hue (2026-09-22).
  /// Null: the photo, kept for revert.
  final IntentMark? mark;
  final double? hue;

  @override
  Widget build(BuildContext context) => PvPress(
        child: InkWell(
          onTap: () {
            pvCommitFeedback();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
              // In a grid the well takes the cell's width; the 78 square was
              // the rail's geometry.
              AspectRatio(
                aspectRatio: 1,
                child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: selected ? p.ink1 : Colors.transparent, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: mark == null
                      ? NutritionPhoto(url: url, p: p, icon: Icons.soup_kitchen_outlined)
                      : Container(
                          color: v2BlockTint(hue ?? 104, p),
                          padding: const EdgeInsets.all(14),
                          child: HubIntentArt(mark: mark!, tint: v2BlockTint(hue ?? 104, p)),
                        ),
                ),
              ),
              ),
              const SizedBox(height: 6),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 12.5, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: p.ink1)),
              Text('$count', style: pvManrope(fontSize: 11, color: p.ink3)),
            ]),
        ),
      );
}

/// Each meal and kind, drawn, in its own hue — a chai cup for breakfast, a
/// plate for lunch, the moon for dinner, a samosa for snacks; the kadhai for
/// mains, a leaf for light, a bowl for soups, a laddoo for sweets, a glass
/// for drinks. Nine tiles, nine marks, nine hues around the wheel.
IntentMark recipeBucketMark(Object b) => switch (b) {
      RecipeMeal.breakfast => IntentMark.chaiMark,
      RecipeMeal.lunch => IntentMark.plate,
      RecipeMeal.dinner => IntentMark.moonMark,
      RecipeMeal.snack => IntentMark.snackMark,
      RecipeKind.main => IntentMark.cookMark,
      RecipeKind.light => IntentMark.folateMark,
      RecipeKind.soup => IntentMark.bowlMark,
      RecipeKind.sweet => IntentMark.sweetMark,
      RecipeKind.drink => IntentMark.calciumMark,
      _ => IntentMark.plate,
    };

double recipeBucketHue(Object b) => switch (b) {
      RecipeMeal.breakfast => 42,
      RecipeMeal.lunch => 104,
      RecipeMeal.dinner => 268,
      RecipeMeal.snack => 26,
      RecipeKind.main => 344,
      RecipeKind.light => 160,
      RecipeKind.soup => 206,
      RecipeKind.sweet => 320,
      RecipeKind.drink => 186,
      _ => 104,
    };
