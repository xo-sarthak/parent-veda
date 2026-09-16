// =============================================================================
//  Confidence & public speaking — the lesson sets, the notes, the coach
// -----------------------------------------------------------------------------
//  `ParentVeda_Confidence_structure.pdf`: "Speaking prompts and stage
//  exercises the activities draw on — Lesson set — build now", resolved as
//  "Prompt and stage-exercise sets per band, each tied to one of the six
//  skills. Small low-stakes turns first, a real talk last."
//
//  ⚠️ PLACEHOLDERS, NOT LESSONS. Two sets spanning every band (prompts;
//  stage exercises), three coming-soon cards per band per set. One page per
//  band in the exercises set is the steady-your-nerves breath, which is the
//  ONE built page: it holds an `SkBreath` block — the app's one breathing
//  circle — and no copy of its own beyond the block's default line, because
//  the brief names the reference and the circle already exists. Every other
//  id is in `docs/DOOR-CONTENT-OWED.md` (SF4).
//
//  The band names are the brief's own, spoken to the child.
// =============================================================================

import '../../screens/skilling/sk_content.dart';
import '../../screens/skilling/sk_door_content.dart';

const Map<String, String> kSkConfidenceBandNames = {
  '6-8': 'Use your voice',
  '8-11': 'Stand up and say it',
  '11-14': 'Give a real talk',
};

const List<SkLessonSet> kSkConfidenceLessonSets = [
  SkLessonSet(
    id: 'prompts',
    title: 'Speaking prompts',
    blurb: 'Something to stand up and say, sized to the room she is in.',
  ),
  SkLessonSet(
    id: 'stage',
    title: 'Stage exercises',
    blurb: 'Small low-stakes turns first, a real talk last.',
  ),
];

List<SkPage> _set(String setId, String idSet) => [
      for (final (band, idBand) in [('6-8', '68'), ('8-11', '811'), ('11-14', '1114')])
        for (var i = 1; i <= 3; i++)
          SkPage(
            id: 'cf_${idSet}_${idBand}_$i',
            title: 'Lesson $i',
            blocks: const [],
            bands: [band],
            set: setId,
            format: 'Lesson',
            comingSoon: true,
          ),
    ];

/// The steady-your-nerves breath — the one page built now, because the
/// circle it shows already exists. "The butterflies are normal and you
/// speak anyway." Confidence references the breath for the moment before
/// you speak; the breath itself belongs to Stillness.
const SkPage kSkConfidenceBreathPage = SkPage(
  id: 'cf_breath',
  title: 'Steady your nerves',
  subtitle: 'Before you speak. Butterflies are normal; this is going anyway.',
  blocks: [
    SkBreath(
      heading: 'Breathe with the circle',
      line: 'In for three, out for five, a few times. Then go — with the '
          'butterflies, not without them.',
    ),
  ],
  set: 'stage',
  format: 'Tool',
);

final List<SkPage> kSkConfidenceLessons = [
  ..._set('prompts', 'prm'),
  kSkConfidenceBreathPage,
  ..._set('stage', 'stg'),
];

/// The parent note — "Why this is a real skill, in plain words". Coming soon.
const SkPage kSkConfidenceParentNote = SkPage(
  id: 'cf_parent_note',
  title: 'For the grown-up',
  subtitle: 'Why daring to speak is a real skill, in plain words; why a '
      'quiet child is not a problem to fix; and how to back her at home.',
  blocks: [],
  format: 'Parent note',
  kidVoice: false,
  comingSoon: true,
);

/// The boundary note — "If it is more than shyness (a real fear of
/// speaking, a stammer): a line out to a professional." Held as one line,
/// never a course. Coming soon; its place is built.
const SkPage kSkConfidenceBoundaryNote = SkPage(
  id: 'cf_boundary_note',
  title: 'If it is more than shyness',
  subtitle: 'A real fear of speaking, or a stammer, is not a confidence gap '
      'and not a course. One honest line to a professional is being written.',
  blocks: [],
  format: 'Parent note',
  kidVoice: false,
  comingSoon: true,
);

/// The speaking coach, one to one — the brief's un-held Consult, as a
/// placeholder row until a real coach is onboarded (the user's call, 1a).
const SkCoach kSkConfidenceCoach = SkCoach(
  id: 'cf_coach',
  title: 'A speaking coach, one to one',
  blurb: 'A real coach, booked by you, for a short call with her. Teaches '
      'speaking; promises nothing about who she will be. Placeholder until '
      'a coach is here.',
  priceInr: 799,
  priceUsd: 10,
);
