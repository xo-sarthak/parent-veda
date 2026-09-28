// =============================================================================
//  Mind & body — the seventh and last TTC door
// -----------------------------------------------------------------------------
//  Built from `ParentVeda_Mindbody_rebuild_final.pdf`, 30 Aug 2026. It completes
//  the stage: every bracket now opens a focus page and none opens a hub.
//
//  ⚠️ THE BRIEF'S OWN VOCABULARY, AND HOW EACH WORD LANDED IN CODE. It marks
//  every card `reuse`, `promote`, `reference` or `new`, and the four are not
//  decoration — they are the difference between single-sourcing this area and
//  quietly making a second copy of it:
//
//    reuse      → the tile names the existing `readId` / `slotId` / offering.
//                 Nothing is retyped. The two locked articles and the free
//                 course are reached exactly as they already are.
//    promote    → `atHeading` on a Guide or Article tile. One new CARD, no new
//                 prose: it opens the existing article scrolled to the named
//                 section. See `PvReaderScreen.openAtHeading`.
//    reference  → an ordinary tile carrying ANOTHER door's `readId`. Same
//                 article, one copy, and Getting ready still owns it. The chip
//                 says "Article", because that is what happens on tap — there
//                 is no "Reference" chip, since nobody outside this repo knows
//                 what a reference is.
//    new        → the only genuinely new things in the area: four guides in
//                 `ttc_reads_mind_body.dart`, twelve practices in
//                 `ttc_practice_data.dart`, and two myth cards written inline
//                 below from the articles' own material.
//
//  ⚠️ TWO MYTH CARDS ARE WRITTEN OUT, NOT PROMOTED, AND THE BRIEF SAYS PROMOTE.
//  `TtcMythTile` needs both halves as strings — a myth and a fact — so there is
//  no way to point one at a section and have it render. Both restate material
//  the locked articles already carry, in the shape the brief asked for. Same
//  compromise as the two After-a-loss myth cards; flagged in §28.
//
//  ⚠️ WHAT IS DELIBERATELY ABSENT: no tool, no tracker, no streak. The brief
//  forbids all three by name and `ttc_mind_body_test.dart` holds each one.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

// Unused since the consult tiles name their offering (2026-09-27,
// relevance audit). Kept for revert:
// import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
import '../ttc_focus_data.dart';
import '../ttc_practice_data.dart';

const String _kStress = 'ttc_read_stress_fertility';
const String _kGarbh = 'ttc_read_garbh_sanskar';

/// One Do tile per practice, straight from the library.
///
/// ⚠️ GENERATED, NOT TYPED. Twelve tiles typed out here would be a second copy
/// of every title and blurb in `ttc_practice_data.dart`, which is precisely the
/// duplication the brief's loudest instruction forbids — and it would be a
/// duplication that compiles, looks right, and drifts silently.
///
/// The cost is that the section's contents are not readable in this file. That
/// is the correct trade: a reader who wants to know what is in the Move library
/// should be reading the library.
List<TtcTile> _practiceTiles(TtcPracticeKind kind) => [
      for (final p in ttcPracticesOfKind(kind))
        TtcDoTile(
          title: p.title,
          blurb: p.blurb,
          surfaceId: 'ttc_practice/${p.id}',
        ),
    ];

final TtcFocusPage kTtcMindBodyFocus = TtcFocusPage(
  bracketId: 'ttc_mind_body',

  intro: 'Getting your mind and body ready to conceive. A few minutes a day, '
      'for both of you, and nothing here you have to believe in.',
  // Our own photograph (2026-09-27): generated to the door's brief, checked by
  // eye, mirrored to the R2 bucket. Kept for revert: the previous value.

  // heroImageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=900&h=700&fit=crop',

  heroImageUrl: 'https://pub-bfbc0773e60e4c5c851b535f08b384bc.r2.dev/ttc_door_mind_body.jpg',
  // The new door's headline, a sentence (TtcDoorScreen, 2026-09-26).
  heroTitle: 'A few calm minutes a day, for both of you.',
  // ⚠️ THE CLOSING LINE LEADS NOW (launch sanity MB9, 2026-09-28). The
  // brief's own sentence stood at the foot of every tab as a large serif line
  // that read like a heading with nothing under it, the second of three
  // closing texts. It is the door's promise, so it moves up into the blurb,
  // word for word, and the door stops drawing it at the foot (the door skips
  // a closing line the hero already says). Kept for revert:
  //   heroBlurb: 'Move a little, breathe a little, and sleep and eat like '
  //       "someone looking after themselves. That's the whole practice. It's "
  //       'worth doing for how the waiting feels, not for what it promises.',
  heroBlurb: 'Move a little, breathe a little, sleep and eat well. This is '
      'about spending the wait well and arriving at conception calmer and '
      'healthier.',

  // ---------------------------------------------------------------------------
  //  The rail — Today first, and it is a do-it screen rather than a menu
  // ---------------------------------------------------------------------------
  // ⚠️ `toolSurfaceId` ON TAB ONE IS HOW "do-it screen, NOT a card rail" IS
  // ENFORCED. A group with a tool surface renders that surface INSTEAD of its
  // rails, so Today cannot become a list of cards by somebody adding a section
  // and tagging it 'today' — there is nowhere for the section to draw. The
  // brief puts this in its DO NOT list, and this makes it structural rather
  // than a matter of remembering.
  groups: [
    TtcFocusGroup(
      id: 'today', mark: IntentMark.sunMark, tabMark: TtcTabMark.sun, inlineLabel: 'A few minutes',
      label: 'Today',
      icon: Icons.wb_sunny_outlined,
      hue: 160,
      toolSurfaceId: 'ttc_mind_today',
    ),
    // Added 2026-09-26 (gap plan, P1). Second, right after Today, because the
    // day a period comes is the day this door is most needed. ⚠️ THE PINNED
    // FLAG CARRIES THE SELF-HARM ROUTING (Tele-MANAS, 112), rendered whole
    // from the read's own callout, as on Talk.
    TtcFocusGroup(
      id: 'hard', mark: IntentMark.cuppedHands, tabMark: TtcTabMark.cloudRain,
      label: 'Hard days',
      icon: Icons.cloud_outlined,
      hue: 268,
      pinnedRedFlagReadIds: ['ttc_read_month_after_month'],
    ),
    TtcFocusGroup(
        id: 'understand', mark: IntentMark.bookMark, tabMark: TtcTabMark.openBook,
        label: 'Understand',
        icon: Icons.menu_book_outlined,
        hue: 206),
    TtcFocusGroup(
      id: 'practice', mark: IntentMark.lotusMark, tabMark: TtcTabMark.lotus,
      label: 'The practice',
      icon: Icons.self_improvement_outlined,
      hue: 104,
      // ⚠️ ONCE, HERE — NOT ON TWELVE CARDS. The brief's own heading, and
      // the reason is that a warning repeated on every card stops being read by
      // the third one. Each card still carries its OWN "skip it if", which is
      // the specific half and is different every time.
      note: kTtcPracticeSafety,
    ),
    TtcFocusGroup(
        id: 'ready', mark: IntentMark.checkMark, tabMark: TtcTabMark.checklist,
        // ⚠️ NAMED FOR WHAT IT HOLDS (launch sanity MB20, 2026-09-28): a tab
        // called exactly like another door ("Getting ready"), holding two
        // sleep reads, a bedtime breath and a way to that door. The id stays
        // (an identity). Kept for revert: label: 'Getting ready',
        label: 'Sleep and routine',
        icon: Icons.checklist_rtl_rounded,
        hue: 42),
    // ⚠️ BOTH FLAGS, ON ONE TAB, FROM TWO DIFFERENT ARTICLES. This is what
    // turned `pinnedRedFlagReadId` into a list on 2026-09-05 — After a loss
    // wanted two and happened to want them on separate tabs, so the singular
    // field fit by luck. The self-harm routing lives inside the first of these
    // and the brief says explicitly not to bury it; rendering the article's own
    // callout whole is what guarantees it travels.
    TtcFocusGroup(
      id: 'talk', mark: IntentMark.moodArc, tabMark: TtcTabMark.twoBubbles,
      label: 'Talk',
      icon: Icons.chat_bubble_outline_rounded,
      hue: 344,
      pinnedRedFlagReadIds: [_kStress, _kGarbh],
    ),
  ],

  // ⚠️ NO HEADLINE MASTERCLASS, AND THAT IS THE POSITION NOTE IN CODE. Every
  // other door carries a paid course at the top. This area's whole argument —
  // set out at length in the brief's "where garbh sanskar sits" note — is that
  // the market sells preconception practice on promises about a baby, and that
  // our advantage is refusing to. Opening it with something to buy would
  // undercut that on the first screen. The free course is still here, in Go
  // deeper, priced at nothing.

  // ⚠️ THE CLOSING LINE THE BRIEF ASKS FOR, VERBATIM. It is why
  // `TtcFocusPage.closingLine` exists — After a loss asked for one first and
  // was held, on the grounds that one caller does not justify a field.
  closingLine: 'This is about spending the wait well and arriving at '
      'conception calmer and healthier.',

  sections: [
    // =========================================================================
    //  Hard days (gap plan, 2026-09-26)
    // =========================================================================
    //  ⚠️ THE CHAT AND THE READ SIT TOGETHER. "My period came" is the scripted
    //  chat (rules only, no AI) that the period-logged message opens; the read
    //  beside it is the longer version of the same kindness.
    TtcFocusSection(
      heading: 'What helps when your period comes?',
      group: 'hard',
      tiles: [
        TtcToolTile(
          title: 'Talk it through',
          blurb: 'A short, gentle chat for the day your period comes.',
          surfaceId: 'ttc_chat/period_came',
        ),
        TtcArticleTile(
          title: 'What today means, and what it doesn\'t',
          blurb: 'A few small things that help you get to next month.',
          readId: 'ttc_read_period_came',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'When other people make it harder',
      group: 'hard',
      tiles: [
        TtcArticleTile(
          title: "When other people's pregnancy news is hard",
          blurb: "Why the envy comes, and why it doesn't make you a bad person.",
          readId: 'ttc_read_others_news',
        ),
        TtcArticleTile(
          title: 'Should you tell family you\'re trying?',
          blurb: 'What telling gives you, what it costs, and how to decide.',
          readId: 'ttc_read_telling_family',
        ),
        TtcArticleTile(
          title: 'Three answers for "Koi good news?"',
          blurb: 'A gentle answer and a firmer one, for each person who asks.',
          readId: 'ttc_read_good_news_answers',
        ),
        // Moved here from Talk, "The people around you" (2026-09-27,
        // relevance audit): it answers the same questions as the two above.
        TtcGuideTile(
          title: 'When family keeps asking',
          blurb: "What to say, what you owe them, and what you don't.",
          readId: 'ttc_read_family_asking',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'When it goes on for months',
      group: 'hard',
      tiles: [
        TtcArticleTile(
          title: 'When trying takes over your life',
          blurb: 'How to notice, and how to give it a smaller place.',
          readId: 'ttc_read_trying_takes_over',
        ),
        TtcArticleTile(
          title: "Coping when month after month doesn't work",
          blurb: 'How to look after each other, and where to get help.',
          readId: 'ttc_read_month_after_month',
        ),
      ],
    ),

    // =========================================================================
    //  Understand
    // =========================================================================
    TtcFocusSection(
      heading: 'About stress',
      group: 'understand',
      tiles: [
        // reuse, locked — not retitled, not rewritten.
        TtcArticleTile(
          title: 'Stress, and the thing everyone says about it',
          blurb: 'What the evidence shows, and why "just relax" is wrong and '
              'unkind.',
          readId: _kStress,
        ),
        TtcVideoTile(
          title: 'Why "just relax" is the wrong advice',
          blurb: 'Parmeshwari, in under five minutes.',
          slotId: 'ttc_vid_stress_fertility',
          duration: '5 MIN',
        ),
        // ⚠️ WRITTEN OUT RATHER THAN PROMOTED — see the file header. Both
        // halves restate the article's opening argument.
        TtcMythTile(
          // D14 (2026-09-28): every myth card is titled as the question, so a
          // true statement never sits under a Myth vs fact chip. Kept for
          // revert: title: 'Stop thinking about it and it will happen',
          title: 'Will it happen if you stop thinking about it?',
          blurb: 'The advice everyone gives, and what the evidence says.',
          myth: "If you stop thinking about it, you'll conceive.",
          fact: 'The largest studies find that emotional distress before '
              "treatment doesn't decide whether it works. The advice also does "
              "harm. It makes you responsible for something you can't "
              "control, and turns every month that doesn't work into proof you "
              "weren't calm enough.",
        ),
        TtcGuideTile(
          title: 'Where stress does have a real effect',
          blurb: "The one honest exception, and why it isn't the everyday "
              'worry of trying.',
          readId: _kStress,
          atHeading: 'When does stress have a real effect?',
        ),
      ],
    ),

    TtcFocusSection(
      // MB16 (2026-09-28): Garbh Sanskar, capitalised as on the home. Kept
      // for revert: heading: 'What garbh sanskar is',
      heading: 'What Garbh Sanskar is',
      group: 'understand',
      tiles: [
        TtcArticleTile(
          title: 'Preconception garbh sanskar, honestly',
          blurb: "What the tradition is, what it's good for, and what it "
              "doesn't claim.",
          readId: _kGarbh,
        ),
        // ⚠️ THE BRIEF'S TITLE FOR THIS CARD IS "Preconception garbh sanskar,
        // taught", AND IT CANNOT BE USED. Tried on 2026-09-10 and reverted the
        // same day, because it fails `ttc_focus_page_test.dart`'s rule that no
        // two tiles in one section may open with the same three words — the
        // article directly above is "Preconception garbh sanskar, honestly".
        //
        // That rule is not a house preference. It was added on 2026-09-03 after
        // two pairs shipped in Getting ready and the user reported both **on
        // sight** as one card printed twice. Taking an exemption here would
        // reintroduce, deliberately, the exact thing that was complained about.
        //
        // What `reuse` actually protects is the ITEM, and the item is
        // untouched: the film's own title in `ttc_videos_data.dart` is still
        // "Preconception garbh sanskar, taught". This is the card in front of
        // it, and it keeps the brief's load-bearing word — taught — while
        // opening on three different words.
        //
        // Recorded as a real conflict between the brief and a shipped
        // invariant in `docs/STILL-OPEN.md` §32.8 rather than settled quietly.
        TtcVideoTile(
          title: 'The eight sessions, taught',
          blurb: 'Garbh sanskar done with you, not just described. For both '
              'of you, and nothing to believe in.',
          slotId: 'ttc_vid_garbh_preconception',
          duration: '36 MIN',
        ),
        TtcMythTile(
          title: 'Does it make a smarter baby?',
          blurb: "What the tradition can fairly claim, and what it can't.",
          myth: 'Doing this shapes your baby\'s intelligence and nature.',
          fact: "No. There's no controlled evidence that any practice before "
              "conception changes a child's intelligence or temperament. The "
              "tradition itself doesn't promise it. That claim comes from the "
              'people selling programmes. The practice is worth doing for how '
              "the months feel, and that's a full reason on its own.",
        ),
        TtcGuideTile(
          title: "And if you're not religious",
          blurb: 'The practice works without the belief, and loses nothing '
              'that way.',
          readId: _kGarbh,
          atHeading: 'What is it good for?',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'What a practice is for',
      group: 'understand',
      tiles: [
        TtcGuideTile(
          title: 'What a daily practice is for',
          // ⚠️ "Not a better chance" WAS AN EARLIER ATTEMPT, AND THE SCANNER
          // WAS RIGHT TO REJECT IT. The sentence denies the claim — but it
          // denies it by printing it, and a card skimmed on a rail leaves
          // "better chance" on the page beside a practice. Denials that quote
          // the claim are how a position erodes without anybody writing
          // something false.
          //
          // The brief's own line does the same work without the phrase, which
          // is why it is the brief's line and not a third attempt at mine.
          blurb: "Not to make it happen. What it's really good for.",
          readId: _kStress,
          atHeading: 'So what is a daily practice for?',
        ),
        // ⚠️ ITS OWN LANDING (2026-09-27, relevance audit). It opened the
        // same section as the card above. The garbh sanskar read's "What does
        // a daily practice look like?" is the one that says keep it short.
        // Kept for revert (2026-09-27, relevance audit):
        //   readId: _kStress,
        //   atHeading: 'So what is a daily practice for?',
        TtcGuideTile(
          title: 'Five minutes, and not as a target',
          blurb: 'Keep it short enough that missing a day costs nothing.',
          readId: _kGarbh,
          atHeading: 'What does a daily practice look like?',
        ),
      ],
    ),

    // =========================================================================
    //  The practice — the library, and the single source
    // =========================================================================
    // ⚠️ THE ONLY REASON THIS WHOLE PAGE IS `final` AND NOT `const`. Dart
    // will not call a function inside a const list, and the alternative is
    // typing twelve tiles out here — a second copy of every practice title and
    // blurb, which is the duplication the brief warns about most loudly and
    // the kind that compiles, looks right, and drifts silently.
    //
    // The cost is real and worth stating: you cannot read this section's
    // contents in this file. That is the correct trade — somebody who wants to
    // know what is in the Move library should be reading the library.
    TtcFocusSection(
      heading: 'Move',
      group: 'practice',
      tiles: _practiceTiles(TtcPracticeKind.move),
    ),
    TtcFocusSection(
      heading: 'Breathe and calm',
      group: 'practice',
      tiles: _practiceTiles(TtcPracticeKind.breathe),
    ),

    TtcFocusSection(
      heading: 'Go deeper',
      group: 'practice',
      tiles: [
        TtcVideoTile(
          title: 'A longer session this week',
          blurb: 'One longer practice, for a day when you have time.',
          slotId: 'ttc_vid_mind_longer_session',
          duration: '25 MIN',
        ),
        // ⚠️ REUSE, AND IT IS FREE. It is a `TtcDoTile` rather than a
        // `TtcMasterclassTile` because the masterclass chip is the app's paid
        // marker — see `isPaid` — and this course costs nothing. A free thing
        // wearing the paid chip is the one labelling mistake this area cannot
        // afford.
        //
        // ⚠️ IT OPENED `ttc_prepare` UNTIL 2026-09-10, AND THAT WAS THE WIRING
        // GATE FAILING QUIETLY. `ttc_prepare` is the Prepare catalogue, where
        // the course was one card DESCRIBING eight sessions at a price of zero.
        // So a tile whose own blurb says "taught properly rather than
        // described" landed on the description — reachable, tappable, wrong, and
        // invisible to any test that only asks whether the tile opens
        // something. `ttc_garbh_course` is the course itself.
        TtcDoTile(
          title: 'The free garbh sanskar course, eight sessions',
          blurb: 'For both of you, taught properly, not just described. No fee.',
          surfaceId: 'ttc_garbh_course',
        ),
      ],
    ),

    // =========================================================================
    //  Getting ready in body and mind — referenced, never re-taught
    // =========================================================================
    // ⚠️ EVERY TILE IN THE FIRST THREE SECTIONS CARRIES A `ttc_read_*` ID THAT
    // GETTING READY OWNS. Not a summary of it, not "the key points" — the
    // article itself. The brief's rule is *"do not re-teach food, supplements,
    // smoking, alcohol, weight or tests in Sub-tab 4"*, and the only way to
    // keep that rule permanently is to have nothing here that could drift.
    // ⚠️ THE THREE REFERENCE SECTIONS ARE OFF THIS TAB (2026-09-27, relevance
    // audit). A door that promises a few calm minutes a day was showing
    // blood tests, vaccines, folic acid and tobacco, and all nine tiles
    // repeated Getting ready. The tab stays, as the checklist lists it, cut
    // to Sleep and routine and one labelled way to Getting ready below.
    // Kept for revert (2026-09-27, relevance audit):
    // TtcFocusSection(
    //   heading: 'Food and supplements',
    //   group: 'ready',
    //   tiles: [
    //     TtcArticleTile(
    //       title: 'What to eat before you start',
    //       blurb: 'From Getting ready. Real food, no targets.',
    //       readId: 'ttc_read_three_months_before',
    //       atHeading: 'What should I eat?',
    //     ),
    //     TtcArticleTile(
    //       title: 'Folic acid, and when to start it',
    //       blurb: 'The one item here with really strong evidence behind it.',
    //       readId: 'ttc_read_folic_acid',
    //     ),
    //     TtcArticleTile(
    //       title: 'Vitamin D, B12 and iron',
    //       blurb: 'When to start what, and how early.',
    //       readId: 'ttc_read_supplement_timing',
    //       // Lands on the section that answers the tile (launch walk, 2026-09-27).
    //       atHeading: 'Should I take vitamin D?',
    //     ),
    //   ],
    // ),
    //
    // TtcFocusSection(
    //   heading: 'Habits worth changing',
    //   group: 'ready',
    //   tiles: [
    //     TtcArticleTile(
    //       title: 'Smoking and tobacco, in every form',
    //       blurb: 'Including being around it.',
    //       readId: 'ttc_read_what_to_cut',
    //       atHeading: 'Does smoking matter, even second-hand?',
    //     ),
    //     TtcArticleTile(
    //       title: 'Alcohol, honestly',
    //       blurb: "What's known, without the scolding.",
    //       readId: 'ttc_read_what_to_cut',
    //       atHeading: 'Do I need to stop drinking?',
    //     ),
    //     TtcArticleTile(
    //       title: 'Weight, said kindly',
    //       blurb: 'In both directions, and with no number to hit.',
    //       readId: 'ttc_read_weight_kindly',
    //     ),
    //   ],
    // ),
    //
    // TtcFocusSection(
    //   heading: 'Checks worth doing',
    //   group: 'ready',
    //   tiles: [
    //     TtcArticleTile(
    //       title: 'Tests before you start trying',
    //       blurb: 'The blood tests worth doing once.',
    //       readId: 'ttc_read_preconception_tests',
    //       atHeading: 'Which blood tests should I have?',
    //     ),
    //     TtcArticleTile(
    //       title: 'Vaccines to check',
    //       blurb: 'And why the timing matters more than the list.',
    //       readId: 'ttc_read_preconception_tests',
    //       atHeading: 'Which vaccines do I need, and why does timing matter?',
    //     ),
    //     // ⚠️ THE ONE CARD THAT OPENS AN AREA RATHER THAN A PIECE, and the
    //     // reason `TtcDoorTile` exists. The brief marks it "reference (opens
    //     // the His side focus area)".
    //     TtcDoorTile(
    //       title: 'His part of this',
    //       blurb: 'Half of this is his. The His side area covers all of it.',
    //       bracketId: 'ttc_male_fertility',
    //     ),
    //   ],
    // ),

    // The one section in this tab that Mind & body owns.
    // MB20 (2026-09-28): the tab is called Sleep and routine now, so the
    // section says what it answers. Kept for revert: heading: 'Sleep and routine',
    TtcFocusSection(
      heading: 'How do you sleep better while trying?',
      group: 'ready',
      tiles: [
        TtcGuideTile(
          title: "Why sleep matters when you're trying",
          blurb: 'Not because it makes conception happen.',
          readId: 'ttc_read_sleep_trying',
        ),
        TtcGuideTile(
          title: 'Setting a bedtime you can keep',
          blurb: 'Bedtimes fail for three reasons. None is willpower.',
          readId: 'ttc_read_bedtime',
        ),
        // ⚠️ A WAY TO CALM DOWN, NOT AN ESSAY ABOUT WHY (2026-09-27,
        // relevance audit). The card promised ways to stay calm and opened
        // the stress read's section on what a practice is for. The long
        // out-breath is the practice library's own, done sitting or lying,
        // which is what a bedtime section wants.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcGuideTile(
        //   title: 'Ways to stay calm',
        //   blurb: 'What helps while you wait.',
        //   readId: _kStress,
        //   atHeading: 'So what is a daily practice for?',
        // ),
        TtcDoTile(
          title: 'A calming breath for bedtime',
          blurb: 'One minute, sitting or lying. Breathing out for longer than '
              'you breathe in is what does the work.',
          surfaceId: 'ttc_practice/mb_longout',
        ),
      ],
    ),

    // The one labelled way to the rest of getting ready (2026-09-27,
    // relevance audit). It replaces the three sections commented out above.
    TtcFocusSection(
      heading: 'Food, tests and habits',
      group: 'ready',
      tiles: [
        TtcDoorTile(
          title: 'More in Getting ready',
          blurb: 'Food, folic acid, tests, vaccines and habits for the months '
              'before, for both of you, in their own door.',
          bracketId: 'ttc_preconception_health',
        ),
      ],
    ),

    // =========================================================================
    //  Talk
    // =========================================================================
    TtcFocusSection(
      heading: 'The people around you',
      group: 'talk',
      tiles: [
        // Retitled (2026-09-27, relevance audit): "this advice" meant "just
        // relax", which nothing on this tab had said. Kept for revert:
        //   title: 'What to say to people who keep offering this advice',
        TtcGuideTile(
          title: 'When people tell you to "just relax"',
          blurb: 'What to say, and how to protect the two of you from it.',
          readId: _kStress,
          atHeading: 'The people around you',
        ),
        // Moved to Hard days, "When other people make it harder" (2026-09-27,
        // relevance audit). Kept for revert:
        // TtcGuideTile(
        //   title: 'When family keeps asking',
        //   blurb: "What to say, what you owe them, and what you don't.",
        //   readId: 'ttc_read_family_asking',
        // ),
        // Moved here from "Talk to someone" (2026-09-27, relevance audit): it
        // is about the two of you, not about a professional.
        TtcGuideTile(
          title: 'Bringing him into this',
          blurb: 'Why it becomes one person\'s job, and what changes it.',
          readId: 'ttc_read_bringing_him_in',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Talk to someone',
      group: 'talk',
      tiles: [
        // ⚠️ THE PSYCHOLOGIST THE CARD NAMES AND PRICES (2026-09-27, relevance
        // audit). `kTtcActConsult` opens fertility, gynaecology and male
        // fertility, with no psychologist on it. `ttc_psych_consult` is the
        // ₹799 session this blurb quotes.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcTalkTile(
        //   title: 'Talk to a psychologist',
        //   blurb: 'A private talk with someone who does this work. ₹799.',
        //   action: kTtcActConsult,
        // ),
        TtcTalkTile(
          title: 'Talk to a psychologist',
          blurb: 'A private talk with someone who does this work. ₹799.',
          action: 'ttc_psych_consult',
        ),
        // Moved to "The people around you" (2026-09-27, relevance audit).
        // Kept for revert:
        // TtcGuideTile(
        //   title: 'Bringing him into this',
        //   blurb: 'Why it becomes one person\'s job, and what changes it.',
        //   readId: 'ttc_read_bringing_him_in',
        // ),
        // Added 2026-09-26 (gap plan, owed from W5). On Talk because it is
        // about who to talk to; its own callout carries 112 and 181.
        TtcArticleTile(
          title: "When home doesn't feel safe",
          blurb: 'What it can look like, and who can help in India.',
          readId: 'ttc_read_relationship_safety',
        ),
      ],
    ),
  ],
);
