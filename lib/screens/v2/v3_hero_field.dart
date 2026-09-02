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

import 'dart:math' as math;

import 'package:flutter/material.dart';

// =============================================================================
//  ⚠️ THE WHEEL IS NOT EVEN, AND A FULL-PAGE WASH IS WHERE THAT SHOWS
// -----------------------------------------------------------------------------
//  Every tint in this app is mixed at a FIXED HSL saturation — `v2BlockTint`
//  uses 0.30/0.32 for all 360 degrees — and the field below re-saturates that
//  hue to 0.58 for its deepest stop. Those numbers are identical for every
//  screen, which is why it is so easy to believe the fields are consistent.
//
//  They are not, because HSL saturation is not chroma. Measured as CIELAB C* on
//  the field's deepest stop, the same recipe produces wildly different colour:
//
//      hue 206  (IVF, clinical blue)        C* = 32
//      hue 344  (rose)                      C* = 47
//      hue 320  (skilling memory)           C* = 56
//      hue 104  (sage)                      C* = 66
//      hue 273  (Fertile Window, violet)    C* = 67
//      hue 288  (PCOS, violet-magenta)      C* = 68
//
//  Reported as *"if I open the fertile window or if I open the IVF, I do not see
//  that purple tint the way it is for PCOS"* — and the numbers say why: the
//  magenta carries more than twice the colour of the blue at settings that are
//  the same integer in code. Invisible on a small tinted BLOCK. On a field that
//  IS the page surface it is the loudest thing on screen.
//
//  ---------------------------------------------------------------------------
//  ⚠️ A BAND RULE WAS THE FIRST FIX AND IT WAS HALF AN ANSWER
//  ---------------------------------------------------------------------------
//
//  That version damped 280..320 to a flat 0.62, which brought PCOS down beside
//  IVF and stopped there. It could not do what was actually asked, because the
//  ask was *"when I am inside PCOS, or fertile window, or IVF, I should see the
//  same colour behind"* — and Fertile Window at 273 sits outside that band at
//  C* 67, so two of the three still disagreed. A band is a patch on the hues
//  someone happened to complain about; the next hue complains next.
//
//  So the rule is now the thing the complaint was always describing:
//  **every hue spends the same perceptual chroma.** [v3FieldChroma] solves for
//  the saturation that lands this hue on [_kFieldTargetChroma] and returns it
//  as a fraction of the recipe's own. Nothing is special-cased, no hue is
//  named, and a hue nobody has drawn yet is already handled.
//
//  ⚠️ AND THE TARGET IS BELOW THE QUIETEST HUE WE HAD, deliberately. 26 sits
//  under the blue's 32, so equalising also lightens — *"slight more towards the
//  whitish side"*. Raise it and every field gets louder together, which is the
//  only kind of change worth making to this number.
//
//  ⚠️ IT DAMPS CHROMA, NEVER HUE. The door keeps its colour — 288 is still 288,
//  and every `v2BlockTint` on every page is untouched. Only the wash spends
//  less of it.
// =============================================================================

/// The chroma every field lands on, whatever its hue.
///
/// CIELAB C*. Chosen below the quietest hue the app had (the clinical blue, at
/// 32) so that equalising also lightens the whole set.
const double _kFieldTargetChroma = 26;

/// The deepest stop's saturation and lightness — the anchor the solve runs
/// against, because it is the loudest part of the field and the one the eye
/// reads as "how purple is this screen".
const double _kFieldDeepSaturation = 0.58;
const double _kFieldDeepLightness = 0.62;

/// Hues repeat across rebuilds and there are a dozen of them in the whole app,
/// so the solve runs once each and never again.
final Map<int, double> _chromaCache = {};

/// How much of the field's saturation [hue] may spend, 0..1.
///
/// ⚠️ SOLVED, NOT TABULATED. A lookup table would have to be regenerated by
/// hand whenever the recipe's lightness moved, and would silently be wrong
/// until someone noticed a screen had drifted. This is twenty-four bisections
/// over a pure function, once per hue per launch.
double v3FieldChroma(double hue) {
  final key = (hue % 360).round();
  return _chromaCache.putIfAbsent(key, () {
    var lo = 0.0;
    var hi = 1.0;
    for (var i = 0; i < 24; i++) {
      final mid = (lo + hi) / 2;
      if (_fieldChromaAt(key.toDouble(), _kFieldDeepSaturation * mid) <
          _kFieldTargetChroma) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2;
  });
}

/// CIELAB C* of the field's deep stop at this hue and saturation.
double _fieldChromaAt(double hue, double saturation) {
  final c = HSLColor.fromAHSL(1, hue, saturation, _kFieldDeepLightness)
      .toColor();

  // sRGB -> linear
  double lin(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  final r = lin(c.r);
  final g = lin(c.g);
  final b = lin(c.b);

  // linear sRGB -> XYZ (D65)
  final x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375;
  final y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750;
  final z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041;

  // XYZ -> Lab
  double f(double t) => t > 216 / 24389
      ? math.pow(t, 1 / 3).toDouble()
      : (841 / 108) * t + 4 / 29;
  final fx = f(x / 0.95047);
  final fy = f(y);
  final fz = f(z / 1.08883);

  final a = 500 * (fx - fy);
  final bb = 200 * (fy - fz);
  return math.sqrt(a * a + bb * bb);
}

class V3HeroField extends StatelessWidget {
  const V3HeroField({
    super.key,
    required this.accent,
    required this.ground,
    required this.variant,
    this.chroma = 1,
  });

  /// How much colour the field may spend, 0..1. See [v3FieldChroma], which is
  /// what every caller should pass — a hand-picked number here is a screen
  /// deciding on its own what a shared surface looks like.
  final double chroma;

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
        painter: _FieldPainter(accent, ground, variant, chroma),
        size: Size.infinite,
      );
}

class _FieldPainter extends CustomPainter {
  _FieldPainter(this.accent, this.ground, this.phase, this.chroma);

  final Color accent;
  final Color ground;
  final int phase;
  final double chroma;

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

    // ⚠️ `chroma` SCALES THESE AND NOTHING ELSE TOUCHES IT. See the note at the
    // head of this file: the saturations below are the same for every hue, and
    // that is precisely the problem they are being corrected for.
    double s(double v) => (v * chroma).clamp(0.0, 1.0);

    final deep = h.withSaturation(s(0.58)).withLightness(0.62).toColor();
    final mid = shifted.withSaturation(s(0.52)).withLightness(0.74).toColor();
    final pale = h.withSaturation(s(0.40)).withLightness(0.90).toColor();

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
            .withSaturation(s(0.50))
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
      old.accent != accent ||
      old.ground != ground ||
      old.phase != phase ||
      old.chroma != chroma;
}
