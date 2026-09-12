// =============================================================================
//  PvFigureHighlight — a schematic figure with attention on one part
// -----------------------------------------------------------------------------
//  TTC's body-scan practice drew this first (`_FigurePainter` in
//  `ttc_practice_player.dart`): a head, a spine, arms, legs, and a soft disc
//  at a fraction of the height. Kriya's guided relaxation needs the same
//  thing — the current body part lit as the script moves down — and the
//  pillars brief says *"reuse the figure-highlight animation from SHARED"*.
//  So it moved here, and TTC draws through it.
//
//  ⚠️ A POSITION INDICATOR, NOT AN ANATOMY DRAWING. Deliberately schematic.
//  Both briefs draw the same line: *"do not attempt to generate the figure
//  artwork."* The commissioned figure, when it exists, is a Rive or Lottie
//  file; [asset] is where its path goes, and this painter is the placeholder
//  that stands until then. Today no player package is in the app, because a
//  dependency for a file nobody has drawn is a dependency for nothing; when
//  the file lands, the player is added here and every caller gets it.
// =============================================================================

import 'package:flutter/material.dart';

class PvFigureHighlight extends StatelessWidget {
  const PvFigureHighlight({
    super.key,
    required this.highlight,
    required this.accent,
    required this.line,
    this.asset,
    this.width = 210,
    this.height = 150,
  });

  /// 0 at the head, 1 at the feet.
  final double highlight;
  final Color accent;
  final Color line;

  /// Path of a Rive/Lottie figure, from data. Null today; see the header.
  final String? asset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: PvFigurePainter(
              highlight: highlight, accent: accent, line: line),
        ),
      );
}

class PvFigurePainter extends CustomPainter {
  const PvFigurePainter(
      {required this.highlight, required this.accent, required this.line});
  final double highlight;
  final Color accent;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = line;

    final cx = size.width / 2;
    const top = 14.0;
    final bottom = size.height - 10;

    // head, spine, arms, legs — deliberately schematic.
    canvas.drawCircle(Offset(cx, top + 10), 10, stroke);
    canvas.drawLine(Offset(cx, top + 22), Offset(cx, bottom - 34), stroke);
    canvas.drawLine(
        Offset(cx - 26, top + 40), Offset(cx + 26, top + 40), stroke);
    canvas.drawLine(Offset(cx, bottom - 34), Offset(cx - 18, bottom), stroke);
    canvas.drawLine(Offset(cx, bottom - 34), Offset(cx + 18, bottom), stroke);

    final y = top + (bottom - top) * highlight.clamp(0.0, 1.0);
    canvas.drawCircle(
        Offset(cx, y), 17, Paint()..color = accent.withValues(alpha: 0.20));
  }

  @override
  bool shouldRepaint(PvFigurePainter old) =>
      old.highlight != highlight || old.accent != accent || old.line != line;
}
