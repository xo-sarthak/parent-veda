// =============================================================================
//  DoctorArt — the drawn marks of ParentVeda+
// -----------------------------------------------------------------------------
//  A seventh family (DESIGN-SYSTEM §3.1), in the language of the other six:
//  one filled focal shape in the tile's own hue at 92%, detail knocked out in
//  WHITE, every tone derived from the tint, one idea per mark, no halo, ONE
//  PATH where shapes would overlap. Authored for a 52dp tile (the Home quick
//  actions) and legible at 40 (rows, the set-up rail). Not a scale factor of
//  anything else: at 40 a clock has two hands and no numerals.
//
//  WHY A FAMILY AND NOT ICONS. The first doctor build put a Material icon in
//  a grey square everywhere — "icons everywhere … very bland" (the user,
//  2026-09-21) — and Mobbin's apps that feel made rather than assembled
//  (GoHenry, Deel's Hub, Alan, Evernote's two big tiles) put a drawn two-tone
//  mark in a tinted tile instead. The parent app already does this on every
//  door; the doctor app is the same product and should be drawn with the
//  same hand.
//
//  WHAT A MARK MAY NEVER SHOW (§3.3) holds here too: no score, no gauge, no
//  medal. Earnings is a note and a coin — money as an object, not a chart.
//
//  Hues are assigned by MEANING off the controlled wheel (v2_palette's
//  V2BlockHues): time is sage, writing is sand, the code is violet, money is
//  peach, the bank is the one cool blue-grey, the person is rose.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../v2/v2_palette.dart' show v2BlockTint, V2Palette;

enum DoctorMark { hours, prescribe, qr, earnings, bank, photo, classes, inbox, video, referral, calendar, done, cancelled, noShow, leave, plus, download, upload }

/// The hue each mark's tile takes. By meaning, not by prettiness.
double doctorMarkHue(DoctorMark m) => switch (m) {
      DoctorMark.hours => 104, // sage — time, ritual
      DoctorMark.calendar => 104,
      DoctorMark.prescribe => 42, // sand — writing
      DoctorMark.qr => 268, // soft violet — the code, tying to the brand
      DoctorMark.referral => 268,
      DoctorMark.earnings => 26, // peach — money as warmth, not a chart
      DoctorMark.bank => 206, // blue-grey — the one cool tile: the institution
      DoctorMark.inbox => 206,
      DoctorMark.photo => 344, // dusty rose — the person
      DoctorMark.classes => 26,
      DoctorMark.video => 344,
      DoctorMark.done => 104,
      // 2026-09-21, the sweep: the last icons in wells.
      DoctorMark.cancelled => 344, // rose — a day that will not happen
      DoctorMark.noShow => 42, // sand — the slot held, unpaid attention
      DoctorMark.leave => 206, // blue-grey — the door out is quiet
      DoctorMark.plus => 268, // violet — the brand's own cross
      DoctorMark.download => 206,
      DoctorMark.upload => 206,
    };

/// The second placement (2026-09-21, the user: "a bit of differentiation"):
/// the same mark on a white disc inside a hairline ring — the parent app's
/// need ticks. The tinted well means "you can act on this"; the ring means
/// "this is how it works". Explanatory rows take the ring; anything that
/// opens, sends or saves keeps the well. The mark is painted in the hue's
/// seed as on the tile, so the two placements read as one hand.
class DoctorArtRing extends StatelessWidget {
  const DoctorArtRing({super.key, required this.mark, required this.p, this.size = 44});
  final DoctorMark mark;
  final V2Palette p;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(doctorMarkHue(mark), p);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.surface,
        border: Border.all(color: p.line, width: 1.4),
      ),
      padding: EdgeInsets.all(size * 0.22),
      child: CustomPaint(painter: _DoctorPainter(mark, doctorMarkSeed(tint)), size: Size.infinite),
    );
  }
}

/// The tile: the mark on its own pastel, radius 16. [size] is the tile side.
class DoctorArtTile extends StatelessWidget {
  const DoctorArtTile({super.key, required this.mark, required this.p, this.size = 52, this.radius = 16, this.muted = false});
  final DoctorMark mark;
  final V2Palette p;
  final double size;
  final double radius;
  /// A done step: the tile goes to the neutral surface and the mark to grey.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final tint = muted ? p.surfaceAlt : v2BlockTint(doctorMarkHue(mark), p);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(radius)),
      padding: EdgeInsets.all(size * 0.2),
      child: CustomPaint(painter: _DoctorPainter(mark, muted ? p.ink3 : doctorMarkSeed(tint)), size: Size.infinite),
    );
  }
}

/// Public so a preview harness derives the same colour the widget does.
Color doctorMarkSeed(Color tint) => HSLColor.fromColor(tint).withSaturation(0.46).withLightness(0.46).toColor();

/// Draws straight onto a canvas, for the offline rasterise-and-look check.
void paintDoctorMark(Canvas canvas, DoctorMark mark, Color tint, double size) =>
    _DoctorPainter(mark, doctorMarkSeed(tint)).paint(canvas, Size(size, size));

class _DoctorPainter extends CustomPainter {
  _DoctorPainter(this.mark, this.seed);
  final DoctorMark mark;
  final Color seed;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final s = side / 100;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(s);

    final obj = Paint()..color = seed.withValues(alpha: 0.92);
    final white = Paint()..color = Colors.white.withValues(alpha: 0.92);
    Paint stroke(double w, {Color? c}) => Paint()
      ..color = c ?? seed.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Paint cut(double w) => stroke(w, c: Colors.white.withValues(alpha: 0.92));

    switch (mark) {
      // ---- HOURS: a clock. One disc, two hands cut in white. -----------------
      case DoctorMark.hours:
        canvas.drawCircle(const Offset(50, 50), 40, obj);
        canvas.drawPath(Path()..moveTo(50, 50)..lineTo(50, 24), cut(9));
        canvas.drawPath(Path()..moveTo(50, 50)..lineTo(68, 60), cut(9));

      // ---- CALENDAR: a page with a white band and one marked day. ------------
      case DoctorMark.calendar:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(14, 20, 86, 86), const Radius.circular(12)), obj);
        canvas.drawRect(const Rect.fromLTRB(14, 34, 86, 42), white);
        canvas.drawCircle(const Offset(62, 64), 9, white);

      // ---- PRESCRIBE: a note with a pen laid across it. One path. ------------
      case DoctorMark.prescribe:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(16, 12, 74, 88), const Radius.circular(10)), obj);
        canvas.drawPath(Path()..moveTo(28, 34)..lineTo(58, 34), cut(7));
        canvas.drawPath(Path()..moveTo(28, 50)..lineTo(52, 50), cut(7));
        canvas.drawPath(Path()..moveTo(28, 66)..lineTo(44, 66), cut(7));
        // the pen: a rounded bar from lower-right, with a white nib line
        canvas.save();
        canvas.translate(74, 62);
        canvas.rotate(-math.pi / 4);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(-9, -30, 9, 22), const Radius.circular(9)), obj);
        canvas.drawRect(const Rect.fromLTRB(-9, 10, 9, 14), white);
        canvas.restore();

      // ---- QR: a rounded square with the three finder eyes cut in white. -----
      case DoctorMark.qr:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(12, 12, 88, 88), const Radius.circular(14)), obj);
        for (final o in const [Offset(31, 31), Offset(69, 31), Offset(31, 69)]) {
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: o, width: 22, height: 22), const Radius.circular(5)), white);
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: o, width: 10, height: 10), const Radius.circular(2)), obj);
        }
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(69, 69), width: 10, height: 10), const Radius.circular(2)), white);

      // ---- EARNINGS: a coin over a note. Money as an object, never a chart. --
      case DoctorMark.earnings:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(10, 30, 78, 76), const Radius.circular(10)), obj);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(20, 40, 68, 66), const Radius.circular(6)), white);
        canvas.drawCircle(const Offset(72, 42), 18, white);
        canvas.drawCircle(const Offset(72, 42), 13, obj);
        canvas.drawCircle(const Offset(72, 42), 5, white);

      // ---- BANK: a portico. One block, columns and a step cut in white. ------
      case DoctorMark.bank:
        canvas.drawPath(
            Path()
              ..moveTo(50, 10)
              ..lineTo(90, 32)
              ..lineTo(90, 88)
              ..lineTo(10, 88)
              ..lineTo(10, 32)
              ..close(),
            obj);
        canvas.drawRect(const Rect.fromLTRB(10, 36, 90, 42), white);
        for (final x in const [24.0, 44.0, 64.0]) {
          canvas.drawRect(Rect.fromLTRB(x, 48, x + 12, 76), white);
        }
        canvas.drawRect(const Rect.fromLTRB(10, 80, 90, 84), white);

      // ---- PHOTO: a portrait. Head and shoulders cut out of a rounded frame. -
      case DoctorMark.photo:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(12, 12, 88, 88), const Radius.circular(18)), obj);
        canvas.drawCircle(const Offset(50, 42), 14, white);
        canvas.drawPath(
            Path()
              ..moveTo(26, 88)
              ..cubicTo(28, 62, 72, 62, 74, 88)
              ..close(),
            white);

      // ---- CLASSES: a screen with three seats before it. ----------------------
      case DoctorMark.classes:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(12, 14, 88, 58), const Radius.circular(10)), obj);
        canvas.drawRect(const Rect.fromLTRB(22, 26, 66, 32), white);
        canvas.drawRect(const Rect.fromLTRB(22, 40, 50, 46), white);
        for (final x in const [24.0, 50.0, 76.0]) {
          canvas.drawCircle(Offset(x, 78), 9, obj);
        }

      // ---- INBOX: a tray with a slot. ------------------------------------------
      case DoctorMark.inbox:
        canvas.drawPath(
            Path()
              ..moveTo(12, 56)
              ..lineTo(24, 22)
              ..lineTo(76, 22)
              ..lineTo(88, 56)
              ..lineTo(88, 84)
              ..lineTo(12, 84)
              ..close(),
            obj);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(30, 56, 70, 66), const Radius.circular(5)), white);

      // ---- VIDEO: a rounded frame with a play wedge cut in white. -------------
      case DoctorMark.video:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(10, 20, 90, 80), const Radius.circular(14)), obj);
        canvas.drawPath(
            Path()
              ..moveTo(42, 36)
              ..lineTo(66, 50)
              ..lineTo(42, 64)
              ..close(),
            white);

      // ---- REFERRAL: two figures, one path, the second a step behind. ---------
      case DoctorMark.referral:
        canvas.drawPath(
            Path()
              ..addOval(Rect.fromCircle(center: const Offset(38, 32), radius: 14))
              ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(16, 50, 60, 88), const Radius.circular(16)))
              ..addOval(Rect.fromCircle(center: const Offset(70, 40), radius: 11))
              ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(54, 56, 88, 88), const Radius.circular(14))),
            obj);

      // ---- DONE: a tick cut out of a disc. -------------------------------------
      case DoctorMark.done:
        canvas.drawCircle(const Offset(50, 50), 40, obj);
        canvas.drawPath(Path()..moveTo(30, 52)..lineTo(44, 66)..lineTo(70, 36), cut(10));

      // ---- CANCELLED: the calendar page with a cross where the day was. --------
      case DoctorMark.cancelled:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(14, 20, 86, 86), const Radius.circular(12)), obj);
        canvas.drawRect(const Rect.fromLTRB(14, 34, 86, 42), white);
        canvas.drawPath(Path()..moveTo(40, 54)..lineTo(60, 74), cut(8));
        canvas.drawPath(Path()..moveTo(60, 54)..lineTo(40, 74), cut(8));

      // ---- NO-SHOW: a chair seen from the front, empty. -----------------------
      case DoctorMark.noShow:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(26, 14, 74, 54), const Radius.circular(10)), obj);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(18, 52, 82, 66), const Radius.circular(6)), obj);
        canvas.drawRect(const Rect.fromLTRB(24, 66, 32, 88), obj);
        canvas.drawRect(const Rect.fromLTRB(68, 66, 76, 88), obj);
        canvas.drawRect(const Rect.fromLTRB(34, 26, 66, 44), white);

      // ---- LEAVE: a door, ajar, with its handle cut in white. -----------------
      case DoctorMark.leave:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(22, 10, 78, 90), const Radius.circular(8)), obj);
        canvas.drawRect(const Rect.fromLTRB(60, 10, 78, 90), white);
        canvas.drawCircle(const Offset(50, 52), 5, white);

      // ---- PLUS: the brand's cross, on a disc. ParentVeda+. -------------------
      case DoctorMark.plus:
        canvas.drawCircle(const Offset(50, 50), 40, obj);
        canvas.drawPath(Path()..moveTo(50, 28)..lineTo(50, 72), cut(11));
        canvas.drawPath(Path()..moveTo(28, 50)..lineTo(72, 50), cut(11));

      // ---- DOWNLOAD: a tray with an arrow coming down into it. ----------------
      case DoctorMark.download:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(12, 60, 88, 88), const Radius.circular(10)), obj);
        canvas.drawPath(Path()..moveTo(50, 12)..lineTo(50, 58), stroke(11));
        canvas.drawPath(Path()..moveTo(32, 42)..lineTo(50, 60)..lineTo(68, 42), stroke(11));
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(30, 70, 70, 78), const Radius.circular(4)), white);

      // ---- UPLOAD: the same tray, the arrow leaving it. -----------------------
      case DoctorMark.upload:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(12, 60, 88, 88), const Radius.circular(10)), obj);
        canvas.drawPath(Path()..moveTo(50, 58)..lineTo(50, 12), stroke(11));
        canvas.drawPath(Path()..moveTo(32, 30)..lineTo(50, 12)..lineTo(68, 30), stroke(11));
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(30, 70, 70, 78), const Radius.circular(4)), white);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DoctorPainter old) => old.mark != mark || old.seed != seed;
}

/// The mark for a task id (doctor_tasks.dart), so rows, the rail and the
/// Inbox draw the same picture for the same thing.
DoctorMark doctorMarkForTask(String id) => switch (id) {
      'class_open' => DoctorMark.classes,
      'call_soon' => DoctorMark.video,
      'rx_owed' => DoctorMark.prescribe,
      'paused' => DoctorMark.hours,
      'account_rejected' => DoctorMark.bank,
      'setup_hours' => DoctorMark.hours,
      'setup_account' => DoctorMark.bank,
      'setup_qr' => DoctorMark.qr,
      'setup_photo' => DoctorMark.photo,
      _ => DoctorMark.inbox,
    };
