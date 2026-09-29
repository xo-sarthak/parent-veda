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

// Unused since the consult tiles name their offering (2026-09-27,
// relevance audit). Kept for revert:
// import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
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
  intro: "PCOS, without the panic. What it means for your body, and what "
      "helps while you're trying.",

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
  // Our own photograph (2026-09-27): generated to the door's brief, checked by
  // eye, mirrored to the R2 bucket. Kept for revert: the previous value.
  // heroImageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=900&h=700&fit=crop',
  heroImageUrl: 'https://pub-bfbc0773e60e4c5c851b535f08b384bc.r2.dev/ttc_door_pcos.jpg',
  // The new door's headline, a sentence (TtcDoorScreen, 2026-09-26).
  heroTitle: 'PCOS, without the panic.',
  heroBlurb: 'PCOS is a condition where a hormone imbalance changes how the '
      "ovaries work. It's common, and it looks different in every person. "
      "It's managed rather than cured.",

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
        id: 'understand', mark: IntentMark.bookMark, tabMark: TtcTabMark.openBook,
        // Kept for revert (2026-09-28, explicit names): label: 'Understand',
        label: 'Understand PCOS',
        icon: Icons.menu_book_outlined,
        hue: 206),
    // ⚠️ THE TOOL ITSELF, NOT A CARD THAT OPENS IT. See `TtcFocusGroup.
    // toolSurfaceId` — a tile in front of a tool, inside a group whose only
    // content is that tool, is a door in front of a door.
    TtcFocusGroup(
        id: 'stand', mark: IntentMark.compassMark, tabMark: TtcTabMark.pin, inlineLabel: 'A quick check',
        label: 'Where do I stand',
        icon: Icons.center_focus_weak_outlined,
        hue: 344,
        toolSurfaceId: 'ttc_pcos_check'),
    TtcFocusGroup(
        id: 'helps', mark: IntentMark.improveMark, tabMark: TtcTabMark.sprout,
        label: 'What helps',
        icon: Icons.eco_outlined,
        hue: 104),
    TtcFocusGroup(
        id: 'trying', mark: IntentMark.cycleRing, tabMark: TtcTabMark.windowRing,
        label: 'Trying with PCOS',
        icon: Icons.favorite_border_rounded,
        hue: 42),
    TtcFocusGroup(
        id: 'track', mark: IntentMark.chartLog, tabMark: TtcTabMark.chartLine,
        // ⚠️ "Track", NOT "Keep track of it". The design's mock data uses the
        // longer name and the section inside this group is already called
        // "Keep track of it" — so the tab and the heading under it would say
        // the same words twice, which is the repetition the group heading was
        // deleted to stop.
        // Kept for revert (2026-09-28, explicit names): label: 'Track',
        label: 'Track your cycle',
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
    id: 'ttc_tile_the_pcos_programme',
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
        // ⚠️ THE WRITTEN FILM WITH THIS PROMISE (2026-09-27, relevance
        // audit). `ttc_pcos_intro` has no entry in `ttc_videos_data.dart`;
        // `ttc_vid_pcos_explained` is written, chaptered and was on no door.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcVideoTile(
        //   title: 'PCOS in five minutes',
        //   blurb: 'The whole picture, in plain words.',
        //   slotId: 'ttc_pcos_intro',
        //   duration: '5 MIN',
        // ),
        TtcVideoTile(
          title: 'PCOS, explained in five minutes',
          id: 'ttc_tile_pcos_explained_in_five_minutes',
          blurb: "What's going on in your ovaries, without the confusing "
              'diagrams.',
          slotId: 'ttc_vid_pcos_explained',
          duration: '5 MIN',
        ),
        TtcArticleTile(
          title: 'PCOS and your cycle',
          id: 'ttc_tile_pcos_and_your_cycle',
          blurb: 'What PCOS does to your month, day by day.',
          readId: 'ttc_read_pcos_cycle',
        ),
        TtcArticleTile(
          title: 'Irregular periods, explained',
          id: 'ttc_tile_irregular_periods_explained',
          blurb: 'What "irregular" means, and the many things that can '
              'cause it.',
          readId: 'ttc_read_pcos_irregular',
        ),
        TtcMythTile(
          title: 'How common is PCOS?',
          id: 'ttc_tile_how_common_is_pcos',
          blurb: "So common that you likely know a few people who have it.",
          myth: 'PCOS is rare, and having it means something has gone '
              'badly wrong.',
          fact: 'Around one in ten people of reproductive age have PCOS. It '
              'ranges from mild to more marked. Many people have a mild kind '
              'that only shows up as cycles that are a little hard to '
              "predict. It's managed rather than cured.",
        ),
      ],
    ),

    TtcFocusSection(
      // Kept for revert (2026-09-28, explicit names): heading: 'Is it PCOS, or something else?',
      heading: 'PCOS, or something else?',
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
          id: 'ttc_tile_pcos_or_ovarian_cysts',
          blurb: 'Two different things that sound alike.',
          headline: "The \"cysts\" in polycystic aren't cysts at all.",
          left: TtcInfographicColumn(
            label: 'What a scan sees in PCOS',
            hue: 288,
            points: [
              'Follicles. These are the small fluid sacs every ovary makes each '
                  'month, and each one holds an egg that is not yet ripe.',
              'In PCOS there are just more of them than usual.',
              "They aren't growths, they aren't dangerous, and they aren't "
                  'removed.',
            ],
          ),
          right: TtcInfographicColumn(
            label: 'An ovarian cyst',
            hue: 206,
            points: [
              'A single sac filled with fluid, usually much bigger.',
              "It's common, and often found by chance.",
              'Most go away on their own, so doctors watch them rather than '
                  'treat them.',
            ],
          ),
          footnote: "A scan alone doesn't diagnose PCOS. Plenty of people have "
              'ovaries that look like this and no other sign of it. To '
              'diagnose PCOS, a doctor needs two of three things: irregular '
              'ovulation, signs of raised androgens (male-type hormones), and '
              'the scan. Other causes are ruled out first.',
          reviewedBy: 'Reviewed by Dr Ruchika Sood, IVF gynaecologist',
        ),
        TtcInfographicTile(
          title: 'PCOS or thyroid',
          id: 'ttc_tile_pcos_or_thyroid',
          blurb: 'One blood test tells them apart, and it often gets missed.',
          headline: 'They look alike from the outside. One blood test tells '
              'them apart.',
          left: TtcInfographicColumn(
            label: 'What overlaps',
            hue: 42,
            points: [
              'Periods that are irregular or missing.',
              'Tiredness, hair changes, weight change.',
              "So much overlap that you can't work it out at home.",
            ],
          ),
          right: TtcInfographicColumn(
            label: 'What separates them',
            hue: 206,
            points: [
              'A thyroid problem shows up on one blood test: TSH, sometimes '
                  'with T3 and T4.',
              'Once it is treated, cycles often settle by themselves.',
              "PCOS has no single test. It's a pattern, and thyroid is ruled "
                  'out first.',
            ],
          ),
          // WARNING: "YOU CAN HAVE BOTH" IS NOT A DETAIL TO CUT. A comparison
          // reads as either-or unless it says otherwise, and a woman told she
          // has PCOS can stop asking about her thyroid on exactly that
          // reasoning.
          footnote: "You can have both. A normal thyroid doesn't rule out "
              "PCOS, and PCOS doesn't rule out a thyroid problem. If no one "
              "has checked yours, ask. It's one more line on a blood test "
              'form, and it often gets missed.',
          reviewedBy: 'Reviewed by Dr Ruchika Sood, IVF gynaecologist',
        ),
        TtcCarouselTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Hair changes, explained',
          title: 'Hair changes with PCOS, explained',
          id: 'ttc_tile_hair_changes_explained',
          blurb: "More hair where you don't want it, less where you do.",
          coverTitle: 'Hair changes, explained',
          coverBlurb: 'Why hair can grow and thin at the same time.',
          coverHue: 42,
          cards: [
            TtcCarouselCard(
              title: 'Androgens are hormones everyone has, in different '
                  'amounts.',
              body: 'In PCOS they can be higher than usual.',
            ),
            TtcCarouselCard(
              title: 'They make body hair thicker and darker.',
              body: 'Most often on the upper lip, chin, chest, belly or '
                  'thighs.',
            ),
            TtcCarouselCard(
              title: 'They can also thin the hair on your head.',
              body: 'Usually on top and along the parting, not at the '
                  'hairline.',
            ),
            TtcCarouselCard(
              title: 'Both changes come from the same cause.',
              body: 'Hair on your head and hair on your body react to the same '
                  'hormone in opposite ways.',
            ),
            // Added 2026-09-26 (gap plan, W10 note): thinning has common
            // causes besides PCOS, and they are one blood test away. No dose,
            // on purpose; that is the doctor's call once the result is back.
            TtcCarouselCard(
              title: 'Check iron, vitamin D and thyroid first.',
              body: 'Thinning on your head often has other, simple causes. '
                  'Ask for these blood tests before you put it all down to '
                  'PCOS.',
            ),
            TtcCarouselCard(
              title: "It's slow, and so is anything that changes it.",
              body: 'A hair root takes months to respond, so give any '
                  'treatment at least six.',
            ),
            TtcCarouselCard(
              title: 'Fast change is worth raising soon.',
              body: 'If hair growth or hair loss has changed sharply over a few '
                  "weeks, book a visit. Don't wait.",
            ),
          ],
          reviewedBy: 'Reviewed by Dr Ruchika Sood, IVF gynaecologist',
        ),
        TtcArticleTile(
          title: 'If a doctor says PCOS',
          id: 'ttc_tile_if_a_doctor_says_pcos',
          blurb: 'What the diagnosis is based on, and what to ask before you '
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
        // ⚠️ THE WRITTEN FILM ON THIS QUESTION (2026-09-27, relevance
        // audit). `ttc_pcos_food_insulin` has no entry in
        // `ttc_videos_data.dart`; `ttc_vid_pcos_plate` is written and was on
        // no door. Kept for revert (2026-09-27, relevance audit):
        // TtcVideoTile(
        //   title: 'Food, insulin and PCOS',
        //   blurb: 'Why the same meal affects you differently, and what that '
        //       'means.',
        //   slotId: 'ttc_pcos_food_insulin',
        //   duration: '4 MIN',
        // ),
        TtcVideoTile(
          title: 'What a PCOS-friendly Indian plate looks like',
          id: 'ttc_tile_what_a_pcos_friendly_indian_plate_looks_like',
          blurb: "Roti, rice and dal aren't the problem. What you eat with "
              'them is what matters.',
          slotId: 'ttc_vid_pcos_plate',
          duration: '7 MIN',
        ),
        TtcArticleTile(
          title: 'Eating for steadier blood sugar, with nothing banned',
          id: 'ttc_tile_eating_for_steadier_blood_sugar_with_nothing_banned',
          blurb: "Insulin is the part worth understanding, and none of it "
              "means giving up rice.",
          readId: 'ttc_read_pcos_insulin',
        ),
        // ⚠️ THE READ THE PDF ASKED FOR, NOW ON THE DOOR (launch walk,
        // 2026-09-27): it existed with a sample Indian day of eating and no
        // door linked it, while a film of the same name sat here unmade.
        TtcArticleTile(
          title: 'A day of eating, with PCOS',
          id: 'ttc_tile_a_day_of_eating_with_pcos',
          blurb: 'What helps in an Indian kitchen, and what a whole day can '
              'look like.',
          readId: 'ttc_read_pcos_food',
          atHeading: 'What does a day of eating like this look like?',
        ),
        // WARNING: A REAL RECIPE ON THE REAL RECIPE PAGE, NOT AN ARTICLE ABOUT
        // RECIPES. This shipped as prose because the tile union had no recipe
        // format; the brief always said Recipe, and an article that describes
        // meals is the shape of a thing nobody cooks from.
        TtcRecipeTile(
          title: 'Moong dal chilla with curd',
          id: 'ttc_tile_moong_dal_chilla_with_curd',
          blurb: 'Protein and fibre in place of refined flour (maida). Makes '
              "as many as you're cooking for.",
          recipeId: 'pcos_moong_chilla',
        ),
        TtcMythTile(
          title: 'Do you have to give up rice?',
          id: 'ttc_tile_do_you_have_to_give_up_rice',
          blurb: 'The PCOS advice you will hear most often in India.',
          myth: 'People with PCOS have to give up rice, roti and all Indian '
              'carbohydrates.',
          fact: 'What you eat a carbohydrate with matters far more than '
              'cutting it out. A home thali already puts carbohydrate '
              'together with protein, fat, fibre and curd or other fermented '
              "food. That's exactly what keeps blood sugar from rising fast.",
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'Do supplements help at all?',
      group: 'helps',
      tiles: [
        TtcArticleTile(
          title: 'Inositol: what the studies show',
          id: 'ttc_tile_inositol_what_the_studies_show',
          blurb: 'The one supplement with real trials behind it, and an '
              'honest look at how strong they are.',
          readId: 'ttc_read_pcos_inositol',
        ),
        TtcMythTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Worth it or hype?',
          title: 'PCOS supplements: worth it or hype?',
          id: 'ttc_tile_worth_it_or_hype',
          blurb: 'What the rest of the chemist shelf is doing.',
          myth: 'Fertility blends, detox teas and PCOS mixes are worth trying '
              "because they can't hurt.",
          fact: 'Most have no proof of working in PCOS at all. Some are '
              'harmless but costly. A few, including berberine, clash with '
              'real medicines. Whatever you take, write it down and tell your '
              'doctor at each visit.',
        ),
        TtcProductTile(
          title: 'Myo-inositol',
          id: 'ttc_tile_myo_inositol',
          blurb: 'If you decide to try it, this is the form used in the '
              'trials.',
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
          id: 'ttc_tile_weight_and_pcos_said_kindly',
          blurb: 'No number, no target, no plan. Just how weight and PCOS '
              'are linked.',
          readId: 'ttc_read_pcos_weight',
        ),
        // ⚠️ THE PCOS ANSWER, NOT THE GENERAL STRESS READ (2026-09-27,
        // relevance audit). The stress read has no sleep section and nothing
        // on PCOS; the insulin read answers sleep, movement and yoga for PCOS.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcArticleTile(
        //   title: 'Stress, sleep and trying',
        //   blurb: "What long-lasting stress does and doesn't do to your "
        //       'cycle.',
        //   readId: 'ttc_read_stress_fertility',
        // ),
        TtcArticleTile(
          title: 'Sleep, movement and insulin',
          id: 'ttc_tile_sleep_movement_and_insulin',
          blurb: 'Why a few short nights and a little strength work change '
              'how your body handles sugar.',
          readId: 'ttc_read_pcos_insulin',
          atHeading: 'Why do sleep and exercise matter?',
        ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Yoga, and your mood',
          title: 'Yoga for PCOS, and your mood',
          id: 'ttc_tile_yoga_and_your_mood',
          blurb: 'What the small trials found, and why moving helps how you '
              'feel.',
          readId: 'ttc_read_pcos_insulin',
          atHeading: 'Does yoga help, and what about your mood?',
        ),
        TtcVideoTile(
          title: 'Gentle movement for PCOS',
          id: 'ttc_tile_gentle_movement_for_pcos',
          blurb: 'Ten minutes, and you won\'t need a gym.',
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
          id: 'ttc_tile_pcos_and_ovulation',
          blurb: 'Why the egg is usually fine, and the problem is getting it '
              'released.',
          readId: 'ttc_read_pcos_ovulation',
        ),
        TtcCarouselTile(
          title: 'Cycles without ovulation',
          id: 'ttc_tile_cycles_without_ovulation',
          blurb: "A month with a bleed but no egg released.",
          coverTitle: "A cycle with a bleed but no ovulation",
          coverBlurb: "How that happens, and how you'd know.",
          coverHue: 268,
          cards: [
            TtcCarouselCard(
              title: 'Ovulation is the turning point of a cycle.',
              body: 'Once it happens, the second half lasts a fairly set '
                  'time of about twelve to fourteen days.',
            ),
            TtcCarouselCard(
              title: 'Sometimes no follicle takes the lead.',
              body: 'Several start to grow, none finishes, and no egg is '
                  'released.',
            ),
            TtcCarouselCard(
              title: 'You can still bleed.',
              body: 'The lining of the womb builds up and in the end breaks '
                  'down, without the usual hormone steps behind it.',
            ),
            TtcCarouselCard(
              title: "That's why these cycles are easy to miss.",
              body: 'It looks like a period, so it gets counted as one.',
            ),
            TtcCarouselCard(
              title: 'Very long cycles are the clue.',
              body: 'A cycle that goes well past forty-five days is more likely '
                  'to be one of these.',
            ),
            TtcCarouselCard(
              title: 'A blood test gives the answer.',
              body: 'Done about a week before your period is due, it is the '
                  'easy way to check whether you ovulated.',
            ),
          ],
          reviewedBy: 'Reviewed by Dr Ruchika Sood, IVF gynaecologist',
        ),
        TtcArticleTile(
          title: 'Getting pregnant with PCOS: what to expect',
          id: 'ttc_tile_getting_pregnant_with_pcos_what_to_expect',
          blurb: 'What research says about how long it takes, honestly and '
              'without doom.',
          readId: 'ttc_read_pcos_timelines',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'What happens if we need treatment?',
      group: 'trying',
      tiles: [
        // ⚠️ THE WRITTEN FILM ON THIS QUESTION (2026-09-27, relevance
        // audit): `ttc_vid_pcos_treatment` was on no door.
        TtcVideoTile(
          title: 'The PCOS treatments your doctor may offer',
          id: 'ttc_tile_the_pcos_treatments_your_doctor_may_offer',
          blurb: 'The order treatments are tried in, and what to ask before '
              'you agree to any of them.',
          slotId: 'ttc_vid_pcos_treatment',
          duration: '7 MIN',
        ),
        // ⚠️ NARROWED TO ITS OWN STEP (2026-09-27, relevance audit). Both
        // reads opened on the same short answer (lifestyle, then letrozole,
        // then metformin), so this one now lands on the step before any
        // tablet and the medicines read keeps the order.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcArticleTile(
        //   title: 'What treatment usually looks like',
        //   blurb: 'The usual steps, before anyone offers you anything.',
        //   readId: 'ttc_read_pcos_treatment',
        // ),
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'Before any tablet',
          title: 'What comes before any PCOS tablet',
          id: 'ttc_tile_what_comes_before_any_pcos_tablet',
          // Kept for revert (2026-09-28, explicit names):
          // blurb: 'The first step a doctor usually suggests, and why it keeps '
          // 'mattering.',
          blurb: 'The first step a doctor usually suggests, and why that step keeps mattering.',
          readId: 'ttc_read_pcos_treatment',
          atHeading: 'What comes before any tablet?',
        ),
        TtcArticleTile(
          title: 'Letrozole, metformin and the usual order',
          id: 'ttc_tile_letrozole_metformin_and_the_usual_order',
          blurb: 'What gets tried first, and what each one does.',
          readId: 'ttc_read_pcos_meds',
        ),
        // ⚠️ MOVED TO "Talk to someone who knows PCOS" AND REPOINTED
        // (2026-09-27, relevance audit): the general read gives the 12 and 6
        // month rule, and with PCOS the answer is sooner.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcArticleTile(
        //   title: 'When to see a specialist',
        //   blurb: 'The point where waiting is no longer the better plan.',
        //   readId: 'ttc_read_when_to_seek_help',
        // ),
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
      // Kept for revert (2026-09-28, explicit names): heading: 'Keep track of it',
      // Not 'Keep track of your cycle': the tab above is 'Track your cycle',
      // and a heading that repeats its tab says nothing (2026-09-28).
      heading: 'What is worth logging with PCOS?',
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
          // One name for one tool (2026-09-28): the Tools tab and Body and
          // cycle say 'Cycle companion'. Kept for revert: 'Cycle Companion'.
          title: 'Cycle companion',
          id: 'ttc_tile_cycle_companion',
          blurb: 'Your pattern is read from this log. Three months of dates '
              'lets it tell you much more.',
          surfaceId: 'ttc_cycle',
        ),
        TtcToolTile(
          title: 'Log your symptoms',
          id: 'ttc_tile_log_your_symptoms',
          // WARNING: WAS `ttc_tools`, WHICH OPENED THE TOOLS HUB. The tile said
          // "log your symptoms" and delivered a menu -- reachable, wrong, and
          // exactly the failure this stage tests for.
          blurb: 'Your cycle, skin, hair and how you felt. The more you log, '
              'the better your pattern read gets.',
          surfaceId: 'ttc_symptom_log',
        ),
        // ⚠️ THE CYCLE REPORT, NOT THE SELF-CHECK (2026-09-27, relevance
        // audit). `ttc_pcos_check` is the eight-question check that already
        // fills the "Where do I stand" tab. The report is what this tile
        // promises: the months she logged, in plain words.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcToolTile(
        //   title: 'What your cycle shows',
        //   blurb: 'The months you logged, turned into a pattern in plain words.',
        //   surfaceId: 'ttc_pcos_check',
        // ),
        TtcToolTile(
          title: 'What your cycle shows',
          id: 'ttc_tile_what_your_cycle_shows',
          blurb: 'The months you logged, turned into a pattern in plain words.',
          surfaceId: 'ttc_cycle_report',
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
          // Kept for revert (2026-09-28, explicit names): title: 'When to see a doctor',
          title: 'When to see a doctor about PCOS',
          id: 'ttc_tile_when_to_see_a_doctor',
          blurb: 'Four things worth a check. None of them is an emergency.',
          coverTitle: 'When to see a doctor',
          coverBlurb: 'Not urgent. Just worth booking.',
          coverHue: 206,
          reviewedBy: 'Reviewed by Dr Ruchika Sood, IVF gynaecologist',
          cards: [
            TtcCarouselCard(
              title: 'Your periods have stopped for three months or more',
              body: "This doesn't count pregnancy, breastfeeding or birth "
                  'control. A long gap can have many causes, and a doctor can '
                  'find which one it is.',
              hue: 344,
            ),
            TtcCarouselCard(
              title: "You've been trying for a year, or six months if you're "
                  '35 or older',
              body: "That's when a fertility check is usual. It's a first "
                  'conversation, not a last resort.',
              hue: 206,
            ),
            TtcCarouselCard(
              title: "Something changed and hasn't gone back",
              body: 'If your hair, skin, weight or cycle has been different for '
                  'a few months, mention it, even if each thing seems small on '
                  'its own.',
              hue: 42,
            ),
            TtcCarouselCard(
              title: "You're worried",
              body: "That's reason enough. You don't need a list of symptoms "
                  'to ask someone.',
              hue: 160,
            ),
          ],
        ),
        // Community held back for launch (2026-09-26, TTC gap plan §7.1) — kept for revert.
        // TtcCommunityTile(
        //   title: 'PCOS circle',
        //   blurb: 'Other people living with PCOS, in their own words.',
        //   surfaceId: 'ttc_community',
        // ),
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
        // Moved here from "What happens if we need treatment?" and pointed at
        // the PCOS answer (2026-09-27, relevance audit).
        TtcArticleTile(
          // Kept for revert (2026-09-28, explicit names): title: 'When to see a specialist',
          title: 'When to see a PCOS specialist',
          id: 'ttc_tile_when_to_see_a_specialist',
          blurb: 'With PCOS the clock starts sooner. The point where waiting '
              'is no longer the better plan.',
          readId: 'ttc_read_pcos_timelines',
          atHeading: 'When should you stop waiting and ask?',
        ),
        // ⚠️ THE GYNAECOLOGIST, NOT THE CONSULTS SHELF (2026-09-27, relevance
        // audit). That offering names PCOS in its own description. A Talk
        // tile, because `openTtcFocusTile` resolves an offering id only on
        // Talk; a Booking tile with any other action opens nothing.
        // Kept for revert (2026-09-27, relevance audit):
        // TtcBookingTile(
        //   title: 'Talk to a PCOS specialist',
        //   blurb: 'Book a 1:1 and ask about managing PCOS while you try.',
        //   action: kTtcActConsult,
        // ),
        TtcTalkTile(
          title: 'Talk to a PCOS specialist',
          id: 'ttc_tile_talk_to_a_pcos_specialist',
          blurb: 'A 1:1 with a gynaecologist about managing PCOS while you '
              'try.',
          action: 'ttc_consult_gynae',
        ),
        TtcMasterclassTile(
          title: 'The PCOS programme',
          id: 'ttc_tile_the_pcos_programme',
          blurb: 'A guided course with a specialist, at your own pace.',
          offeringId: 'ttc_course_pcos',
        ),
      ],
    ),
  ],
);
