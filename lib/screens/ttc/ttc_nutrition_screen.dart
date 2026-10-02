// =============================================================================
//  TTC - This week's food ideas (was "Nutrition Planner" until 2026-09-27)
// -----------------------------------------------------------------------------
//  Not a meal plan to follow. A week of ideas built from the same library that
//  feeds Today's nutrition card, so the planner and the daily card can never
//  suggest two different things on the same day.
//
//  The rules this screen keeps, from §3.9 and the product's standing content
//  rules:
//
//   * Indian-family first. Every entry carries an India-specific line, and that
//     line is the part that makes it ours rather than translated.
//   * No calorie counting, no macros, no diet culture, and no plan to fall off.
//     There is nothing to tick and nothing to complete.
//   * Both of you. Nutrition in this stage is not "her diet" - zinc is his in
//     the same way folate is hers.
//
//  ---------------------------------------------------------------------------
//  ⚠️ REBUILT AROUND ONE DAY AT A TIME (tool rebuild, 2026-09-27, night)
//  ---------------------------------------------------------------------------
//  "Old tools in new clothes": seven shadowed cards in a column, each with a
//  violet pill, a brown tip box and a swap link, and a nutrient panel above
//  that said "tap one" and then only printed a sentence. A swap was forgotten
//  the moment she left. Now, the way the meal-plan apps do it (Centr "Meals",
//  https://mobbin.com/screens/705eaf3c-a294-402a-abd2-870d1eb06136: a day strip
//  on top, the day's food under it, a swap on the meal; Apple Fitness plan
//  week strip, https://mobbin.com/screens/87a2df92-c761-472e-8e91-37803295ee1f):
//
//    · A strip of the seven days, today first and chosen. One tap, one day.
//    · The day's idea large: what it gives you, the food, why, the Indian-
//      kitchen line, and the recipe where the app has one for that very dish.
//    · "Swap this day" right under it, and "Back to the first idea" once she
//      has. A swap is KEPT now (`ttc_food_idea_swaps_v1`, one idea id per
//      date, past dates dropped), because a swap that undoes itself on the
//      next visit is a button that lies.
//    · "Nutrients this week" as chips that jump to the day each is on, so the
//      summary and the week are one thing, not two panels.
//  Today's card on the home still reads the rotation, not her swap; see the
//  note in the report for the lead (it is not this file's to change).
//
//  ---------------------------------------------------------------------------
//  ⚠️ REBUILT AS A TOOL (2026-09-29): a day's food idea as a photo card, the
//  day's four meals from the nutritionist's week (`ttc_meal_week_data.dart`),
//  her kitchen, and swaps that stay. See the note above the state class.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/nutrition/nutrition_photos.dart'
    show nutritionPhotoFor, nutritionRecipePhoto;
import '../../data/nutrition_data.dart' show kRecipes, Recipe;
import '../../data/reads/read_images.dart' show readImageFor;
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_daily_data.dart';
import '../../ttc/ttc_meal_week_data.dart';
import '../../widgets/pv_feedback.dart' show pvCommitFeedback;
import '../doors/pv_list_row.dart' show PvRowGroup;
import '../nutrition/nutrition_recipes_screen.dart' show RecipeDetailScreen;
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_lookup_parts.dart';
import 'ttc_strings.dart';
import 'ttc_ivf_readiness_screen.dart' show kIvfHue;
import 'ttc_read_next.dart' show ttcToolReadNext;
import 'ttc_tool_chrome.dart';
import 'ttc_tool_hues.dart' show kTtcToolHuePlan;
import 'ttc_tool_marks.dart' show TtcToolArt, TtcToolMark;
import 'ttc_common.dart' show ttcTitleInk, ttcLine;

/// Which food ideas have a real recipe behind them in the app's own recipe
/// library (`kRecipes`), by the idea's id (tools pass, 2026-09-27).
///
/// ⚠️ ONLY WHERE THE DISH IS THE IDEA. Most ideas are a food group ("amla,
/// seasonal fruit, tomatoes"), not a dish, and linking those to one recipe
/// would say something the idea does not. A missing recipe id shows no link
/// rather than a dead one; `ttc_nutrition_test.dart` pins that both exist.
const Map<String, String> kTtcNutritionRecipes = {
  'folate_greens': 'dal_palak', // "Palak dal with a squeeze of lemon"
  'iron_bajra': 'punjabi_rajma', // "...and a bowl of rajma"
};

Recipe? ttcNutritionRecipe(String nutritionId) {
  final id = kTtcNutritionRecipes[nutritionId];
  if (id == null) return null;
  for (final r in kRecipes) {
    if (r.id == id) return r;
  }
  return null;
}

/// The next idea for a day, skipping the ones already on screen this week, in
/// the rotation's own order. Returns [current] when nothing else is left.
TtcNutrition ttcNextNutritionIdea(
    TtcNutrition current, Set<String> shownIds) {
  final list = ttcNutrition;
  final start = list.indexWhere((n) => n.id == current.id);
  for (var step = 1; step <= list.length; step++) {
    final next = list[(start + step) % list.length];
    if (next.id != current.id && !shownIds.contains(next.id)) return next;
  }
  return current;
}

/// Where a kept swap lives: `{ "2026-09-28": "iron_bajra", ... }`.
const String kTtcFoodSwapsKey = 'ttc_food_idea_swaps_v1';

String ttcFoodDayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}'
    '-${d.day.toString().padLeft(2, '0')}';

void openTtcNutrition(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcNutritionScreen(),
    settings: const RouteSettings(name: 'ttc/nutrition'),
  ));
}

/// Where a kept meal swap lives: `{ "2026-09-30|breakfast": 5, ... }`, the
/// value being the plan day whose dish she picked for that meal.
const String kTtcFoodMealSwapsKey = 'ttc_food_meal_swaps_v1';

/// Her kitchen (`TtcKitchen.name`), kept across visits.
const String kTtcFoodKitchenKey = 'ttc_food_kitchen_v1';

String _mealKey(DateTime day, TtcMealSlot slot) =>
    '${ttcFoodDayKey(day)}|${slot.name}';

/// Ideas that the data itself says are mostly his ("so this one is mostly
/// for him"). A tag only where the words already say it.
const Set<String> _forHim = {'zinc_male'};

class TtcNutritionScreen extends StatefulWidget {
  const TtcNutritionScreen({super.key});

  /// The coming week, built from the same rotation Today uses - so the planner
  /// and the daily card agree by construction rather than by coincidence.
  static List<(DateTime, TtcNutrition)> weekFrom(DateTime start) => [
        for (var i = 0; i < 7; i++)
          (
            DateTime(start.year, start.month, start.day + i),
            ttcPickForToday(ttcNutrition,
                now: DateTime(start.year, start.month, start.day + i),
                offset: 1),
          )
      ];

  @override
  State<TtcNutritionScreen> createState() => _TtcNutritionScreenState();
}

// =============================================================================
//  ⚠️ REBUILT AS A TOOL (2026-09-29, "Plan and check", heading by heading)
// -----------------------------------------------------------------------------
//  The user on build 20: the tools "just look like big blobs of text". This
//  page was one: a serif sentence, a paragraph, a capitals label and another
//  paragraph, then a full-width swap button. And the nutritionist's week of
//  meals, whose own next step reads "Plan your own week - turn these ideas
//  into a day-by-day plan that fits your kitchen", opened this page and found
//  none of its meals on it.
//
//  Now, from Mobbin (the report lists every URL):
//    · Centr "Meals": a day strip, then the day's meals as photo cards, each
//      with a swap on the card - https://mobbin.com/screens/718c28d7-fa13-491b-8fa1-f695bc360164
//    · Wabi's week: the meal named small above the dish, the photo beside it -
//      https://mobbin.com/screens/a6147a60-54d3-46a6-9e80-4a6949846227
//    · Noom "Replace": a swap opens the alternatives for that one slot, the
//      current one marked - https://mobbin.com/screens/06bceadf-50d3-4f96-8175-a90847ce33f8
//    · Yazio / NYT Cooking filters: a diet is one pill row, chosen once -
//      https://mobbin.com/screens/9f31cf0b-3123-49e1-8eb4-5df1e0c15a78
//    · Crouton and Yazio recipe tags: small tinted tags say what a dish is at
//      a glance - https://mobbin.com/screens/2ea52748-3877-4f07-97fe-53c39284c2c4
//
//  So the page is: pick a day; the day's food idea as a photo card with its
//  nutrient as a tag (the kitchen line folds); the day's four meals from the
//  week of meals, each a photo, a dish and what it puts on the plate, each
//  swappable for any other of that meal in the week; her kitchen (with eggs,
//  no eggs, Jain, non-veg) picked once and kept; the week's nutrients as
//  pills that jump to their day; the whole read, with its shopping list, one
//  row away. Every swap and her kitchen are KEPT.
//
//  ⚠️ STILL NOTHING TO TICK. The standing rule at the head of this file holds:
//  no calories, no targets, nothing to complete. A swap is a preference, not
//  a score.
// =============================================================================
class _TtcNutritionScreenState extends State<TtcNutritionScreen> {
  /// Date key -> the idea she swapped to. Kept across visits.
  final Map<String, String> _swaps = {};

  /// "date|slot" -> the plan day whose dish she picked. Kept across visits.
  final Map<String, int> _mealSwaps = {};

  TtcKitchen _kitchen = TtcKitchen.vegEggs;

  /// Which of the seven days is open. Today, until she picks another.
  int _day = 0;

  /// The idea card's "In an Indian kitchen" line, folded until asked for.
  bool _tipOpen = false;

  /// The kitchen note under the meals (Jain swaps, cooking meat and fish).
  bool _noteOpen = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = ttcFoodDayKey(DateTime.now());
      final ideas = <String, String>{};
      final meals = <String, int>{};
      var kitchen = TtcKitchen.vegEggs;

      final raw = prefs.getString(kTtcFoodSwapsKey);
      if (raw != null) {
        final map = jsonDecode(raw);
        if (map is Map) {
          for (final e in map.entries) {
            // A past day's swap has nothing left to say.
            if (e.key is String &&
                e.value is String &&
                (e.key as String).compareTo(today) >= 0) {
              ideas[e.key as String] = e.value as String;
            }
          }
        }
      }
      final rawMeals = prefs.getString(kTtcFoodMealSwapsKey);
      if (rawMeals != null) {
        final map = jsonDecode(rawMeals);
        if (map is Map) {
          for (final e in map.entries) {
            if (e.key is String &&
                e.value is int &&
                (e.value as int) >= 1 &&
                (e.value as int) <= 7 &&
                (e.key as String).split('|').first.compareTo(today) >= 0) {
              meals[e.key as String] = e.value as int;
            }
          }
        }
      }
      final k = prefs.getString(kTtcFoodKitchenKey);
      for (final v in TtcKitchen.values) {
        if (v.name == k) kitchen = v;
      }
      if (!mounted) return;
      setState(() {
        _swaps.addAll(ideas);
        _mealSwaps.addAll(meals);
        _kitchen = kitchen;
      });
    } catch (_) {/* local-first: a storage failure shows the rotation */}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kTtcFoodSwapsKey, jsonEncode(_swaps));
      await prefs.setString(kTtcFoodMealSwapsKey, jsonEncode(_mealSwaps));
      await prefs.setString(kTtcFoodKitchenKey, _kitchen.name);
    } catch (_) {}
  }

  TtcNutrition? _byId(String id) {
    for (final n in ttcNutrition) {
      if (n.id == id) return n;
    }
    return null;
  }

  /// The dish on a date's meal: her swap if she made one, else the plan's.
  TtcPlanMeal _mealOn(DateTime day, TtcMealSlot slot) {
    final from = _mealSwaps[_mealKey(day, slot)] ?? ttcPlanDayFor(day);
    return ttcPlanMeal(from, slot);
  }

  Future<void> _swapMeal(DateTime day, TtcMealSlot slot) async {
    final current = _mealOn(day, slot);
    final own = ttcPlanDayFor(day);
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _MealSwapSheet(
        slot: slot,
        currentDay: current.day,
        ownDay: own,
        kitchen: _kitchen,
      ),
    );
    if (picked == null || picked == current.day || !mounted) return;
    final key = _mealKey(day, slot);
    final before = _mealSwaps[key];
    setState(() {
      if (picked == own) {
        _mealSwaps.remove(key);
      } else {
        _mealSwaps[key] = picked;
      }
    });
    _save();
    pvCommitFeedback();
    if (!mounted) return;
    // Tell her, with the way back (tell-before-anything-changes).
    pvSnack(
      context,
      picked == own
          ? '${slot.label}: back to the plan'
          : '${slot.label} swapped',
      icon: Icons.check_rounded,
      lift: 16,
      action: 'Undo',
      onAction: () {
        if (!mounted) return;
        setState(() {
          if (before == null) {
            _mealSwaps.remove(key);
          } else {
            _mealSwaps[key] = before;
          }
        });
        _save();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcLang.instance,
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final p = V2PaletteStore.instance.current;
        final base = TtcNutritionScreen.weekFrom(DateTime.now());
        final week = [
          for (final (day, idea) in base)
            (day, _byId(_swaps[ttcFoodDayKey(day)] ?? '') ?? idea),
        ];
        final (day, idea) = week[_day];
        final swapped = week[_day].$2.id != base[_day].$2.id;
        final dayName = _dayName(day, t);
        final planDay = ttcPlanDayFor(day);

        // The nutrients this week actually leans on, each with the first day
        // it is on - a summary of the week rather than a target to hit.
        final nutrientDay = <String, int>{};
        for (var i = 0; i < week.length; i++) {
          nutrientDay.putIfAbsent(week[i].$2.nutrient(hi), () => i);
        }

        final kitchenNote = switch (_kitchen) {
          TtcKitchen.jain => ('What changes in a Jain kitchen', kTtcJainSwaps),
          TtcKitchen.nonVeg => ('Adding chicken, fish or eggs', [kTtcNonVegNote]),
          _ => null,
        };

        return TtcToolScaffold(
          // "Plan and check" in Tools: the header wears its group's colour.
          // Kept for revert (2026-09-29): hue: 104,
          hue: kTtcToolHuePlan,
          // The tool's mark over the eyebrow (2026-09-29, ttc_tool_marks.dart).
          toolId: 'nutrition',
          // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the eyebrow IS the Tools
          // tile's name, word for word; the title is the tile's own line.
          eyebrow: t.nutritionTitle,
          title: 'A week of ideas, not a plan.',
          // Kept for revert (2026-09-29): 'One food idea for each day this
          // week, for both of you. '
          //     "Pick a day to see its idea, and swap any that don't suit you.",
          intro: 'A food idea and four simple meals for each day, for both of '
              "you. Pick your kitchen once, and swap anything that doesn't "
              'suit you.',
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _DayStrip(
                  days: [for (final (d, _) in week) d],
                  selected: _day,
                  todayLabel: t.calendarToday,
                  onPick: (i) => setState(() {
                    _day = i;
                    _tipOpen = false;
                  }),
                ),

                // ---- the day's food idea ------------------------------------
                TtcLookupHeading('Food idea for $dayName', top: 26),
                _IdeaCard(
                  key: ValueKey('ttc_food_idea_${idea.id}'),
                  idea: idea,
                  hi: hi,
                  tipOpen: _tipOpen,
                  onTip: () => setState(() => _tipOpen = !_tipOpen),
                  swapped: swapped,
                  onSwap: () {
                    final next = ttcNextNutritionIdea(
                        idea, {for (final e in week) e.$2.id});
                    setState(() {
                      _swaps[ttcFoodDayKey(day)] = next.id;
                      _tipOpen = false;
                    });
                    _save();
                    pvCommitFeedback();
                  },
                  onUnswap: () {
                    setState(() => _swaps.remove(ttcFoodDayKey(day)));
                    _save();
                  },
                ),

                // ---- the day's meals ----------------------------------------
                // The plan day is named, so "From day 5" on a swapped card and
                // the read's "day 1" in the line below both have an anchor.
                // Kept for revert (2026-09-29): 'Meals for $dayName'
                TtcLookupHeading('Meals for $dayName · day $planDay of 7',
                    top: 30),
                Text(ttcPlanDayLine(planDay),
                    key: const ValueKey('ttc_food_day_line'),
                    style: pvManrope(
                        fontSize: 13.5, height: 1.5, color: p.ink2)),
                const SizedBox(height: 14),
                Text('Your kitchen',
                    style: pvManrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: p.ink1)),
                const SizedBox(height: 8),
                // ⚠️ DIVIDED BLOCKS, NOT A WRAP OF PILLS (2026-09-29): on the
                // render the four pills left "Non-veg" alone on a second row
                // with a ragged gap beside it, which is the waste
                // `TtcToolOptions` exists to remove (two across, both edges).
                // Kept for revert (2026-09-29):
                // Wrap(
                //   key: const ValueKey('ttc_food_kitchen'),
                //   spacing: 8,
                //   runSpacing: 8,
                //   children: [
                //     for (final k in TtcKitchen.values)
                //       Semantics(
                //         button: true,
                //         selected: k == _kitchen,
                //         label: 'Your kitchen: ${k.label}',
                //         excludeSemantics: true,
                //         child: TtcToolPill(
                //           key: ValueKey('ttc_food_kitchen_${k.name}'),
                //           label: k.label,
                //           on: k == _kitchen,
                //           hue: kTtcToolHuePlan,
                //           onTap: () {
                //             if (k == _kitchen) return;
                //             setState(() {
                //               _kitchen = k;
                //               _noteOpen = false;
                //             });
                //             _save();
                //             pvCommitFeedback();
                //           },
                //         ),
                //       ),
                //   ],
                // ),
                KeyedSubtree(
                  key: const ValueKey('ttc_food_kitchen'),
                  child: TtcToolOptions(
                    p: p,
                    hue: kTtcToolHuePlan,
                    items: [
                      for (final k in TtcKitchen.values)
                        TtcToolOption(
                          label: k.label,
                          on: k == _kitchen,
                          onTap: () {
                            if (k == _kitchen) return;
                            setState(() {
                              _kitchen = k;
                              _noteOpen = false;
                            });
                            _save();
                            pvCommitFeedback();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final slot in TtcMealSlot.values) ...[
                  _MealCard(
                    key: ValueKey('ttc_food_meal_${slot.name}'),
                    meal: _mealOn(day, slot),
                    slot: slot,
                    kitchen: _kitchen,
                    swappedFrom: _mealSwaps.containsKey(_mealKey(day, slot))
                        ? _mealOn(day, slot).day
                        : null,
                    onSwap: () => _swapMeal(day, slot),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(kTtcPlateLine,
                    style: pvManrope(
                        fontSize: 12, height: 1.5, color: p.ink2)),
                if (kitchenNote case (final title, final lines)) ...[
                  const SizedBox(height: 14),
                  _FoldRow(
                    key: const ValueKey('ttc_food_kitchen_note'),
                    title: title,
                    meta: lines.length > 1 ? '${lines.length} swaps' : null,
                    open: _noteOpen,
                    onTap: () => setState(() => _noteOpen = !_noteOpen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final l in lines)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (lines.length > 1) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 7),
                                    child: Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                            color: ttcTitleInk,
                                            shape: BoxShape.circle)),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  child: Text(l,
                                      style: pvManrope(
                                          fontSize: 13.5,
                                          height: 1.5,
                                          color: p.ink1)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // ---- the week's nutrients -----------------------------------
                TtcLookupHeading(t.nutritionFocus, top: 30),
                Text("Tap one to see the day it's on.",
                    style: ttcLookupBody(p)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final e in nutrientDay.entries)
                    TtcToolPill(
                      label: e.key,
                      on: week[_day].$2.nutrient(hi) == e.key,
                      hue: kTtcToolHuePlan,
                      onTap: () => setState(() {
                        _day = e.value;
                        _tipOpen = false;
                      }),
                    ),
                ]),

                // ---- the whole week, as the nutritionist wrote it -----------
                // ⚠️ MOVED TO THE FOOT AS "READ NEXT" (2026-10-02, the user:
                // the article on a tool screen is the reader's rail at the
                // bottom, on every tool). It was a photo row here, keyed
                // `ttc_food_open_week_read`, 'The whole week and the shopping
                // list'. Kept for revert.
                const SizedBox(height: 22),
                TtcLookupNote(t.nutritionDisclaimer),
                const SizedBox(height: 26),
              ],
            )),
            ...ttcToolReadNext(
              context,
              const [kTtcMealPlanReadId],
              hue: kIvfHue,
              railKey: const ValueKey('ttc_food_read_next'),
            ),
            const SizedBox(height: 26),
          ],
        );
      },
    );
  }

  static String _dayName(DateTime d, TtcS t) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return t.calendarToday;
    }
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return '${days[d.weekday - 1]} ${d.day}';
  }
}

// =============================================================================
//  Kept for revert (2026-09-29): the build as it was before the tool was
//  rebuilt (one day's idea as text, a full-width swap button).
// =============================================================================
// ignore: unused_element
// class _TtcNutritionScreenState ... {  (the rest of the state is unchanged above)
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: TtcLang.instance,
//       builder: (context, _) {
//         final t = TtcS.current();
//         final hi = t.hinglish;
//         final p = V2PaletteStore.instance.current;
//         final base = TtcNutritionScreen.weekFrom(DateTime.now());
//         final week = [
//           for (final (day, idea) in base)
//             (day, _byId(_swaps[ttcFoodDayKey(day)] ?? '') ?? idea),
//         ];
//         final (day, idea) = week[_day];
//         final swapped = week[_day].$2.id != base[_day].$2.id;
//
//         // The nutrients this week actually leans on, each with the first day
//         // it is on - a summary of the week rather than a target to hit.
//         final nutrientDay = <String, int>{};
//         for (var i = 0; i < week.length; i++) {
//           nutrientDay.putIfAbsent(week[i].$2.nutrient(hi), () => i);
//         }
//
//         return TtcToolScaffold(
//           // Plan and learn's hue in Tools.
//           hue: 104,
//           // The tool's mark over the eyebrow (2026-09-29, ttc_tool_marks.dart).
//           toolId: 'nutrition',
//           // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the eyebrow IS the Tools
//           // tile's name, word for word; the title is the tile's own line.
//           eyebrow: t.nutritionTitle,
//           title: 'A week of ideas, not a plan.',
//           // Kept for revert: 'One food idea for each day this week, for both
//           // of you. If a day's idea doesn't suit you, tap Swap this day.'
//           intro: 'One food idea for each day this week, for both of you. '
//               "Pick a day to see its idea, and swap any that don't suit you.",
//           children: [
//             ttcToolPad(Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 22),
//                 _DayStrip(
//                   days: [for (final (d, _) in week) d],
//                   selected: _day,
//                   todayLabel: t.calendarToday,
//                   onPick: (i) => setState(() => _day = i),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // ---- the day ------------------------------------------------
//                 Text(
//                     '${_dayName(day, t)} · ${idea.nutrient(hi)}'.toUpperCase(),
//                     style: pvManrope(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: 1.2,
//                         color: p.ink3)),
//                 const SizedBox(height: 8),
//                 Text(idea.meal(hi),
//                     key: const ValueKey('ttc_food_meal'),
//                     style: pvFraunces(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w600,
//                         height: 1.25,
//                         letterSpacing: -0.3,
//                         color: p.ink1)),
//                 const SizedBox(height: 10),
//                 Text(idea.why(hi),
//                     style: pvManrope(
//                         fontSize: 14.5, height: 1.6, color: p.ink2)),
//                 const SizedBox(height: 16),
//                 Text('IN AN INDIAN KITCHEN',
//                     style: pvManrope(
//                         fontSize: 9.5,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: 1.1,
//                         color: p.ink3)),
//                 const SizedBox(height: 6),
//                 Text(idea.indian(hi),
//                     style: pvManrope(
//                         fontSize: 14,
//                         height: 1.55,
//                         fontWeight: FontWeight.w600,
//                         color: p.ink1)),
//
//                 // A recipe, only where the app has one for this very dish.
//                 if (ttcNutritionRecipe(idea.id) case final recipe?) ...[
//                   const SizedBox(height: 16),
//                   PvRowGroup(p: p, children: [
//                     TtcLookupActionRow(
//                       key: const ValueKey('ttc_food_recipe'),
//                       icon: Icons.restaurant_menu_rounded,
//                       label: 'See the recipe: ${recipe.name.now}',
//                       line: 'How to make it, step by step.',
//                       onTap: () =>
//                           Navigator.of(context).push(MaterialPageRoute<void>(
//                         settings: const RouteSettings(name: 'ttc/recipe'),
//                         builder: (_) => RecipeDetailScreen(recipe: recipe),
//                       )),
//                     ),
//                   ]),
//                 ],
//                 const SizedBox(height: 18),
//                 KeyedSubtree(
//                   key: const ValueKey('ttc_food_swap'),
//                   child: TtcToolSecondary(
//                     // Kept for revert (2026-09-28): 'Swap this day'
//                     label: 'Swap this food idea',
//                     onTap: () {
//                       final next = ttcNextNutritionIdea(
//                           idea, {for (final e in week) e.$2.id});
//                       setState(() => _swaps[ttcFoodDayKey(day)] = next.id);
//                       _save();
//                     },
//                   ),
//                 ),
//                 if (swapped) ...[
//                   const SizedBox(height: 4),
//                   Center(
//                     child: TextButton(
//                       key: const ValueKey('ttc_food_unswap'),
//                       onPressed: () {
//                         setState(() => _swaps.remove(ttcFoodDayKey(day)));
//                         _save();
//                       },
//                       child: Text('Back to the first idea for this day',
//                           style: pvManrope(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w700,
//                               color: p.ink2)),
//                     ),
//                   ),
//                 ],
//
//                 // ---- the week's nutrients -----------------------------------
//                 TtcLookupHeading(t.nutritionFocus, top: 30),
//                 Text("Tap one to see the day it's on.",
//                     style: ttcLookupBody(p)),
//                 const SizedBox(height: 12),
//                 Wrap(spacing: 8, runSpacing: 8, children: [
//                   for (final e in nutrientDay.entries)
//                     TtcToolPill(
//                       label: e.key,
//                       on: week[_day].$2.nutrient(hi) == e.key,
//                       hue: 104,
//                       onTap: () => setState(() => _day = e.value),
//                     ),
//                 ]),
//                 const SizedBox(height: 26),
//                 TtcLookupNote(t.nutritionDisclaimer),
//                 const SizedBox(height: 26),
//               ],
//             )),
//           ],
//         );
//       },
//     );
//   }
//
// Kept for revert (2026-09-29): the day strip before it gained a spoken
// label per day and the switch black on its chosen edge.
// /// Seven days across the page, the chosen one in ink, today ringed.
// class _DayStrip extends StatelessWidget {
//   const _DayStrip({
//     required this.days,
//     required this.selected,
//     required this.todayLabel,
//     required this.onPick,
//   });
//
//   final List<DateTime> days;
//   final int selected;
//   final String todayLabel;
//   final ValueChanged<int> onPick;
//
//   @override
//   Widget build(BuildContext context) {
//     final p = V2PaletteStore.instance.current;
//     const short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return Row(
//       key: const ValueKey('ttc_food_day_strip'),
//       children: [
//         for (var i = 0; i < days.length; i++) ...[
//           if (i > 0) const SizedBox(width: 5),
//           Expanded(
//             child: Semantics(
//               button: true,
//               selected: i == selected,
//               child: GestureDetector(
//                 key: ValueKey('ttc_food_day_$i'),
//                 onTap: () => onPick(i),
//                 behavior: HitTestBehavior.opaque,
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 160),
//                   padding: const EdgeInsets.symmetric(vertical: 9),
//                   decoration: BoxDecoration(
//                     color: i == selected ? ttcTitleInk : p.surface,
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(
//                         color: i == selected
//                             ? p.ink1
//                             : (i == 0 ? p.ink3 : p.line)),
//                   ),
//                   child: Column(children: [
//                     FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: Text(i == 0 ? todayLabel : short[days[i].weekday - 1],
//                           maxLines: 1,
//                           style: pvManrope(
//                               fontSize: 10.5,
//                               fontWeight: FontWeight.w700,
//                               color: i == selected ? p.surface : p.ink2)),
//                     ),
//                     const SizedBox(height: 3),
//                     Text('${days[i].day}',
//                         style: pvManrope(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w800,
//                             color: i == selected ? p.surface : p.ink1)),
//                   ]),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }

/// A photo from the read-image pipeline, square-cornered to its box, with the
/// tool's drawn bowl while it loads or when there is none or no signal
/// (local-first: the fallback is a finished picture, not a grey box).
class _FoodPhoto extends StatelessWidget {
  const _FoodPhoto({required this.url, required this.size, this.radius = 12});

  final String? url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final drawn = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: ttcLine),
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: TtcToolArt(
          mark: TtcToolMark.nutrition,
          tint: v2BlockTint(kTtcToolHuePlan, V2PaletteStore.instance.current)),
    );
    final u = url;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: u == null
            ? drawn
            : ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Image.network(
                  u,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => drawn,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : drawn,
                ),
              ),
      ),
    );
  }
}

/// The day's food idea: its photo, its nutrient as a tag, the food, why, the
/// Indian-kitchen line folded under one tap, the recipe where there is one,
/// and the swap.
class _IdeaCard extends StatelessWidget {
  const _IdeaCard({
    super.key,
    required this.idea,
    required this.hi,
    required this.tipOpen,
    required this.onTip,
    required this.swapped,
    required this.onSwap,
    required this.onUnswap,
  });

  final TtcNutrition idea;
  final bool hi;
  final bool tipOpen;
  final VoidCallback onTip;
  final bool swapped;
  final VoidCallback onSwap;
  final VoidCallback onUnswap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final photo = readImageFor('ttc_nutrition_${idea.id}');
    final recipe = ttcNutritionRecipe(idea.id);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ttcLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (photo != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ExcludeSemantics(
                child: Image.network(
                  photo,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _PhotoGround(),
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const _PhotoGround(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 6, runSpacing: 6, children: [
                  _Tag(idea.nutrient(hi),
                      key: const ValueKey('ttc_food_idea_nutrient')),
                  if (_forHim.contains(idea.id)) const _Tag('Mostly for him'),
                  if (swapped) const _Tag('Swapped', quiet: true),
                ]),
                const SizedBox(height: 10),
                Text(idea.meal(hi),
                    key: const ValueKey('ttc_food_meal'),
                    style: pvFraunces(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        letterSpacing: -0.3,
                        color: p.ink1)),
                const SizedBox(height: 8),
                Text(idea.why(hi),
                    style: pvManrope(
                        fontSize: 14, height: 1.55, color: p.ink2)),
              ],
            ),
          ),
          // The India-first line: the part that makes it ours, one tap away.
          _FoldRow(
            key: const ValueKey('ttc_food_tip'),
            title: 'In an Indian kitchen',
            open: tipOpen,
            onTap: onTip,
            inset: 16,
            child: Text(idea.indian(hi),
                style: pvManrope(
                    fontSize: 13.5,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                    color: p.ink1)),
          ),
          // A recipe, only where the app has one for this very dish.
          if (recipe != null) ...[
            Divider(height: 1, thickness: 1, color: p.line),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TtcLookupRow(
                key: const ValueKey('ttc_food_recipe'),
                title: 'See the recipe: ${recipe.name.now}',
                leading: _FoodPhoto(
                    url: nutritionRecipePhoto(recipe.id, recipe.name.en),
                    size: 40,
                    radius: 10),
                lines: [ttcLookupLine('How to make it, step by step.')],
                onTap: () =>
                    Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'ttc/recipe'),
                  builder: (_) => RecipeDetailScreen(recipe: recipe),
                )),
              ),
            ),
          ],
          Divider(height: 1, thickness: 1, color: p.line),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            // A Wrap, not a Row: at large text the two buttons stack rather
            // than push each other off the card.
            child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
              // Kept for revert (2026-09-29): a full-width TtcToolSecondary
              // 'Swap this food idea' under the text, and a centred
              // 'Back to the first idea for this day' under that.
              _InkTextButton(
                key: const ValueKey('ttc_food_swap'),
                icon: Icons.swap_horiz_rounded,
                label: 'Swap this food idea',
                onTap: onSwap,
              ),
              if (swapped)
                _InkTextButton(
                  key: const ValueKey('ttc_food_unswap'),
                  icon: Icons.undo_rounded,
                  label: 'First idea',
                  semantics: 'Back to the first idea for this day',
                  onTap: onUnswap,
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

/// The photo frame's ground while the picture loads or when it cannot: the
/// group's tint with the drawn bowl, never a grey hole.
class _PhotoGround extends StatelessWidget {
  const _PhotoGround();

  @override
  Widget build(BuildContext context) {
    final tint =
        v2BlockTint(kTtcToolHuePlan, V2PaletteStore.instance.current);
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 64,
          height: 64,
          child: TtcToolArt(mark: TtcToolMark.nutrition, tint: tint),
        ),
      ),
    );
  }
}

/// A small tag: the group's tint behind ink words (tags are the one place a
/// tint may sit behind text), or a hairline outline when [quiet].
class _Tag extends StatelessWidget {
  const _Tag(this.label, {super.key, this.quiet = false});

  final String label;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: quiet ? Colors.white : v2BlockTint(kTtcToolHuePlan, p),
        borderRadius: BorderRadius.circular(999),
        border: quiet ? Border.all(color: ttcLine) : null,
      ),
      child: Text(label,
          style: pvManrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: p.ink1)),
    );
  }
}

/// An ink text button with a line icon, 44 high: an action inside a card.
class _InkTextButton extends StatelessWidget {
  const _InkTextButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.semantics,
  });

  final IconData icon;
  final String label;
  final String? semantics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: semantics ?? label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 18, color: ttcTitleInk),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: ttcTitleInk)),
                ),
              ]),
            ),
          ),
        ),
      );
}

/// A row that folds its content open under it: title, optional meta, a
/// chevron that turns.
class _FoldRow extends StatelessWidget {
  const _FoldRow({
    super.key,
    required this.title,
    required this.open,
    required this.onTap,
    required this.child,
    this.meta,
    this.inset = 0,
  });

  final String title;
  final String? meta;
  final bool open;
  final VoidCallback onTap;
  final Widget child;
  final double inset;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: open,
          label: title,
          excludeSemantics: true,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: inset, vertical: 10),
                child: Row(children: [
                  Expanded(
                    child: Text(title,
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: p.ink1)),
                  ),
                  if (meta != null) ...[
                    Text(meta!,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: p.ink2)),
                    const SizedBox(width: 6),
                  ],
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.expand_more_rounded,
                        size: 22, color: ttcTitleInk),
                  ),
                ]),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: open
              ? Padding(
                  padding: EdgeInsets.fromLTRB(inset, 0, inset, 12),
                  child: child,
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// One meal of the day: its photo, the meal's name, the dish, what it puts on
/// the plate, a Jain swap when her kitchen needs one, and the swap button.
class _MealCard extends StatelessWidget {
  const _MealCard({
    super.key,
    required this.meal,
    required this.slot,
    required this.kitchen,
    required this.swappedFrom,
    required this.onSwap,
  });

  final TtcPlanMeal meal;
  final TtcMealSlot slot;
  final TtcKitchen kitchen;

  /// The plan day she swapped this dish in from, or null for the plan's own.
  final int? swappedFrom;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final dish = meal.dishFor(kitchen);
    final gives = meal.givesFor(kitchen);
    final jain =
        kitchen == TtcKitchen.jain ? ttcJainSwapFor(dish) : null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ttcLine),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _FoodPhoto(url: ttcPlanMealPhoto(meal, kitchen), size: 72),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(slot.label.toUpperCase(),
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: p.ink2)),
              const SizedBox(height: 4),
              Text(dish,
                  style: pvManrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: p.ink1)),
              if (gives.isNotEmpty || swappedFrom != null) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final g in TtcPlate.values)
                    if (gives.contains(g)) _Tag(g.label),
                  if (swappedFrom != null)
                    _Tag('From day $swappedFrom', quiet: true),
                ]),
              ],
              if (jain != null) ...[
                const SizedBox(height: 8),
                Text('Jain: $jain',
                    key: ValueKey('ttc_food_jain_${slot.name}'),
                    style: pvManrope(
                        fontSize: 12.5, height: 1.45, color: p.ink2)),
              ],
            ],
          ),
        ),
        Semantics(
          button: true,
          label: 'Swap ${slot.label.toLowerCase()}',
          excludeSemantics: true,
          child: IconButton(
            key: ValueKey('ttc_food_swap_${slot.name}'),
            onPressed: onSwap,
            tooltip: 'Swap ${slot.label.toLowerCase()}',
            icon: const Icon(Icons.swap_horiz_rounded,
                size: 22, color: ttcTitleInk),
          ),
        ),
      ]),
    );
  }
}

/// A plan dish's photo: its own where the data names one, else the dish word
/// the nutrition door already matches to a photo (`nutritionPhotoFor`).
String? ttcPlanMealPhoto(TtcPlanMeal meal, TtcKitchen kitchen) {
  final dish = meal.dishFor(kitchen);
  if (dish == meal.dish && meal.photoId != null) {
    return readImageFor(meal.photoId!);
  }
  return nutritionPhotoFor(dish);
}

/// "Swap breakfast": every breakfast of the week, this day's own marked, the
/// one on her plate ticked. A tap picks it (Noom's Replace sheet).
class _MealSwapSheet extends StatelessWidget {
  const _MealSwapSheet({
    required this.slot,
    required this.currentDay,
    required this.ownDay,
    required this.kitchen,
  });

  final TtcMealSlot slot;
  final int currentDay;
  final int ownDay;
  final TtcKitchen kitchen;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final media = MediaQuery.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
      child: SafeArea(
        top: false,
        child: ListView(
          key: const ValueKey('ttc_food_swap_sheet'),
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: ttcLine, borderRadius: BorderRadius.circular(99)),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: Text('Swap ${slot.label.toLowerCase()}',
                    style: pvFraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: p.ink1)),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded,
                    size: 22, color: ttcTitleInk),
              ),
            ]),
            const SizedBox(height: 4),
            Text(
                'The plan says swap dishes freely. Pick any '
                '${slot.label.toLowerCase()} from the week.',
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
            const SizedBox(height: 12),
            PvRowGroup(p: p, children: [
              for (var d = 1; d <= 7; d++)
                _SwapOption(
                  meal: ttcPlanMeal(d, slot),
                  kitchen: kitchen,
                  chosen: d == currentDay,
                  own: d == ownDay,
                  onTap: () => Navigator.of(context).pop(d),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _SwapOption extends StatelessWidget {
  const _SwapOption({
    required this.meal,
    required this.kitchen,
    required this.chosen,
    required this.own,
    required this.onTap,
  });

  final TtcPlanMeal meal;
  final TtcKitchen kitchen;
  final bool chosen;
  final bool own;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final dish = meal.dishFor(kitchen);
    return Semantics(
      button: true,
      selected: chosen,
      label: '$dish${own ? ', this day\'s dish' : ''}',
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('ttc_food_swap_option_${meal.day}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            _FoodPhoto(url: ttcPlanMealPhoto(meal, kitchen), size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dish,
                      style: pvManrope(
                          fontSize: 14,
                          fontWeight: chosen ? FontWeight.w800 : FontWeight.w600,
                          height: 1.35,
                          color: p.ink1)),
                  const SizedBox(height: 3),
                  Text(own ? "Day ${meal.day} · this day's dish" : 'Day ${meal.day}',
                      style: pvManrope(
                          fontSize: 12,
                          fontWeight: own ? FontWeight.w800 : FontWeight.w500,
                          color: p.ink2)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 24,
              child: chosen
                  ? const Icon(Icons.check_rounded,
                      size: 22, color: ttcTitleInk)
                  : null,
            ),
          ]),
        ),
      ),
    );
  }
}

/// Seven days across the page, the chosen one in ink, today ringed.
class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.days,
    required this.selected,
    required this.todayLabel,
    required this.onPick,
  });

  final List<DateTime> days;
  final int selected;
  final String todayLabel;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    const short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const long = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return Row(
      key: const ValueKey('ttc_food_day_strip'),
      children: [
        for (var i = 0; i < days.length; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(
            child: Semantics(
              button: true,
              selected: i == selected,
              label: i == 0
                  ? todayLabel
                  : '${long[days[i].weekday - 1]} ${days[i].day}',
              excludeSemantics: true,
              child: GestureDetector(
                key: ValueKey('ttc_food_day_$i'),
                onTap: () => onPick(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: i == selected ? ttcTitleInk : p.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: i == selected
                            ? ttcTitleInk
                            : (i == 0 ? p.ink3 : p.line)),
                  ),
                  child: Column(children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                          i == 0 ? todayLabel : short[days[i].weekday - 1],
                          maxLines: 1,
                          style: pvManrope(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: i == selected ? Colors.white : p.ink2)),
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('${days[i].day}',
                          maxLines: 1,
                          style: pvManrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color:
                                  i == selected ? Colors.white : p.ink1)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
//  Kept for revert (2026-09-27, night): the state and the day card as they
//  were before the tool rebuild, seven cards in a column.
// =============================================================================
// class _TtcNutritionScreenState extends State<TtcNutritionScreen> {
//   /// ⚠️ "SWAP THIS DAY" (tools pass, 2026-09-27). Day index -> the idea she
//   /// swapped to. Held for this visit only: these are ideas to browse, not a
//   /// plan to keep, and Today's card still reads the rotation.
//   final Map<int, TtcNutrition> _swapped = {};
//
//   /// The nutrient chip she tapped, to show why it matters.
//   String? _openNutrient;
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: TtcLang.instance,
//       builder: (context, _) {
//         final t = TtcS.current();
//         final hi = t.hinglish;
//         final base = TtcNutritionScreen.weekFrom(DateTime.now());
//         final week = [
//           for (var i = 0; i < base.length; i++)
//             (base[i].$1, _swapped[i] ?? base[i].$2),
//         ];
//         // The nutrients this week actually leans on - a summary of the week
//         // rather than a target to hit.
//         final nutrients =
//             week.map((e) => e.$2.nutrient(hi)).toSet().toList();
//         String? whyFor(String nutrient) {
//           for (final e in week) {
//             if (e.$2.nutrient(hi) == nutrient) return e.$2.why(hi);
//           }
//           return null;
//         }
//
//         // ⚠️ ONE SHELL FOR EVERY TOOL (2026-09-27). Tiles in the same Tools
//         // hub opened in two different shells: most wore `TtcToolScaffold`
//         // (hero field, serif title, white sheet) and this one a plain page
//         // with a back bar. Only the shell changed: the tile's name is the
//         // hero title, the what-this-is line is the hero intro, and the
//         // week sits in the sheet unchanged. Kept for revert (2026-09-27):
//         // return Scaffold(
//         //   backgroundColor: ttcBg,
//         //   body: SafeArea(
//         //     child: ListView(
//         //       padding: const EdgeInsets.fromLTRB(
//         //           ttcGutter, 8, ttcGutter, ttcBottomInset),
//         //       children: [
//         //         TtcBackBar(title: t.nutritionTitle),
//         //         const SizedBox(height: 16),
//         //         Text(<the intro below>,
//         //             style: ttcBody(14, color: ttcInk, h: 1.6)),
//         //         const SizedBox(height: 20),
//         return TtcToolScaffold(
//           // Plan and learn's hue in Tools.
//           hue: 104,
//           // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the eyebrow IS the Tools
//           // tile's name, word for word; the title is the tile's own line.
//           eyebrow: t.nutritionTitle,
//           title: 'A week of ideas, not a plan.',
//           // What this is, first (tools pass, 2026-09-27). Kept for
//           // revert: t.nutritionIntro, which opened on what this is not.
//           intro: 'One food idea for each day this week, for both of you. '
//               "If a day's idea doesn't suit you, tap Swap this day.",
//           children: [
//             ttcToolPad(Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 22),
//
//                 TtcCard(
//                   color: ttcPanel,
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ttcEyebrow(t.nutritionFocus, color: ttcPurple),
//                         const SizedBox(height: 10),
//                         Wrap(
//                           spacing: 8,
//                           runSpacing: 8,
//                           children: [
//                             for (final n in nutrients)
//                               GestureDetector(
//                                 onTap: () => setState(() => _openNutrient =
//                                     _openNutrient == n ? null : n),
//                                 behavior: HitTestBehavior.opaque,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 7),
//                                   decoration: BoxDecoration(
//                                       color: _openNutrient == n
//                                           ? ttcInk
//                                           : Colors.white,
//                                       borderRadius:
//                                           BorderRadius.circular(999)),
//                                   child: Text(n,
//                                       style: ttcBody(12,
//                                           color: _openNutrient == n
//                                               ? Colors.white
//                                               : ttcPurple,
//                                           w: FontWeight.w800)),
//                                 ),
//                               ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         // One plain line on why, for the chip she tapped.
//                         Text(
//                             _openNutrient == null
//                                 ? 'Tap one to see why it matters.'
//                                 : (whyFor(_openNutrient!) ?? ''),
//                             style: ttcBody(12.5,
//                                 color: _openNutrient == null
//                                     ? ttcMuted
//                                     : ttcInk,
//                                 h: 1.5)),
//                       ]),
//                 ),
//                 const SizedBox(height: 20),
//
//                 ttcSectionTitle(t.nutritionWeek),
//                 for (var i = 0; i < week.length; i++) ...[
//                   _DayCard(
//                     day: week[i].$1,
//                     nutrition: week[i].$2,
//                     t: t,
//                     onSwap: () => setState(() {
//                       _swapped[i] = ttcNextNutritionIdea(week[i].$2,
//                           {for (final e in week) e.$2.id});
//                     }),
//                   ),
//                   const SizedBox(height: 11),
//                 ],
//
//                 const SizedBox(height: 14),
//                 Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Icon(Icons.info_outline_rounded,
//                       size: 15, color: ttcMuted),
//                   const SizedBox(width: 9),
//                   Expanded(
//                     child: Text(t.nutritionDisclaimer,
//                         style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
//                   ),
//                 ]),
//                 const SizedBox(height: 26),
//               ],
//             )),
//           ],
//           // Kept for revert (2026-09-27): the old page's closing.
//           //     ],
//           //   ),
//           // ),
//         );
//       },
//     );
//   }
// }
//
// class _DayCard extends StatelessWidget {
//   const _DayCard(
//       {required this.day,
//       required this.nutrition,
//       required this.t,
//       required this.onSwap});
//
//   final DateTime day;
//   final TtcNutrition nutrition;
//   final TtcS t;
//   final VoidCallback onSwap;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = t.hinglish;
//     final today = DateTime.now();
//     final isToday = day.year == today.year &&
//         day.month == today.month &&
//         day.day == today.day;
//
//     return TtcCard(
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Text(isToday ? t.calendarToday : _weekday(day),
//               style: ttcBody(11.5,
//                   color: isToday ? ttcPurple : ttcMuted,
//                   w: FontWeight.w800)),
//           const SizedBox(width: 10),
//           const Spacer(),
//           // Flexible (2026-09-27): "Less processed food" beside "Wednesday"
//           // overflowed at phone width once a swap could put it there.
//           Flexible(
//             flex: 3,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                   color: ttcPanel, borderRadius: BorderRadius.circular(999)),
//               child: Text(nutrition.nutrient(hi),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: ttcBody(11, color: ttcPurple, w: FontWeight.w800)),
//             ),
//           ),
//         ]),
//         const SizedBox(height: 10),
//         Text(nutrition.meal(hi), style: ttcJakarta(15.5)),
//         const SizedBox(height: 7),
//         Text(nutrition.why(hi), style: ttcBody(13, h: 1.5)),
//         const SizedBox(height: 12),
//         // The India-first line. The part that makes this ours.
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: ttcCautionCard,
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Icon(Icons.emoji_objects_outlined, size: 15, color: ttcBrown),
//             const SizedBox(width: 9),
//             Expanded(
//               child: Text(nutrition.indian(hi),
//                   style:
//                       ttcBody(12.5, color: ttcBrown, h: 1.5, w: FontWeight.w600)),
//             ),
//           ]),
//         ),
//         // A recipe, only where the app has one for this very dish.
//         if (ttcNutritionRecipe(nutrition.id) case final recipe?) ...[
//           const SizedBox(height: 10),
//           GestureDetector(
//             onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
//               settings: const RouteSettings(name: 'ttc/recipe'),
//               builder: (_) => RecipeDetailScreen(recipe: recipe),
//             )),
//             behavior: HitTestBehavior.opaque,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: Row(children: [
//                 const Icon(Icons.restaurant_menu_rounded,
//                     size: 16, color: ttcInk),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text('See the recipe: ${recipe.name.now}',
//                       style:
//                           ttcBody(13, color: ttcInk, w: FontWeight.w800)),
//                 ),
//                 const Icon(Icons.arrow_forward_rounded,
//                     size: 16, color: ttcInk),
//               ]),
//             ),
//           ),
//         ],
//         const SizedBox(height: 6),
//         Align(
//           alignment: Alignment.centerLeft,
//           child: TextButton.icon(
//             onPressed: onSwap,
//             style: TextButton.styleFrom(
//               foregroundColor: ttcSoft,
//               padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
//               minimumSize: const Size(0, 40),
//             ),
//             icon: const Icon(Icons.swap_horiz_rounded, size: 18),
//             label: Text('Swap this day',
//                 style: ttcBody(13, color: ttcSoft, w: FontWeight.w800)),
//           ),
//         ),
//       ]),
//     );
//   }
//
//   static String _weekday(DateTime d) {
//     const days = [
//       'Monday', 'Tuesday', 'Wednesday', 'Thursday',
//       'Friday', 'Saturday', 'Sunday',
//     ];
//     return days[d.weekday - 1];
//   }
// }
