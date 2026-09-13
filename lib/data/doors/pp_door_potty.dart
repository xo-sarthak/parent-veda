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
//  age-specific. A baby's parent sees two tabs open and three locked; a
//  toddler's sees su-su gone and Dry nights locked until three.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpPottyDoor = PpDoor(
  sectionId: 'parenting_potty',
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
      label: 'Catching the su-su',
      icon: Icons.water_drop_outlined,
      hue: 206,
      areaIds: ['su_su_way'],
    ),
    PpDoorTab(
      id: 'starting_out',
      label: 'Starting out',
      icon: Icons.stairs_outlined,
      hue: 28,
      areaIds: ['getting_ready', 'how_to_do_it', 'things_to_do'],
    ),
    PpDoorTab(
      id: 'bumpy',
      label: 'Accidents and going backwards',
      icon: Icons.undo_rounded,
      hue: 344,
      areaIds: ['when_bumpy'],
      footer: 'Every single child, for months. A puddle is an event, not a '
          'verdict.',
    ),
    PpDoorTab(
      id: 'dry',
      label: 'Dry nights, doing it herself',
      icon: Icons.nights_stay_outlined,
      hue: 268,
      areaIds: ['staying_dry'],
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to a paediatrician about it',
    blurb: 'Withholding, a stubborn regression, bedwetting past five. One '
        'short call, and nothing here is a diagnosis.',
    surfaceId: 'pp_experts/Pediatrician',
  ),
);
