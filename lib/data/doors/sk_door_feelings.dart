// =============================================================================
//  The Feelings door — name it, feel it, find your way through
// -----------------------------------------------------------------------------
//  Built to `ParentVeda_Feelings_structure.pdf`, door six built (the
//  brief's twelfth of twelve), "the mental-health door, and the one that
//  carries the most weight of all twelve". The content is
//  `kSkFeelingsContent` (`lib/data/skilling/skilling_feelings_*`); the
//  contract is `test/sk_feelings_door_test.dart`.
//
//  ⚠️ SIX CARDS, THE BRIEF'S CHILD SURFACES. Three band sets, the lesson
//  set (scenarios, journal prompts, and the calm window onto Stillness),
//  her journal, and the keepsake as "You practised". The off-ramp is not a
//  card: it is a bar at the foot of every one of these screens
//  (`SkTalkToSomeoneBar`), because the brief says "not buried, present on
//  every screen of this door".
//
//  ⚠️ A SKILL DOOR, NEVER THERAPY. No line here claims to treat, diagnose or
//  fix. Real distress goes to a trusted adult and a professional, and the
//  door's first job is to make that easy and un-shameful.
//
//  ⚠️ THE JOURNAL IS HERS (the user's call, 2026-09-18, 1a; legal review
//  owed). ⚠️ THE CRISIS PATHWAY IS A STUB, AND STOPS (`sk_crisis_pathway.
//  dart`). ⚠️ CONSULT IS HELD: "a paid counsellor booking is held. What
//  comes first, and free, is the safety off-ramp."
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'sk_door_data.dart';

final SkDoor kSkFeelingsDoor = SkDoor(
  doorId: 'skilling_emotional',
  // Unsplash, free. Two girls in a field at golden hour, the older one's
  // arm around the younger, reading together — closeness, not a face
  // chart; nothing in it to read. Flagged in the review file for a look.
  heroImageUrl:
      'https://images.unsplash.com/photo-1476234251651-f353703a034d?w=900&h=700&fit=crop',
  tabs: const [
    SkDoorTab(
      id: 'name_what_you_feel',
      label: 'Name what you feel',
      icon: Icons.sentiment_satisfied_outlined,
      hue: 288,
      kind: SkTabKind.activities,
      bandId: '6-8',
      footer: 'Naming feelings with faces and colours, learning it is okay '
          'to feel them, a first way to calm down, simple situations.',
    ),
    SkDoorTab(
      id: 'handle_the_big_feelings',
      label: 'Handle the big feelings',
      icon: Icons.waves_outlined,
      hue: 26,
      kind: SkTabKind.activities,
      bandId: '8-11',
      footer: 'Bigger feelings, empathy, bouncing back from losing or '
          'failing, real situations like a friendship fight or feeling '
          'left out.',
    ),
    SkDoorTab(
      id: 'find_your_way_through',
      label: 'Find your way through',
      icon: Icons.explore_outlined,
      hue: 186,
      kind: SkTabKind.activities,
      bandId: '11-14',
      footer: 'Worry and stress, friendship and belonging, recovering from '
          'real setbacks, and knowing when and how to ask for help.',
    ),
    SkDoorTab(
      id: 'lessons',
      label: 'Scenarios and prompts',
      icon: Icons.forum_outlined,
      hue: 232,
      kind: SkTabKind.lessons,
    ),
    SkDoorTab(
      id: 'your_journal',
      label: 'Your journal',
      icon: Icons.lock_outline_rounded,
      hue: 128,
      kind: SkTabKind.keepsake,
      tools: [
        SkDoorTool(
          label: 'Your journal',
          blurb: 'The harder feelings, written down. On this phone, '
              'locked, and nobody reads it but you.',
          surfaceId: 'sk_journal/skilling_emotional',
          icon: Icons.lock_outline_rounded,
          chip: 'Private',
        ),
      ],
    ),
    SkDoorTab(
      id: 'you_practised',
      label: 'You practised',
      icon: Icons.auto_awesome_outlined,
      hue: 42,
      kind: SkTabKind.keepsake,
      tools: [
        SkDoorTool(
          label: 'You practised',
          blurb: 'What you tried and came back to. '
              'Words, never a feelings score.',
          surfaceId: 'sk_keepsake/skilling_emotional',
          icon: Icons.auto_awesome_outlined,
          chip: 'Keepsake',
        ),
      ],
    ),
  ],
  closing: const SkDoorClosing(
    label: 'For the grown-up',
    blurb: 'How to help a child with big feelings and when to seek help, '
        'the short series, her settings, and her journal — which is hers.',
    surfaceId: 'sk_grown_up/skilling_emotional',
  ),
);
