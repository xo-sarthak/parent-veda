// =============================================================================
//  The Making door — art, music and making, and somewhere to keep it
// -----------------------------------------------------------------------------
//  Built to `ParentVeda_Creativity_structure.pdf`, door seven built, "the
//  one door whose plan already refuses scoring … the job is mostly to hold
//  that line against the temptation to turn making into a competition".
//  The content is `kSkMakingContent` (`lib/data/skilling/skilling_making_*`);
//  the contract is `test/sk_making_door_test.dart`. The bracket id is
//  `skilling_creativity`; the brief's name for the door is Making.
//
//  ⚠️ FIVE CARDS, THE BRIEF'S CHILD SURFACES. Three band sets, Prompts (art,
//  music, making) and Your portfolio — the gallery that keeps what she made
//  (photos, new; her recordings and her words, reused) with the showcase
//  inside it as a private show mode. The keepsake card IS the portfolio on
//  this door: "a portfolio, not a tracker".
//
//  ⚠️ NO LIKES, NO RANKING, NO FEATURED WALL, NO CROSS-USER GALLERY (the
//  user's call, 2026-09-18, 1a). ⚠️ THE LEAST COMMERCIAL DOOR, ON PURPOSE
//  (2a): a light class shelf, Consult held, the money left on the table.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'sk_door_data.dart';

final SkDoor kSkMakingDoor = SkDoor(
  doorId: 'skilling_creativity',
  // Unsplash, free. A child's hands painting stones on a wooden table,
  // markers and crayons everywhere, no face, nothing to read — "playing
  // with stuff", with what is to hand.
  heroImageUrl:
      'https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=900&h=700&fit=crop',
  tabs: const [
    SkDoorTab(
      id: 'just_make_it',
      label: 'Just make it',
      icon: Icons.brush_outlined,
      hue: 12,
      kind: SkTabKind.activities,
      bandId: '6-8',
      footer: 'First marks and first sounds. Scribble, colour past the '
          'lines, bang a rhythm, glue scraps into a thing. There is no '
          'wrong.',
    ),
    SkDoorTab(
      id: 'make_it_yours',
      label: 'Make it yours',
      icon: Icons.palette_outlined,
      hue: 42,
      kind: SkTabKind.activities,
      bandId: '8-11',
      footer: 'Your own version, not the example. Mixing art, music and '
          'making, and taking an idea a bit further.',
    ),
    SkDoorTab(
      id: 'make_something_real',
      label: 'Make something real',
      icon: Icons.construction_outlined,
      hue: 186,
      kind: SkTabKind.activities,
      bandId: '11-14',
      footer: 'A piece you meant: a drawing, a tune, a thing you built. '
          'Keep it, and share it if you want to.',
    ),
    SkDoorTab(
      id: 'prompts',
      label: 'Prompts',
      icon: Icons.lightbulb_outline_rounded,
      hue: 288,
      kind: SkTabKind.lessons,
    ),
    SkDoorTab(
      id: 'your_portfolio',
      label: 'Your portfolio',
      icon: Icons.photo_library_outlined,
      hue: 128,
      kind: SkTabKind.keepsake,
      tools: [
        SkDoorTool(
          label: 'Your portfolio',
          blurb: 'What you made, kept: photos of things, recordings of '
              'tunes, and what you tried. Show it to family if you want. '
              'Nobody marks it.',
          surfaceId: 'sk_portfolio/skilling_creativity',
          icon: Icons.photo_library_outlined,
          chip: 'Keepsake',
        ),
      ],
    ),
  ],
  closing: const SkDoorClosing(
    label: 'For the grown-up',
    blurb: 'Why this is a real skill in plain words, a few art or music '
        'classes if you want them, the things she might enjoy, and her '
        'settings, including whether she keeps photos of what she makes.',
    surfaceId: 'sk_grown_up/skilling_creativity',
  ),
);
