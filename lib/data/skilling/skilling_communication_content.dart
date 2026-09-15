// =============================================================================
//  Communication & articulation — the lesson library, the note, the boundary
// -----------------------------------------------------------------------------
//  `ParentVeda_Communication_structure.pdf`: "Speaking prompts, story frames,
//  describe-it and explain-it sets — Lesson set — build now", resolved as
//  "Prompt, story and describe-or-explain sets per band, each tied to one of
//  the six skills. Works in her own language and in English, mother tongue
//  first."
//
//  ⚠️ PLACEHOLDERS, NOT LESSONS. Three sets, each spanning every band, three
//  coming-soon cards per band per set — the count is the scaffold's, the
//  brief gives none. No prompt text is authored ("new copy stays unwritten
//  until you say go"). Every id is in `docs/DOOR-CONTENT-OWED.md` (SC4).
//
//  The band names are the brief's own, "spoken to the child".
// =============================================================================

import '../../screens/skilling/sk_content.dart';
import '../../screens/skilling/sk_door_content.dart';

const Map<String, String> kSkCommunicationBandNames = {
  '6-8': 'Say it out loud',
  '8-11': 'Tell it and explain it',
  '11-14': 'Say what you think',
};

const List<SkLessonSet> kSkCommunicationLessonSets = [
  SkLessonSet(
    id: 'prompts',
    title: 'Speaking prompts',
    blurb: 'Something to say out loud today, in her own language or in '
        'English.',
  ),
  SkLessonSet(
    id: 'story_frames',
    title: 'Story frames',
    blurb: 'A start, a middle, an end: a frame to tell what happened.',
  ),
  SkLessonSet(
    id: 'describe_explain',
    title: 'Describe it, explain it',
    blurb: 'Make someone picture a thing, or understand how a thing works.',
  ),
];

List<SkPage> _set(String setId, String idSet, {String format = 'Lesson'}) => [
      for (final (band, idBand) in [('6-8', '68'), ('8-11', '811'), ('11-14', '1114')])
        for (var i = 1; i <= 3; i++)
          SkPage(
            id: 'cm_${idSet}_${idBand}_$i',
            title: 'Lesson $i',
            blocks: const [],
            bands: [band],
            set: setId,
            format: format,
            comingSoon: true,
          ),
    ];

final List<SkPage> kSkCommunicationLessons = [
  ..._set('prompts', 'prm'),
  ..._set('story_frames', 'stf'),
  ..._set('describe_explain', 'dex'),
];

/// The parent note — "Why this is a real skill, in plain words". Coming
/// soon; the grown-up screen draws the keepsake's words above it meanwhile.
const SkPage kSkCommunicationParentNote = SkPage(
  id: 'cm_parent_note',
  title: 'For the grown-up',
  subtitle: 'Why saying what you mean is a real skill, in plain words, and '
      'how to back it at home.',
  blocks: [],
  format: 'Parent note',
  kidVoice: false,
  comingSoon: true,
);

/// The boundary note — "If speech itself is the worry (stammer, delay):
/// one honest line out to a professional." The brief made no call beyond
/// holding it as a single line: not a course, not a "fix your child's
/// speech" product. Coming soon; its place on the grown-up screen is built.
const SkPage kSkCommunicationBoundaryNote = SkPage(
  id: 'cm_boundary_note',
  title: 'If speech itself is the worry',
  subtitle: 'A stammer or a delay is not a skill gap, and not a course. One '
      'honest line to a speech professional is being written.',
  blocks: [],
  format: 'Parent note',
  kidVoice: false,
  comingSoon: true,
);
