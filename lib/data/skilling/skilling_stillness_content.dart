// =============================================================================
//  Meditation, yoga & mindfulness — the sessions, the settle breath, the note
// -----------------------------------------------------------------------------
//  `ParentVeda_Stillness_structure.pdf`: "Guided kid meditations and yoga
//  sessions — Content set — adapt from the existing meditation and yoga
//  content, see call 2", resolved as "Guided practices per band, adapted
//  from the existing meditation and yoga content and re-timed for a
//  child's attention span. Rooted in Indian tradition, playful, and kept
//  secular and inclusive."
//
//  ⚠️ PLACEHOLDERS, MARKED ADAPT OR KID-NATIVE (the user's call, 2a: engines
//  reused, sessions kid-authored where the pregnancy content does not
//  transfer). Three sets spanning every band:
//    · Guided sits      — KID-NATIVE. A ten-minute adult sit is not a
//                         child's practice; these are written for her.
//    · Gentle moving    — ADAPT. Garbh Sanskar's yoga transfers as animal
//                         poses and short stretches.
//    · Resting          — ADAPT. `kriya_relaxation_data.dart` (the Kriya
//                         body-scan) transfers, re-timed and re-voiced.
//  The card's `format` says which. Every id is in the ledger (SL4, SL5).
//
//  ⚠️ ONE BUILT PAGE, THE SETTLE BREATH — THE SOURCE (the user's call, 4a).
//  "Stillness is the source, others borrow from it. Focus borrows a
//  settle-breath to apply to a task, Feelings borrows a calming practice,
//  Memory borrows study-calm. Build the calm practices once here and let
//  the others reference them." `sl_settle` is the app's ONE breathing
//  circle (`lib/widgets/breathing_circle.dart`) in an `SkBreath` block,
//  with the brief's own words under it. Confidence's `cf_breath` already
//  says it borrows this breath; the window between them is logged in the
//  review file. No second circle, no session script.
//
//  ⚠️ THE ENGINES ARE VERIFIED, NOT REBUILT. The breathing circle (above),
//  the app's one audio player (`lib/services/raga_audio_store.dart` — one
//  player so pause always means pause), the `garbh` theme key, and the
//  Garbh Sanskar / Kriya content all exist. The audio player is wired to a
//  session the day a session exists; nothing here plays yet, because
//  nothing here is written yet.
//
//  The band names are the brief's own, spoken to the child.
// =============================================================================

import '../../screens/skilling/sk_content.dart';
import '../../screens/skilling/sk_door_content.dart';

const Map<String, String> kSkStillnessBandNames = {
  '6-8': 'Breathe and wiggle',
  '8-11': 'Sit and settle',
  '11-14': 'Find your calm',
};

const List<SkLessonSet> kSkStillnessLessonSets = [
  SkLessonSet(
    id: 'sits',
    title: 'Guided sits',
    blurb: 'Short guided quiet, a minute or two at first, longer as you '
        'grow. Written for you, not shrunk from a grown-up\'s.',
  ),
  SkLessonSet(
    id: 'moving',
    title: 'Gentle moving',
    blurb: 'Animal poses and simple stretches, wriggle first and then '
        'still. Adapted from the yoga the app already has.',
  ),
  SkLessonSet(
    id: 'resting',
    title: 'Resting',
    blurb: 'A body-scan for kids, before sleep or after a hard day. '
        'Adapted from the app\'s relaxation practice.',
  ),
];

List<SkPage> _set(String setId, String idSet, String format, {int perBand = 3}) => [
      for (final (band, idBand) in [('6-8', '68'), ('8-11', '811'), ('11-14', '1114')])
        for (var i = 1; i <= perBand; i++)
          SkPage(
            id: 'sl_${idSet}_${idBand}_$i',
            title: 'Session $i',
            blocks: const [],
            bands: [band],
            set: setId,
            format: format,
            comingSoon: true,
          ),
    ];

/// The settle breath — the one page built now, because the circle it shows
/// already exists and every other calm door borrows this page. The brief's
/// words for the practice: "A few calm breaths to come to rest and land in
/// your body."
const SkPage kSkStillnessSettlePage = SkPage(
  id: 'sl_settle',
  title: 'Settle',
  subtitle: 'A few calm breaths to come to rest and land in your body.',
  blocks: [
    SkBreath(
      heading: 'Breathe with the circle',
      line: 'In for three, out for five. A few times, or as long as you '
          'like. Nothing to get right.',
    ),
  ],
  set: 'sits',
  format: 'Practice',
);

final List<SkPage> kSkStillnessLessons = [
  kSkStillnessSettlePage,
  ..._set('sits', 'sit', 'Kid-native'),
  ..._set('moving', 'mov', 'Adapted'),
  ..._set('resting', 'rst', 'Adapted', perBand: 2),
];

/// The parent note — the brief's own title: "How stillness helps, without
/// over-selling it". Coming soon.
const SkPage kSkStillnessParentNote = SkPage(
  id: 'sl_parent_note',
  title: 'How stillness helps, without over-selling it',
  subtitle: 'A calm practice a child might enjoy and benefit from; not a '
      'treatment for anxiety, behaviour or focus. Why there is no streak '
      'here, on purpose. And where real distress goes instead.',
  blocks: [],
  format: 'Parent note',
  kidVoice: false,
  comingSoon: true,
);
