// =============================================================================
//  Critical thinking & first principles — the course shelf (placeholders)
// -----------------------------------------------------------------------------
//  `ParentVeda_Thinking_structure.pdf`: "Reasoning classes, if the parent
//  wants them — Course shelf — build now; honesty guardrail, no 'critical
//  thinker' upgrade claim", resolved as "A reasoning or debate programme
//  the parent may buy. Held to the honesty guardrail: it teaches reasoning,
//  and never promises a general 'critical thinker' upgrade, because that is
//  not how the skill transfers."
//
//  One reasoning class per level, and light debate for the top band only —
//  the brief puts debate in "Think for yourself (11 to 14)". Placeholders
//  behind the gate, in both currencies, display only. Every string is
//  under the no-outcome scan; nothing here says "critical thinker",
//  "sharper", "smarter" or "brain". Ids in the ledger (ST6).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkCourse> kSkThinkingCourses = [
  for (final (level, name) in [
    ('6-8', 'Ask lots of whys'),
    ('8-11', 'Work out how it works'),
    ('11-14', 'Think for yourself'),
  ])
    SkCourse(
      id: 'th_course_${level.replaceAll('-', '')}_reasoning',
      title: 'Reasoning classes, $name',
      level: level,
      mode: SkCourseMode.live,
      blurb: 'A small group and a real teacher, one sitting a week, '
          'reasoning about real things: a forwarded message, a playground '
          'fairness fight, how a fridge keeps cold. It teaches reasoning on '
          'what is in front of her. Placeholder until a programme exists.',
      priceInr: 2499,
      priceUsd: 30,
      comingSoon: true,
    ),
  const SkCourse(
    id: 'th_course_1114_debate',
    title: 'Light debate, Think for yourself',
    level: '11-14',
    mode: SkCourseMode.live,
    blurb: 'Friendly debates in a small group, where the other side is '
        'argued as well as your own and changing your mind out loud is the '
        'point. Saying it well is the Communication door; this is the '
        'reasoning behind it. Placeholder until a programme exists.',
    priceInr: 2499,
    priceUsd: 30,
    comingSoon: true,
  ),
];
