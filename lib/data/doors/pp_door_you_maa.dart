// =============================================================================
//  The You, Maa door — the one door in the parenting stage that is not about
//  the baby
// -----------------------------------------------------------------------------
//  The content is `kPpYouMaaSection` (`pp_you_maa_content.dart`, 98 pages,
//  the second-biggest section in the app), rebuilt to
//  `You_Parenting_Maa_rebuild.pdf`. Her bands measure HER time since birth
//  (`kPpPostpartumBands`), kept separate from the baby's on purpose. Ten
//  areas on five tabs, on the user's call (2026-09-13):
//
//    How are you today, Maa?   the triage pinned, then "I do not feel like myself"
//    Your body                 what is happening to it, and the pelvic floor
//    Moving and eating         moving again, have you eaten, the healing kitchen
//    The people in your house  and the mothers who are not the only one
//    Going back                locks until six weeks, which fixes the dead card
//
//  ⚠️ THE TRIAGE IS PINNED, AND THE FRIGHTENING-THOUGHTS ROUTE IS PINNED
//  ABOVE IT. "The 'read this one first' line for frightening thoughts stays
//  at the very top, one tap from the crisis helpline. Do not move it down."
//  So it wears the red-flag treatment above the rails on the landing tab: a
//  mother for whom something feels wrong meets it before anything else,
//  without choosing a door.
//
//  ⚠️ NO TOOLS, NO SCORED MOOD TRACKER. "The triage is the front door, not a
//  scored tool." And never the baby's symptom checker for her.
//
//  ⚠️ THE ONE HOME FOR HER RECOVERY (judgement call 1). First 40 Days' acute
//  pages and its breasts card are windows into this section's pages now;
//  Feeding's mastitis red flag links in. One copy, three doors.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpYouMaaDoor = PpDoor(
  sectionId: 'parenting_maternal',
  aboutHer: true,
  // Unsplash, free. A woman by a window, quiet, holding a cup, no baby in
  // the frame: the one door that is about her. Nothing on it a page argues
  // with.
  heroImageUrl:
      'https://images.unsplash.com/photo-1630304678139-e041e0631ea2?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'today',
      label: 'How are you today, Maa?',
      icon: Icons.favorite_border_rounded,
      hue: 288,
      areaIds: ['how_are_you', 'your_mind'],
      redFlagPageId: 'you_route_scary',
      footer: 'Nothing here judges you, and nothing here will tell you that '
          'you are a danger to your baby.',
    ),
    PpDoorTab(
      id: 'body',
      label: 'Your body',
      icon: Icons.self_improvement_outlined,
      hue: 344,
      areaIds: ['your_body', 'pelvic_floor'],
    ),
    PpDoorTab(
      id: 'moving_eating',
      label: 'Moving and eating',
      icon: Icons.restaurant_outlined,
      hue: 96,
      areaIds: ['movement', 'feeding_yourself', 'healing_kitchen'],
      footer: 'For your back, your mood and your sleep. Not for your weight, '
          'anywhere on this door.',
    ),
    PpDoorTab(
      id: 'people',
      label: 'The people in your house',
      icon: Icons.groups_outlined,
      hue: 28,
      areaIds: ['people_around_you', 'the_circle'],
    ),
    PpDoorTab(
      id: 'going_back',
      label: 'Going back',
      icon: Icons.work_outline_rounded,
      hue: 186,
      areaIds: ['back_to_work'],
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to someone about your own recovery',
    blurb: 'A perinatal counsellor or psychologist, ranked by ParentVeda. '
        'For the part nobody in the house asks about.',
    surfaceId: 'pp_experts/Maternal mental health',
  ),
);
