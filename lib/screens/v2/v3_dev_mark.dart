// =============================================================================
//  V3DevMark — one drawn mark per development area
// -----------------------------------------------------------------------------
//  The child snapshot on the parenting home was the last place on that screen
//  still using Material glyphs — `psychology_outlined`, `chat_bubble_outline`,
//  `directions_run`, `back_hand_outlined`. Four bought icons sitting directly
//  under eleven drawn ones, which is exactly the seam that makes an app read as
//  assembled from parts rather than designed.
//
//  Same vocabulary as `v3_bracket_art.dart` and the door marks: ONE FILLED
//  FOCAL SHAPE in the area's own hue, detail KNOCKED OUT IN WHITE rather than
//  laid on in a second colour, and every tone DERIVED from the accent so the
//  set stays coherent when the palette moves.
//
//  ⚠️ NO HALO HERE, unlike the bracket marks. These sit inside a 34dp rounded
//  square that is already tinted with the same accent at 14% — the container is
//  the halo. Drawing a second one inside it produced a muddy double-ring in the
//  first render, because two soft circles at similar alpha read as a smudge
//  rather than as depth.
//
//  ⚠️ AND THE SIZE IS THE REAL CONSTRAINT. These are drawn for a 34dp box —
//  half the bracket marks' 73dp and a third of the door marks' 110dp. At 34dp a
//  shape gets ONE idea and no interior detail at all: a brain with folds is a
//  grey smudge, a hand with five fingers is a paw. Every mark below is the
//  simplest silhouette that still names the thing.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One per entry in `kDevAreas`. Six exist; the home snapshot shows four.
enum DevMark { brain, language, physical, hands, emotional, social }

/// Maps a `DevArea.id` to its mark.
///
/// Returns null rather than a default for an unknown id — a new development
/// area should show nothing until someone draws it, because a wrong mark is
/// read as information and a missing one is read as missing.
DevMark? devMarkFor(String areaId) => switch (areaId) {
      'cognitive' => DevMark.brain,
      'language' => DevMark.language,
      'gross_motor' => DevMark.physical,
      'fine_motor' => DevMark.hands,
      'emotional' => DevMark.emotional,
      'social' => DevMark.social,
      _ => null,
    };

class V3DevMark extends StatelessWidget {
  const V3DevMark(
      {super.key, required this.mark, required this.accent, this.size = 34});

  final DevMark mark;

  /// The area's own colour, straight off `DevArea.accent`. Everything is
  /// derived from it, so the mark and the tint behind it can never disagree.
  final Color accent;

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _DevPainter(mark, devMarkSeed(accent))),
      );
}

/// Deepened rather than used raw: the accents are chosen to work as a 14% wash
/// behind the mark, so at full strength several of them are too pale to hold a
/// shape against their own tint.
///
/// Public because a preview harness has to derive the same colour the widget
/// does — the six door marks shipped as grey lumps precisely because the
/// preview and the screen disagreed about one paint.
Color devMarkSeed(Color accent) {
  final h = HSLColor.fromColor(accent);
  return h
      .withSaturation(math.max(h.saturation, 0.42))
      .withLightness(0.44)
      .toColor();
}

/// Draws a mark straight onto a canvas at `size`, without a widget tree.
///
/// The widget above is a thin wrapper over this, so anything a preview renders
/// is by construction what ships.
void paintDevMark(Canvas canvas, DevMark mark, Color accent, double size) =>
    _DevPainter(mark, devMarkSeed(accent)).paint(canvas, Size(size, size));

class _DevPainter extends CustomPainter {
  _DevPainter(this.mark, this.seed);

  final DevMark mark;
  final Color seed;

  @override
  void paint(Canvas canvas, Size size) {
    // Authored in a 100x100 box and scaled uniformly — the same discipline the
    // other two art files use, so a mark can be moved between them without
    // being redrawn.
    final side = math.min(size.width, size.height);
    final s = side / 100;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(s);

    final obj = Paint()..color = seed.withValues(alpha: 0.92);
    final cut = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    Paint stroke(double w) => Paint()
      ..color = seed.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (mark) {
      // ---- BRAIN ------------------------------------------------------------
      // A filled lobe with two white grooves. Not a two-hemisphere brain: at
      // this size the centre line eats the shape and what is left reads as a
      // walnut.
      case DevMark.brain:
        // ⚠️ ONE PATH, NOT FOUR SHAPES. The first cut drew the bumps as
        // separate circles over a body, and because every shape is painted at
        // 92% rather than 100%, each overlap composited twice and showed as a
        // darker seam — the blob came out looking quilted. Sub-paths inside a
        // single Path with the default non-zero fill render as a true union and
        // are filled once.
        //
        // It also came out as a LEAF on the first render: a smooth lobe plus a
        // stem is a leaf, and the two sparse grooves read as a midrib. The
        // bumps are what make it a brain, so they are the whole mark now and
        // the stem is gone.
        final lobe = Path()
          ..addOval(const Rect.fromLTRB(20, 24, 52, 56))
          ..addOval(const Rect.fromLTRB(40, 18, 74, 52))
          ..addOval(const Rect.fromLTRB(58, 32, 84, 58))
          ..addRRect(RRect.fromRectAndRadius(
              const Rect.fromLTRB(22, 40, 82, 80), const Radius.circular(20)));
        canvas.drawPath(lobe, obj);
        // One groove, not two. At 34dp a second line is noise, and the single
        // curve is what says "folded" rather than "solid".
        cut.strokeWidth = 6;
        canvas.drawPath(
            Path()
              ..moveTo(36, 44)
              ..cubicTo(54, 48, 46, 60, 64, 64),
            cut);

      // ---- LANGUAGE ---------------------------------------------------------
      // A speech bubble with a tail. The most literal mark in the set, and
      // correctly so: language is the one area whose everyday symbol is
      // unambiguous, and inventing a subtler one would only cost legibility.
      case DevMark.language:
        final bubble = Path()
          ..addRRect(RRect.fromRectAndRadius(
              const Rect.fromLTRB(16, 22, 84, 68), const Radius.circular(17)))
          ..moveTo(34, 66)
          ..lineTo(30, 86)
          ..lineTo(52, 66)
          ..close();
        canvas.drawPath(bubble, obj);
        // Three dots: speech in progress, not a finished sentence.
        for (final x in [36.0, 50.0, 64.0]) {
          canvas.drawCircle(
              Offset(x, 45), 5, Paint()..color = Colors.white.withValues(alpha: 0.92));
        }

      // ---- PHYSICAL ---------------------------------------------------------
      // A figure mid-stride. ⚠️ NOT the stepping stones — those are already the
      // `steps` bracket mark, and one shape must not mean two things.
      case DevMark.physical:
        canvas.drawCircle(const Offset(56, 22), 11, obj);
        canvas.drawPath(
            Path()
              ..moveTo(54, 36)
              ..lineTo(46, 58),
            stroke(10));
        // Legs, opened wide enough to read as movement rather than standing.
        canvas.drawPath(
            Path()
              ..moveTo(47, 56)
              ..lineTo(58, 72)
              ..lineTo(56, 88),
            stroke(9));
        canvas.drawPath(
            Path()
              ..moveTo(47, 57)
              ..lineTo(30, 70)
              ..lineTo(20, 82),
            stroke(9));
        // One arm only. Two arms at this weight closes the silhouette into a
        // blob; one keeps the diagonal readable.
        canvas.drawPath(
            Path()
              ..moveTo(52, 42)
              ..lineTo(72, 48),
            stroke(8));

      // ---- HANDS ------------------------------------------------------------
      // A palm with three fingers and a thumb. Four fingers is anatomically
      // right and visually wrong: at 34dp the gaps close and it becomes a paw.
      case DevMark.hands:
        // Same single-path union as the brain, for the same double-composite
        // reason — and here it matters twice over, because the thumb crosses
        // the palm and a seam right there is what made the first render read as
        // a mitten with a stripe.
        final hand = Path()
          ..addRRect(RRect.fromRectAndRadius(
              const Rect.fromLTRB(34, 44, 78, 88), const Radius.circular(15)));
        // Three fingers, not four. Anatomically wrong and visually right: at
        // 34dp a fourth gap closes and the hand becomes a paw. Gaps of 4 units
        // rather than 2 — at the shipped size 2 units is under half a pixel and
        // the fingers fused into a slab.
        for (final x in [37.0, 52.0, 67.0]) {
          hand.addRRect(RRect.fromRectAndRadius(
              Rect.fromLTRB(x, 18, x + 11, 56), const Radius.circular(5.5)));
        }
        // The thumb — the one shape that separates a hand from a comb, so it
        // has to CLEAR the palm rather than sit inside it. It was invisible in
        // the first render for exactly that reason.
        final thumb = Matrix4.identity()
          ..translateByDouble(13.0, 80.0, 0, 1)
          ..rotateZ(-0.55);
        hand.addPath(
            Path()
              ..addRRect(RRect.fromRectAndRadius(
                  const Rect.fromLTWH(0, 0, 30, 14),
                  const Radius.circular(7))),
            Offset.zero,
            matrix4: thumb.storage);
        canvas.drawPath(hand, obj);

      // ---- EMOTIONAL --------------------------------------------------------
      // A heart, geometric rather than decorative — two circles and a point,
      // which is what keeps it from reading as an emoji.
      case DevMark.emotional:
        final heart = Path()
          ..moveTo(50, 82)
          ..cubicTo(14, 58, 18, 30, 34, 26)
          ..cubicTo(44, 23, 50, 32, 50, 38)
          ..cubicTo(50, 32, 56, 23, 66, 26)
          ..cubicTo(82, 30, 86, 58, 50, 82)
          ..close();
        canvas.drawPath(heart, obj);

      // ---- SOCIAL -----------------------------------------------------------
      // Two figures, one smaller and slightly behind. A parent and a child, not
      // two peers — the relationship this area is actually about.
      case DevMark.social:
        final back = Paint()..color = seed.withValues(alpha: 0.45);
        canvas.drawCircle(const Offset(34, 34), 14, back);
        canvas.drawPath(
            Path()
              ..addRRect(RRect.fromRectAndCorners(
                const Rect.fromLTRB(14, 52, 54, 84),
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
              )),
            back);
        canvas.drawCircle(const Offset(66, 44), 11, obj);
        canvas.drawPath(
            Path()
              ..addRRect(RRect.fromRectAndCorners(
                const Rect.fromLTRB(50, 58, 86, 84),
                topLeft: const Radius.circular(17),
                topRight: const Radius.circular(17),
              )),
            obj);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_DevPainter old) => old.mark != mark || old.seed != seed;
}
