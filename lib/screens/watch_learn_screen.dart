// =============================================================================
//  Watch & Learn - contextual learning videos
// -----------------------------------------------------------------------------
//  * TodaysVideoCard - the daily "recommended for this week" video, surfaced on
//    Home (between the greeting hero and Today's Moment).
//  * WatchLearnScreen - the full feature: Recommended / Learn a Skill / Expert
//    Explains / Birth Prep / Newborn Prep / Saved.
//  Real playback (videoUrl) is wired later; for now Watch opens a calm detail
//  with a "coming soon" note. Warm-Nest, never YouTube-styled.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../models/pv_video.dart';
import '../services/pregnancy_controller.dart';
import '../services/video_store.dart';
import '../theme/pv_fonts.dart';
import 'brackets/hub/hub_intent_art.dart';
import 'pregnancy/preg_chrome.dart';
import 'products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
import 'v2/v2_palette.dart' show v2BlockTint;

// ⚠️ ONE PARENTVEDA (2026-09-30, the pregnancy restyle): white cards with the
// page hairline, not shadows; the one serif section heading; the thumbnail is
// a quiet tint with the category's drawn mark and a "Coming soon" pill (the
// trying-to-conceive Learn tab's film card), not a violet gradient with a
// play glyph on a film that cannot play yet.
// Kept for revert: the soft shadow every card wore.
// const List<BoxShadow> _soft = [
//   BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
// ];

/// The hue and drawn mark for each shelf. The model's own `videoMeta` colour
/// is the brand violet for two shelves, so the screen no longer paints it.
(double, IntentMark) _look(VideoCategory c) => switch (c) {
      VideoCategory.recommended => (212.0, IntentMark.lampMark),
      VideoCategory.skill => (150.0, IntentMark.cuppedHands),
      VideoCategory.expert => (176.0, IntentMark.askDoctor),
      VideoCategory.birth => (24.0, IntentMark.bagMark),
      VideoCategory.newborn => (345.0, IntentMark.feedMark),
    };

/// A white pill with ink words, on the thumbnail's tint.
Widget _pill(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: pvManrope(
              fontSize: 11, fontWeight: FontWeight.w700, color: pvStorePalette.ink1)),
    );

PvVideo? _recommendedFor(int week) {
  final recs =
      kVideos.where((v) => v.category == VideoCategory.recommended).toList();
  for (final v in recs) {
    if (v.matchesWeek(week)) return v;
  }
  recs.sort((a, b) =>
      (a.weekStart - week).abs().compareTo((b.weekStart - week).abs()));
  return recs.isEmpty ? null : recs.first;
}

// Shared thumbnail (a tint, the shelf's drawn mark, "Coming soon" and the
// length). No real media yet, so nothing on it looks like a player.
///
/// [pills] off in the detail sheet, which says the length and "coming soon"
/// in words right under it (nothing twice on one screen).
Widget _thumb(PvVideo v, {double height = 150, bool pills = true}) {
  final (hue, mark) = _look(v.category);
  final tint = v2BlockTint(hue, pvStorePalette);
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Container(
      height: height,
      width: double.infinity,
      color: tint,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: height * 0.46,
              height: height * 0.46,
              child: HubIntentArt(mark: mark, tint: tint),
            ),
          ),
          if (pills) ...[
            Positioned(left: 10, top: 10, child: _pill('Coming soon')),
            Positioned(right: 10, bottom: 10, child: _pill(v.duration)),
          ],
        ],
      ),
    ),
  );
}

// Kept for revert: the violet gradient thumbnail with a play glyph.
// // Shared thumbnail placeholder (gradient + play + duration). No real media yet.
// Widget _thumb(PvVideo v, {double height = 150}) {
//   final m = videoMeta(v.category);
//   return ClipRRect(
//     borderRadius: BorderRadius.circular(16),
//     child: Container(
//       height: height,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [m.color, m.color.withValues(alpha: 0.72)],
//         ),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             right: -10,
//             bottom: -10,
//             child: Icon(m.icon,
//                 size: 88, color: Colors.white.withValues(alpha: 0.16)),
//           ),
//           const Center(
//             child: Icon(Icons.play_circle_fill_rounded,
//                 size: 52, color: Colors.white),
//           ),
//           Positioned(
//             right: 10,
//             bottom: 10,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(
//                 color: Colors.black.withValues(alpha: 0.45),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(v.duration,
//                   style: pvManrope(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

void _openDetail(BuildContext context, PvVideo v, AppLanguage lang) {
  final s = S(lang);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: kPvLine,
                      borderRadius: BorderRadius.circular(99))),
            ),
            const SizedBox(height: 14),
            _thumb(v, height: 180, pills: false),
            const SizedBox(height: 14),
            Text(v.title.of(lang),
                style: pvFraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.4,
                    color: pvStorePalette.ink1)),
            const SizedBox(height: 4),
            Text(v.duration,
                style: pvManrope(
                    fontSize: 12, color: pvStorePalette.ink3)),
            const SizedBox(height: 14),
            // A group label inside the sheet. Was the shelf's colour (the
            // brand violet on two shelves).
            Text(s.vidWhyNow.toUpperCase(), style: pregGroupLabelStyle()),
            const SizedBox(height: 4),
            Text(v.reason.of(lang),
                style: pvManrope(
                    fontSize: 13.5, height: 1.5, color: pvStorePalette.ink2)),
            const SizedBox(height: 16),
            // A quiet note on the sheet, not a grey block behind the words.
            // Kept for revert: Container(padding: 14, color:
            // AppTheme.surfaceContainer, radius 14, Row(Icon(movie_outlined),
            // Text(s.vidComingSoon))).
            PregNote(s.vidComingSoon, icon: Icons.movie_outlined),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: VideoStore.instance,
              builder: (context, _) {
                final saved = VideoStore.instance.isSaved(v.id);
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => VideoStore.instance.toggle(v.id),
                    icon: Icon(
                        saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 18),
                    label: Text(saved ? s.vidSaved : s.vidSave),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

// =============================================================================
//  Today's Video card (Home)
// =============================================================================
class TodaysVideoCard extends StatelessWidget {
  const TodaysVideoCard({super.key, required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, VideoStore.instance]),
      builder: (context, _) {
        final s = S(controller.language);
        final lang = controller.language;
        final v = _recommendedFor(controller.currentWeek);
        if (v == null) return const SizedBox.shrink();
        final saved = VideoStore.instance.isSaved(v.id);
        return Container(
          // The hairline, not a shadow (kept for revert: boxShadow: _soft,
          // color: AppTheme.surface).
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kPvLine),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(children: [
                  Text(s.vidTodaysVideo,
                      style: pvJakarta(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: pvStorePalette.ink1)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            WatchLearnScreen(controller: controller))),
                    child: Text(s.vidMoreVideos,
                        style: pvManrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: pvStorePalette.ink1)),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: GestureDetector(
                  onTap: () => _openDetail(context, v, lang),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _thumb(v),
                      const SizedBox(height: 12),
                      Text(v.title.of(lang),
                          style: pvJakarta(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: pvStorePalette.ink1)),
                      const SizedBox(height: 6),
                      Text('${s.vidWhyNow}: ${v.reason.of(lang)}',
                          style: pvManrope(
                              fontSize: 12.5,
                              height: 1.4,
                              color: pvStorePalette.ink2)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: pregFilledStyle(),
                            onPressed: () => _openDetail(context, v, lang),
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: Text(s.vidWatch),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () => VideoStore.instance.toggle(v.id),
                          child: Icon(
                              saved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 20,
                              color: kPvInk),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
//  Watch & Learn screen
// =============================================================================
class WatchLearnScreen extends StatelessWidget {
  const WatchLearnScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, VideoStore.instance]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final cw = controller.currentWeek;

    List<PvVideo> cat(VideoCategory c) =>
        kVideos.where((v) => v.category == c && v.matchesWeek(cw)).toList();

    final recommended = cat(VideoCategory.recommended);
    final saved =
        kVideos.where((v) => VideoStore.instance.isSaved(v.id)).toList();

    final p = pvStorePalette;
    // A pushed page: the AppBar carries only the back arrow, and the title is
    // the serif page title on the white ground (the trying-to-conceive tool
    // pages). Kept for revert: AppBar(backgroundColor:
    // AppTheme.surfaceContainer, title: Text(s.vidScreenTitle, pvJakarta w700))
    // on a grey ground.
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.ink1,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
            child: Semantics(
              header: true,
              child: Text(s.vidScreenTitle, style: pregPageTitleStyle()),
            ),
          ),
          _section(context, s, lang, s.vidSecRecommended,
              recommended.isEmpty ? cat(VideoCategory.recommended) : recommended),
          _section(context, s, lang, s.vidSecSkill, cat(VideoCategory.skill)),
          _section(
              context, s, lang, s.vidSecExpert, cat(VideoCategory.expert)),
          _section(context, s, lang, s.vidSecBirth, cat(VideoCategory.birth)),
          _section(
              context, s, lang, s.vidSecNewborn, cat(VideoCategory.newborn)),
          // Saved is the only rail that can be empty (the rest are catalog
          // lists). It still renders its heading, so the bookmark feature stays
          // discoverable to someone who has never saved a video.
          _section(context, s, lang, s.vidSecSaved, saved,
              emptyNote: s.shVideosEmpty),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, S s, AppLanguage lang, String title,
      List<PvVideo> videos, {String? emptyNote}) {
    // A section with no note is a catalog rail that is never empty in practice;
    // one WITH a note is user-data driven and must stay visible when empty.
    final note = emptyNote;
    if (videos.isEmpty) {
      if (note == null) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
          child: PregSectionHeading(title),
        ),
        // The empty Saved shelf: a quiet note on the page, not a grey block.
        // Kept for revert: Container(padding h14 v16, color:
        // AppTheme.surfaceContainer, radius 16, Row(Icon(bookmark_border),
        // Text(note))).
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: PregNote(note, icon: Icons.bookmark_border_rounded),
        ),
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The one section heading (kept for revert: Text(title, pvJakarta
        // 16 / w700)).
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
          child: PregSectionHeading(title),
        ),
        SizedBox(
          height: 198,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final v in videos) ...[
                _smallCard(context, s, lang, v),
                const SizedBox(width: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _smallCard(BuildContext context, S s, AppLanguage lang, PvVideo v) =>
      GestureDetector(
        onTap: () => _openDetail(context, v, lang),
        child: SizedBox(
          width: 220,
          child: Container(
            // The hairline, not a shadow (kept for revert: boxShadow: _soft).
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kPvLine),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _thumb(v, height: 116),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.title.of(lang),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvJakarta(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: pvStorePalette.ink1)),
                      const SizedBox(height: 3),
                      Text(v.reason.of(lang),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 11.5,
                              height: 1.35,
                              color: pvStorePalette.ink3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
