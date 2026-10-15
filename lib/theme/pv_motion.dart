// The app's motion tokens (DESIGN-SYSTEM §2.6).
//
// Until 2026-10-15 every duration was typed where it was used (120 ms here,
// 320 ms there). These are the shared ones; new motion reads from here so a
// "make it feel calmer" pass is one file, not a grep.
import 'package:flutter/animation.dart';

class PvMotion {
  PvMotion._();

  /// A press settling under the finger (PvPress).
  static const Duration press = Duration(milliseconds: 120);

  /// Something arriving: a toast, a card rising into place.
  static const Duration enter = Duration(milliseconds: 360);

  /// Something leaving. Faster than arriving, always: the eye has already
  /// moved on, so the exit should not hold it.
  static const Duration exit = Duration(milliseconds: 200);

  /// Words or content swapping inside a surface that stays put.
  static const Duration swap = Duration(milliseconds: 180);

  /// A surface resizing to fit new content.
  static const Duration resize = Duration(milliseconds: 220);

  /// Arrival with a small settle: overshoots by a few percent and comes back.
  /// `Curves.easeOutBack` overshoots ~10%, which reads as a bounce; this one
  /// is closer to how iOS and Linear toasts land.
  static const Curve settle = Cubic(0.34, 1.36, 0.64, 1);

  /// Plain arrival with no overshoot (fades, resizes).
  static const Curve arrive = Curves.easeOutCubic;

  /// Leaving.
  static const Curve leave = Curves.easeInCubic;
}
