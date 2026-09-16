// =============================================================================
//  V3FilmScreen — one pregnancy film, on its own page
// -----------------------------------------------------------------------------
//  Where a row of the V3 home's "Watch These Videos This Week" shelf opens.
//  The week's own film plays IN PLACE on the home (v3_week_film.dart); the
//  shelf is a list of other films, and a list row opens a page — that is the
//  difference between "her week's explanation" and "three more if she wants".
//
//  This is the pregnancy stage's first video page. Before it, every pregnancy
//  video tap went `_open('todays_video')` — a TAB SWITCH to the classic home,
//  where the row said "coming soon". A row that says "Kegel Exercises · 3 min"
//  and lands on a different screen's list is a door one screen short.
//
//  ⚠️ THE FIRST CUT WAS A PLAYER, A TITLE AND ONE LINE, AND THE USER SAW IT ON
//  THE PHONE: "its not good if user gets to see empty screens." Correct, and
//  the fix is not padding. Everything under the film now is something that
//  already exists and is genuinely about this film:
//
//    · THE TOOL THE FILM TEACHES. A film about kegels is one tap from the
//      Kegel screen; a film about movement is one tap from the counter. Only
//      films that are ABOUT a tool get the door (`_toolFor`), because a door
//      to a tool the film did not mention is a banner.
//    · READS THAT MATCH IT, by the film's own title words through the reads
//      search, filled from the week's recommendations. They open the real
//      reader.
//    · THE OTHER FILMS THIS WEEK, so the page is a place to keep going and
//      not a dead end — the same "learn next" idea the parenting player has.
//
//  What is NOT here: chapters, takeaways, a transcript. Those are content
//  for films that have not been shot, and writing them here would be writing
//  clinical copy to fill a screen. `PvVideoSlot` is the model for that when
//  it comes; the page is shaped so the sections slot in above the reads.
//
//  Fullscreen is hosted the way watch_player_screen.dart hosts it: the same
//  player instance is kept by a GlobalKey and given the whole screen, so
//  playback never restarts. Progress goes to `WatchStore` through
//  `PregnancyFilmRepository`, keyed by the catalogue id.
//
//  ENGLISH ONLY via `.en` — see v2_sections.dart.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/read_next_data.dart';
import '../../models/pv_video.dart';
import '../../models/read_item.dart';
import '../../services/app_structure.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/surface_router.dart';
import '../../services/video_store.dart';
import '../../theme/pv_fonts.dart';
import '../book_companion_screen.dart';
import '../post_pregnancy/video/pv_video_player.dart';
import '../read_reader_screen.dart';
import 'v2_palette.dart';
import 'v3_sections.dart';
import 'v3_week_film.dart';

class V3FilmScreen extends StatefulWidget {
  const V3FilmScreen(
      {super.key,
      required this.video,
      required this.week,
      required this.pregnancy});

  final PvVideo video;

  /// Her week, for the reads and films that fill the page. The film's own
  /// range is a span; this is the point in it she is at.
  final int week;
  final PregnancyController pregnancy;

  @override
  State<V3FilmScreen> createState() => _V3FilmScreenState();
}

class _V3FilmScreenState extends State<V3FilmScreen> {
  final GlobalKey _playerKey = GlobalKey();
  bool _fullscreen = false;

  PvVideo get v => widget.video;

  Widget _player(V2Palette p) {
    // No file yet: the shared "arriving" poster, with no play control. The
    // engine's own poster would draw one that plays nothing.
    if (!pregnancyFilmPlayable(v)) {
      return V3FilmPoster(
          video: v, p: p, label: 'FILM · ARRIVING', playable: false);
    }
    final wv = pregnancyWatchVideo(v);
    return PvVideoPlayer(
      key: _playerKey,
      video: wv,
      repository: PregnancyFilmRepository(wv),
      onFullscreenChanged: (fs) => setState(() => _fullscreen = fs),
    );
  }

  void _push(Widget screen, String name) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: name), builder: (_) => screen));

  void _openRead(ReadItem item) => _push(
      item.hasCompanion
          ? BookCompanionScreen(item: item, controller: widget.pregnancy)
          : ReadReaderScreen(item: item, controller: widget.pregnancy),
      'read/${item.id}');

  void _openTool(String surfaceId) {
    final s = screenForSurface(
        surfaceId, widget.pregnancy, widget.pregnancy.language);
    if (s == null) return; // `_toolFor` only names ids the router serves
    _push(s, surfaceId);
  }

  @override
  Widget build(BuildContext context) {
    if (_fullscreen) {
      return Scaffold(
          backgroundColor: Colors.black,
          body: _player(V2PaletteStore.instance.current));
    }
    final tool = _toolFor(v.id);
    final reads = v3ReadsForFilm(v, widget.week);
    final more = v3ShelfVideosFor(widget.week, excludeId: v.id, take: 4);

    return ListenableBuilder(
      listenable:
          Listenable.merge([V2PaletteStore.instance, VideoStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final saved = VideoStore.instance.isSaved(v.id);
        return Scaffold(
          backgroundColor: p.ground,
          // The poster has no back arrow of its own (the player's top bar
          // carries one only while it plays), so the page keeps a plain one.
          appBar: pregnancyFilmPlayable(v)
              ? null
              : AppBar(
                  backgroundColor: p.ground,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  iconTheme: IconThemeData(color: p.ink1),
                ),
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                _player(p),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---- The film ---------------------------------------
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(v.title.en,
                                    style: pvFraunces(
                                        fontSize: 23,
                                        letterSpacing: -0.55,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: p.ink1)),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                tooltip: saved ? 'Saved' : 'Save',
                                onPressed: () =>
                                    VideoStore.instance.toggle(v.id),
                                icon: Icon(
                                    saved
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: p.action),
                              ),
                            ]),
                        const SizedBox(height: 4),
                        Text(
                            '${v.duration} · ${_categoryLabel(v.category)} · Weeks ${v.weekStart}–${v.weekEnd}',
                            style: pvManrope(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: p.ink3)),
                        if (v.reason.en.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text('WHY THIS MATTERS NOW',
                              style: pvManrope(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.3,
                                  color: p.action.withValues(alpha: 0.85))),
                          const SizedBox(height: 6),
                          Text(v.reason.en,
                              style: pvJakarta(
                                  fontSize: 15, height: 1.55, color: p.ink1)),
                        ],

                        // ---- The tool it teaches ----------------------------
                        if (tool != null) ...[
                          const SizedBox(height: 22),
                          _ToolDoor(
                              p: p,
                              label: _surfaceLabel(tool),
                              onTap: () => _openTool(tool)),
                        ],

                        // ---- Reads that go with it --------------------------
                        if (reads.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          V3SectionHead(
                              eyebrow: 'Read next',
                              title: 'Goes with this film',
                              p: p),
                          const SizedBox(height: 8),
                          for (final r in reads)
                            V3ReadRow(
                                item: r, p: p, onTap: () => _openRead(r)),
                        ],

                        // ---- The other films this week ----------------------
                        if (more.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          V3SectionHead(
                              eyebrow: 'More films',
                              title: 'Also for week ${widget.week}',
                              p: p),
                          const SizedBox(height: 2),
                          for (final m in more) ...[
                            V3VideoRow(
                                video: m,
                                p: p,
                                onTap: () => _push(
                                    V3FilmScreen(
                                        video: m,
                                        week: widget.week,
                                        pregnancy: widget.pregnancy),
                                    'pregnancy/film/${m.id}')),
                            if (m != more.last)
                              Divider(height: 1, thickness: 1, color: p.line),
                          ],
                        ],
                      ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
//  What goes with a film
// -----------------------------------------------------------------------------

/// The tool a film is ABOUT, or null. Only surface ids `screenForSurface`
/// serves, and only where the film's subject IS the tool: a kegel film and
/// the Kegel screen, a movement film and the counter. `expert_gdm` has no
/// entry on purpose — the condition library is a reference, not a tool, and
/// the film's reads cover it.
String? _toolFor(String videoId) => switch (videoId) {
      'skill_kegel' => 'kegel',
      'rec_movement' => 'movement',
      'rec_scan1' || 'expert_anomaly' => 'tests_scans',
      'skill_bag' => 'hospital_bag',
      'rec_labour' || 'expert_labour' || 'birth_signs' || 'birth_pain' =>
        'contractions',
      _ => null,
    };

/// The surface's own label, from the one list that names every surface —
/// the same words the Tools tab uses, so the door here and the tile there
/// say the same thing.
String _surfaceLabel(String surfaceId) {
  final s = kAppSurfaces.where((x) => x.id == surfaceId);
  return s.isEmpty ? surfaceId : s.first.label;
}

String _categoryLabel(VideoCategory c) => switch (c) {
      VideoCategory.recommended => 'This week',
      VideoCategory.skill => 'Learn a skill',
      VideoCategory.expert => 'From a doctor',
      VideoCategory.birth => 'Birth',
      VideoCategory.newborn => 'Newborn',
    };

const _stop = {
  'your', 'about', 'ready', 'getting', 'feeling', 'explained', 'understanding',
  'first', 'simple', 'gentle', 'signs', 'how', 'the', 'for', 'and', 'with',
  'exercises', 'calm',
};

/// Reads that go with a film: the film's own title words through the reads
/// search, then the week's recommendations to fill to three. Search first
/// because "Kegel" should find the pelvic-floor read before it finds this
/// week's hero article; the week fills in so the section is never empty for
/// a film whose subject has no read yet.
List<ReadItem> v3ReadsForFilm(PvVideo v, int week, {int take = 3}) {
  final out = <ReadItem>[];
  void add(Iterable<ReadItem> items) {
    for (final r in items) {
      if (out.length == take) return;
      if (out.any((x) => x.id == r.id)) continue;
      out.add(r);
    }
  }

  final words = v.title.en
      .toLowerCase()
      .split(RegExp(r'[^a-z]+'))
      .where((w) => w.length >= 4 && !_stop.contains(w));
  for (final w in words) {
    add(readSearch(w));
  }
  add(recommendedForWeek(week));
  return out;
}

/// "Do it, not just watch it" — one door to the tool this film teaches.
class _ToolDoor extends StatelessWidget {
  const _ToolDoor({required this.p, required this.label, required this.onTap});
  final V2Palette p;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line),
            ),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.action.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.touch_app_outlined, size: 20, color: p.action),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Try it now',
                          style: pvManrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: p.ink3)),
                      const SizedBox(height: 2),
                      Text(label,
                          style: pvJakarta(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: p.ink1)),
                    ]),
              ),
              Icon(Icons.chevron_right_rounded, color: p.ink3),
            ]),
          ),
        ),
      );
}
