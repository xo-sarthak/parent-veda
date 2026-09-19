// =============================================================================
//  Creativity & expression — the making set, scaffolded per band
// -----------------------------------------------------------------------------
//  `ParentVeda_Creativity_structure.pdf`: "The heart. A full making set per
//  band, each on one of the six moves, tagged, ending on an honest 'what
//  you made' line. Process not product. No score, no good-versus-bad."
//
//  ⚠️ THIRTY-SIX SLOTS, ALL COMING SOON, NO COPY. No task PDF exists for this
//  door yet; the fills land here when it does. Ids follow the shape the
//  other doors take — `mk_68_01` … `mk_1114_12`, two per move in the door's
//  move order. The door's id is `skilling_creativity`; the brief calls it
//  the Making door, so the prefix is `mk`.
//
//  ⚠️ THE SIX ARE MOVES, NOT A LADDER. "Creativity is the one thing you can
//  kill by grading it, so these are honest creative moves, not a ladder
//  anyone climbs or is measured on." The labels and lines are the brief's
//  table, in the child's words.
//
//  ⚠️ NO SUPPLIES TO BEGIN, AND INDIA FIRST. Every fill is held to the
//  brief: "Rangoli and kolam, mehndi patterns, diya and pot painting,
//  kite-making, clay Ganpati, Warli and Madhubani to try, kitchen-shelf
//  percussion, a fort from a dupatta and chairs … never need a bought kit
//  to begin." And a way back in for the child who has decided she "can't
//  draw": process not product.
// =============================================================================

import '../../screens/skilling/sk_content.dart';

const List<SkSkillPurpose> kSkMakingSkills = [
  SkSkillPurpose(
    id: 'starting',
    label: 'Starting',
    kidLine: 'Making the first mark on a blank page, or the first sound, '
        'before you know how it ends.',
  ),
  SkSkillPurpose(
    id: 'imagining',
    label: 'Imagining',
    kidLine: 'Coming up with an idea. "What if", picturing a thing that is '
        'not there yet.',
  ),
  SkSkillPurpose(
    id: 'your_own_way',
    label: 'Your own way',
    kidLine: 'Doing it differently from the example, making it yours '
        'instead of copying.',
  ),
  SkSkillPurpose(
    id: 'playing_with_stuff',
    label: 'Playing with stuff',
    kidLine: 'Finding out what a crayon, some clay, a scrap or a rhythm can '
        'actually do.',
  ),
  SkSkillPurpose(
    id: 'finishing',
    label: 'Finishing',
    kidLine: 'Taking an idea all the way to a thing you can hold up or play '
        'back.',
  ),
  SkSkillPurpose(
    id: 'showing_it',
    label: 'Showing it',
    kidLine: 'Sharing what you made and saying what it is, without it '
        'having to be good.',
  ),
];

const List<String> _moveOrder = [
  'starting', 'starting',
  'imagining', 'imagining',
  'your_own_way', 'your_own_way',
  'playing_with_stuff', 'playing_with_stuff',
  'finishing', 'finishing',
  'showing_it', 'showing_it',
];

List<SkActivity> _band(String band, String idBand) => [
      for (final (i, move) in _moveOrder.indexed)
        SkActivity(
          id: 'mk_${idBand}_${(i + 1).toString().padLeft(2, '0')}',
          band: band,
          skillPurpose: move,
          title: 'Activity ${i + 1}',
          comingSoon: true,
        ),
    ];

final List<SkActivity> kSkMakingActivities = [
  ..._band('6-8', '68'),
  ..._band('8-11', '811'),
  ..._band('11-14', '1114'),
];
