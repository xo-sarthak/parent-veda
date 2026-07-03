// =============================================================================
//  JourneyPathPainter  —  the winding trail (design: white path + dotted line)
// -----------------------------------------------------------------------------
//  A single, confident trail: a soft shadow, a thick rounded WHITE path, and a
//  fine dotted lavender overlay on top (the design's "1 16" dashes). Calm and
//  premium — not a bright two-tone zig-zag. Progress is read from the nodes and
//  the "you are here" marker, not from the path colour.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'journey_geometry.dart';

class JourneyPathPainter extends CustomPainter {
  JourneyPathPainter({required this.geometry, required this.currentIndex});

  final JourneyGeometry geometry;

  /// Kept so the painter repaints when the mother's position shifts.
  final double currentIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final count = geometry.count;
    if (count <= 0) return;

    // One smooth path across the whole trail (fine sampling of the curve).
    final steps = (count - 1).clamp(1, 1000) * 24;
    final maxP = (count - 1).toDouble();
    final trail = Path();
    for (int i = 0; i <= steps; i++) {
      final p = maxP * (i / steps);
      final pt = geometry.pointAtIndex(p);
      if (i == 0) {
        trail.moveTo(pt.dx, pt.dy);
      } else {
        trail.lineTo(pt.dx, pt.dy);
      }
    }

    // 1 · soft shadow for gentle depth on the lavender canvas.
    canvas.drawPath(
      trail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0x122D144C)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // 2 · thick rounded white base (design's 20px white path).
    canvas.drawPath(
      trail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white
        ..isAntiAlias = true,
    );

    // 3 · fine dotted overlay (design's "1 16" dashes → round dots), split so
    //     the road AHEAD of the current node (toward Birth) reads a touch
    //     lighter than the path already PASSED.
    final double ci = currentIndex.clamp(0.0, maxP).toDouble();
    void drawDots(Path path, Color color) {
      final dot = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = color
        ..isAntiAlias = true;
      for (final metric in path.computeMetrics()) {
        double d = 0;
        while (d < metric.length) {
          canvas.drawPath(metric.extractPath(d, d + 1.5), dot);
          d += 15.5; // 1.5 dot + 14 gap
        }
      }
    }

    Path subPath(double from, double to) {
      final path = Path();
      final segSteps = ((to - from).abs() * 24).ceil().clamp(1, 4000);
      for (int i = 0; i <= segSteps; i++) {
        final p = from + (to - from) * (i / segSteps);
        final pt = geometry.pointAtIndex(p);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      return path;
    }

    drawDots(subPath(0, ci), const Color(0xFFD8C9EE)); // ahead — lighter
    drawDots(subPath(ci, maxP), AppTheme.primary200); // passed — normal
  }

  @override
  bool shouldRepaint(covariant JourneyPathPainter old) =>
      old.currentIndex != currentIndex || old.geometry.size != geometry.size;
}
