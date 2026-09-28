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

import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../../localization/app_language.dart';
import '../../../models/pv_read.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../brackets/hub/hub_intent_art.dart';
import '../../doors/pv_door_chrome.dart'
    show kPvRailCardHeight, kPvUrgentInk, kPvUrgentTint;
import '../../doors/pv_live_search.dart' show PvLiveSearch;
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
    this.icon,
  });

  final V2Palette p;

  /// A line icon drawn IN PLACE of [mark] (2026-09-28, launch sanity D3): a
  /// film that is not made yet wears a clock, never the play mark, so the
  /// card never looks playable. Null draws the mark.
  final IconData? icon;

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
                          _Chip(
                            kind: kind,
                            mark: mark,
                            icon: icon,
                            tint: tint,
                            deep: deep,
                          )
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
                            child: icon == null
                                ? HubIntentArt(mark: mark, tint: tint)
                                : Icon(icon, size: 20, color: deep),
                          ),
                        // ⚠️ THE TITLE LEADS ON A CARD WITHOUT A PHOTO (build 14
                        // on the phone, 2026-09-28): with the title pinned to
                        // the foot, a small mark at the top and nothing between
                        // them, the card read hollow. Without a photo the
                        // words are the picture, so they sit under the mark,
                        // a size up, and the kind and minutes go to the foot.
                        // A photo card keeps its title low, over its scrim.
                        // Kept for revert: Spacer() first, 16.5 / maxLines 4.
                        //
                        // ⚠️ AND BACK TO THE FOOT (the user, 2026-09-28): with
                        // the title at the top "the space below looks empty".
                        // So both faces end the title in the same place, over
                        // the kind and minutes, and the mark holds the top —
                        // Flo's saved-topic card: a drawn mark on a tint, the
                        // title bottom left, nothing between them.
                        // https://mobbin.com/screens/e0c04ff6-6dfe-4e54-b70d-478a9aedb89e
                        // The photo face keeps its shape, which is Calm's: a
                        // white title low over a dark scrim.
                        // https://mobbin.com/screens/ecb19e99-688b-491e-a12f-e5e43e59dfd8
                        // Kept for revert (2026-09-28), the title leading:
                        //   if (onPhoto)
                        //     const Spacer()
                        //   else
                        //     const SizedBox(height: 14),
                        const Spacer(),
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
                        // Kept for revert (2026-09-28): the Spacer that pushed
                        // the foot down under a leading title.
                        //   if (!onPhoto) const Spacer(),
                        if (foot != null && foot.isNotEmpty) ...[
                          // Kept for revert (2026-09-28): onPhoto ? 6 : 0.
                          const SizedBox(height: 6),
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
    this.icon,
  });

  final String kind;
  final IntentMark mark;
  final IconData? icon;
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
          child: icon == null
              ? HubIntentArt(mark: mark, tint: tint)
              : Icon(icon, size: 12, color: deep),
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
//  TtcDoorWideCard — the one card, at full width, for a section of one piece
// -----------------------------------------------------------------------------
//  Launch sanity D11, D13 (2026-09-28): "Read your own report", "Get it read",
//  "Your checklist" were sections of ONE 150-wide card with the rest of the
//  row empty, which read as a load failure. The rail stays for two or more;
//  a single piece takes the whole width, as the same object (the door's tint,
//  the 20 corner, the mark in its white well or the piece's photo, the serif
//  title, the kind and minutes in the foot), laid on its side, with the
//  piece's one line of what it answers where the empty half used to be.
//  Headspace's featured row: one full-width card with a thumbnail, a title
//  and a one-line promise
//  (https://mobbin.com/screens/b0ec0b11-b683-4ddc-9a29-4968204769f6).
// =============================================================================

class TtcDoorWideCard extends StatelessWidget {
  const TtcDoorWideCard({
    super.key,
    required this.p,
    required this.hue,
    required this.mark,
    required this.kind,
    required this.title,
    this.blurb,
    this.meta,
    this.imageUrl,
    this.icon,
    this.onTap,
  });

  final V2Palette p;
  final double hue;
  final IntentMark mark;
  final String kind;
  final String title;

  /// One line of what the piece answers.
  final String? blurb;
  final String? meta;
  final String? imageUrl;

  /// Drawn in place of [mark] (a clock for an unmade film).
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue % 360, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.32)
        .toColor();
    final photo = imageUrl != null && imageUrl!.isNotEmpty;
    final well = Container(
      color: Colors.white.withValues(alpha: 0.78),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(14),
      child: icon == null
          ? HubIntentArt(mark: mark, tint: tint)
          : Icon(icon, size: 26, color: deep),
    );
    final foot = [kind, ?meta].join(' · ');
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
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 76,
                      height: 76,
                      child: photo
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => well,
                            )
                          : well,
                    ),
                  ),
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
                          style: pvFraunces(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.3,
                            color: p.ink1,
                          ),
                        ),
                        if (blurb case final b? when b.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            b,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                              fontSize: 12.5,
                              height: 1.35,
                              color: p.ink2,
                            ),
                          ),
                        ],
                        const SizedBox(height: 5),
                        Text(
                          foot,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: deep,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, size: 20, color: deep),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  TtcDoorLinkRow — a way to another door, as words, not as a card
// -----------------------------------------------------------------------------
//  Launch sanity MB20 (2026-09-28): "More in Getting ready" was a card whose
//  type label read "Elsewhere" — a signpost dressed as content, and on Mind &
//  body it sat under a tab that had the other door's name. A way to another
//  door is a plain row: the door's name as the link, one line of what is
//  there, an arrow out. Nothing to mistake for a piece to read.
// =============================================================================

class TtcDoorLinkRow extends StatelessWidget {
  const TtcDoorLinkRow({
    super.key,
    required this.p,
    required this.door,
    required this.line,
    required this.onTap,
  });

  final V2Palette p;

  /// The other door's own name, as on its tile.
  final String door;

  /// What she will find there.
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Open the $door door. $line',
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.north_east_rounded, size: 18, color: p.ink2),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Open the $door door',
                      style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: p.ink1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      line,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 12.5,
                        height: 1.35,
                        color: p.ink2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ],
          ),
        ),
      ),
    ),
  );
}

// =============================================================================
//  TtcDoorPinnedBar — back and the door's name, once the hero has gone
// -----------------------------------------------------------------------------
//  Launch sanity D2, MB19 (2026-09-28): the door had no pinned bar, so once
//  the hero scrolled away section headings and the glass search slid under
//  the status-bar clock and icons, and the back button was gone until she
//  scrolled to the top. Now a white bar fades in as the hero's words fade
//  out: the status bar's own height, then back, the door's name and a search
//  button that brings the (kept) glass field back into view with the
//  keyboard up. Tripadvisor's article bar and GitHub's list bar are the
//  shape: back, one line of title, one action
//  (https://mobbin.com/screens/a22724ec-d685-44b9-b6b4-5ac067313e6b,
//  https://mobbin.com/screens/b63f1e55-e4b4-450f-a564-4df40b8e66f2).
//
//  ⚠️ WHILE SHE SEARCHES THE BAR STANDS ASIDE. Focus rides the glass field to
//  the top of the screen, which is where the bar would be, so the bar gives
//  way to a strip the height of the status bar only: the rows can no longer
//  slide under the clock, and the field is not covered.
// =============================================================================

class TtcDoorPinnedBar extends StatelessWidget {
  const TtcDoorPinnedBar({
    super.key,
    required this.scroll,
    required this.search,
    required this.p,
    required this.title,
    required this.onSearch,
  });

  /// The door list's offset.
  final ValueListenable<double> scroll;
  final PvLiveSearch search;
  final V2Palette p;
  final String title;
  final VoidCallback onSearch;

  /// The bar is fully in by the time the glass field would reach it: the
  /// field's top sits about 240 below the status bar at rest, so at 190 of
  /// scroll it touches the bar's foot. It starts to show 50 earlier.
  static const double pinFrom = 140;
  static const double pinAt = 190;
  static const double barHeight = 52;

  /// 0 (hidden) to 1 (shown) for an offset.
  static double shownAt(double o) =>
      ((o - pinFrom) / (pinAt - pinFrom)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ListenableBuilder(
        listenable: Listenable.merge([scroll, search]),
        builder: (context, _) {
          final o = scroll.value;
          if (!search.idle) {
            // Searching: the status-bar strip only, once anything scrolls.
            return IgnorePointer(
              child: Opacity(
                opacity: o > 4 ? 1 : 0,
                child: Container(height: top, color: p.ground),
              ),
            );
          }
          final t = shownAt(o);
          return IgnorePointer(
            ignoring: t < 0.6,
            child: Opacity(
              opacity: t,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.only(top: top),
                    decoration: BoxDecoration(
                      color: p.ground.withValues(alpha: 0.94),
                      border: Border(bottom: BorderSide(color: p.line)),
                    ),
                    child: SizedBox(
                      height: barHeight,
                      child: Row(
                        children: [
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: 'Back',
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: p.ink1,
                              size: 22,
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pvFraunces(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                color: p.ink1,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Search $title',
                            icon: Icon(
                              Icons.search_rounded,
                              color: p.ink1,
                              size: 22,
                            ),
                            onPressed: () {
                              pvCommitFeedback();
                              onSearch();
                            },
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
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
    this.compact = false,
  });

  final PvCallout callout;
  final AppLanguage lang;
  final V2Palette p;

  /// Opens the full list.
  final VoidCallback onOpen;

  /// ONE SHORT LINE (2026-09-28, the user's option B): the title and a
  /// chevron, no "Tap to see the signs" under it, a smaller mark and a 44pt
  /// row. The door draws only this form now, on the one tab that keeps a
  /// safety line (`kTtcDoorFlagTabs`). False draws the two-line row as
  /// before, kept for revert.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final title = callout.title.of(lang);
    if (compact) return _compact(title);
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

  /// The one-line form: mark, the read's own title, chevron.
  Widget _compact(String title) => Semantics(
    button: true,
    label: '$title. See the signs',
    excludeSemantics: true,
    child: PvPress(
      child: Material(
        color: kPvUrgentTint,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            pvCommitFeedback();
            onOpen();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.priority_high_rounded,
                    size: 15,
                    color: kPvUrgentInk,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: p.ink1,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20, color: p.ink2),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The key on the flag sheet's call button (D15).
Key ttcDoorCallKey(String number) => ValueKey('ttc-door-call-$number');

/// "Call 112": one ink pill under an urgent list (launch sanity D15,
/// 2026-09-28), and one grey line saying what the number is. The number
/// comes from the caller, which takes it from the one constant that holds
/// it; nothing is typed here.
class TtcDoorCallButton extends StatelessWidget {
  const TtcDoorCallButton({
    super.key,
    required this.p,
    required this.number,
    required this.dial,
    this.ambulance,
  });

  final V2Palette p;
  final String number;
  final Future<void> Function(String number) dial;

  /// India's ambulance number (108), offered under the emergency pill as a
  /// quieter outlined one (2026-09-28). A "go to a hospital today" sheet is
  /// about getting her to care, and 108 sends the ambulance directly. Null
  /// draws the one pill, as before.
  final String? ambulance;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Semantics(
        button: true,
        label: 'Call $number, emergency services',
        excludeSemantics: true,
        child: Material(
          key: ttcDoorCallKey(number),
          color: p.ink1,
          borderRadius: BorderRadius.circular(999),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              pvCommitFeedback();
              dial(number);
            },
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.call_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Call $number',
                    style: pvManrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      if (ambulance case final amb?) ...[
        const SizedBox(height: 10),
        // The second action, quieter: an outlined pill, so the ink one stays
        // the first thing to press.
        Semantics(
          button: true,
          label: 'Call $amb for an ambulance',
          excludeSemantics: true,
          child: Material(
            key: ttcDoorCallKey(amb),
            color: Colors.transparent,
            shape: StadiumBorder(side: BorderSide(color: p.ink1, width: 1.2)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                pvCommitFeedback();
                dial(amb);
              },
              child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_hospital_outlined,
                        size: 18, color: p.ink1),
                    const SizedBox(width: 8),
                    // Scales down rather than overflowing on a narrow phone
                    // or a large text setting; the words are never cut.
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Call $amb for an ambulance',
                          style: pvManrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: p.ink1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      const SizedBox(height: 8),
      Text(
        // Kept for revert (2026-09-28), the one-number line:
        //   '$number is India\'s emergency number. It is free, and it works '
        //   'from any phone. If you can get to a hospital safely, go now.',
        ambulance == null
            ? '$number is India\'s emergency number. It is free, and it works '
                'from any phone. If you can get to a hospital safely, go now.'
            : '$number is India\'s emergency number and $ambulance is the '
                'ambulance number in most states. Both calls are free. If you '
                'can get to a hospital safely, go now.',
        textAlign: TextAlign.center,
        style: pvManrope(fontSize: 12, height: 1.45, color: p.ink2),
      ),
    ],
  );
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
