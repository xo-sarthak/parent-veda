// =============================================================================
//  What to ask at your next scan
// -----------------------------------------------------------------------------
//  The checklist behind sub-tab 5's one new card. Written new, because nothing
//  in the app answered "what should I actually say in there".
//
//  ⚠️ THE APP ALREADY HAS QUESTION LISTS AND THEY ARE A DIFFERENT THING.
//  `ReportFinding.questions` gives three questions per finding — "has the
//  placenta moved since my last scan?" — and those are excellent AFTER a report
//  names something. They are reused where they belong, on the finding pages.
//  This list is for BEFORE, when nothing has been found yet and the question
//  is what to ask about an appointment she has not had.
//
//  ⚠️ WHY THIS IS DATA AND NOT PROSE IN A GUIDE. "Take it to your appointment"
//  is the guide, and it explains how to use ten minutes. This is the thing you
//  carry: ticked, counted, and read off a phone in a corridor. A checklist is
//  an object you operate; an article is something you read. The two are not
//  the same format and the chip on the card says which one she is getting.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NOT ONE OF THESE ASKS US TO INTERPRET ANYTHING
//  ---------------------------------------------------------------------------
//
//  Every line is a question for her doctor. None of them is a threshold, a
//  number to check, or a self-assessment, and none implies a right answer. That
//  is the clinical line this file has to hold: where a clinician owns a
//  decision we may explain it, remind about it, or help her PREPARE for it —
//  and a list of questions is the purest form of the third. See CLAUDE.md's
//  clinical ownership rule.
//
//  ⚠️ AND THE IDS ARE IDENTITIES. `ScanQuestionsStore` persists them, so
//  renaming one strands whatever she had ticked. Reword the text freely; leave
//  the id alone.
// =============================================================================

/// One question, in a group.
class ScanQuestion {
  const ScanQuestion(this.id, this.text);

  /// Persisted verbatim by `ScanQuestionsStore`. An identity, not a label.
  final String id;

  /// Written the way she would say it out loud, not the way a form would ask
  /// it. Short enough to read off a phone without scrolling.
  final String text;
}

/// A heading and the questions under it.
class ScanQuestionGroup {
  const ScanQuestionGroup(this.heading, this.questions);
  final String heading;
  final List<ScanQuestion> questions;
}

/// The list. Four groups, in the order the appointment happens.
///
/// ⚠️ ORDERED BY THE VISIT, NOT BY IMPORTANCE. She reads this in a corridor
/// with minutes to spare, and a list that runs before / during / after / next
/// can be skimmed against where she is. Ranking them instead would mean the
/// question she needs at the desk is somewhere in the middle.
const List<ScanQuestionGroup> kScanQuestions = [
  ScanQuestionGroup('Before the day', [
    ScanQuestion('prep_fast',
        'Do I need to fast, or drink water before I come?'),
    ScanQuestion('prep_how_long', 'How long will it take?'),
    ScanQuestion('prep_bring',
        'What should I bring — old reports, my card, anything else?'),
    ScanQuestion('prep_partner', 'Can someone come in with me?'),
    ScanQuestion('prep_cost',
        'What will it cost, and is the report included in that?'),
  ]),

  ScanQuestionGroup('About this scan', [
    ScanQuestion('scan_what_for', 'What are you looking for in this one?'),
    ScanQuestion('scan_why_now', 'Why is it done at this week and not another?'),
    ScanQuestion('scan_needed',
        'Is this one you are asking for, or one that is available?'),
    ScanQuestion('scan_repeat',
        'How likely is it that I will need to come back for a repeat?'),
  ]),

  ScanQuestionGroup('When I get the report', [
    ScanQuestion('rep_when', 'When will the report be ready, and who gives it '
        'to me?'),
    ScanQuestion('rep_explain', 'Who will explain it — you, or someone here?'),
    ScanQuestion('rep_normal',
        'What would count as an ordinary result for this scan?'),
    ScanQuestion('rep_copy',
        'Can I have a copy of the report and the films to keep?'),
  ]),

  ScanQuestionGroup('What happens next', [
    ScanQuestion('next_change',
        'Would anything in this result change my delivery plan?'),
    ScanQuestion('next_when', 'When do I see you again, and what is next after '
        'this?'),
    // ⚠️ THE ONE QUESTION EVERY DOCTOR HAS AN ANSWER TO AND FEW SAY OUT LOUD.
    // Every clinician carries a threshold for "call me before your next
    // appointment". Asking for it is the single highest-value line on this
    // list, which is why it is last — the last thing read is the thing
    // remembered walking out.
    ScanQuestion('next_call',
        'What would make you want me to call before the next visit?'),
  ]),
];

/// Every question, flattened. What the store's ids are checked against.
List<ScanQuestion> get kScanQuestionsFlat =>
    [for (final g in kScanQuestions) ...g.questions];
