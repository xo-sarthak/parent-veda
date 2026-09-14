// =============================================================================
//  Coding & AI literacy — the activity set, scaffolded for a FULL set per band
// -----------------------------------------------------------------------------
//  `ParentVeda_Coding_structure_v2.pdf`: "this is the heart, so scaffold it
//  for a FULL set per band, not a token one. Each activity entry carries its
//  band, a skillPurpose tag (sequencing, pattern, debugging, decomposition,
//  logic, persistence), and an end-of-activity 'what you practised' word
//  slot. Placeholder content, real structure."
//
//  ⚠️ THIRTY-SIX SLOTS, ALL COMING SOON, AND NOT ONE WORD OF ACTIVITY COPY.
//  The task PDFs (`tasks/coding/…`, "Task 1 of 36" onward) hold the twelve
//  real activities per band, two per thinking skill, and they are mapped in
//  verbatim as the next pass. The ids below are the ids those fills take
//  over — `cd_68_01` … `cd_1114_12` — so nothing on the rail moves the day
//  the copy lands; only `comingSoon` flips and the fields fill.
//
//  The two-per-skill layout is the task PDFs' own rule ("each appears twice
//  across the 12"), so it is the scaffold's rule too and the contract test
//  holds it.
// =============================================================================

import '../../screens/skilling/sk_content.dart';

/// Coding's six real thinking skills — the brief's list, in the brief's
/// words for the child ("putting steps in the right order, spotting the
/// mistake, seeing the pattern, breaking a big thing into small ones,
/// if-this-then-that, and sticking with it").
const List<SkSkillPurpose> kSkCodingSkills = [
  SkSkillPurpose(
    id: 'sequencing',
    label: 'Putting steps in order',
    kidLine: 'What comes first, what comes next.',
  ),
  SkSkillPurpose(
    id: 'pattern',
    label: 'Seeing the pattern',
    kidLine: 'Spotting what repeats, and what comes after.',
  ),
  SkSkillPurpose(
    id: 'debugging',
    label: 'Spotting the mistake',
    kidLine: 'Finding the step that went wrong, and fixing it.',
  ),
  SkSkillPurpose(
    id: 'decomposition',
    label: 'Breaking a big thing into small ones',
    kidLine: 'One big job is lots of little jobs.',
  ),
  SkSkillPurpose(
    id: 'logic',
    label: 'If this, then that',
    kidLine: 'Choices, and what happens because of them.',
  ),
  SkSkillPurpose(
    id: 'persistence',
    label: 'Sticking with it',
    kidLine: 'When it does not work the first time, trying again.',
  ),
];

const List<String> _skillOrder = [
  'sequencing', 'sequencing',
  'pattern', 'pattern',
  'debugging', 'debugging',
  'decomposition', 'decomposition',
  'logic', 'logic',
  'persistence', 'persistence',
];

/// Twelve placeholder slots for one band. The title is the honest state —
/// "Activity 3 · coming soon" — never a made-up activity name.
List<SkActivity> _band(String band, String idBand) => [
      for (final (i, skill) in _skillOrder.indexed)
        SkActivity(
          id: 'cd_${idBand}_${(i + 1).toString().padLeft(2, '0')}',
          band: band,
          skillPurpose: skill,
          title: 'Activity ${i + 1}',
          comingSoon: true,
        ),
    ];

final List<SkActivity> kSkCodingActivities = [
  ..._band('6-8', '68'),
  ..._band('8-11', '811'),
  ..._band('11-14', '1114'),
];
