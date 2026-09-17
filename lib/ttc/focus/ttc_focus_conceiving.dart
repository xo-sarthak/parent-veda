// =============================================================================
//  Conceiving and the fertile window — the focus page for this door
// -----------------------------------------------------------------------------
//  ⚠️ ONE FILE PER BRACKET, FOR THE SAME REASON THE READS WERE SPLIT. Every
//  door build adds a `TtcFocusPage` and every one of them was landing in the
//  same file, at the same closing bracket. With several doors being built at
//  once that is a conflict per pair, in a file where a bad resolution loses
//  whole sections rather than failing to compile.
//
//  The tile model, the format enum and the registry all stay in
//  `ttc_focus_data.dart`. Only the CONTENT moved, so nothing outside this
//  folder changed and no call site knows the difference.
//
//  ⚠️ ADDING A DOOR IS TWO LINES IN THE AGGREGATOR — one import, one entry in
//  `kTtcFocusPages`. That is the whole shared surface, and it is deliberately
//  small enough that two people editing it produces a conflict anyone can
//  resolve at a glance.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../../screens/ttc/ttc_illustrations.dart';
import '../ttc_focus_data.dart';

// =============================================================================
//  Conceiving and the fertile window
// =============================================================================

const TtcFocusPage kTtcConceivingFocus = TtcFocusPage(
  bracketId: 'ttc_conceiving',

  // ⚠️ THE MOST IMPORTANT THREE SENTENCES ON THE PAGE, and the third one is the
  // reason the other two are here. A page with twenty-five tiles reads as
  // twenty-five things she is failing to do unless something tells her, early
  // and plainly, that it is not a list to finish. This stage exists to take
  // pressure off; an unread instruction to relax at the bottom does not.
  intro: 'Some things really help. Some things do not. '
      'You do not need to do everything.',

  // ⚠️ THE FILM CAME OFF THE TOP — 2026-09-04, and for the same reason it came
  // off PCOS and IVF: `ttc_conceiving_intro` has no entry in
  // `ttc_videos_data.dart` at all. It is a bare slot id, so the hero opened on
  // a coming-soon box — the first thing on the first door of the stage.
  //
  // ⚠️ AND NOTHING IS ORPHANED BY REMOVING IT. This is the check that mattered:
  // the four TTC films that ARE written and chaptered (`ttc_vid_whose_side`
  // and the rest) each have a tile somewhere. This one never did. Commenting
  // out a hero whose slot names a real film would have hidden the film; this
  // one names nothing, so there is nothing to relocate. The declaration in
  // `ttc_hubs.dart:107` is untouched and still works if the page is ever
  // unregistered.
  //
  // heroVideoSlot: 'ttc_conceiving_intro',
  // heroVideoTitle: 'What actually helps, in two minutes',

  // ⚠️ SWAPPED 2026-09-06. The placeholder that shipped here turned out, when
  // actually looked at, to be a black-and-white portrait of a crying child —
  // which is what "a placeholder, to be swapped" costs when the swap waits.
  // This one is a cluster of pink buds about to open: a window of days that
  // is about to be, warm, and dark enough round the edges for the white type
  // to sit on it under the scrim. The V3 field still renders behind it, so a
  // dead connection gives the hero rather than a grey box.
  heroImageUrl:
      'https://images.unsplash.com/photo-1779635163668-61db66b24fc7?w=900&h=700&fit=crop',
  heroBlurb: 'About six days in each cycle are the ones that count. Everything '
      'on this page is either about finding them, or about the things people '
      'worry about that turn out not to matter.',

  // ---------------------------------------------------------------------------
  //  The selector rail — five cards under the hero, the window first
  // ---------------------------------------------------------------------------
  // ⚠️ THE RAIL NOW CARRIES THE ARGUMENT THE SCROLL USED TO CARRY. Two
  // orderings in this file were load-bearing and had to survive the change of
  // shape, because in a grouped page nothing is "further down" any more — a
  // tab is either on the rail or it is not.
  //
  //   · His before hers. A male factor is involved in about half of couples
  //     who take longer than expected, and in this market almost all of the
  //     advice, testing and blame lands on her. As sections, "What he should
  //     do" merely came first in a scroll most people never finished. As a
  //     TAB it sits on the rail, permanently, at the same size as hers —
  //     which states the point more plainly than the old order did.
  //
  //   · The doctor last. The page used to end on a consultation because
  //     CLAUDE.md says anything clinical routes calmly to a doctor. A tab
  //     cannot be "the end", so it is the last card on the rail and always one
  //     tap away instead of one long scroll away.
  //
  // ⚠️ HUES ARE THE APP'S OWN, as on PCOS: 344 `V2BlockHues.watch`, 42
  // `.read`, 104 `.practice`, 206 the clinical blue. 186 is the cyan His side
  // already uses for him, which is the one cross-door consistency worth having.
  groups: [
    TtcFocusGroup(
        id: 'window',
        label: 'Your window',
        icon: Icons.center_focus_weak_outlined,
        hue: 344),
    TtcFocusGroup(
        id: 'trying',
        label: 'How to try',
        icon: Icons.favorite_border_rounded,
        hue: 42),
    TtcFocusGroup(
        id: 'his',
        label: 'What he can do',
        icon: Icons.self_improvement_outlined,
        hue: 186),
    TtcFocusGroup(
        id: 'hers',
        label: 'What she can do',
        icon: Icons.eco_outlined,
        hue: 104),
    TtcFocusGroup(
        id: 'doctor',
        label: 'See a doctor',
        icon: Icons.medical_services_outlined,
        hue: 206),
  ],

  headline: TtcMasterclassTile(
    title: 'How to improve your chances of getting pregnant',
    blurb: 'A short course with a fertility doctor. Watch at your own time.',
    offeringId: 'ttc_course_basics',
  ),

  sections: [
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'When should we have sex?',
      group: 'window',
      tiles: [
        // ⚠️ THE TOOL IS SECTION ONE, WHICH IS THE WHOLE MERGE. It used to be
        // one of three cards on a menu in front of this page. It is the thing
        // she came for, so it is the first thing she sees.
        TtcToolTile(
          title: 'Your best days this month',
          blurb: 'Your own dates, from the period you logged.',
          surfaceId: 'ttc_window',
        ),
        // ⚠️ THE TRIAL FOR THE PICTURE-LED ARTICLE. One tile, one image,
        // used in two places: the thumbnail on the rail and the header of the
        // piece it opens.
        TtcArticleTile(
          title: 'Which days can she get pregnant?',
          blurb: 'About six days each cycle. Here is why.',
          art: TtcArt.fertileWindow,
          // The picture lives on the read now (`PvRead.imageUrl`, 2026-09-17)
          // and the rail reads it from there — see `photoForTile`. The URL
          // and its rationale moved with it.
          readId: 'ttc_read_how_conception_works',
        ),
        TtcCarouselTile(
          title: 'How the body shows the right days',
          blurb: 'Three signs you can check yourself, free.',
          cards: [
            TtcCarouselCard(
              title: 'Wetness changes',
              body: 'A few days before the egg is released, the fluid becomes '
                  'clear, wet and stretchy. It looks a little like raw egg '
                  'white. This is the clearest free sign, and it comes BEFORE '
                  'the best days — which is what makes it useful.',
            ),
            TtcCarouselCard(
              title: 'Body temperature',
              body: 'Your temperature rises slightly after the egg is '
                  'released. Useful for learning your own pattern over a few '
                  'months. Not useful for this month, because by the time it '
                  'rises, the best days have passed.',
            ),
            TtcCarouselCard(
              title: 'A kit, if you want one',
              body: 'An ovulation kit tests your urine for a hormone that '
                  'rises about a day before the egg is released. It tells you '
                  'the same thing your body is already telling you. Helpful if '
                  'your cycles are hard to predict.',
            ),
          ],
        ),
        TtcArticleTile(
          title: 'Ovulation kits: do they help?',
          blurb: 'Sometimes. Here is when they are worth the money.',
          art: TtcArt.fertileWindow,
          readId: 'ttc_read_ovulation_kits',
        ),
        TtcProductTile(
          title: 'Buy an ovulation kit',
          blurb: 'LH strips, and what to look for on the pack.',
          productId: 'lh_strips',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'How many times should we try?',
      group: 'trying',
      tiles: [
        // The timing read already answers this exactly — every one to two
        // days across the window, and why saving it up does not help.
        TtcArticleTile(
          title: 'How often is best',
          blurb: 'Every two days is enough. Really.',
          readId: 'ttc_read_timing_myths',
        ),
        TtcMythTile(
          title: 'Every day or not?',
          blurb: 'Does more times mean a better chance?',
          myth: 'The more you have sex, the better the chance.',
          fact: 'Only up to a point. Every two days in the fertile week gives '
              'you the same result as every day. Beyond that, more does not '
              'add anything — it only adds pressure.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  ⚠️ THREE MYTHS IN A ROW, DELIBERATELY. This is the section where the
    //  wrong answers are everywhere and the right answers are all short. An
    //  article here would bury three clean "no"s in six paragraphs.
    TtcFocusSection(
      heading: 'Which sex position is best?',
      group: 'trying',
      tiles: [
        TtcMythTile(
          title: 'Do positions matter?',
          blurb: 'The short answer is no.',
          myth: 'Some positions make a baby more likely.',
          fact: 'No position has been shown to work better than another. '
              'Sperm reach the cervix within minutes whatever position you '
              'used. Pick what is comfortable.',
        ),
        TtcMythTile(
          title: 'Should she lie down after?',
          blurb: 'You do not have to. Here is why.',
          myth: 'You must lie down with your legs up afterwards.',
          fact: 'Sperm are already past the cervix within minutes. Lying down '
              'does no harm if you like it, but getting up straight away does '
              'not wash anything away or undo anything.',
        ),
        TtcMythTile(
          title: 'Does the woman need to finish?',
          blurb: 'No. It is not needed to conceive.',
          myth: 'She has to orgasm for it to work.',
          fact: 'Conception does not need her orgasm. There is a theory that '
              'it may help sperm move, but it has never been shown to change '
              'whether someone conceives. Nothing has gone wrong if it does '
              'not happen.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  ⚠️ MOVED UP INTO "How to try" — 2026-09-04. It used to sit between
    //  hers and the doctor, which is where a scroll put it and not where it
    //  belongs: "does stress stop pregnancy?" is the third of three
    //  myth-corrections about the act of trying, beside "does more sex help?"
    //  and "does position matter?". Grouping made the mis-filing visible.
    //
    //  ⚠️ AND IT IS NOT UNDER "What she can do", WHICH WAS THE NEAR MISS.
    //  Filing stress under her is the same reflex this page exists to correct.
    TtcFocusSection(
      heading: 'Does stress stop pregnancy?',
      group: 'trying',
      tiles: [
        TtcArticleTile(
          title: 'Can stress stop it?',
          blurb: 'Not the way people tell you it does.',
          readId: 'ttc_read_stress_fertility',
        ),
        TtcVideoTile(
          title: 'If you feel too much pressure',
          blurb: 'For the months that feel heavy.',
          slotId: 'ttc_video_pressure',
          duration: '5 MIN',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  ⚠️ HIS IS ITS OWN TAB NOW, AND IT SITS BEFORE HERS ON THE RAIL. The
    //  argument is unchanged and is written out at the `groups` list above: a
    //  male factor is involved in about half of couples who take longer than
    //  expected, and in this market almost all of the advice, testing and blame
    //  lands on her. What changed is that it used to depend on somebody
    //  scrolling far enough to notice the order.
    TtcFocusSection(
      heading: 'What he should do',
      group: 'his',
      tiles: [
        // ⚠️ REWRITTEN FROM A TIP LIST INTO AN EXPLAINER, and that was the
        // note: "the slides should make sense, not look like generic 'smoking
        // and alcohol / keep it cool / give it three months'."
        //
        // The three things are unchanged — heat, smoking and drinking, and the
        // ninety-day lag. What changed is that each slide now says WHY, in a
        // full sentence, in the order the body actually works: sperm are made
        // continuously → that takes about two and a half months → so heat and
        // habits act on a queue that is already forming → so a change today is
        // visible in about three months. A list of three nouns teaches nothing;
        // this teaches the mechanism, and the three actions fall out of it.
        // ⚠️ NOT "3 THINGS FOR HIM" ANY MORE — it is six slides, and a title
        // that counts has to be able to count. The three ACTIONS are still
        // three; the explainer around them is not, and naming the piece after
        // the count made the heading wrong the moment the mechanism was added.
        TtcCarouselTile(
          title: 'How sperm are made',
          blurb: 'The mechanism, and the three things that change it.',
          art: TtcArt.hisSideCover,
          reviewedBy: 'ParentVeda medical review',
          coverHue: 268,
          coverTitle: 'His body, from the inside',
          coverBlurb: 'Six short slides on how sperm are actually made — and '
              'the three things that genuinely change it.',
          cards: [
            TtcCarouselCard(
              title: 'His half is *half of it*',
              hue: 268,
              body: 'In about half of couples who take longer than expected, '
                  'something on his side is part of the reason. It is also the '
                  'faster half to check — *one test, no procedure*.',
              art: TtcArt.hisSideCover,
            ),
            TtcCarouselCard(
              title: 'Sperm are not stored. They are made, *continuously*.',
              hue: 206,
              body: 'His body is producing them right now, and will keep going '
                  'all week. What you are looking after is *a production line, not '
                  'a reserve*.',
              art: TtcArt.spermProduction,
            ),
            TtcCarouselCard(
              title: 'Each one takes about *two and a half months* to finish',
              hue: 160,
              body: 'Roughly *74 days* from start to ready. So the sperm that matter '
                  'next month were begun before you read this.',
              art: TtcArt.threeMonths,
            ),
            TtcCarouselCard(
              title: 'Heat *slows that line down*',
              hue: 42,
              body: 'Sperm are made a little below body temperature, which is '
                  'why the testes sit outside. Long hot baths, saunas, and a '
                  'laptop on the lap for hours all add heat. None of it is a '
                  'disaster. All of it is easy to change.',
              art: TtcArt.heat,
            ),
            TtcCarouselCard(
              title: 'Smoking and heavy drinking *lower the count*',
              hue: 344,
              body: 'Both reduce how many are made and how well they move. '
                  'Stopping smoking is the single biggest thing most men can '
                  'do. An occasional drink is not the problem.',
              art: TtcArt.smokeAndDrink,
            ),
            TtcCarouselCard(
              title: 'So a change today shows up in *about three months*',
              hue: 104,
              body: 'That is slow, and it is also the reason to start now '
                  'rather than wait for a result. If he is having a test, it is '
                  'worth making the changes first.',
              art: TtcArt.threeMonths,
            ),
          ],
        ),
        TtcVideoTile(
          title: 'Keep his sperm healthy',
          blurb: 'What helps, what does not, and how long it takes.',
          slotId: 'ttc_video_sperm_health',
          duration: '4 MIN',
        ),
        // ⚠️ REFERENCED FROM HIS SIDE, NOT COPIED HERE — the his-side rebuild's
        // Step 5a, and the third of the three pointers it names. His side is
        // the OWNER of male-factor content; Getting ready and IVF already name
        // its reads by id and this door did not, which left the one section
        // about him with no way through to the area written about him.
        //
        // Nothing below is a second copy of any prose. Editing the article in
        // His side updates it here, because there is only ever one of it.
        TtcArticleTile(
          title: 'Whose "side" is it, really',
          blurb: 'About half of couples having difficulty have a male factor '
              'somewhere in it — very often alongside a female one.',
          readId: 'ttc_read_whose_side',
        ),
        TtcArticleTile(
          title: 'Heat, habits and time',
          blurb: 'The three levers that genuinely move sperm health, including '
              'the smokeless tobacco nobody counts.',
          readId: 'ttc_read_heat_habits',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'What she should do',
      group: 'hers',
      tiles: [
        TtcCarouselTile(
          title: '3 things for her',
          blurb: 'Start here. The rest can wait.',
          cards: [
            TtcCarouselCard(
              title: 'Folic acid, today',
              body: 'Start it now, not when you get a positive test. It '
                  'protects the baby\'s spine and brain in the first few weeks '
                  '— often before anyone knows they are pregnant. This is the '
                  'one item on the whole page with the strongest evidence.',
            ),
            TtcCarouselCard(
              title: 'Smoking and alcohol',
              body: 'Both make conception take longer, and both matter more '
                  'once you are pregnant. If you are trying, it is worth '
                  'stopping now rather than later.',
            ),
            TtcCarouselCard(
              title: 'Weight, gently',
              body: 'Being well under or well over a healthy weight can make '
                  'cycles irregular, which makes timing harder. Small, steady '
                  'change helps. Crash dieting does not — it can stop ovulation '
                  'altogether.',
            ),
          ],
        ),
        TtcArticleTile(
          title: 'What to eat and avoid',
          blurb: 'Ordinary food. No special fertility diet.',
          readId: 'ttc_read_three_months_before',
        ),
        TtcArticleTile(
          title: 'Folic acid: why she needs it',
          blurb: '400 mcg a day, starting before you conceive.',
          readId: 'ttc_read_folic_acid',
        ),
        // ⚠️ REFERENCED FROM GETTING READY, NOT COPIED HERE — the rebuild
        // brief's Step 5b, and the rule that keeps this section from drifting.
        //
        // Getting ready is the single source for before-you-start body prep:
        // diet, folic acid, weight and habits are DEFINED there. These tiles
        // name the same read ids, so editing an article in that door updates it
        // in this one because there is only ever one of it. Nothing below is a
        // second copy of any prose.
        //
        // Why show them here at all: somebody in the fertile-window door is
        // asking "what should I be doing", and answering "go to another door"
        // is a worse answer than answering the question. Each area is allowed
        // to feel complete; what is not allowed is two versions of the same
        // paragraph.
        TtcArticleTile(
          title: 'What to cut before trying',
          blurb: 'Three things worth changing, and a longer list you can stop '
              'feeling guilty about.',
          readId: 'ttc_read_what_to_cut',
        ),
        TtcArticleTile(
          title: 'Weight, said kindly',
          blurb: 'What it actually does, why direction beats any destination, '
              'and no numbers at all.',
          readId: 'ttc_read_weight_kindly',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  ⚠️ THE LAST CARD ON THE RAIL ROUTES TO A PERSON. CLAUDE.md: anything
    //  clinical ends with a disclaimer and routes calmly to a doctor. A grouped
    //  page has no "end" to close on, so the rule is carried by rail position
    //  instead — last card, always one tap away rather than one scroll away.
    TtcFocusSection(
      heading: 'When should we see a doctor?',
      group: 'doctor',
      tiles: [
        TtcArticleTile(
          title: 'Trying for many months?',
          blurb: 'How long is normal before asking for help.',
          readId: 'ttc_read_when_to_seek_help',
        ),
        TtcCarouselTile(
          title: 'Signs to not wait',
          blurb: 'Reasons to see someone sooner, whatever the calendar says.',
          cards: [
            TtcCarouselCard(
              title: 'Periods that are irregular or missing',
              body: 'If your cycles vary a lot, or stop for months, it is hard '
                  'to time anything — and it usually has a treatable cause. '
                  'Worth checking rather than waiting a year.',
            ),
            TtcCarouselCard(
              title: 'Periods that are very painful',
              body: 'Pain that stops you working or needs strong medicine every '
                  'month is not something to put up with. It can point to '
                  'endometriosis, which is worth finding early.',
            ),
            TtcCarouselCard(
              title: 'Something already known',
              body: 'PCOS, a thyroid problem, a previous ectopic pregnancy, '
                  'pelvic surgery or infection, or two or more miscarriages. '
                  'Any of these is a reason to start the conversation now.',
            ),
            TtcCarouselCard(
              title: 'Age, honestly',
              body: 'Over 35, the usual advice is to ask after six months '
                  'rather than twelve. This is not a warning and it is not a '
                  'deadline. It only means an earlier look is worth having.',
            ),
          ],
        ),
        TtcBookingTile(
          title: 'Talk to a doctor',
          blurb: 'A private video consultation about your own cycle.',
          // ⚠️ THE BOOKING ENGINE, CONFIGURED — never a new appointment
          // feature. Resolved by the caller's hub-action switch, which scopes
          // it to consults; unscoped it opened nine categories and asked her to
          // scroll past yoga to find the thing she tapped.
          action: 'ttc_consult',
        ),
      ],
    ),
  ],
);

/// Every focus page in the stage. One today.
