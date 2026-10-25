// =============================================================================
//  SkDoorScreen — one skill door, five tabs, one page, spoken to the child
// -----------------------------------------------------------------------------
//  Renders an `SkDoor` over its `SkDoorContent`. The shape is the parenting
//  door's (`lib/screens/post_pregnancy/doors/pp_door_screen.dart`) and the
//  pregnancy door's before it: a V3 hero field, a photograph pulled under a
//  sheet, the coverflow selector first thing under the hero, then the open
//  tab's rails of badged 142×176 cards, then the closing card and the
//  disclaimer. Read those files' headers for the three-level hierarchy, why
//  the format is a chip and never a heading, and why the selector does not
//  remember. Every one of those rules holds here; the geometry is copied
//  number for number.
//
//  ⚠️ WHAT IS SKILLING'S OWN, AND WHY:
//
//  * **The rails come from the tab's KIND, for her band.** A parenting tab
//    names areas; a skill tab names one of the brief's five child surfaces
//    (`SkTabKind`), and this screen draws it from the content: the today
//    card, one rail per thinking skill, one rail per lesson set, the
//    cross-band set, the keepsake tool. The door file cannot list a card the
//    content does not have.
//  * **The age rule, in years, with a floor.** `SkChildStore.band` is null
//    under six; then every child tab is LOCKED ("Locked · From 6 years")
//    and the closing card — the grown-up side — stays open. The user's
//    call, 2026-09-14. Above fourteen she reads the top band. No age chip,
//    tab or picker anywhere; the hero says which band it is showing.
//  * **The hero speaks to her.** "FOR AARAV · UNPLUGGED · 6 TO 8" — the
//    door's own name for the rung, then the years. The band label comes
//    from the content (`bandName`), so Coding says Unplugged where
//    Communication will say Say it out loud.
//  * **A card can carry her word.** The keepsake's furthest word for an
//    activity — TRIED, PRACTISED AGAIN, MADE — sits where a parenting card
//    puts its subtitle. A word, never a count; nothing on the rail adds up.
//  * **The closing is the way to the grown-up side, and it is gated** —
//    by the grown-up screen itself, on open, so a deep link and the card
//    meet the same one question.
//
//  ⚠️ NOTHING ON THIS SCREEN IS A SCORE. No count of things done, no
//  fraction of a set, no "3 of 12". The tab's second line is a count of
//  THINGS ON THE TAB ("12 things"), which is a fact about the content, not
//  about the child — the parenting door's rule, and the one number allowed.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/doors/sk_door_data.dart';
import '../../../services/bracket_resolver.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_door_intro_chip.dart';
import '../../doors/pv_live_search.dart';
import '../../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../../v2/v2_palette.dart';
import '../../v2/v3_hero_field.dart';
import '../../v2/v3_skill_art.dart';
import '../sk_activity_screen.dart';
import '../sk_bands.dart';
import '../sk_child_store.dart';
import '../sk_content.dart';
import '../sk_content_registry.dart';
import '../sk_door_content.dart';
import '../sk_practice_store.dart';
import '../sk_safety.dart';
// import 'sk_door_carousel.dart'; // the coverflow deck, kept for revert (house look, 2026-10-25)
import 'sk_door_chrome.dart';

// -----------------------------------------------------------------------------
//  Rail geometry — the parenting door's numbers, so the sum is the same sum.
// -----------------------------------------------------------------------------
const double kSkRailCardWidth = 142;
const double kSkRailCardHeight = 176;
const double kSkRailGap = 10;

/// How far the sheet is pulled up over a photographic hero. One number,
/// used twice — see the pregnancy door for why the two uses must not drift.
const double kSkDoorHeroOverlap = 38;

/// The format's mark, keyed on the badge word.
IconData skDoorFormatIcon(String? format) => switch (format?.toUpperCase()) {
      'TOOL' => Icons.tune_rounded,
      'KEEPSAKE' => Icons.auto_awesome_outlined,
      'ACTIVITY' => Icons.extension_outlined,
      'LESSON' => Icons.menu_book_outlined,
      'VIDEO' => Icons.play_circle_outline_rounded,
      'COURSE' => Icons.school_outlined,
      'PRODUCT' => Icons.shopping_bag_outlined,
      'PARENT NOTE' => Icons.family_restroom_outlined,
      _ => Icons.article_outlined,
    };

/// "LESSON" -> "Lesson". The chip's case.
String skDoorChip(String? format) {
  final f = (format ?? 'Article').trim();
  if (f.isEmpty) return 'Article';
  return f[0].toUpperCase() + f.substring(1).toLowerCase();
}

/// ⚠️ THE ONE WAY A LESSON PAGE OPENS, FROM ANY SCREEN. A tool page opens
/// its surface; everything else opens as content. Mirrors `ppOpenPage`.
void skOpenPage(
  BuildContext context,
  SkDoorContent content,
  SkPage page, {
  void Function(BuildContext, String)? onSurface,
}) {
  if (page.toolSurfaceId != null) {
    onSurface?.call(context, page.toolSurfaceId!);
    return;
  }
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: 'sk/${content.doorId}/page/${page.id}'),
    builder: (_) => skPageScreen(content, page, onSurface: onSurface),
  ));
}

/// The screen `skOpenPage` would push, without pushing it — for the router.
Widget skPageScreen(
  SkDoorContent content,
  SkPage page, {
  void Function(BuildContext, String)? onSurface,
}) =>
    SkContentPage(
      page: page,
      doorId: content.doorId,
      onSurface: onSurface,
      onPage: (ctx, id) {
        final target = content.pageById(id);
        if (target != null) skOpenPage(ctx, content, target, onSurface: onSurface);
      },
    );

/// The one way an activity opens.
void skOpenActivity(
  BuildContext context,
  SkDoorContent content,
  SkActivity activity, {
  void Function(BuildContext, String)? onSurface,
}) {
  if (activity.comingSoon) return;
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: 'sk/${content.doorId}/activity/${activity.id}'),
    builder: (_) => SkActivityScreen(content: content, activity: activity),
  ));
}

class SkDoorScreen extends StatefulWidget {
  const SkDoorScreen({
    super.key,
    required this.door,
    required this.onSurface,
    this.initialTabId,
  });

  final SkDoor door;

  /// How a surface id opens. Injected, so this file never imports the
  /// router.
  final void Function(BuildContext context, String surfaceId) onSurface;

  /// Open on a given tab — how `sk_lessons/<door>` deep links land.
  final String? initialTabId;

  @override
  State<SkDoorScreen> createState() => _SkDoorScreenState();
}

class _SkDoorScreenState extends State<SkDoorScreen> {
  late int _tab = () {
    final id = widget.initialTabId;
    if (id == null) return 0;
    final i = _tabs.indexWhere((t) => t.id == id);
    return i < 0 ? 0 : i;
  }();

  SkDoor get door => widget.door;
  SkDoorContent get content => skDoorContentFor(door.doorId)!;

  /// The header's search (the house door's `PvLiveSearch`): idle, it is a
  /// field under the blurb; typing, the sheet shows what on this door, for
  /// her band, matches.
  final PvLiveSearch _search = PvLiveSearch();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  SkBand? get _band => SkChildStore.instance.band;

  /// The tabs for her age: a band-pinned tab she has grown past is gone.
  ///
  /// ⚠️ A TAB SHE HAS GROWN PAST DROPS; A TAB SHE HAS NOT REACHED IS LOCKED.
  /// The parenting door's rule, applied to `SkDoorTab.bandId`: Communication's
  /// "Say it out loud (6 to 8)" is not on a twelve-year-old's selector, and
  /// "Say what you think (11 to 14)" is on a six-year-old's, locked, "From
  /// 11 years". A tab with no band (Coding's shape) is for every age.
  List<SkDoorTab> get _tabs => [
        for (final t in door.tabs)
          if (!_past(t)) t,
      ];

  bool _past(SkDoorTab t) {
    final b = t.bandId;
    final hers = _band;
    if (b == null || hers == null) return false;
    return skBandRung(b) < skBandRung(hers.id);
  }

  /// The band a tab draws: its own, or hers.
  String _bandFor(SkDoorTab t, SkBand hers) => t.bandId ?? hers.id;

  /// The age a tab opens, or null when it is open now.
  ///
  /// Under the floor every child tab is locked at six. A band-pinned tab
  /// ahead of her band locks at that band's start. A `pages` tab whose
  /// pages are all for a later band locks at that band's start.
  int? _unlockYears(SkDoorTab t) {
    final band = _band;
    if (band == null) return kSkAgeFloor;
    if (t.bandId case final b?) {
      if (skBandRung(b) > skBandRung(band.id)) return skBandById(b)?.fromYears;
      return null;
    }
    if (t.kind != SkTabKind.pages) return null;
    var earliest = 1 << 20;
    for (final id in t.pageIds) {
      final p = content.pageById(id);
      if (p == null) continue;
      if (p.inBand(band.id)) return null;
      for (final b in p.bands) {
        final from = skBandById(b)?.fromYears ?? 0;
        if (from < earliest) earliest = from;
      }
    }
    if (earliest == 1 << 20) return null;
    return earliest > (SkChildStore.instance.ageYears ?? 0) ? earliest : null;
  }

  String _lockLine(int years) => 'Locked  ·  From $years years';

  /// The rails a tab shows: a heading, an optional quiet line, and cards.
  List<_Rail> _railsFor(SkDoorTab tab) {
    final hers = _band;
    if (hers == null) return const [];
    final bandId = _bandFor(tab, hers);
    switch (tab.kind) {
      case SkTabKind.today:
        final a = content.todayFor(bandId);
        return [
          _Rail(
            title: 'One thing to try today',
            line: a == null ? null : content.skillById(a.skillPurpose)?.label,
            cards: [if (a != null) _activityCard(a, meta: 'TODAY')],
          ),
        ];
      case SkTabKind.activities:
        // ⚠️ THE ACCESS RAIL LEADS, WHEN THE BAND HAS ONE. The 8 to 11
        // task's "build once, parent-gated": a Grown-ups card first on the
        // first rail, opening the free-tools screen behind the gate. The
        // Unplugged band has no tools and gets no card.
        final access = content.accessFor(bandId);
        var first = true;
        return [
          for (final s in content.skills)
            if (content.activitiesForSkill(bandId, s.id).isNotEmpty)
              _Rail(
                title: s.label,
                line: s.kidLine,
                cards: [
                  if (access.isNotEmpty && first && !(first = false))
                    _CardSpec(
                      title: 'Free tools to set up',
                      meta: 'FOR THE GROWN-UP',
                      chip: 'Grown-ups',
                      icon: Icons.lock_outline_rounded,
                      onTap: () =>
                          widget.onSurface(context, 'sk_access/${content.doorId}'),
                    ),
                  for (final a in content.activitiesForSkill(bandId, s.id))
                    _activityCard(a),
                ],
              ),
        ];
      case SkTabKind.lessons:
        return [
          for (final set in content.lessonSetsFor(bandId))
            _Rail(
              title: set.title,
              line: set.blurb,
              cards: [
                for (final l in content.lessonsIn(set.id, bandId)) _pageCard(l),
              ],
            ),
        ];
      case SkTabKind.crossBand:
        final id = content.crossBandSetId;
        final set = id == null ? null : content.setById(id);
        if (set == null) return const [];
        return [
          _Rail(
            title: set.title,
            line: set.blurb,
            cards: [
              for (final l in content.lessonsIn(set.id, bandId)) _pageCard(l),
            ],
          ),
        ];
      case SkTabKind.keepsake:
        return [_Rail(title: tab.label, cards: const [])];
      case SkTabKind.pages:
        return [
          _Rail(title: tab.label, cards: [
            for (final id in tab.pageIds)
              if (content.pageById(id) case final p?)
                if (p.inBand(bandId)) _pageCard(p),
          ]),
        ];
    }
  }

  _CardSpec _activityCard(SkActivity a, {String? meta}) {
    final word = SkPracticeStore.instance.wordFor(content.doorId, a.id);
    return _CardSpec(
      title: a.title,
      meta: meta ?? (word.isEmpty ? null : word.toUpperCase()),
      chip: a.comingSoon ? 'Coming soon' : 'Activity',
      icon: skDoorFormatIcon('ACTIVITY'),
      soon: a.comingSoon,
      pageId: a.id,
      onTap: () => skOpenActivity(context, content, a, onSurface: widget.onSurface),
    );
  }

  _CardSpec _pageCard(SkPage p) => _CardSpec(
        title: p.title,
        meta: p.subtitle,
        chip: p.comingSoon ? 'Coming soon' : skDoorChip(p.format),
        icon: skDoorFormatIcon(p.format),
        soon: p.comingSoon,
        pageId: p.id,
        onTap: () => skOpenPage(context, content, p, onSurface: widget.onSurface),
      );

  _CardSpec _toolSpec(SkDoorTool tool) => _CardSpec(
        title: tool.label,
        chip: tool.chip,
        icon: tool.icon,
        onTap: () => widget.onSurface(context, tool.surfaceId),
      );

  /// The second line on a tab's card. Counted from the content, never typed
  /// — or, while the tab is locked, the age it opens.
  // ignore: unused_element
  String _countFor(SkDoorTab tab) { // the coverflow's count line, kept for revert
    if (_unlockYears(tab) case final y?) return _lockLine(y);
    final n = tab.tools.length +
        _railsFor(tab).fold(0, (t, r) => t + r.cards.length);
    if (n == 0) return '';
    return n == 1 ? '1 thing' : '$n things';
  }

  /// The grown-up side asks the gate ITSELF on open (`SkGrownUpScreen`),
  /// so the closing card does not ask first — one question, not two. A
  /// Consult closing, when a brief un-holds one, opens straight through.
  void _openClosing(SkDoorClosing c) => widget.onSurface(context, c.surfaceId);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          SkChildStore.instance,
          SkPracticeStore.instance,
          V2PaletteStore.instance,
        ]),
        builder: (context, _) => _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final bracket = bracketById(door.doorId);
    final tabs = _tabs;
    // ⚠️ HOUSE HUES (2026-10-25). The door data keeps its own numbers; the
    // paint moves off violet, purple and pink onto the house set.
    final hues = skHouseHues([for (final t in tabs) t.hue]);
    final ti = _tab.clamp(0, tabs.length - 1);
    final hue = skHouseHue(bracket?.hue ?? tabs.first.hue);
    final tint = v2BlockTint(hue, p);
    final tab = tabs[ti];
    final tabHue = hues[ti];
    final mark = skTabMarkOn(door, tab);
    final child = SkChildStore.instance;
    final band = _band;
    final lines = [
      for (final t in tabs)
        if (_unlockYears(t) case final y?) 'From $y years' else '',
    ];
    final railH = SkDoorRail.heightOf(context, lines);

    // ⚠️ A TAB OF TOOLS ALONE STILL GETS A RAIL, headed with its own name.
    final rails = _railsFor(tab);

    return PvLiveSearchScope(
      search: _search,
      child: Scaffold(
        backgroundColor: p.ground,
        // The Feelings brief's off-ramp, on every screen of a door that has
        // one; null — nothing — on every other door.
        bottomNavigationBar: skSafetyBarFor(door.doorId),
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
                search: _search,
                photo: door.heroImageUrl,
                title: bracket?.title.now ?? door.doorId,
                blurb: bracket?.blurb.now ?? '',
                mark: skillMarkFor(door.doorId),
                ageLine: band == null
                    ? (child.ageYears == null
                        ? null
                        : 'For ${child.nameOrYou}  ·  From $kSkAgeFloor years')
                    : 'For ${child.nameOrYou}  ·  '
                        '${content.bandName(band.id)}  ·  '
                        '${band.label}',
              ),
              SkDoorSheet(
                p: p,
                minHeight: pvLiveSearchSheetMin(context, _search),
                children: [
                  if (!_search.idle)
                    ..._liveResults(context, p, hues, tabs)
                  else ...[
                    // ---- the rail, across the seam (the house door's) -------
                    SizedBox(
                      height: railH - SkDoorRail.overlap,
                      child: OverflowBox(
                        alignment: Alignment.bottomCenter,
                        minHeight: railH,
                        maxHeight: railH,
                        child: SkDoorRail(
                          door: door,
                          tabs: tabs,
                          hues: hues,
                          lines: lines,
                          selected: ti,
                          p: p,
                          onPick: (i) => setState(() => _tab = i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ---- a locked tab: one plain line, not the rails --------
                    if (_unlockYears(tab) case final y?) ...[
                      skDoorPad(_LockedPanel(years: y, p: p)),
                      const SizedBox(height: 26),
                    ] else ...[
                      if (tab.note case final note?) ...[
                        skDoorPad(_TabNote(note: note, p: p)),
                        const SizedBox(height: 20),
                      ],

                      // ---- this tab's rails -------------------------------
                      //
                      // ⚠️ ALWAYS A RAIL, EVEN FOR ONE CARD; a tool leads the
                      // first rail unless it names the page it follows.
                      for (final (ri, rail) in rails.indexed) ...[
                        skDoorPad(Text(rail.title,
                            style: pvFraunces(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                letterSpacing: -0.45,
                                color: p.ink1))),
                        if (rail.line case final line?) ...[
                          const SizedBox(height: 4),
                          skDoorPad(Text(line,
                              style: pvManrope(
                                  fontSize: 13.5, height: 1.45, color: p.ink2))),
                        ],
                        const SizedBox(height: 13),
                        for (final cards in [
                          [
                            if (ri == 0)
                              for (final tool in tab.tools)
                                if (tool.afterPageId == null ||
                                    !rail.cards.any((x) => x.pageId == tool.afterPageId))
                                  _toolSpec(tool),
                            for (final card in rail.cards) ...[
                              card,
                              if (ri == 0)
                                for (final tool in tab.tools)
                                  if (tool.afterPageId != null &&
                                      tool.afterPageId == card.pageId)
                                    _toolSpec(tool),
                            ],
                          ]
                        ]) ...[
                          if (cards.isNotEmpty)
                            SizedBox(
                              height: skShelfRailHeight(MediaQuery.textScalerOf(context)),
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: kSkDoorGutter),
                                itemCount: cards.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, i) => _shelfCard(
                                  cards[i],
                                  p,
                                  // An activities tab gives each skill its own
                                  // house hue, so the rails read apart; every
                                  // other tab keeps its own.
                                  hue: tab.kind == SkTabKind.activities
                                      ? kSkHouseHues[(kSkHouseHues.indexOf(tabHue) + ri)
                                              .clamp(0, 1 << 20) %
                                          kSkHouseHues.length]
                                      : tabHue,
                                  mark: mark,
                                ),
                              ),
                            ),
                        ],
                        const SizedBox(height: 26),
                      ],
                    ],

                    // ---- the tab's footer, in a human voice -----------------
                    if (tab.footer case final line?) ...[
                      skDoorPad(Text(line,
                          style: pvFraunces(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: p.ink2))),
                      const SizedBox(height: 22),
                    ],

                    // ---- the closing, under every tab -----------------------
                    if (door.closing case final c?) ...[
                      skDoorPad(SkDoorRow(
                        p: p,
                        hue: hue,
                        icon: c.grownUp
                            ? Icons.lock_outline_rounded
                            : Icons.chat_bubble_outline_rounded,
                        chip: c.chip,
                        title: c.label,
                        blurb: c.blurb,
                        onTap: () => _openClosing(c),
                      )),
                      const SizedBox(height: 22),
                    ],

                    skDoorPad(SkDoorDisclaimer(p: p, text: door.disclaimer)),
                  ],
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }

  /// "TODAY" -> "Today": a card's word, as the grey line writes it.
  static String _sentence(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  /// A rail card as the house shelf card: the tab's drawn mark on its pale
  /// ground, the kind's badge, the title, and one grey line — the kind, then
  /// her word for it or her band ("Activity · Tried", "Activity · Unplugged").
  Widget _shelfCard(_CardSpec spec, V2Palette p,
      {required double hue, required TtcTabMark mark}) {
    final band = _band;
    final after = spec.meta != null
        ? _sentence(spec.meta!)
        : (spec.chip == 'Activity' && band != null ? content.bandName(band.id) : null);
    return SkShelfCard(
      p: p,
      hue: hue,
      mark: mark,
      kindIcon: spec.icon,
      title: spec.title,
      line: [spec.chip, ?after].join('  ·  '),
      comingSoon: spec.soon,
      onTap: spec.onTap,
    );
  }

  /// What the field finds on this door, for her band: activities by their
  /// title and one line, lessons by title. The house door's results, in
  /// skilling's own words.
  List<Widget> _liveResults(
      BuildContext context, V2Palette p, List<double> hues, List<SkDoorTab> tabs) {
    final q = _search.query.toLowerCase();
    final band = _band;
    if (!_search.searching || band == null) {
      return [
        const SizedBox(height: 22),
        skDoorPad(Text('Type a word to find it on this door',
            style: pvFraunces(
                fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1))),
        const SizedBox(height: 6),
        skDoorPad(Text('Try "story", "steps" or "loud".',
            style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2))),
        const SizedBox(height: 8),
      ];
    }
    final acts = [
      for (final a in content.activities)
        if (a.band == band.id &&
            (a.title.toLowerCase().contains(q) || a.oneLine.toLowerCase().contains(q)))
          a,
    ];
    final pages = [
      for (final pg in content.lessons)
        if (pg.inBand(band.id) && pg.title.toLowerCase().contains(q)) pg,
    ];
    final none = acts.isEmpty && pages.isEmpty;
    final name = bracketById(door.doorId)?.title.now ?? 'this door';
    Widget row(IconData icon, String title, String line, VoidCallback onTap) =>
        InkWell(
          onTap: () {
            _search.focus.unfocus();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kSkDoorGutter, vertical: 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
            child: Row(children: [
              Icon(icon, size: 20, color: p.ink1),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      style: pvManrope(
                          fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                  const SizedBox(height: 2),
                  Text(line,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 12.5, color: p.ink3)),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink2),
            ]),
          ),
        );
    return [
      const SizedBox(height: 22),
      skDoorPad(Text(none ? 'Nothing in $name by that name' : 'In $name',
          style: pvFraunces(
              fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1))),
      const SizedBox(height: 10),
      for (final a in acts.take(30))
        row(skDoorFormatIcon('ACTIVITY'), a.title,
            'Activity  ·  ${content.skillById(a.skillPurpose)?.label ?? content.bandName(band.id)}',
            () => skOpenActivity(context, content, a, onSurface: widget.onSurface)),
      for (final pg in pages.take(30))
        row(skDoorFormatIcon(pg.format), pg.title,
            [skDoorChip(pg.format), ?pg.subtitle].join('  ·  '),
            () => skOpenPage(context, content, pg, onSurface: widget.onSurface)),
      if (none) ...[
        const SizedBox(height: 4),
        skDoorPad(Text('Try a shorter word, or one from an activity\'s name.',
            style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2))),
      ],
      const SizedBox(height: 8),
    ];
  }

  /* The body before the house look (2026-10-25), kept for revert: the
  // coverflow deck, the tinted 142x176 rail cards, no intro chip, no search.
  Widget _body(BuildContext context, V2Palette p) {
    final bracket = bracketById(door.doorId);
    final tabs = _tabs;
    final hue = bracket?.hue ?? tabs.first.hue;
    final tint = v2BlockTint(hue, p);
    final tab = tabs[_tab.clamp(0, tabs.length - 1)];
    final child = SkChildStore.instance;
    final band = _band;

    // ⚠️ A TAB OF TOOLS ALONE STILL GETS A RAIL, headed with its own name.
    final rails = _railsFor(tab);

    return Scaffold(
      backgroundColor: p.ground,
      // The Feelings brief's off-ramp, on every screen of a door that has
      // one; null — nothing — on every other door.
      bottomNavigationBar: skSafetyBarFor(door.doorId),
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
              eyebrow: bracket?.label.now ?? door.doorId,
              title: bracket?.title.now ?? door.doorId,
              blurb: bracket?.blurb.now ?? '',
              mark: skillMarkFor(door.doorId),
              ageLine: band == null
                  ? (child.ageYears == null
                      ? null
                      : 'FOR ${child.nameOrYou.toUpperCase()}  ·  FROM $kSkAgeFloor YEARS')
                  : 'FOR ${child.nameOrYou.toUpperCase()}  ·  '
                      '${content.bandName(band.id).toUpperCase()}  ·  '
                      '${band.label.toUpperCase()}',
            ),
            SkDoorSheet(p: p, children: [
              const SizedBox(height: 22),

              // ---- the selector, first thing under the hero ----------------
              SkDoorCarousel(
                groups: tabs,
                counts: [for (final t in tabs) _countFor(t)],
                locked: [for (final t in tabs) _unlockYears(t) != null],
                selected: _tab,
                p: p,
                onPick: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 26),

              // ---- a locked tab: the panel, not the rails -----------------
              if (_unlockYears(tab) case final y?) ...[
                skDoorPad(_LockedPanel(years: y, p: p)),
                const SizedBox(height: 26),
              ] else ...[
                if (tab.note case final note?) ...[
                  skDoorPad(_TabNote(note: note, p: p)),
                  const SizedBox(height: 20),
                ],

                // ---- this tab's rails -----------------------------------
                //
                // ⚠️ ALWAYS A RAIL, EVEN FOR ONE CARD; a tool leads the
                // first rail unless it names the page it follows. The
                // parenting door's rules, seen on a phone, kept whole.
                for (final (ri, rail) in rails.indexed) ...[
                  skDoorPad(Text(rail.title,
                      style: pvFraunces(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: -0.45,
                          color: p.ink1))),
                  if (rail.line case final line?) ...[
                    const SizedBox(height: 4),
                    skDoorPad(Text(line,
                        style: pvManrope(
                            fontSize: 13.5, height: 1.45, color: p.ink2))),
                  ],
                  const SizedBox(height: 13),
                  for (final cards in [
                    [
                      if (ri == 0)
                        for (final tool in tab.tools)
                          if (tool.afterPageId == null ||
                              !rail.cards.any((x) => x.pageId == tool.afterPageId))
                            _toolSpec(tool),
                      for (final card in rail.cards) ...[
                        card,
                        if (ri == 0)
                          for (final tool in tab.tools)
                            if (tool.afterPageId != null &&
                                tool.afterPageId == card.pageId)
                              _toolSpec(tool),
                      ],
                    ]
                  ]) ...[
                    if (cards.isNotEmpty)
                      SizedBox(
                        height: kSkRailCardHeight,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: kSkDoorGutter),
                          itemCount: cards.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: kSkRailGap),
                          itemBuilder: (context, i) => _RailCard(
                            spec: cards[i],
                            p: p,
                            hue: tab.hue,
                            index: i,
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 26),
                ],
              ],

              // ---- the tab's footer, in a human voice ----------------------
              if (tab.footer case final line?) ...[
                skDoorPad(Text(line,
                    style: pvFraunces(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: p.ink2))),
                const SizedBox(height: 22),
              ],

              // ---- the closing, under every tab ----------------------------
              if (door.closing case final c?) ...[
                skDoorPad(SkDoorRow(
                  p: p,
                  hue: hue,
                  icon: c.grownUp
                      ? Icons.lock_outline_rounded
                      : Icons.chat_bubble_outline_rounded,
                  chip: c.chip,
                  title: c.label,
                  blurb: c.blurb,
                  onTap: () => _openClosing(c),
                )),
                const SizedBox(height: 22),
              ],

              skDoorPad(SkDoorDisclaimer(p: p, text: door.disclaimer)),
            ]),
          ],
        ),
      ]),
    );
  }
  */
}

/// One rail: a heading, a quiet line, and its cards.
class _Rail {
  const _Rail({required this.title, required this.cards, this.line});
  final String title;
  final String? line;
  final List<_CardSpec> cards;
}

// -----------------------------------------------------------------------------
//  The hero — the parenting door's, with the skill mark and the band line.
// -----------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({
    required this.p,
    required this.tint,
    required this.search,
    required this.title,
    required this.blurb,
    required this.mark,
    this.photo,
    this.ageLine,
  });

  final V2Palette p;
  final Color tint;
  final PvLiveSearch search;
  final String? photo;
  final String title;
  final String blurb;
  final SkillMark? mark;
  final String? ageLine;

  /// The photograph runs under the sheet's corners and the rail's top half.
  static const double _bleed = kSkDoorHeroOverlap + SkDoorRail.overlap;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    const shadow = [Shadow(color: Color(0x59000000), blurRadius: 12)];
    final onPhoto = photo != null;

    // ⚠️ THE HOUSE DOOR'S HEADER (2026-10-25): the parenting `_QuietHero`'s
    // words — title 28, a headline at 14.5, the age line at 12.5 — then the
    // intro video chip (GLOBAL-CHANGES #5) and the search field. The eyebrow
    // and the violet age line went: no other door has either.
    final words = PvLiveSearchWords(
      search: search,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvFraunces(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                height: 1.12,
                letterSpacing: -0.5,
                color: onPhoto ? Colors.white : p.ink1,
              ).copyWith(shadows: onPhoto ? shadow : null)),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(blurb,
                maxLines: ageLine == null ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                  fontSize: 14.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: onPhoto ? Colors.white.withValues(alpha: 0.95) : p.ink2,
                ).copyWith(shadows: onPhoto ? shadow : null)),
          ),
          // ⚠️ THE BAND LINE. A statement, not a chooser — the age rule.
          if (ageLine != null) ...[
            const SizedBox(height: 6),
            Text(ageLine!,
                key: const Key('sk-door-age-line'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: onPhoto ? Colors.white : p.ink1,
                ).copyWith(shadows: onPhoto ? shadow : null)),
          ],
          const SizedBox(height: 14),
          PvDoorIntroChip(p: p, onPhoto: onPhoto),
        ],
      ),
    );

    final field = PvLiveSearchField(
      key: const Key('sk-door-search'),
      search: search,
      p: p,
      hint: 'Search $title',
    );

    return Stack(clipBehavior: Clip.none, children: [
      if (onPhoto)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -_bleed,
          child: Stack(fit: StackFit.expand, children: [
            Image.network(
              photo!,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
            ),
            // The parenting header's two scrims, value for value.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.52),
                    Colors.black.withValues(alpha: 0.38),
                    Colors.black.withValues(alpha: 0.12),
                  ],
                  stops: const [0, 0.62, 1],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.35),
                  ],
                  stops: const [0, 0.25, 0.55, 1],
                ),
              ),
            ),
          ]),
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
                  : V3SkillArt(mark: mark!, tint: tint),
            ),
          ),
        ),
      Padding(
        padding: EdgeInsets.only(top: top),
        child: Stack(alignment: Alignment.bottomLeft, children: [
          const SizedBox(height: 262, width: double.infinity),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 58, 22, 20 + SkDoorRail.overlap - 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [words, const SizedBox(height: 14), field],
            ),
          ),
        ]),
      ),
      Positioned(
        top: top + 8,
        left: 20,
        child: Material(
          color: Colors.white.withValues(alpha: 0.55),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const Key('sk-door-back'),
            onTap: () => Navigator.of(context).maybePop(),
            // The parenting hero's 38, NOT the child tap size: at 56 it sat
            // over the face in Communication's photograph (2026-09-15).
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(Icons.arrow_back_rounded, size: 19, color: p.ink1),
            ),
          ),
        ),
      ),
    ]);
  }
}

/* The hero before the house look (2026-10-25), kept for revert: an eyebrow,
// a 30pt title, a violet band line on the plain field, no chip, no search.
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
  final SkillMark? mark;
  final String? ageLine;

  @override
  Widget build(BuildContext context) {
    final onPhoto = photo != null;
    final ink1 = onPhoto ? Colors.white : p.ink1;
    final ink2 = onPhoto ? Colors.white.withValues(alpha: 0.86) : p.ink2;
    // `Clip.none` lets the picture run past the hero; the sheet covers the
    // overflow with its rounded edge. See the pregnancy door for why a
    // transform could never do this.
    return Stack(clipBehavior: Clip.none, children: [
      if (onPhoto)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -kSkDoorHeroOverlap,
          child: Image.network(
            photo!,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const SizedBox.shrink(),
          ),
        ),
      if (onPhoto)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -kSkDoorHeroOverlap,
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
                  : V3SkillArt(mark: mark!, tint: tint),
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
                        // The parenting hero's 38, NOT the child tap size.
                        // At 56 it sat over the face in Communication's
                        // photograph (seen on a phone, 2026-09-15); the
                        // hero is where a parent taps too, and the child
                        // sizes belong to the content screens.
                        width: 38,
                        height: 38,
                        child: Icon(Icons.arrow_back_rounded,
                            size: 19, color: p.ink1)),
                  ),
                ),
              ),
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
              // ⚠️ THE BAND LINE. A statement, not a chooser — the age rule.
              if (ageLine != null) ...[
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.face_outlined,
                      size: 14, color: onPhoto ? Colors.white : p.action),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(ageLine!,
                        key: const Key('sk-door-age-line'),
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
*/

// -----------------------------------------------------------------------------
//  Tiles — the parenting door's rail card, keyed on a spec
// -----------------------------------------------------------------------------

/// What a locked tab shows instead of its rails: the age it opens and the
/// promise that nothing on it is due before then. Plain words on the page,
/// no box (house look, 2026-10-25; the bordered card is kept below).
class _LockedPanel extends StatelessWidget {
  const _LockedPanel({required this.years, required this.p});
  final int years;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final name = SkChildStore.instance.name;
    final who = name.isEmpty ? 'she' : name;
    return Row(
      key: const Key('sk-door-locked-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.lock_outline_rounded, size: 20, color: p.ink1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('This opens when $who turns $years.',
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
      ],
    );
    /* The bordered card, kept for revert:
    return Container(
      key: const Key('sk-door-locked-panel'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      ... a surfaceAlt lock disc, 'FROM $years YEARS', then the two lines.
    );
    */
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
    this.pageId,
  });
  final String title;
  final String? meta;
  final String chip;
  final IconData icon;
  final VoidCallback onTap;

  /// Full size, dimmed, and it does not respond to a tap — no ink either.
  final bool soon;

  /// For `afterPageId` matching.
  final String? pageId;
}

// ignore: unused_element
class _RailCard extends StatelessWidget { // superseded by SkShelfCard (2026-10-25), kept for revert
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
          width: kSkRailCardWidth,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
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
                          // A point up on the parenting card: the child
                          // reads this one.
                          fontSize: 15.5,
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

/// A tab's standing note. Quiet type, no box.
class _TabNote extends StatelessWidget {
  const _TabNote({required this.note, required this.p});
  final String note;
  final V2Palette p;

  // House look (2026-10-25): one quiet grey line with an info mark, never a
  // tinted box behind text. The grey box, kept for revert:
  // Container(padding: EdgeInsets.fromLTRB(14, 12, 14, 12), decoration:
  //     BoxDecoration(color: p.surfaceAlt, borderRadius: 16), child: Text(note))
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline_rounded, size: 15, color: p.ink3),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(note,
                style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
          ),
        ],
      );
}
