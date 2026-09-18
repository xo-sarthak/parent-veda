// =============================================================================
//  Emotional intelligence & resilience — the sets, the calm window, the note
// -----------------------------------------------------------------------------
//  `ParentVeda_Feelings_structure.pdf`: "Scenarios to think through, and
//  gentle journaling prompts — Lesson set — care: needs clinical review
//  before shipping", resolved as "Scenarios to think through and gentle
//  journaling prompts per band, on the six skills. Resilience as recovery
//  not toughening up. Help-seeking normalised. This content needs review
//  by a child psychologist before it ships."
//
//  ⚠️ PLACEHOLDERS, MARKED FOR CLINICAL REVIEW. Two sets spanning every band
//  — scenarios (safer, external) and journal prompts (private, sensitive)
//  — three coming-soon cards per band per set. The card's `format` says
//  "Needs review" on every one, so a fill cannot land here quietly. Every
//  id is in the ledger (FE4, FE5).
//
//  ⚠️ THE CALM PRACTICE IS A WINDOW ONTO STILLNESS, NOT A COPY. "A calm-down
//  breath when a feeling is big — Calm practice — single-source, reuses
//  Stillness." `fe_calm` has no blocks and a `toolSurfaceId` onto
//  `sk_page/skilling_stillness/sl_settle` — the page Stillness built as
//  the source (its call 4a). "When a feeling is big, Feelings names it and
//  Stillness calms it. This door reuses Stillness's calm-down practices, it
//  does not rebuild breathing."
//
//  ⚠️ THE OFF-RAMP AND THE HELPLINES. The safety off-ramp lives on the door
//  content (`kSkFeelingsSafety`) and is drawn on every child screen of the
//  door by the shell. The numbers are real Indian helplines and are FLAGGED
//  VERIFY (the user's call, 2a): a lawyer and a clinician confirm them and
//  the wording before anything ships.
//
//  The band names are the brief's own, spoken to the child.
// =============================================================================

import '../../screens/skilling/sk_content.dart';
import '../../screens/skilling/sk_door_content.dart';

const Map<String, String> kSkFeelingsBandNames = {
  '6-8': 'Name what you feel',
  '8-11': 'Handle the big feelings',
  '11-14': 'Find your way through',
};

const List<SkLessonSet> kSkFeelingsLessonSets = [
  SkLessonSet(
    id: 'scenarios',
    title: 'Scenarios to think through',
    blurb: 'A real situation, a friend who is upset, a game you lost, '
        'being left out. What would you do? Nothing to get right.',
  ),
  SkLessonSet(
    id: 'prompts',
    title: 'Journal prompts',
    blurb: 'Gentle questions for the harder feelings, to write down in '
        'your journal. Yours only.',
  ),
  SkLessonSet(
    id: 'calm',
    title: 'When a feeling is big',
    blurb: 'A calm-down breath, from the Stillness door. Name it here; '
        'settle there.',
  ),
];

List<SkPage> _set(String setId, String idSet) => [
      for (final (band, idBand) in [('6-8', '68'), ('8-11', '811'), ('11-14', '1114')])
        for (var i = 1; i <= 3; i++)
          SkPage(
            id: 'fe_${idSet}_${idBand}_$i',
            title: setId == 'scenarios' ? 'Scenario $i' : 'Prompt $i',
            blocks: const [],
            bands: [band],
            set: setId,
            format: 'Needs review',
            comingSoon: true,
          ),
    ];

/// The window onto Stillness's settle breath. No blocks; the tap goes
/// through the router to the source page. Every band.
const SkPage kSkFeelingsCalmWindow = SkPage(
  id: 'fe_calm',
  title: 'A calm-down breath',
  subtitle: 'From the Stillness door. A few breaths with the circle, then '
      'come back to the feeling.',
  blocks: [],
  set: 'calm',
  format: 'From Stillness',
  toolSurfaceId: 'sk_page/skilling_stillness/sl_settle',
);

final List<SkPage> kSkFeelingsLessons = [
  ..._set('scenarios', 'scn'),
  ..._set('prompts', 'prm'),
  kSkFeelingsCalmWindow,
];

/// The parent note — the brief's own title: "How to help a child with big
/// feelings, and when to seek help". Coming soon; clinical review first.
const SkPage kSkFeelingsParentNote = SkPage(
  id: 'fe_parent_note',
  title: 'How to help a child with big feelings, and when to seek help',
  subtitle: 'A skill door, never therapy. Why naming and feeling beats '
      '"be strong"; how to make asking for help ordinary at home; and the '
      'plain signs that it is time for a professional. Written with a '
      'child psychologist before it ships.',
  blocks: [],
  format: 'Parent note',
  kidVoice: false,
  comingSoon: true,
);

/// The off-ramp. ⚠️ NUMBERS FLAGGED VERIFY — real as of writing, confirmed
/// by a lawyer and a clinician before ship. `verify: true` keeps them off a
/// release build's sheet until then.
const SkSafety kSkFeelingsSafety = SkSafety(
  trustedAdultLine: 'If something feels too big, tell a grown-up you trust. '
      'That is always okay, and it is what brave people do.',
  helplines: [
    SkHelpline(
      name: 'Childline',
      number: '1098',
      note: 'Free, any time, for any child in India. Someone kind picks up.',
      verify: true,
    ),
    SkHelpline(
      name: 'Tele-MANAS',
      number: '14416',
      note: 'Free, any time, for feelings that are too heavy to carry alone.',
      verify: true,
    ),
  ],
);
