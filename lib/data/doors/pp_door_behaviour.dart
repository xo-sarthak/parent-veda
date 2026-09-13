// =============================================================================
//  The Behaviour door — why she does it, what to do, the words to use
// -----------------------------------------------------------------------------
//  The content is `kPpBehaviourSection` (`pp_behaviour_content.dart` and its
//  two sibling files), rebuilt to `Behaviour_Parenting.pdf` (31 Aug 2026).
//  The brief's own call is "one library plus a tools rail, do NOT invent a
//  five-tab structure"; the user's standing call is that every parenting door
//  wears the door shell, so the twelve areas sit on five tabs the brief did
//  not draw. The grouping is the user's (2026-09-13), not the brief's:
//
//    Crying · the first year        the one infant area
//    Tantrums and the ziddi years   ziddi, first tantrums and hitting, no
//    He keeps doing this            the lookup door, screens, the habits
//    Scared, shy or clingy          the missing half, one new area
//    Calm and guidance              the six practices, no hitting, three to six
//
//  ⚠️ TABS DROP AWAY WITH HIS BAND. A parent of a three-month-old sees one
//  tab; the four toddler tabs have nothing for her band and are not on the
//  selector. A parent of a four-year-old does not see Crying. The shell does
//  this from the areas' own bands, so this file names no ages.
//
//  ⚠️ NO RED FLAG TAB, ON PURPOSE. "Health and Complications earned one
//  because they hold same-day medical emergencies. Behaviour does not; its
//  flags are page-level. A red-flag strip where there are none trains people
//  to ignore the real ones."
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpBehaviourDoor = PpDoor(
  sectionId: 'parenting_behaviour',
  // Unsplash, free. A toddler mid-shout on a beach, arms up, gleeful and
  // furious at once: the big feeling in a small body this door is about,
  // with nobody scolding in the frame.
  heroImageUrl:
      'https://images.unsplash.com/photo-1471286174890-9c112ffca5b4?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'crying',
      label: 'Crying, the first year',
      icon: Icons.nightlight_outlined,
      hue: 232,
      areaIds: ['crying'],
      tools: [
        // The scripts tool rides the infant tab too: in this band the words
        // are for answering the family, not the baby, and this is the only
        // tab an infant's parent sees. The toddler tabs carry it on
        // Tantrums; no parent sees both.
        PpDoorTool(
          label: 'What to say when…',
          blurb: 'The words for the family: "you are spoiling him", "let him '
              'cry". Search it while it is happening.',
          surfaceId: 'pp_scripts',
          icon: Icons.chat_bubble_outline_rounded,
        ),
      ],
    ),
    PpDoorTab(
      id: 'tantrums',
      label: 'Tantrums and the ziddi years',
      icon: Icons.whatshot_outlined,
      hue: 344,
      areaIds: ['ziddi', 'first_feelings', 'the_no_year'],
      tools: [
        // The hero tool. "Find the moment, get the sentence. Referenced from
        // six pages, one tool." Its age chips came off; it opens on his band.
        PpDoorTool(
          label: 'What to say when…',
          blurb: 'The exact words for the moment you are in, and what to '
              'leave unsaid. Search it while it is happening.',
          surfaceId: 'pp_scripts',
          icon: Icons.chat_bubble_outline_rounded,
        ),
      ],
    ),
    PpDoorTab(
      id: 'this_one_thing',
      label: 'He keeps doing this',
      icon: Icons.repeat_rounded,
      hue: 42,
      areaIds: ['specific_behaviours', 'screen_time', 'habits'],
      tools: [
        // The one What Changed checker, shared with Health and Development,
        // opened pre-filtered to the Behaviour and Mood concerns.
        PpDoorTool(
          label: 'Something has changed',
          blurb: 'Started biting, head-banging, suddenly clingy. Work through '
              'it calmly.',
          surfaceId: 'pp_what_changed/behaviour',
          icon: Icons.swap_horiz_rounded,
        ),
      ],
    ),
    PpDoorTab(
      id: 'scared',
      label: 'Scared, shy or clingy',
      icon: Icons.dark_mode_outlined,
      hue: 206,
      areaIds: ['scared'],
    ),
    PpDoorTab(
      id: 'calm',
      label: 'Calm and guidance',
      icon: Icons.spa_outlined,
      hue: 128,
      areaIds: ['calming', 'discipline', 'older_child'],
      footer: 'Warm and firm is a third thing. It is not the middle of the '
          'other two.',
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to a child psychologist',
    blurb: 'For behaviour that has stopped responding to anything you try, '
        'or that is frightening you. Nothing here is a diagnosis.',
    surfaceId: 'pp_experts/Child psychologist',
  ),
);
