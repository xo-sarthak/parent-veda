// =============================================================================
//  Nutrition by age — what a baby actually needs, month by month
// -----------------------------------------------------------------------------
//  The nutrition entry point used to open Recipes, which answered a question a
//  parent of a two-month-old is not asking. Before six months there is nothing
//  to cook: the question is how much milk, how often, and is this normal.
//
//  So this is NUTRITION-led. Recipes appear at the end, once solids are
//  genuinely relevant, as links out — never as the page itself.
//
//  SOURCING NOTE: the volumes and frequencies below are the ranges commonly
//  given by WHO/IAP guidance for healthy term babies. They are deliberately
//  written as RANGES with a "your baby is not an average" caveat, because a
//  parent measuring herself against a single number is the failure mode this
//  page exists to prevent. Nothing here replaces a paediatrician.
// =============================================================================

/// One thing that matters nutritionally at this age, and what to do about it.
class NutrientFocus {
  const NutrientFocus({
    required this.name,
    required this.why,
    required this.howMuch,
    required this.how,
  });

  final String name;

  /// Why it matters AT THIS AGE specifically — not a generic definition.
  final String why;

  /// Quantity guidance, or an honest "no number applies yet".
  final String howMuch;

  /// How a parent actually delivers it.
  final String how;
}

/// How feeding works at this age, per milk route.
class MilkGuidance {
  const MilkGuidance({
    required this.breast,
    required this.formula,
    required this.mixed,
    required this.rhythm,
  });

  final String breast;
  final String formula;
  final String mixed;

  /// The pattern to expect — cluster feeding, night waking, growth spurts.
  final String rhythm;
}

class NutritionStage {
  const NutritionStage({
    required this.minMonths,
    required this.maxMonths,
    required this.headline,
    required this.focus,
    required this.milk,
    required this.nutrients,
    this.solids,
    this.watchFor = const [],
  });

  final int minMonths;
  final int maxMonths;

  /// The one-line answer to "what is nutrition about right now".
  final String headline;
  final String focus;
  final MilkGuidance milk;
  final List<NutrientFocus> nutrients;

  /// Null before solids are relevant — the honest answer for a young baby.
  final String? solids;
  final List<String> watchFor;

  bool covers(int months) => months >= minMonths && months <= maxMonths;
}

const List<NutritionStage> kNutritionStages = [
  // ---- 0-3 months ---------------------------------------------------------
  NutritionStage(
    minMonths: 0,
    maxMonths: 3,
    headline: 'Milk is the whole of it',
    focus:
        'Nothing else is needed — not water, not juice, not cereal. His kidneys and gut are still maturing, and milk is the only thing built for both. The work at this age is establishing supply and learning his cues, not measuring intake.',
    milk: MilkGuidance(
      breast:
          'On demand, roughly 8 to 12 feeds in 24 hours in the early weeks, settling as he gets more efficient. Feed length varies enormously and tells you very little — a fast feeder can take a full feed in seven minutes.',
      formula:
        'Roughly 60 to 120 ml per feed at first, every 2 to 4 hours, working up towards 150 ml per feed by around three months. Follow his cues rather than finishing the bottle: a baby who turns away is done.',
      mixed:
          'There is no fixed ratio that is correct. Many families breastfeed by day and give a formula feed at night, or top up after a breastfeed. Offer the breast first if you are protecting supply.',
      rhythm:
          'Expect cluster feeding — long runs of feed-after-feed, usually in the evening. It looks like not enough milk and is almost always the opposite: he is placing an order for tomorrow. Growth spurts around 3 and 6 weeks do the same thing.',
    ),
    nutrients: [
      NutrientFocus(
        name: 'Vitamin D',
        why:
            'Breast milk is low in vitamin D regardless of how well you eat, and Indian babies are commonly deficient even in sunny cities — most of us are indoors at the hours that matter.',
        howMuch: 'Usually 400 IU daily from birth, on paediatric advice.',
        how: 'Drops, given directly or on a clean fingertip. Formula-fed babies may already get enough — ask.',
      ),
      NutrientFocus(
        name: 'Your own intake, if breastfeeding',
        why:
            'What you eat shapes milk quality less than people claim, but your own stores are what get depleted first — particularly iron, B12 and calcium.',
        howMuch: 'Around 500 extra calories a day, and keep the prenatal going.',
        how: 'Eat regularly rather than perfectly. Keep water within reach of wherever you feed.',
      ),
    ],
    watchFor: [
      'Fewer than six wet nappies a day once your milk is in',
      'No weight gain by two weeks, or weight loss after the first week',
      'Consistently sleepy and hard to rouse for feeds',
    ],
  ),

  // ---- 4-5 months ---------------------------------------------------------
  NutritionStage(
    minMonths: 4,
    maxMonths: 5,
    headline: 'Still milk — and that is not you falling behind',
    focus:
        'There is real pressure around now to start solids, often from people who raised babies on different advice. Waiting until close to six months gives his gut and swallow time to be ready. Milk still supplies essentially all of it.',
    milk: MilkGuidance(
      breast:
          'Typically 5 to 7 feeds a day. Many babies become fast, distractible feeders here — a feed that used to take twenty minutes may take five, and that is efficiency rather than a problem.',
      formula:
          'Around 150 to 200 ml per feed, roughly 5 times a day, up to about 900 ml daily. Volume plateaus around now rather than climbing.',
      mixed:
          'Whatever pattern you have landed on is fine to keep. If you are returning to work, this is a common point to introduce a bottle if you have not already.',
      rhythm:
          'Night waking often returns around four months as sleep matures. It reads as hunger and usually is not — offering more milk by day rarely changes it.',
    ),
    nutrients: [
      NutrientFocus(
        name: 'Vitamin D',
        why: 'Still needed, and still commonly missed once the newborn routine relaxes.',
        howMuch: '400 IU daily, continuing.',
        how: 'Same drops. Tie it to a fixed daily moment so it is not forgotten.',
      ),
      NutrientFocus(
        name: 'Iron stores',
        why:
            'He was born with iron stores that carry him to roughly six months. They are being drawn down now, which is exactly why first foods are iron-first.',
        howMuch: 'Nothing to give yet unless your doctor has advised it.',
        how: 'Worth knowing now so that when solids start you lead with iron rather than fruit.',
      ),
    ],
    watchFor: [
      'Advice to start cereal in a bottle — it is a choking and overfeeding risk, not a sleep aid',
      'Sudden refusal of feeds lasting more than a day',
    ],
  ),

  // ---- 6-8 months ---------------------------------------------------------
  NutritionStage(
    minMonths: 6,
    maxMonths: 8,
    headline: 'Food begins — around the milk, not instead of it',
    focus:
        'Milk is still the main event; food is practice. The point of these months is learning to move food around his mouth and swallow it, and meeting iron. Volume genuinely does not matter yet — a teaspoon eaten with interest beats a bowl pushed in.',
    milk: MilkGuidance(
      breast: 'Still 4 to 6 feeds a day. Offer milk BEFORE food, not after, so food does not displace it.',
      formula: 'Around 700 to 900 ml daily across 4 to 5 feeds, easing down as food goes up.',
      mixed: 'Unchanged. Solids reduce milk gradually over months, not weeks.',
      rhythm:
          'Expect food to make almost no dent in milk intake at first. If milk drops sharply as solids start, slow the solids down.',
    ),
    nutrients: [
      NutrientFocus(
        name: 'Iron',
        why:
            'His birth stores are running out, and iron drives brain development at exactly the age it is running low. This is the single reason first foods matter.',
        howMuch: 'Aim for an iron-containing food at least once a day.',
        how:
            'Ragi, moong dal, well-mashed rajma, egg yolk, finely minced meat. Pair with vitamin C — a little amla, tomato or citrus — which sharply increases absorption.',
      ),
      NutrientFocus(
        name: 'Fat',
        why: 'Brain growth is fat-hungry, and babies need a far higher fat share of calories than adults do.',
        howMuch: 'A little added fat in most meals.',
        how: 'A quarter-teaspoon of ghee stirred into khichdi or dal. Full-fat everything. Never low-fat dairy.',
      ),
      NutrientFocus(
        name: 'Zinc',
        why: 'Works alongside iron for growth and immunity, and comes from broadly the same foods.',
        howMuch: 'No counting needed — it follows a varied diet.',
        how: 'Dals, curd, egg, millets.',
      ),
    ],
    solids:
        'Start with one soft, smooth food a day, at a time when he is alert and not ravenous. Single ingredients for the first few days each, so a reaction is traceable. Textures should progress fairly quickly — lumps by eight months matter more than most parents are told.',
    watchFor: [
      'Honey before one year — never, because of infant botulism risk',
      'Cow milk as a drink before one year (small amounts in cooking are fine)',
      'Salt and sugar — his kidneys cannot handle salt, and sugar sets preferences early',
      'Whole nuts, grapes and hard raw pieces — choking risks',
    ],
  ),

  // ---- 9-11 months --------------------------------------------------------
  NutritionStage(
    minMonths: 9,
    maxMonths: 11,
    headline: 'Three meals, real textures',
    focus:
        'Food is now genuinely feeding him rather than rehearsing. Texture is the thing to push: babies who stay on purées past this window often resist lumps later. Let him feed himself, badly, with his hands.',
    milk: MilkGuidance(
      breast: 'Around 3 to 4 feeds a day, often morning, before naps and at night.',
      formula: 'Roughly 500 to 700 ml daily. Food should now be taking real space.',
      mixed: 'Milk before or between meals rather than with them, so it does not fill him up first.',
      rhythm: 'Milk naturally drops as meals establish. A gentle decline is the goal, not a cliff.',
    ),
    nutrients: [
      NutrientFocus(
        name: 'Iron',
        why: 'Still the priority nutrient, now met entirely through food rather than stores.',
        howMuch: 'An iron food at two of three meals.',
        how: 'Ragi porridge, dal-rice with ghee, egg, minced meat, spinach cooked with a squeeze of lemon.',
      ),
      NutrientFocus(
        name: 'Protein',
        why: 'Muscle and steady growth, and it keeps him full between meals.',
        howMuch: 'A protein element in most meals.',
        how: 'Paneer, curd, dal, egg, chicken or fish if you eat it.',
      ),
      NutrientFocus(
        name: 'Calcium',
        why: 'Bones are hardening quickly, and milk intake is falling at the same time.',
        howMuch: 'Mostly still covered by milk, topped up by food.',
        how: 'Curd, paneer, ragi, til, well-cooked greens.',
      ),
    ],
    solids:
        'Three meals plus a snack or two. Soft finger foods he can hold — steamed carrot sticks, soft roti pieces, banana. Expect most of it on the floor; that is the mechanism, not a failure.',
    watchFor: [
      'Still on smooth purées only — worth pushing texture now',
      'Meals replacing rather than accompanying milk too quickly',
    ],
  ),

  // ---- 12+ months ---------------------------------------------------------
  NutritionStage(
    minMonths: 12,
    maxMonths: 240,
    headline: 'He eats what you eat, mostly',
    focus:
        'Family food, adapted — less salt, less chilli, softer where needed. Appetite becomes wildly inconsistent around now and that is developmentally normal: growth slows sharply after the first year. Judge intake across a week, never a meal.',
    milk: MilkGuidance(
      breast: 'Continue as long as it suits you both. WHO suggests up to two years and beyond.',
      formula: 'No longer needed. Whole cow milk is fine now, around 400 to 500 ml a day.',
      mixed: 'Milk is a food now, not the foundation. Too much displaces iron-rich meals.',
      rhythm: 'Cap milk around 500 ml daily — beyond that it crowds out food and is a common cause of low iron.',
    ),
    nutrients: [
      NutrientFocus(
        name: 'Iron',
        why: 'Toddler iron deficiency is common in India, and excess milk is the usual cause.',
        howMuch: 'Iron food daily; milk capped at about 500 ml.',
        how: 'Ragi, dals, eggs, meat, jaggery in small amounts, always with a vitamin-C food.',
      ),
      NutrientFocus(
        name: 'Variety',
        why: 'Fussiness peaks between one and three. Repeated calm exposure is what widens the diet, not pressure.',
        howMuch: 'Offer a rejected food again another day — often ten or more times.',
        how: 'Serve it alongside something he likes. Never bargain, never force, never make it a scene.',
      ),
    ],
    solids:
        'Three meals and two snacks, from the family pot. Cook the dish once, take his portion out before the salt and chilli.',
    watchFor: [
      'More than about 500 ml milk a day',
      'Juice and packaged snacks becoming routine',
      'Meals turning into negotiations',
    ],
  ),
];

NutritionStage nutritionForAge(int months) {
  for (final s in kNutritionStages) {
    if (s.covers(months)) return s;
  }
  return kNutritionStages.last;
}

/// Recipes only become a sensible answer once solids are real.
bool recipesRelevantAt(int months) => months >= 6;
