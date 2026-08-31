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

  heroVideoSlot: 'ttc_conceiving_intro',
  heroVideoTitle: 'What actually helps, in two minutes',

  headline: TtcMasterclassTile(
    title: 'How to improve your chances of getting pregnant',
    blurb: 'A short course with a fertility doctor. Watch at your own time.',
    offeringId: 'ttc_course_basics',
  ),

  sections: [
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'When should we have sex?',
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
          imageUrl:
              // ⚠️ A CALENDAR, NOT A LANDSCAPE. The first URL here was a mountain,
              // picked for looking calm rather than for meaning anything — the
              // exact failure of stock imagery, where a picture is chosen for
              // mood and ends up decorating a subject it has nothing to do
              // with. This piece is about WHICH DAYS, so the picture is days.
              'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=800&h=600&fit=crop',
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
    //  ⚠️ HIS SECTION COMES BEFORE HERS, AND THAT ORDER IS THE POINT. A male
    //  factor is involved in about half of couples who take longer than
    //  expected, and in this market almost all of the advice, testing and blame
    //  lands on her. Putting his three things first is the cheapest correction
    //  this page can make.
    TtcFocusSection(
      heading: 'What he should do',
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
      ],
    ),

    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'What she should do',
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
      ],
    ),

    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'Does stress stop pregnancy?',
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
    //  ⚠️ THE PAGE ENDS BY ROUTING TO A PERSON. CLAUDE.md: anything clinical
    //  ends with a disclaimer and routes calmly to a doctor. It closes on the
    //  consult rather than on the shop for the same reason the V3 home does.
    TtcFocusSection(
      heading: 'When should we see a doctor?',
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
