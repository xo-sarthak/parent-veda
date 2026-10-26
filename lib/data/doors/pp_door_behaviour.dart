// =============================================================================
//  The Behaviour door — why she does it, what to do, the words to use
// -----------------------------------------------------------------------------
//  The content is `kPpBehaviourSection` (`pp_behaviour_content.dart` and its
//  two sibling files), rebuilt to `Behaviour_Parenting.pdf` (31 Aug 2026).
//  The brief's own call is "one library plus a tools rail, do NOT invent a
//  five-tab structure"; the user's standing call is that every parenting door
//  wears the door shell, so the eleven areas sit on five tabs the brief did
//  not draw (was "twelve": the lying area was folded into Three to six). The
//  grouping is the user's (2026-09-13), not the brief's:
//
//    Crying · the first year        the one infant area
//    Tantrums and the ziddi years   ziddi, first tantrums and hitting, no
//    He keeps doing this            the lookup door, screens, the habits
//    Scared, shy or clingy          the missing half, one new area
//    Calm and guidance              the six practices, no hitting, three to six
//
//  ⚠️ TABS FOR LATER, NEVER HIDDEN (corrected in the door 8 build; this
//  said the toddler tabs were "not on the selector", untrue since step 0 S9).
//  A parent of a three-month-old opens on Crying, and the four toddler tabs
//  sit after it, open, each starting "For later. This usually starts from 1
//  year." A parent of a four-year-old does not see Crying: a tab he has grown
//  past drops. The shell does both from the areas' own bands.
//
//  ⚠️ EACH AGE OPENS ON WHAT FITS, WITH "RIGHT NOW" FIRST (door plan
//  `docs/pp-door-plans/08-behaviour.md`, BH1, the user's yes 2026-10-25).
//  Every age from one opened on Tantrums, and a four-year-old's parent
//  started on the stubborn child while not listening, anger and screens sat
//  two tabs in. Now one to three opens on Tantrums, three to six on He keeps
//  doing this, and the opening tab starts with five things for right now,
//  nothing to tick: the four most-searched worries, each one tap from the
//  door.
//
//  ⚠️ NO RED FLAG TAB, ON PURPOSE. "Health and Complications earned one
//  because they hold same-day medical emergencies. Behaviour does not; its
//  flags are page-level. A red-flag strip where there are none trains people
//  to ignore the real ones."
// =============================================================================

import 'package:flutter/material.dart' show IconData, Icons;

import 'pp_door_data.dart';

/// "Right now" (BH1), drawn in place on the tab that opens for her band. One
/// id per tab that can host it (`kPpBehRightNowShelf/<tab id>`); the row draws
/// itself only on the tab `tabOrder` opens for her band.
const String kPpBehRightNowShelf = 'pp_beh_right_now';

/// One card of the Right now row: a Behaviour page by id, or a surface that
/// is not a page (the What to say tool).
class PpBehRightNowCard {
  const PpBehRightNowCard(this.name, this.icon, {this.pageId, this.surfaceId});

  /// The card's name, whole (a page title is a sentence; a card holds a name).
  final String name;
  final IconData icon;
  final String? pageId;
  final String? surfaceId;
}

/// ⚠️ THE CARDS, BY AGE, IN THE PLAN'S ORDER (BH1's table). Not shuffled: the
/// first card is the worry most searched at that age (crying, then tantrums,
/// then not listening), and What to say is last on every row.
const Map<String, List<PpBehRightNowCard>> kPpBehRightNowCards = {
  'infant': [
    PpBehRightNowCard('Colic, or normal crying?', Icons.graphic_eq_rounded,
        pageId: 'crying_normal'),
    PpBehRightNowCard("Won't settle", Icons.nightlight_outlined,
        pageId: 'wont_settle'),
    PpBehRightNowCard("When it's too much", Icons.self_improvement_outlined,
        pageId: 'crying_too_much'),
    PpBehRightNowCard("You can't spoil him", Icons.favorite_border_rounded,
        pageId: 'cant_spoil'),
    _kWhatToSay,
  ],
  'toddler_1': [
    _kTantrumSteps,
    PpBehRightNowCard('He hit someone', Icons.back_hand_outlined,
        pageId: 'hitting_biting'),
    PpBehRightNowCard('Cries when I leave', Icons.waving_hand_outlined,
        pageId: 'separation'),
    PpBehRightNowCard('Two choices', Icons.call_split_rounded,
        pageId: 'beh_choices'),
    _kWhatToSay,
  ],
  'toddler_2': [
    _kTantrumSteps,
    PpBehRightNowCard('He hits', Icons.back_hand_outlined,
        pageId: 'hitting_biting'),
    PpBehRightNowCard('No to everything', Icons.do_not_disturb_on_outlined,
        pageId: 'defiance'),
    PpBehRightNowCard('Screens off', Icons.tv_off_outlined,
        pageId: 'beh_screen_ending'),
    _kWhatToSay,
  ],
  'preschool': [
    PpBehRightNowCard('Not listening', Icons.hearing_outlined,
        pageId: 'beh_not_listening'),
    PpBehRightNowCard('Anger', Icons.whatshot_outlined, pageId: 'beh_anger'),
    PpBehRightNowCard('Screen limits', Icons.phone_android_outlined,
        pageId: 'beh_screen_limits'),
    PpBehRightNowCard('Calm corner', Icons.spa_outlined,
        pageId: 'beh_calm_corner'),
    _kWhatToSay,
  ],
};

const PpBehRightNowCard _kTantrumSteps = PpBehRightNowCard(
    'Tantrum steps', Icons.format_list_numbered_rounded,
    pageId: 'beh_tantrum_steps');

/// The words tool, opening on his band (`pp_scripts`).
const PpBehRightNowCard _kWhatToSay = PpBehRightNowCard(
    'What to say', Icons.chat_bubble_outline_rounded,
    surfaceId: 'pp_scripts');

final PpDoor kPpBehaviourDoor = PpDoor(
  sectionId: 'parenting_behaviour',
  // BH1: a baby opens on Crying (the other four sit after it, for later);
  // one to three on Tantrums; three to six on He keeps doing this.
  tabOrder: const {
    'infant': ['crying', 'tantrums', 'this_one_thing', 'scared', 'calm'],
    'toddler_1': ['tantrums', 'calm', 'scared', 'this_one_thing', 'crying'],
    'toddler_2': ['tantrums', 'this_one_thing', 'calm', 'scared', 'crying'],
    'preschool': ['this_one_thing', 'calm', 'tantrums', 'scared', 'crying'],
  },
  // Unsplash, free. A toddler mid-shout on a beach, arms up, gleeful and
  // furious at once: the big feeling in a small body this door is about,
  // with nobody scolding in the frame.
  heroImageUrl:
      'https://images.unsplash.com/photo-1471286174890-9c112ffca5b4?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'crying',
      label: 'Crying, the first year',
      icon: Icons.nightlight_outlined,
      hue: 232,
      areaIds: ['crying'],
      // BH1: Right now, for a baby.
      inlineSurfaceId: '$kPpBehRightNowShelf/crying',
      tools: [
        // The scripts tool rides the infant tab too: in this band the words
        // are for answering the family, not the baby, and this is the only
        // tab an infant's parent sees. The toddler tabs carry it on
        // Tantrums; no parent sees both.
        PpDoorTool(
          label: 'What to say', // was 'What to say when…', read as cut off (2026-10-24)
          blurb: 'The words for the family: "you are spoiling him", "let him '
              'cry". Search it while it is happening.',
          surfaceId: 'pp_scripts',
          icon: Icons.chat_bubble_outline_rounded,
        ),
      ],
    ),
    PpDoorTab(
      id: 'tantrums',
      label: 'Tantrums', // was 'Tantrums and the stubborn years', three lines on a card (2026-10-24)
      icon: Icons.whatshot_outlined,
      hue: 344,
      areaIds: ['ziddi', 'first_feelings', 'the_no_year'],
      // BH1: Right now, from one to three.
      inlineSurfaceId: '$kPpBehRightNowShelf/tantrums',
      tools: [
        // The hero tool. "Find the moment, get the sentence. Referenced from
        // six pages, one tool." Its age chips came off; it opens on his band.
        PpDoorTool(
          label: 'What to say', // was 'What to say when…', read as cut off (2026-10-24)
          blurb: 'The exact words for the moment you are in, and what to '
              'leave unsaid. Search it while it is happening.',
          surfaceId: 'pp_scripts',
          icon: Icons.chat_bubble_outline_rounded,
        ),
      ],
    ),
    PpDoorTab(
      id: 'this_one_thing',
      label: 'He keeps doing this',
      icon: Icons.repeat_rounded,
      hue: 42,
      areaIds: ['specific_behaviours', 'screen_time', 'habits'],
      // BH1: Right now, from three.
      inlineSurfaceId: '$kPpBehRightNowShelf/this_one_thing',
      // BH4: help next to the worry, after the first rail. "Nothing works" is
      // the point where a parent needs a person. No child psychologist is
      // live yet, so a tap opens "Our first experts are joining" (S8e). The
      // door's closing card stays on the other tabs.
      expert: PpDoorClosing(
        label: 'A child psychologist',
        blurb: 'Nothing working?',
        surfaceId: 'pp_experts/Child psychologist',
      ),
      tools: [
        // The one What Changed checker, shared with Health and Development,
        // opened pre-filtered to the Behaviour and Mood concerns.
        PpDoorTool(
          label: 'Something has changed',
          blurb: 'Started biting, head-banging, suddenly clingy. Work through '
              'it calmly.',
          surfaceId: 'pp_what_changed/behaviour',
          icon: Icons.swap_horiz_rounded,
        ),
      ],
    ),
    PpDoorTab(
      id: 'scared',
      // SL9 / BH, the user's word 2026-10-26: three lines on the rail card at
      // large text. Was 'Scared, shy or clingy', kept for revert.
      label: 'Shy and clingy',
      icon: Icons.dark_mode_outlined,
      hue: 206,
      areaIds: ['scared'],
    ),
    PpDoorTab(
      id: 'calm',
      label: 'Calm and guidance',
      icon: Icons.spa_outlined,
      hue: 128,
      areaIds: ['calming', 'discipline', 'older_child'],
      footer: 'Warm and firm is a third thing. It is not the middle of the '
          'other two.',
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to a child psychologist',
    blurb: 'For behaviour that has stopped responding to anything you try, '
        'or that is frightening you. Nothing here is a diagnosis.',
    surfaceId: 'pp_experts/Child psychologist',
  ),
);
