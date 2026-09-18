// =============================================================================
//  The Stillness door — a quiet minute, and no chain to keep
// -----------------------------------------------------------------------------
//  Built to `ParentVeda_Stillness_structure.pdf`, door five, "the door with
//  the most already built behind it, and a streak it should refuse for its
//  own reason". The content is `kSkStillnessContent`
//  (`lib/data/skilling/skilling_stillness_*`); the contract is
//  `test/sk_stillness_door_test.dart`.
//
//  ⚠️ FIVE CARDS, THE BRIEF'S CHILD SURFACES. Three band sets, Sessions
//  (the content set: guided sits, gentle moving, resting) and Quiet moments
//  taken — the shared no-score keepsake under this door's name, carrying
//  the one gentle line the brief asks for: "want to sit again?".
//
//  ⚠️ NO STREAK. The user's call (2026-09-17, 1a), on the record with its
//  reason: "a streak turns a non-striving practice into a target, and a
//  broken streak makes a child feel she has failed at calming down." No
//  count, no chain, no days-in-a-row, no broken-streak state, and the
//  invitation to return is one line with no number in it (3a: on the
//  keepsake, never a notification).
//
//  ⚠️ THIS DOOR IS THE CALM SOURCE. Focus, Feelings and Memory borrow their
//  breath and calming from here; `sl_settle` is the page they reference.
//
//  ⚠️ CONSULT IS HELD. "A kids' yoga or meditation teacher, rarely. Held.
//  Real distress is not a meditation gap." No row; the closing card is the
//  grown-up screen.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'sk_door_data.dart';

final SkDoor kSkStillnessDoor = SkDoor(
  doorId: 'skilling_stillness',
  // Unsplash, free. Four children in a misty grove, mid-leap after a ball
  // — movement first, then a moment of quiet, which is the youngest band
  // exactly. Nothing in it to read. Flagged in the review file for a
  // second look: the door is stillness and the photograph is play.
  heroImageUrl:
      'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=900&h=700&fit=crop',
  tabs: const [
    SkDoorTab(
      id: 'breathe_and_wiggle',
      label: 'Breathe and wiggle',
      icon: Icons.air_rounded,
      hue: 232,
      kind: SkTabKind.activities,
      bandId: '6-8',
      footer: 'Tiny playful breath games and animal poses, a minute or two. '
          'Movement first, then a moment of quiet.',
    ),
    SkDoorTab(
      id: 'sit_and_settle',
      label: 'Sit and settle',
      icon: Icons.self_improvement_outlined,
      hue: 186,
      kind: SkTabKind.activities,
      bandId: '8-11',
      footer: 'Short guided sits, noticing, simple yoga, and a real way to '
          'calm down when wound up.',
    ),
    SkDoorTab(
      id: 'find_your_calm',
      label: 'Find your calm',
      icon: Icons.nightlight_outlined,
      hue: 268,
      kind: SkTabKind.activities,
      bandId: '11-14',
      footer: 'Longer practices, yoga, and using stillness for stress, '
          'sleep and the harder days of the pre-teen years.',
    ),
    SkDoorTab(
      id: 'sessions',
      label: 'Sessions',
      icon: Icons.spa_outlined,
      hue: 128,
      kind: SkTabKind.lessons,
    ),
    SkDoorTab(
      id: 'quiet_moments',
      label: 'Quiet moments taken',
      icon: Icons.auto_awesome_outlined,
      hue: 42,
      kind: SkTabKind.keepsake,
      tools: [
        SkDoorTool(
          label: 'Quiet moments taken',
          blurb: 'The quiet minutes you took. No chain to keep, no day to '
              'miss. Want to sit again?',
          surfaceId: 'sk_keepsake/skilling_stillness',
          icon: Icons.auto_awesome_outlined,
          chip: 'Keepsake',
        ),
      ],
    ),
  ],
  closing: const SkDoorClosing(
    label: 'For the grown-up',
    blurb: 'What she has been practising and how stillness helps without '
        'over-selling it, the longer series, her settings, and where real '
        'distress goes instead.',
    surfaceId: 'sk_grown_up/skilling_stillness',
  ),
);
