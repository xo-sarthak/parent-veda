// =============================================================================
//  JourneyColors  —  the Pregnancy Journey map's own colour language
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
  static const Color completed = Color(0xFF3FA56A); // green  — past, achieved
  static const Color current = Color(0xFFE6A817); // gold   — you are here
  static const Color future = Color(0xFFD2CCDB); // soft grey-lavender — ahead

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
}
