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

import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
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

  intro: 'Preparing your mind and body to conceive well. A few minutes a day, '
      'both of you, and nothing here you have to believe in.',

  heroImageUrl:
      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=900&h=700&fit=crop',
  heroBlurb: 'Move a little, breathe a little, sleep and eat like someone who '
      'is looking after themselves. That is the whole practice, and it is worth '
      'doing because of how the waiting feels — not because of what it '
      'promises.',

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
      id: 'today',
      label: 'Today',
      icon: Icons.wb_sunny_outlined,
      hue: 160,
      toolSurfaceId: 'ttc_mind_today',
    ),
    TtcFocusGroup(
        id: 'understand',
        label: 'Understand',
        icon: Icons.menu_book_outlined,
        hue: 206),
    TtcFocusGroup(
      id: 'practice',
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
        id: 'ready',
        label: 'Getting ready',
        icon: Icons.checklist_rtl_rounded,
        hue: 42),
    // ⚠️ BOTH FLAGS, ON ONE TAB, FROM TWO DIFFERENT ARTICLES. This is what
    // turned `pinnedRedFlagReadId` into a list on 2026-09-05 — After a loss
    // wanted two and happened to want them on separate tabs, so the singular
    // field fit by luck. The self-harm routing lives inside the first of these
    // and the brief says explicitly not to bury it; rendering the article's own
    // callout whole is what guarantees it travels.
    TtcFocusGroup(
      id: 'talk',
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
    //  Understand
    // =========================================================================
    TtcFocusSection(
      heading: 'About stress',
      group: 'understand',
      tiles: [
        // reuse, locked — not retitled, not rewritten.
        TtcArticleTile(
          title: 'Stress, and the thing everyone says about it',
          blurb: 'What the evidence actually shows, and why "just relax" is '
              'both wrong and cruel.',
          readId: _kStress,
        ),
        TtcVideoTile(
          title: '"Just relax" — why that advice is wrong',
          blurb: 'Dr. Sharanya Menon, in under five minutes.',
          slotId: 'ttc_vid_stress_fertility',
          duration: '5 MIN',
        ),
        // ⚠️ WRITTEN OUT RATHER THAN PROMOTED — see the file header. Both
        // halves restate the article's opening argument.
        TtcMythTile(
          title: 'Stop thinking about it and it will happen',
          blurb: 'The advice everyone gives, and what the evidence actually '
              'says.',
          myth: 'If you stop thinking about it, you will conceive.',
          fact: 'The largest analyses find that emotional distress before '
              'treatment does not determine whether it works. The advice also '
              'does damage: it hands you responsibility for something you do '
              'not control, and turns every month that does not work into '
              'evidence you were not calm enough.',
        ),
        TtcGuideTile(
          title: 'Where stress does have a real effect',
          blurb: 'The one honest exception, and why it is not the everyday '
              'worry of trying.',
          readId: _kStress,
          atHeading: 'Where stress does have a real effect',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'What garbh sanskar is',
      group: 'understand',
      tiles: [
        TtcArticleTile(
          title: 'Preconception garbh sanskar, honestly',
          blurb: 'What the tradition is, what it is good for, and what it '
              'does not claim.',
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
          blurb: 'Garbh sanskar done with you rather than described. Both of '
              'you, and nothing to believe in.',
          slotId: 'ttc_vid_garbh_preconception',
          duration: '36 MIN',
        ),
        TtcMythTile(
          title: 'Does it make a smarter baby?',
          blurb: 'What the tradition can reasonably claim, and what it '
              'cannot.',
          myth: 'Doing this shapes your baby\'s intelligence and nature.',
          fact: 'No. There is no controlled evidence that any preconception '
              'practice changes a child\'s intelligence or temperament, and '
              'the tradition itself does not promise it — the claim belongs to '
              'the people selling programmes. The practice is worth doing for '
              'how the months feel, which is a complete reason on its own.',
        ),
        TtcGuideTile(
          title: 'And if you are not religious',
          blurb: 'The practice works without the framework, and nothing about '
              'it is diminished.',
          readId: _kGarbh,
          atHeading: 'What it is good for',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'What a practice is actually for',
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
          blurb: 'Not to make it happen. What it is genuinely good for.',
          readId: _kStress,
          atHeading: 'So what is a daily practice actually for',
        ),
        TtcGuideTile(
          title: 'Five minutes, and not as a target',
          blurb: 'Keep it short enough that missing a day costs nothing.',
          readId: _kStress,
          atHeading: 'So what is a daily practice actually for',
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
          blurb: 'One longer practice, for a day you have the time.',
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
          blurb: 'Both of you, taught properly rather than described. No fee.',
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
    TtcFocusSection(
      heading: 'Food and supplements',
      group: 'ready',
      tiles: [
        TtcArticleTile(
          title: 'What to eat before you start',
          blurb: 'Owned by Getting ready. Real food, no targets.',
          readId: 'ttc_read_three_months_before',
          atHeading: 'What to actually eat',
        ),
        TtcArticleTile(
          title: 'Folic acid, and when to start it',
          blurb: 'The one item here with genuinely strong evidence.',
          readId: 'ttc_read_folic_acid',
        ),
        TtcArticleTile(
          title: 'Vitamin D, B12 and iron',
          blurb: 'When to start what, and how early.',
          readId: 'ttc_read_supplement_timing',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Habits worth changing',
      group: 'ready',
      tiles: [
        TtcArticleTile(
          title: 'Smoking and tobacco, in every form',
          blurb: 'Including being around it.',
          readId: 'ttc_read_what_to_cut',
          atHeading: 'Smoking, and being around it',
        ),
        TtcArticleTile(
          title: 'Alcohol, honestly',
          blurb: 'What is known, without the scolding.',
          readId: 'ttc_read_what_to_cut',
          atHeading: 'Alcohol, honestly',
        ),
        TtcArticleTile(
          title: 'Weight, said kindly',
          blurb: 'In both directions, and with no number to hit.',
          readId: 'ttc_read_weight_kindly',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Checks worth doing',
      group: 'ready',
      tiles: [
        TtcArticleTile(
          title: 'Tests before you start trying',
          blurb: 'The blood tests worth doing once.',
          readId: 'ttc_read_preconception_tests',
          atHeading: 'The blood tests worth doing once',
        ),
        TtcArticleTile(
          title: 'Vaccines to check',
          blurb: 'And why the timing matters more than the list.',
          readId: 'ttc_read_preconception_tests',
          atHeading: 'The vaccinations, and why the timing matters',
        ),
        // ⚠️ THE ONE CARD THAT OPENS AN AREA RATHER THAN A PIECE, and the
        // reason `TtcDoorTile` exists. The brief marks it "reference (opens
        // the His side focus area)".
        TtcDoorTile(
          title: 'His part of this',
          blurb: 'Half of this is his. His side has the whole of it.',
          bracketId: 'ttc_male_fertility',
        ),
      ],
    ),

    // The one section in this tab that Mind & body owns.
    TtcFocusSection(
      heading: 'Sleep and routine',
      group: 'ready',
      tiles: [
        TtcGuideTile(
          title: 'Why sleep matters when you are trying',
          blurb: 'Not because it makes conception happen.',
          readId: 'ttc_read_sleep_trying',
        ),
        TtcGuideTile(
          title: 'Fixing a bedtime you will actually keep',
          blurb: 'Bedtimes fail for three reasons. None is willpower.',
          readId: 'ttc_read_bedtime',
        ),
        TtcGuideTile(
          title: 'Ways to stay calm',
          blurb: 'What actually helps during the waiting.',
          readId: _kStress,
          atHeading: 'So what is a daily practice actually for',
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
        TtcGuideTile(
          title: 'What to say to people who keep offering this advice',
          blurb: 'And how to protect the two of you from it.',
          readId: _kStress,
          atHeading: 'The people around you',
        ),
        TtcGuideTile(
          title: 'When family keeps asking',
          blurb: 'What to say, what you owe them, and what you do not.',
          readId: 'ttc_read_family_asking',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Talk to someone',
      group: 'talk',
      tiles: [
        TtcTalkTile(
          title: 'Talking to a psychologist',
          blurb: 'A private conversation with someone who does this work. '
              '₹799.',
          action: kTtcActConsult,
        ),
        TtcGuideTile(
          title: 'Bringing him into this',
          blurb: 'Why it becomes one person\'s job, and what changes it.',
          readId: 'ttc_read_bringing_him_in',
        ),
      ],
    ),
  ],
);
