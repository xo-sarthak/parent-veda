// =============================================================================
//  V2BlockGrid — the hero of the Focus experiment
// -----------------------------------------------------------------------------
//  Six tiles, three across, two down. The shape is FIXED and would be identical
//  in TTC and parenting; only the contents change. That is the whole point —
//  habit forms on where a thing is, not on what it is called this month.
//
//  PERSONALISED, NOT A MENU. Each tile answers "what should I do today",
//  not "what exists in this app". A fixed menu of sections would orient her and
//  give her no reason to stay; this leads with today's practice, this week's
//  size, the scan that is coming.
//
//  WHY SIX AND NOT NINE. At 360dp, three columns leaves ~110dp per tile —
//  enough for art and one readable label. Nine tiles pushes every existing card
//  below the fold and squeezes the labels. Six is the honest maximum.
//
//  WHY DESTINATIONS COME FROM app_structure.dart. Same reason the "also" row
//  does it: a surface renamed there is renamed here, and this screen cannot
//  invent a destination the structure does not know about.
//
//  ART. `asset` when there is real art, `icon` until there is. The image is
//  composited onto the palette's own ground, never carrying its own background
//  — which is why the generated art is transparent PNG and why none of it is
//  invalidated by the palette decision. See docs/IMAGE-PROMPTS.md.
// =============================================================================

import 'package:flutter/material.dart';

import 'v2_block_art.dart';
import 'v3_bracket_art.dart';
import 'v3_skill_art.dart';
import 'v2_palette.dart';

@immutable
class V2Block {
  const V2Block({
    required this.label,
    required this.icon,
    required this.tint,
    this.meta,
    this.asset,
    this.mark,
    this.bracketMark,
    this.skillMark,
    this.onTap,
  });

  /// THE GROUND THE OBJECT SITS ON, and the single change that made this grid
  /// stop looking unfinished.
  ///
  /// The first cut put every object on a white card and it read as six
  /// placeholder frames: the art floated in the middle with air all round it,
  /// and because five of the six objects are cream, the tiles were also
  /// indistinguishable from each other.
  ///
  /// A filled tint fixes both at once. It composites the object instead of
  /// parking it, and it gives each tile an identity the eye can use — which is
  /// the entire point of a grid you are meant to scan rather than read.
  ///
  /// Hues differ; saturation and lightness do not. That is the controlled-
  /// pastel rule from docs/DESIGN-LAYER.md §4a, and it is why six different
  /// colours still read as one system.
  final Color tint;

  /// What it is, in her words. Two words where possible — at 110dp a third
  /// wraps and the grid stops being scannable.
  final String label;

  /// Placeholder until the generated art lands.
  final IconData icon;

  /// The personalisation, and the only number allowed on a tile: "Week 30",
  /// "In 3 days", "4 min". Never a count of anything that accrues.
  final String? meta;

  /// Transparent PNG, composited on the palette ground.
  final String? asset;

  /// The drawn alternative to [asset]. When art mode is set to vector this is
  /// used instead — see v2_block_art.dart for why both sets exist.
  final V2Mark? mark;

  /// A BRACKET's mark, which wins over both of the above when present.
  ///
  /// Separate from [mark] rather than folded into it because the two sets are
  /// authored for different sizes — 110dp doors versus 73dp brackets — and
  /// sharing one enum would invite someone to use a door mark on a bracket tile,
  /// where its interior detail turns to mush. See v3_bracket_art.dart.
  final BracketMark? bracketMark;

  /// A SKILLING bracket's mark. Wins over all of the above.
  ///
  /// ⚠️ A THIRD SLOT RATHER THAN MORE CASES IN `BracketMark`, for the same
  /// reason `bracketMark` is separate from `mark`: the sets are authored
  /// independently and no stage reads more than one of them. Folding skilling's
  /// twelve into the bracket enum would make a 29-case switch that every
  /// painter has to handle exhaustively, to serve four stages that each use a
  /// disjoint third of it.
  final SkillMark? skillMark;

  final VoidCallback? onTap;
}

class V2BlockGrid extends StatelessWidget {
  const V2BlockGrid({
    super.key,
    required this.blocks,
    required this.palette,
    this.columns = 3,
  });

  final List<V2Block> blocks;
  final V2Palette palette;

  /// THREE FOR THE OLD SIX DOORS, FOUR FOR THE BRACKETS.
  ///
  /// The file header argues for six tiles at three columns, and that reasoning
  /// was right for a hand-picked menu of six. The brackets are not that: they
  /// are the workbook's full L1 column, and every stage has to fit — 7 for
  /// preconception, 10 for pregnancy, 11 for after birth, 12 for skilling.
  ///
  /// Four columns × three rows is twelve slots, which covers the largest stage
  /// exactly. So no stage ever needs a "See more", and nothing is ever one tap
  /// further away than anything else — which matters more here than tile size,
  /// because a bracket she cannot see is a bracket she does not know exists.
  ///
  /// The cost is real and was accepted: at 360dp a four-column tile is ~73dp
  /// against ~110dp, so labels had to shorten and the marks were redrawn for
  /// the smaller size rather than scaled down into mush.
  final int columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final gap = columns >= 4 ? 8.0 : 10.0;
      final tile = (c.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final b in blocks)
            SizedBox(
                width: tile,
                child: _Tile(block: b, palette: palette, tile: tile)),
        ],
      );
    });
  }
}

class _Tile extends StatelessWidget {
  const _Tile(
      {required this.block, required this.palette, required this.tile});

  final V2Block block;
  final V2Palette palette;

  /// The tile's own width, so type can step down when four columns squeeze it.
  /// The alternative — one size for both grids — either wastes the three-column
  /// tile or overflows the four-column one, and the four-column labels are the
  /// ones with the least room to spare.
  final double tile;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: block.meta == null
          ? block.label
          : '${block.label}, ${block.meta}',
      child: InkWell(
        onTap: block.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- the art well -------------------------------------------------
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  // ---- A GRADIENT WELL, NOT A FLAT SWATCH -----------------
                  //
                  // The land band is gone from the marks (see v2_block_art),
                  // and something had to replace what it was doing — which was
                  // never "be a landscape", it was "give the object somewhere
                  // to sit so it is not floating on a flat colour". A vertical
                  // gradient does that without drawing a horizon: lighter at
                  // the top, deeper at the foot, so the tile reads as a space
                  // with air in it rather than as a rectangle of paint.
                  //
                  // The two ends are the SAME hue, ±6% lightness. Anything
                  // wider becomes a visible gradient, and a visible gradient is
                  // the slop tell DESIGN-LAYER bans. This one should be felt
                  // and not seen.
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _shift(block.tint, 0.055),
                      _shift(block.tint, -0.055),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                // The object fills the tile rather than sitting in the middle
                // of it. `contain` with a small inset, not `cover`: these are
                // isolated subjects and cropping one costs its silhouette,
                // which at this size is the only thing telling them apart.
                child: Padding(
                  // A SMALL INSET IS BACK on the drawn set — 10, not the old
                  // 14 and not 0. It went to 0 when the marks had a ground band
                  // that was meant to reach the bottom corners; without the
                  // band there is nothing that needs to touch an edge, and an
                  // object running to the corners of its own well reads as
                  // cropped rather than as large.
                  padding: EdgeInsets.all(
                      block.bracketMark != null || block.skillMark != null
                          ? 8
                          : V2BlockArtMode.instance.vector
                              ? 10
                              : 6),
                  child: block.skillMark != null
                      ? V3SkillArt(mark: block.skillMark!, tint: block.tint)
                      : block.bracketMark != null
                      ? V3BracketArt(
                          mark: block.bracketMark!, tint: block.tint)
                      : V2BlockArtMode.instance.vector && block.mark != null
                      ? V2BlockArt(
                          mark: block.mark!,
                          // The tile's own pastel, not a grey. See the note on
                          // V2BlockArt.tint for why the first restyle failed.
                          tint: block.tint,
                          ink: palette.ink1)
                      : block.asset != null
                          ? Image.asset(block.asset!,
                              fit: BoxFit.contain,
                              // A missing asset must not take the screen down
                              // with it.
                              errorBuilder: (_, _, _) => _icon())
                          : _icon(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 14 and 12, up from 12.5 and 11. iOS's base size is 17 and macOS's
            // is 13 — type gets LARGER on the smaller screen, not smaller. The
            // instinct that produced 12.5 here was "the screen shrank, so
            // squeeze", and it is backwards. See the note in v3_sections.dart.
            Text(
              block.label,
              // TWO LINES ON THE TIGHT GRID. "Garbh Sanskar" and "Yoga &
              // fitness" do not fit 73dp on one line, and ellipsising a door's
              // name is worse than wrapping it — "Garbh Sansk…" is not a label,
              // it is a truncation she has to decode.
              maxLines: tile < 90 ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: tile < 90 ? 12.5 : 14,
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: palette.ink1,
              ),
            ),
            if (block.meta != null) ...[
              const SizedBox(height: 2),
              Text(
                block.meta!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: tile < 90 ? 11 : 12,
                  height: 1.15,
                  color: palette.ink3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _icon() => Center(
        child: Icon(block.icon, size: 30, color: palette.ink1.withValues(alpha: 0.55)),
      );

  /// Nudge a colour's lightness without touching its hue or saturation.
  ///
  /// HSL rather than `Color.lerp` towards white/black on purpose: lerping to
  /// white desaturates as it lightens, so the top of the gradient would drift
  /// grey and the two ends would no longer be the same colour. Lightness alone
  /// keeps the hue identical, which is what makes the gradient read as depth
  /// rather than as two colours meeting.
  static Color _shift(Color c, double byLightness) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + byLightness).clamp(0.0, 1.0)).toColor();
  }
}
