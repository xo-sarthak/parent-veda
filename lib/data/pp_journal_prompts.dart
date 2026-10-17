// =============================================================================
//  The parenting journal's question for this month (2026-10-17)
// -----------------------------------------------------------------------------
//  The pregnancy journal asks a question for her week (`journal_prompts.dart`);
//  the parenting journal now asks one for the child's age, on the same card.
//  A blank page makes her decide what is worth keeping; a question does that
//  for her.
//
//  ⚠️ WRITTEN WITHOUT PRONOUNS. A parent of a daughter read "he" across the
//  parenting app until the pronoun getters came in (pp_child_profile.dart).
//  These are asked to the parent ("you"), about "your baby" / "your child",
//  so they read right for every child with no switch to get wrong.
//
//  The note under each band is a population line ("many babies"), never a
//  milestone she is measured against — the clinical rule: no personal targets.
// =============================================================================

/// One age band: the months it starts at, its questions, and a gentle line
/// about the age.
class PpPromptBand {
  const PpPromptBand(this.fromMonths, this.note, this.questions);
  final int fromMonths;
  final String note;
  final List<String> questions;
}

const List<PpPromptBand> kPpPromptBands = [
  PpPromptBand(0, 'The first weeks are mostly feeds, sleep and holding. That is plenty to remember.', [
    'Who was the first person to hold your baby, after you?',
    'What did the first night at home feel like?',
    'Which little sound does your baby make that you never want to forget?',
    'Who has come to help you these weeks, and what did they do?',
    'What does your baby smell like? Try to put it into words.',
    'What did you call your baby before the name stuck?',
  ]),
  PpPromptBand(3, 'Around now, many babies start to laugh out loud.', [
    'What sound greets you in the morning now?',
    'Who can make your baby laugh the fastest?',
    'What do those hands reach for first?',
    'Which song settles your baby every time?',
    'What made you both smile today?',
    'Where is your baby\'s favourite place to be held?',
  ]),
  PpPromptBand(6, 'Many babies start trying new tastes and sitting up in these months.', [
    'What was the first food, and what face came with it?',
    'What does your baby do when you walk into the room?',
    'Which toy is always within reach right now?',
    'What did your baby notice today that you had stopped noticing?',
    'Who in the family does your baby look like this month?',
    'What is bath time like these days?',
  ]),
  PpPromptBand(12, 'A year in. Many children are finding their feet and their first words.', [
    'What was the first word you were sure about?',
    'Where does your child go first when let loose in a room?',
    'What makes your child laugh hardest this month?',
    'What did the first birthday look like?',
    'What does your child hand you to say "play with me"?',
    'Which family saying has your child started to copy?',
  ]),
  PpPromptBand(24, 'Questions, opinions and stories start arriving around now.', [
    'What question did your child ask today that you could not answer?',
    'What is the favourite story right now, and who reads it best?',
    'What did your child insist on doing alone today?',
    'Who is your child\'s best friend this month?',
    'What did your child say today that you want to remember word for word?',
    'What does your child want to be when they grow up, this week?',
  ]),
];

/// The band for a child [months] old.
PpPromptBand ppPromptBandFor(int months) {
  var band = kPpPromptBands.first;
  for (final b in kPpPromptBands) {
    if (months >= b.fromMonths) band = b;
  }
  return band;
}

/// The question for a child [months] old, turned [skip] times by "Another".
String ppJournalPromptFor(int months, {int skip = 0}) {
  final qs = ppPromptBandFor(months).questions;
  return qs[(months + skip) % qs.length];
}

int ppJournalPromptCount(int months) => ppPromptBandFor(months).questions.length;
