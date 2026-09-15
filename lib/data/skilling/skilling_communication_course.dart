// =============================================================================
//  Communication & articulation — the course shelf (placeholder programmes)
// -----------------------------------------------------------------------------
//  `ParentVeda_Communication_structure.pdf`: "Classes: spoken expression,
//  storytelling, speaking up (parent buys) — Course shelf — build now
//  placeholder, no future-promises", and its call 2: "let the course shelf
//  serve the demand [for spoken English] without ever promising an outcome."
//
//  The user's call (2026-09-15, question 4, a): the brief's three, PLUS one
//  "Speaking in English, too" slot per level. Every entry is language-neutral
//  in its framing — mother tongue first — and every string is under the
//  no-outcome scan: no fluency as a destiny, no rank, no future.
//
//  ⚠️ NOT "SPOKEN ENGLISH CLASSES". The brief: "This is where the market and
//  the money are … and it is exactly the claim we refuse to make, that a
//  course buys a child's future." The English slot is named for what it
//  adds ("too"), never for what it promises.
//
//  Prices are placeholders, in both currencies, display only; enrol is a
//  stub sheet. Ids are in the owed ledger (SC5).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkCourse> kSkCommunicationCourses = [
  for (final (level, name) in [
    ('6-8', 'Say it out loud'),
    ('8-11', 'Tell it and explain it'),
    ('11-14', 'Say what you think'),
  ]) ...[
    SkCourse(
      id: 'cm_course_${level.replaceAll('-', '')}_expression',
      title: 'Spoken expression, $name',
      level: level,
      mode: SkCourseMode.live,
      blurb: 'A small group and a real teacher, one sitting a week, in her '
          'own language first. Placeholder until a programme exists.',
      priceInr: 2999,
      priceUsd: 36,
      comingSoon: true,
    ),
    SkCourse(
      id: 'cm_course_${level.replaceAll('-', '')}_storytelling',
      title: 'Storytelling, $name',
      level: level,
      mode: SkCourseMode.recorded,
      blurb: 'Short films and story frames she works through at her own '
          'pace. Placeholder until a programme exists.',
      priceInr: 999,
      priceUsd: 12,
      comingSoon: true,
    ),
    SkCourse(
      id: 'cm_course_${level.replaceAll('-', '')}_speaking_up',
      title: 'Speaking up, $name',
      level: level,
      mode: SkCourseMode.live,
      blurb: 'Saying what you think, with a reason, to people who answer '
          'back. Placeholder until a programme exists.',
      priceInr: 2999,
      priceUsd: 36,
      comingSoon: true,
    ),
    SkCourse(
      id: 'cm_course_${level.replaceAll('-', '')}_english',
      title: 'Speaking in English, too — $name',
      level: level,
      mode: SkCourseMode.live,
      blurb: 'The same speaking practice, in English as well as her own '
          'language. It teaches; it does not sell fluency. Placeholder until '
          'a programme exists.',
      priceInr: 2999,
      priceUsd: 36,
      comingSoon: true,
    ),
  ],
];
