// =============================================================================
//  MemoryCard — renders a template at its logical size, capture-ready
// -----------------------------------------------------------------------------
//  The template builder returns a fixed-size (360-wide) card. Wrap it in a
//  RepaintBoundary so the exporter can capture it crisply, and let the caller
//  scale it for display with a FittedBox. Same widget powers the live preview
//  and the My-Memories thumbnails.
// =============================================================================

import 'package:flutter/material.dart';

import '../../memories/memory_models.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard({
    super.key,
    required this.template,
    required this.data,
    this.captureKey,
  });

  final MemoryTemplate template;
  final MemoryData data;

  /// When set, wraps the card in a RepaintBoundary the exporter captures.
  final GlobalKey? captureKey;

  @override
  Widget build(BuildContext context) {
    final card = template.builder(template, data);
    return captureKey == null
        ? card
        : RepaintBoundary(key: captureKey, child: card);
  }
}

/// A scaled, boxed preview of a card — the template's aspect ratio preserved,
/// sized to the available width, with a soft shadow.
class MemoryCardPreview extends StatelessWidget {
  const MemoryCardPreview({
    super.key,
    required this.template,
    required this.data,
    this.captureKey,
    this.maxWidth,
  });

  final MemoryTemplate template;
  final MemoryData data;
  final GlobalKey? captureKey;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final size = template.format.size;
    final w = maxWidth ?? size.width;
    final h = w * size.height / size.width;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(w * 0.05),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 12)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FittedBox(
        fit: BoxFit.cover,
        child: MemoryCard(
            template: template, data: data, captureKey: captureKey),
      ),
    );
  }
}
