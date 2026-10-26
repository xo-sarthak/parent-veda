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

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import '../../../ask_veda/ask_veda_mark.dart';

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
import 'pp_door_inline_tools.dart';
import '../../../data/doors/pv_door_data.dart' show PvDoorGroup;
import '../../../services/pv_search_store.dart';
import '../../../widgets/pv_feedback.dart';
import '../../../widgets/pv_door_intro_chip.dart';
import '../../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../doors/pv_door_chrome.dart' show PvDoorSheet, kPvDoorGutter;
import '../../doors/pv_door_rail.dart';
import '../../doors/pv_door_screen.dart' show kPvDoorBlockGap, kPvDoorHeadingGap, kPvDoorHeroQuietHeight;
import '../../doors/pv_live_search.dart';
import '../../doors/pv_shelf_card.dart';
import '../../doors/pv_shelf_spec.dart' show PvShelfKind;
import '../pp_din_by_din.dart';
import '../pp_age_bands.dart' show PpBand;
import '../pp_vaccine_data.dart' show VaxStore;
import '../pp_page_read.dart' show kPpPageReadPrefix;
import '../pp_relevance.dart';
import '../pp_search.dart';

// -----------------------------------------------------------------------------
//  Rail geometry — the pregnancy door's numbers, so the sum is the same sum:
//  18 gutter + 142 + 10 + 142 + 10 = 322 on a 360dp screen, 38pt of the third.
// -----------------------------------------------------------------------------
/// The sentence a parenting door ends on when it names none of its own.
const String kPpDoorClosingLine =
    'Every child finds their own pace. If something worries you, your '
    "child's doctor is always the right person to ask.";

const double kPpRailCardWidth = 142;
const double kPpRailCardHeight = 176;
const double kPpRailGap = 10;

/// How far the sheet is pulled up over a photographic hero. One number, used
/// twice — see the pregnancy door for why the two uses must not drift.
const double kPpDoorHeroOverlap = 38;

/// ⚠️ THE TTC DOOR FORMAT, ON EVERY PARENTING DOOR (2026-10-07, the parenting
/// gap pass: "keep the design consistent with TTC and pregnancy on every
/// screen; it must look like ONE ParentVeda"). The pregnancy doors moved to it
/// on 2026-10-02 (`pv_door_screen.dart`); this is the same thing on the
/// parenting door: the quiet hero (the door's NAME as the title, one line
/// under it, the white search pill that searches this door, the photograph
/// parallaxing), the quiet tab rail across the seam (`PvDoorRail`, now with a
/// lock for a tab her child has not reached), every card a `PvShelfCard`
/// that says what it is (Article · 4 min read, Tool, Recipe, Activity), the
/// pinned red flag folded into one white row, TTC's 24/12 rhythm, and no
/// violet. `test/pp_door_ttc_format_test.dart` holds the numbers equal.
/// Kept for revert: `false` draws the 2026-09 door (`_bodyClassic`).
const bool kPpDoorTtcFormat = true;

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
  // The opening tab is index 0 of [_tabs], which is now ordered for his age
  // (S1, 2026-10-25): see [_tabs]. So 0 is still right, and still the first
  // card on the rail.

  PpDoor get door => widget.door;

  /// The other age bands she has unfolded at the foot of a tab (band ids).
  final Set<String> _openBands = {};

  /// The hero's search field, its three states shared with every door
  /// (`PvLiveSearch`). Searches this door first, then every door.
  final PvLiveSearch _search = PvLiveSearch();

  /// The hero's parallax reads this, as the pregnancy and TTC doors do.
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _offset = ValueNotifier(0);

  void _onScroll() {
    final o = _scroll.offset;
    if (o != _offset.value) _offset.value = o;
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    PvSearchStore.instance.init();
    if (door.tabs.any((t) => t.dueLine != null)) VaxStore.instance.init();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _offset.dispose();
    _search.dispose();
    super.dispose();
  }

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
  ///
  /// ⚠️ NO TAB IS LOCKED ANY MORE (step 0 · S9, the user 2026-10-24: "should
  /// we lock the content???", answered "Unlock, every door"). A tab for a
  /// later age opens, sits last, and starts with one line: "For later. This
  /// usually starts from 1 year." Parents read ahead, and stage follows age
  /// loosely. What is behind him still drops. The lock panel and the misted
  /// card are kept below, unused, for revert.
  ///
  /// ⚠️ AND AGE PICKS THE OPENING TAB (S1, 2026-10-25). The tabs for her band
  /// come first, in `door.tabOrder[band]` where the door gives one, else in
  /// the door's own order. Index 0 is where she lands.
  ///
  /// The master plan's guess, "open on the tab with the most pages for her
  /// band", is not used: every door plan now names its order by age, and the
  /// guess moved action doors off their action tab (First 40 at day 12 left
  /// Day by day; Potty left its timeline). It is kept below for revert.
  List<PpDoorTab> get _tabs {
    final kept = [
      for (final t in door.tabs)
        if (_lockFor(t) != _Lock.past) t,
    ];
    final now = [for (final t in kept) if (_unlockMonths(t) == null) t];
    final later = [for (final t in kept) if (_unlockMonths(t) != null) t]
      // Stable: ties keep the door's own order.
      ..sort((a, b) => _unlockMonths(a)!.compareTo(_unlockMonths(b)!));
    final order = door.tabOrder[_band];
    if (order != null) {
      int rank(PpDoorTab t) {
        final i = order.indexOf(t.id);
        return i < 0 ? order.length : i;
      }

      final indexed = [for (var i = 0; i < now.length; i++) (i, now[i])]
        ..sort((a, b) {
          final (ia, ta) = a;
          final (ib, tb) = b;
          final r = rank(ta).compareTo(rank(tb));
          return r != 0 ? r : ia.compareTo(ib);
        });
      return [for (final e in indexed) e.$2, ...later];
    }
    // The most-pages guess, kept for revert (see above):
    // if (now.length > 1) {
    //   var best = 0, most = -1;
    //   for (var i = 0; i < now.length; i++) {
    //     final n = _thingsFor(now[i]);
    //     if (n > most) {
    //       most = n;
    //       best = i;
    //     }
    //   }
    //   if (best != 0) now.insert(0, now.removeAt(best));
    // }
    return [...now, ...later];
  }
  // Kept for revert (S9): open first, then locked by the age they open.
  // List<PpDoorTab> get _tabs => [
  //       for (final t in door.tabs)
  //         if (_lockFor(t) != _Lock.past) t,
  //     ]..sort((a, b) {
  //         final la = _unlockMonths(a), lb = _unlockMonths(b);
  //         if (la == null && lb == null) return 0;
  //         if (la == null) return -1;
  //         if (lb == null) return 1;
  //         return la.compareTo(lb);
  //       });

  // How much a tab holds for her band, for the most-pages guess (kept for
  // revert with it):
  // int _thingsFor(PpDoorTab tab) =>
  //     tab.tools.length +
  //     _bandRailsFor(tab).fold<int>(0, (t, r) => t + r.$2.length) +
  //     (tab.redFlagPageId != null ? 1 : 0);

  /// The band a tab shows. Her own, or, for a tab for later (S9), the first
  /// band after hers that the tab has PAGES for, so it opens on what it will
  /// hold rather than empty. Pages, not areas: You, Maa's Going back area
  /// opens at six weeks but its pages at thirteen.
  String _bandOf(PpDoorTab tab) {
    if (_unlockMonths(tab) == null) return _band;
    final set = section.bandSet;
    if (set == null) return _band;
    final at = set.bands.indexWhere((b) => b.id == _band);
    for (var j = at + 1; j < set.bands.length; j++) {
      final b = set.bands[j];
      if (tab.areaIds.any((id) => section.areas.any((a) =>
          a.id == id && a.inBand(b.id) && a.pagesFor(b.id).isNotEmpty))) {
        return b.id;
      }
    }
    return _band;
  }

  /// "For later. This usually starts from 1 year." The one line a tab for a
  /// later age opens with (S9).
  String _laterLine(PpDoorTab tab, int months) {
    // Her bands are in weeks (You, Maa M2): Going back opens at six weeks,
    // which in months read "about 1 months".
    final weeks = _unlockWeeks(tab);
    if (door.aboutHer && weeks != null && weeks < 13) {
      return 'For later. This usually starts about ${weeks.round()} weeks '
          'after the birth.';
    }
    if (door.aboutHer) {
      final when = months % 12 == 0
          ? '${months ~/ 12} ${months == 12 ? 'year' : 'years'}'
          : '$months months';
      return 'For later. This usually starts about $when after the birth.';
    }
    return 'For later. This usually starts ${_lockLabel(months).replaceFirst('From', 'from')}.';
  }

  /// The month a locked tab opens, or null when it is open now. Rounded from
  /// [_unlockWeeks], which decides.
  int? _unlockMonths(PpDoorTab t) {
    final w = _unlockWeeks(t);
    return w == null ? null : (w / 4.345).round();
  }

  /// ⚠️ THE WEEK A TAB FOR LATER OPENS, ON THE SECTION'S OWN CLOCK (You, Maa
  /// M2, 2026-10-25). It read the selected child's months, so on You, Maa
  /// a mother of a toddler and a newborn had Going back open as if she were
  /// years past the birth, and six weeks rounded to a month. For a months
  /// set nothing changes: `fromMonths > floor(weeks / 4.345)` is the same
  /// test as `fromMonths * 4.345 > weeks`. Was, kept for revert:
  // int? _unlockMonths(PpDoorTab t) {
  //   if (t.areaIds.isEmpty) return null;
  //   final age = ChildProfileStore.instance.ageInMonths;
  //   final starts = <int>[];
  //   for (final id in t.areaIds) {
  //     for (final a in section.areas.where((a) => a.id == id)) {
  //       if (a.inBand(_band)) return null;
  //       starts.add(_areaFrom(a));
  //     }
  //   }
  //   if (starts.isEmpty) return null;
  //   final from = starts.reduce((x, y) => x < y ? x : y);
  //   return from > age ? from : null;
  // }
  double? _unlockWeeks(PpDoorTab t) {
    if (t.areaIds.isEmpty) return null;
    final age =
        section.bandSet?.clockWeeks ?? ChildProfileStore.instance.ageInWeeks;
    final starts = <double>[];
    for (final id in t.areaIds) {
      for (final a in section.areas.where((a) => a.id == id)) {
        if (a.inBand(_band)) return null;
        starts.add(_areaFromWeeks(a));
      }
    }
    if (starts.isEmpty) return null;
    final from = starts.reduce((x, y) => x < y ? x : y);
    return from > age ? from : null;
  }

  /// Where an area's earliest band starts, in weeks. No bands: every age.
  double _areaFromWeeks(PpArea a) {
    final set = section.bandSet;
    if (a.bands.isEmpty || set == null) return 0;
    double? from;
    for (final b in set.bands) {
      if (a.bands.contains(b.id) && (from == null || b.startWeeks < from)) {
        from = b.startWeeks;
      }
    }
    return from ?? 0;
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

  // Where an area's earliest band starts, in months. An area with no bands
  // is for every age. Replaced by [_areaFromWeeks] (You, Maa M2), kept for
  // revert:
  // int _areaFrom(PpArea a) {
  //   final set = section.bandSet;
  //   if (a.bands.isEmpty || set == null) return 0;
  //   var from = 1 << 20;
  //   for (final b in set.bands) {
  //     if (a.bands.contains(b.id) && b.fromMonths < from) from = b.fromMonths;
  //   }
  //   return from == 1 << 20 ? 0 : from;
  // }

  /// "From 1 year", "From 6 months": the card's second line while locked.
  String _lockLabel(int months) => months % 12 == 0
      ? 'From ${months ~/ 12} ${months == 12 ? 'year' : 'years'}'
      : 'From $months months';

  /// The card's second line while locked: "Locked · From 1 year".
  // Unused since S9 (no lock), kept for revert:
  // String _lockLine(int months) => 'Locked  ·  ${_lockLabel(months)}';
  PpSection get section => ppSectionFor(door.sectionId)!;

  String get _band => section.bandSet?.active.id ?? '';

  /// The id a page's reading progress is kept under (pp_page_read.dart).
  String _readIdOf(PpPage page) => '$kPpPageReadPrefix${section.id}_${page.id}';

  /// The pages a tab shows for her band, minus the pinned red flag, ORDERED BY
  /// HER SITUATION (2026-10-21, Wave 4, pp_relevance.dart): inside each rail
  /// the pages about her situation lead (born early, C-section, formula...),
  /// finished reads sink; and a rail about her situation leads the tab. The
  /// brain is stable, so with no signal the writers' order is untouched. It
  /// never drops a page. The other bands are no longer lost either: see
  /// [_otherBands].
  List<(PpArea, List<PpPage>)> _railsFor(PpDoorTab tab) {
    final sit = PpSituation.now();
    final band = _bandOf(tab);
    final rails = [
      for (final (area, pages) in _bandRailsFor(tab))
        (
          area,
          // First 40 days keeps its own day order (pp_din_by_din.dart), and
          // the age rail its plan's order (PpDoorTab.ageRail).
          area.id == kPpDinTabId || area.id == kPpAgeRailId
              ? pages
              : ppRelevanceOrder(pages,
                  situation: sit,
                  text: (x) => x.title,
                  readId: _readIdOf,
                  alwaysFirst: ppIsRedFlagPage,
                  forHerAge: (x) => _forHerAge(x, band)),
        ),
    ];
    return ppRelevanceOrder(rails,
        situation: sit,
        text: (r) => [r.$1.title, for (final x in r.$2) x.title].join(' '),
        // The age rail is the first rail, whatever a signal lifts.
        alwaysFirst: (r) => r.$1.id == kPpAgeRailId);
  }

  /// A page written for her age rather than every age (H-M2): tagged with her
  /// band and with no more than half the door's bands. "A fever under three
  /// months" (newborn only) and "First teeth" (3 months to 3 years) are; a
  /// page tagged for every band but the newborn one is about every age, and
  /// is not lifted, or nearly every page would be.
  bool _forHerAge(PpPage x, String band) {
    final n = section.bandSet?.bands.length ?? 0;
    return x.bands.contains(band) && x.bands.length * 2 <= n;
  }

  /// "3 weeks after the birth", "4 months after the birth": her time on her
  /// own clock (You, Maa M2), under her age rail.
  String _herWeeksLine() {
    final w = (section.bandSet?.clockWeeks ??
            ChildProfileStore.instance.youngestAgeInWeeks)
        .floor();
    if (w < 13) return '$w ${w == 1 ? 'week' : 'weeks'} after the birth';
    final m = (w / 4.345).round();
    return '$m months after the birth';
  }

  /// The tab's age rail for the band it shows (`PpDoorTab.ageRail`): its
  /// pages that exist and are for that band, never the pinned flag.
  (PpAgeRail, List<PpPage>)? _ageRailFor(PpDoorTab tab) {
    final rail = tab.ageRail[_bandOf(tab)];
    if (rail == null) return null;
    final pages = [
      for (final id in rail.pageIds)
        if (section.pageById(id) case final x?)
          if (x.id != tab.redFlagPageId && x.inBand(_bandOf(tab))) x,
    ];
    return pages.isEmpty ? null : (rail, pages);
  }

  /// The tab's tools for the band it shows (`PpDoorTool.bands`, Feeding plan
  /// §2c). The rest sit in the band blocks at the foot ([_otherBands]).
  ///
  /// ⚠️ NOT A TOOL THE INLINE ROW ALREADY SHOWS (Behaviour BH1). The Right now
  /// row ends on What to say, and the Crying and Tantrums tabs carry the same
  /// tool as a row: two cards for one tool, a thumb apart. Where the row is
  /// drawn, it is the way in; on the same tab for another age (no row), the
  /// tool row is back. Was every tool in her band, kept for revert:
  /// `for (final t in tab.tools) if (t.inBand(_bandOf(tab))) t`.
  List<PpDoorTool> _toolsFor(PpDoorTab tab) => [
        for (final t in tab.tools)
          if (t.inBand(_bandOf(tab)) && !_onInlineRow(tab, t)) t,
      ];

  bool _onInlineRow(PpDoorTab tab, PpDoorTool t) =>
      tab.inlineSurfaceId != null &&
      ppDoorInlineSurfaceIds(tab.inlineSurfaceId!).contains(t.surfaceId);

  /// Pages from another tab drawn on this one (`PpDoorTab.extraPageIds`),
  /// for the band it shows. Never the tab's own red flag.
  List<PpPage> _extraPagesFor(PpDoorTab tab) => [
        for (final id in tab.extraPageIds)
          if (section.pageById(id) case final x?)
            if (x.id != tab.redFlagPageId && x.inBand(_bandOf(tab))) x,
      ];

  /// The tab's pinned red flag, when the page is for the band it shows.
  /// Mastitis is pinned on Milk feeds while she may still be feeding (to two
  /// years); for a three-year-old it would be a warning about nothing she
  /// does (Feeding plan §2d). An untagged page is for every band, so a door
  /// whose flag has no bands is unchanged.
  PpPage? _redFlagFor(PpDoorTab tab) {
    final id = tab.redFlagPageId;
    if (id == null) return null;
    final page = section.pageById(id);
    if (page == null || !page.inBand(_bandOf(tab))) return null;
    return page;
  }

  /// The other bands of this tab, each with the pages not already shown: the
  /// next band first, then earlier ones, then later ones.
  ///
  /// ⚠️ THIS REPLACES HIDING. The door used to keep only her band and say
  /// nothing about the rest, so a mother could not read ahead or look back.
  /// Her band still leads and is the only one open; the next follows open as
  /// "Coming up next"; the rest fold at the foot (PpBandSet.ordered's rule:
  /// reordered, not filtered).
  ///
  /// ⚠️ A TOOL OUTSIDE HER BAND GOES TO THE FIRST BLOCK IT FITS (Feeding plan
  /// §2c, 2026-10-25), so the newborn feed timer is folded under "Earlier"
  /// for a toddler instead of leading his first rail, and is never gone.
  List<(PpBand, List<PpPage>, PpBandDistance, List<PpDoorTool>)> _otherBands(
      PpDoorTab tab) {
    final set = section.bandSet;
    if (set == null) return const [];
    final active = set.active;
    // Measured from the band the tab shows: for a tab for later (S9) that is
    // its own first band, so the one after it is "Coming up next".
    final at = set.bands.indexWhere((b) => b.id == _bandOf(tab));
    final shown = {
      for (final r in _bandRailsFor(tab)) for (final x in r.$2) x.id,
      for (final x in _extraPagesFor(tab)) x.id,
      // On the shelf already (Potty's Teach the toy is two stages').
      ..._inlinePageIds(tab),
    };
    // A page whose title is already on her rails, or is a tool's name there
    // ("Sleep at this age" is both a chart and a page), is not shown twice.
    final shownTitles = {
      for (final r in _bandRailsFor(tab)) for (final x in r.$2) x.title,
      for (final tool in tab.tools) tool.label,
    };
    final blocks = <(PpBand, List<PpPage>, PpBandDistance)>[];
    for (var j = 0; j < set.bands.length; j++) {
      final b = set.bands[j];
      // A tab for later shows its own band's rails already (S9).
      if (b.id == active.id || b.id == _bandOf(tab)) continue;
      final seen = <String>{};
      final pages = [
        for (final id in tab.areaIds)
          for (final area in section.areas.where((a) => a.id == id))
            if (area.inBand(b.id))
              for (final x in area.pagesFor(b.id))
                if (x.id != tab.redFlagPageId &&
                    !shown.contains(x.id) &&
                    !shownTitles.contains(x.title) &&
                    seen.add(x.id))
                  x,
      ];
      blocks.add((
        b,
        pages,
        j == at + 1
            ? PpBandDistance.next
            : j < at
                ? PpBandDistance.earlier
                : PpBandDistance.further,
      ));
    }
    blocks.sort((a, b) => a.$3.score.compareTo(b.$3.score));
    // A tool the inline row shows is placed too, so it does not drop to a
    // band block at the foot instead (BH1).
    final placed = <PpDoorTool>{
      ..._toolsFor(tab),
      for (final t in tab.tools)
        if (_onInlineRow(tab, t)) t,
    };
    final out = <(PpBand, List<PpPage>, PpBandDistance, List<PpDoorTool>)>[];
    for (final (b, pages, dist) in blocks) {
      final tools = [
        for (final t in tab.tools)
          if (!placed.contains(t) && t.inBand(b.id)) t,
      ];
      placed.addAll(tools);
      if (pages.isEmpty && tools.isEmpty) continue;
      out.add((b, pages, dist, tools));
    }
    return out;
  }

  /// Her band's rails, as the door always built them (kept as the source the
  /// brain orders). The age rail leads when the tab has one for her band,
  /// and the area rails skip its pages (H-M1); an area left empty by that
  /// drops, which is what "nothing shows twice" costs.
  ///
  /// ⚠️ AND THEY SKIP WHAT AN INLINE TOOL DRAWS (Potty PT3, 2026-10-25), by
  /// the same rule: Try this today is pages of Starting out's own activities
  /// area, so from one to three the rail of them would be the shelf twice.
  /// For every other age the area is a rail as before.
  List<(PpArea, List<PpPage>)> _bandRailsFor(PpDoorTab tab) {
    final age = _ageRailFor(tab);
    final onInline = _inlinePageIds(tab);
    final onAge = {
      for (final x in age?.$2 ?? const <PpPage>[]) x.id,
      ...onInline,
    };
    final out = <(PpArea, List<PpPage>)>[
      if (age != null)
        (
          PpArea(
              id: kPpAgeRailId,
              title: age.$1.title,
              // On You, Maa the rail is picked for her week, not his age.
              blurb: door.aboutHer
                  ? 'Picked for you, ${_herWeeksLine()}'
                  : 'Picked for ${ChildProfileStore.instance.nameMid}, '
                      '${ChildProfileStore.instance.ageLabel}'),
          age.$2,
        ),
    ];
    for (final id in tab.areaIds) {
      for (final area in section.areas.where((a) => a.id == id)) {
        if (!area.inBand(_bandOf(tab))) continue;
        final pages = [
          for (final p in area.pagesFor(_bandOf(tab)))
            if (p.id != tab.redFlagPageId && !onAge.contains(p.id)) p,
        ];
        if (pages.isEmpty && onAge.isNotEmpty) continue;
        out.add((
          area,
          // First 40 days: her day range first (2026-10-07,
          // pp_din_by_din.dart). Every other area is untouched.
          area.id == kPpDinTabId ? ppDinOrder(pages) : pages,
        ));
      }
    }
    return out;
  }

  /// The pages a tab's inline tool draws in place (`ppDoorInlinePageIds`).
  Set<String> _inlinePageIds(PpDoorTab tab) => tab.inlineSurfaceId == null
      ? const {}
      : ppDoorInlinePageIds(tab.inlineSurfaceId!);
  // Before the age rail (H-M1), kept for revert:
  // List<(PpArea, List<PpPage>)> _bandRailsFor(PpDoorTab tab) => [
  //       for (final id in tab.areaIds)
  //         for (final area in section.areas.where((a) => a.id == id))
  //           if (area.inBand(_bandOf(tab)))
  //             (
  //               area,
  //               area.id == kPpDinTabId
  //                   ? ppDinOrder([
  //                       for (final p in area.pagesFor(_bandOf(tab)))
  //                         if (p.id != tab.redFlagPageId) p,
  //                     ])
  //                   : [
  //                       for (final p in area.pagesFor(_bandOf(tab)))
  //                         if (p.id != tab.redFlagPageId) p,
  //                     ],
  //             ),
  //     ];

  /// The offer a tab ends on: its own (`PpDoorTab.closing`), else the door's.
  PpDoorClosing? _closingOf(PpDoorTab tab) => tab.closing ?? door.closing;

  /// The second line on a tab's card. Counted, never typed — or, while the
  /// tab is locked, the age it opens.
  String _countFor(PpDoorTab tab) {
    // A tab for later says so on its card (S9). Was the lock line, kept for
    // revert: `if (_unlockMonths(tab) case final m?) return _lockLine(m);`
    if (_unlockMonths(tab) != null) return 'For later';
    // "Due in 5 days" on Vaccines when a dose is near (Health H1).
    if (tab.dueLine?.call() case final due?) return due;
    // What she sees on the tab for her band: its tools, its pages, the pages
    // from another tab, the pinned flag (Feeding plan §2c). Was every tool
    // and the flag whatever his age, kept for revert:
    // final n = tab.tools.length +
    //     _railsFor(tab).fold(0, (t, r) => t + r.$2.length) +
    //     (tab.redFlagPageId != null ? 1 : 0);
    final n = _toolsFor(tab).length +
        // An inline tool's own things: Play today's six (Development D2).
        (tab.inlineSurfaceId == null ? 0 : ppDoorInlineCount(tab.inlineSurfaceId!)) +
        _extraPagesFor(tab).length +
        _railsFor(tab).fold(0, (t, r) => t + r.$2.length) +
        (_redFlagFor(tab) != null ? 1 : 0);
    if (n == 0) return '';
    return n == 1 ? '1 thing' : '$n things';
  }

  double _railHeight(BuildContext context, List<PpDoorTab> tabs) =>
      PvDoorRail.heightOf(context, later: _withLine(tabs));

  /// The cards that carry their second line: a tab for later (S9), and a tab
  /// with something due (Health H1). The rail draws both the same way, the
  /// smaller mark over the line, which is its look for a card with a line.
  List<bool> _withLine(List<PpDoorTab> tabs) => [
        for (final t in tabs)
          _unlockMonths(t) != null || t.dueLine?.call() != null,
      ];

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
        animation: Listenable.merge([
          ChildProfileStore.instance,
          V2PaletteStore.instance,
          // A tab card's due line reads it (Health H1).
          VaxStore.instance,
          _search,
          PvSearchStore.instance,
        ]),
        builder: (context, _) => kPpDoorTtcFormat
            ? _body(context, V2PaletteStore.instance.current)
            : _bodyClassic(context, V2PaletteStore.instance.current),
      );

  // ===========================================================================
  //  The TTC door format (kPpDoorTtcFormat)
  // ===========================================================================

  /// The door's name, as the home tile says it.
  String get _doorName =>
      bracketById(door.sectionId)?.label.now ?? section.title;

  /// "For Meera · 3 to 6 months": which age the door is showing. The one
  /// thing a parenting hero says that a pregnancy hero does not.
  String? get _ageLine {
    final set = section.bandSet;
    if (set == null) return null;
    final band = set.active.label;
    // ⚠️ A BABY BORN EARLY: SAY WHICH AGE THE DOOR IS READING (Development
    // DV4). Its bands are on his corrected age, so the hero says so, or a
    // mother of a four-month-old would wonder why she sees the newborn shelf.
    final kid = ChildProfileStore.instance;
    if (set.correctedClock && kid.correctionWeeks != null) {
      final m = kid.devAgeInMonths;
      final w = kid.devAgeInWeeks.floor();
      final age = m < 1
          ? '$w ${w == 1 ? 'week' : 'weeks'}'
          : '$m ${m == 1 ? 'month' : 'months'}';
      return 'Using ${kid.their} corrected age, $age';
    }
    return door.aboutHer
        ? 'For you  ·  $band'
        : 'For ${ChildProfileStore.instance.nameMid}  ·  $band';
  }

  PvDoorGroup _groupOf(PpDoorTab t) => PvDoorGroup(
        id: t.id,
        label: t.label,
        icon: t.icon,
        hue: t.hue,
        mark: ppTabMarkFor(t.icon),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final bracket = bracketById(door.sectionId);
    final hub = hubFor(door.sectionId);
    final tabs = _tabs;
    final hue = bracket?.hue ?? tabs.first.hue;
    final tint = v2BlockTint(hue, p);
    final tab = tabs[_tab.clamp(0, tabs.length - 1)];
    final tools = _toolsFor(tab);
    final extras = _extraPagesFor(tab);
    final rails = _railsFor(tab).isNotEmpty || (tools.isEmpty && extras.isEmpty)
        ? _railsFor(tab)
        : [(PpArea(id: tab.id, title: tab.label, blurb: ''), const <PpPage>[])];
    // In her band only (Feeding plan §2d). Was, kept for revert:
    // final redFlag = tab.redFlagPageId == null
    //     ? null
    //     : section.pageById(tab.redFlagPageId!);
    final redFlag = _redFlagFor(tab);

    return PvLiveSearchScope(
      search: _search,
      child: Scaffold(
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
            controller: _scroll,
            padding: EdgeInsets.zero,
            children: [
              _QuietHero(
                scroll: _offset,
                search: _search,
                p: p,
                tint: tint,
                photo: door.heroImageUrl,
                title: _doorName,
                headline: hub?.hero.now ?? section.intro,
                ageLine: _ageLine,
                mark: bracketMarkFor(door.sectionId),
                onSubmitted: (q) {
                  final hits = ppSearch(q.trim(), sectionId: door.sectionId);
                  if (hits.isNotEmpty) {
                    openPpSearchHit(context, hits.first, query: q.trim());
                  } else if (q.trim().isNotEmpty) {
                    openPpSearch(context, query: q.trim());
                  }
                },
              ),
              PvDoorSheet(
                p: p,
                minHeight: pvLiveSearchSheetMin(context, _search),
                children: [
                  if (_search.searching)
                    ..._liveResults(context, p)
                  else if (_search.recalling &&
                      PvSearchStore.instance.recent.isNotEmpty)
                    ..._liveRecall(p)
                  else ...[
                    // ---- the rail, across the seam (the pregnancy door's) --
                    // The card grows at a large text size (S11), so the
                    // seat reads the rail's own height. Was
                    // `PvDoorRail.cardHeight` in all three places.
                    SizedBox(
                      height: _railHeight(context, tabs) - PvDoorRail.overlap,
                      child: OverflowBox(
                        alignment: Alignment.bottomCenter,
                        minHeight: _railHeight(context, tabs),
                        maxHeight: _railHeight(context, tabs),
                        child: PvDoorRail(
                          groups: [for (final t in tabs) _groupOf(t)],
                          counts: [for (final t in tabs) _countFor(t)],
                          // No lock on any card (S9): a tab for later carries
                          // "For later" as its count line instead. Kept for
                          // revert: `[for (final t in tabs) _unlockMonths(t) != null]`.
                          // A due line shows as well (Health H1).
                          later: _withLine(tabs),
                          selected: _tab,
                          p: p,
                          onPick: (i) => setState(() => _tab = i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(height: kPvDoorBlockGap),

                    // A tab for later opens (S9): one line, then its rails.
                    // The lock panel it showed instead, kept for revert:
                    // if (_unlockMonths(tab) case final m?) ...[
                    //   ppDoorPad(_LockedPanel(months: m, label: _lockLabel(m),
                    //       aboutHer: door.aboutHer, p: p)),
                    //   const SizedBox(height: kPvDoorBlockGap),
                    // ] else ...[
                    if (_unlockMonths(tab) case final m?) ...[
                      ppDoorPad(Text(_laterLine(tab, m),
                          key: const ValueKey('pp_door_later_line'),
                          style: pvManrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              color: p.ink2))),
                      const SizedBox(height: kPvDoorBlockGap),
                    ],
                    ...[
                      // Din by din: "Day N of 40" and today's line.
                      if (ppDinToday(tab.id) case final today?) ...[
                        ppDoorPad(PpDinTodayCard(day: today.day, line: today.line, p: p)),
                        const SizedBox(height: kPvDoorBlockGap),
                      ],
                      if (tab.jumpToTabId case final target?) ...[
                        ppDoorPad(_FlagRow(
                          key: const ValueKey('pp_door_jump_row'),
                          p: p,
                          title: tab.jumpTitle ?? 'Is this an emergency?',
                          line: null,
                          onTap: () => setState(() => _tab = tabs
                              .indexWhere((t) => t.id == target)
                              .clamp(0, tabs.length - 1)),
                        )),
                        const SizedBox(height: kPvDoorBlockGap),
                      ],
                      // ⚠️ FOLDED INTO ONE WHITE ROW, AS PREGNANCY'S AND TTC'S
                      // (2026-10-07). The page's own title and its first doctor
                      // line; one tap opens the whole page. Never hidden.
                      if (redFlag != null) ...[
                        ppDoorPad(_FlagRow(
                          key: const ValueKey('pp_door_flag_row'),
                          p: p,
                          title: redFlag.title,
                          // You, Maa pins its frightening-thoughts route here;
                          // the brief's words for it are "read this one
                          // first", not a red flag, and a mother in that state
                          // should meet those, with a hand, not a hospital.
                          route: redFlag.format?.toUpperCase() == 'ROUTE',
                          line: redFlag.format?.toUpperCase() == 'ROUTE'
                              ? 'Read this one first'
                              : _doctorLine(redFlag),
                          onTap: () => _openPage(context, redFlag),
                        )),
                        const SizedBox(height: kPvDoorBlockGap),
                      ],
                      // A tab's note: one quiet grey line, no tinted slab
                      // behind it (the one-ParentVeda rule).
                      if (tab.note case final note?) ...[
                        ppDoorPad(Text(note,
                            style: pvManrope(
                                fontSize: 13.5, height: 1.5, color: p.ink2))),
                        const SizedBox(height: kPvDoorBlockGap),
                      ],
                      // ⚠️ THE TAB'S TOOL, DRAWN IN PLACE (Development D2):
                      // Play today opens on six activities, not on a card
                      // that opens them. It pads itself, so it is not
                      // wrapped in ppDoorPad and its rail runs edge to edge.
                      if (tab.inlineSurfaceId case final surface?)
                        if (ppDoorInlineToolFor(surface,
                                p: p,
                                onSurface: (id) => widget.onSurface(context, id))
                            case final tool?) ...[
                          tool,
                          const SizedBox(height: kPvDoorBlockGap),
                        ],
                      for (final (ri, (area, pages)) in rails.indexed) ...[
                        ppDoorPad(Text(area.title,
                            style: pvFraunces(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                letterSpacing: -0.45,
                                color: p.ink1))),
                        // The age rail says whose it is (H2 look, v4).
                        if (area.id == kPpAgeRailId) ...[
                          const SizedBox(height: 2),
                          ppDoorPad(Text(area.blurb,
                              key: const ValueKey('pp_door_age_rail'),
                              style: pvManrope(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: p.ink3))),
                        ],
                        const SizedBox(height: kPvDoorHeadingGap),
                        // Her band's tools only (PpDoorTool.bands); the rest
                        // wait in the band blocks below. Was `tab.tools`.
                        _shelf(context, p, [
                          if (ri == 0)
                            for (final tool in tools)
                              if (!tool.atEnd &&
                                  (tool.afterPageId == null ||
                                      !pages.any((x) => x.id == tool.afterPageId)))
                                _ShelfItem.tool(tool),
                          // A page from another tab, after the tools
                          // (PpDoorTab.extraPageIds).
                          if (ri == 0)
                            for (final x in extras) _ShelfItem.page(x),
                          for (final page in [
                            ...pages.where((x) => x.pinned),
                            ...pages.where((x) => !x.pinned),
                          ]) ...[
                            _ShelfItem.page(page),
                            if (ri == 0)
                              for (final tool in tools)
                                if (tool.afterPageId == page.id)
                                  _ShelfItem.tool(tool),
                          ],
                          // A shop card comes last (PpDoorTool.atEnd).
                          if (ri == 0)
                            for (final tool in tools)
                              if (tool.atEnd) _ShelfItem.tool(tool),
                        ], area.hue),
                        const SizedBox(height: kPvDoorBlockGap),
                        // The tab's expert, on the first scroll (Feeding D2,
                        // approved 2026-10-23): the grey row after the first
                        // rail, the reader's offer card in look.
                        if (ri == 0 && tab.expert != null) ...[
                          ppDoorPad(_ExpertRow(
                            key: const ValueKey('pp_door_tab_expert'),
                            p: p,
                            expert: tab.expert!,
                            onTap: () => widget.onSurface(
                                context, tab.expert!.surfaceId),
                          )),
                          const SizedBox(height: kPvDoorBlockGap),
                        ],
                      ],
                      // The other bands (2026-10-21, Wave 4): the next one
                      // open as "Coming up next", the rest folded. A tool
                      // for another age rides in the first block it fits.
                      for (final (band, pages, dist, bandTools) in _otherBands(tab)) ...[
                        if (dist == PpBandDistance.next || _openBands.contains(band.id)) ...[
                          ppDoorPad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(dist == PpBandDistance.next ? 'Coming up next' : band.label,
                                key: ValueKey('pp_door_band_head_${band.id}'),
                                style: pvFraunces(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    letterSpacing: -0.45,
                                    color: p.ink1)),
                            if (dist == PpBandDistance.next) ...[
                              const SizedBox(height: 2),
                              Text(band.label,
                                  style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3)),
                            ],
                          ])),
                          const SizedBox(height: kPvDoorHeadingGap),
                          _shelf(context, p, [
                            for (final t in bandTools) _ShelfItem.tool(t),
                            for (final x in pages) _ShelfItem.page(x),
                          ], hue),
                          const SizedBox(height: kPvDoorBlockGap),
                        ] else ...[
                          ppDoorPad(InkWell(
                            key: ValueKey('pp_door_band_fold_${band.id}'),
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => setState(() => _openBands.add(band.id)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: p.line),
                              ),
                              child: Row(children: [
                                Expanded(
                                  child: Text(
                                      '${dist == PpBandDistance.earlier ? 'Earlier' : 'Later'}  \u00b7  ${band.label}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
                                ),
                                const SizedBox(width: 8),
                                Text('${pages.length + bandTools.length}',
                                    style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink3)),
                                Icon(Icons.expand_more_rounded, size: 20, color: p.ink3),
                              ]),
                            ),
                          )),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ],

                    if (tab.footer case final line?) ...[
                      ppDoorPad(Text(line,
                          style: pvFraunces(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: p.ink2))),
                      const SizedBox(height: kPvDoorBlockGap),
                    ],

                    // The tab's one shop card, after every free thing, its
                    // copy first (Development D6, PpDoorTab.shop).
                    if (tab.shop case final shop?) ...[
                      ppDoorPad(_ShopCard(
                        key: const ValueKey('pp_door_tab_shop'),
                        p: p,
                        shop: shop,
                        onTap: () => widget.onSurface(context, shop.surfaceId),
                      )),
                      const SizedBox(height: kPvDoorBlockGap),
                    ],

                    // The closing: one line with an ink link, or the consult
                    // card as a shelf card of its own.
                    if (door.closingLine case final line?) ...[
                      ppDoorPad(InkWell(
                        onTap: door.closing == null
                            ? null
                            : () => widget.onSurface(
                                context, door.closing!.surfaceId),
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
                                        // One ink (was p.action, violet).
                                        color: p.ink1)),
                            ]),
                            style: pvFraunces(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                color: p.ink2),
                          ),
                        ),
                      )),
                      const SizedBox(height: kPvDoorBlockGap),
                    ] else if (_closingOf(tab) case final closing?
                        when tab.expert == null) ...[
                      // The tab's own closing where it has one (Health H3:
                      // Get help now ends on the first-aid class, never a
                      // consult). Was `door.closing` below, kept for revert.
                      // Was `door.closing case final c?`: a tab with its own
                      // expert row (Feeding D2) ends on the sentence below,
                      // as the approved mockup does, so one tab never pitches
                      // twice.
                      // ⚠️ THE CONSULT CARD IS BACK (step 0 · S3, approved
                      // 2026-10-23, after Wave 2 took it out on 2026-10-21):
                      // help sits next to the worry, and the door's own
                      // closing names the right person ("Talk to a sleep
                      // expert") instead of every door saying the same doctor
                      // sentence. Each door's plan places a second one early
                      // on its help tab. With no expert live yet the tap opens
                      // "Our first experts are joining" (S8), never nothing.
                      ppDoorPad(PpDoorRow(
                        key: const ValueKey('pp_door_closing_card'),
                        p: p,
                        hue: hue,
                        icon: closing.surfaceId.startsWith('pp_class/')
                            ? Icons.school_outlined
                            : Icons.chat_bubble_outline_rounded,
                        chip: closing.surfaceId.startsWith('pp_class/')
                            ? 'Class'
                            : 'Consult',
                        title: closing.label,
                        blurb: closing.blurb,
                        onTap: () =>
                            widget.onSurface(context, closing.surfaceId),
                      )),
                      const SizedBox(height: kPvDoorBlockGap),
                    ] else ...[
                      // A door with no closing (First 40, Traditions, Papers)
                      // ends on a sentence, as the pregnancy and TTC doors
                      // do. The Wave 2 note (2026-10-21: every door "ends in
                      // an old Talk to an expert row") and the card it
                      // replaced, kept for revert:
                      // ] else if (door.closing case final c?) ...[
                      //   ppDoorPad(PpDoorRow(
                      //     p: p,
                      //     hue: hue,
                      //     icon: Icons.chat_bubble_outline_rounded,
                      //     chip: 'Consult',
                      //     title: c.label,
                      //     blurb: c.blurb,
                      //     onTap: () => widget.onSurface(context, c.surfaceId),
                      //   )),
                      //   const SizedBox(height: kPvDoorBlockGap),
                      ppDoorPad(Text(
                          key: const ValueKey('pp_door_closing_line'),
                          kPpDoorClosingLine,
                          style: pvFraunces(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: p.ink2))),
                      const SizedBox(height: kPvDoorBlockGap),
                    ],
                    ppDoorPad(PpDoorDisclaimer(p: p, text: door.disclaimer)),
                  ],
                ],
              ),
            ],
          ),
          // ---- the pinned bar: compact once the hero goes, the field on a
          // solid band while she searches (2026-10-10). --------------------
          PvDoorPinnedBar(
            controller: _scroll,
            search: _search,
            p: p,
            title: _doorName,
          ),
        ]),
      ),
    );
  }

  /// The first doctor line of a page, its own words: the flag row's second
  /// line, so the row and the page cannot disagree.
  String? _doctorLine(PpPage page) => page.blocks
      .whereType<PpCallout>()
      .where((c) => c.kind == PpCalloutKind.doctor)
      .map((c) => c.text)
      .firstOrNull;

  /// One shelf: a rail of `PvShelfCard`s at TTC's numbers.
  Widget _shelf(BuildContext context, V2Palette p, List<_ShelfItem> items, double hue) {
    if (items.isEmpty) return const SizedBox.shrink();
    final sit = PpSituation.now();
    return SizedBox(
      height: pvShelfRailHeight(MediaQuery.textScalerOf(context)),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final it = items[i];
          final spec = it.page != null ? ppShelfSpecFor(it.page!) : ppShelfSpecForTool();
          final why = it.page == null ? null : ppRelevanceWhy(sit, it.page!.title);
          return PvShelfCard(
            p: p,
            hue: (hue + i * 22) % 360,
            kind: spec.kind,
            kindWord: spec.word,
            fact: why ?? spec.fact,
            title: it.title,
            comingSoon: it.page?.comingSoon ?? false,
            onTap: () => it.page != null
                ? _openPage(context, it.page!)
                : widget.onSurface(context, it.tool!.surfaceId),
          );
        },
      ),
    );
  }

  // ---- the live field's two states (the pregnancy door's, on this index) ----

  List<Widget> _liveResults(BuildContext context, V2Palette p) {
    final q = _search.query;
    final hits = ppSearch(q, sectionId: door.sectionId);
    final mine = [for (final h in hits) if (h.sectionId == door.sectionId) h];
    final label = _doorName;
    return [
      const SizedBox(height: 22),
      ppDoorPad(Text(
        mine.isEmpty ? 'Nothing in $label by that name' : 'In $label',
        style: pvFraunces(
            fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1),
      )),
      const SizedBox(height: 6),
      for (var i = 0; i < mine.length && i < 30; i++)
        PpSearchHitRow(
          key: ppSearchHitKey(i),
          p: p,
          hit: mine[i],
          onTap: () {
            _search.focus.unfocus();
            openPpSearchHit(context, mine[i], query: q);
          },
        ),
      const SizedBox(height: 14),
      ppDoorPad(PvLiveSearchWayOn(
        p: p,
        icon: Icons.travel_explore_outlined,
        title: 'Search everywhere for "$q"',
        line: 'Every door of ParentVeda, not just $label.',
        onTap: () {
          pvCommitFeedback();
          _search.focus.unfocus();
          openPpSearch(context, query: q);
        },
      )),
      const SizedBox(height: 10),
      ppDoorPad(PvLiveSearchWayOn(
        p: p,
        mark: const AskVedaMark(size: 20), // was icon: Icons.auto_awesome_outlined (Ask Veda mark, 2026-10-24)
        title: 'Ask Veda about "$q"',
        line: 'In your own words, with your child\'s age in mind.',
        onTap: () {
          pvCommitFeedback();
          _search.focus.unfocus();
          openPpAskVeda(context, q);
        },
      )),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _liveRecall(V2Palette p) => [
        const SizedBox(height: 22),
        pvLiveSearchRecallHeading(p, 'Recent', onClear: PvSearchStore.instance.clear),
        const SizedBox(height: 6),
        for (final r in PvSearchStore.instance.recent)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
            leading: Icon(Icons.history_rounded, color: p.ink3),
            title: Text(r, style: pvManrope(fontSize: 15, color: p.ink1)),
            onTap: () => _search.run(r),
          ),
      ];

  /// The 2026-09 door, kept for revert (`kPpDoorTtcFormat = false`).
  Widget _bodyClassic(BuildContext context, V2Palette p) {
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

// =============================================================================
//  The TTC door format's pieces, typed on parenting
// =============================================================================

/// What a parenting card says it is: one of the shared kinds, an honest word
/// where the shared word would mislead, and one fact.
///
/// ⚠️ A "VIDEO" PAGE IS AN ARTICLE UNTIL ITS FILM EXISTS (gap analysis P1,
/// Behind · Videos & audio: "A 'Video' chip on a page with no video is a small
/// untruth on 21 pages, and on choking it is a safety gap"). Not one parenting
/// video slot has a file yet, so every VIDEO page is an Article with its
/// reading time. When films land, a page with a playable film says Video.
({PvShelfKind kind, String? word, String? fact}) ppShelfSpecFor(PpPage page) {
  final f = (page.format ?? 'ARTICLE').toUpperCase();
  final read = ppReadMinutes(page);
  final minutes = '$read min read';
  if (page.toolSurfaceId != null || f == 'TOOL' || f == 'INTERACTIVE' || f == 'CHECKLIST') {
    return (kind: PvShelfKind.tool, word: null, fact: null);
  }
  return switch (f) {
    'RECIPE' => (kind: PvShelfKind.recipe, word: null, fact: null),
    'AUDIO LIBRARY' || 'AUDIO' => (kind: PvShelfKind.audio, word: null, fact: null),
    'CONSULT' || 'TALK' => (kind: PvShelfKind.talk, word: null, fact: null),
    'ACTIVITY' => (kind: PvShelfKind.game, word: 'Activity', fact: null),
    'STORY' => (kind: PvShelfKind.read, word: 'Story', fact: '$read min'),
    'CHART' || 'CHART-CARD' || 'TABLE' || 'COMPARISON TABLE' =>
      (kind: PvShelfKind.read, word: 'Chart', fact: null),
    'CEREMONY' => (kind: PvShelfKind.read, word: 'Ceremony', fact: minutes),
    _ => (kind: PvShelfKind.read, word: null, fact: minutes),
  };
}

/// A page that leads its rail even once read (step 0 · S10): a red-flag list,
/// or a page the door pins.
/// The id of the age rail's synthetic area (`PpDoorTab.ageRail`). No section
/// area may use it.
const String kPpAgeRailId = 'pp_door_age_rail';

bool ppIsRedFlagPage(PpPage page) {
  final f = (page.format ?? '').toUpperCase();
  return f == 'RED FLAG' || f == 'FLAGGED' || page.pinned;
}

({PvShelfKind kind, String? word, String? fact}) ppShelfSpecForTool() =>
    (kind: PvShelfKind.tool, word: null, fact: null);

/// Reading time at 200 words a minute, never under one.
int ppReadMinutes(PpPage page) {
  var words = 0;
  for (final b in page.blocks) {
    final t = switch (b) {
      PpIntro x => x.text,
      PpArticle x => [x.heading ?? '', ...x.paragraphs].join(' '),
      PpSteps x => [for (final st in x.steps) '${st.title} ${st.detail}'].join(' '),
      PpCards x => [for (final c in x.cards) '${c.title} ${c.line}'].join(' '),
      PpCallout x => x.text,
      _ => '',
    };
    words += t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }
  return (words / 200).ceil().clamp(1, 60);
}

/// A tab's line icon, as the drawn mark the shared rail draws (the TTC family's
/// object where one exists, else the hub mark). Line icons are for controls;
/// a row that goes somewhere wears a drawn mark (the three-level icon rule).
IntentMark ppTabMarkFor(IconData icon) {
  final c = icon.codePoint;
  bool any(List<IconData> xs) => xs.any((x) => x.codePoint == c);
  if (any([Icons.nightlight_outlined, Icons.nights_stay_outlined, Icons.dark_mode_outlined, Icons.bedtime_outlined])) {
    return IntentMark.moonMark;
  }
  if (any([Icons.favorite_border_rounded, Icons.groups_outlined, Icons.diversity_2_outlined])) return IntentMark.cuppedHands;
  if (any([Icons.water_drop_outlined])) return IntentMark.feedMark;
  if (any([Icons.toys_outlined])) return IntentMark.playMark;
  if (any([Icons.spa_outlined, Icons.self_improvement_outlined])) return IntentMark.lotusMark;
  if (any([Icons.show_chart_outlined])) return IntentMark.chartLog;
  if (any([Icons.shield_outlined])) return IntentMark.checkMark;
  if (any([Icons.restaurant_outlined])) return IntentMark.plate;
  if (any([Icons.soup_kitchen_outlined])) return IntentMark.cookMark;
  if (any([Icons.emergency_outlined, Icons.forum_outlined, Icons.chat_bubble_outline_rounded])) return IntentMark.askDoctor;
  if (any([Icons.work_outline_rounded])) return IntentMark.compassMark;
  if (any([Icons.whatshot_outlined, Icons.thermostat_outlined, Icons.child_care_outlined])) return IntentMark.bodyMark;
  if (any([Icons.wb_sunny_outlined])) return IntentMark.sunMark;
  if (any([Icons.vaccines_outlined, Icons.medication_outlined])) return IntentMark.pillMark;
  if (any([Icons.undo_rounded])) return IntentMark.improveMark;
  if (any([Icons.timelapse_outlined])) return IntentMark.timelineRail;
  if (any([Icons.stairs_outlined, Icons.directions_walk_outlined])) return IntentMark.stepsMark;
  if (any([Icons.school_outlined])) return IntentMark.schoolMark;
  if (any([Icons.repeat_rounded])) return IntentMark.cycleRing;
  if (any([Icons.music_note_outlined])) return IntentMark.audioMark;
  if (any([Icons.home_outlined, Icons.auto_awesome_outlined])) return IntentMark.lampMark;
  if (any([Icons.gesture_rounded])) return IntentMark.moodArc;
  if (any([Icons.folder_open_outlined])) return IntentMark.reportPage;
  if (any([Icons.event_outlined, Icons.calendar_today_outlined, Icons.cake_outlined])) return IntentMark.calendarDay;
  if (any([Icons.checklist_rtl_outlined])) return IntentMark.listMark;
  if (any([Icons.auto_stories_outlined])) return IntentMark.bookMark;
  // The four doors added 2026-10-07 (safety, papers, special care, family).
  if (any([Icons.directions_car_outlined])) return IntentMark.seatMark;
  if (any([Icons.medical_services_outlined])) return IntentMark.askDoctor;
  if (any([Icons.badge_outlined])) return IntentMark.reportPage;
  if (any([Icons.account_balance_outlined])) return IntentMark.listMark;
  if (any([Icons.health_and_safety_outlined])) return IntentMark.checkMark;
  if (any([Icons.savings_outlined])) return IntentMark.improveMark;
  if (any([Icons.event_note_outlined])) return IntentMark.calendarDay;
  if (any([Icons.looks_two_outlined])) return IntentMark.compareMark;
  if (any([Icons.psychology_outlined])) return IntentMark.moodArc;
  if (any([Icons.support_outlined, Icons.elderly_outlined, Icons.people_outline])) return IntentMark.cuppedHands;
  if (any([Icons.child_friendly_outlined])) return IntentMark.feedMark;
  if (any([Icons.man_outlined])) return IntentMark.stepsMark;
  if (any([Icons.work_outline])) return IntentMark.compassMark;
  return IntentMark.pageMark;
}

/// A tab's expert (`PpDoorTab.expert`, Feeding D2): the reader's grey offer
/// card in look (`PvReadOfferCard`), so the consult on the door and the one
/// in the page read as the same calm thing. No price: what an expert costs is
/// decided server-side, and none is live yet.
class _ExpertRow extends StatelessWidget {
  const _ExpertRow({
    super.key,
    required this.p,
    required this.expert,
    required this.onTap,
  });
  final V2Palette p;
  final PpDoorClosing expert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFFF3F3F4),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(expert.blurb,
                          style: pvManrope(
                              fontSize: 12.5, height: 1.35, color: p.ink3)),
                      const SizedBox(height: 3),
                      Text(expert.label,
                          style: pvManrope(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                              color: p.ink1)),
                      if (expert.note case final note?) ...[
                        const SizedBox(height: 3),
                        Text(note,
                            style: pvManrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                                color: p.ink3)),
                      ],
                    ]),
              ),
              Icon(Icons.chevron_right_rounded, color: p.ink1),
            ]),
          ),
        ),
      );
}

/// A tab's shop card (`PpDoorTab.shop`): the copy, then the label. An
/// outlined aside, never the grey offer card, so it does not read as a
/// second consult.
class _ShopCard extends StatelessWidget {
  const _ShopCard({
    super.key,
    required this.p,
    required this.shop,
    required this.onTap,
  });
  final V2Palette p;
  final PpDoorClosing shop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.blurb,
                      style: pvManrope(
                          fontSize: 13.5, height: 1.45, color: p.ink2)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.card_giftcard_outlined, size: 18, color: p.ink1),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(shop.label,
                          style: pvManrope(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: p.ink1)),
                    ),
                    Icon(Icons.chevron_right_rounded, color: p.ink1),
                  ]),
                ]),
          ),
        ),
      );
}

class _ShelfItem {
  // A page card shows why the brain moved it ("On formula") in place of its
  // usual fact line, from pp_relevance.dart (2026-10-21).
  _ShelfItem.page(PpPage p)
      : page = p,
        tool = null;
  _ShelfItem.tool(PpDoorTool t)
      : tool = t,
        page = null;
  final PpPage? page;
  final PpDoorTool? tool;
  String get title => page?.title ?? tool!.label;
}

/// The pinned red flag (or a jump to the emergency tab), folded into one white
/// row: the pregnancy door's `_PinnedRedFlagRow`, a hospital mark with a red
/// dot, the title, one line of the page's own words, a chevron.
class _FlagRow extends StatelessWidget {
  const _FlagRow({
    super.key,
    required this.p,
    required this.title,
    required this.line,
    required this.onTap,
    this.route = false,
  });
  final V2Palette p;
  final String title;
  final String? line;
  final VoidCallback onTap;

  /// A route to read first (You, Maa), not a red flag: a hand, no red dot.
  final bool route;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: '$title. ${line ?? 'Open'}',
        excludeSemantics: true,
        child: PvPress(
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: p.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                pvCommitFeedback();
                onTap();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Row(children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: Stack(clipBehavior: Clip.none, children: [
                      Icon(route ? Icons.volunteer_activism_outlined : Icons.local_hospital_outlined,
                          size: 22, color: p.ink1),
                      if (!route) Positioned(
                        right: -1,
                        top: -1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5484D),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 14, fontWeight: FontWeight.w700, height: 1.3, color: p.ink1)),
                        if (line != null && line!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(line!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(fontSize: 12.5, color: p.ink2)),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20, color: p.ink2),
                ]),
              ),
            ),
          ),
        ),
      );
}

/// The quiet hero: the pregnancy door's `_Hero._quiet`, on a parenting door,
/// plus the age line. One height on every door (`kPvDoorHeroQuietHeight`).
class _QuietHero extends StatelessWidget {
  const _QuietHero({
    required this.scroll,
    required this.search,
    required this.p,
    required this.tint,
    required this.title,
    required this.headline,
    required this.onSubmitted,
    this.photo,
    this.ageLine,
    this.mark,
  });

  final ValueListenable<double> scroll;
  final PvLiveSearch search;
  final V2Palette p;
  final Color tint;
  final String title;
  final String headline;
  final ValueChanged<String> onSubmitted;
  final String? photo;
  final String? ageLine;
  final BracketMark? mark;

  static const double _kRate = 0.45;
  static const double _kFade = 200;
  static const double _kTopRoom = 58;
  static const double _bleed = kPpDoorHeroOverlap + PvDoorRail.overlap;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    const shadow = [Shadow(color: Color(0x59000000), blurRadius: 12)];
    final onPhoto = photo != null;

    final words = PvLiveSearchWords(
      search: search,
      child: ValueListenableBuilder<double>(
        valueListenable: scroll,
        builder: (context, o, child) =>
            Opacity(opacity: (1 - o / _kFade).clamp(0.0, 1.0), child: child),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                key: const ValueKey('pp_door_hero_title'),
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
              child: Text(headline,
                  // With the age line under it, the headline keeps one line,
                  // so the words are the pregnancy door's height and the hero
                  // is its 262, not taller (2026-10-21, Wave 2; the user saw
                  // the two door heroes differ). Was always 2.
                  maxLines: ageLine == null ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                    fontSize: 14.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: onPhoto ? Colors.white.withValues(alpha: 0.95) : p.ink2,
                  ).copyWith(shadows: onPhoto ? shadow : null)),
            ),
            if (ageLine != null) ...[
              const SizedBox(height: 6),
              Text(ageLine!,
                  key: const ValueKey('pp_door_age_line'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: onPhoto ? Colors.white : p.ink1,
                  ).copyWith(shadows: onPhoto ? shadow : null)),
            ],
            const SizedBox(height: 14),
            // GLOBAL-CHANGES #5: the door's intro video, "Coming soon" until
            // its film exists (the user, 2026-10-25: "all stages").
            PvDoorIntroChip(p: p, onPhoto: onPhoto),
          ],
        ),
      ),
    );

    final field = PvLiveSearchField(
      key: const ValueKey('pp_door_search'),
      search: search,
      p: p,
      hint: 'Search $title',
      onSubmitted: onSubmitted,
    );

    return Stack(clipBehavior: Clip.none, children: [
      if (photo != null)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -_bleed,
          child: ValueListenableBuilder<double>(
            valueListenable: scroll,
            builder: (context, o, child) => Transform.translate(
              offset: Offset(0, (o * _kRate).clamp(0.0, double.infinity)),
              child: child,
            ),
            child: Stack(fit: StackFit.expand, children: [
              Image.network(
                photo!,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const SizedBox.shrink(),
              ),
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
        ),
      if (photo == null)
        Positioned(
          right: -26,
          top: 52,
          child: Opacity(
            opacity: 0.5,
            child: SizedBox(
              width: 146,
              height: 146,
              child: mark == null ? const SizedBox.shrink() : V3BracketArt(mark: mark!, tint: tint),
            ),
          ),
        ),
      Padding(
        padding: EdgeInsets.only(top: top),
        child: Stack(alignment: Alignment.bottomLeft, children: [
          const SizedBox(height: kPvDoorHeroQuietHeight, width: double.infinity),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, _kTopRoom, 22, 20 + PvDoorRail.overlap - 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [words, const SizedBox(height: 18), field],
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
            key: const ValueKey('pp_door_back'),
            onTap: () => Navigator.of(context).maybePop(),
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
