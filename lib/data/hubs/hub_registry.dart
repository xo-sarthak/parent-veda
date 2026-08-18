// =============================================================================
//  Hub registry — what a bracket tile actually opens
// -----------------------------------------------------------------------------
//  One lookup for all four stages. A tile on a V3 home asks this what to do and
//  gets one of two answers:
//
//    · a hub with 2+ doors  -> push the hub screen, she picks
//    · a hub with ONE door  -> push that door's destination, no hub screen
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE ONE-DOOR CASE IS THE WHOLE REASON THIS FILE EXISTS
//  ---------------------------------------------------------------------------
//  Twenty-three of the forty hubs came out of the door audit with a single
//  door, and in every one of those the door only restates the tile she already
//  tapped: "Symptoms & discomforts" -> "I have a symptom". Rendering a hub
//  screen there shows a heading and one button, which is a tap of pure tax.
//
//  So the count is not a style preference — it is a routing instruction. The
//  test is REDUNDANCY, not arithmetic: a hub screen earns its place only when
//  it has something to disambiguate.
//
//  ⚠️ AND THE SINGLE DOOR IS STILL WRITTEN AS A CONFIG rather than as a bare
//  route, because the config is where the door's destination, promise and mark
//  are declared. Skipping the screen must not mean skipping the thinking.
// =============================================================================

import '../../screens/brackets/hub/hub_config.dart';
import 'parenting_hubs.dart';
import 'pregnancy_hubs.dart';
import 'scans_hub_v2.dart';
import 'ttc_hubs.dart';

/// Every hub in the app, keyed by bracket id.
///
/// ⚠️ SCANS & TESTS RESOLVES TO ITS V2 HERE, and its V1 is reached only through
/// the toggle on its own screen. Nothing else has a V1 worth comparing against
/// — the other thirty-nine open a generic placeholder today, which is not a
/// design, so a toggle would compare a thing to nothing.
///
/// ⚠️ SKILLING IS ABSENT ON PURPOSE. Its twelve areas are one picker behind a
/// debug gate, not twelve hubs, and the gate stays shut until there is content
/// behind the doors — see `explore_drawer.dart`. Twelve doors onto twelve empty
/// rooms is the filler this whole restructure removed.
final Map<String, HubConfig> kHubsByBracket = {
  for (final h in [
    kScansHubV2,
    ...kPregnancyHubs,
    ...kParentingHubs,
    ...kTtcHubs,
  ])
    h.bracketId: h,
};

/// What tapping [bracketId] should do. Null when no hub is defined for it —
/// the caller falls back to whatever it did before, rather than opening
/// nothing.
HubConfig? hubFor(String bracketId) => kHubsByBracket[bracketId];

/// True when this bracket should push the hub screen; false when the tile
/// should open its single door's destination directly.
bool showsHubScreen(String bracketId) {
  final h = kHubsByBracket[bracketId];
  return h != null && h.needs.length > 1;
}

/// The single door of a one-door hub, or null.
///
/// Callers use this to route straight through. Returning null for a multi-door
/// hub is deliberate: it makes "did you mean to skip the screen?" a compile-time
/// shape rather than a judgement at every call site.
HubNeed? soleDoorOf(String bracketId) {
  final h = kHubsByBracket[bracketId];
  if (h == null || h.needs.length != 1) return null;
  return h.needs.first;
}
