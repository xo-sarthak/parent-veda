// =============================================================================
//  Journey registry — which doors walk, and which go straight through
// -----------------------------------------------------------------------------
//  A door looks itself up here before doing anything else:
//
//    · a journey exists  -> open it, and she walks the steps
//    · no journey        -> open the destination directly
//
//  ⚠️ THE SECOND CASE IS NOT A BACKLOG. Plenty of doors open a screen that
//  already finishes the job — the fertile-window screen states the dates and
//  the peak day; the can-I checker answers and stops. Wrapping a journey around
//  a complete screen is the same tax as putting a hub screen in front of a
//  single door: another tap, no more answer.
//
//  A journey is for a door whose destination leaves her halfway.
// =============================================================================

import '../../screens/brackets/hub/journey_config.dart';
import 'parenting_journeys.dart';
import 'pregnancy_journeys.dart';
import 'ttc_journeys.dart';

/// Every journey in the app, keyed by the door action that opens it.
final Map<String, JourneyConfig> kAllJourneys = {
  ...kPregnancyJourneys,
  ...kParentingJourneys,
  ...kTtcJourneys,
};

/// The journey behind [action], or null when the door goes straight through.
JourneyConfig? journeyFor(String action) => kAllJourneys[action];
