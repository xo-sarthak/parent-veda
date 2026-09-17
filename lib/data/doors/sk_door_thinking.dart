// =============================================================================
//  The Thinking door — chains of why, and enjoying being wrong
// -----------------------------------------------------------------------------
//  Built to `ParentVeda_Thinking_structure.pdf`, door four, "the stage's
//  default shape, so the work here is editorial, not structural". The
//  content is `kSkThinkingContent` (`lib/data/skilling/skilling_thinking_*`);
//  the contract is `test/sk_thinking_door_test.dart`.
//
//  ⚠️ FIVE CARDS, THE BRIEF'S CHILD SURFACES. Three band sets, the lesson
//  set (puzzles, why-chains, the spotting-fake strand, and the fun extras),
//  and the keepsake. The keepsake is the shared no-score one under this
//  door's name — "You kept thinking" — which is what the brief's extras
//  reshape says: "The certificate becomes a 'you kept thinking' keepsake."
//  One keepsake, one store, a per-door title.
//
//  ⚠️ QUESTION IDEAS, NOT PEOPLE. The user's call (2026-09-17, 1a): the
//  careful framing. The door's blurb and every footer say what she checks
//  — a claim, a forward, an argument — and never who she argues with.
//
//  ⚠️ CONSULT IS HELD. "A reasoning or debate coach, rarely. Held." No coach
//  row on this door; the closing card is the grown-up screen.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'sk_door_data.dart';

final SkDoor kSkThinkingDoor = SkDoor(
  doorId: 'skilling_critical_thinking',
  // Unsplash, free. A child at a desk, head down, working something out on
  // paper — the brief's "reasoning about concrete things a child knows",
  // no lightbulb, no chessboard, nothing on the wall to read.
  heroImageUrl:
      'https://images.unsplash.com/photo-1529390079861-591de354faf5?w=900&h=700&fit=crop',
  tabs: const [
    SkDoorTab(
      id: 'ask_lots_of_whys',
      label: 'Ask lots of whys',
      icon: Icons.help_outline_rounded,
      hue: 268,
      kind: SkTabKind.activities,
      bandId: '6-8',
      footer: 'Riddles, guessing games, why-is-the-sky questions, and the '
          'first "is this real or pretend?".',
    ),
    SkDoorTab(
      id: 'work_out_how_it_works',
      label: 'Work out how it works',
      icon: Icons.settings_suggest_outlined,
      hue: 200,
      kind: SkTabKind.activities,
      bandId: '8-11',
      footer: 'Reasoning puzzles, why-chains, breaking a thing down, and '
          'spotting a silly or too-good-to-be-true claim.',
    ),
    SkDoorTab(
      id: 'think_for_yourself',
      label: 'Think for yourself',
      icon: Icons.psychology_outlined,
      hue: 26,
      kind: SkTabKind.activities,
      bandId: '11-14',
      footer: 'Checking if something is true, seeing the other side, light '
          'debate, and the real skill: changing your mind.',
    ),
    SkDoorTab(
      id: 'lessons',
      label: 'Lessons',
      icon: Icons.extension_outlined,
      hue: 128,
      kind: SkTabKind.lessons,
    ),
    SkDoorTab(
      id: 'you_kept_thinking',
      label: 'You kept thinking',
      icon: Icons.auto_awesome_outlined,
      hue: 344,
      kind: SkTabKind.keepsake,
      tools: [
        SkDoorTool(
          label: 'You kept thinking',
          blurb: 'That you came and reasoned — what you tried, did again '
              'and worked out. Words, never a thinking score.',
          surfaceId: 'sk_keepsake/skilling_critical_thinking',
          icon: Icons.auto_awesome_outlined,
          chip: 'Keepsake',
        ),
      ],
    ),
  ],
  closing: const SkDoorClosing(
    label: 'For the grown-up',
    blurb: 'What she has been working out and why it helps, how to raise a '
        'questioner without raising an arguer, the classes, and her '
        'settings.',
    surfaceId: 'sk_grown_up/skilling_critical_thinking',
  ),
);
