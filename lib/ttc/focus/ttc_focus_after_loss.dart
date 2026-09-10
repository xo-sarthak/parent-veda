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

import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
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

  heroImageUrl:
      'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=900&h=700&fit=crop',
  heroBlurb: 'What your body is doing now, what almost certainly did not cause '
      'this, when trying again is safe if you want to, and people who have '
      'been exactly here.',

  // ---------------------------------------------------------------------------
  //  Four tabs. Your body first — see the header.
  // ---------------------------------------------------------------------------
  // ⚠️ HUES ARE THE APP'S OWN AND DELIBERATELY QUIET HERE. 26 is this
  // bracket's warm ochre and leads; 206 the clinical blue; 160 the green the
  // stage uses for its own logged data; 344 the rose the community rooms wear.
  groups: [
    TtcFocusGroup(
      id: 'body',
      label: 'Your body',
      icon: Icons.favorite_border_rounded,
      hue: 26,
      // The hospital red flag — heavy bleeding, fever, severe pain. Rendered
      // from the article's own callout, not copied.
      pinnedRedFlagReadIds: [_kRecovery],
    ),
    TtcFocusGroup(
        id: 'understand',
        label: 'Understand',
        icon: Icons.menu_book_outlined,
        hue: 206),
    TtcFocusGroup(
        id: 'again',
        label: 'Trying again',
        icon: Icons.wb_twilight_rounded,
        hue: 160),
    TtcFocusGroup(
      id: 'support',
      label: 'Support',
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
      heading: "What's happening now",
      group: 'body',
      tiles: [
        TtcArticleTile(
          title: 'Physical recovery, in plain terms',
          blurb: 'Bleeding, hormones, when your cycle comes back, and what to '
              'expect if you had a procedure.',
          readId: _kRecovery,
        ),
        TtcVideoTile(
          title: 'What the next few weeks look like',
          blurb: 'Walked through gently, by a doctor who does this.',
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
          blurb: 'How long, how heavy, and how it differs depending on how the '
              'loss was managed.',
          readId: _kRecovery,
          atHeading: 'The bleeding',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'The parts that get missed',
      group: 'body',
      tiles: [
        // PROMOTED. The article folds this section on purpose — reading it on
        // day two is not what most people need — and folded content is exactly
        // what a promoted card is for: it stays folded in place, and it also
        // has a door of its own for the woman who needs it now.
        TtcGuideTile(
          title: 'Rh status and retained tissue',
          blurb: 'The two follow-ups that get missed. One of them has a '
              'seventy-two hour window.',
          readId: _kRecovery,
          atHeading: 'Two things that get missed',
        ),
        TtcMythTile(
          title: 'You can ovulate before your first period',
          blurb: 'Which matters a great deal if you are not ready.',
          myth: 'You cannot get pregnant again until your period comes back.',
          fact: 'Ovulation usually returns before the first period — often two '
              'to four weeks after a loss — so pregnancy is possible again '
              'before you have had a period at all. If you would not want to '
              'conceive yet, that means using contraception now rather than '
              'waiting for a period to arrive. This is not usually mentioned, '
              'and finding out afterwards is worse than reading it here.',
        ),
      ],
    ),

    // =========================================================================
    //  2 — Understand
    // =========================================================================
    TtcFocusSection(
      heading: 'Was this preventable?',
      group: 'understand',
      tiles: [
        TtcGuideTile(
          title: 'It was almost certainly not preventable',
          blurb: 'Most early losses are a chromosomal error present from the '
              'beginning. Not inherited, not caused, not preventable.',
          readId: _kTryingAgain,
          atHeading: 'It was almost certainly not preventable',
        ),
        TtcMythTile(
          title: 'A miscarriage is not a pattern',
          blurb: 'One loss does not change what comes next.',
          myth: 'One miscarriage means it is likely to happen again.',
          fact: 'After a single loss, the chance for a next pregnancy is close '
              'to what it was before. One loss is not a pattern, and it is not '
              'evidence of anything about your body. The picture changes after '
              'two or more, which is exactly why the threshold for looking '
              'into it sits there and not here.',
        ),
      ],
    ),

    TtcFocusSection(
      heading: "When it's worth looking further",
      group: 'understand',
      tiles: [
        TtcGuideTile(
          title: 'When investigation is worth asking for',
          blurb: 'After two losses, not three. ESHRE moved that threshold and '
              'many places have not caught up.',
          readId: _kTryingAgain,
          atHeading: 'When investigation is worth asking for',
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
      ],
    ),

    // =========================================================================
    //  3 — Trying again
    // =========================================================================
    TtcFocusSection(
      heading: 'When, and who decides',
      group: 'again',
      tiles: [
        TtcArticleTile(
          title: 'On trying again',
          blurb: 'When it is safe, what the evidence actually says about '
              'waiting, and who decides.',
          readId: _kTryingAgain,
        ),
        TtcMythTile(
          title: 'The six-month wait, and where it came from',
          blurb: 'One 2007 recommendation, one study, and what the evidence '
              'has done since.',
          myth: 'You have to wait three to six months before trying again.',
          fact: 'That advice traces back to a 2007 WHO recommendation resting '
              'largely on a single study. Larger work since — including a '
              'Norwegian cohort of nearly seventy-three thousand pregnancies — '
              'has not found the harm it assumed. For an early loss with no '
              'complications there is no medical reason to wait months. Many '
              'clinicians suggest one normal period, and the reason is '
              'practical: it makes dating a next pregnancy easier. If your own '
              'doctor has told you to wait, ask what their reason is rather '
              'than assuming it is the general advice.',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'If and when you do',
      group: 'again',
      tiles: [
        TtcGuideTile(
          title: 'What to do differently next time',
          blurb: 'A short list, and a shorter one than the internet suggests.',
          readId: _kTryingAgain,
          atHeading: 'If and when you do try again',
        ),
        // ⚠️ THE BRIEF'S OPTIONAL "On trying again" VIDEO IS NOT BUILT. There
        // is one loss video slot in the catalogue and it is already used above.
        // Inventing a second slot id would put a card on the page that no file
        // can ever be mapped to — a coming-soon that is coming from nowhere.
        // Recorded in §26; it is one entry in `ttc_videos_data.dart` away.
      ],
    ),

    // =========================================================================
    //  4 — Support
    // =========================================================================
    TtcFocusSection(
      heading: 'People who have been here',
      group: 'support',
      tiles: [
        TtcCommunityTile(
          title: 'Loss & Recovery room',
          blurb: 'Held gently. No timelines, no silver linings, and no advice '
              'unless it is asked for.',
          surfaceId: 'ttc_community',
        ),
        TtcCommunityTile(
          title: 'Your Care Circle',
          blurb: 'The people you chose. As much or as little as you want.',
          surfaceId: 'ttc_care_circle',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Talk to someone',
      group: 'support',
      tiles: [
        TtcTalkTile(
          title: 'Talking to someone who does this',
          blurb: 'A counsellor who works with pregnancy loss, or a doctor who '
              'can look at what happened. At your pace.',
          action: kTtcActConsult,
        ),
        // ⚠️ THE ONE PAID THING THIS AREA ALLOWS, AND IT IS LAST, AND IT IS
        // DESCRIBED AS PEOPLE. The bracket marks course `notCore` — "reached
        // through a person, not a product row" — so it appears here, at the
        // foot of the tab about support, rather than in the headline slot
        // every other door uses. Its blurb carries no price.
        TtcMasterclassTile(
          title: 'After a loss, four sessions',
          blurb: 'A small group, led by a counsellor, over four weeks. With '
              'people who are where you are.',
          offeringId: 'ttc_loss_support',
        ),
      ],
    ),
  ],
);
