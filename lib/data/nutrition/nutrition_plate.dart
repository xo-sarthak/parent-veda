// =============================================================================
//  Nutrition — today's plate, and what the baby needs
// -----------------------------------------------------------------------------
//  2026-09-20, the Nutrition door rebuild. The door used to be a catalogue:
//  nineteen charts, seventeen recipes, twelve nutrient guides, all opening
//  into reads. Every one of those stays; this file turns them into a DAY.
//
//  THE PLATE. A diet chart already holds three genuinely different worked
//  days (diet_chart_content.dart — meals, swaps, limits). Nobody reads a
//  chart; people open *today* (Mobbin: Crouton, Recime, Cherrypick — a meal
//  plan is a day with swappable slots). So: pick the chart that fits her
//  (trimester × diet × region × a condition she manages), pick today's day
//  from its three, and lay the meals out as slots she can swap.
//
//  WHICH CHART. The five-axis facets (`diet_chart_facets.dart`) score every
//  chart against her; the best match wins, the month-by-month chart is the
//  floor. A condition she has added in Complications outranks region —
//  gestational diabetes changes the whole day, Gujarati changes the dishes.
//
//  WHICH DAY. Deterministic from the date, so the plate she saw at breakfast
//  is the plate she sees at dinner, and tomorrow is genuinely different —
//  `dayOfYear % days.length`, offset by the chart so two charts do not march
//  in step.
//
//  THE NEEDS. Not calories, not grams, not a target she can fail: five
//  things a pregnancy actually needs, as a daily tick each — "did you get
//  iron today?" — and, behind each tick, the everyday foods that give it
//  (`NutrientGuide.foods`) and the recipes tagged for it. Alma's "contributing
//  foods" page, turned round: we do not measure what she ate, we show what
//  would count. The clinical rule ("population guidance, never a personal
//  target") and the calm rule ("nothing here shames") agree on this shape.
//
//  Nothing here is persisted; the store (`nutrition_day_store.dart`) keeps
//  what she did with it.
// =============================================================================

import '../../localization/app_language.dart';
import '../../services/family_profile.dart' show DietPreference;
import '../diet_chart_content.dart';
import '../diet_chart_facets.dart';
import '../nutrition_data.dart';

/// One slot on the plate.
class PlateMeal {
  const PlateMeal({
    required this.slot,
    required this.items,
    required this.chartId,
    required this.dayIndex,
    required this.slotIndex,
  });

  /// "Breakfast", "Mid-morning", "Lunch", "Evening", "Dinner" — the chart's own.
  final String slot;

  /// The dishes, in the chart's words.
  final String items;
  final String chartId;
  final int dayIndex;
  final int slotIndex;

  /// A stable key for the store: which slot on which day of which chart.
  String get key => '$chartId/$dayIndex/$slotIndex';
}

/// Today, for her.
class NutritionPlate {
  const NutritionPlate({
    required this.chart,
    required this.content,
    required this.dayIndex,
    required this.meals,
  });

  final DietChart chart;
  final ChartContent content;
  final int dayIndex;
  final List<PlateMeal> meals;

  /// What "Swap" offers for one meal: the SAME SLOT on the chart's other
  /// days — real meals, in the chart's words. The chart's own `swaps` lines
  /// are advice ("Iron: palak, methi, jaggery…"), not dishes; offering them
  /// here put a sentence of guidance on the plate as breakfast (the phone,
  /// 2026-09-20). They are `swapIdeas` now, shown as text.
  List<String> swapsFor(PlateMeal m) {
    final out = <String>[];
    for (var d = 0; d < content.days.length; d++) {
      if (d == dayIndex) continue;
      final day = content.days[d];
      if (m.slotIndex < day.meals.length) {
        final other = day.meals[m.slotIndex].items.en;
        if (other != m.items && !out.contains(other)) out.add(other);
      }
    }
    return out;
  }

  /// The chart's own swap advice — sentences, for reading.
  List<String> get swapIdeas => [for (final s in content.swaps) s.en];
}

ChartStage plateStageFor(int week) =>
    week <= 13 ? ChartStage.trimester1 : (week <= 27 ? ChartStage.trimester2 : ChartStage.trimester3);

ChartDiet? plateDietFor(DietPreference? d) => switch (d) {
      DietPreference.vegetarian => ChartDiet.vegetarian,
      DietPreference.vegan => ChartDiet.vegetarian,
      DietPreference.eggetarian => ChartDiet.eggetarian,
      DietPreference.nonVegetarian => ChartDiet.nonVegetarian,
      DietPreference.jain => ChartDiet.jain,
      null => null,
    };

/// The chart that fits her best. Scored, not filtered: a chart earns a
/// point per axis it matches, loses a point per axis it contradicts, and
/// null on either side is neutral ("works for any"). Ties go to the more
/// specific chart; nothing matching falls to the month-by-month chart.
DietChart plateChartFor({
  required int week,
  DietPreference? diet,
  ChartRegion? region,
  ChartCondition? condition,
}) {
  final stage = plateStageFor(week);
  final d = plateDietFor(diet);
  DietChart? best;
  var bestScore = -99;
  for (final c in kDietCharts) {
    if (!kChartContent.containsKey(c.id)) continue; // no worked days → not a plate
    final f = facetsFor(c.id);
    var score = 0;
    int axis<T>(T? mine, T? theirs, {int weight = 1}) {
      if (mine == null || theirs == null) return 0;
      return mine == theirs ? weight : -weight * 3;
    }

    score += axis(condition, f.condition, weight: 4);
    if (condition == null && f.condition != null) score -= 6; // a GDM chart for a woman without GDM, never
    score += axis(stage, f.stage, weight: 2);
    score += axis(d, f.diet, weight: 3);
    if (d == ChartDiet.vegetarian && f.diet == ChartDiet.nonVegetarian) score -= 20;
    if (d == ChartDiet.jain && f.diet != null && f.diet != ChartDiet.jain) score -= 20;
    score += axis(region, f.region, weight: 2);
    if (region == null && f.region != null) score -= 1; // a regional chart she did not ask for
    if (f.inHindi) score -= 1; // the Hindi chart is a language, not a fit
    if (score > bestScore) {
      best = c;
      bestScore = score;
    }
  }
  return best ?? kDietCharts.firstWhere((c) => c.id == 'full_month_indian');
}

/// Her plate for [date].
NutritionPlate plateFor(
  DateTime date, {
  required int week,
  DietPreference? diet,
  ChartRegion? region,
  ChartCondition? condition,
  DietChart? chart,
}) {
  final c = chart ?? plateChartFor(week: week, diet: diet, region: region, condition: condition);
  final content = kChartContent[c.id]!;
  final doy = date.difference(DateTime(date.year, 1, 1)).inDays;
  final dayIndex = (doy + c.id.hashCode.abs()) % content.days.length;
  final day = content.days[dayIndex];
  return NutritionPlate(
    chart: c,
    content: content,
    dayIndex: dayIndex,
    meals: [
      for (var i = 0; i < day.meals.length; i++)
        PlateMeal(
          slot: day.meals[i].meal.en,
          items: day.meals[i].items.en,
          chartId: c.id,
          dayIndex: dayIndex,
          slotIndex: i,
        ),
    ],
  );
}

// -----------------------------------------------------------------------------
//  The needs
// -----------------------------------------------------------------------------

/// One daily tick.
class PlateNeed {
  const PlateNeed({required this.id, required this.label, required this.line, required this.recipeTag});

  /// Matches `NutrientGuide.id` where one exists.
  final String id;
  final String label;

  /// One line under the tick — why today, in her words.
  final String line;

  /// The recipe tag that counts.
  final String recipeTag;
}

/// Five, in the order the day meets them. Fluids is not a nutrient guide;
/// it is the water row, and it ticks itself at six glasses.
const List<PlateNeed> kPlateNeeds = [
  PlateNeed(id: 'iron', label: 'Iron', line: 'Dal, greens, jaggery, dates, with something sour to help you absorb it.', recipeTag: 'iron'),
  PlateNeed(id: 'calcium', label: 'Calcium', line: 'Milk, curd, paneer, ragi, sesame.', recipeTag: 'calcium'),
  PlateNeed(id: 'protein', label: 'Protein', line: 'Dal, paneer, egg, chana, curd. A little at every meal.', recipeTag: 'protein'),
  PlateNeed(id: 'folic_acid', label: 'Folate', line: 'Greens, oranges, beans, and your daily tablet.', recipeTag: 'folate'),
  PlateNeed(id: 'fibre', label: 'Fibre', line: 'Whole grains, fruit with the skin on, vegetables, and water to go with it.', recipeTag: 'fibre'),
];

PlateNeed? plateNeedById(String id) => kPlateNeeds.where((n) => n.id == id).firstOrNull;

/// The everyday foods that give a need — from the nutrient guide.
List<LocalizedText> plateFoodsFor(PlateNeed n) =>
    kNutrientGuides.where((g) => g.id == n.id).firstOrNull?.foods ?? const [];

/// The recipes that count for a need, hers first (diet respected).
List<Recipe> plateRecipesFor(PlateNeed n, {DietPreference? diet}) =>
    [for (final r in kRecipes) if (r.tags.contains(n.recipeTag) && recipeSuits(r, diet)) r];

/// Whether a recipe fits her diet. Vegetarian never sees fish; Jain never
/// sees onion-garlic dishes tagged so; eggetarian sees eggs, not meat. A
/// recipe with no signal suits everyone — null means "works for any", the
/// same rule as the chart facets.
bool recipeSuits(Recipe r, DietPreference? diet) {
  if (diet == null) return true;
  final t = r.tags;
  final nonVeg = t.contains('non_veg') || t.contains('fish') || t.contains('meat') || r.id.contains('macher');
  final egg = t.contains('egg');
  return switch (diet) {
    DietPreference.nonVegetarian => true,
    DietPreference.eggetarian => !nonVeg,
    DietPreference.vegetarian || DietPreference.vegan => !nonVeg && !egg,
    DietPreference.jain => !nonVeg && !egg && !t.contains('onion_garlic'),
  };
}

/// Regions, for the preference row. The chart facets' own enum, labelled.
String plateRegionLabel(ChartRegion r) => switch (r) {
      ChartRegion.bengali => 'Bengali',
      ChartRegion.tamil => 'Tamil',
      ChartRegion.punjabi => 'Punjabi',
      ChartRegion.gujarati => 'Gujarati',
      ChartRegion.southIndian => 'South Indian',
      ChartRegion.northIndian => 'North Indian',
    };

/// A date as the store's key. Local date, never UTC: her breakfast is on
/// her calendar, not Greenwich's.
String plateDateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
