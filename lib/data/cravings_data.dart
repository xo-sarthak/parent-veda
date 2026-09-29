// =============================================================================
//  Cravings — the food list, and what she can actually do about each one
// -----------------------------------------------------------------------------
//  ⚠️ THIS REPLACES A PAGE OF REASSURANCE WITH A PAGE THAT ANSWERS SOMETHING.
//
//  The old Cravings screen was six text cards — why cravings happen, sudden
//  aversions, the eating-for-two myth. All true, all worth keeping, and none of
//  it the reason anyone opens that page. A mother opens it at 9pm wanting
//  golgappa, and the question in her head is not "why do cravings happen"; it
//  is "can I have this, and if not, what instead".
//
//  So the page is now a LIST OF THE FOODS, and every one of them answers four
//  things: can she, at HER stage · why she is craving it · what to have instead
//  when the answer is no · and how to make a safe version at home. The six
//  explainer cards survive, moved below the list where they read as context
//  rather than as the answer.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY THE VERDICT IS PER-TRIMESTER AND NOT ONE FLAG
//  ---------------------------------------------------------------------------
//  Because for several of these it genuinely changes, and a single verdict
//  would have to pick the most cautious one and apply it for nine months.
//  Papaya is the clearest case: unripe papaya is off the table throughout, but
//  the caution that matters most is early. Caffeine guidance tightens as
//  pregnancy goes on. Salt-heavy pickle matters most in the third trimester,
//  when swelling and blood pressure are being watched.
//
//  Telling a mother at 34 weeks the same thing we told her at 6 is how an app
//  gets ignored: she knows her pregnancy has changed even if the page does not.
//
//  ⚠️ AND THE STAGE ANSWER IS SHOWN, NEVER COMPUTED INTO A PROBABILITY. "At 30
//  weeks, small amounts are fine" is guidance keyed to a number she already
//  has. It is not a personalised risk score, which CLAUDE.md's clinical
//  invariants forbid outright.
//
//  ⚠️ SEPARATE FILE, NOT APPENDED TO `nutrition_data.dart`. That file is
//  already 2,266 lines and holds seven sections; this is an eighth thing with
//  its own model, and the only cost of splitting it is one import.
//
//  ⚠️ ENGLISH ONLY FOR NOW — `_en(...)`, Hindi owed, same as the rest of
//  Nutrition.
// =============================================================================

import '../localization/app_language.dart';
import 'nutrition_data.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// A home version of a craving, for when the shop-bought one is the problem
/// rather than the food.
///
/// ⚠️ THE POINT IS SUBSTITUTION, NOT COOKERY. Most of these exist because the
/// risk lives in how a thing is made outside — the water in golgappa, the
/// unpasteurised milk in thela kulfi, the sauce that has been standing — and
/// not in what she is actually craving. A recipe here is the shortest honest
/// route to "yes".
class CravingRecipe {
  const CravingRecipe({
    required this.name,
    required this.minutes,
    required this.ingredients,
    required this.steps,
    this.note,
  });

  final LocalizedText name;
  final int minutes;
  final List<LocalizedText> ingredients;
  final List<LocalizedText> steps;

  /// One line on what makes this version the safe one.
  final LocalizedText? note;
}

/// One food women commonly crave, answered at her stage.
class CravingItem {
  const CravingItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.verdict,
    required this.why,
    required this.stageNotes,
    this.verdictByTrimester = const {},
    this.modification,
    this.whenToAvoid,
    this.alternatives = const [],
    this.recipe,
    this.talkToDoctor = false,
    this.foodId,
    this.aliases = const [],
  });

  final String id;
  final String emoji;
  final LocalizedText name;

  /// The answer when nothing stage-specific applies.
  final NutritionVerdict verdict;

  /// ⚠️ TRIMESTER OVERRIDES, AND AN EMPTY MAP IS THE COMMON CASE. Only the
  /// foods whose answer genuinely moves carry entries here; padding the rest
  /// with three identical values would make the data look like it says more
  /// than it does.
  final Map<int, NutritionVerdict> verdictByTrimester;

  /// Why the craving happens — the thing she is half-wondering underneath.
  final LocalizedText why;

  /// Keyed 1 / 2 / 3. Every item carries all three: this is the sentence that
  /// makes the page hers rather than a leaflet, so a missing one is a hole she
  /// would notice.
  final Map<int, LocalizedText> stageNotes;

  /// "Yes, if…" — how to have it safely rather than not at all.
  final LocalizedText? modification;

  final LocalizedText? whenToAvoid;

  /// Shown only when the verdict at her stage is limit or avoid. Never for a
  /// plain yes — offering a substitute for something she can simply have reads
  /// as disapproval dressed up as help.
  final List<LocalizedText> alternatives;

  final CravingRecipe? recipe;

  /// ⚠️ THE SAFETY FLOOR. Ice-chewing and non-food cravings are the two here
  /// that are not food questions at all — both can point at low iron. These
  /// route to a doctor and carry no alternatives, because "have this instead"
  /// would be a confident answer to the wrong question.
  final bool talkToDoctor;

  /// The `FoodEntry` this corresponds to, where one exists — so the craving
  /// page and "Can I eat this?" cannot drift into two different answers about
  /// the same food.
  final String? foodId;

  final List<String> aliases;

  /// Her answer, at [trimester].
  NutritionVerdict verdictAt(int trimester) =>
      verdictByTrimester[trimester] ?? verdict;

  LocalizedText? stageNoteAt(int trimester) => stageNotes[trimester];

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (name.en.toLowerCase().contains(q)) return true;
    if (name.hi.toLowerCase().contains(q)) return true;
    return aliases.any((a) => a.toLowerCase().contains(q));
  }
}

final List<CravingItem> kCravingItems = [
  CravingItem(
    id: 'golgappa',
    emoji: '🥟',
    name: _en('Golgappa / pani puri'),
    verdict: NutritionVerdict.limit,
    aliases: ['pani puri', 'puchka', 'gol gappa', 'street food', 'chaat'],
    why: _en("Sour, cold, sharp and salty all at once. It hits almost every "
        "craving pregnancy brings, which is why it's the most wanted thing in "
        "an Indian pregnancy."),
    stageNotes: {
      1: _en("The craving is usually strongest now, and so is the reason to be "
          "careful. A stomach infection on top of early nausea is miserable "
          "and can dehydrate you fast."),
      2: _en("Your appetite is back and this is often what you want most. "
          "Home-made is a real yes. Roadside is still a gamble on the water."),
      3: _en("Same rule, plus one thing: watch the salt in the pani now if "
          "anyone has mentioned swelling or blood pressure."),
    },
    modification: _en("Made at home with filtered water, and pudina washed in "
        "filtered water, it's a clear yes. The risk was never the golgappa. "
        "It's the water it was dipped in."),
    whenToAvoid: _en("Roadside pani, especially in summer or anywhere you "
        "can't see how the water is stored. Typhoid and hepatitis A both "
        "spread this way, and both are worse in pregnancy."),
    alternatives: [
      _en('The same flavours in a chaat you put together yourself, like sev '
          'puri or bhel, which need no standing water at all.'),
      _en("Jaljeera or nimbu pani with black salt, if it's the sour, sharp "
          "taste you want more than the crunch."),
    ],
    recipe: CravingRecipe(
      name: _en('Home pani puri, safely'),
      minutes: 20,
      note: _en("Everything risky about golgappa is in the pani. Make that "
          "part yourself and the rest is just a snack."),
      ingredients: [
        _en('Ready puris: 12 to 15, from a sealed packet'),
        _en('Fresh pudina: 1 cup, washed in filtered water'),
        _en('Fresh coriander: 1/2 cup'),
        _en('Green chilli: 1 small, or skip it'),
        _en('Ginger: a small piece'),
        _en('Roasted jeera powder: 1 tsp'),
        _en('Black salt and regular salt: to taste, go light'),
        _en('Imli pulp: 2 tbsp'),
        _en('Filtered or boiled-and-cooled water: 3 cups'),
        _en('Boiled potato and white chana: for the filling'),
      ],
      steps: [
        _en('Wash the pudina and coriander in filtered water, not tap. This is '
            'the step that matters most.'),
        _en('Grind the pudina, coriander, chilli and ginger to a smooth '
            'paste.'),
        _en('Mix into the filtered water with the imli pulp, jeera powder and '
            'both salts.'),
        _en("Chill for 30 minutes. Don't add ice made from tap water."),
        _en('Fill the puris with mashed potato and chana, and eat straight '
            'away.'),
      ],
    ),
  ),
  CravingItem(
    id: 'imli',
    emoji: '🟤',
    name: _en('Imli / tamarind'),
    verdict: NutritionVerdict.safe,
    aliases: ['tamarind', 'khatta', 'sour'],
    why: _en('Wanting something sour is one of the most common and harmless '
        'cravings there is, and imli is usually the first thing you reach '
        'for.'),
    stageNotes: {
      1: _en('Very common right now, and often helpful. The sourness settles '
          'nausea for a lot of women.'),
      2: _en('Fine to enjoy. The only thing to watch is your teeth, which '
          'soften a little in pregnancy.'),
      3: _en("Still fine. If you're taking iron tablets, leave a gap around "
          "them instead of having imli at the same time."),
    },
    modification: _en("Plain imli is fine. Imli candy is mostly salt and sugar "
        "with a little imli in it, which isn't the same thing."),
    recipe: CravingRecipe(
      name: _en('Imli-gud chutney'),
      minutes: 15,
      note: _en('It keeps for a week in the fridge, and the gud adds a little '
          'iron to a sour craving.'),
      ingredients: [
        _en('Imli: a lemon-sized ball, soaked'),
        _en('Gud (jaggery): 3 tbsp'),
        _en('Roasted jeera powder: 1 tsp'),
        _en('Saunf powder: 1/2 tsp'),
        _en('Black salt: a pinch'),
      ],
      steps: [
        _en('Soak the imli in warm water for 20 minutes and squeeze out the '
            'pulp.'),
        _en('Simmer the pulp with the gud until it thickens slightly.'),
        _en('Stir in the jeera, saunf and black salt. Cool before storing.'),
      ],
    ),
  ),
  CravingItem(
    id: 'ice_chewing',
    emoji: '🧊',
    name: _en('Chewing ice'),
    verdict: NutritionVerdict.limit,
    talkToDoctor: true,
    aliases: ['ice', 'pagophagia', 'barf'],
    why: _en("A strong, repeated urge to chew ice is one of the better-known "
        "signs of low iron. It isn't always that. Plenty of women just find it "
        "cooling. But it's common enough that it's worth mentioning to your "
        "doctor instead of keeping it to yourself."),
    stageNotes: {
      1: _en("Mention it at your next visit. Your iron is usually checked in "
          "your early blood tests anyway, so it costs nothing to ask."),
      2: _en("This is when anaemia is most often found in India. If you're "
          "chewing ice every day, ask for your haemoglobin to be checked."),
      3: _en("Tell your doctor now, don't wait. Iron matters more in the last "
          "trimester, both for you and for the birth."),
    },
    whenToAvoid: _en("The habit is hard on your tooth enamel, which is "
        "already softer in pregnancy. If you're going to, crushed ice is "
        "kinder than cubes."),
    // ⚠️ NO ALTERNATIVES ON PURPOSE. "Try cold cucumber instead" answers a
    // craving question when the useful answer is a blood test. See
    // `talkToDoctor` on the model.
  ),
  CravingItem(
    id: 'pickle',
    emoji: '🥒',
    name: _en('Achaar / pickle'),
    verdict: NutritionVerdict.limit,
    aliases: ['achar', 'pickle', 'namkeen', 'salty'],
    why: _en('Sharp, salty and sour: the same craving as imli, in a different '
        'jar. Very common, and mostly harmless in small amounts.'),
    stageNotes: {
      1: _en('A spoonful with a meal is fine, and the sourness often helps '
          'with nausea.'),
      2: _en('Fine in small amounts. If heartburn has started, watch how much '
          'oil comes with it.'),
      3: _en('Now is the time to go lighter. Pickle is very high in salt, and '
          'salt matters if your swelling or blood pressure is being watched.'),
    },
    modification: _en('A spoonful, not a bowl. Drain the oil off against the '
        'side of the jar.'),
    whenToAvoid: _en('If your doctor has mentioned raised blood pressure, '
        'preeclampsia or swelling, keep pickle for now and then, not every '
        'day.'),
    alternatives: [
      _en('Fresh lemon squeezed over your meal. The same sour lift, with none '
          'of the salt.'),
      _en('Kachumber with amchoor and black salt, made fresh.'),
    ],
  ),
  CravingItem(
    id: 'sweets',
    emoji: '🍬',
    name: _en('Mithai and sweets'),
    verdict: NutritionVerdict.limit,
    aliases: ['sweet', 'mithai', 'sugar', 'dessert', 'chocolate'],
    why: _en('A sweet craving in pregnancy is usually ordinary. You have more '
        'appetite, you need more energy, and your body is used to something '
        'sweet at a certain time of day.'),
    stageNotes: {
      1: _en("Whatever stays down is a good day. Don't overthink sweets right "
          "now."),
      2: _en('Fine in normal amounts. This is the trimester the sugar test is '
          'usually done, around 24 to 28 weeks.'),
      3: _en("If your sugar test (OGTT) flagged anything, sweets are the first "
          "thing your doctor will talk about. If it didn't, normal amounts are "
          "fine."),
    },
    whenToAvoid: _en("If you've been told you have gestational diabetes, this "
        "is no longer a general question. It's part of your doctor's plan, so "
        "follow theirs, not this page."),
    alternatives: [
      _en('Dates or a piece of gud. Sweet, and they bring some iron with them.'),
      _en('Fruit with thick curd, which slows the sugar down.'),
      _en('A small piece of dark chocolate instead of a full mithai.'),
    ],
    recipe: CravingRecipe(
      name: _en('Date and nut ladoo'),
      minutes: 20,
      note: _en('No added sugar at all, and enough iron and calcium to do you '
          'some good.'),
      ingredients: [
        _en('Seedless dates: 1 cup, packed'),
        _en('Almonds: 1/2 cup'),
        _en('Walnuts: 1/4 cup'),
        _en('Til (sesame): 2 tbsp'),
        _en('Ghee: 1 tsp'),
        _en('Elaichi powder: a pinch'),
      ],
      steps: [
        _en('Dry-roast the nuts and til lightly, then chop them coarse.'),
        _en('Warm the ghee, add the chopped dates, and mash until they come '
            'together as a paste.'),
        _en('Mix in the nuts, til and elaichi. Cool slightly.'),
        _en('Roll into small ladoos. They keep for a week in the fridge.'),
      ],
    ),
  ),
  CravingItem(
    id: 'ice_cream',
    emoji: '🍨',
    name: _en('Ice cream and kulfi'),
    verdict: NutritionVerdict.limit,
    aliases: ['icecream', 'kulfi', 'cold', 'dessert'],
    why: _en("Cold, sweet and soothing. If you have heartburn, it's often just "
        "what your body is asking for."),
    stageNotes: {
      1: _en('Often one of the few things that stays down. Packet ice cream '
          'from a shop with a working freezer is fine.'),
      2: _en('Fine in normal amounts.'),
      3: _en('Fine, and often one of the best things for heartburn. Watch the '
          'sugar if your sugar test (OGTT) flagged anything.'),
    },
    modification: _en("Sealed, branded, and from a freezer that has clearly "
        "stayed cold. Skip soft-serve from a machine you can't see being "
        "cleaned, and thela kulfi made with unpasteurised milk."),
    whenToAvoid: _en("Anything that has half-melted and been refrozen. That's "
        "where the listeria risk is, not in ice cream itself."),
    alternatives: [
      _en('Frozen curd with fruit blended through it.'),
      _en('A home kulfi made from boiled, cooled milk.'),
    ],
    recipe: CravingRecipe(
      name: _en('Mango-curd kulfi'),
      minutes: 15,
      note: _en('Made from boiled milk and set at home, so the two things that '
          'make shop kulfi a worry, the milk and the freezer, are both in your '
          'hands.'),
      ingredients: [
        _en('Full-fat milk: 2 cups, boiled and cooled'),
        _en('Thick curd: 1/2 cup'),
        _en('Ripe mango pulp: 1 cup'),
        _en('Sugar or gud: 2 tbsp, or skip if the mango is sweet'),
        _en('Elaichi powder: a pinch'),
      ],
      steps: [
        _en("Boil the milk, then cool it fully. Don't skip the boil."),
        _en('Blend with the curd, mango pulp, sweetener and elaichi.'),
        _en('Pour into moulds and freeze for 6 hours.'),
      ],
    ),
  ),
  CravingItem(
    id: 'chai_coffee',
    emoji: '☕',
    name: _en('Chai and coffee'),
    verdict: NutritionVerdict.limit,
    foodId: 'coffee',
    aliases: ['tea', 'chai', 'coffee', 'caffeine', 'filter coffee'],
    why: _en('As much habit as craving. In the first trimester it can even go '
        'the other way: a cup you have had every morning for years can '
        'suddenly smell wrong.'),
    stageNotes: {
      1: _en("Around two cups a day is the usual guidance. Many women go off "
          "it completely right now, and that's fine too."),
      2: _en('Same limit: roughly 200mg of caffeine a day, which is about two '
          'cups of instant coffee or three of home chai.'),
      3: _en('Same limit. Keep tea and coffee an hour away from iron tablets '
          'and iron-rich meals, because they block the iron.'),
    },
    modification: _en('Weaker, and fewer. A light home chai has much less '
        'caffeine than a filter coffee or a café cup.'),
    alternatives: [
      _en('Saunf or ajwain water. Warm, and it helps digestion.'),
      _en('Milk with a little haldi in the evening.'),
      _en('Decaf, which keeps the habit without the caffeine.'),
    ],
  ),
  CravingItem(
    id: 'spicy',
    emoji: '🌶️',
    name: _en('Very spicy food'),
    verdict: NutritionVerdict.safe,
    verdictByTrimester: {3: NutritionVerdict.limit},
    aliases: ['spice', 'chilli', 'teekha', 'masala'],
    why: _en("Very common, and the old belief that it harms the baby isn't "
        "true. Chilli doesn't reach your baby. It stops at your own stomach."),
    stageNotes: {
      1: _en("Eat what appeals. If it comes back up, that's the nausea, not the "
          "chilli doing harm."),
      2: _en('Fine. This is usually the easiest trimester for spice.'),
      3: _en("Still safe for your baby, but the acidity can bother you now that "
          "there's less room and heartburn is common. Most women cut back on "
          "their own by now."),
    },
    whenToAvoid: _en("When heartburn has started. That's a comfort limit, not a "
        "safety one. It helps to know the difference, so you don't give up "
        "food you never needed to."),
    alternatives: [
      _en('Flavour without the heat: more jeera, dhania and kali mirch, less '
          'red chilli.'),
      _en('Curd or a glass of milk with the meal, not after it.'),
    ],
  ),
  CravingItem(
    id: 'raw_mango',
    emoji: '🥭',
    name: _en('Raw mango / kaccha aam'),
    verdict: NutritionVerdict.safe,
    foodId: 'mango',
    aliases: ['kacha aam', 'green mango', 'amchoor', 'sour'],
    why: _en('The sour craving again, in season. It also has plenty of vitamin '
        'C, which helps you absorb the iron in the same meal.'),
    stageNotes: {
      1: _en('Fine, and often welcome. Sour flavours settle nausea for many '
          'women.'),
      2: _en("Fine. Have it with a meal and the vitamin C helps you absorb that "
          "meal's iron."),
      3: _en('Fine. If your swelling is being watched, go easy on the salt and '
          'chilli that usually come with it.'),
    },
    modification: _en("Wash it well and peel it. The care is about the skin and "
        "what was on it, not the fruit."),
  ),
  CravingItem(
    id: 'papaya',
    emoji: '🍈',
    name: _en('Papaya'),
    verdict: NutritionVerdict.limit,
    verdictByTrimester: {1: NutritionVerdict.avoid},
    foodId: 'papaya',
    aliases: ['papita', 'raw papaya', 'kaccha papita'],
    why: _en("You might crave it like any sweet fruit. It's also the most "
        "asked food question in an Indian pregnancy, so the craving often "
        "comes with a worry."),
    stageNotes: {
      1: _en('Leave it for now. Unripe papaya has latex that can cause '
          'contractions, and early pregnancy is when that caution is taken '
          'most seriously.'),
      2: _en('Fully ripe papaya (soft, deep orange, no white sap) is generally '
          'considered fine in normal amounts. Unripe or half-ripe is still '
          'off.'),
      3: _en("Same as the second trimester: ripe is fine, unripe isn't. If your "
          "own doctor has told you to avoid it completely, follow them."),
    },
    modification: _en('Ripe only, and clearly ripe: soft to the touch, deep '
        'orange inside, no milky sap at the stem.'),
    whenToAvoid: _en("Any papaya that is green, firm, or leaks white sap when "
        "cut. That's the one the warning has always been about."),
    alternatives: [
      _en('Ripe mango, chikoo or banana. Sweet, soft, and no argument at home.'),
      _en('If you want papita for digestion, soaked figs or a bowl of curd do '
          'the same job.'),
    ],
  ),
  CravingItem(
    id: 'chinese',
    emoji: '🍜',
    name: _en('Chowmein and Indo-Chinese'),
    verdict: NutritionVerdict.limit,
    aliases: ['noodles', 'chowmein', 'hakka', 'manchurian', 'msg', 'ajinomoto'],
    why: _en("Salt, oil and a strong savoury taste. That's what a pregnancy "
        "craving often wants when it isn't asking for sour or sweet."),
    stageNotes: {
      1: _en('Fine now and then. Make sure it is freshly cooked and hot.'),
      2: _en('Fine now and then. Ask for less ajinomoto if the place will do '
          'it.'),
      3: _en('Go lighter now. This food is very high in salt, and salt matters '
          'if your swelling or blood pressure is being watched.'),
    },
    modification: _en('Freshly cooked, eaten hot, from a busy place. Reheated '
        'noodles that have been sitting out are the real risk.'),
    whenToAvoid: _en('Cold or lukewarm noodles, and anything in a sauce that '
        'has been standing.'),
    alternatives: [
      _en('Home hakka noodles with plenty of vegetables and half the salt.'),
      _en("Vegetable soup with noodles in it, if it's something warm and "
          "savoury you want."),
    ],
    recipe: CravingRecipe(
      name: _en('Home veg hakka noodles'),
      minutes: 25,
      note: _en('No ajinomoto, half the salt, twice the vegetables, and hot off '
          'your own stove, which was the real issue.'),
      ingredients: [
        _en('Hakka noodles: 1 packet'),
        _en('Cabbage, carrot, capsicum, spring onion: 2 cups, shredded'),
        _en('Garlic: 4 cloves, chopped'),
        _en('Soy sauce: 1 tbsp'),
        _en('Vinegar: 1 tsp'),
        _en('Kali mirch: to taste'),
        _en('Oil: 1 tbsp'),
      ],
      steps: [
        _en('Boil the noodles, drain, and toss with a few drops of oil.'),
        _en('Fry the garlic on high heat, then the vegetables for 2 minutes '
            'only, so they stay crisp.'),
        _en('Add the noodles, soy, vinegar and pepper. Toss and serve hot.'),
      ],
    ),
  ),
  CravingItem(
    id: 'curd',
    emoji: '🥛',
    name: _en('Curd and lassi'),
    verdict: NutritionVerdict.safe,
    foodId: 'curd_yogurt',
    aliases: ['dahi', 'yogurt', 'lassi', 'chaas', 'buttermilk'],
    why: _en('Cooling, easy on a sour stomach, and one of the few things that '
        'reliably helps heartburn. A craving worth following.'),
    stageNotes: {
      1: _en('Helpful for nausea, and it stays down when little else does.'),
      2: _en('Fine and good: calcium and protein, and you need more of both '
          'now.'),
      3: _en('Fine, and one of the better answers to heartburn in the last '
          'months.'),
    },
    modification: _en('Set at home or from a sealed packet. Skip loose curd '
        'sold open in a market.'),
    recipe: CravingRecipe(
      name: _en('Salted jeera chaas'),
      minutes: 5,
      note: _en('Five minutes, and it helps heartburn more than most things '
          'sold for it.'),
      ingredients: [
        _en('Thick curd: 1/2 cup'),
        _en('Cold water: 1 cup'),
        _en('Roasted jeera powder: 1/2 tsp'),
        _en('Black salt: a pinch'),
        _en('Pudina leaves: a few, washed'),
      ],
      steps: [
        _en('Whisk the curd smooth, then whisk in the water.'),
        _en('Add the jeera, black salt and crushed pudina.'),
        _en("Serve cold. Don't add ice made from tap water."),
      ],
    ),
  ),
  CravingItem(
    id: 'non_food',
    emoji: '⚠️',
    name: _en('Chalk, mud or ash'),
    verdict: NutritionVerdict.avoid,
    talkToDoctor: true,
    aliases: ['pica', 'mitti', 'chalk', 'clay', 'ash', 'raakh', 'khadiya'],
    why: _en("A craving for things that aren't food is called pica. It's real, "
        "there's nothing to be embarrassed about, and it's often linked to low "
        "iron or zinc. That can be treated, and it says nothing about you."),
    stageNotes: {
      1: _en('Tell your doctor at your next visit. Early blood tests will '
          'usually show whether iron is behind it.'),
      2: _en("Please mention it. It's common enough in India that your doctor "
          "won't be surprised, and the fix is often just iron."),
      3: _en("Tell your doctor now, not at delivery. Low iron in the last "
          "trimester matters for how the birth goes."),
    },
    whenToAvoid: _en("Always. Mud and ash can carry lead, parasites and "
        "bacteria, and chalk blocks the very iron you're short of. So it makes "
        "the cause of the craving worse."),
    // No alternatives and no recipe: the answer to this one is a blood test.
  ),
];

CravingItem? cravingById(String id) {
  for (final c in kCravingItems) {
    if (c.id == id) return c;
  }
  return null;
}
