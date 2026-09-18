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
import 'pv_door_chips.dart';
import 'pv_door_chrome.dart';
import 'pv_door_rail.dart';
import 'pv_door_tiles.dart';
import 'pv_door_router.dart';
import '../search/pv_search_screen.dart';
import '../../widgets/pv_search_bar.dart';

/// Doors that use the chip row instead of the deck — the §2.8 comparison.
/// Scans & tests first, by the user's ask; empty this set to put every door
/// back on the deck, or fill it to move them all.
/// Empty since the low deck (2026-09-18): the user chose to keep the swipe
/// and shrink the card instead. The chip row stays built; add a bracket id
/// here to put a door on chips.
const Set<String> kPvDoorChipDoors = {};

/// Doors on the TILE row — icon tiles with a label beneath, every tab
/// visible, one tap (DoorDash, Skip, Glovo, Grab; the app's own home grid).
/// Complications first, for the user to judge; then every door.
const Set<String> kPvDoorTileDoors = {'pregnancy_complications'};

/// Doors on the straddling card RAIL — Flo's pattern, the user's reference
/// (2026-09-18): tall white cards across the seam between hero and sheet.
/// Scans & tests first.
const Set<String> kPvDoorRailDoors = {'pregnancy_scans_tests'};

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
// Rail geometry lives in pv_door_chrome.dart (`kPvRailCardWidth` etc.),
// shared with the embedded tools that draw a card of their own.

/// How far the sheet is pulled up over a photographic hero.
///
/// ⚠️ IT EXISTS TWICE BY NECESSITY — as space added at the foot of the hero and
/// as the distance the sheet is lifted — so it is one number, not two that have
/// to be kept equal by hand. Get them out of step and either the tinted field
/// reappears in the sheet's rounded corners or the page grows a gap.
const Key kPvDoorSearchKey = ValueKey('pv-door-search');

const double kPvDoorHeroOverlap = 38; // the rail lifts by PvDoorRail.overlap (70); see _Hero's `bottom`

class PvDoorScreen extends StatefulWidget {
  const PvDoorScreen({
    super.key,
    required this.page,
    required this.bracket,
    required this.pregnancy,
    this.initialGroup,
  });

  final PvDoorPage page;

  /// ⚠️ THE WHOLE BRACKET, NOT A TITLE AND A HUE. The eyebrow is
  /// `bracket.label` — the exact string on the tile she tapped — so the two can
  /// never drift apart. See `PvDoorPage.heroTitle` for why this door carries
  /// its own headline as well and why that is not the same mistake.
  final Bracket bracket;

  final PregnancyController pregnancy;

  /// The tab to open on, by group id. Null opens the first.
  ///
  /// ⚠️ ADDED FOR MIND & MOOD'S DUPLICATION FIX. The V3 home has two actions,
  /// "Check how I am feeling" and "Help me feel better", and both used to open
  /// the same landing — the brief calls that out as a bug by name. They now
  /// open this door on Track and on Feel respectively. One door, two front
  /// doors into it; the tab is the whole difference.
  final String? initialGroup;

  @override
  State<PvDoorScreen> createState() => _PvDoorScreenState();
}

class _PvDoorScreenState extends State<PvDoorScreen> {
  late int _group = () {
    final id = widget.initialGroup;
    if (id == null) return 0;
    final i = widget.page.groups.indexWhere((g) => g.id == id);
    return i < 0 ? 0 : i;
  }();

  PvDoorPage get page => widget.page;
  Bracket get bracket => widget.bracket;

  /// Open a tile — or, when the tile names another tab of THIS door, switch
  /// to it instead of pushing anything.
  ///
  /// ⚠️ THE LAUNCHER CASE, INTERCEPTED HERE AND NOWHERE ELSE. Garbh Sanskar's
  /// Today tab is four cards that open the tabs below it, and the brief is
  /// explicit that Today "does not repeat" those tabs. A push would stack a
  /// second Listen on top of a door that already has one; a switch is what
  /// the tab selector does when she taps it herself. Everything else goes to
  /// the router, exactly as before.
  void _openTile(PvDoorTile tile) {
    final target = pvDoorTabTarget(tile);
    if (target == null) {
      openPvDoorTile(context, tile, widget.pregnancy);
      return;
    }
    final i = page.groups.indexWhere((g) => g.id == target);
    if (i < 0) return; // held by the door's own test, never seen by a user
    setState(() => _group = i);
    // ⚠️ AND BRING THE SELECTOR INTO VIEW. Found on the phone, 2026-09-12:
    // the card she tapped sits a screen below the selector, so a switch
    // with no scroll changed the content under her thumb and nothing she
    // could see said which tab she was now on. The selector at the top of
    // the screen is what says it — the same thing she sees when she picks
    // a tab herself.
    final ctx = _selectorAnchor.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          alignment: 0, duration: const Duration(milliseconds: 320));
    }
  }

  final GlobalKey _selectorAnchor = GlobalKey();

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
                  pregnancy: widget.pregnancy,
                ),
                PvDoorSheet(p: p, children: [
                  // ⚠️ THE ANCHOR A LAUNCHER CARD SCROLLS TO. See `_openTile`.
                  SizedBox(
                      key: _selectorAnchor,
                      // The rail rides up over the hero by its overlap, so
                      // the sheet's own top gap is spent lifting it.
                      height: kPvDoorRailDoors.contains(page.bracketId) ? 0 : 14),

                  // ---- the rail, across the seam ----------------------------
                  //
                  // ⚠️ IT STRADDLES: a negative top offset lifts the rail so
                  // its upper part sits over the photograph and its lower part
                  // on the sheet (Flo). The sheet is not clipped, so the cards
                  // paint over the hero; `kPvDoorHeroOverlap` already makes
                  // the photo run under the sheet's rounded top, so there is
                  // picture behind the lifted cards, not the tinted field.
                  if (kPvDoorRailDoors.contains(page.bracketId)) ...[
                    // A slot `overlap` shorter than the rail, with the rail
                    // painted upward out of it (clip none on the sheet), is
                    // what puts the cards' top half over the photograph.
                    SizedBox(
                      height: PvDoorRail.cardHeight - PvDoorRail.overlap,
                      child: OverflowBox(
                        alignment: Alignment.bottomCenter,
                        minHeight: PvDoorRail.cardHeight,
                        maxHeight: PvDoorRail.cardHeight,
                        child: PvDoorRail(
                        groups: groups,
                        counts: [for (final g in groups) _countFor(g)],
                        selected: _group,
                        p: p,
                        onPick: (i) => setState(() => _group = i),
                      ),
                      ),
                    ),
                    // The translate paints the rail higher but its layout
                    // slot stays where it was, so the content below already
                    // sits `overlap` further from the painted cards than the
                    // slot suggests; the sheet's top gap was zeroed above to
                    // pay some of that back. A small gap only, here.
                    const SizedBox(height: 4),
                  ] else

                  // ---- the selector, first thing under the hero ----------
                  //
                  // ⚠️ TWO SELECTORS, ONE DOOR AT A TIME — 2026-09-18. The deck
                  // (`PvDoorCarousel`) is the app's signature; the chip row
                  // (`PvDoorChips`) is what every app in the Mobbin set uses
                  // for a selector above content. The user asked to see (b)
                  // on Scans & tests and compare (BASE-UI-DECISIONS §2.8);
                  // `kPvDoorChipDoors` names the doors on chips. Same contract
                  // both ways, so the door itself does not know which it has.
                  if (kPvDoorTileDoors.contains(page.bracketId))
                    PvDoorTiles(
                      groups: groups,
                      counts: [for (final g in groups) _countFor(g)],
                      selected: _group,
                      p: p,
                      onPick: (i) => setState(() => _group = i),
                    )
                  else if (kPvDoorChipDoors.contains(page.bracketId))
                    PvDoorChips(
                      groups: groups,
                      counts: [for (final g in groups) _countFor(g)],
                      selected: _group,
                      p: p,
                      onPick: (i) => setState(() => _group = i),
                    )
                  else
                    PvDoorCarousel(
                      groups: groups,
                      counts: [for (final g in groups) _countFor(g)],
                      selected: _group,
                      p: p,
                      onPick: (i) => setState(() => _group = i),
                    ),
                  const SizedBox(height: 18), // was 26

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
                  //
                  // ⚠️ `note ?? noteFor(week)`. Garbh Sanskar's "Why this
                  // week" is about what is forming, so it is a function of
                  // her week; every other door's note is a constant. Same
                  // box either way.
                  if (group.note ??
                          group.noteFor?.call(widget.pregnancy.currentWeek)
                      case final note?) ...[
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
                  //
                  // ⚠️ `tilesFor(week)`, NOT `tiles`. A section may name one
                  // entry to lead for this woman — Nutrition's stage rail puts
                  // her own trimester first. Same cards for everyone, in an
                  // order that is hers. See `PvDoorSection.lead`.
                  //
                  // (The one-element inner `for` is Dart's only way to bind a
                  // local inside a collection literal; it runs once.)
                  for (final section in page.sectionsOf(group.id))
                    for (final tiles in [
                      section.tilesFor(widget.pregnancy.currentWeek)
                    ]) ...[
                    pvDoorPad(Text(section.heading,
                        style: pvFraunces(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.45,
                            color: p.ink1))),
                    const SizedBox(height: 13),
                    // ⚠️ EVERY SECTION IS A RAIL. ONE TILE, TWO TILES, A TOOL
                    // TAB — A RAIL. Decided by the user on the phone,
                    // 2026-09-11, and it reverses two earlier rules in this
                    // file: "tool tabs get full-width rows" and "a section of
                    // one tile gets a full-width row". Both were reasoned —
                    // a rail says "there is more sideways", and a rail of one
                    // card says it beside an empty gutter — and both broke
                    // the thing that matters more on a phone: that every
                    // door reads as ONE system. A woman learns the card once,
                    // on the first rail she sees, and then meets it on every
                    // section of every tab. The single wide row under the
                    // scans timeline looked like a different app's list.
                    //
                    // The user's words: *"we should need to maintain
                    // symmetry."* So `PvDoorLayout` no longer changes what a
                    // section draws — see its doc — and the one-tile rule is
                    // gone. What a rail of one costs (a gutter) is smaller
                    // than what it bought (a second card language).
                      // ⚠️ A HORIZONTAL RAIL PER SECTION, AND THE CARDS ARE
                      // DELIBERATELY CUT OFF AT THE RIGHT EDGE. Four sections
                      // holding nineteen stacked rows is a page you scroll for
                      // a long time past things you did not want; four rails is
                      // a page where every SECTION is reachable in one
                      // thumb-flick and the depth is sideways, where it costs
                      // nothing.
                      //
                      // ⚠️ AN INLINE SECTION DRAWS ITS OWN RAIL. The widget
                      // behind it listens to a store the page cannot — see
                      // `PvDoorSection.inline` — and it must draw a horizontal
                      // `ListView` of `PvDoorRailCard`s, because the symmetry
                      // test counts rails per section and does not know which
                      // kind of section it is counting.
                      if (section.inlineSurfaceId case final surface?)
                        pvDoorInlineToolFor(surface, widget.pregnancy) ??
                            const SizedBox(height: kPvRailCardHeight)
                      else
                      SizedBox(
                        height: kPvRailCardHeight,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: kPvDoorGutter),
                          itemCount: tiles.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: kPvRailGap),
                          itemBuilder: (context, i) => _RailCard(
                            tile: tiles[i],
                            p: p,
                            hue: hue,
                            index: i,
                            onTap: () => _openTile(tiles[i]),
                          ),
                        ),
                      ),
                    const SizedBox(height: 26),
                  ],

                  // ⚠️ THE CLOSING LINE, UNDER WHATEVER TAB IS OPEN. "Shown
                  // once" means once per page, not once per tab — a line that
                  // appears only under the last tab is a line most people never
                  // see.
                  //
                  // ⚠️ EXCEPT ON A TAB THAT ALREADY SAYS IT. Labour prep's area
                  // note and its closing line are literally the same constant,
                  // so its Talk tab printed one sentence at the top of the
                  // screen and again at the bottom. Seen on a phone,
                  // 2026-09-10.
                  //
                  // The check is identity, not similarity, and that is
                  // deliberate: an engine cannot tell that two differently
                  // worded cautions mean the same thing, and one that guessed
                  // would start hiding lines somebody wrote on purpose. Where
                  // the words merely overlap, the fix belongs in the data —
                  // see `pv_door_nutrition.dart`, which dropped its closing
                  // line for that reason.
                  if (page.closingLine case final line?
                      when line != group.note) ...[
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
    required this.pregnancy,
  });

  final PvDoorPage page;
  final PregnancyController pregnancy;
  final V2Palette p;
  final Color tint;

  /// `bracket.label` — the exact string on the tile that opened this.
  final String eyebrow;

  final Bracket bracket;

  /// How far the picture runs on under the sheet. On a rail door the cards
  /// float up over the seam, so the picture must reach up behind them or a
  /// band of the tinted field shows between photo and sheet (seen on the
  /// phone, 2026-09-18).
  double get _bleed => kPvDoorRailDoors.contains(page.bracketId)
      ? kPvDoorHeroOverlap + PvDoorRail.overlap
      : kPvDoorHeroOverlap;

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
          bottom: -_bleed,
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
          bottom: -_bleed,
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
          // On a rail door the cards float up over the seam by their
          // overlap, so the blurb needs that much more room below it.
          padding: EdgeInsets.fromLTRB(20, 8, 22,
              20 + (kPvDoorRailDoors.contains(page.bracketId) ? PvDoorRail.overlap - 12 : 0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Material(
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
                // A search CIRCLE sat here for an hour (2026-09-18) — the
                // user: "I meant a search bar inside each door." The bar is
                // under the blurb now. Kept for revert:
                //   const Spacer(),
                //   Material(color: white 55%, shape: CircleBorder,
                //     child: InkWell(onTap: openPvSearch(door: page),
                //       child: Icon(Icons.search_rounded)))
              ]),
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
              const SizedBox(height: 16),
              // ---- SEARCH, IN THE DOOR ----------------------------------------
              // Flo's topic page, exactly: title, one line, a white search
              // field, then the card rail (BASE-UI-DECISIONS §2.9). A door is
              // thirty to fifty things across five tabs; "NT scan" typed
              // beats two swipes and a scroll. Scoped to this door, with
              // "Everywhere" one tap away on the screen it opens.
              PvSearchBar(
                  key: kPvDoorSearchKey,
                  hint: 'Search $eyebrow',
                  p: p,
                  onTap: () => openPvSearch(context, pregnancy, door: page)),
              const SizedBox(height: 4),
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
      // ⚠️ A PAGE WITH A LENS ON IT, NOT A BARE LENS. A read is a lookup, so
      // the magnifier was the reasoning — but on Belly & skin, where nineteen
      // of twenty-two cards are reads, the mark paints at 96pt behind every
      // one of them, and a wall of bare magnifying glasses reads as a wall of
      // search boxes. Seen on a phone, 2026-09-10.
      //
      // The general shape: an icon chosen for what it MEANS has to be checked
      // for what it LOOKS LIKE at the size and the repetition it actually
      // ships at. `find_in_page` keeps the lookup idea and puts a document
      // under it, so the card still says "something written".
      PvDoorFormat.read => Icons.find_in_page_outlined,
      PvDoorFormat.mythFact => Icons.balance_rounded,
      PvDoorFormat.checklist => Icons.checklist_rtl_rounded,
      // A message rather than a calendar: the promise is a conversation, not a
      // slot.
      PvDoorFormat.talk => Icons.chat_bubble_outline_rounded,
      // A plate, not a book. The chip promises the app's own recipe page with
      // its serving scaler, and a book over a dish is the wrong promise.
      PvDoorFormat.recipe => Icons.restaurant_outlined,
      PvDoorFormat.video => Icons.play_circle_outline_rounded,
      PvDoorFormat.audio => Icons.headphones_outlined,
      // A puzzle piece: played, not used.
      PvDoorFormat.game => Icons.extension_outlined,
    };

/// One card on a rail.
///
/// ⚠️ THE DRAWING LIVES IN `PvDoorRailCard`, IN THE CHROME FILE; THIS IS THE
/// ADAPTER from a `PvDoorTile`. Promoted 2026-09-12 so an embedded tool (the
/// reports locker's "Add a report") can draw the same card without a tile.
/// The hue-step, the quiet 96pt mark, the meta line and the title-only face
/// are all unchanged — see the chrome file for the reasoning on each.
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
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvDoorRailCard(
        p: p,
        hue: hue,
        index: index,
        icon: pvDoorFormatIcon(tile.format),
        chip: tile.comingSoon ? 'Coming soon' : tile.format.label,
        title: tile.title,
        meta: tile.meta,
        dimmed: tile.comingSoon,
        onTap: onTap,
      );
}

// -----------------------------------------------------------------------------
//  RETIRED 2026-09-11, KEPT FOR REVERT — the full-width row a door section
//  used to draw on tool tabs and for one-tile sections. Every section is a
//  rail now (see the renderer above). The row itself lives on as
//  `PvDoorRow` in pv_door_chrome.dart, used by the screens that render INSIDE
//  a door — the conditions browse, the report tool's topics, the reports
//  locker's "Add a report" — which are lists by nature and stay lists.
// -----------------------------------------------------------------------------
//
// /// One full-width row, on a tool tab.
// ///
// /// ⚠️ IT SHOWS THE BLURB AND THE RAIL CARD DOES NOT. There is room here, and on
// /// a tab with two or three rows the extra line is what stops them reading as an
// /// afterthought under the tool above.
// ///
// /// ⚠️ THE DRAWING LIVES IN `PvDoorRow`, IN THE CHROME FILE, AND THIS IS ONLY
// /// THE ADAPTER. A screen embedded in a door — `ConditionsHomeBody` — needs the
// /// same row and holds `ConditionEntry`s rather than `PvDoorTile`s. Keeping the
// /// paint in a widget that takes plain values means the door's language is
// /// available to a caller that has never heard of the door engine, and the two
// /// cannot drift into looking almost the same.
// class _WideTile extends StatelessWidget {
//   const _WideTile({
//     required this.tile,
//     required this.p,
//     required this.hue,
//     required this.onTap,
//   });
//
//   final PvDoorTile tile;
//   final V2Palette p;
//   final double hue;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) => PvDoorRow(
//         p: p,
//         hue: hue,
//         icon: pvDoorFormatIcon(tile.format),
//         chip: tile.comingSoon ? 'Coming soon' : tile.format.label,
//         title: tile.title,
//         blurb: tile.blurb,
//         dimmed: tile.comingSoon,
//         onTap: onTap,
//       );
// }

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

  // ⚠️ NO BOX — 2026-09-18, the door walk. This was a pink well (radius 20,
  // `kPvUrgentTint`) and the user's words for it were "a big blob thrown at
  // the screen… ruins the whole UI". Flo's own "seek immediate medical help
  // if" is the reference (Mobbin): a bold lead sentence, the signs as a
  // plain list with one coral dot each, on the page itself. So: a rule, the
  // heading in the display face, the lines with a dot, the foot in grey.
  // The dot is the only colour, and it is the one signal that says "call".
  // The old well stays below for revert.
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: flag.seeAll ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 1.5, color: p.ink1),
            const SizedBox(height: 14),
            Text(flag.title,
                style: pvFraunces(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.3,
                    color: p.ink1)),
            const SizedBox(height: 10),
            for (final line in flag.lines)
              GestureDetector(
                onTap: line.conditionId == null
                    ? null
                    : () => onLine(line.conditionId!),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, right: 11),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: kPvUrgentInk, shape: BoxShape.circle),
                          ),
                        ),
                        Expanded(
                          child: Text(line.text,
                              style: pvManrope(
                                  fontSize: 14, height: 1.5, color: p.ink1)),
                        ),
                        if (line.conditionId != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2, left: 6),
                            child: Icon(Icons.chevron_right_rounded,
                                size: 16, color: p.ink3),
                          ),
                      ]),
                ),
              ),
            if (flag.footer case final footer?) ...[
              const SizedBox(height: 8),
              Text(footer,
                  style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2)),
            ],
            if (flag.seeAll) ...[
              const SizedBox(height: 10),
              Text('See all of these',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: p.ink1)),
            ],
            const SizedBox(height: 14),
            Container(height: 1, color: p.line),
          ],
        ),
      );

  // Kept for revert — the pink well, 2026-09-10 → 2026-09-18.
  // ignore: unused_element
  Widget buildWell(BuildContext context) => GestureDetector(
        onTap: flag.seeAll ? onTap : null,
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
              for (final line in flag.lines) ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                ]),
                const SizedBox(height: 9),
              ],
              if (flag.footer case final footer?)
                Text(footer,
                    style: pvManrope(
                        fontSize: 12, height: 1.55, color: p.ink2)),
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
  // No box (2026-09-18): the note sits on the page, an icon and a line of
  // grey. Was a 4% ink well, radius 14 — kept for revert.
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline_rounded, size: 15, color: p.ink3),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(note,
                style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
          ),
        ]),
      );
}
