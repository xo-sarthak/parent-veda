// =============================================================================
//  TtcAllVideosScreen: every film in Trying to Conceive, once (2026-09-29)
// -----------------------------------------------------------------------------
//  The sibling of `ttc_all_reads_screen.dart`, from More's "Read and watch"
//  section (the user: "if someone wants to read all the articles or watch all
//  the videos, that section should also be made").
//
//  ⚠️ HONEST ABOUT WHAT EXISTS. No Trying to conceive film is made yet
//  (`PvVideoSlot.isLive` is false for every slot), so the page says so at the
//  top, in one quiet line, and every film wears the door card's "Coming soon"
//  with a clock. A play button and a length are drawn ONLY on a film that
//  plays (`TtcKindCard`, launch sanity D3), so the day a film gets its file it
//  gets its play button here with no change to this page.
//
//  WHICH FILMS: every video tile on every door (a film on two doors is listed
//  once, under the door its slot's hue names, else the first), then every film slot in
//  `kTtcVideos` that no door shows (they head reads), under the door of the
//  first read it points to. A tap opens exactly what the door's own tile
//  opens today (`openTtcFocusTile`: the film's sheet, with its notes to read
//  now); a slot-only film opens the same sheet through a tile made from it.
//
//  THE CARD is the door's video card (`TtcKindCard`, rose ground, "Video"
//  pill, the still), one to a row at the content width with a 16:9 picture,
//  so a film here looks like the film on its door. Its caption names the
//  door first. Mobbin (2026-09-29):
//    * Formula 1, Latest videos: a back arrow over a large title, chips with
//      "All" first, one full-width 16:9 still per film, the title under it
//      https://mobbin.com/screens/0252ffe3-99cf-4aea-bd44-87d4cda18de3
//    * Weverse, a series' videos: 16:9 thumbnails with the length on the
//      picture https://mobbin.com/screens/c0af3e6f-2245-4818-9528-3f3ee1fbe46f
//    * Flo, Birth control 101: the length on each still, the play mark only
//      on what plays https://mobbin.com/screens/886a1e54-5883-4144-b966-d9053c3ef5b1
//    * pliability, Find a session: filter chips over a list of stills
//      https://mobbin.com/screens/5ae5e3fb-1463-4251-8710-f1f837ed566e
//    * MasterClass, Library: "All" and topic chips over the catalogue
//      https://mobbin.com/screens/82da1be0-0340-4959-a5f3-a671e88a25bb
//  No sort control here: with every film unmade there is no length or date
//  to sort by, and a sort that changes nothing is noise. Films that play
//  will lead the list when there are any.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/brackets/ttc_brackets.dart' show kTtcBrackets;
import '../../data/reads/read_images.dart' show kPvFilmStills;
import '../../models/bracket.dart';
import '../../models/pv_video_slot.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_content_prefs.dart';
import '../../ttc/ttc_focus_data.dart';
import '../../ttc/ttc_reads_data.dart' show ttcReadById;
import '../../ttc/ttc_videos_data.dart';
import '../../widgets/pv_feedback.dart';
import '../doors/pv_live_search.dart';
import '../products/pv_store_chrome.dart' show pvStorePalette;
import '../v2/v2_palette.dart';
import 'doors/ttc_door_screen.dart' show ttcDoorVisiblePage;
import 'doors/ttc_kind_cards.dart';
import 'ttc_all_reads_screen.dart'
    show
        TtcCatalogChips,
        TtcCatalogHeader,
        ttcCatalogMatches,
        ttcCatalogStatusStrip;
import 'ttc_focus_screen.dart' show openTtcFocusTile;
import 'ttc_learn_screen.dart' show kTtcHisLearnFirst;
import 'ttc_strings.dart' show TtcPartnerMode;
import 'ttc_tab_root_header.dart';

/// The page's route. Unique across the bar, Tools and More.
const String kTtcAllVideosRoute = 'ttc/all_videos';

/// The page's title, and the More row's name.
const String kTtcAllVideosTitle = 'All videos';

/// What the page says at the top while no film is made.
const String kTtcFilmsBeingMade =
    "Our films are being made. Here's what's coming and the notes you can read now.";

/// One film on the page.
class TtcFilmEntry {
  const TtcFilmEntry({required this.tile, required this.hue, this.door});

  /// The door's own tile, or one made from the slot for a film no door
  /// shows. Opened through `openTtcFocusTile`, as the door opens it.
  final TtcVideoTile tile;

  /// The door the film belongs to, or null.
  final Bracket? door;

  /// The door's hue, for the sheet the tap opens.
  final double hue;

  String get slotId => tile.slotId;
  PvVideoSlot? get slot => ttcVideoBySlot(tile.slotId);

  /// Whether the film exists and plays.
  bool get live => slot?.isLive ?? false;

  String get doorLabel => door?.label.en ?? 'Trying to conceive';

  /// What search matches: the title, the promise, the door, and what the
  /// film will say.
  String get words => [
    tile.title,
    tile.blurb,
    doorLabel,
    ...tile.keywords,
    if (slot case final s?) ...[
      s.why.en,
      for (final t in s.takeaways) t.en,
      for (final c in s.chapters) c.label.en,
    ],
  ].join(' ');
}

Bracket? _bracketOfRead(String readId) {
  final r = ttcReadById(readId);
  if (r == null) return null;
  for (final b in kTtcBrackets) {
    if (b.label.en == r.kicker.en) return b;
  }
  return null;
}

/// Every film, once, in the doors' order (his door first on his side),
/// films that play before films that do not.
List<TtcFilmEntry> ttcAllFilms({bool? hideIntimate, bool? him}) {
  final hide = hideIntimate ?? TtcContentPrefs.instance.hideIntimate;
  final forHim = him ?? TtcPartnerMode.instance.on;
  final brackets = !forHim
      ? kTtcBrackets
      : [
          for (final id in kTtcHisLearnFirst)
            ...kTtcBrackets.where((b) => b.id == id),
          for (final b in kTtcBrackets)
            if (!kTtcHisLearnFirst.contains(b.id)) b,
        ];
  // Every door's films, in the doors' order.
  final onDoors = <TtcFilmEntry>[];
  for (final b in brackets) {
    final page = ttcFocusPageFor(b.id);
    if (page == null) continue;
    // The door as she sees it, so the switch hides here what it hides there.
    for (final s in ttcDoorVisiblePage(page, hideIntimate: hide).sections) {
      for (final t in s.tiles) {
        if (t is TtcVideoTile) {
          onDoors.add(TtcFilmEntry(tile: t, door: b, hue: b.hue));
        }
      }
    }
  }
  // ⚠️ A FILM ON TWO DOORS IS LISTED ONCE, UNDER ITS OWN DOOR: the one whose
  // hue the film's slot carries (`kTtcVideos`: "hues match the bracket each
  // film belongs to"), else the first. The first render put "Three things
  // that really change his numbers" under Fertile window, the first door in
  // order, when the film is His side's.
  TtcFilmEntry home(String slotId) {
    final all = [for (final e in onDoors) if (e.slotId == slotId) e];
    final hue = ttcVideoBySlot(slotId)?.hue;
    return all.where((e) => e.door?.hue == hue).firstOrNull ?? all.first;
  }

  final seen = <String>{};
  final out = <TtcFilmEntry>[
    for (final e in onDoors)
      if (identical(home(e.slotId), e) && seen.add(e.slotId)) e,
  ];
  for (final v in kTtcVideos) {
    if (!seen.add(v.id)) continue;
    final door = [
      for (final id in v.readNext) ?_bracketOfRead(id),
    ].firstOrNull;
    out.add(TtcFilmEntry(
      tile: TtcVideoTile(
        title: v.title.en,
        blurb: v.why.en,
        slotId: v.id,
        duration: '${(v.seconds / 60).ceil()} MIN',
        // ⚠️ THE STILL'S KEY AS THE TILE'S ID: `photoForTile` finds a tile's
        // photo by its id, and a film no door shows has its still filed
        // under `kPvFilmStills` (read_images.dart). One film, one face.
        id: kPvFilmStills[v.id],
      ),
      door: door,
      hue: door?.hue ?? v.hue,
    ));
  }
  // Films that play first; otherwise the order above.
  final indexed = [for (var i = 0; i < out.length; i++) (i, out[i])];
  indexed.sort((a, b) {
    final l = (a.$2.live ? 0 : 1).compareTo(b.$2.live ? 0 : 1);
    return l != 0 ? l : a.$1.compareTo(b.$1);
  });
  return [for (final (_, e) in indexed) e];
}

/// The More row's line: "17 videos, coming soon" while none is made,
/// "3 to watch, 14 coming soon" when some are, "17 videos" when all are.
String ttcAllVideosLine({bool? hideIntimate}) {
  final films = ttcAllFilms(hideIntimate: hideIntimate, him: false);
  final live = films.where((f) => f.live).length;
  final n = films.length;
  final videos = n == 1 ? '1 video' : '$n videos';
  if (live == 0) return '$videos, coming soon';
  if (live == n) return videos;
  return '$live to watch, ${n - live} coming soon';
}

class TtcAllVideosScreen extends StatefulWidget {
  const TtcAllVideosScreen({super.key});

  @override
  State<TtcAllVideosScreen> createState() => _TtcAllVideosScreenState();
}

class _TtcAllVideosScreenState extends State<TtcAllVideosScreen> {
  final PvLiveSearch _search = PvLiveSearch();
  String? _door;

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

  void _open(TtcFilmEntry f) {
    pvCommitFeedback();
    openTtcFocusTile(context, f.tile, f.hue);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _search,
        TtcContentPrefs.instance,
        TtcPartnerMode.instance,
      ]),
      builder: (context, _) {
        final p = pvStorePalette;
        final films = ttcAllFilms();
        final doors = <(String, String)>[];
        for (final f in films) {
          final d = f.door;
          if (d != null && !doors.any((x) => x.$1 == d.id)) {
            doors.add((d.id, d.label.en));
          }
        }
        final door = doors.any((d) => d.$1 == _door) ? _door : null;
        final shown = [
          for (final f in films)
            if ((door == null || f.door?.id == door) &&
                ttcCatalogMatches(f.words, _search.query))
              f,
        ];
        final noneLive = !films.any((f) => f.live);
        return PvLiveSearchScope(
          search: _search,
          child: Scaffold(
            backgroundColor: p.ground,
            body: Stack(children: [
              Positioned.fill(
                child: ListView(
                  key: const ValueKey('ttc_all_videos_scroll'),
                  padding: EdgeInsets.fromLTRB(
                      0, 0, 0, 32 + MediaQuery.paddingOf(context).bottom),
                  children: [
                    TtcCatalogHeader(
                      title: kTtcAllVideosTitle,
                      intro:
                          'Every film in Trying to conceive, in one list. Search, or pick a topic.',
                      search: _search,
                      hint: 'Search the videos',
                    ),
                    const SizedBox(height: 14),
                    TtcCatalogChips(
                      topics: doors,
                      selected: door,
                      onSelect: (k) => setState(() => _door = k),
                    ),
                    const SizedBox(height: 12),
                    if (noneLive) _beingMade(p),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          kTtcTabRootGutter, 4, kTtcTabRootGutter, 10),
                      child: Text(
                        _search.searching
                            ? '${_videos(shown.length)} found'
                            : _videos(shown.length),
                        key: const ValueKey('ttc_all_videos_count'),
                        style: pvManrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: p.ink2),
                      ),
                    ),
                    if (shown.isEmpty)
                      Padding(
                        key: const ValueKey('ttc_all_videos_empty'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: kTtcTabRootGutter),
                        child: Text(
                          'No video matches "${_search.query}". Try a shorter word, or clear the search.',
                          style: pvManrope(
                              fontSize: 14, height: 1.45, color: p.ink2),
                        ),
                      )
                    else
                      LayoutBuilder(builder: (context, box) {
                        final w = box.maxWidth - 2 * kTtcTabRootGutter;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: kTtcTabRootGutter),
                          child: Column(children: [
                            for (var i = 0; i < shown.length; i++) ...[
                              if (i > 0) const SizedBox(height: 14),
                              _card(p, shown[i], w),
                            ],
                          ]),
                        );
                      }),
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

  static String _videos(int n) => n == 1 ? '1 video' : '$n videos';

  /// One quiet line, no panel behind it (a tinted slab behind a note is
  /// noise, the user 2026-09-29).
  Widget _beingMade(V2Palette p) => Padding(
        key: const ValueKey('ttc_all_videos_being_made'),
        padding:
            const EdgeInsets.fromLTRB(kTtcTabRootGutter, 0, kTtcTabRootGutter, 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.schedule_rounded, size: 18, color: p.ink2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(kTtcFilmsBeingMade,
                style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink1)),
          ),
        ]),
      );

  /// The door's video card at the content width, a 16:9 picture, the door
  /// named first in its caption.
  Widget _card(V2Palette p, TtcFilmEntry f, double width) {
    // Kept for revert (2026-09-30), the tile the kind card drew:
    // ignore: unused_local_variable
    final shown = TtcVideoTile(
      title: f.tile.title,
      blurb: '${f.doorLabel} · ${f.tile.blurb}',
      slotId: f.tile.slotId,
      duration: f.tile.duration,
      // Same id, so the same photo as the door's card.
      id: f.tile.id,
    );
    // ⚠️ THE DOOR'S NEW CARD, WIDE (2026-09-30, the user: "a random overlay…
    // a background behind each video that is red in colour", and "a circle
    // in which there is a play triangle, so it is very evident it's a
    // video"). The old kind card painted every film on the video rose. Now
    // the shelf card at the content width, 16:9, its door's calm colour, the
    // veil, a black play circle and its length, then the title and the door
    // with the watch time. Kept for revert:
    //   TtcKindCard(tile: shown, kind: TtcCardKind.video, p: p, width: width,
    //     imageHeight: ((width - 12) * 9 / 16).roundToDouble(),
    //     onTap: () => _open(f)),
    return KeyedSubtree(
      key: ValueKey('ttc_all_videos_row_${f.slotId}'),
      child: TtcShelfCard(
        tile: f.tile,
        kind: TtcCardKind.video,
        p: p,
        hue: f.hue,
        width: width,
        pictureHeight: (width * 9 / 16).roundToDouble(),
        playCircle: true,
        metaPrefix: f.doorLabel,
        onTap: () => _open(f),
      ),
    );
  }
}
