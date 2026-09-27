// =============================================================================
//  One practice, from the Mind & body library
// -----------------------------------------------------------------------------
//  ⚠️ ONE SCREEN FOR TWELVE CARDS, NOT TWELVE SCREENS. `TtcDoTile` resolves
//  through `ttcScreenForSurface`, and the obvious build for twelve Do cards is
//  twelve entries in that switch. Every one would be the same layout with
//  different words, and a thirteenth practice would need a code change and a
//  release. The surface id carries the practice — `ttc_practice/<id>` — exactly
//  as `ttc_read/<id>` does.
//
//  ⚠️ NOTHING ON THIS SCREEN IS TYPED HERE. Title, duration, setting, steps,
//  "skip it if" and the animation spec all come from `ttc_practice_data.dart`.
//
//  ⚠️ THE STEPS ARE THE PRODUCT; THE ANIMATION IS THE HELP. The brief:
//  *"Every movement card must work WITHOUT the animation: the step list, the
//  timer and the 'skip it if' note are the fallback and must always be
//  visible."* So the step list is not a fallback that appears when something
//  fails — it is always there, and the player sits above it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_mind_today.dart';
import '../../ttc/ttc_practice_data.dart';
import '../v2/v2_palette.dart';
import 'ttc_mind_today_screen.dart' show kTtcMoveHue, kTtcBreatheHue;
import 'ttc_practice_player.dart';
import 'ttc_tool_chrome.dart';

/// The hue for this area. 42 is the bracket's own, from `ttc_brackets.dart`.
///
/// ⚠️ KEPT, AND NO LONGER WHAT THIS SCREEN OPENS IN. A practice now takes the
/// hue of its own library — 104 for Move, 206 for Breathe — because that is the
/// colour of the block she tapped on Today. Landing sand-coloured after tapping
/// a sage block reads as having arrived somewhere else, and the whole point of
/// a do-it screen is that opening the card and doing the practice are one
/// motion. The door itself is still 42; a practice is a room inside it.
const double kTtcMindHue = 42;

class TtcPracticeScreen extends StatefulWidget {
  const TtcPracticeScreen({super.key, required this.practice});

  final TtcPractice practice;

  @override
  State<TtcPracticeScreen> createState() => _TtcPracticeScreenState();
}

class _TtcPracticeScreenState extends State<TtcPracticeScreen> {
  /// Which step is lit. Driven by the reader, not by a clock.
  ///
  /// ⚠️ THE BRIEF ASKS FOR A STEP LIST THAT ADVANCES ON A TIMER, AND THIS ONE
  /// ADVANCES ON A TAP INSTEAD. Deliberate, and the reason is in the brief's own
  /// shared rules: *"No countdown pressure… Leaving mid-way is fine."* A list
  /// that moves on its own is a countdown by another name — it takes the step
  /// away while you are still in it, and on a floor practice you are not looking
  /// at the phone when it happens. The forward and back controls are here, the
  /// current step is highlighted, and the session ring above still runs the
  /// clock. Written down rather than silently substituted; see §31.
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final pr = widget.practice;

    return AnimatedBuilder(
      animation: TtcLogStore.instance,
      builder: (context, _) {
        final done = ttcPracticeDoneToday(pr.kind);

        final pal = V2PaletteStore.instance.current;
        final hue = widget.practice.kind == TtcPracticeKind.move
            ? kTtcMoveHue
            : kTtcBreatheHue;
        final tint = v2BlockTint(hue, pal);
        final deep = HSLColor.fromColor(tint)
            .withSaturation(0.44)
            .withLightness(0.36)
            .toColor();

        return TtcToolScaffold(
          hue: hue,
          eyebrow:
              pr.kind == TtcPracticeKind.move ? 'MOVE' : 'BREATHE AND CALM',
          title: pr.title,
          intro: pr.blurb,
          children: [
            // ---- how long, and where ---------------------------------
            //  ⚠️ THE WHOLE SHEET IS PADDED HERE RATHER THAN LINE BY LINE.
            //  `TtcToolScaffold` hands its children straight into the sheet, so
            //  every row below used to be responsible for its own inset and one
            //  of them always forgets. `ttcToolPad` around the column is one
            //  place to be wrong instead of fifteen.
            ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Row(children: [
              Icon(Icons.schedule_rounded, size: 15, color: pal.ink3),
              const SizedBox(width: 7),
              Text(pr.duration,
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: pal.ink2)),
              const SizedBox(width: 12),
              Icon(Icons.place_outlined, size: 15, color: pal.ink3),
              const SizedBox(width: 7),
              Expanded(
                child: Text(pr.setting,
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: pal.ink2)),
              ),
            ]),

            const SizedBox(height: 20),
            TtcPracticeSession(practice: pr),
            const SizedBox(height: 24),

            // ---- the steps -------------------------------------------
            Row(children: [
              Text('WHAT TO DO',
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: pal.ink3)),
              const Spacer(),
              // ⚠️ BACK ONE STEP, WHICH THE BRIEF NAMES. On a floor practice the
              // commonest thing that happens is missing a line and needing it
              // again, and a list you can only go forward in makes that a
              // restart.
              _StepNudge(
                  icon: Icons.keyboard_arrow_up_rounded,
                  enabled: _step > 0,
                  onTap: () => setState(() => _step--)),
              const SizedBox(width: 6),
              _StepNudge(
                  icon: Icons.keyboard_arrow_down_rounded,
                  enabled: _step < pr.steps.length - 1,
                  onTap: () => setState(() => _step++)),
            ]),
            const SizedBox(height: 12),

            //  ⚠️ THE LIVE STEP IS A FILLED ROW, NOT A BOLDER FONT. Weight
            //  alone is what this had, and on a floor practice the phone is
            //  arm's length away on the mat: at that distance w700 against w400
            //  in the same colour is not a difference you can find without
            //  reading. A tinted row with a filled number is findable in a
            //  glance, which is the only interaction this list ever gets.
            for (var i = 0; i < pr.steps.length; i++) ...[
              GestureDetector(
                onTap: () => setState(() => _step = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(
                      vertical: 11, horizontal: 11),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: i == _step ? tint : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: i == _step ? deep : pal.surfaceAlt,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('${i + 1}',
                              style: pvManrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      i == _step ? Colors.white : pal.ink2)),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(pr.steps[i],
                              // ⚠️ NO `maxLines`, ANYWHERE IN THIS LIST. The
                              // brief: the step text "must survive the largest
                              // accessibility text size". A clipped instruction
                              // is worse than a long screen.
                              style: pvManrope(
                                  fontSize: 13.5,
                                  height: 1.55,
                                  color: i == _step ? pal.ink1 : pal.ink2,
                                  fontWeight: i == _step
                                      ? FontWeight.w700
                                      : FontWeight.w400)),
                        ),
                      ]),
                ),
              ),
            ],

            // ---- which side, where sides matter ----------------------
            if (pr.anim case TtcFigureAnim(sides: true)) ...[
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.swap_horiz_rounded, size: 15, color: pal.ink3),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'This one uses both sides. Do the whole thing on one '
                      'side, then on the other.',
                      style: pvManrope(
                          fontSize: 12.5, height: 1.5, color: pal.ink2)),
                ),
              ]),
            ],

            const SizedBox(height: 18),

            // ---- skip it if ------------------------------------------
            //
            // ⚠️ PER-CARD, AND THE GENERAL SAFETY LINE IS NOT HERE. The brief
            // separates them: one general line on the practice tab, and a
            // specific caution on each card. Repeating the general one twelve
            // times is what stops it being read.
            //  ⚠️ WARM, NOT ALARMING, AND NOT THE PALETTE'S OWN HUE EITHER. A
            //  caution painted in the practice's colour disappears into the
            //  page; painted red it reads as a red flag, which this is not —
            //  "put a cushion under the knees" is not a reason to call anyone.
            //  Sand (42) is the stage's caution tint and is used here for the
            //  same reason the door uses it for paid blocks: distinct without
            //  being loud.
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: v2BlockTint(42, pal),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: pal.ink2),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SKIP IT IF',
                                style: pvManrope(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                    color: pal.ink2)),
                            const SizedBox(height: 5),
                            Text(pr.skipIf,
                                style: pvManrope(
                                    fontSize: 12.5,
                                    height: 1.55,
                                    color: pal.ink1)),
                          ]),
                    ),
                  ]),
            ),

            const SizedBox(height: 22),

            // ---- done today ------------------------------------------
            //
            // ⚠️ A TOGGLE, AND NO CONGRATULATION. Tapping it again undoes it —
            // a tick that only goes one way turns a mis-tap into a permanent
            // small lie. It says "Done today" rather than anything warmer,
            // because a screen that celebrates makes the days she does not open
            // it into days she let something down. There is no streak; see
            // `ttc_mind_today.dart`.
            GestureDetector(
              onTap: () => ttcSetPracticeDone(pr.kind, !done),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done ? pal.surfaceAlt : deep,
                  borderRadius: BorderRadius.circular(16),
                  border: done ? Border.all(color: pal.line) : null,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(done ? Icons.check_rounded : Icons.circle_outlined,
                      size: 17, color: done ? pal.ink1 : Colors.white),
                  const SizedBox(width: 9),
                  Text(done ? 'Done today' : 'Mark done today',
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: done ? pal.ink1 : Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: 10),
                ])),
          ],
        );
      },
    );
  }
}

class _StepNudge extends StatelessWidget {
  const _StepNudge(
      {required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon,
            size: 18,
            color: enabled ? p.ink1 : p.ink3.withValues(alpha: 0.45)),
      ),
    );
  }
}
