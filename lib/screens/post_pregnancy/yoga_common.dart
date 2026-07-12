// =============================================================================
//  ParentVeda Yoga - shared UI building blocks (cult.fit-style)
// -----------------------------------------------------------------------------
//  Reusable pieces so every Yoga surface reads as one premium, image-led system:
//    • YogaBigCard - the tall, rounded "image" card with a big title overlaid and
//      an EXPLORE pill at the bottom (the cult.fit hero-card look), on a striped
//      placeholder with a dark scrim so the white overlay text stays legible.
//    • yogaSectionHeader / yogaStars / yogaModeBadge / yogaPlayDisc helpers.
//  pp-themed, no emojis, no external assets.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_yoga_data.dart';

// Gentle placeholder tints, varied by seed so a rail doesn't read as flat.
const List<(Color, Color)> _kYogaTints = [
  (Color(0xFFE7DBF3), Color(0xFFF1E9F8)),
  (Color(0xFFFAD9E2), Color(0xFFFCE9EF)),
  (Color(0xFFDDE7F5), Color(0xFFEBF1FA)),
  (Color(0xFFE6E0D2), Color(0xFFF2EEE3)),
  (Color(0xFFD9EAE2), Color(0xFFE9F3EE)),
];

(Color, Color) yogaTint(int seed) => _kYogaTints[seed % _kYogaTints.length];

/// A small solid mode badge ("LIVE 1:1" / "GROUP" / "RECORDED") - always readable
/// because it carries its own solid fill.
Widget yogaModeBadge(YogaMode mode, {bool light = false}) {
  final (label, color) = switch (mode) {
    YogaMode.liveOneToOne => ('LIVE · 1:1', ppCoral),
    YogaMode.liveGroup => ('LIVE · GROUP', ppCoral),
    YogaMode.recorded => ('RECORDED', ppPurple),
  };
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: light ? Colors.white.withValues(alpha: 0.92) : color,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: ppBody(9.5, color: light ? color : Colors.white, w: FontWeight.w800).copyWith(letterSpacing: 0.7),
    ),
  );
}

/// A compact star + rating + reviews line ("★ 4.9 · 214 reviews").
Widget yogaStars(double rating, int reviews, {Color color = ppSoft, bool showCount = true}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 15, color: ppCoral),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1), style: ppBody(12.5, color: color, w: FontWeight.w700)),
        if (showCount) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text('· $reviews reviews',
                style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ],
    );

/// A section header (title + one-line subtitle), used above each category rail.
Widget yogaSectionHeader(YogaCategory cat) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
          child: Icon(cat.icon, size: 20, color: ppPurple),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cat.title, style: ppJakarta(18), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(cat.subtitle, style: ppBody(12.5, color: ppMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ],
    );

/// A white play disc (mock playback affordance for recorded classes).
Widget yogaPlayDisc(double size) => Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12)],
      ),
      child: Icon(Icons.play_arrow_rounded, color: ppPurple, size: size * 0.5),
    );

/// The signature cult.fit-style card: a tall rounded "image" (striped placeholder
/// with a dark bottom scrim), a big title overlaid, the instructor, and an EXPLORE
/// pill along the bottom. An optional bookmark toggles a saved state.
class YogaBigCard extends StatelessWidget {
  const YogaBigCard({
    super.key,
    required this.cls,
    required this.onTap,
    this.saved = false,
    this.onSave,
    this.width = 210,
    this.height = 268,
  });

  final YogaClass cls;
  final VoidCallback onTap;
  final bool saved;
  final VoidCallback? onSave;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tint = yogaTint(cls.seed);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(children: [
            // placeholder "image"
            PpStriped(height: height, width: width, colorA: tint.$1, colorB: tint.$2),
            // dark scrim so the overlaid white text reads
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      ppInk.withValues(alpha: 0.06),
                      ppInk.withValues(alpha: 0.82),
                    ],
                    stops: const [0.32, 0.52, 1.0],
                  ),
                ),
              ),
            ),
            // top row: mode badge + optional bookmark
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(children: [
                yogaModeBadge(cls.mode),
                const Spacer(),
                if (onSave != null)
                  GestureDetector(
                    onTap: onSave,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
                      child: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 17, color: ppPurple),
                    ),
                  ),
              ]),
            ),
            // recorded classes hint their play affordance in the centre
            if (cls.mode == YogaMode.recorded)
              Positioned.fill(
                bottom: 96,
                child: Center(child: yogaPlayDisc(46)),
              ),
            // bottom overlay: title + instructor + EXPLORE pill
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(cls.title,
                    style: ppFraunces(21, color: Colors.white, h: 1.1, w: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 13, color: ppCoral),
                  const SizedBox(width: 3),
                  Text(cls.rating.toStringAsFixed(1),
                      style: ppBody(11.5, color: Colors.white, w: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text('· ${cls.instructorName}',
                        style: ppBody(11.5, color: Colors.white.withValues(alpha: 0.85)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('EXPLORE',
                        style: ppBody(11, color: ppPurple, w: FontWeight.w800).copyWith(letterSpacing: 0.8)),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward_rounded, size: 13, color: ppPurple),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A wide list row (used for search results) - a small placeholder tile, title,
/// instructor + schedule, mode badge and price.
class YogaListCard extends StatelessWidget {
  const YogaListCard({super.key, required this.cls, required this.onTap});
  final YogaClass cls;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = yogaTint(cls.seed);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(children: [
              PpStriped(height: 96, width: 96, colorA: tint.$1, colorB: tint.$2),
              if (cls.mode == YogaMode.recorded)
                Positioned.fill(child: Center(child: yogaPlayDisc(34))),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              yogaModeBadge(cls.mode),
              const SizedBox(height: 8),
              Text(cls.title, style: ppJakarta(15).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('${cls.instructorName} · ${cls.categoryInfo.title}',
                  style: ppBody(12, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                yogaStars(cls.rating, cls.reviewsCount, showCount: false),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(cls.durationLabel,
                      style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
