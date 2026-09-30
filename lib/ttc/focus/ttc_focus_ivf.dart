// =============================================================================
//  IVF & IUI — the focus page for this door
// -----------------------------------------------------------------------------
//  ⚠️ ONE FILE PER BRACKET. See `docs/TTC-DOOR-BUILD.md` §2 — the tile model and
//  the registry stay in `ttc_focus_data.dart`, only the content lives here, so
//  several doors can be built at once without colliding.
//
//  ---------------------------------------------------------------------------
//  ⚠️ TEN SECTIONS ON ONE SCROLL, NOT FIVE SUB-TABS
//  ---------------------------------------------------------------------------
//
//  The brief asked for a tab bar. Same answer as PCOS and for a sharper reason
//  here: the two questions people arrive at this door with are "is it time to
//  get help" and "what is this going to cost", and those would have been in
//  different tabs. Someone frightened enough to open a door called IVF should
//  not have to guess which fifth of it holds her question.
//
//  The tab names survive as section headings, which is the work they were
//  actually doing.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NO COMMERCE BEYOND THE CONSULT, AND THAT IS A DATA DECISION ALREADY MADE
//  ---------------------------------------------------------------------------
//
//  `ttc_brackets.dart` marks products `notApplicable` on this bracket with the
//  plainest reason in that file: "Not a fit (clinical)." So there is no product
//  tile here and no course upsell. The consult is a door because seeking a
//  specialist is the reason she opened this area — not because we are selling
//  one.
//
//  ⚠️ AND NO SUCCESS RATES ANYWHERE. Not in a tile title, not in a blurb, not
//  in a carousel slide. `test/ttc_clinical_review_test.dart` scans this file.
//  "How to read a clinic's success rate" is about reading someone ELSE'S
//  published number critically, which is the opposite of quoting one.
// =============================================================================

// Unused since the consult tiles name their offering (2026-09-27,
// relevance audit). Kept for revert:
// import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
import 'package:flutter/material.dart' show Icons;

import '../ttc_focus_data.dart';

// =============================================================================
//  "Starting treatment?" — the card at the top of this door (2026-09-26)
// -----------------------------------------------------------------------------
//  docs/TTC-TREATMENT-FLOW.md §2b and §3f: while no round is running, the top
//  of the IVF & IUI door carries one card, "Starting treatment? Tell us your
//  clinic's plan and we'll follow it with you", into the start flow. This is
//  the obvious place the user asked for. The door screen draws it above the
//  tabs for this bracket only (`TtcStartTreatmentCard`), and it goes the day a
//  round exists; the "Your round" and "Between rounds" panels that replace it
//  are B7, next pass. ORDER, NEVER STRUCTURE: no tab moves or disappears.
// =============================================================================

/// The surface the card opens: the round's start flow.
const String kTtcIvfTopCardSurface = 'ttc_treatment/start';

// -----------------------------------------------------------------------------
//  B7, built 2026-09-26: the card is one of four panels
//  (`TtcIvfRoundPanel`): "Starting treatment?" with no round, "Your round"
//  while one is open (its step, its next date, "See the whole plan"),
//  "Between rounds" after one closes (the negative-test read, the review
//  read, "Month after month" and "Start the next round"), and "Positive
//  test" with the way to Pregnancy.
//
//  ⚠️ AND WHILE A ROUND IS PLANNED OR RUNNING, THESE TWO TABS COME FIRST
//  (§3f). Order only: every tab stays on the rail. "Going through it" is what
//  a round asks of her; "Track" is where its dates live. This overrides the
//  door's "the first tab never moves" rule for the length of a round only, a
//  decision the flow doc makes explicitly; the age reorder waits until the
//  round closes (`ttcDoorOrderedGroups`).
// -----------------------------------------------------------------------------

/// The tabs that lead, in this order, while a round is planned or running.
const List<String> kTtcIvfRoundTabsFirst = ['going', 'track'];

const TtcFocusPage kTtcIvfFocus = TtcFocusPage(
  bracketId: 'ttc_infertility',

  // ⚠️ THE HUB'S HERO LINE, KEPT VERBATIM. The brief asks for it explicitly and
  // it is the best sentence in this part of the product — it names the feeling
  // without naming a diagnosis.
  intro: "When it's taking longer than expected. What the tests and treatments "
      'involve, what they cost, and who to talk to.',

  // WARNING: THE FILM CAME OFF THE TOP AND HAS NOWHERE ELSE TO GO. The brief
  // lists one film for this door -- "An IVF cycle, start to finish" -- and that
  // one is a tile in Understand. `ttc_infertility_intro` was a hero slot this
  // page invented, and it is not in the brief at any position. Kept commented
  // rather than deleted; if it is ever shot, it wants a tile in Understand
  // rather than the hero back.
  //
  // heroVideoSlot: 'ttc_infertility_intro',
  // heroVideoTitle: 'When waiting stops being the answer',

  // WARNING: A PLACEHOLDER PHOTOGRAPH, TO BE SWAPPED. Same shape as PCOS, which
  // is the structural reference for this door. The V3 field renders behind it,
  // so a dead connection gives the hero this page has always had.
  // Our own photograph (2026-09-27): generated to the door's brief, checked by
  // eye, mirrored to the R2 bucket. Kept for revert: the previous value.
  // heroImageUrl: 'https://images.unsplash.com/photo-1584515933487-779824d29309?w=900&h=700&fit=crop',
  heroImageUrl: 'https://pub-bfbc0773e60e4c5c851b535f08b384bc.r2.dev/ttc_door_ivf_iui.jpg',
  // The new door's headline, a sentence (TtcDoorScreen, 2026-09-26).
  heroTitle: 'Treatment, explained step by step.',
  heroBlurb: 'IUI and IVF are treatments, not a last resort. Here\'s what '
      'they involve, what they cost in India, and how to tell when it\'s '
      'time to ask for help.',

  // ---------------------------------------------------------------------------
  //  The selector rail — the brief's five, in the brief's order
  // ---------------------------------------------------------------------------
  //  WARNING: UNDERSTAND IS FIRST NOW, AND THAT REVERSES A DELIBERATE CHOICE.
  //  This page used to open on "Should I get help?" because somebody fourteen
  //  months in is not looking for an explanation of ICSI, and making her scroll
  //  past an education section to reach the only question she came with was the
  //  same mistake as putting it behind a tab.
  //
  //  The rail dissolves that objection rather than overruling it. All five tabs
  //  are on screen at once, so "Should I get help?" is one tap from the top
  //  whatever order they sit in -- she is not scrolling past anything. With the
  //  cost of a wrong default gone, the brief's own order wins.
  groups: [
    TtcFocusGroup(
        id: 'understand', mark: IntentMark.bookMark, tabMark: TtcTabMark.openBook,
        // Kept for revert (2026-09-28, explicit names): label: 'Understand',
        label: 'Understand treatment',
        icon: Icons.menu_book_outlined,
        hue: 206),
    TtcFocusGroup(
        id: 'help', mark: IntentMark.questionMark, tabMark: TtcTabMark.signpost,
        label: 'Should I get help?',
        icon: Icons.center_focus_weak_outlined,
        hue: 344),
    // Added 2026-09-26 (gap plan, P2). Beside "Should I get help?" because
    // age is the most common reason that question comes sooner.
    TtcFocusGroup(
        id: 'age', mark: IntentMark.nextStep, tabMark: TtcTabMark.bigSmallHearts,
        label: 'Age and second baby',
        icon: Icons.timelapse_outlined,
        hue: 104),
    TtcFocusGroup(
        id: 'money', mark: IntentMark.compareMark, tabMark: TtcTabMark.wallet,
        label: 'Money and clinics',
        icon: Icons.account_balance_wallet_outlined,
        hue: 42),
    TtcFocusGroup(
        id: 'going', mark: IntentMark.cuppedHands, tabMark: TtcTabMark.heartHand,
        // Kept for revert (2026-09-28, explicit names): label: 'Going through it',
        label: 'During a round',
        icon: Icons.favorite_border_rounded,
        hue: 268),
    TtcFocusGroup(
        // Kept for revert (2026-09-28, explicit names): label: 'Track',
        id: 'track', mark: IntentMark.calendarDay, tabMark: TtcTabMark.timelineDots, label: 'Track your round', icon: Icons.calendar_today_outlined,
        hue: 160),
  ],

  sections: [
    // -------------------------------------------------------------------------
    //  Should I get help? — FIRST, not third.
    // -------------------------------------------------------------------------
    //  ⚠️ THE BRIEF PUTS THIS SECOND, BEHIND "Understand". It is first here,
    //  and the reason is the one thing this door is for. Somebody who has been
    //  trying for fourteen months and is finally opening this area is not
    //  looking for an explanation of ICSI — she is trying to find out whether it
    //  is time. Making her scroll past an education section to reach the only
    //  question she came with is the same mistake as putting it behind a tab.
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'Is it time to get help?',
      heading: 'Should we get fertility help?',
      group: 'help',
      tiles: [
        // ⚠️ ONE NAME FOR ONE TOOL (2026-09-27, relevance audit). "Readiness"
        // read as IVF readiness; the screen asks whether it is worth talking
        // to someone yet, and Taking a while already calls it this.
        // Kept for revert (2026-09-27, relevance audit):
        //   title: 'Check my readiness',
        TtcToolTile(
          title: 'Should I seek fertility help?',
          id: 'ttc_tile_should_i_seek_fertility_help',
          blurb: "Six short questions. It tells you whether it's worth talking "
              'to a doctor. It never gives you a score or a prediction.',
          surfaceId: 'ttc_fertility_help',
        ),
        // ⚠️ A READ HERE AFTER ALL (2026-09-27, relevance audit). It was parked
        // on the old brief (see the foot of this file, "When to stop waiting
        // and ask"); the gap analysis checklist now puts "when it's time" in
        // this tab, and the tab had a tool and a person but nothing to read.
        TtcArticleTile(
          title: 'When to see a doctor',
          id: 'ttc_tile_when_to_see_a_doctor',
          blurb: 'The usual guideline, and the reasons not to wait.',
          readId: 'ttc_read_when_to_seek_help',
        ),
        // ⚠️ THE FERTILITY SPECIALIST, NOT THE CONSULTS SHELF (2026-09-27,
        // relevance audit). A Talk tile, because `openTtcFocusTile` resolves
        // an offering id only on Talk; a Booking tile with any action but the
        // shared one opens nothing.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcBookingTile(
        //   title: 'Speak to a fertility specialist',
        //   blurb: 'A 1:1 talk with someone who does this every day. Bring your '
        //       'dates and any results you have.',
        //   action: kTtcActConsult,
        // ),
        TtcTalkTile(
          title: 'Speak to a fertility specialist',
          id: 'ttc_tile_speak_to_a_fertility_specialist',
          blurb: 'A 1:1 talk with someone who does this every day. Bring your '
              'dates and any results you have.',
          action: 'ttc_consult_fertility',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Understand
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'What do the treatments involve?',
      group: 'understand',
      tiles: [
        // WARNING: THE FILM LEADS THIS SECTION, AHEAD OF THE ARTICLE. The
        // brief lists the article first and this is the one place it is
        // deliberately not followed -- asked for directly. It reads better
        // too: "what IUI and IVF involve" is the long answer, and a four
        // minute film is the right first offer to somebody who has just
        // arrived and does not yet know which of the two she is reading about.
        //
        // It is a coming-soon placeholder until the file lands, and a
        // placeholder in first position is a deliberate cost -- see the note
        // at the foot of this file.
        // Repointed to the written film with this exact title (2026-09-27,
        // relevance audit). Kept for revert:
        //   slotId: 'ttc_ivf_cycle_walkthrough',
        //   duration: '8 MIN',
        TtcVideoTile(
          title: 'An IVF cycle, start to finish',
          id: 'ttc_tile_an_ivf_cycle_start_to_finish',
          blurb: 'The whole month, explained step by step by a specialist.',
          slotId: 'ttc_vid_ivf_walkthrough',
          duration: '9 MIN',
        ),
        TtcArticleTile(
          title: 'What IUI and IVF involve',
          id: 'ttc_tile_what_iui_and_ivf_involve',
          blurb: 'Both treatments, step by step, in plain words.',
          readId: 'ttc_read_ivf_explained',
        ),
        TtcCarouselTile(
          title: 'IUI or IVF, and when to move from one to the other',
          id: 'ttc_tile_iui_or_ivf_and_when_to_move_from_one_to_the_other',
          blurb: 'Two different treatments, and the point where you might '
              'switch.',
          coverTitle: 'IUI or IVF?',
          coverBlurb: "They're not a weaker and a stronger version of the same "
              'thing.',
          coverHue: 206,
          cards: [
            TtcCarouselCard(
              title: 'IUI places prepared sperm directly into the uterus.',
              body: 'Fertilisation still happens inside your body, in the '
                  'usual place, by itself.',
            ),
            TtcCarouselCard(
              title: 'So IUI needs open tubes and fairly good sperm.',
              body: "It gives sperm a shorter trip. It can't get past a step "
                  "that's blocked.",
            ),
            TtcCarouselCard(
              title: 'IVF fertilises the egg outside the body.',
              body: 'Eggs are collected and put with sperm in a lab. Then an '
                  'embryo is placed back inside.',
            ),
            TtcCarouselCard(
              title: "That's why IVF works even when tubes are blocked.",
              body: 'It skips the tubes completely, instead of helping '
                  'anything through them.',
            ),
            TtcCarouselCard(
              title: 'IUI is cheaper and simpler, but works less often per '
                  'cycle.',
              body: "It's usually tried for a set number of cycles and then "
                  'reviewed, not kept going forever.',
            ),
            TtcCarouselCard(
              title: 'Agree on that number at the start.',
              body: 'How many IUI cycles before we think again? It\'s the most '
                  'useful question to settle early.',
            ),
          ],
          // Was 'Reviewed by Dr Ruchika Sood, IVF gynaecologist' (2026-09-26).
          reviewedBy: 'Reviewed by Dr Surbhi Sharma, IVF gynaecologist, Bloom IVF',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: "ICSI: when it's needed, and when it's just routine",
          title: 'ICSI: needed, or just routine?',
          id: 'ttc_tile_icsi_needed_or_just_routine',
          blurb: "One step inside IVF that's sometimes essential, and often "
              'charged for anyway.',
          readId: 'ttc_read_ivf_icsi',
        ),
      ],
    ),

    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'What will they test, and why?',
      heading: 'What will the clinic test, and why?',
      group: 'understand',
      tiles: [
        TtcArticleTile(
          title: 'What a fertility check involves',
          id: 'ttc_tile_what_a_fertility_check_involves',
          blurb: 'Every test usually ordered in a first round, and what each '
              'one is trying to find out.',
          readId: 'ttc_read_ivf_workup',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'His side of the tests',
          title: 'His test: the semen analysis',
          id: 'ttc_tile_his_test_the_semen_analysis',
          blurb: 'For what it costs, a semen analysis tells you more than any '
              "other test. It's also the one most often put off.",
          readId: 'ttc_read_semen_analysis',
        ),
      ],
    ),

    // Added 2026-09-26 (gap plan, P3). The words and first steps that come
    // before IVF: the glossary, the tablets, the scans that watch them work,
    // and the PCOS door's medicines piece named here rather than copied.
    TtcFocusSection(
      heading: 'What do the words and tablets mean?',
      group: 'understand',
      tiles: [
        TtcArticleTile(
          title: 'Words your clinic uses',
          id: 'ttc_tile_words_your_clinic_uses',
          blurb: 'AMH, HSG, ICSI and more, each in a line or two.',
          readId: 'ttc_read_clinic_glossary',
          keywords: ['glossary', 'AMH', 'HSG', 'beta'],
        ),
        TtcArticleTile(
          title: 'Ovulation tablets, in plain words',
          id: 'ttc_tile_ovulation_tablets_in_plain_words',
          blurb: 'What letrozole and clomiphene do, and what to watch for.',
          readId: 'ttc_read_ovulation_tablets',
          keywords: ['letrozole', 'clomiphene', 'clomid'],
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Follicle scans',
          title: 'Follicle scans: what the doctor looks for',
          id: 'ttc_tile_follicle_scans_what_the_doctor_looks_for',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'What the doctor is looking for, and what the numbers mean.',
          blurb: 'Why scans are done mid-cycle, what they show, and what the numbers mean.',
          readId: 'ttc_read_follicle_scans',
        ),
        // ⚠️ OFF THIS DOOR (2026-09-27, relevance audit). A second letrozole
        // read beside "Ovulation tablets", and PCOS-only in a general door.
        // It lives in the PCOS door. Kept for revert (2026-09-27, relevance
        // audit):
        // TtcArticleTile(
        //   title: 'Medicines for PCOS',
        //   blurb: 'From the PCOS door: what each one is for.',
        //   readId: 'ttc_read_pcos_meds',
        // ),
      ],
    ),

    // ⚠️ MOVED HERE FROM "Age and second baby" (2026-09-27, relevance audit).
    // Donor routes and surrogacy are not age topics, and the checklist puts
    // them under Understand. Facts only, as TTC-GAP-PLAN §7.6 decided.
    TtcFocusSection(
      heading: 'What about donor eggs, sperm or surrogacy?',
      group: 'understand',
      tiles: [
        TtcArticleTile(
          title: 'Donor eggs and sperm',
          id: 'ttc_tile_donor_eggs_and_sperm',
          blurb: 'Who can use them, and what the ART Act 2021 says.',
          readId: 'ttc_read_donor_eggs_sperm',
        ),
        TtcArticleTile(
          title: 'Surrogacy in India',
          id: 'ttc_tile_surrogacy_in_india',
          blurb: 'The 2021 law in plain words: who it is for, how it works.',
          readId: 'ttc_read_surrogacy_india',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Age and second baby (gap plan, 2026-09-26)
    // -------------------------------------------------------------------------
    //  ⚠️ DONOR ROUTES AND SURROGACY ARE FACTS ONLY, as the user decided
    //  (TTC-GAP-PLAN §7.6): what the ART Act 2021 and the Surrogacy Act 2021
    //  say, who they cover, and nothing that reads as a recommendation.
    TtcFocusSection(
      heading: 'Does age change things?',
      group: 'age',
      tiles: [
        // Lands on the age section of the read (2026-09-27, relevance
        // audit), not the top of a general piece.
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'How long it usually takes',
          title: 'How age changes how long trying takes',
          id: 'ttc_tile_how_age_changes_how_long_trying_takes',
          blurb: "What's normal at each age, and when it's time to ask for "
              'help.',
          readId: 'ttc_read_how_long_it_takes',
          atHeading: 'Does age change how long it takes?',
        ),
        TtcArticleTile(
          title: 'Trying after 35',
          id: 'ttc_tile_trying_after_35',
          blurb: "What changes, what doesn't, and when to see a doctor sooner.",
          readId: 'ttc_read_age_after_35',
        ),
        TtcArticleTile(
          title: 'Trying after 40',
          id: 'ttc_tile_trying_after_40',
          blurb: 'An honest look, and why seeing a doctor now helps.',
          readId: 'ttc_read_age_after_40',
        ),
        // ⚠️ MOVED TO ITS OWN SECTION BELOW (2026-09-27, relevance audit): a
        // second baby is not an age question. Kept for revert:
        // TtcArticleTile(
        //   title: 'Harder the second time?',
        //   blurb: 'Why it happens, what doctors check, and when to go.',
        //   readId: 'ttc_read_second_baby',
        // ),
      ],
    ),

    // Its own question (2026-09-27, relevance audit).
    TtcFocusSection(
      heading: 'What about a second baby?',
      group: 'age',
      tiles: [
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Harder the second time?',
          title: 'Why a second baby can take longer',
          id: 'ttc_tile_why_a_second_baby_can_take_longer',
          blurb: 'Why it happens, what doctors check, and when to go.',
          readId: 'ttc_read_second_baby',
        ),
      ],
    ),

    TtcFocusSection(
      // Retitled (2026-09-27, relevance audit): donor routes and surrogacy
      // moved to Understand, and egg freezing, the age answer, stays.
      // Kept for revert: heading: 'What are the other routes?',
      heading: 'Can I freeze my eggs?',
      group: 'age',
      tiles: [
        TtcArticleTile(
          title: 'Egg freezing in India',
          id: 'ttc_tile_egg_freezing_in_india',
          blurb: "What happens, what it costs, and what it can't promise.",
          readId: 'ttc_read_egg_freezing',
        ),
        // Moved to Understand, "What about donor eggs, sperm or
        // surrogacy?" (2026-09-27, relevance audit). Kept for revert:
        // TtcArticleTile(
        //   title: 'Donor eggs and sperm',
        //   blurb: 'Who can use them, and what the ART Act 2021 says.',
        //   readId: 'ttc_read_donor_eggs_sperm',
        // ),
        // TtcArticleTile(
        //   title: 'Surrogacy in India',
        //   blurb: 'The 2021 law in plain words: who it is for, how it works.',
        //   readId: 'ttc_read_surrogacy_india',
        // ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Money and clinics
    // -------------------------------------------------------------------------
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'What does this cost in India?',
      heading: 'What does treatment cost in India?',
      group: 'money',
      tiles: [
        TtcArticleTile(
          title: 'What IVF really costs in India',
          id: 'ttc_tile_what_ivf_really_costs_in_india',
          blurb: 'Real price ranges, with the date we checked them.',
          readId: 'ttc_read_ivf_costs',
        ),
        // WARNING: AN ARTICLE NOW, WHICH IS WHAT THE BRIEF ALWAYS SAID. It
        // shipped as six swipeable cards because there was no article written
        // for it. There is one now. A list of costs somebody is about to be
        // surprised by is not step-shaped — a reader comparing two quotes needs
        // to hold all of it at once rather than remember card four while
        // reading card five.
        TtcArticleTile(
          title: 'What a package leaves out',
          id: 'ttc_tile_what_a_package_leaves_out',
          blurb: "The price you're quoted is rarely the final one. What usually "
              'sits outside it, and the questions that let you compare two '
              'quotes.',
          readId: 'ttc_read_ivf_package',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'How do we choose a clinic?',
      group: 'money',
      tiles: [
        // ⚠️ AN ARTICLE NOW, AND THE CAROUSEL BELOW IT IS THE ONE IT
        // REPLACED — 2026-09-03.
        //
        // The six cards were right about what to ask and had nowhere to put
        // the reason. "Per transfer excludes every cycle that never reached
        // one" is true and is not enough: somebody comparing two clinics needs
        // to hold all six questions at once while looking at two numbers, and a
        // swipe deck can only ever show her one.
        //
        // ⚠️ AND THE SCOPE IS THE SAFETY. The article teaches the measures and
        // never applies them — no benchmark figure, no clinic named, no
        // personal chance, and every quantity relational rather than numeric,
        // because a number in an article becomes a target on a screenshot. See
        // the read's own header.
        TtcArticleTile(
          title: "How to read a clinic's success rate",
          id: 'ttc_tile_how_to_read_a_clinic_s_success_rate',
          blurb: 'Two clinics can quote very different numbers and both be '
              'telling the truth. What the number is counting is the part '
              'that matters.',
          readId: 'ttc_read_ivf_success_rates',
        ),
/*
        TtcCarouselTile(
          title: "How to read a clinic's success rate",
          blurb: 'The number on the hoarding is not the number you want.',
          coverTitle: "Reading a clinic's numbers",
          coverBlurb: 'Six questions that change what a figure means.',
          coverHue: 268,
          cards: [
            TtcCarouselCard(
              title: 'Ask: per cycle started, or per transfer?',
              body: 'Per transfer excludes every cycle that never reached one, '
                  'which makes the figure look much higher.',
            ),
            TtcCarouselCard(
              title: 'Ask: pregnancies, or live births?',
              body: 'A pregnancy rate counts positive tests. A live birth rate '
                  'counts babies. They are not close.',
            ),
            TtcCarouselCard(
              title: 'Ask: for which age group?',
              body: 'An overall figure is dominated by whichever ages the '
                  'clinic treats most. Ask for your own band.',
            ),
            TtcCarouselCard(
              title: 'Ask: over how many cycles?',
              body: 'A number from twenty cycles is not evidence. Ask how many '
                  'the figure is based on.',
            ),
            TtcCarouselCard(
              title: 'Ask: who is excluded?',
              body: 'A clinic that declines difficult cases will publish '
                  'better numbers while helping fewer people.',
            ),
            TtcCarouselCard(
              title: 'Then compare like with like, or not at all.',
              body: 'Two clinics quoting different measures cannot be compared. '
                  'The willingness to explain is itself the useful signal.',
            ),
          ],
          reviewedBy: 'Reviewed by Dr. Meera Krishnan, Fertility specialist',
        ),
*/
        TtcCarouselTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Questions to ask before you sign up',
          title: 'Questions to ask a clinic before you sign up',
          id: 'ttc_tile_questions_to_ask_before_you_sign_up',
          blurb: 'Eight things worth sorting out at the first appointment.',
          coverTitle: 'Before you sign',
          coverBlurb: 'Questions that are easier to ask now than later.',
          coverHue: 160,
          cards: [
            TtcCarouselCard(
              title: 'Who will I see at each visit?',
              body: "Seeing the same doctor matters. In busy centres it isn't "
                  'certain unless you ask.',
            ),
            TtcCarouselCard(
              title: "What's included, and what's charged separately?",
              body: 'Ask for it in writing. This question prevents most nasty '
                  'surprises.',
            ),
            TtcCarouselCard(
              title: 'How many cycles before we review the plan?',
              body: 'Agreeing on a number at the start stops a whole year '
                  'slipping by without a review.',
            ),
            TtcCarouselCard(
              title: "What's your approach to ICSI and add-ons?",
              body: 'A clinic with a reason will give it in a sentence.',
            ),
            TtcCarouselCard(
              title: 'How do you decide fresh or frozen transfer?',
              body: 'Freezing everything is often the safer choice, not a '
                  'setback.',
            ),
            TtcCarouselCard(
              title: 'Who do I call at night, and what number?',
              body: 'Ask before you need it. Every clinic has an answer.',
            ),
            TtcCarouselCard(
              title: 'Are you registered under the ART Act?',
              body: 'In India, clinics must be registered by law. It\'s fair '
                  'to check.',
            ),
            TtcCarouselCard(
              title: 'Can we have the plan in writing?',
              body: "It's not a challenge. It's how you'll remember it next "
                  'week.',
            ),
          ],
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Going through it
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'What will a cycle ask of me?',
      group: 'going',
      tiles: [
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: "The injections: what they're really like",
          title: 'What the IVF injections are really like',
          id: 'ttc_tile_what_the_ivf_injections_are_really_like',
          blurb: "What you'll be doing every evening for two weeks, and how it "
              'feels.',
          readId: 'ttc_read_ivf_injections',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'OHSS: when to call the clinic',
          title: 'OHSS, the one complication to know by name',
          id: 'ttc_tile_ohss_the_one_complication_to_know_by_name',
          blurb: 'The one complication worth knowing by name, and the signs '
              "that mean you shouldn't wait until morning.",
          readId: 'ttc_read_ivf_ohss',
        ),
        // Moved to "The wait, and after the result" (2026-09-27, relevance
        // audit). Kept for revert:
        // TtcVideoTile(
        //   title: 'Getting through the two-week wait',
        //   blurb: 'The hardest fortnight of the cycle, and what helps.',
        //   slotId: 'ttc_ivf_two_week_wait',
        //   duration: '6 MIN',
        // ),
      ],
    ),

    // ⚠️ THE ROUND, STEP BY STEP (launch walk, 2026-09-27). The twelve
    // treatment reads were reachable only from inside a running round and
    // from Learn, so someone reading up before her first round, most of this
    // door's visitors, could not find them here. Order: the order a round
    // runs in, then the wait and what comes after it.
    TtcFocusSection(
      heading: 'What happens at each step?',
      group: 'going',
      tiles: [
        TtcArticleTile(
          title: 'Your first visit: the baseline scan',
          id: 'ttc_tile_your_first_visit_the_baseline_scan',
          blurb: 'What the first scan of a round checks, and why it comes before any medicine.',
          readId: 'ttc_read_tx_baseline_scan',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Monitoring scans',
          title: 'Monitoring scans during IVF',
          id: 'ttc_tile_monitoring_scans_during_ivf',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'What the clinic is measuring every few days, and what the numbers mean.',
          blurb: 'Why you are at the clinic every few mornings, and why your dose keeps changing.',
          readId: 'ttc_read_tx_monitoring_scans',
        ),
        TtcArticleTile(
          title: 'The trigger injection',
          id: 'ttc_tile_the_trigger_injection',
          blurb: 'Why it is timed to the hour, and what to do if you are late.',
          readId: 'ttc_read_tx_trigger_shot',
        ),
        TtcArticleTile(
          title: 'IUI day',
          id: 'ttc_tile_iui_day',
          blurb: 'What happens on the day, how long it takes, and how it feels.',
          readId: 'ttc_read_tx_iui_day',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Day 1, day 3, day 5',
          title: 'Embryo day 1, day 3, day 5',
          id: 'ttc_tile_embryo_day_1_day_3_day_5',
          blurb: 'The words the lab uses about embryos, in plain words.',
          readId: 'ttc_read_tx_embryo_days',
        ),
        TtcArticleTile(
          title: 'Fresh or frozen transfer',
          id: 'ttc_tile_fresh_or_frozen_transfer',
          blurb: 'How clinics decide, and why frozen is common now.',
          readId: 'ttc_read_tx_fresh_or_frozen',
        ),
        TtcArticleTile(
          title: 'Frozen embryo transfer, step by step',
          id: 'ttc_tile_frozen_embryo_transfer_step_by_step',
          blurb: 'Estrogen, the lining scan, then the transfer.',
          readId: 'ttc_read_tx_frozen_transfer',
        ),
        TtcArticleTile(
          title: 'Transfer day, and the progesterone after',
          id: 'ttc_tile_transfer_day_and_the_progesterone_after',
          blurb: 'What happens on the day, and the medicine that comes next.',
          readId: 'ttc_read_tx_transfer_day',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'The wait, and after the result',
      group: 'going',
      tiles: [
        TtcArticleTile(
          title: 'The two-week wait after IVF or IUI',
          id: 'ttc_tile_the_two_week_wait_after_ivf_or_iui',
          blurb: 'What your body is doing, and why the medicines can feel like signs.',
          readId: 'ttc_read_tx_wait_after_treatment',
        ),
        // Moved here from "What will a cycle ask of me?" (2026-09-27,
        // relevance audit): it is about the wait.
        TtcVideoTile(
          title: 'Getting through the two-week wait',
          id: 'ttc_tile_getting_through_the_two_week_wait',
          blurb: 'The hardest fortnight of the cycle, and what helps.',
          slotId: 'ttc_ivf_two_week_wait',
          duration: '6 MIN',
        ),
        TtcArticleTile(
          title: 'The beta test',
          id: 'ttc_tile_the_beta_test',
          blurb: "What the blood test measures, and why it's sometimes repeated.",
          readId: 'ttc_read_tx_beta_test',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'When the test is negative',
          title: 'When the test is negative after treatment',
          id: 'ttc_tile_when_the_test_is_negative_after_treatment',
          blurb: 'The next few weeks, for your body and for the two of you.',
          readId: 'ttc_read_tx_negative_after_treatment',
        ),
        TtcArticleTile(
          title: 'Your review appointment',
          id: 'ttc_tile_your_review_appointment',
          blurb: 'The questions worth taking to the clinic after a round.',
          readId: 'ttc_read_tx_review_appointment',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'The things people are afraid to ask',
      group: 'going',
      tiles: [
        // WARNING: AN ARTICLE NOW, PER THE BRIEF. The honest answer has a
        // before, a during and an after, and somebody who is frightened wants
        // to find the paragraph that applies to her rather than swipe until it
        // arrives.
        TtcArticleTile(
          title: 'Is egg retrieval painful?',
          id: 'ttc_tile_is_egg_retrieval_painful',
          blurb: "What's done, what you're given for it, and how the days "
              'before and after really feel.',
          readId: 'ttc_read_ivf_retrieval',
        ),
        TtcMythTile(
          title: 'Does bed rest after transfer help?',
          id: 'ttc_tile_does_bed_rest_after_transfer_help',
          blurb: 'One of the most widely held beliefs in fertility care.',
          myth: 'I should stay in bed after an embryo transfer to help it '
              'implant.',
          fact: "Trials haven't found that bed rest makes a pregnancy more "
              'likely, and some found slightly worse results. Lying still '
              "isn't what keeps an embryo in place. Gentle, everyday activity "
              "is what's usually advised. Lying in bed for days is hard on "
              'your body and harder on your mind. Follow whatever your own '
              'clinic tells you.',
        ),
        // WARNING: AN ARTICLE NOW, AND THE MYTH FORMAT WAS THE WRONG ONE. A
        // myth card needs a false belief to correct, and there is no myth here
        // — "can I work through a cycle" is a real question whose real answer
        // is "usually yes, and here is what to plan for". Forcing it into two
        // panels meant inventing a wrong belief to knock down.
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Can I work through a cycle?',
          title: 'Can I work through an IVF cycle?',
          id: 'ttc_tile_can_i_work_through_an_ivf_cycle',
          blurb: 'Most people do. What it asks of your calendar, which days '
              'are hard to move, and how much you need to tell anyone.',
          readId: 'ttc_read_ivf_working',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Track — tools you use, not things you read
    // -------------------------------------------------------------------------
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: "Keep track of a cycle you're in",
      heading: 'Keep track of your treatment round',
      group: 'track',
      tiles: [
        TtcToolTile(
          title: 'Track this treatment cycle',
          id: 'ttc_tile_track_this_treatment_cycle',
          blurb: 'Trigger, egg collection, transfer and the wait. The dates '
              'your clinic gave you, all in one place.',
          surfaceId: 'ttc_treatment',
        ),
        TtcToolTile(
          title: 'Keep your reports together',
          id: 'ttc_tile_keep_your_reports_together',
          blurb: 'Every result and letter in one place, so your next '
              "appointment starts from what's already known.",
          surfaceId: 'ttc_records',
        ),
        // ⚠️ BACK ON THE DOOR (2026-09-27, relevance audit). Parked on the old
        // brief (see the foot of this file); the checklist names injection
        // times and reminders as the third thing someone mid-cycle tracks.
        TtcToolTile(
          title: 'Your medicines and timings',
          id: 'ttc_tile_your_medicines_and_timings',
          blurb: 'What to take and when, including the trigger time that '
              'really matters.',
          surfaceId: 'ttc_medication',
        ),
        // ⚠️ THE SAFETY TILE BELONGS IN *THIS* SECTION, NOT ONLY IN "GOING
        // THROUGH IT". OHSS has an article three sections up, which is the
        // right place to learn about it and the wrong place to find it at
        // eleven at night. Track is where someone mid-cycle actually is, so the
        // one thing that might need doing urgently has a door here too.
        //
        // The duplication is deliberate and it is the only duplicated tile on
        // the page.
        // ⚠️ SAYS WHAT IT COVERS AND OPENS ON THE SIGNS (2026-09-27,
        // relevance audit). The read is about OHSS only, so the title says
        // so rather than promising every reason to call.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcArticleTile(
        //   title: 'When to call the clinic',
        //   blurb: 'The signs that mean you should call now, not wait for the '
        //       'morning. Worth reading before you need it.',
        //   readId: 'ttc_read_ivf_ohss',
        // ),
        TtcArticleTile(
          title: 'OHSS: the signs to call about now',
          id: 'ttc_tile_ohss_the_signs_to_call_about_now',
          blurb: 'The signs that mean you should call now, not wait for the '
              'morning. Worth reading before you need it.',
          readId: 'ttc_read_ivf_ohss',
          atHeading: 'Which signs mean you should call now?',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  Parked, not deleted — four tiles the brief does not list
// -----------------------------------------------------------------------------
//  WARNING: PER CLAUDE.md, AND NONE OF THEM IS STRANDED. The instruction was to
//  follow the brief and not to put random things beside it, so these four came
//  off the page. Each was a reasonable addition and none of them was asked for.
//
//    · "Does a low AMH mean it is over?" — a myth card. The best of the four,
//      and the one most worth arguing back for: AMH is the number people
//      catastrophise about, and `ttc_tests_data.dart` already talks it down.
//    · "When to stop waiting and ask" — an article in the readiness group. The
//      brief wants that group to be the tool and a way to a person, nothing
//      else.
//    · "Your medicines and timings" and "Appointments" — both real tools, both
//      still reachable from the Tools hub, the records store and the precheck
//      flow. Removing them from this door strands nothing.
//
//  Restoring any of them is uncommenting it back into its section.
//
//  2026-09-27 (relevance audit): two of these are back on the door. The
//  when-to-see-a-doctor read sits in "Is it time to get help?" (as "When to
//  see a doctor"), and "Your medicines and timings" sits in Track. The gap
//  analysis checklist asks for both. The copies below stay as the record.
//
//         TtcMythTile(
//           title: 'Does a low AMH mean it is over?',
//           blurb: 'The most misread number in fertility care.',
//           myth: 'A low AMH means my eggs are bad and IVF will not work for me.',
//           fact: 'AMH estimates how MANY eggs are in reserve, not their quality '
//               'and not whether a pregnancy is possible. It helps a clinician '
//               'choose a protocol. People with low AMH conceive, and people '
//               'with high AMH sometimes do not — it is a count, not a verdict.',
//         ),
//
//         TtcArticleTile(
//           title: 'When to stop waiting and ask',
//           blurb: 'The points at which guidance says to look into it, rather '
//               'than give it more time.',
//           readId: 'ttc_read_when_to_seek_help',
//         ),
//
//         TtcToolTile(
//           title: 'Your medicines and timings',
//           blurb: 'What to take and when, including the trigger time that '
//               'genuinely matters.',
//           surfaceId: 'ttc_medication',
//         ),
//
//         TtcToolTile(
//           title: 'Appointments',
//           blurb: 'Monitoring scans arrive at short notice. This is where they '
//               'live.',
//           surfaceId: 'ttc_appointments',
//         ),
//
// =============================================================================

// =============================================================================
//  The three carousel and myth versions, parked
// -----------------------------------------------------------------------------
//  WARNING: PER CLAUDE.md, AND THE CONTENT IS NOT LOST TWICE. Each of these
//  three was rewritten as a full article rather than reformatted, so the
//  paragraphs below are not the same words in a different shape — they are the
//  earlier, shorter treatment. Kept so the two can be compared if the longer
//  form turns out to be worse.
//
//         TtcCarouselTile(
//           title: 'What a package leaves out',
//           blurb: 'The items that are usually quoted separately.',
//           coverTitle: 'What a package leaves out',
//           coverBlurb: 'The quote is rarely the total.',
//           coverHue: 42,
//           cards: [
//             TtcCarouselCard(
//               title: 'Medicines are frequently not included.',
//               body: 'Stimulation drugs are one of the largest single costs and '
//                   'vary with the dose you end up needing.',
//             ),
//             TtcCarouselCard(
//               title: 'Nor is ICSI, in many quotes.',
//               body: 'Ask whether it is included, and what in your results '
//                   'makes it necessary.',
//             ),
//             TtcCarouselCard(
//               title: 'Freezing has two costs.',
//               body: 'The freezing itself, and then annual storage. Ask what '
//                   'the yearly fee is and when it starts.',
//             ),
//             TtcCarouselCard(
//               title: 'A frozen transfer later is usually its own charge.',
//               body: 'So "one cycle" may mean the collection only, not the '
//                   'transfer that produces a pregnancy.',
//             ),
//             TtcCarouselCard(
//               title: 'Genetic testing of embryos is almost always extra.',
//               body: 'And it is optional in most situations. Ask what it would '
//                   'change for you before agreeing to it.',
//             ),
//             TtcCarouselCard(
//               title: 'Ask for the full list in writing.',
//               body: 'Every clinic can produce one. A clinic that will not is '
//                   'telling you something.',
//             ),
//           ],
//         ),
//
//         TtcCarouselTile(
//           title: 'Is egg retrieval painful?',
//           blurb: 'What the twenty minutes actually involves.',
//           coverTitle: 'Is egg retrieval painful?',
//           coverBlurb: 'The honest version, step by step.',
//           coverHue: 206,
//           cards: [
//             TtcCarouselCard(
//               title: 'You are sedated. You will not feel the procedure.',
//               body: 'In India this is usually short sedation or light general '
//                   'anaesthesia, arranged by the clinic.',
//             ),
//             TtcCarouselCard(
//               title: 'It takes about fifteen to twenty minutes.',
//               body: 'A fine needle is guided by ultrasound to draw fluid from '
//                   'each follicle. No incision is made.',
//             ),
//             TtcCarouselCard(
//               title: 'You will be asked not to eat beforehand.',
//               body: 'Usually from midnight. The clinic will give you a time — '
//                   'this one matters.',
//             ),
//             TtcCarouselCard(
//               title: 'Afterwards: cramping, and some spotting.',
//               body: 'Most people describe strong period pain for a day, eased '
//                   'by ordinary painkillers.',
//             ),
//             TtcCarouselCard(
//               title: 'You cannot drive, and you should not go alone.',
//               body: 'Take the day off and take someone with you. This is not '
//                   'optional after sedation.',
//             ),
//             TtcCarouselCard(
//               title: 'Call if pain worsens over the next few days.',
//               body: 'Increasing pain, swelling or fever after retrieval is '
//                   'what the clinic wants to hear about.',
//             ),
//           ],
//           reviewedBy: 'Reviewed by Dr. Meera Krishnan, Fertility specialist',
//         ),
//
//         TtcMythTile(
//           title: 'Can I work through a cycle?',
//           blurb: 'What the two weeks actually demand of a working week.',
//           myth: 'I will have to take the whole cycle off work.',
//           fact: 'Most people work through the stimulation phase. What it does '
//               'demand is several early-morning monitoring scans at short '
//               'notice, retrieval day off entirely because of the sedation, and '
//               'a quieter day or two after. Telling one person at work is '
//               'usually what makes the scan appointments survivable.',
//         ),
// =============================================================================
