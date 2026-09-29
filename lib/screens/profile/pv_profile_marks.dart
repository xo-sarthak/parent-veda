// =============================================================================
//  PvProfileArt — the marks the profile and Settings need that the TTC
//  families do not have (2026-09-29)
// -----------------------------------------------------------------------------
//  The user's one icon rule for the whole app (2026-09-29): a row she taps to
//  go somewhere leads with a DRAWN MARK; line icons are only for controls
//  (back, close, search, chevrons, add, delete). The profile's rows borrow
//  the door rail's `TtcTabArt`, the Tools hub's marks and `TtcMoreArt`; the
//  account, preference, notification, privacy and help rows of Settings need
//  the objects below.
//
//  They follow `ttc_tab_art.dart`'s language exactly and use its helpers: a
//  100 by 100 canvas, the ground disc (r 46) in the row's tint, INK for the
//  focal shape, SOFT (ink at 32%) behind it, detail knocked out in the ground
//  colour, the family's three weights (`TtcTabPainter.kLine`, `kBand`,
//  `kDetail`), round caps.
//
//    person     a head and shoulders: how she is signed in
//    door       a door with an arrow leaving it: Sign out
//    bin        a lidded bin: Delete account
//    shield     a shield with a tick: Data and privacy
//    globe      a globe: Language
//    bell       a bell: Reminders
//    bubble     a speech bubble with three dots: WhatsApp updates
//    envelope   a letter in its envelope: Messages
//    eye        an eye: What you see
//    lifebuoy   a ring buoy: Help
//    plane      a paper plane: Contact us
//    phone      a phone with a heart on its screen: Get help now
//    info       an i in a disc: About ParentVeda
//
//  ⚠️ ONE TINT FOR THE PAGE (the lead, 2026-09-29): every mark on the
//  profile and on Settings takes `kPvProfileMarkHue`, so the page reads calm
//  and whole rather than a different colour per row.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ttc/doors/ttc_tab_art.dart'
    show TtcTabPainter, ttcTabGround, ttcTabInk;

/// The one hue every mark on the profile and on Settings is drawn in, and the
/// hero band's tint: a soft blue-grey, the calm and clinical end of the
/// home's hues (`V2BlockHues.scans`). Never violet.
const double kPvProfileMarkHue = 206;

enum PvProfileMark {
  person,
  door,
  bin,
  shield,
  globe,
  bell,
  bubble,
  envelope,
  eye,
  lifebuoy,
  plane,
  phone,
  info,
}

class PvProfileArt extends StatelessWidget {
  const PvProfileArt({super.key, required this.mark, required this.tint});
  final PvProfileMark mark;
  final Color tint;

  @override
  Widget build(BuildContext context) => CustomPaint(
    key: ValueKey('pv_profile_mark_${mark.name}'),
    painter: PvProfilePainter(mark, tint),
    size: Size.infinite,
  );
}

class PvProfilePainter extends CustomPainter {
  PvProfilePainter(this.mark, this.tint);
  final PvProfileMark mark;
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
    Paint stroke(Color c, double w, {StrokeCap cap = StrokeCap.round}) =>
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeCap = cap
          ..strokeJoin = StrokeJoin.round;
    const kLine = TtcTabPainter.kLine;
    const kBand = TtcTabPainter.kBand;
    const kDetail = TtcTabPainter.kDetail;
    final knock = stroke(groundC, kDetail);
    RRect rr(double l, double t, double r, double b, [double rad = 8]) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

    canvas.drawCircle(const Offset(50, 50), 46, ground);

    switch (mark) {
      case PvProfileMark.person:
        // Shoulders soft behind, the head in ink with a ground ring between.
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            24,
            56,
            76,
            82,
            topLeft: const Radius.circular(26),
            topRight: const Radius.circular(26),
            bottomLeft: const Radius.circular(8),
            bottomRight: const Radius.circular(8),
          ),
          ink,
        );
        canvas.drawCircle(const Offset(50, 36), 17, ground);
        canvas.drawCircle(const Offset(50, 36), 13, ink);

      case PvProfileMark.door:
        // A door, soft, and an arrow in ink leaving through it.
        canvas.drawRRect(rr(22, 18, 58, 82, 6), soft);
        canvas.drawCircle(const Offset(50, 52), 3.5, ink);
        canvas.drawLine(
          const Offset(44, 50),
          const Offset(80, 50),
          stroke(inkC, kLine),
        );
        canvas.drawPath(
          Path()
            ..moveTo(69, 38)
            ..lineTo(81, 50)
            ..lineTo(69, 62),
          stroke(inkC, kLine),
        );

      case PvProfileMark.bin:
        // A bin: the lid and its handle, the body with two ribs knocked out.
        canvas.drawRRect(rr(42, 16, 58, 28, 4), soft);
        canvas.drawRRect(rr(24, 24, 76, 34, 5), ink);
        canvas.drawRRect(rr(30, 38, 70, 84, 8), ink);
        canvas.drawLine(const Offset(43, 48), const Offset(43, 74), knock);
        canvas.drawLine(const Offset(57, 48), const Offset(57, 74), knock);

      case PvProfileMark.shield:
        // A shield in ink, a tick knocked out of it; its soft shadow behind.
        Path shield(double dx) => Path()
          ..moveTo(50 + dx, 14)
          ..lineTo(78 + dx, 25)
          ..lineTo(78 + dx, 48)
          ..quadraticBezierTo(78 + dx, 72, 50 + dx, 86)
          ..quadraticBezierTo(22 + dx, 72, 22 + dx, 48)
          ..lineTo(22 + dx, 25)
          ..close();
        canvas.drawPath(shield(6), soft);
        canvas.drawPath(shield(0), ink);
        canvas.drawPath(
          Path()
            ..moveTo(37, 50)
            ..lineTo(46, 59)
            ..lineTo(63, 41),
          stroke(groundC, kLine),
        );

      case PvProfileMark.globe:
        // A globe: an ink disc, a meridian and the equator knocked out.
        canvas.drawCircle(const Offset(56, 54), 30, soft);
        canvas.drawCircle(const Offset(50, 50), 30, ink);
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(50, 50), width: 26, height: 58),
          knock,
        );
        canvas.drawLine(const Offset(22, 50), const Offset(78, 50), knock);
        canvas.drawLine(const Offset(27, 36), const Offset(73, 36), knock);
        canvas.drawLine(const Offset(27, 64), const Offset(73, 64), knock);

      case PvProfileMark.bell:
        // A bell in ink, its clapper soft under it.
        canvas.drawCircle(const Offset(50, 76), 8, soft);
        canvas.drawPath(
          Path()
            ..moveTo(50, 18)
            ..quadraticBezierTo(71, 20, 71, 45)
            ..lineTo(71, 60)
            ..lineTo(79, 70)
            ..lineTo(21, 70)
            ..lineTo(29, 60)
            ..lineTo(29, 45)
            ..quadraticBezierTo(29, 20, 50, 18)
            ..close(),
          ink,
        );
        canvas.drawCircle(const Offset(50, 17), 4.5, ink);
        canvas.drawLine(const Offset(38, 58), const Offset(62, 58), knock);

      case PvProfileMark.bubble:
        // A speech bubble with its tail, three dots knocked out.
        canvas.drawRRect(rr(28, 30, 84, 70, 18), soft);
        canvas.drawPath(
          Path()
            ..addRRect(rr(16, 22, 72, 62, 18))
            ..moveTo(26, 56)
            ..lineTo(22, 76)
            ..lineTo(40, 60)
            ..close(),
          ink,
        );
        for (final x in [32.0, 44.0, 56.0]) {
          canvas.drawCircle(Offset(x, 42), 4, ground);
        }

      case PvProfileMark.envelope:
        // A letter, soft, rising out of an ink envelope; the flap knocked out.
        canvas.drawRRect(rr(30, 18, 70, 50, 5), soft);
        canvas.drawRRect(rr(18, 34, 82, 78, 8), ink);
        canvas.drawPath(
          Path()
            ..moveTo(23, 39)
            ..lineTo(50, 60)
            ..lineTo(77, 39),
          stroke(groundC, kDetail + 1),
        );

      case PvProfileMark.eye:
        // An almond, soft; the iris in ink; the pupil and a glint knocked out.
        canvas.drawPath(
          Path()
            ..moveTo(12, 50)
            ..quadraticBezierTo(50, 14, 88, 50)
            ..quadraticBezierTo(50, 86, 12, 50)
            ..close(),
          soft,
        );
        canvas.drawCircle(const Offset(50, 50), 17, ink);
        canvas.drawCircle(const Offset(50, 50), 6.5, ground);
        canvas.drawCircle(const Offset(57, 43), 3, ground);

      case PvProfileMark.lifebuoy:
        // A ring buoy: the ring soft, four bands in ink round it.
        const c = Offset(50, 50);
        final rect = Rect.fromCircle(center: c, radius: 26);
        canvas.drawCircle(c, 26, stroke(inkC.withValues(alpha: 0.32), 16));
        final band = stroke(inkC, 16, cap: StrokeCap.butt);
        for (var i = 0; i < 4; i++) {
          canvas.drawArc(
            rect,
            -math.pi / 2 - 0.36 + i * math.pi / 2,
            0.72,
            false,
            band,
          );
        }

      case PvProfileMark.plane:
        // A paper plane in ink, its fold knocked out, its trail soft.
        canvas.drawLine(
          const Offset(20, 74),
          const Offset(34, 62),
          stroke(inkC.withValues(alpha: 0.32), kLine),
        );
        canvas.drawPath(
          Path()
            ..moveTo(14, 46)
            ..lineTo(84, 18)
            ..lineTo(64, 82)
            ..lineTo(48, 58)
            ..close(),
          ink,
        );
        canvas.drawLine(const Offset(48, 58), const Offset(80, 24), knock);

      case PvProfileMark.phone:
        // A phone in ink, its screen knocked out, a soft heart on the screen.
        canvas.drawRRect(rr(30, 14, 70, 86, 10), ink);
        canvas.drawRRect(rr(36, 22, 64, 70, 4), ground);
        canvas.drawPath(
          Path()
            ..moveTo(50, 58)
            ..cubicTo(38, 50, 40, 38, 50, 43)
            ..cubicTo(60, 38, 62, 50, 50, 58)
            ..close(),
          soft,
        );
        canvas.drawLine(const Offset(46, 78), const Offset(54, 78), knock);

      case PvProfileMark.info:
        // An i knocked out of an ink disc, a soft disc behind.
        canvas.drawCircle(const Offset(56, 55), 29, soft);
        canvas.drawCircle(const Offset(50, 50), 29, ink);
        canvas.drawCircle(const Offset(50, 36), 4.5, ground);
        canvas.drawLine(
          const Offset(50, 48),
          const Offset(50, 66),
          stroke(groundC, kBand - 3),
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PvProfilePainter old) =>
      old.mark != mark || old.tint != tint;
}
