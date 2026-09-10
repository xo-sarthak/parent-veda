// =============================================================================
//  Belly & skin — the door
// -----------------------------------------------------------------------------
//  Built from `ParentVeda_Belly_and_skin_rebuild.pdf`, 30 Aug 2026. Fourth of
//  the eight pregnancy briefs, and the one whose own summary is *"this area
//  needs almost no rebuild."*
//
//  ---------------------------------------------------------------------------
//  ⚠️ FOUR TABS, NOT FIVE, AND THE BRIEF ARGUES FOR IT RATHER THAN ASSUMING IT
//  ---------------------------------------------------------------------------
//
//  Its words: *"There is no paid consult here and only one real medical flag
//  (the itching-of-palms-and-soles warning), which is better kept prominent
//  inside the Itching read than pulled into a thin Talk tab."*
//
//  That is right, and it is the first brief to argue AGAINST the shape rather
//  than for it. A Talk tab holding one warning and no consult would be a tab
//  built to match the other doors, which is the content-management view of a
//  product — organised by how we happened to build the last one.
//
//  ⚠️ AND FOUR COST A CHANGE IN THE CAROUSEL. On a five-ring no card ever rests
//  at the seam; on a four-ring one always does, and the seam fade rendered it at
//  zero — three cards under four dots. See the note in `pv_door_carousel.dart`.
//  Five is still the better shape; four now works.
//
//  ---------------------------------------------------------------------------
//  ⚠️ ONE CONTENT CHANGE IN THE WHOLE AREA, AND IT IS TWO TITLES
//  ---------------------------------------------------------------------------
//
//  *"The linea nigra (the dark line)"* → *"The dark line (linea nigra)"* and
//  *"Melasma (the pregnancy mask)"* → *"The pregnancy mask (melasma)"*, in
//  `belly_skin_data.dart`. Plain phrase first, medical word in brackets — the
//  rule the Complications door states in full and this brief calls "locked".
//
//  Nothing else. Nineteen reads, the Ingredient Safety Checker, the itching
//  screen and the bump keepsake are carried whole.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE CARDS ARE BUILT FROM `kBsPages`, NOT LISTED
//  ---------------------------------------------------------------------------
//
//  The brief says so directly: *"the cards named are the visible ones, not the
//  full inventory"* and *"+ any other skin-changes reads already built, reuse in
//  place."* A hand-typed list would have shipped exactly the named cards and
//  quietly dropped anything added later — on a door that REPLACED the landing,
//  which is the only route those pages had.
//
//  So each rail reads its `BsArea` and renders whatever is in it. Add a
//  twentieth page tomorrow and it appears, with no edit here.
//
//  ---------------------------------------------------------------------------
//  ⚠️ BOUNDARIES THE BRIEF DRAWS, KEPT
//  ---------------------------------------------------------------------------
//
//  · **The Ingredient Safety Checker owns skincare and salon verdicts.** The
//    Can I? area's hair-dye and salon entries reference it and do not answer it.
//    No second checker is built here.
//  · **The bump ritual is not Garbh Sanskar's My Journal.** Photos here, voice
//    and letters there. Both stay; neither is merged.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../belly_skin_data.dart';
import 'pv_door_data.dart';

/// Surfaces this door opens. Constants because each becomes a route NAME.
const String kBsSurfaceChecker = 'belly_skin/checker';
const String kBsSurfaceItching = 'belly_skin/itching';
const String kBsSurfaceRitual = 'bump_journey';

const String kBsTabSkin = 'skin';
const String kBsTabSafe = 'safe';
const String kBsTabBelly = 'belly';
const String kBsTabRitual = 'ritual';

/// Every read in one area, as tiles, in the order the library holds them.
///
/// ⚠️ READ FROM `kBsPages`, WHICH IS THE WHOLE POINT — see the header.
///
/// ⚠️ AND THE BLURB IS `videoSubtitle`, WHICH IS NOT THE ODD CHOICE IT LOOKS.
/// `BsPage` has no blurb field; what it has is a one-line subtitle for the film
/// at the top of each page — "Where the evidence is real, and where it is a
/// guess", "A realistic timeline for fading". Those are the brief's own card
/// lines, verbatim, on seventeen of nineteen pages: its map was plainly written
/// FROM this field.
///
/// So the card line is the page's own line, no new copy is written anywhere on
/// this door, and the two cannot drift.
///
/// ⚠️ ALL NINETEEN HAVE ONE. An earlier pass here reported two pages missing a
/// subtitle and "supplied" them from the brief — both were already present, and
/// the words added were byte-identical to the words already there. The grep
/// that found the gap assumed a field order the file does not always keep.
/// Worth remembering as a shape: a survey that reads source with a regex will
/// find gaps the source does not have, and the fix looks like content work.
List<PvDoorTile> _readsIn(BsArea area) => [
      for (final p in kBsPages)
        if (p.area == area)
          PvDoorEntryTile(
            title: p.title.en,
            // The `??` is defence, not a live branch — every page has a
            // subtitle today, and a page added without one gets its film's
            // title rather than a blank card.
            blurb: p.videoSubtitle?.en ?? p.videoTitle.en,
            library: PvDoorLibrary.bellySkin,
            entryId: p.id,
          ),
    ];

final PvDoorPage kBellySkinDoor = PvDoorPage(
  bracketId: 'pregnancy_belly_skin',

  // ⚠️ THE AREA'S OWN LINE, KEPT. "Your changing skin and bump, cared for
  // simply" is what the landing said and it is the right sentence; only the
  // menu under it has gone.
  heroTitle: 'Your changing skin and bump.',
  heroBlurb: 'What is happening, what actually helps, and what is safe to put '
      'on your skin — cared for simply.',

  // ⚠️ THE ONE DOOR WHOSE SUBJECT IS A BODY, SO THE PHOTOGRAPH IS ONE. An
  // Indian woman in late pregnancy, a hand on her bump, outdoors in warm
  // light — the same body the nineteen reads under it are about.
  //
  // ⚠️ AND IT IS NOT A SKIN CLOSE-UP, WHICH WAS THE OBVIOUS CHOICE AND THE
  // WRONG ONE. A macro of a stretch mark over "Your changing skin and bump"
  // makes the door about a defect. The woman is the subject; the marks are
  // what the reads discuss.
  heroImageUrl:
      'https://images.unsplash.com/photo-1709823150938-7897d31da66c?w=900&h=700&fit=crop',

  // ⚠️ THE FOOTER STAYS IN THE VOICE THE AREA ALREADY USES. The brief:
  // *"Every line spoken to her, warmly, never a legal notice."* This is the
  // reads' own closing note, not a disclaimer bolted on.
  closingLine: 'Skin in pregnancy changes in ways nobody warns you about, and '
      'almost all of it settles. Anything that worries you is worth showing '
      'your doctor.',

  groups: [
    PvDoorGroup(
      id: kBsTabSkin,
      label: 'Skin changes',
      icon: Icons.face_retouching_natural_outlined,
      hue: 344,
    ),

    PvDoorGroup(
      id: kBsTabSafe,
      label: "What's safe to use",
      icon: Icons.verified_outlined,
      hue: 206,
    ),

    PvDoorGroup(
      id: kBsTabBelly,
      label: 'Belly care',
      icon: Icons.spa_outlined,
      hue: 42,
    ),

    // -------------------------------------------------------------------------
    //  4. The bump ritual — the keepsake, inline
    // -------------------------------------------------------------------------
    //  ⚠️ THE TIMELINE IS THE TAB. The brief calls the keepsake a do-it screen
    //  rather than a rail, and a card in front of it would be a door in front
    //  of a door — the same rule the timeline and the locker follow on Scans.
    PvDoorGroup(
      id: kBsTabRitual,
      label: 'The bump ritual',
      icon: Icons.photo_camera_outlined,
      hue: 26,
      inlineSurfaceId: kBsSurfaceRitual,
      inlineLabel: 'Your bump, over time',
      layout: PvDoorLayout.stack,
    ),
  ],

  sections: [
    // =========================================================================
    //  SUB-TAB 1 · Skin changes
    // =========================================================================
    PvDoorSection(
      group: kBsTabSkin,
      heading: 'Stretch marks',
      tiles: _readsIn(BsArea.stretchMarks),
    ),

    PvDoorSection(
      group: kBsTabSkin,
      heading: 'Pigmentation and skin changes',
      tiles: _readsIn(BsArea.pigmentation),
    ),

    // -------------------------------------------------------------------------
    //  Itching
    // -------------------------------------------------------------------------
    //  ⚠️ ITS OWN SCREEN, NOT A `BsPage`, AND THAT IS WHY IT CARRIES THE ONLY
    //  RED FLAG IN THE AREA. `BsItchingScreen` is built around a warning card:
    //  intense itching of the palms and soles with no rash means call your
    //  doctor today. The brief keeps that warning INSIDE the read rather than
    //  pulling it onto a Talk tab, and this door does not touch it.
    //
    //  ⚠️ SO THERE IS NO PINNED FLAG ON THIS DOOR, AND THE ABSENCE IS A
    //  DECISION. The other two doors that pin one do it because the warning
    //  applies to a whole area. This one applies to a single symptom, and a
    //  woman reading about stretch marks does not need it above her rail.
    PvDoorSection(
      group: kBsTabSkin,
      heading: 'Itching',
      tiles: [
        PvDoorToolTile(
          title: 'Itchy skin in pregnancy, explained',
          blurb: 'What is ordinary, what soothes it, and the one kind that '
              'means calling your doctor today.',
          surfaceId: kBsSurfaceItching,
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 2 · What's safe to use
    // =========================================================================
    PvDoorSection(
      group: kBsTabSafe,
      heading: 'Check any product',
      tiles: [
        PvDoorToolTile(
          title: 'Ingredient Safety Checker',
          blurb: 'Free. Search a product or an ingredient for a clear Safe, '
              'Limit or Avoid answer.',
          surfaceId: kBsSurfaceChecker,
        ),
      ],
    ),

    PvDoorSection(
      group: kBsTabSafe,
      heading: 'Safe skincare',
      tiles: _readsIn(BsArea.safeSkincare),
    ),

    // =========================================================================
    //  SUB-TAB 3 · Belly care
    // =========================================================================
    PvDoorSection(
      group: kBsTabBelly,
      heading: 'Oiling, support and comfort',
      tiles: _readsIn(BsArea.bellyCare),
    ),

    // =========================================================================
    //  SUB-TAB 4 · The bump ritual
    // -------------------------------------------------------------------------
    //  No cards. The keepsake IS the tab.
    // =========================================================================
  ],
);
