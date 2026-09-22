// =============================================================================
//  PvLearnArt — the drawn marks of Learn
// -----------------------------------------------------------------------------
//  An eighth family, in the language of the other seven (DESIGN-SYSTEM §3.1,
//  DoctorArt's header states it best): one filled focal shape in the mark's
//  own hue at 92%, detail knocked out in WHITE, every tone derived from the
//  tint, one idea per mark, no halo, ONE PATH where shapes would overlap.
//  Authored for a 40dp ring and legible at 32.
//
//  ⚠️ WHY A FAMILY AND NOT ICONS. The learn screens shipped with Material
//  glyphs in the trust rows and the notes — `verified_outlined`,
//  `replay_rounded`, `groups_outlined` — and the user caught it on the walk
//  (2026-09-22): *"I don't need icons, use marks/glyphs that we have — you
//  have missed it a lot."* Every other area of this app draws its own: the
//  doors, the brackets, the skilling grid, ParentVeda+. A borrowed glyph is
//  the one thing on a page that was not made for it.
//
//  ⚠️ WHAT A MARK MAY NEVER SHOW (§3.3) holds here: no score, no gauge, no
//  medal, no certificate. "Reviewed" is a tick in a seal, not a rosette with
//  a ribbon; "refund" is a coin turning back, not a badge.
// =============================================================================

import 'package:flutter/material.dart';

import '../v2/v2_palette.dart' show V2Palette, v2BlockTint;

enum PvLearnMark {
  /// A clinician or a course checked before it is listed.
  reviewed,

  /// The money rule: it comes back.
  refund,

  /// Yours to keep — a recording, a course, for good.
  keep,

  /// A recording is included.
  recording,

  /// Live, in the app — a small group, faces.
  group,

  /// Never a diagnosis from us: a hand held open, not a cross.
  notOurs,

  /// A rhythm: book each one when it suits.
  calendar,

  /// A quiet note under a list — the safety line.
  note,

  /// Nothing booked yet: an open book with a play.
  learn,

  /// What it costs: a note, seen straight on.
  money,
}

/// The hue each mark takes. By meaning, not by prettiness.
double pvLearnMarkHue(PvLearnMark m) => switch (m) {
  PvLearnMark.reviewed => 268, // violet — ours, the one brand tone
  PvLearnMark.refund => 26, // peach — money as warmth
  PvLearnMark.keep => 42, // sand — a thing on a shelf
  PvLearnMark.recording => 206, // blue-grey — a screen
  PvLearnMark.group => 344, // dusty rose — people
  PvLearnMark.notOurs => 104, // sage — a boundary held calmly
  PvLearnMark.calendar => 104,
  PvLearnMark.note => 206,
  PvLearnMark.learn => 268,
  PvLearnMark.money => 42, // sand, as `keep` — money is a thing, not a mood
};

/// The seed the detail is painted in: the tint, taken darker. Same
/// derivation as the doctor family so the two read as one hand.
Color pvLearnMarkSeed(Color tint) {
  final h = HSLColor.fromColor(tint);
  return HSLColor.fromAHSL(
    1,
    h.hue,
    (h.saturation + 0.18).clamp(0, 1),
    0.42,
  ).toColor();
}

/// The explanatory placement: the mark on a white disc inside a hairline
/// ring. A trust row explains; it does not act, so it takes the ring
/// rather than the tinted well.
class PvLearnRing extends StatelessWidget {
  const PvLearnRing({
    super.key,
    required this.mark,
    required this.p,
    this.size = 40,
  });
  final PvLearnMark mark;
  final V2Palette p;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(pvLearnMarkHue(mark), p);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.surface,
        border: Border.all(color: p.line, width: 1.4),
      ),
      padding: EdgeInsets.all(size * 0.24),
      child: CustomPaint(
        painter: _PvLearnPainter(mark, pvLearnMarkSeed(tint)),
        size: Size.infinite,
      ),
    );
  }
}

/// The acting placement: the mark on its own pastel, radius 14.
class PvLearnMarkTile extends StatelessWidget {
  const PvLearnMarkTile({
    super.key,
    required this.mark,
    required this.p,
    this.size = 44,
    this.radius = 14,
  });
  final PvLearnMark mark;
  final V2Palette p;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(pvLearnMarkHue(mark), p);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: EdgeInsets.all(size * 0.22),
      child: CustomPaint(
        painter: _PvLearnPainter(mark, pvLearnMarkSeed(tint)),
        size: Size.infinite,
      ),
    );
  }
}

class _PvLearnPainter extends CustomPainter {
  _PvLearnPainter(this.mark, this.seed);
  final PvLearnMark mark;
  final Color seed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final obj = Paint()
      ..color = seed
      ..isAntiAlias = true;
    final white = Paint()
      ..color = Colors.white
      ..isAntiAlias = true;
    Paint cut(double w) => Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    switch (mark) {
      // ---- REVIEWED: a tick cut out of a seal. ------------------------------
      case PvLearnMark.reviewed:
        final seal = Path();
        for (var i = 0; i < 12; i++) {
          final a = i * 3.14159 / 6;
          final r = i.isEven ? 42.0 : 36.0;
          final x = 50 + r * _cos(a);
          final y = 50 + r * _sin(a);
          if (i == 0) {
            seal.moveTo(x, y);
          } else {
            seal.lineTo(x, y);
          }
        }
        seal.close();
        canvas.drawPath(seal, obj);
        canvas.drawPath(
          Path()
            ..moveTo(32, 51)
            ..lineTo(45, 64)
            ..lineTo(69, 38),
          cut(10),
        );

      // ---- MONEY: a banknote, straight on, with the value knocked out. -----
      case PvLearnMark.money:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(10, 28, 90, 74),
            const Radius.circular(8),
          ),
          obj,
        );
        canvas.drawCircle(const Offset(50, 51), 13, white);
        canvas.drawLine(const Offset(19, 38), const Offset(19, 64), cut(5));
        canvas.drawLine(const Offset(81, 38), const Offset(81, 64), cut(5));

      // ---- REFUND: a coin, and the arrow that turns it back. ----------------
      case PvLearnMark.refund:
        canvas.drawCircle(const Offset(50, 54), 34, obj);
        canvas.drawArc(
          const Rect.fromLTRB(28, 32, 72, 76),
          -0.5,
          4.2,
          false,
          cut(9),
        );
        canvas.drawPath(
          Path()
            ..moveTo(30, 28)
            ..lineTo(32, 48)
            ..lineTo(50, 40)
            ..close(),
          white,
        );

      // ---- KEEP: a card with a corner turned down for good. -----------------
      case PvLearnMark.keep:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(18, 14, 82, 86),
            const Radius.circular(12),
          ),
          obj,
        );
        canvas.drawPath(
          Path()
            ..moveTo(36, 14)
            ..lineTo(64, 14)
            ..lineTo(64, 56)
            ..lineTo(50, 45)
            ..lineTo(36, 56)
            ..close(),
          white,
        );

      // ---- RECORDING: a frame, a play wedge, and the disc that keeps it. ----
      case PvLearnMark.recording:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(10, 22, 90, 72),
            const Radius.circular(12),
          ),
          obj,
        );
        canvas.drawPath(
          Path()
            ..moveTo(42, 34)
            ..lineTo(64, 47)
            ..lineTo(42, 60)
            ..close(),
          white,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(34, 78, 66, 88),
            const Radius.circular(5),
          ),
          obj,
        );

      // ---- GROUP: three, one path, the middle one forward. ------------------
      case PvLearnMark.group:
        canvas.drawPath(
          Path()
            ..addOval(Rect.fromCircle(center: const Offset(24, 40), radius: 11))
            ..addRRect(
              RRect.fromRectAndRadius(
                const Rect.fromLTRB(8, 56, 40, 86),
                const Radius.circular(13),
              ),
            )
            ..addOval(Rect.fromCircle(center: const Offset(76, 40), radius: 11))
            ..addRRect(
              RRect.fromRectAndRadius(
                const Rect.fromLTRB(60, 56, 92, 86),
                const Radius.circular(13),
              ),
            ),
          obj,
        );
        canvas.drawPath(
          Path()
            ..addOval(Rect.fromCircle(center: const Offset(50, 32), radius: 15))
            ..addRRect(
              RRect.fromRectAndRadius(
                const Rect.fromLTRB(28, 52, 72, 90),
                const Radius.circular(17),
              ),
            ),
          obj,
        );
        canvas.drawCircle(const Offset(50, 32), 15, cut(5));
        canvas.drawLine(const Offset(28, 60), const Offset(28, 86), cut(5));
        canvas.drawLine(const Offset(72, 60), const Offset(72, 86), cut(5));

      // ---- NOT OURS: an open hand, the boundary held without a wall. --------
      case PvLearnMark.notOurs:
        canvas.drawPath(
          Path()
            ..moveTo(24, 92)
            ..lineTo(24, 52)
            ..quadraticBezierTo(24, 40, 34, 40)
            ..lineTo(34, 22)
            ..quadraticBezierTo(34, 12, 43, 12)
            ..quadraticBezierTo(52, 12, 52, 22)
            ..lineTo(52, 40)
            ..lineTo(66, 40)
            ..quadraticBezierTo(78, 40, 78, 54)
            ..lineTo(78, 92)
            ..close(),
          obj,
        );
        canvas.drawLine(const Offset(43, 52), const Offset(43, 74), cut(6));
        canvas.drawLine(const Offset(60, 56), const Offset(60, 74), cut(6));

      // ---- CALENDAR: the page, and one day taken. ---------------------------
      case PvLearnMark.calendar:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(12, 22, 88, 88),
            const Radius.circular(12),
          ),
          obj,
        );
        canvas.drawRect(const Rect.fromLTRB(12, 38, 88, 42), white);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(28, 54, 46, 70),
            const Radius.circular(4),
          ),
          white,
        );
        canvas.drawLine(const Offset(30, 12), const Offset(30, 28), cut(8));
        canvas.drawLine(const Offset(70, 12), const Offset(70, 28), cut(8));

      // ---- NOTE: a slip with two lines. -------------------------------------
      case PvLearnMark.note:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(16, 18, 84, 82),
            const Radius.circular(12),
          ),
          obj,
        );
        canvas.drawRect(const Rect.fromLTRB(30, 38, 70, 45), white);
        canvas.drawRect(const Rect.fromLTRB(30, 55, 56, 62), white);

      // ---- LEARN: a book, open, with a play in the gutter. ------------------
      case PvLearnMark.learn:
        canvas.drawPath(
          Path()
            ..moveTo(10, 26)
            ..quadraticBezierTo(30, 18, 50, 30)
            ..lineTo(50, 84)
            ..quadraticBezierTo(30, 72, 10, 80)
            ..close(),
          obj,
        );
        canvas.drawPath(
          Path()
            ..moveTo(90, 26)
            ..quadraticBezierTo(70, 18, 50, 30)
            ..lineTo(50, 84)
            ..quadraticBezierTo(70, 72, 90, 80)
            ..close(),
          obj,
        );
        canvas.drawPath(
          Path()
            ..moveTo(26, 44)
            ..lineTo(40, 52)
            ..lineTo(26, 60)
            ..close(),
          white,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _PvLearnPainter old) =>
      old.mark != mark || old.seed != seed;
}

double _cos(double a) => _table(a, true);
double _sin(double a) => _table(a, false);

/// The twelve points of the seal, without importing dart:math for two calls.
double _table(double a, bool isCos) {
  const twoPi = 6.28318530718;
  var x = a % twoPi;
  if (isCos) x += twoPi / 4;
  // A five-term Taylor sine, plenty for a 100-unit canvas.
  if (x > twoPi / 2) x -= twoPi;
  if (x < -twoPi / 2) x += twoPi;
  final x2 = x * x;
  return x * (1 - x2 / 6 * (1 - x2 / 20 * (1 - x2 / 42)));
}
