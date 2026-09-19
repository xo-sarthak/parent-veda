// =============================================================================
//  Creativity & expression — the prompt sets and the parent note
// -----------------------------------------------------------------------------
//  `ParentVeda_Creativity_structure.pdf`: "Art, music and making prompts
//  the activities draw on — Lesson set — build now", resolved as "Prompt
//  sets per band across all three: art, music and making. India-first, and
//  doable with what is in an ordinary home. No supplies required to
//  start."
//
//  ⚠️ PLACEHOLDERS, NOT PROMPTS. Three sets spanning every band — art, music,
//  making — because the brief insists on all three: "'Creativity for kids'
//  quietly means colouring. The tile says art, music and making, so honour
//  all three." Three coming-soon cards per band per set. Every id is in
//  `docs/DOOR-CONTENT-OWED.md` (MK4).
//
//  The band names are the brief's own, spoken to the child.
// =============================================================================

import '../../screens/skilling/sk_content.dart';
import '../../screens/skilling/sk_door_content.dart';

const Map<String, String> kSkMakingBandNames = {
  '6-8': 'Just make it',
  '8-11': 'Make it yours',
  '11-14': 'Make something real',
};

const List<SkLessonSet> kSkMakingLessonSets = [
  SkLessonSet(
    id: 'art',
    title: 'Art',
    blurb: 'Draw, paint, collage. Rangoli, Warli, a diya to paint. With '
        'what is in the house.',
  ),
  SkLessonSet(
    id: 'music',
    title: 'Music',
    blurb: 'Clap a beat, hum a tune, make an instrument from the kitchen '
        'shelf.',
  ),
  SkLessonSet(
    id: 'making',
    title: 'Making',
    blurb: 'Build and craft from junk and household bits. A kite, a fort '
        'from a dupatta and chairs, a clay thing.',
  ),
];

List<SkPage> _set(String setId, String idSet) => [
      for (final (band, idBand) in [('6-8', '68'), ('8-11', '811'), ('11-14', '1114')])
        for (var i = 1; i <= 3; i++)
          SkPage(
            id: 'mk_${idSet}_${idBand}_$i',
            title: 'Prompt $i',
            blocks: const [],
            bands: [band],
            set: setId,
            format: 'Prompt',
            comingSoon: true,
          ),
    ];

final List<SkPage> kSkMakingLessons = [
  ..._set('art', 'art'),
  ..._set('music', 'mus'),
  ..._set('making', 'mak'),
];

/// The parent note — the brief's own title: "Why this is a real skill, in
/// plain words". Coming soon.
const SkPage kSkMakingParentNote = SkPage(
  id: 'mk_parent_note',
  title: 'Why this is a real skill, in plain words',
  subtitle: 'Why making is the point and the drawing is not; why it is '
      'never marked or compared to an example; and how to help a child who '
      'has decided she "cannot draw" find her way back in.',
  blocks: [],
  format: 'Parent note',
  kidVoice: false,
  comingSoon: true,
);
