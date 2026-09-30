// =============================================================================
//  TTC — the Learn tab: every read, film, myth and course the stage has
// -----------------------------------------------------------------------------
//  Built 2026-09-26 when the V3 bar became Today · Learn · Products · Tools ·
//  You. Before this there was no library at all: four reads on a home rail
//  with no "see all", and everything else only inside the seven doors. A
//  woman who remembered reading something about AMH had nowhere to look.
//
//  The shape is Flo's "How to get pregnant" hub, which the Mobbin research
//  (scratchpad research_mobbin_tabs.md §1) found to be the strongest single
//  Learn reference, adapted to our base UI (white ground, ink, colour only in
//  wells):
//
//    search              Flo Insights' search pill; empty = recent + popular
//    browse by topic     Flo's row of big topic entries, one per door
//    your reading        Blinkist's "In progress" + saved (never a count)
//    start here          Flo's step rail, as a short ordered list
//    films               Clue's shelves with a play glyph and minutes
//    by topic            the doors' reads as shelves, with the door's own tabs
//                        as chips (the library mirrors the doors, it does not
//                        invent a second taxonomy)
//    myths and stories   the myth and story cards from every door
//    courses             the stage's programmes, "See all" to the catalogue
//    common questions    Flo's accordion, answered from the reads' own FAQs
//
//  ⚠️ EVERYTHING HERE IS DERIVED, NOTHING IS LISTED BY HAND. Shelves come from
//  `kTtcReads` grouped by the read's own kicker (its door label), the tab chips
//  from `kTtcFocusPages`, films from `kTtcVideos`. A read added to any bracket
//  file appears here with no change to this file, and a read whose kicker
//  matches no door still gets a shelf of its own. `test/ttc_tabs_v3_test.dart`
//  asserts every read in `kTtcReads` is on a shelf.
//
//  ⚠️ ONE READER. Every read opens through the `ttc_read/<id>` surface, which
//  builds `PvReaderScreen` (CLAUDE.md "One reader"). Myths and stories open
//  through `openTtcFocusTile`, exactly as they do inside a door.
//
//  ⚠️ NO COUNTERS. "Pick up where you left off" is a reading position, not
//  progress towards anything; a finished read gets a small tick in Start here
//  and nothing adds them up.
//
//  ⚠️ THE REVIEW PASS, 2026-09-26 (reviewer MR, scratchpad mobbin_review.md
//  §2a). What changed, and why each one:
//    L1  the lists are UNBOXED. `_ListCard` drew the door's read row inside a
//        white rounded box, so one object had two looks in one stage, and
//        DESIGN-SYSTEM §4.13 "Lists are not boxed" already forbade the box.
//        Every list is now `PvRowGroup` + `PvListRow` (pv_list_row.dart), the
//        same row Tools and the store's shop-by-need use. Mobbin: Flo "What
//        causes irregular cycles" (FLO-LIST,
//        https://mobbin.com/screens/3bb65ebc-bb08-4479-b449-3df67ac53fd3).
//    L2  a read with no photo shows the drawn page mark in its door's tint,
//        not `Icons.article_outlined`, exactly as the door rows do.
//    L3  topic tiles draw the door's own bracket mark (`V3BracketArt`), the
//        mark the home grid uses. Mobbin: Flo Insights' row of drawn topic
//        marks (FLO-INSIGHTS,
//        https://mobbin.com/screens/3fba06c7-b554-46cd-9487-ae5e74721a32).
//    L4  topics come from EVERY door (`kTtcBrackets`), not from the shelves.
//        "Taking a while" writes no reads of its own, so it had no shelf and
//        therefore no tile: one door of nine was unreachable from here.
//    L5  films: two placeholders at most, not tappable, each saying what it
//        will be for (§4.7). The bespoke film sheet was a fourth leaf format
//        (§4.0 addendum 3) and is kept below for revert, unreached. The
//        reads those films point to are listed as ordinary rows.
//    L6  every row, step, recall row and question presses (`PvPress`).
//    L7  no count on the Saved button (§4.9: badges are for a clinician, an
//        appointment or a partner; the header already said "never a count").
//    L8  ONE MATCHER. Search runs `ttcDoorSearch` over every door's own index
//        (`ttcLibraryIndex`), word-prefix, the doors' rule. "IUI" typed here
//        and in a door now finds the same things, and tools, films and myths
//        on the doors are findable from the library too.
//    L9  eyebrows 11 / w800 / 1.4 (§4.2). L10 the gutter is the stage's 18.
//    L11 the story card's title is the Manrope card title (one card language).
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/reads/read_images.dart' show readImageFor, pvFilmStillFor;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/brackets/ttc_brackets.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../models/pv_read.dart';
import '../../models/pv_video_slot.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_read_store.dart';
import '../../services/saved_store.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_content_prefs.dart';
import '../../ttc/ttc_focus_data.dart';
import '../../ttc/ttc_home_prefs.dart';
import '../../ttc/ttc_reads_data.dart';
import '../../ttc/ttc_videos_data.dart';
import '../../widgets/global_ask_fab.dart' show kAskVedaRoute;
import '../../widgets/pv_feedback.dart';
import '../../widgets/pv_nav_bar.dart' show pvNavClearance;
import '../../widgets/pv_placeholders.dart' show PvVideoPlaceholder;
import '../brackets/hub/hub_intent_art.dart';
import '../doors/pv_list_row.dart';
import '../doors/pv_live_search.dart';
import '../learn/pv_learn_catalog.dart';
import '../learn/pv_offering_screen.dart' show pvOpenOffering;
import '../products/pv_store_chrome.dart'
    show PvRoundIcon, PvSectionHead, PvChip, kPvLine, pvStorePalette;
import '../saved_screen.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart';
import 'doors/ttc_door_screen.dart' show ttcDoorVisiblePage;
import 'doors/ttc_door_search.dart';
import 'ttc_askveda_screen.dart';
import 'ttc_common.dart' show TtcBottomNav, ttcTitleInk;
import 'ttc_focus_screen.dart' show openTtcFocusTile;
import 'ttc_prepare_screen.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart' show openTtcSurface, kTtcReadPrefix;
import 'ttc_tab_root_header.dart';

/// The Learn tab's route. `ttcV3ActiveFor` lights tab 1 for it.
const String kTtcLearnRoute = 'ttc/learn';

// =============================================================================
//  The data: every shelf derived, so a new read cannot be missed
// =============================================================================

/// One door's reads, with the door's own tabs as filters.
class TtcLearnShelf {
  const TtcLearnShelf({
    required this.key,
    required this.reads,
    this.bracket,
    this.tabs = const [],
  });

  /// The kicker the reads share. The identity, compared, never shown alone.
  final String key;

  /// The door the kicker names, or null for a kicker no door carries.
  final Bracket? bracket;
  final List<PvRead> reads;

  /// The door's tabs that hold at least one of these reads.
  final List<TtcLearnTab> tabs;

  String get label => bracket?.label.en ?? key;

  /// ⚠️ THE DOOR'S OWN NAME (launch sanity L2, 2026-09-28). The shelf used
  /// the bracket's long title ("Conceiving & the fertile window", "PCOS &
  /// hormonal blocks", "Infertility & IVF"), so she could not tell a shelf
  /// and its door were one place, and "Infertility" appeared nowhere else.
  /// Kept for revert: bracket?.title.en ?? key.
  String get title => bracket?.label.en ?? key;
  double get hue => bracket?.hue ?? 268;
}

class TtcLearnTab {
  const TtcLearnTab(
      {required this.id, required this.label, required this.readIds});
  final String id;
  final String label;
  final Set<String> readIds;
}

/// A read id carried by a door tile, or null.
String? _readIdOf(TtcTile tile) => switch (tile) {
      TtcArticleTile(:final readId) => readId,
      TtcGuideTile(:final readId) => readId,
      _ => null,
    };

/// Every read in `kTtcReads`, grouped by door, in the doors' own order.
///
/// ⚠️ GROUPED BY THE READ'S KICKER, which is its door's label ("PCOS",
/// "Getting ready"). That is a field every read already carries, so a new
/// bracket file needs nothing here; a kicker no door carries still gets a
/// shelf, after the doors.
List<TtcLearnShelf> ttcLearnShelves() {
  final byKicker = <String, List<PvRead>>{};
  for (final r in kTtcReads) {
    byKicker.putIfAbsent(r.kicker.en, () => []).add(r);
  }
  final out = <TtcLearnShelf>[];
  final used = <String>{};
  for (final b in kTtcBrackets) {
    final reads = byKicker[b.label.en];
    if (reads == null || reads.isEmpty) continue;
    used.add(b.label.en);
    final ids = {for (final r in reads) r.id};
    final tabs = <TtcLearnTab>[];
    final page = ttcFocusPageFor(b.id);
    for (final g in page?.groups ?? const <TtcFocusGroup>[]) {
      final inTab = <String>{
        for (final s in page!.sections)
          if (s.group == g.id)
            for (final t in s.tiles)
              if (_readIdOf(t) case final id? when ids.contains(id)) id,
      };
      if (inTab.isNotEmpty) {
        tabs.add(TtcLearnTab(id: g.id, label: g.label, readIds: inTab));
      }
    }
    out.add(TtcLearnShelf(key: b.label.en, bracket: b, reads: reads, tabs: tabs));
  }
  for (final e in byKicker.entries) {
    if (used.contains(e.key)) continue;
    out.add(TtcLearnShelf(key: e.key, reads: e.value));
  }
  return out;
}

/// "Start here": a short path through the basics, in reading order. Ids that
/// no longer resolve are skipped rather than shown as a dead row.
///
/// ⚠️ IT IS "TRYING TO CONCEIVE 101" SINCE 2026-09-26: the gap analysis's free
/// seven-step course ("Behind: Learning shapes", P1), in its order, built from
/// reads we already have. One list, `kTtc101ReadIds`, so the home's "New
/// here?" card and this section cannot drift apart. The first five-read path,
/// kept for revert:
///   'ttc_read_how_conception_works', 'ttc_read_three_months_before',
///   'ttc_read_folic_acid', 'ttc_read_timing_myths', 'ttc_read_stress_fertility',
const List<String> kTtcLearnStartIds = kTtc101ReadIds;

List<PvRead> ttcLearnStartHere() =>
    [for (final id in kTtcLearnStartIds) ?ttcReadById(id)];

/// Whether a read is listed while she has asked to hide intimacy content.
/// Timing reads are never in the set; see `ttc_content_prefs.dart`.
bool ttcLearnShows(PvRead r) => !(TtcContentPrefs.instance.hideIntimate &&
    kTtcIntimateReadIds.contains(r.id));

/// Common questions, pulled from the reads' own FAQs: the first of each read,
/// Start here first, so the answers are ones a doctor-reviewed read already
/// gives. Never written here.
List<(PvReadFaq, PvRead)> ttcLearnFaqs({int max = 8}) {
  final order = [
    ...ttcLearnStartHere(),
    for (final r in kTtcReads)
      if (!kTtcLearnStartIds.contains(r.id)) r,
  ];
  final out = <(PvReadFaq, PvRead)>[];
  final seen = <String>{};
  for (final r in order) {
    if (r.faqs.isEmpty) continue;
    final f = r.faqs.first;
    if (!seen.add(f.question.en)) continue;
    out.add((f, r));
    if (out.length >= max) break;
  }
  return out;
}

/// Myths and stories from every door, each with its door's hue, once.
List<(TtcTile, double)> ttcLearnStories() {
  final out = <(TtcTile, double)>[];
  final seen = <String>{};
  for (final page in kTtcFocusPages) {
    final hue = _bracketById(page.bracketId)?.hue ?? 268;
    for (final t in page.allTiles) {
      if (t is! TtcMythTile && t is! TtcCarouselTile) continue;
      if (!seen.add(t.title)) continue;
      out.add((t, hue));
    }
  }
  return out;
}

Bracket? _bracketById(String id) {
  for (final b in kTtcBrackets) {
    if (b.id == id) return b;
  }
  return null;
}

/// The drawn mark of the door a read belongs to, or null (2026-09-27).
BracketMark? _doorMarkOf(PvRead r) {
  for (final b in kTtcBrackets) {
    if (b.label.en == r.kicker.en) return bracketMarkFor(b.id);
  }
  return null;
}

/// The door hue for a read, so its row and its reader share one colour.
double _hueOfRead(PvRead r) {
  for (final b in kTtcBrackets) {
    if (b.label.en == r.kicker.en) return b.hue;
  }
  return r.hue;
}

// Kept for revert (L3, 2026-09-26): the Material glyph each door used to wear
// in Learn. The door's own drawn mark (`bracketMarkFor`) replaced it, and the
// two doors added the same day were missing from this switch altogether.
//   IconData _doorIcon(String? bracketId) => switch (bracketId) {
//         'ttc_conceiving' => Icons.favorite_outline_rounded,
//         'ttc_pcos' => Icons.bubble_chart_outlined,
//         'ttc_infertility' => Icons.biotech_outlined,
//         'ttc_preconception_health' => Icons.eco_outlined,
//         'ttc_male_fertility' => Icons.male_rounded,
//         'ttc_after_loss' => Icons.spa_outlined,
//         'ttc_mind_body' => Icons.self_improvement_outlined,
//         _ => Icons.menu_book_outlined,
//       };

/// One topic tile: a door, and how many pieces to read it holds.
class TtcLearnTopic {
  const TtcLearnTopic({required this.bracket, required this.reads});
  final Bracket bracket;

  /// Distinct reads on the door's own tiles, after her content choice.
  final int reads;
}

/// Every door in the stage, in the doors' own order (L4).
///
/// ⚠️ FROM `kTtcBrackets`, NOT FROM THE SHELVES. A shelf exists only for a
/// door whose label some read carries as its kicker, and "Taking a while"
/// gathers other doors' reads without writing any, so building topics from
/// shelves left it with no tile. The count comes from the door's own tiles,
/// filtered the way the door itself filters them.
///
/// ⚠️ HIS SIDE (2026-09-27): viewed as him, his own door and Mind and body
/// lead, then hers in their order. The library itself is the same for both,
/// as Flo for Partners gives him the pieces about her body too.
const List<String> kTtcHisLearnFirst = ['ttc_male_fertility', 'ttc_mind_body'];

List<TtcLearnTopic> ttcLearnTopics({bool? hideIntimate, bool? him}) {
  final hide = hideIntimate ?? TtcContentPrefs.instance.hideIntimate;
  final forHim = him ?? TtcPartnerMode.instance.on;
  final brackets = !forHim
      ? kTtcBrackets
      : [
          for (final id in kTtcHisLearnFirst) ?_bracketById(id),
          for (final b in kTtcBrackets)
            if (!kTtcHisLearnFirst.contains(b.id)) b,
        ];
  return [
    for (final b in brackets)
      if (ttcFocusPageFor(b.id) case final page?)
        TtcLearnTopic(
          bracket: b,
          reads: {
            for (final s in ttcDoorVisiblePage(page, hideIntimate: hide).sections)
              for (final t in s.tiles) ?_readIdOf(t),
          }.length,
        ),
  ];
}

/// The whole library as one search index, with each hit's hue (L8).
///
/// ⚠️ THE DOORS' INDEX AND THE DOORS' MATCHER, NOT A SECOND ENGINE. Every
/// door's own tiles first (so a tool, a film or a myth on a door is findable
/// from here as well), then every read under its OWN title. The second half
/// matters: a door tile often names a read in the door's words ("How it all
/// works"), and the library must still find the read by the title the reader
/// shows. A read found both ways is listed once (`ttcLibrarySearch`). Built by
/// `ttcDoorSearchIndex`, which already leaves out what "Hide sex and intimacy
/// content" hides, so typing a word cannot bring a hidden piece back.
List<(TtcDoorHit, double)> ttcLibraryIndex({
  AppLanguage? lang,
  bool? hideIntimate,
}) {
  final l = lang ??
      (TtcLang.instance.hinglish ? AppLanguage.hinglish : AppLanguage.english);
  final hide = hideIntimate ?? TtcContentPrefs.instance.hideIntimate;
  final out = <(TtcDoorHit, double)>[];
  final library = <String, TtcDoorHit>{};
  final seenTiles = <String>{};
  for (final page in kTtcFocusPages) {
    final b = _bracketById(page.bracketId);
    if (b == null) continue;
    for (final h in ttcDoorSearchIndex(page, b, l, hideIntimate: hide)) {
      final t = h.tile;
      if (t == null) {
        // A read under its own title, from any door's library half.
        if (h.readId case final id?) library.putIfAbsent(id, () => h);
        continue;
      }
      final key = _readIdOf(t) ?? '${t.runtimeType}:${t.title}';
      if (seenTiles.add(key)) out.add((h, b.hue));
    }
  }
  for (final h in library.values) {
    final r = ttcReadById(h.readId!);
    out.add((h, r == null ? 268 : _hueOfRead(r)));
  }
  return out;
}

/// The library's hits for [query], best first, each with its hue.
List<(TtcDoorHit, double)> ttcLibrarySearch(
  String query,
  List<(TtcDoorHit, double)> index,
) {
  final hue = {for (final (h, u) in index) h: u};
  final seen = <String>{};
  return [
    for (final h in ttcDoorSearch(query, [for (final (h, _) in index) h]))
      // One row per read, whichever way it matched best.
      if (ttcHitReadId(h) case final id when id == null || seen.add(id))
        (h, hue[h] ?? 268),
  ];
}

/// The read a hit opens, if it opens one.
String? ttcHitReadId(TtcDoorHit h) =>
    h.readId ?? (h.tile == null ? null : _readIdOf(h.tile!));

// =============================================================================
//  Her recent searches on this tab
// =============================================================================

/// Recent searches on the Learn tab. Local only, like the doors' recents:
/// they are a typing shortcut, not history anyone else needs.
class TtcLearnRecents extends ChangeNotifier {
  TtcLearnRecents._();
  static final TtcLearnRecents instance = TtcLearnRecents._();

  static const String kKey = 'ttc_learn_recent';
  static const int _max = 6;

  List<String> _recent = const [];
  bool _loaded = false;
  List<String> get recent => _recent;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final p = await SharedPreferences.getInstance();
      _recent = p.getStringList(kKey) ?? const [];
      notifyListeners();
    } catch (_) {/* local-first: an empty list is a fine answer */}
  }

  Future<void> remember(String q) async {
    final s = q.trim();
    if (s.length < 2) return;
    _recent = [
      s,
      ..._recent.where((r) => r.toLowerCase() != s.toLowerCase()),
    ].take(_max).toList();
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setStringList(kKey, _recent);
    } catch (_) {}
  }

  Future<void> clear() async {
    _recent = const [];
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).remove(kKey);
    } catch (_) {}
  }

  @visibleForTesting
  void resetForTest() {
    _recent = const [];
    _loaded = false;
  }
}

/// What people most often come looking for. Plain words she would type.
const List<String> _kPopular = [
  'Ovulation',
  'Folic acid',
  'PCOS',
  'Sperm test',
  'IVF',
  'Stress',
];

// =============================================================================
//  The screen
// =============================================================================

class TtcLearnScreen extends StatefulWidget {
  const TtcLearnScreen({super.key});

  @override
  State<TtcLearnScreen> createState() => _TtcLearnScreenState();
}

class _TtcLearnScreenState extends State<TtcLearnScreen> {
  final PvLiveSearch _search = PvLiveSearch();

  /// Per shelf: which door tab is chosen (null = All), and whether it is open.
  final Map<String, String?> _tab = {};
  final Set<String> _expanded = {};
  final Set<int> _openFaq = {};

  late final List<TtcLearnShelf> _shelves = ttcLearnShelves();
  late final List<PvRead> _start = ttcLearnStartHere();
  late final List<(PvReadFaq, PvRead)> _faqs = ttcLearnFaqs();
  late final List<(TtcTile, double)> _stories = ttcLearnStories();
  late final List<PvOfferingView> _courses = _loadCourses();

  /// The one search index (L8), rebuilt only when her content choice or the
  /// language changes, never per keystroke.
  List<(TtcDoorHit, double)>? _index;
  (bool, bool)? _indexFor;

  List<(TtcDoorHit, double)> get _library {
    final key = (
      TtcContentPrefs.instance.hideIntimate,
      TtcLang.instance.hinglish,
    );
    if (_index == null || _indexFor != key) {
      _index = ttcLibraryIndex(hideIntimate: key.$1);
      _indexFor = key;
    }
    return _index!;
  }

  static List<PvOfferingView> _loadCourses() {
    try {
      return PvLearnCatalog.instance
          .all(stage: LifeStage.tryingToConceive)
          .where((v) => v.kind != PvLearnKind.consult)
          .toList();
    } catch (_) {
      // Local-first: the catalogue merging late is never a crash here.
      return const [];
    }
  }

  @override
  void initState() {
    super.initState();
    PvReadStore.instance.load();
    SavedStore.instance.load();
    TtcLearnRecents.instance.load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ---- opening things -------------------------------------------------------

  void _openRead(PvRead r) {
    pvCommitFeedback();
    if (_search.searching) TtcLearnRecents.instance.remember(_search.query);
    // A course step opened here counts toward the home's "New here?" card
    // stepping aside. Ids outside the course are ignored by the store.
    TtcHomePrefs.instance.markOpened(r.id);
    openTtcSurface(context, '$kTtcReadPrefix${r.id}');
  }

  /// A search hit: remember the words, count a course step as opened, then
  /// the doors' own opener, so a hit here lands exactly where it does there.
  void _openHit(TtcDoorHit h, double hue) {
    TtcLearnRecents.instance.remember(_search.query);
    if (ttcHitReadId(h) case final id?) TtcHomePrefs.instance.markOpened(id);
    openTtcDoorHit(context, h, hue: hue);
  }

  void _openDoor(Bracket b) {
    pvCommitFeedback();
    openTtcFocusTile(
      context,
      TtcDoorTile(title: b.label.en, blurb: b.blurb.en, bracketId: b.id),
      b.hue,
    );
  }

  void _openSaved() => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const SavedScreen(),
        settings: const RouteSettings(name: 'saved'),
      ));

  void _openAllCourses() => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const TtcPrepareScreen(),
        settings: const RouteSettings(name: 'ttc/prepare'),
      ));

  void _askVeda(String q) {
    TtcLearnRecents.instance.remember(q);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => TtcAskVedaScreen(initialQuery: q),
      settings: const RouteSettings(name: kAskVedaRoute),
    ));
  }

  // ---- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _search,
        TtcLang.instance,
        SavedStore.instance,
        PvReadStore.instance,
        TtcLearnRecents.instance,
        // Her "Hide sex and intimacy content" choice (2026-09-26).
        TtcContentPrefs.instance,
        // His side leads with his own door (2026-09-27).
        TtcPartnerMode.instance,
      ]),
      builder: (context, _) {
        final p = pvStorePalette;
        final t = TtcS.current();
        return PvLiveSearchScope(
          search: _search,
          child: Scaffold(
            backgroundColor: p.ground,
            body: Stack(children: [
              Positioned.fill(
                child: ListView(
                  // ⚠️ THE HEADER CARRIES THE SAFE-AREA INSET (2026-09-29,
                  // TtcTabRootHeader), so every tab root's title sits at one
                  // y. Kept for revert:
                  //   padding: EdgeInsets.fromLTRB(0,
                  //       MediaQuery.of(context).padding.top + 12, 0,
                  //       pvNavClearance(context)),
                  padding:
                      EdgeInsets.fromLTRB(0, 0, 0, pvNavClearance(context)),
                  children: [
                    _header(p, t),
                    // The search is the header's `below` now, at the spec's
                    // gap. Kept for revert:
                    //   const SizedBox(height: 14),
                    //   _pad(PvLiveSearchField(search: _search, p: p,
                    //     hint: t.learnSearchHint,
                    //     onSubmitted: (q) =>
                    //         TtcLearnRecents.instance.remember(q))),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: pvLiveSearchSheetMin(context, _search)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _search.searching
                            ? _results(p, t)
                            : _search.recalling
                                ? _recall(p, t)
                                : _page(p, t),
                      ),
                    ),
                  ],
                ),
              ),
              // ⚠️ THE BAR STEPS ASIDE FOR THE KEYBOARD (launch sanity L4,
              // 2026-09-28): floating above the keyboard it covered a third
              // of the results. It comes back the moment the keyboard goes.
              if (MediaQuery.viewInsetsOf(context).bottom == 0)
                const Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: SafeArea(
                      top: false, child: TtcBottomNav(active: 1, v3: true)),
                ),
              // Nothing slides under the clock (the D2 rule, here too): a
              // strip of the page's own ground behind the status bar.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                      height: MediaQuery.paddingOf(context).top,
                      color: p.ground),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  // L10: the stage's gutter is 18 (the doors and the TTC chrome). Was 20.
  static const double _g = 18;

  Widget _pad(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: _g), child: child);

  /// ⚠️ ONE TAB-ROOT HEADER (2026-09-29, build 19): Learn's geometry became
  /// the spec every tab root uses (ttc_tab_root_header.dart has the
  /// measurements and the Mobbin evidence). Same title, same bookmark, same
  /// intro, same search; only who owns the spacing changed.
  Widget _header(V2Palette p, TtcS t) => TtcTabRootHeader(
        title: t.learnTitle,
        trailing: [
          // L7: no count. Kept for revert:
          //   badge: SavedStore.instance.items(kind: SavedKind.article).length,
          PvRoundIcon(
            icon: Icons.bookmark_border_rounded,
            onTap: _openSaved,
            size: kTtcTabRootRowHeight,
          ),
        ],
        intro: PvLiveSearchWords(
          search: _search,
          child: Text(t.learnIntro, style: ttcTabRootIntroStyle()),
        ),
        below: PvLiveSearchField(
          search: _search,
          p: p,
          hint: t.learnSearchHint,
          onSubmitted: (q) => TtcLearnRecents.instance.remember(q),
        ),
      );
  // Kept for revert (2026-09-29), Learn's own header:
  // Widget _header(V2Palette p, TtcS t) => _pad(Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(children: [
  //           Expanded(
  //             child: Text(t.learnTitle,
  //                 style: pvFraunces(
  //                     fontSize: 30,
  //                     fontWeight: FontWeight.w500,
  //                     height: 1.1,
  //                     color: p.ink1)),
  //           ),
  //           PvRoundIcon(
  //             icon: Icons.bookmark_border_rounded,
  //             onTap: _openSaved,
  //             size: 42,
  //           ),
  //         ]),
  //         const SizedBox(height: 6),
  //         PvLiveSearchWords(
  //           search: _search,
  //           child: Text(t.learnIntro,
  //               style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
  //         ),
  //       ],
  //     ));

  // ---- the idle page ----------------------------------------------------------

  List<Widget> _page(V2Palette p, TtcS t) => [
        const SizedBox(height: 22),
        _topics(p, t),
        _yourReading(p, t),
        _startHere(p, t),
        _films(p, t),
        for (final s in _shelves) _shelf(p, t, s),
        _storiesRail(p, t),
        _coursesRail(p, t),
        _questions(p, t),
        const SizedBox(height: 26),
        _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline_rounded, size: 16, color: p.ink3),
          const SizedBox(width: 8),
          Expanded(
            child: Text(t.learnFootnote,
                style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
          ),
        ])),
      ];

  Widget _head(String eyebrow, String title,
          {String? action, VoidCallback? onAction, String? lead}) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(_g, 30, _g, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PvSectionHead(
              eyebrow: eyebrow,
              title: title,
              action: action,
              onAction: onAction),
          if (lead != null) ...[
            const SizedBox(height: 6),
            Text(lead,
                style: pvManrope(
                    fontSize: 13, height: 1.45, color: pvStorePalette.ink2)),
          ],
        ]),
      );

  // ---- browse by topic (Flo's big topic entries) ------------------------------

  Widget _topics(V2Palette p, TtcS t) {
    // L4: every door, from `kTtcBrackets`. L3: each wears its own drawn mark.
    final topics = ttcLearnTopics();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(_eyebrow(p, t.learnTopics)),
      const SizedBox(height: 10),
      SizedBox(
        // ⚠️ GROWS WITH HER TEXT SIZE (2026-09-29). A fixed 108 clipped the
        // tile's name and count by 20-35px at 1.5x on a 360dp phone. The
        // tile is 12 + a 38 mark + 8 + the name + 2 + the count + 12; at 1x
        // that is under 108, so the common case is unchanged.
        // Kept for revert (2026-09-29): height: 108,
        height: math.max(
            108.0,
            72 +
                MediaQuery.textScalerOf(context).scale(13.5) * 1.4 +
                MediaQuery.textScalerOf(context).scale(11.5) * 1.4),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: _g),
          itemCount: topics.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final x = topics[i];
            return _TopicTile(
              key: ValueKey('ttc_learn_topic_${x.bracket.id}'),
              label: x.bracket.label.en,
              meta: x.reads == 1 ? '1 read' : '${x.reads} reads',
              hue: x.bracket.hue,
              mark: bracketMarkFor(x.bracket.id),
              onTap: () => _openDoor(x.bracket),
            );
          },
        ),
      ),
    ]);
  }

  // ---- your reading (Blinkist's In progress, then Saved) ----------------------

  Widget _yourReading(V2Palette p, TtcS t) {
    final store = PvReadStore.instance;
    final going = [
      for (final r in kTtcReads)
        if (store.isStarted(r.id) && ttcLearnShows(r)) r
    ];
    // ⚠️ A READ ONCE IN THIS SECTION (2026-09-28, no repetition). A read she
    // has started AND saved was a card in "Pick up where you left off" and
    // again a row under it. It stays in the rail, where her place is kept;
    // Saved (the screen) still lists it. Kept for revert: the saved list
    // without the `going` check.
    final saved = [
      for (final r in kTtcReads)
        if (store.isSaved(r.id) && ttcLearnShows(r) && !going.contains(r)) r
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _head(t.learnYourReading, going.isNotEmpty ? t.learnContinue : t.learnSaved,
          action: t.learnSeeSaved, onAction: _openSaved),
      const SizedBox(height: 12),
      if (going.isNotEmpty)
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: _g),
            itemCount: going.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _ContinueCard(
              read: going[i],
              hue: _hueOfRead(going[i]),
              progress: store.progressOf(going[i].id),
              meta: t.learnMinRead(going[i].minutes),
              onTap: () => _openRead(going[i]),
            ),
          ),
        ),
      if (going.isNotEmpty && saved.isNotEmpty) const SizedBox(height: 10),
      if (saved.isNotEmpty)
        _pad(PvRowGroup(p: p, children: [
          for (final r in saved.take(3))
            _readRow(p, r,
                hue: _hueOfRead(r),
                meta: t.learnMinRead(r.minutes),
                trailing: Icon(Icons.bookmark_rounded, size: 18, color: p.ink3)),
        ])),
      // A feature is never hidden: with nothing started or saved, the row is
      // the invitation, and says what saving does.
      if (going.isEmpty && saved.isEmpty)
        _pad(Row(children: [
          Icon(Icons.bookmark_border_rounded, size: 20, color: p.ink2),
          const SizedBox(width: 10),
          Expanded(
            child: Text(t.learnSavedEmpty,
                style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
          ),
        ])),
    ]);
  }

  // ---- start here (Flo's step rail, as an ordered list) -----------------------

  Widget _startHere(V2Palette p, TtcS t) {
    if (_start.isEmpty) return const SizedBox.shrink();
    final store = PvReadStore.instance;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _head(t.learnStartEyebrow, t.learnStartTitle, lead: t.learnStartLead),
      const SizedBox(height: 12),
      _pad(PvRowGroup(p: p, children: [
        for (var i = 0; i < _start.length; i++)
          PvListRow(
            p: p,
            leading: _StepMark(n: i + 1, done: store.isFinished(_start[i].id)),
            title: _start[i].title.en,
            meta: store.isFinished(_start[i].id)
                ? '${t.learnFinished} · ${t.learnMinRead(_start[i].minutes)}'
                : t.learnMinRead(_start[i].minutes),
            onTap: () => _openRead(_start[i]),
          ),
      ])),
    ]);
  }

  // ---- films (placeholders, shown as upcoming) --------------------------------

  /// L5: at most two film placeholders, not tappable, each with what it
  /// will be for (§4.7: a placeholder is never tappable, and two per screen
  /// at most). Then the reads those films point to, as ordinary rows, so the
  /// section still gives her something to open today. Mobbin: Clue's Content
  /// tab shows only films that exist (CLUE-CONTENT,
  /// https://mobbin.com/screens/314d865c-de15-48b3-82d9-900e5855bf64).
  Widget _films(V2Palette p, TtcS t) {
    final films = kTtcVideos.take(2).toList();
    if (films.isEmpty) return const SizedBox.shrink();
    // Kept for revert (L1): the reads under the films, as their own list.
    // final reads = <PvRead>[];
    // for (final v in kTtcVideos) {
    //   for (final id in v.readNext) {
    //     final r = ttcReadById(id);
    //     if (r == null || !ttcLearnShows(r) || reads.any((x) => x.id == id)) {
    //       continue;
    //     }
    //     reads.add(r);
    //   }
    // }
    // ⚠️ THE NOTES LIVE IN THE FILM'S OWN CARD (launch sanity L1,
    // 2026-09-28). The reads these films point to used to follow under a
    // bare "READ ABOUT IT NOW" eyebrow, and the same three PCOS rows came
    // back a screen lower under the PCOS shelf: one list twice, and an
    // eyebrow that only made sense joined to the films above. Each card now
    // carries "Read the notes", which opens the film's first read; the
    // separate list is kept below as a comment, for revert.
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _head(t.learnFilmsEyebrow, t.learnFilmsTitle, lead: t.learnFilmsLead),
      const SizedBox(height: 12),
      _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < films.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: _FilmCard(
              film: films[i],
              meta: t.learnMinWatch((films[i].seconds / 60).round()),
              coming: t.learnFilmComing,
              notes: _filmNotes(films[i]),
              onNotes: _filmNotes(films[i]) == null
                  ? null
                  : () => _openRead(_filmNotes(films[i])!),
            ),
          ),
        ],
      ])),
      // Kept for revert (L1): the separate "Read about it now" list.
      // if (reads.isNotEmpty) ...[
      //   const SizedBox(height: 16),
      //   _pad(_eyebrow(p, t.learnFilmReadNow)),
      //   const SizedBox(height: 8),
      //   _pad(PvRowGroup(p: p, children: [
      //     for (final r in reads.take(3))
      //       _readRow(p, r, hue: _hueOfRead(r), meta: t.learnMinRead(r.minutes)),
      //   ])),
      // ],
    ]);
  }

  /// The first read a film points to that she can open (L1).
  PvRead? _filmNotes(PvVideoSlot v) {
    for (final id in v.readNext) {
      final r = ttcReadById(id);
      if (r != null && ttcLearnShows(r)) return r;
    }
    return null;
  }

  // Kept for revert (L5, 2026-09-26): the rail of every film, each tappable
  // into the sheet below.
  //   SizedBox(height: 206, child: ListView.separated(
  //     scrollDirection: Axis.horizontal, itemCount: kTtcVideos.length,
  //     itemBuilder: (_, i) => _FilmCard(film: kTtcVideos[i], ...,
  //         onTap: () => _openFilm(kTtcVideos[i], t)))),

  /// The film's page, before the film exists: its promise, who is in it, what
  /// it covers and what to read meanwhile. A tap that opened nothing would
  /// teach her taps do nothing; a player that plays nothing would be worse.
  // ignore: unused_element
  void _openFilm(PvVideoSlot v, TtcS t) {
    pvCommitFeedback();
    final p = pvStorePalette;
    final reads = [for (final id in v.readNext) ?ttcReadById(id)];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.86),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PvVideoPlaceholder(
                  title: v.title.en,
                  duration: '${(v.seconds / 60).round()} MIN',
                  hue: v.hue,
                  slotId: v.id,
                  flat: true,
                  overlayTitle: true,
                ),
                const SizedBox(height: 14),
                Text(v.title.en,
                    style: pvFraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: p.ink1)),
                const SizedBox(height: 6),
                Text(v.why.en,
                    style: pvManrope(
                        fontSize: 14, height: 1.45, color: p.ink2)),
                const SizedBox(height: 8),
                Text('${v.expert.en} · ${v.expertRole.en}',
                    style: pvManrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink3)),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.schedule_rounded, size: 16, color: p.ink3),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(t.learnFilmNotYet,
                        style: pvManrope(
                            fontSize: 12.5, height: 1.4, color: p.ink3)),
                  ),
                ]),
                if (v.takeaways.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _eyebrow(p, t.learnFilmTakeaways),
                  const SizedBox(height: 8),
                  for (final line in v.takeaways)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                      color: p.ink1,
                                      shape: BoxShape.circle)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(line.en,
                                  style: pvManrope(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: p.ink1)),
                            ),
                          ]),
                    ),
                ],
                if (v.chapters.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _eyebrow(p, t.learnFilmCovers),
                  const SizedBox(height: 6),
                  for (final c in v.chapters)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: kPvLine))),
                      child: Row(children: [
                        SizedBox(
                          width: 48,
                          child: Text(_mmss(c.at),
                              style: pvManrope(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: p.ink3)),
                        ),
                        Expanded(
                          child: Text(c.label.en,
                              style: pvManrope(
                                  fontSize: 14, color: p.ink1)),
                        ),
                      ]),
                    ),
                ],
                if (reads.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _eyebrow(p, t.learnFilmReadNow),
                  const SizedBox(height: 8),
                  PvRowGroup(p: p, children: [
                    for (final r in reads)
                      _readRow(p, r,
                          hue: _hueOfRead(r),
                          meta: t.learnMinRead(r.minutes), onTap: () {
                        Navigator.of(ctx).pop();
                        _openRead(r);
                      }),
                  ]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _mmss(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  // L9: §4.2's eyebrow, 11 / w800 / +1.4 (was 10.5 / 1.1).
  Widget _eyebrow(V2Palette p, String s) => Text(s.toUpperCase(),
      style: pvManrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: p.action));

  /// One read as a row (L1, L2): its photo, else the drawn page mark in its
  /// door's tint. The same row the doors draw.
  Widget _readRow(V2Palette p, PvRead r,
          {required double hue,
          required String meta,
          Widget? trailing,
          VoidCallback? onTap}) =>
      PvListRow(
        p: p,
        // ⚠️ THE DOOR'S DRAWING WHEN THERE IS NO PHOTO (2026-09-27): the home
        // draws a read this way, so the same read looks the same in both
        // places. Kept for revert: mark: IntentMark.pageMark alone.
        leading: PvMarkWell(
            p: p,
            hue: hue,
            photo: readImageFor(r.id, own: r.imageUrl),
            bracket: _doorMarkOf(r),
            mark: _doorMarkOf(r) == null ? IntentMark.pageMark : null),
        title: r.title.en,
        line: r.teaser.en,
        meta: meta,
        trailing: trailing,
        onTap: onTap ?? () => _openRead(r),
      );

  // ---- one door's shelf, with the door's tabs as chips ------------------------

  Widget _shelf(V2Palette p, TtcS t, TtcLearnShelf s) {
    // ⚠️ HER "HIDE SEX AND INTIMACY CONTENT" CHOICE (2026-09-26). The
    // intimacy reads leave every shelf and the door's Sex and closeness chip
    // leaves the chips; the shelves themselves are derived once, so the
    // filter is applied here, where they are drawn, and follows the switch
    // the moment it moves.
    final hide = TtcContentPrefs.instance.hideIntimate;
    final tabs = [
      for (final x in s.tabs)
        if (!(hide && x.id == kTtcIntimateGroupId)) x
    ];
    final all = [for (final r in s.reads) if (ttcLearnShows(r)) r];
    if (all.isEmpty) return const SizedBox.shrink();
    final chosen = _tab[s.key];
    final tab = chosen == null
        ? null
        : tabs.where((x) => x.id == chosen).firstOrNull;
    final reads = tab == null
        ? all
        : [for (final r in all) if (tab.readIds.contains(r.id)) r];
    final open = _expanded.contains(s.key);
    const fold = 4;
    final shown = open ? reads : reads.take(fold).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // L2: the title is the door's name, so the eyebrow says what the
      // shelf is rather than the name twice. Kept for revert: s.label.
      _head(s.bracket == null ? s.label : 'Reads from the door', s.title,
          action: s.bracket == null ? null : t.learnOpenDoor,
          onAction: s.bracket == null ? null : () => _openDoor(s.bracket!)),
      if (tabs.isNotEmpty) ...[
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: _g),
            children: [
              PvChip(
                label: t.learnAll,
                selected: tab == null,
                onTap: () => setState(() => _tab[s.key] = null),
              ),
              for (final x in tabs) ...[
                const SizedBox(width: 6),
                PvChip(
                  label: x.label,
                  selected: tab?.id == x.id,
                  onTap: () => setState(() => _tab[s.key] = x.id),
                ),
              ],
            ],
          ),
        ),
      ],
      const SizedBox(height: 12),
      _pad(PvRowGroup(p: p, children: [
        for (final r in shown)
          _readRow(p, r, hue: s.hue, meta: t.learnMinRead(r.minutes)),
      ])),
      if (reads.length > fold)
        _pad(Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() =>
                open ? _expanded.remove(s.key) : _expanded.add(s.key)),
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                foregroundColor: p.ink1),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              // Flexible (2026-09-29): at 1.5x on 360dp the words ran 44px
              // past the edge. Kept for revert: the Text without Flexible.
              Flexible(
                child: Text(
                    open ? t.learnShowFewer : t.learnShowAll(reads.length),
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink1)),
              ),
              const SizedBox(width: 4),
              Icon(
                  open
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: p.ink1),
            ]),
          ),
        )),
    ]);
  }

  // ---- myths and stories ------------------------------------------------------

  Widget _storiesRail(V2Palette p, TtcS t) {
    if (_stories.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _head(t.learnMythsEyebrow, t.learnMythsTitle),
      const SizedBox(height: 12),
      SizedBox(
        // Grows with her text size (2026-09-29): 28 of padding, the 26 kind
        // row, 10, two lines of title, 6, two lines of blurb. At 1x that is
        // under 150. Kept for revert (2026-09-29): height: 150,
        height: math.max(
            150.0,
            70 +
                MediaQuery.textScalerOf(context).scale(14) * 1.3 * 2 +
                MediaQuery.textScalerOf(context).scale(12.5) * 1.4 * 2),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: _g),
          itemCount: _stories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final (tile, hue) = _stories[i];
            return _StoryCard(
              tile: tile,
              hue: hue,
              onTap: () {
                pvCommitFeedback();
                openTtcFocusTile(context, tile, hue);
              },
            );
          },
        ),
      ),
    ]);
  }

  // ---- courses and programmes -------------------------------------------------

  Widget _coursesRail(V2Palette p, TtcS t) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _head(t.learnCoursesEyebrow, t.learnCoursesTitle,
            action: t.learnCoursesAll, onAction: _openAllCourses),
        const SizedBox(height: 12),
        if (_courses.isEmpty)
          _pad(InkWell(
            onTap: _openAllCourses,
            child: Text(t.moreEverythingPaidBody,
                style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
          ))
        else
          SizedBox(
            // Grows with her text size (2026-09-29): a 16:9 cover on 220,
            // 10, two lines of title, 3, the meta line. At 1x under 196.
            // Kept for revert (2026-09-29): height: 196,
            height: math.max(
                196.0,
                138 +
                    MediaQuery.textScalerOf(context).scale(14) * 1.3 * 2 +
                    MediaQuery.textScalerOf(context).scale(11.5) * 1.4 +
                    4),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: _g),
              itemCount: _courses.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _CourseCard(
                view: _courses[i],
                onTap: () {
                  pvCommitFeedback();
                  pvOpenOffering(context, _courses[i]);
                },
              ),
            ),
          ),
      ]);

  // ---- common questions (Flo's accordion) -------------------------------------

  Widget _questions(V2Palette p, TtcS t) {
    final faqs = [for (final f in _faqs) if (ttcLearnShows(f.$2)) f];
    if (faqs.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _head(t.learnFaqEyebrow, t.learnFaqTitle),
      const SizedBox(height: 8),
      for (var i = 0; i < faqs.length; i++)
        _pad(_FaqItem(
          question: faqs[i].$1.question.en,
          answer: faqs[i].$1.answer.en,
          from: t.learnFaqFrom(faqs[i].$2.title.en),
          open: _openFaq.contains(i),
          last: i == faqs.length - 1,
          onToggle: () => setState(
              () => _openFaq.contains(i) ? _openFaq.remove(i) : _openFaq.add(i)),
          onOpenRead: () => _openRead(faqs[i].$2),
        )),
    ]);
  }

  // ---- search: recall and results ---------------------------------------------

  List<Widget> _recall(V2Palette p, TtcS t) {
    final recent = TtcLearnRecents.instance.recent;
    // L6: a recall row presses like every other row.
    Widget row(IconData icon, String q) => PvPress(
        child: InkWell(
          onTap: () {
            pvCommitFeedback();
            _search.run(q);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _g, vertical: 12),
            child: Row(children: [
              Icon(icon, size: 20, color: p.ink2),
              const SizedBox(width: 14),
              Expanded(
                child: Text(q,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: p.ink1)),
              ),
              Icon(Icons.north_west_rounded, size: 16, color: p.ink3),
            ]),
          ),
        ));
    return [
      if (recent.isNotEmpty) ...[
        const SizedBox(height: 22),
        pvLiveSearchRecallHeading(p, t.learnRecent,
            onClear: TtcLearnRecents.instance.clear),
        const SizedBox(height: 6),
        for (final r in recent) row(Icons.history_rounded, r),
      ],
      const SizedBox(height: 22),
      pvLiveSearchRecallHeading(p, t.learnPopular),
      const SizedBox(height: 6),
      for (final q in _kPopular) row(Icons.search_rounded, q),
    ];
  }

  /// L8: the doors' index and the doors' matcher, over every door. The rows
  /// are the doors' own result row (`TtcDoorHitRow`), which names where each
  /// hit lives ("PCOS · What helps"), so a hit from any door reads the same.
  /// Ask Veda is the last row, always.
  List<Widget> _results(V2Palette p, TtcS t) {
    final q = _search.query;
    final hits = ttcLibrarySearch(q, _library);
    return [
      const SizedBox(height: 14),
      if (hits.isEmpty)
        _pad(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(t.learnNoMatch,
              style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
        )),
      for (final (i, (h, hue)) in hits.take(24).indexed)
        TtcDoorHitRow(
          key: ttcDoorSearchHitKey(i),
          p: p,
          hit: h,
          onTap: () => _openHit(h, hue),
        ),
      const SizedBox(height: 12),
      _pad(PvLiveSearchWayOn(
        p: p,
        icon: Icons.auto_awesome_outlined,
        title: t.learnAskVeda(q),
        line: t.learnAskVedaLine,
        onTap: () => _askVeda(q),
      )),
    ];
  }

  // Kept for revert (L8, 2026-09-26): the Learn-only engine, reads and films
  // matched by substring on words of three letters or more, in `_ListCard`s.
  //   final hits = ttcLearnSearch(q).where(ttcLearnShows).toList();
  //   final films = [for (final v in kTtcVideos)
  //       if (_matches('${v.title.en} ${v.why.en}', q) > 0) v];
  //   ... _ReadRow(read: r, meta: '${r.kicker.en} · ...') for each hit,
  //   ... _FilmRow(film: v, onTap: () => _openFilm(v, t)) for each film.
}

/// How many of the query's words appear in [hay]. Words under three letters
/// are ignored ("is", "of"), unless the whole query is that short.
int _matches(String hay, String q) {
  final h = hay.toLowerCase();
  final words = q
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((w) => w.length >= 3)
      .toList();
  if (words.isEmpty) return h.contains(q.toLowerCase().trim()) ? 1 : 0;
  return words.where(h.contains).length;
}

/// The reads that answer a query, best first: title words count most, then
/// the teaser and the door, then the FAQ questions inside the read.
List<PvRead> ttcLearnSearch(String query) {
  final q = query.trim();
  if (q.isEmpty) return const [];
  final scored = <(PvRead, int)>[];
  for (final r in kTtcReads) {
    final score = _matches(r.title.en, q) * 4 +
        _matches('${r.teaser.en} ${r.kicker.en}', q) * 2 +
        _matches([for (final f in r.faqs) f.question.en].join(' '), q);
    if (score > 0) scored.add((r, score));
  }
  scored.sort((a, b) => b.$2.compareTo(a.$2));
  return [for (final s in scored) s.$1];
}

// =============================================================================
//  The pieces
// =============================================================================

Color _wellInk(Color tint) => HSLColor.fromColor(tint)
    .withSaturation(0.46)
    .withLightness(0.40)
    .toColor();

/// White, one hairline, radius 16, rows separated by hairlines: the base-UI
/// list (DESIGN-SYSTEM §4.0, "a written section is a list").
// ⚠️ KEPT FOR REVERT (L1, L2, L6 — 2026-09-26). The boxed list, the thumbnail
// with a Material glyph, and the bare-InkWell rows. `PvRowGroup`, `PvListRow`
// and `PvMarkWell` (lib/screens/doors/pv_list_row.dart) replaced all four.
// class _ListCard extends StatelessWidget {
//   const _ListCard({required this.children});
//   final List<Widget> children;
//
//   @override
//   Widget build(BuildContext context) => Container(
//         clipBehavior: Clip.antiAlias,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: kPvLine),
//         ),
//         child: Column(children: [
//           for (var i = 0; i < children.length; i++) ...[
//             if (i > 0)
//               const Divider(
//                   height: 1,
//                   thickness: 1,
//                   color: kPvLine,
//                   indent: 16,
//                   endIndent: 16),
//             children[i],
//           ],
//         ]),
//       );
// }
//
// /// The 56pt thumbnail: the read's photo, else its door's mark in the door's
// /// well. Never a broken-image glyph.
// class _Thumb extends StatelessWidget {
//   const _Thumb({required this.hue, required this.icon, this.url});
//   final double hue;
//   final IconData icon;
//   final String? url;
//   static const double size = 56;
//
//   @override
//   Widget build(BuildContext context) {
//     final tint = v2BlockTint(hue, pvStorePalette);
//     final well = Container(
//       width: size,
//       height: size,
//       alignment: Alignment.center,
//       color: tint,
//       child: Icon(icon, size: size * 0.4, color: _wellInk(tint)),
//     );
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: SizedBox(
//         width: size,
//         height: size,
//         child: url == null
//             ? well
//             : Image.network(url!,
//                 fit: BoxFit.cover, errorBuilder: (_, _, _) => well),
//       ),
//     );
//   }
// }
//
// class _ReadRow extends StatelessWidget {
//   const _ReadRow({
//     required this.read,
//     required this.hue,
//     required this.meta,
//     required this.onTap,
//     this.icon = Icons.article_outlined,
//     this.trailing,
//   });
//   final PvRead read;
//   final double hue;
//   final String meta;
//   final VoidCallback onTap;
//   final IconData icon;
//   final IconData? trailing;
//
//   @override
//   Widget build(BuildContext context) {
//     final p = pvStorePalette;
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
//         child: Row(children: [
//           _Thumb(hue: hue, icon: icon, url: read.imageUrl),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(read.title.en,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: pvManrope(
//                       fontSize: 14.5,
//                       fontWeight: FontWeight.w700,
//                       height: 1.3,
//                       color: p.ink1)),
//               const SizedBox(height: 3),
//               Text(read.teaser.en,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: pvManrope(fontSize: 12.5, color: p.ink2)),
//               const SizedBox(height: 4),
//               Text(meta,
//                   style: pvManrope(
//                       fontSize: 11.5,
//                       fontWeight: FontWeight.w700,
//                       color: p.ink3)),
//             ]),
//           ),
//           const SizedBox(width: 6),
//           Icon(trailing ?? Icons.chevron_right_rounded,
//               size: trailing == null ? 20 : 18, color: p.ink3),
//         ]),
//       ),
//     );
//   }
// }
//
// class _StepRow extends StatelessWidget {
//   const _StepRow({
//     required this.n,
//     required this.read,
//     required this.meta,
//     required this.done,
//     required this.onTap,
//   });
//   final int n;
//   final PvRead read;
//   final String meta;
//   final bool done;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final p = pvStorePalette;
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
//         child: Row(children: [
//           Container(
//             width: 30,
//             height: 30,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: done ? p.ink1 : Colors.white,
//               border: Border.all(color: done ? p.ink1 : p.ink3, width: 1.3),
//             ),
//             child: done
//                 ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
//                 : Text('$n',
//                     style: pvManrope(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w800,
//                         color: p.ink1)),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(read.title.en,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: pvManrope(
//                       fontSize: 14.5,
//                       fontWeight: FontWeight.w700,
//                       height: 1.3,
//                       color: p.ink1)),
//               const SizedBox(height: 3),
//               Text(meta,
//                   style: pvManrope(
//                       fontSize: 11.5,
//                       fontWeight: FontWeight.w700,
//                       color: p.ink3)),
//             ]),
//           ),
//           Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
//         ]),
//       ),
//     );
//   }
// }

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    super.key,
    required this.label,
    required this.meta,
    required this.hue,
    required this.mark,
    required this.onTap,
  });
  final String label;
  final String meta;
  final double hue;

  /// The door's drawn mark (L3). Null only for a door `bracketMarkFor` does
  /// not know, which then shows the page mark rather than a Material glyph.
  final BracketMark? mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final tint = v2BlockTint(hue, p);
    return PvPress(
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: kPvLine)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 124,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kept for revert (L3): Icon(icon, size: 18, color: _wellInk(tint))
                  // in the same 34pt well.
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        color: tint, borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.all(mark == null ? 8 : 4),
                    child: mark == null
                        ? HubIntentArt(mark: IntentMark.pageMark, tint: tint)
                        : V3BracketArt(mark: mark!, tint: tint),
                  ),
                  const Spacer(),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: p.ink1)),
                  const SizedBox(height: 2),
                  // One line, like the name above it (2026-09-29, 1.5x text).
                  Text(meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 11.5, color: p.ink3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.read,
    required this.hue,
    required this.progress,
    required this.meta,
    required this.onTap,
  });
  final PvRead read;
  final double hue;
  final double progress;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return PvPress(
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: kPvLine)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 250,
            child: Column(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    PvMarkWell(
                        p: p,
                        hue: hue,
                        photo: readImageFor(read.id, own: read.imageUrl),
                        mark: IntentMark.pageMark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(read.title.en,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                  color: p.ink1)),
                          const SizedBox(height: 4),
                          Text(meta,
                              style: pvManrope(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: p.ink3)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              // A reading position, as the reader draws it: a hairline.
              SizedBox(
                height: 3,
                child: Stack(children: [
                  Container(color: kPvLine),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(color: p.ink1),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// A film that does not exist yet (L5): NOT tappable, no press, so it never
/// promises a tap that opens nothing (§4.7). It says what the film will be
/// for, which is the placeholder's one job.
class _FilmCard extends StatelessWidget {
  const _FilmCard({
    required this.film,
    required this.meta,
    required this.coming,
    this.notes,
    this.onNotes,
  });
  final PvVideoSlot film;

  /// The film's length. ⚠️ NOT SHOWN since 2026-09-28 (launch sanity L3):
  /// a duration on a film that does not exist is a promise. Kept so the
  /// pill comes back in one line when a film is live.
  final String meta;
  final String coming;

  /// The read behind the film, and how to open it (L1).
  final PvRead? notes;
  final VoidCallback? onNotes;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final tint = v2BlockTint(film.hue, p);
    return Column(
        key: ValueKey('ttc_learn_film_${film.id}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: tint,
                // ⚠️ NO PLAY GLYPH ON SOMETHING THAT CANNOT PLAY (launch
                // sanity L3, D3, 2026-09-28): a clock and "Coming soon",
                // nothing that looks like a player, and no duration. Kept
                // for revert: the play mark centred, and
                //   Positioned(right: 8, bottom: 8, child: _Pill(label: meta)),
                child: Stack(children: [
                  // ⚠️ A STILL, NOT A CLOCK ON A TINT (2026-09-29, the user:
                  // "stop leaving the placeholders"). The film's still from
                  // `kPvFilmStills`, the same photo its door card shows; the
                  // clock stays underneath as what a failed load shows, and
                  // "Coming soon" stays on top, so the card is honest about
                  // the film and still looks like one. Kept for revert: the
                  // Center(Icon(Icons.schedule_rounded)) alone.
                  Center(
                    child: Icon(Icons.schedule_rounded,
                        size: 30,
                        color: HSLColor.fromColor(tint)
                            .withSaturation(0.42)
                            .withLightness(0.36)
                            .toColor()),
                  ),
                  if (pvFilmStillFor(film.id) case final still?)
                    Positioned.fill(
                      child: Image.network(still,
                          key: ValueKey('ttc_learn_film_still_${film.id}'),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, _, _) => const SizedBox.shrink()),
                    ),
                  Positioned(left: 8, top: 8, child: _Pill(label: coming)),
                  if (film.isLive)
                    Positioned(right: 8, bottom: 8, child: _Pill(label: meta)),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(film.title.en,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: p.ink1)),
          const SizedBox(height: 3),
          Text(film.why.en,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(fontSize: 12, height: 1.4, color: p.ink2)),
          if (onNotes != null)
            // The one tappable part of a film that is not made yet: its
            // notes, which exist today. A 44pt target.
            InkWell(
              key: ValueKey('ttc_learn_notes_${film.id}'),
              onTap: () {
                pvCommitFeedback();
                onNotes!();
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  // Names whose notes (2026-09-28, explicit names). Kept for
                  // revert: 'Read the notes', maxLines: 1.
                  Flexible(
                    child: Text("Read the film's notes",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: p.ink1)),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 17, color: p.ink1),
                ]),
              ),
            ),
        ]);
  }
}

// Kept for revert (L8): the film search row, retired with the Learn-only engine.
// class _FilmRow extends StatelessWidget {
//   const _FilmRow({required this.film, required this.meta, required this.onTap});
//   final PvVideoSlot film;
//   final String meta;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final p = pvStorePalette;
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
//         child: Row(children: [
//           _Thumb(hue: film.hue, icon: Icons.play_circle_outline_rounded),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(film.title.en,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: pvManrope(
//                       fontSize: 14.5,
//                       fontWeight: FontWeight.w700,
//                       height: 1.3,
//                       color: p.ink1)),
//               const SizedBox(height: 4),
//               Text(meta,
//                   style: pvManrope(
//                       fontSize: 11.5,
//                       fontWeight: FontWeight.w700,
//                       color: p.ink3)),
//             ]),
//           ),
//           Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
//         ]),
//       ),
//     );
//   }
// }

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: pvStorePalette.ink1)),
      );
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.tile, required this.hue, required this.onTap});
  final TtcTile tile;
  final double hue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final tint = v2BlockTint(hue, p);
    final myth = tile is TtcMythTile;
    return PvPress(
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: kPvLine)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 210,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: tint, borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                          myth
                              ? Icons.balance_rounded
                              : Icons.view_carousel_outlined,
                          size: 15,
                          color: _wellInk(tint)),
                    ),
                    const SizedBox(width: 8),
                    // One name for one kind (2026-09-28): the doors say
                    // "Myth vs fact". Kept for revert: 'Myth or fact'.
                    // Flexible (2026-09-29, 1.5x on 360dp). Kept for
                    // revert: the Text without Flexible, maxLines or
                    // overflow.
                    Flexible(
                      child: Text(myth ? 'Myth vs fact' : 'Story',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: p.ink2)),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  // L11: the Manrope card title, one card language on the
                  // page. Was pvFraunces(fontSize: 16, w500, height 1.25).
                  Text(tile.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: p.ink1)),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(tile.blurb,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 12.5, height: 1.4, color: p.ink2)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.view, required this.onTap});
  final PvOfferingView view;
  final VoidCallback onTap;

  static String _kind(PvLearnKind k) => switch (k) {
        PvLearnKind.course => 'Course',
        PvLearnKind.masterclass => 'Masterclass',
        PvLearnKind.cohort => 'Group programme',
        PvLearnKind.consult => 'Consultation',
        PvLearnKind.classPack => 'Classes',
      };

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final tint = v2BlockTint(view.hue, p);
    final cover = Container(
      color: tint,
      alignment: Alignment.center,
      child: Icon(Icons.school_outlined, size: 28, color: _wellInk(tint)),
    );
    final minutes = view.totalMinutes;
    final meta = [
      _kind(view.kind),
      if (view.lessons.isNotEmpty) '${view.lessons.length} lessons',
      if (view.lessons.isEmpty && minutes > 0) '$minutes min',
      view.priceLabel,
    ].join(' · ');
    return PvPress(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 220,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: view.cover == null
                    ? cover
                    : Image.network(view.cover!,
                        fit: BoxFit.cover, errorBuilder: (_, _, _) => cover),
              ),
            ),
            const SizedBox(height: 10),
            Text(view.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: p.ink1)),
            const SizedBox(height: 3),
            Text(meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                    fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink3)),
          ]),
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
    required this.from,
    required this.open,
    required this.last,
    required this.onToggle,
    required this.onOpenRead,
  });
  final String question;
  final String answer;
  final String from;
  final bool open;
  final bool last;
  final VoidCallback onToggle;
  final VoidCallback onOpenRead;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Container(
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: kPvLine)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PvPress(
          child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(question,
                    style: pvManrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: p.ink1)),
              ),
              const SizedBox(width: 10),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 22, color: p.ink2),
              ),
            ]),
          ),
        )),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: open
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(answer,
                            style: pvManrope(
                                fontSize: 14, height: 1.55, color: p.ink2)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: onOpenRead,
                          child: Padding(
                            // 44pt target (was a 4pt pad, about 24pt).
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Flexible(
                                child: Text(from,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: pvManrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: ttcTitleInk)),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 15, color: ttcTitleInk),
                            ]),
                          ),
                        ),
                      ]),
                )
              : const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }
}

/// The numbered circle of a "Start here" step, ticked once read. The row
/// around it is the shared `PvListRow`.
class _StepMark extends StatelessWidget {
  const _StepMark({required this.n, required this.done});
  final int n;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return SizedBox(
      width: 40,
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? ttcTitleInk : Colors.white,
            border: Border.all(color: done ? ttcTitleInk : p.ink3, width: 1.3),
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Text('$n',
                  style: pvManrope(
                      fontSize: 13, fontWeight: FontWeight.w800, color: p.ink1)),
        ),
      ),
    );
  }
}
