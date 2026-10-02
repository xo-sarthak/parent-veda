// =============================================================================
//  Spiritual Reading's marks (2026-10-02)
// -----------------------------------------------------------------------------
//  The user: "Spiritual reading also uses emojis, which we can remove and create
//  the new glyphs and marks for it."
//
//  Each tradition carried an emoji (`SpiritualTradition.symbol`: 🕉️ ☪️ ✝️ ☸️ and
//  so on) in its chip, its card, its page title and, through the same data, in the
//  Garbh Samvad daily headings and the classic home's chips. An emoji is the
//  phone's own picture: it changes with the device and sits outside the app's
//  look. These are drawn instead, in the one family the rest of the app uses
//  (`TtcTabPainter`): a tinted disc, a deep ink, a soft ink, and the family's
//  three line weights (kLine, kBand, kDetail) so a mark here and a mark on a TTC
//  door are the same hand.
//
//  ⚠️ SIMPLE ON PURPOSE, AND RESPECTFUL. Each is a quiet geometric reduction of
//  something the tradition itself uses, never a decoration and never a joke:
//      hindu     a lit diya (the lamp the tool's own copy already names)
//      islam     a crescent with a star
//      christian a cross
//      sikh      a ring, a double-edged blade and two curved edges (the khanda,
//                reduced)
//      jain      an open palm with a wheel in it (the ahimsa hand, reduced)
//      buddhist  the eight-spoked wheel
//      others    a point of light with rays, for every other tradition
//  They carry no words and are decorative to a screen reader: the tradition's
//  name is always beside them (`ExcludeSemantics`).
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ttc/doors/ttc_tab_art.dart' show TtcTabPainter, ttcTabGround, ttcTabInk;
import '../v2/v2_palette.dart' show V2PaletteStore, v2BlockTint;

/// The tool's hue (the Tools tab's "Keep" group; `SpiritualReadingScreen`).
const double kSpiritualHue = 330;

/// The mark for a tradition, in the tool's tint, in a [size] box.
Widget spiritualMark(String traditionId, {double size = 44}) => SpiritualMark(
      traditionId: traditionId,
      tint: v2BlockTint(kSpiritualHue % 360, V2PaletteStore.instance.current),
      size: size,
    );

class SpiritualMark extends StatelessWidget {
  const SpiritualMark({
    super.key,
    required this.traditionId,
    required this.tint,
    this.size = 44,
  });

  final String traditionId;
  final Color tint;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: SpiritualMarkPainter(traditionId, tint)),
        ),
      );
}

class SpiritualMarkPainter extends CustomPainter {
  SpiritualMarkPainter(this.id, this.tint);

  final String id;
  final Color tint;

  // The family's weights: one set, never per mark.
  static const double kLine = TtcTabPainter.kLine;
  static const double kDetail = TtcTabPainter.kDetail;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    if (side <= 0) return;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);

    final groundC = ttcTabGround(tint);
    final inkC = ttcTabInk(tint);
    final ink = Paint()..color = inkC;
    final soft = Paint()..color = inkC.withValues(alpha: 0.32);
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final line = stroke(inkC, kLine);
    final lineSoft = stroke(inkC.withValues(alpha: 0.32), kLine);
    final detail = stroke(inkC, kDetail);
    final knock = stroke(groundC, kDetail);
    const c = Offset(50, 50);

    // The disc every mark sits on.
    canvas.drawCircle(c, 46, Paint()..color = groundC);

    switch (id) {
      case 'hindu':
        // A lit diya: a shallow bowl, a wick, a flame with a lighter heart.
        canvas.drawPath(
            Path()
              ..moveTo(20, 58)
              ..lineTo(80, 58)
              ..quadraticBezierTo(76, 82, 50, 82)
              ..quadraticBezierTo(24, 82, 20, 58)
              ..close(),
            ink);
        canvas.drawLine(const Offset(50, 58), const Offset(50, 52), line);
        canvas.drawPath(
            Path()
              ..moveTo(50, 14)
              ..quadraticBezierTo(68, 34, 50, 52)
              ..quadraticBezierTo(32, 34, 50, 14)
              ..close(),
            ink);
        canvas.drawPath(
            Path()
              ..moveTo(50, 30)
              ..quadraticBezierTo(58, 40, 50, 49)
              ..quadraticBezierTo(42, 40, 50, 30)
              ..close(),
            Paint()..color = groundC);
        canvas.drawLine(const Offset(34, 90), const Offset(66, 90), lineSoft);

      case 'islam':
        // A crescent (one disc taken out of another) and a small star.
        canvas.drawPath(
            Path.combine(
              PathOperation.difference,
              Path()..addOval(Rect.fromCircle(center: const Offset(46, 52), radius: 30)),
              Path()..addOval(Rect.fromCircle(center: const Offset(58, 46), radius: 25)),
            ),
            ink);
        final star = Path();
        const sc = Offset(69, 32);
        for (var i = 0; i < 10; i++) {
          final r = i.isEven ? 10.0 : 4.2;
          final a = -math.pi / 2 + i * math.pi / 5;
          final pt = Offset(sc.dx + r * math.cos(a), sc.dy + r * math.sin(a));
          i == 0 ? star.moveTo(pt.dx, pt.dy) : star.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(star..close(), ink);

      case 'christian':
        // A cross, with a soft ring of light behind it.
        canvas.drawCircle(c, 30, soft);
        canvas.drawRRect(
            RRect.fromLTRBR(43, 16, 57, 84, const Radius.circular(5)), ink);
        canvas.drawRRect(
            RRect.fromLTRBR(26, 36, 74, 50, const Radius.circular(5)), ink);

      case 'sikh':
        // The khanda, reduced: a ring, a double-edged blade through it, and the
        // two curved edges either side.
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 56), radius: 37),
            math.pi - 0.55, 1.1, false, lineSoft);
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 56), radius: 37),
            -0.55, 1.1, false, lineSoft);
        canvas.drawPath(
            Path()
              ..moveTo(50, 10)
              ..lineTo(58, 28)
              ..lineTo(58, 72)
              ..lineTo(50, 90)
              ..lineTo(42, 72)
              ..lineTo(42, 28)
              ..close(),
            ink);
        canvas.drawLine(const Offset(50, 24), const Offset(50, 76), knock);
        canvas.drawCircle(const Offset(50, 54), 19, stroke(groundC, 10));
        canvas.drawCircle(const Offset(50, 54), 19, line);

      case 'jain':
        // An open palm with a wheel in it: four fingers, a thumb, a ring.
        for (final f in const [
          [37.0, 44.0, 25.0],
          [46.0, 44.0, 17.0],
          [55.0, 44.0, 17.0],
          [64.0, 44.0, 25.0],
        ]) {
          canvas.drawLine(Offset(f[0], f[1]), Offset(f[0], f[2]), stroke(inkC, 8));
        }
        canvas.drawLine(const Offset(32, 62), const Offset(19, 48), stroke(inkC, 8));
        canvas.drawRRect(
            RRect.fromLTRBR(32, 44, 69, 84, const Radius.circular(13)), ink);
        canvas.drawCircle(const Offset(50, 64), 8, knock);
        canvas.drawCircle(const Offset(50, 64), 2.5, Paint()..color = groundC);

      case 'buddhist':
        // The eight-spoked wheel: a rim, a hub, eight spokes.
        canvas.drawCircle(c, 31, line);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawLine(
              Offset(50 + 9 * math.cos(a), 50 + 9 * math.sin(a)),
              Offset(50 + 29 * math.cos(a), 50 + 29 * math.sin(a)),
              detail);
        }
        canvas.drawCircle(c, 9, ink);
        canvas.drawCircle(c, 3.2, Paint()..color = groundC);

      default:
        // Every other tradition: a point of light and its rays.
        canvas.drawCircle(c, 13, ink);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawLine(
              Offset(50 + 22 * math.cos(a), 50 + 22 * math.sin(a)),
              Offset(50 + 33 * math.cos(a), 50 + 33 * math.sin(a)),
              i.isEven ? line : lineSoft);
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(SpiritualMarkPainter old) => old.id != id || old.tint != tint;
}
