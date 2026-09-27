// =============================================================================
//  Body and cycle — the focus page for this door
// -----------------------------------------------------------------------------
//  Added 2026-09-26 from the TTC gap analysis (docs/TTC-GAP-PLAN.md §3 A, the
//  "Body and cycle" rows): late periods, bleeding and spotting, mid-cycle
//  pain, intimate health, and the conditions that can slow conception. About
//  120 competitor pieces had no home in the stage; the reads were written by
//  helpers W2, W3 and W4 and live in `lib/ttc/reads/ttc_reads_body_*.dart`.
//
//  ⚠️ DATA ONLY. The door renders through `TtcDoorScreen`, like the other
//  eight. Nothing here knows about widgets, and nothing in the door screen is
//  keyed on this bracket id.
//
//  ⚠️ NO HERO PHOTOGRAPH YET, AND THAT IS SAFE. `heroImageUrl` is null, so the
//  hero renders the drawn V3 field and the bracket's own mark, the same thing
//  every door shows offline. A photograph is owed (docs/DOOR-CONTENT-OWED.md,
//  TTC section): never a body, never someone in pain.
//
//  ⚠️ INTIMATE HEALTH IS NOT BEHIND THE SHARED-PHONE SWITCH. The switch hides
//  sex and intimacy (`kTtcIntimateReadIds`). Discharge, infections and washing
//  are health, and hiding them would hide the signs that need a doctor.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
import '../ttc_focus_data.dart';

const TtcFocusPage kTtcBodyCycleFocus = TtcFocusPage(
  bracketId: 'ttc_body_cycle',

  intro: 'Your cycle, your body, and the things worth getting checked.',

  // Our own photograph (2026-09-27), checked by eye, mirrored to the R2 bucket.
  heroImageUrl: 'https://pub-bfbc0773e60e4c5c851b535f08b384bc.r2.dev/ttc_door_body_cycle.jpg',
  heroTitle: 'What your body and cycle are telling you.',
  heroBlurb: 'Most changes in your cycle, bleeding or discharge are common '
      "and have a simple reason. Here's what each one usually means, and when "
      "it's worth seeing a doctor.",

  // ---------------------------------------------------------------------------
  //  Four tabs: the cycle first, the doctor last
  // ---------------------------------------------------------------------------
  //  Hues are the app's own (V2BlockHues): 344 the stage rose for the cycle,
  //  268 violet, 104 sage, 206 the clinical blue every doctor tab wears.
  //
  //  ⚠️ THE DOCTOR TAB PINS THE BLEEDING READ'S OWN CALLOUT ("Go today, or
  //  book a visit"). Bleeding is the sign in this door most likely to need
  //  someone today, and the words stay the read's, never retyped here.
  groups: [
    TtcFocusGroup(
        id: 'cycle', mark: IntentMark.cycleRing,
        label: 'Your cycle',
        icon: Icons.loop_rounded,
        hue: 344),
    TtcFocusGroup(
        id: 'intimate', mark: IntentMark.bodyMark,
        label: 'Intimate health',
        icon: Icons.spa_outlined,
        hue: 268),
    TtcFocusGroup(
        id: 'conditions', mark: IntentMark.reportPage,
        label: 'Other conditions',
        icon: Icons.biotech_outlined,
        hue: 104),
    TtcFocusGroup(
      id: 'doctor', mark: IntentMark.askDoctor,
      label: 'See a doctor',
      icon: Icons.medical_services_outlined,
      hue: 206,
      pinnedRedFlagReadIds: ['ttc_read_bleeding_kinds'],
    ),
  ],

  sections: [
    // =========================================================================
    //  1 — Your cycle
    // =========================================================================
    //  The two tools first, as on Fertile window: what she logs is what makes
    //  every read below easier to act on, and easier to show a doctor.
    TtcFocusSection(
      heading: 'How do you keep track of it?',
      group: 'cycle',
      tiles: [
        TtcToolTile(
          title: 'Your cycle',
          blurb: 'Log your period and see your own pattern build up.',
          surfaceId: 'ttc_cycle',
        ),
        TtcToolTile(
          title: 'Note how you feel',
          blurb: 'Pain, spotting, discharge. A record you can show a doctor.',
          surfaceId: 'ttc_symptom_log',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Is my cycle normal?',
      group: 'cycle',
      tiles: [
        TtcArticleTile(
          title: 'Is there such a thing as a normal cycle?',
          blurb: 'Why cycles differ, and when short or long is worth a check.',
          readId: 'ttc_read_normal_cycle',
        ),
        TtcArticleTile(
          title: 'What counts as a late period',
          blurb: 'The usual reasons, and what to do while you wait.',
          readId: 'ttc_read_late_period',
        ),
        TtcArticleTile(
          title: "Irregular cycles when it isn't PCOS",
          blurb: 'The other common reasons, and the first tests.',
          readId: 'ttc_read_irregular_not_pcos',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'What does this bleeding mean?',
      group: 'cycle',
      tiles: [
        TtcArticleTile(
          title: 'Five kinds of bleeding',
          blurb: 'How to tell them apart, side by side.',
          readId: 'ttc_read_bleeding_kinds',
        ),
        TtcArticleTile(
          title: 'Spotting between periods',
          blurb: 'What each colour usually means, and when to get it checked.',
          readId: 'ttc_read_spotting',
        ),
        TtcArticleTile(
          title: 'Heavy, light or long periods',
          blurb: 'What counts as heavy, and what to do before pregnancy.',
          readId: 'ttc_read_heavy_flow',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Is this pain usual?',
      group: 'cycle',
      tiles: [
        TtcArticleTile(
          title: 'Ovulation pain',
          blurb: 'The mid-cycle twinge, and the other signs around it.',
          readId: 'ttc_read_ovulation_pain',
        ),
        TtcArticleTile(
          title: 'Period pain',
          blurb: "How much is usual, what helps, and when it isn't.",
          readId: 'ttc_read_period_pain',
        ),
      ],
    ),

    // =========================================================================
    //  2 — Intimate health
    // =========================================================================
    TtcFocusSection(
      heading: 'Is this normal down there?',
      group: 'intimate',
      tiles: [
        TtcArticleTile(
          title: 'Is my discharge normal?',
          blurb: 'What each kind means, and the changes that need a doctor.',
          readId: 'ttc_read_discharge_guide',
        ),
        TtcArticleTile(
          title: 'How to clean down there',
          blurb: 'Water, not products. What your body already does for itself.',
          readId: 'ttc_read_intimate_washing',
        ),
        TtcArticleTile(
          title: 'Itching, smells and bumps',
          blurb: "The worries many women keep to themselves, and what's common.",
          readId: 'ttc_read_intimate_worries',
        ),
      ],
    ),

    TtcFocusSection(
      heading: "What if it's an infection?",
      group: 'intimate',
      tiles: [
        TtcArticleTile(
          title: 'Yeast infections and BV',
          blurb: "What they are, and what's safe while you're trying.",
          readId: 'ttc_read_yeast_bv',
        ),
        TtcArticleTile(
          title: 'Urine infections while trying',
          blurb: 'Why a busy week can bring them on, and what to do.',
          readId: 'ttc_read_uti_trying',
        ),
        TtcArticleTile(
          title: 'A quick infection test before trying',
          blurb: 'Some cause no signs at all. Which ones matter, and how to check.',
          readId: 'ttc_read_sti_testing',
        ),
      ],
    ),

    // =========================================================================
    //  3 — Other conditions
    // =========================================================================
    //  The overview first: "Seven things that can slow conception" is the map,
    //  and each piece after it is one of the places on it.
    TtcFocusSection(
      heading: 'What can slow things down?',
      group: 'conditions',
      tiles: [
        TtcArticleTile(
          title: 'Seven things that can slow conception',
          blurb: 'The common reasons it takes longer, calmly.',
          readId: 'ttc_read_slow_conception',
        ),
        TtcArticleTile(
          title: 'Your thyroid and the TSH test',
          blurb: 'A small gland, and the one test that checks it.',
          readId: 'ttc_read_thyroid_tsh',
          keywords: ['TSH', 'hypothyroid'],
        ),
        TtcArticleTile(
          title: 'High prolactin',
          blurb: 'Why it can stop ovulation, and why the fix is often simple.',
          readId: 'ttc_read_high_prolactin',
        ),
        TtcArticleTile(
          title: 'Endometriosis and trying',
          blurb: "The signs worth taking to a doctor, and what it means.",
          readId: 'ttc_read_endometriosis',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'What might a scan or test find?',
      group: 'conditions',
      tiles: [
        TtcArticleTile(
          title: 'Fibroids and polyps',
          blurb: "Which ones matter when you're trying.",
          readId: 'ttc_read_fibroids_polyps',
        ),
        TtcArticleTile(
          title: 'Ovarian cysts',
          blurb: "What 'cyst' on a scan report usually means.",
          readId: 'ttc_read_ovarian_cysts',
        ),
        TtcArticleTile(
          title: 'Blocked tubes and the HSG test',
          blurb: 'How the dye test works, and the options if they are blocked.',
          readId: 'ttc_read_blocked_tubes_hsg',
          keywords: ['HSG', 'tubes'],
        ),
        TtcArticleTile(
          title: 'Pelvic infections (PID)',
          blurb: 'Why quick treatment protects your tubes.',
          readId: 'ttc_read_pelvic_infection',
        ),
        TtcArticleTile(
          title: 'Genital TB',
          blurb: 'Why it matters in India, and why it is easy to miss.',
          readId: 'ttc_read_genital_tb',
          keywords: ['tuberculosis'],
        ),
      ],
    ),

    // =========================================================================
    //  4 — See a doctor (the pinned flag is on the group, above)
    // =========================================================================
    //  ⚠️ THE DOOR CLOSES ON A PERSON, the rule every TTC door keeps. The
    //  booking is the shared consult action, never a new booking flow.
    TtcFocusSection(
      heading: 'When is it worth a visit?',
      group: 'doctor',
      tiles: [
        TtcArticleTile(
          title: 'Seeing a gynaecologist: what to ask',
          blurb: 'What to take along, and the questions that make it count.',
          readId: 'ttc_read_first_gyn_visit',
        ),
        TtcArticleTile(
          title: 'Trying for many months?',
          blurb: 'How long is usual before asking for help.',
          readId: 'ttc_read_when_to_seek_help',
        ),
        TtcBookingTile(
          title: 'Talk to a doctor',
          blurb: 'A private video consultation about your own cycle.',
          action: kTtcActConsult,
        ),
      ],
    ),
  ],
);
