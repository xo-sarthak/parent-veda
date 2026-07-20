// =============================================================================
//  Recipes - LEGACY content model + data (RecipeItem)
// -----------------------------------------------------------------------------
//  After the Recipes+Food merge, the live unified Recipes section runs on the
//  richer FoodRecipe / FoodStore model in pp_food_data.dart. This legacy model is
//  KEPT LIVE (not deleted) because it still backs: the retired RecipePageScreen
//  ('Recipe page' smoke test), Ask Veda recipe sourcing (parenting_veda iterates
//  kRecipes), and the recipes-flow unit tests (normalRecipes / sickRecipes). Do
//  not add new dishes here - add them to pp_food_data.dart's kFoodRecipes.
//
//  --- original doc -------------------------------------------------------------
//  The Veggie Maggi recipe is a faithful build of Claude Design "post pregnancy
//  app.dc.html" · S15·detail; the rest carry the light fields the list + filters
//  need, so veg/non-veg, category and sick-situation filtering all work.
// =============================================================================

class RecipeItem {
  const RecipeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.meal,
    required this.category,
    required this.veg,
    required this.kcal,
    required this.protein,
    required this.fibre,
    required this.description,
    this.serves = 2,
    this.difficulty = 'Easy',
    this.healthier = false,
    this.recommended = false,
    this.hasVideo = false,
    this.vegan = false, // veg AND vegan (no dairy/egg); overrides the veg dot
    this.immunity = false, // immunity-booster tag
    this.situation, // sick-day situation; null = normal recipe
  });

  final String id;
  final String title;
  final String subtitle;
  final int minutes;
  final String meal; // 'Breakfast' / 'Snack' / 'Lunch' … (meta line)
  final String category; // chip: Snacks/Breakfast/Lunch/Dinner/Beverages/Soups & salads/Desserts/Travel
  final bool veg;
  final int kcal;
  final int protein;
  final int fibre;
  final String description;
  final int serves;
  final String difficulty;
  final bool healthier;
  final bool recommended;
  final bool hasVideo;
  final bool vegan;
  final bool immunity;
  final String? situation;

  /// 'veg' | 'vegan' | 'nonveg' - drives the filter + the identifier mark.
  String get diet => vegan ? 'vegan' : (veg ? 'veg' : 'nonveg');
}

const List<String> kRecipeCategories = [
  'All', 'Snacks', 'Breakfast', 'Lunch', 'Dinner', 'Beverages', 'Soups & salads', 'Desserts', 'Travel',
];

/// Diet filter options → the diet code they map to ('All' = no filter).
const List<(String, String)> kRecipeDiets = [
  ('All', 'All'),
  ('Veg', 'veg'),
  ('Vegan', 'vegan'),
  ('Non-veg', 'nonveg'),
];

const List<String> kSickSituations = ['Constipation', 'Loose motion', 'Cough & cold', 'Fever'];

const String _stage = "Right for {child}'s stage";

const List<RecipeItem> kRecipes = [
  // -- normal recipes --
  RecipeItem(
    id: 'maggi',
    title: 'Veggie Maggi, the smarter way',
    subtitle: _stage,
    minutes: 15,
    meal: 'Snack',
    category: 'Snacks',
    veg: true,
    kcal: 180,
    protein: 6,
    fibre: 4,
    healthier: true,
    recommended: true,
    hasVideo: true,
    description:
        '{child} is teething and moving to firmer finger foods, so soft noodles he can gum are perfect right now - and sneaking in carrots and peas turns a comfort food into a small nutrition win at exactly the stage his iron stores start needing a top-up.',
  ),
  RecipeItem(id: 'ragipancake', title: 'Ragi & banana pancakes', subtitle: _stage, minutes: 10, meal: 'Breakfast', category: 'Breakfast', veg: true, kcal: 150, protein: 5, fibre: 3, healthier: true, recommended: true, description: 'Iron-rich ragi and naturally sweet banana - soft enough to gum, sturdy enough to self-feed.'),
  RecipeItem(id: 'curdrice', title: 'Curd rice, travel-friendly', subtitle: _stage, minutes: 5, meal: 'Lunch', category: 'Travel', veg: true, kcal: 160, protein: 5, fibre: 1, recommended: true, immunity: true, description: 'Cooling, probiotic and no-cook - the easiest thing to carry for a day out.'),
  RecipeItem(id: 'cutlets', title: 'Paneer & veg cutlets', subtitle: _stage, minutes: 20, meal: 'Snack', category: 'Snacks', veg: true, kcal: 170, protein: 8, fibre: 3, description: 'Soft, protein-packed finger food that holds together for little hands.'),
  RecipeItem(id: 'vegpulao', title: 'Veg pulao, soft', subtitle: _stage, minutes: 25, meal: 'Lunch', category: 'Lunch', veg: true, kcal: 200, protein: 6, fibre: 4, vegan: true, description: 'A gentle one-pot with soft-cooked veg - mild spice, easy to mash.'),
  RecipeItem(id: 'dalrice', title: 'Soft dal rice', subtitle: _stage, minutes: 20, meal: 'Lunch', category: 'Lunch', veg: true, kcal: 180, protein: 7, fibre: 3, vegan: true, immunity: true, description: 'The everyday staple - complete protein, soft and comforting.'),
  RecipeItem(id: 'vegkhichdi', title: 'Veg khichdi, dinner', subtitle: _stage, minutes: 25, meal: 'Dinner', category: 'Dinner', veg: true, kcal: 190, protein: 7, fibre: 4, description: 'A warm, filling dinner that settles him for the night.'),
  RecipeItem(id: 'smoothie', title: 'Ragi & banana smoothie', subtitle: _stage, minutes: 5, meal: 'Snack', category: 'Beverages', veg: true, kcal: 140, protein: 4, fibre: 3, healthier: true, immunity: true, description: 'A sippable iron + calcium boost for fussy-appetite days.'),
  RecipeItem(id: 'tomatosoup', title: 'Tomato & carrot soup', subtitle: _stage, minutes: 20, meal: 'Snack', category: 'Soups & salads', veg: true, kcal: 90, protein: 3, fibre: 2, vegan: true, immunity: true, description: 'Smooth, warm and vitamin-A rich - sip from a cup or spoon.'),
  RecipeItem(id: 'datekheer', title: 'Date & banana kheer', subtitle: _stage, minutes: 20, meal: 'Dessert', category: 'Desserts', veg: true, kcal: 190, protein: 5, fibre: 2, healthier: true, description: 'Naturally sweet, no added sugar - a treat that still nourishes.'),
  RecipeItem(id: 'eggbhurji', title: 'Soft egg bhurji', subtitle: _stage, minutes: 12, meal: 'Breakfast', category: 'Breakfast', veg: false, kcal: 160, protein: 9, fibre: 1, description: 'Soft-scrambled and mild - an easy protein-rich start once eggs are introduced.'),
  RecipeItem(id: 'chickensoup', title: 'Clear chicken soup', subtitle: _stage, minutes: 30, meal: 'Lunch', category: 'Soups & salads', veg: false, kcal: 110, protein: 10, fibre: 1, immunity: true, description: 'A light, nourishing broth - gentle protein and warmth.'),

  // -- sick-day comfort meals --
  RecipeItem(id: 'khichdi', title: 'Soft moong dal khichdi', subtitle: 'Light on the tummy, easy to digest', minutes: 20, meal: 'Lunch', category: 'Lunch', veg: true, kcal: 170, protein: 7, fibre: 4, situation: 'Constipation', description: 'Soft, mild and easy to digest - the classic get-well meal.'),
  RecipeItem(id: 'prunepuree', title: 'Stewed prune & apple purée', subtitle: 'Natural fibre to get things moving', minutes: 12, meal: 'Snack', category: 'Snacks', veg: true, kcal: 90, protein: 1, fibre: 5, vegan: true, situation: 'Constipation', description: 'Gentle natural fibre to ease constipation.'),
  RecipeItem(id: 'ragiporridge', title: 'Ragi porridge, loose', subtitle: 'Wholegrain fibre, easy to swallow', minutes: 10, meal: 'Breakfast', category: 'Breakfast', veg: true, kcal: 120, protein: 3, fibre: 4, situation: 'Constipation', description: 'A loose, smooth wholegrain porridge - easy to swallow.'),
  RecipeItem(id: 'bananarice', title: 'Banana & rice mash', subtitle: 'Binding and gentle', minutes: 8, meal: 'Snack', category: 'Snacks', veg: true, kcal: 110, protein: 2, fibre: 2, vegan: true, situation: 'Loose motion', description: 'Binding, bland and soothing when his tummy is upset.'),
  RecipeItem(id: 'coconutwater', title: 'Tender coconut water', subtitle: 'Rehydrates gently', minutes: 2, meal: 'Drink', category: 'Beverages', veg: true, kcal: 45, protein: 0, fibre: 0, vegan: true, situation: 'Loose motion', description: 'Natural electrolytes to keep him hydrated.'),
  RecipeItem(id: 'rasam', title: 'Soft tomato rasam', subtitle: 'Warm and soothing', minutes: 20, meal: 'Soup', category: 'Soups & salads', veg: true, kcal: 70, protein: 2, fibre: 1, vegan: true, situation: 'Cough & cold', description: 'Warm, mildly spiced and comforting for a blocked nose.'),
  RecipeItem(id: 'turmericmilk', title: 'Golden turmeric milk', subtitle: 'Warm comfort at bedtime', minutes: 8, meal: 'Drink', category: 'Beverages', veg: true, kcal: 130, protein: 5, fibre: 0, situation: 'Cough & cold', description: 'A warm, soothing bedtime drink (from ~1 yr).'),
  RecipeItem(id: 'moongwater', title: 'Moong dal water', subtitle: 'Light, nourishing sips', minutes: 15, meal: 'Soup', category: 'Soups & salads', veg: true, kcal: 60, protein: 3, fibre: 1, vegan: true, situation: 'Fever', description: 'Thin, protein-light sips for when appetite drops.'),
  RecipeItem(id: 'lightkhichdi', title: 'Light khichdi, extra soft', subtitle: 'Easy energy when appetite is low', minutes: 20, meal: 'Lunch', category: 'Lunch', veg: true, kcal: 150, protein: 6, fibre: 3, situation: 'Fever', description: 'Extra-soft and mild - easy energy when he isn\'t eating much.'),
];

// ---- queries ----------------------------------------------------------------
List<RecipeItem> get recommendedRecipes => kRecipes.where((r) => r.recommended).toList();

List<RecipeItem> normalRecipes({String diet = 'All', String category = 'All', bool immunity = false}) => kRecipes
    .where((r) => r.situation == null)
    .where((r) => diet == 'All' || r.diet == diet)
    .where((r) => category == 'All' || r.category == category)
    .where((r) => !immunity || r.immunity)
    .toList();

List<RecipeItem> sickRecipes(String situation) =>
    kRecipes.where((r) => r.situation == situation).toList();

String sickBlurb(String situation) {
  switch (situation) {
    case 'Constipation':
      return 'Fibre & fluids to get things moving gently.';
    case 'Loose motion':
      return 'Binding, bland and hydrating - gentle on an upset tummy.';
    case 'Cough & cold':
      return 'Warm, soothing foods to ease a blocked nose and throat.';
    case 'Fever':
      return 'Light, hydrating meals for when appetite drops.';
    default:
      return '';
  }
}
