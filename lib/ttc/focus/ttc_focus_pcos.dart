// =============================================================================
//  PCOS, without the panic — the focus page for this door
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

import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
import 'package:flutter/material.dart' show Icons;

import '../ttc_focus_data.dart';

// =============================================================================
//  PCOS, without the panic
// -----------------------------------------------------------------------------
//  ⚠️ THE ONLY GROUPED DOOR. Every other focus page is one long scroll; this
//  one opens on a photograph and a rail of five cards — Understand / Where do
//  I stand / What helps / Trying with PCOS / Track — and shows one group at a
//  time. Asked for after seeing Flo, and to be checked on a device here before
//  it goes anywhere else.
//
//  ⚠️ THIS REVERSES WHAT USED TO BE WRITTEN HERE, AND THE REVERSAL IS NARROW.
//  The note this replaces argued against the brief's five sub-tabs: a tab is a
//  decision she has to make before she is allowed to see anything, on a subject
//  where most people arriving do not know which of the five their question
//  belongs to. That objection was about a TAB BAR — a row of words where one is
//  lit, the other four are hidden, and nothing says what is behind them.
//
//  The selector is not that. It is a horizontal rail of picture cards in the
//  same language as every other rail on the page, sitting first under the hero,
//  so all five are read before one is chosen. The choice is made after seeing
//  the options rather than before, which is exactly what the old objection was
//  asking for.
//
//  ⚠️ SO DO NOT "FIX" THIS BACK. The door playbook's rule against sub-tabs
//  still holds for a tab bar and still holds for the other four doors. It does
//  not hold here. `docs/TTC-DOOR-BUILD.md` §1 has been amended to say so.
//
//  ⚠️ AND THE SECTIONS ARE PLAIN QUESTIONS WHERE THEY CAN BE. Same rule as the
//  conceiving page: the format never becomes a heading, and a heading she might
//  actually think in words beats a taxonomy every time.
// =============================================================================

const TtcFocusPage kTtcPcosFocus = TtcFocusPage(
  bracketId: 'ttc_pcos',

  // ⚠️ THE HUB'S OWN HERO LINE, KEPT VERBATIM. "PCOS, without the panic" is the
  // stage's best piece of copy and it belongs to this area; rewriting it while
  // restructuring underneath would have thrown away the one line users of the
  // old screen would recognise.
  intro: 'PCOS, without the panic. What it means for your body, and what '
      'helps while you are trying.',

  // ⚠️ THE FILM CAME OFF THE TOP, AND IT WAS ALREADY DOWN THE PAGE. The same
  // slot was the hero AND the first tile in "What is PCOS, really?", so the
  // page opened on a coming-soon placeholder and then offered the identical
  // placeholder again two sections later. Removing it from the hero loses
  // nothing; the tile below is where the PDF lists it.
  //
  // heroVideoSlot: 'ttc_pcos_intro',
  // heroVideoTitle: 'What PCOS is doing to your cycle',

  // ⚠️ A PLACEHOLDER PHOTOGRAPH, TO BE SWAPPED. Same shape the product
  // catalogue and the conceiving page already use. The V3 field renders behind
  // it, so a dead connection gives the hero this page has always had rather
  // than a grey box — local-first is absolute.
  heroImageUrl:
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=900&h=700&fit=crop',
  heroBlurb: 'PCOS is a condition where a hormone imbalance changes how the '
      'ovaries work. It is common, it varies a lot from person to person, and '
      'it is managed rather than cured.',

  // ---------------------------------------------------------------------------
  //  The selector rail — five cards under the hero, Understand first
  // ---------------------------------------------------------------------------
  // ⚠️ FIVE HUES, ONE EACH, AND THEY ARE THE APP'S OWN. 206 is `V2BlockHues.
  // scans` (the clinical blue), 344 `.watch`, 104 `.practice`, 42 `.read`. Only
  // Track's 160 is off the grid, and it is the same green the cycle report
  // gives the fertile stretch — the one place in this stage green already means
  // "your own logged data".
  //
  // ⚠️ THE ORDER IS THE PDF'S NUMBERED LIST AND IS NOT A RANKING. Understand is
  // first because it is where someone who has just been told a word lands, not
  // because it matters most.
  groups: [
    TtcFocusGroup(
        id: 'understand',
        label: 'Understand',
        icon: Icons.menu_book_outlined,
        hue: 206),
    // ⚠️ THE TOOL ITSELF, NOT A CARD THAT OPENS IT. See `TtcFocusGroup.
    // toolSurfaceId` — a tile in front of a tool, inside a group whose only
    // content is that tool, is a door in front of a door.
    TtcFocusGroup(
        id: 'stand',
        label: 'Where do I stand',
        icon: Icons.center_focus_weak_outlined,
        hue: 344,
        toolSurfaceId: 'ttc_pcos_check'),
    TtcFocusGroup(
        id: 'helps',
        label: 'What helps',
        icon: Icons.eco_outlined,
        hue: 104),
    TtcFocusGroup(
        id: 'trying',
        label: 'Trying with PCOS',
        icon: Icons.favorite_border_rounded,
        hue: 42),
    TtcFocusGroup(
        id: 'track',
        // ⚠️ "Track", NOT "Keep track of it". The design's mock data uses the
        // longer name and the section inside this group is already called
        // "Keep track of it" — so the tab and the heading under it would say
        // the same words twice, which is the repetition the group heading was
        // deleted to stop.
        label: 'Track',
        icon: Icons.calendar_today_outlined,
        hue: 160),
  ],

  // ⚠️ POPULATED BUT NOT DRAWN, exactly as on the conceiving page. The paid
  // masterclass was asked to come off the top of the focus pages for now and
  // the screen's `page.headline` render is commented out there; keeping the
  // data means restoring it is uncommenting three lines rather than rewriting
  // a tile. `ttc_focus_page_test.dart` asserts against the data, not the paint.
  headline: TtcMasterclassTile(
    title: 'The PCOS programme',
    blurb: 'A guided course with a specialist, at your own pace.',
    offeringId: 'ttc_course_pcos',
  ),

  sections: [
    // -------------------------------------------------------------------------
    //  Understand
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'What is PCOS, really?',
      group: 'understand',
      tiles: [
        TtcVideoTile(
          title: 'PCOS in five minutes',
          blurb: 'The whole picture, without the jargon.',
          slotId: 'ttc_pcos_intro',
          duration: '5 MIN',
        ),
        TtcArticleTile(
          title: 'PCOS and your cycle',
          blurb: 'What the condition does to the month you are living in.',
          readId: 'ttc_read_pcos_cycle',
        ),
        TtcArticleTile(
          title: 'Irregular periods, explained',
          blurb: 'What "irregular" means, and the long list of things that '
              'cause it.',
          readId: 'ttc_read_pcos_irregular',
        ),
        TtcMythTile(
          title: 'How common is PCOS',
          blurb: 'Common enough that you know several people with it.',
          myth: 'PCOS is rare, and having it means something has gone '
              'seriously wrong.',
          fact: 'Around one in ten people of reproductive age have PCOS. It '
              'runs on a wide spectrum — many have a mild version that shows '
              'up only as slightly unpredictable cycles — and it is managed '
              'rather than cured.',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Is it PCOS, or something else?',
      group: 'understand',
      tiles: [
        // WARNING: AN INFOGRAPHIC, WHICH IS ONE FRAME. This was six carousel
        // cards, and the brief always marked it Infographic -- the format did
        // not exist, so it became the nearest thing that did. The six beats
        // were a build-up to a comparison, and a comparison is what a single
        // frame does better than any number of slides: both halves are on
        // screen at once, so the difference is the picture rather than
        // something to remember across a swipe.
        TtcInfographicTile(
          title: 'PCOS or ovarian cysts',
          blurb: 'Two different things with one confusing name.',
          headline: 'The "cysts" in polycystic are not cysts at all.',
          left: TtcInfographicColumn(
            label: 'What a scan sees in PCOS',
            hue: 288,
            points: [
              'Follicles — the small fluid sacs every ovary makes each month, '
                  'each holding an immature egg.',
              'In PCOS there are simply more of them than usual.',
              'Not growths, not dangerous, and not removed.',
            ],
          ),
          right: TtcInfographicColumn(
            label: 'An ovarian cyst',
            hue: 206,
            points: [
              'A single fluid-filled sac, usually much larger.',
              'Common, and often found by accident.',
              'Most resolve on their own and are watched rather than acted on.',
            ],
          ),
          footnote: 'A scan alone does not diagnose PCOS — plenty of people '
              'have ovaries that look like this and no other feature of it. '
              'The diagnosis needs two of three things: irregular ovulation, '
              'signs of raised androgens, and the scan, with other causes '
              'excluded first.',
          reviewedBy: 'Reviewed by Dr. Ananya Rao, Gynaecologist',
        ),
        TtcInfographicTile(
          title: 'PCOS or thyroid',
          blurb: 'One blood test separates them, and it is often skipped.',
          headline: 'They look alike from the outside. One blood test tells '
              'them apart.',
          left: TtcInfographicColumn(
            label: 'What overlaps',
            hue: 42,
            points: [
              'Periods that are irregular or absent.',
              'Tiredness, hair changes, weight change.',
              'Enough overlap that you cannot reason it out at home.',
            ],
          ),
          right: TtcInfographicColumn(
            label: 'What separates them',
            hue: 206,
            points: [
              'A thyroid problem shows on one blood test — TSH, sometimes with '
                  'T3 and T4.',
              'Treated, it often settles cycles on its own.',
              'PCOS has no single test. It is a pattern, and thyroid is ruled '
                  'out first.',
            ],
          ),
          // WARNING: "YOU CAN HAVE BOTH" IS NOT A DETAIL TO CUT. A comparison
          // reads as either-or unless it says otherwise, and a woman told she
          // has PCOS can stop asking about her thyroid on exactly that
          // reasoning.
          footnote: 'You can have both — a normal thyroid does not rule out '
              'PCOS, and PCOS does not rule out a thyroid problem. If nobody '
              'has checked yours, ask. It is a one-line addition to a blood '
              'form and it is often skipped.',
          reviewedBy: 'Reviewed by Dr. Ananya Rao, Gynaecologist',
        ),
        TtcCarouselTile(
          title: 'Hair changes, explained',
          blurb: 'Growth where you would rather not, thinning where you would '
              'rather not.',
          coverTitle: 'Hair changes, explained',
          coverBlurb: 'Why both directions happen at once.',
          coverHue: 42,
          cards: [
            TtcCarouselCard(
              title: 'Androgens are hormones everyone has, in different '
                  'amounts.',
              body: 'In PCOS they can run higher than usual.',
            ),
            TtcCarouselCard(
              title: 'They make body hair coarser and darker.',
              body: 'Most often on the upper lip, chin, chest, belly or '
                  'thighs.',
            ),
            TtcCarouselCard(
              title: 'And they can thin hair on the scalp.',
              body: 'Usually at the crown and along the parting rather than '
                  'at the hairline.',
            ),
            TtcCarouselCard(
              title: 'Both directions, from the same cause.',
              body: 'Scalp follicles and body follicles respond to the same '
                  'hormone in opposite ways.',
            ),
            TtcCarouselCard(
              title: 'It is slow, and so is anything that changes it.',
              body: 'A hair follicle takes months to respond, so give any '
                  'treatment at least six.',
            ),
            TtcCarouselCard(
              title: 'Rapid change is the one thing to raise quickly.',
              body: 'Hair growth or loss that has changed sharply over weeks '
                  'deserves an appointment rather than a wait.',
            ),
          ],
          reviewedBy: 'Reviewed by Dr. Ananya Rao, Gynaecologist',
        ),
        TtcArticleTile(
          title: 'If a doctor says PCOS',
          blurb: 'What the diagnosis rests on, and what to ask before you '
              'leave the room.',
          readId: 'ttc_read_pcos_diagnosed',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Where do I stand — NOT A SECTION ANY MORE
    // -------------------------------------------------------------------------
    //  ⚠️ IT IS A GROUP THAT RENDERS THE TOOL ITSELF. This used to be a section
    //  holding a tile called "A read of your own pattern" which you tapped to
    //  leave the page. Selecting the group now shows the questions in place —
    //  `TtcFocusGroup.toolSurfaceId` on the `stand` entry above.
    //
    //  The old reasoning for giving it a section of its own still stands and is
    //  now served better: this is the only thing on the page that reads HER
    //  data back, so it gets its own card in the selector rather than being the
    //  fourth tile in somebody else's rail.
    //
    //  Its second tile, Cycle Companion, moved to "Keep track of it" — it is a
    //  log, and the group it was propping up no longer holds tiles.

    // -------------------------------------------------------------------------
    //  What helps
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'What should I be eating?',
      group: 'helps',
      tiles: [
        // WARNING: A FIFTH OWED FILM. The brief marks this "reuse existing" and
        // there is no such film anywhere in the repo -- the phrase describes
        // what the author expected to find, not what is there. It renders the
        // honest 16:9 placeholder like the other four, so nothing shifts when
        // the file lands. Recorded in `docs/STILL-OPEN.md` 18.6.
        TtcVideoTile(
          title: 'Food, insulin and PCOS',
          blurb: 'Why the same meal lands differently, and what that changes.',
          slotId: 'ttc_pcos_food_insulin',
          duration: '4 MIN',
        ),
        TtcArticleTile(
          title: 'What changes the curve, nothing banned',
          blurb: 'Insulin is the lever worth understanding, and none of it '
              'requires giving up rice.',
          readId: 'ttc_read_pcos_insulin',
        ),
        // WARNING: A REAL RECIPE ON THE REAL RECIPE PAGE, NOT AN ARTICLE ABOUT
        // RECIPES. This shipped as prose because the tile union had no recipe
        // format; the brief always said Recipe, and an article that describes
        // meals is the shape of a thing nobody cooks from.
        TtcRecipeTile(
          title: 'Moong dal chilla with curd',
          blurb: 'Protein and fibre instead of refined flour. Scales to the '
              'number you are cooking for.',
          recipeId: 'pcos_moong_chilla',
        ),
        TtcMythTile(
          title: 'Is rice really the enemy?',
          blurb: 'The most repeated piece of PCOS advice in India.',
          myth: 'People with PCOS have to give up rice, roti and all Indian '
              'carbohydrates.',
          fact: 'What a carbohydrate is eaten with changes the response far '
              'more than removing it would. A traditional thali already pairs '
              'carbohydrate with protein, fat, fibre and fermented food — '
              'which is exactly what flattens the rise.',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Do supplements actually do anything?',
      group: 'helps',
      tiles: [
        TtcArticleTile(
          title: 'Inositol: what is shown to help',
          blurb: 'The one with real trials behind it, and an honest account '
              'of how strong they are.',
          readId: 'ttc_read_pcos_inositol',
        ),
        TtcMythTile(
          title: 'Worth it vs hype',
          blurb: 'What the rest of the shelf is doing.',
          myth: 'The fertility blends, detox teas and PCOS-branded mixes are '
              'worth trying because they cannot hurt.',
          fact: 'Most have no evidence in PCOS at all. Some are harmless and '
              'expensive; a few, including berberine, interact with real '
              'medicines. Whatever you take, write it down and mention it at '
              'appointments.',
        ),
        TtcProductTile(
          title: 'Myo-inositol',
          blurb: 'If you decide to try it, this is the form the trials used.',
          productId: 'myo_inositol',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'What about movement, sleep and weight?',
      group: 'helps',
      tiles: [
        TtcArticleTile(
          title: 'Weight and PCOS, said kindly',
          blurb: 'No number, no target, no plan. What the relationship '
              'actually is.',
          readId: 'ttc_read_pcos_weight',
        ),
        TtcArticleTile(
          title: 'Stress, sleep and trying',
          blurb: 'What sustained stress does and does not do to a cycle.',
          readId: 'ttc_read_stress_fertility',
        ),
        TtcVideoTile(
          title: 'Gentle movement for PCOS',
          blurb: 'Ten minutes, nothing that needs a gym.',
          slotId: 'ttc_pcos_movement',
          duration: '10 MIN',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Trying with PCOS
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'How does PCOS affect conceiving?',
      group: 'trying',
      tiles: [
        TtcArticleTile(
          title: 'PCOS and ovulation',
          blurb: 'Why the egg is usually fine and the release is the problem.',
          readId: 'ttc_read_pcos_ovulation',
        ),
        TtcCarouselTile(
          title: 'Anovulatory cycles',
          blurb: 'A month that bleeds but did not release an egg.',
          coverTitle: 'A cycle that bleeds but did not ovulate',
          coverBlurb: 'How that happens, and how you would know.',
          coverHue: 268,
          cards: [
            TtcCarouselCard(
              title: 'Ovulation is the hinge of a cycle.',
              body: 'Once it happens, the second half runs to a fairly fixed '
                  'length of about twelve to fourteen days.',
            ),
            TtcCarouselCard(
              title: 'Sometimes no follicle becomes dominant.',
              body: 'Several start, none finishes, and no egg is released.',
            ),
            TtcCarouselCard(
              title: 'Bleeding can still happen.',
              body: 'The lining builds and eventually breaks down without the '
                  'usual hormonal sequence behind it.',
            ),
            TtcCarouselCard(
              title: 'Which is why these are easy to miss.',
              body: 'It looks like a period, so it is counted as one.',
            ),
            TtcCarouselCard(
              title: 'Very long cycles are the clue.',
              body: 'A cycle running well past forty-five days is more likely '
                  'to be one of these.',
            ),
            TtcCarouselCard(
              title: 'A blood test settles it.',
              body: 'Taken about a week before a period is due, it is the '
                  'straightforward way to check whether ovulation happened.',
            ),
          ],
          reviewedBy: 'Reviewed by Dr. Ananya Rao, Gynaecologist',
        ),
        TtcArticleTile(
          title: 'Conceiving with PCOS, realistically',
          blurb: 'What the research says about how long it takes, without '
              'false cheer or doom.',
          readId: 'ttc_read_pcos_timelines',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'What happens if we need treatment?',
      group: 'trying',
      tiles: [
        TtcArticleTile(
          title: 'What treatment usually looks like',
          blurb: 'The shape of it, before anyone offers you anything.',
          readId: 'ttc_read_pcos_treatment',
        ),
        TtcArticleTile(
          title: 'Letrozole, metformin and the usual order',
          blurb: 'What gets tried first, and what each one is actually doing.',
          readId: 'ttc_read_pcos_meds',
        ),
        TtcArticleTile(
          title: 'When to see a specialist',
          blurb: 'The point at which waiting stops being the better plan.',
          readId: 'ttc_read_when_to_seek_help',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Track
    // -------------------------------------------------------------------------
    //  ⚠️ TOOLS, NOT READING, AND THE BRIEF ASKED FOR THEM AS FULL-WIDTH ACTION
    //  CARDS RATHER THAN A BROWSE RAIL. That distinction is real and it is
    //  preserved in spirit rather than in geometry: the page has one card shape,
    //  so these stay rail tiles, but they are grouped under a heading that says
    //  plainly they are things you use rather than things you read.
    TtcFocusSection(
      heading: 'Keep track of it',
      group: 'track',
      // WARNING: THESE FIVE, IN THIS ORDER, ARE THE BRIEF'S OWN LIST. The tab
      // had drifted to four tools -- two from the brief and two invented -- and
      // was missing the three items that are not tools at all. Asked for
      // directly: *"those 3 points haven't been followed... just follow what's
      // in the pdf."*
      //
      // WARNING: SO TRACK IS NOT A TOOLS DRAWER, and the brief is clearer about
      // that than the old list was. Two tools, one way back to her read, one
      // quiet clinical card, one room of people. That mix is the point: the
      // group is "keep track of it", and keeping track includes knowing when to
      // stop tracking and go and see someone.
      tiles: [
        TtcToolTile(
          title: 'Cycle Companion',
          blurb: 'The log your read is built from. Three months of dates '
              'changes what it can say.',
          surfaceId: 'ttc_cycle',
        ),
        TtcToolTile(
          title: 'Log your symptoms',
          // WARNING: WAS `ttc_tools`, WHICH OPENED THE TOOLS HUB. The tile said
          // "log your symptoms" and delivered a menu -- reachable, wrong, and
          // exactly the failure this stage tests for.
          blurb: 'Cycle, skin, hair and how you felt. This is what the read '
              'gets better from.',
          surfaceId: 'ttc_symptom_log',
        ),
        TtcToolTile(
          title: 'What your cycle shows',
          blurb: 'Your logged months, read back as a pattern in plain words.',
          surfaceId: 'ttc_pcos_check',
        ),
        // WARNING: QUIET, AND THE BRIEF SAYS SO TWICE. "Calm card, quiet, not
        // alarming." So: no red, no warning mark, no urgency, and every slide
        // ends at a booking rather than at a fear. The strongest it gets is
        // "worth booking a check" -- the same ceiling the self-read is held to.
        //
        // A carousel rather than an article because it is four short things to
        // notice, and a 700-word read on when to be worried is a read nobody
        // finishes and everybody skims for the frightening part.
        TtcCarouselTile(
          title: 'When to see a doctor',
          blurb: 'Four things worth a check, and none of them are emergencies.',
          coverTitle: 'When to see a doctor',
          coverBlurb: 'Not urgent. Just worth booking.',
          coverHue: 206,
          reviewedBy: 'Reviewed by a gynaecologist',
          cards: [
            TtcCarouselCard(
              title: 'Your periods have stopped for three months or more',
              body: 'Leaving aside pregnancy, breastfeeding and birth control. '
                  'A long gap has many causes and a doctor can find which one.',
              hue: 344,
            ),
            TtcCarouselCard(
              title: 'You have been trying for a year, or six months if you '
                  'are 35 or older',
              body: 'These are the points at which a fertility check is usual. '
                  'It is a starting conversation, not a last resort.',
              hue: 206,
            ),
            TtcCarouselCard(
              title: 'Something changed and it has stayed changed',
              body: 'Hair, skin, weight or your cycle behaving differently for '
                  'a few months is worth mentioning, even if each thing on its '
                  'own seems small.',
              hue: 42,
            ),
            TtcCarouselCard(
              title: 'You are worried',
              body: 'That is reason enough. You do not need a symptom list to '
                  'be allowed to ask someone.',
              hue: 160,
            ),
          ],
        ),
        TtcCommunityTile(
          title: 'PCOS circle',
          blurb: 'Other people managing PCOS, in their own words.',
          surfaceId: 'ttc_community',
        ),
      ],
    ),

    // WARNING: COMMENTED OUT, NOT DELETED, per CLAUDE.md. Two tools that were
    // in this group and are not in the brief. Neither is stranded -- the
    // calendar is reachable from the home, the More screen, a journey step and
    // two brackets; the tests library from the home, a journey step and four
    // brackets. Restoring them is uncommenting two tiles.
    //
    //   TtcToolTile(
    //     title: 'Your calendar',
    //     blurb: 'A month at a time, with everything you have logged on it.',
    //     surfaceId: 'ttc_calendar',
    //   ),
    //   TtcToolTile(
    //     title: 'Tests worth asking about',
    //     blurb: 'Thyroid, prolactin, glucose and the rest - what each one '
    //         'answers and what it costs in India.',
    //     surfaceId: 'ttc_tests',
    //   ),

    // -------------------------------------------------------------------------
    //  Get help — the page closes on a person, not a price
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'Talk to someone who knows PCOS',
      group: 'trying',
      tiles: [
        TtcBookingTile(
          title: 'Talk to a PCOS specialist',
          blurb: 'Book a 1:1 and ask about managing PCOS while trying.',
          action: kTtcActConsult,
        ),
        TtcMasterclassTile(
          title: 'The PCOS programme',
          blurb: 'A guided course with a specialist, at your own pace.',
          offeringId: 'ttc_course_pcos',
        ),
      ],
    ),
  ],
);
