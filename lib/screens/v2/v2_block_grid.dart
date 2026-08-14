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

  final VoidCallback? onTap;
}

class V2BlockGrid extends StatelessWidget {
  const V2BlockGrid({super.key, required this.blocks, required this.palette});

  final List<V2Block> blocks;
  final V2Palette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const gap = 10.0;
      final tile = (c.maxWidth - gap * 2) / 3;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final b in blocks)
            SizedBox(width: tile, child: _Tile(block: b, palette: palette)),
        ],
      );
    });
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.block, required this.palette});

  final V2Block block;
  final V2Palette palette;

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
                  color: block.tint,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                // The object fills the tile rather than sitting in the middle
                // of it. `contain` with a small inset, not `cover`: these are
                // isolated subjects and cropping one costs its silhouette,
                // which at this size is the only thing telling them apart.
                child: Padding(
                  padding: EdgeInsets.all(
                      V2BlockArtMode.instance.vector ? 14 : 6),
                  child: V2BlockArtMode.instance.vector && block.mark != null
                      ? V2BlockArt(
                          mark: block.mark!,
                          color: palette.ink1.withValues(alpha: 0.72))
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
            const SizedBox(height: 7),
            Text(
              block.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
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
                  fontSize: 11,
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
}
