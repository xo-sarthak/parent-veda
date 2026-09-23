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

  // ---------------------------------------------------------------------------
  //  NUTRITION'S FIVE NEEDS — 2026-09-21
  // ---------------------------------------------------------------------------
  //  The Did-you-get ticks, "Strong in" on a dish and the need pages wore
  //  Material line icons while the rail cards above them wore these drawn
  //  marks — two hands on one door (the user: "so two varieties?"). The rule
  //  now: a mark that stands for a CONCEPT is drawn; chrome (chevrons, search,
  //  close) stays Material. Iron, calcium, protein, folate and fibre are
  //  concepts.

  /// A spinach leaf with its midrib — the iron of an Indian kitchen.
  ironMark,

  /// A glass of milk, side on, the milk line below the rim.
  calciumMark,

  /// An egg in a cup — protein as the everyday object, not a molecule.
  proteinMark,

  /// A sprig of three small leaves — the greens folate comes from.
  folateMark,

  /// A wheat ear — whole grain, the bran on.
  fibreMark,

  // ---------------------------------------------------------------------------
  //  THE FORMATS — 2026-09-21
  // ---------------------------------------------------------------------------
  //  Every read row and tool tile on every door wore a Material icon in a
  //  grey well (a book on all eight fasting rows) — "generic, ugly" (the
  //  user). A format is a concept, so it is drawn: these five plus the marks
  //  the other formats already had (reportPage, checkMark, blocksMark, plate,
  //  calendarDay, askDoctor, questionMark). See `pvDoorFormatMark`.

  /// An open book — a guide, something she comes back to.
  bookMark,

  /// A slider with its knob — a tool, something she sets.
  toolMark,

  /// A play triangle in a rounded frame — a film.
  playMark,

  /// Headphones — a track.
  audioMark,

  /// A page with a fold and two lines — an article or a read.
  pageMark,

  /// A capsule, two halves — a medicine (Is it safe? · Take).
  pillMark,

  /// A kadhai with two handles and steam rising — cooked food, a recipe.
  /// (The Recipes tab wore cupped hands, which says care, not cooking — the
  /// user, 2026-09-21.)
  cookMark,

  // ---------------------------------------------------------------------------
  //  THE MEALS — 2026-09-22
  // ---------------------------------------------------------------------------
  //  The Recipes tab's "What are you after?" tiles wore photos, and two tiles
  //  wore the same photo (breakfast and snacks; lunch and dinner) because a
  //  tile borrowed its first recipe's picture. The user: "use the mark … with
  //  the tinted background … and please don't use it of the same colour."
  //  So each meal and each kind has a mark of its own and a hue of its own.
  //  Today's rail card takes the sun; What to eat now takes the cutlery.

  /// A sun over a horizon line, five rays — the day; breakfast.
  sunMark,

  /// A fork and a spoon, crossed — what to eat.
  forkMark,

  /// A chai cup with its handle and two wisps — the morning.
  chaiMark,

  /// A samosa: a triangle with a crimped edge — a snack.
  snackMark,

  /// A soup bowl with a spoon resting in it.
  bowlMark,

  /// A laddoo: a disc with the boondi as dots.
  sweetMark,

  // ---------------------------------------------------------------------------
  //  THE BODY AREAS — 2026-09-22, the Symptoms door
  // ---------------------------------------------------------------------------
  //  Six areas group the symptom library by where she feels it. Four are new;
  //  the back (`bodyMark`) and sleep (`moonMark`) were already drawn.

  /// A tummy: a soft rounded belly in profile with a wave inside — digestion.
  tummyMark,

  /// A head in profile with a zigzag at the temple — headaches, dizziness.
  headMark,

  /// A patch of skin: a rounded square with three tiny itch strokes.
  skinMark,

  /// A tiny foot, sole up — a kick.
  kickMark,

  // ---------------------------------------------------------------------------
  //  THE SYMPTOMS THEMSELVES — 2026-09-22, the user: "for headache, bloating,
  //  mood swings … if it's possible". Each common symptom wears its own mark;
  //  the rarer ones wear their area's. `symptomMark()` in symptoms_widgets.
  // ---------------------------------------------------------------------------

  /// A flame — heartburn.
  flameMark,

  /// A tight coil — constipation.
  coilMark,

  /// A battery, one bar left — fatigue.
  batteryMark,

  /// A balloon on a string — bloating.
  balloonMark,

  /// A spoon — taste.
  spoonMark,

  /// A plate with a bar across it — food aversions.
  noPlateMark,

  /// A spine: a stack of discs with a bolt beside it — back pain.
  spineMark,

  /// A lightning bolt — a cramp.
  boltMark,

  /// A droplet — urine, leaking.
  dropMark,

  /// A handset — "what to say when you call" (2026-09-23). The door had no
  /// phone, so a card about phoning wore the tool format's sliders.
  phoneMark,

  /// A spiral — dizziness.
  spiralMark,

  /// Three wind lines — breathlessness.
  windMark,

  /// A moon with a z — trouble sleeping.
  sleepMark,

  /// A nose in profile with two scent lines — smell.
  noseMark,

  /// A thermometer — feeling hot.
  thermoMark,

  /// A tooth — gums.
  toothMark,

  /// A foot from the side, puffed — swelling.
  swellMark,
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
      // ---- NUTRITION'S FIVE NEEDS -------------------------------------------
      case IntentMark.ironMark:
        // A leaf: two arcs meeting at the tip, the midrib cut through.
        canvas.drawPath(
            Path()
              ..moveTo(50, 12)
              ..quadraticBezierTo(90, 30, 58, 84)
              ..quadraticBezierTo(46, 90, 42, 84)
              ..quadraticBezierTo(10, 30, 50, 12)
              ..close(),
            obj);
        canvas.drawLine(const Offset(50, 22), const Offset(50, 82), cut(5));
        canvas.drawLine(const Offset(50, 46), const Offset(66, 34), cut(4));
        canvas.drawLine(const Offset(50, 62), const Offset(34, 50), cut(4));
      case IntentMark.calciumMark:
        // A glass, slightly tapered, and the milk inside it.
        canvas.drawPath(
            Path()
              ..moveTo(28, 14)
              ..lineTo(72, 14)
              ..lineTo(66, 86)
              ..lineTo(34, 86)
              ..close(),
            soft);
        canvas.drawPath(
            Path()
              ..moveTo(31, 40)
              ..lineTo(69, 40)
              ..lineTo(66, 86)
              ..lineTo(34, 86)
              ..close(),
            obj);
        canvas.drawLine(const Offset(28, 14), const Offset(72, 14), cutSeed(5));
      case IntentMark.proteinMark:
        // An egg standing in a cup.
        canvas.drawPath(
            Path()
              ..moveTo(24, 62)
              ..lineTo(76, 62)
              ..quadraticBezierTo(74, 90, 50, 90)
              ..quadraticBezierTo(26, 90, 24, 62)
              ..close(),
            soft);
        canvas.drawOval(const Rect.fromLTRB(32, 12, 68, 66), obj);
        canvas.drawLine(const Offset(24, 62), const Offset(76, 62), cutSeed(4));
      case IntentMark.folateMark:
        // A stem with three leaves — the greens, not a tablet.
        canvas.drawLine(const Offset(50, 88), const Offset(50, 30), cutSeed(6));
        canvas.drawPath(
            Path()
              ..moveTo(50, 30)
              ..quadraticBezierTo(70, 6, 76, 26)
              ..quadraticBezierTo(70, 44, 50, 30)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(50, 50)
              ..quadraticBezierTo(24, 30, 22, 50)
              ..quadraticBezierTo(28, 68, 50, 50)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(50, 66)
              ..quadraticBezierTo(76, 52, 78, 70)
              ..quadraticBezierTo(70, 86, 50, 66)
              ..close(),
            obj);
      case IntentMark.fibreMark:
        // A wheat ear: a stem and grains climbing it in pairs.
        canvas.drawLine(const Offset(50, 90), const Offset(50, 22), cutSeed(6));
        for (var i = 0; i < 4; i++) {
          final y = 74.0 - i * 15;
          canvas.drawOval(Rect.fromCenter(center: Offset(38, y), width: 20, height: 12), obj);
          canvas.drawOval(Rect.fromCenter(center: Offset(62, y), width: 20, height: 12), obj);
        }
        canvas.drawOval(const Rect.fromLTRB(42, 10, 58, 26), obj);

      // ---- THE FORMATS --------------------------------------------------------
      case IntentMark.bookMark:
        // Two leaves meeting at the spine, the text lines knocked out.
        canvas.drawPath(
            Path()
              ..moveTo(50, 26)
              ..quadraticBezierTo(30, 16, 12, 24)
              ..lineTo(12, 80)
              ..quadraticBezierTo(30, 72, 50, 82)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(50, 26)
              ..quadraticBezierTo(70, 16, 88, 24)
              ..lineTo(88, 80)
              ..quadraticBezierTo(70, 72, 50, 82)
              ..close(),
            obj);
        canvas.drawLine(const Offset(50, 26), const Offset(50, 82), cut(3));
        canvas.drawLine(const Offset(22, 38), const Offset(40, 42), cut(3));
        canvas.drawLine(const Offset(22, 52), const Offset(40, 56), cut(3));
        canvas.drawLine(const Offset(60, 42), const Offset(78, 38), cut(3));
        canvas.drawLine(const Offset(60, 56), const Offset(78, 52), cut(3));
      case IntentMark.toolMark:
        // Two slider tracks, a knob on each at different points.
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTRB(14, 30, 86, 40), const Radius.circular(5)), soft);
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTRB(14, 60, 86, 70), const Radius.circular(5)), soft);
        canvas.drawCircle(const Offset(62, 35), 11, obj);
        canvas.drawCircle(const Offset(36, 65), 11, obj);
      case IntentMark.playMark:
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTRB(12, 18, 88, 82), const Radius.circular(18)), obj);
        canvas.drawPath(
            Path()
              ..moveTo(41, 34)
              ..lineTo(68, 50)
              ..lineTo(41, 66)
              ..close(),
            white);
      case IntentMark.audioMark:
        // The band over the head, a cup on each side.
        canvas.drawPath(
            Path()
              ..moveTo(20, 60)
              ..lineTo(20, 50)
              ..quadraticBezierTo(20, 18, 50, 18)
              ..quadraticBezierTo(80, 18, 80, 50)
              ..lineTo(80, 60),
            cutSeed(7));
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTRB(12, 52, 32, 82), const Radius.circular(8)), obj);
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTRB(68, 52, 88, 82), const Radius.circular(8)), obj);
      case IntentMark.pageMark:
        // A sheet with the corner folded, two lines of text.
        canvas.drawPath(
            Path()
              ..moveTo(24, 12)
              ..lineTo(62, 12)
              ..lineTo(78, 28)
              ..lineTo(78, 88)
              ..lineTo(24, 88)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(62, 12)
              ..lineTo(62, 28)
              ..lineTo(78, 28)
              ..close(),
            soft);
        canvas.drawLine(const Offset(36, 50), const Offset(66, 50), cut(4));
        canvas.drawLine(const Offset(36, 64), const Offset(60, 64), cut(4));

      case IntentMark.cookMark:
        // The bowl of the kadhai, its rim, the two handles, three wisps.
        canvas.drawPath(
            Path()
              ..moveTo(18, 48)
              ..lineTo(82, 48)
              ..quadraticBezierTo(80, 88, 50, 88)
              ..quadraticBezierTo(20, 88, 18, 48)
              ..close(),
            obj);
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTRB(12, 44, 88, 52), const Radius.circular(4)), obj);
        canvas.drawLine(const Offset(6, 46), const Offset(14, 40), cutSeed(5));
        canvas.drawLine(const Offset(94, 46), const Offset(86, 40), cutSeed(5));
        for (final x in [36.0, 50.0, 64.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(x, 34)
                ..quadraticBezierTo(x - 6, 26, x, 18)
                ..quadraticBezierTo(x + 6, 10, x, 4),
              soft
                ..style = PaintingStyle.stroke
                ..strokeWidth = 5
                ..strokeCap = StrokeCap.round);
        }
        soft.style = PaintingStyle.fill;
      case IntentMark.pillMark:
        // A capsule on a slant, one half solid, one half soft, the seam cut.
        canvas.save();
        canvas.translate(50, 50);
        canvas.rotate(-0.6);
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTRB(-34, -13, 0, 13), const Radius.circular(13)), obj);
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTRB(0, -13, 34, 13), const Radius.circular(13)), soft);
        canvas.drawLine(const Offset(0, -13), const Offset(0, 13), cut(3));
        canvas.restore();

      case IntentMark.sunMark:
        // The disc, the horizon under it, five rays.
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 62), radius: 22), math.pi, math.pi, true, obj);
        canvas.drawLine(const Offset(12, 66), const Offset(88, 66), cutSeed(5));
        for (final a in [-1.0, -0.5, 0.0, 0.5, 1.0]) {
          final ang = -math.pi / 2 + a * 0.62;
          canvas.drawLine(
              Offset(50 + 30 * math.cos(ang), 62 + 30 * math.sin(ang)),
              Offset(50 + 40 * math.cos(ang), 62 + 40 * math.sin(ang)),
              cutSeed(5));
        }
        canvas.drawLine(const Offset(24, 80), const Offset(76, 80), soft
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round);

      case IntentMark.forkMark:
        // A fork on the left, a spoon on the right, crossing low.
        canvas.save();
        canvas.translate(50, 50);
        canvas.rotate(-0.35);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(-4, -14, 4, 44), const Radius.circular(4)), obj);
        for (final x in [-9.0, -3.0, 3.0, 9.0]) {
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(x - 2.2, -44, x + 2.2, -12), const Radius.circular(2.2)), obj);
        }
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(-12, -20, 12, -10), const Radius.circular(3)), obj);
        canvas.restore();
        canvas.save();
        canvas.translate(50, 50);
        canvas.rotate(0.35);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(-4, -14, 4, 44), const Radius.circular(4)), soft);
        canvas.drawOval(const Rect.fromLTRB(-13, -46, 13, -10), soft);
        canvas.restore();

      case IntentMark.chaiMark:
        // The cup, its handle, the saucer, two wisps.
        canvas.drawPath(
            Path()
              ..moveTo(22, 40)
              ..lineTo(70, 40)
              ..quadraticBezierTo(70, 76, 46, 76)
              ..quadraticBezierTo(22, 76, 22, 40)
              ..close(),
            obj);
        canvas.drawArc(const Rect.fromLTRB(64, 44, 88, 68), -math.pi / 2, math.pi, false, cutSeed(6));
        canvas.drawLine(const Offset(14, 86), const Offset(80, 86), cutSeed(5));
        for (final x in [38.0, 54.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(x, 30)
                ..quadraticBezierTo(x - 6, 22, x, 14)
                ..quadraticBezierTo(x + 6, 6, x, 0),
              soft
                ..style = PaintingStyle.stroke
                ..strokeWidth = 5
                ..strokeCap = StrokeCap.round);
        }

      case IntentMark.snackMark:
        // A samosa: the triangle, a crimped seam along its top edge.
        canvas.drawPath(
            Path()
              ..moveTo(50, 12)
              ..lineTo(90, 84)
              ..quadraticBezierTo(50, 96, 10, 84)
              ..close(),
            obj);
        for (var i = 0; i < 5; i++) {
          final t = 0.18 + i * 0.16;
          canvas.drawCircle(Offset(50 + 40 * t, 12 + 72 * t), 3.2, white);
        }
        canvas.drawLine(const Offset(30, 60), const Offset(48, 78), cut(4));

      case IntentMark.bowlMark:
        // A bowl in profile, the spoon leaning out of it.
        canvas.drawPath(
            Path()
              ..moveTo(12, 44)
              ..lineTo(88, 44)
              ..quadraticBezierTo(86, 86, 50, 86)
              ..quadraticBezierTo(14, 86, 12, 44)
              ..close(),
            obj);
        canvas.drawLine(const Offset(30, 90), const Offset(70, 90), cutSeed(5));
        canvas.drawLine(const Offset(58, 40), const Offset(84, 8), cutSeed(6));
        canvas.drawOval(const Rect.fromLTRB(78, 0, 96, 16), soft);

      case IntentMark.sweetMark:
        // A laddoo: the ball, the boondi as dots, a leaf of silver on top.
        canvas.drawCircle(const Offset(50, 56), 34, obj);
        for (final d in [(36.0, 44.0), (58.0, 40.0), (44.0, 62.0), (64.0, 60.0), (52.0, 78.0), (30.0, 66.0)]) {
          canvas.drawCircle(Offset(d.$1, d.$2), 4, white);
        }
        canvas.drawOval(const Rect.fromLTRB(40, 10, 60, 24), soft);

      case IntentMark.tummyMark:
        // The belly in profile — a leaning oval — with a wave through it.
        canvas.save();
        canvas.translate(50, 54);
        canvas.rotate(-0.25);
        canvas.drawOval(const Rect.fromLTRB(-34, -30, 34, 30), obj);
        canvas.restore();
        canvas.drawPath(
            Path()
              ..moveTo(26, 56)
              ..quadraticBezierTo(36, 44, 46, 56)
              ..quadraticBezierTo(56, 68, 66, 56)
              ..quadraticBezierTo(72, 50, 76, 54),
            cut(5));

      case IntentMark.headMark:
        // A head in profile: the crown, the brow, the nose, the chin — and a
        // zigzag at the temple.
        canvas.drawPath(
            Path()
              ..moveTo(30, 90)
              ..lineTo(30, 62)
              ..quadraticBezierTo(14, 40, 30, 20)
              ..quadraticBezierTo(46, 4, 66, 14)
              ..quadraticBezierTo(84, 24, 78, 44)
              ..lineTo(84, 52)
              ..lineTo(78, 56)
              ..lineTo(78, 66)
              ..quadraticBezierTo(74, 76, 62, 74)
              ..lineTo(62, 90)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(40, 30)
              ..lineTo(50, 40)
              ..lineTo(42, 48)
              ..lineTo(52, 58),
            cut(4));

      case IntentMark.skinMark:
        // A patch of skin, and three short itch strokes across its corner.
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(16, 22, 84, 84), const Radius.circular(18)), obj);
        for (final d in [0.0, 14.0, 28.0]) {
          canvas.drawLine(Offset(34 + d, 58), Offset(46 + d, 44), cut(4));
        }
        canvas.drawCircle(const Offset(68, 70), 4, white);

      case IntentMark.kickMark:
        // A foot, sole up: the sole, the heel, five toes.
        canvas.drawOval(const Rect.fromLTRB(30, 34, 70, 92), obj);
        canvas.drawOval(const Rect.fromLTRB(26, 12, 42, 30), obj);
        canvas.drawOval(const Rect.fromLTRB(42, 6, 55, 22), obj);
        canvas.drawOval(const Rect.fromLTRB(55, 8, 66, 22), obj);
        canvas.drawOval(const Rect.fromLTRB(66, 14, 76, 27), obj);
        canvas.drawOval(const Rect.fromLTRB(74, 24, 84, 36), obj);
        canvas.drawArc(const Rect.fromLTRB(38, 50, 62, 82), 0.3, 2.5, false, cut(4));

      case IntentMark.flameMark:
        canvas.drawPath(
            Path()
              ..moveTo(50, 8)
              ..quadraticBezierTo(78, 40, 72, 62)
              ..quadraticBezierTo(68, 88, 50, 92)
              ..quadraticBezierTo(32, 88, 28, 62)
              ..quadraticBezierTo(24, 44, 38, 30)
              ..quadraticBezierTo(40, 44, 50, 40)
              ..quadraticBezierTo(46, 24, 50, 8)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(50, 56)
              ..quadraticBezierTo(62, 66, 56, 80)
              ..quadraticBezierTo(50, 88, 44, 80)
              ..quadraticBezierTo(40, 68, 50, 56)
              ..close(),
            white);

      case IntentMark.coilMark:
        canvas.drawPath(
            Path()
              ..moveTo(16, 62)
              ..cubicTo(16, 30, 44, 30, 44, 56)
              ..cubicTo(44, 78, 68, 78, 68, 52)
              ..cubicTo(68, 28, 86, 34, 86, 50),
            cutSeed(9));
        canvas.drawCircle(const Offset(86, 50), 6, obj);

      case IntentMark.batteryMark:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(12, 30, 80, 70), const Radius.circular(9)), obj);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(80, 41, 90, 59), const Radius.circular(3)), obj);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(20, 38, 72, 62), const Radius.circular(5)), white);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(20, 38, 34, 62), const Radius.circular(4)), obj);

      case IntentMark.balloonMark:
        canvas.drawOval(const Rect.fromLTRB(24, 6, 76, 66), obj);
        canvas.drawPath(
            Path()
              ..moveTo(50, 66)
              ..lineTo(44, 74)
              ..lineTo(56, 74)
              ..close(),
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(50, 74)
              ..quadraticBezierTo(40, 84, 52, 94),
            cutSeed(4));
        canvas.drawOval(const Rect.fromLTRB(36, 16, 48, 34), white);

      case IntentMark.spoonMark:
        canvas.save();
        canvas.translate(50, 50);
        canvas.rotate(-0.7);
        canvas.drawOval(const Rect.fromLTRB(-16, -46, 16, -4), obj);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(-5, -8, 5, 46), const Radius.circular(5)), obj);
        canvas.drawOval(const Rect.fromLTRB(-8, -38, 4, -18), white);
        canvas.restore();

      case IntentMark.noPlateMark:
        canvas.drawOval(const Rect.fromLTRB(10, 30, 90, 70), obj);
        canvas.drawOval(const Rect.fromLTRB(26, 38, 74, 62), white);
        canvas.drawLine(const Offset(22, 78), const Offset(78, 22), cutSeed(8));
        canvas.drawLine(const Offset(24, 76), const Offset(76, 24), cut(3));

      case IntentMark.spineMark:
        for (var i = 0; i < 5; i++) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromLTRB(34, 10.0 + i * 16, 62, 22.0 + i * 16), const Radius.circular(5)), obj);
        }
        canvas.drawPath(
            Path()
              ..moveTo(76, 34)
              ..lineTo(68, 50)
              ..lineTo(78, 50)
              ..lineTo(70, 66),
            cutSeed(5));

      case IntentMark.boltMark:
        canvas.drawPath(
            Path()
              ..moveTo(58, 6)
              ..lineTo(28, 54)
              ..lineTo(50, 54)
              ..lineTo(42, 94)
              ..lineTo(74, 42)
              ..lineTo(52, 42)
              ..close(),
            obj);

      case IntentMark.dropMark:
        canvas.drawPath(
            Path()
              ..moveTo(50, 8)
              ..quadraticBezierTo(84, 52, 76, 68)
              ..quadraticBezierTo(70, 92, 50, 92)
              ..quadraticBezierTo(30, 92, 24, 68)
              ..quadraticBezierTo(16, 52, 50, 8)
              ..close(),
            obj);
        canvas.drawCircle(const Offset(40, 70), 5, white);

      case IntentMark.phoneMark:
        // An old-telephone handset on its side: earpiece top-left, mouthpiece
        // bottom-right, the curved grip between — the shape every phone
        // icon still borrows, readable at 16pt.
        canvas.drawPath(
            Path()
              ..moveTo(22, 14)
              ..quadraticBezierTo(34, 10, 40, 22)
              ..lineTo(44, 34)
              ..quadraticBezierTo(46, 42, 38, 46)
              ..lineTo(34, 48)
              ..quadraticBezierTo(40, 62, 54, 68)
              ..lineTo(56, 64)
              ..quadraticBezierTo(60, 56, 68, 58)
              ..lineTo(80, 62)
              ..quadraticBezierTo(90, 66, 86, 78)
              ..lineTo(82, 86)
              ..quadraticBezierTo(76, 94, 60, 90)
              ..quadraticBezierTo(24, 78, 12, 40)
              ..quadraticBezierTo(8, 22, 22, 14)
              ..close(),
            obj);
        canvas.drawCircle(const Offset(70, 26), 5, obj);
        canvas.drawCircle(const Offset(82, 16), 4, obj);

      case IntentMark.spiralMark:
        canvas.drawPath(
            Path()
              ..moveTo(50, 50)
              ..cubicTo(62, 50, 62, 66, 50, 66)
              ..cubicTo(30, 66, 30, 36, 50, 36)
              ..cubicTo(78, 36, 78, 76, 50, 76)
              ..cubicTo(14, 76, 14, 24, 50, 24)
              ..cubicTo(86, 24, 90, 60, 80, 78),
            cutSeed(7));

      case IntentMark.windMark:
        for (final row in [(18.0, 30.0, 70.0), (18.0, 50.0, 84.0), (18.0, 70.0, 60.0)]) {
          canvas.drawPath(
              Path()
                ..moveTo(row.$1, row.$2)
                ..lineTo(row.$3, row.$2)
                ..quadraticBezierTo(row.$3 + 12, row.$2, row.$3 + 12, row.$2 - 8),
              cutSeed(7));
        }

      case IntentMark.sleepMark:
        canvas.drawPath(
            Path()
              ..addOval(Rect.fromCircle(center: const Offset(42, 54), radius: 30))
              ..addOval(Rect.fromCircle(center: const Offset(58, 44), radius: 26))
              ..fillType = PathFillType.evenOdd,
            obj);
        canvas.drawPath(
            Path()
              ..moveTo(64, 14)
              ..lineTo(84, 14)
              ..lineTo(64, 34)
              ..lineTo(84, 34),
            cutSeed(5));

      case IntentMark.noseMark:
        canvas.drawPath(
            Path()
              ..moveTo(44, 12)
              ..lineTo(44, 52)
              ..quadraticBezierTo(28, 60, 34, 72)
              ..quadraticBezierTo(44, 82, 58, 72)
              ..quadraticBezierTo(62, 60, 50, 56),
            cutSeed(8));
        for (final y in [30.0, 44.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(62, y)
                ..quadraticBezierTo(72, y - 8, 84, y),
              cutSeed(5));
        }

      case IntentMark.thermoMark:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(40, 8, 60, 66), const Radius.circular(10)), obj);
        canvas.drawCircle(const Offset(50, 76), 16, obj);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(46, 30, 54, 66), const Radius.circular(4)), white);
        canvas.drawCircle(const Offset(50, 76), 8, white);

      case IntentMark.toothMark:
        canvas.drawPath(
            Path()
              ..moveTo(28, 30)
              ..quadraticBezierTo(28, 8, 44, 12)
              ..quadraticBezierTo(50, 16, 56, 12)
              ..quadraticBezierTo(72, 8, 72, 30)
              ..quadraticBezierTo(74, 56, 66, 84)
              ..quadraticBezierTo(60, 96, 56, 70)
              ..quadraticBezierTo(50, 56, 44, 70)
              ..quadraticBezierTo(40, 96, 34, 84)
              ..quadraticBezierTo(26, 56, 28, 30)
              ..close(),
            obj);

      case IntentMark.swellMark:
        // A foot from the side, the ankle puffed: the sole, the heel, the
        // rounded top, and a ring of three short strokes above the ankle.
        canvas.drawPath(
            Path()
              ..moveTo(10, 78)
              ..lineTo(90, 78)
              ..quadraticBezierTo(90, 62, 70, 60)
              ..lineTo(56, 56)
              ..quadraticBezierTo(48, 30, 30, 30)
              ..quadraticBezierTo(12, 30, 12, 56)
              ..close(),
            obj);
        for (final x in [20.0, 30.0, 40.0]) {
          canvas.drawLine(Offset(x, 22), Offset(x + 4, 12), cutSeed(4));
        }

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
