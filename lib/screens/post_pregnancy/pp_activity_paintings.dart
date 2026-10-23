// =============================================================================
//  Activity paintings (2026-10-23, Wave 8)
// -----------------------------------------------------------------------------
//  Each of the 149 activities gets its own painting in the house style of the
//  twenty phase paintings, made with ChatGPT image generation from prompts the
//  user asks for (the user, 2026-10-23). Rows show it as a rounded square,
//  the way Alan and Polarsteps list content with a photo (Mobbin), and the
//  activity opens with it as the reader's hero.
//
//  ⚠️ A ROW NEVER LOADS A PICTURE THAT IS NOT THERE. An activity shows its
//  painting only once its id is in kActivityPaintings; until then the row
//  keeps the drawn mark it has today. Adding a batch is: drop the files in
//  assets/activities/<id>.webp, add the ids here, and (with the first batch)
//  add `- assets/activities/` to pubspec.yaml.
// =============================================================================

import 'package:flutter/material.dart';

/// The activity ids that have a painting in assets/activities/. Empty until
/// the first batch lands.
const Set<String> kActivityPaintings = {};

/// The painting's asset path for this activity, or null.
String? ppActivityPainting(String activityId) =>
    kActivityPaintings.contains(activityId) ? 'assets/activities/$activityId.webp' : null;

/// The leading picture of an activity row: its painting in a rounded square,
/// or [fallback] (today's drawn mark) when it has none yet.
class PpActivityThumb extends StatelessWidget {
  const PpActivityThumb({super.key, required this.activityId, required this.fallback, this.size = 56});

  final String activityId;
  final Widget fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = ppActivityPainting(activityId);
    if (path == null) return fallback;
    return ClipRRect(
      key: ValueKey('pp_activity_thumb_$activityId'),
      borderRadius: BorderRadius.circular(size / 4),
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}
