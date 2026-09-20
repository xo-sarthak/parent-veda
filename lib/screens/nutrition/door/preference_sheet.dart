// =============================================================================
//  Nutrition — eating your way
// -----------------------------------------------------------------------------
//  One sheet, two questions, both optional: what she eats (the onboarding
//  answer, editable here) and where her kitchen is from. Set once and every
//  list respects it (Kitchen Stories' food preferences, Blue Apron's
//  toggles): the plate picks a matching chart, swaps stay inside it, a
//  vegetarian never meets the fish curry. Diet lives on the family profile
//  (it is who she is); region lives on the nutrition store (it is only
//  the kitchen's).
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/diet_chart_facets.dart' show ChartRegion;
import '../../../data/nutrition/nutrition_plate.dart';
import '../../../services/family_profile.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../v2/v2_palette.dart';
import 'nutrition_widgets.dart';

Future<void> showPreferenceSheet(BuildContext context, {bool region = false}) {
  final p = V2PaletteStore.instance.current;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => AnimatedBuilder(
      animation: Listenable.merge([FamilyProfileStore.instance, NutritionDayStore.instance]),
      builder: (ctx, _) {
        final diet = FamilyProfileStore.instance.diet;
        final reg = NutritionDayStore.instance.region;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + MediaQuery.paddingOf(ctx).bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('EATING YOUR WAY', style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
            const SizedBox(height: 4),
            Text('What you eat', style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            const SizedBox(height: 4),
            Text('Every plate, swap and recipe follows this.', style: pvManrope(fontSize: 13, color: p.ink2)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final d in DietPreference.values)
                NutritionChip(
                  label: d.label.en,
                  p: p,
                  selected: diet == d,
                  onTap: () => FamilyProfileStore.instance.setDiet(diet == d ? null : d),
                ),
            ]),
            const SizedBox(height: 22),
            Text('Your kitchen', style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            const SizedBox(height: 4),
            Text('Picks a regional chart where one exists; "Any" uses the all-India one.',
                style: pvManrope(fontSize: 13, color: p.ink2)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              NutritionChip(label: 'Any', p: p, selected: reg == null, onTap: () => NutritionDayStore.instance.setRegion(null)),
              for (final r in ChartRegion.values)
                NutritionChip(
                  label: plateRegionLabel(r),
                  p: p,
                  selected: reg == r,
                  onTap: () => NutritionDayStore.instance.setRegion(reg == r ? null : r),
                ),
            ]),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                pvCommitFeedback();
                Navigator.of(ctx).maybePop();
              },
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text('Done'),
            ),
          ]),
        );
      },
    ),
  );
}
