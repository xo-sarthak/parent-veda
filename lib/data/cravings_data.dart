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
    why: _en('Sour, cold, sharp and salty all at once — it hits almost every '
        'craving pregnancy tends to produce, which is why it is the most-'
        'wanted thing in an Indian pregnancy.'),
    stageNotes: {
      1: _en('The craving is usually strongest now, and so is the reason to be '
          'careful: a stomach infection on top of first-trimester nausea is '
          'genuinely miserable and can dehydrate you fast.'),
      2: _en('Appetite is back and this is often the thing you want most. '
          'Home-made is a real yes; roadside is still a gamble on the water.'),
      3: _en('Same rule, one addition — the salt in the pani is worth watching '
          'now if anyone has mentioned swelling or blood pressure.'),
    },
    modification: _en('Made at home with filtered water, and pudina washed in '
        'filtered water, this is a straightforward yes. The risk was never the '
        'golgappa — it is the water it was dipped in.'),
    whenToAvoid: _en('Roadside pani, especially in summer or anywhere you '
        'cannot see how the water is stored. Typhoid and hepatitis A both '
        'travel this way, and both are worse in pregnancy.'),
    alternatives: [
      _en('The same flavours as a chaat you assemble yourself — sev puri or '
          'bhel, which need no standing water at all.'),
      _en('Jaljeera or nimbu-pani with black salt, if it is the sour-and-sharp '
          'hit you are after rather than the crunch.'),
    ],
    recipe: CravingRecipe(
      name: _en('Home pani puri, safely'),
      minutes: 20,
      note: _en('Everything risky about golgappa is in the pani. Make that '
          'part yourself and the rest is just a snack.'),
      ingredients: [
        _en('Ready puris — 12 to 15, from a sealed packet'),
        _en('Fresh pudina — 1 cup, washed in filtered water'),
        _en('Fresh coriander — 1/2 cup'),
        _en('Green chilli — 1 small, or skip it'),
        _en('Ginger — a small piece'),
        _en('Roasted jeera powder — 1 tsp'),
        _en('Black salt and regular salt — to taste, go light'),
        _en('Imli pulp — 2 tbsp'),
        _en('Filtered or boiled-and-cooled water — 3 cups'),
        _en('Boiled potato and white chana — for the filling'),
      ],
      steps: [
        _en('Wash the pudina and coriander in filtered water, not tap. This is '
            'the step that matters most.'),
        _en('Grind the pudina, coriander, chilli and ginger to a smooth '
            'paste.'),
        _en('Mix into the filtered water with the imli pulp, jeera powder and '
            'both salts.'),
        _en('Chill for 30 minutes. Do not add ice made from tap water.'),
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
    why: _en('A pull towards sour is one of the most common and most harmless '
        'cravings there is, and imli is usually the first thing it lands on.'),
    stageNotes: {
      1: _en('Very common right now, and often genuinely helpful — the '
          'sourness settles nausea for a lot of women.'),
      2: _en('Fine to enjoy. Nothing to watch beyond your own teeth, which '
          'soften a little in pregnancy.'),
      3: _en('Still fine. If you are taking iron tablets, leave a gap around '
          'them rather than eating imli alongside.'),
    },
    modification: _en('Plain imli is fine. Imli candy is mostly salt and sugar '
        'with a little imli in it, which is a different thing.'),
    recipe: CravingRecipe(
      name: _en('Imli-gud chutney'),
      minutes: 15,
      note: _en('Keeps a week in the fridge, and turns a sour craving into '
          'something with a little iron in it from the gud.'),
      ingredients: [
        _en('Imli — a lemon-sized ball, soaked'),
        _en('Gud (jaggery) — 3 tbsp'),
        _en('Roasted jeera powder — 1 tsp'),
        _en('Saunf powder — 1/2 tsp'),
        _en('Black salt — a pinch'),
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
    why: _en('A strong, repeated urge to chew ice is one of the better-known '
        'signals of low iron. It is not always that — plenty of women simply '
        'find it cooling — but it is common enough to be worth saying out loud '
        'rather than managing quietly.'),
    stageNotes: {
      1: _en('Worth mentioning at your next visit. Iron stores are usually '
          'checked in early bloodwork anyway, so it costs nothing to ask.'),
      2: _en('This is the stage anaemia is most often picked up in India. If '
          'you are chewing ice daily, ask for your haemoglobin to be looked '
          'at.'),
      3: _en('Say it to your doctor now rather than waiting. Iron matters more '
          'in the last trimester, both for you and for delivery.'),
    },
    whenToAvoid: _en('The habit itself is hard on tooth enamel, which is '
        'already softer in pregnancy. Crushed ice is kinder than cubes if you '
        'are going to.'),
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
    why: _en('Sharp, salty and sour — the same craving that lands on imli, '
        'wearing a different jar. Very common and mostly harmless in small '
        'amounts.'),
    stageNotes: {
      1: _en('A spoonful with a meal is fine, and the sourness often helps '
          'with nausea.'),
      2: _en('Fine in small amounts. Keep an eye on how much oil comes with it '
          'if heartburn has started.'),
      3: _en('This is the stage to go lighter. Pickle is very high in salt, '
          'and salt is what matters if swelling or blood pressure is being '
          'watched.'),
    },
    modification: _en('A spoonful, not a bowl — and drain the oil off against '
        'the side of the jar.'),
    whenToAvoid: _en('If your doctor has mentioned raised blood pressure, '
        'preeclampsia or swelling, treat pickle as occasional rather than '
        'daily.'),
    alternatives: [
      _en('Fresh lemon squeezed over the meal — the same sour lift, none of '
          'the salt.'),
      _en('Kachumber with amchoor and black salt, made fresh.'),
    ],
  ),
  CravingItem(
    id: 'sweets',
    emoji: '🍬',
    name: _en('Mithai and sweets'),
    verdict: NutritionVerdict.limit,
    aliases: ['sweet', 'mithai', 'sugar', 'dessert', 'chocolate'],
    why: _en('A sweet craving in pregnancy is usually ordinary — more '
        'appetite, more energy needed, and a body used to a sugar hit at a '
        'particular time of day.'),
    stageNotes: {
      1: _en('Whatever stays down is a good day. Do not overthink sweets right '
          'now.'),
      2: _en('Fine in normal amounts. This is the trimester the sugar test is '
          'usually done, around 24 to 28 weeks.'),
      3: _en('If your OGTT flagged anything, sweets are the first thing your '
          'doctor will talk about. If it did not, ordinary amounts are '
          'ordinary.'),
    },
    whenToAvoid: _en('If you have been told you have gestational diabetes, '
        'this stops being a general-advice question and becomes your own '
        'doctor\'s plan. Follow theirs, not this page.'),
    alternatives: [
      _en('Dates or a piece of gud — sweet, and they bring some iron along.'),
      _en('Fruit with thick curd, which slows the sugar down.'),
      _en('A small piece of dark chocolate rather than a full mithai.'),
    ],
    recipe: CravingRecipe(
      name: _en('Date and nut ladoo'),
      minutes: 20,
      note: _en('No added sugar at all, and enough iron and calcium to be '
          'worth eating rather than merely allowed.'),
      ingredients: [
        _en('Seedless dates — 1 cup, packed'),
        _en('Almonds — 1/2 cup'),
        _en('Walnuts — 1/4 cup'),
        _en('Til (sesame) — 2 tbsp'),
        _en('Ghee — 1 tsp'),
        _en('Elaichi powder — a pinch'),
      ],
      steps: [
        _en('Dry-roast the nuts and til lightly, then chop them coarse.'),
        _en('Warm the ghee, add the chopped dates, and mash until they come '
            'together as a paste.'),
        _en('Mix in the nuts, til and elaichi. Cool slightly.'),
        _en('Roll into small ladoos. Keeps a week in the fridge.'),
      ],
    ),
  ),
  CravingItem(
    id: 'ice_cream',
    emoji: '🍨',
    name: _en('Ice cream and kulfi'),
    verdict: NutritionVerdict.limit,
    aliases: ['icecream', 'kulfi', 'cold', 'dessert'],
    why: _en('Cold, sweet and soothing — and if you have heartburn, genuinely '
        'the thing your body is asking for.'),
    stageNotes: {
      1: _en('Often one of the few things that stays down. Packet ice cream '
          'from a shop with a working freezer is fine.'),
      2: _en('Fine in normal amounts.'),
      3: _en('Fine, and often the best thing going for heartburn. Watch the '
          'sugar if your OGTT flagged anything.'),
    },
    modification: _en('Sealed, branded, and from a freezer that has clearly '
        'stayed cold. What to skip is soft-serve from a machine you cannot see '
        'the cleaning of, and thela kulfi made with unpasteurised milk.'),
    whenToAvoid: _en('Anything that has half-melted and been refrozen — that '
        'is where listeria risk actually lives, not in ice cream as a '
        'category.'),
    alternatives: [
      _en('Frozen curd with fruit blended through it.'),
      _en('A home kulfi made from boiled, cooled milk.'),
    ],
    recipe: CravingRecipe(
      name: _en('Mango-curd kulfi'),
      minutes: 15,
      note: _en('Made from boiled milk and set at home, so the two things that '
          'make shop kulfi a question — the milk and the freezer — are both '
          'yours.'),
      ingredients: [
        _en('Full-fat milk — 2 cups, boiled and cooled'),
        _en('Thick curd — 1/2 cup'),
        _en('Ripe mango pulp — 1 cup'),
        _en('Sugar or gud — 2 tbsp, or skip if the mango is sweet'),
        _en('Elaichi powder — a pinch'),
      ],
      steps: [
        _en('Boil the milk, then cool it fully. Do not skip the boil.'),
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
    why: _en('Habit as much as craving — and in the first trimester often the '
        'opposite: a cup you have had every morning for years can suddenly '
        'smell wrong.'),
    stageNotes: {
      1: _en('Around two cups a day is the usual guidance. Many women go off '
          'it entirely right now, which is its own answer.'),
      2: _en('Same limit — roughly 200mg of caffeine a day, which is about two '
          'cups of instant coffee or three of home chai.'),
      3: _en('Same limit. Keep tea and coffee an hour away from iron tablets '
          'and iron-rich meals — they block the absorption.'),
    },
    modification: _en('Weaker, and fewer. A light home chai carries much less '
        'caffeine than a filter coffee or a café cup.'),
    alternatives: [
      _en('Saunf or ajwain water — warm, and it helps digestion.'),
      _en('Milk with a little haldi in the evening.'),
      _en('Decaf, which keeps the ritual and drops the problem.'),
    ],
  ),
  CravingItem(
    id: 'spicy',
    emoji: '🌶️',
    name: _en('Very spicy food'),
    verdict: NutritionVerdict.safe,
    verdictByTrimester: {3: NutritionVerdict.limit},
    aliases: ['spice', 'chilli', 'teekha', 'masala'],
    why: _en('Extremely common, and the old belief that it harms the baby is '
        'not true. Chilli does not reach your baby; it stops at your own '
        'stomach.'),
    stageNotes: {
      1: _en('Eat what appeals. If it comes back up, that is the nausea '
          'talking, not the chilli doing harm.'),
      2: _en('Fine. This is usually the easiest trimester for spice.'),
      3: _en('Still safe for the baby — but the acidity is a real problem now '
          'that there is less room and heartburn is common. Most women cut '
          'back on their own by this stage.'),
    },
    whenToAvoid: _en('When heartburn has started. That is a comfort limit, not '
        'a safety one — worth being clear about, because the two get confused '
        'and women give up food they never needed to.'),
    alternatives: [
      _en('Flavour without heat — more jeera, dhania and kali mirch, less red '
          'chilli.'),
      _en('Curd or a glass of milk alongside the meal rather than after it.'),
    ],
  ),
  CravingItem(
    id: 'raw_mango',
    emoji: '🥭',
    name: _en('Raw mango / kaccha aam'),
    verdict: NutritionVerdict.safe,
    foodId: 'mango',
    aliases: ['kacha aam', 'green mango', 'amchoor', 'sour'],
    why: _en('The sour craving again, in season. It also carries real vitamin '
        'C, which helps you absorb the iron in the same meal.'),
    stageNotes: {
      1: _en('Fine, and often welcome — sour flavours settle nausea for many '
          'women.'),
      2: _en('Fine. Eat it with a meal and the vitamin C helps that meal\'s '
          'iron do more.'),
      3: _en('Fine. Go easy on the salt-and-chilli that usually comes with it '
          'if swelling is being watched.'),
    },
    modification: _en('Wash it properly and peel it. The caution is the skin '
        'and what was on it, not the fruit.'),
  ),
  CravingItem(
    id: 'papaya',
    emoji: '🍈',
    name: _en('Papaya'),
    verdict: NutritionVerdict.limit,
    verdictByTrimester: {1: NutritionVerdict.avoid},
    foodId: 'papaya',
    aliases: ['papita', 'raw papaya', 'kaccha papita'],
    why: _en('Craved like any sweet fruit — and also the single most-asked '
        'food question in an Indian pregnancy, so the craving usually arrives '
        'with worry attached.'),
    stageNotes: {
      1: _en('Leave it for now. Unripe papaya contains latex that can cause '
          'contractions, and early pregnancy is when that caution is taken '
          'most seriously.'),
      2: _en('Fully ripe papaya — soft, deep orange, no white sap — is '
          'generally considered fine in normal amounts. Unripe or half-ripe '
          'stays off.'),
      3: _en('Same as the second trimester: ripe is fine, unripe is not. If '
          'your own doctor has told you to avoid it entirely, follow them.'),
    },
    modification: _en('Ripe only, and obviously ripe — soft to the touch, deep '
        'orange inside, no milky sap at the stem.'),
    whenToAvoid: _en('Any papaya that is green, firm, or leaks white sap when '
        'cut. That is the one the warning has always been about.'),
    alternatives: [
      _en('Ripe mango, chikoo or banana — sweet, soft, and no argument '
          'attached.'),
      _en('Papita is often craved for digestion; soaked figs or a bowl of curd '
          'do the same job.'),
    ],
  ),
  CravingItem(
    id: 'chinese',
    emoji: '🍜',
    name: _en('Chowmein and Indo-Chinese'),
    verdict: NutritionVerdict.limit,
    aliases: ['noodles', 'chowmein', 'hakka', 'manchurian', 'msg', 'ajinomoto'],
    why: _en('Salt, oil and a strong savoury hit — which is exactly what a '
        'pregnancy craving wants when it is not asking for sour or sweet.'),
    stageNotes: {
      1: _en('Fine occasionally. Freshly cooked and hot is the thing to insist '
          'on.'),
      2: _en('Fine occasionally. Ask for less ajinomoto if the place will do '
          'it.'),
      3: _en('Go lighter now — this food is very high in salt, and salt is '
          'what matters if swelling or blood pressure is being watched.'),
    },
    modification: _en('Freshly cooked, eaten hot, from somewhere with '
        'turnover. Reheated noodles that have sat out are the actual risk.'),
    whenToAvoid: _en('Cold or lukewarm noodles, and anything in a sauce that '
        'has been standing.'),
    alternatives: [
      _en('Home hakka noodles with plenty of vegetables and half the salt.'),
      _en('Vegetable soup with noodles in it, if it is the warm-savoury thing '
          'you want.'),
    ],
    recipe: CravingRecipe(
      name: _en('Home veg hakka noodles'),
      minutes: 25,
      note: _en('No ajinomoto, half the salt, twice the vegetables — and hot '
          'off your own stove, which was the real issue.'),
      ingredients: [
        _en('Hakka noodles — 1 packet'),
        _en('Cabbage, carrot, capsicum, spring onion — 2 cups, shredded'),
        _en('Garlic — 4 cloves, chopped'),
        _en('Soy sauce — 1 tbsp'),
        _en('Vinegar — 1 tsp'),
        _en('Kali mirch — to taste'),
        _en('Oil — 1 tbsp'),
      ],
      steps: [
        _en('Boil the noodles, drain, and toss with a few drops of oil.'),
        _en('Fry the garlic on high heat, then the vegetables — 2 minutes '
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
        'reliably helps heartburn. A craving worth simply following.'),
    stageNotes: {
      1: _en('Genuinely helpful for nausea, and it stays down when little else '
          'does.'),
      2: _en('Fine and good — calcium and protein, both of which you need more '
          'of now.'),
      3: _en('Fine, and one of the better answers to third-trimester '
          'heartburn.'),
    },
    modification: _en('Set at home or from a sealed packet. The one to skip is '
        'loose curd sold open in a market.'),
    recipe: CravingRecipe(
      name: _en('Salted jeera chaas'),
      minutes: 5,
      note: _en('Five minutes, and it does more for heartburn than most things '
          'sold for it.'),
      ingredients: [
        _en('Thick curd — 1/2 cup'),
        _en('Cold water — 1 cup'),
        _en('Roasted jeera powder — 1/2 tsp'),
        _en('Black salt — a pinch'),
        _en('Pudina leaves — a few, washed'),
      ],
      steps: [
        _en('Whisk the curd smooth, then whisk in the water.'),
        _en('Add the jeera, black salt and crushed pudina.'),
        _en('Serve cold. Do not add ice made from tap water.'),
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
    why: _en('A craving for things that are not food is called pica. It is '
        'real, it is not something to be embarrassed about, and it is often '
        'linked to low iron or zinc — which is a treatable thing, not a '
        'character flaw.'),
    stageNotes: {
      1: _en('Tell your doctor at your next visit. Bloodwork this early will '
          'usually show whether iron is behind it.'),
      2: _en('Please mention it. It is common enough in India that your doctor '
          'will not be surprised, and the fix is often just iron.'),
      3: _en('Say it now rather than at delivery. Low iron in the last '
          'trimester matters for how the birth goes.'),
    },
    whenToAvoid: _en('Always. Mud and ash can carry lead, parasites and '
        'bacteria, and chalk blocks the very iron you are short of — so it '
        'deepens the thing causing the craving.'),
    // No alternatives and no recipe: the answer to this one is a blood test.
  ),
];

CravingItem? cravingById(String id) {
  for (final c in kCravingItems) {
    if (c.id == id) return c;
  }
  return null;
}
