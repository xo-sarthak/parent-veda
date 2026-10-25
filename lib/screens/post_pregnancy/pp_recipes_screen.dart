// =============================================================================
//  Parenting · Recipes, in the one ParentVeda format (2026-10-07)
// -----------------------------------------------------------------------------
//  The user: "do a mobbin MCP usage over it to find out the most appropriate
//  representation of the recipes section". Two browse screens did one job
//  (RecipesScreen from the doors and Tools, RecipesExploreScreen from More),
//  both on the old chrome. This is the one, on the shell every TTC and
//  pregnancy tool wears; both entrances open it, the old two are kept for
//  revert.
//
//  Mobbin:
//   * search, then the filters as chips that read as a sentence, after Noom's
//     recipes (mobbin.com/screens/99817269-341f-4d2d-bf05-17162018a65b);
//   * one rail per meal, after Lifesum's Breakfast / Lunch rails
//     (mobbin.com/screens/c23fec59-8d81-4c2a-984c-4581ee26e0e4);
//   * the time on every card, after Kitchen Stories
//     (mobbin.com/screens/ec68f241-2fae-4090-aaf0-383f7bddb260).
//  The cards are the doors' shelf cards (kind: recipe), so a recipe here looks
//  like a recipe on a door.
//
//  "For <name> now" is on by default: the age is derived, never asked. A
//  sick-day doorway stays at the foot, as before.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../doors/pv_shelf_card.dart';
import '../doors/pv_shelf_spec.dart' show PvShelfKind;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvChip, PvCommit, pvStorePalette;
import '../v2/v2_palette.dart';
import '../../services/family_profile.dart' show DietPreference, FamilyProfileStore;
import 'food_common.dart' show FoodPhoto, FoodPhotoCard, foodAgeLabel, foodDietMark, foodPhotoDisc;
import 'food_saved_screen.dart';
import 'pp_baby_food_check_screen.dart' show PpBabyFoodCheckScreen;
// import 'pp_baby_ok_check_screen.dart' show PpBabyOkCheckScreen; // kept for revert (tools pass H2)
import 'what_changed_screen.dart' show WhatChangedScreen;
import 'pp_common.dart' show ppFill;
import 'pp_feeding_content.dart' show kPpFeedingSection;
import 'pp_section_screen.dart' show ppOpenPage;
import 'food_recipe_screen.dart';
import 'pp_child_profile.dart';
import 'pp_food_data.dart';
import 'sick_days_screen.dart';

/// The months an age tag covers ('6 to 12 mo', '12 mo+', '6+ mo'), or null.
(int, int)? ppRecipeAgeRange(String tag) {
  final t = tag.toLowerCase().replaceAll('–', ' to ').replaceAll('-', ' to ');
  final r = RegExp(r'(\d+)\s*to\s*(\d+)').firstMatch(t);
  if (r != null) return (int.parse(r.group(1)!), int.parse(r.group(2)!));
  final plus = RegExp(r'(\d+)\s*(mo)?\s*\+').firstMatch(t);
  if (plus != null) return (int.parse(plus.group(1)!), 999);
  return null;
}

bool ppRecipeSuits(FoodRecipe r, int months) {
  final range = ppRecipeAgeRange(r.ageTag);
  return range == null || (months >= range.$1 && months <= range.$2);
}

// The browse before the relevance pass (2026-10-21), kept for revert. Its
// "For <name> now" chip FILTERED: under six months every rail came out empty
// and the sick-day row was the whole page.
class PpRecipesBrowseClassic extends StatefulWidget {
  const PpRecipesBrowseClassic({super.key});

  @override
  State<PpRecipesBrowseClassic> createState() => _PpRecipesBrowseClassicState();
}

class _PpRecipesBrowseClassicState extends State<PpRecipesBrowseClassic> {
  final TextEditingController _q = TextEditingController();
  String _query = '';
  bool _forNow = true;
  String _diet = 'All'; // All | Veg | Non-veg

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _open(FoodRecipe r) {
    pvCommitFeedback();
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'pp/recipe/${r.id}'),
      builder: (_) => FoodRecipeScreen(recipe: r),
    ));
  }

  List<FoodRecipe> _pool(int months) => [
        for (final r in foodCatalog)
          if (!r.comfortOnly &&
              (!_forNow || ppRecipeSuits(r, months)) &&
              (_diet == 'All' || (_diet == 'Veg' ? r.veg : !r.veg)))
            r,
      ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: foodListenable,
      builder: (context, _) {
        final p = pvStorePalette;
        final c = ChildProfileStore.instance;
        final months = c.devAgeInMonths;
        final pool = _pool(months);
        final q = _query.trim().toLowerCase();
        final hits = q.isEmpty
            ? const <FoodRecipe>[]
            : [
                for (final r in pool)
                  if (r.title.toLowerCase().contains(q) ||
                      r.tags.any((t) => t.contains(q)) ||
                      r.ingredients.any((i) => i.toLowerCase().contains(q)))
                    r,
              ];
        return PregToolScaffold(
          hue: 96,
          eyebrow: 'Food',
          mark: IntentMark.cookMark,
          title: 'Recipes',
          intro: '${foodCatalog.length} Indian home recipes, each tagged for an age, with why it is good and '
              'how to make it.',
          children: [
            pregToolPad(TextField(
              key: const ValueKey('pp_recipes_search'),
              controller: _q,
              onChanged: (v) => setState(() => _query = v),
              style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, color: p.ink1),
              decoration: InputDecoration(
                hintText: 'khichdi, ragi, egg, dal...',
                hintStyle: pvManrope(fontSize: 15, color: p.ink3),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: p.ink3),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.ink1)),
              ),
            )),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                KeyedSubtree(
                  key: const ValueKey('pp_recipes_for_now'),
                  child: PvChip(
                    label: 'For ${c.nameMid} now',
                    selected: _forNow,
                    onTap: () => setState(() => _forNow = !_forNow),
                  ),
                ),
                for (final d in const ['All', 'Veg', 'Non-veg']) ...[
                  const SizedBox(width: 8),
                  KeyedSubtree(
                    key: ValueKey('pp_recipes_diet_$d'),
                    child: PvChip(label: d == 'All' ? 'Any diet' : d, selected: _diet == d, onTap: () => setState(() => _diet = d)),
                  ),
                ],
              ]),
            ),
            if (q.isNotEmpty) ...[
              const SizedBox(height: 18),
              if (hits.isEmpty)
                pregToolPad(Text('No recipe by that name. Try one ingredient, like ragi or dal.',
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
              else
                _grid(p, hits),
            ] else ...[
              // `inCategory`, not `category ==`: a doc-format dish is tagged into
              // several categories (the khichdi is Lunch, Dinner and a First
              // Food), and the doc-format dishes lead their rails while the
              // new card is being piloted (2026-10-15).
              for (final cat in kBrowseCategories)
                if (cat != 'All')
                  ..._rail(p, cat, [
                    for (final r in pool) if (r.inCategory(cat) && r.docFormat) r,
                    for (final r in pool) if (r.inCategory(cat) && !r.docFormat) r,
                  ]),
              const SizedBox(height: 26),
              pregToolPad(PvRowGroup(p: p, children: [
                PvListRow(
                  key: const ValueKey('pp_recipes_sick'),
                  p: p,
                  leading: PvMarkWell(p: p, hue: 206, size: 40, icon: Icons.healing_outlined),
                  title: 'When ${c.nameMid} is unwell',
                  line: 'Gentle food for a cold, loose motions or constipation.',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SickDaysScreen())),
                ),
              ])),
            ],
          ],
        );
      },
    );
  }

  String _time(FoodRecipe r) => '${r.prepMin + r.cookMin} min';

  List<Widget> _rail(V2Palette p, String cat, List<FoodRecipe> items) {
    if (items.isEmpty) return const [];
    return [
      const SizedBox(height: 24),
      pregToolPad(Text(cat, style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1))),
      const SizedBox(height: 10),
      SizedBox(
        // The photo card's title sits a few pixels lower than the shelf
        // card's, so a rail holding one grows by that much and no more.
        height: pvShelfRailHeight(MediaQuery.textScalerOf(context)) + (items.any((r) => r.docFormat) ? 14 : 0),
        child: ListView.separated(
          key: ValueKey('pp_recipes_rail_$cat'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) => _card(p, items[i], i),
        ),
      ),
    ];
  }

  Widget _card(V2Palette p, FoodRecipe r, int i, {double? width}) => r.docFormat
      // The new recipe card, on the doc-format dishes only until the user has
      // seen it beside the shelf cards and approved it (2026-10-15 pilot).
      ? FoodPhotoCard(
          key: ValueKey('pp_recipe_${r.id}'),
          recipe: r,
          width: width ?? kPvShelfCardWidth,
          photoHeight: width == null ? kPvShelfPictureHeight : null,
          onTap: () => _open(r),
        )
      : PvShelfCard(
        key: ValueKey('pp_recipe_${r.id}'),
        p: p,
        // Kept inside the warm food hues (orange to leaf green). The old
        // `(80 + i * 26) % 360` ran into lilac and pink from about the seventh
        // card, beside the doc dishes (the user, 2026-10-17: "pink purple").
        hue: 20.0 + (i * 26) % 120,
        kind: PvShelfKind.recipe,
        kindWord: r.ageTag,
        fact: _time(r),
        title: r.title,
        width: width ?? kPvShelfCardWidth,
        onTap: () => _open(r),
      );

  Widget _grid(V2Palette p, List<FoodRecipe> items) => LayoutBuilder(
        builder: (context, box) {
          final w = (box.maxWidth - 40 - 12) / 2;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(spacing: 12, runSpacing: 12, children: [
              for (var i = 0; i < items.length && i < 40; i++) _card(p, items[i], i, width: w),
            ]),
          );
        },
      );
}

// =============================================================================
//  Recipes, ordered by the child (2026-10-21)
// -----------------------------------------------------------------------------
//  The user: Tools > Recipes opened on "When your baby is unwell", not on a
//  recipe. The cause: the "For <name> now" chip FILTERED by age, and the
//  youngest dish is tagged 6+ months, so under six months every rail was empty
//  and the sick-day row at the foot was the whole page. Approved as the
//  Artifact claude.ai/artifact/YERnPpDwamz3Qa7RNCX4AM.
//
//  The page now ORDERS by the child and never filters by age
//  (docs/PERSONALIZATION.md, "The parenting ranker"): age fit, then the
//  family's diet, then a complete page with a photo, then what she saved. A
//  ranking returns every dish it was given, so it cannot hide one.
//
//  Mobbin: one featured dish before the lists (NYT Cooking 7703a07f, Kitchen
//  Stories "Today's Recipe" f7d9718f); "top picks for you" as the first rail
//  (Cherrypick 48b28392); six meal tiles (Blinkit c69b2710, NYT Cooking
//  f96b49e6); rails with an eyebrow over a short title (Hims 484a4184); a
//  saved rail (CREME 715a96fa). One photo per dish, on its card and its page.
//
//  Every tap lands on the same look: a recipe opens FoodRecipeScreen, every
//  "All", "See all", meal tile, collection and Saved opens PpRecipeListScreen.
// =============================================================================

/// Where a dish sits against the child's age.
enum PpRecipeFit { now, later, earlier }

PpRecipeFit ppRecipeFit(FoodRecipe r, int months) {
  final range = ppRecipeAgeRange(r.ageTag);
  if (range == null) return PpRecipeFit.now;
  if (months < range.$1) return PpRecipeFit.later;
  if (months > range.$2) return PpRecipeFit.earlier;
  return PpRecipeFit.now;
}

/// The first month after [months] at which new dishes open, or null.
int? ppRecipeNextStart(Iterable<FoodRecipe> pool, int months) {
  int? best;
  for (final r in pool) {
    final range = ppRecipeAgeRange(r.ageTag);
    if (range == null || range.$1 <= months) continue;
    if (best == null || range.$1 < best) best = range.$1;
  }
  return best;
}

/// The diet chip the family's profile presets. Derived, never asked: Jain
/// families cook vegetarian here, and no diet given means every dish.
String ppRecipeDietFor(DietPreference? d) => switch (d) {
      DietPreference.vegetarian || DietPreference.jain => 'veg',
      DietPreference.vegan => 'vegan',
      DietPreference.eggetarian => 'egg',
      _ => 'all',
    };

/// Whether [r] fits the diet chip. An egg dish is neither veg nor non-veg.
bool ppRecipeDietOk(FoodRecipe r, String diet) => switch (diet) {
      'veg' => r.veg,
      'vegan' => r.vegan,
      'egg' => r.veg || r.egg,
      'nonveg' => !r.veg && !r.egg,
      _ => true,
    };

/// THE PARENTING RECIPE RANKER (2026-10-21). Returns every dish it was given,
/// reordered; ties keep the catalogue order. Strongest first:
///  1. age fit: made for now, then the next band to open, then dishes for
///     younger babies (still a good meal), then further ahead;
///  2. the diet chip, when the pool still holds other diets;
///  3. a dish with its photo, then one with the complete doc page;
///  4. a dish she saved;
///  5. the tighter band: "7 to 8 mo" beats "12 mo+" for a seven-month-old.
List<FoodRecipe> ppRankRecipes(
  Iterable<FoodRecipe> pool, {
  required int months,
  String diet = 'all',
  Set<String> saved = const {},
}) {
  final list = pool.toList();
  final next = ppRecipeNextStart(list, months);
  int score(FoodRecipe r) {
    final range = ppRecipeAgeRange(r.ageTag);
    final fit = switch (ppRecipeFit(r, months)) {
      PpRecipeFit.now => 0,
      PpRecipeFit.later => range!.$1 == next ? 1 : 3,
      PpRecipeFit.earlier => 2,
    };
    final span = range == null ? 99 : (range.$2 - range.$1).clamp(0, 99);
    return fit * 10000 +
        (ppRecipeDietOk(r, diet) ? 0 : 1000) +
        (r.photo != null ? 0 : 200) +
        (r.docFormat ? 0 : 100) +
        (saved.contains(r.id) ? 0 : 50) +
        span;
  }

  final indexed = [for (var i = 0; i < list.length; i++) (i, list[i], score(list[i]))];
  indexed.sort((a, b) => a.$3 != b.$3 ? a.$3.compareTo(b.$3) : a.$1.compareTo(b.$1));
  return [for (final e in indexed) e.$2];
}

/// Today's pick: one of the first few dishes for now, a different one each
/// day, so the page is never the same dish twice in a row.
FoodRecipe? ppRecipeTodayPick(List<FoodRecipe> rankedNow, DateTime day) {
  if (rankedNow.isEmpty) return null;
  final n = rankedNow.length < 7 ? rankedNow.length : 7;
  return rankedNow[day.difference(DateTime(2026)).inDays.abs() % n];
}

/// '9 months', '2 years'.
String ppRecipeAgeWord(int months) =>
    months < 24 ? '$months months' : '${months ~/ 12} years';

/// The meal tile's drawn mark.
IntentMark ppRecipeCategoryMark(String cat) => switch (cat) {
      'First Foods' => IntentMark.spoonMark,
      'Finger Foods' => IntentMark.snackMark,
      'Breakfast' => IntentMark.sunMark,
      'Lunch' => IntentMark.bowlMark,
      'Dinner' => IntentMark.moonMark,
      'Snacks' => IntentMark.snackMark,
      'Smoothies' => IntentMark.dropMark,
      'Soups' => IntentMark.chaiMark,
      'Travel Food' => IntentMark.bagMark,
      'Toddler Meals' => IntentMark.forkMark,
      'Healthy Desserts' => IntentMark.sweetMark,
      _ => IntentMark.cookMark,
    };

String _sentence(String s) => s.isEmpty ? s : s[0] + s.substring(1).toLowerCase();

void _ppOpenRecipe(BuildContext context, FoodRecipe r) {
  pvCommitFeedback();
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: 'pp/recipe/${r.id}'),
    builder: (_) => FoodRecipeScreen(recipe: r),
  ));
}

/// One photo card per dish, the same in every rail and grid.
Widget _ppRecipeCard(BuildContext context, FoodRecipe r, {double? width}) => FoodPhotoCard(
      key: ValueKey('pp_recipe_${r.id}'),
      recipe: r,
      width: width ?? kPvShelfCardWidth,
      photoHeight: width == null ? kPvShelfPictureHeight : null,
      onTap: () => _ppOpenRecipe(context, r),
    );

Widget _ppRecipeGrid(BuildContext context, List<FoodRecipe> items, {Key? key}) => LayoutBuilder(
      key: key,
      builder: (context, box) {
        final w = (box.maxWidth - 40 - 12) / 2;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(spacing: 12, runSpacing: 16, children: [
            for (final r in items) _ppRecipeCard(context, r, width: w),
          ]),
        );
      },
    );

Widget _ppRecipeHead(V2Palette p, String eyebrow, String? title, {String? action, VoidCallback? onAction, Key? actionKey}) =>
    pregToolPad(Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(eyebrow.toUpperCase(),
                style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
            if (title != null) ...[
              const SizedBox(height: 3),
              Text(title, style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
            ],
          ]),
        ),
        if (action != null)
          Semantics(
            button: true,
            child: PvPress(child: GestureDetector(
              key: actionKey,
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 2),
                child: Text(action,
                    style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)
                        .copyWith(decoration: TextDecoration.underline)),
              ),
            )),
          ),
      ]),
    ));

class PpRecipesScreen extends StatefulWidget {
  const PpRecipesScreen({super.key});

  @override
  State<PpRecipesScreen> createState() => _PpRecipesScreenState();
}

class _PpRecipesScreenState extends State<PpRecipesScreen> {
  final TextEditingController _q = TextEditingController();
  String _query = '';

  /// Null until she taps a chip; until then the family's diet decides.
  String? _diet;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _push(Widget w) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));

  void _list(String eyebrow, String title, List<FoodRecipe> Function() recipes, {String? intro, bool split = true}) =>
      _push(PpRecipeListScreen(eyebrow: eyebrow, title: title, intro: intro, recipes: recipes, splitByAge: split));

  void _openSolids() {
    for (final a in kPpFeedingSection.areas) {
      for (final page in a.pages) {
        if (page.id == 'solids_when') return ppOpenPage(context, kPpFeedingSection, page);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([foodListenable, ChildProfileStore.instance, FamilyProfileStore.instance]),
      builder: (context, _) {
        final p = pvStorePalette;
        final c = ChildProfileStore.instance;
        final months = c.devAgeInMonths;
        final name = c.nameMid;
        final profileDiet = ppRecipeDietFor(FamilyProfileStore.instance.diet);
        final diet = _diet ?? profileDiet;
        final saved = FoodStore.instance.saved;
        final savedIds = {for (final r in saved) r.id};
        List<FoodRecipe> rank(Iterable<FoodRecipe> rs) =>
            ppRankRecipes(rs, months: months, diet: diet, saved: savedIds);
        final pool = [
          for (final r in foodCatalog)
            if (!r.comfortOnly && ppRecipeDietOk(r, diet)) r,
        ];
        final ranked = rank(pool);
        final now = [for (final r in ranked) if (ppRecipeFit(r, months) == PpRecipeFit.now) r];
        final nextStart = ppRecipeNextStart(pool, months);
        final next = nextStart == null
            ? const <FoodRecipe>[]
            : [for (final r in ranked) if (ppRecipeAgeRange(r.ageTag)?.$1 == nextStart) r];
        final pick = ppRecipeTodayPick(now, DateTime.now());
        final q = _query.trim().toLowerCase();
        final hits = q.isEmpty
            ? const <FoodRecipe>[]
            : [
                for (final r in ranked)
                  if (r.title.toLowerCase().contains(q) ||
                      r.tags.any((t) => t.contains(q)) ||
                      r.ingredients.any((i) => i.toLowerCase().contains(q)))
                    r,
              ];
        // The six meal tiles, the ones with the most dishes for now first.
        final cats = [
          for (final cat in kBrowseCategories)
            if (cat != 'All' && pool.any((r) => r.inCategory(cat)))
              (
                cat,
                now.where((r) => r.inCategory(cat)).length,
                ppRecipeNextStart(pool.where((r) => r.inCategory(cat)), months),
              ),
        ]..sort((a, b) => b.$2.compareTo(a.$2));
        final diets = [
          if (profileDiet == 'vegan' || _diet == 'vegan') ('vegan', 'Vegan'),
          ('veg', 'Veg'),
          ('egg', 'Egg'),
          ('nonveg', 'Non-veg'),
          ('all', 'Any diet'),
        ];
        return PregToolScaffold(
          hue: 96,
          eyebrow: 'Food',
          mark: IntentMark.cookMark,
          title: 'Recipes',
          intro: 'Indian home food for each age, from first tastes to the family plate.',
          children: [
            pregToolPad(TextField(
              key: const ValueKey('pp_recipes_search'),
              controller: _q,
              onChanged: (v) => setState(() => _query = v),
              style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, color: p.ink1),
              decoration: InputDecoration(
                hintText: 'Search khichdi, ragi, dal...',
                hintStyle: pvManrope(fontSize: 15, color: p.ink3),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: p.ink3),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.ink1)),
              ),
            )),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                for (var i = 0; i < diets.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  KeyedSubtree(
                    key: ValueKey('pp_recipes_diet_${diets[i].$1}'),
                    child: PvChip(
                      label: diets[i].$2,
                      selected: diet == diets[i].$1,
                      onTap: () => setState(() => _diet = diets[i].$1),
                    ),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            pregToolPad(Text.rich(
              key: const ValueKey('pp_recipes_age_line'),
              TextSpan(children: [
                const TextSpan(text: 'Showing '),
                TextSpan(text: "$name's age first", style: TextStyle(fontWeight: FontWeight.w700, color: p.ink1)),
                TextSpan(text: ' · ${c.ageLabel}'),
              ]),
              style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2),
            )),
            if (q.isNotEmpty) ...[
              const SizedBox(height: 18),
              if (hits.isEmpty)
                pregToolPad(Text('No recipe by that name. Try one ingredient, like ragi or dal.',
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
              else
                _ppRecipeGrid(context, hits, key: const ValueKey('pp_recipes_hits')),
            ] else ...[
              // ---- first view: today's pick, or "get ready" before solids ----
              if (pick == null) ...[
                const SizedBox(height: 18),
                _ready(p, name, months),
              ] else ...[
                _ppRecipeHead(p, "Today's pick for $name", null),
                _pick(p, pick, name),
              ],
              if (now.length > 1) ...[
                _ppRecipeHead(p, 'Right for $name now', 'At ${c.ageLabel}',
                    action: 'All ${now.length}',
                    actionKey: const ValueKey('pp_recipes_now_all'),
                    onAction: () => _list('Right for $name now', 'At ${c.ageLabel}',
                        () => [for (final r in rank(pool)) if (ppRecipeFit(r, months) == PpRecipeFit.now) r],
                        split: false)),
                _rail('now', [for (final r in now) if (r != pick) r].take(12).toList()),
              ],
              // ---- by meal ---------------------------------------------------
              _ppRecipeHead(p, 'Browse', 'By meal',
                  action: 'All ${pool.length}',
                  actionKey: const ValueKey('pp_recipes_all'),
                  onAction: () => _list('Recipes', 'Every recipe', () => rank(pool))),
              _tiles(p, months, [for (final c in cats.take(6)) c], pool, rank),
              // ---- what opens next ---------------------------------------------
              if (next.isNotEmpty) ...[
                _ppRecipeHead(p, 'Coming up at ${ppRecipeAgeWord(nextStart!)}',
                    now.isEmpty ? 'First tastes' : 'Next to try',
                    action: 'See all',
                    actionKey: const ValueKey('pp_recipes_next_all'),
                    onAction: () => _list('Coming up at ${ppRecipeAgeWord(nextStart)}',
                        now.isEmpty ? 'First tastes' : 'Next to try',
                        () => [for (final r in rank(pool)) if (ppRecipeAgeRange(r.ageTag)?.$1 == nextStart) r],
                        intro: 'For when $name gets there. Each page says the age it is made for.',
                        split: false)),
                _rail('next', next.take(12).toList()),
              ],
              // ---- saved -------------------------------------------------------
              _ppRecipeHead(p, 'For later', 'Your saved dishes',
                  action: saved.isEmpty ? null : 'See all',
                  actionKey: const ValueKey('pp_recipes_saved_all'),
                  onAction: () => _push(const FoodSavedScreen())),
              if (saved.isEmpty)
                pregToolPad(Container(
                  key: const ValueKey('pp_recipes_saved_empty'),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: p.line)),
                  child: Row(children: [
                    Icon(Icons.bookmark_outline_rounded, size: 20, color: p.ink1),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          pick == null
                              ? 'Tap the bookmark on any dish and it waits here for when $name is ready.'
                              : 'Tap the bookmark on any dish and it waits here.',
                          style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
                    ),
                  ]),
                ))
              else
                _rail('saved', saved),
              // ---- collections -----------------------------------------------
              _ppRecipeHead(p, 'When you need it', 'Collections'),
              pregToolPad(PvRowGroup(p: p, children: [
                PvListRow(
                  key: const ValueKey('pp_recipes_sick'),
                  p: p,
                  leading: PvMarkWell(p: p, hue: 30, size: 40, mark: IntentMark.thermoMark),
                  title: 'When $name is unwell',
                  // Under six months milk is the whole of a poorly baby's food:
                  // the row goes to the doctor guidance, never to a meal.
                  line: months < 6
                      ? 'Under 6 months, milk is the food. See when to call the doctor.'
                      : 'Gentle food for a cold, loose motions or constipation.',
                  lineMaxLines: 2,
                  // Under 6 months the unwell row goes to Is my baby OK?, the one
                  // symptom tool, on illness, tummy and feeding (tools pass H2,
                  // 2026-10-25). Was the newborn feeding check: the label did not
                  // match the landing. Kept for revert:
                  // onTap: () => _push(months < 6 ? const PpBabyOkCheckScreen() : const SickDaysScreen()),
                  onTap: () => _push(months < 6
                      ? const WhatChangedScreen(initialCategories: ['Illness', 'Tummy', 'Feeding'])
                      : const SickDaysScreen()),
                ),
                for (final (cat, title, line) in [
                  ('Travel Food', 'Food for a day out', 'dishes that travel well.'),
                  ('Healthy Desserts', 'Something sweet', 'soft, gently sweet desserts.'),
                ])
                  if (pool.any((r) => r.inCategory(cat)))
                    PvListRow(
                      key: ValueKey('pp_recipes_collection_$cat'),
                      p: p,
                      leading: PvMarkWell(p: p, hue: 30, size: 40, mark: ppRecipeCategoryMark(cat)),
                      title: title,
                      line: '${pool.where((r) => r.inCategory(cat)).length} $line',
                      onTap: () => _list('Collection', title, () => rank(pool.where((r) => r.inCategory(cat)))),
                    ),
                PvListRow(
                  key: const ValueKey('pp_recipes_can_eat'),
                  p: p,
                  leading: PvMarkWell(p: p, hue: 30, size: 40, mark: IntentMark.questionMark),
                  title: 'Can my baby eat this?',
                  line: 'Look up any food and the age it is safe from.',
                  onTap: () => _push(const PpBabyFoodCheckScreen()),
                ),
              ])),
              const SizedBox(height: 24),
            ],
          ],
        );
      },
    );
  }

  // ---- before solids: get ready, never an empty page ----------------------
  Widget _ready(V2Palette p, String name, int months) {
    final weeks = ((6 - months) * 4.35).round().clamp(1, 26);
    return pregToolPad(Container(
      key: const ValueKey('pp_recipes_ready'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('FOR ${name.toUpperCase()} · ${ChildProfileStore.instance.ageLabel.toUpperCase()}',
            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
        const SizedBox(height: 6),
        Text('Solids start around 6 months',
            style: pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
        const SizedBox(height: 8),
        Text(
            'Until then, milk is all $name needs. In about $weeks weeks, watch for the signs: sitting with support, '
            'reaching for your food, and no longer pushing the spoon out with the tongue.',
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        const SizedBox(height: 12),
        Semantics(
          label: '$months of 6 months',
          child: Row(children: [
            for (var i = 0; i < 6; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(color: i < months ? p.ink1 : p.line, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 14),
        KeyedSubtree(
          key: const ValueKey('pp_recipes_solids'),
          child: PvCommit(label: 'How to start solids', onTap: _openSolids),
        ),
      ]),
    ));
  }

  // ---- today's pick: one dish, why, and the age-fit tick ------------------
  Widget _pick(V2Palette p, FoodRecipe r, String name) => pregToolPad(Semantics(
        button: true,
        label: r.title,
        child: PvPress(child: GestureDetector(
          key: const ValueKey('pp_recipes_pick'),
          onTap: () => _ppOpenRecipe(context, r),
          behavior: HitTestBehavior.opaque,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(children: [
                FoodPhoto(recipe: r, height: 190, radius: 0),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: IgnorePointer(child: foodPhotoDisc(size: 28, child: foodDietMark(r.diet, size: 13))),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${foodAgeLabel(r.ageTag)} · ${r.category}'.toUpperCase(),
                      style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: p.ink3)),
                  const SizedBox(height: 4),
                  Text(r.title,
                      style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
                  const SizedBox(height: 4),
                  Text(ppFill(r.subtitle),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: p.ink1),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text('Right for $name now · ${r.prepMin + r.cookMin} min',
                          style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink1)),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        )),
      ));

  Widget _rail(String id, List<FoodRecipe> items) => SizedBox(
        // The photo card's title sits a few pixels lower than the shelf card's.
        height: pvShelfRailHeight(MediaQuery.textScalerOf(context)) + 14,
        child: ListView.separated(
          key: ValueKey('pp_recipes_rail_$id'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) => _ppRecipeCard(context, items[i]),
        ),
      );

  // ---- six meal tiles, drawn marks, "N for now" -----------------------------
  Widget _tiles(V2Palette p, int months, List<(String, int, int?)> cats, List<FoodRecipe> pool,
          List<FoodRecipe> Function(Iterable<FoodRecipe>) rank) =>
      LayoutBuilder(builder: (context, box) {
        final w = (box.maxWidth - 40 - 20) / 3;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(spacing: 10, runSpacing: 10, children: [
            for (final (cat, forNow, from) in cats)
              Semantics(
                button: true,
                label: _sentence(cat),
                child: PvPress(child: GestureDetector(
                  key: ValueKey('pp_recipes_meal_$cat'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _list('By meal', _sentence(cat), () => rank(pool.where((r) => r.inCategory(cat)))),
                  child: Container(
                    width: w,
                    padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
                    decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(14)),
                    child: Column(children: [
                      PvMarkWell(p: p, hue: 30, size: 40, mark: ppRecipeCategoryMark(cat)),
                      const SizedBox(height: 6),
                      Text(_sentence(cat),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.2, color: p.ink1)),
                      const SizedBox(height: 2),
                      Text(forNow > 0 ? '$forNow for now' : (from != null ? 'From ${ppRecipeAgeWord(from)}' : 'For younger'),
                          textAlign: TextAlign.center,
                          style: pvManrope(fontSize: 11, color: p.ink3)),
                    ]),
                  ),
                )),
              ),
          ]),
        );
      });
}

/// The one list behind every "All", "See all", meal tile, collection and
/// Saved (2026-10-21): the dish's photo card in two columns, the child's age
/// first, other ages after under their own heading. A tap never lands on a
/// screen of another look.
class PpRecipeListScreen extends StatelessWidget {
  const PpRecipeListScreen({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.recipes,
    this.intro,
    this.splitByAge = true,
    this.empty,
  });

  final String eyebrow;
  final String title;
  final String? intro;

  /// Read on every rebuild, so saving or unsaving shows at once.
  final List<FoodRecipe> Function() recipes;
  final bool splitByAge;
  final String? empty;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: foodListenable,
        builder: (context, _) {
          final p = pvStorePalette;
          final c = ChildProfileStore.instance;
          final months = c.devAgeInMonths;
          final list = recipes();
          final now = [for (final r in list) if (ppRecipeFit(r, months) == PpRecipeFit.now) r];
          final rest = [for (final r in list) if (ppRecipeFit(r, months) != PpRecipeFit.now) r];
          Widget head(String t) => pregToolPad(Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: Text(t, style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
              ));
          return PregToolScaffold(
            hue: 96,
            eyebrow: eyebrow,
            mark: IntentMark.cookMark,
            title: title,
            intro: intro ?? (list.isEmpty ? null : '${list.length} ${list.length == 1 ? 'dish' : 'dishes'}, ${c.nameMid}\'s age first.'),
            children: [
              if (list.isEmpty)
                pregToolPad(Text(empty ?? 'Nothing here yet.',
                    key: const ValueKey('pp_recipe_list_empty'),
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
              else if (splitByAge && now.isNotEmpty && rest.isNotEmpty) ...[
                head('Right for ${c.nameMid} now'),
                _ppRecipeGrid(context, now, key: const ValueKey('pp_recipe_list_now')),
                const SizedBox(height: 26),
                head('For other ages'),
                _ppRecipeGrid(context, rest, key: const ValueKey('pp_recipe_list_rest')),
              ] else
                _ppRecipeGrid(context, list, key: const ValueKey('pp_recipe_list_all')),
              const SizedBox(height: 24),
            ],
          );
        },
      );
}
