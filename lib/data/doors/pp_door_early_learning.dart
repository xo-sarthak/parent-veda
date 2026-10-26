// =============================================================================
//  The Early Learning door — play, stories, habits, and getting ready for school
// -----------------------------------------------------------------------------
//  The content is `kPpEarlyLearningSection` (`pp_early_learning_content.dart`,
//  the biggest section in the stage: 13 areas, 127 pages, 58 of them
//  stories; was "12 areas, 125 pages", corrected in the door 9 build, EL8),
//  rebuilt to `Early_Learning_Parenting.pdf`. The brief's one
//  structural finding: everything sat behind a door labelled "Prepare for
//  school", so a parent who wanted a bedtime story had to tap a
//  school-readiness button. Here the everyday things are the front, and the
//  school tab is one of five, on the user's call (2026-09-13) to split the
//  brief's fourth tab where the code already had two areas:
//
//    Ideas for today             the 36 activities, and learning through play
//    Stories and rhymes          how to tell one, six collections, the rhymes
//    Good habits                 fifteen, one page each
//    Letters, numbers            what actually comes first, and the language call
//    Starting school             readiness, the checklist, admission, the gate
//
//  (The first and fourth were "Do something today" and "Before letters and
//  numbers": three lines on the rail card at large text, renamed on the
//  user's word 2026-10-26.)
//
//  ⚠️ TALKING FIRST, FROM ONE TO THREE (door plan
//  `docs/pp-door-plans/09-early-learning.md`, EL1, yes 2026-10-25). Speech is
//  the most-asked question in the stage (609 hits) and the language page was
//  behind the fourth tab from two. Now a one- or two-year-old's door opens on
//  a "Talking first" rail whose first card is "Help him talk". Ages and
//  stories (EL2) are in the content file's area and page tags.
//
//  ⚠️ THE ACTIVITY PICKER IS NOT A TOOL HERE. "The activities in Tab 1 and
//  the 'Something to do today' picker are the same set. Keep one." The
//  first tab's rail IS the set for his age; a Tool card opening the same
//  set was the door-and-tool duplication the brief names. The other three
//  tools ride the tab they belong to; the expert is the closing.
//
//  ⚠️ NO RED FLAG, ON PURPOSE. "Keep the front door calm, with no red-flag
//  strip, since this section has no emergencies."
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpEarlyLearningDoor = PpDoor(
  sectionId: 'parenting_early_learning',
  // Unsplash, free. A small child and an adult bent over a drawing
  // together at a table: learning by doing, beside someone, with what is
  // already in the house. Nothing on it a page argues with.
  heroImageUrl:
      'https://images.unsplash.com/photo-1544776193-352d25ca82cd?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'today',
      // The user's word, 2026-10-26: three lines on the rail card at 1.3.
      // Was 'Do something today', kept for revert.
      label: 'Ideas for today',
      icon: Icons.toys_outlined,
      hue: 42,
      areaIds: ['today', 'montessori'],
      // EL1: from one to three the tab opens on talking. "Help him talk"
      // (the language page) first, then the rhymes and that age's talking
      // activities, which the area rail then skips. From three, no rail.
      ageRail: {
        'one': PpAgeRail('Talking first', [
          'skills_language', 'rhymes_collection', 'act_picture_point',
          'act_music_movement',
        ]),
        'two': PpAgeRail('Talking first', [
          'skills_language', 'rhymes_collection', 'act_story_actout',
          'act_pretend_shop',
        ]),
      },
      tools: [
        // EL7, built in the tools pass (33, 2026-10-26): named for what the
        // shelf holds. Nothing called a story box or activity box is stocked.
        // Was 'Story books, crayons and activity boxes', kept for revert.
        PpDoorTool(
          label: 'Toys and crayons',
          blurb: 'Only where buying something genuinely helps. Everything on '
              'this door works without any of it.',
          surfaceId: 'pp_recos',
          icon: Icons.shopping_bag_outlined,
          // After the free things (gap analysis P2, 2026-10-07).
          atEnd: true,
        ),
      ],
      footer: 'Never a worksheet. What comes before letters and numbers is '
          'not letters and numbers.',
    ),
    PpDoorTab(
      id: 'stories',
      label: 'Stories and rhymes',
      icon: Icons.auto_stories_outlined,
      hue: 268,
      areaIds: [
        'story_time', 'bedtime_tales', 'panchatantra', 'jataka', 'birbal',
        'tenali', 'world_tales', 'rhymes',
      ],
    ),
    PpDoorTab(
      id: 'habits',
      label: 'Good habits',
      icon: Icons.wb_sunny_outlined,
      hue: 128,
      areaIds: ['habits'],
    ),
    PpDoorTab(
      id: 'before_letters',
      // The user's word, 2026-10-26: three lines on the rail card at 1.3.
      // Was 'Before letters and numbers', kept for revert.
      label: 'Letters, numbers',
      icon: Icons.gesture_rounded,
      hue: 206,
      areaIds: ['early_skills'],
      tools: [
        // The one tracker, Development's. "Milestones and speech, the same
        // tracker used in Development. Kept in one place."
        PpDoorTool(
          // Named as the tool is (tools pass, 2026-10-25). Was 'Where your
          // baby is right now', three lines on a tab that opens at age 2.
          // EL7 asked for "His milestones"; the tools pass's R3 holds every
          // tracker card to the tool's own name, one name in every door
          // (pp_development_screens_test). Kept as the tool is. Tried in the
          // door 9 build, kept for revert: label: 'His milestones',
          label: 'Milestones',
          blurb: 'Milestones, speech and what usually comes next. Kept in one '
              'place so nothing here has to guess.',
          surfaceId: 'pp_milestones',
          icon: Icons.checklist_rtl_outlined,
        ),
      ],
    ),
    PpDoorTab(
      id: 'school',
      label: 'Starting school',
      icon: Icons.school_outlined,
      hue: 160,
      areaIds: ['school'],
      // The masterclass card is off until the course exists (gap analysis
      // P2, 2026-10-07: "Remove the masterclass card until the course
      // exists"). Kept for revert:
      // tools: [
      //   PpDoorTool(
      //     label: 'The early learning masterclass',
      //     blurb: 'A short course on play-based learning at home and what '
      //         'school readiness actually asks of a child.',
      //     surfaceId: 'pp_courses',
      //     icon: Icons.play_lesson_outlined,
      //   ),
      // ],
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to an early learning expert',
    blurb: 'A 1:1 about school readiness, or about whether any of it needs '
        'to be happening yet.',
    surfaceId: 'pp_experts/Early learning expert',
  ),
);
