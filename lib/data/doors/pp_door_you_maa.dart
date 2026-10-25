// =============================================================================
//  The You, Maa door — the one door in the parenting stage that is not about
//  the baby
// -----------------------------------------------------------------------------
//  The content is `kPpYouMaaSection` (`pp_you_maa_content.dart`, 98 pages,
//  the second-biggest section in the app), rebuilt to
//  `You_Parenting_Maa_rebuild.pdf`. Her bands measure HER time since birth
//  (`kPpPostpartumBands`), kept separate from the baby's on purpose. Ten
//  areas on five tabs, on the user's call (2026-09-13):
//
//    How are you today, Maa?   the triage pinned, then "I do not feel like myself"
//    Your body                 what is happening to it, and the pelvic floor
//    Moving and eating         moving again, have you eaten, the healing kitchen
//    The people in your house  and the mothers who are not the only one
//    Going back                locks until six weeks, which fixes the dead card
//
//  ⚠️ THE TRIAGE IS PINNED, AND THE FRIGHTENING-THOUGHTS ROUTE IS PINNED
//  ABOVE IT. "The 'read this one first' line for frightening thoughts stays
//  at the very top, one tap from the crisis helpline. Do not move it down."
//  So it wears the red-flag treatment above the rails on the landing tab: a
//  mother for whom something feels wrong meets it before anything else,
//  without choosing a door.
//
//  ⚠️ NO SCORED MOOD TRACKER. "The triage is the front door, not a scored
//  tool." And never the baby's symptom checker for her. The door has tools
//  now (the unscored check-in, the session for her week, Kegel Care, the
//  classes, the "Can I...?" lookup), and none of them scores her mood or
//  her body. Kegel Care keeps its own practice history, with no streaks.
//  (This said "NO TOOLS" until door 3's build, 2026-10-25.)
//
//  ⚠️ THE ONE HOME FOR HER RECOVERY (judgement call 1). First 40 Days' acute
//  pages and its breasts card are windows into this section's pages now;
//  Feeding's mastitis red flag links in. One copy, three doors.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../mind_mood_data.dart' show kCrisisHelplineName, kCrisisHelplineNumber;
import 'pp_door_data.dart';

//  ⚠️ DOOR 3 OF THE DOOR-BY-DOOR PASS (built 2026-10-25, from
//  `docs/pp-door-plans/03-you-maa.md`). What changed, and why:
//
//    · HOW ARE YOU TODAY OPENS AT EVERY AGE (M1), because the frightening-
//      thoughts route is pinned on it and must be the first thing she meets.
//      The tabs after it follow HER weeks since the birth.
//    · A SECOND CARD ON TODAY, "10 minutes for you today" (M1): one session
//      picked for her week. Not a tracker: nothing is scored or saved.
//    · YOUR BODY HAS ITS OWN RED FLAG (M3), and Body and Moving open on a
//      shelf for her week, in the look approved for Health (H2).
//    · AN EXPERT ON EVERY TAB (§6), after the first rail, never stacked
//      under the red route. The counsellor rows carry the free helpline as
//      their quiet line (M5).
//    · HER BANDS ARE IN WEEKS, ON HER YOUNGEST CHILD'S CLOCK (M2,
//      `kPpPostpartumBands`).

/// The free line under a counsellor row (M5): free help is named before a
/// paid one, everywhere on this door.
const String _kFreeLine =
    'Free, any hour: $kCrisisHelplineName on $kCrisisHelplineNumber.';

final PpDoor kPpYouMaaDoor = PpDoor(
  sectionId: 'parenting_maternal',
  aboutHer: true,
  // Plan §1, row by row. Today leads every band: the scary-thoughts route
  // is pinned there.
  tabOrder: const {
    'pp_0_6w': ['today', 'body', 'moving_eating', 'people', 'going_back'],
    'pp_6w_3m': ['today', 'moving_eating', 'body', 'people', 'going_back'],
    'pp_3_6m': ['today', 'moving_eating', 'going_back', 'body', 'people'],
    'pp_6m': ['today', 'going_back', 'moving_eating', 'body', 'people'],
  },
  // Unsplash, free. A woman by a window, quiet, holding a cup, no baby in
  // the frame: the one door that is about her. Nothing on it a page argues
  // with.
  heroImageUrl:
      'https://images.unsplash.com/photo-1630304678139-e041e0631ea2?w=900&h=700&fit=crop',
  tabs: const [
    PpDoorTab(
      id: 'today',
      label: 'How are you today?',
      icon: Icons.favorite_border_rounded,
      hue: 288,
      areaIds: ['how_are_you', 'your_mind'],
      redFlagPageId: 'you_route_scary',
      // The two-question check-in (gap analysis P2, 2026-10-07): no score,
      // nothing saved, the crisis path pinned. The triage stays above it.
      // The counsellor sits after the first rail, never under the red
      // route (the user's rule from Health, 2026-10-23).
      expert: PpDoorClosing(
        label: 'Talk to a perinatal counsellor',
        blurb: 'Not feeling like yourself? 1:1, on video.',
        surfaceId: 'pp_experts/Maternal mental health',
        note: _kFreeLine,
      ),
      tools: [
        PpDoorTool(
          label: 'How have you been?',
          blurb: 'Two questions about the last two weeks. No score, nothing saved.',
          surfaceId: 'pp_mood_check',
          icon: Icons.favorite_border_rounded,
        ),
        // M1. One card for every band; the router opens the session for
        // her week (`ppMaaTenMinutesTarget`): breathing before six weeks,
        // the Pelvic-Floor Daily Ten, the deep core, then strength. Not a
        // tracker: no score, nothing saved.
        PpDoorTool(
          label: '10 minutes for you today',
          blurb: 'One short session picked for your week. Nothing to log.',
          surfaceId: 'pp_maa_ten_minutes',
          icon: Icons.self_improvement_outlined,
        ),
      ],
      footer: 'Nothing here judges you, and nothing here will tell you that '
          'you are a danger to your baby.',
    ),
    PpDoorTab(
      id: 'body',
      label: 'Your body',
      icon: Icons.self_improvement_outlined,
      hue: 344,
      areaIds: ['your_body', 'pelvic_floor'],
      // M3. Today keeps its own route, so each tab has one red row.
      redFlagPageId: 'body_red_flags',
      // M3, at most six cards a shelf; the area rails carry the rest.
      ageRail: {
        'pp_0_6w': PpAgeRail('Right now for you', [
          'body_lochia', 'body_perineum', 'body_csection_early',
          'body_afterpains', 'body_breasts', 'body_after_bp',
        ]),
        'pp_6w_3m': PpAgeRail('Right now for you', [
          'body_scar_care', 'body_back_posture', 'body_contraception',
          'body_after_gdm', 'pf_leaks', 'body_constipation',
        ]),
        'pp_3_6m': PpAgeRail('Right now for you', [
          'body_diastasis', 'body_core_recovery', 'body_when_normal',
          'body_hair_fall', 'body_screening', 'body_thyroid',
        ]),
        'pp_6m': PpAgeRail('Right now for you', [
          'body_when_normal', 'body_energy', 'body_skin_settling',
          'body_hair_fall', 'body_thyroid', 'pf_sex_pain',
        ]),
      },
      expert: PpDoorClosing(
        label: 'See a gynaecologist',
        blurb: 'Something not healing right? 1:1, on video.',
        surfaceId: 'pp_experts/Gynecologist',
      ),
    ),
    PpDoorTab(
      id: 'moving_eating',
      label: 'Moving and eating',
      icon: Icons.restaurant_outlined,
      hue: 96,
      areaIds: ['movement', 'feeding_yourself', 'healing_kitchen', 'can_i_feeding'],
      // The pelvic-floor exercises live on Body; the shelf is how they reach
      // the tab she opens to move. One page, two ways in.
      ageRail: {
        'pp_0_6w': PpAgeRail('Your movement this week', [
          'pf_ex_breathing', 'move_first_weeks', 'move_walking',
          'move_bounce_back',
        ]),
        'pp_6w_3m': PpAgeRail('Your movement this week', [
          'move_six_week_check', 'pf_ex_kegels', 'move_core_reconnect',
          'move_after_csection', 'move_walking',
        ]),
        'pp_3_6m': PpAgeRail('Your movement this week', [
          'pf_ex_progression', 'pf_ex_connect', 'move_diastasis_training',
          'move_getting_stronger', 'move_running',
        ]),
        'pp_6m': PpAgeRail('Your movement this week', [
          'move_getting_stronger', 'pf_ex_functional', 'move_running',
          'move_diastasis_training',
        ]),
      },
      expert: PpDoorClosing(
        label: "See a women's health physio",
        blurb: 'Leaks, heaviness, a gap in your tummy? 1:1, on video.',
        surfaceId: 'pp_experts/Physiotherapist',
      ),
      tools: [
        PpDoorTool(
          label: 'Kegel Care',
          blurb: 'Your pelvic-floor practice, a few minutes a day.',
          surfaceId: 'pp_kegel',
          icon: Icons.self_improvement_outlined,
        ),
        // The after-check classes are labelled in the hub
        // (`kYogaAfterCheckIds`), and a direct link to one before six weeks
        // says so (the router).
        PpDoorTool(
          label: 'Classes for after birth',
          blurb: 'Gentle, recorded or live. The core classes wait for your '
              'six-week check.',
          surfaceId: 'pp_yoga',
          icon: Icons.play_circle_outline_rounded,
        ),
        // Replaces the `cani_search` card, now linkedOnly (§3).
        PpDoorTool(
          label: 'Can I eat or take this?',
          blurb: 'Chai, medicines, fasting, mehendi, travel: 330+ answers '
              'while feeding.',
          surfaceId: 'pp_maa_can_i',
          icon: Icons.search_rounded,
        ),
      ],
      footer: 'For your back, your mood and your sleep. Not for your weight, '
          'anywhere on this door.',
    ),
    PpDoorTab(
      id: 'people',
      label: 'The people in your house',
      icon: Icons.groups_outlined,
      hue: 28,
      areaIds: ['people_around_you', 'the_circle'],
      // A couples or family counsellor is owed (DOOR-CONTENT-OWED); the
      // perinatal counsellors see couples too.
      expert: PpDoorClosing(
        label: 'Talk it through with a counsellor',
        blurb: 'The house, the marriage, the advice. 1:1, on video.',
        surfaceId: 'pp_experts/Maternal mental health',
        note: _kFreeLine,
      ),
    ),
    PpDoorTab(
      id: 'going_back',
      label: 'Going back',
      icon: Icons.work_outline_rounded,
      hue: 186,
      areaIds: ['back_to_work'],
      expert: PpDoorClosing(
        label: 'Talk to a lactation expert',
        blurb: 'Pumping at work, or a plan for the switch? 1:1, on video.',
        surfaceId: 'pp_experts/Lactation expert',
      ),
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to an expert about your own recovery', // was 'Talk to someone...' (2026-10-23)
    blurb: 'A perinatal counsellor or psychologist, ranked by ParentVeda. '
        'For the part nobody in the house asks about.',
    surfaceId: 'pp_experts/Maternal mental health',
  ),
);
