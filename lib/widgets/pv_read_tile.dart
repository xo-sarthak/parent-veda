// =============================================================================
//  PvReadTile — an article as a tile, two to a row
// -----------------------------------------------------------------------------
//  ⚠️ WHY A TILE AND NOT THE FULL-WIDTH ROW WE ALREADY HAD.
//
//  `PvReadPlaceholder` is a horizontal row: a 76dp cover on the left, title and
//  subtitle on the right, one per line. Four of them is four full-width bands
//  down a page, and on the PCOS journey the effect was that finding the one
//  article she wanted meant scrolling past three she did not — the reviewer's
//  words were "the user has to scroll till the very bottom to see what they
//  want".
//
//  Two columns halves the vertical distance, and more importantly it turns a
//  LIST into a GRID: a list is read in order, a grid is scanned. Someone
//  arriving with a specific question is scanning, not reading.
//
//  The row is not deleted and is not wrong — it is right where an article sits
//  among other KINDS of thing (a tool, a consult), because a grid of mixed
//  types is a jumble. Tiles are for a run of articles and nothing else.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE COVER IS DRAWN, AND IT IS DRAWN AS TEXT
//  ---------------------------------------------------------------------------
//
//  No photograph, and deliberately no gradient — the brief was "no gimmicky
//  gradients", and a stock photo of a woman looking wistfully out of a window
//  is worse than no photograph at all on a page about a diagnosis.
//
//  So the cover is ruled lines: an abstract of a page of text, in the bracket's
//  own tint. It is honest (it depicts what is behind it), it is ours, it needs
//  no network, it cannot 404, and it varies per article without anyone
//  commissioning anything — the line pattern is derived from the title, so two
//  tiles side by side never look identical and the same article always looks
//  the same.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../screens/v2/v2_palette.dart';
import '../theme/pv_fonts.dart';

class PvReadTile extends StatelessWidget {
  const PvReadTile({
    super.key,
    required this.title,
    required this.minutes,
    this.kicker,
    this.hue = 42,
    this.seed = 0,
    this.onTap,
  });

  final String title;

  /// "9 MIN READ". Null hides the line rather than printing an empty one.
  final String? minutes;

  /// The small label above the title — which bracket, or which kind of piece.
  final String? kicker;

  final double hue;

  /// Varies the drawn cover. Pass something stable per article — its title's
  /// hash, its index — never a random, or the cover changes on every rebuild.
  final int seed;

  /// Null means not built yet: the tile renders a shade back with a quiet
  /// "coming soon" and does NOT accept a tap.
  ///
  /// ⚠️ Same rule as every placeholder in this app. Something that looks
  /// tappable and does nothing teaches her that taps do nothing, everywhere.
  final VoidCallback? onTap;

  bool get _live => onTap != null;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(hue, p);
    final ink = HSLColor.fromColor(tint)
        .withSaturation(0.34)
        .withLightness(0.46)
        .toColor();

    return Semantics(
      label: _live ? title : 'Article coming soon: $title',
      child: Opacity(
        // A shade back, not greyed out — it is a real thing that is not here
        // yet, not a disabled control.
        opacity: _live ? 1 : 0.72,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- THE COVER ------------------------------------------------
              // 4:3 rather than square. A square cover plus three lines of
              // title makes a tile taller than it is wide by a long way, and
              // two of those fill a phone screen with two articles.
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CustomPaint(
                    painter: _RuledCoverPainter(
                        tint: tint, ink: ink, seed: seed),
                    child: _live
                        ? null
                        : Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(9),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: p.surface.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('SOON',
                                    style: pvManrope(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.9,
                                        color: p.ink3)),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (kicker != null) ...[
                Text(kicker!.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: ink)),
                const SizedBox(height: 5),
              ],
              Text(title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: pvFraunces(
                      fontSize: 15.5,
                      height: 1.28,
                      fontWeight: FontWeight.w600,
                      color: p.ink1)),
              if (minutes != null) ...[
                const SizedBox(height: 6),
                Text(minutes!,
                    style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: p.ink3)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Ruled lines, as an abstract of a page of text.
///
/// ⚠️ DETERMINISTIC FROM [seed], never random. `Random()` with no seed would
/// redraw a different cover on every rebuild — including mid-scroll — which
/// reads as a glitch rather than as variety.
class _RuledCoverPainter extends CustomPainter {
  const _RuledCoverPainter(
      {required this.tint, required this.ink, required this.seed});

  final Color tint;
  final Color ink;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = tint);

    final rnd = math.Random(seed);
    final line = Paint()..color = ink.withValues(alpha: 0.30);

    // A heading block, then body lines — the shape of an article, at a glance.
    final left = size.width * 0.14;
    final maxRight = size.width * 0.86;
    final usable = maxRight - left;

    double y = size.height * 0.22;
    final headH = size.height * 0.055;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(left, y, usable * 0.68, headH),
          Radius.circular(headH / 2)),
      Paint()..color = ink.withValues(alpha: 0.52),
    );

    y += headH + size.height * 0.11;
    final bodyH = size.height * 0.032;
    final gap = size.height * 0.075;

    for (var i = 0; i < 4; i++) {
      // Last line of a paragraph runs short, the way a real one does.
      final isLast = i == 3;
      final w = usable * (isLast ? 0.34 + rnd.nextDouble() * 0.18 : 0.80 + rnd.nextDouble() * 0.20);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(left, y, math.min(w, usable), bodyH),
            Radius.circular(bodyH / 2)),
        line,
      );
      y += gap;
      if (y > size.height * 0.92) break;
    }
  }

  @override
  bool shouldRepaint(covariant _RuledCoverPainter old) =>
      old.tint != tint || old.ink != ink || old.seed != seed;
}
