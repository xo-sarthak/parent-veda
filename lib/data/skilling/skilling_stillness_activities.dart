// =============================================================================
//  Meditation, yoga & mindfulness — the practice set, scaffolded per band
// -----------------------------------------------------------------------------
//  `ParentVeda_Stillness_structure.pdf`: "The heart, and gentle. A set per
//  band of guided practices (settle, breathe, notice, move, calm, rest),
//  each a real practice, non-striving, ending on a soft line, no score."
//
//  ⚠️ THIRTY-SIX SLOTS, ALL COMING SOON, NO COPY. No task PDF exists for this
//  door yet; the fills land here when it does. Ids follow the shape the
//  other doors take — `sl_68_01` … `sl_1114_12`, two per practice in the
//  door's practice order.
//
//  ⚠️ THESE ARE PRACTICES, NOT SKILLS TO GRADE. The brief: "the practice is
//  non-striving, so nothing here is ever measured. Every session ends on a
//  gentle line ('you took a quiet minute'), never a score." The six labels
//  and lines are the brief's table, in the child's words.
//
//  ⚠️ KID-AUTHORED, ON THE REUSED ENGINES (the user's call, 2026-09-17, 2a).
//  The breathing circle and the app's one audio player are the engines
//  every session runs on; the sessions themselves are written for a child
//  — short, playful, movement-first — and adapted from the pregnancy
//  Garbh / Kriya content only where a piece genuinely transfers. Which is
//  which is marked on the lesson sets (`skilling_stillness_content.dart`).
// =============================================================================

import '../../screens/skilling/sk_content.dart';

const List<SkSkillPurpose> kSkStillnessSkills = [
  SkSkillPurpose(
    id: 'settling',
    label: 'Settling',
    kidLine: 'A few calm breaths to come to rest and land in your body.',
  ),
  SkSkillPurpose(
    id: 'breathing',
    label: 'Breathing',
    kidLine: 'Playful breath games, balloon breath, bee breath, that '
        'quietly calm the body down.',
  ),
  SkSkillPurpose(
    id: 'noticing',
    label: 'Noticing',
    kidLine: 'Gentle attention to sounds, the body, the breath, without '
        'having to fix anything.',
  ),
  SkSkillPurpose(
    id: 'gentle_moving',
    label: 'Gentle moving',
    kidLine: 'Simple yoga and animal poses, stretch and breathe. Stillness '
        'that lets you wriggle first.',
  ),
  SkSkillPurpose(
    id: 'calming_down',
    label: 'Calming down',
    kidLine: 'A way back to steady when you are upset or wound up.',
  ),
  SkSkillPurpose(
    id: 'resting',
    label: 'Resting',
    kidLine: 'A quiet wind-down, a body-scan for kids, before sleep or '
        'after a hard day.',
  ),
];

const List<String> _practiceOrder = [
  'settling', 'settling',
  'breathing', 'breathing',
  'noticing', 'noticing',
  'gentle_moving', 'gentle_moving',
  'calming_down', 'calming_down',
  'resting', 'resting',
];

List<SkActivity> _band(String band, String idBand) => [
      for (final (i, practice) in _practiceOrder.indexed)
        SkActivity(
          id: 'sl_${idBand}_${(i + 1).toString().padLeft(2, '0')}',
          band: band,
          skillPurpose: practice,
          title: 'Practice ${i + 1}',
          comingSoon: true,
        ),
    ];

final List<SkActivity> kSkStillnessActivities = [
  ..._band('6-8', '68'),
  ..._band('8-11', '811'),
  ..._band('11-14', '1114'),
];
