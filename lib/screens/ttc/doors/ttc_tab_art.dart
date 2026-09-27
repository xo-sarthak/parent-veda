// =============================================================================
//  TtcTabArt — the trying-to-conceive door TAB marks, one family, drawn in code
// -----------------------------------------------------------------------------
//  ⚠️ WHY A FAMILY OF ITS OWN (2026-09-27, the launch walk). The door rail's
//  white cards wore `HubIntentArt` marks borrowed from forty pregnancy hubs: a
//  book, a report page, a calendar, a sun, cupped hands. Each was drawn for a
//  different question ("understand my report", "see my appointments"), so on a
//  TTC door they read as stock. The user, on the phone: "very random ... make
//  better ones; if that is done using code, you can make way better ones."
//
//  So these are drawn for THIS rail and nothing else: one mark per tab meaning,
//  each literally about its tab (a test strip with two lines for Waiting and
//  testing, two overlapping circles for Sex and closeness, a cloud with soft
//  rain for Hard days), and one visual language across all of them.
//
//  THE LANGUAGE (hold it when adding a mark):
//    · CANVAS 100×100, centred, drawn for the rail's 48dp mark box.
//    · A GROUND DISC, r 46, in the door's own tint. The object sits on it.
//      Taken from Flo's log sheet and interests list, where every topic is a
//      two-tone object on a pastel disc, and from Stardust's feeling picker:
//      the disc is what makes a set of different objects read as one family.
//    · TWO TONES, both derived from the tint: INK (the tint's hue, deep) for
//      the focal shape, and SOFT (ink at 32%) for whatever sits behind it.
//      Detail is KNOCKED OUT in the ground colour, never a third colour laid
//      on top.
//    · ONE LINE WEIGHT (6) for strokes, ONE BAND WEIGHT (11) for rings and
//      roads, ONE DETAIL WEIGHT (4) for knocked-out lines. Corners 8 on big
//      shapes, 4 on small ones. Round caps and joins everywhere.
//    · OPTICAL SIZE: the object fills roughly the 18..82 box, so a round mark
//      and a tall one look the same size on the rail.
//    · NOTHING CLINICAL OR ANATOMICAL. See a doctor is a speech bubble with a
//      plus, Intimate health is a tulip, Your body (after a loss) is a hot
//      water bottle. The shape of the help, never the shape of the fear, the
//      rule `v3_bracket_art.dart` set for the pregnancy brackets.
//
//  REUSE BY MEANING, as `hub_intent_art.dart` does: "Understand" is the same
//  open book on every door, because it is the same act. Two tabs on ONE door
//  never share a mark (`test/ttc_tab_art_test.dart`).
//
//  Mobbin screens that set the style:
//    · Flo, log sheet with pastel-disc topic marks (Creamy, Calm, Cravings):
//      https://mobbin.com/screens/ef9d56e1-288d-4119-b280-47a5bccf28b8
//    · Flo, Interests list, one round two-tone picture per topic:
//      https://mobbin.com/screens/f983b7eb-82f1-4aa4-b1f0-24a35f1c6a6f
//    · Flo, Start a new chat, topic pictures on a pale disc:
//      https://mobbin.com/screens/f9b53c99-c4c4-45b1-ad68-e65543e60ecc
//    · Stardust, feeling picker, one object per feeling on a soft disc:
//      https://mobbin.com/screens/70358b09-1d36-4d01-9713-1bb06270cb6f
//    · Headspace, Explore collections, one drawn object per topic card:
//      https://mobbin.com/screens/d05b1798-9389-4073-999b-693b84cca19e
//  What they decided: a topic mark is an OBJECT on a DISC, flat, in two tones
//  of one hue; never a line icon in a box, and never a scene.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One per tab MEANING on the TTC doors. The tab to mark map lives on each
/// `TtcFocusGroup.tabMark` in `lib/ttc/focus/*.dart`.
enum TtcTabMark {
  /// An open book with a leaf growing from the spine. Understand.
  openBook,

  /// A cycle ring with the fertile stretch picked out and one day marked.
  /// When and how; Trying with PCOS.
  windowRing,

  /// A ring of days with the period as a drop at the top. Your cycle.
  cycleDrops,

  /// A test strip with its two lines. Waiting and testing.
  testStrip,

  /// Two circles overlapping, a small heart where they meet. Sex and closeness.
  twoCircles,

  /// A sprout with two leaves from a mound. Improving his health, what helps.
  sprout,

  /// A supplement jar with a leaf on its label. Diet and supplements; What
  /// you can do (folic acid first).
  jarLeaf,

  /// A speech bubble with a plus. See a doctor.
  doctorChat,

  /// A small vial in front of a report. Tests and results.
  vialReport,

  /// A bowl with steam. Meal plan.
  bowl,

  /// A bathroom scale with a heart on it. Weight and habits.
  scale,

  /// A path to a flag. Before you start.
  flagPath,

  /// A clipboard with two ticks and one box. Your checklist; Getting ready.
  checklist,

  /// A soft line chart with the last point marked. Track.
  chartLine,

  /// Two speech bubbles. Talk.
  twoBubbles,

  /// A signpost with two ways. Should I get help?
  signpost,

  /// A big heart and a small one. Age and second baby.
  bigSmallHearts,

  /// A wallet with its clasp. Money and clinics.
  wallet,

  /// A heart held in a cupped hand. Support; Going through it.
  heartHand,

  /// A timeline with the current station ringed. The IVF round's Track.
  timelineDots,

  /// A hot water bottle with a heart. Your body, after a loss.
  hotBottle,

  /// A sun rising over the horizon. Trying again.
  sunrise,

  /// A small sun. Today.
  sun,

  /// A cloud with soft rain. Hard days.
  cloudRain,

  /// A lotus. The practice.
  lotus,

  /// A tulip. Intimate health, without anatomy.
  tulip,

  /// A magnifier over a page. Other conditions.
  magnifier,

  /// A clock face. Is it time?
  clock,

  /// Two people side by side. Both of you.
  twoFigures,

  /// A winding road. What can slow it.
  windingPath,

  /// A map pin. Where do I stand.
  pin,
}

/// The drawn tab mark on the TTC door rail. Size comes from the parent box.
class TtcTabArt extends StatelessWidget {
  const TtcTabArt({super.key, required this.mark, required this.tint});

  final TtcTabMark mark;

  /// The tab's pastel (`v2BlockTint(hue)`). Ink and soft are derived from it,
  /// so a tab's mark always matches its hue with nothing passed in twice.
  final Color tint;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TtcTabPainter(mark, tint),
        size: Size.infinite,
      );
}

/// The deep tone of a tab's hue: the focal shape.
Color ttcTabInk(Color tint) =>
    HSLColor.fromColor(tint).withSaturation(0.44).withLightness(0.37).toColor();

/// The ground disc: the tab's tint, nudged a little richer so it holds on a
/// white card.
Color ttcTabGround(Color tint) {
  final h = HSLColor.fromColor(tint);
  return h
      .withSaturation(math.max(h.saturation, 0.42))
      .withLightness(math.min(h.lightness, 0.89))
      .toColor();
}

class TtcTabPainter extends CustomPainter {
  TtcTabPainter(this.mark, this.tint);

  final TtcTabMark mark;
  final Color tint;

  // The family's three weights. Change them here, never per mark.
  static const double kLine = 6;
  static const double kBand = 11;
  static const double kDetail = 4;

  @override
  void paint(Canvas canvas, Size size) {
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
    final line = stroke(inkC, kLine);
    final lineSoft = stroke(inkC.withValues(alpha: 0.32), kLine);
    final knock = stroke(groundC, kDetail);
    RRect rr(double l, double t, double r, double b, [double rad = 8]) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

    // The disc every mark sits on.
    canvas.drawCircle(const Offset(50, 50), 46, ground);

    switch (mark) {
      // ---- UNDERSTAND --------------------------------------------------------
      case TtcTabMark.openBook:
        // Two pages from the spine, a leaf growing out of it: learning that
        // leads somewhere, not a textbook.
        canvas.drawPath(
            Path()
              ..moveTo(49, 40)
              ..quadraticBezierTo(34, 32, 18, 36)
              ..lineTo(18, 74)
              ..quadraticBezierTo(34, 70, 49, 78)
              ..close(),
            ink);
        canvas.drawPath(
            Path()
              ..moveTo(51, 40)
              ..quadraticBezierTo(66, 32, 82, 36)
              ..lineTo(82, 74)
              ..quadraticBezierTo(66, 70, 51, 78)
              ..close(),
            ink);
        for (final y in [50.0, 60.0]) {
          canvas.drawLine(Offset(26, y - 2), Offset(42, y + 1), knock);
          canvas.drawLine(Offset(58, y + 1), Offset(74, y - 2), knock);
        }
        canvas.drawPath(_leaf(const Offset(50, 36), const Offset(64, 14), 12), soft);
        canvas.drawLine(const Offset(50, 38), const Offset(50, 30), line);

      // ---- WHEN AND HOW ------------------------------------------------------
      case TtcTabMark.windowRing:
        // The month as a ring; the fertile days as the stretch in ink; the
        // day she is on as a ringed dot at its end.
        const c = Offset(50, 50);
        final ring = Rect.fromCircle(center: c, radius: 28);
        canvas.drawArc(ring, 0, math.pi * 2, false,
            stroke(inkC.withValues(alpha: 0.32), kBand));
        canvas.drawArc(ring, -math.pi * 0.62, math.pi * 0.52, false,
            stroke(inkC, kBand));
        final a = -math.pi * 0.10;
        final dot = c + Offset(math.cos(a) * 28, math.sin(a) * 28);
        canvas.drawCircle(dot, 11, ink);
        canvas.drawCircle(dot, 4.5, ground);
        canvas.drawPath(_heart(50, 52, 16), soft);

      // ---- YOUR CYCLE --------------------------------------------------------
      case TtcTabMark.cycleDrops:
        // Days around a ring; the period is the drop at the top.
        const c = Offset(50, 52);
        for (var i = 1; i < 10; i++) {
          final a = -math.pi / 2 + i * math.pi * 2 / 10;
          canvas.drawCircle(
              c + Offset(math.cos(a) * 28, math.sin(a) * 28), 5, i == 3 ? ink : soft);
        }
        canvas.drawPath(
            Path()
              ..moveTo(50, 10)
              ..cubicTo(56, 18, 62, 24, 62, 30)
              ..arcToPoint(const Offset(38, 30),
                  radius: const Radius.circular(12))
              ..cubicTo(38, 24, 44, 18, 50, 10)
              ..close(),
            ink);
        canvas.drawCircle(const Offset(50, 52), 9, soft);

      // ---- WAITING AND TESTING ----------------------------------------------
      case TtcTabMark.testStrip:
        // A home test stick: the soft tip, the body, and the window with its
        // two lines, one sure and one faint. A tilted strip with rounded ends
        // read as a plaster on the first render, so it stands nearly upright
        // and the tip is its own tone.
        canvas.save();
        canvas.translate(50, 50);
        canvas.rotate(math.pi / 9);
        canvas.drawRRect(rr(-10, -42, 10, -18, 9), soft);
        canvas.drawRRect(rr(-14, -24, 14, 40, 12), ink);
        canvas.drawLine(const Offset(-14, -16), const Offset(14, -16), knock);
        canvas.drawRRect(rr(-7, -6, 7, 24, 7), ground);
        canvas.drawLine(const Offset(-3, 3), const Offset(3, 3), stroke(inkC, kDetail));
        canvas.drawLine(const Offset(-3, 13), const Offset(3, 13),
            stroke(inkC.withValues(alpha: 0.45), kDetail));
        canvas.restore();

      // ---- SEX AND CLOSENESS -------------------------------------------------
      case TtcTabMark.twoCircles:
        final left = Path()
          ..addOval(Rect.fromCircle(center: const Offset(38, 50), radius: 23));
        final right = Path()
          ..addOval(Rect.fromCircle(center: const Offset(62, 50), radius: 23));
        canvas.drawPath(left, soft);
        canvas.drawPath(right, soft);
        canvas.save();
        canvas.clipPath(left);
        canvas.drawPath(right, ink);
        canvas.restore();
        canvas.drawPath(_heart(50, 51, 12), ground);

      // ---- WHAT HELPS / IMPROVE HIS HEALTH ------------------------------------
      case TtcTabMark.sprout:
        canvas.drawPath(
            Path()
              ..moveTo(20, 82)
              ..quadraticBezierTo(50, 64, 80, 82)
              ..close(),
            soft);
        canvas.drawLine(const Offset(50, 76), const Offset(50, 42), line);
        canvas.drawPath(_leaf(const Offset(50, 56), const Offset(24, 40), 16), ink);
        canvas.drawPath(_leaf(const Offset(50, 44), const Offset(78, 22), 20), ink);
        canvas.drawLine(const Offset(55, 40), const Offset(70, 29), knock);

      // ---- DIET AND SUPPLEMENTS / WHAT YOU CAN DO ------------------------------
      case TtcTabMark.jarLeaf:
        canvas.drawRRect(rr(34, 18, 66, 30, 4), soft);
        canvas.drawRRect(rr(28, 30, 72, 84, 11), ink);
        canvas.drawRRect(rr(35, 44, 65, 72, 6), ground);
        canvas.drawPath(_leaf(const Offset(42, 66), const Offset(59, 50), 11), ink);

      // ---- SEE A DOCTOR ------------------------------------------------------
      case TtcTabMark.doctorChat:
        // A person to ask, not a clinic: a bubble, and the plus inside it.
        canvas.drawPath(
            Path()
              ..addRRect(rr(16, 18, 84, 66, 16))
              ..moveTo(32, 64)
              ..lineTo(28, 84)
              ..lineTo(50, 64)
              ..close(),
            soft);
        canvas.drawRRect(rr(44, 26, 56, 58, 4), ink);
        canvas.drawRRect(rr(34, 36, 66, 48, 4), ink);

      // ---- TESTS AND RESULTS -------------------------------------------------
      case TtcTabMark.vialReport:
        canvas.drawRRect(rr(40, 16, 82, 78), soft);
        for (final y in [30.0, 42.0, 54.0]) {
          canvas.drawLine(Offset(52, y), Offset(y == 54 ? 62 : 72, y),
              stroke(inkC, kDetail));
        }
        canvas.drawRRect(rr(20, 24, 42, 84, 11), ink);
        canvas.drawRRect(rr(26, 34, 36, 54, 4), ground);
        canvas.drawLine(const Offset(20, 30), const Offset(42, 30), knock);

      // ---- MEAL PLAN ---------------------------------------------------------
      case TtcTabMark.bowl:
        canvas.drawPath(
            Path()
              ..moveTo(16, 50)
              ..lineTo(84, 50)
              ..quadraticBezierTo(82, 82, 50, 82)
              ..quadraticBezierTo(18, 82, 16, 50)
              ..close(),
            ink);
        canvas.drawLine(const Offset(24, 58), const Offset(76, 58), knock);
        for (final x in [38.0, 56.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(x, 42)
                ..quadraticBezierTo(x - 6, 34, x, 28)
                ..quadraticBezierTo(x + 6, 22, x, 16),
              lineSoft);
        }

      // ---- WEIGHT AND HABITS -------------------------------------------------
      case TtcTabMark.scale:
        canvas.drawRRect(rr(20, 22, 80, 82, 16), ink);
        canvas.drawRRect(rr(34, 32, 66, 48, 6), ground);
        canvas.drawLine(const Offset(50, 46), const Offset(57, 37),
            stroke(inkC, kDetail));
        canvas.drawPath(_heart(50, 64, 16), ground);

      // ---- BEFORE YOU START --------------------------------------------------
      case TtcTabMark.flagPath:
        canvas.drawPath(
            Path()
              ..moveTo(22, 82)
              ..quadraticBezierTo(22, 62, 44, 62)
              ..quadraticBezierTo(62, 62, 62, 50),
            stroke(inkC.withValues(alpha: 0.32), kBand));
        canvas.drawCircle(const Offset(22, 80), 7, ink);
        canvas.drawLine(const Offset(62, 54), const Offset(62, 16), line);
        canvas.drawPath(
            Path()
              ..moveTo(62, 16)
              ..lineTo(84, 25)
              ..lineTo(62, 34)
              ..close(),
            ink);

      // ---- YOUR CHECKLIST / GETTING READY ------------------------------------
      case TtcTabMark.checklist:
        canvas.drawRRect(rr(24, 20, 76, 86, 10), ink);
        canvas.drawRRect(rr(38, 13, 62, 26, 5), soft);
        final tick = stroke(groundC, 5);
        for (final y in [40.0, 56.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(32, y)
                ..lineTo(36, y + 4)
                ..lineTo(43, y - 4),
              tick);
          canvas.drawLine(Offset(50, y), Offset(67, y), knock);
        }
        canvas.drawRRect(rr(32, 67, 42, 77, 3), knock);
        canvas.drawLine(const Offset(50, 72), const Offset(62, 72), knock);

      // ---- TRACK -------------------------------------------------------------
      case TtcTabMark.chartLine:
        final pts = [
          const Offset(20, 66),
          const Offset(36, 54),
          const Offset(52, 60),
          const Offset(76, 32),
        ];
        final curve = Path()..moveTo(pts[0].dx, pts[0].dy);
        for (final p in pts.skip(1)) {
          curve.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(
            Path.from(curve)
              ..lineTo(76, 80)
              ..lineTo(20, 80)
              ..close(),
            soft);
        canvas.drawPath(curve, line);
        canvas.drawLine(const Offset(16, 80), const Offset(84, 80), line);
        canvas.drawCircle(const Offset(76, 32), 10, ink);
        canvas.drawCircle(const Offset(76, 32), 4, ground);

      // ---- TALK --------------------------------------------------------------
      case TtcTabMark.twoBubbles:
        canvas.drawPath(
            Path()
              ..addRRect(rr(38, 18, 86, 54, 14))
              ..moveTo(70, 52)
              ..lineTo(78, 66)
              ..lineTo(80, 52)
              ..close(),
            soft);
        canvas.drawPath(
            Path()
              ..addRRect(rr(14, 38, 64, 74, 14))
              ..moveTo(24, 72)
              ..lineTo(20, 86)
              ..lineTo(38, 72)
              ..close(),
            ink);
        for (final x in [28.0, 39.0, 50.0]) {
          canvas.drawCircle(Offset(x, 56), 3.5, ground);
        }

      // ---- SHOULD I GET HELP? ------------------------------------------------
      case TtcTabMark.signpost:
        canvas.drawLine(const Offset(38, 86), const Offset(62, 86), lineSoft);
        canvas.drawLine(const Offset(50, 18), const Offset(50, 86), line);
        canvas.drawPath(
            Path()
              ..moveTo(72, 52)
              ..lineTo(28, 52)
              ..lineTo(18, 61)
              ..lineTo(28, 70)
              ..lineTo(72, 70)
              ..close(),
            soft);
        canvas.drawPath(
            Path()
              ..moveTo(26, 24)
              ..lineTo(74, 24)
              ..lineTo(84, 33)
              ..lineTo(74, 42)
              ..lineTo(26, 42)
              ..close(),
            ink);
        canvas.drawLine(const Offset(34, 33), const Offset(64, 33), knock);

      // ---- AGE AND SECOND BABY -----------------------------------------------
      case TtcTabMark.bigSmallHearts:
        canvas.drawPath(_heart(42, 56, 54), soft);
        final small = _heart(70, 34, 28);
        canvas.drawPath(small, stroke(groundC, 8));
        canvas.drawPath(small, ink);

      // ---- MONEY AND CLINICS -------------------------------------------------
      case TtcTabMark.wallet:
        canvas.save();
        canvas.translate(46, 28);
        canvas.rotate(-0.18);
        canvas.drawRRect(rr(-22, -10, 22, 12, 5), soft);
        canvas.restore();
        canvas.drawRRect(rr(18, 32, 82, 80, 12), ink);
        canvas.drawRRect(rr(56, 46, 82, 66, 9), ground);
        canvas.drawCircle(const Offset(66, 56), 4.5, ink);

      // ---- SUPPORT / GOING THROUGH IT ----------------------------------------
      case TtcTabMark.heartHand:
        // A heart resting in a cupped palm. Held, not fixed.
        final heart = _heart(52, 40, 36);
        canvas.drawPath(heart, ink);
        canvas.drawPath(
            Path()
              ..moveTo(14, 58)
              ..quadraticBezierTo(22, 56, 30, 62)
              ..quadraticBezierTo(50, 76, 70, 64)
              ..lineTo(82, 56),
            stroke(inkC, kBand));
        canvas.drawPath(
            Path()
              ..moveTo(12, 70)
              ..lineTo(24, 82),
            stroke(inkC.withValues(alpha: 0.32), kBand));

      // ---- TRACK (the IVF round) ---------------------------------------------
      case TtcTabMark.timelineDots:
        canvas.drawLine(const Offset(16, 58), const Offset(84, 58), lineSoft);
        canvas.drawCircle(const Offset(22, 58), 7.5, ink);
        canvas.drawCircle(const Offset(40, 58), 7.5, ink);
        canvas.drawCircle(const Offset(80, 58), 7, soft);
        canvas.drawCircle(const Offset(60, 58), 11, ink);
        canvas.drawCircle(const Offset(60, 58), 4.5, ground);
        canvas.drawPath(
            Path()
              ..moveTo(52, 28)
              ..lineTo(68, 28)
              ..lineTo(60, 38)
              ..close(),
            ink);

      // ---- YOUR BODY (after a loss) ------------------------------------------
      case TtcTabMark.hotBottle:
        canvas.save();
        canvas.translate(50, 54);
        canvas.rotate(-0.26);
        canvas.drawRRect(rr(-9, -42, 9, -34, 3), soft);
        canvas.drawRRect(rr(-8, -36, 8, -22, 3), ink);
        canvas.drawRRect(rr(-22, -26, 22, 32, 16), ink);
        canvas.drawLine(const Offset(-12, -12), const Offset(12, -12), knock);
        canvas.drawPath(_heart(0, 10, 18), ground);
        canvas.restore();

      // ---- TRYING AGAIN ------------------------------------------------------
      case TtcTabMark.sunrise:
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 66), radius: 22),
            math.pi, math.pi, true, ink);
        for (var i = 1; i < 6; i++) {
          final a = math.pi + i * math.pi / 6;
          final d = Offset(math.cos(a), math.sin(a));
          canvas.drawLine(const Offset(50, 66) + d * 30,
              const Offset(50, 66) + d * 38, line);
        }
        canvas.drawLine(const Offset(14, 66), const Offset(86, 66), line);
        canvas.drawLine(const Offset(30, 78), const Offset(70, 78), lineSoft);

      // ---- TODAY -------------------------------------------------------------
      case TtcTabMark.sun:
        canvas.drawCircle(const Offset(50, 50), 25, soft);
        canvas.drawCircle(const Offset(50, 50), 17, ink);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final d = Offset(math.cos(a), math.sin(a));
          canvas.drawLine(const Offset(50, 50) + d * 31,
              const Offset(50, 50) + d * 37, line);
        }

      // ---- HARD DAYS ---------------------------------------------------------
      case TtcTabMark.cloudRain:
        // A cloud and a soft rain, not a storm: weather passes.
        canvas.drawPath(
            Path()
              ..addRRect(rr(16, 40, 84, 64, 12))
              ..addOval(Rect.fromCircle(center: const Offset(36, 42), radius: 14))
              ..addOval(Rect.fromCircle(center: const Offset(58, 36), radius: 19)),
            ink);
        for (final x in [34.0, 52.0, 70.0]) {
          canvas.drawLine(Offset(x, 72), Offset(x - 4, 82), lineSoft);
        }

      // ---- THE PRACTICE ------------------------------------------------------
      case TtcTabMark.lotus:
        canvas.drawPath(_leaf(const Offset(48, 72), const Offset(16, 46), 18), soft);
        canvas.drawPath(_leaf(const Offset(52, 72), const Offset(84, 46), 18), soft);
        canvas.drawPath(_leaf(const Offset(48, 72), const Offset(28, 30), 18), ink);
        canvas.drawPath(_leaf(const Offset(52, 72), const Offset(72, 30), 18), ink);
        canvas.drawPath(_leaf(const Offset(50, 72), const Offset(50, 18), 22),
            stroke(groundC, 5));
        canvas.drawPath(_leaf(const Offset(50, 72), const Offset(50, 18), 22), ink);
        canvas.drawLine(const Offset(26, 82), const Offset(74, 82), lineSoft);

      // ---- INTIMATE HEALTH ---------------------------------------------------
      case TtcTabMark.tulip:
        canvas.drawLine(const Offset(50, 84), const Offset(50, 54), line);
        canvas.drawPath(_leaf(const Offset(50, 80), const Offset(74, 58), 14), soft);
        canvas.drawPath(
            Path()
              ..moveTo(30, 22)
              ..lineTo(40, 32)
              ..lineTo(50, 16)
              ..lineTo(60, 32)
              ..lineTo(70, 22)
              ..lineTo(70, 42)
              ..quadraticBezierTo(70, 60, 50, 60)
              ..quadraticBezierTo(30, 60, 30, 42)
              ..close(),
            ink);

      // ---- OTHER CONDITIONS --------------------------------------------------
      case TtcTabMark.magnifier:
        canvas.drawRRect(rr(18, 16, 60, 74), soft);
        for (final y in [30.0, 42.0]) {
          canvas.drawLine(Offset(28, y), Offset(46, y), stroke(inkC, kDetail));
        }
        canvas.drawLine(const Offset(70, 70), const Offset(84, 84),
            stroke(inkC, kBand));
        canvas.drawCircle(const Offset(58, 56), 22, ink);
        canvas.drawCircle(const Offset(58, 56), 14, ground);
        canvas.drawArc(Rect.fromCircle(center: const Offset(58, 56), radius: 8),
            math.pi * 1.1, math.pi * 0.5, false, stroke(inkC.withValues(alpha: 0.32), kDetail));

      // ---- IS IT TIME? -------------------------------------------------------
      case TtcTabMark.clock:
        canvas.drawRRect(rr(43, 10, 57, 18, 3), soft);
        canvas.drawCircle(const Offset(50, 52), 32, ink);
        final hand = stroke(groundC, 6);
        canvas.drawLine(const Offset(50, 52), const Offset(50, 32), hand);
        canvas.drawLine(const Offset(50, 52), const Offset(63, 60), hand);
        for (final a in [0.0, math.pi / 2, math.pi]) {
          canvas.drawCircle(
              const Offset(50, 52) + Offset(math.cos(a) * 24, math.sin(a) * 24),
              2.6,
              ground);
        }

      // ---- BOTH OF YOU -------------------------------------------------------
      case TtcTabMark.twoFigures:
        canvas.drawCircle(const Offset(36, 34), 11, soft);
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(16, 52, 56, 84,
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18)),
            soft);
        final head = Path()
          ..addOval(Rect.fromCircle(center: const Offset(64, 40), radius: 12));
        final body = Path()
          ..addRRect(RRect.fromLTRBAndCorners(42, 58, 86, 84,
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20)));
        canvas.drawPath(head, stroke(groundC, 6));
        canvas.drawPath(body, stroke(groundC, 6));
        canvas.drawPath(head, ink);
        canvas.drawPath(body, ink);

      // ---- WHAT CAN SLOW IT --------------------------------------------------
      case TtcTabMark.windingPath:
        // A road that bends and narrows into the distance over a soft hill.
        // Drawn as a TAPERING shape: a road of even width read as a worm on
        // the first render; the taper is what says "distance". Both are
        // clipped to the disc, because a road runs off the edge of the world.
        canvas.save();
        canvas.clipPath(Path()
          ..addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 46)));
        canvas.drawPath(
            Path()
              ..moveTo(10, 74)
              ..quadraticBezierTo(50, 40, 90, 74)
              ..lineTo(90, 90)
              ..lineTo(10, 90)
              ..close(),
            soft);
        final centre = Path()
          ..moveTo(40, 90)
          ..cubicTo(36, 68, 72, 66, 66, 48)
          ..cubicTo(62, 36, 46, 36, 50, 22);
        final m = centre.computeMetrics().first;
        final l = <Offset>[], r = <Offset>[];
        const steps = 24;
        for (var i = 0; i <= steps; i++) {
          final t = m.getTangentForOffset(m.length * i / steps)!;
          final half = 11 - 9 * i / steps;
          final n = Offset(-t.vector.dy, t.vector.dx);
          l.add(t.position + n * half);
          r.add(t.position - n * half);
        }
        canvas.drawPath(Path()..addPolygon([...l, ...r.reversed], true), ink);
        for (var d = 8.0; d < m.length * 0.7; d += 13) {
          canvas.drawPath(m.extractPath(d, d + 5), knock);
        }
        canvas.restore();

      // ---- WHERE DO I STAND --------------------------------------------------
      case TtcTabMark.pin:
        canvas.drawOval(const Rect.fromLTRB(32, 78, 68, 88), soft);
        canvas.drawPath(
            Path()
              ..moveTo(50, 84)
              ..cubicTo(40, 70, 27, 58, 27, 40)
              ..arcToPoint(const Offset(73, 40),
                  radius: const Radius.circular(23))
              ..cubicTo(73, 58, 60, 70, 50, 84)
              ..close(),
            ink);
        canvas.drawCircle(const Offset(50, 40), 9, ground);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(TtcTabPainter old) =>
      old.mark != mark || old.tint != tint;
}

/// A heart centred on (cx, cy), about [w] wide.
Path _heart(double cx, double cy, double w) {
  final h = w * 0.5;
  return Path()
    ..moveTo(cx, cy + h * 0.85)
    ..cubicTo(cx - w * 0.62, cy + h * 0.1, cx - w * 0.5, cy - h * 1.05, cx,
        cy - h * 0.45)
    ..cubicTo(cx + w * 0.5, cy - h * 1.05, cx + w * 0.62, cy + h * 0.1, cx,
        cy + h * 0.85)
    ..close();
}

/// A pointed leaf (or petal) from [a] to [b], [w] across at its widest.
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
