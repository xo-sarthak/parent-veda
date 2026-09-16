// =============================================================================
//  Confidence & public speaking — the activity set, scaffolded per band
// -----------------------------------------------------------------------------
//  `ParentVeda_Confidence_structure.pdf`: "Activity set × 3 — Use your voice
//  (6 to 8) · Stand up and say it (8 to 11) · Give a real talk (11 to 14).
//  The heart. A full practice set per band, each on one real skill, tagged,
//  honest end-line, no score. Recording a turn is offered, never forced."
//
//  ⚠️ THIRTY-SIX SLOTS, ALL COMING SOON, NO COPY. Three task PDFs exist in
//  `tasks/confidence/` and fill these ids in the next pass. Ids follow the
//  shape the other doors take — `cf_68_01` … `cf_1114_12`, two per skill in
//  the door's skill order.
//
//  ⚠️ THE SIX ARE DELIVERY AND NERVE, NOT MEANING. "Communication owns
//  saying it clearly; Confidence owns daring to say it at all, and being
//  heard when you do." The labels and lines are the brief's table, in the
//  child's words. And the brief's own warning, kept where a fill will read
//  it: "The quiet child must not be failed here … small private turns,
//  record just for yourself, no forced stage. Quiet is not a defect to fix."
// =============================================================================

import '../../screens/skilling/sk_content.dart';

const List<SkSkillPurpose> kSkConfidenceSkills = [
  SkSkillPurpose(
    id: 'speaking_up',
    label: 'Speaking up',
    kidLine: 'Taking your turn out loud when it comes, instead of going '
        'quiet and letting it pass.',
  ),
  SkSkillPurpose(
    id: 'being_heard',
    label: 'Being heard',
    kidLine: 'A voice loud and clear enough to reach the back of the room, '
        'not a mumble at the floor.',
  ),
  SkSkillPurpose(
    id: 'facing_the_room',
    label: 'Facing the room',
    kidLine: 'Standing in front of people and looking at them, not turning '
        'away or hiding behind a book.',
  ),
  SkSkillPurpose(
    id: 'steadying_nerves',
    label: 'Steadying nerves',
    kidLine: 'The butterflies before you speak are normal. This is going '
        'anyway, not making them vanish.',
  ),
  SkSkillPurpose(
    id: 'keeping_going',
    label: 'Keeping going',
    kidLine: 'When you lose your place or fumble a word, carrying on '
        'instead of freezing or walking off.',
  ),
  SkSkillPurpose(
    id: 'being_yourself',
    label: 'Being yourself',
    kidLine: 'Saying it in your own words and your own way, not performing '
        'a memorised script perfectly.',
  ),
];

const List<String> _skillOrder = [
  'speaking_up', 'speaking_up',
  'being_heard', 'being_heard',
  'facing_the_room', 'facing_the_room',
  'steadying_nerves', 'steadying_nerves',
  'keeping_going', 'keeping_going',
  'being_yourself', 'being_yourself',
];

List<SkActivity> _band(String band, String idBand) => [
      for (final (i, skill) in _skillOrder.indexed)
        SkActivity(
          id: 'cf_${idBand}_${(i + 1).toString().padLeft(2, '0')}',
          band: band,
          skillPurpose: skill,
          title: 'Activity ${i + 1}',
          comingSoon: true,
        ),
    ];

final List<SkActivity> kSkConfidenceActivities = [
  ..._band('6-8', '68'),
  ..._band('8-11', '811'),
  ..._band('11-14', '1114'),
];
