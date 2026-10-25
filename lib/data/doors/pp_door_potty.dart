// =============================================================================
//  The Potty door — toilet learning, the su-su way, honestly told
// -----------------------------------------------------------------------------
//  The content is `kPpPottySection` (`pp_potty_content.dart`), rebuilt to
//  `Potty_Parenting.pdf`. The brief's main call is "collapse the two-door hub
//  into one library"; on the door that is simply the tile opening here. Its
//  seven areas sit on five tabs the brief did not draw, on the user's call
//  (2026-09-13):
//
//    How long this takes          the pinned timeline, every stage
//    Catching the su-su           the baby stage, real content not a wait
//    Starting out                 readiness, day by day, the activities
//    Accidents and going backwards
//    Dry nights, doing it herself
//
//  ⚠️ NO TOOLS, NO QUIZ, NO STAR CHARTS. All three on purpose: "a quiz that
//  says 'not ready' is the verdict the section deliberately avoids", and "a
//  chart of wins turns a wet afternoon into a visible failure on the wall".
//  The tabs carry no `tools`, and that is the brief, not an omission.
//
//  ⚠️ AGE IS A WEAK STAND-IN FOR POTTY STAGE, so three areas are widened to
//  the 3 to 6 band (judgement call 1) and only su-su and dry nights stay
//  age-specific. A baby's parent sees two tabs open and three for later; a
//  toddler's sees su-su gone and Dry nights for later until three.
//
//  ⚠️ IT OPENS ON SOMETHING TO DO NOW (door plan `docs/pp-door-plans/
//  05-potty.md`, PT1 and PT3, the user's yes 2026-10-24). Every age landed on
//  the timeline chart, and the only three activities were the last area of
//  the third tab. Now the opening tab is the one for his stage (su-su for a
//  baby, Starting out from one, Accidents from three), and it opens on "Try
//  this today": the activities for his stage, a fresh order each day. The
//  honest timeline stays one tab away.
//
//  ⚠️ STILL NO TOOLS, NO QUIZ, NO STAR CHARTS. The shelf is pages of the
//  section drawn in place, not a tool: no tick, no count, no "done".
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

/// "Try this today" (PT3), drawn in place on the tab that opens for his
/// stage. One id per tab that can host it; the shelf draws itself only on
/// the tab `tabOrder` opens for his band (`ppDoorInlineToolFor`).
const String kPpPottyTodayShelf = 'pp_potty_today';

final PpDoor kPpPottyDoor = PpDoor(
  sectionId: 'parenting_potty',
  // PT1: the tab for his stage first; the timeline one tab away.
  tabOrder: const {
    'su_su': ['su_su', 'how_long', 'starting_out', 'bumpy', 'dry'],
    'pt_1_2': ['starting_out', 'how_long', 'bumpy', 'dry'],
    'pt_2_3': ['starting_out', 'bumpy', 'how_long', 'dry'],
    'pt_3_4': ['bumpy', 'dry', 'starting_out', 'how_long'],
    'pt_4_6': ['bumpy', 'dry', 'starting_out', 'how_long'],
  },
  // Unsplash, free. A toddler at the bathroom mirror, brushing her own
  // teeth, laughing: the doing-it-herself end of the arc, in the room this
  // door is about, and nothing on it a page argues with.
  heroImageUrl:
      'https://images.unsplash.com/photo-1780327065644-399075fb9e9b?w=900&h=700&fit=crop',
  tabs: const [
    // ⚠️ THE TIMELINE ALONE. Readiness sat here first, and for a baby's
    // parent the tab promised "is she ready" and showed one card — the
    // readiness rail is 1 to 6 and hid inside an open tab instead of
    // locking. Moved to Starting out (the user's call, 2026-09-13), where
    // it locks cleanly with "From 1 year".
    PpDoorTab(
      id: 'how_long',
      label: 'How long this takes',
      icon: Icons.timelapse_outlined,
      hue: 160,
      areaIds: ['the_real_shape'],
    ),
    PpDoorTab(
      id: 'su_su',
      label: 'Catching the wee early',
      icon: Icons.water_drop_outlined,
      hue: 206,
      areaIds: ['su_su_way'],
      // PT3: the baby shelf. PT5: no expert, it is a light stage.
      inlineSurfaceId: '$kPpPottyTodayShelf/su_su',
    ),
    PpDoorTab(
      id: 'starting_out',
      label: 'Starting out',
      icon: Icons.stairs_outlined,
      hue: 28,
      // ⚠️ THE ACTIVITIES STAY ON THIS TAB, AND THE RAILS SKIP WHAT THE
      // SHELF DRAWS. From one to three the shelf is these pages for his band;
      // for every other age they are the rail they always were, and the
      // other bands' activities fold at the foot, so none is ever lost.
      areaIds: ['getting_ready', 'how_to_do_it', 'things_to_do'],
      inlineSurfaceId: '$kPpPottyTodayShelf/starting_out',
      // PT1: from two, day by day comes before readiness. The rail is the
      // whole area, so the area rail below drops and readiness follows.
      ageRail: {
        'pt_2_3': PpAgeRail('Starting out, day by day', [
          'introducing_potty', 'daily_routine', 'words_and_cues',
          'indian_toilet', 'boys_and_girls', 'three_day_method', 'pull_ups',
        ]),
      },
      // PT5: the category exists (Behaviour's row uses it).
      expert: PpDoorClosing(
        label: 'A child psychologist',
        blurb: 'Refusal and fear?',
        surfaceId: 'pp_experts/Child psychologist',
      ),
    ),
    PpDoorTab(
      id: 'bumpy',
      label: 'Accidents and going backwards',
      icon: Icons.undo_rounded,
      hue: 344,
      areaIds: ['when_bumpy'],
      // PT3: from three this tab opens, on the calm-reset activities.
      inlineSurfaceId: '$kPpPottyTodayShelf/bumpy',
      expert: PpDoorClosing(
        label: 'A paediatrician',
        blurb: "Withholding, or a regression that won't lift?",
        surfaceId: 'pp_experts/Pediatrician',
      ),
      footer: 'Every single child, for months. A puddle is an event, not a '
          'verdict.',
    ),
    PpDoorTab(
      id: 'dry',
      label: 'Dry nights', // was 'Dry nights, doing it herself', three lines on a card (2026-10-24)
      icon: Icons.nights_stay_outlined,
      hue: 268,
      areaIds: ['staying_dry'],
      // PT5. The plan's paediatric urologist has no category; a worried
      // parent reaches a paediatrician, who refers (Health's rule).
      expert: PpDoorClosing(
        label: 'A paediatrician',
        blurb: 'Wet past five?',
        surfaceId: 'pp_experts/Pediatrician',
      ),
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to a paediatrician about it',
    blurb: 'Withholding, a stubborn regression, bedwetting past five. One '
        'short call, and nothing here is a diagnosis.',
    surfaceId: 'pp_experts/Pediatrician',
  ),
);
