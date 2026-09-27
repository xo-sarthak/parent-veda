// =============================================================================
//  PvListRow · PvRowGroup · PvMarkWell: one unboxed row, for every list
// -----------------------------------------------------------------------------
//  Lifted out 2026-09-26 from the TTC review (reviewer MR, findings L1, T2,
//  S1). The same object, a read or a tool or a need, was drawn three ways in
//  one stage: unboxed inside the doors (`_ArticleList`), inside a white
//  rounded box on Learn, inside a radius-26 box on Tools, and inside a third
//  box on the store's shop-by-need. DESIGN-SYSTEM §4.13 "Lists are not boxed"
//  (2026-09-21) already said which one is right: rows on the page gutter with
//  a hairline between them and one above and below, never a bordered,
//  rounded container with its own inset.
//
//  So this file is that row, once:
//
//    PvRowGroup   a hairline above, one between each row, one below. No fill,
//                 no radius, no border of its own. The caller's gutter is the
//                 row's edge.
//    PvListRow    leading well (56 for a read, 40 for a tool), the title in
//                 Manrope 15/700, one grey line, an optional small meta, and
//                 a chevron. PvPress on it (§4.0c: a press scales, never
//                 dims). The haptic stays with the caller, which already
//                 knows whether the tap commits anything.
//    PvMarkWell   the well: the item's photo when it has one, else a drawn
//                 mark (IntentMark or the door's BracketMark) in the group's
//                 tint, else a line icon in the tint's ink. Never a
//                 broken-image glyph, and never a Material glyph where a drawn
//                 mark exists ("bye bye to the generic icons", the user,
//                 2026-09-21).
//
//  Mobbin: Flo "What causes irregular cycles" (FLO-LIST,
//  https://mobbin.com/screens/3bb65ebc-bb08-4479-b449-3df67ac53fd3), articles
//  as unboxed rows with a thumbnail, a bold title and one grey line; Apple
//  Health Search (AH-SEARCH,
//  https://mobbin.com/screens/cd8919aa-c470-48b8-8716-54343395eab2), category
//  colour on each glyph; Fresha search
//  (https://mobbin.com/screens/86a0b800-40fe-4cbe-a1b6-1355f84bd38d), tinted
//  icon wells on unboxed rows under headings.
//
//  Consumers: `ttc_learn_screen.dart`, `ttc_tools_screen.dart` and the TTC
//  shop-by-need in `pv_store_screen.dart`. The TTC and pregnancy doors keep
//  their own `_ArticleList`, which this row matches line for line.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart';

/// Rows on the page, a hairline above, between and below. No box.
class PvRowGroup extends StatelessWidget {
  const PvRowGroup({super.key, required this.p, required this.children});

  final V2Palette p;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const ValueKey('pv_row_group'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: p.line),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Divider(height: 1, thickness: 1, color: p.line),
          children[i],
        ],
        Divider(height: 1, thickness: 1, color: p.line),
      ],
    );
  }
}

/// One row: well, title, one grey line, an optional meta, a chevron.
class PvListRow extends StatelessWidget {
  const PvListRow({
    super.key,
    required this.p,
    required this.leading,
    required this.title,
    required this.onTap,
    this.line,
    this.meta,
    this.trailing,
    this.lineMaxLines = 1,
  });

  final V2Palette p;
  final Widget leading;
  final String title;
  final String? line;

  /// A small fact under the line ("6 min read", "3 days logged").
  final String? meta;

  /// Replaces the chevron (a bookmark on a saved read). The chevron is the
  /// default because in a list row the chevron IS the explicit action.
  final Widget? trailing;
  final VoidCallback onTap;
  final int lineMaxLines;

  @override
  Widget build(BuildContext context) {
    return PvPress(
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          // 44pt is the floor for any tap target; a row with no line still
          // clears it.
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: p.ink1,
                        ),
                      ),
                      if (line != null && line!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          line!,
                          maxLines: lineMaxLines,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                            fontSize: 12.5,
                            height: 1.4,
                            color: p.ink2,
                          ),
                        ),
                      ],
                      if (meta != null && meta!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          meta!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: p.ink3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing ??
                    Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The ink a line icon takes inside a tint well: the tint's own hue, darker.
Color pvWellInk(Color tint) => HSLColor.fromColor(tint)
    .withSaturation(0.46)
    .withLightness(0.40)
    .toColor();

/// The row's well. Photo first, then a drawn mark, then a line icon, in that
/// order, all in the group's tint. Exactly one of [mark], [bracket] or [icon]
/// is expected; a photo that fails falls back to whichever was given.
class PvMarkWell extends StatelessWidget {
  const PvMarkWell({
    super.key,
    required this.p,
    required this.hue,
    this.size = 56,
    this.photo,
    this.mark,
    this.bracket,
    this.icon,
  });

  final V2Palette p;
  final double hue;
  final double size;
  final String? photo;
  final IntentMark? mark;
  final BracketMark? bracket;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue % 360, p);
    final Widget art;
    if (mark != null) {
      art = Padding(
        padding: EdgeInsets.all(size * 0.2),
        child: HubIntentArt(mark: mark!, tint: tint),
      );
    } else if (bracket != null) {
      art = Padding(
        padding: EdgeInsets.all(size * 0.14),
        child: V3BracketArt(mark: bracket!, tint: tint),
      );
    } else {
      art = Center(
        child: Icon(icon ?? Icons.circle_outlined,
            size: size * 0.46, color: pvWellInk(tint)),
      );
    }
    final well = Container(
      key: const ValueKey('pv_mark_well'),
      width: size,
      height: size,
      color: tint,
      child: art,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(size >= 48 ? 12 : 11),
      child: SizedBox(
        width: size,
        height: size,
        child: photo == null
            ? well
            : Image.network(
                photo!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => well,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : well,
              ),
      ),
    );
  }
}
