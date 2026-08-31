// =============================================================================
//  Mood marks — drawn, not typed
// -----------------------------------------------------------------------------
//  ⚠️ WHY THESE ARE NOT EMOJI. Asked for directly: *"can you not find something
//  else custom made or something like that solves the purpose of representing a
//  mood"* — the read on the shipped row being that a grid of 😌🙂😔😰 looks
//  cheap. It does, and the reason is worth writing down because it is not a
//  matter of taste:
//
//   1. **They are not ours.** An emoji is rendered by the operating system, so
//      the same screen is a Samsung face on one phone, an Apple face on
//      another, and a Noto face on a third. Every other mark in this app is
//      drawn by us and consistent everywhere; these were the only elements that
//      changed identity depending on who was holding the phone.
//
//   2. **They are the wrong weight.** Emoji are full-colour, high-saturation,
//      glossy objects. This stage's entire visual language is flat tints and
//      line work, so four glossy discs in a row read as stickers dropped onto
//      the design rather than as part of it.
//
//   3. **They carry meanings we did not choose.** 😤 is "irritated" here and
//      "triumph" in the Unicode name; 🎭 for mood swings is a stretch in any
//      reading.
//
//  ⚠️ FEATURES ONLY, NO FACE OUTLINE. The tinted bubble the mark sits in IS the
//  face — drawing a circle inside a circle reads as a badge on a button. So
//  each mood is two eyes and a mouth, plus at most one extra stroke, scaled to
//  whatever box it is handed. That is also what keeps it legible at 11pt on the
//  home's day strip, where a detailed drawing would turn to mush.
//
//  ⚠️ `TtcSymptom.emoji` STAYS ON THE MODEL AND IS NO LONGER DRAWN. It is still
//  the right thing for a semantics label and for search, and deleting a field
//  that half the codebase might read is a bigger change than this one needs to
//  be. Nothing renders it any more; `ttcMoodFor` is what decides whether a
//  symptom has a face.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

enum TtcMood { calm, happy, energetic, low, anxious, irritated, swings, tearful }

/// The mood a symptom id represents, or null if it is not a feeling.
///
/// ⚠️ A SWITCH ON IDS, NOT A FIELD ON `TtcSymptom`. The ids are persisted
/// identities — renaming one orphans every day it was ever tapped — so they are
/// the stable thing to key off. Putting a `mood:` on the model would mean the
/// data file importing a drawing concern, and the two would then have to be
/// kept in step by hand.
TtcMood? ttcMoodFor(String symptomId) => switch (symptomId) {
      'calm' => TtcMood.calm,
      'happy' => TtcMood.happy,
      'energetic' => TtcMood.energetic,
      'low' => TtcMood.low,
      'anxious' => TtcMood.anxious,
      'irritated' => TtcMood.irritated,
      'mood_swings' => TtcMood.swings,
      'tearful' => TtcMood.tearful,
      _ => null,
    };

/// A drawn mood mark, sized to [size] and inked in [ink].
class TtcMoodFace extends StatelessWidget {
  const TtcMoodFace(
      {super.key, required this.mood, required this.size, required this.ink});

  final TtcMood mood;
  final double size;
  final Color ink;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _FacePainter(mood: mood, ink: ink)),
      );
}

class _FacePainter extends CustomPainter {
  const _FacePainter({required this.mood, required this.ink});

  final TtcMood mood;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ⚠️ EVERY MEASUREMENT IS A FRACTION OF `s`, INCLUDING THE STROKE. A fixed
    // 2pt line is right at 28pt and a blunt slab at 11pt — the same mark has to
    // work on the logger's bubbles and on the day strip's, which differ by
    // nearly three times. Floored, because below about 1.1 an anti-aliased
    // hairline fades to nothing on a low-density screen.
    final w = math.max(1.1, s * 0.075);
    final line = Paint()
      ..color = ink
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = ink;

    final eyeX = s * 0.19;
    final eyeY = cy - s * 0.11;
    final eyeR = math.max(0.9, s * 0.055);

    void dotEyes() {
      canvas.drawCircle(Offset(cx - eyeX, eyeY), eyeR, dot);
      canvas.drawCircle(Offset(cx + eyeX, eyeY), eyeR, dot);
    }

    /// A mouth as one quadratic curve. [lift] positive smiles, negative frowns.
    void mouth(double lift, {double width = 0.23, double drop = 0.16}) {
      final y = cy + s * drop;
      final half = s * width;
      final path = Path()
        ..moveTo(cx - half, y)
        ..quadraticBezierTo(cx, y + s * lift, cx + half, y);
      canvas.drawPath(path, line);
    }

    switch (mood) {
      // Closed eyes and the smallest smile on the set. Calm is not happy with
      // more teeth; it is happy with less going on.
      case TtcMood.calm:
        for (final side in [-1, 1]) {
          final path = Path()
            ..moveTo(cx + side * eyeX - s * 0.07, eyeY)
            ..quadraticBezierTo(
                cx + side * eyeX, eyeY + s * 0.07, cx + side * eyeX + s * 0.07, eyeY);
          canvas.drawPath(path, line);
        }
        mouth(0.13, width: 0.15);

      case TtcMood.happy:
        dotEyes();
        mouth(0.20);

      // The one mood that is not about the face. Two rays, because "energetic"
      // is a level rather than an expression and a bigger smile would just read
      // as happier.
      case TtcMood.energetic:
        dotEyes();
        mouth(0.18, width: 0.20);
        for (final side in [-1, 1]) {
          canvas.drawLine(
            Offset(cx + side * s * 0.36, cy - s * 0.30),
            Offset(cx + side * s * 0.44, cy - s * 0.38),
            line,
          );
        }

      case TtcMood.low:
        dotEyes();
        mouth(-0.14, drop: 0.24);

      // A wavy mouth, not a frown — anxious is unsettled, not sad, and the two
      // must not collapse into the same drawing.
      case TtcMood.anxious:
        dotEyes();
        final y = cy + s * 0.19;
        final path = Path()..moveTo(cx - s * 0.22, y);
        path.quadraticBezierTo(cx - s * 0.11, y - s * 0.1, cx, y);
        path.quadraticBezierTo(cx + s * 0.11, y + s * 0.1, cx + s * 0.22, y);
        canvas.drawPath(path, line);

      // Brows do the work here. A flat mouth on its own is neutral; angled
      // brows above it are the whole expression.
      case TtcMood.irritated:
        dotEyes();
        for (final side in [-1, 1]) {
          canvas.drawLine(
            Offset(cx + side * s * 0.28, cy - s * 0.30),
            Offset(cx + side * s * 0.11, cy - s * 0.22),
            line,
          );
        }
        canvas.drawLine(Offset(cx - s * 0.17, cy + s * 0.22),
            Offset(cx + s * 0.17, cy + s * 0.22), line);

      // Up on one side, down on the other. Literally both at once, which is
      // what the word means and what a theatre-mask glyph never said.
      case TtcMood.swings:
        dotEyes();
        final y = cy + s * 0.19;
        final path = Path()
          ..moveTo(cx - s * 0.22, y + s * 0.07)
          ..quadraticBezierTo(cx - s * 0.05, y + s * 0.13, cx, y)
          ..quadraticBezierTo(cx + s * 0.05, y - s * 0.13, cx + s * 0.22,
              y - s * 0.07);
        canvas.drawPath(path, line);

      // A small frown and one tear. The tear is the only filled shape on any of
      // the eight, which is what makes this one readable at 11pt.
      case TtcMood.tearful:
        dotEyes();
        mouth(-0.10, drop: 0.24);
        final tx = cx - eyeX;
        final ty = eyeY + s * 0.14;
        final tear = Path()
          ..moveTo(tx, ty)
          ..quadraticBezierTo(tx + s * 0.075, ty + s * 0.12, tx, ty + s * 0.18)
          ..quadraticBezierTo(tx - s * 0.075, ty + s * 0.12, tx, ty)
          ..close();
        canvas.drawPath(tear, dot);
    }
  }

  @override
  bool shouldRepaint(_FacePainter old) => old.mood != mood || old.ink != ink;
}
