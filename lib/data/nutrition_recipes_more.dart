// =============================================================================
//  Nutrition — the recipes that make the meal tiles real (2026-09-20)
// -----------------------------------------------------------------------------
//  The first sixteen recipes were mains with a chilla or two; when the user
//  asked for "a breakfast, a sweet, a soup, a drink" the honest answer was
//  that we had two or three of each. These twenty-four fill the tiles:
//  breakfasts, snacks, sweets, drinks, soups, and the non-vegetarian mains a
//  non-vegetarian chart promises. Same model, same page, same scaler.
//
//  Rules that hold here as everywhere in Nutrition: named dishes a mother
//  already cooks, not macros; "why now" is a fact about the food, never a
//  target for her; nothing is forbidden, some things are "well cooked";
//  jaggery and dates are sweetness with iron in it, and a sweet is a sweet,
//  not a sin. Diet is respected by tag: `egg`, `fish`, `meat`, `non_veg`,
//  `onion_garlic` — see `recipeSuits`.
//
//  Photos: `nut_r_<id>` in read_images.dart when picked; until then the dish
//  word in the name finds the plate photo (`nutritionPhotoFor`).
// =============================================================================

import '../localization/app_language.dart';
import 'nutrition_data.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

RecipeIngredient _i(String name, double qty, String unit) =>
    RecipeIngredient(name: _en(name), qtyPerServing: qty, unit: unit);

final List<Recipe> kMoreRecipes = [
  // ===========================================================================
  //  BREAKFASTS
  // ===========================================================================
  Recipe(
    id: 'vegetable_poha',
    minutes: 15,
    fact: "The lemon on poha is not decoration: vitamin C turns the peanuts' iron into iron you absorb.",
    meals: const [RecipeMeal.breakfast, RecipeMeal.snack],
    kind: RecipeKind.light,
    name: _en('Vegetable poha with peanuts'),
    whyNow: _en('Flattened rice is light on a queasy morning, and the peanuts '
        'and lemon on top turn it into iron you can absorb.'),
    region: RecipeRegion.maharashtrian,
    tags: const ['iron', 't1', 'nausea', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Thick poha, rinsed and drained', 60, 'g'),
      _i('Onion, chopped', 0.5, 'pcs'),
      _i('Peanuts', 1, 'tbsp'),
      _i('Green peas or chopped carrot', 2, 'tbsp'),
      _i('Mustard seeds, curry leaves, turmeric', 1, 'tsp'),
      _i('Oil', 1, 'tsp'),
      _i('Lemon', 0.25, 'pcs'),
    ],
    steps: [
      _en('Rinse the poha in a colander until it softens, and leave it to drain.'),
      _en('Heat the oil; pop the mustard seeds, then fry the peanuts until they colour.'),
      _en('Add the onion, curry leaves and turmeric; cook until the onion is soft.'),
      _en('Stir in the peas or carrot, then the poha and salt; cover for two minutes on low.'),
      _en('Finish with a squeeze of lemon. It helps your body take in the iron.'),
    ],
    nutritionGlance: const ['Iron 2mg', 'Fibre 3g', 'Light and quick'],
    videoTitle: 'Cook along: vegetable poha',
  ),
  Recipe(
    id: 'vegetable_upma',
    minutes: 20,
    fact: "A handful of vegetables in upma doubles its fibre for no extra cooking time.",
    meals: const [RecipeMeal.breakfast, RecipeMeal.dinner],
    kind: RecipeKind.light,
    name: _en('Vegetable upma'),
    whyNow: _en('A warm, soft breakfast that settles easily and carries a '
        'handful of vegetables in without you noticing.'),
    region: RecipeRegion.southIndian,
    tags: const ['fibre', 't1', 'nausea', 't3', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Semolina (rava), dry-roasted', 50, 'g'),
      _i('Onion, chopped', 0.5, 'pcs'),
      _i('Carrot and beans, chopped', 40, 'g'),
      _i('Ginger, grated', 0.5, 'tsp'),
      _i('Mustard seeds, urad dal, curry leaves', 1, 'tsp'),
      _i('Ghee', 1, 'tsp'),
      _i('Water', 1.25, 'cup'),
    ],
    steps: [
      _en('Dry-roast the rava until it smells nutty, and set it aside.'),
      _en('Heat the ghee; pop the mustard seeds and urad dal, add the curry leaves and ginger.'),
      _en('Cook the onion and vegetables until soft, then pour in the water and salt and bring to a boil.'),
      _en('Lower the heat and rain in the rava, stirring so no lumps form.'),
      _en('Cover for three minutes, then fluff with a fork.'),
    ],
    nutritionGlance: const ['Fibre 4g', 'Protein 5g', 'Gentle on the stomach'],
    videoTitle: 'Cook along: vegetable upma',
  ),
  Recipe(
    id: 'oats_porridge_dates',
    minutes: 12,
    fact: "Two dates sweeten a bowl and add about a milligram of iron. Sugar would add none.",
    meals: const [RecipeMeal.breakfast],
    kind: RecipeKind.light,
    name: _en('Oats porridge with dates and almonds'),
    whyNow: _en('Slow oats keep the morning steady, dates bring iron and '
        'sweetness without sugar, and the milk is calcium before nine.'),
    region: RecipeRegion.panIndian,
    tags: const ['fibre', 'calcium', 'iron', 'gestational_diabetes', 't2', 't3', 'constipation'],
    defaultServings: 1,
    ingredients: [
      _i('Rolled oats', 40, 'g'),
      _i('Milk', 1, 'cup'),
      _i('Dates, pitted and chopped', 2, 'pcs'),
      _i('Almonds, sliced', 5, 'pcs'),
      _i('Cardamom, ground', 0.25, 'tsp'),
    ],
    steps: [
      _en('Warm the milk in a pan and stir in the oats.'),
      _en('Simmer five to six minutes, stirring, until it thickens to how you like it.'),
      _en('Stir in the dates and cardamom; the dates do the sweetening.'),
      _en('Top with the almonds and eat warm.'),
      // Appendix A (What to Expect, "Good Morning Granola"): an Indian crunch.
      _en('For a change, skip the dates and top it with a spoon of roasted '
          'makhana and a little grated jaggery instead.'),
    ],
    nutritionGlance: const ['Fibre 6g', 'Calcium 300mg', 'Iron 2mg'],
    videoTitle: 'Cook along: oats porridge',
  ),
  Recipe(
    id: 'egg_bhurji_roti',
    minutes: 20,
    fact: "An egg is one of the few foods with choline, which the baby's brain uses this month.",
    meals: const [RecipeMeal.breakfast, RecipeMeal.dinner],
    kind: RecipeKind.main,
    name: _en('Egg bhurji with roti'),
    whyNow: _en('Two eggs are complete protein and choline for the brain '
        'being built this month, cooked through, in ten minutes.'),
    region: RecipeRegion.panIndian,
    tags: const ['egg', 'protein', 't2', 't3', 'onion_garlic'],
    defaultServings: 1,
    ingredients: [
      _i('Eggs', 2, 'pcs'),
      _i('Onion, chopped', 0.5, 'pcs'),
      _i('Tomato, chopped', 0.5, 'pcs'),
      _i('Green chilli, chopped', 0.5, 'pcs'),
      _i('Turmeric and coriander leaves', 0.5, 'tsp'),
      _i('Ghee', 1, 'tsp'),
      _i('Whole-wheat roti', 2, 'pcs'),
    ],
    steps: [
      _en('Heat the ghee and soften the onion, then the tomato and chilli with turmeric and salt.'),
      _en('Beat the eggs and pour them in; stir gently as they set.'),
      _en("Cook until there's no wet egg left. In pregnancy, eggs should be fully set."),
      _en('Scatter coriander and roll into warm rotis.'),
      // Appendix A (What to Expect, "Broccoli-Cheddar Omelet"): greens folded in.
      _en('For greens, stir a handful of chopped spinach or methi in with the '
          'tomato. It wilts in a minute and adds folate and iron.'),
    ],
    nutritionGlance: const ['Protein 16g', 'Choline', 'Eggs cooked through'],
    videoTitle: 'Cook along: egg bhurji',
  ),
  Recipe(
    id: 'paneer_paratha',
    minutes: 30,
    fact: "Fifty grams of paneer is a quarter of a day's calcium, more than a glass of milk.",
    meals: const [RecipeMeal.breakfast, RecipeMeal.lunch],
    kind: RecipeKind.main,
    name: _en('Paneer paratha with curd'),
    whyNow: _en('Paneer inside, curd beside: calcium twice over and enough '
        'protein to hold you until lunch.'),
    region: RecipeRegion.punjabi,
    tags: const ['calcium', 'protein', 't2', 't3'],
    defaultServings: 2,
    ingredients: [
      _i('Whole-wheat flour', 60, 'g'),
      _i('Paneer, crumbled', 50, 'g'),
      _i('Coriander leaves and green chilli, chopped', 1, 'tbsp'),
      _i('Ajwain', 0.25, 'tsp'),
      _i('Ghee', 1, 'tsp'),
      _i('Curd', 0.5, 'cup'),
    ],
    steps: [
      _en('Knead the flour with water into a soft dough and rest it ten minutes.'),
      _en('Mix the paneer with coriander, chilli, ajwain and salt.'),
      _en('Roll a ball, fill it with paneer, seal and roll out gently.'),
      _en('Cook on a hot tawa with a little ghee until both sides brown.'),
      _en('Serve with curd.'),
    ],
    nutritionGlance: const ['Calcium 250mg', 'Protein 12g', 'Whole wheat'],
    videoTitle: 'Cook along: paneer paratha',
  ),
  Recipe(
    id: 'idli_with_sambar',
    minutes: 35,
    fact: "Idli batter ferments overnight and the microbes make folate as they go.",
    meals: const [RecipeMeal.breakfast, RecipeMeal.dinner],
    kind: RecipeKind.main,
    name: _en('Idli with sambar'),
    whyNow: _en('Steamed, fermented and easy to keep down. The breakfast '
        'most women can face in the first weeks, with sambar for the dal.'),
    region: RecipeRegion.southIndian,
    tags: const ['t1', 'nausea', 'protein', 'fibre'],
    defaultServings: 2,
    ingredients: [
      _i('Idli batter (shop or home)', 1, 'cup'),
      _i('Toor dal, cooked', 50, 'g'),
      _i('Mixed vegetables (drumstick, carrot, pumpkin)', 60, 'g'),
      _i('Sambar powder', 1, 'tsp'),
      _i('Tamarind pulp', 1, 'tsp'),
      _i('Mustard seeds, curry leaves, oil', 1, 'tsp'),
    ],
    steps: [
      _en('Steam the idlis in greased moulds for ten to twelve minutes.'),
      _en('Simmer the vegetables in water with turmeric until tender.'),
      _en('Add the cooked dal, sambar powder, tamarind and salt; simmer five minutes.'),
      _en('Temper mustard seeds and curry leaves in oil and pour over.'),
      _en('Serve the idlis in a bowl of sambar.'),
    ],
    nutritionGlance: const ['Protein 8g', 'Fibre 5g', 'Fermented, steamed'],
    videoTitle: 'Cook along: idli sambar',
  ),

  // ===========================================================================
  //  SNACKS
  // ===========================================================================
  Recipe(
    id: 'roasted_makhana',
    minutes: 10,
    fact: "Makhana is a water-lily seed: high in calcium and magnesium, low in fat, and it keeps for weeks.",
    meals: const [RecipeMeal.snack],
    kind: RecipeKind.light,
    name: _en('Ghee-roasted makhana'),
    whyNow: _en('A crunchy snack that is calcium and protein rather than '
        'fried flour, and it keeps in a jar for the three o\'clock hunger.'),
    region: RecipeRegion.panIndian,
    tags: const ['calcium', 'protein', 'gestational_diabetes', 't2', 't3', 'jain'],
    defaultServings: 2,
    ingredients: [
      _i('Makhana (fox nuts)', 30, 'g'),
      _i('Ghee', 0.5, 'tsp'),
      _i('Black pepper and rock salt', 0.25, 'tsp'),
      _i('Turmeric', 0.25, 'tsp'),
    ],
    steps: [
      _en('Heat the ghee in a wide pan on low.'),
      _en('Add the makhana and roast, tossing, for six to eight minutes until crisp.'),
      _en('Sprinkle turmeric, pepper and salt; toss once more and cool before storing.'),
    ],
    nutritionGlance: const ['Calcium', 'Protein 3g', 'Low in fat'],
    videoTitle: 'Cook along: roasted makhana',
  ),
  Recipe(
    id: 'sprouts_chaat',
    minutes: 15,
    fact: "Sprouting a moong bean roughly doubles its folate and vitamin C.",
    meals: const [RecipeMeal.snack, RecipeMeal.breakfast],
    kind: RecipeKind.light,
    name: _en('Steamed sprouts chaat'),
    whyNow: _en('Sprouted moong is protein, folate and fibre in one bowl. '
        "It's steamed, because raw sprouts are the one thing to skip right now."),
    region: RecipeRegion.panIndian,
    tags: const ['protein', 'folic_acid', 'fibre', 't1', 't2', 'constipation', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Moong sprouts', 80, 'g'),
      _i('Onion, tomato, cucumber, chopped', 60, 'g'),
      _i('Boiled potato, cubed', 0.5, 'pcs'),
      _i('Chaat masala and roasted cumin', 0.5, 'tsp'),
      _i('Lemon', 0.25, 'pcs'),
      _i('Coriander leaves', 1, 'tbsp'),
    ],
    steps: [
      _en('Steam the sprouts for five to six minutes, until cooked through and no longer raw.'),
      _en('Cool, then toss with the vegetables and potato.'),
      _en('Season with chaat masala, cumin, salt and lemon; finish with coriander.'),
    ],
    nutritionGlance: const ['Protein 9g', 'Folate', 'Fibre 6g'],
    videoTitle: 'Cook along: sprouts chaat',
  ),
  Recipe(
    id: 'fruit_chaat',
    minutes: 10,
    fact: "The vitamin C in a bowl of cut fruit helps the iron from the rest of the day's food go in.",
    meals: const [RecipeMeal.snack],
    kind: RecipeKind.light,
    name: _en('Fruit chaat with roasted cumin'),
    whyNow: _en('Seasonal fruit, cut and salted, is vitamin C that helps the '
        'iron from the rest of the day go in.'),
    region: RecipeRegion.panIndian,
    tags: const ['vitamin_c', 'fibre', 't1', 't2', 't3', 'constipation', 'jain'],
    defaultServings: 2,
    ingredients: [
      _i('Apple, guava, banana, pomegranate, whatever is in season', 200, 'g'),
      _i('Roasted cumin powder', 0.25, 'tsp'),
      _i('Black salt', 0.25, 'tsp'),
      _i('Lemon', 0.25, 'pcs'),
    ],
    steps: [
      _en('Wash the fruit well and cut it into bite-sized pieces.'),
      _en('Toss with cumin, black salt and a squeeze of lemon.'),
      _en('Eat straight away; cut fruit that sits out is the one to avoid.'),
    ],
    nutritionGlance: const ['Vitamin C', 'Fibre 5g', 'Seasonal'],
    videoTitle: 'Cook along: fruit chaat',
  ),
  Recipe(
    id: 'peanut_jaggery_chikki',
    minutes: 25,
    fact: "Jaggery keeps the iron that refined sugar loses. A square of chikki has about a milligram.",
    meals: const [RecipeMeal.snack],
    kind: RecipeKind.sweet,
    name: _en('Peanut and jaggery chikki'),
    whyNow: _en('Two ingredients: peanuts for protein, jaggery for iron. A '
        'square of this is the sweet that does some work.'),
    region: RecipeRegion.maharashtrian,
    tags: const ['iron', 'protein', 't2', 't3', 'jain'],
    defaultServings: 4,
    ingredients: [
      _i('Peanuts, roasted and skinned', 40, 'g'),
      _i('Jaggery, grated', 30, 'g'),
      _i('Ghee', 0.25, 'tsp'),
    ],
    steps: [
      _en('Melt the jaggery in a pan on low with the ghee until it bubbles and a drop in water turns brittle.'),
      _en('Stir in the peanuts quickly and turn out onto a greased plate.'),
      _en('Flatten with a rolling pin, cut into squares while warm, and cool.'),
    ],
    nutritionGlance: const ['Iron 1.5mg', 'Protein 6g', 'One square is a serving'],
    videoTitle: 'Cook along: peanut chikki',
  ),

  // ===========================================================================
  //  SWEETS
  // ===========================================================================
  Recipe(
    id: 'dates_nuts_laddoo',
    minutes: 20,
    fact: "Dates are the sweetener here: no sugar at all, and iron and fibre in every laddoo.",
    meals: const [RecipeMeal.snack],
    kind: RecipeKind.sweet,
    name: _en('Dates and nuts laddoo'),
    whyNow: _en('No sugar at all. Dates hold it together, and every laddoo '
        'is iron, fibre and the good fat from the nuts.'),
    region: RecipeRegion.panIndian,
    tags: const ['iron', 'fibre', 'protein', 't2', 't3', 'constipation', 'jain', 'gestational_diabetes'],
    defaultServings: 6,
    ingredients: [
      _i('Dates, pitted', 4, 'pcs'),
      _i('Almonds, cashews, walnuts, mixed', 15, 'g'),
      _i('Desiccated coconut', 1, 'tsp'),
      _i('Cardamom, ground', 0.1, 'tsp'),
      _i('Ghee', 0.25, 'tsp'),
    ],
    steps: [
      _en('Dry-roast the nuts until they smell toasted, then chop them coarsely.'),
      _en('Warm the dates in the ghee for a minute until soft, and mash into a paste.'),
      _en('Mix in the nuts, coconut and cardamom; roll into small balls while warm.'),
    ],
    nutritionGlance: const ['Iron 1mg', 'Fibre 3g', 'No added sugar'],
    videoTitle: 'Cook along: dates laddoo',
  ),
  Recipe(
    id: 'jaggery_kheer',
    minutes: 40,
    fact: "Milk is the calcium in kheer; jaggery instead of sugar adds a little iron and a deeper taste.",
    meals: const [RecipeMeal.dinner, RecipeMeal.snack],
    kind: RecipeKind.sweet,
    name: _en('Rice kheer with jaggery'),
    whyNow: _en('The festival sweet, made with jaggery instead of sugar: '
        'calcium from the milk and a little iron from the jaggery.'),
    region: RecipeRegion.panIndian,
    tags: const ['calcium', 'iron', 't2', 't3', 'jain'],
    defaultServings: 3,
    ingredients: [
      _i('Rice, soaked', 20, 'g'),
      _i('Milk', 1, 'cup'),
      _i('Jaggery, grated', 15, 'g'),
      _i('Cardamom and a few raisins', 0.25, 'tsp'),
      _i('Almonds, sliced', 3, 'pcs'),
    ],
    steps: [
      _en('Bring the milk to a boil, add the rice and simmer on low, stirring, until the rice is soft and the milk thick.'),
      _en('Take it off the heat and let it cool a minute before stirring in the jaggery, so the milk does not split.'),
      _en('Add cardamom, raisins and almonds. Warm or cold, both are right.'),
    ],
    nutritionGlance: const ['Calcium 250mg', 'Iron', 'Jaggery, not sugar'],
    videoTitle: 'Cook along: jaggery kheer',
  ),
  Recipe(
    id: 'ragi_halwa',
    minutes: 25,
    fact: "Ragi has more calcium than any other grain, so a halwa of it is a sweet that does you some good.",
    meals: const [RecipeMeal.snack],
    kind: RecipeKind.sweet,
    name: _en('Ragi halwa'),
    whyNow: _en('Ragi is the calcium grain; as a halwa with jaggery it is a '
        'sweet you can hand to your mother-in-law without a lecture.'),
    region: RecipeRegion.tamil,
    tags: const ['calcium', 'iron', 't2', 't3', 'jain'],
    defaultServings: 3,
    ingredients: [
      _i('Ragi flour', 30, 'g'),
      _i('Jaggery, grated', 20, 'g'),
      _i('Ghee', 1, 'tsp'),
      _i('Water', 0.75, 'cup'),
      _i('Cardamom and cashews', 0.25, 'tsp'),
    ],
    steps: [
      _en('Dissolve the jaggery in the water and strain it.'),
      _en('Roast the ragi flour in ghee on low until it smells nutty, four to five minutes.'),
      _en('Pour in the jaggery water, stirring fast, and cook until it leaves the sides of the pan.'),
      _en('Finish with cardamom and cashews.'),
    ],
    nutritionGlance: const ['Calcium 100mg', 'Iron 1mg', 'Whole millet'],
    videoTitle: 'Cook along: ragi halwa',
  ),

  // ===========================================================================
  //  DRINKS
  // ===========================================================================
  Recipe(
    id: 'ginger_lemon_tea',
    minutes: 10,
    fact: "A gram of ginger a day is the amount studies used for morning sickness: about three thin slices.",
    meals: const [RecipeMeal.breakfast, RecipeMeal.snack],
    kind: RecipeKind.drink,
    name: _en('Ginger and lemon warm water'),
    whyNow: _en('The morning-sickness cup: a little ginger settles the '
        'stomach, and it is warm water, so it is fine as often as you like.'),
    region: RecipeRegion.panIndian,
    tags: const ['t1', 'nausea', 'immunity', 'jain'],
    defaultServings: 1,
    ingredients: [
      _i('Water', 1, 'cup'),
      _i('Ginger, thinly sliced', 3, 'pcs'),
      _i('Lemon', 0.25, 'pcs'),
      _i('Honey (optional)', 0.5, 'tsp'),
    ],
    steps: [
      _en('Simmer the ginger in the water for four minutes.'),
      _en('Strain into a cup, squeeze in the lemon, and sweeten with honey if you want.'),
      _en('Sip slowly before you get out of bed on a queasy morning.'),
    ],
    nutritionGlance: const ['Ginger, a small amount', 'Vitamin C', 'Caffeine-free'],
    videoTitle: 'Cook along: ginger lemon water',
  ),
  Recipe(
    id: 'haldi_doodh',
    minutes: 10,
    fact: "The pinch of turmeric in haldi doodh is the everyday amount; the milk is the calcium.",
    meals: const [RecipeMeal.dinner],
    kind: RecipeKind.drink,
    name: _en('Haldi doodh'),
    whyNow: _en('Warm milk at night is calcium and an easier sleep; the '
        'pinch of turmeric is the everyday amount, not a supplement.'),
    region: RecipeRegion.panIndian,
    tags: const ['calcium', 'immunity', 't2', 't3', 'jain'],
    defaultServings: 1,
    ingredients: [
      _i('Milk', 1, 'cup'),
      _i('Turmeric', 0.25, 'tsp'),
      _i('Black pepper, a pinch', 0.05, 'tsp'),
      _i('Jaggery or honey (optional)', 0.5, 'tsp'),
    ],
    steps: [
      _en('Warm the milk with the turmeric and pepper, stirring, until just below a boil.'),
      _en('Sweeten a little if you like and drink it warm, an hour before bed.'),
    ],
    nutritionGlance: const ['Calcium 300mg', 'Protein 8g', 'Kitchen turmeric only'],
    videoTitle: 'Cook along: haldi doodh',
  ),
  Recipe(
    id: 'salted_buttermilk',
    minutes: 10,
    fact: "Chaas is curd thinned with water: half the calories of lassi, the same probiotics.",
    meals: const [RecipeMeal.lunch, RecipeMeal.snack],
    kind: RecipeKind.drink,
    name: _en('Salted buttermilk (chaas)'),
    whyNow: _en('After lunch it cools heartburn and puts back the water and '
        'salt of a hot afternoon; the curd is calcium and probiotics.'),
    region: RecipeRegion.gujarati,
    tags: const ['calcium', 'heartburn', 't3', 'digestion', 'jain'],
    defaultServings: 1,
    ingredients: [
      _i('Curd', 0.5, 'cup'),
      _i('Cold water', 1, 'cup'),
      _i('Roasted cumin powder', 0.25, 'tsp'),
      _i('Rock salt and mint leaves', 0.25, 'tsp'),
    ],
    steps: [
      _en('Whisk the curd smooth, then whisk in the water.'),
      _en('Season with cumin, salt and torn mint; serve cold.'),
    ],
    nutritionGlance: const ['Calcium 150mg', 'Probiotic', 'Cooling'],
    videoTitle: 'Cook along: chaas',
  ),
  Recipe(
    id: 'badam_milk',
    minutes: 15,
    fact: "Eight almonds and a cup of milk together give about a third of a day's calcium.",
    meals: const [RecipeMeal.breakfast, RecipeMeal.snack],
    kind: RecipeKind.drink,
    name: _en('Badam milk'),
    whyNow: _en('Almonds blended into milk: calcium, protein and the good fat '
        'in one glass, for the days when eating feels like a task.'),
    region: RecipeRegion.panIndian,
    tags: const ['calcium', 'protein', 't1', 'nausea', 'weight_gain', 'jain'],
    defaultServings: 1,
    ingredients: [
      _i('Almonds, soaked overnight and peeled', 8, 'pcs'),
      _i('Milk', 1, 'cup'),
      _i('Cardamom and a strand of saffron', 0.1, 'tsp'),
      _i('Jaggery or dates (optional)', 1, 'tsp'),
    ],
    steps: [
      _en('Blend the almonds with a little of the milk into a smooth paste.'),
      _en('Warm the rest of the milk with the paste, cardamom and saffron, stirring, for three minutes.'),
      _en('Sweeten if you like; drink warm or chilled.'),
    ],
    nutritionGlance: const ['Calcium 320mg', 'Protein 10g', 'Vitamin E'],
    videoTitle: 'Cook along: badam milk',
  ),
  Recipe(
    id: 'coconut_water_cooler',
    minutes: 10,
    fact: "Coconut water has more potassium than a banana and almost no sugar.",
    meals: const [RecipeMeal.snack],
    kind: RecipeKind.drink,
    name: _en('Coconut water and mint cooler'),
    whyNow: _en('Coconut water is the electrolytes a hot day and a queasy '
        'stomach both need, with none of the sugar a packet drink brings.'),
    region: RecipeRegion.southIndian,
    tags: const ['t1', 'nausea', 'heartburn', 't3', 'jain'],
    defaultServings: 1,
    ingredients: [
      _i('Fresh coconut water', 1, 'cup'),
      _i('Mint leaves', 4, 'pcs'),
      _i('Lemon', 0.25, 'pcs'),
      _i('Black salt, a pinch', 0.05, 'tsp'),
    ],
    steps: [
      _en('Crush the mint lightly in a glass.'),
      _en('Pour over the coconut water, add lemon and a pinch of black salt, and stir.'),
    ],
    nutritionGlance: const ['Potassium', 'Electrolytes', 'No added sugar'],
    videoTitle: 'Cook along: coconut cooler',
  ),

  // ===========================================================================
  //  SOUPS
  // ===========================================================================
  Recipe(
    id: 'moong_dal_soup',
    minutes: 25,
    fact: "Moong is the easiest dal to digest, the one dieticians reach for on a queasy day.",
    meals: const [RecipeMeal.dinner, RecipeMeal.lunch],
    kind: RecipeKind.soup,
    name: _en('Moong dal soup'),
    whyNow: _en('The lightest dal, thinned into a soup: protein that goes '
        'down on a day when nothing else will.'),
    region: RecipeRegion.panIndian,
    tags: const ['protein', 't1', 'nausea', 'digestion', 'jain'],
    defaultServings: 2,
    ingredients: [
      _i('Yellow moong dal, rinsed', 40, 'g'),
      _i('Turmeric', 0.25, 'tsp'),
      _i('Ginger, grated', 0.5, 'tsp'),
      _i('Cumin seeds and ghee', 1, 'tsp'),
      _i('Water', 2, 'cup'),
      _i('Lemon and coriander', 0.25, 'pcs'),
    ],
    steps: [
      _en('Pressure-cook the dal with turmeric and water until completely soft; whisk smooth.'),
      _en('Temper cumin and ginger in ghee and pour into the dal; season with salt.'),
      _en('Thin with hot water to a soup, and finish with lemon and coriander.'),
    ],
    nutritionGlance: const ['Protein 8g', 'Folate', 'Easy to digest'],
    videoTitle: 'Cook along: moong dal soup',
  ),
  Recipe(
    id: 'tomato_carrot_soup',
    minutes: 30,
    fact: "Cooking tomatoes raises their lycopene; the carrot adds vitamin A.",
    meals: const [RecipeMeal.dinner, RecipeMeal.snack],
    kind: RecipeKind.soup,
    name: _en('Tomato and carrot soup'),
    whyNow: _en('Vitamin C from the tomato, vitamin A from the carrot, and a '
        'warm bowl at six that stops the evening snack from being biscuits.'),
    region: RecipeRegion.panIndian,
    tags: const ['vitamin_c', 'fibre', 't2', 't3', 'immunity', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Tomatoes, chopped', 2, 'pcs'),
      _i('Carrot, chopped', 1, 'pcs'),
      _i('Onion and garlic, chopped', 0.5, 'pcs'),
      _i('Black pepper', 0.25, 'tsp'),
      _i('Butter or ghee', 1, 'tsp'),
      _i('Water', 1.5, 'cup'),
    ],
    steps: [
      _en('Soften the onion and garlic in the butter, then add the carrot and tomatoes.'),
      _en('Add the water and simmer until the carrot is soft, about twelve minutes.'),
      _en('Blend smooth, return to the pan, season with salt and pepper, and warm through.'),
    ],
    nutritionGlance: const ['Vitamin C', 'Vitamin A', 'Fibre 4g'],
    videoTitle: 'Cook along: tomato carrot soup',
  ),
  Recipe(
    id: 'chicken_clear_soup',
    minutes: 35,
    fact: "A clear broth is protein and salt in a form an unwell evening can take.",
    meals: const [RecipeMeal.dinner],
    kind: RecipeKind.soup,
    name: _en('Chicken clear soup'),
    whyNow: _en('A clear chicken broth is protein and salt in a form a tired '
        'or unwell evening can manage, with the chicken cooked right through.'),
    region: RecipeRegion.panIndian,
    tags: const ['non_veg', 'meat', 'protein', 't2', 't3', 'immunity', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Chicken, boneless, diced', 80, 'g'),
      _i('Garlic and ginger, crushed', 1, 'tsp'),
      _i('Carrot and beans, chopped', 40, 'g'),
      _i('Spring onion', 1, 'tbsp'),
      _i('Black pepper', 0.25, 'tsp'),
      _i('Water', 2, 'cup'),
    ],
    steps: [
      _en('Simmer the chicken in the water with garlic and ginger for fifteen minutes, skimming the top.'),
      _en('Add the vegetables and cook until tender and the chicken is white all the way through.'),
      _en('Season with salt and pepper; finish with spring onion.'),
    ],
    nutritionGlance: const ['Protein 14g', 'Light', 'Chicken cooked through'],
    videoTitle: 'Cook along: chicken clear soup',
  ),

  // ===========================================================================
  //  NON-VEGETARIAN MAINS
  // ===========================================================================
  Recipe(
    id: 'home_chicken_curry',
    minutes: 45,
    fact: "Chicken's iron is the haem kind. Your body absorbs two to three times more of it than from dal.",
    meals: const [RecipeMeal.lunch, RecipeMeal.dinner],
    kind: RecipeKind.main,
    name: _en('Home-style chicken curry'),
    whyNow: _en('Chicken is iron you absorb easily and complete protein; '
        'a home curry keeps the oil sensible and the meat fully cooked.'),
    region: RecipeRegion.punjabi,
    tags: const ['non_veg', 'meat', 'protein', 'iron', 't2', 't3', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Chicken, on the bone', 200, 'g'),
      _i('Onion, sliced', 1, 'pcs'),
      _i('Tomato, chopped', 1, 'pcs'),
      _i('Ginger-garlic paste', 1, 'tsp'),
      _i('Turmeric, coriander, cumin, chilli powder', 1, 'tsp'),
      _i('Curd', 2, 'tbsp'),
      _i('Oil', 2, 'tsp'),
    ],
    steps: [
      _en('Brown the onion in the oil, then cook the ginger-garlic paste and spices for a minute.'),
      _en('Add the tomato and cook until the oil separates; stir in the curd.'),
      _en('Add the chicken and salt; cover and simmer twenty-five minutes until the meat leaves the bone.'),
      _en('Check the thickest piece is white all through, with no pink. Serve with roti or rice.'),
    ],
    nutritionGlance: const ['Protein 24g', 'Iron 1.5mg', 'Cooked through'],
    videoTitle: 'Cook along: chicken curry',
  ),
  Recipe(
    id: 'egg_curry',
    minutes: 30,
    fact: "Hard-boiling is exactly right in pregnancy: the yolk set, the protein complete.",
    meals: const [RecipeMeal.lunch, RecipeMeal.dinner],
    kind: RecipeKind.main,
    name: _en('Egg curry'),
    whyNow: _en('Hard-boiled eggs in a tomato gravy: the cheapest complete '
        'protein there is, and hard-boiled is exactly right for now.'),
    region: RecipeRegion.panIndian,
    tags: const ['egg', 'protein', 'iron', 't2', 't3', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Eggs, hard-boiled and peeled', 2, 'pcs'),
      _i('Onion, chopped', 1, 'pcs'),
      _i('Tomato, pureed', 1, 'pcs'),
      _i('Ginger-garlic paste', 1, 'tsp'),
      _i('Turmeric, coriander, garam masala', 1, 'tsp'),
      _i('Oil', 2, 'tsp'),
    ],
    steps: [
      _en('Cook the onion in the oil until golden; add the ginger-garlic paste and spices.'),
      _en('Add the tomato and a splash of water; simmer until the gravy thickens.'),
      _en('Halve the eggs, slip them into the gravy, and simmer three minutes. Serve with rice.'),
    ],
    nutritionGlance: const ['Protein 14g', 'Choline', 'Eggs hard-boiled'],
    videoTitle: 'Cook along: egg curry',
  ),
  Recipe(
    id: 'pan_fried_pomfret',
    minutes: 25,
    fact: "Pomfret is one of the low-mercury sea fish, so it is the omega-3 without the worry.",
    meals: const [RecipeMeal.lunch, RecipeMeal.dinner],
    kind: RecipeKind.main,
    name: _en('Pan-fried pomfret'),
    whyNow: _en('Pomfret is a low-mercury fish, so it gives your baby\'s brain '
        'omega-3 without the mercury. Shallow-fried, not deep.'),
    region: RecipeRegion.maharashtrian,
    tags: const ['non_veg', 'fish', 'protein', 'omega3', 't2', 't3', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Pomfret, cleaned, in pieces', 200, 'g'),
      _i('Turmeric and chilli powder', 0.5, 'tsp'),
      _i('Ginger-garlic paste', 1, 'tsp'),
      _i('Lemon', 0.5, 'pcs'),
      _i('Rice flour or semolina for coating', 2, 'tbsp'),
      _i('Oil', 2, 'tsp'),
    ],
    steps: [
      _en('Rub the fish with turmeric, chilli, ginger-garlic, lemon and salt; rest fifteen minutes.'),
      _en('Coat lightly in rice flour.'),
      _en('Shallow-fry on a medium tawa four minutes a side until the flesh flakes white right through.'),
    ],
    nutritionGlance: const ['Protein 20g', 'Omega-3', 'Low-mercury fish'],
    videoTitle: 'Cook along: pan-fried pomfret',
  ),
  Recipe(
    id: 'dal_palak',
    minutes: 30,
    fact: "The tomato in dal palak isn't only for taste. Its vitamin C helps the spinach's iron go in.",
    meals: const [RecipeMeal.lunch, RecipeMeal.dinner],
    kind: RecipeKind.main,
    name: _en('Dal palak'),
    whyNow: _en('Dal and spinach in one pot: protein and folate together, '
        'and the tomato in it helps the iron go in.'),
    region: RecipeRegion.panIndian,
    tags: const ['protein', 'iron', 'folic_acid', 't1', 't2', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Toor or moong dal', 50, 'g'),
      _i('Spinach, chopped', 80, 'g'),
      _i('Tomato, chopped', 1, 'pcs'),
      _i('Garlic, sliced', 2, 'pcs'),
      _i('Cumin seeds and turmeric', 0.5, 'tsp'),
      _i('Ghee', 1, 'tsp'),
    ],
    steps: [
      _en('Pressure-cook the dal with turmeric until soft.'),
      _en('Cook the spinach and tomato into the dal for five minutes.'),
      _en('Temper cumin and garlic in ghee and pour over; season and serve with roti or rice.'),
    ],
    nutritionGlance: const ['Protein 10g', 'Folate', 'Iron 3mg'],
    videoTitle: 'Cook along: dal palak',
  ),

  // ===========================================================================
  //  2026-09-29, the pregnancy warmth pass: four the gap analysis asked for
  //  (Appendix A, Nutrition > Recipes). Our own Indian versions: a raita
  //  (Tzatziki), a kaddu soup (the two squash soups), a banana, curd and
  //  dates smoothie (Banana-Berry Smoothie, Just Peachy Shake), and a
  //  kachumber with pomegranate that shows how to eat raw salad safely.
  // ===========================================================================
  Recipe(
    id: 'cucumber_raita',
    minutes: 10,
    fact: "A bowl of curd has about as much calcium as half a glass of milk, and the cucumber makes it cooling.",
    meals: const [RecipeMeal.lunch, RecipeMeal.dinner, RecipeMeal.snack],
    kind: RecipeKind.light,
    name: _en('Cucumber raita'),
    whyNow: _en('Cool curd with cucumber adds calcium to any meal, and it '
        'soothes a stomach that has had enough spice.'),
    region: RecipeRegion.panIndian,
    tags: const ['calcium', 't1', 't2', 't3'],
    defaultServings: 2,
    ingredients: [
      _i('Curd', 0.5, 'cup'),
      _i('Cucumber, peeled and grated', 60, 'g'),
      _i('Roasted cumin powder', 0.25, 'tsp'),
      _i('Mint leaves, chopped', 1, 'tsp'),
      _i('Black salt', 0.25, 'tsp'),
    ],
    steps: [
      _en('Wash the cucumber well in clean water, peel it and grate it.'),
      _en('Squeeze out a little of the water so the raita stays thick.'),
      _en('Whisk the curd smooth, then stir in the cucumber, cumin, mint and black salt.'),
      _en('Eat it fresh, the same day. Keep any left over in the fridge.'),
    ],
    nutritionGlance: const ['Calcium good', 'Cooling', 'Calories 70'],
    videoTitle: 'Cook along: cucumber raita',
  ),
  Recipe(
    id: 'kaddu_soup',
    minutes: 25,
    fact: "Orange pumpkin is rich in beta-carotene, which your body turns into vitamin A.",
    meals: const [RecipeMeal.dinner, RecipeMeal.snack],
    kind: RecipeKind.soup,
    name: _en('Kaddu (pumpkin) soup'),
    whyNow: _en('Smooth, mild and gentle on the stomach, with fibre and '
        'vitamin A. Easy on an evening when heavy food feels like too much.'),
    region: RecipeRegion.panIndian,
    tags: const ['fibre', 't1', 't2', 't3', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Pumpkin (kaddu), peeled and cubed', 150, 'g'),
      _i('Onion, chopped', 0.5, 'pcs'),
      _i('Ginger, grated', 0.5, 'tsp'),
      _i('Cumin seeds', 0.25, 'tsp'),
      _i('Ghee', 1, 'tsp'),
      _i('Water', 1, 'cup'),
      _i('Milk', 0.25, 'cup'),
    ],
    steps: [
      _en('Heat the ghee, add the cumin, then soften the onion and ginger.'),
      _en('Add the pumpkin, water and a little salt, and simmer until the pumpkin is soft, about fifteen minutes.'),
      _en('Blend until smooth, return to the pan and stir in the milk.'),
      _en('Warm through without boiling, and add black pepper if you like.'),
    ],
    nutritionGlance: const ['Vitamin A', 'Fibre 3g', 'Calories 110'],
    videoTitle: 'Cook along: kaddu soup',
  ),
  Recipe(
    id: 'banana_dates_smoothie',
    minutes: 10,
    fact: "Banana and dates sweeten a smoothie on their own, and the dates add a little iron.",
    meals: const [RecipeMeal.breakfast, RecipeMeal.snack],
    kind: RecipeKind.drink,
    name: _en('Banana, curd and dates smoothie'),
    whyNow: _en('Easy to sip on a morning when chewing feels like too much. '
        'Calcium from the curd and milk, and a little iron from the dates.'),
    region: RecipeRegion.panIndian,
    tags: const ['calcium', 'iron', 't1', 't2', 'nausea'],
    defaultServings: 1,
    ingredients: [
      _i('Banana', 1, 'pcs'),
      _i('Curd', 0.5, 'cup'),
      _i('Milk', 0.5, 'cup'),
      _i('Dates, pitted', 2, 'pcs'),
      _i('Cardamom, ground', 0.25, 'tsp'),
    ],
    steps: [
      _en('Soak the dates in the milk for ten minutes so they soften.'),
      _en('Blend the banana, curd, milk, dates and cardamom until smooth.'),
      _en('Drink it fresh and cool. Sip slowly if you feel sick.'),
      // Appendix A (What to Expect, "Just Peachy Breakfast Shake").
      _en('For a change, use a ripe chikoo or mango instead of the banana.'),
    ],
    nutritionGlance: const ['Calcium good', 'Iron present', 'Calories 280'],
    videoTitle: 'Cook along: banana dates smoothie',
  ),
  Recipe(
    id: 'kachumber_pomegranate',
    minutes: 15,
    fact: "The lemon on a kachumber adds vitamin C, which helps you absorb iron from the dal on the same plate.",
    meals: const [RecipeMeal.lunch, RecipeMeal.dinner, RecipeMeal.snack],
    kind: RecipeKind.light,
    name: _en('Kachumber with pomegranate'),
    whyNow: _en('A fresh, crunchy salad with vitamin C to help the iron in '
        'your meal go in. Washed well and eaten fresh, raw salad is fine.'),
    region: RecipeRegion.panIndian,
    tags: const ['vitamin_c', 'fibre', 'iron', 't2', 't3', 'onion_garlic'],
    defaultServings: 2,
    ingredients: [
      _i('Cucumber, peeled and chopped', 60, 'g'),
      _i('Tomato, chopped', 0.5, 'pcs'),
      _i('Onion, chopped', 0.5, 'pcs'),
      _i('Pomegranate seeds', 30, 'g'),
      _i('Lemon', 0.25, 'pcs'),
      _i('Roasted cumin powder', 0.25, 'tsp'),
    ],
    steps: [
      _en('Wash the cucumber, tomato and onion well under clean running water, and wash your hands and knife too.'),
      _en('Peel the cucumber, then chop everything small on a clean board.'),
      _en('Toss with the pomegranate seeds, cumin, a pinch of salt and the lemon juice.'),
      _en("Eat it within the hour. Don't keep cut salad standing, and skip salads from outside."),
    ],
    nutritionGlance: const ['Vitamin C', 'Fibre 3g', 'Calories 60'],
    videoTitle: 'Cook along: kachumber',
  ),
];
