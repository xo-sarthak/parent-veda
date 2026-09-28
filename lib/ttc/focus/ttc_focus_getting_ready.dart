// =============================================================================
//  Getting ready — the focus page for this door
// -----------------------------------------------------------------------------
//  Built 2026-09-03 from `getting_ready_rebuild.pdf`. Fourth door on the shape
//  PCOS and IVF established: a hero, a group rail, then sections of tiles.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THIS REPLACED WAS A JOURNEY, NOT A PAGE
//  ---------------------------------------------------------------------------
//
//  The brief describes "a single page: an intro, a 'What this answers'
//  accordion of six questions, then those same six as full sections". That is
//  `kTtcPreconceptionReadiness` in `ttc_journeys.dart` — a six-step journey
//  whose ten elements are exactly the ten cards the brief lists.
//
//  So the migration was not a screen rewrite. Every one of those ten
//  destinations is re-slotted below, and the journey stays on disk untouched:
//  it is registered by `doorId`, and the V3 home now finds this page first.
//  Nothing was deleted to make room.
//
//  ---------------------------------------------------------------------------
//  ⚠️ SINGLE-SOURCE WAS ALREADY HOW THIS REPO WORKS — STEP 5 WAS FREE
//  ---------------------------------------------------------------------------
//
//  The brief's central worry is whether the content model can point many cards
//  at one item, and says to build that first if it cannot. It can, and it never
//  worked any other way: a tile carries a `readId`, a `surfaceId`, a
//  `productId` or a `recipeId` — an IDENTIFIER, never a copy of the text. The
//  article lives once in `kTtcReads`; any number of tiles on any number of
//  pages may name it; editing it updates every one of them because there is
//  only ever one of it.
//
//  `ttc_focus_page_test.dart` already enforces the other half: every id on
//  every page must resolve, so a card pointing at content that has been renamed
//  or removed fails the build rather than rendering perfectly and doing
//  nothing.
//
//  What this page therefore does NOT contain is any duplicated prose. Where the
//  fertile-window door shows the same diet and folic-acid material, it names
//  the same read ids — see the note on those tiles in
//  `ttc_focus_conceiving.dart`.
//
//  ---------------------------------------------------------------------------
//  ⚠️ AND THE TONE IS DIFFERENT FROM EVERY OTHER DOOR, DELIBERATELY
//  ---------------------------------------------------------------------------
//
//  Nobody arriving here has a problem. They have not started trying yet. PCOS
//  opens on somebody who has been given a word she did not want; IVF opens on
//  somebody frightened and out of options; this one opens on somebody being
//  organised, early, by choice.
//
//  So the brief's framing — "nothing urgent, nothing you have to rush" — is
//  kept verbatim in the intro, and no tile on this page implies a delay is her
//  fault or that a list needs finishing.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

// Unused since the consult tiles name their offering (2026-09-27,
// relevance audit). Kept for revert:
// import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
import '../ttc_focus_data.dart';

// =============================================================================
//  Getting ready
// =============================================================================

const TtcFocusPage kTtcGettingReadyFocus = TtcFocusPage(
  bracketId: 'ttc_preconception_health',

  // ⚠️ THE JOURNEY'S OWN INTRO, KEPT WORD FOR WORD. The brief says the hero
  // line and the "nothing urgent" framing stay, and the line it means already
  // exists — `kTtcPreconceptionReadiness.intro`. Rewriting it while
  // restructuring underneath would throw away the one sentence somebody
  // returning to this area would recognise.
  intro: "A short, practical list of what's worth sorting out before you start "
      "trying. Nothing urgent, nothing you have to rush.",
  // Our own photograph (2026-09-27): generated to the door's brief, checked by
  // eye, mirrored to the R2 bucket. Kept for revert: the previous value.

  // heroImageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=900&h=700&fit=crop',

  heroImageUrl: 'https://pub-bfbc0773e60e4c5c851b535f08b384bc.r2.dev/ttc_door_getting_ready.jpg',
  // The new door's headline, a sentence (TtcDoorScreen, 2026-09-26).
  heroTitle: 'Getting ready, at your own pace.',
  heroBlurb: 'The months before you start trying are a good time to get '
      'ready. Diet, a few tests, folic acid and a couple of habits. Take it '
      'calmly, at your own pace, and do most of it together.',

  // ---------------------------------------------------------------------------
  //  The selector rail — five cards, Diet first, exactly the brief's order
  // ---------------------------------------------------------------------------
  // ⚠️ THE HUES ARE THE APP'S OWN AND NOT NEW ONES. 104 is this bracket's own
  // green and leads because the brief makes Diet the default; 206 is the
  // clinical blue every test surface in this stage already wears; 42 the warm
  // read tone; 344 the "for you" rose; 160 the green the cycle report gives a
  // completed stretch, which is what a finished checklist is.
  //
  // ⚠️ AND "Your checklist" IS LAST BECAUSE IT IS THE CLOSING SPINE, not
  // because it matters least. The brief is explicit: it is not a browse rail,
  // it is where the section ends.
  //
  // ⚠️ FOUR TABS, NOT SIX (launch sanity D11, 2026-09-28): 27 pieces over six
  // tabs (3, 6, 4, 4, 7, 3) was six tabs to learn for a small door, and
  // "Meal plan" held reads, not a plan. Diet and Meal plan are one tab, Food
  // and supplements; Weight and habits and Before you start are one tab,
  // Habits and first steps. Every piece stays, in the same order; only the
  // tab it sits under moved. The two retired tabs are kept for revert.
  groups: [
    // Kept for revert (2026-09-28): label: 'Diet and supplements',
    TtcFocusGroup(
        id: 'diet', mark: IntentMark.plate, tabMark: TtcTabMark.jarLeaf,
        label: 'Food and supplements',
        icon: Icons.restaurant_outlined,
        hue: 104),
    // Added 2026-09-26 (gap plan, P1): the Indian meal plan, beside Diet
    // because it is Diet made practical. Six tabs; Your checklist stays last.
    // Folded into Food and supplements (D11, 2026-09-28). Kept for revert:
    // TtcFocusGroup(
    //     id: 'meals', mark: IntentMark.cookMark, tabMark: TtcTabMark.bowl,
    //     label: 'Meal plan',
    //     icon: Icons.soup_kitchen_outlined,
    //     hue: 26),
    TtcFocusGroup(
        id: 'tests', mark: IntentMark.reportPage, tabMark: TtcTabMark.vialReport,
        label: 'Tests and vaccines',
        icon: Icons.biotech_outlined,
        hue: 206),
    TtcFocusGroup(
        id: 'habits', mark: IntentMark.stepsMark, tabMark: TtcTabMark.scale,
        // Kept for revert (2026-09-28): label: 'Weight and habits',
        label: 'Habits and first steps',
        icon: Icons.self_improvement_outlined,
        hue: 42),
    // Folded into Habits and first steps (D11, 2026-09-28). Kept for revert:
    // TtcFocusGroup(
    //     id: 'before', mark: IntentMark.nextStep, tabMark: TtcTabMark.flagPath,
    //     label: 'Before you start',
    //     icon: Icons.event_note_outlined,
    //     hue: 344),
    TtcFocusGroup(
        id: 'checklist', mark: IntentMark.checkMark, tabMark: TtcTabMark.checklist,
        label: 'Your checklist',
        icon: Icons.checklist_rtl_rounded,
        hue: 160),
  ],

  // ⚠️ POPULATED BUT NOT DRAWN, as on the other three pages. The paid
  // masterclass came off the top of the focus pages; keeping the data means
  // restoring it is uncommenting a render rather than rewriting a tile, and
  // `ttc_focus_page_test.dart` asserts against the data.
  headline: TtcMasterclassTile(
    title: 'Getting ready to conceive',
    blurb: 'A short course on the months before you start, with a doctor.',
    offeringId: 'ttc_course_basics',
  ),

  sections: [
    // =========================================================================
    //  1 — Diet and supplements
    // =========================================================================
    TtcFocusSection(
      heading: 'Eating before you try',
      group: 'diet',
      tiles: [
        // ⚠️ "FOR BOTH OF YOU" IS IN THE READ, NOT ONLY IN THE BLURB. This is
        // the first tile of the first tab of a door about preparation, and it
        // is the first chance in this area to say that preparation is not her
        // job alone.
        // ⚠️ THE EATING ANSWER, NOT THE WHOLE READ (2026-09-27, relevance
        // audit). "The three months before" opened folic acid, weight,
        // cutting, the partner and money under a question about eating. It
        // moved to "Before you start", where the whole read is the answer,
        // and this tile opens the same read at its eating section, with the
        // same words the fertile-window door uses for it.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcArticleTile(
        //   title: 'The three months before',
        //   blurb: "What's worth changing in the months before you start, and "
        //       "why it's for both of you, not just you.",
        //   readId: 'ttc_read_three_months_before',
        // ),
        TtcArticleTile(
          title: 'What to eat and avoid',
          blurb: 'Ordinary food. No special fertility diet.',
          readId: 'ttc_read_three_months_before',
          atHeading: 'What should I eat?',
        ),
        // ⚠️ A FILM WAS HERE AND THE BRIEF NEVER ASKED FOR ONE — removed
        // 2026-09-03.
        //
        // `ttc_vid_three_months_before` is written, chaptered and reachable
        // from nowhere, and I put it here on the argument that a door with no
        // page had left it stranded. That argument may even be right, and it
        // is still not what this section is. The brief lists three rows here;
        // I shipped four.
        //
        // This is the same mistake as the supplements tool, the checklist
        // format and the two duplicate titles: filling a slot with something I
        // decided rather than what the brief said. If the films belong in this
        // door, that is a change to ask for — see `docs/STILL-OPEN.md` §23.

        // ⚠️ A TOOL, AND THE DISTINCTION MATTERS. This is a day-by-day eating
        // planner for an Indian kitchen, not an article about diet. The read
        // above says why the three months matter; this says what to cook on
        // Thursday. Filing the planner as an article was the mistake the
        // journey's own note records.
        // ⚠️ OFF THIS TAB (2026-09-27, relevance audit). The Meal plan tab
        // next door opens the same tool as "Plan your own week", and owns it.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcToolTile(
        //   title: 'Eating, day to day',
        //   blurb: 'A week of real meals from an Indian kitchen, and what each '
        //       'one does for you.',
        //   surfaceId: 'ttc_nutrition',
        // ),
        // ⚠️ MOVED TO "Everyday habits" (2026-09-27, relevance audit):
        // tobacco, alcohol and caffeine are habits, not eating.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcArticleTile(
        //   title: 'What to cut before trying',
        //   blurb: 'Three things worth changing, and a longer list you can stop '
        //       'feeling guilty about.',
        //   readId: 'ttc_read_what_to_cut',
        // ),
      ],
    ),

    TtcFocusSection(
      heading: 'Supplements',
      group: 'diet',
      tiles: [
        // ⚠️ TWO CARDS, NOT THREE — CORRECTED 2026-09-03, SAME DAY IT SHIPPED.
        //
        // There were three, and the first two both opened with the words
        // "Folic acid". Reported on sight: *"i still see three tabs in
        // supplements, and they the same?"* — which is the correct reading of
        // what was on screen.
        //
        // What happened is worth recording, because it is a specific trap. The
        // brief asks for two items here. I added a third — the shipped folic
        // acid read — on the argument that the need should be established
        // before the product is offered. That argument is sound and the card
        // was still redundant, because the NEW article written in the same
        // session already establishes it: `ttc_read_supplement_timing` opens on
        // the folic acid deadline. I added a card to solve a problem I had just
        // solved somewhere else, and did not notice because I wrote the two
        // pieces hours apart.
        //
        // ⚠️ THE DEEP READ IS NOT LOST, AND THAT IS WHY THIS IS A MERGE RATHER
        // THAN A DELETION. `moreReadId` hangs `ttc_read_folic_acid` off the
        // timing article as its fuller piece — one tap, in the place somebody
        // asking "how early" would actually look for it. It also still sits on
        // the fertile-window door, which references the same id.
        TtcArticleTile(
          title: 'When to start what, and how early',
          blurb: 'Folic acid works best when it starts before a test turns '
              'positive. Almost nothing else has a deadline like that.',
          readId: 'ttc_read_supplement_timing',
          moreReadId: 'ttc_read_folic_acid',
        ),
        // ⚠️ A PRODUCT CARD OPENING THE SUPPLEMENTS SHELF — CORRECTED
        // 2026-09-03, ON THE SECOND REPORT.
        //
        // The brief's format column says **Product**. This shipped as
        // `TtcToolTile(surfaceId: 'ttc_supplements')`, which opens the
        // supplements TRACKER — "a record of what they actually take, and
        // whether they took it today", in that screen's own words. So a card
        // about what to buy landed on a compliance grid.
        //
        // Two separate mistakes, worth separating:
        //
        //   1. I matched each brief row to the nearest existing surface instead
        //      of to the format the brief named. `ttc_supplements` had the word
        //      in its name and I stopped looking.
        //   2. `TtcProductTile` could only name ONE product, so the row had no
        //      form to be built in — and a model that cannot express what a
        //      brief asks for gets a near-miss substituted for it every time.
        //      Fixed at the model: `TtcProductTile.shelf`.
        //
        // And the whole V3 product flow — categories, shelf, product page —
        // was built in the same session and this tile pointed at none of it.
        TtcProductTile.shelf(
          title: 'Folic acid and preconception supplements',
          blurb: "What's worth buying, and what we'd gently talk you out "
              'of.',
          category: 'supplements',
        ),
        // ⚠️ AND NOTHING ELSE. The brief's Supplements section is TWO rows —
        // one Product, one Article — and this is the third time a third card
        // has been added here and removed again. The supplements tracker is a
        // real screen and it is reachable from the Tools hub; it is not on
        // this section's list, and "it would be useful" is not the same thing
        // as "the brief asks for it".
      ],
    ),

    // =========================================================================
    //  1b — Meal plan (gap plan, 2026-09-26)
    // =========================================================================
    //  ⚠️ THE NUTRITION TOOL IS ON THIS TAB TOO, UNDER ITS OWN TITLE. Diet's
    //  "Eating, day to day" opens the same surface; one tool, two doors in,
    //  the way His side and IVF share the records folder. The brief test holds
    //  every title to one tile, so this one says what she does here: plan.
  //  2026-09-27 (relevance audit): Diet's copy is commented out, so this tab
  //  is now the one way in from this door.
    TtcFocusSection(
      heading: 'What can we cook this week?',
      group: 'diet', // D11 (2026-09-28). Kept for revert: 'meals'
      tiles: [
        TtcArticleTile(
          title: 'A week of Indian meals for trying',
          blurb: 'Seven days of home food, with eggless and Jain swaps.',
          readId: 'ttc_read_meal_plan_week',
        ),
        TtcArticleTile(
          title: 'Ten everyday recipes',
          blurb: 'Home dishes under 40 minutes that add iron, folate or protein.',
          readId: 'ttc_read_everyday_recipes',
        ),
        TtcToolTile(
          title: 'Plan your own week',
          blurb: 'Pick meals from an Indian kitchen and see what each one does.',
          surfaceId: 'ttc_nutrition',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'What else is worth knowing about food?',
      group: 'diet', // D11 (2026-09-28). Kept for revert: 'meals'
      tiles: [
        TtcArticleTile(
          title: 'Iron before pregnancy',
          blurb: 'Indian foods that help, and the tea timing that matters.',
          readId: 'ttc_read_iron_before_pregnancy',
        ),
        TtcArticleTile(
          title: 'Omega-3 without fish',
          blurb: 'Where a vegetarian kitchen finds it.',
          readId: 'ttc_read_omega3_without_fish',
        ),
        TtcArticleTile(
          title: 'Ask a dietitian: ten questions',
          blurb: 'The food questions people ask most, answered plainly.',
          readId: 'ttc_read_ask_dietitian',
        ),
      ],
    ),

    // =========================================================================
    //  2 — Tests and vaccines
    // =========================================================================
    TtcFocusSection(
      heading: 'What to check first',
      group: 'tests',
      tiles: [
        TtcArticleTile(
          title: 'Tests and vaccines worth doing first',
          blurb: 'A short list to take to a doctor, and why each one is on '
              'it.',
          readId: 'ttc_read_preconception_tests',
        ),
        // ⚠️ THE BRIEF'S SECOND ROW, WRITTEN 2026-09-03 ONCE THE TEST WAS
        // CONFIRMED. It sat empty until then on purpose — the brief itself
        // says to confirm which screen is meant before it goes into copy,
        // because naming a medical test is a place to be precise. Confirmed:
        // thalassemia carrier screening, HbA2 by HPLC.
        //
        // ⚠️ A GUIDE, WHICH IS WHAT THE BRIEF'S FORMAT COLUMN SAYS. It shipped
        // as an Article for two days because Step 2 lists the badges to add
        // and Guide was not one of them; the badge was then asked for and
        // added. See `TtcGuideTile` — it opens the same reader, and the chip
        // is the only difference, which is the entire point of it.
        TtcGuideTile(
          title: 'The carrier screening that matters in India',
          blurb: 'One cheap blood test, done once. Most Western advice '
              'for before pregnancy never mentions it, but it matters here '
              'more than almost anywhere.',
          readId: 'ttc_read_carrier_screening',
        ),

        // ⚠️ THE BRIEF'S FIFTH NEW PIECE IS NOT HERE, AND THAT IS THE BRIEF'S
        // OWN INSTRUCTION. "The carrier screening that matters in India" is
        // listed with a note to confirm which screen is meant with the content
        // author before it goes into copy — it reads like thalassemia carrier
        // screening and "reads like" is not good enough when naming a medical
        // test to a reader who may go and order it.
        //
        // No placeholder tile either. A card whose article does not exist opens
        // nothing, and the reachability test would fail the build — which is
        // correct. Recorded in `docs/STILL-OPEN.md` instead.
        //
        // What IS already covered: `ttc_read_preconception_tests` above carries
        // a "Being a carrier is not being ill" section, so the subject is not
        // absent from the door while the naming is settled.
      ],
    ),

    TtcFocusSection(
      heading: 'Sort it out',
      group: 'tests',
      tiles: [
        TtcToolTile(
          title: 'Check your vaccinations',
          blurb: 'Which ones matter before pregnancy, and which need doing '
              'a month ahead.',
          surfaceId: 'ttc_vaccinations',
        ),
        TtcToolTile(
          title: 'The full test library',
          blurb: "Every test, what it's for, when in your cycle to do it, "
              'and a real Indian price range.',
          surfaceId: 'ttc_tests',
        ),
        // ⚠️ A RECORDS TILE WAS HERE AND THE BRIEF DOES NOT LIST IT.
        // Removed 2026-09-03. The argument was good — a door that sends
        // somebody to order six tests should offer somewhere to put the
        // results — and it was still an addition nobody asked for. Records is
        // reachable from Tools and from the appointment card.

      ],
    ),

    // =========================================================================
    //  3 — Weight and habits
    // =========================================================================
    TtcFocusSection(
      heading: 'Weight, kindly',
      group: 'habits',
      tiles: [
        // ⚠️ NO NUMBER APPEARS IN THIS ARTICLE, ANYWHERE, and the brief asks
        // for exactly that. A figure on this subject is read as a verdict by
        // somebody already anxious about it, and a target she cannot reach
        // becomes a reason to stop trying rather than a reason to see anybody.
        // The same rule already governs the checklist's weight item and the
        // `ttc_bmi` surface.
        TtcArticleTile(
          title: 'Weight before pregnancy, said kindly',
          blurb: 'What weight really does, why the direction matters more '
              'than a goal, and no numbers at all.',
          readId: 'ttc_read_weight_kindly',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Everyday habits',
      group: 'habits',
      tiles: [
        // ⚠️ THE TWELFTH FORMAT EARNS ITS KEEP HERE. Sleep and movement are
        // not a tool — a tool is something you operate and put down. See
        // `TtcDoTile`.
        TtcDoTile(
          title: 'Habits worth building now',
          blurb: 'Sleep, movement, alcohol and tobacco. These four have the '
              'clearest evidence behind them.',
          surfaceId: 'ttc_precheck/lifestyle',
        ),
        // ⚠️ A TOOL, WHICH IS WHAT THE BRIEF SAYS. It shipped as `Do`, on the
        // reasoning that the section is about habits. But the brief
        // distinguishes them within the same section on purpose: "Habits worth
        // building now" is the practice, and this is the instrument you record
        // it with. Two rows, two formats, and the brief had them right.
        TtcToolTile(
          title: "Track what you're working on",
          blurb: "The four habit trackers in one place. It's a record, not a "
              'report card: no streaks and no score.',
          surfaceId: 'ttc_habits',
        ),
        // Moved here from "Eating before you try" (2026-09-27, relevance
        // audit).
        TtcArticleTile(
          title: 'What to cut before trying',
          blurb: 'Three things worth changing, and a longer list you can stop '
              'feeling guilty about.',
          readId: 'ttc_read_what_to_cut',
        ),
        // ⚠️ A STRESS ARTICLE WAS HERE, AND IT MISREAD THE BRIEF.
        //
        // Step 5c says the "Track what you're working on" **stress piece**
        // references the Mind and body content — meaning the stress tracker
        // inside that tool, which is where the reference belongs. I read it as
        // "put a stress card in this section" and added a fourth row.

      ],
    ),

    // =========================================================================
    //  4 — Before you start
    // =========================================================================
    TtcFocusSection(
      heading: 'Before you start',
      group: 'habits', // D11 (2026-09-28). Kept for revert: 'before'
      tiles: [
        // Moved here from "Eating before you try" (2026-09-27, relevance
        // audit). The whole read is the answer to "before you start", and it
        // still says, early, that this is for both of you.
        TtcArticleTile(
          title: 'The three months before',
          blurb: "What's worth changing in the months before you start, and "
              "why it's for both of you, not just you.",
          readId: 'ttc_read_three_months_before',
        ),
        TtcArticleTile(
          title: 'Coming off birth control',
          blurb: 'What comes back quickly, what really takes months, and why '
              '"let it clear out of your system" costs people time.',
          readId: 'ttc_read_coming_off_birth_control',
        ),
        // ⚠️ THE MOST IMPORTANT TILE ON THE PAGE, and it is here rather than in
        // tab one because it is the one thing somebody does WRONG while getting
        // ready. The reflex to stop every tablet before trying is common, well
        // meant, and the most avoidable harm in this whole area.
        TtcArticleTile(
          title: 'Medicines and conditions to check with a doctor',
          blurb: 'Never stop a prescribed medicine to get ready. What to ask '
              'instead, and how far ahead.',
          readId: 'ttc_read_meds_and_conditions',
        ),
        // ⚠️ REFERENCED, NOT COPIED — Step 5c again. His side owns this.
        TtcArticleTile(
          title: 'His part',
          blurb: 'Whose "side" it really is, and the half of this that '
              'depends on him.',
          readId: 'ttc_read_whose_side',
        ),
      ],
    ),

    // Added 2026-09-26 (gap plan). A second section rather than three more
    // rows under the first, so "Before you start" stays about what to stop,
    // keep and ask, and this one is the visit and the practical side.
    TtcFocusSection(
      heading: 'What is worth asking early?',
      group: 'habits', // D11 (2026-09-28). Kept for revert: 'before'
      tiles: [
        TtcArticleTile(
          title: 'Your first gynaecologist visit',
          blurb: 'What to take along, and the questions that make it count.',
          readId: 'ttc_read_first_gyn_visit',
        ),
        TtcArticleTile(
          title: 'Can a past abortion affect trying now?',
          blurb: 'What the evidence says, and the few things worth checking.',
          readId: 'ttc_read_after_abortion',
        ),
        TtcArticleTile(
          title: 'Money before a baby',
          blurb: 'Insurance waiting periods, leave and help, written for India.',
          readId: 'ttc_read_money_before_baby',
        ),
      ],
    ),

    // =========================================================================
    //  5 — Your checklist, the closing spine
    // =========================================================================
    TtcFocusSection(
      heading: 'Your checklist',
      group: 'checklist',
      tiles: [
        // ⚠️ THE BRIEF'S OWN FORMAT NAMES — both of these shipped as the
        // nearest existing thing (`Tool` and `Booking`) rather than as what
        // the brief called them. The chip is the promise about what happens
        // when she taps, and both promises were slightly wrong: a checklist is
        // something you return to and add to, not a tool you use once; and
        // "Talk" offers a conversation where "Booking" offers a calendar slot.
        TtcChecklistTile(
          title: 'Your pre-pregnancy checklist',
          blurb: "What's done, what's still worth talking about, and your "
              'next three things. Go at your own pace.',
          surfaceId: 'ttc_precheck',
        ),
        // ⚠️ THE PAGE CLOSES ON A PERSON, NOT ON A PRICE — the same rule the
        // conceiving page's test asserts. A consult is the last tile because a
        // door about preparation should end by handing you to somebody who can
        // answer what a page cannot, and it is one tile rather than repeated
        // down the page.
        // ⚠️ TWO PEOPLE, EACH OPENED BY NAME (2026-09-27, relevance audit).
        // The consults shelf has no nutritionist, so "a doctor or a
        // nutritionist" opened a shelf with half the promise on it. The
        // gynaecologist offering names the check-up before trying; the
        // nutritionist has a tile of their own.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcTalkTile(
        //   title: 'Talk to someone before you start',
        //   blurb: 'A doctor or a nutritionist who helps before pregnancy, for '
        //       'the questions that are yours.',
        //   action: kTtcActConsult,
        // ),
        TtcTalkTile(
          title: 'Talk to someone before you start',
          blurb: 'A gynaecologist who sees people before pregnancy, for the '
              'questions that are yours.',
          action: 'ttc_consult_gynae',
        ),
        TtcTalkTile(
          title: 'Talk to a nutritionist',
          blurb: 'A food plan for both of you, from what you already cook.',
          action: 'ttc_nutrition_consult',
        ),
      ],
    ),
  ],
);
