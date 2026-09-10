// =============================================================================
//  PvDoorScreen — one problem area, five sub-tabs, one page
// -----------------------------------------------------------------------------
//  Renders a `PvDoorPage`. It knows nothing about scans specifically — the
//  content is data, and adding a door is a data file plus a line in
//  `kPvDoorPages`.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE THREE-LEVEL HIERARCHY IS THE DESIGN, AND IT IS EASY TO WRECK
//  ---------------------------------------------------------------------------
//
//    tab      →  where she is standing                 ("Understand a scan")
//    section  →  a plain phrase she would say          ("Before any scan")
//    tile     →  one piece of content                  ("NT scan")
//    format   →  what kind of thing it is              (Article)
//
//  The failure mode, which every content-heavy screen in this app has hit at
//  least once, is the fourth level climbing into the second: a "Videos"
//  heading, an "Articles" section, a "Guides" group. That organises the page by
//  how we happened to build it instead of by what she wants to know, and it is
//  invisible in review because it looks tidy.
//
//  So the format never appears as a heading. It appears as a small chip on the
//  tile, which is the only place it belongs: she does not choose a format, she
//  chooses a question and then wants to know whether the answer is thirty
//  seconds of reading or a form to fill in.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE TAB IS NOT REPEATED AS A HEADING
//  ---------------------------------------------------------------------------
//
//  Tapping the card marked "My reports" and then reading the words "My reports"
//  underneath it tells her nothing she did not just do — and on a tool tab it
//  pushes the tool itself below the fold, which is a real cost paid for a
//  label. The lit card IS the heading.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE SELECTOR DOES NOT REMEMBER
//  ---------------------------------------------------------------------------
//
//  It resets to the first tab every time the door is opened. "My scans" is
//  where somebody arriving at Scans & tests should land, and remembering that
//  she last read "Understand a result" would drop the next visitor into the
//  middle of the subject — including the visitor who is the same person a
//  fortnight later with a different question.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_data.dart';
import '../../models/bracket.dart';
import '../../services/pregnancy_controller.dart';
import '../../data/conditions_data.dart' show ConditionsStore;
import '../../services/scan_reports_store.dart';
import '../../services/scans_store.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart';
import '../v2/v3_hero_field.dart';
import 'pv_door_carousel.dart';
import 'pv_door_chrome.dart';
import 'pv_door_router.dart';

// -----------------------------------------------------------------------------
//  Rail geometry
// -----------------------------------------------------------------------------
//  ⚠️ PUBLIC SO A TEST CAN DO THE SUM, and the sum is the whole point. What
//  these numbers have to add up to is HOW MUCH OF THE THIRD CARD SHOWS, and
//  that is the thing nobody writes down and therefore the thing that drifts.
//
//  On a 360dp screen:
//
//      18 gutter + 142 + 10 gap + 142 + 10 gap = 322  →  38pt of the third
//
//  Leaving out the SECOND gap is the mistake that has already been made once:
//  it leaves four points of the third card visible, which reads as a clipping
//  bug rather than as an invitation to swipe. A rail that fits exactly reads as
//  a finished row and nobody swipes it at all.
const double kPvRailCardWidth = 142;
const double kPvRailCardHeight = 176;
const double kPvRailGap = 10;

/// How far the sheet is pulled up over a photographic hero.
///
/// ⚠️ IT EXISTS TWICE BY NECESSITY — as space added at the foot of the hero and
/// as the distance the sheet is lifted — so it is one number, not two that have
/// to be kept equal by hand. Get them out of step and either the tinted field
/// reappears in the sheet's rounded corners or the page grows a gap.
const double kPvDoorHeroOverlap = 38;

class PvDoorScreen extends StatefulWidget {
  const PvDoorScreen({
    super.key,
    required this.page,
    required this.bracket,
    required this.pregnancy,
  });

  final PvDoorPage page;

  /// ⚠️ THE WHOLE BRACKET, NOT A TITLE AND A HUE. The eyebrow is
  /// `bracket.label` — the exact string on the tile she tapped — so the two can
  /// never drift apart. See `PvDoorPage.heroTitle` for why this door carries
  /// its own headline as well and why that is not the same mistake.
  final Bracket bracket;

  final PregnancyController pregnancy;

  @override
  State<PvDoorScreen> createState() => _PvDoorScreenState();
}

class _PvDoorScreenState extends State<PvDoorScreen> {
  int _group = 0;

  PvDoorPage get page => widget.page;
  Bracket get bracket => widget.bracket;

  /// The second line on a tab's card. Counted, never typed.
  ///
  /// ⚠️ A HAND-WRITTEN COUNT GOES STALE SILENTLY — nothing fails, the number is
  /// simply wrong, and it is wrong on the one line whose whole job is to be
  /// trusted before a tap.
  ///
  /// ⚠️ AND A TOOL TAB NAMES ITSELF RATHER THAN COUNTING. "1 thing" over the
  /// timeline is true and useless. `PvDoorGroup.inlineLabel` is set per tab
  /// rather than switched on the surface id, because a value inferred from the
  /// first caller is wrong at the second — which is exactly how the TTC
  /// original ended up calling a practice screen a "Quick check".
  String _countFor(PvDoorGroup g) {
    if (g.inlineLabel case final label?) return label;
    final n = page
        .sectionsOf(g.id)
        .fold(0, (t, s) => t + s.tiles.length);
    if (n == 0) return g.inlineSurfaceId != null ? 'Look it up' : '';
    return n == 1 ? '1 thing' : '$n things';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // ⚠️ THE STORES THE INLINE TOOLS READ, LISTENED TO HERE. The timeline and
      // the locker are rendered as bodies inside this page's own scroll, so a
      // report added or a scan ticked has to rebuild THIS widget — their own
      // `AnimatedBuilder`s cannot help them when their Scaffold is not on
      // screen. Missing this is the classic inline-tool bug: the tool works
      // perfectly on its own screen and looks frozen inside the tab.
      animation: Listenable.merge([
        V2PaletteStore.instance,
        ScansStore.instance,
        ScanReportsStore.instance,
        // ⚠️ ADDED WITH THE COMPLICATIONS DOOR. Its first tab renders the
        // conditions search inline, and the two-way door writes to this store —
        // so without it, answering the gate leaves the tab showing the gate.
        // The list grows by one line per door that renders a stateful tool
        // inline, and forgetting a line looks like a frozen tab.
        ConditionsStore.instance,
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final hue = bracket.hue;
        final tint = v2BlockTint(hue, p);
        final lang = widget.pregnancy.language;
        final groups = page.groups;
        final group = groups[_group.clamp(0, groups.length - 1)];

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
              // ⚠️ NO BOTTOM PADDING HERE — THE SHEET OWNS THE CLEARANCE. See
              // `PvDoorSheet`.
              padding: EdgeInsets.zero,
              children: [
                _Hero(
                  page: page,
                  p: p,
                  tint: tint,
                  eyebrow: bracket.label.of(lang),
                  bracket: bracket,
                ),
                PvDoorSheet(p: p, children: [
                  const SizedBox(height: 22),

                  // ---- the selector, first thing under the hero ----------
                  PvDoorCarousel(
                    groups: groups,
                    counts: [for (final g in groups) _countFor(g)],
                    selected: _group,
                    p: p,
                    onPick: (i) => setState(() => _group = i),
                  ),
                  const SizedBox(height: 26),

                  // ---- a pinned red flag, above everything ---------------
                  //
                  // ⚠️ ABOVE THE CONTENT AND NEVER IN AN ACCORDION. A rail is a
                  // browse surface, and a woman scanning cards for the one that
                  // matches her situation has already been asked to make a
                  // choice. This should not wait for one.
                  if (group.pinnedRedFlag case final flag?) ...[
                    pvDoorPad(_PinnedRedFlag(
                      flag: flag,
                      p: p,
                      onTap: () => openPvDoorSurface(
                          context, flag.surfaceId, widget.pregnancy),
                      onLine: (conditionId) => openPvDoorConditionPage(
                          context, conditionId, widget.pregnancy),
                    )),
                    const SizedBox(height: 22),
                  ],

                  // ---- a note that belongs to the tab, if it has one -----
                  //
                  // ⚠️ BELOW THE FLAG WHEN BOTH ARE PRESENT, because the order
                  // is the order of consequence. Quiet type: it is a standing
                  // note, not news.
                  if (group.note case final note?) ...[
                    pvDoorPad(_TabNote(note: note, p: p)),
                    const SizedBox(height: 20),
                  ],

                  // ---- the tool, rendered in place ----------------------
                  //
                  // ⚠️ NOT BEHIND A TILE. A card in front of a tool, inside a
                  // tab whose main content is that tool, is a door in front of
                  // a door. The brief calls two of these tabs "tool screens,
                  // not rails" and this is what that means mechanically.
                  if (group.inlineSurfaceId case final surface?) ...[
                    if (pvDoorInlineToolFor(surface, widget.pregnancy)
                        case final tool?) ...[
                      pvDoorPad(tool),
                      const SizedBox(height: 28),
                    ],
                  ],

                  // ---- this tab's sections ------------------------------
                  for (final section in page.sectionsOf(group.id)) ...[
                    pvDoorPad(Text(section.heading,
                        style: pvFraunces(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.45,
                            color: p.ink1))),
                    const SizedBox(height: 13),
                    if (group.layout == PvDoorLayout.stack)
                      // ⚠️ FULL-WIDTH ROWS, NOT A RAIL. A rail says "there is
                      // more sideways"; on a tab with a tool above it and two
                      // errands below, there is not.
                      for (final tile in section.tiles) ...[
                        pvDoorPad(_WideTile(
                          tile: tile,
                          p: p,
                          hue: hue,
                          onTap: () => openPvDoorTile(
                              context, tile, widget.pregnancy),
                        )),
                        const SizedBox(height: 10),
                      ]
                    else
                      // ⚠️ A HORIZONTAL RAIL PER SECTION, AND THE CARDS ARE
                      // DELIBERATELY CUT OFF AT THE RIGHT EDGE. Four sections
                      // holding nineteen stacked rows is a page you scroll for
                      // a long time past things you did not want; four rails is
                      // a page where every SECTION is reachable in one
                      // thumb-flick and the depth is sideways, where it costs
                      // nothing.
                      SizedBox(
                        height: kPvRailCardHeight,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: kPvDoorGutter),
                          itemCount: section.tiles.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: kPvRailGap),
                          itemBuilder: (context, i) => _RailCard(
                            tile: section.tiles[i],
                            p: p,
                            hue: hue,
                            index: i,
                            onTap: () => openPvDoorTile(
                                context, section.tiles[i], widget.pregnancy),
                          ),
                        ),
                      ),
                    const SizedBox(height: 26),
                  ],

                  // ⚠️ THE CLOSING LINE, UNDER WHATEVER TAB IS OPEN. "Shown
                  // once" means once per page, not once per tab — a line that
                  // appears only under the last tab is a line most people never
                  // see.
                  if (page.closingLine case final line?) ...[
                    pvDoorPad(Text(line,
                        style: pvFraunces(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: p.ink2))),
                    const SizedBox(height: 22),
                  ],

                  pvDoorPad(PvDoorDisclaimer(p: p)),
                ]),
              ],
            ),
          ]),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
//  The hero
// -----------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({
    required this.page,
    required this.p,
    required this.tint,
    required this.eyebrow,
    required this.bracket,
  });

  final PvDoorPage page;
  final V2Palette p;
  final Color tint;

  /// `bracket.label` — the exact string on the tile that opened this.
  final String eyebrow;

  final Bracket bracket;

  @override
  Widget build(BuildContext context) {
    final mark = bracketMarkFor(bracket.id);
    final photo = page.heroImageUrl;

    // ⚠️ `Clip.none`, WHICH IS WHAT LETS THE PICTURE RUN PAST THE HERO. The
    // whole overlap depends on this Stack not trimming its children to its own
    // box, and the default does.
    return Stack(clipBehavior: Clip.none, children: [
      // ⚠️ THE PHOTOGRAPH IS A LAYER OVER THE FIELD, NOT A REPLACEMENT FOR IT.
      // `errorBuilder` and `loadingBuilder` both return nothing, so a dead
      // connection or a bad URL leaves exactly the hero this area has always
      // had rather than a grey box. Local-first is absolute, and here that
      // means the offline version is a finished design rather than a fallback
      // anyone would recognise as one.
      //
      // ⚠️ `bottom: -kPvDoorHeroOverlap`, AND A `Transform` HERE COULD NEVER
      // WORK. The sheet's rounded top corners are two holes, and something
      // deliberate has to be behind them or the field shows through. Dragging
      // the SHEET up with a transform and paying the height back by growing the
      // sheet is arithmetically impossible: a transform moves paint and not
      // layout, so growing the sheet grows the scroll extent by the same amount
      // and the gap at the foot survives at exactly its old size. The
      // compensation chases itself.
      //
      // So the overlap moves to the layer that can afford it. The photograph is
      // laid out below the hero's own box and simply paints there; the hero
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
          bottom: -kPvDoorHeroOverlap,
          child: Image.network(
            photo,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const SizedBox.shrink(),
          ),
        ),
      // ⚠️ A DARK SCRIM ONLY, AND IT NEVER FADES TO THE PAGE COLOUR. Ending
      // this gradient on `p.ground` washes the bottom of the photograph into a
      // pale haze under the type and the words stop being readable. It is an
      // easy mistake and worth naming: fading a photo into the page colour
      // looks like a clean seam in a design file and looks like fog on a phone,
      // because a real photograph has its own values down there and the fade
      // lands on top of them rather than replacing them.
      //
      // The seam is not this gradient's job anyway — the sheet below is pulled
      // up over the picture and its own rounded edge is the seam.
      if (photo != null)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -kPvDoorHeroOverlap,
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
            // 0.5 — the value the hub settled on. At 0.26 it read as a blank
            // grey box on a tinted field; a mark you have to look for is
            // decoration nobody sees.
            opacity: 0.5,
            child: SizedBox(
              width: 146,
              height: 146,
              child: mark == null
                  ? const SizedBox.shrink()
                  : V3BracketArt(mark: mark, tint: tint),
            ),
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
              // ⚠️ THE PHOTOGRAPH IS GIVEN ROOM HERE, AND NOWHERE ELSE. The
              // hero is a Stack whose size comes from this column, so the only
              // way to make the picture bigger is to make the column taller —
              // there is no height to set on the image itself.
              //
              // A fraction of the screen rather than a constant, because a
              // literal that looks generous on a 780pt phone eats a 640pt one.
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
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(page.heroTitle,
                    style: pvFraunces(
                        fontSize: photo == null ? 27 : 30,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                        letterSpacing: -0.6,
                        color: photo == null ? p.ink1 : Colors.white)),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 330),
                child: Text(page.heroBlurb,
                    style: pvManrope(
                        fontSize: 13.5,
                        height: 1.55,
                        color: photo == null
                            ? p.ink2
                            : Colors.white.withValues(alpha: 0.92))),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    ]);
  }
}

// -----------------------------------------------------------------------------
//  Tiles
// -----------------------------------------------------------------------------

/// The format's mark. Small on a chip, large and quiet behind a card.
IconData pvDoorFormatIcon(PvDoorFormat format) => switch (format) {
      PvDoorFormat.tool => Icons.tune_rounded,
      PvDoorFormat.article => Icons.article_outlined,
      // A book with a bookmark rather than a plain page: something you come
      // back to and use, not something you read once.
      PvDoorFormat.guide => Icons.menu_book_outlined,
      PvDoorFormat.read => Icons.search_rounded,
      PvDoorFormat.mythFact => Icons.balance_rounded,
      PvDoorFormat.checklist => Icons.checklist_rtl_rounded,
      // A message rather than a calendar: the promise is a conversation, not a
      // slot.
      PvDoorFormat.talk => Icons.chat_bubble_outline_rounded,
    };

/// One card on a rail.
class _RailCard extends StatelessWidget {
  const _RailCard({
    required this.tile,
    required this.p,
    required this.hue,
    required this.index,
    required this.onTap,
  });

  final PvDoorTile tile;
  final V2Palette p;
  final double hue;

  /// Position in its rail. Drives the tint step — see below.
  final int index;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // ⚠️ EACH CARD STEPS THE HUE, so a rail reads as separate blocks rather
    // than one long slab of the section's colour. With flat tints a uniform
    // rail loses the card edges entirely and the eye stops counting them. 22°
    // is enough to separate neighbours and small enough that the rail still
    // belongs to its section.
    final tint = v2BlockTint((hue + index * 22) % 360, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();
    final soon = tile.comingSoon;

    return InkWell(
      // ⚠️ A COMING-SOON CARD DOES NOT RESPOND TO A TAP, and that is the
      // honest treatment rather than a disabled one. A tap that does nothing
      // teaches that taps do nothing; no ink, no ripple and a chip that says
      // "Coming soon" teaches that this one is not ready.
      onTap: soon ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Opacity(
        opacity: soon ? 0.62 : 1,
        child: Container(
          width: kPvRailCardWidth,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            // The mark, sitting where an illustration would.
            //
            // ⚠️ QUIETER AND SMALLER THAN THE TTC ORIGINAL'S, BECAUSE THIS RAIL
            // IS NOT THAT RAIL. Over there most tiles carry their own drawn art
            // and the format glyph is the exception; here every tile falls back
            // to it — and nine scans are all one format, so the rail came out
            // as nine identical grey pages separated only by a title and a 22°
            // hue step. Seen on a phone, 2026-09-10.
            //
            // The fix is not a bigger difference between marks, it is a smaller
            // mark: at 96 and 0.34 it reads as a texture the hue sits in rather
            // than as the subject of the card, and the words become the thing
            // you look at. The week range does the actual distinguishing.
            Positioned(
              right: -22,
              bottom: 22,
              child: Icon(pvDoorFormatIcon(tile.format),
                  size: 96, color: Colors.white.withValues(alpha: 0.34)),
            ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The badge, top-left.
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(pvDoorFormatIcon(tile.format),
                          size: 10, color: deep),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(soon ? 'Coming soon' : tile.format.label,
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
                  // ⚠️ THE ONE FACT ABOVE THE TITLE, WHERE THERE IS ONE. On the
                  // scans rail this is the week range, and it is what makes a
                  // card answer "is this one mine, now" without being tapped.
                  // See `PvDoorTile.meta`.
                  if (tile.meta case final meta?) ...[
                    Text(meta.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: deep.withValues(alpha: 0.85))),
                    const SizedBox(height: 4),
                  ],
                  // ⚠️ TITLE ONLY ON THE FACE, BESIDES THAT. The blurb still
                  // exists on every tile and still does its job on a wide row;
                  // on a 142pt block it would take the title from four lines to
                  // one and turn a scannable rail into a wall.
                  Text(tile.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.22,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// One full-width row, on a tool tab.
///
/// ⚠️ IT SHOWS THE BLURB AND THE RAIL CARD DOES NOT. There is room here, and on
/// a tab with two or three rows the extra line is what stops them reading as an
/// afterthought under the tool above.
class _WideTile extends StatelessWidget {
  const _WideTile({
    required this.tile,
    required this.p,
    required this.hue,
    required this.onTap,
  });

  final PvDoorTile tile;
  final V2Palette p;
  final double hue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();
    final soon = tile.comingSoon;

    return InkWell(
      onTap: soon ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Opacity(
        opacity: soon ? 0.62 : 1,
        child: PvDoorCard(
          p: p,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(pvDoorFormatIcon(tile.format), size: 18, color: deep),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tile.title,
                      style: pvFraunces(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                  const SizedBox(height: 4),
                  Text(tile.blurb,
                      style: pvManrope(
                          fontSize: 13, height: 1.45, color: p.ink2)),
                  const SizedBox(height: 9),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: p.ground,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: p.line),
                    ),
                    child: Text(soon ? 'Coming soon' : tile.format.label,
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: p.ink3)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (!soon)
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

/// The pinned red flag.
///
/// ⚠️ CORAL, NOT SCARLET, AND THE WHOLE LIST IS SHOWN. `danger` in this design
/// system is reserved for destructive confirmation, never urgency, and a red
/// block on a records screen shouts at somebody who is already frightened. It
/// earns attention by sitting above everything rather than by being loud.
class _PinnedRedFlag extends StatelessWidget {
  const _PinnedRedFlag(
      {required this.flag,
      required this.p,
      required this.onTap,
      required this.onLine});

  final PvDoorRedFlag flag;
  final V2Palette p;
  final VoidCallback onTap;

  /// Opens the condition page behind one line, where that line has one.
  final void Function(String conditionId) onLine;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: kPvUrgentTint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: kPvUrgentInk),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(flag.title,
                      style: pvJakarta(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: p.ink1)),
                ),
              ]),
              const SizedBox(height: 12),
              // ⚠️ A LINE WITH ITS OWN PAGE IS ITS OWN TARGET, and it has to
              // stop the tap reaching the box behind it — otherwise a tap on
              // "the baby moving less than usual" would open the general
              // screen rather than the page that line was assembled from.
              // `GestureDetector` on the row does that by consuming the
              // gesture; the box's own handler only ever sees the gaps.
              for (final line in flag.lines) ...[
                GestureDetector(
                  onTap: line.conditionId == null
                      ? null
                      : () => onLine(line.conditionId!),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7, right: 9),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                                color: kPvUrgentInk, shape: BoxShape.circle),
                          ),
                        ),
                        Expanded(
                          child: Text(line.text,
                              style: pvManrope(
                                  fontSize: 13, height: 1.55, color: p.ink1)),
                        ),
                        // The mark that says this line goes somewhere. Only on
                        // the lines that do.
                        if (line.conditionId != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2, left: 6),
                            child: Icon(Icons.chevron_right_rounded,
                                size: 16,
                                color: kPvUrgentInk.withValues(alpha: 0.7)),
                          ),
                      ]),
                ),
                const SizedBox(height: 9),
              ],
              // ⚠️ THE BRIEF'S OWN SENTENCE, WHERE A FLAG CARRIES ONE. It sits
              // above the "see all" link because it qualifies the LIST, not the
              // link — "this tells you when to call and never replaces calling
              // a doctor or going in".
              if (flag.footer case final footer?) ...[
                const SizedBox(height: 4),
                Text(footer,
                    style: pvManrope(
                        fontSize: 12, height: 1.55, color: p.ink2)),
                const SizedBox(height: 10),
              ] else
                const SizedBox(height: 4),
              Text('See all of these',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: kPvUrgentInk)),
            ],
          ),
        ),
      );
}

/// A tab's standing note. Quiet type, quiet box, no urgency.
class _TabNote extends StatelessWidget {
  const _TabNote({required this.note, required this.p});

  final String note;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: p.ink1.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline_rounded, size: 15, color: p.ink3),
          const SizedBox(width: 9),
          Expanded(
            child: Text(note,
                style: pvManrope(fontSize: 12, height: 1.5, color: p.ink2)),
          ),
        ]),
      );
}
