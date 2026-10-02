// =============================================================================
//  Garbh Sanskar's four pillar marks (2026-10-02)
// -----------------------------------------------------------------------------
//  The daily screens drew an emoji for the practice (a raga's 🎵, a breath's 🌿,
//  a heart) in a tinted square. The app has stopped using emoji, so each pillar
//  has a drawn mark in the one family the rest of the app uses
//  (`TtcTabPainter`): a tinted disc, a deep ink, a soft ink, and the family's
//  line weights. They are also the marks the daily rows can wear later.
//
//      shravan  five bars of sound, a waveform she is listening to
//      samvad   a speech bubble with a heart in it: speaking to the baby
//      buddhi   a 2 by 2 of pieces with one still to place: a quiet puzzle
//      kriya    breath: three rings widening from a point
//
//  Decorative: the pillar's name is always beside them (`ExcludeSemantics`).
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ttc/doors/ttc_tab_art.dart' show TtcTabPainter, ttcTabGround, ttcTabInk;
import '../v2/v2_palette.dart' show V2PaletteStore, v2BlockTint;

/// The door's hue: every pillar screen sits on the Garbh Sanskar door's tint.
const double kGarbhHue = 42;

Widget garbhPillarMark(String pillarId, {double size = 52}) => ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: GarbhPillarMarkPainter(
            pillarId,
            v2BlockTint(kGarbhHue % 360, V2PaletteStore.instance.current),
          ),
        ),
      ),
    );

class GarbhPillarMarkPainter extends CustomPainter {
  GarbhPillarMarkPainter(this.id, this.tint);

  final String id;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    if (side <= 0) return;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);

    final groundC = ttcTabGround(tint);
    final inkC = ttcTabInk(tint);
    final ink = Paint()..color = inkC;
    final soft = Paint()..color = inkC.withValues(alpha: 0.32);
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final line = stroke(inkC, TtcTabPainter.kLine);
    final lineSoft = stroke(inkC.withValues(alpha: 0.32), TtcTabPainter.kLine);
    RRect rr(double l, double t, double r, double b, [double rad = 8]) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

    canvas.drawCircle(const Offset(50, 50), 46, Paint()..color = groundC);

    switch (id) {
      case 'shravan':
        // Five bars of sound, tallest in the middle.
        const heights = [22.0, 40.0, 58.0, 40.0, 22.0];
        for (var i = 0; i < 5; i++) {
          final x = 24.0 + i * 13.0;
          final h = heights[i];
          canvas.drawRRect(
              rr(x - 4, 50 - h / 2, x + 4, 50 + h / 2, 4), i == 2 ? ink : soft);
        }
        canvas.drawLine(const Offset(24, 82), const Offset(76, 82), lineSoft);

      case 'samvad':
        // A speech bubble with its tail, and a heart inside it.
        canvas.drawPath(
            Path()
              ..addRRect(rr(18, 20, 82, 66, 16))
              ..moveTo(34, 64)
              ..lineTo(30, 84)
              ..lineTo(52, 66)
              ..close(),
            ink);
        final heart = Path()
          ..moveTo(50, 56)
          ..cubicTo(32, 46, 38, 32, 46, 34)
          ..cubicTo(49, 35, 50, 38, 50, 38)
          ..cubicTo(50, 38, 51, 35, 54, 34)
          ..cubicTo(62, 32, 68, 46, 50, 56)
          ..close();
        canvas.drawPath(heart, Paint()..color = groundC);

      case 'buddhi':
        // Pieces in a 2 by 2, the last one still to place.
        canvas.drawRRect(rr(20, 20, 47, 47, 7), ink);
        canvas.drawRRect(rr(53, 20, 80, 47, 7), ink);
        canvas.drawRRect(rr(20, 53, 47, 80, 7), ink);
        canvas.drawRRect(rr(53, 53, 80, 80, 7), soft);
        canvas.drawRRect(
            rr(58, 58, 75, 75, 5), stroke(inkC.withValues(alpha: 0.55), TtcTabPainter.kDetail));

      case 'kriya':
      default:
        // Breath: a point and three rings widening from it.
        canvas.drawCircle(const Offset(50, 50), 7, ink);
        canvas.drawCircle(const Offset(50, 50), 17, line);
        canvas.drawCircle(const Offset(50, 50), 28, lineSoft);
        canvas.drawCircle(
            const Offset(50, 50), 38, stroke(inkC.withValues(alpha: 0.16), TtcTabPainter.kLine));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(GarbhPillarMarkPainter old) => old.id != id || old.tint != tint;
}
