// =============================================================================
//  After a loss — the focus page for this door
// -----------------------------------------------------------------------------
//  Built 2026-09-04 from `ParentVeda_After_a_loss_rebuild.pdf`. Sixth door on
//  the shape PCOS, IVF, Getting ready and His side established — and the one
//  that departs from it in three deliberate places.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THREE DIFFERENCES FROM EVERY OTHER DOOR, ALL BECAUSE OF THE CONTEXT
//  ---------------------------------------------------------------------------
//
//  **1. "Your body" is the default tab, not "Understand".** Every other door
//  opens on explanation. Days after a loss the first need is physical
//  reassurance and the hospital red flag — not causes, and certainly not
//  whether it could have been prevented.
//
//  **2. There is no tool, and there will not be one.** PCOS has "Where do I
//  stand", IVF a readiness check, His side "Read your semen report". The only
//  candidate here is a recovery tracker, and turning miscarriage recovery into
//  a number to log is the one place a tool does harm rather than help. The
//  brief says so and it is right. ⚠️ **Do not add a tracker, a calculator or a
//  self-check to this area.** If anything is ever added it is a gentle "what is
//  normal in the next few weeks" explainer, never a countdown or a score.
//
//  **3. Two tabs pin a red flag above their rails.** A rail is a browse
//  surface, and a woman scanning cards has already been asked to make a choice.
//  Heavy bleeding and thoughts of self-harm do not wait for one.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NOTHING HERE IS REWRITTEN, AND MOST OF IT IS NOT EVEN MOVED
//  ---------------------------------------------------------------------------
//
//  Two long articles by Dr. Ananya Rao carry almost all of this area's text.
//  The brief's rule is that every card marked "reuse" or "promote" REFERENCES
//  the existing article by one content id — shown in a new place, never copied.
//
//  "Promote" is implemented with `atHeading`, which opens the article scrolled
//  to the named section. Without that, six promoted cards all open one article
//  at the top and a woman who tapped "Rh status and retained tissue" is left
//  hunting for the paragraph she was promised. See `TtcGuideTile.atHeading`.
//
//  ⚠️ THE HEADINGS BELOW ARE COPIED EXACTLY FROM THE ARTICLES. A typo opens at
//  the top instead — the safe failure — and `ttc_after_loss_test.dart` asserts
//  every one of them still resolves, so it does not fail silently either.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

// Unused since the consult tiles name their offering (2026-09-27,
// relevance audit). Kept for revert:
// import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
import '../ttc_focus_data.dart';

/// The two articles this whole area references.
const String _kRecovery = 'ttc_read_loss_recovery';
const String _kTryingAgain = 'ttc_read_trying_again';

// =============================================================================
//  After a loss
// =============================================================================

const TtcFocusPage kTtcAfterLossFocus = TtcFocusPage(
  bracketId: 'ttc_after_loss',

  // ⚠️ THE EXISTING HERO, KEPT WORD FOR WORD. The brief requires it, and the
  // second sentence is the most important one in the area.
  intro: 'Trying again, after a loss. No rush, and no timeline you have to '
      'keep.',
  // Our own photograph (2026-09-27): generated to the door's brief, checked by
  // eye, mirrored to the R2 bucket. Kept for revert: the previous value.

  // heroImageUrl: 'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=900&h=700&fit=crop',

  heroImageUrl: 'https://pub-bfbc0773e60e4c5c851b535f08b384bc.r2.dev/ttc_door_after_a_loss.jpg',
  // The new door's headline, a sentence (TtcDoorScreen, 2026-09-26).
  heroTitle: 'No rush, and no timeline to keep.',
  // ⚠️ NO PROMISE OF A COMMUNITY (launch walk, 2026-09-27): community is
  // held back for launch, so "people who've been through it too" pointed at
  // nothing. What is here: her Care Circle and a counsellor. Kept for revert:
  //   "…when it's safe to try again if you want to, and people who've "
  //   'been through it too.',
  heroBlurb: "What your body is doing now, what almost certainly didn't cause "
      "this, when it's safe to try again if you want to, and someone to talk "
      'to when you need it.',

  // ---------------------------------------------------------------------------
  //  Four tabs. Your body first — see the header.
  // ---------------------------------------------------------------------------
  // ⚠️ HUES ARE THE APP'S OWN AND DELIBERATELY QUIET HERE. 26 is this
  // bracket's warm ochre and leads; 206 the clinical blue; 160 the green the
  // stage uses for its own logged data; 344 the rose the community rooms wear.
  groups: [
    TtcFocusGroup(
      id: 'body', mark: IntentMark.bodyMark, tabMark: TtcTabMark.hotBottle,
      label: 'Your body',
      icon: Icons.favorite_border_rounded,
      hue: 26,
      // The hospital red flag — heavy bleeding, fever, severe pain. Rendered
      // from the article's own callout, not copied.
      //
      // ⚠️ THE ECTOPIC SIGNS ARE A TILE BELOW, NOT A SECOND PIN (2026-09-27,
      // relevance audit). Pinning the ectopic read's callout was tried: its
      // title is the same words as this one ("Go to a hospital today, not
      // tomorrow"), so the tab opened on two identical headlines stacked,
      // which reads as one card printed twice. The signs are a tile in
      // "What's happening now" instead. Tried and not kept:
      // pinnedRedFlagReadIds: [_kRecovery, 'ttc_read_ectopic_pregnancy'],
      pinnedRedFlagReadIds: [_kRecovery],
    ),
    TtcFocusGroup(
        id: 'understand', mark: IntentMark.bookMark, tabMark: TtcTabMark.openBook,
        // Kept for revert (2026-09-28, explicit names): label: 'Understand',
        label: 'Why losses happen',
        icon: Icons.menu_book_outlined,
        hue: 206),
    TtcFocusGroup(
        id: 'again', mark: IntentMark.sunMark, tabMark: TtcTabMark.sunrise,
        label: 'Trying again',
        icon: Icons.wb_twilight_rounded,
        hue: 160),
    TtcFocusGroup(
      id: 'support', mark: IntentMark.cuppedHands, tabMark: TtcTabMark.heartHand,
      // Kept for revert (2026-09-28, explicit names): label: 'Support',
      label: 'Support for you',
      icon: Icons.diversity_1_outlined,
      hue: 344,
      // ⚠️ THIS ONE CARRIES THE SELF-HARM ROUTING and the brief says in as many
      // words that it must not be lost or buried. It is the article's whole
      // callout, pinned above everything on the tab.
      pinnedRedFlagReadIds: [_kTryingAgain],
    ),
  ],

  // ⚠️ NO `headline` MASTERCLASS ON THIS PAGE, AND THAT IS NOT AN OVERSIGHT.
  // Every other door carries a paid course in the headline slot. The bracket
  // marks course `notCore` with a stated reason — "reached through a person,
  // not a product row" — and a course sold from the top of a page somebody
  // opened three days after a miscarriage is the single worst placement of a
  // price in this product. The group cohort is still reachable, from the
  // Support tab, described as four sessions with people rather than as an
  // offering.

  sections: [
    // =========================================================================
    //  1 — Your body (default)
    // =========================================================================
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: "What's happening now",
      heading: 'What is happening in your body now?',
      group: 'body',
      tiles: [
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Physical recovery, in plain terms',
          title: 'Physical recovery after a loss',
          id: 'ttc_tile_physical_recovery_after_a_loss',
          blurb: 'Bleeding, hormones, when your cycle comes back, and what to '
              'expect if you had a procedure.',
          readId: _kRecovery,
        ),
        TtcVideoTile(
          title: 'What the next few weeks look like',
          id: 'ttc_tile_what_the_next_few_weeks_look_like',
          blurb: 'Talked through gently, by a doctor who does this work.',
          slotId: 'ttc_vid_loss_recovery',
          duration: '5 MIN',
        ),
        // ⚠️ THE BRIEF ASKS FOR AN INFOGRAPHIC HERE AND THIS IS A GUIDE, ON
        // PURPOSE — 2026-09-04.
        //
        // `TtcInfographicTile` requires two real columns; there is no empty
        // state for it, and there should not be. An infographic about what
        // counts as normal bleeding after a miscarriage is clinical content
        // that a doctor writes, not something to draft into a placeholder so a
        // card exists.
        //
        // So the SLOT the brief wants is filled with something true today: the
        // article's own "The bleeding" section, promoted, which is exactly the
        // material the infographic will illustrate. When the picture is
        // supplied this becomes `TtcInfographicTile` and the guide steps aside.
        // Recorded in `docs/STILL-OPEN.md` §26.
        TtcGuideTile(
          title: 'What normal bleeding and spotting looks like',
          id: 'ttc_tile_what_normal_bleeding_and_spotting_looks_like',
          blurb: 'How long it lasts, how heavy it is, and how it changes with '
              'how the loss was managed.',
          readId: _kRecovery,
          atHeading: 'How long does the bleeding last?',
        ),
        // ⚠️ THE ECTOPIC SIGNS, ON THE TAB SHE OPENS FIRST (2026-09-27,
        // relevance audit). They were only in the third section of the
        // second tab. This opens the ectopic read at its signs; the read's
        // own urgent callout says go to a hospital today.
        TtcGuideTile(
          title: 'Ectopic signs that need a hospital today',
          id: 'ttc_tile_ectopic_signs_that_need_a_hospital_today',
          blurb: 'Pain on one side, shoulder-tip pain, bleeding with pain, or '
              'feeling faint.',
          readId: 'ttc_read_ectopic_pregnancy',
          atHeading: 'What are the signs?',
        ),
      ],
    ),

    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'The parts that get missed',
      heading: 'Which follow-ups get missed?',
      group: 'body',
      tiles: [
        // PROMOTED. The article folds this section on purpose — reading it on
        // day two is not what most people need — and folded content is exactly
        // what a promoted card is for: it stays folded in place, and it also
        // has a door of its own for the woman who needs it now.
        TtcGuideTile(
          title: 'Rh status and retained tissue',
          id: 'ttc_tile_rh_status_and_retained_tissue',
          blurb: 'The two follow-ups that get missed. One of them has a '
              'seventy-two hour window.',
          readId: _kRecovery,
          atHeading: 'Two things that get missed',
        ),
        TtcMythTile(
          // D14 (2026-09-28): every myth card is titled as the question, so a
          // true statement never sits under a Myth vs fact chip. Kept for
          // revert: title: 'You can ovulate before your first period',
          title: 'Can you ovulate before your first period?',
          id: 'ttc_tile_can_you_ovulate_before_your_first_period',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: "This matters a lot if you're not ready.",
          blurb: "Ovulation can come before the first period, which matters if you're not ready.",
          myth: "You can't get pregnant again until your period comes back.",
          fact: 'Ovulation usually comes back before the first period, often '
              'two to four weeks after a loss. So you can get pregnant again '
              "before you've had a period at all. If you don't want to "
              'conceive yet, use contraception now rather than waiting for a '
              "period to come. This isn't often mentioned, and it's kinder to "
              'read it here than to find out later.',
        ),
      ],
    ),

    // =========================================================================
    //  2 — Understand
    // =========================================================================
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'Could this have been prevented?',
      heading: 'Could the loss have been prevented?',
      group: 'understand',
      tiles: [
        TtcGuideTile(
          // Kept for revert (2026-09-28, explicit names): title: "It almost certainly couldn't have been prevented",
          title: 'Most early losses could not have been prevented',
          id: 'ttc_tile_most_early_losses_could_not_have_been_prevented',
          blurb: 'Most early losses are a chromosome error that was there from '
              "the beginning. It isn't inherited, and nobody caused it.",
          readId: _kTryingAgain,
          atHeading: "It almost certainly couldn't have been prevented",
        ),
        // The whole piece behind the card above: the real causes, and the
        // long list of everyday things that don't cause a loss.
        TtcArticleTile(
          title: 'What causes a miscarriage, and what doesn\'t',
          id: 'ttc_tile_what_causes_a_miscarriage_and_what_doesn_t',
          blurb: 'The real reasons, and the everyday things you can let go of.',
          readId: 'ttc_read_miscarriage_causes',
        ),
        // Moved to "When it's worth looking further" (2026-09-27, relevance
        // audit): it is about it happening again, not about prevention.
        // Kept for revert:
        // TtcMythTile(
        //   title: "One miscarriage isn't a pattern",
        //   blurb: "One loss doesn't change what comes next.",
        //   myth: "One miscarriage means it's likely to happen again.",
        //   fact: 'After a single loss, the chance for a next pregnancy is close '
        //       "to what it was before. One loss isn't a pattern, and it says "
        //       'nothing about your body. Things change after two or more, '
        //       'which is exactly why testing starts there and not here.',
        // ),
      ],
    ),

    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: "When it's worth looking further",
      heading: 'When is it worth looking for a cause?',
      group: 'understand',
      tiles: [
        TtcGuideTile(
          // Kept for revert (2026-09-28, explicit names): title: 'When to ask for tests',
          title: 'When to ask for tests after a loss',
          id: 'ttc_tile_when_to_ask_for_tests',
          blurb: 'After two losses, not three. ESHRE changed that line, and '
              "many places haven't caught up.",
          readId: _kTryingAgain,
          atHeading: 'When should you ask for tests?',
        ),
        // ⚠️ THE BRIEF ASKS FOR A SECOND CARD HERE — "What recurrent-loss
        // investigation looks like" — and it is NOT built. That content is the
        // third paragraph of the section above, not a section of its own, so a
        // second card would anchor to the same heading and land in the same
        // place. Two cards opening one paragraph is the fake promotion the
        // anchor exists to prevent.
        //
        // Splitting the article would fix it and means changing a
        // doctor-reviewed piece, which Step 2's rules forbid. Recorded in
        // `docs/STILL-OPEN.md` §26 as a content decision rather than papered
        // over.
        //
        // 2026-09-27 (relevance audit): that second card now exists as its
        // own piece, "Recurrent miscarriage", moved here from Trying again so
        // the one question is answered in one tab.
        TtcArticleTile(
          title: 'Recurrent miscarriage',
          id: 'ttc_tile_recurrent_miscarriage',
          blurb: 'Which tests help after more than one loss, and when.',
          readId: 'ttc_read_recurrent_miscarriage',
        ),
        // Moved here from "Could this have been prevented?" (2026-09-27,
        // relevance audit).
        TtcMythTile(
          // D14 (2026-09-28): every myth card is titled as the question, so a
          // true statement never sits under a Myth vs fact chip. Kept for
          // revert: title: "One miscarriage isn't a pattern",
          title: 'Does one miscarriage mean another?',
          id: 'ttc_tile_does_one_miscarriage_mean_another',
          blurb: "One loss doesn't change what comes next.",
          myth: "One miscarriage means it's likely to happen again.",
          fact: 'After a single loss, the chance for a next pregnancy is close '
              "to what it was before. One loss isn't a pattern, and it says "
              'nothing about your body. Things change after two or more, '
              'which is exactly why testing starts there and not here.',
        ),
      ],
    ),

    // ⚠️ ADDED 2026-09-26 FROM THE GAP PLAN. Two kinds of early loss that are
    // named on a report and rarely explained, each with its own piece. The ectopic
    // read carries "go to a hospital today" in its own callout; the Your body
    // tab's pinned flag still covers heavy bleeding, fever and fainting.
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'What kind of loss was it?',
      heading: 'What kind of loss did you have?',
      group: 'understand',
      tiles: [
        TtcArticleTile(
          title: 'Chemical pregnancy',
          id: 'ttc_tile_chemical_pregnancy',
          blurb: 'When a positive test turns into a period, and what it means.',
          readId: 'ttc_read_chemical_pregnancy',
        ),
        TtcArticleTile(
          title: 'Ectopic pregnancy',
          id: 'ttc_tile_ectopic_pregnancy',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'The signs that need a hospital today, and what comes after.',
          blurb: 'What an ectopic pregnancy is, how it is treated, and trying again after one.',
          readId: 'ttc_read_ectopic_pregnancy',
        ),
      ],
    ),

    // =========================================================================
    //  3 — Trying again
    // =========================================================================
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'When, and who decides',
      heading: 'When can you try again?',
      group: 'again',
      tiles: [
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'On trying again',
          title: 'When to try again, and who decides',
          id: 'ttc_tile_when_to_try_again_and_who_decides',
          blurb: "When it's safe, what the evidence says about waiting, and "
              'who decides.',
          readId: _kTryingAgain,
        ),
        TtcMythTile(
          // D14 (2026-09-28): every myth card is titled as the question, so a
          // true statement never sits under a Myth vs fact chip. Kept for
          // revert: title: 'The six-month wait, and where it came from',
          title: 'Do you have to wait six months?',
          id: 'ttc_tile_do_you_have_to_wait_six_months',
          blurb: 'One 2007 recommendation, one study, and what the evidence '
              'has shown since.',
          myth: 'You have to wait three to six months before trying again.',
          fact: 'That advice goes back to a 2007 WHO recommendation based '
              'mostly on a single study. Larger studies since then, including '
              'a Norwegian one of nearly seventy-three thousand pregnancies, '
              "haven't found the harm it assumed. For an early loss with no "
              "complications, there's no medical reason to wait months. Many "
              'doctors suggest waiting for one normal period, for a practical '
              'reason: it makes the next pregnancy easier to date. If your own '
              'doctor has told you to wait, ask what their reason is rather '
              "than assuming it's the general advice.",
        ),
      ],
    ),

    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'If and when you do',
      heading: 'If and when you try again',
      group: 'again',
      tiles: [
        TtcGuideTile(
          title: 'What to do differently next time',
          id: 'ttc_tile_what_to_do_differently_next_time',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: "It's a short list, shorter than the internet suggests.",
          blurb: 'The list of changes is short, shorter than the internet suggests.',
          readId: _kTryingAgain,
          atHeading: 'If and when you do try again',
        ),
        // ⚠️ THE BRIEF'S OPTIONAL "On trying again" VIDEO IS NOT BUILT. There
        // is one loss video slot in the catalogue and it is already used above.
        // Inventing a second slot id would put a card on the page that no file
        // can ever be mapped to — a coming-soon that is coming from nowhere.
        // Recorded in §26; it is one entry in `ttc_videos_data.dart` away.
        TtcArticleTile(
          title: 'Trying again: the feelings',
          id: 'ttc_tile_trying_again_the_feelings',
          blurb: 'Fear, guilt and hope, often in the same day.',
          readId: 'ttc_read_loss_feelings',
        ),
      ],
    ),

    // ⚠️ MOVED TO UNDERSTAND, "When it's worth looking further" (2026-09-27,
    // relevance audit). The same question was answered in two tabs.
    // Kept for revert (2026-09-27, relevance audit):
    // // ⚠️ ADDED 2026-09-26. Testing after more than one loss, in Trying again
    // // because it is the question asked before the next attempt. The
    // // Understand card "When to ask for tests" opens the short answer in the
    // // older read; this is the full piece.
    // TtcFocusSection(
    //   heading: 'What if it has happened more than once?',
    //   group: 'again',
    //   tiles: [
    //     TtcArticleTile(
    //       title: 'Recurrent miscarriage',
    //       blurb: 'Which tests help after more than one loss, and when.',
    //       readId: 'ttc_read_recurrent_miscarriage',
    //     ),
    //   ],
    // ),

    // =========================================================================
    //  4 — Support
    // =========================================================================
    TtcFocusSection(
      // Retitled (2026-09-27, relevance audit). The heading promised people
      // with lived loss, a room that is held back for launch; what is here
      // is her Care Circle, the people she chose. Kept for revert:
      // heading: 'People who have been here',
      heading: 'The people close to you',
      group: 'support',
      tiles: [
        // Community held back for launch (2026-09-26, TTC gap plan §7.1) — kept for revert.
        // TtcCommunityTile(
        //   title: 'Loss & Recovery room',
        //   blurb: 'A gentle space. Nobody gives you a timeline or a bright side, '
        //       'and nobody gives advice unless you ask for it.',
        //   surfaceId: 'ttc_community',
        // ),
        TtcCommunityTile(
          title: 'Your Care Circle',
          id: 'ttc_tile_your_care_circle',
          // She has not chosen anyone yet: the circle is filled by the app
          // and her partner (2026-09-27). Kept for revert: 'The people you
          // chose. As much or as little as you want.'
          blurb: 'Who is with you in this, and where advice comes from.',
          surfaceId: 'ttc_care_circle',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Talk to someone',
      group: 'support',
      tiles: [
        // ⚠️ THE PSYCHOLOGIST, NOT THE MEDICAL SHELF (2026-09-27, relevance
        // audit). `kTtcActConsult` opens fertility, gynaecology and male
        // fertility; no counsellor is on it. `ttc_psych_consult` is the
        // private session with the psychologist.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcTalkTile(
        //   title: 'Someone who knows this kind of loss',
        //   blurb: 'A counsellor who works with pregnancy loss, or a doctor who '
        //       'can look at what happened. At your own pace.',
        //   action: kTtcActConsult,
        // ),
        TtcTalkTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Someone who knows this kind of loss',
          title: 'A psychologist who knows pregnancy loss',
          id: 'ttc_tile_someone_who_knows_this_kind_of_loss',
          blurb: 'A private talk with a psychologist, at your own pace.',
          action: 'ttc_psych_consult',
        ),
        // "When grief needs extra help", which the checklist asks for here
        // (2026-09-27, relevance audit). The read's own section, with the
        // signs and where to call.
        TtcGuideTile(
          title: 'When grief needs more help',
          id: 'ttc_tile_when_grief_needs_more_help',
          blurb: 'The signs it is getting heavier, not easier, and who to '
              'call.',
          readId: 'ttc_read_loss_feelings',
          atHeading: 'When does grief need more help?',
        ),
        // ⚠️ THE ONE PAID THING THIS AREA ALLOWS, AND IT IS LAST, AND IT IS
        // DESCRIBED AS PEOPLE. The bracket marks course `notCore` — "reached
        // through a person, not a product row" — so it appears here, at the
        // foot of the tab about support, rather than in the headline slot
        // every other door uses. Its blurb carries no price.
        TtcMasterclassTile(
          title: 'After a loss, four sessions',
          id: 'ttc_tile_after_a_loss_four_sessions',
          blurb: 'A small group, led by a counsellor, over four weeks. With '
              "people who've been through what you have.",
          offeringId: 'ttc_loss_support',
        ),
      ],
    ),
  ],
);
