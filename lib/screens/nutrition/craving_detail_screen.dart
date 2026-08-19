// =============================================================================
//  CravingDetailScreen — one craving, answered where she actually is
// -----------------------------------------------------------------------------
//  The four questions, in the order she asks them:
//
//    1. Can I have this?          -> the verdict AT HER TRIMESTER, first
//    2. Why do I want it so much? -> the thing she is half-wondering
//    3. What if I can't?          -> alternatives, and only when the answer
//                                    was limit or avoid
//    4. Can I make it at home?    -> the recipe, which is usually how a "no"
//                                    turns into a "yes"
//
//  ⚠️ THE VERDICT IS THE FIRST THING ON THE PAGE, ABOVE EVERYTHING. Not after
//  an explanation of why cravings happen, not after a paragraph on hormones.
//  She is standing in front of a stall or a fridge; the answer goes first and
//  the reasoning follows it.
//
//  ⚠️ AND THE ANSWER SAYS WHICH WEEK IT IS FOR. "In small amounts" alone is a
//  leaflet. "At week 30, in small amounts" is the app knowing her — and it is
//  also the honest framing, because for papaya, spice and pickle the answer
//  genuinely differs from what it would have been at week 8.
//
//  ⚠️ NEVER A PERSONALISED RISK. Everything here is guidance keyed to a week
//  she already has, never a computed chance of harm — CLAUDE.md's clinical
//  invariants, and the reason there is no percentage anywhere on this page.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/cravings_data.dart';
import '../../data/nutrition_data.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'cravings_screen.dart' show cravingVerdictStyle;

class CravingDetailScreen extends StatelessWidget {
  const CravingDetailScreen(
      {super.key, required this.item, required this.pregnancy});

  final CravingItem item;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final week = pregnancy.currentWeek;
        final tri = week < 14 ? 1 : (week < 28 ? 2 : 3);
        final verdict = item.verdictAt(tri);
        final v = cravingVerdictStyle(verdict, p);
        final stageNote = item.stageNoteAt(tri);

        // ⚠️ ALTERNATIVES ONLY WHERE THE ANSWER WAS NOT A PLAIN YES.
        // Offering a substitute for something she can simply have reads as
        // disapproval wearing the costume of help.
        final showAlternatives =
            verdict != NutritionVerdict.safe && item.alternatives.isNotEmpty;

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(item.name.now,
                style: pvFraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 36),
              children: [
                // ---- 1 · THE ANSWER, AT HER WEEK -------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
                  decoration: BoxDecoration(
                    color: v.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(item.emoji,
                            style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(v.label,
                              style: pvFraunces(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w600,
                                  height: 1.15,
                                  color: v.fg)),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Text('At week $week, your ${_ord(tri)} trimester',
                          style: pvManrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: v.fg.withValues(alpha: 0.85))),
                      if (stageNote != null) ...[
                        const SizedBox(height: 10),
                        Text(stageNote.now,
                            style: pvManrope(
                                fontSize: 14,
                                height: 1.55,
                                color: p.ink1)),
                      ],
                    ],
                  ),
                ),

                // ---- the safety floor, immediately under the answer ------
                //
                // ⚠️ ABOVE EVERYTHING ELSE FOR THE TWO THAT NEED IT. Ice-
                // chewing and pica are not food questions; burying "mention
                // this to your doctor" under three sections of craving
                // explanation would be the app being calm at her expense.
                if (item.talkToDoctor) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: p.action.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 17, color: p.action),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                                'Worth telling your doctor at your next visit. '
                                'This one is often about iron, and iron is '
                                'easy to check and easy to fix.',
                                style: pvManrope(
                                    fontSize: 13.5,
                                    height: 1.55,
                                    fontWeight: FontWeight.w600,
                                    color: p.ink1)),
                          ),
                        ]),
                  ),
                ],

                // ---- 2 · WHY SHE WANTS IT ---------------------------------
                const SizedBox(height: 26),
                _H('Why you are craving it', p),
                _B(item.why.now, p),

                if (item.modification != null) ...[
                  const SizedBox(height: 24),
                  _H('How to have it safely', p),
                  _B(item.modification!.now, p),
                ],

                if (item.whenToAvoid != null) ...[
                  const SizedBox(height: 24),
                  _H('When to skip it', p),
                  _B(item.whenToAvoid!.now, p),
                ],

                // ---- 3 · WHAT INSTEAD -------------------------------------
                if (showAlternatives) ...[
                  const SizedBox(height: 24),
                  _H('If you would rather not risk it', p),
                  const SizedBox(height: 2),
                  for (final a in item.alternatives) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 8, right: 11),
                              decoration: BoxDecoration(
                                  color: p.ink3, shape: BoxShape.circle),
                            ),
                            Expanded(
                              child: Text(a.now,
                                  style: pvManrope(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: p.ink2)),
                            ),
                          ]),
                    ),
                  ],
                ],

                // ---- 4 · MAKE IT AT HOME ----------------------------------
                if (item.recipe != null) ...[
                  const SizedBox(height: 28),
                  _RecipeCard(recipe: item.recipe!, p: p),
                ],

                const SizedBox(height: 26),
                Text(
                    'General guidance for an ordinary pregnancy. If your own '
                    'doctor has told you something different about this food, '
                    'theirs is the answer.',
                    style:
                        pvManrope(fontSize: 12, height: 1.5, color: p.ink3)),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _ord(int t) =>
      switch (t) { 1 => 'first', 2 => 'second', _ => 'third' };
}

class _H extends StatelessWidget {
  const _H(this.text, this.p);
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: pvFraunces(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.25,
                letterSpacing: -0.3,
                color: p.ink1)),
      );
}

class _B extends StatelessWidget {
  const _B(this.text, this.p);
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Text(text,
      style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink2));
}

/// The home version — ingredients and steps, in place rather than behind a tap.
///
/// ⚠️ NOT A LINK TO THE RECIPES SECTION. These are four-line substitutions
/// whose whole job is to turn "no" into "yes" in the moment; sending her to
/// another screen to read five lines would lose most of the people it is for.
/// A real recipe with servings, nutrition and a video belongs in Recipes; this
/// is a workaround, and it belongs where the problem is.
class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.p});

  final CravingRecipe recipe;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(17, 16, 17, 18),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.soup_kitchen_outlined, size: 18, color: p.action),
            const SizedBox(width: 9),
            Text('MAKE IT AT HOME',
                style: pvManrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: p.action)),
          ]),
          const SizedBox(height: 11),
          Text(recipe.name.now,
              style: pvFraunces(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: p.ink1)),
          const SizedBox(height: 5),
          Text('${recipe.minutes} minutes',
              style: pvManrope(
                  fontSize: 12, fontWeight: FontWeight.w700, color: p.ink3)),
          if (recipe.note != null) ...[
            const SizedBox(height: 11),
            Text(recipe.note!.now,
                style: pvManrope(
                    fontSize: 13.5,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: p.ink2)),
          ],
          const SizedBox(height: 18),
          Text('YOU NEED',
              style: pvManrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: p.ink3)),
          const SizedBox(height: 8),
          for (final i in recipe.ingredients)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text('·  ${i.now}',
                  style:
                      pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
            ),
          const SizedBox(height: 16),
          Text('HOW',
              style: pvManrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: p.ink3)),
          const SizedBox(height: 8),
          for (int i = 0; i < recipe.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text('${i + 1}',
                          style: pvManrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: p.action)),
                    ),
                    Expanded(
                      child: Text(recipe.steps[i].now,
                          style: pvManrope(
                              fontSize: 13.5, height: 1.5, color: p.ink2)),
                    ),
                  ]),
            ),
        ]),
      );
}
