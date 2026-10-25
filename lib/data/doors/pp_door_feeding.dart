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

//  ⚠️ DOOR 1 OF THE DOOR-BY-DOOR PASS (built 2026-10-25, from
//  `docs/pp-door-plans/01-feeding.md`). What changed, and why:
//
//    · THE TAB ORDER FOLLOWS HIS AGE (`tabOrder`, plan §2a). It used to open
//      on Milk feeds for everyone, so a toddler's parent met the newborn feed
//      timer, mastitis and twenty milk pages before any food.
//    · TOOLS HAVE AGES (`PpDoorTool.bands`, §2c). Outside his band a tool
//      waits in the band block it fits at the foot of the tab.
//    · STARTING SOLIDS PINS THE CHOKING RESPONSE TOO (§2e), and carries the
//      gagging carousel from Keeping it safe: a parent at the first spoon
//      should not have to find tab three.
//    · AN EXPERT ON EACH HELP TAB (D2), after the first rail; none on Safe.
//    · "GROWING WELL" IS "EATING AND GROWING" (D1): for a toddler "he won't
//      eat" is the first worry, and the old name hid it.

final PpDoor kPpFeedingDoor = PpDoor(
  sectionId: 'parenting_feeding',
  // NHN, Unsplash. A toddler upright in a high chair with her own spoon and
  // a bowl on the table: the door's "setting up for solids" page in one
  // frame. Nothing propped, nothing round to choke on, nothing sweet.
  heroImageUrl:
      'https://images.unsplash.com/photo-1760267978902-b34c1cc0c0af?w=900&h=700&fit=crop',
  hiddenAreaIds: const ['age_charts'],
  // Plan §2a, row by row. A tab the band has outgrown drops on its own (the
  // shell's rule): Starting solids for two and up. Tabs for later sit last.
  tabOrder: const {
    'milk': ['milk', 'growing', 'safe'],
    'first_foods': ['solids', 'milk', 'safe', 'cooking', 'growing'],
    'm8_12': ['solids', 'cooking', 'safe', 'milk', 'growing'],
    'tod': ['cooking', 'growing', 'safe', 'solids', 'milk'],
    'big': ['cooking', 'growing', 'safe', 'milk'],
  },
  tabs: const [
    PpDoorTab(
      id: 'milk',
      label: 'Milk feeds',
      icon: Icons.water_drop_outlined,
      hue: 206,
      areaIds: ['breastfeeding', 'formula'],
      // Pinned while the page is in his band: to two years, because it is
      // about her body while she may still be feeding.
      redFlagPageId: 'bf_mastitis',
      expert: PpDoorClosing(
        label: 'Talk to a lactation expert',
        blurb: 'Latch, supply, a feed that hurts. 1:1, on video.',
        surfaceId: 'pp_experts/Lactation expert',
      ),
      tools: [
        // The care logs (gap analysis P1, 2026-10-07): a timer for each side,
        // nappies, pumping and the last 7 days, each a Tool card here.
        // The timer leads now (plan §2c): it is the thing she does at 3am.
        PpDoorTool(
          label: 'Breastfeed timer',
          blurb: 'Tap left or right to start, tap again to pause. Saves the '
              'feed and remembers the last side.',
          surfaceId: 'pp_feed_timer',
          icon: Icons.timer_outlined,
          bands: ['milk', 'first_foods'],
        ),
        // "Log his feeds = Feeding journey." One surface; no sponsor here.
        PpDoorTool(
          label: 'Log a feed',
          blurb: 'A light record of feeds, bottles and solids, so a pattern '
              'can show itself. No scores, no streaks.',
          surfaceId: 'pp_feeding',
          icon: Icons.edit_note_outlined,
          bands: ['milk', 'first_foods', 'm8_12', 'tod'],
        ),
        // After "how often": is he getting enough? Count the nappies.
        PpDoorTool(
          label: 'Nappies',
          blurb: 'One tap at each change. Wet nappies are the clearest sign '
              'milk is going in.',
          surfaceId: 'pp_nappies',
          icon: Icons.baby_changing_station_outlined,
          afterPageId: 'bf_how_often',
          bands: ['milk'],
        ),
        PpDoorTool(
          label: 'Pumping',
          blurb: 'What you express, left and right, so whoever gives the '
              'bottle knows what there is.',
          surfaceId: 'pp_pump',
          icon: Icons.water_drop_outlined,
          afterPageId: 'bf_pumping',
          bands: ['milk', 'first_foods', 'm8_12'],
        ),
        PpDoorTool(
          label: 'The last 7 days',
          blurb: 'Feeds, sleep, nappies and pumping, day by day, and a '
              'summary for your doctor.',
          surfaceId: 'pp_care_history',
          icon: Icons.calendar_month_outlined,
          atEnd: true,
          bands: ['milk', 'first_foods', 'm8_12'],
        ),
      ],
    ),
    PpDoorTab(
      id: 'solids',
      label: 'Starting solids',
      icon: Icons.restaurant_outlined,
      hue: 96,
      areaIds: ['starting_solids'],
      // The first spoon and the first gag come together, so the response is
      // one tap from the first rail (plan §2e). The same page Safe pins.
      redFlagPageId: 'safety_choking_response',
      extraPageIds: ['safety_gagging'],
      expert: PpDoorClosing(
        label: 'Talk to a child nutritionist',
        blurb: 'First foods, how much, and what to do when he refuses. 1:1, '
            'on video.',
        surfaceId: 'pp_experts/Nutritionist',
      ),
      tools: [
        // The merged tool: his portions, a day of food, the signs, the swaps.
        PpDoorTool(
          label: 'What to feed at this age',
          blurb: 'His portions, a day of food, the signs he is getting '
              'enough, and regional swaps. Shown for his age.',
          surfaceId: 'pp_food_chart',
          icon: Icons.event_note_outlined,
          bands: ['first_foods', 'm8_12', 'tod', 'big'],
        ),
        PpDoorTool(
          label: 'Can my baby eat this?',
          blurb: 'Type a food, get a straight answer for his age. Honey, cow '
              'milk, nuts, salt, the lot.',
          surfaceId: 'pp_baby_food_check',
          icon: Icons.search_outlined,
          bands: ['first_foods', 'm8_12', 'tod', 'big'],
        ),
      ],
    ),
    PpDoorTab(
      id: 'cooking',
      label: 'Cooking for your child',
      icon: Icons.soup_kitchen_outlined,
      hue: 44,
      areaIds: ['cooking'],
      expert: PpDoorClosing(
        label: 'Talk to a child nutritionist',
        blurb: 'Meals he will eat, tiffins, and a plate that is enough. 1:1, '
            'on video.',
        surfaceId: 'pp_experts/Nutritionist',
      ),
      tools: [
        // ⚠️ THE SAME TWO TOOLS AS STARTING SOLIDS, FOR ONE AND UP (plan §2c).
        // From one Cooking is where he opens, and Starting solids sinks (or,
        // from two, is gone), so the questions "how much" and "can he eat
        // this" come here. Whole nuts and grapes stay a risk until five.
        PpDoorTool(
          label: 'What to feed at this age',
          blurb: 'His portions, a day of food, the signs he is getting '
              'enough, and regional swaps. Shown for his age.',
          surfaceId: 'pp_food_chart',
          icon: Icons.event_note_outlined,
          bands: ['tod', 'big'],
        ),
        PpDoorTool(
          label: 'Can my baby eat this?',
          blurb: 'Type a food, get a straight answer for his age. Honey, cow '
              'milk, nuts, salt, the lot.',
          surfaceId: 'pp_baby_food_check',
          icon: Icons.search_outlined,
          bands: ['tod', 'big'],
        ),
        // "Recipes for him = the Recipes tool." Recipe cards on the rail link
        // to it and never duplicate a recipe.
        PpDoorTool(
          label: 'Recipes by age',
          blurb: 'Every baby and toddler recipe in the app, filtered by age, '
              'texture and what you have in the kitchen.',
          surfaceId: 'pp_food',
          icon: Icons.restaurant_menu_outlined,
          bands: ['first_foods', 'm8_12', 'tod', 'big'],
        ),
      ],
    ),
    PpDoorTab(
      id: 'growing',
      // D1 (2026-10-23): it must read at a single glance. Kept for revert:
      // label: 'Growing well',
      label: 'Eating and growing',
      icon: Icons.show_chart_outlined,
      hue: 12,
      areaIds: ['weight_gain', 'not_eating'],
      expert: PpDoorClosing(
        label: 'Talk to a child nutritionist',
        blurb: "He won't eat, or his weight worries you. A plan without a "
            'fight. 1:1, on video.',
        surfaceId: 'pp_experts/Nutritionist',
      ),
      tools: [
        // "Track his growth = Growth journey, which also owns the growth
        // reads." The growth-chart page on the rail opens this too.
        PpDoorTool(
          label: 'Track growth',
          blurb: 'Weight and height over time, plotted properly, so "is he '
              'too thin" has an actual answer.',
          surfaceId: 'pp_growth',
          icon: Icons.show_chart_outlined,
        ),
      ],
    ),
    // No expert row here (D2): an urgent tab is not sold to.
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
