// =============================================================================
//  JourneyBackdropPainter  —  the "map" behind the trail
// -----------------------------------------------------------------------------
//  Soft, full-width trimester regions (peach / lavender / mint) stacked top to
//  bottom, with a warm arrival glow near Birth, so the canvas reads like a
//  gentle map rather than a bare line. Band boundaries are passed in as y-pixels
//  (computed from where weeks 13 → 14 and 27 → 28 fall on the winding trail).
// =============================================================================

import 'package:flutter/material.dart';

/// One trimester region: a vertical slice [top]‥[bottom] painted with [fill].
class TrimesterBand {
  const TrimesterBand({required this.top, required this.bottom, required this.fill});
  final double top;
  final double bottom;
  final Color fill;
}

class JourneyBackdropPainter extends CustomPainter {
  JourneyBackdropPainter({required this.bands, this.arrivalCenter});

  final List<TrimesterBand> bands;

  /// If set, a warm golden glow is painted here (the journey's destination near
  /// Birth) so the end of the trail feels like an arrival, not just more trail.
  final Offset? arrivalCenter;

  static const double _inset = 2;
  static const double _gap = 5; // vertical breathing room between bands
  static const double _radius = 22;

  @override
  void paint(Canvas canvas, Size size) {
    // ---- Trimester regions -------------------------------------------------
    for (final band in bands) {
      final top = band.top + (band == bands.first ? 0 : _gap / 2);
      final bottom = band.bottom - (band == bands.last ? 0 : _gap / 2);
      if (bottom <= top) continue;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(_inset, top, size.width - _inset, bottom),
        const Radius.circular(_radius),
      );
      // Gentle top-to-bottom fade within each band so it feels lit, not flat.
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            band.fill.withValues(alpha: 0.85),
            band.fill.withValues(alpha: 0.45),
          ],
        ).createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);
    }

    // ---- Warm arrival glow at the destination ------------------------------
    final arrival = arrivalCenter;
    if (arrival != null) {
      final radius = size.width * 0.6;
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFE6A817).withValues(alpha: 0.26),
            const Color(0xFFEF6F8E).withValues(alpha: 0.10),
            const Color(0xFFEF6F8E).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: arrival, radius: radius));
      canvas.drawCircle(arrival, radius, glow);
    }
  }

  @override
  bool shouldRepaint(covariant JourneyBackdropPainter old) {
    if (old.arrivalCenter != arrivalCenter) return true;
    if (old.bands.length != bands.length) return true;
    for (int i = 0; i < bands.length; i++) {
      if (old.bands[i].top != bands[i].top ||
          old.bands[i].bottom != bands[i].bottom ||
          old.bands[i].fill != bands[i].fill) {
        return true;
      }
    }
    return false;
  }
}
