// =============================================================================
//  Journey node assembly
// -----------------------------------------------------------------------------
//  Merges the ten week checkpoints with every authored milestone into a single
//  list of stops, ordered top-to-bottom along the trail by pregnancy day.
// =============================================================================

import '../data/journey_milestones.dart';
import '../models/journey_node.dart';

const List<int> kWeekCheckpoints = [4, 8, 12, 16, 20, 24, 28, 32, 36, 40];

/// All trail stops, sorted by pregnancy day (ties: week checkpoint first, then
/// by node type). Stable, deterministic order so layout never jumps.
List<MapNode> buildJourneyNodes() {
  final nodes = <MapNode>[
    for (final w in kWeekCheckpoints)
      MapNode(
        type: JourneyNodeType.week,
        posDay: (w * 7).toDouble(),
        weekLabel: w,
        routeWeek: w,
      ),
    for (final m in kJourneyMilestones)
      MapNode(
        type: m.type,
        posDay: m.posDay,
        routeWeek: m.ctaWeek,
        milestone: m,
      ),
  ];

  nodes.sort((a, b) {
    final byDay = a.posDay.compareTo(b.posDay);
    if (byDay != 0) return byDay;
    // Week checkpoints anchor first within a cluster, then by type order.
    return a.type.index.compareTo(b.type.index);
  });

  return nodes;
}
