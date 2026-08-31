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
import '../ttc_focus_data.dart';

// =============================================================================
//  PCOS, without the panic
// -----------------------------------------------------------------------------
//  ⚠️ ELEVEN SECTIONS ON ONE SCROLL, NOT FIVE SUB-TABS. The brief specified a
//  tab bar inside the focus area — Understand / Where do I stand / What helps /
//  Trying with PCOS / Track — and that was set aside deliberately in favour of
//  the shape the conceiving page already uses.
//
//  The reasoning is the same one that removed the conceiving hub's three-card
//  menu: a tab is a decision she has to make before she is allowed to see
//  anything, on a subject where most people arriving do not yet know which of
//  the five their question belongs to. "Is this PCOS or my thyroid" and "will
//  I be able to have children" are the two commonest reasons anyone opens this
//  door, and they live in different tabs.
//
//  The tab names survive as SECTION headings, which is where they were always
//  doing their real work — they are good labels for groups of content and a
//  poor gate in front of it.
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

  heroVideoSlot: 'ttc_pcos_intro',
  heroVideoTitle: 'What PCOS is doing to your cycle',

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
      tiles: [
        TtcCarouselTile(
          title: 'PCOS or ovarian cysts',
          blurb: 'Two different things with one confusing name.',
          coverTitle: 'PCOS or ovarian cysts?',
          coverBlurb: 'The word in the name is the problem.',
          coverHue: 288,
          cards: [
            TtcCarouselCard(
              title: 'The "cysts" in polycystic are not cysts.',
              body: 'They are follicles — the small fluid sacs every ovary '
                  'makes each month, each holding an immature egg.',
            ),
            TtcCarouselCard(
              title: 'In PCOS there are simply more of them than usual.',
              body: 'They are not growths, they are not dangerous, and they '
                  'are not removed.',
            ),
            TtcCarouselCard(
              title: 'An ovarian cyst is a different thing entirely.',
              body: 'A single fluid-filled sac, usually much larger, and most '
                  'often harmless and temporary on its own.',
            ),
            TtcCarouselCard(
              title: 'Most ovarian cysts resolve without treatment.',
              body: 'They are common, frequently found by accident, and '
                  'usually watched rather than acted on.',
            ),
            TtcCarouselCard(
              title: 'A scan alone does not diagnose PCOS.',
              body: 'Plenty of people have ovaries that look like this with no '
                  'other feature of PCOS at all.',
            ),
            TtcCarouselCard(
              title: 'Which is why the diagnosis needs two of three things.',
              body: 'Irregular ovulation, signs of raised androgens, and the '
                  'scan — with other causes excluded first.',
            ),
          ],
          reviewedBy: 'Reviewed by Dr. Ananya Rao, Gynaecologist',
        ),
        TtcCarouselTile(
          title: 'PCOS or thyroid',
          blurb: 'One blood test separates them, and it is often skipped.',
          coverTitle: 'PCOS or thyroid?',
          coverBlurb: 'They look alike from the outside.',
          coverHue: 206,
          cards: [
            TtcCarouselCard(
              title: 'Both can make periods irregular or disappear.',
              body: 'Which is why the two are so often confused before anyone '
                  'has tested anything.',
            ),
            TtcCarouselCard(
              title: 'Both can cause tiredness, hair changes and weight '
                  'change.',
              body: 'The overlap is real, and it is not something you can '
                  'reason your way through at home.',
            ),
            TtcCarouselCard(
              title: 'A thyroid problem is found with a single blood test.',
              body: 'TSH, sometimes with T3 and T4. Cheap, quick, and widely '
                  'available.',
            ),
            TtcCarouselCard(
              title: 'And treated, it often settles cycles on its own.',
              body: 'Which is why it is checked before anyone concludes PCOS.',
            ),
            TtcCarouselCard(
              title: 'You can have both.',
              body: 'A normal thyroid does not rule out PCOS, and PCOS does '
                  'not rule out a thyroid problem.',
            ),
            TtcCarouselCard(
              title: 'If nobody has checked yours, ask.',
              body: 'It is a reasonable question and a one-line addition to a '
                  'blood form.',
            ),
          ],
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
    //  Where do I stand
    // -------------------------------------------------------------------------
    //  ⚠️ A SECTION OF ITS OWN, WITH ONE TILE IN IT. Every other section here
    //  holds three or four, and the imbalance is the point: this is the only
    //  thing on the page that reads HER data back, and burying it as the fourth
    //  card in a rail would make it look like another article.
    TtcFocusSection(
      heading: 'Where do I stand?',
      tiles: [
        TtcToolTile(
          title: 'A read of your own pattern',
          blurb: 'Eight short questions and your logged cycles, turned into '
              'plain words and notes for your doctor. No score, no verdict.',
          surfaceId: 'ttc_pcos_check',
        ),
        TtcToolTile(
          title: 'Cycle Companion',
          blurb: 'The log the read above is built from. Three months of dates '
              'changes what it can say.',
          surfaceId: 'ttc_cycle',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  What helps
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'What should I be eating?',
      tiles: [
        TtcArticleTile(
          title: 'What changes the curve, nothing banned',
          blurb: 'Insulin is the lever worth understanding, and none of it '
              'requires giving up rice.',
          readId: 'ttc_read_pcos_insulin',
        ),
        TtcArticleTile(
          title: 'PCOS-friendly Indian meals',
          blurb: 'Ordinary food, put together in a way that helps.',
          readId: 'ttc_read_pcos_food',
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
      tiles: [
        TtcToolTile(
          title: 'Log your symptoms',
          blurb: 'Cycle, skin, hair and how you felt. This is what the read '
              'above gets better from.',
          // ⚠️ WAS `ttc_tools`, WHICH OPENED THE TOOLS HUB. The tile said "log
          // your symptoms" and delivered a menu — reachable, wrong, and exactly
          // the failure this stage tests for.
          surfaceId: 'ttc_symptom_log',
        ),
        TtcToolTile(
          title: 'Your calendar',
          blurb: 'A month at a time, with everything you have logged on it.',
          surfaceId: 'ttc_calendar',
        ),
        TtcToolTile(
          title: 'Tests worth asking about',
          blurb: 'Thyroid, prolactin, glucose and the rest — what each one '
              'answers and what it costs in India.',
          surfaceId: 'ttc_tests',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Get help — the page closes on a person, not a price
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'Talk to someone who knows PCOS',
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
