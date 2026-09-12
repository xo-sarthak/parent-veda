// =============================================================================
//  Garbh Sanskar — the door
// -----------------------------------------------------------------------------
//  Built from `ParentVeda_Garbh_Sanskar_rebuild.pdf`, 12 Sep 2026. Seventh of
//  the eight pregnancy briefs — and the eighth, `..._pillars_build.pdf`, is
//  its pair: this one puts a door on the area, that one builds the four
//  pillars behind it to final. The user's call was door first, then pillars
//  one at a time, and this file is written so the second job touches nothing
//  in it: every card here opens a SURFACE ID, and a pillar rebuilt behind the
//  same id is a pillar rebuilt behind the same card.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE TWO BRIEFS DISAGREE ABOUT THE PREMISE, AND THE CODE SETTLED IT
//  ---------------------------------------------------------------------------
//
//  This brief: *"REUSE, DO NOT REBUILD: this area is already fully built."*
//  The pillars brief: *"Shravan, Samvad, Buddhi and Kriya are placeholders
//  today."* Walking the code, the second is right and the first is not:
//
//    · Shravan has ten tracks in data and ONE bundled file — every card plays
//      the same tanpura drone (`raga_drone.wav`). The player, the daily pick,
//      the why-line and skip-today are real.
//    · Samvad's recording is real and writes to My Journal; the narrator is a
//      "coming soon" line on the record screen.
//    · Buddhi's four games exist; Sudoku is a 4×4 with three fixed boards.
//    · Kriya's breathing circle is real; "Guided Relaxation" is a breathing
//      pattern named relax, not a body scan.
//
//  So the door reuses everything AS IT IS, and the cards do not pretend: a
//  track card opens the player (which plays the drone), a game card opens the
//  game. Nothing on the door is coming-soon, because every screen exists — the
//  placeholders are INSIDE working screens, which is the pillars brief's job
//  and is listed in `docs/DOOR-CONTENT-OWED.md` §7 as such.
//
//  ---------------------------------------------------------------------------
//  ⚠️ TODAY IS A LAUNCHER, AND THE ENGINE GREW ONE THING FOR IT
//  ---------------------------------------------------------------------------
//
//  *"Today only opens the tabs below, it does not repeat their libraries."*
//  The four pillar cards carry `pvDoorTabSurface(...)` ids, and the door
//  screen switches tab instead of pushing — see `kPvDoorTabSurface`. Each
//  destination tab opens with "Today's pick" as its first rail, which is what
//  "opens Listen at today's pick" means without a second copy of Listen.
//
//  And "whatever is picked shows on Today" needed a rail that reads a store:
//  `PvDoorSection.inline` — a section whose rail a widget draws, in position.
//  The "Your own practice" rail is that widget: the picker card first, then
//  one card per ritual she has chosen.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE ONE NEW ITEM IS THE CLOSING LINE, AND WHY IT IS AT AREA LEVEL
//  ---------------------------------------------------------------------------
//
//  The brief's sub-tab map puts "Where this comes from" [Note] NEW on My
//  Journal. Its own correctness box says *"One new note added at AREA LEVEL
//  to make the honesty explicit."* The door's closing line is the area-level
//  note this engine has — it renders under every tab — so that is where it
//  went. It is the only copy in this file that was written rather than
//  carried, and it says exactly what the brief's box says it must: the voice
//  part has real evidence, the rest is a calming ritual, and nothing here
//  promises anything about the child's intelligence or nature.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE STOP IF BLOCK IS THE PINNED FLAG, IN HER VOICE
//  ---------------------------------------------------------------------------
//
//  *"Rewrite the Kriya 'STOP IF' block to open with 'Stop and call your doctor
//  today if...'"* — done as the flag's title. The six lines are
//  `_StopIfCard._signs` from the Kriya screen, unchanged; the safety note
//  ("Support your bump, go slow, rest when you need") is the flag's footer,
//  because on this tab it is the sentence that follows the list. The flag
//  opens the Kriya screen, where the same block sits above the practices.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT WAS NOT DONE, AND WHY
//  ---------------------------------------------------------------------------
//
//  · No Ask Veda card — the FAB, on every screen, with this door's context.
//  · No streak, no score, no counter as a card. The old landing's "Nothing
//    here keeps score" stays true: the door shows no completion state at all.
//  · Vichara's stories are not on the door. The brief does not name them and
//    the old landing had already dropped that pillar (four rows, not five);
//    `VicharaScreen` stays in the library for revert.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../../models/garbh_content.dart' show GarbhKind;
import '../garbh_data.dart';
import '../garbh_rebuild_data.dart';
import 'pv_door_data.dart';

// Tab ids. The Today cards switch to these; see `pvDoorTabSurface`.
const String kGarbhTabToday = 'today';
const String kGarbhTabListen = 'listen';
const String kGarbhTabRead = 'read';
const String kGarbhTabForYou = 'for_you';
const String kGarbhTabJournal = 'journal';

// Surfaces. Constants because each becomes a route NAME.
const String kGarbhSurfaceRitual = 'garbh/ritual';
const String kGarbhSurfaceRitualRail = 'garbh/ritual_rail';
const String kGarbhSurfaceListenToday = 'garbh/listen/today';
const String kGarbhSurfaceReadToday = 'garbh/read/today';
const String kGarbhSurfaceRelax = 'garbh/relax';
const String kGarbhSurfaceKriya = 'garbh/kriya';
const String kGarbhSurfaceJournal = 'garbh/journal';

/// `garbh/listen/<audio id>` — one track on its player.
String garbhSurfaceListen(String audioId) => 'garbh/listen/$audioId';

/// `garbh/read/piece/<slug>` — one affirmation on the record-first screen.
String garbhSurfacePiece(String slug) => 'garbh/read/piece/$slug';

/// `garbh/read/shelf/<n>` — the library open on one of its four shelves.
String garbhSurfaceShelf(int shelf) => 'garbh/read/shelf/$shelf';

/// `garbh/play/<slug>` — one of Buddhi's four games.
String garbhSurfaceGame(String slug) => 'garbh/play/$slug';

/// The slug a read-aloud piece or a puzzle is addressed by: its English
/// title, lowercased, spaces to underscores. `.en` because this is an
/// IDENTITY — a route name and a lookup key — never the words on screen.
String garbhSlug(String englishTitle) =>
    englishTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

/// The brief's six affirmations, in its order. Each exists in
/// `kReadAloudPieces` under `kRtbAffirmations`; the door's test proves it.
const List<String> kGarbhDoorAffirmations = [
  'You are loved',
  'Grow gently',
  'You are safe',
  'A wish for joy',
  'Brave and kind',
  'Our little blessing',
];

/// The tracks of one kind, in library order, each opening its player.
List<PvDoorTile> _tracks(GarbhKind kind) => [
      for (final a in kShravan)
        if (a.kind == kind)
          PvDoorAudioTile(
            title: a.title.en,
            blurb: a.subtitle.en,
            meta: '${a.minutes} MIN',
            surfaceId: garbhSurfaceListen(a.id),
          ),
    ];

final PvDoorPage kGarbhDoor = PvDoorPage(
  bracketId: 'pregnancy_garbh',

  heroTitle: 'A few minutes a day, for both of you.',
  heroBlurb: 'Something to listen to, something to say aloud, a few quiet '
      'minutes for you, and a keepsake that grows.',

  // ⚠️ LOOKED AT BEFORE IT WAS WIRED — see `pv_door_scans.dart` for the rule.
  // Her two hands around a late bump, warm light, the face soft and out of
  // focus. Nothing to read as a mood, nothing clinical, nothing that belongs
  // to a country — and it is the one gesture every practice on this door
  // comes back to. A candidate of a woman in lotus on a lawn was rejected:
  // not visibly pregnant, and the pose sells yoga, which is another area.
  heroImageUrl:
      'https://images.unsplash.com/photo-1710897872621-bcf232f9b368?w=900&h=700&fit=crop',

  // ⚠️ THE ONE NEW ITEM IN THE AREA. See the header for why it is here and
  // not on the last tab only.
  closingLine: 'Where this comes from: the one part with real evidence is '
      'your voice. By the third trimester your baby can hear it and learn it, '
      'and newborns know the voice they heard most. The rest is a calming '
      'ritual for you, and it promises nothing about how clever or what kind '
      'of person your child will be.',

  groups: [
    // -------------------------------------------------------------------------
    //  1. Today — the launcher. Default.
    // -------------------------------------------------------------------------
    //  ⚠️ THE NOTE IS "WHY THIS WEEK", AND IT IS A FUNCTION OF HER WEEK — the
    //  voice-rhythm line the brief names, from `kGarbhWeekReasons`, banded by
    //  what is forming. See `PvDoorGroup.noteFor`.
    PvDoorGroup(
      id: kGarbhTabToday,
      label: 'Today',
      icon: Icons.wb_sunny_outlined,
      hue: 42,
      noteFor: (week) => garbhWeekReason(week).en,
    ),

    // -------------------------------------------------------------------------
    //  2. Listen — Shravan
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kGarbhTabListen,
      label: 'Listen',
      icon: Icons.headphones_outlined,
      hue: 42,
      // Spoken TO her — "your calm", not "her calm". Read back on the phone.
      note: 'Shravan, listening. Your calm, and a moment you share — nothing '
          'here claims to be good for the baby, and nothing says it is.',
    ),

    // -------------------------------------------------------------------------
    //  3. Talk & read — Samvad
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kGarbhTabRead,
      label: 'Talk and read',
      icon: Icons.record_voice_over_outlined,
      hue: 14,
      note: 'Samvad, talking to your baby. Everything you read or record here '
          'lands in My Journal.',
    ),

    // -------------------------------------------------------------------------
    //  4. For you — Buddhi + Kriya
    // -------------------------------------------------------------------------
    //  ⚠️ THE HONESTY LINE IS THE TAB'S NOTE. "Do not soften or remove this
    //  line." It is the first thing under the flag, on every visit.
    PvDoorGroup(
      id: kGarbhTabForYou,
      label: 'For you',
      icon: Icons.self_improvement_rounded,
      hue: 262,
      note: 'This one is for you, and it will not make your baby cleverer.',
      pinnedRedFlag: PvDoorRedFlag(
        title: 'Stop and call your doctor today if...',
        lines: [
          PvDoorFlagLine('Bleeding, or fluid leaking'),
          PvDoorFlagLine('Pain in your belly, chest or back that is new'),
          PvDoorFlagLine('A tight, painful belly that will not settle'),
          PvDoorFlagLine('Dizziness, a bad headache, or blurred vision'),
          PvDoorFlagLine(
              'Trouble breathing, or a racing heart that does not slow'),
          PvDoorFlagLine('Your baby moving noticeably less than usual'),
        ],
        footer: 'Support your bump, go slow, and rest whenever you need to.',
        surfaceId: kGarbhSurfaceKriya,
      ),
    ),

    // -------------------------------------------------------------------------
    //  5. My Journal — the keepsake. The tab IS the journal.
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kGarbhTabJournal,
      label: 'My Journal',
      icon: Icons.auto_stories_outlined,
      hue: 330,
      inlineSurfaceId: kGarbhSurfaceJournal,
      inlineLabel: 'Everything your baby has heard',
      layout: PvDoorLayout.stack,
      note: 'This stays yours. It does not disappear after the birth: these '
          'are the voices your newborn will already know, and you can play '
          'the whole thing back whenever you want.',
    ),
  ],

  sections: [
    // =========================================================================
    //  TODAY
    // =========================================================================
    PvDoorSection(
      group: kGarbhTabToday,
      heading: "Today's practice",
      tiles: [
        // ⚠️ THE CHIP IS THE DESTINATION'S. Each card switches to a tab whose
        // first rail is today's pick, so "Audio" over Shravan is what the
        // next tap plays. The pillar names stay, with the subtitles the build
        // already had.
        PvDoorAudioTile(
          title: "Shravan, today's raga",
          blurb: 'Listening. One raga chosen for today, and why.',
          surfaceId: pvDoorTabSurface(kGarbhTabListen),
        ),
        PvDoorReadTile(
          title: "Samvad, today's reading",
          blurb: 'Talking to your baby. A passage to read aloud, in your '
              'voice.',
          surfaceId: pvDoorTabSurface(kGarbhTabRead),
        ),
        PvDoorGameTile(
          title: "Buddhi, today's quiet minutes",
          blurb: 'Just for you. A few minutes your head gets to keep.',
          surfaceId: pvDoorTabSurface(kGarbhTabForYou),
        ),
        PvDoorToolTile(
          title: "Kriya, today's relaxation",
          blurb: 'Breath and grounding. Slow, and safe to stop.',
          surfaceId: pvDoorTabSurface(kGarbhTabForYou),
        ),
      ],
    ),

    // ⚠️ DRAWN BY `GarbhRitualRail`, which reads the store. The picker card,
    // then whatever she picked. See `PvDoorSection.inline`.
    PvDoorSection.inline(
      group: kGarbhTabToday,
      heading: 'Your own practice',
      inlineSurfaceId: kGarbhSurfaceRitualRail,
    ),

    PvDoorSection(
      group: kGarbhTabToday,
      heading: 'What you are making',
      tiles: [
        PvDoorToolTile(
          title: 'My Journal',
          blurb: 'Every voice your baby has heard, kept by the week.',
          surfaceId: pvDoorTabSurface(kGarbhTabJournal),
        ),
      ],
    ),

    // =========================================================================
    //  LISTEN
    // =========================================================================
    PvDoorSection(
      group: kGarbhTabListen,
      heading: "Today's pick",
      tiles: [
        PvDoorAudioTile(
          title: "Today's raga",
          blurb: 'One chosen for today, with why. Skip it if it is not the '
              'one.',
          surfaceId: kGarbhSurfaceListenToday,
        ),
      ],
    ),

    PvDoorSection(
      group: kGarbhTabListen,
      heading: 'Ragas',
      tiles: _tracks(GarbhKind.raga),
    ),

    PvDoorSection(
      group: kGarbhTabListen,
      heading: 'Nature sounds',
      tiles: _tracks(GarbhKind.nature),
    ),

    PvDoorSection(
      group: kGarbhTabListen,
      heading: 'Guided',
      tiles: _tracks(GarbhKind.guided),
    ),

    // =========================================================================
    //  TALK AND READ
    // =========================================================================
    PvDoorSection(
      group: kGarbhTabRead,
      heading: "Today's pick",
      tiles: [
        PvDoorReadTile(
          title: "Today's passage to read aloud",
          blurb: 'Record it in your voice, or hear the narrator.',
          surfaceId: kGarbhSurfaceReadToday,
        ),
      ],
    ),

    PvDoorSection(
      group: kGarbhTabRead,
      heading: 'Affirmations and blessings',
      tiles: [
        // ⚠️ EACH OPENS THE RECORD-FIRST SCREEN ON THAT PIECE, not the
        // library's inline card. Her voice is the point; see
        // `GarbhSamvadDailyScreen.piece`.
        for (final title in kGarbhDoorAffirmations)
          PvDoorReadTile(
            title: title,
            blurb: 'Spoken to your baby. Read it aloud, or record it.',
            surfaceId: garbhSurfacePiece(garbhSlug(title)),
          ),
      ],
    ),

    PvDoorSection(
      group: kGarbhTabRead,
      heading: 'More to read aloud',
      tiles: [
        PvDoorReadTile(
          title: 'Stories and fables',
          blurb: 'Short, gentle, a few minutes each.',
          surfaceId: garbhSurfaceShelf(1),
        ),
        PvDoorReadTile(
          title: 'Mantras and lullabies',
          blurb: 'With the words, and what they mean.',
          surfaceId: garbhSurfaceShelf(2),
        ),
        PvDoorReadTile(
          title: 'Spiritual reading',
          blurb: 'Short passages, by tradition. You choose.',
          surfaceId: garbhSurfaceShelf(3),
        ),
      ],
    ),

    // =========================================================================
    //  FOR YOU
    // =========================================================================
    PvDoorSection(
      group: kGarbhTabForYou,
      heading: 'A few quiet minutes',
      tiles: [
        for (final puzzle in kPuzzles)
          PvDoorGameTile(
            title: puzzle.title.en,
            blurb: puzzle.blurb.en,
            surfaceId: garbhSurfaceGame(garbhSlug(puzzle.title.en)),
          ),
      ],
    ),

    PvDoorSection(
      group: kGarbhTabForYou,
      heading: 'Breath and relaxation',
      tiles: [
        PvDoorToolTile(
          title: 'Guided Relaxation',
          blurb: 'A voice walks you down your body, head to toe, with a raga '
              'underneath if you like.',
          meta: '8 MIN',
          surfaceId: kGarbhSurfaceRelax,
        ),
        // ⚠️ THE SINGLE SOURCE for guided relaxation in the app. "Mind & mood
        // links to it later, it is not rebuilt there."
        PvDoorToolTile(
          title: 'See all guided relaxations',
          blurb: 'Every breath and grounding practice, by trimester.',
          surfaceId: kGarbhSurfaceKriya,
        ),
      ],
    ),

    // =========================================================================
    //  MY JOURNAL — no sections; the tab IS the journal.
    // =========================================================================
  ],
);
