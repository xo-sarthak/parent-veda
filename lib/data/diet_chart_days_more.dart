// =============================================================================
//  Diet charts — days four to seven
// -----------------------------------------------------------------------------
//  2026-09-21. The charts shipped with three worked days each, on the
//  reasoning that three days is a pattern and the Swaps list turns it into a
//  month. Then the chart became the plate (`plateFor` rotates through a
//  chart's days by date) and the user asked, on the phone, why only three:
//  "if it's a week, it should be a week." A dietician hands over seven days;
//  a mother with three sees the same breakfast every third morning.
//
//  Every English chart gets days four to seven here — the five main ones
//  first (Full month, First trimester, Vegetarian, Non-vegetarian,
//  Gestational diabetes), then the stage, condition and regional charts —
//  and `kChartContent` splices them in (`diet_chart_content.dart`). The
//  Hindi chart keeps its three: new Hindi is written only when asked.
//
//  The rules that held for days one to three hold here: named dishes a
//  mother already cooks; the chart's focus in every day (a queasy-stomach
//  chart stays bland and frequent, the GDM chart pairs every carb with
//  protein and keeps fruit whole); nothing forbidden, some things "well
//  cooked"; and every dish word is one the food-values table knows, so the
//  plate can put a number under it (`test/food_values_test.dart` fails a
//  line it cannot estimate).
// =============================================================================

import '../localization/app_language.dart';
import 'diet_chart_content.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);
ChartMeal _m(String slot, String items) => ChartMeal(_en(slot), _en(items));
ChartDay _d(String label, List<ChartMeal> meals) => ChartDay(label: _en(label), meals: meals);

final Map<String, List<ChartDay>> kChartDaysMore = {
  // ---------------------------------------------------------------------------
  //  Full month-by-month Indian chart — the all-rounder
  // ---------------------------------------------------------------------------
  'full_month_indian': [
    _d('Day 4', [
      _m('Breakfast', 'Vegetable upma, a glass of milk'),
      _m('Mid-morning', 'A guava, a handful of roasted chana'),
      _m('Lunch', 'Rajma with rice, cucumber salad, curd'),
      _m('Evening', 'Sprouts chaat, buttermilk'),
      _m('Dinner', 'Two rotis with bhindi sabzi, moong dal'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Idli with sambar'),
      _m('Mid-morning', 'A banana, a few almonds'),
      _m('Lunch', 'Dal palak with two rotis, salad'),
      _m('Evening', 'Roasted makhana, lemon water'),
      _m('Dinner', 'Vegetable pulao with raita'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Besan chilla with curd'),
      _m('Mid-morning', 'Pomegranate, a glass of buttermilk'),
      _m('Lunch', 'Chole with rice, a green sabzi'),
      _m('Evening', 'Fruit chaat'),
      _m('Dinner', 'Paneer bhurji with two rotis, dal'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Oats porridge with dates and almonds'),
      _m('Mid-morning', 'An orange, a handful of peanuts'),
      _m('Lunch', 'Sambar with rice, beetroot sabzi, curd'),
      _m('Evening', 'Dhokla, ginger tea'),
      _m('Dinner', 'Khichdi with vegetables, a bowl of kheer'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  First trimester — small, bland, frequent
  // ---------------------------------------------------------------------------
  't1_chart': [
    _d('Day 4', [
      _m('On waking', 'A few salted crackers before you sit up'),
      _m('Breakfast', 'Plain poha, small portion'),
      _m('Mid-morning', 'Coconut water'),
      _m('Lunch', 'Curd rice with a little pickle'),
      _m('Evening', 'A banana, ginger tea'),
      _m('Dinner', 'Moong dal soup with one roti'),
    ]),
    _d('Day 5', [
      _m('On waking', 'Dry toast'),
      _m('Breakfast', 'Idli, plain, with a little ghee'),
      _m('Mid-morning', 'Buttermilk with jeera'),
      _m('Lunch', 'Soft khichdi with curd'),
      _m('Evening', 'An apple, sliced, roasted makhana'),
      _m('Dinner', 'Dal with rice, lauki sabzi'),
    ]),
    _d('Day 6', [
      _m('On waking', 'A handful of roasted chana'),
      _m('Breakfast', 'Vegetable dalia, small portion'),
      _m('Mid-morning', 'Lemon water with a pinch of salt, a pear'),
      _m('Lunch', 'Curd rice, steamed vegetables'),
      _m('Evening', 'Plain biscuits, ginger tea'),
      _m('Dinner', 'Moong dal with one roti, plain sabzi'),
    ]),
    _d('Day 7', [
      _m('On waking', 'Dry cornflakes'),
      _m('Breakfast', 'Upma, small portion'),
      _m('Mid-morning', 'Milk if you can take it, otherwise a banana'),
      _m('Lunch', 'Khichdi with a spoon of ghee, curd'),
      _m('Evening', 'Sweet lime, a few crackers'),
      _m('Dinner', 'Dal with rice, tori sabzi'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Vegetarian — protein and iron without meat
  // ---------------------------------------------------------------------------
  'vegetarian_chart': [
    _d('Day 4', [
      _m('Breakfast', 'Moong dal chilla with curd'),
      _m('Mid-morning', 'A guava, a handful of peanuts'),
      _m('Lunch', 'Rajma with rice, salad, curd'),
      _m('Evening', 'Sprouts chaat, buttermilk'),
      _m('Dinner', 'Palak paneer with two rotis'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Ragi dosa with sambar'),
      _m('Mid-morning', 'Pomegranate, a glass of milk'),
      _m('Lunch', 'Chole with rice, a green sabzi'),
      _m('Evening', 'Roasted makhana, lemon water'),
      _m('Dinner', 'Dal palak with two rotis, curd'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Oats porridge with dates and almonds'),
      _m('Mid-morning', 'An orange, roasted chana'),
      _m('Lunch', 'Sambar with rice, beetroot sabzi'),
      _m('Evening', 'Dhokla, ginger tea'),
      _m('Dinner', 'Paneer bhurji with two rotis, moong dal'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Vegetable poha with peanuts, a glass of milk'),
      _m('Mid-morning', 'A banana, a few walnuts'),
      _m('Lunch', 'Kadhi with rice, bhindi sabzi'),
      _m('Evening', 'Fruit chaat, badam milk'),
      _m('Dinner', 'Khichdi with vegetables, a bowl of kheer'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Non-vegetarian — two to four non-veg meals a week, never every meal
  // ---------------------------------------------------------------------------
  'non_vegetarian_chart': [
    _d('Day 4', [
      _m('Breakfast', 'Egg bhurji with two rotis'),
      _m('Mid-morning', 'A guava, buttermilk'),
      _m('Lunch', 'Dal with rice, bhindi sabzi, salad'),
      _m('Evening', 'Roasted makhana, lemon water'),
      _m('Dinner', 'Chicken curry with two rotis, cucumber salad'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Vegetable upma, a glass of milk'),
      _m('Mid-morning', 'A banana, a few almonds'),
      _m('Lunch', 'Egg curry with rice, a green sabzi'),
      _m('Evening', 'Sprouts chaat'),
      _m('Dinner', 'Moong dal with two rotis, lauki sabzi, curd'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Idli with sambar'),
      _m('Mid-morning', 'Pomegranate, roasted chana'),
      _m('Lunch', 'Pan-fried pomfret with rice, dal, salad'),
      _m('Evening', 'Fruit chaat, ginger tea'),
      _m('Dinner', 'Rajma with two rotis, curd'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Oats porridge with dates and almonds'),
      _m('Mid-morning', 'An orange, a glass of milk'),
      _m('Lunch', 'Chicken clear soup, khichdi with vegetables'),
      _m('Evening', 'Dhokla, buttermilk'),
      _m('Dinner', 'Dal palak with two rotis, paneer bhurji'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Gestational diabetes — every carb with a protein, fruit whole, no juice
  // ---------------------------------------------------------------------------
  'gestational_diabetes_chart': [
    _d('Day 4', [
      _m('Breakfast', 'Moong dal chilla with curd'),
      _m('Mid-morning', 'A guava, a handful of peanuts'),
      _m('Lunch', 'Two rotis with rajma, a big salad, curd'),
      _m('Evening', 'Roasted makhana, buttermilk'),
      _m('Dinner', 'Paneer bhurji with one roti, moong dal soup'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Vegetable upma with peanuts, a boiled egg or curd'),
      _m('Mid-morning', 'An apple, a few almonds'),
      _m('Lunch', 'Brown rice with sambar, bhindi sabzi'),
      _m('Evening', 'Sprouts chaat'),
      _m('Dinner', 'Dal palak with one roti, cucumber salad'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Oats porridge with almonds, no dates'),
      _m('Mid-morning', 'Pomegranate, roasted chana'),
      _m('Lunch', 'Two rotis with chole, a green sabzi, curd'),
      _m('Evening', 'Dhokla, ginger tea'),
      _m('Dinner', 'Vegetable daliya with moong dal'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Ragi dosa with sambar'),
      _m('Mid-morning', 'A pear, a glass of milk'),
      _m('Lunch', 'Khichdi with vegetables, a bowl of curd, salad'),
      _m('Evening', 'Peanut and jaggery chikki, one square, buttermilk'),
      _m('Dinner', 'Egg bhurji or paneer bhurji with one roti, dal'),
    ]),
  ],
  // ---------------------------------------------------------------------------
  //  Second trimester — appetite back, protein and iron forward
  // ---------------------------------------------------------------------------
  't2_chart': [
    _d('Day 4', [
      _m('Breakfast', 'Paneer paratha with curd'),
      _m('Mid-morning', 'A guava, a handful of roasted chana'),
      _m('Lunch', 'Rajma with rice, salad, curd'),
      _m('Evening', 'Sprouts chaat, buttermilk'),
      _m('Dinner', 'Dal palak with two rotis'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Egg bhurji or besan chilla with two rotis'),
      _m('Mid-morning', 'Pomegranate, a glass of milk'),
      _m('Lunch', 'Chole with rice, a green sabzi'),
      _m('Evening', 'Roasted makhana, lemon water'),
      _m('Dinner', 'Palak paneer with two rotis, dal'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Ragi dosa with sambar'),
      _m('Mid-morning', 'An orange, a few almonds'),
      _m('Lunch', 'Fish curry or dal with rice, beetroot sabzi'),
      _m('Evening', 'Fruit chaat'),
      _m('Dinner', 'Rajma with two rotis, curd'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Oats porridge with dates and almonds'),
      _m('Mid-morning', 'A banana, roasted chana'),
      _m('Lunch', 'Sambar with rice, bhindi sabzi, curd'),
      _m('Evening', 'Dhokla, ginger tea'),
      _m('Dinner', 'Khichdi with vegetables, a bowl of kheer'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Third trimester — small and often, calcium and iron, heartburn in mind
  // ---------------------------------------------------------------------------
  't3_chart': [
    _d('Day 4', [
      _m('Breakfast', 'Vegetable upma, a glass of milk'),
      _m('Mid-morning', 'A guava, a few almonds'),
      _m('Lunch', 'Dal with rice, lauki sabzi, curd'),
      _m('Evening', 'Roasted makhana, coconut water'),
      _m('Dinner', 'Moong dal soup, one roti with paneer bhurji'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Idli with sambar'),
      _m('Mid-morning', 'A banana, buttermilk'),
      _m('Lunch', 'Two rotis with dal palak, cucumber salad'),
      _m('Evening', 'Fruit chaat'),
      _m('Dinner', 'Khichdi with curd, small portion'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Oats porridge with dates'),
      _m('Mid-morning', 'Pomegranate, roasted chana'),
      _m('Lunch', 'Curd rice, steamed vegetables'),
      _m('Evening', 'Dhokla, lemon water'),
      _m('Dinner', 'Dal with one roti, bhindi sabzi'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Besan chilla with curd'),
      _m('Mid-morning', 'A pear, a glass of milk'),
      _m('Lunch', 'Rajma with rice, small portion, salad'),
      _m('Evening', 'Salted buttermilk, a few crackers'),
      _m('Dinner', 'Vegetable daliya with moong dal, a bowl of kheer'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Healthy weight gain — ordinary food, portions and timing do the work
  // ---------------------------------------------------------------------------
  'weight_gain_chart': [
    _d('Day 4', [
      _m('Breakfast', 'Vegetable upma, a glass of milk'),
      _m('Mid-morning', 'A guava'),
      _m('Lunch', 'Two rotis with dal palak, a big salad, curd'),
      _m('Evening', 'Roasted makhana, buttermilk'),
      _m('Dinner', 'Moong dal soup with one roti, bhindi sabzi'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Idli with sambar'),
      _m('Mid-morning', 'An apple, a few almonds'),
      _m('Lunch', 'Brown rice with rajma, cucumber salad'),
      _m('Evening', 'Sprouts chaat'),
      _m('Dinner', 'Paneer bhurji with one roti, dal'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Oats porridge with almonds'),
      _m('Mid-morning', 'Pomegranate, roasted chana'),
      _m('Lunch', 'Two rotis with chole, a green sabzi'),
      _m('Evening', 'Fruit chaat, lemon water'),
      _m('Dinner', 'Vegetable daliya with curd'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Besan chilla with curd'),
      _m('Mid-morning', 'A pear, buttermilk'),
      _m('Lunch', 'Khichdi with vegetables, salad, curd'),
      _m('Evening', 'Dhokla, ginger tea'),
      _m('Dinner', 'Dal with one roti, lauki sabzi'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Bengali — rice at the centre, fish for protein, greens and dal
  // ---------------------------------------------------------------------------
  'regional_bengali': [
    _d('Day 4', [
      _m('Breakfast', 'Luchi is a treat, not a daily. Muri with milk and a banana'),
      _m('Mid-morning', 'A guava, roasted chana'),
      _m('Lunch', 'Rice with moong dal, shukto, a small piece of fish'),
      _m('Evening', 'Sprouts chaat, buttermilk'),
      _m('Dinner', 'Rice with dal, aloo posto, a green sabzi'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Vegetable khichuri, small portion'),
      _m('Mid-morning', 'Doi with gur'),
      _m('Lunch', 'Rice with macher jhol, a green sabzi'),
      _m('Evening', 'Fruit chaat'),
      _m('Dinner', 'Two rotis with dal, chorchori'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Chirer polao with a boiled egg or curd'),
      _m('Mid-morning', 'Pomegranate, a glass of milk'),
      _m('Lunch', 'Rice with dal, shukto, a bowl of curd'),
      _m('Evening', 'Roasted makhana, ginger tea'),
      _m('Dinner', 'Khichuri with a boiled egg or paneer'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Oats porridge with dates'),
      _m('Mid-morning', 'A banana, a few almonds'),
      _m('Lunch', 'Rice with macher jhol, spinach sabzi'),
      _m('Evening', 'Dhokla or muri, lemon water'),
      _m('Dinner', 'Rice with moong dal, a green sabzi, mishti doi'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Tamil — idli, dosa, sambar, rasam, curd rice; the fermented breakfasts do the work
  // ---------------------------------------------------------------------------
  'regional_tamil': [
    _d('Day 4', [
      _m('Breakfast', 'Pongal with sambar'),
      _m('Mid-morning', 'A guava, roasted chana'),
      _m('Lunch', 'Rice with sambar, beetroot poriyal, curd'),
      _m('Evening', 'Sundal, buttermilk'),
      _m('Dinner', 'Ragi dosa with chutney, a glass of milk'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Idli with sambar'),
      _m('Mid-morning', 'A banana, a few almonds'),
      _m('Lunch', 'Rice with rasam, dal, a green sabzi'),
      _m('Evening', 'Fruit chaat'),
      _m('Dinner', 'Curd rice, steamed vegetables'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Pesarattu with chutney'),
      _m('Mid-morning', 'Pomegranate, a glass of milk'),
      _m('Lunch', 'Rice with sambar, keerai, curd'),
      _m('Evening', 'Roasted makhana, ginger tea'),
      _m('Dinner', 'Adai with avial'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Ragi kanji with a banana'),
      _m('Mid-morning', 'An orange, roasted chana'),
      _m('Lunch', 'Rice with rasam, drumstick sambar, curd'),
      _m('Evening', 'Sundal, coconut water'),
      _m('Dinner', 'Idli with sambar, a bowl of kheer'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Punjabi — protein is already there; the chart keeps the ghee and cream in check
  // ---------------------------------------------------------------------------
  'regional_punjabi': [
    _d('Day 4', [
      _m('Breakfast', 'Paneer paratha with curd'),
      _m('Mid-morning', 'A guava, a glass of buttermilk'),
      _m('Lunch', 'Rajma with rice, salad'),
      _m('Evening', 'Roasted chana, lemon water'),
      _m('Dinner', 'Dal palak with two rotis, curd'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Besan chilla with curd'),
      _m('Mid-morning', 'A banana, a few almonds'),
      _m('Lunch', 'Chole with two rotis, a green sabzi, curd'),
      _m('Evening', 'Sprouts chaat'),
      _m('Dinner', 'Palak paneer with two rotis'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Vegetable daliya with milk'),
      _m('Mid-morning', 'Pomegranate, roasted chana'),
      _m('Lunch', 'Kadhi with rice, bhindi sabzi'),
      _m('Evening', 'Fruit chaat, buttermilk'),
      _m('Dinner', 'Moong dal with two rotis, lauki sabzi'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Oats porridge with dates and almonds'),
      _m('Mid-morning', 'An orange, a glass of milk'),
      _m('Lunch', 'Sarson saag with makki roti, curd'),
      _m('Evening', 'Roasted makhana, ginger tea'),
      _m('Dinner', 'Paneer bhurji with two rotis, dal, a bowl of kheer'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Gujarati — vegetarian, steamed more than fried; the sugar in everyday dishes kept light
  // ---------------------------------------------------------------------------
  'regional_gujarati': [
    _d('Day 4', [
      _m('Breakfast', 'Thepla with curd'),
      _m('Mid-morning', 'A guava, roasted chana'),
      _m('Lunch', 'Rotli with dal, a mixed shaak, salad'),
      _m('Evening', 'Dhokla, buttermilk'),
      _m('Dinner', 'Khichdi with kadhi'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Handvo, a small piece, with curd'),
      _m('Mid-morning', 'A banana, a few almonds'),
      _m('Lunch', 'Rotli with undhiyu, dal, curd'),
      _m('Evening', 'Sprouts chaat'),
      _m('Dinner', 'Moong dal with rotli, lauki shaak'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Vegetable upma, a glass of milk'),
      _m('Mid-morning', 'Pomegranate, roasted makhana'),
      _m('Lunch', 'Rotli with chole, a green shaak'),
      _m('Evening', 'Khandvi, ginger tea'),
      _m('Dinner', 'Khichdi with vegetables, curd'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Oats porridge with dates'),
      _m('Mid-morning', 'An orange, buttermilk'),
      _m('Lunch', 'Dal palak with rotli, salad, curd'),
      _m('Evening', 'Fruit chaat'),
      _m('Dinner', 'Kadhi with rice, bhindi shaak, a small bowl of shrikhand'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  South Indian, broadly — rice, coconut, sambar and plenty of vegetables
  // ---------------------------------------------------------------------------
  'regional_south_indian': [
    _d('Day 4', [
      _m('Breakfast', 'Puttu with kadala curry'),
      _m('Mid-morning', 'A guava, roasted chana'),
      _m('Lunch', 'Rice with sambar, thoran, curd'),
      _m('Evening', 'Sundal, buttermilk'),
      _m('Dinner', 'Ragi dosa with chutney, a glass of milk'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Idli with sambar'),
      _m('Mid-morning', 'A banana, a few almonds'),
      _m('Lunch', 'Bisi bele bath, cucumber salad'),
      _m('Evening', 'Fruit chaat'),
      _m('Dinner', 'Appam with vegetable stew'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Pesarattu with chutney'),
      _m('Mid-morning', 'Pomegranate, a glass of milk'),
      _m('Lunch', 'Rice with rasam, avial, curd'),
      _m('Evening', 'Roasted makhana, coconut water'),
      _m('Dinner', 'Ragi mudde with sambar'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Vegetable upma, a glass of milk'),
      _m('Mid-morning', 'An orange, roasted chana'),
      _m('Lunch', 'Rice with sambar, beetroot poriyal, curd'),
      _m('Evening', 'Sundal, ginger tea'),
      _m('Dinner', 'Idiyappam with vegetable stew, a bowl of kheer'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Jain — no onion, garlic or root vegetables; iron and B12 are the work
  // ---------------------------------------------------------------------------
  'regional_jain': [
    _d('Day 4', [
      _m('Breakfast', 'Moong dal chilla with curd'),
      _m('Mid-morning', 'A guava, a handful of peanuts'),
      _m('Lunch', 'Rajma with rice, cucumber salad, curd'),
      _m('Evening', 'Roasted makhana, buttermilk'),
      _m('Dinner', 'Kadhi khichdi with a green sabzi'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Vegetable upma, a glass of milk'),
      _m('Mid-morning', 'Pomegranate, roasted chana'),
      _m('Lunch', 'Two rotis with chole, lauki sabzi, curd'),
      _m('Evening', 'Dhokla, lemon water'),
      _m('Dinner', 'Dal palak with two rotis'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Thepla with curd'),
      _m('Mid-morning', 'A banana, a few almonds'),
      _m('Lunch', 'Moong dal with rice, bhindi sabzi, curd'),
      _m('Evening', 'Fruit chaat'),
      _m('Dinner', 'Paneer bhurji with two rotis, dal'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Oats porridge with dates and almonds'),
      _m('Mid-morning', 'An orange, a glass of milk'),
      _m('Lunch', 'Kadhi with rice, a green sabzi'),
      _m('Evening', 'Roasted makhana, ginger tea'),
      _m('Dinner', 'Khichdi with vegetables, a bowl of kheer'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Low iron — iron at every meal, something sour beside it, tea away from food
  // ---------------------------------------------------------------------------
  'anaemia_chart': [
    _d('Day 4', [
      _m('Breakfast', 'Vegetable poha with peanuts and lemon'),
      _m('Mid-morning', 'A guava, a handful of roasted chana'),
      _m('Lunch', 'Rajma with rice, tomato and cucumber salad'),
      _m('Evening', 'Sprouts chaat with lemon, buttermilk'),
      _m('Dinner', 'Dal palak with two rotis, a piece of jaggery'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Ragi dosa with sambar'),
      _m('Mid-morning', 'Pomegranate, a few dates'),
      _m('Lunch', 'Chole with rice, a green sabzi, an orange after'),
      _m('Evening', 'Roasted chana, lemon water'),
      _m('Dinner', 'Egg curry or paneer bhurji with two rotis, dal'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Oats porridge with dates'),
      _m('Mid-morning', 'An orange, a few almonds'),
      _m('Lunch', 'Chicken curry or dal with rice, spinach sabzi'),
      _m('Evening', 'Dates and nuts laddoo, buttermilk'),
      _m('Dinner', 'Moong dal with two rotis, beetroot sabzi'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Besan chilla with curd, a guava'),
      _m('Mid-morning', 'Sweet lime, roasted chana'),
      _m('Lunch', 'Sambar with rice, drumstick sabzi, curd'),
      _m('Evening', 'Peanut and jaggery chikki, lemon water'),
      _m('Dinner', 'Rajma with two rotis, tomato salad'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  After birth — recovery, milk supply, and eating at all
  // ---------------------------------------------------------------------------
  'postpartum_chart': [
    _d('Day 4', [
      _m('Early', 'Warm milk with a few almonds'),
      _m('Breakfast', 'Vegetable daliya'),
      _m('Mid-morning', 'A banana, a few dates'),
      _m('Lunch', 'Dal with rice, lauki sabzi, curd'),
      _m('Evening', 'Panjiri or gond ka laddu, milk'),
      _m('Dinner', 'Moong dal soup with two rotis, a green sabzi'),
    ]),
    _d('Day 5', [
      _m('Early', 'Haldi doodh'),
      _m('Breakfast', 'Vegetable upma, a glass of milk'),
      _m('Mid-morning', 'A guava, roasted makhana'),
      _m('Lunch', 'Khichdi with vegetables, curd'),
      _m('Evening', 'Dates and nuts laddoo, buttermilk'),
      _m('Dinner', 'Dal palak with two rotis'),
    ]),
    _d('Day 6', [
      _m('Early', 'Warm milk with a few almonds'),
      _m('Breakfast', 'Oats porridge with dates'),
      _m('Mid-morning', 'Pomegranate, a glass of milk'),
      _m('Lunch', 'Rajma with rice, salad, curd'),
      _m('Evening', 'Roasted makhana, ginger tea'),
      _m('Dinner', 'Paneer bhurji with two rotis, moong dal'),
    ]),
    _d('Day 7', [
      _m('Early', 'Haldi doodh'),
      _m('Breakfast', 'Besan chilla with curd'),
      _m('Mid-morning', 'An orange, a few almonds'),
      _m('Lunch', 'Chicken curry or dal with rice, a green sabzi'),
      _m('Evening', 'Panjiri, milk'),
      _m('Dinner', 'Khichdi with vegetables, a bowl of kheer'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  Vegetarian plus egg — the egg quietly closes the gaps
  // ---------------------------------------------------------------------------
  'eggetarian_chart': [
    _d('Day 4', [
      _m('Breakfast', 'Two boiled eggs, toast, milk'),
      _m('Mid-morning', 'A guava, roasted chana'),
      _m('Lunch', 'Rajma with rice, salad, curd'),
      _m('Evening', 'Sprouts chaat, buttermilk'),
      _m('Dinner', 'Dal palak with two rotis'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Vegetable upma, a glass of milk'),
      _m('Mid-morning', 'A banana, a few almonds'),
      _m('Lunch', 'Egg curry with rice, a green sabzi'),
      _m('Evening', 'Roasted makhana, lemon water'),
      _m('Dinner', 'Palak paneer with two rotis, dal'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Egg bhurji with two rotis'),
      _m('Mid-morning', 'Pomegranate, buttermilk'),
      _m('Lunch', 'Chole with rice, cucumber salad'),
      _m('Evening', 'Fruit chaat'),
      _m('Dinner', 'Moong dal with two rotis, lauki sabzi, curd'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Oats porridge with dates and almonds'),
      _m('Mid-morning', 'An orange, roasted chana'),
      _m('Lunch', 'Sambar with rice, beetroot sabzi, curd'),
      _m('Evening', 'Dhokla, ginger tea'),
      _m('Dinner', 'Khichdi with vegetables, a boiled egg, a bowl of kheer'),
    ]),
  ],

  // ---------------------------------------------------------------------------
  //  North Indian — roti, dal, sabzi and curd across UP, Bihar, Rajasthan and Delhi
  // ---------------------------------------------------------------------------
  'regional_north_indian': [
    _d('Day 4', [
      _m('Breakfast', 'Vegetable poha with peanuts, a glass of milk'),
      _m('Mid-morning', 'A guava, roasted chana'),
      _m('Lunch', 'Two rotis with dal, bhindi sabzi, curd'),
      _m('Evening', 'Sprouts chaat, buttermilk'),
      _m('Dinner', 'Rajma with rice, salad'),
    ]),
    _d('Day 5', [
      _m('Breakfast', 'Besan chilla with curd'),
      _m('Mid-morning', 'A banana, a few almonds'),
      _m('Lunch', 'Chole with two rotis, a green sabzi'),
      _m('Evening', 'Roasted makhana, lemon water'),
      _m('Dinner', 'Dal palak with two rotis, curd'),
    ]),
    _d('Day 6', [
      _m('Breakfast', 'Vegetable daliya with milk'),
      _m('Mid-morning', 'Pomegranate, roasted chana'),
      _m('Lunch', 'Kadhi with rice, lauki sabzi'),
      _m('Evening', 'Fruit chaat'),
      _m('Dinner', 'Paneer bhurji with two rotis, moong dal'),
    ]),
    _d('Day 7', [
      _m('Breakfast', 'Oats porridge with dates'),
      _m('Mid-morning', 'An orange, a glass of milk'),
      _m('Lunch', 'Sattu paratha with curd, salad'),
      _m('Evening', 'Dhokla or roasted chana, ginger tea'),
      _m('Dinner', 'Khichdi with vegetables, a bowl of kheer'),
    ]),
  ],

};
