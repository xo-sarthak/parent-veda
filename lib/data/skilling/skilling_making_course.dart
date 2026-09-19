// =============================================================================
//  Creativity & expression — the course shelf (placeholders, deliberately small)
// -----------------------------------------------------------------------------
//  `ParentVeda_Creativity_structure.pdf`: "A few art or music classes, if
//  the parent wants them — Course shelf — build now, small placeholder, not
//  a ladder", resolved as "Deliberately small. A few art or music classes
//  a parent may buy. Not a leveled paid ladder, no outcome promise.
//  Creativity is not sold in levels."
//
//  The user's call (2026-09-18, 2a): keep it light — the opposite of
//  Confidence, on purpose. One art and one music class per level, live,
//  placeholders behind the gate, in both currencies, display only. Every
//  string is under the no-outcome scan; nothing says "artist", "talent",
//  "level" or "your child could be". Ids in the ledger (MK6).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkCourse> kSkMakingCourses = [
  for (final (level, name) in [
    ('6-8', 'Just make it'),
    ('8-11', 'Make it yours'),
    ('11-14', 'Make something real'),
  ]) ...[
    SkCourse(
      id: 'mk_course_${level.replaceAll('-', '')}_art',
      title: 'An art class, $name',
      level: level,
      mode: SkCourseMode.live,
      blurb: 'A few sittings with a real art teacher, making with what is '
          'to hand. For the fun of it, with nothing to get right. '
          'Placeholder until a class exists.',
      priceInr: 999,
      priceUsd: 12,
      comingSoon: true,
    ),
    SkCourse(
      id: 'mk_course_${level.replaceAll('-', '')}_music',
      title: 'A music class, $name',
      level: level,
      mode: SkCourseMode.live,
      blurb: 'A few sittings with a real music teacher: a beat, a tune, a '
          'song. For the fun of it, with nothing to get right. Placeholder '
          'until a class exists.',
      priceInr: 999,
      priceUsd: 12,
      comingSoon: true,
    ),
  ],
];
