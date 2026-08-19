// =============================================================================
//  Diet charts — five independent axes, not five shelves
// -----------------------------------------------------------------------------
//  ⚠️ THE BUG THIS FIXES IS IN THE OLD MODEL, NOT IN THE OLD SCREEN.
//
//  `DietChartCategory { stage, diet, condition, regional, language }` made a
//  chart exactly ONE of those things. So the library read:
//
//      By stage      · First trimester · Second · Third · Month-by-month
//      By diet       · Vegetarian · Non-vegetarian
//      By condition  · Gestational diabetes · Healthy weight gain
//      Regional      · Bengali · Tamil · Punjabi · Gujarati · South Indian · Jain
//      In Hindi      · Hindi chart
//
//  Every one of those is really a DIFFERENT QUESTION about the same chart, and
//  a mother has all of them at once. She is vegetarian AND in her third
//  trimester AND Gujarati AND would like it in Hindi — and the old shape made
//  her pick one and abandon the rest. "In Hindi" as a shelf is the clearest
//  tell: a language is not a kind of diet chart, it is a property every chart
//  should be able to have.
//
//  Review put it exactly: "Veg / Non Veg, Egg, Regional selection should all be
//  filters put in a manner that they don't all mix with each other."
//
//  ---------------------------------------------------------------------------
//  ⚠️ NULL MEANS "WORKS FOR ANY", NOT "MISSING"
//  ---------------------------------------------------------------------------
//  This is the load-bearing decision, and getting it backwards breaks the
//  feature quietly. With fourteen charts across five axes, filtering on strict
//  equality would return nothing almost immediately — pick third trimester AND
//  Gujarati and there is no chart tagged as both, so she would see an empty
//  screen and conclude the app has nothing for her.
//
//  So a null facet is a positive claim: *this chart does not vary on that
//  axis*. The Gujarati chart has no stage because it is good for any stage; the
//  third-trimester chart has no region because it is not about region. A filter
//  therefore EXCLUDES only a chart that declares a DIFFERENT value on that
//  axis, never one that declares none.
//
//  The cost is honest and worth stating: "Third trimester + Gujarati" returns
//  two charts that each answer half the question rather than one that answers
//  all of it. That is a content gap, not a model failure, and the screen says
//  so rather than pretending the pair is a match.
// =============================================================================

import '../localization/app_language.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// Which part of the journey a chart is written for.
enum ChartStage { trimester1, trimester2, trimester3, postpartum }

/// ⚠️ EGG IS ITS OWN VALUE, NOT A SHADE OF VEGETARIAN. Review asked for it by
/// name, and in India it is a real and separate answer — a large number of
/// households eat egg and no meat, and telling them to use the non-vegetarian
/// chart means handing them a week built around chicken and fish.
enum ChartDiet { vegetarian, eggetarian, nonVegetarian, jain }

/// A condition the chart is built around. Deliberately small: a chart earns a
/// condition tag only when the whole week is genuinely different, not when one
/// meal changes.
enum ChartCondition { gestationalDiabetes, weightGain, anaemia }

enum ChartRegion { bengali, tamil, punjabi, gujarati, southIndian, northIndian }

extension ChartStageMeta on ChartStage {
  LocalizedText get label => switch (this) {
        ChartStage.trimester1 => _en('First trimester'),
        ChartStage.trimester2 => _en('Second trimester'),
        ChartStage.trimester3 => _en('Third trimester'),
        ChartStage.postpartum => _en('After birth'),
      };

  /// The week this stage starts at, for matching her own week to a chart.
  ///
  /// ⚠️ POSTPARTUM IS DELIBERATELY UNREACHABLE FROM A WEEK NUMBER. A pregnancy
  /// week never implies "after birth" — that is a stage change the app records
  /// elsewhere — so `stageForWeek` below can never select it. Inferring it from
  /// week 40 would mean a mother at 40 weeks, still pregnant, being shown a
  /// postpartum chart.
  int get fromWeek => switch (this) {
        ChartStage.trimester1 => 1,
        ChartStage.trimester2 => 14,
        ChartStage.trimester3 => 28,
        ChartStage.postpartum => 999,
      };
}

extension ChartDietMeta on ChartDiet {
  LocalizedText get label => switch (this) {
        ChartDiet.vegetarian => _en('Vegetarian'),
        ChartDiet.eggetarian => _en('Egg'),
        ChartDiet.nonVegetarian => _en('Non-vegetarian'),
        ChartDiet.jain => _en('Jain'),
      };
}

extension ChartConditionMeta on ChartCondition {
  LocalizedText get label => switch (this) {
        ChartCondition.gestationalDiabetes => _en('Gestational diabetes'),
        ChartCondition.weightGain => _en('Healthy weight gain'),
        ChartCondition.anaemia => _en('Low iron'),
      };
}

extension ChartRegionMeta on ChartRegion {
  LocalizedText get label => switch (this) {
        ChartRegion.bengali => _en('Bengali'),
        ChartRegion.tamil => _en('Tamil'),
        ChartRegion.punjabi => _en('Punjabi'),
        ChartRegion.gujarati => _en('Gujarati'),
        ChartRegion.southIndian => _en('South Indian'),
        ChartRegion.northIndian => _en('North Indian'),
      };
}

/// Her trimester from a pregnancy week, clamped into 1–3.
ChartStage? stageForWeek(int week) {
  if (week <= 0) return null;
  if (week < 14) return ChartStage.trimester1;
  if (week < 28) return ChartStage.trimester2;
  return ChartStage.trimester3;
}

/// What a chart claims on each axis. Any field may be null — see the header.
class ChartFacets {
  const ChartFacets({
    this.stage,
    this.diet,
    this.condition,
    this.region,
    this.inHindi = false,
  });

  final ChartStage? stage;
  final ChartDiet? diet;
  final ChartCondition? condition;
  final ChartRegion? region;

  /// ⚠️ A BOOLEAN, NOT AN AXIS VALUE. "In Hindi" was a shelf, which forced a
  /// chart to be *either* Hindi *or* about a trimester. It is a property: this
  /// chart is also available in Hindi. Once the whole library is translated
  /// this field disappears rather than needing rethinking.
  final bool inHindi;

  /// Does this chart survive [f]?
  ///
  /// ⚠️ A NULL FACET NEVER EXCLUDES. Read the header before changing this line
  /// — strict equality here empties the screen for most real filter
  /// combinations, and it does it silently.
  bool satisfies(ChartFilter f) {
    if (f.stage != null && stage != null && stage != f.stage) return false;
    if (f.diet != null && diet != null && diet != f.diet) return false;
    if (f.condition != null && condition != null && condition != f.condition) {
      return false;
    }
    if (f.region != null && region != null && region != f.region) return false;
    if (f.inHindi && !inHindi) return false;
    return true;
  }

  /// How specifically this chart answers [f] — used to rank, never to hide.
  ///
  /// A chart that names her exact trimester is a better answer than one that
  /// works for any, even though both survive the filter. Without this the list
  /// would be in file order and the general charts would sit above the ones
  /// written for her.
  int specificity(ChartFilter f) {
    var n = 0;
    if (f.stage != null && stage == f.stage) n++;
    if (f.diet != null && diet == f.diet) n++;
    if (f.condition != null && condition == f.condition) n++;
    if (f.region != null && region == f.region) n++;
    return n;
  }
}

/// One selection across the five axes. Every field null / false = show all.
class ChartFilter {
  const ChartFilter({
    this.stage,
    this.diet,
    this.condition,
    this.region,
    this.inHindi = false,
  });

  final ChartStage? stage;
  final ChartDiet? diet;
  final ChartCondition? condition;
  final ChartRegion? region;
  final bool inHindi;

  bool get isEmpty =>
      stage == null &&
      diet == null &&
      condition == null &&
      region == null &&
      !inHindi;

  int get activeCount =>
      (stage != null ? 1 : 0) +
      (diet != null ? 1 : 0) +
      (condition != null ? 1 : 0) +
      (region != null ? 1 : 0) +
      (inHindi ? 1 : 0);

  /// ⚠️ EACH AXIS IS SINGLE-SELECT AND RE-TAPPING CLEARS IT.
  ///
  /// Single-select because two trimesters at once is not a question anyone
  /// has, and multi-select on five axes produces combinations with no charts
  /// behind them. Re-tapping clearing it is the way out — a chip you can turn
  /// on and not off is how someone gets stuck in a filtered state and decides
  /// the app is broken. Same rule the report decoder's "All" chip follows.
  ChartFilter withStage(ChartStage? s) => ChartFilter(
      stage: stage == s ? null : s,
      diet: diet,
      condition: condition,
      region: region,
      inHindi: inHindi);

  ChartFilter withDiet(ChartDiet? d) => ChartFilter(
      stage: stage,
      diet: diet == d ? null : d,
      condition: condition,
      region: region,
      inHindi: inHindi);

  ChartFilter withCondition(ChartCondition? c) => ChartFilter(
      stage: stage,
      diet: diet,
      condition: condition == c ? null : c,
      region: region,
      inHindi: inHindi);

  ChartFilter withRegion(ChartRegion? r) => ChartFilter(
      stage: stage,
      diet: diet,
      condition: condition,
      region: region == r ? null : r,
      inHindi: inHindi);

  ChartFilter withHindi(bool v) => ChartFilter(
      stage: stage,
      diet: diet,
      condition: condition,
      region: region,
      inHindi: v);
}

/// ⚠️ THE FACETS LIVE HERE, KEYED BY CHART ID, RATHER THAN ON `DietChart`.
///
/// `DietChart` and `kDietCharts` sit in `nutrition_data.dart` alongside six
/// other sections, and adding four fields to that class would touch every one
/// of its fourteen literals. A side table keeps the change to one file, and it
/// makes the gap visible: a chart with no entry here is untagged, which
/// `test/diet_chart_facets_test.dart` fails on rather than letting it quietly
/// match every filter.
const Map<String, ChartFacets> kChartFacets = {
  'full_month_indian': ChartFacets(inHindi: true),
  't1_chart': ChartFacets(stage: ChartStage.trimester1, inHindi: true),
  't2_chart': ChartFacets(stage: ChartStage.trimester2, inHindi: true),
  't3_chart': ChartFacets(stage: ChartStage.trimester3, inHindi: true),
  // ⚠️ THE HINDI CHART KEEPS ITS OWN ROW FOR NOW. It is the one chart whose
  // entire point is the language, and until every chart is genuinely
  // translated, deleting it would remove the only Hindi document that exists.
  // Once the library is translated this entry and `inHindi` both go.
  'hindi_chart': ChartFacets(inHindi: true),
  'vegetarian_chart': ChartFacets(diet: ChartDiet.vegetarian, inHindi: true),
  'non_vegetarian_chart': ChartFacets(diet: ChartDiet.nonVegetarian),
  'gestational_diabetes_chart':
      ChartFacets(condition: ChartCondition.gestationalDiabetes, inHindi: true),
  'weight_gain_chart': ChartFacets(condition: ChartCondition.weightGain),
  'regional_bengali': ChartFacets(region: ChartRegion.bengali),
  'regional_tamil': ChartFacets(region: ChartRegion.tamil),
  'regional_punjabi': ChartFacets(region: ChartRegion.punjabi),
  'regional_gujarati': ChartFacets(region: ChartRegion.gujarati),
  'regional_south_indian': ChartFacets(region: ChartRegion.southIndian),
  // ⚠️ JAIN IS A DIET, NOT A REGION — and it was filed under "Regional"
  // because the old model had nowhere else to put it. A Jain kitchen is
  // defined by what it excludes (onion, garlic, root vegetables), which is
  // exactly what the diet axis is for, and it spans several regions.
  'regional_jain': ChartFacets(diet: ChartDiet.jain),
};

ChartFacets facetsFor(String chartId) =>
    kChartFacets[chartId] ?? const ChartFacets();
