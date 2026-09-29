// =============================================================================
//  Work, money and rights (pregnancy) — the door
// -----------------------------------------------------------------------------
//  Built 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "New section: Work, money and rights", P2: *"The practical
//  worries of pregnancy have Indian answers."* What to Expect's career and
//  money pieces are written for US law and US insurance; ours are written
//  for the Maternity Benefit Act, Indian insurance and Indian schemes.
//
//  Same shape as the other pregnancy doors (`pv_door_scans.dart` is the
//  benchmark, `pv_door_move.dart` the nearest model): a hero, tabs, rails of
//  guide cards, a closing line.
//
//  ---------------------------------------------------------------------------
//  THREE TABS
//  ---------------------------------------------------------------------------
//
//    1. Work              getting through the day, safety, telling work,
//                         planning leave
//    2. Leave and rights  the 26 weeks, other kinds of work, his leave,
//                         her rights
//    3. Money             the delivery bill, insurance, schemes, planning
//
//  ⚠️ NO PINNED RED FLAG. This is not a clinical door. Every read still ends
//  on an urgent callout (the pregnancy warning signs, and "don't let cost
//  delay care"), which is where that line belongs here.
//
//  ⚠️ NO TOOL SURFACES. The gap analysis asks for a fill-in budget sheet
//  ("Family goal setting workbook", "Budget categories"); that is a new tool
//  and is listed in the build report, not built here. The baby budget read
//  carries the method in words until it exists.
//
//  ⚠️ THE LEAVE AND MONEY TABS CARRY A STANDING NOTE, not a red flag: laws,
//  scheme amounts and prices change, and she should check with HR, the
//  insurer or the health centre before planning around them.
//
//  Hues are the app's own `V2BlockHues`: 26 peach, 268 violet, 104 sage.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import '../reads/read_images.dart' show readImageFor;
import 'pv_door_data.dart';

/// Tab ids. Constants for the reason `pv_door_scans.dart` gives: a typo in a
/// section's group renders it in no tab at all.
const String kWorkMoneyTabWork = 'work';
const String kWorkMoneyTabLeave = 'leave';
const String kWorkMoneyTabMoney = 'money';

final PvDoorPage kWorkMoneyDoor = PvDoorPage(
  bracketId: 'pregnancy_work_money',

  heroTitle: 'Work, money and your rights.',
  heroBlurb: 'Working while pregnant, your maternity leave, and what a baby '
      'costs in India.',

  // ⚠️ NOT LOOKED AT IN A HERO CROP BY THE AUTHOR OF THIS FILE. It is the
  // photograph the TTC read "Money before a baby" already ships (Indian
  // one-rupee coins, CC BY-SA 3.0, Wikimedia Commons, credited in
  // `kReadImageCredits`), chosen for subject: no person, no baby, no bump.
  // No other door wears it. Look at it on a phone before release.
  heroImageUrl: readImageFor('ttc_read_money_before_baby'),

  closingLine: 'Laws, schemes and prices change. Check the details with your '
      'HR team, your insurer or your health centre, and anything about your '
      'health with your doctor.',

  groups: [
    PvDoorGroup(
      id: kWorkMoneyTabWork,
      label: 'Work',
      mark: IntentMark.checkMark,
      icon: Icons.work_outline_rounded,
      hue: 26,
    ),
    PvDoorGroup(
      id: kWorkMoneyTabLeave,
      label: 'Leave and rights',
      mark: IntentMark.calendarDay,
      icon: Icons.event_available_outlined,
      hue: 268,
      note: 'Your company can give you more than the law, never less. Check '
          'what applies to you with your HR team.',
    ),
    PvDoorGroup(
      id: kWorkMoneyTabMoney,
      label: 'Money',
      mark: IntentMark.listMark,
      icon: Icons.account_balance_wallet_outlined,
      hue: 104,
      note: 'Prices and scheme amounts change. Ask for a written estimate, and '
          'check the latest details with your hospital, insurer or health '
          'centre.',
    ),
  ],

  sections: [
    // =========================================================================
    //  TAB 1 · Work
    // =========================================================================
    PvDoorSection(
      group: kWorkMoneyTabWork,
      heading: 'Getting through the day',
      tiles: [
        PvDoorGuideTile(
          title: 'Working while pregnant',
          blurb: 'Tiredness, the commute, sitting and standing.',
          readId: 'preg_work_read_working_while_pregnant',
        ),
        PvDoorGuideTile(
          title: 'Staying safe at work',
          blurb: 'Heat, chemicals, night shifts and lifting. Screens are fine.',
          readId: 'preg_work_read_safe_at_work',
        ),
        PvDoorGuideTile(
          title: 'Can I work from home?',
          blurb: 'How to ask, and what the law says after your leave.',
          readId: 'preg_work_read_working_while_pregnant',
          atHeading: 'Can I work from home?',
        ),
      ],
    ),
    PvDoorSection(
      group: kWorkMoneyTabWork,
      heading: 'Telling work, and planning your leave',
      tiles: [
        PvDoorGuideTile(
          title: "Telling your boss you're pregnant",
          blurb: 'When to tell, what to say, and what to ask.',
          readId: 'preg_work_read_telling_your_boss',
        ),
        PvDoorGuideTile(
          title: 'Planning your leave, and going back',
          blurb: 'When to stop, a calm handover, and coming back.',
          readId: 'preg_work_read_planning_leave',
        ),
      ],
    ),

    // =========================================================================
    //  TAB 2 · Leave and rights
    // =========================================================================
    PvDoorSection(
      group: kWorkMoneyTabLeave,
      heading: 'Your maternity leave',
      tiles: [
        PvDoorGuideTile(
          title: 'Maternity leave: your 26 weeks',
          blurb: 'What the Maternity Benefit Act gives, and who it covers.',
          readId: 'preg_work_read_maternity_leave',
        ),
        PvDoorGuideTile(
          title: 'Government, self-employed or informal work',
          blurb: 'Central government leave, ESIC, and help if you work for '
              'yourself.',
          readId: 'preg_work_read_government_informal',
        ),
        PvDoorGuideTile(
          title: 'Crèche, nursing breaks and work from home',
          blurb: 'What the Act gives you when you go back.',
          readId: 'preg_work_read_maternity_leave',
          atHeading: 'What else does the Act give me?',
        ),
      ],
    ),
    PvDoorSection(
      group: kWorkMoneyTabLeave,
      heading: 'His leave',
      tiles: [
        PvDoorGuideTile(
          title: 'His paternity leave',
          blurb: 'What fathers can get, and how to make the days count.',
          readId: 'preg_work_read_paternity_leave',
        ),
      ],
    ),
    PvDoorSection(
      group: kWorkMoneyTabLeave,
      heading: 'Your rights',
      tiles: [
        // Opens a read whose first section carries the myth block, as the
        // myth chip promises (`pv_door_scans_test.dart` holds it).
        PvDoorMythTile(
          title: 'Can I lose my job for being pregnant?',
          blurb: 'What the law protects, and where to get help.',
          readId: 'preg_work_read_your_rights',
        ),
        PvDoorGuideTile(
          title: 'Changing jobs while pregnant',
          blurb: 'The 80-day rule, and insurance at the new job.',
          readId: 'preg_work_read_your_rights',
          atHeading: 'Can I change jobs while pregnant?',
        ),
        PvDoorGuideTile(
          title: "If you're treated unfairly",
          blurb: 'Step by step, from HR to the Labour Commissioner.',
          readId: 'preg_work_read_your_rights',
          atHeading: "What should I do if I'm treated unfairly?",
        ),
      ],
    ),

    // =========================================================================
    //  TAB 3 · Money
    // =========================================================================
    PvDoorSection(
      group: kWorkMoneyTabMoney,
      heading: 'Paying for the birth',
      tiles: [
        PvDoorGuideTile(
          title: 'What a delivery may cost',
          blurb: 'Free in government hospitals, and a rough guide to private '
              'costs.',
          readId: 'preg_work_read_delivery_cost',
        ),
        PvDoorGuideTile(
          title: 'Does my insurance cover the birth?',
          blurb: 'Waiting periods, work policies and newborn cover.',
          readId: 'preg_work_read_insurance',
        ),
      ],
    ),
    PvDoorSection(
      group: kWorkMoneyTabMoney,
      heading: 'Help and planning',
      tiles: [
        PvDoorGuideTile(
          title: 'Government help for mothers',
          blurb: 'JSSK, JSY, PMMVY and Ayushman Bharat.',
          readId: 'preg_work_read_schemes',
        ),
        PvDoorGuideTile(
          title: 'Getting your money ready',
          blurb: 'A simple checklist for each stage of pregnancy.',
          readId: 'preg_work_read_money_plan',
        ),
        PvDoorGuideTile(
          title: 'A baby budget for the first year',
          blurb: 'What costs money, and what you can skip or borrow.',
          readId: 'preg_work_read_baby_budget',
        ),
      ],
    ),
  ],
);
