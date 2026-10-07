// =============================================================================
//  The Special care door — built 2026-10-02 from the parenting gap analysis
// -----------------------------------------------------------------------------
//  The content is `kPpSpecialCareSection` (`pp_special_care_content.dart`). Five areas,
//  one per tab, in the section's own order.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpSpecialCareDoor = PpDoor(
  sectionId: 'parenting_special_care',
  tabs: const [
    PpDoorTab(
      id: 'early',
      label: 'Born early, and the NICU',
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
      label: 'When your child needs a little more',
      icon: Icons.psychology_outlined,
      hue: 268,
      areaIds: ['additional_needs'],
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
      label: 'Looking after yourself',
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
