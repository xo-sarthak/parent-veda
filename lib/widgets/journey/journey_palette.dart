// =============================================================================
//  JourneyColors  -  the Pregnancy Journey map's own colour language
// -----------------------------------------------------------------------------
//  The map deliberately uses a louder, more literal colour system than the rest
//  of the (restrained) app: state colours signal progress, and each milestone
//  TYPE has its own hue (per the product spec). Kept here so the whole feature
//  shares one source of truth.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/journey_node.dart';

/// Where a node / path segment sits relative to the mother's current position.
enum NodeState { completed, current, future }

class JourneyColors {
  JourneyColors._();

  // ---- Path / node STATE colours -------------------------------------------
  static const Color completed = Color(0xFF6A30B6); // purple - past, achieved
  static const Color current = Color(0xFFFF5A79); // coral  - you are here
  static const Color future = Color(0xFFD2CCDB); // soft grey-lavender - ahead

  // ---- Arrival / destination (the end of the journey, near Birth) ----------
  static const Color arrivalGold = Color(0xFF6A30B6); // purple (Warm Nest)
  static const Color arrivalRose = Color(0xFFEF6F8E);

  // ---- Trimester backdrop bands (soft washes behind the trail) -------------
  // index 0 = first trimester, 1 = second, 2 = third.
  static const List<Color> trimesterFill = [
    Color(0xFFFBEAE0), // soft peach   - first trimester
    Color(0xFFEDE6F7), // soft lavender - second trimester
    Color(0xFFE2F1E8), // soft mint    - third trimester
  ];
  static const List<Color> trimesterInk = [
    Color(0xFFC07A4E), // muted terracotta
    Color(0xFF7A4FC2), // muted purple
    Color(0xFF3E9A66), // muted green
  ];

  // ---- Milestone TYPE colours (used as nodes are added in later phases) -----
  static const Color typeAchievement = Color(0xFFE6A817); // gold
  static const Color typeMedical = Color(0xFF7A4FC2); // purple
  static const Color typeBaby = Color(0xFF3B82C4); // blue
  static const Color typeMother = Color(0xFFEF6F8E); // pink
  static const Color typePvJourney = Color(0xFF3FA56A); // ParentVeda green
  static const Color typeFeature = Color(0xFF18A39B); // teal

  /// The state colour for a given [NodeState].
  static Color forState(NodeState state) {
    switch (state) {
      case NodeState.completed:
        return completed;
      case NodeState.current:
        return current;
      case NodeState.future:
        return future;
    }
  }

  /// The TYPE colour for a milestone node.
  static Color forType(JourneyNodeType type) {
    switch (type) {
      case JourneyNodeType.achievement:
        return typeAchievement;
      case JourneyNodeType.medical:
        return typeMedical;
      case JourneyNodeType.babyDev:
        return typeBaby;
      case JourneyNodeType.mother:
        return typeMother;
      case JourneyNodeType.pvJourney:
        return typePvJourney;
      case JourneyNodeType.feature:
        return typeFeature;
      case JourneyNodeType.week:
        return current;
    }
  }

  /// A tasteful Material icon for each milestone TYPE - shown inside the marker
  /// so a milestone reads as a real checkpoint, without emoji clutter.
  static IconData iconForType(JourneyNodeType type) {
    switch (type) {
      case JourneyNodeType.achievement:
        return Icons.emoji_events_rounded;
      case JourneyNodeType.medical:
        return Icons.medical_services_rounded;
      case JourneyNodeType.babyDev:
        return Icons.child_care_rounded;
      case JourneyNodeType.mother:
        return Icons.favorite_rounded;
      case JourneyNodeType.pvJourney:
        return Icons.auto_awesome_rounded;
      case JourneyNodeType.feature:
        return Icons.star_rounded;
      case JourneyNodeType.week:
        return Icons.flag_rounded;
    }
  }
}
