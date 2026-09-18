// =============================================================================
//  Emotional intelligence & resilience — the activity set, scaffolded per band
// -----------------------------------------------------------------------------
//  `ParentVeda_Feelings_structure.pdf`: "The heart, two strands. Scenarios
//  (think through a real situation, safer, external) and journaling (write
//  the harder ones down, private, sensitive). Per band, tied to a skill,
//  honest end-line, no score."
//
//  ⚠️ THIRTY-SIX SLOTS, ALL COMING SOON, NO COPY — AND THIS DOOR'S COPY NEEDS
//  CLINICAL REVIEW BEFORE IT SHIPS. The brief marks the content "care", not
//  "build now": "This content needs review by a child psychologist before
//  it ships." So a task PDF for this door goes to a clinician before it
//  comes here; the ledger (FE1–FE3) says so. Ids follow the shape the other
//  doors take — `fe_68_01` … `fe_1114_12`, two per skill in the door's
//  skill order.
//
//  ⚠️ THE SIX ARE SEL SKILLS, NOT THINGS TO RATE. "Nothing here is ever
//  scored: you cannot rate a child's feelings." The labels and lines are
//  the brief's table, in the child's words. "The last one, asking for help,
//  is also the door's safety off-ramp, built in as an ordinary skill rather
//  than an emergency."
//
//  ⚠️ RESILIENCE MEANS RECOVERING, NOT TOUGHENING UP. The brief: "The word
//  gets misused to mean suppress your feelings, be strong, get over it,
//  which is harmful and culturally common here, 'log kya kahenge', 'boys
//  don't cry'. This door's honest heart is name it, feel it, find your way
//  through." Every fill is held to that line.
// =============================================================================

import '../../screens/skilling/sk_content.dart';

const List<SkSkillPurpose> kSkFeelingsSkills = [
  SkSkillPurpose(
    id: 'naming_it',
    label: 'Naming it',
    kidLine: 'Knowing what you feel, and giving it a name. You cannot '
        'handle a feeling you cannot name, so this comes first.',
  ),
  SkSkillPurpose(
    id: 'feeling_its_okay',
    label: "Feeling it's okay",
    kidLine: 'All feelings are allowed. They are information, not good or '
        'bad. The opposite of "be tough".',
  ),
  SkSkillPurpose(
    id: 'handling_the_big_ones',
    label: 'Handling the big ones',
    kidLine: 'What to do when a feeling is huge, anger, worry, so you can '
        'settle instead of being swept away.',
  ),
  SkSkillPurpose(
    id: 'reading_others',
    label: 'Reading others',
    kidLine: 'Noticing how someone else is feeling.',
  ),
  SkSkillPurpose(
    id: 'bouncing_back',
    label: 'Bouncing back',
    kidLine: 'After something hard, losing, failing, a fight, finding your '
        'way back. Recovery, not toughening up.',
  ),
  SkSkillPurpose(
    id: 'asking_for_help',
    label: 'Asking for help',
    kidLine: 'Knowing it is okay to tell a trusted grown-up when something '
        'is too big, and knowing who your people are.',
  ),
];

const List<String> _skillOrder = [
  'naming_it', 'naming_it',
  'feeling_its_okay', 'feeling_its_okay',
  'handling_the_big_ones', 'handling_the_big_ones',
  'reading_others', 'reading_others',
  'bouncing_back', 'bouncing_back',
  'asking_for_help', 'asking_for_help',
];

List<SkActivity> _band(String band, String idBand) => [
      for (final (i, skill) in _skillOrder.indexed)
        SkActivity(
          id: 'fe_${idBand}_${(i + 1).toString().padLeft(2, '0')}',
          band: band,
          skillPurpose: skill,
          title: 'Activity ${i + 1}',
          comingSoon: true,
        ),
    ];

final List<SkActivity> kSkFeelingsActivities = [
  ..._band('6-8', '68'),
  ..._band('8-11', '811'),
  ..._band('11-14', '1114'),
];
