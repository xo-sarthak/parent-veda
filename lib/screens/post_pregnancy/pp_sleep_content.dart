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
//  ⚠️ NO SLEEP TRAINING ANYWHERE. The spec is explicit and it is a market fact,
//  not a preference: "near-zero India demand for sleep training and Indian
//  families co-sleep by default with no decision-anxiety". So no cry-it-out and
//  no ferberizing, and the phrase "sleep training" appears exactly once in
//  user-facing copy: on the consult, where spec §11 requires it to be named and
//  ruled out. Everywhere else it stays out of the reader's head rather than
//  being introduced in order to be argued with.
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
//  ⚠️ THE AGE CARDS IN AREA 1 ARE THE DATA SOURCE FOR THE QUICK-CHECK TOOL.
//  They are `PpChartCard`s with label/value rows precisely so `pp_sleep_check`
//  can read them instead of a second copy of the numbers existing in a tool
//  file. Two copies of a sleep range is two answers to the same question.
//
//  English only for now, plain `String`, per the standing instruction.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_age_bands.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpSleepSection = PpSection(
  id: 'parenting_sleep', // MUST match the hub's bracketId.
  title: 'Sleep',
  intro: 'Helping your little one, and you, sleep better.',
  bandSet: kPpSleepBands,
  areas: [
    _howMuch,
    _nightWaking,
    _regressions,
    _gettingToSleep,
    _safeSleep,
    _worries,
    _music,
  ],
  tools: [
    PpSectionTool(
      label: 'Is she sleeping enough?',
      blurb: 'Enter her age and see the normal range. Takes ten seconds.',
      surfaceId: 'pp_sleep_check',
      icon: Icons.nightlight_outlined,
    ),
    // ⚠️ REUSED, NOT REBUILT. `pp_sleep` is the existing Sleep Journey log
    // (sleep_journey_screen.dart). It is already non-gamified, already reads
    // SleepStore, and already has the age-context card. A second sleep log
    // would split one baby's nights across two databases.
    PpSectionTool(
      label: 'Log her sleep and naps',
      blurb: 'A light record of a few days, so a pattern can show itself. '
          'No scores and no streaks.',
      surfaceId: 'pp_sleep',
      icon: Icons.edit_note_outlined,
    ),
    PpSectionTool(
      label: 'Sleep Sounds',
      blurb: 'Lori, white noise, rain, soft ragas and bedtime stories, '
          'with a timer that switches itself off.',
      surfaceId: 'pp_sleep_sounds',
      icon: Icons.music_note_outlined,
    ),
  ],
);

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
  title: 'How much sleep does she need?',
  blurb: 'What is normal at this age, and the honest range around it.',
  hue: 206,
  pages: [
    PpPage(
      id: 'sleep_newborn',
      title: 'Newborn sleep, 0 to 3 months',
      format: 'CHART-CARD',
      bands: ['nb'],
      blocks: [
        PpIntro('Newborns sleep a lot, in short bursts, around the clock. '
            'There is no schedule yet, and that is not something you need to '
            'fix. Her stomach is small and it empties fast, so she wakes.'),
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
        PpCallout('Do not try to build a routine yet. In the first three '
            'months you are feeding on demand and sleeping when she sleeps. '
            'The routine comes later and it comes easily.'),
        PpWhenLine('From birth to about 12 weeks. Expect the pattern to shift '
            'every few days rather than settle.'),
        PpIndiaNote('In a shared room she often settles faster, not slower. '
            'You do not need a separate nursery, and there is no evidence a '
            'baby sleeping in your room sleeps worse.'),
        PpLink(
          'Check the range for her exact age',
          surfaceId: 'pp_sleep_check',
          blurb: 'Enter her age in weeks or months, get the normal range.',
        ),
      ],
    ),
    PpPage(
      id: 'sleep_3_6',
      title: 'Sleep at 3 to 6 months',
      format: 'CHART-CARD',
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
        PpIndiaNote('If the household eats at 9pm, her bedtime will drift '
            'late. Rather than fight the whole house, keep the last 20 minutes '
            'before sleep quiet and dim, wherever that happens.'),
        PpLink(
          'Check the range for her exact age',
          surfaceId: 'pp_sleep_check',
          blurb: 'Enter her age in weeks or months, get the normal range.',
        ),
      ],
    ),
    PpPage(
      id: 'sleep_6_12',
      title: 'Sleep at 6 to 12 months',
      format: 'CHART-CARD',
      bands: ['m6_12'],
      blocks: [
        PpIntro('Most of her sleep has moved to the night by now. The day naps '
            'get fewer and longer, and she can stay happily awake for much '
            'longer stretches between them.'),
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
        PpIndiaNote('Once she can pull to stand, check the bed and the room '
            'again. A baby who could not move last month can now reach the '
            'edge of the mattress.'),
        PpLink(
          'Check the range for her exact age',
          surfaceId: 'pp_sleep_check',
          blurb: 'Enter her age in weeks or months, get the normal range.',
        ),
      ],
    ),
    PpPage(
      id: 'sleep_toddler',
      title: 'Sleep for a 1 to 3 year old',
      format: 'CHART-CARD',
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
              'More often she is short of your attention at the end of a long '
              'day, or the nap ran too late.',
        ),
        PpCallout('If the afternoon nap ends after about 4pm, bedtime moves '
            'back with it. Waking her from a late nap is allowed.'),
        PpWhenLine('From 12 months to 3 years. Two naps become one somewhere '
            'between 12 and 18 months for most children.'),
        PpIndiaNote('Indian children often keep an afternoon nap longer than '
            'Western charts suggest, partly because of the afternoon heat and '
            'partly because the household naps too. That is fine.'),
        PpLink(
          'Check the range for her exact age',
          surfaceId: 'pp_sleep_check',
          blurb: 'Enter her age in months or years, get the normal range.',
        ),
      ],
    ),
    PpPage(
      id: 'sleep_preschool',
      title: 'Sleep for a 3 to 5 year old',
      format: 'CHART-CARD',
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
          note: 'If she skips the nap and is still cheerful at 6pm, she is '
              'ready to drop it. If she skips it and falls apart, she is not, '
              'and quiet rest on a mat is a fair middle step.',
        ),
        PpCallout('When the nap goes, bedtime needs to come forward by 30 to '
            '60 minutes for a while. That is the whole fix, most of the time.'),
        PpWhenLine('From 3 to 5 years. Most children drop the nap between '
            '3 and 4, some keep it to 5, and both are ordinary.'),
        PpIndiaNote('School or playgroup timings often decide the wake-up, so '
            'work backwards from that to set bedtime rather than forwards from '
            'dinner.'),
        PpLink(
          'Check the range for her exact age',
          surfaceId: 'pp_sleep_check',
          blurb: 'Enter her age in months or years, get the normal range.',
        ),
      ],
    ),
    PpPage(
      id: 'baby_vs_adult_sleep',
      title: 'Why her sleep is not like yours',
      subtitle: 'The reason she stirs, in plain terms',
      format: 'SHORT ARTICLE + diagram',
      blocks: [
        PpIntro('Almost every worry about baby sleep gets smaller once you '
            'know this one thing: her sleep is built differently from yours, '
            'and it is supposed to be.'),
        PpArticle([
          'Sleep runs in cycles. You go down through light sleep into deep '
              'sleep, come back up, and start again. At the top of each cycle '
              'you surface for a moment, turn over, and go back down without '
              'ever knowing you woke.',
          'Your cycle lasts about 90 minutes. Hers lasts about 40 to 50. So in '
              'the same night she surfaces roughly twice as often as you do.',
          'She also spends far more of her night in light sleep. That is not a '
              'flaw. Light sleep is when a baby can wake to feed, wake if she '
              'is too warm, wake if she cannot breathe freely. It is thought to '
              'be protective, and it is one of the reasons very young babies '
              'are not built to sleep like adults.',
          'And she has not yet learned to go back down on her own at the top of '
              'a cycle. That skill arrives on its own timetable, mostly in the '
              'second half of the first year, and it arrives whether or not '
              'anyone taught it.',
        ]),
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
        PpCallout('She is not waking up. She is surfacing, the way you do, and '
            'sometimes she needs a hand to get back down. Those are two very '
            'different problems and only one of them is a problem.'),
        PpWhenLine('True from birth. Her cycles lengthen slowly and start to '
            'look adult-shaped somewhere around 4 to 5 years.'),
        PpVideoSlot(
          title: 'How much sleep does she really need?',
          subtitle: 'A paediatrician walks through the ranges age by age, and '
              'what to do when your baby sits outside them.',
          minutes: '8 MIN',
          slotId: 'sleep/needs_by_age',
        ),
        PpLink(
          'Log a few nights and see her own pattern',
          surfaceId: 'pp_sleep',
          blurb: 'Three or four days is usually enough for a shape to appear.',
        ),
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
  title: 'She keeps waking at night',
  blurb: 'Why it happens, and gentle ways to settle her back down.',
  hue: 268,
  pages: [
    PpPage(
      id: 'why_babies_wake',
      title: 'Why babies wake',
      format: 'CARDS',
      blocks: [
        PpIntro('Almost every night waking has an ordinary cause, and most of '
            'them are quick to check. Here are the common ones, in the order '
            'they are usually worth checking.'),
        PpCards([
          PpCard(
              'Hunger',
              'A small stomach empties in two to three hours. Feed her, and '
                  'expect this to be most night wakings under 4 months.'),
          PpCard(
              'Needing to know you are there',
              'She surfaced, could not find you, and called. A hand on her '
                  'chest and a low shush often ends it in under a minute.'),
          PpCard(
              'A developmental leap',
              'New skills wake babies. Rolling, sitting, crawling, standing '
                  'and first words all bring a few unsettled nights. Ride it '
                  'out, it passes in one to three weeks.'),
          PpCard(
              'She needs the same help she fell asleep with',
              'If she fell asleep on the breast, she may look for the breast '
                  'to get back down. That is a sleep association, not a bad '
                  'habit, and you can loosen it slowly if you want to.'),
          PpCard(
              'A wet or dirty nappy',
              'Change a dirty one always. A wet one, only if she is bothered '
                  'or has nappy rash. A full change wakes her up more.'),
          PpCard(
              'Gas or an uncomfortable tummy',
              'Legs pulled up, squirming, a hard little belly. Hold her '
                  'upright against your shoulder, or try a slow clockwise '
                  'tummy rub and bicycle legs.'),
          PpCard(
              'Teething',
              'Usually a few bad nights around each tooth, with drooling and '
                  'chewing in the day. Cold teether, extra cuddles, and ask '
                  'your doctor before any medicine.'),
          PpCard(
              'Too hot or too cold',
              'Feel the back of her neck, not her hands. Sweaty means one '
                  'layer off. In an Indian summer, overheating is far more '
                  'common than cold.'),
        ], hue: 268),
        PpCallout('Night waking is not a habit you created. It is how baby '
            'sleep is built, and it changes on its own as she grows.'),
        PpCallout(
          'Most night waking is ordinary. Ask your doctor if there is pain, if '
              'she is not gaining weight, if her breathing pauses or she goes '
              'blue, or if a settled sleeper suddenly changes with no clear '
              'reason. Those are worth a call, not a wait.',
          kind: PpCalloutKind.doctor,
          title: 'When night waking needs a doctor',
        ),
        PpWhenLine('Wakings peak around 4 months and again around 8 to 10 '
            'months. Both of those are leaps, not setbacks.'),
        PpIndiaNote('In a joint family everyone has a theory about why she is '
            'waking, and most of them are kindly meant. You are allowed to '
            'check the list above and leave it there.'),
      ],
    ),
    PpPage(
      id: 'normal_waking_by_age',
      title: 'What is normal night waking',
      subtitle: 'A page to scan, then relax',
      format: 'COMPARISON TABLE',
      blocks: [
        PpIntro('If you only want one thing from this section, it is this '
            'table. Find her age, read across, and see that the night you had '
            'is the night most parents at this age are having.'),
        PpTable(
          columns: ['Age', 'Typical wakes', 'Why'],
          rows: [
            [
              '0 to 3 months',
              '3 to 5 a night',
              'Feeding. Tiny stomach, no day-night rhythm yet.'
            ],
            [
              '3 to 6 months',
              '2 to 4 a night',
              'Feeding, plus the 4-month shift in how her sleep is organised.'
            ],
            [
              '6 to 12 months',
              '0 to 3 a night',
              'Leaps, teeth, and looking for you. Feeds may or may not still '
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
        PpWhenLine('Use this as a floor, not a goal. If she wakes more often '
            'than the row above for more than two or three weeks with no leap '
            'or illness to explain it, it is worth a conversation.'),
        PpIndiaNote('Households where the baby sleeps beside the mother tend '
            'to report more brief wakings and less distress at each one, '
            'because a feed or a hand happens before she is properly awake.'),
        PpVideoSlot(
          title: '"Night waking is normal." What actually helped us',
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
      title: 'Gentle ways to settle her',
      format: 'STEP-LIST CARDS',
      blocks: [
        PpIntro('Five ways to get her back down, all of them gentle and all of '
            'them fine to use while she sleeps next to you. Pick by what is '
            'happening tonight, not by which one is meant to be best.'),
        PpCards([
          PpCard('Patting and shushing',
              'When she is stirring and grumbling but not properly awake.'),
          PpCard('Feeding back to sleep',
              'When she is hungry, and any time it is 3am and you want the '
                  'fastest route back to sleep.'),
          PpCard('Contact settling, in your arms or on your chest',
              'When she is upset rather than sleepy, or unwell, or in a leap.'),
          PpCard('A dream feed',
              'When she reliably wakes hungry at the same early-night hour, '
                  'and you would rather choose the time than be woken.'),
          PpCard('Slowly using less help',
              'When you want to change something, and only when nothing else '
                  'is going on that week.'),
        ], heading: 'Which one, and when', hue: 268),
        PpSteps(
          heading: 'Patting and shushing',
          [
            PpStep('Get there before she is fully awake', 'A stir answered in ten seconds is a stir. The same '
                    'stir answered in two minutes is a cry.'),
            PpStep('Put a still, warm hand on her chest or her back', 'Weight and warmth, not movement. Let her feel where '
                    'you are.'),
            PpStep('Add a slow pat, about one a second', 'Roughly the speed of a resting heartbeat. Slower than '
                    'feels natural when you are tired.'),
            PpStep('Shush low and long, close to her ear', 'A steady "shhhhh" is closer to what she heard in the '
                    'womb than any word is.'),
            PpStep('Slow the pat down, then stop, then lift your hand last', 'Fading out in that order is what stops her jolting '
                    'awake as you leave.'),
          ],
        ),
        PpSteps(
          heading: 'Feeding back to sleep',
          [
            PpStep('Feed in the dark, with no talking', 'No lights, no nappy change unless it is dirty, no '
                    'phone. Boring is the point.'),
            PpStep('Let her come off on her own', 'If she drifts off latched and full, that is a job '
                    'done, not a habit made.'),
            PpStep('Hold her upright for a minute if she is windy', 'Then lower her slowly, feet and bottom first, head '
                    'last.'),
          ],
        ),
        PpSteps(
          heading: 'Contact settling',
          [
            PpStep('Pick her up before she escalates', 'You cannot spoil a baby by holding her. Under six '
                    'months, held is where most babies settle fastest.'),
            PpStep('Hold her upright against your chest, her ear over your '
                'heart'),
            PpStep('Sway or walk slowly, and hum one thing on repeat', 'One lori on a loop works better than three songs.'),
            PpStep('Wait for the heavy arm', 'When her arm flops loose she is deeply asleep. '
                    'Transfers before that mostly fail.'),
            PpStep('Lower her bottom first, keep a hand on her, then let go', 'Warm your hands and the sheet first if the room is '
                    'cold. Cold sheets wake babies.'),
          ],
        ),
        PpSteps(
          heading: 'A dream feed',
          [
            PpStep('Pick a time about two to three hours after she goes down', 'Usually somewhere between 10pm and 11.30pm.'),
            PpStep('Lift her gently and offer the feed without waking her '
                'properly', 'Keep the room dark. Many babies feed with their eyes '
                    'shut.'),
            PpStep('Put her back down and go to bed yourself', 'The point of a dream feed is your sleep, not hers. '
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
                    'holding still. Holding becomes a hand on her chest.'),
            PpStep('Stay at each step for three to five nights', 'If a step is clearly too big, go back one. Going back '
                    'is not failing.'),
            PpStep('Stop entirely if she is ill, teething, in a leap or you '
                'have travelled', 'Pick it up again in a fortnight. Nothing is lost.'),
            PpStep('You never leave her to cry', 'At every step you are there, responding. If a step '
                    'needs her to cry alone, it is the wrong step.'),
          ],
        ),
        PpCallout('Nothing here asks you to leave her crying. You stay, you '
            'respond, and you use a little less help each week. That is the '
            'whole method.'),
        PpWhenLine('Patting, feeding and contact settling work from birth. '
            'Slowly using less help is worth trying from about 6 months, once '
            'night feeds are genuinely optional.'),
        PpIndiaNote('If she sleeps on your bed, most of this gets easier, not '
            'harder. A hand on her chest costs you no getting up. Read the '
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
          whoFor: 'For nights that have stopped feeling manageable, when you '
              'have tried the settling above and want someone to look at your '
              'baby specifically. Gentle and co-sleeping friendly. Never sleep '
              'training, and never crying it out.',
          surfaceId: 'pp_experts',
          role: 'sleep',
        ),
      ],
    ),
    PpPage(
      id: 'at_3am',
      title: 'What to do at 3am',
      subtitle: 'The short version, for when you cannot read',
      format: 'SHORT TEXT / quick reference',
      blocks: [
        PpIntro('It is the middle of the night and you are too tired to think. '
            'Run down this list. Most nights you will stop at step two.'),
        PpSteps(
          heading: 'In order',
          [
            PpStep('Wait ten seconds', 'Babies grumble in their sleep. A good number of '
                    'wakings end without you.'),
            PpStep('Hand on her chest, low shush', 'No lifting yet, no light, no talking.'),
            PpStep('Offer a feed', 'Under six months, this is almost always the answer '
                    'and it is the fastest one.'),
            PpStep('Check the back of her neck', 'Sweaty, take a layer off. Cool, add one. Ignore her '
                    'hands, they are always cold.'),
            PpStep('Check for a dirty nappy', 'Change a dirty one. Leave a merely wet one unless she '
                    'is bothered.'),
            PpStep('Hold her upright against your shoulder for a few minutes', 'For wind and for the wakings that are only about '
                    'wanting you.'),
            PpStep('If she is inconsolable and this is not like her, check her '
                'over properly', 'Temperature, breathing, tummy, a wet nappy count for '
                    'the day. Then read the doctor page in this area.'),
          ],
        ),
        PpCards([
          PpCard('Keep the room dark',
              'One dim warm light if you must. Bright light tells her body it '
                  'is morning.'),
          PpCard('Do not look at your phone',
              'The screen wakes you up more than it wakes her, and then you '
                  'are the one who cannot get back to sleep.'),
          PpCard('Do not do the maths',
              'Counting how many hours you have left is the single fastest way '
                  'to stay awake.'),
          PpCard('Swap nights if you can',
              'One person on, one person properly asleep in another room, '
                  'alternating. Two half-slept people is worse than one '
                  'rested one.'),
        ], heading: 'And for you', hue: 206),
        PpCallout('Keep 3am boring. Same dark, same quiet, same order every '
            'time. Boring is what teaches her that nothing interesting happens '
            'at night.'),
        PpWhenLine('Use this from birth. It stops being needed somewhere in '
            'the second year for most children.'),
        PpIndiaNote('If a grandmother or a helper shares the night duty, walk '
            'her through these seven steps once. A shared night only works if '
            'everyone does the same thing.'),
      ],
    ),
    PpPage(
      id: 'night_weaning',
      title: 'Gently dropping night feeds',
      format: 'ARTICLE',
      bands: ['m6_12', 'tod'],
      blocks: [
        PpIntro('If you want to stop feeding at night, it can be done slowly '
            'and without anyone crying it out. And if you do not want to stop, '
            'you do not have to. Plenty of children feed at night into their '
            'second year and are perfectly well.'),
        PpArticle(heading: 'When it makes sense to start', [
          'Wait until she is over six months, eating solids reasonably well, '
              'gaining weight along her own line, and healthy. Before that, '
              'night feeds are food and not comfort.',
          'It also has to be a calm few weeks. Not during teething, not during '
              'an illness, not the week you travel, not the week she starts '
              'creche. Choose a boring fortnight.',
          'And be honest about who wants it. If night feeds are working for '
              'you, there is no medical reason to stop them. If you are '
              'exhausted and resentful, that is reason enough on its own.',
        ]),
        PpSteps(
          heading: 'A gentle way to do it',
          [
            PpStep('Count what is actually happening first', 'Three or four nights of notes. Most parents are '
                    'surprised by both the number and the times.'),
            PpStep('Feed her more in the day', 'Move calories into daylight before you take them out '
                    'of the night. An extra feed or meal in the afternoon.'),
            PpStep('Pick the easiest feed to drop, not the hardest', 'Usually the one where she takes the least, or the one '
                    'closest to morning.'),
            PpStep('Shorten it a little every few nights', 'Two minutes less, or one side instead of two, or a '
                    'little less in the bottle. Then a little less again.'),
            PpStep('Replace the feed with the same comfort in another form', 'A hand on her chest, a cuddle, water for a toddler. '
                    'She is not being refused, she is being answered '
                    'differently.'),
            PpStep('Let your partner take that waking for a few nights', 'She will look for the breast if the breast is in the '
                    'room. This one step often does most of the work.'),
            PpStep('Then start on the next feed', 'One feed per one to two weeks. Slower is genuinely '
                    'faster here, because nothing has to be undone.'),
          ],
        ),
        PpCallout('Going backwards is normal. A tooth, a fever or a bad week '
            'will bring a feed back. Feed her, and start again when things are '
            'calm. Nothing you did is wasted.'),
        PpCallout(
          'Check with your doctor before dropping night feeds if she was born '
              'early or small, if her weight gain has been slow or has '
              'flattened, or if she is under six months. Night feeds are '
              'nutrition at that stage, not habit.',
          kind: PpCalloutKind.doctor,
          title: 'Ask first if any of this is true',
        ),
        PpWhenLine('From about 6 months at the earliest, more comfortably from '
            '9 to 12 months. Allow four to six weeks for the whole thing.'),
        PpIndiaNote('If you share a bed, she will smell milk all night. Moving '
            'her to the far side of the bed, or having your partner sleep '
            'between you for a fortnight, is often the gentlest version of '
            'this whole plan.'),
      ],
    ),
    PpPage(
      id: 'waking_doctor',
      title: 'When night waking needs a doctor',
      format: 'FLAGGED CALLOUT',
      blocks: [
        PpIntro('Almost all night waking is ordinary. A small number of things '
            'are not, and they are worth knowing by heart so you never have to '
            'wonder at 2am whether to call.'),
        PpCallout(
          'Call your doctor the same day if she pauses in her breathing, goes '
              'blue or grey around the lips, is very hard to wake, has a fever '
              'under three months of age, cries in a way that sounds like pain '
              'and will not settle, or is having far fewer wet nappies than '
              'usual.',
          kind: PpCalloutKind.doctor,
          title: 'Same day, not tomorrow',
        ),
        PpCards([
          PpCard('Waking that comes with pain',
              'Screaming that does not settle in your arms, pulling at an ear, '
                  'legs drawn up hard and rigid. Get her looked at.'),
          PpCard('Weight that has stopped moving',
              'If she is waking hungry all night and her weight has flattened '
                  'off her own line, that is a feeding question for the '
                  'doctor, not a sleep question.'),
          PpCard('Pauses in breathing, or gasping',
              'Brief irregular breathing is normal in newborns. Pauses longer '
                  'than about 20 seconds, gasping, or heavy snoring every '
                  'night are not. Ask.'),
          PpCard('A sudden change with no reason',
              'A settled sleeper who suddenly wakes hourly for more than a '
                  'week, with no tooth, leap, travel or illness to explain it, '
                  'deserves a check.'),
          PpCard('Waking that is really reflux',
              'Arching, crying on being laid flat, frequent vomiting, sleeping '
                  'far better upright. Treatable. Worth naming to your '
                  'doctor.'),
          PpCard('Night sweats or scratching',
              'Soaked bedding every night, or waking to scratch, can point at '
                  'something ordinary and fixable, like eczema or an iron '
                  'problem. Mention it.'),
        ], heading: 'The specific things to mention', hue: 344),
        PpCallout('Bringing your sleep log to the appointment saves the whole '
            'first half of it. Times, feeds, and what you tried are more '
            'useful than any description.'),
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
  title: 'Her sleep suddenly got worse',
  blurb: 'The regressions, when they hit, and how to get through them.',
  hue: 344,
  pages: [
    PpPage(
      id: 'what_is_regression',
      title: 'What is a sleep regression',
      format: 'SHORT ARTICLE + timeline',
      blocks: [
        PpIntro('A baby who was sleeping well starts waking every hour. '
            'Nothing has changed in the room, the routine or the feeding. This '
            'is a regression, and it is almost always a sign of progress.'),
        PpArticle([
          'The word is misleading. Nothing is going backwards. What is '
              'happening is that her brain is doing something new, and while it '
              'is doing it, sleep gets loud.',
          'Every big new skill costs sleep for a while. Rolling, sitting, '
              'crawling, standing, walking, first words, and the growing '
              'understanding that you still exist when you leave the room. She '
              'practises at night because her brain is busy with it.',
          'The pattern is nearly always the same: two to six weeks of bad '
              'nights, then sleep settles again, often a little better than '
              'before. The skill arrives and the nights come back.',
          'The one real risk in a regression is not the regression. It is '
              'deciding, in week two at 4am, to change everything. New rules '
              'made while exhausted are hard to unmake in month three.',
        ]),
        PpChartCard(
          title: 'When they typically hit',
          rows: [
            ('Around 4 months', 'Her sleep reorganises for good'),
            ('6 to 8 months', 'Sitting, crawling, first separation worries'),
            ('8 to 10 months', 'Pulling up, standing, and missing you'),
            ('11 to 12 months', 'Walking, and the first nap wobble'),
            ('18 months', 'Big feelings, big words, testing limits'),
            ('2 years', 'Dreams, fears, and giving up the cot'),
          ],
          note: 'These ages are averages and your baby has not read them. Two '
              'weeks either side is normal, and some babies skip one entirely.',
          hue: 344,
        ),
        PpCallout('Do not start anything new during a regression. Hold your '
            'routine, add help rather than remove it, and change nothing until '
            'the fortnight is over.'),
        PpWhenLine('Expect two to six weeks each time. If bad nights run past '
            'six weeks with no leap you can point at, treat it as something '
            'else and read the doctor page in the night waking area.'),
        PpIndiaNote('In a joint family a regression is often read as "she has '
            'been spoiled" or "the milk has reduced". It is neither. Naming it '
            'out loud as a two-week phase takes the pressure off everyone.'),
        PpVideoSlot(
          title: 'Sleep regressions, explained',
          subtitle: 'A child development specialist on what is actually '
              'happening at 4 months, 8 months and 18 months, and what to hold '
              'steady through each one.',
          minutes: '10 MIN',
          slotId: 'sleep/regressions_explainer',
          hue: 344,
        ),
        PpConsult(
          title: 'Gentle infant sleep consultation',
          whoFor: 'For a regression that has run long, or a second and third '
              'one back to back, when you want a plan that does not involve '
              'leaving her to cry. Gentle and co-sleeping friendly.',
          surfaceId: 'pp_experts',
          role: 'sleep',
        ),
      ],
    ),
    PpPage(
      id: 'regression_4m',
      title: 'The 4 month regression',
      format: 'ARTICLE',
      bands: ['nb', 'm3_6'],
      blocks: [
        PpIntro('This is the one that catches parents out, because it usually '
            'arrives just after the first few good nights. It is also the only '
            'one that is a permanent change rather than a phase.'),
        PpArticle(heading: 'What is happening and why', [
          'Until now she had two states, roughly: deep sleep and active sleep. '
              'Around four months her sleep reorganises into the adult pattern '
              'of proper cycles, with real light sleep at the top of each one.',
          'So for the first time she surfaces properly between cycles, every '
              '40 to 50 minutes, and notices where she is. If she went to '
              'sleep on the breast in your arms and surfaces alone on the bed, '
              'she calls.',
          'This is not a regression at all, then. It is her sleep growing up, '
              'and it does not undo itself. What changes is that she slowly '
              'learns to get back down through those surfacings, over the next '
              'few months.',
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
              'She goes down harder than she did a month ago.'),
          PpCard('Suddenly hungry again at night',
              'Real hunger, partly. She is also more distracted in the day and '
                  'feeds less then.'),
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
            PpStep('Feed her when she wakes hungry', 'Do not ration night feeds during a leap. This is not '
                    'the fortnight for that.'),
            PpStep('Help her get back down however works', 'Patting, feeding, holding. Adding help during a '
                    'regression does not create a problem you will have to '
                    'undo.'),
            PpStep('Rescue short naps once a day if you can', 'Hands on, or in a carrier, or beside you. One decent '
                    'nap a day changes the evening.'),
            PpStep('Change nothing else at all', 'No new room, no weaning off feeds, no dropping the '
                    'swaddle unless she has started rolling. One thing at a '
                    'time, and this fortnight already has its one thing.'),
          ],
        ),
        PpCallout('This passes. Almost every parent who describes four months '
            'as the worst month also describes six months as fine. You are not '
            'building a problem by comforting her through it.'),
        PpWhenLine('Typically 3.5 to 4.5 months, lasting two to six weeks. If '
            'she has started rolling, stop swaddling now, tonight, whatever '
            'else is happening.'),
        PpIndiaNote('This is the age solids get suggested early to "fill her '
            'up so she sleeps". It does not work, and before six months it is '
            'not recommended. Ask your doctor before starting solids for '
            'sleep.'),
      ],
    ),
    PpPage(
      id: 'regression_8_10m',
      title: 'The 8 to 10 month regression',
      format: 'ARTICLE',
      bands: ['m3_6', 'm6_12'],
      blocks: [
        PpIntro('This one is loud and it is mostly about two things: her body '
            'learning to move, and her mind working out that you still exist '
            'after you walk out of the room.'),
        PpArticle(heading: 'What is happening and why', [
          'Between eight and ten months most babies are crawling, pulling to '
              'stand, and cruising along furniture. New motor skills get '
              'rehearsed in light sleep, which is why you find her standing in '
              'the cot at midnight, crying, unable to work out how to sit down '
              'again.',
          'At the same time separation awareness arrives properly. She now '
              'knows you exist somewhere else when she cannot see you, and '
              'that is a much bigger deal to a baby than it sounds. Waking and '
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
              'because by the end of it she can get herself back down.',
          hue: 344,
        ),
        PpCards([
          PpCard('Standing up in the cot and getting stuck',
              'She can pull up and cannot yet lower herself. Practise sitting '
                  'down from standing in the daytime, on the floor.'),
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
            PpStep('Play peek-a-boo, and narrate leaving', '"Amma is going and Amma is coming back." Leaving and '
                    'returning, over and over, in the day, is how separation '
                    'awareness gets easier.'),
            PpStep('Keep the goodnight short and the same', 'A long drawn-out exit gives her more to protest '
                    'about, not less.'),
            PpStep('Lower the cot mattress and check the room again', 'She can stand now. Anything she could not reach last '
                    'month, she can reach this month.'),
            PpStep('Go in, settle her, and lie her back down', 'Every time she needs you. Responding during a leap '
                    'does not build a habit, it builds the confidence that '
                    'ends the leap.'),
            PpStep('Drop to two naps if the third is being refused', 'Then bring bedtime forward by 20 to 30 minutes for a '
                    'fortnight to cover the lost sleep.'),
          ],
        ),
        PpCallout('This passes, and it usually leaves her a better sleeper '
            'than she was. Every night you go in and settle her is teaching '
            'her that you come back, which is the actual lesson of this month.'),
        PpWhenLine('Typically 8 to 10 months, lasting two to six weeks. Lower '
            'the cot base as soon as she pulls to stand, not later.'),
        PpIndiaNote('If she has just started with a creche, a nanny or a '
            'grandparent while you return to work, separation and the '
            'regression stack on top of each other. Extra evening contact '
            'time, for a few weeks, does more than any change to her nights.'),
      ],
    ),
    PpPage(
      id: 'regression_toddler',
      title: 'The toddler sleep wobbles, 18 months and 2 years',
      format: 'ARTICLE',
      bands: ['m6_12', 'tod', 'pre'],
      blocks: [
        PpIntro('Toddler sleep goes wrong for different reasons than baby '
            'sleep. It is less about her body and more about her having '
            'opinions, an imagination, and the ability to climb out.'),
        PpArticle(heading: 'What is happening and why', [
          'Around 18 months she is walking well, talking, and discovering that '
              'she is a separate person who can say no. Bedtime is a very '
              'obvious place to try that out.',
          'Around two, imagination arrives. That is a wonderful thing in the '
              'day and a complicated one at night, because the same mind that '
              'invents a game can invent something behind the almirah. Real '
              'dreams and night fears start here.',
          'Underneath both, the single nap is under pressure. A nap that is '
              'too late pushes bedtime out, and a nap that has been dropped '
              'too early makes her overtired by 6pm. Most toddler bedtime '
              'battles are a nap timing problem wearing a costume.',
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
              'two hours on the fourth has not dropped it. She is testing it.',
          hue: 344,
        ),
        PpCards([
          PpCard('Endless bedtime requests',
              'Water, su-su, one more story, a different blanket. Answer the '
                  'first, then hold the line kindly.'),
          PpCard('Refusing the nap, then falling apart at 5pm',
              'Cap the nap rather than lose it. Even 40 minutes helps.'),
          PpCard('Waking in the night frightened',
              'Real fear, not manipulation. Go, sit with her, keep it low and '
                  'brief.'),
          PpCard('Climbing out of the cot',
              'Once she can climb out, the cot is no longer the safe option. '
                  'Move to a low bed or a mattress on the floor.'),
          PpCard('Wanting you to stay until she sleeps',
              'Very common at two. You can sit by her and slowly move the '
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
            PpStep('Give her two real choices inside the routine', 'Which pyjamas, which story. Choosing something is '
                    'often all the independence she was looking for.'),
            PpStep('Make the routine visual and fixed', 'Four or five pictures on the wall in order. A toddler '
                    'who can see what comes next argues less about it.'),
            PpStep('Take night fears seriously and briefly', '"I know. I am here. Nothing is going to hurt you." '
                    'Then stay a little, and go. Do not search the room for '
                    'monsters, it makes them real.'),
            PpStep('Answer the first request, then stop', 'One drink of water, then "the water is done, I am '
                    'here". Kindly, and the same words every night.'),
            PpStep('Bring bedtime forward by 30 minutes for a fortnight', 'The counter-intuitive one that works most often. '
                    'Overtired toddlers fight sleep harder and wake earlier.'),
          ],
        ),
        PpCallout('This passes too. Toddler sleep is more about steady, kind '
            'repetition than about any technique. The same words, in the same '
            'order, every night, for two weeks.'),
        PpWhenLine('Around 18 months and again around 2 years, two to six '
            'weeks each. Move her out of the cot the week she first climbs '
            'out, not after a fall.'),
        PpIndiaNote('In a joint family the household bedtime is often 10pm or '
            'later and a toddler cannot sleep through a lit, busy room. If the '
            'timing cannot move, a curtain or a partition and a small dim '
            'corner does more than asking everyone to be quiet.'),
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
  title: 'Getting her to sleep',
  blurb: 'Routines, malish, and what to do when the whole house is awake.',
  hue: 26,
  pages: [
    PpPage(
      id: 'bedtime_routine',
      title: 'A calming bedtime routine',
      format: 'STEP-LIST + callout',
      blocks: [
        PpIntro('A bedtime routine is not about discipline. It is a signal. '
            'The same few things in the same order tell her body that sleep is '
            'coming, before anyone asks her to sleep.'),
        PpSteps(
          heading: 'The order that works',
          [
            PpStep('Dim the lights, about 30 minutes before', 'One lamp instead of the tube light. Light is the '
                    'strongest signal her body reads, stronger than the '
                    'clock.'),
            PpStep('Bath, or a warm wipe-down', 'Every night or every other night, whichever suits '
                    'your home. Warm water and then cooling down afterwards '
                    'both help sleep.'),
            PpStep('Malish, if it is part of your evening', 'Five to ten minutes of slow oil massage. Calming for '
                    'her, and one of the loveliest parts of the day for '
                    'you.'),
            PpStep('Night clothes and a fresh nappy', 'Do this now, not later. A nappy change after she is '
                    'asleep undoes the whole routine.'),
            PpStep('Feed, in the dim room', 'Feed her here rather than as the very last step, if '
                    'you can, so that feeding is not the only thing that means '
                    'sleep. If she falls asleep anyway, that is fine.'),
            PpStep('One quiet story or one lori', 'The same one. Repetition is the point, not variety. '
                    'Newborns get the lori, older babies get both.'),
            PpStep('Lights off, and the same cue every night', 'One sentence, one kiss, the same words. "Good night, '
                    'I am here." That sentence becomes the switch.'),
          ],
        ),
        PpCallout('Keep it the same every night. The order matters far more '
            'than the contents. A routine she can predict is a routine that '
            'works, and it works on holiday, at nani-nana\'s house, and in a '
            'hotel room.'),
        PpWhenLine('Twenty to forty minutes, at roughly the same time every '
            'night. You can start a simple two-step version from about six '
            'weeks. From three months it starts to genuinely pay off.'),
        PpIndiaNote('If you share the room, you cannot dim the whole house. '
            'Dim her corner, turn her away from the light, and put a curtain '
            'or a dupatta over a line beside the bed. The routine has to fit '
            'your home, not a nursery in a catalogue.'),
        PpVideoSlot(
          title: 'A bedtime routine and malish, follow along',
          subtitle: 'Twenty real minutes, start to finish, in a one-room home. '
              'Follow along tonight with your own baby.',
          minutes: '14 MIN',
          slotId: 'sleep/bedtime_malish_followalong',
          hue: 26,
        ),
        PpLink(
          'Put on a lori or some white noise',
          surfaceId: 'pp_sleep_sounds',
          blurb: 'Low volume, timer on. Use the same track every night.',
        ),
      ],
    ),
    PpPage(
      id: 'wind_down',
      title: 'The hour before bed',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Most bedtime trouble is decided in the hour before bedtime, '
            'not at bedtime. Three things do nearly all the work: light, '
            'screens, and how wound up she is.'),
        PpArticle([
          'Light first, because it is the biggest one. Bright white light in '
              'the evening tells her brain it is still daytime and delays the '
              'melatonin that makes her sleepy. Turning off the tube light and '
              'using one warm lamp for the last hour is a real intervention, '
              'not a nicety.',
          'Screens matter for two reasons and only one of them is the light. A '
              'phone or a TV in the last hour is bright, yes, but it is also '
              'exciting, and an excited brain takes 30 to 40 minutes to come '
              'back down. For under-twos the advice is no screens at all in '
              'the evening. For older children, off an hour before bed.',
          'Then activity level. Rough play, tickling and chasing right before '
              'bed produce a very happy child who then cannot sleep. Move the '
              'wild play earlier and keep the last hour low and floor-based: '
              'blocks, books, a slow bath.',
          'One thing that is not on this list: keeping her up late to make her '
              'sleep better. It almost never works. An overtired child is '
              'harder to settle and wakes earlier, not later.',
        ]),
        PpCards([
          PpCard('The tube light',
              'One warm lamp instead, for the last hour. The single easiest '
                  'change on this page.'),
          PpCard('The TV in the living room',
              'If it cannot go off, turn her away from it and take her to the '
                  'quiet corner for the last 20 minutes.'),
          PpCard('Phones, including yours',
              'A screen held over her while she feeds is light straight into '
                  'her eyes.'),
          PpCard('Chasing, tickling and jhula games',
              'Wonderful, and not after 7pm.'),
          PpCard('Sugar and a big late meal',
              'A full stomach and a heavy meal too close to sleep leaves her '
                  'uncomfortable. Dinner about an hour before.'),
        ], heading: 'What to turn down in the last hour', hue: 26),
        PpCallout('If you change one thing on this page, change the light. '
            'Dim beats everything else, and it costs nothing.'),
        PpWhenLine('Start caring about this from about three months, when her '
            'body clock begins to respond to light at all. It matters most '
            'from one year on.'),
        PpIndiaNote('Evenings in an Indian home are busy and bright by nature, '
            'with people arriving, dinner cooking and the TV on. You are not '
            'going to change all of that. Claim the last twenty minutes and '
            'one dim corner, and that is enough.'),
      ],
    ),
    PpPage(
      id: 'malish',
      title: 'Malish before sleep',
      format: 'STEP-LIST',
      blocks: [
        PpIntro('Malish is one of the few traditional practices with real '
            'evidence behind it. Babies who are massaged settle a little '
            'faster, cry a little less, and gain weight a little better. It is '
            'also fifteen minutes of undistracted attention, which is its own '
            'reason.'),
        PpArticle([
          'Warm oil, warm hands, and slow strokes. Any of the oils used in '
              'Indian homes are fine on healthy skin. Coconut oil is well '
              'studied and light, sesame is traditional and warming for '
              'winter, mustard oil is common in the north but can irritate '
              'sensitive skin, so patch test it first.',
          'The direction to move in is outwards, from the middle of the body '
              'towards the hands and feet, and on the tummy always clockwise. '
              'Pressure should be firm enough to move the skin and never '
              'enough to make her flinch.',
        ]),
        PpSteps(
          heading: 'How to do it',
          [
            PpStep('Pick a time when she is calm and not just fed', 'About 30 to 45 minutes after a feed, and before the '
                    'bath. Not on a full stomach, not on an empty one.'),
            PpStep('Warm the room and warm the oil', 'Stand the oil bowl in warm water. Rub some between '
                    'your palms so it is not cold on her.'),
            PpStep('Lay her on a towel on the floor or across your legs', 'The traditional legs position is fine for a baby with '
                    'good head control. On the floor is safest.'),
            PpStep('Start at the legs, ankles up to the thighs', 'Long slow strokes, one leg at a time, then the '
                    'feet.'),
            PpStep('Then arms, then hands', 'Same idea. Open her fist gently and stroke each '
                    'finger.'),
            PpStep('Chest, outwards from the middle', 'Both hands from the centre of the chest out to the '
                    'sides, like opening a book.'),
            PpStep('Tummy, always clockwise', 'Slow circles around the navel. This is the bit that '
                    'helps with wind. Skip it if the cord stump is still '
                    'there.'),
            PpStep('Back, then finish at her head', 'Turn her over, long strokes down the back, then very '
                    'light circles on her head. Nothing forceful on the soft '
                    'spot.'),
            PpStep('Bath, dress, and into the routine', 'Malish then bath then bed is the sequence. Massaged '
                    'and left in oil overnight is sticky and not the point.'),
          ],
        ),
        PpCallout('Ten minutes is plenty, and a crying baby is telling you '
            'today is not the day. Stop, cuddle, try tomorrow. Malish is '
            'supposed to be pleasant for both of you.'),
        PpCallout(
          'Never put oil into her nose, ears or mouth, however commonly it is '
              'advised. Oil in the nose can reach the lungs and cause a '
              'serious pneumonia. Also stop and ask your doctor if the skin '
              'goes red or bumpy after an oil, if she has eczema, or if she '
              'was born early and is still very small.',
          kind: PpCalloutKind.doctor,
          title: 'One thing to never do, whoever suggests it',
        ),
        PpWhenLine('From about two weeks, once the cord stump has healed. Ten '
            'to fifteen minutes, once a day, ideally at the same point in the '
            'evening.'),
        PpIndiaNote('If a maalishwali comes to your home, watch the first '
            'session. Vigorous pulling of the limbs, cracking, hanging the '
            'baby upside down and oil in the nose or ears are all still done '
            'and all worth saying no to. Firm, slow, gentle strokes are the '
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
      title: 'She only falls asleep on the feed',
      format: 'ARTICLE',
      blocks: [
        PpIntro('You have probably been told this is a bad habit you will '
            'regret. It is worth knowing what is actually true, because the '
            'guilt around this one is out of all proportion to the problem.'),
        PpArticle(heading: 'Is it a problem?', [
          'Usually not. Feeding to sleep is what babies are designed to do. '
              'Breast milk in the evening carries sleep-inducing compounds, '
              'sucking itself is calming, and the whole arrangement is old and '
              'well tested. Millions of children who fed to sleep every night '
              'now sleep fine.',
          'It becomes worth loosening in only one case: when it is the ONLY '
              'way she can get to sleep, she wakes often, and nobody else can '
              'settle her, and that combination has made your nights '
              'unmanageable. Not because it is wrong, but because a single '
              'route to sleep leaves you with no options on a bad night.',
          'The mildest version of loosening it is not stopping. It is adding a '
              'second route. If she can also fall asleep being patted, or in '
              'her father\'s arms, or in a carrier, then feeding to sleep is a '
              'choice rather than the only door.',
          'And there is one genuine health point, separate from sleep. Once '
              'she has teeth, falling asleep with milk pooling in her mouth '
              'raises the risk of tooth decay. Wipe her gums or brush her '
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
              'Not to prove a point. Just so she learns there is more than one '
                  'way, and so you get one evening.'),
          PpCard('Feed earlier in the routine',
              'Feed, then story, then lights off. Even a two-minute gap '
                  'changes what she associates with going down.'),
          PpCard('Unlatch her while she is drowsy but not gone',
              'Some nights she will accept it. Some nights she will not. Both '
                  'are fine, do not turn it into a battle.'),
          PpCard('Add a second comfort alongside the feed',
              'The same lori, the same hand on her back. In time the comfort '
                  'can work without the feed.'),
          PpCard('Brush or wipe before the last feed',
              'Once she has teeth. This one is not optional.'),
        ], heading: 'If you want to loosen it', hue: 26),
        PpWhenLine('No need to do anything before six months. If you want to '
            'add a second route to sleep, six to twelve months is a '
            'comfortable window, and it takes two to three weeks.'),
        PpIndiaNote('"Doodh pilake sula diya" gets said as a criticism in a lot '
            'of homes. It is not one. If it is working for you and she is '
            'growing well, you have nothing to defend.'),
      ],
    ),
    PpPage(
      id: 'day_night_confusion',
      title: 'She sleeps all day and is awake all night',
      format: 'ARTICLE',
      bands: ['nb'],
      blocks: [
        PpIntro('In the first weeks a lot of babies have their nights and days '
            'the wrong way round. It is real, it is common, and it is one of '
            'the few sleep problems you can genuinely fix in about a week.'),
        PpArticle(heading: 'Why it happens', [
          'She has no body clock yet. Inside you, she slept and woke on your '
              'rhythm, and she was often most active in the evening when you '
              'were finally still. Nothing about being born changes that '
              'overnight.',
          'The clock that will eventually run her days is driven mostly by '
              'light, and it starts working somewhere between six and twelve '
              'weeks. Until then she does not know that dark means night. Your '
              'job is not to teach her a schedule, it is to give her clear, '
              'consistent signals so the clock has something to set itself '
              'by.',
        ]),
        PpSteps(
          heading: 'How to turn it around',
          [
            PpStep('Make daytime bright and noisy', 'Nap her in the day-lit room with the normal sounds of '
                    'the house going on. Do not tiptoe.'),
            PpStep('Take her outside in the morning light', 'Fifteen to twenty minutes of gentle morning sun on '
                    'the balcony or the terrace. Morning light is the strongest '
                    'single tool you have. Avoid harsh midday sun.'),
            PpStep('Wake her for a feed if a daytime nap runs past three hours', 'Yes, wake her. Daytime sleep taken now is night sleep '
                    'you will not get.'),
            PpStep('Make nights dark, dull and quiet', 'Minimum light, no talking, no eye contact games, '
                    'nappy change only if dirty. Night should be boring.'),
            PpStep('Do her biggest feeds in the late afternoon and evening', 'Cluster feeding in the evening is normal and it '
                    'front-loads the calories before the longest stretch.'),
            PpStep('Start a two-minute bedtime cue at the same time nightly', 'Dim, change, feed, lori. Far too short to be a '
                    'routine, which is exactly right for this age.'),
          ],
        ),
        PpCallout('Give it seven to ten days of doing the same thing before you '
            'decide it is not working. The clock sets slowly, and it does '
            'set.'),
        PpWhenLine('Most common in the first six weeks. Nearly always sorted '
            'by eight to twelve weeks. Start the light and dark signals from '
            'day one, they cost nothing.'),
        PpIndiaNote('If the household is up until 11pm, her "night" starts '
            'when the room goes quiet, not when the clock says so. Pick the '
            'realistic time your home actually settles and be consistent with '
            'that instead of fighting for 8pm.'),
      ],
    ),
    PpPage(
      id: 'dropping_naps',
      title: 'When naps drop away',
      format: 'CHART',
      blocks: [
        PpIntro('Naps do not vanish overnight. They go one at a time, and each '
            'transition brings two or three ragged weeks. Knowing which one is '
            'due explains most sudden bedtime trouble.'),
        PpTable(
          heading: 'Naps by age',
          columns: ['Age', 'Naps a day', 'What is changing'],
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
          PpCard('She takes ages to fall asleep for the nap',
              'Consistently, for two weeks or more, and is not upset about '
                  'it.'),
          PpCard('The nap starts pushing bedtime late',
              'She is not tired at bedtime because the nap was too long or too '
                  'late.'),
          PpCard('She skips it happily and stays cheerful till evening',
              'The clearest sign of all. Cheerful is the word that matters.'),
          PpCard('New early morning waking',
              'Sometimes a sign of too much day sleep. Sometimes the opposite. '
                  'Try shortening the nap for a week and see.'),
        ], heading: 'Signs a nap is genuinely ready to go', hue: 26),
        PpCallout('Shorten before you drop, and bring bedtime forward when you '
            'do. Cap the nap at an hour for a fortnight, and move bedtime 30 '
            'minutes earlier while she adjusts. Dropping a nap cold usually '
            'means a week of overtired evenings.'),
        PpWhenLine('Every transition takes two to four unsettled weeks. If she '
            'goes back to needing the nap after a week without it, give it '
            'back. Nothing is decided.'),
        PpIndiaNote('The afternoon nap survives longer in Indian homes than in '
            'Western charts, and the afternoon heat is a genuine reason. A '
            'four-year-old who still sleeps after lunch in May is not behind '
            'anything.'),
        PpLink(
          'See her own nap pattern over a few days',
          surfaceId: 'pp_sleep',
          blurb: 'Log four days and the shape usually becomes obvious.',
        ),
      ],
    ),
    PpPage(
      id: 'joint_family_sleep',
      title: 'Sleep in a joint family or a shared room',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Most sleep advice quietly assumes a separate nursery, a dark '
            'room and a house that goes quiet at 8pm. If that is not your '
            'home, almost none of it is useless. It just needs translating.'),
        PpArticle(heading: 'The three real problems, and what actually helps', [
          'First, the household bedtime. If dinner is at 9.30pm and everyone '
              'is up until 11, a baby cannot sleep at 8. Rather than fight the '
              'whole house, pick the earliest time your home is genuinely calm '
              'and make that her bedtime every night. Consistent and late '
              'beats early and different every day.',
          'Second, light and noise. You cannot dim a room where four people '
              'are living. You can make her corner dark: a curtain on a wire, '
              'a dupatta over the cot side away from the door, her face turned '
              'away from the tube light. For noise, steady sound is much easier '
              'to sleep through than sudden sound, which is why white noise or '
              'a fan helps more than asking people to whisper.',
          'Third, everybody has an opinion. In a joint family her sleep is a '
              'shared subject, and advice arrives whether or not you asked. '
              'The thing that helps is agreeing one routine out loud with the '
              'people who put her down, so that whoever does bedtime does the '
              'same seven things in the same order. Different hands are fine. '
              'Different routines are what confuses her.',
          'And one genuine advantage worth naming. In a house with many arms, '
              'you can actually hand her over and sleep. Mothers in nuclear '
              'homes cannot. If someone offers to take the 5am stretch, that '
              'is not a failure on your part, it is the single best thing '
              'about how you live.',
        ]),
        PpCards([
          PpCard('A curtain, not a room',
              'A wire and a dark curtain around her corner costs a few hundred '
                  'rupees and does most of what a nursery would.'),
          PpCard('Steady sound over silence',
              'A fan, or low white noise. Steady noise masks the door, the '
                  'kitchen and the TV.'),
          PpCard('One routine, agreed out loud',
              'Whoever puts her down, same order. Write the seven steps on a '
                  'paper and stick it up if you need to.'),
          PpCard('Her own surface, in your room',
              'A cot or a firm mattress beside your bed is the safest setup '
                  'and it needs no extra room.'),
          PpCard('Share the nights on purpose',
              'Rota it. One person genuinely asleep is worth more than two '
                  'people half awake.'),
          PpCard('Say the phase out loud',
              'When she is in a regression, tell the house it is a two-week '
                  'phase. It stops six people each suggesting a fix.'),
        ], heading: 'What actually works in a full house', hue: 26),
        PpCallout('Consistency beats conditions. A baby in a bright, noisy, '
            'crowded room with the same routine every night sleeps better than '
            'a baby in a perfect nursery with a different routine each '
            'evening.'),
        PpWhenLine('Worth setting up from about six weeks, and it matters most '
            'between three months and two years.'),
        PpIndiaNote('Sharing your room is recommended, not a compromise. '
            'Sleeping in the same room as you for the first six to twelve '
            'months is associated with a lower risk of SIDS. You are not doing '
            'a second-best version of anything.'),
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
  title: 'Keeping her safe while she sleeps',
  blurb: 'Safer bed-sharing, back to sleep, and what to clear away.',
  hue: 152,
  pages: [
    PpPage(
      id: 'safer_bed_sharing',
      title: 'Safer bed-sharing',
      subtitle: 'How to share a bed with fewer risks',
      format: 'ARTICLE, harm-reduction framed',
      blocks: [
        PpIntro('Most Indian families sleep with their baby, and that is not '
            'going to change because an app says otherwise. So here is the '
            'useful version: how to do it more safely, what raises the risk, '
            'and the small number of nights when she genuinely needs her own '
            'surface.'),
        PpArticle(heading: 'Start with the bed itself', [
          'Nearly all bed-sharing risk comes from the surface and the bedding, '
              'not from the sharing. A firm mattress, no gap, no quilt over '
              'her, and nothing soft near her face removes most of it in one '
              'evening of rearranging.',
          'The dangerous versions are specific and worth knowing exactly: soft '
              'surfaces she can sink into, heavy bedding that can cover her '
              'face, gaps she can slip into between the mattress and the wall '
              'or the bed and the cot, being wedged against a pillow or a '
              'bolster, and an adult who cannot sense her because of alcohol, '
              'sedating medicine or extreme exhaustion.',
          'A very common and very avoidable one: falling asleep with her on a '
              'sofa or an armchair. That is far more dangerous than a properly '
              'set up bed, because she can slide into the gap between you and '
              'the cushions. If you are feeding at night and you might drift '
              'off, do it in the bed, set up as below, not in a chair.',
        ]),
        PpSteps(
          heading: 'Setting the bed up once',
          [
            PpStep('Firm mattress, flat, no dip', 'A firm Indian cotton or coir mattress is good. Soft '
                    'foam, memory foam, a waterbed or a folded quilt as a bed '
                    'are not.'),
            PpStep('Close every gap', 'Push the bed flush against the wall or pull it away '
                    'from the wall entirely. A gap between the mattress and '
                    'the wall is the single most common serious hazard.'),
            PpStep('Put her on her back, beside you, not between two adults', 'Mother\'s side is safest. A mother sleeping beside '
                    'her baby stays aware of her in a way another adult '
                    'usually does not.'),
            PpStep('Get pillows, bolsters and quilts away from her', 'Her head stays clear of your pillow. No bolster '
                    'beside her, no quilt over her.'),
            PpStep('Dress her in her own light layer instead of covering her', 'A sleep sack or a light kurta and pyjama, so your '
                    'blanket never needs to come over her.'),
            PpStep('Keep the blanket at your waist', 'Your own bedding comes no higher than your waist on '
                    'the side she is on.'),
            PpStep('Tie long hair back and take off cords and dupattas', 'Loose hair, drawstrings and dupattas are a strangling '
                    'risk at close quarters.'),
            PpStep('If the bed is high, put a mattress on the floor', 'A firm mattress on the floor, away from walls and '
                    'furniture, is one of the safest setups there is.'),
          ],
        ),
        PpCards([
          PpCard('A soft or sagging mattress',
              'She can sink and her face can be covered. The single most '
                  'important thing to change.'),
          PpCard('Quilts, razai and heavy blankets over her',
              'Give her her own light layer instead.'),
          PpCard('Pillows and bolsters beside her',
              'Clear a space around her head. Bolsters are not a safety '
                  'barrier, they are a hazard.'),
          PpCard('A gap between the bed and the wall',
              'Or between the bed and a cot pushed alongside. Close it or '
                  'remove it.'),
          PpCard('Sleeping with her on a sofa or armchair',
              'Much riskier than a proper bed. Never on purpose, and be '
                  'careful about drifting off.'),
          PpCard('Other children or pets in the bed',
              'An older sibling cannot sense a baby the way you can.'),
        ], heading: 'What raises the risk', hue: 152),
        PpCards([
          PpCard('Her own firm flat surface, in your room',
              'A cot or a firm mattress right beside your bed gives you the '
                  'closeness with none of the bedding risk.'),
          PpCard('Breastfeeding',
              'Associated with a lower risk, and it also puts you in the '
                  'curled position that naturally keeps her space clear.'),
          PpCard('On her back, every time',
              'Day naps included, and by whoever puts her down.'),
          PpCard('A smoke-free home',
              'Nobody smoking anywhere in the house, and not on the balcony in '
                  'the same clothes she is then held in.'),
          PpCard('Room sharing for the first year',
              'Same room, own surface or a safely set up bed. Lower risk than '
                  'a separate room.'),
          PpCard('A comfortable room temperature',
              'Not overheated. Overheating is a known risk and it is the one '
                  'Indian homes get wrong most often.'),
        ], heading: 'What lowers the risk', hue: 152),
        PpCallout('If you change one thing tonight, close the gap and get the '
            'quilt off her. Those two take five minutes and remove most of the '
            'risk in a shared bed.'),
        PpCallout(
          'On these nights, put her on her own firm surface instead: if anyone '
              'in the bed has had alcohol or a sedating medicine, if anyone '
              'smokes, if you are so exhausted you cannot be roused, or if she '
              'was born before 37 weeks or under 2.5 kg and is still under '
              'three months. Ask your doctor about your own situation if she '
              'was born early or small.',
          kind: PpCalloutKind.doctor,
          title: 'Nights when she needs her own surface',
        ),
        PpWhenLine('Set the bed up before she arrives if you can. The risks '
            'are highest in the first three months and drop a lot after six.'),
        PpIndiaNote('Bed-sharing itself is normal here and there is no need to '
            'feel defensive about it. What is worth changing is the razai, the '
            'bolsters and the gap against the wall, because those are what the '
            'actual risk is made of.'),
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
    PpPage(
      id: 'back_to_sleep',
      title: 'On her back, every sleep',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('This is the single most effective piece of safe sleep advice '
            'there is. Putting babies on their backs to sleep cut cot deaths '
            'by more than half in every country that ran the campaign.'),
        PpArticle([
          'On her back, for every sleep, day naps included, by whoever puts '
              'her down. That last part matters: many babies are put on their '
              'backs at night and on their fronts for a day nap by someone '
              'else, and the risk sits with the unfamiliar position.',
          'Side lying is not a safe alternative. A baby on her side rolls onto '
              'her front easily, and the front is the position associated with '
              'the highest risk.',
          'Once she can roll over by herself, usually somewhere between four '
              'and six months, you do not have to turn her back all night. '
              'Put her down on her back, and if she rolls onto her front on '
              'her own, that is allowed. What matters by then is that the '
              'surface around her is clear.',
          'Back sleeping does flatten the back of the head a little in some '
              'babies. It evens out on its own once she is sitting and '
              'crawling. Plenty of tummy time while she is awake and watched '
              'is the answer to it, not front sleeping.',
        ]),
        PpCallout(
          'Myth: a baby on her back will choke if she brings up milk. She will '
              'not. A baby\'s airway is built so that milk drains away when she '
              'is on her back, and babies who sleep on their fronts are not '
              'protected from choking. This one has been studied carefully.',
          kind: PpCalloutKind.myth,
        ),
        PpCallout('Tell everyone who puts her down. Grandmothers, the didi, '
            'the creche. On her back, every single sleep. It is the most '
            'important sentence in this whole section.'),
        PpWhenLine('Every sleep from birth until she rolls independently, '
            'usually four to six months. Awake tummy time from the first '
            'weeks, several short sessions a day.'),
        PpIndiaNote('Front sleeping is still recommended in a lot of Indian '
            'homes because babies do settle more deeply on their fronts. That '
            'deeper sleep is exactly the reason it is riskier. It is worth '
            'saying so plainly and kindly to whoever suggests it.'),
      ],
    ),
    PpPage(
      id: 'swaddling',
      title: 'Swaddling, and when to stop',
      format: 'STEP-LIST',
      bands: ['nb', 'm3_6'],
      blocks: [
        PpIntro('A snug wrap helps a lot of newborns settle, because it stops '
            'the startle reflex from waking them. Done loosely around the '
            'hips, arms in, and stopped at the right moment, it is a good '
            'tool.'),
        PpSteps(
          heading: 'How to swaddle',
          [
            PpStep('Use one thin cotton sheet', 'Thin muslin or cotton. Not a blanket, not a razai, '
                    'and one layer only. Overheating is the main risk.'),
            PpStep('Lay it as a diamond and fold the top corner down', 'Her shoulders sit just below that folded edge.'),
            PpStep('Place her on her back, head clear of the cloth', 'Nothing comes above her shoulders. Ever.'),
            PpStep('Bring one side across her chest and tuck it under her', 'Her arm goes down by her side, inside the wrap.'),
            PpStep('Fold the bottom up loosely', 'Loose over the legs. She must be able to bend her '
                    'knees up and out. A tight straight wrap over the hips can '
                    'harm hip development.'),
            PpStep('Bring the other side across and tuck it in', 'Snug across the chest, and loose at the hips. You '
                    'should fit two or three fingers between the cloth and her '
                    'chest.'),
            PpStep('Put her down on her back, in the same clear space', 'A swaddled baby must never be put down on her front '
                    'or side. She cannot free her arms to move her head.'),
          ],
        ),
        PpCallout('Stop swaddling the day she shows any sign of rolling, even '
            'a first attempt. A swaddled baby who rolls onto her front cannot '
            'push herself back up. Usually somewhere between eight and twelve '
            'weeks. Move to a sleeping bag with arms out.'),
        PpCallout(
          'Ask your doctor before swaddling if she was born early, if she has '
              'been treated for hip dysplasia, or if she has been advised to '
              'sleep in a particular position. And loosen it immediately if '
              'her chest, neck or back feels sweaty or she is breathing '
              'fast.',
          kind: PpCalloutKind.doctor,
          title: 'When to check first',
        ),
        PpWhenLine('From birth to about 8 to 12 weeks, and stop the moment she '
            'attempts to roll, whichever comes first.'),
        PpIndiaNote('The traditional tight wrap, with the legs straightened '
            'and the cloth pulled firm, is the version to avoid. Snug arms, '
            'loose hips is the change, and it is a small one.'),
      ],
    ),
    PpPage(
      id: 'sleep_surface',
      title: 'Her sleep space, checked',
      format: 'CARDS / CHECKLIST',
      blocks: [
        PpIntro('Two minutes, once. Then repeat it whenever she learns '
            'something new, because a baby who can roll, sit or stand can '
            'reach things she could not reach last month.'),
        PpCards([
          PpCard('Firm and flat',
              'A firm mattress that does not dip under her weight. Press it '
                  'with your palm. If your hand sinks, so does she.'),
          PpCard('A tight-fitting sheet, and nothing under it',
              'No folded towel or extra padding beneath her for softness.'),
          PpCard('No gaps anywhere',
              'Between the mattress and the cot sides, between the bed and the '
                  'wall, between a cot and a bed pushed together.'),
          PpCard('Flat, not inclined',
              'No wedge, no propping the mattress up, no sleeping in a car '
                  'seat, bouncer or rocker. She can slump forward and block '
                  'her own airway.'),
          PpCard('Her own space in your room',
              'Same room as you for the first six to twelve months. Own '
                  'surface, or a safely set up bed.'),
        ], heading: 'The surface', hue: 152),
        PpCards([
          PpCard('Pillows and bolsters',
              'No pillow at all under one year. Bolsters are not a barrier and '
                  'they are a hazard.'),
          PpCard('Quilts, razai and loose blankets',
              'Dress her in a light layer instead. If you use a blanket, it is '
                  'thin, tucked in low, and no higher than her chest.'),
          PpCard('Soft toys and bumpers',
              'Nothing soft in the space until one year. Cot bumpers included, '
                  'even the pretty ones.'),
          PpCard('Cords, dupattas and mobile strings',
              'Curtain cords, charger cables and hanging toys, all out of '
                  'reach. Check the reach again when she starts standing.'),
          PpCard('Anything she can pull in on herself',
              'A towel over the cot rail, clothes hung on the side, a mosquito '
                  'net that can sag onto her face.'),
          PpCard('Cigarette smoke, anywhere in the home',
              'Not in the room, not on the balcony, not in the clothes she is '
                  'then held in.'),
        ], heading: 'Clear away', hue: 152),
        PpCallout('The test is simple. If it is soft, loose, or can end up '
            'over her face, it does not belong in her sleep space until she is '
            'one.'),
        PpWhenLine('Check it before she comes home, then again when she starts '
            'rolling, sitting and standing. The strict version applies for the '
            'first twelve months.'),
        PpIndiaNote('The mosquito net is the one that gets forgotten. Use a '
            'frame net that stays tented well above her, not one draped over '
            'the cot that can sag onto her face, and check there is no gap she '
            'can get an arm or her head into.'),
      ],
    ),
    PpPage(
      id: 'overheating',
      title: 'Too warm, and how to tell',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('In Indian homes overheating is a far more common problem than '
            'cold, and it matters, because being too warm is one of the known '
            'risk factors for cot death. The good news is that it is easy to '
            'check.'),
        PpArticle([
          'Feel the back of her neck, or her chest, or her tummy. Not her '
              'hands and not her feet. A baby\'s hands and feet are meant to '
              'be cool, and every layer added because her hands felt cold is a '
              'layer she did not need.',
          'The rule of thumb for dressing her is what you are comfortable in, '
              'plus one thin layer. Not three. A baby cannot take off a topi '
              'or push down a razai, so she has no way to fix it herself.',
          'Aim for a room somewhere around 20 to 24 degrees if you can control '
              'it. Most Indian homes cannot for much of the year, and that is '
              'fine. In a hot room, fewer layers and moving air is the answer. '
              'A fan is safe and is actually associated with lower risk. Point '
              'it at the room and not directly at her.',
          'One thing to drop entirely: the indoor topi. Babies lose heat '
              'through their heads, which is how they cool themselves down. A '
              'cap indoors, on a sleeping baby, in an Indian summer, is worth '
              'taking off.',
        ]),
        PpChartCard(
          title: 'What to dress her in for sleep',
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
              'Along with feeling hot. Cool her down and keep watching.'),
          PpCard('Heat rash on the neck and chest',
              'Tiny red bumps in the folds. She is being over-dressed.'),
          PpCard('Unusually sleepy and hard to rouse when hot',
              'Cool her down and call your doctor.'),
        ], heading: 'Signs she is too warm', hue: 152),
        PpCallout('Back of the neck, not the hands. If it is sweaty, one layer '
            'comes off. That is the whole check and it takes three seconds.'),
        PpWhenLine('Check at every sleep in summer, and any time she seems '
            'unsettled without a reason. Most relevant in the first year.'),
        PpIndiaNote('Sweater, topi and socks indoors in October is standard '
            'advice in a lot of families and it comes from real love. The '
            'gentlest way through it is the neck check, done together, once. '
            'It is hard to argue with a sweaty neck.'),
      ],
    ),
    PpPage(
      id: 'sids_calmly',
      title: 'SIDS, explained calmly',
      format: 'ARTICLE',
      blocks: [
        PpIntro('You may have heard the term and been frightened by it, '
            'possibly at 2am on the internet. Here is the honest picture: it '
            'is rare, most of the risk is understood, and nearly everything '
            'that lowers it is something you can do this evening.'),
        PpArticle(heading: 'What it is, and what it is not', [
          'SIDS means the sudden unexplained death of a baby under one during '
              'sleep. It is a name for what could not be explained, not a '
              'disease she could catch or be born with.',
          'It is rare. It became much rarer everywhere the back-to-sleep '
              'message spread, which is the single strongest clue about what '
              'was going wrong. It is most likely between one and four months, '
              'and the risk falls steeply after six months.',
          'The best current understanding is that it takes several things '
              'lining up: a baby in a vulnerable window of development, '
              'something in the sleep environment that makes breathing harder, '
              'and a stressor like a mild infection or overheating. That is '
              'why the advice is all about the environment. The environment is '
              'the part anyone can change.',
          'What it is not: caused by something you forgot, by vaccination, by '
              'choking on milk, or by any single thing a parent did. Families '
              'who have lost a baby this way did not cause it. If someone has '
              'said or implied otherwise to you, they were wrong.',
        ]),
        PpCards([
          PpCard('On her back, every sleep',
              'The biggest single one, by a distance.'),
          PpCard('Firm flat surface, nothing soft near her face',
              'No pillows, quilts, bumpers or soft toys under one year.'),
          PpCard('Share your room for six to twelve months',
              'Her own surface beside your bed. Lower risk than a separate '
                  'room.'),
          PpCard('A smoke-free pregnancy and a smoke-free home',
              'Second only to sleep position in how much it matters.'),
          PpCard('Do not let her get too hot',
              'Light layers, no indoor cap, moving air.'),
          PpCard('Breastfeed if you can, for as long as suits you',
              'Any amount is associated with lower risk. This is not a reason '
                  'for guilt if you cannot.'),
          PpCard('Keep vaccinations up to date',
              'Vaccinated babies have a lower rate, not a higher one.'),
          PpCard('Offer a dummy at sleep if you use one',
              'Associated with lower risk. Wait until feeding is established '
                  'if you are breastfeeding.'),
        ], heading: 'What genuinely lowers the risk', hue: 152),
        PpCallout(
          'Myth: a home monitor or a smart sock prevents SIDS. No consumer '
              'device has been shown to. They mostly generate false alarms and '
              'anxious nights. The evidence-backed list is the one above, and '
              'it is free.',
          kind: PpCalloutKind.myth,
        ),
        PpCallout('You do not need to watch her breathe all night. Getting the '
            'sleep space right once is worth more than any amount of staying '
            'awake to check, and you need your sleep too.'),
        PpWhenLine('The risk window is mainly one to four months, dropping '
            'sharply after six. The full precautions apply for the first '
            'twelve months.'),
        PpIndiaNote('Being in the same room as you, which most Indian families '
            'do anyway, is on the protective side of this list. So is '
            'breastfeeding. A lot of what your family already does is right.'),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 6 — Common sleep worries
// -----------------------------------------------------------------------------
//  One page per worry, all on the same template the spec asks for: what is
//  going on, is it normal, what helps. The template is identical on purpose so
//  a worried parent recognises the shape by the second page.
// =============================================================================

final PpArea _worries = PpArea(
  id: 'worries',
  mark: IntentMark.moodArc,
  title: 'The things that worry you',
  blurb: 'The five or six sleep questions almost every parent asks.',
  hue: 188,
  pages: [
    PpPage(
      id: 'only_sleeps_on_me',
      title: 'She only sleeps on me',
      format: 'SHORT ARTICLE',
      bands: ['nb', 'm3_6', 'm6_12'],
      blocks: [
        PpIntro('She sleeps beautifully in your arms and wakes within minutes '
            'of being put down. This is one of the most common things new '
            'parents ask about, and one of the most normal.'),
        PpArticle(heading: 'What is going on', [
          'To a newborn, you are the habitat. Your warmth, your smell, your '
              'heartbeat and the movement of your breathing are what she has '
              'known for months. A flat, still, cool mattress is a different '
              'planet, and a baby who protests at being moved to it is behaving '
              'exactly as designed.',
          'There is also a mechanical reason for the wake-up on the way down. '
              'Babies have a startle reflex that fires when their head drops '
              'backwards even slightly. That is why lowering her bottom first, '
              'and keeping her head supported and last, changes the success '
              'rate so much.',
          'It gets better on its own, and mostly between three and six months '
              'as her sleep matures. Nothing you do or do not do now decides '
              'whether she will sleep alone at two.',
        ]),
        PpCards([
          PpCard('Wait for the heavy arm',
              'Lift her arm gently. If it flops loose she is deeply asleep and '
                  'the transfer will probably work. If it has tone, wait five '
                  'more minutes.'),
          PpCard('Warm the surface first',
              'Your hand on the sheet for a minute, or a warm cloth removed '
                  'just before. Cold sheets wake babies.'),
          PpCard('Bottom first, head last, hand stays',
              'Lower her feet and bottom, then her back, then her head. Keep a '
                  'hand on her chest for a minute after.'),
          PpCard('Turn her slightly on her side to lower her, then flat on her '
              'back',
              'Less startle on the way down. She finishes flat on her back, '
                  'always.'),
          PpCard('Use a carrier for one nap a day',
              'A safe upright carry means she sleeps, you have your hands, and '
                  'nobody is fighting a transfer.'),
          PpCard('Take the contact naps on purpose sometimes',
              'One nap a day where you sit down with her and a cup of tea. It '
                  'is not a defeat, and these months are short.'),
        ], heading: 'What helps', hue: 188),
        PpCallout('You cannot spoil a baby by holding her. There is no '
            'evidence that contact sleeping in the first months makes '
            'independent sleep harder later, and plenty that being responded '
            'to helps.'),
        PpWhenLine('Peaks in the first eight weeks. Most babies accept being '
            'put down much more easily by four to six months.'),
        PpIndiaNote('This is where many hands genuinely help. If a grandparent '
            'or your partner can hold her for one nap so you sleep, take it. '
            'She does not need only you for a daytime nap.'),
      ],
    ),
    PpPage(
      id: 'catnapping',
      title: 'Her naps are only 30 minutes',
      format: 'SHORT ARTICLE',
      bands: ['nb', 'm3_6', 'm6_12'],
      blocks: [
        PpIntro('She goes down, sleeps 30 or 40 minutes, and is awake again. '
            'It is called catnapping and around four months it is close to '
            'universal.'),
        PpArticle(heading: 'What is going on', [
          'A baby\'s sleep cycle is about 40 to 50 minutes long. At the end of '
              'one she surfaces. If she cannot get herself back down through '
              'that surfacing, the nap ends there, and you get a nap the exact '
              'length of one cycle.',
          'This is why catnapping arrives so predictably at around four '
              'months. It is the same event as the four-month regression, '
              'showing up in daylight.',
          'It resolves as she learns to link cycles, mostly between five and '
              'eight months, and it usually resolves on its own. A short nap '
              'is only a problem if she is unhappy and overtired by the '
              'evening. If she wakes cheerful and stays cheerful, a 40 minute '
              'nap is enough for her, whatever the chart says.',
        ]),
        PpCards([
          PpCard('Try to be there at the 30 minute mark',
              'Hand on her chest and a shush just before she fully surfaces. '
                  'Sometimes she links straight into the next cycle.'),
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
              'Two steps, always the same: curtain drawn, same lori. She needs '
                  'the signal in the day as well.'),
          PpCard('Do not stretch her to the next nap when she is falling apart',
              'An earlier bedtime is the right answer to a day of short naps, '
                  'not a later one.'),
        ], heading: 'What helps', hue: 188),
        PpCallout('Look at her mood, not the clock. A baby who wakes at 40 '
            'minutes happy and stays happy has had the nap she needed.'),
        PpWhenLine('Most common from 3 to 6 months. Naps usually lengthen '
            'somewhere between 5 and 8 months.'),
        PpIndiaNote('If the day is busy and loud, short naps are partly the '
            'room. A curtained corner and steady sound help more than a '
            'schedule does.'),
      ],
    ),
    PpPage(
      id: 'early_waking',
      title: 'She is up at 5am',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Anything before 6am counts as early waking, and it is one of '
            'the most stubborn sleep problems there is. There are four usual '
            'causes and it is worth working through them in order.'),
        PpArticle(heading: 'What is going on', [
          'Sleep pressure is at its lowest in the early morning. A baby who '
              'surfaces at 5am has already had most of her night sleep, so '
              'there is not much pushing her back down. Any small thing, light, '
              'noise, hunger or a full nappy, is enough to make the waking '
              'stick.',
          'The four common causes, in the order they are worth checking: too '
              'much day sleep or a nap that ran too late, going to bed '
              'overtired, light and sound at dawn, and treating 5am as morning '
              'so that it becomes morning.',
          'The counter-intuitive one is bedtime. Putting her to bed later '
              'almost never fixes early waking and often makes it worse, '
              'because an overtired baby sleeps less deeply through the second '
              'half of the night. Earlier is usually the fix.',
        ]),
        PpCards([
          PpCard('Make the room properly dark at 5am',
              'Indian dawn is early and bright. A dark curtain, or a dark '
                  'cloth clipped over the window, is often the entire '
                  'solution.'),
          PpCard('Bring bedtime 30 minutes earlier for two weeks',
              'Yes, earlier. Try it properly before you decide it makes no '
                  'sense.'),
          PpCard('Cap or shift the last nap',
              'A nap that ends after 4pm, or a long nap, steals from the '
                  'night.'),
          PpCard('Keep 5am boring for 20 minutes',
              'No lights, no talking, no getting up. Feed or pat and lie down '
                  'again. If 5am reliably starts the day, her body will keep '
                  'setting that alarm.'),
          PpCard('Add steady sound',
              'Dawn traffic, birds, temple bells, the kitchen starting up. '
                  'Steady white noise masks all of it.'),
          PpCard('Check whether she is genuinely hungry',
              'For some babies an early feed at 5am, in the dark, buys another '
                  'hour and a half. Worth testing for a week.'),
        ], heading: 'What helps', hue: 188),
        PpCallout('Change one thing and hold it for two weeks. Early waking '
            'shifts slowly, and trying four fixes in four days tells you '
            'nothing about any of them.'),
        PpWhenLine('Most common between 6 months and 3 years. Allow two to '
            'three weeks per change.'),
        PpIndiaNote('If the household is up at 5.30 for the kitchen, the '
            'temple bell or school, she will wake with it. Darkness and steady '
            'sound do more here than anything else, because you are not going '
            'to move the household.'),
      ],
    ),
    PpPage(
      id: 'sleeping_too_much',
      title: 'She sleeps all the time, is that alright?',
      format: 'SHORT ARTICLE',
      bands: ['nb', 'm3_6'],
      blocks: [
        PpIntro('A very sleepy baby usually just needs sleep, especially in the '
            'first weeks. But there are a few specific situations where a '
            'sleepy baby should be woken, and they are worth knowing.'),
        PpArticle(heading: 'What is going on', [
          'Newborns sleep 14 to 17 hours out of 24, and some healthy babies '
              'sit at the top of that range. A baby who is feeding well, '
              'having plenty of wet nappies, gaining weight and alert for at '
              'least short spells is fine.',
          'The one thing worth watching is that sleep does not start crowding '
              'out feeding. In the first two to three weeks, and in any baby '
              'who was born early, small, or is jaundiced, a very sleepy baby '
              'can feed too little, which makes her sleepier, which makes her '
              'feed less. That loop is the reason for waking her.',
          'So the answer is not about hours of sleep. It is about feeds, wet '
              'nappies and weight. If those three are good, let her sleep.',
        ]),
        PpCards([
          PpCard('Count feeds, not hours',
              'Eight to twelve feeds in 24 hours in the early weeks. That is '
                  'the number that matters.'),
          PpCard('Count wet nappies',
              'Six or more properly wet nappies a day after the first week '
                  'means she is getting enough.'),
          PpCard('Wake her to feed if a stretch goes past three hours',
              'In the first two to three weeks, or if your doctor has asked '
                  'you to. Undress her a little, change her, offer skin to '
                  'skin.'),
          PpCard('Look for alert spells',
              'Even a very sleepy newborn has short periods of quiet '
                  'alertness. Some is what you want to see.'),
          PpCard('Sleep yourself while she does',
              'If she is well and feeding, the extra sleep is a gift. Take '
                  'it.'),
        ], heading: 'What helps', hue: 188),
        PpCallout(
          'Call your doctor today if she is hard to wake for feeds, has fewer '
              'wet nappies than usual, looks more yellow, is floppy, is not '
              'interested in feeding, or feels hot or unusually cold. A sudden '
              'change into sleepiness in an older baby also needs a call.',
          kind: PpCalloutKind.doctor,
          title: 'When sleepiness needs a doctor',
        ),
        PpWhenLine('Wake for feeds in the first two to three weeks, and for '
            'longer if she was born early or small or has jaundice, exactly as '
            'your doctor advises.'),
        PpIndiaNote('"Bahut sota hai, achha bachcha hai" is often said kindly '
            'and is usually true. In the first three weeks, still count the '
            'feeds and the nappies rather than going by how settled she '
            'seems.'),
      ],
    ),
    PpPage(
      id: 'own_space',
      title: 'Moving her to her own bed or room',
      format: 'SHORT ARTICLE',
      bands: ['m6_12', 'tod', 'pre'],
      blocks: [
        PpIntro('There is no age at which this has to happen. When you do want '
            'to do it, doing it slowly and at a calm time makes almost all the '
            'difference.'),
        PpArticle(heading: 'What is going on', [
          'Sharing your room for the first six to twelve months is actively '
              'recommended, so there is nothing to hurry. After that it is a '
              'family decision, not a milestone, and plenty of Indian children '
              'share a room with their parents for years without any harm at '
              'all.',
          'The two things that make a move hard are doing it during something '
              'else, and doing it all at once. A move that lands in the same '
              'fortnight as a new sibling, a new school, potty training or a '
              'trip is a move that will go badly for reasons that have nothing '
              'to do with the room.',
          'What she is actually losing is not the bed, it is you nearby. So '
              'the trick is to change the bed and the room separately, so she '
              'only ever loses one thing at a time.',
        ]),
        PpSteps(
          heading: 'A gentle way to do it',
          [
            PpStep('Pick a calm fortnight', 'No illness, no travel, no new sibling, no new creche, '
                    'no potty training in the same weeks.'),
            PpStep('Let her own the new bed in the daytime first', 'A week of playing on it, reading on it, napping on '
                    'it. Let her choose the sheet.'),
            PpStep('Change the surface, not the room', 'Her own mattress or bed, still beside you. One change '
                    'only.'),
            PpStep('Then move the bed, in stages if the room allows', 'A little further away each few nights, or into the '
                    'new room with you sleeping there at first.'),
            PpStep('Keep the bedtime routine exactly the same', 'Same order, same words, same lori. The routine is '
                    'what tells her nothing important has changed.'),
            PpStep('Say what will happen and then do exactly that', '"I will sit here until you sleep, and I will be in '
                    'the next room." Then be there. Trust is the whole '
                    'mechanism.'),
            PpStep('Expect to go back a step, and let that be fine', 'A bad week means one step back, not a failed move.'),
          ],
        ),
        PpCallout('If she ends up in your bed at 3am most nights, that is not '
            'a failed move. Many families settle at exactly this: she starts '
            'in her bed and finishes in yours. If the bed is set up safely, '
            'that is a perfectly good arrangement.'),
        PpWhenLine('Any time after six to twelve months, and often much later. '
            'Allow two to four weeks and pick a calm fortnight.'),
        PpIndiaNote('There is often family pressure in both directions, to '
            'move her out early or to keep her in for years. Neither is a '
            'health question after the first year. It is yours to decide.'),
      ],
    ),
    PpPage(
      id: 'noisy_breathing',
      title: 'She breathes noisily or snores in her sleep',
      format: 'SHORT ARTICLE + doctor callout',
      blocks: [
        PpIntro('Babies are noisy sleepers. Snuffles, squeaks, little grunts '
            'and irregular breathing are all normal, and most of it comes from '
            'anatomy rather than a problem. There is a specific short list '
            'that does need a doctor, and it is below.'),
        PpArticle(heading: 'What is going on', [
          'A baby\'s nasal passages are narrow and she breathes mostly through '
              'her nose, so a very small amount of dryness or mucus makes a '
              'lot of noise. Add soft floppy airway tissue and you get a baby '
              'who sounds dramatic and is completely fine.',
          'Newborn breathing is also naturally irregular. She may breathe '
              'quickly for a while, then slowly, then pause for a few seconds, '
              'then start again. Pauses under about ten seconds, with normal '
              'colour and no effort, are normal in the early weeks and settle '
              'as she matures.',
          'Occasional snoring during a cold, or when she is congested, is '
              'ordinary. What is not ordinary is snoring most nights, snoring '
              'that comes with pauses and gasps, or breathing that is visibly '
              'hard work. Those are worth a proper look, and they are usually '
              'very treatable, often something as simple as large tonsils or '
              'adenoids.',
        ]),
        PpCallout(
          'Call your doctor now, or go to hospital, if she pauses in her '
              'breathing for more than about 20 seconds, goes blue or grey '
              'around the lips or tongue, is gasping, is pulling in under her '
              'ribs or at the base of her throat with each breath, is '
              'breathing very fast at rest, or is grunting with every breath. '
              'Do not wait for morning for any of these.',
          kind: PpCalloutKind.doctor,
          title: 'Same day, or straight away',
        ),
        PpCards([
          PpCard('Snoring most nights, not just with a cold',
              'Worth an appointment. Often tonsils or adenoids, and treatable.'),
          PpCard('Pauses followed by a gasp or a snort',
              'Mention this specifically. It is the pattern that matters.'),
          PpCard('Sleeping with her neck stretched right back',
              'Or only settling half sitting up. She may be finding a position '
                  'to breathe in.'),
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
              'Cigarette smoke, mosquito coils and heavy agarbatti in a closed '
                  'room all irritate a small airway.'),
          PpCard('Film it on your phone',
              'Thirty seconds of the sound and her chest moving is worth more '
                  'to your doctor than any description you can give.'),
        ], heading: 'What helps at home', hue: 188),
        PpCallout('Noisy is usually fine. Effortful is not. If she is working '
            'hard to breathe, or changing colour, that is the line, and you do '
            'not need to be sure before you call.'),
        PpWhenLine('Snuffly breathing is most common in the first three '
            'months. Habitual snoring is more of a toddler and preschool '
            'thing, and that is when to ask about tonsils.'),
        PpIndiaNote('Mosquito coils, closed rooms and winter smoke make '
            'snuffly babies snufflier. A mesh screen and a mosquito net are '
            'better than a coil burning in the room she sleeps in.'),
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
  title: 'Music, lori and sleep sounds',
  blurb: 'What actually helps, what is myth, and the tracks to play tonight.',
  hue: 96,
  pages: [
    PpPage(
      id: 'does_music_help',
      title: 'Does music actually help babies sleep?',
      format: 'HONEST ARTICLE',
      blocks: [
        PpIntro('Partly yes, and not in the way it is usually sold. Some of '
            'this has real evidence behind it, some of it is marketing, and '
            'one part of it is a genuine safety issue nobody mentions.'),
        PpArticle(heading: 'What genuinely helps', [
          'Steady, unchanging sound helps, and this is the best supported part. '
              'White noise, womb sounds, a fan or steady rain mask the sudden '
              'noises that wake a baby: a door, a pressure cooker, the '
              'neighbour\'s bike. In a shared room in an Indian home, that '
              'masking is doing most of the work, not the music.',
          'Being sung to helps, and more than a recording does. Babies '
              'consistently prefer a live human voice, and they prefer their '
              'mother\'s. A lori sung badly by you beats a beautifully '
              'produced track, every time. Singing also slows your own '
              'breathing down, which she feels.',
          'Consistency helps most of all. The same sound, every night, in the '
              'same order, becomes a cue that sleep is next. That is where '
              'nearly all of the benefit lives. Which track you choose matters '
              'far less than playing the same one nightly.',
          'And slow music helps more than pretty music. Slow, low, repetitive, '
              'no sudden changes in volume. This is why the traditional night '
              'ragas and simple lori work: they were built for exactly this.',
        ]),
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
          PpCard('"Playing something all night helps her sleep deeper"',
              'It does not, and continuous sound all night is the part with an '
                  'actual downside. See the safety note below.'),
          PpCard('"She needs it to sleep now, so we have created a problem"',
              'A sound cue is one of the easiest cues to travel with and to '
                  'let go of later. Of all the sleep associations, this is the '
                  'least troublesome one.'),
        ], heading: 'What is myth', hue: 96),
        PpCallout(
          'Keep the volume low, use the timer, and keep the speaker away from '
              'her head. As a rule: quieter than a normal conversation, at '
              'least two to three feet away, never in the cot, and never a '
              'phone on the pillow. Loud sound played close to a baby all '
              'night has been linked to hearing damage, and continuous sound '
              'all night gives her nothing to listen to as she matures. Set it '
              'to switch itself off after 30 to 45 minutes. The timer in the '
              'player is on by default for this reason.',
          title: 'Low volume, and use the timer',
        ),
        PpWhenLine('White noise and womb sounds suit newborns best. Lori suit '
            'every age. Stories start earning their place from about 18 '
            'months. Thirty to forty-five minutes, then off.'),
        PpIndiaNote('The lori your own mother sang is a better choice than '
            'anything in a library, because you know it by heart and you can '
            'sing it in the dark at 3am with your eyes shut. Use the library '
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
          blurb: 'Lori, white noise, rain, soft ragas and stories. '
              'Timer on by default.',
        ),
      ],
    ),
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
        PpArticle(heading: 'Lullabies and lori', [
          'A sung human voice, slow and repetitive. Suits every age from birth '
              'and stays useful into the school years. Best of all sung by you, '
              'and these are here for the nights when you have nothing left.',
        ]),
        PpAudioSlot(
          title: 'Nini Baba Nini',
          category: 'Lullabies and lori',
          minutes: '5 MIN',
          slotId: 'sleep_sounds/lori_nini_baba',
        ),
        PpAudioSlot(
          title: 'Aaja Nindiya Aaja',
          category: 'Lullabies and lori',
          minutes: '6 MIN',
          slotId: 'sleep_sounds/lori_aaja_nindiya',
        ),
        PpAudioSlot(
          title: 'Lalla Lalla Lori',
          category: 'Lullabies and lori',
          minutes: '4 MIN',
          slotId: 'sleep_sounds/lori_lalla_lalla',
        ),
        PpAudioSlot(
          title: 'Thaai Thaai, a Tamil thalattu',
          category: 'Lullabies and lori',
          minutes: '5 MIN',
          slotId: 'sleep_sounds/lori_thaai_thalattu',
        ),
        PpAudioSlot(
          title: 'Humming lori, no words',
          category: 'Lullabies and lori',
          minutes: '20 MIN',
          slotId: 'sleep_sounds/lori_humming_wordless',
        ),
        PpArticle(heading: 'White noise and womb sounds', [
          'Steady, unchanging sound that masks doors, kitchens and traffic. The '
              'best supported category, and the one that suits newborns most. '
              'Low volume, well away from her head, and off after the timer.',
        ]),
        PpAudioSlot(
          title: 'Womb sounds, as she heard them',
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
              'months, when she starts noticing sound as something separate '
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
              'on her own.',
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
          'Low volume, speaker away from her head, timer on. Quieter than a '
              'normal conversation, at least two to three feet away, never in '
              'the cot and never a phone on the pillow. Thirty to forty-five '
              'minutes, then off.',
          title: 'The same safety note, because it matters',
        ),
        PpWhenLine('Newborns: white noise and womb sounds. Three months and up: '
            'nature and ragas. Eighteen months and up: stories. Lori at any '
            'age.'),
        PpIndiaNote('Download the two or three you actually use before you '
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
  ],
);
