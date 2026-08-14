// =============================================================================
//  V2BlockArt — the six door marks, drawn rather than generated
// -----------------------------------------------------------------------------
//  WHY VECTORS INSTEAD OF THE RENDERED OBJECTS.
//
//  The generated set kept failing in ways no re-prompt fixed. Two of the six
//  came back as several objects in one picture (two paper stacks, three play
//  cards) because the prompt asked for variations. All six came back cream,
//  because the prompt never specified colour. And all six landed in the soft-
//  clay 3D style that every image model produces right now — which is the same
//  problem as the purple gradient: not ugly, just unmistakably machine-made.
//
//  Drawing them solves all three at once and adds things generation cannot:
//
//    · ONE HAND. Same geometry, same stroke, same corner treatment, always.
//    · PALETTE-AWARE. They take their ink from the ground they sit on, so all
//      five palettes stay coherent without six more exports each.
//    · WEIGHTLESS. No PNGs, no 668KB, no double-padding, nothing to re-crop.
//
//  THE TRADE, STATED HONESTLY: these are flatter and more graphic than the
//  render objects. Less tactile. Whether that is better is a taste question the
//  phone answers faster than an argument, which is why both sets exist behind a
//  toggle rather than one replacing the other.
//
//  Drawing rules, so a seventh mark added later still belongs:
//    · One stroke weight, scaled from the tile.
//    · Round caps and joins everywhere — the wordmark is soft, so this is too.
//    · No fills except where an object is genuinely solid.
//    · Everything inside a 100x100 space, scaled by the painter.
// =============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum V2Mark { practice, week, scan, read, watch, ask }

class V2BlockArt extends StatelessWidget {
  const V2BlockArt({super.key, required this.mark, required this.color});

  final V2Mark mark;

  /// Taken from the tile's own ink, not from the accent. These are objects on a
  /// ground, not actions — a violet one would read as a button.
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _MarkPainter(mark, color), size: Size.infinite);
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.mark, this.color);
  final V2Mark mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final s = side / 100; // everything below is authored in a 100x100 box
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.16);
    final solid = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    switch (mark) {
      // Cloth: two long folds. Practice is the calm one, so it is the only
      // mark with no straight line in it.
      case V2Mark.practice:
        final p = Path()
          ..moveTo(20 * s, 62 * s)
          ..cubicTo(34 * s, 30 * s, 48 * s, 74 * s, 62 * s, 42 * s)
          ..cubicTo(70 * s, 24 * s, 78 * s, 34 * s, 82 * s, 44 * s);
        canvas.drawPath(p, stroke);
        final q = Path()
          ..moveTo(24 * s, 76 * s)
          ..cubicTo(38 * s, 48 * s, 52 * s, 88 * s, 66 * s, 58 * s);
        canvas.drawPath(q, stroke..color = color.withValues(alpha: 0.45));
        stroke.color = color;

      // Seed pod: a leaf with a seam. Growth, and about to open.
      case V2Mark.week:
        final pod = Path()
          ..moveTo(50 * s, 18 * s)
          ..cubicTo(80 * s, 34 * s, 80 * s, 66 * s, 50 * s, 82 * s)
          ..cubicTo(20 * s, 66 * s, 20 * s, 34 * s, 50 * s, 18 * s)
          ..close();
        canvas.drawPath(pod, fill);
        canvas.drawPath(pod, stroke);
        canvas.drawLine(Offset(50 * s, 26 * s), Offset(50 * s, 74 * s), stroke);

      // Ultrasound strip: three frames on a tape. The only mark with hard
      // corners, because it is the only clinical one — see the tint note in
      // v2_palette.dart, where Scans is also the only cool tile.
      case V2Mark.scan:
        for (var i = 0; i < 3; i++) {
          final r = RRect.fromRectAndRadius(
            Rect.fromLTWH(32 * s, (20 + i * 22) * s, 36 * s, 17 * s),
            Radius.circular(2.5 * s),
          );
          canvas.drawRRect(r, i == 1 ? fill : Paint()..color = Colors.transparent);
          canvas.drawRRect(r, stroke);
        }
        canvas.drawLine(Offset(26 * s, 16 * s), Offset(26 * s, 84 * s),
            stroke..color = color.withValues(alpha: 0.4));
        stroke.color = color;

      // Paper: a stack with the top sheet lifting.
      case V2Mark.read:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(24 * s, 46 * s, 52 * s, 30 * s),
              Radius.circular(4 * s)),
          stroke,
        );
        canvas.drawLine(Offset(28 * s, 66 * s), Offset(72 * s, 66 * s),
            stroke..color = color.withValues(alpha: 0.4));
        stroke.color = color;
        final lift = Path()
          ..moveTo(30 * s, 44 * s)
          ..cubicTo(42 * s, 22 * s, 58 * s, 22 * s, 70 * s, 44 * s);
        canvas.drawPath(lift, stroke);

      // Play: a frame and a triangle. The one mark that must be instantly
      // legible, so it is the most literal.
      case V2Mark.watch:
        final r = RRect.fromRectAndRadius(
            Rect.fromLTWH(20 * s, 28 * s, 60 * s, 44 * s),
            Radius.circular(7 * s));
        canvas.drawRRect(r, fill);
        canvas.drawRRect(r, stroke);
        final tri = Path()
          ..moveTo(44 * s, 40 * s)
          ..lineTo(62 * s, 50 * s)
          ..lineTo(44 * s, 60 * s)
          ..close();
        canvas.drawPath(tri, solid);

      // Two pebbles, one behind the other — a conversation, not a question
      // mark and not a speech bubble.
      case V2Mark.ask:
        final back = Path()
          ..addOval(Rect.fromLTWH(44 * s, 26 * s, 38 * s, 34 * s));
        canvas.drawPath(back, fill);
        canvas.drawPath(back, stroke..color = color.withValues(alpha: 0.5));
        stroke.color = color;
        final front = Path()
          ..addOval(Rect.fromLTWH(20 * s, 42 * s, 42 * s, 36 * s));
        canvas.drawPath(front, fill);
        canvas.drawPath(front, stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.mark != mark || old.color != color;
}

/// Which set of door marks the grid draws.
///
/// PERSISTED, unlike the palette bar, and the difference is deliberate.
///
/// The palette bar resets each launch so nobody opens the app days later in an
/// experimental ground and reports its colours as the product's. That argument
/// does not transfer here: this control only exists INSIDE V3, which is already
/// a screen you have to opt into, so there is no state to protect anyone from.
/// Not persisting it just meant a choice was thrown away every relaunch —
/// which reads as the toggle not working at all.
class V2BlockArtMode extends ChangeNotifier {
  V2BlockArtMode._() {
    _load();
  }
  static final V2BlockArtMode instance = V2BlockArtMode._();

  static const _key = 'v3_block_art_vector';

  bool _vector = false;
  bool get vector => _vector;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_key);
    if (v != null && v != _vector) {
      _vector = v;
      notifyListeners();
    }
  }

  Future<void> set(bool v) async {
    if (v == _vector) return;
    _vector = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, v);
  }
}
