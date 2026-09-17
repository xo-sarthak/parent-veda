// =============================================================================
//  The Confidence door — standing up and being heard, and hearing yourself
// -----------------------------------------------------------------------------
//  Built to `ParentVeda_Confidence_structure.pdf` (11 Sep 2026), door three,
//  "the one that actually sells". The content is `kSkConfidenceContent`
//  (`lib/data/skilling/skilling_confidence_*`); the contract is
//  `test/sk_confidence_door_test.dart`.
//
//  ⚠️ SIX CARDS, BECAUSE THE BRIEF LISTS SIX CHILD SURFACES. The three band
//  sets, the lesson set, "Hear yourself back" (the recorder) and "Your
//  talks, saved" (the keepsake). The user's call (2026-09-16, question 3b):
//  PDF-literal, six cards, the last two opening the two halves of one
//  screen — `sk_record/<door>` lands on the recorder, `sk_voice/<door>` on
//  the clips. The coverflow allows six where a brief insists; this one does.
//
//  ⚠️ THE COACH IS ON THE PARENT SIDE, NOT A CONSULT CARD. The brief un-holds
//  Consult; the user's call (2a) puts the coach as a row under the classes
//  on the grown-up screen — the parent books — and keeps the one closing
//  card as the way there.
//
//  ⚠️ RECORDING, AS COMMUNICATION: optional, off until a parent turns it on,
//  on this phone, never analysed. Plus this door's own line: after listen-
//  back, "notice one thing you did" — a prompt, stored nowhere (4a).
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'sk_door_data.dart';

final SkDoor kSkConfidenceDoor = SkDoor(
  doorId: 'skilling_confidence',
  // Unsplash, free. A classroom on the floor, hands up to answer, one child
  // standing at the front — the first of the brief's "rooms an Indian child
  // actually faces" (answering in class), no stage. The first pick
  // (`photo-1577896851231`) had a chalkboard reading "if someone in your
  // family has cancer", seen only on the phone (2026-09-17): a hero
  // photograph is read at full size, and every word in it is the door's.
  heroImageUrl:
      'https://images.unsplash.com/photo-1588075592446-265fd1e6e76f?w=900&h=700&fit=crop',
  tabs: const [
    SkDoorTab(
      id: 'use_your_voice',
      label: 'Use your voice',
      icon: Icons.campaign_outlined,
      hue: 344,
      kind: SkTabKind.activities,
      bandId: '6-8',
      footer: 'Getting one line out in front of the group, saying your name '
          'and one thing, loud enough to be heard.',
    ),
    SkDoorTab(
      id: 'stand_up_and_say_it',
      label: 'Stand up and say it',
      icon: Icons.record_voice_over_outlined,
      hue: 26,
      kind: SkTabKind.activities,
      bandId: '8-11',
      footer: 'A short show-and-tell to the whole room, facing them, '
          'finishing the thing even when it wobbles.',
    ),
    SkDoorTab(
      id: 'give_a_real_talk',
      label: 'Give a real talk',
      icon: Icons.mic_external_on_outlined,
      hue: 288,
      kind: SkTabKind.activities,
      bandId: '11-14',
      footer: 'A proper short talk, steadying the nerves, recovering from a '
          'fumble, speaking to a small room and a big one.',
    ),
    SkDoorTab(
      id: 'lessons',
      label: 'Lessons',
      icon: Icons.menu_book_outlined,
      hue: 232,
      kind: SkTabKind.lessons,
    ),
    SkDoorTab(
      id: 'hear_yourself_back',
      label: 'Hear yourself back',
      icon: Icons.mic_none_rounded,
      hue: 128,
      kind: SkTabKind.keepsake,
      tools: [
        SkDoorTool(
          label: 'Hear yourself back',
          blurb: 'Record a turn, play it, notice one thing you did. Nobody '
              'marks it.',
          surfaceId: 'sk_record/skilling_confidence',
          icon: Icons.mic_rounded,
          chip: 'Tool',
        ),
      ],
    ),
    SkDoorTab(
      id: 'your_talks',
      label: 'Your talks, saved',
      icon: Icons.auto_awesome_outlined,
      hue: 186,
      kind: SkTabKind.keepsake,
      tools: [
        SkDoorTool(
          label: 'Your talks, saved',
          blurb: 'What you stood up and did. It stays on this phone.',
          surfaceId: 'sk_voice/skilling_confidence',
          icon: Icons.auto_awesome_outlined,
          chip: 'Keepsake',
        ),
      ],
    ),
  ],
  closing: const SkDoorClosing(
    label: 'For the grown-up',
    blurb: 'What she has been doing and why it helps, the classes and a '
        'speaking coach a parent can book, her settings, and one honest '
        'line if it is more than shyness.',
    surfaceId: 'sk_grown_up/skilling_confidence',
  ),
);
