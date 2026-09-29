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
// -----------------------------------------------------------------------------
//  ⚠️ `id:` ON A TILE IS ITS PHOTO KEY (2026-09-28, `TtcTile.id`). The value
//  is frozen at the title the tile had when its photo was filed, and it is
//  the photo's file name on R2, so retitle freely and never touch the id.
//  Tiles with no `id` either take their read's photo or key on the title.
// =============================================================================

const TtcFocusPage kTtcConceivingFocus = TtcFocusPage(
  bracketId: 'ttc_conceiving',

  // ⚠️ THE MOST IMPORTANT THREE SENTENCES ON THE PAGE, and the third one is the
  // reason the other two are here. A page with twenty-five tiles reads as
  // twenty-five things she is failing to do unless something tells her, early
  // and plainly, that it is not a list to finish. This stage exists to take
  // pressure off; an unread instruction to relax at the bottom does not.
  intro: "Some things really help. Some things don't. "
      "You don't need to do everything.",

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
  // Our own photograph (2026-09-27): generated to the door's brief, checked by
  // eye, mirrored to the R2 bucket. Kept for revert: the previous value.
  // heroImageUrl: 'https://images.unsplash.com/photo-1779635163668-61db66b24fc7?w=900&h=700&fit=crop',
  heroImageUrl: 'https://pub-bfbc0773e60e4c5c851b535f08b384bc.r2.dev/ttc_door_fertile_window.jpg',
  // The new door's headline, a sentence (TtcDoorScreen, 2026-09-26).
  heroTitle: 'The days that count, and how to use them.',
  heroBlurb: 'About six days in each cycle are the ones that count. Everything '
      'on this page helps you find them, or covers the worries that turn out '
      'not to matter.',

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
  //
  // ⚠️ SIX TABS, NOT SEVEN, SINCE THE GAP PLAN (2026-09-26). "Waiting and
  // testing" and "Sex and closeness" arrived as two new tabs, and seven cards
  // is a rail she scrolls instead of reads. So "Your window" and "How to try"
  // became ONE tab, "When and how": when in the cycle, how often, which
  // position, and whether stress stops it. That was the order of the page
  // before it had a rail, and it is one question asked four ways. Nothing
  // came off; the two old cards are kept below for revert. His stays before
  // hers and the doctor stays last, which is what the tests hold.
  //
  // ⚠️ THE MERGED TAB KEEPS THE ID 'trying', NOT 'window'. The stress section
  // is pinned to 'trying' by `ttc_focus_groups_test`, and nothing outside this
  // file opens the door on 'window'.
  //
  // ⚠️ 'sex' IS NOT A FREE CHOICE OF ID. It is `kTtcIntimateGroupId`
  // (ttc_content_prefs.dart), the one the "Hide sex and intimacy content"
  // switch removes. Rename it and the switch silently stops working.
  groups: [
    // Kept for revert (the two tabs before the merge):
    // TtcFocusGroup(
    //     id: 'window', mark: IntentMark.cycleRing,
    //     label: 'Your window',
    //     icon: Icons.center_focus_weak_outlined,
    //     hue: 344),
    // TtcFocusGroup(
    //     id: 'trying', mark: IntentMark.questionMark,
    //     label: 'How to try',
    //     icon: Icons.favorite_border_rounded,
    //     hue: 42),
    TtcFocusGroup(
        id: 'trying', mark: IntentMark.cycleRing, tabMark: TtcTabMark.windowRing,
        // Kept for revert (2026-09-28, explicit names): label: 'When and how',
        label: 'When and how to try',
        icon: Icons.center_focus_weak_outlined,
        hue: 344),
    TtcFocusGroup(
        id: 'waiting', mark: IntentMark.calendarDay, tabMark: TtcTabMark.testStrip,
        label: 'Waiting and testing',
        icon: Icons.hourglass_empty_rounded,
        hue: 268),
    TtcFocusGroup(
        id: 'sex', mark: IntentMark.cuppedHands, tabMark: TtcTabMark.twoCircles,
        label: 'Sex and closeness',
        icon: Icons.favorite_border_rounded,
        hue: 42),
    TtcFocusGroup(
        id: 'his', mark: IntentMark.spermMark, tabMark: TtcTabMark.sprout,
        label: 'What he can do',
        icon: Icons.self_improvement_outlined,
        hue: 186),
    TtcFocusGroup(
        id: 'hers', mark: IntentMark.improveMark, tabMark: TtcTabMark.jarLeaf,
        label: 'What you can do',
        icon: Icons.eco_outlined,
        hue: 104),
    TtcFocusGroup(
        id: 'doctor', mark: IntentMark.askDoctor, tabMark: TtcTabMark.doctorChat,
        label: 'See a doctor',
        icon: Icons.medical_services_outlined,
        hue: 206),
  ],

  headline: TtcMasterclassTile(
    title: 'What helps you get pregnant',
    id: 'ttc_tile_what_helps_you_get_pregnant',
    blurb: 'A short course with a fertility doctor. Watch in your own time.',
    offeringId: 'ttc_course_basics',
  ),

  sections: [
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'When should we have sex?',
      group: 'trying', // was 'window', before the merge
      tiles: [
        // ⚠️ THE TOOL IS SECTION ONE, WHICH IS THE WHOLE MERGE. It used to be
        // one of three cards on a menu in front of this page. It is the thing
        // she came for, so it is the first thing she sees.
        TtcToolTile(
          title: 'Your best days this month',
          id: 'ttc_tile_your_best_days_this_month',
          blurb: 'Your own dates, from the period you logged.',
          surfaceId: 'ttc_window',
        ),
        // ⚠️ THE TRIAL FOR THE PICTURE-LED ARTICLE. One tile, one image,
        // used in two places: the thumbnail on the rail and the header of the
        // piece it opens.
        TtcArticleTile(
          title: 'Which days can you get pregnant?',
          id: 'ttc_tile_which_days_can_you_get_pregnant',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: "About six days each cycle. Here's why.",
          blurb: 'About six days each cycle, and the reason the fertile window is six days long.',
          art: TtcArt.fertileWindow,
          // The picture lives on the read now (`PvRead.imageUrl`, 2026-09-17)
          // and the rail reads it from there — see `photoForTile`. The URL
          // and its rationale moved with it.
          // ⚠️ THE READ THAT ANSWERS IT (launch walk, 2026-09-27): "How
          // conception works" has no section on which days, so the tile
          // promised one thing and opened another. The timing read's short
          // answer is exactly this question. Kept for revert:
          //   readId: 'ttc_read_how_conception_works',
          readId: 'ttc_read_timing_myths',
          atHeading: 'Why is the window six days long?',
        ),
        TtcCarouselTile(
          title: 'How the body shows the right days',
          id: 'ttc_tile_how_the_body_shows_the_right_days',
          blurb: 'Three signs you can check yourself, free.',
          cards: [
            TtcCarouselCard(
              title: 'Wetness changes',
              body: 'A few days before the egg is released, the fluid becomes '
                  'clear, wet and stretchy. It looks a little like raw egg '
                  'white. This is the clearest free sign, and it comes before '
                  "the best days. That's what makes it useful.",
            ),
            TtcCarouselCard(
              title: 'Body temperature',
              body: 'Your temperature rises slightly after the egg is '
                  "released. It's useful for learning your own pattern over a "
                  "few months. It won't help this month, because by the time it "
                  'rises, the best days have passed.',
            ),
            TtcCarouselCard(
              title: 'A kit, if you want one',
              body: 'An ovulation kit tests your urine for a hormone that '
                  'rises about a day before the egg is released. It tells you '
                  'the same thing your body is already telling you. It helps '
                  'if your cycles are hard to predict.',
            ),
          ],
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Ovulation kits: do they help?',
          title: 'Do ovulation kits help?',
          id: 'ttc_tile_do_ovulation_kits_help',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: "Sometimes. Here's when they're worth the money.",
          blurb: "Sometimes. When ovulation kits are worth the money, and when they aren't.",
          art: TtcArt.fertileWindow,
          readId: 'ttc_read_ovulation_kits',
        ),
        // Beside the kits piece, because it is the question the kits piece
        // leaves open: what to do when your cycle won't tell you when to start.
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Kits when your cycles are irregular',
          title: 'Ovulation kits when your cycles are irregular',
          id: 'ttc_tile_ovulation_kits_when_your_cycles_are_irregular',
          blurb: 'When to start, how often to test, and what the strips mean.',
          readId: 'ttc_read_ovulation_tests_irregular',
        ),
        // Added 2026-09-28 (launch sanity, from the tools helper): the other
        // body sign people track, beside the kits, so the temperature chart's
        // own read has a door to live in and is not only reachable from the
        // tool.
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Morning temperature: how it works',
          title: 'How morning temperature tracking works',
          id: 'ttc_tile_how_morning_temperature_tracking_works',
          blurb: 'What the small rise after ovulation shows, and why you '
              "don't need it.",
          readId: 'ttc_read_morning_temperature',
        ),
        TtcProductTile(
          title: 'Buy an ovulation kit',
          id: 'ttc_tile_buy_an_ovulation_kit',
          blurb: 'LH strips, and what to look for on the pack.',
          productId: 'lh_strips',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'How many times should we try?',
      heading: 'How often should we have sex?',
      group: 'trying',
      tiles: [
        // The timing read already answers this exactly — every one to two
        // days across the window, and why saving it up does not help.
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'How often is best',
          title: 'How often to have sex',
          id: 'ttc_tile_how_often_to_have_sex',
          blurb: 'Every two days is enough. Really.',
          readId: 'ttc_read_timing_myths',
        ),
        // ⚠️ MOVED TO "When should we see a doctor?" (2026-09-27, relevance
        // audit). This section asks how OFTEN, and the tile answers how LONG.
        // Kept for revert (2026-09-27, relevance audit):
        // // "How many times" is also asked in months, not only in nights. The
        // // IVF door owns this read (Age and second baby); it is named here too
        // // because this is where the question first comes up.
        // TtcArticleTile(
        //   title: 'How many months it usually takes',
        //   blurb: "Most couples need several cycles. Here's what's normal.",
        //   readId: 'ttc_read_how_long_it_takes',
        // ),
        TtcMythTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Every day or not?',
          title: 'Sex every day, or every other day?',
          id: 'ttc_tile_every_day_or_not',
          blurb: 'Does more often mean more likely?',
          myth: 'The more you have sex, the better the chance.',
          fact: 'Only up to a point. Every two days in the fertile week gives '
              "you the same result as every day. Beyond that, more doesn't "
              'add anything except pressure.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  ⚠️ THREE MYTHS IN A ROW, DELIBERATELY. This is the section where the
    //  wrong answers are everywhere and the right answers are all short. An
    //  article here would bury three clean "no"s in six paragraphs.
    TtcFocusSection(
      // Retitled (2026-09-27, relevance audit): two of the three myths are
      // about lying down and orgasm, not position. Kept for revert:
      // heading: 'Which sex position is best?',
      heading: 'Positions, lying down and other myths',
      group: 'trying',
      tiles: [
        TtcMythTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Do positions matter?',
          title: 'Do sex positions matter?',
          id: 'ttc_tile_do_positions_matter',
          blurb: 'The short answer is no.',
          myth: 'Some positions make a baby more likely.',
          fact: 'No position has been shown to work better than another. '
              'Sperm reach the cervix within minutes, whatever position you '
              "used. Pick what's comfortable.",
        ),
        TtcMythTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Should you lie down after?',
          title: 'Should you lie down after sex?',
          id: 'ttc_tile_should_you_lie_down_after',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: "You don't have to. Here's why.",
          blurb: "You don't have to. Getting up washes nothing away.",
          myth: 'You must lie down with your legs up afterwards.',
          fact: 'Sperm are already past the cervix within minutes. Lying down '
              'does no harm if you like it. But getting up straight away '
              "doesn't wash anything away or undo anything.",
        ),
        TtcMythTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Do you need to orgasm?',
          title: 'Do you need an orgasm to conceive?',
          id: 'ttc_tile_do_you_need_to_orgasm',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: "No. It isn't needed to get pregnant.",
          blurb: "No. Nothing has gone wrong if you don't have one.",
          myth: 'You have to orgasm for it to work.',
          fact: "Getting pregnant doesn't depend on your orgasm. There's a "
              'theory that it may help sperm move, but it has never been shown '
              'to change whether someone gets pregnant. Nothing has gone wrong '
              "if it doesn't happen.",
        ),
        // The written film on exactly these myths (2026-09-27, relevance
        // audit). It was on no door, only at the head of the timing read.
        TtcVideoTile(
          title: 'Six myths about timing, one by one',
          id: 'ttc_tile_six_myths_about_timing_one_by_one',
          blurb: 'Positions, saving it up, lying still afterwards. What the '
              'evidence says about each.',
          slotId: 'ttc_vid_timing_myths',
          duration: '6 MIN',
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
          // Kept for revert (2026-09-28, explicit names): title: 'Can stress stop it?',
          title: 'Can stress stop you getting pregnant?',
          id: 'ttc_tile_can_stress_stop_you_getting_pregnant',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'Not the way people tell you it does.',
          blurb: 'Not the way people tell you stress does.',
          readId: 'ttc_read_stress_fertility',
        ),
        // ⚠️ THE FILM THAT ANSWERS THIS SECTION (2026-09-27, relevance
        // audit). The pressure film was a coping film under a factual
        // question, and a bare slot with no entry in `ttc_videos_data.dart`.
        // This one is written and chaptered, and is the same film Mind & body
        // shows. Kept for revert (2026-09-27, relevance audit):
        // TtcVideoTile(
        //   title: 'If you feel too much pressure',
        //   blurb: 'For the months that feel heavy.',
        //   slotId: 'ttc_video_pressure',
        //   duration: '5 MIN',
        // ),
        TtcVideoTile(
          title: 'Why "just relax" is the wrong advice',
          id: 'ttc_tile_why_just_relax_is_the_wrong_advice',
          blurb: 'What the evidence shows about stress and getting pregnant.',
          slotId: 'ttc_vid_stress_fertility',
          duration: '5 MIN',
        ),
      ],
    ),

    // ⚠️ ADDED 2026-09-27 (relevance audit). "How conception works" was the
    // one read with no tile on any door, and the checklist puts it here. The
    // film beside it is written and chaptered and was on no door either.
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'How does it happen?',
      heading: 'How does conception happen?',
      group: 'trying',
      tiles: [
        TtcArticleTile(
          title: 'How conception works',
          id: 'ttc_tile_how_conception_works',
          blurb: "What your cycle is doing, and why it doesn't happen every "
              'month.',
          readId: 'ttc_read_how_conception_works',
        ),
        TtcVideoTile(
          title: 'Your cycle, drawn out step by step',
          id: 'ttc_tile_your_cycle_drawn_out_step_by_step',
          blurb: 'The two halves of a cycle, and when you ovulate in yours.',
          slotId: 'ttc_vid_cycle_basics',
          duration: '6 MIN',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Waiting and testing — the gap plan's P1 tab (2026-09-26)
    // -------------------------------------------------------------------------
    //  ⚠️ THE CHAT SITS WITH THE TEST READS, NOT ON ITS OWN. "Should I test?"
    //  is a scripted chat of rules, no AI, and it answers the same question
    //  the reads beside it do, in a few taps instead of a page. Both routes
    //  to one answer, side by side, so she picks the one that suits the night.
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'What happens in the two weeks after?',
      heading: 'What happens in the two weeks after ovulation?',
      group: 'waiting',
      tiles: [
        TtcArticleTile(
          title: 'The two-week wait, day by day',
          id: 'ttc_tile_the_two_week_wait_day_by_day',
          blurb: "What's going on inside, and why you can't feel it yet.",
          readId: 'ttc_read_two_week_wait',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Early signs, and why most are also PMS',
          title: 'Early pregnancy signs, and why most are also PMS',
          id: 'ttc_tile_early_pregnancy_signs_and_why_most_are_also_pms',
          blurb: "Why your body can't answer before a test can.",
          readId: 'ttc_read_early_signs',
        ),
        TtcArticleTile(
          title: 'Implantation bleeding or your period?',
          id: 'ttc_tile_implantation_bleeding_or_your_period',
          blurb: 'How to tell them apart, and when bleeding needs a doctor.',
          readId: 'ttc_read_implantation_bleeding',
        ),
      ],
    ),

    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'When should you test, and how?',
      heading: 'When and how should you take a pregnancy test?',
      group: 'waiting',
      tiles: [
        TtcToolTile(
          title: 'Should I test?',
          id: 'ttc_tile_should_i_test',
          blurb: 'A few taps to work out if a test can tell you anything yet.',
          surfaceId: 'ttc_chat/should_test',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'When to take a test, and which one',
          title: 'When to take a pregnancy test, and which one',
          id: 'ttc_tile_when_to_take_a_pregnancy_test_and_which_one',
          blurb: 'The first day a test can give you a real answer.',
          readId: 'ttc_read_when_to_test',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'How to take a test, step by step',
          title: 'How to take a pregnancy test, step by step',
          id: 'ttc_tile_how_to_take_a_pregnancy_test_step_by_step',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'So you can trust what it says.',
          blurb: 'So you can trust the result.',
          readId: 'ttc_read_how_to_test',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'A faint line, explained',
          title: 'A faint line on a pregnancy test, explained',
          id: 'ttc_tile_a_faint_line_on_a_pregnancy_test_explained',
          blurb: 'What a pale line usually means, and when to test again.',
          readId: 'ttc_read_faint_line',
        ),
      ],
    ),

    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'What if the test says no?',
      heading: 'What if the pregnancy test says no?',
      group: 'waiting',
      tiles: [
        TtcArticleTile(
          title: 'Late period, negative test',
          id: 'ttc_tile_late_period_negative_test',
          blurb: 'The usual reasons, and when to see a doctor.',
          readId: 'ttc_read_late_negative',
        ),
        TtcArticleTile(
          title: 'Feeling pregnant, but the test says no',
          id: 'ttc_tile_feeling_pregnant_but_the_test_says_no',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'Why it can feel so real, and what helps.',
          blurb: 'Why the signs can feel so real, and what helps.',
          readId: 'ttc_read_feeling_pregnant',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Sex and closeness — the gap plan's tab, behind the shared-phone switch
    // -------------------------------------------------------------------------
    //  ⚠️ THIS WHOLE TAB DISAPPEARS WHEN SHE TURNS ON "Hide sex and intimacy
    //  content". The door screen removes group `kTtcIntimateGroupId` and any
    //  tile whose read is in `kTtcIntimateReadIds`, in one place
    //  (`ttcDoorVisiblePage`). Timing stays in "When and how", because timing
    //  is not the private part and hiding it would take away the tool.
    TtcFocusSection(
      heading: 'When trying changes your sex life',
      group: 'sex',
      tiles: [
        TtcArticleTile(
          title: 'When sex starts to feel like homework',
          id: 'ttc_tile_when_sex_starts_to_feel_like_homework',
          blurb: 'Small changes that take the pressure off.',
          readId: 'ttc_read_sex_homework',
        ),
        TtcArticleTile(
          title: 'Low desire, yours and his',
          id: 'ttc_tile_low_desire_yours_and_his',
          blurb: "What's normal, and when it's worth a word with a doctor.",
          readId: 'ttc_read_low_desire',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Staying close through the months',
          title: 'Staying close through months of trying',
          id: 'ttc_tile_staying_close_through_months_of_trying',
          blurb: 'Everyday ways to stay a couple, not just a plan.',
          readId: 'ttc_read_keeping_close',
        ),
      ],
    ),

    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'The questions that are hard to ask',
      heading: 'The sex questions that are hard to ask',
      group: 'sex',
      tiles: [
        TtcArticleTile(
          title: 'Pain during sex',
          id: 'ttc_tile_pain_during_sex',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'Including vaginismus, and how treatable it is.',
          blurb: 'Including vaginismus, which is very treatable.',
          readId: 'ttc_read_pain_vaginismus',
        ),
        TtcArticleTile(
          title: 'Which lubricants are sperm-friendly?',
          id: 'ttc_tile_which_lubricants_are_sperm_friendly',
          blurb: 'Why dryness happens, and what to use instead.',
          readId: 'ttc_read_lubricants',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Sex after the window',
          title: 'Sex after the fertile window',
          id: 'ttc_tile_sex_after_the_fertile_window',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'Can it affect an early pregnancy? For most couples, no.',
          blurb: 'Can sex affect an early pregnancy? For most couples, no.',
          readId: 'ttc_read_sex_after_window',
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
      // Kept for revert (2026-09-28, explicit names): heading: 'What he should do',
      heading: 'What can he do for his fertility?',
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
          id: 'ttc_tile_how_sperm_are_made',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'How it works, and the three things that change it.',
          blurb: 'Six slides, from how sperm are made to why a change takes three months.',
          art: TtcArt.hisSideCover,
          reviewedBy: 'ParentVeda team',
          coverHue: 268,
          coverTitle: 'His body, from the inside',
          coverBlurb: 'Six short slides on how sperm are made, and the three '
              'things that really change it.',
          cards: [
            TtcCarouselCard(
              title: 'His half is *half of it*',
              hue: 268,
              body: 'In about half of couples who take longer than expected, '
                  "something on his side is part of the reason. It's also the "
                  'quicker half to check: *one test, no procedure*.',
              art: TtcArt.hisSideCover,
            ),
            TtcCarouselCard(
              title: "Sperm aren't stored. They're made *all the time*.",
              hue: 206,
              body: 'His body is making them right now, and will keep going '
                  "all week. What you're looking after is *a production line, "
                  'not a store*.',
              art: TtcArt.spermProduction,
            ),
            TtcCarouselCard(
              title: 'Each one takes about *two and a half months* to finish',
              hue: 160,
              body: 'Roughly *74 days* from start to ready. So the sperm that '
                  'matter next month started growing before you read this.',
              art: TtcArt.threeMonths,
            ),
            TtcCarouselCard(
              title: 'Heat *slows that line down*',
              hue: 42,
              body: 'Sperm are made a little below body temperature, which is '
                  'why the testes sit outside the body. Long hot baths, saunas '
                  'and a laptop on the lap for hours all add heat. None of it is '
                  'a disaster, and all of it is easy to change.',
              art: TtcArt.heat,
            ),
            TtcCarouselCard(
              title: 'Smoking and heavy drinking *lower the count*',
              hue: 344,
              body: 'Both reduce how many are made and how well they move. '
                  'Stopping smoking is the biggest single thing most men can '
                  "do. An occasional drink isn't the problem.",
              art: TtcArt.smokeAndDrink,
            ),
            TtcCarouselCard(
              title: 'So a change today shows up in *about three months*',
              hue: 104,
              body: "That's slow, and it's also the reason to start now "
                  "instead of waiting for a result. If he's having a test, it's "
                  'worth making the changes first.',
              art: TtcArt.threeMonths,
            ),
          ],
        ),
        // ⚠️ THE WRITTEN FILM WITH THIS PROMISE (2026-09-27, relevance
        // audit). The old slot had no entry in `ttc_videos_data.dart`.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcVideoTile(
        //   title: 'Keep his sperm healthy',
        //   blurb: "What helps, what doesn't, and how long it takes.",
        //   slotId: 'ttc_video_sperm_health',
        //   duration: '4 MIN',
        // ),
        TtcVideoTile(
          title: 'Three things that really change his numbers',
          id: 'ttc_tile_three_things_that_really_change_his_numbers',
          blurb: 'Tobacco, heat and time, and how long before any change '
              'shows.',
          slotId: 'ttc_vid_heat_habits',
          duration: '5 MIN',
        ),
        // ⚠️ REFERENCED FROM HIS SIDE, NOT COPIED HERE — the his-side rebuild's
        // Step 5a, and the third of the three pointers it names. His side is
        // the OWNER of male-factor content; Getting ready and IVF already name
        // its reads by id and this door did not, which left the one section
        // about him with no way through to the area written about him.
        //
        // Nothing below is a second copy of any prose. Editing the article in
        // His side updates it here, because there is only ever one of it.
        // ⚠️ SWAPPED FOR AN ACTION (2026-09-27, relevance audit). The section
        // asks what he should do; "whose side" explains whose problem it is.
        // Testing early is the one action His side leads with.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcArticleTile(
        //   title: 'Whose "side" is it, really',
        //   blurb: 'About half of couples having difficulty have a male factor '
        //       'somewhere in it, very often alongside a female one.',
        //   readId: 'ttc_read_whose_side',
        // ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'The case for testing early',
          title: 'The case for an early sperm test',
          id: 'ttc_tile_the_case_for_an_early_sperm_test',
          blurb: 'One simple, cheap test that answers what months of waiting '
              "can't.",
          readId: 'ttc_read_case_for_testing',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Heat, habits and time',
          title: 'Heat, habits and time: what changes sperm',
          id: 'ttc_tile_heat_habits_and_time_what_changes_sperm',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'The three things that really change sperm health, '
          // 'including the smokeless tobacco nobody counts.',
          blurb: 'Including the smokeless tobacco nobody counts, and how much each change helps.',
          readId: 'ttc_read_heat_habits',
        ),
        // A labelled way through to the door written about him
        // (2026-09-27, relevance audit).
        TtcDoorTile(
          title: 'More in His side',
          id: 'ttc_tile_more_in_his_side',
          blurb: 'The test, his report, and what helps, in his own door.',
          bracketId: 'ttc_male_fertility',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'What you should do',
      heading: 'What can you do before you conceive?',
      group: 'hers',
      tiles: [
        TtcCarouselTile(
          // Kept for revert (2026-09-28, explicit names): title: '3 things for you',
          title: '3 things to start before you conceive',
          id: 'ttc_tile_3_things_for_you',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'Start here. The rest can wait.',
          blurb: 'Folic acid, smoking and weight. The rest can wait.',
          cards: [
            TtcCarouselCard(
              title: 'Folic acid, today',
              body: 'Start it now, not when you get a positive test. It '
                  "protects the baby's spine and brain in the first few weeks, "
                  "often before anyone knows they're pregnant. Of everything on "
                  'this page, this has the strongest evidence.',
            ),
            TtcCarouselCard(
              title: 'Smoking and alcohol',
              body: 'Both make it take longer to get pregnant, and both matter '
                  "more once you're pregnant. If you're trying, it's worth "
                  'stopping now rather than later.',
            ),
            TtcCarouselCard(
              title: 'Weight, gently',
              body: 'Being well under or well over a healthy weight can make '
                  'cycles irregular, which makes timing harder. Small, steady '
                  "changes help. Crash dieting doesn't, and it can stop "
                  'ovulation altogether.',
            ),
          ],
        ),
        TtcArticleTile(
          title: 'What to eat and avoid',
          id: 'ttc_tile_what_to_eat_and_avoid',
          blurb: 'Ordinary food. No special fertility diet.',
          readId: 'ttc_read_three_months_before',
          // Lands on the section that answers the tile (launch walk, 2026-09-27).
          atHeading: 'What should I eat?',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Folic acid: why you need it',
          title: 'Why you need folic acid before you conceive',
          id: 'ttc_tile_why_you_need_folic_acid_before_you_conceive',
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
          id: 'ttc_tile_what_to_cut_before_trying',
          blurb: 'Three things worth changing, and a longer list you can stop '
              'feeling guilty about.',
          readId: 'ttc_read_what_to_cut',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Weight, said kindly',
          title: 'Weight before pregnancy, said kindly',
          id: 'ttc_tile_weight_before_pregnancy_said_kindly',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'What it really does, why the direction matters more than '
          // 'any goal, and no numbers at all.',
          blurb: 'What weight really does, why the direction matters more than any goal, and no numbers at all.',
          readId: 'ttc_read_weight_kindly',
        ),
        // Three of the reads above belong to Getting ready, so the tab says
        // where the rest of them live (2026-09-27, relevance audit).
        TtcDoorTile(
          title: 'More in Getting ready',
          id: 'ttc_tile_more_in_getting_ready',
          blurb: 'Food, tests, vaccines and habits for the months before, in '
              'their own door.',
          bracketId: 'ttc_preconception_health',
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
          // Kept for revert (2026-09-28, explicit names): title: 'Trying for many months?',
          title: 'When to see a doctor',
          id: 'ttc_tile_trying_for_many_months',
          blurb: 'How long is normal before asking for help.',
          readId: 'ttc_read_when_to_seek_help',
        ),
        // Moved here from "How many times should we try?" (2026-09-27,
        // relevance audit): how LONG it takes is the doctor question.
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'How many months it usually takes',
          title: 'How long getting pregnant usually takes',
          id: 'ttc_tile_how_long_getting_pregnant_usually_takes',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: "Most couples need several cycles. Here's what's normal.",
          blurb: 'Most couples need several cycles, and what can make trying take longer.',
          readId: 'ttc_read_how_long_it_takes',
        ),
        TtcCarouselTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Signs not to wait',
          title: 'Signs to see a doctor sooner',
          id: 'ttc_tile_signs_not_to_wait',
          blurb: 'Reasons to see someone sooner, whatever the calendar says.',
          cards: [
            TtcCarouselCard(
              title: 'Periods that are irregular or missing',
              body: "If your cycles vary a lot, or stop for months, it's hard "
                  'to time anything. It usually has a treatable cause, so '
                  "it's worth checking rather than waiting a year.",
            ),
            TtcCarouselCard(
              title: 'Periods that are very painful',
              body: 'Pain that stops you working or needs strong medicine every '
                  "month isn't something to put up with. It can point to "
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
                  "rather than twelve. This isn't a warning and it isn't a "
                  'deadline. It only means an earlier look is worth having.',
            ),
          ],
        ),
        // ⚠️ THE GYNAECOLOGIST, NOT THE CONSULTS SHELF (2026-09-27, relevance
        // audit). `ttc_consult` opens three cards and asks her to choose; a
        // question about her own cycle is the gynaecologist's. A Talk tile,
        // because `openTtcFocusTile` resolves an offering id only on Talk; a
        // Booking tile with any action but the shared one opens nothing.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcBookingTile(
        //   title: 'Talk to a doctor',
        //   blurb: 'A private video consultation about your own cycle.',
        //   // ⚠️ THE BOOKING ENGINE, CONFIGURED — never a new appointment
        //   // feature. Resolved by the caller's hub-action switch, which scopes
        //   // it to consults; unscoped it opened nine categories and asked her to
        //   // scroll past yoga to find the thing she tapped.
        //   action: 'ttc_consult',
        // ),
        TtcTalkTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Talk to a doctor',
          title: 'Talk to a gynaecologist',
          id: 'ttc_tile_talk_to_a_doctor',
          blurb: 'A private video consultation with a gynaecologist about '
              'your own cycle.',
          action: 'ttc_consult_gynae',
        ),
      ],
    ),
  ],
);

/// Every focus page in the stage. One today.
