// =============================================================================
//  Symptom marks — the rest of the set, drawn
// -----------------------------------------------------------------------------
//  ⚠️ THIS FINISHES WHAT `ttc_mood_face.dart` STARTED. The eight moods got
//  drawn faces and the response was *"could you create those custom things for
//  other as well — cramping, tenderness, a headache and stuff like that, the
//  way our competitor app has done"*. So: every remaining symptom, thirty-nine
//  of them, as line marks in the same hand.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY ALL OF THEM AND NOT THE OBVIOUS ONES
//  ---------------------------------------------------------------------------
//
//  The tempting version is to draw the dozen that read well and leave Material
//  icons for the rest. That produces the worst possible result: one `Wrap` of
//  chips holding two visual languages, where the drawn ones look like the app
//  and the leftovers look like a settings screen. Mixed sets do not read as
//  "some are custom" — they read as unfinished.
//
//  So the coverage is total, and `ttc_symptom_marks_test.dart` asserts it. A
//  symptom added to `kTtcSymptomGroups` without a glyph fails the suite rather
//  than quietly falling back to an icon nobody notices for three months. That
//  is the wiring gate applied to artwork.
//
//  ---------------------------------------------------------------------------
//  ⚠️ OBJECTS AND PLACES, NOT LITTLE PICTURES OF WOMEN
//  ---------------------------------------------------------------------------
//
//  Two rules held the whole way through, and both are about not overclaiming:
//
//   1. **No anatomy.** Cramping is a lower-belly curve with radiating strokes,
//      not a drawn uterus. Hand-drawn anatomy without a clinician's review is a
//      claim this app is not entitled to make — the same rule that shaped
//      `ttc_illustrations.dart`.
//
//   2. **No bodies and no faces outside the moods.** A symptom is something
//      happening to her, not a picture of her having it. The moment a mark
//      shows a person, it starts describing what that person looks like.
//
//  Legibility target is 15pt, because that is the size on the chips.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ttc/ttc_symptom_data.dart';
import 'ttc_mood_face.dart';

/// One drawn mark. Named for what it depicts, not for the symptom, because
/// several symptoms legitimately share a shape with a variation.
enum TtcGlyph {
  // body
  check,
  bellyAche,
  tender,
  headAche,
  battery,
  spine,
  expand,
  spots,
  craving,
  moonEye,
  queasy,
  pelvis,
  // discharge — one droplet, seven treatments
  dropNone,
  dropStretch,
  dropWatery,
  dropCreamy,
  dropSticky,
  dropSpot,
  dropOdd,
  // sex
  ringsNone,
  rings,
  ringsShield,
  heartUp,
  heartDown,
  // tests — one stick, four readings
  stickNone,
  stickTwo,
  stickOne,
  stickFaint,
  // life
  dumbbell,
  lotus,
  stride,
  storm,
  plane,
  glass,
  thermometer,
  ripples,
}

/// The glyph for a symptom id, or null if it is a mood (which draws a face) or
/// has no mark yet.
TtcGlyph? ttcGlyphFor(String id) => switch (id) {
      'all_fine' => TtcGlyph.check,
      'cramping' => TtcGlyph.bellyAche,
      'breast' => TtcGlyph.tender,
      'headache' => TtcGlyph.headAche,
      'fatigue' => TtcGlyph.battery,
      'backache' => TtcGlyph.spine,
      'bloating' => TtcGlyph.expand,
      'acne' => TtcGlyph.spots,
      'cravings' => TtcGlyph.craving,
      'insomnia' => TtcGlyph.moonEye,
      'nausea' => TtcGlyph.queasy,
      'pelvic_pain' => TtcGlyph.pelvis,
      'disch_none' => TtcGlyph.dropNone,
      'disch_eggwhite' => TtcGlyph.dropStretch,
      'disch_watery' => TtcGlyph.dropWatery,
      'disch_creamy' => TtcGlyph.dropCreamy,
      'disch_sticky' => TtcGlyph.dropSticky,
      'disch_spotting' => TtcGlyph.dropSpot,
      'disch_unusual' => TtcGlyph.dropOdd,
      'sex_none' => TtcGlyph.ringsNone,
      'sex_unprotected' => TtcGlyph.rings,
      'sex_protected' => TtcGlyph.ringsShield,
      'sex_high_drive' => TtcGlyph.heartUp,
      'sex_low_drive' => TtcGlyph.heartDown,
      // ⚠️ THE TWO TEST GROUPS SHARE A STICK ON PURPOSE. An ovulation test and
      // a pregnancy test are the same object read the same way, and they never
      // appear in the same card — the group heading above them is what says
      // which test this is. Inventing two different sticks would be a
      // distinction the reader has to learn for no gain.
      'ov_none' || 'pt_none' => TtcGlyph.stickNone,
      'ov_positive' || 'pt_positive' => TtcGlyph.stickTwo,
      'ov_negative' || 'pt_negative' => TtcGlyph.stickOne,
      'pt_faint' => TtcGlyph.stickFaint,
      'exercise' => TtcGlyph.dumbbell,
      'yoga' => TtcGlyph.lotus,
      'walk' => TtcGlyph.stride,
      'stress' => TtcGlyph.storm,
      'travel' => TtcGlyph.plane,
      'alcohol' => TtcGlyph.glass,
      'illness' => TtcGlyph.thermometer,
      'meditation' => TtcGlyph.ripples,
      _ => null,
    };

/// The right mark for any symptom: a mood face, a drawn glyph, or — only if
/// neither exists — its Material icon.
///
/// ⚠️ THE ICON FALLBACK IS A SAFETY NET, NOT A TIER. It exists so a new symptom
/// renders something rather than a hole while it is being added, and the test
/// exists so it never survives a commit. If you find yourself relying on it,
/// draw the glyph.
class TtcSymptomMark extends StatelessWidget {
  const TtcSymptomMark(
      {super.key, required this.symptom, required this.size, required this.ink});

  final TtcSymptom symptom;
  final double size;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final mood = ttcMoodFor(symptom.id);
    if (mood != null) return TtcMoodFace(mood: mood, size: size, ink: ink);

    final glyph = ttcGlyphFor(symptom.id);
    if (glyph == null) {
      return Icon(symptom.icon, size: size * 0.85, color: ink);
    }
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GlyphPainter(glyph: glyph, ink: ink)),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({required this.glyph, required this.ink});

  final TtcGlyph glyph;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ⚠️ STROKE SCALES WITH THE BOX, FLOORED AT 1.1. Same rule as the mood
    // faces: a fixed 2pt line is right at 28pt and a slab at 12pt, and below
    // about 1.1 an anti-aliased hairline disappears on a low-density screen.
    final w = math.max(1.1, s * 0.085);
    final line = Paint()
      ..color = ink
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final thin = Paint()
      ..color = ink
      ..strokeWidth = w * 0.72
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = ink;

    /// A teardrop centred on [c], [r] wide.
    Path drop(Offset c, double r) => Path()
      ..moveTo(c.dx, c.dy - r * 1.25)
      ..quadraticBezierTo(c.dx + r, c.dy + r * 0.1, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - r, c.dy + r * 0.1, c.dx, c.dy - r * 1.25)
      ..close();

    /// A heart centred on [c].
    Path heart(Offset c, double r) => Path()
      ..moveTo(c.dx, c.dy + r * 0.9)
      ..cubicTo(c.dx - r * 1.5, c.dy - r * 0.3, c.dx - r * 0.55,
          c.dy - r * 1.3, c.dx, c.dy - r * 0.35)
      ..cubicTo(c.dx + r * 0.55, c.dy - r * 1.3, c.dx + r * 1.5,
          c.dy - r * 0.3, c.dx, c.dy + r * 0.9)
      ..close();

    /// A diagonal bar through the mark — "none of this".
    void slash() => canvas.drawLine(Offset(cx - s * 0.32, cy + s * 0.32),
        Offset(cx + s * 0.32, cy - s * 0.32), line);

    /// A test stick: a rounded body with a window.
    void stick(void Function(Rect window) bars) {
      final body = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(cx, cy), width: s * 0.34, height: s * 0.82),
          Radius.circular(s * 0.1));
      canvas.drawRRect(body, line);
      bars(Rect.fromCenter(
          center: Offset(cx, cy - s * 0.06),
          width: s * 0.2,
          height: s * 0.34));
    }

    void bar(Rect win, double t, {bool faint = false}) {
      final y = win.top + win.height * t;
      canvas.drawLine(
          Offset(win.left, y), Offset(win.right, y), faint ? thin : line);
    }

    switch (glyph) {
      // ---- body ----------------------------------------------------------
      case TtcGlyph.check:
        final path = Path()
          ..moveTo(cx - s * 0.26, cy)
          ..lineTo(cx - s * 0.06, cy + s * 0.2)
          ..lineTo(cx + s * 0.28, cy - s * 0.22);
        canvas.drawPath(path, line);

      // A lower-belly curve with the ache radiating out of it. Not a uterus —
      // see the no-anatomy rule at the head of this file.
      case TtcGlyph.bellyAche:
        final bowl = Path()
          ..moveTo(cx - s * 0.26, cy - s * 0.06)
          ..quadraticBezierTo(cx, cy + s * 0.36, cx + s * 0.26, cy - s * 0.06);
        canvas.drawPath(bowl, line);
        for (final a in [-0.9, 0.0, 0.9]) {
          canvas.drawLine(
            Offset(cx + math.sin(a) * s * 0.16, cy - s * 0.14),
            Offset(cx + math.sin(a) * s * 0.26, cy - s * 0.34),
            thin,
          );
        }

      case TtcGlyph.tender:
        canvas.drawCircle(Offset(cx, cy + s * 0.04), s * 0.19, line);
        canvas.drawCircle(Offset(cx, cy + s * 0.04), s * 0.05, fill);
        for (final a in [-2.4, -0.75]) {
          canvas.drawArc(
              Rect.fromCircle(
                  center: Offset(cx, cy + s * 0.04), radius: s * 0.32),
              a,
              0.7,
              false,
              thin);
        }

      case TtcGlyph.headAche:
        canvas.drawArc(
            Rect.fromCircle(center: Offset(cx, cy + s * 0.12), radius: s * 0.22),
            math.pi,
            math.pi,
            false,
            line);
        canvas.drawLine(Offset(cx - s * 0.22, cy + s * 0.12),
            Offset(cx + s * 0.22, cy + s * 0.12), line);
        for (final dx in [-0.22, 0.0, 0.22]) {
          canvas.drawLine(
            Offset(cx + s * dx, cy - s * 0.2),
            Offset(cx + s * dx * 1.5, cy - s * 0.36),
            thin,
          );
        }

      // A battery with one bar left. "Tired" as a level rather than a mood —
      // the mood set already owns faces.
      case TtcGlyph.battery:
        final body = RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx - s * 0.03, cy),
                width: s * 0.56,
                height: s * 0.34),
            Radius.circular(s * 0.07));
        canvas.drawRRect(body, line);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(cx - s * 0.26, cy - s * 0.1, s * 0.13, s * 0.2),
                Radius.circular(s * 0.03)),
            fill);
        canvas.drawLine(Offset(cx + s * 0.3, cy - s * 0.07),
            Offset(cx + s * 0.3, cy + s * 0.07), line);

      case TtcGlyph.spine:
        final path = Path()
          ..moveTo(cx - s * 0.06, cy - s * 0.32)
          ..quadraticBezierTo(cx + s * 0.16, cy - s * 0.1, cx - s * 0.04, cy)
          ..quadraticBezierTo(cx - s * 0.22, cy + s * 0.16, cx, cy + s * 0.32);
        canvas.drawPath(path, line);
        for (final a in [-0.6, 0.6]) {
          canvas.drawLine(
            Offset(cx + s * 0.16, cy + a * s * 0.16),
            Offset(cx + s * 0.32, cy + a * s * 0.26),
            thin,
          );
        }

      case TtcGlyph.expand:
        canvas.drawCircle(Offset(cx, cy), s * 0.2, line);
        for (var i = 0; i < 4; i++) {
          final a = math.pi / 4 + i * math.pi / 2;
          canvas.drawLine(
            Offset(cx + math.cos(a) * s * 0.28, cy + math.sin(a) * s * 0.28),
            Offset(cx + math.cos(a) * s * 0.4, cy + math.sin(a) * s * 0.4),
            thin,
          );
        }

      case TtcGlyph.spots:
        canvas.drawCircle(Offset(cx, cy), s * 0.3, line);
        canvas.drawCircle(Offset(cx - s * 0.1, cy - s * 0.08), s * 0.05, fill);
        canvas.drawCircle(Offset(cx + s * 0.11, cy - s * 0.02), s * 0.04, fill);
        canvas.drawCircle(Offset(cx - s * 0.02, cy + s * 0.13), s * 0.045, fill);

      // A bowl with a heart over it. Wanting, not eating.
      case TtcGlyph.craving:
        canvas.drawArc(
            Rect.fromCircle(center: Offset(cx, cy + s * 0.1), radius: s * 0.28),
            0.1,
            math.pi - 0.2,
            false,
            line);
        canvas.drawLine(Offset(cx - s * 0.3, cy + s * 0.1),
            Offset(cx + s * 0.3, cy + s * 0.1), line);
        canvas.drawPath(heart(Offset(cx, cy - s * 0.2), s * 0.13), fill);

      case TtcGlyph.moonEye:
        final moon = Path()
          ..addOval(Rect.fromCircle(
              center: Offset(cx - s * 0.02, cy), radius: s * 0.3));
        final bite = Path()
          ..addOval(Rect.fromCircle(
              center: Offset(cx + s * 0.16, cy - s * 0.1), radius: s * 0.28));
        canvas.drawPath(
            Path.combine(PathOperation.difference, moon, bite), line);
        // The open eye — awake, not asleep.
        canvas.drawCircle(Offset(cx - s * 0.1, cy + s * 0.02), s * 0.05, fill);

      case TtcGlyph.queasy:
        canvas.drawCircle(Offset(cx, cy), s * 0.3, line);
        final wave = Path()..moveTo(cx - s * 0.2, cy + s * 0.04);
        wave.quadraticBezierTo(
            cx - s * 0.1, cy - s * 0.08, cx, cy + s * 0.04);
        wave.quadraticBezierTo(
            cx + s * 0.1, cy + s * 0.16, cx + s * 0.2, cy + s * 0.04);
        canvas.drawPath(wave, thin);

      case TtcGlyph.pelvis:
        final basin = Path()
          ..moveTo(cx - s * 0.28, cy - s * 0.14)
          ..lineTo(cx + s * 0.28, cy - s * 0.14)
          ..quadraticBezierTo(cx + s * 0.14, cy + s * 0.3, cx, cy + s * 0.3)
          ..quadraticBezierTo(
              cx - s * 0.14, cy + s * 0.3, cx - s * 0.28, cy - s * 0.14);
        canvas.drawPath(basin, line);
        canvas.drawLine(Offset(cx, cy - s * 0.22), Offset(cx, cy - s * 0.38),
            thin);

      // ---- discharge: one droplet, seven readings -------------------------
      case TtcGlyph.dropNone:
        canvas.drawPath(drop(Offset(cx, cy), s * 0.24), line);
        slash();

      // Stretchy — the one sign worth recognising on sight, so it gets the
      // clearest treatment: the drop pulled between two points.
      case TtcGlyph.dropStretch:
        canvas.drawPath(drop(Offset(cx - s * 0.16, cy), s * 0.16), line);
        canvas.drawPath(drop(Offset(cx + s * 0.16, cy), s * 0.16), line);
        canvas.drawLine(Offset(cx - s * 0.1, cy), Offset(cx + s * 0.1, cy),
            thin);

      case TtcGlyph.dropWatery:
        canvas.drawPath(drop(Offset(cx, cy - s * 0.06), s * 0.2), line);
        for (final dy in [0.26, 0.38]) {
          canvas.drawArc(
              Rect.fromCenter(
                  center: Offset(cx, cy + s * dy),
                  width: s * (dy == 0.26 ? 0.44 : 0.28),
                  height: s * 0.14),
              math.pi,
              math.pi,
              false,
              thin);
        }

      case TtcGlyph.dropCreamy:
        canvas.drawPath(drop(Offset(cx, cy), s * 0.26), fill);

      case TtcGlyph.dropSticky:
        canvas.drawPath(drop(Offset(cx, cy - s * 0.08), s * 0.2), line);
        canvas.drawLine(Offset(cx, cy + s * 0.16), Offset(cx, cy + s * 0.34),
            line);

      case TtcGlyph.dropSpot:
        canvas.drawCircle(Offset(cx - s * 0.16, cy - s * 0.1), s * 0.075, fill);
        canvas.drawCircle(Offset(cx + s * 0.14, cy + s * 0.02), s * 0.06, fill);
        canvas.drawCircle(Offset(cx - s * 0.04, cy + s * 0.22), s * 0.05, fill);

      case TtcGlyph.dropOdd:
        canvas.drawPath(drop(Offset(cx - s * 0.06, cy), s * 0.22), line);
        canvas.drawLine(Offset(cx + s * 0.26, cy - s * 0.24),
            Offset(cx + s * 0.26, cy + s * 0.04), line);
        canvas.drawCircle(Offset(cx + s * 0.26, cy + s * 0.2), w * 0.7, fill);

      // ---- sex -------------------------------------------------------------
      case TtcGlyph.ringsNone:
        canvas.drawCircle(Offset(cx - s * 0.13, cy), s * 0.19, line);
        canvas.drawCircle(Offset(cx + s * 0.13, cy), s * 0.19, line);
        slash();

      case TtcGlyph.rings:
        canvas.drawCircle(Offset(cx - s * 0.13, cy), s * 0.19, line);
        canvas.drawCircle(Offset(cx + s * 0.13, cy), s * 0.19, line);

      case TtcGlyph.ringsShield:
        canvas.drawCircle(Offset(cx - s * 0.1, cy + s * 0.02), s * 0.13, line);
        canvas.drawCircle(Offset(cx + s * 0.1, cy + s * 0.02), s * 0.13, line);
        final shield = Path()
          ..moveTo(cx - s * 0.34, cy - s * 0.18)
          ..quadraticBezierTo(cx, cy - s * 0.42, cx + s * 0.34, cy - s * 0.18);
        canvas.drawPath(shield, thin);

      case TtcGlyph.heartUp:
        canvas.drawPath(heart(Offset(cx - s * 0.06, cy + s * 0.04), s * 0.2),
            fill);
        canvas.drawLine(Offset(cx + s * 0.28, cy + s * 0.1),
            Offset(cx + s * 0.28, cy - s * 0.22), line);
        canvas.drawPath(
            Path()
              ..moveTo(cx + s * 0.18, cy - s * 0.12)
              ..lineTo(cx + s * 0.28, cy - s * 0.24)
              ..lineTo(cx + s * 0.38, cy - s * 0.12),
            line);

      case TtcGlyph.heartDown:
        canvas.drawPath(heart(Offset(cx - s * 0.06, cy - s * 0.02), s * 0.2),
            line);
        canvas.drawLine(Offset(cx + s * 0.28, cy - s * 0.2),
            Offset(cx + s * 0.28, cy + s * 0.14), line);
        canvas.drawPath(
            Path()
              ..moveTo(cx + s * 0.18, cy + s * 0.04)
              ..lineTo(cx + s * 0.28, cy + s * 0.16)
              ..lineTo(cx + s * 0.38, cy + s * 0.04),
            line);

      // ---- tests -----------------------------------------------------------
      case TtcGlyph.stickNone:
        stick((_) {});
        slash();

      case TtcGlyph.stickTwo:
        stick((win) {
          bar(win, 0.3);
          bar(win, 0.7);
        });

      case TtcGlyph.stickOne:
        stick((win) => bar(win, 0.3));

      case TtcGlyph.stickFaint:
        stick((win) {
          bar(win, 0.3);
          bar(win, 0.7, faint: true);
        });

      // ---- life ------------------------------------------------------------
      case TtcGlyph.dumbbell:
        canvas.drawLine(Offset(cx - s * 0.16, cy), Offset(cx + s * 0.16, cy),
            line);
        for (final side in [-1, 1]) {
          canvas.drawLine(Offset(cx + side * s * 0.22, cy - s * 0.16),
              Offset(cx + side * s * 0.22, cy + s * 0.16), line);
          canvas.drawLine(Offset(cx + side * s * 0.33, cy - s * 0.09),
              Offset(cx + side * s * 0.33, cy + s * 0.09), thin);
        }

      // Crossed legs and a straight back, from above the waist down. No head,
      // no figure — see the no-bodies rule.
      case TtcGlyph.lotus:
        canvas.drawLine(Offset(cx, cy - s * 0.34), Offset(cx, cy + s * 0.06),
            line);
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(cx, cy + s * 0.14),
                width: s * 0.66,
                height: s * 0.42),
            math.pi,
            math.pi,
            false,
            line);
        canvas.drawLine(Offset(cx - s * 0.24, cy + s * 0.14),
            Offset(cx + s * 0.24, cy + s * 0.14), thin);

      case TtcGlyph.stride:
        canvas.drawLine(Offset(cx + s * 0.04, cy - s * 0.3),
            Offset(cx - s * 0.04, cy + s * 0.02), line);
        canvas.drawLine(Offset(cx - s * 0.04, cy + s * 0.02),
            Offset(cx - s * 0.24, cy + s * 0.3), line);
        canvas.drawLine(Offset(cx - s * 0.04, cy + s * 0.02),
            Offset(cx + s * 0.2, cy + s * 0.3), line);
        canvas.drawLine(Offset(cx + s * 0.02, cy - s * 0.18),
            Offset(cx + s * 0.26, cy - s * 0.06), thin);

      case TtcGlyph.storm:
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(cx, cy - s * 0.12),
                width: s * 0.6,
                height: s * 0.36),
            math.pi,
            math.pi,
            false,
            line);
        canvas.drawLine(Offset(cx - s * 0.3, cy - s * 0.12),
            Offset(cx + s * 0.3, cy - s * 0.12), line);
        canvas.drawPath(
            Path()
              ..moveTo(cx + s * 0.06, cy - s * 0.02)
              ..lineTo(cx - s * 0.08, cy + s * 0.14)
              ..lineTo(cx + s * 0.04, cy + s * 0.14)
              ..lineTo(cx - s * 0.06, cy + s * 0.34),
            line);

      case TtcGlyph.plane:
        canvas.drawPath(
            Path()
              ..moveTo(cx - s * 0.32, cy + s * 0.06)
              ..lineTo(cx + s * 0.34, cy - s * 0.26)
              ..lineTo(cx + s * 0.02, cy + s * 0.32)
              ..lineTo(cx - s * 0.04, cy + s * 0.1)
              ..close(),
            line);

      case TtcGlyph.glass:
        canvas.drawPath(
            Path()
              ..moveTo(cx - s * 0.22, cy - s * 0.3)
              ..lineTo(cx + s * 0.22, cy - s * 0.3)
              ..quadraticBezierTo(cx + s * 0.18, cy + s * 0.06, cx, cy + s * 0.08)
              ..quadraticBezierTo(
                  cx - s * 0.18, cy + s * 0.06, cx - s * 0.22, cy - s * 0.3)
              ..close(),
            line);
        canvas.drawLine(Offset(cx, cy + s * 0.08), Offset(cx, cy + s * 0.28),
            line);
        canvas.drawLine(Offset(cx - s * 0.14, cy + s * 0.3),
            Offset(cx + s * 0.14, cy + s * 0.3), line);

      case TtcGlyph.thermometer:
        canvas.drawLine(Offset(cx, cy - s * 0.3), Offset(cx, cy + s * 0.12),
            line);
        canvas.drawCircle(Offset(cx, cy + s * 0.24), s * 0.12, line);
        canvas.drawCircle(Offset(cx, cy + s * 0.24), s * 0.05, fill);
        for (final dy in [-0.2, -0.06]) {
          canvas.drawLine(Offset(cx + s * 0.06, cy + s * dy),
              Offset(cx + s * 0.18, cy + s * dy), thin);
        }

      case TtcGlyph.ripples:
        canvas.drawCircle(Offset(cx, cy), s * 0.07, fill);
        for (final r in [0.19, 0.31]) {
          canvas.drawCircle(Offset(cx, cy), s * r, thin);
        }
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.ink != ink;
}
