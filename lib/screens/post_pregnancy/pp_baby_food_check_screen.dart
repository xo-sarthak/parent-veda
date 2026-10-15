// =============================================================================
//  PpBabyFoodCheckScreen — "Can he eat this?"
// -----------------------------------------------------------------------------
//  The Feeding section's promise, verbatim:
//
//    "Type a food, get a straight answer for his age. Honey, cow milk, nuts,
//     salt, the lot."
//
//  ⚠️ THE ANSWER DEPENDS ON HIS AGE, AND THAT IS THE WHOLE POINT.
//
//  The pregnancy side has a food checker (`can_i`) where an answer is fixed: a
//  food is safe in pregnancy or it is not. Here almost nothing is simply banned
//  and almost nothing is simply allowed. Cow milk is dangerous as a drink at
//  eight months, fine in cooking at eight months, and fine as a drink at
//  thirteen. Honey is a hard no until one and unremarkable after.
//
//  So a verdict is a function of (food, age), and the screen refuses to show one
//  without both. That rules out the shape this normally takes -- a searchable
//  list of foods each with a green or red badge -- because such a list is either
//  wrong for most readers or hedged into uselessness.
//
//  ⚠️ IT NEVER RETURNS "NO" WHERE THE TRUTH IS "NOT YET".
//
//  Three verdicts, and the middle one carries most of the weight:
//
//    * `yes`     -- fine at this age.
//    * `notYet`  -- fine later, and it says WHEN. This is the common answer and
//                   it is the reason the tool exists: a parent told only "no"
//                   asks again next month, or never.
//    * `avoid`   -- genuinely not for young children at all, with the reason.
//
//  A flat red for everything not-yet-allowed would make the first year read as a
//  minefield, which is the anxiety this whole section is written against.
//
//  ⚠️ SEARCH IS BY ALIAS AS WELL AS NAME, because she will type "sahad" or
//  "gud", not "honey" or "jaggery". An Indian food checker that only matches
//  English names answers "no results" to the people it is for.
//
//  ⚠️ EVERY AGE THRESHOLD IS REQUIRED_REVIEW.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_age_bands.dart';
import 'pp_child_profile.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_content.dart';
import 'pp_phases_data.dart' show ppFillChild;
import '../../models/can_i_entry.dart' show CanIVerdict;
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../can_i/can_i_widgets.dart' show canIVerdictColor;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvSecondary;
import '../doors/pv_list_row.dart';
import '../../widgets/pv_feedback.dart' show PvPress;

enum _Verdict { yes, notYet, avoid }

/// The mother's answer for a food with no `maa` line of its own.
const String kPpMaaFoodDefault =
    'Fine for you, as part of a varied diet. What you eat rarely upsets him.';

class _Food {
  const _Food({
    required this.name,
    required this.fromMonths,
    required this.why,
    this.avoidEntirely = false,
    this.aliases = const [],
    this.note,
    this.maa,
  });

  final String name;

  /// The age it becomes fine. 0 means from the start of solids.
  final int fromMonths;

  /// Why, in one line. Present on every entry: an unexplained rule gets ignored
  /// by the grandmother who has fed six children.
  final String why;

  /// True for the handful that are not about age at all.
  final bool avoidEntirely;

  /// What she will actually type. Hindi and regional names included.
  final List<String> aliases;

  /// ⚠️ THE MOTHER'S ANSWER, ADDED 2026-10-02 (parenting gap analysis).
  /// theAsianparent rates every food for the baby AND for a breastfeeding
  /// mother; she asks both in one breath ("can I eat it, can he?"). Null
  /// means the ordinary answer, `kPpMaaFoodDefault`; foods where hers differs
  /// say so here. REQUIRED_REVIEW.
  final String? maa;

  /// Extra practical detail where the yes-or-no hides something.
  final String? note;

  _Verdict verdictAt(int months) {
    if (avoidEntirely) return _Verdict.avoid;
    return months >= fromMonths ? _Verdict.yes : _Verdict.notYet;
  }
}

/// How many foods the lookup answers. Read by its test.
/// The matching names, for the parenting search. Same rule as the screen.
List<String> ppBabyFoodSearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.length < 2) return const [];
  return [
    for (final x in _foods)
      if (x.name.toLowerCase().contains(q) ||
          x.aliases.any((a) => a.contains(q) || q.contains(a))) x.name,
  ];
}

int get ppBabyFoodCount => _foods.length;

/// Every food the check answers, with its other names, for the parenting
/// search (pp_search.dart). The list stays private; search reads names only.
List<(String name, List<String> aliases)> ppBabyFoodEntries() => [
      for (final f in _foods) (f.name, f.aliases),
    ];

// REQUIRED_REVIEW: every `fromMonths` value in this list.
const List<_Food> _foods = [
  // ---- the hard rules -------------------------------------------------------
  _Food(
    name: 'Honey',
    aliases: ['sahad', 'shahad', 'madhu'],
    fromMonths: 12,
    why: 'Honey can carry spores that a baby under one cannot handle. It causes '
        'infant botulism, which is rare and serious.',
    note: 'This includes honey cooked into something, and honey on a dummy or '
        'given at a naming ceremony.',
    maa: 'Fine for you. Only babies under one cannot have honey.',
  ),
  _Food(
    name: 'Cow milk as a drink',
    aliases: ['milk', 'doodh', 'buffalo milk', 'dairy milk'],
    fromMonths: 12,
    why: 'As a main drink before one it is hard on the gut and gets in the way '
        'of iron. Breast milk or formula stays the drink until then.',
    note: 'Cow milk COOKED INTO food, like in a kheer or a porridge, is fine '
        'from about six months. It is the drinking that waits.',
    maa: 'Fine for you. No need to drink extra milk to make milk; cut dairy only if a doctor suspects cow\'s milk allergy in him.',
  ),
  _Food(
    name: 'Salt',
    aliases: ['namak', 'salty food'],
    fromMonths: 12,
    why: 'His kidneys cannot clear much salt in the first year, and food that '
        'tastes right to you is already too salty for him.',
    note: 'Take his portion out of the pot before you season the family one.',
    maa: 'Fine for you, in normal amounts. Use iodised salt.',
  ),
  _Food(
    name: 'Sugar',
    aliases: ['cheeni', 'chini', 'sweets', 'mithai'],
    fromMonths: 12,
    why: 'Nothing in the first year needs it, and a sweet tooth learned now is '
        'hard to unlearn.',
    note: 'Fruit is sweet enough. Jaggery is still sugar.',
    maa: 'Fine for you in moderation.',
  ),
  _Food(
    name: 'Whole nuts',
    aliases: ['nuts', 'badam', 'almond', 'peanut', 'kaju', 'cashew'],
    fromMonths: 60,
    why: 'A whole nut is the classic choking food. The shape is exactly wrong '
        'for a small airway.',
    note: 'Ground or as a smooth paste, nuts are good for him from six months '
        'and early introduction helps prevent allergy. It is the WHOLE nut that '
        'waits until about five.',
    maa: 'Fine, and good for you. Avoiding nuts while breastfeeding does not prevent allergies in him.',
  ),
  _Food(
    name: 'Whole grapes',
    aliases: ['grapes', 'angoor'],
    fromMonths: 0,
    why: 'Fine from the start of solids, but always quartered lengthways. Whole '
        'or halved, a grape is the right size and shape to block an airway.',
    note: 'Same for cherry tomatoes and small round sweets.',
    maa: 'Fine for you.',
  ),

  // ---- never for small children --------------------------------------------
  _Food(
    name: 'Tea and coffee',
    aliases: ['chai', 'coffee', 'kaapi'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Caffeine is not for small children, and the tannins block the iron he '
        'is getting from everything else.',
    note: 'Giving a toddler sips of chai is common and is worth stopping.',
    maa: 'Two or three cups a day is fine. Caffeine passes into milk; cut down if he seems jittery or wakeful.',
  ),
  _Food(
    name: 'Packaged juice and cold drinks',
    aliases: ['juice', 'soft drink', 'cola', 'frooti', 'soda'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Sugar with the fibre taken out. It fills him up, spoils his appetite '
        'for real food, and is hard on new teeth.',
    note: 'Whole fruit instead. Even fresh juice is worth leaving until later.',
    maa: 'Occasionally. Mostly sugar; colas also have caffeine.',
  ),
  _Food(
    name: 'Popcorn',
    aliases: ['popcorn'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Choking risk, and the hulls are not something a small child can clear.',
    note: 'Usually advised against under about four or five.',
    maa: 'Fine for you.',
  ),

  // ---- the ordinary yeses ---------------------------------------------------
  _Food(
    name: 'Dal',
    aliases: ['lentils', 'daal', 'moong', 'toor', 'masoor'],
    fromMonths: 6,
    why: 'One of the best Indian first foods. Protein, iron, and it mashes to '
        'any texture you need.',
    note: 'Start with a thin moong dal water, then the dal itself.',
  ),
  _Food(
    name: 'Khichdi',
    aliases: ['khichri', 'rice and dal'],
    fromMonths: 6,
    why: 'A complete first meal, and the same pot the family eats from.',
  ),
  _Food(
    name: 'Ghee',
    aliases: ['clarified butter'],
    fromMonths: 6,
    why: 'Good fat and good calories, which a small stomach needs. A little in '
        'his dal or khichdi is right.',
    note: 'A teaspoon or so a day is plenty. It is not a tonic.',
  ),
  _Food(
    name: 'Curd',
    aliases: ['dahi', 'yoghurt', 'yogurt'],
    fromMonths: 6,
    why: 'Plain, unsweetened curd is fine from six months. It is cow milk as a '
        'DRINK that waits until one, not dairy in food.',
  ),
  _Food(
    name: 'Egg',
    aliases: ['anda', 'eggs'],
    fromMonths: 6,
    why: 'Well cooked, yolk and white together, from about six months. Early '
        'introduction lowers the chance of an egg allergy rather than raising '
        'it.',
  ),
  _Food(
    name: 'Fish',
    aliases: ['machli', 'macch', 'meen'],
    fromMonths: 6,
    why: 'Well cooked and carefully deboned, from about six months. Good for '
        'his brain.',
    note: 'Stick to smaller fish and avoid the large predatory ones, which '
        'carry more mercury.',
    maa: 'Fine and good for you: two or three times a week.',
  ),
  _Food(
    name: 'Chicken and meat',
    aliases: ['chicken', 'mutton', 'meat', 'murgi'],
    fromMonths: 6,
    why: 'Iron he can absorb easily. Cooked soft and shredded or minced fine.',
  ),
  _Food(
    name: 'Ragi',
    aliases: ['nachni', 'finger millet'],
    fromMonths: 6,
    why: 'Calcium and iron, and it makes an easy porridge. A standard Indian '
        'first food for good reason.',
  ),
  _Food(
    name: 'Banana',
    aliases: ['kela'],
    fromMonths: 6,
    why: 'Mashed, from six months. Easy, filling and almost never a problem.',
  ),
  _Food(
    name: 'Water',
    aliases: ['pani', 'paani'],
    fromMonths: 6,
    why: 'Not before six months: it fills him up and takes the place of milk he '
        'needs. From six months, small sips with meals.',
    note: 'In real heat before six months, feed more often rather than giving '
        'water.',
    maa: 'Drink to thirst, and keep a glass by you at every feed.',
  ),
  _Food(
    name: 'Spices',
    aliases: ['masala', 'jeera', 'haldi', 'turmeric', 'cumin'],
    fromMonths: 6,
    why: 'Mild spices are fine and are how he learns to eat your food. It is '
        'chilli heat and salt that wait.',
    maa: 'Fine. Spices in your food do not harm your milk.',
  ),
  // ===========================================================================
  //  Added 2026-10-02 from the parenting gap analysis: theAsianparent's food
  //  lookup runs to ~530 foods by category. These are the ones an Indian
  //  family actually asks about, written for this tool's (food, age) rule.
  //  REQUIRED_REVIEW: every threshold, as above.
  // ===========================================================================

  // ---- drinks ---------------------------------------------------------------
  _Food(
    name: 'Coconut water',
    aliases: ['nariyal pani', 'tender coconut', 'daab'],
    fromMonths: 12,
    why: 'A few sips after six months will not harm him, but it is not needed '
        'and fills a small stomach. As a regular drink, after one.',
    note: 'Useful when he is unwell and drinking little, but ORS is what treats '
        'dehydration.',
    maa: 'Fine, and hydrating.',
  ),
  _Food(
    name: 'Chaas and lassi',
    aliases: ['buttermilk', 'mattha', 'lassi', 'chhach'],
    fromMonths: 8,
    why: 'Plain, unsalted chaas made from curd is fine in small amounts. Sweet '
        'lassi waits until he can have sugar.',
    note: 'No salt or sugar before one. Roasted jeera is fine.',
  ),
  _Food(
    name: 'Fresh fruit juice',
    aliases: ['juice', 'orange juice', 'mosambi juice', 'fresh juice'],
    fromMonths: 12,
    why: 'Whole fruit is better at every age: it keeps the fibre and does not '
        'bathe the teeth in sugar.',
    note: 'After one, a small cup with a meal at most, never in a bottle.',
  ),
  _Food(
    name: 'Milkshake',
    aliases: ['shake', 'banana shake', 'mango shake'],
    fromMonths: 12,
    why: 'Made with whole milk and fruit, no sugar, it is a filling snack after '
        'one, when cow milk is fine to drink.',
  ),
  _Food(
    name: 'Malt and health drink powders',
    aliases: ['bournvita', 'horlicks', 'complan', 'boost', 'health drink'],
    fromMonths: 24,
    why: 'Most are mainly sugar. A child eating ordinary food does not need '
        'them, whatever the advert says.',
    note: 'Not a replacement for meals, and never for babies.',
    maa: 'Fine, but mostly sugar. A balanced meal does more.',
  ),
  _Food(
    name: 'Herbal tea and kadha',
    aliases: ['kadha', 'kadhai', 'tulsi tea', 'herbal tea', 'green tea'],
    fromMonths: 24,
    why: 'Strong kadha with pepper, cloves and ginger is too much for a baby, '
        'and some herbs are not tested for children.',
    note: 'A mild, cooled tulsi or ginger water in small amounts is fine for an '
        'older child. Never with honey before one.',
    maa: 'A mild homemade kadha is fine. Avoid strong mixtures or herbs bought loose; ask about medicinal herbs.',
  ),
  _Food(
    name: 'Energy drinks',
    aliases: ['red bull', 'energy drink', 'sting'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'High caffeine and sugar. Not for children at any age.',
    maa: 'Best avoided while breastfeeding: a lot of caffeine and sugar.',
  ),
  _Food(
    name: 'Goat milk',
    aliases: ['bakri ka doodh', 'goat\'s milk'],
    fromMonths: 12,
    why: 'Like cow milk: fine in cooking from six months, as a drink after one. '
        'It is not a substitute for formula or breast milk in a baby.',
    note: 'Often offered in dengue for platelets; there is no good evidence it '
        'helps.',
    maa: 'Fine for you, boiled.',
  ),
  _Food(
    name: 'Plant milks',
    aliases: ['almond milk', 'soy milk', 'oat milk', 'rice milk'],
    fromMonths: 24,
    why: 'Most are low in protein, fat and calories, and are not a replacement '
        'for breast milk, formula or cow milk in a young child.',
    note: 'Ask your doctor if he cannot have dairy.',
    maa: 'Fine for you, if you choose them.',
  ),

  // ---- fruits ---------------------------------------------------------------
  _Food(
    name: 'Apple',
    aliases: ['seb', 'saeb'],
    fromMonths: 6,
    why: 'Steamed and mashed at first. Raw apple is hard and a choking risk, '
        'so grate it thinly until he chews well.',
  ),
  _Food(
    name: 'Papaya',
    aliases: ['papita'],
    fromMonths: 6,
    why: 'Ripe papaya is soft, sweet and gentle on the tummy. Good for '
        'constipation.',
    maa: 'Fine for you. Papaya is only questioned in pregnancy.',
  ),
  _Food(
    name: 'Mango',
    aliases: ['aam'],
    fromMonths: 6,
    why: 'Ripe mango, mashed or in soft strips. One of the best-loved first '
        'fruits.',
    note: 'Not the stone to suck on: it is slippery and a choking risk.',
  ),
  _Food(
    name: 'Chikoo',
    aliases: ['sapota', 'chiku', 'sapodilla'],
    fromMonths: 6,
    why: 'Ripe and scooped, with the seeds removed. Sweet and soft.',
  ),
  _Food(
    name: 'Pear',
    aliases: ['nashpati', 'naspati'],
    fromMonths: 6,
    why: 'Steamed and mashed, or very ripe and soft. Helps with constipation.',
  ),
  _Food(
    name: 'Orange and mosambi',
    aliases: ['santra', 'mosambi', 'sweet lime', 'citrus', 'orange'],
    fromMonths: 6,
    why: 'Segments with the skin and seeds removed, cut small. The acid can '
        'cause a mild rash around the mouth, which is not an allergy.',
  ),
  _Food(
    name: 'Strawberries and berries',
    aliases: ['strawberry', 'blueberry', 'berries', 'shahtoot'],
    fromMonths: 6,
    why: 'Mashed, or cut into quarters. Round berries whole are a choking risk.',
  ),
  _Food(
    name: 'Watermelon and muskmelon',
    aliases: ['tarbooz', 'kharbooza', 'melon'],
    fromMonths: 6,
    why: 'Soft and hydrating. Remove every seed.',
  ),
  _Food(
    name: 'Guava',
    aliases: ['amrood', 'peru'],
    fromMonths: 8,
    why: 'Cooked or very ripe and mashed, with the hard seeds sieved out.',
  ),
  _Food(
    name: 'Pomegranate',
    aliases: ['anar'],
    fromMonths: 6,
    why: 'Crushed or as fresh juice strained into food. The whole seeds can '
        'choke a young child.',
    note: 'Whole seeds from about three years, when he chews well.',
  ),
  _Food(
    name: 'Dates',
    aliases: ['khajoor', 'khajur'],
    fromMonths: 6,
    why: 'Soaked, pitted and mashed, as a natural sweetener. Whole dates are '
        'sticky and a choking risk.',
  ),
  _Food(
    name: 'Whole raisins',
    aliases: ['kishmish', 'raisin', 'munakka'],
    fromMonths: 36,
    why: 'Small and sticky, a choking risk for small children. Soaked and '
        'mashed or chopped into food is fine from six months.',
  ),
  _Food(
    name: 'Amla',
    aliases: ['indian gooseberry', 'awla'],
    fromMonths: 12,
    why: 'Very sour and hard. A little grated or cooked into food after one.',
  ),
  _Food(
    name: 'Litchi',
    aliases: ['lychee', 'lichi'],
    fromMonths: 12,
    why: 'Peeled, seeded and chopped small, it is fine. Whole litchi is a '
        'serious choking risk.',
    note: 'Only ripe litchi, and never on an empty stomach: eating many unripe '
        'litchis without a meal has been linked to dangerously low sugar in '
        'undernourished children.',
    maa: 'Fine for you.',
  ),
  _Food(
    name: 'Jamun',
    aliases: ['java plum', 'black plum'],
    fromMonths: 8,
    why: 'Ripe, with the seed removed, mashed or chopped.',
  ),
  _Food(
    name: 'Coconut',
    aliases: ['nariyal', 'grated coconut'],
    fromMonths: 8,
    why: 'Finely grated into food, or as coconut milk in cooking. Hard pieces '
        'are a choking risk.',
  ),
  _Food(
    name: 'Avocado',
    aliases: ['butter fruit'],
    fromMonths: 6,
    why: 'Soft, full of good fat, and easy to mash. A great first food.',
  ),

  // ---- nuts, seeds and pulses ----------------------------------------------
  _Food(
    name: 'Peanut butter and powdered nuts',
    aliases: ['peanut butter', 'almond powder', 'nut powder', 'mungfali'],
    fromMonths: 6,
    why: 'Smooth nut butter thinned into porridge, or finely powdered nuts, '
        'from six months. Early introduction lowers the chance of a nut '
        'allergy.',
    note: 'Never a spoonful of thick nut butter, which can stick and choke. Ask '
        'your doctor first if he has severe eczema or another food allergy.',
  ),
  _Food(
    name: 'Ground seeds',
    aliases: ['flax', 'alsi', 'chia', 'til', 'sesame', 'pumpkin seeds'],
    fromMonths: 6,
    why: 'Finely ground into food, or chia soaked until soft. Sesame is a '
        'common allergen, so introduce it on its own.',
  ),
  _Food(
    name: 'Makhana',
    aliases: ['fox nuts', 'lotus seeds', 'phool makhana'],
    fromMonths: 8,
    why: 'Roasted and powdered into porridge first. Whole puffs once he is '
        'chewing well, around a year.',
  ),
  _Food(
    name: 'Rajma and chole',
    aliases: ['kidney beans', 'chickpeas', 'chana', 'kabuli chana', 'lobia'],
    fromMonths: 8,
    why: 'Soaked, cooked very soft and mashed. Gentle on the tummy if you start '
        'with small amounts.',
    note: 'Whole roasted chana is a choking food until about four.',
  ),
  _Food(
    name: 'Sprouts',
    aliases: ['sprouted moong', 'ankurit'],
    fromMonths: 8,
    why: 'Cooked sprouts are fine. Raw sprouts can carry germs and are best '
        'avoided by young children.',
    maa: 'Cooked is safer for you too; raw sprouts can carry germs.',
  ),
  _Food(
    name: 'Soya chunks',
    aliases: ['soya', 'nutrela', 'soy'],
    fromMonths: 12,
    why: 'Soaked, cooked and minced fine. Soy is a common allergen, so start '
        'small.',
    maa: 'Fine for you, and a good protein.',
  ),

  // ---- dairy ----------------------------------------------------------------
  _Food(
    name: 'Paneer',
    aliases: ['cottage cheese', 'chhena'],
    fromMonths: 6,
    why: 'Fresh, soft paneer crumbled or in strips. Protein and calcium.',
  ),
  _Food(
    name: 'Cheese',
    aliases: ['cheese slice', 'cheddar', 'processed cheese'],
    fromMonths: 6,
    why: 'Pasteurised hard cheese, grated, in small amounts. Processed cheese '
        'slices are salty, so keep them occasional.',
  ),
  _Food(
    name: 'Butter and cream',
    aliases: ['makhan', 'malai', 'cream'],
    fromMonths: 6,
    why: 'Small amounts in cooking add calories. Unsalted butter is best.',
  ),
  _Food(
    name: 'Tofu',
    aliases: ['bean curd'],
    fromMonths: 6,
    why: 'Soft and easy to mash or cut into strips. Introduce soy on its own.',
  ),
  _Food(
    name: 'Raw milk and unpasteurised cheese',
    aliases: ['kaccha doodh', 'raw milk', 'fresh from the dairy'],
    fromMonths: 999,
    avoidEntirely: true,
    why: 'Can carry harmful germs. Always boil loose milk, and avoid soft '
        'unpasteurised cheeses.',
    maa: 'Boil loose milk for yourself too, and avoid soft unpasteurised cheese: they can carry germs.',
  ),

  // ---- grains ---------------------------------------------------------------
  _Food(
    name: 'Rice',
    aliases: ['chawal', 'rice water', 'kanji'],
    fromMonths: 6,
    why: 'Soft-cooked and mashed, on its own or as khichdi.',
  ),
  _Food(
    name: 'Suji and dalia',
    aliases: ['rava', 'semolina', 'broken wheat', 'upma', 'daliya'],
    fromMonths: 6,
    why: 'Easy porridges. Wheat is fine from six months.',
  ),
  _Food(
    name: 'Oats',
    aliases: ['oatmeal', 'porridge'],
    fromMonths: 6,
    why: 'Plain oats, cooked soft. Avoid the flavoured instant packs, which '
        'have sugar and salt.',
  ),
  _Food(
    name: 'Idli and dosa',
    aliases: ['idly', 'dosai', 'uttapam', 'appam'],
    fromMonths: 8,
    why: 'Soft idli mashed with dal or sambar is a lovely early food. Soft '
        'dosa in strips once he chews.',
  ),
  _Food(
    name: 'Roti and chapati',
    aliases: ['phulka', 'paratha', 'roti'],
    fromMonths: 8,
    why: 'Soft roti soaked in dal, or torn into small pieces. Parathas with '
        'little oil.',
  ),
  _Food(
    name: 'Poha',
    aliases: ['flattened rice', 'aval', 'chivda'],
    fromMonths: 8,
    why: 'Soaked and cooked soft, it is easy to eat. Dry fried chivda is a '
        'different food: salty and a choking risk.',
  ),
  _Food(
    name: 'Millets',
    aliases: ['jowar', 'bajra', 'foxtail', 'kodo', 'sorghum'],
    fromMonths: 6,
    why: 'As porridge or khichdi, a good source of iron and fibre.',
  ),
  _Food(
    name: 'Sabudana',
    aliases: ['sago', 'tapioca pearls'],
    fromMonths: 8,
    why: 'Soaked and cooked until clear and soft. Mostly starch, so pair it '
        'with protein.',
  ),
  _Food(
    name: 'Bread',
    aliases: ['pav', 'toast', 'bun', 'double roti'],
    fromMonths: 8,
    why: 'Lightly toasted wholewheat fingers are fine. Bread has some salt, so '
        'keep it occasional in the first year.',
  ),
  _Food(
    name: 'Rusk',
    aliases: ['toast biscuit', 'khari'],
    fromMonths: 12,
    why: 'Usually sugary, and hard pieces can break off. Soaked in milk is '
        'safer.',
  ),
  _Food(
    name: 'Pasta and noodles',
    aliases: ['macaroni', 'spaghetti', 'noodles'],
    fromMonths: 8,
    why: 'Plain pasta, well cooked, with a vegetable sauce.',
  ),
  _Food(
    name: 'Instant noodles',
    aliases: ['maggi', 'cup noodles', 'ramen'],
    fromMonths: 24,
    why: 'Very salty and low in nutrition. An occasional treat, not a meal.',
    note: 'If you make them, use half the tastemaker and add vegetables.',
    maa: 'Occasionally. Salty and low in nutrition.',
  ),
  _Food(
    name: 'Cornflakes and breakfast cereals',
    aliases: ['cornflakes', 'chocos', 'cereal'],
    fromMonths: 12,
    why: 'Most children\'s cereals are high in sugar. Plain cornflakes soaked '
        'in milk are fine occasionally.',
  ),
  _Food(
    name: 'Puffed rice',
    aliases: ['murmura', 'kurmura', 'mandakki'],
    fromMonths: 12,
    why: 'Plain puffed rice melts in the mouth. Spiced bhel waits until he is '
        'older.',
  ),

  // ---- vegetables -----------------------------------------------------------
  _Food(
    name: 'Carrot',
    aliases: ['gajar'],
    fromMonths: 6,
    why: 'Steamed soft and mashed, or in soft sticks. Raw carrot sticks are a '
        'choking food until about four.',
  ),
  _Food(
    name: 'Pumpkin and lauki',
    aliases: ['kaddu', 'bottle gourd', 'doodhi', 'ghiya', 'tori'],
    fromMonths: 6,
    why: 'Soft, mild and easy to digest. Classic first vegetables.',
  ),
  _Food(
    name: 'Sweet potato and potato',
    aliases: ['shakarkandi', 'aloo', 'potato'],
    fromMonths: 6,
    why: 'Boiled and mashed, a filling first food.',
  ),
  _Food(
    name: 'Spinach and leafy greens',
    aliases: ['palak', 'methi', 'saag', 'bathua', 'moringa', 'drumstick leaves'],
    fromMonths: 6,
    why: 'Cooked and blended into dal or khichdi. Good for iron, especially '
        'with a little lemon.',
  ),
  _Food(
    name: 'Beetroot',
    aliases: ['chukandar'],
    fromMonths: 6,
    why: 'Cooked and mashed. It turns his poo and urine pink-red, which is '
        'harmless.',
  ),
  _Food(
    name: 'Peas and beans',
    aliases: ['matar', 'green beans', 'french beans'],
    fromMonths: 6,
    why: 'Cooked and mashed. Whole peas squashed flat once he picks up food.',
  ),
  _Food(
    name: 'Cauliflower and broccoli',
    aliases: ['gobhi', 'phool gobhi', 'broccoli', 'cabbage', 'patta gobhi'],
    fromMonths: 6,
    why: 'Steamed soft. Can cause a little gas at first.',
  ),
  _Food(
    name: 'Tomato',
    aliases: ['tamatar'],
    fromMonths: 6,
    why: 'Cooked into dal or sauce. The acid may redden the skin around his '
        'mouth, which is not an allergy.',
  ),
  _Food(
    name: 'Cucumber',
    aliases: ['kheera', 'kakdi'],
    fromMonths: 8,
    why: 'Peeled and grated, or in thin soft strips. Hard round slices are a '
        'choking risk.',
  ),
  _Food(
    name: 'Corn',
    aliases: ['makka', 'bhutta', 'sweet corn'],
    fromMonths: 8,
    why: 'Mashed or blended. Whole kernels can choke a young child.',
  ),
  _Food(
    name: 'Mushroom',
    aliases: ['khumb', 'mushrooms'],
    fromMonths: 8,
    why: 'Well cooked and chopped small. Only shop-bought, never wild.',
  ),
  _Food(
    name: 'Okra and brinjal',
    aliases: ['bhindi', 'lady finger', 'baingan', 'brinjal', 'eggplant'],
    fromMonths: 6,
    why: 'Cooked soft. Brinjal can cause a mild itchy rash in some children.',
  ),

  // ---- seasonings -----------------------------------------------------------
  _Food(
    name: 'Chilli',
    aliases: ['mirchi', 'red chilli', 'green chilli', 'spicy'],
    fromMonths: 12,
    why: 'Heat can upset a small tummy and put him off food. Add it slowly '
        'after one, as he gets used to family food.',
    maa: 'Fine. A few babies seem fussier after very spicy meals; most do not.',
  ),
  _Food(
    name: 'Garlic, ginger and hing',
    aliases: ['lahsun', 'adrak', 'hing', 'asafoetida'],
    fromMonths: 6,
    why: 'A little, cooked in, adds flavour and is fine.',
    maa: 'Fine. Garlic does not harm milk; some babies even feed longer.',
  ),
  _Food(
    name: 'Pepper and garam masala',
    aliases: ['kali mirch', 'black pepper', 'garam masala'],
    fromMonths: 8,
    why: 'A small pinch, cooked in. Strong blends can wait.',
  ),
  _Food(
    name: 'Lemon and tamarind',
    aliases: ['nimbu', 'imli', 'lime'],
    fromMonths: 6,
    why: 'A few drops of lemon help him absorb iron. Tamarind in small amounts '
        'in cooked food.',
  ),
  _Food(
    name: 'Jaggery',
    aliases: ['gud', 'gur', 'shakkar', 'jaggery'],
    fromMonths: 12,
    why: 'It is still sugar, whatever the label says. After one, in small '
        'amounts.',
    maa: 'Fine. Some iron, but still a sugar.',
  ),
  _Food(
    name: 'Pickle and achar',
    aliases: ['achar', 'pickle', 'murabba'],
    fromMonths: 24,
    why: 'Very salty and oily. A tiny taste after two, not a regular food.',
    maa: 'Fine in small amounts; it is salty.',
  ),
  _Food(
    name: 'Stock cubes, MSG and sauces',
    aliases: ['maggi masala', 'stock cube', 'ajinomoto', 'soy sauce', 'ketchup'],
    fromMonths: 24,
    why: 'Very high in salt and sugar. Keep them occasional, and make his '
        'portion before adding them.',
  ),
  _Food(
    name: 'Ajwain and saunf water',
    aliases: ['ajwain', 'saunf', 'fennel', 'carom', 'janam ghutti'],
    fromMonths: 6,
    why: 'Not for babies under six months: anything but milk fills the stomach '
        'and can carry germs. In cooked food after six months, fine.',
    maa: 'Fine for you, and many mothers find it settles the tummy.',
  ),

  // ---- packaged foods and snacks -------------------------------------------
  _Food(
    name: 'Biscuits',
    aliases: ['marie', 'parle g', 'cookies', 'biscuit'],
    fromMonths: 12,
    why: 'Most are sugar and refined flour, and easy to fill up on. An '
        'occasional one after one, not a daily snack.',
    maa: 'Fine occasionally; a handful of nuts or fruit fills you better.',
  ),
  _Food(
    name: 'Namkeen and chips',
    aliases: ['bhujia', 'namkeen', 'chips', 'kurkure', 'wafers', 'mixture'],
    fromMonths: 36,
    why: 'Salty, oily, and the hard bits are a choking risk for small '
        'children. An occasional treat when he is older.',
  ),
  _Food(
    name: 'Chocolate',
    aliases: ['chocolate', 'dairy milk', 'cocoa'],
    fromMonths: 24,
    why: 'Sugar and some caffeine. A small piece now and then after two.',
    maa: 'Fine in moderation; it has a little caffeine.',
  ),
  _Food(
    name: 'Ice cream',
    aliases: ['kulfi', 'ice-cream'],
    fromMonths: 12,
    why: 'Sugar, but fine as an occasional treat after one. Cold food does not '
        'cause colds.',
  ),
  _Food(
    name: 'Cake and mithai',
    aliases: ['cake', 'mithai', 'ladoo', 'gulab jamun', 'barfi', 'halwa'],
    fromMonths: 12,
    why: 'A taste at a birthday or festival after one is fine. Not a habit.',
    note: 'Sugar before one is best avoided, even at a ceremony.',
  ),
  _Food(
    name: 'Hard sweets, toffees and gum',
    aliases: ['toffee', 'candy', 'lollipop', 'chewing gum', 'jelly sweets'],
    fromMonths: 48,
    why: 'A serious choking risk, and bad for teeth. Gum not until he '
        'understands not to swallow it.',
  ),
  _Food(
    name: 'Sausages and processed meat',
    aliases: ['sausage', 'chicken sausage', 'chicken salami', 'nuggets', 'frozen kebab'],
    fromMonths: 24,
    why: 'Salty and processed. Round sausage slices are a choking shape: cut '
        'lengthwise.',
    maa: 'Occasionally. Fresh meat, eggs and dal are better.',
  ),
  _Food(
    name: 'Fried snacks',
    aliases: ['pakora', 'samosa', 'french fries', 'fries', 'vada'],
    fromMonths: 24,
    why: 'Oily and often salty. Fine as an occasional family treat when he is '
        'older.',
    maa: 'Occasionally.',
  ),

  // ---- meat and seafood -----------------------------------------------------
  _Food(
    name: 'Prawns and shellfish',
    aliases: ['jhinga', 'prawn', 'shrimp', 'crab', 'kekda'],
    fromMonths: 8,
    why: 'Well cooked and chopped fine. Shellfish is a common allergen, so '
        'introduce it on its own.',
  ),
  _Food(
    name: 'Liver',
    aliases: ['kaleji', 'chicken liver'],
    fromMonths: 8,
    why: 'Rich in iron, but very high in vitamin A, so a small amount once a '
        'week at most.',
    maa: 'Fine in moderation, once a week or so.',
  ),
  _Food(
    name: 'Large fish',
    aliases: ['shark', 'swordfish', 'king mackerel', 'surmai', 'tuna'],
    fromMonths: 24,
    why: 'Big predatory fish carry more mercury. Choose smaller fish like rohu, '
        'pomfret or sardines for young children.',
    maa: 'Prefer smaller fish (rohu, pomfret, sardines); limit shark, swordfish and king mackerel, which carry more mercury.',
  ),
  _Food(
    name: 'Raw or undercooked meat, fish and eggs',
    aliases: ['sushi', 'half fry', 'runny egg', 'rare meat', 'raw egg'],
    fromMonths: 999,
    avoidEntirely: true,
    why: 'Can carry germs that make young children very ill. Cook eggs until '
        'firm and meat and fish right through.',
    maa: 'Best cooked for you too, to avoid food poisoning.',
  ),
  _Food(
    name: 'Soup and bone broth',
    aliases: ['soup', 'yakhni', 'shorba', 'broth'],
    fromMonths: 6,
    why: 'Home-made and unsalted, it is a good way to add protein and taste.',
  ),

  // ===========================================================================
  //  Added 2026-10-02 (second pass): Indian dishes, dals, flours, vegetables,
  //  fruits, drinks, sweets, condiments and tonics, each with the mother's
  //  line where hers differs. REQUIRED_REVIEW, as above.
  // ===========================================================================
  _Food(
    name: 'Moong dal',
    aliases: ['green gram', 'yellow moong', 'moong'],
    fromMonths: 6,
    why: 'The gentlest dal to start with: easy to digest, cooked soft and mashed.',
  ),
  _Food(
    name: 'Masoor dal',
    aliases: ['red lentil', 'masoor'],
    fromMonths: 6,
    why: 'Cooks quickly to a smooth mash. Good protein and iron.',
  ),
  _Food(
    name: 'Toor dal',
    aliases: ['arhar', 'tuvar', 'pigeon pea'],
    fromMonths: 6,
    why: 'The everyday dal of many homes, cooked soft for him.',
  ),
  _Food(
    name: 'Urad dal',
    aliases: ['black gram', 'urad', 'dal makhani'],
    fromMonths: 8,
    why: 'Heavier to digest; start in small amounts, as in idli batter.',
  ),
  _Food(
    name: 'Chana dal and besan',
    aliases: ['bengal gram', 'gram flour', 'besan', 'chana dal'],
    fromMonths: 8,
    why: 'Cooked well, as chilla or in dal. Besan is a good protein flour.',
  ),
  _Food(
    name: 'Horse gram',
    aliases: ['kulthi', 'kollu', 'hurali'],
    fromMonths: 12,
    why: 'Nutritious but heavy; cooked soft, in small amounts after one.',
  ),
  _Food(
    name: 'Moth beans',
    aliases: ['matki', 'moth'],
    fromMonths: 12,
    why: 'Cooked soft or as cooked sprouts, after one.',
  ),
  _Food(
    name: 'Sattu',
    aliases: ['roasted gram flour', 'sattu'],
    fromMonths: 8,
    why: 'Roasted gram flour mixed into porridge. Protein-rich and filling.',
    maa: 'Fine and filling; a sattu drink is a good summer snack for you.',
  ),
  _Food(
    name: 'Kuttu and singhara flour',
    aliases: ['buckwheat', 'kuttu', 'water chestnut flour', 'singhara', 'vrat atta'],
    fromMonths: 8,
    why: 'Fast-day flours, fine in cooked rotis or porridge.',
    maa: 'Fine for you on fast days, with plenty of fluids.',
  ),
  _Food(
    name: 'Rajgira',
    aliases: ['amaranth', 'ramdana'],
    fromMonths: 6,
    why: 'A protein-rich grain, as porridge or ladoo.',
  ),
  _Food(
    name: 'Barley',
    aliases: ['jau', 'barley water'],
    fromMonths: 8,
    why: 'Cooked soft as porridge. Barley water can be offered in small sips after six months.',
  ),
  _Food(
    name: 'Quinoa',
    aliases: ['quinoa'],
    fromMonths: 8,
    why: 'Rinsed well and cooked soft. A complete protein.',
  ),
  _Food(
    name: 'Brown and red rice',
    aliases: ['brown rice', 'red rice', 'matta rice'],
    fromMonths: 8,
    why: 'Fine once he manages white rice; cook it very soft.',
  ),
  _Food(
    name: 'Maida',
    aliases: ['all purpose flour', 'refined flour', 'maida'],
    fromMonths: 12,
    why: 'Fine occasionally, but whole wheat and millets give more nutrition.',
  ),
  _Food(
    name: 'Upma',
    aliases: ['rava upma', 'uppittu'],
    fromMonths: 8,
    why: 'Soft suji upma with vegetables, without chilli or much salt.',
  ),
  _Food(
    name: 'Dhokla',
    aliases: ['khaman', 'dhokla'],
    fromMonths: 8,
    why: 'Soft and spongy. Make his without sugar syrup or tempering chillies.',
  ),
  _Food(
    name: 'Uttapam',
    aliases: ['uthappam'],
    fromMonths: 8,
    why: 'Soft, with finely grated vegetables.',
  ),
  _Food(
    name: 'Paratha',
    aliases: ['aloo paratha', 'paneer paratha', 'gobhi paratha'],
    fromMonths: 8,
    why: 'Soft parathas with little oil, cut into strips.',
  ),
  _Food(
    name: 'Thepla',
    aliases: ['methi thepla'],
    fromMonths: 8,
    why: 'Soft methi thepla is a good finger food.',
  ),
  _Food(
    name: 'Puri and bhature',
    aliases: ['poori', 'bhatura', 'chole bhature'],
    fromMonths: 24,
    why: 'Deep fried and heavy. An occasional treat when older.',
    maa: 'Occasionally.',
  ),
  _Food(
    name: 'Kadhi',
    aliases: ['kadhi pakora', 'kadhi'],
    fromMonths: 8,
    why: 'Plain kadhi without pakoras or chilli, with rice.',
  ),
  _Food(
    name: 'Sambar and rasam',
    aliases: ['sambar', 'rasam'],
    fromMonths: 8,
    why: 'Mild sambar with soft vegetables, mashed with rice. Go easy on tamarind and chilli at first.',
  ),
  _Food(
    name: 'Curd rice',
    aliases: ['thayir sadam', 'dahi chawal', 'mosaru anna'],
    fromMonths: 6,
    why: 'Soft rice mashed with curd. Gentle and loved.',
  ),
  _Food(
    name: 'Pulao and biryani',
    aliases: ['pulao', 'biryani', 'fried rice'],
    fromMonths: 12,
    why: 'A mild homemade pulao is fine. Spicy biryani can wait.',
    maa: 'Fine; homemade is lighter than restaurant biryani.',
  ),
  _Food(
    name: 'Dal makhani',
    aliases: ['dal makhani'],
    fromMonths: 12,
    why: 'Rich with butter and cream. A small portion now and then.',
  ),
  _Food(
    name: 'Pav bhaji',
    aliases: ['pav bhaji'],
    fromMonths: 24,
    why: 'Usually buttery and spicy. A mild homemade version is fine for older children.',
  ),
  _Food(
    name: 'Vada pav and samosa',
    aliases: ['vada pav', 'samosa', 'kachori'],
    fromMonths: 24,
    why: 'Fried and spicy. An occasional treat when older.',
    maa: 'Occasionally.',
  ),
  _Food(
    name: 'Momos',
    aliases: ['dumplings', 'momo'],
    fromMonths: 24,
    why: 'Steamed, homemade or from a clean shop, cut small. Skip the hot chutney.',
    maa: 'Fine from a clean shop; skip street momos if unsure of hygiene.',
  ),
  _Food(
    name: 'Pizza and burgers',
    aliases: ['pizza', 'burger', 'fast food'],
    fromMonths: 24,
    why: 'Salty and fatty. Fine as an occasional family treat.',
    maa: 'Occasionally.',
  ),
  _Food(
    name: 'Sandwich',
    aliases: ['sandwich', 'grilled sandwich'],
    fromMonths: 12,
    why: 'Wholewheat bread with paneer, egg or vegetables, cut small.',
  ),
  _Food(
    name: 'Chilla',
    aliases: ['besan chilla', 'moong chilla', 'pesarattu'],
    fromMonths: 8,
    why: 'A soft pancake of besan or moong, cut into strips.',
  ),
  _Food(
    name: 'Appam and idiyappam',
    aliases: ['appam', 'idiyappam', 'string hoppers'],
    fromMonths: 8,
    why: 'Soft and easy to eat with a mild stew.',
  ),
  _Food(
    name: 'Pongal',
    aliases: ['ven pongal', 'khara pongal'],
    fromMonths: 6,
    why: 'Rice and moong cooked soft with a little ghee. A classic first food.',
  ),
  _Food(
    name: 'Kheer and payasam',
    aliases: ['kheer', 'payasam', 'phirni'],
    fromMonths: 6,
    why: 'Rice and milk cooked soft is fine. Add sugar only after one.',
    note: 'Milk cooked into food is fine from six months.',
  ),
  _Food(
    name: 'Sevaiyan',
    aliases: ['seviyan', 'vermicelli'],
    fromMonths: 8,
    why: 'Cooked soft in milk or with vegetables. Sweet versions after one.',
  ),
  _Food(
    name: 'Halwa',
    aliases: ['suji halwa', 'gajar halwa', 'moong dal halwa'],
    fromMonths: 12,
    why: 'Fine as an occasional treat after one; it is sweet and rich.',
  ),
  _Food(
    name: 'Khichdi with vegetables',
    aliases: ['vegetable khichdi', 'masala khichdi'],
    fromMonths: 6,
    why: 'Rice, dal and soft vegetables, mashed. One pot for the family.',
  ),
  _Food(
    name: 'Bitter gourd',
    aliases: ['karela'],
    fromMonths: 12,
    why: 'Very bitter; a small amount cooked after one, if he likes it.',
  ),
  _Food(
    name: 'Tinda, parwal and tindora',
    aliases: ['tinda', 'parwal', 'pointed gourd', 'ivy gourd', 'tendli', 'tindora'],
    fromMonths: 6,
    why: 'Soft gourds cooked well. Gentle first vegetables.',
  ),
  _Food(
    name: 'Ash gourd and ridge gourd',
    aliases: ['petha', 'tori', 'turai', 'ridge gourd', 'ash gourd'],
    fromMonths: 6,
    why: 'Mild and watery, cooked soft.',
  ),
  _Food(
    name: 'Arbi and suran',
    aliases: ['colocasia', 'arbi', 'yam', 'suran', 'jimikand'],
    fromMonths: 8,
    why: 'Cooked well and mashed. Can itch the throat if undercooked.',
  ),
  _Food(
    name: 'Raw banana',
    aliases: ['kacha kela', 'plantain', 'vazhakkai'],
    fromMonths: 8,
    why: 'Cooked and mashed. Filling.',
  ),
  _Food(
    name: 'Drumstick',
    aliases: ['moringa pods', 'sahjan', 'murungakkai'],
    fromMonths: 8,
    why: 'Cooked in sambar; scrape out the soft flesh for him. Never the fibrous skin.',
  ),
  _Food(
    name: 'Radish and turnip',
    aliases: ['mooli', 'shalgam', 'turnip'],
    fromMonths: 8,
    why: 'Cooked soft. Raw radish is too hard and strong for babies.',
  ),
  _Food(
    name: 'Capsicum',
    aliases: ['shimla mirch', 'bell pepper'],
    fromMonths: 8,
    why: 'Cooked soft and chopped fine.',
  ),
  _Food(
    name: 'Lotus stem',
    aliases: ['kamal kakdi', 'nadru'],
    fromMonths: 12,
    why: 'Cooked soft and chopped fine. Fibrous, so after one.',
  ),
  _Food(
    name: 'Mustard greens and other saag',
    aliases: ['sarson', 'sarson ka saag', 'chaulai', 'amaranth leaves', 'colocasia leaves'],
    fromMonths: 8,
    why: 'Cooked soft and blended into dal or rice.',
  ),
  _Food(
    name: 'Onion and spring onion',
    aliases: ['pyaz', 'hari pyaz', 'onion'],
    fromMonths: 6,
    why: 'Cooked into food, fine from the start. Raw onion can wait.',
  ),
  _Food(
    name: 'Zucchini and lettuce',
    aliases: ['zucchini', 'lettuce', 'salad'],
    fromMonths: 8,
    why: 'Zucchini cooked soft. Raw salad leaves are hard to chew until he is older.',
  ),
  _Food(
    name: 'Raw salad vegetables',
    aliases: ['raw carrot', 'raw cucumber', 'salad'],
    fromMonths: 48,
    why: 'Hard raw pieces are a choking risk until about four. Grate or cook them before then.',
    maa: 'Fine and good for you. Wash well.',
  ),
  _Food(
    name: 'Bamboo shoot',
    aliases: ['bamboo shoot', 'khorisa'],
    fromMonths: 24,
    why: 'Must be well boiled; raw shoots contain a natural toxin. Fermented bamboo shoot is strong for small children.',
    maa: 'Fine if well cooked.',
  ),
  _Food(
    name: 'Pineapple',
    aliases: ['ananas'],
    fromMonths: 8,
    why: 'Ripe and soft, chopped small. The acid may redden the skin around his mouth.',
    maa: 'Fine for you. Pineapple is only questioned in pregnancy.',
  ),
  _Food(
    name: 'Kiwi',
    aliases: ['kiwi'],
    fromMonths: 8,
    why: 'Ripe, peeled and chopped. Tart, so offer with other fruit.',
  ),
  _Food(
    name: 'Plums, peaches and apricots',
    aliases: ['aloo bukhara', 'aadoo', 'khubani', 'plum', 'peach', 'apricot'],
    fromMonths: 6,
    why: 'Ripe, peeled, stone removed, mashed or chopped. Good for constipation.',
  ),
  _Food(
    name: 'Figs',
    aliases: ['anjeer', 'fig'],
    fromMonths: 8,
    why: 'Soaked dried figs mashed, or soft fresh figs. Good for constipation.',
  ),
  _Food(
    name: 'Custard apple',
    aliases: ['sitaphal', 'sharifa'],
    fromMonths: 6,
    why: 'Scoop the soft flesh and remove every seed. The seeds are toxic if crushed and a choking risk.',
  ),
  _Food(
    name: 'Bael',
    aliases: ['bel', 'wood apple'],
    fromMonths: 12,
    why: 'Ripe bael pulp or sharbat without sugar, in small amounts.',
  ),
  _Food(
    name: 'Ber',
    aliases: ['jujube', 'ber', 'bor'],
    fromMonths: 24,
    why: 'Small fruit with a hard stone; a choking risk. Stone removed and chopped, when older.',
  ),
  _Food(
    name: 'Cherries',
    aliases: ['cherry'],
    fromMonths: 8,
    why: 'Stone removed and cut into quarters.',
  ),
  _Food(
    name: 'Jackfruit',
    aliases: ['kathal', 'phanas', 'chakka'],
    fromMonths: 8,
    why: 'Ripe jackfruit pulp, seeds removed, chopped small. Raw jackfruit cooked as a vegetable is fine too.',
  ),
  _Food(
    name: 'Starfruit',
    aliases: ['kamrakh', 'carambola'],
    fromMonths: 24,
    why: 'Small amounts only for children; avoid entirely for anyone with kidney problems.',
    maa: 'Fine in normal amounts if your kidneys are healthy.',
  ),
  _Food(
    name: 'Sugarcane',
    aliases: ['ganna'],
    fromMonths: 12,
    why: 'Fresh sugarcane juice from a clean stall, in small amounts after one. Chewing sticks are a choking risk.',
    maa: 'Fine from a clean stall with clean ice; it is very sweet.',
  ),
  _Food(
    name: 'Khoa and mawa sweets',
    aliases: ['khoya', 'mawa', 'peda', 'burfi'],
    fromMonths: 12,
    why: 'Rich and sweet. A small taste at festivals after one.',
  ),
  _Food(
    name: 'Rasgulla and rasmalai',
    aliases: ['rasgulla', 'rasmalai', 'chhena sweets'],
    fromMonths: 12,
    why: 'Sugary; an occasional taste after one. Squeeze out the syrup.',
  ),
  _Food(
    name: 'Jalebi and fried sweets',
    aliases: ['jalebi', 'imarti', 'gulab jamun'],
    fromMonths: 24,
    why: 'Fried and very sugary. A festival treat when older.',
    maa: 'Occasionally.',
  ),
  _Food(
    name: 'Shrikhand and rabri',
    aliases: ['shrikhand', 'rabri', 'basundi'],
    fromMonths: 12,
    why: 'Sweetened dairy. A small amount after one.',
  ),
  _Food(
    name: 'Condensed milk',
    aliases: ['milkmaid', 'condensed milk'],
    fromMonths: 24,
    why: 'Mostly sugar. Not a milk substitute at any age.',
    maa: 'Occasionally, in desserts.',
  ),
  _Food(
    name: 'Flavoured milk and yoghurt',
    aliases: ['flavoured milk', 'fruit yoghurt', 'chocolate milk'],
    fromMonths: 24,
    why: 'Usually high in sugar. Plain milk and curd with fresh fruit are better.',
  ),
  _Food(
    name: 'Chikki and til laddoo',
    aliases: ['chikki', 'gud chikki', 'til laddoo', 'peanut chikki'],
    fromMonths: 36,
    why: 'Hard and sticky, a choking risk for small children. Crushed into food is fine earlier.',
  ),
  _Food(
    name: 'Khakhra and mathri',
    aliases: ['khakhra', 'mathri'],
    fromMonths: 12,
    why: 'Crisp and salty; a soft-dissolving piece is fine after one.',
  ),
  _Food(
    name: 'Murukku and chakli',
    aliases: ['murukku', 'chakli'],
    fromMonths: 36,
    why: 'Hard and crunchy; a choking risk for small children.',
  ),
  _Food(
    name: 'Bhel and sev puri',
    aliases: ['bhel', 'sev puri', 'sev'],
    fromMonths: 36,
    why: 'Spicy, salty, and hard bits. When he is older, a mild home version.',
  ),
  _Food(
    name: 'Banana chips',
    aliases: ['kela chips', 'banana chips'],
    fromMonths: 36,
    why: 'Fried, salty and hard. An occasional snack when older.',
  ),
  _Food(
    name: 'Roasted chana',
    aliases: ['bhuna chana', 'roasted gram'],
    fromMonths: 48,
    why: 'A whole roasted chana is a choking food until about four. Powdered into food earlier.',
  ),
  _Food(
    name: 'Baked crackers and puffs',
    aliases: ['rice puffs', 'baby puffs', 'crackers'],
    fromMonths: 8,
    why: 'Melt-in-the-mouth puffs without added salt or sugar are fine finger food.',
  ),
  _Food(
    name: 'Nimbu pani',
    aliases: ['lemonade', 'shikanji', 'nimbu pani'],
    fromMonths: 12,
    why: 'Without much sugar or salt, a few sips after one.',
  ),
  _Food(
    name: 'Aam panna and jaljeera',
    aliases: ['aam panna', 'jaljeera'],
    fromMonths: 24,
    why: 'Tangy, salty and spicy. A small glass when older.',
  ),
  _Food(
    name: 'Rooh Afza and sharbats',
    aliases: ['rooh afza', 'sharbat', 'rose syrup'],
    fromMonths: 24,
    why: 'Mostly sugar syrup. Occasionally, well diluted, when older.',
  ),
  _Food(
    name: 'Soda and sparkling drinks',
    aliases: ['soda', 'sparkling water'],
    fromMonths: 24,
    why: 'Plain soda is not needed. Sweet fizzy drinks are best avoided.',
  ),
  _Food(
    name: 'Thandai',
    aliases: ['thandai', 'bhang'],
    fromMonths: 24,
    why: 'Plain thandai with milk and nuts is fine when older. Never bhang: it contains cannabis.',
    maa: 'Plain thandai is fine. Bhang is not safe while breastfeeding.',
  ),
  _Food(
    name: 'Kombucha and fermented drinks',
    aliases: ['kombucha', 'kanji'],
    fromMonths: 24,
    why: 'Can contain a little alcohol and caffeine. Homemade kanji is fine in small amounts when older.',
  ),
  _Food(
    name: 'Mustard, coconut and sesame oil',
    aliases: ['sarson ka tel', 'nariyal tel', 'til ka tel', 'cooking oil'],
    fromMonths: 6,
    why: 'Fine for cooking his food, in small amounts.',
  ),
  _Food(
    name: 'Coconut and green chutney',
    aliases: ['nariyal chutney', 'hari chutney', 'pudina chutney'],
    fromMonths: 8,
    why: 'Fresh and mild, without green chilli for him.',
  ),
  _Food(
    name: 'Ketchup and mayonnaise',
    aliases: ['ketchup', 'mayo', 'sauce'],
    fromMonths: 24,
    why: 'Salty and sugary; a little now and then.',
  ),
  _Food(
    name: 'Vinegar',
    aliases: ['sirka', 'vinegar'],
    fromMonths: 12,
    why: 'Fine in small amounts in cooking.',
  ),
  _Food(
    name: 'Saffron and elaichi',
    aliases: ['kesar', 'saffron', 'elaichi', 'cardamom'],
    fromMonths: 6,
    why: 'A pinch in kheer or milk is fine.',
  ),
  _Food(
    name: 'Cinnamon and cloves',
    aliases: ['dalchini', 'laung', 'cinnamon', 'cloves'],
    fromMonths: 8,
    why: 'A pinch cooked into food. Whole pieces out before serving.',
  ),
  _Food(
    name: 'Tulsi, mint and curry leaves',
    aliases: ['tulsi', 'pudina', 'kadi patta', 'mint', 'curry leaves'],
    fromMonths: 6,
    why: 'Cooked into food for flavour. Remove whole leaves for small babies.',
  ),
  _Food(
    name: 'Kalonji and dill',
    aliases: ['nigella', 'kalonji', 'suva', 'dill', 'shepu'],
    fromMonths: 8,
    why: 'Small amounts in cooking are fine.',
  ),
  _Food(
    name: 'Chyawanprash',
    aliases: ['chyawanprash'],
    fromMonths: 24,
    why: 'Contains honey and many herbs. Not for babies; ask your doctor before giving it to an older child.',
    maa: 'Ask your doctor first. Herbal products are not well tested in breastfeeding.',
  ),
  _Food(
    name: 'Ashwagandha, giloy and herbal supplements',
    aliases: ['ashwagandha', 'giloy', 'tulsi drops', 'triphala', 'herbal supplement'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Herbal medicines are medicines. Not for babies or young children unless a doctor prescribes them.',
    maa: 'Ask your doctor first. Many herbs are not tested in breastfeeding.',
  ),
  _Food(
    name: 'Gond and panjiri',
    aliases: ['gond', 'panjiri', 'dink laddoo'],
    fromMonths: 24,
    why: 'Rich postpartum foods made for the mother; too heavy and sweet for small children.',
    maa: 'Fine and traditional for you, in sensible amounts. A few a day is plenty.',
  ),
  _Food(
    name: 'Gond katira',
    aliases: ['gond katira', 'tragacanth'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Swells a lot when soaked and can choke or block the gut if not fully soaked. Not for young children.',
    maa: 'Fine for you if fully soaked first.',
  ),
  _Food(
    name: 'Fenugreek seeds',
    aliases: ['methi dana', 'fenugreek'],
    fromMonths: 8,
    why: 'Soaked and cooked into food in small amounts.',
    maa: 'Fine in food amounts; traditionally used for milk.',
  ),
  _Food(
    name: 'Keema',
    aliases: ['minced meat', 'qeema'],
    fromMonths: 8,
    why: 'Minced mutton or chicken cooked soft. Good iron.',
  ),
  _Food(
    name: 'Crab and squid',
    aliases: ['kekda', 'squid', 'calamari'],
    fromMonths: 12,
    why: 'Well cooked and chopped fine. Shellfish is a common allergen.',
  ),
  _Food(
    name: 'Dry fish',
    aliases: ['sukhi machli', 'dry fish', 'bombil'],
    fromMonths: 24,
    why: 'Very salty. A small amount in family food when older.',
    maa: 'Fine occasionally; it is salty.',
  ),
  _Food(
    name: 'Egg yolk only',
    aliases: ['yolk'],
    fromMonths: 6,
    why: 'Not needed: the whole egg, well cooked, is fine from six months.',
  ),
  _Food(
    name: 'Duck and other eggs',
    aliases: ['duck egg', 'quail egg'],
    fromMonths: 8,
    why: 'Well cooked, like hen eggs.',
  ),
  _Food(
    name: 'Mutton bone soup',
    aliases: ['paya', 'nalli', 'bone soup'],
    fromMonths: 8,
    why: 'Unsalted, with the fat skimmed. Check for bone splinters.',
  ),
  _Food(
    name: 'Sabudana khichdi',
    aliases: ['sabudana khichdi', 'sago khichdi'],
    fromMonths: 12,
    why: 'Soaked and cooked until soft, with crushed (not whole) peanuts.',
    maa: 'Fine on fast days; add curd or peanuts for protein.',
  ),
  _Food(
    name: 'Aloo tikki and cutlets',
    aliases: ['tikki', 'cutlet', 'aloo tikki'],
    fromMonths: 12,
    why: 'Shallow-fried or baked at home, soft inside, without chilli.',
  ),
  _Food(
    name: 'Paneer tikka and tandoori dishes',
    aliases: ['paneer tikka', 'tandoori chicken', 'tikka', 'kebab'],
    fromMonths: 24,
    why: 'Often spicy and charred. A mild homemade version when older.',
  ),
  _Food(
    name: 'Fish curry',
    aliases: ['machher jhol', 'meen kuzhambu', 'fish curry'],
    fromMonths: 8,
    why: 'Mild, with every bone removed. Skip the chilli for him.',
  ),
  _Food(
    name: 'Egg curry and bhurji',
    aliases: ['egg curry', 'anda bhurji', 'omelette'],
    fromMonths: 8,
    why: 'Well-cooked egg, mild masala.',
  ),
  _Food(
    name: 'Rajma chawal and chole',
    aliases: ['rajma chawal', 'chole chawal'],
    fromMonths: 8,
    why: 'Very soft, mashed, with little salt for him.',
  ),
  _Food(
    name: 'Litti chokha',
    aliases: ['litti', 'chokha', 'baati'],
    fromMonths: 12,
    why: 'Sattu-filled litti is filling; break it small and soften with chokha.',
  ),
  _Food(
    name: 'Dal dhokli and dal bati',
    aliases: ['dal dhokli', 'dal bati'],
    fromMonths: 12,
    why: 'Soft pieces in dal are fine. Bati is hard; soak it well.',
  ),
  _Food(
    name: 'Thalipeeth and handvo',
    aliases: ['thalipeeth', 'handvo'],
    fromMonths: 8,
    why: 'Soft multigrain pancakes, cut into strips.',
  ),
  _Food(
    name: 'Puttu and neer dosa',
    aliases: ['puttu', 'neer dosa'],
    fromMonths: 8,
    why: 'Soft rice dishes, with a mild curry.',
  ),
  _Food(
    name: 'Avial, kootu and poriyal',
    aliases: ['avial', 'kootu', 'poriyal', 'thoran'],
    fromMonths: 8,
    why: 'Mild vegetable dishes with coconut; cook vegetables soft.',
  ),
  _Food(
    name: 'Misal and usal',
    aliases: ['misal pav', 'usal'],
    fromMonths: 24,
    why: 'Usually spicy. A plain sprouts usal is fine earlier.',
  ),
  _Food(
    name: 'Undhiyu',
    aliases: ['undhiyu'],
    fromMonths: 12,
    why: 'Mixed vegetables, rich and spiced; a small mild portion after one.',
  ),
  _Food(
    name: 'Pasta in white sauce',
    aliases: ['white sauce pasta', 'mac and cheese'],
    fromMonths: 12,
    why: 'Fine occasionally; homemade is less salty.',
  ),
  _Food(
    name: 'Raw mango',
    aliases: ['kairi', 'kacchi kairi', 'raw mango'],
    fromMonths: 24,
    why: 'Very sour; small amounts in cooked dishes when older.',
    maa: 'Fine; very sour raw mango can upset some stomachs.',
  ),
  _Food(
    name: 'Palm fruit and fresh water chestnut',
    aliases: ['tadgola', 'nungu', 'ice apple', 'singhara'],
    fromMonths: 12,
    why: 'Soft palm fruit flesh, or boiled water chestnut, chopped small.',
  ),
  _Food(
    name: 'Dragon fruit and other exotic fruit',
    aliases: ['dragon fruit', 'persimmon', 'avocado', 'passion fruit'],
    fromMonths: 8,
    why: 'Ripe, soft and chopped. Introduce one new fruit at a time.',
  ),
  _Food(
    name: 'Mulberries',
    aliases: ['shahtoot', 'mulberry'],
    fromMonths: 8,
    why: 'Ripe and mashed, or halved.',
  ),
  _Food(
    name: 'Black grapes and raisins soaked',
    aliases: ['kali draksh', 'munakka soaked'],
    fromMonths: 8,
    why: 'Soaked raisins mashed help constipation. Whole grapes are quartered until four.',
  ),
  _Food(
    name: 'Canned fruit',
    aliases: ['canned fruit', 'fruit cocktail'],
    fromMonths: 24,
    why: 'Often in sugar syrup. Fresh fruit is better.',
  ),
  _Food(
    name: 'Badam milk',
    aliases: ['badam doodh', 'almond milk drink'],
    fromMonths: 12,
    why: 'Warm milk with powdered almonds, no sugar, after one.',
  ),
  _Food(
    name: 'Ragi malt',
    aliases: ['ragi java', 'ragi ambli', 'ragi malt'],
    fromMonths: 6,
    why: 'Ragi porridge thinned with milk. A classic, without sugar before one.',
  ),
  _Food(
    name: 'Hot chocolate',
    aliases: ['hot chocolate', 'cocoa milk'],
    fromMonths: 24,
    why: 'Sweet with a little caffeine. An occasional treat when older.',
  ),
  _Food(
    name: 'Protein powder',
    aliases: ['protein powder', 'whey'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Not for children. They get enough protein from food.',
    maa: 'Fine for you if it has no added herbs or stimulants; food is usually enough.',
  ),
  _Food(
    name: 'Packaged baby cereal',
    aliases: ['cerelac', 'baby cereal', 'nestum'],
    fromMonths: 6,
    why: 'Fine, but many are sweetened. Home-cooked ragi, rice and dal are cheaper and just as good.',
  ),
  _Food(
    name: 'Baby food pouches',
    aliases: ['puree pouch', 'baby food pouch'],
    fromMonths: 6,
    why: 'Fine when travelling, but sucking from a pouch skips learning to eat from a spoon. Squeeze onto a spoon.',
  ),
  _Food(
    name: 'Nutella and chocolate spreads',
    aliases: ['nutella', 'chocolate spread'],
    fromMonths: 24,
    why: 'Mostly sugar. A thin smear occasionally when older.',
  ),
  _Food(
    name: 'Jam and fruit spread',
    aliases: ['jam', 'kissan', 'fruit spread'],
    fromMonths: 12,
    why: 'Mostly sugar; a thin layer occasionally.',
  ),
  _Food(
    name: 'Cheese spread',
    aliases: ['cheese spread', 'processed spread'],
    fromMonths: 12,
    why: 'Salty; a thin layer occasionally.',
  ),
  _Food(
    name: 'Vanaspati and dalda',
    aliases: ['dalda', 'vanaspati', 'margarine'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Contains trans fats that are bad for hearts at every age. Use ghee or oil instead.',
    maa: 'Best avoided; use ghee or oil.',
  ),
  _Food(
    name: 'Frozen and ready-to-eat meals',
    aliases: ['frozen food', 'ready to eat', 'packaged meal'],
    fromMonths: 24,
    why: 'Usually salty. Fine occasionally; home cooking is better.',
  ),
  _Food(
    name: 'Ice lollies and kulfi from carts',
    aliases: ['ice lolly', 'gola', 'baraf ka gola', 'kulfi cart'],
    fromMonths: 36,
    why: 'Cart ice is often made from unsafe water. Homemade lollies from boiled water are fine when older.',
    maa: 'Avoid ice from carts; it often uses unsafe water.',
  ),
  _Food(
    name: 'Ice',
    aliases: ['baraf', 'ice cubes'],
    fromMonths: 12,
    why: 'Ice made from boiled or filtered water is fine. Whole ice cubes are a choking risk for small children.',
  ),
  _Food(
    name: 'Peanut butter on bread',
    aliases: ['peanut butter toast'],
    fromMonths: 12,
    why: 'A thin layer on soft toast, not a thick lump.',
  ),
  _Food(
    name: 'Mushroom and cheese pizza at home',
    aliases: ['homemade pizza'],
    fromMonths: 24,
    why: 'Homemade with a wholewheat base and vegetables is a fine family meal.',
  ),
  _Food(
    name: 'Corn on the cob',
    aliases: ['bhutta', 'corn cob'],
    fromMonths: 48,
    why: 'Whole kernels and the cob are choking risks until about four. Cut kernels off and mash earlier.',
    maa: 'Fine for you.',
  ),
  _Food(
    name: 'Sweet corn soup',
    aliases: ['corn soup', 'tomato soup', 'soup'],
    fromMonths: 8,
    why: 'Homemade and unsalted, blended smooth.',
  ),
  _Food(
    name: 'Gur and til in winter',
    aliases: ['gajak', 'revdi', 'til gud'],
    fromMonths: 36,
    why: 'Hard, sticky winter sweets; a choking risk for small children.',
    maa: 'Fine in winter, in moderation.',
  ),
  _Food(
    name: 'Fermented foods',
    aliases: ['idli batter', 'dosa batter', 'kanji', 'pickled vegetables'],
    fromMonths: 8,
    why: 'Freshly fermented idli and dosa batter, well cooked, is fine.',
  ),
  _Food(
    name: 'Sugarcane jaggery water',
    aliases: ['panakam', 'gud ka pani'],
    fromMonths: 12,
    why: 'Sweet; small amounts after one.',
  ),

  // ---- regional staples and festival foods, added 2026-10-02 (third pass) ----
  _Food(
    name: 'Makki ki roti',
    aliases: ['makki roti', 'maize roti', 'corn roti'],
    fromMonths: 12,
    why: 'Soft and warm with saag after one. It can be dense, so tear it small.',
  ),
  _Food(
    name: 'Jowar and bajra roti',
    aliases: ['bhakri', 'jowar roti', 'bajra roti', 'rotla'],
    fromMonths: 12,
    why: 'Millet rotis are nutritious; soak in dal or curd so they are soft enough.',
  ),
  _Food(
    name: 'Dhansak',
    aliases: ['dhansak'],
    fromMonths: 12,
    why: 'A Parsi dal with vegetables and meat; a mild portion after one.',
  ),
  _Food(
    name: 'Kokum',
    aliases: ['kokum', 'sol kadhi', 'amsul'],
    fromMonths: 12,
    why: 'Kokum drinks and sol kadhi are tangy; small amounts after one.',
  ),
  _Food(
    name: 'Idiyappam',
    aliases: ['string hoppers', 'nool puttu', 'idiyappam'],
    fromMonths: 8,
    why: 'Soft steamed rice noodles; break small and serve with a mild stew.',
  ),
  _Food(
    name: 'Sprouted ragi flour',
    aliases: ['sprouted ragi', 'ragi malt flour'],
    fromMonths: 6,
    why: 'Sprouted ragi is easier to digest and good for first porridges.',
  ),
  _Food(
    name: 'Bajra khichdi',
    aliases: ['bajra khichdi', 'pearl millet khichdi'],
    fromMonths: 8,
    why: 'Pearl millet cooked soft with moong. Warming in winter.',
  ),
  _Food(
    name: 'Methi muthia',
    aliases: ['muthia'],
    fromMonths: 12,
    why: 'Steamed fenugreek dumplings; soft pieces after one.',
  ),
  _Food(
    name: 'Kothimbir vadi',
    aliases: ['kothimbir vadi', 'coriander vadi'],
    fromMonths: 24,
    why: 'Usually fried and spicy; a steamed, mild version for older children.',
  ),
  _Food(
    name: 'Patra',
    aliases: ['alu vadi', 'patrode', 'patra'],
    fromMonths: 24,
    why: 'Colocasia leaf rolls; well steamed and mild for older children. Undercooked leaves itch the throat.',
  ),
  _Food(
    name: 'Undhiyu and oondhiyu vegetables',
    aliases: ['surti undhiyu'],
    fromMonths: 12,
    why: 'Mixed winter vegetables; mild portion after one.',
  ),
  _Food(
    name: 'Sarson ka saag with makkhan',
    aliases: ['saag', 'makkhan'],
    fromMonths: 12,
    why: 'Cooked greens with a little butter; blend smooth for younger ones.',
  ),
  _Food(
    name: 'Rogan josh and rich curries',
    aliases: ['rogan josh', 'korma', 'butter chicken'],
    fromMonths: 24,
    why: 'Rich and spicy; a small mild portion when older.',
    maa: 'Fine; restaurant versions are heavier than homemade.',
  ),
  _Food(
    name: 'Haleem',
    aliases: ['haleem', 'khichda'],
    fromMonths: 24,
    why: 'Slow-cooked wheat, lentils and meat; soft and filling, mild spice for children.',
  ),
  _Food(
    name: 'Nihari and paya',
    aliases: ['nihari', 'paya'],
    fromMonths: 24,
    why: 'Rich slow-cooked meat dishes; skim the fat and keep it mild for children.',
  ),
  _Food(
    name: 'Kebabs',
    aliases: ['seekh kebab', 'shami kebab', 'galouti'],
    fromMonths: 24,
    why: 'Minced meat kebabs are soft; make sure they are cooked through and mild.',
  ),
  _Food(
    name: 'Fish fry',
    aliases: ['fish fry', 'rava fish'],
    fromMonths: 12,
    why: 'Shallow-fried boneless fish, checked for bones, mild masala.',
  ),
  _Food(
    name: 'Prawn curry',
    aliases: ['jhinga curry', 'prawn masala'],
    fromMonths: 12,
    why: 'Well-cooked prawns chopped small, mild curry. Shellfish is a common allergen.',
  ),
  _Food(
    name: 'Egg biryani and anda curry',
    aliases: ['egg biryani', 'anda curry'],
    fromMonths: 12,
    why: 'Well-cooked egg, mild spice.',
  ),
  _Food(
    name: 'Chicken tikka',
    aliases: ['chicken tikka', 'tandoori'],
    fromMonths: 24,
    why: 'Mild, well cooked, cut small; charred bits removed.',
  ),
  _Food(
    name: 'Bread pakora and bonda',
    aliases: ['bread pakora', 'batata vada', 'bonda'],
    fromMonths: 24,
    why: 'Deep fried; an occasional treat when older.',
    maa: 'Occasionally.',
  ),
  _Food(
    name: 'Dabeli and kachori',
    aliases: ['dabeli', 'kachori'],
    fromMonths: 24,
    why: 'Spicy and fried; occasionally when older.',
    maa: 'Occasionally.',
  ),
  _Food(
    name: 'Pani puri and chaat',
    aliases: ['golgappa', 'pani puri', 'chaat', 'papdi chaat'],
    fromMonths: 48,
    why: 'Puris are a choking risk and street pani is often unsafe; a home version for older children.',
    maa: 'Only from very clean stalls; pani from carts often carries tummy bugs.',
  ),
  _Food(
    name: 'Bhutta with lemon',
    aliases: ['roasted corn', 'bhutta'],
    fromMonths: 48,
    why: 'Kernels are a choking risk; cut off and mash for younger children.',
  ),
  _Food(
    name: 'Peanuts boiled',
    aliases: ['boiled peanuts', 'shengdana'],
    fromMonths: 48,
    why: 'Whole peanuts are a choking food until about four. Powdered into food earlier.',
  ),
  _Food(
    name: 'Moong dal halwa',
    aliases: ['moong halwa'],
    fromMonths: 24,
    why: 'Rich with ghee and sugar; a festive taste when older.',
  ),
  _Food(
    name: 'Modak',
    aliases: ['modak', 'ukadiche modak'],
    fromMonths: 12,
    why: 'Steamed modak with coconut and jaggery; a small taste at Ganesh Chaturthi after one.',
  ),
  _Food(
    name: 'Puran poli',
    aliases: ['puran poli', 'obbattu', 'holige'],
    fromMonths: 12,
    why: 'Sweet lentil-filled flatbread; a small piece after one.',
  ),
  _Food(
    name: 'Pongal sweet (sakkarai)',
    aliases: ['sakkarai pongal', 'sweet pongal'],
    fromMonths: 12,
    why: 'Rice and moong with jaggery and ghee; a festive taste after one.',
  ),
  _Food(
    name: 'Payasam with jaggery',
    aliases: ['palada', 'pradhaman'],
    fromMonths: 12,
    why: 'Coconut milk and jaggery kheer; small amounts after one.',
  ),
  _Food(
    name: 'Sandesh and mishti doi',
    aliases: ['sandesh', 'mishti doi'],
    fromMonths: 12,
    why: 'Sweet Bengali dairy; a small taste after one.',
  ),
  _Food(
    name: 'Ladoo varieties',
    aliases: ['besan ladoo', 'motichoor', 'rava ladoo', 'boondi ladoo'],
    fromMonths: 24,
    why: 'Sweet; hard or crumbly ladoos can choke. A small soft piece when older.',
  ),
  _Food(
    name: 'Chakli and sev in tiffins',
    aliases: ['sev', 'chakli tiffin'],
    fromMonths: 36,
    why: 'Hard and crunchy; for older children only.',
  ),
  _Food(
    name: 'Masala chai for children',
    aliases: ['masala chai', 'chai for kids'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Tea has caffeine and fills a small stomach. Milk or water is better for children.',
    maa: 'Two or three cups a day is fine for you.',
  ),
  _Food(
    name: 'Coffee for children',
    aliases: ['coffee for kids', 'cold coffee'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Caffeine is not recommended for young children.',
    maa: 'Up to two cups a day is fine for you.',
  ),
  _Food(
    name: 'Kesar milk',
    aliases: ['saffron milk', 'kesar doodh'],
    fromMonths: 12,
    why: 'Warm milk with a pinch of saffron after one.',
  ),
  _Food(
    name: 'Gulkand',
    aliases: ['gulkand', 'rose petal jam'],
    fromMonths: 24,
    why: 'Very sweet; a little now and then when older.',
  ),
  _Food(
    name: 'Murabba',
    aliases: ['amla murabba', 'murabba'],
    fromMonths: 24,
    why: 'Fruit in sugar syrup; small amounts when older.',
  ),
  _Food(
    name: 'Papad',
    aliases: ['papad', 'appalam'],
    fromMonths: 36,
    why: 'Salty and can shatter into sharp pieces; for older children.',
  ),
  _Food(
    name: 'Vada and medu vada',
    aliases: ['medu vada', 'vada'],
    fromMonths: 24,
    why: 'Fried; soft centre pieces for older toddlers occasionally.',
  ),
  _Food(
    name: 'Dosa varieties',
    aliases: ['masala dosa', 'rava dosa', 'set dosa'],
    fromMonths: 12,
    why: 'Soft dosas are fine after one; mild potato masala.',
  ),
  _Food(
    name: 'Pav and bun',
    aliases: ['ladi pav', 'bun'],
    fromMonths: 12,
    why: 'Mostly refined flour; wholewheat versions are better. Fine occasionally.',
  ),
  _Food(
    name: 'Mayonnaise sandwich spreads',
    aliases: ['sandwich spread', 'mayo spread'],
    fromMonths: 24,
    why: 'Salty and fatty; a thin layer occasionally.',
  ),
  _Food(
    name: 'Chicken soup cubes',
    aliases: ['chicken cube', 'soup cube'],
    fromMonths: 24,
    why: 'Very salty; homemade stock is better.',
  ),
  _Food(
    name: 'Flavoured yoghurt drinks',
    aliases: ['yakult', 'flavoured lassi', 'probiotic drink'],
    fromMonths: 24,
    why: 'Often sweetened; plain curd or chaas is better.',
  ),
];

class PpBabyFoodCheckScreen extends StatefulWidget {
  const PpBabyFoodCheckScreen({super.key, this.initialQuery});

  /// Pre-filled by the parenting search (2026-10-02), so a result lands on
  /// the answer rather than an empty box.
  final String? initialQuery;

  @override
  State<PpBabyFoodCheckScreen> createState() => _PpBabyFoodCheckScreenState();
}

class _PpBabyFoodCheckScreenState extends State<PpBabyFoodCheckScreen> {
  /// Derived from the profile, and changeable. See the note in the fever check.
  /// His age, read once on open. Never chosen — see the age rule.
  final int _months = ppMonthsSinceBirth;

  static String _bandLabel(int months) {
    for (final b in kPpChildFoodBands) {
      if (months >= b.$2 && months < b.$3) return b.$1;
    }
    return kPpChildFoodBands.last.$1;
  }
  late String _query = widget.initialQuery ?? '';
  late final _queryCtrl = TextEditingController(text: _query);

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  List<_Food> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _foods;
    return [
      for (final f in _foods)
        if (f.name.toLowerCase().contains(q) ||
            f.aliases.any((a) => a.contains(q) || q.contains(a)))
          f,
    ];
  }

  // ---- the one ParentVeda look (2026-10-07) ------------------------------------
  //  The shell every TTC and pregnancy tool wears, and each answer as
  //  pregnancy's Can I card: white, one verdict dot in pregnancy's colours.
  //  With no search, the first 30 and a "Show all"; 289 cards at once is a
  //  wall. The old page is `_buildBeforeShell`, kept for revert.
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final results = _results;
    final searching = _query.trim().isNotEmpty;
    final shown = searching || _all ? results : results.take(30).toList();
    final c = ChildProfileStore.instance;
    return PregToolScaffold(
      hue: 96,
      eyebrow: 'Food',
      mark: IntentMark.forkMark,
      title: 'Can my baby eat this?',
      intro: 'A straight answer for ${c.nameMid}\'s age, with the reason, and a line for you while you '
          'breastfeed. Type the food in English or Hindi.',
      children: [
        pregToolPad(Text('FOR ${c.nameMid.toUpperCase()}  ·  ${_bandLabel(_months).toUpperCase()}',
            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.action))),
        const SizedBox(height: 10),
        pregToolPad(TextField(
          key: const ValueKey('pp_food_field'),
          controller: _queryCtrl,
          onChanged: (v) => setState(() => _query = v),
          style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, color: p.ink1),
          decoration: InputDecoration(
            hintText: 'egg, honey, dal, ghee, mango...',
            hintStyle: pvManrope(fontSize: 15, color: p.ink3),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search_rounded, size: 20, color: p.ink3),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.ink1)),
          ),
        )),
        const SizedBox(height: 16),
        if (results.isEmpty)
          pregToolPad(Text(
              'Not in the list yet. If it is an ordinary home-cooked food with no added salt or sugar, it is '
              'almost certainly fine once solids have started. Ask your paediatrician about anything you are unsure of.',
              style: pvManrope(fontSize: 14, height: 1.6, color: p.ink2))),
        // ⚠️ ROWS, NOT CARDS (Mobbin audit, 2026-10-07): one row per food,
        // the verdict as a dot and a word on the right, the full answer on a
        // tap; after Yuka's additives list
        // (mobbin.com/screens/5e756797-34ea-465d-814c-c139ce62a34f). 289 long
        // cards were a wall; a row is read at a glance. Kept for revert:
        // pregToolPad(_FoodCardV3(food: f, months: _months)) for each.
        if (shown.isNotEmpty)
          pregToolPad(PvRowGroup(p: p, children: [
            for (final f in shown) _foodRow(context, p, f),
          ])),
        const SizedBox(height: 10),
        if (!searching && !_all && results.length > shown.length)
          pregToolPad(PvSecondary(
            label: 'Show all ${results.length} foods',
            onTap: () => setState(() => _all = true),
          )),
      ],
    );
  }

  Widget _foodRow(BuildContext context, V2Palette p, _Food f) {
    final v = f.verdictAt(_months);
    final (verdict, word) = switch (v) {
      _Verdict.yes => (CanIVerdict.safe, 'Yes'),
      _Verdict.notYet => (CanIVerdict.moderation, 'Not yet'),
      _Verdict.avoid => (CanIVerdict.avoid, 'Avoid'),
    };
    return PvListRow(
      key: ValueKey('pp_food_row_${f.name}'),
      p: p,
      leading: PvMarkWell(p: p, hue: 96, size: 40, mark: IntentMark.forkMark),
      title: f.name,
      line: v == _Verdict.notYet ? _FoodCard.fromLabel(f.fromMonths) : ppFillChild(f.why),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: canIVerdictColor(verdict, p), shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(word, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
      ]),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: p.ground,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: _FoodCardV3(food: f, months: _months),
          ),
        ),
      ),
    );
  }

  // Kept for revert (2026-10-07): the page before the shared shell.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final results = _results;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ppV3Back(context, p),
                  const SizedBox(height: 16),
                  Text('Can my baby eat this?',
                      style: pvFraunces(fontSize: 27, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
                  const SizedBox(height: 9),
                  Text(
                      'A straight answer for his age, and a line for you '
                      'while you breastfeed. Type the food in English or in '
                      'Hindi.',
                      style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),
                  const SizedBox(height: 12),
                  // ⚠️ THE AGE RULE. The chips that asked her to "pick that
                  // first" are gone (kept below for revert); the answer is
                  // for his age, stated once, not chosen.
                  Row(children: [
                    Icon(Icons.child_care_outlined, size: 14, color: p.action),
                    const SizedBox(width: 6),
                    Text(
                        'FOR ${ChildProfileStore.instance.nameMid.toUpperCase()}'
                        '  ·  ${_bandLabel(_months).toUpperCase()}',
                        style: pvManrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: p.action)),
                  ]),
                  /* kept for revert: the age chooser
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      for (final b in kPpChildFoodBands) ...[
                        _AgeChip(
                          label: b.$1,
                          selected: _months >= b.$2 && _months < b.$3,
                          onTap: () => setState(() => _months = b.$2),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ]),
                  ),
                  */
                  const SizedBox(height: 14),
                  TextField(
                    controller: _queryCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, height: 1.55, color: p.ink1),
                    decoration: InputDecoration(
                      hintText: 'honey, dal, cow milk, namak...',
                      hintStyle: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, height: 1.55, color: p.ink3),
                      filled: true,
                      fillColor: p.surface,
                      prefixIcon: Icon(Icons.search_rounded,
                          size: 20, color: p.ink3),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: p.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: p.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: p.action),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                if (results.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                        'Not in the list yet. If it is an ordinary home-cooked '
                        'food with no added salt or sugar, it is almost '
                        'certainly fine once he has started solids. Ask your '
                        'paediatrician about anything you are unsure of.',
                        style: pvManrope(fontSize: 14, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),
                  ),
                for (final f in results) ...[
                  _FoodCard(food: f, months: _months),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/// (label, fromMonths, toMonths). Mirrors the Feeding section's own bands.
// REQUIRED_REVIEW: these boundaries should stay in step with kPpFeedingBands.
const List<(String, int, int)> kPpChildFoodBands = [
  ('Under 6 months', 0, 6),
  ('6 to 8 months', 6, 8),
  ('8 to 12 months', 8, 12),
  ('1 to 2 years', 12, 24),
  ('Over 2 years', 24, 999),
];

/// Pregnancy's Can I card for a food: white, one verdict dot.
class _FoodCardV3 extends StatelessWidget {
  const _FoodCardV3({required this.food, required this.months});
  final _Food food;
  final int months;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final v = food.verdictAt(months);
    final (verdict, label) = switch (v) {
      _Verdict.yes => (CanIVerdict.safe, 'Yes, at this age'),
      _Verdict.notYet => (CanIVerdict.moderation, 'Not yet'),
      _Verdict.avoid => (CanIVerdict.avoid, 'Best avoided'),
    };
    final body = pvManrope(fontSize: 13.5, height: 1.6, color: p.ink1);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(food.name, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
        const SizedBox(height: 8),
        Row(children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: canIVerdictColor(verdict, p), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(v == _Verdict.notYet ? '$label. ${_FoodCard.fromLabel(food.fromMonths)}' : label,
                style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, color: p.ink1)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(ppFillChild(food.why), style: body),
        if (food.note != null) ...[
          const SizedBox(height: 8),
          Text(ppFillChild(food.note!), style: pvManrope(fontSize: 13, height: 1.55, color: p.ink2)),
        ],
        const SizedBox(height: 10),
        Container(height: 1, color: p.line),
        const SizedBox(height: 10),
        Text('For you, while breastfeeding', style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w800, color: p.ink2)),
        const SizedBox(height: 4),
        Text(ppFillChild(food.maa ?? kPpMaaFoodDefault), style: pvManrope(fontSize: 13, height: 1.55, color: p.ink1)),
      ]),
    );
  }
}

// Kept for revert (2026-10-07): the tinted card before the shared look.
// ignore: unused_element
class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.food, required this.months});
  final _Food food;
  final int months;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final v = food.verdictAt(months);
    // ⚠️ NOT-YET IS AMBER, NOT RED. See the header: a red badge on everything a
    // baby cannot eat yet turns the first year into a minefield.
    final (bg, edge, label, icon) = switch (v) {
      _Verdict.yes => (
          const Color(0xFFEAF6EE),
          const Color(0xFFBFE0CB),
          'YES, AT THIS AGE',
          Icons.check_circle_outline_rounded
        ),
      _Verdict.notYet => (
          const Color(0xFFFFF6E6),
          const Color(0xFFE8D6AC),
          'NOT YET',
          Icons.schedule_rounded
        ),
      _Verdict.avoid => (
          ppAlertTint(p),
          ppAlertInk(p).withValues(alpha: 0.4),
          'BEST AVOIDED',
          Icons.block_rounded
        ),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: edge),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: p.ink1),
          const SizedBox(width: 9),
          Expanded(
            child: Text(food.name, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(label,
            style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, height: 1.55, color: p.ink2)
                .copyWith(letterSpacing: 0.9)),
        // ⚠️ "NOT YET" ALWAYS SAYS WHEN. Without the date it is just a no, and a
        // no with no end gets asked again next month or ignored entirely.
        if (v == _Verdict.notYet) ...[
          const SizedBox(height: 6),
          Text(_fromLabel(food.fromMonths),
              style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.55, color: p.ink1)),
        ],
        const SizedBox(height: 8),
        Text(ppFillChild(food.why), style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink1)),
        if (food.note != null) ...[
          const SizedBox(height: 9),
          Text(ppFillChild(food.note!), style: pvManrope(fontSize: 13, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
        ],
        // The mother's line. Added 2026-10-02; see `_Food.maa`.
        const SizedBox(height: 11),
        Container(height: 1, color: p.ink1.withValues(alpha: 0.08)),
        const SizedBox(height: 10),
        Text('FOR YOU, MAA, WHILE BREASTFEEDING',
            style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, height: 1.5, color: p.ink3)
                .copyWith(letterSpacing: 0.9)),
        const SizedBox(height: 4),
        Text(ppFillChild(food.maa ?? kPpMaaFoodDefault),
            style: pvManrope(fontSize: 13, fontWeight: FontWeight.w500, height: 1.55, color: p.ink1)),
      ]),
    );
  }

  String _fromLabel(int m) => fromLabel(m);

  static String fromLabel(int m) {
    if (m >= 60) return 'From about 5 years';
    // Whole years from 2 to 4, so a food that waits until 3 or 4 (whole
    // raisins, hard sweets) is not labelled "2 years". Added 2026-10-02.
    if (m >= 24) return 'From about ${m ~/ 12} years';
    if (m == 12) return 'From the first birthday';
    return 'From about $m months';
  }
}

// ignore: unused_element
class _AgeChip extends StatelessWidget {
  const _AgeChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) =>
            _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) => PvPress(child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? p.action : p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? p.action : p.line),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? Colors.white : p.ink2)),
        ),
      ));
}
