// =============================================================================
//  PvInsightRail — "My daily insights", the rail of cards under every hero
// -----------------------------------------------------------------------------
//  Lifted from `_InsightTile` / `_InsightMark` in ttc_home_v3.dart on
//  2026-09-21, when the pregnancy home took the TTC fold (docs/PREG-HOME-HERO-
//  PLAN.md). The TTC originals are commented out there, kept for revert; TTC's
//  `_InsightTile` is now a wrapper over `PvInsightTile`, and `TtcInsightArt`
//  is a typedef of `PvInsightArt`.
//
//  ⚠️ THE CARD IS SHARED; WHAT A DAY EARNS IS NOT. Each stage keeps its own
//  "which cards does this day get" file (ttc_daily_insights.dart,
//  preg_daily_insights.dart) and its own exhaustive switch on where a card
//  goes — that switch is the cheapest form of the wiring gate, and it belongs
//  next to the stage's screens, not here.
//
//  The tile's numbers are the TTC ones, measured off the reference: 100 x 112,
//  three fit on a 360dp phone with slack so the rail reads as a rail. The
//  notes on why they are what they are stayed with the TTC file; the short
//  version is that a card resized without its type resized is not a smaller
//  card, it is the same card clipping its own contents.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';

/// What the card draws as its texture, bottom right, behind the value.
///
/// ⚠️ DRAWN, NOT AN ICON FONT. An icon at this size reads as a button
/// affordance, and these are not buttons — they are the card's texture. Each
/// mark is a few strokes tuned to sit behind the eyebrow without competing.
enum PvInsightArt {
  level,
  number,
  symptom,
  droplet,
  note,
  balance,
  ring,
  log,
  meal,
  move,
  product,

  // Added for pregnancy, 2026-09-21.
  /// A curled figure — the baby this week.
  baby,

  /// A small disc beside a large one — the size of a …
  size,

  /// A fan of arcs — a scan.
  scan,

  /// A question mark — is it safe?
  question,
}

/// One card on the rail. A tinted block with the answer written on it.
///
/// No white half: the tints are already pale, so ink on one clears contrast,
/// and a seam across every card made a rail of small blocks read as sixteen
/// shapes instead of eight.
class PvInsightTile extends StatelessWidget {
  const PvInsightTile({
    super.key,
    required this.eyebrow,
    required this.value,
    required this.hue,
    required this.art,
    required this.p,
    required this.onTap,
    this.caption,
    this.artWidget,
  });

  static const double width = 100;
  static const double height = 112;

  /// The small line at the top — "SIZE OF A", "YOU LOGGED".
  final String eyebrow;

  /// The large answer — "a peach", "Nausea", "8".
  final String value;

  /// One optional line under the value.
  final String? caption;

  final double hue;
  final PvInsightArt art;

  /// A drawn mark to wear INSTEAD of [art] — the Symptoms door's own glyph on
  /// a "you logged" card (2026-09-22). It sits top-right, where the painted
  /// art cannot: the painted set is anchored bottom-right and a long value
  /// ("Constipation") ran straight through it.
  final Widget? artWidget;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // `% 360` is not defensive padding: `v2BlockTint` asserts hue <= 360 and a
    // hue is an angle, so wrapping it is the correct arithmetic.
    final tint = v2BlockTint(hue % 360, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.45)
        .withLightness(0.34)
        .toColor();

    return Semantics(
      button: true,
      label: '$eyebrow: $value',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            if (artWidget == null)
              Positioned.fill(
                child: CustomPaint(
                    painter: PvInsightMark(
                        art: art, ink: deep.withValues(alpha: 0.5))),
              )
            else
              Positioned(top: 8, right: 8, child: SizedBox(width: 22, height: 22, child: artWidget)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      // Room for the drawn mark in the corner.
                      padding: EdgeInsets.only(right: artWidget == null ? 0 : 24),
                      child: Text(eyebrow.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            height: 1.25,
                            color: deep)),
                    ),
                    const Spacer(),
                    Text(value,
                        maxLines: caption == null ? 4 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: pvJakarta(
                            fontSize: valueSize(value),
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: p.ink1)),
                    if (caption != null) ...[
                      const SizedBox(height: 3),
                      Text(caption!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 8.5,
                              height: 1.25,
                              color: p.ink2.withValues(alpha: 0.85))),
                    ],
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  /// The size follows the length: the same slot holds "8" and "Cut back on
  /// chai to two cups". Three steps, chosen at the lengths where the text
  /// stops fitting rather than at round numbers.
  static double valueSize(String v) {
    if (v.length <= 3) return 22;
    if (v.length <= 12) return 14;
    return 11;
  }
}

/// The rail: 112 tall, 18 in from each edge, 8 between cards.
///
/// ⚠️ A `SizedBox` around a rail must equal its tallest child. Reserve more and
/// the surplus lands on the section gap below as a hole; the TTC rail shipped
/// that bug once at 128 around a 104pt child.
///
/// ⚠️ IT PADS ITSELF, so the caller must NOT wrap it in the page gutter — the
/// rail runs edge to edge and the first card starts at the gutter. Double
/// padding is the "wall" Nutrition shipped and a test now guards on doors
/// (`kPvDoorSelfPaddedTools`); on the homes the rule is the same by hand.
class PvInsightRail extends StatelessWidget {
  const PvInsightRail({super.key, required this.tiles, this.gutter = 18});

  final List<PvInsightTile> tiles;
  final double gutter;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: PvInsightTile.height,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: gutter),
          itemCount: tiles.length,
          itemBuilder: (context, i) => Padding(
            padding: EdgeInsets.only(right: i == tiles.length - 1 ? 0 : 8),
            child: tiles[i],
          ),
        ),
      );
}

/// The drawn mark in a card's corner.
class PvInsightMark extends CustomPainter {
  const PvInsightMark({required this.art, required this.ink});

  final PvInsightArt art;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = ink.withValues(alpha: 0.32);

    // Anchored bottom-right, so the eyebrow at top-left never collides with it
    // regardless of how many lines the eyebrow takes.
    final cx = size.width - 22;
    final cy = size.height - 20;

    // Scaled about its own centre, not redrawn at new numbers: the geometry
    // was tuned inside a 158 x 168 card; a single transform about the anchor
    // keeps the drawing and its position independent of the card's size.
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(0.72);
    canvas.translate(-cx, -cy);

    switch (art) {
      case PvInsightArt.level:
        for (var i = 0; i < 3; i++) {
          final h = 9.0 + i * 8;
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(cx - 12 + i * 11, cy + 6 - h, 7, h),
                  const Radius.circular(3)),
              fill);
        }
      case PvInsightArt.number:
      case PvInsightArt.ring:
        canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: 15),
            -1.9, 4.9, false, stroke);
        canvas.drawCircle(Offset(cx + 13, cy - 8), 3.2, fill);
      case PvInsightArt.symptom:
        final path = Path()..moveTo(cx - 20, cy);
        path.lineTo(cx - 8, cy);
        path.lineTo(cx - 3, cy - 13);
        path.lineTo(cx + 3, cy + 8);
        path.lineTo(cx + 8, cy);
        path.lineTo(cx + 20, cy);
        canvas.drawPath(path, stroke);
      case PvInsightArt.droplet:
        final path = Path()
          ..moveTo(cx, cy - 17)
          ..quadraticBezierTo(cx + 14, cy - 1, cx, cy + 13)
          ..quadraticBezierTo(cx - 14, cy - 1, cx, cy - 17)
          ..close();
        canvas.drawPath(path, fill);
      case PvInsightArt.note:
        for (var i = 0; i < 4; i++) {
          canvas.drawLine(Offset(cx - 18, cy - 12 + i * 8),
              Offset(cx + 18 - i * 7, cy - 12 + i * 8), stroke);
        }
      case PvInsightArt.balance:
        canvas.drawLine(
            Offset(cx - 19, cy - 8), Offset(cx + 19, cy - 8), stroke);
        canvas.drawLine(Offset(cx, cy - 8), Offset(cx, cy + 12), stroke);
        canvas.drawCircle(Offset(cx - 14, cy + 2), 5, fill);
        canvas.drawCircle(Offset(cx + 14, cy + 2), 5, fill);
      case PvInsightArt.log:
        canvas.drawCircle(Offset(cx, cy), 15, stroke);
        canvas.drawLine(Offset(cx - 7, cy), Offset(cx + 7, cy), stroke);
        canvas.drawLine(Offset(cx, cy - 7), Offset(cx, cy + 7), stroke);
      case PvInsightArt.meal:
        canvas.drawArc(
            Rect.fromCircle(center: Offset(cx, cy - 2), radius: 16),
            0.15, 2.85, false, stroke);
        canvas.drawLine(
            Offset(cx - 18, cy - 2), Offset(cx + 18, cy - 2), stroke);
        canvas.drawCircle(Offset(cx, cy - 12), 3.5, fill);
      case PvInsightArt.move:
        canvas.drawCircle(Offset(cx + 2, cy - 16), 4.5, fill);
        canvas.drawLine(
            Offset(cx + 2, cy - 11), Offset(cx - 2, cy + 1), stroke);
        canvas.drawLine(
            Offset(cx - 2, cy + 1), Offset(cx - 11, cy + 11), stroke);
        canvas.drawLine(
            Offset(cx - 2, cy + 1), Offset(cx + 9, cy + 11), stroke);
      case PvInsightArt.product:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(cx - 15, cy - 12, 30, 26),
                const Radius.circular(5)),
            fill);
        canvas.drawLine(
            Offset(cx - 15, cy - 4), Offset(cx + 15, cy - 4), stroke);
      case PvInsightArt.baby:
        // A head and a curled body: one disc, one arc closing under it.
        canvas.drawCircle(Offset(cx + 6, cy - 12), 6.5, fill);
        final body = Path()
          ..moveTo(cx + 10, cy - 4)
          ..quadraticBezierTo(cx + 14, cy + 12, cx - 2, cy + 13)
          ..quadraticBezierTo(cx - 18, cy + 12, cx - 14, cy - 2)
          ..quadraticBezierTo(cx - 12, cy - 10, cx - 2, cy - 6);
        canvas.drawPath(body, stroke);
      case PvInsightArt.size:
        // The small one and the big one, side by side.
        canvas.drawCircle(Offset(cx - 13, cy + 5), 5, fill);
        canvas.drawCircle(Offset(cx + 7, cy - 1), 14, stroke);
      case PvInsightArt.scan:
        // A fan of three arcs from one point — the probe's sweep.
        for (var i = 1; i <= 3; i++) {
          canvas.drawArc(
              Rect.fromCircle(center: Offset(cx, cy + 12), radius: 7.0 * i),
              -2.45, 1.75, false, stroke);
        }
        canvas.drawCircle(Offset(cx, cy + 12), 2.5, fill);
      case PvInsightArt.question:
        final q = Path()
          ..moveTo(cx - 9, cy - 8)
          ..quadraticBezierTo(cx - 9, cy - 18, cx, cy - 18)
          ..quadraticBezierTo(cx + 10, cy - 18, cx + 9, cy - 8)
          ..quadraticBezierTo(cx + 8, cy - 2, cx, cy)
          ..lineTo(cx, cy + 5);
        canvas.drawPath(q, stroke);
        canvas.drawCircle(Offset(cx, cy + 13), 2.4, fill);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PvInsightMark old) => old.art != art || old.ink != ink;
}
