// =============================================================================
//  Garbh Sanskar's four pillar marks (2026-10-02)
// -----------------------------------------------------------------------------
//  The daily screens drew an emoji for the practice (a raga's 🎵, a breath's 🌿,
//  a heart) in a tinted square. The app has stopped using emoji, so each pillar
//  has a drawn mark in the one family the rest of the app uses
//  (`TtcTabPainter`): a tinted disc, a deep ink, a soft ink, and the family's
//  line weights. They are also the marks the daily rows can wear later.
//
//      shravan  five bars of sound, a waveform she is listening to
//      samvad   a speech bubble with a heart in it: speaking to the baby
//      buddhi   a 2 by 2 of pieces with one still to place: a quiet puzzle
//      kriya    breath: three rings widening from a point
//
//  Decorative: the pillar's name is always beside them (`ExcludeSemantics`).
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ttc/doors/ttc_tab_art.dart'
    show TtcTabArt, TtcTabMark, TtcTabPainter, ttcTabGround, ttcTabInk;
import '../v2/v2_palette.dart' show V2PaletteStore, v2BlockTint;

/// The door's hue: every pillar screen sits on the Garbh Sanskar door's tint.
const double kGarbhHue = 42;

Widget garbhPillarMark(String pillarId, {double size = 52}) => ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: GarbhPillarMarkPainter(
            pillarId,
            v2BlockTint(kGarbhHue % 360, V2PaletteStore.instance.current),
          ),
        ),
      ),
    );

class GarbhPillarMarkPainter extends CustomPainter {
  GarbhPillarMarkPainter(this.id, this.tint);

  final String id;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    if (side <= 0) return;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);

    final groundC = ttcTabGround(tint);
    final inkC = ttcTabInk(tint);
    final ink = Paint()..color = inkC;
    final soft = Paint()..color = inkC.withValues(alpha: 0.32);
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final line = stroke(inkC, TtcTabPainter.kLine);
    final lineSoft = stroke(inkC.withValues(alpha: 0.32), TtcTabPainter.kLine);
    RRect rr(double l, double t, double r, double b, [double rad = 8]) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

    canvas.drawCircle(const Offset(50, 50), 46, Paint()..color = groundC);

    switch (id) {
      case 'shravan':
        // Five bars of sound, tallest in the middle.
        const heights = [22.0, 40.0, 58.0, 40.0, 22.0];
        for (var i = 0; i < 5; i++) {
          final x = 24.0 + i * 13.0;
          final h = heights[i];
          canvas.drawRRect(
              rr(x - 4, 50 - h / 2, x + 4, 50 + h / 2, 4), i == 2 ? ink : soft);
        }
        canvas.drawLine(const Offset(24, 82), const Offset(76, 82), lineSoft);

      case 'samvad':
        // A speech bubble with its tail, and a heart inside it.
        canvas.drawPath(
            Path()
              ..addRRect(rr(18, 20, 82, 66, 16))
              ..moveTo(34, 64)
              ..lineTo(30, 84)
              ..lineTo(52, 66)
              ..close(),
            ink);
        final heart = Path()
          ..moveTo(50, 56)
          ..cubicTo(32, 46, 38, 32, 46, 34)
          ..cubicTo(49, 35, 50, 38, 50, 38)
          ..cubicTo(50, 38, 51, 35, 54, 34)
          ..cubicTo(62, 32, 68, 46, 50, 56)
          ..close();
        canvas.drawPath(heart, Paint()..color = groundC);

      case 'buddhi':
        // Pieces in a 2 by 2, the last one still to place.
        canvas.drawRRect(rr(20, 20, 47, 47, 7), ink);
        canvas.drawRRect(rr(53, 20, 80, 47, 7), ink);
        canvas.drawRRect(rr(20, 53, 47, 80, 7), ink);
        canvas.drawRRect(rr(53, 53, 80, 80, 7), soft);
        canvas.drawRRect(
            rr(58, 58, 75, 75, 5), stroke(inkC.withValues(alpha: 0.55), TtcTabPainter.kDetail));

      case 'kriya':
      default:
        // Breath: a point and three rings widening from it.
        canvas.drawCircle(const Offset(50, 50), 7, ink);
        canvas.drawCircle(const Offset(50, 50), 17, line);
        canvas.drawCircle(const Offset(50, 50), 28, lineSoft);
        canvas.drawCircle(
            const Offset(50, 50), 38, stroke(inkC.withValues(alpha: 0.16), TtcTabPainter.kLine));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(GarbhPillarMarkPainter old) => old.id != id || old.tint != tint;
}

// =============================================================================
//  Buddhi and Kriya marks (2026-10-15, the Garbh pillars pass)
// -----------------------------------------------------------------------------
//  The user: "use the marks, the glyphs we are using instead of the icons. For
//  example, for word search, sudoku. And inside each and every game as well."
//  Two kinds, one painter:
//
//    * TILE marks (`disc: true`): a game or a breathing practice, on the
//      family's tinted disc, like every other mark in the app.
//        wordSearch  a letter grid with one word banded across it
//        sudoku      a 3 by 3 of boxes, the middle one filled with a numeral
//        logic       a picture made of filled squares (a heart), the nonogram
//        memory      two cards, one face down, one turned
//        hum         Bhramari: a head with sound arcs leaving it
//        wind        deep belly breath: three flowing lines
//        box         box breathing: a square path with a dot travelling it
//        leaf        a calm breath: one leaf
//    * KEY glyphs (`disc: false`): the verbs inside a game, drawn as plain ink
//      with no disc, because a disc on a 44px key reads as a sticker. Each key
//      also carries its word under it (the ease rule: a glyph never stands
//      alone where meaning matters).
//        pencil, hint, fill, cross, newGame, reload, next, play
//
//  Back, close and backspace stay Material: they are chrome verbs the whole
//  app draws that way (DESIGN-SYSTEM §3.4).
// =============================================================================

enum GarbhGameMark {
  wordSearch,
  sudoku,
  logic,
  memory,
  hum,
  wind,
  box,
  leaf,
  pencil,
  hint,
  fill,
  cross,
  newGame,
  reload,
  next,
  play,
}

/// The tile mark for a Buddhi game, by its English title (the dispatch key
/// `gameForPuzzle` already uses).
GarbhGameMark garbhGameMarkFor(String titleEn) => switch (titleEn) {
      'Sudoku' => GarbhGameMark.sudoku,
      'Logic Puzzle' => GarbhGameMark.logic,
      'Memory Match' => GarbhGameMark.memory,
      _ => GarbhGameMark.wordSearch,
    };

/// The tile mark for a Kriya practice, by its id; null where the shared
/// lotus (TtcTabMark.lotus) is the right picture.
GarbhGameMark? garbhPracticeMarkFor(String id) => switch (id) {
      'bhramari' => GarbhGameMark.hum,
      'deep_belly' => GarbhGameMark.wind,
      'box' => GarbhGameMark.box,
      'calm' => GarbhGameMark.leaf,
      _ => null,
    };

/// A Kriya practice's drawn mark: its own where one is drawn, else the
/// shared lotus, on the Garbh tint.
Widget garbhPracticeArt(String id, {double size = 44}) {
  final m = garbhPracticeMarkFor(id);
  if (m != null) return garbhGameMark(m, size: size);
  return ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size,
      child: TtcTabArt(
          mark: TtcTabMark.lotus,
          tint: v2BlockTint(kGarbhHue % 360, V2PaletteStore.instance.current)),
    ),
  );
}

/// A Shravan cover, small: a rounded square in the track's own tone with the
/// sound-bar mark. The list rows and the now-playing bar wear it, so a raga
/// looks the same wherever it appears. [hue] is the track's (see
/// `shravanHueFor`).
Widget shravanCoverThumb(double hue, {double size = 48, bool playing = false}) {
  final tint = v2BlockTint(hue % 360, V2PaletteStore.instance.current);
  return ExcludeSemantics(
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ttcTabGround(tint),
        borderRadius: BorderRadius.circular(size * 0.26),
        border: Border.all(
            color: playing ? ttcTabInk(tint) : Colors.transparent, width: 1.6),
      ),
      child: CustomPaint(painter: _BarsPainter(ttcTabInk(tint))),
    ),
  );
}

/// Each Shravan track's own tone, stable by id, all within the warm calm
/// range (no violet): the covers differ so the list is easy to scan.
double shravanHueFor(String id) {
  const hues = [42.0, 18.0, 150.0, 200.0, 335.0, 95.0, 25.0, 175.0, 55.0, 220.0];
  var h = 0;
  for (final c in id.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return hues[h % hues.length];
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.ink);
  final Color ink;
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    const heights = [0.24, 0.44, 0.62, 0.44, 0.24];
    final bar = w * 0.085;
    final gap = w * 0.13;
    final x0 = w / 2 - gap * 2;
    for (var i = 0; i < 5; i++) {
      final h = size.height * heights[i];
      final x = x0 + i * gap;
      canvas.drawRRect(
          RRect.fromLTRBR(x - bar / 2, size.height / 2 - h / 2, x + bar / 2,
              size.height / 2 + h / 2, Radius.circular(bar / 2)),
          Paint()..color = i == 2 ? ink : ink.withValues(alpha: 0.4));
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) => old.ink != ink;
}

/// A tile mark on the Garbh disc.
Widget garbhGameMark(GarbhGameMark mark, {double size = 44}) => ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: GarbhGameMarkPainter(
            mark,
            v2BlockTint(kGarbhHue % 360, V2PaletteStore.instance.current),
            disc: true,
          ),
        ),
      ),
    );

/// A key glyph: plain [color] shapes, no disc.
Widget garbhKeyGlyph(GarbhGameMark mark, {required Color color, double size = 22}) =>
    ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: GarbhGameMarkPainter(mark, color, disc: false),
        ),
      ),
    );

class GarbhGameMarkPainter extends CustomPainter {
  GarbhGameMarkPainter(this.mark, this.tint, {required this.disc});

  final GarbhGameMark mark;

  /// With [disc], the family tint; without, the glyph's own ink colour.
  final Color tint;
  final bool disc;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    if (side <= 0) return;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);

    final groundC = disc ? ttcTabGround(tint) : Colors.white;
    final inkC = disc ? ttcTabInk(tint) : tint;
    // A key glyph is drawn heavier: it is read at 22px, not 44.
    final w = disc ? TtcTabPainter.kLine : 9.0;
    final ink = Paint()..color = inkC;
    final soft = Paint()..color = inkC.withValues(alpha: disc ? 0.32 : 0.38);
    Paint stroke(Color c, double width) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final line = stroke(inkC, w);
    final lineSoft = stroke(inkC.withValues(alpha: 0.32), w);
    final knock = stroke(groundC, disc ? TtcTabPainter.kDetail : 7);
    RRect rr(double l, double t, double r, double b, [double rad = 8]) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

    if (disc) canvas.drawCircle(const Offset(50, 50), 46, Paint()..color = groundC);

    switch (mark) {
      // ---- Games -------------------------------------------------------------
      case GarbhGameMark.wordSearch:
        // A 4 by 4 of letter dots, one row banded: the word found.
        for (var r = 0; r < 4; r++) {
          for (var c = 0; c < 4; c++) {
            if (r == 2) continue;
            canvas.drawCircle(Offset(29 + c * 14.0, 29 + r * 14.0), 3.4, soft);
          }
        }
        canvas.drawRRect(rr(20, 50, 80, 64, 7), ink);
        for (var c = 0; c < 4; c++) {
          canvas.drawCircle(Offset(29 + c * 14.0, 57), 3.2, Paint()..color = groundC);
        }

      case GarbhGameMark.sudoku:
        // Nine boxes; the middle one filled, a numeral knocked out of it.
        for (var r = 0; r < 3; r++) {
          for (var c = 0; c < 3; c++) {
            final l = 22 + c * 19.0, t = 22 + r * 19.0;
            canvas.drawRRect(rr(l, t, l + 16, t + 16, 4), (r == 1 && c == 1) ? ink : soft);
          }
        }
        canvas.drawLine(const Offset(49, 45), const Offset(49, 55), knock);

      case GarbhGameMark.logic:
        // A heart built of squares: the picture a nonogram reveals.
        const cells = [
          [1, 0], [2, 0], [4, 0], [5, 0],
          [0, 1], [1, 1], [2, 1], [3, 1], [4, 1], [5, 1], [6, 1],
          [1, 2], [2, 2], [3, 2], [4, 2], [5, 2],
          [2, 3], [3, 3], [4, 3],
          [3, 4],
        ];
        for (final cell in cells) {
          final l = 22 + cell[0] * 8.2, t = 30 + cell[1] * 8.2;
          canvas.drawRRect(rr(l, t, l + 7, t + 7, 1.6), ink);
        }

      case GarbhGameMark.memory:
        // Two cards: one face down (soft), one turned with a heart on it.
        canvas.save();
        canvas.translate(38, 52);
        canvas.rotate(-0.16);
        canvas.drawRRect(rr(-16, -22, 16, 22, 6), soft);
        canvas.restore();
        canvas.save();
        canvas.translate(60, 50);
        canvas.rotate(0.12);
        canvas.drawRRect(rr(-16, -22, 16, 22, 6), ink);
        canvas.drawPath(_heartAt(0, 2, 16), Paint()..color = groundC);
        canvas.restore();

      // ---- Kriya practices -----------------------------------------------------
      case GarbhGameMark.hum:
        // A calm head, humming: sound arcs leave it.
        canvas.drawCircle(const Offset(38, 50), 18, ink);
        canvas.drawArc(Rect.fromCircle(center: const Offset(56, 50), radius: 12),
            -0.6, 1.2, false, line);
        canvas.drawArc(Rect.fromCircle(center: const Offset(56, 50), radius: 22),
            -0.6, 1.2, false, lineSoft);

      case GarbhGameMark.wind:
        // Three flowing lines: a long, slow breath.
        Path wave(double y, double from, double to) => Path()
          ..moveTo(from, y)
          ..cubicTo(from + 14, y - 10, to - 14, y + 10, to, y);
        canvas.drawPath(wave(36, 22, 70), line);
        canvas.drawPath(wave(52, 22, 78), line);
        canvas.drawPath(wave(68, 30, 70), lineSoft);

      case GarbhGameMark.box:
        // The square path of box breathing, a dot on its way round.
        canvas.drawRRect(rr(26, 26, 74, 74, 8), lineSoft);
        canvas.drawLine(const Offset(26, 74), const Offset(26, 26), line);
        canvas.drawLine(const Offset(26, 26), const Offset(58, 26), line);
        canvas.drawCircle(const Offset(66, 26), 7, ink);

      case GarbhGameMark.leaf:
        final leaf = Path()
          ..moveTo(28, 74)
          ..quadraticBezierTo(24, 30, 74, 24)
          ..quadraticBezierTo(76, 70, 28, 74)
          ..close();
        canvas.drawPath(leaf, ink);
        canvas.drawLine(const Offset(34, 68), const Offset(62, 38), knock);

      // ---- Key glyphs (no disc) --------------------------------------------------
      case GarbhGameMark.pencil:
        canvas.save();
        canvas.translate(50, 50);
        canvas.rotate(math.pi / 4);
        canvas.drawRRect(rr(-9, -36, 9, 18, 3), ink);
        canvas.drawPath(
            Path()
              ..moveTo(-9, 22)
              ..lineTo(9, 22)
              ..lineTo(0, 38)
              ..close(),
            ink);
        canvas.restore();

      case GarbhGameMark.hint:
        // A bulb: round glass, a small base.
        canvas.drawCircle(const Offset(50, 40), 24, line);
        canvas.drawLine(const Offset(40, 74), const Offset(60, 74), line);
        canvas.drawLine(const Offset(44, 86), const Offset(56, 86), line);

      case GarbhGameMark.fill:
        canvas.drawRRect(rr(22, 22, 78, 78, 10), ink);

      case GarbhGameMark.cross:
        canvas.drawLine(const Offset(26, 26), const Offset(74, 74), line);
        canvas.drawLine(const Offset(74, 26), const Offset(26, 74), line);

      case GarbhGameMark.newGame:
        // A fresh sheet with a plus.
        canvas.drawRRect(rr(22, 14, 78, 86, 10), line);
        canvas.drawLine(const Offset(50, 38), const Offset(50, 62), line);
        canvas.drawLine(const Offset(38, 50), const Offset(62, 50), line);

      case GarbhGameMark.reload:
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 52), radius: 28),
            -math.pi * 0.35, math.pi * 1.6, false, line);
        canvas.drawPath(
            Path()
              ..moveTo(60, 12)
              ..lineTo(80, 28)
              ..lineTo(56, 36)
              ..close(),
            ink);

      case GarbhGameMark.next:
        canvas.drawPath(
            Path()
              ..moveTo(24, 22)
              ..lineTo(62, 50)
              ..lineTo(24, 78)
              ..close(),
            ink);
        canvas.drawLine(const Offset(76, 24), const Offset(76, 76), line);

      case GarbhGameMark.play:
        canvas.drawPath(
            Path()
              ..moveTo(32, 20)
              ..lineTo(80, 50)
              ..lineTo(32, 80)
              ..close(),
            ink);
    }
    canvas.restore();
  }

  static Path _heartAt(double cx, double cy, double w) {
    final h = w * 0.9;
    return Path()
      ..moveTo(cx, cy + h / 2)
      ..cubicTo(cx - w, cy - h * 0.1, cx - w * 0.45, cy - h, cx, cy - h * 0.35)
      ..cubicTo(cx + w * 0.45, cy - h, cx + w, cy - h * 0.1, cx, cy + h / 2)
      ..close();
  }

  @override
  bool shouldRepaint(GarbhGameMarkPainter old) =>
      old.mark != mark || old.tint != tint || old.disc != disc;
}
