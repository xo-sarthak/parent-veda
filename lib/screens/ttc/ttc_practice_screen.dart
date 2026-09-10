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
import 'ttc_common.dart';
import 'ttc_practice_player.dart';
import 'ttc_tool_chrome.dart';

/// The hue for this area. 42 is the bracket's own, from `ttc_brackets.dart`.
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
    final p = widget.practice;

    return AnimatedBuilder(
      animation: TtcLogStore.instance,
      builder: (context, _) {
        final done = ttcPracticeDoneToday(p.kind);

        return TtcToolScaffold(
          hue: kTtcMindHue,
          eyebrow: p.kind == TtcPracticeKind.move ? 'MOVE' : 'BREATHE AND CALM',
          title: p.title,
          intro: p.blurb,
          children: [
            // ---- how long, and where ---------------------------------
            Row(children: [
              const Icon(Icons.schedule_rounded, size: 15, color: ttcSoft),
              const SizedBox(width: 7),
              Text(p.duration,
                  style: ttcBody(13, color: ttcSoft, w: FontWeight.w700)),
              const SizedBox(width: 12),
              const Icon(Icons.place_outlined, size: 15, color: ttcSoft),
              const SizedBox(width: 7),
              Expanded(
                child: Text(p.setting,
                    style: ttcBody(13, color: ttcSoft, w: FontWeight.w700)),
              ),
            ]),

            const SizedBox(height: 20),
            TtcPracticeSession(practice: p),
            const SizedBox(height: 24),

            // ---- the steps -------------------------------------------
            Row(children: [
              Text('WHAT TO DO',
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: ttcMuted)),
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
                  enabled: _step < p.steps.length - 1,
                  onTap: () => setState(() => _step++)),
            ]),
            const SizedBox(height: 12),

            for (var i = 0; i < p.steps.length; i++) ...[
              GestureDetector(
                onTap: () => setState(() => _step = i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: i == _step ? ttcPurple : ttcPanel,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('${i + 1}',
                              style: ttcBody(11,
                                  color:
                                      i == _step ? Colors.white : ttcTitleInk,
                                  w: FontWeight.w800)),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(p.steps[i],
                              // ⚠️ NO `maxLines`, ANYWHERE IN THIS LIST. The
                              // brief: the step text "must survive the largest
                              // accessibility text size". A clipped instruction
                              // is worse than a long screen.
                              style: ttcBody(13.5,
                                  color: i == _step ? ttcTitleInk : ttcInk,
                                  h: 1.55,
                                  w: i == _step
                                      ? FontWeight.w700
                                      : FontWeight.w400)),
                        ),
                      ]),
                ),
              ),
            ],

            // ---- which side, where sides matter ----------------------
            if (p.anim case TtcFigureAnim(sides: true)) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.swap_horiz_rounded, size: 15, color: ttcSoft),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'This one changes sides. Do the whole thing on one side, '
                      'then the other.',
                      style: ttcBody(12.5, color: ttcSoft, h: 1.5)),
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ttcCoralTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: ttcBrown),
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
                                    color: ttcBrown)),
                            const SizedBox(height: 5),
                            Text(p.skipIf,
                                style:
                                    ttcBody(12.5, color: ttcBrown, h: 1.55)),
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
              onTap: () => ttcSetPracticeDone(p.kind, !done),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done ? ttcPanel : ttcPurple,
                  borderRadius: BorderRadius.circular(16),
                  border: done ? Border.all(color: ttcBorder) : null,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(done ? Icons.check_rounded : Icons.circle_outlined,
                      size: 17, color: done ? ttcTitleInk : Colors.white),
                  const SizedBox(width: 9),
                  Text(done ? 'Done today' : 'Mark done today',
                      style: ttcBody(14.5,
                          color: done ? ttcTitleInk : Colors.white,
                          w: FontWeight.w700)),
                ]),
              ),
            ),
            const SizedBox(height: 10),
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ttcPanel,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(icon,
              size: 18,
              color: enabled ? ttcTitleInk : ttcMuted.withValues(alpha: 0.5)),
        ),
      );
}
