// =============================================================================
//  The article-foot tile and rail: ONE widget for every "Read next" (2026-10-01)
// -----------------------------------------------------------------------------
//  The reader drew its Read next cards with a private builder, so every other
//  screen that wanted "two reads to open next" drew its own row (the ovulation
//  tests page had a bordered text row). The user: they should "be like the way
//  we have at the bottom of each article reader". So the tile and the rail now
//  live here, the reader calls them, and so does any screen that offers reads
//  at its foot. The tile is the "What you can do with this" family: a tinted
//  block, the read's own picture with a scrim when it has one, a chip, a
//  serif title and the teaser.
//
//  The code is the reader's, lifted whole: `_PvPvReaderScreenState._tile` and
//  `_readNextRail` now call these.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_solution_cards.dart';
import '../v2/v2_palette.dart';

/// One tile: [type] sets the tint, the mark and the chip; [title] and [value]
/// are the words; [imageUrl] puts the read's own picture behind them.
class PvReadTile extends StatelessWidget {
  const PvReadTile({
    super.key,
    required this.type,
    required this.title,
    required this.lang,
    required this.onTap,
    this.value,
    this.imageUrl,
    this.chip,
    this.icon,
  });

  final SolutionType type;
  final String title;
  final String? value;
  final String? imageUrl;
  final String? chip;
  final IconData? icon;
  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // A local, so the null check below promotes (a field cannot).
    final imageUrl = this.imageUrl;
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(type.hue % 360, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();
    final photo = imageUrl != null && imageUrl.isNotEmpty;

    return PvPress(
        child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 172,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          // ⚠️ THE MARK IS THE PICTURE, cropped by the block's own edge rather
          // than sitting in a well of its own. Same device as the focus rail:
          // it fills the space an illustration will eventually take, at an
          // alpha low enough that the title never has to fight it. Where the
          // piece HAS a picture, the picture fills the block and a scrim
          // rises under the type — the door rail's own treatment.
          if (photo)
            Positioned.fill(
              child: Image.network(imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink()),
            )
          else
            Positioned(
              right: -22,
              bottom: -14,
              child: Icon(icon ?? type.icon,
                  size: 108, color: Colors.white.withValues(alpha: 0.42)),
            ),
          if (photo)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.86),
                    ],
                    stops: const [0.30, 0.72],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon ?? type.icon, size: 10, color: deep),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(chip ?? type.chip(lang),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: deep)),
                      ),
                    ]),
                  ),
                  const Spacer(),
                  Text(title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.22,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                  // ⚠️ AT LARGE TEXT THE TEASER STEPS ASIDE (2026-10-01): the tile
                  // is a fixed 172pt block, and at 1.5x the three-line title,
                  // the chip and a two-line teaser were 9pt too tall (found
                  // on the ovulation page by test/ttc_tool_marks_test.dart).
                  // The title is the part that must stay whole.
                  if (value case final v?
                      when MediaQuery.textScalerOf(context).scale(10) <= 12.5) ...[
                    const SizedBox(height: 5),
                    Text(v,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 10.5,
                            height: 1.32,
                            color: p.ink2.withValues(alpha: 0.9))),
                  ],
                ]),
          ),
        ]),
      ),
    ));
  }
}

/// The rail at the foot of a read: a horizontal list, two tiles visible.
/// [items] are (id, title, teaser, picture); an item the caller could not
/// resolve is simply not passed in, so nothing draws an empty card.
class PvReadNextRail extends StatelessWidget {
  const PvReadNextRail({
    super.key,
    required this.items,
    required this.lang,
    required this.onOpen,
    this.sidePad = 22,
  });

  final List<(String, LocalizedText, LocalizedText?, String?)> items;
  final AppLanguage lang;
  final void Function(String id) onOpen;

  /// 22 in the reader; a tool screen with its own gutter passes its own.
  final double sidePad;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: sidePad),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final (id, title, teaser, image) = items[i];
          final width =
              (MediaQuery.of(context).size.width - sidePad * 2 - 10) / 2;
          return SizedBox(
            width: width,
            child: PvReadTile(
              type: SolutionType.read,
              title: title.of(lang),
              value: teaser?.of(lang),
              imageUrl: image,
              lang: lang,
              onTap: () => onOpen(id),
            ),
          );
        },
      ),
    );
  }
}
