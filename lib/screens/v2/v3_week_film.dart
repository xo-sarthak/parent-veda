// =============================================================================
//  V3WeekFilm — "This Week Explained", played in place
// -----------------------------------------------------------------------------
//  Built 2026-09-16 to the "Pregnancy Home V3" Claude Design (option 1a/1c).
//  The design made one call that this file exists to honour:
//
//    "Playing: inline, in place, no route change — the section is her week's
//     explanation, so leaving the page for it breaks the reading order."
//
//  WHAT THAT COSTS, and why it is still right. The home is a `ListView`, and a
//  list disposes children that scroll far enough away. A film playing in a
//  disposed child stops. So a video she starts, scrolls past by two screens,
//  and comes back to is a poster again — resumed from the saved second on the
//  next tap, because the player saves position on dispose, but not still
//  playing. That is the honest behaviour for a home screen: a film that keeps
//  talking from somewhere above the fold is a radio she did not turn on.
//
//  ⚠️ THE ENGINE IS THE PARENTING ONE, ON PURPOSE. `PvVideoPlayer` in
//  post_pregnancy/video/ is the app's only native player, and the rule is to
//  reuse the thing itself rather than build a lookalike. What is NOT reused is
//  its repository: `LocalWatchRepository` resolves an id against the PARENTING
//  catalogue with `orElse: first`, so a pregnancy id would silently play the
//  first parenting lesson under the wrong title. `PregnancyFilmRepository`
//  below resolves from the video it was handed and never looks anything up.
//
//  ⚠️ NO PLAY CONTROL THAT PLAYS NOTHING (pv_video_slot.dart's rule). The
//  pregnancy catalogue carries no files yet. When no URL resolves the poster
//  shows "Film arriving" instead of a play button, and the tap goes where the
//  old card sent her. On a dev build the five recommended films are mapped
//  to the sample in pv_video_config.dart, so the control is real there.
//
//  ENGLISH ONLY via `.en` — see v2_sections.dart.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_video.dart';
import '../../theme/pv_fonts.dart';
import '../post_pregnancy/pp_watch_data.dart' show WatchStore, WatchVideo;
import '../post_pregnancy/video/pv_video_config.dart';
import '../post_pregnancy/video/pv_video_player.dart';
import '../post_pregnancy/video/pv_video_repository.dart';
import 'v2_palette.dart';
import 'v2_sections.dart' show v2CoverTint;

// -----------------------------------------------------------------------------
//  Adapter: a pregnancy catalogue entry as something the player can hold
// -----------------------------------------------------------------------------

/// `PvVideo` (pregnancy: title, reason, a "4 min" string) as a `WatchVideo`
/// (what the player takes). The id is carried through unchanged so progress in
/// `WatchStore` is keyed by the catalogue id, and the parenting ids
/// (`sleep4mo`, `q_noise`…) and pregnancy ids (`rec_sound`, `skill_kegel`…)
/// share no names.
WatchVideo pregnancyWatchVideo(PvVideo v) => WatchVideo(
      id: v.id,
      title: v.title.en,
      topic: 'Pregnancy',
      category: 'pregnancy',
      expertId: '',
      ageTag: 'Week ${v.weekStart}–${v.weekEnd}',
      seconds: pregnancyVideoSeconds(v),
      quick: false,
      why: v.reason.en,
      seed: v.id.hashCode & 0xff,
    );

/// "4 min" → 240. The catalogue's duration is a display string; the player
/// needs seconds for its scrubber before the file reports its own length.
int pregnancyVideoSeconds(PvVideo v) {
  final m = RegExp(r'\d+').firstMatch(v.duration);
  final n = int.tryParse(m?.group(0) ?? '') ?? 0;
  return v.duration.contains('min') ? n * 60 : n;
}

/// "4 min" → "4:00", the form the design shows on the duration chip.
String pregnancyDurationStamp(PvVideo v) {
  final s = pregnancyVideoSeconds(v);
  if (s <= 0) return v.duration;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// True when this film has a source the engine can play right now.
bool pregnancyFilmPlayable(PvVideo v) =>
    pvCanPlayNatively(pregnancyWatchVideo(v));

/// Progress and source for ONE pregnancy film, resolved from the video it was
/// built with. See the file header for why `LocalWatchRepository` cannot be
/// used here.
class PregnancyFilmRepository implements PvVideoRepository {
  const PregnancyFilmRepository(this.video);
  final WatchVideo video;

  @override
  Future<VideoLesson> lesson(String id) async => VideoLesson(
        lessonId: video.id,
        title: video.title,
        videoUrl: pvResolveVideoUrl(video),
        duration: video.seconds,
        completed: WatchStore.instance.isCompleted(video.id),
        lastPosition: WatchStore.instance.lastPositionOf(video.id),
      );

  @override
  Future<void> saveProgress(String id,
          {required int positionSeconds, required int watchedSeconds}) async =>
      WatchStore.instance
          .setLastPosition(video.id, positionSeconds, video.seconds);

  @override
  Future<void> markCompleted(String id) async =>
      WatchStore.instance.markCompleted(video.id);
}

// -----------------------------------------------------------------------------
//  The shelf under "Watch These Videos This Week"
// -----------------------------------------------------------------------------

/// Three more films for this week, excluding the one playing above.
///
/// Order: any other recommendation that covers the week, then the expert,
/// skill, birth and newborn categories in that order — clinical explanation
/// before practice, and the birth/newborn material last because most weeks it
/// is furthest off. Every candidate must cover the week; there is no "nearest
/// week" fallback here because a shelf of three that are all a trimester away
/// is worse than a shelf of two.
List<PvVideo> v3ShelfVideosFor(int week, {String? excludeId, int take = 3}) {
  const order = [
    VideoCategory.recommended,
    VideoCategory.expert,
    VideoCategory.skill,
    VideoCategory.birth,
    VideoCategory.newborn,
  ];
  final out = <PvVideo>[];
  for (final c in order) {
    for (final v in kVideos) {
      if (out.length == take) return out;
      if (v.category != c || v.id == excludeId) continue;
      if (!v.matchesWeek(week)) continue;
      out.add(v);
    }
  }
  return out;
}

// -----------------------------------------------------------------------------
//  The film block
// -----------------------------------------------------------------------------

/// The week's film: a full-bleed 16:9 poster that becomes the player in place.
///
/// The caller places this OUTSIDE the page's 18dp gutter — it is the one
/// section besides the hero that reaches both edges, which is what makes it
/// read as the page's second act rather than another card.
class V3WeekFilm extends StatefulWidget {
  const V3WeekFilm(
      {super.key,
      required this.video,
      required this.week,
      required this.p,
      this.onUnavailable});

  final PvVideo video;
  final int week;
  final V2Palette p;

  /// Where a tap goes while there is no file to play. The old card sent her
  /// to the Today tab's video row; that stays the destination rather than a
  /// dead tap.
  final VoidCallback? onUnavailable;

  @override
  State<V3WeekFilm> createState() => _V3WeekFilmState();
}

class _V3WeekFilmState extends State<V3WeekFilm> {
  bool _playing = false;

  @override
  void didUpdateWidget(V3WeekFilm old) {
    super.didUpdateWidget(old);
    // A different week's film is a different film: back to its poster.
    if (old.video.id != widget.video.id) _playing = false;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final wv = pregnancyWatchVideo(widget.video);
    final canPlay = pvCanPlayNatively(wv);

    if (_playing && canPlay) {
      return PvVideoPlayer(
        video: wv,
        inline: true,
        autoStart: true,
        repository: PregnancyFilmRepository(wv),
      );
    }

    return V3FilmPoster(
      video: widget.video,
      p: p,
      label: canPlay
          ? 'WEEK ${widget.week} FILM'
          : 'WEEK ${widget.week} FILM · ARRIVING',
      playable: canPlay,
      onTap: canPlay ? () => setState(() => _playing = true) : widget.onUnavailable,
    );
  }
}

/// The 16:9 poster a film shows before it plays — and INSTEAD of a player
/// while it has no file. Shared by the home's inline block and the film page
/// so the two "arriving" states are one state.
///
/// ⚠️ THE PLAY CONTROL IS CONDITIONAL, and that is the whole widget. The
/// parenting player's own poster draws a play circle whether or not a source
/// exists; on the first walk the film page showed it for an unmapped film and
/// read as a button that does nothing. A poster that says "arriving" with no
/// button teaches her that buttons do things.
class V3FilmPoster extends StatelessWidget {
  const V3FilmPoster(
      {super.key,
      required this.video,
      required this.p,
      required this.label,
      required this.playable,
      this.onTap});

  final PvVideo video;
  final V2Palette p;
  final String label;
  final bool playable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2CoverTint('video-${video.id}', p);
    final deep = HSLColor.fromColor(tint).withLightness(0.74).toColor();
    return InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(fit: StackFit.expand, children: [
          // No real still yet — a tinted ground with the film named on it,
          // never a fake thumbnail of a film that does not exist.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.8, -0.9),
                radius: 1.4,
                colors: [tint, deep],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.55)),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 20,
            child: Text(label,
                style: pvManrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: p.ink1.withValues(alpha: 0.4))),
          ),
          if (playable)
            Center(
              child: Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.action,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: p.action.withValues(alpha: 0.34),
                        blurRadius: 22,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.play_arrow_rounded,
                      size: 34, color: Colors.white),
                ),
              ),
            ),
          Positioned(
            right: 18,
            bottom: 14,
            child: _DurationChip(label: pregnancyDurationStamp(video)),
          ),
        ]),
      ),
    );
  }
}

/// One row of the "Watch These Videos This Week" shelf — option 1d, the
/// design's recommendation: a small 16:9 thumb with its duration, so the rows
/// read as a list beside the full-bleed film above and do not merge with the
/// thumb-less reads rows below.
class V3VideoRow extends StatelessWidget {
  const V3VideoRow(
      {super.key, required this.video, required this.p, required this.onTap});

  final PvVideo video;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 112,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: v2CoverTint('video-${video.id}', p),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(children: [
                    Center(
                      child: Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Icon(Icons.play_arrow_rounded,
                              size: 15, color: p.action),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 5,
                      bottom: 5,
                      child: _DurationChip(
                          label: pregnancyDurationStamp(video), small: true),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(video.title.en,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(
                            fontSize: 16,
                            letterSpacing: -0.4,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            color: p.ink1)),
                    if (video.reason.en.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(video.reason.en,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvJakarta(
                              fontSize: 13, height: 1.45, color: p.ink2)),
                    ],
                  ]),
            ),
          ]),
        ),
      );
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({required this.label, this.small = false});
  final String label;
  final bool small;

  @override
  Widget build(BuildContext context) => Container(
        padding: small
            ? const EdgeInsets.symmetric(horizontal: 5, vertical: 2)
            : const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
            color: const Color(0xFF201C24).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999)),
        child: Text(label,
            style: pvManrope(
                fontSize: small ? 8.5 : 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: Colors.white)),
      );
}
