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
    blurb: 'Tastes, not meals. Milk is still most of what he lives on.',
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
    blurb: 'Family food, cow milk, and an appetite that halves overnight.',
  ),
  PpBand(
    id: 'big',
    label: '2 years and older',
    fromMonths: 24,
    toMonths: 216,
    blurb: 'Opinions, refusals, and eating what the house eats.',
  ),
]);

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpFeedingSection = PpSection(
  id: 'parenting_feeding', // MUST match the hub's bracketId.
  title: 'Feeding',
  intro: 'Milk, first foods, and the week he decides rice is the enemy.',
  bandSet: kPpFeedingBands,
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
      label: 'Can he eat this?',
      blurb: 'Type a food, get a straight answer for his age. Honey, cow milk, '
          'nuts, salt, the lot.',
      surfaceId: 'pp_baby_food_check',
      icon: Icons.search_outlined,
    ),
    // ⚠️ NEW SURFACE. Reads the chart pages in Area 4 rather than holding a
    // second copy of the numbers. Two copies of a feeding chart is two answers
    // to the same question.
    PpSectionTool(
      label: 'What to feed at this age',
      blurb: 'His age in, a day of food out. Veg and non-veg, with regional '
          'swaps.',
      surfaceId: 'pp_food_chart',
      icon: Icons.event_note_outlined,
    ),
    // ⚠️ REUSED, NOT REBUILT. `pp_feeding` is the existing Feeding Journey
    // (feeding_journey_screen.dart + FeedingStore). It is already non-gamified
    // and already reads the child's age. A second feed log would split one
    // baby's feeds across two stores.
    PpSectionTool(
      label: 'Log his feeds',
      blurb: 'A light record of feeds, bottles and solids, so a pattern can '
          'show itself. No scores, no streaks.',
      surfaceId: 'pp_feeding',
      icon: Icons.edit_note_outlined,
    ),
    PpSectionTool(
      label: 'Recipes for him',
      blurb: 'Every baby and toddler recipe in the app, filtered by age, '
          'texture and what you have in the kitchen.',
      surfaceId: 'pp_food',
      icon: Icons.restaurant_outlined,
    ),
    PpSectionTool(
      label: 'Track his growth',
      blurb: 'Weight and height over time, plotted properly, so "is he too '
          'thin" has an actual answer.',
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
  blurb: 'Latch, supply, pumping, and every problem that actually happens.',
  hue: 206,
  pages: [
    PpPage(
      id: 'bf_latch',
      title: 'Getting the latch right',
      subtitle: 'The one thing that fixes most of the rest',
      format: 'STEP-LIST',
      bands: ['milk', 'first_foods'],
      blocks: [
        PpIntro('A good latch is the difference between feeding that hurts and '
            'feeding that does not. It is a skill, not an instinct, and most '
            'mothers learn it over the first two weeks rather than in the '
            'first hour.'),
        PpSteps([
          PpStep('Hold him tummy to tummy',
              'Ear, shoulder and hip in one line, his whole body turned towards '
              'you. A baby who has to twist his head cannot swallow easily.'),
          PpStep('Nose to nipple, not mouth to nipple',
              'Line your nipple up with his nose so he has to tip his head back '
              'to reach it. That tilt is what makes his mouth open wide.'),
          PpStep('Wait for the wide mouth',
              'Brush your nipple along his upper lip and wait. When his mouth '
              'opens like a yawn, bring him on in one movement.'),
          PpStep('Bring baby to breast, never breast to baby',
              'Leaning forward to post your breast into his mouth gives a '
              'shallow latch and a sore back by day three.'),
          PpStep('Chin in first, more areola showing above than below',
              'His chin presses into the breast, his nose stays clear, and his '
              'lips flare outwards rather than tucking in.'),
          PpStep('Check what you can hear',
              'Slow, deep swallows with a soft ka sound. Clicking or smacking '
              'usually means the latch has slipped and it is worth taking him '
              'off and starting again.'),
        ], heading: 'A deep latch, step by step'),
        PpCallout('Feeding should feel like a strong tug, not a pinch or a '
            'bite. Sharp pain that lasts the whole feed is a latch problem, not '
            'something to get used to.'),
        PpWhenLine('From the very first feed. If it still hurts on day five, '
            'have someone watch a whole feed rather than waiting it out.'),
        PpIndiaNote('In a joint family you will often be handed advice mid-feed '
            'by three people at once. You are allowed to say you are still '
            'learning and ask for the room. Feeding badly in front of an '
            'audience is harder than feeding badly alone.'),
        PpVideoSlot(
          title: 'A lactation counsellor shows a deep latch',
          subtitle: 'Filmed on a real mother and a real two-week-old, from two '
              'angles, with the common mistakes shown alongside.',
          minutes: '7 MIN',
          slotId: 'feeding/latch_demo',
        ),
        PpLink(
          'Log his feeds',
          surfaceId: 'pp_feeding',
          blurb: 'Sides, times and how long, so you are not counting in your '
              'head at 3am.',
        ),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For a latch that still hurts after a week, or when you have '
              'tried everything on this page and want a trained pair of eyes on '
              'a real feed rather than more reading.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
      ],
    ),
    PpPage(
      id: 'bf_positions',
      title: 'Positions that actually work',
      format: 'CARDS',
      bands: ['milk', 'first_foods'],
      blocks: [
        PpIntro('There is no correct position, only the one that gets a deep '
            'latch without wrecking your shoulders. Most mothers use two or '
            'three depending on the time of day.'),
        PpCards([
          PpCard('Cradle hold',
              'The classic. His head rests in the crook of the arm on the same '
              'side as the breast. Easy once feeding is established, harder in '
              'the first fortnight because you have less control of his head.'),
          PpCard('Cross cradle',
              'Opposite arm supports him, your hand at the base of his neck. '
              'The best one for learning, because you can steer his head onto '
              'the breast rather than hoping.'),
          PpCard('Rugby or football hold',
              'He tucks under your arm along your side, feet behind you. Very '
              'good after a caesarean because nothing rests on the scar, and '
              'good for twins.'),
          PpCard('Side lying',
              'Both of you on your sides, facing each other. This is the one '
              'that saves the night feeds. Keep pillows and quilts away from '
              'his face and read the safe-sleep page before you drift off.'),
          PpCard('Laid back or biological nurturing',
              'You semi-reclined, him on your chest, gravity holding him on. '
              'Often sorts out a shallow latch on its own without anyone '
              'correcting anything.'),
        ], heading: 'Five that cover almost everything', hue: 206),
        PpCallout('Support the baby, not the breast. If you are holding your '
            'breast in place for the entire feed, he is not latched deeply '
            'enough to stay on by himself.'),
        PpWhenLine('Try a new position whenever a feed is going badly, and any '
            'time one part of the breast is staying full.'),
        PpIndiaNote('A firm cushion or a rolled-up razai across your lap does '
            'the same job as a nursing pillow. Get his mouth level with the '
            'nipple before you start, so you are not hunching down to him.'),
        PpLink(
          'Nursing pillows and feeding chairs',
          surfaceId: 'pp_products',
          blurb: 'What is worth buying and what a cushion already does.',
        ),
      ],
    ),
    PpPage(
      id: 'bf_how_often',
      title: 'How often, and how much',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Almost every worry here comes from not being able to see how '
            'much went in. A bottle has markings. A breast does not, so you '
            'read the baby instead.'),
        PpArticle([
          'A newborn feeds on demand, which in practice means eight to twelve '
              'times in twenty four hours, sometimes more. Feeds are not evenly '
              'spaced, and a run of feeds close together in the evening is '
              'normal rather than a sign that your milk has run out.',
          'Feed when he asks. Early hunger cues are rooting, turning his head, '
              'sucking his hands and getting restless. Crying is a late cue, '
              'and a crying baby latches worse, so catching him before that '
              'makes the feed easier for both of you.',
          'Length is not a measure of anything. Some babies finish in eight '
              'minutes and some take forty, and both can be feeding perfectly '
              'well. Let him finish one side properly before offering the '
              'second, because the milk at the end of a side is the richest '
              'part of the feed.',
          'What tells you he is getting enough is the other end. Steady wet '
              'nappies, weight coming back up after the normal first-week dip, '
              'and a baby who lets go looking drunk and satisfied rather than '
              'frantic.',
        ]),
        // REQUIRED_REVIEW: nappy counts and the day-5 threshold. Standard
        // paediatric guidance, but confirm the exact figures and wording with a
        // paediatrician before ship.
        PpChartCard(
          title: 'Is he getting enough?',
          subtitle: 'The signs you can actually see',
          rows: [
            ('Feeds in 24 hours', '8 to 12 in the early weeks'),
            ('Wet nappies from day 5', '6 or more, pale and odourless'),
            ('Dirty nappies from day 5', '3 or more, soft and yellow'),
            ('Weight', 'Back to birth weight by about 2 weeks'),
            ('After a feed', 'Relaxed hands, sleepy, lets go on his own'),
          ],
          note: 'Weight and nappies together are the honest answer. How full '
              'your breast feels is not, and it stops being a signal at all '
              'once supply settles around 6 weeks.',
        ),
        PpCallout('You cannot overfeed a breastfed baby. He stops when he is '
            'done, and a baby who wants the breast an hour after a feed is '
            'usually thirsty, hot or wanting you, not starving.'),
        PpWhenLine('On demand for the first 6 months. Feeds space themselves '
            'out on their own, usually somewhere between 6 and 12 weeks.'),
        PpIndiaNote('You will be told to give ghutti, gripe water, honey or '
            'plain water in the first weeks. None of it is needed and honey is '
            'genuinely unsafe before one year. Breast milk or formula is the '
            'whole diet until 6 months, water included.'),
        PpCallout(
          'See your paediatrician if he is not back to birth weight by two '
          'weeks, has fewer wet nappies than the chart, is too sleepy to '
          'finish feeds, or has a dry mouth and sunken soft spot. Poor weight '
          'gain is treatable and it is easiest to treat early.',
          kind: PpCalloutKind.doctor,
          title: 'When feeding needs a doctor, not more patience',
        ),
        PpLink(
          'Log his feeds',
          surfaceId: 'pp_feeding',
          blurb: 'A few days of records makes the pattern obvious.',
        ),
      ],
    ),
    PpPage(
      id: 'bf_supply',
      title: 'Making enough milk, and keeping it',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Milk supply runs on one rule: milk removed is milk made. '
            'Almost every real fix comes back to that sentence, and almost '
            'every product sold for supply does not.'),
        PpArticle([
          'Your body works out how much to make from how much leaves. Feed '
              'often and empty the breast well, and it makes more. Skip feeds, '
              'top up heavily with formula without pumping, or let a feed run '
              'short because the latch is shallow, and it quietly makes less.',
          'The first two weeks set the baseline, which is why frequent feeding '
              'early matters more than anything you eat or drink. After about '
              'six weeks supply settles, breasts stop feeling engorged, and '
              'many mothers read that softness as losing their milk. It is the '
              'opposite: it means supply has matched demand.',
          'Growth spurts look like supply failure and are not. He feeds '
              'constantly for two or three days, seems never satisfied, and '
              'then goes back to normal with more milk available than before. '
              'That is the system working, out loud.',
          'Things that genuinely help: feeding or pumping more often, fixing '
              'the latch, keeping him on the first side until he lets go, '
              'skin to skin, and sleeping when you can. Things that mostly do '
              'not: expensive supplements, and worrying.',
        ]),
        PpCallout('If you want to build supply, add a feed or a pump, not a '
            'supplement. Nothing raises supply the way removing more milk does.'),
        PpCallout(
          'Soft breasts do not mean empty breasts. Around six weeks your body '
          'stops overproducing and starts making what he actually takes, so '
          'the engorged feeling goes. Almost every mother reads that as losing '
          'her milk, and it is the opposite.',
          kind: PpCalloutKind.myth,
          title: 'My breasts feel empty, so my milk has gone',
        ),
        PpWhenLine('Supply is most responsive in the first 6 weeks and stays '
            'adjustable throughout. It is rarely too late to build it back up.'),
        PpIndiaNote('Traditional galactagogues like methi, shatavari, ajwain, '
            'garlic and gond ke laddoo are widely used and are generally safe '
            'in food quantities. They are worth having if the family is '
            'feeding you them with love. They work best alongside more feeding, '
            'not instead of it, and anything in tablet form is worth running '
            'past your doctor first.'),
        PpLink(
          'It feels like I am not making enough',
          pageId: 'bf_low_supply',
          blurb: 'The full page, including how to tell real low supply from '
              'the far more common false alarm.',
        ),
      ],
    ),
    PpPage(
      id: 'bf_diet',
      title: 'What you eat while you are nursing',
      format: 'CARDS',
      blocks: [
        PpIntro('The list of foods a nursing mother must avoid is much shorter '
            'than the one your family will give you. Here is the honest '
            'version.'),
        PpCards([
          PpCard('Alcohol',
              'Passes into milk. If you drink, feed first and then wait about '
              'two hours per drink before the next feed. You do not need to '
              'pump and throw milk away, time does the work.'),
          PpCard('Caffeine',
              'Fine in ordinary amounts, roughly two to three cups of tea or '
              'coffee a day. A very young baby clears it slowly, so if he is '
              'unusually wakeful, cut back and see.'),
          PpCard('Large predatory fish',
              'Shark, swordfish and king mackerel carry more mercury. Ordinary '
              'Indian fish like rohu, pomfret and small mackerel are fine and '
              'genuinely good for both of you.'),
          PpCard('Anything he clearly reacts to',
              'A small number of babies react to dairy or soy in your diet with '
              'blood in the stool, bad reflux or a rash. That is uncommon, and '
              'it is worth a doctor rather than a guessing game of cutting '
              'foods out one by one.'),
          PpCard('Your own medicines',
              'Most common medicines are compatible with feeding, including '
              'paracetamol and most antibiotics. Check with your doctor or '
              'pharmacist rather than stopping feeds on your own.'),
        ], heading: 'The genuine cautions', hue: 206),
        PpCards([
          PpCard('Cold foods, curd and rice',
              'Curd, rice, cold water and bananas do not cause the baby a cold. '
              'Nothing you eat lowers his immunity through milk.'),
          PpCard('Spice, garlic and masala',
              'Flavours do reach the milk, and that is a good thing. Babies '
              'exposed to family flavours early tend to accept them more '
              'easily at six months.'),
          PpCard('Gassy vegetables',
              'Rajma, gobi and chana do not pass gas into milk. Gas is not a '
              'nutrient and does not travel that way.'),
          PpCard('A restricted diet',
              'Cutting out food groups on a hunch usually leaves you '
              'undernourished and exhausted, which is the last thing supply '
              'needs. Eat properly and eat enough.'),
        ], heading: 'What you can safely ignore', hue: 206),
        PpCallout('You need roughly an extra meal a day and a lot of water. '
            'Keep a filled bottle where you feed, because thirst arrives the '
            'moment he latches and nobody is going to fetch it for you.'),
        PpWhenLine('Applies for as long as you are nursing, at any age.'),
        PpIndiaNote('Fasting during Navratri, Karva Chauth or Ramzan while '
            'nursing is a personal decision and many mothers do it. If you do, '
            'keep fluids up in the permitted hours, eat properly at both ends, '
            'and treat dizziness or a sharp drop in milk as a reason to stop '
            'that day. Most religious traditions already exempt a nursing '
            'mother.'),
      ],
    ),
    PpPage(
      id: 'bf_pumping',
      title: 'Pumping when you go back to work',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Going back to work does not have to end breastfeeding. It does '
            'take a plan, a pump, and somewhere passable to sit for fifteen '
            'minutes twice a day.'),
        PpArticle([
          'Start about two to three weeks before you go back, not the night '
              'before. Pump once a day after a morning feed, when supply is '
              'highest, and freeze what you get. A small stash takes the panic '
              'out of the first week and lets whoever is minding him practise '
              'with a bottle while you are still around.',
          'At work, aim to pump roughly as often as he would have fed, which '
              'for most mothers is two or three times across the day. Missing '
              'sessions regularly is the thing that drops supply, so the '
              'sessions matter more than how much comes out of any one of them.',
          'Hand expression is a real skill and worth learning, because it needs '
              'no power, no privacy and no equipment. Many mothers get more '
              'with hands than with a pump, and combining the two gets the most.',
          'Feed him directly whenever you are together, mornings, evenings and '
              'weekends. Direct feeds keep supply up better than any pump, and '
              'they are how a lot of mothers keep going for a year on two '
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
          note: 'Warm it by standing the bottle in hot water. Never in a '
              'microwave, which heats unevenly and can scald his mouth from a '
              'bottle that feels fine on your wrist.',
        ),
        PpCallout('Label every bag or bottle with the date before it goes in '
            'the freezer, and use the oldest first. Ten minutes of labelling '
            'saves a month of guessing.'),
        PpWhenLine('Start building a stash 2 to 3 weeks before you return. '
            'Introduce the bottle around 4 to 6 weeks if you can, once feeding '
            'at the breast is comfortable.'),
        PpIndiaNote('Indian offices rarely have a feeding room. A locked cabin, '
            'a first-aid room or the accessible washroom lobby is what most '
            'mothers end up using. Under the Maternity Benefit Act you are '
            'entitled to nursing breaks, and establishments above a certain '
            'size are required to provide a creche. It is worth asking HR in '
            'writing before your first day back.'),
        PpVideoSlot(
          title: 'Hand expression and pumping, shown properly',
          subtitle: 'How to hold the flange, how to hand express, and how to '
              'combine the two for more milk in less time.',
          minutes: '9 MIN',
          slotId: 'feeding/pumping_demo',
        ),
        PpLink(
          'Pumps, storage bags and nursing bras',
          surfaceId: 'pp_products',
          blurb: 'Manual against electric, flange size, and what you can skip.',
        ),
        PpLink(
          'Compare breast pumps',
          surfaceId: 'pp_product_guide',
          blurb: 'What matters, what to ignore, and the mistake most people '
              'make choosing one.',
        ),
      ],
    ),
    PpPage(
      id: 'bf_low_supply',
      title: 'It feels like I am not making enough',
      format: 'ARTICLE',
      blocks: [
        PpIntro('This is the most common reason mothers stop feeding, and most '
            'of the time supply is fine and something else is going on. Both '
            'halves of that sentence matter, so here is how to tell.'),
        PpArticle([
          'Soft breasts, a baby who feeds often, short feeds, a baby who cries '
              'in the evening, and getting very little out with a pump are all '
              'things mothers read as low supply. None of them is evidence. '
              'Breasts soften when supply settles, pumps are much worse at '
              'removing milk than a baby, and evening fussiness happens on '
              'full supply too.',
          'What is evidence is weight and nappies. If he is gaining steadily '
              'and has plenty of pale wet nappies, you are making enough, '
              'whatever it feels like. If he is not gaining, or nappies have '
              'dropped off, that is real and needs looking at rather than '
              'pushing through.',
          'When supply genuinely is low, the usual causes are fixable: a '
              'shallow latch removing little milk, feeds being capped by the '
              'clock, heavy formula top ups without pumping, a tongue tie, '
              'severe blood loss at delivery, retained placenta or a thyroid '
              'problem. That is a list for a doctor and a lactation consultant, '
              'not for a supplement shelf.',
          'The rebuild is unglamorous and it works. Feed more often, get the '
              'latch checked, keep him on the first side until he lets go, add '
              'a pump after a couple of feeds, and do a day or two of skin to '
              'skin with very little clothing between you. Supply usually '
              'responds inside a week.',
        ]),
        PpCallout('If you are topping up with formula, keep pumping at the same '
            'time. Milk not removed is the signal to make less, and that is how '
            'a temporary top up quietly becomes a permanent one.'),
        PpWhenLine('Act within a week of noticing rather than waiting a month. '
            'Supply is much easier to rebuild early.'),
        PpIndiaNote('Being told you have no milk, by a relative, on day three, '
            'is almost a rite of passage. Day three is before the milk has '
            'properly come in. It is not a verdict.'),
        PpCallout(
          'See your paediatrician if he is losing weight or not gaining, if '
          'wet nappies drop below six a day after the first week, or if he is '
          'listless and hard to wake. Ask your own doctor about thyroid and '
          'anaemia if supply never established at all.',
          kind: PpCalloutKind.doctor,
          title: 'When low supply needs medical help',
        ),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For a mother who has been told she has low supply and wants '
              'someone to check whether that is actually true, watch a real '
              'feed, and build a plan that does not start with giving up.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
      ],
    ),
    PpPage(
      id: 'bf_oversupply',
      title: 'Too much milk, and a baby who splutters',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Oversupply gets no sympathy and is genuinely miserable. He '
            'chokes, pulls off, cries at the breast, and you leak through '
            'everything you own.'),
        PpArticle([
          'The signs are fairly clear. He latches, gulps, splutters and comes '
              'off crying within a minute. He may be windy, arch away, and pass '
              'green frothy stools. Your breasts refill fast and stay hard, and '
              'milk sprays across the room when he lets go.',
          'What is happening is a forceful letdown plus more milk than he '
              'needs. He fills up on the watery milk at the start of a side '
              'without reaching the fattier milk at the end, which is why the '
              'stools go green and why he seems hungry again quickly.',
          'The fix is counter-intuitive: take less milk out, not more. Feed '
              'from one side per feed, or per two-hour block, so that side gets '
              'thoroughly drained and the other one gets the message to slow '
              'down. Express just enough from the unused side for comfort, not '
              'until it is empty.',
          'Lean back while feeding so he is above the flow rather than under '
              'it, and let the first strong letdown spray into a cloth before '
              'latching him on. Most oversupply settles within a few weeks '
              'once the one-side pattern starts.',
        ]),
        PpCallout('Do not pump to relieve the pressure unless you are '
            'genuinely uncomfortable. Every extra pump tells your body to keep '
            'making the amount you are struggling with.'),
        PpWhenLine('Most common in the first 6 to 12 weeks and usually settled '
            'by 3 months.'),
        PpIndiaNote('Nursing pads and a spare kurta at work are the practical '
            'half of this. Cotton pads washed and dried in the sun work as well '
            'as disposables and cost nothing.'),
        PpCallout(
          'See a doctor if the breast becomes hot, red and painful with fever '
          'and body aches. Repeated blocked ducts on the back of oversupply '
          'can tip into mastitis, and that needs treating rather than waiting '
          'out.',
          kind: PpCalloutKind.doctor,
          title: 'When oversupply turns into something else',
        ),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For a forceful letdown that is making every feed a fight, '
              'when one-sided feeding has not settled it in a fortnight and you '
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
      format: 'ARTICLE',
      blocks: [
        PpIntro('A blocked duct is a sore lump. Mastitis is that lump plus '
            'fever and feeling like you have been hit by a truck. The second '
            'one moves fast, so this page is worth reading before you need it.'),
        PpArticle([
          'A blocked duct is a tender, firm patch in one breast, usually with '
              'no fever and no red streak. It happens when milk is not moving '
              'out of one part of the breast, often after a long gap, a tight '
              'bra, sleeping on that side, or a shallow latch.',
          'Mastitis is inflammation of the breast tissue, with or without '
              'infection. The breast goes red, hot and painful in a wedge '
              'shape, and you get fever, chills and aching like flu. It can go '
              'from mildly annoying to properly ill within hours.',
          'For both, keep the milk moving. Feed from that side often, aim his '
              'chin towards the lump, and use gentle massage towards the '
              'nipple rather than the deep digging that gets recommended. '
              'Vigorous massage makes inflammation worse. Cold packs between '
              'feeds settle swelling, and brief warmth just before a feed helps '
              'letdown.',
          'Rest, fluids and paracetamol or ibuprofen are part of the treatment, '
              'not an optional extra. Both are compatible with feeding. Keep '
              'feeding throughout, including from the affected side. The milk '
              'is safe for him and stopping makes everything worse.',
        ]),
        PpCallout('Do not stop feeding from the painful side. Emptying that '
            'breast is the treatment, and letting it stay full is what turns a '
            'blocked duct into mastitis.'),
        PpWhenLine('Can happen any time you are feeding, most often in the '
            'first 3 months and again during weaning.'),
        PpIndiaNote('Tight bras, dupattas knotted across the chest and a heavy '
            'saree pallu all press on the same spot for hours. If you keep '
            'getting a block in the same place, look at what is pressing there '
            'rather than at your milk.'),
        PpCallout(
          'Call your doctor the same day if you have fever above 38.5C, red '
          'streaks spreading across the breast, or symptoms that have not '
          'improved in 24 hours of feeding and rest. Mastitis often needs '
          'antibiotics, and an untreated abscess needs a hospital. Go sooner '
          'rather than later.',
          kind: PpCalloutKind.doctor,
          title: 'This one has a clock on it',
        ),
        // REQUIRED_REVIEW: the 38.5C threshold and the 24-hour window. Confirm
        // both with a clinician, and confirm the current guidance on massage,
        // which changed recently away from deep massage.
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For repeated blocked ducts or a second bout of mastitis, '
              'when you want someone to find the cause rather than treat the '
              'same lump again.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
      ],
    ),
    PpPage(
      id: 'bf_cracked',
      title: 'Sore and cracked nipples',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Nipple pain is the single most common reason feeding stops in '
            'the first month. It is also, almost always, a fixable mechanical '
            'problem rather than something you have to tolerate.'),
        PpArticle([
          'Some tenderness in the first few days is normal. Pain that lasts '
              'through the whole feed, cracks, bleeding, or nipples that come '
              'out flattened, creased or lipstick shaped are not. They mean the '
              'latch is shallow and he is compressing the nipple against his '
              'hard palate instead of drawing it deep.',
          'Fix the latch first, because nothing else works while the cause is '
              'still happening. Get his mouth wider, his chin deeper, more '
              'areola in his mouth below than above. If it hurts once he is on, '
              'break the seal with a clean finger and start again rather than '
              'enduring the feed.',
          'For healing, express a few drops of your own milk and let them dry '
              'on the nipple, then a purified lanolin or a plain paraffin '
              'ointment that does not need washing off. Keep the area dry '
              'between feeds and change nursing pads as soon as they are damp.',
          'If the pain is burning, deep, and continues after the feed ends, '
              'with shiny pink nipples or white patches in his mouth, thrush is '
              'the likely cause and both of you need treating at once. A tongue '
              'tie is the other common cause when the latch looks right and '
              'still hurts.',
        ]),
        PpCallout('You can keep feeding on a cracked nipple. If it is too '
            'painful, express from that side for a day or two to protect '
            'supply and let it heal, rather than skipping the milk removal.'),
        PpWhenLine('Most common in the first 2 weeks. Pain that is still there '
            'at day 7 needs someone to watch a feed.'),
        PpIndiaNote('Traditional advice to apply coconut oil or ghee is common '
            'and is not harmful, but it does not heal a crack caused by a bad '
            'latch. Wipe anything oily off before a feed and fix the latch '
            'either way.'),
        PpCallout(
          'See a doctor or a lactation consultant if the crack is deep or '
          'bleeding heavily, if there is pus or spreading redness, or if pain '
          'is burning and continues between feeds. Thrush and tongue tie both '
          'need diagnosing rather than guessing.',
          kind: PpCalloutKind.doctor,
          title: 'When sore nipples need someone to look',
        ),
        PpLink(
          'Nipple cream and nursing pads',
          surfaceId: 'pp_products',
          blurb: 'Purified lanolin, plain ointments, and what the difference '
              'actually is.',
        ),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For nipple pain that has lasted more than a week, or a latch '
              'that looks textbook and still hurts, which usually means '
              'something a video cannot see.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
      ],
    ),
    PpPage(
      id: 'bf_biting',
      title: 'He has started biting',
      format: 'ARTICLE',
      bands: ['m8_12', 'tod', 'big'],
      blocks: [
        PpIntro('The first bite is a shock and usually makes you yelp, which '
            'many babies find hilarious. It is a phase, it has causes, and it '
            'does not have to end feeding.'),
        PpArticle([
          'A baby cannot bite while actively sucking, because his tongue covers '
              'his lower gums. Bites happen at the very start of a feed when he '
              'is not properly latched, or at the end when he is bored and '
              'still on the breast. That tells you when to watch.',
          'The usual reasons are teething, a blocked nose that makes feeding '
              'awkward, distraction, or simply experimenting with new teeth. '
              'Some babies bite when the milk flow slows and they want more.',
          'What works: stay calm and say a flat, quiet no. Break the suction '
              'and take him off for a minute, then offer again. Ending the feed '
              'briefly is the clearest message a baby of this age understands. '
              'A dramatic reaction can either frighten him off the breast '
              'entirely or turn it into a game.',
          'Prevent rather than punish. Watch for the moment his attention '
              'wanders at the end of a feed and take him off first. Offer '
              'something cold and chewable before the feed if he is teething, '
              'and feed somewhere quiet if he is at the stage of turning to '
              'look at every sound.',
        ]),
        PpCallout('Do not flick his cheek, tap him or shout. All three teach '
            'him that the breast is where unpleasant things happen, and a '
            'nursing strike is much harder to fix than a bite.'),
        PpWhenLine('Usually starts around 6 to 9 months with the first teeth, '
            'and generally passes within a few weeks.'),
        PpIndiaNote('You will hear that teeth mean it is time to stop feeding. '
            'They do not. Feeding to a year and well beyond is normal and '
            'recommended, teeth and all.'),
      ],
    ),
    PpPage(
      id: 'bf_refusing',
      title: 'He is refusing the breast',
      format: 'ARTICLE',
      blocks: [
        PpIntro('A baby who suddenly refuses to feed is frightening, and it is '
            'almost never a decision he has made about you. Something has made '
            'feeding uncomfortable and it is usually findable.'),
        PpArticle([
          'A nursing strike is a sudden refusal in a baby who was feeding fine. '
              'The common causes are a blocked nose, an ear infection, a sore '
              'mouth from teething or thrush, a change in how you smell after '
              'a new soap or deodorant, a strong reaction to a bite that '
              'startled him, or a stressful few days.',
          'Newborn refusal is different and more urgent. A baby in the first '
              'weeks who will not latch at all, or who is too sleepy to feed, '
              'needs checking rather than coaxing.',
          'While you work it out, keep milk moving and keep him fed. Express '
              'at least as often as he would have fed, and give that milk by '
              'spoon, katori or cup rather than heading straight to a bottle, '
              'which can make coming back to the breast harder.',
          'To coax him back: skin to skin with no pressure, offering when he is '
              'sleepy or just waking, feeding in a dark quiet room, feeding '
              'while walking or rocking, and a warm bath together. Most strikes '
              'end within two to five days.',
        ]),
        PpCallout('Offer, do not force. Pushing a baby onto the breast while he '
            'arches away builds an association you then have to undo. Stop, '
            'cuddle, and try again in twenty minutes.'),
        PpWhenLine('Can happen at any age. A strike usually resolves in 2 to 5 '
            'days. Genuine self-weaning before 12 months is rare.'),
        PpIndiaNote('If he started refusing after being fed a bottle at the '
            'creche or by a relative, it is flow preference rather than '
            'rejection. Ask for paced bottle feeding, held upright with a slow '
            'teat, so the bottle stops being the easier option.'),
        PpCallout(
          'See your paediatrician the same day if a newborn will not feed at '
          'all, if he is pulling at one ear, has a fever, has fewer wet '
          'nappies, or seems floppy and hard to rouse. Refusal plus any of '
          'those is a sign of illness and not a phase.',
          kind: PpCalloutKind.doctor,
          title: 'When refusing to feed means he is unwell',
        ),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For a strike that has lasted more than a few days, or a '
              'newborn who has never latched properly, when you want help '
              'today rather than another article.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
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
  blurb: 'Honest answers, no guilt, and how to prepare a bottle safely.',
  hue: 32,
  pages: [
    PpPage(
      id: 'formula_fed_is_fine',
      title: 'Fed is fine, and that is not a consolation prize',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('If you are reading this at 2am feeling like you failed, start '
            'here. A fed baby, by whatever route, is the outcome that matters, '
            'and this page is not going to spend three paragraphs on breast '
            'being best before it says so.'),
        PpArticle([
          'Mothers use formula for every reason there is. Supply that never '
              'established, a baby who never latched, medication, surgery, '
              'adoption, twins, returning to work at six weeks, a mother whose '
              'mental health was collapsing under round-the-clock feeding, and '
              'mothers who simply chose it. Every one of those is a real '
              'reason and none of them owes anybody an explanation.',
          'Formula in India is regulated and nutritionally complete. It is '
              'designed to be a full diet for the first six months, and it '
              'delivers the energy, protein, iron and vitamins a baby needs. '
              'What it does not contain is antibodies, which is a genuine '
              'difference and a small one against a baby who is fed, growing, '
              'and has a mother who is coping.',
          'Combination feeding is not half a failure. Plenty of families do '
              'some breast and some formula for months, and it is a stable, '
              'legitimate way to feed a baby rather than a stage on the way to '
              'giving up.',
          'The part nobody says out loud: guilt about feeding is heavier in '
              'India than almost anywhere, because it is delivered in person, '
              'daily, by people who love you. You are allowed to say he is '
              'feeding well and gaining, thank you, and then change the '
              'subject. You do not owe the room your medical history.',
        ]),
        PpCallout('Holding him close, eye contact, and feeding him yourself '
            'when you can are what build the bond people credit to the breast. '
            'A bottle held by his mother does all of that.'),
        PpWhenLine('Applies at any age. There is no point at which switching '
            'to or adding formula becomes a wrong decision.'),
        PpIndiaNote('Formula still carries stigma in a lot of Indian families, '
            'and a wet nurse or a relative feeding the baby is still suggested '
            'in some households. Cross-feeding is not recommended, because '
            'infections including HIV and hepatitis pass through breast milk. '
            'If you want donor milk, ask your hospital about a screened human '
            'milk bank rather than arranging it privately.'),
        PpVideoSlot(
          title: 'Three mothers on why they used formula',
          subtitle: 'No experts, no music, no apology. Just what happened and '
              'what they wish somebody had told them.',
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
        PpIntro('There is far less difference between formulas than the packs '
            'suggest. The composition of infant formula in India is regulated, '
            'so the floor is high and the marketing does most of the work.'),
        PpArticle([
          'Stage 1 is infant formula, for birth to six months. Stage 2 is '
              'follow-on formula, from six months. Stage 3 and toddler milks '
              'are growing-up drinks and are not needed at all once a child is '
              'on cow milk and family food. Start with stage 1 and stay there '
              'until six months.',
          'Almost every ordinary baby should be on a standard cows-milk-based '
              'formula. The specialist ones exist for real medical reasons: '
              'extensively hydrolysed and amino acid formulas for diagnosed '
              'cows milk protein allergy, lactose-free for diagnosed lactose '
              'intolerance, preterm formula for premature babies. Those are '
              'prescribed, not chosen off a shelf.',
          'Soy formula is not a first-line choice for a suspected milk allergy '
              'in a young baby, because many babies who react to cows milk '
              'protein also react to soy. If you think he is reacting, that is '
              'a paediatrician conversation before it is a shopping one.',
          'Powder, liquid concentrate and ready-to-feed all work. Powder is '
              'cheapest and is what most Indian families use. Ready-to-feed is '
              'sterile in the tin, which makes it the safer choice for a '
              'premature or unwell newborn, and it costs several times more.',
          'The one thing genuinely worth checking is the expiry date and an '
              'intact seal. Buy from a shop with real stock turnover rather '
              'than a dusty tin from a cheap online seller.',
        ]),
        PpCallout('A more expensive formula is not a better formula. The '
            'extras on the front of the tin have far less evidence behind them '
            'than the price difference suggests.'),
        PpWhenLine('Stage 1 from birth to 6 months. From 6 months you can '
            'continue stage 1 or move to stage 2, and either is fine. From 12 '
            'months, plain cow milk replaces formula for most children.'),
        PpIndiaNote('Chemists sometimes push whichever brand carries the best '
            'margin, and hospitals occasionally send you home with a tin of '
            'whatever was in the sample cupboard. Neither is a recommendation. '
            'Ask your paediatrician which type he needs, then buy on price.'),
        PpCallout(
          'Talk to your paediatrician before using any specialist formula, and '
          'before switching for a suspected allergy. Blood or mucus in the '
          'stool, poor weight gain, severe reflux or eczema that will not '
          'settle are all reasons to be seen rather than to change brands.',
          kind: PpCalloutKind.doctor,
          title: 'Specialist formula is a prescription, not a purchase',
        ),
      ],
    ),
    PpPage(
      id: 'formula_prepare',
      title: 'Making up a bottle safely',
      format: 'STEP-LIST',
      blocks: [
        PpIntro('This is the page with real stakes in it. Powdered formula is '
            'not sterile, so how you make the bottle matters as much as which '
            'tin it came from.'),
        PpSteps([
          PpStep('Wash your hands and the surface',
              'Soap and water, before you touch anything. This is the step '
              'people skip at 3am and it is the one that matters most.'),
          PpStep('Clean and sterilise the bottle and teat',
              'Scrub with a bottle brush and detergent, rinse, then sterilise '
              'by boiling for at least five minutes, by steam steriliser, or '
              'with sterilising solution. Every feed, until he is a year old.'),
          PpStep('Boil fresh water and let it cool for no more than 30 minutes',
              'It needs to still be hot, around 70C, because that is what '
              'kills the bacteria that can live in the powder. Water that has '
              'cooled to room temperature does not do this job.'),
          PpStep('Pour the water into the bottle first, then add the powder',
              'Water first, always. Powder first gives you a bottle that is '
              'too concentrated, and that is hard on his kidneys.'),
          PpStep('Use the scoop from that tin, levelled off',
              'That scoop belongs to that tin. Never pack it down, never heap '
              'it, and never add an extra scoop to make him sleep longer. Too '
              'strong is dangerous, too weak means he does not grow.'),
          PpStep('Cap it, shake, and cool it fast',
              'Hold the bottle under a running cold tap or stand it in a jug '
              'of cold water, keeping the water below the cap.'),
          PpStep('Test on the inside of your wrist',
              'It should feel just warm, not hot. Then feed within two hours '
              'and throw away whatever he leaves.'),
        ], heading: 'Seven steps, in this order'),
        // REQUIRED_REVIEW: the 70C water temperature, the 30-minute cooling
        // window, the 2-hour use-by for a made-up feed, and "sterilise until
        // 12 months". Standard, but confirm against current Indian paediatric
        // guidance, which differs in places from WHO wording.
        PpCallout(
          'Never dilute or strengthen a feed beyond the instructions on the '
          'tin. Extra powder to fill him up can dehydrate him and strain his '
          'kidneys. Extra water to make the tin last means he slowly '
          'undernourishes on a normal number of feeds. Follow the scoop.',
          kind: PpCalloutKind.safety,
          title: 'The ratio is not adjustable',
        ),
        PpCallout(
          'Do not save the leftovers of a feed he has drunk from, and do not '
          'reheat a bottle. Bacteria from his mouth multiply in warm milk. '
          'Throw away what is left after two hours and make a fresh one.',
          kind: PpCalloutKind.safety,
          title: 'One feed, one bottle',
        ),
        PpWhenLine('Every feed, from birth. Sterilising can usually stop at '
            'about 12 months, but thorough washing continues.'),
        PpIndiaNote('For travel, carry the measured powder in a dry dispenser '
            'and hot boiled water in a flask, and make the feed when you need '
            'it. Do not carry made-up bottles around in a bag for hours in '
            'Indian heat. If you must make one ahead, cool it fast, keep it at '
            'the back of the fridge, and use it within 24 hours.'),
        PpVideoSlot(
          title: 'Making up a bottle, step by step',
          subtitle: 'The real thing, in a normal Indian kitchen, including how '
              'to sterilise without a steriliser.',
          minutes: '6 MIN',
          slotId: 'feeding/formula_prep_demo',
        ),
      ],
    ),
    PpPage(
      id: 'formula_brands',
      title: 'Indian formula, compared honestly',
      subtitle: 'Review only. Nothing here is sponsored or sold.',
      format: 'COMPARISON TABLE',
      blocks: [
        PpIntro('This is here because the information is hard to find honestly '
            'and very easy to find in an advertisement. Nothing on this page '
            'is paid for, linked to a shop, or ranked by anything except what '
            'is in the tin.'),
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
              'Cows milk based, regulated composition. This is the default.',
            ],
            [
              'Stage 2 follow-on',
              'From 6 months, alongside solids',
              'Not necessary. Continuing stage 1 is equally fine.',
            ],
            [
              'Toddler or growing-up milk',
              'Marketed from 12 months',
              'Not needed. Plain cow milk and family food do the same job for '
                  'a fraction of the price.',
            ],
            [
              'Partially hydrolysed, sold as comfort',
              'Marketed for colic and fussiness',
              'Thin evidence. Not a treatment for allergy.',
            ],
            [
              'Extensively hydrolysed',
              'Diagnosed cows milk protein allergy',
              'Prescribed by a paediatrician. Tastes bitter, and babies do '
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
              'Rarely needed long term in babies. Usually temporary.',
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
            'and whether your local shop reliably stocks it. Running out at '
            '10pm is a worse problem than any difference between brands.'),
        PpWhenLine('Review this when he turns 6 months and again at 12 months, '
            'which is when most families can stop buying formula altogether.'),
        PpIndiaNote('Loose formula sold by weight, refilled tins and grey '
            'imports without Indian labelling are all worth avoiding. A sealed '
            'tin with an Indian label, a batch number and a readable expiry is '
            'the whole checklist.'),
        PpCallout(
          'Ask your paediatrician before moving to any specialist formula, and '
          'before stopping one he was prescribed. Changing an allergy formula '
          'on your own can restart the symptoms you spent weeks settling.',
          kind: PpCalloutKind.doctor,
          title: 'The specialist ones are a doctor decision',
        ),
      ],
    ),
    PpPage(
      id: 'formula_switching',
      title: 'Switching brands',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('People switch formula far more often than they need to, '
            'usually chasing better sleep or less crying. Here is what a '
            'switch can and cannot fix.'),
        PpArticle([
          'You can switch between standard stage 1 formulas freely. They are '
              'made to the same regulated composition, so there is no medical '
              'reason to stay loyal to one tin, and price or availability are '
              'perfectly good reasons to change.',
          'Change over a few days if you can. Try a feed or two a day of the '
              'new one, then more, over about three to five days. Some babies '
              'notice the taste and some do not care at all. A straight swap '
              'is not dangerous, it just occasionally means a day of '
              'fussiness.',
          'Expect the stools to change colour and texture for a few days. That '
              'is normal and settles. Blood, mucus, vomiting or a rash is not '
              'the switch settling in and needs a doctor.',
          'What a switch will not fix: normal newborn crying, evening '
              'fussiness, waking at night, and wind. Those are baby behaviour '
              'rather than formula behaviour, and cycling through four brands '
              'in six weeks mostly costs money and confidence.',
        ]),
        PpCallout('Give a new formula at least a week before deciding it did '
            'not work. Most of what people blame on formula settles in that '
            'time on its own.'),
        PpWhenLine('Switch gradually over 3 to 5 days. Give any new formula a '
            'week before judging it.'),
        PpIndiaNote('Stock disappears from shops without warning, so it is '
            'worth knowing you can switch safely between standard brands. Keep '
            'one spare tin at home rather than one preferred brand and no '
            'backup.'),
      ],
    ),
    PpPage(
      id: 'formula_mixed',
      title: 'Doing both, breast and bottle',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Combination feeding is what a very large number of Indian '
            'families actually do, and almost nothing is written for them. '
            'This page is.'),
        PpArticle([
          'Mixed feeding works. Some breast is worth having, and there is no '
              'threshold below which it stops counting. One feed a day is not '
              'a failed version of eight.',
          'The one mechanical thing to understand is that supply follows '
              'removal. Every formula feed that replaces a breast feed without '
              'a pump tells your body to make a little less. If you want to '
              'keep breastfeeding long term, keep the number of breast feeds '
              'or pumps roughly steady and let the formula fill the gaps '
              'around them.',
          'A common shape that holds up well: breast in the morning and at '
              'night when supply is highest and you are together anyway, '
              'formula during the day at work or creche. Another: breast first '
              'at each feed with a formula top up after, which keeps the '
              'stimulation and takes the pressure off.',
          'Drop feeds slowly if you are reducing on purpose. One feed every '
              'three or four days gives your breasts time to adjust and '
              'protects you from blocked ducts and mastitis.',
          'If he is under six months, top ups should be infant formula, or '
              'expressed milk if you have it. Cow milk as a main drink comes '
              'at a year, not before.',
        ]),
        PpCallout('Breast first, bottle after, is the pattern that protects '
            'supply best. Bottle first fills him up and the breast then gets '
            'skipped, which is how mixed feeding drifts into formula only '
            'without anyone choosing it.'),
        PpWhenLine('Can start at any age. If you want to protect the breast '
            'side, wait until feeding is comfortable, usually around 4 to 6 '
            'weeks, before adding regular bottles.'),
        PpIndiaNote('Mixed feeding is often the thing that lets an Indian '
            'mother go back to work at three months and still be feeding at a '
            'year. It is not the compromise everybody treats it as. It is '
            'frequently the reason breastfeeding lasts as long as it does.'),
        PpConsult(
          title: 'Lactation consultation',
          whoFor: 'For a mother planning combination feeding around a return '
              'to work, or one who wants to reduce formula and rebuild the '
              'breast side, and would rather have a plan than experiment on '
              'her own baby.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
      ],
    ),
    PpPage(
      id: 'formula_bottle_refusal',
      title: 'He will not take the bottle',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('This one usually arrives about ten days before you go back to '
            'work, and it is genuinely stressful. Most babies do take a bottle '
            'eventually, and how you offer it matters more than which bottle '
            'it is.'),
        PpArticle([
          'Let somebody else offer it. A breastfed baby who can smell his '
              'mother will hold out for the real thing. Leave the room, or the '
              'house, and let his father or his dadi try.',
          'Offer when he is calm and mildly hungry, not starving. A frantic '
              'baby will not learn a new skill. Try mid-morning rather than at '
              'the end of a long day.',
          'Warm the teat under running water so it does not feel cold and '
              'strange, hold him more upright than you would at the breast, '
              'and let him draw the teat in himself rather than pushing it in. '
              'Try a slow-flow teat first.',
          'If he refuses for weeks, a katori and spoon, a small open cup or a '
              'sippy cup all work, and from about six months you can skip '
              'bottles entirely and go straight to a cup. A baby who never '
              'takes a bottle is an inconvenience, not a problem to solve at '
              'any cost.',
        ]),
        PpCallout('Do not starve him into taking it. Waiting him out builds a '
            'fight around feeding, and the katori route works better and '
            'faster than a battle does.'),
        PpWhenLine('Start offering around 4 to 6 weeks if you know you will '
            'need it, and keep one bottle or cup feed a week going so the '
            'skill does not disappear.'),
        PpIndiaNote('The katori and spoon is how many Indian babies have '
            'always been fed expressed milk, and it is what most hospitals '
            'teach. It is slower, it works, and it avoids the flow-preference '
            'problem bottles can create.'),
      ],
    ),
    PpPage(
      id: 'formula_weaning',
      title: 'Stopping breastfeeding when you are ready',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Whenever you stop, it is the right time if it is your '
            'decision. This page is about doing it comfortably rather than '
            'about whether you should.'),
        PpArticle([
          'Go slowly if you can. Drop one feed every three to five days, '
              'starting with the one he cares about least, usually a midday '
              'feed. Keep the first morning and last night feeds for the end, '
              'because those hold most of the comfort and are the hardest to '
              'give up.',
          'Replace what you drop, not just the milk. Under one year, replace '
              'with formula. Over one year, cow milk and food. And replace the '
              'cuddle too, because for a toddler the feed is at least half '
              'about being held. A story, a lap and a katori of milk covers '
              'most of it.',
          'Look after your breasts on the way down. Express just enough for '
              'comfort rather than emptying, use cold packs, and watch for a '
              'hot painful lump. Weaning too fast is one of the classic '
              'triggers for mastitis.',
          'Expect your mood to dip for a few days around a big drop. The '
              'hormone shift is real and it passes. If it does not pass, or if '
              'it feels heavier than a few flat days, that is worth talking to '
              'a doctor about rather than filing under normal.',
          'Sudden stopping is sometimes unavoidable, for surgery or treatment. '
              'In that case express for comfort, taper the expressing over a '
              'week or two, and ask your doctor about anything you are taking '
              'rather than assuming you must stop at all.',
        ]),
        PpCallout('There is no age at which breastfeeding stops being good for '
            'him, and no age at which you are obliged to continue. Both halves '
            'of that are true at the same time.'),
        PpWhenLine('Gradual weaning over 2 to 6 weeks is comfortable for most '
            'mothers. Under 12 months, formula replaces the dropped feeds; '
            'over 12 months, cow milk and food do.'),
        PpIndiaNote('Bitter pastes like neem or karela on the nipple are still '
            'suggested, and they work by making a toddler distrust his mother '
            'rather than by helping him move on. Dropping feeds slowly and '
            'offering the cuddle without the feed gets there without that.'),
        PpCallout(
          'See a doctor if a breast becomes hot, red and painful with fever '
          'during weaning, or if low mood after stopping lasts more than a '
          'couple of weeks. Both are common, both are treatable, and neither '
          'is something to push through alone.',
          kind: PpCalloutKind.doctor,
          title: 'Two things to watch while weaning',
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
        PpIntro('Six months is the answer, and it is worth knowing why, '
            'because everyone around you will suggest four. This page is the '
            'whole of the first week.'),
        PpArticle([
          'Around six months, milk alone stops covering everything. His iron '
              'stores from birth are running down, he needs more energy than '
              'milk gives, and his gut and kidneys are ready for food in a way '
              'they were not at four months.',
          'Age is not the only signal, and the signs matter more than the '
              'date. He can sit with support and hold his head steady. He has '
              'lost the reflex that pushes food back out with his tongue. He '
              'can pick something up and get it to his mouth. And he watches '
              'you eat with real interest rather than politely.',
          'Start small. One meal a day, a teaspoon or two, at a time of day '
              'when he is neither starving nor exhausted. Mid-morning suits '
              'most families. Offer milk first for the first few weeks so he '
              'is not trying to learn a new skill while hungry.',
          'Build slowly to two meals a day by about seven or eight months and '
              'three by nine to ten months, with snacks after that. Milk stays '
              'the main source of nutrition until about a year, which is why '
              'the first months of solids are about practice rather than '
              'calories.',
          'Expect mess, gagging that is not choking, faces that look like '
              'horror, and a lot of food ending up on the floor. All of that '
              'is a baby learning, not a baby refusing.',
        ]),
        PpCallout('Before six months, milk is still the whole answer. Starting '
            'earlier does not help him sleep and does raise the risk of '
            'infection and allergy. If he was premature, ask your '
            'paediatrician which age to count from.'),
        PpCallout(
          'Starting solids early does not make a baby sleep through the night. '
          'It has been tested repeatedly and it does not work. What it does do '
          'is displace milk, which is more nutritious than anything you can '
          'put in a bowl at four months.',
          kind: PpCalloutKind.myth,
          title: 'Start rice cereal early and he will sleep',
        ),
        PpWhenLine('Around 6 months, and not before 4 months under any '
            'circumstances. One meal a day to begin, building to three by '
            'about 9 to 10 months.'),
        PpIndiaNote('You will be told to start at four months with sooji or '
            'rice water because that is what the previous generation did, and '
            'often it was because mothers went back to the fields. The advice '
            'has changed for good reasons. Six months, and the family gets to '
            'help by making the food rather than by setting the date.'),
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
          blurb: 'Purees, dal water and first mashes, filtered to his age.',
        ),
      ],
    ),
    PpPage(
      id: 'solids_first_foods',
      title: 'The first foods',
      format: 'CARDS',
      blocks: [
        PpIntro('There is no magic first food and no required order. Anything '
            'soft, plain and mashable works, and the Indian kitchen is full of '
            'better first foods than a packet of cereal.'),
        PpCards([
          PpCard('Moong dal water, then soft dal',
              'Start with the strained water, move to soft-cooked dal mashed '
              'smooth. Protein, familiar to the whole family, and cheap.'),
          PpCard('Rice, cooked soft and mashed',
              'Plain rice mashed with a little dal water or milk. Gentle and '
              'almost never refused.'),
          PpCard('Ragi porridge',
              'Ragi is one of the best first grains available in India. High '
              'in calcium and iron, easy to make loose or thick as he grows.'),
          PpCard('Sooji and dalia',
              'Cooked soft with water or milk. Sooji is smooth, dalia has more '
              'fibre. Both work well from six months.'),
          PpCard('Mashed banana, apple or pear',
              'Banana raw and mashed, apple and pear steamed first. Naturally '
              'sweet, so offer vegetables alongside rather than after.'),
          PpCard('Steamed vegetable mash',
              'Carrot, pumpkin, bottle gourd, sweet potato, potato. Steam, '
              'mash, thin with a little water or milk.'),
          PpCard('Curd, from six months',
              'Plain, unsweetened, full fat. Good for the gut and easy to '
              'combine with rice or fruit.'),
          PpCard('A little ghee',
              'Half a teaspoon stirred into dal or khichdi adds the energy a '
              'small stomach cannot get from volume.'),
        ], heading: 'Eight that work, in any order', hue: 96),
        PpCallout('Offer one new food at a time and give it two or three days '
            'before adding another. Not because a reaction is likely, but '
            'because if there is one you will know what caused it.'),
        PpWhenLine('From 6 months. Two to three teaspoons at first, building '
            'to a few tablespoons by 8 months.'),
        PpIndiaNote('No salt and no sugar before one year. That is not fussy: '
            'his kidneys cannot handle salt yet, and a baby who never learns '
            'that food must be sweet is much easier to feed at three. Make his '
            'portion out of the pot before you season the family one.'),
        PpLink(
          'Which foods are safe at his age',
          surfaceId: 'pp_baby_food_check',
          blurb: 'Type any food, get a straight answer.',
        ),
      ],
    ),
    PpPage(
      id: 'solids_spoon_or_blw',
      title: 'Spoon-feeding or letting him feed himself',
      subtitle: 'Both work. Most families do a bit of each.',
      format: 'COMPARISON TABLE',
      blocks: [
        PpIntro('You will read that one of these is the modern way and the '
            'other is old fashioned. That is a marketing argument, not a '
            'medical one. Here is the honest comparison so you can pick what '
            'suits your kitchen.'),
        PpTable(
          heading: 'The two routes, side by side',
          columns: ['', 'Spoon-fed purees', 'Baby-led weaning'],
          rows: [
            [
              'What it looks like',
              'You offer smooth food on a spoon, moving to lumps and then to '
                  'finger food.',
              'He picks up soft finger-sized pieces himself from the start. No '
                  'puree stage.',
            ],
            [
              'Start age',
              'Around 6 months.',
              'Around 6 months, and only once he can sit upright well.',
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
              'Considerable. Floor, hair, walls.',
            ],
            [
              'How you know how much went in',
              'You can see it. Reassuring in the early weeks.',
              'Hard to tell at first. Milk is covering him, so it matters '
                  'less than it feels.',
            ],
            [
              'Choking',
              'Low risk, but the same rules apply once lumps start.',
              'No higher risk if pieces are soft and finger sized. Gagging is '
                  'common and is not choking.',
            ],
            [
              'The honest catch',
              'Can stall at puree for too long if you never move to lumps.',
              'Iron-rich foods are harder to deliver in the first weeks, so '
                  'offer them deliberately.',
            ],
          ],
        ),
        PpCallout('Doing both is normal and is not a compromise. Dal chawal '
            'from a spoon and a piece of soft carrot in his fist, in the same '
            'meal, is a very ordinary way to feed an Indian baby.'),
        PpWhenLine('Either route starts around 6 months. Whichever you pick, '
            'lumps and finger foods should be part of his life by 9 months, '
            'because babies who stay on smooth puree past then often refuse '
            'texture later.'),
        PpIndiaNote('Indian food suits both approaches better than most '
            'cuisines. Khichdi mashes for a spoon and rolls into balls for a '
            'fist, idli tears into strips, a soft paratha finger holds '
            'together, and dal chawal works either way.'),
        PpCallout(
          'Whichever route you choose, he sits upright, he eats with an adult '
          'watching, and nothing is offered in a moving car or a pram. Never '
          'prop a spoon or a bottle and walk away.',
          kind: PpCalloutKind.safety,
          title: 'The rules that apply to both',
        ),
        PpLink(
          'Choking hazards and safe textures',
          pageId: 'safety_choking',
          blurb: 'What to cut, how to cut it, and what gagging actually looks '
              'like.',
        ),
      ],
    ),
    PpPage(
      id: 'solids_allergens',
      title: 'Introducing allergens safely',
      format: 'STEP-LIST',
      blocks: [
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
      ],
    ),
    PpPage(
      id: 'solids_textures',
      title: 'Textures, stage by stage',
      format: 'CHART-CARD',
      blocks: [
        PpIntro('Texture matters more than most parents are told. A baby who '
            'stays on smooth puree too long often refuses lumps at a year, and '
            'that is a much harder problem than a bit of gagging at eight '
            'months.'),
        // REQUIRED_REVIEW: the texture-by-age progression below, particularly
        // the 8 to 9 month window for introducing lumps and finger foods.
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
        PpCards([
          PpCard('Thin it with what it was made with',
              'Dal water, milk or plain water. Not sugar syrup and not extra '
              'ghee just to make it slide.'),
          PpCard('Mash with a fork, not a mixer',
              'Once he is past six months, a fork leaves the small lumps he '
              'needs to learn on. A blender removes exactly what he is meant '
              'to practise.'),
          PpCard('Finger food means finger sized',
              'About the length of your little finger, soft enough to squash '
              'between your finger and thumb.'),
          PpCard('If he refuses a new texture',
              'Go back one step for a few days and try again. Refusing once '
              'is not a verdict.'),
        ], heading: 'Four practical things', hue: 96),
        PpCallout('Aim to have soft lumps in his food by eight months. That is '
            'the window where chewing is learned most easily.'),
        PpWhenLine('Move up a texture every four to six weeks between 6 and 12 '
            'months, faster if he is managing easily.'),
        PpIndiaNote('Idli, soft dosa strips, mashed khichdi, soaked and '
            'squeezed roti and steamed vegetable pieces cover every stage on '
            'this chart without cooking anything separately.'),
        PpVideoSlot(
          title: 'Safe textures, shown at every stage',
          subtitle: 'What each texture actually looks like in a katori, and '
              'the difference between gagging and choking on video.',
          minutes: '10 MIN',
          slotId: 'feeding/safe_textures_demo',
        ),
      ],
    ),
    PpPage(
      id: 'solids_annaprashan',
      title: 'Annaprashan, the first bite',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('The first grain is a ceremony in most Indian families, and it '
            'is one of the nicer collisions between tradition and paediatrics. '
            'They agree on the timing almost exactly.'),
        PpArticle([
          'Annaprashan, also called mukhe bhaat, choroonu or bhaat khulai '
              'depending on where your family is from, marks the first time a '
              'baby is given grain. It is usually held around six months for '
              'boys and sometimes at five or seven months for girls, on a date '
              'chosen by the family or a priest.',
          'That timing lines up with the medical advice almost perfectly, '
              'which is worth saying to the relative who thinks the app is '
              'against tradition. Kheer, payasam or plain rice with ghee is a '
              'perfectly good first food.',
          'Two small adjustments make it safe. Keep his portion unsweetened, '
              'or very lightly sweetened, and keep it separate from the family '
              'bowl. And no honey, at all, before he turns one, whatever the '
              'tradition in your family says about honey on the tongue.',
          'The ceremony often ends with the baby choosing an object from a '
              'tray, and with a large number of people wanting to feed him. '
              'One or two spoons from you is enough. He does not need to eat a '
              'full bowl to have had his annaprashan.',
        ]),
        PpCallout(
          'No honey before one year, including a single ceremonial drop on the '
          'tongue or on the lips. Honey can carry spores that cause infant '
          'botulism, which is rare and serious. Use a drop of ghee or plain '
          'kheer instead and the ritual is unchanged.',
          kind: PpCalloutKind.safety,
          title: 'The one substitution to make',
        ),
        PpWhenLine('Traditionally at 6 months, sometimes 5 or 7 depending on '
            'family custom. Any of those is fine as long as it is not before '
            'about 6 months for the first real food.'),
        PpIndiaNote('If your family date falls at four months, you can hold '
            'the ceremony and give him a symbolic touch of ghee or kheer to '
            'the lips rather than a bowl, and start real solids at six. Most '
            'elders accept that easily once it is framed as doing the ritual '
            'properly rather than as skipping it.'),
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
      format: 'CHART-CARD',
      bands: ['milk'],
      blocks: [
        PpIntro('There is no chart for this age because there is nothing to '
            'chart. Breast milk, formula, or both, and nothing else at all, '
            'including water.'),
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
          note: 'A breastfed baby sets his own amount and you do not need to '
              'measure anything. The formula figures are a starting point, and '
              'a hungry baby who is growing well can take more.',
        ),
        PpCallout('Milk covers his fluid needs completely, in any weather. '
            'Water before six months fills his stomach without feeding him and '
            'can upset the salt balance in his blood.'),
        PpWhenLine('Birth to about 6 months. Solids start at 6 months, not '
            'earlier, and milk stays the main food until about a year.'),
        PpIndiaNote('In a Delhi or Chennai summer you will be told he must be '
            'thirsty. He is not. He asks for more frequent, shorter feeds in '
            'the heat, and that is the system working.'),
        PpLink(
          'Log his feeds',
          surfaceId: 'pp_feeding',
          blurb: 'Times, sides and amounts, without doing sums in your head.',
        ),
      ],
    ),
    PpPage(
      id: 'chart_6m',
      title: 'A day at 6 months',
      format: 'CHART-CARD',
      bands: ['first_foods'],
      blocks: [
        PpIntro('The first month of solids is about practice, not calories. '
            'Milk is still doing almost all the feeding, and two teaspoons '
            'eaten is a good day.'),
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
            ('Night', 'Breast or formula, as often as he asks'),
            ('Total solids', 'About 2 to 4 tablespoons across the day'),
            ('Texture', 'Smooth and runny'),
          ],
          note: 'Offer milk before the solid meal at this age, so he is '
              'learning rather than eating out of hunger.',
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
        ], heading: 'What goes in the katori', hue: 186),
        PpCallout('Two to four teaspoons is a full month-one portion. If he '
            'turns his head away, the meal is over, and that is a good habit '
            'to start on day one.'),
        PpWhenLine('Month 7 of life, one meal a day, moving to two by about '
            '7 months.'),
        PpIndiaNote('Make his portion out of the family pot before you add '
            'salt, chilli and tadka. That is the whole trick, and it means you '
            'never cook twice.'),
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
      format: 'CHART-CARD',
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
            ('Breakfast', '2 to 3 tablespoons of ragi or sooji porridge'),
            ('Midday', 'Breast or formula'),
            ('Lunch', '2 to 3 tablespoons of soft khichdi or dal rice'),
            ('Afternoon', 'Breast or formula'),
            ('Evening', 'Breast or formula'),
            ('Night', 'Breast or formula on demand'),
            ('Texture', 'Thick, mashed, with soft lumps'),
          ],
          note: 'Half a teaspoon of ghee in one meal a day from now on. It is '
              'the easiest way to add energy to a small stomach.',
        ),
        PpCards([
          PpCard('New this month',
              'Soft khichdi, mashed idli, soft dalia, apple and pear stewed '
              'and mashed, paneer mashed fine, ground til stirred into food.'),
          PpCard('Non-vegetarian',
              'Whole egg once yolk has been accepted. Well-cooked boneless '
              'fish or chicken mashed very fine, in tiny amounts.'),
          PpCard('Iron matters from now',
              'His birth iron stores are running low. Dal, ragi, greens, egg '
              'and meat all help. Serve with a little lemon or amla, which '
              'helps iron absorb.'),
        ], heading: 'What changes this month', hue: 186),
        PpCallout('Move to fork-mashed rather than blended this month. A baby '
            'who never meets a lump before nine months often refuses them '
            'later.'),
        PpWhenLine('Month 8 of life. Two meals a day, thicker textures, half a '
            'teaspoon of ghee daily.'),
        PpIndiaNote('Idli is close to a perfect baby food. Steamed, soft, '
            'fermented so it is easy to digest, and it tears into strips he '
            'can hold as soon as he wants to.'),
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
      format: 'CHART-CARD',
      bands: ['m8_12'],
      blocks: [
        PpIntro('Finger food starts here. Expect most of it on the floor for a '
            'fortnight, and expect him to be delighted about it.'),
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
        ], heading: 'What he can hold now', hue: 186),
        PpCallout('Gagging is loud and he stays pink. Choking is silent. That '
            'one sentence is the difference between panicking at the right '
            'moment and at the wrong one.'),
        PpWhenLine('Month 9 of life. Three meals taking shape, finger foods '
            'daily, texture moving to minced and chopped.'),
        PpIndiaNote('A soft roti finger dipped in dal is the classic Indian '
            'first finger food, and it beats every packaged teether biscuit on '
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
      format: 'CHART-CARD',
      bands: ['m8_12'],
      blocks: [
        PpIntro('Three real meals now, and he eats more or less what the '
            'family eats, made softer and left unsalted.'),
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
          note: 'Let him try the spoon himself even though almost nothing will '
              'arrive. That practice is what makes twelve months easier.',
        ),
        PpCards([
          PpCard('New this month',
              'Soft upma and poha, chopped rather than mashed vegetables, '
              'small pasta, chopped fruit, thicker curd preparations.'),
          PpCard('Non-vegetarian',
              'Chicken and fish in small chopped pieces, egg in most forms, '
              'small amounts of mutton keema cooked very soft.'),
          PpCard('Iron-rich every day',
              'Ragi, dal, palak, egg, chicken liver in tiny amounts, and jaggery '
              'only after one year.'),
        ], heading: 'What changes this month', hue: 186),
        PpCallout('Offer solids before milk now, the reverse of six months. '
            'Food is doing real work at this age and a full milk feed just '
            'before lunch will cost you the lunch.'),
        PpWhenLine('Month 10 of life. Three meals plus a snack, still no salt '
            'or sugar, still no cow milk as a drink.'),
        PpIndiaNote('This is the age where two households often start '
            'disagreeing about salt. His kidneys are the reason, not fussiness, '
            'and one unsalted katori from the same pot keeps everyone happy.'),
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
      format: 'CHART-CARD',
      bands: ['m8_12'],
      blocks: [
        PpIntro('By his first birthday he should be eating family food, cut '
            'small and made mild. This is the run up to that.'),
        PpChartCard(
          title: '10 to 12 months, vegetarian',
          subtitle: 'Three meals and two snacks, mostly self fed',
          rows: [
            ('On waking', 'Breast or formula'),
            ('Breakfast', 'Paratha fingers, idli, upma or porridge'),
            ('Mid morning', 'Fruit, curd or a soft chilla'),
            ('Lunch', 'Rice, dal, vegetable, ghee. Roti pieces if he likes '
                'them'),
            ('Afternoon', 'Breast or formula, or a snack'),
            ('Dinner', 'Whatever the family eats, unsalted and chopped small'),
            ('Night', 'Breast or formula'),
            ('Texture', 'Chopped family food, most textures'),
          ],
          note: 'Expect his appetite to swing wildly from day to day. Judge '
              'intake across a week, never across one meal.',
        ),
        PpCards([
          PpCard('Ready for',
              'Most family foods, chopped small and made mild. A spoon of his '
              'own. An open cup or a straw cup with water.'),
          PpCard('At twelve months',
              'Cow milk can become his main milk drink, salt and sugar can be '
              'used lightly, and honey becomes safe.'),
          PpCard('Still not',
              'Whole nuts, whole grapes, hard raw carrot, popcorn, chewing gum, '
              'and anything round and firm the size of his windpipe.'),
        ], heading: 'The one year handover', hue: 186),
        PpCallout('Two to three sittings of milk a day is plenty by now. Milk '
            'that keeps replacing meals is the most common reason a one year '
            'old is not eating food.'),
        PpWhenLine('Months 11 and 12. Three meals and two snacks, family food '
            'chopped small, milk moving into the background.'),
        PpIndiaNote('A tiffin of curd rice and a boiled vegetable travels well '
            'and survives an Indian afternoon better than anything with a '
            'gravy. Useful the first time you take him out for a full day.'),
        PpLink(
          'Recipes for 9 to 12 months',
          surfaceId: 'pp_food',
          blurb: 'Finger foods and family meals, filtered by age.',
        ),
      ],
    ),
    PpPage(
      id: 'chart_toddler',
      title: 'A day for a toddler',
      format: 'CHART-CARD',
      bands: ['tod', 'big'],
      blocks: [
        PpIntro('From one year he eats what the house eats. The chart matters '
            'less than the rhythm, because a toddler who grazes all day is a '
            'toddler who eats nothing at meals.'),
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
            ('Dinner', 'Family food, early rather than at 10pm'),
            ('Milk in 24 hours', 'About 300 to 500 ml, no more'),
            ('Water', 'Freely, in a cup he can reach'),
          ],
          note: 'A toddler portion is roughly a quarter to a third of an adult '
              'one. His stomach is about the size of his fist.',
        ),
        PpCards([
          PpCard('Why the milk limit matters',
              'More than about 500 ml a day fills him up, replaces meals, and '
              'blocks iron absorption. Excess milk is the single most common '
              'cause of a toddler who will not eat.'),
          PpCard('Fixed times, not a running buffet',
              'Meals and snacks at roughly the same times, nothing in between '
              'except water. A toddler who has grazed since 4pm cannot eat '
              'dinner.'),
          PpCard('Growth slows down at one',
              'He gains far less in his second year than his first, so his '
              'appetite drops. That is developmental, not a problem.'),
        ], heading: 'Three things that fix most toddler feeding', hue: 186),
        PpCallout('Serve, then step back. Your job is what is offered and '
            'when. How much goes in is his, and taking that over is where '
            'mealtime fights begin.'),
        PpWhenLine('From 12 months onwards. Three meals and two snacks at '
            'roughly fixed times, milk capped at about 500 ml a day.'),
        PpIndiaNote('Ek aur roti, khaana khilao, do niwale aur. A toddler '
            'being fed by four people until he cries is the most common '
            'feeding problem in Indian homes and it is entirely fixable. Agree '
            'once, as a family, that he decides how much.'),
        PpLink(
          'Baby not eating food',
          pageId: 'picky_not_eating',
          blurb: 'The full page on refusal, and what actually works.',
        ),
      ],
    ),
    PpPage(
      id: 'chart_nonveg_regional',
      title: 'Non-vegetarian and regional swaps',
      format: 'CHART-CARD',
      blocks: [
        PpIntro('Every chart in this area is written vegetarian by default '
            'because that is the most common Indian kitchen. Here is how to '
            'swap in meat, egg and fish, and what each region already does '
            'well.'),
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
            ('Shellfish', 'Later, and only after discussing with your doctor'),
          ],
          note: 'Meat and fish are the easiest iron and zinc a baby can get, '
              'which is worth knowing if his weight gain is being watched.',
        ),
        PpCards([
          PpCard('North',
              'Dalia, sooji halwa without sugar, soft paratha fingers, moong '
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
        PpCallout('Nothing on any chart in this app is compulsory. Feed him '
            'the food your family actually eats, made soft, unsalted and '
            'mild. That is better than any imported list.'),
        PpWhenLine('Applies from 6 months onwards. Introduce each new protein '
            'one at a time and watch for two hours the first time.'),
        PpIndiaNote('If your household is vegetarian, iron needs a little more '
            'attention: ragi, dal, palak, til and jaggery after one year, with '
            'a source of vitamin C at the same meal so the iron absorbs.'),
        PpVideoSlot(
          title: 'A day of food, walked through by age',
          subtitle: 'Six months to two years, real katoris on a real table, so '
              'you can see what a portion actually looks like.',
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
  title: 'Cooking for him',
  blurb: 'What to actually make, by age, by staple, and by what he needs.',
  hue: 44,
  pages: [
    PpPage(
      id: 'recipes_by_age',
      title: 'Recipes for his age',
      format: 'CARDS',
      blocks: [
        PpIntro('The whole recipe collection is free and filterable. This page '
            'is the shortcut: what stage he is at, and which set of recipes '
            'belongs to it.'),
        PpCards([
          PpCard('6 to 8 months, purees and first mashes',
              'Smooth and thin, moving to fork-mashed. Dal water, ragi '
              'porridge, steamed vegetable mash, mashed banana, first khichdi.'),
          PpCard('8 to 12 months, mashes and finger foods',
              'Minced, chopped, and things he can hold. Idli strips, soft roti '
              'fingers, paneer cubes, moong dal chilla, thicker khichdi.'),
          PpCard('12 months and up, family meals',
              'What the house eats, chopped small and made mild. Curd rice, '
              'veg pulao, paratha, dal chawal, soft cutlets.'),
          PpCard('Travel and tiffin',
              'Things that survive four hours in a bag in Indian weather. Curd '
              'rice, dry chilla, steamed vegetable, banana.'),
        ], heading: 'Four stages, four sets of recipes', hue: 44),
        PpCallout('Cook one pot for the family and lift his portion out before '
            'the salt and the chilli. That is the single habit that makes '
            'feeding a baby sustainable in a working household.'),
        PpWhenLine('From 6 months onwards. Match the recipe to his texture '
            'stage rather than strictly to his age in months.'),
        PpIndiaNote('Almost nothing here is a special baby recipe. It is your '
            'own kitchen, cooked softer and seasoned later, which is also why '
            'he grows up eating your food instead of a separate menu.'),
        PpLink(
          'Open the recipe collection',
          surfaceId: 'pp_food',
          blurb: 'Filter by age, meal, texture, veg or non-veg, and what is in '
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
              'first grains available anywhere. Loose porridge at six months, '
              'thicker later, pancakes and laddoo after one.'),
          PpCard('Khichdi',
              'Rice and moong dal cooked soft together. Complete protein, one '
              'pot, works at every stage from mashed to hand-held balls.'),
          PpCard('Sooji and dalia',
              'Semolina and broken wheat. Sooji is smooth and quick, dalia has '
              'more fibre and holds him longer. Both work sweet or savoury.'),
          PpCard('Dal water and dal',
              'Start with the strained water, move to mashed dal. Moong first, '
              'then masoor and toor. Cheap, familiar and iron rich.'),
          PpCard('Curd',
              'Plain, unsweetened, full fat, from six months. Good for the '
              'gut, cooling in summer, and the base of curd rice which is the '
              'most travel-proof baby food there is.'),
          PpCard('Idli and dosa',
              'Steamed and fermented, so they are soft and easy to digest. '
              'Idli tears into strips for small hands from about eight months.'),
        ], heading: 'The six that carry everything', hue: 44),
        PpCallout('Add half a teaspoon of ghee to one meal a day from seven '
            'months. A baby stomach cannot hold enough volume to get its '
            'energy any other way.'),
        PpWhenLine('All six work from 6 months in their softest form. Textures '
            'move up with him rather than the food changing.'),
        PpIndiaNote('Buy ragi and millet flour in small packs and keep them '
            'sealed. Flour goes rancid faster than whole grain, especially in '
            'humid weather, and rancid ragi tastes bitter enough that he will '
            'refuse it and you will blame ragi.'),
        PpVideoSlot(
          title: 'Cook along, moong dal khichdi for a baby',
          subtitle: 'One pot, three textures, from six months to two years, '
              'made in a normal pressure cooker.',
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
        PpIntro('Sometimes you are not cooking for a stage, you are cooking '
            'for a problem. Three of those come up constantly.'),
        PpCards([
          PpCard('For weight gain',
              'Ghee in dal or khichdi, mashed banana with curd, ragi and '
              'banana pancakes, date and banana kheer, paneer, avocado where '
              'you can get it, nut powders stirred in after allergens are '
              'introduced.'),
          PpCard('For iron',
              'Ragi, moong and masoor dal, palak dal, egg, chicken and fish, '
              'jaggery after one year. Serve with amla, lemon, orange or '
              'tomato at the same meal so the iron absorbs.'),
          PpCard('For immunity',
              'Curd and curd rice, turmeric milk after one year, tomato and '
              'carrot soup, clear chicken soup, seasonal fruit. No single food '
              'is a shield, and eating a range beats any one superfood.'),
          PpCard('What blocks iron',
              'Too much cow milk, and tea or coffee anywhere near a meal. A '
              'toddler on a litre of milk a day can be iron deficient while '
              'looking perfectly well fed.'),
        ], heading: 'Cooking with a purpose', hue: 44),
        PpCallout('Calorie density beats volume every time. A small katori '
            'with ghee in it feeds him better than a big katori of thin soup '
            'he cannot finish.'),
        PpWhenLine('Weight-gain foods from 7 months, iron from 6, jaggery and '
            'honey only after 12 months.'),
        PpIndiaNote('Gond, dry fruit powders and kesar are traditional weight '
            'foods and are genuinely useful once nuts have been introduced, as '
            'a fine powder rather than pieces. Never whole nuts, at any age '
            'under five.'),
        PpLink(
          'Foods that help him gain weight',
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
      title: 'What to feed when he is unwell',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Appetite disappears when a child is ill and that is normal. '
            'Fluids matter far more than food for a few days, and there is a '
            'whole set of recipes in the app for exactly this.'),
        PpArticle([
          'With fever, offer fluids constantly and food whenever he wants it. '
              'Thin khichdi, moong dal water, coconut water, plain curd and '
              'fruit are the usual winners. He will make it up in the week '
              'after, and children reliably do.',
          'With loose motions, keep feeding. Withholding food makes recovery '
              'slower, not faster. ORS after every loose stool, breast or '
              'formula as normal, plus banana, rice, curd and khichdi. Avoid '
              'juice and anything sugary, which makes it worse.',
          'With a cough or cold, warm and soft is what goes down. Rasam, clear '
              'soup, warm dal water. Feeds get shorter because his nose is '
              'blocked, so expect more of them, and clear his nose with saline '
              'drops before a feed.',
          'With vomiting, small amounts very often beats a normal meal. A '
              'spoon of fluid every few minutes for an hour, then build up. '
              'Breastfed babies should keep feeding, in shorter feeds.',
        ]),
        PpCallout('A child who is drinking and passing urine is usually '
            'managing, even if he eats nothing for two days. Fluids are the '
            'thing to watch, not the plate.'),
        PpWhenLine('For as long as the illness lasts, plus a few days. '
            'Appetite usually returns within a week and often comes back '
            'bigger than before.'),
        PpIndiaNote('Home ORS is one litre of clean boiled and cooled water, '
            'six level teaspoons of sugar and half a level teaspoon of salt. '
            'A packet from the chemist is more reliable and costs almost '
            'nothing, so keep two at home.'),
        // REQUIRED_REVIEW: the home ORS recipe above, and the dehydration
        // signs in the callout below.
        PpCallout(
          'See a doctor if he has no wet nappy for six hours, a dry mouth, no '
          'tears when crying, a sunken soft spot, blood in the stool, '
          'persistent vomiting, or if he is unusually drowsy. Dehydration in a '
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
          'What changed with him',
          surfaceId: 'pp_what_changed',
          blurb: 'If the change was sudden, start here instead.',
        ),
      ],
    ),
    PpPage(
      id: 'recipes_batch',
      title: 'Cooking once, feeding all week',
      format: 'STEP-LIST',
      blocks: [
        PpIntro('Nobody cooks a fresh baby meal five times a day for a year. '
            'A couple of hours on a Sunday covers most of the week, safely.'),
        PpSteps([
          PpStep('Cook in batches on one day',
              'Steam a tray of vegetables, cook a pot of dal, make a batch of '
              'khichdi. One gas ring, three components, most of the week.'),
          PpStep('Cool fast, within an hour',
              'Spread it thin in a wide plate rather than leaving a hot pot on '
              'the counter. Food sitting warm in Indian weather is where '
              'trouble starts.'),
          PpStep('Portion into small containers or an ice tray',
              'One meal per cube or per box, so you thaw what he eats rather '
              'than reheating a whole batch repeatedly.'),
          PpStep('Label with the date',
              'Fridge for two days, freezer for a month. Written down beats '
              'remembered, especially at 7am.'),
          PpStep('Thaw in the fridge overnight, or in hot water',
              'Never on the counter for hours, and never by leaving it out '
              'while you finish something else.'),
          PpStep('Reheat until steaming hot, then cool to warm',
              'Hot all the way through kills what grew while it was stored. '
              'Then stir and test it on your wrist before it goes near him.'),
          PpStep('Reheat once only',
              'What he does not eat gets thrown away, not put back in the '
              'fridge for tomorrow.'),
        ], heading: 'A week of baby food in one afternoon'),
        // REQUIRED_REVIEW: fridge and freezer storage times for cooked baby
        // food, and the one-hour cooling window. Confirm against food safety
        // guidance for a warm climate.
        PpCallout(
          'Never refreeze anything that has been thawed, and never save the '
          'part of a meal he has already eaten from. Serve into a separate '
          'katori and the rest of the batch stays clean.',
          kind: PpCalloutKind.safety,
          title: 'Two rules that make batching safe',
        ),
        PpWhenLine('Works from 6 months onwards. Purees freeze best, khichdi '
            'and dal freeze well, curd and cut fruit do not freeze at all.'),
        PpIndiaNote('If the power goes for hours, treat anything that has '
            'thawed as finished. A freezer that has warmed and refrozen is the '
            'commonest cause of a baby getting an upset stomach from home '
            'food.'),
        PpLink(
          'Meal plan and shopping list',
          surfaceId: 'pp_food',
          blurb: 'Plan the week and turn it into a list you can shop from.',
        ),
        PpLink(
          'Steamers, storage trays and containers',
          surfaceId: 'pp_products',
          blurb: 'What is worth buying for batch cooking and what is not.',
        ),
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
  blurb: 'Foods that help, and the honest answer to is he too thin.',
  hue: 12,
  pages: [
    PpPage(
      id: 'weight_foods',
      title: 'Foods that help him gain weight',
      format: 'CARDS',
      blocks: [
        PpIntro('Adding weight is about energy density, not quantity. A baby '
            'stomach is roughly the size of his fist, so what matters is how '
            'much energy fits into each small katori.'),
        PpCards([
          PpCard('Ghee',
              'Half to one teaspoon stirred into dal, khichdi or porridge, '
              'from about 7 months. The single easiest addition there is.'),
          PpCard('Full fat curd and paneer',
              'Never low fat for a child under two. Curd from six months, '
              'paneer mashed from about seven.'),
          PpCard('Banana and mashed avocado',
              'Banana with curd is a complete snack. Avocado is expensive but '
              'is almost pure good fat if you can get it.'),
          PpCard('Ragi and banana together',
              'As porridge, pancakes or a smoothie. Iron, calcium and calories '
              'in one bowl.'),
          PpCard('Nut and seed powders',
              'Almond, cashew, til and groundnut ground fine and stirred in, '
              'once those allergens have been introduced. A fine powder only, '
              'never pieces.'),
          PpCard('Coconut and coconut milk',
              'A spoon of coconut milk in a rice or vegetable dish adds real '
              'energy and is already in most southern kitchens.'),
          PpCard('Egg, chicken and fish',
              'Protein and iron in a small volume, which is exactly what a '
              'baby who is not gaining needs.'),
          PpCard('Dates and jaggery, after one year',
              'Date and banana kheer is the classic. Both are iron rich, and '
              'both wait until his first birthday.'),
        ], heading: 'Eight that genuinely add weight', hue: 12),
        PpCallout('Add energy to the food he already eats rather than trying '
            'to make him eat more of it. A spoon of ghee in the same katori '
            'beats a fight over a second katori.'),
        PpWhenLine('Ghee from about 7 months, nut powders once allergens are '
            'introduced, jaggery and honey only after 12 months.'),
        PpIndiaNote('Panjiri, gond laddoo and dry fruit powders are '
            'traditional weight foods and they work, for children over one, in '
            'small amounts and finely ground. Skip the sugar-heavy versions '
            'and skip them entirely before a year.'),
        PpLink(
          'Weight gain recipes',
          surfaceId: 'pp_food',
          blurb: 'Every calorie-dense recipe in the app, by age.',
        ),
      ],
    ),
    PpPage(
      id: 'weight_fats',
      title: 'Ghee, nuts and the fats a baby needs',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Fat has a bad name it does not deserve in the first two '
            'years. A baby brain is built largely out of fat, and a low-fat '
            'diet for a small child is a genuinely bad idea.'),
        PpArticle([
          'Roughly half of the energy in breast milk comes from fat, which '
              'tells you how the system is designed. When solids start to '
              'replace milk, that fat has to come from somewhere, and dal and '
              'vegetables alone do not carry it.',
          'Ghee is the obvious Indian answer and it is a good one. Half a '
              'teaspoon in one meal a day from seven months, a teaspoon by a '
              'year, more if he is not gaining. It carries flavour, helps '
              'fat-soluble vitamins absorb, and every Indian kitchen has it.',
          'Nuts and seeds are the other big source. Almond, cashew, walnut, '
              'til and groundnut, ground to a fine powder and stirred into '
              'porridge or dal. Once introduced, keep them in his diet rather '
              'than giving them occasionally.',
          'Full fat dairy matters until at least two years. Never buy toned or '
              'skimmed milk for a small child, and never low fat curd. The fat '
              'is the point.',
          'What to keep low is the other kind: repeatedly reheated frying oil, '
              'packaged fried snacks and bakery items made with vanaspati. '
              'Those add energy in a form nobody needs, and they crowd out '
              'food that would have fed him.',
        ]),
        PpCallout('Full fat milk, full fat curd, ghee in his food, and ground '
            'nuts once he has met them. That is the whole of good fat for a '
            'child under two.'),
        PpWhenLine('Ghee from about 7 months, ground nuts from about 7 to 8 '
            'months once introduced as allergens, full fat dairy until at '
            'least 2 years.'),
        PpIndiaNote('Homemade white butter and ghee from your own kitchen are '
            'excellent and cheaper than anything sold as a baby product. There '
            'is no baby ghee, there is just ghee.'),
        PpLink(
          'Track his growth',
          surfaceId: 'pp_growth',
          blurb: 'Weight and height plotted over time, so you can see the '
              'trend rather than guess at it.',
        ),
      ],
    ),
    PpPage(
      id: 'weight_too_thin',
      title: 'Is my baby too thin?',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Almost every Indian mother is asked this, usually in a room '
            'full of people, usually about a perfectly healthy baby. Here is '
            'how to tell whether it is worth listening to.'),
        PpArticle([
          'A chubby baby is not a healthier baby. The image most Indian '
              'families carry of a well-fed child comes from a time when '
              'undernutrition was the common danger, and it has not updated. '
              'Babies come in different builds, and a lean baby who is active, '
              'alert, meeting milestones and gaining steadily is a well baby.',
          'What matters is the trend, not the number. A baby who has always '
              'tracked along the lower part of the chart and keeps tracking '
              'there is growing normally. A baby who was tracking higher and '
              'has crossed down through the lines is the one to look at, even '
              'if he still weighs more than the neighbour who everybody '
              'praises.',
          'The signs of a baby who is genuinely well fed are boring and '
              'reliable. Six or more wet nappies a day, steady weight over '
              'weeks, energy to play, developmental milestones arriving, and '
              'firm limbs rather than soft ones.',
          'Common reasons for slow gain that are fixable: not enough feeds, a '
              'poor latch removing little milk, watery food with no energy '
              'density, too much milk crowding out food after a year, and '
              'grazing all day so he is never hungry at a meal. All of those '
              'are worth checking before anyone worries about anything else.',
          'And the part nobody says: your relatives are not measuring him '
              'against a chart. They are measuring him against a memory. A '
              'plotted growth chart from your paediatrician ends the argument '
              'in a way that no amount of feeding him will.',
        ]),
        PpCallout('Weigh him monthly, not daily. Day-to-day weight moves with '
            'a full nappy and a big feed, and watching it that closely turns '
            'ordinary noise into worry.'),
        PpCallout(
          'A chubby baby is not a healthier baby. That picture comes from a '
          'time when undernutrition was the everyday danger and it has never '
          'been updated. What health looks like on a chart is a steady line, '
          'high or low, not a high number.',
          kind: PpCalloutKind.myth,
          title: 'Gol matol matlab healthy',
        ),
        PpWhenLine('Weigh at the routine visits and at each vaccination, and '
            'plot it. Between 1 and 2 years, gain slows to roughly two to '
            'three kilos for the whole year, which is normal and alarms '
            'everyone.'),
        // REQUIRED_REVIEW: the second-year weight gain figure above, and the
        // faltering-growth signs in the doctor callout below.
        PpIndiaNote('Ek aur roti khila do, thoda mota ho jayega. You are '
            'allowed to say the doctor is happy with his growth and leave it '
            'there. Force-feeding to satisfy an aunt costs you the next two '
            'years of mealtimes.'),
        PpCallout(
          'See your paediatrician if he has crossed downwards through the '
          'lines on his growth chart, has not gained weight in a month, was '
          'gaining and stopped, is losing weight, or is lethargic and pale. '
          'Faltering growth has causes that are usually treatable, and finding '
          'them early is much easier than finding them late.',
          kind: PpCalloutKind.doctor,
          title: 'When thin is worth a doctor',
        ),
        PpVideoSlot(
          title: 'A paediatrician on the too-thin question',
          subtitle: 'What a growth chart actually shows, what a healthy lean '
              'baby looks like, and the signs that mean stop reassuring and '
              'start investigating.',
          minutes: '9 MIN',
          slotId: 'feeding/too_thin_explained',
        ),
        PpLink(
          'Track his growth',
          surfaceId: 'pp_growth',
          blurb: 'Plot weight and height properly, so the trend is visible.',
        ),
        PpConsult(
          title: 'Paediatric nutrition consultation',
          whoFor: 'For a baby whose weight gain has genuinely slowed, or a '
              'family arguing about it, when you want a nutrition plan built '
              'around what your kitchen already cooks rather than a generic '
              'diet chart.',
          surfaceId: 'pp_experts',
          role: 'nutrition',
        ),
      ],
    ),
    PpPage(
      id: 'weight_chart_reading',
      title: 'Reading the growth chart without panic',
      format: 'SHORT ARTICLE',
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
      title: 'He is not eating anything',
      format: 'ARTICLE',
      blocks: [
        PpIntro('This is the most searched feeding worry in India and it is '
            'exhausting in a way that is hard to explain to anyone who is not '
            'the one holding the katori. Almost always there is a reason, and '
            'almost always it is fixable.'),
        PpArticle([
          'Start with the boring explanation, because it is usually the right '
              'one. Growth slows sharply after the first birthday. A baby '
              'roughly triples his birth weight in year one and adds only two '
              'or three kilos in year two, so his appetite genuinely halves. '
              'The child has not changed; the requirement has.',
          'Then check the milk. A toddler drinking a litre of milk a day is '
              'full before he sits down, and milk also blocks iron absorption, '
              'which lowers appetite further. Capping milk at about 500 ml a '
              'day fixes more refusal cases than any recipe.',
          'Then check the grazing. A biscuit at four, a banana at five, juice '
              'at half past five, and dinner at seven has no chance. Fixed '
              'meal and snack times with only water in between rebuilds '
              'hunger, and hunger does most of the work.',
          'Then check what happens at the table. Pressure, chasing, screens, '
              'four adults coaxing at once, or a plate loaded so high it looks '
              'impossible all reduce how much a child eats. So does eating '
              'alone while the family eats later.',
          'And check him. Teething, a sore throat, constipation, a blocked '
              'nose, an ear infection or plain tiredness all flatten appetite '
              'for a few days. A sudden change in a child who was eating well '
              'is more likely to be one of those than a new personality.',
        ]),
        PpCallout('Judge his eating across a week, not across a meal. Almost '
            'every toddler who eats nothing on Tuesday eats twice as much on '
            'Thursday, and the week evens out even when no single day does.'),
        PpWhenLine('Most common between 1 and 3 years. A drop in appetite '
            'after the first birthday is expected and usually lasts months '
            'rather than days.'),
        PpIndiaNote('The Indian version of this comes with an audience. Ek aur '
            'niwala, thoda aur khila do, the phone held up to distract him, '
            'the walk around the colony with a plate. It works today and it '
            'costs you every meal after, because he learns that eating is '
            'something done to him rather than something he does.'),
        PpCallout(
          'See your paediatrician if he is losing weight, has stopped gaining '
          'over a month or more, is refusing fluids as well as food, is pale '
          'and tired, has pain or vomiting with meals, or has choked or gagged '
          'badly enough to be frightened of eating. Those are different from a '
          'fussy phase and are worth being seen for.',
          kind: PpCalloutKind.doctor,
          title: 'When not eating is more than a phase',
        ),
        PpVideoSlot(
          title: 'Four parents on the year their child stopped eating',
          subtitle: 'What they tried, what made it worse, and what eventually '
              'worked. No experts and no perfect families.',
          minutes: '9 MIN',
          slotId: 'feeding/picky_real_parents',
        ),
        PpLink(
          'What changed with him',
          surfaceId: 'pp_what_changed',
          blurb: 'If the refusal started suddenly, look here for what else '
              'changed at the same time.',
        ),
      ],
    ),
    PpPage(
      id: 'picky_who_decides',
      title: 'Who decides what, and who decides how much',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('One idea sorts out more mealtimes than any recipe. You decide '
            'what is served, where and when. He decides whether he eats it and '
            'how much.'),
        PpArticle([
          'That division sounds passive and it is not. It puts you firmly in '
              'charge of the parts you can actually control, and it hands him '
              'the only part he was ever going to control anyway, which is '
              'whether he swallows.',
          'Your half is real work: cooking food worth eating, serving it at '
              'sensible times, always including at least one thing he reliably '
              'accepts, and sitting down with him. His half is to eat what he '
              'wants of it, or nothing, without anybody making it a scene.',
          'What this ends is the negotiation. No two more bites, no bribing '
              'with sweets, no aeroplane spoon, no phone. All of those teach a '
              'child to eat for a reward rather than for hunger, and appetite '
              'is a much more reliable engine than a reward is.',
          'It takes about two weeks to settle and the first week is usually '
              'worse. He tests whether the rule is real, eats badly for a few '
              'days, gets properly hungry, and then starts eating. Holding the '
              'line during that week is the whole intervention.',
        ]),
        PpCallout('Serve one safe food he likes at every meal alongside '
            'whatever else is on the table. It means he can always eat '
            'something, so nobody has to negotiate.'),
        PpWhenLine('Works from about 12 months onwards. Give any change two '
            'weeks before deciding it has not worked.'),
        PpIndiaNote('This needs the whole household to agree once, out loud, '
            'because one grandparent following him around with a plate undoes '
            'it entirely. It is easier to have that conversation as a family '
            'rule than as a correction in the moment.'),
        PpScript([
          PpScriptLine(
            say: 'This is dinner. You can eat what you like from it.',
            notThis: 'Just two more bites and then you can go.',
            why: 'The first leaves him in charge of his own stomach. The '
                'second makes eating a negotiation he can win by holding out.',
          ),
          PpScriptLine(
            say: 'You do not have to eat it. Leave it on the side.',
            notThis: 'You are not getting up until that plate is finished.',
            why: 'Forcing food creates a fight that outlives the meal, and '
                'children who are made to finish tend to eat less over time, '
                'not more.',
          ),
          PpScriptLine(
            say: 'Kitchen is closed now. Breakfast is in the morning.',
            notThis: 'Fine, I will make you Maggi instead.',
            why: 'A second menu teaches him to hold out for the better offer. '
                'Missing one dinner is safe; a permanent short-order kitchen '
                'is not.',
          ),
          PpScriptLine(
            say: 'Chalo, we are all eating together.',
            notThis: 'Here, watch this while I feed you.',
            why: 'Children eat more, and try more new things, when they eat '
                'with people than when they eat in front of a screen.',
          ),
        ], heading: 'What to say, and what to stop saying'),
      ],
    ),
    PpPage(
      id: 'picky_food_jags',
      title: 'He ate it last week and now he hates it',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Food jags are one of the strangest parts of toddlerhood. He '
            'wants the same dish at every meal for eleven days and then never '
            'wants it again. It is normal, and there is a way to handle it '
            'that avoids losing the food for good.'),
        PpArticle([
          'Toddlers are working out that they are separate people with their '
              'own preferences, and food is the easiest place to practise. '
              'Refusing something you cooked is not about the food and it is '
              'certainly not about you.',
          'Some of it is developmental caution. Around eighteen months to '
              'three years most children become wary of new foods, which in '
              'evolutionary terms is a toddler who has just learned to walk '
              'and should not be eating unknown things off the ground. It '
              'fades.',
          'For a jag, serve the favourite but not at every meal, and always '
              'put something else next to it without comment. If you let a jag '
              'run unlimited, the child usually burns out on that food '
              'completely and you lose it from the rotation.',
          'For a new or rejected food, keep offering it without pressure. It '
              'can take ten or fifteen exposures before a child accepts '
              'something, and most families stop after three. Put a small '
              'amount on the plate, say nothing, and let him ignore it.',
          'Vary how it appears. A child who refuses cooked carrot may eat it '
              'raw and grated, in a paratha, in a soup, or cut into a '
              'different shape. Same vegetable, different question.',
        ]),
        PpCallout('Ten to fifteen exposures with no pressure is what acceptance '
            'usually takes. Serving it, saying nothing, and letting him leave '
            'it is not a failed attempt. It is one of the fifteen.'),
        PpWhenLine('Most common from about 18 months to 4 years. Individual '
            'jags usually last one to three weeks.'),
        PpIndiaNote('It helps that Indian food repeats ingredients in many '
            'forms. A child refusing dal will often eat the same dal as chilla, '
            'in khichdi, in sambar, or rolled into a roti. You are not '
            'sneaking it in, you are offering it differently.'),
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
            'second. In that order, because the second does not happen without '
            'the first.'),
        PpArticle([
          'Force-feeding works in the short term, which is exactly why it '
              'spreads through families. The child swallows, the plate empties '
              'and everyone relaxes. The cost arrives later: children who are '
              'regularly pressured to eat end up eating less over time, '
              'refusing more foods, and carrying a sour association with '
              'meals into their teens.',
          'The physical version, pinning a child, holding the nose, spooning '
              'in while he cries, also carries a real choking risk. A crying '
              'child breathes in sharply, and food in the mouth at that moment '
              'can go into the airway.',
          'What replaces it is unglamorous. Fixed times, no grazing between, '
              'small portions, one accepted food on every plate, everyone at '
              'the table, screens off, and the meal ending after about twenty '
              'to thirty minutes whether or not he ate.',
          'Reduce the audience. One adult manages the meal. A toddler with '
              'four people watching and commenting is at a performance, and '
              'his part in it is refusal, because that is the part that gets '
              'the biggest reaction.',
          'And accept the flat weeks. Some weeks he eats like a labourer and '
              'some weeks he lives on curd rice. Both happen in children who '
              'grow perfectly well, and your job across those weeks is to keep '
              'offering rather than to keep winning.',
        ]),
        PpCallout('Never force, never hold him down, never pinch the nose, and '
            'never feed a crying child. Beyond what it teaches him about '
            'meals, food going into an open airway is a genuine risk.'),
        PpWhenLine('Any age from about 1 year. Give a new calmer routine two '
            'weeks, and expect the first week to be worse.'),
        PpIndiaNote('The plate that follows a child around the colony, the '
            'phone propped against the dal, the grandmother finishing the '
            'katori while he plays. All of it comes from love and all of it '
            'makes the next meal harder. Changing it is a family decision '
            'rather than a mother-versus-everyone one.'),
        PpCallout(
          'Talk to your paediatrician if he gags or vomits at the sight of '
          'food, eats fewer than about ten foods in total, refuses whole '
          'textures, or if mealtimes have become frightening for him. A '
          'feeding therapist or a paediatric nutrition consultation helps in '
          'those cases, and they are not the same as ordinary fussiness.',
          kind: PpCalloutKind.doctor,
          title: 'When the battle needs outside help',
        ),
        PpConsult(
          title: 'Paediatric nutrition consultation',
          whoFor: 'For a family where meals have become a daily fight, or a '
              'child eating a very short list of foods, when you want a plan '
              'and someone to tell the rest of the household the same thing '
              'you have been saying.',
          surfaceId: 'pp_experts',
          role: 'nutrition',
        ),
      ],
    ),
    PpPage(
      id: 'picky_sweet_packet',
      title: 'He only wants biscuits and chips',
      format: 'SHORT ARTICLE',
      bands: ['tod', 'big'],
      blocks: [
        PpIntro('Packaged snacks are engineered to be more appealing than dal '
            'chawal, so a child preferring them is not a character flaw. It is '
            'the product working. This is about keeping them in proportion.'),
        PpArticle([
          'The problem is not one biscuit. It is that biscuits, chips, juice '
              'and namkeen are dense, quick and always available, so they '
              'crowd out the meal that would have followed. A child who has '
              'had a packet at five will not eat at seven, and then gets a '
              'packet again because he did not eat.',
          'The practical fix is availability rather than willpower. What is '
              'not in the house is not a negotiation. Keep fruit, curd, '
              'roasted chana, chilla, boiled egg and nuts in ground or chopped '
              'form where the packets used to be.',
          'Do not make sweets a reward or a punishment. Finish your food and '
              'you can have a chocolate teaches him that the chocolate is the '
              'valuable thing and the dal is the tax. Serve a small sweet '
              'occasionally as part of a meal instead, without ceremony.',
          'Juice is the quiet one. Even fresh juice is sugar without the '
              'fibre, it dulls appetite, and it is bad for new teeth. Whole '
              'fruit and water, and let milk stay a food rather than a drink '
              'he carries around.',
        ]),
        PpCallout('Change what is in the cupboard rather than arguing at the '
            'table. Almost every packet fight is won at the shop.'),
        PpWhenLine('Most relevant from about 18 months, once he can ask for '
            'things by name and other children are eating them in front of '
            'him.'),
        PpIndiaNote('Guests bring chocolates and relatives hand over biscuits '
            'as affection, and refusing that in the moment is awkward. Take '
            'it, thank them, and keep it for after a meal rather than making '
            'it a scene. The rule is about frequency, not about purity.'),
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
      title: 'Choking, and how to cut food so it does not happen',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Read this page before he starts finger foods, not after. Most '
            'choking in small children happens with a short list of foods and '
            'a short list of situations, and both are avoidable.'),
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
        PpCallout(
          'Cut round food lengthways, never into coins. Grapes and cherry '
          'tomatoes quartered lengthways. Sausage sliced lengthways then '
          'chopped. Nuts ground to powder, never whole and never halved. '
          'Spread nut butter thinly rather than serving it by the spoon. Grate '
          'or cook hard vegetables and fruit until soft.',
          kind: PpCalloutKind.safety,
          title: 'How to cut it',
        ),
        PpCallout(
          'He sits upright to eat, every time. An adult stays with him for the '
          'whole meal. No eating in a moving car, a pram, or lying down. Never '
          'feed a crying child, and never prop a bottle and walk away.',
          kind: PpCalloutKind.safety,
          title: 'The rules that do not bend',
        ),
        PpWhenLine('Applies from the first finger food, around 8 months, until '
            'at least 4 to 5 years. Whole nuts and popcorn wait until about 5.'),
        PpIndiaNote('The specific Indian hazards are worth naming: whole '
            'peanuts and channa handed over as a snack, boiled sweets and '
            'lozenges, hard chikki, whole grapes at a wedding, and small round '
            'ladoos. In a joint family the food usually arrives from someone '
            'who is not thinking about age, so it is worth saying out loud '
            'once to everybody.'),
        PpCallout(
          'If he is silent, cannot cough or cry, or is going blue, start back '
          'blows immediately and have somebody call an ambulance at the same '
          'time. After any choking episode where you had to intervene, take '
          'him to a hospital to be checked even if he seems completely fine '
          'afterwards.',
          kind: PpCalloutKind.doctor,
          title: 'If he is actually choking',
        ),
        PpVideoSlot(
          title: 'Choking and safe textures, shown properly',
          subtitle: 'What gagging looks like against choking, how to cut every '
              'risky food, and back blows and chest thrusts demonstrated on a '
              'training doll.',
          minutes: '12 MIN',
          slotId: 'feeding/choking_safety_demo',
        ),
      ],
    ),
    PpPage(
      id: 'safety_avoid_under_one',
      title: 'Foods to avoid before his first birthday',
      format: 'FLAGGED CARDS',
      blocks: [
        PpIntro('Short list, and every item on it has a real reason. Once he '
            'turns one, most of these open up.'),
        PpCards([
          PpCard('Honey',
              'Not a drop before 12 months, including on the tongue at a '
              'ceremony or on a dummy. It can carry spores that cause infant '
              'botulism, which is rare and serious.'),
          PpCard('Salt',
              'His kidneys cannot handle it. No added salt before one year, '
              'and go light after. That includes packaged snacks, papad, '
              'pickle, sauces and namkeen.'),
          PpCard('Sugar',
              'Nothing is gained and appetite for real food is lost. No sugar, '
              'jaggery, gur, biscuits, juice or sweets before one year.'),
          PpCard('Cow milk as a main drink',
              'Small amounts in cooking are fine from six months. As his main '
              'drink it waits until 12 months, because it is low in iron and '
              'hard on a young gut.'),
          PpCard('Whole nuts and popcorn',
              'A choking risk, not an allergy one. Ground nut powder is fine '
              'and encouraged. Whole nuts wait until about 5 years.'),
          PpCard('Unpasteurised milk and soft cheese',
              'Raw milk from the doodhwala must be boiled. Unpasteurised soft '
              'cheeses carry a real infection risk for a baby.'),
          PpCard('Raw or undercooked egg and meat',
              'Cook both through. No half-boiled egg, no runny yolk, no rare '
              'meat before at least a year.'),
          PpCard('Tea, coffee and anything caffeinated',
              'Not needed, and tea near a meal blocks iron absorption, which '
              'is a common and invisible problem in Indian households.'),
        ], heading: 'The under-one list', hue: 8),
        PpCallout(
          'No honey before 12 months, in any amount, in any form, for any '
          'ritual. Substitute a drop of ghee or plain kheer and the ceremony '
          'is unchanged.',
          kind: PpCalloutKind.safety,
          title: 'The one that catches families out',
        ),
        PpWhenLine('All of these apply until his first birthday. Whole nuts '
            'and popcorn stay off the list until about 5 years.'),
        PpIndiaNote('Honey on the tongue at birth or at annaprashan is a real '
            'and loving tradition in many families, which is exactly why it '
            'needs saying clearly and early rather than on the day. Ghee is '
            'the accepted substitute and nobody objects to it.'),
        PpLink(
          'Can he eat this?',
          surfaceId: 'pp_baby_food_check',
          blurb: 'Any food, his age, a straight answer and one line of reason.',
        ),
      ],
    ),
    PpPage(
      id: 'safety_allergy',
      title: 'What an allergic reaction looks like',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Most reactions to food are mild and settle. A small number '
            'are emergencies. Knowing which is which, before it happens, is '
            'the whole of this page.'),
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
        PpCallout(
          'Call an ambulance immediately for swelling of the tongue or throat, '
          'noisy or difficult breathing, a hoarse cry, sudden pallor, '
          'floppiness or collapse after a food. Do not drive him yourself if '
          'you can avoid it, and do not wait to see whether it settles.',
          kind: PpCalloutKind.doctor,
          title: 'The signs that mean call now',
        ),
        PpWhenLine('Reactions usually appear within minutes to 2 hours of the '
            'food. Introduce any new allergen in the morning, at home, on a '
            'day you can reach a doctor.'),
        PpIndiaNote('Keep the paediatrician\'s number and the nearest hospital '
            'with a paediatric emergency saved in every phone in the house, '
            'and stuck on the fridge for whoever does not have a phone. In an '
            'emergency nobody remembers where anything is.'),
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
        PpIntro('Iron deficiency is genuinely common in Indian babies and it '
            'is invisible until it is not. A few habits in the kitchen prevent '
            'most of it.'),
        PpCards([
          PpCard('Iron, from about 6 months',
              'His birth stores run out around six months, which is one of the '
              'reasons solids start then. Ragi, moong and masoor dal, palak, '
              'egg yolk, chicken, fish, liver in tiny amounts, and jaggery '
              'after one year.'),
          PpCard('Vitamin C alongside it',
              'Lemon on the dal, amla, tomato, orange, guava. Vitamin C at the '
              'same meal can multiply how much iron he absorbs from plant '
              'foods, which matters a lot in a vegetarian household.'),
          PpCard('What blocks iron',
              'Tea and coffee near meals, and too much cow milk. A toddler on '
              'a litre of milk a day is the classic iron-deficient child who '
              'looks perfectly well fed.'),
          PpCard('Calcium',
              'Milk, curd, paneer, ragi, til and green leafy vegetables. Do '
              'not serve a big milk drink with an iron-rich meal, because they '
              'compete.'),
          PpCard('Vitamin D',
              'Sunlight and drops. Most Indian babies are given vitamin D '
              'drops, and deficiency is very common here despite the sun, '
              'because of skin cover and indoor living. Ask your paediatrician '
              'about the dose.'),
          PpCard('Zinc',
              'Dal, chana, til, curd, egg, meat. Matters for immunity and for '
              'recovering from repeated infections.'),
          PpCard('Protein',
              'Dal, curd, paneer, egg, chicken, fish, soya, chana. Spread '
              'across the day rather than in one meal.'),
          PpCard('Iodine',
              'Use iodised salt in the family cooking, for everybody over one '
              'year. It is the cheapest public health measure in the kitchen.'),
        ], heading: 'What matters, and where it comes from', hue: 8),
        // REQUIRED_REVIEW: vitamin D supplementation for Indian infants, the
        // age iron needs rise, and whether iron supplementation should be
        // mentioned here at all rather than left entirely to the doctor.
        PpCallout('Iron plus vitamin C at the same meal, and milk kept away '
            'from it. That one pairing does more for an Indian baby\'s iron '
            'than any supplement bought without advice.'),
        PpWhenLine('Iron matters from 6 months. Vitamin D drops usually from '
            'birth, on your paediatrician\'s advice. Iodised salt from 1 year, '
            'when salt starts.'),
        PpIndiaNote('Cooking dal and vegetables in an iron kadhai adds a small '
            'but real amount of iron to the food, which is a genuine advantage '
            'of the pan your family probably already owns.'),
        PpCallout(
          'Ask your paediatrician about testing if he is pale, tired, '
          'irritable, eating badly, or was born premature or small. Do not '
          'start iron or any other supplement on your own, because too much '
          'iron is harmful and iron drops are a common cause of accidental '
          'poisoning in small children.',
          kind: PpCalloutKind.doctor,
          title: 'Supplements are a doctor decision',
        ),
        PpConsult(
          title: 'Paediatric nutrition consultation',
          whoFor: 'For a vegetarian household worried about iron and protein, '
              'or a child who has been told he is anaemic, when you want a '
              'plan built out of what your kitchen already cooks.',
          surfaceId: 'pp_experts',
          role: 'nutrition',
        ),
      ],
    ),
    PpPage(
      id: 'safety_water',
      title: 'When to start water',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Not before six months, whatever the weather. After that, '
            'freely and in an open cup. That is nearly the whole page, and the '
            'reasons are worth two minutes.'),
        PpArticle([
          'Before six months, breast milk and formula supply all the water he '
              'needs, even in a Rajasthan summer. Water fills a small stomach '
              'without feeding him, so he takes less milk, and in larger '
              'amounts it can dilute the salts in his blood, which is '
              'dangerous.',
          'From six months, offer water with meals in a small open cup or a '
              'straw cup. A few sips is plenty at first. It is about learning '
              'to drink from a cup as much as it is about the water.',
          'From a year, water is his main drink between meals, with milk '
              'limited to about 500 ml a day. Water rather than juice, and '
              'nothing sweetened at all.',
          'Use water that is safe for the household: boiled and cooled, '
              'filtered, or from a treated supply. Boil for a rolling minute '
              'if you are unsure, then cool it covered. Bottled water is not '
              'automatically safer than a good home filter.',
        ]),
        // REQUIRED_REVIEW: the "no water before 6 months" line, the toddler
        // milk cap of about 500 ml, and the boiling instruction.
        PpChartCard(
          title: 'Water, by age',
          rows: [
            ('0 to 6 months', 'None. Milk covers everything.'),
            ('6 to 12 months', 'A few sips with meals, in an open cup'),
            ('12 to 24 months', 'Freely through the day, about 1 litre'),
            ('2 years and up', 'Freely, and always the default drink'),
          ],
          note: 'In hot weather a young baby wants shorter, more frequent milk '
              'feeds rather than water. Let him have them.',
        ),
        PpCallout('An open cup or a straw cup beats a spouted sippy cup. Both '
            'are better for his teeth and his speech muscles, and he learns '
            'the real skill instead of a temporary one.'),
        PpWhenLine('From 6 months with meals. Freely from 12 months, with milk '
            'capped at about 500 ml a day.'),
        PpIndiaNote('Do not give a baby under six months water, glucose water, '
            'gripe water or janam ghutti, however hot it is and however '
            'insistent the advice. If he seems thirsty in summer, feed him '
            'more often.'),
        PpCallout(
          'See a doctor if he has fewer wet nappies than usual, a dry mouth, '
          'no tears when crying, a sunken soft spot or is unusually drowsy. '
          'Dehydration in a baby moves quickly and is not something to manage '
          'at home with water alone.',
          kind: PpCalloutKind.doctor,
          title: 'Signs he is short of fluid',
        ),
      ],
    ),
  ],
);
