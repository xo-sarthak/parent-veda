// =============================================================================
//  ParentVeda Watch — shared UI building blocks
// -----------------------------------------------------------------------------
//  Reusable pieces so every Watch surface reads as one calm, learning-first
//  system: placeholder thumbnails (with play / duration / progress), the
//  learning-metadata line (category · age · expert · duration — never social
//  metrics), and the rail/list video cards. pp-themed, no emojis.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_watch_data.dart';

// Gentle thumbnail tints, varied by seed so a grid doesn't read as flat.
const List<(Color, Color)> _kThumbTints = [
  (Color(0xFFEBE3F5), Color(0xFFF5EFFA)),
  (Color(0xFFFCE6EC), Color(0xFFFDF0F4)),
  (Color(0xFFE7EEF9), Color(0xFFF1F5FB)),
  (Color(0xFFEDE9DF), Color(0xFFF6F3EB)),
];

/// A placeholder video thumbnail with an optional play badge, a duration pill,
/// and a continue-watching progress bar.
class WatchThumb extends StatelessWidget {
  const WatchThumb({
    super.key,
    required this.seed,
    required this.height,
    this.width,
    this.radius = 16,
    this.showPlay = true,
    this.duration,
    this.progress,
    this.quick = false,
  });

  final int seed;
  final double height;
  final double? width;
  final double radius;
  final bool showPlay;
  final String? duration;
  final double? progress; // 0..1
  final bool quick;

  @override
  Widget build(BuildContext context) {
    final tint = _kThumbTints[seed % _kThumbTints.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(children: [
        PpStriped(height: height, width: width, colorA: tint.$1, colorB: tint.$2, border: true),
        if (showPlay)
          Positioned.fill(
            child: Center(
              child: Container(
                width: quick ? 44 : 52,
                height: quick ? 44 : 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12)]),
                child: Icon(Icons.play_arrow_rounded, color: ppPurple, size: quick ? 24 : 28),
              ),
            ),
          ),
        if (quick)
          Positioned(
            top: 8,
            left: 8,
            child: _pill('QUICK', ppCoral),
          ),
        if (duration != null)
          Positioned(
            right: 8,
            bottom: progress != null ? 12 : 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
              child: Text(duration!, style: ppBody(10.5, color: Colors.white, w: FontWeight.w700)),
            ),
          ),
        if (progress != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 4,
              color: Colors.white.withValues(alpha: 0.5),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress!.clamp(0.0, 1.0),
                child: Container(color: ppCoral),
              ),
            ),
          ),
      ]),
    );
  }

  static Widget _pill(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(999)),
        child: Text(t, style: ppBody(9, color: Colors.white, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
      );
}

/// The learning-metadata line — category · child age · expert. No social metrics.
Widget watchMeta(WatchVideo v, {Color color = ppMuted}) => Text(
      '${v.category}  ·  ${v.ageTag}  ·  ${v.expert.name}',
      style: ppBody(11.5, color: color, w: FontWeight.w600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

/// A section header with an optional trailing action.
Widget watchSectionHeader(String title, {String? action, VoidCallback? onAction}) => Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: ppJakarta(18))),
        if (action != null)
          GestureDetector(onTap: onAction, behavior: HitTestBehavior.opaque, child: ppSeeAll(action)),
      ],
    );

/// A rail card (fixed width) — thumbnail + title + meta.
class WatchRailCard extends StatelessWidget {
  const WatchRailCard({super.key, required this.video, required this.onTap, this.width = 230, this.progress});
  final WatchVideo video;
  final VoidCallback onTap;
  final double width;
  final double? progress;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: width,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            WatchThumb(seed: video.seed, height: width * 0.56, duration: video.durationLabel, progress: progress, quick: video.quick),
            const SizedBox(height: 10),
            Text(video.title, style: ppJakarta(14).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            watchMeta(video),
          ]),
        ),
      );
}

/// A wide list card (thumbnail left, text right) — for feeds & "For you".
class WatchListCard extends StatelessWidget {
  const WatchListCard({super.key, required this.video, required this.onTap, this.progress});
  final WatchVideo video;
  final VoidCallback onTap;
  final double? progress;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 132,
              child: WatchThumb(seed: video.seed, height: 84, duration: video.durationLabel, progress: progress, quick: video.quick),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(video.title, style: ppJakarta(14.5).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(video.topic, style: ppBody(12.5, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                watchMeta(video),
              ]),
            ),
          ]),
        ),
      );
}
