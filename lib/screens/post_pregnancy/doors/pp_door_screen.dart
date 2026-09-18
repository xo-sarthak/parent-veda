// =============================================================================
//  PpDoorScreen — one parenting problem area, five tabs, one page
// -----------------------------------------------------------------------------
//  Renders a `PpDoor` over its `PpSection`. The shape is the pregnancy door's
//  (`lib/screens/doors/pv_door_screen.dart`) and the TTC fertile-window
//  door's before it: a V3 hero field, a sheet pulled over it, the coverflow
//  selector first thing under the hero, then the open tab's rails of badged
//  cards, then the closing row and the disclaimer. Read that file's header
//  for the three-level hierarchy and why the format is a chip and never a
//  heading; every one of those rules holds here.
//
//  ⚠️ WHAT IS PARENTING'S OWN, AND WHY:
//
//  * **The cards come from the section, for her band.** A rail is an area's
//    `pagesFor(band)`. There is no tile list in the door file — the section
//    already holds the pages, banded and tested — so the door cannot list a
//    page the section does not have, and the age rule (`PpSection.autoScope`)
//    is applied here by the same call the library screen makes.
//  * **The hero says which age it is showing.** The tracker's "Typical for N
//    weeks" line, under the blurb: a statement, not a control.
//  * **The chip is `PpPage.format`**, which the rebuild brief wrote in its own
//    vocabulary (CHART, ANIMATION, INTERACTIVE, RED FLAG…). Title-cased on the
//    card, so "Red flag" sits beside "Article" the way the pregnancy chips do.
//  * **A page can be a tool** (`toolSurfaceId`) — its card opens the surface,
//    exactly as the pregnancy door's tool tiles do.
//
//  ⚠️ THE SELECTOR DOES NOT REMEMBER, for the reason the pregnancy door gives:
//  the first tab is where somebody arriving should land.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/doors/pp_door_data.dart';
import '../../../data/hubs/hub_registry.dart';
import '../../../services/bracket_resolver.dart';
import '../../../theme/pv_fonts.dart';
import '../../v2/v2_palette.dart';
import '../../v2/v3_bracket_art.dart';
import '../../v2/v3_hero_field.dart';
import '../pp_child_profile.dart';
import '../pp_content.dart';
import '../pp_section_registry.dart';
import '../pp_section_screen.dart';
import 'pp_door_carousel.dart';
import 'pp_door_chrome.dart';

// -----------------------------------------------------------------------------
//  Rail geometry — the pregnancy door's numbers, so the sum is the same sum:
//  18 gutter + 142 + 10 + 142 + 10 = 322 on a 360dp screen, 38pt of the third.
// -----------------------------------------------------------------------------
const double kPpRailCardWidth = 142;
const double kPpRailCardHeight = 176;
const double kPpRailGap = 10;

/// How far the sheet is pulled up over a photographic hero. One number, used
/// twice — see the pregnancy door for why the two uses must not drift.
const double kPpDoorHeroOverlap = 38;

/// The format's mark, keyed on the brief's badge word. Small on the chip,
/// large and quiet behind the card. Unknown words get the article mark rather
/// than nothing, so a new format is visibly a page and not visibly a bug.
IconData ppDoorFormatIcon(String? format) => switch (format?.toUpperCase()) {
      'TOOL' => Icons.tune_rounded,
      'CHART' => Icons.bar_chart_rounded,
      'TABLE' => Icons.table_rows_outlined,
      'CARDS' => Icons.grid_view_rounded,
      'ANIMATION' => Icons.animation_rounded,
      'ILLUSTRATION' => Icons.image_outlined,
      'CAROUSEL' => Icons.view_carousel_outlined,
      'INTERACTIVE' => Icons.touch_app_outlined,
      'VIDEO' => Icons.play_circle_outline_rounded,
      'STEP-LIST' || 'STEPS' => Icons.format_list_numbered_rounded,
      'FLAGGED CALLOUT' => Icons.flag_outlined,
      'CONSULT' => Icons.chat_bubble_outline_rounded,
      'AUDIO LIBRARY' || 'AUDIO' => Icons.music_note_outlined,
      'RED FLAG' => Icons.flag_outlined,
      'TALK' => Icons.chat_bubble_outline_rounded,
      _ => Icons.article_outlined,
    };

/// "RED FLAG" -> "Red flag". The chip's case, from the brief's shouting.
String ppDoorChip(String? format) {
  final f = (format ?? 'Article').trim();
  if (f.isEmpty) return 'Article';
  // The long badges the briefs use, at chip length. "Flagged quick-refer…"
  // was what the chip showed on a phone (First 40 Days, 2026-09-13).
  switch (f.toUpperCase()) {
    case 'FLAGGED QUICK-REFERENCE':
      return 'Red flag';
    case 'FLAGGED ARTICLE':
    case 'FLAGGED CALLOUT':
      return 'Flagged';
    case 'COMPARISON TABLE':
      return 'Comparison';
    case 'DAY-SPINE CARD':
      return 'Day by day';
    case 'AUDIO LIBRARY':
      return 'Audio';
  }
  return f[0].toUpperCase() + f.substring(1).toLowerCase();
}

class PpDoorScreen extends StatefulWidget {
  const PpDoorScreen({
    super.key,
    required this.door,
    required this.onSurface,
    this.initialTabId,
  });

  final PpDoor door;

  /// How a surface id opens. Injected, like the section screen's, so this file
  /// never imports the router.
  final void Function(BuildContext context, String surfaceId) onSurface;

  /// Open on a given tab — how `pp_section/<id>/<area>` deep links land.
  final String? initialTabId;

  @override
  State<PpDoorScreen> createState() => _PpDoorScreenState();
}

class _PpDoorScreenState extends State<PpDoorScreen> {
  late int _tab = () {
    final id = widget.initialTabId;
    if (id == null) return 0;
    final i = _tabs.indexWhere((t) => t.id == id);
    return i < 0 ? 0 : i;
  }();

  PpDoor get door => widget.door;

  /// The tabs for his age. See `PpDoorTab.toMonths`: a tab scoped to the
  /// first two years is not on the selector for a three-year-old.
  ///
  /// ⚠️ A TAB HE HAS GROWN PAST DROPS; A TAB HE HAS NOT REACHED IS LOCKED.
  /// Behaviour's four toddler tabs hold no area for a three-month-old, and
  /// its Crying tab none for a four-year-old. The brief's age rule is "other
  /// bands hidden, not one tap away" — and the user's call (2026-09-13) is
  /// the game's answer to it: what is coming is shown misted with a lock and
  /// the age it opens, after the open tabs, so the section never looks bare
  /// and she knows to come back; what is behind him is simply gone. A tab
  /// of tools alone (no areas at all, like Development's leaps) is always
  /// open, since a tool has no band.
  List<PpDoorTab> get _tabs => [
        for (final t in door.tabs)
          if (_lockFor(t) != _Lock.past) t,
      ]..sort((a, b) {
          // Open first, then locked by the age they open. A stable sort:
          // ties keep the door's own order.
          final la = _unlockMonths(a), lb = _unlockMonths(b);
          if (la == null && lb == null) return 0;
          if (la == null) return -1;
          if (lb == null) return 1;
          return la.compareTo(lb);
        });

  /// The month a locked tab opens, or null when it is open now.
  int? _unlockMonths(PpDoorTab t) {
    if (t.areaIds.isEmpty) return null;
    final age = ChildProfileStore.instance.ageInMonths;
    final starts = <int>[];
    for (final id in t.areaIds) {
      for (final a in section.areas.where((a) => a.id == id)) {
        if (a.inBand(_band)) return null;
        starts.add(_areaFrom(a));
      }
    }
    if (starts.isEmpty) return null;
    final from = starts.reduce((x, y) => x < y ? x : y);
    return from > age ? from : null;
  }

  _Lock _lockFor(PpDoorTab t) {
    final age = ChildProfileStore.instance.ageInMonths;
    if (t.toMonths != null && age >= t.toMonths!) return _Lock.past;
    if (t.areaIds.isEmpty) return _Lock.open;
    if (_unlockMonths(t) != null) return _Lock.locked;
    // Not open, not ahead: every area's band has closed behind him.
    final open = t.areaIds.any(
        (id) => section.areas.any((a) => a.id == id && a.inBand(_band)));
    return open ? _Lock.open : _Lock.past;
  }

  /// Where an area's earliest band starts, in months. An area with no bands
  /// is for every age.
  int _areaFrom(PpArea a) {
    final set = section.bandSet;
    if (a.bands.isEmpty || set == null) return 0;
    var from = 1 << 20;
    for (final b in set.bands) {
      if (a.bands.contains(b.id) && b.fromMonths < from) from = b.fromMonths;
    }
    return from == 1 << 20 ? 0 : from;
  }

  /// "From 1 year", "From 6 months": the card's second line while locked.
  String _lockLabel(int months) => months % 12 == 0
      ? 'From ${months ~/ 12} ${months == 12 ? 'year' : 'years'}'
      : 'From $months months';

  /// The card's second line while locked: "Locked · From 1 year".
  String _lockLine(int months) => 'Locked  ·  ${_lockLabel(months)}';
  PpSection get section => ppSectionFor(door.sectionId)!;

  String get _band => section.bandSet?.active.id ?? '';

  /// The pages a tab shows, for her band, minus the pinned red flag.
  List<(PpArea, List<PpPage>)> _railsFor(PpDoorTab tab) => [
        for (final id in tab.areaIds)
          for (final area in section.areas.where((a) => a.id == id))
            if (area.inBand(_band))
              (
                area,
                [
                  for (final p in area.pagesFor(_band))
                    if (p.id != tab.redFlagPageId) p,
                ],
              ),
      ];

  /// The second line on a tab's card. Counted, never typed — or, while the
  /// tab is locked, the age it opens.
  String _countFor(PpDoorTab tab) {
    if (_unlockMonths(tab) case final m?) return _lockLine(m);
    final n = tab.tools.length +
        _railsFor(tab).fold(0, (t, r) => t + r.$2.length) +
        (tab.redFlagPageId != null ? 1 : 0);
    if (n == 0) return '';
    return n == 1 ? '1 thing' : '$n things';
  }

  _CardSpec _toolSpec(BuildContext context, PpDoorTool tool) => _CardSpec(
        title: tool.label,
        chip: tool.chip,
        icon: tool.icon,
        onTap: () => widget.onSurface(context, tool.surfaceId),
      );

  // ---- navigation -----------------------------------------------------------

  /// One opener for every path — see `ppOpenPage`.
  void _openPage(BuildContext context, PpPage page) =>
      ppOpenPage(context, section, page, onSurface: widget.onSurface);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(
            [ChildProfileStore.instance, V2PaletteStore.instance]),
        builder: (context, _) => _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final bracket = bracketById(door.sectionId);
    final hub = hubFor(door.sectionId);
    final tabs = _tabs;
    final hue = bracket?.hue ?? tabs.first.hue;
    final tint = v2BlockTint(hue, p);
    final tab = tabs[_tab.clamp(0, tabs.length - 1)];
    // ⚠️ A TAB OF TOOLS ALONE STILL GETS A RAIL. The tools ride the first
    // rail, so a tab with no area under it (Development's "The leaps" is
    // one tool, the calendar) had nowhere to put them and drew nothing. It
    // gets one rail, headed with the tab's own name.
    final rails = _railsFor(tab).isNotEmpty || tab.tools.isEmpty
        ? _railsFor(tab)
        : [(PpArea(id: tab.id, title: tab.label, blurb: ''), const <PpPage>[])];
    final redFlag = tab.redFlagPageId == null
        ? null
        : section.pageById(tab.redFlagPageId!);

    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(children: [
        Positioned.fill(
          child: V3HeroField(
              accent: tint,
              ground: p.ground,
              variant: 1,
              chroma: v3FieldChroma(hue)),
        ),
        ListView(
          padding: EdgeInsets.zero,
          children: [
            _Hero(
              p: p,
              tint: tint,
              photo: door.heroImageUrl,
              eyebrow: bracket?.label.now ?? section.title,
              title: hub?.hero.now ?? section.title,
              blurb: hub?.heroSupport.now ?? section.intro,
              mark: bracketMarkFor(door.sectionId),
              ageLine: section.bandSet == null
                  ? null
                  : door.aboutHer
                      ? 'FOR YOU  ·  ${section.bandSet!.active.label.toUpperCase()}'
                      : 'FOR ${ChildProfileStore.instance.nameMid.toUpperCase()}'
                          '  ·  ${section.bandSet!.active.label.toUpperCase()}',
            ),
            PpDoorSheet(p: p, children: [
              const SizedBox(height: 14), // was 22 (deck tightened 2026-09-18)

              // ---- the selector, first thing under the hero ----------------
              PpDoorCarousel(
                groups: tabs,
                counts: [for (final t in tabs) _countFor(t)],
                locked: [for (final t in tabs) _unlockMonths(t) != null],
                selected: _tab,
                p: p,
                onPick: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 18), // was 26

              // ---- a locked tab: the panel, not the rails -----------------
              if (_unlockMonths(tab) case final m?) ...[
                ppDoorPad(_LockedPanel(
                  months: m,
                  label: _lockLabel(m),
                  aboutHer: door.aboutHer,
                  p: p,
                )),
                const SizedBox(height: 26),
              ] else ...[

              // ---- a pinned jump to another tab ----------------------------
              if (tab.jumpToTabId case final target?) ...[
                ppDoorPad(_JumpCard(
                  title: tab.jumpTitle ?? 'Is this an emergency?',
                  p: p,
                  onTap: () => setState(() => _tab = tabs
                      .indexWhere((t) => t.id == target)
                      .clamp(0, tabs.length - 1)),
                )),
                const SizedBox(height: 22),
              ],

              // ---- a pinned red flag, above everything ---------------------
              if (redFlag != null) ...[
                ppDoorPad(_PinnedRedFlag(
                  page: redFlag,
                  p: p,
                  onTap: () => _openPage(context, redFlag),
                )),
                const SizedBox(height: 22),
              ],

              // ---- the tab's note ------------------------------------------
              if (tab.note case final note?) ...[
                ppDoorPad(_TabNote(note: note, p: p)),
                const SizedBox(height: 20),
              ],

              // ---- this tab's rails, one per area --------------------------
              //
              // ⚠️ A STANDALONE TOOL IS THE FIRST CARD ON THE FIRST RAIL, NOT
              // A ROW ABOVE IT. The fertile-window door puts "Your best days
              // this month" as the leading card of its first section, in the
              // same card as everything beside it, with a Tool chip. A white
              // row over a tinted rail was the same thing in a different
              // vocabulary, and it stood out for that reason alone. Seen on a
              // phone, 2026-09-11.
              for (final (ri, (area, pages)) in rails.indexed) ...[
                ppDoorPad(Text(area.title,
                    style: pvFraunces(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: -0.45,
                        color: p.ink1))),
                const SizedBox(height: 13),

                // ⚠️ ONE VOCABULARY, WHATEVER THE COUNT. The pregnancy door
                // turns a rail of one into a wide row; this door does not,
                // on the user's call after seeing both on a phone,
                // 2026-09-11: a collection that happens to hold one page for
                // her age is still the same collection, and a card that
                // changes shape with the count reads as a different kind of
                // thing. So: always a rail, and the pinned page is simply the
                // first card on it, not a row above it. The tools lead the
                // first rail for the same reason.
                for (final cards in [
                  [
                    // A tool leads the first rail unless it names the page
                    // it follows (`PpDoorTool.afterPageId`); a tool whose
                    // page is not on this rail leads anyway rather than
                    // vanishing.
                    if (ri == 0)
                      for (final tool in tab.tools)
                        if (tool.afterPageId == null ||
                            !pages.any((x) => x.id == tool.afterPageId))
                          _toolSpec(context, tool),
                    for (final page in [
                      ...pages.where((x) => x.pinned),
                      ...pages.where((x) => !x.pinned),
                    ]) ...[
                      _CardSpec(
                        title: page.title,
                        meta: page.subtitle,
                        chip: page.comingSoon
                            ? 'Coming soon'
                            : ppDoorChip(page.format),
                        icon: ppDoorFormatIcon(page.format),
                        soon: page.comingSoon,
                        onTap: () => _openPage(context, page),
                      ),
                      if (ri == 0)
                        for (final tool in tab.tools)
                          if (tool.afterPageId == page.id)
                            _toolSpec(context, tool),
                    ],
                  ]
                ]) ...[
                  if (cards.isNotEmpty)
                    SizedBox(
                      height: kPpRailCardHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: kPpDoorGutter),
                        itemCount: cards.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: kPpRailGap),
                        itemBuilder: (context, i) => _RailCard(
                          spec: cards[i],
                          p: p,
                          hue: area.hue,
                          index: i,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 26),
              ],

              ], // end of the open tab's body

              // ---- the tab's footer, in a human voice ----------------------
              if (tab.footer case final line?) ...[
                ppDoorPad(Text(line,
                    style: pvFraunces(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: p.ink2))),
                const SizedBox(height: 22),
              ],

              // ---- the closing, under every tab ----------------------------
              //
              // ⚠️ A LINE WHEN THE DOOR HAS ONE, THE CARD OTHERWISE. See
              // `PpDoor.closingLine`.
              if (door.closingLine case final line?) ...[
                ppDoorPad(InkWell(
                  onTap: door.closing == null
                      ? null
                      : () => widget.onSurface(context, door.closing!.surfaceId),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: line),
                        if (door.closing != null)
                          TextSpan(
                              text: '  ${door.closing!.label} \u2192',
                              style: pvManrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 1.5,
                                  color: p.action)),
                      ]),
                      style: pvFraunces(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: p.ink2),
                    ),
                  ),
                )),
                const SizedBox(height: 22),
              ] else if (door.closing case final c?) ...[
                ppDoorPad(PpDoorRow(
                  p: p,
                  hue: hue,
                  icon: Icons.chat_bubble_outline_rounded,
                  chip: 'Consult',
                  title: c.label,
                  blurb: c.blurb,
                  onTap: () => widget.onSurface(context, c.surfaceId),
                )),
                const SizedBox(height: 22),
              ],

              ppDoorPad(PpDoorDisclaimer(p: p, text: door.disclaimer)),
            ]),
          ],
        ),
      ]),
    );
  }
}

// -----------------------------------------------------------------------------
//  The hero — the pregnancy door's, without the photograph layer, plus the
//  age line.
// -----------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({
    required this.p,
    required this.tint,
    required this.eyebrow,
    required this.title,
    required this.blurb,
    required this.mark,
    this.photo,
    this.ageLine,
  });

  final V2Palette p;
  final Color tint;
  final String? photo;
  final String eyebrow;
  final String title;
  final String blurb;
  final BracketMark? mark;
  final String? ageLine;

  @override
  Widget build(BuildContext context) {
    final onPhoto = photo != null;
    final ink1 = onPhoto ? Colors.white : p.ink1;
    final ink2 = onPhoto ? Colors.white.withValues(alpha: 0.86) : p.ink2;
    // ⚠️ `Clip.none`, WHICH IS WHAT LETS THE PICTURE RUN PAST THE HERO. The
    // photograph is laid out `kPpDoorHeroOverlap` below the hero's own box and
    // paints there; the sheet, laid out right after, covers the overflow with
    // its rounded edge over picture rather than over field. The pregnancy door
    // explains at length why a transform could never do this.
    return Stack(clipBehavior: Clip.none, children: [
        if (onPhoto)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: -kPpDoorHeroOverlap,
            child: Image.network(
              photo!,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              // A dead connection or a bad URL leaves the field and the mark,
              // never a grey box.
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
            ),
          ),
        // A dark scrim only, never fading to the page colour — fading a photo
        // into the ground reads as fog under the type on a phone.
        if (onPhoto)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: -kPpDoorHeroOverlap,
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
        if (!onPhoto)
          Positioned(
            right: -26,
            top: 52,
            child: Opacity(
              opacity: 0.5,
              child: SizedBox(
                width: 146,
                height: 146,
                child: mark == null
                    ? const SizedBox.shrink()
                    : V3BracketArt(mark: mark!, tint: tint),
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
                // The photograph is given room here and nowhere else: the
                // hero's height is this column's. A fraction of the screen,
                // because a literal generous on a tall phone eats a short one.
                SizedBox(
                    height: onPhoto
                        ? MediaQuery.sizeOf(context).height * 0.10
                        : 20),
                Text(eyebrow.toUpperCase(),
                    style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: onPhoto
                            ? Colors.white.withValues(alpha: 0.82)
                            : p.ink2)),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(title,
                      style: pvFraunces(
                          fontSize: onPhoto ? 30 : 27,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          letterSpacing: -0.6,
                          color: ink1)),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 330),
                  child: Text(blurb,
                      style: pvManrope(
                          fontSize: 13.5, height: 1.55, color: ink2)),
                ),
                // ⚠️ THE AGE LINE. The one thing a parenting hero says that a
                // pregnancy hero does not: which age this door is showing.
                // A statement, not a chooser — the age rule.
                if (ageLine != null) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Icon(Icons.child_care_outlined,
                        size: 14, color: onPhoto ? Colors.white : p.action),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(ageLine!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: onPhoto ? Colors.white : p.action)),
                    ),
                  ]),
                ],
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ]);
  }
}

// -----------------------------------------------------------------------------
//  Tiles — the pregnancy door's rail card, keyed on a page
// -----------------------------------------------------------------------------

/// What a rail card needs, whichever thing it is for. A page and a tool are
/// the same card — that is the whole point of the spec: the rail has one
/// vocabulary, and a tool does not get a second one.
enum _Lock { open, locked, past }

/// What a locked tab shows instead of its rails: the lock, the age it opens,
/// and the promise that nothing on it is due before then.
class _LockedPanel extends StatelessWidget {
  const _LockedPanel({required this.months, required this.label, required this.p, this.aboutHer = false});
  final int months;
  final String label;
  final V2Palette p;

  /// The mother's door: "when you are 2 months in", not "when he is".
  final bool aboutHer;

  @override
  Widget build(BuildContext context) {
    final name = ChildProfileStore.instance.nameMid;
    final when = months % 12 == 0
        ? '${months ~/ 12}'
        : '$months months';
    final turns = months % 12 == 0 ? 'turns $when' : 'is $when old';
    final herWhen = months % 12 == 0
        ? '${months ~/ 12} ${months == 12 ? 'year' : 'years'}'
        : '$months months';
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.surfaceAlt, shape: BoxShape.circle),
          child: Icon(Icons.lock_outline_rounded, size: 20, color: p.ink2),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(),
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: p.ink3)),
            const SizedBox(height: 6),
            Text(aboutHer
                    ? 'This opens when you are $herWhen in.'
                    : 'This opens when $name $turns.',
                style: pvFraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.35,
                    color: p.ink1)),
            const SizedBox(height: 6),
            Text('Nothing here is due before then. It will be on this tab '
                'the day it is, with nothing to catch up on.',
                style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: p.ink2)),
          ]),
        ),
      ]),
    );
  }
}

class _CardSpec {
  const _CardSpec({
    required this.title,
    required this.chip,
    required this.icon,
    required this.onTap,
    this.meta,
    this.soon = false,
  });
  final String title;
  final String? meta;
  final String chip;
  final IconData icon;
  final VoidCallback onTap;

  /// A coming-soon card: full size, dimmed, and it does not respond to a tap
  /// — a tap that does nothing teaches that taps do nothing, so there is no
  /// ink and no ripple either.
  final bool soon;
}

class _RailCard extends StatelessWidget {
  const _RailCard({
    required this.spec,
    required this.p,
    required this.hue,
    required this.index,
  });

  final _CardSpec spec;
  final V2Palette p;
  final double hue;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Each card steps the hue 22°, so a rail reads as separate blocks rather
    // than one slab of the area's colour.
    final tint = v2BlockTint((hue + index * 22) % 360, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();
    final icon = spec.icon;

    return InkWell(
      onTap: spec.soon ? null : spec.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Opacity(
        opacity: spec.soon ? 0.62 : 1,
        child: Container(
        width: kPpRailCardWidth,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          // The mark, quiet and small, where an illustration would sit.
          Positioned(
            right: -22,
            bottom: 22,
            child: Icon(icon,
                size: 96, color: Colors.white.withValues(alpha: 0.34)),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, size: 10, color: deep),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(spec.chip,
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
                // The one fact above the title, where there is one: the
                // chart's age band, a page's subtitle.
                if (spec.meta case final meta?) ...[
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
                Text(spec.title,
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

/// The pinned jump card: the red-flag treatment, pointing at another tab.
class _JumpCard extends StatelessWidget {
  const _JumpCard({required this.title, required this.p, required this.onTap});
  final String title;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 13, 14),
          decoration: BoxDecoration(
            color: kPpUrgentTint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kPpUrgentInk.withValues(alpha: 0.35)),
          ),
          child: Row(children: [
            const Icon(Icons.flag_outlined, size: 18, color: kPpUrgentInk),
            const SizedBox(width: 11),
            Expanded(
              child: Text(title,
                  style: pvFraunces(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      height: 1.22,
                      letterSpacing: -0.3,
                      color: p.ink1)),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 20, color: kPpUrgentInk),
          ]),
        ),
      );
}

/// The pinned red flag: the doctor page, coral, above the tab's content.
class _PinnedRedFlag extends StatelessWidget {
  const _PinnedRedFlag(
      {required this.page, required this.p, required this.onTap});

  final PpPage page;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The first doctor callout's text is the flag's line. It is the page's
    // own words, so the flag and the page cannot disagree.
    final line = page.blocks
        .whereType<PpCallout>()
        .where((c) => c.kind == PpCalloutKind.doctor)
        .map((c) => c.text)
        .firstOrNull;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 14, 13, 15),
        decoration: BoxDecoration(
          color: kPpUrgentTint,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPpUrgentInk.withValues(alpha: 0.35)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.flag_outlined, size: 18, color: kPpUrgentInk),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // You, Maa pins its frightening-thoughts route here; the
                  // brief's words for it are "read this one first", not a
                  // red flag, and a mother in that state should meet those.
                  Text(page.format?.toUpperCase() == 'ROUTE'
                          ? 'READ THIS ONE FIRST'
                          : 'RED FLAG',
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: kPpUrgentInk)),
                  const SizedBox(height: 5),
                  Text(page.title,
                      style: pvFraunces(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          height: 1.22,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                  if (line != null) ...[
                    const SizedBox(height: 5),
                    Text(line,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 12.5, height: 1.5, color: p.ink2)),
                  ],
                ]),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
        ]),
      ),
    );
  }
}

/// A tab's standing note. Quiet type, quiet box.
class _TabNote extends StatelessWidget {
  const _TabNote({required this.note, required this.p});
  final String note;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(note,
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
      );
}
