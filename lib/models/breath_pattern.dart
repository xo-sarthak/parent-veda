// =============================================================================
//  BreathPattern — one breath cycle, as the shared circle reads it
// -----------------------------------------------------------------------------
//  ⚠️ THE THIRD MODEL FOR THE SAME THING, AND THE ONE THE OTHERS CONVERT TO.
//
//  Three areas each grew a breathing circle with its own phase model: Garbh's
//  `BreathPhase(label, seconds, scale)`, Mind & mood's `MmBreathPhase(label,
//  seconds, action)`, TTC's `TtcBreathAnim(inhale, hold, exhale, holdEmpty)`.
//  All three describe a circle that grows, holds, shrinks, maybe rests. The
//  Garbh pillars brief asks for ONE component — *"build it once and reuse it
//  everywhere breath appears"* — and one component needs one input.
//
//  ⚠️ THE AREA MODELS STAY. Each is persisted nowhere but is referenced by
//  data files and tests in its own area, and a model rename across three
//  stages for a widget's convenience is the kind of diff that loses a Hindi
//  label. Each area converts to this in one function; see `toBreathPattern`
//  in the three data files.
//
//  ⚠️ `at()` IS THE WHOLE ENGINE. Given elapsed seconds it says which step,
//  how far through it, and the count. A stateless widget can then draw any
//  moment of any pattern, which is what lets three screens with three kinds
//  of session logic (loop until Finish; a chosen duration; a ring with a
//  stopwatch) share the drawing without sharing the session.
// =============================================================================

/// What the circle does during a step.
enum BreathKind {
  /// Grows: the in-breath.
  expand,

  /// Stays large: held after the in-breath.
  hold,

  /// Shrinks: the out-breath.
  contract,

  /// Stays small: rested after the out-breath.
  holdEmpty,
}

/// One step of a cycle.
class BreathStep {
  const BreathStep(this.label, this.seconds, this.kind)
      : assert(seconds > 0, 'a zero-length step is no step; omit it');

  /// The word on screen — "Breathe in", "Hold", "Hum out softly".
  final String label;
  final int seconds;
  final BreathKind kind;
}

/// Where in a pattern an elapsed time falls.
class BreathMoment {
  const BreathMoment({
    required this.index,
    required this.within,
    required this.count,
    required this.cycle,
  });

  /// Index into [BreathPattern.steps].
  final int index;

  /// 0..1 through that step.
  final double within;

  /// The live count: seconds into the step, 1-based, the way a person counts
  /// a breath — "one, two, three, four".
  final int count;

  /// Which cycle this is, 1-based.
  final int cycle;
}

/// A cycle of steps, repeated for as long as a session runs.
class BreathPattern {
  const BreathPattern(this.steps);
  final List<BreathStep> steps;

  int get cycleSeconds => steps.fold(0, (a, s) => a + s.seconds);

  /// The moment [elapsed] seconds in. Wraps, so a session of any length works.
  BreathMoment at(double elapsed) {
    final cycleLen = cycleSeconds;
    final e = elapsed < 0 ? 0.0 : elapsed;
    final cycle = (e / cycleLen).floor() + 1;
    var p = e % cycleLen;
    for (var i = 0; i < steps.length; i++) {
      final s = steps[i];
      if (p < s.seconds || i == steps.length - 1) {
        final within = (p / s.seconds).clamp(0.0, 1.0);
        return BreathMoment(
          index: i,
          within: within,
          count: p.floor() + 1,
          cycle: cycle,
        );
      }
      p -= s.seconds;
    }
    // Unreachable: the last step catches everything.
    return BreathMoment(index: 0, within: 0, count: 1, cycle: cycle);
  }

  /// The size of the circle, 0..1, at a moment. Eased, so the edges of a
  /// breath are soft rather than mechanical.
  static double scaleAt(BreathStep step, double within) {
    final t = _easeInOut(within);
    return switch (step.kind) {
      BreathKind.expand => t,
      BreathKind.hold => 1,
      BreathKind.contract => 1 - t,
      BreathKind.holdEmpty => 0,
    };
  }

  static double _easeInOut(double t) =>
      t < 0.5 ? 2 * t * t : 1 - (-2 * t + 2) * (-2 * t + 2) / 2;
}
