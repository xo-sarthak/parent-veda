// =============================================================================
//  Food values — a number under every meal
// -----------------------------------------------------------------------------
//  2026-09-20, the user on the phone: "it's a nutrition door with zero
//  nutritional values … people care about nutritional value so much." True,
//  and every food app in the library agrees on the shape: two or three
//  numbers on the card (HelloFresh, Chipotle, Chick-fil-A), a per-serving
//  block on the page (Cherrypick, Bevel), and a caveat that the numbers are
//  averages.
//
//  The six that matter in pregnancy: energy, protein, iron, calcium, fibre,
//  folate — the five ticks on Today plus kcal. Everything here is an
//  ESTIMATE from typical Indian portions (IFCT 2017 / NIN scale, rounded),
//  said so on every surface, and it is a fact about the food, never a target
//  for her — no percentage-of-need bars, no "you are short". The reference
//  amounts (`kPregnancyDayReference`) are one quiet line by the ticks, in
//  the word "roughly".
//
//  Two estimators, one table:
//    · `estimateMeal(sentence)` — a chart meal is prose ("Two boiled eggs,
//      toast, milk"); dish words are matched, longest phrase first, counts
//      like "two rotis" multiply, and the servings sum.
//    · `estimateRecipe(recipe)` — a recipe has ingredients with quantities
//      per serving; each is looked up by weight (g / ml / cup / tbsp / tsp /
//      pcs) and summed for ONE serving.
//
//  Per-100 g values, with a `serving` in grams for the dish-in-prose case.
//  Cooked weights for cooked dishes. Iron here is total dietary iron; the
//  vegetarian kind absorbs less, which the iron read explains.
// =============================================================================

import '../nutrition_data.dart';

/// The six numbers. All per whatever the caller says (a serving, a day).
class NutritionValues {
  const NutritionValues({
    this.kcal = 0,
    this.protein = 0,
    this.iron = 0,
    this.calcium = 0,
    this.fibre = 0,
    this.folate = 0,
  });

  final double kcal;

  /// grams
  final double protein;

  /// milligrams
  final double iron;

  /// milligrams
  final double calcium;

  /// grams
  final double fibre;

  /// micrograms (DFE)
  final double folate;

  bool get isEmpty => kcal == 0 && protein == 0 && iron == 0 && calcium == 0 && fibre == 0 && folate == 0;

  NutritionValues operator +(NutritionValues o) => NutritionValues(
        kcal: kcal + o.kcal,
        protein: protein + o.protein,
        iron: iron + o.iron,
        calcium: calcium + o.calcium,
        fibre: fibre + o.fibre,
        folate: folate + o.folate,
      );

  NutritionValues operator *(double f) => NutritionValues(
        kcal: kcal * f,
        protein: protein * f,
        iron: iron * f,
        calcium: calcium * f,
        fibre: fibre * f,
        folate: folate * f,
      );

  static const zero = NutritionValues();
}

/// Reference amounts for a day in pregnancy (ICMR-NIN 2020, second and third
/// trimester, rounded). Shown as "roughly", once, by the ticks — never as a
/// bar against her plate.
const NutritionValues kPregnancyDayReference =
    NutritionValues(kcal: 2200, protein: 60, iron: 27, calcium: 1000, fibre: 30, folate: 570);

/// One food: values per 100 g, and how much one typical serving weighs.
class FoodValue {
  const FoodValue(this.per100, {required this.serving, this.pieceGrams});

  final NutritionValues per100;

  /// Grams in one serving when the food is named in prose ("dal", "poha").
  final double serving;

  /// Grams in one piece when a recipe says "2 pcs" (an egg, a roti, a date).
  final double? pieceGrams;

  NutritionValues get perServing => per100 * (serving / 100);
  NutritionValues perGrams(double g) => per100 * (g / 100);
}

NutritionValues _v(double kcal, double p, double fe, double ca, double fib, double fol) =>
    NutritionValues(kcal: kcal, protein: p, iron: fe, calcium: ca, fibre: fib, folate: fol);

/// The table. Keys are lower-case; a key with a space is a phrase and is
/// tried before its words. Values per 100 g (cooked where cooked).
final Map<String, FoodValue> kFoodValues = {
  // ---- breads, rice, grains ---------------------------------------------------
  'roti': FoodValue(_v(250, 8, 2.0, 25, 5, 20), serving: 40, pieceGrams: 40),
  'rotis': FoodValue(_v(250, 8, 2.0, 25, 5, 20), serving: 80, pieceGrams: 40),
  'chapati': FoodValue(_v(250, 8, 2.0, 25, 5, 20), serving: 40, pieceGrams: 40),
  'phulka': FoodValue(_v(250, 8, 2.0, 25, 5, 20), serving: 40, pieceGrams: 35),
  'paratha': FoodValue(_v(300, 7, 1.8, 25, 4, 18), serving: 80, pieceGrams: 80),
  'thepla': FoodValue(_v(290, 7, 2.2, 40, 4, 20), serving: 70, pieceGrams: 35),
  'thalipeeth': FoodValue(_v(260, 9, 2.5, 40, 6, 25), serving: 90, pieceGrams: 90),
  'toast': FoodValue(_v(265, 8, 1.5, 40, 3, 30), serving: 60, pieceGrams: 30),
  'bread': FoodValue(_v(265, 8, 1.5, 40, 3, 30), serving: 60, pieceGrams: 30),
  'rice': FoodValue(_v(130, 2.7, 0.3, 10, 0.4, 3), serving: 150),
  'brown rice': FoodValue(_v(120, 2.6, 0.5, 10, 1.8, 4), serving: 150),
  'curd rice': FoodValue(_v(120, 4, 0.3, 60, 0.4, 5), serving: 250),
  'khichdi': FoodValue(_v(120, 4.5, 1.0, 20, 2, 25), serving: 250),
  'pulao': FoodValue(_v(150, 3.5, 0.6, 20, 1.5, 10), serving: 200),
  'biryani': FoodValue(_v(180, 7, 1.0, 25, 1.2, 10), serving: 220),
  'poha': FoodValue(_v(150, 3, 1.5, 15, 1.5, 10), serving: 150),
  'upma': FoodValue(_v(140, 3.5, 1.0, 15, 1.8, 12), serving: 150),
  'idli': FoodValue(_v(130, 4, 0.8, 15, 1.2, 10), serving: 120, pieceGrams: 40),
  'idlis': FoodValue(_v(130, 4, 0.8, 15, 1.2, 10), serving: 120, pieceGrams: 40),
  'dosa': FoodValue(_v(170, 4, 1.0, 15, 1.2, 12), serving: 110, pieceGrams: 110),
  'ragi dosa': FoodValue(_v(180, 5, 2.5, 120, 2.5, 15), serving: 110, pieceGrams: 110),
  'uttapam': FoodValue(_v(170, 4.5, 1.0, 20, 1.5, 14), serving: 130, pieceGrams: 130),
  'oats': FoodValue(_v(70, 2.5, 0.9, 50, 1.7, 8), serving: 250),
  'oatmeal': FoodValue(_v(70, 2.5, 0.9, 50, 1.7, 8), serving: 250),
  'rolled oats': FoodValue(_v(380, 13, 4.3, 52, 10, 30), serving: 40),
  'daliya': FoodValue(_v(95, 3.2, 1.2, 18, 2.5, 10), serving: 250),
  'dalia': FoodValue(_v(95, 3.2, 1.2, 18, 2.5, 10), serving: 250),
  'ragi': FoodValue(_v(90, 2, 1.5, 100, 2, 8), serving: 250),
  'ragi kanji': FoodValue(_v(90, 2, 1.5, 100, 2, 8), serving: 250),
  'ragi porridge': FoodValue(_v(90, 2, 1.5, 100, 2, 8), serving: 250),
  'ragi flour': FoodValue(_v(320, 7, 3.9, 344, 11, 18), serving: 30),
  'kanji': FoodValue(_v(90, 2, 1.5, 100, 2, 8), serving: 250),
  'sabudana': FoodValue(_v(180, 0.5, 0.6, 10, 0.5, 2), serving: 150),
  'semolina': FoodValue(_v(360, 12, 1.2, 17, 4, 70), serving: 50),
  'rava': FoodValue(_v(360, 12, 1.2, 17, 4, 70), serving: 50),
  'whole-wheat flour': FoodValue(_v(340, 12, 3.9, 34, 11, 44), serving: 60),
  'flour': FoodValue(_v(340, 12, 3.9, 34, 11, 44), serving: 60),
  'besan': FoodValue(_v(370, 20, 4.5, 45, 10, 400), serving: 50),
  'rice flour': FoodValue(_v(360, 6, 0.4, 10, 2, 4), serving: 15),
  'poha, rinsed': FoodValue(_v(350, 6.5, 2.5, 20, 2, 12), serving: 60),
  'thick poha': FoodValue(_v(350, 6.5, 2.5, 20, 2, 12), serving: 60),
  'idli batter': FoodValue(_v(100, 3.5, 0.7, 15, 1.2, 10), serving: 240),

  // ---- dals, beans, sprouts -------------------------------------------------
  'dal': FoodValue(_v(105, 6, 1.5, 25, 3, 60), serving: 150),
  'sambar': FoodValue(_v(85, 4, 1.2, 30, 2.5, 45), serving: 150),
  'rasam': FoodValue(_v(40, 1.5, 0.8, 20, 1, 15), serving: 150),
  'rajma': FoodValue(_v(130, 7, 2.2, 40, 5, 80), serving: 150),
  'chole': FoodValue(_v(150, 7, 2.5, 45, 5, 100), serving: 150),
  'chana': FoodValue(_v(150, 7, 2.5, 45, 5, 100), serving: 150),
  'roasted chana': FoodValue(_v(370, 19, 6.0, 55, 12, 180), serving: 30),
  'chickpeas': FoodValue(_v(160, 8.5, 2.9, 50, 7, 170), serving: 150),
  'moong': FoodValue(_v(105, 7, 1.4, 27, 3, 60), serving: 150),
  'moong dal': FoodValue(_v(105, 7, 1.4, 27, 3, 60), serving: 150),
  'yellow moong dal': FoodValue(_v(340, 24, 4.0, 75, 9, 220), serving: 40),
  'split green moong dal': FoodValue(_v(340, 24, 4.0, 75, 9, 220), serving: 50),
  'toor dal': FoodValue(_v(340, 22, 2.7, 70, 9, 200), serving: 50),
  'toor or moong dal': FoodValue(_v(340, 23, 3.3, 72, 9, 210), serving: 50),
  'toor dal, cooked': FoodValue(_v(120, 7, 1.0, 25, 3, 60), serving: 50),
  'urad dal': FoodValue(_v(340, 24, 3.8, 150, 10, 200), serving: 10),
  'sprouts': FoodValue(_v(60, 4, 1.2, 25, 3, 60), serving: 80),
  'moong sprouts': FoodValue(_v(60, 4, 1.2, 25, 3, 60), serving: 80),
  'kadhi': FoodValue(_v(90, 3.5, 0.7, 60, 1, 20), serving: 150),
  'sundal': FoodValue(_v(150, 7, 2.5, 45, 5, 90), serving: 100),
  'undhiyu': FoodValue(_v(140, 4, 1.5, 50, 4, 45), serving: 150),
  'shaak': FoodValue(_v(80, 2.5, 1.2, 40, 3, 40), serving: 120),
  'rotli': FoodValue(_v(250, 8, 2.0, 25, 5, 20), serving: 60, pieceGrams: 30),
  'bathua': FoodValue(_v(45, 3.7, 4.2, 150, 2.5, 80), serving: 100),
  'sarson saag': FoodValue(_v(90, 3.5, 3.0, 150, 3.5, 90), serving: 120),
  'saag': FoodValue(_v(90, 3.5, 3.0, 150, 3.5, 90), serving: 120),
  'makki roti': FoodValue(_v(280, 6, 2.0, 20, 4, 15), serving: 70, pieceGrams: 70),
  'panjiri': FoodValue(_v(480, 9, 3.0, 80, 4, 30), serving: 40),
  'gond ka laddu': FoodValue(_v(450, 7, 3.0, 70, 3, 25), serving: 40),
  'gond laddu': FoodValue(_v(450, 7, 3.0, 70, 3, 25), serving: 40),
  'pongal': FoodValue(_v(150, 5, 1.0, 20, 2, 25), serving: 200),
  'pesarattu': FoodValue(_v(180, 9, 2.0, 30, 3.5, 100), serving: 120, pieceGrams: 60),
  'poriyal': FoodValue(_v(80, 2.5, 1.0, 45, 3, 35), serving: 100),
  'keerai': FoodValue(_v(40, 3, 2.5, 100, 2.5, 140), serving: 100),
  'thoran': FoodValue(_v(90, 2.5, 1.0, 45, 3, 35), serving: 100),
  'bisi bele bath': FoodValue(_v(140, 5, 1.5, 25, 3, 40), serving: 250),
  'ragi mudde': FoodValue(_v(110, 2.5, 1.5, 120, 3, 8), serving: 150),
  'sattu': FoodValue(_v(400, 20, 6.0, 60, 12, 200), serving: 40),
  'sattu paratha': FoodValue(_v(300, 11, 3.5, 40, 6, 60), serving: 90, pieceGrams: 90),
  'khandvi': FoodValue(_v(150, 7, 1.2, 40, 2, 70), serving: 80),
  'shrikhand': FoodValue(_v(220, 5, 0.2, 130, 0, 8), serving: 80),
  'mishti doi': FoodValue(_v(150, 4, 0.2, 130, 0, 7), serving: 100),
  'chorchori': FoodValue(_v(90, 2.5, 1.2, 45, 3.5, 40), serving: 120),
  'aloo posto': FoodValue(_v(150, 4, 1.5, 40, 2.5, 20), serving: 120),
  'bajra roti': FoodValue(_v(300, 9, 5.0, 30, 6, 40), serving: 60, pieceGrams: 60),
  'jowar roti': FoodValue(_v(290, 8, 3.0, 25, 7, 20), serving: 60, pieceGrams: 60),
  'kadala curry': FoodValue(_v(140, 7, 2.6, 45, 5, 95), serving: 150),
  'khichuri': FoodValue(_v(120, 4.5, 1.0, 20, 2, 25), serving: 250),
  'adai': FoodValue(_v(190, 9, 2.2, 30, 3.5, 90), serving: 120, pieceGrams: 60),
  'avial': FoodValue(_v(90, 2.5, 0.8, 40, 3, 30), serving: 120),
  'appam': FoodValue(_v(120, 2.5, 0.5, 10, 0.8, 8), serving: 120, pieceGrams: 60),
  'idiyappam': FoodValue(_v(130, 2.5, 0.4, 8, 0.8, 6), serving: 150),
  'puttu': FoodValue(_v(150, 3, 0.6, 12, 1.5, 8), serving: 150),
  'vegetable stew': FoodValue(_v(85, 2, 0.7, 30, 2, 25), serving: 150),
  'stew': FoodValue(_v(85, 2, 0.7, 30, 2, 25), serving: 150),
  'handvo': FoodValue(_v(200, 7, 1.8, 40, 3.5, 60), serving: 100),
  'muthiya': FoodValue(_v(180, 6, 1.5, 35, 3, 50), serving: 100),
  'idada': FoodValue(_v(150, 6, 1.4, 25, 2.5, 60), serving: 100),
  'doi': FoodValue(_v(70, 3.5, 0.1, 130, 0, 7), serving: 120),
  'gur': FoodValue(_v(380, 0.4, 11.0, 80, 0, 0), serving: 15),

  // ---- vegetables -----------------------------------------------------------
  'sabzi': FoodValue(_v(80, 2.5, 1.2, 40, 3, 40), serving: 120),
  'green sabzi': FoodValue(_v(70, 3, 1.8, 60, 3.5, 60), serving: 120),
  'lauki sabzi': FoodValue(_v(45, 1, 0.5, 25, 1.5, 15), serving: 120),
  'methi sabzi': FoodValue(_v(80, 4, 2.5, 150, 3, 50), serving: 100),
  'palak': FoodValue(_v(40, 3, 2.7, 100, 2.5, 140), serving: 100),
  'spinach': FoodValue(_v(25, 2.9, 2.7, 99, 2.2, 190), serving: 80),
  'spinach, chopped': FoodValue(_v(25, 2.9, 2.7, 99, 2.2, 190), serving: 80),
  'bhindi': FoodValue(_v(70, 2, 0.8, 80, 3.5, 60), serving: 100),
  'shukto': FoodValue(_v(80, 2.5, 1.0, 40, 3, 30), serving: 150),
  'salad': FoodValue(_v(25, 1, 0.5, 20, 1.5, 30), serving: 100),
  'cucumber': FoodValue(_v(15, 0.7, 0.3, 16, 0.5, 7), serving: 60),
  'tomato': FoodValue(_v(20, 0.9, 0.4, 10, 1.2, 15), serving: 80, pieceGrams: 80),
  'tomatoes': FoodValue(_v(20, 0.9, 0.4, 10, 1.2, 15), serving: 160, pieceGrams: 80),
  'onion': FoodValue(_v(40, 1.1, 0.2, 23, 1.7, 19), serving: 50, pieceGrams: 80),
  'carrot': FoodValue(_v(40, 0.9, 0.3, 33, 2.8, 19), serving: 60, pieceGrams: 60),
  'carrot and beans': FoodValue(_v(38, 1.4, 0.7, 35, 2.8, 25), serving: 60),
  'carrot and beans, chopped': FoodValue(_v(38, 1.4, 0.7, 35, 2.8, 25), serving: 60),
  'peas': FoodValue(_v(80, 5.4, 1.5, 25, 5, 65), serving: 50),
  'green peas': FoodValue(_v(80, 5.4, 1.5, 25, 5, 65), serving: 50),
  'potato': FoodValue(_v(85, 2, 0.8, 10, 2, 15), serving: 80, pieceGrams: 100),
  'boiled potato': FoodValue(_v(85, 2, 0.8, 10, 2, 15), serving: 80, pieceGrams: 100),
  'beetroot': FoodValue(_v(45, 1.6, 0.8, 16, 2.8, 110), serving: 60),
  'drumstick': FoodValue(_v(35, 2.5, 0.4, 30, 3, 40), serving: 60),
  'pumpkin': FoodValue(_v(25, 1, 0.8, 20, 1, 15), serving: 80),
  'mixed vegetables': FoodValue(_v(45, 2, 0.8, 30, 3, 35), serving: 100),
  'vegetables': FoodValue(_v(45, 2, 0.8, 30, 3, 35), serving: 100),
  'mushroom': FoodValue(_v(22, 3, 0.5, 3, 1, 17), serving: 80),
  'ginger': FoodValue(_v(80, 1.8, 0.6, 16, 2, 11), serving: 5, pieceGrams: 2),
  'garlic': FoodValue(_v(150, 6, 1.7, 180, 2, 3), serving: 5, pieceGrams: 3),
  'mint': FoodValue(_v(45, 3.3, 5.0, 200, 8, 110), serving: 5, pieceGrams: 1),
  'coriander': FoodValue(_v(23, 2, 1.8, 67, 2.8, 62), serving: 5),
  'lemon': FoodValue(_v(30, 1, 0.6, 26, 2.8, 11), serving: 15, pieceGrams: 60),
  'green chilli': FoodValue(_v(40, 2, 1.2, 18, 1.5, 23), serving: 5, pieceGrams: 5),

  // ---- dairy, eggs, paneer ---------------------------------------------------
  'milk': FoodValue(_v(65, 3.3, 0.1, 120, 0, 5), serving: 240),
  'glass of milk': FoodValue(_v(65, 3.3, 0.1, 120, 0, 5), serving: 240),
  'curd': FoodValue(_v(70, 3.5, 0.1, 130, 0, 7), serving: 120),
  'dahi': FoodValue(_v(70, 3.5, 0.1, 130, 0, 7), serving: 120),
  'yogurt': FoodValue(_v(70, 3.5, 0.1, 130, 0, 7), serving: 120),
  'buttermilk': FoodValue(_v(30, 1.5, 0.1, 60, 0, 3), serving: 240),
  'chaas': FoodValue(_v(30, 1.5, 0.1, 60, 0, 3), serving: 240),
  'lassi': FoodValue(_v(90, 3, 0.1, 110, 0, 6), serving: 240),
  'paneer': FoodValue(_v(265, 18, 0.5, 480, 0, 25), serving: 60),
  'paneer, crumbled': FoodValue(_v(265, 18, 0.5, 480, 0, 25), serving: 50),
  'palak paneer': FoodValue(_v(180, 9, 2.0, 250, 2.5, 90), serving: 150),
  'paneer bhurji': FoodValue(_v(200, 12, 0.8, 300, 1, 30), serving: 120),
  'cheese': FoodValue(_v(330, 20, 0.7, 700, 0, 25), serving: 30),
  'ghee': FoodValue(_v(900, 0, 0, 0, 0, 0), serving: 5),
  'butter': FoodValue(_v(720, 0.5, 0, 20, 0, 3), serving: 5),
  'egg': FoodValue(_v(155, 13, 1.8, 50, 0, 47), serving: 50, pieceGrams: 50),
  'eggs': FoodValue(_v(155, 13, 1.8, 50, 0, 47), serving: 100, pieceGrams: 50),
  'boiled egg': FoodValue(_v(155, 13, 1.8, 50, 0, 47), serving: 50, pieceGrams: 50),
  'boiled eggs': FoodValue(_v(155, 13, 1.8, 50, 0, 47), serving: 100, pieceGrams: 50),
  'egg bhurji': FoodValue(_v(180, 11, 1.8, 60, 0.5, 45), serving: 120),
  'omelette': FoodValue(_v(170, 12, 1.8, 55, 0.3, 45), serving: 110),
  'egg curry': FoodValue(_v(140, 8, 1.5, 45, 1, 35), serving: 180),

  // ---- fish, meat -------------------------------------------------------------
  'fish': FoodValue(_v(120, 20, 1.0, 40, 0, 10), serving: 100),
  'fish curry': FoodValue(_v(130, 14, 1.0, 40, 0.5, 15), serving: 180),
  'macher jhol': FoodValue(_v(130, 14, 1.0, 40, 0.5, 15), serving: 180),
  'pomfret': FoodValue(_v(110, 19, 0.9, 30, 0, 8), serving: 100),
  'rohu': FoodValue(_v(100, 17, 1.0, 40, 0, 10), serving: 100),
  'prawns': FoodValue(_v(100, 20, 1.5, 70, 0, 5), serving: 100),
  'chicken': FoodValue(_v(165, 25, 1.0, 12, 0, 6), serving: 100),
  'chicken curry': FoodValue(_v(150, 15, 1.2, 25, 0.8, 12), serving: 180),
  'chicken, on the bone': FoodValue(_v(100, 14, 0.7, 12, 0, 5), serving: 100), // bone is weight, not meat
  'chicken, boneless': FoodValue(_v(165, 25, 1.0, 12, 0, 6), serving: 100),
  'mutton': FoodValue(_v(250, 22, 2.5, 15, 0, 5), serving: 100),
  'kebab': FoodValue(_v(220, 18, 2.0, 20, 0.5, 10), serving: 100),

  // ---- fruit ------------------------------------------------------------------
  'fruit': FoodValue(_v(60, 0.8, 0.4, 15, 2.5, 15), serving: 150),
  'seasonal fruit': FoodValue(_v(60, 0.8, 0.4, 15, 2.5, 15), serving: 150),
  'banana': FoodValue(_v(90, 1.1, 0.3, 5, 2.6, 20), serving: 100, pieceGrams: 100),
  'apple': FoodValue(_v(52, 0.3, 0.1, 6, 2.4, 3), serving: 150, pieceGrams: 150),
  'orange': FoodValue(_v(47, 0.9, 0.1, 40, 2.4, 30), serving: 130, pieceGrams: 130),
  'sweet lime': FoodValue(_v(43, 0.8, 0.3, 40, 1.5, 20), serving: 130, pieceGrams: 130),
  'mosambi': FoodValue(_v(43, 0.8, 0.3, 40, 1.5, 20), serving: 130, pieceGrams: 130),
  'guava': FoodValue(_v(68, 2.6, 0.3, 18, 5.4, 49), serving: 100, pieceGrams: 100),
  'papaya': FoodValue(_v(43, 0.5, 0.3, 20, 1.7, 37), serving: 150),
  'pomegranate': FoodValue(_v(83, 1.7, 0.3, 10, 4, 38), serving: 100),
  'dates': FoodValue(_v(280, 2.5, 1.0, 40, 8, 15), serving: 30, pieceGrams: 8),
  'dates, pitted': FoodValue(_v(280, 2.5, 1.0, 40, 8, 15), serving: 30, pieceGrams: 8),
  'raisins': FoodValue(_v(300, 3, 1.9, 50, 3.7, 5), serving: 15),
  'mango': FoodValue(_v(60, 0.8, 0.2, 11, 1.6, 43), serving: 150),
  'chikoo': FoodValue(_v(83, 0.4, 0.8, 21, 5.3, 14), serving: 100),
  'amla': FoodValue(_v(44, 0.9, 0.3, 25, 4.3, 6), serving: 30),
  'pear': FoodValue(_v(57, 0.4, 0.2, 9, 3.1, 7), serving: 150, pieceGrams: 150),
  'figs': FoodValue(_v(250, 3.3, 2.0, 160, 10, 9), serving: 30, pieceGrams: 15),
  'figs soaked overnight': FoodValue(_v(250, 3.3, 2.0, 160, 10, 9), serving: 30, pieceGrams: 15),
  'coconut water': FoodValue(_v(19, 0.7, 0.3, 24, 1.1, 3), serving: 240),
  'fresh coconut water': FoodValue(_v(19, 0.7, 0.3, 24, 1.1, 3), serving: 240),

  // ---- nuts, seeds ------------------------------------------------------------
  'nuts': FoodValue(_v(600, 18, 3.5, 150, 8, 40), serving: 25),
  'handful of nuts': FoodValue(_v(600, 18, 3.5, 150, 8, 40), serving: 25),
  'almonds': FoodValue(_v(580, 21, 3.7, 270, 12, 44), serving: 20, pieceGrams: 1.2),
  'almonds, sliced': FoodValue(_v(580, 21, 3.7, 270, 12, 44), serving: 10, pieceGrams: 1.2),
  'walnuts': FoodValue(_v(650, 15, 2.9, 98, 6.7, 98), serving: 20, pieceGrams: 4),
  'cashews': FoodValue(_v(550, 18, 6.7, 37, 3.3, 25), serving: 20, pieceGrams: 1.5),
  'peanuts': FoodValue(_v(570, 26, 4.6, 92, 8.5, 240), serving: 25),
  'peanuts, roasted and skinned': FoodValue(_v(585, 26, 2.3, 55, 8.4, 145), serving: 25),
  'makhana': FoodValue(_v(350, 9.7, 1.4, 60, 14, 20), serving: 25),
  'flaxseed': FoodValue(_v(530, 18, 5.7, 255, 27, 87), serving: 10),
  'sesame': FoodValue(_v(570, 18, 14.5, 975, 12, 97), serving: 10),
  'til': FoodValue(_v(570, 18, 14.5, 975, 12, 97), serving: 10),
  'desiccated coconut': FoodValue(_v(660, 7, 3.3, 26, 16, 9), serving: 10),
  'almonds, cashews, walnuts, mixed': FoodValue(_v(590, 18, 4.4, 135, 7.3, 56), serving: 20),

  // ---- sweeteners, sweets -----------------------------------------------------
  'jaggery': FoodValue(_v(380, 0.4, 11.0, 80, 0, 0), serving: 15),
  'jaggery, grated': FoodValue(_v(380, 0.4, 11.0, 80, 0, 0), serving: 15),
  'honey': FoodValue(_v(300, 0.3, 0.4, 6, 0.2, 2), serving: 7),
  'sugar': FoodValue(_v(400, 0, 0, 1, 0, 0), serving: 10),
  'kheer': FoodValue(_v(140, 3.5, 0.5, 110, 0.3, 8), serving: 150),
  'halwa': FoodValue(_v(300, 4, 1.5, 60, 2, 15), serving: 80),
  'laddoo': FoodValue(_v(420, 8, 2.5, 60, 4, 30), serving: 40),
  'chikki': FoodValue(_v(480, 13, 5.5, 60, 4, 70), serving: 30),
  'mithai': FoodValue(_v(400, 6, 1.0, 150, 0.5, 10), serving: 50),

  // ---- drinks -----------------------------------------------------------------
  'tea': FoodValue(_v(40, 1.2, 0.05, 45, 0, 2), serving: 150),
  'chai': FoodValue(_v(40, 1.2, 0.05, 45, 0, 2), serving: 150),
  'coffee': FoodValue(_v(40, 1.5, 0.05, 50, 0, 2), serving: 150),
  'juice': FoodValue(_v(45, 0.5, 0.2, 10, 0.3, 20), serving: 200),
  'smoothie': FoodValue(_v(80, 2.5, 0.4, 70, 1.5, 20), serving: 250),
  'soup': FoodValue(_v(45, 2, 0.6, 20, 1.2, 20), serving: 200),
  'water': FoodValue(_v(0, 0, 0, 0, 0, 0), serving: 240),
  'cold water': FoodValue(_v(0, 0, 0, 0, 0, 0), serving: 240),
  'badam milk': FoodValue(_v(110, 5, 0.5, 150, 0.8, 10), serving: 240),
  'haldi doodh': FoodValue(_v(70, 3.4, 0.2, 122, 0.1, 5), serving: 240),
  'turmeric milk': FoodValue(_v(70, 3.4, 0.2, 122, 0.1, 5), serving: 240),

  // ---- snacks -----------------------------------------------------------------
  'dhokla': FoodValue(_v(160, 6, 1.5, 30, 2.5, 60), serving: 100),
  'chilla': FoodValue(_v(180, 9, 2.0, 30, 3.5, 120), serving: 100, pieceGrams: 60),
  'khakhra': FoodValue(_v(400, 10, 3.0, 40, 6, 25), serving: 30, pieceGrams: 15),
  'sandwich': FoodValue(_v(220, 7, 1.5, 60, 3, 35), serving: 130),
  'chaat': FoodValue(_v(120, 4, 1.2, 30, 3, 40), serving: 120),
  'sprouts chaat': FoodValue(_v(90, 5, 1.5, 30, 3.5, 70), serving: 120),
  'fruit chaat': FoodValue(_v(60, 1, 0.5, 20, 2.5, 20), serving: 150),
  'murmura': FoodValue(_v(380, 6, 4.0, 20, 1, 10), serving: 30),
  'muri': FoodValue(_v(380, 6, 4.0, 20, 1, 10), serving: 30),
  'chirer polao': FoodValue(_v(150, 3, 1.5, 15, 1.5, 10), serving: 150),
  'luchi': FoodValue(_v(330, 6, 1.5, 15, 1.5, 15), serving: 60, pieceGrams: 30),
  'biscuits': FoodValue(_v(480, 6, 1.5, 20, 1, 10), serving: 30),
  'biscuit': FoodValue(_v(480, 6, 1.5, 20, 1, 10), serving: 15, pieceGrams: 8),
  'crackers': FoodValue(_v(430, 8, 1.5, 30, 2, 15), serving: 20, pieceGrams: 5),
  'cornflakes': FoodValue(_v(370, 7, 8.0, 10, 3, 100), serving: 30),
  'samosa': FoodValue(_v(260, 5, 1.5, 20, 2, 15), serving: 100),
  'pakora': FoodValue(_v(280, 7, 2.0, 30, 3, 60), serving: 80),

  // ---- oils, spices (small, but a recipe sums them) ---------------------------
  'oil': FoodValue(_v(900, 0, 0, 0, 0, 0), serving: 5),
  // Spices: IFCT-scale iron (a tempering is a gram or two, and its iron is
  // mostly not absorbed), so these read modestly on purpose.
  'mustard seeds': FoodValue(_v(500, 25, 8, 300, 12, 160), serving: 2),
  'cumin seeds': FoodValue(_v(375, 18, 11, 900, 10, 10), serving: 2),
  'turmeric': FoodValue(_v(310, 10, 20, 170, 21, 20), serving: 1),
  'black pepper': FoodValue(_v(250, 10, 8, 440, 25, 17), serving: 1),
  'cardamom': FoodValue(_v(310, 11, 5, 380, 28, 0), serving: 1),
  'salt': FoodValue(_v(0, 0, 0, 0, 0, 0), serving: 1),
  'spices': FoodValue(_v(300, 12, 20, 400, 20, 30), serving: 3),
  'sambar powder': FoodValue(_v(300, 12, 20, 400, 20, 30), serving: 3),
  'tamarind': FoodValue(_v(240, 2.8, 2.8, 74, 5, 14), serving: 5),
  'saffron': FoodValue(_v(310, 11, 11, 111, 4, 93), serving: 0.1),
  'ajwain': FoodValue(_v(305, 16, 12, 1500, 40, 40), serving: 1),
  'chaat masala': FoodValue(_v(250, 8, 15, 300, 15, 20), serving: 2),
};

// -----------------------------------------------------------------------------
//  The prose estimator
// -----------------------------------------------------------------------------

const Map<String, double> _kCounts = {
  'a': 1, 'an': 1, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6,
  'half': 0.5, 'couple': 2, 'few': 3,
};

/// The keys, longest phrase first, so "curd rice" beats "curd" and "rice".
final List<String> _kKeysByLength = kFoodValues.keys.toList()
  ..sort((a, b) => b.length.compareTo(a.length));

/// One matched food in a sentence.
class MealMatch {
  const MealMatch(this.key, this.count, this.values);
  final String key;
  final double count;
  final NutritionValues values;
}

/// The dish before the dash — "Fish curry with rice" from "Fish curry with
/// rice — well cooked, and a low-mercury fish like rohu". The chart writes
/// the advice into the line; a row, a swap option and a sheet title show
/// the dish and carry the advice as its own small line (`plateNote`).
String plateName(String items) => items.split(RegExp('[—–]')).first.trim();

/// The advice after the dash, or null.
String? plateNote(String items) {
  final parts = items.split(RegExp('[—–]'));
  if (parts.length < 2) return null;
  final note = parts.sublist(1).join(' ').trim();
  return note.isEmpty ? null : note[0].toUpperCase() + note.substring(1);
}

/// Estimate a meal named in prose. Null when nothing in it is a food we know.
///
/// "Two boiled eggs, toast, milk" → boiled eggs ×1 (the key already means
/// two), toast ×1, milk ×1. "Dal with two rotis, lauki sabzi" → dal, rotis
/// ("two rotis" is a count of 2 over the single `roti`), lauki sabzi. A
/// count word right before a food multiplies its serving; a plural key
/// whose serving already counts two ("eggs") ignores the count.
List<MealMatch> matchMeal(String sentence) {
  // "Orange or sweet lime" is one fruit, not two: keep the first alternative
  // of every "or" — an estimate of the day she is likelier to have.
  // A dash starts advice, not food ("Fish curry with rice — well cooked,
  // and a low-mercury fish like rohu…"): the plate stops at the dash.
  final plate = sentence.split(RegExp('[—–]')).first;
  // ⚠️ DROP THE ALTERNATIVE, NOT THE REST OF THE PLATE (2026-09-22). This
  // cut the sentence at "or", so "Chicken or egg curry with roti, palak
  // sabzi" became "Chicken" — 165 kcal for a dinner, on the phone. Now the
  // "or …" phrase goes up to the next comma, "with" or "and", and the plate
  // after it stays: "Chicken curry with roti, palak sabzi".
  final firstOf = plate.replaceAll(RegExp(r'\s+\bor\b\s+.*?(?=,|;| with | and |$)'), '');
  var s = ' ${firstOf.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s\-]'), ' ')} ';
  s = s.replaceAll(RegExp(r'\s+'), ' ');
  final out = <MealMatch>[];
  for (final key in _kKeysByLength) {
    final idx = s.indexOf(' $key ');
    if (idx < 0) continue;
    final fv = kFoodValues[key]!;
    // a count right before it: "two rotis", "2 idlis", "a handful of nuts"
    var count = 1.0;
    final before = s.substring(0, idx).trimRight();
    final lastWord = before.split(' ').last;
    final n = double.tryParse(lastWord);
    if (n != null) {
      count = n;
    } else if (_kCounts.containsKey(lastWord)) {
      count = _kCounts[lastWord]!;
    }
    // a plural whose serving already means two ("eggs", "rotis") takes the
    // count as pieces, not as multiples of the pair
    final pieces = fv.pieceGrams;
    final values = (pieces != null && count != 1)
        ? fv.perGrams(pieces * count)
        : fv.perServing * (pieces == null ? count : 1);
    out.add(MealMatch(key, count, values));
    // blank it so shorter keys inside it do not match again
    s = s.replaceFirst(' $key ', ' ${'#' * key.length} ');
  }
  return out;
}

NutritionValues? estimateMeal(String sentence) {
  var m = matchMeal(sentence);
  // The first alternative was a dish we do not know ("Undhiyu or a mixed
  // shaak …"): take the whole line rather than answer nothing.
  if (m.isEmpty && sentence.contains(' or ')) m = matchMeal(sentence.split(RegExp('[—–]')).first.replaceAll(' or ', ' , '));
  // The advice came first ("Luchi is a treat — start with muri with milk"):
  // the whole line, then, with every alternative in.
  if (m.isEmpty) m = matchMeal(sentence.replaceAll(RegExp('[—–]'), ' , ').replaceAll(' or ', ' , '));
  if (m.isEmpty) return null;
  var total = NutritionValues.zero;
  for (final x in m) {
    total = total + x.values;
  }
  return total;
}

// -----------------------------------------------------------------------------
//  The recipe estimator — ingredients by weight, for one serving
// -----------------------------------------------------------------------------

double _gramsFor(FoodValue fv, double qty, String unit) => switch (unit) {
      'g' || 'ml' => qty,
      'cup' => qty * (fv.per100.kcal > 300 ? 150 : 240), // dry grains / flours vs liquids
      'tbsp' => qty * 15,
      'tsp' => qty * 5,
      'pcs' => qty * (fv.pieceGrams ?? fv.serving),
      _ => qty,
    };

/// The food an ingredient line names: the longest key the line contains.
FoodValue? _foodForIngredient(String name) {
  final s = ' ${name.toLowerCase().replaceAll(RegExp(r'[^a-z\s\-]'), ' ')} '.replaceAll(RegExp(r'\s+'), ' ');
  for (final key in _kKeysByLength) {
    if (s.contains(' $key ')) return kFoodValues[key];
  }
  return null;
}

/// One serving of a recipe, from its ingredients. Ingredients the table
/// does not know contribute nothing — so a recipe estimate can only read
/// low, never high, which is the right side to err on.
NutritionValues estimateRecipe(Recipe r) {
  var total = NutritionValues.zero;
  for (final i in r.ingredients) {
    final fv = _foodForIngredient(i.name.en);
    if (fv == null) continue;
    total = total + fv.perGrams(_gramsFor(fv, i.qtyPerServing, i.unit));
  }
  return total;
}

// -----------------------------------------------------------------------------
//  Words
// -----------------------------------------------------------------------------

String _n(double v) => v >= 100 ? v.round().toString() : (v >= 10 ? v.round().toString() : v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1));

/// "≈ 320 kcal · 12 g protein · 3 mg iron" — energy, protein, and the one
/// of iron / calcium / fibre / folate the dish is strongest in, judged
/// against a day's reference so a calcium dish says calcium.
String nutritionGlance(NutritionValues v) {
  if (v.isEmpty) return '';
  final parts = ['≈ ${_n(v.kcal)} kcal', '${_n(v.protein)} g protein'];
  final ranked = [
    (v.iron / kPregnancyDayReference.iron, '${_n(v.iron)} mg iron'),
    (v.calcium / kPregnancyDayReference.calcium, '${_n(v.calcium)} mg calcium'),
    (v.fibre / kPregnancyDayReference.fibre, '${_n(v.fibre)} g fibre'),
    (v.folate / kPregnancyDayReference.folate, '${_n(v.folate)} µg folate'),
  ]..sort((a, b) => b.$1.compareTo(a.$1));
  if (ranked.first.$1 > 0.03) parts.add(ranked.first.$2);
  return parts.join('  ·  ');
}

/// The three a dish is strongest in, ranked by share of a day's reference —
/// energy excluded (every dish has some). (need id, label, value with unit.)
/// The need id matches `kPlateNeeds` so the tick's own mark can draw it.
List<(String, String, String)> nutritionTopThree(NutritionValues v) {
  final ranked = [
    (v.protein / kPregnancyDayReference.protein, 'protein', 'Protein', '${_n(v.protein)} g'),
    (v.iron / kPregnancyDayReference.iron, 'iron', 'Iron', '${_n(v.iron)} mg'),
    (v.calcium / kPregnancyDayReference.calcium, 'calcium', 'Calcium', '${_n(v.calcium)} mg'),
    (v.fibre / kPregnancyDayReference.fibre, 'fibre', 'Fibre', '${_n(v.fibre)} g'),
    (v.folate / kPregnancyDayReference.folate, 'folic_acid', 'Folate', '${_n(v.folate)} µg'),
  ]..sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final r in ranked.take(3)) (r.$2, r.$3, r.$4)];
}

/// The six, for a tile grid: (label, value with unit).
List<(String, String)> nutritionTiles(NutritionValues v) => [
      ('Energy', '${_n(v.kcal)} kcal'),
      ('Protein', '${_n(v.protein)} g'),
      ('Iron', '${_n(v.iron)} mg'),
      ('Calcium', '${_n(v.calcium)} mg'),
      ('Fibre', '${_n(v.fibre)} g'),
      ('Folate', '${_n(v.folate)} µg'),
    ];

/// The caveat every surface carries, verbatim.
const String kNutritionEstimateNote =
    'Estimated from typical Indian portions (IFCT 2017 averages). Your portions and recipes vary; '
    'your doctor or dietician sets any numbers that matter for you.';

/// The one quiet reference line by the ticks.
/// The day's reference for one need, as a short amount — "27 mg". For the
/// tick tiles (2026-09-22); the prose line stays for revert.
String pregnancyReferenceFor(String needId) => switch (needId) {
      'iron' => '${_n(kPregnancyDayReference.iron)} mg',
      'calcium' => '${_n(kPregnancyDayReference.calcium)} mg',
      'protein' => '${_n(kPregnancyDayReference.protein)} g',
      'folic_acid' => '${_n(kPregnancyDayReference.folate)} µg',
      _ => '${_n(kPregnancyDayReference.fibre)} g',
    };

String pregnancyReferenceLine() =>
    'A day in pregnancy asks for roughly ${_n(kPregnancyDayReference.protein)} g protein, '
    '${_n(kPregnancyDayReference.iron)} mg iron, ${_n(kPregnancyDayReference.calcium)} mg calcium and '
    '${_n(kPregnancyDayReference.fibre)} g fibre (ICMR-NIN). Food covers most of it; the tablet covers the rest.';
