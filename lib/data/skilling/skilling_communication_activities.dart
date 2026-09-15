// =============================================================================
//  Communication & articulation — the activity set, scaffolded per band
// -----------------------------------------------------------------------------
//  `ParentVeda_Communication_structure.pdf`: "Activity set × 3 — Say it out
//  loud (6 to 8) · Tell it and explain it (8 to 11) · Say what you think
//  (11 to 14) — build now. The heart. A full set per band, not a token few.
//  Each built on one real skill, tagged, ending on an honest 'what you just
//  practised' line. No score."
//
//  ⚠️ THIRTY-SIX SLOTS, ALL COMING SOON, NO COPY. The brief's rule for this
//  pass: "Build the frame, not the content … Do not author any prompt text,
//  any activity". Two task PDFs exist (6 to 8 and 8 to 11) and fill these
//  ids in the next pass; the 11 to 14 task is not written yet. Ids follow
//  Coding's shape — `cm_68_01` … `cm_1114_12` — two per skill, in the
//  door's skill order, so a fill is a transcription.
//
//  The six skills are the brief's table, verbatim in the child's words.
// =============================================================================

import '../../screens/skilling/sk_content.dart';

/// The brief's six real skills, with its own line for each.
const List<SkSkillPurpose> kSkCommunicationSkills = [
  SkSkillPurpose(
    id: 'clarity',
    label: 'Clarity',
    kidLine: 'Saying a thing so the other person gets it the first time, '
        'without having to guess.',
  ),
  SkSkillPurpose(
    id: 'listening',
    label: 'Listening',
    kidLine: 'Actually taking in what someone said, and being able to say '
        'it back in your own words.',
  ),
  SkSkillPurpose(
    id: 'describing',
    label: 'Describing',
    kidLine: 'Making someone picture a thing in their head using only your '
        'words.',
  ),
  SkSkillPurpose(
    id: 'storytelling',
    label: 'Storytelling',
    kidLine: 'Putting what happened in an order that makes sense: a start, '
        'a middle, an end.',
  ),
  SkSkillPurpose(
    id: 'right_word',
    label: 'The right word',
    kidLine: 'Finding the word that fits, instead of "that thing" and '
        'pointing.',
  ),
  SkSkillPurpose(
    id: 'putting_your_point',
    label: 'Putting your point',
    kidLine: 'Saying what you think and the reason for it, so it holds up.',
  ),
];

const List<String> _skillOrder = [
  'clarity', 'clarity',
  'listening', 'listening',
  'describing', 'describing',
  'storytelling', 'storytelling',
  'right_word', 'right_word',
  'putting_your_point', 'putting_your_point',
];

List<SkActivity> _band(String band, String idBand) => [
      for (final (i, skill) in _skillOrder.indexed)
        SkActivity(
          id: 'cm_${idBand}_${(i + 1).toString().padLeft(2, '0')}',
          band: band,
          skillPurpose: skill,
          title: 'Activity ${i + 1}',
          comingSoon: true,
        ),
    ];

final List<SkActivity> kSkCommunicationActivities = [
  ..._band('6-8', '68'),
  ..._band('8-11', '811'),
  ..._band('11-14', '1114'),
];
