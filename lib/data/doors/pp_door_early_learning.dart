// =============================================================================
//  The Early Learning door — play, stories, habits, and getting ready for school
// -----------------------------------------------------------------------------
//  The content is `kPpEarlyLearningSection` (`pp_early_learning_content.dart`,
//  the biggest section in the stage: 12 areas, 125 pages, 58 of them
//  stories), rebuilt to `Early_Learning_Parenting.pdf`. The brief's one
//  structural finding: everything sat behind a door labelled "Prepare for
//  school", so a parent who wanted a bedtime story had to tap a
//  school-readiness button. Here the everyday things are the front, and the
//  school tab is one of five, on the user's call (2026-09-13) to split the
//  brief's fourth tab where the code already had two areas:
//
//    Do something today          the 36 activities, and learning through play
//    Stories and rhymes          how to tell one, six collections, the rhymes
//    Good habits                 fifteen, one page each
//    Before letters and numbers  what actually comes first, and the language call
//    Starting school             readiness, the checklist, the gate
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
      label: 'Do something today',
      icon: Icons.toys_outlined,
      hue: 42,
      areaIds: ['today', 'montessori'],
      tools: [
        PpDoorTool(
          label: 'Story books, crayons and activity boxes',
          blurb: 'Only where buying something genuinely helps. Everything on '
              'this door works without any of it.',
          surfaceId: 'pp_recos',
          icon: Icons.shopping_bag_outlined,
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
      label: 'Before letters and numbers',
      icon: Icons.gesture_rounded,
      hue: 206,
      areaIds: ['early_skills'],
      tools: [
        // The one tracker, Development's. "Milestones and speech, the same
        // tracker used in Development. Kept in one place."
        PpDoorTool(
          label: 'Where he is right now',
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
      tools: [
        PpDoorTool(
          label: 'The early learning masterclass',
          blurb: 'A short course on play-based learning at home and what '
              'school readiness actually asks of a child.',
          surfaceId: 'pp_courses',
          icon: Icons.play_lesson_outlined,
        ),
      ],
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to an early learning expert',
    blurb: 'A 1:1 about school readiness, or about whether any of it needs '
        'to be happening yet.',
    surfaceId: 'pp_experts/Early learning expert',
  ),
);
