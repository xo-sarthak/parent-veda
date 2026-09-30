// =============================================================================
//  TtcMoreArt — the few marks More and the profile need that the door and
//  tool families do not have (2026-09-29)
// -----------------------------------------------------------------------------
//  The user: "every section should look like part of the same application".
//  More and the profile draw their rows with the TTC family: the door rail's
//  `TtcTabArt`, the Tools hub's `TtcToolMarkLeading`, and, for the four
//  objects neither family draws, these. They follow `ttc_tab_art.dart`'s
//  language exactly and use its helpers: a 100×100 canvas, the ground disc
//  (r 46) in the row's tint, INK for the focal shape, SOFT (ink at 32%)
//  behind it, detail knocked out in the ground colour, the family's three
//  weights (`TtcTabPainter.kLine`, `kBand`, `kDetail`), round caps.
//
//    parcel    a box with its lid band and tape: Orders
//    house     a house with its door: Delivery addresses
//    bookmark  a bookmark over a page: Saved
//    gear      a cog: Settings
//    film      a strip of film with its sprocket holes: All videos
//              (2026-09-29, More's "Read and watch"; no play triangle, as
//              no film is made yet and a play glyph is a promise)
//
//  `ttcArt*` below turn any of the three families into the one shape the
//  rows take (a builder of the mark for a tint), so a row never has to know
//  which family its mark came from.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'doors/ttc_tab_art.dart';
import 'ttc_tool_marks.dart' show TtcToolMarkLeading;

enum TtcMoreMark { parcel, house, bookmark, gear, film }

/// A row's drawn mark, for its tint.
typedef TtcArtBuilder = Widget Function(Color tint);

/// A mark from the door rail's family.
TtcArtBuilder ttcArtTab(TtcTabMark m) =>
    (tint) => TtcTabArt(mark: m, tint: tint);

/// A Tools row's own mark, by its Tools id ('expert', 'courses', 'map', …).
TtcArtBuilder ttcArtTool(String toolId) =>
    (tint) => TtcToolMarkLeading(toolId: toolId, tint: tint);

/// One of the four drawn here.
TtcArtBuilder ttcArtMore(TtcMoreMark m) =>
    (tint) => TtcMoreArt(mark: m, tint: tint);

class TtcMoreArt extends StatelessWidget {
  const TtcMoreArt({super.key, required this.mark, required this.tint});
  final TtcMoreMark mark;
  final Color tint;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TtcMorePainter(mark, tint),
        size: Size.infinite,
      );
}

class TtcMorePainter extends CustomPainter {
  TtcMorePainter(this.mark, this.tint);
  final TtcMoreMark mark;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    // The rail's canvas, exactly (`TtcTabPainter.paint`).
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
    const kDetail = TtcTabPainter.kDetail;
    final knock = stroke(groundC, kDetail);
    RRect rr(double l, double t, double r, double b, [double rad = 8]) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

    canvas.drawCircle(const Offset(50, 50), 46, ground);

    switch (mark) {
      case TtcMoreMark.parcel:
        // A box: the lid as a soft band above, the body in ink, the tape
        // knocked out down the middle. What she ordered, not a cart.
        canvas.drawRRect(rr(18, 26, 82, 42, 6), soft);
        canvas.drawRRect(rr(22, 40, 78, 80, 8), ink);
        canvas.drawLine(const Offset(50, 44), const Offset(50, 76), knock);
        canvas.drawLine(const Offset(30, 50), const Offset(42, 50), knock);

      case TtcMoreMark.house:
        // A house: the roof soft, the walls ink, the door knocked out.
        canvas.drawPath(
            Path()
              ..moveTo(14, 50)
              ..lineTo(50, 18)
              ..lineTo(86, 50)
              ..close(),
            soft);
        canvas.drawRRect(rr(24, 44, 76, 82, 6), ink);
        canvas.drawRRect(rr(43, 58, 57, 82, 4), ground);

      case TtcMoreMark.bookmark:
        // A page behind, soft; a bookmark in front, ink, with its notch.
        canvas.drawRRect(rr(22, 16, 70, 80, 8), soft);
        canvas.drawPath(
            Path()
              ..moveTo(40, 26)
              ..lineTo(76, 26)
              ..lineTo(76, 86)
              ..lineTo(58, 72)
              ..lineTo(40, 86)
              ..close(),
            ink);
        canvas.drawLine(const Offset(48, 38), const Offset(68, 38), knock);

      case TtcMoreMark.gear:
        // A cog: eight rounded teeth round an ink wheel, the hub knocked out.
        canvas.save();
        canvas.translate(50, 50);
        for (var i = 0; i < 8; i++) {
          canvas.save();
          canvas.rotate(i * math.pi / 4);
          canvas.drawRRect(rr(-7, -36, 7, -20, 4), ink);
          canvas.restore();
        }
        canvas.restore();
        canvas.drawCircle(const Offset(50, 50), 25, ink);
        canvas.drawCircle(const Offset(50, 50), 10, ground);
        canvas.drawCircle(const Offset(50, 50), 16, knock);

      case TtcMoreMark.film:
        // A frame of film: a second frame soft behind, the strip in ink,
        // its sprocket holes and its picture knocked out in the ground.
        canvas.drawRRect(rr(26, 18, 84, 62, 8), soft);
        canvas.drawRRect(rr(16, 34, 76, 82, 8), ink);
        canvas.drawRRect(rr(26, 46, 66, 70, 4), ground);
        for (var x = 24.0; x <= 68; x += 11) {
          canvas.drawRRect(rr(x - 2.5, 37.5, x + 2.5, 42.5, 1.5), ground);
          canvas.drawRRect(rr(x - 2.5, 73.5, x + 2.5, 78.5, 1.5), ground);
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(TtcMorePainter old) =>
      old.mark != mark || old.tint != tint;
}
