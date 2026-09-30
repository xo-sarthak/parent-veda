// =============================================================================
//  TTC - the week of meals, as data the food-ideas tool can pick from
// -----------------------------------------------------------------------------
//  ⚠️ NOT NEW CONTENT. Every dish below is a bullet of the read "A week of
//  fertility-friendly Indian meals" (`ttc_read_meal_plan_week`, written by the
//  nutritionist in `lib/ttc/reads/ttc_reads_meal_plan.dart`), cut into a day,
//  a meal and a dish so the tool can show one day at a time. That read's own
//  next step already promised this: "Plan your own week - turn these ideas
//  into a day-by-day plan that fits your kitchen", and it opened a screen
//  that showed none of its meals.
//
//  `test/ttc_food_ideas_tool_test.dart` holds the two in step: every dish here
//  must be word for word a "Day N <meal>: ..." bullet of the read, and every
//  kitchen note must be a bullet or answer of it. Change the read and the test
//  names the dish that drifted; the tool can never quietly say something the
//  nutritionist did not write.
//
//  What is derived here, and only here:
//    · the plate tags (protein, whole grain, vegetables, vitamin C), set by
//      hand per dish from the read's own "How is each day put together?"
//      lists: protein = dal, curd, paneer, chana, sprouts, eggs (and their
//      cousins: besan, soya, milk, kadhi, peanuts); whole grain = roti, a
//      millet, brown or red rice, poha; vitamin C = lemon, tomato, amla,
//      guava, orange. Hand-set rather than keyword-matched because "rice"
//      is only a whole grain when the read says red or brown;
//    · which weekday is which plan day: Monday is day 1, and day 7 - "lighter
//      to cook, because most people want a slower day" - is Sunday;
//    · the eggless dish, composed from the read's swap sentence for that day.
//
//  English only, like the read (CLAUDE.md, "New work is English").
// =============================================================================

/// The four meals of a plan day, in the order she eats them.
enum TtcMealSlot { breakfast, lunch, evening, dinner }

extension TtcMealSlotName on TtcMealSlot {
  /// The label on the card.
  String get label => switch (this) {
        TtcMealSlot.breakfast => 'Breakfast',
        TtcMealSlot.lunch => 'Lunch',
        TtcMealSlot.evening => 'Evening snack',
        TtcMealSlot.dinner => 'Dinner',
      };

  /// The word the read uses in "Day 1 breakfast: ...". Identity, not display.
  String get readWord => switch (this) {
        TtcMealSlot.breakfast => 'breakfast',
        TtcMealSlot.lunch => 'lunch',
        TtcMealSlot.evening => 'evening',
        TtcMealSlot.dinner => 'dinner',
      };
}

/// What a dish puts on the plate, from the read's "three things on the
/// plate" plus the vitamin C that helps iron in.
enum TtcPlate { protein, grain, veg, vitC }

extension TtcPlateName on TtcPlate {
  String get label => switch (this) {
        TtcPlate.protein => 'Protein',
        TtcPlate.grain => 'Whole grain',
        TtcPlate.veg => 'Vegetables',
        TtcPlate.vitC => 'Vitamin C',
      };
}

/// Her kitchen. Picks the eggless dish and which notes show.
///
/// ⚠️ THE ENUM NAME IS PERSISTED (`kTtcFoodKitchenKey`). Rename a value and a
/// saved choice falls back to the default.
enum TtcKitchen { vegEggs, noEggs, jain, nonVeg }

extension TtcKitchenName on TtcKitchen {
  String get label => switch (this) {
        TtcKitchen.vegEggs => 'Veg with eggs',
        TtcKitchen.noEggs => 'Veg, no eggs',
        TtcKitchen.jain => 'Jain',
        TtcKitchen.nonVeg => 'Non-veg',
      };

  /// A Jain plate has no eggs either, so the eggless dish serves it too.
  bool get eggless => this == TtcKitchen.noEggs || this == TtcKitchen.jain;
}

/// One dish of the week.
class TtcPlanMeal {
  const TtcPlanMeal({
    required this.day,
    required this.slot,
    required this.dish,
    required this.gives,
    this.eggless,
    this.egglessGives,
    this.photoId,
  });

  /// 1 to 7, the read's day.
  final int day;
  final TtcMealSlot slot;

  /// The read's words after the colon, first letter raised.
  final String dish;
  final Set<TtcPlate> gives;

  /// The dish in a kitchen without eggs, from the read's eggless swap.
  final String? eggless;
  final Set<TtcPlate>? egglessGives;

  /// A photo id in read_images.dart when the dish-word matcher
  /// (`nutritionPhotoFor`) would land on the wrong picture or none.
  final String? photoId;

  String dishFor(TtcKitchen k) =>
      k.eggless && eggless != null ? eggless! : dish;

  Set<TtcPlate> givesFor(TtcKitchen k) =>
      k.eggless && egglessGives != null ? egglessGives! : gives;

  /// The read's bullet this dish came from, for the contract test.
  String get readBullet =>
      'Day $day ${slot.readWord}: ${dish[0].toLowerCase()}${dish.substring(1)}';
}

const _p = TtcPlate.protein;
const _g = TtcPlate.grain;
const _v = TtcPlate.veg;
const _c = TtcPlate.vitC;

/// The read's 28 dishes.
const List<TtcPlanMeal> kTtcPlanMeals = [
  // ---- Day 1 -----------------------------------------------------------------
  TtcPlanMeal(
      day: 1,
      slot: TtcMealSlot.breakfast,
      dish: 'Vegetable poha with peanuts, and a bowl of curd.',
      gives: {_p, _g, _v}),
  TtcPlanMeal(
      day: 1,
      slot: TtcMealSlot.lunch,
      dish: 'Palak dal, two rotis, and a cucumber and tomato salad with lemon.',
      gives: {_p, _g, _v, _c},
      // The food idea's own palak dal photo, not the generic dal (a soup).
      photoId: 'ttc_nutrition_folate_greens'),
  TtcPlanMeal(
      day: 1,
      slot: TtcMealSlot.evening,
      dish: 'Roasted chana and a guava or an orange.',
      gives: {_p, _c}),
  TtcPlanMeal(
      day: 1,
      slot: TtcMealSlot.dinner,
      dish: 'Rice, rajma and a mixed vegetable sabzi.',
      gives: {_p, _v}),
  // ---- Day 2 -----------------------------------------------------------------
  TtcPlanMeal(
      day: 2,
      slot: TtcMealSlot.breakfast,
      dish: 'Two besan chillas with grated vegetables, and mint chutney.',
      gives: {_p, _v}),
  TtcPlanMeal(
      day: 2,
      slot: TtcMealSlot.lunch,
      dish: 'Jowar or wheat roti, lauki chana dal, and curd.',
      gives: {_p, _g, _v},
      // A bowl of Indian dal; the generic `nut_dal` reads as a soup.
      photoId: 'nut_dal_rice'),
  TtcPlanMeal(
      day: 2,
      slot: TtcMealSlot.evening,
      dish: 'A small handful of walnuts or peanuts and two dates.',
      gives: {_p},
      // Mixed nuts with peanuts, not the matcher's hazelnuts.
      photoId: 'ttc_nutrition_coq10'),
  TtcPlanMeal(
      day: 2,
      slot: TtcMealSlot.dinner,
      dish: 'Moong dal khichdi with vegetables, a spoon of ghee, and '
          'kachumber.',
      gives: {_p, _v}),
  // ---- Day 3 -----------------------------------------------------------------
  TtcPlanMeal(
      day: 3,
      slot: TtcMealSlot.breakfast,
      dish: 'Ragi dosa, or ragi porridge made with milk, and a banana.',
      gives: {_g}),
  TtcPlanMeal(
      day: 3,
      slot: TtcMealSlot.lunch,
      dish: 'Chole with two rotis, and an onion and tomato salad with lemon.',
      gives: {_p, _g, _v, _c}),
  TtcPlanMeal(
      day: 3,
      slot: TtcMealSlot.evening,
      dish: 'Sprouted moong chaat with tomato and lemon.',
      gives: {_p, _c},
      // "sprouted" is not the matcher's "sprouts"; this is that photo.
      photoId: 'nut_sprouts'),
  TtcPlanMeal(
      day: 3,
      slot: TtcMealSlot.dinner,
      dish: 'Paneer and peas sabzi, rice and a bowl of dal.',
      gives: {_p, _v}),
  // ---- Day 4 -----------------------------------------------------------------
  TtcPlanMeal(
      day: 4,
      slot: TtcMealSlot.breakfast,
      dish: 'Egg bhurji with two multigrain rotis.',
      gives: {_p, _g},
      // "Egg bhurji on day 4 becomes paneer bhurji or tofu bhurji."
      eggless: 'Paneer bhurji or tofu bhurji with two multigrain rotis.',
      egglessGives: {_p, _g}),
  TtcPlanMeal(
      day: 4,
      slot: TtcMealSlot.lunch,
      dish: 'Bajra roti, methi aloo, and curd.',
      gives: {_p, _g, _v}),
  TtcPlanMeal(
      day: 4,
      slot: TtcMealSlot.evening,
      dish: 'Roasted makhana and a glass of buttermilk.',
      gives: {_p}),
  TtcPlanMeal(
      day: 4,
      slot: TtcMealSlot.dinner,
      dish: 'Vegetable pulao with soya chunks, and cucumber raita.',
      gives: {_p, _v}),
  // ---- Day 5 -----------------------------------------------------------------
  TtcPlanMeal(
      day: 5,
      slot: TtcMealSlot.breakfast,
      dish: 'Vegetable upma with peas, and a glass of milk.',
      gives: {_p, _v}),
  TtcPlanMeal(
      day: 5,
      slot: TtcMealSlot.lunch,
      dish: 'Sambar with red or brown rice, beans poriyal, and curd.',
      gives: {_p, _g, _v}),
  TtcPlanMeal(
      day: 5,
      slot: TtcMealSlot.evening,
      dish: 'Curd with chopped fruit and a spoon of ground flaxseed.',
      gives: {_p}),
  TtcPlanMeal(
      day: 5,
      slot: TtcMealSlot.dinner,
      dish: 'Two methi theplas, kadhi, and a vegetable.',
      gives: {_p, _g, _v}),
  // ---- Day 6 -----------------------------------------------------------------
  TtcPlanMeal(
      day: 6,
      slot: TtcMealSlot.breakfast,
      dish: 'A two-egg vegetable omelette with a multigrain roti.',
      gives: {_p, _g, _v},
      // "The omelette on day 6 becomes a moong dal chilla or a besan chilla
      // with paneer inside."
      eggless: 'A moong dal chilla, or a besan chilla with paneer inside, '
          'with a multigrain roti.',
      egglessGives: {_p, _g}),
  TtcPlanMeal(
      day: 6,
      slot: TtcMealSlot.lunch,
      dish: 'Lobia or rajma, rice, and a carrot and beetroot salad with lemon.',
      gives: {_p, _v, _c}),
  TtcPlanMeal(
      day: 6,
      slot: TtcMealSlot.evening,
      dish: 'An orange and a small handful of roasted peanuts.',
      gives: {_p, _c}),
  TtcPlanMeal(
      day: 6,
      slot: TtcMealSlot.dinner,
      dish: 'Paneer or tofu tikka with vegetables, two rotis, and dal.',
      gives: {_p, _g, _v},
      // A paneer tikka plate (the Can I...? paneer photo), not a block of
      // paneer.
      photoId: 'cani_paneer'),
  // ---- Day 7 -----------------------------------------------------------------
  TtcPlanMeal(
      day: 7,
      slot: TtcMealSlot.breakfast,
      dish: 'Dal paratha with curd.',
      gives: {_p, _g}),
  TtcPlanMeal(
      day: 7,
      slot: TtcMealSlot.lunch,
      dish: 'Curd rice, and a vegetable kootu or sabzi.',
      gives: {_p, _v}),
  TtcPlanMeal(
      day: 7,
      slot: TtcMealSlot.evening,
      dish: 'Two dates and a few almonds.',
      gives: {},
      photoId: 'nut_dates'),
  TtcPlanMeal(
      day: 7,
      slot: TtcMealSlot.dinner,
      dish: 'Palak paneer, two rotis, and a steamed sprout salad.',
      gives: {_p, _g, _v}),
];

/// The plan day a date falls on: Monday is day 1, Sunday day 7.
int ttcPlanDayFor(DateTime d) => d.weekday;

/// The plan's dish for a plan day and a meal.
TtcPlanMeal ttcPlanMeal(int day, TtcMealSlot slot) =>
    kTtcPlanMeals.firstWhere((m) => m.day == day && m.slot == slot);

/// Why this day looks the way it does: the read's own opening line for the
/// pair of days it sits in, verbatim.
String ttcPlanDayLine(int day) => switch (day) {
      1 || 2 => 'Start with dishes you probably make already. The one change '
          'on day 1 is adding protein to breakfast.',
      3 || 4 => 'Two millet meals come in here. Ragi and bajra carry more iron '
          "and calcium than white rice, and they're easy to rotate in.",
      5 || 6 => 'By now the pattern should feel familiar. These two days bring '
          "in south and west Indian dishes, so the week doesn't feel "
          'repetitive.',
      _ => 'Day 7 is lighter to cook, because most people want a slower day. '
          'Leftover dal becomes dal paratha. Leftover rice becomes curd rice '
          'with a tadka.',
    };

/// The read's one-line rule for the plate, over the meal cards.
const String kTtcPlateLine = 'Each main meal has three things on the plate: '
    'a protein, a whole grain and at least one vegetable. The tags show '
    'which.';

/// A Jain kitchen's swaps, the read's bullets word for word.
const List<String> kTtcJainSwaps = [
  'Use hing and a little dry ginger powder (sonth) in your tadka in place of '
      'onion, garlic and fresh ginger.',
  'Swap potatoes for raw banana, and carrot or beetroot for cabbage, '
      'capsicum or cucumber.',
  'Some Jain families avoid sprouts. Boiled whole moong or kala chana does '
      'the same job.',
  'Tomato, lemon, amla and guava still bring the vitamin C, so the iron '
      'pairing stays.',
  "If you don't eat after sunset, move the evening snack earlier and make "
      'lunch the bigger meal.',
];

/// The one Jain swap a dish needs, when it names the thing a Jain plate
/// leaves out. Null when the dish works as it is. Only the ingredients the
/// dish NAMES: a tadka's onion is covered by the kitchen note, not guessed.
String? ttcJainSwapFor(String dish) {
  final d = dish.toLowerCase();
  if (d.contains('aloo') || d.contains('potato')) return kTtcJainSwaps[1];
  if (d.contains('carrot') || d.contains('beetroot')) return kTtcJainSwaps[1];
  if (d.contains('sprout')) return kTtcJainSwaps[2];
  // Not onion: the read's onion rule is about the tadka, and the one dish
  // that names onion names it raw in a salad, where the rule does not fit.
  return null;
}

/// A non-veg kitchen's note: the read's answer to "We eat chicken and fish at
/// home. Can I still use this?", word for word.
const String kTtcNonVegNote = 'Swap a dal or paneer dish for chicken, fish or '
    'eggs whenever you like, and cook them all the way through. Fish like '
    'sardines, mackerel, rohu or pomfret are good choices. Skip large fish '
    'like shark and swordfish.';

/// The read the week comes from, to open for the full plan and the shopping
/// list.
const String kTtcMealPlanReadId = 'ttc_read_meal_plan_week';
