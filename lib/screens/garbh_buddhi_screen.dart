// =============================================================================
//  Buddhi - the fourth pillar, and the only one that is not for the baby
// -----------------------------------------------------------------------------
//  Shravan is what she hears. Samvad is what she says. Kriya is what her body
//  does. Buddhi is what her own mind does.
//
//  ⚠️ THIS IS NOT NEW CONTENT. It is content that already shipped and that
//  nobody could find. The four games were buried inside Vichara, a screen
//  whose other two tabs duplicated Shravan and Samvad, so the one genuinely
//  unique thing in it was reached through a door named after something else.
//  Promoting it and deleting the wrapper is the whole change.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THREE RULES THAT MAKE THIS PILLAR DIFFERENT FROM THE OTHER THREE
//  ---------------------------------------------------------------------------
//
//  1. IT MAKES NO CLAIM ABOUT THE BABY. Not one word here says puzzles make a
//     baby smarter, because there is no evidence for it and the claim is the
//     exact misinformation this product positions against. The "why" line says
//     what is actually true: this is focused calm and a break from pregnancy
//     anxiety, for her.
//
//  2. IT DOES NOT WRITE TO MY JOURNAL. The journal is the thing she is making
//     for her child; a sudoku is not that. Putting it in would dilute the one
//     artifact whose value depends on everything in it being for the baby.
//
//  3. IT IS OPTIONAL TO COMPLETE. A day reads as complete on the three
//     baby-facing practices alone. Requiring the one that is purely hers would
//     turn "some time for yourself" into a fourth obligation, which is how a
//     wellbeing feature becomes the thing she feels guilty about.
//
//  ⚠️ AND IT SERVES ONE THING, NOT A MENU - same shape as the other pillars.
//  Four tiles is a decision to make before she has done anything; one game
//  with the rest below the fold is a thing to start.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/garbh_data.dart';
import '../localization/app_language.dart';
import '../models/garbh_content.dart';
import '../services/pregnancy_controller.dart';
import '../theme/pv_fonts.dart';

const _accBuddhi = Color(0xFF7A6E9B); // muted indigo, its own place on the wheel
const _ink = Color(0xFF2E2A32);
const _muted = Color(0xFF8A8290);
const _ground = Color(0xFFFBF9F6);

class GarbhBuddhiScreen extends StatelessWidget {
  const GarbhBuddhiScreen({
    super.key,
    required this.controller,
    this.daily = false,
    this.onOpenPuzzle,
  });

  final PregnancyController controller;

  /// Daily mode serves today's rotation and shows the foot; library mode is
  /// the full set with no "today" framing, matching the other three pillars.
  final bool daily;

  /// How a puzzle is actually launched. Passed in rather than imported so this
  /// screen does not depend on the game widgets, which live in a 2,000-line
  /// file it has no other reason to reach into.
  final void Function(BuildContext, GarbhPuzzle)? onOpenPuzzle;

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final week = controller.currentWeek;
    // The rotation, so today's is stable within a day and moves between days.
    final today = kPuzzles.isEmpty
        ? null
        : kPuzzles[controller.currentDay % kPuzzles.length];

    return Scaffold(
      backgroundColor: _ground,
      appBar: AppBar(
        backgroundColor: _ground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _ink,
        title: Text(lang.isHindi ? 'बुद्धि' : 'Buddhi',
            style: pvFraunces(
                fontSize: 18, fontWeight: FontWeight.w600, color: _ink)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
          children: [
            // ---- the intent, stated before anything else -----------------
            Text('A few quiet minutes that are yours.',
                style: pvFraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: _ink)),
            const SizedBox(height: 8),
            Text(
                'Every other practice here is for your baby. This one is not.',
                style: pvManrope(fontSize: 13.5, height: 1.55, color: _muted)),
            const SizedBox(height: 22),

            // ---- the why line, in the same format as the other pillars ---
            //
            // ⚠️ AND HONEST ABOUT WHAT IT IS. The other three say what is
            // developing in the baby this week. This one cannot say that
            // without inventing a benefit, so it says what is true instead.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
              decoration: BoxDecoration(
                color: _accBuddhi.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WHY THIS',
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: _accBuddhi)),
                    const SizedBox(height: 7),
                    Text(
                        'Ten minutes of focused attention is one of the few '
                        'reliable ways to stop a worrying mind circling. It '
                        'will not make your baby cleverer, and nobody can '
                        'honestly tell you it will. It is here because '
                        'pregnancy is long and your head deserves a break '
                        'from it.',
                        style: pvManrope(
                            fontSize: 13.5, height: 1.6, color: _ink)),
                  ]),
            ),
            const SizedBox(height: 26),

            if (daily && today != null) ...[
              Text('TODAY',
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: _muted)),
              const SizedBox(height: 10),
              _PuzzleCard(
                puzzle: today,
                feature: true,
                onTap: () => onOpenPuzzle?.call(context, today),
              ),
              const SizedBox(height: 12),
              // ⚠️ NO "MARK COMPLETE". Completion fires when the puzzle is
              // finished or the session timer ends, same rule as every other
              // pillar in this section.
              Text(
                  'This finishes on its own when the puzzle is done. Skipping '
                  'it does not break your day.',
                  style: pvManrope(fontSize: 12, height: 1.5, color: _muted)),
              const SizedBox(height: 30),
              Text('MORE',
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: _muted)),
              const SizedBox(height: 10),
            ],

            for (final p in kPuzzles)
              if (!daily || p != today) ...[
                _PuzzleCard(
                    puzzle: p, onTap: () => onOpenPuzzle?.call(context, p)),
                const SizedBox(height: 10),
              ],

            const SizedBox(height: 22),
            // ⚠️ SAYING OUT LOUD THAT THIS ONE DOES NOT GO IN THE JOURNAL.
            // She will have watched three other practices land there, so its
            // absence needs an explanation or it reads as a bug.
            Text(
                'Nothing here goes into My Journal. That is for what you are '
                'making for your baby, and week $week of it is already there.',
                style: pvManrope(fontSize: 12, height: 1.55, color: _muted)),
          ],
        ),
      ),
    );
  }
}

class _PuzzleCard extends StatelessWidget {
  const _PuzzleCard(
      {required this.puzzle, required this.onTap, this.feature = false});

  final GarbhPuzzle puzzle;
  final VoidCallback onTap;
  final bool feature;

  @override
  Widget build(BuildContext context) => Material(
        color: feature ? _accBuddhi.withValues(alpha: 0.10) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 15, 14, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: feature
                      ? _accBuddhi.withValues(alpha: 0.35)
                      : const Color(0x14000000)),
            ),
            child: Row(children: [
              Text(puzzle.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(puzzle.title.now,
                          style: pvFraunces(
                              fontSize: feature ? 17 : 15.5,
                              fontWeight: FontWeight.w600,
                              color: _ink)),
                      const SizedBox(height: 4),
                      Text(puzzle.blurb.now,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 12.5, height: 1.4, color: _muted)),
                    ]),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: _muted),
            ]),
          ),
        ),
      );
}

/// Today's line for the daily card, so the card and this screen cannot drift.
LocalizedText buddhiTodayLine(int day) {
  if (kPuzzles.isEmpty) return const LocalizedText(en: '', hi: '');
  return kPuzzles[day % kPuzzles.length].title;
}
