// =============================================================================
//  The Feeding door — eight collections and six tools on five tabs
// -----------------------------------------------------------------------------
//  The content is `kPpFeedingSection` (`pp_feeding_content.dart`), rebuilt to
//  `ParentVeda_Feeding_rebuild.pdf`. This file is how it is laid over the
//  door shell — same shell as Sleep, same rules: always a rail, tools lead
//  the first rail, the red flag pinned above.
//
//  ⚠️ THE GROUPING. The brief's collections are the section's areas; the
//  selector draws five cards:
//
//    · Milk feeds        — the breast and the bottle, which are one stage of
//                          his life with two rails.
//    · Starting solids   — its own tab, with the two tools that answer "can
//                          he, and how much" leading its rail.
//    · Cooking for him   — the kitchen, and the Recipes tool.
//    · Growing well      — weight gain and "not eating", which are the same
//                          worry from two ends, and the Growth tool.
//    · Keeping it safe   — choking, allergy, water, iron, vitamin D.
//
//  ⚠️ THE MERGED COLLECTION IS HIDDEN ON PURPOSE. "What to feed at this age"
//  is a tool now (`pp_food_chart`), and its pages are that tool's data. It is
//  named in `hiddenAreaIds` so the door test can tell a merged area from a
//  forgotten one.
//
//  ⚠️ TWO RED FLAGS, ONE PER TAB THAT HAS ONE. Mastitis with fever on Milk
//  (the brief's "same-day red-flag"), and "If he chokes: what to do" on Safe
//  — the brief's most important safety fix on the parenting side, and the
//  page a frightened parent must not have to find.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpFeedingDoor = PpDoor(
  sectionId: 'parenting_feeding',
  // NHN, Unsplash. A toddler upright in a high chair with her own spoon and
  // a bowl on the table: the door's "setting up for solids" page in one
  // frame. Nothing propped, nothing round to choke on, nothing sweet.
  heroImageUrl:
      'https://images.unsplash.com/photo-1760267978902-b34c1cc0c0af?w=900&h=700&fit=crop',
  hiddenAreaIds: const ['age_charts'],
  tabs: const [
    PpDoorTab(
      id: 'milk',
      label: 'Milk feeds',
      icon: Icons.water_drop_outlined,
      hue: 206,
      areaIds: ['breastfeeding', 'formula'],
      redFlagPageId: 'bf_mastitis',
      tools: [
        // "Log his feeds = Feeding journey." One surface; no sponsor here.
        PpDoorTool(
          label: 'Log his feeds',
          blurb: 'A light record of feeds, bottles and solids, so a pattern '
              'can show itself. No scores, no streaks.',
          surfaceId: 'pp_feeding',
          icon: Icons.edit_note_outlined,
        ),
      ],
    ),
    PpDoorTab(
      id: 'solids',
      label: 'Starting solids',
      icon: Icons.restaurant_outlined,
      hue: 96,
      areaIds: ['starting_solids'],
      tools: [
        // The merged tool: his portions, a day of food, the signs, the swaps.
        PpDoorTool(
          label: 'What to feed at this age',
          blurb: 'His portions, a day of food, the signs he is getting '
              'enough, and regional swaps. Shown for his age.',
          surfaceId: 'pp_food_chart',
          icon: Icons.event_note_outlined,
        ),
        PpDoorTool(
          label: 'Can he eat this?',
          blurb: 'Type a food, get a straight answer for his age. Honey, cow '
              'milk, nuts, salt, the lot.',
          surfaceId: 'pp_baby_food_check',
          icon: Icons.search_outlined,
        ),
      ],
    ),
    PpDoorTab(
      id: 'cooking',
      label: 'Cooking for him',
      icon: Icons.soup_kitchen_outlined,
      hue: 44,
      areaIds: ['cooking'],
      tools: [
        // "Recipes for him = the Recipes tool." Recipe cards on the rail link
        // to it and never duplicate a recipe.
        PpDoorTool(
          label: 'Recipes for him',
          blurb: 'Every baby and toddler recipe in the app, filtered by age, '
              'texture and what you have in the kitchen.',
          surfaceId: 'pp_food',
          icon: Icons.restaurant_menu_outlined,
        ),
      ],
    ),
    PpDoorTab(
      id: 'growing',
      label: 'Growing well',
      icon: Icons.show_chart_outlined,
      hue: 12,
      areaIds: ['weight_gain', 'not_eating'],
      tools: [
        // "Track his growth = Growth journey, which also owns the growth
        // reads." The growth-chart page on the rail opens this too.
        PpDoorTool(
          label: 'Track his growth',
          blurb: 'Weight and height over time, plotted properly, so "is he '
              'too thin" has an actual answer.',
          surfaceId: 'pp_growth',
          icon: Icons.show_chart_outlined,
        ),
      ],
    ),
    PpDoorTab(
      id: 'safe',
      label: 'Keeping it safe',
      icon: Icons.shield_outlined,
      hue: 8,
      areaIds: ['safety'],
      redFlagPageId: 'safety_choking_response',
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to a lactation expert',
    blurb: 'Book a 1:1 on latch, supply, or the switch to solids.',
    surfaceId: 'pp_experts/Lactation expert',
  ),
);
