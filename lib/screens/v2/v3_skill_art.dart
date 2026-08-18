// =============================================================================
//  V3SkillArt — one drawn mark per skilling bracket
// -----------------------------------------------------------------------------
//  Twelve marks, in the same language as `v3_bracket_art.dart`: one filled focal
//  shape in the tile's own hue, detail knocked out in WHITE rather than laid on
//  in a second colour, every tone derived from the tint. Drawn for a 73dp tile —
//  four columns — so each shape gets ONE idea and no interior detail.
//
//  ⚠️ WHY TWELVE NEW MARKS RATHER THAN REUSE.
//
//  TTC took all seven of its marks from the existing set, because each one was
//  the same idea arriving in a third stage — the cycle IS the moon, PCOS IS a
//  steady pulse. Skilling shares nothing with the other three: there is no
//  existing mark that means "mental arithmetic" or "reading habit", and reaching
//  for the nearest one would put a nutrition bowl on a maths door. Reuse is
//  meaning-led or it is noise.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE RULE THAT SHAPED HALF OF THESE: NOTHING HERE MAY SCORE A CHILD
//  ---------------------------------------------------------------------------
//
//  The obvious mark for most of these skills is a measurement — a target, a
//  bar chart, a gauge, a filled progress ring, a medal. Every one of them is
//  banned by the product's own rules, and the ban has already bitten once: the
//  parenting Development mark shipped as a BAR CHART and had to be redrawn as
//  stepping stones, because a bar chart of a child's abilities is a score, and
//  this product does not give children scores.
//
//  Skilling is where that pressure is highest, because the workbook itself asks
//  for challenges, streaks, certificates and progress reports. So:
//
//    · **Focus** is an aperture, not a bullseye. A target says "hit it".
//    · **Memory** is a spiral, not a ranked list.
//    · **Critical thinking** is a branch, not a tick.
//    · **Creativity** is a palette, not a starred artwork.
//
//  Every mark shows the ACTIVITY, never the attainment.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One per skilling bracket, in the workbook's order.
enum SkillMark {
  focus,
  speaking,
  communication,
  reasoning,
  // ⚠️ `character`, not `values` — Dart reserves `values` on every enum for
  // the generated list of members, so a case called that will not compile.
  character,
  maths,
  coding,
  reading,
  creativity,
  emotions,
  stillness,
  memory,
}

/// Maps a skilling bracket id to its mark.
SkillMark? skillMarkFor(String bracketId) => switch (bracketId) {
      'skilling_focus' => SkillMark.focus,
      'skilling_confidence' => SkillMark.speaking,
      'skilling_communication' => SkillMark.communication,
      'skilling_critical_thinking' => SkillMark.reasoning,
      'skilling_values' => SkillMark.character,
      'skilling_maths' => SkillMark.maths,
      'skilling_coding' => SkillMark.coding,
      'skilling_reading' => SkillMark.reading,
      'skilling_creativity' => SkillMark.creativity,
      'skilling_emotional' => SkillMark.emotions,
      'skilling_stillness' => SkillMark.stillness,
      'skilling_memory' => SkillMark.memory,
      _ => null,
    };

class V3SkillArt extends StatelessWidget {
  const V3SkillArt({super.key, required this.mark, required this.tint});

  final SkillMark mark;

  /// The tile's pastel. Everything else is derived — see `v2_block_art.dart`
  /// for why passing a flat colour instead produced six grey lumps.
  final Color tint;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _SkillPainter(mark, skillMarkSeed(tint)),
        size: Size.infinite,
      );
}

/// Public so a preview harness derives the same colour the widget does. The
/// door marks shipped as grey lumps because the preview and the screen
/// disagreed about one paint.
Color skillMarkSeed(Color tint) =>
    HSLColor.fromColor(tint).withSaturation(0.46).withLightness(0.46).toColor();

/// Draws straight onto a canvas, without a widget tree.
void paintSkillMark(Canvas canvas, SkillMark mark, Color tint, double size) =>
    _SkillPainter(mark, skillMarkSeed(tint)).paint(canvas, Size(size, size));

class _SkillPainter extends CustomPainter {
  _SkillPainter(this.mark, this.seed);

  final SkillMark mark;
  final Color seed;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final s = side / 100;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(s);

    final obj = Paint()..color = seed.withValues(alpha: 0.92);
    final soft = Paint()..color = seed.withValues(alpha: 0.34);
    final white = Paint()..color = Colors.white.withValues(alpha: 0.92);
    Paint stroke(double w, {Color? c}) => Paint()
      ..color = c ?? seed.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Paint cut(double w) =>
        stroke(w, c: Colors.white.withValues(alpha: 0.92));

    // ⚠️ NO HALO HERE, UNLIKE THE BRACKET MARKS — removed after seeing all
    // twelve on a phone together.
    //
    // The bracket marks carry a soft disc behind the focal shape and it works
    // there, because those shapes are open silhouettes — a crescent, a bowl, a
    // figure — and the disc gives them something to sit against.
    //
    // Half of these are CLOSED shapes that already fill their box: the abacus,
    // the coding well, the palette, the memory spiral, the focus eye. A disc
    // behind a shape that is already round reads as a second, softer copy of
    // the same object — a smudge, not depth. Across a twelve-tile grid that is
    // twelve smudges, and it was the first thing anyone noticed.
    //
    // The tile's own pastel is the ground. It does not need a second one.

    switch (mark) {
      // ---- FOCUS ------------------------------------------------------------
      // An aperture: a filled disc with a white ring cut through it, and one
      // blade. ⚠️ NOT a bullseye — a target says "hit it", which is a score.
      case SkillMark.focus:
        // ⚠️ AN EYE, AFTER AN APERTURE FAILED. The first draw was a disc with a
        // white centre and one blade, meant to read as a camera iris; offline it
        // read as a DIAL — a knob you turn, which is the opposite of attention.
        //
        // It still may not be a bullseye. A target says "hit it", and a target
        // on a child's attention door is a score with a nicer shape. An eye is
        // the act of looking, which is what attention actually is.
        canvas.drawPath(
            Path()
              ..moveTo(12, 50)
              ..cubicTo(30, 24, 70, 24, 88, 50)
              ..cubicTo(70, 76, 30, 76, 12, 50)
              ..close(),
            obj);
        canvas.drawCircle(const Offset(50, 50), 17, white);
        canvas.drawCircle(const Offset(50, 50), 9, obj);

      // ---- CONFIDENCE & SPEAKING --------------------------------------------
      // A microphone. The one skill whose everyday object is unambiguous, and
      // a subtler mark would only cost legibility.
      case SkillMark.speaking:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(38, 16, 62, 58), const Radius.circular(12)),
            obj);
        canvas.drawArc(const Rect.fromLTRB(26, 32, 74, 76), 0, math.pi,
            false, stroke(7));
        canvas.drawPath(
            Path()
              ..moveTo(50, 70)
              ..lineTo(50, 84),
            stroke(7));
        canvas.drawPath(
            Path()
              ..moveTo(34, 86)
              ..lineTo(66, 86),
            stroke(7));

      // ---- COMMUNICATION ----------------------------------------------------
      // Two bubbles, overlapping — a conversation, not an announcement. One
      // path so the overlap fills once; two 92% shapes would show a seam.
      case SkillMark.communication:
        canvas.drawPath(
            Path()
              ..addRRect(RRect.fromRectAndRadius(
                  const Rect.fromLTRB(12, 20, 62, 54),
                  const Radius.circular(14)))
              ..moveTo(24, 52)
              ..lineTo(20, 68)
              ..lineTo(38, 52)
              ..close(),
            soft);
        canvas.drawPath(
            Path()
              ..addRRect(RRect.fromRectAndRadius(
                  const Rect.fromLTRB(42, 42, 90, 74),
                  const Radius.circular(14)))
              ..moveTo(78, 72)
              ..lineTo(82, 88)
              ..lineTo(64, 72)
              ..close(),
            obj);
        for (final x in [54.0, 66.0, 78.0]) {
          canvas.drawCircle(Offset(x, 58), 4, white);
        }

      // ---- CRITICAL THINKING ------------------------------------------------
      // A branch: one question opening into two. Reasoning drawn as the SHAPE
      // of thinking rather than as a right answer — no tick, no bulb.
      case SkillMark.reasoning:
        canvas.drawPath(
            Path()
              ..moveTo(28, 82)
              ..lineTo(28, 56)
              ..lineTo(72, 56)
              ..moveTo(50, 56)
              ..lineTo(50, 34),
            stroke(7));
        canvas.drawCircle(const Offset(50, 22), 13, obj);
        canvas.drawCircle(const Offset(28, 86), 9, obj);
        canvas.drawCircle(const Offset(72, 68), 9, obj);

      // ---- VALUES & CHARACTER -----------------------------------------------
      // A seedling. ⚠️ NOT the lamp — that mark already means TRADITION on the
      // parenting grid, and values is a neighbouring idea rather than the same
      // one. Character is the thing that grows, so it is drawn growing.
      case SkillMark.character:
        canvas.drawPath(
            Path()
              ..moveTo(50, 88)
              ..lineTo(50, 44),
            stroke(8));
        canvas.drawPath(
            Path()
              ..moveTo(50, 56)
              ..cubicTo(30, 56, 22, 44, 22, 32)
              ..cubicTo(40, 32, 50, 42, 50, 56)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(50, 48)
              ..cubicTo(68, 48, 78, 38, 78, 26)
              ..cubicTo(60, 26, 50, 36, 50, 48)
              ..close(),
            obj);

      // ---- MATHS ------------------------------------------------------------
      // An abacus — the workbook's own subject (vedic maths, abacus, mental
      // drills, ~33,100 searches) and the most legible object in the set.
      case SkillMark.maths:
        // ⚠️ THE FIRST RENDER CAME OUT AS A SETTINGS ICON. Three horizontal
        // rails with one knob each IS the slider glyph — the beads were doing
        // the job of handles. What makes an abacus an abacus is the FRAME: two
        // vertical posts holding the rails, and more than one bead per rail so
        // the eye reads counting rather than adjusting.
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(14, 18, 86, 84), const Radius.circular(10)),
            obj);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(24, 28, 76, 74), const Radius.circular(4)),
            white);
        for (final y in [38.0, 51.0, 64.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(24, y)
                ..lineTo(76, y),
              stroke(3));
        }
        // Beads: three on each rail, at different positions, so the abacus is
        // mid-count. An abacus at rest is a grid.
        for (final b in [
          (34.0, 38.0), (43.0, 38.0), (66.0, 38.0),
          (30.0, 51.0), (52.0, 51.0), (61.0, 51.0),
          (38.0, 64.0), (47.0, 64.0), (70.0, 64.0),
        ]) {
          canvas.drawCircle(Offset(b.$1, b.$2), 5, obj);
        }

      // ---- CODING & AI ------------------------------------------------------
      // Angle brackets in a well. ⚠️ NOT the `blocks` mark: that one means
      // early learning on the parenting grid, and block-based coding borrowing
      // it would give one shape two meanings across two stages.
      case SkillMark.coding:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(14, 22, 86, 80), const Radius.circular(16)),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(40, 38)
              ..lineTo(28, 51)
              ..lineTo(40, 64),
            cut(7));
        canvas.drawPath(
            Path()
              ..moveTo(60, 38)
              ..lineTo(72, 51)
              ..lineTo(60, 64),
            cut(7));

      // ---- READING ----------------------------------------------------------
      // An open book. The same object the pregnancy Read mark uses, redrawn for
      // this size rather than reused — the door marks are authored for 110dp and
      // that book's two pages become a lump at 73.
      case SkillMark.reading:
        // ⚠️ ONE PATH, TWO SUB-PATHS. Drawn as two separate halves the spine
        // overlapped and composited twice at 92%, so the middle came out as a
        // dark bar and the book read as a folded card. Same lesson as the brain
        // mark in v3_dev_mark.dart.
        final book = Path()
          ..moveTo(50, 32)
          ..cubicTo(38, 22, 24, 22, 13, 26)
          ..lineTo(13, 74)
          ..cubicTo(24, 70, 38, 70, 50, 80)
          ..close()
          ..moveTo(50, 32)
          ..cubicTo(62, 22, 76, 22, 87, 26)
          ..lineTo(87, 74)
          ..cubicTo(76, 70, 62, 70, 50, 80)
          ..close();
        canvas.drawPath(book, obj);
        // The spine, knocked out — it is the line that separates a book from a
        // leaf, and the pages that say it is open.
        canvas.drawPath(
            Path()
              ..moveTo(50, 32)
              ..lineTo(50, 80),
            cut(5));
        for (final y in [44.0, 55.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(22, y)
                ..lineTo(41, y + 2)
                ..moveTo(59, y + 2)
                ..lineTo(78, y),
              cut(3.5));
        }

      // ---- CREATIVITY -------------------------------------------------------
      // A palette. ⚠️ Not a starred or framed artwork — the mark is the making,
      // never the piece that got praised.
      case SkillMark.creativity:
        canvas.drawPath(
            Path()
              ..addOval(const Rect.fromLTRB(14, 18, 86, 84))
              ..addOval(const Rect.fromLTRB(54, 50, 78, 72))
              ..fillType = PathFillType.evenOdd,
            obj);
        canvas.drawCircle(const Offset(34, 36), 7, white);
        canvas.drawCircle(const Offset(56, 30), 7, white);
        canvas.drawCircle(const Offset(28, 60), 7, white);

      // ---- EMOTIONAL INTELLIGENCE -------------------------------------------
      // A heart with a wave through it — feeling, and the steadying of it.
      // Resilience is the wave, not a shield: nothing here is about defence.
      case SkillMark.emotions:
        canvas.drawPath(
            Path()
              ..moveTo(50, 84)
              ..cubicTo(14, 60, 18, 30, 34, 26)
              ..cubicTo(44, 23, 50, 32, 50, 38)
              ..cubicTo(50, 32, 56, 23, 66, 26)
              ..cubicTo(82, 30, 86, 60, 50, 84)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(28, 54)
              ..cubicTo(38, 44, 42, 64, 52, 54)
              ..cubicTo(62, 44, 66, 60, 74, 52),
            cut(6));

      // ---- STILLNESS --------------------------------------------------------
      // A seated figure. Kid meditation and yoga, drawn as a posture rather
      // than as a streak — the workbook asks for streaks here and the mark is
      // one place the product can quietly decline.
      case SkillMark.stillness:
        canvas.drawCircle(const Offset(50, 26), 13, obj);
        canvas.drawPath(
            Path()
              ..moveTo(50, 42)
              ..lineTo(50, 64),
            stroke(11));
        // The crossed legs: one wide triangle, which is the whole silhouette.
        canvas.drawPath(
            Path()
              ..moveTo(20, 80)
              ..cubicTo(30, 62, 70, 62, 80, 80)
              ..close(),
            obj);
        // Arms resting on the knees.
        canvas.drawPath(
            Path()
              ..moveTo(50, 50)
              ..lineTo(26, 70)
              ..moveTo(50, 50)
              ..lineTo(74, 70),
            stroke(7));

      // ---- MEMORY -----------------------------------------------------------
      // A spiral: recall drawn as a path inward, which is what a memory
      // technique actually is. No list, no rank, nothing counted.
      case SkillMark.memory:
        canvas.drawCircle(const Offset(50, 50), 32, obj);
        final spiral = Path()..moveTo(50, 22);
        for (var i = 0; i <= 90; i++) {
          final t = i / 90;
          final ang = -math.pi / 2 + t * math.pi * 2.6;
          final r = 28 * (1 - t * 0.82);
          spiral.lineTo(50 + r * math.cos(ang), 50 + r * math.sin(ang));
        }
        canvas.drawPath(spiral, cut(6));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkillPainter old) =>
      old.mark != mark || old.seed != seed;
}
