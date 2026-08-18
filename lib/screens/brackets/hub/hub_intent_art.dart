// =============================================================================
//  HubIntentArt — a drawn mark per intent door
// -----------------------------------------------------------------------------
//  The "What do you need right now?" doors are the primary navigation of every
//  problem hub (FINAL SPEC §5.3), so they get the treatment the V3 home already
//  uses for its doors: a gradient well in the door's own hue with a drawn mark
//  in it — not a Material glyph, and not a pill with a coloured arrow.
//
//  ⚠️ WHY NOT REUSE `BracketMark`. Those name PROBLEMS — scans, sleep, PCOS. An
//  intent is a verb: understand, check, ask. Putting the scan-strip mark on
//  "Understand my next scan" would say "scans" twice on a screen already
//  titled Scans, and say nothing about what the door does.
//
//  ⚠️ AND WHY THESE FOUR ARE WORTH DRAWING PROPERLY: they are not
//  Scans-specific. "Understand a document", "see my appointments", "ask someone"
//  recur across most of the forty hubs. This is the start of a small shared set,
//  which is exactly the symmetry §6 asks for — the same solution type looks the
//  same everywhere in the app.
//
//  Same vocabulary as every other mark file: ONE FILLED FOCAL SHAPE in the
//  door's hue, detail KNOCKED OUT IN WHITE, every tone derived from the tint so
//  the palette stays coherent for free. Authored in a 100×100 box, drawn for a
//  ~64dp well.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

enum IntentMark {
  /// An ultrasound fan — the beam, not the machine.
  scanFan,

  /// A page with a line picked out: a report, and the word she is looking for.
  reportPage,

  /// A calendar page with one day marked.
  calendarDay,

  /// A speech bubble with a medical cross: asking a person, not reading a page.
  askDoctor,

  /// A rail with three stations and one knocked out — where she is on the run
  /// of tests, not a list of them. The raised station is what stops it reading
  /// as three buttons in a row.
  timelineRail,

  /// A road already walked, and the stretch ahead with an arrow on it. The
  /// question "what happens next?" is about time, so the mark is a journey
  /// rather than an object.
  nextStep,

  // ---------------------------------------------------------------------------
  //  THE REST OF THE FORTY HUBS
  // ---------------------------------------------------------------------------
  //  ⚠️ MARKS ARE REUSED ACROSS HUBS, BY MEANING. The rule is only that two
  //  doors on the SAME hub cannot share one — and that is deliberate rather
  //  than a shortcut: a hue belongs to a subject and stays with it everywhere,
  //  and so should a mark. "Log a reading" should look the same whether she is
  //  logging blood pressure in Complications or sleep in Sleep, because it is
  //  the same act. Twenty-odd marks used meaningfully beats sixty used once.

  /// A line chart with a logged point — the act of recording something
  /// repeatedly. Blood pressure, sugar, sleep, weight.
  chartLog,

  /// A plate with food arranged on it, seen from above.
  plate,

  /// A body outline with one area picked out — a condition or a symptom that
  /// lives somewhere specific.
  bodyMark,

  /// A weighing scale — a number someone else is watching.
  scaleMark,

  /// A packed bag with a handle.
  bagMark,

  /// A face, drawn as the barest possible arc — how she is feeling, without
  /// picking an emoji's opinion for her.
  moodArc,

  /// Two cupped hands. Support offered, not instructions given.
  cuppedHands,

  /// A moon and one star. Night, not bedtime.
  moonMark,

  /// A bottle and a curve — feeding, whichever way she does it.
  feedMark,

  /// Footprints going up a step. Development as movement, never as a score.
  stepsMark,

  /// Building blocks stacked. Play that does something.
  blocksMark,

  /// A checklist with one tick — readiness, not a test.
  checkMark,

  /// A small seat. Potty training, drawn plainly, because coyness about it
  /// helps nobody.
  seatMark,

  /// A school building's roofline with a door.
  schoolMark,

  /// A cycle ring with a marked arc — the fertile window, drawn as a portion
  /// of a loop rather than as a calendar.
  cycleRing,

  /// A question mark set in a circle — "should I?", the decision doors.
  questionMark,

  /// A single sperm, drawn simply. Male fertility, named rather than implied.
  spermMark,

  /// An upward line with a small leaf at the tip — improving something slowly.
  improveMark,

  /// Two rectangles side by side with a divider — comparing.
  compareMark,

  /// A list with three lines and a small bullet each — what you actually need.
  listMark,

  /// A lamp with a flame. Ritual and tradition.
  lampMark,

  /// A lotus, opened. Stillness, practice.
  lotusMark,

  /// A compass rose. The skill picker — many directions, one child.
  compassMark,
}

class HubIntentArt extends StatelessWidget {
  const HubIntentArt({super.key, required this.mark, required this.tint});

  final IntentMark mark;

  /// The door's pastel. Everything else is derived — see v2_block_art.dart for
  /// why passing a flat colour instead produced six grey lumps.
  final Color tint;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _IntentPainter(mark, intentSeed(tint)),
        size: Size.infinite,
      );
}

Color intentSeed(Color tint) =>
    HSLColor.fromColor(tint).withSaturation(0.46).withLightness(0.44).toColor();

/// Draws straight onto a canvas, so a preview renders exactly what ships.
void paintIntentMark(Canvas canvas, IntentMark m, Color tint, double size) =>
    _IntentPainter(m, intentSeed(tint)).paint(canvas, Size(size, size));

class _IntentPainter extends CustomPainter {
  _IntentPainter(this.mark, this.seed);

  final IntentMark mark;
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
    final white = Paint()..color = Colors.white.withValues(alpha: 0.94);
    Paint cut(double w) => Paint()
      ..color = Colors.white.withValues(alpha: 0.94)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    // A stroke in the mark's OWN colour rather than a knockout — for lines that
    // sit on the tinted well itself instead of inside a solid shape.
    Paint cutSeed(double w) => Paint()
      ..color = seed.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;

    // ⚠️ NO HALO. These sit in a gradient well that is already the door's hue —
    // a soft disc inside a tinted box is a second background, which reads as a
    // smudge. Same call the skilling marks landed on after seeing twelve of
    // them together on a phone.

    switch (mark) {
      // ---- UNDERSTAND MY NEXT SCAN -----------------------------------------
      // The ultrasound beam: a wedge from a transducer, with the arc it sweeps.
      // Drawn as the ACT of scanning rather than as a machine — a probe on its
      // own is unrecognisable at this size, and a baby silhouette would promise
      // a picture the scan may not give her.
      case IntentMark.scanFan:
        canvas.drawPath(
            Path()
              ..moveTo(50, 20)
              ..lineTo(84, 82)
              ..lineTo(16, 82)
              ..close(),
            soft);
        // The transducer.
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(33, 13, 67, 29), const Radius.circular(6)),
            obj);
        // Two sweep arcs, knocked out of the wedge.
        for (final r in [34.0, 52.0]) {
          canvas.drawArc(Rect.fromCircle(center: const Offset(50, 24), radius: r),
              math.pi * 0.28, math.pi * 0.44, false, cut(5));
        }

      // ---- UNDERSTAND MY REPORT --------------------------------------------
      // A page with one line picked out — the word she does not understand,
      // which is the entire reason this door exists.
      case IntentMark.reportPage:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(22, 14, 78, 86), const Radius.circular(9)),
            obj);
        for (final y in [32.0, 44.0, 68.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(33, y)
                ..lineTo(y == 68 ? 55 : 67, y),
              cut(5));
        }
        // The picked-out line: solid white block rather than a stroke, so the
        // eye lands on it first.
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(33, 51, 67, 60), const Radius.circular(4)),
            white);

      // ---- SEE MY APPOINTMENTS ---------------------------------------------
      // A calendar page with one day marked. The two rings at the top are what
      // separate a calendar from a plain page at 64dp.
      case IntentMark.calendarDay:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(16, 24, 84, 86), const Radius.circular(10)),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(16, 42)
              ..lineTo(84, 42),
            cut(4));
        for (final x in [34.0, 66.0]) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromLTRB(x - 4, 12, x + 4, 30),
                  const Radius.circular(4)),
              obj);
        }
        canvas.drawCircle(const Offset(50, 64), 11, white);

      // ---- KNOW WHEN TO ASK MY DOCTOR ---------------------------------------
      // A speech bubble with a cross: a PERSON, not another page. The cross is
      // what stops it reading as the community mark.
      case IntentMark.askDoctor:
        canvas.drawPath(
            Path()
              ..addRRect(RRect.fromRectAndRadius(
                  const Rect.fromLTRB(14, 18, 86, 66),
                  const Radius.circular(15)))
              ..moveTo(34, 64)
              ..lineTo(30, 86)
              ..lineTo(54, 64)
              ..close(),
            obj);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(44, 28, 56, 56), const Radius.circular(3)),
            white);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(36, 36, 64, 48), const Radius.circular(3)),
            white);

      // ---- SEE MY TIMELINE --------------------------------------------------
      // A rail with three stations, the middle one knocked out ("you are here")
      // and the next one lifted off the rail on a stalk.
      //
      // ⚠️ The stalk is load-bearing. Without it this is three dots in a row,
      // which at 64dp reads as a segmented control — an input, not a picture of
      // time. Lifting one station is the cheapest way to say "these are in an
      // order and you are partway along it".
      case IntentMark.timelineRail:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(10, 58, 90, 66), const Radius.circular(4)),
            soft);
        for (final x in [24.0, 50.0]) {
          canvas.drawCircle(Offset(x, 62), 10, obj);
        }
        canvas.drawCircle(const Offset(50, 62), 4.5, white);
        // The next station, raised.
        canvas.drawPath(
            Path()
              ..moveTo(76, 62)
              ..lineTo(76, 36),
            cut(5));
        canvas.drawCircle(const Offset(76, 62), 10, obj);
        canvas.drawCircle(const Offset(76, 28), 11, obj);

      // ---- WHAT HAPPENS NEXT? -----------------------------------------------
      // The stretch already walked, soft; the stretch ahead, solid; an arrow on
      // the end. A signpost or a plain chevron would both read as "forward" in
      // the abstract — this reads as forward FROM somewhere, which is the
      // actual question after a scan.
      case IntentMark.nextStep:
        Paint road(double alpha) => Paint()
          ..color = seed.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(
            Path()
              ..moveTo(18, 82)
              ..quadraticBezierTo(46, 82, 52, 56),
            road(0.34));
        canvas.drawPath(
            Path()
              ..moveTo(52, 56)
              ..lineTo(60, 34),
            road(0.92));
        canvas.drawPath(
            Path()
              ..moveTo(64, 14)
              ..lineTo(80, 40)
              ..lineTo(48, 40)
              ..close(),
            obj);

      // ---- LOG A READING ----------------------------------------------------
      case IntentMark.chartLog:
        canvas.drawPath(
            Path()
              ..moveTo(16, 78)
              ..lineTo(16, 22),
            cutSeed(5));
        canvas.drawPath(
            Path()
              ..moveTo(16, 78)
              ..lineTo(86, 78),
            cutSeed(5));
        canvas.drawPath(
            Path()
              ..moveTo(24, 62)
              ..lineTo(42, 48)
              ..lineTo(58, 56)
              ..lineTo(80, 30),
            Paint()
              ..color = seed.withValues(alpha: 0.92)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 7
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round);
        // The point she just logged.
        canvas.drawCircle(const Offset(80, 30), 11, obj);
        canvas.drawCircle(const Offset(80, 30), 4.5, white);

      // ---- WHAT SHOULD I EAT -----------------------------------------------
      case IntentMark.plate:
        // ⚠️ SEEN FROM THE SIDE, NOT ABOVE. A circle with two blobs and a bar
        // inside it is a FACE — and this app already has a face mark two doors
        // away. A bowl in profile cannot be misread.
        canvas.drawPath(
            Path()
              ..moveTo(30, 40)
              ..quadraticBezierTo(50, 22, 70, 40)
              ..close(),
            soft);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(14, 40, 86, 52), const Radius.circular(6)),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(20, 52)
              ..quadraticBezierTo(50, 90, 80, 52)
              ..close(),
            obj);
        // ⚠️ WAS A PIE CHART. Filling an arc from the centre draws a pie,
        // whatever you meant. Food sits ON a plate as separate objects.

      // ---- A CONDITION THAT LIVES SOMEWHERE --------------------------------
      case IntentMark.bodyMark:
        canvas.drawCircle(const Offset(50, 24), 13, obj);
        canvas.drawPath(
            Path()
              ..moveTo(50, 40)
              ..quadraticBezierTo(74, 46, 70, 84)
              ..lineTo(30, 84)
              ..quadraticBezierTo(26, 46, 50, 40)
              ..close(),
            obj);
        canvas.drawCircle(const Offset(50, 62), 9, white);

      // ---- A NUMBER SOMEONE IS WATCHING ------------------------------------
      case IntentMark.scaleMark:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(14, 34, 86, 82), const Radius.circular(12)),
            obj);
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 66), radius: 20),
            math.pi, math.pi, false, cut(5));
        canvas.drawPath(
            Path()
              ..moveTo(50, 66)
              ..lineTo(62, 52),
            cut(5));
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(38, 16, 62, 30), const Radius.circular(5)),
            soft);

      // ---- THE BAG ----------------------------------------------------------
      case IntentMark.bagMark:
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 36), radius: 15),
            math.pi, math.pi, false, cutSeed(6));
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(16, 36, 84, 84), const Radius.circular(12)),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(16, 54)
              ..lineTo(84, 54),
            cut(4));

      // ---- HOW AM I FEELING -------------------------------------------------
      // ⚠️ Deliberately NOT a smile or a frown. The door asks her; a mark that
      // has already picked an answer is a leading question.
      case IntentMark.moodArc:
        canvas.drawCircle(const Offset(50, 50), 34, obj);
        canvas.drawCircle(const Offset(38, 42), 5, white);
        canvas.drawCircle(const Offset(62, 42), 5, white);
        canvas.drawPath(
            Path()
              ..moveTo(34, 62)
              ..lineTo(66, 62),
            cut(5));

      // ---- SUPPORT OFFERED --------------------------------------------------
      case IntentMark.cuppedHands:
        // ⚠️ WITHOUT THE SEAM THIS IS A BOWL. Two hands need to read as two.
        canvas.drawPath(
            Path()
              ..moveTo(12, 46)
              ..quadraticBezierTo(20, 80, 50, 80)
              ..quadraticBezierTo(80, 80, 88, 46)
              ..quadraticBezierTo(78, 64, 50, 64)
              ..quadraticBezierTo(22, 64, 12, 46)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(50, 64)
              ..lineTo(50, 80),
            cut(4));
        // What the hands are holding: a heart, not a ball.
        canvas.drawPath(
            Path()
              ..moveTo(50, 46)
              ..quadraticBezierTo(38, 30, 50, 24)
              ..quadraticBezierTo(62, 30, 50, 46)
              ..close(),
            soft);
        canvas.drawCircle(const Offset(43, 32), 8, soft);
        canvas.drawCircle(const Offset(57, 32), 8, soft);

      // ---- NIGHT ------------------------------------------------------------
      case IntentMark.moonMark:
        canvas.drawPath(
            Path()
              ..addOval(Rect.fromCircle(center: const Offset(46, 50), radius: 32))
              ..addOval(Rect.fromCircle(center: const Offset(64, 40), radius: 28))
              ..fillType = PathFillType.evenOdd,
            obj);
        canvas.drawCircle(const Offset(76, 72), 5, obj);

      // ---- FEEDING ----------------------------------------------------------
      case IntentMark.feedMark:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(34, 30, 66, 86), const Radius.circular(13)),
            obj);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(42, 12, 58, 30), const Radius.circular(6)),
            soft);
        canvas.drawPath(
            Path()
              ..moveTo(34, 48)
              ..lineTo(66, 48),
            cut(4));
        canvas.drawPath(
            Path()
              ..moveTo(42, 62)
              ..lineTo(58, 62),
            cut(4));

      // ---- DEVELOPMENT ------------------------------------------------------
      case IntentMark.stepsMark:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(12, 66, 42, 84), const Radius.circular(5)),
            soft);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(36, 48, 66, 84), const Radius.circular(5)),
            soft);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(60, 28, 90, 84), const Radius.circular(5)),
            obj);
        canvas.drawCircle(const Offset(75, 16), 8, obj);

      // ---- PLAY -------------------------------------------------------------
      case IntentMark.blocksMark:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(14, 52, 48, 86), const Radius.circular(7)),
            obj);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(52, 52, 86, 86), const Radius.circular(7)),
            soft);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(33, 14, 67, 48), const Radius.circular(7)),
            obj);
        canvas.drawCircle(const Offset(50, 31), 6, white);

      // ---- READY? -----------------------------------------------------------
      case IntentMark.checkMark:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(18, 14, 82, 86), const Radius.circular(11)),
            obj);
        for (final y in [34.0, 52.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(30, y)
                ..lineTo(70, y),
              cut(5));
        }
        canvas.drawPath(
            Path()
              ..moveTo(31, 70)
              ..lineTo(43, 80)
              ..lineTo(69, 62),
            cut(7));

      // ---- POTTY ------------------------------------------------------------
      case IntentMark.seatMark:
        canvas.drawPath(
            Path()
              ..addOval(const Rect.fromLTRB(16, 22, 84, 52))
              ..addOval(const Rect.fromLTRB(32, 30, 68, 44))
              ..fillType = PathFillType.evenOdd,
            obj);
        // ⚠️ A wide top on a narrow stem is a mushroom at any size. A potty is
        // a wide seat on a wide body — no waist.
        canvas.drawPath(
            Path()
              ..moveTo(24, 44)
              ..lineTo(76, 44)
              ..lineTo(68, 82)
              ..lineTo(32, 82)
              ..close(),
            obj);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(26, 80, 74, 88), const Radius.circular(4)),
            soft);

      // ---- SCHOOL -----------------------------------------------------------
      case IntentMark.schoolMark:
        canvas.drawPath(
            Path()
              ..moveTo(50, 14)
              ..lineTo(90, 40)
              ..lineTo(10, 40)
              ..close(),
            obj);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(18, 40, 82, 86), const Radius.circular(6)),
            obj);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(42, 58, 58, 86), const Radius.circular(4)),
            white);

      // ---- THE FERTILE WINDOW -----------------------------------------------
      // A portion of a loop, not a calendar: the window is a phase, and a grid
      // of days invites her to read it as a guarantee about one of them.
      case IntentMark.cycleRing:
        // ⚠️ A heavy arc around a filled centre reads as a pupil in a lid. The
        // centre is empty now and the window is marked ON the ring.
        canvas.drawCircle(const Offset(50, 50), 32,
            Paint()
              ..color = seed.withValues(alpha: 0.30)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 9);
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 50), radius: 32),
            -math.pi * 0.92, math.pi * 0.58, false,
            Paint()
              ..color = seed.withValues(alpha: 0.92)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 11
              ..strokeCap = StrokeCap.round);
        canvas.drawCircle(const Offset(50, 18), 7, obj);

      // ---- SHOULD I? --------------------------------------------------------
      case IntentMark.questionMark:
        canvas.drawCircle(const Offset(50, 50), 36, obj);
        canvas.drawPath(
            Path()
              ..moveTo(38, 40)
              ..quadraticBezierTo(38, 26, 51, 26)
              ..quadraticBezierTo(64, 26, 62, 40)
              ..quadraticBezierTo(60, 50, 50, 54)
              ..lineTo(50, 60),
            cut(7));
        canvas.drawCircle(const Offset(50, 72), 5, white);

      // ---- MALE FERTILITY ---------------------------------------------------
      case IntentMark.spermMark:
        canvas.drawCircle(const Offset(30, 42), 15, obj);
        canvas.drawCircle(const Offset(30, 42), 5.5, white);
        canvas.drawPath(
            Path()
              ..moveTo(44, 46)
              ..quadraticBezierTo(64, 52, 60, 66)
              ..quadraticBezierTo(56, 80, 78, 82),
            Paint()
              ..color = seed.withValues(alpha: 0.92)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 7
              ..strokeCap = StrokeCap.round);

      // ---- IMPROVE SOMETHING SLOWLY -----------------------------------------
      case IntentMark.improveMark:
        // ⚠️ One curved stroke is a paintbrush. A sprout needs a straight stem
        // with leaves either side to read as growth.
        canvas.drawPath(
            Path()
              ..moveTo(50, 86)
              ..lineTo(50, 34),
            cutSeed(8));
        canvas.drawPath(
            Path()
              ..moveTo(50, 54)
              ..quadraticBezierTo(24, 50, 20, 28)
              ..quadraticBezierTo(46, 30, 50, 54)
              ..close(),
            soft);
        canvas.drawPath(
            Path()
              ..moveTo(50, 44)
              ..quadraticBezierTo(76, 40, 80, 18)
              ..quadraticBezierTo(54, 20, 50, 44)
              ..close(),
            obj);

      // ---- COMPARE ----------------------------------------------------------
      case IntentMark.compareMark:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(12, 24, 44, 82), const Radius.circular(8)),
            obj);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(56, 34, 88, 82), const Radius.circular(8)),
            soft);
        for (final y in [40.0, 54.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(20, y)
                ..lineTo(36, y),
              cut(4));
        }

      // ---- WHAT YOU ACTUALLY NEED -------------------------------------------
      case IntentMark.listMark:
        for (var i = 0; i < 3; i++) {
          final y = 26.0 + i * 22;
          canvas.drawCircle(Offset(22, y), 7, obj);
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTRB(38, y - 5, i == 2 ? 68 : 84, y + 5),
                  const Radius.circular(5)),
              i == 0 ? obj : soft);
        }

      // ---- RITUAL -----------------------------------------------------------
      case IntentMark.lampMark:
        canvas.drawPath(
            Path()
              ..moveTo(50, 20)
              ..quadraticBezierTo(62, 34, 50, 46)
              ..quadraticBezierTo(38, 34, 50, 20)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(18, 56)
              ..quadraticBezierTo(50, 50, 82, 56)
              ..quadraticBezierTo(72, 80, 50, 80)
              ..quadraticBezierTo(28, 80, 18, 56)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(34, 62)
              ..quadraticBezierTo(50, 66, 66, 62),
            cut(4));

      // ---- STILLNESS --------------------------------------------------------
      case IntentMark.lotusMark:
        canvas.drawPath(
            Path()
              ..moveTo(50, 22)
              ..quadraticBezierTo(64, 44, 50, 62)
              ..quadraticBezierTo(36, 44, 50, 22)
              ..close(),
            obj);
        for (final dir in [-1.0, 1.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(50, 62)
                ..quadraticBezierTo(50 + dir * 40, 40, 50 + dir * 42, 62)
                ..quadraticBezierTo(50 + dir * 34, 74, 50, 62)
                ..close(),
              soft);
        }
        canvas.drawPath(
            Path()
              ..moveTo(22, 78)
              ..quadraticBezierTo(50, 88, 78, 78),
            cutSeed(5));

      // ---- THE SKILL PICKER -------------------------------------------------
      case IntentMark.compassMark:
        canvas.drawCircle(const Offset(50, 50), 34, obj);
        canvas.drawCircle(const Offset(50, 50), 25, white);
        canvas.drawPath(
            Path()
              ..moveTo(50, 28)
              ..lineTo(58, 50)
              ..lineTo(50, 44)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(50, 72)
              ..lineTo(42, 50)
              ..lineTo(50, 56)
              ..close(),
            soft);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_IntentPainter old) =>
      old.mark != mark || old.seed != seed;
}
