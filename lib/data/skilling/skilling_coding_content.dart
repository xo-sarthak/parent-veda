// =============================================================================
//  Coding & AI literacy — the lesson library and the AI-literacy set
// -----------------------------------------------------------------------------
//  `ParentVeda_Coding_structure_v2.pdf`: "placeholder lesson entries in
//  three sets (unplugged, blocks, projects) plus an AI-literacy set spanning
//  all bands. Each tagged to its band and typed."
//
//  ⚠️ PLACEHOLDERS, NOT LESSONS. Every page here is `comingSoon` with an
//  honest title ("Lesson 2") and no blocks — the brief's "clearly-marked
//  placeholders (title, band, type, and an honest 'content coming' state),
//  the way an unshot video slot renders today." The set titles and blurbs
//  are the brief's own words for the bands; the lesson copy is job two.
//
//  Four lessons per set is the scaffold's shape, not a count the brief gave;
//  a fill may add or remove slots freely. The AI set has two per band, since
//  the brief gives each band its own AI line ("what even is a computer";
//  "it can be wrong, you never tell it a secret"; "why it sounds sure when
//  it's wrong").
//
//  Every id here is in `docs/DOOR-CONTENT-OWED.md` (S1–S4).
// =============================================================================

import '../../screens/skilling/sk_content.dart';
import '../../screens/skilling/sk_door_content.dart';

/// The band names the door speaks — the brief's own ladder.
const Map<String, String> kSkCodingBandNames = {
  '6-8': 'Unplugged',
  '8-11': 'Blocks',
  '11-14': 'Projects',
};

const List<SkLessonSet> kSkCodingLessonSets = [
  SkLessonSet(
    id: 'unplugged',
    title: 'Unplugged',
    blurb: 'No code yet. Clear instructions, spotting a wrong step and '
        'fixing it, patterns.',
    bands: ['6-8'],
  ),
  SkLessonSet(
    id: 'blocks',
    title: 'Blocks',
    blurb: 'Visual drag-and-drop coding, first real programs, a loop, a '
        'little game or story that runs.',
    bands: ['8-11'],
  ),
  SkLessonSet(
    id: 'projects',
    title: 'Projects',
    blurb: 'Real projects, first taste of typed code, building something '
        'that works.',
    bands: ['11-14'],
  ),
  // The set that spans all three bands and gets the door's fourth tab.
  SkLessonSet(
    id: 'ai',
    title: 'AI, explained for her age',
    blurb: 'Woven through every band, sized to the age.',
  ),
];

List<SkPage> _set(String setId, String idSet, List<String> bands, int n,
        {String format = 'Lesson'}) =>
    [
      for (var i = 1; i <= n; i++)
        SkPage(
          id: 'cd_${idSet}_l$i',
          title: 'Lesson $i',
          blocks: const [],
          bands: bands,
          set: setId,
          format: format,
          comingSoon: true,
        ),
    ];

final List<SkPage> kSkCodingLessons = [
  ..._set('unplugged', 'unp', ['6-8'], 4),
  ..._set('blocks', 'blk', ['8-11'], 4),
  ..._set('projects', 'prj', ['11-14'], 4),
  // The AI set: two cards per band, tagged so each band sees its own two.
  ...[
    for (final (band, idBand) in [('6-8', '68'), ('8-11', '811'), ('11-14', '1114')])
      for (var i = 1; i <= 2; i++)
        SkPage(
          id: 'cd_ai_${idBand}_$i',
          title: 'AI card $i',
          blocks: const [],
          bands: [band],
          set: 'ai',
          format: 'Article',
          comingSoon: true,
        ),
  ],
];

/// The parent note. Parent voice, behind the gate. The brief's three
/// questions are its headings; the copy is job two, so it is a coming-soon
/// page whose one built part is what the keepsake can already say (drawn
/// by the grown-up screen, not authored here).
const SkPage kSkCodingParentNote = SkPage(
  id: 'cd_parent_note',
  title: 'For the grown-up',
  subtitle: 'What she has been doing, why it helps her thinking, and how to help.',
  blocks: [],
  format: 'Parent note',
  kidVoice: false,
  comingSoon: true,
);
