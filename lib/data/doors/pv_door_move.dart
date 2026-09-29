// =============================================================================
//  Move & rest — the door
// -----------------------------------------------------------------------------
//  Built 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "New section: Move & rest", P1. The "Yoga & fitness" tile
//  was the only tile on the pregnancy home without a door: it opened a class
//  catalogue shared with other stages, there was no written read on exercise
//  in pregnancy, and the Kegel Care tool had no door pointing to it.
//
//  Same shape as the other pregnancy doors (`pv_door_scans.dart` is the
//  benchmark): a hero, tabs, rails of guide and tool cards, a closing line.
//
//  ---------------------------------------------------------------------------
//  ⚠️ FOUR TABS, AND THE FOURTH IS WHERE THE TOOLS LIVE TOGETHER
//  ---------------------------------------------------------------------------
//
//    1. Move safely        is it safe, month by month, yoga, what to avoid
//    2. Pelvic floor       kegels, leaking, perineal massage
//    3. Sleep and rest     side sleeping, can't sleep, tiredness
//    4. Classes and tools  the 22 month-by-month yoga sessions, Kegel Care
//
//  The gap analysis names three tabs; the build brief adds a fourth that
//  gathers the two follow-along tools in one place, as well as beside the
//  reads they belong to. Each tool is on two tabs by design, never as a copy: one
//  surface id, opened through the door router either way.
//
//  ⚠️ THE TOOLS ARE SURFACE IDS, NOT SCREENS. `kMoveSurfaceYoga` and
//  `kMoveSurfaceKegel` become route names, and `global_ask_fab.dart` reads
//  route names to pick which Ask Veda opens. The door router maps them to the
//  shipped screens (`PrenatalYogaScreen`, `KegelCareScreen`).
//
//  Hues are the app's own: 160 is this bracket's green, 344, 268 and 42 are
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
/// The 22 month-by-month prenatal yoga sessions (`kYogaSessions`,
/// `PrenatalYogaScreen`).
const String kMoveSurfaceYoga = 'move/yoga';

/// The Kegel Care routine (`KegelCareScreen`).
const String kMoveSurfaceKegel = 'move/kegel';

/// Tab ids. Constants for the reason `pv_door_scans.dart` gives: a typo in a
/// section's group renders it in no tab at all.
const String kMoveTabMove = 'move';
const String kMoveTabPelvic = 'pelvic';
const String kMoveTabRest = 'rest';
const String kMoveTabClasses = 'classes';

/// Each tool card's words, shared by the two tabs it sits on.
const String _yogaTitle = 'Pregnancy yoga classes';
const String _yogaBlurb = '22 short sessions, month by month, for where you '
    'are now.';
const String _kegelTitle = 'Kegel Care: a guided daily routine';
const String _kegelBlurb = 'It times each squeeze and rest, and builds up as '
    'your pregnancy goes on.';

final PvDoorPage kMoveDoor = PvDoorPage(
  bracketId: 'pregnancy_fitness',

  heroTitle: 'Moving well, resting well.',
  heroBlurb: 'How to stay active safely, look after your pelvic floor, and '
      'sleep a little better.',

  // ⚠️ NOT LOOKED AT BY THE AUTHOR OF THIS FILE, AND SAID SO. The rule in
  // `pv_door_scans.dart` is "look at it first", and the image hosts were
  // unreachable from the session that built this door. This is the photograph
  // the Can I "Yoga" answer already ships (CC0, StockSnap, chosen by eye for
  // that page and mirrored to our R2 bucket), so it has been seen, but not in
  // a hero crop. Look at it on a phone before release; swap the id here if
  // the crop shows anything the rule forbids.
  heroImageUrl: readImageFor('cani_yoga'),

  closingLine: 'Check with your doctor before you start anything new. '
      'ParentVeda explains and reminds. Your doctor decides.',

  groups: [
    PvDoorGroup(
      id: kMoveTabMove,
      label: 'Move safely',
      mark: IntentMark.stepsMark,
      icon: Icons.directions_walk_rounded,
      hue: 160,
    ),
    PvDoorGroup(
      id: kMoveTabPelvic,
      label: 'Pelvic floor',
      mark: IntentMark.bodyMark,
      icon: Icons.favorite_border_rounded,
      hue: 344,
    ),
    PvDoorGroup(
      id: kMoveTabRest,
      label: 'Sleep and rest',
      mark: IntentMark.moonMark,
      icon: Icons.bedtime_outlined,
      hue: 268,
    ),
    PvDoorGroup(
      id: kMoveTabClasses,
      label: 'Classes and tools',
      mark: IntentMark.lotusMark,
      icon: Icons.self_improvement_rounded,
      hue: 42,
    ),
  ],

  sections: [
    // =========================================================================
    //  TAB 1 · Move safely
    // =========================================================================
    PvDoorSection(
      group: kMoveTabMove,
      heading: 'Start here',
      tiles: [
        PvDoorGuideTile(
          title: 'Is it safe to exercise in pregnancy?',
          blurb: 'How much is enough, and the talk test.',
          readId: 'preg_move_read_is_it_safe',
        ),
        PvDoorGuideTile(
          title: 'Walking: the easiest exercise',
          blurb: 'How far, how fast, and staying safe in the heat.',
          readId: 'preg_move_read_walking',
        ),
      ],
    ),
    PvDoorSection(
      group: kMoveTabMove,
      heading: 'Month by month',
      tiles: [
        PvDoorGuideTile(
          title: 'Moving in the first three months',
          blurb: "Gentle days, rest days, and what helps nausea.",
          readId: 'preg_move_read_first_trimester',
          meta: 'Weeks 1 to 13',
        ),
        PvDoorGuideTile(
          title: 'Moving in the middle three months',
          blurb: 'Your energy returns. What to change as you grow.',
          readId: 'preg_move_read_second_trimester',
          meta: 'Weeks 14 to 27',
        ),
        PvDoorGuideTile(
          title: 'Moving in the last three months',
          blurb: 'Slower and softer, and moves to get ready for birth.',
          readId: 'preg_move_read_third_trimester',
          meta: 'Weeks 28 to birth',
        ),
      ],
    ),
    PvDoorSection(
      group: kMoveTabMove,
      heading: 'Yoga',
      tiles: [
        PvDoorGuideTile(
          title: "Prenatal yoga: what's safe and what to skip",
          blurb: 'Poses to change, and what to leave for later.',
          readId: 'preg_move_read_yoga',
        ),
        PvDoorToolTile(
          title: _yogaTitle,
          blurb: _yogaBlurb,
          surfaceId: kMoveSurfaceYoga,
        ),
      ],
    ),
    PvDoorSection(
      group: kMoveTabMove,
      heading: 'Keep it safe',
      tiles: [
        PvDoorGuideTile(
          title: 'What to avoid',
          blurb: 'The sports and moves to leave out for now, and why.',
          readId: 'preg_move_read_avoid',
        ),
        PvDoorGuideTile(
          title: 'When to stop and call your doctor',
          blurb: 'The signs that mean stop now.',
          readId: 'preg_move_read_when_to_stop',
        ),
        PvDoorGuideTile(
          title: 'When your doctor may say not to exercise',
          blurb: 'The conditions that need a different plan.',
          readId: 'preg_move_read_when_not',
        ),
        PvDoorGuideTile(
          title: 'Belly muscles separating',
          blurb: 'What diastasis recti is, and getting up the gentle way.',
          readId: 'preg_move_read_diastasis',
        ),
      ],
    ),

    // =========================================================================
    //  TAB 2 · Pelvic floor
    // =========================================================================
    PvDoorSection(
      group: kMoveTabPelvic,
      heading: 'Your pelvic floor',
      tiles: [
        PvDoorGuideTile(
          title: 'Your pelvic floor, and how to do kegels',
          blurb: 'Find the right muscles, and a routine that fits your day.',
          readId: 'preg_move_read_pelvic_floor',
        ),
        PvDoorToolTile(
          title: _kegelTitle,
          blurb: _kegelBlurb,
          surfaceId: kMoveSurfaceKegel,
        ),
        // Opens a read whose first section carries the myth block, as the
        // myth chip promises (`pv_door_scans_test.dart` holds it).
        PvDoorMythTile(
          title: 'Is leaking just part of pregnancy?',
          blurb: "It's common, and it can get better.",
          readId: 'preg_move_read_leaking',
        ),
      ],
    ),
    PvDoorSection(
      group: kMoveTabPelvic,
      heading: 'Getting ready for birth',
      tiles: [
        PvDoorGuideTile(
          title: 'Perineal massage from 34 weeks',
          blurb: 'What it is, and how to do it gently at home.',
          readId: 'preg_move_read_perineal_massage',
          meta: 'From 34 weeks',
        ),
        PvDoorGuideTile(
          title: 'Moves to help you get ready for birth',
          blurb: 'Birth ball, supported squats and slow breathing.',
          readId: 'preg_move_read_third_trimester',
          atHeading: 'Can I get my body ready for birth?',
        ),
      ],
    ),

    // =========================================================================
    //  TAB 3 · Sleep and rest
    // =========================================================================
    PvDoorSection(
      group: kMoveTabRest,
      heading: 'Sleeping well',
      tiles: [
        PvDoorGuideTile(
          title: 'Sleeping on your side from 28 weeks',
          blurb: 'Which side, pillows, and waking up on your back.',
          readId: 'preg_move_read_side_sleeping',
          meta: 'From 28 weeks',
        ),
        PvDoorGuideTile(
          title: "When you can't sleep",
          blurb: 'Heartburn, bathroom trips, cramps and a busy mind.',
          readId: 'preg_move_read_cant_sleep',
        ),
        PvDoorGuideTile(
          title: 'Tired all the time',
          blurb: "Resting well, and when it's more than tiredness.",
          readId: 'preg_move_read_tiredness',
        ),
      ],
    ),

    // =========================================================================
    //  TAB 4 · Classes and tools
    // =========================================================================
    PvDoorSection(
      group: kMoveTabClasses,
      heading: 'Follow along at home',
      tiles: [
        PvDoorToolTile(
          title: _yogaTitle,
          blurb: _yogaBlurb,
          surfaceId: kMoveSurfaceYoga,
        ),
        PvDoorToolTile(
          title: _kegelTitle,
          blurb: _kegelBlurb,
          surfaceId: kMoveSurfaceKegel,
        ),
      ],
    ),
    PvDoorSection(
      group: kMoveTabClasses,
      heading: 'Before you start',
      tiles: [
        PvDoorGuideTile(
          title: "Yoga in pregnancy: what's safe",
          blurb: 'Read this before your first class.',
          readId: 'preg_move_read_yoga',
        ),
        PvDoorGuideTile(
          title: 'Signs to stop and call',
          blurb: 'Keep these in mind whenever you exercise.',
          readId: 'preg_move_read_when_to_stop',
        ),
      ],
    ),
  ],
);
