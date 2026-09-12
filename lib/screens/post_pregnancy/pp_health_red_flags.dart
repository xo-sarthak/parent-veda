// =============================================================================
//  The one "go to a hospital now" list
// -----------------------------------------------------------------------------
//  ⚠️ THREE HAND-WRITTEN COPIES BECAME ONE. The Health door brief: "the
//  red-flag list is copied in three places and will drift" — the Get help now
//  page, the fever red-flags page and the fever check's gate each had their
//  own wording. A red flag that one copy has and another lacks is the worst
//  kind of drift, because nobody reading either screen can see the gap.
//
//  So the list lives here, as plain lines, and the three read it. The page
//  joins it into a callout; the tool lists it as the gate; a test asserts the
//  tool's gate IS this list.
//
//  REQUIRED_REVIEW: EVERY LINE, BY A PAEDIATRICIAN, BEFORE RELEASE. This is
//  the single most consequential list in the parenting app. Merged from the
//  three copies; nothing was dropped, so it is the union of what each said.
// =============================================================================

/// Each line is one sign, phrased so it reads alone on a gate and reads
/// joined in a callout.
const List<String> kPpGoNowSigns = [
  'Breathing hard: fast breaths, ribs sucking in under the chest, nostrils '
      'flaring, or a grunt on every breath',
  'Blue or grey lips, tongue or face',
  'A fit or seizure of any kind',
  'Floppy, or you cannot wake him properly',
  'A fever of 100.4 F or 38 C in a baby under three months',
  'A rash that does not fade when you press a clear glass on it',
  'No urine for twelve hours, or no tears when crying',
  'A bulging or sunken soft spot',
  'Cold, mottled or blue hands and feet',
  'Green or yellow vomit with a swollen, tender belly',
  'Constant crying you cannot settle at all',
];
