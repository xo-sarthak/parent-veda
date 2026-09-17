// =============================================================================
//  PpSection / PpSectionScreen — the landing screen every spec describes
// -----------------------------------------------------------------------------
//  ⚠️ ELEVEN SPECS DESCRIBE THE SAME LANDING SCREEN IN ALMOST THE SAME WORDS.
//
//    Sleep:  "a landing screen leading to seven content areas plus the tools...
//             soft one-line intro, entry tiles for the seven areas"
//    Others: an age-banded landing where "the child's own band leads" and the
//             other bands stay browsable.
//
//  So it is built once. A section author declares a `PpSection` — an intro line,
//  a list of areas, a band set, and its tools — and gets the screen.
//
//  ⚠️ THE THING THIS SHAPE IS DESIGNED TO PREVENT is the screen the parenting app
//  already has behind 39 of its 40 doors: a generic layer-ordered list that shows
//  "Articles · Videos · Products · Consult" whatever the door was about. The
//  specs name it directly — "Health is one of the 39 brackets still opening the
//  generic layer-ordered screen; build it to the new hub model". An AREA is a
//  question a parent has ("Why does my baby wake at night?"); a LAYER is a
//  content type we happen to own. Ordering a screen by layer is the supply-side
//  thinking the whole door audit was against.
//
//  ⚠️ AND AN AREA CARRIES ITS OWN PAGES. Not a route to be wired later — the
//  pages are right there in the data, so "does this area open to anything?" is a
//  property of the data and a test can walk all eleven sections and prove no area
//  is empty. Correct-but-unreachable content is the failure this repo has
//  actually hit, which is why the wiring gate exists.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../data/hubs/hub_registry.dart';
import '../../localization/app_language.dart';
import '../brackets/hub/hub_config.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../brackets/hub/problem_hub_screen.dart';
import '../v2/v2_palette.dart';
import 'pp_age_bands.dart';
import 'pp_child_profile.dart';
import 'pp_content.dart';
import 'pp_page_read.dart';
import 'pp_story_screen.dart';

/// ⚠️ THE ONE WAY A PAGE OPENS, FROM ANY SCREEN.
///
/// A tool page opens its surface. A CAROUSEL page opens the story screen. An
/// INTERACTIVE page opens the step-through. Everything else opens as content.
/// The TTC doors state the rule this exists to keep: "tapping a piece of
/// content should open that piece of content, full screen, every time" — a
/// Carousel chip that lands on prose with a second card to tap is a chip that
/// lied. It was true on the door and false on the library screen for one
/// build; one function is how it stays true on both, and on the next screen
/// somebody adds.
void ppOpenPage(
  BuildContext context,
  PpSection section,
  PpPage page, {
  void Function(BuildContext, String)? onSurface,
}) {
  if (page.toolSurfaceId != null) {
    onSurface?.call(context, page.toolSurfaceId!);
    return;
  }
  final (screen, kind) = _ppPageScreenAndKind(section, page, onSurface: onSurface);
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: 'pp/${section.id}/$kind/${page.id}'),
    builder: (_) => screen,
  ));
}

/// The screen `ppOpenPage` would push for a page, without pushing it — so
/// the router can hand a page in ANOTHER section back as a surface
/// (`pp_page/<section>/<page>`). Tool pages have no screen of their own;
/// resolve `toolSurfaceId` through the router instead.
Widget ppPageScreen(
  PpSection section,
  PpPage page, {
  void Function(BuildContext, String)? onSurface,
}) =>
    _ppPageScreenAndKind(section, page, onSurface: onSurface).$1;

(Widget, String) _ppPageScreenAndKind(
  PpSection section,
  PpPage page, {
  void Function(BuildContext, String)? onSurface,
}) {
  void openById(BuildContext ctx, String id) {
    final target = section.pageById(id);
    if (target == null) return;
    ppOpenPage(ctx, section, target, onSurface: onSurface);
  }

  final format = page.format?.toUpperCase();
  final months = ChildProfileStore.instance.ageInMonths;

  // ⚠️ CARDS IS A STORY — see `ppCardsAsSlides`. One format per tag.
  if (format == 'CARDS') {
    final slides = ppCardsAsSlides(page);
    if (slides != null) {
      PpIntro? intro;
      for (final b in page.blocks) {
        if (b is PpIntro) {
          intro = b;
          break;
        }
      }
      double hue = 268;
      for (final b in page.blocks) {
        if (b is PpCards) {
          hue = b.hue;
          break;
        }
      }
      return (
        PpStoryScreen(
          title: page.title,
          cards: slides,
          hue: hue,
          coverTitle: page.title,
          coverBlurb: page.subtitle ?? intro?.text,
          onPage: openById,
        ),
        'story',
      );
    }
  }

  for (final b in page.blocks) {
    if (b is PpCarousel && format == 'CAROUSEL') {
      final cards = b.cardsFor(months);
      if (cards.isEmpty) break;
      return (
        PpStoryScreen(
          title: b.eyebrow ?? page.title,
          cards: cards,
          hue: b.hue,
          coverTitle: b.coverTitle,
          coverBlurb: b.coverBlurb,
          onPage: openById,
        ),
        'story',
      );
    }
    if (b is PpInteractive && format == 'INTERACTIVE') {
      // ⚠️ AN INTERACTIVE IS A STORY. Decided on a phone, 2026-09-12: the
      // carousel and the interactive are one design — cover, one idea per
      // slide, tap right for next, tap left for back, chevrons — and the
      // done / not-yet buttons are gone. Each step is a slide; the closing
      // is the last slide, and swipes up to its page if it has one. The
      // step-through screen with the buttons is kept (`pp_interactive_
      // screen.dart`) for revert and is opened by nothing.
      return (
        PpStoryScreen(
          title: b.title,
          cards: ppInteractiveAsSlides(b),
          hue: b.hue,
          coverTitle: b.title,
          coverBlurb: b.blurb,
          // The brief's "dark and dim" for the 3am page: the same story, on
          // a darker ground. Everything else stays in the day palette.
          dim: b.kind == PpInteractiveKind.night,
          onPage: openById,
        ),
        'interactive',
      );
    }
  }
  // ⚠️ THE ARTICLE FORMAT, 2026-09-17 — every parenting page reads in the
  // one reader (pp_page_read.dart). `PpContentPage` is kept for revert and
  // opened by nothing; test/reader_unification_test.dart holds that.
  // return (
  //   PpContentPage(page: page, onSurface: onSurface, onPage: openById),
  //   'page',
  // );
  return (
    ppPageReader(section, page, onSurface: onSurface, onPage: openById),
    'page',
  );
}

/// One area within a section: a question, and the pages that answer it.
class PpArea {
  const PpArea({
    required this.id,
    required this.title,
    required this.blurb,
    this.pages = const [],
    this.bands = const [],
    this.hue = 268,
    this.mark = IntentMark.listMark,
    this.toolSurfaceId,
    this.cover,
    this.pinned = false,
  });

  final String id;

  /// ⚠️ PHRASED AS HER QUESTION OR THE THING SHE DOES, never as the mechanism.
  /// The First 40 Days spec states the rule for all of them: "Label everything by
  /// the MOTHER'S QUESTION or the thing she DOES, not by the mechanism. Never
  /// ship an engineer label like 'activities', 'tracker' or 'module' as a
  /// user-facing name."
  final String title;

  final String blurb;

  /// The pages behind this area. An area with no pages and no tool is a hole,
  /// and `test/pp_section_test.dart` fails on one.
  final List<PpPage> pages;

  /// Which bands this area belongs to. Empty means all of them.
  final List<String> bands;

  final double hue;

  /// ⚠️ A DRAWN MARK, NOT A MATERIAL ICON.
  ///
  /// The area tiles shipped with `Icons.menu_book_outlined` on every one of
  /// them, which the review caught twice: "new screens again scream purple and
  /// old icons". A stock glyph is the one thing in this app that belongs to no
  /// product -- the pregnancy doors have used hand-drawn `IntentMark` art since
  /// the door audit, and a parenting area sitting next to them in a stock book
  /// icon reads as a different app.
  ///
  /// The mark is chosen by MEANING, which is `hub_intent_art.dart`'s own rule:
  /// the same act looks the same everywhere, so "log a reading" is `chartLog`
  /// whether it is sleep or blood pressure.
  final IntentMark mark;

  /// An area that IS a tool rather than reading — the sleep log, the quick
  /// check. Opens through the router instead of listing pages.
  final String? toolSurfaceId;

  /// ⚠️ RENDERED ABOVE THE GRID, FULL WIDTH, AS ONE WIDE CARD.
  ///
  /// For the area that is not one shelf among several but the honest answer
  /// the whole section is built around — Potty's "how long does this actually
  /// take", which the feedback describes as "a constant, and like a tool
  /// should look different from other articles".
  ///
  /// It is a presentation flag rather than a new concept: a pinned area is
  /// still an area, still band-filtered, still opens the same way. Making it a
  /// separate model would have meant every section screen learning about two
  /// kinds of thing.
  ///
  /// At most one per section, by convention rather than by assertion — two
  /// pinned areas is just a second grid with a different card, which defeats
  /// the point of pinning either.
  final bool pinned;

  /// ⚠️ NULL IS A STATE, NOT AN OVERSIGHT.
  ///
  /// The feedback asks for these tiles to become cards "like we have reels on
  /// Insta ... with Title written and a cover image put". Photography for
  /// eleven sections does not exist yet, and waiting for it would mean either
  /// shipping nothing or shipping a grey rectangle that has to be replaced by
  /// a different widget later.
  ///
  /// So the card is the FINISHED component running in its file-less state: a
  /// null cover paints the section's own tinted ground with its drawn mark,
  /// which is a real cover rather than a placeholder for one. When a
  /// photograph arrives, this becomes an asset path and no widget is touched.
  /// Same seam as `MmCalmAudio.asset` on the pregnancy side, for the same
  /// reason — a placeholder you delete to ship is a second implementation.
  final String? cover;

  bool inBand(String band) => bands.isEmpty || bands.contains(band);

  /// Pages in this area that fit the given band and are listed.
  ///
  /// ⚠️ `linkedOnly` PAGES ARE NOT HERE. They resolve by id (`pageById`) and
  /// open from a carousel or a link; they are never a tile. See `PpPage.linkedOnly`.
  List<PpPage> pagesFor(String band) =>
      [for (final p in pages) if (p.inBand(band) && !p.linkedOnly) p];
}

/// A whole section — one of the eleven parenting brackets.
class PpSection {
  const PpSection({
    required this.id,
    required this.title,
    required this.intro,
    required this.areas,
    this.subtitle,
    this.bandSet,
    this.tools = const [],
    this.autoScope = false,
  });

  /// Matches the hub's `bracketId` so the router can find it.
  final String id;

  /// ⚠️ THE AGE RULE: THE APP KNOWS HER AGE, SO IT DOES NOT ASK.
  ///
  /// The Sleep rebuild states it for the whole app and applies it to Sleep
  /// first: "Remove every age chooser and every 'enter her age'. Other-age
  /// content is hidden, not tucked one tap away. The tracker's 'Typical for N
  /// weeks' is the correct pattern; match it."
  ///
  /// With this on, the band chips are not drawn, the section is locked to the
  /// child's own band, and the landing says which age it is showing rather
  /// than offering the others. The band SET stays exactly as it was — every
  /// page keeps its tags, `bandSet.active` still decides — so turning this on
  /// for a section is one line and turning it off again is the same line.
  ///
  /// ⚠️ A FLAG READ IN ONE PLACE, ON PURPOSE. Sleep is the first door rebuilt
  /// under the rule; the other nine sections keep their chooser until their
  /// own rebuild says otherwise. Flipping all ten at once from here would be
  /// touching areas the brief said not to touch.
  ///
  /// ⚠️ THIS IS THE ONE PLACE PERSONALISATION HIDES STRUCTURE — and it is
  /// still not structure. The seven collections are the same for every
  /// parent; what is hidden is other-age CONTENT within them. That is the
  /// line `test/landing_focus_test.dart` draws, and this stays on the right
  /// side of it.
  final bool autoScope;

  final String title;
  final String? subtitle;

  /// The "soft one-line intro" every spec opens with.
  final String intro;

  final List<PpArea> areas;

  /// Null for a section that is not age-banded. Most are.
  final PpBandSet? bandSet;

  /// Tools, surfaced separately from the reading areas because a tool is
  /// something she uses rather than something she reads.
  final List<PpSectionTool> tools;

  /// Every page in the section, flattened. Used by search, by the wiring tests,
  /// and by anything that needs to resolve a page id.
  List<PpPage> get allPages => [for (final a in areas) ...a.pages];

  PpPage? pageById(String id) {
    for (final p in allPages) {
      if (p.id == id) return p;
    }
    return null;
  }
}

class PpSectionTool {
  const PpSectionTool({
    required this.label,
    required this.blurb,
    required this.surfaceId,
    this.icon = Icons.build_outlined,
  });
  final String label;
  final String blurb;

  /// ⚠️ MUST RESOLVE THROUGH THE ROUTER. A tool tile that leads nowhere is worse
  /// than no tile, and it is exactly what the wiring gate exists to catch.
  final String surfaceId;
  final IconData icon;
}

// =============================================================================
//  THE SCREEN
// =============================================================================

class PpSectionScreen extends StatefulWidget {
  const PpSectionScreen({
    super.key,
    required this.section,
    this.onSurface,
    this.initialAreaId,
  });

  /// ⚠️ OPENS STRAIGHT INTO ONE AREA, AND IT EXISTS BECAUSE TWO HUB DOORS
  /// WERE LANDING IN THE SAME PLACE.
  ///
  /// Potty's hub offers "Is she ready yet?" and "Start and manage potty
  /// training" and both resolved to `pp_section/parenting_potty` — the same
  /// landing, so two differently-worded questions got one identical answer.
  /// That is the third time this review has found that exact shape (Nutrition,
  /// Development, and here), and it is always the same cause: a section id is
  /// easy to route to and an area id was not addressable.
  ///
  /// Null keeps the old behaviour exactly.
  final String? initialAreaId;

  final PpSection section;
  final void Function(BuildContext context, String surfaceId)? onSurface;

  @override
  State<PpSectionScreen> createState() => _PpSectionScreenState();
}

class _PpSectionScreenState extends State<PpSectionScreen> {
  PpSection get s => widget.section;

  /// The closing offer's surface, when this screen is the one that has to show
  /// it. Null whenever a hub screen exists to show it instead, or when the
  /// closing routes by action rather than by surface.
  String? get _closingSurface {
    if (showsHubScreen(s.id)) return null;
    return hubFor(s.id)?.closing?.surfaceId;
  }


  /// Which band is selected. Starts at the child's own — see `PpBandSet.ordered`.
  String? _band;

  @override
  void initState() {
    super.initState();
    _band = s.bandSet?.active.id;

    // ⚠️ DEEP LINK AFTER THE FIRST FRAME, NOT DURING IT. Pushing a route from
    // `initState` throws — there is no Navigator context yet — and doing it in
    // `build` would re-fire on every rebuild, including every band change.
    //
    // The landing is still built underneath, deliberately: she arrives inside
    // the area she asked for and Back takes her to the section rather than out
    // of it, which is what a door should feel like.
    final target = widget.initialAreaId;
    if (target == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final area = s.areas.where((a) => a.id == target).firstOrNull;
      // An unknown id lands on the section landing rather than throwing. It is
      // a routing typo, and a parent should meet it as "the right section"
      // rather than as a crash. `test/pp_potty_doors_test.dart` catches it in
      // CI instead.
      if (area == null) return;
      _openArea(context, area, _band ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listening rather than reading: the band has to follow the active child, and
    // a parent can switch children from My Child while this screen is alive.
    return AnimatedBuilder(
      animation: Listenable.merge(
          [ChildProfileStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final bands = s.bandSet;
        // ⚠️ AUTO-SCOPE FOLLOWS THE CHILD, LIVE. `_band` is the chooser's
        // memory; a section with no chooser reads the active band every
        // build, so switching children on My Child re-scopes this screen
        // without a tap.
        final band = s.autoScope
            ? bands?.active.id ?? ''
            : _band ?? bands?.active.id ?? '';
        final areas = [
          for (final a in s.areas)
            if (a.inBand(band)) a,
        ];

        return Scaffold(
          backgroundColor: p.ground,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
              children: [
                _V3Back(p: p),
                const SizedBox(height: 18),
                Text(s.title, style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w600, height: 1.22, color: p.ink1)),
                const SizedBox(height: 9),
                Text(s.intro, style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),

                // ---- auto-scoped: say which age, offer no other -------------
                //
                // The tracker's "Typical for N weeks" line, in the library's
                // vocabulary. It is a statement, not a control: there is
                // nothing to tap, which is the whole of the age rule.
                if (bands != null && s.autoScope) ...[
                  const SizedBox(height: 16),
                  Row(children: [
                    Icon(Icons.child_care_outlined, size: 15, color: p.action),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                          'FOR ${ChildProfileStore.instance.nameMid.toUpperCase()}'
                          '  ·  ${bands.active.label.toUpperCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: p.action)),
                    ),
                  ]),
                ],

                // ---- the band chooser ----------------------------------------
                if (bands != null && !s.autoScope) ...[
                  const SizedBox(height: 22),
                  // ⚠️ HER CHILD'S BAND LEADS AND THE REST STAY REACHABLE.
                  // `ordered` puts hers first; nothing is removed.
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      for (final b in bands.ordered) ...[
                        _BandChip(
                          p: p,
                          label: b.label,
                          selected: b.id == band,
                          mine: b.id == bands.active.id,
                          onTap: () => setState(() => _band = b.id),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ]),
                  ),
                  if (bands.byId(band)?.blurb != null) ...[
                    const SizedBox(height: 12),
                    Text(bands.byId(band)!.blurb!,
                        style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
                  ],

                  // ⚠️ SAY SO WHEN THE CHIPS CHANGE NOTHING.
                  //
                  // Reported as "inside the traditions door the toggles don't
                  // seem to work". They were working -- `_band` changed and the
                  // filter ran -- but Traditions deliberately leaves almost every
                  // page untagged so a ceremony already past stays browsable. So
                  // tapping a chip re-filtered a list where nothing was filtered
                  // out, and from the outside that is indistinguishable from a
                  // dead control.
                  //
                  // Both halves of that are right, which is why the fix is
                  // neither "tag everything" (it would hide the mundan page from
                  // a newborn parent who wants to read ahead) nor "remove the
                  // chips" (they do change the reading order and the blurb).
                  // The screen says what is true: this section is written to be
                  // read at any age.
                  if (_bandChangesNothing(s))
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                          'Everything here is worth reading at any age. The age '
                          'above just changes what comes first.',
                          style: pvManrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: p.ink3)),
                    ),
                ],

                const SizedBox(height: 26),

                // ---- the areas ------------------------------------------------
                // ⚠️ CARDS, NOT ROWS — and `_AreaTile` is kept below rather
                // than deleted, per comment-out-never-delete. Reverting is
                // swapping this grid back for the loop it replaced.
                // ⚠️ THE PINNED AREA, IF THERE IS ONE, SITS ABOVE THE GRID AS A
                // WIDE CARD. See `PpArea.pinned`. Filtered out of the grid
                // below so it does not appear twice.
                for (final a in areas.where((a) => a.pinned)) ...[
                  _PinnedAreaCard(
                    area: a,
                    p: p,
                    onTap: () => _openArea(context, a, band),
                  ),
                  const SizedBox(height: 14),
                ],

                _PpCardGrid(children: [
                  for (final a in areas.where((a) => !a.pinned))
                    _PpCoverCard(
                      title: a.title,
                      meta: a.pagesFor(band).length > 1
                          ? '${a.pagesFor(band).length} PAGES'
                          : null,
                      hue: a.hue,
                      mark: a.mark,
                      cover: a.cover,
                      p: p,
                      onTap: () => _openArea(context, a, band),
                    ),
                ]),

                // ⚠️ AN EMPTY BAND STILL SAYS SOMETHING. It should not happen —
                // the tests forbid it — but if content is ever band-tagged wrong,
                // a blank screen reads as a broken app rather than as a gap.
                if (areas.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                        'Nothing here for this age yet. Try another age above.',
                        style: pvManrope(fontSize: 14, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
                  ),

                // ---- tools and the expert offer, WHEN THIS IS THE TOP SCREEN --
                // ⚠️ THE CONDITION IS THE WHOLE POINT, AND ITS ABSENCE COST
                // SEVENTEEN TOOLS.
                //
                // Tools were moved off this screen and up onto the hub, which
                // was right for the brackets that HAVE a hub screen. Four do
                // not: a hub with a single door opens that door's destination
                // directly, so Behaviour, Health, First 40 Days and Traditional
                // land a parent straight here. Their tools were declared, were
                // routable, were tested for resolvability -- and were drawn by
                // nothing. Health alone stranded nine.
                //
                // Reported from the outside as the symptom it is: Behaviour
                // "opens in a very different ui than others". It was not a
                // styling drift. The screen was genuinely missing a section
                // every other bracket shows.
                //
                // ⚠️ ASK THE REGISTRY, DO NOT LIST THE FOUR. `showsHubScreen`
                // already answers "does this bracket render a hub?", and it is
                // the same function `pp_home_v3` branches on. A hardcoded list
                // here would be a second copy of that decision, and the day a
                // fifth door is added to Health the two would disagree
                // silently -- tools drawn twice, which is how this block came
                // to be commented out in the first place.
                if (!showsHubScreen(s.id)) ...[
                  if (s.tools.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Row(children: [
                      Text('TOOLS',
                          style: pvManrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                              color: p.action.withValues(alpha: 0.85))),
                      const SizedBox(width: 10),
                      Expanded(child: Container(height: 1, color: p.line)),
                    ]),
                    const SizedBox(height: 12),
                    for (final t in s.tools) ...[
                      HubToolRow(
                        tool: HubTool(
                          // ⚠️ BOTH SIDES IDENTICAL ON PURPOSE, and it is not
                          // `_t(x, x)` sloppiness: `PpSectionTool` carries a
                          // plain `String`, because parenting is not migrated
                          // to Hindi yet. Wrapping it keeps ONE tool row for
                          // both screens instead of a second widget that takes
                          // strings, and the language genuinely cannot change
                          // what renders until that content is translated.
                          label: LocalizedText(en: t.label, hi: t.label),
                          blurb: LocalizedText(en: t.blurb, hi: t.blurb),
                          surfaceId: t.surfaceId,
                          icon: t.icon,
                        ),
                        p: p,
                        lang: AppLanguage.english,
                        onTap: () => widget.onSurface
                            ?.call(context, t.surfaceId),
                      ),
                      if (t != s.tools.last) const SizedBox(height: 9),
                    ],
                  ],

                  // ⚠️ AND THE EXPERT OFFER, WHICH THESE FOUR ALSO NEVER HAD.
                  // Every hub-screen bracket ends on "talk to someone". These
                  // four ended on the last card of a grid. Read from the hub so
                  // the offer is declared once, beside the doors it closes.
                  //
                  // Only a closing that names a SURFACE renders here: this
                  // screen has no `onAction`, and quietly drawing a card whose
                  // tap does nothing is worse than not drawing it.
                  if (_closingSurface != null) ...[
                    const SizedBox(height: 22),
                    HubClosingCard(
                      closing: hubFor(s.id)!.closing!,
                      p: p,
                      lang: AppLanguage.english,
                      onTap: () =>
                          widget.onSurface?.call(context, _closingSurface!),
                    ),
                  ],
                ],

                // ---- the tools -----------------------------------------------
                // ⚠️ THE TOOLS MOVED UP TO THE HUB. Feedback: "Move tools out
                // of Help My Child Sleep section and bring it out on main
                // Sleep section above Talk to Sleep expert." They were here,
                // behind one of the hub's two doors, so a mother who wanted
                // the sleep log had to first pick the door about a problem she
                // might not have. `pp_home_v3.dart` now reads
                // `ppSectionFor(bracketId).tools` and hands them to
                // `ProblemHubScreen`, so this list is still the ONE place
                // tools are declared — only the screen that renders them
                // changed.
                //
                // ⚠️ LEAVING THIS BLOCK ACTIVE WOULD HAVE SHOWN THEM TWICE,
                // which is the failure mode of "add it there" without also
                // removing it here. Kept commented, per comment-out-never-
                // delete, so reverting is uncommenting.
/*
                // ---- the tools ------------------------------------------------
                if (s.tools.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Text('TOOLS',
                      style: pvManrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                          color: p.action.withValues(alpha: 0.85))),
                  const SizedBox(height: 12),
                  for (final t in s.tools) ...[
                    _ToolTile(
                      tool: t,
                      p: p,
                      onTap: widget.onSurface == null
                          ? null
                          : () => widget.onSurface!(context, t.surfaceId),
                    ),
                    const SizedBox(height: 9),
                  ],
                ],
*/
              ],
            ),
          ),
        );
      },
    );
  }

  /// True when switching band yields the same visible areas every time, so the
  /// chips cannot narrow anything the reader can see.
  ///
  /// ⚠️ COMPARES THE RESULT, NOT THE TAGS. The first version asked "is every
  /// area untagged", which was wrong for exactly the section that prompted this:
  /// Traditions tags ONE area (the which-ceremony-is-next calendar) and leaves
  /// the other six open on purpose. Six of seven rows never moving is what reads
  /// as broken, and a tag-counting test says everything is fine.
  bool _bandChangesNothing(PpSection section) {
    final set = section.bandSet;
    if (set == null || set.bands.length < 2) return false;

    // ⚠️ THE SIGNATURE INCLUDES PAGE COUNTS, AND THAT MATTERS FOR A WHOLE
    // SECTION.
    //
    // The first version compared only WHICH AREAS were visible. Development
    // tags none of its areas — all five are worth opening at any age — but it
    // tags most of its PAGES, so switching band changes what is behind every
    // tile without changing the tiles themselves. By the old comparison that
    // is "nothing changes", so the section printed "everything here is worth
    // reading at any age" underneath chips that were quietly doing real work.
    //
    // Reported as "if the content needs to change by age, it is not happening
    // by changing the tabs". The chips were changing it; the screen was
    // telling her they were not, and the card labels ("6 PAGES") are the thing
    // that actually shifts.
    //
    // Traditions still gets the note, correctly: it leaves pages untagged on
    // purpose, so its counts really are identical across every band.
    String signature(String b) => [
          for (final a in section.areas)
            if (a.inBand(b)) '${a.id}:${a.pagesFor(b).length}',
        ].join('|');

    final first = signature(set.bands.first.id);
    return set.bands.every((b) => signature(b.id) == first);
  }

  void _openArea(BuildContext context, PpArea a, String band) {
    // An area that is a tool opens the tool. Nothing in between.
    if (a.toolSurfaceId != null) {
      widget.onSurface?.call(context, a.toolSurfaceId!);
      return;
    }
    final pages = a.pagesFor(band);
    if (pages.isEmpty) return;

    // ⚠️ ONE PAGE OPENS DIRECTLY. A list screen holding a single row is a tap
    // that exists only because the code has a list in it.
    if (pages.length == 1) {
      _openPage(context, pages.first);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'pp/${s.id}/${a.id}'),
      builder: (_) => _AreaScreen(
        section: s,
        area: a,
        pages: pages,
        onSurface: widget.onSurface,
        onPage: _openPageById,
      ),
    ));
  }

  void _openPage(BuildContext context, PpPage p) =>
      ppOpenPage(context, s, p, onSurface: widget.onSurface);

  /// ⚠️ RESOLVES A `PpLink(pageId:)` AGAINST THIS SECTION.
  ///
  /// The resolver lives here rather than in `pp_content.dart` because a block
  /// does not know which section it is in, and the block model must not import
  /// the registry -- the registry already imports the block model, and that
  /// would be a cycle.
  ///
  /// An unknown id does nothing rather than throwing. It is caught by
  /// `test/pp_section_test.dart`, so a bad id fails a build rather than a phone.
  void _openPageById(BuildContext context, String pageId) {
    final target = s.pageById(pageId);
    if (target == null) return;
    _openPage(context, target);
  }
}

/// An area's page list.
class _AreaScreen extends StatelessWidget {
  const _AreaScreen({
    required this.section,
    required this.area,
    required this.pages,
    this.onSurface,
    this.onPage,
  });

  final PpSection section;
  final PpArea area;
  final List<PpPage> pages;
  final void Function(BuildContext, String)? onSurface;
  final void Function(BuildContext, String)? onPage;

  /// A tool page opens its surface; any other page opens as content. The
  /// same branch `_PpSectionScreenState._openPage` takes, kept here because
  /// this screen pushes its own routes.
  void _open(BuildContext context, PpPage page) =>
      ppOpenPage(context, section, page, onSurface: onSurface);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) {
          // ⚠️ NAMED `pal`, NOT `p`. The list below binds each PpPage to `p`,
          // and the two shadowed each other silently -- every palette read
          // inside the loop resolved against a page instead. It failed loudly
          // here, but the same collision inside a builder that happens to have
          // both in scope would not.
          final pal = V2PaletteStore.instance.current;
          return Scaffold(
            backgroundColor: pal.ground,
            body: SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
                children: [
                  _V3Back(p: pal),
                  const SizedBox(height: 20),
                  Text(area.title,
                      style: pvFraunces(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          height: 1.18,
                          letterSpacing: -0.6,
                          color: pal.ink1)),
                  const SizedBox(height: 9),
                  Text(area.blurb,
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                          color: pal.ink2)),
                  const SizedBox(height: 26),
                  // ⚠️ A PINNED PAGE SITS ABOVE THE GRID AS ONE WIDE CARD.
                  // Same treatment as a pinned area, same reasoning — see
                  // `PpPage.pinned`. Filtered out of the grid below.
                  for (final page in pages.where((p) => p.pinned)) ...[
                    _PinnedPageCard(
                      page: page,
                      area: area,
                      p: pal,
                      onTap: () => _open(context, page),
                    ),
                    const SizedBox(height: 14),
                  ],
                  // ⚠️ THE SAME CARD ONE LEVEL DOWN, because the note says
                  // so explicitly: "when user clicks and inside it also each
                  // small section that is there become a card". A library
                  // that changes its vocabulary between the shelf and the
                  // shelf's contents reads as two products.
                  //
                  // ⚠️ THE HUE WALKS PER CARD rather than repeating the
                  // area's. Sixteen identical tinted cards is a wall; a
                  // 17-degree step keeps them recognisably one family while
                  // giving the eye somewhere to land. 17 because it is
                  // coprime with 360, so a long list never repeats a tint
                  // next to itself.
                  _PpCardGrid(children: [
                    for (final (i, page)
                        in pages.where((p) => !p.pinned).toList().indexed)
                      _PpCoverCard(
                        title: page.title,
                        meta: page.format,
                        hue: (area.hue + i * 17) % 360,
                        mark: area.mark,
                        p: pal,
                        onTap: () => _open(context, page),
                      ),
                  ]),
                ],
              ),
            ),
          );
        },
      );
}

/// V3's back control: a hairline circle on the ground, never a filled disc.
class _V3Back extends StatelessWidget {
  const _V3Back({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: p.line),
            ),
            child: Icon(Icons.arrow_back_rounded, size: 19, color: p.ink1),
          ),
        ),
      );
}

class _BandChip extends StatelessWidget {
  const _BandChip(
      {required this.p,
      required this.label,
      required this.selected,
      required this.mine,
      required this.onTap});

  final V2Palette p;
  final String label;
  final bool selected;

  /// Whether this is the band the child is actually in.
  final bool mine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? p.action : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? p.action : p.line),
          ),
          child: Row(children: [
            // A quiet dot marks her child's own band, so switching away and back
            // does not mean re-deriving which one was hers.
            if (mine) ...[
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : p.action,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
            ],
            Text(label,
                style: pvManrope(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? Colors.white : p.ink2)),
          ]),
        ),
      );
}

/* ⚠️ KEPT FOR REVERT — the row-shaped area tile the cover cards
   replaced. The feedback asked for reels-shaped cards with a title and a
   cover; if that lands badly on a real phone, restoring this widget and
   the `for (final a in areas)` loop in the landing is the whole revert.
   Commented rather than deleted, per the repo rule.

class _AreaTile extends StatelessWidget {
  const _AreaTile(
      {required this.area,
      required this.band,
      required this.p,
      required this.onTap});

  final PpArea area;
  final String band;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = area.pagesFor(band).length;
    final tint = v2BlockTint(area.hue, p);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          // ⚠️ A LINE, NOT A SHADOW. `v2_palette.dart`: "elevation in this
          // system is a line, not a blur."
          border: Border.all(color: p.line),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // The drawn mark, on its own tinted ground, exactly as the doors do it.
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: HubIntentArt(mark: area.mark, tint: tint),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(area.title,
                      style: pvFraunces(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.22,
                          letterSpacing: -0.4,
                          color: p.ink1)),
                  const SizedBox(height: 5),
                  Text(area.blurb,
                      style: pvManrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: p.ink2)),
                  if (n > 1) ...[
                    const SizedBox(height: 8),
                    // A count, not a progress bar: it orients without implying
                    // there is a set of things to finish.
                    Text('$n PAGES',
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: p.ink3)),
                  ],
                ]),
          ),
        ]),
      ),
    );
  }
}

/// A 9:16 cover card — the shape the feedback asked for, in one place.
///
/// ⚠️ ONE COMPONENT FOR AREAS AND FOR PAGES, AND THAT IS THE POINT. The
/// note says the change applies "everywhere there is a list of articles shown
/// in a tab", for every section, and asks explicitly for consistency with what
/// came before. Two card widgets that merely look alike drift within a week;
/// the second one gets a radius nudged and nobody sees both screens at once.
///
/// ⚠️ 9:16 IS THE ASK, AND IT COSTS SOMETHING WORTH NAMING. A reels-shaped
/// card at two columns is about 300pt tall on a 390pt phone, so three rows
/// fill a screen where the old list showed six. That is the trade the feedback
/// is making on purpose: fewer things visible, each one recognisable. It is
/// the right call for a library you browse and would be the wrong one for a
/// list you scan, which is why the tools below deliberately did NOT become
/// cards.
///
/// ⚠️ THE TITLE SITS ON A SCRIM, NOT ON THE IMAGE. Once a real photograph
/// lands here the text has to stay legible over whatever the crop contains,
/// and a scrim that only appears "when needed" is a scrim nobody tested. It is
/// always there, and light enough that the tinted state does not look dimmed.
*/

/// The pinned area: one wide card above the grid.
///
/// ⚠️ IT MUST NOT BE A BIGGER VERSION OF THE COVER CARD. The point of pinning
/// is that this area is a different KIND of thing — the honest answer the
/// section is built around, rather than one shelf among several — and scaling
/// the same card up says "more important" without saying "different".
///
/// So: horizontal rather than 9:16, a tinted panel rather than a cover, and a
/// label that names what it is. The feedback for Potty puts it exactly: "how
/// long does this actually take is a constant, and like a tool should look
/// different from other articles".
class _PinnedAreaCard extends StatelessWidget {
  const _PinnedAreaCard(
      {required this.area, required this.p, required this.onTap});

  final PpArea area;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(area.hue, p);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              width: 84,
              color: tint,
              padding: const EdgeInsets.all(17),
              child: HubIntentArt(mark: area.mark, tint: tint),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 13, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('START HERE',
                        style: pvManrope(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: p.action)
                            .copyWith(letterSpacing: 1.1)),
                    const SizedBox(height: 6),
                    Text(area.title,
                        style: pvFraunces(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            height: 1.18,
                            letterSpacing: -0.35,
                            color: p.ink1)),
                    const SizedBox(height: 5),
                    Text(area.blurb,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: p.ink2)),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// The pinned page: one wide card above an area's grid.
///
/// The area version's argument holds one level down: pinning says "a
/// different kind of thing", not "more important", so it is horizontal, on a
/// tinted panel, with a label. The Sleep rebuild pins "Where we stand on sleep
/// training" at the top of its collection and calls it brand-defining; the
/// card is what makes that visible before the title is read.
class _PinnedPageCard extends StatelessWidget {
  const _PinnedPageCard(
      {required this.page,
      required this.area,
      required this.p,
      required this.onTap});

  final PpPage page;
  final PpArea area;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(area.hue, p);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              width: 84,
              color: tint,
              padding: const EdgeInsets.all(17),
              child: HubIntentArt(mark: area.mark, tint: tint),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 13, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        [
                          'START HERE',
                          if (page.format != null) page.format!.toUpperCase(),
                        ].join('  ·  '),
                        style: pvManrope(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: p.action)
                            .copyWith(letterSpacing: 1.1)),
                    const SizedBox(height: 6),
                    Text(page.title,
                        style: pvFraunces(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            height: 1.18,
                            letterSpacing: -0.35,
                            color: p.ink1)),
                    if (page.subtitle != null) ...[
                      const SizedBox(height: 5),
                      Text(page.subtitle!,
                          style: pvManrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: p.ink2)),
                    ],
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PpCoverCard extends StatelessWidget {
  const _PpCoverCard({
    required this.title,
    required this.hue,
    required this.mark,
    required this.p,
    required this.onTap,
    this.meta,
    this.cover,
  });

  final String title;
  final String? meta;
  final double hue;
  final IntentMark mark;
  final String? cover;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The cover. A file when there is one, the section's own drawn
              // mark when there is not.
              if (cover != null)
                Image.asset(cover!, fit: BoxFit.cover,
                    // A missing file degrades to the tinted state rather than
                    // to Flutter's grey error box, which on a content card
                    // reads as a broken app.
                    errorBuilder: (_, _, _) => const SizedBox.shrink())
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 26, 26, 96),
                  child: Opacity(
                    opacity: 0.55,
                    child: HubIntentArt(mark: mark, tint: tint),
                  ),
                ),

              // The scrim, then the words.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(13, 34, 13, 13),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        tint.withValues(alpha: 0),
                        tint.withValues(alpha: 0.92),
                        tint,
                      ],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: pvFraunces(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: -0.35,
                              color: p.ink1)),
                      if (meta != null) ...[
                        const SizedBox(height: 6),
                        Text(meta!,
                            style: pvManrope(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: p.ink3)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The grid the cards sit in.
///
/// ⚠️ `GridView` IS DELIBERATELY NOT USED. These grids live inside a
/// `ListView`, and a nested scrollable needs `shrinkWrap` plus
/// `NeverScrollableScrollPhysics` to behave — which lays out every child on
/// every frame of the parent's scroll. A `Wrap` of fixed-width children costs
/// nothing and cannot fight the outer scroll.
class _PpCardGrid extends StatelessWidget {
  const _PpCardGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) {
          const gap = 11.0;
          final w = (c.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final child in children) SizedBox(width: w, child: child),
            ],
          );
        },
      );
}

/* ⚠️ KEPT FOR REVERT — the section screen's own tool row. The tools now
   render on the hub (see `_HubTool` in problem_hub_screen.dart), so this is
   unused rather than wrong. It comes back with the commented block above.

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool, required this.p, this.onTap});
  final PpSectionTool tool;
  final V2Palette p;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 14, 15),
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tool.label,
                        style: pvFraunces(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                    const SizedBox(height: 4),
                    Text(tool.blurb,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: p.ink2)),
                  ]),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, size: 18, color: p.action),
          ]),
        ),
      );
}
*/
