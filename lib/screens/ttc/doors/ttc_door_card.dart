// =============================================================================
//  TTC door pieces: the one section card, and the folded safety row
// -----------------------------------------------------------------------------
//  Two things the TTC door draws that the pregnancy door draws differently,
//  so they live here as TTC copies rather than as edits to `pv_door_chrome`
//  (the pregnancy doors are signed off and must not move).
//
//  ⚠️ WHY A TTC CARD AT ALL (the user, walking build 13, 2026-09-27): "so many
//  elements placed but not blending", "everything should feel done on
//  purpose rather than random". Inside one tab a section could be rows and
//  the next section tall cards, the cards stepped their hue 22 degrees per
//  card, and a card with no photograph drew a big faded document or play
//  shape where a picture should be. Three sources of "random" in one rail.
//
//  So every section in every TTC door is now this card, in a rail, and the
//  card has exactly two faces, chosen by one fact (is there a photograph):
//
//    photo        the read's own photograph, a dark scrim rising under the
//                 type, the kind chip top left, the title in white serif.
//    typographic  the door's own tint, flat (no per-card hue step), a small
//                 drawn mark for the kind in a white well, the title larger
//                 in the serif, and the kind with its minutes underneath.
//
//  Both faces share the geometry (150 x 176, the tab rail's width), the
//  corner radius, the padding and the place the title ends, so a rail of
//  mixed cards still reads as one row of the same object.
//
//  Mobbin, what decided it:
//    * Calm, "The weather report" tile: a card with no picture is a colour
//      block whose TITLE is the art, set large, and it sits in a grid of
//      photo cards without looking unfinished.
//      https://mobbin.com/screens/669f0282-b6e7-47db-8b44-0cb6ad9d600f
//    * Headspace library: every item the same shape and size, kind and
//      duration in one small line under the title ("Course · 3-10 min").
//      https://mobbin.com/screens/b0ec0b11-b683-4ddc-9a29-4968204769f6
//    * Oura Cycle Insights: a fertility content rail of one card shape.
//      https://mobbin.com/screens/757da07d-d5a8-4000-bc6b-588bb036d182
// =============================================================================

import 'package:flutter/material.dart';

import '../../../localization/app_language.dart';
import '../../../models/pv_read.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../brackets/hub/hub_intent_art.dart';
import '../../doors/pv_door_chrome.dart'
    show kPvRailCardHeight, kPvUrgentInk, kPvUrgentTint;
import '../../v2/v2_palette.dart';

/// The card's width: the tab rail's own (`TtcDoorRail.cardWidth`), so the
/// tab cards and the section cards under them line up in one column rhythm.
const double kTtcDoorCardWidth = 150;

/// The card's height. The shared rail height, so the edge-to-edge rail
/// arithmetic (`kPvRailCardHeight`) is unchanged.
const double kTtcDoorCardHeight = kPvRailCardHeight;

Key ttcDoorCardKey(String title) => ValueKey('ttc-door-card-$title');

/// One piece on a TTC door's section rail. See the header for the two faces.
class TtcDoorSectionCard extends StatelessWidget {
  const TtcDoorSectionCard({
    super.key,
    required this.p,
    required this.hue,
    required this.mark,
    required this.kind,
    required this.title,
    this.meta,
    this.imageUrl,
    this.onTap,
  });

  final V2Palette p;

  /// The DOOR's hue. Every card on a door takes the same tint: the per-card
  /// 22 degree step read as random on the phone (2026-09-27).
  final double hue;

  /// The kind, drawn (`ttcDoorFormatMark`).
  final IntentMark mark;

  /// One word for the kind: "Article", "Video", "Tool", "Paid".
  final String kind;
  final String title;

  /// The derived fact: "4 min read", "3 min film", "6 slides".
  final String? meta;

  /// The piece's photograph, when it has one.
  final String? imageUrl;
  final VoidCallback? onTap;

  bool get _onPhoto => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue % 360, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.32)
        .toColor();
    final onPhoto = _onPhoto;

    // The line under the title: kind and minutes, one line. On the photo
    // face the kind is already the chip, so only the minutes.
    final foot = onPhoto ? meta : [kind, ?meta].join(' · ');

    return Semantics(
      button: onTap != null,
      label: [kind, title, ?meta].join(', '),
      excludeSemantics: true,
      child: PvPress(
        child: Material(
          color: tint,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            // The caller hums (the door's `_openTile`), so the card does not
            // hum twice.
            onTap: onTap,
            child: SizedBox(
              width: kTtcDoorCardWidth,
              height: kTtcDoorCardHeight,
              child: Stack(
                children: [
                  if (onPhoto) ...[
                    Positioned.fill(
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        // Offline: the tint, never a grey box.
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    // Dark, never white: a white mist washes the photo out.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.68),
                            ],
                            stops: const [0.30, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (onPhoto)
                          _Chip(kind: kind, mark: mark, tint: tint, deep: deep)
                        else
                          // The typographic face's one drawn thing: the kind
                          // as a small mark in a white well. Small and whole,
                          // never the large faded ghost it replaces.
                          Container(
                            width: 34,
                            height: 34,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.78),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: HubIntentArt(mark: mark, tint: tint),
                          ),
                        // ⚠️ THE TITLE LEADS ON A CARD WITHOUT A PHOTO (build 14
                        // on the phone, 2026-09-28): with the title pinned to
                        // the foot, a small mark at the top and nothing between
                        // them, the card read hollow. Without a photo the
                        // words are the picture, so they sit under the mark,
                        // a size up, and the kind and minutes go to the foot.
                        // A photo card keeps its title low, over its scrim.
                        // Kept for revert: Spacer() first, 16.5 / maxLines 4.
                        if (onPhoto)
                          const Spacer()
                        else
                          const SizedBox(height: 14),
                        Text(
                          title,
                          // Three lines at the larger size: the mark, three
                          // lines and the foot fill the 176 card exactly.
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: pvFraunces(
                            fontSize: onPhoto ? 15 : 17.5,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.3,
                            color: onPhoto ? Colors.white : p.ink1,
                          ),
                        ),
                        if (!onPhoto) const Spacer(),
                        if (foot != null && foot.isNotEmpty) ...[
                          SizedBox(height: onPhoto ? 6 : 0),
                          Text(
                            foot,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: onPhoto
                                  ? Colors.white.withValues(alpha: 0.86)
                                  : deep,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.kind,
    required this.mark,
    required this.tint,
    required this.deep,
  });

  final String kind;
  final IntentMark mark;
  final Color tint;
  final Color deep;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.86),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: HubIntentArt(mark: mark, tint: tint),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            kind,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: pvManrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: deep,
            ),
          ),
        ),
      ],
    ),
  );
}

// =============================================================================
//  The folded safety row
// -----------------------------------------------------------------------------
//  The user (2026-09-27): "alerting is fine, it has to be done, but it's too
//  much on the face". Mind & body › Hard days opened on the full "When to get
//  help for low mood or anxiety" list before any content.
//
//  So the flag keeps its place (first thing in the tab, above everything) and
//  its words (the read's own title, whole), and the list folds behind one tap:
//  a coral-tinted row with a small alert mark, the title and a chevron, which
//  opens the full list in a sheet. Nothing clinical is removed; the sheet is
//  the same `TtcDoorRedFlag` block the tab used to draw, with its "Read the
//  full piece" way on. American Airlines' hazardous-materials banner is the
//  shape: one tinted line with an icon and a chevron, the detail on demand.
//  https://mobbin.com/screens/77d1bc6e-a8ee-4672-82cd-60d7f430fe29
// =============================================================================

class TtcDoorFlagRow extends StatelessWidget {
  const TtcDoorFlagRow({
    super.key,
    required this.callout,
    required this.lang,
    required this.p,
    required this.onOpen,
  });

  final PvCallout callout;
  final AppLanguage lang;
  final V2Palette p;

  /// Opens the full list.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final title = callout.title.of(lang);
    return Semantics(
      button: true,
      label: '$title. See the signs',
      excludeSemantics: true,
      child: PvPress(
        child: Material(
          color: kPvUrgentTint,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              pvCommitFeedback();
              onOpen();
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kPvUrgentInk.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.priority_high_rounded,
                        size: 16,
                        color: kPvUrgentInk,
                      ),
                    ),
                    const SizedBox(width: 11),
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
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              color: p.ink1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to see the signs',
                            style: pvManrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: p.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 22, color: p.ink2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The full list behind a [TtcDoorFlagRow], in a sheet. [body] is the
/// door's own `TtcDoorRedFlag` block, so the words cannot drift.
Future<void> showTtcDoorFlagSheet(
  BuildContext context, {
  required V2Palette p,
  required Widget Function(BuildContext sheetContext) body,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.86,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: p.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            body(sheetContext),
          ],
        ),
      ),
    ),
  );
}
