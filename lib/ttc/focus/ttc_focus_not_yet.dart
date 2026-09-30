// =============================================================================
//  Trying, but not pregnant yet? — the focus page for this door
// -----------------------------------------------------------------------------
//  Added 2026-09-26 from the TTC gap analysis (docs/TTC-GAP-PLAN.md §3 C, P2):
//  a door that GATHERS. Every tile here opens a read or a tool that already
//  lives in another door. What is new is the order: the pieces she needs
//  after some months of trying, in the order she tends to need them.
//
//  ⚠️ NOTHING IS COPIED. A read named here is the same read, by id, as in its
//  own door, so editing it there updates it here. That is also why this file
//  has no prose of its own beyond titles, blurbs and the hero.
//
//  ⚠️ NEVER A CHANCE, EVEN HERE. This is the door where the question of
//  chances sits closest to the surface, and where the clinical rule matters
//  most: no number attached to her, only when to ask and what a check involves.
//
//  ⚠️ NO HERO PHOTOGRAPH YET, AND THAT IS SAFE. `heroImageUrl` is null, so
//  the hero renders the drawn V3 field and the bracket's own mark. A photo is
//  owed (docs/DOOR-CONTENT-OWED.md, TTC section): never a body, never someone
//  crying.
//
//  Where it sits on the home (first after six months of trying) is the home's
//  job, not this file's.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

// Unused since the consult tiles name their offering (2026-09-27,
// relevance audit). Kept for revert:
// import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
import '../ttc_focus_data.dart';

const TtcFocusPage kTtcNotYetFocus = TtcFocusPage(
  bracketId: 'ttc_not_yet',

  intro: "When it's taking longer than you hoped. What's normal, and what to "
      'do next.',

  // Our own photograph (2026-09-27), checked by eye, mirrored to the R2 bucket.
  heroImageUrl: 'https://pub-bfbc0773e60e4c5c851b535f08b384bc.r2.dev/ttc_door_taking_a_while.jpg',
  heroTitle: 'Trying, but not pregnant yet?',
  heroBlurb: "It often takes longer than people expect, and that's common. "
      "Here's what's usual, when it's worth seeing a doctor, and what a first "
      'check involves.',

  // ---------------------------------------------------------------------------
  //  Five tabs, in the order the questions tend to come
  // ---------------------------------------------------------------------------
  //  ⚠️ TWO PINNED FLAGS, EACH THE READ'S OWN WORDS. "Is it time?" pins the
  //  reasons not to wait twelve months (age, irregular or painful periods, past
  //  pelvic infection, cancer treatment). "Getting through it" pins the
  //  low-mood callout, which carries the self-harm routing (Tele-MANAS, 112)
  //  and must never be trimmed.
  groups: [
    TtcFocusGroup(
      id: 'time', mark: IntentMark.compassMark, tabMark: TtcTabMark.clock,
      // Kept for revert (2026-09-28, explicit names): label: 'Is it time?',
      label: 'When to get help',
      icon: Icons.schedule_rounded,
      hue: 344,
      pinnedRedFlagReadIds: ['ttc_read_when_to_seek_help'],
    ),
    TtcFocusGroup(
        id: 'check', mark: IntentMark.reportPage, tabMark: TtcTabMark.vialReport,
        // Kept for revert (2026-09-28, explicit names; the old label wrapped
        // to three lines on the rail card): label: 'What a check involves',
        label: 'Fertility checks',
        icon: Icons.biotech_outlined,
        hue: 206),
    TtcFocusGroup(
        id: 'both', mark: IntentMark.spermMark, tabMark: TtcTabMark.twoFigures,
        label: 'Both of you',
        icon: Icons.people_outline_rounded,
        hue: 186),
    TtcFocusGroup(
        id: 'slow', mark: IntentMark.bodyMark, tabMark: TtcTabMark.windingPath,
        // Kept for revert (2026-09-28, explicit names): label: 'What can slow it',
        label: 'What slows conception',
        icon: Icons.hourglass_empty_rounded,
        hue: 104),
    TtcFocusGroup(
      id: 'through', mark: IntentMark.cuppedHands, tabMark: TtcTabMark.heartHand,
      // Kept for revert (2026-09-28, explicit names): label: 'Getting through it',
      label: 'Coping with the wait',
      icon: Icons.favorite_border_rounded,
      hue: 268,
      pinnedRedFlagReadIds: ['ttc_read_month_after_month'],
    ),
  ],

  sections: [
    // =========================================================================
    //  1 — Is it time?
    // =========================================================================
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'How long is usual?',
      heading: 'How long does trying usually take?',
      group: 'time',
      tiles: [
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'How long it usually takes',
          title: 'How long getting pregnant usually takes',
          id: 'ttc_tile_how_long_getting_pregnant_usually_takes',
          blurb: "What's normal, and what can slow it down.",
          readId: 'ttc_read_how_long_it_takes',
        ),
        TtcArticleTile(
          title: 'Trying after 35',
          id: 'ttc_tile_trying_after_35',
          blurb: 'Why the usual advice is to ask after six months.',
          readId: 'ttc_read_age_after_35',
        ),
      ],
    ),

    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'Should we see someone now?',
      heading: 'Should we see a doctor now?',
      group: 'time',
      tiles: [
        TtcToolTile(
          title: 'Should I seek fertility help?',
          id: 'ttc_tile_should_i_seek_fertility_help',
          blurb: 'A few short questions. No score and no prediction.',
          surfaceId: 'ttc_fertility_help',
        ),
        TtcArticleTile(
          title: 'When to see a doctor',
          id: 'ttc_tile_when_to_see_a_doctor',
          blurb: 'The usual guideline, and the reasons not to wait.',
          readId: 'ttc_read_when_to_seek_help',
        ),
        // The "When to see someone" film the checklist asks for (2026-09-27,
        // relevance audit). Written and chaptered, and was on no door.
        TtcVideoTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Is it time to see someone?',
          title: 'The twelve-month rule, and who should not wait',
          id: 'ttc_tile_is_it_time_to_see_someone',
          blurb: 'The twelve-month rule, and the situations where it does not '
              'apply.',
          slotId: 'ttc_vid_when_to_seek_help',
          duration: '5 MIN',
        ),
      ],
    ),

    // =========================================================================
    //  2 — What a check involves
    // =========================================================================
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'What will they test?',
      heading: 'What will a fertility check test?',
      group: 'check',
      tiles: [
        TtcArticleTile(
          title: 'What a first fertility check involves',
          id: 'ttc_tile_what_a_first_fertility_check_involves',
          blurb: 'Every test usually ordered, and what each one looks for.',
          readId: 'ttc_read_ivf_workup',
        ),
        TtcArticleTile(
          title: 'Words your clinic uses',
          id: 'ttc_tile_words_your_clinic_uses',
          blurb: 'AMH, HSG, ICSI and more, each in a line or two.',
          readId: 'ttc_read_clinic_glossary',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Who should we see first?',
      group: 'check',
      tiles: [
        // ⚠️ THE EXACT ANSWER, NOT THE BEFORE-TRYING READ (2026-09-27,
        // relevance audit). "Seeing a gynaecologist" is written for a visit
        // before you start trying, which is the wrong read for someone who
        // has tried for a year. This section answers the heading word for
        // word. Kept for revert (2026-09-27, relevance audit):
        // TtcArticleTile(
        //   title: 'Seeing a gynaecologist: what to ask',
        //   blurb: 'What to take along, and the questions that make it count.',
        //   readId: 'ttc_read_first_gyn_visit',
        // ),
        TtcArticleTile(
          title: 'Who to see first',
          id: 'ttc_tile_who_to_see_first',
          blurb: 'Usually a gynaecologist before a fertility clinic, and why '
              "that's a sensible order.",
          readId: 'ttc_read_when_to_seek_help',
          atHeading: 'Who should you see first?',
        ),
        // ⚠️ THE FERTILITY SPECIALIST, NOT THE CONSULTS SHELF (2026-09-27,
        // relevance audit). A Talk tile, because `openTtcFocusTile` resolves
        // an offering id only on Talk; a Booking tile with any action but the
        // shared one opens nothing.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcBookingTile(
        //   title: 'Talk to a fertility doctor',
        //   blurb: 'A private talk about your own dates and results.',
        //   action: kTtcActConsult,
        // ),
        TtcTalkTile(
          title: 'Talk to a fertility doctor',
          id: 'ttc_tile_talk_to_a_fertility_doctor',
          blurb: 'A private talk about your own dates and results.',
          action: 'ttc_consult_fertility',
        ),
      ],
    ),

    // =========================================================================
    //  3 — Both of you
    // =========================================================================
    //  ⚠️ HIS TAB, AT THE SAME SIZE AS EVERY OTHER. A male factor is part of
    //  the picture in about half of couples who take longer, and in this
    //  market the testing and the blame land on her first.
    TtcFocusSection(
      heading: 'Should he be tested too?',
      group: 'both',
      tiles: [
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'The case for testing early',
          title: 'The case for an early sperm test',
          id: 'ttc_tile_the_case_for_an_early_sperm_test',
          blurb: "One simple test that answers what months of waiting can't.",
          readId: 'ttc_read_case_for_testing',
        ),
        TtcArticleTile(
          title: 'What a semen analysis involves',
          id: 'ttc_tile_what_a_semen_analysis_involves',
          blurb: 'What is measured, and how to get a result worth having.',
          readId: 'ttc_read_semen_analysis',
        ),
        TtcArticleTile(
          title: 'Does his age matter?',
          id: 'ttc_tile_does_his_age_matter',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: "It changes more slowly than yours. Here's what changes.",
          blurb: 'His fertility changes more slowly with age than yours, and what does change.',
          readId: 'ttc_read_his_age',
        ),
      ],
    ),

    // =========================================================================
    //  4 — What can slow it
    // =========================================================================
    //  The overview and the four checked most often; the rest of the
    //  conditions live in Body and cycle, one tap away through the door tile.
    TtcFocusSection(
      heading: 'What can slow conception?',
      group: 'slow',
      tiles: [
        TtcArticleTile(
          title: 'Seven things that can slow conception',
          id: 'ttc_tile_seven_things_that_can_slow_conception',
          blurb: 'The common reasons it takes longer, calmly.',
          readId: 'ttc_read_slow_conception',
        ),
        TtcArticleTile(
          title: 'Your thyroid and the TSH test',
          id: 'ttc_tile_your_thyroid_and_the_tsh_test',
          blurb: 'A small gland, and the one test that checks it.',
          readId: 'ttc_read_thyroid_tsh',
        ),
        TtcArticleTile(
          title: 'High prolactin',
          id: 'ttc_tile_high_prolactin',
          blurb: 'Why it can stop ovulation, and why the fix is often simple.',
          readId: 'ttc_read_high_prolactin',
        ),
        TtcArticleTile(
          title: 'Endometriosis and trying',
          id: 'ttc_tile_endometriosis_and_trying',
          blurb: 'The signs worth taking to a doctor, and what it means.',
          readId: 'ttc_read_endometriosis',
        ),
        TtcArticleTile(
          title: 'Blocked tubes and the HSG test',
          id: 'ttc_tile_blocked_tubes_and_the_hsg_test',
          blurb: 'How the dye test works, and the options if they are blocked.',
          readId: 'ttc_read_blocked_tubes_hsg',
        ),
      ],
    ),

    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'Where are the other conditions?',
      heading: 'Where are fibroids, cysts and infections?',
      group: 'slow',
      tiles: [
        TtcDoorTile(
          title: 'Body and cycle',
          id: 'ttc_tile_body_and_cycle',
          blurb: 'Fibroids, cysts, infections and more, in their own door.',
          bracketId: 'ttc_body_cycle',
        ),
      ],
    ),

    // =========================================================================
    //  5 — Getting through it
    // =========================================================================
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'When it has been a long time',
      heading: 'When trying has taken a long time',
      group: 'through',
      tiles: [
        TtcArticleTile(
          title: "Coping when month after month doesn't work",
          id: 'ttc_tile_coping_when_month_after_month_doesn_t_work',
          blurb: 'How to look after each other, and where to get help.',
          readId: 'ttc_read_month_after_month',
        ),
        TtcArticleTile(
          title: 'When trying takes over your life',
          id: 'ttc_tile_when_trying_takes_over_your_life',
          blurb: 'How to notice, and how to give it a smaller place.',
          readId: 'ttc_read_trying_takes_over',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Where else can you find support?',
      group: 'through',
      tiles: [
        TtcDoorTile(
          title: 'Mind and body',
          id: 'ttc_tile_mind_and_body',
          blurb: 'Hard days, a few calm minutes, and someone to talk to.',
          bracketId: 'ttc_mind_body',
          // Lands on Hard days, the tab this link is about (2026-09-27).
          group: 'hard',
        ),
      ],
    ),
  ],
);
