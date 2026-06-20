// =============================================================================
//  JourneyGeometry  —  the winding-trail maths (sequence-of-stops layout)
// -----------------------------------------------------------------------------
//  Each stop on the trail gets its own vertical slot (collision-free, even when
//  several milestones share a week). The path winds left/right via a sine of the
//  continuous slot index, so markers at integer indices sit exactly ON the trail.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class JourneyGeometry {
  JourneyGeometry({
    required this.size,
    required this.count,
    double? amplitude,
    this.lanePhase = math.pi / 2,
    this.topPad = 40,
    this.bottomPad = 70,
  }) : amplitude = amplitude ?? (size.width * 0.12);

  /// The full canvas the trail is drawn into.
  final Size size;

  /// Number of stops on the trail.
  final int count;

  /// Horizontal swing from the centre line, in pixels.
  final double amplitude;

  /// Radians of phase advance per slot (π/2 → gentle center→right→center→left).
  final double lanePhase;

  /// Vertical breathing room at the very top / bottom of the trail.
  final double topPad;
  final double bottomPad;

  double get _centerX => size.width / 2;

  double get slotHeight =>
      count <= 1 ? 0 : (size.height - topPad - bottomPad) / (count - 1);

  /// The point on the trail at a (possibly fractional) slot index [p].
  Offset pointAtIndex(double p) {
    final y = topPad + p * slotHeight;
    final x = _centerX + amplitude * math.sin(p * lanePhase);
    return Offset(x, y);
  }

  /// Total canvas height needed for [count] stops at [perSlot] spacing.
  static double heightFor(int count, double perSlot,
      {double topPad = 40, double bottomPad = 70}) {
    final slots = count <= 1 ? 0 : count - 1;
    return topPad + slots * perSlot + bottomPad;
  }
}
