// =============================================================================
//  Getting ready for baby — the door
// -----------------------------------------------------------------------------
//  Built 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "New section: Getting ready for baby", P2: *"We have
//  products but no guidance, and no names in pregnancy."* And from Experts /
//  Learn / Products, P2: an Indian "what you need, what you can skip" list
//  for the first three months, linked to our store, placed here.
//
//  Same shape as the other pregnancy doors (`pv_door_scans.dart` is the
//  benchmark): a hero, tabs, rails of guide and tool cards, a closing line.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THREE TABS, AS THE GAP ANALYSIS NAMES THEM
//  ---------------------------------------------------------------------------
//
//    1. Baby names      choosing together, naming customs
//    2. What to buy     need, skip or borrow, buying safely, the store
//    3. Home and help   the home, nesting, the last months, the first 40
//                       days, an older child, godh bharai
//
//  ⚠️ NO PINNED RED FLAG. Nothing on this door is an urgent subject; every
//  read still ends on an urgent doctor line (`assertShape` demands it).
//
//  ⚠️ THE TOOLS ARE SURFACE IDS, NOT SCREENS. Each becomes a route name, and
//  `global_ask_fab.dart` reads route names. The lead maps them in the door
//  router:
//
//    kReadySurfaceStore  the store, opened on the newborn "need" list
//    kReadySurfaceBag    Ready for Birth, the shipped hospital bag tool
//                        (the Labour door opens the same screen as
//                        `hospital_bag`; this door does not rebuild it)
//
//  ⚠️ THE NAMES TOOL IS NOT HERE YET. The parenting stage ships a couple's
//  name finder (`BabyNamingHomeScreen`); bringing it into pregnancy is the
//  lead's call, so the names read says a tool "is coming" and no tile
//  promises it.
//
//  Hues are the app's own: 36 is this bracket's hue, 344 and 104 are
//  `V2BlockHues` values already used across the stage.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import '../reads/read_images.dart' show readImageFor;
import 'pv_door_data.dart';

/// Surfaces this door opens. Resolved by `pv_door_router.dart`.
///
/// ⚠️ CONSTANTS, NOT LITERALS, BECAUSE THESE ARE IDENTITIES — see
/// `pv_door_scans.dart`. Each becomes a route name.
///
/// "Shop the list": the store, on the newborn things the "What you need"
/// read lists. Owed by the lead.
/// The baby name finder (parenting's `BabyNamingHomeScreen`), 2026-09-29.
const String kReadySurfaceNames = 'ready/names';

const String kReadySurfaceStore = 'ready/store';

/// Ready for Birth, the hospital bag tool that already ships. Owed by the
/// lead: the same screen `kLabourSurfaceBag` opens.
const String kReadySurfaceBag = 'ready/bag';

/// Tab ids. Constants for the reason `pv_door_scans.dart` gives: a typo in a
/// section's group renders it in no tab at all.
const String kReadyTabNames = 'names';
const String kReadyTabBuy = 'buy';
const String kReadyTabHome = 'home';

/// The hospital bag card's words, shared by the two tabs it sits on.
const String _bagTitle = 'Ready for Birth: your hospital bag';
const String _bagBlurb = 'What to pack for you, the baby and whoever comes '
    'with you.';

final PvDoorPage kGettingReadyDoor = PvDoorPage(
  bracketId: 'pregnancy_getting_ready',

  heroTitle: 'Getting ready for your baby.',
  heroBlurb: 'Choosing a name, what to buy and what to skip, and getting '
      'your home and your help ready.',

  // ⚠️ NOT LOOKED AT BY THE AUTHOR OF THIS FILE, AND SAID SO. The rule in
  // `pv_door_scans.dart` is "look at it first", and the image hosts were
  // unreachable from the session that built this door. This is the
  // photograph the weekly "hospital bag" read already ships (CC0, StockSnap,
  // Matt Bango), chosen by eye for that page, so it has been seen, but not
  // in a hero crop. No other door wears it. Look at it on a phone before
  // release; swap the id here if the crop shows anything the rule forbids.
  heroImageUrl: readImageFor('preg_week_read_hospital_bag'),

  closingLine: 'Take what fits your family and leave the rest. ParentVeda '
      'explains and reminds. Your doctor decides.',

  groups: [
    PvDoorGroup(
      id: kReadyTabNames,
      label: 'Baby names',
      mark: IntentMark.lampMark,
      icon: Icons.edit_note_rounded,
      hue: 36,
    ),
    PvDoorGroup(
      id: kReadyTabBuy,
      label: 'What to buy',
      mark: IntentMark.listMark,
      icon: Icons.shopping_bag_outlined,
      hue: 344,
    ),
    PvDoorGroup(
      id: kReadyTabHome,
      label: 'Home and help',
      mark: IntentMark.cuppedHands,
      icon: Icons.home_outlined,
      hue: 104,
    ),
  ],

  sections: [
    // =========================================================================
    //  TAB 1 · Baby names
    // =========================================================================
    PvDoorSection(
      group: kReadyTabNames,
      heading: 'Choosing a name',
      tiles: [
        PvDoorGuideTile(
          title: 'Choosing a name together',
          blurb: 'Where to start, who gets a say, and making a shortlist.',
          readId: 'preg_ready_read_choosing_name',
        ),
        PvDoorGuideTile(
          title: 'Names that work in two languages',
          blurb: 'Meaning, spelling, initials and a pet name for home.',
          readId: 'preg_ready_read_choosing_name',
          atHeading: 'Will the name work in two languages?',
        ),
        PvDoorGuideTile(
          title: 'A few names, by meaning',
          blurb: 'Light, peace, a star: some ideas to start you off.',
          readId: 'preg_ready_read_choosing_name',
          atHeading: 'A few names, by meaning',
        ),
      ],
    ),
    // The name finder the parenting stage already ships (couple swipe,
    // shared matches, shortlist), opened from here rather than copied: the
    // gap analysis asks for it in pregnancy, where the name is chosen.
    PvDoorSection(
      group: kReadyTabNames,
      heading: 'Find names together',
      tiles: [
        PvDoorToolTile(
          title: 'The name finder',
          blurb: 'Swipe through names, each of you, and see the ones you '
              'both like.',
          surfaceId: kReadySurfaceNames,
        ),
      ],
    ),
    PvDoorSection(
      group: kReadyTabNames,
      heading: 'Family customs',
      tiles: [
        PvDoorGuideTile(
          title: 'Naamkaran and other naming days',
          blurb: 'How families across India name a baby, and when.',
          readId: 'preg_ready_read_naming_customs',
        ),
        PvDoorGuideTile(
          title: 'Star letters (rashi and nakshatra)',
          blurb: 'What they are, and why they wait for the birth.',
          readId: 'preg_ready_read_naming_customs',
          atHeading: 'What are star letters?',
        ),
        PvDoorGuideTile(
          title: 'Keeping the name a secret',
          blurb: 'Telling family early, or waiting for the day.',
          readId: 'preg_ready_read_naming_customs',
          atHeading: 'Should we keep the name a secret?',
        ),
        PvDoorGuideTile(
          title: 'The name on the birth certificate',
          blurb: 'Registering the birth, and adding the name later.',
          readId: 'preg_ready_read_naming_customs',
          atHeading: 'When does the name go on the birth certificate?',
        ),
      ],
    ),

    // =========================================================================
    //  TAB 2 · What to buy
    // =========================================================================
    PvDoorSection(
      group: kReadyTabBuy,
      heading: 'The first three months',
      tiles: [
        PvDoorGuideTile(
          title: 'What you need for the first three months',
          blurb: 'Clothes, nappies, sleep, feeding and getting about.',
          readId: 'preg_ready_read_need',
        ),
        PvDoorGuideTile(
          title: 'What you can skip or borrow',
          blurb: "The things you won't miss, and a few to leave out.",
          readId: 'preg_ready_read_skip',
        ),
        PvDoorToolTile(
          title: 'Shop the list',
          blurb: 'A shopping checklist to build and tick off, with a '
              'newborn starter list.',
          surfaceId: kReadySurfaceStore,
        ),
      ],
    ),
    PvDoorSection(
      group: kReadyTabBuy,
      heading: 'Buying safely',
      tiles: [
        PvDoorGuideTile(
          title: 'Cots, cradles and second-hand checks',
          blurb: 'What to look for on a cot, a palna or a jhoola.',
          readId: 'preg_ready_read_buying_safely',
        ),
        PvDoorGuideTile(
          title: 'Car seats: choosing and fitting one',
          blurb: 'Why it matters, and getting home from hospital.',
          readId: 'preg_ready_read_buying_safely',
          atHeading: 'Why a car seat?',
        ),
        // Opens a read whose first section carries the myth block, as the
        // myth chip promises (`pv_door_scans_test.dart` holds it).
        PvDoorMythTile(
          title: 'Does a baby need a pillow?',
          blurb: 'What helps the head keep a good shape.',
          readId: 'preg_ready_read_home',
        ),
      ],
    ),
    PvDoorSection(
      group: kReadyTabBuy,
      heading: 'For the hospital',
      tiles: [
        PvDoorToolTile(
          title: _bagTitle,
          blurb: _bagBlurb,
          surfaceId: kReadySurfaceBag,
        ),
      ],
    ),

    // =========================================================================
    //  TAB 3 · Home and help
    // =========================================================================
    PvDoorSection(
      group: kReadyTabHome,
      heading: 'Getting the home ready',
      tiles: [
        PvDoorGuideTile(
          title: 'Getting your home ready',
          blurb: 'A safe sleep corner, gentle cleaning, and pets.',
          readId: 'preg_ready_read_home',
        ),
        PvDoorGuideTile(
          title: 'Nesting, safely',
          blurb: 'The urge to get everything ready, without ladders or fumes.',
          readId: 'preg_ready_read_nesting',
        ),
        PvDoorGuideTile(
          title: 'Getting pets ready for the baby',
          blurb: 'Dogs, cats, the vet, and the cat litter tray.',
          readId: 'preg_ready_read_home',
          atHeading: 'What about pets?',
        ),
      ],
    ),
    PvDoorSection(
      group: kReadyTabHome,
      heading: 'The last months',
      tiles: [
        PvDoorGuideTile(
          title: 'Your last three months: a to-do list',
          blurb: "Your baby's doctor, hospital papers, and the ride in.",
          readId: 'preg_ready_read_last_months',
          meta: 'From 28 weeks',
        ),
        PvDoorToolTile(
          title: _bagTitle,
          blurb: _bagBlurb,
          surfaceId: kReadySurfaceBag,
        ),
        PvDoorGuideTile(
          title: 'Godh bharai and baby showers',
          blurb: 'When to hold it, keeping comfortable, and what to ask for.',
          readId: 'preg_ready_read_godh_bharai',
          meta: 'Often in month 7',
        ),
      ],
    ),
    PvDoorSection(
      group: kReadyTabHome,
      heading: 'Help after the birth',
      tiles: [
        PvDoorGuideTile(
          title: 'Planning help for the first 40 days',
          blurb: "Your mother's home, a japa maid, and sharing the nights.",
          readId: 'preg_ready_read_help',
        ),
        PvDoorGuideTile(
          title: 'Hiring a japa maid or a nanny',
          blurb: 'What to ask, and what to agree on day one.',
          readId: 'preg_ready_read_help',
          atHeading: 'Hiring a japa maid or a nanny',
        ),
        PvDoorGuideTile(
          title: 'Getting an older child ready',
          blurb: 'Telling them, keeping things steady, and the first days.',
          readId: 'preg_ready_read_older_child',
        ),
      ],
    ),
  ],
);
