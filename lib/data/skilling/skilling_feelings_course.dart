// =============================================================================
//  Emotional intelligence & resilience — the course shelf (placeholders)
// -----------------------------------------------------------------------------
//  `ParentVeda_Feelings_structure.pdf`: "A short emotional-skills series, if
//  the parent wants it — Course shelf — build now, small, never a 'fix your
//  child' programme", resolved as "Small. A short emotional-skills series
//  if a parent wants it. Never a paid 'fix your child's emotions'
//  programme, which would be the worst over-promise in the most sensitive
//  place."
//
//  One recorded series per level, no live class. Placeholders behind the
//  gate, in both currencies, display only. Every string is under the
//  no-outcome scan; nothing here says "fix", "cure", "anxiety", "therapy",
//  "counselling" or "resilient child". Ids in the ledger (FE7).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkCourse> kSkFeelingsCourses = [
  for (final (level, name) in [
    ('6-8', 'Name what you feel'),
    ('8-11', 'Handle the big feelings'),
    ('11-14', 'Find your way through'),
  ])
    SkCourse(
      id: 'fe_course_${level.replaceAll('-', '')}_series',
      title: 'A short emotional-skills series, $name',
      level: level,
      mode: SkCourseMode.recorded,
      blurb: 'A few short sessions on naming feelings, handling the big '
          'ones and bouncing back, to watch at her own pace. It teaches '
          'skills; it is not treatment, and it promises nothing about who '
          'she will be. Placeholder until a series exists.',
      priceInr: 699,
      priceUsd: 8,
      comingSoon: true,
    ),
];
