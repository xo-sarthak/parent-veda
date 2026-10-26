// =============================================================================
//  The Special care door — built 2026-10-02 from the parenting gap analysis
// -----------------------------------------------------------------------------
//  The content is `kPpSpecialCareSection` (`pp_special_care_content.dart`). Five
//  areas, one per tab, in the section's own order:
//
//    Preemies and NICU    the NICU, bringing a premature baby home
//    Twins                feeding two, pumping, sleep and potty
//    Extra support        not talking yet, the therapies, hearing checks,
//                         autism signs, sensory, attention, acting early,
//                         a diagnosis from birth
//    Help in India        the DEIC, the UDID card, Niramaya, 80DD, pensions,
//                         school, step by step
//    Looking after you    the parent who carries most of it
//
//  Door 12 (2026-10-26, `docs/pp-door-plans/12-special-care.md`): a baby's
//  parent opens on the NICU, from one on Extra support (SC1); the
//  developmental paediatrician next to the worry (SC4).
//  `test/pp_special_care_door_test.dart` holds it.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpSpecialCareDoor = PpDoor(
  sectionId: 'parenting_special_care',
  // SC1: each age opens on what fits. A 3-year-old's parent worried about
  // speech used to start on the NICU and twins.
  tabOrder: const {
    'infant': ['early', 'twins', 'more', 'help', 'you'],
    'toddler_1': ['more', 'help', 'you', 'twins', 'early'],
    'toddler_2': ['more', 'help', 'you', 'twins', 'early'],
    'preschool': ['more', 'help', 'you', 'twins', 'early'],
  },
  // SC6: Unsplash, free (Vitaly Gariev, unsplash.com/photos/IGnXUcRKZzQ). A
  // parent and a toddler building block towers on the floor, side by side:
  // calm, nothing clinical, play as this door puts it. Checked by eye.
  heroImageUrl:
      'https://images.unsplash.com/photo-1714646793439-35c2c58596b0?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'early',
      // SC7: three lines at 1.3 on the rail card; the user's word, 2026-10-26.
      // Kept for revert:
      // label: 'Born early, and the NICU',
      label: 'Preemies and NICU',
      icon: Icons.child_care_outlined,
      hue: 344,
      areaIds: ['born_early'],
    ),
    PpDoorTab(
      id: 'twins',
      label: 'Twins',
      icon: Icons.looks_two_outlined,
      hue: 206,
      areaIds: ['twins'],
    ),
    PpDoorTab(
      id: 'more',
      label: 'Extra support', // was 'When your child needs a little more', three lines on a card (2026-10-24)
      icon: Icons.psychology_outlined,
      hue: 268,
      areaIds: ['additional_needs'],
      // SC4: the right person next to the worry, after the first rail. The
      // developmental paediatricians are placeholder profiles, so a tap says
      // they are joining and offers a paediatrician (S8b, Development's DV7
      // row, the same category). The speech therapist and the child
      // psychologist sit on the pages that name them.
      expert: PpDoorClosing(
        label: 'A developmental paediatrician',
        blurb: 'Worried about talking, moving or playing?',
        surfaceId: 'pp_experts/Development expert',
      ),
    ),
    PpDoorTab(
      id: 'help',
      label: 'Help in India',
      icon: Icons.support_outlined,
      hue: 160,
      areaIds: ['help_india'],
    ),
    PpDoorTab(
      id: 'you',
      // SC7: three lines at 1.3; the user's word, 2026-10-26. Kept for revert:
      // label: 'Looking after yourself',
      label: 'Looking after you',
      icon: Icons.spa_outlined,
      hue: 28,
      areaIds: ['caring_for_you'],
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to a paediatrician',
    blurb: 'About development, feeding twins or life after the NICU. Nothing here is a diagnosis.',
    surfaceId: 'pp_experts/Pediatrician',
  ),
);
