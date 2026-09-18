// =============================================================================
//  Meditation, yoga & mindfulness — the course shelf (placeholders)
// -----------------------------------------------------------------------------
//  `ParentVeda_Stillness_structure.pdf`: "A longer guided series, if the
//  parent wants it — Course shelf — build now, small, reuse-first",
//  resolved as "Small, and reuse-first. A longer guided series a parent
//  may want. No outcome promise, no cure claim."
//
//  One recorded series per level, no live class: the brief says small, and
//  a longer guided series is a recording by nature. Placeholders behind the
//  gate, in both currencies, display only. Every string is under the
//  no-outcome scan; nothing here says "calmer child", "cures", "anxiety",
//  "focus" or "sleep better". Ids in the ledger (SL6).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkCourse> kSkStillnessCourses = [
  for (final (level, name) in [
    ('6-8', 'Breathe and wiggle'),
    ('8-11', 'Sit and settle'),
    ('11-14', 'Find your calm'),
  ])
    SkCourse(
      id: 'sl_course_${level.replaceAll('-', '')}_series',
      title: 'A longer guided series, $name',
      level: level,
      mode: SkCourseMode.recorded,
      blurb: 'A set of guided sessions to work through at her own pace, '
          'sized to her attention span, with no order to keep and no day to '
          'miss. A practice, not a treatment. Placeholder until a series '
          'exists.',
      priceInr: 699,
      priceUsd: 8,
      comingSoon: true,
    ),
];
