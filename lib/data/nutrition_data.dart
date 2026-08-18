// =============================================================================
//  Nutrition — data models + seeded content
// -----------------------------------------------------------------------------
//  Everything in this section is FREE. There is no locked verdict, no locked
//  chart, no locked recipe — the only thing money buys anywhere in Nutrition is
//  a human being (a dietician's time). See `ExpertOptionsBlock` in
//  `nutrition_stage_screen.dart` for the one paid surface, and read the header
//  there for where it is allowed to appear.
//
//  `_en` mirrors the house pattern from `pregnancy_journeys.dart`: this section
//  is authored English-only for now. Hindi is owed, not decided against — when
//  it is written it replaces the `hi:` side of these calls, nothing else moves.
//
//  Verdicts here are a THREE-state tag (SAFE / LIMIT / AVOID), deliberately
//  simpler than `CanIVerdict`'s five states in `can_i_entry.dart`. Can I?
//  answers a single sharp question with room for "depends" and "ask your
//  doctor"; a food verdict on this screen wants one calm word a mother can read
//  in a second, with the nuance carried in the two or three lines beneath it
//  rather than in a sixth tag. LIMIT is doing double duty for "depends" and
//  "in moderation" on purpose — the difference lives in `limitGuidance`.
// =============================================================================

import '../localization/app_language.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// =============================================================================
//  1. Can I eat this? — food verdicts
// =============================================================================

enum NutritionVerdict { safe, limit, avoid }

enum FoodCategory {
  fruits,
  dairyProtein,
  nonVeg,
  drinks,
  spicesHeat,
  sweet,
  outsidePackaged,
  grains,
}

extension FoodCategoryMeta on FoodCategory {
  LocalizedText get label => switch (this) {
        FoodCategory.fruits => _en('Fruits'),
        FoodCategory.dairyProtein => _en('Dairy & protein'),
        FoodCategory.nonVeg => _en('Non-veg'),
        FoodCategory.drinks => _en('Drinks'),
        FoodCategory.spicesHeat => _en('Spices & heat'),
        FoodCategory.sweet => _en('Sweet'),
        FoodCategory.outsidePackaged => _en('Outside & packaged'),
        FoodCategory.grains => _en('Grains'),
      };
}

extension NutritionVerdictMeta on NutritionVerdict {
  LocalizedText get label => switch (this) {
        NutritionVerdict.safe => _en('Safe'),
        NutritionVerdict.limit => _en('Limit'),
        NutritionVerdict.avoid => _en('Avoid'),
      };
}

class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.verdict,
    required this.lines,
    this.myth,
    this.limitGuidance,
    this.related = const [],
    this.aliases = const [],
  });

  final String id;
  final LocalizedText name;
  final FoodCategory category;
  final NutritionVerdict verdict;

  /// 2-3 plain lines: what's true, and why. Not a bullet list — read as prose.
  final LocalizedText lines;

  /// Shown only where a real myth exists (papaya, pineapple, methi...).
  final LocalizedText? myth;

  /// Shown only when [verdict] is [NutritionVerdict.limit] — how much is fine.
  final LocalizedText? limitGuidance;

  final List<String> related;
  final List<String> aliases;
}

FoodEntry? foodById(String id) {
  for (final f in kFoodEntries) {
    if (f.id == id) return f;
  }
  return null;
}

List<FoodEntry> foodsByCategory(FoodCategory c) =>
    kFoodEntries.where((f) => f.category == c).toList();

List<FoodEntry> searchFoods(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return kFoodEntries.where((f) {
    if (f.name.en.toLowerCase().contains(q)) return true;
    if (f.name.hi.toLowerCase().contains(q)) return true;
    for (final a in f.aliases) {
      if (a.toLowerCase().contains(q)) return true;
    }
    return false;
  }).toList();
}

/// Most-searched chips on the Can I eat this? landing.
const List<({String emoji, String id})> kMostSearchedFoods = [
  (emoji: '🍈', id: 'papaya'),
  (emoji: '🍍', id: 'pineapple'),
  (emoji: '☕', id: 'coffee'),
  (emoji: '🥛', id: 'curd_yogurt'),
  (emoji: '🍗', id: 'chicken'),
  (emoji: '🥥', id: 'coconut_water'),
  (emoji: '🧈', id: 'ghee'),
  (emoji: '🥭', id: 'mango'),
];

final List<FoodEntry> kFoodEntries = [
  // ---------------------------------------------------------------------
  //  Fruits
  // ---------------------------------------------------------------------
  FoodEntry(
    id: 'papaya',
    name: _en('Papaya'),
    category: FoodCategory.fruits,
    verdict: NutritionVerdict.limit,
    lines: _en('Fully ripe papaya, eaten as fruit, is nutritious and fine. '
        'Raw or semi-ripe papaya carries more latex, which is traditionally '
        'avoided in pregnancy, so it is worth steering clear of.'),
    myth: _en('"One bite of papaya and you will miscarry" is not true. The '
        'caution is specific to the unripe fruit, not the sweet, orange kind '
        'on your fruit plate.'),
    limitGuidance: _en('A bowl of ripe, sweet papaya is fine any day. Skip it '
        'raw or half-ripe, and skip it in salads or sabzis where you cannot '
        'tell how ripe it was.'),
    related: ['pineapple', 'mango', 'street_food_chaat'],
    aliases: ['papita', 'raw papaya', 'ripe papaya'],
  ),
  FoodEntry(
    id: 'pineapple',
    name: _en('Pineapple'),
    category: FoodCategory.fruits,
    verdict: NutritionVerdict.limit,
    lines: _en('Pineapple in a normal serving is fine through pregnancy. It '
        'contains an enzyme called bromelain, but a slice or two carries far '
        'too little of it to matter.'),
    myth: _en('Pineapple is often blamed for starting labour. You would need '
        'to eat an unrealistic amount, all at once, for bromelain to do '
        'anything at all. A few slices will not bring on contractions.'),
    limitGuidance: _en('A cup of pineapple or a glass of fresh juice is fine '
        'daily. There is no need to avoid it out of caution.'),
    related: ['papaya', 'mango', 'guava'],
    aliases: ['ananas'],
  ),
  FoodEntry(
    id: 'mango',
    name: _en('Mango'),
    category: FoodCategory.fruits,
    verdict: NutritionVerdict.safe,
    lines: _en('Mango is rich in vitamin A, vitamin C and folate, and safe to '
        'enjoy through pregnancy. It is also naturally high in sugar, so keep '
        'portions sensible, especially if your doctor is watching your blood '
        'sugar.'),
    related: ['pineapple', 'banana', 'jaggery_gud'],
    aliases: ['aam'],
  ),
  FoodEntry(
    id: 'banana',
    name: _en('Banana'),
    category: FoodCategory.fruits,
    verdict: NutritionVerdict.safe,
    lines: _en('A simple, reliable pregnancy snack. Bananas give quick '
        'energy and potassium, can settle early nausea, and help with '
        'constipation, which makes them worth keeping around.'),
    related: ['curd_yogurt', 'dates', 'oats'],
    aliases: ['kela'],
  ),
  FoodEntry(
    id: 'grapes',
    name: _en('Grapes'),
    category: FoodCategory.fruits,
    verdict: NutritionVerdict.safe,
    lines: _en('Grapes are safe in pregnancy. Wash them well before eating, '
        'the way you would any fruit eaten with the skin on, and there is no '
        'need to avoid them.'),
    related: ['apple', 'pomegranate', 'watermelon'],
    aliases: ['angoor'],
  ),
  FoodEntry(
    id: 'watermelon',
    name: _en('Watermelon'),
    category: FoodCategory.fruits,
    verdict: NutritionVerdict.safe,
    lines: _en('A hydrating, cooling fruit that is genuinely useful in the '
        'later months when swelling and heat can be uncomfortable. Safe '
        'through pregnancy in normal amounts.'),
    related: ['coconut_water', 'grapes', 'buttermilk_chaas'],
    aliases: ['tarbooz'],
  ),
  FoodEntry(
    id: 'pomegranate',
    name: _en('Pomegranate'),
    category: FoodCategory.fruits,
    verdict: NutritionVerdict.safe,
    lines: _en('Pomegranate is safe and a good source of vitamin C, which '
        'helps your body absorb iron from the rest of your meal, one reason '
        'it is often paired with iron-rich food.'),
    related: ['guava', 'dates', 'jaggery_gud'],
    aliases: ['anaar'],
  ),
  FoodEntry(
    id: 'guava',
    name: _en('Guava'),
    category: FoodCategory.fruits,
    verdict: NutritionVerdict.safe,
    lines: _en('Guava is safe, high in vitamin C and fibre, and a good '
        'everyday fruit choice. Wash it well since it is usually eaten with '
        'the skin on.'),
    related: ['pomegranate', 'apple', 'grapes'],
    aliases: ['amrud', 'peru'],
  ),
  FoodEntry(
    id: 'apple',
    name: _en('Apple'),
    category: FoodCategory.fruits,
    verdict: NutritionVerdict.safe,
    lines: _en('An easy, safe, everyday fruit. Apples give fibre and steady '
        'energy without much fuss, and there is no reason to limit them.'),
    related: ['guava', 'banana', 'grapes'],
    aliases: ['seb'],
  ),
  FoodEntry(
    id: 'dates',
    name: _en('Dates'),
    category: FoodCategory.fruits,
    verdict: NutritionVerdict.safe,
    lines: _en('Dates are safe through pregnancy and a traditional food for '
        'the later weeks, valued for iron and natural sugar. A few a day is '
        'a fine habit, not just a third-trimester ritual.'),
    related: ['jaggery_gud', 'banana', 'raw_sprouts'],
    aliases: ['khajoor'],
  ),

  // ---------------------------------------------------------------------
  //  Dairy & protein
  // ---------------------------------------------------------------------
  FoodEntry(
    id: 'milk',
    name: _en('Milk'),
    category: FoodCategory.dairyProtein,
    verdict: NutritionVerdict.safe,
    lines: _en('Pasteurised milk, boiled or packaged, is safe and a useful '
        'everyday source of calcium and protein. Unpasteurised or raw milk '
        'straight from an animal is the thing to avoid, not milk itself.'),
    related: ['curd_yogurt', 'paneer', 'ghee'],
    aliases: ['doodh'],
  ),
  FoodEntry(
    id: 'curd_yogurt',
    name: _en('Curd / Yoghurt'),
    category: FoodCategory.dairyProtein,
    verdict: NutritionVerdict.safe,
    lines: _en('Curd made from pasteurised milk is safe and genuinely good '
        'for you, a reliable source of calcium and protein whose probiotics '
        'can help digestion too. Home-set or packaged dahi both work.'),
    related: ['paneer', 'milk', 'buttermilk_chaas'],
    aliases: ['dahi', 'yogurt'],
  ),
  FoodEntry(
    id: 'paneer',
    name: _en('Paneer'),
    category: FoodCategory.dairyProtein,
    verdict: NutritionVerdict.safe,
    lines: _en('Paneer made from pasteurised milk, whether fresh or cooked '
        'into a curry, is safe through pregnancy and a good vegetarian '
        'protein source. Most branded and home-made paneer already uses '
        'pasteurised milk.'),
    limitGuidance: _en('If you are ever unsure where a paneer came from, '
        'cook it, palak paneer or paneer bhurji, rather than eating it raw.'),
    related: ['curd_yogurt', 'soft_cheese', 'milk'],
    aliases: ['cottage cheese'],
  ),
  FoodEntry(
    id: 'soft_cheese',
    name: _en('Soft, unpasteurised cheese'),
    category: FoodCategory.dairyProtein,
    verdict: NutritionVerdict.avoid,
    lines: _en('Soft cheeses made from unpasteurised milk, brie, camembert '
        'and similar imported cheeses, can carry listeria, a bacteria that '
        'is more dangerous in pregnancy than in everyday life. This does not '
        'include paneer or most Indian dairy, which use pasteurised milk.'),
    related: ['paneer', 'milk', 'curd_yogurt'],
    aliases: ['brie', 'camembert', 'unpasteurised cheese'],
  ),
  FoodEntry(
    id: 'eggs',
    name: _en('Eggs'),
    category: FoodCategory.dairyProtein,
    verdict: NutritionVerdict.safe,
    lines: _en('Fully cooked eggs, boiled, fried firm or scrambled through, '
        'are a safe and excellent protein source in pregnancy. Runny or raw '
        'egg, as in some homemade mayonnaise or a soft-boiled yolk, is what '
        'is worth cooking through instead.'),
    related: ['chicken', 'peanuts', 'dal_lentils'],
    aliases: ['anda'],
  ),
  FoodEntry(
    id: 'dal_lentils',
    name: _en('Dal / lentils'),
    category: FoodCategory.dairyProtein,
    verdict: NutritionVerdict.safe,
    lines: _en('Dal is a pregnancy staple for good reason: it is safe, and a '
        'strong everyday source of protein, fibre and iron. There is no need '
        'to limit it.'),
    related: ['dal_lentils', 'paneer', 'peanuts'],
    aliases: ['lentils', 'daal'],
  ),
  FoodEntry(
    id: 'tofu_soy',
    name: _en('Tofu / soy'),
    category: FoodCategory.dairyProtein,
    verdict: NutritionVerdict.limit,
    lines: _en('Tofu and soy foods are a reasonable vegetarian protein '
        'source, safe in normal food amounts. Very heavy daily soy intake, '
        'well beyond what most people eat, is the only thing worth going '
        'easy on.'),
    limitGuidance: _en('A few servings a week as part of a varied diet is '
        'fine. There is no need to avoid soy, only to not make it the whole '
        'diet.'),
    related: ['paneer', 'dal_lentils', 'peanuts'],
    aliases: ['soya', 'soybean'],
  ),
  FoodEntry(
    id: 'peanuts',
    name: _en('Peanuts'),
    category: FoodCategory.dairyProtein,
    verdict: NutritionVerdict.safe,
    lines: _en('Peanuts and peanut products are safe to eat in pregnancy '
        'unless you have a known peanut allergy yourself. They are a good, '
        'cheap protein source.'),
    myth: _en('Mothers used to be told to avoid peanuts to prevent an '
        'allergy in the baby. That advice has been reversed. Current '
        'guidance does not ask you to avoid peanuts unless you are allergic '
        'to them.'),
    related: ['dal_lentils', 'tofu_soy', 'eggs'],
    aliases: ['moongfali', 'groundnut'],
  ),

  // ---------------------------------------------------------------------
  //  Non-veg
  // ---------------------------------------------------------------------
  FoodEntry(
    id: 'chicken',
    name: _en('Chicken'),
    category: FoodCategory.nonVeg,
    verdict: NutritionVerdict.safe,
    lines: _en('Chicken cooked all the way through is safe and a good '
        'protein source. The thing to watch is doneness, not the meat '
        'itself: no pink in the middle, and juices should run clear.'),
    related: ['mutton', 'eggs', 'fish_general'],
    aliases: ['murgi', 'meat'],
  ),
  FoodEntry(
    id: 'mutton',
    name: _en('Mutton'),
    category: FoodCategory.nonVeg,
    verdict: NutritionVerdict.safe,
    lines: _en('Mutton, well cooked, is safe and a good source of iron and '
        'protein. It also carries more fat than chicken, so a moderate '
        'portion in a curry sits better than a heavy, oily preparation every '
        'day.'),
    related: ['chicken', 'liver_organ_meat', 'processed_meat_bacon'],
    aliases: ['goat meat', 'lamb'],
  ),
  FoodEntry(
    id: 'fish_general',
    name: _en('Fish (everyday varieties)'),
    category: FoodCategory.nonVeg,
    verdict: NutritionVerdict.limit,
    lines: _en('Well-cooked fish is genuinely good for you and the baby, a '
        'strong source of protein and omega-3. The one thing worth managing '
        'is mercury, which builds up more in some large, long-living fish '
        'than others.'),
    limitGuidance: _en('Two to three servings a week of everyday fish, rohu, '
        'katla, sardines, pomfret, salmon, is a good target. Choose smaller, '
        'younger fish where you have a choice, and cook fish through rather '
        'than eating it rare.'),
    related: ['king_fish_shark', 'prawns_shrimp', 'sushi_raw_fish'],
    aliases: ['machli', 'rohu', 'katla', 'salmon', 'pomfret'],
  ),
  FoodEntry(
    id: 'king_fish_shark',
    name: _en('King fish, shark, swordfish'),
    category: FoodCategory.nonVeg,
    verdict: NutritionVerdict.avoid,
    lines: _en('These are large, long-living fish that accumulate the most '
        'mercury, which can affect a developing nervous system if eaten '
        'often. This is a mercury note, not a fish note, everyday fish like '
        'rohu and pomfret do not carry the same risk.'),
    related: ['fish_general', 'sushi_raw_fish', 'prawns_shrimp'],
    aliases: ['surmai', 'shark', 'swordfish', 'king mackerel'],
  ),
  FoodEntry(
    id: 'prawns_shrimp',
    name: _en('Prawns / shrimp'),
    category: FoodCategory.nonVeg,
    verdict: NutritionVerdict.safe,
    lines: _en('Prawns and shrimp, cooked through, are safe and low in '
        'mercury compared to larger fish. A normal, well-cooked serving is '
        'fine.'),
    related: ['fish_general', 'sushi_raw_fish', 'chicken'],
    aliases: ['jhinga', 'shrimp'],
  ),
  FoodEntry(
    id: 'liver_organ_meat',
    name: _en('Liver / organ meat'),
    category: FoodCategory.nonVeg,
    verdict: NutritionVerdict.limit,
    lines: _en('Liver is extremely rich in vitamin A, useful in small '
        'amounts but easy to overdo, and very high vitamin A intake is '
        'linked with harm in pregnancy. This is about frequency, not a full '
        'ban.'),
    limitGuidance: _en('An occasional serving, not a weekly habit, is the '
        'safer way to enjoy liver in pregnancy.'),
    related: ['mutton', 'chicken', 'dal_lentils'],
    aliases: ['kaleji'],
  ),
  FoodEntry(
    id: 'sushi_raw_fish',
    name: _en('Sushi / raw fish'),
    category: FoodCategory.nonVeg,
    verdict: NutritionVerdict.avoid,
    lines: _en('Raw or undercooked fish carries a higher risk of parasites '
        'and bacteria than cooked fish, a risk pregnancy makes worth '
        'avoiding. Cooked sushi rolls are fine; raw fish sushi is the part '
        'to skip for now.'),
    related: ['fish_general', 'king_fish_shark', 'prawns_shrimp'],
    aliases: ['sashimi', 'raw fish'],
  ),
  FoodEntry(
    id: 'processed_meat_bacon',
    name: _en('Processed / cured meat'),
    category: FoodCategory.nonVeg,
    verdict: NutritionVerdict.limit,
    lines: _en('Bacon, sausages, salami and similar cured meats are fine '
        'occasionally, cooked hot and through. Eating them cold, straight '
        'from the pack, carries the same listeria concern as unpasteurised '
        'dairy.'),
    limitGuidance: _en('Cook it hot before eating, and keep it occasional '
        'rather than a daily habit.'),
    related: ['mutton', 'liver_organ_meat', 'canned_food'],
    aliases: ['bacon', 'sausage', 'salami', 'cured meat'],
  ),

  // ---------------------------------------------------------------------
  //  Drinks
  // ---------------------------------------------------------------------
  FoodEntry(
    id: 'coffee',
    name: _en('Coffee'),
    category: FoodCategory.drinks,
    verdict: NutritionVerdict.limit,
    lines: _en('Coffee is fine in moderate amounts. Caffeine crosses to the '
        'baby, so the usual guidance is to keep total caffeine, from all '
        'sources, under about 200mg a day, roughly one to two cups.'),
    limitGuidance: _en('One or two regular cups of coffee a day is the '
        'generally accepted limit. Remember tea, chocolate and cola also '
        'count toward the same total.'),
    related: ['tea_chai', 'green_tea', 'chocolate'],
    aliases: ['caffeine'],
  ),
  FoodEntry(
    id: 'tea_chai',
    name: _en('Tea / chai'),
    category: FoodCategory.drinks,
    verdict: NutritionVerdict.safe,
    lines: _en('A cup or two of regular chai a day is fine and counts toward '
        'the same daily caffeine allowance as coffee. There is no need to '
        'give it up, just to be mindful of how many caffeinated drinks add '
        'up across the day.'),
    related: ['coffee', 'green_tea', 'herbal_tea'],
    aliases: ['chai'],
  ),
  FoodEntry(
    id: 'green_tea',
    name: _en('Green tea'),
    category: FoodCategory.drinks,
    verdict: NutritionVerdict.limit,
    lines: _en('Green tea is fine in moderation. It carries caffeine like '
        'other tea, and in larger amounts can interfere with folate '
        'absorption, which matters more than usual in pregnancy.'),
    limitGuidance: _en('A cup a day is reasonable. It is not a good '
        'replacement for water through the rest of the day.'),
    related: ['tea_chai', 'coffee', 'herbal_tea'],
    aliases: [],
  ),
  FoodEntry(
    id: 'coconut_water',
    name: _en('Coconut water'),
    category: FoodCategory.drinks,
    verdict: NutritionVerdict.safe,
    lines: _en('Coconut water is safe, hydrating and a good source of '
        'natural electrolytes, genuinely useful in the heat or with mild '
        'nausea. Fresh is best; check a packaged one has no added sugar you '
        'were not expecting.'),
    related: ['watermelon', 'buttermilk_chaas', 'fresh_fruit_juice'],
    aliases: ['nariyal pani'],
  ),
  FoodEntry(
    id: 'buttermilk_chaas',
    name: _en('Buttermilk / chaas'),
    category: FoodCategory.drinks,
    verdict: NutritionVerdict.safe,
    lines: _en('Chaas made at home from pasteurised curd is safe, cooling '
        'and easy on digestion, a good everyday drink through pregnancy.'),
    related: ['curd_yogurt', 'coconut_water', 'watermelon'],
    aliases: ['chaas', 'lassi'],
  ),
  FoodEntry(
    id: 'fresh_fruit_juice',
    name: _en('Fresh fruit juice'),
    category: FoodCategory.drinks,
    verdict: NutritionVerdict.limit,
    lines: _en('Fresh juice made and drunk at home is fine. The concern is '
        'hygiene with street-vended juice, where fruit and ice may not be '
        'handled as carefully, and sugar content when juice replaces whole '
        'fruit too often.'),
    limitGuidance: _en('Home-made or a trusted, hygienic source is best. '
        'Whole fruit is still the better everyday choice; keep juice '
        'occasional.'),
    related: ['sugarcane_juice', 'coconut_water', 'mango'],
    aliases: ['juice'],
  ),
  FoodEntry(
    id: 'herbal_tea',
    name: _en('Herbal tea'),
    category: FoodCategory.drinks,
    verdict: NutritionVerdict.limit,
    lines: _en('Common herbal teas, ginger or chamomile in moderate amounts, '
        'are generally considered fine. "Herbal" is not automatically safe '
        'though; some detox or weight-loss blends contain herbs not tested '
        'for pregnancy.'),
    limitGuidance: _en('Stick to well-known, food-grade teas in moderate '
        'amounts, and check with your doctor before trying an unfamiliar '
        'herbal blend.'),
    related: ['tea_chai', 'green_tea', 'ginger_adrak'],
    aliases: [],
  ),
  FoodEntry(
    id: 'alcohol',
    name: _en('Alcohol'),
    category: FoodCategory.drinks,
    verdict: NutritionVerdict.avoid,
    lines: _en('There is no amount of alcohol known to be safe in pregnancy, '
        'so the straightforward guidance is to avoid it completely, at any '
        'stage, in any amount.'),
    related: ['soda_energy_drinks', 'coffee', 'herbal_tea'],
    aliases: ['wine', 'beer', 'drinking'],
  ),
  FoodEntry(
    id: 'soda_energy_drinks',
    name: _en('Soda / energy drinks'),
    category: FoodCategory.drinks,
    verdict: NutritionVerdict.avoid,
    lines: _en('Energy drinks carry high caffeine and ingredients not tested '
        'for pregnancy, so they are best avoided outright. Regular soda is '
        'not dangerous, but is mostly sugar with nothing your body needs, '
        'so it is worth keeping occasional at most.'),
    related: ['coffee', 'alcohol', 'packaged_chips_namkeen'],
    aliases: ['cola', 'energy drink', 'soft drink'],
  ),
  FoodEntry(
    id: 'sugarcane_juice',
    name: _en('Sugarcane juice'),
    category: FoodCategory.drinks,
    verdict: NutritionVerdict.limit,
    lines: _en('Sugarcane juice from a busy street cart carries the same '
        'hygiene concerns as street-vended juice generally, and it is very '
        'high in sugar. An occasional glass from a clean, trusted source is '
        'reasonable.'),
    limitGuidance: _en('Keep it occasional, and choose a stall you would '
        'trust for any food, not just this drink.'),
    related: ['fresh_fruit_juice', 'street_food_chaat', 'jaggery_gud'],
    aliases: ['ganne ka ras'],
  ),

  // ---------------------------------------------------------------------
  //  Spices & heat
  // ---------------------------------------------------------------------
  FoodEntry(
    id: 'ghee',
    name: _en('Ghee'),
    category: FoodCategory.spicesHeat,
    verdict: NutritionVerdict.safe,
    lines: _en('A spoon of ghee in your dal or roti is a safe, traditional '
        'part of an Indian pregnancy diet, and gives useful calories and fat '
        'soluble vitamins. Moderation is the only real rule, as with any fat.'),
    related: ['milk', 'jaggery_gud', 'dal_lentils'],
    aliases: ['clarified butter'],
  ),
  FoodEntry(
    id: 'turmeric_haldi',
    name: _en('Turmeric / haldi'),
    category: FoodCategory.spicesHeat,
    verdict: NutritionVerdict.safe,
    lines: _en('Turmeric used as a cooking spice, in your sabzi or dal, is '
        'safe through pregnancy. The caution some people mention is about '
        'concentrated turmeric supplements taken in large doses, not the '
        'spoon of haldi in your kitchen.'),
    related: ['ginger_adrak', 'garlic_lehsun', 'hing_asafoetida'],
    aliases: ['haldi'],
  ),
  FoodEntry(
    id: 'ginger_adrak',
    name: _en('Ginger / adrak'),
    category: FoodCategory.spicesHeat,
    verdict: NutritionVerdict.safe,
    lines: _en('Ginger in food and in tea, in normal amounts, is safe and '
        'genuinely helpful for nausea, which is why it turns up in so much '
        'first-trimester advice.'),
    related: ['herbal_tea', 'tea_chai', 'turmeric_haldi'],
    aliases: ['adrak'],
  ),
  FoodEntry(
    id: 'garlic_lehsun',
    name: _en('Garlic / lehsun'),
    category: FoodCategory.spicesHeat,
    verdict: NutritionVerdict.safe,
    lines: _en('Garlic used as a cooking ingredient is safe through '
        'pregnancy. Garlic supplements in concentrated pill form are a '
        'separate thing and worth checking with your doctor before starting, '
        'but garlic in your food is not a concern.'),
    related: ['ginger_adrak', 'turmeric_haldi', 'hing_asafoetida'],
    aliases: ['lehsun'],
  ),
  FoodEntry(
    id: 'methi_fenugreek_seeds',
    name: _en('Methi / fenugreek seeds'),
    category: FoodCategory.spicesHeat,
    verdict: NutritionVerdict.limit,
    lines: _en('Methi used as a cooking spice, in a sabzi or paratha, is '
        'fine. Fenugreek in concentrated, medicinal doses is traditionally '
        'linked with uterine contractions, which is where the caution comes '
        'from.'),
    myth: _en('This is often stretched into "no methi at all in pregnancy." '
        'The concern is about concentrated seed doses or supplements, not '
        'the pinch of methi in your everyday cooking.'),
    limitGuidance: _en('Ordinary cooking amounts are fine. Skip fenugreek '
        'supplements or large medicinal doses unless your doctor suggests '
        'them.'),
    related: ['ajwain_carom_seeds', 'ginger_adrak', 'turmeric_haldi'],
    aliases: ['fenugreek', 'methi'],
  ),
  FoodEntry(
    id: 'hing_asafoetida',
    name: _en('Hing / asafoetida'),
    category: FoodCategory.spicesHeat,
    verdict: NutritionVerdict.safe,
    lines: _en('The pinch of hing used in everyday tadka is safe in '
        'pregnancy, and is traditionally valued for easing digestion and '
        'gas.'),
    related: ['ajwain_carom_seeds', 'ginger_adrak', 'dal_lentils'],
    aliases: ['asafoetida'],
  ),
  FoodEntry(
    id: 'ajwain_carom_seeds',
    name: _en('Ajwain / carom seeds'),
    category: FoodCategory.spicesHeat,
    verdict: NutritionVerdict.limit,
    lines: _en('Ajwain used as a cooking spice is fine. Like methi, the '
        'traditional caution is about large, concentrated doses taken as a '
        'home remedy, not the amount in your food.'),
    limitGuidance: _en('Cooking amounts are fine. Avoid ajwain water or '
        'concentrated remedies in large quantities without checking with '
        'your doctor first.'),
    related: ['methi_fenugreek_seeds', 'hing_asafoetida', 'ginger_adrak'],
    aliases: ['carom seeds'],
  ),

  // ---------------------------------------------------------------------
  //  Sweet
  // ---------------------------------------------------------------------
  FoodEntry(
    id: 'jaggery_gud',
    name: _en('Jaggery / gud'),
    category: FoodCategory.sweet,
    verdict: NutritionVerdict.safe,
    lines: _en('Gud is a safe, traditional sweetener that carries a little '
        'iron along with its sugar, a small but real reason it is often '
        'preferred over refined sugar in pregnancy.'),
    related: ['dates', 'ghee', 'chocolate'],
    aliases: ['gud', 'jaggery'],
  ),
  FoodEntry(
    id: 'chocolate',
    name: _en('Chocolate'),
    category: FoodCategory.sweet,
    verdict: NutritionVerdict.limit,
    lines: _en('Chocolate in moderate amounts is fine. It contains caffeine, '
        'more in dark chocolate than milk chocolate, which counts toward '
        'your daily caffeine total alongside tea and coffee.'),
    limitGuidance: _en('A square or two is a fine everyday treat. Keep it in '
        'mind if you are also having coffee and tea the same day.'),
    related: ['coffee', 'ice_cream', 'mithai_sweets'],
    aliases: [],
  ),
  FoodEntry(
    id: 'ice_cream',
    name: _en('Ice cream'),
    category: FoodCategory.sweet,
    verdict: NutritionVerdict.limit,
    lines: _en('Branded, properly stored ice cream is fine occasionally. '
        'Street kulfi or ice cream from an uncertain source carries the same '
        'hygiene and pasteurisation questions as any dairy of unknown '
        'origin.'),
    limitGuidance: _en('Stick to a trusted, branded source, and keep it an '
        'occasional treat rather than a daily habit.'),
    related: ['milk', 'chocolate', 'mithai_sweets'],
    aliases: ['kulfi'],
  ),
  FoodEntry(
    id: 'mithai_sweets',
    name: _en('Mithai / sweets'),
    category: FoodCategory.sweet,
    verdict: NutritionVerdict.limit,
    lines: _en('Mithai from a trusted, clean sweet shop is fine to enjoy '
        'occasionally, festival or not. The concerns are sugar quantity and, '
        'with looser sweets, how carefully the milk and khoya were handled.'),
    limitGuidance: _en('Enjoy it for the occasion, from a source you trust, '
        'rather than as an everyday habit.'),
    related: ['jaggery_gud', 'ice_cream', 'chocolate'],
    aliases: ['sweets', 'mithai'],
  ),
  FoodEntry(
    id: 'honey_shahad',
    name: _en('Honey'),
    category: FoodCategory.sweet,
    verdict: NutritionVerdict.safe,
    lines: _en('Honey is safe for you to eat in pregnancy. The well-known '
        'caution about honey is for babies under one year old, not for a '
        'pregnant mother, so this is one myth worth putting down.'),
    myth: _en('Honey being unsafe in pregnancy confuses a real rule that '
        'applies to infants under one, with pregnancy itself, where it does '
        'not apply.'),
    related: ['jaggery_gud', 'ghee', 'chocolate'],
    aliases: ['shahad'],
  ),
  FoodEntry(
    id: 'artificial_sweeteners',
    name: _en('Artificial sweeteners'),
    category: FoodCategory.sweet,
    verdict: NutritionVerdict.limit,
    lines: _en('Most common approved sweeteners are considered fine in '
        'moderate amounts in pregnancy. Saccharin is the one older sweetener '
        'usually advised against, since it can cross to the baby and is not '
        'well studied for this use.'),
    limitGuidance: _en('Moderate use of common sweeteners is fine. Check the '
        'label if you are unsure which sweetener a product uses.'),
    related: ['soda_energy_drinks', 'chocolate', 'mithai_sweets'],
    aliases: ['sweetener', 'sugar substitute'],
  ),

  // ---------------------------------------------------------------------
  //  Outside & packaged
  // ---------------------------------------------------------------------
  FoodEntry(
    id: 'street_food_chaat',
    name: _en('Street food / chaat'),
    category: FoodCategory.outsidePackaged,
    verdict: NutritionVerdict.limit,
    lines: _en('The concern with street food is hygiene, how the ingredients '
        'were stored and what water went into the chutneys, not the food '
        'itself. Freshly cooked, hot food from a busy, clean-looking stall is '
        'lower risk than anything raw or sitting out.'),
    limitGuidance: _en('Choose hot, freshly cooked food over anything raw or '
        'pre-mixed, and be more cautious about the source of any water or '
        'ice used.'),
    related: ['pani_puri_golgappe', 'restaurant_food', 'sugarcane_juice'],
    aliases: ['chaat', 'gol gappe'],
  ),
  FoodEntry(
    id: 'pani_puri_golgappe',
    name: _en('Pani puri / gol gappe'),
    category: FoodCategory.outsidePackaged,
    verdict: NutritionVerdict.avoid,
    lines: _en('The main risk here is the water used in the pani, which is '
        'rarely boiled or filtered at a street stall, and can carry bacteria '
        'that cause stomach infections, a bigger deal in pregnancy than '
        'usual. This is really a water-hygiene issue, not the puri itself.'),
    limitGuidance: _en('If you cannot resist, a home-made version with '
        'boiled or filtered water is the safer way to have it.'),
    related: ['street_food_chaat', 'fresh_fruit_juice', 'sugarcane_juice'],
    aliases: ['golgappe', 'puchka'],
  ),
  FoodEntry(
    id: 'packaged_chips_namkeen',
    name: _en('Packaged chips / namkeen'),
    category: FoodCategory.outsidePackaged,
    verdict: NutritionVerdict.limit,
    lines: _en('An occasional packet is not harmful. These are high in salt '
        'and low in anything your body needs, so the concern is a diet built '
        'around them, not one packet.'),
    limitGuidance: _en('Fine occasionally. Try not to let them replace an '
        'actual meal.'),
    related: ['instant_noodles', 'soda_energy_drinks', 'canned_food'],
    aliases: ['namkeen', 'chips'],
  ),
  FoodEntry(
    id: 'instant_noodles',
    name: _en('Instant noodles'),
    category: FoodCategory.outsidePackaged,
    verdict: NutritionVerdict.limit,
    lines: _en('Instant noodles cooked and eaten occasionally are fine. They '
        'are high in sodium and low in nutrition on their own, so worth '
        'boosting with an egg or vegetables when you do have them, rather '
        'than as a regular meal.'),
    limitGuidance: _en('Occasional is fine. Add protein and vegetables when '
        'you do have it, and keep it out of the weekly routine.'),
    related: ['packaged_chips_namkeen', 'canned_food', 'bakery_items'],
    aliases: ['maggi', 'noodles'],
  ),
  FoodEntry(
    id: 'canned_food',
    name: _en('Canned / tinned food'),
    category: FoodCategory.outsidePackaged,
    verdict: NutritionVerdict.limit,
    lines: _en('Properly canned food from a sealed, undamaged tin and within '
        'its expiry is safe. A bulging, dented or leaking can is a genuine '
        'risk sign and worth throwing out rather than using.'),
    limitGuidance: _en('Check the can and the date before using. Rinse '
        'canned beans or vegetables to cut down on added sodium.'),
    related: ['processed_meat_bacon', 'instant_noodles', 'packaged_chips_namkeen'],
    aliases: ['tinned food'],
  ),
  FoodEntry(
    id: 'bakery_items',
    name: _en('Bakery items'),
    category: FoodCategory.outsidePackaged,
    verdict: NutritionVerdict.limit,
    lines: _en('Bread, biscuits and pastries from a normal bakery are fine '
        'occasionally. They tend to be higher in sugar, refined flour and '
        'preservatives than a home-cooked meal, which is the reason to keep '
        'them occasional rather than daily.'),
    limitGuidance: _en('Fine as a treat. A home-cooked meal is still the '
        'better everyday default.'),
    related: ['mithai_sweets', 'ice_cream', 'energy_bars_protein_bars'],
    aliases: ['pastry', 'bread', 'biscuits'],
  ),
  FoodEntry(
    id: 'restaurant_food',
    name: _en('Restaurant food'),
    category: FoodCategory.outsidePackaged,
    verdict: NutritionVerdict.limit,
    lines: _en('Freshly cooked, hot restaurant food from a place you trust is '
        'fine. The things worth being careful about are raw salads and '
        'chutneys made with untreated water, and anything served '
        'lukewarm or pre-prepared.'),
    limitGuidance: _en('Choose hot, freshly cooked dishes over raw '
        'accompaniments when eating out, and pick places you already trust '
        'for hygiene.'),
    related: ['street_food_chaat', 'sushi_raw_fish', 'canned_food'],
    aliases: ['eating out', 'outside food'],
  ),
  FoodEntry(
    id: 'energy_bars_protein_bars',
    name: _en('Energy / protein bars'),
    category: FoodCategory.outsidePackaged,
    verdict: NutritionVerdict.limit,
    lines: _en('Most everyday energy or protein bars are fine occasionally. '
        'Some carry added stimulants, herbal extracts or very high doses of '
        'single vitamins, worth checking the label for before making them a '
        'daily habit.'),
    limitGuidance: _en('Read the label for caffeine or unfamiliar herbal '
        'extras, and treat a bar as an occasional snack, not a meal '
        'replacement.'),
    related: ['bakery_items', 'packaged_chips_namkeen', 'chocolate'],
    aliases: ['protein bar'],
  ),

  // ---------------------------------------------------------------------
  //  Grains
  // ---------------------------------------------------------------------
  FoodEntry(
    id: 'rice',
    name: _en('Rice'),
    category: FoodCategory.grains,
    verdict: NutritionVerdict.safe,
    lines: _en('Rice, white or brown, is a safe everyday staple through '
        'pregnancy and a fine base for most Indian meals.'),
    related: ['wheat_roti', 'dal_lentils', 'millets_ragi_jowar'],
    aliases: ['chawal'],
  ),
  FoodEntry(
    id: 'wheat_roti',
    name: _en('Wheat / roti'),
    category: FoodCategory.grains,
    verdict: NutritionVerdict.safe,
    lines: _en('Roti and other wheat-based staples are safe and a good '
        'source of everyday fibre and energy through pregnancy.'),
    related: ['rice', 'oats', 'millets_ragi_jowar'],
    aliases: ['chapati', 'atta'],
  ),
  FoodEntry(
    id: 'oats',
    name: _en('Oats'),
    category: FoodCategory.grains,
    verdict: NutritionVerdict.safe,
    lines: _en('Oats are safe, high in fibre, and a good breakfast choice '
        'for steady energy and helping with constipation, common in '
        'pregnancy.'),
    related: ['wheat_roti', 'raw_sprouts', 'quinoa'],
    aliases: [],
  ),
  FoodEntry(
    id: 'quinoa',
    name: _en('Quinoa'),
    category: FoodCategory.grains,
    verdict: NutritionVerdict.safe,
    lines: _en('Quinoa is safe and a complete protein grain, a useful '
        'addition if you are eating largely vegetarian and want more protein '
        'variety.'),
    related: ['oats', 'millets_ragi_jowar', 'dal_lentils'],
    aliases: [],
  ),
  FoodEntry(
    id: 'millets_ragi_jowar',
    name: _en('Millets: ragi, jowar, bajra'),
    category: FoodCategory.grains,
    verdict: NutritionVerdict.safe,
    lines: _en('Millets are safe and a genuinely strong choice: ragi in '
        'particular is valued for calcium, and millets generally bring more '
        'iron and fibre than polished rice.'),
    related: ['rice', 'wheat_roti', 'oats'],
    aliases: ['ragi', 'jowar', 'bajra', 'finger millet'],
  ),
  FoodEntry(
    id: 'raw_sprouts',
    name: _en('Sprouts'),
    category: FoodCategory.grains,
    verdict: NutritionVerdict.limit,
    lines: _en('Cooked or lightly steamed sprouts are safe and a good '
        'protein and fibre source. Raw sprouts, eaten uncooked in a salad, '
        'carry a higher bacterial risk because the warm, moist sprouting '
        'process is exactly what bacteria like too.'),
    limitGuidance: _en('Steam or cook sprouts briefly before eating rather '
        'than having them raw.'),
    related: ['dal_lentils', 'oats', 'dates'],
    aliases: ['sprouted moong'],
  ),
];

// =============================================================================
//  2. Food for my stage
// =============================================================================

class TrimesterGuide {
  const TrimesterGuide({
    required this.id,
    required this.label,
    required this.videoTitle,
    required this.focus,
    required this.helps,
    required this.leanOn,
    required this.sampleDay,
  });

  final String id;
  final LocalizedText label;
  final String videoTitle;

  /// What to focus on this stage.
  final LocalizedText focus;

  /// What helps, as short lines.
  final List<LocalizedText> helps;

  /// Foods to lean on.
  final List<LocalizedText> leanOn;

  /// A sample day, meal by meal.
  final List<({LocalizedText meal, LocalizedText items})> sampleDay;
}

final List<TrimesterGuide> kTrimesterGuides = [
  TrimesterGuide(
    id: 'pre_pregnancy',
    label: _en('Pre-pregnancy'),
    videoTitle: 'Eating well before you conceive',
    focus: _en('Building up folate, iron and a steady weight before you '
        'conceive makes the first weeks, when the baby\'s neural tube is '
        'forming, easier on both of you.'),
    helps: [
      _en('Starting folic acid, ideally a few months before you try'),
      _en('A steady, varied diet rather than a sudden new one'),
      _en('Cutting down alcohol and smoking, not just once pregnant'),
    ],
    leanOn: [
      _en('Leafy greens, dal and citrus for folate'),
      _en('Iron-rich foods: dal, dark greens, jaggery'),
      _en('Dairy or a calcium source daily'),
    ],
    sampleDay: [
      (meal: _en('Breakfast'), items: _en('Vegetable poha or besan chilla, a glass of milk')),
      (meal: _en('Lunch'), items: _en('Dal, sabzi, roti or rice, a side salad')),
      (meal: _en('Snack'), items: _en('A handful of nuts, seasonal fruit')),
      (meal: _en('Dinner'), items: _en('Khichdi or roti with a vegetable curry, curd')),
    ],
  ),
  TrimesterGuide(
    id: 't1',
    label: _en('First trimester'),
    videoTitle: 'Eating through the first trimester',
    focus: _en('Nausea often makes eating hard right when folic acid matters '
        'most. Small, frequent, bland meals usually work better than three '
        'big ones.'),
    helps: [
      _en('Small meals every two to three hours rather than three large ones'),
      _en('Ginger, in tea or food, for nausea'),
      _en('Not worrying if appetite dips, it usually returns by T2'),
    ],
    leanOn: [
      _en('Dry, bland foods when nausea is high: khichdi, toast, banana'),
      _en('Folate-rich food: dal, leafy greens, citrus'),
      _en('Whatever stays down, over what is "ideal" that day'),
    ],
    sampleDay: [
      (meal: _en('Breakfast'), items: _en('Toast or khichdi, ginger tea')),
      (meal: _en('Mid-morning'), items: _en('A banana or a few soaked almonds')),
      (meal: _en('Lunch'), items: _en('Dal, rice, a simple vegetable')),
      (meal: _en('Evening'), items: _en('Light khichdi or curd rice, whatever settles')),
    ],
  ),
  TrimesterGuide(
    id: 't2',
    label: _en('Second trimester'),
    videoTitle: 'Eating through the second trimester',
    focus: _en('Appetite usually returns and the baby is growing fast. This '
        'is the stage to build a steady rhythm of protein, iron and calcium '
        'rather than restrict anything.'),
    helps: [
      _en('A protein source at every meal: dal, paneer, egg, chicken or fish'),
      _en('Iron with a vitamin C food alongside it, to help absorption'),
      _en('Calcium daily, dairy or ragi, alongside iron at a different meal'),
    ],
    leanOn: [
      _en('Dal, paneer, eggs, chicken or fish through the week'),
      _en('Dark leafy greens with a squeeze of lemon'),
      _en('Milk, curd or ragi for calcium'),
    ],
    sampleDay: [
      (meal: _en('Breakfast'), items: _en('Vegetable paratha or dosa, milk')),
      (meal: _en('Lunch'), items: _en('Dal, sabzi, roti or rice, a bowl of curd')),
      (meal: _en('Snack'), items: _en('Fruit with a squeeze of lemon, nuts')),
      (meal: _en('Dinner'), items: _en('Paneer or fish curry, a leafy sabzi, roti')),
    ],
  ),
  TrimesterGuide(
    id: 't3',
    label: _en('Third trimester'),
    videoTitle: 'Eating through the third trimester',
    focus: _en('The baby\'s growth speeds up and there is less room for big '
        'meals. Smaller, more frequent meals with steady protein and iron '
        'usually feel more comfortable than three large plates.'),
    helps: [
      _en('Smaller, more frequent meals as the stomach has less room'),
      _en('Iron and protein stay a daily priority, right through to labour'),
      _en('Easy-to-digest food in the evening if heartburn is a problem'),
    ],
    leanOn: [
      _en('Dates, valued traditionally in the final weeks'),
      _en('Dal, paneer, eggs for steady protein'),
      _en('Lighter dinners: khichdi, curd rice, a simple soup'),
    ],
    sampleDay: [
      (meal: _en('Breakfast'), items: _en('Vegetable upma or a besan chilla, milk')),
      (meal: _en('Lunch'), items: _en('Dal, sabzi, roti, a small bowl of rice')),
      (meal: _en('Snack'), items: _en('Dates and a handful of nuts')),
      (meal: _en('Dinner'), items: _en('Khichdi or curd rice, kept light')),
    ],
  ),
];

/// Condition pages. Each ends by pointing at a doctor or the dietician, never
/// a diagnosis or a prescribed amount.
class ConditionGuide {
  const ConditionGuide({
    required this.id,
    required this.label,
    required this.videoTitle,
    required this.summary,
    required this.guidance,
  });

  final String id;
  final LocalizedText label;
  final String videoTitle;
  final LocalizedText summary;

  /// Plain guidance, as short paragraphs.
  final List<LocalizedText> guidance;
}

final List<ConditionGuide> kConditionGuides = [
  ConditionGuide(
    id: 'gestational_diabetes',
    label: _en('Gestational diabetes'),
    videoTitle: 'Eating with gestational diabetes',
    summary: _en('The goal is steadier blood sugar through the day, not a '
        'restrictive diet. Small changes to how and when you eat carbs '
        'usually matter more than cutting any one food out.'),
    guidance: [
      _en('Pair carbs with protein or fibre, rice with dal rather than rice '
          'alone, to slow how fast sugar rises.'),
      _en('Smaller, more frequent meals tend to keep readings steadier than '
          'three large ones.'),
      _en('Fruit is not off-limits, but portion and pairing matter, ask your '
          'dietician what a serving looks like for you.'),
      _en('Your care team will usually give you specific numbers to aim for. '
          'This page explains the general approach; the numbers are theirs '
          'to set.'),
    ],
  ),
  ConditionGuide(
    id: 'anemia_iron',
    label: _en('Anaemia / low iron'),
    videoTitle: 'Eating for anaemia in pregnancy',
    summary: _en('Iron needs go up sharply in pregnancy, and food alone often '
        'is not quite enough, which is why a supplement is common alongside '
        'diet, not instead of it.'),
    guidance: [
      _en('Iron-rich foods: dal, dark leafy greens, jaggery, ragi, and meat '
          'if you eat it.'),
      _en('Have a vitamin C food, citrus, tomato, amla, at the same meal as '
          'an iron-rich food, it noticeably helps absorption.'),
      _en('Tea and coffee right around an iron-rich meal can reduce '
          'absorption, so it helps to have them a little apart from meals.'),
      _en('If a supplement has been prescribed, food and supplement work '
          'together, one is not a substitute for the other.'),
    ],
  ),
  ConditionGuide(
    id: 'thyroid',
    label: _en('Thyroid conditions'),
    videoTitle: 'Eating with a thyroid condition in pregnancy',
    summary: _en('Thyroid needs in pregnancy are usually managed through '
        'medication your doctor prescribes and monitors, with diet playing a '
        'supporting role rather than the main one.'),
    guidance: [
      _en('Iodine matters for thyroid function, iodised salt in normal '
          'cooking amounts usually covers this.'),
      _en('If you take thyroid medication, it is generally taken on an '
          'empty stomach, calcium and iron supplements can interfere with '
          'absorption if taken too close together, ask your doctor about '
          'timing.'),
      _en('Diet supports thyroid health, it does not replace or adjust your '
          'prescribed dose, that stays with your doctor.'),
    ],
  ),
  ConditionGuide(
    id: 'pcos',
    label: _en('PCOS'),
    videoTitle: 'Eating with PCOS in pregnancy',
    summary: _en('If PCOS was part of your journey to this pregnancy, steady '
        'blood sugar and a varied diet remain useful, much like the general '
        'gestational diabetes approach, whether or not you have been '
        'diagnosed with it in this pregnancy.'),
    guidance: [
      _en('Regular meals with protein and fibre help keep blood sugar '
          'steadier through the day.'),
      _en('There is no need for an unusually restrictive diet, a varied, '
          'balanced plate remains the goal.'),
      _en('Your doctor may watch your blood sugar a little more closely '
          'given a PCOS history, that is routine, not a sign of a problem.'),
    ],
  ),
  ConditionGuide(
    id: 'high_bp_preeclampsia',
    label: _en('High BP / preeclampsia'),
    videoTitle: 'Eating with high blood pressure in pregnancy',
    summary: _en('Where salt has been flagged as a concern, the useful lever '
        'is usually cutting back on added and packaged salt, not eliminating '
        'salt from cooking altogether.'),
    guidance: [
      _en('Go easy on packaged, pickled and processed foods, where most '
          'hidden salt lives, more than the pinch you add while cooking.'),
      _en('Potassium-rich foods, banana, coconut water, leafy greens, are '
          'often encouraged alongside a lower-salt approach.'),
      _en('This is guidance your doctor will tailor with actual numbers if '
          'you have been diagnosed with preeclampsia, this page is the '
          'general picture, not your specific plan.'),
    ],
  ),
  ConditionGuide(
    id: 'healthy_weight_gain',
    label: _en('Healthy weight gain'),
    videoTitle: 'How much weight gain is normal, and what helps',
    summary: _en('Weight gain in pregnancy is expected and healthy. The '
        'useful question is usually less "how much" and more "is it '
        'steady", which your doctor tracks at each visit.'),
    guidance: [
      _en('A varied plate with protein, whole grains and vegetables usually '
          'supports steady gain better than any single food.'),
      _en('Sudden, sharp weight change in either direction is worth '
          'mentioning to your doctor, more than the total number on its '
          'own.'),
      _en('Your doctor tracks your weight against your own starting point, '
          'not a single target every mother is measured against.'),
    ],
  ),
  ConditionGuide(
    id: 'brain_development',
    label: _en('Brain-development foods'),
    videoTitle: 'Foods that support your baby\'s brain development',
    summary: _en('A few nutrients are particularly tied to the baby\'s '
        'developing brain and nervous system, and they are easy to build '
        'into an ordinary Indian diet.'),
    guidance: [
      _en('Omega-3, from fish twice a week or walnuts and flaxseed if you '
          'eat vegetarian, supports the developing brain.'),
      _en('Folate and iron, dal, leafy greens, remain foundational through '
          'every trimester, not just the first.'),
      _en('Choline, found in eggs, is another nutrient increasingly linked '
          'to brain development, an egg a day is an easy way to include it.'),
    ],
  ),
  ConditionGuide(
    id: 'constipation_piles',
    label: _en('Constipation / piles'),
    videoTitle: 'Easing constipation through food',
    summary: _en('Constipation is extremely common in pregnancy, from '
        'hormones, iron supplements and a growing uterus, and food is often '
        'the first and gentlest thing to try.'),
    guidance: [
      _en('Fibre from whole grains, oats, fruits with the skin on, and '
          'vegetables makes a real difference.'),
      _en('Water matters as much as fibre, aim to drink through the day '
          'rather than in a few large glasses.'),
      _en('A short walk after meals genuinely helps digestion move, worth '
          'pairing with the dietary changes.'),
      _en('If it becomes painful or persistent, or piles develop, that is '
          'worth mentioning to your doctor rather than managing through diet '
          'alone.'),
    ],
  ),
  ConditionGuide(
    id: 'twins',
    label: _en('Carrying twins'),
    videoTitle: 'Eating well for a twin pregnancy',
    summary: _en('A twin pregnancy generally needs more calories and '
        'nutrients than a single pregnancy, which your doctor will usually '
        'account for at your visits.'),
    guidance: [
      _en('Extra protein and iron needs are common with twins, your doctor '
          'may suggest higher supplement doses than a single pregnancy.'),
      _en('Smaller, more frequent meals often feel more comfortable as room '
          'in the stomach becomes limited earlier than in a single '
          'pregnancy.'),
      _en('Weight gain targets for twins are usually different from single '
          'pregnancy charts, ask your doctor what range applies to you.'),
    ],
  ),
  ConditionGuide(
    id: 'underweight',
    label: _en('Underweight in pregnancy'),
    videoTitle: 'Eating to gain steadily when starting underweight',
    summary: _en('If you started pregnancy underweight, the goal is usually '
        'steady, adequate weight gain, without feeling pressured to eat past '
        'comfort.'),
    guidance: [
      _en('Calorie-dense, nutritious foods, nuts, ghee, dairy, help without '
          'needing huge meal sizes.'),
      _en('Frequent smaller meals, five or six through the day, are often '
          'easier than three large ones if appetite is limited.'),
      _en('Your doctor will track your specific weight-gain range, which is '
          'usually higher than the general chart when starting underweight.'),
    ],
  ),
  ConditionGuide(
    id: 'overweight',
    label: _en('Overweight in pregnancy'),
    videoTitle: 'Eating well when starting pregnancy overweight',
    summary: _en('This is about steady, healthy nutrition for you and the '
        'baby, never about restriction or a smaller body during pregnancy '
        'itself.'),
    guidance: [
      _en('A varied, balanced plate, protein, vegetables, whole grains, '
          'supports a healthy pregnancy regardless of starting weight.'),
      _en('Weight-gain targets are usually a smaller range than the general '
          'chart when starting overweight, your doctor will set the actual '
          'number.'),
      _en('This is never about dieting during pregnancy, that is a '
          'conversation for after, with your own doctor.'),
    ],
  ),
];

// =============================================================================
//  3. Nutrients
// =============================================================================

class NutrientGuide {
  const NutrientGuide({
    required this.id,
    required this.name,
    required this.whatItDoes,
    required this.foods,
    required this.supplementNote,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText whatItDoes;

  /// Everyday Indian foods that give this nutrient.
  final List<LocalizedText> foods;
  final LocalizedText supplementNote;
}

final List<NutrientGuide> kNutrientGuides = [
  NutrientGuide(
    id: 'folic_acid',
    name: _en('Folic acid'),
    whatItDoes: _en('Supports the early formation of the baby\'s brain and '
        'spinal cord, which is why it matters most before conception and in '
        'the first weeks.'),
    foods: [_en('Leafy greens'), _en('Dal and lentils'), _en('Citrus fruit'), _en('Beetroot')],
    supplementNote: _en('Usually prescribed as a supplement before and '
        'during early pregnancy, since food alone rarely covers the full '
        'need in time.'),
  ),
  NutrientGuide(
    id: 'iron',
    name: _en('Iron'),
    whatItDoes: _en('Builds the extra blood you and the baby both need, and '
        'low iron is one of the most common pregnancy deficiencies in '
        'India.'),
    foods: [_en('Dal'), _en('Dark leafy greens'), _en('Jaggery'), _en('Ragi'), _en('Meat, if eaten')],
    supplementNote: _en('Very commonly prescribed alongside diet, since '
        'pregnancy needs are usually higher than food alone provides.'),
  ),
  NutrientGuide(
    id: 'calcium',
    name: _en('Calcium'),
    whatItDoes: _en('Builds the baby\'s bones and teeth, and protects your '
        'own bone density, since the baby will draw on your stores if diet '
        'falls short.'),
    foods: [_en('Milk and curd'), _en('Paneer'), _en('Ragi'), _en('Sesame seeds')],
    supplementNote: _en('Often suggested if dairy intake is low, ask your '
        'doctor rather than starting one on your own.'),
  ),
  NutrientGuide(
    id: 'protein',
    name: _en('Protein'),
    whatItDoes: _en('Builds the baby\'s tissue and supports your own '
        'changing body, with needs rising steadily through pregnancy.'),
    foods: [_en('Dal'), _en('Paneer'), _en('Eggs'), _en('Chicken and fish'), _en('Soy and tofu')],
    supplementNote: _en('Rarely needed as a supplement if meals include a '
        'protein source regularly, whole food is usually enough.'),
  ),
  NutrientGuide(
    id: 'vitamin_d',
    name: _en('Vitamin D'),
    whatItDoes: _en('Helps your body use calcium properly, and supports the '
        'baby\'s bone development.'),
    foods: [_en('Sunlight exposure'), _en('Egg yolk'), _en('Fortified milk')],
    supplementNote: _en('Commonly low in India despite the sun, many doctors '
        'prescribe a supplement as routine.'),
  ),
  NutrientGuide(
    id: 'b12',
    name: _en('Vitamin B12'),
    whatItDoes: _en('Supports the baby\'s nervous system, and is one of the '
        'few nutrients genuinely hard to get enough of on a vegetarian or '
        'vegan diet, since it mainly comes from animal foods.'),
    foods: [_en('Milk and curd'), _en('Eggs'), _en('Meat and fish, if eaten')],
    supplementNote: _en('Often prescribed for vegetarians and almost always '
        'for vegans, since plant foods do not reliably provide it.'),
  ),
  NutrientGuide(
    id: 'omega3_dha',
    name: _en('Omega-3 (DHA)'),
    whatItDoes: _en('A key building block for the baby\'s brain and eyes, '
        'especially in the second half of pregnancy.'),
    foods: [_en('Fish, twice a week'), _en('Walnuts'), _en('Flaxseed')],
    supplementNote: _en('Often suggested for vegetarians, since plant '
        'sources give a weaker form of omega-3 than fish does.'),
  ),
  NutrientGuide(
    id: 'iodine',
    name: _en('Iodine'),
    whatItDoes: _en('Needed for the baby\'s thyroid and brain development, '
        'and for your own thyroid, which is working harder in pregnancy.'),
    foods: [_en('Iodised salt'), _en('Milk'), _en('Eggs')],
    supplementNote: _en('Iodised salt in normal cooking usually covers this, '
        'a separate supplement is not routine unless your doctor suggests '
        'one.'),
  ),
  NutrientGuide(
    id: 'fibre',
    name: _en('Fibre'),
    whatItDoes: _en('Keeps digestion moving, genuinely useful against the '
        'constipation that is common in pregnancy.'),
    foods: [_en('Whole grains'), _en('Fruit with the skin on'), _en('Vegetables'), _en('Dal')],
    supplementNote: _en('Rarely needed as a supplement, food easily covers '
        'this one.'),
  ),
  NutrientGuide(
    id: 'zinc',
    name: _en('Zinc'),
    whatItDoes: _en('Supports the baby\'s growth and your own immune '
        'function through pregnancy.'),
    foods: [_en('Dal and legumes'), _en('Nuts and seeds'), _en('Dairy')],
    supplementNote: _en('Usually covered by a varied diet, not routinely '
        'supplemented on its own.'),
  ),
  NutrientGuide(
    id: 'magnesium',
    name: _en('Magnesium'),
    whatItDoes: _en('Supports muscle and nerve function, and may help with '
        'the leg cramps common later in pregnancy.'),
    foods: [_en('Nuts and seeds'), _en('Whole grains'), _en('Dark leafy greens')],
    supplementNote: _en('Usually covered by diet, sometimes suggested '
        'specifically if leg cramps are frequent.'),
  ),
  NutrientGuide(
    id: 'vitamin_c',
    name: _en('Vitamin C'),
    whatItDoes: _en('Supports your immune system and, importantly, helps '
        'your body absorb iron from plant foods when eaten at the same '
        'meal.'),
    foods: [_en('Citrus fruit'), _en('Amla'), _en('Tomato'), _en('Guava')],
    supplementNote: _en('Rarely needed as a supplement, easiest to just pair '
        'with an iron-rich food at meals.'),
  ),
];

/// Practical cards on the Nutrients screen, distinct from single-nutrient
/// cards: these answer a whole-diet question rather than one nutrient.
class NutritionPracticalCard {
  const NutritionPracticalCard({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText body;
}

final List<NutritionPracticalCard> kNutritionPracticalCards = [
  NutritionPracticalCard(
    id: 'which_prenatal_vitamins',
    title: _en('Which prenatal vitamins?'),
    body: _en('Most doctors prescribe a standard combination covering folic '
        'acid, iron, calcium and vitamin D, sometimes as separate tablets '
        'rather than one pill, since some of these interfere with each other '
        'if taken together. Take whatever your own doctor has prescribed, '
        'this page is about understanding it, not choosing it yourself.'),
  ),
  NutritionPracticalCard(
    id: 'iron_calcium_timing',
    title: _en('Iron and calcium: why not together'),
    body: _en('Calcium can reduce how much iron your body absorbs if taken '
        'at the same time. That is why they are often prescribed at '
        'different times of day, iron with a vitamin C food, calcium with '
        'milk or a meal later on. If your prescription already spaces them '
        'out, that spacing is doing real work.'),
  ),
  NutritionPracticalCard(
    id: 'veg_vegan_protein_b12',
    title: _en('Vegetarian or vegan? Protein and B12'),
    body: _en('A vegetarian diet can easily meet protein needs through dal, '
        'paneer, dairy and soy. B12 is the harder gap, since it mainly comes '
        'from animal foods, dairy covers it for most vegetarians, but a '
        'vegan diet almost always needs a B12 supplement, worth raising with '
        'your doctor early.'),
  ),
  NutritionPracticalCard(
    id: 'is_my_thali_enough',
    title: _en('Is my normal thali enough?'),
    body: _en('An ordinary Indian thali, dal, sabzi, roti or rice, curd, '
        'covers most of what you need most days. The gaps that usually still '
        'need a supplement are iron, folic acid, calcium and vitamin D, '
        'which is why your doctor prescribes those specifically rather than '
        'asking you to overhaul your diet.'),
  ),
  NutritionPracticalCard(
    id: 'do_i_need_supplements',
    title: _en('Do I actually need supplements?'),
    body: _en('For most mothers, yes, at least for iron, folic acid and '
        'often vitamin D and calcium, because pregnancy needs typically '
        'outpace what a normal diet provides, even a good one. Food and '
        'supplements do different jobs here, one does not replace the '
        'other. Your prescription is the actual answer for you; a dietician '
        'can walk through why, if you want the reasoning.'),
  ),
];

// =============================================================================
//  4. Recipes
// =============================================================================

enum RecipeRegion {
  bengali,
  tamil,
  punjabi,
  gujarati,
  southIndian,
  maharashtrian,
  jain,
  panIndian,
}

extension RecipeRegionMeta on RecipeRegion {
  LocalizedText get label => switch (this) {
        RecipeRegion.bengali => _en('Bengali'),
        RecipeRegion.tamil => _en('Tamil'),
        RecipeRegion.punjabi => _en('Punjabi'),
        RecipeRegion.gujarati => _en('Gujarati'),
        RecipeRegion.southIndian => _en('South Indian'),
        RecipeRegion.maharashtrian => _en('Maharashtrian'),
        RecipeRegion.jain => _en('Jain'),
        RecipeRegion.panIndian => _en('Pan-Indian'),
      };
}

class RecipeIngredient {
  const RecipeIngredient(
      {required this.name, required this.qtyPerServing, required this.unit});

  final LocalizedText name;

  /// Amount for ONE serving. The detail screen multiplies by the servings the
  /// mother picks.
  final double qtyPerServing;
  final String unit;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.whyNow,
    required this.region,
    required this.tags,
    required this.defaultServings,
    required this.ingredients,
    required this.steps,
    required this.nutritionGlance,
    required this.videoTitle,
  });

  final String id;
  final LocalizedText name;

  /// One line: why this helps you now.
  final LocalizedText whyNow;
  final RecipeRegion region;

  /// Filter tags: needs ('iron','protein','fibre','calcium'…), stage
  /// ('t1','t2','t3'), condition ('gestational_diabetes','constipation'…).
  final List<String> tags;
  final int defaultServings;
  final List<RecipeIngredient> ingredients;
  final List<LocalizedText> steps;

  /// e.g. "Protein 9g", "Iron 3mg", "Calories 220" — per serving.
  final List<String> nutritionGlance;
  final String videoTitle;
}

/// Filter chips shown on the Recipes grid — a mix of need/stage/condition/
/// region tags, kept short on purpose.
const List<({String tag, String label})> kRecipeFilters = [
  (tag: 't1', label: 'First trimester'),
  (tag: 't2', label: 'Second trimester'),
  (tag: 't3', label: 'Third trimester'),
  (tag: 'iron', label: 'Iron'),
  (tag: 'protein', label: 'Protein'),
  (tag: 'calcium', label: 'Calcium'),
  (tag: 'fibre', label: 'Fibre'),
  (tag: 'gestational_diabetes', label: 'Diabetes-friendly'),
  (tag: 'constipation', label: 'Digestion'),
  (tag: 'jain', label: 'Jain'),
];

final List<Recipe> kRecipes = [
  Recipe(
    id: 'bengali_macher_jhol',
    name: _en('Bengali macher jhol'),
    whyNow: _en('A light fish curry that gives you protein and omega-3 '
        'without a heavy hand of oil or spice.'),
    region: RecipeRegion.bengali,
    tags: const ['protein', 'omega3', 't2', 't3'],
    defaultServings: 2,
    ingredients: [
      RecipeIngredient(name: _en('Rohu or katla fish pieces'), qtyPerServing: 100, unit: 'g'),
      RecipeIngredient(name: _en('Potato, cubed'), qtyPerServing: 0.5, unit: 'pcs'),
      RecipeIngredient(name: _en('Mustard oil'), qtyPerServing: 1, unit: 'tsp'),
      RecipeIngredient(name: _en('Turmeric powder'), qtyPerServing: 0.25, unit: 'tsp'),
      RecipeIngredient(name: _en('Cumin seeds'), qtyPerServing: 0.25, unit: 'tsp'),
      RecipeIngredient(name: _en('Green chilli'), qtyPerServing: 0.5, unit: 'pcs'),
      RecipeIngredient(name: _en('Water'), qtyPerServing: 0.5, unit: 'cup'),
    ],
    steps: [
      _en('Rub the fish pieces lightly with turmeric and salt, and set aside.'),
      _en('Heat the mustard oil and shallow fry the fish pieces until firm, then set them aside.'),
      _en('In the same pan, temper cumin seeds, add the potato and cook a few minutes.'),
      _en('Add turmeric, water and green chilli, and simmer until the potato is nearly done.'),
      _en('Slide the fish back in and simmer gently until cooked through, then serve hot with rice.'),
    ],
    nutritionGlance: const ['Protein 18g', 'Omega-3 present', 'Calories 190'],
    videoTitle: 'Cook along: Bengali macher jhol',
  ),
  Recipe(
    id: 'bengali_shukto',
    name: _en('Bengali shukto'),
    whyNow: _en('A mixed-vegetable dish that is gentle on digestion and a '
        'good source of everyday fibre.'),
    region: RecipeRegion.bengali,
    tags: const ['fibre', 'constipation', 't1'],
    defaultServings: 2,
    ingredients: [
      RecipeIngredient(name: _en('Mixed vegetables (bitter gourd, potato, beans, drumstick)'), qtyPerServing: 150, unit: 'g'),
      RecipeIngredient(name: _en('Milk'), qtyPerServing: 0.25, unit: 'cup'),
      RecipeIngredient(name: _en('Ghee'), qtyPerServing: 1, unit: 'tsp'),
      RecipeIngredient(name: _en('Panch phoron (five-spice mix)'), qtyPerServing: 0.5, unit: 'tsp'),
      RecipeIngredient(name: _en('Ginger paste'), qtyPerServing: 0.5, unit: 'tsp'),
    ],
    steps: [
      _en('Cut all vegetables into similar-sized pieces.'),
      _en('Heat ghee and temper the panch phoron until fragrant.'),
      _en('Add the vegetables and ginger paste, and stir well.'),
      _en('Add the milk and a little water, and simmer until the vegetables are soft.'),
      _en('Serve warm alongside rice, as a light start to the meal.'),
    ],
    nutritionGlance: const ['Fibre 5g', 'Calories 120'],
    videoTitle: 'Cook along: Bengali shukto',
  ),
  Recipe(
    id: 'tamil_ragi_kanji',
    name: _en('Tamil ragi kanji'),
    whyNow: _en('A finger-millet porridge that is easy on a queasy stomach '
        'and quietly strong on iron and calcium.'),
    region: RecipeRegion.tamil,
    tags: const ['iron', 'calcium', 't1'],
    defaultServings: 1,
    ingredients: [
      RecipeIngredient(name: _en('Ragi flour'), qtyPerServing: 3, unit: 'tbsp'),
      RecipeIngredient(name: _en('Buttermilk'), qtyPerServing: 1, unit: 'cup'),
      RecipeIngredient(name: _en('Water'), qtyPerServing: 0.5, unit: 'cup'),
      RecipeIngredient(name: _en('Salt'), qtyPerServing: 0.1, unit: 'tsp'),
    ],
    steps: [
      _en('Mix the ragi flour with water into a smooth paste, no lumps.'),
      _en('Cook on low heat, stirring, until it thickens into a thin porridge.'),
      _en('Let it cool a little, then stir in the buttermilk and salt.'),
      _en('Serve at room temperature, sipped slowly like a light drink.'),
    ],
    nutritionGlance: const ['Calcium high', 'Iron present', 'Calories 140'],
    videoTitle: 'Cook along: Tamil ragi kanji',
  ),
  Recipe(
    id: 'tamil_sambar',
    name: _en('Tamil sambar'),
    whyNow: _en('A lentil and vegetable stew that pairs protein with fibre '
        'in one easy, everyday pot.'),
    region: RecipeRegion.tamil,
    tags: const ['protein', 'fibre', 't2'],
    defaultServings: 3,
    ingredients: [
      RecipeIngredient(name: _en('Toor dal'), qtyPerServing: 0.33, unit: 'cup'),
      RecipeIngredient(name: _en('Mixed vegetables (drumstick, brinjal, pumpkin)'), qtyPerServing: 100, unit: 'g'),
      RecipeIngredient(name: _en('Tamarind pulp'), qtyPerServing: 1, unit: 'tsp'),
      RecipeIngredient(name: _en('Sambar powder'), qtyPerServing: 1, unit: 'tsp'),
      RecipeIngredient(name: _en('Mustard seeds and curry leaves'), qtyPerServing: 0.25, unit: 'tsp'),
    ],
    steps: [
      _en('Pressure-cook the toor dal until soft, then mash it lightly.'),
      _en('Cook the vegetables separately in a little water until tender.'),
      _en('Combine the dal and vegetables, add tamarind pulp and sambar powder, and simmer.'),
      _en('Temper mustard seeds and curry leaves in a little oil, and pour over the sambar.'),
      _en('Serve hot with rice or idli.'),
    ],
    nutritionGlance: const ['Protein 10g', 'Fibre 6g', 'Calories 160'],
    videoTitle: 'Cook along: Tamil sambar',
  ),
  Recipe(
    id: 'punjabi_palak_paneer',
    name: _en('Punjabi palak paneer'),
    whyNow: _en('Iron from the spinach and calcium from the paneer in one '
        'familiar, comforting curry.'),
    region: RecipeRegion.punjabi,
    tags: const ['iron', 'calcium', 't2'],
    defaultServings: 2,
    ingredients: [
      RecipeIngredient(name: _en('Spinach, chopped'), qtyPerServing: 150, unit: 'g'),
      RecipeIngredient(name: _en('Paneer, cubed'), qtyPerServing: 75, unit: 'g'),
      RecipeIngredient(name: _en('Onion, chopped'), qtyPerServing: 0.25, unit: 'pcs'),
      RecipeIngredient(name: _en('Tomato, chopped'), qtyPerServing: 0.5, unit: 'pcs'),
      RecipeIngredient(name: _en('Ginger-garlic paste'), qtyPerServing: 0.5, unit: 'tsp'),
      RecipeIngredient(name: _en('Cream or milk'), qtyPerServing: 1, unit: 'tbsp'),
    ],
    steps: [
      _en('Blanch the spinach briefly in hot water, then blend to a smooth puree.'),
      _en('Sauté onion, ginger-garlic paste and tomato until soft.'),
      _en('Add the spinach puree and simmer for a few minutes.'),
      _en('Add the paneer cubes and a splash of cream or milk, and warm through.'),
      _en('Serve with roti or rice.'),
    ],
    nutritionGlance: const ['Iron 3mg', 'Calcium high', 'Calories 210'],
    videoTitle: 'Cook along: Punjabi palak paneer',
  ),
  Recipe(
    id: 'punjabi_rajma',
    name: _en('Punjabi rajma'),
    whyNow: _en('A kidney-bean curry that is a solid, filling source of both '
        'protein and iron.'),
    region: RecipeRegion.punjabi,
    tags: const ['protein', 'iron', 't2', 't3'],
    defaultServings: 3,
    ingredients: [
      RecipeIngredient(name: _en('Rajma (kidney beans), soaked'), qtyPerServing: 0.33, unit: 'cup'),
      RecipeIngredient(name: _en('Onion, chopped'), qtyPerServing: 0.33, unit: 'pcs'),
      RecipeIngredient(name: _en('Tomato puree'), qtyPerServing: 3, unit: 'tbsp'),
      RecipeIngredient(name: _en('Ginger-garlic paste'), qtyPerServing: 0.5, unit: 'tsp'),
      RecipeIngredient(name: _en('Rajma masala'), qtyPerServing: 1, unit: 'tsp'),
    ],
    steps: [
      _en('Pressure-cook the soaked rajma until soft.'),
      _en('Sauté onion and ginger-garlic paste until golden.'),
      _en('Add tomato puree and rajma masala, and cook until the oil separates.'),
      _en('Add the cooked rajma with its water, and simmer until the gravy thickens.'),
      _en('Serve hot with rice.'),
    ],
    nutritionGlance: const ['Protein 12g', 'Iron 3.5mg', 'Calories 220'],
    videoTitle: 'Cook along: Punjabi rajma',
  ),
  Recipe(
    id: 'gujarati_dhokla',
    name: _en('Gujarati dhokla'),
    whyNow: _en('A steamed, fermented snack that is light, protein-bearing '
        'and easy on the stomach.'),
    region: RecipeRegion.gujarati,
    tags: const ['fibre', 'gestational_diabetes', 'jain'],
    defaultServings: 4,
    ingredients: [
      RecipeIngredient(name: _en('Besan (gram flour)'), qtyPerServing: 3, unit: 'tbsp'),
      RecipeIngredient(name: _en('Curd'), qtyPerServing: 2, unit: 'tbsp'),
      RecipeIngredient(name: _en('Eno or fruit salt'), qtyPerServing: 0.25, unit: 'tsp'),
      RecipeIngredient(name: _en('Turmeric powder'), qtyPerServing: 0.1, unit: 'tsp'),
      RecipeIngredient(name: _en('Mustard seeds and curry leaves for tempering'), qtyPerServing: 0.25, unit: 'tsp'),
    ],
    steps: [
      _en('Whisk besan, curd, turmeric and water into a smooth, pourable batter.'),
      _en('Add the fruit salt just before steaming, and mix gently, the batter should turn frothy.'),
      _en('Pour into a greased plate and steam for about 15 minutes, until a knife comes out clean.'),
      _en('Temper mustard seeds and curry leaves in a little oil, and pour over the steamed dhokla.'),
      _en('Cool slightly, cut into squares, and serve.'),
    ],
    nutritionGlance: const ['Protein 6g', 'Calories 110', 'Low oil'],
    videoTitle: 'Cook along: Gujarati dhokla',
  ),
  Recipe(
    id: 'gujarati_khichdi',
    name: _en('Gujarati moong dal khichdi'),
    whyNow: _en('A gentle, easy-to-digest one-pot meal, especially useful on '
        'a nauseous or low-appetite day.'),
    region: RecipeRegion.gujarati,
    tags: const ['t1', 'nausea', 'protein'],
    defaultServings: 2,
    ingredients: [
      RecipeIngredient(name: _en('Rice'), qtyPerServing: 0.25, unit: 'cup'),
      RecipeIngredient(name: _en('Split moong dal'), qtyPerServing: 0.25, unit: 'cup'),
      RecipeIngredient(name: _en('Ghee'), qtyPerServing: 1, unit: 'tsp'),
      RecipeIngredient(name: _en('Cumin seeds'), qtyPerServing: 0.25, unit: 'tsp'),
      RecipeIngredient(name: _en('Turmeric powder'), qtyPerServing: 0.1, unit: 'tsp'),
    ],
    steps: [
      _en('Wash the rice and dal together, and drain.'),
      _en('Heat ghee, temper cumin seeds, then add the rice, dal and turmeric.'),
      _en('Add water, about four times the rice and dal by volume, and salt.'),
      _en('Pressure-cook until soft and porridge-like.'),
      _en('Serve warm, plain or with a spoon of ghee on top.'),
    ],
    nutritionGlance: const ['Protein 8g', 'Calories 180', 'Easy to digest'],
    videoTitle: 'Cook along: Gujarati moong dal khichdi',
  ),
  Recipe(
    id: 'south_indian_ragi_dosa',
    name: _en('South Indian ragi dosa'),
    whyNow: _en('A breakfast dosa that trades some rice for ragi, adding '
        'iron and calcium to a familiar plate.'),
    region: RecipeRegion.southIndian,
    tags: const ['iron', 'calcium', 't2'],
    defaultServings: 2,
    ingredients: [
      RecipeIngredient(name: _en('Ragi flour'), qtyPerServing: 3, unit: 'tbsp'),
      RecipeIngredient(name: _en('Rice flour'), qtyPerServing: 2, unit: 'tbsp'),
      RecipeIngredient(name: _en('Curd'), qtyPerServing: 2, unit: 'tbsp'),
      RecipeIngredient(name: _en('Cumin seeds'), qtyPerServing: 0.25, unit: 'tsp'),
      RecipeIngredient(name: _en('Oil for the pan'), qtyPerServing: 0.5, unit: 'tsp'),
    ],
    steps: [
      _en('Whisk ragi flour, rice flour, curd, cumin and water into a thin, pourable batter.'),
      _en('Let it rest for 15 to 20 minutes.'),
      _en('Heat a pan with a little oil, and spread a thin layer of batter across it.'),
      _en('Cook until the edges lift and the base is golden, then flip briefly.'),
      _en('Serve hot with chutney or sambar.'),
    ],
    nutritionGlance: const ['Calcium high', 'Iron present', 'Calories 150'],
    videoTitle: 'Cook along: South Indian ragi dosa',
  ),
  Recipe(
    id: 'south_indian_curd_rice',
    name: _en('South Indian curd rice'),
    whyNow: _en('A cooling, probiotic dish that settles the stomach and '
        'often eases late-pregnancy heartburn.'),
    region: RecipeRegion.southIndian,
    tags: const ['t3', 'heartburn', 'digestion'],
    defaultServings: 2,
    ingredients: [
      RecipeIngredient(name: _en('Cooked rice'), qtyPerServing: 0.5, unit: 'cup'),
      RecipeIngredient(name: _en('Curd'), qtyPerServing: 0.5, unit: 'cup'),
      RecipeIngredient(name: _en('Milk'), qtyPerServing: 2, unit: 'tbsp'),
      RecipeIngredient(name: _en('Mustard seeds and curry leaves for tempering'), qtyPerServing: 0.25, unit: 'tsp'),
      RecipeIngredient(name: _en('Grated ginger'), qtyPerServing: 0.25, unit: 'tsp'),
    ],
    steps: [
      _en('Mash the cooked rice lightly while still warm.'),
      _en('Stir in the curd and milk until smooth and creamy.'),
      _en('Temper mustard seeds and curry leaves in a little oil, and mix in.'),
      _en('Add the grated ginger and a pinch of salt.'),
      _en('Chill briefly and serve cool.'),
    ],
    nutritionGlance: const ['Calcium good', 'Calories 160', 'Cooling'],
    videoTitle: 'Cook along: South Indian curd rice',
  ),
  Recipe(
    id: 'maharashtrian_varan_bhaat',
    name: _en('Maharashtrian varan bhaat'),
    whyNow: _en('A simple dal and rice combination that is gentle, filling '
        'and easy to make on a tired evening.'),
    region: RecipeRegion.maharashtrian,
    tags: const ['protein', 't1', 'nausea'],
    defaultServings: 2,
    ingredients: [
      RecipeIngredient(name: _en('Toor dal'), qtyPerServing: 0.33, unit: 'cup'),
      RecipeIngredient(name: _en('Rice'), qtyPerServing: 0.33, unit: 'cup'),
      RecipeIngredient(name: _en('Turmeric powder'), qtyPerServing: 0.1, unit: 'tsp'),
      RecipeIngredient(name: _en('Ghee'), qtyPerServing: 1, unit: 'tsp'),
      RecipeIngredient(name: _en('Cumin seeds'), qtyPerServing: 0.25, unit: 'tsp'),
    ],
    steps: [
      _en('Pressure-cook the dal with turmeric until soft, then mash lightly.'),
      _en('Cook the rice separately until soft.'),
      _en('Temper cumin seeds in ghee, and stir into the dal.'),
      _en('Serve the dal ladled generously over the rice.'),
    ],
    nutritionGlance: const ['Protein 9g', 'Calories 190', 'Easy to digest'],
    videoTitle: 'Cook along: Maharashtrian varan bhaat',
  ),
  Recipe(
    id: 'maharashtrian_thalipeeth',
    name: _en('Maharashtrian thalipeeth'),
    whyNow: _en('A multigrain flatbread that brings iron and fibre together '
        'in one hearty breakfast.'),
    region: RecipeRegion.maharashtrian,
    tags: const ['iron', 'fibre', 't2'],
    defaultServings: 2,
    ingredients: [
      RecipeIngredient(name: _en('Thalipeeth multigrain flour'), qtyPerServing: 0.33, unit: 'cup'),
      RecipeIngredient(name: _en('Onion, finely chopped'), qtyPerServing: 0.25, unit: 'pcs'),
      RecipeIngredient(name: _en('Coriander leaves, chopped'), qtyPerServing: 1, unit: 'tbsp'),
      RecipeIngredient(name: _en('Cumin seeds'), qtyPerServing: 0.25, unit: 'tsp'),
      RecipeIngredient(name: _en('Oil for the pan'), qtyPerServing: 1, unit: 'tsp'),
    ],
    steps: [
      _en('Mix the flour with onion, coriander, cumin, salt and water into a soft dough.'),
      _en('Pat the dough flat, directly on a greased pan or a plastic sheet, into a thin round.'),
      _en('Place it onto a hot pan, poke a few small holes for even cooking, and drizzle a little oil.'),
      _en('Cook on both sides until golden and cooked through.'),
      _en('Serve hot with curd or a chutney.'),
    ],
    nutritionGlance: const ['Iron 2.5mg', 'Fibre 5g', 'Calories 200'],
    videoTitle: 'Cook along: Maharashtrian thalipeeth',
  ),
  Recipe(
    id: 'jain_kadhi_khichdi',
    name: _en('Jain kadhi khichdi'),
    whyNow: _en('A calcium-rich, gut-friendly meal made without onion or '
        'garlic, gentle enough for an off day.'),
    region: RecipeRegion.jain,
    tags: const ['jain', 'calcium', 'digestion'],
    defaultServings: 2,
    ingredients: [
      RecipeIngredient(name: _en('Curd'), qtyPerServing: 0.5, unit: 'cup'),
      RecipeIngredient(name: _en('Besan (gram flour)'), qtyPerServing: 1, unit: 'tbsp'),
      RecipeIngredient(name: _en('Rice'), qtyPerServing: 0.25, unit: 'cup'),
      RecipeIngredient(name: _en('Split moong dal'), qtyPerServing: 0.25, unit: 'cup'),
      RecipeIngredient(name: _en('Cumin seeds and curry leaves'), qtyPerServing: 0.25, unit: 'tsp'),
    ],
    steps: [
      _en('Cook the rice and moong dal together into a soft khichdi.'),
      _en('Whisk curd and besan together with water until smooth.'),
      _en('Cook the curd mixture on low heat, stirring, until it thickens into a kadhi.'),
      _en('Temper cumin seeds and curry leaves in ghee, and stir into the kadhi.'),
      _en('Serve the khichdi with the kadhi poured over or alongside.'),
    ],
    nutritionGlance: const ['Calcium good', 'Protein 8g', 'Calories 200'],
    videoTitle: 'Cook along: Jain kadhi khichdi',
  ),
  Recipe(
    id: 'besan_chilla',
    name: _en('Besan chilla'),
    whyNow: _en('A quick, protein-forward savoury pancake that works for any '
        'meal of the day.'),
    region: RecipeRegion.panIndian,
    tags: const ['protein', 'gestational_diabetes', 't2'],
    defaultServings: 1,
    ingredients: [
      RecipeIngredient(name: _en('Besan (gram flour)'), qtyPerServing: 4, unit: 'tbsp'),
      RecipeIngredient(name: _en('Onion, finely chopped'), qtyPerServing: 0.25, unit: 'pcs'),
      RecipeIngredient(name: _en('Tomato, finely chopped'), qtyPerServing: 0.25, unit: 'pcs'),
      RecipeIngredient(name: _en('Turmeric and red chilli powder'), qtyPerServing: 0.25, unit: 'tsp'),
      RecipeIngredient(name: _en('Oil for the pan'), qtyPerServing: 1, unit: 'tsp'),
    ],
    steps: [
      _en('Whisk besan with water, salt and spices into a smooth, pourable batter.'),
      _en('Stir in the chopped onion and tomato.'),
      _en('Pour a ladle onto a hot, lightly oiled pan and spread thin.'),
      _en('Cook until the base is golden, then flip and cook the other side.'),
      _en('Serve hot with chutney or curd.'),
    ],
    nutritionGlance: const ['Protein 9g', 'Calories 170'],
    videoTitle: 'Cook along: Besan chilla',
  ),
  Recipe(
    id: 'vegetable_daliya',
    name: _en('Vegetable daliya'),
    whyNow: _en('A broken-wheat porridge, light but filling, and a steady '
        'source of fibre for the later months.'),
    region: RecipeRegion.panIndian,
    tags: const ['fibre', 'weight_gain', 't3'],
    defaultServings: 2,
    ingredients: [
      RecipeIngredient(name: _en('Broken wheat (daliya)'), qtyPerServing: 0.33, unit: 'cup'),
      RecipeIngredient(name: _en('Mixed vegetables (carrot, peas, beans)'), qtyPerServing: 0.5, unit: 'cup'),
      RecipeIngredient(name: _en('Ghee'), qtyPerServing: 1, unit: 'tsp'),
      RecipeIngredient(name: _en('Cumin seeds'), qtyPerServing: 0.25, unit: 'tsp'),
    ],
    steps: [
      _en('Dry roast the daliya lightly until fragrant, then set aside.'),
      _en('Heat ghee, temper cumin seeds, and add the vegetables.'),
      _en('Add the roasted daliya and water, about three times the daliya by volume.'),
      _en('Simmer, stirring occasionally, until soft and porridge-like.'),
      _en('Serve warm as a light meal.'),
    ],
    nutritionGlance: const ['Fibre 6g', 'Calories 180'],
    videoTitle: 'Cook along: Vegetable daliya',
  ),
];

/// A clearly-named stub. The integrator wires this to whatever share/print
/// flow the recipe screen eventually gets; today it is a no-op the caller can
/// hook a SnackBar onto.
void shareRecipePlaceholder(String recipeId) {}

// =============================================================================
//  5. Cravings
// =============================================================================

class CravingCard {
  const CravingCard({required this.id, required this.title, required this.body});
  final String id;
  final LocalizedText title;
  final LocalizedText body;
}

final List<CravingCard> kCravingCards = [
  CravingCard(
    id: 'why_cravings_happen',
    title: _en('Why cravings happen'),
    body: _en('Shifting hormones, a heightened sense of smell and taste, and '
        'your body genuinely asking for certain nutrients all play a part. '
        'Cravings are common and, for the most part, harmless to follow in '
        'reasonable amounts.'),
  ),
  CravingCard(
    id: 'common_cravings',
    title: _en('Sour, spicy, sweet, ice'),
    body: _en('Sour and spicy cravings are extremely common and usually '
        'harmless. A pull toward sweet food is worth watching a little if '
        'your doctor is monitoring blood sugar. A strong urge to chew ice is '
        'sometimes, though not always, linked to low iron, worth mentioning '
        'at your next visit if it is frequent.'),
  ),
  CravingCard(
    id: 'sudden_aversions',
    title: _en('Sudden aversions'),
    body: _en('Going off a food you used to love, coffee, garlic, a '
        'particular vegetable, is as common as craving something new. It '
        'usually passes on its own; there is no need to force yourself to '
        'eat something that suddenly turns your stomach.'),
  ),
  CravingCard(
    id: 'pica',
    title: _en('Pica, and when to tell a doctor'),
    body: _en('A rare but real craving for non-food things, chalk, clay, ice '
        'in large amounts, mud, is called pica and is sometimes linked to a '
        'deficiency like low iron. It is genuinely worth mentioning to your '
        'doctor rather than managing quietly on your own.'),
  ),
  CravingCard(
    id: 'loss_of_appetite',
    title: _en('Loss of appetite'),
    body: _en('Especially in the first trimester, not wanting to eat much at '
        'all is common. Small, frequent, plain meals usually work better '
        'than pushing through a full plate. If it continues well into the '
        'second trimester or you are losing weight, mention it to your '
        'doctor.'),
  ),
  CravingCard(
    id: 'eating_for_two_myth',
    title: _en('The "eating for two" myth'),
    body: _en('Pregnancy does need more calories, but nowhere near double. '
        'Most of the extra need is modest and comes later in pregnancy, not '
        'from the first trimester. "Eating for two" as a licence for two '
        'full plates at every meal is the part that is a myth, not the idea '
        'that you need a little more.'),
  ),
];

// =============================================================================
//  6. Diet charts — free, viewable and downloadable
// =============================================================================

enum DietChartCategory { stage, diet, condition, regional, language }

class DietChart {
  const DietChart({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText description;
  final DietChartCategory category;
}

final List<DietChart> kDietCharts = [
  DietChart(
    id: 'full_month_indian',
    title: _en('Full month-by-month Indian chart'),
    description: _en('A complete pregnancy-to-postpartum reference, month by '
        'month, built around an everyday Indian kitchen.'),
    category: DietChartCategory.stage,
  ),
  DietChart(
    id: 't1_chart',
    title: _en('First trimester chart'),
    description: _en('Small, bland, frequent meals built for a queasy '
        'stomach and early folate needs.'),
    category: DietChartCategory.stage,
  ),
  DietChart(
    id: 't2_chart',
    title: _en('Second trimester chart'),
    description: _en('A fuller, protein-and-iron-forward chart for the '
        'stage appetite usually returns.'),
    category: DietChartCategory.stage,
  ),
  DietChart(
    id: 't3_chart',
    title: _en('Third trimester chart'),
    description: _en('Smaller, more frequent meals as room runs short, with '
        'steady protein and iron through to labour.'),
    category: DietChartCategory.stage,
  ),
  DietChart(
    id: 'hindi_chart',
    title: _en('Hindi chart'),
    description: _en('The same everyday guidance, written out in Hindi for '
        'the household to read together.'),
    category: DietChartCategory.language,
  ),
  DietChart(
    id: 'vegetarian_chart',
    title: _en('Vegetarian chart'),
    description: _en('A full vegetarian week built to hit protein, iron and '
        'B12 without meat, egg or fish.'),
    category: DietChartCategory.diet,
  ),
  DietChart(
    id: 'non_vegetarian_chart',
    title: _en('Non-vegetarian chart'),
    description: _en('A full week that folds in chicken, fish and egg '
        'alongside the everyday thali.'),
    category: DietChartCategory.diet,
  ),
  DietChart(
    id: 'gestational_diabetes_chart',
    title: _en('Gestational diabetes chart'),
    description: _en('A steadier-blood-sugar week: smaller meals, carbs '
        'paired with protein and fibre.'),
    category: DietChartCategory.condition,
  ),
  DietChart(
    id: 'weight_gain_chart',
    title: _en('Healthy weight-gain chart'),
    description: _en('Calorie-dense, nutritious meals for steady gain '
        'without needing huge portions.'),
    category: DietChartCategory.condition,
  ),
  DietChart(
    id: 'regional_bengali',
    title: _en('Bengali regional chart'),
    description: _en('A week of everyday Bengali cooking, built for balanced '
        'pregnancy nutrition.'),
    category: DietChartCategory.regional,
  ),
  DietChart(
    id: 'regional_tamil',
    title: _en('Tamil regional chart'),
    description: _en('A week of everyday Tamil cooking, built for balanced '
        'pregnancy nutrition.'),
    category: DietChartCategory.regional,
  ),
  DietChart(
    id: 'regional_punjabi',
    title: _en('Punjabi regional chart'),
    description: _en('A week of everyday Punjabi cooking, built for balanced '
        'pregnancy nutrition.'),
    category: DietChartCategory.regional,
  ),
  DietChart(
    id: 'regional_gujarati',
    title: _en('Gujarati regional chart'),
    description: _en('A week of everyday Gujarati cooking, built for '
        'balanced pregnancy nutrition.'),
    category: DietChartCategory.regional,
  ),
  DietChart(
    id: 'regional_south_indian',
    title: _en('South Indian regional chart'),
    description: _en('A week of everyday South Indian cooking, built for '
        'balanced pregnancy nutrition.'),
    category: DietChartCategory.regional,
  ),
  DietChart(
    id: 'regional_jain',
    title: _en('Jain regional chart'),
    description: _en('A week without onion, garlic or root vegetables, built '
        'for balanced pregnancy nutrition.'),
    category: DietChartCategory.regional,
  ),
];

/// A clearly-named stub. Downloading a real PDF is a follow-up piece of work;
/// this exists so the download button has something honest to call today.
void downloadDietChartPlaceholder(String chartId) {}

// =============================================================================
//  7. Fasting
// =============================================================================

class FastingTopic {
  const FastingTopic({required this.id, required this.title, required this.body});
  final String id;
  final LocalizedText title;
  final LocalizedText body;
}

/// The five named fasts, shown first.
final List<FastingTopic> kFastingByOccasion = [
  FastingTopic(
    id: 'navratri',
    title: _en('Navratri'),
    body: _en('A Navratri fast usually allows fruit, milk, sabudana, '
        'kuttu and singhara flour, and rock salt, which makes it easier to '
        'keep nutritious than many other fasts. Spread these across the day '
        'rather than one heavy meal, and keep drinking water and fluids '
        'through the fast.'),
  ),
  FastingTopic(
    id: 'ramzan',
    title: _en('Ramzan'),
    body: _en('A dawn-to-dusk fast with no food or water is a much bigger '
        'ask in pregnancy than a partial fast, and Islamic guidance itself '
        'generally excuses pregnant women from fasting, with the fast made '
        'up later or through charity instead. This is worth discussing with '
        'both your doctor and your religious guidance before deciding.'),
  ),
  FastingTopic(
    id: 'karva_chauth',
    title: _en('Karva Chauth'),
    body: _en('A full day without food or water is hard on anyone, and more '
        'so in pregnancy, where dehydration and low blood sugar come on '
        'faster. Many mothers choose a modified version, sipping water or '
        'eating lightly, and that is a reasonable adjustment, not a lesser '
        'observance.'),
  ),
  FastingTopic(
    id: 'ekadashi',
    title: _en('Ekadashi'),
    body: _en('Ekadashi fasting styles vary widely, from grain-free to a '
        'single meal to complete abstinence. Whatever your usual practice, '
        'a grain-free but otherwise normal-eating version is usually the '
        'easiest to keep safe in pregnancy.'),
  ),
  FastingTopic(
    id: 'jain_fasts',
    title: _en('Jain fasts'),
    body: _en('Jain fasting can range from avoiding root vegetables to a '
        'full day of water only. Pregnancy is widely considered a valid '
        'reason to observe a lighter form of the fast, worth discussing '
        'with your family and, where relevant, a religious guide alongside '
        'your doctor.'),
  ),
];

/// General, non-preachy safety guidance, shown alongside the named fasts.
final List<FastingTopic> kFastingGeneral = [
  FastingTopic(
    id: 'should_i_fast',
    title: _en('Should I fast at all?'),
    body: _en('This is genuinely your call to make, alongside your doctor, '
        'weighing your own health, how the pregnancy is going, and what the '
        'fast means to you. Nobody here is going to tell you not to fast, '
        'only to make sure it is a safe version if you choose to.'),
  ),
  FastingTopic(
    id: 'how_to_fast_safely',
    title: _en('How to fast safely'),
    body: _en('Where the fast allows it, keep sipping water and fluids '
        'through the day. Break a fast gently, a fruit or a light bite '
        'rather than a heavy meal all at once. Keep a piece of fruit or a '
        'snack on hand in case you need to stop.'),
  ),
  FastingTopic(
    id: 'when_to_skip',
    title: _en('When to skip it this year'),
    body: _en('Dizziness, a headache that will not lift, reduced baby '
        'movement, or simply feeling unwell are all good reasons to break a '
        'fast, this year, without guilt. A high-risk pregnancy is also worth '
        'a direct conversation with your doctor before you decide to fast at '
        'all.'),
  ),
];
