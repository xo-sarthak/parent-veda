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
import '../brackets/hub/hub_intent_art.dart';
import '../v2/v2_palette.dart';
import 'pp_age_bands.dart';
import 'pp_child_profile.dart';
import 'pp_content.dart';

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

  bool inBand(String band) => bands.isEmpty || bands.contains(band);

  /// Pages in this area that fit the given band.
  List<PpPage> pagesFor(String band) =>
      [for (final p in pages) if (p.inBand(band)) p];
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
  });

  /// Matches the hub's `bracketId` so the router can find it.
  final String id;

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
  const PpSectionScreen({super.key, required this.section, this.onSurface});

  final PpSection section;
  final void Function(BuildContext context, String surfaceId)? onSurface;

  @override
  State<PpSectionScreen> createState() => _PpSectionScreenState();
}

class _PpSectionScreenState extends State<PpSectionScreen> {
  PpSection get s => widget.section;

  /// Which band is selected. Starts at the child's own — see `PpBandSet.ordered`.
  String? _band;

  @override
  void initState() {
    super.initState();
    _band = s.bandSet?.active.id;
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
        final band = _band ?? bands?.active.id ?? '';
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

                // ---- the band chooser ----------------------------------------
                if (bands != null) ...[
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
                for (final a in areas) ...[
                  _AreaTile(
                    area: a,
                    band: band,
                    p: p,
                    onTap: () => _openArea(context, a, band),
                  ),
                  const SizedBox(height: 10),
                ],

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
    List<String> shown(String b) =>
        [for (final a in section.areas) if (a.inBand(b)) a.id];
    final first = shown(set.bands.first.id).join('|');
    return set.bands.every((b) => shown(b.id).join('|') == first);
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
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'pp/${s.id}/page/${p.id}'),
        builder: (_) => PpContentPage(
          page: p,
          onSurface: widget.onSurface,
          onPage: (ctx, id) => _openPageById(ctx, id),
        ),
      ));

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
                  for (final page in pages) ...[
                    InkWell(
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: RouteSettings(
                            name: 'pp/${section.id}/page/${page.id}'),
                        builder: (_) => PpContentPage(
                          page: page,
                          onSurface: onSurface,
                          onPage: onPage,
                        ),
                      )),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 15, 14, 16),
                        decoration: BoxDecoration(
                          color: pal.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: pal.line),
                        ),
                        child: Row(children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(page.title,
                                      style: pvFraunces(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          height: 1.25,
                                          color: pal.ink1)),
                                  if (page.subtitle != null) ...[
                                    const SizedBox(height: 5),
                                    Text(page.subtitle!,
                                        style: pvManrope(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5,
                                            color: pal.ink2)),
                                  ],
                                ]),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded,
                              size: 17, color: pal.ink3),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
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
