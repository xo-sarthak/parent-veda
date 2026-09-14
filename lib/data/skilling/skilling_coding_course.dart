// =============================================================================
//  Coding & AI literacy — the course shelf (placeholder programmes)
// -----------------------------------------------------------------------------
//  `ParentVeda_Coding_structure_v2.pdf`: "placeholder live and recorded
//  course entries, leveled, with a price field and an enrol action behind
//  the parent gate. Carry a flag that forbids outcome-claim copy."
//
//  ⚠️ THE ONE LINE HELD FIRM ON. "A course here can teach brilliantly and it
//  can be paid, but it cannot sell an outcome. No 'your child will be a
//  coder', no 'future-ready', no rank, no guarantee. Sell the teaching, never
//  the future." `SkCourse.noOutcomeClaims` is true on the type, and
//  `test/sk_doors_sanity_test.dart` scans every string here for the phrases
//  that would break it. Placeholder blurbs are therefore about the TEACHING
//  and nothing else.
//
//  ⚠️ PRICES ARE PLACEHOLDERS AND SAY SO ON SCREEN. Money is decided
//  server-side, always; the shelf displays a number so the layout is the
//  real layout, in both ₹ and $ per the house rule. Enrol opens a stub sheet
//  (the user's call, 2026-09-14, question 7), not the booking engine — a
//  real-looking purchase of a placeholder is worse than none.
//
//  One live and one recorded per level: the smallest shelf that shows the
//  whole shape. Real programmes replace these entries; ids are in the owed
//  ledger (S5).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkCourse> kSkCodingCourses = [
  for (final (level, name) in [
    ('6-8', 'Unplugged'),
    ('8-11', 'Blocks'),
    ('11-14', 'Projects'),
  ]) ...[
    SkCourse(
      id: 'cd_course_${level.replaceAll('-', '')}_live',
      title: '$name, live',
      level: level,
      mode: SkCourseMode.live,
      blurb: 'A small group, a real teacher, one sitting a week. Placeholder '
          'until a programme exists.',
      priceInr: 2999,
      priceUsd: 36,
      comingSoon: true,
    ),
    SkCourse(
      id: 'cd_course_${level.replaceAll('-', '')}_rec',
      title: '$name, recorded',
      level: level,
      mode: SkCourseMode.recorded,
      blurb: 'Short films she watches at her own pace, with things to try '
          'after each. Placeholder until a programme exists.',
      priceInr: 999,
      priceUsd: 12,
      comingSoon: true,
    ),
  ],
];
