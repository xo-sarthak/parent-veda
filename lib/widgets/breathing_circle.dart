// =============================================================================
//  PvBreathingCircle — the one breathing circle, drawn from a clock
// -----------------------------------------------------------------------------
//  Built for the Garbh Sanskar pillars brief, 12 Sep 2026: *"Build the
//  breathing as ONE reusable component: a circle that grows on the in-breath,
//  holds, shrinks on the out-breath, with the phase word ('Breathe in / Hold /
//  Breathe out') and a live count. This is the SAME component the Mind & body
//  preconception practice uses; build it once and reuse it everywhere breath
//  appears."*
//
//  ⚠️ THREE CIRCLES EXISTED WHEN THIS WAS WRITTEN. Garbh's `_BreathingScreen`
//  (an AnimationController per phase, looping until Finish), Mind & mood's
//  `MmBreathingScreen` (an async loop over phases with a chosen duration) and
//  TTC's `_Breath` in the practice player (a stopwatch, a ring, a square for
//  box breathing, a nostril side). Each was correct. Each drew a slightly
//  different circle, and a woman who used two areas met two breaths.
//
//  ⚠️ STATELESS, DRIVEN BY ELAPSED SECONDS — AND THAT IS WHAT MAKES IT
//  SHAREABLE. The three screens keep three kinds of session logic: loop until
//  she taps Finish; run for the duration she chose; run a stopwatch and draw a
//  progress ring around it. None of that is the circle's business. The circle
//  is handed a `BreathPattern` and a number of seconds and draws that moment.
//  A screen that owns a clock owns its session; a widget that owns a clock
//  owns nothing a screen can reason about. (`PvBreathTicker` below is the
//  clock for a screen that has none of its own.)
//
//  ⚠️ THE COUNT COUNTS UP. "One, two, three, four" is how a person counts a
//  breath; a countdown is how a timer counts a launch. Garbh's screen used to
//  count down — that changes with this, deliberately.
//
//  ⚠️ A SQUARE FOR BOX BREATHING. TTC's brief: *"this one is naturally a
//  square, not a circle"* — four equal phases on four equal sides, the shape
//  teaching the timing. Kept as a flag, because Garbh's box practice deserves
//  the same shape.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/breath_pattern.dart';
import '../theme/pv_fonts.dart';

class PvBreathingCircle extends StatelessWidget {
  const PvBreathingCircle({
    super.key,
    required this.pattern,
    required this.elapsed,
    required this.tint,
    required this.ink,
    this.running = true,
    this.square = false,
    this.size = 240,
    this.readyLabel = 'Ready',
    this.below,
  });

  final BreathPattern pattern;

  /// Seconds since the session began. Any value; the pattern wraps.
  final double elapsed;

  /// The fill; the word and count colour.
  final Color tint;
  final Color ink;

  /// False before she begins: the shape rests small and says [readyLabel].
  final bool running;
  final bool square;

  /// The box the shape breathes inside. The shape spans 62% to 100% of it.
  final double size;
  final String readyLabel;

  /// Anything a screen wants under the count — TTC's "Breath 3 of 10" and
  /// its nostril side. Drawn inside the shape so it moves with it.
  final Widget? below;

  /// The moment being drawn — exposed so a screen can read the same word.
  BreathMoment get moment => pattern.at(elapsed);

  @override
  Widget build(BuildContext context) {
    final m = moment;
    final step = pattern.steps[m.index];
    final scale = running ? BreathPattern.scaleAt(step, m.within) : 0.0;
    final side = size * (0.62 + 0.38 * scale);
    final word = running ? step.label : readyLabel;
    final count = running ? '${m.count}' : '';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        Container(
          width: side,
          height: side,
          decoration: BoxDecoration(
            shape: square ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: square ? BorderRadius.circular(size * 0.09) : null,
            gradient: RadialGradient(colors: [
              tint.withValues(alpha: 0.55),
              tint.withValues(alpha: 0.18),
            ]),
            border:
                Border.all(color: ink.withValues(alpha: 0.28), width: 1.4),
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(word,
                key: ValueKey(word),
                textAlign: TextAlign.center,
                style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: ink)),
          ),
          // ⚠️ THE COUNT LINE ONLY WHILE RUNNING (2026-09-28, launch walk
          // MB12): an empty 34pt line under "Ready" pushed the word into the
          // top third of the disc, which reads as a bug. Kept for revert: the
          // gap and the Text(count) drawn always.
          if (running) ...[
            const SizedBox(height: 4),
            Text(count,
                style: pvFraunces(
                    fontSize: 34, fontWeight: FontWeight.w600, color: ink)),
          ],
          if (below case final b?) ...[const SizedBox(height: 2), b],
        ]),
      ]),
    );
  }
}

/// A clock for a screen that has none: elapsed seconds while [running],
/// rebuilt every frame, reset to zero each time running turns on.
///
/// ⚠️ A TICKER, NOT A ONE-SECOND TIMER. The circle's size is a function of
/// the fraction through a step; at one tick a second it would jump in four
/// lurches per breath. TTC's player uses a 100 ms timer for the same reason
/// and keeps it; this exists for the two screens that had an
/// AnimationController and no clock of their own.
class PvBreathTicker extends StatefulWidget {
  const PvBreathTicker({
    super.key,
    required this.running,
    required this.builder,
    this.onTick,
  });

  final bool running;
  final Widget Function(BuildContext context, double elapsedSeconds) builder;

  /// Called once per frame with the elapsed seconds, for a screen that ends a
  /// session at a chosen length.
  final void Function(double elapsedSeconds)? onTick;

  @override
  State<PvBreathTicker> createState() => _PvBreathTickerState();
}

class _PvBreathTickerState extends State<PvBreathTicker>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  double _elapsed = 0;

  @override
  void initState() {
    super.initState();
    if (widget.running) _ticker.start();
  }

  @override
  void didUpdateWidget(PvBreathTicker old) {
    super.didUpdateWidget(old);
    if (widget.running && !old.running) {
      _elapsed = 0;
      _ticker.start();
    } else if (!widget.running && old.running) {
      _ticker.stop();
    }
  }

  void _tick(Duration d) {
    if (!mounted) return;
    setState(() => _elapsed = d.inMilliseconds / 1000);
    widget.onTick?.call(_elapsed);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _elapsed);
}
