// =============================================================================
//  The Your growing family door — built 2026-10-02 from the parenting gap analysis
// -----------------------------------------------------------------------------
//  The content is `kPpFamilySection` (`pp_family_content.dart`). Five areas,
//  one per tab, in the section's own order.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpFamilyDoor = PpDoor(
  sectionId: 'parenting_family',
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
      label: 'For fathers',
      icon: Icons.man_outlined,
      hue: 206,
      areaIds: ['fathers'],
    ),
    PpDoorTab(
      id: 'grand',
      label: 'Grandparents and the joint family',
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
      label: 'Who looks after your child',
      icon: Icons.work_outline,
      hue: 42,
      areaIds: ['childcare'],
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to a child psychologist',
    blurb: 'About jealousy, a hard transition, or how the family is coping. Nothing here is a diagnosis.',
    surfaceId: 'pp_experts/Child psychologist',
  ),
);
