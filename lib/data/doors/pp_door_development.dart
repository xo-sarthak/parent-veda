// =============================================================================
//  The Development door — play first, then "is he okay", on four tabs
// -----------------------------------------------------------------------------
//  The content is `kPpDevelopmentSection` (`pp_development_content.dart`),
//  rebuilt to `Development_Parenting.pdf` (the reissued brief of 31 Aug 2026,
//  which replaces `ParentVeda_Development_rebuild.pdf`). The reissue's one
//  structural call: the "is my child on track" pages come FIRST, and the four
//  areas of growing sit inside the tracker as a closer look, not out front.
//  "A parent's real question is 'is he okay, and what do I do', not 'show me
//  his profile'."
//
//  ⚠️ PLAY FIRST NOW, AT EVERY AGE (door plan `docs/pp-door-plans/
//  04-development.md`, DV1, the user's yes 2026-10-24). Development is an
//  action door that opened like a test: the month's checklist was the first
//  card for every child, and the activities were four taps away (door, tab,
//  tool card, activity). Play today opens on six activities for his age
//  (DV2, the approved look), and On track stays one tab away with its
//  worth-checking page, so the worry is never hidden.
//
//  ⚠️ SIX TABS BECAME FOUR. "Phases" and "Talk and check" held one tool card
//  each; both tools moved to On track. The two tabs are kept below, commented,
//  for revert.
//
//  ⚠️ A TAB DROPS AWAY WITH AGE, on the brief's own scoping: "Sit, crawl,
//  walk" is up to two years ("drops away after 2, on purpose"). See
//  `PpDoorTab.toMonths`.
//
//  ⚠️ NO RED FLAG TAB, BY DESIGN. "No emergency red-flag tab (this section
//  has none by design)." The honest lines live inside "When something is
//  genuinely worth checking", "Movement signs worth showing a doctor" and
//  "When talking is worth checking", each routing to a person, never a
//  verdict.
//
//  ⚠️ CORRECTED AGE. For a baby born early, under two, the door's bands read
//  his corrected age (`kPpDevelopmentBands`, `PpBandSet.correctedClock`,
//  DV4), and the hero says so.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

/// Play today's inline shelf (`PpDoorTab.inlineSurfaceId`, D2): six
/// activities for his age, a fresh pick each day, then All activities.
const String kPpPlayTodayShelf = 'pp_play_today';

final PpDoor kPpDevelopmentDoor = PpDoor(
  sectionId: 'parenting_development',
  // DV1: Play today first at every age, then what matters most for the age.
  tabOrder: const {
    'dev_0_6': ['what_to_do', 'on_track', 'when_will', 'talking'],
    'dev_6_12': ['what_to_do', 'when_will', 'talking', 'on_track'],
    'dev_1_2': ['what_to_do', 'talking', 'when_will', 'on_track'],
    'dev_2_3': ['what_to_do', 'talking', 'on_track'],
    'dev_3_5': ['what_to_do', 'talking', 'on_track'],
  },
  // Unsplash, free. A toddler mid messy-play, paint on her face, looking up
  // and laughing: growing as something joyful, not measured. Nothing on it a
  // page in this door argues with.
  heroImageUrl:
      'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      // The id stays 'what_to_do' so deep links and `initialTabId` land.
      id: 'what_to_do',
      label: 'Play today', // was 'What to do' (DV1, 2026-10-25)
      icon: Icons.toys_outlined,
      hue: 28,
      areaIds: ['help_develop', 'feelings_play'],
      // D2: "Play with him today", six activities for his age, one tap each.
      inlineSurfaceId: kPpPlayTodayShelf,
      tools: [
        // ⚠️ THE CARD BECAME THE SHELF. The activities are drawn in place
        // now, and "All activities" closes the shelf. Kept for revert:
        // PpDoorTool(
        //   // R3 (tools pass, 2026-10-25): it opens every idea for this age,
        //   // not today's pick. Was 'Things to do together today'.
        //   label: 'Activities for this age',
        //   blurb: 'Today\'s pick and every activity, matched to his age and to '
        //       'each area of growing.',
        //   surfaceId: 'pp_activities',
        //   icon: Icons.toys_outlined,
        // ),
        // Gap analysis P2 (2026-10-07): "a tummy time timer on the
        // Development door with a soft daily total and no target". The
        // first year only (D8): it showed to a four-year-old's parent.
        PpDoorTool(
          label: 'Tummy time',
          blurb: 'A gentle timer and a daily total. No target, no streak.',
          surfaceId: 'pp_tummy_time',
          icon: Icons.timer_outlined,
          bands: ['dev_0_6', 'dev_6_12'],
        ),
      ],
      // DV7: no expert on the play tab; the class that fits it instead.
      expert: PpDoorClosing(
        label: 'Play and Brain',
        blurb: 'A class for you',
        note: 'Five short lessons with a paediatrician',
        surfaceId: 'pp_learn/rc_playbrain',
      ),
      // DV6: toys last, and the copy before the label.
      shop: PpDoorClosing(
        label: 'Toys for this age',
        blurb: 'You don\'t need to buy anything. A steel bowl and a spoon '
            'are a toy.',
        surfaceId: 'pp_toys',
      ),
    ),
    PpDoorTab(
      id: 'on_track',
      label: 'On track',
      icon: Icons.checklist_rtl_outlined,
      hue: 160,
      // `something_changed` stays out: the user removed that area as a
      // duplicate of its tool (kept commented in the content file). The
      // tool is here.
      areaIds: ['on_track', 'age_by_age'],
      tools: [
        // Development > Month by month checklist (gap analysis P1, 2026-10-07):
        // milestones, play, sleep, feeding, safety, vaccines and the doctor
        // lines for this age, on one page.
        PpDoorTool(
          label: "This month's checklist",
          blurb: 'Everything for this age on one page: what is new, skills '
              'coming in, what is due, and when to call the doctor.',
          surfaceId: 'pp_month_checklist',
          icon: Icons.checklist_rtl_outlined,
        ),
        // ⚠️ THE ONE TRACKER. "Where he is right now" and "What is emerging"
        // were the same list shown two ways; the journey kept the flip-cards
        // and the search and gained the "usually settled by now" group. The
        // four areas of growing are its Explore-by-area, one tap deeper.
        //
        // ⚠️ READ, THEN THE TOOL FOR IT. The user's call (2026-09-13): the
        // rail goes "The normal range is much wider than you think" then the
        // tracker, "When something is worth checking" then the
        // check-in, then the born-early read. Educate, then hand over.
        PpDoorTool(
          // Named as the tool is (tools pass, 2026-10-25). Was 'Where your
          // baby is right now', and the blurb's fixed "His milestones".
          label: 'Milestones',
          blurb: 'Skills as windows: usually settled by now, emerging '
              'now, and a soft look ahead. Never a score.',
          surfaceId: 'pp_milestones',
          icon: Icons.checklist_rtl_outlined,
          afterPageId: 'dev_range_is_wide',
        ),
        PpDoorTool(
          label: 'A gentle check-in',
          blurb: 'A few soft yes or not-yet questions for his age. No score, '
              'and it never says "all fine".',
          surfaceId: 'pp_dev_checkin',
          icon: Icons.spa_outlined,
          afterPageId: 'dev_worth_checking',
        ),
        // ⚠️ FROM THE PHASES TAB (DV1). The leaps are retired (the user,
        // 2026-10-14); the surface opens the phases the Drive docs feed,
        // birth to five.
        PpDoorTool(
          label: 'Your child\'s phases',
          blurb: 'Every phase from birth to five, and what each one brings.',
          surfaceId: 'pp_leaps',
          icon: Icons.auto_awesome_outlined,
          atEnd: true,
        ),
        // ⚠️ FROM TALK AND CHECK (DV1). The one What Changed flow, shared
        // with Health and Behaviour.
        PpDoorTool(
          label: 'Something has changed',
          blurb: 'Babbling gone quiet, suddenly shy. Work through what changed, '
              'calmly.',
          surfaceId: 'pp_what_changed',
          icon: Icons.change_circle_outlined,
          atEnd: true,
        ),
      ],
      // DV7: the developmental paediatricians are placeholder profiles, so
      // the tap says they are joining and offers a paediatrician (S8b).
      expert: PpDoorClosing(
        label: 'A developmental paediatrician',
        blurb: 'Something worrying you?',
        surfaceId: 'pp_experts/Development expert',
      ),
      footer: 'A box you have not ticked is not one your child has missed. One baby '
          'is not a range.',
    ),
    PpDoorTab(
      id: 'when_will',
      label: 'Sit, crawl, walk', // was 'When will my baby...', cut off on its card (2026-10-24)
      icon: Icons.directions_walk_outlined,
      hue: 206,
      areaIds: ['when_will'],
      toMonths: 24,
      // DV7: no paediatric physio category yet; S8b offers a paediatrician.
      expert: PpDoorClosing(
        label: 'A paediatric physio',
        blurb: 'Games that help him move, by video call',
        surfaceId: 'pp_experts/Paediatric physio',
      ),
    ),
    PpDoorTab(
      id: 'talking',
      label: 'Talking',
      icon: Icons.chat_bubble_outline_rounded,
      hue: 268,
      areaIds: ['speech_language'],
      expert: PpDoorClosing(
        label: 'A speech therapist',
        blurb: 'Questions about his talking?',
        surfaceId: 'pp_experts/Speech therapist',
      ),
    ),
    // The two tool-only tabs, folded into On track (DV1). Kept for revert:
    // PpDoorTab(
    //   id: 'leaps',
    //   // ⚠️ THE LEAPS ARE RETIRED (the user, 2026-10-14): "I don't want those
    //   // old leaps ... anywhere in the app wired." The tab now opens the
    //   // phases the Drive docs feed, birth to five. The id stays 'leaps'
    //   // because deep links and `initialTabId` use it.
    //   // Kept for revert: label: 'The leaps', toMonths: 20,
    //   label: 'Phases',
    //   icon: Icons.auto_awesome_outlined,
    //   hue: 296,
    //   areaIds: [],
    //   tools: [
    //     PpDoorTool(
    //       label: 'Your child\'s phases',
    //       blurb: 'Every phase from birth to five, and what each one brings.',
    //       surfaceId: 'pp_leaps',
    //       icon: Icons.auto_awesome_outlined,
    //     ),
    //   ],
    //   note: 'The phase your child is in now, and the ones ahead. Every '
    //       'child\'s timing is their own.',
    // ),
    // PpDoorTab(
    //   id: 'talk',
    //   label: 'Talk and check',
    //   icon: Icons.forum_outlined,
    //   hue: 128,
    //   areaIds: [],
    //   tools: [
    //     PpDoorTool(
    //       label: 'Something has changed',
    //       blurb: 'Babbling gone quiet, suddenly shy. Work through what changed, '
    //           'calmly.',
    //       surfaceId: 'pp_what_changed',
    //       icon: Icons.change_circle_outlined,
    //     ),
    //   ],
    // ),
  ],
  // Every tab now carries its own expert or class (DV7), so this card is
  // drawn by none of them; it stays for the section screen and as the
  // door's named specialist.
  closing: const PpDoorClosing(
    label: 'Talk to a specialist',
    blurb: 'A second, reassuring opinion if something feels off track. '
        'Booking is mock for now.',
    surfaceId: 'pp_experts/Development expert',
  ),
);
