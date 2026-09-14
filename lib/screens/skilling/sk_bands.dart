// =============================================================================
//  SkBand — the three skilling bands, and the age floor
// -----------------------------------------------------------------------------
//  The parenting side has `pp_age_bands.dart`, per-section bands in months.
//  Skilling is the opposite shape: ONE band set for all twelve doors, in
//  years, fixed by the Coding v2 brief and repeated by every brief after it
//  ("same age boundaries as the shell"). A door names its own band labels
//  (Coding: Unplugged / Blocks / Projects; Communication: Say it out loud /
//  Tell it and explain it / Say what you think) but never its own boundaries.
//
//  ⚠️ INCLUSIVE LOWER, EXCLUSIVE UPPER — parenting's rule, kept. An
//  eight-year-old is in 8 to 11, not 6 to 8.
//
//  ⚠️ NO FALLBACK UNDER THE FLOOR. `PpBandSet.bandFor` falls back to the first
//  band for an age below it, because a parenting section must never open
//  empty. Skilling has an AGE FLOOR (6) written into the brief's own header,
//  and the user's call (2026-09-14) is that a younger child sees every child
//  tab LOCKED with "From 6 years" and the grown-up side open. So `bandFor`
//  returns null under six, and every consumer has to say what it does about
//  that — which is the point: the floor is a state, not an off-by-one.
//
//  Fourteen and over reads the top band. The brief: "A fourth band for 14+ is
//  easy to add later. Three is the honest start." Until it exists, the top
//  rung is the honest content for a teenager, and `test/sk_coding_door_test`
//  holds that a fifteen-year-old still sees Projects rather than nothing.
// =============================================================================

/// One skilling band. `id` is the stable slug every door's pages tag.
class SkBand {
  const SkBand({
    required this.id,
    required this.fromYears,
    required this.toYears,
    required this.label,
  });

  final String id;

  /// Inclusive.
  final int fromYears;

  /// Exclusive.
  final int toYears;

  /// The shell's own label — "6 to 8". A door overrides it on screen with
  /// its own name for the rung (`SkDoorContent.bandName`).
  final String label;

  bool contains(int years) => years >= fromYears && years < toYears;
}

/// The age floor. Written once.
const int kSkAgeFloor = 6;

/// The three bands, in order. The ids are what the task PDFs call the band
/// ("band: 6-8"), so a content fill maps without a lookup table.
const List<SkBand> kSkBands = [
  SkBand(id: '6-8', fromYears: 6, toYears: 8, label: '6 to 8'),
  SkBand(id: '8-11', fromYears: 8, toYears: 11, label: '8 to 11'),
  SkBand(id: '11-14', fromYears: 11, toYears: 14, label: '11 to 14'),
];

/// The band for an age in years, or null under the floor.
SkBand? skBandFor(int years) {
  if (years < kSkAgeFloor) return null;
  for (final b in kSkBands) {
    if (b.contains(years)) return b;
  }
  return kSkBands.last;
}

SkBand? skBandById(String id) {
  for (final b in kSkBands) {
    if (b.id == id) return b;
  }
  return null;
}

/// The index of a band in the ladder — 0 for the bottom rung.
int skBandRung(String bandId) => kSkBands.indexWhere((b) => b.id == bandId);
