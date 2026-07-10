// =============================================================================
//  Recommendations - shared widgets (card, row, save button, rating, reason)
// -----------------------------------------------------------------------------
//  One reusable recommendation card (rail + row forms) so every surface reads
//  the same. Each carries the hero image, title, age suitability, one-line
//  summary, the "why it's here" reason, and Save - never a wall of options.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_reco_data.dart';

/// Heart-toggle bound to the RecoStore.
class RecoSaveHeart extends StatelessWidget {
  const RecoSaveHeart({super.key, required this.id, this.onLight = false, this.size = 30});
  final String id;
  final bool onLight; // sitting on the image (needs a scrim)
  final double size;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: RecoStore.instance,
        builder: (context, _) {
          final saved = RecoStore.instance.isSaved(id);
          return GestureDetector(
            onTap: () => RecoStore.instance.toggleSave(id),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: onLight ? BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle) : null,
              child: Icon(saved ? Icons.favorite : Icons.favorite_border, size: size * 0.6, color: saved ? ppCoral : (onLight ? ppInk : ppMuted)),
            ),
          );
        },
      );
}

Widget recoRating(double rating, {double size = 13, Color color = ppCoral}) => Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.star_rounded, size: size + 2, color: color),
      const SizedBox(width: 3),
      Text(rating.toStringAsFixed(1), style: ppBody(size - 1.5, color: ppSoft, w: FontWeight.w700)),
    ]);

Widget recoAgePill(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: ppBody(10.5, color: ppPurple, w: FontWeight.w700)),
    );

Widget recoReasonChip(String reason) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.auto_awesome, size: 12, color: ppCoral),
      const SizedBox(width: 5),
      Expanded(child: Text(reason, style: ppBody(11, color: ppSoft, h: 1.35), maxLines: 2, overflow: TextOverflow.ellipsis)),
    ]);

/// The image placeholder - a warm striped panel with a faint category icon.
class RecoThumb extends StatelessWidget {
  const RecoThumb({super.key, required this.item, this.height = 128, this.radius = 16});
  final RecoItem item;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(children: [
          PpStriped(height: height, radius: radius, border: true),
          Positioned.fill(child: Center(child: Icon(recoCatIcon(item.category), size: height * 0.28, color: ppPurple.withValues(alpha: 0.28)))),
          if (item.indian)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                child: Text('Indian gem', style: ppBody(9.5, color: Colors.white, w: FontWeight.w700)),
              ),
            ),
        ]),
      );
}

/// A rail card (horizontal scrollers). Compact, image-led.
class RecoRailCard extends StatelessWidget {
  const RecoRailCard({super.key, required this.item, this.reason, this.onTap, this.width = 214});
  final RecoItem item;
  final String? reason;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: width,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              RecoThumb(item: item, height: 118),
              Positioned(top: 8, left: 8, child: _catChip(item.category)),
              Positioned(top: 4, right: 4, child: RecoSaveHeart(id: item.id, onLight: true, size: 30)),
            ]),
            const SizedBox(height: 9),
            Text(item.title, style: ppJakarta(14).copyWith(height: 1.22), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Row(children: [recoAgePill(item.ageLabel), const SizedBox(width: 8), recoRating(item.pvRating)]),
            const SizedBox(height: 6),
            Text(item.summary, style: ppBody(11.5, color: ppSoft, h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            if (reason != null) ...[
              const SizedBox(height: 7),
              recoReasonChip(reason!),
            ],
          ]),
        ),
      );
}

/// A list row (category / collection / search / library screens).
class RecoRow extends StatelessWidget {
  const RecoRow({super.key, required this.item, this.reason, this.onTap});
  final RecoItem item;
  final String? reason;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 84, child: RecoThumb(item: item, height: 84, radius: 14)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Text(item.title, style: ppJakarta(14.5).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  RecoSaveHeart(id: item.id, size: 26),
                ]),
                const SizedBox(height: 4),
                Row(children: [recoAgePill(item.ageLabel), const SizedBox(width: 8), recoRating(item.pvRating), if (item.price != null) ...[const SizedBox(width: 8), Text(item.price!, style: ppBody(11.5, color: ppInk, w: FontWeight.w700))]]),
                const SizedBox(height: 5),
                Text(item.summary, style: ppBody(12, color: ppSoft, h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (reason != null) ...[
                  const SizedBox(height: 6),
                  recoReasonChip(reason!),
                ],
              ]),
            ),
          ]),
        ),
      );
}

Widget _catChip(String category) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(recoCatIcon(category), size: 12, color: ppPurple),
        const SizedBox(width: 5),
        Text(category, style: ppBody(10, color: ppInk, w: FontWeight.w700)),
      ]),
    );
