// =============================================================================
//  TtcFocusScreen — one problem area, one scrollable page
// -----------------------------------------------------------------------------
//  Renders a `TtcFocusPage`. It knows nothing about conceiving specifically —
//  the content is data, and adding a second focus area is a data change plus a
//  line in `kTtcFocusPages`.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE THREE-LEVEL HIERARCHY IS THE DESIGN, AND IT IS EASY TO WRECK
//  ---------------------------------------------------------------------------
//
//    section  →  a plain question she might ask        ("What he should do")
//    tile     →  one piece of content                  ("3 things for him")
//    format   →  what kind of thing it is              (Carousel)
//
//  The failure mode, which every content-heavy screen in this app has hit at
//  least once, is the third level climbing into the first: a "Videos" heading,
//  an "Articles" section, a "Tools" group. That organises the page by how we
//  happened to build it instead of by what she wants to know, and it is
//  invisible in review because it looks tidy.
//
//  So the format never appears as a heading. It appears as a small chip on the
//  tile, which is the only place it belongs: she does not choose a format, she
//  chooses a question and then wants to know whether the answer is thirty
//  seconds of reading or a four-minute film.
//
//  ---------------------------------------------------------------------------
//  ⚠️ PAID TILES DO NOT LOOK LIKE FREE TILES
//  ---------------------------------------------------------------------------
//
//  Twenty-three of the twenty-five tiles here are free. Two are not — the
//  masterclass at the top and the ovulation kit in section one. Those two get a
//  filled, bordered treatment and a chip that says what they are, because a
//  shop tile that looks exactly like an article is a dark pattern whether or not
//  anyone meant it that way. `TtcTileFormat.isPaid` decides, so the rule lives
//  with the format rather than being remembered at each call site.
//
//  ⚠️ AND THE PAGE STILL CLOSES ON A PERSON, NOT A PRICE. Same call as the V3
//  home: the last thing on the page is a consultation, and the last thing under
//  that is the disclaimer.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_focus_data.dart';
import '../../ttc/ttc_prepare_data.dart';
import '../../widgets/pv_placeholders.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart';
import '../v2/v3_hero_field.dart';
import '../../ttc/ttc_reads_data.dart';
import '../../ttc/ttc_videos_data.dart';
import '../reader/pv_reader_screen.dart';
import 'ttc_common.dart';
import 'ttc_illustrations.dart';
import 'ttc_story_screen.dart';
import 'ttc_prepare_screen.dart';
import 'ttc_products_screen.dart';
import 'ttc_strings.dart';
import 'ttc_today_parts.dart' show showTtcRowSheet;
import 'ttc_surface_router.dart';

// -----------------------------------------------------------------------------
//  Rail geometry
// -----------------------------------------------------------------------------
//  ⚠️ PUBLIC SO A TEST CAN DO THE SUM. These were private constants on
//  `_TileCard` plus a literal `11` in the rail's `separatorBuilder`, which is
//  three numbers in two places that only mean something together — and the
//  thing they have to add up to (how much of the third card is visible) was
//  written down nowhere and therefore drifted.
//
//  It drifted to four points, which reads as a clipping bug rather than as an
//  invitation to swipe. `ttc_rail_peek_test.dart` now asserts the remainder
//  directly, so the next time someone changes a width the arithmetic fails
//  rather than the design.
const double kTtcRailCardWidth = 142;
const double kTtcRailCardHeight = 176;
const double kTtcRailGap = 10;

/// The narrowest screen this app is designed against.
///
/// Not a guess: 360dp is the standard Android baseline and the width most
/// budget Indian handsets report. Anything that fits here fits everywhere.
const double kPvNarrowestScreen = 360;

class TtcFocusScreen extends StatelessWidget {
  const TtcFocusScreen({super.key, required this.page, required this.bracket});

  final TtcFocusPage page;

  /// ⚠️ THE WHOLE BRACKET, NOT A TITLE AND A HUE. The heading is
  /// `bracket.label` — the exact string on the tile she tapped — so the two can
  /// never drift apart. This screen shipped titled "Getting pregnant" behind a
  /// tile reading "Fertile window", and the mismatch reads as having landed on
  /// the wrong screen.
  final Bracket bracket;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcLang.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final hue = bracket.hue;
        final tint = v2BlockTint(hue, p);
        final lang = TtcLang.instance.hinglish
            ? AppLanguage.hinglish
            : AppLanguage.english;
        final title = bracket.label.of(lang);

        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(children: [
            // The field is the page's surface and does not scroll — the same
            // structure every V3 screen uses.
            Positioned.fill(
              child: V3HeroField(accent: tint, ground: p.ground, variant: 1),
            ),
            ListView(
              // ⚠️ NO BOTTOM PADDING HERE — THE SHEET OWNS THE CLEARANCE.
              // Padding on the ListView sits BELOW the sheet's ground, so
              // scrolling to the end revealed the hero field through a 96pt
              // gap under the last card. Whenever a scroll view has a coloured
              // panel inside it, the panel has to be the thing that reaches the
              // bottom, not the padding.
              padding: EdgeInsets.zero,
              children: [
                _Hero(
                    page: page,
                    p: p,
                    tint: tint,
                    title: title,
                    eyebrow: bracket.title.of(lang),
                    bracket: bracket),
                _Sheet(p: p, children: [
                  const SizedBox(height: 24),

                  // ⚠️ THE INTRO LINE IS GONE. "Some things really help. Some
                  // things do not. You do not need to do everything." was good
                  // copy doing no work: it sat between the film that had just
                  // said the same thing and a paid tile, and the two of them
                  // together held the top of the page without earning it.
                  //
                  // Kept here rather than deleted because the sentiment is the
                  // stage's whole posture and will want a home again — probably
                  // on the film's own card, where it is the subtitle.
                  //
                  // _pad(Text(page.intro, ...)),

                  // ---- the one paid tile -------------------------------
                  //
                  // ⚠️ AN ORDINARY RAIL CARD, LAID SIDEWAYS. It used to be a
                  // full-width row with a 40pt icon well, which is a shape that
                  // appears nowhere else on the page any more — the rails
                  // dropped icon wells when they became picture blocks. One
                  // leftover shape at the top read as a fragment of an older
                  // screen.
                  // ⚠️ COMMENTED OUT ON REQUEST, KEPT FOR LATER. The paid
                  // masterclass sat between the film and the first section and
                  // was asked to come off for now — "not needed for now, but
                  // just comment it out, as I might want it in future".
                  //
                  // `page.headline` stays on the model and stays populated, so
                  // restoring this is uncommenting three lines. Note that
                  // `ttc_focus_page_test.dart` asserts the page still HAS a
                  // headline and that exactly two tiles cost money — those
                  // assertions are about the data, not about what is drawn, so
                  // they still hold and still describe the intent.
                  //
                  // if (page.headline case final headline?) ...[
                  //   _pad(_WideCard(tile: headline, p: p)),
                  //   const SizedBox(height: 28),
                  // ],

                  // ---- the sections ------------------------------------
                  //
                  // ⚠️ A HORIZONTAL RAIL PER SECTION, NOT A VERTICAL LIST, and
                  // the difference is not cosmetic. Seven sections holding
                  // twenty-five stacked rows is a page you scroll for a long
                  // time past things you did not want; seven rails is a page
                  // where every SECTION is reachable in one thumb-flick and the
                  // depth is sideways, where it costs nothing.
                  //
                  // ⚠️ AND THE CARDS ARE DELIBERATELY CUT OFF AT THE RIGHT EDGE.
                  // A rail that fits exactly reads as a finished row and nobody
                  // swipes it. Half a card showing is the only reliable signal
                  // that there is more — which is why the viewport is 200 wide
                  // on a 360 screen rather than something that divides evenly.
                  for (final section in page.sections) ...[
                    _pad(Text(section.heading,
                        style: pvFraunces(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.45,
                            color: p.ink1))),
                    const SizedBox(height: 13),
                    SizedBox(
                      height: _TileCard.height,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: section.tiles.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: kTtcRailGap),
                        itemBuilder: (context, i) => _TileCard(
                            tile: section.tiles[i],
                            p: p,
                            hue: hue,
                            index: i),
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],

                  // ⚠️ EVERY CLINICAL SURFACE CARRIES THIS. CLAUDE.md: never a
                  // diagnosis, and anything clinical ends with a disclaimer.
                  // This page holds twenty-five pieces of medical content and
                  // would be the worst one to leave it off.
                  _pad(Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 15, color: p.ink3),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(TtcS.current().estimatesDisclaimer,
                              style: pvManrope(
                                  fontSize: 11.5, height: 1.5, color: p.ink3)),
                        ),
                      ])),
                ]),
              ],
            ),
            // ⚠️ NO SECOND BACK BUTTON HERE. This screen had one pinned to the
            // Stack AND one inside the hero, so the top-left corner carried two
            // arrows a few pixels apart.
            //
            // It happened because the hero was rebuilt to match the hub's
            // grammar — which includes a chip-backed back button — and the
            // pre-existing one was never removed. That is the standard hazard
            // of replacing a header: the new one brings its own chrome and the
            // old chrome is in a different part of the file.
            //
            // const Positioned(
            //     left: 6, top: 0, child: SafeArea(child: _Back())),
          ]),
        );
      },
    );
  }
}

Widget _pad(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: child);

// RETIRED WITH THE DUPLICATE ARROW. The hero draws its own, chip-backed,
// matching the hub's.
// class _Back extends StatelessWidget {
//   const _Back();
//
//   @override
//   Widget build(BuildContext context) => IconButton(
//         icon: const Icon(Icons.arrow_back_rounded),
//         color: ttcInk,
//         onPressed: () => Navigator.of(context).maybePop(),
//       );
// }
//
/// The page title, and the film in place of a support paragraph.
/// The page header, built to the SAME grammar as `ProblemHubScreen`'s hero.
///
/// ⚠️ THE SYMMETRY IS THE REQUIREMENT, NOT A NICETY.
///
/// This screen and the hub are the two things a door on the "Start anywhere"
/// grid can open. They sat beside each other in that grid and then opened two
/// visibly different headers — chip-backed back button, small-caps eyebrow and
/// the bracket's mark bleeding off the right on one; a bare arrow and a title
/// on the other. Reported exactly that way: *"you have missed the symmetry…
/// the fertile window one looks very bland."*
///
/// It is worth naming HOW that happened, because it is the standing hazard of
/// replacing one screen with another: the focus page was written against a
/// content spec (title, intro, sections) and the hub against a chrome spec, and
/// neither brief mentioned the other. **Two screens reachable from the same
/// grid have to be designed against each other, not against their own briefs.**
///
/// ⚠️ THE MARK MATTERS MOST OF THE THREE. It is the same drawing as the tile
/// she tapped, half-bled off the right edge, so the door and the room behind it
/// carry the same object. That continuity is nearly free and its absence is
/// most of why this read as bland.
///
/// ⚠️ AND THE HEIGHT IS CONTENT-DRIVEN, for the reason the hub already learned
/// the hard way: a fixed height plus a 16:9 film overflows by about 140px, and
/// a `Spacer` cannot be used in a column that sizes to its children. See the
/// long note in `problem_hub_screen.dart`.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.page,
    required this.p,
    required this.tint,
    required this.title,
    required this.eyebrow,
    required this.bracket,
  });

  final TtcFocusPage page;
  final V2Palette p;
  final Color tint;

  /// `bracket.label` — the same string as the tile that opened this.
  final String title;

  /// `bracket.title` — the area, set small above the heading.
  final String eyebrow;

  final Bracket bracket;

  @override
  Widget build(BuildContext context) {
    final mark = bracketMarkFor(bracket.id);

    return Stack(children: [
      Positioned(
        right: -26,
        top: 52,
        child: Opacity(
          // 0.5 — the same value the hub settled on. At 0.26 it read as two
          // blank grey boxes on a tinted field; a mark you have to look for is
          // decoration nobody sees.
          opacity: 0.5,
          child: SizedBox(
              width: 146,
              height: 146,
              child: mark == null
                  ? const SizedBox.shrink()
                  : V3BracketArt(mark: mark, tint: tint)),
        ),
      ),
      SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 22, 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.55),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(Icons.arrow_back_rounded,
                              size: 19, color: p.ink1)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(eyebrow.toUpperCase(),
                    style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: p.ink2)),
                const SizedBox(height: 8),
                // ⚠️ THE AREA'S NAME, NOT A QUESTION — and the same string as
                // the tile, so tapping one name never lands on another.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 252),
                  child: Text(title,
                      style: pvFraunces(
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          letterSpacing: -0.6,
                          color: p.ink1)),
                ),
                if (page.heroVideoSlot case final slot?) ...[
                  const SizedBox(height: 9),
                  // No file exists yet. `PvVideoPlaceholder` holds the real
                  // 16:9 geometry and is deliberately not tappable.
                  //
                  // ⚠️ NO SUBTITLE. The heading sits directly above it; a line
                  // here would be a third string saying what two already say —
                  // the mistake this codebase has now made four times.
                  Padding(
                    padding: const EdgeInsets.only(right: 4, top: 2),
                    child: PvVideoPlaceholder(
                      title: page.heroVideoTitle ?? title,
                      overlayTitle: true,
                      duration: '2 MIN',
                      hue: bracket.hue,
                      slotId: slot,
                      // ⚠️ FLAT. The default is a diagonal `tint -> deep`
                      // gradient running top-left to bottom-right, and at the
                      // head of a page it reads as a bright wash down one
                      // corner rather than as a thumbnail: *"whatever lightning
                      // gradient on the left hand side of that area just
                      // doesn't look that nice. Keep it simple."*
                      //
                      // Same conclusion the reader reached, for the same
                      // reason. The gradient is right on a HUB, where a
                      // thumbnail is competing with a grid of tiles for
                      // attention. At the top of a page it is already the
                      // largest object present and the extra contrast is spent
                      // winning an argument it has no opponent in.
                      //
                      // A flag on the shared component, not a second widget —
                      // the geometry, the play control, the duration chip and
                      // the coming-soon treatment all have to stay identical,
                      // because the whole point of the placeholder is that
                      // nothing shifts when the real file lands.
                      flat: true,
                    ),
                  ),
                ],
              ]),
        ),
      ),
    ]);
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.p, required this.children});

  final V2Palette p;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height * 0.72),
        decoration: BoxDecoration(
          color: p.ground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...children,
          // The nav pill and the Ask FAB both float over this.
          const SizedBox(height: ttcBottomInset),
        ]),
      );
}

// -----------------------------------------------------------------------------
//  One tile
// -----------------------------------------------------------------------------

// RETIRED, KEPT FOR REVERT. The full-width row with a 40pt icon well.
// Replaced by `_WideCard`, which is the rail card's own grammar laid
// sideways, so the page has one card language instead of two.
// class _Tile extends StatelessWidget {
//   const _Tile({required this.tile, required this.p, required this.hue});
//
//   final TtcTile tile;
//   final V2Palette p;
//   final double hue;
//
//   @override
//   Widget build(BuildContext context) {
//     final paid = tile.format.isPaid;
//     final tint = v2BlockTint(paid ? 42 : hue, p);
//
//     return InkWell(
//       onTap: () => openTtcFocusTile(context, tile, hue),
//       borderRadius: BorderRadius.circular(18),
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
//         decoration: BoxDecoration(
//           // ⚠️ THE PAID TREATMENT IS A DIFFERENT SURFACE, not a badge bolted
//           // onto the free one. A tinted fill and a coloured border read as
//           // "this is a different kind of thing" at a glance, from across the
//           // room, before any text is read — which is the only test that
//           // matters for this distinction.
//           color: paid ? tint.withValues(alpha: 0.55) : p.surface,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(
//               color: paid
//                   ? HSLColor.fromColor(tint)
//                       .withSaturation(0.5)
//                       .withLightness(0.68)
//                       .toColor()
//                   : p.line,
//               width: paid ? 1.5 : 1),
//         ),
//         child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Container(
//             width: 40,
//             height: 40,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: paid ? Colors.white.withValues(alpha: 0.7) : tint,
//               borderRadius: BorderRadius.circular(13),
//             ),
//             child: Icon(iconForFormat(tile.format),
//                 size: 19,
//                 color: HSLColor.fromColor(tint)
//                     .withSaturation(0.46)
//                     .withLightness(0.4)
//                     .toColor()),
//           ),
//           const SizedBox(width: 13),
//           Expanded(
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(tile.title,
//                   style: pvFraunces(
//                       fontSize: 16.5,
//                       fontWeight: FontWeight.w600,
//                       height: 1.25,
//                       letterSpacing: -0.3,
//                       color: p.ink1)),
//               const SizedBox(height: 4),
//               Text(tile.blurb,
//                   style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
//               const SizedBox(height: 9),
//               _FormatChip(tile: tile, p: p),
//             ]),
//           ),
//           const SizedBox(width: 6),
//           Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
//         ]),
//       ),
//     );
//   }
//
//   /// ⚠️ A LINE ICON PER FORMAT, and the switch is exhaustive because `TtcTile`
//   /// is sealed — a ninth format will not compile until it is given one. That is
//   /// the whole reason the union exists: the alternative is a `default:` arm
//   /// that silently ships a wrong icon.
// }
//
/// The picture a tile carries, if it has one.
///
/// ⚠️ THE SAME IMAGE ON THE CARD AND ON THE PAGE IT OPENS. That is the whole
/// point of putting art on the tile rather than on the screen: the thumbnail
/// she taps becomes the header she lands on, which is what makes a card and its
/// article read as one object instead of a link to another one.
TtcArt? artForTile(TtcTile tile) => switch (tile) {
      TtcArticleTile(:final art) => art,
      TtcCarouselTile(:final art) => art,
      _ => null,
    };

/// The photograph a tile carries, if any.
String? photoForTile(TtcTile tile) => switch (tile) {
      TtcArticleTile(:final imageUrl) => imageUrl,
      _ => null,
    };

IconData iconForFormat(TtcTileFormat format) => switch (format) {
    TtcTileFormat.masterclass => Icons.school_outlined,
    TtcTileFormat.tool => Icons.tune_rounded,
    TtcTileFormat.article => Icons.article_outlined,
    TtcTileFormat.carousel => Icons.view_carousel_outlined,
    TtcTileFormat.video => Icons.play_circle_outline_rounded,
    TtcTileFormat.mythFact => Icons.balance_rounded,
    TtcTileFormat.product => Icons.shopping_bag_outlined,
    TtcTileFormat.booking => Icons.event_available_outlined,
  };

/// Opens whatever a tile is.
///
/// ⚠️ EVERY BRANCH PUSHES A SCREEN. Articles and carousels used to open a
/// bottom sheet, which capped the main content at half a screen and told the
/// reader that what they tapped was minor. Tapping a piece of content opens
/// that piece of content, full screen, every time.
void openTtcFocusTile(BuildContext context, TtcTile tile, double hue) {
  switch (tile) {
    // ---- the tool: opened, never rebuilt --------------------------------
    case TtcToolTile(:final surfaceId):
      openTtcSurface(context, surfaceId);

    // ---- reading --------------------------------------------------------
    case TtcArticleTile(:final readId, :final art, :final imageUrl):
      // ⚠️ ONE ARTICLE FORMAT, AND ONLY ONE. Every article tile opens
      // `PvReaderScreen` — the reader the rest of the app uses. There is no
      // lighter second reader any more: it existed for four tiles whose answer
      // was written inline, and having two article screens meant the same chip
      // opened two different-looking things depending on which tile you tapped.
      //
      // Those four are now real library reads, which is what "don't create new
      // formats" actually costs: the content had to be written to the standard
      // the format requires (four sections, a contents, an FAQ, sourcing, a
      // when-to-see-someone) rather than the format being lowered to the
      // content. `body` and `moreReadId` are gone from the model with it.
      openTtcArticle(context, readId!, art: art, imageUrl: imageUrl, hue: hue);

    case TtcCarouselTile(
        :final cards,
        :final reviewedBy,
        :final coverTitle,
        :final coverBlurb,
        :final art
      ):
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/story'),
        builder: (_) => TtcStoryScreen(
          title: tile.title,
          cards: cards,
          hue: hue,
          reviewedBy: reviewedBy,
          coverTitle: coverTitle,
          coverBlurb: coverBlurb,
          coverArt: art,
        ),
      ));

    // ⚠️ A MYTH IS A STORY WHERE IT HAS SLIDES, and the two-block screen only
    // where it does not. Same reasoning as the carousel: stating a correction
    // teaches an answer, walking through the mechanism teaches why the belief
    // exists — which is what stops the next version of the same myth landing.
    // ⚠️ A MYTH IS ALWAYS A STORY NOW, AND THERE IS NO SECOND SCREEN.
    //
    // The first attempt gave myths their own two-panel screen. That was one
    // more format for the same chip — the exact thing the article split was
    // just deleted for — so it went, and the fallback is a story SYNTHESISED
    // from the claim and the correction rather than a different widget.
    //
    // Two slides is a thin story and that is the honest signal: a myth with no
    // authored slides is content that has not been written yet, and it reads
    // as slightly thin rather than as a different kind of thing. Authoring
    // slides upgrades it in place, with no code change at the call site.
    case TtcMythTile(:final myth, :final fact, :final slides):
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/story'),
        builder: (_) => TtcStoryScreen(
          title: tile.title,
          cards: slides.isNotEmpty
              ? slides
              : [
                  TtcCarouselCard(
                      title: 'What people say', body: myth),
                  TtcCarouselCard(title: 'What is true', body: fact),
                ],
          hue: hue,
          reviewedBy: 'ParentVeda medical review',
          coverTitle: tile.title,
          coverBlurb: tile.blurb,
        ),
      ));

    case TtcVideoTile(:final slotId, :final duration):
      // ⚠️ THE TILE IS TAPPABLE AND THE PLACEHOLDER INSIDE IT IS NOT. The
      // sheet is honest about there being no film yet; a play control that
      // plays nothing would teach her that taps do nothing.
      showTtcRowSheet(
        context,
        eyebrow: tile.format.label,
        title: tile.title,
        body: [
          PvVideoPlaceholder(
            title: tile.title,
            subtitle: tile.blurb,
            duration: duration,
            hue: 268,
            slotId: slotId,
            // Same reasoning as the hero above: inside a sheet this is the
            // only object on screen, so the gradient has nothing to separate
            // itself from.
            flat: true,
          ),
          const SizedBox(height: 14),
          Text(
              'This film is being made. It will play here when it is ready.',
              style: ttcBody(13.5, color: ttcSoft, h: 1.6)),
        ],
      );

    // ---- the two that cost money ----------------------------------------
    case TtcProductTile(:final productId):
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/products'),
        builder: (_) => TtcProductsScreen(focusId: productId),
      ));

    case TtcMasterclassTile(:final offeringId):
      final offering = ttcOfferingById(offeringId);
      // Null is a real answer — an unknown id opens nothing rather than
      // opening the wrong course. Same call the surface router makes.
      if (offering == null) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'ttc/offering/$offeringId'),
        builder: (_) => TtcOfferingScreen(offering: offering),
      ));

    // ---- a person --------------------------------------------------------
    case TtcBookingTile(:final action):
      // The booking engine, configured, scoped to consults — never a second
      // appointment feature.
      if (action != kTtcActConsult) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/consults'),
        builder: (_) => const TtcPrepareScreen(onlyCategory: 'consults'),
      ));
  }
}


//// KEPT WITH THE MASTERCLASS CARD IT DRAWS. Both come back together — see
// the commented block in the page body. Deleting this would make
// restoring that card a rewrite rather than an uncomment.
// /// The paid tile at the top — the rail card's grammar, laid on its side.
// ///
// /// ⚠️ THE SAME PARTS AS `_TileCard`, IN A RECTANGLE. Badge top-left, big quiet
// /// mark behind, title over it. That is the point: the page now has exactly one
// /// card language, and the headline is a wide instance of it rather than a
// /// second design that happens to sit above the first.
// class _WideCard extends StatelessWidget {
//   const _WideCard({required this.tile, required this.p});
//
//   final TtcTile tile;
//   final V2Palette p;
//
//   @override
//   Widget build(BuildContext context) {
//     final tint = v2BlockTint(42, p);
//     final deep = HSLColor.fromColor(tint)
//         .withSaturation(0.5)
//         .withLightness(0.34)
//         .toColor();
//
//     return InkWell(
//       onTap: () => openTtcFocusTile(context, tile, 42),
//       borderRadius: BorderRadius.circular(18),
//       child: Container(
//         height: 132,
//         decoration: BoxDecoration(
//           color: tint,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: deep.withValues(alpha: 0.40), width: 1.5),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Stack(children: [
//           Positioned(
//             right: -20,
//             bottom: -18,
//             child: Icon(iconForFormat(tile.format),
//                 size: 132, color: Colors.white.withValues(alpha: 0.45)),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: p.ink1,
//                       borderRadius: BorderRadius.circular(999),
//                     ),
//                     child: Row(mainAxisSize: MainAxisSize.min, children: [
//                       Icon(iconForFormat(tile.format),
//                           size: 10, color: Colors.white),
//                       const SizedBox(width: 4),
//                       Text('${tile.format.label} · Paid',
//                           style: pvManrope(
//                               fontSize: 9,
//                               fontWeight: FontWeight.w800,
//                               letterSpacing: 0.6,
//                               color: Colors.white)),
//                     ]),
//                   ),
//                   const Spacer(),
//                   SizedBox(
//                     width: 250,
//                     child: Text(tile.title,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: pvFraunces(
//                             fontSize: 17,
//                             fontWeight: FontWeight.w600,
//                             height: 1.2,
//                             letterSpacing: -0.4,
//                             color: p.ink1)),
//                   ),
//                 ]),
//           ),
//         ]),
//       ),
//     );
//   }
// }
//
///// One tile as a block on a rail.
///
/// ⚠️ THE ART IS THE CARD, NOT A THUMBNAIL STRIP ABOVE A LABEL. The reference
/// fills each block edge to edge with an illustration and sets the title over
/// the foot of it. We have no per-tile illustrations and are not inventing an
/// asset pipeline for twenty-five of them, so the block is a tinted field with
/// the format's mark set large and low-contrast behind the words — the stage's
/// existing visual language, at the reference's geometry.
///
/// It degrades honestly: when real illustrations arrive they drop into exactly
/// this box and nothing else moves.
class _TileCard extends StatelessWidget {
  const _TileCard(
      {required this.tile,
      required this.p,
      required this.hue,
      required this.index});

  /// ⚠️ ONE CONSTANT, READ BY THE RAIL THAT SIZES ITSELF AROUND IT. The rail is
  /// a `SizedBox` and the card is its child, so a height typed in two places is
  /// a clipped title the first time either changes.
  ///
  /// ⚠️ 142, DOWN FROM 158, AND THE FIX IS ARITHMETIC RATHER THAN TASTE.
  ///
  /// 158 was chosen so that two whole cards and a slice of the third would
  /// show, and the intent was right. The sum was wrong, because it forgot the
  /// gap. On a 360dp screen:
  ///
  ///     18 gutter + 158 + 11 gap + 158 = 345
  ///
  /// which leaves 15pt — but the NEXT thing in the rail is another 11pt gap, so
  /// the third card starts at 356 and shows **4 points of itself**. Four points
  /// of a card is not a slice, it is a rendering artefact, and the rail read as
  /// two cards that happened to be clipped: *"the blocks are a little bit more
  /// smaller so that I can actually see that there is something on the right
  /// hand side as well, so that I can actually swipe."*
  ///
  /// So the sum has to include the second gap, and the target is the visible
  /// remainder rather than the card:
  ///
  ///     18 + 142 + 10 + 142 + 10 = 322  ->  38pt of the third card shows
  ///
  /// The reference shows about 19pt of its third card and is legible at that;
  /// 38 is deliberately past it, because a peek that is obvious on a 360dp
  /// phone is merely adequate on a 412dp one.
  ///
  /// ⚠️ THE HEIGHT CAME DOWN WITH THE WIDTH, keeping the 1.24 ratio. A card
  /// narrowed without being shortened is not a smaller card, it is a different
  /// and worse shape.
  static const double height = kTtcRailCardHeight;
  static const double width = kTtcRailCardWidth;

  final TtcTile tile;
  final V2Palette p;
  final double hue;

  /// Position in its rail. Drives the tint step — see below.
  final int index;

  @override
  Widget build(BuildContext context) {
    final paid = tile.format.isPaid;
    // ⚠️ EACH CARD STEPS THE HUE, so a rail reads as separate blocks rather
    // than one long slab of the section's colour. The reference gets this for
    // free because every card carries a different illustration; with flat tints
    // a uniform rail loses the card edges entirely and the eye stops counting
    // them. 22° is enough to separate neighbours and small enough that the rail
    // still belongs to its section.
    //
    // Paid blocks ignore the step and take a fixed warm hue, so a shop card is
    // a different colour before it is a different word.
    final tint = v2BlockTint(paid ? 42 : (hue + index * 22) % 360, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();

    return InkWell(
      onTap: () => openTtcFocusTile(context, tile, hue),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(18),
          border: paid
              ? Border.all(color: deep.withValues(alpha: 0.45), width: 1.5)
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          // The mark, large and quiet, sitting where an illustration would.
          // ⚠️ THE PICTURE FILLS THE BLOCK WHERE THERE IS ONE, and the format
          // mark is the fallback where there is not. Two treatments rather than
          // one because the art is being added a tile at a time — a rail is
          // allowed to mix them, and a card with no picture still has to look
          // deliberate rather than unfinished.
          if (artForTile(tile) != null || photoForTile(tile) != null)
            Positioned.fill(
              child: TtcHeroArt(
                art: artForTile(tile),
                tint: tint,
                imageUrl: photoForTile(tile),
              ),
            )
          else
            Positioned(
              right: -26,
              bottom: 20,
              child: Icon(iconForFormat(tile.format),
                  size: 118, color: Colors.white.withValues(alpha: 0.5)),
            ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The badge, top-left, exactly where the reference puts its
                  // "Video" / "Story" chips.
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: paid
                          ? p.ink1
                          : Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(iconForFormat(tile.format),
                          size: 10,
                          color: paid ? Colors.white : deep),
                      const SizedBox(width: 4),
                      // ⚠️ "Paid" ALONE ON A CARD, not "Masterclass · Paid".
                      // The long form overflowed a 158dp card by 35px the
                      // moment the cards were narrowed — caught by the render
                      // test, not by looking. The chip already carries the
                      // format's icon and the whole block is a different
                      // colour with a border, so the format word was the
                      // redundant half. The full-width tile still spells it
                      // out, where there is room.
                      Flexible(
                        child: Text(paid ? 'Paid' : tile.format.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: paid ? Colors.white : deep)),
                      ),
                    ]),
                  ),
                  const Spacer(),
                  // ⚠️ TITLE ONLY ON THE FACE. The blurb still exists on every
                  // tile and still does its job inside the sheet; on a 200pt
                  // block it would take the title from three lines to one and
                  // turn a scannable rail into a wall.
                  Text(tile.title,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.22,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                ]),
          ),
        ]),
      ),
    );
  }
}

// RETIRED WITH THE FULL-WIDTH `_Tile`. The rail card draws its own badge.
// class _FormatChip extends StatelessWidget {
//   const _FormatChip({required this.tile, required this.p});
//
//   final TtcTile tile;
//   final V2Palette p;
//
//   @override
//   Widget build(BuildContext context) {
//     final paid = tile.format.isPaid;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: paid ? p.ink1 : p.ground,
//         borderRadius: BorderRadius.circular(999),
//         border: paid ? null : Border.all(color: p.line),
//       ),
//       child: Text(
//           // ⚠️ THE WORD "PAID" IS ON THE CHIP, not implied by a colour. A
//           // colour is a convention she has to have learned; the word is not.
//           paid ? '${tile.format.label} · Paid' : tile.format.label,
//           style: pvManrope(
//               fontSize: 9.5,
//               fontWeight: FontWeight.w800,
//               letterSpacing: 0.8,
//               color: paid ? Colors.white : p.ink3)),
//     );
//   }
// }
//
/// The myth, then the fact. Two blocks, never one paragraph.
// ⚠️ RETIRED WITH THE MYTH SHEET, KEPT FOR REVERT. Myth-vs-fact was the last
// format still opening a bottom sheet — missed because it is the SHORTEST
// content on the page, which is exactly the size a sheet feels right for.
// That instinct is the trap: the reader cannot see how long an answer is
// before she taps, only that the chip looks like the others.
//
// The two blocks moved to `TtcMythScreen`, which also sets the claim quieter
// than the correction — see its header.
// class _MythBlock extends StatelessWidget {
//   const _MythBlock(
//       {required this.label, required this.text, required this.myth});
//
//   final String label;
//   final String text;
//   final bool myth;
//
//   @override
//   Widget build(BuildContext context) => Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: myth ? ttcPanel : ttcCoralTint,
//           borderRadius: BorderRadius.circular(ttcCardRadius),
//         ),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(label.toUpperCase(),
//               style: pvManrope(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 1.2,
//                   color: myth ? ttcMuted : ttcCoral)),
//           const SizedBox(height: 7),
//           Text(text,
//               style: ttcBody(14,
//                   color: ttcTitleInk,
//                   h: 1.65,
//                   w: myth ? FontWeight.w400 : FontWeight.w700)),
//         ]),
//       );
// }
//
/// A few cards, swiped, with dots.
///
/// ⚠️ A PAGE VIEW AND NOT A LIST, because "3 things for him" is a promise about
/// a count. A horizontal list of three lets two and a half show, which reads as
/// an arbitrary rail; one card at a time with three dots reads as three things.
class _Carousel extends StatefulWidget {
  const _Carousel({required this.cards});

  final List<TtcCarouselCard> cards;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 240,
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.cards.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            final card = widget.cards[i];
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ttcPanel,
                  borderRadius: BorderRadius.circular(ttcCardRadius),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1} of ${widget.cards.length}',
                          style: pvManrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: ttcMuted)),
                      const SizedBox(height: 10),
                      Text(card.title,
                          style: ttcFraunces(18,
                              w: FontWeight.w600, color: ttcTitleInk)),
                      const SizedBox(height: 9),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(card.body,
                              style: ttcBody(13.5, color: ttcInk, h: 1.65)),
                        ),
                      ),
                    ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < widget.cards.length; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _index ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == _index ? ttcPurple : ttcBorder,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ]),
    ]);
  }
}

/// "Read the longer piece" under a short answer.
// ⚠️ RETIRED WITH THE SHEET IT LIVED IN, KEPT FOR REVERT. This was the
// "Read the full article" button at the foot of the article bottom-sheet.
// The sheet is gone — articles open as screens — and the longer-piece link
// moved onto `TtcFocusArticleScreen` where it belongs.
// class _MoreLink extends StatelessWidget {
//   const _MoreLink({required this.readId});
//
//   final String readId;
//
//   @override
//   Widget build(BuildContext context) => InkWell(
//         onTap: () {
//           Navigator.of(context).pop();
//           openTtcSurface(context, '$kTtcReadPrefix$readId');
//         },
//         borderRadius: BorderRadius.circular(999),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(999),
//             border: Border.all(color: ttcBorder),
//           ),
//           child: Text('Read the full article',
//               style: pvManrope(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w800,
//                   color: ttcPurple)),
//         ),
//       );
// }
//

/// Opens a library read with a picture over its masthead.
///
/// ⚠️ IT DOES NOT GO THROUGH THE SURFACE ROUTER, and that is the one wrinkle
/// worth understanding. The router resolves `ttc_read/<id>` into a
/// `PvReaderScreen` with no hero, because the router is shared by every
/// entrance in the stage and most of them have no picture to offer. A focus
/// card does, so it builds the reader itself and passes one in.
///
/// The route NAME is kept identical to the router's — `ttc_read/<id>` — because
/// `global_ask_fab.dart` reads the route name to decide which Ask Veda opens.
/// Constructing the screen locally and letting the name drift would work
/// perfectly and silently open the wrong assistant.
void openTtcArticle(
  BuildContext context,
  String readId, {
  TtcArt? art,
  String? imageUrl,
  required double hue,
}) {
  final read = ttcReadById(readId);
  // Null is a real answer — an unknown id opens nothing rather than the wrong
  // article. Same call the router makes.
  if (read == null) return;

  final p = V2PaletteStore.instance.current;
  final tint = v2BlockTint(hue, p);
  final lang = TtcLang.instance.hinglish
      ? AppLanguage.hinglish
      : AppLanguage.english;

  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: '$kTtcReadPrefix$readId'),
    builder: (_) => PvReaderScreen(
      read: read,
      lang: lang,
      resolveVideo: ttcVideoBySlot,
      readTitle: ttcReadTitle,
      openRead: (context, id) => openTtcSurface(context, '$kTtcReadPrefix$id'),
      openSurface: openTtcSurface,
      hero: (art == null && (imageUrl == null || imageUrl.isEmpty))
          ? null
          : TtcHeroArt(art: art, tint: tint, imageUrl: imageUrl),
    ),
  ));
}
