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

import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../../models/bracket.dart';
import '../../theme/pv_fonts.dart';
import '../../services/bracket_resolver.dart';
import '../../ttc/ttc_focus_data.dart';
import '../../data/nutrition_data.dart' show kRecipes;
import '../../ttc/ttc_prepare_data.dart';
import '../nutrition/nutrition_recipes_screen.dart' show RecipeDetailScreen;
import '../../widgets/pv_placeholders.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart';
import '../v2/v3_hero_field.dart';
import '../../ttc/ttc_reads_data.dart';
import '../../ttc/ttc_videos_data.dart';
import '../reader/pv_reader_screen.dart';
import 'ttc_common.dart';
import 'ttc_illustrations.dart';
import 'ttc_infographic_screen.dart';
import 'ttc_story_screen.dart';
import 'ttc_prepare_screen.dart';
// Kept for revert: the flat library this door no longer opens. See the note on
// the TtcProductTile case below.
// import 'ttc_products_screen.dart';
import 'ttc_shop_v3.dart';
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

/// How far the sheet is pulled up over a photographic hero.
///
/// ⚠️ IT EXISTS TWICE BY NECESSITY — as space added at the foot of the hero and
/// as the distance the sheet is lifted — so it is one number, not two that have
/// to be kept equal by hand. Get them out of step and either the pink field
/// reappears in the sheet's rounded corners or the page grows a gap.
const double kTtcHeroOverlap = 38;

class TtcFocusScreen extends StatefulWidget {
  const TtcFocusScreen({super.key, required this.page, required this.bracket});

  final TtcFocusPage page;

  /// ⚠️ THE WHOLE BRACKET, NOT A TITLE AND A HUE. The heading is
  /// `bracket.label` — the exact string on the tile she tapped — so the two can
  /// never drift apart. This screen shipped titled "Getting pregnant" behind a
  /// tile reading "Fertile window", and the mismatch reads as having landed on
  /// the wrong screen.
  final Bracket bracket;

  @override
  State<TtcFocusScreen> createState() => _TtcFocusScreenState();
}

class _TtcFocusScreenState extends State<TtcFocusScreen> {
  /// Which selector card is lit. Ignored on a page with no groups.
  ///
  /// ⚠️ NOT PERSISTED, AND IT RESETS TO THE FIRST GROUP EVERY TIME THE DOOR IS
  /// OPENED. "Understand" is the right place to land for someone arriving at
  /// PCOS, and remembering that she last read "What helps" would drop the next
  /// visitor into the middle of the subject — including the visitor who is the
  /// same person a month later with a different question.
  int _group = 0;

  TtcFocusPage get page => widget.page;
  Bracket get bracket => widget.bracket;

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
              child: V3HeroField(
                  accent: tint,
                  ground: p.ground,
                  variant: 1,
                  chroma: v3FieldChroma(hue)),
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
                if (page.groups case final groups?)
                  _Sheet(
                      p: p,
                      // WARNING: A FULL SCREEN, NOT 0.72, AND THIS IS THE OTHER
                      // HALF OF THE BOTTOM BUG.
                      //
                      // Ungrouped, this page is eleven sections and the sheet
                      // always outgrew its minimum. Grouped, it shows ONE group
                      // -- Track is a single rail -- so the sheet stopped
                      // short, the list ended with it, and the field was left
                      // showing under the last card.
                      //
                      // A full viewport is the smallest number that cannot
                      // fail: the hero has already been scrolled past by the
                      // time the sheet's foot is reachable, so a sheet at least
                      // as tall as the screen always reaches the bottom of it,
                      // on any device, for any group.
                      minHeightFactor: 1,
                      children: [
                    const SizedBox(height: 22),

                    // ---- the selector, first thing under the hero --------
                    //
                    // ⚠️ A RAIL, NOT A TAB BAR, AND THE DIFFERENCE IS THE WHOLE
                    // ARGUMENT. A tab bar lights one word and hides four; you
                    // choose before you know what you are choosing between.
                    // These are picture cards in the same language as every
                    // other rail on this page — she reads all five, then picks.
                    // The objection that kept sub-tabs out of this stage was
                    // about choosing blind, and this is not that.
                    //
                        // ⚠️ EXCEPT ON ONE DOOR. Fertile window runs the coverflow
                        // from design 4a instead — all five on a 3D track, one
                        // forward and the rest receding into mist — which is a
                        // real step back toward the shape the paragraph above
                        // rejects. It was chosen with that named, and it is
                        // gated to one bracket so the comparison can be made on a
                        // handset rather than argued. See [_GroupCarousel].
                        if (page.bracketId == kTtcCarouselBracketId)
                          _GroupCarousel(
                            page: page,
                            groups: groups,
                            selected: _group,
                            p: p,
                            onPick: (i) => setState(() => _group = i),
                          )
                        else
                          _GroupRail(
                            page: page,
                            groups: groups,
                            selected: _group,
                            p: p,
                            onPick: (i) => setState(() => _group = i),
                          ),
                    const SizedBox(height: 26),

                    // ⚠️ THE GROUP'S NAME IS NOT REPEATED HERE, AND IT WAS.
                    // Tapping the card marked "Understand" and then reading the
                    // word "Understand" underneath it tells her nothing she did
                    // not just do — and on the tool group it pushed the second
                    // question off the bottom of the screen, which is a real
                    // cost paid for a label. The lit card IS the heading.
                    //
                    // _pad(Text(groups[_group].label, ...)),

                        // ---- a pinned red flag, above everything -----------
                    //
                        // ⚠️ ABOVE THE RAILS AND NEVER IN AN ACCORDION. Two areas
                        // need a warning that is read before anything is chosen —
                        // heavy bleeding after a loss, and thoughts of self-harm.
                        // A rail is a browse surface; a woman scanning cards for
                        // the one that matches her situation has already been
                        // asked to make a choice, and neither of these should wait
                        // for one.
                    //
                        // The text is the article's own `whenToSeeSomeone`. See
                        // `TtcFocusGroup.pinnedRedFlagReadId`.
                        for (final rid in groups[_group].pinnedRedFlagReadIds)
                          if (ttcReadById(rid) case final read?) ...[
                            _pad(
                              _PinnedRedFlag(
                                callout: read.whenToSeeSomeone,
                                lang: TtcLang.instance.hinglish
                                    ? AppLanguage.hinglish
                                    : AppLanguage.english,
                                p: p,
                              ),
                            ),
                            const SizedBox(height: 22),
                          ],

                        // ---- a note that belongs to the tab, if it has one ---
                    //
                        // ⚠️ ABOVE THE RAILS AND BELOW THE FLAGS. A practical
                        // caution sits under a clinical one when both are present,
                        // because the order is the order of consequence. Quiet
                        // type: it is a standing note, not news.
                        if (groups[_group].note case final note?) ...[
                          _pad(
                            Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: p.ink1.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 15,
                                    color: p.ink3,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      note,
                                      style: pvManrope(
                                        fontSize: 12,
                                        height: 1.5,
                                        color: p.ink2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                    // ---- either one tool, or this group's sections -------
                    //
                    // ⚠️ THE TOOL RENDERS HERE, NOT BEHIND A TILE. "Where do I
                    // stand" used to be a card you tapped to leave the page.
                    // A card in front of a tool, inside a group whose only
                    // content is that tool, is a door in front of a door.
                    if (groups[_group].toolSurfaceId case final surface?)
                      ttcInlineToolFor(surface) ??
                          _pad(Text(TtcS.current().estimatesDisclaimer,
                              style: pvManrope(
                                  fontSize: 12, height: 1.5, color: p.ink3)))
                    else
                      for (final section in page.sections
                          .where((s) => s.group == groups[_group].id)) ...[
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

                        // ⚠️ THE CLOSING LINE, UNDER WHATEVER TAB IS OPEN. "Shown
                        // once" in the brief means once per page, not once per tab
                        // — a line that appears only under the last tab is a line
                        // most people never see. See `TtcFocusPage.closingLine`.
                        if (page.closingLine case final line?) ...[
                          _pad(
                            Text(
                              line,
                              style: pvFraunces(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                color: p.ink2,
                          ),
                        ),
                          ),
                          const SizedBox(height: 22),
                        ],

                    _pad(Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 15, color: p.ink3),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(TtcS.current().estimatesDisclaimer,
                                style: pvManrope(
                                    fontSize: 11.5,
                                    height: 1.5,
                                    color: p.ink3)),
                          ),
                        ])),
                      ]),
                if (page.groups == null)
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
    final photo = page.heroImageUrl;

    // WARNING: `Clip.none`, WHICH IS WHAT LETS THE PICTURE RUN PAST THE HERO.
    // See the note on the photo layer below — the whole overlap depends on this
    // Stack not trimming its children to its own box, and the default does.
    return Stack(clipBehavior: Clip.none, children: [
      // ⚠️ THE PHOTOGRAPH IS A LAYER OVER THE FIELD, NOT A REPLACEMENT FOR IT.
      // `errorBuilder` and `loadingBuilder` both return nothing, so a dead
      // connection or a bad URL leaves exactly the hero this page has always
      // had rather than a grey box where a face should be. Local-first is
      // absolute, and here that means the offline version is a finished design
      // rather than a fallback anyone would recognise as one.
      // WARNING: `bottom: -kTtcHeroOverlap`, AND THIS REPLACED A
      // `Transform.translate` THAT COULD NEVER HAVE WORKED.
      //
      // The sheet's rounded top corners are two holes, and something deliberate
      // has to be behind them or the field shows through — reported as a pink
      // border in the corners. The first fix dragged the SHEET up over the
      // hero with a transform and then tried to pay the height back by growing
      // the sheet.
      //
      // That is arithmetically impossible and it is worth writing down why,
      // because it looks like it should work. A transform moves paint and not
      // layout, so a sheet lifted by 38 paints its bottom edge 38 above its
      // layout box. Growing the sheet by 38 to compensate grows the scroll
      // extent by 38 as well, so the gap at the foot of the list survives at
      // exactly its old size. The compensation chases itself. Any fix that
      // stays inside the scrolled child has this shape.
      //
      // So the overlap moves to the layer that can afford it. The photograph is
      // laid out 38 BELOW the hero's own box and simply paints there; the hero
      // keeps its true height, the sheet is laid out immediately after it with
      // no transform at all, and — because a list paints its children in order
      // — the sheet covers the overflow with its rounded edge over picture
      // rather than over field. Nothing is owed at the bottom because nothing
      // was borrowed.
      if (photo != null)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -kTtcHeroOverlap,
          child: Image.network(
            photo,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const SizedBox.shrink(),
        ),
        ),
      // ⚠️ A DARK SCRIM ONLY, AND IT NEVER FADES TO THE PAGE COLOUR.
      //
      // The first version ended this gradient on `p.ground`, so the bottom of
      // the photograph washed out into a pale haze under the type — reported
      // exactly that way: *"that white mist coming out from the bottom of the
      // image"*, and the text over it stopped being readable. It is an easy
      // mistake to make and worth naming: fading a photo into the page colour
      // looks like a clean seam in a design file and looks like fog on a phone,
      // because a real photograph has its own values down there and the fade
      // lands on top of them rather than replacing them.
      //
      // The seam is not this gradient's job anyway. The sheet below is pulled
      // up over the picture and its own rounded edge is the seam.
      //
      // Type over a photograph is unreadable about half the time and you cannot
      // know which half, so the scrim stays — just dark, and heaviest where the
      // words are.
      if (photo != null)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -kTtcHeroOverlap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.52),
                  Colors.black.withValues(alpha: 0.30),
                  Colors.black.withValues(alpha: 0.34),
                ],
                stops: const [0, 0.62, 1],
            ),
          ),
        ),
        ),
      if (photo == null)
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
                // ⚠️ THE PHOTOGRAPH IS GIVEN ROOM HERE, AND NOWHERE ELSE.
                //
                // The hero is a Stack whose size comes from this column, so the
                // only way to make the picture bigger is to make the column
                // taller — there is no height to set on the image itself. Asked
                // for as *"the image can take a little bit more space, I won't
                // mind… so that the text also fits well"*, and the two halves
                // of that are the same lever: a taller hero shows more
                // photograph AND stops the eyebrow, the title and the blurb
                // being crammed against the back button.
                //
                // A fraction of the screen rather than a constant, because a
                // literal that looks generous on a 780pt phone eats a 640pt one
                // — the same class of mistake as the hardcoded `bottom: 96`
                // that `pvNavClearance` exists to undo.
                SizedBox(
                    height: photo == null
                        ? 20
                        : MediaQuery.sizeOf(context).height * 0.10),
                Text(eyebrow.toUpperCase(),
                    style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: photo == null
                            ? p.ink2
                            : Colors.white.withValues(alpha: 0.82))),
                const SizedBox(height: 8),
                // ⚠️ THE AREA'S NAME, NOT A QUESTION — and the same string as
                // the tile, so tapping one name never lands on another.
                //
                // ⚠️ IT STAYS THE BRACKET'S NAME EVEN ON A GROUPED PAGE. The
                // selected group is named lower down, in the sheet, above its
                // own sections. Putting "Understand" up here instead would mean
                // the hero changed identity every time she tapped a card, and
                // the one thing a hero has to do is say which door she is
                // standing in.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(title,
                      style: pvFraunces(
                          fontSize: photo == null ? 27 : 30,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          letterSpacing: -0.6,
                          color: photo == null ? p.ink1 : Colors.white)),
                ),
                if (page.heroBlurb case final blurb?) ...[
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 330),
                    child: Text(blurb,
                        style: pvManrope(
                            fontSize: 13.5,
                            height: 1.55,
                            color: photo == null
                                ? p.ink2
                                : Colors.white.withValues(alpha: 0.92))),
                  ),
                  const SizedBox(height: 6),
                ],
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

/// The five tabs under the hero on a grouped page.
///
/// ⚠️ THIS IS OPTION 4b OF THE "PCOS MODE SWITCHER" DESIGN PROJECT, and it is
/// the fourth shape this control has taken. The three before it are worth
/// keeping in one place, because each was rejected for a different reason and
/// the reasons together are the spec:
///
///   1. **A glyph on a white card** — *"you have just used the icons basic
///      icons, I don't like it."*
///   2. **A drawn mark in a tinted disc**, copied off the home's daily rail —
///      *"a lot of wasted space on that tab… it's all white behind, that's why
///      it looks very empty."*
///   3. **A pill sized to its label** — the retreat from 2, and rejected on
///      sight: *"I did not want it to be like a pill design. I want them to be
///      blocks, obviously tabs."*
///
/// The design's own reading of that history is the useful one: *"the box was
/// never the problem; the problem was five identical pastel boxes in a single
/// clipped row, with nothing saying which one is on."* So 4b keeps the
/// rectangle and the pastel and fixes the three things that were actually
/// wrong — a mark so each box reads as a place rather than a colour, a
/// selected state that goes white and raised against flat neighbours, and a
/// row that stops cutting words in half.
///
/// ⚠️ 108pt SQUARE, AND THE SQUARE IS LOAD-BEARING. It is what lets "Where do
/// I stand" wrap to two lines INSIDE the box instead of being clipped by the
/// screen edge. A pill has to grow sideways to hold a long name; a square
/// grows downward, where there is room. Three and a bit are visible at 360pt.
class _GroupRail extends StatefulWidget {
  const _GroupRail({
    required this.page,
    required this.groups,
    required this.selected,
    required this.p,
    required this.onPick,
  });

  final TtcFocusPage page;
  final List<TtcFocusGroup> groups;
  final int selected;
  final V2Palette p;
  final ValueChanged<int> onPick;

  /// 108 box + 2 above + 8 below, so the selected box's shadow has somewhere to
  /// fall without being clipped by the rail's own bounds.
  static const double height = 118;
  static const double box = 108;

  @override
  State<_GroupRail> createState() => _GroupRailState();
}

class _GroupRailState extends State<_GroupRail> {
  final _controller = ScrollController();
  late List<GlobalKey> _keys =
      List.generate(widget.groups.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(covariant _GroupRail old) {
    super.didUpdateWidget(old);
    if (old.groups.length != widget.groups.length) {
      _keys = List.generate(widget.groups.length, (_) => GlobalKey());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ⚠️ TAPPING PULLS THE BOX INTO VIEW, which the design calls for and which
  /// matters more than it sounds. A half-visible box at the right edge is
  /// tappable, and without this it stays half-visible after being tapped — so
  /// the one tab that is definitely being read is the one the reader can see
  /// least of.
  void _pick(int i) {
    widget.onPick(i);
    final ctx = _keys[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      alignment: 0.5,
    );
  }

  /// The second line. Counted, never typed.
  ///
  /// ⚠️ A HAND-WRITTEN COUNT GOES STALE SILENTLY — nothing fails, the number is
  /// simply wrong, and it is wrong on the one line whose whole job is to be
  /// trusted before a tap.
  String _inside(TtcFocusGroup g) {
    // ⚠️ "Quick check" WAS WRITTEN FOR THE ONLY TOOL GROUP THAT EXISTED. PCOS's
    // "Where do I stand" IS a quick check, so hard-coding the words was fine
    // while it was the only one. Mind & body's Today is a tool group too, and
    // it is not a check of anything — it is two practices and two ticks.
    //
    // Same shape as the `pinnedRedFlagReadId` singular: a value inferred from
    // the first caller. Named per surface now rather than guessed from the
    // fact that a surface exists.
    if (g.toolSurfaceId case final s?) {
      return switch (s) {
        'ttc_mind_today' => 'Today',
        _ => 'Quick check',
      };
    }
    final n = widget.page.sections
        .where((s) => s.group == g.id)
        .fold(0, (t, s) => t + s.tiles.length);
    return n == 1 ? '1 thing' : '$n things';
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    key: kTtcGroupRailKey,
        height: _GroupRail.height,
        // ⚠️ BOTH EDGES FADE RATHER THAN CUT. The design's own diagnosis of the
        // screen it replaced was "a half-cut chip on the left, a half-cut chip
        // on the right, and no way to know there were five". A hard edge reads
        // as a clipping bug; a fade reads as more to come, which is the thing
        // the reader actually needs to know.
        child: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0x00000000),
              Color(0xFF000000),
              Color(0xFF000000),
              Color(0x00000000),
            ],
            stops: [0, 0.045, 0.88, 1],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
            itemCount: widget.groups.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _GroupTab(
              key: _keys[i],
              group: widget.groups[i],
              inside: _inside(widget.groups[i]),
              selected: i == widget.selected,
              p: widget.p,
              onTap: () => _pick(i),
            ),
          ),
            ),
      );
}


/// The hue at full depth — the selected tab's fill.
///
/// ⚠️ SOLVED FOR CONTRAST, NOT PICKED. See the note on [_GroupTab]. The target
/// is 4.8:1 against white: a little over the 4.5 floor, because the label sits
/// at 12.5pt and the count at 10.5pt, and a floor met exactly is a floor that
/// fails the moment someone nudges a size.
Color _deepFor(double hue) {
  const target = 4.8;
  const saturation = 0.44;

  double luminance(double lightness) {
    final c = HSLColor.fromAHSL(1, hue % 360, saturation, lightness).toColor();
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  var lo = 0.05;
  var hi = 0.70;
  for (var i = 0; i < 24; i++) {
    final mid = (lo + hi) / 2;
    // Darker means more contrast, so a mid that is too pale moves the ceiling.
    if (1.05 / (luminance(mid) + 0.05) < target) {
      hi = mid;
    } else {
      lo = mid;
    }
  }
  return HSLColor.fromAHSL(1, hue % 360, saturation, (lo + hi) / 2).toColor();
}

/// One tab. A filled square with a marked well, a name and a count.
///
/// ⚠️ SELECTION IS THE TAB'S OWN HUE GOING DEEP. NO PURPLE, ANYWHERE.
///
/// The design file marks the chosen box with a white fill and a violet 1.5pt
/// edge. That shipped once and came straight back: *"can we have better
/// highlighting over selected one, as in not turning purple or purple outline,
/// find a better way."*
///
/// The objection is right twice over. Purple is the stage ACCENT — it means
/// "this is the action" — and putting it on whichever tab happens to be open
/// says the open tab is a thing to press, which is the one thing it is not. And
/// it is a fifth colour arriving on a control that already has five: five hues
/// resting, then a sixth to say which is on.
///
/// So the hue does the work instead. Every tab carries its group's colour
/// already; the chosen one simply **takes that colour at full depth** and wears
/// white type, while the others stay at the pale tint. One hue, two strengths,
/// no new colour introduced — the same relationship `V3DailyArt` uses between a
/// tinted well and its mark, and `ttcPhaseMark` between a band and its dot.
///
/// It also reads better than an outline for a plain physical reason: a 1.5pt
/// edge is 1.5pt of signal that disappears at arm's length or in sunlight,
/// while a solid block of colour is the whole box.
///
/// ⚠️ THE DEEP LIGHTNESS IS SOLVED PER HUE, NOT FIXED. A single lightness looks
/// consistent in code and is not: at L .42 white type clears 4.5:1 on the blue
/// and the rose and fails it on the sage, the sand and the teal — measured at
/// 3.4, 3.9 and 3.4. Yellow-greens carry far more luminance than blues at the
/// same number, which is the same trap as `v3FieldChroma`, one channel over.
///
/// [_deepFor] therefore solves for the lightness that puts every hue at the
/// same contrast against white. The five fills are different colours of equal
/// weight, and a group added later is legible without anyone checking.
///
/// ⚠️ IT STILL ANSWERS THE FINGER. Asked for separately and kept through every
/// reshape, because it is the only feedback that arrives before the rebuild:
///
///   · **It shrinks while held** — a control that does not move under a thumb
///     reads as a picture of a control.
///   · **The phone ticks** — `selectionClick`, the light one a picker uses.
///     `mediumImpact` would be a notification, and changing tab is not an
///     event.
///   · **Fill, edge and shadow cross-fade** over 180ms, so the selection moves
///     rather than teleports and the eye can follow which box took it.
class _GroupTab extends StatefulWidget {
  const _GroupTab({
    super.key,
    required this.group,
    required this.inside,
    required this.selected,
    required this.p,
    required this.onTap,
  });

  final TtcFocusGroup group;

  /// The second line — "8 things", "Quick check". Counted by the rail.
  final String inside;

  final bool selected;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  State<_GroupTab> createState() => _GroupTabState();
}

class _GroupTabState extends State<_GroupTab> {
  bool _held = false;

  void _hold(bool v) {
    if (_held != v && mounted) setState(() => _held = v);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final on = widget.selected;
    final tint = v2BlockTint(widget.group.hue % 360, p);
    final deep = _deepFor(widget.group.hue);

    return Semantics(
      selected: on,
      button: true,
      label: '${widget.group.label}, ${widget.inside}',
      child: GestureDetector(
        onTapDown: (_) => _hold(true),
        onTapCancel: () => _hold(false),
        onTapUp: (_) => _hold(false),
        onTap: on
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onTap();
              },
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _held ? 0.95 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: _GroupRail.box,
            height: _GroupRail.box,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: on ? deep : tint,
              borderRadius: BorderRadius.circular(16),
              // ⚠️ NO BORDER IN EITHER STATE. An outline was the old signal and
              // it is gone; leaving a transparent one behind would keep 1.5pt
              // of padding that only one state ever used, and the two would sit
              // at different sizes.
              boxShadow: on
                  ? [
                      // The shadow is the hue's own, not black. A coloured
                      // block casting a grey shadow reads as a sticker on the
                      // page rather than a part of it.
                      BoxShadow(
                        color: deep.withValues(alpha: 0.30),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // ⚠️ THE WELL STAYS PALE IN BOTH STATES, which is what
                    // keeps the mark readable once the box goes dark. Filling
                    // it with the tint would put a pastel on a deep ground of
                    // the same hue — two neighbouring values of one colour,
                    // which is the hardest pair for an eye to separate.
                    color: Colors.white.withValues(alpha: on ? 0.92 : 0.72),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(widget.group.icon,
                      size: 20, color: on ? deep : p.ink2),
                ),
                // ⚠️ `Flexible`, BECAUSE A LONG NAME IS THE POINT OF THE SQUARE.
                // "Where do I stand" wraps to two lines here; without this the
                // column overflows by a few points and paints a stripe.
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.group.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 12.5,
                              height: 1.2,
                              letterSpacing: -0.2,
                              fontWeight:
                                  on ? FontWeight.w800 : FontWeight.w600,
                              color: on ? Colors.white : p.ink2)),
                      const SizedBox(height: 2),
                      Text(widget.inside,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: on
                                  ? Colors.white.withValues(alpha: 0.82)
                              : p.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  _GroupCarousel — the tabs as design 4a's coverflow, "mist falloff"
// -----------------------------------------------------------------------------
//  Design source: "Health Cards Options" turn 4, option **4a** — "Carousel ·
//  mist falloff", which is 3a revised from a device shot. Five cards on one 3D
//  track, ALL FIVE ON SCREEN: the chosen one flat and forward, and the row
//  receding on both sides in three steps — the neighbour at 0.80 scale and 92%
//  opacity, the one behind it at 0.60 and 72%, each pushed further out and
//  tilted a little more, with a light blur that grows with depth and a tint
//  that deepens as it recedes, so distance never means invisible. Both edges of
//  the track fade to 45%, so the far cards soften rather than being sliced by
//  the screen. Under the track, five dots. On each card, 3a's layered mark —
//  a soft radial disc, two hairline arcs, a dot cluster and a hairline horizon,
//  each rotated a little differently per group, with the group's icon at the
//  centre — and the mark drifts a few points sideways as its card turns.
//
//  ⚠️ WHAT 4a CHANGED FROM 3a, so the numbers below are read as decisions:
//
//    · the far pair is no longer hidden. 3a faded everything past the
//      neighbours to nothing, which made the dot row the only route to two of
//      five groups. 4a keeps them on the track, small and misted, so every
//      group is visible from every position. The dot row stays, as a counter
//      and a one-tap route to the back of the ladder.
//    · the cards are smaller — 172×132, was 196×150 — and the track shorter,
//      146 instead of 160, because on the device the neighbours were nearly
//      the size of the centre and the row read as three competing cards.
//    · the track CLIPS AND FADES at its edges, where 3a let the neighbour
//      overhang the screen. A card cut off by the phone's edge is a card cut
//      off; a card softening into mist is distance.
//    · the ring on the front card is a soft tinted rim, not a hard outline in
//      the deep hue.
//
//  It runs on ONE door. `kTtcCarouselBracketId` gates it to Fertile window; the
//  other six keep [_GroupRail], which is live code and not a revert stub.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THREE WAYS TO BUILD THIS THAT DO NOT WORK, ALL OF THEM TRIED HERE FIRST
//  ---------------------------------------------------------------------------
//
//  Every one of them compiles, renders, and looks plausible in a still frame.
//  They are written down because the failure in each case is invisible until
//  the thing is in a hand.
//
//  **1. `AnimatedContainer(transform: …)`.** The obvious move, and it destroys
//  the effect. `Matrix4Tween` interpolates by calling `Matrix4.decompose` —
//  translation, quaternion, scale — which has nowhere to put a perspective row.
//  So every intermediate frame is drawn FLAT, and the cards slide about in 2D
//  before snapping into depth at the end. The lesson generalises: a matrix
//  tween is an affine tween, and perspective is not affine.
//
//  **2. Reordering `Stack` children without keys.** The cards have to be
//  painted far-to-near (a `Stack` has no z-index, so paint order IS the
//  z-index), and that order changes every time the selection moves. With no
//  keys, Flutter matches children by slot: the element in slot 0 is reused for
//  whichever card is now furthest away, so its state and its animation belong
//  to the previous occupant. Nothing travels — the tiles simply change. This is
//  the bug that made the first cut of this screen read as having no motion at
//  all, and it needs both fixes together, because (1) hides it.
//
//  **3. Discrete state plus a transition.** 3a itself is written this way
//  because CSS has to be: an integer index, and `transition: transform .45s` to
//  cover the jump. Ported literally it gives a control that ignores the finger
//  until a threshold trips and then animates on its own — which is a slideshow,
//  not a track.
//
//  So: ONE `double` is the state. [_position] is the fractional index of the
//  card in the middle; every card's transform, opacity, scale, tilt, blur and
//  tint are computed from it each frame, and dragging moves it directly. 4a's
//  numbers are the values at whole positions, and the in-between frames are the
//  thing CSS was approximating.
//
//  **4. `Transform(filterQuality: …)` while moving.** Flutter's own cure for
//  text shimmering under an animated scale — `ScaleTransition` does it — and
//  it was tried here for exactly that. With a `filterQuality` set, the card is
//  drawn flat into a bitmap and the matrix goes through `ImageFilter.matrix`
//  instead of the canvas. On the device that bitmap path did NOT draw the
//  perspective the vector path draws: the neighbours came out larger and
//  further apart, the back pair further still. Switching it on for the glide
//  and off at rest then meant the track settled, and then settled AGAIN as the
//  render path swapped under it — and any swipe that ended on a cancelled drag
//  left the flag on, so some rests kept the wrong geometry. Two layouts at
//  rest, chosen by the gesture that got you there. Screenshots 2026-09-07.
//
//  The general fact: a widget that renders one way in motion and another at
//  rest has two geometries, and every difference between the two paths is a
//  "settle" the eye will see. Pick one path.
//
//  ---------------------------------------------------------------------------
//  The geometry, and why it is CSS's rather than an approximation of it
//  ---------------------------------------------------------------------------
//
//  4a writes the transform per step `a = |o|`, with `s = sign(o)`:
//
//      translateX(s · (96 + (a−1)·74))   — 0, ±96, ±170
//      translateZ(−a · 60)               — 0, −60, −120
//      translateY(a · 8)                 — the ladder steps down as it recedes
//      rotateY(−s · (24 + (a−1)·8)deg)   — 0, ∓24°, ∓32°
//      rotateX(a ? 3deg : 0)
//      scale(1, .8, .6)
//
//  under `perspective: 1000px`, where `o` is the signed distance round the
//  ring. Every one of those is a straight line between its whole-step values,
//  and [_CarouselCard] evaluates the line rather than the steps — so `scale` is
//  `1 − 0.2·a` throughout, and the sideways travel changes slope at `a = 1`
//  (96 for the first step, 74 for the second) exactly as 4a's table does.
//
//  Two things have to be right for that to survive the port:
//
//   1. **Multiplication order.** CSS applies a transform list left-to-right as
//      matrix multiplication — `T · Ry · Rx · S`. Matrix4's cascade
//      post-multiplies in the same order, so `..translate()..rotateY()
//      ..rotateX()..scale()` is not merely similar to the CSS, it is the same
//      matrix.
//
//   2. **The sign on the perspective entry.** Flutter's usual flip-card recipe
//      is `setEntry(3, 2, 0.001)`, which gives `w = 1 + z/1000` — positive z
//      recedes. CSS is `w = 1 - z/d`, where positive z comes TOWARD you. Using
//      the Flutter idiom with CSS's numbers therefore inverts the depth: the
//      neighbours come forward and the chosen card sinks. That still animates
//      and still looks deliberate, so it would not have been caught by looking
//      at it. `-1 / 1000` keeps CSS's convention, which is what lets every
//      other number in the design be copied across unchanged.
//
//  With CSS's convention restored, `Matrix4.rotateY` and `rotateX` match CSS's
//  signs for free — both send a point at +x toward −z, and a point at +y (the
//  card's foot) toward +z — so the tilts are written exactly as 4a has them.
//
//  The blur is applied INSIDE the transform, as CSS does: `filter` is rendered
//  in the element's own space and the transform is applied to the result, so a
//  card at 0.6 scale carries a blur that is 0.6 as wide on screen. Putting the
//  `ImageFiltered` outside the `Transform` would blur in screen space and the
//  far cards would be softer than the design.
//
//  The general fact, worth more than this screen: porting a transform is not
//  porting the numbers. It is porting the numbers PLUS the coordinate
//  convention they were written against, and the convention is the half nobody
//  writes down.
// =============================================================================

/// The one door that opens on the carousel.
const String kTtcCarouselBracketId = 'ttc_conceiving';

/// ⚠️ THESE KEYS EXIST SO THE WIRING CAN BE ASSERTED, AND THAT IS THE ONLY
/// REASON. Two shapes of the same control now ship side by side behind a
/// bracket id; without a marker, a test can prove `kTtcCarouselBracketId` says
/// `'ttc_conceiving'` and prove nothing at all about which widget the door
/// actually builds — the exact "correct but unreachable" shape this repo keeps
/// hitting. `ttc_focus_carousel_test.dart` reads both.
const Key kTtcGroupCarouselKey = Key('ttc-group-carousel');
const Key kTtcGroupRailKey = Key('ttc-group-rail');

/// One dot, addressable. The far pair sits at the back of the ladder, two
/// swipes away by drag, so the dot is the only one-tap route to it.
Key ttcCarouselDotKey(int i) => ValueKey('ttc-carousel-dot-$i');

/// One side of the track — `-1` for the card on the left, `1` for the right.
///
/// Named rather than found by position because the zones are transparent, and a
/// test aiming at a coordinate would be asserting the geometry by accident.
Key ttcCarouselZoneKey(int step) => ValueKey('ttc-carousel-zone-$step');

/// Card size. 4a draws a 172×132 landscape card in a 390pt frame — down from
/// 3a's 196×150, because on the device the neighbours were nearly the size of
/// the centre and the row read as three competing cards.
///
/// ⚠️ FIXED, NOT PROPORTIONAL. At 360pt — the narrowest screen this app is
/// designed against, [kPvNarrowestScreen] — the back pair run past the edge of
/// the track and are cut by its mask, which fades to 45% there so the cut
/// reads as mist rather than as an edge. Pinching the numbers until all five
/// fit would flatten the ladder into a row.
const double kTtcCarouselCardWidth = 172;
const double kTtcCarouselCardHeight = 132;

/// The track's height — 4a's 146 — and where in it the cards sit. The cards are
/// laid out 4pt down and step down a further 8 per place round the ring, so
/// the back pair sit lowest; the shadow under the front card takes the rest.
const double kTtcCarouselTrackHeight = 146;
const double _cardTop = 4;

/// 4a's edge fade: 45% at the edge, 82% a tenth of the way in, solid across
/// the middle 44%. The values are the design's; they are what makes the back
/// pair soften into the sheet rather than stop at the screen.
const List<double> _edgeFadeStops = [0, .10, .28, .72, .90, 1];
const List<double> _edgeFadeAlphas = [.45, .82, 1, 1, .82, .45];

class _GroupCarousel extends StatefulWidget {
  const _GroupCarousel({
    required this.page,
    required this.groups,
    required this.selected,
    required this.p,
    required this.onPick,
  });

  final TtcFocusPage page;
  final List<TtcFocusGroup> groups;
  final int selected;
  final V2Palette p;
  final ValueChanged<int> onPick;

  /// The track, 4a's 12pt under it, and the dot row with its tap padding. One
  /// number, so the sheet's spacing does not have to know the parts — the same
  /// reason [_GroupRail.height] is 118 and not 108.
  ///
  /// The dot row is 5pt of dot inside 7pt of transparent target above and
  /// below, so the 12pt gap in the design is 5pt of spacer plus the top 7.
  static const double height =
      kTtcCarouselTrackHeight + _dotGap + _CarouselDots.height;

  static const double _dotGap = 12 - _CarouselDots.tapPad;

  @override
  State<_GroupCarousel> createState() => _GroupCarouselState();
}

class _GroupCarouselState extends State<_GroupCarousel>
    with SingleTickerProviderStateMixin {
  /// ⚠️ THE WHOLE STATE OF THE TRACK, AND IT IS A `double` ON PURPOSE.
  ///
  /// The fractional index of the card in the middle. At 1.0 the second card is
  /// square on; at 1.5 the track is exactly halfway between two cards, with
  /// both turned 16° and neither in front. Dragging writes to it directly, so
  /// the cards follow the finger instead of waiting for it to finish.
  ///
  /// It is allowed outside `[0, count)` while a drag or a settle is running —
  /// `_offsetOf` wraps, so −0.4 and 4.6 describe the same picture. It is
  /// normalised on settle, so it cannot wander after a hundred swipes.
  late double _position = widget.selected.toDouble();

  /// ⚠️ BUILT IN `initState`, NOT `late final`. A `late final` controller is
  /// only constructed on first use — and if the door is opened and closed
  /// without the track ever moving, that first use is `dispose()` itself, which
  /// then builds a `Ticker` against an element that is already deactivated and
  /// throws "Looking up a deactivated widget's ancestor is unsafe". A lazy
  /// field whose initialiser reads the element tree is a lazy field that can
  /// run at the worst possible moment.
  late final AnimationController _settle;
  late final CurvedAnimation _curve;

  /// Where the current settle started and where it is going. Plain fields, not
  /// a `Tween` rebuilt per settle — see the note on [_settleTo].
  double _from = 0;
  double _to = 0;

  int get _count => widget.groups.length;

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(
      vsync: this,
      // 4a's .48s, and it is the number that makes the track feel like objects
      // rather than a slideshow: long enough to read the turn, short enough
      // that a second swipe never has to wait.
      duration: const Duration(milliseconds: 480),
    );
    // Leaves fast, arrives slowly — 4a's cubic-bezier(.2,.8,.2,1), so the eye
    // can follow which card took the middle instead of finding it there.
    _curve = CurvedAnimation(parent: _settle, curve: Curves.easeOutCubic);
    // ⚠️ ONE LISTENER, ADDED ONCE. The first cut built a fresh `Tween` and
    // called `addListener` inside `_settleTo`, which never removed the previous
    // one — so a door left open through twenty swipes was running twenty
    // `setState`s per frame, all writing the same value. Nothing looked wrong;
    // it just got slower the longer you stayed.
    _settle.addListener(
        () => setState(() => _position = _from + (_to - _from) * _curve.value));
    // ⚠️ AND THE NORMALISATION THE DOC COMMENT ON [_position] HAS ALWAYS
    // CLAIMED, WHICH UNTIL NOW DID NOT EXIST. Every settle target is
    // `_position + _offsetOf(target)` — the short way round, which is what
    // makes the ring a ring — so the position moves by ±1 per step and NEVER
    // comes back. Swipe one way six times and it is at 6, or −6.
    //
    // Nothing about the cards notices, because `_offsetOf` wraps: 6 and 1
    // describe the same picture, exactly. So the bug hid behind the very
    // mechanism that makes the loop work, and it took a two-lap test to see —
    // one step from a fresh position is always correct.
    //
    // What it broke was downstream: [_CarouselDots] reduced its distance with
    // `if (o > n/2) o = n - o`, which is only right while the position is
    // inside one lap. At −6 that returns a negative distance for every dot,
    // every dot clamps to fully lit, and the counter stops naming the open
    // card. Both halves are fixed — the position is brought back into
    // `[0, count)` here, and the dots no longer assume it.
    _settle.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      final wrapped = _position - _count * (_position / _count).floorToDouble();
      if (wrapped == _position) return;
      // Subtracting whole laps changes nothing on screen — every offset is
      // taken modulo the count — so this is invisible, which is the point.
      setState(() => _position = _from = _to = wrapped);
    });
  }

  @override
  void didUpdateWidget(covariant _GroupCarousel old) {
    super.didUpdateWidget(old);
    if (old.selected == widget.selected) return;
    // The selection can move from outside — a rebuild with a different door,
    // or the parent answering our own [_land]. Glide to it rather than
    // jumping — and ONLY if the track is not already on its way there.
    //
    // ⚠️ THE FIRST CUT SPUN THE RING, AND EVERY TEST PASSED. `_land` settles
    // the short way round and tells the parent; the parent rebuilds; this ran
    // `_settleTo(widget.selected.toDouble())` — to 4.0 as a plain number, from
    // a position near 0. The settle it replaced was going 0 → −1, one card
    // left; the new one went 0 → 4, four cards right, through every card on
    // the track. The end state was right, so the content tests passed, and
    // the dot row landed on the right dot. It only showed on a handset, as a
    // track that "wasn't a loop".
    //
    // Two rules fall out. A settle target is a position on an unbounded line,
    // never an index — so it is always `_position + _offsetOf(index)`, the
    // short way round. And an instruction that says where we already are, or
    // where we are already going, is not a new instruction.
    final heading = _settle.isAnimating ? _to : _position;
    final headingIndex = ((heading.round() % _count) + _count) % _count;
    if (headingIndex != widget.selected) {
      _settleTo(_position + _offsetOf(widget.selected));
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _settle.dispose();
    super.dispose();
  }

  /// The signed distance from the middle of the track to card [i], the short
  /// way round the ring.
  ///
  /// ⚠️ IT WRAPS, so card five is one step from card one rather than four. That
  /// is 3a's behaviour and it is what makes the track continuous — without it
  /// the last card is a wall, and a fan of cards with a wall at one end is a
  /// list drawn in perspective.
  double _offsetOf(int i) {
    final half = _count / 2;
    var o = i - _position;
    while (o > half) {
      o -= _count;
    }
    while (o < -half) {
      o += _count;
    }
    return o;
  }

  /// Glide the track to [target] and tell the screen which card won.
  ///
  /// ⚠️ THE TWEEN RUNS ON THE POSITION, NOT ON THE MATRIX. See failure (1) in
  /// the header: interpolating the matrix itself flattens every frame between
  /// the two ends, because a matrix tween decomposes and perspective does not
  /// survive being decomposed. Interpolating the one number the matrix is built
  /// from means every frame is a real perspective frame.
  void _settleTo(double target) {
    _from = _position;
    _to = target;
    _settle
      ..reset()
      ..forward();
  }

  /// ⚠️ EVERY ROUTE TO A NEW CARD GOES THROUGH HERE — a zone, a dot, the end of
  /// a drag — so the haptic cannot be wired to two of the three and forgotten
  /// on the last. `selectionClick` is the light one a picker uses;
  /// `mediumImpact` would read as a notification, and changing tab is not one.
  void _land(int i) {
    final target = ((i % _count) + _count) % _count;
    // Settle even when the group has not changed: a drag that did not travel
    // far enough still has to put the track back where it was.
    _settleTo(_position + _offsetOf(target));
    if (target == widget.selected) return;
    HapticFeedback.selectionClick();
    widget.onPick(target);
  }

  void _step(int direction) => _land(widget.selected + direction);

  // ---- the drag -------------------------------------------------------------
  //
  // ⚠️ THE TRACK FOLLOWS THE FINGER. 4a advances a whole card once a 28pt
  // threshold trips, because CSS cannot do better; ported literally that gives
  // a control which ignores you and then moves by itself. Here the drag writes
  // straight to [_position], so the cards turn as the thumb moves and the
  // gesture can be taken back halfway.

  void _dragStart(DragStartDetails _) {
    _settle.stop();
    _dragFrom = _position;
  }

  /// Where the track was when the finger landed, so [_dragEnd] can tell a
  /// drag that has already crossed into the next card from one that has not.
  double _dragFrom = 0;

  void _dragUpdate(DragUpdateDetails d) {
    // ⚠️ A CARD'S WIDTH OF FINGER IS A CARD'S WORTH OF TURN. The first cut
    // divided by the neighbour's 96pt of sideways travel, so the front card
    // tracked the neighbour's centre exactly — and a thumb's ordinary swipe,
    // 250pt or so, spun the ring two and a half cards. Faithful, and twitchy.
    // Dividing by the card's own width means the card under the thumb moves
    // with the thumb, which is the thing a finger actually expects, and a
    // full swipe is one card with a little to spare.
    setState(() => _position -= d.delta.dx / kTtcCarouselCardWidth);
  }

  void _dragEnd(DragEndDetails d) {
    // ⚠️ A FLICK COUNTS AS ONE CARD, NEVER MORE, which is what stops a fast,
    // short swipe dying halfway — and what stops a fast, long one overshooting.
    // Velocity is in points per second; three cards' worth a second is about
    // the speed at which a gesture reads as a throw rather than a nudge. The
    // flick is only added if the drag has not already crossed into the next
    // card, so a long throw lands one card on, not two.
    final v = d.velocity.pixelsPerSecond.dx;
    final crossed = _position.round() - _dragFrom.round();
    final flick = v.abs() > kTtcCarouselCardWidth * 3 && crossed == 0
        ? (v < 0 ? 1 : -1)
        : 0;
    _land(_position.round() + flick);
  }

  /// Indices sorted far-to-near.
  ///
  /// A `Stack` has no z-index, so PAINT ORDER IS THE Z-INDEX — this sort is the
  /// whole of 4a's `z: 10 - a`. See failure (2) in the header for why every
  /// card that comes out of here must also carry a key.
  List<int> _paintOrder() {
    final order = List<int>.generate(_count, (i) => i);
    order.sort((a, b) => _offsetOf(b).abs().compareTo(_offsetOf(a).abs()));
    return order;
  }

  /// The second line. Counted, never typed — same rule and same reason as
  /// [_GroupRailState._inside], which see.
  String _inside(TtcFocusGroup g) {
    if (g.toolSurfaceId case final s?) {
      return switch (s) {
        'ttc_mind_today' => 'Today',
        _ => 'Quick check',
      };
    }
    final n = widget.page.sections
        .where((s) => s.group == g.id)
        .fold(0, (t, s) => t + s.tiles.length);
    return n == 1 ? '1 thing' : '$n things';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return SizedBox(
      key: kTtcGroupCarouselKey,
      height: _GroupCarousel.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: _dragStart,
        onHorizontalDragUpdate: _dragUpdate,
        onHorizontalDragEnd: _dragEnd,
        onHorizontalDragCancel: () => _land(_position.round()),
        child: Column(
          children: [
            SizedBox(
              height: kTtcCarouselTrackHeight,
              child: Stack(
                children: [
                  // ---- the picture ---------------------------------------
                  //
                  // ⚠️ THE TRACK CLIPS, AND THE CLIP IS DRESSED AS MIST. 3a let
                  // the neighbour overhang the screen and called the overhang
                  // the design; 4a masks the track instead — `mask-image:
                  // linear-gradient(90deg, .45, .82 10%, 1 28%, 1 72%, .82
                  // 90%, .45)` — so the back pair fade into the sheet at the
                  // sides rather than being sliced by the phone.
                  //
                  // Why `ClipRect` AND `ShaderMask`, when CSS needs only the
                  // mask: a CSS mask is clipped to the element's box, so a
                  // pixel outside the track is simply not drawn. Flutter's
                  // `ShaderMask` draws its gradient over the widget's own
                  // rect and leaves anything painted OUTSIDE that rect alone
                  // — so without the clip, the part of a far card that runs
                  // past the track's edge would come through at full
                  // strength, sharp, exactly where the design wants it
                  // faintest. The clip is the half of `mask-image` that
                  // Flutter does not do for you.
                  //
                  // `BlendMode.dstIn` keeps the child's colour and multiplies
                  // its alpha by the gradient's — the card is the destination
                  // and the gradient is the source, and "in" keeps the
                  // destination where the source is.
                  //
                  // ⚠️ AND NOTHING HERE TAKES A TAP. A perspective-transformed
                  // widget in Flutter is tappable somewhere other than where it
                  // is painted: `RenderTransform` paints with the full matrix
                  // but hit-tests through `PointerEvent.removePerspective-
                  // Transform`, which clears only row 2 and column 2 — and
                  // `rotateY` couples x into z, leaving a residue at entry
                  // [3][0] that nothing strips. Measured on the neighbour card,
                  // a tap aimed at the middle of the label lands about 18pt to
                  // its right in card-local space, past the end of a short
                  // word. So the track is a picture, and the untransformed
                  // zones below take the taps.
                  //
                  // The general fact: painting and hit testing are two passes
                  // over the same tree that do not have to agree, and 3D is
                  // where they stop agreeing.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRect(
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (rect) => LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: _edgeFadeStops,
                            colors: [
                              for (final a in _edgeFadeAlphas)
                                Colors.black.withValues(alpha: a),
                            ],
                          ).createShader(rect),
                          child: Padding(
                            padding: const EdgeInsets.only(top: _cardTop),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                for (final i in _paintOrder())
                                  _CarouselCard(
                                    // ⚠️ THE KEY IS LOAD-BEARING, NOT
                                    // TIDINESS. The list above is re-sorted
                                    // every frame; without an identity,
                                    // Flutter reuses each slot's element for
                                    // whatever card now occupies it. See
                                    // failure (2) in the header.
                                    key: ValueKey(widget.groups[i].id),
                                    group: widget.groups[i],
                                    inside: _inside(widget.groups[i]),
                                    offset: _offsetOf(i),
                                    count: _count,
                                    index: i,
                                    held: _heldStep != 0 &&
                                        _offsetOf(i).round() == _heldStep,
                                    p: p,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ---- the two side targets ------------------------------
                  //
                  // The middle is the width of the front card, which sits at
                  // z 0 and is therefore drawn at its true size — the one card
                  // whose painted width IS [kTtcCarouselCardWidth]. The sides
                  // take whatever the screen has left, so on a narrow phone
                  // they stay usable rather than shrinking with the
                  // foreshortened card they stand for.
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          child: _CarouselZone(
                            key: ttcCarouselZoneKey(-1),
                            step: -1,
                            group: widget.groups[_indexAt(-1)],
                            onHold: _hold,
                            onTap: () => _step(-1),
                          ),
                        ),
                        // ⚠️ INERT ON PURPOSE, AND STILL PRESENT. The front
                        // card is already chosen, so there is nothing for a tap
                        // to do — but the gap has to exist to stop the side
                        // zones meeting in the middle, where a tap on the front
                        // card would swing the track sideways for no reason the
                        // reader could name.
                        const SizedBox(width: kTtcCarouselCardWidth),
                        Expanded(
                          child: _CarouselZone(
                            key: ttcCarouselZoneKey(1),
                            step: 1,
                            group: widget.groups[_indexAt(1)],
                            onHold: _hold,
                            onTap: () => _step(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _GroupCarousel._dotGap),
            _CarouselDots(
              groups: widget.groups,
              position: _position,
              selected: widget.selected,
              p: p,
              onPick: _land,
            ),
          ],
        ),
      ),
    );
  }

  /// Which side is being pressed, so the card behind it can answer the finger.
  ///
  /// −1 or +1 while a side zone is held, 0 otherwise. It lives up here rather
  /// than in the card because the zone and the card it presses are now two
  /// different widgets — the cost of the hit-testing note above, paid in one
  /// field.
  int _heldStep = 0;

  void _hold(int v) {
    if (_heldStep != v && mounted) setState(() => _heldStep = v);
  }

  /// The group [step] places round the ring from the chosen one.
  int _indexAt(int step) => (widget.selected + step + _count) % _count;
}

/// One side of the track: a transparent target that brings the card on that
/// side forward.
///
/// ⚠️ IT CARRIES THE SEMANTICS FOR THE CARD IT STANDS FOR. The cards themselves
/// sit under an `IgnorePointer` and are no longer buttons, so without this a
/// screen reader would find a track it could not operate. The label names the
/// group the tap would open, not "previous" or "next" — a direction is only
/// useful to someone who can already see what is on either side.
class _CarouselZone extends StatelessWidget {
  const _CarouselZone({
    super.key,
    required this.step,
    required this.group,
    required this.onHold,
    required this.onTap,
  });

  final int step;
  final TtcFocusGroup group;
  final ValueChanged<int> onHold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: group.label,
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => onHold(step),
          onTapCancel: () => onHold(0),
          onTapUp: (_) => onHold(0),
          onTap: onTap,
        ),
      );
}

// =============================================================================
//  The layered mark
// -----------------------------------------------------------------------------
//  3a's turn-3 note, in full: *"the flat tint blob is replaced by a layered
//  mark — a soft radial disc, two hairline concentric arcs, a small dot cluster
//  and a hairline horizon, each rotated a little differently per category, with
//  the kit icon still at the centre."*
//
//  Five parts, drawn in a 96×96 space and painted at 86, all of them from the
//  group's own hue:
//
//    · a radial disc, r 33, lit off-centre at (38%, 30%) — light → mid
//    · a hairline ring, r 41, at 22% — the disc's edge, a little outside it
//    · a broken arc across the top, r 39, at 34%, dashed 86-on 200-off
//    · a second arc under it, r 34, at 28%, springing the other way
//    · three dots of falling size, at 50% / 35% / 28%
//
//  and outside the rotation, a horizon: a shallow curve across the foot at 30%.
//
//  ⚠️ THE ROTATION IS PER GROUP AND IT IS THE WHOLE TRICK. `i * 26 - 12`
//  degrees. Five cards carrying the SAME drawing in five colours read as one
//  thing tinted five ways; the same drawing turned five ways reads as five
//  places. It costs one number and it is the difference between a palette and
//  a set of marks.
//
//  ⚠️ AND THE DOT CLUSTER IS SEEDED PER GROUP, NOT RANDOM. 3a lists the six
//  coordinates by hand. A `Random()` here would redraw the mark on every
//  rebuild — the card would shimmer as the track moved, which is the kind of
//  thing that gets diagnosed as a rendering bug three months later.
// =============================================================================

/// 3a's hand-listed dot positions, per group: (x, y) three times over.
const List<List<double>> _kMarkDots = [
  [74, 24, 84, 40, 66, 12],
  [22, 26, 12, 42, 32, 15],
  [72, 74, 84, 60, 62, 86],
  [26, 72, 14, 58, 36, 84],
  [76, 46, 86, 62, 70, 30],
];

/// The mark's palette, straight off 3a: the same hue at four strengths.
///
/// ⚠️ NOT ROUTED THROUGH `v2BlockTint`. Those are the app's BLOCK tints, solved
/// for a large flat panel; the mark needs a light and a mid that sit within a
/// few percent of each other or the disc turns into a bullseye. These are the
/// design's own numbers, and the only one that leaves this file is the deep —
/// which stays [_deepFor], because it is the one that has to clear 4.5:1
/// against white type on the front card.
Color _markLight(double h) => HSLColor.fromAHSL(1, h % 360, 0.46, 0.93).toColor();
Color _markMid(double h) => HSLColor.fromAHSL(1, h % 360, 0.30, 0.82).toColor();
// Kept for revert: 3a's card field was `_markLight → _markTint`, fixed per
// card. 4a's field deepens with distance instead, so [_CarouselCard] now
// computes both stops from the card's own offset and this stop went unused.
// Color _markTint(double h) => HSLColor.fromAHSL(1, h % 360, 0.32, 0.91).toColor();

class _CarouselMark extends CustomPainter {
  const _CarouselMark({required this.hue, required this.index});

  final double hue;
  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    // Everything below is written in 3a's 96-unit space and scaled once, so the
    // numbers in the code are the numbers in the design file.
    canvas.scale(size.width / 96);
    final deep = _deepFor(hue);
    final d = _kMarkDots[index % _kMarkDots.length];
    const c = Offset(48, 48);

    Paint hair(double width, double opacity) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = deep.withValues(alpha: opacity);

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate((index * 26 - 12) * math.pi / 180);
    canvas.translate(-c.dx, -c.dy);

    // The disc, lit from up and to the left.
    canvas.drawCircle(
      c,
      33,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.24, -0.40), // 3a's cx 38% cy 30%
          radius: 0.78,
          colors: [_markLight(hue), _markMid(hue)],
        ).createShader(Rect.fromCircle(center: c, radius: 33)),
    );

    // The ring just outside it.
    canvas.drawCircle(c, 41, hair(1, 0.22));

    // A broken arc over the top. 3a dashes it 86-on 200-off, which on a 39pt
    // half-circumference (≈123) means it stops about two thirds of the way
    // across — an arc that trails off rather than closing.
    canvas.drawArc(Rect.fromCircle(center: c, radius: 39), math.pi,
        math.pi * (86 / 123), false, hair(1.25, 0.34));

    // And a second, springing the other way underneath.
    //
    // ⚠️ ITS CENTRE IS NOT THE MARK'S CENTRE. 3a writes it as an SVG arc
    // command — `M18 66 A34 34 0 0 0 78 66` — which gives two endpoints and a
    // radius and lets the renderer solve for the middle. A 60-unit chord at
    // radius 34 puts that middle 16 units off the chord, at (48, 50), and
    // sweep-flag 0 says take the half that bulges downward. Drawing it around
    // (48, 48) instead is two units of drift that reads as the lower arc not
    // quite belonging to the disc.
    canvas.drawArc(
        Rect.fromCircle(center: const Offset(48, 50), radius: 34),
        151.93 * math.pi / 180,
        -123.86 * math.pi / 180,
        false,
        hair(1, 0.28));

    // The cluster: three dots of falling size and falling weight.
    for (final (i, r, a) in [(0, 4.5, 0.50), (1, 2.4, 0.35), (2, 1.4, 0.28)]) {
      canvas.drawCircle(Offset(d[i * 2], d[i * 2 + 1]), r,
          Paint()..color = deep.withValues(alpha: a));
    }
    canvas.restore();

    // ⚠️ THE HORIZON IS OUTSIDE THE ROTATION, and 3a puts it there on purpose.
    // Everything else turns; this one line stays level on all five cards, so
    // the marks read as five views of one place rather than five unrelated
    // drawings. Turning it with the rest loses that instantly.
    canvas.drawPath(
      Path()
        ..moveTo(4, 82)
        ..quadraticBezierTo(48, 70, 92, 80),
      hair(1, 0.30),
    );
  }

  @override
  bool shouldRepaint(_CarouselMark old) =>
      old.hue != hue || old.index != index;
}

/// One card on the track — a drawing, at a position on a ring.
///
/// ⚠️ STATELESS, AND REBUILT EVERY FRAME OF A DRAG. It holds no animation of
/// its own: [offset] arrives already interpolated and the card just draws where
/// that says. Anything animating in here would be a second clock running
/// against the track's, and the one that loses is whichever finished last.
class _CarouselCard extends StatelessWidget {
  const _CarouselCard({
    super.key,
    required this.group,
    required this.inside,
    required this.offset,
    required this.count,
    required this.index,
    required this.held,
    required this.p,
  });

  final TtcFocusGroup group;

  /// The second line — "8 things", "Quick check". Counted by the carousel.
  final String inside;

  /// Signed distance from the middle of the track, fractional while it moves.
  final double offset;

  /// How many cards are on the ring. Sets where the far side is — the one
  /// place a card has to vanish, because it is about to reappear on the other
  /// side. See the opacity note in [build].
  final int count;

  /// Position in the door's group list. Seeds the mark, so a group's drawing is
  /// the same every time it is looked at.
  final int index;

  /// Whether the zone in front of this card is being pressed. Pushed down from
  /// the track rather than held here, because the finger never lands on this
  /// widget — see the hit-testing note in [_GroupCarouselState.build].
  final bool held;

  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final o = offset;
    final a = o.abs();
    final s = o.sign;
    final h = group.hue % 360;
    final deep = _deepFor(group.hue);

    // ⚠️ EVERY ONE OF THESE IS CONTINUOUS IN `o`. At a == 0 they are 4a's
    // chosen-card values, at a == 1 its neighbour values and at a == 2 its
    // back-pair values; the frames between are what a CSS transition would have
    // produced and what the finger is actually dragging through.
    //
    // Where 4a's table is a straight line — scale drops 0.2 a step, z 60, y 8 —
    // the line is written once. Where it bends at the neighbour — the sideways
    // travel is 96 for the first step and 74 for the second, the turn 24° then
    // 8° more — `_ladder` bends with it.
    final near = (1 - a).clamp(0.0, 1.0); // 1 in the middle, 0 at a neighbour
    final one = a.clamp(0.0, 1.0); // the first step, saturating
    double ladder(double first, double rest) =>
        a <= 1 ? first * a : first + rest * (a - 1);

    // ⚠️ NO PRESS-SCALE ANY MORE, AND IT WAS A JITTER. `held` used to multiply
    // this by 0.95 while a side zone was pressed — instantly, no tween. But a
    // zone's `onTapDown` also fires at the START OF A SWIPE, once the finger
    // has sat for the press timeout, and is cancelled the moment the drag
    // wins: the neighbour shrank a twentieth and popped back before the
    // track had moved a point. On a tap it was shrink, pop, then glide —
    // three movements for one gesture. 4a has no press state; the turn is
    // the feedback. `held` still arrives, so the plumbing stays for a
    // tweened version if one is ever wanted:
    //   final scale = (1 - 0.2 * a) * (held ? 0.95 : 1);
    final scale = 1 - 0.2 * a;

    // ⚠️ NOTHING IS HIDDEN — THAT IS THE WHOLE OF 4a — EXCEPT AT THE SEAM.
    // The design's opacities are 1, .92, .72 and every card on a five-ring is
    // within two steps of the middle, so all five are drawn. But the ring has a
    // far side, at |o| = count/2, where a card stops being "two to the right"
    // and becomes "two to the left" in one frame, and its x flips sign. On a
    // five-ring that point is behind the mask's edge and mostly off screen; the
    // fade over the last half step before it is what makes the crossing
    // invisible rather than merely unlikely to be noticed.
    final misted = a <= 1 ? 1 - 0.08 * a : 0.92 - 0.20 * (a - 1);
    final seam = ((count / 2 - a) / 0.5).clamp(0.0, 1.0);
    final opacity = (misted * seam).clamp(0.0, 1.0);

    if (opacity == 0) return const SizedBox.shrink();

    // See the header note for why the perspective entry is negative.
    final m = Matrix4.identity()
      ..setEntry(3, 2, -1 / 1000)
      ..translateByDouble(s * ladder(96, 74), 8 * a, -60 * a, 1)
      ..rotateY(-s * ladder(24, 8) * math.pi / 180)
      ..rotateX(3 * one * math.pi / 180)
      ..scaleByDouble(scale, scale, 1, 1);

    // 4a's `filter: blur(a·1.1px)`. A CSS blur radius is a Gaussian sigma, so
    // the number crosses over unchanged.
    //
    // ⚠️ THE `saturate(1.05 | 1.15)` HALF OF THAT FILTER IS NOT APPLIED. It
    // cost a `ColorFiltered` layer per receding card — four offscreen passes a
    // frame on top of the four blurs — for a shift the eye cannot find next
    // to the tint deepening in [field] below. On a mid-range phone the
    // layers, not the maths, are what turn a glide into a stutter, and a
    // stutter reads as jitter. Kept for revert:
    //   final saturate = a <= 1 ? 1 + 0.05 * a : 1.05 + 0.10 * (a - 1);
    //   … ColorFiltered(colorFilter: ColorFilter.matrix(_saturation(saturate)))
    final blur = 1.1 * a;

    // 4a's "tint that deepens as it recedes": the same 150° two-stop field 3a
    // drew, with both stops walking darker and a touch more saturated per
    // step — `hsl(h 32+3a% 94−7a%)` to `hsl(h 26+5a% 91−10a%)`.
    // `linear-gradient(150deg, …)` measures clockwise from straight up, so the
    // line runs (sin150, −cos150) = (0.5, 0.866) — down and to the right.
    final field = LinearGradient(
      begin: const Alignment(-0.5, -0.866),
      end: const Alignment(0.5, 0.866),
      colors: [
        HSLColor.fromAHSL(1, h, 0.32 + 0.03 * a, 0.94 - 0.07 * a).toColor(),
        HSLColor.fromAHSL(1, h, 0.26 + 0.05 * a, 0.91 - 0.10 * a).toColor(),
      ],
    );

    // ⚠️ A SOFT RIM, NOT A HARD RING, AND THIS IS 4a REVISING 3a. 3a drew the
    // front card's border in the group's deep hue; 4a's note is *"ring is a
    // soft tinted rim rather than a hard outline"* — `hsl(h 32% 62% / .55)` in
    // front, `hsl(h 24% (60−4a)% / .32)` behind. Both are the group's own hue
    // at two strengths, so [_GroupTab]'s objection to a purple outline still
    // does not apply; what changed is that the rim no longer competes with the
    // geometry for the job of saying which card is forward.
    final rim = Color.lerp(
      HSLColor.fromAHSL(0.32, h, 0.24, 0.60 - 0.04 * a).toColor(),
      HSLColor.fromAHSL(0.55, h, 0.32, 0.62).toColor(),
      near,
    )!;

    Widget card = SizedBox(
      width: kTtcCarouselCardWidth,
      height: kTtcCarouselCardHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: field,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: rim, width: 1),
          boxShadow: near > 0
              ? [
                  // 4a's `0 10px 26px −12px hsl(h 34% 42% / .38)`, on the
                  // front card only. The hue's own shadow, not black: a
                  // coloured block casting a grey shadow reads as a sticker
                  // on the page rather than a part of it.
                  BoxShadow(
                    color: HSLColor.fromAHSL(0.38 * near, h, 0.34, 0.42)
                        .toColor(),
                    blurRadius: 26,
                    spreadRadius: -12,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        // ⚠️ A STACK, NOT A COLUMN, AND THE FIRST CUT GOT THIS WRONG.
        // Stacking the mark above the text made them share the card's
        // height: a 74pt mark and a two-line name like "What he can do" do
        // not both fit under each other, and the card painted an overflow
        // stripe.
        //
        // The Column was the mistake, not the sizes. The design's own words
        // are that the mark "sits in a FIELD rather than on a patch" — it is
        // the card's surface, not an item stacked on top of one, so the name
        // lies over its lower edge and neither has to give way. It is also
        // what lets the mark bleed off the edge.
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 4a's mark: 74pt, top-right, `margin: -1px -3px 0 0` inside
            // `padding: 11px 13px 13px` — so 10 from the top and 10 from the
            // right, with the ring round the disc running just past the
            // corner. And it drifts: `translateX(−s·a·7px)`, a few points
            // against the turn, so the drawing slides across its card as the
            // card comes round. 4a: *"the mark drifts a few px as cards
            // rotate."*
            Positioned(
              top: 10,
              right: 10,
              width: 74,
              height: 74,
              child: Transform.translate(
                offset: Offset(-o * 7, 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CarouselMark(hue: group.hue, index: index),
                      ),
                    ),
                    // The group's own icon, at the centre of its mark — "with
                    // the kit icon still at the centre", and the thing that
                    // keeps the drawing a TAB rather than decoration.
                    Transform.translate(
                      offset: const Offset(-2, -3),
                      child: Icon(group.icon, size: 26, color: deep),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 13,
              right: 13,
              bottom: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(group.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                  const SizedBox(height: 3),
                  // ⚠️ THE COUNT FADES WITH DISTANCE, THE NAME DOES NOT.
                  // 4a hides a neighbour's whole label, which works there
                  // because its art carries the identity on its own. Ours
                  // has to keep the name — a nameless neighbour is a
                  // coloured rectangle, and she would have to swipe to find
                  // out what she was swiping to. The count is the part that
                  // is only useful once you have chosen, so it is the part
                  // that goes.
                  Opacity(
                    opacity: near,
                    child: Text(inside,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: deep.withValues(alpha: 0.75))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // ---- the mist ----------------------------------------------------------
    //
    // ⚠️ THE FRONT CARD GETS NO FILTER LAYER AT ALL. `ImageFiltered` renders
    // its child into an offscreen layer and composites it back, every frame
    // of a drag. At a == 0 that would be a blur of zero and still cost the
    // layer. So the card that is looked at most is the plain widget, and the
    // filter only exists on the cards that are actually receding.
    //
    // The order matters and is CSS's: `filter` is applied in the card's own
    // space and the transform to the filtered result, so the filter sits
    // INSIDE the `Transform` — see the header. `TileMode.decal` is what lets a
    // blurred card's edges soften into nothing; the default clamp would smear
    // its edge pixels outward into a hard, slightly wider rectangle.
    if (a > 0.01) {
      card = ImageFiltered(
        imageFilter: ImageFilter.blur(
            sigmaX: blur, sigmaY: blur, tileMode: TileMode.decal),
        child: card,
      );
    }

    return Opacity(
      opacity: opacity,
      child: Transform(
        transform: m,
        // ⚠️ CENTRE, AND IT IS NOT COSMETIC — IT IS WHERE THE VANISHING POINT
        // GOES. CSS puts `perspective` on the PARENT, so every card recedes
        // toward one point at the middle of the track. Flutter has no parent
        // perspective: the entry rides in each card's own matrix, so the
        // vanishing point sits at that card's `alignment`.
        //
        // The two only agree because every card is laid out at the SAME place —
        // the `Stack` centres them all and the matrix does the displacing — so
        // "the centre of this card" and "the centre of the track" are the same
        // point. Give the cards real positions instead of transforms and each
        // one starts receding toward itself, which looks like five separate
        // animations rather than one track.
        alignment: Alignment.center,
        // ⚠️ NO `filterQuality`, ON PURPOSE. See failure (4) in the header.
        child: card,
      ),
    );
  }
}

// Kept for revert: the saturate half of 4a's filter, dropped for the layer it
// cost — see the note on `blur` in [_CarouselCard.build].
// /// CSS `saturate(s)` as a 4×5 colour matrix — the SVG/CSS filter definition,
// /// weighting the channels by the same luminance coefficients (.213/.715/.072)
// /// the browser uses, so 4a's `saturate(1.15)` lands the same colour here.
// ///
// /// At `s = 1` it is the identity; above 1 each channel is pushed away from the
// /// pixel's luminance, which is what "more saturated" means arithmetically.
// List<double> _saturation(double s) {
//   final r = 0.213 * (1 - s);
//   final g = 0.715 * (1 - s);
//   final b = 0.072 * (1 - s);
//   return [
//     r + s, g, b, 0, 0, //
//     r, g + s, b, 0, 0, //
//     r, g, b + s, 0, 0, //
//     0, 0, 0, 1, 0,
//   ];
// }

/// The counter under the track.
///
/// ⚠️ IT IS NOT DECORATION. On the flat rail every tab is on screen, so a dot
/// row would only repeat what the eye already has — which is why [_GroupRail]
/// has none and this does. Here two of five are small, misted and half off the
/// track, and this is the thing that says plainly how many there are and which
/// one is open.
///
/// It is also tappable. A dot is a smaller target than a card, but it is the
/// shortest route to the far pair, which otherwise takes two swipes to reach.
///
/// ⚠️ THE LIT DOT STRETCHES WITH THE TRACK, not after it. It reads [position],
/// the same fractional number the cards do, so halfway through a drag the pill
/// is halfway between two dots. A dot row that waits for the gesture to finish
/// and then jumps is the tell that a carousel is a slideshow.
class _CarouselDots extends StatelessWidget {
  const _CarouselDots({
    required this.groups,
    required this.position,
    required this.selected,
    required this.p,
    required this.onPick,
  });

  final List<TtcFocusGroup> groups;
  final double position;
  final int selected;
  final V2Palette p;
  final ValueChanged<int> onPick;

  /// 4a's dot: 5pt tall, 5 wide at rest and 18 lit.
  static const double dot = 5;
  static const double lit = 18;

  /// Transparent target above and below the painted dot.
  static const double tapPad = 7;

  static const double height = dot + 2 * tapPad;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < groups.length; i++)
            Builder(builder: (context) {
              // How much of the lit state this dot is holding right now. The
              // ring wraps, so the distance has to as well, or dot five and
              // dot one would hand over by travelling through the middle.
              //
              // ⚠️ MODULO FIRST, AND THAT IS THE WHOLE OF A SHIPPED BUG. This
              // was `(i - position).abs()` reduced by `if (o > n/2) o = n - o`,
              // which is correct only while `position` is inside one lap — and
              // the track's position legitimately leaves it, because each step
              // settles the short way round rather than to an index. Six steps
              // in one direction put it at ±6, `n - o` went NEGATIVE, `1 - o`
              // came out above 1, and every dot clamped to fully lit.
              //
              // Dart's `%` on a double returns a non-negative result for a
              // positive divisor, so one modulo puts the distance in `[0, n)`
              // for any position at all, and the fold after it in `[0, n/2]`.
              // The position is also normalised on settle now, so this is
              // belt and braces — deliberately, because the last version of
              // this line was correct-given-an-invariant that nothing checked.
              final n = groups.length;
              var o = (i - position) % n;
              if (o > n / 2) o = n - o;
              final on = (1 - o).clamp(0.0, 1.0);
              return Padding(
                key: ttcCarouselDotKey(i),
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Semantics(
                  selected: i == selected,
                  button: true,
                  label: groups[i].label,
                  child: GestureDetector(
                    onTap: () => onPick(i),
                    behavior: HitTestBehavior.opaque,
                    // ⚠️ THE PAINTED DOT IS 5pt AND THE TARGET IS NOT. A 5pt
                    // hit box is far under any touch minimum; the transparent
                    // padding carries the tap and the dot only draws it.
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: tapPad),
                      child: SizedBox(
                        width: dot + (lit - dot) * on,
                        height: dot,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            // The lit dot takes the group's own deep hue, so
                            // the counter changes colour with the card it
                            // points at. One hue, two strengths — the rail's
                            // rule, kept.
                            color: Color.lerp(p.ink1.withValues(alpha: 0.14),
                                _deepFor(groups[i].hue), on),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      );
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.p,
    required this.children,
    this.minHeightFactor = 0.72,
  });

  final V2Palette p;
  final List<Widget> children;

  /// ⚠️ ZERO WHEN A SLIVER IS ALREADY SIZING THIS. `SliverFillRemaining` hands
  /// the sheet at least the rest of the viewport, so a second minimum here
  /// would fight it and win on short pages — which is the gap this parameter
  /// exists to close, arrived at from the other direction.
  final double minHeightFactor;


  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
            minHeight:
                MediaQuery.sizeOf(context).height * minHeightFactor),
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
  // A pair of shoes rather than a slider: the difference between a thing you
  // operate and a thing you do for six weeks.
  TtcTileFormat.practice => Icons.directions_run_rounded,
  TtcTileFormat.checklist => Icons.checklist_rtl_rounded,
  // A book with a bookmark rather than a plain page: something you come back
  // to and use, not something you read once.
  TtcTileFormat.guide => Icons.menu_book_outlined,
  // An arrow leaving a box — the only tile whose tap takes you off this
  // door, and the icon is the one part of the card that can say so before
  // she reads the words.
  TtcTileFormat.door => Icons.open_in_new_rounded,
  // A message rather than a calendar: the promise is a conversation, not a
  // slot. Same engine underneath as `booking`.
  TtcTileFormat.talk => Icons.chat_bubble_outline_rounded,
    TtcTileFormat.article => Icons.article_outlined,
    TtcTileFormat.carousel => Icons.view_carousel_outlined,
    TtcTileFormat.video => Icons.play_circle_outline_rounded,
    TtcTileFormat.mythFact => Icons.balance_rounded,
    TtcTileFormat.product => Icons.shopping_bag_outlined,
    TtcTileFormat.booking => Icons.event_available_outlined,
    TtcTileFormat.recipe => Icons.restaurant_outlined,
    TtcTileFormat.community => Icons.forum_outlined,
    TtcTileFormat.infographic => Icons.insights_outlined,
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

    // ---- something to practise: same push, different promise ------------
    case TtcDoTile(:final surfaceId):
      openTtcSurface(context, surfaceId);

    // ---- another door entirely ------------------------------------------
    //
    // ⚠️ IT RESOLVES BEFORE IT PUSHES. `ttcFocusPageFor` returns null for a
    // bracket with no focus page, and an unknown bracket id would otherwise
    // build a screen against a null page. Returning is the wiring gate: a card
    // naming a door that does not exist opens nothing, loudly, in the test.
    case TtcDoorTile(:final bracketId):
      final page = ttcFocusPageFor(bracketId);
      final bracket = bracketById(bracketId);
      if (page == null || bracket == null) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: 'ttc/focus/$bracketId'),
          builder: (_) => TtcFocusScreen(page: page, bracket: bracket),
        ),
      );

    // ---- one frame, no swiping ------------------------------------------
    case TtcInfographicTile():
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/infographic'),
        builder: (_) => TtcInfographicScreen(tile: tile, hue: hue),
      ));

    // ---- a room, not an answer ------------------------------------------
    case TtcCommunityTile(:final surfaceId):
      openTtcSurface(context, surfaceId);

    // ---- a dish, on the app's own recipe page ---------------------------
    //
    // ⚠️ `RecipeDetailScreen`, NOT A TTC RECIPE SCREEN. It already scales every
    // ingredient to a chosen serving count, lists the steps and carries a
    // nutrition glance; a second one styled for this stage would be a second
    // thing to keep in step for no gain the reader can see.
    //
    // ⚠️ AND A MISSING ID FAILS LOUDLY HERE. `firstWhere` throws rather than
    // returning a blank page, because a recipe tile that opens nothing is the
    // exact silent failure `ttc_focus_page_test.dart` exists to catch — better
    // it dies in a test than renders an empty screen on a phone.
    case TtcRecipeTile(:final recipeId):
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/recipe'),
        builder: (_) => RecipeDetailScreen(
            recipe: kRecipes.firstWhere((r) => r.id == recipeId)),
      ));

    // ---- reading --------------------------------------------------------
    case TtcArticleTile(
      :final readId,
      :final art,
      :final imageUrl,
      :final atHeading,
    ):
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
      openTtcArticle(
        context,
        readId!,
        art: art,
        imageUrl: imageUrl,
        hue: hue,
        atHeading: atHeading,
      );

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
    // ⚠️ V3 DOORS OPEN THE NEW PRODUCT PAGE — CHANGED 2026-09-03.
    //
    // It used to push `TtcProductsScreen` with a `focusId`, which opened the
    // whole flat library scrolled to one entry. That was right when the library
    // was the only product surface; it is not right from a focus page, where
    // the tile named ONE product and answering with a list of ten is the
    // "middle menu" this whole rebuild removed everywhere else.
    //
    // ⚠️ AND THE OLD SCREEN IS UNTOUCHED. It stays on disk, stays routed at
    // `ttc_products`, and Ask Veda's deep links still land there — asked for
    // directly: only the V3 doors move. Both read `ttcProducts`, so there is
    // one catalogue under two surfaces and no copy of any text in either.
    // ---- something to buy: one product, or the whole shelf --------------
    //
    // ⚠️ BOTH FORMS, BECAUSE THE SHELF FORM IS THE ONE THAT WAS MISSING. See
    // the note on `TtcProductTile`: a brief row meaning "open the supplements
    // shelf" had nowhere to go and shipped as a tool pointing at the
    // supplements tracker.
    case TtcProductTile(:final productId?):
      openTtcProductPage(context, productId);

    case TtcProductTile(:final category?):
      Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: 'ttc/shop/$category'),
          builder: (_) => TtcShelfScreen(category: category),
        ),
      );

    // Unreachable: the two constructors guarantee one of the pair is set.
    case TtcProductTile():
      openTtcShop(context);

    // ---- a guide: the article reader, a truer chip ----------------------
    case TtcGuideTile(:final readId, :final atHeading):
      openTtcArticle(context, readId, hue: hue, atHeading: atHeading);

    // ---- a checklist: same push as a tool, a truer chip -----------------
    case TtcChecklistTile(:final surfaceId):
      openTtcSurface(context, surfaceId);

    // ---- a person, reached by asking ------------------------------------
    //
    // Same destination as a booking tile and the same guard. Only the chip
    // differs, because "Talk" and "Booking" are different promises to somebody
    // who has not started trying yet.
    case TtcTalkTile(:final action):
      // ⚠️ AN OFFERING ID OPENS THAT OFFERING — 2026-09-06. His side's Talk
      // tiles name the andrologist consultation rather than the consults
      // shelf, because the brief says "Consult (andrologist)" and a shelf
      // with his card third on it is not that. Same null rule as the
      // masterclass below: an unknown id opens nothing, loudly, in the test.
      if (ttcOfferingById(action) case final offering?) {
        Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: 'ttc/offering/$action'),
          builder: (_) => TtcOfferingScreen(offering: offering),
        ));
        return;
      }
      if (action != kTtcActConsult) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'ttc/consults'),
          builder: (_) => const TtcPrepareScreen(onlyCategory: 'consults'),
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
  String? atHeading,
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
        openAtHeading: atHeading,
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

/// A red flag, pinned above a group's rails.
///
/// ⚠️ NOT RED, AND THAT IS DELIBERATE ON THIS AREA IN PARTICULAR. `danger` in
/// this design system is reserved for destructive confirmation, never urgency,
/// and a scarlet block on a screen opened days after a miscarriage shouts at
/// somebody who is already frightened. It is the coral tint every other urgent
/// callout in this stage uses, and it earns attention by sitting above
/// everything rather than by being loud.
class _PinnedRedFlag extends StatelessWidget {
  const _PinnedRedFlag({
    required this.callout,
    required this.lang,
    required this.p,
  });

  final PvCallout callout;
  final AppLanguage lang;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: ttcCoralTint,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 18, color: ttcCoral),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                callout.title.of(lang),
                style: pvJakarta(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: p.ink1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          callout.body.of(lang),
          style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink1),
        ),
      ],
    ),
  );
}
