// =============================================================================
//  V3DailyArt — the same drawn language, at row scale
// -----------------------------------------------------------------------------
//  The six doors got filled shapes with a halo and their own hue, and it worked.
//  These are the two places on the page that still had bare line icons: the four
//  journal verbs and the medicine rows.
//
//  WHY A SECOND FILE RATHER THAN MORE ENTRIES IN V2Mark. The door marks are
//  authored for a 110dp tile; these live in a 44–50px well. That is not a scale
//  factor, it is a different drawing problem — at 44px a shape has room for one
//  idea and no interior detail, so the book's two pages or the scan strip's
//  three frames would turn to mush. Sharing an enum would have invited someone
//  to reuse a door mark in a row, which is the mistake the separation prevents.
//
//  WHAT IS SHARED, and must stay shared, or these stop looking like one app:
//    · One filled focal shape in the well's own hue at full strength.
//    · A soft halo behind it — no ground band, no horizon. See the note in
//      v2_block_art.dart for why the landscape came out.
//    · Colour derived from the tint, never passed in as a constant, so all four
//      palette directions stay coherent for free.
//    · Detail in white knocked out of the fill, never a second colour on top.
//
//  Authored in a 100x100 box and centred, same as the doors.
// =============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum V3DailyMark { memory, note, photo, voice, capsule }

/// A mark in a tinted well. [tint] is the well's pastel; everything else is
/// derived from it.
class V3DailyArt extends StatelessWidget {
  const V3DailyArt({super.key, required this.mark, required this.tint});

  final V3DailyMark mark;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final h = HSLColor.fromColor(tint);
    // Same fixed saturation/lightness as the doors — the controlled-pastel rule
    // one step darker. Hue varies, nothing else does.
    final seed = h.withSaturation(0.46).withLightness(0.46).toColor();
    return CustomPaint(painter: _DailyPainter(mark, seed), size: Size.infinite);
  }
}

class _DailyPainter extends CustomPainter {
  _DailyPainter(this.mark, this.seed);

  final V3DailyMark mark;
  final Color seed;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final s = side / 100;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);

    final obj = Paint()..color = seed.withValues(alpha: 0.92);
    final cut = Paint()..color = Colors.white.withValues(alpha: 0.86);

    // The halo, on every mark. It is what the set shares now that the ground
    // band is gone — atmosphere rather than a floor.
    canvas.drawCircle(
      Offset(50 * s, 50 * s),
      40 * s,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(50 * s, 50 * s),
          40 * s,
          [seed.withValues(alpha: 0.16), seed.withValues(alpha: 0.0)],
          [0.3, 1.0],
        ),
    );

    switch (mark) {
      // A page with two written lines knocked out of it. Not a pen: a pen at
      // 44px is a diagonal stick, and a diagonal stick is not legible as
      // anything.
      case V3DailyMark.memory:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(24 * s, 18 * s, 52 * s, 64 * s),
              Radius.circular(7 * s)),
          obj,
        );
        for (final y in const [38.0, 52.0, 66.0]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(35 * s, y * s, y == 66.0 ? 20 * s : 30 * s, 5 * s),
                Radius.circular(2.5 * s)),
            cut,
          );
        }

      // A heart, drawn as two lobes and a point rather than with cubics —
      // simpler curves hold their shape better when they are 30px across.
      case V3DailyMark.note:
        final p = Path()
          ..moveTo(50 * s, 78 * s)
          ..cubicTo(14 * s, 54 * s, 22 * s, 22 * s, 50 * s, 36 * s)
          ..cubicTo(78 * s, 22 * s, 86 * s, 54 * s, 50 * s, 78 * s)
          ..close();
        canvas.drawPath(p, obj);

      // A frame with a hill and a sun inside it, both knocked out. The most
      // literal of the four on purpose — "add a photo" has to be unmistakable
      // because it is the only one that opens the camera.
      case V3DailyMark.photo:
        final frame = Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromLTWH(16 * s, 24 * s, 68 * s, 52 * s),
              Radius.circular(9 * s)));
        final hill = Path()
          ..moveTo(24 * s, 72 * s)
          ..quadraticBezierTo(40 * s, 46 * s, 56 * s, 72 * s)
          ..close();
        final sun = Path()
          ..addOval(Rect.fromCircle(
              center: Offset(66 * s, 42 * s), radius: 7 * s));
        canvas.drawPath(
          Path.combine(PathOperation.difference,
              Path.combine(PathOperation.difference, frame, hill), sun),
          obj,
        );

      // Five bars at different heights: a voice, not a microphone. A microphone
      // is a device; the bars are the sound, which is what she is leaving.
      case V3DailyMark.voice:
        const hs = [26.0, 44.0, 60.0, 38.0, 20.0];
        for (var i = 0; i < hs.length; i++) {
          final hh = hs[i] * s;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                  (24 + i * 13) * s, 50 * s - hh / 2, 7 * s, hh),
              Radius.circular(3.5 * s),
            ),
            obj,
          );
        }

      // A capsule on the diagonal with the seam knocked out. Reads as medicine
      // at any size and, unlike a pill bottle, does not read as a container of
      // something we are selling.
      case V3DailyMark.capsule:
        canvas.save();
        canvas.translate(50 * s, 50 * s);
        canvas.rotate(-math.pi / 4);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: 34 * s, height: 62 * s),
              Radius.circular(17 * s)),
          obj,
        );
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero, width: 34 * s, height: 3.5 * s),
            cut);
        canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_DailyPainter old) =>
      old.mark != mark || old.seed != seed;
}
