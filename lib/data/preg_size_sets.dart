// =============================================================================
//  "About the size of a …" — three Indian comparison sets, weeks 4–40
// -----------------------------------------------------------------------------
//  docs/PREG-HOME-HERO-PLAN.md, Tier 2 §6 (2026-09-21). The week content's
//  own list is the Western BabyCenter one — rutabaga, jicama, spaghetti
//  squash, winter melon — words an Indian mother has never bought. Three sets
//  she has:
//
//    · fruit & veg — from the sabzi mandi: jamun, ber, amla, chikoo, mosambi,
//      guava, sitaphal, bael, lauki, petha, kathal, sahjan …
//    · kitchen — the objects of an Indian kitchen: a katori, a cutting-chai
//      glass, a masala dabba, a tawa, a belan, a thali, a paraat, a handi,
//      a matka …
//    · sweets — the mithai box: boondi, peda, gulab jamun, rasgulla, jalebi,
//      laddoo, ghevar, kaju katli, barfi, shrikhand …
//
//  ⚠️ TWO WAYS OF COMPARING, AND EACH ITEM SAYS WHICH. Fruit, veg and kitchen
//  things compare by LENGTH ("about the size of a guava"). Sweets compare by
//  length only while the baby is small enough to be one (a peda, a jalebi);
//  from week 14 they compare by WEIGHT ("about as heavy as a boondi laddoo"),
//  because no sweet is 40 cm long but a 1 kg box of laddoos is a thing
//  everyone has carried home. `PregSizeBy` carries the frame and the line
//  reads differently for each — a caption that said "size of" over a weight
//  would be the kind of small lie that makes a mother stop trusting the line.
//
//  ⚠️ LENGTH CHANGES MEANING AT WEEK 20. Weeks 4–19 measure crown to rump;
//  from 20 crown to heel, which is why the number jumps from 15 to 26 cm
//  between weeks 19 and 20. The comparisons follow the number as given.
//
//  ⚠️ AVERAGES. Every entry is "about"; the sheet says so and points at her
//  scan. Nothing here is about her baby in particular.
//
//  The Western list stays in weekContent.json as the fallback per entry
//  (`pregSizeFor` returns null for a week a set does not cover, and the
//  caller falls back to `snapshot.fruit`). Comparison pictures are owed — see
//  the plan, §8 — and land as `imageKey` lookups later, keyed by `name`.
// =============================================================================

/// Whether the fruit · kitchen · sweets toggle is offered. Off until each
/// entry has its picture (2026-09-22, the user: a toggle whose images do not
/// change is no toggle). The store answers `fruit` while it is off.
const bool kPregSizeToggle = false;

/// Which set she is looking at. Persisted by `PregSizeSetStore`.
enum PregSizeSet {
  fruit,
  kitchen,
  sweets;

  String get label => switch (this) {
        PregSizeSet.fruit => 'Fruit & veg',
        PregSizeSet.kitchen => 'Kitchen',
        PregSizeSet.sweets => 'Sweets',
      };
}

/// The dimension an item compares on.
enum PregSizeBy { length, weight }

/// One comparison: "a guava", by length.
class PregSizeItem {
  const PregSizeItem(this.name, {this.by = PregSizeBy.length});

  /// With its article — "a guava", "an amla", "a 1 kg box of laddoos".
  final String name;
  final PregSizeBy by;

  /// "About the size of a guava" / "About as heavy as a boondi laddoo".
  String get line => switch (by) {
        PregSizeBy.length => 'About the size of $name',
        PregSizeBy.weight => 'About as heavy as $name',
      };

  /// The eyebrow on the insight card.
  String get eyebrow => switch (by) {
        PregSizeBy.length => 'About the size of',
        PregSizeBy.weight => 'About as heavy as',
      };
}

const _w = PregSizeBy.weight;

/// Week → (fruit & veg, kitchen, sweets).
const Map<int, ({PregSizeItem fruit, PregSizeItem kitchen, PregSizeItem sweets})>
    kPregSizes = {
  //  week: length · weight — the number the comparison was written against
  4: (fruit: PregSizeItem('a poppy seed (khus khus)'), kitchen: PregSizeItem('a grain of salt'), sweets: PregSizeItem('a grain of sugar')), // 1 mm
  5: (fruit: PregSizeItem('a sesame seed (til)'), kitchen: PregSizeItem('a mustard seed (rai)'), sweets: PregSizeItem('a mishri crystal')), // 2 mm
  6: (fruit: PregSizeItem('a pomegranate seed'), kitchen: PregSizeItem('a masoor dal grain'), sweets: PregSizeItem('a single boondi')), // 5 mm
  7: (fruit: PregSizeItem('a small grape'), kitchen: PregSizeItem('a chana'), sweets: PregSizeItem('a chocolate chip')), // 1 cm
  8: (fruit: PregSizeItem('a jamun'), kitchen: PregSizeItem('a rajma bean'), sweets: PregSizeItem('a sugar cube')), // 1.6 cm · 1 g
  9: (fruit: PregSizeItem('a ber'), kitchen: PregSizeItem('a garlic clove'), sweets: PregSizeItem('a toffee')), // 2.3 cm · 2 g
  10: (fruit: PregSizeItem('an amla'), kitchen: PregSizeItem('a bottle cap'), sweets: PregSizeItem('a peda')), // 3.1 cm · 4 g
  11: (fruit: PregSizeItem('a lychee'), kitchen: PregSizeItem('a walnut'), sweets: PregSizeItem('a gulab jamun')), // 4.1 cm · 7 g
  12: (fruit: PregSizeItem('a chikoo'), kitchen: PregSizeItem('a lime'), sweets: PregSizeItem('a rasgulla')), // 5.4 cm · 14 g
  13: (fruit: PregSizeItem('a mosambi'), kitchen: PregSizeItem('a small katori'), sweets: PregSizeItem('a jalebi')), // 7.4 cm · 23 g
  14: (fruit: PregSizeItem('a guava'), kitchen: PregSizeItem('a cutting-chai glass'), sweets: PregSizeItem('a boondi laddoo', by: _w)), // 8.7 cm · 43 g
  15: (fruit: PregSizeItem('an orange'), kitchen: PregSizeItem('a katori'), sweets: PregSizeItem('a kulfi', by: _w)), // 10.1 cm · 70 g
  16: (fruit: PregSizeItem('a sitaphal'), kitchen: PregSizeItem('a steel glass'), sweets: PregSizeItem('a 100 g bar of chocolate', by: _w)), // 11.6 cm · 100 g
  17: (fruit: PregSizeItem('a nashpati'), kitchen: PregSizeItem('a tea cup'), sweets: PregSizeItem('a bowl of kheer', by: _w)), // 13 cm · 140 g
  18: (fruit: PregSizeItem('a bael fruit'), kitchen: PregSizeItem('a small tiffin box'), sweets: PregSizeItem('a ghevar', by: _w)), // 14.2 cm · 190 g
  19: (fruit: PregSizeItem('a mango'), kitchen: PregSizeItem('a masala dabba'), sweets: PregSizeItem('a 250 g box of kaju katli', by: _w)), // 15.3 cm · 240 g
  // From here length is crown to heel.
  20: (fruit: PregSizeItem('a banana'), kitchen: PregSizeItem('a tawa'), sweets: PregSizeItem('a bowl of gajar halwa', by: _w)), // 25.7 cm · 331 g
  21: (fruit: PregSizeItem('a long kheera'), kitchen: PregSizeItem('a steel dinner plate'), sweets: PregSizeItem('eight rasgullas', by: _w)), // 26.7 cm · 398 g
  22: (fruit: PregSizeItem('a coconut with its husk'), kitchen: PregSizeItem('a belan'), sweets: PregSizeItem('a 500 g box of barfi', by: _w)), // 27.8 cm · 475 g
  23: (fruit: PregSizeItem('a pineapple with its crown'), kitchen: PregSizeItem('a chopping board'), sweets: PregSizeItem('ten gulab jamuns', by: _w)), // 28.9 cm · 550 g
  24: (fruit: PregSizeItem('a bhutta with its husk'), kitchen: PregSizeItem('a kadhai'), sweets: PregSizeItem('a tub of shrikhand', by: _w)), // 30 cm · 635 g
  25: (fruit: PregSizeItem('a lauki'), kitchen: PregSizeItem('a thali'), sweets: PregSizeItem('a 750 g box of mixed mithai', by: _w)), // 34.6 cm · 760 g
  26: (fruit: PregSizeItem('a cauliflower with its leaves'), kitchen: PregSizeItem('a 2-litre water bottle'), sweets: PregSizeItem('a jar of twenty pedas', by: _w)), // 35.6 cm · 900 g
  27: (fruit: PregSizeItem('a papaya'), kitchen: PregSizeItem('a 3-litre pressure cooker'), sweets: PregSizeItem('a 1 kg box of laddoos', by: _w)), // 36.6 cm · 1 kg
  28: (fruit: PregSizeItem('a small petha (ash gourd)'), kitchen: PregSizeItem('a large kadhai with its handles'), sweets: PregSizeItem('two dozen motichoor laddoos', by: _w)), // 37.6 cm · 1.2 kg
  29: (fruit: PregSizeItem('a small kaddu'), kitchen: PregSizeItem('a paraat'), sweets: PregSizeItem('a wedding ghevar', by: _w)), // 38.6 cm · 1.37 kg
  30: (fruit: PregSizeItem('a small kathal'), kitchen: PregSizeItem('a handi'), sweets: PregSizeItem('a 1.5 kg birthday cake', by: _w)), // 39.9 cm · 1.52 kg
  31: (fruit: PregSizeItem('a drumstick (sahjan) pod'), kitchen: PregSizeItem('a dosa tawa'), sweets: PregSizeItem('a tin of thirty-five rasgullas', by: _w)), // 41.1 cm · 1.71 kg
  32: (fruit: PregSizeItem('a long turai'), kitchen: PregSizeItem('a 5-litre pressure cooker'), sweets: PregSizeItem('a 2 kg box of kaju katli', by: _w)), // 42.4 cm · 1.9 kg
  33: (fruit: PregSizeItem('a large papaya'), kitchen: PregSizeItem('a big steel serving tray'), sweets: PregSizeItem('a 2 kg bag of sugar', by: _w)), // 43.7 cm · 2.1 kg
  34: (fruit: PregSizeItem('a small watermelon'), kitchen: PregSizeItem('a mixer grinder'), sweets: PregSizeItem('a Diwali mithai thali', by: _w)), // 45 cm · 2.3 kg
  35: (fruit: PregSizeItem('a length of sugarcane'), kitchen: PregSizeItem('a 5 kg bag of atta'), sweets: PregSizeItem('a dabba of fifty laddoos', by: _w)), // 46.2 cm · 2.5 kg
  36: (fruit: PregSizeItem('a snake gourd (chichinda)'), kitchen: PregSizeItem('a rice dabba'), sweets: PregSizeItem('a big tin of gulab jamuns', by: _w)), // 47.4 cm · 2.7 kg
  37: (fruit: PregSizeItem('a kathal'), kitchen: PregSizeItem('a microwave'), sweets: PregSizeItem('a 3 kg box of motichoor laddoos', by: _w)), // 48.6 cm · 2.9 kg
  38: (fruit: PregSizeItem('a big watermelon'), kitchen: PregSizeItem('a biryani degchi'), sweets: PregSizeItem('three 1 kg boxes of mithai', by: _w)), // 49.8 cm · 3.1 kg
  39: (fruit: PregSizeItem('a big kaddu'), kitchen: PregSizeItem('a two-burner gas stove'), sweets: PregSizeItem('a wedding cake', by: _w)), // 50.7 cm · 3.3 kg
  40: (fruit: PregSizeItem('a big kathal'), kitchen: PregSizeItem('a matka'), sweets: PregSizeItem('a Diwali hamper', by: _w)), // 51.2 cm · 3.5 kg
};

/// The comparison for [week] in [set], or null when the set does not cover
/// the week (the caller falls back to the week content's own fruit).
PregSizeItem? pregSizeFor(int week, PregSizeSet set) {
  final row = kPregSizes[week];
  if (row == null) return null;
  return switch (set) {
    PregSizeSet.fruit => row.fruit,
    PregSizeSet.kitchen => row.kitchen,
    PregSizeSet.sweets => row.sweets,
  };
}

/// The comparison for [week] in [set], falling back to the week content's own
/// fruit (`snapshot.fruit.en`, the Western list) when the set has no entry.
/// Null only when neither has anything.
PregSizeItem? pregSizeOrFallback(int week, PregSizeSet set, String fallbackFruit) {
  final own = pregSizeFor(week, set);
  if (own != null) return own;
  final f = fallbackFruit.trim();
  if (f.isEmpty) return null;
  return PregSizeItem(pregArticle(f));
}

/// "a peach", "an orange" — for a line that reads as one sentence. Leaves a
/// name that already carries its article alone.
String pregArticle(String noun) {
  final n = noun.trim();
  if (n.isEmpty) return n;
  final lower = n.toLowerCase();
  if (lower.startsWith('a ') ||
      lower.startsWith('an ') ||
      lower.startsWith('the ')) {
    return n;
  }
  return '${'aeiou'.contains(lower[0]) ? 'an' : 'a'} $n';
}
