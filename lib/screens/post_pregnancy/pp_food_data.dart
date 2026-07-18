// =============================================================================
//  ParentVeda Food ("Food Companion") - content model, catalog + store
// -----------------------------------------------------------------------------
//  Recipes V2 - NOT a recipe library. A personalised food companion that answers
//  one question: "What should I feed my child today?". So the model carries far
//  more than a recipe: the WHY, key nutrients, serving frequency, storage,
//  common mistakes, ingredient substitutions, and a "Healthier ParentVeda
//  version" - plus canonical ingredient keys that power the Smart Meal Builder.
//  Indian-family first, evidence-based, no calorie counting / diet culture.
//  Brand-new + self-contained: does NOT touch the existing Recipes module
//  (pp_recipes_data.dart). Scenario child: Aarav (first foods from ~6 months).
// =============================================================================

import 'package:flutter/material.dart';

/// One key nutrient line for the Nutrition Breakdown.
class FoodNutrient {
  const FoodNutrient(this.name, this.amount, this.note);
  final String name; // 'Iron'
  final String amount; // 'good source'
  final String note; // one-line why
}

/// A food/recipe - the unit of the Food companion.
class FoodRecipe {
  const FoodRecipe({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.slot,
    required this.ageTag,
    required this.veg,
    required this.prepMin,
    required this.cookMin,
    required this.difficulty,
    required this.seed,
    required this.highlight,
    required this.why,
    required this.nutrients,
    required this.frequency,
    required this.ingredients,
    required this.steps,
    // What you need in the kitchen beyond a spoon and a plate. Called out
    // separately because discovering you need a blender halfway through is the
    // difference between cooking this and abandoning it.
    this.equipment = const [],
    required this.storage,
    required this.mistakes,
    required this.substitutions,
    required this.healthierNote,
    required this.tags,
    required this.ingredientKeys,
    this.vegan = false, // veg AND vegan (no dairy/egg); drives the 3-way diet mark
    this.immunity = false, // immunity-booster tag/filter
    this.serves = 2,
    this.situations = const {}, // sick-day situations this dish helps with
    this.comfortOnly = false, // a pure comfort/recovery meal (hidden from everyday browse)
    this.relatedArticle,
    this.relatedVideoId,
    this.relatedProductId,
    this.relatedCommunity,
  });

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String slot; // meal slot: Breakfast / Morning snack / Lunch / …
  final String ageTag; // '6–12 mo'
  final bool veg;
  final int prepMin;
  final int cookMin;
  final String difficulty;
  final int seed;
  final String highlight; // 'Iron + calcium'
  final String why; // why this is good (educational)
  final List<FoodNutrient> nutrients;
  final String frequency; // 'A few times a week'
  final List<String> ingredients;
  final List<String> equipment;
  final List<String> steps;
  final List<String> storage;
  final List<String> mistakes;
  final Map<String, String> substitutions; // item -> swap
  final String healthierNote; // what changed & why it's healthier
  final Set<String> tags; // search / nutrition tags
  final Set<String> ingredientKeys; // canonical keys for the Smart Meal Builder
  final bool vegan;
  final bool immunity;
  final int serves;
  final Set<String> situations; // sick-day situations (Constipation / Fever / …)
  final bool comfortOnly;
  final String? relatedArticle;
  final String? relatedVideoId;
  final String? relatedProductId;
  final String? relatedCommunity;

  int get totalMin => prepMin + cookMin;
  String get vegLabel => veg ? 'Veg' : 'Non-veg';

  /// 'veg' | 'vegan' | 'nonveg' - drives the diet filter + the diet marker.
  String get diet => vegan ? 'vegan' : (veg ? 'veg' : 'nonveg');
}

/// One "nutrition focus of the day" - the educational strength.
class NutritionFocus {
  const NutritionFocus({
    required this.id,
    required this.nutrient,
    required this.oneLine,
    required this.why,
    required this.sources,
    required this.easyFoods,
    required this.deficiency,
    required this.recipeIds,
    required this.seed,
    this.article,
  });
  final String id;
  final String nutrient; // 'Iron'
  final String oneLine; // short hook
  final String why;
  final List<String> sources;
  final List<String> easyFoods;
  final String deficiency; // signs (gentle, where appropriate)
  final List<String> recipeIds;
  final int seed;
  final String? article;
}

// ---- diet + sick axes (ported from the old Recipes module) ------------------
/// The 3-way diet filter options (label, code) for the unified Recipes home.
const List<(String, String)> kFoodDiets = [
  ('All', 'All'),
  ('Veg', 'veg'),
  ('Vegan', 'vegan'),
  ('Non-veg', 'nonveg'),
];

/// Category chips for the unified Recipes browse. Sick-Day Meals has its own
/// doorway (SickDaysScreen), so it is deliberately not offered as a chip here.
const List<String> kBrowseCategories = [
  'All', 'First Foods', 'Finger Foods', 'Breakfast', 'Lunch', 'Dinner',
  'Snacks', 'Smoothies', 'Soups', 'Travel Food', 'Toddler Meals', 'Healthy Desserts',
];

/// The sick-day situations offered in the Sick-mode doorway.
const List<String> kSickSituations = ['Constipation', 'Loose motion', 'Cough & cold', 'Fever'];

// ---- meal slots + categories ------------------------------------------------
const List<String> kFoodSlots = ['Breakfast', 'Morning snack', 'Lunch', 'Evening snack', 'Dinner'];

const List<(String, IconData)> kFoodCategories = [
  ('First Foods', Icons.spa_outlined),
  ('Finger Foods', Icons.back_hand_outlined),
  ('Breakfast', Icons.free_breakfast_outlined),
  ('Lunch', Icons.lunch_dining_outlined),
  ('Dinner', Icons.dinner_dining_outlined),
  ('Snacks', Icons.cookie_outlined),
  ('Smoothies', Icons.local_drink_outlined),
  ('Soups', Icons.soup_kitchen_outlined),
  ('Sick-Day Meals', Icons.healing_outlined),
  ('Travel Food', Icons.luggage_outlined),
  ('Toddler Meals', Icons.child_care_outlined),
  ('Healthy Desserts', Icons.icecream_outlined),
];

// The ingredients a parent can toggle in the Smart Meal Builder.
const List<String> kBuilderIngredients = [
  'milk', 'banana', 'oats', 'ragi', 'rice', 'moong dal', 'curd', 'egg',
  'paneer', 'vegetables', 'sweet potato', 'spinach', 'tomato', 'besan', 'dates',
];

// ---- catalog ----------------------------------------------------------------
const List<FoodRecipe> kFoodRecipes = [
  FoodRecipe(
    id: 'ragipancake',
    title: 'Ragi & banana pancakes',
    subtitle: 'Iron-rich, naturally sweet, easy to self-feed',
    category: 'Breakfast',
    slot: 'Breakfast',
    ageTag: '8–12 mo',
    veg: true,
    prepMin: 5,
    cookMin: 8,
    difficulty: 'Easy',
    seed: 1,
    highlight: 'Iron + calcium',
    why:
        'Ragi (nachni) is one of the richest vegetarian sources of iron and calcium - exactly what a baby needs as his own iron stores start to run low around 6 months. Banana adds natural sweetness so there’s no need for sugar, and the soft, sturdy texture is perfect for little fingers learning to self-feed.',
    nutrients: [
      FoodNutrient('Iron', 'good source', 'Supports his blood and brain as birth stores deplete.'),
      FoodNutrient('Calcium', 'good source', 'For growing bones and teeth.'),
      FoodNutrient('Fibre', 'moderate', 'Gentle on a developing tummy.'),
    ],
    frequency: '2–3 mornings a week',
    ingredients: ['3 tbsp ragi (finger millet) flour', '½ ripe banana, mashed', '3 tbsp milk or water', '½ tsp ghee'],
    steps: [
      'Mash the banana smooth and whisk in the ragi flour and milk to a thick, lump-free batter.',
      'Heat a non-stick pan on low with a little ghee.',
      'Pour small pancakes; cook 2–3 min each side until set and soft.',
      'Cool to just-warm and cut into strips he can hold.',
    ],
    storage: ['Best fresh; keep leftovers covered in the fridge up to 24 hours and warm gently.'],
    mistakes: ['Cooking on high heat - ragi burns fast; keep it low and slow.', 'Adding sugar or honey - never honey before 1 year.'],
    substitutions: {'banana': 'stewed apple or mashed sweet potato', 'ragi flour': 'oat flour (less iron)'},
    healthierNote:
        'The everyday version uses maida and sugar. Ours swaps in iron-and-calcium-rich ragi and lets ripe banana do the sweetening - same comforting pancake, far more nourishment and no added sugar.',
    tags: {'iron', 'calcium', 'breakfast', 'finger food', 'ragi', 'banana', 'no sugar'},
    ingredientKeys: {'ragi', 'banana', 'milk'},
    relatedArticle: 'Distracted feeds: is he getting enough?',
    relatedVideoId: 'q_iron',
    relatedCommunity: 'First-foods wins & flops',
  ),
  FoodRecipe(
    id: 'sweetpotatomash',
    title: 'Sweet potato mash',
    subtitle: 'A gentle, sweet first food',
    category: 'First Foods',
    slot: 'Lunch',
    ageTag: '6+ mo',
    veg: true,
    vegan: true,
    prepMin: 5,
    cookMin: 15,
    difficulty: 'Easy',
    seed: 2,
    highlight: 'Vitamin A',
    why:
        'Naturally sweet, smooth and easy to digest, sweet potato is a lovely first food. It’s rich in vitamin A for healthy eyes and immunity, and its mild taste is usually an easy yes for a baby just starting solids.',
    nutrients: [
      FoodNutrient('Vitamin A', 'excellent', 'For eyes, skin and immunity.'),
      FoodNutrient('Fibre', 'good', 'Keeps digestion gentle and regular.'),
      FoodNutrient('Carbohydrate', 'good', 'Steady energy for a growing body.'),
    ],
    frequency: 'Anytime - a great daily first food',
    ingredients: ['1 small sweet potato', 'A splash of breast milk / formula / water'],
    steps: [
      'Steam or boil the peeled, cubed sweet potato until very soft.',
      'Mash smooth, loosening with a little milk or water to the texture he manages.',
      'Serve just-warm; thin it more for a first taste.',
    ],
    storage: ['Fridge up to 2 days, or freeze in an ice-cube tray for quick single portions.'],
    mistakes: ['Serving too thick at the very first taste - start runny and thicken over weeks.'],
    substitutions: {'sweet potato': 'pumpkin or carrot (both vitamin-A rich)'},
    healthierNote: 'No added salt, sugar or butter - just the vegetable, the way a first food should be.',
    tags: {'first food', 'vitamin a', 'sweet potato', 'puree', 'vegetables'},
    ingredientKeys: {'sweet potato'},
    relatedVideoId: 'solids101',
  ),
  FoodRecipe(
    id: 'moongkhichdi',
    title: 'Soft moong dal khichdi',
    subtitle: 'The classic complete-protein first meal',
    category: 'Lunch',
    slot: 'Lunch',
    ageTag: '6–12 mo',
    veg: true,
    immunity: true,
    situations: {'Constipation'},
    prepMin: 10,
    cookMin: 20,
    difficulty: 'Easy',
    seed: 3,
    highlight: 'Protein + iron',
    why:
        'Rice and moong dal together make a complete protein - all the building blocks in one soft, comforting bowl. It’s the classic Indian first meal for good reason: gentle to digest, easy to mash, and endlessly adaptable as he grows.',
    nutrients: [
      FoodNutrient('Protein', 'complete', 'Dal + rice = all essential amino acids.'),
      FoodNutrient('Iron', 'moderate', 'From the dal - pair with a squeeze of lemon later on.'),
      FoodNutrient('Carbohydrate', 'good', 'Warm, filling energy.'),
    ],
    frequency: '3–4 times a week',
    ingredients: ['2 tbsp rice', '1 tbsp moong dal', 'Soft-cooked vegetables (optional)', 'A little ghee', 'Pinch of turmeric'],
    steps: [
      'Rinse rice and dal; pressure-cook with turmeric and plenty of water until very soft.',
      'Mash to the texture he manages; add mashed veg if using.',
      'Stir in a little ghee, cool to just-warm and serve.',
    ],
    storage: ['Fridge up to 24 hours; loosen with warm water when reheating.'],
    mistakes: ['Too little water - khichdi should be soft and porridge-like for a baby, not fluffy.', 'Adding salt before 1 year is best kept minimal.'],
    substitutions: {'moong dal': 'toor or masoor dal', 'rice': 'broken wheat (dalia) for older babies'},
    healthierNote: 'We keep it low-salt, add a vegetable for extra nutrients, and finish with ghee for healthy fats and vitamin absorption - not a fried tadka.',
    tags: {'protein', 'iron', 'lunch', 'first food', 'khichdi', 'rice', 'dal', 'moong dal'},
    ingredientKeys: {'rice', 'moong dal', 'vegetables'},
    relatedCommunity: 'Khichdi variations we love',
  ),
  FoodRecipe(
    id: 'veggieoats',
    title: 'Savoury vegetable oats',
    subtitle: 'A soft, fibre-rich savoury breakfast',
    category: 'Breakfast',
    slot: 'Breakfast',
    ageTag: '8–12 mo',
    veg: true,
    prepMin: 5,
    cookMin: 10,
    difficulty: 'Easy',
    seed: 4,
    highlight: 'Fibre + B-vitamins',
    why:
        'Oats cook down soft and creamy, and a handful of grated vegetables turns breakfast into a small nutrition win. The fibre keeps digestion happy - useful in the months when new foods can slow things down.',
    nutrients: [
      FoodNutrient('Fibre', 'good', 'Keeps digestion moving.'),
      FoodNutrient('Iron', 'moderate', 'Oats add a little plant iron.'),
      FoodNutrient('Protein', 'moderate', 'More if cooked in milk.'),
    ],
    frequency: '2–3 mornings a week',
    ingredients: ['3 tbsp quick oats', 'Grated carrot / bottle gourd', '½ cup milk or water', 'Pinch of cumin'],
    steps: [
      'Lightly cook the grated veg in a little water until soft.',
      'Add oats and milk; simmer to a soft, creamy porridge.',
      'Mash any lumps, cool to just-warm and serve.',
    ],
    storage: ['Best fresh - oats thicken as they sit; loosen with warm milk if needed.'],
    mistakes: ['Using flavoured/instant oats - plain oats only, no added sugar or salt.'],
    substitutions: {'oats': 'daliya (broken wheat)', 'carrot': 'any soft-cooked veg'},
    healthierNote: 'A savoury, vegetable-forward take instead of sugary oats - same 10-minute ease, real nourishment.',
    tags: {'fibre', 'breakfast', 'oats', 'vegetables'},
    ingredientKeys: {'oats', 'milk', 'vegetables'},
    relatedVideoId: 'q_iron',
  ),
  FoodRecipe(
    id: 'paneercutlet',
    title: 'Paneer & veg cutlets',
    subtitle: 'Soft, protein-packed finger food',
    category: 'Finger Foods',
    slot: 'Evening snack',
    ageTag: '10–12 mo',
    veg: true,
    prepMin: 15,
    cookMin: 10,
    difficulty: 'Medium',
    seed: 5,
    highlight: 'Protein + calcium',
    why:
        'Paneer is a baby-friendly powerhouse - soft, mild and rich in protein and calcium. Shaped into little cutlets your baby can grip, it’s a brilliant self-feeding snack that builds his pincer grasp while it nourishes.',
    nutrients: [
      FoodNutrient('Protein', 'excellent', 'For muscle and steady growth.'),
      FoodNutrient('Calcium', 'excellent', 'Bones and teeth.'),
      FoodNutrient('Healthy fats', 'good', 'Energy-dense for little tummies.'),
    ],
    frequency: 'Twice a week',
    ingredients: ['3 tbsp grated paneer', '2 tbsp mashed potato/veg', '1 tsp rice flour to bind', 'Pinch of cumin', 'Ghee to pan-fry'],
    steps: [
      'Mix paneer, mashed veg, rice flour and cumin into a soft dough.',
      'Shape into small, flat cutlets.',
      'Pan-fry gently in a little ghee until golden and warmed through.',
      'Cool and cut into grippable strips.',
    ],
    storage: ['Fridge up to a day; warm before serving. Freeze uncooked patties for quick snacks.'],
    mistakes: ['Deep frying - a light pan-fry in ghee is plenty.', 'Making them too big or firm to gum.'],
    substitutions: {'paneer': 'crumbled tofu', 'potato': 'sweet potato or peas'},
    healthierNote: 'Pan-fried in a little ghee, not deep-fried, and bound with rice flour instead of a heavy breadcrumb coating.',
    tags: {'protein', 'calcium', 'finger food', 'snack', 'paneer', 'vegetables'},
    ingredientKeys: {'paneer', 'vegetables'},
    relatedProductId: 'clothbook',
  ),
  // ---- dinners -------------------------------------------------------------
  //  Added 18 Jul: the weekly meal plan repeated because only two dinners were
  //  authored, so a 7-day plan could only alternate between them. These five are
  //  deliberately one-pot and quick - dinner is cooked by a tired parent at the
  //  worst hour of the day, and a recipe that ignores that will not get made.
  FoodRecipe(
    id: 'vegkhichdi',
    title: 'Soft vegetable khichdi',
    subtitle: 'The one-pot dinner that never fails',
    category: 'Dinner',
    slot: 'Dinner',
    ageTag: '7-12 mo',
    veg: true,
    prepMin: 8,
    cookMin: 18,
    difficulty: 'Easy',
    seed: 21,
    highlight: 'Complete protein',
    why:
        'Rice and dal together make a complete protein, which neither manages alone - the oldest piece of nutrition science in the Indian kitchen. Soft, mild and warm, it is the dinner most babies accept even on a bad evening.',
    nutrients: [
      FoodNutrient('Protein', 'good', 'Rice and dal combined.'),
      FoodNutrient('Iron', 'moderate', 'From the dal, helped along by the ghee.'),
      FoodNutrient('Fibre', 'moderate', 'From the vegetables.'),
    ],
    frequency: 'Two or three times a week',
    ingredients: ['2 tbsp rice', '1 tbsp moong dal', 'Carrot and bottle gourd, finely chopped', 'Pinch of turmeric', 'Quarter tsp ghee'],
    equipment: ['Pressure cooker', 'Masher'],
    steps: [
      'Rinse the rice and dal together.',
      'Pressure cook with the vegetables, turmeric and three times the water - about three whistles.',
      'Mash to the texture he manages: smooth at seven months, lumpier by ten.',
      'Stir the ghee in at the end, off the heat.',
    ],
    storage: ['Fridge up to 24 hours; loosen with warm water when reheating.'],
    mistakes: ['Skipping the ghee - the fat matters more than the calories suggest.', 'Adding salt before one year.'],
    substitutions: {'bottle gourd': 'pumpkin or beans', 'moong dal': 'toor dal'},
    healthierNote: 'No salt, no tempering, and the ghee goes in off the heat so it is never overheated.',
    tags: {'protein', 'iron', 'dinner', 'one pot', 'khichdi', 'rice', 'dal'},
    ingredientKeys: {'rice', 'moong dal', 'vegetables'},
  ),
  FoodRecipe(
    id: 'ragiveg',
    title: 'Ragi and vegetable porridge',
    subtitle: 'Calcium-rich, ready in minutes',
    category: 'Dinner',
    slot: 'Dinner',
    ageTag: '6-10 mo',
    veg: true,
    prepMin: 5,
    cookMin: 10,
    difficulty: 'Easy',
    seed: 22,
    highlight: 'Calcium + iron',
    why:
        'Ragi carries more calcium than almost anything else in an Indian pantry, and useful iron alongside it - exactly the two things a baby needs most as milk begins making way for food.',
    nutrients: [
      FoodNutrient('Calcium', 'good', 'Ragi is unusually rich in it.'),
      FoodNutrient('Iron', 'good', 'Better absorbed alongside a vitamin-C food.'),
      FoodNutrient('Fibre', 'moderate', 'Gentle on a young gut.'),
    ],
    frequency: 'Two or three times a week',
    ingredients: ['2 tbsp ragi flour', 'Grated carrot or pumpkin', '1 cup water', 'Quarter tsp ghee'],
    equipment: ['Saucepan', 'Whisk', 'Grater'],
    steps: [
      'Whisk the ragi flour into COLD water first - lumps are impossible to fix later.',
      'Add the grated vegetable and cook on low, stirring, for eight to ten minutes.',
      'It should coat the back of a spoon, not hold its shape.',
      'Stir in the ghee off the heat and cool to warm.',
    ],
    storage: ['Best fresh - it sets hard in the fridge.'],
    mistakes: ['Adding flour to hot water - it seizes into lumps instantly.', 'Serving it too thick for a young baby.'],
    substitutions: {'carrot': 'pumpkin, sweet potato or beetroot'},
    healthierNote: 'No sugar and no jaggery - ragi and a sweet vegetable are sweet enough, and early sugar sets preferences that last for years.',
    tags: {'calcium', 'iron', 'ragi', 'dinner', 'porridge'},
    ingredientKeys: {'ragi', 'vegetables'},
  ),
  FoodRecipe(
    id: 'daliaveg',
    title: 'Dalia with soft vegetables',
    subtitle: 'Broken wheat, gentle and filling',
    category: 'Dinner',
    slot: 'Dinner',
    ageTag: '8-14 mo',
    veg: true,
    prepMin: 7,
    cookMin: 15,
    difficulty: 'Easy',
    seed: 23,
    highlight: 'Slow-release energy',
    why:
        'Dalia digests slowly, which is exactly what you want at night - it holds him through a longer stretch without sitting heavily. The texture is also a useful step up from purees.',
    nutrients: [
      FoodNutrient('Fibre', 'good', 'Whole broken wheat.'),
      FoodNutrient('Protein', 'moderate', 'More again with a spoon of dal added.'),
      FoodNutrient('B vitamins', 'moderate', 'From the whole grain.'),
    ],
    frequency: 'Twice a week',
    ingredients: ['2 tbsp dalia', '1 tbsp moong dal (optional)', 'Carrot, peas and beans, finely chopped', 'Pinch of turmeric', 'Quarter tsp ghee'],
    equipment: ['Pressure cooker'],
    steps: [
      'Dry roast the dalia for a minute until it smells nutty - this is what stops it turning gluey.',
      'Pressure cook with the dal, vegetables, turmeric and four times the water.',
      'Mash lightly; leave a little texture for babies past nine months.',
      'Finish with ghee.',
    ],
    storage: ['Fridge up to a day; add warm water when reheating.'],
    mistakes: ['Skipping the dry roast - it is the difference between fluffy and paste.'],
    substitutions: {'dalia': 'quinoa or samai', 'peas': 'any soft vegetable'},
    healthierNote: 'Whole broken wheat rather than refined suji, so the fibre and B vitamins survive.',
    tags: {'fibre', 'dinner', 'dalia', 'one pot', 'texture'},
    ingredientKeys: {'dalia', 'moong dal', 'vegetables'},
  ),
  FoodRecipe(
    id: 'paneerpulao',
    title: 'Soft paneer pulao',
    subtitle: 'Protein and calcium in one bowl',
    category: 'Dinner',
    slot: 'Dinner',
    ageTag: '9-14 mo',
    veg: true,
    prepMin: 8,
    cookMin: 15,
    difficulty: 'Easy',
    seed: 24,
    highlight: 'Protein + calcium',
    why:
        'Paneer is one of the easiest ways to get both protein and calcium into a baby who has started refusing milk feeds - and crumbled into rice, it disappears into something he already likes.',
    nutrients: [
      FoodNutrient('Protein', 'good', 'Paneer is close to complete.'),
      FoodNutrient('Calcium', 'good', 'For bones hardening quickly now.'),
      FoodNutrient('Fat', 'good', 'Full-fat paneer, as it should be.'),
    ],
    frequency: 'Twice a week',
    ingredients: ['2 tbsp rice', '2 tbsp paneer, crumbled', 'Carrot and peas, finely chopped', 'Pinch of jeera', 'Quarter tsp ghee'],
    equipment: ['Pressure cooker', 'Non-stick pan'],
    steps: [
      'Cook the rice soft with the vegetables.',
      'Warm the ghee, add the jeera, and toss the crumbled paneer through for a minute - no browning.',
      'Fold the paneer into the rice.',
      'Mash lightly if he is still learning texture.',
    ],
    storage: ['Best fresh - paneer turns rubbery reheated.'],
    mistakes: ['Frying the paneer hard, which makes it chewy and difficult to gum.', 'Using low-fat paneer - babies need the fat.'],
    substitutions: {'paneer': 'crumbled tofu or well-cooked egg'},
    healthierNote: 'Full-fat paneer, barely warmed rather than fried, and no salt.',
    tags: {'protein', 'calcium', 'paneer', 'dinner', 'rice'},
    ingredientKeys: {'paneer', 'rice', 'vegetables'},
  ),
  FoodRecipe(
    id: 'moongchilla',
    title: 'Moong dal chilla fingers',
    subtitle: 'Something he can hold',
    category: 'Dinner',
    slot: 'Dinner',
    ageTag: '10-18 mo',
    veg: true,
    prepMin: 10,
    cookMin: 10,
    difficulty: 'Easy',
    seed: 25,
    highlight: 'Iron + self-feeding',
    why:
        'A dinner he feeds himself is worth more than a neater one you spoon in. Cut into fingers, chilla is soft enough to gum and firm enough to hold - and moong dal brings real iron with it.',
    nutrients: [
      FoodNutrient('Iron', 'good', 'Plant iron from the dal.'),
      FoodNutrient('Protein', 'good', 'Moong is protein-dense.'),
      FoodNutrient('Fat', 'moderate', 'From the ghee it cooks in.'),
    ],
    frequency: 'Twice a week',
    ingredients: ['Quarter cup moong dal, soaked 3 hours', 'Grated carrot', 'Pinch of turmeric', 'Ghee for the pan'],
    equipment: ['Blender or mixie', 'Non-stick pan'],
    steps: [
      'Blend the soaked dal with a little water to a smooth, pourable batter.',
      'Stir in the grated carrot and turmeric.',
      'Cook thin on a lightly greased pan, about two minutes a side, until it lifts cleanly.',
      'Cool, then cut into finger-width strips he can grip.',
    ],
    storage: ['Fridge up to a day; warm briefly before serving.'],
    mistakes: ['Making it thick - a thick chilla stays doughy in the middle.', 'Serving it straight from the pan; always check the temperature first.'],
    substitutions: {'moong dal': 'chana dal for older babies', 'carrot': 'grated bottle gourd or spinach'},
    healthierNote: 'Cooked in a little ghee on a non-stick pan, so it needs almost no fat and no salt at all.',
    tags: {'iron', 'protein', 'finger food', 'dinner', 'self feeding', 'chilla'},
    ingredientKeys: {'moong dal', 'vegetables'},
  ),
  FoodRecipe(
    id: 'palakdal',
    title: 'Palak (spinach) dal',
    subtitle: 'Gentle greens the easy way',
    category: 'Lunch',
    slot: 'Dinner',
    ageTag: '8–12 mo',
    veg: true,
    prepMin: 10,
    cookMin: 20,
    difficulty: 'Easy',
    seed: 6,
    highlight: 'Iron + folate',
    why:
        'Folding soft-cooked spinach into dal is the gentlest way to get greens - and their iron and folate - into a baby who might refuse them plain. Blended smooth into the dal, the taste is mild and the colour is fun.',
    nutrients: [
      FoodNutrient('Iron', 'good', 'Plant iron from spinach and dal.'),
      FoodNutrient('Folate', 'good', 'For rapid cell growth.'),
      FoodNutrient('Protein', 'moderate', 'From the dal.'),
    ],
    frequency: 'Twice a week',
    ingredients: ['2 tbsp moong/toor dal', 'A handful of spinach', 'Pinch of turmeric', 'A little ghee', 'A drop of lemon (after cooking)'],
    steps: [
      'Cook the dal soft with turmeric.',
      'Wilt and purée the spinach; stir it through the dal.',
      'Finish with ghee and, for older babies, a drop of lemon to boost iron absorption.',
      'Serve with soft rice.',
    ],
    storage: ['Fridge up to 24 hours; reheat gently.'],
    mistakes: ['Overcooking spinach for long - a quick wilt keeps more nutrients.'],
    substitutions: {'spinach': 'methi or soft-cooked bottle gourd'},
    healthierNote: 'Vitamin C (that drop of lemon) is added on purpose - it helps his body absorb far more of the plant iron.',
    tags: {'iron', 'folate', 'greens', 'lunch', 'dinner', 'spinach', 'dal'},
    ingredientKeys: {'spinach', 'moong dal', 'rice'},
    relatedArticle: 'Distracted feeds: is he getting enough?',
  ),
  FoodRecipe(
    id: 'curdrice',
    title: 'Curd rice, travel-friendly',
    subtitle: 'Cooling, probiotic, no-cook',
    category: 'Travel Food',
    slot: 'Lunch',
    ageTag: '8–12 mo',
    veg: true,
    immunity: true,
    prepMin: 5,
    cookMin: 0,
    difficulty: 'Easy',
    seed: 7,
    highlight: 'Probiotics',
    why:
        'Soft rice mashed with curd is cooling, gentle and full of gut-friendly probiotics. It needs no cooking and travels well - the easiest thing to carry for a day out, and a soother on a hot day or an upset tummy.',
    nutrients: [
      FoodNutrient('Probiotics', 'good', 'Friendly bacteria for gut health.'),
      FoodNutrient('Calcium', 'good', 'From the curd.'),
      FoodNutrient('Carbohydrate', 'good', 'Easy, gentle energy.'),
    ],
    frequency: 'Anytime - great for travel & recovery',
    ingredients: ['3 tbsp soft-cooked rice', '2 tbsp fresh curd', 'A little water to loosen'],
    steps: ['Mash the rice soft.', 'Fold in fresh curd and loosen to a soft, spoonable texture.', 'Serve cool (not cold).'],
    storage: ['Best fresh; in a cool flask it holds a few hours for travel.'],
    mistakes: ['Using sour or very cold curd.'],
    substitutions: {'curd': 'hung curd for a thicker travel version'},
    healthierNote: 'Fresh curd and no tempering or salt - just the cooling, probiotic basics a little tummy loves.',
    tags: {'probiotic', 'travel', 'lunch', 'curd', 'rice', 'sick day'},
    ingredientKeys: {'curd', 'rice'},
  ),
  FoodRecipe(
    id: 'eggbhurji',
    title: 'Soft egg bhurji',
    subtitle: 'A mild, protein-rich start',
    category: 'Breakfast',
    slot: 'Breakfast',
    ageTag: '9–12 mo',
    veg: false,
    prepMin: 5,
    cookMin: 7,
    difficulty: 'Easy',
    seed: 8,
    highlight: 'Protein + choline',
    why:
        'Once eggs are introduced, soft-scrambled bhurji is a wonderful protein-rich breakfast. Eggs bring choline, which supports the fast brain development happening this year - and the soft curds are easy for little hands.',
    nutrients: [
      FoodNutrient('Protein', 'excellent', 'High-quality and complete.'),
      FoodNutrient('Choline', 'excellent', 'Supports brain and memory development.'),
      FoodNutrient('Healthy fats', 'good', 'For energy and absorption.'),
    ],
    frequency: '2–3 times a week (once egg is well tolerated)',
    ingredients: ['1 egg', '1 tbsp milk', 'Finely chopped soft tomato (optional)', 'A little ghee', 'Pinch of turmeric'],
    steps: [
      'Whisk the egg with milk and turmeric.',
      'Cook low and slow in a little ghee, stirring to soft, small curds.',
      'Keep it moist (not dry); cool to just-warm.',
    ],
    storage: ['Serve fresh - eggs are best not stored once cooked for a baby.'],
    mistakes: ['Overcooking to dry, rubbery curds.', 'Introducing egg alongside other new foods - try it alone first to spot any reaction.'],
    substitutions: {'egg': 'for vegetarians, soft crumbled paneer bhurji'},
    healthierNote: 'Cooked in a little ghee, kept soft and moist, low salt - gentle on his tummy and easy to gum.',
    tags: {'protein', 'brain', 'breakfast', 'egg', 'non-veg'},
    ingredientKeys: {'egg', 'milk', 'tomato'},
    relatedVideoId: 'leap4brain',
  ),
  FoodRecipe(
    id: 'ragismoothie',
    title: 'Ragi & banana smoothie',
    subtitle: 'A sippable iron + calcium boost',
    category: 'Smoothies',
    slot: 'Morning snack',
    ageTag: '10–12 mo',
    veg: true,
    immunity: true,
    prepMin: 5,
    cookMin: 5,
    difficulty: 'Easy',
    seed: 9,
    highlight: 'Iron + calcium',
    why:
        'On fussy-appetite days, a smooth ragi-and-banana drink slips in iron, calcium and energy without a fight. Cooking the ragi first makes it easy to digest and safe for little ones.',
    nutrients: [
      FoodNutrient('Iron', 'good', 'From cooked ragi.'),
      FoodNutrient('Calcium', 'good', 'Ragi + milk.'),
      FoodNutrient('Energy', 'good', 'Banana keeps it filling.'),
    ],
    frequency: 'On low-appetite days',
    ingredients: ['1 tbsp ragi flour', '½ banana', '½ cup milk', 'A few soaked dates (optional)'],
    steps: [
      'Cook the ragi flour in a little water 3–4 min to a smooth paste; cool.',
      'Blend with banana, milk and dates until smooth.',
      'Serve fresh in a sipper or spoon.',
    ],
    storage: ['Drink fresh; ragi thickens on standing.'],
    mistakes: ['Serving raw (uncooked) ragi flour - always cook it first.'],
    substitutions: {'dates': 'ripe mango or extra banana for sweetness'},
    healthierNote: 'Sweetened only with fruit and dates - no sugar, no syrups - and thickened with iron-rich ragi instead of cornflour.',
    tags: {'iron', 'calcium', 'smoothie', 'drink', 'ragi', 'banana', 'fussy eater'},
    ingredientKeys: {'ragi', 'banana', 'milk', 'dates'},
  ),
  FoodRecipe(
    id: 'tomatocarrotsoup',
    title: 'Tomato & carrot soup',
    subtitle: 'Smooth, warm and vitamin-A rich',
    category: 'Soups',
    slot: 'Evening snack',
    ageTag: '8–12 mo',
    veg: true,
    immunity: true,
    situations: {'Cough & cold'},
    prepMin: 5,
    cookMin: 15,
    difficulty: 'Easy',
    seed: 10,
    highlight: 'Vitamin A + C',
    why:
        'A silky tomato-carrot soup is warmth and vitamins in a cup - vitamin A for immunity and vitamin C to help him absorb iron from the rest of his meals. Lovely as a light evening sip, especially with a stuffy nose.',
    nutrients: [
      FoodNutrient('Vitamin A', 'good', 'Immunity and eyes.'),
      FoodNutrient('Vitamin C', 'good', 'Boosts iron absorption.'),
      FoodNutrient('Hydration', 'good', 'Gentle fluids.'),
    ],
    frequency: 'A few times a week',
    ingredients: ['1 tomato', '1 small carrot', 'A little water', 'A drop of ghee'],
    steps: ['Cook tomato and carrot soft.', 'Blend smooth and strain if needed.', 'Warm through with a drop of ghee; serve just-warm.'],
    storage: ['Fridge up to 2 days; reheat gently.'],
    mistakes: ['Adding stock cubes or salt - the vegetables are sweet enough.'],
    substitutions: {'carrot': 'pumpkin or bottle gourd'},
    healthierNote: 'No cream, no salt, no stock cubes - just blended vegetables and a drop of ghee for absorption.',
    tags: {'vitamin a', 'vitamin c', 'soup', 'sick day', 'tomato', 'vegetables'},
    ingredientKeys: {'tomato', 'vegetables'},
    relatedCommunity: 'Sick-day meals that worked',
  ),
  FoodRecipe(
    id: 'besanchilla',
    title: 'Soft besan chilla',
    subtitle: 'A protein-rich savoury pancake',
    category: 'Snacks',
    slot: 'Morning snack',
    ageTag: '10–12 mo',
    veg: true,
    prepMin: 8,
    cookMin: 8,
    difficulty: 'Easy',
    seed: 11,
    highlight: 'Protein + iron',
    why:
        'Besan (gram flour) is quietly high in protein and iron. Thinned soft and cooked gently, chilla makes a savoury, grippable snack - a nice change from sweet foods and a good way to widen his palate.',
    nutrients: [
      FoodNutrient('Protein', 'good', 'Plant protein from gram flour.'),
      FoodNutrient('Iron', 'moderate', 'A useful vegetarian source.'),
      FoodNutrient('Fibre', 'moderate', 'Keeps things gentle.'),
    ],
    frequency: 'Twice a week',
    ingredients: ['3 tbsp besan', 'Grated soft veg', 'Water to a thin batter', 'Pinch of turmeric', 'Ghee'],
    steps: [
      'Whisk besan, veg, turmeric and water to a thin, lump-free batter.',
      'Cook thin, soft chillas in a little ghee on low heat.',
      'Cool and cut into strips he can hold.',
    ],
    storage: ['Best fresh; batter keeps in the fridge a few hours.'],
    mistakes: ['Making it thick and doughy - keep the batter thin so the chilla stays soft.'],
    substitutions: {'besan': 'moong dal batter (soaked & ground)'},
    healthierNote: 'Cooked soft in a little ghee, loaded with vegetables, no chilli or heavy salt - savoury nutrition, gently done.',
    tags: {'protein', 'iron', 'snack', 'savoury', 'besan', 'vegetables', 'finger food'},
    ingredientKeys: {'besan', 'vegetables'},
  ),
  FoodRecipe(
    id: 'datekheer',
    title: 'Date & banana kheer',
    subtitle: 'Naturally sweet, no added sugar',
    category: 'Healthy Desserts',
    slot: 'Evening snack',
    ageTag: '10–12 mo',
    veg: true,
    prepMin: 5,
    cookMin: 15,
    difficulty: 'Easy',
    seed: 12,
    highlight: 'Iron + energy',
    why:
        'A treat that still nourishes - dates bring natural sweetness plus iron, and banana makes it creamy. It proves dessert doesn’t need sugar to feel special, and it’s a gentle way to end a meal.',
    nutrients: [
      FoodNutrient('Iron', 'moderate', 'Dates are a sweet iron source.'),
      FoodNutrient('Calcium', 'good', 'From the milk.'),
      FoodNutrient('Energy', 'good', 'Naturally sweet, filling.'),
    ],
    frequency: 'An occasional treat',
    ingredients: ['½ cup milk', '3–4 soft dates, deseeded', '½ banana', 'A little cooked rice/vermicelli (optional)'],
    steps: [
      'Simmer the dates in milk until very soft.',
      'Blend or mash smooth with banana (and cooked rice, if using).',
      'Warm through and cool to just-warm.',
    ],
    storage: ['Fridge up to a day; reheat gently.'],
    mistakes: ['Adding sugar or condensed milk - the dates are the sweetness.'],
    substitutions: {'dates': 'ripe mango or stewed apple'},
    healthierNote: 'Traditional kheer is sugar-and-condensed-milk heavy. Ours sweetens only with dates and banana - a real dessert, no added sugar.',
    tags: {'dessert', 'iron', 'no sugar', 'dates', 'banana', 'milk'},
    ingredientKeys: {'dates', 'banana', 'milk'},
  ),

  // -- merged in from the old Recipes catalog (deduped) ----------------------
  FoodRecipe(
    id: 'maggi',
    title: 'Veggie Maggi, the smarter way',
    subtitle: 'A comfort food that quietly does more',
    category: 'Snacks',
    slot: 'Evening snack',
    ageTag: '10–12 mo',
    veg: true,
    prepMin: 5,
    cookMin: 10,
    difficulty: 'Easy',
    seed: 13,
    highlight: 'Fibre + vitamin A',
    serves: 2,
    why:
        'Aarav is teething and moving to firmer finger foods, so soft noodles he can gum are perfect right now - and sneaking in carrots and peas turns a comfort food into a small nutrition win at exactly the stage his iron stores start needing a top-up. The veg boost adds fibre and vitamin A, and the ghee swap makes it gentler than the packet masala alone.',
    nutrients: [
      FoodNutrient('Vitamin A', 'from carrots', 'Builds his immunity and eyesight as he explores and mouths everything.'),
      FoodNutrient('Iron', '12% RDA', 'His birth iron stores run low around now, and iron fuels these months of brain growth.'),
      FoodNutrient('Fibre', 'peas + wheat', 'Keeps digestion gentle as he moves from purées to firmer foods.'),
    ],
    frequency: 'Once a week is plenty',
    ingredients: ['1 pack whole-wheat noodles', '½ carrot, grated', '2 tbsp peas', '½ tsp ghee', 'Half the masala sachet'],
    steps: [
      'Sauté the grated carrot and peas in ghee for two minutes.',
      'Add the noodles, water and half the masala; simmer.',
      'Cook till soft, cool a little, and serve. For a younger baby, chop small or blend to a soft mash.',
    ],
    storage: ['Best fresh; noodles turn stodgy on standing.'],
    mistakes: ['Using the whole masala sachet - it is still salty; half is plenty.', 'Serving long strands - chop or mash so there are no choking-length pieces.'],
    substitutions: {'masala sachet': 'a pinch of jeera and the vegetables alone', 'whole-wheat noodles': 'millet or ragi noodles'},
    healthierNote:
        'The packet version is refined noodles and a full, salty masala. Ours halves the masala, folds in carrot and peas for fibre and vitamin A, and finishes with ghee instead of the sachet oil - the same comfort food, quietly doing more.',
    tags: {'fibre', 'vitamin a', 'snack', 'noodles', 'vegetables', 'comfort food'},
    ingredientKeys: {'vegetables'},
    relatedVideoId: 'q_iron',
    relatedCommunity: 'Comfort foods, made better',
  ),
  FoodRecipe(
    id: 'vegpulao',
    title: 'Soft veg pulao',
    subtitle: 'A gentle one-pot, mild and easy to mash',
    category: 'Lunch',
    slot: 'Lunch',
    ageTag: '10–12 mo',
    veg: true,
    vegan: true,
    prepMin: 10,
    cookMin: 20,
    difficulty: 'Easy',
    seed: 14,
    highlight: 'Fibre + energy',
    serves: 2,
    why:
        'A soft, mildly spiced one-pot that hides plenty of vegetables in rice he already loves. Cooked without masala and mashed to his texture, it is filling, dairy-free and endlessly adaptable - a good way to widen his palate with new vegetables one at a time.',
    nutrients: [
      FoodNutrient('Carbohydrate', 'good', 'Warm, filling energy for a busy day.'),
      FoodNutrient('Fibre', 'good', 'From the soft-cooked vegetables.'),
      FoodNutrient('Vitamin A', 'moderate', 'From carrot and beans.'),
    ],
    frequency: '2–3 times a week',
    ingredients: ['3 tbsp rice', 'Soft-cooked mixed vegetables (carrot, beans, peas)', 'Pinch of jeera', '½ tsp oil or ghee', 'Water to cook soft'],
    steps: [
      'Temper jeera in a little oil; add the chopped vegetables and soften.',
      'Add rinsed rice and plenty of water; cook until very soft.',
      'Mash lightly to the texture he manages; cool to just-warm.',
    ],
    storage: ['Fridge up to 24 hours; loosen with warm water when reheating.'],
    mistakes: ['Adding garam masala or chilli - keep it mild with just jeera.'],
    substitutions: {'rice': 'broken wheat (dalia) for older babies', 'vegetables': 'whatever is soft and in season'},
    healthierNote: 'No masala, no salt-heavy stock - just soft rice, real vegetables and a little ghee for absorption. A mild pulao a baby can actually eat.',
    tags: {'fibre', 'lunch', 'rice', 'vegetables', 'vegan', 'one-pot'},
    ingredientKeys: {'rice', 'vegetables'},
  ),
  FoodRecipe(
    id: 'chickensoup',
    title: 'Clear chicken soup',
    subtitle: 'A light, nourishing broth - gentle protein and warmth',
    category: 'Soups',
    slot: 'Lunch',
    ageTag: '10–12 mo',
    veg: false,
    immunity: true,
    prepMin: 10,
    cookMin: 20,
    difficulty: 'Easy',
    seed: 15,
    highlight: 'Protein + warmth',
    serves: 2,
    why:
        'A clear, home-made chicken broth is warmth and easy protein in a cup - comforting on a cold or low-appetite day. Simmered gently with a little vegetable and no stock cubes, it delivers zinc and protein that support his immunity, in a form even a poorly tummy accepts.',
    nutrients: [
      FoodNutrient('Protein', 'good', 'Gentle, easy protein when appetite is low.'),
      FoodNutrient('Zinc', 'good', 'Supports his immune system.'),
      FoodNutrient('Hydration', 'good', 'Warm fluids for a stuffy day.'),
    ],
    frequency: 'A few times a week',
    ingredients: ['A small piece of chicken (with bone for a richer broth)', '1 small carrot', 'A little water', 'Pinch of turmeric'],
    steps: [
      'Simmer the chicken with carrot, turmeric and water until fully cooked and soft.',
      'Strain to a clear broth; shred a little soft chicken back in for older babies.',
      'Cool to just-warm and serve as sips or with soft rice.',
    ],
    storage: ['Fridge up to 2 days; reheat until piping hot, then cool to just-warm.'],
    mistakes: ['Using stock cubes or salt - the chicken and carrot are flavour enough.', 'Serving stringy pieces - shred finely or keep it a clear broth.'],
    substitutions: {'chicken': 'for vegetarians, a moong dal + vegetable broth'},
    healthierNote: 'A clear, home-simmered broth - no cream, no cubes, no salt. Just gentle protein and warmth the way it helps a recovering child.',
    tags: {'protein', 'immunity', 'soup', 'non-veg', 'sick day', 'chicken'},
    ingredientKeys: {'vegetables'},
    relatedCommunity: 'Sick-day meals that worked',
  ),

  // -- sick-day comfort meals (hidden from everyday browse) ------------------
  FoodRecipe(
    id: 'prunepuree',
    title: 'Stewed prune & apple purée',
    subtitle: 'Natural fibre to get things moving',
    category: 'Sick-Day Meals',
    slot: 'Morning snack',
    ageTag: '6–12 mo',
    veg: true,
    vegan: true,
    prepMin: 3,
    cookMin: 10,
    difficulty: 'Easy',
    seed: 16,
    highlight: 'Fibre + sorbitol',
    situations: {'Constipation'},
    comfortOnly: true,
    why:
        'Prunes are the gentlest natural laxative there is - their fibre and sorbitol draw water into the gut and ease things along, and stewed apple makes them mild and sweet. A small spoonful is often all it takes.',
    nutrients: [
      FoodNutrient('Fibre', 'excellent', 'Softens stools and keeps digestion moving.'),
      FoodNutrient('Sorbitol', 'natural', 'The prune sugar that gently eases constipation.'),
    ],
    frequency: 'A small serving when he is blocked up',
    ingredients: ['3–4 soft prunes, pitted', '½ apple, peeled', 'A little water'],
    steps: ['Stew the prunes and apple in a little water until very soft.', 'Blend or mash smooth; loosen to a purée.', 'Cool to just-warm and offer a few spoonfuls.'],
    storage: ['Fridge up to 2 days, or freeze in cubes for quick portions.'],
    mistakes: ['Overdoing it - a little goes a long way; too much can loosen his tummy.'],
    substitutions: {'prunes': 'soaked raisins or stewed pear'},
    healthierNote: 'Just fruit, no added sugar - the sweetness and the fibre both come from the prunes and apple themselves.',
    tags: {'fibre', 'constipation', 'sick day', 'prune', 'apple', 'vegan'},
    ingredientKeys: {},
  ),
  FoodRecipe(
    id: 'ragiporridge',
    title: 'Ragi porridge, loose',
    subtitle: 'Wholegrain fibre, easy to swallow',
    category: 'Sick-Day Meals',
    slot: 'Breakfast',
    ageTag: '6–12 mo',
    veg: true,
    prepMin: 3,
    cookMin: 8,
    difficulty: 'Easy',
    seed: 17,
    highlight: 'Fibre + iron',
    situations: {'Constipation'},
    comfortOnly: true,
    why:
        'A loose, smooth ragi porridge is easy to swallow when he is off his food, and its wholegrain fibre gently helps a blocked-up tummy. Kept thin, it doubles as comfort and a soft nudge for digestion.',
    nutrients: [
      FoodNutrient('Fibre', 'good', 'Gently keeps things moving.'),
      FoodNutrient('Iron', 'good', 'Ragi tops up iron even on low-appetite days.'),
    ],
    frequency: 'As a light, settling meal',
    ingredients: ['1 tbsp ragi flour', '½ cup milk or water', 'A soft mashed date (optional)'],
    steps: ['Cook the ragi flour in water 3–4 min to a smooth, loose paste.', 'Stir in milk to keep it thin and pourable.', 'Cool to just-warm; sweeten only with mashed date if needed.'],
    storage: ['Best fresh - ragi thickens fast on standing; loosen with warm milk.'],
    mistakes: ['Serving raw ragi flour - always cook it first.'],
    substitutions: {'ragi flour': 'oat flour (less iron)'},
    healthierNote: 'Kept loose and unsweetened (or sweetened only with a date) - a wholegrain porridge, not a sugary cereal.',
    tags: {'fibre', 'iron', 'constipation', 'sick day', 'ragi'},
    ingredientKeys: {'ragi', 'milk'},
  ),
  FoodRecipe(
    id: 'bananarice',
    title: 'Banana & rice mash',
    subtitle: 'Binding and gentle',
    category: 'Sick-Day Meals',
    slot: 'Morning snack',
    ageTag: '6–12 mo',
    veg: true,
    vegan: true,
    prepMin: 8,
    cookMin: 0,
    difficulty: 'Easy',
    seed: 18,
    highlight: 'Potassium + energy',
    situations: {'Loose motion'},
    comfortOnly: true,
    why:
        'Banana and rice are both binding and bland - the classic soothing pair when his tummy is upset. Banana also replaces the potassium lost with loose motions, and neither irritates a sensitive gut.',
    nutrients: [
      FoodNutrient('Potassium', 'good', 'Replaces what is lost with loose motions.'),
      FoodNutrient('Carbohydrate', 'good', 'Gentle, easy energy.'),
    ],
    frequency: 'When his tummy is loose',
    ingredients: ['3 tbsp soft-cooked rice', '½ ripe banana'],
    steps: ['Mash the rice soft.', 'Fold in the mashed banana to a smooth, spoonable mash.', 'Serve at room temperature.'],
    storage: ['Best fresh; banana browns quickly.'],
    mistakes: ['Adding milk or curd during active loose motions - keep it simple and binding.'],
    substitutions: {'banana': 'stewed apple (also binding)'},
    healthierNote: 'No sugar, no dairy while his tummy settles - just two gentle, binding foods and nothing to irritate.',
    tags: {'loose motion', 'sick day', 'banana', 'rice', 'vegan', 'binding'},
    ingredientKeys: {'banana', 'rice'},
  ),
  FoodRecipe(
    id: 'coconutwater',
    title: 'Tender coconut water',
    subtitle: 'Rehydrates gently',
    category: 'Sick-Day Meals',
    slot: 'Morning snack',
    ageTag: '8–12 mo',
    veg: true,
    vegan: true,
    prepMin: 2,
    cookMin: 0,
    difficulty: 'Easy',
    seed: 19,
    highlight: 'Electrolytes',
    situations: {'Loose motion'},
    comfortOnly: true,
    why:
        'Tender coconut water is a natural, gentle source of electrolytes - keeping him hydrated during loose motions without the sugar of packaged drinks. Offer small, frequent sips rather than a big serving.',
    nutrients: [
      FoodNutrient('Electrolytes', 'natural', 'Potassium and minerals lost with dehydration.'),
      FoodNutrient('Hydration', 'excellent', 'The priority when a tummy is loose.'),
    ],
    frequency: 'Small sips through the day when loose',
    ingredients: ['Fresh tender coconut water'],
    steps: ['Offer small sips of fresh coconut water, at room temperature.', 'Keep breast milk or formula going alongside.'],
    storage: ['Fresh only; discard once it has stood.'],
    mistakes: ['Replacing milk feeds entirely - fluids support them, not replace them.'],
    substitutions: {'coconut water': 'a paediatrician-advised ORS if he is very dehydrated'},
    healthierNote: 'Nature\'s electrolyte drink - no added sugar or colour, unlike bottled sports or glucose drinks.',
    tags: {'loose motion', 'sick day', 'hydration', 'coconut', 'vegan'},
    ingredientKeys: {},
  ),
  FoodRecipe(
    id: 'rasam',
    title: 'Soft tomato rasam',
    subtitle: 'Warm and soothing',
    category: 'Sick-Day Meals',
    slot: 'Lunch',
    ageTag: '10–12 mo',
    veg: true,
    vegan: true,
    prepMin: 5,
    cookMin: 15,
    difficulty: 'Easy',
    seed: 20,
    highlight: 'Vitamin C + warmth',
    situations: {'Cough & cold'},
    comfortOnly: true,
    why:
        'A warm, mildly spiced rasam is old wisdom for a blocked nose - the warmth and gentle pepper help him breathe easier, and the tomato brings vitamin C. Thin and strained, it is a comforting sip for an off-colour day.',
    nutrients: [
      FoodNutrient('Vitamin C', 'good', 'Supports immunity during a cold.'),
      FoodNutrient('Hydration', 'good', 'Warm fluids soothe and thin mucus.'),
    ],
    frequency: 'A warm sip when he is congested',
    ingredients: ['1 tomato', 'A tiny pinch of jeera and black pepper', 'Water', 'A drop of ghee (optional)'],
    steps: ['Simmer the tomato with jeera, a hint of pepper and water until soft.', 'Strain to a thin, clear rasam.', 'Cool to just-warm and offer as sips.'],
    storage: ['Fridge up to a day; reheat gently.'],
    mistakes: ['Making it too peppery - the faintest hint only for a baby.'],
    substitutions: {'black pepper': 'leave it out for younger babies'},
    healthierNote: 'Mild and low-salt - the warmth and vitamin C do the soothing, not a heavy tempering.',
    tags: {'cough', 'cold', 'sick day', 'tomato', 'vitamin c', 'vegan'},
    ingredientKeys: {'tomato'},
  ),
  FoodRecipe(
    id: 'turmericmilk',
    title: 'Golden turmeric milk',
    subtitle: 'Warm comfort at bedtime',
    category: 'Sick-Day Meals',
    slot: 'Dinner',
    ageTag: '12 mo+',
    veg: true,
    prepMin: 3,
    cookMin: 5,
    difficulty: 'Easy',
    seed: 21,
    highlight: 'Calcium + warmth',
    situations: {'Cough & cold'},
    comfortOnly: true,
    why:
        'A warm cup of milk with a pinch of turmeric is a soothing bedtime ritual once he is over a year - comforting for a scratchy throat and an easy way to wind down. The turmeric is gentle and traditional; the warmth does most of the work.',
    nutrients: [
      FoodNutrient('Calcium', 'good', 'From the milk.'),
      FoodNutrient('Warmth', 'soothing', 'Comforts a sore throat before sleep.'),
    ],
    frequency: 'A bedtime soother during a cold (from ~1 yr)',
    ingredients: ['½ cup milk', 'A tiny pinch of turmeric'],
    steps: ['Warm the milk gently with the pinch of turmeric.', 'Cool to a safe, comfortable warmth before offering.'],
    storage: ['Make fresh each time.'],
    mistakes: ['Giving cow-milk drinks as a main feed before 1 year.', 'Adding honey before 1 year - never.'],
    substitutions: {'milk': 'his usual formula, warmed, for under-ones (skip the turmeric drink)'},
    healthierNote: 'No sugar or honey - just warm milk and a hint of turmeric, the way the traditional soother is meant to be.',
    tags: {'cough', 'cold', 'sick day', 'milk', 'turmeric', 'bedtime'},
    ingredientKeys: {'milk'},
  ),
  FoodRecipe(
    id: 'moongwater',
    title: 'Moong dal water',
    subtitle: 'Light, nourishing sips',
    category: 'Sick-Day Meals',
    slot: 'Lunch',
    ageTag: '6–12 mo',
    veg: true,
    vegan: true,
    prepMin: 5,
    cookMin: 12,
    difficulty: 'Easy',
    seed: 22,
    highlight: 'Light protein + fluids',
    situations: {'Fever'},
    comfortOnly: true,
    why:
        'When a fever kills his appetite, the strained water from cooked moong dal gives him gentle protein and fluids in the lightest possible form - easy to sip and easy to digest when solid food feels like too much.',
    nutrients: [
      FoodNutrient('Protein', 'light', 'A little nourishment when he can\'t manage a meal.'),
      FoodNutrient('Hydration', 'good', 'Warm fluids matter most during a fever.'),
    ],
    frequency: 'Light sips while his appetite is low',
    ingredients: ['1 tbsp moong dal', 'Water', 'Pinch of turmeric'],
    steps: ['Cook the dal very soft with turmeric and plenty of water.', 'Strain off the thin, protein-rich water.', 'Cool to just-warm and offer as sips.'],
    storage: ['Best fresh; keep any extra in the fridge for a few hours.'],
    mistakes: ['Adding salt or heavy tempering - keep it plain and light.'],
    substitutions: {'moong dal': 'toor dal water'},
    healthierNote: 'The lightest, plainest form of nourishment - just strained dal water, no salt or oil, for when solids are too much.',
    tags: {'fever', 'sick day', 'dal water', 'moong dal', 'vegan', 'hydration'},
    ingredientKeys: {'moong dal'},
  ),
  FoodRecipe(
    id: 'lightkhichdi',
    title: 'Light khichdi, extra soft',
    subtitle: 'Easy energy when appetite is low',
    category: 'Sick-Day Meals',
    slot: 'Lunch',
    ageTag: '6–12 mo',
    veg: true,
    prepMin: 5,
    cookMin: 18,
    difficulty: 'Easy',
    seed: 23,
    highlight: 'Gentle energy + protein',
    situations: {'Fever'},
    comfortOnly: true,
    why:
        'An extra-soft, extra-mild khichdi is the friendliest solid food when he is running a fever and eating little - warm, easy energy and a little protein in a bowl he can manage even when off his food.',
    nutrients: [
      FoodNutrient('Carbohydrate', 'good', 'Gentle energy when he is not eating much.'),
      FoodNutrient('Protein', 'moderate', 'A little from the dal.'),
    ],
    frequency: 'A soft, settling meal during a fever',
    ingredients: ['2 tbsp rice', '1 tbsp moong dal', 'Extra water', 'Pinch of turmeric', 'A little ghee'],
    steps: ['Cook the rice and dal with turmeric and extra water until very soft.', 'Mash thin - looser than usual for a poorly tummy.', 'Finish with a little ghee; cool to just-warm.'],
    storage: ['Fridge up to 24 hours; loosen well when reheating.'],
    mistakes: ['Making it thick or spicy - keep it thin and plain while he is unwell.'],
    substitutions: {'moong dal': 'skip the dal for a plain rice porridge if he wants lighter'},
    healthierNote: 'Made thinner, milder and lower-salt than the everyday khichdi - all the comfort, nothing to tax a poorly tummy.',
    tags: {'fever', 'sick day', 'khichdi', 'rice', 'dal'},
    ingredientKeys: {'rice', 'moong dal'},
  ),
];

// ---- nutrition focuses ------------------------------------------------------
const List<NutritionFocus> kNutritionFocuses = [
  NutritionFocus(
    id: 'iron',
    nutrient: 'Iron',
    oneLine: 'The nutrient that matters most right now',
    why:
        'Babies are born with an iron store that starts to run low around 6 months - right when solids begin. Iron builds healthy blood and, crucially, fuels the fast brain growth of the first two years. It’s the single most important nutrient to be intentional about as your baby starts eating.',
    sources: ['Ragi (nachni)', 'Moong & other dals', 'Spinach & greens', 'Dates', 'Egg yolk', 'Iron-fortified cereals'],
    easyFoods: ['Ragi banana pancakes', 'Palak dal with rice', 'A few mashed dates'],
    deficiency: 'Persistent paleness, unusual tiredness or poor appetite can be signs - mention it to your paediatrician, who can check simply.',
    recipeIds: ['ragipancake', 'palakdal', 'ragismoothie', 'datekheer'],
    seed: 31,
    article: 'Distracted feeds: is he getting enough?',
  ),
  NutritionFocus(
    id: 'protein',
    nutrient: 'Protein',
    oneLine: 'The building blocks of growth',
    why:
        'Protein builds and repairs everything - muscle, skin, the immune system. For a rapidly growing baby it’s essential, but it doesn’t take much: a little dal, paneer, egg or curd at meals is plenty. Balance matters more than quantity.',
    sources: ['Dals & pulses', 'Paneer', 'Curd', 'Egg', 'Besan (gram flour)'],
    easyFoods: ['Moong dal khichdi', 'Paneer cutlets', 'Soft egg bhurji'],
    deficiency: 'Rare in a varied diet; a paediatrician can advise if your baby is a very selective eater.',
    recipeIds: ['moongkhichdi', 'paneercutlet', 'eggbhurji', 'besanchilla'],
    seed: 32,
  ),
  NutritionFocus(
    id: 'calcium',
    nutrient: 'Calcium',
    oneLine: 'For strong bones and teeth',
    why:
        'Calcium builds the skeleton and the teeth now forming. Milk (breast or formula) still leads in the first year; as solids grow, curd, paneer and ragi top it up. Vitamin D (a little gentle sun) helps his body use it.',
    sources: ['Milk', 'Curd', 'Paneer', 'Ragi', 'Sesame (til)'],
    easyFoods: ['Curd rice', 'Paneer cutlets', 'Ragi pancakes'],
    deficiency: 'Uncommon with milk in the diet; your paediatrician guides any concern.',
    recipeIds: ['curdrice', 'paneercutlet', 'ragipancake'],
    seed: 33,
  ),
  NutritionFocus(
    id: 'vitamina',
    nutrient: 'Vitamin A',
    oneLine: 'For eyes and immunity',
    why:
        'Vitamin A supports healthy eyes, skin and a strong immune system - helpful as your baby meets more of the world (and its germs). The orange and dark-green vegetables are the friendliest sources, and they’re naturally sweet.',
    sources: ['Sweet potato', 'Carrot', 'Pumpkin', 'Spinach', 'Mango'],
    easyFoods: ['Sweet potato mash', 'Tomato & carrot soup'],
    deficiency: 'A varied vegetable diet usually covers it; ask your paediatrician if unsure.',
    recipeIds: ['sweetpotatomash', 'tomatocarrotsoup'],
    seed: 34,
  ),
  NutritionFocus(
    id: 'fibre',
    nutrient: 'Fibre & hydration',
    oneLine: 'Keeping digestion gentle',
    why:
        'New foods can slow a baby’s digestion. Gentle fibre from wholegrains, fruit and vegetables - plus enough fluids - keeps things comfortable and regular. It’s about balance, not loading up: too much fibre can be as troublesome as too little.',
    sources: ['Oats & wholegrains', 'Fruit (banana, prune, apple)', 'Vegetables', 'Water (from 6 months, small sips)'],
    easyFoods: ['Savoury vegetable oats', 'Stewed fruit', 'Extra water with meals'],
    deficiency: 'Hard, infrequent stools can signal too little fibre or fluid - a paediatrician can guide you.',
    recipeIds: ['veggieoats', 'sweetpotatomash'],
    seed: 35,
  ),
];

// ---- lookups + engine -------------------------------------------------------
FoodRecipe foodRecipeById(String id) =>
    kFoodRecipes.firstWhere((r) => r.id == id, orElse: () => kFoodRecipes.first);
NutritionFocus focusById(String id) =>
    kNutritionFocuses.firstWhere((f) => f.id == id, orElse: () => kNutritionFocuses.first);
List<FoodRecipe> foodByCategory(String category) {
  // Only the Sick-Day Meals category surfaces the comfort-only recovery meals;
  // every other kind hides them (they belong behind the Sick-mode doorway).
  final wantSick = category == 'Sick-Day Meals';
  return kFoodRecipes
      .where((r) => r.category == category || r.tags.contains(category.toLowerCase()))
      .where((r) => wantSick || !r.comfortOnly)
      .where((r) => !FoodStore.instance.vegOnly || r.veg)
      .toList();
}
List<FoodRecipe> get recommendedFood =>
    kFoodRecipes.where((r) => !r.comfortOnly && (!FoodStore.instance.vegOnly || r.veg)).take(6).toList();

/// The unified Recipes home browse list: 3-way diet + category + immunity
/// filters, always excluding the sick-day comfort meals (they live behind the
/// Sick-mode doorway). Mirrors the old Recipes `normalRecipes` axes on the
/// richer FoodRecipe model.
List<FoodRecipe> browseRecipes({String diet = 'All', String category = 'All', bool immunity = false}) => kFoodRecipes
    .where((r) => !r.comfortOnly)
    .where((r) => diet == 'All' || r.diet == diet)
    .where((r) => category == 'All' || r.category == category)
    .where((r) => !immunity || r.immunity)
    .where((r) => !FoodStore.instance.vegOnly || r.veg)
    .toList();

/// Everyday recipes whose title matches [query] (excludes comfort-only meals).
List<FoodRecipe> searchEverydayRecipes(String query) {
  final q = query.trim().toLowerCase();
  return kFoodRecipes.where((r) => !r.comfortOnly && r.title.toLowerCase().contains(q)).toList();
}

/// Every dish that helps with a sick-day [situation] - the comfort-only recovery
/// meals plus any everyday dish tagged for it - warm-styled in the Sick-mode
/// doorway (SickDaysScreen).
List<FoodRecipe> sickFoodRecipes(String situation) =>
    kFoodRecipes.where((r) => r.situations.contains(situation)).toList();

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

/// The controlled ingredient library - every ingredient key used anywhere in the
/// recipe database. The Smart Meal Builder offers only these (never arbitrary
/// items), so a chosen ingredient always maps to real, matchable recipes.
List<String> foodIngredientLibrary() {
  final set = <String>{};
  for (final r in kFoodRecipes) {
    set.addAll(r.ingredientKeys);
  }
  return set.toList()..sort();
}

/// Today's focus (a real engine would rotate/personalise; iron leads for a
/// baby starting solids).
NutritionFocus todaysFocus() => focusById('iron');

/// Today's five-slot meal plan (seeded for the scenario child).
Map<String, FoodRecipe> todaysMeals() => {
      'Breakfast': foodRecipeById('ragipancake'),
      'Morning snack': foodRecipeById('ragismoothie'),
      'Lunch': foodRecipeById('moongkhichdi'),
      'Evening snack': foodRecipeById('tomatocarrotsoup'),
      'Dinner': foodRecipeById('palakdal'),
    };

/// A meal plan for [days] days (each day = the five slots). Deterministic per
/// day index so "regenerate" can vary it without randomness in tests.
/// Slots a thin pool can honestly borrow from. A baby's lunch and dinner are
/// interchangeable, and the two snack slots are the same kind of food - so a
/// slot with only a couple of recipes tops itself up rather than repeating.
const Map<String, List<String>> _slotNeighbours = {
  'Breakfast': ['Morning snack'],
  'Morning snack': ['Evening snack', 'Breakfast'],
  'Lunch': ['Dinner'],
  'Evening snack': ['Morning snack'],
  'Dinner': ['Lunch'],
};

Map<String, FoodRecipe> planForDay(int dayIndex) {
  final vegOnly = FoodStore.instance.vegOnly;

  List<FoodRecipe> poolFor(String s) {
    bool ok(FoodRecipe r) => !r.comfortOnly && (!vegOnly || r.veg);
    final own = kFoodRecipes.where((r) => r.slot == s && ok(r)).toList();
    // A WEEKLY plan drawn from a pool of two is the same dinner four times, so
    // top up thin slots from their neighbours. Dinner currently has only two
    // recipes authored - this keeps the plan varied until more are written.
    if (own.length >= 4) return own;
    final extra = <FoodRecipe>[];
    for (final n in _slotNeighbours[s] ?? const <String>[]) {
      extra.addAll(kFoodRecipes.where((r) => r.slot == n && ok(r)));
    }
    final merged = [...own, ...extra];
    if (merged.isNotEmpty) return merged;
    return kFoodRecipes.where(ok).toList();
  }

  // Each slot walks its pool at a DIFFERENT stride, so Tuesday is not simply
  // Monday shifted by one across the board.
  FoodRecipe slot(String s, int stride) {
    final list = poolFor(s);
    if (list.isEmpty) return kFoodRecipes.first;
    return list[((dayIndex * stride) + stride) % list.length];
  }

  return {
    'Breakfast': slot('Breakfast', 1),
    'Morning snack': slot('Morning snack', 2),
    'Lunch': slot('Lunch', 1),
    'Evening snack': slot('Evening snack', 3),
    'Dinner': slot('Dinner', 2),
  };
}

/// Smart Meal Builder: given a [meal] slot, [maxMinutes] available and the
/// ingredients the parent [has], suggest recipes (best ingredient-overlap first)
/// that fit the time. Returns each suggestion with the ingredients still to buy.
class MealSuggestion {
  const MealSuggestion(this.recipe, this.missing, this.matched);
  final FoodRecipe recipe;
  final List<String> missing; // ingredient keys not in the pantry
  final int matched; // how many pantry items it uses
}

List<MealSuggestion> buildMeals({required String meal, required int maxMinutes, required Set<String> has}) {
  final scored = <MealSuggestion>[];
  for (final r in kFoodRecipes) {
    if (r.slot != meal) continue;
    if (r.comfortOnly) continue; // sick-day meals never surface in everyday planning
    if (r.totalMin > maxMinutes) continue;
    if (FoodStore.instance.vegOnly && !r.veg) continue;
    final matched = r.ingredientKeys.where(has.contains).length;
    final missing = r.ingredientKeys.where((k) => !has.contains(k)).toList();
    scored.add(MealSuggestion(r, missing, matched));
  }
  scored.sort((a, b) {
    if (b.matched != a.matched) return b.matched.compareTo(a.matched); // most pantry use first
    return a.recipe.totalMin.compareTo(b.recipe.totalMin); // then quickest
  });
  return scored.take(5).toList();
}

// =============================================================================
//  FoodStore - saved recipes + the shopping list (ingredient -> purchased).
// =============================================================================
class FoodStore extends ChangeNotifier {
  FoodStore._();
  static final FoodStore instance = FoodStore._();

  final Set<String> _saved = {'moongkhichdi', 'ragipancake'};
  final Map<String, bool> _shopping = {}; // ingredient line -> purchased
  final List<String> _cooked = ['moongkhichdi', 'sweetpotatomash'];
  bool _vegOnly = false;

  bool isSaved(String id) => _saved.contains(id);
  void toggleSave(String id) {
    _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
    notifyListeners();
  }

  /// Vegetarian-only mode: when on, every suggestion, plan, recommendation and
  /// Smart-Meal-Builder result is filtered to vegetarian recipes.
  bool get vegOnly => _vegOnly;
  void setVeg(bool v) {
    _vegOnly = v;
    notifyListeners();
  }

  void toggleVeg() => setVeg(!_vegOnly);

  List<FoodRecipe> get saved => _saved.map(foodRecipeById).toList();
  List<FoodRecipe> get recentlyCooked => _cooked.map(foodRecipeById).toList();

  Map<String, bool> get shopping => Map.unmodifiable(_shopping);
  int get shoppingCount => _shopping.length;
  int get shoppingLeft => _shopping.values.where((p) => !p).length;

  /// Add a recipe's ingredients to the shopping list (skips ones already there).
  void addRecipeToShopping(FoodRecipe r) {
    for (final ing in r.ingredients) {
      _shopping.putIfAbsent(ing, () => false);
    }
    notifyListeners();
  }

  /// Add specific ingredient lines (used by the Smart Meal Builder's "buy missing").
  void addLines(Iterable<String> lines) {
    for (final l in lines) {
      _shopping.putIfAbsent(l, () => false);
    }
    notifyListeners();
  }

  void togglePurchased(String line) {
    _shopping[line] = !(_shopping[line] ?? false);
    notifyListeners();
  }

  void clearPurchased() {
    _shopping.removeWhere((_, purchased) => purchased);
    notifyListeners();
  }
}
