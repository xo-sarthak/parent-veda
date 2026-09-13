// =============================================================================
//  The First 40 Days door — jaapa, one day at a time, for him and for her
// -----------------------------------------------------------------------------
//  The content is `kPpFirst40Section` (`pp_first40_content.dart`), rebuilt to
//  `First_40_Days_Prompt.pdf`. The brief's own call is "treat it like Sleep,
//  Feeding and Behaviour: keep the ten areas plus the tools row, do not force
//  it into five tabs"; the user's standing call is that every parenting door
//  wears the shell, so the ten areas sit on five tabs:
//
//    Din by din                 the day-by-day spine, the husband, the ceremonies
//    When to rush               the go-now list second, on purpose; the quick check
//    Maa ki dekhbhaal           her recovery, THIRD, on the brief's lean
//    Samjho your newborn        every strange thing he does; malish, jhula, soothing
//    Feeding, sleep and the rest  the early feeds, the course, the essentials, Ask Veda
//
//  ⚠️ THE MOTHER IS THIRD, NOT SEVENTH. "A whole area is her recovery,
//  sitting alongside the baby areas because in these weeks nobody in the
//  house asks how she is." The brief's judgement call 2: lift her area up,
//  right after the two baby-emergency areas. Done by the tab order.
//
//  ⚠️ NO RED STRIP AND NO CLOSING OFFER, BOTH DELIBERATE. "No red strip on
//  the front, so people do not learn to scroll past it"; "no closing 'book
//  someone' footer under exhaustion content (the lactation and doctor
//  consults instead fire on the pages where the need is real)". So the
//  go-now list is the first card of its tab, not a pinned strip, and this
//  door has no `closing`.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpFirst40Door = PpDoor(
  sectionId: 'parenting_first_40',
  // Unsplash, free. A newborn's feet, tiny, in a white wrap: the first
  // weeks, and no sleep position in the frame for the safe-sleep page to
  // argue with (most "sleeping newborn" photographs show a side or a front).
  heroImageUrl:
      'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'din_by_din',
      label: 'Din by din',
      icon: Icons.calendar_today_outlined,
      hue: 26,
      areaIds: ['din_by_din'],
      note: 'Only this tab changes with the day. Everything else on the door '
          'is written for the whole forty days and stays put.',
    ),
    PpDoorTab(
      id: 'rush',
      label: 'When to rush',
      icon: Icons.emergency_outlined,
      hue: 12,
      areaIds: ['rush_to_doctor', 'baby_ok'],
      // ⚠️ NO TOOL CARD FOR THE QUICK CHECK. The brief's tools rail names
      // `pp_baby_ok_check`, and the Is My Baby OK? area's own first page
      // ("The quick daily check") opens that tool; a Tool card beside it
      // would be the same thing twice on one tab. Same for Ask Veda on the
      // last tab: the "Ask anything, at any hour" page is its card.
    ),
    PpDoorTab(
      id: 'maa',
      label: 'Maa ki dekhbhaal',
      icon: Icons.favorite_border_rounded,
      hue: 344,
      areaIds: ['maa_ki_dekhbhaal'],
      footer: 'Rest is treatment, not laziness. You do not need to enjoy '
          'this week.',
    ),
    PpDoorTab(
      id: 'samjho',
      label: 'Samjho your newborn',
      icon: Icons.child_care_outlined,
      hue: 44,
      areaIds: ['samjho', 'malish_jhula'],
    ),
    PpDoorTab(
      id: 'feeding_rest',
      label: 'Feeding, sleep and the rest',
      icon: Icons.nightlight_outlined,
      hue: 206,
      areaIds: ['feeding_sleep_early', 'puchho', 'jaapa_course', 'jaapa_essentials'],
      tools: [
        PpDoorTool(
          label: 'Log his feeds',
          blurb: 'The shared feeding journey: every feed, both sides, and '
              'the pattern it makes.',
          surfaceId: 'pp_feeding',
          icon: Icons.water_drop_outlined,
        ),
        PpDoorTool(
          label: 'Weight, and his own curve',
          blurb: 'The shared growth journey. Is he getting enough, answered '
              'by the scale.',
          surfaceId: 'pp_growth',
          icon: Icons.show_chart_outlined,
        ),
      ],
    ),
  ],
  // No closing, on purpose. See the header.
  closing: null,
);
