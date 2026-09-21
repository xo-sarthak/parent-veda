// =============================================================================
//  Nutrition — one meal, and its swaps
// -----------------------------------------------------------------------------
//  A slot on the plate opens this sheet: the photo, the slot, the dishes,
//  then the swaps the chart wrote for exactly this, then "Not today". A
//  swap is one tap and the plate changes under the sheet (Uber Eats' swap
//  sheet, Instacart's "replace with"). "Not today" is deliberately as easy
//  as a swap — nausea, a late night, no appetite are all fine reasons and
//  none of them need explaining to an app.
// =============================================================================

import 'package:flutter/material.dart';
import '../../../data/nutrition/food_values.dart';

import '../../../data/nutrition/nutrition_photos.dart';
import '../../../data/nutrition/nutrition_plate.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../v2/v2_palette.dart';
import 'nutrition_widgets.dart';

Future<void> showMealSheet(
  BuildContext context, {
  required NutritionPlate plate,
  required PlateMeal meal,
  required DateTime date,
  bool swapFirst = false,
}) {
  final p = V2PaletteStore.instance.current;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.surface,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => _MealSheet(plate: plate, meal: meal, date: date, p: p, swapFirst: swapFirst),
  );
}

class _MealSheet extends StatelessWidget {
  const _MealSheet({required this.plate, required this.meal, required this.date, required this.p, required this.swapFirst});
  final NutritionPlate plate;
  final PlateMeal meal;
  final DateTime date;
  final V2Palette p;
  final bool swapFirst;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: NutritionDayStore.instance,
        builder: (context, _) {
          final store = NutritionDayStore.instance;
          final current = store.swapFor(date, meal.key) ?? meal.items;
          final skipped = store.isSkipped(date, meal.key);
          final swaps = plate.swapsFor(meal).where((s) => s != current).toList();
          final url = nutritionPhotoFor(current);
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: swapFirst ? 0.78 : 0.62,
            maxChildSize: 0.92,
            minChildSize: 0.4,
            builder: (ctx, sc) => ListView(
              controller: sc,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20 + MediaQuery.paddingOf(ctx).bottom),
              children: [
                // The photo band only when there is a photo; a grey band with
                // a scrim read as a broken image on the phone.
                // The photo, then the words. It had a fade into the sheet at
                // its foot; the user (2026-09-20): "no white mist, no fading —
                // the image, then the section below." Kept for revert:
                //   Positioned.fill(child: DecoratedBox(gradient: transparent → p.surface, stops 0.55→1))
                if (url != null) ...[
                  SizedBox(height: 190, child: NutritionPhoto(url: url, p: p, iconSize: 44)),
                  const SizedBox(height: 18),
                ] else
                  const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(meal.slot.toUpperCase(),
                        style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
                    const SizedBox(height: 4),
                    Text(current,
                        style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
                    if (store.swapFor(date, meal.key) != null) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          pvCommitFeedback();
                          store.setSwap(date, meal.key, null);
                        },
                        child: Text('Swapped · back to ${meal.items}',
                            style: pvManrope(fontSize: 12.5, color: p.ink3, decoration: TextDecoration.underline)),
                      ),
                    ],
                    if (estimateMeal(current) case final v?) ...[
                      const SizedBox(height: 16),
                      NutritionTopThree(p: p, values: v),
                      const SizedBox(height: 18),
                      NutritionValuesGrid(p: p, values: v, title: 'This meal, estimated'),
                    ],
                    const SizedBox(height: 18),
                    Text('Swap it for',
                        style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
                    const SizedBox(height: 4),
                    Text('From the same chart, so the day still adds up.',
                        style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
                    const SizedBox(height: 10),
                    for (var i = 0; i < swaps.length; i++)
                      InkWell(
                        onTap: () {
                          pvCommitFeedback();
                          store.setSwap(date, meal.key, swaps[i]);
                          Navigator.of(ctx).maybePop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                              border: i == swaps.length - 1 ? null : Border(bottom: BorderSide(color: p.line))),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                  width: 44, height: 44, child: NutritionPhoto(url: nutritionPhotoFor(swaps[i]), p: p, iconSize: 18)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(swaps[i], style: pvManrope(fontSize: 14, height: 1.4, color: p.ink1))),
                            Icon(Icons.swap_horiz_rounded, size: 18, color: p.ink3),
                          ]),
                        ),
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
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: () {
                        pvCommitFeedback();
                        store.toggleSkip(date, meal.key);
                        Navigator.of(ctx).maybePop();
                      },
                      icon: Icon(skipped ? Icons.undo_rounded : Icons.bedtime_outlined, size: 18),
                      label: Text(skipped ? 'Put it back' : 'Not today'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    ),
                    const SizedBox(height: 6),
                    Text('Skipping a meal is allowed. If it is most meals for a few days, mention it to your doctor.',
                        style: pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3)),
                  ]),
                ),
              ],
            ),
          );
        },
      );
}
