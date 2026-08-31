// =============================================================================
//  Story skins — the colour language a story gets to have of its own
// -----------------------------------------------------------------------------
//  ⚠️ THIS DELIBERATELY IGNORES THE APP PALETTE, AND THAT IS THE WHOLE POINT.
//
//  The first attempt at "different colour backgrounds" took the section's hue
//  and washed it to 38% — a tint. The note back was exact:
//
//    "By colour change I did not mean slight tint. This does not have anything
//     to do with the app colour language."
//
//  And that is right. Everywhere else in this product, colour is subordinate:
//  the controlled-pastel wheel exists so that forty screens can carry a hue
//  each without any of them shouting, because they are all furniture around
//  content. A story is not furniture. It is the one place in the app that is
//  supposed to feel like a thing you are inside rather than a page you are on,
//  and a stage's own washed tint cannot do that — by construction, since it was
//  designed not to.
//
//  So a story gets saturated, full-bleed colour from its own palette. The rule
//  it still obeys is the only one that matters: nothing here is coral, because
//  coral is the period marker and means one thing in this stage.
//
//  ---------------------------------------------------------------------------
//  ⚠️ BANDS SEPARATED BY A CURVE, NOT A STRAIGHT SPLIT
//  ---------------------------------------------------------------------------
//
//  The reference divides each screen into two or three horizontal colour fields
//  with a soft wave between them. It is worth naming why that reads as designed
//  rather than as a gradient: a straight horizontal split reads as two boxes
//  stacked, which is a layout. A curve reads as one surface with a shape on it,
//  which is a picture. The curve is doing the same job a die-cut does on print.
//
//  The waves are derived from the slide index, so a story's slides differ from
//  each other but any one slide is identical every time it is drawn — a random
//  wave per build would shimmer on every rebuild.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The story palette. Saturated on purpose, and shared by every story so the
/// format has an identity of its own across the stage.
class TtcStoryPalette {
  const TtcStoryPalette._();

  static const teal = Color(0xFF0F6E62);
  static const rose = Color(0xFFFF5A7D);
  static const blush = Color(0xFFF9CBD5);
  static const cream = Color(0xFFFAF5EC);
  static const plum = Color(0xFF7C4457);
  static const sky = Color(0xFFBFDCE4);
  static const sand = Color(0xFFF3D9A4);
  static const ink = Color(0xFF17151A);
}

/// How one slide is coloured.
class TtcSlideSkin {
  const TtcSlideSkin({
    required this.top,
    required this.mid,
    required this.bottom,
    required this.onTop,
    required this.onMid,
    required this.onBottom,
    this.topFraction = 0.30,
    this.bottomFraction = 0.68,
  });

  final Color top;
  final Color mid;
  final Color bottom;

  final Color onTop;
  final Color onMid;
  final Color onBottom;

  /// Where the first wave sits, as a fraction of height.
  final double topFraction;

  /// Where the second wave sits. Equal to [topFraction] means two bands.
  final double bottomFraction;

  bool get twoBand => (bottomFraction - topFraction).abs() < 0.02;
}

/// ⚠️ A FIXED CYCLE, NOT A RANDOM PICK. Seven skins that look deliberate in
/// sequence — dark, light, hot, dark, light — so moving through a story feels
/// composed rather than shuffled. A palette chosen per slide at random produces
/// two adjacent teals about a fifth of the time, and that reads as a mistake.
const List<TtcSlideSkin> kTtcSlideSkins = [
  // 0 — the cover. One deep field, type reversed out of it.
  TtcSlideSkin(
    top: TtcStoryPalette.plum,
    mid: TtcStoryPalette.plum,
    bottom: TtcStoryPalette.plum,
    onTop: Colors.white,
    onMid: Colors.white,
    onBottom: Colors.white,
    topFraction: 0.99,
    bottomFraction: 0.99,
  ),

  // 1 — teal over cream over blush. The reference's signature slide.
  TtcSlideSkin(
    top: TtcStoryPalette.teal,
    mid: TtcStoryPalette.cream,
    bottom: TtcStoryPalette.blush,
    onTop: Colors.white,
    onMid: TtcStoryPalette.ink,
    onBottom: TtcStoryPalette.ink,
    topFraction: 0.26,
    bottomFraction: 0.70,
  ),

  // 2 — cream over blush, two bands.
  TtcSlideSkin(
    top: TtcStoryPalette.cream,
    mid: TtcStoryPalette.cream,
    bottom: TtcStoryPalette.blush,
    onTop: TtcStoryPalette.ink,
    onMid: TtcStoryPalette.ink,
    onBottom: TtcStoryPalette.ink,
    topFraction: 0.62,
    bottomFraction: 0.63,
  ),

  // 3 — hot rose over cream.
  TtcSlideSkin(
    top: TtcStoryPalette.rose,
    mid: TtcStoryPalette.cream,
    bottom: TtcStoryPalette.cream,
    onTop: Colors.white,
    onMid: TtcStoryPalette.ink,
    onBottom: TtcStoryPalette.ink,
    topFraction: 0.30,
    bottomFraction: 0.31,
  ),

  // 4 — sky over cream over sand.
  TtcSlideSkin(
    top: TtcStoryPalette.sky,
    mid: TtcStoryPalette.cream,
    bottom: TtcStoryPalette.sand,
    onTop: TtcStoryPalette.ink,
    onMid: TtcStoryPalette.ink,
    onBottom: TtcStoryPalette.ink,
    topFraction: 0.28,
    bottomFraction: 0.72,
  ),

  // 5 — teal over cream, deep and quiet.
  TtcSlideSkin(
    top: TtcStoryPalette.teal,
    mid: TtcStoryPalette.cream,
    bottom: TtcStoryPalette.cream,
    onTop: Colors.white,
    onMid: TtcStoryPalette.ink,
    onBottom: TtcStoryPalette.ink,
    topFraction: 0.33,
    bottomFraction: 0.34,
  ),

  // 6 — cream over rose. The closing note.
  TtcSlideSkin(
    top: TtcStoryPalette.cream,
    mid: TtcStoryPalette.cream,
    bottom: TtcStoryPalette.rose,
    onTop: TtcStoryPalette.ink,
    onMid: TtcStoryPalette.ink,
    onBottom: Colors.white,
    topFraction: 0.58,
    bottomFraction: 0.59,
  ),
];

TtcSlideSkin ttcSkinFor(int index) =>
    kTtcSlideSkins[index % kTtcSlideSkins.length];

/// Paints the bands and the waves between them, edge to edge.
class TtcStoryBackground extends StatelessWidget {
  const TtcStoryBackground({super.key, required this.skin, required this.seed});

  final TtcSlideSkin skin;

  /// Varies the wave shape per slide, deterministically.
  final int seed;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _BandPainter(skin: skin, seed: seed),
        size: Size.infinite,
      );
}

class _BandPainter extends CustomPainter {
  _BandPainter({required this.skin, required this.seed});

  final TtcSlideSkin skin;
  final int seed;

  /// A soft horizontal wave across the full width at [y].
  ///
  /// ⚠️ THREE CONTROL POINTS, NOT A SINE. A sampled sine gives a regular ripple
  /// that reads as a pattern; two cubic segments with offset control points
  /// give the lazy, uneven curve the reference uses, which reads as drawn.
  Path _wave(Size size, double y, double amp, double skew) {
    final p = Path()..moveTo(0, y);
    p.cubicTo(
      size.width * 0.28, y - amp * (1 + skew),
      size.width * 0.55, y + amp * (0.6 - skew),
      size.width, y - amp * 0.35,
    );
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // The top band is the ground; the others are laid over it, each clipped by
    // its own wave. Painting downward like this means no seams between bands,
    // however the curves fall.
    canvas.drawRect(Offset.zero & size, Paint()..color = skin.top);

    final amp = size.height * 0.035;
    final skew = ((seed % 5) - 2) * 0.12;

    canvas.drawPath(
        _wave(size, size.height * skin.topFraction, amp, skew),
        Paint()..color = skin.mid);

    if (!skin.twoBand) {
      canvas.drawPath(
          _wave(size, size.height * skin.bottomFraction, amp * 0.85, -skew),
          Paint()..color = skin.bottom);
    }
  }

  @override
  bool shouldRepaint(covariant _BandPainter old) =>
      old.skin != skin || old.seed != seed;
}

/// Splits `*emphasised*` runs out of a line so they can be set bold italic.
///
/// ⚠️ THE REFERENCE LEANS ON THIS HEAVILY and it is most of why its slides read
/// as speech rather than as captions — "can depend on *the method used*", "you
/// can try *right away!*". One weight for a whole sentence is a caption; a
/// stress inside a sentence is somebody talking.
///
/// Deliberately the smallest possible markup. A real rich-text layer here would
/// be a parser, a model change and an editor convention, for one effect.
List<TextSpan> ttcEmphasise(String raw, TextStyle base, TextStyle strong) {
  final out = <TextSpan>[];
  var rest = raw;
  while (true) {
    final open = rest.indexOf('*');
    if (open < 0) break;
    final close = rest.indexOf('*', open + 1);
    if (close < 0) break;
    if (open > 0) out.add(TextSpan(text: rest.substring(0, open), style: base));
    out.add(TextSpan(
        text: rest.substring(open + 1, close), style: strong));
    rest = rest.substring(close + 1);
  }
  if (rest.isNotEmpty) out.add(TextSpan(text: rest, style: base));
  return out.isEmpty ? [TextSpan(text: raw, style: base)] : out;
}

/// A blob of confetti — the small circles and dashes scattered behind the art.
class TtcConfetti extends StatelessWidget {
  const TtcConfetti({super.key, required this.colour, this.seed = 0});

  final Color colour;
  final int seed;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ConfettiPainter(colour, seed), size: Size.infinite);
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.colour, this.seed);
  final Color colour;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed + 11);
    final stroke = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 14; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      if (i.isEven) {
        canvas.drawCircle(Offset(x, y), 4 + rnd.nextDouble() * 9, stroke);
      } else {
        final a = rnd.nextDouble() * math.pi;
        canvas.drawLine(
            Offset(x, y),
            Offset(x + math.cos(a) * 11, y + math.sin(a) * 11),
            stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.colour != colour || old.seed != seed;
}
