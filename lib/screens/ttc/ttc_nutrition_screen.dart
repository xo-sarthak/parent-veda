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
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/nutrition_data.dart' show kRecipes, Recipe;
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_daily_data.dart';
import '../doors/pv_list_row.dart' show PvRowGroup;
import '../nutrition/nutrition_recipes_screen.dart' show RecipeDetailScreen;
import '../v2/v2_palette.dart';
import 'ttc_lookup_parts.dart';
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';

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

class _TtcNutritionScreenState extends State<TtcNutritionScreen> {
  /// Date key -> the idea she swapped to. Kept across visits.
  final Map<String, String> _swaps = {};

  /// Which of the seven days is open. Today, until she picks another.
  int _day = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kTtcFoodSwapsKey);
      if (raw == null) return;
      final map = jsonDecode(raw);
      if (map is! Map) return;
      final today = ttcFoodDayKey(DateTime.now());
      if (!mounted) return;
      setState(() {
        for (final e in map.entries) {
          // A past day's swap has nothing left to say.
          if (e.key is String &&
              e.value is String &&
              (e.key as String).compareTo(today) >= 0) {
            _swaps[e.key as String] = e.value as String;
          }
        }
      });
    } catch (_) {/* local-first: a storage failure shows the rotation */}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kTtcFoodSwapsKey, jsonEncode(_swaps));
    } catch (_) {}
  }

  TtcNutrition? _byId(String id) {
    for (final n in ttcNutrition) {
      if (n.id == id) return n;
    }
    return null;
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

        // The nutrients this week actually leans on, each with the first day
        // it is on - a summary of the week rather than a target to hit.
        final nutrientDay = <String, int>{};
        for (var i = 0; i < week.length; i++) {
          nutrientDay.putIfAbsent(week[i].$2.nutrient(hi), () => i);
        }

        return TtcToolScaffold(
          // Plan and learn's hue in Tools.
          hue: 104,
          // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the eyebrow IS the Tools
          // tile's name, word for word; the title is the tile's own line.
          eyebrow: t.nutritionTitle,
          title: 'A week of ideas, not a plan.',
          // Kept for revert: 'One food idea for each day this week, for both
          // of you. If a day's idea doesn't suit you, tap Swap this day.'
          intro: 'One food idea for each day this week, for both of you. '
              "Pick a day to see its idea, and swap any that don't suit you.",
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),
                _DayStrip(
                  days: [for (final (d, _) in week) d],
                  selected: _day,
                  todayLabel: t.calendarToday,
                  onPick: (i) => setState(() => _day = i),
                ),
                const SizedBox(height: 24),

                // ---- the day ------------------------------------------------
                Text(
                    '${_dayName(day, t)} · ${idea.nutrient(hi)}'.toUpperCase(),
                    style: pvManrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: p.ink3)),
                const SizedBox(height: 8),
                Text(idea.meal(hi),
                    key: const ValueKey('ttc_food_meal'),
                    style: pvFraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        letterSpacing: -0.3,
                        color: p.ink1)),
                const SizedBox(height: 10),
                Text(idea.why(hi),
                    style: pvManrope(
                        fontSize: 14.5, height: 1.6, color: p.ink2)),
                const SizedBox(height: 16),
                Text('IN AN INDIAN KITCHEN',
                    style: pvManrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: p.ink3)),
                const SizedBox(height: 6),
                Text(idea.indian(hi),
                    style: pvManrope(
                        fontSize: 14,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                        color: p.ink1)),

                // A recipe, only where the app has one for this very dish.
                if (ttcNutritionRecipe(idea.id) case final recipe?) ...[
                  const SizedBox(height: 16),
                  PvRowGroup(p: p, children: [
                    TtcLookupActionRow(
                      key: const ValueKey('ttc_food_recipe'),
                      icon: Icons.restaurant_menu_rounded,
                      label: 'See the recipe: ${recipe.name.now}',
                      line: 'How to make it, step by step.',
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: const RouteSettings(name: 'ttc/recipe'),
                        builder: (_) => RecipeDetailScreen(recipe: recipe),
                      )),
                    ),
                  ]),
                ],
                const SizedBox(height: 18),
                KeyedSubtree(
                  key: const ValueKey('ttc_food_swap'),
                  child: TtcToolSecondary(
                    label: 'Swap this day',
                    onTap: () {
                      final next = ttcNextNutritionIdea(
                          idea, {for (final e in week) e.$2.id});
                      setState(() => _swaps[ttcFoodDayKey(day)] = next.id);
                      _save();
                    },
                  ),
                ),
                if (swapped) ...[
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton(
                      key: const ValueKey('ttc_food_unswap'),
                      onPressed: () {
                        setState(() => _swaps.remove(ttcFoodDayKey(day)));
                        _save();
                      },
                      child: Text('Back to the first idea for this day',
                          style: pvManrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: p.ink2)),
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
                      hue: 104,
                      onTap: () => setState(() => _day = e.value),
                    ),
                ]),
                const SizedBox(height: 26),
                TtcLookupNote(t.nutritionDisclaimer),
                const SizedBox(height: 26),
              ],
            )),
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
    return Row(
      key: const ValueKey('ttc_food_day_strip'),
      children: [
        for (var i = 0; i < days.length; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(
            child: Semantics(
              button: true,
              selected: i == selected,
              child: GestureDetector(
                key: ValueKey('ttc_food_day_$i'),
                onTap: () => onPick(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: i == selected ? p.ink1 : p.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: i == selected
                            ? p.ink1
                            : (i == 0 ? p.ink3 : p.line)),
                  ),
                  child: Column(children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(i == 0 ? todayLabel : short[days[i].weekday - 1],
                          maxLines: 1,
                          style: pvManrope(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: i == selected ? p.surface : p.ink2)),
                    ),
                    const SizedBox(height: 3),
                    Text('${days[i].day}',
                        style: pvManrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: i == selected ? p.surface : p.ink1)),
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
