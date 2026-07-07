// =============================================================================
//  ParentVeda Reading - shared UI building blocks
// -----------------------------------------------------------------------------
//  Editorial, calm, magazine-like: cover placeholders (warm tints), the reading
//  metadata line (collection · minutes · age), and the article cards. pp-themed.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_reading_data.dart';

const List<(Color, Color)> _kCoverTints = [
  (Color(0xFFEDE7F6), Color(0xFFF6F1FB)), // lavender
  (Color(0xFFF7ECE2), Color(0xFFFBF4EE)), // warm sand
  (Color(0xFFFBE9EE), Color(0xFFFDF2F5)), // blush
  (Color(0xFFE7EEF6), Color(0xFFF1F5FA)), // soft blue
];

/// A calm editorial cover placeholder.
class ReadCover extends StatelessWidget {
  const ReadCover({super.key, required this.seed, required this.height, this.width, this.radius = 16, this.progress});
  final int seed;
  final double height;
  final double? width;
  final double radius;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final tint = _kCoverTints[seed % _kCoverTints.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(children: [
        PpStriped(height: height, width: width, colorA: tint.$1, colorB: tint.$2, border: true),
        Positioned.fill(child: Center(child: Icon(Icons.auto_stories_outlined, size: height * 0.24, color: Colors.white.withValues(alpha: 0.7)))),
        if (progress != null && progress! > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 4,
              color: Colors.white.withValues(alpha: 0.5),
              child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: progress!.clamp(0.0, 1.0), child: Container(color: ppCoral)),
            ),
          ),
      ]),
    );
  }
}

Widget readMeta(ReadArticle a, {Color color = ppMuted}) => Text(
      '${readCollectionById(a.collection).title}  ·  ${a.minutes} min read',
      style: ppBody(11.5, color: color, w: FontWeight.w600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

Widget readSectionHeader(String title, {String? action, VoidCallback? onAction}) => Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: ppJakarta(18))),
        if (action != null) GestureDetector(onTap: onAction, behavior: HitTestBehavior.opaque, child: ppSeeAll(action)),
      ],
    );

class ReadRailCard extends StatelessWidget {
  const ReadRailCard({super.key, required this.article, required this.onTap, this.width = 220, this.progress});
  final ReadArticle article;
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
            ReadCover(seed: article.seed, height: width * 0.62, progress: progress),
            const SizedBox(height: 10),
            Text(article.title, style: ppJakarta(14.5).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            readMeta(article),
          ]),
        ),
      );
}

class ReadListCard extends StatelessWidget {
  const ReadListCard({super.key, required this.article, required this.onTap, this.progress});
  final ReadArticle article;
  final VoidCallback onTap;
  final double? progress;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 116, child: ReadCover(seed: article.seed, height: 84, progress: progress)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(article.title, style: ppJakarta(15).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(article.teaser, style: ppBody(12.5, color: ppSoft, h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 7),
                readMeta(article),
              ]),
            ),
          ]),
        ),
      );
}
