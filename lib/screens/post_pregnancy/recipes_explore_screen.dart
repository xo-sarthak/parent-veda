// =============================================================================
//  Recipes — the redesigned home. Browse, don't filter.
// -----------------------------------------------------------------------------
//  Built to the Recipes brief, and the first of the four Explore redesigns, so
//  the other three (Recommendations, Read, Courses) reuse its shape through
//  pp_explore_kit.dart. The briefs asked for exactly that: "the Recommendations
//  screen should feel like its sibling".
//
//  Page order, as specified:
//      expert banner -> search -> Smart Meal Planner -> diet chips
//      -> ten horizontal sections, each with See more
//
//  THE OLD SCREEN IS UNTOUCHED. recipes_screen.dart still exists and still
//  works; the Explore row that opened it is commented in place beside the new
//  one. Everything the old home carried and this one does not — the Nutrition
//  Focus, the Smart Meal Builder, the shopping list, saved & recently cooked,
//  the sick-mode doorway — is still reachable from the meal planner and from
//  the sections here, and none of those screens was edited.
//
//  WHY SECTIONS INSTEAD OF ONE FILTERED LIST. The old home showed one list and
//  four filter controls. That works if you know what you want and is useless at
//  6pm when you do not — the brief's own point: "instead of forcing users to
//  browse hundreds of recipes, they should naturally discover recipes based on
//  meal type". So meal type became the structure rather than a dropdown.
//
//  ⚠️ ONE FILTER, GLOBALLY. Diet (All / Veg / Vegan / Non-veg) is the only
//  filter on this page and it changes every section at once, per the brief.
//  Immunity was a filter on the old home; here it is a SECTION, which is what
//  the brief asked for and is also better — it is a thing to browse, not a
//  switch to remember to flip.
// =============================================================================

import 'package:flutter/material.dart';

import 'food_mealplan_screen.dart';
import 'food_recipe_screen.dart';
import 'pp_common.dart';
import 'pp_explore_kit.dart';
import 'pp_food_data.dart';

// =============================================================================
//  The ten sections
// -----------------------------------------------------------------------------
//  Defined as data, once, so the home and every "See more" page read the same
//  membership rule. A section whose contents are decided in two places is a
//  section that eventually shows a recipe on one screen and not the other.
// =============================================================================

class RecipeSection {
  const RecipeSection({
    required this.title,
    required this.icon,
    required this.accent,
    required this.match,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final bool Function(FoodRecipe) match;

  List<FoodRecipe> of(List<FoodRecipe> pool) => pool.where(match).toList();
}

const Color _cWarm = Color(0xFFC2661E);
const Color _cGreen = Color(0xFF3E7A5E);
const Color _cPurple = ppPurple;
const Color _cBlue = Color(0xFF3E6BA8);
const Color _cCoral = ppCoral;

/// Beverages have no category of their own in the data, so they are matched on
/// what they actually are — drinks. Listed explicitly rather than guessed from
/// the title, because "Ragi & banana smoothie" and "Soft tomato rasam" are both
/// liquid and only one of them is a drink.
const Set<String> _kBeverageIds = {
  'ragismoothie',
  'turmericmilk',
  'coconutwater',
  'moongwater',
};

final List<RecipeSection> kRecipeSections = [
  RecipeSection(
    title: 'Lunch / Dinner',
    icon: Icons.dinner_dining_outlined,
    accent: _cWarm,
    match: (r) => r.category == 'Lunch' || r.category == 'Dinner',
  ),
  RecipeSection(
    title: 'Breakfast',
    icon: Icons.free_breakfast_outlined,
    accent: _cWarm,
    match: (r) => r.category == 'Breakfast',
  ),
  RecipeSection(
    title: 'Immunity boosters',
    icon: Icons.shield_moon_outlined,
    accent: _cGreen,
    // Was a filter switch on the old home. A section is better: it is
    // something to browse rather than something to remember to turn on.
    match: (r) => r.immunity,
  ),
  RecipeSection(
    title: 'Snacks',
    icon: Icons.cookie_outlined,
    accent: _cWarm,
    match: (r) => r.category == 'Snacks',
  ),
  RecipeSection(
    title: 'Beverages',
    icon: Icons.local_cafe_outlined,
    accent: _cBlue,
    match: (r) => _kBeverageIds.contains(r.id) || r.category == 'Smoothies',
  ),
  RecipeSection(
    title: 'Soups',
    icon: Icons.soup_kitchen_outlined,
    accent: _cCoral,
    match: (r) => r.category == 'Soups',
  ),
  RecipeSection(
    title: 'Travel food',
    icon: Icons.luggage_outlined,
    accent: _cBlue,
    match: (r) => r.category == 'Travel Food',
  ),
  RecipeSection(
    title: 'Desserts',
    icon: Icons.icecream_outlined,
    accent: _cCoral,
    match: (r) => r.category == 'Healthy Desserts',
  ),
  RecipeSection(
    title: 'Finger foods',
    icon: Icons.back_hand_outlined,
    accent: _cPurple,
    match: (r) => r.category == 'Finger Foods' || r.category == 'First Foods',
  ),
  RecipeSection(
    title: 'Sick-day meals',
    icon: Icons.healing_outlined,
    accent: _cGreen,
    match: (r) => r.category == 'Sick-Day Meals' || r.comfortOnly,
  ),
];

/// The diet filter, applied once and shared by every section.
List<FoodRecipe> recipesForDiet(String diet) {
  switch (diet) {
    case 'Veg':
      return kFoodRecipes.where((r) => r.veg).toList();
    case 'Vegan':
      return kFoodRecipes.where((r) => r.vegan).toList();
    case 'Non-veg':
      return kFoodRecipes.where((r) => !r.veg).toList();
    default:
      return kFoodRecipes;
  }
}

// =============================================================================
//  The screen
// =============================================================================

class RecipesExploreScreen extends StatefulWidget {
  const RecipesExploreScreen({super.key});

  @override
  State<RecipesExploreScreen> createState() => _RecipesExploreScreenState();
}

class _RecipesExploreScreenState extends State<RecipesExploreScreen> {
  final _search = TextEditingController();
  String _q = '';
  String _diet = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _push(Widget s) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  List<FoodRecipe> get _pool => recipesForDiet(_diet);

  /// Search runs across every recipe, and across more than the title — a
  /// parent looking for "iron" or "paneer" is searching the contents, not the
  /// name.
  List<FoodRecipe> get _results {
    final t = _q.trim().toLowerCase();
    if (t.isEmpty) return const [];
    return _pool.where((r) {
      return r.title.toLowerCase().contains(t) ||
          r.subtitle.toLowerCase().contains(t) ||
          r.category.toLowerCase().contains(t) ||
          r.highlight.toLowerCase().contains(t) ||
          r.tags.any((x) => x.toLowerCase().contains(t)) ||
          r.ingredients.any((x) => x.toLowerCase().contains(t));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final searching = _q.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ppBack(context, 'Explore'),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text('Recipes', style: ppFraunces(31, h: 1.05)),
            ),

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: ExpertCuratedBanner(
                text: 'Recipes curated by paediatric nutrition experts for your '
                    'child’s age, nutritional needs and stage of development.',
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ExploreSearchBar(
                controller: _search,
                hint: 'Search recipes…',
                onChanged: (v) => setState(() => _q = v),
              ),
            ),

            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Align(
                alignment: Alignment.centerRight,
                child: _mealPlannerCta(),
              ),
            ),

            const SizedBox(height: 14),
            ExploreFilterChips(
              labels: const ['All', 'Veg', 'Vegan', 'Non-veg'],
              selected: _diet,
              onSelect: (v) => setState(() => _diet = v),
              icons: const [
                Icons.blur_on_rounded,
                Icons.eco_outlined,
                Icons.spa_outlined,
                Icons.egg_alt_outlined,
              ],
            ),

            const SizedBox(height: 22),
            if (searching) ..._searchResults() else ..._sections(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// The brief: "Tapping opens the existing Meal Planner feature. Do NOT
  /// redesign Meal Planner." So this is a link and nothing more.
  Widget _mealPlannerCta() => GestureDetector(
        onTap: () => _push(const FoodMealPlanScreen()),
        behavior: HitTestBehavior.opaque,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.calendar_month_outlined, size: 16, color: ppPurple),
          const SizedBox(width: 7),
          Text('Smart Meal Planner',
              style: ppBody(13, color: ppPurple, w: FontWeight.w800)),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right_rounded, size: 18, color: ppPurple),
        ]),
      );

  // ---- sections ------------------------------------------------------------

  List<Widget> _sections() {
    final pool = _pool;
    final out = <Widget>[];
    var rendered = 0;

    for (final s in kRecipeSections) {
      final items = s.of(pool);
      // A section with nothing in it under the current diet is skipped rather
      // than rendered empty — ten "nothing here" cards is not a page. The
      // whole-page empty state below covers the case where the diet leaves
      // nothing at all, which is the case a parent actually needs told.
      if (items.isEmpty) continue;
      rendered++;
      out
        ..add(ExploreSectionHeader(
          title: s.title,
          onSeeMore: () => _push(RecipeCategoryScreen(section: s, diet: _diet)),
        ))
        ..add(const SizedBox(height: 12))
        // The brief: "Each section should initially show only 4–6 recipes.
        // Remaining recipes appear inside See More."
        ..add(ExploreRail(
          height: 176,
          itemWidth: 150,
          children: [
            for (final r in items.take(6)) _card(r, s),
          ],
        ))
        ..add(const SizedBox(height: 26));
    }

    if (rendered == 0) {
      out.add(ExploreEmpty(
        title: 'No ${_diet.toLowerCase()} recipes yet',
        subtitle:
            'Nothing in the collection matches that diet at the moment. Try '
            'another one — everything else is still here.',
        icon: Icons.no_meals_outlined,
        cta: 'Show all recipes',
        onCta: () => setState(() => _diet = 'All'),
      ));
    }
    return out;
  }

  Widget _card(FoodRecipe r, RecipeSection s) => GestureDetector(
        onTap: () => _push(FoodRecipeScreen(recipe: r)),
        behavior: HitTestBehavior.opaque,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ExploreThumb(
            icon: s.icon,
            accent: s.accent,
            height: 104,
            topLeft: ExploreBadge(label: r.ageTag),
            // The brief: "Small Play icon if recipe has video."
            centre: r.relatedVideoId == null
                ? null
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow_rounded,
                            size: 15, color: ppPurple),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 9),
          Text(r.title,
              style: ppJakarta(13).copyWith(height: 1.25),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('${r.prepMin + r.cookMin} min',
              style: ppBody(11, color: ppMuted)),
        ]),
      );

  // ---- search --------------------------------------------------------------

  List<Widget> _searchResults() {
    final results = _results;
    if (results.isEmpty) {
      return [
        ExploreEmpty(
          title: 'No recipes found',
          subtitle: 'Try searching for something else — an ingredient works '
              'as well as a dish name.',
          cta: 'Clear search',
          onCta: () {
            _search.clear();
            setState(() => _q = '');
            FocusScope.of(context).unfocus();
          },
        ),
      ];
    }
    return [
      ExploreSectionHeader(
        title: '${results.length} recipe${results.length == 1 ? '' : 's'}',
        subtitle: 'Matching “${_q.trim()}”',
      ),
      const SizedBox(height: 12),
      for (final r in results)
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
          child: RecipeResultRow(recipe: r, onTap: () => _push(FoodRecipeScreen(recipe: r))),
        ),
    ];
  }
}

/// A recipe as a full-width row — used by search and by the listing pages.
class RecipeResultRow extends StatelessWidget {
  const RecipeResultRow({super.key, required this.recipe, required this.onTap});

  final FoodRecipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ppBorder),
          ),
          child: Row(children: [
            SizedBox(
              width: 64,
              child: ExploreThumb(
                icon: Icons.restaurant_menu_rounded,
                accent: ppPurple,
                height: 64,
                radius: 12,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(recipe.title,
                    style: ppJakarta(13.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(recipe.subtitle,
                    style: ppBody(11.5, color: ppMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Row(children: [
                  ExploreBadge(label: recipe.ageTag, color: ppPanel),
                  const SizedBox(width: 7),
                  Text('${recipe.prepMin + recipe.cookMin} min',
                      style: ppBody(11, color: ppMuted)),
                ]),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}

// =============================================================================
//  "See more" — one category, everything in it
// -----------------------------------------------------------------------------
//  The brief: these pages retain search, the diet filter and sorting.
// =============================================================================

class RecipeCategoryScreen extends StatefulWidget {
  const RecipeCategoryScreen({
    super.key,
    required this.section,
    required this.diet,
  });

  final RecipeSection section;

  /// Inherited from the home, so tapping See more does not silently widen a
  /// diet a parent has chosen.
  final String diet;

  @override
  State<RecipeCategoryScreen> createState() => _RecipeCategoryScreenState();
}

class _RecipeCategoryScreenState extends State<RecipeCategoryScreen> {
  final _search = TextEditingController();
  String _q = '';
  late String _diet = widget.diet;
  String _sort = 'Age';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<FoodRecipe> get _items {
    var list = widget.section.of(recipesForDiet(_diet));
    final t = _q.trim().toLowerCase();
    if (t.isNotEmpty) {
      list = list
          .where((r) =>
              r.title.toLowerCase().contains(t) ||
              r.subtitle.toLowerCase().contains(t) ||
              r.tags.any((x) => x.toLowerCase().contains(t)))
          .toList();
    }
    switch (_sort) {
      case 'Quickest':
        list.sort((a, b) =>
            (a.prepMin + a.cookMin).compareTo(b.prepMin + b.cookMin));
      case 'A–Z':
        list.sort((a, b) => a.title.compareTo(b.title));
      default:
        // By age, youngest first — the order a parent actually scans in, since
        // the first question is always "can he have this yet".
        list.sort((a, b) => a.ageTag.compareTo(b.ageTag));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ppBack(context, 'Recipes'),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(widget.section.title, style: ppFraunces(28, h: 1.05)),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ExploreSearchBar(
                controller: _search,
                hint: 'Search in ${widget.section.title.toLowerCase()}…',
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            const SizedBox(height: 14),
            ExploreFilterChips(
              labels: const ['All', 'Veg', 'Vegan', 'Non-veg'],
              selected: _diet,
              onSelect: (v) => setState(() => _diet = v),
            ),
            const SizedBox(height: 10),
            ExploreFilterChips(
              labels: const ['Age', 'Quickest', 'A–Z'],
              selected: _sort,
              onSelect: (v) => setState(() => _sort = v),
            ),
            const SizedBox(height: 20),
            if (items.isEmpty)
              ExploreEmpty(
                title: 'Nothing here yet',
                subtitle: 'No ${widget.section.title.toLowerCase()} match that '
                    'search and diet.',
                cta: 'Clear',
                onCta: () {
                  _search.clear();
                  setState(() {
                    _q = '';
                    _diet = 'All';
                  });
                },
              )
            else
              for (final r in items)
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                  child: RecipeResultRow(
                    recipe: r,
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => FoodRecipeScreen(recipe: r))),
                  ),
                ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
