// =============================================================================
//  Confidence & public speaking — the course shelf (placeholder programmes)
// -----------------------------------------------------------------------------
//  `ParentVeda_Confidence_structure.pdf`: "The door people pay for. A leveled
//  paid programme, live or recorded, with a real coach. Held hard to one
//  line: it teaches speaking, it never promises a confident child or a
//  rank."
//
//  The user's call (2026-09-16, question 1a): placeholders behind the gate,
//  as on Coding — one live and one recorded per level — with the booking
//  engine (`lib/booking/`) as the named next pass, the day a real coach is
//  onboarded. Every string is under the no-outcome scan; nothing here says
//  "confident child", "fearless" or "stage-ready".
//
//  Prices are placeholders, in both currencies, display only. Ids in the
//  ledger (SF5).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkCourse> kSkConfidenceCourses = [
  for (final (level, name) in [
    ('6-8', 'Use your voice'),
    ('8-11', 'Stand up and say it'),
    ('11-14', 'Give a real talk'),
  ]) ...[
    SkCourse(
      id: 'cf_course_${level.replaceAll('-', '')}_live',
      title: 'With a coach, $name',
      level: level,
      mode: SkCourseMode.live,
      blurb: 'A small group and a real speaking coach, one sitting a week: '
          'small turns first, a real talk last. It teaches speaking. '
          'Placeholder until a programme exists.',
      priceInr: 3499,
      priceUsd: 42,
      comingSoon: true,
    ),
    SkCourse(
      id: 'cf_course_${level.replaceAll('-', '')}_rec',
      title: 'At her own pace, $name',
      level: level,
      mode: SkCourseMode.recorded,
      blurb: 'Short films and stage exercises she works through at home, '
          'with a private turn to record after each. Placeholder until a '
          'programme exists.',
      priceInr: 999,
      priceUsd: 12,
      comingSoon: true,
    ),
  ],
];
