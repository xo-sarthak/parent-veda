// =============================================================================
//  Scan schedule helpers - which scans are "due around now"
// -----------------------------------------------------------------------------
//  Scan content lives in kJourneyMilestones (type medical), each with an
//  [anchorWeek] (the centre of its window) and a display [rangeLabel]. The daily
//  home "Scans & appointments" card uses these to surface only the scan(s) due
//  around the current week - future scans appear when their week arrives, and
//  past/not-done ones stay reachable via "view all scans". Done-state is held by
//  ScansStore (the caller filters with isCompleted).
// =============================================================================

import '../models/journey_node.dart';
import 'journey_milestones.dart';

/// Every medical scan, earliest week first.
List<JourneyMilestone> allMedicalScans() => kJourneyMilestones
    .where((m) => m.type == JourneyNodeType.medical)
    .toList()
  ..sort((a, b) => a.anchorWeek.compareTo(b.anchorWeek));

/// Scans whose window overlaps [week] - anchor week ± 2 (scans sit roughly four
/// weeks apart, so this is "the one due around now"). The caller filters out the
/// ones already marked done.
List<JourneyMilestone> scansDueAt(int week) =>
    allMedicalScans().where((m) => (m.anchorWeek - week).abs() <= 2).toList();
