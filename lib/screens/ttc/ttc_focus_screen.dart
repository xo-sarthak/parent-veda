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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../theme/pv_fonts.dart';
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
    if (g.toolSurfaceId != null) return 'Quick check';
    final n = widget.page.sections
        .where((s) => s.group == g.id)
        .fold(0, (t, s) => t + s.tiles.length);
    return n == 1 ? '1 thing' : '$n things';
  }

  @override
  Widget build(BuildContext context) => SizedBox(
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
                                  : p.ink3)),
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
