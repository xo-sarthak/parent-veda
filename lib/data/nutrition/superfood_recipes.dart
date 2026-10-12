// =============================================================================
//  Nutrition — the week's superfood, as a recipe (2026-10-10)
// -----------------------------------------------------------------------------
//  Every pregnancy week names an "Indian superfood of the week" (the week
//  page › You this week › Health › Diet). It was a card with three lines and
//  nothing to cook: the user's note, "this week food idea tool should be in
//  depth like recipe?".
//
//  So the card now opens a recipe, on the recipe page the Nutrition door
//  already ships (`RecipeCookScreen`: ingredients that scale, numbered
//  steps, cook mode, add to list). No second recipe renderer.
//
//  ⚠️ MOST SUPERFOODS ALREADY HAVE A RECIPE. Palak is `dal_palak`, rajma is
//  `punjabi_rajma`, ragi is `tamil_ragi_kanji`, and so on: `recipeForSuperfood`
//  points at those first. The eight below are the foods the library had no
//  dish for. They join `kRecipes` (see the foot of nutrition_data.dart), so
//  they are in the recipe library too, with the same tests over them as
//  every other recipe: a real kitchen time, quantities that never print a
//  decimal, an energy estimate that reads like one dish.
//
//  The rules every Nutrition recipe keeps: a named dish a mother already
//  cooks; "why now" is a fact about the food, never a target for her;
//  "well cooked" rather than forbidden; nothing personalised.
// =============================================================================

import '../../localization/app_language.dart';
import '../nutrition_data.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

RecipeIngredient _i(String name, double qty, String unit) =>
    RecipeIngredient(name: _en(name), qtyPerServing: qty, unit: unit);

final List<Recipe> kSuperfoodRecipes = [
  Recipe(
    id: 'sf_kala_chana_chaat',
    minutes: 20,
    fact: 'Kala chana keeps its dark skin, and most of its fibre is in it.',
    meals: const [RecipeMeal.snack, RecipeMeal.breakfast],
    kind: RecipeKind.light,
    name: _en('Kala chana chaat'),
    whyNow: _en('Black chickpeas bring plant protein, iron and fibre in one '
        'small bowl. The lemon on top helps the iron go in.'),
    region: RecipeRegion.panIndian,
    tags: const ['protein', 'iron', 'fibre', 't1', 't2', 't3', 'constipation', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Kala chana, soaked overnight', 40, 'g'),
      _i('Onion and tomato, finely chopped', 50, 'g'),
      _i('Cucumber, chopped', 30, 'g'),
      _i('Chaat masala', 0.25, 'tsp'),
      _i('Roasted cumin powder', 0.25, 'tsp'),
      _i('Lemon', 0.25, 'pcs'),
      _i('Coriander leaves', 1, 'tbsp'),
    ],
    steps: [
      _en('Soak the chana overnight. In the morning, drain and rinse it.'),
      _en('Pressure cook with fresh water and a little salt for five to six whistles, until a chana crushes easily between two fingers.'),
      _en('Drain and let it cool a little.'),
      _en('Toss with the onion, tomato and cucumber.'),
      _en('Season with chaat masala, cumin, salt and a squeeze of lemon. Finish with coriander and eat it fresh.'),
    ],
    nutritionGlance: const ['Protein', 'Iron', 'Fibre'],
    videoTitle: 'Cook along: kala chana chaat',
  ),
  Recipe(
    id: 'sf_sattu_sharbat',
    minutes: 10,
    fact: 'Sattu is roasted chana, ground. It is cooked already, which is why it can be stirred straight into water.',
    meals: const [RecipeMeal.breakfast, RecipeMeal.snack],
    kind: RecipeKind.drink,
    name: _en('Salted sattu sharbat'),
    whyNow: _en('A glass of sattu is protein and fibre you can drink, and it '
        'is cooling on a hot afternoon.'),
    region: RecipeRegion.panIndian,
    tags: const ['protein', 'fibre', 't1', 't2', 't3', 'constipation', 'jain'],
    defaultServings: 1,
    ingredients: [
      _i('Sattu (roasted chana flour)', 2, 'tbsp'),
      _i('Cold water', 1, 'cup'),
      _i('Roasted cumin powder', 0.25, 'tsp'),
      _i('Black salt', 0.25, 'tsp'),
      _i('Lemon', 0.5, 'pcs'),
      _i('Mint leaves, torn', 1, 'tbsp'),
    ],
    steps: [
      _en('Whisk the sattu into a little of the water first, so it does not form lumps.'),
      _en('Add the rest of the water and stir well.'),
      _en('Add the cumin, black salt and lemon, and taste.'),
      _en('Drop in the mint and drink it soon, stirring once, because sattu settles.'),
    ],
    nutritionGlance: const ['Protein', 'Fibre', 'Cooling'],
    videoTitle: 'Cook along: sattu sharbat',
  ),
  Recipe(
    id: 'sf_guava_chaat',
    minutes: 10,
    fact: 'One guava has more vitamin C than an orange.',
    meals: const [RecipeMeal.snack],
    kind: RecipeKind.light,
    name: _en('Guava chaat with black salt'),
    whyNow: _en('Guava is vitamin C and fibre. Eaten with an iron-rich meal, '
        'its vitamin C helps the iron go in.'),
    region: RecipeRegion.panIndian,
    tags: const ['vitamin_c', 'fibre', 't1', 't2', 't3', 'constipation', 'jain'],
    defaultServings: 1,
    ingredients: [
      _i('Ripe guava', 1, 'pcs'),
      _i('Black salt', 0.25, 'tsp'),
      _i('Roasted cumin powder', 0.25, 'tsp'),
      _i('Red chilli powder, optional', 0.25, 'tsp'),
      _i('Lemon', 0.25, 'pcs'),
    ],
    steps: [
      _en('Wash the guava well under running water and pat it dry.'),
      _en('Cut it into wedges or cubes. The seeds can stay.'),
      _en('Sprinkle the black salt, cumin and chilli if you like it, and squeeze over the lemon.'),
      _en('Eat it straight away. Cut fruit that sits out for hours is the one to skip.'),
    ],
    nutritionGlance: const ['Vitamin C', 'Fibre', 'Seasonal'],
    videoTitle: 'Cook along: guava chaat',
  ),
  Recipe(
    id: 'sf_amla_chutney',
    minutes: 15,
    fact: "Amla keeps much of its vitamin C even when it's ground into a chutney.",
    meals: const [RecipeMeal.lunch, RecipeMeal.dinner],
    kind: RecipeKind.light,
    name: _en('Amla and coriander chutney'),
    whyNow: _en('A spoon of amla chutney beside dal and roti adds vitamin C to '
        'the plate, which helps the iron from the meal go in.'),
    region: RecipeRegion.panIndian,
    tags: const ['vitamin_c', 'iron', 't1', 't2', 't3', 'jain'],
    defaultServings: 4,
    ingredients: [
      _i('Amla, deseeded', 0.5, 'pcs'),
      _i('Coriander leaves', 2, 'tbsp'),
      _i('Mint leaves', 1, 'tbsp'),
      _i('Ginger, small piece', 0.5, 'pcs'),
      _i('Jaggery, grated', 0.5, 'tsp'),
      _i('Roasted cumin powder', 0.25, 'tsp'),
    ],
    steps: [
      _en('Wash the amla, cut the flesh away from the seed and chop it.'),
      _en('Put everything in a small jar with a pinch of salt and a few spoons of water.'),
      _en('Grind to a smooth chutney, adding water a little at a time.'),
      _en('Taste: a little more jaggery softens the sourness.'),
      _en('Keep it covered in the fridge and finish it within two days.'),
    ],
    nutritionGlance: const ['Vitamin C', 'With dal and roti', 'Two days in the fridge'],
    videoTitle: 'Cook along: amla chutney',
  ),
  Recipe(
    id: 'sf_til_gud_laddoo',
    minutes: 25,
    fact: 'A spoon of til has about as much calcium as a third of a glass of milk.',
    meals: const [RecipeMeal.snack],
    kind: RecipeKind.sweet,
    name: _en('Til and gud laddoo'),
    whyNow: _en('Sesame brings calcium and good fat, jaggery brings iron. One '
        'small laddoo is a sweet that also does some work.'),
    region: RecipeRegion.maharashtrian,
    tags: const ['calcium', 'iron', 't2', 't3', 'jain'],
    defaultServings: 6,
    ingredients: [
      _i('White til (sesame seeds)', 15, 'g'),
      _i('Jaggery, grated', 10, 'g'),
      _i('Peanuts, roasted and crushed', 5, 'g'),
      _i('Cardamom, ground', 0.25, 'tsp'),
      _i('Ghee', 0.25, 'tsp'),
    ],
    steps: [
      _en('Dry roast the til on a low flame, stirring all the time, until it smells nutty and a few seeds pop. Tip it onto a plate.'),
      _en('In the same pan, melt the jaggery with the ghee on low until it is just liquid and bubbling.'),
      _en('Take the pan off the heat and stir in the til, peanuts and cardamom quickly.'),
      _en('With greased palms, roll small laddoos while the mixture is warm. It sets as it cools.'),
    ],
    nutritionGlance: const ['Calcium', 'Iron', 'One laddoo is a serving'],
    videoTitle: 'Cook along: til laddoo',
  ),
  Recipe(
    id: 'sf_flaxseed_roti',
    minutes: 25,
    fact: 'Flaxseed is best ground: whole seeds often pass through without giving up their goodness.',
    meals: const [RecipeMeal.lunch, RecipeMeal.dinner],
    kind: RecipeKind.main,
    name: _en('Alsi (flaxseed) roti'),
    whyNow: _en('A spoon of ground flaxseed in the atta adds fibre and '
        'plant omega-3 to a roti you would make anyway.'),
    region: RecipeRegion.punjabi,
    tags: const ['fibre', 'omega3_dha', 't2', 't3', 'constipation', 'jain'],
    defaultServings: 2,
    ingredients: [
      _i('Wheat flour (atta)', 50, 'g'),
      _i('Flaxseed, roasted and ground', 1, 'tsp'),
      _i('Ajwain', 0.25, 'tsp'),
      _i('Ghee', 0.5, 'tsp'),
    ],
    steps: [
      _en('Dry roast the flaxseed for two minutes, cool it and grind it to a powder.'),
      _en('Mix the atta, ground flaxseed, ajwain and a pinch of salt.'),
      _en('Add water little by little and knead a soft dough. Rest it, covered, for ten minutes.'),
      _en('Roll out rotis and cook them on a hot tawa, turning once, until both sides have brown spots.'),
      _en('Brush with a little ghee and serve warm with dal or sabzi.'),
    ],
    nutritionGlance: const ['Fibre', 'Plant omega-3', 'Everyday roti'],
    videoTitle: 'Cook along: flaxseed roti',
  ),
  Recipe(
    id: 'sf_soya_matar_sabzi',
    minutes: 30,
    fact: 'Soybean is one of the few plant foods with all the protein building blocks the body needs.',
    meals: const [RecipeMeal.lunch, RecipeMeal.dinner],
    kind: RecipeKind.main,
    name: _en('Soya chunks and matar sabzi'),
    whyNow: _en('Soya chunks are one of the richest vegetarian proteins in the '
        'kitchen, and the peas add fibre.'),
    region: RecipeRegion.panIndian,
    tags: const ['protein', 'fibre', 't2', 't3', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Soya chunks', 25, 'g'),
      _i('Green peas', 40, 'g'),
      _i('Onion, chopped', 0.5, 'pcs'),
      _i('Tomato, chopped', 0.5, 'pcs'),
      _i('Ginger-garlic paste', 0.5, 'tsp'),
      _i('Turmeric, coriander and cumin powder', 0.5, 'tsp'),
      _i('Oil', 1, 'tsp'),
    ],
    steps: [
      _en('Boil the soya chunks in salted water for five minutes. Drain, cool and squeeze out the water.'),
      _en('Heat the oil and soften the onion. Add the ginger-garlic paste and cook until it smells cooked.'),
      _en('Add the tomato and the spice powders and cook until the oil separates.'),
      _en('Add the soya chunks, peas and half a cup of water. Cover and simmer for ten minutes, until the peas are soft.'),
      _en('Serve hot with roti or rice.'),
    ],
    nutritionGlance: const ['Protein', 'Fibre', 'Vegetarian'],
    videoTitle: 'Cook along: soya matar',
  ),
  Recipe(
    id: 'sf_chole_masala',
    minutes: 40,
    fact: 'Chickpeas are one of the oldest cultivated pulses in the world, and a staple across India.',
    meals: const [RecipeMeal.lunch, RecipeMeal.dinner],
    kind: RecipeKind.main,
    name: _en('Home-style chole'),
    whyNow: _en('A bowl of chole is protein, iron, folate and fibre. A squeeze '
        'of lemon on top helps the iron go in.'),
    region: RecipeRegion.punjabi,
    tags: const ['protein', 'iron', 'folic_acid', 'fibre', 't1', 't2', 't3', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Kabuli chickpeas, soaked overnight', 50, 'g'),
      _i('Onion, chopped', 0.5, 'pcs'),
      _i('Tomato, pureed', 1, 'pcs'),
      _i('Ginger-garlic paste', 0.5, 'tsp'),
      _i('Chole masala', 0.5, 'tsp'),
      _i('Oil', 1, 'tsp'),
      _i('Lemon', 0.25, 'pcs'),
    ],
    steps: [
      _en('Soak the chickpeas overnight. Drain, rinse and pressure cook with fresh water and salt for six to seven whistles, until they are soft right through.'),
      _en('Heat the oil and cook the onion until golden. Add the ginger-garlic paste.'),
      _en('Add the tomato and chole masala and cook until the oil separates.'),
      _en('Add the chickpeas with some of their water and simmer for ten minutes. Mash a few against the pan to thicken it.'),
      _en('Squeeze over the lemon and serve with roti or rice.'),
    ],
    nutritionGlance: const ['Protein', 'Iron', 'Folate'],
    videoTitle: 'Cook along: chole',
  ),
];

/// Which recipe a week's superfood opens, by the superfood's English name.
///
/// ⚠️ MATCHED ON `.en`, THE IDENTITY, NEVER `.now`. The names come from
/// weekContent.json ("Palak (Spinach)", "Til (Sesame Seeds)"), so the match
/// is by the word in them, first match wins. Null when nothing matches: the
/// card then stays as it was, without the recipe link, rather than opening
/// a dish that is not this food.
const List<(String, String)> _kSuperfoodToRecipe = [
  ('kala chana', 'sf_kala_chana_chaat'),
  ('sattu', 'sf_sattu_sharbat'),
  ('nariyal', 'coconut_water_cooler'),
  ('coconut water', 'coconut_water_cooler'),
  ('moong', 'moong_dal_soup'),
  ('peanut', 'peanut_jaggery_chikki'),
  ('paneer', 'paneer_paratha'),
  ('guava', 'sf_guava_chaat'),
  ('amla', 'sf_amla_chutney'),
  ('palak', 'dal_palak'),
  ('spinach', 'dal_palak'),
  ('ragi', 'tamil_ragi_kanji'),
  ('til', 'sf_til_gud_laddoo'),
  ('sesame', 'sf_til_gud_laddoo'),
  ('flax', 'sf_flaxseed_roti'),
  ('almond', 'badam_milk'),
  ('walnut', 'dates_nuts_laddoo'),
  ('soy', 'sf_soya_matar_sabzi'),
  ('rajma', 'punjabi_rajma'),
  ('chole', 'sf_chole_masala'),
  ('oats', 'oats_porridge_dates'),
  ('banana', 'banana_dates_smoothie'),
];

Recipe? recipeForSuperfood(String foodEn) {
  final f = foodEn.toLowerCase();
  for (final (word, id) in _kSuperfoodToRecipe) {
    if (!RegExp('\\b${RegExp.escape(word)}').hasMatch(f)) continue;
    for (final r in kRecipes) {
      if (r.id == id) return r;
    }
  }
  return null;
}
