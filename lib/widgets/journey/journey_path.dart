// =============================================================================
//  JourneyPathPainter  —  draws the winding trail, split at "you are here"
// -----------------------------------------------------------------------------
//  Everything up to the current slot is GREEN (completed); everything after is
//  SOFT GREY (future). The two segments meet cleanly at currentIndex.
// =============================================================================

import 'package:flutter/material.dart';

import 'journey_geometry.dart';
import 'journey_palette.dart';

class JourneyPathPainter extends CustomPainter {
  JourneyPathPainter({required this.geometry, required this.currentIndex});

  final JourneyGeometry geometry;

  /// Fractional slot index of the mother's current position on the trail.
  final double currentIndex;

  static const double _stroke = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final count = geometry.count;
    if (count <= 0) return;

    // Sample finely across the whole index range for a smooth curve.
    final steps = (count - 1).clamp(1, 1000) * 24;
    final maxP = (count - 1).toDouble();

    final completed = Path();
    final future = Path();
    bool cStarted = false;
    bool fStarted = false;
    Offset? lastCompleted;

    for (int i = 0; i <= steps; i++) {
      final p = maxP * (i / steps);
      final pt = geometry.pointAtIndex(p);
      if (p <= currentIndex) {
        if (!cStarted) {
          completed.moveTo(pt.dx, pt.dy);
          cStarted = true;
        } else {
          completed.lineTo(pt.dx, pt.dy);
        }
        lastCompleted = pt;
      } else {
        if (!fStarted) {
          if (lastCompleted != null) {
            future.moveTo(lastCompleted.dx, lastCompleted.dy);
            future.lineTo(pt.dx, pt.dy);
          } else {
            future.moveTo(pt.dx, pt.dy);
          }
          fStarted = true;
        } else {
          future.lineTo(pt.dx, pt.dy);
        }
      }
    }

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawPath(future, stroke..color = JourneyColors.future);
    canvas.drawPath(completed, stroke..color = JourneyColors.completed);
  }

  @override
  bool shouldRepaint(covariant JourneyPathPainter old) =>
      old.currentIndex != currentIndex || old.geometry.size != geometry.size;
}
