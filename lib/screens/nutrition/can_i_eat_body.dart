// =============================================================================
//  Can I eat this? — the food checker and cravings, folded together
// -----------------------------------------------------------------------------
//  Sub-tab 1 of the Nutrition door, rendered in place.
//
//  ⚠️ THE FOLD IS THE BRIEF'S OWN CALL AND IT IS THE RIGHT ONE. Its words:
//  *"Fold Cravings in here (same 'can I have this' question)."*
//
//  They were two screens because they were built at different times, not
//  because they answer different questions. A woman typing "papaya" and a woman
//  tapping "something sour" are asking the same thing about two kinds of
//  object, and the honest answer to "why are these separate" was "history".
//
//  ⚠️ TWO BODIES, ONE SCROLL, AND NOTHING MERGED. `FoodCheckBody` keeps its own
//  category filter and `CravingsScreen` keeps its own search controller and its
//  own trimester derivation. Merging their state would have meant rewriting two
//  working screens to save a heading — and the brief's loudest rule on this
//  door is reuse, do not rebuild.
//
//  ⚠️ THE SEAM IS A HEADING, NOT A DIVIDER. She scrolls from a food list into a
//  cravings list, and the one thing that has to be obvious is that the badges
//  change meaning: Safe / Limit / Avoid above, Yes / In small amounts below.
//  The heading says which list she is in; without it the second set of badges
//  reads as an inconsistency in the first.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'cravings_screen.dart';
import 'food_verdict_screen.dart';

class CanIEatBody extends StatelessWidget {
  const CanIEatBody({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FoodCheckBody(),
              const SizedBox(height: 30),

              // ---- the seam ------------------------------------------------
              Text('Cravings',
                  style: pvFraunces(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      letterSpacing: -0.45,
                      color: p.ink1)),
              const SizedBox(height: 4),
              // ⚠️ IT SAYS WHY THE BADGES CHANGE. A craving answer depends on
              // how many weeks she is — the cravings pages are written that way
              // — and a food answer usually does not. One line, so the second
              // list does not read as the first list disagreeing with itself.
              Text('Answered for the week you are in, not pregnancy in '
                  'general.',
                  style:
                      pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3)),
              const SizedBox(height: 14),
              CravingsBody(pregnancy: pregnancy),
            ],
          );
        },
      );
}
