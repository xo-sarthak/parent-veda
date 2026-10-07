// =============================================================================
//  Feeding — the section's content
// -----------------------------------------------------------------------------
//  Built from pp_specs/02-feeding.md, against the mechanism in
//  docs/PP-SECTION-PATTERN.md. Eight areas plus five tools.
//
//  ⚠️ THIS FILE IS DATA. No layout, no Scaffold, no TextStyle. `PpSectionScreen`
//  renders the landing and `PpContentPage` renders every page. See
//  pp_content.dart's header for why that is not negotiable.
//
//  ⚠️ NO BREASTFEEDING GUILT, ANYWHERE. The spec states it and it is a market
//  fact rather than a preference: Indian guilt about not exclusively
//  breastfeeding is real, loud, and usually delivered by a relative. So formula
//  and combination feeding are described the way breastfeeding is described,
//  with the same warmth and the same practical detail, and "fed is fine" is a
//  statement of fact rather than a consolation offered after the real advice.
//  A mother who reads Area 2 must not come away feeling she read the chapter for
//  the failures.
//
//  ⚠️ NO DOGMA ON SOLIDS. Spoon-feeding and baby-led weaning are presented as
//  two valid routes to the same place, in a comparison table, and neither is
//  written as the enlightened one. Most Indian families will do a mix, and the
//  mix is not a compromise.
//
//  ⚠️ AREA 8 IS THE ONE WITH PHYSICAL STAKES. Choking, honey before one, whole
//  nuts, allergy. That area is deliberately blunt and is never softened for
//  flow. Its callouts are `safety` where the instruction is complete on its own
//  (how to cut a grape needs no doctor) and `doctor` where somebody genuinely
//  has to look at the child.
//
//  ⚠️ IMS ACT / WHO CODE. India's Infant Milk Substitutes Act restricts the
//  advertising and promotion of infant formula, feeding bottles and infant foods
//  marketed as breast-milk substitutes. So this file NEVER links formula or
//  bottles to a commerce surface. They appear only as free, honest, comparative
//  review content, marked REVIEW-ONLY below at every site. Pumps, bowls, high
//  chairs, bibs, storage and steamers are fine and do link to `pp_products`.
//  If a later pass wants to monetise anything in Area 2, that needs legal
//  sign-off first and the marker below is where to start reading.
//
//  ⚠️ LIVE CELLS ARE LINKED, NOT REBUILT. The feeding bracket is almost entirely
//  live: `pp_feeding` is the Feeding Journey log, `pp_food` is the unified
//  Recipes screen, `pp_growth` is the Growth Journey, `pp_what_changed` is the
//  concern library, `pp_products` and `pp_product_guide` are the commerce IA,
//  `pp_courses` is Learning and `pp_read` is Reading. Every one of those is
//  reached with `PpLink(surfaceId:)` and none of them is duplicated here.
//
//  Clinical numbers carry a `// REQUIRED_REVIEW:` comment. They are drawn from
//  ordinary paediatric guidance and a human has to confirm each one before this
//  ships. Nothing here diagnoses anything.
//
//  English only for now, plain `String`, per the standing instruction.
// =============================================================================

// =============================================================================
//  ⚠️ REBUILT 2026-09-12 FROM `ParentVeda_Feeding_rebuild.pdf`, THE V3 DOOR
//  BRIEF. Same treatment as Sleep: the age rule (`autoScope`, `rowMonths`, no
//  "pick his age" anywhere), the format fixes the map marks, six new pieces,
//  one merge. The brief's marks are quoted at each page a reviewer would
//  want to hold against it. The door that shows this is
//  `lib/data/doors/pp_door_feeding.dart`.
//
//  ⚠️ THE "WHAT TO FEED AT THIS AGE" COLLECTION IS MERGED INTO THE TOOL. The
//  brief: three surfaces answered the same question — a landing tool, this
//  collection, and the "is he getting enough?" signs. Now one auto-scoped
//  tool (`pp_food_chart` -> `PpWhatToFeedScreen`) shows his day of food, the
//  regional swaps and the signs. The collection's pages STAY in this file as
//  the tool's data source (`ppChartPagesForBand` reads them), they are just
//  not a rail on the door — `PpDoor.hiddenAreaIds` names it as merged, so a
//  test can tell "merged" from "forgotten".
//
//  ⚠️ CHOKING IS THE SAFETY FIX THE BRIEF CALLS THE MOST IMPORTANT ON THE
//  PARENTING SIDE. Prevention is a labelled "cut it this way" picture, not an
//  article; the response ("If he chokes: what to do") is a new video page
//  pinned as the red flag on the Safe tab; gagging vs choking is a carousel
//  so the panic is stopped before it starts.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_age_bands.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// =============================================================================
//  THE BANDS
// -----------------------------------------------------------------------------
//  ⚠️ FEEDING'S OWN BAND SET, NOT `kPpChildBands`. The shared set opens with a
//  single "0 to 12 months" band, and feeding changes more inside that one year
//  than in the four years after it. A three-month-old is on milk alone; a
//  seven-month-old is on first purees; an eleven-month-old is eating finger food
//  off the family thali. One band describing all three would have to hedge every
//  sentence, and a hedged answer to "what do I feed him today" is no answer.
//
//  The 6 and 8 month boundaries are the real ones: 6 months is when solids start
//  and 8 months is roughly when texture moves past puree. Inclusive lower,
//  exclusive upper, per `PpBand`.
// =============================================================================

const PpBandSet kPpFeedingBands = PpBandSet([
  PpBand(
    id: 'milk',
    label: 'Milk only, 0 to 6 months',
    fromMonths: 0,
    toMonths: 6,
    blurb: 'Breast, formula or both. Nothing else is needed yet.',
  ),
  PpBand(
    id: 'first_foods',
    label: 'First foods, 6 to 8 months',
    fromMonths: 6,
    toMonths: 8,
    blurb: 'Tastes, not meals. Milk still does most of the work.',
  ),
  PpBand(
    id: 'm8_12',
    label: '8 to 12 months',
    fromMonths: 8,
    toMonths: 12,
    blurb: 'Lumps, finger food, and three real meals taking shape.',
  ),
  PpBand(
    id: 'tod',
    label: '1 to 2 years',
    fromMonths: 12,
    toMonths: 24,
    blurb: 'Family food, cow milk, and an appetite that can halve overnight.',
  ),
  PpBand(
    id: 'big',
    label: '2 years and older',
    fromMonths: 24,
    toMonths: 216,
    blurb: 'Opinions, refusals, and eating what the family eats.',
  ),
]);

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpFeedingSection = PpSection(
  id: 'parenting_feeding', // MUST match the hub's bracketId.
  title: 'Feeding',
  intro: 'Milk, first foods, and the week rice becomes the enemy.',
  bandSet: kPpFeedingBands,
  // ⚠️ THE AGE RULE. No chips; every screen opens on his band.
  autoScope: true,
  areas: [
    _breastfeeding,
    _formula,
    _startingSolids,
    _ageCharts,
    _cooking,
    _weightGain,
    _notEating,
    _safety,
  ],
  tools: [
    // ⚠️ NEW SURFACE. Mirrors the pregnancy `can_i` / `CanIStore` pattern:
    // a food plus the child's age gives SAFE / NOT YET / AVOID and one line of
    // reason. Listed in the build report so the router gets an entry.
    PpSectionTool(
      label: 'Can my baby eat this?',
      blurb: "Type a food and get a clear answer for your baby's age. "
          'Honey, cow milk, nuts, salt and the rest.',
      surfaceId: 'pp_baby_food_check',
      icon: Icons.search_outlined,
    ),
    // ⚠️ NEW SURFACE. Reads the chart pages in Area 4 rather than holding a
    // second copy of the numbers. Two copies of a feeding chart is two answers
    // to the same question.
    PpSectionTool(
      label: 'What to feed at this age',
      blurb: "Portions for your baby's age, a day of food, the signs your "
          'baby is getting enough, and swaps from your region.',
      surfaceId: 'pp_food_chart',
      icon: Icons.event_note_outlined,
    ),
    // ⚠️ REUSED, NOT REBUILT. `pp_feeding` is the existing Feeding Journey
    // (feeding_journey_screen.dart + FeedingStore). It is already non-gamified
    // and already reads the child's age. A second feed log would split one
    // baby's feeds across two stores.
    PpSectionTool(
      label: 'Log feeds',
      blurb: 'A light record of feeds, bottles and solids, so you can see a '
          'pattern. No scores, no streaks.',
      surfaceId: 'pp_feeding',
      icon: Icons.edit_note_outlined,
    ),
    PpSectionTool(
      label: 'Recipes for your child',
      blurb: 'Every baby and toddler recipe in the app, sorted by age, '
          'texture and what you have in the kitchen.',
      surfaceId: 'pp_food',
      icon: Icons.restaurant_outlined,
    ),
    PpSectionTool(
      label: 'Track growth',
      blurb: 'Weight and height over time, on a proper chart, so "is my baby '
          'too thin" gets a real answer.',
      surfaceId: 'pp_growth',
      icon: Icons.show_chart_outlined,
    ),
  ],
);

// =============================================================================
//  AREA 1 — Feeding at the breast
// -----------------------------------------------------------------------------
//  Full basics, then one page per problem, as the spec requires. The problem
//  pages are the ones that carry the paid lactation consult, and only those:
//  offering a consult on the "how often to feed" page sells to a mother whose
//  question the page above just answered.
// =============================================================================

final PpArea _breastfeeding = PpArea(
  id: 'breastfeeding',
  mark: IntentMark.feedMark,
  title: 'Feeding at the breast',
  blurb: 'Latch, supply, pumping, and the problems that really come up.',
  hue: 206,
  pages: [
    PpPage(
      id: 'bf_latch',
      title: 'Getting the latch right',
      subtitle: 'Get this right and most of the rest follows',
      // [reformat: was step-list] -> VIDEO. "The key one. A physical skill,
      // shown on a real baby from several angles. Step-list stays as
      // companion." The slot below is hoisted to the top by the renderer.
      format: 'VIDEO',
      bands: ['milk', 'first_foods'],
      blocks: [
        PpIntro('A good latch is what makes feeding comfortable instead of '
            "painful. It's a skill you learn, not an instinct, and most "
            'mothers get it over the first two weeks, not in the first '
            'hour.'),
        PpSteps([
          PpStep('Hold your baby tummy to tummy',
              'Ear, shoulder and hip in one line, the whole body turned '
              "towards you. It's hard to swallow with a twisted neck."),
          PpStep('Nose to nipple, not mouth to nipple',
              "Line your nipple up with your baby's nose, so the head tips "
              'back a little to reach it. That tilt opens the mouth wide.'),
          PpStep('Wait for the wide mouth',
              'Brush your nipple along the upper lip and wait. When the mouth '
              'opens like a yawn, bring your baby on in one movement.'),
          PpStep('Bring baby to breast, never breast to baby',
              'Leaning forward to push your breast in gives a shallow latch, '
              'and a sore back by day three.'),
          PpStep('Chin in first, more areola showing above than below',
              'The chin presses into the breast, the nose stays clear, and '
              'the lips curl outwards instead of tucking in.'),
          PpStep('Listen to the feed',
              'Slow, deep swallows with a soft ka sound. Clicking or smacking '
              'usually means the latch has slipped. Take your baby off gently '
              'and start again.'),
        ], heading: 'A deep latch, step by step'),
        PpCallout('Feeding should feel like a strong tug, not a pinch or a '
            'bite. Sharp pain through the whole feed is a latch problem. You '
            "don't have to get used to it."),
        PpWhenLine('From the very first feed. If it still hurts on day five, '
            'ask someone to watch a whole feed instead of waiting it out.'),
        PpIndiaNote('In a joint family, three people may give you advice in '
            "the middle of one feed. It's fine to say you're still learning "
            'and ask for the room. Learning to feed is easier without an '
            'audience.'),
        PpVideoSlot(
          title: 'A lactation counsellor shows a deep latch',
          subtitle: 'Filmed with a real mother and a two-week-old, from two '
              'angles, with the common mistakes shown alongside.',
          minutes: '7 MIN',
          slotId: 'feeding/latch_demo',
        ),
        PpLink(
          'Log feeds',
          surfaceId: 'pp_feeding',
          blurb: "Sides, times and how long, so you're not counting in your "
              'head at 3am.',
        ),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For a latch that still hurts after a week. Or when you '
              'have tried everything here and want a trained eye on a real '
              'feed, not more reading.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpArticle(heading: 'Flat or inverted nipples', [
          'Many mothers with flat or inverted nipples breastfeed well. Babies '
              'feed from the breast, not only the nipple. A deep latch takes '
              'in a big mouthful of the dark area around it.',
          'Before a feed, roll the nipple gently or use a pump for a minute '
              'to draw it out. Shaping the breast with your fingers like a '
              'sandwich helps your baby take more in. A lactation counsellor '
              'can show you. A nipple shield is sometimes used for a short '
              "time, with the counsellor's guidance.",
        ]),
      ],
    ),
    PpPage(
      id: 'bf_positions',
      title: 'Feeding positions that work',
      // [reformat: was cards] -> VIDEO. "Cradle, cross-cradle, rugby hold,
      // lying down: spatial, show them." The cards stay as the companion.
      format: 'VIDEO',
      bands: ['milk', 'first_foods'],
      blocks: [
        PpVideoSlot(
          title: 'Five positions, shown with a real mother',
          subtitle: 'Cradle, cross cradle, rugby hold, side lying and laid '
              'back, each set up from the start, with where the pillows go.',
          minutes: '8 MIN',
          slotId: 'feeding/positions_demo',
          hue: 206,
        ),
        PpIntro("There's no correct position, only the one that gives a deep "
            'latch and spares your shoulders. Most mothers use two or three, '
            'depending on the time of day.'),
        PpCards([
          PpCard('Cradle hold',
              "The classic. Your baby's head rests in the crook of your arm, "
              'on the same side as the breast. Easy once feeding settles, '
              'harder in the first fortnight, when you have less head control.'),
          PpCard('Cross cradle',
              "The opposite arm holds your baby, your hand at the base of the "
              'neck. Best for learning, because you can guide the head onto '
              'the breast instead of hoping.'),
          PpCard('Rugby or football hold',
              'Your baby tucks under your arm along your side, feet behind '
              'you. Very good after a caesarean, as nothing rests on the scar, '
              'and good for twins.'),
          PpCard('Side lying',
              'Both of you on your sides, facing each other. This one saves '
              'the night feeds. Keep pillows and quilts away from the face, '
              'and read the safe-sleep page before you drift off.'),
          PpCard('Laid back or biological nurturing',
              "You lean back, your baby lies on your chest, and gravity does "
              'the holding. It often fixes a shallow latch on its own, with '
              'nobody correcting anything.'),
        ], heading: 'Five that cover almost everything', hue: 206),
        PpCallout('Support the baby, not the breast. If you hold your breast '
            "in place for the whole feed, the latch isn't deep enough yet to "
            'stay on without help.'),
        PpWhenLine('Try a new position whenever a feed is going badly, and any '
            'time one part of the breast stays full.'),
        PpIndiaNote('A firm cushion or a rolled-up quilt across your lap does '
            "the job of a nursing pillow. Bring your baby's mouth level with "
            "the nipple before you start, so you're not hunching down."),
        PpLink(
          'Nursing pillows and feeding chairs',
          surfaceId: 'pp_products',
          blurb: "What's worth buying, and what a cushion already does.",
        ),
      ],
    ),
    PpPage(
      id: 'bf_how_often',
      title: 'How often, and how much',
      format: 'ARTICLE',
      blocks: [
        PpIntro("Most worries here come from not seeing how much went in. A "
            "bottle has markings. A breast doesn't, so you read your baby "
            'instead.'),
        PpArticle([
          'Newborns feed on demand. In practice that means eight to twelve '
              'times in twenty four hours, sometimes more. Feeds are not evenly '
              'spaced. A run of close feeds in the evening is normal, and it '
              "doesn't mean your milk has run out.",
          'Feed when your baby asks. Early hunger signs are rooting, turning '
              'the head, sucking hands and getting restless. Crying is a late '
              'sign, and a crying baby latches less well. Catching it earlier '
              'makes the feed easier for you both.',
          "Length doesn't tell you much. Some babies finish in eight minutes "
              'and some take forty, and both can be feeding perfectly well. '
              'Let your baby finish one side properly before offering the '
              'second. The milk at the end of a side is the richest part.',
          'The other end tells you your baby is getting enough. Steady wet '
              'nappies, weight coming back after the normal first-week dip, '
              'and a baby who lets go looking drowsy and content, not '
              'frantic.',
        ]),
        // REQUIRED_REVIEW: nappy counts and the day-5 threshold. Standard
        // paediatric guidance, but confirm the exact figures and wording with a
        // paediatrician before ship.
        PpChartCard(
          title: 'Is my baby getting enough?',
          subtitle: 'The signs you can see',
          rows: [
            ('Feeds in 24 hours', '8 to 12 in the early weeks'),
            ('Wet nappies from day 5', '6 or more, pale and odourless'),
            ('Dirty nappies from day 5', '3 or more, soft and yellow'),
            ('Weight', 'Back to birth weight by about 2 weeks'),
            ('After a feed', 'Relaxed hands, sleepy, lets go without help'),
          ],
          note: 'Weight and nappies together give the honest answer. How full '
              "your breast feels doesn't, and it stops being a sign at all "
              'once supply settles around 6 weeks.',
        ),
        PpCallout("You can't overfeed a breastfed baby. Babies stop when "
            "they're done. Wanting the breast an hour after a feed usually "
            'means thirsty, hot or wanting you, not starving.'),
        PpWhenLine('On demand for the first 6 months. Feeds space themselves '
            'out with time, usually somewhere between 6 and 12 weeks.'),
        PpIndiaNote("You'll be told to give herbal drops (ghutti), gripe water, honey or "
            "plain water in the first weeks. None of it is needed, and honey "
            "isn't safe before one year. Breast milk or formula is the whole "
            'diet until 6 months, water included.'),
        PpCallout(
          "See your paediatrician if your baby isn't back to birth weight by "
          'two weeks. Go too for fewer wet nappies than the chart, a baby too '
          'sleepy to finish feeds, or a dry mouth and sunken soft spot. Slow '
          "weight gain is treatable, and it's easiest to treat early.",
          kind: PpCalloutKind.doctor,
          title: 'When feeding needs a doctor, not more patience',
        ),
        PpLink(
          'Log feeds',
          surfaceId: 'pp_feeding',
          blurb: 'A few days of notes makes the pattern clear.',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCallout('In the first weeks, jot down feeds and wet and dirty nappies '
            'in a notebook or the feeding tracker. Tired days blur together, '
            'and the record answers the doctor\'s first question for you.'),
      ],
    ),
    PpPage(
      id: 'bf_supply',
      title: 'Making enough milk, and keeping it',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Milk supply runs on one rule: milk removed is milk made. '
            'Almost every real fix comes back to that, and almost every '
            "product sold for supply doesn't."),
        PpArticle([
          'Your body decides how much to make from how much leaves. Feed '
              'often and drain the breast well, and it makes more. Skip feeds, '
              'top up a lot with formula without pumping, or let a shallow '
              'latch cut feeds short, and it slowly makes less.',
          'The first two weeks set the baseline. So frequent feeding early '
              'matters more than anything you eat or drink. After about six '
              'weeks supply settles and breasts stop feeling engorged. Many '
              'mothers read that softness as losing their milk. It means '
              'supply now matches demand.',
          'Growth spurts look like supply failing, but they are not. Your baby '
              'feeds constantly for two or three days, never seems satisfied, '
              'and then settles, with more milk there than before. That is '
              'your body keeping up.',
          'What helps: feeding or pumping more often, fixing the latch, '
              'letting the first side run until your baby lets go, skin to '
              'skin, and sleeping when you can. What mostly does not: costly '
              'supplements, and worrying.',
        ]),
        PpCallout('To build supply, add a feed or a pump session, not a '
            'supplement. Nothing raises supply like removing more milk.'),
        PpCallout(
          "Soft breasts aren't empty breasts. Around six weeks your body stops "
          'making extra and starts making what your baby takes, so the '
          'engorged feeling goes. Almost every mother reads that as losing '
          'milk, and it means the opposite.',
          kind: PpCalloutKind.myth,
          title: 'My breasts feel empty, so my milk has gone',
        ),
        PpWhenLine('Supply responds best in the first 6 weeks and can still '
            "change after that. It's rarely too late to build it back up."),
        PpIndiaNote('Traditional milk boosters like fenugreek, shatavari, carom seeds, '
            'garlic and edible gum laddoos are widely used and generally safe in '
            'food amounts. Enjoy them if the family makes them for you with '
            'love. They work best alongside more feeding, not instead of it. '
            'Ask your doctor before taking anything in tablet form.'),
        PpLink(
          "It feels like I'm not making enough",
          pageId: 'bf_low_supply',
          blurb: 'The full page, including how to tell real low supply from '
              'the much more common false alarm.',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpSteps(heading: 'Expressing by hand', [
          PpStep('Wash your hands and sit comfortably',
              'A warm cloth on the breast and a gentle massage help the milk '
                  'flow.'),
          PpStep('Make a C with your thumb and fingers',
              'About two or three centimetres back from the nipple.'),
          PpStep('Press back towards your chest, then squeeze gently',
              'Release and repeat in a rhythm. Move your fingers around the '
                  'breast.'),
          PpStep('Collect in a clean, wide cup',
              'Colostrum comes in drops at first. A spoon or syringe can catch '
                  'it.'),
        ]),
        PpWhenLine('For colostrum in the first days, hand expression often '
            'works better than a pump. It is free and always with you.'),
      ],
    ),
    PpPage(
      id: 'bf_diet',
      title: "What you eat while you're breastfeeding",
      format: 'CARDS',
      blocks: [
        PpIntro('The list of foods a nursing mother must avoid is much shorter '
            "than the one your family will give you. Here's the honest "
            'version.'),
        PpCards([
          PpCard('Alcohol',
              'Passes into milk. If you drink, feed first, then wait about two '
              "hours per drink before the next feed. You don't need to pump "
              'and throw milk away. Time does the work.'),
          PpCard('Caffeine',
              'Fine in ordinary amounts, roughly two to three cups of tea or '
              'coffee a day. Very young babies clear it slowly, so if yours is '
              'unusually wakeful, cut back and see.'),
          PpCard('Large predatory fish',
              'Shark, swordfish and king mackerel carry more mercury. Everyday '
              'Indian fish like rohu, pomfret and small mackerel are fine and '
              'good for you both.'),
          PpCard('Anything your baby clearly reacts to',
              'A few babies react to dairy or soy in your diet, with blood in '
              "the stool, bad reflux or a rash. It's uncommon, and it needs a "
              'doctor, not a guessing game of cutting foods one by one.'),
          PpCard('Your own medicines',
              'Most common medicines are fine with feeding, including '
              'paracetamol and most antibiotics. Check with your doctor or '
              'chemist instead of stopping feeds on your own.'),
        ], heading: 'The real cautions', hue: 206),
        PpCards([
          PpCard('Cold foods, curd and rice',
              "Curd, rice, cold water and bananas don't give your baby a cold. "
              "Nothing you eat lowers your baby's immunity through milk."),
          PpCard('Spice, garlic and masala',
              "Flavours do reach the milk, and that's a good thing. Babies who "
              'taste family flavours early tend to accept them more easily at '
              'six months.'),
          PpCard('Gassy vegetables',
              "Rajma, gobi and chana don't pass gas into milk. Gas isn't a "
              "nutrient, and it doesn't travel that way."),
          PpCard('A restricted diet',
              'Cutting out food groups on a hunch usually leaves you '
              'underfed and exhausted, the last thing supply needs. Eat '
              'properly and eat enough.'),
        ], heading: 'What you can safely ignore', hue: 206),
        PpCallout('You need roughly an extra meal a day and a lot of water. '
            'Keep a filled bottle where you feed. Thirst arrives the moment '
            'your baby latches, and nobody will think to fetch it.'),
        PpWhenLine('For as long as you breastfeed, at any age.'),
        PpIndiaNote('Fasting during Navratri, Karva Chauth or Ramzan while '
            'nursing is your choice, and many mothers do it. If you fast, keep '
            'fluids up in the permitted hours and eat well at both ends. '
            'Dizziness or a sharp drop in milk is a reason to stop that day. '
            'Most religious traditions already excuse a nursing mother.'),
      ],
    ),
    PpPage(
      id: 'bf_pumping',
      title: 'Pumping when you go back to work',
      format: 'ARTICLE',
      blocks: [
        PpIntro("Going back to work doesn't have to end breastfeeding. It "
            'does take a plan, a pump, and somewhere decent to sit for fifteen '
            'minutes twice a day.'),
        PpArticle([
          'Start about two to three weeks before you go back, not the night '
              'before. Pump once a day after a morning feed, when supply is '
              'highest, and freeze what you get. A small stash calms the first '
              'week, and lets whoever minds your baby practise with a bottle '
              "while you're still around.",
          'At work, aim to pump about as often as your baby would have fed. '
              'For most mothers that is two or three times across the day. '
              'Missing sessions often is what drops supply, so keeping the '
              'sessions matters more than how much comes out of any one of them.',
          "Hand expression is a real skill and worth learning. It needs no "
              'power, no privacy and no equipment. Many mothers get more by '
              'hand than with a pump, and using both gets the most.',
          'Feed your baby directly whenever you are together: mornings, '
              'evenings and weekends. Direct feeds keep supply up better than '
              'any pump. They help many mothers keep going for a year on two '
              'pumping sessions a day.',
        ]),
        // REQUIRED_REVIEW: expressed milk storage times. These are the commonly
        // cited figures; confirm against current national guidance, including
        // whether they should be shortened for warm-climate room temperature.
        PpChartCard(
          title: 'How long expressed milk keeps',
          subtitle: 'Fresh milk, in a clean sealed container',
          rows: [
            ('Room temperature, cool room', 'Up to 4 hours'),
            ('Room temperature, hot day', 'Up to 2 hours, then refrigerate'),
            ('Fridge, back shelf not the door', 'Up to 4 days'),
            ('Freezer compartment of a fridge', 'About 2 weeks'),
            ('Deep freezer', 'Up to 6 months'),
            ('Thawed in the fridge', '24 hours, and never refrozen'),
          ],
          note: 'Warm it by standing the bottle in hot water. Never use a '
              'microwave. It heats unevenly and can scald a mouth even when '
              'the bottle feels fine on your wrist.',
        ),
        PpCallout('Label every bag or bottle with the date before it goes in '
            'the freezer, and use the oldest first. Ten minutes of labelling '
            'saves a month of guessing.'),
        PpWhenLine('Start building a stash 2 to 3 weeks before you return. '
            'Try the bottle around 4 to 6 weeks if you can, once feeding at '
            'the breast is comfortable.'),
        PpIndiaNote('Indian offices rarely have a feeding room. Most mothers '
            'end up using a locked cabin, a first-aid room or the accessible '
            'washroom lobby. Under the Maternity Benefit Act you are entitled '
            'to nursing breaks, and workplaces above a certain size must '
            'provide a creche. Ask HR in writing before your first day back.'),
        PpVideoSlot(
          title: 'Hand expression and pumping, shown clearly',
          subtitle: 'How to hold the flange, how to hand express, and how to '
              'use both for more milk in less time.',
          minutes: '9 MIN',
          slotId: 'feeding/pumping_demo',
        ),
        PpLink(
          'Pumps, storage bags and nursing bras',
          surfaceId: 'pp_products',
          blurb: 'Manual or electric, flange size, and what you can skip.',
        ),
        PpLink(
          'Compare breast pumps',
          surfaceId: 'pp_product_guide',
          blurb: 'What matters, what to ignore, and the mistake most people '
              'make when choosing one.',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpSteps(heading: 'How to pump', [
          PpStep('Start once breastfeeding is settled',
              'Usually after three or four weeks, unless you need to pump '
                  'sooner.'),
          PpStep('Pump at the times your baby would feed',
              'At work, about every three hours, for 15 to 20 minutes.'),
          PpStep('Use the right flange size',
              'The nipple should move freely, not rub. Pain means the wrong '
                  'size or too high a setting.'),
          PpStep('With a manual pump',
              'Short quick pumps to start the flow, then slower, longer ones. '
                  'Switch sides when the flow slows.'),
          PpStep("Look at your baby's photo, or smell a worn vest",
              'It helps the milk let down.'),
        ]),
        PpSteps(heading: 'Cleaning the pump', [
          PpStep('Take apart every piece that touches milk', 'After each use.'),
          PpStep('Rinse in cool water, then wash in hot soapy water',
              'With a brush kept only for pump parts.'),
          PpStep('Air dry on a clean towel', 'Not wiped with a kitchen cloth.'),
          PpStep('Sterilise once a day', 'By boiling for five minutes or '
              'steaming, especially for a young or premature baby.'),
          PpStep('Throw away mouldy tubing', 'And check the parts for dark '
              'spots.'),
        ]),
      ],
    ),
    PpPage(
      id: 'bf_low_supply',
      title: "It feels like I'm not making enough",
      format: 'ARTICLE', // [reuse] "links to the feed tracker"
      blocks: [
        PpIntro('This is the most common reason mothers stop feeding. Most of '
            'the time supply is fine and something else is going on. Both of '
            "those matter, so here's how to tell."),
        PpArticle([
          'Mothers often read these as low supply: soft breasts, frequent or '
              'short feeds, evening crying, and very little milk from a pump. '
              'None of them proves anything. Breasts soften when supply '
              'settles. Pumps remove milk far less well than a baby. Evening '
              'fussiness happens on full supply too.',
          'Weight and nappies are the real evidence. If your baby is gaining '
              "steadily and has plenty of pale wet nappies, you're making "
              'enough, whatever it feels like. If weight gain has stalled, or '
              'nappies have dropped off, that is real and needs looking at, '
              'not pushing through.',
          'When supply really is low, the usual causes can be fixed. A '
              'shallow latch that removes little milk. Feeds limited by the '
              'clock. Heavy formula top ups without pumping. A tongue tie, '
              'heavy blood loss at delivery, retained placenta or a thyroid '
              'problem. That list is for a doctor and a lactation consultant, '
              'not a supplement shelf.',
          'Rebuilding is plain work, and it works. Feed more often and get the '
              'latch checked. Let the first side run until your baby lets go. '
              'Add a pump after a couple of feeds. Spend a day or two skin to '
              'skin, with very little clothing between you. Supply usually '
              'responds within a week.',
        ]),
        PpCallout("If you're topping up with formula, keep pumping alongside. "
            'Milk left in the breast tells your body to make less, and that is '
            'how a short-term top up can slowly become a permanent one.'),
        PpWhenLine('Act within a week of noticing, not after a month. '
            'Supply is much easier to rebuild early.'),
        PpIndiaNote('Hearing from a relative on day three that you have no '
            'milk happens to almost everyone. On day three the milk has not '
            "properly come in yet. It isn't a verdict."),
        PpCallout(
          'See your paediatrician if your baby is losing weight or not '
          'gaining, or if wet nappies drop below six a day after the first '
          'week. Go too if your baby is listless and hard to wake. Ask your own '
          'doctor about thyroid and anaemia if supply never came in at all.',
          kind: PpCalloutKind.doctor,
          title: 'When low supply needs medical help',
        ),
        PpLink(
          'Log feeds for three days',
          surfaceId: 'pp_feeding',
          blurb: 'Times and sides written down beat a feeling of empty.',
        ),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: "If you've been told you have low supply and want someone to "
              'check if it is true. They watch a real feed and build a plan '
              "that doesn't start with giving up.",
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpArticle(heading: 'Triple feeding, and knowing your limits', [
          "When a baby isn't gaining well, a doctor or lactation consultant "
              'may suggest triple feeding for a short time. You breastfeed, then '
              'top up with expressed milk or formula, then pump to build '
              "supply. It can work, but it's exhausting. It's meant to last "
              'days or a couple of weeks, not months.',
          'Ask for a clear plan and an end date. Let someone else give the top '
              "up while you pump. If it's wearing you down, say so. Your rest "
              'and mood matter to your baby too.',
        ]),
        PpCards(heading: 'Other reasons supply can drop', [
          PpCard('Tongue tie', 'Can stop your baby draining the breast well. '
              'A doctor can check.'),
          PpCard('Long gaps or a dummy replacing feeds',
              'Milk is made by demand.'),
          PpCard('Some contraceptive pills', 'Ask for a breastfeeding-friendly '
              'one.'),
          PpCard('Stress, illness or not eating', 'Look after yourself first.'),
        ]),
      ],
    ),
    PpPage(
      id: 'bf_oversupply',
      title: 'Too much milk, and a baby who splutters',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Too much milk gets little sympathy, and it can be miserable. '
            'Your baby chokes, pulls off and cries at the breast, and you leak '
            'through everything you own.'),
        PpArticle([
          'The signs are fairly clear. Your baby latches, gulps, splutters and '
              'comes off crying within a minute. There may be wind, arching '
              'away, and green frothy stools. Your breasts refill fast and stay '
              'hard, and milk sprays across the room when the latch breaks.',
          'Two things are going on: a forceful letdown and more milk than your '
              'baby needs. Babies fill up on the watery milk at the start of a '
              'side and never reach the creamier milk at the end. That is why '
              'stools go green, and why hunger comes back quickly.',
          'The fix feels backwards: take less milk out, not more. Feed from '
              'one side per feed, or per two-hour block. That side drains well, '
              'and the other side gets the message to slow down. Express only '
              'enough from the unused side for comfort, not until it is empty.',
          'Lean back while feeding so your baby is above the flow, not under '
              'it. Let the first strong letdown spray into a cloth before you '
              'latch. Most oversupply settles within a few weeks of one-side '
              'feeding.',
        ]),
        PpCallout("Don't pump to relieve the pressure unless you're really "
            'uncomfortable. Every extra pump tells your body to keep making '
            "the amount you're struggling with."),
        PpWhenLine('Most common in the first 6 to 12 weeks, and usually '
            'settled by 3 months.'),
        PpIndiaNote('Nursing pads and a spare kurta at work cover the practical '
            'side. Cotton pads washed and dried in the sun work as well as '
            'disposables and cost nothing.'),
        PpCallout(
          'See a doctor if the breast becomes hot, red and painful, with fever '
          'and body aches. Repeated blocked ducts from oversupply can turn into '
          'mastitis, and that needs treatment, not waiting.',
          kind: PpCalloutKind.doctor,
          title: 'When oversupply turns into something else',
        ),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For a forceful letdown that turns every feed into a fight. '
              "Useful when one-side feeding hasn't settled it in a fortnight and you "
              'want a plan built around your baby.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
      ],
    ),
    PpPage(
      id: 'bf_mastitis',
      title: 'A hot, painful lump in the breast',
      subtitle: 'Blocked ducts and mastitis',
      // [reuse] "Add a same-day red-flag: mastitis with fever needs a doctor
      // today." The doctor callout below is that flag, and the door pins
      // this page as the Milk tab's red flag so it sits above the rails.
      format: 'ARTICLE',
      blocks: [
        PpIntro('A blocked duct is a sore lump. Mastitis is that lump plus '
            "fever, and feeling like you've been hit by a truck. The second "
            "one moves fast, so it's worth reading this before you need it."),
        PpArticle([
          'A blocked duct is a tender, firm patch in one breast, usually with '
              "no fever and no red streak. It happens when milk isn't moving "
              'out of one part of the breast. Common triggers are a long gap, a '
              'tight bra, sleeping on that side, or a shallow latch.',
          'Mastitis is inflammation of the breast tissue, with or without '
              'infection. The breast goes red, hot and painful in a wedge '
              'shape, with fever, chills and flu-like aches. It can go from '
              'mildly annoying to properly ill within hours.',
          "For both, keep the milk moving. Feed from that side often, with "
              "your baby's chin pointing towards the lump. Massage gently "
              'towards the nipple, not the deep digging people suggest. Hard '
              'massage makes inflammation worse. Cold packs between feeds ease '
              'swelling, and brief warmth just before a feed helps letdown.',
          'Rest, fluids and paracetamol or ibuprofen are part of the '
              'treatment, not an optional extra. Both are fine with feeding. '
              'Keep feeding throughout, including from the sore side. The milk '
              'is safe for your baby, and stopping makes everything worse.',
        ]),
        PpCallout("Don't stop feeding from the painful side. Emptying that "
            'breast is the treatment. Letting it stay full is what turns a '
            'blocked duct into mastitis.'),
        PpWhenLine("Can happen any time you're breastfeeding, most often in "
            'the first 3 months and again during weaning.'),
        PpIndiaNote('Tight bras, dupattas knotted across the chest and a heavy '
            'loose end of a saree can all press on the same spot for hours. If a block '
            'keeps coming back in one place, look at what presses there, not '
            'at your milk.'),
        PpCallout(
          'Call your doctor the same day if you have fever above 38.5C or red '
          'streaks spreading across the breast. Call the same day too if it '
          'has not improved after 24 hours of feeding and rest. Mastitis often needs '
          'antibiotics, and an untreated abscess needs a hospital. Go sooner '
          'rather than later.',
          kind: PpCalloutKind.doctor,
          title: 'When to call the same day',
        ),
        // REQUIRED_REVIEW: the 38.5C threshold and the 24-hour window. Confirm
        // both with a clinician, and confirm the current guidance on massage,
        // which changed recently away from deep massage.
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For repeated blocked ducts or a second bout of mastitis, '
              'when you want someone to find the cause, not treat the same '
              'lump again.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
        // The You brief consolidates breast health (engorgement, cracked
        // nipples, blocked duct, mastitis) into "Sore, rock hard breasts"
        // there; this red flag stays here and links in.
        PpLink('Sore, rock hard breasts: the whole picture',
            surfaceId: 'pp_page/parenting_maternal/body_breasts',
            blurb: 'Engorgement, cracked nipples, a blocked duct and mastitis, '
                'in your own section.'),
      ],
    ),
    PpPage(
      id: 'bf_cracked',
      title: 'Sore and cracked nipples',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Nipple pain is the most common reason feeding stops '
            "in the first month. It's also almost always a fixable problem "
            "with the latch, not something you have to put up with."),
        PpArticle([
          'Some tenderness in the first few days is normal. Pain through the '
              'whole feed, cracks, bleeding, or nipples that come out flat, '
              'creased or lipstick shaped are not. They mean the latch is '
              'shallow, and the nipple is being pressed against the hard '
              'palate instead of drawn deep.',
          "Fix the latch first. Nothing else works while the cause is still "
              "there. Aim for a wider mouth, a deeper chin, and more areola "
              'in from below than above. If it hurts once your baby is on, '
              'break the seal with a clean finger and start again. You '
              "don't have to sit through it.",
          'To heal, express a few drops of your own milk and let them dry on '
              'the nipple. Then use purified lanolin or a plain paraffin '
              "ointment that doesn't need washing off. Keep the area dry "
              'between feeds, and change nursing pads as soon as they are damp.',
          'Sometimes the pain is burning and deep, and goes on after the feed. '
              "With shiny pink nipples or white patches in your baby's mouth, "
              'thrush is the likely cause, and you both need treating at once. '
              'A tongue tie is the other common cause when the latch looks '
              'right and still hurts.',
        ]),
        PpCallout("You can keep feeding on a cracked nipple. If it's too "
            'painful, express from that side for a day or two to protect '
            'supply while it heals. Keep the milk moving either way.'),
        PpWhenLine('Most common in the first 2 weeks. If the pain is still '
            'there at day 7, ask someone to watch a feed.'),
        PpIndiaNote('Coconut oil or ghee is common family advice. It does no '
            "harm, but it won't heal a crack caused by the latch. Wipe "
            'anything oily off before a feed, and fix the latch either way.'),
        PpCallout(
          'See a doctor or a lactation consultant if the crack is deep or '
          'bleeding heavily, or if there is pus or spreading redness. Go too if '
          'the pain is burning and continues between feeds. Thrush and tongue '
          'tie both need diagnosing, not guessing.',
          kind: PpCalloutKind.doctor,
          title: 'When sore nipples need someone to look',
        ),
        PpLink(
          'Nipple cream and nursing pads',
          surfaceId: 'pp_products',
          blurb: 'Purified lanolin, plain ointments, and what the difference '
              'really is.',
        ),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For nipple pain that has lasted more than a week, or a '
              'latch that looks perfect and still hurts. That usually means '
              "something a video can't see.",
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCards(heading: 'Three other causes of nipple pain', [
          PpCard('Thrush',
              'Shiny, itchy or burning nipples and deep shooting pain, often '
                  "with white patches in your baby's mouth. You both need "
                  'treatment from the doctor.'),
          PpCard('Nipple blanching',
              'The nipple turns white, then blue or red, with a burning or '
                  'throbbing pain after feeds, often in the cold. Warmth '
                  'straight after feeds helps. A better latch fixes most of it.'),
          PpCard('A milk blister',
              'A small white dot on the nipple that hurts during feeds. Warm '
                  'compresses before feeds and feeding often usually clear it. '
                  "Don't pick it with a needle. Ask your doctor."),
        ]),
      ],
    ),
    PpPage(
      id: 'bf_biting',
      title: 'My baby has started biting',
      format: 'ARTICLE',
      bands: ['m8_12', 'tod', 'big'],
      blocks: [
        PpIntro('The first bite is a shock and usually makes you yelp, which '
            "many babies find very funny. It's a phase, it has causes, and it "
            "doesn't have to end feeding."),
        PpArticle([
          "Babies can't bite while sucking well, because the tongue covers the "
              'lower gums. Bites come at the very start of a feed, before a '
              'proper latch, or at the end, when your baby is bored and still '
              'on the breast. Those are the moments to watch.',
          'The usual reasons are teething, a blocked nose that makes feeding '
              'awkward, distraction, or trying out new teeth. Some babies bite '
              'when the milk flow slows and they want more.',
          'What works: stay calm and say a flat, quiet no. Break the suction '
              'and take your baby off for a minute, then offer again. A short '
              'pause in the feed is the clearest message at this age. A big '
              'reaction can either frighten your baby off the breast or turn '
              'it into a game.',
          'Prevent instead of punishing. Watch for the moment attention '
              'wanders at the end of a feed, and take your baby off first. '
              'Offer something cold to chew before the feed when teeth are '
              'coming. If every sound turns your baby\'s head, feed somewhere '
              'quiet.',
        ]),
        PpCallout("Don't flick the cheek, tap or shout. All three teach your "
            'baby that the breast is where unpleasant things happen, and a '
            'nursing strike is much harder to fix than a bite.'),
        PpWhenLine('Usually starts around 6 to 9 months with the first teeth, '
            'and mostly passes within a few weeks.'),
        PpIndiaNote("You'll hear that teeth mean it's time to stop feeding. "
            "They don't. Feeding to a year and well beyond is normal and "
            'recommended, teeth and all.'),
      ],
    ),
    PpPage(
      id: 'bf_refusing',
      title: 'My baby is refusing the breast',
      format: 'ARTICLE',
      blocks: [
        PpIntro('A baby who suddenly refuses to feed is frightening. It is '
            'almost never about you. Something has made feeding uncomfortable, '
            'and you can usually find out what.'),
        PpArticle([
          'A nursing strike is a sudden refusal in a baby who was feeding well. '
              'Common causes are a blocked nose, an ear infection, or a sore '
              'mouth from teething or thrush. Others are a new soap or '
              'deodorant changing how you smell, a startled reaction to a bite, '
              'or a stressful few days.',
          'Newborn refusal is different and more urgent. A baby in the first '
              "weeks who won't latch at all, or is too sleepy to feed, needs "
              'checking, not coaxing.',
          'While you work it out, keep the milk moving and keep your baby fed. '
              'Express at least as often as your baby would have fed. Give that '
              'milk by spoon, small bowl or cup, not straight away by bottle, which '
              'can make coming back to the breast harder.',
          'To coax your baby back, try skin to skin with no pressure. Offer '
              'when sleepy or just waking. Feed in a dark quiet room, or while '
              'walking or rocking, and share a warm bath. Most '
              'strikes end within two to five days.',
        ]),
        PpCallout("Offer, don't force. Pushing a baby who is arching away "
            'onto the breast builds a link you then have to undo. Stop, '
            'cuddle, and try again in twenty minutes.'),
        PpWhenLine('Can happen at any age. A strike usually settles in 2 to 5 '
            'days. Real self-weaning before 12 months is rare.'),
        PpIndiaNote('If the refusal started after bottle feeds at the creche or '
            "from a relative, it's about flow, not rejection. Ask for paced "
            'bottle feeding, held upright with a slow teat, so the bottle '
            'stops being the easier option.'),
        PpCallout(
          'See your paediatrician the same day if a newborn will not feed at '
          'all. Go the same day too if your baby is pulling at one ear, has a '
          'fever, has fewer wet nappies, or seems floppy and hard to rouse. '
          'Refusal plus any of those is a sign of illness, not a phase.',
          kind: PpCalloutKind.doctor,
          title: 'When refusing to feed means your baby is unwell',
        ),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For a strike that has lasted more than a few days, or a '
              'newborn who has never latched properly, when you want help '
              'today, not another article.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
      ],
    ),
    // Added 2026-10-02 from the parenting gap analysis (P2/P3).
    PpPage(
      id: 'bf_benefits',
      title: 'Why breastfeeding helps, for both of you',
      subtitle: 'Without the guilt',
      bands: ['milk', 'first_foods', 'm8_12'],
      format: 'CARDS',
      blocks: [
        PpIntro('Breastfeeding has real benefits for babies and mothers, and '
            "every feed counts, whether it's one a day or all of them. If it "
            "doesn't work out for you, your baby will still thrive. Fed and "
            'loved is what matters.'),
        PpCards(heading: 'For your baby', [
          PpCard('Protection from infection',
              'Fewer tummy upsets, chest infections and ear infections.'),
          PpCard('Made for your baby', 'Changes with age, and even within a feed.'),
          PpCard('Lower risk of some illnesses later',
              'Including asthma and obesity in some studies.'),
        ]),
        PpCards(heading: 'For you', [
          PpCard('Helps the womb shrink back', 'In the first days.'),
          PpCard('Lower risk of breast and ovarian cancer', 'The longer you '
              'feed, overall.'),
          PpCard('Easy and free', 'Always ready, at the right temperature.'),
        ]),
      ],
    ),
    PpPage(
      id: 'bf_lactation_help',
      title: 'Getting breastfeeding help: counsellors and groups',
      subtitle: 'Who can help, and when to ask',
      format: 'STEPS',
      blocks: [
        PpIntro("Breastfeeding is natural, but it's also a skill you both "
            'learn. Almost every mother gains from help in the first weeks, '
            'and asking early prevents most problems.'),
        PpSteps(heading: 'Who can help', [
          PpStep('A lactation consultant or counsellor',
              'Trained to help with latch, positions, pain, low supply and '
                  'pumping. Many hospitals have one. Ask before you go home.'),
          PpStep('Your paediatrician and gynaecologist',
              'For weight gain, tongue tie, infections and medicines.'),
          PpStep('Support groups',
              'Mothers meeting with a trained leader, in person or online. '
                  'Ask your hospital, or look for groups linked to the '
                  'Breastfeeding Promotion Network of India.'),
        ]),
        PpCallout('Call a lactation consultant if feeds hurt beyond the first '
            'latch, or your baby is not gaining weight or has few wet nappies. '
            'Call too for cracked or bleeding nipples, or if you feel unsure '
            'and worried.',
            kind: PpCalloutKind.doctor),
        PpLink('Book a lactation consultation',
            surfaceId: 'pp_experts/Lactation expert'),
      ],
    ),
    PpPage(
      id: 'bf_toddler',
      title: 'Breastfeeding a toddler',
      subtitle: "Still good for your child, and stopping when you're ready",
      bands: ['tod', 'big'],
      format: 'ARTICLE',
      blocks: [
        PpIntro('Breastfeeding past one is normal and recommended. The WHO '
            'suggests continuing to two years and beyond, alongside family '
            "food. There's no age at which your milk stops being good for "
            'your child.'),
        PpArticle([
          'After one, food becomes the main nutrition, and breast milk is a '
              'drink, a comfort and protection. Offer meals first and feed '
              'after, or between meals. Many toddlers feed on waking, at '
              'naps and at bedtime.',
          'You decide what suits you. Some mothers set limits, like feeding '
              'only at home or only at night. Others carry on until the child '
              'stops alone. Both are fine.',
        ]),
        PpSteps(heading: 'If you want to stop', [
          PpStep('Drop one feed at a time, every few days'),
          PpStep("Don't offer, don't refuse", 'A gentle way to wind down.'),
          PpStep('Replace the feed with closeness',
              'A story, a cuddle, a cup of milk at bedtime.'),
          PpStep('Go slowly to avoid sore, full breasts'),
        ]),
      ],
    ),
    PpPage(
      id: 'bf_relactation',
      title: 'Restarting breastfeeding, or bringing in milk for an adopted baby',
      subtitle: 'Relactation and induced lactation',
      format: 'ARTICLE',
      blocks: [
        PpIntro("If you stopped breastfeeding and wish you hadn't, or you're "
            "adopting a baby, it's often possible to bring milk in. It takes "
            'patience and support, and any amount of milk is worth it.'),
        PpArticle([
          'Relactation works best when the baby is young and you stopped '
              'recently, but it can work later too. What matters is frequent '
              'stimulation: putting the baby to the breast often, and '
              'pumping or hand expressing eight or more times a day.',
          'A supplementer is a thin tube taped to the breast that carries '
              'formula or donor milk. Your baby gets milk while suckling, '
              'which keeps the feed at the breast and builds your supply.',
          'For an adopted baby, induced lactation follows the same idea. '
              'It is sometimes started weeks before the baby arrives, and '
              'sometimes with medicine prescribed by a doctor.',
        ]),
        PpCallout('Work with a lactation consultant and your doctor. They can '
            'make a plan and decide if any medicine is right for you. '
            "Don't take supplements or galactagogues without advice.",
            kind: PpCalloutKind.doctor),
      ],
    ),
    PpPage(
      id: 'bf_exclusive_pumping',
      title: 'Exclusive pumping',
      subtitle: 'Breast milk, by bottle',
      bands: ['milk', 'first_foods', 'm8_12'],
      format: 'STEPS',
      blocks: [
        PpIntro('Some mothers feed only pumped milk, because of a premature '
            'birth, latch problems, or because it works for them. It is a '
            "real commitment, and it's breastfeeding too."),
        PpSteps([
          PpStep('Pump eight to ten times a day at first',
              'Including once at night, to build supply in the first weeks.'),
          PpStep('Aim for about 750 to 900 ml a day by six weeks',
              'Many mothers then drop to six or seven sessions.'),
          PpStep('A double electric pump saves time', 'Hire or buy one.'),
          PpStep('Keep a log', 'Of times and amounts, to spot dips early.'),
          PpStep('Clean and store carefully',
              'Fridge for up to four days, freezer for months.'),
        ]),
        PpCallout('A sudden drop in supply, pain, or a hard red lump needs a '
            'lactation consultant or doctor.',
            kind: PpCalloutKind.doctor),
      ],
    ),
    PpPage(
      id: 'bf_special_situations',
      title: 'Donor milk, and feeding after breast surgery or cancer',
      subtitle: 'Less common questions, answered',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Some mothers face situations most guides skip. Here are two '
            'that come up.'),
        PpArticle(heading: 'Donor milk and milk banks', [
          'Human milk banks collect milk from screened donors and pasteurise '
              'it, mainly for premature and sick babies in hospital. India '
              'has a growing number, often in large government and medical '
              'college hospitals. The NICU team arranges it.',
          "Informal milk sharing between friends isn't screened and carries "
              'a risk of infection. Talk to your doctor first.',
        ]),
        PpArticle(heading: 'After breast surgery or breast cancer', [
          'Many women breastfeed after breast surgery, though supply may be '
              'lower on that side. After breast cancer, feeding from the '
              'untreated breast is often possible once treatment is '
              "finished. Some medicines aren't safe while breastfeeding.",
        ]),
        PpCallout('Talk to your oncologist or surgeon and a lactation '
            "consultant before you start. They'll check your medicines and "
            'make a plan.',
            kind: PpCalloutKind.doctor),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 2 — Formula, bottles and doing both
// -----------------------------------------------------------------------------
//  ⚠️ REVIEW-ONLY / REQUIRES-LEGAL-SIGNOFF. Under India's IMS Act and the WHO
//  code, infant formula, feeding bottles and infant foods sold as breast-milk
//  substitutes cannot be advertised or promoted. Every page in this area is
//  therefore free comparative REVIEW content and NONE of them links to
//  `pp_products`, `pp_recos` or any other commerce surface. Sterilisers,
//  warmers and bottle brushes are outside the restriction and could be linked;
//  they are deliberately not linked from the same page as formula, so that no
//  future edit can make this area look like a shop by accident.
//
//  ⚠️ TONE IS THE POINT OF THIS AREA. It is written for the mother who is
//  already carrying somebody else's disappointment. Nothing here apologises for
//  formula, and nothing here talks her out of breastfeeding either.
// =============================================================================

final PpArea _formula = PpArea(
  id: 'formula',
  mark: IntentMark.listMark,
  title: 'Formula, bottles and doing both',
  blurb: 'Honest answers, no guilt, and how to make a bottle safely.',
  hue: 32,
  pages: [
    PpPage(
      id: 'formula_fed_is_fine',
      title: 'Fed is fine, and it is the whole answer',
      format: 'ARTICLE',
      blocks: [
        PpIntro("If you're reading this at 2am feeling like you failed, start "
            'here. A fed baby, by any route, is what matters. This page '
            "won't spend three paragraphs on breast being best before it "
            'says so.'),
        PpArticle([
          'Mothers use formula for every reason there is. Milk that never '
              'came in, a baby who never latched, medicine, surgery, adoption, '
              'twins, going back to work at six weeks. A mother whose mental '
              'health was breaking under round-the-clock feeding. Mothers who '
              'just chose it. Each is a real reason, and none needs explaining.',
          'Formula in India is regulated and nutritionally complete. It is '
              'made to be a full diet for the first six months, with the '
              'energy, protein, iron and vitamins a baby needs. What it lacks '
              'is antibodies. That is a real difference, and a small one next '
              'to a baby who is fed and growing, with a mother who is coping.',
          "Combination feeding isn't half a failure. Plenty of families give "
              "some breast and some formula for months. It's a stable, "
              'proper way to feed a baby, not a step on the way to '
              'giving up.',
          'Feeding guilt can feel heavier in India than almost anywhere, '
              "because it comes in person, every day, from people who love "
              "you. You can say your baby is feeding well and gaining, thank "
              "you, and change the subject. You don't owe the room your "
              'medical history.',
        ]),
        PpCallout('Holding your baby close, eye contact, and giving feeds '
            'yourself when you can build the bond people credit to the '
            "breast. A bottle in a mother's arms does all of that."),
        PpWhenLine("At any age. There's no point at which switching to or "
            'adding formula becomes a wrong decision.'),
        PpIndiaNote('Formula still carries stigma in many Indian families, '
            'and some households still suggest a wet nurse or a relative '
            "feeding the baby. Cross-feeding isn't recommended, because "
            'infections including HIV and hepatitis pass through breast milk. '
            'If you want donor milk, ask your hospital about a screened human '
            'milk bank instead of arranging it privately.'),
        PpVideoSlot(
          title: 'Three mothers on why they used formula',
          subtitle: 'No experts, no music, no apology. What happened, and '
              'what they wish someone had told them.',
          minutes: '8 MIN',
          slotId: 'feeding/fed_is_fine_voices',
        ),
      ],
    ),
    PpPage(
      id: 'formula_choose',
      title: 'Choosing a formula',
      subtitle: 'Review only, and we sell none of it',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Formulas differ far less than the packs suggest. Infant '
            'formula in India is regulated, so the basic standard is high, '
            'and marketing does most of the rest.'),
        PpArticle([
          'Stage 1 is infant formula, for birth to six months. Stage 2 is '
              'follow-on formula, from six months. Stage 3 and toddler milks '
              "are growing-up drinks. They aren't needed at all once a child "
              'is on cow milk and family food. Start with stage 1 and stay '
              'there until six months.',
          'Almost every baby does well on a standard cows-milk-based formula. '
              'The specialist ones exist for real medical reasons. '
              'Extensively hydrolysed and amino acid formulas are for '
              'diagnosed cows milk protein allergy. Lactose-free is for '
              'diagnosed lactose intolerance, and preterm formula is for '
              'premature babies. These are prescribed, not picked off a shelf.',
          "Soy formula isn't a first choice for a suspected milk allergy in a "
              'young baby. Many babies who react to cows milk protein also '
              'react to soy. If you think your baby is reacting, talk to your '
              'paediatrician before you go shopping.',
          'Powder, liquid concentrate and ready-to-feed all work. Powder is '
              'cheapest, and most Indian families use it. Ready-to-feed is '
              'sterile in the tin, so it is the safer choice for a premature '
              'or unwell newborn, and it costs several times more.',
          'What is worth checking is the expiry date and an intact seal. Buy '
              'from a shop where stock moves fast, not a dusty tin from a '
              'cheap online seller.',
        ]),
        PpCallout('A more expensive formula is not a better formula. The '
            'extras on the front of the tin have far less evidence behind them '
            'than the price difference suggests.'),
        PpWhenLine('Stage 1 from birth to 6 months. From 6 months you can '
            'stay on stage 1 or move to stage 2. Either is fine. From 12 '
            'months, plain cow milk replaces formula for most children.'),
        PpIndiaNote('Chemists sometimes push whichever brand pays them most, '
            'and hospitals sometimes send you home with a tin from the sample '
            'cupboard. Neither is a recommendation. Ask your paediatrician '
            'which type your baby needs, then buy on price.'),
        PpCallout(
          'Talk to your paediatrician before using any specialist formula, and '
          'before switching for a suspected allergy. Blood or mucus in the '
          "stool, poor weight gain, severe reflux or eczema that won't "
          'settle are reasons to be seen, not to change brands.',
          kind: PpCalloutKind.doctor,
          title: 'Specialist formula is a prescription, not a purchase',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCallout('Never make formula at home from cow milk, flour or other '
            "ingredients, even in a shortage. It can't give a baby the right "
            'balance and can make a baby seriously ill. If you can\'t get your '
            "baby's formula, call your paediatrician for a safe alternative.",
            kind: PpCalloutKind.safety,
            title: 'Homemade formula is not safe'),
      ],
    ),
    PpPage(
      id: 'formula_prepare',
      title: 'Making up a bottle safely',
      // [reformat: was step-list] -> VIDEO. "Safety-critical (water temp,
      // sterilising, ratio, timing). Demonstrated + a glanceable checklist."
      // The slot is hoisted; the cards are the glance; the steps stay.
      format: 'VIDEO',
      blocks: [
        PpIntro('This page matters for safety. Powdered formula is not '
            'sterile, so how you make the bottle matters as much as which tin '
            'it came from.'),
        PpCards([
          PpCard('Water at about 70C', 'Boiled, cooled no more than 30 minutes.'),
          PpCard('Water first, then powder', 'Never the other way round.'),
          PpCard('That tin\'s scoop, levelled', 'Never packed, never an extra.'),
          PpCard('Cool fast, test on your wrist', 'Just warm, not hot.'),
          PpCard('Two hours, then it goes', 'Never reheated, never saved.'),
        ], heading: 'At a glance, before the steps', hue: 32),
        PpSteps([
          PpStep('Wash your hands and the surface',
              'Soap and water, before you touch anything. This is the step '
              "people skip at 3am, and it's the one that matters most."),
          PpStep('Clean and sterilise the bottle and teat',
              'Scrub with a bottle brush and detergent, and rinse. Then '
              'sterilise by boiling for at least five minutes, in a steam '
              'steriliser, or with sterilising solution. Every feed, until '
              'your baby is a year old.'),
          PpStep('Boil fresh water and let it cool for no more than 30 minutes',
              "It needs to still be hot, around 70C. That's what kills the "
              'bacteria that can live in the powder. Water that has cooled '
              "to room temperature doesn't do this."),
          PpStep('Pour the water into the bottle first, then add the powder',
              'Water first, always. Powder first makes a bottle that is too '
              "concentrated, and that's hard on a baby's kidneys."),
          PpStep('Use the scoop from that tin, levelled off',
              'That scoop belongs to that tin. Never pack it down or heap it, '
              'and never add an extra scoop for longer sleep. Too strong is '
              "dangerous. Too weak means your baby doesn't grow."),
          PpStep('Cap it, shake, and cool it fast',
              'Hold the bottle under a running cold tap or stand it in a jug '
              'of cold water, keeping the water below the cap.'),
          PpStep('Test on the inside of your wrist',
              'It should feel just warm, not hot. Then feed within two hours, '
              'and throw away whatever is left.'),
        ], heading: 'Seven steps, in this order'),
        // REQUIRED_REVIEW: the 70C water temperature, the 30-minute cooling
        // window, the 2-hour use-by for a made-up feed, and "sterilise until
        // 12 months". Standard, but confirm against current Indian paediatric
        // guidance, which differs in places from WHO wording.
        PpCallout(
          'Never dilute or strengthen a feed beyond the instructions on the '
          'tin. Extra powder to fill your baby up can cause dehydration and '
          'strain the kidneys. Extra water to make the tin last means slow '
          'undernourishment on a normal number of feeds. Follow the scoop.',
          kind: PpCalloutKind.safety,
          title: 'Never change the ratio',
        ),
        PpCallout(
          "Don't save the leftovers of a feed your baby has drunk from, and "
          "don't reheat a bottle. Bacteria from the mouth multiply in warm "
          "milk. Throw away what's left after two hours and make a fresh one.",
          kind: PpCalloutKind.safety,
          title: 'One feed, one bottle',
        ),
        PpWhenLine('Every feed, from birth. Sterilising can usually stop at '
            'about 12 months, but thorough washing carries on.'),
        PpIndiaNote('For travel, carry measured powder in a dry dispenser and '
            'hot boiled water in a flask, and make the feed when you need it. '
            "Don't carry made-up bottles in a bag for hours in Indian heat. "
            'If you must make one ahead, cool it fast, keep it at the back of '
            'the fridge, and use it within 24 hours.'),
        PpVideoSlot(
          title: 'Making up a bottle, step by step',
          subtitle: 'The real thing, in an ordinary Indian kitchen, including '
              'how to sterilise without a steriliser.',
          minutes: '6 MIN',
          slotId: 'feeding/formula_prep_demo',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCards(heading: 'Bottles, held and cleaned right', [
          PpCard('Never prop the bottle',
              'Even once your baby can hold it, around six to ten months, '
                  'stay close. A propped bottle can cause choking, ear '
                  'infections and tooth decay.'),
          PpCard('Hold your baby close',
              'Feeding is a time to connect. Swap arms halfway, as at the '
                  'breast.'),
          PpCard('Breast milk and formula in one bottle',
              'This is fine, but make the formula up with water first, then '
                  'add the breast milk. Never mix powder into breast milk.'),
          PpCard('Watch for mould',
              'Check bottle teats, valves and straw cups for black spots. Take '
                  'them apart to wash, dry fully, and replace worn parts.'),
        ]),
      ],
    ),
    PpPage(
      id: 'formula_brands',
      title: 'Indian formula, compared honestly',
      subtitle: 'Review only. Nothing here is sponsored or sold.',
      format: 'TABLE',
      blocks: [
        PpIntro('This is here because honest information is hard to find, '
            'and adverts are everywhere. Nothing on this page is paid for, '
            "linked to a shop, or ranked by anything except what's in the "
            'tin.'),
        // REQUIRED_REVIEW: this table describes CATEGORIES of formula rather
        // than naming brands, deliberately. Naming brands is where IMS Act
        // exposure begins, and a category table answers the mother's real
        // question ("which type do I need") without promoting anyone. If a
        // later pass wants named brands, that needs legal sign-off first.
        PpTable(
          heading: 'Which type of formula, and who it is for',
          columns: ['Type', 'Who it is for', 'Worth knowing'],
          rows: [
            [
              'Standard stage 1',
              'Almost every healthy baby, birth to 6 months',
              'Cows milk based, regulated content. This is the usual choice.',
            ],
            [
              'Stage 2 follow-on',
              'From 6 months, alongside solids',
              'Not needed. Staying on stage 1 is just as fine.',
            ],
            [
              'Toddler or growing-up milk',
              'Marketed from 12 months',
              'Not needed. Plain cow milk and family food cover it, for '
                  'much less money.',
            ],
            [
              'Partially hydrolysed, sold as comfort',
              'Marketed for colic and fussiness',
              'Little evidence. Not a treatment for allergy.',
            ],
            [
              'Extensively hydrolysed',
              'Diagnosed cows milk protein allergy',
              'Prescribed by a paediatrician. It tastes bitter, and babies do '
                  'accept it.',
            ],
            [
              'Amino acid based',
              'Severe allergy, when hydrolysed is not enough',
              'Specialist and expensive. Always prescribed.',
            ],
            [
              'Lactose free',
              'Diagnosed lactose intolerance, or after severe gastroenteritis',
              'Rarely needed long term in babies. Usually for a short time.',
            ],
            [
              'Soy based',
              'Specific medical or family reasons',
              'Not a first choice for suspected milk allergy, because many '
                  'babies react to both.',
            ],
            [
              'Preterm and high energy',
              'Premature or very low birth weight babies',
              'A hospital decision, followed up by your paediatrician.',
            ],
          ],
        ),
        PpCallout('Once you have the right type, choose on price, expiry date '
            'and whether your local shop keeps it in stock. Running out at '
            '10pm is a bigger problem than any difference between brands.'),
        PpWhenLine('Look at this again at 6 months and at 12 months. By then '
            'most families can stop buying formula altogether.'),
        PpIndiaNote('Avoid loose formula sold by weight, refilled tins and '
            'imports without Indian labelling. A sealed tin with an Indian '
            'label, a batch number and a clear expiry date is the whole '
            'checklist.'),
        PpCallout(
          'Ask your paediatrician before moving to any specialist formula, and '
          'before stopping one that was prescribed. Changing an allergy formula '
          'on your own can bring back symptoms that took weeks to settle.',
          kind: PpCalloutKind.doctor,
          title: 'Specialist formulas are a doctor decision',
        ),
      ],
    ),
    PpPage(
      id: 'formula_switching',
      title: 'Switching brands',
      format: 'ARTICLE',
      blocks: [
        PpIntro('People switch formula far more often than they need to, '
            "usually hoping for better sleep or less crying. Here's what a "
            "switch can and can't fix."),
        PpArticle([
          'You can switch between standard stage 1 formulas freely. They are '
              "made to the same regulated standard, so there's no medical "
              'reason to stick to one tin. Price or availability are good '
              'reasons to change.',
          'Change over a few days if you can. Give a feed or two a day of the '
              'new one, then more, over about three to five days. Some babies '
              "notice the taste and some don't mind at all. A straight swap "
              "isn't dangerous. At most it means a day of fussiness.",
          'Expect stools to change colour and texture for a few days. That '
              'is normal and settles. Blood, mucus, vomiting or a rash is not '
              'the switch settling in, and needs a doctor.',
          "What a switch won't fix: normal newborn crying, evening fussiness, "
              'waking at night, and wind. Those come from being a baby, not '
              'from the formula. Trying four brands in six weeks mostly costs '
              'money and confidence.',
        ]),
        PpCallout('Give a new formula at least a week before deciding it '
            "didn't work. Most of what people blame on formula settles in "
            'that time anyway.'),
        PpWhenLine('Switch gradually over 3 to 5 days. Give any new formula a '
            'week before judging it.'),
        PpIndiaNote('Stock can vanish from shops without warning, so it helps '
            'to know you can switch safely between standard brands. Keep one '
            'spare tin at home, not one favourite brand and no backup.'),
      ],
    ),
    PpPage(
      id: 'formula_mixed',
      title: 'Doing both, breast and bottle',
      format: 'ARTICLE',
      blocks: [
        PpIntro('A great many Indian families feed with both breast and '
            'formula, and almost nothing is written for them. This page is.'),
        PpArticle([
          "Mixed feeding works. Some breast milk is worth having, and there's "
              'no point below which it stops counting. One feed a day is not '
              'a failed version of eight.',
          'The one thing to understand is that supply follows removal. Every '
              'formula feed that replaces a breast feed without a pump tells '
              'your body to make a little less. To keep breastfeeding long '
              'term, keep breast feeds or pumps roughly steady, and let '
              'formula fill the gaps around them.',
          'One pattern that holds up well is breast in the morning and at '
              "night, when supply is highest and you're together anyway. "
              'Formula covers the day, at work or creche. Another: breast first at each '
              'feed, then a formula top up. That keeps the stimulation and '
              'takes the pressure off.',
          "If you're cutting down on purpose, drop feeds slowly. One feed "
              'every three or four days gives your breasts time to adjust and '
              'protects you from blocked ducts and mastitis.',
          'Under six months, top ups should be infant formula, or expressed '
              'milk if you have it. Cow milk as a main drink comes at a year, '
              'not before.',
        ]),
        PpCallout('Breast first, bottle after, protects supply best. Bottle '
            'first fills your baby up, so the breast gets skipped. That is '
            'how mixed feeding slides into formula only without anyone '
            'choosing it.'),
        PpWhenLine('Can start at any age. To protect the breast side, wait '
            'until feeding is comfortable, usually around 4 to 6 weeks, '
            'before adding regular bottles.'),
        PpIndiaNote('Mixed feeding is often what lets an Indian mother go back '
            'to work at three months and still be breastfeeding at a year. It '
            'is often the reason breastfeeding lasts as long as it does, not '
            'a compromise.'),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'If you are planning combination feeding around going back '
              'to work, or want to cut formula and rebuild the breast side. '
              'For when you would like a plan, not trial and error.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpSteps(heading: 'Paced bottle feeding', [
          PpStep('Hold your baby fairly upright', 'Not lying flat.'),
          PpStep('Keep the bottle level', 'So the milk only just fills the teat.'),
          PpStep('Let your baby draw the teat in', 'Touch it to the lips and wait.'),
          PpStep('Pause every few minutes',
              'Tip the bottle down for a rest and a burp.'),
          PpStep('Let your baby decide when the feed is done',
              'No need to finish the bottle.'),
        ]),
        PpWhenLine('Paced feeding takes 15 to 20 minutes and is closer to '
            'breastfeeding, so your baby is less likely to prefer the bottle.'),
      ],
    ),
    PpPage(
      id: 'formula_bottle_refusal',
      title: "My baby won't take the bottle",
      format: 'ARTICLE',
      blocks: [
        PpIntro('This often shows up about ten days before you go back to '
            "work, and it's stressful. Most babies do take a bottle in the "
            'end, and how you offer it matters more than which bottle it is.'),
        PpArticle([
          'Let someone else offer it. Breastfed babies who can smell their '
              'mother will hold out for the real thing. Leave the room, or the '
              "house, and let your baby's father or grandmother try.",
          'Offer when your baby is calm and a little hungry, not starving. A '
              "frantic baby won't learn a new skill. Try mid-morning, not at "
              'the end of a long day.',
          "Warm the teat under running water so it doesn't feel cold and "
              'strange. Hold your baby more upright than at the breast, and '
              'let the teat be drawn in, not pushed in. Try a slow-flow teat '
              'first.',
          'If the refusal lasts weeks, a small bowl and spoon, a small open cup or '
              'a sippy cup all work. From about six months you can skip '
              'bottles and go straight to a cup. A baby who never takes a '
              'bottle is an inconvenience, not a problem to fix at any cost.',
        ]),
        PpCallout("Don't hold back feeds to force it. Waiting it out builds a "
            'fight around feeding, and the bowl and spoon work better and faster '
            'than a battle.'),
        PpWhenLine("Start offering around 4 to 6 weeks if you know you'll "
            'need it. Keep one bottle or cup feed a week going so the skill '
            "doesn't fade."),
        PpIndiaNote('A small bowl and spoon is how many Indian babies have always '
            'been given expressed milk, and most hospitals teach it. It is '
            'slower, it works, and it avoids the flow preference bottles can '
            'cause.'),
      ],
    ),
    PpPage(
      id: 'formula_weaning',
      title: "Stopping breastfeeding when you're ready",
      format: 'ARTICLE',
      blocks: [
        PpIntro("Whenever you stop, it's the right time if it's your "
            'decision. This page is about doing it comfortably, not about '
            'whether you should.'),
        PpArticle([
          'Go slowly if you can. Drop one feed every three to five days, '
              'starting with the one your baby cares about least, usually a '
              'midday feed. Keep the first morning and last night feeds for '
              'the end. They hold the most comfort and are hardest to give up.',
          'Replace what you drop, not only the milk. Under one year, replace '
              'with formula. Over one year, cow milk and food. Replace the '
              'cuddle too, because for a toddler a feed is at least half about '
              'being held. A story, a lap and a small bowl of milk covers most of '
              'it.',
          'Look after your breasts as you wind down. Express just enough for '
              'comfort, not to empty, use cold packs, and watch for a hot, '
              'painful lump. Weaning too fast is a classic trigger for '
              'mastitis.',
          'Expect your mood to dip for a few days around a big drop. The '
              "hormone shift is real, and it passes. If it doesn't pass, or "
              'feels heavier than a few flat days, talk to a doctor. Don\'t '
              'file it under normal.',
          'Sometimes stopping suddenly is unavoidable, for surgery or '
              'treatment. Then express for comfort, and taper the expressing '
              'over a week or two. Ask your doctor about any medicine first. '
              "You may not need to stop at all.",
        ]),
        PpCallout('Breastfeeding never stops being good for your child at any '
            "age, and you're never obliged to continue at any age. Both are "
            'true at once.'),
        PpWhenLine('Gradual weaning over 2 to 6 weeks is comfortable for most '
            'mothers. Under 12 months, formula replaces the dropped feeds. '
            'Over 12 months, cow milk and food do.'),
        PpIndiaNote('Bitter pastes like neem or karela on the nipple are still '
            'suggested. They work by making a toddler distrust the breast and '
            'you, not by helping a child move on. Dropping feeds slowly and '
            'offering the cuddle without the feed gets there more gently.'),
        PpCallout(
          'See a doctor if a breast becomes hot, red and painful with fever '
          'during weaning. See one too if low mood after stopping lasts more '
          'than a couple of weeks. Both are common and treatable, and neither '
          'is something to push through alone.',
          kind: PpCalloutKind.doctor,
          title: 'Two things to watch while weaning',
        ),
      ],
    ),
    // ⚠️ [new] CHART. "Amounts per feed by age/weight. The breast side has
    // 'how much'; the bottle side has no numbers." Framed as a guide, not a
    // quota; her row leads.
    //
    // REQUIRED_REVIEW: every figure below. Standard ranges (roughly 150 ml
    // per kg per day in the early months, falling as solids come in); confirm
    // against current Indian paediatric guidance and the tin's own table.
    PpPage(
      id: 'formula_amounts',
      title: 'How much formula, by age',
      subtitle: 'A guide, not a quota',
      format: 'CHART',
      bands: ['milk', 'first_foods', 'm8_12'],
      blocks: [
        PpIntro('A bottle has markings, which helps and hurts: you can see what '
            'went in, so you start worrying about the number. These are the '
            'usual ranges. Your baby sets the amount, and the tin sets the '
            'ratio.'),
        PpChartCard(
          title: 'Per feed, and across a day',
          subtitle: 'Most babies land inside these. Some sit outside and are '
              'fine.',
          rows: [
            ('First week', '30 to 60 ml a feed, 8 to 10 feeds'),
            ('2 to 4 weeks', '60 to 90 ml a feed, 7 to 9 feeds'),
            ('1 to 3 months', '90 to 150 ml a feed, 6 to 8 feeds'),
            ('3 to 6 months', '150 to 210 ml a feed, 5 to 6 feeds'),
            ('6 to 9 months', '180 to 240 ml a feed, 4 to 5 feeds, solids starting'),
            ('9 to 12 months', '180 to 240 ml a feed, 3 to 4 feeds, solids growing'),
          ],
          rowMonths: [(0, 1), (1, 1), (1, 3), (3, 6), (6, 9), (9, 12)],
          note: 'The rough rule doctors use in the early months is about 150 ml '
              "for every kilo of your baby's weight, across a whole day. A 4 kg "
              'baby lands near 600 ml a day. It falls as food comes in.',
          hue: 32,
        ),
        PpCallout("Feed to your baby's hunger, not to the number. Turning away, "
            'slowing down and relaxed hands mean done, whatever is left in '
            'the bottle. A baby who finishes fast and is still rooting can '
            'have a little more.'),
        PpWhenLine('From birth to about a year, when cow milk as a drink can '
            'begin and formula usually ends.'),
        PpIndiaNote('Grandmothers count bottles the way they once counted '
            "feeds, and a half-finished bottle looks like a problem. It isn't. "
            'What matters is wet nappies and the weight line.'),
        PpLink(
          'Log feeds',
          surfaceId: 'pp_feeding',
          blurb: 'Amounts over a few days tell you more than any one bottle.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 3 — Starting solids
// -----------------------------------------------------------------------------
//  ⚠️ NO DOGMA. Spoon-feeding and baby-led weaning get one comparison table
//  between them and neither is written as the enlightened choice. Most Indian
//  families will do both in the same week, which is fine and is said out loud
//  rather than left as a guilty secret.
//
//  ⚠️ THE PAGES ARE NOT BAND-LOCKED TO 'first_foods'. Parents read ahead about
//  solids from about four months, and a mother with a five-month-old who opens
//  this area and finds nothing has been told the app has no answer. Banding
//  narrows what leads, never what exists.
// =============================================================================

final PpArea _startingSolids = PpArea(
  id: 'starting_solids',
  mark: IntentMark.blocksMark,
  title: 'Starting solids',
  blurb: 'When to begin, what first, and both ways of doing it.',
  hue: 96,
  pages: [
    PpPage(
      id: 'solids_when',
      title: 'When to start, and how to begin',
      format: 'ARTICLE',
      blocks: [
        PpIntro("Six months is the answer, and it's worth knowing why, "
            'because everyone around you will suggest four. This page covers '
            'the whole first week.'),
        PpArticle([
          'Around six months, milk alone stops covering everything. Iron '
              'stored from birth is running low, and energy needs outgrow '
              'milk. The gut and kidneys are ready for food in a way '
              'they were not at four months.',
          "Age isn't the only sign, and the signs matter more than the date. "
              'Your baby can sit with support and hold the head steady. The '
              'reflex that pushes food back out with the tongue has gone. '
              'Your baby can pick something up and get it to the mouth, and '
              'watches you eat with real interest.',
          'Start small. One meal a day, a teaspoon or two, at a time when your '
              'baby is neither starving nor exhausted. Mid-morning suits most '
              'families. Offer milk first for the first few weeks, so a new '
              "skill isn't being learned on an empty stomach.",
          'Build slowly to two meals a day by about seven or eight months, and '
              'three by nine to ten months, with snacks after that. Milk stays '
              'the main nutrition until about a year. So the first months of '
              'solids are about practice, not calories.',
          "Expect mess, gagging that isn't choking, faces of pure horror, and "
              'a lot of food on the floor. All of that is a baby learning, not '
              'a baby refusing.',
        ]),
        PpCallout('Before six months, milk is still the whole answer. Starting '
            "earlier doesn't help sleep, and does raise the risk of infection "
            'and allergy. If your baby was premature, ask your paediatrician '
            'which age to count from.'),
        PpCallout(
          "Starting solids early doesn't make a baby sleep through the night. "
          "It has been tested again and again, and it doesn't work. What it "
          'does is push out milk, which is more nourishing than anything you '
          'can put in a bowl at four months.',
          kind: PpCalloutKind.myth,
          title: 'Start rice cereal early and your baby will sleep',
        ),
        PpWhenLine('Around 6 months, and not before 4 months under any '
            'circumstances. One meal a day to begin, building to three by '
            'about 9 to 10 months.'),
        PpIndiaNote("You'll be told to start at four months with semolina or rice "
            'water, because the last generation did. Often that was because '
            'mothers went back to the fields. The advice has changed for good '
            'reasons. Six months it is, and the family can help by making the '
            'food, not by setting the date.'),
        PpVideoSlot(
          title: 'The first spoon, start to finish',
          subtitle: 'A real six-month-old, a real first meal, including the '
              'faces and the mess nobody puts in a brochure.',
          minutes: '8 MIN',
          slotId: 'feeding/starting_solids_demo',
        ),
        PpLink(
          'Recipes for a six month old',
          surfaceId: 'pp_food',
          blurb: "Purees, dal water and first mashes, sorted for your baby's age.",
        ),
      ],
    ),
    PpPage(
      id: 'solids_first_foods',
      title: 'The first foods',
      format: 'CARDS',
      blocks: [
        PpIntro("There's no special first food and no set order. Anything "
            'soft, plain and mashable works, and the Indian kitchen is full of '
            'better first foods than a packet of cereal.'),
        PpCards([
          PpCard('Moong dal water, then soft dal',
              'Start with the strained water, then move to soft-cooked dal '
              'mashed smooth. Protein, familiar to the whole family, and cheap.'),
          PpCard('Rice, cooked soft and mashed',
              'Plain rice mashed with a little dal water or milk. Gentle, and '
              'almost never refused.'),
          PpCard('Ragi porridge',
              'Ragi is one of the best first grains in India. High in calcium '
              'and iron, and easy to make loose or thick as your baby grows.'),
          PpCard('Semolina and broken wheat (sooji and dalia)',
              'Cooked soft with water or milk. Semolina is smooth, broken wheat has more '
              'fibre. Both work well from six months.'),
          PpCard('Mashed banana, apple or pear',
              'Banana raw and mashed, apple and pear steamed first. Naturally '
              'sweet, so offer vegetables alongside, not after.'),
          PpCard('Steamed vegetable mash',
              'Carrot, pumpkin, bottle gourd, sweet potato, potato. Steam, '
              'mash, and thin with a little water or milk.'),
          PpCard('Curd, from six months',
              'Plain, unsweetened, full fat. Good for the gut, and easy to mix '
              'with rice or fruit.'),
          PpCard('A little ghee',
              'Half a teaspoon stirred into dal or khichdi adds energy a small '
              "stomach can't get from volume."),
        ], heading: 'Eight that work, in any order', hue: 96),
        PpCallout('Offer one new food at a time, and give it two or three days '
            "before adding another. A reaction isn't likely, but if there is "
            "one, you'll know what caused it."),
        PpWhenLine('From 6 months. Two to three teaspoons at first, building '
            'to a few tablespoons by 8 months.'),
        PpIndiaNote("No salt and no sugar before one year. Babies' kidneys "
            "can't handle salt yet. And a baby who never learns that food must "
            "be sweet is much easier to feed at three. Take your baby's portion "
            'out of the pot before you season the family one.'),
        PpLink(
          "Which foods are safe at your baby's age",
          surfaceId: 'pp_baby_food_check',
          blurb: 'Type any food, get a clear answer.',
        ),
      ],
    ),
    PpPage(
      id: 'solids_spoon_or_blw',
      title: 'Spoon-feeding or self-feeding',
      subtitle: 'Both work. Most families do a bit of each.',
      format: 'TABLE',
      blocks: [
        PpIntro("You'll read that one of these is the modern way and the "
            "other is old fashioned. That's a marketing argument, not a "
            "medical one. Here's an honest comparison, so you can pick what "
            'suits your kitchen.'),
        PpTable(
          heading: 'The two routes, side by side',
          columns: ['', 'Spoon-fed purees', 'Baby-led weaning'],
          rows: [
            [
              'What it looks like',
              'You offer smooth food on a spoon, moving to lumps and then to '
                  'finger food.',
              'Your baby picks up soft finger-sized pieces from the start. No '
                  'puree stage.',
            ],
            [
              'Start age',
              'Around 6 months.',
              'Around 6 months, and only once your baby sits upright well.',
            ],
            [
              'Best for',
              'Babies who need more calories in, twins, a parent short of '
                  'time, and anyone worried about intake.',
              'Babies who refuse a spoon, families eating together, and '
                  'building chewing skill early.',
            ],
            [
              'Mess',
              'Moderate. Mostly on the bib and your hands.',
              'A lot. Floor, hair, walls.',
            ],
            [
              'How you know how much went in',
              'You can see it. Reassuring in the early weeks.',
              'Hard to tell at first. Milk is still covering needs, so it '
                  'matters less than it feels.',
            ],
            [
              'Choking',
              'Low risk, but the same rules apply once lumps start.',
              "No higher risk if pieces are soft and finger sized. Gagging is "
                  "common, and it isn't choking.",
            ],
            [
              'The honest catch',
              'Can get stuck at puree if you never move on to lumps.',
              'Iron-rich foods are harder to give in the first weeks, so '
                  'offer them on purpose.',
            ],
          ],
        ),
        PpCallout('Doing both is normal, not a compromise. Dal and rice from a '
            'spoon and soft carrot in a little fist, in the same meal, is an '
            'ordinary way to feed an Indian baby.'),
        PpWhenLine('Either route starts around 6 months. Whichever you pick, '
            'bring in lumps and finger foods by 9 months. Babies who stay on '
            'smooth puree past then often refuse texture later.'),
        PpIndiaNote('Indian food suits both ways better than most cuisines. '
            'Khichdi mashes for a spoon and rolls into balls for a fist. Idli '
            'tears into strips, a soft paratha finger holds together, and dal and '
            'rice work either way.'),
        PpCallout(
          'Whichever route you choose, your baby sits upright and eats with an '
          'adult watching. Nothing is offered in a moving car or a pram. Never '
          'prop a spoon or a bottle and walk away.',
          kind: PpCalloutKind.safety,
          title: 'The rules that apply to both',
        ),
        PpLink(
          'Choking hazards and safe textures',
          pageId: 'safety_choking',
          blurb: 'What to cut, how to cut it, and what gagging really looks '
              'like.',
        ),
      ],
    ),
    // ⚠️ [reformat: was step-list] -> INTERACTIVE. "An allergen tracker: tick
    // egg, peanut, etc. with the wait-and-watch guidance, not just a static
    // list." Each allergen is one check — introduced, or not yet — and the
    // walk ends on the ones still to do. The how-to lives in each item's
    // detail so the guidance is read at the moment it is needed, not on a
    // page before. Nothing is stored (see `pp_interactive_screen.dart`);
    // a persistent tracker is on the ledger in STILL-OPEN.
    //
    // REQUIRED_REVIEW: early allergen introduction from around 6 months, the
    // "keep it in the diet regularly" instruction, and the high-risk-baby
    // caveat in the closing. Current international position; confirm Indian
    // guidance specifically.
    PpPage(
      id: 'solids_allergens',
      title: 'Introducing allergens safely',
      format: 'INTERACTIVE',
      blocks: [
        PpInteractive(
          kind: PpInteractiveKind.checklist,
          title: 'Introducing allergens safely',
          blurb: 'The eight that matter, one at a time. Tick the ones your baby '
              'has had. The rest is your list.',
          hue: 96,
          items: [
            PpInteractiveItem(
                'Cow\'s milk, cooked into food',
                'A spoon of curd, or milk in a kheer or porridge. Not as a '
                    'drink until one. Morning, at home: a quarter teaspoon on '
                    'the lip first, then a small taste, then watch for two '
                    'hours.',
                'One at a time, morning, tiny first'),
            PpInteractiveItem(
                'Egg, well cooked',
                'Hard-boiled yolk mashed into dal or khichdi. Never runny.',
                'One at a time, morning, tiny first'),
            PpInteractiveItem(
                'Peanut, as a thin paste',
                'A little smooth peanut paste stirred into dal, or a thin '
                    'peanut chutney. Never whole, never a spoonful of thick '
                    'butter. That is a choking risk, separate from allergy.',
                'One at a time, morning, tiny first'),
            PpInteractiveItem(
                'Tree nuts, ground',
                'Almonds or cashews ground to a powder and stirred in. Whole nuts '
                    'wait until about five.',
                'One at a time, morning, tiny first'),
            PpInteractiveItem(
                'Wheat',
                'Soaked and squeezed roti, semolina, broken wheat. Probably already in.',
                'One at a time, morning, tiny first'),
            PpInteractiveItem(
                'Sesame, as til',
                'Ground til in a khichdi, or a thin til chutney.',
                'One at a time, morning, tiny first'),
            PpInteractiveItem(
                'Soy',
                'A little mashed tofu, or a spoon of cooked soya.',
                'One at a time, morning, tiny first'),
            PpInteractiveItem(
                'Fish',
                'Boneless, cooked soft, mashed into rice. Check twice for '
                    'bones.',
                'One at a time, morning, tiny first'),
          ],
          closing: 'Once a food is in without a reaction, keep giving it a '
              'couple of times a week. Regular exposure keeps the tolerance. '
              'Ask your paediatrician first if your baby has severe eczema, a '
              'food allergy already or a strong family history. Swelling of '
              'the lips or face, difficulty breathing, or going floppy and '
              'pale after a food means an emergency. Call an ambulance or get '
              'to a hospital immediately.',
          closingPageId: 'safety_allergy',
          closingLabel: 'What an allergic reaction looks like',
        ),
        /* kept for revert: the step-list page the tracker replaced
        PpIntro('The advice on this reversed in the last decade. Holding '
            'allergens back does not prevent allergy and may make it more '
            'likely, so the current approach is to introduce them early and '
            'keep them in the diet.'),
        // REQUIRED_REVIEW: early allergen introduction from around 6 months,
        // the "keep it in the diet regularly" instruction, and the specific
        // high-risk-baby caveat below. This is the current international
        // position and it changed recently; confirm with a paediatrician and
        // check Indian guidance specifically.
        PpSteps([
          PpStep('Start once solids are established',
              'Give it a week or two of ordinary food first, so you are not '
              'introducing an allergen and a whole new skill on the same day.'),
          PpStep('One allergen at a time, at home, in the morning',
              'Never at a restaurant, never at bedtime, and never on a day you '
              'cannot get to a doctor. Morning gives you the whole day to '
              'watch him.'),
          PpStep('Start with a tiny amount',
              'A quarter teaspoon rubbed on his lip, wait a few minutes, then '
              'a small taste if nothing happens.'),
          PpStep('Watch for two hours',
              'Most reactions show up within minutes to two hours. Hives '
              'around the mouth, swelling, vomiting, or a sudden change in '
              'breathing.'),
          PpStep('If nothing happens, build the amount up over a few days',
              'Then keep it in his diet, roughly a couple of times a week. '
              'Regular exposure is what maintains tolerance.'),
          PpStep('Move to the next one',
              'The main ones in an Indian kitchen are cows milk in food form, '
              'egg, peanut as a thin paste, tree nuts ground, wheat, soy, '
              'sesame in til form, and fish.'),
        ], heading: 'How to introduce one'),
        PpCallout('Whole nuts and spoonfuls of thick nut butter are a choking '
            'hazard for years, and that is a separate issue from allergy. Give '
            'peanut and nuts as a smooth thin paste stirred into food, never '
            'whole and never in a lump.'),
        PpWhenLine('From around 6 months, once solids are going. Do not delay '
            'past 12 months, which is what the old advice used to say.'),
        PpIndiaNote('Til, groundnut, curd, wheat and egg are already in most '
            'Indian kitchens, which makes early introduction easy. Ground '
            'til or a thin peanut chutney stirred into dal is a perfectly good '
            'first exposure.'),
        PpCallout(
          'Talk to your paediatrician first if he has severe eczema, an '
          'existing food allergy, or a strong family history. Those babies are '
          'still introduced early, but sometimes in a clinic. And if he ever '
          'has swelling of the lips or face, difficulty breathing, or goes '
          'floppy and pale after a food, call an ambulance or get to a '
          'hospital immediately.',
          kind: PpCalloutKind.doctor,
          title: 'Before you start, and if something goes wrong',
        ),
        PpLink(
          'What an allergic reaction looks like',
          pageId: 'safety_allergy',
          blurb: 'Mild against serious, and what to do for each.',
        ),
        */
      ],
    ),
    PpPage(
      id: 'solids_textures',
      title: 'Textures, stage by stage',
      // [reformat: was chart-card] -> ILLUSTRATION. "Show what each texture
      // actually looks like (puree -> mash -> soft finger food -> chopped)."
      // Four katoris, drawn; the chart card is kept below for revert.
      format: 'ILLUSTRATION',
      blocks: [
        PpIntro('Texture matters more than most parents are told. Babies who '
            'stay on smooth puree too long often refuse lumps at a year. That '
            'is much harder to fix than a bit of gagging at eight months.'),
        // REQUIRED_REVIEW: the texture-by-age progression below, particularly
        // the 8 to 9 month window for introducing lumps and finger foods.
        PpIllustration(
          kind: PpIllustrationKind.solidsTextures,
          title: 'What each stage looks like in the bowl',
          labels: [
            PpIllustrationLabel('6 to 7 months: smooth and thin',
                'Purees, dal water, loose ragi. Runs off the spoon.'),
            PpIllustrationLabel('7 to 8 months: thicker, mashed, soft lumps',
                'Mashed with a fork, not blended. The lumps are the point.'),
            PpIllustrationLabel('8 to 9 months: minced, and first finger food',
                'Soft sticks the length of your little finger, squashable '
                    'between finger and thumb.'),
            PpIllustrationLabel('9 to 12 months: chopped family food',
                'Most textures, self feeding. From a year, what the family '
                    'eats, cut small and less spicy.'),
          ],
          caption: "A guide, not a deadline. Go at your baby's pace, but keep "
              'moving. Gagging on a new texture is normal and noisy, and your '
              'baby stays pink. Choking is silent.',
        ),
        /* kept for revert: the chart card the picture replaced
        PpChartCard(
          title: 'What texture, at what age',
          subtitle: 'A guide, not a deadline. Move at his pace, but keep '
              'moving.',
          rows: [
            ('6 to 7 months', 'Smooth and thin. Purees, dal water, loose ragi.'),
            ('7 to 8 months', 'Thicker and mashed, with soft lumps in it.'),
            ('8 to 9 months', 'Minced and chopped. First soft finger foods.'),
            ('9 to 12 months', 'Chopped family food, most textures, self '
                'feeding.'),
            ('12 months and up', 'The same food the family eats, cut small and '
                'less spicy.'),
          ],
          note: 'Gagging while learning a new texture is normal and is his '
              'body protecting him. It is noisy and he stays pink. Choking is '
              'silent.',
        ),
        */
        PpCards([
          PpCard('Thin it with what it was made with',
              'Dal water, milk or plain water. Not sugar syrup, and not extra '
              'ghee just to make it slide.'),
          PpCard('Mash with a fork, not a mixer',
              'After six months, a fork leaves the small lumps babies need to '
              'learn on. A blender removes exactly what your baby is meant to '
              'practise.'),
          PpCard('Finger food means finger sized',
              'About the length of your little finger, soft enough to squash '
              'between your finger and thumb.'),
          PpCard('If a new texture is refused',
              'Go back one step for a few days and try again. One refusal is '
              'not a verdict.'),
        ], heading: 'Four practical things', hue: 96),
        PpCallout('Aim for soft lumps in the food by eight months. That is '
            'when chewing is learned most easily.'),
        PpWhenLine('Move up a texture every four to six weeks between 6 and 12 '
            'months, or faster if your baby is managing easily.'),
        PpIndiaNote('Idli, soft dosa strips, mashed khichdi, soaked and '
            'squeezed roti and steamed vegetable pieces cover every stage on '
            'this chart, without cooking anything separately.'),
        PpVideoSlot(
          title: 'Safe textures, shown at every stage',
          subtitle: 'What each texture really looks like in a bowl, and '
              'the difference between gagging and choking on video.',
          minutes: '10 MIN',
          slotId: 'feeding/safe_textures_demo',
        ),
      ],
    ),
    PpPage(
      id: 'solids_annaprashan',
      title: 'The first rice feeding (annaprashan), the first bite',
      format: 'ARTICLE',
      blocks: [
        PpIntro('The first grain is a ceremony in most Indian families. It is '
            'a lovely place where tradition and paediatrics meet, and they '
            'agree on the timing almost exactly.'),
        PpArticle([
          'Your family may call it annaprashan, mukhe bhaat, choroonu or bhaat '
              'khulai. The first rice feeding marks the first time a '
              'baby is given grain. It is usually held around six months for '
              'boys, and sometimes at five or seven months for girls, on a date '
              'chosen by the family or a priest.',
          'That timing matches the medical advice almost perfectly, which is '
              'worth telling the relative who thinks the app is against '
              'tradition. Kheer, payasam or plain rice with ghee is a perfectly '
              'good first food.',
          "Two small changes make it safe. Keep your baby's portion "
              'unsweetened or very lightly sweetened, and separate from the '
              'family bowl. And no honey at all before one year, whatever your '
              'family tradition says about honey on the tongue.',
          'The ceremony often ends with the baby choosing an object from a '
              'tray, and with many people wanting to give a bite. One or two '
              "spoons from you is enough. A full bowl isn't needed for the "
              'ceremony to count.',
        ]),
        PpCallout(
          'No honey before one year, not even a single ceremonial drop on the '
          'tongue or lips. Honey can carry spores that cause infant botulism, '
          'which is rare and serious. Use a drop of ghee or plain kheer '
          'instead, and the ritual stays the same.',
          kind: PpCalloutKind.safety,
          title: 'The one swap to make',
        ),
        PpWhenLine('Traditionally at 6 months, sometimes 5 or 7 depending on '
            'family custom. Any of those is fine, as long as the first real '
            'food is not before about 6 months.'),
        PpIndiaNote('If your family date falls at four months, you can still '
            'hold the ceremony. Give a symbolic touch of ghee or kheer to the '
            'lips instead of a bowl, and start real solids at six. Most elders '
            'accept this easily when it is put as doing the ritual properly, '
            'not skipping it.'),
      ],
    ),
    // ⚠️ [new] ARTICLE. "he can sit with support, high-chair basics, one calm
    // mealtime a day."
    PpPage(
      id: 'solids_setup',
      title: 'Setting up for solids',
      subtitle: 'Sitting, the chair, and one calm mealtime',
      format: 'ARTICLE',
      bands: ['milk', 'first_foods'],
      blocks: [
        PpIntro('Before the first spoon, three small things make every meal '
            'easier: your baby can sit, has somewhere to sit, and gets one '
            'mealtime a day that nobody rushes.'),
        PpArticle([
          'Your baby is ready to sit for food when the head is steady and '
              'sitting with support is easy, usually around six months. '
              "Slumped in a bouncer or lying back in your lap isn't a safe way "
              'to swallow, at any age.',
          'A high chair is useful, not essential. What matters is upright, '
              'supported and at table height. That can be a high chair with a '
              'footrest, a booster strapped to a dining chair, or your lap with '
              "your baby's back against your chest. Feet like something to "
              'push against. Dangling feet make a wriggly eater.',
          'Pick one meal a day, when your baby is awake, had milk an hour '
              'before, and is not tired. Late morning suits most babies. Sit '
              'together, put a little on the tray as well as on the spoon, '
              'and expect most of it on the floor. That is where learning to '
              'eat happens.',
        ]),
        PpCards([
          PpCard('A small spoon, a small bowl', 'Silicone or steel, not sharp-edged.'),
          PpCard('A bib and a mat under the chair', 'Or an old dupatta. Mess is part of learning.'),
          PpCard('A cloth for the face, not wet wipes', 'Wipe at the end, not after every mouthful.'),
          PpCard('Nothing on a screen', 'Your baby needs to see the spoon and your face.'),
        ], heading: 'What you really need', hue: 96),
        PpCallout('One calm mealtime a day beats three rushed ones. Milk is '
            'still most of the food at this age. This is practice.'),
        PpWhenLine('From about 5 months, so the chair and the habit are ready '
            'in time. Solids themselves start at 6 months.'),
        PpIndiaNote('A grandmother who feeds your baby sitting on a lap, '
            "facing outwards, back against the chest, is doing it right. It's lying "
            'back and walking about with a spoon that are worth changing.'),
        PpLink(
          'When to start, and how to begin',
          pageId: 'solids_when',
          blurb: 'The signs your baby is ready, and the first week.',
        ),
      ],
    ),
    // ⚠️ [new] ARTICLE. "why it happens, water/fibre, when to see the
    // doctor." Links to Health.
    PpPage(
      id: 'solids_constipation',
      title: 'Constipation when solids start',
      format: 'ARTICLE',
      bands: ['first_foods', 'm8_12'],
      blocks: [
        PpIntro('A baby who pooed after every feed now goes once in two days, '
            'and strains. This is one of the most common things in the first '
            'month of solids, and it is mostly the gut learning a new job.'),
        PpArticle([
          'Milk is almost all absorbed. Food is not, so for the first time '
              'the gut has real work to do and real waste to move. Firmer, '
              "less frequent stools are the normal result. It's only "
              'constipation if stools are hard pellets, passing them hurts, '
              'or there is blood.',
          'The usual causes are simple. Less fluid now that food is replacing '
              'milk. A lot of rice, banana, semolina or refined cereal, and very '
              'little fruit and vegetable. Iron-fortified cereals and, later, '
              'large amounts of cow milk can add to it.',
          'The fixes are simple too. Sips of water with meals from six '
              'months. Fruit and vegetable purees every day: papaya, pear, '
              'prune, peas, spinach in the dal. Swap some rice or semolina for '
              'ragi, oats or dalia. Keep the milk feeds going. Gently cycling '
              'the legs and a warm bath help a straining baby.',
        ]),
        PpCards([
          PpCard('Papaya, pear, prune', 'The three that work most reliably. Stewed and mashed.'),
          PpCard('Water with meals, from 6 months', 'Sips from a cup, not a whole bottle.'),
          PpCard('Less rice and semolina, more ragi and oats', 'Whole grains keep things moving. Refined ones slow them down.'),
          PpCard('No honey, no castor oil, no home remedies', "Honey isn't safe under one, and the rest aren't for babies."),
        ], heading: 'What helps', hue: 96),
        PpCallout('Straining, going red and grunting, then passing a soft '
            "stool, isn't constipation. Your baby is still learning to relax "
            'the right muscles while pushing. It passes.'),
        PpCallout(
          'See your paediatrician if there is blood in the stool, or no stool '
          'for more than four days with discomfort. Go too for vomiting, a '
          'swollen hard tummy, or constipation since birth, not since solids. '
          "Don't give any laxative or suppository without asking.",
          kind: PpCalloutKind.doctor,
          title: 'When it needs a doctor',
        ),
        PpWhenLine('Most common in the first 4 to 6 weeks of solids. Usually '
            'settles within a fortnight of changing the food.'),
        PpIndiaNote("Ghee in the dal really helps. It's one of the traditional "
            'answers that holds up. Honey, jaggery water and a drop of oil in '
            "the bottom are the ones that don't."),
        PpLink(
          'Health, the whole section',
          surfaceId: 'pp_section/parenting_health',
          blurb: 'Tummy trouble, reflux, and when a stool needs looking at.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 4 — What to feed at this age
// -----------------------------------------------------------------------------
//  ⚠️ THESE PAGES ARE THE DATA SOURCE FOR THE `pp_food_chart` TOOL. They are
//  `PpChartCard`s with label/value rows precisely so the quick-view can read
//  them instead of a second copy of every chart existing in a tool file. Two
//  copies of a feeding chart is two answers to the same question, and this is
//  the highest-traffic content in the section, so the copy that drifts would be
//  the one most people read.
//
//  ⚠️ EVERY BAND IS COVERED HERE, which is what lets the other seven areas band
//  their pages freely without leaving a band empty.
// =============================================================================

final PpArea _ageCharts = PpArea(
  id: 'age_charts',
  mark: IntentMark.chartLog,
  title: 'What to feed at this age',
  blurb: 'A day of food, month by month, veg and non-veg.',
  hue: 186,
  pages: [
    PpPage(
      id: 'chart_milk_only',
      title: 'Before 6 months, milk is the whole chart',
      format: 'CHART',
      bands: ['milk'],
      blocks: [
        PpIntro("There's no food chart for this age, because there's nothing "
            'to chart. Breast milk, formula, or both, and nothing else at '
            'all, including water.'),
        // REQUIRED_REVIEW: feed volumes and frequencies below.
        PpChartCard(
          title: 'Birth to 6 months',
          subtitle: 'A rough shape, not a target to hit',
          rows: [
            ('Food', 'Breast milk or infant formula only'),
            ('Water', 'None needed, even in summer'),
            ('Breast feeds in 24 hours', '8 to 12, on demand'),
            ('Formula, 0 to 1 month', 'About 60 to 90 ml, 8 to 10 times'),
            ('Formula, 1 to 3 months', 'About 90 to 150 ml, 6 to 8 times'),
            ('Formula, 3 to 6 months', 'About 150 to 210 ml, 5 to 6 times'),
            ('Vitamin D', 'Usually recommended as drops. Ask your doctor.'),
          ],
          note: 'Breastfed babies set their own amount, so there is nothing '
              'to measure. The formula figures are a starting point. A hungry '
              'baby who is growing well can take more.',
        ),
        PpCallout("Milk covers all of your baby's fluid needs, in any weather. "
            'Water before six months fills the stomach without feeding, and '
            'can upset the salt balance in the blood.'),
        PpWhenLine('Birth to about 6 months. Solids start at 6 months, not '
            'earlier, and milk stays the main food until about a year.'),
        PpIndiaNote("In a Delhi or Chennai summer, you'll be told your baby "
            "must be thirsty. Milk is enough. In the heat babies ask for "
            "shorter, more frequent feeds, and that's how it should work."),
        PpLink(
          'Log feeds',
          surfaceId: 'pp_feeding',
          blurb: 'Times, sides and amounts, without doing sums in your head.',
        ),
      ],
    ),
    PpPage(
      id: 'chart_6m',
      title: 'A day at 6 months',
      format: 'CHART',
      bands: ['first_foods'],
      blocks: [
        PpIntro('The first month of solids is about practice, not calories. '
            'Milk still does almost all the feeding, and two teaspoons eaten '
            'is a good day.'),
        // REQUIRED_REVIEW: portion sizes and meal counts on this and every
        // other age chart in this area.
        PpChartCard(
          title: '6 months, vegetarian',
          subtitle: 'One meal a day, building to two by the end of the month',
          rows: [
            ('On waking', 'Breast or formula'),
            ('Mid morning', '2 to 4 teaspoons of smooth puree or dal water'),
            ('Midday', 'Breast or formula'),
            ('Afternoon', 'Breast or formula'),
            ('Evening', 'Breast or formula'),
            ('Night', 'Breast or formula, as often as your baby asks'),
            ('Total solids', 'About 2 to 4 tablespoons across the day'),
            ('Texture', 'Smooth and runny'),
          ],
          note: 'Offer milk before the solid meal at this age, so your baby '
              'is learning, not eating out of hunger.',
        ),
        PpCards([
          PpCard('Good first meals this month',
              'Moong dal water, mashed rice with dal water, ragi porridge, '
              'steamed carrot or pumpkin mash, mashed banana, curd.'),
          PpCard('Non-vegetarian addition',
              'Well-cooked egg yolk mashed into rice can start this month. '
              'Introduce it as an allergen, one at a time.'),
          PpCard('Not yet',
              'Salt, sugar, honey, cow milk as a drink, whole nuts, and '
              'anything from a packet marked for older children.'),
        ], heading: 'What goes in the bowl', hue: 186),
        PpCallout('Two to four teaspoons is a full month-one portion. When '
            'your baby turns away, the meal is over. That is a good habit to '
            'start on day one.'),
        PpWhenLine('Month 7 of life, one meal a day, moving to two by about '
            '7 months.'),
        PpIndiaNote("Take your baby's portion out of the family pot before you "
            "add salt, chilli and tadka. That's the whole trick, and you never "
            'cook twice.'),
        PpLink(
          'Recipes for this age',
          surfaceId: 'pp_food',
          blurb: 'Every 6 to 8 month recipe in the app, with textures.',
        ),
      ],
    ),
    PpPage(
      id: 'chart_7m',
      title: 'A day at 7 months',
      format: 'CHART',
      bands: ['first_foods'],
      blocks: [
        PpIntro('Two meals now, and the texture gets thicker. This is the '
            'month to stop blending everything smooth and start mashing with a '
            'fork.'),
        PpChartCard(
          title: '7 months, vegetarian',
          subtitle: 'Two meals a day, milk still leading',
          rows: [
            ('On waking', 'Breast or formula'),
            ('Breakfast', '2 to 3 tablespoons of ragi or semolina porridge'),
            ('Midday', 'Breast or formula'),
            ('Lunch', '2 to 3 tablespoons of soft khichdi or dal rice'),
            ('Afternoon', 'Breast or formula'),
            ('Evening', 'Breast or formula'),
            ('Night', 'Breast or formula on demand'),
            ('Texture', 'Thick, mashed, with soft lumps'),
          ],
          note: "Half a teaspoon of ghee in one meal a day from now on. It's "
              'the easiest way to add energy to a small stomach.',
        ),
        PpCards([
          PpCard('New this month',
              'Soft khichdi, mashed idli, soft dalia, apple and pear stewed '
              'and mashed, paneer mashed fine, ground til stirred into food.'),
          PpCard('Non-vegetarian',
              'Whole egg once the yolk is accepted. Well-cooked boneless fish '
              'or chicken mashed very fine, in tiny amounts.'),
          PpCard('Iron matters from now',
              'Iron stored from birth is running low. Dal, ragi, greens, egg '
              'and meat all help. Serve with a little lemon or amla, which '
              'helps the body absorb iron.'),
        ], heading: 'What changes this month', hue: 186),
        PpCallout('Move to fork-mashed, not blended, this month. Babies who '
            'never meet a lump before nine months often refuse lumps later.'),
        PpWhenLine('Month 8 of life. Two meals a day, thicker textures, half a '
            'teaspoon of ghee daily.'),
        PpIndiaNote('Idli is close to a perfect baby food. Steamed, soft, '
            "fermented so it's easy to digest, and it tears into strips little "
            'hands can hold as soon as they want to.'),
        PpLink(
          'Recipes for this age',
          surfaceId: 'pp_food',
          blurb: 'Mashes and thicker porridges for 6 to 8 months.',
        ),
      ],
    ),
    PpPage(
      id: 'chart_8m',
      title: 'A day at 8 months',
      format: 'CHART',
      bands: ['m8_12'],
      blocks: [
        PpIntro('Finger food starts here. Expect most of it on the floor for a '
            'fortnight, and expect your baby to love every minute.'),
        PpChartCard(
          title: '8 months, vegetarian',
          subtitle: 'Two to three meals, plus finger food to practise on',
          rows: [
            ('On waking', 'Breast or formula'),
            ('Breakfast', '3 to 4 tablespoons porridge, plus a soft finger '
                'food'),
            ('Mid morning', 'Breast or formula'),
            ('Lunch', '3 to 4 tablespoons khichdi or dal rice with vegetables'),
            ('Afternoon', 'Breast or formula, plus fruit pieces'),
            ('Dinner', '2 to 3 tablespoons of something soft'),
            ('Night', 'Breast or formula'),
            ('Texture', 'Minced and chopped, soft finger foods'),
          ],
          note: 'Sitting upright, in a high chair or on a lap, with an adult '
              'watching. Never eating while crawling around.',
        ),
        PpCards([
          PpCard('First finger foods',
              'Steamed carrot sticks, soft paneer cubes, ripe banana pieces, '
              'idli strips, soft roti fingers soaked in dal, well-cooked pasta '
              'shapes.'),
          PpCard('Non-vegetarian',
              'Soft boneless chicken shredded fine, fish flaked carefully with '
              'every bone checked, egg cut into strips.'),
          PpCard('Still no',
              'Salt, sugar, honey, whole nuts, whole grapes, popcorn, hard raw '
              'vegetables, cow milk as a drink.'),
        ], heading: 'What little hands can hold now', hue: 186),
        PpCallout('Gagging is loud, and your baby stays pink. Choking is '
            'silent. Knowing this tells you when to act and when to stay '
            'calm.'),
        PpWhenLine('Month 9 of life. Three meals taking shape, finger foods '
            'daily, texture moving to minced and chopped.'),
        PpIndiaNote('A soft roti finger dipped in dal is the classic Indian '
            'first finger food. It beats every packaged teether biscuit on '
            'cost and on sugar.'),
        PpLink(
          'Choking hazards and safe textures',
          pageId: 'safety_choking',
          blurb: 'How to cut everything, and what never to offer.',
        ),
      ],
    ),
    PpPage(
      id: 'chart_9m',
      title: 'A day at 9 months',
      format: 'CHART',
      bands: ['m8_12'],
      blocks: [
        PpIntro('Three real meals now, and your baby eats more or less what '
            'the family eats, made softer and left unsalted.'),
        PpChartCard(
          title: '9 months, vegetarian',
          subtitle: 'Three meals and one snack',
          rows: [
            ('On waking', 'Breast or formula'),
            ('Breakfast', 'Porridge, upma or soft poha, about 4 tablespoons'),
            ('Mid morning', 'Fruit pieces or curd'),
            ('Lunch', 'Khichdi or dal rice with vegetables and ghee, about '
                '5 tablespoons'),
            ('Afternoon', 'Breast or formula'),
            ('Dinner', 'Soft roti with dal, or vegetable rice'),
            ('Night', 'Breast or formula'),
            ('Milk feeds', 'About 3 to 4 across the day'),
          ],
          note: 'Let your baby try the spoon, even though almost nothing will '
              'arrive. That practice makes twelve months easier.',
        ),
        PpCards([
          PpCard('New this month',
              'Soft upma and poha, chopped (not mashed) vegetables, small '
              'pasta, chopped fruit, thicker curd dishes.'),
          PpCard('Non-vegetarian',
              'Chicken and fish in small chopped pieces, egg in most forms, '
              'small amounts of mutton keema cooked very soft.'),
          PpCard('Iron-rich every day',
              'Ragi, dal, spinach, egg, chicken liver in tiny amounts, and jaggery '
              'only after one year.'),
        ], heading: 'What changes this month', hue: 186),
        PpCallout('Offer solids before milk now, the reverse of six months. '
            'Food does real work at this age, and a full milk feed just before '
            'lunch will cost you the lunch.'),
        PpWhenLine('Month 10 of life. Three meals plus a snack, still no salt '
            'or sugar, still no cow milk as a drink.'),
        PpIndiaNote('This is the age when two households often start '
            "disagreeing about salt. Young kidneys are the reason, not "
            'fussiness. One unsalted bowl from the same pot keeps everyone '
            'happy.'),
        PpLink(
          'Recipes for 9 to 12 months',
          surfaceId: 'pp_food',
          blurb: 'Mashes, finger foods and first family meals.',
        ),
      ],
    ),
    PpPage(
      id: 'chart_10_12m',
      title: 'A day at 10 to 12 months',
      format: 'CHART',
      bands: ['m8_12'],
      blocks: [
        PpIntro('Around the first birthday, most babies move to family food, '
            'cut small and made mild. These months lead up to that.'),
        PpChartCard(
          title: '10 to 12 months, vegetarian',
          subtitle: 'Three meals and two snacks, mostly self fed',
          rows: [
            ('On waking', 'Breast or formula'),
            ('Breakfast', 'Paratha fingers, idli, upma or porridge'),
            ('Mid morning', 'Fruit, curd or a soft chilla'),
            ('Lunch', 'Rice, dal, vegetable, ghee. Roti pieces if your baby '
                'likes them'),
            ('Afternoon', 'Breast or formula, or a snack'),
            ('Dinner', 'Whatever the family eats, unsalted and chopped small'),
            ('Night', 'Breast or formula'),
            ('Texture', 'Chopped family food, most textures'),
          ],
          note: 'Expect appetite to swing wildly from day to day. Judge what '
              'goes in across a week, never across one meal.',
        ),
        PpCards([
          PpCard('Ready for',
              'Most family foods, chopped small and made mild. A spoon to '
              'hold and use. An open cup or a straw cup with water.'),
          PpCard('At twelve months',
              'Cow milk can become the main milk drink, salt and sugar can be '
              'used lightly, and honey becomes safe.'),
          PpCard('Still not',
              'Whole nuts, whole grapes, hard raw carrot, popcorn, chewing gum, '
              "and anything round and firm the size of a child's windpipe."),
        ], heading: 'The one year handover', hue: 186),
        PpCallout('Two to three milk feeds a day is plenty by now. Milk that '
            'keeps replacing meals is the most common reason a one year old '
            "isn't eating food."),
        PpWhenLine('Months 11 and 12. Three meals and two snacks, family food '
            'chopped small, milk moving into the background.'),
        PpIndiaNote('A tiffin of curd rice and a boiled vegetable travels well, '
            'and lasts an Indian afternoon better than anything with gravy. '
            'Useful the first time you go out with your baby for a full day.'),
        PpLink(
          'Recipes for 9 to 12 months',
          surfaceId: 'pp_food',
          blurb: 'Finger foods and family meals, sorted by age.',
        ),
      ],
    ),
    PpPage(
      id: 'chart_toddler',
      title: 'A day for a toddler',
      format: 'CHART',
      bands: ['tod', 'big'],
      blocks: [
        PpIntro('From one year, your toddler eats what the family eats. The '
            'rhythm matters more than the chart. A toddler who snacks all day '
            'eats nothing at meals.'),
        // REQUIRED_REVIEW: the 300 to 500 ml daily milk cap for a toddler, and
        // the claim that excess milk blocks iron absorption. Both are widely
        // taught and both drive real advice on this page, so confirm the
        // numbers with a paediatrician.
        PpChartCard(
          title: '1 to 3 years',
          subtitle: 'Three meals and two snacks, at roughly fixed times',
          rows: [
            ('Breakfast', 'Paratha, idli, upma, poha, egg, porridge'),
            ('Mid morning snack', 'Fruit, curd, a small chilla'),
            ('Lunch', 'Roti or rice, dal, vegetable, curd'),
            ('Afternoon snack', 'Milk with a small snack'),
            ('Dinner', 'Family food, early, not at 10pm'),
            ('Milk in 24 hours', 'About 300 to 500 ml, no more'),
            ('Water', 'Freely, in a cup within reach'),
          ],
          note: 'A toddler portion is roughly a quarter to a third of an adult '
              "one. A toddler's stomach is about the size of a small fist.",
        ),
        PpCards([
          PpCard('Why the milk limit matters',
              'More than about 500 ml a day fills a toddler up, replaces '
              'meals, and blocks iron absorption. Too much milk is the most '
              "common reason a toddler won't eat."),
          PpCard('Fixed times, not a running buffet',
              'Meals and snacks at roughly the same times, nothing in between '
              "except water. A toddler who has snacked since 4pm can't eat "
              'dinner.'),
          PpCard('Growth slows down at one',
              'Children gain far less in the second year than the first, so '
              "appetite drops. That's part of growing, not a problem."),
        ], heading: 'Three things that fix most toddler feeding', hue: 186),
        PpCallout("Serve, then step back. Your job is what's offered and "
            "when. How much goes in is your child's choice. Taking that over "
            'is where mealtime fights begin.'),
        PpWhenLine('From 12 months onwards. Three meals and two snacks at '
            'roughly fixed times, milk capped at about 500 ml a day.'),
        PpIndiaNote('"One more roti. Feed the child. Two more bites." A toddler fed '
            'by four people until the tears come is the most common feeding '
            "problem in Indian homes, and it's completely fixable. Agree once, "
            'as a family, that your child decides how much.'),
        PpLink(
          'Baby not eating food',
          pageId: 'picky_not_eating',
          blurb: 'The full page on refusal, and what really works.',
        ),
      ],
    ),
    PpPage(
      id: 'chart_nonveg_regional',
      title: 'Non-vegetarian and regional swaps',
      format: 'CHART',
      blocks: [
        PpIntro('Every chart here is vegetarian by default, because that is '
            "the most common Indian kitchen. Here's how to swap in meat, egg "
            'and fish, and what each region already does well.'),
        // REQUIRED_REVIEW: ages for introducing egg, fish and meat.
        PpChartCard(
          title: 'Non-vegetarian, when and how',
          subtitle: 'Introduced as allergens, one at a time',
          rows: [
            ('Egg yolk', 'From 6 months, well cooked and mashed'),
            ('Whole egg', 'From about 7 months once yolk is accepted'),
            ('Fish', 'From about 7 months, boneless, checked twice'),
            ('Chicken', 'From about 7 to 8 months, cooked soft and minced'),
            ('Mutton and keema', 'From about 9 months, cooked very soft'),
            ('Liver', 'From about 8 months, tiny amounts, very iron rich'),
            ('Shellfish', 'Later, and only after talking to your doctor'),
          ],
          note: 'Meat and fish are the easiest iron and zinc a baby can get. '
              'Worth knowing if your baby\'s weight gain is being watched.',
        ),
        PpCards([
          PpCard('North',
              'Dalia, semolina halwa without sugar, soft paratha fingers, moong '
              'dal khichdi, curd, paneer.'),
          PpCard('South',
              'Idli, soft dosa strips, rice with sambar water, ragi mudde '
              'softened, curd rice, steamed vegetable.'),
          PpCard('East',
              'Bhaat with mashed potato and ghee, boneless rohu, khichuri, '
              'mashed pumpkin, payesh without sugar.'),
          PpCard('West',
              'Thepla fingers, soft khichdi with kadhi, moong dal chilla, '
              'bhakri soaked soft, coconut in small amounts.'),
        ], heading: 'What your region already does well', hue: 186),
        PpCallout('Nothing on any chart in this app is compulsory. Feed your '
            'child the food your family eats, made soft, unsalted and mild. '
            "That's better than any imported list."),
        PpWhenLine('From 6 months onwards. Introduce each new protein one at '
            'a time, and watch for two hours the first time.'),
        PpIndiaNote('In a vegetarian home, iron needs a little more attention: '
            'ragi, dal, spinach, sesame, and jaggery after one year. Add a source '
            'of vitamin C at the same meal so the iron absorbs.'),
        PpVideoSlot(
          title: 'A day of food, walked through by age',
          subtitle: 'Six months to two years, real bowls on a real table, so '
              'you can see what a portion really looks like.',
          minutes: '10 MIN',
          slotId: 'feeding/age_charts_walkthrough',
        ),
        PpLink(
          'Iron and the nutrients that matter',
          pageId: 'safety_iron',
          blurb: 'Indian sources for each one, and what blocks absorption.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 5 — Cooking for him
// -----------------------------------------------------------------------------
//  ⚠️ THE RECIPE ENGINE IS REUSED, NOT REBUILT. `pp_food` opens the unified
//  RecipesScreen, which already holds the recipes, the meal plan, the builder,
//  the shopping list, the saved list and the sick-days screen. This area is the
//  guided way in: it says which recipes to use for what, and hands off. Writing
//  recipes into this file would have created a second recipe store, and a baby's
//  ragi porridge would then exist twice with two different textures.
//
//  ⚠️ WHAT THIS AREA CANNOT DO FROM HERE. The spec asks for the 28 existing
//  recipes to gain age, texture, allergen and cook-along-video fields. That is
//  an edit to `pp_recipes_data.dart` / `pp_food_data.dart`, outside this file,
//  and it is named in the build report rather than half-done here.
// =============================================================================

final PpArea _cooking = PpArea(
  id: 'cooking',
  mark: IntentMark.stepsMark,
  title: 'Cooking for your child',
  blurb: 'What to make, by age, by staple, and by what your child needs.',
  hue: 44,
  pages: [
    PpPage(
      id: 'recipes_by_age',
      title: "Recipes for your child's age",
      format: 'CARDS',
      blocks: [
        PpIntro('The whole recipe collection is free and easy to filter. This '
            "page is the shortcut: your child's stage, and the set of recipes "
            'that goes with it.'),
        PpCards([
          PpCard('6 to 8 months, purees and first mashes',
              'Smooth and thin, moving to fork-mashed. Dal water, ragi '
              'porridge, steamed vegetable mash, mashed banana, first khichdi.'),
          PpCard('8 to 12 months, mashes and finger foods',
              'Minced, chopped, and things to hold. Idli strips, soft roti '
              'fingers, paneer cubes, moong dal chilla, thicker khichdi.'),
          PpCard('12 months and up, family meals',
              'What the family eats, chopped small and made mild. Curd rice, '
              'veg pulao, paratha, dal and rice, soft cutlets.'),
          PpCard('Travel and tiffin',
              'Food that lasts four hours in a bag in Indian weather. Curd '
              'rice, dry chilla, steamed vegetable, banana.'),
        ], heading: 'Four stages, four sets of recipes', hue: 44),
        PpCallout("Cook one pot for the family, and lift your child's portion "
            'out before the salt and chilli. That one habit makes feeding a '
            'baby manageable in a working household.'),
        PpWhenLine('From 6 months onwards. Match the recipe to the texture '
            'stage, more than to the exact age in months.'),
        PpIndiaNote("Almost nothing here is a special baby recipe. It's your "
            'own kitchen, cooked softer and seasoned later. So your child '
            'grows up eating your food, not a separate menu.'),
        PpLink(
          'Open the recipe collection',
          surfaceId: 'pp_food',
          blurb: "Filter by age, meal, texture, veg or non-veg, and what's in "
              'the kitchen.',
        ),
      ],
    ),
    PpPage(
      id: 'recipes_staples',
      title: 'Ragi, khichdi, dalia and the rest',
      format: 'CARDS',
      blocks: [
        PpIntro('Six Indian staples do most of the work of feeding a baby. '
            'Learn these and you rarely need a recipe again.'),
        PpCards([
          PpCard('Ragi',
              'Finger millet. High in calcium and iron, and one of the best '
              'first grains anywhere. Loose porridge at six months, thicker '
              'later, pancakes and laddoo after one.'),
          PpCard('Khichdi',
              'Rice and moong dal cooked soft together. Complete protein, one '
              'pot, and it works at every stage, from mashed to hand-held balls.'),
          PpCard('Semolina and broken wheat (sooji and dalia)',
              'Semolina is smooth and quick. Broken wheat has '
              'more fibre and keeps hunger away longer. Both work sweet or savoury.'),
          PpCard('Dal water and dal',
              'Start with the strained water, then move to mashed dal. Moong '
              'first, then masoor and toor. Cheap, familiar and iron rich.'),
          PpCard('Curd',
              'Plain, unsweetened, full fat, from six months. Good for the gut, '
              'cooling in summer, and the base of curd rice, the best baby food '
              'for travel there is.'),
          PpCard('Idli and dosa',
              "Steamed and fermented, so they're soft and easy to digest. "
              'Idli tears into strips for small hands from about eight months.'),
        ], heading: 'The six that carry everything', hue: 44),
        PpCallout('Add half a teaspoon of ghee to one meal a day from seven '
            "months. A baby's stomach can't hold enough volume to get its "
            'energy any other way.'),
        PpWhenLine('All six work from 6 months in their softest form. The '
            'texture moves up as your child grows, not the food.'),
        PpIndiaNote('Buy ragi and millet flour in small packs and keep them '
            'sealed. Flour goes rancid faster than whole grain, especially in '
            'humid weather. Rancid ragi tastes bitter enough to be refused, '
            'and then ragi gets the blame.'),
        PpVideoSlot(
          title: 'Cook along, moong dal khichdi for a baby',
          subtitle: 'One pot, three textures, from six months to two years, '
              'made in an ordinary pressure cooker.',
          minutes: '11 MIN',
          slotId: 'feeding/cookalong_khichdi',
        ),
        PpLink(
          'Ragi and khichdi recipes',
          surfaceId: 'pp_food',
          blurb: 'Every version in the app, sorted by texture.',
        ),
      ],
    ),
    PpPage(
      id: 'recipes_by_need',
      title: 'Cooking for weight, iron or immunity',
      format: 'CARDS',
      blocks: [
        PpIntro("Sometimes you aren't cooking for a stage. You're cooking for "
            'a worry. Three of those come up all the time.'),
        PpCards([
          PpCard('For weight gain',
              'Ghee in dal or khichdi, mashed banana with curd, ragi and '
              'banana pancakes, date and banana kheer, and paneer. Avocado '
              'where you can get it. Nut powders stirred in, once allergens '
              'are introduced.'),
          PpCard('For iron',
              'Ragi, moong and masoor dal, spinach dal, egg, chicken and fish, '
              'jaggery after one year. Serve with amla, lemon, orange or '
              'tomato at the same meal so the iron absorbs.'),
          PpCard('For immunity',
              'Curd and curd rice, turmeric milk after one year, tomato and '
              'carrot soup, clear chicken soup, seasonal fruit. No single food '
              'protects, and a varied plate beats any one superfood.'),
          PpCard('What blocks iron',
              'Too much cow milk, and tea or coffee anywhere near a meal. A '
              'toddler on a litre of milk a day can be low in iron while '
              'looking perfectly well fed.'),
        ], heading: 'Cooking with a purpose', hue: 44),
        PpCallout('Energy in each spoon beats volume every time. A small bowl '
            'with ghee in it feeds your child better than a big bowl of '
            "thin soup that doesn't get finished."),
        PpWhenLine('Weight-gain foods from 7 months, iron from 6, jaggery and '
            'honey only after 12 months.'),
        PpIndiaNote('Edible gum, dry fruit powders and saffron are traditional weight '
            'foods. They really are useful once nuts have been introduced, as '
            'a fine powder, not pieces. Never whole nuts, at any age under '
            'five.'),
        PpLink(
          'Foods that help with weight gain',
          pageId: 'weight_foods',
          blurb: 'The full page, with what to add to what.',
        ),
        PpLink(
          'Filter recipes by need',
          surfaceId: 'pp_food',
          blurb: 'Weight gain, iron rich and immunity, as recipe filters.',
        ),
      ],
    ),
    PpPage(
      id: 'recipes_sick_days',
      title: 'What to feed when your child is unwell',
      format: 'ARTICLE',
      blocks: [
        PpIntro("Appetite disappears when a child is ill, and that's normal. "
            'For a few days, fluids matter far more than food. There is a '
            'whole set of recipes in the app for exactly this.'),
        PpArticle([
          'With fever, offer fluids all the time, and food whenever your child '
              'wants it. Thin khichdi, moong dal water, coconut water, plain '
              'curd and fruit usually go down well. Children make it up in '
              'the week after, almost always.',
          'With loose motions, keep feeding. Holding back food slows recovery. '
              'Give ORS after every loose stool, breast or formula as normal, '
              'plus banana, rice, curd and khichdi. Avoid juice and anything '
              'sugary, which makes it worse.',
          'With a cough or cold, warm and soft goes down best. Rasam, clear '
              'soup, warm dal water. A blocked nose makes feeds shorter, so '
              'expect more of them. Clear the nose with saline drops before a '
              'feed.',
          'With vomiting, small amounts often work better than a normal meal. '
              'A spoon of fluid every few minutes for an hour, then build up. '
              'Breastfed babies should keep feeding, in shorter feeds.',
        ]),
        PpCallout('A child who is drinking and passing urine is usually '
            'managing, even after eating nothing for two days. Watch the '
            'fluids, not the plate.'),
        PpWhenLine('For as long as the illness lasts, plus a few days. '
            'Appetite usually returns within a week, often bigger than '
            'before.'),
        PpIndiaNote('Home ORS is one litre of clean boiled and cooled water, '
            'six level teaspoons of sugar and half a level teaspoon of salt. '
            'A packet from the chemist is more reliable and costs almost '
            'nothing, so keep two at home.'),
        // REQUIRED_REVIEW: the home ORS recipe above, and the dehydration
        // signs in the callout below.
        PpCallout(
          'See a doctor for no wet nappy in six hours, a dry mouth, no tears '
          'when crying, or a sunken soft spot. Go too for blood in the stool, '
          'vomiting that keeps on, or unusual drowsiness. Dehydration in a '
          'small child moves fast, and a hospital is the right place for it.',
          kind: PpCalloutKind.doctor,
          title: 'When an illness stops being a food question',
        ),
        PpLink(
          'Sick day recipes',
          surfaceId: 'pp_food',
          blurb: 'Recipes grouped by fever, loose motion, cough and cold.',
        ),
        PpLink(
          'What changed with my child',
          surfaceId: 'pp_what_changed',
          blurb: 'If the change was sudden, start here instead.',
        ),
        // Link out, do not own: "when he is unwell" depth and Sick mode are
        // Health's.
        PpLink(
          'Health, the whole section',
          surfaceId: 'pp_section/parenting_health',
          blurb: 'Fever, vomiting, dehydration, and when a sick day needs a '
              'doctor.',
        ),
      ],
    ),
    PpPage(
      id: 'recipes_batch',
      title: 'Cooking once, feeding all week',
      format: 'STEPS',
      blocks: [
        PpIntro('Nobody cooks a fresh baby meal five times a day for a year. '
            'A couple of hours on a Sunday covers most of the week, safely.'),
        PpSteps([
          PpStep('Cook in batches on one day',
              'Steam a tray of vegetables, cook a pot of dal, make a batch of '
              'khichdi. One gas ring, three dishes, most of the week.'),
          PpStep('Cool fast, within an hour',
              'Spread it thin on a wide plate, instead of leaving a hot pot on '
              'the counter. Food sitting warm in Indian weather is where '
              'trouble starts.'),
          PpStep('Portion into small containers or an ice tray',
              'One meal per cube or per box. Then you thaw only what gets '
              'eaten, not a whole batch again and again.'),
          PpStep('Label with the date',
              'Fridge for two days, freezer for a month. Written down beats '
              'remembered, especially at 7am.'),
          PpStep('Thaw in the fridge overnight, or in hot water',
              'Never on the counter for hours, and never left out while you '
              'finish something else.'),
          PpStep('Reheat until steaming hot, then cool to warm',
              'Hot all the way through kills what grew while it was stored. '
              'Then stir, and test it on your wrist before serving.'),
          PpStep('Reheat once only',
              "Whatever isn't eaten gets thrown away, not put back in the "
              'fridge for tomorrow.'),
        ], heading: 'A week of baby food in one afternoon'),
        // REQUIRED_REVIEW: fridge and freezer storage times for cooked baby
        // food, and the one-hour cooling window. Confirm against food safety
        // guidance for a warm climate.
        PpCallout(
          'Never refreeze anything that has been thawed, and never save food '
          'from a bowl your child has already eaten from. Serve into a '
          'separate bowl, and the rest of the batch stays clean.',
          kind: PpCalloutKind.safety,
          title: 'Two rules that make batching safe',
        ),
        PpWhenLine('From 6 months onwards. Purees freeze best, khichdi and '
            "dal freeze well, and curd and cut fruit don't freeze at all."),
        PpIndiaNote('If the power goes for hours, treat anything that has '
            'thawed as finished. A freezer that has warmed and refrozen is the '
            'most common cause of an upset stomach from home-cooked baby '
            'food.'),
        PpLink(
          'Meal plan and shopping list',
          surfaceId: 'pp_food',
          blurb: 'Plan the week and turn it into a list you can shop from.',
        ),
        PpLink(
          'Steamers, storage trays and containers',
          surfaceId: 'pp_products',
          blurb: "What's worth buying for batch cooking, and what isn't.",
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCards(heading: 'More variety, not more cooking', [
          PpCard("Rotate, don't reinvent",
              'Change one thing in a familiar dish: a different dal, a new '
                  'vegetable in the khichdi, ragi instead of semolina.'),
          PpCard('One family pot',
              "Take your child's portion out before salt and chilli, then "
                  'season the rest for the adults.'),
          PpCard('A weekly plan',
              'Seven dinners on paper saves daily decisions and shopping '
                  'trips.'),
          PpCard('Cook extra grains and dal',
              'Store in the fridge for two days and turn them into tomorrow\'s '
                  'paratha, cutlets or soup.'),
        ]),
      ],
    ),
    // Added 2026-10-02 from the parenting gap analysis (P2/P3).
    PpPage(
      id: 'recipes_meal_ideas',
      title: 'Easy meal ideas, from first foods to two and up',
      subtitle: 'Indian dishes that work for little ones',
      format: 'TABLE',
      blocks: [
        PpIntro("You don't need special baby recipes. Most Indian home "
            'cooking works for children with small changes: softer, less '
            "salt, less chilli. Here are ideas to keep the week "
            'interesting.'),
        PpTable(
          columns: ['Age', 'Ideas'],
          rowMonths: [(6, 8), (8, 12), (12, 24), (24, 72)],
          rows: [
            ['6 to 8 months', 'Moong dal water then mashed dal, rice and dal '
                'khichdi, ragi porridge, semolina kheer without sugar. Mashed '
                'banana, steamed apple or pear, pumpkin or carrot puree, '
                'mashed egg yolk and white.'],
            ['8 to 12 months', 'Soft idli with sambar, vegetable upma, dalia '
                'with vegetables, curd rice, paneer bhurji. Soft roti soaked in '
                'dal, mashed rajma rice, fish or chicken stew, poha, gram flour '
                'chilla strips.'],
            ['1 to 2 years', 'Family dal, vegetables and roti cut small, vegetable '
                'pulao, dosa, uttapam, spinach paneer, scrambled egg, chicken curry '
                'shredded, vegetable cutlets, paneer paratha, sweet potato '
                'chaat without spice.'],
            ['2 years and up', 'Most family food: rajma rice, chole, dal '
                'tadka, pav bhaji with less butter, vegetable biryani. '
                'Idli-sambar, egg curry, fish fry pieces without bones, '
                'whole-wheat pasta with vegetable sauce.'],
          ],
        ),
        PpWhenLine('Offer three meals and two snacks a day from about a year. '
            'Your child decides how much.'),
        PpLink('Recipes, step by step', surfaceId: 'pp_food',
            blurb: 'The Food companion, sorted by age.'),
      ],
    ),
    PpPage(
      id: 'recipes_tiffin_snacks',
      title: 'Healthy snacks, tiffin ideas and drinks',
      subtitle: 'For playschool and in between meals',
      bands: ['tod', 'big'],
      format: 'CARDS',
      blocks: [
        PpIntro('Snacks are small meals for little stomachs, not treats. A '
            'tiffin that is easy to eat, colourful and familiar comes home '
            'empty more often.'),
        PpCards(heading: 'Snacks', [
          PpCard('Fruit', 'Banana, chikoo, papaya, orange segments, cut '
              'grapes.'),
          PpCard('Curd and raita', 'With fruit or grated vegetables.'),
          PpCard('Roasted fox nuts (makhana)', 'Crushed for younger ones.'),
          PpCard('Boiled corn or chana chaat', 'Mashed for under-fours.'),
          PpCard('Dhokla, idli or appe', 'Soft and easy to hold.'),
          PpCard('Peanut or sesame ladoo', 'Small, soft, low on jaggery.'),
        ]),
        PpCards(heading: 'Tiffin ideas', [
          PpCard('Mini parathas', 'Paneer, potato, fenugreek or dal, rolled up.'),
          PpCard('Vegetable sandwich', 'Wholewheat, cut into small squares.'),
          PpCard('Idli or dosa rolls', 'With a little podi or chutney.'),
          PpCard('Pulao or curd rice', 'In a spill-proof box.'),
          PpCard('Cut fruit', 'In a separate small box.'),
        ]),
        PpCards(heading: 'Drinks', [
          PpCard('Water', 'The main drink, always.'),
          PpCard('Milk', 'Plain, after one, about two cups a day.'),
          PpCard('Buttermilk or plain lassi', 'Without much sugar.'),
          PpCard('Avoid packaged juices and cold drinks',
              'They are mostly sugar.'),
        ]),
        PpCallout('Keep shapes safe until four: no whole nuts, whole grapes '
            'or hard round sweets in the tiffin.',
            kind: PpCalloutKind.safety),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 6 — Weight gain and growing well
// -----------------------------------------------------------------------------
//  ⚠️ TWO DIFFERENT THINGS LIVE HERE AND THEY MUST NOT BLUR. "My family says he
//  is thin" is a social problem and gets reassurance plus a growth chart. "He is
//  not gaining" is a clinical problem and gets a paediatrician. The page that
//  reassures also names the signs that mean stop reassuring, because reassurance
//  without an exit is how a real faltering-growth case gets missed.
//
//  ⚠️ THE TRACKER IS `pp_growth`, NOT A NEW ONE. GrowthJourneyScreen already
//  plots weight and height properly.
// =============================================================================

final PpArea _weightGain = PpArea(
  id: 'weight_gain',
  mark: IntentMark.scaleMark,
  title: 'Weight gain and growing well',
  blurb: 'Foods that help, and an honest answer to "is my child too thin?"',
  hue: 12,
  pages: [
    PpPage(
      id: 'weight_foods',
      title: 'Foods that help with weight gain',
      format: 'CARDS',
      blocks: [
        PpIntro('Adding weight is about energy in each spoon, not quantity. A '
            "baby's stomach is roughly the size of a small fist, so what "
            'matters is how much energy fits into each small bowl.'),
        PpCards([
          PpCard('Ghee',
              'Half to one teaspoon stirred into dal, khichdi or porridge, '
              'from about 7 months. The easiest addition there is.'),
          PpCard('Full fat curd and paneer',
              'Never low fat for a child under two. Curd from six months, '
              'paneer mashed from about seven.'),
          PpCard('Banana and mashed avocado',
              'Banana with curd is a complete snack. Avocado is expensive, but '
              'almost pure good fat if you can get it.'),
          PpCard('Ragi and banana together',
              'As porridge, pancakes or a smoothie. Iron, calcium and calories '
              'in one bowl.'),
          PpCard('Nut and seed powders',
              'Almond, cashew, til and groundnut ground fine and stirred in, '
              'once those allergens have been introduced. A fine powder only, '
              'never pieces.'),
          PpCard('Coconut and coconut milk',
              'A spoon of coconut milk in a rice or vegetable dish adds real '
              'energy, and most southern kitchens already use it.'),
          PpCard('Egg, chicken and fish',
              'Protein and iron in a small volume, exactly what a baby who '
              "isn't gaining needs."),
          PpCard('Dates and jaggery, after one year',
              'Date and banana kheer is the classic. Both are iron rich, and '
              'both wait until the first birthday.'),
        ], heading: 'Eight that really add weight', hue: 12),
        PpCallout('Add energy to the food your child already eats, instead of '
            'pushing for more of it. A spoon of ghee in the same bowl beats '
            'a fight over a second bowl.'),
        PpWhenLine('Ghee from about 7 months, nut powders once allergens are '
            'introduced, jaggery and honey only after 12 months.'),
        PpIndiaNote('Roasted flour mix (panjiri), edible gum laddoos and dry fruit powders are '
            'traditional weight foods, and they work for children over one, in '
            'small amounts and finely ground. Skip the sugar-heavy versions, '
            'and skip them all before a year.'),
        PpLink(
          'Weight gain recipes',
          surfaceId: 'pp_food',
          blurb: 'Every energy-rich recipe in the app, by age.',
        ),
      ],
    ),
    PpPage(
      id: 'weight_fats',
      title: 'Ghee, nuts and the fats a baby needs',
      format: 'ARTICLE',
      blocks: [
        PpIntro("Fat gets a bad name it doesn't deserve in the first two "
            "years. A baby's brain is built largely out of fat, and a low-fat "
            'diet for a small child is a bad idea.'),
        PpArticle([
          'Roughly half of the energy in breast milk comes from fat. That '
              'tells you what babies are built to need. When solids start to '
              'replace milk, that fat has to come from somewhere, and dal and '
              "vegetables alone don't carry it.",
          "Ghee is the obvious Indian answer, and it's a good one. Half a "
              'teaspoon in one meal a day from seven months, a teaspoon by a '
              'year, more if weight gain is slow. It carries flavour, helps '
              'fat-soluble vitamins absorb, and every Indian kitchen has it.',
          'Nuts and seeds are the other big source. Almond, cashew, walnut, '
              'til and groundnut, ground to a fine powder and stirred into '
              'porridge or dal. Once introduced, keep them in the diet '
              'regularly, not just now and then.',
          'Full fat dairy matters until at least two years. Never buy toned or '
              'skimmed milk for a small child, and never low fat curd. The fat '
              'is the point.',
          'What to keep low is the other kind: frying oil reheated again and '
              'again, packaged fried snacks, and bakery items made with '
              'vanaspati. They add energy nobody needs, and crowd out food that '
              'would have nourished your child.',
        ]),
        PpCallout('Full fat milk, full fat curd, ghee in the food, and ground '
            "nuts once they've been introduced. That covers good fat for a "
            'child under two.'),
        PpWhenLine('Ghee from about 7 months, ground nuts from about 7 to 8 '
            'months once introduced as allergens, full fat dairy until at '
            'least 2 years.'),
        PpIndiaNote('Homemade white butter and ghee from your own kitchen are '
            'excellent, and cheaper than anything sold as a baby product. '
            "There's no special baby ghee. Ghee is ghee."),
        PpLink(
          'Track growth',
          surfaceId: 'pp_growth',
          blurb: 'Weight and height plotted over time, so you can see the '
              'trend instead of guessing.',
        ),
      ],
    ),
    PpPage(
      id: 'weight_too_thin',
      title: 'Is my baby too thin?',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Almost every Indian mother is asked this, usually in a room '
            "full of people, usually about a perfectly healthy baby. Here's "
            'how to tell if it is worth listening to.'),
        PpArticle([
          "A chubby baby isn't a healthier baby. Many Indian families picture "
              'a well-fed child from a time when undernutrition was the common '
              "danger, and that picture hasn't changed. Babies come in different "
              'builds. A lean baby who is active, alert, picking up new skills '
              'and gaining steadily is a well baby.',
          'What matters is the trend, not the number. A baby who has always '
              'followed the lower part of the chart, and still does, is growing '
              'normally. A baby who was higher and has crossed down through the '
              'lines is the one to look at, even if still heavier than the '
              'neighbour everybody praises.',
          'The signs of a well-fed baby are dull and reliable. Six or more '
              'wet nappies a day, steady weight over weeks, energy to play, '
              'new skills arriving, and firm limbs rather than soft ones.',
          'Some common reasons for slow gain can be fixed. Too few feeds. A '
              'poor latch that removes little milk. Watery food with little '
              'energy in it. Too much milk crowding out food after a year. '
              'Snacking all day, so there is no hunger at meals. Check all of '
              'those before worrying about anything else.',
          "Your relatives aren't measuring your baby against a chart. They're "
              'measuring against a memory. A plotted growth chart from your '
              'paediatrician ends the argument in a way no amount of extra '
              'feeding will.',
        ]),
        PpCallout('Weigh monthly, not daily. Day-to-day weight moves with a '
            'full nappy and a big feed, and watching that closely turns '
            'ordinary ups and downs into worry.'),
        PpCallout(
          "A chubby baby isn't a healthier baby. That picture comes from a "
          'time when undernutrition was the everyday danger, and it has never '
          'been updated. On a chart, health looks like a steady line, high or '
          'low, not a high number.',
          kind: PpCalloutKind.myth,
          title: '"Chubby means healthy"',
        ),
        PpWhenLine('Weigh at the routine visits and at each vaccination, and '
            'plot it. Between 1 and 2 years, gain slows to roughly two to '
            'three kilos for the whole year. That is normal, though it alarms '
            'everyone.'),
        // REQUIRED_REVIEW: the second-year weight gain figure above, and the
        // faltering-growth signs in the doctor callout below.
        PpIndiaNote('"Give one more roti, the child will fill out a bit." You can say '
            'the doctor is happy with the growth and leave it there. '
            'Force-feeding to satisfy an aunt costs you the next two years of '
            'mealtimes.'),
        PpCallout(
          'See your paediatrician if your baby has crossed downwards through '
          'the lines on the growth chart, or has not gained weight in a month. '
          'Go too if weight gain has stopped, weight is dropping, or your baby '
          'is lethargic and pale. Slow growth usually has treatable causes, '
          'and they are much easier to find early.',
          kind: PpCalloutKind.doctor,
          title: 'When thin is worth a doctor',
        ),
        PpVideoSlot(
          title: 'A paediatrician on the too-thin question',
          subtitle: 'What a growth chart really shows, what a healthy lean '
              'baby looks like, and the signs that mean stop reassuring and '
              'start checking.',
          minutes: '9 MIN',
          slotId: 'feeding/too_thin_explained',
        ),
        PpLink(
          'Track growth',
          surfaceId: 'pp_growth',
          blurb: 'Plot weight and height properly, so the trend is visible.',
        ),
        PpConsult(
          title: 'Paediatric nutrition consultation',
          whoFor: 'For a baby whose weight gain has really slowed, or a family '
              'arguing about it. You get a nutrition plan built around what '
              'your kitchen already cooks, not a generic diet chart.',
          surfaceId: 'pp_experts',
          role: 'nutrition',
        ),
      ],
    ),
    // ⚠️ [reference] -> the Growth journey. "Lives with the Growth tracker's
    // percentile reads; link, do not duplicate." The card opens the tracker,
    // where the percentile read already is. The article this page carried
    // is kept below for revert; it duplicated that read.
    PpPage(
      id: 'weight_chart_reading',
      title: 'Reading the growth chart without panic',
      subtitle: "In the Growth journey, beside your child's own curve",
      format: 'ARTICLE',
      toolSurfaceId: 'pp_growth',
      blocks: [],
    ),
    /* kept for revert: the article the reference replaced
    PpPage(
      id: 'weight_chart_reading',
      title: 'Reading the growth chart without panic',
      format: 'ARTICLE',
      blocks: [
        PpIntro('A growth chart is the most useful and most misread piece of '
            'paper in your file. Ten minutes here saves a lot of unnecessary '
            'fear.'),
        PpArticle([
          'The curved lines are percentiles. If he is on the 25th, it means '
              'that out of a hundred healthy children his age, about '
              'twenty five weigh less than him and seventy five weigh more. '
              'It is a position, not a mark out of a hundred.',
          'Somebody has to be on the 10th line and somebody has to be on the '
              '90th, and both are healthy children. A child on the 10th who '
              'has always been there is doing exactly what he should.',
          'What a doctor watches is the shape of the line, not where it sits. '
              'Steady along any percentile is good. Crossing downwards through '
              'two lines is worth investigating. A flat line over months is '
              'worth investigating regardless of how high it is.',
          'Weight is only one of three. Length or height and head '
              'circumference are plotted too, and a child who is short and '
              'light in proportion is usually simply small, often because his '
              'parents are. Weight falling while height carries on is the '
              'combination that gets attention.',
        ]),
        PpCallout('Steady along a low line is healthy. Falling across lines is '
            'the thing worth asking about. Where he sits matters much less '
            'than where he is going.'),
        PpWhenLine('Plot at every routine visit: monthly for the first six '
            'months, then at each vaccination and at least every three months '
            'to two years.'),
        PpIndiaNote('Take a photo of the plotted chart at every visit. Files '
            'get lost, doctors get changed, and a year of dots is worth more '
            'than a year of remembering roughly what he weighed.'),
        PpLink(
          'Track his growth',
          surfaceId: 'pp_growth',
          blurb: 'Enter each weight and height and see the curve build.',
        ),
      ],
    ),
    */
  ],
);

// =============================================================================
//  AREA 7 — Baby not eating food
// -----------------------------------------------------------------------------
//  ⚠️ THE AREA IS NAMED IN HER WORDS, NOT OURS. Indian parents search "baby not
//  eating food". They do not search "picky eater", which is an American phrase
//  and reads as a diagnosis of the child rather than a description of the
//  problem. The page ids keep 'picky' for continuity with the rest of the app's
//  data; nothing the parent sees uses it.
//
//  ⚠️ EMPATHY FIRST, THEN MECHANICS. Every one of these pages opens by agreeing
//  that it is hard, because a page that opens with "this is a normal phase" to a
//  mother who has been fighting over dinner for six weeks has already lost her.
// =============================================================================

final PpArea _notEating = PpArea(
  id: 'not_eating',
  mark: IntentMark.compassMark,
  title: 'Baby not eating food',
  blurb: 'Refusal, food jags, mealtime battles, and what calms them down.',
  hue: 288,
  pages: [
    PpPage(
      id: 'picky_not_eating',
      title: "My child isn't eating anything",
      format: 'ARTICLE',
      blocks: [
        PpIntro('This is the most searched feeding worry in India. It wears '
            "you out in a way that's hard to explain to anyone not holding "
            'the bowl. Almost always there is a reason, and almost always '
            'it can be fixed.'),
        PpArticle([
          "Start with the dull explanation, because it's usually the right "
              'one. Growth slows sharply after the first birthday. Babies '
              'roughly triple their birth weight in year one, and add only two '
              'or three kilos in year two. So appetite really does halve. Your '
              'child is the same. The need has changed.',
          'Then check the milk. A toddler drinking a litre of milk a day is '
              'full before sitting down. Milk also blocks iron absorption, '
              'which lowers appetite further. Capping milk at about 500 ml a '
              'day fixes more refusal than any recipe.',
          'Then check the snacking. A biscuit at four, a banana at five, juice '
              'at half past five, and dinner at seven has no chance. Fixed '
              'meal and snack times, with only water in between, rebuild '
              'hunger, and hunger does most of the work.',
          'Then check what happens at the table. Pressure, chasing, screens, '
              'four adults coaxing at once, or a plate piled so high it looks '
              'impossible all make a child eat less. So does eating alone '
              'while the family eats later.',
          "And check how your child is. Teething, a sore throat, "
              'constipation, a blocked nose, an ear infection or plain '
              'tiredness all flatten appetite for a few days. A sudden change '
              'in a child who ate well is more likely one of those than a new '
              'personality.',
        ]),
        PpCallout('Judge eating across a week, not one meal. Almost every '
            'toddler who eats nothing on Tuesday eats twice as much on '
            'Thursday. The week evens out even when no single day does.'),
        PpWhenLine('Most common between 1 and 3 years. A drop in appetite '
            'after the first birthday is expected, and usually lasts months, '
            'not days.'),
        PpIndiaNote('In India this comes with an audience. "One more bite, '
            'feed a little more", the phone held up as a distraction, the walk '
            'around the colony with a plate. It works today and costs you '
            'every meal after, because eating turns into something adults do '
            'to a child, not something a child does.'),
        PpCallout(
          'See your paediatrician if your child is losing weight, has stopped '
          'gaining for a month or more, or is refusing fluids as well as food. '
          'Go too for paleness and tiredness, pain or vomiting with meals, or '
          'a choke or gag bad enough to make eating frightening. Those are '
          'different from a fussy phase and worth being seen for.',
          kind: PpCalloutKind.doctor,
          title: 'When not eating is more than a phase',
        ),
        PpVideoSlot(
          title: 'Four parents on the year their child stopped eating',
          subtitle: 'What they tried, what made it worse, and what worked in '
              'the end. No experts and no perfect families.',
          minutes: '9 MIN',
          slotId: 'feeding/picky_real_parents',
        ),
        PpLink(
          'What changed with my child',
          surfaceId: 'pp_what_changed',
          blurb: 'If the refusal started suddenly, look here for what else '
              'changed at the same time.',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCallout('Research on twins suggests fussy eating is largely in the '
            "genes. It isn't your cooking or your parenting, and it often eases "
            'slowly through the school years. Keep offering, without '
            'pressure.'),
      ],
    ),
    PpPage(
      id: 'picky_who_decides',
      title: 'Who decides what, and who decides how much',
      format: 'ARTICLE',
      blocks: [
        PpIntro('One idea sorts out more mealtimes than any recipe. You decide '
            'what is served, where and when. Your child decides whether to eat '
            'it, and how much.'),
        PpArticle([
          "That split sounds passive, and it isn't. It puts you firmly in "
              'charge of the parts you can control. It hands your child the '
              'one part no adult can control anyway: whether to '
              'swallow.',
          'Your half is real work. Cooking food worth eating, serving it at '
              'sensible times, always including one thing your child reliably '
              'eats, and sitting down together. Your child\'s half is to eat '
              'as much or as little as feels right, with nobody making a scene.',
          'This ends the bargaining. No two more bites, no bribing with '
              'sweets, no aeroplane spoon, no phone. All of those teach a child '
              'to eat for a reward, not for hunger. Appetite is far more '
              'reliable than any reward.',
          'It takes about two weeks to settle, and the first week is usually '
              'worse. Your child tests whether the rule is real, eats badly '
              'for a few days, gets properly hungry, and then starts eating. '
              'Holding steady through that week is what makes it work.',
        ]),
        PpCallout('Serve one safe food your child likes at every meal, '
            'alongside whatever else is on the table. Then there is always '
            'something to eat, and nobody has to bargain.'),
        PpWhenLine('Works from about 12 months onwards. Give any change two '
            "weeks before deciding it hasn't worked."),
        PpIndiaNote('The whole household needs to agree on this once, out '
            'loud. One grandparent following your child around with a plate '
            "undoes it. It's easier to talk about as a family rule than as a "
            'correction in the moment.'),
        PpScript([
          PpScriptLine(
            say: 'This is dinner. You can eat what you like from it.',
            notThis: 'Just two more bites and then you can go.',
            why: "The first leaves hunger in your child's hands. The second "
                'turns eating into a bargain that holding out can win.',
          ),
          PpScriptLine(
            say: "You don't have to eat it. Leave it on the side.",
            notThis: "You're not getting up until that plate is finished.",
            why: 'Forcing food starts a fight that outlasts the meal. Children '
                'made to finish tend to eat less over time, not more.',
          ),
          PpScriptLine(
            say: 'Kitchen is closed now. Breakfast is in the morning.',
            notThis: "Fine, I'll make you Maggi instead.",
            why: 'A second menu teaches a child to hold out for the better '
                'offer. Missing one dinner is safe. A permanent short-order '
                'kitchen is not.',
          ),
          PpScriptLine(
            say: "Come on, we're all eating together.",
            notThis: 'Here, watch this while I feed you.',
            why: 'Children eat more, and try more new foods, when they eat '
                'with people than in front of a screen.',
          ),
        ], heading: 'What to say, and what to stop saying'),
      ],
    ),
    PpPage(
      id: 'picky_food_jags',
      title: 'Loved it last week, hates it now',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Food jags are one of the oddest parts of toddlerhood. The '
            'same dish at every meal for eleven days, then never again. It is '
            "normal, and there's a way to handle it so the food isn't lost "
            'for good.'),
        PpArticle([
          'Toddlers are working out that they are separate people with their '
              'own likes, and food is the easiest place to practise. Refusing '
              "something you cooked isn't about the food, and it certainly "
              "isn't about you.",
          'Some of it is natural caution. From around eighteen months to three '
              'years, most children become wary of new foods. It makes sense '
              'for a toddler who has just learned to walk not to eat unknown '
              'things off the ground. It fades.',
          'For a jag, serve the favourite, but not at every meal, and always '
              'put something else beside it without comment. Left to run '
              'unlimited, a jag usually ends with the child sick of that food, '
              'and it drops out of the rotation.',
          'For a new or rejected food, keep offering it without pressure. It '
              'can take ten or fifteen tries before a child accepts something, '
              'and most families stop after three. Put a little on the plate, '
              'say nothing, and let it be ignored.',
          'Change how it appears. A child who refuses cooked carrot may eat it '
              'raw and grated, in a paratha, in a soup, or cut a different '
              'shape. Same vegetable, new question.',
        ]),
        PpCallout('Ten to fifteen tries with no pressure is what acceptance '
            'usually takes. Serving it, saying nothing, and letting it be left '
            "isn't a failed attempt. It's one of the fifteen."),
        PpWhenLine('Most common from about 18 months to 4 years. Each jag '
            'usually lasts one to three weeks.'),
        PpIndiaNote('Indian food helps, because it uses the same ingredients in '
            'many forms. A child refusing dal will often eat the same dal as '
            "chilla, in khichdi, in sambar, or rolled into a roti. You aren't "
            "sneaking it in. You're offering it differently."),
        PpLink(
          'Recipes that change how a food looks',
          surfaceId: 'pp_food',
          blurb: 'The same vegetables in a different form.',
        ),
      ],
    ),
    PpPage(
      id: 'picky_battles',
      title: 'Mealtime battles, and why force-feeding backfires',
      format: 'ARTICLE',
      blocks: [
        PpIntro('If dinner has become the worst half hour of your day, this '
            'page is about getting the calm back first and the nutrition '
            'second. In that order, because the second needs the first.'),
        PpArticle([
          'Force-feeding works in the short term, which is why it spreads '
              'through families. The child swallows, the plate empties and '
              'everyone relaxes. The cost comes later. Children often pushed '
              'to eat end up eating less over time, refusing more foods, and '
              'linking meals with stress into their teens.',
          'The physical version (pinning a child down, holding the nose, '
              'spooning food in during tears) also carries a real choking '
              'risk. A crying child breathes in sharply, and food in the mouth '
              'at that moment can go into the airway.',
          'What replaces it is plain. Fixed times, no snacking between, small '
              'portions, one accepted food on every plate, everyone at the '
              'table, screens off. The meal ends after about twenty to thirty '
              'minutes, eaten or not.',
          'Reduce the audience. One adult runs the meal. A toddler with four '
              'people watching and commenting is on stage, and refusal is the '
              'role that gets the biggest reaction.',
          'And accept the flat weeks. Some weeks your child eats like a '
              'labourer, and some weeks lives on curd rice. Both happen in '
              'children who grow perfectly well. Your job across those weeks '
              'is to keep offering, not to keep winning.',
        ]),
        PpCallout('Never force, never hold a child down, never pinch the nose, '
            'and never feed a crying child. Beyond what it teaches about '
            'meals, food going into an open airway is a real risk.'),
        PpWhenLine('Any age from about 1 year. Give a new, calmer routine two '
            'weeks, and expect the first week to be worse.'),
        PpIndiaNote('The plate that follows a child around the colony, the '
            'phone propped against the dal, the grandmother finishing the '
            'bowl during play. All of it comes from love, and all of it '
            'makes the next meal harder. Changing it is a family decision, '
            'not a mother against everyone.'),
        PpCallout(
          'Talk to your paediatrician if your child gags or vomits at the '
          'sight of food, eats fewer than about ten foods in total, or refuses '
          'whole textures. Talk to them too if mealtimes have become '
          'frightening. A feeding therapist or a paediatric nutrition '
          'consultation helps here. These are different from ordinary '
          'fussiness.',
          kind: PpCalloutKind.doctor,
          title: 'When the battle needs outside help',
        ),
        PpConsult(
          title: 'Paediatric nutrition consultation',
          whoFor: 'For a family where meals have become a daily fight, or a '
              'child eating a very short list of foods. You get a plan, and '
              'someone to tell the rest of the household what you have been '
              'saying.',
          surfaceId: 'pp_experts',
          role: 'nutrition',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpArticle(heading: 'Stress shows up at the table', [
          'Children often eat less, or only want comfort foods, when '
              'something is unsettling them: a new sibling, a move, starting '
              'school, or tension at home. Pressure at meals makes it worse.',
          'Keep meals calm and predictable, eat together when you can, and '
              'talk about the day, not the food. Appetite usually comes back '
              'as life settles.',
        ]),
      ],
    ),
    PpPage(
      id: 'picky_sweet_packet',
      title: 'Only wants biscuits and chips',
      format: 'ARTICLE',
      bands: ['tod', 'big'],
      blocks: [
        PpIntro('Packaged snacks are designed to be more tempting than dal and '
            "rice, so a child preferring them isn't a character flaw. It's "
            'the product doing its job. This page is about keeping them in '
            'proportion.'),
        PpArticle([
          "One biscuit isn't the problem. Biscuits, chips, juice and namkeen "
              'are filling, quick and always there, so they crowd out the next '
              "meal. A child who had a packet at five won't eat at seven, and "
              'then gets another packet because dinner was missed.',
          "The practical fix is what's in the house, not willpower. What "
              "isn't in the house can't be argued over. Keep fruit, curd, "
              'roasted chana, chilla, boiled egg and nuts in ground or chopped '
              'form where the packets used to be.',
          "Don't make sweets a reward or a punishment. \"Finish your food and "
              'you can have a chocolate" teaches that the chocolate is the '
              'prize and the dal is the price. Serve a small sweet now and '
              'then as part of a meal instead, without fuss.',
          'Juice is easy to miss. Even fresh juice is sugar without the fibre. '
              'It dulls appetite, and it is bad for new teeth. Offer whole '
              'fruit and water, and keep milk a food, not a drink carried '
              'around all day.',
        ]),
        PpCallout("Change what's in the cupboard instead of arguing at the "
            'table. Almost every packet fight is won at the shop.'),
        PpWhenLine('Most relevant from about 18 months, once your child can '
            'ask for things by name and sees other children eating them.'),
        PpIndiaNote('Guests bring chocolates and relatives hand over biscuits '
            "as affection, and saying no in the moment is awkward. Take it, "
            'thank them, and keep it for after a meal, without a scene. The '
            'rule is about how often, not about purity.'),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 8 — Feeding safety
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE ONE AREA WITH PHYSICAL STAKES AND IT IS DELIBERATELY BLUNT.
//  Choking, honey before one, whole nuts, anaphylaxis. Nothing here is softened
//  for tone, nothing is buried under reassurance, and none of these pages links
//  to a product. A safety page that also sells something reads as an
//  advertisement dressed as a warning, which is the fastest way to lose the
//  reader's trust on the page where it matters most.
//
//  ⚠️ CALLOUT KINDS ARE CHOSEN, NOT DEFAULTED. `safety` where the instruction is
//  complete on its own (how to cut a grape, no honey before one). `doctor` where
//  somebody genuinely has to look at the child.
// =============================================================================

final PpArea _safety = PpArea(
  id: 'safety',
  mark: IntentMark.checkMark,
  title: 'Keeping feeding safe',
  blurb: 'Choking, allergies, what to avoid before one, and when water starts.',
  hue: 8,
  pages: [
    PpPage(
      id: 'safety_choking',
      title: "Choking, and how to cut food so it doesn't happen",
      // [reformat: was article] -> ILLUSTRATION. "A labelled 'cut it this
      // way' visual (grapes, round foods). Text is the wrong medium for a
      // choking-prevention page." The picture carries the cutting; the two
      // safety callouts, the doctor callout and the film stay. Gagging vs
      // choking moved to its own carousel. Prose kept below for revert.
      format: 'ILLUSTRATION',
      blocks: [
        PpIntro('Read this before finger foods start, not after. Most choking '
            'in small children happens with a short list of foods and a short '
            'list of situations, and both can be avoided.'),
        PpIllustration(
          kind: PpIllustrationKind.cutItThisWay,
          title: 'Cut it this way',
          labels: [
            PpIllustrationLabel('Grapes and cherry tomatoes: quartered lengthways',
                'Never whole, never halved into coins. A coin is exactly the '
                    'shape of a small airway.'),
            PpIllustrationLabel('Sausage, paneer, cheese: sticks, not coins',
                'Slice lengthways, then chop. Finger-length sticks that are '
                    'easy to hold.'),
            PpIllustrationLabel('Nuts: ground to powder',
                'Never whole and never halved until about five. Nut butter '
                    'spread thin, never by the spoon.'),
            PpIllustrationLabel('Carrot, apple, hard fruit and veg: grated or cooked soft',
                'Raw chunks wait. Steam until it squashes between finger '
                    'and thumb.'),
            PpIllustrationLabel('Popcorn, boiled sweets, chikki, whole channa: not yet',
                'The Indian snack list. These wait until about five.'),
          ],
          caption: 'The shapes that block an airway are round, firm and about '
              'the size of a small child\'s throat. Change the shape and most '
              'of the risk goes.',
        ),
        /* kept for revert: the article the picture replaced
        PpArticle([
          'Gagging and choking are different and confusing them causes a lot '
              'of unnecessary panic. Gagging is loud. He retches, his eyes '
              'water, he goes red, and he sorts it out himself. It is a '
              'protective reflex and it is very common while learning to eat.',
          'Choking is silent. He cannot cry, cannot cough properly, may go '
              'blue around the lips, and his face shows real distress with no '
              'sound. Silence is the signal. A child who is coughing loudly '
              'still has an airway, and the best thing you can do is let him '
              'cough.',
          'The dangerous shapes are round, firm and roughly the size of a '
              'small child\'s airway. Whole grapes, cherry tomatoes, whole '
              'nuts, chunks of raw carrot or apple, popcorn, hard boiled '
              'sweets, chunks of paneer or cheese, sausage cut into coins, and '
              'thick blobs of nut butter.',
          'The situations matter as much as the food. Eating while walking, '
              'crawling, lying down, in a moving car or in a pram. Being made '
              'to eat while crying. Being distracted or laughing with a full '
              'mouth. An older sibling handing him something. Nobody watching.',
          'Learn what to do before you need it. Every parent and every '
              'caregiver in the house, including the maid and the grandparents, '
              'should know the back blows and chest thrusts for a choking '
              'baby. A first-aid class run by a hospital takes one afternoon '
              'and is the best afternoon you will spend this year.',
        ]),
        */
        PpCallout(
          'Cut round food lengthways, never into coins. Grapes and cherry '
          'tomatoes quartered lengthways. Sausage sliced lengthways, then '
          'chopped. Nuts ground to powder, never whole and never halved. '
          'Spread nut butter thinly, never by the spoon. Grate hard vegetables '
          'and fruit, or cook them until soft.',
          kind: PpCalloutKind.safety,
          title: 'How to cut it',
        ),
        PpCallout(
          'Your child sits upright to eat, every time. An adult stays for the '
          'whole meal. No eating in a moving car, a pram, or lying down. Never '
          'feed a crying child, and never prop a bottle and walk away.',
          kind: PpCalloutKind.safety,
          title: 'The rules that never bend',
        ),
        PpWhenLine('From the first finger food, around 8 months, until at '
            'least 4 to 5 years. Whole nuts and popcorn wait until about 5.'),
        PpIndiaNote('The Indian hazards are worth naming. Whole peanuts and '
            'channa handed over as a snack. Boiled sweets and lozenges, hard '
            'chikki, whole grapes at a wedding, and small round ladoos. In a '
            "joint family, food often comes from someone who isn't thinking "
            'about age, so say it out loud once, to everybody.'),
        PpCallout(
          'If your child is silent, cannot cough or cry, or is going blue, '
          'start back blows immediately. Have somebody call an ambulance at '
          'the same time. After any choking where you had to step in, go to a '
          'hospital for a check, even if your child seems completely fine.',
          kind: PpCalloutKind.doctor,
          title: 'If your child is really choking',
        ),
        PpLink(
          'If your child chokes: what to do',
          pageId: 'safety_choking_response',
          blurb: 'Back blows and chest thrusts, infant and older, on film.',
        ),
        PpVideoSlot(
          title: 'Choking and safe textures, shown clearly',
          subtitle: 'What gagging looks like next to choking, how to cut every '
              'risky food, and back blows and chest thrusts shown on a '
              'training doll.',
          minutes: '12 MIN',
          slotId: 'feeding/choking_safety_demo',
        ),
      ],
    ),
    PpPage(
      id: 'safety_avoid_under_one',
      title: 'Foods to avoid before the first birthday',
      format: 'CARDS',
      blocks: [
        PpIntro('A short list, and every item on it has a real reason. After '
            'the first birthday, most of these open up.'),
        PpCards([
          PpCard('Honey',
              'Not a drop before 12 months, including on the tongue at a '
              'ceremony or on a dummy. It can carry spores that cause infant '
              'botulism, which is rare and serious.'),
          PpCard('Salt',
              "A baby's kidneys can't handle it. No added salt before one "
              'year, and go light after. That includes packaged snacks, papad, '
              'pickle, sauces and namkeen.'),
          PpCard('Sugar',
              'Nothing is gained, and appetite for real food is lost. No sugar, '
              'jaggery, gur, biscuits, juice or sweets before one year.'),
          PpCard('Cow milk as a main drink',
              'Small amounts in cooking are fine from six months. As the main '
              'drink it waits until 12 months, because it is low in iron and '
              'hard on a young gut.'),
          PpCard('Whole nuts and popcorn',
              'A choking risk, not an allergy one. Ground nut powder is fine '
              'and encouraged. Whole nuts wait until about 5 years.'),
          PpCard('Unpasteurised milk and soft cheese',
              'Raw milk from the milkman must be boiled. Unpasteurised soft '
              'cheeses carry a real infection risk for a baby.'),
          PpCard('Raw or undercooked egg and meat',
              'Cook both through. No half-boiled egg, no runny yolk, no rare '
              'meat before at least a year.'),
          PpCard('Tea, coffee and anything caffeinated',
              'Not needed, and tea near a meal blocks iron absorption. That is '
              'a common, hidden problem in Indian homes.'),
        ], heading: 'The under-one list', hue: 8),
        PpCallout(
          'No honey before 12 months, in any amount, in any form, for any '
          'ritual. Use a drop of ghee or plain kheer instead, and the ceremony '
          'stays the same.',
          kind: PpCalloutKind.safety,
          title: 'The one that catches families out',
        ),
        PpWhenLine('All of these apply until the first birthday. Whole nuts '
            'and popcorn stay off the list until about 5 years.'),
        PpIndiaNote('Honey on the tongue at birth or at the first rice feeding is a real, '
            'loving tradition in many families. That is why it needs saying '
            'clearly and early, not on the day. Ghee is the accepted swap, and '
            'nobody objects to it.'),
        PpLink(
          'Can my baby eat this?',
          surfaceId: 'pp_baby_food_check',
          blurb: "Any food, your baby's age, a clear answer and one line of "
              'reason.',
        ),
      ],
    ),
    PpPage(
      id: 'safety_allergy',
      title: 'What an allergic reaction looks like',
      // [reformat: was article] -> ILLUSTRATION. "Show it (hives, swelling)
      // + a clear call-now block for breathing/face. Red-flag." The picture
      // splits mild from call-now; the doctor callout is the block; three
      // cards keep what the picture cannot show. Prose kept for revert.
      format: 'ILLUSTRATION',
      blocks: [
        PpIntro('Most reactions to food are mild and settle. A few are '
            'emergencies. This page helps you know which is which, before it '
            'happens.'),
        PpIllustration(
          kind: PpIllustrationKind.allergicReaction,
          title: 'Mild, and call now',
          labels: [
            PpIllustrationLabel('Hives or red blotches, mostly round the mouth',
                'Mild. Stop the food, watch closely, call your doctor for advice.'),
            PpIllustrationLabel('Some swelling of the lips, an itchy rash',
                'Mild. Same: stop, watch, call for advice.'),
            PpIllustrationLabel('A bit of vomiting or loose stools',
                'Mild. Usually settles. Note the food and the time.'),
            PpIllustrationLabel('Swollen tongue or throat, noisy or hard breathing',
                'Call now. An ambulance, not the car, and no wait-and-see.'),
            PpIllustrationLabel('Hoarse cry, barking cough, wheeze',
                'Call now.'),
            PpIllustrationLabel('Sudden pallor, floppy, collapse',
                'Call now.'),
          ],
          caption: 'Reactions show within minutes to two hours. Anything on '
              'the face, the breathing or the colour is the emergency kind.',
        ),
        PpCards([
          PpCard("Looks like allergy, but isn't",
              'A red ring round the mouth after tomato, orange or strawberry '
                  'is contact irritation. Loose stools after a new food are '
                  'usually just a new food.'),
          PpCard('Cow\'s milk protein allergy looks slower',
              "Reflux that won't settle, blood or mucus in the stool, eczema "
                  'that keeps flaring, poor weight gain. Diagnosed by a '
                  'paediatrician, not by cutting dairy on a guess.'),
          PpCard('After a real reaction',
              "Don't test it again at home. Get it confirmed, ask what to "
                  'keep in the house, and tell everyone who feeds your child.'),
        ], heading: "Three things the picture can't show", hue: 8),
        /* kept for revert: the article the picture replaced
        PpArticle([
          'A mild reaction usually shows within minutes to two hours: hives or '
              'red blotches, especially around the mouth, an itchy rash, some '
              'swelling of the lips, a bit of vomiting, or loose stools. Stop '
              'the food, watch him closely, and call your doctor for advice '
              'about antihistamines and about what to do next.',
          'A severe reaction, anaphylaxis, is different in kind and not just '
              'in degree. Swelling of the tongue or throat, a hoarse voice or '
              'a barking cough, noisy or difficult breathing, wheeze, sudden '
              'pallor, floppiness, or collapse. That is an ambulance, '
              'immediately, and not a wait-and-see.',
          'Reactions that are not allergy also exist and get confused with it. '
              'A red ring around the mouth from acidic food like tomato, '
              'orange or strawberry is contact irritation and is harmless. '
              'Loose stools after a new food are usually just a new food.',
          'Cows milk protein allergy in a baby often looks slower and vaguer: '
              'reflux that will not settle, blood or mucus in the stool, '
              'eczema that keeps flaring, poor weight gain, and a generally '
              'unhappy baby. It needs diagnosing by a paediatrician rather '
              'than by cutting dairy out on a guess.',
          'If a food has caused a real reaction, do not test it again at home. '
              'Get it confirmed properly, ask what you should keep in the '
              'house, and tell everybody who feeds him, including the creche '
              'and the grandparents.',
        ]),
        */
        PpCallout(
          'Call an ambulance immediately for swelling of the tongue or throat, '
          'noisy or difficult breathing, a hoarse cry, sudden pallor, '
          'floppiness or collapse after a food. Avoid driving your child '
          "yourself if you can, and don't wait to see if it settles.",
          kind: PpCalloutKind.doctor,
          title: 'The signs that mean call now',
        ),
        PpWhenLine('Reactions usually appear within minutes to 2 hours of the '
            'food. Introduce any new allergen in the morning, at home, on a '
            'day you can reach a doctor.'),
        PpIndiaNote('Save the paediatrician\'s number and the nearest hospital '
            'with a paediatric emergency in every phone in the house. Stick '
            "them on the fridge for anyone without a phone. In an emergency, "
            'nobody remembers where anything is.'),
        PpLink(
          'Introducing allergens safely',
          pageId: 'solids_allergens',
          blurb: 'How to introduce each one, and why early is better.',
        ),
      ],
    ),
    PpPage(
      id: 'safety_iron',
      title: 'Iron and the nutrients that matter',
      format: 'CARDS',
      blocks: [
        PpIntro("Low iron is common in Indian babies, and you can't see it "
            'until it shows. A few habits in the kitchen prevent most of it.'),
        PpCards([
          PpCard('Iron, from about 6 months',
              'Iron stored from birth runs out around six months, one reason '
              'solids start then. Ragi, moong and masoor dal, spinach, egg yolk, '
              'chicken, fish, liver in tiny amounts, and jaggery after one '
              'year.'),
          PpCard('Vitamin C alongside it',
              'Lemon on the dal, amla, tomato, orange, guava. Vitamin C at the '
              'same meal can multiply the iron absorbed from plant foods. '
              'That matters a lot in a vegetarian home.'),
          PpCard('What blocks iron',
              'Tea and coffee near meals, and too much cow milk. A toddler on '
              'a litre of milk a day is the classic low-iron child who looks '
              'perfectly well fed.'),
          PpCard('Calcium',
              "Milk, curd, paneer, ragi, til and green leafy vegetables. Don't "
              'serve a big milk drink with an iron-rich meal, because they '
              'compete.'),
          PpCard('Vitamin D',
              'Sunlight and drops. Most Indian babies are given vitamin D '
              'drops. Low vitamin D is very common here despite the sun, '
              'because of covered skin and indoor living. Ask your '
              'paediatrician about the dose.'),
          PpCard('Zinc',
              'Dal, chana, til, curd, egg, meat. Matters for immunity, and for '
              'recovering from repeated infections.'),
          PpCard('Protein',
              'Dal, curd, paneer, egg, chicken, fish, soya, chana. Spread '
              'across the day, not in one meal.'),
          PpCard('Iodine',
              'Use iodised salt in the family cooking, for everybody over one '
              "year. It's the cheapest health measure in the kitchen."),
        ], heading: 'What matters, and where it comes from', hue: 8),
        // REQUIRED_REVIEW: vitamin D supplementation for Indian infants, the
        // age iron needs rise, and whether iron supplementation should be
        // mentioned here at all rather than left entirely to the doctor.
        PpCallout('Iron plus vitamin C at the same meal, and milk kept away '
            'from it. That pairing does more for an Indian baby\'s iron than '
            'any supplement bought without advice.'),
        PpWhenLine('Iron matters from 6 months. Vitamin D drops usually from '
            'birth, on your paediatrician\'s advice. Iodised salt from 1 year, '
            'when salt starts.'),
        PpIndiaNote('Cooking dal and vegetables in an iron pan adds a small '
            'but real amount of iron to the food. A useful plus of the pan '
            'your family probably already owns.'),
        PpCallout(
          'Ask your paediatrician about a test if your child is pale, tired, '
          'irritable or eating badly, or was born premature or small. '
          "Don't start iron or any supplement on your own. Too much iron is "
          'harmful, and iron drops are a common cause of accidental poisoning '
          'in small children.',
          kind: PpCalloutKind.doctor,
          title: 'Supplements are a doctor decision',
        ),
        PpConsult(
          title: 'Paediatric nutrition consultation',
          whoFor: 'For a vegetarian home worried about iron and protein, or a '
              'child found to be anaemic. You get a plan built from what your '
              'kitchen already cooks.',
          surfaceId: 'pp_experts',
          role: 'nutrition',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCards(heading: 'Food for a growing brain', [
          PpCard('Iron', 'Dal, leafy greens, eggs, meat, ragi.'),
          PpCard('Healthy fats', 'Ghee, nuts (powdered for little ones), '
              'seeds, fish.'),
          PpCard('Protein', 'At every meal.'),
          PpCard('Iodised salt in family food', 'After one.'),
          PpCard('No wonder foods',
              'No single food or drink boosts memory. A varied plate, sleep '
                  'and play do.'),
        ]),
      ],
    ),
    PpPage(
      id: 'safety_water',
      title: 'When to start water',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Not before six months, whatever the weather. After that, '
            "freely, in an open cup. That's nearly the whole page, and the "
            'reasons take two minutes.'),
        PpArticle([
          'Before six months, breast milk and formula give all the water a '
              'baby needs, even in a Rajasthan summer. Water fills a small '
              'stomach without feeding it, so less milk goes in. In larger '
              'amounts it can dilute the salts in the blood, which is '
              'dangerous.',
          'From six months, offer water with meals in a small open cup or a '
              'straw cup. A few sips is plenty at first. It is about learning '
              'to drink from a cup as much as about the water.',
          'From a year, water is the main drink between meals, with milk '
              'limited to about 500 ml a day. Water, not juice, and nothing '
              'sweetened at all.',
          'Use water that is safe for the household: boiled and cooled, '
              'filtered, or from a treated supply. If unsure, boil for a '
              'rolling minute, then cool it covered. Bottled water is not '
              'always safer than a good home filter.',
        ]),
        // REQUIRED_REVIEW: the "no water before 6 months" line, the toddler
        // milk cap of about 500 ml, and the boiling instruction.
        PpChartCard(
          title: 'Water, by age',
          rows: [
            ('0 to 6 months', 'None. Milk covers everything.'),
            ('6 to 12 months', 'A few sips with meals, in an open cup'),
            ('12 to 24 months', 'Freely through the day, about 1 litre'),
            ('2 years and up', 'Freely, and always the first choice of drink'),
          ],
          note: 'In hot weather, young babies want shorter, more frequent '
              'milk feeds, not water. Offer them.',
        ),
        PpCallout('An open cup or a straw cup beats a spouted sippy cup. Both '
            'are better for teeth and speech muscles, and teach the real '
            'skill instead of a temporary one.'),
        PpWhenLine('From 6 months with meals. Freely from 12 months, with milk '
            'capped at about 500 ml a day.'),
        PpIndiaNote("Don't give a baby under six months water, glucose water, "
            'gripe water or herbal drops (janam ghutti), however hot it is and however firm '
            'the advice. If your baby seems thirsty in summer, feed more '
            'often.'),
        PpCallout(
          'See a doctor for fewer wet nappies than usual, a dry mouth, no '
          'tears when crying, a sunken soft spot, or unusual drowsiness. '
          "Dehydration in a baby moves quickly. It isn't something to manage "
          'at home with water alone.',
          kind: PpCalloutKind.doctor,
          title: 'Signs of too little fluid',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpSteps(heading: 'Moving to a cup', [
          PpStep('Offer an open cup or straw cup from six months',
              "With water at meals. Expect spills. That's how cup drinking is learned."),
          PpStep('A sippy cup is optional',
              'An open or straw cup is better for the mouth and teeth.'),
          PpStep('Aim to stop the bottle around a year, and by 18 months',
              'Drop one bottle feed at a time, starting with the one your '
                  'child cares least about. The bedtime bottle usually goes '
                  'last.'),
          PpStep('Milk in a cup from one', 'And never a bottle in bed.'),
        ]),
      ],
    ),
    // ⚠️ [new] VIDEO, and the Safe tab's red flag. "The missing response:
    // back blows, infant vs older, when to call. Prevention alone is not
    // enough." The most important safety fix on the parenting side.
    //
    // REQUIRED_REVIEW: the whole sequence below against current paediatric
    // first-aid guidance (Indian Academy of Pediatrics / resuscitation
    // council wording), before this ships. It must be signed off by a
    // clinician, not a reviewer.
    // ⚠️ [reference] -> HEALTH. The choking response was built here first;
    // the Health door brief makes it canonical on Get help now ("Feeding
    // links to it, does not keep its own copy"). This card opens that page
    // directly. The page as it was built here is kept below for revert; the
    // live copy is `health_choking_response` in `pp_health_content.dart`.
    PpPage(
      id: 'safety_choking_response',
      title: 'If your child chokes: what to do',
      subtitle: 'Back blows and chest thrusts, in Health',
      format: 'VIDEO',
      toolSurfaceId: 'pp_page/parenting_health/health_choking_response',
      blocks: [],
    ),
    /* kept for revert: the page before it moved to Health
    PpPage(
      id: 'safety_choking_response',
      title: 'If he chokes: what to do',
      subtitle: 'Back blows and chest thrusts, before you need them',
      format: 'VIDEO',
      blocks: [
        PpVideoSlot(
          title: 'If he chokes: back blows and chest thrusts',
          subtitle: 'On a training doll, at real speed and then slowly: the '
              'infant hold, the older child, and the moment to call.',
          minutes: '5 MIN',
          slotId: 'feeding/back_blows_demo',
          hue: 8,
        ),
        PpIntro('Read this once now, calmly, and watch the film. Then make '
            'everyone who feeds him watch it too. In a real choking you will '
            'not be reading anything.'),
        PpCallout(
          'He is choking, not gagging, if he is SILENT: cannot cry, cannot '
          'cough properly, may be going blue round the lips, face frightened '
          'and no sound. If he is coughing loudly or crying, he has an airway: '
          'do not slap his back, let him cough, stay with him.',
          kind: PpCalloutKind.safety,
          title: 'First: is it choking?',
        ),
        PpSteps([
          PpStep('Shout for help and have someone call an ambulance',
              'You start at the same time. Do not go looking for a phone '
                  'first.'),
          PpStep('Under one: lay him face down along your forearm',
              'Head lower than his bottom, your hand supporting his jaw, not '
                  'his throat. Rest your arm on your thigh.'),
          PpStep('Five firm back blows',
              'Heel of your hand between the shoulder blades. Firm, and '
                  'check after each one whether it has come out.'),
          PpStep('If not: turn him face up, five chest thrusts',
              'Two fingers on the breastbone just below the nipple line, '
                  'pushing down sharply. Not the tummy in a baby.'),
          PpStep('Repeat: five back blows, five chest thrusts',
              'Until it comes out, or he goes limp.'),
          PpStep('Over one: back blows, then abdominal thrusts',
              'Lean him forward, five back blows. If not, stand behind him, '
                  'fist above the navel, pull sharply in and up, five times. '
                  'Repeat.'),
          PpStep('If he goes limp: start CPR and keep the phone on speaker',
              'The ambulance call handler will talk you through it.'),
        ], heading: 'The sequence'),
        PpCallout(
          'After any choking where you had to act, take him to a hospital '
          'to be checked even if he seems completely fine. Abdominal thrusts '
          'can injure; anything that went down the wrong way can too.',
          kind: PpCalloutKind.doctor,
          title: 'Afterwards, always',
        ),
        PpWhenLine('Learn it before the first finger food, around 8 months. A '
            'hospital first-aid class takes one afternoon. Do it.'),
        PpIndiaNote('Whoever is most often alone with him at mealtimes, the '
            'maid, the grandmother, the older cousin, is the person who most '
            'needs to have watched this. Show them, do not tell them.'),
        PpLink(
          'Gagging vs choking',
          pageId: 'safety_gagging',
          blurb: 'Six slides so you know the difference before it matters.',
        ),
        PpLink(
          'Health, the whole section',
          surfaceId: 'pp_section/parenting_health',
          blurb: 'First-aid depth, and everything after an emergency.',
        ),
      ],
    ),
    */
    // ⚠️ [new] CAROUSEL. "Gagging is normal and noisy; choking is silent.
    // Stops the panic and teaches the real emergency."
    PpPage(
      id: 'safety_gagging',
      title: 'Gagging vs choking',
      format: 'CAROUSEL',
      blocks: [
        PpCarousel(
          eyebrow: 'Gagging vs choking',
          hue: 8,
          coverTitle: 'Noisy is fine. Silent is the emergency.',
          coverBlurb: 'The one difference that stops the panic at the table.',
          cards: [
            PpCarouselCard(
                'Gagging is loud. Your child retches, eyes water, the face '
                    'goes red, and it sorts itself out.',
                'It is a protective reflex, and very common while learning '
                    'to eat.'),
            PpCarouselCard(
                'A gag reflex sits far forward in a baby\'s mouth. It fires '
                    'early on purpose.',
                'It moves back with age. Gagging at eight months is the body '
                    'doing its job, not a sign the food was wrong.'),
            PpCarouselCard(
                "During a gag, do nothing. Don't pull the food out. Don't "
                    'slap the back.',
                'Stay calm and let your child work it forward. A finger in '
                    'the mouth can push it deeper.'),
            PpCarouselCard(
                'Choking is silent. No cry, no proper cough, a frightened '
                    'face, and maybe blue round the lips.',
                'Silence is the signal. This is the one you act on, now.'),
            PpCarouselCard.linked(
                'If your child is silent: back blows, chest thrusts, and '
                    'someone calling an ambulance at the same time.',
                'Swipe up for the steps and the film. Learn them before '
                    'the first finger food.',
                pageId: 'safety_choking_response'),
            PpCarouselCard.linked(
                'Most choking can be avoided. It comes down to a short list '
                    'of shapes and a short list of situations.',
                'Round, firm and coin-shaped is the danger. Swipe up for how '
                    'to cut it.',
                pageId: 'safety_choking'),
          ],
        ),
      ],
    ),
    // ⚠️ [new] ARTICLE. "India-relevant (indoor babies, exclusive
    // breastfeeding). Iron is covered; Vitamin D is not."
    //
    // REQUIRED_REVIEW: the 400 IU figure and the "most exclusively breastfed
    // babies" statement, against current IAP guidance.
    PpPage(
      id: 'safety_vitamin_d',
      title: 'Vitamin D and supplements',
      format: 'ARTICLE',
      blocks: [
        PpIntro('India has plenty of sun, and still a lot of low vitamin D, '
            'especially in babies. It is the one supplement most babies here '
            'are advised to take, and the one most often forgotten.'),
        PpArticle([
          'Vitamin D is made in the skin from sunlight, and it lets the body '
              'use calcium for bones. Breast milk carries very little of it. '
              'Most Indian babies spend the first months indoors, away from '
              'the heat. So an exclusively breastfed baby can run short, '
              'without anyone doing anything wrong.',
          'That is why most paediatricians in India start breastfed babies on '
              'vitamin D drops in the first weeks, usually about 400 IU a '
              'day. Many continue through the first year. Formula is fortified, so a '
              'fully formula-fed baby taking enough usually needs no extra. '
              "Ask, don't guess.",
          'Sun helps, but not the way it is usually done. Ten to fifteen '
              'minutes of gentle morning sun on arms and legs a few times a '
              'week is useful. Midday sun on a baby is not. It burns long '
              'before it does anything for bones.',
          'Iron is the other one worth knowing about, and it has its own '
              'page. Beyond vitamin D and iron, a healthy baby on milk and then '
              "a varied diet doesn't need multivitamins, tonics or growth "
              'powders, whatever the chemist shelf says.',
        ]),
        PpCards([
          PpCard('Vitamin D drops', 'From the first weeks, if breastfed. Dose from the doctor.'),
          PpCard('Iron', 'From about 6 months through food, sometimes drops. Doctor decides.'),
          PpCard('Multivitamin tonics and growth powders', 'Not needed for a healthy baby. Mostly marketing.'),
          PpCard('Calcium', 'Comes from milk and, later, curd and dal. Rarely needed extra.'),
        ], heading: "What's worth giving, and what isn't", hue: 8),
        PpCallout('A supplement is a doctor decision, including the dose and '
            'how long. The bottle from the chemist is not the prescription.'),
        PpWhenLine('Vitamin D from the first weeks through the first year for '
            'most breastfed babies. Review at each vaccination visit.'),
        PpIndiaNote('Massage in the morning sun on the balcony is a tradition '
            'that turns out to be just right. Keep it to early sun, not the '
            'noon glare.'),
        PpLink(
          'Iron and the nutrients that matter',
          pageId: 'safety_iron',
          blurb: 'The other supplement question, answered.',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpArticle(heading: 'Does my child need a multivitamin?', [
          "Most toddlers eating a varied diet don't need a multivitamin. "
              'Vitamin D is the common exception in India, and iron if a '
              "doctor finds anaemia. A fussy week or two doesn't need a "
              'supplement.',
          'Give a supplement only on your doctor\'s advice, at the dose they '
              'give. Gummy vitamins look like sweets, so store them out of '
              'reach. Too much iron or vitamin A is dangerous.',
        ]),
      ],
    ),
  ],
);
