// =============================================================================
//  Ready-to-Try plan — "in your kitchen", one short block per region
// -----------------------------------------------------------------------------
//  ⚠️ A LAYER ON THE WEEK, NOT A SECOND MEAL PLAN (decided 2026-10-17). The
//  week of meals is the nutritionist's read (`ttc_read_meal_plan_week`), held
//  word for word by `ttc_meal_week_data.dart` and its contract test. Writing
//  twenty-eight regional weeks would be weeks of copy and a dietitian review
//  before anything shipped. So the plan shows her week for her diet, and this
//  file adds what changes by region: the foods she already cooks that carry
//  iron, folate, B12 and protein, and a handful of small swaps.
//
//  ⚠️ NO CLAIM HERE IS A NUMBER, A DOSE OR A CURE. Each food names what it
//  carries (iron, folate, protein), the way the week's own plate tags do, and
//  nothing more. Owed a dietitian's read before launch: listed in
//  `docs/DOOR-CONTENT-OWED.md`.
//
//  ⚠️ JAIN AND VEG PLATES FILTER, THEY DO NOT GET A SEPARATE LIST. A food
//  carries its own flags (fish or meat, egg, a root vegetable), and the plan drops
//  what does not belong on her plate. One list per region is one place to
//  correct a food.
//
//  English only (CLAUDE.md, "New work is English").
// =============================================================================

/// Her home kitchen.
///
/// ⚠️ THE NAME IS PERSISTED (`TtcReadyPlanStore`).
enum ReadyRegion {
  northIndian,
  punjabi,
  gujarati,
  maharashtrian,
  bengali,
  southIndian,
  mixed,
}

extension ReadyRegionCopy on ReadyRegion {
  String get label => switch (this) {
    ReadyRegion.northIndian => 'North Indian',
    ReadyRegion.punjabi => 'Punjabi',
    ReadyRegion.gujarati => 'Gujarati',
    ReadyRegion.maharashtrian => 'Maharashtrian',
    ReadyRegion.bengali => 'Bengali',
    ReadyRegion.southIndian => 'South Indian',
    ReadyRegion.mixed => 'A bit of everything',
  };
}

/// One food from her own kitchen, and what it carries.
class ReadyFood {
  const ReadyFood(
    this.name,
    this.gives, {
    this.meat = false,
    this.egg = false,
    this.root = false,
  });

  final String name;

  /// "iron and folate". The plate words, never a number.
  final String gives;

  /// Fish or meat: off a vegetarian plate.
  final bool meat;

  /// Off an eggless plate.
  final bool egg;

  /// Off a Jain plate (onion, garlic, potato and the other root vegetables).
  final bool root;
}

class ReadyKitchen {
  const ReadyKitchen({
    required this.line,
    required this.foods,
    required this.swaps,
  });

  /// One sentence: what this kitchen already does well.
  final String line;
  final List<ReadyFood> foods;

  /// Small changes inside dishes she already makes.
  final List<String> swaps;
}

const Map<ReadyRegion, ReadyKitchen> kReadyKitchens = {
  ReadyRegion.northIndian: ReadyKitchen(
    line:
        'Dal, sabzi, roti and curd already make a good plate. A little '
        'more protein and some greens do the rest.',
    foods: [
      ReadyFood('Rajma and chole', 'protein, iron and folate'),
      ReadyFood('Palak and methi', 'folate and iron'),
      ReadyFood('Curd, paneer and lassi', 'protein, calcium and B12'),
      ReadyFood('Amla and guava', 'vitamin C, which helps iron in'),
      ReadyFood('Eggs', 'protein and B12', egg: true),
    ],
    swaps: [
      'Make one roti a day with a mixed flour, wheat with besan or bajra.',
      'Squeeze lemon over your dal. The vitamin C helps the iron in.',
      'Keep a bowl of curd at lunch.',
      'Try sprouts chaat as the evening snack.',
    ],
  ),
  ReadyRegion.punjabi: ReadyKitchen(
    line:
        'Saag, dals and dairy are already on the table. Keep them, and '
        'lean on the greens.',
    foods: [
      ReadyFood('Sarson ka saag', 'folate and iron'),
      ReadyFood('Rajma, chole and maah di dal', 'protein, iron and folate'),
      ReadyFood('Paneer, curd and lassi', 'protein, calcium and B12'),
      ReadyFood('Missi roti (with besan)', 'protein and iron'),
      ReadyFood('Eggs', 'protein and B12', egg: true),
    ],
    swaps: [
      'Have missi roti in place of a plain paratha on some days.',
      'Try paneer or egg bhurji for breakfast.',
      'Add a handful of spinach to dal or sabzi.',
      'Keep butter for taste, not for every roti.',
    ],
  ),
  ReadyRegion.gujarati: ReadyKitchen(
    line:
        'Besan, moong and buttermilk are already everyday. They are good '
        'sources of protein, so build on them.',
    foods: [
      ReadyFood('Methi thepla', 'folate and iron'),
      ReadyFood('Khaman, dhokla and besan chilla', 'protein'),
      ReadyFood('Kadhi and chaas', 'calcium and B12'),
      ReadyFood('Sprouted moong', 'protein, iron and folate'),
      ReadyFood('Bajra rotla', 'iron'),
    ],
    swaps: [
      'Make methi thepla your breakfast a few days a week.',
      'Add sprouted moong usal or salad to lunch.',
      'Keep a glass of chaas with one meal a day.',
      'Put vegetables into your khichdi.',
    ],
  ),
  ReadyRegion.maharashtrian: ReadyKitchen(
    line:
        'Bhakri, usal and amti already cover a lot. Millets and sprouts '
        'are worth leaning on.',
    foods: [
      ReadyFood('Nachni, jowar and bajra bhakri', 'iron and calcium'),
      ReadyFood('Usal and misal sprouts', 'protein, iron and folate'),
      ReadyFood('Pithla (with besan)', 'protein'),
      ReadyFood('Curd and taak', 'calcium and B12'),
      ReadyFood('Poha with peanuts', 'iron and protein'),
    ],
    swaps: [
      'Have nachni bhakri in place of a wheat roti on some days.',
      'Add lemon to your poha.',
      'Keep sprouted usal on the menu twice a week.',
      'Add leafy greens like methi or chawli to your bhaji.',
    ],
  ),
  ReadyRegion.bengali: ReadyKitchen(
    line:
        'Shaak, dal, and fish or chhana make a strong plate. A bowl of greens a day '
        'is the easy win.',
    foods: [
      ReadyFood('Lal shaak and palong shaak', 'folate and iron'),
      ReadyFood('Masoor and moong dal', 'protein and folate'),
      ReadyFood(
        'Rohu, katla and other river fish',
        'protein and B12',
        meat: true,
      ),
      ReadyFood('Chhana and doi', 'protein, calcium and B12'),
      ReadyFood('Mochar ghonto (banana flower)', 'iron'),
    ],
    swaps: [
      'Have one bowl of shaak every day.',
      'Make dal twice a day if you eat vegetarian.',
      'If you eat fish, rohu, katla and pomfret are good choices. Skip large fish like shark.',
      'Add chhana to breakfast.',
    ],
  ),
  ReadyRegion.southIndian: ReadyKitchen(
    line:
        'Sambar, ragi and curd rice already carry a lot. More dal in the '
        'sambar and some ragi go a long way.',
    foods: [
      ReadyFood('Ragi dosa, ragi mudde and kanji', 'iron and calcium'),
      ReadyFood('Drumstick leaves (murungai keerai)', 'iron and folate'),
      ReadyFood('Sambar and sundal', 'protein and folate'),
      ReadyFood('Curd and curd rice', 'calcium and B12'),
      ReadyFood('Fish curry', 'protein and B12', meat: true),
    ],
    swaps: [
      'Have ragi dosa or kanji on some days.',
      'Put more dal into the sambar.',
      'Make drumstick-leaf poriyal once a week.',
      'Try sundal as the evening snack.',
    ],
  ),
  ReadyRegion.mixed: ReadyKitchen(
    line:
        'Whatever you cook, the same three things on the plate do the '
        'work: a protein, a whole grain and a vegetable.',
    foods: [
      ReadyFood('Dal, chana and rajma', 'protein, iron and folate'),
      ReadyFood('Spinach, methi and other greens', 'folate and iron'),
      ReadyFood('Curd, paneer and milk', 'protein, calcium and B12'),
      ReadyFood('Ragi, bajra and jowar', 'iron'),
      ReadyFood('Lemon, amla and guava', 'vitamin C, which helps iron in'),
    ],
    swaps: [
      'Add a protein to breakfast.',
      'Put greens into one dish a day.',
      'Swap one refined grain for a millet a few times a week.',
      'Squeeze lemon over dal or sabzi.',
    ],
  ),
};

/// The foods for her plate: fish and meat off a vegetarian plate, eggs off an eggless
/// one, and root vegetables off a Jain one.
List<ReadyFood> readyFoodsFor(
  ReadyRegion r, {
  required bool vegetarian,
  required bool eggless,
  required bool jain,
}) => [
  for (final f in kReadyKitchens[r]!.foods)
    if (!(f.meat && vegetarian) && !(f.egg && eggless) && !(f.root && jain)) f,
];
