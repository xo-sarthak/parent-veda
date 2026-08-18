// =============================================================================
//  V3HeroField — a background, not a picture. SHARED BY EVERY STAGE.
// -----------------------------------------------------------------------------
//  ⚠️ THIS REPLACED FIVE DRAWN SCENES (post_pregnancy/pp_hero_art.dart, deleted), and the
//  replacement is an improvement rather than a retreat. The reasoning is worth
//  keeping, because the wrong lesson is easy to draw from it.
//
//  The scenes were: a held newborn, a baby on a rug, a toddler pulling up, a
//  child outside, a child walking alongside. They worked as compositions and
//  failed as pictures, because a CustomPainter draws geometry — it can render a
//  silhouette and cannot render a face, a texture or a character. Every figure
//  came out as the account-avatar glyph wearing a hat.
//
//  The fix was not a better figure. It was noticing what Flo actually does:
//  **its hero has no illustration in it at all.** A soft gradient field, one
//  enormous number, two short lines — "Best chances of conceiving are in 5
//  days". The information IS the hero. The picture was never carrying that
//  screen, and ours was trying to.
//
//  Which makes this a strictly larger win rather than a compromise: a drawing is
//  the same every morning and a number is not.
//
//  SO: an abstract field that shifts with the phase, and nothing on it but
//  facts. No figures, no scenes, no generation pipeline, no per-phase exports,
//  and it follows the palette for free.
//
//  WHY IT STILL VARIES. A background identical across twenty phases is wallpaper
//  and stops being seen by the second week. The arcs move and resize on the
//  phase number, so the field is recognisably the same object in a different
//  position each time the child moves on — the same argument as the six tip
//  skies, for the same reason.
// =============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class V3HeroField extends StatelessWidget {
  const V3HeroField({
    super.key,
    required this.accent,
    required this.ground,
    required this.variant,
  });

  /// The phase's own colour. Everything is derived from it, so the hero and the
  /// phase never disagree and there is no second colour decision to get wrong.
  final Color accent;

  /// The page colour the field has to land on, so the seam is invisible.
  final Color ground;

  /// Drives the composition — the stage's own position on its spine. Parenting
  /// passes the phase number (1..20), TTC passes the chapter (1..4). Any int is
  /// safe; only `variant % 6` is read.
  ///
  /// ⚠️ IT IS DELIBERATELY NOT CALLED `phaseNumber` ANY MORE. It was, while this
  /// lived in `post_pregnancy/`, and the name was the reason TTC would have got
  /// a COPY of this file rather than a call to it — a parameter named after one
  /// stage's vocabulary reads as belonging to that stage. The journal section
  /// had already taught this: two screens drift apart when one of them holds a
  /// lookalike instead of the thing itself.
  final int variant;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _FieldPainter(accent, ground, variant),
        size: Size.infinite,
      );
}

class _FieldPainter extends CustomPainter {
  _FieldPainter(this.accent, this.ground, this.phase);

  final Color accent;
  final Color ground;
  final int phase;

  @override
  void paint(Canvas canvas, Size size) {
    final h = HSLColor.fromColor(accent);

    // ⚠️ TWO HUES, NOT ONE. The previous version derived every tone from the
    // phase accent, so the field was one purple at three lightnesses — which is
    // a colour wash, not a picture, and reads exactly as flat as it is.
    //
    // A second hue 34 degrees away is what gives a gradient somewhere to travel
    // TO. It is small enough that the field still belongs to its phase and
    // large enough that the eye registers a shift rather than a fade. Every
    // sunset does this and no single-hue gradient has ever looked like one.
    final shifted = HSLColor.fromAHSL(
        1, (h.hue + 34) % 360, (h.saturation + 0.10).clamp(0.0, 1.0), h.lightness);

    final deep = h.withSaturation(0.58).withLightness(0.62).toColor();
    final mid = shifted.withSaturation(0.52).withLightness(0.74).toColor();
    final pale = h.withSaturation(0.40).withLightness(0.90).toColor();

    // The field fills whatever it is given — it is the PAGE's surface now, not
    // a section's. See the note in the stage home about why that is what
    // removes the seam.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(size.width, 0),
          Offset(0, size.height * 0.62),
          [deep, mid, pale, ground],
          [0.0, 0.34, 0.78, 1.0],
        ),
    );

    // ⚠️ ARCS, NOT A BLOB. A soft round gradient floating in a field is what
    // Haikei generates and what every AI-built page has. These are the EDGES of
    // very large circles, mostly off-canvas, so what is visible is a long
    // shallow curve — depth rather than an object sitting on top of one.
    final t = (phase % 6) / 6.0;

    canvas.drawCircle(
      Offset(size.width * (0.82 - t * 0.30), -size.height * (0.22 + t * 0.16)),
      size.width * (0.95 + t * 0.30),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );

    canvas.drawCircle(
      Offset(size.width * (0.10 + t * 0.5), size.height * (0.74 - t * 0.14)),
      size.width * (0.62 + (1 - t) * 0.26),
      Paint()
        ..color = shifted
            .withSaturation(0.50)
            .withLightness(0.84)
            .toColor()
            .withValues(alpha: 0.5),
    );

    // ---- TEXTURE ----------------------------------------------------------
    //
    // A very fine dot grid at 3% white. Individually invisible; collectively it
    // stops the gradient being perfectly smooth, which is the difference
    // between "a colour" and "a surface". Every printed thing has tooth and
    // every screen gradient that looks expensive is faking some.
    //
    // Deliberately not a noise shader: 4px dots cost one loop and no GPU
    // program, and at this alpha nothing more elaborate would be visible.
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.030);
    for (double y = 6; y < size.height * 0.80; y += 9) {
      for (double x = (y ~/ 9).isEven ? 6 : 10.5; x < size.width; x += 9) {
        canvas.drawCircle(Offset(x, y), 1.15, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_FieldPainter old) =>
      old.accent != accent || old.ground != ground || old.phase != phase;
}
