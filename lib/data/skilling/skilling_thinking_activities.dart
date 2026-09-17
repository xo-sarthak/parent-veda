// =============================================================================
//  Critical thinking & first principles — the activity set, scaffolded per band
// -----------------------------------------------------------------------------
//  `ParentVeda_Thinking_structure.pdf`: "The heart. A full set per band, each
//  on one of the six moves, reasoning about concrete things, tagged, honest
//  end-line, no score. The good question is celebrated over the right
//  answer."
//
//  ⚠️ THIRTY-SIX SLOTS, ALL COMING SOON, NO COPY. No task PDF exists for this
//  door yet; the fills land here when it does. Ids follow the shape the
//  other doors take — `th_68_01` … `th_1114_12`, two per move in the door's
//  move order.
//
//  ⚠️ THE SIX ARE MOVES, PRACTISED ON REAL THINGS. The brief: "Critical
//  thinking does not transfer as an abstract drill; it grows from reasoning
//  about real things. So these are practised on concrete stuff a child
//  knows, not on logic puzzles in a vacuum." The labels and lines are the
//  brief's table, in the child's words. "The last one is the whole point."
//
//  ⚠️ QUESTION IDEAS, NOT PEOPLE (the user's call, 2026-09-17, 1a: the
//  careful framing). Every fill that lands here checks claims, forwards and
//  arguments, and keeps "respect the person" and "question the idea"
//  clearly apart. Nothing here is "argue with your parents". The
//  Communication fill already carries the line ("question ideas, not
//  people"); this door is where it lives.
// =============================================================================

import '../../screens/skilling/sk_content.dart';

const List<SkSkillPurpose> kSkThinkingSkills = [
  SkSkillPurpose(
    id: 'asking_why',
    label: 'Asking why',
    kidLine: 'Following the chain of why instead of taking "because that is '
        'how it is". Getting to the real reason.',
  ),
  SkSkillPurpose(
    id: 'breaking_it_down',
    label: 'Breaking it down',
    kidLine: 'Taking a big or confusing thing apart into the bits you '
        'actually know for sure.',
  ),
  SkSkillPurpose(
    id: 'checking_if_true',
    label: "Checking if it's true",
    kidLine: 'Is this right? How would I know? Who is saying it, and why? '
        'The defence against a fake forward.',
  ),
  SkSkillPurpose(
    id: 'seeing_the_other_side',
    label: 'Seeing the other side',
    kidLine: 'What would someone who disagrees say? Holding more than one '
        'view before picking.',
  ),
  SkSkillPurpose(
    id: 'spotting_a_bad_argument',
    label: 'Spotting a bad argument',
    kidLine: 'Noticing when something does not follow, when there is a '
        'trick or a jump in the middle.',
  ),
  SkSkillPurpose(
    id: 'changing_your_mind',
    label: 'Changing your mind',
    kidLine: 'Being fine to be wrong, and updating when you learn something '
        'new. The heart of the whole door.',
  ),
];

const List<String> _moveOrder = [
  'asking_why', 'asking_why',
  'breaking_it_down', 'breaking_it_down',
  'checking_if_true', 'checking_if_true',
  'seeing_the_other_side', 'seeing_the_other_side',
  'spotting_a_bad_argument', 'spotting_a_bad_argument',
  'changing_your_mind', 'changing_your_mind',
];

List<SkActivity> _band(String band, String idBand) => [
      for (final (i, move) in _moveOrder.indexed)
        SkActivity(
          id: 'th_${idBand}_${(i + 1).toString().padLeft(2, '0')}',
          band: band,
          skillPurpose: move,
          title: 'Activity ${i + 1}',
          comingSoon: true,
        ),
    ];

final List<SkActivity> kSkThinkingActivities = [
  ..._band('6-8', '68'),
  ..._band('8-11', '811'),
  ..._band('11-14', '1114'),
];
