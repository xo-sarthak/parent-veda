// =============================================================================
//  Critical thinking & first principles — the lesson sets and the parent note
// -----------------------------------------------------------------------------
//  `ParentVeda_Thinking_structure.pdf`: "Puzzles, why-chains, and the
//  spotting-fake strand — Lesson set — build now; the fake-spotting bit
//  shared with Coding, see call 2", resolved as "Puzzles, why-chains,
//  reasoning and light debate per band, on real content not abstract
//  drills. Woven with the spotting-fake strand, which is the door's most
//  valuable modern piece."
//
//  ⚠️ PLACEHOLDERS, NOT LESSONS. Four sets spanning every band: puzzles,
//  why-chains, "Is this true?" (the spotting-fake strand, a HEADLINE strand
//  on the user's call of 2026-09-17, 2a), and "Just for fun" (the extras
//  reshape, 3a: "challenges become optional fun — a riddle, a friendly
//  debate"). Three coming-soon cards per band per set; two for the fun set.
//  Every id is in `docs/DOOR-CONTENT-OWED.md` (ST4, ST5).
//
//  ⚠️ THE SPOTTING-FAKE STRAND IS BUILT ONCE, ACROSS TWO DOORS. The brief:
//  "Thinking owns the reasoning (is this true, who says so, how would I
//  know); Coding's AI literacy owns the mechanism (how AI generates content,
//  why it errs and is biased); the two cross-link into one defence built
//  once." Coding's AI set (`cd_ai_*`) is itself coming soon, so — as the
//  brief's prompt says for exactly this case — this door leaves a
//  CROSS-LINK SLOT and lists it: the set's blurb names the window, the
//  review file's cross-door table holds it, and the page that links across
//  is authored when both halves exist. Nothing AI-literacy is re-authored
//  here.
//
//  The band names are the brief's own, spoken to the child.
// =============================================================================

import '../../screens/skilling/sk_content.dart';
import '../../screens/skilling/sk_door_content.dart';

const Map<String, String> kSkThinkingBandNames = {
  '6-8': 'Ask lots of whys',
  '8-11': 'Work out how it works',
  '11-14': 'Think for yourself',
};

const List<SkLessonSet> kSkThinkingLessonSets = [
  SkLessonSet(
    id: 'puzzles',
    title: 'Puzzles',
    blurb: 'Riddles and reasoning puzzles on things you know. A logic '
        'puzzle lives here; a number puzzle lives in Maths.',
  ),
  SkLessonSet(
    id: 'why_chains',
    title: 'Why-chains',
    blurb: 'Why? And why is that? And why is that? Following it down to '
        'the real reason.',
  ),
  SkLessonSet(
    id: 'is_it_true',
    title: 'Is this true?',
    blurb: 'A forwarded message, a too-good-to-be-true claim, a video that '
        'looks real. Who says so, and how would you know? How the machine '
        'makes things up is in the Coding door; this is the checking.',
  ),
  SkLessonSet(
    id: 'fun',
    title: 'Just for fun',
    blurb: 'A riddle to take to the table, a friendly debate to lose on '
        'purpose. Optional. Nothing counts.',
  ),
];

List<SkPage> _set(String setId, String idSet, {int perBand = 3}) => [
      for (final (band, idBand) in [('6-8', '68'), ('8-11', '811'), ('11-14', '1114')])
        for (var i = 1; i <= perBand; i++)
          SkPage(
            id: 'th_${idSet}_${idBand}_$i',
            title: 'Lesson $i',
            blocks: const [],
            bands: [band],
            set: setId,
            format: 'Lesson',
            comingSoon: true,
          ),
    ];

final List<SkPage> kSkThinkingLessons = [
  ..._set('puzzles', 'pzl'),
  ..._set('why_chains', 'why'),
  ..._set('is_it_true', 'tru'),
  ..._set('fun', 'fun', perBand: 2),
];

/// The parent note — the brief's own title: "How to raise a questioner
/// without raising an arguer". Coming soon.
const SkPage kSkThinkingParentNote = SkPage(
  id: 'th_parent_note',
  title: 'How to raise a questioner without raising an arguer',
  subtitle: 'Why enjoying being wrong is the real skill; why the good '
      'question beats the right answer; and how questioning an idea and '
      'respecting a person stay two different things at home.',
  blocks: [],
  format: 'Parent note',
  kidVoice: false,
  comingSoon: true,
);
