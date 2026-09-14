// =============================================================================
//  The Traditions door — the ceremonies, explained simply, and what to skip
// -----------------------------------------------------------------------------
//  The content is `kPpTraditionsSection` (`pp_traditions_content.dart`),
//  rebuilt to `Traditions_Parenting.pdf`, the last of the parenting briefs.
//  "The build for this one is unusually finished, so most of the work is the
//  editorial, not the plumbing." Eight areas on five tabs, on the user's
//  call (2026-09-14):
//
//    Coming up now        her stage's chart first, and how the date and name get chosen
//    Welcoming her home   chatti, namkaran, the cradle, the first outing
//    The first years      the first meal, hair, ears, the birthday, the letters
//    In every faith       Muslim, Christian, Sikh, Jain and Parsi welcomes, and interfaith
//    Small, safe, honest  the costs, keeping it small, the words, the not-safe customs, first festivals
//
//  ⚠️ ONLY THE FIRST TAB CHANGES WITH HER AGE. "Which ceremony is coming up
//  now?" is the one band-tagged area — four charts, one per stage — and it
//  opens the right one on its own; every other area is for every age and
//  shows in full. So no tab here ever locks or drops.
//
//  ⚠️ NO RED FLAG AND NO CLOSING. "The genuine flags live on the pages that
//  earn them, by design." "There is no 'book an expert' offer, and that is
//  right, not a gap. For this subject there is genuinely nobody to book."
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpTraditionsDoor = PpDoor(
  sectionId: 'parenting_traditional',
  // Unsplash, free. A family on the floor before a decorated wall, marigolds,
  // a toddler between the parents: a ceremony as this door describes them,
  // small and at home. Nothing on it a page argues with.
  heroImageUrl:
      'https://images.unsplash.com/photo-1730130596425-197566414dc4?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'coming_up',
      label: 'Coming up now',
      icon: Icons.event_outlined,
      hue: 32,
      areaIds: ['whats_now'],
      tools: [
        // The one naming tool, after the read on how families choose.
        PpDoorTool(
          label: 'Find a name',
          blurb: 'Names by meaning, origin, sound and letter, with a shortlist '
              'you and your partner can build together.',
          surfaceId: 'pp_names',
          icon: Icons.auto_awesome_outlined,
          afterPageId: 'how_name_chosen',
        ),
      ],
    ),
    PpDoorTab(
      id: 'welcome',
      label: 'Welcoming her home',
      icon: Icons.home_outlined,
      hue: 26,
      areaIds: ['welcome'],
    ),
    PpDoorTab(
      id: 'first_years',
      label: 'The first years',
      icon: Icons.cake_outlined,
      hue: 344,
      areaIds: ['first_meal', 'milestones'],
    ),
    PpDoorTab(
      id: 'faiths',
      label: 'In every faith',
      icon: Icons.diversity_2_outlined,
      hue: 206,
      areaIds: ['other_faiths'],
    ),
    PpDoorTab(
      id: 'small_safe',
      label: 'Small, safe and honest',
      icon: Icons.favorite_border_rounded,
      hue: 8,
      areaIds: ['keep_it_small', 'not_safe', 'first_festivals'],
      tools: [
        PpDoorTool(
          label: 'Dadi ke nuskhe, checked',
          blurb: 'The home remedies every family passes down, with an honest '
              'note on which ones are safe and which are not.',
          surfaceId: 'pp_nuskhe',
          icon: Icons.spa_outlined,
        ),
      ],
      footer: 'Small is complete. Nobody in the tradition is failing a child '
          'by keeping it modest.',
    ),
  ],
  // No closing, on purpose. See the header.
  closing: null,
);
