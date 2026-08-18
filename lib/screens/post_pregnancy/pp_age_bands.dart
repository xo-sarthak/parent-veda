// =============================================================================
//  PpBand / PpBandSet — age-banding, built once for all eleven sections
// -----------------------------------------------------------------------------
//  ⚠️ NEARLY EVERY PARENTING SPEC ASKS FOR THE SAME MECHANISM IN DIFFERENT
//  WORDS, AND THE REASON IS ALWAYS THE SAME FAILURE:
//
//    Behaviour:      "so a parent of a 3-month-old never sees an empty tantrum
//                     library"
//    Potty:          "a newborn parent sees the gentle su-su intro, a 2-year
//                     parent sees the real training content"
//    You, Maa:       "a mother 4 months in must not see day-1 healing content"
//    Early Learning: "must be heavily age-gated so it never reads as a
//                     placeholder"
//
//  All four describe one thing: content that exists for a different child than
//  the one this parent has. Eleven sections each writing their own `if (months <
//  12)` would work and would drift — a boundary written as `< 12` in one file
//  and `<= 12` in another puts a one-year-old in two bands at once.
//
//  ⚠️ THE BANDS THEMSELVES ARE PER-SECTION, AND THAT IS NOT A COMPROMISE.
//  Behaviour bands 0-1y / 1-2y / 2-3y / 3-5y because that is where behaviour
//  changes. "You, Maa" bands 0-6w / 6w-3m / 3-6m / 6m+ because that is how
//  postpartum recovery moves, and it measures the MOTHER's time since birth.
//  Forcing one shared set would push every section into whichever compromise
//  fitted none of them. So: one mechanism, per-section band definitions.
//
//  ⚠️ AND BANDING NARROWS WHAT LEADS, NEVER WHAT EXISTS. This repo's rule —
//  enforced by `test/landing_focus_test.dart` — is that personalisation changes
//  ranking and order, never structure. Every spec agrees independently ("other
//  bands stay browsable; the child's own band leads"). So `activeBand` decides
//  what opens first and `all` stays reachable. A band is never a lock.
// =============================================================================

import 'pp_child_profile.dart';

/// One age band within a section.
class PpBand {
  const PpBand({
    required this.id,
    required this.label,
    required this.fromMonths,
    required this.toMonths,
    this.blurb,
  });

  /// Stable slug, used by `PpPage.bands`. Not derived from the label.
  final String id;

  /// What a parent reads — "0 to 12 months", "Crying and temperament".
  final String label;

  /// ⚠️ INCLUSIVE LOWER, EXCLUSIVE UPPER. Stated here once so no section has to
  /// decide it. A 12-month-old is in the band starting at 12, not the one ending
  /// there — which is the off-by-one that puts one child in two bands.
  final int fromMonths;

  /// Exclusive. Use a large number for the open-ended top band rather than a
  /// nullable, so `contains` needs no null branch and cannot be got wrong.
  final int toMonths;

  final String? blurb;

  bool contains(int months) => months >= fromMonths && months < toMonths;
}

/// A section's ordered bands.
class PpBandSet {
  const PpBandSet(this.bands);
  final List<PpBand> bands;

  /// The band this child is in.
  ///
  /// ⚠️ FALLS BACK TO THE FIRST BAND, NOT TO NULL. A null would make every call
  /// site handle "no band", and the honest answer for an age below the first band
  /// is the youngest content — a section must never open empty. `ChildProfileStore`
  /// starts a child at age zero deliberately (see its own note), so age 0 is the
  /// common case, not an edge one.
  PpBand bandFor(int months) {
    for (final b in bands) {
      if (b.contains(months)) return b;
    }
    return months < bands.first.fromMonths ? bands.first : bands.last;
  }

  /// The band for the child currently active in `ChildProfileStore`.
  PpBand get active => bandFor(ChildProfileStore.instance.ageInMonths);

  /// The bands in the order they should be shown: the child's own first, then
  /// the rest in their natural order.
  ///
  /// ⚠️ REORDERED, NOT FILTERED — the distinction this whole file rests on. A
  /// parent of a two-year-old who wants to read ahead about a four-year-old can;
  /// she simply does not have to scroll past it to reach her own.
  List<PpBand> get ordered {
    final mine = active;
    return [mine, ...bands.where((b) => b.id != mine.id)];
  }

  PpBand? byId(String id) {
    for (final b in bands) {
      if (b.id == id) return b;
    }
    return null;
  }
}

/// Days since birth, for the sections whose spine is days rather than months.
///
/// "Jaapa: Your First 40 Days" is the case: a 0-to-40-day spine cannot be
/// expressed in months at all, and month-banding a section whose entire subject
/// is the first six weeks would put every reader in one band.
int get ppDaysSinceBirth => ChildProfileStore.instance.ageInDays;

int get ppMonthsSinceBirth => ChildProfileStore.instance.ageInMonths;

// =============================================================================
//  THE SHARED BAND SETS
// -----------------------------------------------------------------------------
//  Defined here rather than in each section's data file so two sections that
//  genuinely share a shape share the definition. Sections with their own shape
//  declare it in their own file and that is expected.
// =============================================================================

/// The child-development bands: the ones most sections use.
const PpBandSet kPpChildBands = PpBandSet([
  PpBand(
    id: 'infant',
    label: '0 to 12 months',
    fromMonths: 0,
    toMonths: 12,
  ),
  PpBand(
    id: 'toddler_1',
    label: '1 to 2 years',
    fromMonths: 12,
    toMonths: 24,
  ),
  PpBand(
    id: 'toddler_2',
    label: '2 to 3 years',
    fromMonths: 24,
    toMonths: 36,
  ),
  PpBand(
    id: 'preschool',
    label: '3 to 5 years',
    fromMonths: 36,
    toMonths: 72,
  ),
]);

/// Sleep's bands, which are finer in the first year because sleep changes
/// fastest there — a newborn and a nine-month-old have almost nothing in common
/// on this subject, and one "0 to 12 months" band would have to describe both.
const PpBandSet kPpSleepBands = PpBandSet([
  PpBand(id: 'nb', label: 'Newborn, 0 to 3 months', fromMonths: 0, toMonths: 3),
  PpBand(id: 'm3_6', label: '3 to 6 months', fromMonths: 3, toMonths: 6),
  PpBand(id: 'm6_12', label: '6 to 12 months', fromMonths: 6, toMonths: 12),
  PpBand(id: 'tod', label: 'Toddler, 1 to 3 years', fromMonths: 12, toMonths: 36),
  PpBand(
      id: 'pre', label: 'Preschooler, 3 to 5 years', fromMonths: 36, toMonths: 72),
]);

/// ⚠️ THE MOTHER'S BANDS, NOT THE CHILD'S — and they happen to be measured by
/// the same clock.
///
/// "You, Maa" bands by her time since birth, which equals the baby's age. The
/// numbers are identical to a child band set and the MEANING is not: 0-6 weeks
/// here is her healing, not her baby's newborn stage. Kept separate and named
/// for her, because the moment someone reuses `kPpChildBands` for her recovery,
/// a band boundary later moved for a reason about babies silently moves her
/// six-week check.
const PpBandSet kPpPostpartumBands = PpBandSet([
  PpBand(
    id: 'pp_0_6w',
    label: 'The first 6 weeks',
    fromMonths: 0,
    toMonths: 2,
    blurb: 'Healing, rest, and the things nobody warned you about.',
  ),
  PpBand(
    id: 'pp_6w_3m',
    label: '6 weeks to 3 months',
    fromMonths: 2,
    toMonths: 3,
    blurb: 'Cleared to move again, and finding out what that feels like.',
  ),
  PpBand(
    id: 'pp_3_6m',
    label: '3 to 6 months',
    fromMonths: 3,
    toMonths: 6,
    blurb: 'Strength, sleep debt, and feeling like yourself.',
  ),
  PpBand(
    id: 'pp_6m',
    label: '6 months and beyond',
    fromMonths: 6,
    toMonths: 600,
    blurb: 'Going back to work, or choosing not to.',
  ),
]);
