// =============================================================================
//  My Journal — this week's question
// -----------------------------------------------------------------------------
//  2026-09-23. A blank page asks her to decide what is worth keeping; a
//  question tied to where she is does that for her (Apple Journal's
//  suggestions, stoic.'s weekly themes, 5 Minute Journal's prompts — every
//  journal on Mobbin that people keep coming back to opens on one).
//
//  ⚠️ WRITTEN FOR THE CHILD WHO READS IT LATER. Each question is one a grown
//  child would want answered — how you found out, who you told, what you were
//  afraid of — not a wellness check-in about her mood. The journal's promise
//  is "a memory for your baby to show when it grows up", and these are the
//  questions that keep it.
//
//  ⚠️ NEVER CLINICAL, NEVER A SCORE. No "how many kicks today", no symptom
//  prompts: those have their own tools. Nothing here asks her to rate or
//  measure anything.
// =============================================================================

/// The questions for a stretch of weeks, from [from] to [to] inclusive.
class _Band {
  const _Band(this.from, this.to, this.questions);
  final int from;
  final int to;
  final List<String> questions;
}

const List<_Band> _bands = [
  _Band(1, 8, [
    'How did you find out? Where were you standing?',
    'Who was the first person you told, and what did they say?',
    'What did you do in the hour after you knew?',
    'What is one thing you hope stays exactly the same about your life?',
    'What were you secretly afraid of this week?',
  ]),
  _Band(9, 13, [
    'What have you been craving, and who went out to get it?',
    'Is there a song you keep playing right now?',
    'What does home look like these days — the room, the light, the mess?',
    'What did the first scan feel like, before anyone said a word?',
    'Who do you most want your baby to meet?',
  ]),
  _Band(14, 19, [
    'Which names are on the list, and which one did someone laugh at?',
    'What is a small thing you have started doing for your baby already?',
    'What advice have you been given that you are quietly ignoring?',
    'What was your own mother like at your age?',
    'What do you want your baby to know about the family they are joining?',
  ]),
  _Band(20, 27, [
    'Describe the first time you felt them move.',
    'What does your partner say to the bump when they think you are not listening?',
    'What story do you want to tell them first?',
    'What are you making, buying or keeping for them?',
    'What is the kindest thing someone has done for you this month?',
  ]),
  _Band(28, 33, [
    'What do you want to remember about your body right now?',
    'Who has been looking after you, and how?',
    'What do you already know about their personality from the way they move?',
    'Write down one thing you promise them.',
    'What are you most looking forward to teaching them?',
  ]),
  _Band(34, 42, [
    'What is in the bag by the door, and what did you almost forget?',
    'Write what you want them to know on their very first day.',
    'What will you miss about this time, just the two of you?',
    'What do you imagine their face looks like?',
    'Write a letter for them to open on their eighteenth birthday.',
  ]),
];

List<String> _questionsFor(int week) {
  for (final b in _bands) {
    if (week >= b.from && week <= b.to) return b.questions;
  }
  return _bands.last.questions;
}

/// This week's question, and the next ones when she asks for another.
///
/// Stable within a week — the same question every time she opens the journal
/// this week, so it reads as the week's question, not a random one. [skip]
/// walks to the next in the band.
String journalPromptFor(int week, {int skip = 0}) {
  final qs = _questionsFor(week);
  return qs[(week + skip) % qs.length];
}

/// How many different questions a week can offer.
int journalPromptCount(int week) => _questionsFor(week).length;
