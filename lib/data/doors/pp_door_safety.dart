// =============================================================================
//  The Keeping him safe door — home, water, road, first aid, body safety
// -----------------------------------------------------------------------------
//  The content is `kPpSafetySection` (`pp_safety_content.dart`), built
//  2026-10-02 from the parenting gap analysis. Five areas, one per tab, so
//  the grouping decision this file usually makes is simply the section's own
//  order:
//
//    Around the house    babyproofing, tip-overs, poisons, small things, walkers
//    Water               bath time, drowning
//    Road and heat       car seats and two-wheelers, parked cars, hot days
//    First aid           CPR, bleeding, animal bites
//    His body            safe touch and safe adults, age by age
//
//  ⚠️ FIRST AID IS NOT TRIAGE. Health's Get help now is the "is this an
//  emergency" door; this one is the calm-day reading that makes the bad day
//  go better. The pages link across rather than repeating Health's go-now
//  list, so there is one emergency list in the app.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpSafetyDoor = PpDoor(
  sectionId: 'parenting_safety',
  tabs: const [
    PpDoorTab(
      id: 'house',
      label: 'Around the house',
      icon: Icons.home_outlined,
      hue: 28,
      areaIds: ['around_house'],
      footer: 'Walk the house again each time your child can reach something '
          'new.',
    ),
    PpDoorTab(
      id: 'water',
      label: 'Bath time and water',
      icon: Icons.water_drop_outlined,
      hue: 206,
      areaIds: ['water_bath'],
    ),
    PpDoorTab(
      id: 'road',
      label: 'On the road, and in the heat',
      icon: Icons.directions_car_outlined,
      hue: 160,
      areaIds: ['road_out'],
    ),
    PpDoorTab(
      id: 'first_aid',
      label: 'First aid',
      icon: Icons.medical_services_outlined,
      hue: 344,
      areaIds: ['first_aid'],
      note: 'In an emergency, call 112. Read these once on a calm day.',
    ),
    PpDoorTab(
      id: 'body',
      label: 'My body is mine',
      icon: Icons.favorite_border_rounded,
      hue: 268,
      areaIds: ['body_safety'],
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to a paediatrician',
    blurb: 'About a fall, a bite, something swallowed, or how to make your '
        'home safer. Nothing here is a diagnosis.',
    surfaceId: 'pp_experts/Pediatrician',
  ),
);
