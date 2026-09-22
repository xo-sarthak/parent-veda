// =============================================================================
//  Nutrition — one meal, and its swaps
// -----------------------------------------------------------------------------
//  Two sheets since 2026-09-22, because two buttons asked two questions and
//  got one answer. The plate row's SWAP opened the same sheet as the row
//  itself, with the swaps scrolled into view — "when I click on swap, it's
//  not swapping, it opens the same screen" (the user). And the sheet said
//  the meal's numbers three times: the glance line under the row, then
//  "Strong in", then "This meal, estimated" — "why am I able to see the
//  nutritional value at three places?"
//
//  So:
//
//   · `showMealSheet` — the row's tap. The photo, the slot and the dish, the
//     numbers ONCE (the six tiles the user kept: "I like it"), then what is
//     actually on the plate — each dish we can name, with its own share — a
//     recipe for it where the library has one, and the two actions at the
//     foot: Swap and Not today. No "Strong in".
//
//   · `showSwapSheet` — the row's Swap. Leads with the alternatives; one tap
//     swaps, the sheet closes and the row changes under it (Centr's ⇄, Chopt's
//     "Swapping…", Instacart's "replace with"). The chart's own swap ideas
//     stay at its foot as text, and "Put it back" when a swap is on.
//
//  "Not today" stays as easy as a swap — nausea, a late night, no appetite
//  are all fine reasons and none of them need explaining to an app.
//
//  The previous single sheet is commented out at the foot, kept for revert.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/nutrition/food_values.dart';
import '../../../data/nutrition/nutrition_photos.dart';
import '../../../data/nutrition/nutrition_plate.dart';
import '../../../data/nutrition_data.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../v2/v2_palette.dart';
import 'nutrition_widgets.dart';
import 'recipe_cook_screen.dart' show openRecipe;

Future<void> _sheet(BuildContext context, Widget Function(BuildContext) builder) {
  final p = V2PaletteStore.instance.current;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.surface,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: builder,
  );
}

/// The meal: what it is, what it comes to, what is on it. [pregnancy] lets
/// the recipe row open the recipe; null hides the row.
Future<void> showMealSheet(
  BuildContext context, {
  required NutritionPlate plate,
  required PlateMeal meal,
  required DateTime date,
  PregnancyController? pregnancy,
  // Kept on the signature for revert; the Swap button opens `showSwapSheet`.
  bool swapFirst = false,
  // From a chart's day: no swap, no not-today — those act on today's plate.
  bool readOnly = false,
}) =>
    _sheet(context, (ctx) => _MealSheet(plate: plate, meal: meal, date: date, pregnancy: pregnancy, readOnly: readOnly));

/// The swaps: the alternatives first, one tap each.
Future<void> showSwapSheet(
  BuildContext context, {
  required NutritionPlate plate,
  required PlateMeal meal,
  required DateTime date,
}) =>
    _sheet(context, (ctx) => _SwapSheet(plate: plate, meal: meal, date: date));

/// A recipe in the library for a dish named on the plate, if there is one:
/// the recipe's whole name in the sentence, or its first word when that word
/// is a dish word and not a filler ("Ragi porridge" matches "ragi porridge
/// with dates"; "Dal" would match everything, so one word needs five
/// letters).
Recipe? recipeForMeal(String items) {
  final s = items.toLowerCase();
  for (final r in kRecipes) {
    if (s.contains(r.name.en.toLowerCase())) return r;
  }
  // Otherwise the recipe's first TWO words, both on the plate. One word was
  // too loose: "chicken" put "Chicken clear soup" under a chicken curry
  // (the phone, 2026-09-22).
  for (final r in kRecipes) {
    final words = r.name.en.toLowerCase().split(RegExp(r'[\s,]+')).where((w) => w.length >= 3).take(2).toList();
    if (words.length < 2) continue;
    if (words.every((w) => RegExp('\\b${RegExp.escape(w)}\\b').hasMatch(s))) return r;
  }
  return null;
}

Widget _handle(V2Palette p) => Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(2)),
      ),
    );

class _MealSheet extends StatelessWidget {
  const _MealSheet({required this.plate, required this.meal, required this.date, required this.pregnancy, this.readOnly = false});
  final NutritionPlate plate;
  final PlateMeal meal;
  final DateTime date;
  final PregnancyController? pregnancy;
  final bool readOnly;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: NutritionDayStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final store = NutritionDayStore.instance;
          final current = readOnly ? meal.items : (store.swapFor(date, meal.key) ?? meal.items);
          final skipped = !readOnly && store.isSkipped(date, meal.key);
          final url = nutritionPhotoFor(current);
          final total = estimateMeal(current);
          final parts = matchMeal(current);
          final recipe = pregnancy == null ? null : recipeForMeal(current);
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.94,
            minChildSize: 0.4,
            builder: (ctx, sc) => ListView(
              controller: sc,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20 + MediaQuery.paddingOf(ctx).bottom),
              children: [
                // The photo, then the words — no fade (the user, 2026-09-20).
                if (url != null)
                  SizedBox(height: 200, child: NutritionPhoto(url: url, p: p, iconSize: 44))
                else
                  _handle(p),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(meal.slot.toUpperCase(),
                          style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
                      if (!readOnly && store.swapFor(date, meal.key) != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.swap_horiz_rounded, size: 13, color: p.ink3),
                        const SizedBox(width: 3),
                        Text('SWAPPED', style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
                      ],
                      if (skipped) ...[
                        const SizedBox(width: 8),
                        Text('NOT TODAY', style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
                      ],
                    ]),
                    const SizedBox(height: 4),
                    Text(plateName(current),
                        style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
                    if (plateNote(current) case final note?) ...[
                      const SizedBox(height: 6),
                      Text(note, style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
                    ],

                    // ---- the recipe, where the library has one ---------------
                    if (recipe != null) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          pvCommitFeedback();
                          Navigator.of(ctx).maybePop();
                          openRecipe(context, recipe, pregnancy!);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          decoration: BoxDecoration(
                              color: nutritionMarkTint(p).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(14)),
                          child: Row(children: [
                            nutritionMarkWell(p, IntentMark.cookMark, size: 36, radius: 11),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Cook it',
                                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
                                Text('${recipe.name.en} · the recipe, step by step',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: pvManrope(fontSize: 12, color: p.ink2)),
                              ]),
                            ),
                            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink2),
                          ]),
                        ),
                      ),
                    ],

                    // ---- the numbers, once -------------------------------------
                    if (total != null) ...[
                      const SizedBox(height: 18),
                      NutritionValuesGrid(p: p, values: total, title: 'This meal, estimated'),
                    ],

                    // ---- what is on the plate, dish by dish --------------------
                    //
                    // The estimate is a sum; this is the sum's parts, so
                    // "chicken curry with roti and palak" says what each
                    // brings (the user, 2026-09-22: "why not provide it
                    // individually as well?"). Only when there is more than
                    // one dish we can name — one row under a total that
                    // equals it is the repetition this sheet just shed.
                    if (parts.length > 1) ...[
                      const SizedBox(height: 18),
                      Text('On the plate',
                          style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
                      const SizedBox(height: 4),
                      Text('Each dish\'s share of the estimate.',
                          style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
                      const SizedBox(height: 6),
                      for (var i = 0; i < parts.length; i++)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              border: i == parts.length - 1 ? null : Border(bottom: BorderSide(color: p.line))),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: NutritionPhoto(url: nutritionPhotoFor(parts[i].key), p: p, iconSize: 16)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(_cap(parts[i].key) + (parts[i].count > 1 ? ' ×${_n(parts[i].count)}' : ''),
                                    style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
                                const SizedBox(height: 2),
                                NutritionGlanceLine(p: p, values: parts[i].values),
                              ]),
                            ),
                          ]),
                        ),
                    ],

                    // ---- the two actions --------------------------------------
                    if (!readOnly) ...[
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            pvCommitFeedback();
                            Navigator.of(ctx).maybePop();
                            showSwapSheet(context, plate: plate, meal: meal, date: date);
                          },
                          icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                          label: const Text('Swap'),
                          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            pvCommitFeedback();
                            store.toggleSkip(date, meal.key);
                            Navigator.of(ctx).maybePop();
                          },
                          icon: Icon(skipped ? Icons.undo_rounded : Icons.bedtime_outlined, size: 18),
                          label: Text(skipped ? 'Put it back' : 'Not today'),
                          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text('Skipping a meal is allowed. If it is most meals for a few days, mention it to your doctor.',
                        style: pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3)),
                    ],
                  ]),
                ),
              ],
            ),
          );
        },
      );

  static String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  static String _n(double v) => v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
}

class _SwapSheet extends StatelessWidget {
  const _SwapSheet({required this.plate, required this.meal, required this.date});
  final NutritionPlate plate;
  final PlateMeal meal;
  final DateTime date;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: NutritionDayStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final store = NutritionDayStore.instance;
          final current = store.swapFor(date, meal.key) ?? meal.items;
          final swapped = store.swapFor(date, meal.key) != null;
          final swaps = plate.swapsFor(meal).where((s) => s != current).toList();
          final currentValues = estimateMeal(current);
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.72,
            maxChildSize: 0.94,
            minChildSize: 0.4,
            builder: (ctx, sc) => ListView(
              controller: sc,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.paddingOf(ctx).bottom),
              children: [
                _handle(p),
                const SizedBox(height: 16),
                Text('SWAP ${meal.slot.toUpperCase()}',
                    style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
                const SizedBox(height: 4),
                Text('Instead of ${plateName(current)}',
                    style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.3, color: p.ink1)),
                const SizedBox(height: 4),
                Text('From the same chart, so the day still adds up. One tap swaps it.',
                    style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
                const SizedBox(height: 10),
                if (swapped)
                  _Option(
                    p: p,
                    label: meal.items,
                    values: estimateMeal(meal.items),
                    against: currentValues,
                    trailing: 'Put it back',
                    onTap: () {
                      pvCommitFeedback();
                      store.setSwap(date, meal.key, null);
                      Navigator.of(ctx).maybePop();
                    },
                  ),
                for (final s in swaps)
                  _Option(
                    p: p,
                    label: s,
                    values: estimateMeal(s),
                    against: currentValues,
                    onTap: () {
                      pvCommitFeedback();
                      store.setSwap(date, meal.key, s);
                      Navigator.of(ctx).maybePop();
                    },
                  ),
                if (swaps.isEmpty && !swapped)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('The chart wrote no other ${meal.slot.toLowerCase()} for this week. The ideas below are its own.',
                        style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
                  ),
                if (plate.swapIdeas.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text('Swap ideas from the chart',
                      style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
                  const SizedBox(height: 8),
                  for (final idea in plate.swapIdeas)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: p.ink3)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(idea, style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2))),
                      ]),
                    ),
                ],
              ],
            ),
          );
        },
      );
}

/// One alternative: photo, name, its glance line, and how its kcal compares
/// with what is on the plate now ("−40 kcal", "+12 g protein" would be too
/// much; one figure keeps it a choice, not a spreadsheet).
class _Option extends StatelessWidget {
  const _Option({
    required this.p,
    required this.label,
    required this.values,
    required this.against,
    required this.onTap,
    this.trailing,
  });
  final V2Palette p;
  final String label;
  final NutritionValues? values;
  final NutritionValues? against;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    String? delta;
    if (values != null && against != null) {
      final d = (values!.kcal - against!.kcal).round();
      if (d != 0) delta = '${d > 0 ? '+' : '−'}${d.abs()} kcal';
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 52, height: 52, child: NutritionPhoto(url: nutritionPhotoFor(label), p: p, iconSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plateName(label), style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.35, color: p.ink1)),
              if (plateNote(label) case final note?)
                Text(note, maxLines: 2, overflow: TextOverflow.ellipsis, style: pvManrope(fontSize: 11.5, height: 1.35, color: p.ink3)),
              const SizedBox(height: 2),
              NutritionGlanceLine(p: p, values: values),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(trailing ?? 'Swap', style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w800, color: p.ink1)),
            if (delta != null) Text(delta, style: pvManrope(fontSize: 11, color: p.ink3)),
          ]),
        ]),
      ),
    );
  }
}

// =============================================================================
//  KEPT FOR REVERT — the one sheet that did both (2026-09-20 → 2026-09-22)
// -----------------------------------------------------------------------------
//  Photo band → slot → dish → "Swapped · back to …" → NutritionTopThree
//  ("Strong in") → NutritionValuesGrid ("This meal, estimated") → "Swap it
//  for" rows → "Swap ideas from the chart" → Not today. `swapFirst` opened it
//  taller so the swaps were on screen. The user: the same screen from both
//  buttons, and the numbers three times.
// =============================================================================
