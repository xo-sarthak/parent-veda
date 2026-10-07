// =============================================================================
//  Development — the section's content
// -----------------------------------------------------------------------------
//  Built from docs/../pp_specs/04-development.md, to the pattern in
//  docs/PP-SECTION-PATTERN.md. Five areas, four tools.
//
//  ⚠️ THE ONE GUARDRAIL THAT OVERRIDES EVERYTHING ELSE HERE: wide normal ranges,
//  reassurance first, always. A parent who opens this section is usually already
//  worried, and usually worried because of somebody else's baby. So:
//
//  * Every timing is a RANGE with a real spread, never a deadline. "Most babies
//    walk somewhere between 9 and 15 months" is the shape. "Should be walking by
//    12 months" is the shape we never write.
//  * There is no score, no percentage, no pass, no fail, and no progress bar.
//    The spec is blunt about why: a rigid milestone tracker does not retain, and
//    the anxiety it creates is off-brand. The reassurance content is the product.
//  * The words "behind", "delayed" and "late developer" do not describe a child
//    anywhere in this file. A skill is EMERGING, or it is one a family is
//    WAITING FOR. Where a real concern exists it gets a
//    `PpCallout(kind: doctor)` that names a next step, never a label.
//  * No diagnosis, ever. Red flags here are the honest, boring, published ones
//    (no social smile, no babble, no gestures, no words, and any LOSS of a skill
//    already had), and each one routes to a human.
//
//  ⚠️ SCOPE, HARD. This section is on-track (milestones) + activities +
//  speech/language ONLY. Behaviour (tantrums, discipline, biting, screen time)
//  and Early Learning (montessori-at-home, moral stories, activity boxes) are
//  their own sections and are deliberately absent. Physical growth (weight,
//  height, head) lives in Health, so this file links to it and does not restate
//  it.
//
//  ⚠️ WHAT IS REUSED RATHER THAN REBUILT. The engines already ship: 18 milestones
//  across 6 domains (`pp_milestones_data.dart` + MilestoneStore), 8 development
//  areas and 8 activities (`pp_development_data.dart` + DevStore), 39 grow
//  activities (`pp_grow_activities.dart`), 10 leaps and their screens
//  (`pp_leaps_data.dart`, leap_calendar, leap_definition), and the Development
//  subset of What Changed. This file is the CONTENT the spec says is missing
//  around them: the per-skill pages, the speech and language door, the
//  "normal range is wide" framing, the per-domain honest flags, and the
//  play-builds-the-brain piece. Everything else is a `PpLink` or a
//  `PpSectionTool` into the real screen.
//
//  ⚠️ INDIA IS NOT A NOTE HERE, IT IS THE PREMISE. Two things in particular:
//  the joint-family comparison ("your cousin's baby was walking at ten months")
//  is the actual emotional problem this section solves, and a bilingual or
//  trilingual home is the NORMAL Indian home, not a risk factor. Both get real
//  pages rather than a line at the bottom.
//
//  ⚠️ ENGLISH ONLY FOR NOW, plain `String`, per the standing instruction.
// =============================================================================

import 'package:flutter/material.dart' show Icons;
import 'pp_age_bands.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// =============================================================================
//  BANDS
// -----------------------------------------------------------------------------
//  Development's own set rather than `kPpChildBands`, and for the same reason
//  Sleep has its own: the first year is where this subject moves fastest. A
//  single "0 to 12 months" band would have to hold both "when will she roll
//  over" and "when will she walk", which are eight months and a different parent
//  apart. Splitting at 6 months costs one extra chip and makes every skill page
//  land in front of the parent who is actually asking.
//
//  Boundaries are inclusive-lower, exclusive-upper, per `PpBand`.
// =============================================================================

const PpBandSet kPpDevelopmentBands = PpBandSet([
  PpBand(
    id: 'dev_0_6',
    label: 'First 6 months',
    fromMonths: 0,
    toMonths: 6,
    blurb: 'Head control, rolling, reaching, and the first real smiles.',
  ),
  PpBand(
    id: 'dev_6_12',
    label: '6 to 12 months',
    fromMonths: 6,
    toMonths: 12,
    blurb: 'Sitting, moving, babbling, and starting to point at the world.',
  ),
  PpBand(
    id: 'dev_1_2',
    label: '1 to 2 years',
    fromMonths: 12,
    toMonths: 24,
    blurb: 'Walking, first words, and a lot of climbing.',
  ),
  PpBand(
    id: 'dev_2_3',
    label: '2 to 3 years',
    fromMonths: 24,
    toMonths: 36,
    blurb: 'Sentences, pretend play, and wanting to do it alone.',
  ),
  PpBand(
    id: 'dev_3_5',
    label: '3 to 5 years',
    fromMonths: 36,
    toMonths: 72,
    blurb: 'Stories, questions, friendships, and getting understood.',
  ),
]);

/// Every band. Written once so a page that genuinely belongs everywhere says so
/// by name instead of by an empty list that could equally mean "not tagged yet".
const List<String> _all = [
  'dev_0_6',
  'dev_6_12',
  'dev_1_2',
  'dev_2_3',
  'dev_3_5',
];

/// The first two years, where the "when will my baby..." questions live.
const List<String> _firstTwoYears = ['dev_0_6', 'dev_6_12', 'dev_1_2'];

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpDevelopmentSection = PpSection(
  id: 'parenting_development',
  title: 'Growing and learning',
  subtitle: 'On track, in your child’s own time',
  intro: 'What is coming up, what helps, and when something is worth a '
      'second look. No scores, no scoreboard.',
  bandSet: kPpDevelopmentBands,
  // ⚠️ THE AGE RULE. No chips; the door opens on his band. "Remove the five
  // age tabs and the age chooser. Open on the child's age and show only
  // that." The bands stay as the scoping, not as a picker.
  autoScope: true,
  areas: [
    // =========================================================================
    //  DOOR 1 — Is my child on track?
    // =========================================================================
    PpArea(
      id: 'on_track',
      mark: IntentMark.listMark,
      title: 'Is my child on track?',
      blurb: 'The honest answer, and why it’s a range and not a date.',
      hue: 160,
      pages: [
        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_range_is_wide',
          title: 'The normal range is much wider than you think',
          subtitle: 'Start here, especially if somebody has just worried you.',
          format: 'ARTICLE',
          bands: _all,
          blocks: [
            PpIntro('If you’ve come here because another baby is doing '
                'something yours isn’t doing yet, read this page first. It’s '
                'the best place to start in this section.'),
            PpArticle(
              [
                'Every milestone you’ve read as a single number is '
                    'a window. Walking is the famous one. Some babies '
                    'take their first steps at nine months, some at fifteen, '
                    'and a good number closer to eighteen. All of those '
                    'children are walking confidently by the time they start '
                    'nursery, and by then nobody can tell you who was first.',
                'The same is true of almost everything. Sitting, crawling, '
                    'first words, using a spoon. The window is usually four to '
                    'six months wide, and where your child falls inside it '
                    'says very little about what comes next. Early walkers '
                    'don’t read sooner. Children who talk later aren’t less '
                    'clever.',
                'Development isn’t a queue either. Children move in bursts and '
                    'then sit still for weeks, and they often trade one skill '
                    'for another while they work on it. A baby who is learning '
                    'to pull up on furniture very often goes quiet for a '
                    'fortnight, then starts babbling again as if nothing '
                    'happened. That trade is normal, and it isn’t a step back.',
                'What matters is direction, not date. Over a month or '
                    'two, is something new appearing? Is your child using you '
                    'to explore, looking to you, coming back to you? That '
                    'steady forward drift is the real signal, and it is the one '
                    'a paediatrician looks at too.',
              ],
            ),
            PpCallout('There’s no prize for early. A child who does '
                'everything at the far end of the window is a completely '
                'typical child, and in a year you won’t remember the order.'),
            PpWhenLine('True at every age in this section, from the first '
                'month to five years.'),
            PpIndiaNote('The comparison usually arrives from someone who loves '
                'you. An aunt, a neighbour, a WhatsApp group of cousins. They '
                'aren’t trying to frighten you, and they aren’t measuring '
                'anything either. One baby can’t show you a range.'),
            PpVideoSlot(
              title: 'Why every baby moves at a different pace',
              subtitle: 'A developmental paediatrician on ranges, bursts, and '
                  'why the order doesn’t matter.',
              minutes: '7 MIN',
              slotId: 'development/on_track_reassurance',
              hue: 160,
            ),
            PpLink('See what is emerging for your child right now',
                surfaceId: 'pp_milestones',
                blurb: 'The same milestones, shown as windows rather than '
                    'a checklist.'),
            PpLink('Weight, height and head growth',
                surfaceId: 'pp_growth',
                blurb: 'Physical growth is tracked in Health, not here.'),
            PpLink('A masterclass on the first three years',
                surfaceId: 'pp_courses',
                blurb: 'If you’d rather be talked through it by a '
                    'developmental paediatrician, at your own pace.'),
          ],
        ),

        // ---------------------------------------------------------------------
        /* ⚠️ REMOVED BY FEEDBACK, KEPT FOR REVERT.
           "Remove the six kinds of growing section." The six-domain split is still
           the app's internal model — the per-domain pages below all use it —
           but naming the taxonomy to a parent turned it into six things to
           be graded on, which is the exact anxiety this section exists to
           reduce.
           Commented rather than deleted, per comment-out-never-delete:
           the writing is good and the decision is editorial, so bringing
           it back is uncommenting rather than rewriting.

        PpPage(
          id: 'dev_six_domains',
          title: 'The six kinds of growing',
          subtitle: 'What each one means, in plain words',
          format: 'CARDS',
          bands: _all,
          blocks: [
            PpIntro('Development is usually split into six areas. They are not '
                'subjects to be graded. They are just six different things a '
                'child is quietly getting better at, at six different speeds.'),
            PpCards([
              PpCard('Gross motor, the big movements',
                  'Head control, rolling, sitting, crawling, walking, running, '
                      'climbing. The one families notice first and talk about '
                      'most, and the one with the widest windows of all.'),
              PpCard('Fine motor, the hands',
                  'Reaching, grasping, passing a toy from one hand to the '
                      'other, picking up a mustard seed with finger and thumb, '
                      'holding a crayon, using a spoon.'),
              PpCard('Language, understanding and talking',
                  'Cooing, babbling, following a simple instruction, first '
                      'words, then two words together. Understanding always '
                      'runs well ahead of speaking, in every child.'),
              PpCard('Social and emotional, being with people',
                  'Smiling back, seeking your face when unsure, going shy '
                      'around strangers, playing beside another child, then '
                      'playing with them.'),
              PpCard('Cognitive, working things out',
                  'Following a moving object, banging two things together to '
                      'hear what happens, looking for a toy that has gone '
                      'under a cloth, pretending a katori is a phone.'),
              PpCard('Self-care, doing it alone',
                  'Bringing a hand to the mouth, holding a glass, feeding '
                      'herself, pulling off a sock, washing hands, dressing.'),
            ], hue: 160),
            PpCallout('A child is almost never even across all six, and does '
                'not need to be. Racing ahead in one area while another waits '
                'is the usual pattern, not the exception.'),
            PpWhenLine('These six areas apply from birth right through the '
                'preschool years.'),
            PpLink('See all six for your child',
                surfaceId: 'pp_milestones',
                blurb: 'Everything emerging now, grouped by area.'),
            PpLink('Small things you can do for each area',
                surfaceId: 'pp_development',
                blurb: 'Matched to where your child is today.'),
          ],
        ),
        */

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_worth_checking',
          title: 'When something is worth checking',
          subtitle: 'The honest list, area by area',
          // format: 'FLAGGED CALLOUT, one per area', // the sentence was the chip
          format: 'FLAGGED CALLOUT',
          bands: _all,
          blocks: [
            // ⚠️ ADDED BY FEEDBACK: "also have a video when something is
            // genuinely worth checking section". This is the page a worried
            // parent opens, and a person saying it out loud calmly does more
            // than a list can — the tone of the delivery IS half the content
            // here, and tone is the one thing prose cannot carry.
            PpVideoSlot(
              title: 'When to wait, and when to ask',
              subtitle: 'A developmental paediatrician on the difference '
                  'between a slow start and a real flag, said plainly.',
              minutes: '7 MIN',
              slotId: 'development/worth_checking',
            ),
            PpIntro('Wide ranges are the truth, and so is this: a small number '
                'of specific things are worth a proper look, and looking early '
                'helps. None of the lines below is a diagnosis or a label. '
                'Each one is a reason to book an appointment, nothing more.'),
            PpArticle([
              'Read these as prompts, not verdicts. Most parents who bring one '
                  'of these to a paediatrician leave reassured after one '
                  'visit. The others are glad they came when they did, '
                  'because support works best early.',
              'One line matters more than all the others, at every age: if '
                  'your child could do something and has stopped doing it, '
                  'that’s always worth a call. Losing a skill is different '
                  'from being slow to gain one.',
            ]),
            PpCallout(
              'If your child has lost a skill that was clearly there, in any '
                  'area, at any age, ring your paediatrician rather than '
                  'waiting for the next visit. Words that have gone quiet, '
                  'waving that has stopped, eye contact that has faded. This '
                  'one doesn’t wait.',
              kind: PpCalloutKind.doctor,
              title: 'The one that never waits: losing a skill',
            ),
            // ⚠️ SIX ALERT BOXES BECAME ONE CARD BLOCK, AND THE COMPLAINT WAS
            // ABOUT THE COLOUR ONLY BECAUSE THE COLOUR IS WHAT YOU SEE FIRST.
            // Feedback: "improve the representation of this page, orange the
            // way it is feels off, should look much better."
            //
            // `PpCalloutKind.doctor` renders coral on purpose — see-a-doctor
            // must never be buried. But SEVEN of them stacked turned a page
            // about reassurance into a wall of warnings, and a signal used
            // seven times in a row stops being a signal. Coral is now reserved
            // for the one flag that genuinely never waits (losing a skill,
            // kept above as a callout); the six per-area notes read as a calm
            // card block instead.
            //
            // ⚠️ NOT A SINGLE WORD OF THE CONTENT CHANGED. The text in each
            // card is the text that was in each box, lifted verbatim. This is
            // a representation fix, and mixing a rewrite into it would make
            // the diff impossible to review for a clinician.
            PpCards([
              PpCard('Gross motor', 'Big movements. Worth raising with your paediatrician if your baby isn’t holding the head steady by about 4 months. The same goes for no sitting without support by about 9 months, no standing while holding on by about 12 months, or no walking by about 18 months. Mention it too if one side of the body looks a lot stronger, or your baby feels very stiff or very floppy to hold.'),
              PpCard('Fine motor', 'Hands. Worth raising with your paediatrician if your baby isn’t reaching for things by about 5 months. Mention it too if a toy isn’t passing from hand to hand by about 8 months. Or if small pieces of food still aren’t picked up with finger and thumb by about 12 months. A strong preference for one hand before 18 months is also worth a mention.'),
              PpCard('Language', 'Language. Worth raising with your paediatrician if your baby isn’t making sounds back at you by about 4 months, or isn’t babbling strings like "bababa" by about 9 months. The same goes for no single words by about 16 months, or no two words together by about 2 years. Ask for a hearing check at the same visit. Hearing is the commonest reason, and the easiest to treat.'),
              PpCard('Social and emotional', 'Being with people. Worth raising with your paediatrician if your baby doesn’t smile back at you by about 3 months. Or doesn’t look where you point, or point things out to you, by about 12 to 15 months. Mention it too if your baby rarely brings you things to show you, or doesn’t respond to being called by name by about 12 months.'),
              PpCard('Cognitive', 'Working things out. Worth raising with your paediatrician if your baby doesn’t follow a moving object with the eyes by about 3 months. Or shows no interest in a toy that has just been hidden by about 12 months. Mention it too if, by about 2 years, everyday objects aren’t used the way they’re meant, such as holding a phone to the ear.'),
              PpCard('Self-care', 'Doing it alone. Worth raising with your paediatrician if your baby can’t bring food to the mouth by about 12 months. Or isn’t trying to help with simple things, like pushing an arm through a sleeve, by about 2 years. Feeding that is hard again and again, with coughing or choking, belongs in the same conversation.'),
            ], heading: 'By area, worth mentioning at the next visit', hue: 160),
            PpWhenLine('Bring any of these to your child’s next routine '
                'visit, or sooner if it’s the lost-skill line above.'),
            PpIndiaNote('Your paediatrician is the right first door. If they '
                'want a closer look, many district hospitals now run an early '
                'intervention centre, and most cities have developmental '
                'paediatricians, speech therapists and occupational '
                'therapists. Support this early is usually about play and '
                'practice, not medicine.'),
            PpConsult(
              title: 'Talk to a developmental paediatrician',
              whoFor: 'For a parent holding one of the lines above and wanting '
                  'an unhurried opinion before deciding anything. You’ll get '
                  'a clear view of what is normal for your child and what, if '
                  'anything, is worth following up. Not a diagnosis over a '
                  'call.',
              surfaceId: 'pp_experts',
              role: 'development',
            ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpArticle(heading: 'When movement takes longer, and why screening helps', [
              'Some children are slower with big movements, like walking, '
                  'running and climbing, or with small ones, like picking up '
                  'small things, holding a crayon or using a spoon. Often they '
                  'catch up. When they don’t, a physiotherapist or '
                  'occupational therapist helps a great deal, and earlier is '
                  'better.',
              'A developmental screen is a short, structured check, usually at '
                  '9, 18 and 24 to 30 months, that looks at movement, talking, '
                  'play and social skills. Your child can’t pass or fail it. '
                  'It’s a way to find the children who would gain from help '
                  'early. Ask your paediatrician for one.',
            ]),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_born_early',
          title: 'If your baby was born early',
          subtitle: 'Count from the due date, not the birthday',
          format: 'SHORT ARTICLE',
          bands: _firstTwoYears,
          blocks: [
            PpIntro('A baby born six weeks early has had six fewer weeks to '
                'grow. So read every milestone window in this app from the '
                'date your baby was due, not the date of birth.'),
            PpArticle([
              'This is called corrected age, and it’s what your '
                  'paediatrician uses too. If your baby is eight months old '
                  'and was born two months early, the corrected age is six '
                  'months. Read the six-month pages. Expect six-month things.',
              'Almost every worry a preterm parent brings to a milestone chart '
                  'disappears the moment the chart is read at the right age. '
                  'This is the right standard for your baby, and your doctor '
                  'uses it too.',
              'Most doctors keep correcting until about two years, by which '
                  'point the head start the other babies had stops mattering. '
                  'After that, the ordinary windows apply.',
            ]),
            PpChartCard(
              title: 'Reading a chart at corrected age',
              rows: [
                ('Born 4 weeks early, now 6 months', 'Read as 5 months'),
                ('Born 8 weeks early, now 9 months', 'Read as 7 months'),
                ('Born 12 weeks early, now 12 months', 'Read as 9 months'),
              ],
              note: 'Take the weeks born early away from the age today. That '
                  'is the age to read.',
              hue: 160,
            ),
            PpWhenLine('Correct for prematurity until about 2 years, then use '
                'the ordinary age.'),
            PpIndiaNote('If your baby spent time in the NICU, keep the '
                'discharge summary and the follow-up card together. Most '
                'preterm babies are enrolled in a high-risk follow-up clinic, '
                'and those visits are worth keeping even when everything looks '
                'fine.'),
            PpCallout('Corrected age isn’t an excuse or wishful thinking. '
                'It’s plain arithmetic, the same arithmetic the charts were '
                'built on.'),
            PpLink('Keep the NICU papers and follow-up notes together',
                surfaceId: 'pp_health',
                blurb: 'Health records hold the discharge summary and visit '
                    'notes.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpSteps(heading: 'Working out your baby’s corrected age', [
              PpStep('Count how many weeks early your baby came', 'Forty weeks minus the '
                  'weeks of pregnancy at birth. Born at 32 weeks is 8 weeks '
                  'early.'),
              PpStep('Take that from the age since birth', 'At 6 months old, '
                  'that’s about 4 months corrected.'),
              PpStep('Use corrected age for milestones and growth', 'Until '
                  'about two years.'),
              PpStep('Use the real age for vaccines', 'Vaccines go by birth '
                  'date, not corrected age.'),
            ]),
          ],
        ),

        // ---------------------------------------------------------------------
        /* ⚠️ REMOVED BY FEEDBACK, KEPT FOR REVERT.
           "In check my child's development section — delete Your cousin baby was
           walking by now section."
           ⚠️ WORTH KNOWING WHAT THIS COSTS. This file's own header calls the
           joint-family comparison "the actual emotional problem this section
           solves". Removing the page does not remove the problem — it is
           still answered by "The normal range is much wider than you think"
           and by the India note on that page, which is where a parent meets
           it without having to open a page named after the sentence that
           upset her.
           Commented rather than deleted, per comment-out-never-delete:
           the writing is good and the decision is editorial, so bringing
           it back is uncommenting rather than rewriting.

        PpPage(
          id: 'dev_comparison_pressure',
          title: '"Your cousin’s baby was walking by now"',
          subtitle: 'What to say, and what to stop measuring',
          format: 'SHORT ARTICLE with script box',
          bands: _all,
          blocks: [
            PpIntro('This is the most common reason parents in India open a '
                'milestone page, and it is a family problem rather than a '
                'medical one. Here is how to put it down.'),
            PpArticle([
              'The comparison almost always comes with love attached. A '
                  'grandmother who raised four children, an aunt who is proud '
                  'of her own, a cousin sending a video of a ten-month-old '
                  'toddling across a hall. Nobody in that chain is trying to '
                  'hurt you.',
              'It still lands hard, because you are the one awake at night '
                  'with it. And it is not information. One other baby is a '
                  'single point, not a range, and the videos that travel '
                  'around a family are the early ones. Nobody films the fifteen'
                  '-month-old taking their time.',
              'The useful move is to stop defending the timeline and change '
                  'what you report. Tell people what your child is doing, not '
                  'what they are not doing yet. It is warmer, it is true, and '
                  'it ends the conversation faster.',
            ]),
            PpScript(
              [
                PpScriptLine(
                  say: 'She is doing it in her own time, and the doctor is '
                      'happy with her.',
                  notThis: 'I know, I am worried too, I keep checking.',
                  why: 'Naming the doctor closes the subject kindly. Agreeing '
                      'with the worry invites more advice.',
                ),
                PpScriptLine(
                  say: 'Look what he has just started doing, he pulls himself '
                      'up on the sofa now.',
                  notThis: 'He still is not walking.',
                  why: 'Reporting what is emerging is the same news, told '
                      'accurately. Most relatives just want to celebrate '
                      'something.',
                ),
                PpScriptLine(
                  say: 'Babies walk anywhere between nine and eighteen months. '
                      'We are right in the middle of that.',
                  notThis: 'The book says twelve months.',
                  why: 'The range is the fact. A single number is what created '
                      'the pressure in the first place.',
                ),
                PpScriptLine(
                  say: 'I would rather not compare them, they are different '
                      'children.',
                  notThis: 'Why do you always compare?',
                  why: 'A boundary about the comparing, not an accusation '
                      'about the person, is the version that gets respected.',
                ),
              ],
              heading: 'Words you can borrow',
            ),
            PpCallout('If you take one thing from this page: stop reporting '
                'the gap and start reporting the movement. Your child gets the '
                'same credit and you get your evenings back.'),
            PpWhenLine('Useful from the first month onwards, and most useful '
                'between 9 and 18 months when walking talk peaks.'),
            PpIndiaNote('In a joint family the comparison is daily rather than '
                'occasional, and it is often the mother who is held '
                'responsible for it. That is not fair and it is also not '
                'yours to carry. A milestone is not a report card on your '
                'feeding, your milk or your attention.'),
            PpLink('The actual ranges, so you have the numbers',
                surfaceId: 'pp_milestones',
                blurb: 'Windows for every milestone, in one place.'),
          ],
        ),
        */
      ],
    ),

    // =========================================================================
    //  DOOR 2 — When will my baby...
    // =========================================================================
    PpArea(
      id: 'when_will',
      mark: IntentMark.chartLog,
      title: 'When will my baby sit, crawl, walk, talk?',
      blurb: 'One page per skill. The range, the signs it’s coming, and how '
          'to help gently.',
      hue: 206,
      // The whole area is a first-two-years question. Hidden rather than
      // half-empty for a parent of a three-year-old, who has other doors.
      bands: _firstTwoYears,
      pages: [
        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_rolling',
          title: 'When will my baby roll over?',
          format: 'ARTICLE',
          bands: ['dev_0_6'],
          blocks: [
            PpIntro('Rolling is usually the first big move a baby makes '
                'alone. It often happens once, dramatically, and then not '
                'again for two weeks.'),
            PpChartCard(
              title: 'Rolling over',
              rows: [
                ('Usual window', '4 to 6 months'),
                ('Tummy to back often first', 'From about 4 months'),
                ('Back to tummy usually later', 'About 5 to 7 months'),
                ('Still within normal', 'Up to about 7 months'),
              ],
              note: 'Some babies skip rolling almost entirely and go straight '
                  'to sitting and shuffling. That is fine.',
              hue: 206,
            ),
            PpCards([
              PpCard('Rocking on the side',
                  'Lying on the back, lifting both legs and tipping to one '
                      'side. This is practice for the roll.'),
              PpCard('Reaching across the body',
                  'Stretching for something just out of reach on the far side. '
                      'The reach is what turns into the roll.'),
              PpCard('Strong head lift on the tummy',
                  'Pushing up on the forearms and holding it. The strength '
                      'comes before the movement.'),
              PpCard('Kicking hard against a surface',
                  'A baby who pushes off your lap or the mat is building '
                      'exactly the muscles this needs.'),
            ], heading: 'Signs it’s coming', hue: 206),
            PpSteps([
              PpStep('Give short, frequent floor time on the tummy', 'Three or four short spells a day beat one long '
                      'unhappy one. On a firm surface, awake, with you at eye '
                      'level.'),
              PpStep('Put a favourite thing just out of reach, to the side', 'A small steel bowl, a bright scarf, your own face. '
                      'The reach across the body does the work.'),
              PpStep('Let your baby finish the roll', 'Help with the first half if it gets stuck, then wait. '
                      'The last bit is the part being learned.'),
              PpStep('Change which side you approach from', 'Babies favour one side. Feeding and playing from '
                      'both keeps it even.'),
            ], heading: 'How to help, gently'),
            PpWhenLine('Most babies roll between 4 and 6 months. Tummy time '
                'from the first weeks, in short spells.'),
            PpIndiaNote('Baby massage helps here, and not only for '
                'bonding. The stretching and the few minutes on the tummy '
                'afterwards, on a mat rather than a soft bed, is good rolling '
                'practice. Keep the room warm and the surface firm.'),
            PpCallout('Once a baby can roll, the edge of a bed or a string cot '
                'is in reach, and the first time is always a surprise. Move '
                'play to the floor now rather than after.'),
            PpCallout(
              'Worth asking your paediatrician if your baby isn’t holding '
                  'the head steady by about 4 months, or hasn’t rolled either '
                  'way by about 7 months. Ask too if rolling only ever goes to '
                  'one side, or your baby feels unusually stiff or floppy when '
                  'picked up.',
              kind: PpCalloutKind.doctor,
              title: 'When rolling is worth a check',
            ),
            PpLink('Things to do together today',
                surfaceId: 'pp_development',
                blurb: 'Activities matched to your baby’s age.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_sitting',
          title: 'When will my baby sit up?',
          format: 'ARTICLE',
          bands: ['dev_0_6', 'dev_6_12'],
          blocks: [
            PpIntro('Sitting arrives in stages: propped, then wobbling alone '
                'for a second, then steady, then steady enough to turn and '
                'reach without toppling.'),
            PpChartCard(
              title: 'Sitting up',
              rows: [
                ('Sits with support', 'About 4 to 6 months'),
                ('Sits alone, wobbly', 'About 5 to 7 months'),
                ('Sits steadily', 'About 6 to 9 months'),
                ('Gets into sitting alone', 'About 8 to 11 months'),
              ],
              note: 'Steady independent sitting anywhere up to about 9 months '
                  'is well inside normal.',
              hue: 206,
            ),
            PpCards([
              PpCard('A strong, straight back when propped',
                  'Held at the hips rather than the chest, and still upright. '
                      'That is trunk strength arriving.'),
              PpCard('Tripod sitting',
                  'Sitting forward on both hands like a little tripod. The '
                      'hands come off one at a time.'),
              PpCard('Pushing up on straight arms',
                  'From the tummy, arms locked, chest well off the floor.'),
              PpCard('Rolling with purpose',
                  'A baby who can get around by rolling is close to '
                      'wanting to sit and look instead.'),
            ], heading: 'Signs it’s coming', hue: 206),
            PpSteps([
              PpStep('Sit your baby between your legs on the floor', 'Your thighs are a better prop than cushions, '
                      'because they hold the hips and leave the back to work.'),
              PpStep('Put toys in a ring around your baby, not in the lap', 'Turning to reach is how balance gets learned.'),
              PpStep('Let the topples land on something soft', 'Falling over is part of it. A folded quilt behind '
                      'and beside is enough.'),
              PpStep('Keep plenty of tummy and floor time', 'Sitting is built on the same back and shoulder '
                      'strength tummy time builds.'),
            ], heading: 'How to help, gently'),
            PpWhenLine('Most babies sit steadily between 6 and 9 months. Start '
                'propped floor sitting from about 4 months.'),
            PpIndiaNote('Walkers, jumpers and long stretches in a bouncy chair '
                'do not teach sitting, because the seat does the balancing. '
                'Floor time on a cotton rug or a folded sheet does. Free floor '
                'play is what helps, and it costs nothing.'),
            PpCallout('Don’t prop a baby upright with cushions and walk away. '
                'A baby who can’t get out of a position is never left alone '
                'in it.'),
            PpCallout(
              'Worth asking your paediatrician if your baby isn’t sitting '
                  'without support by about 9 months. Ask too if no weight '
                  'goes through straight arms, or your baby always slumps to '
                  'the same side.',
              kind: PpCalloutKind.doctor,
              title: 'When sitting is worth a check',
            ),
            PpLink('Where your child is right now',
                surfaceId: 'pp_milestones',
                blurb: 'Sitting, and what is emerging alongside it.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_crawling',
          title: 'When will my baby crawl?',
          format: 'ARTICLE',
          bands: ['dev_0_6', 'dev_6_12'],
          blocks: [
            PpIntro('Crawling is the milestone with the loosest rules of all. '
                'Plenty of babies never crawl on hands and knees, and go '
                'straight from sitting to pulling up to walking.'),
            PpChartCard(
              title: 'Crawling and other ways of moving',
              rows: [
                ('Usual window for moving', '6 to 10 months'),
                ('Commando shuffle on the tummy', 'Often first, from 6 months'),
                ('Hands and knees crawling', 'About 7 to 11 months'),
                ('Bottom shuffling instead', 'Common, and completely fine'),
              ],
              note: 'The milestone is "gets across the room somehow". '
                  'How is up to your baby.',
              hue: 206,
            ),
            PpCards([
              PpCard('Rocking on hands and knees',
                  'Up on all fours, rocking back and forth. The engine is '
                      'running.'),
              PpCard('Going backwards first',
                  'Sliding away from the very toy that was wanted. Almost '
                      'every baby does this, and it’s very frustrating at the time.'),
              PpCard('The commando drag',
                  'Pulling along on the tummy with the arms. This counts as '
                      'moving and often replaces crawling entirely.'),
              PpCard('Reaching from sitting',
                  'Leaning further and further out of a sitting position until '
                      'a hand lands on the floor.'),
            ], heading: 'Signs it’s coming', hue: 206),
            PpSteps([
              PpStep('Clear a stretch of floor and let your baby loose on it', 'Space matters more than toys. A cleared room is the '
                      'best equipment there is.'),
              PpStep('Sit a little way off and call your baby over', 'You’re a better motivator than any object. Move '
                      'back a step at each arrival.'),
              PpStep('Put a target just beyond reach', 'Close enough to seem possible. If your baby gives up '
                      'every time, it’s too far.'),
              PpStep('Make crawling worth doing, and safe', 'Cover plug points, move buckets of water, put away '
                      'phenyl and cleaning bottles, and tie up dangling wires. '
                      'A baby who can cross a room will.'),
            ], heading: 'How to help, gently'),
            PpWhenLine('Most babies are moving somehow between 6 and 10 '
                'months. Not crawling by 12 months, with no other way of '
                'moving, is worth a mention.'),
            PpIndiaNote('Indian floors help here. A wiped floor with a cotton rug '
                'or a sheet over it beats a mattress for crawling. A firm '
                'surface gives the knees and hands something to push against. '
                'Bare knees on a warm swept floor are fine.'),
            PpVideoSlot(
              title: 'Helping your baby get moving',
              subtitle: 'A physiotherapist shows floor positions, tummy play '
                  'and the reach that turns into a crawl.',
              minutes: '9 MIN',
              slotId: 'development/helping_baby_move',
              hue: 206,
            ),
            PpCallout(
              'Worth asking your paediatrician if your baby has no way at all '
                  'of getting around by about 12 months. Ask too if only one arm '
                  'or one leg is used to move, or one side drags. Skipping '
                  'crawling on its own isn’t a concern.',
              kind: PpCalloutKind.doctor,
              title: 'When moving is worth a check',
            ),
            PpLink('Things to do together today',
                surfaceId: 'pp_development',
                blurb: 'Floor play and movement activities for this age.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_standing',
          title: 'When will my baby pull up and stand?',
          format: 'ARTICLE',
          bands: ['dev_6_12', 'dev_1_2'],
          blocks: [
            PpIntro('Pulling up to stand is the first time a baby chooses to '
                'be upright, and it usually arrives with a lot of noise and a '
                'few bumped chins.'),
            PpChartCard(
              title: 'Pulling up, standing, cruising',
              rows: [
                ('Bears weight on legs when held', 'About 5 to 8 months'),
                ('Pulls up on furniture', 'About 8 to 11 months'),
                ('Stands holding on', 'About 8 to 12 months'),
                ('Cruises along furniture', 'About 9 to 13 months'),
                ('Stands alone briefly', 'About 10 to 14 months'),
              ],
              note: 'Standing holding on by about 12 months is the line worth '
                  'remembering. Everything before that is a window.',
              hue: 206,
            ),
            PpCards([
              PpCard('Pushing up on the legs in your lap',
                  'Straightening the knees and bouncing. Leg strength coming '
                      'in.'),
              PpCard('Kneeling at the sofa',
                  'Up on both knees against something solid. Standing is the '
                      'next push.'),
              PpCard('One hand off',
                  'Standing at a surface and letting go with one hand to '
                      'reach. Balance is being tested.'),
              PpCard('Sitting down on purpose',
                  'Getting down without falling is a separate skill, and it '
                      'often arrives after standing. That’s why so many babies '
                      'cry at the top.'),
            ], heading: 'Signs it’s coming', hue: 206),
            PpSteps([
              PpStep('Give your baby something stable at chest height', 'A heavy sofa, a low bed, a diwan. Check that it '
                      'won’t tip before your baby leans on it.'),
              PpStep('Teach getting down, not only getting up', 'Guide the hands down and bend the knees a few '
                      'times. It stops the stuck-and-screaming stage.'),
              PpStep('Go barefoot indoors', 'Bare feet grip and feel the floor. Shoes are for '
                      'outside, once walking starts.'),
              PpStep('Look at the room from your baby’s height', 'Tablecloths, table edges, the pressure cooker '
                      'handle, a hot cup on a low table. Anything within reach '
                      'will get pulled.'),
            ], heading: 'How to help, gently'),
            PpWhenLine('Most babies pull up between 8 and 11 months and stand '
                'holding on by about 12 months.'),
            PpIndiaNote('This is when the house needs a second look at knee '
                'height. Bucket of water in the bathroom, hot pan handles '
                'turned inwards, the pressure cooker moved back, and '
                'floor-level lamps and wires tied up. A baby who can stand can '
                'reach a foot higher than yesterday.'),
            PpCallout(
              'Worth asking your paediatrician if your baby isn’t bearing '
                  'weight on the legs by about 9 months, or isn’t standing '
                  'holding on by about 12 months. Ask too if your baby stands '
                  'on tiptoes all the time and can’t get the heels down.',
              kind: PpCalloutKind.doctor,
              title: 'When standing is worth a check',
            ),
            PpLink('Where your child is right now',
                surfaceId: 'pp_milestones',
                blurb: 'Standing, and what tends to arrive after it.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_walking',
          title: 'When will my baby walk?',
          format: 'ARTICLE',
          bands: ['dev_6_12', 'dev_1_2'],
          blocks: [
            PpIntro('The most asked question in this whole section, and the one '
                'with the widest honest answer. Somewhere between nine and '
                'eighteen months, and where your child lands inside that '
                'predicts nothing at all.'),
            PpChartCard(
              title: 'First steps',
              rows: [
                ('Usual window', '9 to 15 months'),
                ('Still typical', 'Up to about 18 months'),
                ('Walks steadily', 'Usually 2 to 4 months after first steps'),
                ('Runs', 'About 18 to 24 months'),
              ],
              note: 'A quarter of babies aren’t walking at the first '
                  'birthday, and most of them are walking within three '
                  'months.',
              hue: 206,
            ),
            PpCards([
              PpCard('Cruising along the furniture',
                  'Sideways steps holding on. This is walking, with the '
                      'balance borrowed.'),
              PpCard('Standing alone without noticing',
                  'Letting go to look at something and staying up. Confidence '
                      'is arriving.'),
              PpCard('Walking with one hand held',
                  'One hand instead of two means most of the balance is '
                      'already your baby’s own.'),
              PpCard('Pushing a heavy chair around',
                  'A weighted push is the best natural walking trainer there '
                      'is, because your baby sets the pace.'),
            ], heading: 'Signs it’s coming', hue: 206),
            PpSteps([
              PpStep('Barefoot, indoors, on a firm floor', 'Feet learn balance by feeling the ground. Save '
                      'shoes for outdoors and keep them soft and flexible.'),
              PpStep('Offer your hands, not your grip', 'Let your baby hold your fingers, rather than you '
                      'holding the wrists. That way letting go is always possible.'),
              PpStep('Set up short crossings', 'Sofa to your knees, a metre apart. Then a little '
                      'more. Small successes beat long attempts.'),
              PpStep('Let the falls land on a padded bottom', 'Nappy-cushioned falls are how it’s learned. Clear '
                      'the hard corners rather than the practice.'),
              PpStep('Offer something to push, not something to sit in', 'A heavy stool, a laundry basket with a book in it, '
                      'a sturdy push toy. Your baby is in charge of it, not '
                      'carried by it.'),
            ], heading: 'How to help, gently'),
            PpCallout(
              'Please don’t use a baby walker, the kind with a seat and '
                  'wheels. Walkers don’t help a baby walk sooner, can delay '
                  'it, and cause serious head injuries when they roll '
                  'into a step, a bathroom threshold or a staircase. Several '
                  'countries have banned them outright. A push-along toy, '
                  'which the baby walks behind rather than sits inside, is the '
                  'safe version.',
              kind: PpCalloutKind.myth,
              title: 'Baby walkers: the one clear no',
            ),
            PpWhenLine('Most babies take first steps between 9 and 15 months. '
                'Not walking at all by 18 months is worth a check.'),
            PpIndiaNote('Two things worth naming. First, walkers and jumpers '
                'are still sold and gifted widely here, and refusing one is a '
                'reasonable thing to do even when it came from an elder. '
                'Second, a bowed-legs look in a new walker is usually normal '
                'and straightens by two or three years. Still, ask your '
                'paediatrician about vitamin D and calcium. Deficiency '
                'is common in Indian children, and easy to treat.'),
            PpVideoSlot(
              title: 'The last few weeks before walking',
              subtitle: 'A follow-along on cruising, short crossings, and what '
                  'to do instead of holding both hands.',
              minutes: '8 MIN',
              slotId: 'development/helping_baby_walk',
              hue: 206,
            ),
            PpCallout(
              'Worth asking your paediatrician if your baby isn’t walking at '
                  'all by about 18 months, or was walking and has stopped. Ask '
                  'too if your baby walks only on tiptoes and can’t put the '
                  'feet flat, or drags one leg. Ask about vitamin D at the '
                  'same visit.',
              kind: PpCalloutKind.doctor,
              title: 'When walking is worth a check',
            ),
            // [fix] "skip this" lives behind the guides door, not the grid.
            PpLink('Things worth buying, and things worth skipping',
                // surfaceId: 'pp_recos',
                surfaceId: 'pp_product_guide',
                blurb: 'A push toy is on the list. A seated walker is not.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_gestures',
          title: 'When will my baby point and wave?',
          subtitle: 'The quietest milestone, and one of the most telling',
          format: 'ARTICLE',
          bands: ['dev_6_12', 'dev_1_2'],
          blocks: [
            PpIntro('Pointing, waving, clapping and holding something up to '
                'show you are easy to miss next to walking. They matter more '
                'than most families realise, because they are how a baby talks '
                'before there are words.'),
            PpChartCard(
              title: 'Early gestures',
              rows: [
                ('Reaching up to be picked up', 'About 6 to 9 months'),
                ('Clapping, banging two things', 'About 8 to 12 months'),
                ('Waving bye-bye', 'About 9 to 13 months'),
                ('Pointing at something wanted', 'About 10 to 14 months'),
                ('Pointing to show you something', 'About 12 to 16 months'),
                ('Shaking head for no', 'About 12 to 18 months'),
              ],
              note: 'Pointing to share something, rather than to get it, is '
                  'the one worth watching for. It means "look at that with '
                  'me".',
              hue: 206,
            ),
            PpArticle([
              'Gestures are the bridge to speech. A baby who points, waves and '
                  'brings you things is already having conversations, only '
                  'without sound, and children who gesture a lot tend to talk '
                  'a little sooner. If you’re waiting anxiously for first '
                  'words, gestures are the reassuring thing to look for in the '
                  'meantime.',
              'The two kinds of pointing are worth telling apart. Pointing '
                  'at the biscuit to get it is asking. Pointing at a crow '
                  'on the wall and then turning to check you saw it is '
                  'sharing, and sharing is the bigger step.',
            ]),
            PpSteps([
              PpStep('Point at things yourself, all day', 'Name what you point at. "Look, a crow." Babies copy '
                      'the gesture long before the word.'),
              PpStep('Wave at every arrival and departure', 'Doorways are natural practice, and Indian homes '
                      'have plenty of comings and goings.'),
              PpStep('Answer every gesture as if it were a sentence', 'Your baby points, you say the word and hand it over. '
                      'That exchange teaches that gestures work.'),
              PpStep('Play games with hands in them', 'Clapping, peekaboo, and the old hand rhymes. Copying '
                      'hands is the skill underneath all of these.'),
            ], heading: 'How to help, gently'),
            PpWhenLine('Most babies wave and point between 9 and 14 months. No '
                'gestures at all by 12 to 15 months is worth mentioning.'),
            PpIndiaNote('The traditional hand games do this job perfectly. '
                'Clap-clap games, a namaste at the door, hands on the head, and '
                'the rhymes a grandmother already knows. You don’t need '
                'flashcards for this one.'),
            PpCallout('If words are taking their time but gestures are '
                'plentiful, that’s a much calmer picture than the other way '
                'round. Children who gesture are communicating.'),
            PpCallout(
              'Worth asking your paediatrician if your baby uses no gestures '
                  'at all by about 15 months, or doesn’t look where you point. '
                  'Ask too if your baby rarely brings you things to show you, '
                  'or doesn’t respond to being called by name by about 12 '
                  'months. Ask for a hearing check at the same visit.',
              kind: PpCalloutKind.doctor,
              title: 'When gestures are worth a check',
            ),
            PpLink('Talking activities for this age',
                surfaceId: 'pp_activities',
                blurb: 'The language area, with things to try today.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_first_words',
          title: 'When will my baby say a first word?',
          format: 'ARTICLE',
          bands: ['dev_6_12', 'dev_1_2'],
          blocks: [
            PpIntro('Understanding always comes first, and by a long way. Your '
                'baby will follow instructions, recognise names and get your '
                'jokes months before saying anything you can write down.'),
            PpChartCard(
              title: 'The road to first words',
              rows: [
                ('Cooing and vowel sounds', 'About 2 to 4 months'),
                ('Babbling strings, "bababa"', 'About 4 to 9 months'),
                ('Understands simple words', 'About 6 to 12 months'),
                ('First real word', 'About 10 to 15 months'),
                ('Around 10 to 20 words', 'About 15 to 18 months'),
                ('Two words together', 'About 18 to 24 months'),
              ],
              note: 'A word counts if it’s used consistently to mean the same '
                  'thing, even if it isn’t clear. "Baa" for bottle is a word.',
              hue: 206,
            ),
            PpArticle([
              'Count what your child understands, not only what comes out. Ask '
                  'for the ball and watch the search begin. Say papa is coming '
                  'and watch the turn to the door. That is language, working '
                  'exactly as it’s meant to.',
              'First words aren’t always the ones a family is hoping '
                  'for. Mummy, papa, dada, no, and the name of the family dog '
                  'are all extremely common. So is a word for milk, since it '
                  'is the thing most worth asking for.',
            ]),
            PpSteps([
              PpStep('Talk through what you’re doing, out loud', 'Naming the day as it happens gives your baby thousands '
                      'of words in context rather than in a list.'),
              PpStep('Leave a gap and wait', 'Ask, then count to five in your head. A pause is an '
                      'invitation, and babies need longer than adults to take '
                      'it.'),
              PpStep('Answer babble as though it were speech', 'Your baby says bababa, you answer properly. That '
                      'back-and-forth is one of the most useful things you can '
                      'do.'),
              PpStep('Add one word to whatever your baby says', 'Your baby says "milk", you say "warm milk". One '
                      'step further, never a correction.'),
            ], heading: 'How to help, gently'),
            PpWhenLine('Most babies say a first word between 10 and 15 months. '
                'No words at all by about 16 months is worth a check.'),
            PpIndiaNote('If your home runs on two or three languages, your '
                'baby isn’t confused and isn’t falling short. First words may '
                'be spread across languages, and the right way to count is to '
                'add them all together. There’s a full page on this in the '
                'talking door.'),
            PpVideoSlot(
              title: 'What a first word sounds like',
              subtitle: 'A speech therapist on babble, first words, and why '
                  'understanding runs ahead of talking.',
              minutes: '8 MIN',
              slotId: 'development/first_words_explainer',
              hue: 206,
            ),
            PpCallout(
              'Worth asking your paediatrician if your baby isn’t babbling by '
                  'about 9 months, or has no words by about 16 months. Ask too '
                  'if two words aren’t joined by about 2 years, or words that '
                  'used to be there have gone. Ask for a hearing test as part '
                  'of the visit, every time.',
              kind: PpCalloutKind.doctor,
              title: 'When talking is worth a check',
            ),
            PpLink('Talking activities for this age',
                surfaceId: 'pp_activities',
                blurb: 'The language area, with things to try today.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_self_feeding',
          title: 'When will my baby start self-feeding?',
          format: 'ARTICLE',
          bands: ['dev_6_12', 'dev_1_2'],
          blocks: [
            PpIntro('Self-feeding is a hand skill before it is an eating '
                'skill, and it’s messy by design. The mess is your child '
                'learning where the mouth is.'),
            PpChartCard(
              title: 'Self-feeding',
              rows: [
                ('Brings things to the mouth', 'About 4 to 7 months'),
                ('Holds and gnaws a soft finger food', 'About 6 to 9 months'),
                ('Picks up small pieces, finger and thumb',
                    'About 8 to 12 months'),
                ('Uses a spoon, badly', 'About 12 to 18 months'),
                ('Uses a spoon, mostly successfully', 'About 18 to 24 months'),
                ('Drinks from an open glass', 'About 15 to 24 months'),
              ],
              note: 'Getting food to the mouth by 12 months matters. Doing it '
                  'neatly does not, for years.',
              hue: 206,
            ),
            PpSteps([
              PpStep('Offer soft strips your baby can hold in a fist', 'Steamed carrot, ripe banana, soft paneer, a strip '
                      'of roti softened in dal. Long enough to stick out of a '
                      'closed hand.'),
              PpStep('Give your baby a spoon while you use yours', 'It won’t work for months. Holding it is '
                      'the practice.'),
              PpStep('Put the food on the tray, not in the hand', 'Picking it up is the skill you’re after.'),
              PpStep('Let the floor get dirty', 'Newspaper or an old sheet under the chair, and '
                      'nobody has to police the mess.'),
              PpStep('Sit and eat together', 'Children learn eating by watching. Family meals do '
                      'more than any technique.'),
            ], heading: 'How to help, gently'),
            PpWhenLine('Most babies pick up small pieces between 8 and 12 '
                'months, and use a spoon somewhere between 12 and 24 months.'),
            PpIndiaNote('Hand-feeding a child, and being hand-fed, is normal '
                'and warm in Indian homes, and there’s nothing to fix about '
                'it. Leave room for your child’s own hands too, so both happen. '
                'Steel plates and small steel bowls are good tools here, since a bowl '
                'that doesn’t skid is easier to eat from than a light plastic '
                'one.'),
            PpCallout('Never leave a baby alone with food, and skip the hard '
                'round things entirely for now: whole nuts, whole grapes, '
                'boiled sweets, popcorn and raw carrot rounds.'),
            PpCallout(
              'Worth asking your paediatrician if your baby can’t get food to '
                  'the mouth by about 12 months, or gags or coughs badly at most '
                  'meals. Ask too if all textures beyond puree are refused well '
                  'past 10 months, or there is weight loss. Feeding difficulty '
                  'is worth real help rather than more patience.',
              kind: PpCalloutKind.doctor,
              title: 'When feeding is worth a check',
            ),
            PpLink('What to feed, and how much',
                surfaceId: 'pp_food',
                blurb: 'Recipes and age-wise food, in the Food companion.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  DOOR 3 — Help my child develop
    // =========================================================================
    PpArea(
      id: 'help_develop',
      mark: IntentMark.cuppedHands,
      title: 'What can I do to help?',
      blurb: 'Play that builds the brain, using what is already in '
          'your house.',
      hue: 268,
      pages: [
        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_play_builds_brain',
          title: 'How play builds the brain',
          format: 'ARTICLE',
          bands: _all,
          blocks: [
            PpIntro('Nothing you can buy beats the thing you already do. A '
                'child’s brain is built by back-and-forth with a person '
                'who knows that child well. Everything else is optional.'),
            PpArticle([
              'The mechanism has a plain name: serve and return. Your baby '
                  'does something, a sound, a look, a reach. You answer it. '
                  'Your baby answers back. Each round lays down connections, '
                  'and a few hundred rounds a day is what a growing brain '
                  'runs on. That’s why talking to a baby who can’t talk back '
                  'isn’t silly, and why a phone in your hand at that moment '
                  'costs something real.',
              'Play is where most of those rounds happen. Not organised, '
                  'instructional play. Ordinary play, led by the child, with '
                  'you paying attention. Filling a small bowl with dal and pouring '
                  'it out is mathematics. Hiding under a scarf and coming '
                  'back is object permanence, and trust too. Banging a '
                  'steel glass with a spoon is cause and effect, and it’s '
                  'loud on purpose.',
              'The evidence for expensive toys is weak. What '
                  'helps is variety, repetition, and a responsive adult. What '
                  'doesn’t help much is anything that lights up and '
                  'plays a song while the child watches. When the toy does '
                  'all the work, your child does very little.',
              'One more thing worth knowing: little and often beats long and '
                  'formal. Ten minutes of your full attention, four or five '
                  'times a day, does more than an hour with a phone in your '
                  'other hand. That’s good news, because you can find ten '
                  'minutes even on a bad day.',
            ]),
            PpCards([
              PpCard('Follow, don’t lead',
                  'Watch what your child has picked up and join in, instead of '
                      'steering towards what you had planned.'),
              PpCard('Narrate what is happening',
                  'Say what your child is doing and what you’re doing. Words '
                      'attached to actions stick.'),
              PpCard('Repeat it, and repeat it again',
                  'Children ask for the same game forty times because '
                      'repetition is how a brain lays a path. All that '
                      'repeating is practice.'),
              PpCard('Let your child struggle for a moment',
                  'Wait before you help. The bit just past easy is where the '
                      'learning happens.'),
              PpCard('Use what is in the kitchen',
                  'Steel bowls, steel glasses, a wooden spoon, dry rajma in a '
                      'bottle, an empty flour tin. Free, safe, endlessly '
                      'reusable.'),
            ], heading: 'Five things that make any play better', hue: 268),
            PpCallout('You matter more than any toy. Whatever else you need '
                'is already in your kitchen.'),
            PpWhenLine('True from the first weeks to school age. A few short '
                'spells of attention a day is the target, not an hour.'),
            PpIndiaNote('A joint family is an advantage here, not a '
                'distraction. More faces, more voices, more languages and more '
                'laps all count as input. A baby passed around a room all '
                'evening is getting a great deal of serve and '
                'return.'),
            PpVideoSlot(
              title: 'Serve and return, shown with real babies',
              subtitle: 'What the back-and-forth looks like at three months, '
                  'nine months and two years.',
              minutes: '10 MIN',
              slotId: 'development/play_builds_brain',
              hue: 268,
            ),
            PpLink('Things to do together today',
                surfaceId: 'pp_development',
                blurb: 'Activities matched to your child’s age and to '
                    'each area of growing.'),
            PpLink('More activities, by area',
                surfaceId: 'pp_activities',
                blurb: 'The full set, filterable by what you want to work on.'),
            PpLink('A masterclass on play and early development',
                surfaceId: 'pp_courses',
                blurb: 'The same ideas, taught properly, if you want to go '
                    'deeper than a page.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_tummy_time',
          title: 'Tummy time without the tears',
          // ⚠️ REFORMAT step-list > video, on the brief: "it is a body
          // position, and a parent copies that from watching, not reading."
          // The steps stay under the film; the film leads.
          // format: 'STEP-LIST',
          format: 'VIDEO',
          bands: ['dev_0_6', 'dev_6_12'],
          blocks: [
            PpVideoSlot(
              title: 'Tummy time, shown',
              subtitle: 'On your chest, across your lap, then the floor: the '
                  'three positions at real speed, and when to stop.',
              minutes: '4 MIN',
              slotId: 'development/tummy_time',
              hue: 200,
            ),
            PpIntro('Almost every baby protests tummy time at first, and '
                'almost every parent takes that as a sign to stop. Short and '
                'often is the answer.'),
            PpArticle([
              'Time on the tummy, while awake and watched, builds the neck, '
                  'shoulder and back strength that rolling, sitting and '
                  'crawling all sit on top of. It also keeps the back of the '
                  'head from flattening on one side.',
              'Aim for a habit rather than a number of minutes: a few '
                  'short spells a day, starting from the first weeks with '
                  'only one or two minutes.',
            ]),
            PpSteps([
              PpStep('Start on your chest, not the floor', 'Lie back, put your baby tummy-down on you, face to '
                      'face. Most babies accept this long before they accept '
                      'a mat.'),
              PpStep('Then across your lap, then the floor', 'A slight downhill slope across your thighs is '
                      'easier than flat. Move to a firm mat once your baby is '
                      'happier.'),
              PpStep('Get down to your baby’s eye level', 'Lie on the floor, face to face. Your face is the '
                      'reason to lift the head.'),
              PpStep('Keep each spell short and stop before the crying', 'One or two minutes, three or four times a day, is a '
                      'good start. End it while it’s still being enjoyed.'),
              PpStep('Use the mirror and the high-contrast things', 'A mirror propped up, or a black and white picture, '
                      'buys another thirty seconds of head lift.'),
              PpStep('Try it after a massage, not after a feed', 'Warm, loose and awake is the best window. On a full '
                      'stomach it’s uncomfortable, and your baby will tell you so.'),
            ]),
            PpWhenLine('From the first weeks, awake and supervised, aiming for '
                'a total of about an hour a day spread out by 3 to 4 months.'),
            PpIndiaNote('Baby massage already gets your baby onto a firm surface, '
                'undressed and stretched, so the two minutes after the massage '
                'is the easiest tummy time of the day. A folded sheet on the '
                'floor is a better surface than a soft mattress, which lets '
                'the face sink and makes lifting harder.'),
            PpCallout('Tummy time is only for a baby who is awake and being '
                'watched. Sleep is always on the back, every time, including '
                'naps.'),
            PpCallout(
              'Worth asking your paediatrician if your baby won’t take '
                  'any tummy time at all by 3 months. Or if the head isn’t '
                  'lifting off the surface by about 4 months. Ask too if the head '
                  'always turns to the same side, or is clearly flattening or '
                  'lopsided.',
              kind: PpCalloutKind.doctor,
              title: 'When to mention it',
            ),
            PpLink('Movement activities for this age',
                surfaceId: 'pp_activities',
                blurb: 'What all this strength is building towards.'),
            PpLink('Time tummy time', surfaceId: 'pp_tummy_time',
                blurb: 'A start-stop timer that adds up the day, gently.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_everyday_play',
          title: 'Things to do today, from around the house',
          format: 'CARDS',
          bands: _all,
          blocks: [
            PpIntro('None of these needs to be bought. All of them are real '
                'development work, and most take under ten minutes.'),
            PpCards([
              PpCard('The bowl and the spoon',
                  'Hand over a small steel bowl and a spoon, then let the banging and '
                      'dropping begin. Cause and effect, and grip. '
                      'From about 6 months.'),
              PpCard('Scarf peekaboo',
                  'Hide your face, hide a toy, hide yourself. Object '
                      'permanence, and the beginning of trusting that you come '
                      'back. From about 5 months.'),
              PpCard('The tin drop',
                  'An empty flour tin and a handful of large safe objects to '
                      'post in and tip out. Hand skill and problem solving. '
                      'From about 9 months.'),
              PpCard('Roti dough in small hands',
                  'A small ball of roti dough to squeeze, poke and flatten '
                      'beside you while you cook. Fine motor and sensory. From '
                      'about 15 months.'),
              PpCard('Water and two glasses',
                  'Pouring between two steel glasses in a tray or over the '
                      'bathroom floor. Concentration, and it buys you twenty '
                      'quiet minutes. From about 18 months.'),
              PpCard('Naming the balcony',
                  'Five minutes at the window or on the balcony naming the '
                      'crow, the auto, the neighbour, the pigeon. Language, in '
                      'context. From birth.'),
              PpCard('The laundry sort',
                  'Your toddler hands you clothes, matches socks, and puts things in '
                      'the bucket. Categories, and being useful, which '
                      'toddlers love. From about 20 months.'),
              PpCard('A pile of books, not a lesson',
                  'Let your child turn pages, chew corners and skip to the end. '
                      'Handling books is the first reading skill. From about '
                      '6 months.'),
            ], heading: 'Eight that need nothing new', hue: 268),
            PpCallout('If a game is going badly, change the game rather than '
                'pushing. A bored or frustrated child learns nothing, and you '
                'both lose the ten minutes.'),
            PpWhenLine('Each card carries the age it usually starts working. '
                'A few short spells a day is plenty.'),
            PpIndiaNote('Everything here is a kitchen or cupboard object on '
                'purpose. Expensive developmental toys aren’t a shortcut. '
                'Household objects have an advantage besides price: they '
                'are the real things children see adults using, which is '
                'exactly why they want them.'),
            PpLink('Something new to try this week',
                surfaceId: 'pp_development',
                blurb: 'The app picks activities for your child’s age, '
                    'and changes them with each new stage.'),
            PpLink('The full activity list, by area',
                surfaceId: 'pp_activities',
                blurb: 'Movement, hands, talking, thinking, feelings, and '
                    'doing it alone.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_sensory_play',
          title: 'Messy play, and why it’s worth the mess',
          format: 'CARDS',
          bands: ['dev_6_12', 'dev_1_2', 'dev_2_3', 'dev_3_5'],
          blocks: [
            PpIntro('Hands in things is how young children gather '
                'information. It looks like a mess because it is one, and the '
                'mess is the point.'),
            PpArticle([
              'Touch is one of the earliest senses to work well and one of the '
                  'main ways a small child learns what the world is made of. '
                  'Wet, dry, rough, cold, heavy, crumbly. None of that can be '
                  'learned by looking.',
              'It also builds the hand strength and control that later hold a '
                  'pencil, and it’s calming, which is why a difficult evening '
                  'often improves the moment water appears.',
            ]),
            PpCards([
              PpCard('A tray of dry rice or dal',
                  'Pour, scoop, bury a spoon and find it. Sit alongside, '
                      'because small dry things and small children need '
                      'watching. From about 15 months.'),
              PpCard('Plain flour dough',
                  'Flour, water, a little oil. Squeeze, roll, poke holes. '
                      'Better than any shop clay and safe if it goes in the '
                      'mouth. From about 15 months.'),
              PpCard('Water play in a tub',
                  'A tub, two glasses, a small bowl with a hole in it. On the '
                      'bathroom floor so nobody minds. From about 9 months.'),
              PpCard('Ice on a hot afternoon',
                  'A few cubes in a steel plate to push around and watch '
                      'vanish. Temperature, and change over time. From about '
                      '18 months.'),
              PpCard('The texture basket',
                  'Six safe things that feel different: a loofah, a steel '
                      'spoon, a woollen sock, a plastic mug, a coconut shell, '
                      'a silk ribbon. From about 6 months.'),
              PpCard('Mud and the garden',
                  'Digging, wet soil, leaves, stones too big to swallow. A '
                      'bit of dirt is good for children. From about 18 '
                      'months.'),
            ], heading: 'Six, with what you already own', hue: 268),
            PpCallout('Set the mess up rather than fighting it. Newspaper or '
                'an old sheet underneath, clothes you don’t mind about, and '
                'a bucket ready. Then you can say yes without flinching.'),
            PpWhenLine('Most messy play starts working from about 9 months, '
                'and the dry-grain trays from about 15 months.'),
            PpIndiaNote('Do this in the bathroom, the balcony or the courtyard, '
                'and it stops being a problem. In the summer months water play '
                'is also the easiest way to cool a cranky toddler down.'),
            PpCallout(
              'Stay within arm’s reach for anything small and dry, and '
                  'for all water play. Small grains go up noses and into ears, '
                  'and a child can drown in very little water, silently. '
                  'If something has gone into a nose or an ear, don’t try to '
                  'dig it out. Go to a doctor.',
              kind: PpCalloutKind.doctor,
              title: 'Supervision is the whole safety rule',
            ),
            PpLink('More activities like these',
                surfaceId: 'pp_activities',
                blurb: 'Sorted by what they build.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_leaps_lens',
          title: 'Is my baby going through a leap?',
          format: 'SHORT ARTICLE',
          bands: _firstTwoYears,
          blocks: [
            PpIntro('Some weeks a settled baby turns clingy, wakeful and hard '
                'to please for no visible reason, and then comes out of it '
                'doing something new. The leaps idea is one popular way to '
                'think about those weeks.'),
            PpArticle([
              'The observation behind it is real, and most parents recognise it '
                  'at once. Before a jump in understanding, babies often '
                  'get unsettled. They want to be held, feed oddly, '
                  'sleep worse and cling. Then something clicks, and there is '
                  'new noticing, reaching or babbling that wasn’t there '
                  'a fortnight ago.',
              'What the leaps framework adds is a calendar, with specific '
                  'weeks. That part is worth being honest about: the fixed '
                  'week-by-week timing isn’t well backed by evidence, and '
                  'independent researchers haven’t reproduced it neatly. '
                  'Babies do jump forward, though not on a '
                  'timetable.',
              'So use it as a lens, not a law. If your baby is having a rough '
                  'week and a leap window is open, it’s a comforting '
                  'explanation, and the week usually passes. If your baby is settled '
                  'during a leap week, nothing is wrong and nothing is being '
                  'missed. And if a rough patch arrives outside any window, it’s '
                  'just as real.',
            ]),
            PpCallout('The most helpful part of the leaps idea is '
                'permission: a difficult fortnight can be development rather '
                'than something you did wrong. That much holds whatever the '
                'calendar says.'),
            PpCards([
              PpCard('Clingy and wanting to be held',
                  'More arms, less floor. Give it rather than training it '
                      'out.'),
              PpCard('Sleep gone backwards',
                  'Extra night waking and short naps for a week or two, then a '
                      'return.'),
              PpCard('Fussy feeding',
                  'Shorter feeds, more often, or distracted feeds. Usually '
                      'settles with the rest.'),
              PpCard('Then something new',
                  'The reward at the end. A new sound, a new reach, a new '
                      'game that suddenly makes sense.'),
            ], heading: 'What a rough leap week tends to look like', hue: 268),
            PpWhenLine('The described windows fall in the first 20 months. '
                'Rough patches last a few days to about two weeks.'),
            PpIndiaNote('In a joint family a fussy fortnight often gets '
                'explained as the evil eye, or as the mother’s milk having '
                'reduced, or as teething. Development is a kinder and usually '
                'more accurate explanation, and it doesn’t ask anyone to '
                'change what they’re doing.'),
            PpCallout(
              'A leap may explain fussiness. It doesn’t explain fever, refusing '
                  'to feed, vomiting, unusual sleepiness, or crying that '
                  'can’t be soothed at all. Those need a doctor, and a leap '
                  'window is never a reason to wait.',
              kind: PpCalloutKind.doctor,
              title: 'What a leap doesn’t explain',
            ),
            PpLink('Your baby’s phase calendar',
                surfaceId: 'pp_leaps',
                blurb: 'Which window is open now, and what tends to arrive '
                    'after it.'),
            PpLink('Something has changed in my baby',
                surfaceId: 'pp_what_changed',
                blurb: 'Work through a specific change, step by step.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  DOOR 4 — Speech and language
    // =========================================================================
    // =========================================================================
    //  The one [NEW] page of the reissued brief, a scaffold until the copy
    //  lands. "That corner of the app is blank today." Logged in
    //  docs/DOOR-CONTENT-OWED.md; the ledger test holds it there.
    // =========================================================================
    PpArea(
      id: 'feelings_play',
      mark: IntentMark.stepsMark,
      title: 'Feelings, and getting on with others',
      blurb: 'Play for the part of growing that has no milestone chart.',
      hue: 344,
      pages: [
        PpPage(
          id: 'dev_feelings_activities',
          title: 'Activities for feelings and getting on with others',
          subtitle: 'Face-to-face play, naming feelings, and taking turns',
          format: 'ARTICLE',
          bands: _all,
          
          blocks: [
            // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
            // REQUIRED_REVIEW.
            PpIntro('Getting on with others starts with feeling safe with you. '
                'These small, everyday things help your child understand '
                'feelings, calm down and connect with people, matched to each '
                'age.'),
            PpSteps(heading: 'In the first year', [
              PpStep('Face-to-face time', 'Copy your baby’s faces and sounds. '
                  'Take turns.'),
              PpStep('Name the feeling', '"You’re hungry. You’re '
                  'cross."'),
              PpStep('Comfort quickly', 'Being soothed now is how a baby learns '
                  'self-soothing later.'),
            ]),
            PpSteps(heading: 'From one to three', [
              PpStep('Feelings faces', 'Make happy, sad and angry faces in the '
                  'mirror together.'),
              PpStep('Books about feelings', 'Point to a face and ask, "How is '
                  'this one feeling?"'),
              PpStep('Play together, then side by side', 'Sharing comes later. '
                  'Taking turns with you comes first.'),
              PpStep('Calm down together', 'Slow breaths, a hug, a quiet '
                  'corner.'),
            ]),
            PpSteps(heading: 'From three to five', [
              PpStep('Pretend play', 'Doctor, shop, house: practising other '
                  'people\'s feelings.'),
              PpStep('Games with rules', 'Waiting, taking turns, losing '
                  'gracefully.'),
              PpStep('Talk about the day', '"What made you happy? What was '
                  'hard?"'),
              PpStep('Help someone together', 'Carrying something for '
                  'grandparents, sharing food.'),
            ]),
            PpCallout('Children under three don’t need classes or playdates to '
                'learn social skills. Loving, chatty time with family and the '
                'children nearby is exactly what helps. An active '
                'family, walking, playing and moving together, sets habits for '
                'life.'),
          ],
        ),
      ],
    ),

    PpArea(
      id: 'speech_language',
      mark: IntentMark.questionMark,
      title: 'Talking and understanding',
      blurb: 'Month by month ranges, two or three languages at home, and how '
          'to help.',
      hue: 300,
      pages: [
        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_speech_by_age',
          title: 'What talking looks like, month by month',
          subtitle: 'Six months to three years, as ranges',
          format: 'CHART',
          bands: _all,
          blocks: [
            PpIntro('Read these as windows. Every row has children at both '
                'ends of it who are doing perfectly well, and understanding '
                'always runs ahead of speaking.'),
            PpChartCard(
              title: '6 to 12 months',
              subtitle: 'Sounds, then sounds that mean something',
              rows: [
                ('Babbles strings of sounds', 'By about 9 months'),
                ('Turns when you call the name', 'By about 12 months'),
                ('Understands "no" and "come"', 'About 9 to 12 months'),
                ('Copies sounds you make', 'About 8 to 12 months'),
                ('First word', 'About 10 to 15 months'),
              ],
              note: 'Babbling by 9 months is the row worth remembering here.',
              hue: 300,
            ),
            PpChartCard(
              title: '12 to 18 months',
              subtitle: 'A handful of words, and a lot of understanding',
              rows: [
                ('Words used consistently', 'About 3 to 20 by 18 months'),
                ('Follows a simple instruction', 'About 12 to 18 months'),
                ('Points at things in a book', 'About 12 to 18 months'),
                ('Names one or two body parts', 'About 15 to 20 months'),
              ],
              note: 'Some children have three words at 18 months and forty at '
                  '24. The jump is often sudden.',
              hue: 300,
            ),
            PpChartCard(
              title: '18 to 24 months',
              subtitle: 'Words start joining up',
              rows: [
                ('Vocabulary', 'About 20 to 100 plus words'),
                ('Two words together', 'About 18 to 24 months'),
                ('Follows two-step instructions', 'About 22 to 30 months'),
                ('How much a stranger understands', 'About half by 2 years'),
              ],
              note: 'Two words joined by about 2 years is the row worth '
                  'remembering.',
              hue: 300,
            ),
            PpChartCard(
              title: '2 to 3 years',
              subtitle: 'Sentences, questions, and being understood',
              rows: [
                ('Three to four word sentences', 'About 24 to 36 months'),
                ('Asks "what" and "where"', 'About 24 to 33 months'),
                ('Uses own name, then "I"', 'About 24 to 36 months'),
                ('How much a stranger understands', 'About three quarters by 3 '
                    'years'),
              ],
              note: 'Unclear speech at this age is common. Not being '
                  'understood at all by 3 years is worth a check.',
              hue: 300,
            ),
            PpCallout('Count what your child understands as carefully as what '
                'comes out. A child who follows instructions, finds named things '
                'and gets your jokes has language, whether or not it’s coming '
                'out yet.'),
            PpWhenLine('For a child born early, read these ranges from the due '
                'date, up to about two years.'),
            PpIndiaNote('If your home uses more than one language, add the '
                'words from all of them together to compare with these rows. '
                'Counting only the Hindi words, or only the English ones, '
                'makes a perfectly typical child look as if half the '
                'vocabulary is missing.'),
            PpVideoSlot(
              title: 'The normal range for talking, explained',
              subtitle: 'A speech and language therapist on why the windows '
                  'are this wide, and which lines matter.',
              minutes: '11 MIN',
              slotId: 'development/speech_normal_range',
              hue: 300,
            ),
            PpLink('Where your child is right now',
                surfaceId: 'pp_milestones',
                blurb: 'Language, alongside the other five areas of '
                    'growing.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_two_languages',
          title: 'Will two languages confuse my child?',
          format: 'ARTICLE',
          bands: _all,
          blocks: [
            PpIntro('No. Growing up with two or three languages doesn’t cause '
                'a speech delay, and it never has. This page is here because '
                'somebody has almost certainly told you otherwise.'),
            PpArticle([
              'The Indian home is usually multilingual by default. A mother '
                  'tongue with grandparents, Hindi or the state language '
                  'outside, English at playschool and on screens. Children '
                  'have grown up like this here for generations, and the '
                  'research on bilingual children is consistent: they reach '
                  'language milestones on the same timetable as everyone else.',
              'What does happen is that the words get spread across '
                  'languages. A twenty-month-old might have the home words for water and milk, then ball '
                  'and dada, one from each side of the household. Counted '
                  'separately, that looks like five words in one language. '
                  'Counted properly, which means added together, it’s a '
                  'normal vocabulary. Most families who worry about a '
                  'bilingual delay are counting only one language.',
              'Mixing languages inside a sentence isn’t confusion either. It’s '
                  'called code-switching, and adults in this country do it all '
                  'the time. A child who does it is using two systems, with '
                  'neither one muddled.',
              'The advice that does real harm is "drop the mother tongue and '
                  'speak only English at home". It usually means the person '
                  'speaking to the child most, often a grandmother, has to use '
                  'the language with the least fluency and the least warmth. The '
                  'child then hears poorer language, not richer. Speak to your '
                  'child in the language you feel most yourself in.',
            ]),
            PpCards([
              PpCard('Give each language a real place',
                  'One person, one language works, and so does one place or '
                      'one time. Consistency helps a child sort them, '
                      'though it isn’t compulsory.'),
              PpCard('Keep the grandparents’ language',
                  'It’s usually the warmest and the most fluent input in the '
                      'house, and it carries your child’s family with it.'),
              PpCard('Count all the languages together',
                  'When you compare with any milestone chart, add every '
                      'language up. This alone ends most bilingual worry.'),
              PpCard('Don’t correct the mixing',
                  'Answer the meaning. Correcting the choice of language '
                      'teaches a child to say less.'),
              PpCard('English will arrive anyway',
                  'It’s everywhere: school, screens, shops, cousins. It '
                      'almost never needs protecting at home.'),
            ], heading: 'What helps in a multilingual home', hue: 300),
            PpCallout('Two languages don’t cause a delay, and they don’t '
                'explain one away either. If the red flags on the next page are '
                'there, they’re worth checking whatever languages are spoken at '
                'home. Two languages are never a reason to wait out a real '
                'concern.'),
            PpWhenLine('Applies from birth. The vocabulary counting matters '
                'most between 18 months and 3 years, when families start '
                'comparing.'),
            PpIndiaNote('If a school or a well-meaning relative tells you to '
                'stop the mother tongue, you can decline politely. A child who '
                'grows up speaking a grandmother’s language stays close to '
                'family, and gains nothing at school by losing it.'),
            PpLink('Talking activities in your own languages',
                surfaceId: 'pp_activities',
                blurb: 'The language area, with things to try today.'),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_help_talk',
          title: 'How to help your child talk',
          format: 'STEP-LIST',
          bands: _all,
          blocks: [
            PpIntro('Everything that works is free, takes no preparation, and '
                'happens inside things you’re already doing. There’s nothing '
                'to buy on this page.'),
            PpSteps([
              PpStep('Narrate the day out loud', 'Say what you’re doing while you do it. "Now the '
                      'dal is going in." "Let’s wash this hand." Words tied '
                      'to what a child can see are the ones that stick.'),
              PpStep('Ask, then wait five seconds', 'Adults fill silences far too fast. Count to five '
                      'and let the answer come. This one change does more '
                      'than any other.'),
              PpStep('Answer babble like conversation', 'Your baby says bababa, you reply properly, then wait '
                      'for the next turn. Taking turns is the shape of language '
                      'before there are words in it.'),
              PpStep('Add one word to whatever your child says', 'Your child says "car", you say "big car" or "the car '
                      'is here". One small step further, and never a '
                      'correction.'),
              PpStep('Give the word instead of the quiz', 'Say "yes, that’s a bus" rather than "what is '
                      'that?" Testing makes children go quiet. Naming invites '
                      'them in.'),
              PpStep('Read together every day, badly is fine', 'Let your child turn pages, skip, and repeat the same book '
                      'for a month. Talking about the picture matters more '
                      'than reading the sentence.'),
              PpStep('Sing the same songs again and again', 'Lullabies, rhymes, a film song with a chorus. Rhythm '
                      'and repetition are how sounds get learned, and pausing '
                      'before the last word is an invitation to fill it in.'),
              PpStep('Turn the background noise down', 'A television running all day makes it harder for a '
                      'child to pick your voice out. Quiet rooms help more '
                      'than any app does.'),
              PpStep('Give your child a reason to ask', 'Put a favourite thing in sight but out of reach, or '
                      'hand over the closed box. A little friction is an '
                      'invitation to communicate.'),
            ]),
            PpCallout('If you only change one thing, change the waiting. Ask, '
                'then stay quiet for five seconds. Most children fill that '
                'gap, and most adults never leave it.'),
            PpWhenLine('All of this works from the first months. The waiting '
                'and the adding one word matter most from about 9 months to 3 '
                'years.'),
            PpIndiaNote('Everyone in the house counts as input, and different '
                'voices in different languages is a good thing rather than a '
                'confusing one. Sing the loris you know, in the language you '
                'know them in, rather than switching to English rhymes because '
                'those seem more educational.'),
            PpLink('Talking activities for your child’s age',
                surfaceId: 'pp_activities',
                blurb: 'The language area, with things to try today.'),
            PpLink('Books to read together',
                surfaceId: 'pp_read',
                blurb: 'Reading picks in ParentVeda Learn.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpCards(heading: 'Baby signs', [
              PpCard('What they are', 'Simple hand signs, like more, milk, all '
                  'done, that babies can use before they can speak.'),
              PpCard('Do they delay talking?', 'No. Used alongside words, they '
                  'can ease frustration, and they don’t slow speech.'),
              PpCard('How', 'Say the word and make the sign every time, from '
                  'about six to eight months.'),
            ]),
          ],
        ),

        // ---------------------------------------------------------------------
        PpPage(
          id: 'dev_speech_flags',
          title: 'When talking is worth checking',
          subtitle: 'The honest lines, by age',
          format: 'FLAGGED CALLOUT',
          bands: _all,
          blocks: [
            PpIntro('Talking that takes its time usually needs nothing but time, and '
                'most children who start slowly catch up. A few specific things '
                'are still worth checking properly, and checking early helps.'),
            PpArticle([
              'Two things before the list. First, ask for a hearing test at '
                  'the same visit, every single time. Reduced hearing, often '
                  'from fluid after repeated colds and ear infections, is the '
                  'commonest reason a child is slow to talk. It’s very '
                  'treatable, and easy to miss at home: a child who hears some '
                  'things can look as though everything is heard.',
              'Second, none of these lines is a diagnosis of anything. They’re '
                  'reasons to get a proper look, nothing more. Most '
                  'families who go are told to carry on and come back in three '
                  'months.',
            ]),
            PpCallout(
              'Any age: if your child has lost words or sounds that used to '
                  'be there, or no longer responds to being called by name, '
                  'ring your paediatrician now. Don’t wait. Going backwards is '
                  'different from going slowly.',
              kind: PpCalloutKind.doctor,
              title: 'The line that never waits',
            ),
            PpCallout(
              'By about 9 months: not babbling strings of sounds like '
                  '"bababa", not making sounds back at you, and not turning '
                  'towards a voice or a loud noise.',
              kind: PpCalloutKind.doctor,
              title: 'Around 9 months',
            ),
            PpCallout(
              'By about 12 to 15 months: no gestures at all, no waving or '
                  'pointing, no response to being called by name, and not '
                  'understanding simple everyday words.',
              kind: PpCalloutKind.doctor,
              title: 'Around 12 to 15 months',
            ),
            PpCallout(
              'By about 16 to 18 months: no single words at all, in any '
                  'language, counted together.',
              kind: PpCalloutKind.doctor,
              title: 'Around 18 months',
            ),
            PpCallout(
              'By about 2 years: not putting two words together, fewer than '
                  'about 50 words across all languages, or not following a '
                  'simple instruction without gestures to help.',
              kind: PpCalloutKind.doctor,
              title: 'Around 2 years',
            ),
            PpCallout(
              'By about 3 years: strangers can’t understand most of what your '
                  'child says, or short sentences aren’t being used. Or a bad '
                  'stammer has started, with visible struggle and '
                  'frustration.',
              kind: PpCalloutKind.doctor,
              title: 'Around 3 years',
            ),
            PpWhenLine('Bring these to a paediatrician first, and ask for a '
                'hearing test alongside. A speech therapist is the next step '
                'if one is needed.'),
            PpIndiaNote('Speech therapy is widely available in Indian cities '
                'and increasingly online, which matters for a family in a '
                'smaller town. Most of the work happens at home in your own '
                'languages, with the therapist coaching you rather than '
                'treating the child alone. And don’t let anyone tell you to '
                'wait because you speak two languages at home. That isn’t a '
                'reason.'),
            PpConsult(
              title: 'Talk to a speech and language therapist',
              whoFor: 'For a parent whose child has crossed one of the lines '
                  'above, or who has been told to "just wait" and isn’t '
                  'settled by that. You get an assessment in your own '
                  'languages, an honest answer about whether therapy is '
                  'needed, and things to do at home either way.',
              surfaceId: 'pp_experts',
              role: 'speech',
            ),
            PpLink('Something has changed in how my child talks',
                surfaceId: 'pp_what_changed',
                blurb: 'Work through babbling that has gone quiet, step by '
                    'step.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpArticle(heading: 'When the words are there but hard to say', [
              'Some children understand a lot and want to talk, but find it '
                  'hard to plan and make the mouth movements for words. Speech '
                  'is very hard to understand, words come out differently each '
                  'time, and the mouth may seem to search for the shape. This '
                  'can be a motor speech disorder, such as childhood apraxia of '
                  'speech.',
              'A speech therapist can assess this and help. It needs '
                  'specific, frequent therapy, so ask early.',
            ]),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  What changed? — the Development subset of the existing feature
    // =========================================================================
    /* ⚠️ REMOVED BY FEEDBACK, KEPT FOR REVERT.
       "Something About My Child Has Changed section — please delete, it is
       anyways there as tool."
       Correct: `PpSectionTool('Something has changed' → pp_what_changed)` at
       the foot of this file opens the same screen. The area and the tool were
       two doors on one page leading to one place, which is the same defect as
       the two nutrition doors and the two development activity links found
       earlier in this pass. The tool is the right survivor — What Changed is
       something you USE, not something you read.

    PpArea(
      id: 'something_changed',
      mark: IntentMark.blocksMark,
      title: 'Something has changed',
      blurb: 'A skill has gone quiet, or your child seems different. Work '
          'through it calmly.',
      hue: 128,
      pages: [
        PpPage(
          id: 'dev_what_changed',
          title: 'Something about my child has changed',
          format: 'CARDS',
          bands: _all,
          blocks: [
            PpIntro('A change is more useful information than a milestone '
                'date, and it usually has an ordinary explanation. Pick the '
                'one that sounds like your child and work through it.'),
            PpCards([
              PpCard('Babbling less than before',
                  'The sounds have gone quieter. Often a leap, a cold, or '
                      'attention going into a new physical skill, and '
                      'sometimes hearing. Worth working through properly.'),
              PpCard('Suddenly shy around new people',
                  'Clinging, hiding, crying at visitors. Usually stranger '
                      'awareness arriving on time, which is a developmental '
                      'step rather than a problem.'),
            ], heading: 'The changes families ask about most', hue: 128),
            PpCallout('A skill that has gone quiet for a week or two while '
                'another one is being learned is normal. A skill that has '
                'genuinely gone and not come back is worth a call.'),
            PpWhenLine('Use this whenever something changes, at any age. It '
                'takes two or three minutes.'),
            PpIndiaNote('Going shy around relatives is often read as the child '
                'being badtameez or spoilt, and it is neither. Between about '
                '6 and 18 months it is a normal step, and forcing a child into '
                'unfamiliar arms makes it last longer rather than shorter.'),
            PpLink('Work through what changed',
                surfaceId: 'pp_what_changed',
                blurb: 'A guided starting point, not a diagnosis. If '
                    'something worries you, always check with a doctor.'),
            PpLink('What is emerging for my child right now',
                surfaceId: 'pp_milestones',
                blurb: 'If the change is in sounds or words, start with the '
                    'language area.'),
          ],
        ),
      ],
    ),
    */

    // =========================================================================
    //  AGE BY AGE, 1 TO 5 — added 2026-10-02 from the parenting gap analysis
    // -------------------------------------------------------------------------
    //  theAsianparent runs a monthly checklist from 13 months to 4 years; all
    //  19 of its months were P1 gaps. Ours is ONE page per band, not one per
    //  month, for the reason this section was rebuilt: a monthly checklist is
    //  a monthly test. Each page is a table of windows ("most children,
    //  around") and the one column that matters ("worth a call if"), with
    //  `rowMonths` so her own row is highlighted and nothing asks her age.
    //
    //  ⚠️ NO TICK BOXES, NO COUNT. Same rule as the screener note at the foot
    //  of this file: a list she ticks becomes a score. These are read, never
    //  completed.
    //
    //  REQUIRED_REVIEW: the windows follow the 2022 CDC "Learn the Signs"
    //  milestones (which most children reach by the age named) and the IAP's
    //  developmental red flags. A developmental paediatrician to confirm.
    // =========================================================================
    PpArea(
      id: 'age_by_age',
      mark: IntentMark.checkMark,
      title: 'What most children do at this age',
      blurb: 'Windows from birth to five, and when it’s worth a call.',
      hue: 42,
      bands: ['dev_0_6', 'dev_6_12', 'dev_1_2', 'dev_2_3', 'dev_3_5'],
      pages: [
        PpPage(
          id: 'dev_age_1_2',
          title: 'From one to two: what most children do',
          subtitle: 'Walking, first words, and wanting to help',
          bands: ['dev_1_2'],
          format: 'CHART',
          blocks: [
            PpIntro('The second year is full of big changes: first steps, '
                'first words, and a strong will. Children get there at '
                'different paces. Here’s what most children are doing by each '
                'age, and the few things worth mentioning to your doctor.'),
            PpTable(
              columns: ['By about', 'Most children', 'Worth a call if'],
              rowMonths: [(12, 15), (15, 18), (18, 24)],
              rows: [
                [
                  '15 months',
                  'Takes a few steps. Says one or two words besides "ma" and '
                      '"dada". Points to ask for something. Shows you a toy. '
                      'Claps when excited.',
                  'No response to being called by name, no pointing or waving, '
                      'or not yet standing with support.',
                ],
                [
                  '18 months',
                  'Walks alone. Tries to say three or more words. '
                      'Follows a simple instruction like "give it to me". '
                      'Scribbles. Drinks from an open cup with some spills. '
                      'Eats finger food without help.',
                  'Not walking, no single words by 16 months, no copying '
                      'you, or not seeming to understand simple '
                      'words.',
                ],
                [
                  '2 years',
                  'Puts two words together, like "more milk". Points to '
                      'things in a book. Kicks a ball. Runs. Eats with a spoon. '
                      'Notices when you’re upset.',
                  'No two-word phrases, walking only on tiptoe or very '
                      'unsteadily, or no pretend play, like feeding a '
                      'doll.',
                ],
              ],
            ),
            PpCallout('If your child loses words or skills that were there '
                'before, at any age, tell your paediatrician soon. That’s '
                'always worth a check, and never something to wait out.',
                kind: PpCalloutKind.doctor),
            PpLink('Early signs of autism, and what to do if you wonder',
                surfaceId: 'pp_page/parenting_special_care/dev_autism_signs'),
            PpCards(heading: 'The rest of life at this age', [
              PpCard('Food',
                  'Family food, mashed or chopped small, three meals and two '
                      'snacks. Picky days are normal, so keep offering. Watch '
                      'for gagging that turns into choking.'),
              PpCard('Sleep',
                  'Around 11 to 14 hours in 24, often down to one nap by 18 '
                      'months.'),
              PpCard('Safety',
                  'Climbing starts now. Window grilles, balcony doors, buckets, '
                      'and anything that can tip.'),
              PpCard('Vaccines',
                  'Several boosters fall due in this year. Check the vaccine card.'),
            ]),
            PpLink('Keeping your child safe at home',
                surfaceId: 'pp_section/parenting_safety'),
            PpLink('Your child’s vaccine card', surfaceId: 'pp_vaccines'),
            PpIndiaNote('Children in homes with two or three languages often '
                'start speaking a little later, and catch up. Count words in '
                'every language together, not only one.'),
          ],
        ),
        PpPage(
          id: 'dev_age_2_3',
          title: 'From two to three: what most children do',
          subtitle: 'Sentences, pretend play, and big feelings',
          bands: ['dev_2_3'],
          format: 'CHART',
          blocks: [
            PpIntro('Between two and three, words turn into sentences and '
                'play turns into stories. Feelings get bigger too, and that '
                'is part of the same growth. Here’s what most children are '
                'doing, and when it’s worth a call.'),
            PpTable(
              columns: ['By about', 'Most children', 'Worth a call if'],
              rowMonths: [(24, 30), (30, 36)],
              rows: [
                [
                  '2 and a half',
                  'Uses around 50 words, and says things like "I go" or '
                      '"car is gone". Names things in a book. Jumps with both '
                      'feet. Plays simple pretend. Turns pages one by one.',
                  'Hard to understand even for you, not following '
                      'two-step instructions, or little interest in '
                      'other children.',
                ],
                [
                  '3 years',
                  'Has short back-and-forth conversations. Asks who, what, '
                      'where and why. Says own first name. Copies a circle. '
                      'Puts on loose clothes. Notices other children and joins '
                      'in.',
                  'Drooling a lot or very unclear speech, falling often or '
                      'not managing stairs, no eye contact, or not able '
                      'to hold a crayon.',
                ],
              ],
            ),
            PpCallout('Weight going down, refusing most food for days, '
                'vomiting after meals, head banging, or losing skills that '
                'were there: see your paediatrician soon.',
                kind: PpCalloutKind.doctor),
            PpCards(heading: 'The rest of life at this age', [
              PpCard('Food',
                  'Family food now, with less spice and salt. Appetite '
                      'swings from day to day, so look at the week, not the '
                      'meal.'),
              PpCard('Feelings',
                  'Tantrums peak now. They show a brain learning to manage '
                      'big feelings. They aren’t a sign of bad parenting.'),
              PpCard('Independence',
                  'Let your child help: putting toys away, carrying a plate. A '
                      'low shelf within reach makes it easy.'),
              PpCard('Potty',
                  'Many children start now, some later. Readiness matters more '
                      'than age.'),
            ]),
            PpLink('Talking, month by month',
                surfaceId: 'pp_page/parenting_development/dev_speech_by_age'),
          ],
        ),
        PpPage(
          id: 'dev_age_3_5',
          title: 'From three to five: what most children do',
          subtitle: 'Stories, questions and friendships',
          bands: ['dev_3_5'],
          format: 'CHART',
          blocks: [
            PpIntro('Three to five is the age of a thousand questions, best '
                'friends and long stories. Your child is getting ready for '
                'school in all the ways that matter, mostly through play. '
                'Here’s what most children are doing, and when it’s worth a call.'),
            PpTable(
              columns: ['By about', 'Most children', 'Worth a call if'],
              rowMonths: [(36, 42), (42, 48), (48, 60), (60, 72)],
              rows: [
                [
                  '3 and a half',
                  'Holds a crayon with fingers, not a fist. Does a simple '
                      'puzzle. Climbs stairs one foot per step. Plays with '
                      'other children, not only beside them.',
                  'Not able to jump, not following simple instructions, or '
                      'extremely clingy every time you leave.',
                ],
                [
                  '4 years',
                  'Speaks in sentences of four or more words. Tells you about '
                      'the day. Pretends to be someone else. Catches a large '
                      'ball. Draws a person with a head and a few body parts. '
                      'Comforts a friend who is hurt.',
                  'Speech still unclear to strangers, mixing up "me" '
                      'and "you", no pretend play, or not able to focus on '
                      'anything for five minutes.',
                ],
                [
                  '5 years',
                  'Tells a simple story with a beginning and end. Counts to '
                      'ten. Hops on one foot. Writes a few letters. Takes '
                      'turns in a game and follows its rules.',
                  'Very withdrawn or very aggressive with other '
                      'children, not able to get dressed alone, or losing skills that were there.',
                ],
                [
                  'After 5',
                  'Growing confidence, friendships, longer attention.',
                  'Anything at school worries the teacher or you. Ask early. '
                      'Early help works best.',
                ],
              ],
            ),
            PpCallout('Trouble seeing the board or hearing you, squinting, or '
                'turning the TV up loud: get eyes and ears checked. Your '
                'paediatrician can refer you.',
                kind: PpCalloutKind.doctor),
            PpCards(heading: 'The rest of life at this age', [
              PpCard('Food',
                  'A balanced plate over the day: cereal or roti, dal or an '
                      'egg, a vegetable, fruit, milk or curd, and water.'),
              PpCard('Hygiene',
                  'Hand washing before meals and after the toilet, brushing '
                      'twice a day with a pea-sized smear of toothpaste.'),
              PpCard('Safety',
                  'A helmet on the cycle, a booster seat in the car, and the '
                      'talk about safe touch and safe adults.'),
              PpCard('Vaccines',
                  'Boosters fall due between four and six. Check the vaccine card.'),
            ]),
            PpLink('Talking with your child about body safety and safe touch',
                surfaceId: 'pp_page/parenting_safety/safety_body_talk'),
          ],
        ),
        // Added 2026-10-02 (P2): the first year, completing theAsianparent's
        // monthly checklists from birth. Same shape and rules as the pages
        // above: windows, never a score. REQUIRED_REVIEW as above.
        PpPage(
          id: 'dev_age_0_6',
          title: 'The first six months: what most babies do',
          subtitle: 'Smiles, head control, cooing and rolling',
          bands: ['dev_0_6'],
          format: 'CHART',
          blocks: [
            PpIntro('In the first six months your baby changes faster than at '
                'any other time. Every baby has a different pace. Here’s what '
                'most babies are doing by each age, and the few signs worth '
                'mentioning to your doctor.'),
            PpTable(
              columns: ['By about', 'Most babies', 'Worth a call if'],
              rowMonths: [(0, 1), (1, 2), (2, 4), (4, 6)],
              rows: [
                [
                  'The first weeks',
                  'Startles at loud sounds, roots and sucks, grips your finger, '
                      'looks at faces close up, calms to your voice.',
                  'Feeding very poorly, unusually floppy or stiff, or no '
                      'reaction to loud sounds.',
                ],
                [
                  '1 month',
                  'Lifts the head briefly during tummy time, follows a face '
                      'with the eyes, makes small throaty sounds.',
                  'Doesn’t seem to see or hear, or doesn’t move both arms '
                      'and legs.',
                ],
                [
                  '2 months',
                  'Smiles at you on purpose, coos, holds the head up during '
                      'tummy time, opens the hands.',
                  'No smiling at people, no response to loud sounds, or no '
                      'lifting the head at all during tummy time.',
                ],
                [
                  '4 months',
                  'Laughs and chuckles, holds the head steady, brings hands to '
                      'the mouth, pushes up on the arms, reaches for a toy.',
                  'No cooing or laughing, not holding toys, or not '
                      'pushing up on the arms.',
                ],
              ],
            ),
            PpCards(heading: 'The rest of life at this age', [
              PpCard('Feeding', 'Breast milk or formula only, on demand. No '
                  'water, honey or herbal drops (ghutti).'),
              PpCard('Sleep', '14 to 17 hours at first, settling to about 12 '
                  'to 16. On the back, every sleep.'),
              PpCard('Nappies', 'Six or more wet nappies a day is a good sign '
                  'your baby is getting enough.'),
              PpCard('Vaccines', 'At birth, 6, 10 and 14 weeks. Check the vaccine '
                  'card.'),
            ]),
            PpCallout('A fever of 38 C (100.4 F) or more in a baby under three '
                'months always needs a doctor the same day. Go even if your '
                'baby seems well.',
                kind: PpCalloutKind.doctor),
            PpLink('Your baby’s vaccine card', surfaceId: 'pp_vaccines'),
          ],
        ),
        PpPage(
          id: 'dev_age_6_12',
          title: 'Six to twelve months: what most babies do',
          subtitle: 'Sitting, babbling, crawling and first steps',
          bands: ['dev_6_12'],
          format: 'CHART',
          blocks: [
            PpIntro('The second half of the first year brings sitting, '
                'moving, babbling and, for many, first steps. Some babies '
                'skip crawling entirely, which is fine. Here’s what most '
                'babies are doing, and when it’s worth a call.'),
            PpTable(
              columns: ['By about', 'Most babies', 'Worth a call if'],
              rowMonths: [(6, 9), (9, 12)],
              rows: [
                [
                  '6 months',
                  'Rolls both ways, sits with support, babbles, passes toys '
                      'hand to hand, knows familiar faces, shows interest in '
                      'food.',
                  'Not reaching for things, not rolling, or no response '
                      'to sounds or to being called by name.',
                ],
                [
                  '9 months',
                  'Sits alone, moves around by crawling or shuffling, says '
                      'sounds like mamama and bababa, looks for things you hide, '
                      'may be shy with strangers.',
                  'Not sitting without support, no babbling, no response '
                      'to being called by name, or not looking where you point.',
                ],
                [
                  '12 months',
                  'Pulls to stand and cruises, picks up small things with '
                      'finger and thumb, waves bye-bye, says "ma" or "dada" with '
                      'meaning, points.',
                  'Not standing with support, no pointing or waving, or '
                      'a skill that was there has been lost.',
                ],
              ],
            ),
            PpCards(heading: 'The rest of life at this age', [
              PpCard('Feeding', 'Solids from about six months, two then three '
                  'meals a day, with milk. Common allergens early.'),
              PpCard('Sleep', 'About 12 to 15 hours in 24, usually two naps.'),
              PpCard('Safety', 'Babyproof before crawling starts: gates, socket '
                  'covers, small things off the floor.'),
              PpCard('Vaccines', 'MMR at about nine months. Check the vaccine card.'),
            ]),
            PpCallout('If your baby loses sounds or skills that were there '
                'before, at any age, tell your paediatrician soon.',
                kind: PpCalloutKind.doctor),
            PpLink('Keeping your child safe at home',
                surfaceId: 'pp_section/parenting_safety'),
          ],
        ),

      ],
    ),
  ],
  tools: [
    // ⚠️ FIRST TOOL, BECAUSE IT IS THE SECTION'S OWN QUESTION. "Is my child
    // on track?" is the title of the first area and the thing a parent came to
    // find out; it was answered by four articles about why the question is
    // hard. The articles are still there and still worth reading — this just
    // stops them being the only answer.
    // ⚠️ MERGED. "There are two milestone screens that show the same list
    // two ways. Make it one." The Development journey absorbed the
    // "usually settled by now" group, and `pp_on_track` now opens it too.
    // Kept for revert.
    // PpSectionTool(
    //   label: 'What is emerging for my child right now',
    //   blurb: 'Every milestone as a window, never a checklist and never a '
    //       'score.',
    //   surfaceId: 'pp_milestones',
    // ),
    PpSectionTool(
      label: 'Where your child is right now',
      blurb: 'Usually settled by now, emerging now, and a soft look ahead. '
          'Windows, never a score.',
      surfaceId: 'pp_milestones',
      icon: Icons.checklist_rtl_outlined,
    ),
    PpSectionTool(
      label: 'Things to do together today',
      blurb: 'Activities matched to your child’s age and to each area of '
          'growing.',
      surfaceId: 'pp_development',
    ),
    PpSectionTool(
      label: 'Your baby’s phase calendar',
      blurb: 'Which window is open now, held as a helpful lens rather than a '
          'law.',
      surfaceId: 'pp_leaps',
    ),
    PpSectionTool(
      label: 'Something has changed',
      blurb: 'Babbling gone quiet, suddenly shy. Work through it calmly.',
      surfaceId: 'pp_what_changed',
    ),
  ],
);

// =============================================================================
//  ⚠️ THE DEVELOPMENT SCREENER IS DELIBERATELY NOT BUILT
// -----------------------------------------------------------------------------
//  The spec names it and then answers its own question: "default to NOT building
//  it until confirmed, given the anxiety risk", and it is flagged for Ishaan and
//  Deepti to decide. So there is no screener tool above, and that absence is a
//  decision rather than an omission.
//
//  The reasoning is worth keeping, because the request will come back. A
//  screener is a small number of questions that produces an outcome, and the
//  outcome is the whole problem. Any screener has to land somewhere, and every
//  landing place we could build carries a cost:
//
//  * "Everything looks on track" is a reassurance we are not qualified to give,
//    on the strength of eight taps. If it is wrong, we have actively delayed a
//    family, which is the worst outcome this section can produce.
//  * "Worth a chat with an expert" is the only honest alternative, and if it is
//    the only outcome then the questions are decoration and the tool is a lead
//    form wearing a clinical face.
//  * Anything in between is a score, and a score on a milestone screen is
//    precisely the comparison-anxiety machine this section was rebuilt to stop
//    being.
//
//  The content above does the screener's real job without the outcome: the
//  per-domain flags on `dev_worth_checking` and the per-age flags on
//  `dev_speech_flags` let a parent recognise their own child in a specific line
//  and take it to a specific person. That is a triage that does not need us to
//  render a verdict.
//
//  If it is later confirmed, the constraint to hold is that it must never
//  produce a number, and its "worth a chat" arm must be reachable from a single
//  answer rather than needing a total. A screener that adds up is a score.
// =============================================================================
