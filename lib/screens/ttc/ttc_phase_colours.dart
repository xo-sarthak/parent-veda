// =============================================================================
//  The four cycle stretches, as colour
// -----------------------------------------------------------------------------
//  ⚠️ WHY THIS IS NOT `v2BlockTint`, AND WHY IT IS NOT ALLOWED TO BECOME A
//  SECOND GENERAL TINT RULE.
//
//  `v2BlockTint(hue, p)` takes a hue and stamps its own saturation and
//  lightness — 32% and 91%, near-white — then hands it back. That is exactly
//  right for what it was written for: a tinted block behind a heading, where
//  the colour is a soft label on a large calm surface and four of them are
//  never asked to be told apart.
//
//  A cycle picture asks something else. Four arcs on one ring at a 16pt stroke,
//  or twenty-eight small squares in a grid, have to be distinguishable at a
//  glance and in a hurry — that IS the information, not decoration on top of
//  it. Held side by side, the 32/91 wash puts the four stretches within a few
//  points of each other and of the card they sit on. It was compared on screen
//  before this file existed, and the stronger set is the one that was chosen.
//
//  So the hues are the repo's, unchanged — 344, 206, 160, 268, three of them
//  the app's own `V2BlockHues` — and only the saturation and lightness differ.
//  A phase is the same colour family here as everywhere else in the stage; it
//  is simply drawn strongly enough to read as a diagram.
//
//  ⚠️ THE SCOPE IS THE POINT. These functions take a [TtcPhase], not a hue.
//  Nothing else can call them, so they cannot spread into ordinary cards and
//  leave the app with two competing answers to "how tinted is a tinted block".
//  If a second colour-coded diagram ever wants this treatment, give it its own
//  narrow accessor next to this one rather than widening these to take a hue.
//
//  Recorded in `docs/STILL-OPEN.md` §18 as a deliberate deviation from the door
//  playbook's "`v2BlockTint` for every tint".
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_cycle_report.dart';

/// The fill behind a stretch — a ring arc, a calendar day, a legend chip.
Color ttcPhaseBand(TtcPhase phase) => switch (phase) {
      TtcPhase.period => const Color(0xFFE2B6C2),
      TtcPhase.beforeWindow => const Color(0xFFB9CFDF),
      TtcPhase.fertileWindow => const Color(0xFFA9D1C3),
      TtcPhase.afterWindow => const Color(0xFFD5C9E3),
    };

/// The solid mark — a timeline node, the dot on today, a legend key.
///
/// ⚠️ SOLID, NOT A DARKER BAND. A mark and a fill are doing different jobs: the
/// fill says "these days belong together", the mark says "this one thing". They
/// are far enough apart in strength that neither is mistaken for the other at
/// the size a phone renders them.
Color ttcPhaseMark(TtcPhase phase) => switch (phase) {
      TtcPhase.period => const Color(0xFFCB7289),
      TtcPhase.beforeWindow => const Color(0xFF77A3C5),
      TtcPhase.fertileWindow => const Color(0xFF438972),
      TtcPhase.afterWindow => const Color(0xFFB198CD),
    };

/// Text and numerals sitting **on** [ttcPhaseBand].
///
/// ⚠️ NOT `ttcTitleInk` ON A TINT. A calendar sets a day number on every one of
/// twenty-eight coloured squares; one neutral ink across four different fills
/// reads correctly on some and muddily on others. Each of these is the phase's
/// own hue taken dark, so the number belongs to the square it is on.
Color ttcPhaseInk(TtcPhase phase) => switch (phase) {
      TtcPhase.period => const Color(0xFF8C364D),
      TtcPhase.beforeWindow => const Color(0xFF376181),
      TtcPhase.fertileWindow => const Color(0xFF366D5B),
      TtcPhase.afterWindow => const Color(0xFF5F4082),
    };
