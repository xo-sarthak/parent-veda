// =============================================================================
//  The Sleep door — seven collections on five tabs
// -----------------------------------------------------------------------------
//  The content is `kPpSleepSection` (`pp_sleep_content.dart`), built from the
//  rebuild brief. This file is only how it is laid over the door shell the
//  TTC and pregnancy doors wear — decided 2026-09-11 after the brief's own
//  landing-and-library shape was built and seen on a phone: the parenting
//  doors are to open the way every other door opens.
//
//  ⚠️ THE GROUPING, AND WHY. The brief's seven collections are the seven
//  areas of the section, and the selector draws five cards. Two pairs sit
//  naturally together:
//
//    · "She keeps waking at night" and "Her sleep suddenly got worse" are
//      both the night going wrong — one tonight, one this fortnight.
//    · "The things that worry you" and "Music, lori and sleep sounds" are
//      the collections that are not a stage of the night: the questions,
//      and the thing she reaches for at 2am.
//
//  The brief's LANDING items live on the tabs rather than above them: the
//  tracker ("Track & understand sleep") is a tool row on the first tab, where
//  her range is; Sleep Sounds is a tool row beside the sound library; and
//  "Talk to a sleep expert" is the door's closing row, under every tab. Nothing
//  from the landing is dropped.
//
//  ⚠️ THE RED FLAG IS THE DOCTOR PAGE, PINNED. "When night waking needs a
//  doctor" was the last card of a rail; the door shape has a place for it
//  above the rail, coral, and the brief's own format for it is "Red flag".
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpSleepDoor = PpDoor(
  sectionId: 'parenting_sleep',
  // Hu Chen, Unsplash. A sleeping face and a curled fist, close enough that
  // neither the position nor the bedding is in frame — see
  // `PpDoor.heroImageUrl` for why that is the requirement here.
  heroImageUrl:
      'https://images.unsplash.com/photo-1552819289-e14fbbcea868?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'how_much',
      label: 'How much sleep',
      icon: Icons.bedtime_outlined,
      hue: 206,
      areaIds: ['how_much'],
      tools: [
        // ⚠️ THE TRACKER, WHERE HER RANGE IS. "Tracker = Log her sleep =
        // Track & understand (one surface, keep Pampers)." `pp_sleep` is the
        // Sleep journey, Presented by Pampers, already age-aware; it is not
        // rebuilt or wrapped.
        PpDoorTool(
          label: 'Track and understand sleep',
          blurb: 'Log naps and nights, watch a pattern emerge, and get gentle '
              'age context, with no target to hit.',
          surfaceId: 'pp_sleep',
          icon: Icons.show_chart_rounded,
        ),
      ],
    ),
    PpDoorTab(
      id: 'waking',
      label: 'Waking at night',
      icon: Icons.nightlight_outlined,
      hue: 268,
      areaIds: ['night_waking', 'regressions'],
      redFlagPageId: 'waking_doctor',
    ),
    PpDoorTab(
      id: 'getting',
      label: 'Getting her to sleep',
      icon: Icons.self_improvement_outlined,
      hue: 26,
      areaIds: ['getting_to_sleep'],
    ),
    PpDoorTab(
      id: 'safe',
      label: 'Safe sleep',
      icon: Icons.shield_outlined,
      hue: 152,
      areaIds: ['safe_sleep'],
    ),
    PpDoorTab(
      id: 'worries',
      label: 'Worries and sounds',
      icon: Icons.music_note_outlined,
      hue: 188,
      areaIds: ['worries', 'music'],
      tools: [
        // "Sleep Sounds tool = the library in collection 7." The row opens
        // the player; the library page on the rail is generated from the
        // same data.
        PpDoorTool(
          label: 'Sleep Sounds',
          blurb: 'Lori, white noise, rain, soft ragas and bedtime stories, '
              'with a timer that switches itself off.',
          surfaceId: 'pp_sleep_sounds',
          icon: Icons.music_note_outlined,
          chip: 'Audio',
        ),
      ],
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to a sleep expert',
    blurb: 'Book a 1:1 if the nights are wearing you down more than the day '
        'can fix.',
    // The hub's own filtered roster — see `kPpSleep.closing` for why it is
    // filtered and why that was once reverted.
    surfaceId: 'pp_experts/Sleep expert',
  ),
);
