// =============================================================================
//  ParentVeda Food ("Food Companion") — content model, catalog + store
// -----------------------------------------------------------------------------
//  Recipes V2 — NOT a recipe library. A personalised food companion that answers
//  one question: "What should I feed my child today?". So the model carries far
//  more than a recipe: the WHY, key nutrients, serving frequency, storage,
//  common mistakes, ingredient substitutions, and a "Healthier ParentVeda
//  version" — plus canonical ingredient keys that power the Smart Meal Builder.
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

/// A food/recipe — the unit of the Food companion.
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
    required this.storage,
    required this.mistakes,
    required this.substitutions,
    required this.healthierNote,
    required this.tags,
    required this.ingredientKeys,
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
  final List<String> steps;
  final List<String> storage;
  final List<String> mistakes;
  final Map<String, String> substitutions; // item -> swap
  final String healthierNote; // what changed & why it's healthier
  final Set<String> tags; // search / nutrition tags
  final Set<String> ingredientKeys; // canonical keys for the Smart Meal Builder
  final String? relatedArticle;
  final String? relatedVideoId;
  final String? relatedProductId;
  final String? relatedCommunity;

  int get totalMin => prepMin + cookMin;
  String get vegLabel => veg ? 'Veg' : 'Non-veg';
}

/// One "nutrition focus of the day" — the educational strength.
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
        'Ragi (nachni) is one of the richest vegetarian sources of iron and calcium — exactly what a baby needs as his own iron stores start to run low around 6 months. Banana adds natural sweetness so there’s no need for sugar, and the soft, sturdy texture is perfect for little fingers learning to self-feed.',
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
    mistakes: ['Cooking on high heat — ragi burns fast; keep it low and slow.', 'Adding sugar or honey — never honey before 1 year.'],
    substitutions: {'banana': 'stewed apple or mashed sweet potato', 'ragi flour': 'oat flour (less iron)'},
    healthierNote:
        'The everyday version uses maida and sugar. Ours swaps in iron-and-calcium-rich ragi and lets ripe banana do the sweetening — same comforting pancake, far more nourishment and no added sugar.',
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
    frequency: 'Anytime — a great daily first food',
    ingredients: ['1 small sweet potato', 'A splash of breast milk / formula / water'],
    steps: [
      'Steam or boil the peeled, cubed sweet potato until very soft.',
      'Mash smooth, loosening with a little milk or water to the texture he manages.',
      'Serve just-warm; thin it more for a first taste.',
    ],
    storage: ['Fridge up to 2 days, or freeze in an ice-cube tray for quick single portions.'],
    mistakes: ['Serving too thick at the very first taste — start runny and thicken over weeks.'],
    substitutions: {'sweet potato': 'pumpkin or carrot (both vitamin-A rich)'},
    healthierNote: 'No added salt, sugar or butter — just the vegetable, the way a first food should be.',
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
    prepMin: 10,
    cookMin: 20,
    difficulty: 'Easy',
    seed: 3,
    highlight: 'Protein + iron',
    why:
        'Rice and moong dal together make a complete protein — all the building blocks in one soft, comforting bowl. It’s the classic Indian first meal for good reason: gentle to digest, easy to mash, and endlessly adaptable as he grows.',
    nutrients: [
      FoodNutrient('Protein', 'complete', 'Dal + rice = all essential amino acids.'),
      FoodNutrient('Iron', 'moderate', 'From the dal — pair with a squeeze of lemon later on.'),
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
    mistakes: ['Too little water — khichdi should be soft and porridge-like for a baby, not fluffy.', 'Adding salt before 1 year is best kept minimal.'],
    substitutions: {'moong dal': 'toor or masoor dal', 'rice': 'broken wheat (dalia) for older babies'},
    healthierNote: 'We keep it low-salt, add a vegetable for extra nutrients, and finish with ghee for healthy fats and vitamin absorption — not a fried tadka.',
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
        'Oats cook down soft and creamy, and a handful of grated vegetables turns breakfast into a small nutrition win. The fibre keeps digestion happy — useful in the months when new foods can slow things down.',
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
    storage: ['Best fresh — oats thicken as they sit; loosen with warm milk if needed.'],
    mistakes: ['Using flavoured/instant oats — plain oats only, no added sugar or salt.'],
    substitutions: {'oats': 'daliya (broken wheat)', 'carrot': 'any soft-cooked veg'},
    healthierNote: 'A savoury, vegetable-forward take instead of sugary oats — same 10-minute ease, real nourishment.',
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
        'Paneer is a baby-friendly powerhouse — soft, mild and rich in protein and calcium. Shaped into little cutlets your baby can grip, it’s a brilliant self-feeding snack that builds his pincer grasp while it nourishes.',
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
    mistakes: ['Deep frying — a light pan-fry in ghee is plenty.', 'Making them too big or firm to gum.'],
    substitutions: {'paneer': 'crumbled tofu', 'potato': 'sweet potato or peas'},
    healthierNote: 'Pan-fried in a little ghee, not deep-fried, and bound with rice flour instead of a heavy breadcrumb coating.',
    tags: {'protein', 'calcium', 'finger food', 'snack', 'paneer', 'vegetables'},
    ingredientKeys: {'paneer', 'vegetables'},
    relatedProductId: 'clothbook',
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
        'Folding soft-cooked spinach into dal is the gentlest way to get greens — and their iron and folate — into a baby who might refuse them plain. Blended smooth into the dal, the taste is mild and the colour is fun.',
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
    mistakes: ['Overcooking spinach for long — a quick wilt keeps more nutrients.'],
    substitutions: {'spinach': 'methi or soft-cooked bottle gourd'},
    healthierNote: 'Vitamin C (that drop of lemon) is added on purpose — it helps his body absorb far more of the plant iron.',
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
    prepMin: 5,
    cookMin: 0,
    difficulty: 'Easy',
    seed: 7,
    highlight: 'Probiotics',
    why:
        'Soft rice mashed with curd is cooling, gentle and full of gut-friendly probiotics. It needs no cooking and travels well — the easiest thing to carry for a day out, and a soother on a hot day or an upset tummy.',
    nutrients: [
      FoodNutrient('Probiotics', 'good', 'Friendly bacteria for gut health.'),
      FoodNutrient('Calcium', 'good', 'From the curd.'),
      FoodNutrient('Carbohydrate', 'good', 'Easy, gentle energy.'),
    ],
    frequency: 'Anytime — great for travel & recovery',
    ingredients: ['3 tbsp soft-cooked rice', '2 tbsp fresh curd', 'A little water to loosen'],
    steps: ['Mash the rice soft.', 'Fold in fresh curd and loosen to a soft, spoonable texture.', 'Serve cool (not cold).'],
    storage: ['Best fresh; in a cool flask it holds a few hours for travel.'],
    mistakes: ['Using sour or very cold curd.'],
    substitutions: {'curd': 'hung curd for a thicker travel version'},
    healthierNote: 'Fresh curd and no tempering or salt — just the cooling, probiotic basics a little tummy loves.',
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
        'Once eggs are introduced, soft-scrambled bhurji is a wonderful protein-rich breakfast. Eggs bring choline, which supports the fast brain development happening this year — and the soft curds are easy for little hands.',
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
    storage: ['Serve fresh — eggs are best not stored once cooked for a baby.'],
    mistakes: ['Overcooking to dry, rubbery curds.', 'Introducing egg alongside other new foods — try it alone first to spot any reaction.'],
    substitutions: {'egg': 'for vegetarians, soft crumbled paneer bhurji'},
    healthierNote: 'Cooked in a little ghee, kept soft and moist, low salt — gentle on his tummy and easy to gum.',
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
    mistakes: ['Serving raw (uncooked) ragi flour — always cook it first.'],
    substitutions: {'dates': 'ripe mango or extra banana for sweetness'},
    healthierNote: 'Sweetened only with fruit and dates — no sugar, no syrups — and thickened with iron-rich ragi instead of cornflour.',
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
    prepMin: 5,
    cookMin: 15,
    difficulty: 'Easy',
    seed: 10,
    highlight: 'Vitamin A + C',
    why:
        'A silky tomato-carrot soup is warmth and vitamins in a cup — vitamin A for immunity and vitamin C to help him absorb iron from the rest of his meals. Lovely as a light evening sip, especially with a stuffy nose.',
    nutrients: [
      FoodNutrient('Vitamin A', 'good', 'Immunity and eyes.'),
      FoodNutrient('Vitamin C', 'good', 'Boosts iron absorption.'),
      FoodNutrient('Hydration', 'good', 'Gentle fluids.'),
    ],
    frequency: 'A few times a week',
    ingredients: ['1 tomato', '1 small carrot', 'A little water', 'A drop of ghee'],
    steps: ['Cook tomato and carrot soft.', 'Blend smooth and strain if needed.', 'Warm through with a drop of ghee; serve just-warm.'],
    storage: ['Fridge up to 2 days; reheat gently.'],
    mistakes: ['Adding stock cubes or salt — the vegetables are sweet enough.'],
    substitutions: {'carrot': 'pumpkin or bottle gourd'},
    healthierNote: 'No cream, no salt, no stock cubes — just blended vegetables and a drop of ghee for absorption.',
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
        'Besan (gram flour) is quietly high in protein and iron. Thinned soft and cooked gently, chilla makes a savoury, grippable snack — a nice change from sweet foods and a good way to widen his palate.',
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
    mistakes: ['Making it thick and doughy — keep the batter thin so the chilla stays soft.'],
    substitutions: {'besan': 'moong dal batter (soaked & ground)'},
    healthierNote: 'Cooked soft in a little ghee, loaded with vegetables, no chilli or heavy salt — savoury nutrition, gently done.',
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
        'A treat that still nourishes — dates bring natural sweetness plus iron, and banana makes it creamy. It proves dessert doesn’t need sugar to feel special, and it’s a gentle way to end a meal.',
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
    mistakes: ['Adding sugar or condensed milk — the dates are the sweetness.'],
    substitutions: {'dates': 'ripe mango or stewed apple'},
    healthierNote: 'Traditional kheer is sugar-and-condensed-milk heavy. Ours sweetens only with dates and banana — a real dessert, no added sugar.',
    tags: {'dessert', 'iron', 'no sugar', 'dates', 'banana', 'milk'},
    ingredientKeys: {'dates', 'banana', 'milk'},
  ),
];

// ---- nutrition focuses ------------------------------------------------------
const List<NutritionFocus> kNutritionFocuses = [
  NutritionFocus(
    id: 'iron',
    nutrient: 'Iron',
    oneLine: 'The nutrient that matters most right now',
    why:
        'Babies are born with an iron store that starts to run low around 6 months — right when solids begin. Iron builds healthy blood and, crucially, fuels the fast brain growth of the first two years. It’s the single most important nutrient to be intentional about as your baby starts eating.',
    sources: ['Ragi (nachni)', 'Moong & other dals', 'Spinach & greens', 'Dates', 'Egg yolk', 'Iron-fortified cereals'],
    easyFoods: ['Ragi banana pancakes', 'Palak dal with rice', 'A few mashed dates'],
    deficiency: 'Persistent paleness, unusual tiredness or poor appetite can be signs — mention it to your paediatrician, who can check simply.',
    recipeIds: ['ragipancake', 'palakdal', 'ragismoothie', 'datekheer'],
    seed: 31,
    article: 'Distracted feeds: is he getting enough?',
  ),
  NutritionFocus(
    id: 'protein',
    nutrient: 'Protein',
    oneLine: 'The building blocks of growth',
    why:
        'Protein builds and repairs everything — muscle, skin, the immune system. For a rapidly growing baby it’s essential, but it doesn’t take much: a little dal, paneer, egg or curd at meals is plenty. Balance matters more than quantity.',
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
        'Vitamin A supports healthy eyes, skin and a strong immune system — helpful as your baby meets more of the world (and its germs). The orange and dark-green vegetables are the friendliest sources, and they’re naturally sweet.',
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
        'New foods can slow a baby’s digestion. Gentle fibre from wholegrains, fruit and vegetables — plus enough fluids — keeps things comfortable and regular. It’s about balance, not loading up: too much fibre can be as troublesome as too little.',
    sources: ['Oats & wholegrains', 'Fruit (banana, prune, apple)', 'Vegetables', 'Water (from 6 months, small sips)'],
    easyFoods: ['Savoury vegetable oats', 'Stewed fruit', 'Extra water with meals'],
    deficiency: 'Hard, infrequent stools can signal too little fibre or fluid — a paediatrician can guide you.',
    recipeIds: ['veggieoats', 'sweetpotatomash'],
    seed: 35,
  ),
];

// ---- lookups + engine -------------------------------------------------------
FoodRecipe foodRecipeById(String id) =>
    kFoodRecipes.firstWhere((r) => r.id == id, orElse: () => kFoodRecipes.first);
NutritionFocus focusById(String id) =>
    kNutritionFocuses.firstWhere((f) => f.id == id, orElse: () => kNutritionFocuses.first);
List<FoodRecipe> foodByCategory(String category) => kFoodRecipes
    .where((r) => (r.category == category || r.tags.contains(category.toLowerCase())) && (!FoodStore.instance.vegOnly || r.veg))
    .toList();
List<FoodRecipe> get recommendedFood =>
    kFoodRecipes.where((r) => !FoodStore.instance.vegOnly || r.veg).take(6).toList();

/// The controlled ingredient library — every ingredient key used anywhere in the
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
Map<String, FoodRecipe> planForDay(int dayIndex) {
  FoodRecipe slot(String s, int offset) {
    final pool = kFoodRecipes.where((r) => r.slot == s && (!FoodStore.instance.vegOnly || r.veg)).toList();
    final list = pool.isEmpty ? kFoodRecipes : pool;
    return list[(dayIndex + offset) % list.length];
  }

  return {
    'Breakfast': slot('Breakfast', 0),
    'Morning snack': slot('Morning snack', 1),
    'Lunch': slot('Lunch', 0),
    'Evening snack': slot('Evening snack', 1),
    'Dinner': slot('Dinner', 0),
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
//  FoodStore — saved recipes + the shopping list (ingredient -> purchased).
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
