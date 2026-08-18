// =============================================================================
//  TTC surfaces — what a bracket can point at on the Trying-to-Conceive side
// -----------------------------------------------------------------------------
//  Third file of its kind, after `app_structure.dart` (pregnancy) and
//  `parenting_surfaces.dart`. The reason there are three rather than one is the
//  same each time and worth stating once more, because "just merge them" is the
//  obvious suggestion:
//
//  A surface list is not a description of the app — it is a list of what ONE
//  stage's brackets are allowed to point at. Merging them would make the
//  pregnancy build compile the TTC screen tree and vice versa, and it would let
//  a pregnancy bracket name a TTC screen, which is a wiring mistake nothing else
//  would catch.
//
//  IDS ARE PREFIXED `ttc_`, matching `pp_`. Every stage has a Tools hub, a
//  Community and a Calendar; an unprefixed 'tools' is ambiguous in exactly the
//  place ambiguity costs most.
//
//  ⚠️ NOTHING HERE IS NEW. Every entry names a screen that already ships — the
//  TTC stage was built out over several sessions and is the most complete of the
//  three. That is why its brackets resolve so densely: this file is an inventory,
//  not a plan.
//
//  ⚠️ AND THE LABELS ARE HINGLISH, NOT DEVANAGARI. That is deliberate and it is
//  NOT the pregnancy house style. Per CLAUDE.md the Devanagari migration covers
//  the Pregnancy stage ONLY; TTC still speaks Hinglish throughout its chrome
//  (`ttc_strings.dart` — `Suprabhat`, `Aapka chapter`), and a bracket screen
//  rendering Devanagari rows inside a Hinglish shell would be worse than either
//  choice made consistently. When TTC is migrated, these move with the rest of
//  the stage in one pass.
// =============================================================================

import 'package:flutter/foundation.dart';

@immutable
class TtcSurface {
  const TtcSurface(this.id, this.en, this.hi);

  /// Stable, never translated, always `ttc_`-prefixed.
  final String id;

  final String en;

  /// Hinglish, matching the rest of the stage. See the header.
  final String hi;
}

/// Everything a TTC bracket may point at.
const List<TtcSurface> kTtcSurfaces = [
  // ---- The cycle spine ------------------------------------------------------
  TtcSurface('ttc_cycle', 'Your cycle', 'Aapka cycle'),
  TtcSurface('ttc_ovulation', 'Ovulation signals', 'Ovulation ke signals'),
  TtcSurface('ttc_window', 'Fertile window', 'Fertile window'),
  TtcSurface('ttc_calendar', 'Calendar', 'Calendar'),

  // ---- Learning -------------------------------------------------------------
  TtcSurface('ttc_chapter', 'Read this chapter', 'Yeh chapter padhein'),
  TtcSurface('ttc_can_i', 'Can I…?', 'Kya main…?'),

  // ---- Body and health ------------------------------------------------------
  TtcSurface('ttc_tests', 'Tests & results', 'Tests aur results'),
  TtcSurface('ttc_nutrition', 'Eating for fertility', 'Fertility ke liye khana'),
  TtcSurface('ttc_supplements', 'Supplements', 'Supplements'),
  TtcSurface('ttc_tracker', 'Daily log', 'Roz ka log'),

  // ---- Treatment ------------------------------------------------------------
  TtcSurface('ttc_treatment', 'IUI & IVF explained', 'IUI aur IVF samjhein'),
  TtcSurface('ttc_records', 'Your records', 'Aapke records'),
  TtcSurface('ttc_medication', 'Medication schedule', 'Dawai ka schedule'),
  TtcSurface('ttc_appointments', 'Appointments', 'Appointments'),

  // ---- Mind and body --------------------------------------------------------
  TtcSurface('ttc_ritual', "Today's practice", 'Aaj ka abhyas'),
  TtcSurface('ttc_journal', 'Journal', 'Journal'),

  // ---- Partner --------------------------------------------------------------
  TtcSurface('ttc_partner', 'For your partner', 'Aapke partner ke liye'),

  // ---- People ---------------------------------------------------------------
  TtcSurface('ttc_prepare', 'Talk to someone', 'Kisi se baat karein'),
  TtcSurface('ttc_community', 'Others going through this', 'Aur log jo isi mein hain'),
  TtcSurface('ttc_care_circle', 'Your care circle', 'Aapka care circle'),

  // ---- Commerce -------------------------------------------------------------
  TtcSurface('ttc_products', 'Things that help', 'Jo cheezein madad karti hain'),
];

/// The label for a TTC surface, or null when the id is unknown.
///
/// Null rather than the id itself: the bracket screen filters rows on this
/// exact answer, so an unknown id must render NOTHING rather than a row
/// labelled `ttc_whatever`. A typo should look like a missing feature to the
/// reader and like a bug to the wiring test — never like a broken row to her.
String? ttcSurfaceLabel(String id, {required bool hinglish}) {
  for (final s in kTtcSurfaces) {
    if (s.id == id) return hinglish ? s.hi : s.en;
  }
  return null;
}
