// =============================================================================
//  Jaapa: Your First 40 Days — the section's content
// -----------------------------------------------------------------------------
//  Built from docs/../pp_specs/08-first-40-days.md. Ten areas plus four tools.
//
//  ⚠️ THIS SECTION LANDS ON THE PEAK-FEAR MOMENT OF THE WHOLE PRODUCT. The spec
//  says it plainly: "a scared parent at day 3". So every page here is written
//  reassurance-first and instruction-second. The order inside a page is not a
//  style choice, it is the design: she is told the thing is ordinary, then told
//  what to do about it. A page that opens with a warning has already failed,
//  because a frightened reader stops at the first alarming line and never
//  reaches the part that would have calmed her.
//
//  ⚠️ AND YET THE RED FLAGS MUST BE UNMISSABLE. Newborn danger signs are
//  genuinely time-critical, so "When to Rush to the Doctor" is the SECOND area,
//  above everything except the day spine, and it carries no product, no course
//  and no paid consult. Only a free link to a human. The spec asks for the
//  consult to be surfaced on that card; the same spec also says the card is
//  upsell-free and carries no commerce. Both are honoured by linking to the
//  expert door with no price and no sell, and putting the actual paid
//  `PpConsult` on the feeding and tracker pages instead.
//
//  ⚠️ THE SPINE IS DAYS, AND `PpBand` COUNTS MONTHS. Stated here because it is
//  the one place this file bends the shared mechanism. `ppDaysSinceBirth`
//  exists (see pp_age_bands.dart) and is the honest unit for a 0-to-40-day
//  section, but `PpPage.bands` is matched against a `PpBandSet` and a band
//  boundary is an `int` month. Days 1 to 30 all floor to month 0, so month
//  bands physically cannot separate "week 1" from "week 3".
//
//  The choice made: THREE honest month bands (the first month / the 40-day mark
//  / past the 40 days) rather than four fake ones whose day labels would be
//  wrong for most readers in them. The four day phases the spec asks for exist
//  as PAGES inside "Din by Din", all visible through the first month, so a
//  mother at day 3 can read ahead and a mother at day 25 is not told day 3 is
//  her present. A true day-level spine needs day boundaries on `PpBand`, and
//  that is written up as a follow-up rather than faked here.
//
//  ⚠️ MYTH VERSUS EVIDENCE, NOT TRADITION VERSUS SCIENCE. Jaapa is honoured on
//  every page it touches, and the specific practices that harm are named
//  specifically. A page that dismissed the whole tradition would be ignored by
//  the grandmother running the house, and she is the reader who can actually
//  change what happens to the baby.
//
//  ⚠️ BOUNDARY: the baby, plus the mother's IMMEDIATE first weeks, live here.
//  Deeper and ongoing recovery (postpartum depression care, pelvic floor,
//  return to work) belongs to the "You, Maa" section and is LINKED, not rebuilt.
//
//  ⚠️ NO GAMIFICATION ANYWHERE. Counts are fine, streaks are not. A woman on day
//  6 after a caesarean must never be told she missed a day.
//
//  ⚠️ EVERY CLINICAL NUMBER IN THIS FILE CARRIES A `REQUIRED_REVIEW` COMMENT.
//  Temperatures, nappy counts, feed intervals, weight-loss percentages,
//  breathing rates and bleeding thresholds are all marked, because a number is
//  the one kind of copy tone cannot soften: if it is wrong, it is wrong at the
//  moment it matters most. A paediatrician and an obstetrician sign these off
//  before release. Grep `REQUIRED_REVIEW` for the full list.
//
//  ⚠️ ENGLISH ONLY FOR NOW, per the standing instruction. Hinglish where the
//  Hinglish word IS the word: jaapa, malish, jhula, kadha, gond laddoo, dai,
//  maalishwali, nada, janam ghutti.
// =============================================================================

import 'pp_age_bands.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// =============================================================================
//  THE BANDS
// -----------------------------------------------------------------------------
//  Declared here rather than in pp_age_bands.dart because no other section
//  measures this window, and a shared set would invite someone to move a
//  boundary here for a reason about six-week checks.
//
//  Three bands, not four. See the file header: months cannot split the first
//  thirty days, and a coarse label beats a label that lies.
// =============================================================================

const PpBandSet kPpJaapaBands = PpBandSet([
  PpBand(
    id: 'jaapa_first_month',
    label: 'The first month',
    fromMonths: 0,
    toMonths: 1,
    blurb: 'Roughly day 1 to day 30. The part nobody could have prepared you '
        'for, and the part that passes fastest.',
  ),
  PpBand(
    id: 'jaapa_forty',
    label: 'The 40-day mark',
    fromMonths: 1,
    toMonths: 2,
    blurb: 'Week 5 and 6. Jaapa is ending, and a rhythm is starting to show '
        'itself.',
  ),
  PpBand(
    id: 'jaapa_after',
    label: 'Past the 40 days',
    fromMonths: 2,
    toMonths: 600,
    blurb: 'You are through it. Everything here stays open, because newborn '
        'questions do not stop on day 41.',
  ),
]);

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpFirst40Section = PpSection(
  id: 'parenting_first_40', // MUST match the hub's bracketId
  title: 'Jaapa: Your First 40 Days',
  subtitle: 'Newborn care, and looking after the person who just gave birth.',
  intro: 'The first forty days are loud, tender and very short. Here is what is '
      'normal, what to do, and the few things that need a doctor today.',
  bandSet: kPpJaapaBands,
  areas: [
    // =========================================================================
    //  1. Din by Din — the 0 to 40 day spine
    // =========================================================================
    PpArea(
      id: 'din_by_din',
      mark: IntentMark.stepsMark,
      title: 'Din by Din: Your 40-Day Guide',
      blurb: 'Where you are today, and what it actually means.',
      hue: 26,
      pages: [
        PpPage(
          id: 'f40_days_1_7',
          title: 'Days 1 to 7: the first week',
          subtitle: 'Survival, not routine. That is the correct plan.',
          format: 'DAY-SPINE CARD',
          bands: ['jaapa_first_month'],
          blocks: [
            PpIntro('This week is meant to feel like this. Your baby is '
                'learning to feed, you are bleeding and sore, and nobody in '
                'the house has slept. None of that is a sign something has '
                'gone wrong.'),
            PpVideoSlot(
              title: 'Your first 40 days, gently explained',
              subtitle: 'What jaapa is for, what changes week by week, and the '
                  'few things worth watching.',
              minutes: '8 MIN',
              slotId: 'first40/welcome_intro',
            ),
            PpChartCard(
              title: 'What is normal in week 1',
              // REQUIRED_REVIEW: every number in this card. Feeds per 24 hours
              // (8 to 12), day-5-onward wet nappy count (6 or more), the stool
              // colour progression, and up-to-10-percent birth weight loss with
              // recovery by day 14.
              rows: [
                ('Feeds in 24 hours', '8 to 12, day and night'),
                ('Longest sleep stretch', '2 to 3 hours, if you are lucky'),
                ('Wet nappies by day 5', '6 or more, pale urine'),
                ('Poop', 'Black and sticky, then green, then yellow'),
                ('Weight', 'Drops up to 10 percent, back up by day 14'),
                ('Cord stump', 'Dries, darkens, still attached'),
              ],
              note: 'A newborn who feeds, wets nappies and can be settled is '
                  'doing well, even if he cries a lot.',
              hue: 26,
            ),
            PpCards([
              PpCard('Feed him whenever he asks',
                  'There is no schedule worth protecting this week. Offer the '
                  'breast at every stir, and wake him if he sleeps long.'),
              PpCard('Keep the cord dry and uncovered',
                  'Nothing on it. No oil, no haldi, no ash, no powder.'),
              PpCard('Sponge baths only for now',
                  'A soft cloth, a warm room, and no rush. The proper bath can '
                  'wait for the cord.'),
              PpCard('Lie down more than you think you should',
                  'Your bleeding is heaviest now and it gets worse when you '
                  'are on your feet. Rest is treatment, not laziness.'),
              PpCard('Let one person guard the door',
                  'Visitors can come next week. This week is for feeding and '
                  'healing.'),
            ], heading: 'What to do this week', hue: 26),
            PpWhenLine('Fits roughly day 1 to day 7, from the day of birth.'),
            PpIndiaNote('If the house is already full of relatives, give one '
                'family member the job of saying no on your behalf. It is far '
                'easier for your mother or your husband to turn people away '
                'than for you to do it from the bed.'),
            PpCallout('You do not need to enjoy this week. Feeding him, and '
                'being looked after yourself, is the whole job.'),
            PpCallout(
              'Some things in a newborn cannot wait. Trouble breathing, a '
              'fever, refusing feeds, far fewer wet nappies, deepening '
              'jaundice, or a baby who is floppy or hard to wake means a '
              'doctor today. The full list is in "When to Rush to the Doctor" '
              'on the section home.',
              kind: PpCalloutKind.doctor,
              title: 'The few things that need a doctor now',
            ),
          ],
        ),
        PpPage(
          id: 'f40_days_8_15',
          title: 'Days 8 to 15: finding the feed',
          subtitle: 'Jaundice watch, malish begins, and visitors arrive.',
          format: 'DAY-SPINE CARD',
          bands: ['jaapa_first_month'],
          blocks: [
            PpIntro('The panic of the first week usually softens here. Feeding '
                'starts to work, your milk has come in properly, and the cord '
                'is on its way out.'),
            PpChartCard(
              title: 'What is normal in week 2',
              // REQUIRED_REVIEW: cord separation window (day 5 to 15), jaundice
              // peak (day 4 to 5) and fade (day 10 to 14), wet nappy count of 6
              // or more per 24 hours.
              rows: [
                ('Cord stump', 'Falls off between day 5 and day 15'),
                ('Jaundice', 'Peaked around day 4 or 5, now fading'),
                ('Feeds in 24 hours', 'Still 8 to 12, a little more organised'),
                ('Wet nappies', '6 or more every 24 hours'),
                ('Weight', 'Climbing back towards birth weight'),
                ('Awake time', 'Short bursts, still no sense of day and night'),
              ],
              note: 'Milk that leaks, breasts that feel full, and a baby who '
                  'feeds noisily are all signs this is working.',
              hue: 26,
            ),
            PpCards([
              PpCard('Start malish once the cord has gone',
                  'Gentle oil massage, warm room, never straight after a feed. '
                  'The full how-to is in "Malish, Jhula and Soothing".'),
              PpCard('Watch the yellow, do not panic about it',
                  'Look at his face in daylight. Jaundice that is fading is '
                  'ordinary. Jaundice spreading to palms and soles is not.'),
              PpCard('Set visiting hours out loud',
                  'One hour in the evening, hands washed, nobody unwell, '
                  'nobody kissing his face.'),
              PpCard('Eat and drink at every feed',
                  'Keep water and something to eat beside where you feed. '
                  'Hunger and thirst hit hardest during letdown.'),
            ], heading: 'What to do this week', hue: 26),
            PpWhenLine('Fits roughly day 8 to day 15.'),
            PpIndiaNote('This is usually when the maalishwali starts coming. '
                'Watch the first massage yourself before you leave them alone '
                'with him, and say clearly that nothing goes in his eyes, '
                'ears, nose or mouth.'),
            PpCallout(
              'Jaundice that is getting deeper instead of lighter, that reaches '
              'his palms or the soles of his feet, or that appears for the '
              'first time after two weeks needs a doctor the same day. '
              'Yellowing together with poor feeding or a very sleepy baby needs '
              'one now.',
              kind: PpCalloutKind.doctor,
              title: 'Jaundice that needs checking',
            ),
          ],
        ),
        PpPage(
          id: 'f40_days_16_30',
          title: 'Days 16 to 30: the long evenings',
          subtitle: 'Cluster feeding, more alert time, and your own healing.',
          format: 'DAY-SPINE CARD',
          bands: ['jaapa_first_month'],
          blocks: [
            PpIntro('Two things usually arrive together now. He is awake and '
                'looking at you more, and he wants to feed on and off through '
                'the whole evening. Both are growth, not a problem.'),
            PpChartCard(
              title: 'What is normal in weeks 3 and 4',
              // REQUIRED_REVIEW: expected weight gain of 150 to 200 grams a
              // week in the first three months, and the crying peak at about
              // week 6.
              rows: [
                ('Weight', 'Above birth weight, gaining 150 to 200 g a week'),
                ('Evening feeding', 'Long clusters, often 4 pm to 10 pm'),
                ('Awake and alert', '30 to 60 minutes at a stretch'),
                ('Crying', 'Peaks around week 6, then eases'),
                ('Your bleeding', 'Lighter, brown or pink, still there'),
              ],
              note: 'Cluster feeding in the evening is how he builds your milk '
                  'supply. It is not a sign that you have too little.',
              hue: 26,
            ),
            PpCards([
              PpCard('Plan for the evening instead of fighting it',
                  'Dinner cooked early, phone charged, water nearby, something '
                  'to watch. Feed, and let the evening pass.'),
              PpCard('Give him one bright morning',
                  'Daylight, noise and normal household life in the day. Quiet '
                  'and dim at night. That is how day and night sort themselves '
                  'out.'),
              PpCard('Start moving gently',
                  'Short slow walks inside the house. Nothing that pulls at '
                  'stitches or a caesarean scar.'),
              PpCard('Book the one-month check',
                  'Weight, feeding, jaundice and the next vaccines all get '
                  'looked at together.'),
            ], heading: 'What to do now', hue: 26),
            PpWhenLine('Fits roughly day 16 to day 30.'),
            PpIndiaNote('If relatives are telling you the evening crying means '
                'your milk is not enough and formula should start, check his '
                'nappies and his weight instead. Those two answer the '
                'question, and an argument does not.'),
            PpLink('His weight, plotted',
                surfaceId: 'pp_growth',
                blurb: 'Add this month\'s weight and see the curve.'),
          ],
        ),
        PpPage(
          id: 'f40_days_31_40',
          title: 'Days 31 to 40: a rhythm appears',
          subtitle: 'The end of jaapa, and what changes after it.',
          format: 'DAY-SPINE CARD',
          bands: ['jaapa_first_month', 'jaapa_forty'],
          blocks: [
            PpIntro('Something shifts in these ten days. You can usually tell '
                'his cries apart, you have a rough sense of his evenings, and '
                'you have stopped checking quite so often whether he is '
                'breathing.'),
            PpChartCard(
              title: 'What is normal now',
              // REQUIRED_REVIEW: 7 to 10 feeds per 24 hours at 5 to 6 weeks,
              // longest night stretch of 3 to 4 hours, and first social smile
              // at around 6 weeks.
              rows: [
                ('Feeds in 24 hours', '7 to 10, more predictable'),
                ('Longest night sleep', '3 to 4 hours, sometimes more'),
                ('Smiling', 'A first real social smile appears around now'),
                ('Your bleeding', 'Mostly stopped, or nearly'),
                ('Neck', 'Lifts his head briefly when on his tummy'),
              ],
              note: 'If none of this has happened yet, it is still normal. '
                  'Babies arrive at these things weeks apart.',
              hue: 26,
            ),
            PpCards([
              PpCard('Do not rebuild the house on day 41',
                  'Jaapa ending does not mean you are back to full strength. '
                  'Add one thing a week, not everything at once.'),
              PpCard('Keep the help you can keep',
                  'Cooking and cleaning help matters more in month two than '
                  'month one, because that is when everyone assumes you are '
                  'fine.'),
              PpCard('Get your own six-week check done',
                  'Bleeding, stitches, blood pressure, mood, and contraception '
                  'if you want it. This one is for you, not the baby.'),
              PpCard('Notice how you feel, not only how he feeds',
                  'Low mood that has not lifted in two weeks deserves the same '
                  'seriousness as a fever.'),
            ], heading: 'What to do now', hue: 26),
            PpWhenLine('Fits roughly day 31 to day 40, and the weeks just '
                'after.'),
            PpIndiaNote('The 40-day mark often comes with a ceremony, a first '
                'outing and a house full of people. Going out is fine now. '
                'Being handed around a room of forty guests is still a lot for '
                'him, and for you.'),
          ],
        ),
        PpPage(
          id: 'f40_forty_mark',
          title: 'You made it to 40 days. What now?',
          subtitle: 'What jaapa was actually for, and what comes next.',
          format: 'SHORT ARTICLE',
          bands: ['jaapa_forty', 'jaapa_after'],
          blocks: [
            PpIntro('Forty days is not a medical deadline. It is the length of '
                'time our families worked out that a new mother needs to be '
                'fed, kept warm and left alone. They were broadly right.'),
            PpArticle([
              'What jaapa protects is real. Rest while the uterus shrinks back '
              'and the bleeding stops. Warm, easy food while your appetite is '
              'strange. Fewer visitors while your baby has little immunity of '
              'his own. Someone else cooking while you feed every two hours.',
              'What it does not do is finish your recovery. A caesarean scar '
              'takes months to stop aching. Your pelvic floor, your back and '
              'your sleep are all still mending on day 41, and nobody throws a '
              'ceremony for month four.',
              'So treat the 40-day mark as the end of the emergency, not the '
              'end of the healing. The next stretch is quieter and longer, and '
              'it has its own section in this app.',
            ]),
            PpCallout('If one thing carries forward from jaapa, let it be this. '
                'You are allowed to be looked after even when you are no '
                'longer visibly unwell.'),
            PpLink('You, Maa: your longer recovery',
                surfaceId: 'pp_you_maa',
                blurb: 'Pelvic floor, mood, strength, going back to work, and '
                    'the parts that take months.'),
            PpLink('What changes next in him',
                surfaceId: 'pp_what_changed',
                blurb: 'The leaps, growth spurts and sudden changes ahead.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  2. When to Rush to the Doctor — THE SAFETY CORE
    // -------------------------------------------------------------------------
    //  ⚠️ SECOND AREA, DELIBERATELY. High enough to find at 2am, not first,
    //  because opening a section for frightened new parents with a list of
    //  emergencies is the anxiety this product is written against.
    //
    //  ⚠️ NO COMMERCE ON EITHER PAGE. No PpConsult, no product link, no course.
    //  The only outward links are free: the expert door with no price attached,
    //  and the help finder.
    // =========================================================================
    PpArea(
      id: 'rush_to_doctor',
      mark: IntentMark.chartLog,
      title: 'When to Rush to the Doctor',
      blurb: 'The short list that cannot wait until morning. Read it once now, '
          'so you are not reading it for the first time in a panic.',
      hue: 12,
      pages: [
        PpPage(
          id: 'f40_red_flags',
          title: 'When to rush to the doctor',
          subtitle: 'Newborn danger signs, and what to do about each one.',
          format: 'FLAGGED QUICK-REFERENCE',
          blocks: [
            PpIntro('Almost everything a newborn does is normal, which is '
                'exactly why the short list of things that are not deserves its '
                'own page. Read it once while you are calm.'),
            PpCallout(
              'If you are here because something feels badly wrong right now, '
              'do not finish reading. Go to the nearest hospital with a '
              'paediatric or newborn unit. A newborn seen too early is sent '
              'home. A newborn seen too late is a different story.',
              kind: PpCalloutKind.doctor,
              title: 'If you are frightened right now',
            ),
            PpTable(
              heading: 'Go now, or call now',
              columns: ['If you see this', 'What to do'],
              rows: [
                [
                  'Struggling to breathe: fast breathing, grunting with every '
                  'breath, nostrils flaring, ribs pulling in, or he stops '
                  'breathing',
                  'Go now. Nearest hospital with a newborn unit.',
                ],
                [
                  'Blue or dusky lips, tongue or face',
                  'Go now.',
                ],
                [
                  'Fever, or a body that feels cold and will not warm up',
                  'Go now. A temperature in a baby under 3 months is always '
                  'treated as urgent.',
                ],
                [
                  'Refusing feeds, or too sleepy to feed for two feeds in a row',
                  'Call now, and be ready to go in.',
                ],
                [
                  'Far fewer wet nappies than usual, or a dry nappy for many '
                  'hours',
                  'Call now. This is the earliest sign of dehydration.',
                ],
                [
                  'Yellow deepening, or reaching his palms and the soles of his '
                  'feet',
                  'Same day. Ask for a bilirubin check.',
                ],
                [
                  'Floppy, limp, or very hard to wake',
                  'Go now.',
                ],
                [
                  'A fit: jerking, stiffening, staring and unresponsive, or lip '
                  'smacking',
                  'Go now.',
                ],
                [
                  'Vomiting every feed, forceful vomiting, or vomit that is '
                  'green or yellow-green',
                  'Go now.',
                ],
                [
                  'Blood in the stool, black stool after the first few days, or '
                  'a swollen hard tummy',
                  'Go now.',
                ],
                [
                  'Cord area red and spreading onto the belly, oozing pus, or '
                  'smelling bad',
                  'Same day.',
                ],
                [
                  'A cry that is different: shrill, weak, or inconsolable for '
                  'hours with nothing helping',
                  'Call now.',
                ],
              ],
            ),
            PpChartCard(
              title: 'The numbers, if you have been asked for them',
              subtitle: 'Useful on the phone to a doctor.',
              // REQUIRED_REVIEW: EVERY ROW IN THIS CARD IS A CLINICAL THRESHOLD
              // AND MUST BE CONFIRMED BY A PAEDIATRICIAN BEFORE RELEASE.
              //   * Fever: 100.4 F / 38.0 C, treated as an emergency under 3
              //     months. Confirm the measurement site we state (we do not
              //     name one here on purpose) and whether an axillary figure
              //     should be lower.
              //   * Too cold: below 97.5 F / 36.5 C.
              //   * Breathing too fast: more than 60 breaths a minute at rest,
              //     counted for a full minute while settled.
              //   * Breathing pause: longer than 15 to 20 seconds, or any pause
              //     with a colour change.
              //   * Wet nappies: fewer than 6 in 24 hours from day 5 onward.
              //   * Weight: more than 10 percent below birth weight.
              rows: [
                ('Fever', '100.4 F or 38 C and above'),
                ('Too cold', 'Below 97.5 F or 36.5 C'),
                ('Breathing too fast', 'More than 60 breaths a minute at rest'),
                ('Breathing pause', 'Longer than 15 to 20 seconds'),
                ('Wet nappies, day 5 onward', 'Fewer than 6 in 24 hours'),
                ('Weight', 'More than 10 percent below birth weight'),
              ],
              note: 'You do not need a number to be allowed to worry. If he '
                  'looks wrong to you, that is reason enough to be seen.',
              hue: 12,
            ),
            PpSteps([
              PpStep('Say his age in days first',
                  'A newborn is a different patient at day 3 and day 30, and it '
                  'changes what happens next.'),
              PpStep('Say the one thing that frightened you',
                  'Not the whole history. "He has not fed since morning and his '
                  'nappy is dry" is the useful sentence.'),
              PpStep('Say his temperature if you have it',
                  'And say how you took it.'),
              PpStep('Ask directly whether to come in',
                  '"Should I bring him now, or in the morning?" is a fair '
                  'question and you are allowed to ask it.'),
            ], heading: 'What to say when you call'),
            PpWhenLine('Applies from birth through the whole newborn period. '
                'Under 3 months, everything on this list is treated as more '
                'urgent than it would be later.'),
            PpIndiaNote('Do two things today, while nothing is wrong. Save the '
                'nearest 24-hour paediatric hospital number in your phone, and '
                'find out which chemist near you stays open at night. At 2am, '
                'knowing where to go is most of the problem solved.'),
            PpCallout(
              'Nothing on this page is a diagnosis, and none of it can be '
              'settled by an app. It is a list of moments to hand over to a '
              'doctor.',
            ),
            // ⚠️ FREE LINK, NOT A SELL. See the area note above.
            PpLink('Not an emergency, but you are not sure',
                surfaceId: 'pp_experts',
                blurb: 'Talk to a newborn nurse or a lactation expert instead '
                    'of guessing at 2am.'),
            PpLink('Find help near you',
                surfaceId: 'pp_find_help',
                blurb: 'Paediatricians, lactation support and night help.'),
          ],
        ),
        PpPage(
          id: 'f40_crying_never_shake',
          title: 'When the crying will not stop',
          subtitle: 'What to do with him, and what to do with yourself.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('There will be an evening when you have tried everything, '
                'he is still screaming, and you feel something you did not '
                'expect to feel. That happens to almost every parent, and it '
                'does not mean anything is wrong with you.'),
            PpArticle([
              'Newborn crying climbs from birth, peaks somewhere around week 6, '
              'then eases. Some of it has no cause you can find and no fix you '
              'can apply. That is genuinely how it is built, and it is the '
              'hardest fact of the first two months to accept.',
              'The dangerous moment is not the crying. It is exhaustion plus '
              'the feeling that you must make it stop. So the plan below is '
              'about keeping both of you safe, in that order.',
            ]),
            PpSteps([
              PpStep('Check the fixable things once',
                  'Hungry, wet, too warm, too cold, wind, or wanting to be '
                  'held. Once through the list, not five times.'),
              PpStep('Try the calming sequence',
                  'Swaddle, hold him on his side against you, shush close to '
                  'his ear, sway. Give each one a full minute before changing.'),
              PpStep('If you feel your temper rising, put him down',
                  'Flat on his back in his cot or on a firm bed. A crying baby '
                  'in a safe place is completely fine.'),
              PpStep('Walk out of the room for five minutes',
                  'Drink water. Sit down. Let yourself cry. Set a timer if it '
                  'helps you come back.'),
              PpStep('Call someone in',
                  'Your husband, your mother, your sister, a neighbour. Handing '
                  'him over for twenty minutes is not failure, it is the '
                  'correct move.'),
              PpStep('Go back to him',
                  'He will not remember the five minutes. He will be picked up '
                  'again by someone who can hold him calmly.'),
            ], heading: 'The plan, in order'),
            PpCallout(
              'Never shake him, and never let anyone else. A newborn neck '
              'cannot hold his head, and shaking causes bleeding and injury '
              'inside the brain that no amount of sorry undoes. He should also '
              'never be thrown up in the air, jerked to stop hiccups, or '
              'vigorously rocked to force sleep. If he has been shaken even '
              'once, take him to a hospital today and say exactly what '
              'happened. He can look completely fine and still need checking.',
              kind: PpCalloutKind.doctor,
              title: 'Never shake a baby',
            ),
            PpCallout(
              'A cry that is genuinely different needs a doctor, not more '
              'soothing. Shrill or high pitched, weak and whimpering, '
              'inconsolable for hours with nothing at all helping, or crying '
              'alongside a fever, vomiting, a swollen tummy or refusing feeds.',
              kind: PpCalloutKind.doctor,
              title: 'Crying that needs a doctor',
            ),
            PpIndiaNote('In a joint family the crying is often treated as a '
                'verdict on you: your milk, your handling, your nerves. It is '
                'not. Say out loud that you need twenty minutes and someone '
                'else needs to hold him. Being surrounded by people only helps '
                'if you actually use them.'),
            PpWhenLine('Crying peaks around 6 weeks and eases from around 3 to '
                '4 months.'),
            PpLink('If the hard feelings are not lifting',
                surfaceId: 'pp_you_maa',
                blurb: 'Low mood, rage, numbness and frightening thoughts, and '
                    'what actually helps.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  3. Samjho Your Newborn — the article library
    // -------------------------------------------------------------------------
    //  Every page follows the spec's fixed skeleton: what it is, what to do,
    //  what to watch (flagged where it matters), and which day range it fits.
    // =========================================================================
    PpArea(
      id: 'samjho',
      mark: IntentMark.listMark,
      title: 'Samjho Your Newborn',
      blurb: 'Every strange thing he does, and whether it means anything.',
      hue: 44,
      pages: [
        PpPage(
          id: 'f40_cord_care',
          title: 'Looking after the cord stump',
          subtitle: 'Dry, uncovered, and nothing on it.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('The cord stump looks alarming and needs almost nothing '
                'from you. Keeping it dry and open to the air is the whole '
                'treatment, and it works better than anything you could put on '
                'it.'),
            PpSteps([
              PpStep('Leave it uncovered',
                  'Air dries it faster than any dressing. No bandage, no '
                  'binder, no cotton pad, no belt.'),
              PpStep('Fold the nappy below it',
                  'Or use a nappy with a dip cut out at the front, so urine '
                  'never soaks the stump.'),
              PpStep('Wash your hands before touching it',
                  'This is the single most useful thing anyone in the house '
                  'can do for it.'),
              PpStep('Clean only if it gets dirty',
                  'Plain water on clean cotton, then let it air dry. Not soap, '
                  'not antiseptic, unless your doctor asked for one.'),
              PpStep('Sponge bath until it falls off',
                  'Wash him in parts on a towel. No tub baths yet.'),
              PpStep('Let it fall off on its own',
                  'Usually between day 5 and day 15. Never pull it, even if it '
                  'is hanging by a thread.'),
            ], heading: 'How to care for it'),
            // REQUIRED_REVIEW: cord separation window of day 5 to 15, and
            // whether we should name chlorhexidine or dry cord care as the
            // default for Indian home births specifically.
            PpWhenLine('From birth until it separates, usually day 5 to day '
                '15. A little dampness or a few drops of blood as it comes '
                'away is normal.'),
            PpCallout(
              'Nothing goes on the cord. Not haldi, not oil, not ash or '
              'raakh, not cow dung, not powder, not surma, not a coin, not a '
              'binder. This is not a small superstition to indulge. These '
              'applications cause umbilical infection and tetanus, and tetanus '
              'in a newborn kills. Dry and uncovered is the modern medical '
              'advice for a reason.',
              kind: PpCalloutKind.myth,
              title: 'The one hard rule',
            ),
            PpCallout(
              'See a doctor the same day if the skin around the cord is red '
              'and the redness is spreading onto the belly, if there is pus or '
              'a foul smell, if it bleeds more than a few spots, if the belly '
              'is swollen and tender, or if he has a fever or has gone off '
              'feeds.',
              kind: PpCalloutKind.doctor,
              title: 'Cord signs that need a doctor',
            ),
            PpIndiaNote('If an older relative or the dai wants to apply '
                'something, offer the swap rather than the argument. "The '
                'doctor said dry only, and it falls off faster this way" ends '
                'the conversation more often than a lecture does.'),
          ],
        ),
        PpPage(
          id: 'f40_first_bath',
          title: 'His first bath, and when to start',
          subtitle: 'Later than you think, and shorter than you think.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('There is no rush to bathe a newborn. The white coating he '
                'is born with protects his skin, and waiting a day or two is '
                'better for his temperature, his blood sugar and his first '
                'feeds.'),
            PpArticle([
              'For the first days, a top-to-toe sponge wash on a towel is '
              'enough: face, neck folds, hands, nappy area. Two or three baths '
              'a week is plenty for a newborn, and daily is fine in hot weather '
              'if he enjoys it.',
              'Once the cord has fallen off and healed, you can move to a small '
              'tub. Warm room first, everything laid out within reach, and keep '
              'the whole bath to about five minutes.',
            ]),
            PpSteps([
              PpStep('Warm the room, close the windows',
                  'Bathe him where there is no draught. Warmth matters more '
                  'than water depth.'),
              PpStep('Lay everything out first',
                  'Towel, clean clothes, nappy, mug, and the oil if you are '
                  'doing malish. Never leave him to fetch something.'),
              PpStep('Test the water on your elbow',
                  'It should feel pleasantly warm, not hot. Fill the tub before '
                  'he goes in, and check again.'),
              PpStep('Wash his face and head first',
                  'Plain water on the face. A little baby soap or wash on the '
                  'scalp, and not every day.'),
              PpStep('Support his head and neck the whole time',
                  'One forearm under his back, your hand holding his far '
                  'shoulder. His head never goes under.'),
              PpStep('Get into the folds',
                  'Neck, armpits, groin and behind the knees hold milk and '
                  'sweat, and that is where rashes start.'),
              PpStep('Out, wrapped, dried in the folds, dressed',
                  'Dry properly rather than rubbing hard. Then feed him, he '
                  'will be hungry.'),
            ], heading: 'The bath, step by step'),
            // REQUIRED_REVIEW: (a) delaying the first bath by at least 24 hours
            // after birth, (b) bath water at about 37 to 38 C, (c) 2 to 3 baths
            // a week as the newborn norm.
            PpWhenLine('First bath after the first 24 hours, sponge washes '
                'until the cord falls off, tub baths after that. Two or three '
                'a week is enough, more in hot weather.'),
            PpCallout('Never leave him alone in water for a second, not even '
                'in an inch of it, not even with an older child watching. '
                'Answer the door later.'),
            PpIndiaNote('Many families do not bathe the baby for the first few '
                'days, and that custom lines up with the medical advice rather '
                'than against it. What is worth changing is the vigorous '
                'head-down malish-and-bath routine some maalishwalis use, and '
                'anyone pouring water over his face to "make him strong". '
                'Gentle is not weak.'),
            PpCallout(
              'Skip the bath and speak to your doctor if he is unwell, feeding '
              'poorly, or was born early or small. Cold stress in a small baby '
              'is a real risk, and a wash on a towel is always the safer '
              'option.',
              kind: PpCalloutKind.doctor,
              title: 'When not to bathe him',
            ),
          ],
        ),
        PpPage(
          id: 'f40_nappy_poop',
          title: 'Nappies, and what his poop should look like',
          subtitle: 'The two counts that tell you he is fine.',
          format: 'CHART-CARD',
          blocks: [
            PpIntro('Newborn poop changes colour dramatically in the first '
                'week, and almost all of it is normal. Nappies are also the '
                'cheapest reassurance you have: enough wet ones means enough '
                'milk.'),
            PpChartCard(
              title: 'What to expect, day by day',
              // REQUIRED_REVIEW: the whole nappy-count and stool-progression
              // table. Wet nappies rising to 6 or more from day 5, stools of at
              // least 3 to 4 a day from day 4 to about week 6, meconium
              // clearing by day 3 to 4.
              rows: [
                ('Day 1', '1 wet nappy, black sticky meconium'),
                ('Day 2', '2 wet nappies, still black'),
                ('Day 3', '3 wet nappies, turning greenish'),
                ('Day 4', '4 or more wet, yellow starting'),
                ('Day 5 onward', '6 or more wet, pale urine'),
                ('Stools, after day 4', '3 or more a day, yellow and seedy'),
              ],
              note: 'After about 6 weeks, a breastfed baby can go days without '
                  'a stool and still be perfectly well, as long as it is soft '
                  'when it comes.',
              hue: 44,
            ),
            PpCards([
              PpCard('Black and tar-like, first 2 days',
                  'Meconium. Sticky and hard to wipe. Completely normal.'),
              PpCard('Dark green, days 3 to 4',
                  'The changeover. Milk is getting through.'),
              PpCard('Mustard yellow with seeds',
                  'The classic breastfed poop. Loose is normal, it is not '
                  'diarrhoea.'),
              PpCard('Tan or brown, firmer',
                  'Usual on formula. Also normal.'),
              PpCard('A little dark green sometimes',
                  'Common and harmless in the early weeks.'),
              PpCard('A pink or orange stain in a girl\'s nappy',
                  'Often just concentrated urine, or a small hormonal bleed in '
                  'the first week. Mention it, do not panic.'),
            ], heading: 'The colours, and what they mean', hue: 44),
            PpSteps([
              PpStep('Change him at every feed, and whenever he is dirty',
                  'A newborn nappy off for a couple of minutes is good for his '
                  'skin.'),
              PpStep('Clean front to back, especially for a girl',
                  'Plain water and cotton, or a fragrance-free wipe.'),
              PpStep('Dry properly before the new nappy',
                  'Trapped damp is what causes most nappy rash.'),
              PpStep('Use a thin barrier if the skin is red',
                  'A plain zinc or petroleum jelly layer. Not talcum powder, '
                  'which he can breathe in.'),
            ], heading: 'Changing him'),
            PpWhenLine('This pattern holds through the first 6 weeks. Colours '
                'settle after that.'),
            PpCallout(
              'See a doctor for these: no wet nappy for many hours or a sudden '
              'drop in wet nappies, blood in the stool, stool that is white, '
              'chalky or pale grey, black stool after the first few days, '
              'watery stools with a fever or a floppy baby, or no stool at all '
              'in the first 48 hours of life.',
              kind: PpCalloutKind.doctor,
              title: 'Nappy signs that need a doctor',
            ),
            PpIndiaNote('Cloth langots are perfectly fine and often kinder in '
                'the heat, they just need changing sooner because you cannot '
                'tell how wet they are. If you are using cloth, count wet '
                'nappies by weight and feel rather than by look.'),
          ],
        ),
        PpPage(
          id: 'f40_swaddle',
          title: 'Swaddling, and how tight is right',
          subtitle: 'Snug at the arms, loose at the hips.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('A swaddle works because it stops his own startle reflex '
                'from waking him. It is one of the most useful tricks of the '
                'first weeks, and it has two rules that matter.'),
            PpSteps([
              PpStep('Lay a thin square cloth as a diamond, top corner folded '
                  'down', 'Cotton or muslin. Thin, not a blanket.'),
              PpStep('Put him on it with his shoulders on the fold',
                  'Head clear of the cloth, always.'),
              PpStep('Bring one side across his chest and tuck it under him',
                  'Arms down and snug against his body, or up beside his face '
                  'if he prefers that.'),
              PpStep('Fold the bottom up, loosely',
                  'This is the hip rule. His legs must be able to bend up and '
                  'out and kick freely.'),
              PpStep('Bring the other side across and tuck it in',
                  'You should be able to slide a flat hand between the cloth '
                  'and his chest.'),
              PpStep('Always put him down on his back',
                  'A swaddled baby must never be placed on his front or side.'),
            ], heading: 'How to swaddle'),
            PpCallout(
              'Two hard rules. Tight around the chest and arms is fine, tight '
              'around the hips is not, because it can damage how the hip joint '
              'forms. And a swaddled baby always sleeps on his back, never on '
              'his front or side.',
              kind: PpCalloutKind.key,
            ),
            // REQUIRED_REVIEW: stop swaddling at the first signs of rolling,
            // usually 8 to 12 weeks. Confirm the age we state.
            PpWhenLine('Useful from birth. Stop swaddling as soon as he shows '
                'any sign of rolling or pushing up on his side, usually around '
                '8 to 12 weeks.'),
            PpCards([
              PpCard('Not over the face',
                  'Nothing loose near his head. No dupatta, no towel, no '
                  'pillow.'),
              PpCard('Not with a nada or tight binder',
                  'Binding the belly or chest with cord or cloth restricts his '
                  'breathing and does nothing for his shape.'),
              PpCard('Not in layers',
                  'One thin swaddle instead of a swaddle plus a blanket plus a '
                  'sweater. Overheating is the real risk.'),
              PpCard('Not straightening his legs',
                  'Pulling the legs straight and wrapping them tight is the '
                  'practice that harms hips. Bent and free is correct.'),
            ], heading: 'What not to do', hue: 44),
            PpIndiaNote('The old cloth wrap and the modern velcro swaddle bag '
                'both work. In summer, one thin cotton layer with the arms out '
                'is often all he can tolerate, and that is fine. A sweaty, '
                'flushed, hot-necked baby is over-wrapped, whatever the elders '
                'say about him catching cold.'),
          ],
        ),
        PpPage(
          id: 'f40_warm_enough',
          title: 'Is he too hot, or too cold?',
          subtitle: 'Dressing him for real Indian weather.',
          format: 'CHART-CARD',
          blocks: [
            PpIntro('Newborns cannot regulate their temperature well, so they '
                'do need help. In most Indian homes the mistake goes one way '
                'though: far too many layers, because a cold baby is what '
                'everyone is afraid of.'),
            PpChartCard(
              title: 'What to dress him in',
              // REQUIRED_REVIEW: room temperature of 26 to 28 C, the "one layer
              // more than an adult" rule, and both temperature figures quoted
              // in the doctor callout below.
              rows: [
                ('The rule', 'One layer more than you are comfortable in'),
                ('Room, ideally', '26 to 28 C'),
                ('Summer, no AC', 'A thin cotton vest and nappy. That is all'),
                ('In AC', 'Full sleeve cotton, socks, a thin sheet'),
                ('Winter, north India', 'Vest, full sleeves, socks, cap, one '
                    'blanket'),
                ('Monsoon', 'Cotton layers you can change often, dry skin '
                    'folds'),
              ],
              note: 'Check the back of his neck or his tummy, not his hands. '
                  'Cold hands and feet are normal in a warm baby.',
              hue: 44,
            ),
            PpCards([
              PpCard('Too warm looks like this',
                  'Sweaty neck and back, flushed face, damp hair, restless or '
                  'unusually sleepy, a heat rash on the neck and chest.'),
              PpCard('Too cold looks like this',
                  'A cool back or tummy, a pale or mottled body, unusually '
                  'quiet and hard to wake, not interested in feeding.'),
              PpCard('A cap indoors is rarely needed',
                  'He loses heat through his head, and that also lets him cool '
                  'down. Cap for outings and cold nights, not all day.'),
              PpCard('Never a heater or angeethi in a closed room',
                  'Coal and kerosene in an unventilated room can kill. Room '
                  'heaters must be kept away from the cot and never left on '
                  'with the door and windows shut.'),
            ], heading: 'Reading him', hue: 44),
            PpWhenLine('Applies through the whole newborn period, and matters '
                'most in the first two weeks.'),
            PpCallout(
              'A temperature in a baby under 3 months is urgent either way. '
              '100.4 F or 38 C and above, or below 97.5 F or 36.5 C after you '
              'have warmed him, needs a doctor the same day. Do not give '
              'paracetamol or any fever medicine to a newborn unless a doctor '
              'has told you the dose.',
              kind: PpCalloutKind.doctor,
              title: 'Fever, and being too cold',
            ),
            PpIndiaNote('If the family insists on a sweater in May, the '
                'compromise that works is a thin cotton full-sleeve top. It '
                'looks like a layer, it does not cook him, and it stops the '
                'argument.'),
          ],
        ),
        PpPage(
          id: 'f40_newborn_skin',
          title: 'His skin looks strange. Is that normal?',
          subtitle: 'Peeling, spots, patches and blotches.',
          format: 'CARDS',
          blocks: [
            PpIntro('Newborn skin does a lot of odd things in the first weeks '
                'and nearly all of it clears on its own. Most of what worries '
                'parents needs no cream at all.'),
            PpCards([
              PpCard('Peeling and flaking',
                  'Especially hands, feet and ankles, in the first two weeks. '
                  'Normal. A plain moisturiser if it looks dry, nothing more.'),
              PpCard('Tiny white pinhead spots on the nose and cheeks',
                  'Milia, blocked oil glands. They clear by themselves in a '
                  'few weeks. Do not squeeze them.'),
              PpCard('Blotchy red patches with a small pale centre',
                  'A common newborn rash of the first week. Comes and goes '
                  'across the body and needs nothing.'),
              PpCard('Small pimples on the face at 3 to 4 weeks',
                  'Newborn acne, driven by hormones. Wash with plain water and '
                  'wait. No creams.'),
              PpCard('Slate grey or bluish patches on the back and buttocks',
                  'Common in Indian babies. Harmless birthmarks that fade over '
                  'years.'),
              PpCard('A flat pink patch on the eyelids, forehead or nape',
                  'A stork mark. It reddens when he cries and usually fades.'),
              PpCard('Yellow greasy scales on the scalp',
                  'Cradle cap. Soften with a little oil an hour before a bath, '
                  'then wash gently. Never pick it off.'),
              PpCard('Prickly red bumps in the neck folds',
                  'Heat rash. Fewer layers, a cooler room, and keep the folds '
                  'dry.'),
            ], heading: 'Common and harmless', hue: 44),
            PpWhenLine('Most of this appears in the first 2 to 4 weeks and '
                'settles by 2 to 3 months.'),
            PpCallout(
              'Show a doctor: blisters, or spots filled with pus or fluid; a '
              'rash with a fever or a baby who is feeding poorly; small dark '
              'red or purple spots that do not fade when you press them; '
              'yellow, weeping or spreading patches; or a rash all over the '
              'body that appeared very quickly.',
              kind: PpCalloutKind.doctor,
              title: 'Skin that needs a doctor',
            ),
            PpIndiaNote('Besan and malai are traditional for the skin and are '
                'mostly harmless on the body, but keep them away from his eyes '
                'and mouth, and stop if the skin reddens. Skip fairness pastes '
                'and any lightening product entirely. His colour is not a '
                'problem to be treated.'),
          ],
        ),
        PpPage(
          id: 'f40_jaundice',
          title: 'Jaundice: what to watch and when it matters',
          subtitle: 'Very common, usually harmless, occasionally not.',
          format: 'FLAGGED ARTICLE',
          blocks: [
            PpIntro('Most newborns go a little yellow in the first week. It '
                'happens because his liver is still learning to clear a normal '
                'waste product, and in the great majority of babies it fades on '
                'its own. It is still worth watching properly.'),
            PpChartCard(
              title: 'The usual timeline',
              // REQUIRED_REVIEW: the entire jaundice timeline. Onset day 2 to
              // 3, peak day 4 to 5, fading by day 10 to 14 (later in breastfed
              // babies), plus the three red-flag timings named below: yellow in
              // the first 24 hours, jaundice reaching palms and soles, and new
              // or persisting jaundice after 2 weeks.
              rows: [
                ('Appears', 'Day 2 or 3, face first'),
                ('Peaks', 'Around day 4 or 5'),
                ('Fades', 'By day 10 to 14, sometimes a little later'),
                ('Spreads', 'Face, then chest, then tummy, then legs'),
                ('Treatment, if needed', 'Light therapy in hospital'),
              ],
              note: 'Feeding him often is the most useful thing you can do. '
                  'Milk moves the waste product out through his stools.',
              hue: 44,
            ),
            PpSteps([
              PpStep('Look at him in daylight, not under a tube light',
                  'Yellow light hides it and white light exaggerates it. Take '
                  'him near a window.'),
              PpStep('Press gently on his forehead or nose, then let go',
                  'Yellow in the blanched skin as the colour returns is '
                  'jaundice.'),
              PpStep('Check how far down it goes',
                  'Face only is usually mild. Chest and tummy means more. '
                  'Palms and soles means see a doctor today.'),
              PpStep('Feed him often, 8 to 12 times a day',
                  'Wake him if he is sleepy. Sleepy plus yellow is the '
                  'combination to act on.'),
              PpStep('Count his wet nappies and stools',
                  'Fewer stools slows the clearing. Report a drop.'),
            ], heading: 'How to check him at home'),
            PpCallout(
              'Sunlight through a window is not treatment. It is not enough '
              'light to clear jaundice, and putting a newborn in direct sun '
              'risks burning him and overheating him. Nor does stopping '
              'breastfeeding help; more feeding is what clears it. Real '
              'treatment is a hospital light unit, and it works quickly.',
              kind: PpCalloutKind.myth,
              title: 'The sunlight myth',
            ),
            PpCallout(
              'See a doctor today if he looks yellow in the first 24 hours of '
              'life, if the yellow is deepening rather than fading, if it '
              'reaches his palms or the soles of his feet, if he is very sleepy '
              'or feeding poorly, if his stools are pale or chalky and his '
              'urine is dark, or if he is still yellow after two weeks. Ask for '
              'a bilirubin level, not a look.',
              kind: PpCalloutKind.doctor,
              title: 'Jaundice that needs a doctor',
            ),
            PpWhenLine('Watch daily from day 2 to about day 14. Any jaundice '
                'starting on day 1, or lasting past two weeks, is checked '
                'regardless of how mild it looks.'),
            PpIndiaNote('Home light treatment kits are sold and rented in many '
                'cities. Do not arrange one yourself on the basis of how yellow '
                'he looks. Jaundice is treated against a blood level and his '
                'age in hours, and only a doctor can set that.'),
          ],
        ),
        PpPage(
          id: 'f40_cluster_feeding',
          title: 'He wants to feed all evening',
          subtitle: 'Cluster feeding and growth spurts, explained.',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('Feeding every twenty minutes from five in the evening '
                'until midnight is one of the most alarming and most normal '
                'things a newborn does. It is almost never about your milk '
                'running out.'),
            PpArticle([
              'Cluster feeding is short feeds bunched close together, usually in '
              'the evening, often with fussing in between. He is topping up, '
              'settling himself, and telling your body to make more milk for '
              'tomorrow. The signal works because he is draining you now.',
              'Growth spurts do the same thing for a day or two at a time. They '
              'tend to land at around 2 to 3 weeks, 6 weeks and 3 months, and '
              'they end as suddenly as they start.',
              'The reason it feels like failure is the timing. Evening is when '
              'your supply naturally feels softest and when the whole house is '
              'watching. Neither of those means there is less milk.',
            ]),
            PpCards([
              PpCard('He is fine if the nappies are fine',
                  'Six or more wet nappies a day and steady weight gain settle '
                  'the question. Fussing does not.'),
              PpCard('Feed him rather than time him',
                  'A clock cannot tell you whether he is hungry. He can.'),
              PpCard('Set yourself up for it',
                  'Water, food, a charged phone, a comfortable corner. Plan the '
                  'evening around feeding rather than fighting it.'),
              PpCard('Let someone else do everything else',
                  'This is the shift where help is worth the most.'),
            ], heading: 'What actually helps', hue: 44),
            PpWhenLine('Common from about day 10 to 3 months, heaviest in the '
                'evenings and around growth spurts.'),
            PpCallout(
              'This is different from a baby who is not getting enough. Speak '
              'to a doctor or a lactation expert if he has fewer than 6 wet '
              'nappies a day, is not back to birth weight by two weeks, is not '
              'gaining after that, is sleepy and hard to wake for feeds, or '
              'feeds constantly and still seems desperate and limp.',
              kind: PpCalloutKind.doctor,
              title: 'When constant feeding is a real problem',
            ),
            PpIndiaNote('Evening cluster feeding is the single most common '
                'reason formula gets started in Indian homes, usually on the '
                'advice of someone who loves you. If you want to keep '
                'breastfeeding, ask for the nappy count and the weight to be '
                'checked first. If you choose to top up, that is your decision '
                'and a fed baby is the point.'),
          ],
        ),
        PpPage(
          id: 'f40_newborn_noises',
          title: 'Hiccups, sneezes, grunts and other noises',
          subtitle: 'The sounds that keep parents awake for nothing.',
          format: 'CARDS',
          blocks: [
            PpIntro('Newborns are noisy sleepers and noisy feeders. Most of the '
                'sounds that make you sit up at 3am mean nothing at all.'),
            PpCards([
              PpCard('Hiccups, several times a day',
                  'His diaphragm is immature. They do not hurt him. A feed or a '
                  'cuddle usually settles them, and never jerk him or startle '
                  'him to stop them.'),
              PpCard('Sneezing often',
                  'Clearing dust and mucus from a tiny nose. Not a cold, unless '
                  'there is also a blocked nose that stops him feeding.'),
              PpCard('Grunting and straining, especially while pooping',
                  'He is learning to push while lying flat. Normal. Constipated '
                  'means hard pellets, not effort.'),
              PpCard('A rattly or snuffly nose',
                  'Narrow passages plus normal mucus. Saline drops if it blocks '
                  'a feed, and nothing else.'),
              PpCard('Squeaks, whimpers and cries in sleep',
                  'Light sleep. Wait a minute before picking him up, he often '
                  'settles himself.'),
              PpCard('Jerky arms and legs, and a startle with a bang',
                  'A normal newborn reflex. It fades by 3 to 4 months.'),
              PpCard('Irregular breathing while asleep',
                  'Fast, then slow, then a short pause. Normal in a newborn as '
                  'long as he stays pink and the pauses are brief.'),
              PpCard('A small posset of milk after feeds',
                  'Bringing up a mouthful is normal. Forceful or green vomiting '
                  'is not.'),
            ], heading: 'Normal, and needing nothing', hue: 44),
            PpWhenLine('All of this is usual through the first 3 months.'),
            PpCallout(
              'These same sounds need a doctor now if breathing is the problem '
              'rather than the noise: more than 60 breaths a minute at rest, '
              'grunting with every single breath, nostrils flaring, ribs or the '
              'space between them pulling in, a pause longer than 15 to 20 '
              'seconds, a blue tinge to the lips or tongue, or a blocked nose '
              'that stops him feeding at all.',
              kind: PpCalloutKind.doctor,
              title: 'Noises that are actually breathing trouble',
            ),
            PpIndiaNote('Hiccups get treated at home with water, gutti or a '
                'thread on the forehead. Water before six months is genuinely '
                'unsafe for him, and gripe water and janam ghutti are not '
                'needed by any baby. A feed does the same job with none of the '
                'risk.'),
          ],
        ),
        PpPage(
          id: 'f40_day_night',
          title: 'Why he is awake all night',
          subtitle: 'Day and night confusion, and how it sorts itself out.',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('He spent nine months in the dark with no idea when morning '
                'was, and he was rocked to sleep every time you walked around. '
                'Being awake at night is not a habit he has picked up. It is '
                'the setting he arrived with.'),
            PpArticle([
              'Newborns sleep in short cycles, around the clock, and they wake '
              'often because they need to feed often. There is no routine to '
              'build yet and no schedule that will hold. What does exist is a '
              'gentle nudge you can give his body clock.',
              'The nudge is light and activity in the day, dark and dullness at '
              'night. Nothing else. Most babies find a longer night stretch '
              'somewhere between 6 and 12 weeks, and it arrives on its own '
              'timing rather than yours.',
            ]),
            PpSteps([
              PpStep('Make mornings bright and ordinary',
                  'Open the curtains. Let the house be noisy. Feed him in the '
                  'light and chat to him.'),
              PpStep('Keep night feeds boring',
                  'Dim light, no talking, no play, straight back down. Kind, '
                  'but dull.'),
              PpStep('Do not let him sleep more than 3 hours in the day early '
                  'on', 'Waking a long daytime sleeper for a feed helps him '
                  'take more of his sleep at night.'),
              PpStep('Sleep when he sleeps, even in the afternoon',
                  'It is the least glamorous advice in the world and it is '
                  'still the only one that works.'),
              PpStep('Take turns if you can',
                  'One long stretch of unbroken sleep for you, once a day, '
                  'changes how the whole week feels.'),
            ], heading: 'What actually helps'),
            PpWhenLine('Day and night confusion is normal for the first 6 to 8 '
                'weeks and usually settles by 3 months.'),
            PpCallout('There is no sleep training in this app, and none of it is '
                'appropriate for a newborn anyway. At this age, responding to '
                'him is the correct answer every single time.'),
            PpIndiaNote('In a joint family the night is often shared, and that '
                'is genuinely an advantage. Let a grandmother do the 5am shift '
                'if she offers. The one thing to hold firm on is where he '
                'sleeps and how, because safe sleep does not change with who is '
                'holding him.'),
            PpLink('Newborn sleep, in full',
                surfaceId: 'pp_sleep',
                blurb: 'What is normal at every age, and gentle settling.'),
          ],
        ),
        PpPage(
          id: 'f40_safe_sleep',
          title: 'Sleeping safely, in your bed or his',
          subtitle: 'How to make the way your family sleeps safer.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Almost every Indian family sleeps with the baby in the '
                'room, and most share the bed. Rather than telling you not to, '
                'here is how to make it as safe as it can be, and the few '
                'situations where it genuinely is not.'),
            PpSteps([
              PpStep('On his back, every sleep',
                  'Naps included, at night, with anyone. This one rule reduces '
                  'the risk more than everything else combined.'),
              PpStep('On a firm flat surface',
                  'A firm mattress or a cot. Not a soft mattress, not a quilt '
                  'nest, not a pillow, not a sofa, and never on a folded razai '
                  'he can sink into.'),
              PpStep('Nothing loose around his head',
                  'No pillow, no soft toys, no bumpers, no dupatta, no thick '
                  'blanket. A thin sheet tucked low, or a sleep bag.'),
              PpStep('His own clear space in the bed',
                  'Beside the mother, not between the parents, not against a '
                  'wall or a bolster where he can be wedged.'),
              PpStep('Feet to the foot of the bed, sheet no higher than his '
                  'chest', 'So bedding cannot ride up over his face.'),
              PpStep('In your room for the first 6 months',
                  'In your room is protective, in your bed is a separate '
                  'question. A cot beside the bed gives you both.'),
              PpStep('Never on a sofa or an armchair with you',
                  'Falling asleep holding him on soft furniture is the single '
                  'most dangerous place to sleep together.'),
            ], heading: 'Making sleep safer, wherever he sleeps'),
            PpCallout(
              'Do not share a bed with him at all if anyone in the bed has '
              'been drinking, has taken anything that makes them drowsy, '
              'smokes, or is extremely exhausted, or if he was born early or '
              'very small. In those situations put him in a cot beside you '
              'instead, and keep him in the room.',
              // A rule she acts on, not a flag that sends her to someone: the
              // instruction is complete as written. See PpCalloutKind.safety.
              kind: PpCalloutKind.safety,
              title: 'When bed-sharing is not safe',
            ),
            PpWhenLine('These rules matter most in the first 6 months, and the '
                'back-to-sleep rule holds until he rolls confidently on his '
                'own.'),
            PpIndiaNote('The traditional cloth jhula and the metal palna are '
                'both fine for supervised naps if he lies flat on a firm base '
                'with nothing padded under him, and someone is in the room. '
                'What is not fine is a deep hammock shape that curls his chin '
                'onto his chest, or leaving him swinging while everyone is '
                'outside.'),
            PpLink('The full safe sleep guide',
                surfaceId: 'pp_sleep',
                blurb: 'Cots, co-sleeping, naps and everything after the '
                    'newborn weeks.'),
          ],
        ),
        PpPage(
          id: 'f40_folk_practices',
          title: 'The old practices: which help and which harm',
          subtitle: 'Honest about both, because both are true.',
          format: 'COMPARISON TABLE',
          blocks: [
            PpIntro('Jaapa gets a great deal right, and it is worth saying so '
                'first. It rests the mother, feeds her warm food, keeps crowds '
                'away from a new baby and puts hands on him every day. Modern '
                'newborn care agrees with all of that.'),
            PpCards([
              PpCard('Forty days of rest for the mother',
                  'Genuinely protective. Bleeding settles faster and feeding '
                  'establishes better when she is not running the house.'),
              PpCard('Daily malish',
                  'Real benefits. Better weight gain, calmer babies, better '
                  'sleep, and it is how fathers and grandmothers bond.'),
              PpCard('Warm, easy, ghee-rich food',
                  'Sensible for a woman with a low appetite and high energy '
                  'needs. Protein and iron matter most.'),
              PpCard('Keeping visitors away',
                  'Correct. A newborn has very little immunity, and infection '
                  'is the main thing you are protecting him from.'),
              PpCard('Skin contact and constant holding',
                  'One of the most evidence-backed things in newborn care. '
                  'Tradition was ahead of the textbooks here.'),
            ], heading: 'What tradition gets right', hue: 44),
            PpTable(
              heading: 'What to stop, and why',
              columns: ['The practice', 'Why not', 'Instead'],
              rows: [
                [
                  'Haldi, oil, ash, powder or cow dung on the cord',
                  'Causes umbilical infection and newborn tetanus, which kills',
                  'Keep it dry and uncovered',
                ],
                [
                  'Kajal or surma in the eyes',
                  'Eye infection, and many kajals carry lead',
                  'Nothing in his eyes at all',
                ],
                [
                  'Oil in the ears or nose',
                  'Can be inhaled into the lungs, and damages the ear canal',
                  'Wipe only what you can see outside',
                ],
                [
                  'Honey, gur, ghutti or janam ghutti in the mouth',
                  'Honey can cause infant botulism. Nothing else is needed',
                  'Only breastmilk or formula before 6 months',
                ],
                [
                  'Water, gripe water or jal before 6 months',
                  'Fills a tiny stomach, dilutes his salts, replaces milk',
                  'Breastmilk covers all his fluid needs',
                ],
                [
                  'Pressing the head or nose into shape',
                  'The skull moulds back on its own. Pressing does no good',
                  'Leave it. It settles in weeks',
                ],
                [
                  'Nada or tight belly binding on the baby',
                  'Restricts breathing, does nothing for a hernia or navel',
                  'Loose clothes, and show any bulge to a doctor',
                ],
                [
                  'Massaging or pressing the soft spot on his head',
                  'It protects the brain and needs no treatment',
                  'Wash it gently, do not press it',
                ],
                [
                  'Pulling and straightening the legs during malish',
                  'Forcing hips straight can affect how the joint forms',
                  'Gentle strokes, legs free to bend',
                ],
                [
                  'Shaving or scrubbing to change his colour',
                  'Skin colour is not a condition. Scrubs damage the skin',
                  'Nothing. He is fine',
                ],
              ],
            ),
            PpCallout(
              'The reason to be firm about this short list is not that the old '
              'ways are wrong. It is that these particular ones put things '
              'inside a body that has no defences yet. Everything else in '
              'jaapa can stay exactly as it is.',
              kind: PpCalloutKind.myth,
            ),
            PpWhenLine('Applies from birth. The eye, ear, cord and mouth rules '
                'matter most in the first 6 weeks.'),
            PpIndiaNote('You will be doing this negotiation with someone who '
                'raised children successfully and loves this baby. What works '
                'better than evidence is attribution and a substitute. "The '
                'paediatrician said no kajal, she said to keep it for after his '
                'first birthday" gives everyone a way to agree.'),
            PpCallout(
              'If something has already been applied to his eyes, ears, cord or '
              'mouth, tell your doctor plainly and without embarrassment. '
              'Nobody will scold you, and knowing changes what they look for.',
              kind: PpCalloutKind.doctor,
              title: 'If something has already been used',
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  4. Feeding and sleep in the early days
    // -------------------------------------------------------------------------
    //  The newborn slice ONLY. Everything past the first weeks links out to the
    //  Feeding and Sleep sections rather than being written twice.
    // =========================================================================
    PpArea(
      id: 'feeding_sleep_early',
      mark: IntentMark.feedMark,
      title: 'Feeding & Sleep in the Early Days',
      blurb: 'The newborn slice: latch, how often, is he getting enough, and '
          'why he wakes.',
      hue: 190,
      pages: [
        PpPage(
          id: 'f40_latch',
          title: 'Getting the latch right',
          subtitle: 'The one thing that makes feeding stop hurting.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('A deep latch is the difference between feeding that hurts '
                'and feeding that works. It is a skill, not an instinct, and '
                'almost everybody needs a few days and a pair of experienced '
                'hands to get it.'),
            PpVideoSlot(
              title: 'A deep latch, shown properly',
              subtitle: 'Positioning, the mouth wide, and how to tell it is '
                  'right. Filmed with a real mother and baby.',
              minutes: '7 MIN',
              // ⚠️ ITS OWN ID. This shared 'feeding/latch_demo' with the Feeding
              // section, whose video is a lactation counsellor teaching the
              // latch. This one is a newborn-week explainer with a different
              // title and a different job. Two different videos under one id
              // means one file lands and the other never does.
              slotId: 'first40/latch_demo',
            ),
            PpSteps([
              PpStep('Get yourself comfortable first',
                  'Back supported, feet down, a pillow under your arm or on '
                  'your lap. If you are twisted, he will slip.'),
              PpStep('Bring him chest to chest, nose to nipple',
                  'His whole body facing you, ear, shoulder and hip in a line. '
                  'Not just his head turned.'),
              PpStep('Wait for the wide open mouth',
                  'Brush your nipple on his upper lip. He will gape like a '
                  'yawn. That is the moment.'),
              PpStep('Bring him on quickly, chin first',
                  'Aim your nipple towards the roof of his mouth. He comes to '
                  'you, you do not lean into him.'),
              PpStep('Check the shape',
                  'More of the darker skin visible above his lip than below. '
                  'Chin pressed in, nose free, lips flanged out.'),
              PpStep('Listen and watch',
                  'Deep slow jaw movements down to the ear, pauses, and '
                  'swallowing. Not fast fluttery sucking.'),
              PpStep('If it hurts, take him off and start again',
                  'Slide a clean finger into the corner of his mouth to break '
                  'the seal. Never pull him off a latch.'),
            ], heading: 'The latch, step by step'),
            PpCards([
              PpCard('It is working if',
                  'It is comfortable after the first few seconds, his cheeks '
                  'are full and rounded, you can hear swallowing, and your '
                  'nipple comes out the same round shape it went in.'),
              PpCard('It needs fixing if',
                  'It pinches or burns throughout, you hear clicking, he slips '
                  'off repeatedly, your nipple comes out flattened or creased, '
                  'or you are cracked and bleeding.'),
              PpCard('Try a different hold',
                  'Cross-cradle for control, rugby hold after a caesarean, or '
                  'lying on your side at night. The best hold is the one that '
                  'works for you.'),
              PpCard('Nipple shields and pumps have a place',
                  'They are tools, not failure. Ask someone to show you rather '
                  'than working it out from a box.'),
            ], heading: 'Reading the latch', hue: 190),
            PpWhenLine('Work on this from the first hour after birth and '
                'through the first two weeks. Most pain settles once the latch '
                'is deep.'),
            PpCallout(
              'Get help within a day, not a week, if your nipples are cracked '
              'or bleeding, if feeding is agony throughout, if you have a hard '
              'red painful patch on the breast with a fever, if he has lost '
              'more than 10 percent of his birth weight, or if he cannot stay '
              'latched at all.',
              kind: PpCalloutKind.doctor,
              title: 'When to get help fast',
            ),
            PpIndiaNote('Ask the hospital for a lactation consultant before you '
                'are discharged, and again on day 3 when your milk comes in '
                'properly. Most hospitals have one and most mothers are never '
                'offered her.'),
            PpConsult(
              title: 'Talk to a Newborn Expert',
              whoFor: 'For a latch that still hurts, cracked nipples, worry '
                  'about supply, or a baby who will not stay on. A lactation '
                  'expert and a newborn nurse, on video, usually the same day.',
              surfaceId: 'pp_experts',
              role: 'lactation',
            ),
          ],
        ),
        PpPage(
          id: 'f40_how_often',
          title: 'How often should he feed?',
          subtitle: 'On demand, and what that really means at 3am.',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('A newborn stomach is tiny and breastmilk digests fast, so '
                'he feeds far more often than seems reasonable. Feeding on '
                'demand simply means feeding him when he asks rather than when '
                'a clock says.'),
            PpChartCard(
              title: 'What normal looks like',
              // REQUIRED_REVIEW: 8 to 12 feeds per 24 hours; not letting a
              // newborn go more than 3 hours by day and 4 hours by night
              // without a feed in the first 2 weeks; feed length of 10 to 40
              // minutes.
              rows: [
                ('Feeds in 24 hours', '8 to 12, sometimes more'),
                ('Gap by day, first 2 weeks', 'No more than 3 hours'),
                ('Gap by night, first 2 weeks', 'No more than 4 hours'),
                ('Length of a feed', '10 to 40 minutes, both very normal'),
                ('Which side', 'Finish one properly, then offer the other'),
              ],
              note: 'Counting feeds is useful in the first fortnight. After '
                  'that, his nappies and his weight tell you far more than any '
                  'number of feeds.',
              hue: 190,
            ),
            PpCards([
              PpCard('Early hunger cues, catch these',
                  'Stirring, turning his head, opening his mouth, hands to '
                  'mouth, sucking noises. A feed offered now goes far better.'),
              PpCard('Crying is a late cue',
                  'By the time he screams he is too upset to latch. Calm him '
                  'against your skin first, then offer.'),
              PpCard('Wake a sleepy newborn to feed',
                  'In the first two weeks, do not let a long sleep run. Undress '
                  'him to his nappy, change him, hold him skin to skin, stroke '
                  'his feet.'),
              PpCard('Formula is not a failure',
                  'If you are topping up or fully formula feeding, feed on '
                  'demand the same way, follow the tin exactly, and never water '
                  'it down to stretch it.'),
            ], heading: 'Reading him', hue: 190),
            PpWhenLine('This pattern holds through the first 6 weeks. Feeds '
                'space out on their own after that.'),
            PpCallout(
              'A very sleepy newborn who has to be woken for every feed, or who '
              'will not wake at all, needs a doctor the same day. So does one '
              'who suddenly refuses two feeds in a row. Sleepiness in a newborn '
              'is a symptom, not a personality.',
              kind: PpCalloutKind.doctor,
              title: 'A baby too sleepy to feed',
            ),
            PpIndiaNote('You will be told that feeding this often means your '
                'milk is thin or insufficient, and that a bottle at night will '
                'let everyone sleep. Frequency is how supply is built, and the '
                'first weeks are when it is set. If you want to keep '
                'breastfeeding, this is the fortnight to protect.'),
          ],
        ),
        PpPage(
          id: 'f40_getting_enough',
          title: 'Is he getting enough?',
          subtitle: 'The two numbers that answer it.',
          format: 'ARTICLE',
          blocks: [
            PpIntro('This is the question that keeps almost every new mother '
                'awake, and the honest answer is reassuring: you do not need to '
                'measure milk to know. You need his nappies and his weight.'),
            PpArticle([
              'You cannot see how much comes out of a breast, so the only '
              'reliable evidence is what goes in and what comes out the other '
              'end. A baby who wets enough nappies and gains weight is getting '
              'enough, whatever the evening fussing suggests.',
              'Almost nothing else is evidence. Not how soft your breasts feel, '
              'not how long he feeds, not how much you can pump, not whether he '
              'cries after a feed, and certainly not what someone else\'s baby '
              'does.',
            ]),
            PpChartCard(
              title: 'The signs he is getting enough',
              // REQUIRED_REVIEW: 6 or more wet nappies a day from day 5; 3 or
              // more stools a day after day 4; regains birth weight by day 10
              // to 14; gains 150 to 200 g a week for the first 3 months.
              rows: [
                ('Wet nappies, day 5 onward', '6 or more a day, pale urine'),
                ('Stools, after day 4', '3 or more a day, yellow'),
                ('Back to birth weight', 'By day 10 to 14'),
                ('Weight gain after that', '150 to 200 g a week'),
                ('At the breast', 'Deep swallows, calm at the end'),
                ('In himself', 'Alert in his awake spells, good tone'),
              ],
              note: 'If these are in place, he is fine. You are allowed to stop '
                  'worrying on this specific question.',
              hue: 190,
            ),
            PpCards([
              PpCard('Not evidence: soft breasts',
                  'Breasts settle down after the first few weeks. Supply has '
                  'not dropped, it has become efficient.'),
              PpCard('Not evidence: what you can pump',
                  'A pump is much worse at removing milk than a baby is.'),
              PpCard('Not evidence: a short feed',
                  'Some babies are fast and effective. Time is not intake.'),
              PpCard('Not evidence: crying after a feed',
                  'Wind, tiredness, overstimulation and simply wanting to be '
                  'held all look identical to hunger.'),
            ], heading: 'What people will tell you to measure', hue: 190),
            PpWhenLine('Check nappies daily in the first fortnight, and weight '
                'at each visit. After 6 weeks, weight alone is enough.'),
            PpLink('The quick daily check',
                surfaceId: 'pp_baby_ok_check',
                blurb: 'Wet nappies, weight, jaundice and feeds. Four things, '
                    'thirty seconds, nothing to log.'),
            PpLink('His weight and growth',
                surfaceId: 'pp_growth',
                blurb: 'Plot it and see the curve rather than a single '
                    'reading.'),
            PpCallout(
              'See a doctor or a lactation expert if he has fewer than 6 wet '
              'nappies a day after day 5, has lost more than 10 percent of his '
              'birth weight, is not back to birth weight by two weeks, is not '
              'gaining after that, has a dry mouth or a sunken soft spot, or is '
              'unusually sleepy and limp.',
              kind: PpCalloutKind.doctor,
              title: 'When it is a real supply problem',
            ),
            PpConsult(
              title: 'Talk to a Newborn Expert',
              whoFor: 'For weight worry, slow gain, or a baby who feeds forever '
                  'and never seems full. If you have been logging feeds, the '
                  'expert can see that history before the call.',
              surfaceId: 'pp_experts',
              role: 'lactation',
            ),
          ],
        ),
        PpPage(
          id: 'f40_burping',
          title: 'Burping him',
          subtitle: 'Useful, quick, and not the emergency it is made into.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Babies swallow air while feeding and some of it comes back '
                'up. Burping helps, and a baby who does not burp is usually '
                'just a baby with no air to bring up.'),
            PpSteps([
              PpStep('Hold him upright against your chest',
                  'His chin over your shoulder, one hand supporting his bottom, '
                  'a cloth under his mouth.'),
              PpStep('Pat, or better, rub upwards',
                  'Firm flat strokes up the back. Gentle patting works too. No '
                  'thumping.'),
              PpStep('Try sitting him on your lap instead',
                  'Leaning slightly forward, your hand supporting his chest and '
                  'chin, and rub his back.'),
              PpStep('Give it two or three minutes, then stop',
                  'If nothing comes, there is nothing there. Put him down.'),
              PpStep('Burp him at the swap and at the end',
                  'And in the middle if he is squirming and pulling off.'),
              PpStep('Hold him upright for ten minutes after a feed',
                  'This helps more with reflux than any amount of patting.'),
            ], heading: 'How to burp him'),
            PpWhenLine('Useful for the first 4 to 6 months, and less needed as '
                'he gets better at feeding.'),
            PpCallout('A little milk coming up with the burp is normal. Do not '
                'jiggle him hard, bounce him, or hold him upside down. None of '
                'that brings up wind and all of it is unsafe for a newborn '
                'neck.'),
            PpCallout(
              'Speak to a doctor if he vomits forcefully after most feeds, if '
              'the vomit is green or yellow-green or has blood in it, if he '
              'arches and screams with every feed, or if he is not gaining '
              'weight. Ordinary posseting looks like a spill, not a fountain.',
              kind: PpCalloutKind.doctor,
              title: 'Vomiting that is not just wind',
            ),
            PpIndiaNote('Hing paste on the tummy, gripe water and janam ghutti '
                'are all offered for wind. Hing on the skin can burn a '
                'newborn, and nothing needs to go in his mouth. Holding him '
                'upright and a gentle clockwise tummy stroke do the same job '
                'safely.'),
          ],
        ),
        PpPage(
          id: 'f40_newborn_sleep',
          title: 'Newborn sleep, honestly',
          subtitle: 'Why he wakes, and why there is no routine yet.',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Newborns sleep a great deal and almost never for long. '
                'That combination is not a problem to be solved, and it is the '
                'single most misunderstood thing about the first two months.'),
            PpChartCard(
              title: 'Newborn sleep, 0 to 6 weeks',
              // REQUIRED_REVIEW: total sleep of 14 to 17 hours per 24 hours,
              // sleep cycle length of about 45 to 50 minutes, longest stretch
              // of 2 to 4 hours.
              rows: [
                ('Total in 24 hours', '14 to 17 hours'),
                ('One sleep cycle', 'About 45 to 50 minutes'),
                ('Longest stretch', '2 to 4 hours'),
                ('Naps a day', '4 to 6, of very uneven length'),
                ('Awake at a stretch', '30 to 60 minutes'),
              ],
              note: 'Waking every 2 to 3 hours to feed is expected and is how '
                  'his weight and your supply are protected.',
              hue: 190,
            ),
            PpArticle([
              'He wakes because his sleep cycles are short, because he is '
              'hungry, and because being close to you is a survival instinct '
              'rather than a preference. None of it is a habit you created, and '
              'none of it can be trained at this age.',
              'So there is nothing to fix in these weeks. What helps is bright '
              'days and dull nights, sleeping when he sleeps, and sharing the '
              'nights with someone if you possibly can.',
            ]),
            PpCallout('No sleep training, no crying it out, and no schedules for '
                'a newborn. Responding to him at this age is the right answer '
                'every time, and it is also what builds the sleep that comes '
                'later.'),
            PpWhenLine('Applies to the first 6 to 8 weeks. Longer stretches '
                'usually appear between 6 and 12 weeks.'),
            PpLink('Sleep, all the way through',
                surfaceId: 'pp_sleep',
                blurb: 'Safe sleep, gentle settling, naps and every age after '
                    'this one.'),
            PpCallout(
              'Talk to a doctor if he sleeps through feeds and is hard to wake, '
              'if he is sleeping much more than usual and feeding less, if he '
              'has pauses in breathing, or if he has stopped his usual pattern '
              'suddenly with no clear reason.',
              kind: PpCalloutKind.doctor,
              title: 'Sleep that needs checking',
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  5. Malish, Jhula & Soothing — the how-tos
    // =========================================================================
    PpArea(
      id: 'malish_jhula',
      mark: IntentMark.blocksMark,
      title: 'Malish, Jhula & Soothing',
      blurb: 'The things you do with your hands. Step by step, properly.',
      hue: 268,
      pages: [
        PpPage(
          id: 'f40_malish',
          title: 'Malish, step by step',
          subtitle: 'Which oil, how warm, which order, how long.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Malish is one of the best things our tradition hands down. '
                'Done gently it helps him gain weight, sleep better and settle '
                'faster, and it gives whoever does it a daily half hour of pure '
                'closeness with him.'),
            PpVideoSlot(
              title: 'Malish, the full sequence',
              subtitle: 'Legs, arms, chest, tummy and back, with the pressure '
                  'shown on a real baby.',
              minutes: '10 MIN',
              slotId: 'first40/malish_demo',
            ),
            PpSteps([
              PpStep('Pick your moment',
                  'He should be awake, calm and not hungry. Wait at least 30 to '
                  '45 minutes after a feed, and never massage a crying or '
                  'sleepy baby.'),
              PpStep('Warm the room and close the windows',
                  'Undressed for twenty minutes needs a warm draught-free room. '
                  'Lay him on a towel on the floor or a bed.'),
              PpStep('Warm the oil in your palms, not on the stove',
                  'A little in your hands, rubbed together. Test a drop on your '
                  'own inner wrist first.'),
              PpStep('Legs first, feet to thigh',
                  'Long gentle strokes upwards, one leg at a time. Then small '
                  'circles on the soles and each toe. Legs are where he is most '
                  'comfortable being touched.'),
              PpStep('Arms next, hands to shoulder',
                  'Same long strokes. Open his palm and circle it with your '
                  'thumb.'),
              PpStep('Chest, outwards from the middle',
                  'Flat hands, from the centre out to the sides, like smoothing '
                  'a page. Never press on the breastbone.'),
              PpStep('Tummy, clockwise only',
                  'Soft flat circles around the navel, clockwise, following his '
                  'gut. Avoid the cord area entirely until it has healed.'),
              PpStep('Back, neck to bottom',
                  'Turn him onto his tummy across your lap or the towel. Long '
                  'strokes down either side of the spine, never on the spine '
                  'itself.'),
              PpStep('Finish, then a warm bath if you like',
                  'Wipe off the excess, dress him warmly, and feed him. He will '
                  'be hungry and probably sleepy.'),
            ], heading: 'The sequence'),
            PpChartCard(
              title: 'The practical numbers',
              // REQUIRED_REVIEW: waiting 30 to 45 minutes after a feed, a
              // massage length of 10 to 15 minutes for a newborn, and starting
              // full-body malish only after the cord has separated and healed.
              rows: [
                ('How long', '10 to 15 minutes for a newborn'),
                ('How often', 'Once a day is plenty. Twice in cold weather'),
                ('Best time', 'Morning, or before an evening bath'),
                ('After a feed', 'Wait 30 to 45 minutes'),
                ('When to start', 'Once the cord has fallen off and healed'),
                ('Pressure', 'Firm enough to move skin, never to press bone'),
              ],
              note: 'Watch him rather than the clock. Stop when he stops '
                  'enjoying it.',
              hue: 268,
            ),
            PpCards([
              PpCard('Coconut oil',
                  'Light, cooling, well tolerated, easy to find. The safest '
                  'default, and best for hot weather.'),
              PpCard('Sesame or til oil',
                  'The traditional winter choice. Warming and nourishing. Use '
                  'cold-pressed and edible grade.'),
              PpCard('Mustard oil',
                  'Widely used in north and east India. Strong and can irritate '
                  'newborn skin, especially if warmed hot. Patch test, and '
                  'avoid it on very young or premature babies.'),
              PpCard('Almond oil',
                  'Gentle and light. Avoid if there is a family history of nut '
                  'allergy.'),
              PpCard('Skip these',
                  'Mineral oil and baby oils that are mostly mineral oil, '
                  'anything perfumed, and all essential oils. His skin absorbs '
                  'far more than yours.'),
            ], heading: 'Which oil', hue: 268),
            PpCallout(
              'Stop and speak to a doctor if the oil leaves his skin red, '
              'itchy or bumpy, or if he has eczema that flares after malish. '
              'And never let anyone put oil in his ears, nose, eyes or navel, '
              'stretch or pull his limbs to straighten them, press his soft '
              'spot, or massage him head-down.',
              kind: PpCalloutKind.doctor,
              title: 'When to stop',
            ),
            PpWhenLine('Start once the cord has healed, usually around week 2, '
                'and carry on for as long as he enjoys it.'),
            PpIndiaNote('If a maalishwali comes, watch the whole first session. '
                'The traditional style can be far more forceful than a newborn '
                'needs, and the leg-pulling and head-shaping parts are the ones '
                'to ask her to skip. A calm baby means it is being done right; '
                'a screaming one means too hard, whatever anyone says about him '
                'getting used to it.'),
            PpLink('Malish oils and what to look for',
                surfaceId: 'pp_products',
                blurb: 'Cold-pressed, edible grade, no fragrance. What actually '
                    'matters on the label.'),
          ],
        ),
        PpPage(
          id: 'f40_soothing',
          title: 'Soothing your baby',
          subtitle: 'The calming sequence, in the order that works.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Newborns calm down through their bodies, not through '
                'reasoning, and there is a rough order that works better than '
                'random trying. Recreate the womb: tight, sideways, noisy and '
                'moving.'),
            PpSteps([
              PpStep('Swaddle him snugly',
                  'Arms contained, hips free. Being loose and flailing keeps '
                  'him startled.'),
              PpStep('Hold him on his side or tummy, against you',
                  'Along your forearm or over your shoulder. This position is '
                  'for calming while you are holding him only, never for '
                  'sleeping.'),
              PpStep('Shush loudly, close to his ear',
                  'Louder than his crying, then softening as he settles. The '
                  'womb was noisier than your living room.'),
              PpStep('Sway or jiggle, small and fast',
                  'Tiny movements from your hips, supporting his head. Never '
                  'shaking, never jerking.'),
              PpStep('Offer a suck',
                  'The breast, a clean finger, or a dummy once feeding is well '
                  'established. Sucking is a nervous system switch.'),
              PpStep('If nothing works, go skin to skin',
                  'Strip him to his nappy against your bare chest with a shawl '
                  'over both of you. This is the strongest tool you have.'),
              PpStep('If you are running out of patience, put him down safely',
                  'On his back in his cot, and step out for five minutes. See '
                  '"When the crying will not stop".'),
            ], heading: 'The sequence, in order'),
            PpCards([
              PpCard('White noise and a fan',
                  'A steady hum, roughly as loud as a shower, at a distance. '
                  'Not right beside his ear.'),
              PpCard('A warm bath',
                  'Works well for the evening crying window, if he likes '
                  'water.'),
              PpCard('A walk outside',
                  'Air, movement and a change of light settles many babies '
                  'within minutes.'),
              PpCard('A wrap or a sling',
                  'Upright against your chest, hands free. Often the only thing '
                  'that works through cluster feeding hours.'),
              PpCard('One thing at a time',
                  'Bouncing plus singing plus patting plus a rattle is more '
                  'noise, not more comfort.'),
            ], heading: 'What else helps', hue: 268),
            PpWhenLine('Most useful from birth to about 4 months, when crying '
                'naturally eases.'),
            PpCallout('You cannot spoil a newborn by picking him up. There is '
                'no such thing at this age, and being held is how his nervous '
                'system learns to calm itself later.'),
            PpIndiaNote('Everybody in the house will have a technique and they '
                'will all take turns on the same crying baby. Being passed '
                'between six people is itself overstimulating. Let one person '
                'hold him for a full ten minutes before handing him on.'),
            PpCallout(
              'Crying that is shrill, weak, or completely inconsolable for '
              'hours, or crying with a fever, vomiting, a swollen tummy or '
              'refused feeds, is not a soothing problem. Call a doctor.',
              kind: PpCalloutKind.doctor,
              title: 'When soothing is not the answer',
            ),
          ],
        ),
        PpPage(
          id: 'f40_jhula',
          title: 'Carrying him, and the jhula',
          subtitle: 'Wraps, carriers and the traditional cloth jhula, done '
              'safely.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Carrying him against you is one of the most practical '
                'things you can do in these weeks. He settles, you get your '
                'hands back, and it makes cluster feeding evenings survivable. '
                'The only thing that matters is his airway.'),
            PpVideoSlot(
              title: 'Wrapping and carrying him safely',
              subtitle: 'A cloth wrap, a soft carrier, and the traditional '
                  'jhula, with the airway checks shown.',
              minutes: '9 MIN',
              slotId: 'first40/jhula_demo',
            ),
            PpSteps([
              PpStep('High and upright, close enough to kiss',
                  'His head should be at your chest level, not down at your '
                  'waist. If you cannot kiss the top of his head, he is too '
                  'low.'),
              PpStep('Chin off his chest, always',
                  'A curled chin closes a newborn airway silently. You should '
                  'always be able to fit two fingers under his chin.'),
              PpStep('Face visible and clear of fabric',
                  'Nothing over his face. No hood pulled across, no dupatta, no '
                  'shawl covering his nose.'),
              PpStep('Back supported in a gentle curve',
                  'The wrap firm enough that he cannot slump into a C shape. '
                  'Snug, not loose.'),
              PpStep('Knees higher than his bottom, legs in an M',
                  'Thighs supported, hips spread. Never dangling straight down '
                  'from the crotch, which is what narrow-based carriers do.'),
              PpStep('Check him every few minutes at first',
                  'Especially if he falls asleep, and especially in the first '
                  'weeks. A quiet baby in a carrier is not automatically a fine '
                  'one.'),
              PpStep('Learn it sitting on a bed',
                  'Practise the wrap over a soft surface until your hands know '
                  'it.'),
            ], heading: 'The safety checks, every time'),
            PpCallout(
              'The five things to check, every single time, are his airway, his '
              'position, his height on your chest, his back support and his '
              'hips. If you only remember one, remember this: chin off chest, '
              'face uncovered, close enough to kiss.',
              kind: PpCalloutKind.key,
            ),
            PpCards([
              PpCard('A long cloth wrap',
                  'Cheapest and most adjustable, and the closest thing to what '
                  'our mothers used. Takes practice.'),
              PpCard('A soft structured carrier',
                  'Quick to put on. Check it is rated for newborn weight and '
                  'has a wide base for his thighs.'),
              PpCard('A ring sling',
                  'Good for quick ups and downs and for feeding on the move. '
                  'One shoulder, so less comfortable for long stretches.'),
              PpCard('The traditional cloth jhula',
                  'Fine for supervised naps if he lies flat on a firm base with '
                  'nothing padded under him. Not for unattended sleep and not '
                  'in a deep hammock curl.'),
              PpCard('Skip narrow-based hanging carriers',
                  'The kind where his legs dangle straight down with no thigh '
                  'support. Bad for hips and bad for his back.'),
            ], heading: 'What to carry him in', hue: 268),
            // REQUIRED_REVIEW: the two-finger airway gap, the "close enough to
            // kiss" height rule, and whether we should name the TICKS acronym
            // explicitly for parents who have been taught it.
            PpWhenLine('From birth, with newborn-safe positioning, and on '
                'through the first year. Front carrying only until he can hold '
                'his own head steadily.'),
            PpIndiaNote('The traditional jhula and palna are genuinely good at '
                'settling a baby, and the risk is never the swinging, it is the '
                'shape and the padding. Firm flat base, nothing soft '
                'underneath, no pillow, and someone in the room. Never tie a '
                'sheet hammock between two points and leave him in it.'),
            PpCallout(
              'Take him out of the carrier immediately and get help if his lips '
              'or face look dusky, if his breathing sounds strained or '
              'grunting, if his chin is pressed to his chest and he does not '
              'lift it when you reposition him, or if he is limp and unusually '
              'quiet.',
              kind: PpCalloutKind.doctor,
              title: 'Signs to act on at once',
            ),
          ],
        ),
        PpPage(
          id: 'f40_skin_to_skin',
          title: 'Skin to skin, and why it is worth the trouble',
          subtitle: 'The most useful twenty minutes of your day.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Holding him undressed against your bare chest sounds like '
                'a nice idea and is actually one of the best-evidenced things '
                'in newborn care. It steadies his temperature, his breathing '
                'and his heart rate, and it helps your milk.'),
            PpSteps([
              PpStep('Warm the room first',
                  'He is going to be in just a nappy. Close the windows and '
                  'switch off the fan overhead.'),
              PpStep('Undress him to his nappy, and open your top',
                  'Bare chest to bare chest. A cap on his head if the room is '
                  'cool.'),
              PpStep('Lie back slightly, do not sit bolt upright',
                  'Semi-reclined, his whole front against you, his head turned '
                  'to one side.'),
              PpStep('Cover you both with a shawl or blanket',
                  'Over his back, never over his face. His head stays out and '
                  'visible.'),
              PpStep('Check his position',
                  'Chin up and off his chest, nose and mouth clear, breathing '
                  'quiet and easy.'),
              PpStep('Stay for twenty minutes or more',
                  'Short bursts help, longer is better. Let him doze, root '
                  'around and feed if he wants to.'),
              PpStep('Do not do it if you might fall asleep',
                  'If you are that tired, hand him to someone else who is '
                  'awake, or put him in his cot.'),
            ], heading: 'How to do it'),
            PpCards([
              PpCard('It steadies his body',
                  'Temperature, heart rate, breathing and blood sugar all '
                  'settle against your chest.'),
              PpCard('It helps feeding',
                  'Babies latch better after skin contact, and it lifts the '
                  'hormones that make milk.'),
              PpCard('It calms crying',
                  'Often the only thing that works during the evening hours.'),
              PpCard('Fathers count fully',
                  'Every benefit except milk applies to his father, his '
                  'grandmother, anyone who holds him. This is the easiest way '
                  'for a father to be genuinely useful in week one.'),
              PpCard('It matters most for small babies',
                  'For premature or low birth weight babies this is real '
                  'medical care, and hospitals prescribe hours of it a day.'),
            ], heading: 'What it actually does', hue: 268),
            PpWhenLine('From the first hour after birth, ideally daily through '
                'the first weeks, and useful for months afterwards.'),
            PpIndiaNote('It can feel odd to sit half undressed in a full house, '
                'and that is usually the only reason it does not happen. Ask '
                'for the bedroom and twenty minutes with the door shut. It is a '
                'small thing to ask for and it does more than most of what '
                'anyone else is doing that day.'),
            PpCallout(
              'If he was born early or small, ask the hospital about kangaroo '
              'mother care specifically. It is a structured version of this '
              'with real measured benefits, and they will show you how to do it '
              'for long stretches safely.',
              kind: PpCalloutKind.doctor,
              title: 'For a small or premature baby',
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  6. Is My Baby OK? — the light check, and when to escalate
    // -------------------------------------------------------------------------
    //  ⚠️ THE POINT OF THIS AREA IS WHAT IT DOES NOT DO. No ml logging, no
    //  feed timer as the default, no caregiver dashboard, no streaks. The spec
    //  is explicit that the India-fit answer to "is he getting enough" is four
    //  reassuring checks, and that the full trackers are an ESCALATION for the
    //  minority who genuinely need them. The full feed and growth trackers are
    //  LIVE already and are linked, never rebuilt.
    // =========================================================================
    PpArea(
      id: 'baby_ok',
      mark: IntentMark.compassMark,
      title: 'Is My Baby OK?',
      blurb: 'A thirty second check, and the trackers if you ever need more.',
      hue: 152,
      pages: [
        PpPage(
          id: 'f40_light_check',
          title: 'The quick daily check',
          subtitle: 'Four things. Nothing to log, nothing to keep up with.',
          format: 'CHART-CARD',
          blocks: [
            PpIntro('You do not need to record every feed to know he is fine. '
                'Four quick checks a day answer almost every newborn worry, and '
                'the rest of the day you can just hold him.'),
            PpChartCard(
              title: 'The four checks',
              // REQUIRED_REVIEW: all four thresholds. 6 or more wet nappies a
              // day from day 5; weight back to birth weight by day 14 and 150
              // to 200 g a week after; jaundice reaching palms and soles as the
              // escalation point; and not letting a newborn go beyond 3 hours
              // by day or 4 by night in the first two weeks.
              rows: [
                ('Wet nappies', '6 or more a day from day 5'),
                ('Weight', 'Back to birth weight by day 14, then rising'),
                ('Yellow', 'Fading, and not on palms or soles'),
                ('Feeds', '8 to 12 a day, and he wakes for them'),
              ],
              note: 'All four looking fine means he is fine, even on a day when '
                  'he has cried for hours.',
              hue: 152,
            ),
            PpCards([
              PpCard('Wet nappies, counted roughly',
                  'You are looking at a pattern, not a precise total. Six '
                  'reasonably wet nappies with pale urine is the mark.'),
              PpCard('Weight, once a week at most',
                  'Weighing daily tells you nothing but your own anxiety. The '
                  'trend over weeks is what matters.'),
              PpCard('Yellow, checked in daylight',
                  'Press his forehead or nose and look as the colour returns. '
                  'Face only is usually mild.'),
              PpCard('A sleepy feeder needs waking',
                  'In the first two weeks, do not let him go more than 3 hours '
                  'in the day or 4 at night without a feed.'),
            ], heading: 'How to do each one', hue: 152),
            PpLink('Open the quick check',
                surfaceId: 'pp_baby_ok_check',
                blurb: 'Tap through the four checks and see whether anything '
                    'needs a call.'),
            PpWhenLine('Once a day through the first fortnight is plenty. After '
                'that, only when something feels off.'),
            PpCallout('There is no score here, no streak, and nothing that '
                'notices if you skip a day. This is a reassurance tool, not a '
                'record you have to keep.'),
            PpCallout(
              'If any one of the four checks is off, that is the moment to '
              'call. Fewer wet nappies, no weight gain, deepening yellow, or a '
              'baby who will not wake to feed each deserve a doctor the same '
              'day rather than a wait and see.',
              kind: PpCalloutKind.doctor,
              title: 'When a check does not look right',
            ),
          ],
        ),
        PpPage(
          id: 'f40_escalate',
          title: 'When to start logging properly',
          subtitle: 'The full trackers, and the few reasons to open them.',
          format: 'CARDS',
          blocks: [
            PpIntro('Detailed feed and weight logging is genuinely useful for a '
                'small number of babies, and unnecessary work for everybody '
                'else. Here is where the line is.'),
            PpCards([
              PpCard('He is not gaining as expected',
                  'Not back to birth weight by two weeks, or a flat weight '
                  'after that. A feed log makes the pattern visible to a '
                  'doctor.'),
              PpCard('He was born early, small, or is a twin',
                  'These babies are often sleepy feeders and need feeds counted '
                  'rather than trusted.'),
              PpCard('Jaundice is being followed',
                  'Feeds and stools are part of how it clears, and your doctor '
                  'will ask.'),
              PpCard('Feeding is not working yet',
                  'Cracked nipples, a shallow latch, top-ups, or a baby who '
                  'feeds for an hour and wakes hungry.'),
              PpCard('A doctor has asked you to',
                  'Then log exactly what she asked for, and only that.'),
              PpCard('You simply want to',
                  'Some parents find it calming to see it written down. That is '
                  'a perfectly good reason, and you can stop any time.'),
            ], heading: 'Reasons to switch it on', hue: 152),
            PpLink('The full feed log',
                surfaceId: 'pp_feeding',
                blurb: 'Times, sides, top-ups and nappies, if you want the '
                    'detail.'),
            PpLink('Weight and growth',
                surfaceId: 'pp_growth',
                blurb: 'Plot his weight, length and head, and see the curve.'),
            PpLink('Sleep, if you are being asked about it',
                surfaceId: 'pp_sleep',
                blurb: 'Useful mostly when a doctor wants the pattern.'),
            PpWhenLine('Switch it on when one of the reasons above applies, and '
                'switch it off again when the worry has passed.'),
            PpCallout('Logging is off by default and stays off unless you turn '
                'it on. Nothing in this app will tell you off for a gap in a '
                'log, and no chart here is a report card.'),
            PpConsult(
              title: 'Talk to a Newborn Expert',
              whoFor: 'For slow weight gain, feeding that is not working, or a '
                  'sleepy baby you are having to wake for every feed. If you '
                  'have been keeping a feed log, share it before the call so the '
                  'expert starts with the facts instead of your memory of a '
                  'hard week.',
              surfaceId: 'pp_experts',
              role: 'lactation',
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  7. Maa Ki Dekhbhaal — the mother's immediate first weeks
    // -------------------------------------------------------------------------
    //  ⚠️ BOUNDARY, ENFORCED HERE. Immediate recovery essentials only. Ongoing
    //  and deeper recovery links to "You, Maa" (`pp_you_maa`). The mood page
    //  below is deliberately NOT a screening questionnaire and carries NO paid
    //  block: it names what she may be feeling, then routes her to a person.
    // =========================================================================
    PpArea(
      id: 'maa_ki_dekhbhaal',
      mark: IntentMark.lotusMark,
      title: 'Maa Ki Dekhbhaal: Healing After Birth',
      blurb: 'Your body in these first weeks, and what needs attention.',
      hue: 330,
      pages: [
        PpPage(
          id: 'f40_lochia',
          title: 'Your bleeding: what is normal',
          subtitle: 'How much, how long, and the amount that is too much.',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Bleeding after birth is heavier and longer than most women '
                'expect, and it happens after a caesarean too. Knowing the '
                'normal shape of it makes the one dangerous version easy to '
                'spot.'),
            PpVideoSlot(
              title: 'Your body in the first weeks',
              subtitle: 'Bleeding, stitches, the caesarean scar, and what rest '
                  'is actually for.',
              minutes: '9 MIN',
              slotId: 'first40/recovery_basics',
            ),
            PpChartCard(
              title: 'The usual course',
              // REQUIRED_REVIEW: the lochia timeline (bright red days 1 to 4,
              // pink or brown to about day 10, then pale for up to 6 weeks) and
              // the total 4 to 6 week duration.
              rows: [
                ('Days 1 to 4', 'Bright red and heavy, some clots'),
                ('Days 5 to 10', 'Pink or brown, lighter'),
                ('Day 10 to 6 weeks', 'Pale, yellowish, then stops'),
                ('Clots', 'Small ones are normal, especially in the morning'),
                ('After a caesarean', 'The same, usually a little lighter'),
                ('A gush on standing', 'Normal. Pooling while you were lying '
                    'down'),
              ],
              note: 'Bleeding that gets heavier or turns bright red again after '
                  'it had settled usually means you are doing too much. Lie '
                  'down.',
              hue: 330,
            ),
            PpCards([
              PpCard('Use pads, not tampons or a cup',
                  'Nothing inside for at least six weeks. It is an infection '
                  'risk while the wound inside is healing.'),
              PpCard('Change every four to six hours',
                  'More often at first. It is also how you keep track of how '
                  'much you are losing.'),
              PpCard('Wash front to back with plain water',
                  'A mug of warm water while you pass urine takes the sting '
                  'away. Pat dry rather than rubbing.'),
              PpCard('Expect a smell like a period',
                  'Faint and metallic is fine. Strongly foul is not.'),
              PpCard('Rest is the actual treatment',
                  'Every extra hour on your feet in week one shows up as more '
                  'bleeding that evening.'),
            ], heading: 'Looking after yourself', hue: 330),
            PpCallout(
              'Go to hospital now if you are soaking a full pad in an hour or '
              'less, or two pads in two hours; if you are passing clots bigger '
              'than a lemon or several large clots; if you feel faint, '
              'breathless, or your heart is racing; if the bleeding suddenly '
              'becomes bright red and heavy again; or if there is a foul '
              'smelling discharge with a fever. Postpartum haemorrhage is an '
              'emergency and it is treatable when you get there in time.',
              kind: PpCalloutKind.doctor,
              title: 'Bleeding that is an emergency',
            ),
            // REQUIRED_REVIEW: the haemorrhage thresholds above. One full pad
            // soaked in an hour or less, two pads in two hours, and clots
            // larger than a lemon. Obstetrician to confirm the wording and the
            // clot size comparison we use.
            PpWhenLine('Bleeding normally lasts 4 to 6 weeks and reduces the '
                'whole way through. Anything that increases needs a call.'),
            PpIndiaNote('Cloth is still commonly used instead of pads. If you '
                'are using cloth, it must be clean, dried in full sunlight and '
                'changed as often as a pad would be, and it makes judging the '
                'amount much harder. In the first week, pads are worth the '
                'money for that reason alone.'),
          ],
        ),
        PpPage(
          id: 'f40_after_normal_delivery',
          title: 'After a normal delivery',
          subtitle: 'Stitches, soreness, and the first trip to the toilet.',
          format: 'ARTICLE',
          blocks: [
            PpIntro('If you tore or were cut, the stitches will be sore for '
                'about two weeks and then improve fast. Almost everything that '
                'helps is simple, and the first few days are the worst of it.'),
            PpArticle([
              'Sitting down, standing up, coughing and passing urine will all '
              'sting at first. Stitches dissolve on their own and nobody needs '
              'to remove them. The soreness peaks around day two or three and '
              'is usually much better within a fortnight.',
              'The first bowel movement is the thing most women dread, and it is '
              'genuinely fine. The stitches will not tear. Water, fibre and a '
              'stool softener if your doctor agrees make it a non-event.',
            ]),
            PpSteps([
              PpStep('Pour warm water while you pass urine',
                  'A mug or a bottle. It dilutes the urine and takes most of '
                  'the sting away.'),
              PpStep('Pat dry, front to back, every time',
                  'Clean and dry is what prevents infection. Do not rub.'),
              PpStep('Sit on something soft, or on your side',
                  'A folded towel or a cushion. Feeding lying down for the '
                  'first days saves you a lot of sitting.'),
              PpStep('Cold, then warm',
                  'A cold pack wrapped in cloth for ten minutes helps swelling '
                  'in the first two days. A warm sitz bath helps after that.'),
              PpStep('Take the painkillers you were given',
                  'Paracetamol and the ones prescribed are safe while '
                  'breastfeeding. Pain you are gritting through is not '
                  'noble, it stops you resting and feeding.'),
              PpStep('Drink and eat for your bowels',
                  'Water all day, fruit, and something with fibre. Ask about a '
                  'stool softener if it has been three days.'),
              PpStep('Start gentle pelvic floor squeezes when it is comfortable',
                  'A few, several times a day. It genuinely speeds up healing '
                  'and helps the leaking.'),
            ], heading: 'What helps'),
            PpWhenLine('Worst for 3 to 5 days, much better by two weeks, fully '
                'healed by about six.'),
            PpCallout(
              'See your doctor if the pain is getting worse rather than better '
              'after day three or four, if the stitch line is hot, hard, '
              'swollen or oozing, if there is a foul smelling discharge, if you '
              'have a fever, if you cannot pass urine or cannot control it, or '
              'if you feel a bulge or heaviness at the opening.',
              kind: PpCalloutKind.doctor,
              title: 'Stitches that need checking',
            ),
            PpIndiaNote('Squatting toilets are hard on fresh stitches. Use a '
                'western toilet if there is one in the house for the first two '
                'weeks, or a stool to raise your feet. Ask for it plainly, it '
                'is not fussiness.'),
            PpLink('Pelvic floor, and the longer recovery',
                surfaceId: 'pp_you_maa',
                blurb: 'Leaking, heaviness, core strength and what comes after '
                    'these weeks.'),
          ],
        ),
        PpPage(
          id: 'f40_after_csection',
          title: 'After a C-section',
          subtitle: 'Your first weeks with a fresh scar.',
          format: 'ARTICLE',
          blocks: [
            PpIntro('A caesarean is major abdominal surgery, and you have been '
                'sent home to look after a newborn while recovering from it. '
                'Almost every ache in these weeks is normal, and the limits '
                'exist for a reason.'),
            PpArticle([
              'The wound closes in a week or two but the layers underneath take '
              'months. Numbness, itching, tugging, a shelf above the scar and '
              'sharp twinges when you twist are all ordinary and often carry on '
              'for months.',
              'Moving is encouraged, lifting is not. Short slow walks around the '
              'house from day one reduce your risk of clots and help your '
              'bowels. Carrying anything heavier than your baby does not.',
            ]),
            PpSteps([
              PpStep('Support your tummy when you cough, laugh or sneeze',
                  'A hand or a folded towel pressed over the scar. It hurts far '
                  'less.'),
              PpStep('Roll to your side to get up',
                  'Bend your knees, roll, push up with your arms. Never sit '
                  'straight up from flat.'),
              PpStep('Walk a little, often',
                  'Short slow walks from the first day, increasing gradually. '
                  'Stop if it pulls.'),
              PpStep('Keep the scar clean and dry',
                  'A daily shower after your doctor allows it, pat dry, and '
                  'leave it open to the air. No oil, no haldi, no powder on the '
                  'wound.'),
              PpStep('Feed lying down or with a rugby hold',
                  'A pillow across your lap keeps his weight off the scar.'),
              PpStep('Lift nothing heavier than your baby',
                  'For at least six weeks. Not the toddler, not a bucket, not '
                  'a suitcase.'),
              PpStep('Take the pain relief on time',
                  'Not only when it becomes unbearable. The prescribed ones are '
                  'compatible with breastfeeding.'),
            ], heading: 'The first six weeks'),
            PpWhenLine('Wound closed in 1 to 2 weeks, no heavy lifting for 6 '
                'weeks, no driving until you can brake hard without flinching. '
                'Deeper healing continues for months.'),
            PpCallout(
              'Go in today if the scar is red, hot, hard or swollen, if it is '
              'oozing or opening, if you have a fever, if the pain is suddenly '
              'much worse, if you are breathless or your chest hurts, or if one '
              'calf becomes painful, swollen, hot or red. The last two can mean '
              'a clot and are an emergency.',
              kind: PpCalloutKind.doctor,
              title: 'Caesarean signs that need a doctor now',
            ),
            // REQUIRED_REVIEW: the six-week no-heavy-lifting limit, and the
            // clot warning signs (calf pain, breathlessness, chest pain) as
            // presented here.
            PpIndiaNote('Two things get pushed on caesarean mothers in Indian '
                'homes: a tight belly binder and an early full round of house '
                'visits. A binder can feel supportive for a few hours a day if '
                'your doctor agrees, but it does not flatten your stomach and it '
                'must never be tight. And you are allowed to say no to the '
                'stairs, the kitchen and the crowd for six weeks.'),
            PpLink('Rebuilding your core, later',
                surfaceId: 'pp_you_maa',
                blurb: 'Scar massage, core work and movement, once you are '
                    'cleared.'),
          ],
        ),
        PpPage(
          id: 'f40_rest_and_food',
          title: 'Rest, water and jaapa food',
          subtitle: 'What actually helps you heal, and what is just tradition.',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Jaapa food is one of the parts our families get most '
                'right. Warm, easy, energy-dense meals cooked by someone else '
                'are exactly what a woman feeding every two hours needs.'),
            PpArticle([
              'Breastfeeding costs you roughly a small extra meal a day in '
              'energy, and it makes you thirsty in a way nothing else does. '
              'Eating enough matters more than eating perfectly, and skipping '
              'meals to lose weight in these weeks is the one genuinely bad '
              'idea.',
              'Nobody needs to eat only bland food, and nothing you eat causes '
              'colic in most babies. Have your usual food, warm and cooked. If '
              'you genuinely notice the same reaction twice to something '
              'specific, mention it rather than cutting out half your diet.',
            ]),
            PpCards([
              PpCard('Gond laddoo, panjiri, methi laddoo',
                  'Energy dense, easy to eat one-handed at 3am, and traditional '
                  'for good reason. One or two a day, not a plateful.'),
              PpCard('Ajwain, jeera and saunf water',
                  'Warm, comforting and they help wind and digestion. Harmless '
                  'and genuinely soothing.'),
              PpCard('Kadha and haldi doodh',
                  'Warm and comforting. Keep the kadha mild, and mention any '
                  'strong herbal mixture to your doctor if you are on '
                  'medication.'),
              PpCard('Protein at every meal',
                  'Dal, curd, paneer, eggs, chicken or fish. This is the part '
                  'most jaapa diets are light on and it matters most for '
                  'healing.'),
              PpCard('Iron and calcium, as prescribed',
                  'Keep taking them. Blood loss and breastfeeding both draw on '
                  'your stores, and low iron is why so many mothers feel '
                  'permanently flattened.'),
              PpCard('Water beside every feed',
                  'Thirst hits hardest during letdown. A bottle where you feed '
                  'is the simplest fix in this whole app.'),
            ], heading: 'What helps', hue: 330),
            PpCallout(
              'A few jaapa food beliefs are worth setting aside. You do not '
              'need to restrict water. Bland food is not required. Ghee alone '
              'does not heal stitches. There is no food that will make your '
              'milk thin, and no single food that will make more of it: '
              'frequent feeding does that. Alcohol and smoking are the real '
              'things to avoid, and check any medicine, even ayurvedic, before '
              'you take it while feeding.',
              kind: PpCalloutKind.myth,
              title: 'What you can let go of',
            ),
            PpSteps([
              PpStep('Sleep when he sleeps, at least once a day',
                  'One deliberate nap. Put the phone down and lie flat.'),
              PpStep('Give away one job today',
                  'The dishes, the door, the visitors, the older child. Name it '
                  'and hand it over.'),
              PpStep('Eat before you feed, not after',
                  'You will not get up again once he latches.'),
              PpStep('Keep a tray beside your feeding spot',
                  'Water, laddoo or fruit, and your phone charger. Restock it '
                  'each night.'),
              PpStep('Say no to one visitor this week',
                  'You do not need a reason, and you will not remember them '
                  'being disappointed.'),
            ], heading: 'Protecting your own rest'),
            PpWhenLine('Most important through the first 6 weeks, and worth '
                'keeping up for as long as you are feeding.'),
            PpIndiaNote('If you are being fed generously but nobody is letting '
                'you sleep because there is a stream of guests, the food is not '
                'the part that is failing. Rest is the harder half of jaapa to '
                'ask for, and it is the half that actually decides how the next '
                'month feels.'),
            PpLink('Food and recipes',
                surfaceId: 'pp_food',
                blurb: 'Warm, simple, one-handed meals and jaapa recipes.'),
          ],
        ),
        PpPage(
          id: 'f40_recovery_red_flags',
          title: 'When to call your own doctor',
          subtitle: 'The signs in you that are not just tiredness.',
          format: 'FLAGGED QUICK-REFERENCE',
          blocks: [
            PpIntro('Everyone is watching the baby, including you. These are '
                'the signs in your own body that need a doctor rather than more '
                'rest, and none of them are things to sit out politely.'),
            PpTable(
              heading: 'Call, or go in',
              columns: ['If you have this', 'What to do'],
              rows: [
                [
                  'Soaking a pad in an hour or less, or clots bigger than a '
                  'lemon',
                  'Go now.',
                ],
                [
                  'Fever, or shaking chills',
                  'Call today.',
                ],
                [
                  'Foul smelling discharge, or pain low in the belly that is '
                  'worsening',
                  'Call today.',
                ],
                [
                  'A hard, red, hot painful patch on the breast with a fever '
                  'and body ache',
                  'Call today. Keep feeding from that side meanwhile.',
                ],
                [
                  'Pain, swelling, heat or redness in one calf',
                  'Go now. This can be a clot.',
                ],
                [
                  'Breathlessness, chest pain, or a racing heart',
                  'Go now.',
                ],
                [
                  'A severe headache, blurred vision, flashing lights, or '
                  'swelling of the face and hands',
                  'Go now. Blood pressure can rise after delivery too.',
                ],
                [
                  'A fit, or fainting',
                  'Go now.',
                ],
                [
                  'A stitch line or scar that is hot, opening, or oozing',
                  'Call today.',
                ],
                [
                  'Cannot pass urine, or cannot control it at all',
                  'Call today.',
                ],
                [
                  'Thoughts of harming yourself or the baby',
                  'Tell someone today. This is urgent and it is treatable.',
                ],
              ],
            ),
            // REQUIRED_REVIEW: the maternal thresholds on this page. Fever at
            // 100.4 F / 38 C, the haemorrhage pad rate, the pre-eclampsia
            // warning signs and the window in which postpartum blood pressure
            // problems can still occur. Obstetrician to confirm.
            PpChartCard(
              title: 'The numbers for you',
              rows: [
                ('Fever', '100.4 F or 38 C and above'),
                ('Bleeding', 'A full pad soaked in an hour or less'),
                ('Blood pressure', 'Get it checked if you have a bad headache '
                    'or blurred vision'),
              ],
              note: 'Postpartum complications are treatable and they are '
                  'time-sensitive. Being seen and sent home is a good outcome, '
                  'not a wasted trip.',
              hue: 330,
            ),
            PpWhenLine('Most postpartum complications appear in the first two '
                'weeks, and some can appear up to six weeks after birth.'),
            PpCallout('You are a patient too, for at least six weeks. If '
                'something in your body feels wrong, you do not have to wait '
                'until the baby has been dealt with first.'),
            PpIndiaNote('There is real pressure to be uncomplaining in jaapa, '
                'and a new mother who says she is unwell is often told to rest '
                'and drink something warm. If a symptom on this list is '
                'present, say it to a doctor directly rather than to the room.'),
          ],
        ),
        PpPage(
          id: 'f40_not_yourself',
          title: 'If you do not feel like yourself',
          subtitle: 'What is common, what is more than that, and who to tell.',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('You have just had your body, your sleep and your whole day '
                'rearranged. Feeling weepy, flat, frightened or strangely '
                'nothing at all is extremely common in these weeks, and it is '
                'not a character flaw.'),
            PpArticle([
              'Most mothers get a few days of tearfulness and mood swings in the '
              'first week or two, often as the milk comes in. It comes in waves, '
              'it lifts, and it does not stop you from functioning.',
              'What is different is a low mood, a numbness or an anxiety that '
              'settles in and does not lift, that is there most of the day for '
              'more than a couple of weeks, or that makes it hard to look after '
              'yourself or him. That is postnatal depression or anxiety, it is '
              'genuinely common, and it responds well to help.',
              'There is nothing here to score and no test to take. You are not '
              'being assessed by an app. The only thing worth doing is telling '
              'one real person: your doctor, your husband, your mother, a '
              'friend who will keep asking.',
            ]),
            PpCards([
              PpCard('Worth mentioning to your doctor',
                  'Crying most days after the second week, not sleeping even '
                  'when he sleeps, no appetite, constant dread, feeling '
                  'detached from him, or feeling nothing at all.'),
              PpCard('Rage and irritability count too',
                  'Postnatal depression does not always look like sadness. '
                  'Snapping, fury and feeling permanently on edge are just as '
                  'common and just as treatable.'),
              PpCard('Frightening thoughts happen',
                  'Sudden unwanted images of something bad happening to him are '
                  'very common and horrifying to have. They are not a sign you '
                  'will act. Say them out loud to a doctor.'),
              PpCard('Treatment does not mean stopping feeding',
                  'There are options that are compatible with breastfeeding. '
                  'That is a conversation, not a barrier.'),
            ], heading: 'What to watch for in yourself', hue: 330),
            PpWhenLine('The early tearful days pass within two weeks. Anything '
                'still there after that, or getting heavier, is worth telling '
                'someone about.'),
            PpCallout(
              'Some things need help today, not at the six week check. Thoughts '
              'of harming yourself or the baby, feeling you cannot keep him '
              'safe, hearing or seeing things others do not, or feeling '
              'confused and unlike yourself in a way that frightens the people '
              'around you. Tell your doctor or go to a hospital today. This is '
              'treatable, and asking is the strong thing to do.',
              kind: PpCalloutKind.doctor,
              title: 'Get help today if',
            ),
            PpIndiaNote('You will hear that everyone goes through this and that '
                'it is only weakness or nazar. Both halves of that are wrong. '
                'If your family will not take it seriously, tell your own '
                'doctor at the next visit, or ask your husband to make the '
                'appointment for you. One appointment is usually all it takes to '
                'start.'),
            PpLink('You, Maa: your mind in the first year',
                surfaceId: 'pp_you_maa',
                blurb: 'Mood, identity, anger, therapy and what actually helps. '
                    'The deeper part of this lives there.'),
            PpLink('Find someone to talk to',
                surfaceId: 'pp_find_help',
                blurb: 'Doctors, counsellors and support near you.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  8. Puchho ParentVeda — the 2am question
    // -------------------------------------------------------------------------
    //  Reuses Ask Veda. Nothing is rebuilt here. The page exists because a
    //  frightened parent needs to be told what the answer machine will and will
    //  not do before she leans on it at 2am.
    // =========================================================================
    PpArea(
      id: 'puchho',
      mark: IntentMark.lampMark,
      title: 'Puchho ParentVeda',
      blurb: 'The 2am "is this normal" question, answered without waking '
          'anybody.',
      hue: 206,
      pages: [
        PpPage(
          id: 'f40_ask_veda',
          title: 'Ask anything, at any hour',
          subtitle: 'What it can answer, and what it will hand to a doctor.',
          format: 'CARDS',
          blocks: [
            PpIntro('At 3am, with a baby doing something you have never seen '
                'before, you need an answer in your own words rather than a '
                'search results page. Type the question as you would say it.'),
            PpCards([
              PpCard('"Is it normal that his poop is green?"',
                  'The ordinary reassurance questions are what this is best '
                  'at.'),
              PpCard('"He fed for an hour and is still crying"',
                  'Describe what is happening. You do not need the right '
                  'words.'),
              PpCard('"How long should the cord take to fall off?"',
                  'The small factual things nobody thought to tell you.'),
              PpCard('"Can I take this medicine while feeding?"',
                  'It will tell you what is known and when to check with your '
                  'doctor.'),
              PpCard('"What is a normal amount of bleeding on day 10?"',
                  'Your own body counts as a fair question here too.'),
            ], heading: 'The kind of thing to ask', hue: 206),
            PpLink('Open Puchho ParentVeda',
                surfaceId: 'pp_ask_veda',
                blurb: 'Ask in English or Hindi, any time.'),
            PpCallout('Answers come from our own reviewed content and trusted '
                'medical sources, never from what other parents have posted in '
                'the community. Where the honest answer is "this needs a '
                'doctor", that is what it says.'),
            PpCallout(
              'It will never diagnose him, never tell you to skip a hospital '
              'visit, and never contradict your own doctor. Anything that looks '
              'like a red flag gets routed straight to "When to Rush to the '
              'Doctor" and to a human.',
              kind: PpCalloutKind.doctor,
              title: 'What it will not do',
            ),
            PpWhenLine('Available at any hour, and most used between midnight '
                'and 4am, which is exactly what it is for.'),
            PpIndiaNote('Ask in the language you think in. Hindi questions get '
                'Hindi answers, and you can mix the two the way you would '
                'speaking to a friend.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  9. The Jaapa Course — the hero, surfaced honestly
    // -------------------------------------------------------------------------
    //  ⚠️ REUSES `pp_courses`. The page's job is to be honest enough that a
    //  mother who does not need it can tell. Everything clinical in the course
    //  is also free in this section, and the page says so out loud, because the
    //  alternative is selling to the parent whose problem the free page above
    //  already solved.
    // =========================================================================
    PpArea(
      id: 'jaapa_course',
      mark: IntentMark.improveMark,
      title: 'The Jaapa Course',
      blurb: 'The First 40 Days, taught properly, if you want it all in one '
          'place.',
      hue: 86,
      pages: [
        PpPage(
          id: 'f40_course',
          title: 'The First 40 Days course',
          subtitle: 'What is inside it, what it costs, and who does not need '
              'it.',
          format: 'CARDS',
          blocks: [
            PpIntro('A digital jaapa: the whole first forty days taught in '
                'order, by people who do this for a living. It exists because '
                'most families cannot arrange a knowledgeable jaapa maid, and '
                'the ones who can often get the folk practices along with the '
                'good parts.'),
            PpCards([
              PpCard('Newborn care, dos and don\'ts',
                  'Cord, bath, nappies, skin, sleep and safety, with the myths '
                  'named and settled.'),
              PpCard('Feeding, from the first latch',
                  'Latch, supply, cluster feeding, expressing, and mixed '
                  'feeding without guilt.'),
              PpCard('Malish, soothing and carrying',
                  'Filmed properly, so you can copy it rather than interpret a '
                  'diagram.'),
              PpCard('Your own recovery',
                  'Normal delivery and caesarean, bleeding, food, rest, mood, '
                  'and when to call.'),
              PpCard('What the brain actually needs',
                  'A module on early brain development that sticks to what is '
                  'supported: talking, holding, responding, feeding, sleep. It '
                  'is not a flashcard programme and it will not promise a '
                  'genius baby, because nothing can.'),
              PpCard('Handling the house',
                  'Visitors, advice, joint family negotiations and the scripts '
                  'that end an argument politely.'),
            ], heading: 'What is inside', hue: 86),
            PpChartCard(
              title: 'What it costs',
              rows: [
                ('The course', 'Rs 1,499'),
                ('Usual price', 'Rs 2,999'),
                ('A live jaapa maid, 40 days', 'Rs 20,000 to 35,000'),
                ('Access', 'Yours to keep, watch in any order'),
                ('Language', 'Hindi and English'),
              ],
              note: 'Priced against what it replaces, not against other apps.',
              hue: 86,
            ),
            PpCallout('Everything medical in the course is also free in this '
                'section, and always will be. The red flags, the how-tos, the '
                'trackers and the reading are never behind a payment. The '
                'course is the same material taught in order, on video, with '
                'the parts nobody writes down.'),
            PpLink('See the course',
                surfaceId: 'pp_courses',
                blurb: 'Watch the free first lesson before you decide.'),
            PpWhenLine('Most useful in the last weeks of pregnancy or the first '
                'fortnight after birth. It stays available afterwards.'),
            PpIndiaNote('If a jaapa maid is already coming, the course is still '
                'the thing that lets you tell which of her advice to follow. '
                'That is what most families use it for.'),
            PpCallout('Infant sleep, taught gently and with no sleep training, '
                'is the next course being built and it will live in the Sleep '
                'section rather than here.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  10. Jaapa Essentials — contextual commerce, never a wall
    // -------------------------------------------------------------------------
    //  ⚠️ NO PRODUCT SURFACE ANYWHERE NEAR THE RED FLAG PAGES OR THE RECOVERY
    //  RED FLAGS. This area is where buying decisions live, and the first page
    //  is deliberately the one that tells her what NOT to buy.
    //
    //  ⚠️ `PpProduct` HAS NO IMAGE FIELD YET, so nothing here promises a photo.
    //  These pages carry named comparisons and route to the live product and
    //  compare surfaces, which degrade to text cleanly. Image seeding is
    //  flagged in the report.
    // =========================================================================
    PpArea(
      id: 'jaapa_essentials',
      mark: IntentMark.nextStep,
      title: 'Jaapa Essentials',
      blurb: 'What is genuinely worth buying, and what you can skip.',
      hue: 300,
      pages: [
        PpPage(
          id: 'f40_what_you_need',
          title: 'What you actually need',
          subtitle: 'A short list, and a longer list of things to skip.',
          format: 'CARDS',
          blocks: [
            PpIntro('The newborn shopping lists doing the rounds are mostly '
                'written by people selling things. A newborn needs remarkably '
                'little, and you need more than the lists admit.'),
            PpCards([
              PpCard('Nappies, and plenty of them',
                  'Cloth langots, disposables, or both. Ten to twelve changes a '
                  'day in the first weeks.'),
              PpCard('Six to eight thin cotton clothes',
                  'Front-opening or wide-necked. Muslin swaddle cloths double '
                  'as everything.'),
              PpCard('One good malish oil',
                  'Cold-pressed, edible grade, unperfumed. One bottle is '
                  'enough.'),
              PpCard('Maternity pads, and a lot of them',
                  'More than you think. This is the item most first-time '
                  'mothers under-buy.'),
              PpCard('Two or three feeding bras and a feeding pillow',
                  'Comfort while feeding is not a luxury when you are doing it '
                  'ten times a day.'),
              PpCard('A thermometer, and a paediatrician\'s number saved',
                  'Cheap, and the two things you will want at 2am.'),
              PpCard('A safe flat sleep surface',
                  'A firm cot mattress or a firm section of your own bed. No '
                  'soft nest, no pillows.'),
            ], heading: 'Worth buying', hue: 300),
            PpCards([
              PpCard('Skip: baby pillows and head-shaping pillows',
                  'No pillow of any kind for a newborn. They are a suffocation '
                  'risk and his head shape sorts itself out.'),
              PpCard('Skip: cot bumpers and soft nests',
                  'Every one of them puts something soft near his face.'),
              PpCard('Skip: talcum powder',
                  'Breathed in, it irritates newborn lungs. Dry skin folds '
                  'properly instead.'),
              PpCard('Skip: gripe water, janam ghutti and colic drops',
                  'Not needed, and not for a baby under six months.'),
              PpCard('Skip: walkers and jumpers',
                  'Not for months, and paediatric bodies advise against '
                  'walkers entirely.'),
              PpCard('Skip: a sterilising cupboard full of bottles',
                  'Buy one or two if you might need them. You can add more in a '
                  'day.'),
              PpCard('Wait on: the pram, the cot mobile, the giant toy set',
                  'None of it is used in the first six weeks. Wait and see what '
                  'you actually reach for.'),
            ], heading: 'Skip, or wait', hue: 300),
            PpCallout(
              'The things being marketed hardest at new parents are often the '
              'ones paediatric bodies advise against: sleep positioners, cot '
              'bumpers, baby pillows, walkers. Expensive does not mean safe, '
              'and "recommended by mothers" is not a safety standard.',
              kind: PpCalloutKind.myth,
            ),
            PpWhenLine('Buy the short list before the birth. Everything else '
                'can be bought in a day when you find you need it.'),
            PpIndiaNote('Most of this arrives as gifts, and much of it will be '
                'the pillows and the powder. Accept graciously and store the '
                'unsafe things away. You do not have to use a gift to have '
                'appreciated it.'),
            PpLink('Newborn and jaapa essentials',
                surfaceId: 'pp_products',
                blurb: 'The short list, with what to look for on each label.'),
          ],
        ),
        PpPage(
          id: 'f40_which_oil',
          title: 'Which malish oil?',
          subtitle: 'The honest comparison, including the ones to avoid.',
          format: 'COMPARISON TABLE',
          blocks: [
            PpIntro('Any clean, plain, edible-grade oil does the job. The '
                'differences are about weather, skin and tradition rather than '
                'anything dramatic, so use the one your family already trusts '
                'unless his skin objects.'),
            PpTable(
              heading: 'Comparing the usual choices',
              columns: ['Oil', 'Good for', 'Watch out for'],
              rows: [
                [
                  'Coconut',
                  'Hot weather, sensitive skin, everyday use. The safest '
                  'default',
                  'Solidifies in winter. Warm it in your palms',
                ],
                [
                  'Sesame or til',
                  'Winter, the traditional warming choice, good absorption',
                  'Buy cold-pressed and edible grade. Strong smell',
                ],
                [
                  'Mustard',
                  'Cold north Indian winters, deeply traditional',
                  'Can irritate or burn newborn skin. Patch test, never warm '
                  'it hot, avoid on premature or very young babies',
                ],
                [
                  'Almond',
                  'Light, gentle, absorbs quickly',
                  'Avoid if there is nut allergy in the family. Expensive',
                ],
                [
                  'Olive',
                  'Widely available',
                  'Can worsen eczema-prone skin. Not the best first choice',
                ],
                [
                  'Mineral oil and most baby oils',
                  'Cheap and long-lasting',
                  'Sits on the skin rather than nourishing it. Often perfumed. '
                  'Skip',
                ],
                [
                  'Essential oils and medicated oils',
                  'Nothing, at this age',
                  'Too strong for a newborn. Never use them undiluted or on a '
                  'baby',
                ],
              ],
            ),
            PpSteps([
              PpStep('Check the label says cold-pressed and edible grade',
                  'If you would not cook with it, do not put it on him.'),
              PpStep('No fragrance, no added colour',
                  'Perfume is the most common cause of a reaction.'),
              PpStep('Patch test on his leg first',
                  'A small amount, then wait a few hours and look for redness.'),
              PpStep('Buy a small bottle and keep it cool',
                  'Oil goes rancid. A small bottle used up in a month beats a '
                  'litre that turns.'),
            ], heading: 'How to choose a bottle'),
            PpWhenLine('Start once the cord has healed. Reconsider the oil in '
                'summer, when a lighter one is usually kinder.'),
            PpCallout(
              'Stop and ask a doctor if his skin turns red, bumpy or itchy '
              'after malish, or if he has eczema that flares each time. A '
              'reaction is a reason to change oil, not to push through.',
              kind: PpCalloutKind.doctor,
              title: 'If his skin reacts',
            ),
            PpIndiaNote('Family loyalty to a particular oil runs deep, and it '
                'is usually harmless. Mustard is the one worth a conversation, '
                'especially for a very small or premature baby in the first '
                'weeks, and coconut is an easy substitute nobody objects to for '
                'long.'),
            PpLink('Compare malish oils side by side',
                surfaceId: 'pp_compare',
                blurb: 'Ingredients, pressing, fragrance and price in one '
                    'table.'),
          ],
        ),
        PpPage(
          id: 'f40_which_swaddle',
          title: 'Which swaddle, and how many?',
          subtitle: 'Cloth, muslin or a velcro bag.',
          format: 'COMPARISON TABLE',
          blocks: [
            PpIntro('A swaddle is a piece of cloth, and the expensive versions '
                'mostly buy you convenience at 3am. Any of these work, as long '
                'as the hips stay free and he sleeps on his back.'),
            PpTable(
              heading: 'The three real options',
              columns: ['Option', 'Good for', 'Watch out for'],
              rows: [
                [
                  'Plain cotton square, the traditional wrap',
                  'Cheapest, breathable, doubles as everything else',
                  'Takes practice. Can come loose, so no loose ends near his '
                  'face',
                ],
                [
                  'Muslin swaddle cloth',
                  'Light, breathable, ideal for Indian heat, gets softer with '
                  'washing',
                  'Thin, so add a layer in winter rather than doubling the '
                  'wrap',
                ],
                [
                  'Velcro or zip swaddle bag',
                  'Fast and consistent at 3am, hard for him to kick out of',
                  'Sized by weight, so you will outgrow it. Check the hip room '
                  'is genuinely wide',
                ],
                [
                  'Weighted swaddles and sleep positioners',
                  'Nothing',
                  'Not recommended for babies. Skip entirely',
                ],
              ],
            ),
            PpChartCard(
              title: 'How many, and what fabric',
              rows: [
                ('Swaddle cloths', '4 to 6, they are constantly in the wash'),
                ('Summer', 'Thin cotton or muslin only'),
                ('Winter', 'Cotton swaddle plus a layer under, not a thick '
                    'wrap'),
                ('Size', 'At least a metre square for a newborn'),
                ('Stop using when', 'He shows any sign of rolling'),
              ],
              note: 'Old cotton sarees and dhotis cut into squares make the '
                  'softest swaddles there are, and they cost nothing.',
              hue: 300,
            ),
            PpWhenLine('Useful from birth until he starts to roll, usually '
                'around 8 to 12 weeks.'),
            PpCallout('Whatever you use, the two rules do not change. Loose at '
                'the hips so his legs can bend and kick, and always on his '
                'back.'),
            PpIndiaNote('Grandmothers make excellent swaddles from old soft '
                'cotton, and they are better than most things sold in a box. '
                'The only thing to check is that nothing has a long tie or a '
                'loose end that can reach his face.'),
            PpLink('Compare swaddles',
                surfaceId: 'pp_compare',
                blurb: 'Fabric, sizing, hip room and price, side by side.'),
          ],
        ),
      ],
    ),
  ],
  tools: [
    PpSectionTool(
      label: 'Is my baby OK? The quick check',
      blurb: 'Four things in thirty seconds. Nothing to log, no streaks.',
      surfaceId: 'pp_baby_ok_check',
    ),
    PpSectionTool(
      label: 'His weight and growth',
      blurb: 'Plot his weight and see the curve, not a single reading.',
      surfaceId: 'pp_growth',
    ),
    PpSectionTool(
      label: 'The full feed log, if you want it',
      blurb: 'Off by default. Useful for slow gain or a sleepy feeder.',
      surfaceId: 'pp_feeding',
    ),
    PpSectionTool(
      label: 'Puchho ParentVeda',
      blurb: 'Ask the 2am question in your own words.',
      surfaceId: 'pp_ask_veda',
    ),
  ],
);
