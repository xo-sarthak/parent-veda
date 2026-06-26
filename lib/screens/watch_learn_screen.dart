// =============================================================================
//  Watch & Learn — contextual learning videos
// -----------------------------------------------------------------------------
//  * TodaysVideoCard — the daily "recommended for this week" video, surfaced on
//    Home (between the greeting hero and Today's Moment).
//  * WatchLearnScreen — the full feature: Recommended / Learn a Skill / Expert
//    Explains / Birth Prep / Newborn Prep / Saved.
//  Real playback (videoUrl) is wired later; for now Watch opens a calm detail
//  with a "coming soon" note. Warm-Nest, never YouTube-styled.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localization/app_language.dart';
import '../models/pv_video.dart';
import '../services/pregnancy_controller.dart';
import '../services/video_store.dart';
import '../theme/app_theme.dart';

const List<BoxShadow> _soft = [
  BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
];

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

// Shared thumbnail placeholder (gradient + play + duration). No real media yet.
Widget _thumb(PvVideo v, {double height = 150}) {
  final m = videoMeta(v.category);
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [m.color, m.color.withValues(alpha: 0.72)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(m.icon,
                size: 88, color: Colors.white.withValues(alpha: 0.16)),
          ),
          const Center(
            child: Icon(Icons.play_circle_fill_rounded,
                size: 52, color: Colors.white),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(v.duration,
                  style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}

void _openDetail(BuildContext context, PvVideo v, AppLanguage lang) {
  final s = S(lang);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
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
                      color: AppTheme.neutral300,
                      borderRadius: BorderRadius.circular(99))),
            ),
            const SizedBox(height: 14),
            _thumb(v, height: 180),
            const SizedBox(height: 14),
            Text(v.title.of(lang),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary900)),
            const SizedBox(height: 4),
            Text(v.duration,
                style: GoogleFonts.manrope(
                    fontSize: 12, color: AppTheme.neutral500)),
            const SizedBox(height: 12),
            Text(s.vidWhyNow,
                style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: videoMeta(v.category).color)),
            const SizedBox(height: 4),
            Text(v.reason.of(lang),
                style: GoogleFonts.manrope(
                    fontSize: 13.5, height: 1.5, color: AppTheme.neutral700)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.movie_outlined,
                    size: 18, color: AppTheme.neutral500),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(s.vidComingSoon,
                      style: GoogleFonts.manrope(
                          fontSize: 12.5, color: AppTheme.neutral600)),
                ),
              ]),
            ),
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
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(children: [
                  Text(s.vidTodaysVideo,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            WatchLearnScreen(controller: controller))),
                    child: Text(s.vidMoreVideos,
                        style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary500)),
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
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary900)),
                      const SizedBox(height: 6),
                      Text('${s.vidWhyNow}: ${v.reason.of(lang)}',
                          style: GoogleFonts.manrope(
                              fontSize: 12.5,
                              height: 1.4,
                              color: AppTheme.neutral600)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: FilledButton.icon(
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
                              color: AppTheme.primary600),
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

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(s.vidScreenTitle,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
        children: [
          _section(context, s, lang, s.vidSecRecommended,
              recommended.isEmpty ? cat(VideoCategory.recommended) : recommended),
          _section(context, s, lang, s.vidSecSkill, cat(VideoCategory.skill)),
          _section(
              context, s, lang, s.vidSecExpert, cat(VideoCategory.expert)),
          _section(context, s, lang, s.vidSecBirth, cat(VideoCategory.birth)),
          _section(
              context, s, lang, s.vidSecNewborn, cat(VideoCategory.newborn)),
          _section(context, s, lang, s.vidSecSaved, saved),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, S s, AppLanguage lang, String title,
      List<PvVideo> videos) {
    if (videos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
          child: Text(title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary900)),
        ),
        SizedBox(
          height: 198,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
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
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: _soft,
            ),
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
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary900)),
                      const SizedBox(height: 3),
                      Text(v.reason.of(lang),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                              fontSize: 11.5,
                              height: 1.35,
                              color: AppTheme.neutral500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
