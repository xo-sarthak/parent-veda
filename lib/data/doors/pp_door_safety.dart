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
//    Travel and heat     car seats and two-wheelers, flights, hot days
//    First aid           CPR, bleeding, animal bites
//    His body            safe touch and safe adults, age by age
//
//  ⚠️ FIRST AID IS NOT TRIAGE. Health's Get help now is the "is this an
//  emergency" door; this one is the calm-day reading that makes the bad day
//  go better. The pages link across rather than repeating Health's go-now
//  list, so there is one emergency list in the app.
//
//  ⚠️ THE EMERGENCY STRIP (door 11, SF1, 2026-10-26). Every tab opens on the
//  numbers as call buttons (`PpDoor.emergency`, the shared shell's), and on
//  First aid the strip is led by Get help now, pinned the way Health pins it.
//  The strip is not a second emergency list: it holds the numbers and two
//  ways to the steps, and Get help now stays the one list of signs.
//  `test/pp_safety_door_test.dart` fails if it goes missing on any tab.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../mind_mood_data.dart'
    show
        kAmbulanceNumber,
        kEmergencyNumber,
        kMotherBabyAmbulanceNumber,
        kPoisonsHelplineNumber;
import 'pp_door_data.dart';

final PpDoor kPpSafetyDoor = PpDoor(
  sectionId: 'parenting_safety',
  // SF2: the tab order for his age. A baby's parent opens on the house, with
  // first aid second; a three-year-old's on the road and crowds.
  tabOrder: const {
    'infant': ['house', 'first_aid', 'water', 'road', 'body'],
    'toddler_1': ['house', 'water', 'first_aid', 'road', 'body'],
    'toddler_2': ['house', 'water', 'first_aid', 'road', 'body'],
    'preschool': ['road', 'body', 'house', 'water', 'first_aid'],
  },
  // SF4: Unsplash, free (ONUR KURT, unsplash.com/photos/ycSXLokxvNs). A
  // toddler walking on a pavement, an adult's hand holding hers: road sense
  // as this door puts it, hand in hand. Nothing on it a page argues with.
  heroImageUrl:
      'https://images.unsplash.com/photo-1760205085646-2ce78b07c189?w=900&h=700&fit=crop',
  // SF1: the numbers, one tap from every tab. Each from its one constant.
  emergency: const PpDoorEmergency(
    calls: [
      PpDoorCall('Call $kEmergencyNumber', kEmergencyNumber),
      PpDoorCall('Ambulance $kAmbulanceNumber', kAmbulanceNumber),
      PpDoorCall('Poison help', kPoisonsHelplineNumber),
    ],
    numbersLine: 'Emergency $kEmergencyNumber · Ambulance $kAmbulanceNumber '
        'or $kMotherBabyAmbulanceNumber · Poison line '
        '$kPoisonsHelplineNumber (AIIMS)',
    links: [
      PpDoorEmergencyLink('Choking: what to do now',
          'pp_page/parenting_health/health_choking_response'),
      PpDoorEmergencyLink(
          'CPR: baby or child', 'pp_page/parenting_safety/safety_cpr'),
    ],
    pin: PpDoorEmergencyPin(
      tabId: 'first_aid',
      title: 'Get help now',
      line: 'The signs that mean go to a hospital now',
      surfaceId: 'pp_page/parenting_health/health_go_now',
    ),
  ),
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
      // SF8: was 'On the road, and in the heat' (three lines on the rail
      // card), kept for revert.
      // label: 'On the road, and in the heat',
      label: 'Travel and heat',
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
      // SF6: the tab ends on the first aid and CPR class, Health's own
      // (Get help now's closing), never a consult: one class, two ways in.
      // Not open yet, so a tap says "Tell me" (SFO3).
      closing: PpDoorClosing(
        label: 'Learn it on a calm day: baby first aid and CPR',
        blurb: 'Choking, burns, falls and fits, with a mannequin. Live, 2 hours.',
        surfaceId: 'pp_class/Baby first aid and CPR',
      ),
      // SF1: the emergency strip, led by Get help now, takes this line's
      // place. Kept for revert:
      // note: 'In an emergency, call 112. Read these once on a calm day.',
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
