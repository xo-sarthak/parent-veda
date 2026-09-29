// =============================================================================
//  Signs to get help the same day
// -----------------------------------------------------------------------------
//  The pinned red flag on the Complications door's safety tab.
//
//  ---------------------------------------------------------------------------
//  ⚠️ ASSEMBLED, NEVER AUTHORED. THIS IS THE STRICTEST RULE IN THE BRIEF.
//  ---------------------------------------------------------------------------
//
//  Its words: *"One plain list assembled from the existing CALL NOW sections
//  across conditions… No new medical advice; assemble only."*
//
//  So every entry below points at a condition that already ships, and the
//  sentence a mother reads is drawn from THAT PAGE'S OWN `callNow` list rather
//  than typed here. `test/pv_door_complications_test.dart` asserts each id
//  resolves and that its plain line matches something the condition actually
//  says.
//
//  ⚠️ WHY THAT MATTERS MORE HERE THAN ANYWHERE ELSE ON THE DOOR. A red-flag
//  list is the one surface where being wrong has a body count. Twenty-seven
//  condition pages were written and clinically reviewed with their call-now
//  lists; a twenty-eighth list typed fresh into a data file for a landing has
//  had none of that, and it would sit ABOVE all of them in the reader's
//  attention. Assembling is how the pinned list inherits the review the pages
//  already passed.
//
//  ⚠️ AND THE FIVE ARE THE BRIEF'S OWN FIVE, in its order: bleeding; a bad
//  headache with blurred eyes or swelling; the baby moving less than usual;
//  high fever; waters breaking early. Not a ranking — it is roughly the order
//  a pregnancy meets them.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE PLAIN-LANGUAGE RULE APPLIES HARDEST TO A RED FLAG
//  ---------------------------------------------------------------------------
//
//  The brief: *"Never put a bare medical word as a list label, a section
//  heading, or a red-flag line."* Nothing below says antepartum haemorrhage,
//  preeclampsia, or premature rupture of membranes. A woman reading this is
//  frightened and scanning; a word she has to decode is a word she skips.
//
//  The condition each line opens still carries its medical name as its title,
//  which is where a name belongs — see `ConditionEntry.name`.
// =============================================================================

/// One line on the pinned list, and the page it opens.
class SameDaySign {
  const SameDaySign({
    required this.line,
    required this.conditionId,
    required this.because,
  });

  /// What she reads. Plain, short, and never a diagnosis — it describes what
  /// she would notice, not what it would mean.
  final String line;

  /// The condition page this opens. Must exist in `kAllConditions`.
  ///
  /// ⚠️ THE LINE OPENS THE FULLER PAGE, which is the brief's instruction and
  /// also the honest one: five sentences cannot carry a decision, and the page
  /// behind each has the symptoms, the tests, and what happens next.
  final String conditionId;

  /// Which condition's call-now list this line was assembled from.
  ///
  /// ⚠️ IT IS THE SAME ID AS [conditionId] TODAY AND THEY ARE NOT THE SAME
  /// FIELD. `conditionId` is where the tap goes; this records where the WORDS
  /// came from. They would diverge the moment a line is assembled from one
  /// page's list but is better answered by another's — and at that point the
  /// test that checks the wording has to know which page to check against.
  final String because;
}

/// The five, in the brief's order.
const List<SameDaySign> kSameDaySigns = [
  SameDaySign(
    line: 'Any bleeding from the vagina, from spotting to heavier.',
    conditionId: 'placenta_previa',
    because: 'placenta_previa',
  ),
  SameDaySign(
    line: "A bad headache that won't ease, with blurred eyes or sudden "
        'swelling in your face or hands.',
    conditionId: 'preeclampsia',
    because: 'preeclampsia',
  ),
  SameDaySign(
    line: 'Your baby moving less than usual, on any day.',
    conditionId: 'iugr',
    because: 'iugr',
  ),
  SameDaySign(
    line: 'A high fever, especially with chills or feeling very unwell.',
    conditionId: 'uti',
    because: 'uti',
  ),
  SameDaySign(
    line: 'Water leaking, or a gush of fluid, before your due weeks.',
    conditionId: 'cervical_incompetence',
    because: 'cervical_incompetence',
  ),
];

/// The line that sits under the list.
///
/// ⚠️ THE BRIEF ASKS FOR IT IN SO MANY WORDS: *"State plainly this tells you
/// when to call and never replaces calling a doctor or going in."*
///
/// It is here rather than in the widget because it is content, and because the
/// widget is shared with every other door's pinned flag — a sentence typed into
/// a renderer is a sentence that appears on somebody else's warning.
// Rewritten 2026-09-29 to docs/PREG-VOICE.md (no dash, contractions); the
// two clauses the test holds are unchanged.
const String kSameDayFooter =
    'This tells you when to call. It never replaces calling your doctor or '
    "going in. If something feels wrong and it isn't on this list, call "
    'anyway.';
