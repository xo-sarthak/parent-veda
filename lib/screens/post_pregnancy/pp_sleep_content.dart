// =============================================================================
//  Sleep — the section's content
// -----------------------------------------------------------------------------
//  Built from pp_specs/01-sleep.md, against the mechanism in
//  docs/PP-SECTION-PATTERN.md. Seven areas plus three tools.
//
//  ⚠️ THIS FILE IS DATA. There is no layout in it, on purpose. `PpSectionScreen`
//  renders the landing, `PpContentPage` renders every page, and the only reason
//  eleven parallel sections stay one product is that none of them own a
//  `SizedBox`. See pp_content.dart's own header for the full argument.
//
//  ⚠️ REBUILT 2026-09-11 FROM `ParentVeda_Sleep_rebuild.pdf`, THE V3 DOOR BRIEF.
//  The library model stayed (landing, seven collections, the standalone
//  tracker); what changed is the age rule, nine reformats, seven new pieces,
//  two merges and one cut. The brief's marks are quoted at each page below so
//  a reviewer can hold the file against the map. Three rules from it that the
//  data now enforces rather than describes:
//
//    * **The app knows her age, so it never asks.** `autoScope: true` on the
//      section removes the band chips; every age-arc table and timeline
//      carries `rowMonths` so her row leads; the "Is she sleeping enough?"
//      checker is gone because it existed only to turn an age into a range.
//    * **Single source.** The tracker is "Log her sleep" is "Track and
//      understand" — one surface, on the hub. Sleep Sounds is one library,
//      `pp_sounds_data.dart`, and the collection 7 page is GENERATED from it
//      rather than being a second list that drifts.
//    * **No second copies.** The worry set is a carousel whose cards open the
//      four canonical pages, which stay in the file as `linkedOnly`.
//
//  ⚠️ SLEEP TRAINING: WE NOW SAY WHERE WE STAND, ONCE, AND PIN IT. The first
//  build kept the phrase out of the reader's head entirely, on the market
//  fact that Indian families co-sleep by default. The rebuild reverses that
//  deliberately: "Where we stand on sleep training" is pinned at the top of
//  collection 4 and named brand-defining — gentle first, and why, plus the
//  words to push back when family says "let her cry". Everywhere else the
//  old rule still holds: no cry-it-out, no ferberizing, and the consult still
//  names sleep training only to rule it out.
//
//  ⚠️ SAFE SLEEP IS HARM REDUCTION, NOT ABSTINENCE. This is the one place the
//  section could actually cost a baby something, and the reasoning is worth
//  writing down rather than rediscovering in review: "never bed-share" is advice
//  Indian families do not follow, and advice that is not followed does not
//  reduce risk, it only moves the conversation out of the app. So Area 5 leads
//  with "here is how to bed-share more safely" and keeps a short, specific list
//  of the nights where the answer really is a separate surface. Fewer absolutes,
//  more babies on a firm flat surface with no quilt over their face.
//
//  ⚠️ THE AGE CARDS IN AREA 1 ARE STRUCTURED DATA, AND THAT STILL MATTERS. They
//  were built as `PpChartCard`s with label/value rows so the quick-check tool
//  could read them. The tool is gone — auto-scope made it redundant — but the
//  cards stay structured, because `test/pp_sleep_check_test.dart` still proves
//  every band has a card, and because the day someone wants the numbers in a
//  second place (Ask Veda, a WhatsApp reply) they are rows, not prose.
//
//  English only, plain `String`.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_age_bands.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';
import 'pp_sounds_data.dart';

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpSleepSection = PpSection(
  id: 'parenting_sleep', // MUST match the hub's bracketId.
  title: 'Sleep',
  intro: 'Helping your little one, and you, sleep better.',
  bandSet: kPpSleepBands,
  // ⚠️ THE AGE RULE. No chips, no chooser; the library opens on her band and
  // shows only that. See `PpSection.autoScope`.
  autoScope: true,
  areas: [
    _howMuch,
    _nightWaking,
    _regressions,
    _gettingToSleep,
    _safeSleep,
    _worries,
    _music,
  ],
  // ⚠️ ONE TOOL ON THE LANDING, AND THE BRIEF SAYS WHY THE OTHER TWO WENT.
  //
  // "Removed from tools: 'Is she sleeping enough?' (merged into collection 1
  // chart); 'Log her sleep' shown as = the tracker." The checker only turned
  // an age into a range, and the app knows the age. The log IS the tracker,
  // which is already the hub's second door ("Track & understand sleep"), so a
  // tool row for it was the same surface offered twice on one screen.
  //
  // Both kept below for revert.
  tools: [
    /*
    PpSectionTool(
      label: 'Is your baby sleeping enough?',
      blurb: 'Enter your baby\'s age and see the normal range. Takes ten seconds.',
      surfaceId: 'pp_sleep_check',
      icon: Icons.nightlight_outlined,
    ),
    // ⚠️ REUSED, NOT REBUILT. `pp_sleep` is the existing Sleep Journey log
    // (sleep_journey_screen.dart). It is already non-gamified, already reads
    // SleepStore, and already has the age-context card. A second sleep log
    // would split one baby's nights across two databases.
    PpSectionTool(
      label: 'Log sleep and naps',
      blurb: 'A light record of a few days, so a pattern can show up. '
          'No scores and no streaks.',
      surfaceId: 'pp_sleep',
      icon: Icons.edit_note_outlined,
    ),
    */
    PpSectionTool(
      label: 'Sleep Sounds',
      blurb: 'Lullabies, white noise, rain, soft ragas and bedtime stories, '
          'with a timer that switches itself off.',
      surfaceId: 'pp_sleep_sounds',
      icon: Icons.music_note_outlined,
    ),
  ],
);

/// The reassurance the old quick-check screen carried, now on the chart it
/// merged into. One string, five pages, so it cannot drift between ages.
const String _kRangeReassurance =
    'Plenty of healthy babies sit outside these ranges. If your baby '
    'wakes rested and is growing and feeding well, that is enough sleep '
    'for now.';

/// The `(fromMonths, toMonths)` spans behind every age-arc table in this
/// file, so "her row" is decided from one list rather than five. Matches
/// `kPpSleepBands` exactly.
const List<(int, int)> _kArc = [(0, 3), (3, 6), (6, 12), (12, 36), (36, 72)];

// =============================================================================
//  AREA 1 — How much sleep by age
// -----------------------------------------------------------------------------
//  One chart-card page per band, plus one article that every band sees. The
//  band-tagged pages are the reason the numbers never have to be hedged: a
//  newborn page can simply say "every two to three hours" instead of "it
//  depends on age".
// =============================================================================

final PpArea _howMuch = PpArea(
  id: 'how_much',
  mark: IntentMark.chartLog,
  title: 'How much sleep does your baby need?',
  blurb: 'What is normal at this age, and the honest range around it.',
  hue: 206,
  pages: [
    PpPage(
      id: 'sleep_newborn',
      title: 'Sleep at this age',
      subtitle: 'Newborn, 0 to 3 months',
      format: 'CHART',
      bands: ['nb'],
      blocks: [
        PpIntro('Newborns sleep a lot, in short bursts, around the clock. '
            'There is no schedule yet, and you don\'t need to make one. A '
            'newborn\'s stomach is small and empties fast, so waking is normal.'),
        PpChartCard(
          title: 'Newborn, 0 to 3 months',
          subtitle: 'Across a full 24 hours, day and night together',
          rows: [
            ('Total sleep in 24 hours', '14 to 17 hours'),
            ('The honest range', '11 to 19 hours'),
            ('Day naps', '4 to 5'),
            ('Length of a nap', '30 minutes to 3 hours'),
            ('Longest night stretch', '2 to 4 hours'),
            ('Night feeds', '2 to 4'),
          ],
          note: 'Waking every two to three hours to feed is normal and '
              'expected. A baby who sleeps one long stretch is not better at '
              'sleeping, just built a little differently this week.',
        ),
        PpCallout('There is no need for a routine yet. In the first three '
            'months you feed on demand and sleep when your baby sleeps. '
            'The routine comes later, and it comes easily.'),
        PpWhenLine('From birth to about 12 weeks. Expect the pattern to shift '
            'every few days rather than settle.'),
        PpIndiaNote('In a shared room, babies often settle faster, not slower. '
            'You don\'t need a separate nursery. There is no evidence that a '
            'baby sleeping in your room sleeps worse.'),
        PpCallout(_kRangeReassurance),
        // ⚠️ THE CHECKER LINK IS GONE. The brief: "delete 'check the range
        // for her exact age'". This page IS her exact age now. Kept for
        // revert.
        // PpLink(
        //   'Check the range for your baby\'s exact age',
        //   surfaceId: 'pp_sleep_check',
        //   blurb: 'Enter the age in weeks or months, get the normal range.',
        // ),
      ],
    ),
    PpPage(
      id: 'sleep_3_6',
      title: 'Sleep at this age',
      subtitle: '3 to 6 months',
      format: 'CHART',
      bands: ['m3_6'],
      blocks: [
        PpIntro('Something starts to look like a pattern now. Night sleep '
            'gathers into longer stretches and the day naps begin to fall at '
            'roughly the same times.'),
        PpChartCard(
          title: '3 to 6 months',
          subtitle: 'Across a full 24 hours, day and night together',
          rows: [
            ('Total sleep in 24 hours', '12 to 16 hours'),
            ('The honest range', '10 to 18 hours'),
            ('Day naps', '3 to 4'),
            ('Length of a nap', '30 minutes to 2 hours'),
            ('Night sleep', '9 to 11 hours'),
            ('Longest night stretch', '4 to 6 hours'),
            ('Night feeds', '1 to 3'),
          ],
          note: 'Many babies find a long night stretch here and then lose it '
              'again around four months. Both halves of that are normal.',
        ),
        PpCallout('This is the age a bedtime routine starts to pay off. Same '
            'order, same time, every night. Twenty minutes is plenty.'),
        PpWhenLine('From about 12 weeks to 6 months. Naps usually settle into '
            'a rough shape by 5 months, not before.'),
        PpIndiaNote('If the household eats at 9pm, bedtime will drift late. '
            'Rather than fight the whole house, keep the last 20 minutes '
            'before sleep quiet and dim, wherever that happens.'),
        PpCallout(_kRangeReassurance),
        // ⚠️ THE CHECKER LINK IS GONE. The brief: "delete 'check the range
        // for her exact age'". This page IS her exact age now. Kept for
        // revert.
        // PpLink(
        //   'Check the range for your baby\'s exact age',
        //   surfaceId: 'pp_sleep_check',
        //   blurb: 'Enter the age in weeks or months, get the normal range.',
        // ),
      ],
    ),
    PpPage(
      id: 'sleep_6_12',
      title: 'Sleep at this age',
      subtitle: '6 to 12 months',
      format: 'CHART',
      bands: ['m6_12'],
      blocks: [
        PpIntro('Most sleep has moved to the night by now. Day naps get '
            'fewer and longer, and your baby can stay happily awake for much '
            'longer between them.'),
        PpChartCard(
          title: '6 to 12 months',
          subtitle: 'Across a full 24 hours, day and night together',
          rows: [
            ('Total sleep in 24 hours', '12 to 16 hours'),
            ('The honest range', '11 to 17 hours'),
            ('Day naps', '2 to 3'),
            ('Length of a nap', '45 minutes to 2 hours'),
            ('Night sleep', '10 to 12 hours'),
            ('Wakes in the night', '0 to 3'),
            ('Night feeds', '0 to 2'),
          ],
          note: 'Sleeping through the night is common at this age and so is '
              'still waking twice. Neither one means you did something right '
              'or something wrong.',
        ),
        PpCallout('Awake time between naps matters more than the clock now. '
            'Most babies this age can manage 2.5 to 4 hours awake, and an '
            'overtired baby is harder to settle, not easier.'),
        PpWhenLine('From 6 to 12 months. The third nap usually goes somewhere '
            'between 6 and 9 months.'),
        PpIndiaNote('Once your baby can pull to stand, check the bed and the '
            'room again. A baby who could not move last month can now reach '
            'the edge of the mattress.'),
        PpCallout(_kRangeReassurance),
        // ⚠️ THE CHECKER LINK IS GONE. The brief: "delete 'check the range
        // for her exact age'". This page IS her exact age now. Kept for
        // revert.
        // PpLink(
        //   'Check the range for your baby\'s exact age',
        //   surfaceId: 'pp_sleep_check',
        //   blurb: 'Enter the age in weeks or months, get the normal range.',
        // ),
      ],
    ),
    PpPage(
      id: 'sleep_toddler',
      title: 'Sleep at this age',
      subtitle: 'Toddler, 1 to 3 years',
      format: 'CHART',
      bands: ['tod'],
      blocks: [
        PpIntro('One long night and one afternoon nap is where most toddlers '
            'land. The biggest change in these two years is the morning nap '
            'disappearing.'),
        PpChartCard(
          title: 'Toddler, 1 to 3 years',
          subtitle: 'Across a full 24 hours, day and night together',
          rows: [
            ('Total sleep in 24 hours', '11 to 14 hours'),
            ('The honest range', '9 to 16 hours'),
            ('Day naps', '1, sometimes 2 until about 18 months'),
            ('Length of a nap', '1 to 3 hours'),
            ('Night sleep', '10 to 12 hours'),
            ('Wakes in the night', '0 to 2'),
          ],
          note: 'A toddler who fights bedtime is usually not short of sleep. '
              'More often it is a wish for your attention at the end of a long '
              'day, or the nap ran too late.',
        ),
        PpCallout('If the afternoon nap ends after about 4pm, bedtime moves '
            'later with it. It\'s fine to wake your toddler from a late nap.'),
        PpWhenLine('From 12 months to 3 years. Two naps become one somewhere '
            'between 12 and 18 months for most children.'),
        PpIndiaNote('Indian children often keep an afternoon nap longer than '
            'Western charts suggest, partly because of the afternoon heat and '
            'partly because the household naps too. That is fine.'),
        PpCallout(_kRangeReassurance),
        // ⚠️ THE CHECKER LINK IS GONE. The brief: "delete 'check the range
        // for her exact age'". This page IS her exact age now. Kept for
        // revert.
        // PpLink(
        //   'Check the range for your child\'s exact age',
        //   surfaceId: 'pp_sleep_check',
        //   blurb: 'Enter the age in months or years, get the normal range.',
        // ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCards(heading: 'A sample toddler day', [
          PpCard('Wake', 'Around 6:30 to 7:30.'),
          PpCard('Nap', 'One nap after lunch, about one to two and a half '
              'hours, until most children drop it between three and four.'),
          PpCard('Bedtime', 'Between 7:30 and 9, with the same short routine '
              'every night: bath, brush, book, bed.'),
          PpCard('Total', 'About 11 to 14 hours in 24 from one to two years, '
              '10 to 13 from three to five.'),
        ]),
      ],
    ),
    PpPage(
      id: 'sleep_preschool',
      title: 'Sleep at this age',
      subtitle: 'Preschooler, 3 to 5 years',
      format: 'CHART',
      bands: ['pre'],
      blocks: [
        PpIntro('Nights are long and mostly unbroken now. The nap goes '
            'somewhere in here, and bad dreams arrive around the same time, '
            'which can look like a step backwards.'),
        PpChartCard(
          title: 'Preschooler, 3 to 5 years',
          subtitle: 'Across a full 24 hours, day and night together',
          rows: [
            ('Total sleep in 24 hours', '10 to 13 hours'),
            ('The honest range', '8 to 14 hours'),
            ('Day naps', '0 to 1'),
            ('Night sleep', '10 to 13 hours'),
            ('Wakes in the night', 'Usually 0'),
          ],
          note: 'If the nap is skipped and your child is still cheerful at '
              '6pm, it is ready to go. If skipping it ends in tears, it is not '
              'yet, and quiet rest on a mat is a fair middle step.',
        ),
        PpCallout('When the nap goes, bedtime needs to come forward by 30 to '
            '60 minutes for a while. That is the whole fix, most of the time.'),
        PpWhenLine('From 3 to 5 years. Most children drop the nap between '
            '3 and 4, some keep it to 5, and both are ordinary.'),
        PpIndiaNote('School or playgroup timings often decide the wake-up, so '
            'work backwards from that to set bedtime rather than forwards from '
            'dinner.'),
        PpCallout(_kRangeReassurance),
        // ⚠️ THE CHECKER LINK IS GONE. The brief: "delete 'check the range
        // for her exact age'". This page IS her exact age now. Kept for
        // revert.
        // PpLink(
        //   'Check the range for your child\'s exact age',
        //   surfaceId: 'pp_sleep_check',
        //   blurb: 'Enter the age in months or years, get the normal range.',
        // ),
      ],
    ),
    // ⚠️ [reformat: was article+diagram] -> ANIMATION. "Short animation of the
    // two cycle waves: she surfaces twice as often as you. Keep the comparison
    // table." The animation carries what the four paragraphs said; the table
    // stays; the prose is kept below for revert.
    PpPage(
      id: 'baby_vs_adult_sleep',
      title: 'Why baby sleep is not like yours',
      subtitle: 'Why babies stir, in plain words',
      format: 'ANIMATION',
      blocks: [
        PpIntro('Most worries about baby sleep get smaller once you know '
            'this: a baby\'s sleep is built differently from yours, and it is '
            'meant to be.'),
        PpAnimation(
          kind: PpAnimationKind.sleepCycles,
          title: 'One night, two rhythms',
          caption: 'Your cycle lasts about 90 minutes. A baby\'s lasts 40 to '
              '50. Every crest is a surfacing, so your baby surfaces about '
              'twice as often as you in the same night. You turn over and go '
              'back down without noticing. Babies learn that later, on their '
              'own, mostly in the second half of the first '
              'year.',
        ),
        /* kept for revert: the article the animation replaced
        PpArticle([
          'Sleep runs in cycles. You go down through light sleep into deep '
              'sleep, come back up, and start again. At the top of each cycle '
              'you surface for a moment, turn over, and go back down without '
              'ever knowing you woke.',
          'Your cycle lasts about 90 minutes. A baby\'s lasts about 40 to 50. '
              'So in the same night your baby surfaces about twice as often.',
          'Babies also spend far more of the night in light sleep. That is not '
              'a flaw. Light sleep lets a baby wake to feed, wake if too warm, '
              'and wake if breathing is not free. It is thought to be '
              'protective. It is one reason very young babies are not built '
              'to sleep like adults.',
          'And babies have not yet learned to go back down alone at the top of '
              'a cycle. That skill comes on its own timetable, mostly in the '
              'second half of the first year, whether or not anyone teaches '
              'it.',
        ]),
        */
        PpTable(
          heading: 'One night, two kinds of sleeper',
          columns: ['', 'Your baby', 'You'],
          rows: [
            ['One sleep cycle', '40 to 50 min', 'About 90 min'],
            ['Time in light sleep', 'About half the night', 'About a quarter'],
            ['Surfaces per night', '10 to 14 times', '4 to 6 times'],
            ['Goes back down alone', 'Learning', 'Without noticing'],
            ['Deep sleep arrives', 'Later in the cycle', 'Early in the cycle'],
          ],
        ),
        PpCallout('Your baby is not waking up. It is surfacing, the way you '
            'do, and sometimes a hand helps getting back down. Those are two '
            'different things, and only one needs anything from you.'),
        PpWhenLine('True from birth. Sleep cycles lengthen slowly and start '
            'to look like an adult\'s at around 4 to 5 years.'),
        PpVideoSlot(
          title: 'How much sleep does a baby need?',
          subtitle: 'A paediatrician walks through the ranges age by age, and '
              'what to do when your baby sits outside them.',
          minutes: '8 MIN',
          slotId: 'sleep/needs_by_age',
        ),
        PpLink(
          'Log a few nights and see your baby\'s own pattern',
          surfaceId: 'pp_sleep',
          blurb: 'Three or four days is usually enough for a shape to appear.',
        ),
      ],
    ),

    // ⚠️ [new] TOOL. "Her current happy-awake window, shown directly. A guide,
    // not a stopwatch: watch her, not the clock." A tool page: the card opens
    // `pp_wake_windows` and these blocks are never rendered. See
    // `PpPage.toolSurfaceId`.
    PpPage(
      id: 'wake_windows',
      title: 'Wake windows',
      subtitle: 'How long your baby can happily stay awake right now',
      format: 'TOOL',
      toolSurfaceId: 'pp_wake_windows',
      blocks: [],
    ),

    // ⚠️ [new] CAROUSEL. "The paradox: more overtired = harder to settle. How
    // to catch the window."
    PpPage(
      id: 'overtired_baby',
      title: 'The overtired baby',
      format: 'CAROUSEL',
      // ⚠️ THIS PAGE IS ITS BLOCK. A Carousel card opens the slides, an
      // Interactive card opens the step-through; there is no page between
      // the tap and the thing, exactly as on the TTC doors. Decided on a
      // phone, 2026-09-11. The intro and notes that sat around the block
      // are kept below for revert and render nowhere.
      blocks: [
        /* kept for revert: the page prose the direct-open replaced
        PpIntro('It sounds backwards, and every parent finds it out the hard '
            'way: a baby who has been awake too long does not go down easier. '
            'It gets harder. Six slides on why, and how to catch the moment '
            'before it happens.'),
        */
        PpCarousel(
          eyebrow: 'The overtired baby',
          hue: 206,
          coverTitle: 'More tired is harder, not easier',
          coverBlurb: 'The paradox that explains most bad bedtimes, and the '
              'window that fixes it.',
          cards: [
            PpCarouselCard(
                'When a baby is kept awake past the window, the body does '
                    'not get sleepier. It gets wired.',
                'Stress hormones rise to keep your baby going. They are the '
                    'same ones that keep you awake after a late night '
                    'of work.'),
            PpCarouselCard(
                'An overtired baby fights sleep, wakes more in the night, '
                    'and is up earlier in the morning.',
                'All three at once. The early morning is the one that fools '
                    'people into a later bedtime still.'),
            PpCarouselCard(
                'The window closes fast. The signs come before the crying, '
                    'and they are small.',
                'A long stare. Rubbing the eyes. Turning away from the toy. '
                    'One yawn. That is the moment, not the meltdown twenty '
                    'minutes later.'),
            PpCarouselCard(
                'If you have missed it, an earlier bedtime tonight does more '
                    'than a later one.',
                'Thirty minutes earlier, for a fortnight. It sounds wrong, '
                    'and it works most often.'),
            PpCarouselCard(
                'Overtired and undertired can look the same at 7pm. The '
                    'difference is the day before it.',
                'Short naps and a long last stretch usually mean overtired. '
                    'A late, long nap usually means the opposite. The log '
                    'tells you which.'),
            // The page's "see her window" link, as the last slide: swipe up
            // opens the tool.
            PpCarouselCard.linked(
                'The awake window lengthens with age, and nothing you do '
                    'sets its pace.',
                'Newborns manage about 45 minutes. By a year it is three to '
                    'four hours. Swipe up to see your baby\'s right now.',
                pageId: 'wake_windows'),
          ],
        ),
        /* kept for revert: the page prose the direct-open replaced
        PpCallout('Catch the window, and bedtime stops being a fight. That '
            'one habit does more than any settling technique in this '
            'section.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpWhenLine('Matters most from about 6 weeks to 2 years, when the '
            'window is short and easy to miss. Older children show it as '
            'wildness at 6pm rather than crying.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpIndiaNote('An evening full of visitors is the easiest way to miss '
            'the window. Everyone wants a cuddle, your baby is passed around, '
            'and by the time the house is calm, the moment has gone. Take '
            'your baby back at the first yawn.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpLink(
          'See your baby\'s window right now',
          surfaceId: 'pp_wake_windows',
          blurb: 'Shown for your baby\'s age, with no numbers to enter.',
        ),
        */
      ],
    ),
  ],
);

// =============================================================================
//  AREA 2 — Night waking and gentle settling
// -----------------------------------------------------------------------------
//  The area the section exists for. The doctor callout appears on the FIRST
//  page as well as on its own page, deliberately: the spec says it must not be
//  buried, and a red flag on page four of an area is buried. The two are worded
//  differently rather than copy-pasted, so the dedicated page is worth opening.
// =============================================================================

final PpArea _nightWaking = PpArea(
  id: 'night_waking',
  mark: IntentMark.moonMark,
  title: 'Waking often at night',
  blurb: 'Why it happens, and gentle ways to settle your baby back down.',
  hue: 268,
  pages: [
    PpPage(
      id: 'why_babies_wake',
      title: 'Why babies wake',
      format: 'CARDS', // [reuse]
      blocks: [
        PpIntro('Almost every night waking has an ordinary cause, and most '
            'are quick to check. Here are the common ones, in the order '
            'worth checking.'),
        PpCards([
          PpCard(
              'Hunger',
              'A small stomach empties in two to three hours. Feed your baby, '
                  'and expect this to be most night wakings under 4 months.'),
          PpCard(
              'Needing to know you are there',
              'Your baby surfaced, could not find you, and called. A hand on '
                  'the chest and a low shush often ends it in under a minute.'),
          PpCard(
              'A developmental leap',
              'New skills wake babies. Rolling, sitting, crawling, standing '
                  'and first words all bring a few unsettled nights. These '
                  'pass in one to three weeks.'),
          PpCard(
              'Looking for the same help as at bedtime',
              'A baby who fell asleep on the breast may look for the breast '
                  'to get back down. That is a sleep association, not a bad '
                  'habit, and you can loosen it slowly if you want to.'),
          PpCard(
              'A wet or dirty nappy',
              'Always change a dirty one. Change a wet one only if your baby is '
                  'bothered or has nappy rash. A full change wakes babies more.'),
          PpCard(
              'Gas or an uncomfortable tummy',
              'Legs pulled up, squirming, a hard little belly. Hold your baby '
                  'upright against your shoulder, or try a slow clockwise '
                  'tummy rub and bicycle legs.'),
          PpCard(
              'Teething',
              'Usually a few bad nights around each tooth, with drooling and '
                  'chewing in the day. Cold teether, extra cuddles, and ask '
                  'your doctor before any medicine.'),
          PpCard(
              'Too hot or too cold',
              'Feel the back of the neck, not the hands. Sweaty means one '
                  'layer off. In an Indian summer, overheating is far more '
                  'common than cold.'),
        ], hue: 268),
        PpCallout('Night waking is not a habit you created. It is how baby '
            'sleep is built, and it changes on its own with age.'),
        PpCallout(
          'Most night waking is ordinary. Ask your doctor if there is pain or '
              'poor weight gain. Ask too if breathing pauses, or your baby goes '
              'blue. The same goes if a settled sleeper suddenly changes for no '
              'clear reason. Those are worth a call, not a wait.',
          kind: PpCalloutKind.doctor,
          title: 'When night waking needs a doctor',
        ),
        PpWhenLine('Wakings peak around 4 months and again around 8 to 10 '
            'months. Both of those are leaps, not setbacks.'),
        PpIndiaNote('In a joint family everyone has a theory about the night '
            'waking, and most are kindly meant. You can check the list above '
            'and leave it there.'),
      ],
    ),
    PpPage(
      id: 'normal_waking_by_age',
      title: 'What is normal night waking',
      subtitle: 'A page to scan, then relax',
      // [reuse] [auto-scope]: "Leads with HER typical wakes; the age arc stays
      // as context behind it." `rowMonths` hoists her row.
      format: 'TABLE',
      blocks: [
        PpIntro('If you only want one thing from this section, it is this '
            'table. Your baby\'s row is at the top. Read across, and see that '
            'your night is the night most parents at this age are having.'),
        PpTable(
          columns: ['Age', 'Typical wakes', 'Why'],
          rowMonths: _kArc,
          rows: [
            [
              '0 to 3 months',
              '3 to 5 a night',
              'Feeding. Tiny stomach, no day-night rhythm yet.'
            ],
            [
              '3 to 6 months',
              '2 to 4 a night',
              'Feeding, plus the 4-month shift in how sleep is organised.'
            ],
            [
              '6 to 12 months',
              '0 to 3 a night',
              'Phases, teeth, and looking for you. Feeds may or may not still '
                  'be needed.'
            ],
            [
              '1 to 3 years',
              '0 to 2 a night',
              'Separation, big dreams, potty, and a nap that ran late.'
            ],
            [
              '3 to 5 years',
              'Usually 0',
              'Bad dreams and night fears, which come in patches and pass.'
            ],
          ],
        ),
        PpCallout('There is no age at which zero wakings is the target. Even '
            'adults surface four to six times a night. The only difference is '
            'that you do not remember it.'),
        PpWhenLine('Use this as a floor, not a goal. Is your child waking more '
            'often than this row for over two or three weeks? With no leap or '
            'illness to explain it, it is worth a conversation.'),
        PpIndiaNote('Where the baby sleeps beside the mother, families tend to '
            'report more brief wakings but less distress at each one. A feed '
            'or a hand comes before the baby is properly awake.'),
        PpVideoSlot(
          title: '"Night waking is normal." What helped us',
          subtitle: 'Three Indian parents on the months they thought something '
              'was wrong, and what turned out to be true.',
          minutes: '9 MIN',
          slotId: 'sleep/real_parents_night_waking',
          hue: 344,
        ),
      ],
    ),
    PpPage(
      id: 'gentle_settling',
      title: 'Gentle ways to settle your baby',
      // [reformat: was step-list] -> VIDEO. "Physical skill: patting, shushing,
      // upright hold, the transfer, on a real baby. Step-list becomes the
      // companion." The slot below is hoisted to the top by the renderer; the
      // five step-lists stay as what she reads after watching.
      format: 'VIDEO',
      blocks: [
        PpIntro('Five gentle ways to help your baby back down, all fine to use '
            'when you sleep side by side. Pick by what is happening tonight, '
            'not by which one is meant to be best.'),
        PpCards([
          PpCard('Patting and shushing',
              'For stirring and grumbling, but not properly awake.'),
          PpCard('Feeding back to sleep',
              'For hunger, and any time it is 3am and you want the '
                  'fastest route back to sleep.'),
          PpCard('Contact settling, in your arms or on your chest',
              'For upset rather than sleepy, or unwell, or in a leap.'),
          PpCard('A dream feed',
              'For a baby who wakes hungry at the same early-night hour, '
                  'when you would rather choose the time than be woken.'),
          PpCard('Slowly using less help',
              'When you want to change something, and only when nothing else '
                  'is going on that week.'),
        ], heading: 'Which one, and when', hue: 268),
        PpSteps(
          heading: 'Patting and shushing',
          [
            PpStep('Get there before your baby is fully awake', 'A stir answered in ten seconds is a stir. The same '
                    'stir answered in two minutes is a cry.'),
            PpStep('Rest a still, warm hand on the chest or back', 'Weight and warmth, not movement. Your baby feels where '
                    'you are.'),
            PpStep('Add a slow pat, about one a second', 'Roughly the speed of a resting heartbeat. Slower than '
                    'feels natural when you are tired.'),
            PpStep('Shush low and long, close to the ear', 'A steady "shhhhh" is closer to the sound of the '
                    'womb than any word is.'),
            PpStep('Slow the pat down, then stop, then lift your hand last', 'Fading out in that order stops the jolt '
                    'awake as you leave.'),
          ],
        ),
        PpSteps(
          heading: 'Feeding back to sleep',
          [
            PpStep('Feed in the dark, with no talking', 'No lights, no nappy change unless it is dirty, no '
                    'phone. Boring is the point.'),
            PpStep('Let your baby come off the feed alone', 'Drifting off latched and full is a job '
                    'done, not a habit made.'),
            PpStep('Hold upright for a minute if there is wind', 'Then lower your baby slowly, feet and bottom first, head '
                    'last.'),
          ],
        ),
        PpSteps(
          heading: 'Contact settling',
          [
            PpStep('Pick your baby up before the crying builds', 'Holding a baby never does harm. Under six '
                    'months, being held is where most babies settle fastest.'),
            PpStep('Hold your baby upright against your chest, ear over your '
                'heart'),
            PpStep('Sway or walk slowly, and hum one thing on repeat', 'One lullaby on a loop works better than three songs.'),
            PpStep('Wait for the heavy arm', 'When the arm flops loose, your baby is deeply asleep. '
                    'Transfers before that mostly fail.'),
            PpStep('Lower bottom first, keep a hand on, then let go', 'Warm your hands and the sheet first if the room is '
                    'cold. Cold sheets wake babies.'),
          ],
        ),
        PpSteps(
          heading: 'A dream feed',
          [
            PpStep('Pick a time about two to three hours after bedtime', 'Usually somewhere between 10pm and 11.30pm.'),
            PpStep('Lift your baby gently and offer the feed without fully '
                'waking', 'Keep the room dark. Many babies feed with their eyes '
                    'shut.'),
            PpStep('Lay your baby back down and go to bed yourself', 'A dream feed is for your sleep. '
                    'If it does not buy you a longer stretch within a week, '
                    'drop it.'),
          ],
        ),
        PpSteps(
          heading: 'Slowly using less help',
          [
            PpStep('Change one thing, and only one', 'Feeding to sleep, or rocking to sleep, or being held '
                    'to sleep. Not two at once.'),
            PpStep('Take one small step back', 'Rocking becomes swaying on the spot. Swaying becomes '
                    'holding still. Holding becomes a hand on the chest.'),
            PpStep('Stay at each step for three to five nights', 'If a step is clearly too big, go back one. Going back '
                    'is not failing.'),
            PpStep('Stop if your baby is ill, teething, in a leap, or you '
                'have travelled', 'Pick it up again in a fortnight. Nothing is lost.'),
            PpStep('You never leave your baby to cry', 'At every step you are there, responding. If a step '
                    'means crying alone, it is the wrong step.'),
          ],
        ),
        PpCallout('Nothing here asks you to leave your baby crying. You stay, '
            'you respond, and you use a little less help each week. That is '
            'the method.'),
        PpWhenLine('Patting, feeding and contact settling work from birth. '
            'Slowly using less help is worth trying from about 6 months, once '
            'night feeds are no longer needed.'),
        PpIndiaNote('If your baby sleeps on your bed, most of this gets easier. '
            'A hand on the chest costs you no getting up. Read the '
            'safer bed-sharing page and set the bed up once.'),
        PpVideoSlot(
          title: 'Gentle settling, demonstrated',
          subtitle: 'Patting, shushing, the upright hold and the transfer, '
              'shown on a real baby at three different ages.',
          minutes: '11 MIN',
          slotId: 'sleep/settling_demo',
        ),
        PpConsult(
          title: 'Gentle infant sleep consultation',
          whoFor: 'For nights that no longer feel manageable, when you have '
              'tried the settling above and want someone to look at your '
              'baby. Gentle and co-sleeping friendly. Never sleep '
              'training, and never crying it out.',
          surfaceId: 'pp_experts',
          role: 'sleep',
        ),
      ],
    ),
    // ⚠️ [reformat: was text list] -> INTERACTIVE. "One big step at a time,
    // dark and dim, tap to advance. Not a long list to read in the dark." The
    // seven steps are unchanged; they moved from a list into the step-through.
    // The list is kept below for revert.
    PpPage(
      id: 'at_3am',
      title: 'What to do at 3am',
      subtitle: 'The short version, for when you cannot read',
      format: 'INTERACTIVE',
      // ⚠️ THIS PAGE IS ITS BLOCK. A Carousel card opens the slides, an
      // Interactive card opens the step-through; there is no page between
      // the tap and the thing, exactly as on the TTC doors. Decided on a
      // phone, 2026-09-11. The intro and notes that sat around the block
      // are kept below for revert and render nowhere.
      blocks: [
        /* kept for revert: the page prose the direct-open replaced
        PpIntro('It is the middle of the night and you are too tired to think. '
            'Tap through this, one step at a time, on a screen dark enough not '
            'to wake either of you. Most nights you will stop at step two.'),
        */
        PpInteractive(
          kind: PpInteractiveKind.night,
          title: 'What to do at 3am',
          blurb: 'Seven steps, one per screen, dark and dim. Tap to advance.',
          items: [
            PpInteractiveItem('Wait ten seconds',
                'Babies grumble in their sleep. A good number of wakings end '
                    'without you.'),
            PpInteractiveItem('Hand on the chest, low shush',
                'No lifting yet, no light, no talking.'),
            PpInteractiveItem('Offer a feed',
                'Under six months, this is almost always the answer, and it '
                    'is the fastest one.'),
            PpInteractiveItem('Check the back of the neck',
                'Sweaty, take a layer off. Cool, add one. Ignore the hands, '
                    'they are always cold.'),
            PpInteractiveItem('Check for a dirty nappy',
                'Change a dirty one. Leave a wet one unless your baby is '
                    'bothered.'),
            PpInteractiveItem(
                'Hold your baby upright on your shoulder for a few minutes',
                'For wind, and for the wakings that are only about wanting '
                    'you.'),
            PpInteractiveItem(
                'Still going, and this is unusual for your baby? Check '
                    'properly',
                'Temperature, breathing, tummy, a wet nappy count for the '
                    'day.'),
          ],
          closing: 'If nothing comforts your baby and this is unusual, read '
              'the doctor page. Under three months, the bar for calling is '
              'deliberately low.',
          closingPageId: 'waking_doctor',
          closingLabel: 'When night waking needs a doctor',
        ),
        /* kept for revert: the list the step-through replaced
        PpSteps(
          heading: 'In order',
          [
            PpStep('Wait ten seconds', 'Babies grumble in their sleep. A good number of '
                    'wakings end without you.'),
            PpStep('Hand on the chest, low shush', 'No lifting yet, no light, no talking.'),
            PpStep('Offer a feed', 'Under six months, this is almost always the answer, '
                    'and it is the fastest one.'),
            PpStep('Check the back of the neck', 'Sweaty, take a layer off. Cool, add one. Ignore the '
                    'hands, they are always cold.'),
            PpStep('Check for a dirty nappy', 'Change a dirty one. Leave a wet one unless your baby '
                    'is bothered.'),
            PpStep('Hold your baby upright on your shoulder for a few minutes', 'For wind, and for the wakings that are only about '
                    'wanting you.'),
            PpStep('If nothing comforts your baby and this is unusual, check '
                'properly', 'Temperature, breathing, tummy, a wet nappy count for '
                    'the day. Then read the doctor page in this area.'),
          ],
        ),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpCards([
          PpCard('Keep the room dark',
              'One dim warm light if you must. Bright light tells a baby\'s body '
                  'it is morning.'),
          PpCard('Leave your phone alone',
              'The screen wakes you up more than your baby, and then you '
                  'are the one who cannot get back to sleep.'),
          PpCard('Skip the maths',
              'Counting the hours you have left is the fastest way '
                  'to stay awake.'),
          PpCard('Swap nights if you can',
              'One person on, one person properly asleep in another room, '
                  'taking turns. Two half-slept people do worse than one '
                  'rested one.'),
        ], heading: 'And for you', hue: 206),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpCallout('Keep 3am boring. Same dark, same quiet, same order every '
            'time. Boring teaches your baby that nothing interesting happens '
            'at night.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpWhenLine('Use this from birth. It stops being needed somewhere in '
            'the second year for most children.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpIndiaNote('If a grandmother or a helper shares the night duty, walk '
            'through these seven steps together once. A shared night works '
            'when everyone does the same thing.'),
        */
      ],
    ),
    PpPage(
      id: 'waking_doctor',
      title: 'When night waking needs a doctor',
      format: 'RED FLAG', // [reuse]
      blocks: [
        PpIntro('Almost all night waking is ordinary. A few things are not, '
            'and they are worth knowing by heart so you never have to '
            'wonder at 2am whether to call.'),
        PpCallout(
          'Call your doctor the same day for any of these. Breathing pauses. '
              'Blue or grey around the lips. Very hard to wake. A fever under '
              'three months of age. Crying that sounds like pain and will not '
              'settle. Far fewer wet nappies than usual.',
          kind: PpCalloutKind.doctor,
          title: 'Same day, not tomorrow',
        ),
        PpCards([
          PpCard('Waking that comes with pain',
              'Screaming that does not settle in your arms, pulling at an ear, '
                  'legs drawn up hard and rigid. Get your baby looked at.'),
          PpCard('Weight that has stopped moving',
              'Waking hungry all night, with weight that has flattened off its '
                  'own line? That is a feeding question for the '
                  'doctor, not a sleep question.'),
          PpCard('Pauses in breathing, or gasping',
              'Brief irregular breathing is normal in newborns. Pauses longer '
                  'than about 20 seconds, gasping, or heavy snoring every '
                  'night are not. Ask.'),
          PpCard('A sudden change with no reason',
              'A settled sleeper who suddenly wakes hourly for more than a '
                  'week, with no tooth, leap, travel or illness to explain it, '
                  'needs a check.'),
          PpCard('Waking that is really reflux',
              'Arching, crying when laid flat, frequent vomiting, sleeping '
                  'far better upright. Treatable. Worth naming to your '
                  'doctor.'),
          PpCard('Night sweats or scratching',
              'Soaked bedding every night, or waking to scratch, can point to '
                  'something ordinary and fixable, like eczema or an iron '
                  'problem. Mention it.'),
        ], heading: 'The specific things to mention', hue: 344),
        PpCallout('Bring your sleep log to the appointment. It saves the '
            'first half of the visit. Times, feeds and what you tried say '
            'more than any description.'),
        PpWhenLine('This page is for any age. Under three months, the bar for '
            'calling is deliberately lower. Call.'),
        PpLink(
          'Open the sleep log to take with you',
          surfaceId: 'pp_sleep',
          blurb: 'A few nights of times and feeds, ready to show.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 3 — Sleep regressions
// -----------------------------------------------------------------------------
//  The three regression pages use an IDENTICAL block order, as the spec
//  requires: intro, what is happening, the quick facts card, signs, how to
//  cope, "this passes", when-line, India note. Identical order is what makes
//  them feel like one library rather than three articles by three people.
// =============================================================================

final PpArea _regressions = PpArea(
  id: 'regressions',
  mark: IntentMark.listMark,
  title: 'When sleep suddenly gets worse',
  blurb: 'The regressions, when they come, and how to get through them.',
  hue: 344,
  pages: [
    PpPage(
      id: 'what_is_regression',
      title: 'What is a sleep regression',
      // [reuse] [auto-scope]: "Article + timeline; auto-marks where she is."
      // The timeline card's `rowMonths` does the marking. Video coming soon:
      // the slot below is that promise.
      format: 'ARTICLE',
      blocks: [
        PpIntro('A baby who was sleeping well starts waking every hour. '
            'Nothing has changed in the room, the routine or the feeding. This '
            'is a regression, and it is almost always a sign of progress.'),
        PpArticle([
          'The word is misleading. Nothing is going backwards. Your baby\'s '
              'brain is learning something new, and while it does, sleep gets '
              'loud.',
          'Every big new skill costs sleep for a while. Rolling, sitting, '
              'crawling, standing, walking, first words, and knowing that you '
              'still exist when you leave the room. Babies practise at night '
              'because the brain is busy with it.',
          'The pattern is nearly always the same: two to six weeks of bad '
              'nights, then sleep settles again, often a little better than '
              'before. The skill arrives and the nights come back.',
          'The real risk is what you might decide in week two at 4am: to '
              'change everything. New rules made while exhausted are hard to '
              'undo by month three.',
        ]),
        PpChartCard(
          title: 'When they typically hit',
          rows: [
            ('Around 4 months', 'Sleep reorganises for good'),
            ('6 to 8 months', 'Sitting, crawling, first separation worries'),
            ('8 to 10 months', 'Pulling up, standing, and missing you'),
            ('11 to 12 months', 'Walking, and the first nap wobble'),
            ('18 months', 'Big feelings, big words, testing limits'),
            ('2 years', 'Dreams, fears, and giving up the cot'),
          ],
          // ⚠️ SPANS, NOT POINTS, so "you are here" lands on the row she is
          // approaching or inside. The gaps between the brief's ages are
          // split so every month from birth to three has one row.
          rowMonths: [(0, 6), (6, 8), (8, 11), (11, 15), (15, 22), (22, 36)],
          note: 'These ages are averages, and babies keep their own '
              'calendars. Two weeks either side is normal, and some babies skip '
              'one entirely.',
          hue: 344,
        ),
        PpCallout('Start nothing new during a regression. Hold your '
            'routine, add help rather than remove it, and change nothing until '
            'the fortnight is over.'),
        PpWhenLine('Expect two to six weeks each time. Bad nights past six '
            'weeks, with no leap to point at, may be something else. Read the '
            'doctor page in the night waking area.'),
        PpIndiaNote('In a joint family a regression is often read as "too '
            'much holding" or "the milk has reduced". It is neither. Calling it '
            'a two-week phase, out loud, takes the pressure off everyone.'),
        PpVideoSlot(
          title: 'Sleep regressions, explained',
          subtitle: 'A child development specialist on what is happening at '
              '4 months, 8 months and 18 months, and what to hold '
              'steady through each one.',
          minutes: '10 MIN',
          slotId: 'sleep/regressions_explainer',
          hue: 344,
        ),
        PpConsult(
          title: 'Gentle infant sleep consultation',
          whoFor: 'For a regression that has run long, or two or three back '
              'to back. You get a plan that never means leaving your baby to '
              'cry. Gentle and co-sleeping friendly.',
          surfaceId: 'pp_experts',
          role: 'sleep',
        ),
      ],
    ),
    PpPage(
      id: 'regression_4m',
      title: 'The 4 month regression',
      // [reuse] [auto-scope]: "Shows in the 3-6mo band; the other regressions
      // surface at their ages." Was also tagged newborn; the brief narrows it.
      format: 'ARTICLE',
      bands: ['m3_6'],
      blocks: [
        PpIntro('This is the one that catches parents out, because it usually '
            'arrives just after the first few good nights. It is also the only '
            'one that is a permanent change rather than a phase.'),
        PpArticle(heading: 'What is happening and why', [
          'Until now there were roughly two states: deep sleep and active '
              'sleep. Around four months, sleep reorganises into the adult '
              'pattern of proper cycles, with real light sleep at the top of each.',
          'So for the first time your baby surfaces properly between cycles, '
              'every 40 to 50 minutes, and notices the room. Fell asleep '
              'on the breast in your arms, and surfaced alone on the bed? Your '
              'baby calls for you.',
          'So this is not a regression at all. Sleep is growing up, and it '
              'does not undo itself. What changes, over the next few months, is '
              'that your baby slowly learns to get back down through those '
              'surfacings.',
        ]),
        PpChartCard(
          title: 'The quick facts',
          rows: [
            ('Usually starts', '3.5 to 4.5 months'),
            ('How long the rough patch lasts', '2 to 6 weeks'),
            ('What is driving it', 'Sleep permanently reorganising'),
            ('Naps in this period', 'Often short, 30 to 45 minutes'),
          ],
          note: 'The nights come back. The new sleep structure stays, and that '
              'is the part that eventually makes long nights possible at all.',
          hue: 344,
        ),
        PpCards([
          PpCard('Naps collapse to 30 or 40 minutes',
              'One cycle, then awake. Very typical of this exact age.'),
          PpCard('Waking every one to two hours all night',
              'Often after a stretch of much better nights, which is what '
                  'makes it feel like a loss.'),
          PpCard('Fighting sleep at bedtime',
              'Going down is harder than it was a month ago.'),
          PpCard('Suddenly hungry again at night',
              'Real hunger, partly. Babies this age are also more distracted '
                  'in the day and feed less then.'),
          PpCard('Rolling and practising in the cot',
              'Rolling often lands in the same weeks and adds to it.'),
        ], heading: 'Signs you are in it', hue: 344),
        PpSteps(
          heading: 'How to get through it',
          [
            PpStep('Hold the bedtime routine exactly as it was', 'Same order, same time. Familiarity is doing more work '
                    'right now than anything clever would.'),
            PpStep('Watch awake windows rather than the clock', 'At this age about 1.5 to 2.5 hours awake. Overtired '
                    'makes every one of these symptoms worse.'),
            PpStep('Feed your baby on waking hungry', 'Don\'t ration night feeds during a leap. This is not '
                    'the fortnight for that.'),
            PpStep('Help your baby back down however works', 'Patting, feeding, holding. Adding help during a '
                    'regression does not create a problem you will have to '
                    'undo.'),
            PpStep('Rescue short naps once a day if you can', 'Hands on, or in a carrier, or beside you. One decent '
                    'nap a day changes the evening.'),
            PpStep('Change nothing else at all', 'No new room, no weaning off feeds, no dropping the '
                    'swaddle unless your baby has started rolling. One thing at a '
                    'time, and this fortnight already has its one thing.'),
          ],
        ),
        PpCallout('This passes. Almost every parent who calls four months '
            'the worst month also calls six months fine. Comforting your baby '
            'through it does not build a problem.'),
        PpWhenLine('Typically 3.5 to 4.5 months, lasting two to six weeks. If '
            'your baby has started rolling, stop swaddling now, tonight, '
            'whatever else is happening.'),
        PpIndiaNote('At this age someone may suggest early solids to "fill the '
            'baby up for sleep". It does not work, and before six months it is '
            'not recommended. Ask your doctor before starting solids for '
            'sleep.'),
      ],
    ),
    PpPage(
      id: 'regression_8_10m',
      title: 'The 8 to 10 month regression',
      // Surfaces at its age. Was also tagged 3 to 6 months.
      format: 'ARTICLE',
      bands: ['m6_12'],
      blocks: [
        PpIntro('This one is loud, and it is mostly about two things. A body '
            'learning to move. And a mind working out that you still exist '
            'after you walk out of the room.'),
        PpArticle(heading: 'What is happening and why', [
          'Between eight and ten months most babies are crawling, pulling to '
              'stand, and cruising along furniture. New motor skills get '
              'practised in light sleep. So you may find your baby standing in '
              'the cot at midnight, crying, unsure how to sit down '
              'again.',
          'At the same time, separation awareness arrives properly. Your baby '
              'now knows you exist somewhere else when out of sight. That is '
              'a much bigger deal to a baby than it sounds. Waking and '
              'finding you gone becomes worth crying about.',
          'Teeth often land in the same window, and the third nap is usually '
              'on its way out too. Three things at once is why this one feels '
              'heavier than four months for some families.',
        ]),
        PpChartCard(
          title: 'The quick facts',
          rows: [
            ('Usually starts', '8 to 10 months'),
            ('How long it lasts', '2 to 6 weeks'),
            ('What is driving it', 'Movement, separation, often teeth'),
            ('Naps in this period', 'Dropping from 3 to 2'),
          ],
          note: 'Sleep usually settles better after this one than before it, '
              'because by the end of it most babies can get back down alone.',
          hue: 344,
        ),
        PpCards([
          PpCard('Standing up in the cot and getting stuck',
              'Pulling up is easy now; lowering down is not yet. Practise '
                  'sitting down from standing in the daytime, on the floor.'),
          PpCard('Crying the moment you leave the room',
              'Separation awareness. Real, and it fades with practice.'),
          PpCard('Refusing one of the naps',
              'Often the third one. That is the nap going, not a problem.'),
          PpCard('Waking at the same time every night',
              'Common in this window and rarely means anything specific.'),
          PpCard('Fussy feeding, chewing everything',
              'Teeth. Usually a few nights per tooth.'),
          PpCard('Only settling for one particular person',
              'Preference is normal at this age and it is not permanent.'),
        ], heading: 'Signs you are in it', hue: 344),
        PpSteps(
          heading: 'How to get through it',
          [
            PpStep('Practise the new skill in daylight', 'Ten minutes a day of pulling up and sitting back '
                    'down. The daytime practice is what shortens the night '
                    'practice.'),
            PpStep('Play peek-a-boo, and narrate leaving', '"Mummy is going and Mummy is coming back." Leaving and '
                    'returning, over and over, in the day, is how separation '
                    'awareness gets easier.'),
            PpStep('Keep the goodnight short and the same', 'A long drawn-out exit gives your baby more to protest '
                    'about, not less.'),
            PpStep('Lower the cot mattress and check the room again', 'Your baby can stand now. Anything out of reach last '
                    'month can be reached this month.'),
            PpStep('Go in, settle, and lay your baby back down', 'Every time you are needed. Responding during a leap '
                    'builds the confidence that ends the leap, not a '
                    'habit.'),
            PpStep('Drop to two naps if the third is being refused', 'Then bring bedtime forward by 20 to 30 minutes for a '
                    'fortnight to cover the lost sleep.'),
          ],
        ),
        PpCallout('This passes, and sleep is usually better afterwards '
            'than before. Every night you go in and settle your baby teaches that '
            'you come back. That is the real lesson of this month.'),
        PpWhenLine('Typically 8 to 10 months, lasting two to six weeks. Lower '
            'the cot base as soon as your baby pulls to stand, not later.'),
        PpIndiaNote('Has your baby just started with a creche, a nanny or a '
            'grandparent while you return to work? Then separation and the '
            'regression stack on top of each other. Extra evening contact '
            'time, for a few weeks, does more than any change to the nights.'),
      ],
    ),
    PpPage(
      id: 'regression_toddler',
      title: 'The toddler sleep wobbles, 18 months and 2 years',
      // Surfaces at its age: 18 months and 2 years are the toddler band.
      format: 'ARTICLE',
      bands: ['tod'],
      blocks: [
        PpIntro('Toddler sleep goes wrong for different reasons than baby '
            'sleep. It is less about the body and more about having '
            'opinions, an imagination, and the ability to climb out.'),
        PpArticle(heading: 'What is happening and why', [
          'Around 18 months your toddler is walking well, talking, and finding '
              'out what it means to be a separate person who can say no. '
              'Bedtime is a very obvious place to try that out.',
          'Around two, imagination arrives. That is a lovely thing in the '
              'day and a complicated one at night. The same mind that '
              'invents a game can invent something behind the cupboard. Real '
              'dreams and night fears start here.',
          'Underneath both, the single nap is under pressure. A nap that is '
              'too late pushes bedtime out. A nap dropped too early means an '
              'overtired toddler by 6pm. Most toddler bedtime battles are '
              'really about nap timing.',
        ]),
        PpChartCard(
          title: 'The quick facts',
          rows: [
            ('Usually starts', '17 to 19 months, and again around 2 years'),
            ('How long it lasts', '2 to 6 weeks'),
            ('What is driving it', 'Independence, language, dreams, nap timing'),
            ('Naps in this period', '1, and sometimes being refused'),
          ],
          note: 'A toddler who refuses the nap for three days and then sleeps '
              'two hours on the fourth has not dropped it. It is still needed.',
          hue: 344,
        ),
        PpCards([
          PpCard('Endless bedtime requests',
              'Water, a wee, one more story, a different blanket. Answer the '
                  'first, then hold the line kindly.'),
          PpCard('Refusing the nap, then falling apart at 5pm',
              'Cap the nap rather than lose it. Even 40 minutes helps.'),
          PpCard('Waking in the night frightened',
              'Real fear, not manipulation. Go, sit close, keep it low and '
                  'brief.'),
          PpCard('Climbing out of the cot',
              'Once your toddler can climb out, the cot is no longer the safe '
                  'option. Move to a low bed or a mattress on the floor.'),
          PpCard('Wanting you to stay until sleep comes',
              'Very common at two. You can sit close by and slowly move the '
                  'chair further out over a couple of weeks.'),
          PpCard('Early morning waking',
              'Often too late a nap, or too late a bedtime. Try earlier, not '
                  'later.'),
        ], heading: 'Signs you are in it', hue: 344),
        PpSteps(
          heading: 'How to get through it',
          [
            PpStep('Fix the nap before you fix the night', 'Nap ends by about 3pm. If it runs to 5pm, bedtime '
                    'cannot work and nothing else you try will matter.'),
            PpStep('Offer two real choices inside the routine', 'Which pyjamas, which story. Choosing something is '
                    'often all the independence your toddler was looking for.'),
            PpStep('Make the routine visual and fixed', 'Four or five pictures on the wall in order. A toddler '
                    'who can see what comes next argues less about it.'),
            PpStep('Take night fears seriously and briefly', '"I know. I am here. Nothing is going to hurt you." '
                    'Then stay a little, and go. Searching the room for '
                    'monsters makes them real.'),
            PpStep('Answer the first request, then stop', 'One drink of water, then "the water is done, I am '
                    'here". Kindly, and the same words every night.'),
            PpStep('Bring bedtime forward by 30 minutes for a fortnight', 'It sounds wrong, and it works most often. '
                    'Overtired toddlers fight sleep harder and wake earlier.'),
          ],
        ),
        PpCallout('This passes too. Toddler sleep is more about steady, kind '
            'repetition than about any technique. The same words, in the same '
            'order, every night, for two weeks.'),
        PpWhenLine('Around 18 months and again around 2 years, two to six '
            'weeks each. Move your toddler out of the cot the week of the first '
            'climb out, not after a fall.'),
        PpIndiaNote('In a joint family the household bedtime is often 10pm or '
            'later, and a toddler cannot sleep through a lit, busy room. If the '
            'timing cannot move, a curtain or partition and a small dim '
            'corner do more than asking everyone to be quiet.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCards(heading: 'The wobbles, by age', [
          PpCard('Around 12 months', 'Walking, new words and a nap change can '
              'all unsettle nights for a week or two.'),
          PpCard('Around 15 months', 'Separation anxiety and dropping to one '
              'nap. Bring bedtime forward while the nap settles.'),
          PpCard('Around 2 years', 'Testing limits at bedtime, fears, and '
              'molars. Keep the routine short and the same.'),
          PpCard('Around 3 years', 'Getting out of bed, resisting the nap, and '
              'night fears. Quiet time can replace the nap.'),
          PpCard('Fighting bedtime', 'Often a sign of too little or too much '
              'daytime sleep. A calm hour before bed, and no screens.'),
        ]),
      ],
    ),
    PpPage(
      id: 'night_weaning',
      title: 'Night weaning, gently',
      // ⚠️ [new] in the brief, but it already existed in collection 2 as
      // "Gently dropping night feeds". Moved here and retitled, not rewritten:
      // the brief's "shows from ~6mo, only once the doctor is happy with her
      // weight, a slow no-battle taper" is exactly what this page already said.
      format: 'ARTICLE',
      bands: ['m6_12', 'tod'],
      blocks: [
        PpIntro('If you want to stop feeding at night, it can be done slowly, '
            'with no crying it out. And if you don\'t want to stop, you '
            'don\'t have to. Plenty of children feed at night into their '
            'second year and are perfectly well.'),
        PpArticle(heading: 'When it makes sense to start', [
          'Wait until your baby is over six months, eating solids reasonably '
              'well, gaining weight along a steady line, and healthy. Before '
              'that, night feeds are food and not comfort.',
          'It also has to be a calm few weeks. Not during teething, not during '
              'an illness, not the week you travel, not the week creche '
              'starts. Choose a boring fortnight.',
          'And be honest about who wants it. If night feeds are working for '
              'you, there is no medical reason to stop them. If you are '
              'exhausted and resentful, that is reason enough on its own.',
        ]),
        PpSteps(
          heading: 'A gentle way to do it',
          [
            PpStep('First, count what is really happening', 'Three or four nights of notes. Most parents are '
                    'surprised by both the number and the times.'),
            PpStep('Offer more food in the day', 'Move calories into daylight before you take them out '
                    'of the night. An extra feed or meal in the afternoon.'),
            PpStep('Pick the easiest feed to drop, not the hardest', 'Usually the smallest feed, or the one '
                    'closest to morning.'),
            PpStep('Shorten it a little every few nights', 'Two minutes less, or one side instead of two, or a '
                    'little less in the bottle. Then a little less again.'),
            PpStep('Replace the feed with the same comfort in another form', 'A hand on the chest, a cuddle, water for a toddler. '
                    'Your baby is not being refused, just answered '
                    'differently.'),
            PpStep('Let your partner take that waking for a few nights', 'Babies look for the breast if the breast is in the '
                    'room. This one step often does most of the work.'),
            PpStep('Then start on the next feed', 'One feed per one to two weeks. Going slowly is '
                    'faster here, because nothing has to be undone.'),
          ],
        ),
        PpCallout('Going backwards is normal. A tooth, a fever or a bad week '
            'will bring a feed back. Feed your baby, and start again when '
            'things are calm. Nothing you did is wasted.'),
        PpCallout(
          'Check with your doctor before dropping night feeds in these cases. '
              'Your baby was born early or small. Weight gain has been slow or '
              'has flattened. Your baby is under six months. Night feeds are '
              'nutrition at that stage, not habit.',
          kind: PpCalloutKind.doctor,
          title: 'Ask first if any of this is true',
        ),
        PpWhenLine('From about 6 months at the earliest, more comfortably from '
            '9 to 12 months. Allow four to six weeks for the whole thing.'),
        PpIndiaNote('If you share a bed, your baby smells milk all night. '
            'Moving your baby to the far side of the bed, or your partner '
            'sleeping between you for a fortnight, is often the gentlest '
            'version of this whole plan.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpArticle(heading: 'Does a dream feed help?', [
          'A dream feed is a feed you give without fully waking your baby, '
              'around 10 or 11 pm, before you go to bed. For some babies it '
              'pushes the next waking later, so your first sleep is longer. For '
              'others it makes no difference, or wakes them more. Try it for a '
              'week. If it does not help, drop it.',
        ]),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 4 — Getting to sleep, in an Indian home
// =============================================================================

final PpArea _gettingToSleep = PpArea(
  id: 'getting_to_sleep',
  mark: IntentMark.blocksMark,
  title: 'Getting your baby to sleep',
  blurb: 'Routines, massage, and what to do when the whole house is awake.',
  hue: 26,
  pages: [
    // ⚠️ [new] VIDEO, PINNED AT THE TOP. "Gentle first, and why; plus the words
    // to push back when family says 'let her cry'. Brand-defining." This is
    // the one place the section says the phrase on purpose. See the header.
    PpPage(
      id: 'sleep_training_stance',
      title: 'Where we stand on sleep training',
      subtitle: 'Gentle first, and the words for when family disagrees',
      format: 'VIDEO',
      pinned: true,
      blocks: [
        PpVideoSlot(
          title: 'Where we stand on sleep training',
          subtitle: 'Three minutes on why we start gentle, what the evidence '
              'does and does not say, and how to answer "just let the baby cry".',
          minutes: '3 MIN',
          slotId: 'sleep/where_we_stand',
          hue: 26,
        ),
        PpIntro('Sooner or later somebody will tell you to let your baby cry. '
            'A relative, a neighbour, an app. It helps to know what we think '
            'before that happens, so the decision stays yours and not '
            'theirs.'),
        PpArticle(heading: 'Gentle first, and why', [
          'We start gentle and stay gentle for as long as gentle is working. '
              'Everything in this section, from patting to slowly using less '
              'help, keeps you in the room and responding. The other way is '
              'not forbidden. But most Indian families share a room or a bed '
              'anyway, and gentle methods are the ones that fit the house and '
              'get followed.',
          'The evidence, honestly: structured methods with some crying, done '
              'carefully at the right age, have not been shown to harm '
              'children in the studies that exist. Nor have they been shown to '
              'make children sleep better a year later than gentler ways. What '
              'they offer is speed. The price is a few very hard nights for '
              'everyone.',
          'So our position is simple. Under six months, never leave a baby '
              'to cry to sleep. After that, gentle may not be enough and '
              'the nights may be wearing you down. Then talk to your doctor, or '
              'a sleep consultant who will not push you. Only if it suits your '
              'family. Never a decision made at 4am because a relative said so.',
        ]),
        PpScript(
          heading: 'The words for when family says "let the baby cry"',
          [
            PpScriptLine(
                say: 'We are doing it the gentle way, and it is working. Give '
                    'us a few more weeks.',
                notThis: 'You are wrong about this.',
                why: 'A plan with a time on it ends the argument. A verdict '
                    'starts a new one.'),
            PpScriptLine(
                say: 'The doctor said not before six months, so we are '
                    'waiting.',
                why: 'True, and it moves the disagreement out of the family '
                    'and onto someone nobody argues with.'),
            PpScriptLine(
                say: 'I know you did it differently and your children are '
                    'fine. This is the way we have chosen.',
                notThis: 'That was harmful.',
                why: 'You are not asking them to admit anything. You are '
                    'asking them to let you parent.'),
            PpScriptLine(
                say: 'Could you take the baby for the first stretch tonight so I '
                    'can sleep? That would help more than anything.',
                why: 'The relative who wants to fix your nights usually also '
                    'wants to help. Give them a way that is not advice.'),
          ],
        ),
        PpCallout('You never have to defend responding to your baby. If '
            'someone in the house needs a reason, "because it is working for '
            'us" is a complete one.'),
        PpWhenLine('This page is for any age. The six-month line is the one '
            'thing in it that is a rule rather than a view.'),
        PpIndiaNote('"Let the baby cry, or it becomes a habit" comes from love, and from a '
            'generation that had less help and more babies. Advice can be '
            'kindly meant and still not be what you do.'),
        PpConsult(
          title: 'Gentle infant sleep consultation',
          whoFor: 'For when gentle is not enough on its own and you want a '
              'plan from someone who will not push you toward crying it out. '
              'Co-sleeping friendly.',
          surfaceId: 'pp_experts',
          role: 'sleep',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCards(heading: 'The methods you will hear about', [
          PpCard('Cry it out', 'Putting the baby down awake and not returning. '
              'Not something we suggest for young babies.'),
          PpCard('Checking in', 'Going back at longer and longer gaps to '
              'reassure, briefly.'),
          PpCard('The chair method', 'Sitting beside the cot and moving the '
              'chair a little further away every few nights.'),
          PpCard('Fading', 'Slowly doing less and less of what helps your '
              'baby fall asleep.'),
          PpCard('Whatever you choose', 'Not before about six months, only if '
              'it suits your family, and only when your baby is well.'),
        ]),
      ],
    ),
    // ⚠️ [reuse] [merge] VIDEO. "Already video + step-list. Absorb 'The hour
    // before bed' as its wind-down section." The wind-down article and its
    // cards now sit after the routine's steps; the separate page is kept
    // commented below the malish page for revert.
    PpPage(
      id: 'bedtime_routine',
      title: 'A calming bedtime routine',
      format: 'VIDEO',
      blocks: [
        PpIntro('A bedtime routine is not about discipline. It is a signal. '
            'The same few things in the same order tell a baby\'s body that '
            'sleep is coming, before anyone asks for sleep.'),
        PpSteps(
          heading: 'The order that works',
          [
            PpStep('Dim the lights, about 30 minutes before', 'One lamp instead of the tube light. Light is the '
                    'strongest signal the body reads, stronger than the '
                    'clock.'),
            PpStep('Bath, or a warm wipe-down', 'Every night or every other night, whichever suits '
                    'your home. Warm water and then cooling down afterwards '
                    'both help sleep.'),
            PpStep('Massage, if it is part of your evening', 'Five to ten minutes of slow oil massage. Calming for '
                    'your baby, and one of the loveliest parts of the day for '
                    'you.'),
            PpStep('Night clothes and a fresh nappy', 'Do this now, not later. A nappy change after your baby '
                    'is asleep undoes the whole routine.'),
            PpStep('Feed, in the dim room', 'Feed here rather than as the very last step, if '
                    'you can, so feeding is not the only thing that means '
                    'sleep. Falling asleep on the feed anyway is fine.'),
            PpStep('One quiet story or one lullaby', 'The same one. Repetition is the point, not variety. '
                    'Newborns get the lullaby, older babies get both.'),
            PpStep('Lights off, and the same cue every night', 'One sentence, one kiss, the same words. "Good night, '
                    'I am here." That sentence becomes the switch.'),
          ],
        ),
        // ---- merged in: 'The hour before bed' (was its own page) ----------
        // "Most bedtime trouble is decided in the hour before bedtime, not
        // at bedtime." The routine above is what happens at bedtime; this is
        // the wind-down that makes it work.
        PpArticle(heading: 'The hour before bed', [
          'Light first, because it matters most. Bright white light in '
              'the evening tells the brain it is still daytime. It delays the '
              'melatonin that brings sleep. Turning off the tube light and '
              'using one warm lamp for the last hour is a real change, '
              'not a nicety.',
          'Screens matter for two reasons, and only one is the light. A '
              'phone or a TV in the last hour is bright, yes, but also '
              'exciting, and an excited brain takes 30 to 40 minutes to come '
              'back down. For under-twos the advice is no screens at all in '
              'the evening. For older children, off an hour before bed.',
          'Then activity level. Rough play, tickling and chasing right before '
              'bed make a very happy child who then cannot sleep. Move the '
              'wild play earlier and keep the last hour low and floor-based: '
              'blocks, books, a slow bath.',
          'One thing that is not on this list: keeping your child up late for '
              'better sleep. It almost never works. An overtired child is '
              'harder to settle and wakes earlier, not later.',
        ]),
        PpCards([
          PpCard('The tube light',
              'One warm lamp instead, for the last hour. The easiest '
                  'change on this page.'),
          PpCard('The TV in the living room',
              'If it cannot go off, turn your baby away from it and go to the '
                  'quiet corner for the last 20 minutes.'),
          PpCard('Phones, including yours',
              'A screen held up during a feed shines light straight into your '
                  'baby\'s eyes.'),
          PpCard('Chasing, tickling and swing games',
              'Wonderful, and not after 7pm.'),
          PpCard('Sugar and a big late meal',
              'A full stomach and a heavy meal too close to sleep make for '
                  'discomfort. Dinner about an hour before.'),
        ], heading: 'What to turn down in the last hour', hue: 26),
        PpCallout('Keep it the same every night. The order matters far more '
            'than the contents. A routine your baby can predict is a routine '
            'that works, on holiday, at the grandparents\' house, and in a '
            'hotel room.'),
        PpWhenLine('Twenty to forty minutes, at roughly the same time every '
            'night. You can start a simple two-step version from about six '
            'weeks. From three months it starts to really pay off.'),
        PpIndiaNote('If you share the room, you cannot dim the whole house. '
            'Dim your baby\'s corner, face away from the light, and put a '
            'curtain or a dupatta over a line beside the bed. The routine has '
            'to fit your home, not a nursery in a catalogue.'),
        PpVideoSlot(
          title: 'A bedtime routine and massage, follow along',
          subtitle: 'Twenty real minutes, start to finish, in a one-room home. '
              'Follow along tonight with your own baby.',
          minutes: '14 MIN',
          slotId: 'sleep/bedtime_malish_followalong',
          hue: 26,
        ),
        PpLink(
          'Put on a lullaby or some white noise',
          surfaceId: 'pp_sleep_sounds',
          blurb: 'Low volume, timer on. Use the same track every night.',
        ),
      ],
    ),
    /* ⚠️ [merge] KEPT FOR REVERT. 'The hour before bed' is folded into the
       routine above as its wind-down section. "Not a separate page."
    PpPage(
      id: 'wind_down',
      title: 'The hour before bed',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Most bedtime trouble is decided in the hour before bedtime, '
            'not at bedtime. Three things do nearly all the work: light, '
            'screens, and how wound up your child is.'),
        PpArticle([
          'Light first, because it matters most. Bright white light in '
              'the evening tells the brain it is still daytime. It delays the '
              'melatonin that brings sleep. Turning off the tube light and '
              'using one warm lamp for the last hour is a real change, '
              'not a nicety.',
          'Screens matter for two reasons, and only one is the light. A '
              'phone or a TV in the last hour is bright, yes, but also '
              'exciting, and an excited brain takes 30 to 40 minutes to come '
              'back down. For under-twos the advice is no screens at all in '
              'the evening. For older children, off an hour before bed.',
          'Then activity level. Rough play, tickling and chasing right before '
              'bed make a very happy child who then cannot sleep. Move the '
              'wild play earlier and keep the last hour low and floor-based: '
              'blocks, books, a slow bath.',
          'One thing that is not on this list: keeping your child up late for '
              'better sleep. It almost never works. An overtired child is '
              'harder to settle and wakes earlier, not later.',
        ]),
        PpCards([
          PpCard('The tube light',
              'One warm lamp instead, for the last hour. The easiest '
                  'change on this page.'),
          PpCard('The TV in the living room',
              'If it cannot go off, turn your baby away from it and go to the '
                  'quiet corner for the last 20 minutes.'),
          PpCard('Phones, including yours',
              'A screen held up during a feed shines light straight into your '
                  'baby\'s eyes.'),
          PpCard('Chasing, tickling and swing games',
              'Wonderful, and not after 7pm.'),
          PpCard('Sugar and a big late meal',
              'A full stomach and a heavy meal too close to sleep make for '
                  'discomfort. Dinner about an hour before.'),
        ], heading: 'What to turn down in the last hour', hue: 26),
        PpCallout('If you change one thing on this page, change the light. '
            'Dim beats everything else, and it costs nothing.'),
        PpWhenLine('Start caring about this from about three months, when the '
            'body clock begins to respond to light at all. It matters most '
            'from one year on.'),
        PpIndiaNote('Evenings in an Indian home are busy and bright by nature, '
            'with people arriving, dinner cooking and the TV on. You won\'t '
            'change all of that. Claim the last twenty minutes and '
            'one dim corner, and that is enough.'),
      ],
    ),
    */

    // ⚠️ [reformat: was step-list] -> VIDEO. "Massage is shown, not read.
    // Flagship India ritual; its own demonstrated video." The routine page's
    // follow-along film includes malish in passing; this slot is the
    // demonstration itself. The steps stay as the companion.
    PpPage(
      id: 'malish',
      title: 'Massage before sleep',
      format: 'VIDEO',
      blocks: [
        PpVideoSlot(
          title: 'Massage before sleep, demonstrated',
          subtitle: 'Every stroke, slowly, on a real baby: legs, arms, chest, '
              'the clockwise tummy, back and head. And the pressure that is '
              'right.',
          minutes: '9 MIN',
          slotId: 'sleep/malish_demo',
          hue: 26,
        ),
        PpIntro('Baby massage is one of the few traditional practices with real '
            'evidence behind it. Babies who are massaged settle a little '
            'faster, cry a little less, and gain weight a little better. It is '
            'also fifteen minutes of undistracted attention, which is its own '
            'reason.'),
        PpArticle([
          'Warm oil, warm hands, and slow strokes. Any of the oils used in '
              'Indian homes are fine on healthy skin. Coconut oil is well '
              'studied and light. Sesame is traditional and warming for '
              'winter. Mustard oil is common in the north but can irritate '
              'sensitive skin, so patch test it first.',
          'Move outwards, from the middle of the body towards the hands and '
              'feet, and on the tummy always clockwise. Press firmly enough '
              'to move the skin, and never so hard that your baby '
              'flinches.',
        ]),
        PpSteps(
          heading: 'How to do it',
          [
            PpStep('Pick a calm time, not just after a feed', 'About 30 to 45 minutes after a feed, and before the '
                    'bath. Not on a full stomach, not on an empty one.'),
            PpStep('Warm the room and warm the oil', 'Stand the oil bowl in warm water. Rub some between '
                    'your palms so it is not cold on the skin.'),
            PpStep('Lay your baby on a towel on the floor or across your legs', 'The traditional legs position is fine for a baby with '
                    'good head control. On the floor is safest.'),
            PpStep('Start at the legs, ankles up to the thighs', 'Long slow strokes, one leg at a time, then the '
                    'feet.'),
            PpStep('Then arms, then hands', 'Same idea. Open the fist gently and stroke each '
                    'finger.'),
            PpStep('Chest, outwards from the middle', 'Both hands from the centre of the chest out to the '
                    'sides, like opening a book.'),
            PpStep('Tummy, always clockwise', 'Slow circles around the navel. This is the part that '
                    'helps with wind. Skip it if the cord stump is still '
                    'there.'),
            PpStep('Back, then finish at the head', 'Turn your baby over, long strokes down the back, then '
                    'very light circles on the head. Nothing forceful on the soft '
                    'spot.'),
            PpStep('Bath, dress, and into the routine', 'Massage, then bath, then bed. Oil left on '
                    'overnight is sticky and does not help.'),
          ],
        ),
        PpCallout('Ten minutes is plenty, and crying means today is not the '
            'day. Stop, cuddle, try tomorrow. Massage is meant to be pleasant '
            'for both of you.'),
        PpCallout(
          'Never put oil into the nose, ears or mouth, however often it is '
              'advised. Oil in the nose can reach the lungs and cause a '
              'serious pneumonia. Stop and ask your doctor if the skin goes '
              'red or bumpy after an oil. Ask too if your baby has eczema, or '
              'was born early and is still very small.',
          kind: PpCalloutKind.doctor,
          title: 'One thing to never do, whoever suggests it',
        ),
        PpWhenLine('From about two weeks, once the cord stump has healed. Ten '
            'to fifteen minutes, once a day, ideally at the same point in the '
            'evening.'),
        PpIndiaNote('If a massage helper comes to your home, watch the first '
            'session. Pulling the limbs hard, cracking, hanging the baby '
            'upside down, and oil in the nose or ears are all still done. '
            'Say no to all of them. Firm, slow, gentle strokes are the '
            'whole technique.'),
        // ⚠️ NO PpLink BACK TO THE ROUTINE PAGE, deliberately. `PpLink` resolves
        // through the router, so it can only point at a SURFACE, not at a
        // sibling page in this section. A link with a null surfaceId renders
        // "SOON", which would be a lie about a page that exists two rows up in
        // the same area. Reported as a gap rather than faked.
      ],
    ),
    PpPage(
      id: 'feeding_to_sleep',
      title: 'Only falls asleep on the feed',
      format: 'ARTICLE', // [reuse] "Sleep-association angle. Links to Feeding."
      blocks: [
        PpIntro('You have probably been told this is a bad habit you will '
            'regret. It helps to know what is true, because the guilt '
            'around this one is far bigger than the problem.'),
        PpArticle(heading: 'Is it a problem?', [
          'Usually not. Feeding to sleep is what babies are designed to do. '
              'Breast milk in the evening carries sleep-inducing compounds, '
              'sucking itself is calming, and the whole arrangement is old and '
              'well tested. Millions of children who fed to sleep every night '
              'now sleep fine.',
          'It is worth loosening in one case only. Feeding is the only way to '
              'sleep, wakings are frequent, nobody else can settle your baby, '
              'and together that has made nights unmanageable. Not because it '
              'is wrong. A single route to sleep leaves you no options on a '
              'bad night.',
          'The mildest way to loosen it is not stopping. It is adding a '
              'second route: being patted, the father\'s arms, or a carrier. '
              'Then feeding to sleep is a choice rather than the only door.',
          'And there is one real health point, separate from sleep. Once '
              'teeth arrive, falling asleep with milk pooling in the mouth '
              'raises the risk of tooth decay. Wipe the gums or brush the '
              'teeth before the last feed rather than after it.',
        ]),
        PpCallout(
          'Myth: feeding to sleep ruins a baby\'s sleep and creates a habit '
              'you will have to break. There is no good evidence for it. What '
              'the evidence does show is that babies who are responded to at '
              'night are not worse sleepers later.',
          kind: PpCalloutKind.myth,
        ),
        PpCards([
          PpCard('Let someone else do bedtime once a week',
              'Not to prove a point. Just so your baby learns there is more '
                  'than one way, and you get one evening.'),
          PpCard('Feed earlier in the routine',
              'Feed, then story, then lights off. Even a two-minute gap '
                  'changes what going down is linked to.'),
          PpCard('Unlatch while drowsy but not gone',
              'Some nights it will be accepted. Some nights not. Both '
                  'are fine; there is no need for a battle.'),
          PpCard('Add a second comfort alongside the feed',
              'The same lullaby, the same hand on the back. In time the comfort '
                  'can work without the feed.'),
          PpCard('Brush or wipe before the last feed',
              'Once teeth arrive. This one is not optional.'),
        ], heading: 'If you want to loosen it', hue: 26),
        PpWhenLine('No need to do anything before six months. If you want to '
            'add a second route to sleep, six to twelve months is a '
            'comfortable window, and it takes two to three weeks.'),
        PpIndiaNote('"You just fed the baby to sleep" gets said as a criticism in a lot '
            'of homes. It is not one. If it is working for you and your baby '
            'is growing well, you have nothing to defend.'),
        // Link out, do not own: feed-to-sleep and the dream feed are Feeding's.
        PpLink(
          'Feeding, the whole section',
          surfaceId: 'pp_section/parenting_feeding',
          blurb: 'Night feeds, the dream feed, and when feeding is the '
              'question rather than sleep.',
        ),
      ],
    ),
    PpPage(
      id: 'day_night_confusion',
      title: 'Sleeps all day, awake all night',
      format: 'ARTICLE', // [reuse]
      bands: ['nb'],
      blocks: [
        PpIntro('In the first weeks a lot of babies have their nights and days '
            'the wrong way round. It is real, it is common, and it is one of '
            'the few sleep problems you can usually fix in about a week.'),
        PpArticle(heading: 'Why it happens', [
          'Newborns have no body clock yet. In the womb, your baby slept and '
              'woke on your rhythm, and was often most active in the evening '
              'when you were finally still. Being born does not change that '
              'overnight.',
          'The body clock is set mostly by light, and it starts working '
              'somewhere between six and twelve weeks. Until then, dark does '
              'not mean night to your baby. Your job is not to teach a '
              'schedule. It is to give clear, steady signals so the clock has '
              'something to set itself '
              'by.',
        ]),
        PpSteps(
          heading: 'How to turn it around',
          [
            PpStep('Make daytime bright and noisy', 'Day naps in a day-lit room, with the normal sounds of '
                    'the house going on. No need to tiptoe.'),
            PpStep('Go outside in the morning light', 'Fifteen to twenty minutes of gentle morning sun on '
                    'the balcony or the terrace. Morning light is the strongest '
                    'tool you have. Avoid harsh midday sun.'),
            PpStep('Wake for a feed if a daytime nap runs past three hours', 'Yes, wake your baby. Daytime sleep taken now is night '
                    'sleep you will not get.'),
            PpStep('Make nights dark, dull and quiet', 'Minimum light, no talking, no eye contact games, '
                    'nappy change only if dirty. Keep the night boring.'),
            PpStep('Give the biggest feeds in the late afternoon and evening', 'Cluster feeding in the evening is normal, and it '
                    'front-loads the calories before the longest stretch.'),
            PpStep('Start a two-minute bedtime cue at the same time nightly', 'Dim, change, feed, lullaby. Far too short to be a '
                    'routine, which is exactly right for this age.'),
          ],
        ),
        PpCallout('Give it seven to ten days of doing the same thing before you '
            'decide it is not working. The clock sets slowly, and it does '
            'set.'),
        PpWhenLine('Most common in the first six weeks. Nearly always sorted '
            'by eight to twelve weeks. Start the light and dark signals from '
            'day one; they cost nothing.'),
        PpIndiaNote('If the household is up until 11pm, your baby\'s "night" '
            'starts when the room goes quiet, not when the clock says so. Pick '
            'the time your home really settles and keep to it, instead of '
            'fighting for 8pm.'),
      ],
    ),
    PpPage(
      id: 'dropping_naps',
      title: 'When naps drop away',
      // [reuse] [auto-scope]: "Naps-by-age arc; auto-marks her stage."
      format: 'CHART',
      blocks: [
        PpIntro('Naps do not vanish overnight. They go one at a time, and each '
            'change brings two or three ragged weeks. Your child\'s stage is '
            'at the top of the table. Knowing which change is due explains '
            'most sudden bedtime trouble.'),
        PpTable(
          heading: 'Naps by age',
          columns: ['Age', 'Naps a day', 'What is changing'],
          rowMonths: [(0, 3), (3, 6), (6, 9), (9, 12), (12, 18), (18, 36), (36, 72)],
          rows: [
            ['0 to 3 months', '4 to 5', 'No pattern at all yet, and that is '
                'correct for this age'],
            ['3 to 6 months', '3 to 4', 'Naps start landing at roughly the same '
                'times'],
            ['6 to 9 months', '3 becomes 2', 'The late afternoon nap goes '
                'first'],
            ['9 to 12 months', '2', 'A morning and an afternoon nap, fairly '
                'settled'],
            ['12 to 18 months', '2 becomes 1', 'The morning nap goes. The '
                'roughest transition of the lot'],
            ['18 months to 3 years', '1', 'One afternoon nap, 1 to 3 hours'],
            ['3 to 5 years', '1 becomes 0', 'Often replaced by quiet rest '
                'rather than sleep'],
          ],
        ),
        PpCards([
          PpCard('Taking ages to fall asleep for the nap',
              'Consistently, for two weeks or more, without being upset about '
                  'it.'),
          PpCard('The nap starts pushing bedtime late',
              'No tiredness at bedtime, because the nap was too long or too '
                  'late.'),
          PpCard('Skipping it happily and staying cheerful till evening',
              'The clearest sign of all. Cheerful is the word that matters.'),
          PpCard('New early morning waking',
              'Sometimes a sign of too much day sleep. Sometimes the opposite. '
                  'Try shortening the nap for a week and see.'),
        ], heading: 'Signs a nap is ready to go', hue: 26),
        PpCallout('Shorten before you drop, and bring bedtime forward when you '
            'do. Cap the nap at an hour for a fortnight, and move bedtime 30 '
            'minutes earlier during the change. Dropping a nap all at once '
            'usually means a week of overtired evenings.'),
        PpWhenLine('Every change takes two to four unsettled weeks. If the nap '
            'is needed again after a week without it, give it back. Nothing '
            'is decided.'),
        PpIndiaNote('The afternoon nap lasts longer in Indian homes than in '
            'Western charts, and the afternoon heat is a real reason. A '
            'four-year-old who still sleeps after lunch in May is doing just '
            'fine.'),
        PpLink(
          'See your child\'s own nap pattern over a few days',
          surfaceId: 'pp_sleep',
          blurb: 'Log four days and the shape usually becomes obvious.',
        ),
      ],
    ),
    PpPage(
      id: 'joint_family_sleep',
      title: 'Sleep in a joint family or a shared room',
      format: 'ARTICLE', // [reuse] India-specific.
      blocks: [
        PpIntro('Most sleep advice assumes a separate nursery, a dark '
            'room and a house that goes quiet at 8pm. If that is not your '
            'home, almost none of it is useless. It just needs translating.'),
        PpArticle(heading: 'The three real problems, and what helps', [
          'First, the household bedtime. If dinner is at 9.30pm and everyone '
              'is up until 11, a baby cannot sleep at 8. Rather than fight the '
              'whole house, pick the earliest time your home is really calm, '
              'and keep that bedtime every night. Consistent and late '
              'beats early and different every day.',
          'Second, light and noise. You cannot dim a room where four people '
              'are living. You can make your baby\'s corner dark. Try a curtain on '
              'a wire, or a dupatta over the cot side away from the door. Turn '
              'the face away from the tube light. Steady sound is much '
              'easier to sleep through than sudden sound. So white noise or a '
              'fan helps more than asking people to whisper.',
          'Third, everybody has an opinion. In a joint family a baby\'s sleep '
              'is a shared subject, and advice arrives whether or not you '
              'asked. What helps is agreeing one routine out loud with '
              'everyone who does bedtime, so they all do the same seven things '
              'in the same order. Different hands are fine. Different '
              'routines are what confuse a baby.',
          'And one real advantage worth naming. In a house with many arms, '
              'you can hand your baby over and sleep. Mothers in nuclear '
              'homes cannot. If someone offers to take the 5am stretch, that '
              'is not a failure on your part. It is one of the best things '
              'about how you live.',
        ]),
        PpCards([
          PpCard('A curtain, not a room',
              'A wire and a dark curtain around your baby\'s corner costs a few '
                  'hundred rupees and does most of what a nursery would.'),
          PpCard('Steady sound over silence',
              'A fan, or low white noise. Steady noise masks the door, the '
                  'kitchen and the TV.'),
          PpCard('One routine, agreed out loud',
              'Whoever does bedtime, same order. Write the seven steps on a '
                  'paper and stick it up if you need to.'),
          PpCard('A separate surface, in your room',
              'A cot or a firm mattress beside your bed is the safest setup '
                  'and it needs no extra room.'),
          PpCard('Share the nights on purpose',
              'Take turns. One person properly asleep is worth more than two '
                  'people half awake.'),
          PpCard('Say the phase out loud',
              'During a regression, tell the house it is a two-week '
                  'phase. It stops six people each suggesting a fix.'),
        ], heading: 'What works in a full house', hue: 26),
        PpCallout('Consistency beats conditions. Picture a bright, noisy, '
            'crowded room with the same routine every night. A baby there '
            'sleeps better than one in a perfect nursery with a new routine '
            'each evening.'),
        PpWhenLine('Worth setting up from about six weeks, and it matters most '
            'between three months and two years.'),
        PpIndiaNote('Sharing your room is recommended, not a compromise. '
            'Sleeping in the same room as you for the first six to twelve '
            'months is associated with a lower risk of SIDS. You are not doing '
            'a second-best version of anything.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpSteps(heading: 'When a toddler and a new baby share a room', [
          PpStep('The baby sleeps in a separate cot', 'Never in the toddler\'s '
              'bed, and with nothing the toddler might put in it.'),
          PpStep('Wait until the baby sleeps longer stretches',
              'Often from about six months, so night feeds do not wake both.'),
          PpStep('Talk it up to the older child', 'A special role: big sibling '
              'of the room.'),
          PpStep('A little white noise helps both', 'At a low volume.'),
        ]),
      ],
    ),
    PpPage(
      id: 'own_space',
      title: 'Moving to a separate cot or room',
      // ⚠️ [new] in the brief, but it already existed in collection 6 as
      // "Moving her to her own bed or room". Moved here and retitled, not
      // rewritten: "India-aware. No right age, family decides; what actually
      // eases the move from your bed to her cot" is what it already says.
      format: 'ARTICLE',
      bands: ['m6_12', 'tod', 'pre'],
      blocks: [
        PpIntro('There is no age at which this has to happen. When you do want '
            'to do it, going slowly and at a calm time makes almost all the '
            'difference.'),
        PpArticle(heading: 'What is going on', [
          'Sharing your room for the first six to twelve months is actively '
              'recommended, so there is nothing to hurry. After that it is a '
              'family decision, not a milestone. Plenty of Indian children '
              'share a room with their parents for years without any harm at '
              'all.',
          'Two things make a move hard: doing it during something else, and '
              'doing it all at once. Avoid the fortnight of a new '
              'sibling, a new school, potty training or a trip. A move then goes '
              'badly, for reasons that have nothing '
              'to do with the room.',
          'What your child is losing is not the bed. It is you nearby. So '
              'change the bed and the room separately, and only one thing '
              'goes at a time.',
        ]),
        PpSteps(
          heading: 'A gentle way to do it',
          [
            PpStep('Pick a calm fortnight', 'No illness, no travel, no new sibling, no new creche, '
                    'no potty training in the same weeks.'),
            PpStep('Make the new bed familiar in the daytime first', 'A week of playing on it, reading on it, napping on '
                    'it. Let your child choose the sheet.'),
            PpStep('Change the surface, not the room', 'A separate mattress or bed, still beside you. One change '
                    'only.'),
            PpStep('Then move the bed, in stages if the room allows', 'A little further away each few nights, or into the '
                    'new room with you sleeping there at first.'),
            PpStep('Keep the bedtime routine exactly the same', 'Same order, same words, same lullaby. The routine '
                    'says nothing important has changed.'),
            PpStep('Say what will happen, and then do exactly that', '"I will sit here until you sleep, and I will be in '
                    'the next room." Then be there. Trust is what makes '
                    'it work.'),
            PpStep('Expect to go back a step, and let that be fine', 'A bad week means one step back, not a failed move.'),
          ],
        ),
        PpCallout('Ending up in your bed at 3am most nights is not a failed '
            'move. Many families settle at exactly this: the night starts in '
            'one bed and finishes in yours. If the bed is set up safely, '
            'that is a perfectly good arrangement.'),
        PpWhenLine('Any time after six to twelve months, and often much later. '
            'Allow two to four weeks and pick a calm fortnight.'),
        PpIndiaNote('Family pressure often pulls both ways: move your child '
            'out early, or stay side by side for years. Neither is a '
            'health question after the first year. It is yours to decide.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCards(heading: 'Cot safety, and moving to a bed', [
          PpCard('Lower the mattress', 'Before your baby can sit, and again to '
              'the lowest setting before standing.'),
          PpCard('Check the cot', 'Bars no more than about 6 cm apart, no '
              'cut-outs in the ends, a mattress with no gap at the sides, and '
              'no loose screws.'),
          PpCard('From about 18 months', 'A thin blanket and one small soft toy '
              'are fine. A small, flat pillow once your child is in a bed.'),
          PpCard('When to move to a bed', 'When your child climbs out, or is too '
              'big for the cot, usually between 18 months and three years. A '
              'mattress on the floor or a low bed with a guard rail is safest.'),
          PpCard('Getting out again and again', 'Walk your child back calmly, '
              'every time, with very few words. A toddler clock that lights up '
              'at wake-up time helps from about two and a half.'),
          PpCard('Bunk beds', 'Not for children under six on the top bunk.'),
        ]),
      ],
    ),

    // ⚠️ [new] CAROUSEL. "Nani's house, a wedding, a festival, a train.
    // Protect the routine, recover after."
    PpPage(
      id: 'sleep_away_from_home',
      title: 'Sleep away from home',
      format: 'CAROUSEL',
      // ⚠️ THIS PAGE IS ITS BLOCK. A Carousel card opens the slides, an
      // Interactive card opens the step-through; there is no page between
      // the tap and the thing, exactly as on the TTC doors. Decided on a
      // phone, 2026-09-11. The intro and notes that sat around the block
      // are kept below for revert and render nowhere.
      blocks: [
        /* kept for revert: the page prose the direct-open replaced
        PpIntro('A wedding, a festival, a week at nani\'s, an overnight train. '
            'Sleep will wobble, and that is not a failure of planning. Six '
            'slides on what to protect, what to let go, and how to get back '
            'to normal afterwards.'),
        */
        PpCarousel(
          eyebrow: 'Sleep away from home',
          hue: 26,
          coverTitle: 'Protect the routine, not the schedule',
          coverBlurb: 'Away from home, the clock will lose. The order of '
              'things can still win.',
          cards: [
            PpCarouselCard(
                'Pack the routine, not the bedtime. The same five steps in '
                    'the same order work in any room.',
                'Dim, change, feed, lullaby, the same last sentence. Twenty '
                    'familiar minutes, wherever they happen.'),
            PpCarouselCard(
                'Bring the three things that smell of home: the usual sheet, '
                    'the sleep sack, and the sound your baby sleeps to.',
                'Download the track before you leave. A train has no '
                    'network and a wedding has no quiet.'),
            PpCarouselCard(
                'At a wedding, one adult owns bedtime, and everyone else '
                    'gets to enjoy the wedding.',
                'Decide who before the baraat, not at 11pm. Swap the next '
                    'night if it is more than one.'),
            PpCarouselCard(
                'At the grandparents\' house, agree the routine out loud on day one, '
                    'kindly, and then let Grandma do it her way inside it.',
                'Different hands are fine. A different order is what '
                    'confuses a baby.'),
            PpCarouselCard(
                'On a train, feed and settle your baby in the berth you will '
                    'use all night. Moving a sleeping baby rarely works.',
                'Lower berth, wall side, your body on the open side. A '
                    'dupatta on the window hook makes a curtain.'),
            PpCarouselCard(
                'Coming home: expect two or three off nights, hold the '
                    'routine, and change nothing else.',
                'No new habit forms in a week. It was just a different '
                    'week. It settles.'),
            // The page's "download the sound she sleeps to" link, as a slide:
            // swipe up opens the library.
            PpCarouselCard.linked(
                'Before you go: download the two or three sounds your baby '
                    'really sleeps to.',
                'A train has no network and a wedding has no quiet. Swipe up '
                    'for the library.',
                pageId: 'sleep_sounds_library'),
            // Added 2026-10-02 from the parenting gap analysis (P3).
            PpCarouselCard('Jet lag',
                'After crossing time zones, get into daylight together in the '
                    'morning and keep naps short. Most babies adjust by about '
                    'a day per hour of time difference.')
          ],
        ),
        /* kept for revert: the page prose the direct-open replaced
        PpCallout('Late is fine. Different is the problem. A baby put down '
            'at 11pm with the usual routine sleeps better than one put down at '
            '8pm with somebody else\'s.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpWhenLine('Matters from about 3 months, once there is a routine to '
            'protect. Under 3 months, babies mostly sleep anywhere. That is '
            'the one advantage of a newborn at a wedding.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpIndiaNote('Nobody at a family function will think less of you for '
            'taking your baby to a quiet room at bedtime. They will think less '
            'of anyone who kept your baby up. Go.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpLink(
          'Download the sound your baby sleeps to',
          surfaceId: 'pp_sleep_sounds',
          blurb: 'Two or three tracks, saved before you travel.',
        ),
        */
      ],
    ),
  ],
);

// =============================================================================
//  AREA 5 — Safe sleep
// -----------------------------------------------------------------------------
//  ⚠️ THE HARM-REDUCTION AREA. Read the header note before editing any copy
//  here. Bed-sharing leads with HOW, and the short list of nights where the
//  answer is genuinely "not tonight" is specific rather than absolute, because
//  a specific list gets followed and a blanket ban does not.
// =============================================================================

final PpArea _safeSleep = PpArea(
  id: 'safe_sleep',
  mark: IntentMark.checkMark,
  title: 'Keeping your baby safe during sleep',
  blurb: 'Safer bed-sharing, back to sleep, and what to clear away.',
  hue: 152,
  pages: [
    // ⚠️ [reformat: was article] -> ILLUSTRATION. "One labelled safe-setup
    // picture + what to clear away. Keep the harm-reduction wording under
    // it." The eight setup steps became the eight labels on the picture; the
    // article and the step-list are kept below for revert. The two card
    // groups (what raises the risk, what lowers it) and both callouts are the
    // harm-reduction wording and stay exactly as they were.
    PpPage(
      id: 'safer_bed_sharing',
      title: 'Safer bed-sharing',
      subtitle: 'How to share a bed with fewer risks',
      format: 'ILLUSTRATION',
      blocks: [
        PpIntro('Most Indian families sleep with their baby, and an app will '
            'not change that. So here is the useful version. One picture of a '
            'bed set up more safely, what to clear away, and the few nights '
            'when your baby needs a separate surface.'),
        PpIllustration(
          kind: PpIllustrationKind.safeBedSetup,
          title: 'One bed, set up once',
          labels: [
            PpIllustrationLabel('Firm mattress, flat, no dip',
                'Cotton or coir is good. Soft foam, a waterbed or a folded '
                    'quilt as a bed are not.'),
            PpIllustrationLabel('No gap between the bed and the wall',
                'Flush against it, or pulled right away from it. The gap is '
                    'the most common serious hazard.'),
            PpIllustrationLabel(
                'On the back, beside you, not between two adults',
                'Mother\'s side is safest. You stay aware of your baby in a way '
                    'another adult usually does not.'),
            PpIllustrationLabel('Pillows and bolsters away from your baby',
                'Keep the head clear of your pillow. A bolster is not a '
                    'barrier. It is a hazard.'),
            PpIllustrationLabel('A separate light layer instead of a cover',
                'A sleep sack or a light kurta-pyjama, so your blanket never '
                    'needs to come over your baby.'),
            PpIllustrationLabel('Your blanket no higher than your waist',
                'On your baby\'s side.'),
            PpIllustrationLabel('Hair tied back, no cords, no dupatta',
                'Loose hair and drawstrings are a strangling risk at close '
                    'quarters.'),
            PpIllustrationLabel('A low bed, or a mattress on the floor',
                'A firm mattress on the floor, away from walls and furniture, '
                    'is one of the safest setups there is.'),
          ],
          caption: 'Nearly all bed-sharing risk comes from the surface and '
              'the bedding, not from the sharing. One evening of rearranging '
              'removes most of it.',
        ),
        /* kept for revert: the article and the step-list the picture replaced
        PpArticle(heading: 'Start with the bed itself', [
          'Nearly all bed-sharing risk comes from the surface and the bedding, '
              'not from the sharing. A firm mattress, no gap, no quilt over '
              'your baby, and nothing soft near the face removes most of it in '
              'one evening of rearranging.',
          'The dangerous versions are specific and worth knowing exactly. Soft '
              'surfaces a baby can sink into. Heavy bedding that can cover the '
              'face. Gaps between the mattress and the wall, or the bed and '
              'the cot. Being wedged against a pillow or a bolster. And an '
              'adult who cannot sense the baby because of alcohol, sedating '
              'medicine or extreme exhaustion.',
          'A very common and very avoidable one: falling asleep with your baby '
              'on a sofa or an armchair. That is far more dangerous than a '
              'properly set up bed, because a baby can slide into the gap '
              'between you and the cushions. If you are feeding at night and '
              'might drift off, do it in the bed, set up as below, not in a chair.',
        ]),
        PpSteps(
          heading: 'Setting the bed up once',
          [
            PpStep('Firm mattress, flat, no dip', 'A firm Indian cotton or coir mattress is good. Soft '
                    'foam, memory foam, a waterbed or a folded quilt as a bed '
                    'are not.'),
            PpStep('Close every gap', 'Push the bed flush against the wall or pull it away '
                    'from the wall entirely. A gap between the mattress and '
                    'the wall is the most common serious hazard.'),
            PpStep('Lay your baby on the back, beside you, not between two adults', 'Mother\'s side is safest. A mother sleeping alongside '
                    'stays aware of the baby in a way another adult '
                    'usually does not.'),
            PpStep('Move pillows, bolsters and quilts away from your baby', 'Keep the head clear of your pillow. No bolster '
                    'alongside, no quilt over the top.'),
            PpStep('Dress your baby in a light layer instead of a cover', 'A sleep sack or a light kurta and pyjama, so your '
                    'blanket never needs to come over your baby.'),
            PpStep('Keep the blanket at your waist', 'Your own bedding comes no higher than your waist on '
                    'your baby\'s side.'),
            PpStep('Tie long hair back and take off cords and dupattas', 'Loose hair, drawstrings and dupattas are a strangling '
                    'risk at close quarters.'),
            PpStep('If the bed is high, put a mattress on the floor', 'A firm mattress on the floor, away from walls and '
                    'furniture, is one of the safest setups there is.'),
          ],
        ),
        */
        PpCards([
          PpCard('A soft or sagging mattress',
              'A baby can sink, and the face can be covered. The most '
                  'important thing to change.'),
          PpCard('Quilts and heavy blankets over your baby',
              'A light layer of your baby\'s own instead.'),
          PpCard('Pillows and bolsters alongside',
              'Clear a space around the head. Bolsters are not a safety '
                  'barrier. They are a hazard.'),
          PpCard('A gap between the bed and the wall',
              'Or between the bed and a cot pushed alongside. Close it or '
                  'remove it.'),
          PpCard('Sleeping with your baby on a sofa or armchair',
              'Much riskier than a proper bed. Never on purpose, and be '
                  'careful about drifting off.'),
          PpCard('Other children or pets in the bed',
              'An older sibling cannot sense a baby the way you can.'),
        ], heading: 'What raises the risk', hue: 152),
        PpCards([
          PpCard('A separate firm flat surface, in your room',
              'A cot or a firm mattress right beside your bed gives you the '
                  'closeness with none of the bedding risk.'),
          PpCard('Breastfeeding',
              'Linked to a lower risk. It also puts you in the curled '
                  'position that naturally keeps your baby\'s space clear.'),
          PpCard('On the back, every time',
              'Day naps included, and by whoever puts your baby down.'),
          PpCard('A smoke-free home',
              'Nobody smoking anywhere in the house, and not on the balcony in '
                  'the same clothes your baby is then held in.'),
          PpCard('Room sharing for the first year',
              'Same room, separate surface or a safely set up bed. Lower risk '
                  'than a separate room.'),
          PpCard('A comfortable room temperature',
              'Not overheated. Overheating is a known risk, and it is the one '
                  'Indian homes get wrong most often.'),
        ], heading: 'What lowers the risk', hue: 152),
        PpCallout('If you change one thing tonight, close the gap and get the '
            'quilt off your baby. Those two take five minutes and remove most '
            'of the risk in a shared bed.'),
        PpCallout(
          'On these nights, put your baby on a separate firm surface instead. '
              'Anyone in the bed has had alcohol or a sedating medicine. Anyone '
              'smokes. You are so exhausted you cannot be roused. Or your baby '
              'was born before 37 weeks or under 2.5 kg and is still under '
              'three months. If your baby was born early or small, ask your '
              'doctor about your own situation.',
          kind: PpCalloutKind.doctor,
          title: 'Nights for a separate surface',
        ),
        PpWhenLine('Set the bed up before the birth if you can. The risks '
            'are highest in the first three months and drop a lot after six.'),
        PpIndiaNote('Bed-sharing itself is normal here, and there is no need '
            'to feel defensive about it. What is worth changing is the heavy quilt, '
            'the bolsters and the gap against the wall, because those are what '
            'the real risk is made of.'),
        PpVideoSlot(
          title: 'Safe sleep, set up in a real Indian bedroom',
          subtitle: 'A paediatrician walks through one ordinary bed and one '
              'ordinary cot, and shows exactly what to move.',
          minutes: '9 MIN',
          slotId: 'sleep/safe_sleep_setup',
          hue: 152,
        ),
      ],
    ),
    // ⚠️ [reformat: was short article] -> ILLUSTRATION. "A simple visual:
    // back is the way, every sleep." The four paragraphs became four labels;
    // the prose is kept below for revert. Both callouts stay.
    PpPage(
      id: 'back_to_sleep',
      title: 'On the back, every sleep',
      format: 'ILLUSTRATION',
      blocks: [
        PpIntro('This is the most effective piece of safe sleep advice '
            'there is. Putting babies on their backs to sleep cut cot deaths '
            'by more than half in every country that ran the campaign.'),
        PpIllustration(
          kind: PpIllustrationKind.backToSleep,
          title: 'Back is the way',
          labels: [
            PpIllustrationLabel('On the back, every sleep',
                'Day naps included, by whoever puts your baby down. The risk '
                    'sits with the unfamiliar position somebody else uses.'),
            PpIllustrationLabel('Not on the side',
                'Babies roll onto the front from there easily.'),
            PpIllustrationLabel('Not on the front',
                'The position with the highest risk, and the deeper sleep it '
                    'gives is exactly why.'),
            PpIllustrationLabel('Once your baby rolls over alone, leave it',
                'Usually four to six months. Lay your baby down on the back. '
                    'Rolling over after that is allowed. A clear surface is '
                    'what matters by then.'),
          ],
          caption: 'Back sleeping flattens the back of the head a little in '
              'some babies. It evens out with sitting and crawling. Awake, '
              'watched tummy time is the answer to that, not front sleeping.',
        ),
        /* kept for revert: the article the picture replaced
        PpArticle([
          'On the back, for every sleep, day naps included, by whoever puts '
              'your baby down. That last part matters. Many babies go on their '
              'backs at night and on their fronts for a day nap with someone '
              'else, and the risk sits with the unfamiliar position.',
          'Side lying is not a safe alternative. A baby on the side rolls onto '
              'the front easily, and the front is the position linked to '
              'the highest risk.',
          'Once your baby can roll over alone, usually somewhere between four '
              'and six months, you do not have to turn your baby back all '
              'night. Lay your baby down on the back. Rolling onto the front '
              'after that is allowed. What matters by then is that the '
              'surface all around is clear.',
          'Back sleeping does flatten the back of the head a little in some '
              'babies. It evens out on its own with sitting and '
              'crawling. Plenty of tummy time, awake and watched, '
              'is the answer to it, not front sleeping.',
        ]),
        */
        PpCallout(
          'Myth: a baby on the back will choke on milk that comes up. Not so. '
              'A baby\'s airway is built so that milk drains away in that '
              'position, and babies who sleep on their fronts are not '
              'protected from choking. This one has been studied carefully.',
          kind: PpCalloutKind.myth,
        ),
        PpCallout('Tell everyone who puts your baby down. Grandmothers, the '
            'nanny, the creche. On the back, every single sleep. It is the most '
            'important sentence in this whole section.'),
        PpWhenLine('Every sleep from birth until your baby rolls alone, '
            'usually four to six months. Awake tummy time from the first '
            'weeks, several short sessions a day.'),
        // Added 2026-10-02 from the parenting gap analysis (P1, ADD TO OURS:
        // What to Expect's "can babies sleep with a pillow" piece).
        PpCallout('No pillow for a baby, including the small mustard '
            'seed pillow. A soft surface near the face is a suffocation risk, '
            'and babies do not need one: their head shape and neck are made '
            'for a flat surface. A small, flat, firm pillow is fine once your '
            'child has moved from a cot to a bed, usually after two years.',
            kind: PpCalloutKind.safety,
            title: 'And when is a pillow fine?'),
        PpIndiaNote('Front sleeping is still advised in a lot of Indian '
            'homes, because babies do settle more deeply on their fronts. That '
            'deeper sleep is exactly why it is riskier. Say so plainly and '
            'kindly to whoever suggests it.'),
      ],
    ),
    // ⚠️ [reformat: was step-list] -> VIDEO. "Physical skill + safety: the
    // hip-safe wrap, and stopping the day she can roll." The steps stay as
    // the companion under the film.
    PpPage(
      id: 'swaddling',
      title: 'Swaddling, and when to stop',
      format: 'VIDEO',
      bands: ['nb', 'm3_6'],
      blocks: [
        PpVideoSlot(
          title: 'The hip-safe swaddle, and the day to stop',
          subtitle: 'The diamond fold, snug at the chest and loose at the '
              'hips, on a real newborn. And what a first roll looks like.',
          minutes: '5 MIN',
          slotId: 'sleep/swaddle_demo',
          hue: 152,
        ),
        PpIntro('A snug wrap helps a lot of newborns settle, because it stops '
            'the startle reflex from waking them. Done loosely around the '
            'hips, arms in, and stopped at the right moment, it is a good '
            'tool.'),
        PpSteps(
          heading: 'How to swaddle',
          [
            PpStep('Use one thin cotton sheet', 'Thin muslin or cotton. Not a blanket, not a quilt, '
                    'and one layer only. Overheating is the main risk.'),
            PpStep('Lay it as a diamond and fold the top corner down', 'Your baby\'s shoulders sit just below that folded edge.'),
            PpStep('Lay your baby on the back, head clear of the cloth', 'Nothing comes above the shoulders. Ever.'),
            PpStep('Bring one side across the chest and tuck it under', 'One arm goes down by the side, inside the wrap.'),
            PpStep('Fold the bottom up loosely', 'Loose over the legs. Your baby must be able to bend the '
                    'knees up and out. A tight straight wrap over the hips can '
                    'harm hip development.'),
            PpStep('Bring the other side across and tuck it in', 'Snug across the chest, and loose at the hips. You '
                    'can fit two or three fingers between the cloth and the '
                    'chest.'),
            PpStep('Lay your baby down on the back, in the same clear space', 'A swaddled baby must never be put down on the front '
                    'or side. With arms wrapped, a baby cannot move the head free.'),
          ],
        ),
        PpCallout('Stop swaddling the day your baby shows any sign of rolling, '
            'even a first attempt. A swaddled baby who rolls onto the front '
            'cannot push back up. Usually somewhere between eight and twelve '
            'weeks. Move to a sleeping bag with arms out.'),
        PpCallout(
          'Ask your doctor before swaddling if your baby was born early, has '
              'been treated for hip dysplasia, or has been advised to '
              'sleep in a particular position. Loosen it straight away if '
              'the chest, neck or back feels sweaty or breathing is '
              'fast.',
          kind: PpCalloutKind.doctor,
          title: 'When to check first',
        ),
        PpWhenLine('From birth to about 8 to 12 weeks, and stop the moment your '
            'baby tries to roll, whichever comes first.'),
        PpIndiaNote('The traditional tight wrap, with the legs straightened '
            'and the cloth pulled firm, is the version to avoid. Snug arms, '
            'loose hips is the change, and it is a small one.'),
      ],
    ),
    // ⚠️ [reuse] as INTERACTIVE. "An interactive tap-through checklist.
    // Already cards/checklist." The eleven cards are now eleven checks, each
    // answered done or not yet, ending on what to change tonight. The cards
    // are kept below for revert.
    PpPage(
      id: 'sleep_surface',
      title: 'Your baby\'s sleep space, checked',
      format: 'INTERACTIVE',
      // ⚠️ THIS PAGE IS ITS BLOCK. A Carousel card opens the slides, an
      // Interactive card opens the step-through; there is no page between
      // the tap and the thing, exactly as on the TTC doors. Decided on a
      // phone, 2026-09-11. The intro and notes that sat around the block
      // are kept below for revert and render nowhere.
      blocks: [
        /* kept for revert: the page prose the direct-open replaced
        PpIntro('Two minutes, once. Tap through eleven checks and answer each '
            'one honestly; it ends on the short list of what to change. Then '
            'repeat it with each new skill, because a baby who can roll, sit '
            'or stand can reach things that were out of reach last '
            'month.'),
        */
        PpInteractive(
          kind: PpInteractiveKind.checklist,
          title: 'Your baby\'s sleep space, checked',
          blurb: 'Eleven checks, done or not yet. Ends on what to fix.',
          hue: 152,
          items: [
            PpInteractiveItem('Firm and flat',
                'A firm mattress that does not dip under your baby\'s weight. '
                    'Press it with your palm. If your hand sinks, so will your baby.',
                'The surface'),
            PpInteractiveItem('A tight-fitting sheet, and nothing under it',
                'No folded towel or extra padding underneath for softness.',
                'The surface'),
            PpInteractiveItem('No gaps anywhere',
                'Between the mattress and the cot sides, between the bed and '
                    'the wall, between a cot and a bed pushed together.',
                'The surface'),
            PpInteractiveItem('Flat, not inclined',
                'No wedge, no propping the mattress up, no sleeping in a car '
                    'seat, bouncer or rocker. A baby can slump forward and '
                    'block the airway.',
                'The surface'),
            PpInteractiveItem('A separate space in your room',
                'Same room as you for the first six to twelve months. Own '
                    'surface, or a safely set up bed.',
                'The surface'),
            PpInteractiveItem('No pillows or bolsters',
                'No pillow at all under one year. Bolsters are not a barrier '
                    'and they are a hazard.',
                'Clear away'),
            PpInteractiveItem('No quilts or loose blankets',
                'Dress your baby in a light layer instead. If you use a blanket, '
                    'it is thin, tucked in low, and no higher than the chest.',
                'Clear away'),
            PpInteractiveItem('No soft toys or bumpers',
                'Nothing soft in the space until one year. Cot bumpers '
                    'included, even the pretty ones.',
                'Clear away'),
            PpInteractiveItem('No cords, dupattas or mobile strings',
                'Curtain cords, charger cables and hanging toys, all out of '
                    'reach. Check the reach again once your baby starts standing.',
                'Clear away'),
            PpInteractiveItem('Nothing that can be pulled down onto the face',
                'A towel over the cot rail, clothes hung on the side, a '
                    'mosquito net that can sag onto the face.',
                'Clear away'),
            PpInteractiveItem('No cigarette smoke, anywhere in the home',
                'Not in the room, not on the balcony, not in the clothes your '
                    'baby is then held in.',
                'Clear away'),
          ],
          closing: 'If it is soft, loose, or can end up over the face, it '
              'does not belong in the sleep space until your baby is one.',
        ),
        /* kept for revert: the cards the checklist replaced
        /* kept for revert: the page prose the direct-open replaced
        PpCards([
          PpCard('Firm and flat',
              'A firm mattress that does not dip under your baby\'s weight. '
                  'Press it with your palm. If your hand sinks, so will your baby.'),
          PpCard('A tight-fitting sheet, and nothing under it',
              'No folded towel or extra padding underneath for softness.'),
          PpCard('No gaps anywhere',
              'Between the mattress and the cot sides, between the bed and the '
                  'wall, between a cot and a bed pushed together.'),
          PpCard('Flat, not inclined',
              'No wedge, no propping the mattress up, no sleeping in a car '
                  'seat, bouncer or rocker. A baby can slump forward and '
                  'block the airway.'),
          PpCard('A separate space in your room',
              'Same room as you for the first six to twelve months. Own '
                  'surface, or a safely set up bed.'),
        ], heading: 'The surface', hue: 152),
        */
        PpCards([
          PpCard('Pillows and bolsters',
              'No pillow at all under one year. Bolsters are not a barrier and '
                  'they are a hazard.'),
          PpCard('Quilts and loose blankets',
              'Dress your baby in a light layer instead. If you use a blanket, '
                  'it is thin, tucked in low, and no higher than the chest.'),
          PpCard('Soft toys and bumpers',
              'Nothing soft in the space until one year. Cot bumpers included, '
                  'even the pretty ones.'),
          PpCard('Cords, dupattas and mobile strings',
              'Curtain cords, charger cables and hanging toys, all out of '
                  'reach. Check the reach again once your baby starts standing.'),
          PpCard('Anything that can be pulled down onto the face',
              'A towel over the cot rail, clothes hung on the side, a mosquito '
                  'net that can sag onto the face.'),
          PpCard('Cigarette smoke, anywhere in the home',
              'Not in the room, not on the balcony, not in the clothes your '
                  'baby is then held in.'),
        ], heading: 'Clear away', hue: 152),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpCallout('The test is simple. If it is soft, loose, or can end up '
            'over the face, it does not belong in the sleep space until your '
            'baby is one.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpWhenLine('Check it before your baby comes home, then again with '
            'rolling, sitting and standing. The strict version applies for the '
            'first twelve months.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpIndiaNote('The mosquito net is the one that gets forgotten. Use a '
            'frame net that stays tented well above your baby, not one draped '
            'over the cot that can sag onto the face. Check there is no gap '
            'an arm or the head can get into.'),
        */
      ],
    ),
    PpPage(
      id: 'overheating',
      title: 'Too warm, and how to tell',
      format: 'ARTICLE', // [reuse]
      blocks: [
        PpIntro('In Indian homes overheating is far more common than cold, '
            'and it matters, because being too warm is one of the known '
            'risk factors for cot death. The good news: it is easy to '
            'check.'),
        PpArticle([
          'Feel the back of the neck, or the chest, or the tummy. Not the '
              'hands and not the feet. A baby\'s hands and feet are meant to '
              'be cool. Every layer added because the hands felt cold is a '
              'layer your baby did not need.',
          'For dressing, the rule of thumb is what you are comfortable in, '
              'plus one thin layer. Not three. A baby cannot take off a cap '
              'or push down a quilt, so there is no way to fix it alone.',
          'Aim for a room somewhere around 20 to 24 degrees if you can control '
              'it. Most Indian homes cannot for much of the year, and that is '
              'fine. In a hot room, fewer layers and moving air is the answer. '
              'A fan is safe and is even linked to lower risk. Point '
              'it at the room and not straight at your baby.',
          'One thing to drop entirely: the indoor topi. Babies lose heat '
              'through their heads, which is how they cool themselves down. A '
              'cap indoors, on a sleeping baby, in an Indian summer, is worth '
              'taking off.',
        ]),
        PpChartCard(
          title: 'What to dress your baby in for sleep',
          rows: [
            ('Hot room, over 26', 'Just a nappy and a thin cotton vest'),
            ('Warm, 24 to 26', 'A thin full-sleeve cotton suit'),
            ('Comfortable, 20 to 24', 'A cotton suit and a light sleeping bag'),
            ('Cool, 18 to 20', 'A cotton suit, socks, a warmer sleeping bag'),
            ('Cold, under 18', 'Add a thin layer under the suit, no loose '
                'blanket'),
          ],
          note: 'Layers you can remove beat one thick layer you cannot. And no '
              'hat indoors at any temperature.',
          hue: 152,
        ),
        PpCards([
          PpCard('Sweaty neck, back or hair',
              'The clearest sign. One layer off.'),
          PpCard('Flushed cheeks and a warm chest',
              'Combined with sweating, take a layer off and open the room '
                  'up.'),
          PpCard('Breathing faster than usual',
              'Along with feeling hot. Cool your baby down and keep watching.'),
          PpCard('Heat rash on the neck and chest',
              'Tiny red bumps in the folds. Too many clothes.'),
          PpCard('Unusually sleepy and hard to rouse when hot',
              'Cool your baby down and call your doctor.'),
        ], heading: 'Signs of being too warm', hue: 152),
        PpCallout('Back of the neck, not the hands. If it is sweaty, one layer '
            'comes off. That is the whole check, and it takes three seconds.'),
        PpWhenLine('Check at every sleep in summer, and any time your baby '
            'seems unsettled for no reason. Most relevant in the first year.'),
        PpIndiaNote('Sweater, topi and socks indoors in October is standard '
            'advice in a lot of families, and it comes from real love. The '
            'gentlest way through it is the neck check, done together, once. '
            'It is hard to argue with a sweaty neck.'),
      ],
    ),
    PpPage(
      id: 'sids_calmly',
      title: 'SIDS, explained calmly',
      format: 'ARTICLE', // [reuse] "Sensitive; text stays. Links to Health."
      blocks: [
        PpIntro('You may have heard the term and been frightened by it, '
            'perhaps at 2am on the internet. Here is the honest picture: it '
            'is rare, most of the risk is understood, and nearly everything '
            'that lowers it is something you can do this evening.'),
        PpArticle(heading: 'What it is, and what it is not', [
          'SIDS means the sudden unexplained death of a baby under one during '
              'sleep. It is a name for what could not be explained, not a '
              'disease a baby catches or is born with.',
          'It is rare. It became much rarer everywhere the back-to-sleep '
              'message spread, which is the strongest clue about what '
              'was going wrong. It is most likely between one and four months, '
              'and the risk falls steeply after six months.',
          'The best current understanding is that several things have to line '
              'up. A baby in a vulnerable window of development. Something in '
              'the sleep space that makes breathing harder. And a stressor, '
              'like a mild infection or overheating. That is why the advice is '
              'all about the sleep space. It is the part anyone can change.',
          'What it is not: caused by something you forgot, by vaccination, by '
              'choking on milk, or by any single thing a parent did. Families '
              'who have lost a baby this way did not cause it. If anyone has '
              'said or hinted otherwise to you, they were wrong.',
        ]),
        PpCards([
          PpCard('On the back, every sleep',
              'The biggest single one, by a distance.'),
          PpCard('Firm flat surface, nothing soft near the face',
              'No pillows, quilts, bumpers or soft toys under one year.'),
          PpCard('Share your room for six to twelve months',
              'A separate surface beside your bed. Lower risk than a separate '
                  'room.'),
          PpCard('A smoke-free pregnancy and a smoke-free home',
              'Second only to sleep position in how much it matters.'),
          PpCard('Keep your baby from getting too hot',
              'Light layers, no indoor cap, moving air.'),
          PpCard('Breastfeed if you can, for as long as suits you',
              'Any amount is linked to lower risk. This is not a reason '
                  'for guilt if you cannot.'),
          PpCard('Keep vaccinations up to date',
              'Vaccinated babies have a lower rate, not a higher one.'),
          PpCard('Offer a dummy at sleep if you use one',
              'Linked to lower risk. Wait until feeding is established '
                  'if you are breastfeeding.'),
        ], heading: 'What lowers the risk', hue: 152),
        PpCallout(
          'Myth: a home monitor or a smart sock prevents SIDS. No consumer '
              'device has been shown to. They mostly generate false alarms and '
              'anxious nights. The evidence-backed list is the one above, and '
              'it is free.',
          kind: PpCalloutKind.myth,
        ),
        PpCallout('You don\'t need to watch your baby breathe all night. '
            'Getting the sleep space right once is worth more than any amount '
            'of staying awake to check, and you need your sleep too.'),
        PpWhenLine('The risk window is mainly one to four months, dropping '
            'sharply after six. The full precautions apply for the first '
            'twelve months.'),
        PpIndiaNote('Being in the same room as you, which most Indian families '
            'do anyway, is on the protective side of this list. So is '
            'breastfeeding. A lot of what your family already does is right.'),
        PpLink(
          'Health, the whole section',
          surfaceId: 'pp_section/parenting_health',
          blurb: 'For the depth on this, and for anything that is a health '
              'question rather than a sleep one.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 6 — Common sleep worries
// -----------------------------------------------------------------------------
//  ⚠️ [reformat: was 5 short articles] [reference] -> ONE CAROUSEL. "Swipe-
//  through: only sleeps on me, naps only 30 min, up at 5am, sleeps all the
//  time. Each links to its canonical page, no second copies."
//
//  So the collection shows three tiles: the worry set, snoring, and the new
//  dummy page. The four worry articles are still here, unchanged, marked
//  `linkedOnly` — they open from their slide (swipe up) and from nowhere
//  else. Their template is still identical on purpose: what is going on, is
//  it normal, what helps.
// =============================================================================

final PpArea _worries = PpArea(
  id: 'worries',
  mark: IntentMark.moodArc,
  title: 'The things that worry you',
  blurb: 'The sleep questions almost every parent asks, and the honest answers.',
  hue: 188,
  pages: [
    PpPage(
      id: 'worry_set',
      title: 'The worry set',
      subtitle: 'Four things that feel like problems, and mostly are not',
      format: 'CAROUSEL',
      // ⚠️ THIS PAGE IS ITS BLOCK. A Carousel card opens the slides, an
      // Interactive card opens the step-through; there is no page between
      // the tap and the thing, exactly as on the TTC doors. Decided on a
      // phone, 2026-09-11. The intro and notes that sat around the block
      // are kept below for revert and render nowhere.
      blocks: [
        /* kept for revert: the page prose the direct-open replaced
        PpIntro('Only sleeps on you. Naps for thirty minutes. Up at 5am. '
            'Sleeps all the time. Four worries, one slide each, and the '
            'full page behind every one if you want it.'),
        */
        PpCarousel(
          eyebrow: 'The worry set',
          hue: 188,
          coverTitle: 'Four worries, and what is true about each',
          coverBlurb: 'Swipe through. Swipe up on any slide for the full '
              'page.',
          cards: [
            PpCarouselCard.linked(
                'Only sleeps on you? To a newborn you are home, and a cool '
                    'flat mattress is a different planet.',
                'It gets better on its own between three and six months. '
                    'Bottom first, head last, hand stays: the transfer that '
                    'works.',
                pageId: 'only_sleeps_on_me',
                fromMonths: 0,
                toMonths: 12),
            PpCarouselCard.linked(
                'Naps only 30 minutes long? That is one sleep cycle, and '
                    'around four months it is close to universal.',
                'Waking cheerful and staying cheerful means the nap was '
                    'enough. Look at the mood, not the clock.',
                pageId: 'catnapping',
                fromMonths: 0,
                toMonths: 12),
            PpCarouselCard.linked(
                'Up at 5am? Sleep pressure is lowest at dawn, so any '
                    'small thing makes the waking stick.',
                'Darker room, earlier bedtime, boring 5am. Later bedtime '
                    'almost never fixes it.',
                pageId: 'early_waking'),
            PpCarouselCard.linked(
                'Sleeping all the time? Usually that is just a need for sleep. '
                    'What matters is feeds, wet nappies and weight.',
                'In the first three weeks, wake your baby to feed if a stretch '
                    'passes three hours. If those three are good, let your '
                    'baby sleep.',
                pageId: 'sleeping_too_much',
                fromMonths: 0,
                toMonths: 6),
          ],
        ),
        /* kept for revert: the page prose the direct-open replaced
        PpCallout('None of these is a habit you created, and none of them '
            'needs fixing tonight. If one has stopped feeling '
            'manageable, the full page behind it is where to start.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpWhenLine('You see the slides that fit your child\'s age. Under '
            'a year, all four; from the second year, the early-waking one '
            'stays and the rest drop away.'),
        */
        /* kept for revert: the page prose the direct-open replaced
        PpIndiaNote('Every one of these gets a theory in a joint family, and '
            'most of the theories are kind. The slides are what is really '
            'true.'),
        */
      ],
    ),
    PpPage(
      id: 'only_sleeps_on_me',
      title: 'Only sleeps on me',
      format: 'ARTICLE',
      linkedOnly: true,
      bands: ['nb', 'm3_6', 'm6_12'],
      blocks: [
        // ⚠️ ADDED IN THE S01 PASS — "review once more, where the video has
        // not been added, please add video wherever it feels correct." This
        // area had six pages and no video at all, and this is the page that
        // earns one: the transfer is a PHYSICAL technique, and a paragraph
        // describing the order of head and bottom is exactly the thing a
        // fifteen-second demonstration does better than any prose can.
        PpVideoSlot(
          title: 'The drowsy transfer, shown slowly',
          subtitle: 'Bottom first, head supported and last, and the pause '
              'before you let go. Filmed at real speed.',
          minutes: '4 MIN',
          slotId: 'sleep/drowsy_transfer',
        ),
        PpIntro('Sleeping beautifully in your arms, then awake within minutes '
            'of being put down. New parents ask about this all the time, and '
            'it is one of the most normal things there is.'),
        PpArticle(heading: 'What is going on', [
          'To a newborn, you are home. Your warmth, your smell, your '
              'heartbeat and the movement of your breathing are all your baby '
              'has known for months. A flat, still, cool mattress is a '
              'different planet. A baby who protests at the move is behaving '
              'exactly as designed.',
          'There is also a physical reason for the wake-up on the way down. '
              'Babies have a startle reflex that fires when the head drops '
              'backwards even slightly. That is why lowering the bottom first, '
              'with the head supported and last, works so much more '
              'often.',
          'It gets better on its own, mostly between three and six months, '
              'as sleep matures. Nothing you do or don\'t do now decides how '
              'your child sleeps at two.',
        ]),
        PpCards([
          PpCard('Wait for the heavy arm',
              'Lift an arm gently. If it flops loose, your baby is deeply asleep '
                  'and the transfer will probably work. If it has tone, wait five '
                  'more minutes.'),
          PpCard('Warm the surface first',
              'Your hand on the sheet for a minute, or a warm cloth removed '
                  'just before. Cold sheets wake babies.'),
          PpCard('Bottom first, head last, hand stays',
              'Lower the feet and bottom, then the back, then the head. Keep a '
                  'hand on the chest for a minute after.'),
          PpCard('Tilt slightly to the side while lowering, then flat on the '
              'back',
              'Less startle on the way down. Your baby finishes flat on the '
                  'back, always.'),
          PpCard('Use a carrier for one nap a day',
              'A safe upright carry means your baby sleeps, you have your hands, '
                  'and nobody is fighting a transfer.'),
          PpCard('Take the contact naps on purpose sometimes',
              'One nap a day where you sit down together with a cup of tea. It '
                  'is not a defeat, and these months are short.'),
        ], heading: 'What helps', hue: 188),
        PpCallout('Holding a baby never does harm. There is no evidence '
            'that contact sleeping in the first months makes '
            'independent sleep harder later, and plenty that being responded '
            'to helps.'),
        PpWhenLine('Peaks in the first eight weeks. Most babies accept being '
            'put down much more easily by four to six months.'),
        PpIndiaNote('This is where many hands really help. If a grandparent '
            'or your partner can hold your baby for one nap so you sleep, take '
            'it. A daytime nap does not need only you.'),
      ],
    ),
    PpPage(
      id: 'catnapping',
      title: 'Naps only 30 minutes long',
      format: 'ARTICLE',
      linkedOnly: true,
      bands: ['nb', 'm3_6', 'm6_12'],
      blocks: [
        PpIntro('Down, asleep for 30 or 40 minutes, and awake again. It is '
            'called catnapping, and around four months it is close to '
            'universal.'),
        PpArticle(heading: 'What is going on', [
          'A baby\'s sleep cycle is about 40 to 50 minutes long. At the end of '
              'one, babies surface. If your baby cannot get back down through '
              'that surfacing, the nap ends there, and you get a nap the exact '
              'length of one cycle.',
          'This is why catnapping arrives so predictably at around four '
              'months. It is the same event as the four-month regression, '
              'showing up in daylight.',
          'It eases as babies learn to link cycles, mostly between five and '
              'eight months, and usually on its own. A short nap is only a '
              'problem if your baby is unhappy and overtired by the evening. '
              'Waking cheerful and staying cheerful means a 40 minute nap is '
              'enough, whatever the chart says.',
        ]),
        PpCards([
          PpCard('Try to be there at the 30 minute mark',
              'Hand on the chest and a shush just before your baby fully '
                  'surfaces. Sometimes that links straight into the next cycle.'),
          PpCard('Check the awake window before the nap',
              'Overtired and undertired both produce short naps. Nudge it 15 '
                  'minutes either way for a few days and see which helps.'),
          PpCard('Make the first nap of the day the good one',
              'Morning naps link most easily. Protect that one and be relaxed '
                  'about the rest.'),
          PpCard('Use one contact or carrier nap a day',
              'A longer nap on you once a day takes the pressure off the '
                  'others.'),
          PpCard('Same routine, shorter, before naps',
              'Two steps, always the same: curtain drawn, same lullaby. The '
                  'signal is needed in the day as well.'),
          PpCard('No stretching to the next nap when things fall apart',
              'An earlier bedtime is the right answer to a day of short naps, '
                  'not a later one.'),
        ], heading: 'What helps', hue: 188),
        PpCallout('Look at the mood, not the clock. A baby who wakes at 40 '
            'minutes happy and stays happy has had the nap that was needed.'),
        PpWhenLine('Most common from 3 to 6 months. Naps usually lengthen '
            'somewhere between 5 and 8 months.'),
        PpIndiaNote('If the day is busy and loud, short naps are partly the '
            'room. A curtained corner and steady sound help more than a '
            'schedule does.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCards(heading: 'If your baby won\'t nap at all', [
          PpCard('Watch the awake time', 'Overtired babies fight sleep '
              'hardest. Start the nap routine a little earlier.'),
          PpCard('A dark, quiet room', 'Daylight and noise make day sleep '
              'harder than night.'),
          PpCard('A short, same routine', 'Nappy, song, cuddle, cot.'),
          PpCard('A nap on the move is still a nap', 'In the carrier or pram, '
              'on bad days.'),
        ]),
      ],
    ),
    PpPage(
      id: 'early_waking',
      title: 'Up at 5am',
      format: 'ARTICLE',
      linkedOnly: true,
      blocks: [
        PpIntro('Anything before 6am counts as early waking, and it is one of '
            'the most stubborn sleep problems there is. There are four usual '
            'causes, and it is worth working through them in order.'),
        PpArticle(heading: 'What is going on', [
          'Sleep pressure is at its lowest in the early morning. By 5am most of '
              'the night\'s sleep is done, so not much is pushing your child '
              'back down. Any small thing, light, noise, hunger or a full '
              'nappy, is enough to make the waking '
              'stick.',
          'There are four common causes, in the order worth checking. Too '
              'much day sleep, or a nap that ran too late. Going to bed '
              'overtired. Light and sound at dawn. And treating 5am as morning, '
              'so that it becomes morning.',
          'The surprising one is bedtime. A later bedtime almost never fixes '
              'early waking and often makes it worse. An overtired child sleeps '
              'less deeply through the second half of the night. Earlier is '
              'usually the fix.',
        ]),
        PpCards([
          PpCard('Make the room properly dark at 5am',
              'Indian dawn is early and bright. A dark curtain, or a dark '
                  'cloth clipped over the window, is often the whole '
                  'solution.'),
          PpCard('Bring bedtime 30 minutes earlier for two weeks',
              'Yes, earlier. Try it properly before you decide it makes no '
                  'sense.'),
          PpCard('Cap or shift the last nap',
              'A nap that ends after 4pm, or a long nap, steals from the '
                  'night.'),
          PpCard('Keep 5am boring for 20 minutes',
              'No lights, no talking, no getting up. Feed or pat and lie down '
                  'again. If 5am reliably starts the day, the body keeps '
                  'setting that alarm.'),
          PpCard('Add steady sound',
              'Dawn traffic, birds, temple bells, the kitchen starting up. '
                  'Steady white noise masks all of it.'),
          PpCard('Check for real hunger',
              'For some babies an early feed at 5am, in the dark, buys another '
                  'hour and a half. Worth testing for a week.'),
        ], heading: 'What helps', hue: 188),
        PpCallout('Change one thing and hold it for two weeks. Early waking '
            'shifts slowly, and four fixes in four days tell you '
            'nothing about any of them.'),
        PpWhenLine('Most common between 6 months and 3 years. Allow two to '
            'three weeks per change.'),
        PpIndiaNote('If the household is up at 5.30 for the kitchen, the '
            'temple bell or school, your child will wake with it. Darkness and '
            'steady sound do the most here, because you are not going '
            'to move the household.'),
      ],
    ),
    PpPage(
      id: 'sleeping_too_much',
      title: 'Sleeps all the time, is that alright?',
      format: 'ARTICLE',
      linkedOnly: true,
      bands: ['nb', 'm3_6'],
      blocks: [
        PpIntro('A very sleepy baby usually just needs sleep, especially in the '
            'first weeks. But in a few specific situations a sleepy baby '
            'needs waking, and they are worth knowing.'),
        PpArticle(heading: 'What is going on', [
          'Newborns sleep 14 to 17 hours out of 24, and some healthy babies '
              'sit at the top of that range. A baby who is feeding well, '
              'having plenty of wet nappies, gaining weight and alert for at '
              'least short spells is fine.',
          'The one thing to watch is sleep crowding out feeding. In the first '
              'two to three weeks, and in any baby born early, small, or '
              'jaundiced, a very sleepy baby can feed too little. Feeding '
              'little brings more sleepiness, and more sleepiness means less '
              'feeding. That loop is the reason for waking your baby.',
          'So the answer is not about hours of sleep. It is about feeds, wet '
              'nappies and weight. If those three are good, let your baby sleep.',
        ]),
        PpCards([
          PpCard('Count feeds, not hours',
              'Eight to twelve feeds in 24 hours in the early weeks. That is '
                  'the number that matters.'),
          PpCard('Count wet nappies',
              'Six or more properly wet nappies a day after the first week '
                  'means your baby is getting enough.'),
          PpCard('Wake to feed if a stretch goes past three hours',
              'In the first two to three weeks, or if your doctor has asked '
                  'you to. Undress a little, change the nappy, offer skin to '
                  'skin.'),
          PpCard('Look for alert spells',
              'Even a very sleepy newborn has short periods of quiet '
                  'alertness. Some is what you want to see.'),
          PpCard('Sleep yourself while your baby sleeps',
              'If your baby is well and feeding, the extra sleep is a gift. '
                  'Take it.'),
        ], heading: 'What helps', hue: 188),
        PpCallout(
          'Call your doctor today for any of these. Hard to wake for feeds. '
              'Fewer wet nappies than usual. Looking more yellow. Floppy. Not '
              'interested in feeding. Feeling hot or unusually cold. A sudden '
              'change into sleepiness in an older baby also needs a call.',
          kind: PpCalloutKind.doctor,
          title: 'When sleepiness needs a doctor',
        ),
        PpWhenLine('Wake for feeds in the first two to three weeks. Do it for '
            'longer if your baby was born early or small or has jaundice, '
            'exactly as your doctor advises.'),
        PpIndiaNote('"Sleeps so much, such an easy baby" is often said kindly '
            'and is usually true. In the first three weeks, still count the '
            'feeds and the nappies rather than going by how settled your baby '
            'seems.'),
      ],
    ),
    PpPage(
      id: 'noisy_breathing',
      title: 'Noisy breathing or snoring in sleep',
      format: 'ARTICLE', // [reuse] "Short article + doctor callout. Links to Health."
      blocks: [
        PpIntro('Babies are noisy sleepers. Snuffles, squeaks, little grunts '
            'and irregular breathing are all normal, and most of it comes from '
            'how babies are built, not from a problem. A short list does need '
            'a doctor, and it is below.'),
        PpArticle(heading: 'What is going on', [
          'A baby\'s nasal passages are narrow, and babies breathe mostly '
              'through the nose. So a very small amount of dryness or mucus '
              'makes a lot of noise. Add soft, floppy airway tissue and you get '
              'a baby who sounds dramatic and is completely fine.',
          'Newborn breathing is also naturally irregular. Quick for a while, '
              'then slow, then a pause for a few seconds, then starting again. '
              'Pauses under about ten seconds, with normal colour and no '
              'effort, are normal in the early weeks and settle with age.',
          'Occasional snoring during a cold or a blocked nose is ordinary. '
              'Not ordinary: snoring most nights, snoring with pauses and '
              'gasps, or breathing that is visibly hard work. Those are worth '
              'a proper look. They are usually very treatable, often something '
              'as simple as large tonsils or '
              'adenoids.',
        ]),
        PpCallout(
          'Call your doctor now, or go to hospital, for any of these. A pause '
              'in breathing of more than about 20 seconds. Blue or grey around '
              'the lips or tongue. Gasping. Pulling in under the ribs or at '
              'the base of the throat with each breath. Very fast breathing at '
              'rest. Grunting with every breath. '
              'Do not wait for morning for any of these.',
          kind: PpCalloutKind.doctor,
          title: 'Same day, or straight away',
        ),
        PpCards([
          PpCard('Snoring most nights, not just with a cold',
              'Worth an appointment. Often tonsils or adenoids, and treatable.'),
          PpCard('Pauses followed by a gasp or a snort',
              'Mention this specifically. It is the pattern that matters.'),
          PpCard('Sleeping with the neck stretched right back',
              'Or only settling half sitting up. This can be a way of finding '
                  'a position to breathe in.'),
          PpCard('Very restless nights with heavy sweating',
              'Together with noisy breathing, worth raising.'),
          PpCard('Daytime mouth breathing all the time',
              'Combined with the above, worth a look.'),
          PpCard('Poor weight gain alongside noisy breathing',
              'Two things together is more meaningful than either alone.'),
        ], heading: 'Worth an appointment, not an emergency', hue: 188),
        PpCards([
          PpCard('Saline drops before feeds and sleep',
              'One or two drops per nostril for a blocked nose. Safe, cheap, '
                  'and usually enough.'),
          PpCard('Keep the air from being too dry',
              'A bowl of water in an air-conditioned room, or a humidifier if '
                  'you have one.'),
          PpCard('Keep smoke and strong fumes out',
              'Cigarette smoke, mosquito coils and heavy incense in a closed '
                  'room all irritate a small airway.'),
          PpCard('Film it on your phone',
              'Thirty seconds of the sound and the chest moving tells your '
                  'doctor more than any description you can give.'),
        ], heading: 'What helps at home', hue: 188),
        PpCallout('Noisy is usually fine. Effortful is not. Working hard to '
            'breathe, or changing colour, is the line, and you don\'t need '
            'to be sure before you call.'),
        PpWhenLine('Snuffly breathing is most common in the first three '
            'months. Habitual snoring is more of a toddler and preschool '
            'thing, and that is when to ask about tonsils.'),
        PpIndiaNote('Mosquito coils, closed rooms and winter smoke make '
            'snuffly babies snufflier. A mesh screen and a mosquito net are '
            'better than a coil burning in the room where your baby sleeps.'),
        PpLink(
          'Health, the whole section',
          surfaceId: 'pp_section/parenting_health',
          blurb: 'Tonsils, adenoids, reflux and the rest of what noisy '
              'breathing can be.',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCallout('Loud snoring most nights, pauses in breathing or gasping, '
            'breathing through the mouth, restless sleep and daytime '
            'tiredness can mean sleep apnoea. It often comes from large '
            'tonsils or adenoids, and it is treatable. Ask your paediatrician, '
            'and take a short phone video of the breathing at night.',
            kind: PpCalloutKind.doctor,
            title: 'Snoring that needs a doctor'),
      ],
    ),
    // ⚠️ [new] ARTICLE. "Honest pros and cons for sleep, safe use, letting it
    // go later."
    PpPage(
      id: 'dummy_soother',
      title: 'Dummy, soother and sleep',
      format: 'ARTICLE',
      blocks: [
        PpIntro('A dummy is one of the few sleep aids with real evidence on '
            'both sides. Here is the honest version, so using one is a '
            'decision and not a guilt.'),
        PpArticle(heading: 'What it does for sleep', [
          'Sucking is calming, and a dummy gives that without a feed. '
              'Many babies settle faster with one and stay settled through '
              'the small surfacings that would otherwise wake them. Offered '
              'at sleep, it is also linked to a lower risk of SIDS, '
              'though nobody is entirely sure why.',
          'The cost is the 2am dummy hunt. Most babies can find it and put '
              'it back alone only after seven or eight months. Until then, a '
              'dummy that falls out is a dummy you get up for. For some babies that is '
              'several times a night. For those babies, the dummy is not '
              'helping anyone sleep.',
          'On feeding: if you are breastfeeding, wait until it is going well, '
              'usually three to four weeks, before offering one. Earlier can '
              'muddle the latch. On teeth and speech: no harm under two, and '
              'a real but small effect on the bite if it goes on past three '
              'or four.',
        ]),
        PpCards([
          PpCard('Only at sleep, not all day',
              'A sleep dummy stays a sleep cue. An all-day dummy becomes '
                  'something to give up, and talking happens less while it is in.'),
          PpCard('Nothing tied to it, ever',
              'No cord, no ribbon, no clip to clothes at night. A cord in '
                  'a cot is a strangling risk.'),
          PpCard('One piece, the right size, checked for cracks',
              'Replace it every month or two. A torn teat is a choking risk.'),
          PpCard('Leave it out once your baby is asleep',
              'If it falls out during sleep, leave it out. Only put it back '
                  'if your baby wakes and wants it.'),
          PpCard('Never dip it in anything',
              'Honey, sugar and gripe water on a dummy are all still done, '
                  'and all still a bad idea. Honey under one year is unsafe.'),
        ], heading: 'Using one safely', hue: 188),
        PpArticle(heading: 'Letting it go, later', [
          'There is no hurry. Between one and two is often the easiest time. '
              'By then there are other ways to settle, and not yet the '
              'words to negotiate. Limit it to sleep first, for a few '
              'weeks, then to bedtime only, then choose a calm fortnight and '
              'stop.',
          'For a toddler who is attached, a story helps more than a rule. The '
              'dummy goes to a new baby, or to the dummy fairy, or it is '
              'planted and a small toy grows in its place. Three or four bad '
              'nights is the usual price, and then it is done.',
        ]),
        PpCallout('A dummy is neither a failure nor a fix. If it helps your '
            'baby settle and you are not woken to replace it, use it. If it '
            'costs you more sleep than it saves, it can go.'),
        PpWhenLine('From three to four weeks if breastfeeding, earlier if '
            'not. Most useful up to about a year. Best let go between one '
            'and two, and before three in any case.'),
        PpIndiaNote('Older relatives are often against a dummy on principle, '
            'and for the thumb on the same principle. A thumb cannot be '
            'given to the dummy fairy, which is the honest answer to that.'),
      ],
    ),
    // Added 2026-10-02 from the parenting gap analysis (P2/P3).
    PpPage(
      id: 'night_fears',
      title: 'Nightmares and night terrors',
      subtitle: 'Two very different things',
      bands: ['tod', 'pre'],
      format: 'CARDS',
      blocks: [
        PpIntro('Waking up screaming in the night is frightening for both of '
            'you. Knowing whether it is a nightmare or a night terror tells '
            'you what to do.'),
        PpCards(heading: 'A nightmare', [
          PpCard('When', 'Usually in the second half of the night.'),
          PpCard('What you see', 'Your child wakes up scared, wants you, and '
              'can often tell you about it.'),
          PpCard('What to do', 'Go in, hold your child close, and say "You '
              'are safe." A night light and a calm bedtime help.'),
        ]),
        PpCards(heading: 'A night terror', [
          PpCard('When', 'Usually one to three hours after falling asleep.'),
          PpCard('What you see', 'Screaming, thrashing, eyes open, but not '
              'really awake, and not aware you are there. There is no memory '
              'of it afterwards.'),
          PpCard('What to do', 'Stay close, keep your child safe, and don\'t '
              'try to wake your child. It passes in minutes. Overtiredness '
              'makes night terrors more likely, so an earlier bedtime helps.'),
        ]),
        PpCallout('See your doctor if night terrors happen very often or last '
            'a long time. The same goes if they come with jerking, stiffness '
            'or breathing pauses, which can look like a fit.',
            kind: PpCalloutKind.doctor),
      ],
    ),
    PpPage(
      id: 'sleep_talk_walk',
      title: 'Sleep talking and sleepwalking',
      subtitle: 'Common, mostly harmless, and outgrown',
      bands: ['tod', 'pre'],
      format: 'ARTICLE',
      blocks: [
        PpIntro('Many young children talk, laugh or even walk in their '
            'sleep. It runs in families, gets worse with tiredness, and '
            'nearly always fades by the teens.'),
        PpArticle([
          'Sleep talking needs nothing at all. Sleepwalking needs a safe home: '
              'gate the stairs, lock doors and windows, keep the balcony shut, '
              'and clear the floor. Guide your child gently back to bed, '
              'without waking.',
          'An earlier, steady bedtime and a calm hour before bed reduce both.',
        ]),
        PpCallout('See your doctor if sleepwalking happens most nights, if '
            'there are injuries, or if there is snoring or gasping in sleep.',
            kind: PpCalloutKind.doctor),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 7 — Music and sleep, and the Sleep Sounds library
// -----------------------------------------------------------------------------
//  ⚠️ REQUIRED-CONFIRM, PER THE SPEC'S FLAGGED DECISION (spec §9).
//
//  The spec flags two questions for Ishaan and Deepti and asks for the
//  recommended default to be built with the decision left easy to change:
//
//    1. The player should be a REUSABLE app-wide ParentVeda audio component,
//       surfaced here rather than locked inside Sleep, so it can also serve a
//       fussy baby, travel and the car later. Built that way: the tool points at
//       `pp_sleep_sounds`, which is a general player surface, and this file
//       contributes only the LIBRARY.
//
//    2. Whether the library is fresh or extends the existing Garbh Sanskar
//       audio library. DEFAULT TAKEN HERE: a fresh baby-sleep library, kept
//       separate from Garbh Sanskar, because Garbh Sanskar audio is pregnancy
//       and mother-baby-connection content and blending the two would make
//       "what is this track for" unanswerable.
//
//  ⚠️ SO THE LIBRARY SOURCE IS REQUIRED-CONFIRM. If the decision goes the other
//  way, the change is confined to this one area: repoint the slot ids from the
//  `sleep_sounds/...` namespace to the Garbh Sanskar namespace and delete the
//  duplicated categories. Nothing else in the section reads these ids.
//
//  ⚠️ AND THE PLAYER SCREEN ITSELF IS NOT BUILT HERE. `pp_sleep_sounds` is a NEW
//  surface someone must build, and it owns the behaviour the spec requires:
//  sleep timer DEFAULT ON, loop, offline play, and a safe default volume that is
//  not loud. That behaviour is a property of the player, not of the data, and
//  putting it here would mean each library entry carrying a volume field nothing
//  reads.
// =============================================================================

final PpArea _music = PpArea(
  id: 'music',
  mark: IntentMark.stepsMark,
  title: 'Music, lullabies and sleep sounds',
  blurb: 'What helps, what is myth, and the tracks to play tonight.',
  hue: 96,
  pages: [
    // ⚠️ [reuse] ARTICLE. "Honest article; the 'what is myth' section becomes
    // a myth-vs-truth carousel." The five cards are the five slides, each one
    // the myth as it is said, then what is true. Cards kept below for revert.
    PpPage(
      id: 'does_music_help',
      title: 'Does music help babies sleep?',
      format: 'ARTICLE',
      blocks: [
        // ⚠️ ADDED IN THE S01 PASS. The area had no video, and this page
        // carries the section's one genuine safety point — the volume limit,
        // which the text says "nobody mentions". A number in a paragraph is
        // read past; a demonstration of how loud is too loud, next to a phone
        // at arm's length, is the version that changes what she does tonight.
        PpVideoSlot(
          title: 'How loud is too loud?',
          subtitle: 'Where to put the speaker, and what the safe level sounds '
              'like next to a cot.',
          minutes: '3 MIN',
          slotId: 'sleep/sound_volume',
        ),
        PpIntro('Partly yes, and not in the way it is usually sold. Some of '
            'this has real evidence behind it, some of it is marketing, and '
            'one part is a real safety issue nobody mentions.'),
        PpArticle(heading: 'What helps', [
          'Steady, unchanging sound helps, and this is the best supported part. '
              'White noise, womb sounds, a fan or steady rain mask the sudden '
              'noises that wake a baby: a door, a pressure cooker, the '
              'neighbour\'s bike. In a shared room in an Indian home, that '
              'masking is doing most of the work, not the music.',
          'Being sung to helps, and more than a recording does. Babies '
              'consistently prefer a live human voice, and they prefer their '
              'mother\'s. A lullaby sung badly by you beats a beautifully '
              'produced track, every time. Singing also slows your own '
              'breathing down, and your baby feels it.',
          'Consistency helps most of all. The same sound, every night, in the '
              'same order, becomes a cue that sleep is next. That is where '
              'nearly all of the benefit lives. Which track you choose matters '
              'far less than playing the same one nightly.',
          'And slow music helps more than pretty music. Slow, low, repetitive, '
              'no sudden changes in volume. This is why the traditional night '
              'ragas and simple lullabies work: they were made for exactly this.',
        ]),
        PpCarousel(
          eyebrow: 'Myth vs truth',
          hue: 96,
          cards: [
            PpCarouselCard.myth('Classical music makes babies smarter',
                'No. The famous study was on adults doing a spatial task and '
                    'the effect did not last. Play it because it is calm, '
                    'not because it is an investment.'),
            PpCarouselCard.myth(
                'Special sleep frequencies and binaural beats work',
                'No evidence in babies. A fan does the same job for free.'),
            PpCarouselCard.myth('Music can replace a bedtime routine',
                'It cannot. It is one step inside a routine, and the routine '
                    'is the part that works.'),
            PpCarouselCard.myth(
                'Playing something all night helps deeper sleep',
                'It does not, and continuous sound all night is the part '
                    'with a real downside. Low volume, timer on.'),
            PpCarouselCard.myth(
                'Our baby needs it to sleep now, so we have created a problem',
                'A sound cue is one of the easiest cues to travel with and '
                    'to let go of later. Of all the sleep associations, this '
                    'is the least troublesome one.'),
          ],
        ),
        /* kept for revert: the cards the carousel replaced
        PpCards([
          PpCard('"Classical music makes babies smarter"',
              'No. The famous study was on adults doing a spatial task and the '
                  'effect did not last. Play it because it is calm, not because '
                  'it is an investment.'),
          PpCard('"Special sleep frequencies and binaural beats"',
              'No evidence in babies. A fan does the same job for free.'),
          PpCard('"Music can replace a bedtime routine"',
              'It cannot. It is one step inside a routine, and the routine is '
                  'the part that works.'),
          PpCard('"Playing something all night helps deeper sleep"',
              'It does not, and continuous sound all night is the part with a '
                  'real downside. See the safety note below.'),
          PpCard('"Our baby needs it to sleep now, so we have created a problem"',
              'A sound cue is one of the easiest cues to travel with and to '
                  'let go of later. Of all the sleep associations, this is the '
                  'least troublesome one.'),
        ], heading: 'What is myth', hue: 96),
        */
        PpCallout(
          'Keep the volume low, use the timer, and keep the speaker away from '
              'your baby\'s head. As a rule: quieter than a normal conversation, '
              'at least two to three feet away, never in the cot, and never a '
              'phone on the pillow. Loud sound played close to a baby all '
              'night has been linked to hearing damage. Continuous sound all '
              'night also leaves nothing to listen for as hearing matures. Set '
              'it to switch itself off after 30 to 45 minutes. The timer in the '
              'player is on by default for this reason.',
          title: 'Low volume, and use the timer',
        ),
        PpWhenLine('White noise and womb sounds suit newborns best. Lullabies suit '
            'every age. Stories start earning their place from about 18 '
            'months. Thirty to forty-five minutes, then off.'),
        PpIndiaNote('The lullaby your own mother sang beats anything in a '
            'library. You know it by heart, and you can sing it in the dark '
            'at 3am with your eyes shut. Use the library '
            'for the nights you have nothing left.'),
        // ⚠️ THE SAMPLE TRACKS THAT SAT HERE ARE GONE. Kept for revert:
        //
        //   PpAudioSlot(title: 'Steady white noise', ...
        //               'sleep_sounds/white_noise_steady')
        //   PpAudioSlot(title: 'Nini Baba Nini', ...
        //               'sleep_sounds/lori_nini_baba')
        //
        // They re-declared two slot ids that the library page below already
        // owns, which `test/pp_section_test.dart` caught: a slot id used twice
        // means one real audio file has two homes, so it lands in one of them
        // and silently never appears in the other.
        //
        // The page loses nothing. Its job is the honest answer to "does music
        // actually help?", and the link right below opens the whole library.
        PpLink(
          'Open Sleep Sounds',
          surfaceId: 'pp_sleep_sounds',
          blurb: 'Lullabies, white noise, rain, soft ragas and stories. '
              'Timer on by default.',
        ),
      ],
    ),
    // ⚠️ [reference] AUDIO LIBRARY, GENERATED FROM THE PLAYER'S OWN DATA.
    //
    // "Sleep Sounds tool = the library in collection 7." This page used to be
    // a second, hand-written list of twenty-five tracks with its own slot ids,
    // and it had already drifted from `pp_sounds_data.dart`: different lori,
    // different stories, two id namespaces for one library. Now the page is
    // built from `kPpSoundCategories`, so the catalogue she reads here and
    // the player she opens from it cannot disagree. The old list is kept at
    // the foot of this file for revert.
    //
    // ⚠️ SHARES ASSETS WITH GARBH SANSKAR SHRAVAN. The brief settles the
    // REQUIRED-CONFIRM the first build left open: same player
    // (`RagaAudioStore`), same bundled files where they fit. The tanpura
    // drone is the first — see `pp_sounds_data.dart`.
    _soundsLibraryPage,
  ],
);

/// The collection 7 library page, built from the player's categories.
///
/// A `final` rather than a `const` because it is derived. Every `PpAudioSlot`
/// here carries the track's own `slotId`, so `test/pp_section_test.dart`'s
/// one-id-one-title rule now holds across the page AND the player.
final PpPage _soundsLibraryPage = PpPage(
  id: 'sleep_sounds_library',
  title: 'The Sleep Sounds library',
  subtitle: 'Everything in the player, by category',
  format: 'AUDIO LIBRARY',
  blocks: [
    const PpIntro('Five kinds of sound, and a note on which suits which age. '
        'Play the same one every night rather than a different one each '
        'evening. The timer switches everything off on its own.'),
    for (final c in kPpSoundCategories) ...[
      PpArticle(heading: c.label, [c.blurb]),
      for (final t in c.tracks)
        PpAudioSlot(
          title: t.title,
          category: c.label,
          minutes: t.minutes.toUpperCase(),
          slotId: t.slotId,
        ),
    ],
    const PpCallout(
      'Low volume, speaker away from your baby\'s head, timer on. Quieter than a '
      'normal conversation, at least two to three feet away, never in the '
      'cot and never a phone on the pillow. Thirty to forty-five minutes, '
      'then off.',
      title: 'The same safety note, because it matters',
    ),
    const PpWhenLine('Newborns: white noise and womb sounds. Three months and '
        'up: nature and ragas. Eighteen months and up: stories. Lullabies at any '
        'age.'),
    const PpIndiaNote('Download the two or three you really use before you '
        'travel. A train, a bus or a grandparent\'s house is exactly where a familiar '
        'sound earns its place, and exactly where the network will not be '
        'there.'),
    const PpLink(
      'Open Sleep Sounds',
      surfaceId: 'pp_sleep_sounds',
      blurb: 'Pick a track, set the timer, and put the phone face down.',
    ),
  ],
);

/* ⚠️ KEPT FOR REVERT: the hand-written library page the generated one
   replaced. Twenty-five tracks under `sleep_sounds/` ids that no longer
   match the player. If the generated page ever lands badly, this is the
   whole revert.

    PpPage(
      id: 'sleep_sounds_library',
      title: 'The Sleep Sounds library',
      subtitle: 'Everything in the player, by category',
      format: 'AUDIO LIBRARY',
      blocks: [
        PpIntro('Five kinds of sound, and a note on which suits which age. '
            'Play the same one every night rather than a different one each '
            'evening. The timer switches everything off on its own.'),
        // ---------------------------------------------------------------------
        //  ⚠️ THE LIBRARY IS REQUIRED-CONFIRM. See the area header above: this
        //  is a FRESH baby-sleep library, deliberately not the Garbh Sanskar
        //  one. Every slotId is namespaced `sleep_sounds/` so repointing is a
        //  find and replace in this one page if that decision changes.
        // ---------------------------------------------------------------------
        PpArticle(heading: 'Lullabies', [
          'A sung human voice, slow and repetitive. Suits every age from birth '
              'and stays useful into the school years. Best of all sung by you, '
              'and these are here for the nights when you have nothing left.',
        ]),
        PpAudioSlot(
          title: 'Nini Baba Nini',
          category: 'Lullabies',
          minutes: '5 MIN',
          slotId: 'sleep_sounds/lori_nini_baba',
        ),
        PpAudioSlot(
          title: 'Aaja Nindiya Aaja',
          category: 'Lullabies',
          minutes: '6 MIN',
          slotId: 'sleep_sounds/lori_aaja_nindiya',
        ),
        PpAudioSlot(
          title: 'Lalla Lalla Lori',
          category: 'Lullabies',
          minutes: '4 MIN',
          slotId: 'sleep_sounds/lori_lalla_lalla',
        ),
        PpAudioSlot(
          title: 'Thaai Thaai, a Tamil thalattu',
          category: 'Lullabies',
          minutes: '5 MIN',
          slotId: 'sleep_sounds/lori_thaai_thalattu',
        ),
        PpAudioSlot(
          title: 'Humming lullaby, no words',
          category: 'Lullabies',
          minutes: '20 MIN',
          slotId: 'sleep_sounds/lori_humming_wordless',
        ),
        PpArticle(heading: 'White noise and womb sounds', [
          'Steady, unchanging sound that masks doors, kitchens and traffic. The '
              'best supported category, and the one that suits newborns most. '
              'Low volume, well away from your baby\'s head, and off after the timer.',
        ]),
        PpAudioSlot(
          title: 'Womb sounds, as heard before birth',
          category: 'White noise and womb sounds',
          minutes: '30 MIN',
          slotId: 'sleep_sounds/womb_sounds',
        ),
        PpAudioSlot(
          title: 'Steady white noise',
          category: 'White noise and womb sounds',
          minutes: '45 MIN',
          slotId: 'sleep_sounds/white_noise_steady',
        ),
        PpAudioSlot(
          title: 'Pink noise, softer than white',
          category: 'White noise and womb sounds',
          minutes: '45 MIN',
          slotId: 'sleep_sounds/pink_noise',
        ),
        PpAudioSlot(
          title: 'Ceiling fan hum',
          category: 'White noise and womb sounds',
          minutes: '30 MIN',
          slotId: 'sleep_sounds/fan_hum',
        ),
        PpAudioSlot(
          title: 'A slow, steady heartbeat',
          category: 'White noise and womb sounds',
          minutes: '20 MIN',
          slotId: 'sleep_sounds/heartbeat_slow',
        ),
        PpArticle(heading: 'Nature and calm sounds', [
          'Gentle, mostly steady, with no sudden peaks. Good from about three '
              'months, when babies start noticing sound as something separate '
              'from the room. Nothing here has thunder in it.',
        ]),
        PpAudioSlot(
          title: 'Monsoon rain on a terrace',
          category: 'Nature and calm sounds',
          minutes: '30 MIN',
          slotId: 'sleep_sounds/monsoon_terrace',
        ),
        PpAudioSlot(
          title: 'Slow evening rain, no thunder',
          category: 'Nature and calm sounds',
          minutes: '30 MIN',
          slotId: 'sleep_sounds/evening_rain',
        ),
        PpAudioSlot(
          title: 'A river over stones',
          category: 'Nature and calm sounds',
          minutes: '25 MIN',
          slotId: 'sleep_sounds/river_stones',
        ),
        PpAudioSlot(
          title: 'Night crickets and a soft breeze',
          category: 'Nature and calm sounds',
          minutes: '30 MIN',
          slotId: 'sleep_sounds/crickets_breeze',
        ),
        PpAudioSlot(
          title: 'Distant temple bells at dusk',
          category: 'Nature and calm sounds',
          minutes: '15 MIN',
          slotId: 'sleep_sounds/temple_bells_dusk',
        ),
        PpArticle(heading: 'Soft ragas', [
          'Slow, low and repetitive, which is exactly what helps. The evening '
              'and night ragas were shaped for this over a very long time, and '
              'Nilambari has been the sleep raga in Indian homes for '
              'generations. Suits every age, and adults too.',
        ]),
        PpAudioSlot(
          title: 'Raag Nilambari, the sleep raga',
          category: 'Soft ragas',
          minutes: '15 MIN',
          slotId: 'sleep_sounds/raga_nilambari',
        ),
        PpAudioSlot(
          title: 'Raag Yaman, a slow alaap',
          category: 'Soft ragas',
          minutes: '12 MIN',
          slotId: 'sleep_sounds/raga_yaman_alaap',
        ),
        PpAudioSlot(
          title: 'Raag Bhupali at dusk',
          category: 'Soft ragas',
          minutes: '12 MIN',
          slotId: 'sleep_sounds/raga_bhupali',
        ),
        PpAudioSlot(
          title: 'Raag Bageshri, for the late night',
          category: 'Soft ragas',
          minutes: '14 MIN',
          slotId: 'sleep_sounds/raga_bageshri',
        ),
        PpAudioSlot(
          title: 'Bansuri, slow and low',
          category: 'Soft ragas',
          minutes: '10 MIN',
          slotId: 'sleep_sounds/bansuri_slow',
        ),
        PpArticle(heading: 'Bedtime stories', [
          'For older babies and toddlers, from about 18 months. Read slowly, '
              'with nothing exciting in them and no loud voices. A story is '
              'the last step of a routine, not a way to get a child to sleep '
              'alone.',
        ]),
        PpAudioSlot(
          title: 'The moon that followed her home',
          category: 'Bedtime stories',
          minutes: '6 MIN',
          slotId: 'sleep_sounds/story_moon_followed',
        ),
        PpAudioSlot(
          title: 'The tortoise and the two geese, told softly',
          category: 'Bedtime stories',
          minutes: '7 MIN',
          slotId: 'sleep_sounds/story_tortoise_geese',
        ),
        PpAudioSlot(
          title: 'A very sleepy elephant',
          category: 'Bedtime stories',
          minutes: '5 MIN',
          slotId: 'sleep_sounds/story_sleepy_elephant',
        ),
        PpAudioSlot(
          title: 'Good night to everything in the house',
          category: 'Bedtime stories',
          minutes: '4 MIN',
          slotId: 'sleep_sounds/story_goodnight_house',
        ),
        PpAudioSlot(
          title: 'Dadi tells a story',
          category: 'Bedtime stories',
          minutes: '8 MIN',
          slotId: 'sleep_sounds/story_dadi_tells',
        ),
        PpCallout(
          'Low volume, speaker away from your baby\'s head, timer on. Quieter than a '
              'normal conversation, at least two to three feet away, never in '
              'the cot and never a phone on the pillow. Thirty to forty-five '
              'minutes, then off.',
          title: 'The same safety note, because it matters',
        ),
        PpWhenLine('Newborns: white noise and womb sounds. Three months and up: '
            'nature and ragas. Eighteen months and up: stories. Lullabies at any '
            'age.'),
        PpIndiaNote('Download the two or three you really use before you '
            'travel. A train, a bus or nani\'s house is exactly where a '
            'familiar sound earns its place, and exactly where the network '
            'will not be there.'),
        PpLink(
          'Open Sleep Sounds',
          surfaceId: 'pp_sleep_sounds',
          blurb: 'Pick a track, set the timer, and put the phone face down.',
        ),
      ],
    ),
*/
