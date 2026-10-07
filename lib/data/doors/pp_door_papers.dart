// =============================================================================
//  The Papers and money door — built 2026-10-02 from the parenting gap analysis
// -----------------------------------------------------------------------------
//  The content is `kPpPapersSection` (`pp_papers_content.dart`). Five areas,
//  one per tab, in the section's own order.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpPapersDoor = PpDoor(
  sectionId: 'parenting_papers',
  tabs: const [
    PpDoorTab(
      id: 'docs',
      label: 'Your child\'s documents',
      icon: Icons.badge_outlined,
      hue: 206,
      areaIds: ['documents'],
    ),
    PpDoorTab(
      id: 'schemes',
      label: 'Government schemes',
      icon: Icons.account_balance_outlined,
      hue: 42,
      areaIds: ['schemes'],
    ),
    PpDoorTab(
      id: 'insurance',
      label: 'Health insurance',
      icon: Icons.health_and_safety_outlined,
      hue: 344,
      areaIds: ['insurance'],
    ),
    PpDoorTab(
      id: 'saving',
      label: 'Saving for your child',
      icon: Icons.savings_outlined,
      hue: 160,
      areaIds: ['saving'],
    ),
    PpDoorTab(
      id: 'ahead',
      label: 'Planning ahead',
      icon: Icons.event_note_outlined,
      hue: 268,
      areaIds: ['planning'],
    ),
  ],
);
