// =============================================================================
//  The Your growing family door — built 2026-10-02 from the parenting gap analysis
// -----------------------------------------------------------------------------
//  The content is `kPpFamilySection` (`pp_family_content.dart`). Five areas,
//  one per tab, in the section's own order:
//
//    A second baby          telling your firstborn, the first weeks with two,
//                           the age gap, tandem feeding
//    For fathers            low mood, breastfeeding help, leave, the night
//                           shift, bonding, her anxiety, doing it on your own
//    Grandma, grandpa       grandparents close by, when you two disagree,
//                           you two after the baby
//    Brothers and sisters   jealousy and fighting
//    Care while you work    choosing care, settling in, and links to You,
//                           Maa's back-to-work pages
//
//  Door 13 (2026-10-26, `docs/pp-door-plans/13-family.md`): a baby's parent
//  opens on Grandma, grandpa, from one on A second baby (FM1).
//  `test/pp_family_door_test.dart` holds it.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpFamilyDoor = PpDoor(
  sectionId: 'parenting_family',
  // FM1: each age opens on what fits. A 2-month-old's mother used to open on
  // the second-baby tab.
  tabOrder: const {
    'infant': ['grand', 'care', 'fathers', 'second', 'siblings'],
    'toddler_1': ['second', 'siblings', 'care', 'grand', 'fathers'],
    'toddler_2': ['second', 'siblings', 'care', 'grand', 'fathers'],
    'preschool': ['second', 'siblings', 'care', 'grand', 'fathers'],
  },
  // FM5: Unsplash, free (Samar Ahmad, unsplash.com/photos/qtlW4e80RAA). An
  // older brother, smiling, holding his baby brother on his lap at home:
  // warm, nothing clinical. Checked by eye.
  heroImageUrl:
      'https://images.unsplash.com/photo-1678282613496-9a3cbea0cc0f?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'second',
      label: 'A second baby',
      icon: Icons.child_friendly_outlined,
      hue: 322,
      areaIds: ['second_baby'],
    ),
    PpDoorTab(
      id: 'fathers',
      label: 'For fathers', // FM4: stays; the area blurb names parents on their own
      icon: Icons.man_outlined,
      hue: 206,
      areaIds: ['fathers'],
    ),
    PpDoorTab(
      id: 'grand',
      // Door 13: "Grandparents" is wider than the line at 1.3 and broke
      // mid-word; the user's word, 2026-10-26. Kept for revert:
      // label: 'Grandparents', // was 'Grandparents and the joint family', three lines on a card (2026-10-24)
      label: 'Grandma, grandpa',
      icon: Icons.elderly_outlined,
      hue: 28,
      areaIds: ['grandparents'],
    ),
    PpDoorTab(
      id: 'siblings',
      label: 'Brothers and sisters',
      icon: Icons.people_outline,
      hue: 160,
      areaIds: ['siblings'],
    ),
    PpDoorTab(
      id: 'care',
      // FM4: three lines on the rail card. Kept for revert:
      // label: 'Who looks after your child',
      label: 'Care while you work',
      icon: Icons.work_outline,
      hue: 42,
      areaIds: ['childcare'],
    ),
  ],
  // FM5: drawn by the shell since step 0 (S3). Child psychologists open
  // their own list (Behaviour's and Special care's builds).
  closing: const PpDoorClosing(
    label: 'Talk to a child psychologist',
    blurb: 'About jealousy, a hard transition, or how the family is coping. Nothing here is a diagnosis.',
    surfaceId: 'pp_experts/Child psychologist',
  ),
);
