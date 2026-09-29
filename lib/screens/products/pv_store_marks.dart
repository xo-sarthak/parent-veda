// =============================================================================
//  PvStoreArt — the store's drawn marks, for rows that take her somewhere
// -----------------------------------------------------------------------------
//  Built 2026-09-29 (the one-app pass on the store). The icon rule the user
//  chose has three levels: DRAWN MARKS for every row you tap to go somewhere,
//  small glyphs for things she logs, line icons only for controls. The
//  storefront's "Shop by need" rows are rows that take her somewhere, and they
//  wore Material line icons (eco, twilight, science, medication, menu book) in
//  grey squares: the one place in the Products tab that looked like a
//  different app from Learn, Tools and More.
//
//  So each need has its own object, drawn in the door family's hand
//  (`ttc_tab_art.dart`), with that family's helpers and weights:
//    · a 100×100 canvas, centred; a ground disc r 46 in the row's tint;
//    · INK (`ttcTabInk`) for the focal shape, SOFT (ink at 32%) behind it,
//      detail KNOCKED OUT in the ground colour, never a third colour;
//    · the family's weights (`TtcTabPainter.kLine`, `kBand`, `kDetail`),
//      round caps, corners 8 on big shapes and 4 on small ones;
//    · the object fills roughly the 18..82 box.
//
//  ONE TINT FOR ALL OF THEM (`kPvStoreMarkHue`), because the user found the
//  Tools marks "more toned" when every group took its own hue. The hue is the
//  sand More gives "Your bookings and orders": commerce reads as one colour.
//
//  The marks (one per need, never shared, the shape of the help):
//    folicTablet     a blister strip of tablets with a leaf (folate is named
//                    for leaves)
//    fertileCalendar a calendar page with a stretch of days picked out
//    pregnancyTest   a test stick lying across, its window with two lines
//    capsules        two capsules, one in front of the other
//    books           two books stacked, the top one with a ribbon
//
//  Mobbin, what set it:
//    · Zocdoc, My health: one drawn object per row (clipboard, capsule,
//      shield), a title and one grey line, a chevron.
//      https://mobbin.com/screens/01d4889f-4689-4aba-b150-33847a54d38b
//    · Alan, My health coverage: every row's object in ONE tint.
//      https://mobbin.com/screens/55c9fb0a-c4cc-4d2e-8620-ac7b3a7b4b8f
//    · Flo's topic marks on a pastel disc, the source of the door family:
//      https://mobbin.com/screens/f983b7eb-82f1-4aa4-b1f0-24a35f1c6a6f
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ttc/doors/ttc_tab_art.dart'
    show TtcTabPainter, ttcTabGround, ttcTabInk;

/// The one hue every store mark takes (More's "Your bookings and orders").
const double kPvStoreMarkHue = 36;

enum PvStoreMark { folicTablet, fertileCalendar, pregnancyTest, capsules, books }

/// A store row's drawn mark. Size comes from the parent box (44dp on a row).
class PvStoreArt extends StatelessWidget {
  const PvStoreArt({super.key, required this.mark, required this.tint});
  final PvStoreMark mark;

  /// The row's pastel (`v2BlockTint(kPvStoreMarkHue, p)`).
  final Color tint;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: CustomPaint(
          painter: PvStorePainter(mark, tint),
          size: Size.infinite,
        ),
      );
}

class PvStorePainter extends CustomPainter {
  PvStorePainter(this.mark, this.tint);
  final PvStoreMark mark;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    // The door rail's canvas, exactly (`TtcTabPainter.paint`).
    final side = math.min(size.width, size.height);
    if (side <= 0) return;
    final s = side / 100;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(s);

    final groundC = ttcTabGround(tint);
    final inkC = ttcTabInk(tint);
    final ground = Paint()..color = groundC;
    final ink = Paint()..color = inkC;
    final soft = Paint()..color = inkC.withValues(alpha: 0.32);
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    const kLine = TtcTabPainter.kLine;
    const kDetail = TtcTabPainter.kDetail;
    final line = stroke(inkC, kLine);
    final knock = stroke(groundC, kDetail);
    RRect rr(double l, double t, double r, double b, [double rad = 8]) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

    // The disc every mark sits on.
    canvas.drawCircle(const Offset(50, 50), 46, ground);

    switch (mark) {
      case PvStoreMark.folicTablet:
        // A leaf behind (soft), a blister strip in front (ink) with six
        // tablets knocked out: the one supplement to begin, and what it is.
        // (A round tablet with a score line read as a no-entry sign on the
        // first render, 2026-09-29.)
        canvas.drawPath(_leaf(const Offset(46, 40), const Offset(84, 14), 14),
            soft);
        // (Round bubbles in a square read as a die; the strip is tilted and
        // its bubbles are tablet-shaped, each holding a soft tablet.)
        canvas.save();
        canvas.translate(44, 58);
        canvas.rotate(-math.pi / 12);
        canvas.drawRRect(rr(-24, -28, 24, 28, 9), ink);
        for (var r = 0; r < 3; r++) {
          for (var c = 0; c < 2; c++) {
            final o = Offset(-11 + c * 22.0, -16 + r * 16.0);
            canvas.drawRRect(
                RRect.fromRectAndRadius(
                    Rect.fromCenter(center: o, width: 16, height: 10),
                    const Radius.circular(5)),
                ground);
            canvas.drawRRect(
                RRect.fromRectAndRadius(
                    Rect.fromCenter(center: o, width: 10, height: 5),
                    const Radius.circular(2.5)),
                soft);
          }
        }
        canvas.restore();

      case PvStoreMark.fertileCalendar:
        // A page with its two rings; a grid of days, a run of six in ink and
        // the last of them ringed. Her fertile days, as a date she can find.
        canvas.drawRRect(rr(18, 24, 82, 82, 10), soft);
        canvas.drawRRect(rr(18, 24, 82, 38, 10), ink);
        canvas.drawLine(const Offset(34, 16), const Offset(34, 30), line);
        canvas.drawLine(const Offset(66, 16), const Offset(66, 30), line);
        for (var r = 0; r < 3; r++) {
          for (var c = 0; c < 4; c++) {
            final o = Offset(30 + c * 13.3, 50 + r * 12.0);
            final lit = (r == 1) || (r == 2 && c < 2);
            canvas.drawCircle(o, 4, lit ? ink : ground);
          }
        }
        canvas.drawCircle(const Offset(43.3, 74), 7.5, stroke(inkC, 3));

      case PvStoreMark.pregnancyTest:
        // A test stick lying across the disc: the soft cap, the ink body, the
        // window knocked out with one sure line and one faint one. Drawn
        // across, not upright, so it is not the door rail's Waiting strip.
        canvas.save();
        canvas.translate(50, 52);
        canvas.rotate(-math.pi / 10);
        canvas.drawRRect(rr(20, -9, 42, 9, 8), soft);
        canvas.drawRRect(rr(-38, -13, 26, 13, 12), ink);
        canvas.drawRRect(rr(-20, -6, 8, 6, 6), ground);
        canvas.drawLine(
            const Offset(-12, -2), const Offset(-12, 2), stroke(inkC, kDetail));
        canvas.drawLine(const Offset(-2, -2), const Offset(-2, 2),
            stroke(inkC.withValues(alpha: 0.45), kDetail));
        canvas.restore();

      case PvStoreMark.capsules:
        // Two capsules: one soft behind, one ink in front with its seam
        // knocked out. Supplements, more than one, weighed against each other.
        canvas.save();
        canvas.translate(50, 50);
        canvas.rotate(math.pi / 5);
        canvas.drawRRect(rr(-30, -22, 30, -2, 10), soft);
        canvas.restore();
        canvas.save();
        canvas.translate(50, 56);
        canvas.rotate(-math.pi / 6);
        canvas.drawRRect(rr(-30, -11, 30, 11, 11), ink);
        canvas.drawLine(const Offset(0, -9), const Offset(0, 9), knock);
        canvas.drawLine(const Offset(-20, -3), const Offset(-10, -3), knock);
        canvas.restore();

      case PvStoreMark.books:
        // Two books stacked: the lower soft with its pages knocked out, the
        // upper ink with its pages knocked out, and its ribbon hanging down
        // over the lower one.
        canvas.drawRRect(rr(18, 60, 82, 80, 6), soft);
        canvas.drawLine(const Offset(24, 70), const Offset(62, 70), knock);
        canvas.drawRRect(rr(24, 34, 76, 58, 6), ink);
        canvas.drawLine(const Offset(30, 50), const Offset(70, 50), knock);
        canvas.drawPath(
            Path()
              ..moveTo(62, 56)
              ..lineTo(70, 56)
              ..lineTo(70, 76)
              ..lineTo(66, 72)
              ..lineTo(62, 76)
              ..close(),
            ink);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PvStorePainter old) =>
      old.mark != mark || old.tint != tint;
}

/// A pointed leaf from [a] to [b], [w] across at its widest. The door
/// family's leaf, drawn the same way (its own is private to that file).
Path _leaf(Offset a, Offset b, double w) {
  final mid = Offset.lerp(a, b, 0.5)!;
  final d = b - a;
  final n = Offset(-d.dy, d.dx) / d.distance;
  final c1 = mid + n * w;
  final c2 = mid - n * w;
  return Path()
    ..moveTo(a.dx, a.dy)
    ..quadraticBezierTo(c1.dx, c1.dy, b.dx, b.dy)
    ..quadraticBezierTo(c2.dx, c2.dy, a.dx, a.dy)
    ..close();
}
