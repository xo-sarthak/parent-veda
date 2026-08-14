// =============================================================================
//  V3TipArt — a drawn morning, in place of a stock photograph
// -----------------------------------------------------------------------------
//  WHY THE PHOTOGRAPHS CAME OUT.
//
//  They were warm and well-chosen and still wrong, for a reason worth naming:
//  a photograph always claims to be ABOUT something. A candle, a coffee cup,
//  leaf shadow on a curtain — each of those is a subject, and the tip sitting
//  under it is a different subject, so the card kept reading as two unrelated
//  things stacked. There is no fix by better searching, because the tip is free
//  text that changes daily and no image library can be relevant to a sentence
//  nobody has written yet.
//
//  So the art stops trying to illustrate the SENTENCE and illustrates the
//  OCCASION instead. This card is the morning greeting; a drawn sunrise is
//  about the only thing that is honestly related to every possible tip, because
//  what it is saying is "today", not "coffee".
//
//  WHY DRAWN RATHER THAN SOURCED SVG. The same four reasons v2_block_art.dart
//  gives, and they all still hold:
//
//    · ONE HAND. Same stroke weight, same caps, same geometry across all six.
//      A downloaded illustration set carries someone else's hand, and the free
//      ones carry a hand thousands of products are already using.
//    · PALETTE-AWARE. It takes its ink from the palette, so all four palette
//      directions stay coherent without six exports each — and the palette is
//      still undecided, so anything baked into a file would be redone.
//    · WEIGHTLESS. No network round trip on app open, which matters here more
//      than anywhere: this is the FIRST thing drawn, and a photograph that has
//      not loaded yet is a grey rectangle at the exact moment the card is
//      trying to make an impression.
//    · NOTHING TO GET WRONG. A drawing cannot show a woman who is not our user,
//      a brand we do not own, or a body that reads as someone else's.
//
//  THE SIX VARIANTS ARE ONE SCENE AT SIX TIMES OF DAY, not six different
//  pictures. Sun low, sun high, moon and stars, and so on. That is deliberate:
//  a rotation of unrelated images reads as randomness, while a rotation of one
//  scene reads as time passing — which is the thing this whole product is
//  about. Six means the same sky returns about weekly, by which point it reads
//  as a season rather than a repeat.
//
//  DRAWING RULES, so a seventh variant added later still belongs:
//    · Authored in a 200×100 box; the painter scales.
//    · One stroke weight, scaled from the box. Round caps and joins.
//    · The disc is the only filled shape. Everything else is line.
//    · Nothing crosses the bottom edge — the card's type starts right under it.
// =============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A drawn sky. [variant] selects one of six; anything is accepted and wrapped.
class V3TipArt extends StatelessWidget {
  const V3TipArt(
      {super.key,
      required this.variant,
      required this.ink,
      required this.accent});

  final int variant;

  /// The line colour. Comes from the palette, never from a constant here.
  final Color ink;

  /// The warm tertiary the card already uses for its label. The disc takes it,
  /// and nothing else does — one filled warm shape is a sun, two is a pattern.
  final Color accent;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _SkyPainter(variant.abs() % 6, ink, accent),
        size: Size.infinite,
      );
}

/// Exposed so the six variants can be looked at ALL AT ONCE rather than one per
/// day, which is the only reason any of this got fixed: the first cut had the
/// horizon running off the bottom edge and the grass growing through the label,
/// and on the phone that is a six-day bug report.
///
/// The recipe, if a seventh variant is ever added — a throwaway file under
/// test/, deleted after looking:
///
///     testWidgets('render', (tester) async {
///       await tester.runAsync(() async {            // toImage needs a real
///         for (var v = 0; v < 6; v++) {             // async zone; without
///           final rec = ui.PictureRecorder();       // runAsync it hangs
///           const size = Size(348, 132);
///           final c = Canvas(rec, Offset.zero & size);
///           c.drawRect(Offset.zero & size, Paint()..color = Colors.white);
///           // ...then the card's warm gradient, THEN the painter. Painting
///           // the tint without white under it composites alpha against
///           // nothing and everything renders full-strength orange.
///           tipSkyPainter(v, ink, accent).paint(c, size);
///           final img = await rec.endRecording().toImage(348, 132);
///           // write img to build/sky_\$v.png
///         }
///       });
///     });
CustomPainter tipSkyPainter(int v, Color ink, Color accent) =>
    _SkyPainter(v.abs() % 6, ink, accent);

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.v, this.ink, this.accent);
  final int v;
  final Color ink;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    // Authored wide: this is a banner, not a tile, so the 100×100 convention
    // from v2_block_art does not transfer. Scale on width and let height ride,
    // because the horizon is the thing that must reach both edges.
    // ⚠️ TWO SCALES WOULD SQUASH THE SUN, ONE SCALE OVERFLOWED THE BOX.
    //
    // First cut authored in a fixed 200x100 and multiplied BOTH axes by
    // width/200. The card is 200x76 in those units, so every vertical landed
    // ~30% too low: the horizon sat below the bottom edge and the grass grew up
    // through the label. The obvious fix — scale x and y independently — is
    // worse, because a non-uniform scale turns the disc into an ellipse and the
    // disc is the one shape anyone actually looks at.
    //
    // So: ONE uniform scale, and the authoring box's HEIGHT is whatever the
    // widget gives us. Verticals are fractions of `hh` rather than of a
    // constant, which means the composition re-flows to any banner ratio
    // instead of assuming one.
    final s = size.width / 200;
    final hh = size.height / s; // authoring-unit height, ~76 at the card's size
    canvas.save();

    // ⚠️ THE LAND IS NOT DRAWN IN INK, and the first version's mistake is a
    // general one. `ink` is #241E2B — a violet-dark — so at alpha 0.14 over a
    // peach sky it composites to GREY, and the picture came out as warm sky
    // over cold hills, which reads as two pictures. Earth in a warm scene has
    // to be a warm dark: the accent carried most of the way towards ink keeps
    // it dark enough to sit behind everything and warm enough to belong.
    final land = Color.lerp(accent, ink, 0.52)!;

    Paint line(double alpha, [double w = 1.6]) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = land.withValues(alpha: alpha);

    // ---- the disc: sun or moon, by variant ---------------------------------
    // x in authoring units; y as a FRACTION of the box height; radius in
    // authoring units so it stays a circle. (x, yFrac, r, isMoon)
    const discs = <List<double>>[
      [148, 0.36, 16, 0], // sun, high right
      [152, 0.56, 13, 1], // moon, low right
      [100, 0.32, 18, 0], // sun, high centre
      [ 52, 0.44, 14, 0], // sun, left
      [156, 0.28, 12, 1], // moon, high right
      [ 96, 0.54, 20, 0], // sun, low and large — the "rising" one
    ];
    final d = discs[v];
    final cx = d[0] * s, cy = d[1] * hh * s, r = d[2] * s;
    final isMoon = d[3] == 1;

    if (isMoon) {
      // A crescent by subtraction, so it is one shape rather than a circle with
      // a bite drawn over it — the latter breaks the moment the ground behind
      // is not flat, which it is not.
      final full =
          Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      final bite = Path()
        ..addOval(Rect.fromCircle(
            center: Offset(cx + r * 0.42, cy - r * 0.28), radius: r * 0.94));
      canvas.drawPath(Path.combine(PathOperation.difference, full, bite),
          Paint()..color = accent.withValues(alpha: 0.9));
      // Three stars, never more. A sky full of stars is a children's book.
      for (final st in const [[38.0, 0.30], [62.0, 0.18], [176.0, 0.46]]) {
        canvas.drawCircle(Offset(st[0] * s, st[1] * hh * s), 1.6 * s,
            Paint()..color = land.withValues(alpha: 0.45));
      }
    } else {
      canvas.drawCircle(
          Offset(cx, cy), r, Paint()..color = accent.withValues(alpha: 0.9));
      // NO RAYS. They were eight short ticks orbiting the disc and, detached
      // from it, read as scattered marks rather than light — the single most
      // clip-art thing in the picture. A soft halo does the same job by the
      // means light actually uses, and it costs one gradient instead of eight
      // strokes. Only the two high-sun variants get it: a low sun in haze does
      // not glow, and a moon never does.
      if (v == 0 || v == 2) {
        canvas.drawCircle(
          Offset(cx, cy),
          r * 2.4,
          Paint()
            ..shader = ui.Gradient.radial(Offset(cx, cy), r * 2.4, [
              accent.withValues(alpha: 0.26),
              accent.withValues(alpha: 0.0),
            ], [
              0.32,
              1.0,
            ]),
        );
        // Redrawn on top, because the halo washes over the disc's own edge and
        // softens it into a smudge otherwise.
        canvas.drawCircle(Offset(cx, cy), r,
            Paint()..color = accent.withValues(alpha: 0.9));
      }
    }

    // ---- the horizon: two or three arcs, always reaching both edges ---------
    //
    // These sit IN FRONT of the disc, so the sun is setting into them rather
    // than floating above them. That single ordering decision is most of why
    // this reads as a landscape and not as a clip-art assembly.
    //
    // (y at the left edge, y at the crest) as fractions of the box height. The
    // left value is always the larger, so each ridge rises towards the middle.
    final bands = <List<double>>[
      [0.74, 0.58, 0.16],
      [0.86, 0.72, 0.28],
      if (v != 1 && v != 4) [0.99, 0.87, 0.16],
    ];
    for (final b in bands) {
      final left = b[0] * hh * s, crest = b[1] * hh * s, alpha = b[2];
      final path = Path()
        ..moveTo(0, left)
        ..quadraticBezierTo(60 * s, crest - 5 * s, 104 * s, crest)
        ..quadraticBezierTo(150 * s, crest + 7 * s, size.width, crest - 6 * s)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = land.withValues(alpha: alpha));
    }

    // ---- one botanical, bottom left ----------------------------------------
    // Three blades from a common root, rooted ON the bottom edge and never
    // taller than a third of the box — it is the near edge of the scene, not a
    // subject. Present on every variant, which is what makes the six read as
    // one place at six times of day rather than six pictures.
    for (final t in const [[-0.5, 0.30], [-0.12, 0.38], [0.28, 0.25]]) {
      final ang = t[0], len = t[1] * hh * s;
      final root = Offset(22 * s, size.height);
      final tip =
          Offset(root.dx + math.sin(ang) * len, root.dy - math.cos(ang) * len);
      final ctrl =
          Offset((root.dx + tip.dx) / 2 - 4 * s, (root.dy + tip.dy) / 2);
      canvas.drawPath(
          Path()
            ..moveTo(root.dx, root.dy)
            ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy),
          line(0.26));
    }

    // ---- two birds, on the daylight variants only --------------------------
    if (v == 0 || v == 3 || v == 5) {
      for (final b in const [[68.0, 0.24, 1.0], [86.0, 0.34, 0.78]]) {
        final bx = b[0] * s, by = b[1] * hh * s, k = b[2] * 5 * s;
        canvas.drawPath(
            Path()
              ..moveTo(bx - k, by)
              ..quadraticBezierTo(bx - k * 0.4, by - k * 0.7, bx, by)
              ..quadraticBezierTo(bx + k * 0.4, by - k * 0.7, bx + k, by),
            line(0.28, 1.4));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkyPainter old) =>
      old.v != v || old.ink != ink || old.accent != accent;
}
