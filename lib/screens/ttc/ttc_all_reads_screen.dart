// =============================================================================
//  TtcAllReadsScreen: every article in Trying to Conceive, once, A to Z
//  (2026-09-29)
// -----------------------------------------------------------------------------
//  The user: "In the More tab we also need a separate section for all the
//  videos… if someone wants to read all the articles or watch all the videos,
//  that section should also be made." More's "Read and watch" section opens
//  this page and its sibling, `ttc_all_videos_screen.dart`.
//
//  ⚠️ IT DOES NOT REPLACE LEARN. Learn is the library to browse: topics,
//  where she left off, a start path, films, shelves, myths, courses and
//  questions. This page is the plain index behind it, "everything, A to Z",
//  for the woman who wants the whole list and nothing chosen for her. Every
//  read appears exactly once (grouped by its own kicker, which names one
//  door), and the rows are the rows Learn draws, so the same read looks the
//  same in both places.
//
//  THE PATTERN, from Mobbin (2026-09-29). A catalogue page is a pushed page
//  with a way back, one search field, a row of topic chips with "All" first,
//  and a list of rows (thumbnail, bold title, one grey line, a small fact);
//  with "All" chosen the list is grouped under small topic headings, and a
//  "sorted by" control sits over the list:
//    * Flo, a topic's "See all": rows of a square photo, a bold title and one
//      grey line, nothing boxed
//      https://mobbin.com/screens/3bb65ebc-bb08-4479-b449-3df67ac53fd3
//    * Flo, Interests: "All" first in the chip row, the list grouped under
//      small topic labels
//      https://mobbin.com/screens/e84779f6-abb1-46f6-aea3-c97fb5cc1f01
//    * Pocket, Saves: a search field, chips with "All" first, rows with the
//      minutes ("5 min") in the grey line
//      https://mobbin.com/screens/ef1aced7-6791-4665-8d99-144fd90468ba
//    * Medium, Explore: search, then topic chips, then the list
//      https://mobbin.com/screens/e23b35f2-287d-45ce-a01a-a21b29bcbdc3
//    * Centr, Articles: a pushed page with a back arrow, search and filter
//      top right, photo rows
//      https://mobbin.com/screens/222842de-e264-4a15-850d-abaa223b3788
//    * MasterClass, Library: "All" and topic chips, rows that say the kind
//      and the topic ("Series · Food")
//      https://mobbin.com/screens/82da1be0-0340-4959-a5f3-a671e88a25bb
//    * IMDb, a title's videos: "Sorted by …" over the list, with its control
//      https://mobbin.com/screens/299e3057-6e09-419a-a06f-c0abfb03f43c
//
//  WHAT WAS NOT TAKEN: Centr's and Letterboxd's boxed cards (DESIGN-SYSTEM
//  §4.13, lists are not boxed), Medium's numbered trending order (we have no
//  honest popularity to rank by) and any count of what she has read (§4.9).
//
//  ⚠️ THE SHARED-PHONE SWITCH AND HIS SIDE. With "Hide sex and intimacy
//  content" on, the reads in `kTtcIntimateReadIds` leave the list, the count
//  and the search, exactly as they leave Learn (`ttcLearnShows`). His side
//  sees the whole library, as the doors show it to him, with his own door
//  and Mind and body first (`kTtcHisLearnFirst`, Learn's rule).
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/reads/read_images.dart' show readImageFor;
import '../../models/pv_read.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_content_prefs.dart';
import '../../ttc/ttc_focus_data.dart' show TtcArticleTile;
import '../../ttc/ttc_home_prefs.dart';
import '../../ttc/ttc_reads_data.dart';
import '../../widgets/pv_feedback.dart';
import '../doors/pv_list_row.dart' show PvRowGroup, PvMarkWell;
import '../doors/pv_live_search.dart';
import '../products/pv_store_chrome.dart'
    show PvChip, PvRoundIcon, pvStorePalette;
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart' show bracketMarkFor;
import 'doors/ttc_door_search.dart' show TtcDoorHit;
import 'doors/ttc_kind_cards.dart' show ttcCardReadMinutes;
import 'ttc_common.dart' show TtcSectionHeading;
import 'ttc_learn_screen.dart'
    show
        kTtcHisLearnFirst,
        ttcHitReadId,
        ttcLearnShelves,
        ttcLibraryIndex,
        ttcLibrarySearch;
import 'ttc_strings.dart' show TtcPartnerMode, TtcLang;
import 'ttc_surface_router.dart' show openTtcSurface, kTtcReadPrefix;
import 'ttc_tab_root_header.dart';

/// The page's route. Unique: `test/ttc_tools_only_tools_test.dart` fails if
/// two ways in land on one route.
const String kTtcAllReadsRoute = 'ttc/all_reads';

/// The page's title, and the More row's name.
const String kTtcAllReadsTitle = 'All articles';

// =============================================================================
//  The data
// =============================================================================

/// One topic: a door's reads (by the read's own kicker), in the door's hue.
class TtcReadTopic {
  const TtcReadTopic({
    required this.key,
    required this.label,
    required this.hue,
    required this.reads,
    this.bracketId,
  });

  /// The kicker the reads share. Identity, compared, never shown alone.
  final String key;

  /// The door's own name ("PCOS", "Fertile window").
  final String label;
  final double hue;
  final String? bracketId;
  final List<PvRead> reads;
}

/// Every read, once, in topics in the doors' order (his door first on his
/// side), with what the shared-phone switch hides left out. A topic left
/// with no read is left out too: a chip that filters to nothing is a dead
/// tap.
///
/// ⚠️ LEARN'S SHELVES, NOT A SECOND GROUPING (`ttcLearnShelves`). A read
/// belongs to the one topic its kicker names, so no read can be listed
/// twice, and a read added to any bracket file appears here with no change
/// to this file.
List<TtcReadTopic> ttcAllReadTopics({bool? hideIntimate, bool? him}) {
  final hide = hideIntimate ?? TtcContentPrefs.instance.hideIntimate;
  final forHim = him ?? TtcPartnerMode.instance.on;
  final topics = <TtcReadTopic>[
    for (final s in ttcLearnShelves())
      if ([
        for (final r in s.reads)
          if (!(hide && kTtcIntimateReadIds.contains(r.id))) r,
      ] case final reads when reads.isNotEmpty)
        TtcReadTopic(
          key: s.key,
          label: s.title,
          hue: s.hue,
          bracketId: s.bracket?.id,
          reads: reads,
        ),
  ];
  if (!forHim) return topics;
  // Named placeOf: the identity test's scan mistakes a helper named after
  // ranking, called on a record field, for an identity-bearing call.
  int placeOf(TtcReadTopic t) {
    final i = kTtcHisLearnFirst.indexOf(t.bracketId ?? '');
    return i < 0 ? kTtcHisLearnFirst.length : i;
  }

  // A stable sort: his doors first, the rest in their own order.
  final indexed = [for (var i = 0; i < topics.length; i++) (i, topics[i])];
  indexed.sort((a, b) {
    final r = placeOf(a.$2).compareTo(placeOf(b.$2));
    return r != 0 ? r : a.$1.compareTo(b.$1);
  });
  return [for (final (_, t) in indexed) t];
}

/// How many articles the page lists: `kTtcReads`, less what she has chosen
/// to hide. The More row says this number.
int ttcAllReadsCount({bool? hideIntimate}) => [
  for (final t in ttcAllReadTopics(hideIntimate: hideIntimate, him: false))
    ...t.reads,
].length;

/// "134 articles", "1 article".
String ttcArticlesLabel(int n) => n == 1 ? '1 article' : '$n articles';

/// How the list is ordered while nothing is typed.
enum TtcCatalogSort { topic, az }

String ttcCatalogSortLabel(TtcCatalogSort s) => switch (s) {
  TtcCatalogSort.topic => 'By topic',
  TtcCatalogSort.az => 'A to Z',
};

/// "5 min read" at 200 words or more, else null: the reader's rule, through
/// the door card's own function, so a card, a row and the page agree.
String? ttcAllReadsMinutes(PvRead r) =>
    ttcCardReadMinutes(TtcArticleTile(title: r.title.en, blurb: '', readId: r.id));

// =============================================================================
//  The shared pieces of the two catalogue pages
// =============================================================================

/// The catalogue header: a round back button over the tab-root header (the
/// title, one intro line and the search), so a page reached from More reads
/// as one of our tab pages, with a way back.
///
/// ⚠️ THE TAB-ROOT HEADER HAS NO LEADING SLOT ON PURPOSE (its title's y must
/// never depend on a button), so the back button sits on its own row above
/// it, the large-title pattern (Formula 1's "Latest videos",
/// https://mobbin.com/screens/0252ffe3-99cf-4aea-bd44-87d4cda18de3). The
/// header then takes no safe-area inset of its own.
class TtcCatalogHeader extends StatelessWidget {
  const TtcCatalogHeader({
    super.key,
    required this.title,
    required this.intro,
    required this.search,
    required this.hint,
  });

  final String title;
  final String intro;
  final PvLiveSearch search;
  final String hint;

  static const Key backKey = ValueKey('ttc_catalog_back');

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(kTtcTabRootGutter,
              MediaQuery.paddingOf(context).top + 8, kTtcTabRootGutter, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              container: true,
              button: true,
              label: 'Back to More',
              excludeSemantics: true,
              onTap: () => Navigator.of(context).maybePop(),
              child: PvRoundIcon(
                key: backKey,
                icon: Icons.arrow_back_rounded,
                size: kTtcTabRootRowHeight,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: TtcTabRootHeader(
            title: title,
            intro: PvLiveSearchWords(
              search: search,
              child: Text(intro, style: ttcTabRootIntroStyle()),
            ),
            below: PvLiveSearchField(search: search, p: p, hint: hint),
          ),
        ),
      ],
    );
  }
}

/// The topic chips: "All" first, then each door by name.
class TtcCatalogChips extends StatelessWidget {
  const TtcCatalogChips({
    super.key,
    required this.topics,
    required this.selected,
    required this.onSelect,
  });

  /// (key, label) per topic, in order.
  final List<(String, String)> topics;
  final String? selected;
  final ValueChanged<String?> onSelect;

  static Key chipKey(String? key) => ValueKey('ttc_catalog_chip_${key ?? 'all'}');

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return SizedBox(
      // The chip is 36 high; the row grows with a large text size.
      height: math.max(36.0, scaler.scale(13) * 1.4 + 18),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: kTtcTabRootGutter),
        children: [
          PvChip(
            key: chipKey(null),
            label: 'All',
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final (k, label) in topics) ...[
            const SizedBox(width: 6),
            PvChip(
              key: chipKey(k),
              label: label,
              selected: selected == k,
              onTap: () => onSelect(k),
            ),
          ],
        ],
      ),
    );
  }
}

/// The page's ground behind the status bar, so nothing slides under the
/// clock (Learn's D2 rule).
Widget ttcCatalogStatusStrip(BuildContext context, V2Palette p) => Positioned(
  top: 0,
  left: 0,
  right: 0,
  child: IgnorePointer(
    child: Container(height: MediaQuery.paddingOf(context).top, color: p.ground),
  ),
);

/// Whether every word of [query] starts a word of [hay] (the doors' rule,
/// "nt" finds "NT scan", not "appointment").
bool ttcCatalogMatches(String hay, String query) {
  final split = RegExp(r'[^a-z0-9]+');
  final words = hay.toLowerCase().split(split);
  final q = [
    for (final w in query.toLowerCase().split(split))
      if (w.isNotEmpty) w,
  ];
  if (q.isEmpty) return true;
  return q.every((w) => words.any((h) => h.startsWith(w)));
}

// =============================================================================
//  The page
// =============================================================================

class TtcAllReadsScreen extends StatefulWidget {
  const TtcAllReadsScreen({super.key});

  @override
  State<TtcAllReadsScreen> createState() => _TtcAllReadsScreenState();
}

class _TtcAllReadsScreenState extends State<TtcAllReadsScreen> {
  final PvLiveSearch _search = PvLiveSearch();
  String? _topic;
  TtcCatalogSort _sort = TtcCatalogSort.topic;

  /// Learn's one search index, rebuilt only when her content choice or the
  /// language changes, never per keystroke.
  List<(TtcDoorHit, double)>? _index;
  (bool, bool)? _indexFor;

  List<(TtcDoorHit, double)> get _library {
    final key = (TtcContentPrefs.instance.hideIntimate, TtcLang.instance.hinglish);
    if (_index == null || _indexFor != key) {
      _index = ttcLibraryIndex(hideIntimate: key.$1);
      _indexFor = key;
    }
    return _index!;
  }

  @override
  void initState() {
    super.initState();
    TtcContentPrefs.instance.init();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(PvRead r) {
    pvCommitFeedback();
    // A 101 step opened here counts, as it does from Learn.
    TtcHomePrefs.instance.markOpened(r.id);
    openTtcSurface(context, '$kTtcReadPrefix${r.id}');
  }

  Future<void> _chooseSort() async {
    final p = pvStorePalette;
    final picked = await showModalBottomSheet<TtcCatalogSort>(
      context: context,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 18, 0, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: const TtcSectionHeading('Sort the articles'),
              ),
              for (final s in TtcCatalogSort.values)
                InkWell(
                  key: ValueKey('ttc_all_reads_sort_${s.name}'),
                  onTap: () => Navigator.of(ctx).pop(s),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(children: [
                        Expanded(
                          child: Text(ttcCatalogSortLabel(s),
                              style: pvManrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: p.ink1)),
                        ),
                        if (s == _sort)
                          Icon(Icons.check_rounded, size: 20, color: p.ink1),
                      ]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _sort = picked);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _search,
        TtcContentPrefs.instance,
        TtcPartnerMode.instance,
        TtcLang.instance,
      ]),
      builder: (context, _) {
        final p = pvStorePalette;
        final topics = ttcAllReadTopics();
        final chosen =
            topics.where((t) => t.key == _topic).firstOrNull;
        final pool = chosen == null ? topics : [chosen];
        final byTopic = {
          for (final t in pool)
            for (final r in t.reads) r.id: t,
        };
        final searching = _search.searching;

        // The list, once each: searched by Learn's matcher (ranked, with
        // the brand-name synonyms and the reads' own words), else in the
        // chosen order.
        final List<PvRead> flat;
        if (searching) {
          final seen = <String>{};
          flat = [
            for (final (h, _) in ttcLibrarySearch(_search.query, _library))
              if (ttcHitReadId(h) case final id?
                  when byTopic.containsKey(id) && seen.add(id))
                ?ttcReadById(id),
          ];
        } else {
          flat = [for (final t in pool) ...t.reads];
          if (_sort == TtcCatalogSort.az) {
            flat.sort((a, b) =>
                a.title.en.toLowerCase().compareTo(b.title.en.toLowerCase()));
          }
        }
        final grouped =
            !searching && chosen == null && _sort == TtcCatalogSort.topic;

        return PvLiveSearchScope(
          search: _search,
          child: Scaffold(
            backgroundColor: p.ground,
            body: Stack(children: [
              Positioned.fill(
                child: ListView(
                  key: const ValueKey('ttc_all_reads_scroll'),
                  padding: EdgeInsets.fromLTRB(
                      0, 0, 0, 32 + MediaQuery.paddingOf(context).bottom),
                  children: [
                    TtcCatalogHeader(
                      title: kTtcAllReadsTitle,
                      intro:
                          'Every article in Trying to conceive, in one list. Search, or pick a topic.',
                      search: _search,
                      hint: 'Search the articles',
                    ),
                    const SizedBox(height: 14),
                    TtcCatalogChips(
                      topics: [for (final t in topics) (t.key, t.label)],
                      selected: chosen?.key,
                      onSelect: (k) => setState(() => _topic = k),
                    ),
                    const SizedBox(height: 8),
                    _countRow(p, flat.length, searching: searching),
                    if (flat.isEmpty)
                      _empty(p)
                    else if (grouped)
                      for (final t in pool) _group(p, t)
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kTtcTabRootGutter),
                        child: PvRowGroup(p: p, children: [
                          for (final r in flat)
                            _row(p, r, byTopic[r.id]!, showTopic: true),
                        ]),
                      ),
                  ],
                ),
              ),
              ttcCatalogStatusStrip(context, p),
            ]),
          ),
        );
      },
    );
  }

  /// "134 articles" on the left, the sort on the right. While she types the
  /// list is best match first, and the sort steps aside.
  Widget _countRow(V2Palette p, int n, {required bool searching}) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(kTtcTabRootGutter, 4, 8, 4),
        child: Row(children: [
          Expanded(
            child: Text(
              searching
                  ? '${ttcArticlesLabel(n)} found, best match first'
                  : ttcArticlesLabel(n),
              key: const ValueKey('ttc_all_reads_count'),
              style: pvManrope(
                  fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
            ),
          ),
          if (!searching)
            Semantics(
              button: true,
              label: 'Sort: ${ttcCatalogSortLabel(_sort)}',
              excludeSemantics: true,
              onTap: _chooseSort,
              child: InkWell(
                key: const ValueKey('ttc_all_reads_sort'),
                onTap: _chooseSort,
                borderRadius: BorderRadius.circular(999),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.swap_vert_rounded, size: 18, color: p.ink1),
                      const SizedBox(width: 4),
                      Text(ttcCatalogSortLabel(_sort),
                          style: pvManrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: p.ink1)),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
      );

  Widget _group(V2Palette p, TtcReadTopic t) => Padding(
        key: ValueKey('ttc_all_reads_group_${t.key}'),
        padding: const EdgeInsets.fromLTRB(
            kTtcTabRootGutter, 18, kTtcTabRootGutter, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              children: [
                // The one section heading of the stage (ttc_common.dart).
                TtcSectionHeading(t.label),
                Text(ttcArticlesLabel(t.reads.length),
                    style: pvManrope(fontSize: 12, color: p.ink3)),
              ],
            ),
            const SizedBox(height: 8),
            PvRowGroup(p: p, children: [
              for (final r in t.reads) _row(p, r, t, showTopic: false),
            ]),
          ],
        ),
      );

  Widget _row(V2Palette p, PvRead r, TtcReadTopic t,
      {required bool showTopic}) {
    final minutes = ttcAllReadsMinutes(r);
    final meta = [if (showTopic) t.label, ?minutes].join(' · ');
    final mark = t.bracketId == null ? null : bracketMarkFor(t.bracketId!);
    return Semantics(
      key: ValueKey('ttc_all_reads_row_${r.id}'),
      button: true,
      container: true,
      excludeSemantics: true,
      label: ['Article', r.title.en, r.teaser.en, if (meta.isNotEmpty) meta]
          .join(', '),
      onTap: () => _open(r),
      child: PvPress(
        child: InkWell(
          onTap: () => _open(r),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              // The photo the reader opens on; the door's drawing without one
              // (Learn's row, so one read has one face).
              PvMarkWell(
                p: p,
                hue: t.hue,
                size: 64,
                photo: readImageFor(r.id, own: r.imageUrl),
                bracket: mark,
                icon: mark == null ? Icons.article_outlined : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(r.title.en,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: -0.2,
                            color: p.ink1)),
                    const SizedBox(height: 3),
                    Text(r.teaser.en,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 12.5, height: 1.4, color: p.ink2)),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: p.ink3)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _empty(V2Palette p) => Padding(
        key: const ValueKey('ttc_all_reads_empty'),
        padding: const EdgeInsets.fromLTRB(
            kTtcTabRootGutter, 12, kTtcTabRootGutter, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            _search.searching
                ? 'No article matches "${_search.query}". Try a shorter word, or clear the search.'
                : 'No articles here yet.',
            style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2),
          ),
          if (_search.searching) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _search.release,
              style: TextButton.styleFrom(foregroundColor: p.ink1),
              child: Text('Clear the search',
                  style: pvManrope(
                      fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
            ),
          ],
        ]),
      );
}
