// =============================================================================
//  TtcToolArt — the Tools tab's marks, in the door rails' hand
// -----------------------------------------------------------------------------
//  ⚠️ WHY (2026-09-29, the user on build 18): "in Tools you have used icons,
//  but what we are using is marks, that glyph, very evidently visible as the
//  thumbnail for the doors and inside the doors ... it looks like a different
//  side of the application, which it should not."
//
//  The doors' tab rails draw `TtcTabArt`: an OBJECT on a DISC of the tab's
//  tint, two tones of one hue, detail knocked out in the ground colour. The
//  Tools hub drew Material line glyphs in square tinted wells, the one place
//  in the stage still speaking the settings-screen language. So every tool
//  now has its own mark in the rail's family, and the hub draws it as the
//  rail does: the disc IS the well.
//
//  HOW THIS FILE KEEPS THE FAMILY ONE FAMILY
//    · Where the rail already has a mark that means the object, the tool
//      BORROWS it (`_borrowed`), painted by `TtcTabPainter` itself: Cycle
//      companion is the rail's ring of days with the period drop, Fertile
//      window is its fertile ring, Ovulation tests its test strip, Weight its
//      scale, Supplements its jar, Medical tests its vial and report, the
//      specialist check its signpost ("Should I get help?"), the treatment
//      round its timeline, food its bowl, the pre-pregnancy checklist its
//      clipboard. One object, one drawing, wherever it appears.
//    · Where no mark exists (a face for Symptoms and mood, a questionnaire for
//      the PCOS check, a heart with a pulse for his health, a blister pack, a
//      syringe, a folder, a calendar page, a question in a bubble) it is drawn
//      HERE on `TtcTabPainter`'s canvas rules: the 100×100 canvas, the r46
//      ground disc, `ttcTabInk` / `ttcTabGround` from the tint, soft = ink at
//      32%, and its three weights (6 / 11 / 4). The heart is the rail's own
//      (`ttcTabHeart`), so the two families cannot drift.
//    · No two rows on the hub share a mark (`test/ttc_tool_marks_test.dart`).
//
//  Tinting: the caller passes `v2BlockTint(groupHue)`, the hue of the tool's
//  Tools group (`ttc_tool_hues.dart`), exactly as the rail passes its tab's.
//
//  Mobbin, the shape this copies:
//    · Noom, "All tools": each tool a drawn object on a coloured disc, name,
//      chevron — a tools list that looks like the rest of the app:
//      https://mobbin.com/screens/a4710a2a-449c-4014-aca2-ce8501600a11
//    · Gentler Streak, insights list, one drawn object per row:
//      https://mobbin.com/screens/eb117be8-7532-49ff-8f57-57aeeb9630c9
//    · Flo, Interests list, one round two-tone picture per topic (the rail's
//      own reference, `ttc_tab_art.dart`):
//      https://mobbin.com/screens/f983b7eb-82f1-4aa4-b1f0-24a35f1c6a6f
//
//  FOR THE DOORS: `ttcToolMarkForSurface` maps a door tile's surface id to its
//  tool mark, so a tool card on a door can draw the same object the hub row
//  does. The doors own whether and how they use it.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import 'doors/ttc_tab_art.dart';

/// One mark per tool, named for the TOOL (unlike `TtcTabMark`, which is named
/// for the object), because the map from tool to object is the decision this
/// file records.
enum TtcToolMark {
  // ---- Your body
  cycle,
  ovulation,
  window,
  symptoms,
  weight,
  habits,
  pcosCheck,
  // ---- Both of you
  partnerHealth,
  // ---- Care and medicines
  fertilityHelp,
  supplements,
  medication,
  tests,
  vaccinations,
  records,
  appointments,
  treatment,
  // ---- Plan and check
  nutrition,
  canI,
  precheck,
  // ---- rows that moved to More (2026-09-28), so More can draw them too
  expert,
  courses,
  map,
  // ---- door-only surfaces that are tools but not hub rows
  cycleReport,
  practice,
  careCircle,
  // ---- drawn for the PREGNANCY Tools tab (2026-10-02), in this family's own
  // style, for the three things TTC's set had no object for. Not in
  // `kTtcToolMarks`: they are not TTC hub rows.
  hospitalBag,
  stopwatch,
  bell,
}

/// Every hub row's id (hers and his) and every moved row's id, to its mark.
/// `test/ttc_tool_marks_test.dart` fails if a Tools row has no entry here.
const Map<String, TtcToolMark> kTtcToolMarks = {
  'cycle': TtcToolMark.cycle,
  'ovulation': TtcToolMark.ovulation,
  'window': TtcToolMark.window,
  'symptoms': TtcToolMark.symptoms,
  'weight': TtcToolMark.weight,
  'habits': TtcToolMark.habits,
  'pcos_check': TtcToolMark.pcosCheck,
  'partner_health': TtcToolMark.partnerHealth,
  'fertility_help': TtcToolMark.fertilityHelp,
  'supplements': TtcToolMark.supplements,
  'medication': TtcToolMark.medication,
  'tests': TtcToolMark.tests,
  'vaccinations': TtcToolMark.vaccinations,
  'records': TtcToolMark.records,
  'appointments': TtcToolMark.appointments,
  'treatment': TtcToolMark.treatment,
  'nutrition': TtcToolMark.nutrition,
  'canI': TtcToolMark.canI,
  'precheck': TtcToolMark.precheck,
  'expert': TtcToolMark.expert,
  'courses': TtcToolMark.courses,
  'map': TtcToolMark.map,
};

/// A tool's mark by its Tools id, or null for an id that is not a tool.
TtcToolMark? ttcToolMarkFor(String toolId) => kTtcToolMarks[toolId];

/// A door tile's surface id (`ttc_surface_router.dart`) to the mark of the tool
/// it opens, for the door tool cards. Null for a surface that is not a tool
/// (a chat, a read, a door, the store), so the caller keeps its own drawing.
TtcToolMark? ttcToolMarkForSurface(String surfaceId) {
  // Sub-routes ('ttc_treatment/start', 'ttc_precheck/…', 'ttc_practice/…')
  // open the same tool as their root.
  final root = surfaceId.split('/').first;
  return switch (root) {
    'ttc_cycle' || 'ttc_calendar' => TtcToolMark.cycle,
    'ttc_ovulation' => TtcToolMark.ovulation,
    'ttc_window' => TtcToolMark.window,
    'ttc_symptom_log' => TtcToolMark.symptoms,
    'ttc_bmi' => TtcToolMark.weight,
    'ttc_habits' => TtcToolMark.habits,
    'ttc_pcos_check' => TtcToolMark.pcosCheck,
    'ttc_partner_health' => TtcToolMark.partnerHealth,
    'ttc_fertility_help' => TtcToolMark.fertilityHelp,
    'ttc_supplements' => TtcToolMark.supplements,
    'ttc_medication' => TtcToolMark.medication,
    'ttc_tests' || 'ttc_semen_report' => TtcToolMark.tests,
    'ttc_vaccinations' => TtcToolMark.vaccinations,
    'ttc_records' => TtcToolMark.records,
    'ttc_appointments' => TtcToolMark.appointments,
    'ttc_treatment' => TtcToolMark.treatment,
    'ttc_nutrition' => TtcToolMark.nutrition,
    'ttc_can_i' => TtcToolMark.canI,
    'ttc_precheck' => TtcToolMark.precheck,
    'ttc_garbh_course' => TtcToolMark.courses,
    'ttc_cycle_report' => TtcToolMark.cycleReport,
    'ttc_ritual' || 'ttc_practice' || 'ttc_mind_today' => TtcToolMark.practice,
    'ttc_care_circle' => TtcToolMark.careCircle,
    _ => null,
  };
}

/// The rail mark a tool borrows, when the rail already draws its object.
TtcTabMark? _borrowed(TtcToolMark m) => switch (m) {
  TtcToolMark.cycle => TtcTabMark.cycleDrops,
  TtcToolMark.ovulation => TtcTabMark.testStrip,
  TtcToolMark.window => TtcTabMark.windowRing,
  TtcToolMark.weight => TtcTabMark.scale,
  // Sleep, movement, stress and lifestyle: the rail's lotus is the calm
  // habit, the same idea the Material self_improvement glyph carried.
  TtcToolMark.habits => TtcTabMark.lotus,
  TtcToolMark.fertilityHelp => TtcTabMark.signpost,
  TtcToolMark.supplements => TtcTabMark.jarLeaf,
  TtcToolMark.tests => TtcTabMark.vialReport,
  TtcToolMark.treatment => TtcTabMark.timelineDots,
  TtcToolMark.nutrition => TtcTabMark.bowl,
  TtcToolMark.precheck => TtcTabMark.checklist,
  TtcToolMark.expert => TtcTabMark.doctorChat,
  TtcToolMark.courses => TtcTabMark.openBook,
  TtcToolMark.map => TtcTabMark.pin,
  TtcToolMark.cycleReport => TtcTabMark.chartLine,
  TtcToolMark.practice => TtcTabMark.lotus,
  TtcToolMark.careCircle => TtcTabMark.twoFigures,
  _ => null,
};

/// A tool's drawn mark. Size comes from the parent box, like `TtcTabArt`.
class TtcToolArt extends StatelessWidget {
  const TtcToolArt({super.key, required this.mark, required this.tint});

  final TtcToolMark mark;

  /// The tool group's pastel (`v2BlockTint(groupHue)`).
  final Color tint;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TtcToolPainter(mark, tint),
        size: Size.infinite,
      );
}

class TtcToolPainter extends CustomPainter {
  TtcToolPainter(this.mark, this.tint);

  final TtcToolMark mark;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final borrowed = _borrowed(mark);
    if (borrowed != null) {
      TtcTabPainter(borrowed, tint).paint(canvas, size);
      return;
    }

    // The rail's canvas, exactly (`TtcTabPainter.paint`).
    final side = math.min(size.width, size.height);
    if (side <= 0) return;
    final s = side / 100;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(s);

    final groundC = ttcTabGround(tint);
    final inkC = ttcTabInk(tint);
    final softC = inkC.withValues(alpha: 0.32);
    final ground = Paint()..color = groundC;
    final ink = Paint()..color = inkC;
    final soft = Paint()..color = softC;
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    const kLine = TtcTabPainter.kLine;
    const kDetail = TtcTabPainter.kDetail;
    final knock = stroke(groundC, kDetail);
    RRect rr(double l, double t, double r, double b, [double rad = 8]) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

    canvas.drawCircle(const Offset(50, 50), 46, ground);

    switch (mark) {
      // ---- SYMPTOMS AND MOOD -------------------------------------------------
      case TtcToolMark.symptoms:
        // A face with smiling eyes, and a drop beside it: how she feels and
        // what her body does, the two things the logger holds. The drop is
        // outlined in the ground first so it sits in front of the face.
        canvas.drawCircle(const Offset(45, 55), 28, ink);
        for (final x in [35.0, 55.0]) {
          canvas.drawArc(Rect.fromCircle(center: Offset(x, 51), radius: 5),
              math.pi * 1.1, math.pi * 0.8, false, knock);
        }
        canvas.drawArc(Rect.fromCircle(center: const Offset(45, 58), radius: 11),
            math.pi * 0.2, math.pi * 0.6, false, knock);
        final drop = Path()
          ..moveTo(75, 12)
          ..cubicTo(80, 19, 85, 24, 85, 31)
          ..arcToPoint(const Offset(65, 31), radius: const Radius.circular(10))
          ..cubicTo(65, 24, 70, 19, 75, 12)
          ..close();
        canvas.drawPath(drop, stroke(groundC, 6));
        canvas.drawPath(drop, ground);
        canvas.drawPath(drop, soft);

      // ---- PCOS SYMPTOM CHECK ------------------------------------------------
      case TtcToolMark.pcosCheck:
        // A questionnaire: a card of three answers, one chosen. Not the
        // clipboard (that is the checklist's), because this one ASKS.
        canvas.drawRRect(rr(20, 14, 80, 86, 12), soft);
        final ring = stroke(inkC, kDetail);
        for (final (i, y) in [32.0, 50.0, 68.0].indexed) {
          if (i == 1) {
            canvas.drawCircle(Offset(35, y), 7.5, ink);
            canvas.drawCircle(Offset(35, y), 2.8, ground);
            canvas.drawLine(Offset(49, y), Offset(68, y), stroke(inkC, kLine));
          } else {
            canvas.drawCircle(Offset(35, y), 5.5, ring);
            canvas.drawLine(Offset(49, y), Offset(i == 0 ? 66 : 60, y), ring);
          }
        }

      // ---- PARTNER HEALTH (his own) ------------------------------------------
      case TtcToolMark.partnerHealth:
        // A heart with a pulse through it: health, his, without a body.
        canvas.drawOval(const Rect.fromLTRB(30, 80, 70, 88), soft);
        canvas.drawPath(ttcTabHeart(50, 50, 64), ink);
        canvas.drawPath(
            Path()
              ..moveTo(22, 48)
              ..lineTo(38, 48)
              ..lineTo(44, 38)
              ..lineTo(52, 60)
              ..lineTo(58, 46)
              ..lineTo(78, 46),
            knock);

      // ---- MEDICATION --------------------------------------------------------
      case TtcToolMark.medication:
        // A blister pack with one pill already taken, and one pill beside it.
        canvas.save();
        canvas.translate(46, 48);
        canvas.rotate(-0.28);
        canvas.drawRRect(rr(-24, -32, 24, 32, 10), ink);
        for (final y in [-18.0, 0.0, 18.0]) {
          for (final x in [-10.0, 10.0]) {
            final pill = rr(x - 6.5, y - 5, x + 6.5, y + 5, 5);
            if (x > 0 && y < 0) {
              canvas.drawRRect(pill, knock); // the one she has taken
            } else {
              canvas.drawRRect(pill, ground);
            }
          }
        }
        canvas.restore();
        canvas.save();
        canvas.translate(72, 73);
        canvas.rotate(0.6);
        canvas.drawRRect(rr(-11, -6, 11, 6, 6), soft);
        canvas.restore();

      // ---- VACCINATIONS ------------------------------------------------------
      case TtcToolMark.vaccinations:
        // A small, calm syringe on the diagonal: short needle, marked barrel.
        canvas.save();
        canvas.translate(50, 50);
        canvas.rotate(math.pi / 4);
        canvas.drawLine(const Offset(0, -24), const Offset(0, -36),
            stroke(inkC, kLine));
        canvas.drawRRect(rr(-11, -41, 11, -35, 3), soft);
        canvas.drawRRect(rr(-17, -26, 17, -20, 3), ink);
        canvas.drawRRect(rr(-11, -22, 11, 24, 5), ink);
        for (final y in [-10.0, 0.0, 10.0]) {
          canvas.drawLine(Offset(-11, y), Offset(-2, y), knock);
        }
        canvas.drawRRect(rr(-5, 23, 5, 30, 2), ink);
        canvas.drawLine(const Offset(0, 30), const Offset(0, 40),
            stroke(inkC, 3));
        canvas.restore();

      // ---- RECORDS AND REPORTS -----------------------------------------------
      case TtcToolMark.records:
        // A folder with a sheet showing above its front.
        canvas.drawRRect(rr(16, 20, 44, 32, 6), soft);
        canvas.drawRRect(rr(16, 26, 84, 80, 9), soft);
        canvas.drawRRect(rr(26, 30, 74, 58, 5), ground);
        for (final y in [38.0, 46.0]) {
          canvas.drawLine(Offset(34, y), Offset(y == 46 ? 56 : 66, y),
              stroke(inkC, kDetail));
        }
        canvas.drawRRect(rr(14, 50, 86, 84, 9), ink);
        canvas.drawLine(const Offset(40, 66), const Offset(60, 66), knock);

      // ---- APPOINTMENTS ------------------------------------------------------
      case TtcToolMark.appointments:
        // A calendar page with one day ringed: the visit.
        canvas.drawRRect(rr(18, 22, 82, 84, 11), ink);
        canvas.drawLine(const Offset(18, 38), const Offset(82, 38), knock);
        for (final x in [32.0, 68.0]) {
          canvas.drawRRect(rr(x - 4, 14, x + 4, 30, 4), soft);
        }
        for (final y in [52.0, 70.0]) {
          for (final x in [32.0, 50.0, 68.0]) {
            if (x == 68 && y == 70) continue;
            canvas.drawCircle(Offset(x, y), 3.4, ground);
          }
        }
        canvas.drawCircle(const Offset(68, 70), 8, ground);
        canvas.drawCircle(const Offset(68, 70), 4, ink);

      // ---- CAN I...? ---------------------------------------------------------
      case TtcToolMark.canI:
        // A question in a bubble: an everyday worry, asked.
        canvas.drawPath(
            Path()
              ..addRRect(rr(16, 16, 84, 68, 18))
              ..moveTo(30, 66)
              ..lineTo(26, 86)
              ..lineTo(48, 66)
              ..close(),
            soft);
        canvas.drawPath(
            Path()
              ..moveTo(40, 34)
              ..cubicTo(40, 22, 61, 22, 61, 33)
              ..cubicTo(61, 42, 50, 42, 50, 50),
            stroke(inkC, 8));
        canvas.drawCircle(const Offset(50, 60), 4.8, ink);

      // ---- HOSPITAL BAG (pregnancy Tools) ------------------------------------
      case TtcToolMark.hospitalBag:
        // A packed bag: its handle over a rounded body, a small cross on it.
        canvas.drawOval(const Rect.fromLTRB(26, 83, 74, 91), soft);
        canvas.drawPath(
            Path()
              ..moveTo(35, 34)
              ..cubicTo(35, 12, 65, 12, 65, 34),
            stroke(inkC, kLine));
        canvas.drawRRect(rr(18, 30, 82, 83, 14), ink);
        canvas.drawLine(const Offset(18, 47), const Offset(82, 47), knock);
        canvas.drawRRect(rr(45, 54, 55, 76, 3), ground);
        canvas.drawRRect(rr(38, 60, 62, 70, 3), ground);

      // ---- STOPWATCH (pregnancy Tools: the contraction timer) -----------------
      case TtcToolMark.stopwatch:
        // A stopwatch: crown on top, a hand part-way round the face.
        canvas.drawRRect(rr(42, 10, 58, 20, 4), soft);
        canvas.drawLine(const Offset(50, 20), const Offset(50, 27), stroke(inkC, kLine));
        canvas.drawLine(const Offset(75, 30), const Offset(81, 24), stroke(inkC, kLine));
        canvas.drawCircle(const Offset(50, 58), 31, ink);
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 58), radius: 22),
            -math.pi / 2, math.pi * 0.7, false, stroke(groundC.withValues(alpha: 0.5), kDetail));
        canvas.drawLine(const Offset(50, 58), const Offset(63, 46), stroke(groundC, kLine));
        canvas.drawCircle(const Offset(50, 58), 4, ground);

      // ---- BELL (pregnancy Tools: reminders) ----------------------------------
      case TtcToolMark.bell:
        // A bell with its clapper, and a soft ring either side.
        canvas.drawCircle(const Offset(50, 15), 4.5, ink);
        canvas.drawPath(
            Path()
              ..moveTo(22, 70)
              ..cubicTo(33, 62, 33, 52, 33, 42)
              ..cubicTo(33, 28, 42, 21, 50, 21)
              ..cubicTo(58, 21, 67, 28, 67, 42)
              ..cubicTo(67, 52, 67, 62, 78, 70)
              ..close(),
            ink);
        canvas.drawLine(const Offset(20, 72), const Offset(80, 72), stroke(inkC, kLine));
        canvas.drawCircle(const Offset(50, 83), 7, soft);
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 46), radius: 40),
            math.pi * 1.12, math.pi * 0.2, false, stroke(inkC.withValues(alpha: 0.32), kLine));
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 46), radius: 40),
            math.pi * 1.68, math.pi * 0.2, false, stroke(inkC.withValues(alpha: 0.32), kLine));

      // Borrowed marks never reach here (see the top of `paint`).
      default:
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(TtcToolPainter old) =>
      old.mark != mark || old.tint != tint;
}

/// The TTC-family mark for a pregnancy `IntentMark`, so a list or a tab rail on
/// the pregnancy side draws the same objects as the trying-to-conceive side
/// (2026-10-02, the user: match Tools, More and the doors to TTC's marks).
/// Null for a mark with no counterpart: the caller keeps its own drawing.
///
/// [forDoor] only changes one answer, because one pregnancy mark means two
/// things: a calendar page is the due date on the Tools list (the cycle ring
/// with one day marked) and a visit or a scan schedule on a door tab (the
/// appointments calendar).
Widget? ttcFamilyMarkForIntent(IntentMark? m, Color tint,
        {bool forDoor = false}) =>
    switch (m) {
      IntentMark.stepsMark => TtcMarkLeading(tab: TtcTabMark.heartHand, tint: tint),
      IntentMark.scaleMark => TtcMarkLeading(tool: TtcToolMark.weight, tint: tint),
      IntentMark.pillMark => TtcMarkLeading(tool: TtcToolMark.medication, tint: tint),
      IntentMark.chartLog => TtcMarkLeading(tab: TtcTabMark.chartLine, tint: tint),
      IntentMark.lotusMark => TtcMarkLeading(tab: TtcTabMark.lotus, tint: tint),
      IntentMark.nextStep => TtcMarkLeading(tool: TtcToolMark.bell, tint: tint),
      IntentMark.bagMark => TtcMarkLeading(tool: TtcToolMark.hospitalBag, tint: tint),
      IntentMark.reportPage => TtcMarkLeading(tool: TtcToolMark.records, tint: tint),
      IntentMark.timelineRail => TtcMarkLeading(tool: TtcToolMark.stopwatch, tint: tint),
      IntentMark.calendarDay => forDoor
          ? TtcMarkLeading(tool: TtcToolMark.appointments, tint: tint)
          : TtcMarkLeading(tab: TtcTabMark.windowRing, tint: tint),
      IntentMark.listMark => TtcMarkLeading(tab: TtcTabMark.checklist, tint: tint),
      IntentMark.bookMark => TtcMarkLeading(tab: TtcTabMark.openBook, tint: tint),
      IntentMark.bodyMark => TtcMarkLeading(tab: TtcTabMark.bigSmallHearts, tint: tint),
      IntentMark.lampMark => TtcMarkLeading(tab: TtcTabMark.sunrise, tint: tint),
      IntentMark.askDoctor => TtcMarkLeading(tab: TtcTabMark.twoBubbles, tint: tint),
      // Door tabs only: marks the Tools list never uses.
      IntentMark.scanFan => forDoor
          ? TtcMarkLeading(tab: TtcTabMark.vialReport, tint: tint)
          : null,
      IntentMark.cuppedHands => forDoor
          ? TtcMarkLeading(tab: TtcTabMark.heartHand, tint: tint)
          : null,
      IntentMark.sunMark =>
        forDoor ? TtcMarkLeading(tab: TtcTabMark.sun, tint: tint) : null,
      IntentMark.checkMark => forDoor
          ? TtcMarkLeading(tab: TtcTabMark.checklist, tint: tint)
          : null,
      IntentMark.questionMark =>
        forDoor ? TtcMarkLeading(tool: TtcToolMark.canI, tint: tint) : null,
      IntentMark.pageMark => forDoor
          ? TtcMarkLeading(tab: TtcTabMark.openBook, tint: tint)
          : null,
      IntentMark.forkMark || IntentMark.cookMark =>
        forDoor ? TtcMarkLeading(tab: TtcTabMark.bowl, tint: tint) : null,
      _ => null,
    };

/// A mark by its object rather than by a TTC tool id: either a tool mark or a
/// rail mark, in the same 44 box and disc as `TtcToolMarkLeading`. The
/// pregnancy Tools and More rows use it, so the two stages' lists draw one
/// family (2026-10-02).
class TtcMarkLeading extends StatelessWidget {
  const TtcMarkLeading({
    super.key,
    this.tool,
    this.tab,
    required this.tint,
    this.size = 44,
  });

  final TtcToolMark? tool;
  final TtcTabMark? tab;
  final Color tint;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: tool != null
              ? TtcToolArt(mark: tool!, tint: tint)
              : tab != null
                  ? TtcTabArt(mark: tab!, tint: tint)
                  : CustomPaint(painter: _DiscOnly(tint)),
        ),
      );
}

/// The hub row's leading mark: the disc is the well, as on the door rail.
/// Keyed per tool so tests can find it (`ttc_tool_mark_<id>`). Decorative:
/// the row's title already says what the tool is.
class TtcToolMarkLeading extends StatelessWidget {
  const TtcToolMarkLeading({
    super.key,
    required this.toolId,
    required this.tint,
    this.size = 44,
  });

  final String toolId;
  final Color tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mark = ttcToolMarkFor(toolId);
    return ExcludeSemantics(
      child: SizedBox(
        key: ValueKey('ttc_tool_mark_$toolId'),
        width: size,
        height: size,
        child: mark == null
            // Never an empty hole: an id without a mark (a test fails for
            // that) still gets its disc.
            ? CustomPaint(painter: _DiscOnly(tint))
            : TtcToolArt(mark: mark, tint: tint),
      ),
    );
  }
}

class _DiscOnly extends CustomPainter {
  _DiscOnly(this.tint);
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2 * 0.92;
    canvas.drawCircle(size.center(Offset.zero), r,
        Paint()..color = ttcTabGround(tint));
  }

  @override
  bool shouldRepaint(_DiscOnly old) => old.tint != tint;
}

/// The size of a tool's mark in its page's header.
const double kTtcToolHeaderMarkSize = 40;

/// A tool's mark in its page's header, above the eyebrow (2026-09-29): the
/// object she tapped on the Tools row greets her on the page it opens, the way
/// Noom's Heart Health page puts its glyph over the title
/// (https://mobbin.com/screens/06265f0f-5477-4e42-96db-14bad972747f).
/// Keyed `ttc_tool_header_mark_<id>`. Null when the id has no mark, so a
/// caller can drop the row and its gap together. Tinted by the header's own
/// field (`v2BlockTint(hue)`), so the disc belongs to the colour behind it.
Widget? ttcToolHeaderMark(String? toolId, Color tint) {
  if (toolId == null) return null;
  final mark = ttcToolMarkFor(toolId);
  if (mark == null) return null;
  return ExcludeSemantics(
    child: SizedBox(
      key: ValueKey('ttc_tool_header_mark_$toolId'),
      width: kTtcToolHeaderMarkSize,
      height: kTtcToolHeaderMarkSize,
      child: TtcToolArt(mark: mark, tint: tint),
    ),
  );
}
