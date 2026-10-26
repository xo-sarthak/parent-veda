// =============================================================================
//  The Papers and money door — built 2026-10-02 from the parenting gap analysis
// -----------------------------------------------------------------------------
//  The content is `kPpPapersSection` (`pp_papers_content.dart`). Five areas,
//  one per tab, in the section's own order:
//
//    Child's documents       the birth certificate, Baal Aadhaar, the
//                            passport, and the document vault
//    Schemes to claim        PMMVY, anganwadi, free vaccines, JSSK, Sukanya,
//                            and a child with a disability
//    Health insurance        adding your baby; vaccines, OPD and therapy
//    Saving for your child   the common choices, and tax
//    Planning ahead          nominees, a will, a guardian
//
//  Door 14 (2026-10-26, `docs/pp-door-plans/14-papers.md`): Schemes is a
//  first-year tab and moves back from one; from three the Baal Aadhaar page
//  leads Documents, because its free update is due at five (PM1). No closing
//  card: no expert fits, and the vault is the door's last offer (PM5).
//  `test/pp_papers_door_test.dart` holds it.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpPapersDoor = PpDoor(
  sectionId: 'parenting_papers',
  // PM1: the first year is documents, PMMVY and the insurance window; after
  // it, insurance and saving matter more than the schemes.
  tabOrder: const {
    'infant': ['docs', 'schemes', 'insurance', 'saving', 'ahead'],
    'toddler_1': ['docs', 'insurance', 'saving', 'schemes', 'ahead'],
    'toddler_2': ['docs', 'insurance', 'saving', 'schemes', 'ahead'],
    'preschool': ['docs', 'insurance', 'saving', 'schemes', 'ahead'],
  },
  // PM6: Unsplash, free (Ashwini Chaudhary, unsplash.com/photos/awkngZALcVw,
  // Badarkha, Uttar Pradesh). A child sitting in an elder's lap at home,
  // looking straight at you: India, calm, nothing clinical. The plan's
  // "parent at a table with a folder" has no free photo that is not a tablet
  // advert or a dark desk. Checked by eye.
  heroImageUrl:
      'https://images.unsplash.com/photo-1632661765830-aa47ee0765c4?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'docs',
      // Door 14: three lines on the rail card at large text; the user's
      // word, 2026-10-26. Kept for revert:
      // label: 'Your child\'s documents',
      label: 'Child\'s documents',
      icon: Icons.badge_outlined,
      hue: 206,
      areaIds: ['documents'],
      // PM1: from three, the Baal Aadhaar page first. The same three pages,
      // the authored order otherwise kept; the area rail drops, so nothing
      // shows twice.
      ageRail: {
        'preschool': PpAgeRail('Your child\'s documents',
            ['pm_aadhaar', 'pm_birth_certificate', 'pm_passport']),
      },
      // PM5: the vault, after the pages. The door's last offer (no closing).
      tools: [
        PpDoorTool(
          label: 'Document vault',
          blurb: 'A photo or PDF of the birth certificate, Aadhaar, passport '
              'and policy, ready when someone asks.',
          surfaceId: 'pp_baby_documents',
          icon: Icons.folder_outlined,
          atEnd: true,
        ),
      ],
    ),
    PpDoorTab(
      id: 'schemes',
      // Door 14: "Government" is wider than the line at large text; the
      // user's word, 2026-10-26. Kept for revert:
      // label: 'Government schemes',
      label: 'Schemes to claim',
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
