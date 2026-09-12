// =============================================================================
//  The Development door — "is he okay, and what do I do", on six tabs
// -----------------------------------------------------------------------------
//  The content is `kPpDevelopmentSection` (`pp_development_content.dart`),
//  rebuilt to `Development_Parenting.pdf` (the reissued brief of 31 Aug 2026,
//  which replaces `ParentVeda_Development_rebuild.pdf`). The reissue's one
//  structural call: the "is my child on track" pages come FIRST, and the four
//  areas of growing sit inside the tracker as a closer look, not out front.
//  "A parent's real question is 'is he okay, and what do I do', not 'show me
//  his profile'."
//
//  ⚠️ THE MERGES SHOW AS ONE CARD EACH. Two trackers over one dataset became
//  one (`pp_milestones`; `pp_on_track` opens the same screen). The hub with
//  today's pick and the activities is the one Tool on What to do, so the
//  activities finally sit beside the reassurance pages — "today a parent can
//  land on the activities and never find the reassurance pages, which is the
//  part that matters most."
//
//  ⚠️ TWO TABS DROP AWAY WITH AGE, on the brief's own scoping: "When will my
//  baby..." is up to two years ("drops away after 2, on purpose") and The
//  leaps is the first twenty months. See `PpDoorTab.toMonths`.
//
//  ⚠️ NO RED FLAG TAB, BY DESIGN. "No emergency red-flag tab (this section
//  has none by design)." The honest lines live inside "When something is
//  genuinely worth checking" and "When talking is worth checking", each
//  routing to a person, never a verdict.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpDevelopmentDoor = PpDoor(
  sectionId: 'parenting_development',
  // Unsplash, free. A toddler mid messy-play, paint on her face, looking up
  // and laughing: growing as something joyful, not measured. Nothing on it a
  // page in this door argues with.
  heroImageUrl:
      'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'on_track',
      label: 'On track',
      icon: Icons.checklist_rtl_outlined,
      hue: 160,
      areaIds: ['on_track'],
      tools: [
        // ⚠️ THE ONE TRACKER. "Where he is right now" and "What is emerging"
        // were the same list shown two ways; the journey kept the flip-cards
        // and the search and gained the "usually settled by now" group. The
        // four areas of growing are its Explore-by-area, one tap deeper.
        PpDoorTool(
          label: 'Where he is right now',
          blurb: 'His milestones as windows: usually settled by now, emerging '
              'now, and a soft look ahead. Never a score.',
          surfaceId: 'pp_milestones',
          icon: Icons.checklist_rtl_outlined,
        ),
        PpDoorTool(
          label: 'A gentle check-in',
          blurb: 'A few soft yes or not-yet questions for his age. No score, '
              'and it never says "all fine".',
          surfaceId: 'pp_dev_checkin',
          icon: Icons.spa_outlined,
        ),
      ],
      footer: 'A box you have not ticked is not one he has missed. One baby '
          'is not a range.',
    ),
    PpDoorTab(
      id: 'when_will',
      label: 'When will my baby...',
      icon: Icons.directions_walk_outlined,
      hue: 206,
      areaIds: ['when_will'],
      toMonths: 24,
    ),
    PpDoorTab(
      id: 'talking',
      label: 'Talking',
      icon: Icons.chat_bubble_outline_rounded,
      hue: 268,
      areaIds: ['speech_language'],
    ),
    PpDoorTab(
      id: 'what_to_do',
      label: 'What to do',
      icon: Icons.toys_outlined,
      hue: 28,
      areaIds: ['help_develop', 'feelings_play'],
      tools: [
        // ⚠️ MERGED IN. The hub (`pp_development`) is today's pick plus the
        // activities by age and by area, and it was a second front door that
        // never met the reassurance pages. Here it is one card beside them.
        PpDoorTool(
          label: 'Things to do together today',
          blurb: 'Today\'s pick and every activity, matched to his age and to '
              'each area of growing.',
          surfaceId: 'pp_development',
          icon: Icons.toys_outlined,
        ),
      ],
    ),
    PpDoorTab(
      id: 'leaps',
      label: 'The leaps',
      icon: Icons.auto_awesome_outlined,
      hue: 296,
      areaIds: [],
      toMonths: 20,
      tools: [
        // ⚠️ THE HONESTY REFRAME. The calendar used to print his own dates
        // ("3 Oct to 27 Oct") and "he is in Phase 4 right now"; it now says
        // "around 4 to 6 months, give or take" and "may be in", with the
        // caveat in the header rather than the footer. The ten names, the
        // sunny side and the nazar line are untouched.
        PpDoorTool(
          label: 'Your baby\'s phase calendar',
          blurb: 'The ten fussy-then-forward phases, held as a way to think '
              'about it, not a rule.',
          surfaceId: 'pp_leaps',
          icon: Icons.auto_awesome_outlined,
        ),
      ],
      note: 'Which fussy-then-forward phase he may be in now. Every baby\'s '
          'timing is his own, so this is a lens and never a law.',
    ),
    PpDoorTab(
      id: 'talk',
      label: 'Talk and check',
      icon: Icons.forum_outlined,
      hue: 128,
      areaIds: [],
      tools: [
        // The one What Changed flow, shared with Health and Behaviour.
        PpDoorTool(
          label: 'Something has changed',
          blurb: 'Babbling gone quiet, suddenly shy. Work through what changed, '
              'calmly.',
          surfaceId: 'pp_what_changed',
          icon: Icons.change_circle_outlined,
        ),
        // "Talk to a specialist" is the door's closing, drawn under every
        // tab including this one; a second card for it here would be the
        // same thing twice on the tab the brief puts it on.
      ],
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to a specialist',
    blurb: 'A second, reassuring opinion if something feels off track. '
        'Booking is mock for now.',
    surfaceId: 'pp_experts/Development expert',
  ),
);
