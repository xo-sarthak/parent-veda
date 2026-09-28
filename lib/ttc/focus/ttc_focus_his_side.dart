// =============================================================================
//  His side — the focus page for this door
// -----------------------------------------------------------------------------
//  Built 2026-09-04 from `his_side_rebuild.pdf`; brought back to the brief on
//  2026-09-06. Fifth door on the shape PCOS, IVF and Getting ready
//  established.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THIS IS THE STRONGEST CONTENT IN THE STAGE AND THE REBUILD MUST NOT
//  DILUTE IT
//  ---------------------------------------------------------------------------
//
//  The brief says so plainly, and it is right: three long doctor-authored
//  articles, WHO 2021 figures, and India specifics — gutka and khaini named
//  rather than "tobacco", real INR costs — that almost nothing else in this
//  category carries.
//
//  So the three originals are REUSED UNTOUCHED, and every other piece the
//  brief names is WRITTEN. The first build substituted the nearest existing
//  article for three of them; the rule that replaced that is below.
//
//  ---------------------------------------------------------------------------
//  ⚠️ REUSE ONLY WHAT IS THE THING. DO NOT REUSE THE CLOSEST THING — 2026-09-06
//  ---------------------------------------------------------------------------
//
//  The user's own words, paraphrased only slightly: *reuse when what exists is
//  exactly what is needed, or can be made so with a small change. Never pick
//  the nearest thing and put it there because it sounds like what the brief
//  asked for.* A tile titled "What three months looks like" that opened the
//  heat-and-habits essay was the failure — the reader was promised a plan and
//  handed an argument with a plan in section five.
//
//  So: three reads written (`ttc_read_case_for_testing`,
//  `ttc_read_three_months`, `ttc_read_zinc_coq10`); the tracker tile opens HIS
//  tracker rather than the tools hub; the consult tiles open the andrologist
//  rather than the consults shelf; the emotional pointer is a door to Mind and
//  body rather than one of its articles; and the red-flag card the brief puts
//  in Talk is pinned there.
//
//  ---------------------------------------------------------------------------
//  ⚠️ HIS SIDE OWNS MALE-FACTOR CONTENT, AND THREE OTHER DOORS REFERENCE IT
//  ---------------------------------------------------------------------------
//
//  Step 5 of the brief. Getting ready's "His part", the fertile-window door's
//  his-side card and IVF's tests card all name reads defined HERE, by id.
//  Nothing is copied, so an edit lands in every door at once.
//
//  The same rule runs the other way for one tile: "Keep his reports with yours"
//  and IVF's "Keep your reports together" are ONE tool — surface `ttc_records`
//  — shown twice. Two records screens that must agree with each other is how
//  records rot.
//
//  ---------------------------------------------------------------------------
//  ⚠️ AND THE TONE IS DIFFERENT AGAIN
//  ---------------------------------------------------------------------------
//
//  A man opens this either because somebody suggested he get tested, or because
//  a report has already come back and he is reading it alone at night. He has
//  had far less practice than she has at being examined and discussed, and the
//  commonest failure mode is not panic — it is going quiet.
//
//  So nothing here is jocular, nothing is a nudge, and the pieces that matter
//  most say "tell her" out loud.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../ttc_focus_data.dart';
import '../ttc_prepare_data.dart' show kTtcOfferingAndrologist;

// =============================================================================
//  His side
// =============================================================================

const TtcFocusPage kTtcHisSideFocus = TtcFocusPage(
  bracketId: 'ttc_male_fertility',

  // ⚠️ THE HUB'S OWN HERO LINE, KEPT VERBATIM — the brief requires it, and it
  // is the sentence this whole area exists to make.
  intro: 'His fertility matters just as much.',

  // ⚠️ THE PLACEHOLDER WAS A WOMAN AT A LAPTOP, ON THE ONE DOOR IN THIS STAGE
  // THAT IS ABOUT HIM. Changed 2026-09-04 on sight.
  //
  // Worth saying because it is a general trap rather than one bad URL: these
  // heroes are unsplash placeholders picked for mood, and every other door in
  // this stage is read by her — so "a person, softly lit, calm" defaults to a
  // woman and nobody notices. This is the door where that default is the
  // opposite of the point, since half of what it exists to say is that this is
  // not only her problem.
  //
  // Still a placeholder. The real photograph is owed with the other four.
  // Our own photograph (2026-09-27): generated to the door's brief, checked by
  // eye, mirrored to the R2 bucket. Kept for revert: the previous value.
  // heroImageUrl: 'https://images.unsplash.com/photo-1516585427167-9f4af9627e6c?w=900&h=700&fit=crop',
  heroImageUrl: 'https://pub-bfbc0773e60e4c5c851b535f08b384bc.r2.dev/ttc_door_his_side_v2.jpg',
  // ⚠️ TWO PEOPLE, NOT ONE FACE — second correction, 2026-09-04. The first
  // placeholder was a woman at a laptop, which was wrong on a door about him.
  // The replacement was a man's face, which was also wrong, and for a subtler
  // reason: a portrait of a man makes this the page about HIM, and the door's
  // whole argument is that fertility is a thing the two of them have together.
  // A couple is the picture that says what the copy says.
  // The new door's headline, a sentence (TtcDoorScreen, 2026-09-26).
  heroTitle: 'His side of trying, in plain words.',
  heroBlurb: 'Sperm health, the habits that really change it, what the test '
      'involves, and how to read the report when it comes back. Written from '
      'WHO, NICE and other medical guidance.',

  // ---------------------------------------------------------------------------
  //  Five tabs, Understand first, in the brief's order
  // ---------------------------------------------------------------------------
  // ⚠️ HUES ARE THE APP'S OWN. 186 is this bracket's teal and leads; 206 the
  // clinical blue every test surface in this stage wears; 104 the practice
  // green; 160 the "your own logged data" green the cycle report uses; 42 the
  // warm read tone for the tab that ends at a person.
  groups: [
    TtcFocusGroup(
        id: 'understand', mark: IntentMark.bookMark, tabMark: TtcTabMark.openBook,
        label: 'Understand',
        icon: Icons.menu_book_outlined,
        hue: 186),
    TtcFocusGroup(
        id: 'test', mark: IntentMark.reportPage, tabMark: TtcTabMark.vialReport,
        label: 'Test and results',
        icon: Icons.biotech_outlined,
        hue: 206),
    TtcFocusGroup(
        id: 'improve', mark: IntentMark.improveMark, tabMark: TtcTabMark.sprout,
        label: 'Improve his health',
        icon: Icons.eco_outlined,
        hue: 104),
    // ⚠️ FOLDED 2026-09-28 (launch sanity D13): a tab of two tools made her
    // tap for very little. His log now sits under Improve his health (it
    // logs the habits that tab is about) and the shared records folder under
    // Test and results (it holds the report). Kept for revert:
    // TtcFocusGroup(
    //     id: 'track', mark: IntentMark.chartLog, tabMark: TtcTabMark.chartLine,
    //     label: 'Track',
    //     icon: Icons.calendar_today_outlined,
    //     hue: 160),
    TtcFocusGroup(
      id: 'talk', mark: IntentMark.askDoctor, tabMark: TtcTabMark.twoBubbles,
      label: 'Talk',
      icon: Icons.chat_bubble_outline_rounded,
      hue: 42,
      // ⚠️ THE BRIEF'S "REASONS TO BE SEEN SOONER" CARD, AND IT IS A REUSED
      // CALLOUT EXACTLY AS THE BRIEF SAYS — "calm red-flag card (reuse
      // callout)". The group names the read; the screen renders that read's
      // own `whenToSeeSomeone`, which is titled "Reasons for him to be seen
      // sooner" and was written by the doctor. One copy of the sentence, and
      // it is visible without opening anything, which the brief insists on:
      // "keep the red-flag card visible either way".
      pinnedRedFlagReadIds: ['ttc_read_whose_side'],
    ),
  ],

  // ⚠️ POPULATED BUT NOT DRAWN, as on the other four pages. The paid course
  // came off the top of the focus pages; keeping the data means restoring it is
  // uncommenting a render rather than rewriting a tile.
  //
  // ⚠️ AND IT IS THE SAME OFFERING ID AS THE ONE IN TAB THREE — Step 5c. One
  // course shown in two places, not two copies of a course.
  headline: TtcMasterclassTile(
    title: 'The half nobody talks about',
    blurb: 'A short course on the male side, with an andrologist.',
    offeringId: 'ttc_partner_workshop',
  ),

  sections: [
    // =========================================================================
    //  1 — Understand
    // =========================================================================
    TtcFocusSection(
      heading: 'Is it about him?',
      group: 'understand',
      tiles: [
        TtcArticleTile(
          title: 'Whose "side" is it, really',
          blurb: 'About half of couples having difficulty have a male factor '
              'somewhere in it. The word "fault" doesn\'t help anyone here.',
          readId: 'ttc_read_whose_side',
        ),
        // ⚠️ MOVED TO "Is it worth testing?" UNDER THE FILM'S OWN TITLE
        // (2026-09-27, relevance audit). This slot is "Why his side gets
        // tested last", not a film about what affects sperm health; that
        // film is `ttc_vid_heat_habits`, now under "The three levers".
        // Kept for revert (2026-09-27, relevance audit):
        // TtcVideoTile(
        //   title: 'What affects sperm health',
        //   blurb: 'The three things that really change it, and the many that '
        //       "don't.",
        //   slotId: 'ttc_vid_whose_side',
        //   duration: '5 MIN',
        // ),
        // Moved here from "Is it worth testing?" (2026-09-27, relevance
        // audit): his age is a question about him, not about the test.
        TtcArticleTile(
          title: 'Does his age matter?',
          blurb: "It changes more slowly than yours. Here's what changes.",
          readId: 'ttc_read_his_age',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Is it worth testing?',
      group: 'understand',
      tiles: [
        // ⚠️ THE BRIEF'S "SHORT CARD THAT BRIDGES INTO TAB 2" — and since
        // 2026-09-06 it is its own short piece rather than the semen-analysis
        // article wearing a different title. It makes the one-paragraph case,
        // then hands over: its read-next is "What a semen analysis involves"
        // and its next step is the tool, which is tab 2 in the order tab 2
        // presents them.
        TtcArticleTile(
          title: 'The case for testing early',
          blurb: 'One test, easy to find and cheap, and it answers a question '
              "a year of waiting can't.",
          readId: 'ttc_read_case_for_testing',
        ),
        // Moved to "Is it about him?" (2026-09-27, relevance audit).
        // Kept for revert:
        // // Added 2026-09-26 (gap plan, His side P2).
        // TtcArticleTile(
        //   title: 'Does his age matter?',
        //   blurb: "It changes more slowly than yours. Here's what changes.",
        //   readId: 'ttc_read_his_age',
        // ),
        // Moved here from "Is it about him?" under its own title (2026-09-27,
        // relevance audit): the film is about why testing him comes last.
        TtcVideoTile(
          title: 'Why his side gets tested last',
          blurb: 'A male factor plays a part for about half of couples, and '
              'his side is the quickest to check.',
          slotId: 'ttc_vid_whose_side',
          duration: '5 MIN',
        ),
      ],
    ),

    // =========================================================================
    //  2 — Test and results
    // =========================================================================
    TtcFocusSection(
      heading: 'The test',
      group: 'test',
      tiles: [
        TtcArticleTile(
          title: 'What a semen analysis involves',
          blurb: "What's measured, what the numbers mean, and what to do "
              'before the sample so the result is worth having.',
          readId: 'ttc_read_semen_analysis',
        ),
        TtcVideoTile(
          title: 'Reading a semen report',
          blurb: 'The page, explained line by line.',
          slotId: 'ttc_vid_semen_analysis',
          duration: '6 MIN',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Read your own report',
      group: 'test',
      tiles: [
        // ⚠️ THE ONE NET-NEW THING IN THIS DOOR, and the rules it holds are on
        // `ttc_semen_reading.dart`: no score, no verdict, a single low number
        // is never a conclusion, and every path ends at a real andrologist.
        TtcToolTile(
          title: 'Read your semen report',
          blurb: 'Type in what it says and get it explained in plain English. '
              "It won't tell you whether you're fertile. Nothing can, from one "
              'sheet of paper.',
          surfaceId: 'ttc_semen_report',
        ),
        // D13 (2026-09-28): "Get it read" was a section of this one card;
        // it joins the report it reads. Moved from its own section below.
        TtcTalkTile(
          title: 'Have the report read properly',
          blurb: 'An andrologist reads the numbers together and in context, '
              'which no list of lines can do.',
          action: kTtcOfferingAndrologist,
        ),
        // D13 (2026-09-28): moved from the retired Track tab. His semen
        // analysis belongs beside her reports; see the note at its old place.
        TtcToolTile(
          title: 'Keep his reports with yours',
          blurb: 'One folder for both of you, so a second opinion starts with '
              'the papers, not with trying to remember.',
          surfaceId: 'ttc_records',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'What the words and results mean',
      group: 'test',
      tiles: [
        TtcGuideTile(
          title: 'The words on the report, in plain English',
          blurb: 'Every term on the page, said the way a person would say it.',
          readId: 'ttc_read_report_words',
        ),
        TtcArticleTile(
          title: 'If the result is normal',
          blurb: "What it rules out, and the two things it doesn't.",
          readId: 'ttc_read_result_normal',
        ),
        TtcArticleTile(
          title: 'If the first test is abnormal',
          blurb: 'One low number is a reason to repeat, not a conclusion. '
              "Here's why that matters.",
          readId: 'ttc_read_result_abnormal',
        ),
        // ⚠️ ITS OWN CARD, WHICH IS STEP 4a AND MATTERS. This was a paragraph
        // inside a longer piece. It is the one result that needs a specialist
        // rather than a repeat, it is the sentence a man is most likely to
        // read alone at midnight, and the true information is far more hopeful
        // than the word sounds. Buried, it helps nobody.
        TtcArticleTile(
          title: 'If no sperm is found',
          blurb: "It's not the end of the road. It's the one result that goes "
              'to a specialist rather than to a second sample.',
          readId: 'ttc_read_azoospermia',
        ),
      ],
    ),

    // ⚠️ THE ANDROLOGIST, NOT THE CONSULTS SHELF — 2026-09-06. The brief
    // says "Talk / Consult (andrologist)". `kTtcActConsult` opens the whole
    // consults category, where the male-fertility consultation is one card
    // in three; this names the offering itself, so the tap lands on the
    // person the card promised.
    // Moved into "Read your own report" (D13, 2026-09-28). Kept for revert:
    // TtcFocusSection(
    //   heading: 'Get it read',
    //   group: 'test',
    //   tiles: [
    //     TtcTalkTile(
    //       title: 'Have the report read properly',
    //       blurb: 'An andrologist reads the numbers together and in context, '
    //           'which no list of lines can do.',
    //       action: kTtcOfferingAndrologist,
    //     ),
    //   ],
    // ),

    // =========================================================================
    //  3 — Improve his health
    // =========================================================================
    TtcFocusSection(
      heading: 'The three levers',
      group: 'improve',
      tiles: [
        TtcArticleTile(
          title: 'Heat, habits and time',
          blurb: 'What really changes sperm health, including the smokeless '
              'tobacco nobody counts.',
          readId: 'ttc_read_heat_habits',
        ),
        // ⚠️ A GUIDE, AND ITS OWN PIECE — 2026-09-06. The brief: "Guide (the
        // 12-week plan)". It was an article tile opening the essay above it;
        // now it is the plan, week by week, with the repeat booked on day one.
        TtcGuideTile(
          title: 'What three months looks like',
          blurb: 'The twelve-week plan: which change in which week, and why '
              'the repeat test is booked before anything else.',
          readId: 'ttc_read_three_months',
        ),
        // The film about what changes sperm health (2026-09-27, relevance
        // audit). Written and chaptered, and was on no door.
        TtcVideoTile(
          title: 'Three things that really change his numbers',
          blurb: 'Tobacco, heat and time, and how long before any change '
              'shows.',
          slotId: 'ttc_vid_heat_habits',
          duration: '5 MIN',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Supplements, honestly',
      group: 'improve',
      tiles: [
        // ⚠️ ARTICLE FIRST, PRODUCT SECOND — the brief lists both, in that
        // order, and the order is the ethics. He reads that the evidence is
        // weak, what the one large trial found, and what a month costs in
        // rupees, BEFORE he reaches anything he can buy.
        TtcArticleTile(
          title: 'Zinc and CoQ10, honestly',
          blurb: 'The two with any evidence at all: what the evidence shows, '
              "what they cost, and what they can't replace.",
          readId: 'ttc_read_zinc_coq10',
        ),
        // A shelf, not a single product — and both entries on it say the
        // evidence is weak. `zinc` is band `situational` and evidence `thin`;
        // CoQ10 the same. This door does not sell him a stack on the strength
        // of one report.
        //
        // ⚠️ TWO PRODUCTS, NOT THE WHOLE SHELF (2026-09-27, relevance audit).
        // The shelf opened folic acid, inositol and the rest, the same shelf
        // Getting ready calls "Folic acid and preconception supplements". The
        // tile named zinc and CoQ10, and both are in the catalogue, each with
        // its own honest "best for" lines on its page. The old blurb's "at the
        // doses the trials used" is not true of the CoQ10 entry, whose page
        // says box doses vary, so the blurbs now say when each is worth it.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcProductTile.shelf(
        //   title: 'Zinc / CoQ10',
        //   blurb: 'Plain versions, at the doses the trials used. Read the piece '
        //       'above before you spend anything.',
        //   category: 'supplements',
        // ),
        TtcProductTile(
          title: 'Zinc',
          blurb: 'Worth it only if a test showed his level is low. Read the '
              'piece above before you spend anything.',
          productId: 'zinc',
        ),
        TtcProductTile(
          title: 'CoQ10',
          blurb: 'Worth it only if a clinic has named it. Read the piece above '
              'before you spend anything.',
          productId: 'coq10',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'The course',
      group: 'improve',
      tiles: [
        // ⚠️ THE SAME OFFERING ID AS THE HEADLINE ABOVE — Step 5c. One course,
        // two placements, one content id.
        TtcMasterclassTile(
          title: 'The half nobody talks about',
          blurb: 'A short course on the male side, at your own pace, with an '
              'andrologist.',
          offeringId: 'ttc_partner_workshop',
        ),
      ],
    ),

    // =========================================================================
    //  4 — Track
    // =========================================================================
    // D13 (2026-09-28): under Improve his health, with the tab gone. Kept for
    // revert: heading: 'Track', group: 'track'.
    TtcFocusSection(
      heading: 'Keep track of what he changes',
      group: 'improve',
      tiles: [
        // ⚠️ HIS TRACKER, DIRECTLY — 2026-09-06. The brief: "Tool (reuse,
        // private, his side)". This opened `ttc_tools`, the whole tools hub,
        // where his tracker is one tile among a dozen of hers. The partner
        // health tracker already exists (`partner_health`, `forPartner: true`)
        // and is exactly the thing; the surface id below opens it and nothing
        // else.
        TtcToolTile(
          title: 'What he can track',
          blurb: 'Sleep, alcohol, tobacco, heat and movement: his own log, on '
              'his own account.',
          surfaceId: 'ttc_partner_health',
        ),
        // ⚠️ ONE TOOL SHOWN TWICE, NOT TWO TOOLS — Step 5b. IVF's "Keep your
        // reports together" opens this same surface. His semen analysis
        // belongs beside her AMH, in one folder, in one date order; two
        // records screens that have to agree with each other is how records
        // rot.
        // Moved to "Read your own report" (D13, 2026-09-28). Kept for revert:
        // TtcToolTile(
        //   title: 'Keep his reports with yours',
        //   blurb: 'One folder for both of you, so a second opinion starts with '
        //       'the papers, not with trying to remember.',
        //   surfaceId: 'ttc_records',
        // ),
      ],
    ),

    // =========================================================================
    //  5 — Talk
    // =========================================================================
    //  The "Reasons to be seen sooner" card is pinned above this section by
    //  the group — see `pinnedRedFlagReadIds` on the `talk` group.
    TtcFocusSection(
      heading: 'Talk',
      group: 'talk',
      tiles: [
        // The andrologist offering itself — see the note on "Get it read".
        TtcTalkTile(
          title: 'Talk to an andrologist',
          blurb: 'In private, about your own results. Bring the printed '
              'report rather than a number you remember.',
          action: kTtcOfferingAndrologist,
        ),
        // Added 2026-09-26 (gap plan, His side P2). ⚠️ HIDDEN BY THE
        // SHARED-PHONE SWITCH: this read is in `kTtcIntimateReadIds`, so the
        // door drops this one tile, not the Talk tab, when she turns it on.
        TtcArticleTile(
          title: 'When sex is hard for him under pressure',
          blurb: "Common in the fertile days, and it's usually the pressure.",
          readId: 'ttc_read_his_side_pressure',
        ),
        // ⚠️ STEP 4b — A DOOR, NOT AN ARTICLE — 2026-09-06. The brief: "a
        // single pointer card that deep-links to the Mind and body focus
        // area". It was an article tile opening one of that area's reads,
        // which is a pointer to a page rather than to the area. A door tile
        // opens the area itself, the way Mind and body's own "His part of
        // this" opens this one. Nothing about stress is built here.
        //
        // ⚠️ THE PIECE ABOUT HIM, NOT A DOOR THAT OPENS ON HER (2026-09-27,
        // relevance audit). Mind & body opens on Today, her few calm
        // minutes, and no section there is about him; a door tile cannot yet
        // open another door on a chosen tab. The one section written about
        // him going quiet lives in Mind & body's own read, so this names that
        // section: still Mind & body's content, and nothing built here.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcDoorTile(
        //   title: 'His emotional side',
        //   blurb: 'What this does to him, from the area that covers it. Men '
        //       'are offered support far less often, mostly because nobody '
        //       'asks.',
        //   bracketId: 'ttc_mind_body',
        // ),
        TtcGuideTile(
          title: 'When he goes quiet',
          blurb: 'Why he may say little even when he cares. Men are offered '
              'support far less often, mostly because nobody asks.',
          readId: 'ttc_read_bringing_him_in',
          atHeading: 'Why might he be quiet, even when he cares?',
        ),
      ],
    ),
  ],
);
