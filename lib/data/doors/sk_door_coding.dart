// =============================================================================
//  The Coding door — play first, then blocks, then real things she makes
// -----------------------------------------------------------------------------
//  Built to `ParentVeda_Coding_structure_v2.pdf` (11 Sep 2026), the first
//  skill door and the one that lays the shell. The content is
//  `kSkCodingContent` (`lib/data/skilling/skilling_coding_*.dart`); the
//  contract is `test/sk_coding_door_test.dart`.
//
//  The five tabs are the brief's five child surfaces, in the brief's own
//  order, on the user's call (2026-09-14): "follow the brief completely, I
//  want to see how the brief does; then give your suggestions." The
//  regrouping the build would have proposed is in
//  `docs/SKILLING-DOORS-REVIEW.md`, not here.
//
//  ⚠️ NO CONSULT CLOSING. The brief holds Consult ("A rare expert. Nothing
//  to book yet."), so the closing card is the way to the grown-up side —
//  the parent note, the course shelf, the product shelf and settings —
//  behind the grown-up gate. When Consult is un-held, the Consult card
//  arrives and this one moves to a second card or a hero control; the
//  shell's `SkDoorClosing.chip` already tells the two apart.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'sk_door_data.dart';

final SkDoor kSkCodingDoor = SkDoor(
  doorId: 'skilling_coding',
  // Unsplash, free. A spill of plastic building bricks, no face, no screen:
  // "blocks" in the plainest sense, and nothing in it contradicts the
  // youngest band's "no code yet". Swap when a better free one turns up
  // (the review file lists it).
  heroImageUrl:
      'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=900&h=700&fit=crop',
  tabs: const [
    SkDoorTab(
      id: 'today',
      label: "Today's thing to try",
      icon: Icons.wb_sunny_outlined,
      hue: 42,
      kind: SkTabKind.today,
    ),
    SkDoorTab(
      id: 'things_to_do',
      label: 'Things to do',
      icon: Icons.extension_outlined,
      hue: 186,
      kind: SkTabKind.activities,
      footer: 'Every one of these is built around one real thinking skill. '
          'You just play.',
    ),
    SkDoorTab(
      id: 'lessons',
      label: 'Lessons',
      icon: Icons.menu_book_outlined,
      hue: 232,
      kind: SkTabKind.lessons,
    ),
    SkDoorTab(
      id: 'ai',
      label: 'AI, explained',
      icon: Icons.smart_toy_outlined,
      hue: 288,
      kind: SkTabKind.crossBand,
    ),
    SkDoorTab(
      id: 'made_and_tried',
      label: "What I've made and tried",
      icon: Icons.auto_awesome_outlined,
      hue: 128,
      kind: SkTabKind.keepsake,
      tools: [
        SkDoorTool(
          label: "What I've made and tried",
          blurb: 'What you tried, practised again and made. '
              'Words, never a score.',
          surfaceId: 'sk_keepsake/skilling_coding',
          icon: Icons.auto_awesome_outlined,
          chip: 'Keepsake',
        ),
      ],
    ),
  ],
  closing: const SkDoorClosing(
    label: 'For the grown-up',
    blurb: 'What she has been doing and why it helps, the classes and the '
        'kits a parent can buy, and her settings.',
    surfaceId: 'sk_grown_up/skilling_coding',
  ),
);
