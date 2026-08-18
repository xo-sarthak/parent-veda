// =============================================================================
//  V3BracketArt — one drawn mark per problem bracket
// -----------------------------------------------------------------------------
//  Ten marks for the ten pregnancy brackets, in the language the door marks and
//  the tip skies already established:
//
//    · ONE FILLED FOCAL SHAPE in the tile's own hue at full strength. Fill is
//      what separates a picture from a diagram, and a diagram is something you
//      study rather than a door you push.
//    · A SOFT HALO behind it. No ground band, no horizon — see the note in
//      v2_block_art.dart about why the landscape came out.
//    · DETAIL KNOCKED OUT IN WHITE, never a second colour laid on top.
//    · COLOUR DERIVED FROM THE TINT, never passed in as a constant, so all the
//      palettes stay coherent for free.
//
//  ⚠️ WHY A THIRD ART FILE AND NOT MORE CASES IN V2Mark.
//
//  The door marks are authored for a 110dp tile. These live in a **73dp** tile —
//  four columns instead of three — and that is not a scale factor, it is a
//  different drawing problem. At 73dp a shape has room for one idea and no
//  interior detail: the scan strip's three frames blur into a smear, and the
//  open book's two pages become a lump. Every mark below is drawn for the size
//  it will actually be seen at.
//
//  ⚠️ AND WHY NONE OF THEM IS A LITERAL PICTURE OF THE PROBLEM.
//
//  Several of these brackets are frightening — complications, mental health.
//  A mark that illustrates the fear (a warning triangle, a crying face) makes
//  the grid a wall of alarms, which is the alarmist register this product exists
//  to refuse. So each mark shows the SHAPE OF THE HELP rather than the shape of
//  the problem: a steady pulse rather than a warning, a calm sky rather than a
//  sad face.
// =============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// One per pregnancy bracket, in the workbook's demand order.
enum BracketMark {
  scans,
  complications,
  safety,
  nutrition,
  symptoms,
  labour,
  garbh,
  fitness,
  mind,
  skin,
  // ---- Parenting -----------------------------------------------------------
  // Four parenting brackets reuse a pregnancy mark rather than getting their
  // own, and the reuse is meaning-led rather than lazy: feeding IS a bowl,
  // health IS a steady pulse, behaviour IS weather, and maternal recovery IS
  // the body figure. Drawing a second bowl would give the set two shapes for
  // one idea, which is how an icon language stops being a language.
  moon,
  steps,
  seat,
  blocks,
  swaddle,
  basket,
  lamp,
}

/// Maps a bracket id to its mark. Lives here rather than in the data table so
/// the table stays free of anything that has to be looked at to be judged.
BracketMark? bracketMarkFor(String bracketId) => switch (bracketId) {
      'pregnancy_scans_tests' => BracketMark.scans,
      'pregnancy_complications' => BracketMark.complications,
      'pregnancy_is_it_safe' => BracketMark.safety,
      'pregnancy_nutrition' => BracketMark.nutrition,
      'pregnancy_symptoms' => BracketMark.symptoms,
      'pregnancy_labour' => BracketMark.labour,
      'pregnancy_garbh' => BracketMark.garbh,
      'pregnancy_fitness' => BracketMark.fitness,
      'pregnancy_mental_health' => BracketMark.mind,
      'pregnancy_belly_skin' => BracketMark.skin,
      // ---- Parenting ---------------------------------------------------
      'parenting_sleep' => BracketMark.moon,
      'parenting_feeding' => BracketMark.nutrition,
      'parenting_health' => BracketMark.complications,
      'parenting_development' => BracketMark.steps,
      'parenting_behaviour' => BracketMark.mind,
      'parenting_potty' => BracketMark.seat,
      'parenting_early_learning' => BracketMark.blocks,
      'parenting_first_40' => BracketMark.swaddle,
      'parenting_maternal' => BracketMark.fitness,
      'parenting_buying' => BracketMark.basket,
      'parenting_traditional' => BracketMark.lamp,
      // ---- TTC ----------------------------------------------------------
      // ⚠️ ALL SEVEN REUSE AN EXISTING MARK, and none of the reuses is a
      // shortage of ideas — each is the same idea arriving in a third stage:
      //
      //   · the cycle IS the moon. Every language that has a word for the
      //     menstrual month borrowed it from the lunar one, so the crescent is
      //     not a stand-in for the cycle mark, it is the cycle mark.
      //   · PCOS IS a steady pulse — a condition to manage, drawn as the shape
      //     of the help rather than the shape of the alarm.
      //   · infertility work IS reports and tests, which is the scan strip.
      //   · preconception nutrition IS the bowl.
      //   · after a loss IS the calm sky — the same mark pregnancy uses for
      //     mental health, which is exactly the continuity `theme` exists for.
      //   · mind-body prep IS the lotus, the same practice one stage earlier.
      //
      // Drawing seven new marks that mean things the set already says would
      // give the app two shapes per idea, which is the point at which an icon
      // language stops being one.
      'ttc_conceiving' => BracketMark.moon,
      'ttc_pcos' => BracketMark.complications,
      'ttc_infertility' => BracketMark.scans,
      'ttc_preconception_health' => BracketMark.nutrition,
      'ttc_male_fertility' => BracketMark.fitness,
      'ttc_after_loss' => BracketMark.mind,
      'ttc_mind_body' => BracketMark.garbh,
      _ => null,
    };

class V3BracketArt extends StatelessWidget {
  const V3BracketArt({super.key, required this.mark, required this.tint});

  final BracketMark mark;

  /// The tile's pastel. Everything else is derived — see v2_block_art.dart for
  /// why passing a flat colour instead produced six grey lumps.
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final h = HSLColor.fromColor(tint);
    final seed = h.withSaturation(0.46).withLightness(0.46).toColor();
    return CustomPaint(painter: _BracketPainter(mark, seed), size: Size.infinite);
  }
}

class _BracketPainter extends CustomPainter {
  _BracketPainter(this.mark, this.seed);

  final BracketMark mark;
  final Color seed;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final s = side / 100;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);

    final obj = Paint()..color = seed.withValues(alpha: 0.92);
    final soft = Paint()..color = seed.withValues(alpha: 0.34);
    final cut = Paint()..color = Colors.white.withValues(alpha: 0.88);
    Paint line(double w, Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = c;

    // The halo — what the set shares.
    canvas.drawCircle(
      Offset(50 * s, 50 * s),
      42 * s,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(50 * s, 50 * s),
          42 * s,
          [seed.withValues(alpha: 0.15), seed.withValues(alpha: 0.0)],
          [0.3, 1.0],
        ),
    );

    switch (mark) {
      // Two frames of a scan strip. THREE at this size becomes a smear — the
      // door-mark version has three because it had 110dp to spend.
      case BracketMark.scans:
        for (var i = 0; i < 2; i++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(24 * s, (24 + i * 30) * s, 52 * s, 24 * s),
              Radius.circular(5 * s),
            ),
            i == 0 ? obj : soft,
          );
        }

      // A steady pulse, not a warning triangle. This bracket holds the
      // frightening things, and a mark that illustrates the fear turns the grid
      // into a wall of alarms.
      case BracketMark.complications:
        canvas.drawCircle(Offset(50 * s, 50 * s), 32 * s, obj);
        canvas.drawPath(
          Path()
            ..moveTo(24 * s, 50 * s)
            ..lineTo(38 * s, 50 * s)
            ..lineTo(44 * s, 34 * s)
            ..lineTo(54 * s, 64 * s)
            ..lineTo(61 * s, 50 * s)
            ..lineTo(76 * s, 50 * s),
          line(5, Colors.white.withValues(alpha: 0.92)),
        );

      // A shield with a tick knocked out. The most literal mark in the set, on
      // purpose — "is it safe?" is the one question she arrives already asking
      // in those words.
      case BracketMark.safety:
        final shield = Path()
          ..moveTo(50 * s, 14 * s)
          ..lineTo(80 * s, 27 * s)
          ..cubicTo(80 * s, 62 * s, 68 * s, 80 * s, 50 * s, 88 * s)
          ..cubicTo(32 * s, 80 * s, 20 * s, 62 * s, 20 * s, 27 * s)
          ..close();
        final tick = Path()
          ..moveTo(36 * s, 49 * s)
          ..lineTo(46 * s, 60 * s)
          ..lineTo(65 * s, 38 * s)
          ..lineTo(71 * s, 45 * s)
          ..lineTo(46 * s, 73 * s)
          ..lineTo(30 * s, 56 * s)
          ..close();
        canvas.drawPath(
            Path.combine(PathOperation.difference, shield, tick), obj);

      // A bowl with something in it. Not a plate — a plate seen from above at
      // 73dp is a circle, and a circle is already the halo.
      case BracketMark.nutrition:
        canvas.drawPath(
          Path()
            ..moveTo(16 * s, 48 * s)
            ..lineTo(84 * s, 48 * s)
            ..cubicTo(84 * s, 76 * s, 68 * s, 88 * s, 50 * s, 88 * s)
            ..cubicTo(32 * s, 88 * s, 16 * s, 76 * s, 16 * s, 48 * s)
            ..close(),
          obj,
        );
        canvas.drawOval(
            Rect.fromLTWH(34 * s, 18 * s, 32 * s, 24 * s), soft);

      // Three bands, the middle one strongest — a body that does not feel the
      // same all over. Abstract on purpose: a literal pregnant silhouette in a
      // 73dp tile reads as a pictogram on a toilet door.
      case BracketMark.symptoms:
        for (var i = 0; i < 3; i++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH((18 + i * 4) * s, (28 + i * 18) * s,
                  (64 - i * 8) * s, 13 * s),
              Radius.circular(6.5 * s),
            ),
            i == 1 ? obj : soft,
          );
        }

      // The bag. Everyone recognises it, and by the time this bracket matters
      // she has already been told to pack one.
      case BracketMark.labour:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(16 * s, 36 * s, 68 * s, 50 * s),
              Radius.circular(10 * s)),
          obj,
        );
        canvas.drawArc(
            Rect.fromLTWH(36 * s, 14 * s, 28 * s, 34 * s), math.pi, math.pi,
            false, line(6, seed.withValues(alpha: 0.55)));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(40 * s, 54 * s, 20 * s, 7 * s),
              Radius.circular(3.5 * s)),
          cut,
        );

      // The lotus, carried over from the door marks — this is the one bracket
      // that already had a mark and already had a colour, and changing either
      // would break a recognition the app has been teaching for weeks.
      case BracketMark.garbh:
        void petal(double turns, double alpha) {
          canvas.save();
          canvas.translate(50 * s, 76 * s);
          canvas.rotate(turns);
          canvas.drawPath(
            Path()
              ..moveTo(0, 0)
              ..quadraticBezierTo(-19 * s, -30 * s, 0, -54 * s)
              ..quadraticBezierTo(19 * s, -30 * s, 0, 0)
              ..close(),
            Paint()..color = seed.withValues(alpha: alpha),
          );
          canvas.restore();
        }

        petal(-0.72, 0.40);
        petal(0.72, 0.40);
        petal(0, 0.92);

      // ⚠️ WAS A WIFI SYMBOL. An arc over a centred dot is the signal-strength
      // glyph on every phone ever made, and no amount of intent overrides a
      // shape that universal. Caught in the offline render, before it reached a
      // tile — which is the entire reason the render exists.
      //
      // A figure mid-stretch instead: head, and one thick sweep for the body.
      // Two elements, unmistakably a person, and still not a specific pose —
      // this bracket covers yoga, walking and everything between.
      case BracketMark.fitness:
        canvas.drawCircle(Offset(36 * s, 26 * s), 12 * s, obj);
        canvas.drawPath(
          Path()
            ..moveTo(34 * s, 44 * s)
            ..cubicTo(34 * s, 62 * s, 46 * s, 70 * s, 66 * s, 66 * s),
          line(13, seed.withValues(alpha: 0.92)),
        );
        canvas.drawPath(
          Path()
            ..moveTo(38 * s, 60 * s)
            ..cubicTo(40 * s, 74 * s, 44 * s, 82 * s, 56 * s, 86 * s),
          line(11, seed.withValues(alpha: 0.42)),
        );

      // A cloud with light behind it. Weather, not a face — a mark that draws
      // sadness makes the tile a diagnosis before she has opened it.
      case BracketMark.mind:
        canvas.drawCircle(Offset(66 * s, 34 * s), 15 * s, soft);
        final cloud = Path()
          ..addOval(Rect.fromLTWH(18 * s, 44 * s, 34 * s, 30 * s))
          ..addOval(Rect.fromLTWH(38 * s, 36 * s, 34 * s, 34 * s))
          ..addOval(Rect.fromLTWH(54 * s, 48 * s, 28 * s, 26 * s))
          ..addRect(Rect.fromLTWH(30 * s, 58 * s, 44 * s, 16 * s));
        canvas.drawPath(cloud, obj);

      // A drop. Skin, oil, care — and the only mark in the set with a single
      // unbroken silhouette, which is what makes it findable at the end of a
      // row of busier shapes.
      case BracketMark.skin:
        canvas.drawPath(
          Path()
            ..moveTo(50 * s, 12 * s)
            ..cubicTo(74 * s, 42 * s, 82 * s, 56 * s, 82 * s, 64 * s)
            ..cubicTo(82 * s, 79 * s, 68 * s, 90 * s, 50 * s, 90 * s)
            ..cubicTo(32 * s, 90 * s, 18 * s, 79 * s, 18 * s, 64 * s)
            ..cubicTo(18 * s, 56 * s, 26 * s, 42 * s, 50 * s, 12 * s)
            ..close(),
          obj,
        );
        canvas.drawCircle(Offset(38 * s, 64 * s), 8 * s, cut);

      // ---- Parenting ------------------------------------------------------

      // A crescent, cut rather than drawn, so it is one shape at any size.
      case BracketMark.moon:
        final full = Path()
          ..addOval(Rect.fromCircle(center: Offset(52 * s, 50 * s), radius: 34 * s));
        final bite = Path()
          ..addOval(Rect.fromCircle(
              center: Offset(70 * s, 38 * s), radius: 32 * s));
        canvas.drawPath(Path.combine(PathOperation.difference, full, bite), obj);
        for (final st in const [[26.0, 26.0], [30.0, 74.0], [74.0, 78.0]]) {
          canvas.drawCircle(
              Offset(st[0] * s, st[1] * s), 3.5 * s, soft);
        }

      // ⚠️ WAS A BAR CHART. Three rising rectangles is the analytics glyph,
      // and this product forbids scoring a child above almost anything else —
      // a tile that looks like a performance graph makes the bracket a report
      // card before she has opened it. Caught in the offline render.
      //
      // A path of stepping stones instead: four, rising, with the third one
      // filled. Sequence and position, no magnitude, nothing to be behind on.
      case BracketMark.steps:
        const stones = [
          [20.0, 76.0, 9.0],
          [38.0, 64.0, 10.0],
          [58.0, 50.0, 13.0],
          [78.0, 34.0, 9.0],
        ];
        for (var i = 0; i < stones.length; i++) {
          final st = stones[i];
          canvas.drawOval(
            Rect.fromCenter(
                center: Offset(st[0] * s, st[1] * s),
                width: st[2] * 2 * s,
                height: st[2] * 1.25 * s),
            i == 2 ? obj : soft,
          );
        }

      // A potty seat, seen from the front: bowl plus back-rest. Simple enough
      // to survive 73dp and specific enough that nothing else reads into it.
      case BracketMark.seat:
        // The bowl.
        canvas.drawPath(
          Path()
            ..moveTo(20 * s, 50 * s)
            ..lineTo(80 * s, 50 * s)
            ..quadraticBezierTo(78 * s, 84 * s, 50 * s, 84 * s)
            ..quadraticBezierTo(22 * s, 84 * s, 20 * s, 50 * s)
            ..close(),
          obj,
        );
        // The back-rest, behind it.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(30 * s, 18 * s, 40 * s, 30 * s),
              Radius.circular(12 * s)),
          soft,
        );
        // The seat opening, knocked out so it reads as a seat and not a pot.
        canvas.drawOval(
            Rect.fromLTWH(34 * s, 54 * s, 32 * s, 15 * s), cut);

      // Two stacked blocks and one beside them. Not letters — the alphabet on a
      // toy is the visual shorthand for tutoring, which is the register this
      // bracket most needs to avoid.
      case BracketMark.blocks:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(16 * s, 50 * s, 34 * s, 34 * s),
              Radius.circular(7 * s)),
          obj,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(24 * s, 16 * s, 30 * s, 30 * s),
              Radius.circular(6 * s)),
          soft,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(56 * s, 56 * s, 28 * s, 28 * s),
              Radius.circular(6 * s)),
          soft,
        );

      // ⚠️ WAS A USER AVATAR. A centred circle above a dome is the account
      // icon on every screen ever built, and no context overrides it.
      //
      // Tilted, wrapped, and off-centre instead: a cocoon lying at an angle
      // with the head at one end and one fold across it. Asymmetry is what
      // stops it being a symbol and starts it being a baby.
      case BracketMark.swaddle:
        canvas.save();
        canvas.translate(50 * s, 54 * s);
        canvas.rotate(-0.38);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: 40 * s, height: 74 * s),
              Radius.circular(20 * s)),
          obj,
        );
        // One fold across the wrap, knocked out.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(0, 6 * s), width: 40 * s, height: 5 * s),
              Radius.circular(2.5 * s)),
          cut,
        );
        canvas.restore();
        canvas.drawCircle(Offset(35 * s, 26 * s), 13 * s, soft);

      // A basket. Not a trolley and not a bag: a trolley is a supermarket and a
      // bag is checkout, and this bracket is about deciding rather than buying.
      case BracketMark.basket:
        canvas.drawPath(
          Path()
            ..moveTo(14 * s, 44 * s)
            ..lineTo(86 * s, 44 * s)
            ..lineTo(74 * s, 84 * s)
            ..lineTo(26 * s, 84 * s)
            ..close(),
          obj,
        );
        canvas.drawArc(Rect.fromLTWH(32 * s, 16 * s, 36 * s, 44 * s),
            math.pi, math.pi, false, line(6, seed.withValues(alpha: 0.5)));

      // A diya. The one mark in the set that is culturally specific, and it is
      // the one bracket where that is the entire point — "Indian in material,
      // not in applied motif" does not forbid a lamp when the bracket IS the
      // rituals.
      case BracketMark.lamp:
        canvas.drawPath(
          Path()
            ..moveTo(16 * s, 58 * s)
            ..quadraticBezierTo(50 * s, 92 * s, 84 * s, 58 * s)
            ..close(),
          obj,
        );
        canvas.drawPath(
          Path()
            ..moveTo(50 * s, 14 * s)
            ..quadraticBezierTo(64 * s, 34 * s, 50 * s, 52 * s)
            ..quadraticBezierTo(36 * s, 34 * s, 50 * s, 14 * s)
            ..close(),
          soft,
        );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BracketPainter old) =>
      old.mark != mark || old.seed != seed;
}

/// Exposed for the offline preview recipe in v3_tip_art.dart — ten marks judged
/// side by side beats ten builds.
CustomPainter bracketMarkPainter(BracketMark m, Color seed) =>
    _BracketPainter(m, seed);
