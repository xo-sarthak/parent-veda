// =============================================================================
//  The Sleep door — seven collections on five tabs
// -----------------------------------------------------------------------------
//  The content is `kPpSleepSection` (`pp_sleep_content.dart`), built from the
//  rebuild brief. This file is only how it is laid over the door shell the
//  TTC and pregnancy doors wear — decided 2026-09-11 after the brief's own
//  landing-and-library shape was built and seen on a phone: the parenting
//  doors are to open the way every other door opens.
//
//  ⚠️ THE GROUPING, AND WHY. The brief's seven collections are the seven
//  areas of the section, and the selector draws five cards. Two pairs sit
//  naturally together:
//
//    · "She keeps waking at night" and "Her sleep suddenly got worse" are
//      both the night going wrong — one tonight, one this fortnight.
//    · "The things that worry you" and "Music, lori and sleep sounds" are
//      the collections that are not a stage of the night: the questions,
//      and the thing she reaches for at 2am.
//
//  The brief's LANDING items live on the tabs rather than above them: the
//  tracker ("Track & understand sleep") is a tool row on the first tab, where
//  her range is; Sleep Sounds is a tool row beside the sound library; and
//  "Talk to a sleep expert" is the door's closing row, under every tab. Nothing
//  from the landing is dropped.
//
//  ⚠️ THE RED FLAG IS THE DOCTOR PAGE, PINNED. "When night waking needs a
//  doctor" was the last card of a rail; the door shape has a place for it
//  above the rail, coral, and the brief's own format for it is "Red flag".
//
//  ⚠️ EACH AGE OPENS ON WHAT FITS, WITH "TONIGHT" FIRST (door plan
//  `docs/pp-door-plans/07-sleep.md`, SL1, the user's yes 2026-10-24). Every
//  age landed on How much sleep: two tracker rows and a chart, nothing to do
//  tonight. Now a newborn's parent lands on Safe sleep, and every other age on
//  Getting to sleep, and the opening tab starts with a row of things to try
//  tonight, nothing to tick. How much sleep, the tracker and the chart stay
//  one tab away.
// =============================================================================

import 'package:flutter/material.dart' show IconData, Icons;

import 'pp_door_data.dart';

/// "Tonight" (SL1), drawn in place on the tab that opens for her band. One id
/// per tab that can host it (`kPpSleepTonightShelf/<tab id>`); the row draws
/// itself only on the tab `tabOrder` opens for her band.
const String kPpSleepTonightShelf = 'pp_sleep_tonight';

/// One card of the Tonight row: a Sleep page by id, or a surface that is not
/// a page (the tanpura, Early Learning's bedtime tales).
class PpSleepTonightCard {
  const PpSleepTonightCard(this.name, this.icon, {this.pageId, this.surfaceId});

  /// The card's name, whole (a page title is a sentence; a card holds a name).
  final String name;
  final IconData icon;
  final String? pageId;
  final String? surfaceId;
}

/// ⚠️ THE CARDS, BY AGE, IN THE PLAN'S ORDER (SL1's table). Not shuffled: the
/// first card is the one that matters most tonight (a safe space for a
/// newborn, the routine after that). The tanpura is last on every row, and it
/// is the sound that plays (SL4). "Night fears" is for three and up, so the
/// one-to-three rows have four cards.
const Map<String, List<PpSleepTonightCard>> kPpSleepTonightCards = {
  'nb': [
    PpSleepTonightCard('Set up a safe sleep space', Icons.crib_outlined,
        pageId: 'sleep_surface'),
    PpSleepTonightCard('Swaddling', Icons.child_friendly_outlined,
        pageId: 'swaddling'),
    PpSleepTonightCard('Day and night', Icons.wb_twilight_outlined,
        pageId: 'day_night_confusion'),
    PpSleepTonightCard('Gentle settling', Icons.spa_outlined,
        pageId: 'gentle_settling'),
    _kTanpura,
  ],
  'm3_6': _kBabyTonight,
  'm6_12': _kBabyTonight,
  'tod_1_2': _kToddlerTonight,
  'tod_2_3': _kToddlerTonight,
  // Night fears joins from three (SL1: "Night fears (3+)").
  'pre': [
    PpSleepTonightCard('The bedtime routine', Icons.bedtime_outlined,
        pageId: 'bedtime_routine'),
    _kStoryOn,
    PpSleepTonightCard('Night fears', Icons.nights_stay_outlined,
        pageId: 'night_fears'),
    PpSleepTonightCard('Dropping naps', Icons.wb_sunny_outlined,
        pageId: 'dropping_naps'),
    _kTanpura,
  ],
};

const PpSleepTonightCard _kTanpura = PpSleepTonightCard(
    'Tanpura to sleep', Icons.music_note_outlined,
    surfaceId: 'pp_sleep_sounds');

const List<PpSleepTonightCard> _kBabyTonight = [
  PpSleepTonightCard('The bedtime routine', Icons.bedtime_outlined,
      pageId: 'bedtime_routine'),
  PpSleepTonightCard('Wake windows', Icons.timelapse_outlined,
      surfaceId: 'pp_wake_windows'),
  PpSleepTonightCard('Malish before bed', Icons.back_hand_outlined,
      pageId: 'malish'),
  PpSleepTonightCard('Gentle settling', Icons.spa_outlined,
      pageId: 'gentle_settling'),
  _kTanpura,
];

/// Early Learning's "Little bedtime tales": ten very short, very calm stories
/// for the last ten minutes of the day, from about one year.
const PpSleepTonightCard _kStoryOn = PpSleepTonightCard(
    'Screens off, story on', Icons.menu_book_outlined,
    surfaceId: 'pp_section/parenting_early_learning/bedtime_tales');

/// One to three: four cards (night fears waits for three).
const List<PpSleepTonightCard> _kToddlerTonight = [
  PpSleepTonightCard('The bedtime routine', Icons.bedtime_outlined,
      pageId: 'bedtime_routine'),
  _kStoryOn,
  PpSleepTonightCard('Dropping naps', Icons.wb_sunny_outlined,
      pageId: 'dropping_naps'),
  _kTanpura,
];

final PpDoor kPpSleepDoor = PpDoor(
  sectionId: 'parenting_sleep',
  // SL1: safe sleep first for a newborn, bedtime after that; the worries
  // before the numbers from one.
  tabOrder: const {
    'nb': ['safe', 'how_much', 'waking', 'getting', 'worries'],
    'm3_6': ['getting', 'waking', 'how_much', 'safe', 'worries'],
    'm6_12': ['getting', 'waking', 'how_much', 'safe', 'worries'],
    'tod_1_2': ['getting', 'waking', 'worries', 'how_much', 'safe'],
    'tod_2_3': ['getting', 'waking', 'worries', 'how_much', 'safe'],
    'pre': ['getting', 'waking', 'worries', 'how_much', 'safe'],
  },
  // Hu Chen, Unsplash. A sleeping face and a curled fist, close enough that
  // neither the position nor the bedding is in frame — see
  // `PpDoor.heroImageUrl` for why that is the requirement here.
  heroImageUrl:
      'https://images.unsplash.com/photo-1552819289-e14fbbcea868?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'how_much',
      label: 'How much sleep',
      icon: Icons.bedtime_outlined,
      hue: 206,
      areaIds: ['how_much'],
      tools: [
        // ⚠️ THE TRACKER, WHERE HER RANGE IS. "Tracker = Log her sleep =
        // Track & understand (one surface, keep Pampers)." `pp_sleep` is the
        // Sleep journey, Presented by Pampers, already age-aware; it is not
        // rebuilt or wrapped.
        PpDoorTool(
          label: 'Track and understand sleep',
          blurb: 'Log naps and nights, watch a pattern emerge, and get gentle '
              'age context, with no target to hit.',
          surfaceId: 'pp_sleep',
          icon: Icons.show_chart_rounded,
        ),
        // The week, not just today (gap analysis P2, Behind · Logging,
        // 2026-10-07): sleep per day over 7 days, and the doctor summary.
        PpDoorTool(
          label: 'The last 7 days',
          blurb: 'Total sleep each day this week, and a summary for your '
              'doctor.',
          surfaceId: 'pp_care_history',
          icon: Icons.calendar_month_outlined,
        ),
      ],
    ),
    PpDoorTab(
      id: 'waking',
      label: 'Waking at night',
      icon: Icons.nightlight_outlined,
      hue: 268,
      areaIds: ['night_waking', 'regressions'],
      redFlagPageId: 'waking_doctor',
      // SL6: help next to the worry, after the first rail, never stacked
      // with the pinned red flag above it. No sleep expert is live yet, so a
      // tap opens "Our first experts are joining" (S8).
      expert: PpDoorClosing(
        label: 'A sleep expert',
        blurb: 'Nights wearing you down?',
        surfaceId: 'pp_experts/Sleep expert',
      ),
    ),
    PpDoorTab(
      id: 'getting',
      label: 'Getting to sleep',
      icon: Icons.self_improvement_outlined,
      hue: 26,
      areaIds: ['getting_to_sleep'],
      // SL1: Tonight, from three months on.
      inlineSurfaceId: '$kPpSleepTonightShelf/getting',
    ),
    PpDoorTab(
      id: 'safe',
      label: 'Safe sleep',
      icon: Icons.shield_outlined,
      hue: 152,
      areaIds: ['safe_sleep'],
      // SL1: Tonight, for a newborn.
      inlineSurfaceId: '$kPpSleepTonightShelf/safe',
    ),
    PpDoorTab(
      id: 'worries',
      // SL9: three lines on the card at a large text size (measured in
      // Manrope at the card's width, `door_names_fit_test`). Was 'Worries and
      // sounds', kept for revert.
      label: 'Worries, sounds',
      icon: Icons.music_note_outlined,
      hue: 188,
      areaIds: ['worries', 'music'],
      tools: [
        // "Sleep Sounds tool = the library in collection 7." The row opens
        // the player; the library page on the rail is generated from the
        // same data.
        PpDoorTool(
          label: 'Sleep Sounds',
          // SL4: the tanpura first, the one that plays. Was: 'Lullabies, white
          // noise, rain, soft ragas and bedtime stories, with a timer that
          // switches itself off.'
          blurb: 'A tanpura drone to play tonight, with a timer that switches '
              'itself off. Lori, rain and stories are being recorded.',
          surfaceId: 'pp_sleep_sounds',
          icon: Icons.music_note_outlined,
          chip: 'Audio',
        ),
      ],
    ),
  ],
  // ⚠️ REPRESENTATION B WAS TRIED HERE AND NOT CHOSEN. A sentence instead
  // of a card, compared against the card on the other doors on a phone;
  // the user picked the card for every door (2026-09-13). Kept for revert.
  // closingLine: 'If the nights are wearing you down more than the day can '
  //     'fix, a sleep expert can look at her specifically. Book a 1:1.',
  closing: const PpDoorClosing(
    label: 'Talk to a sleep expert',
    blurb: 'Book a 1:1 if the nights are wearing you down more than the day '
        'can fix.',
    // The hub's own filtered roster — see `kPpSleep.closing` for why it is
    // filtered and why that was once reverted.
    surfaceId: 'pp_experts/Sleep expert',
  ),
);
