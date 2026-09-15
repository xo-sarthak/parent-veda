// =============================================================================
//  The Communication door — saying what you mean, so it lands
// -----------------------------------------------------------------------------
//  Built to `ParentVeda_Communication_structure.pdf` (11 Sep 2026), door two
//  of twelve, the first on the shell Coding laid. The content is
//  `kSkCommunicationContent` (`lib/data/skilling/skilling_communication_*`);
//  the contract is `test/sk_communication_door_test.dart`.
//
//  ⚠️ THE FIVE TABS ARE THE BRIEF'S SURFACE TABLE, LITERALLY. It lists the
//  three band sets as three surfaces — "Say it out loud (6 to 8)", "Tell it
//  and explain it (8 to 11)", "Say what you think (11 to 14)" — then the
//  lesson set, then "Your voice, saved". No Today. So each band set is a
//  card, pinned to its band (`SkDoorTab.bandId`): a six-year-old sees the
//  first open and the next two locked "From 8 years" / "From 11 years"; a
//  twelve-year-old sees three cards, the two she has grown past gone. The
//  user's call, 2026-09-15 (question 2, A).
//
//  ⚠️ THE KEEPSAKE RECORDS HER VOICE. "Your voice, saved: she records a
//  story or a prompt, it keeps what she tried" — `sk_voice/<door>`, on this
//  phone only. See `sk_voice_keepsake.dart` for why it is the pregnancy
//  recorder's mechanism without its upload.
//
//  ⚠️ NO CONSULT CLOSING. Held by the brief ("a communication expert,
//  rarely … speech delay and stammering are not a skill gap and not a
//  course"); the boundary note on the grown-up screen is where that line
//  will stand. The closing card is the way to the grown-up side.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'sk_door_data.dart';

final SkDoor kSkCommunicationDoor = SkDoor(
  doorId: 'skilling_communication',
  // Unsplash, free. A boy on a bench, mid-laugh, an open book in his lap:
  // one child, telling it out loud, no screen. Swap if a better free one
  // turns up (the review file lists it).
  heroImageUrl:
      'https://images.unsplash.com/photo-1472162072942-cd5147eb3902?w=900&h=700&fit=crop',
  tabs: const [
    SkDoorTab(
      id: 'say_it_out_loud',
      label: 'Say it out loud',
      icon: Icons.record_voice_over_outlined,
      hue: 26,
      kind: SkTabKind.activities,
      bandId: '6-8',
      footer: 'Getting a clear thought out, naming things properly, telling '
          'a first small story.',
    ),
    SkDoorTab(
      id: 'tell_and_explain',
      label: 'Tell it and explain it',
      icon: Icons.auto_stories_outlined,
      hue: 42,
      kind: SkTabKind.activities,
      bandId: '8-11',
      footer: 'A proper story with an order, describing so someone sees it, '
          'explaining how a thing works, asking a good question.',
    ),
    SkDoorTab(
      id: 'say_what_you_think',
      label: 'Say what you think',
      icon: Icons.forum_outlined,
      hue: 344,
      kind: SkTabKind.activities,
      bandId: '11-14',
      footer: 'Putting your point with a reason, speaking differently to '
          'different people, holding a real back-and-forth.',
    ),
    SkDoorTab(
      id: 'lessons',
      label: 'Lessons',
      icon: Icons.menu_book_outlined,
      hue: 232,
      kind: SkTabKind.lessons,
    ),
    SkDoorTab(
      id: 'your_voice',
      label: 'Your voice, saved',
      icon: Icons.mic_none_rounded,
      hue: 128,
      kind: SkTabKind.keepsake,
      tools: [
        SkDoorTool(
          label: 'Your voice, saved',
          blurb: 'The stories and things you said out loud, and what you '
              'tried. It stays on this phone.',
          surfaceId: 'sk_voice/skilling_communication',
          icon: Icons.mic_none_rounded,
          chip: 'Keepsake',
        ),
      ],
    ),
  ],
  closing: const SkDoorClosing(
    label: 'For the grown-up',
    blurb: 'What she has been doing and why it helps, the classes and the '
        'story decks a parent can buy, her settings, and one honest line if '
        'speech itself is the worry.',
    surfaceId: 'sk_grown_up/skilling_communication',
  ),
);
