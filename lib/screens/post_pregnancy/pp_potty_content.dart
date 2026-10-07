// =============================================================================
//  Toilet learning (potty) — the section's content
// -----------------------------------------------------------------------------
//  Built from docs/../pp_specs/06-potty-training.md. Seven areas, no tools.
//
//  ⚠️ THIS SECTION IS A REFRAME, NOT A TRANSLATION. The spec is explicit and it
//  is a cultural fact rather than a preference: "this is toilet learning the
//  Indian way. Lead with elimination communication / su-su cueing", NOT the
//  Western "potty training at 2 to 3 with a 3-day blitz" model. So the su-su cue
//  is the frame and the first thing on screen; the 3-day method appears once, in
//  a comparison table, as one option a family may pick. It is never the default
//  and it is never the thing a parent is measured against.
//
//  ⚠️ AND THE REFRAME COMES WITH AN HONESTY DEBT. Leading with su-su means the
//  section could very easily oversell it, which the spec forbids by name: "EC /
//  su-su is communication and fewer diapers, NOT independent toileting; a young
//  baby held over a potty is not trained. Independence usually is not solid till
//  around 3. Night dryness lags day dryness by months or years." That is why the
//  first page in the section is the honest timeline chart and it shows in every
//  band. A parent who reads only one page should come away with the true shape,
//  not with "trained by six months".
//
//  ⚠️ NO SHAME, ANYWHERE, FOR ANYONE. Not for the child who wet the bed at five,
//  not for the mother whose two-year-old still wears a diaper, not for the
//  grandmother who has been catching su-su since week three, and not for the
//  family that uses disposables and always will. The spec asks for both families
//  to be right, so both are.
//
//  ⚠️ NO SCOREKEEPING. The potty routine chart is described as a technique a
//  family can draw on paper, because that is what it is in a real house. The APP
//  does not keep a streak, a star count or a "days dry" number. A number that can
//  go down turns an ordinary accident into a loss, and the one thing this subject
//  cannot afford is a child who feels she has failed.
//
//  ⚠️ TOOLS ARE notApplicable HERE and so there are none. `tools:` is left empty
//  deliberately rather than filled with something plausible.
//
//  ⚠️ COMMERCE NEVER SITS ON A HEALTH-FLAG PAGE. Withholding, constipation and
//  bedwetting carry a doctor callout and the light consult, and no product link
//  at all. Selling a training pant beside "her poo is painful" is the exact thing
//  the spec forbids.
//
//  ⚠️ ENGLISH ONLY FOR NOW. Plain `String`, per the shared decision at the foot
//  of pp_content.dart.
// =============================================================================

import 'pp_age_bands.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// =============================================================================
//  THE BANDS
// -----------------------------------------------------------------------------
//  ⚠️ ITS OWN BAND SET, NOT `kPpChildBands`, AND THE REASON IS THE SUBJECT.
//  Toilet learning has exactly three chapters and they do not line up with the
//  four development bands. `kPpChildBands` would split the training year in half
//  at 24 months, putting "readiness signs" and "accidents are normal" in
//  different bands when they are the same conversation three weeks apart. And it
//  would give a 1-year-old parent an empty band, because nothing real happens
//  between 12 and 18 months that is not either su-su or readiness.
//
//  The boundaries, and why each is where it is:
//    0 to 12m   su-su cueing. Communication, not training.
//    12 to 36m  toilet learning proper. Readiness through to mostly-dry days.
//    36 to 72m  staying dry, nights, wiping, school and public toilets.
//
//  Inclusive lower, exclusive upper, per `PpBand`. A 36-month-old is in the
//  night-dryness band, which is correct: that is exactly when it starts being
//  her question.
// =============================================================================

const PpBandSet kPpPottyBands = PpBandSet([
  PpBand(
    id: 'su_su',
    label: 'Baby, 0 to 12 months',
    fromMonths: 0,
    toMonths: 12,
    blurb: "The wee cue. Learning your baby's timing, and fewer nappies to wash.",
  ),
  PpBand(
    id: 'learning',
    label: '1 to 3 years',
    fromMonths: 12,
    toMonths: 36,
    blurb: "Learning to use the potty, at your child's pace, with accidents along the way.",
  ),
  PpBand(
    id: 'dry',
    label: '3 to 6 years',
    fromMonths: 36,
    toMonths: 72,
    blurb: 'Dry nights, wiping without help, and managing a toilet away from home.',
  ),
]);

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpPottySection = PpSection(
  id: 'parenting_potty',
  title: 'Toilet learning',
  subtitle: 'The early cueing way, honestly told',
  // ⚠️ THE AGE RULE. "Drop the three buttons at the top (Baby / 1 to 3 /
  // 3 to 6) and open on where the child is now." The bands stay as the
  // scoping; the chooser is gone.
  autoScope: true,
  intro: 'In most Indian homes this starts long before any training does, with '
      'the wee cue and a grandmother who already knows the timing. Here is '
      'that path, and an honest look at how long each part takes.',
  bandSet: kPpPottyBands,
  areas: [
    // =========================================================================
    //  ACROSS ALL BANDS — the honest shape of the whole thing
    // -------------------------------------------------------------------------
    //  ⚠️ NO `bands:`, ON PURPOSE. This is the anti-overselling page and every
    //  parent needs it, including the one who has been cueing su-su since week
    //  three and has been told that means her baby is trained.
    // =========================================================================
    PpArea(
      id: 'the_real_shape',
  // ⚠️ PINNED ABOVE THE GRID. Feedback: "since 'how long does this actually
  // take' is a constant and like a tool, it should look different from other
  // articles." It is not one shelf among seven — it is the honest answer the
  // whole section is reframed around, and the thing a parent should read
  // before she picks a method. See `PpArea.pinned`.
  pinned: true,
      mark: IntentMark.listMark,
      title: 'How long does this really take?',
      blurb: 'The honest timeline, from the first caught wee to dry nights.',
      hue: 206,
      pages: [
        PpPage(
          id: 'honest_timeline',
          title: 'How long this actually takes',
          subtitle: 'One chart, and no rushing',
          format: 'CHART-CARD',
          blocks: [
        // ⚠️ ADDED IN THE S06 PASS — this area had no video, and the
        // feedback asks that video, tools and expert booking all get the
        // treatment the earlier sections got.
        PpVideoSlot(
          title: 'How long this really takes',
          subtitle: 'A paediatrician on the honest timeline, and why "trained by six months" means something different from what it sounds like.',
          minutes: '5 MIN',
          slotId: 'potty/real_timeline',
        ),
            PpIntro("Toilet learning isn't one event you get through in a "
                "weekend. It's a long, slow conversation. It starts with you "
                'reading your baby\'s signals and ends, years later, with your '
                'child going alone. Here is the real shape of it.'),
            PpChartCard(
              title: 'What usually happens, and roughly when',
              subtitle: 'Wide ranges, on purpose',
              rows: [
                ('Wee cueing can begin', 'From a few weeks old'),
                ('Tells you after going', 'About 18 to 24 months'),
                ('Tells you just before', 'About 2 to 3 years'),
                ('Mostly dry days, with accidents', 'About 2.5 to 3 years'),
                ('Goes alone, start to finish', 'About 3 years, often later'),
                ('Dry most nights', 'Anywhere from 3 to 6 years'),
              ],
              note: 'Getting there at four is well within the normal range. '
                  'Boys often take a little longer than girls, and that is '
                  'fine too.',
            ),
            PpCallout(
              "Wee cueing is you learning your baby's timing. Toilet "
              'learning is your child learning to feel it. Both are worth '
              "doing, in that order, and the first doesn't replace the second.",
            ),
            PpCallout(
              "A baby held over a basin at six months isn't potty trained. "
              'Your baby is being caught, which is useful and means far fewer '
              'wet nappies. Going alone is a different skill. It needs '
              'speech, bladder control and the ability to wait, and none '
              'of those arrive before about two.',
              kind: PpCalloutKind.myth,
              title: 'Nobody is trained at six months',
            ),
            PpWhenLine('Useful at any age. Worth re-reading on the day '
                'somebody compares your child with another.'),
            PpIndiaNote('If your mother or mother-in-law started cueing wees '
                "with her own babies at three weeks, she isn't wrong or "
                'exaggerating. That method works. It does something a little '
                'different from what a training chart measures, and both of '
                'those things are real.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  BAND A — 0 to 12 months. Su-su cueing.
    // =========================================================================
    PpArea(
      id: 'su_su_way',
      mark: IntentMark.seatMark,
      title: 'Catching the wee early',
      blurb: 'The cue method your family already knows, done gently.',
      hue: 152,
      bands: ['su_su'],
      pages: [
        PpPage(
          id: 'what_is_su_su',
          title: 'What is wee cueing?',
          subtitle: 'Communication first, diapers second',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Wee cueing is easy to learn. When your baby is about to '
                'go, you hold a supported squat over a potty or basin and make '
                'a soft "sss" or "su-su" sound. Over weeks, the sound and the '
                'position start to go together.'),
            PpArticle(
              heading: 'Why it works',
              [
                "A newborn doesn't wee at random. Most babies go soon after a "
                    'feed, soon after waking, and often at the same points in '
                    'the day. They also give small signs first. Cueing works '
                    'because it joins two things a baby can already do: a '
                    'predictable rhythm and a clear signal. Nothing brand new '
                    'has to be taught.',
                "The sound matters most. It doesn't have to be \"su-su\", "
                    "though that's the word most Indian families use, and "
                    "there's no reason to change it. What matters is that it's "
                    'always the same sound, made at the same moment, by '
                    'everyone in the house.',
                'This is what the elders in your family mean when they say a '
                    'baby can be trained early. What they describe is real. '
                    "It's closer to a shared language than to training.",
              ],
            ),
            PpSteps(
              heading: 'How families do it',
              [
                PpStep('Pick two easy windows to start', 'First thing after waking, and about ten to '
                        'twenty minutes after a feed. Those are the times you '
                        "are most likely to be right."),
                PpStep('Hold your baby in a supported squat', 'Back against your chest, your hands under the '
                        'thighs, knees drawn up. Over a small basin, a potty, '
                        'or the bathroom floor. The whole body feels held, '
                        'never dangling.'),
                PpStep('Make the sound, softly, and wait', 'A soft "sssss". Wait less than a minute. If '
                        "nothing comes, that's fine. Put your baby down."),
                PpStep('Say the same thing when it happens', 'A calm "sss" as it happens. That is the whole '
                        'lesson. No clapping, no fuss.'),
                PpStep('Tell everyone the same sound', 'Grandmothers, the helper, the father. One sound, '
                        'one word, or your baby is learning three languages at once.'),
              ],
            ),
            PpCallout(
              "This isn't training, and it isn't meant to be. What you get is "
              'fewer wet nappies, more diaper-free time, and a baby whose '
              'signals you can read. Bladder control comes years later, '
              'and nothing here speeds that up.',
              title: 'What wee cueing gives you, honestly',
            ),
            PpCards(
              heading: 'When to stop for the day',
              hue: 152,
              [
                PpCard('Your baby arches or cries in the position',
                    "That's a no. Stop and try another time. A baby who "
                    'learns to dread the hold will stop signalling '
                    'altogether.'),
                PpCard("You've been holding for minutes",
                    'Long holds are hard on little hips, and on yours. Under '
                    'a minute, then stop.'),
                PpCard('Your baby is unwell, or teething badly',
                    'The rhythm goes off during an illness. Pause without '
                    'guilt and pick it up in a calmer week.'),
                PpCard("You're exhausted",
                    'This is a nice-to-have, not a duty. A week off costs '
                    'nothing at all.'),
              ],
            ),
            PpWhenLine('Any time from a few weeks old. Most families find it '
                'easiest between 3 and 9 months, before crawling away '
                'mid-hold begins.'),
            PpIndiaNote('In a joint family this is often easier, not harder. '
                'More arms means more chances to catch the moment, and someone '
                'in the house has almost certainly done it before. Agree on '
                'the sound early. Read next in this area: '
                'how to read your baby\'s signals.'),
            PpVideoSlot(
              title: 'Cue-based holding, shown properly',
              subtitle: 'A supported squat, the "sss" sound, and the moments '
                  'to try. Filmed with a grandmother who has done this for '
                  'four babies.',
              minutes: '5 MIN',
              slotId: 'potty/su_su_cue_demo',
            ),
          ],
        ),
        PpPage(
          id: 'reading_signals',
          title: 'How to read your baby\'s signals',
          subtitle: 'Your baby tells you, quietly.',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Almost every baby gives a small sign before going. It '
                "is easy to miss because it's subtle and lasts a few "
                "seconds. Once you've seen it two or three times, you'll "
                'keep seeing it.'),
            PpArticle(
              heading: 'Why the signs are there at all',
              [
                'A full bladder or a moving bowel is a strange feeling, and '
                    'babies respond to strange feelings with the whole body. '
                    "Your baby isn't trying to tell you anything yet. It's a "
                    "reaction, and you're reading it.",
                'This is also why the signs change. What a baby does at two '
                    "months isn't what happens at eight. Expect to relearn "
                    'the signs a few times.',
              ],
            ),
            PpCards(
              heading: 'The signs to watch for',
              hue: 152,
              [
                PpCard('Going suddenly still',
                    'Mid-play, mid-feed, a small pause. The most common sign '
                    'and the easiest to miss.'),
                PpCard('A change in the face',
                    'A frown, a faraway look, a red face for a poo. Often the '
                    'clearest one.'),
                PpCard('Squirming and kicking',
                    'Restless legs, arching, twisting away from the breast '
                    'before the feed is finished.'),
                PpCard('A particular fuss or grunt',
                    'Not the hungry cry, not the tired cry. Most parents can '
                    'name it within a month even if they cannot describe it.'),
                PpCard('Waking from a nap and not settling',
                    'A very reliable one. Many babies wake because they need '
                    'to go, not because the nap is over.'),
              ],
            ),
            PpSteps(
              heading: 'What to do when you see it',
              [
                PpStep('Move without hurrying', 'Rushing and gasping makes it feel like an '
                        'emergency. Walk over calmly.'),
                PpStep('Settle into the squat and make the sound', 'Same position, same "sssss", every time.'),
                PpStep('Give it thirty to sixty seconds', 'That is long enough. If it was the right moment '
                        'it usually happens quickly.'),
                PpStep('If nothing comes, stop cheerfully', 'You read it wrong, or the moment passed. '
                        "Neither is a failure, and your baby needn't feel one."),
                PpStep('Notice what you missed, later', 'If the nappy is wet five minutes later, '
                        'think back to what happened just before. That is the '
                        'sign for next time.'),
              ],
            ),
            PpCards(
              heading: 'What not to do',
              hue: 32,
              [
                PpCard('Do not force the position',
                    "Stiffening or pushing back means it's over. Holding on "
                    'through it is the fastest way to lose cooperation.'),
                PpCard('Do not hold your baby there waiting',
                    'Three minutes over a basin is uncomfortable and teaches '
                    'nothing. Under a minute.'),
                PpCard('Do not chase every single wee',
                    'Aiming to catch them all makes the day miserable and the '
                    'method feel like failure. Two or three a day is a fine '
                    'place to live.'),
                PpCard('Do not show disappointment when you miss',
                    'A baby reads your face long before your words. A missed '
                    "catch is your miss, not your baby's, and neither of you "
                    'needs to carry it.'),
              ],
            ),
            PpCallout(
              "Some days there's no signal at all, and some babies never "
              "give an obvious one. That's a fact about your baby, not a "
              'verdict on you. Timing after feeds and naps works even when you '
              "can't read a thing.",
              title: "When it's just not the moment",
            ),
            PpCallout(
              'Ask a doctor if your baby seems to strain or cry when passing '
              'urine. Ask too if the nappies are suddenly much drier than '
              "usual for a day, or there's a smell or colour that worries you. "
              'These are quick to check, and worth checking rather than watching.',
              kind: PpCalloutKind.doctor,
              title: 'When to ask a doctor instead',
            ),
            PpWhenLine('From birth onwards. The signals get easier to read from '
                'about 2 months, and harder again once your baby is on the move.'),
          ],
        ),
        PpPage(
          id: 'grandmother_and_diapers',
          title: 'The grandmother method and diapers, together',
          subtitle: 'Both sides of this argument are right',
          format: 'ARTICLE',
          blocks: [
            PpIntro('This is one of the most common unspoken arguments in an '
                'Indian home with a new baby. Grandma started catching wees at '
                "three weeks. You're using disposables and going back to "
                'work. Neither of you is being careless.'),
            PpArticle(
              heading: 'What each side is protecting',
              [
                'The elders in your house grew up when a nappy was a cloth '
                    'that somebody washed by hand. A baby who was caught '
                    'reliably made less work and got fewer rashes. Cueing '
                    "wasn't a philosophy; it was how the house ran. When Grandma "
                    "says the baby can be trained now, she's remembering "
                    'something that worked.',
                "You're protecting your sleep, your job, a night feed at 3am "
                    'and the ability to leave the house without three changes '
                    "of clothes. A disposable nappy isn't laziness. It's a "
                    'real solution to problems the older method never had '
                    'to solve.',
                "The good news is that these two don't compete. Cueing "
                    "doesn't mean giving up nappies, and nappies don't stop "
                    'you cueing. Almost every family who does this well does '
                    'both, at different times of day.',
              ],
            ),
            PpSteps(
              heading: 'How to blend the two',
              [
                PpStep('Nappy on as the backup, not the plan', 'Your baby still wears one. You still offer the potty. '
                        'A catch means one less change, a miss means the '
                        'nappy did its job.'),
                PpStep('Cue at the easy times only', 'After waking, after feeds, before a bath. Give '
                        'the elders those windows and keep the nappy for '
                        'outings and nights.'),
                PpStep('Let whoever is holding the baby do the catching', "If Grandma is better at reading the signs, she's "
                        'better at it. That is a resource, not a comment on '
                        'you.'),
                PpStep('Agree the one sound out loud', 'Say it as a decision, at a calm moment, not '
                        'mid-catch. "We will all say sss." Done.'),
                PpStep('Name what you will not do', 'No long holds, no scolding, no sitting a baby on a '
                        'cold floor in winter. Boundaries are easier to hold '
                        "when they're stated once, kindly, in advance."),
              ],
            ),
            PpScript(
              heading: 'Words that keep the peace',
              [
                PpScriptLine(
                  say: 'You are much better at spotting it than me. Will you '
                      'do the after-nap one?',
                  notThis: 'Doctors say that does not work any more.',
                  why: 'It does work, and dismissing it turns a helper into an '
                      "opponent. Handing over the part she's good at ends the "
                      'argument faster than any fact.',
                ),
                PpScriptLine(
                  say: 'We will keep the nappy for the night. I cannot do the '
                      'washing on this much sleep.',
                  notThis: 'Nappies are just easier, leave it.',
                  why: 'A reason she can sympathise with lands. "Leave it" '
                      'sounds like the subject is closed and guarantees it '
                      'comes back tomorrow.',
                ),
                PpScriptLine(
                  say: 'Nothing this time. Let us try after the next feed.',
                  notThis: 'See, it did not work.',
                  why: 'A miss is a miss for both of you. Scoring points off '
                      'it in front of the baby teaches that the potty is where '
                      'the tension lives.',
                ),
              ],
            ),
            PpCallout(
              'There is no better mother here. One family catches wees from '
              'week three; another starts at two and a half. Both end up with '
              'a child who uses the toilet. The route is a household choice, '
              'and either one is fine.',
            ),
            PpIndiaNote('If the disagreement is really about the washing, say '
                'so. Many nappy arguments are about workload underneath. They '
                'get solved by deciding who does the buckets, not by anybody '
                'being right about babies.'),
            PpWhenLine('Worth reading in the first few months, before the '
                'positions harden.'),
          ],
        ),
        PpPage(
          id: 'diaper_free_time',
          title: 'Diaper-free time, and less rash',
          subtitle: 'The one benefit that is not in dispute',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('Whatever you think about cueing, more time out of a nappy '
                "is good for your baby's skin. This is the least disputed thing in "
                'the whole section.'),
            PpArticle([
              'Nappy rash is mostly caused by three things together: warmth, '
                  'moisture and rubbing. Time with nothing on removes all '
                  'three at once, which is why an hour of bare-bottom floor '
                  'time often does more than a second layer of cream. In '
                  'Indian summers, when a nappy sits against skin in real '
                  'heat, that matters more than it does in a cold country.',
              'Parents who do diaper-free time also tend to notice their '
                  'baby\'s bowel rhythm, because it is impossible not '
                  'to. That is the practical link between this and '
                  "wee cueing. Nothing clever is happening; you're "
                  'just watching.',
              'You will get puddles. Plan for the floor, not for the '
                  'catching.',
            ]),
            PpSteps(
              heading: 'How to make it easy',
              [
                PpStep('Pick the warm part of the day', 'Late morning, after a bath, on a mat. Not in a '
                        'cold room and not in a north Indian winter without '
                        'heating.'),
                PpStep('One washable mat or a folded old bedsheet', 'A waterproof mat under a cotton sheet is the '
                        'usual setup. Cheap, and it saves the mattress.'),
                PpStep('Start with fifteen minutes', 'Build up to an hour or two across the day. It '
                        'does not have to be one long stretch.'),
                PpStep('Keep the potty in the room', 'If you happen to catch one, good. If not, the '
                        'skin still got its air.'),
                PpStep('Mop with plain water and move on', 'No reaction, no comment. A puddle is never '
                        'an event.'),
              ],
            ),
            PpCallout(
              'Ask a doctor about a rash that is bright red with small spots '
              'at the edges. That pattern is often a yeast rash, and it needs '
              'a different cream, not more of the same one. Ask too if a rash '
              "hasn't settled after a week of air and barrier cream.",
              kind: PpCalloutKind.doctor,
              title: 'When a rash needs more than air',
            ),
            PpWhenLine('From the first weeks. Easiest before crawling starts, and '
                'worth restarting every summer.'),
            PpIndiaNote('A soft cotton cloth nappy in the daytime is a '
                'good middle option, and it is what most Indian homes used '
                'before disposables. It breathes, it tells you immediately '
                'when it is wet, and it washes.'),
            // The rash grid lives in Health; the words above describe what
            // the pictures there show.
            PpLink('Which rash is this? The pictures',
                surfaceId: 'pp_page/parenting_health/skin_which_rash',
                blurb: 'Nappy rash, yeast rash and the rest, side by side.'),
            PpLink('Something new with the skin or tummy?',
                surfaceId: 'pp_what_changed',
                blurb: 'Nappy rash, and the tummy signs worth checking.'),
            PpLink('A potty, a basin and a floor mat',
                surfaceId: 'pp_products',
                blurb: 'What is worth buying now, and what can wait a year.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  BAND B — 1 to 3 years. Getting ready.
    // =========================================================================
    PpArea(
      id: 'getting_ready',
      // ⚠️ WIDENED TO 3 TO 6 (the brief's judgement call 1, the user's call
      // 2026-09-13): "age is a weak stand-in for potty stage. A 3 and a
      // half year old could be nowhere near ready." A late starter needs
      // the signs too.
      mark: IntentMark.schoolMark,
      title: 'Is your child ready yet?',
      blurb: "The real signs, and why there's no prize for early.",
      hue: 268,
      // bands: ['learning'], // widened, see the area note
      bands: ['learning', 'dry'],
      pages: [
        PpPage(
          id: 'readiness_signs',
          title: 'Signs your child is ready',
          subtitle: "And what it means when they aren't there",
          format: 'ARTICLE',
          blocks: [
            PpIntro("Readiness isn't an age. It's a small cluster of things "
                'happening around the same time, and when they do, this gets '
                "much easier. When they haven't, effort mostly buys "
                'you frustration.'),
            PpArticle(
              heading: "Why waiting isn't losing time",
              [
                'Using a toilet needs several separate skills to arrive '
                    'together: feeling a full bladder, holding it for a '
                    'minute, telling somebody, getting there, and managing '
                    'clothes. A child with four of those five can look like '
                    'a potty training failure while only missing one piece.',
                "Starting before the pieces are there doesn't build them "
                    'faster. It usually means weeks of accidents, a child who '
                    'starts refusing the potty, and a family that has to stop '
                    'and restart anyway. Families who wait for the signs '
                    'almost always finish sooner, even having started later.',
              ],
            ),
            PpCards(
              heading: 'The signs worth waiting for',
              hue: 268,
              [
                PpCard('Staying dry for two hours or more',
                    'Or waking dry from a nap. This is bladder capacity and '
                    "it can't be taught. It's the most useful sign of all."),
                PpCard('Telling you after going',
                    'Even just pulling at the nappy or saying "dirty". The '
                    'feeling and the event are now connected.'),
                PpCard('Telling you before',
                    "The one you're waiting for. Once this appears, the rest "
                    'is usually weeks, not months.'),
                PpCard('Interest in the bathroom',
                    'Follows you in, wants to flush, copies. Curiosity is '
                    'half of the motivation.'),
                PpCard('Pulling pants down without help',
                    'Roughly. It matters more than people expect, because a '
                    "child who can't undress won't make it in time."),
                PpCard('Following a two-step instruction',
                    '"Take your pants off and sit down." Without that, every '
                    'trip needs you.'),
              ],
            ),
            PpSteps(
              heading: 'What to do while you wait',
              [
                PpStep('Let your child see people use the toilet', 'The most effective preparation there is, and it '
                        'costs nothing. Indian homes are rarely private '
                        'enough for this to be a problem.'),
                PpStep('Name what is happening, plainly', 'One word for wee and one for poo, used by '
                        'everybody. Start using them now.'),
                PpStep('Put a potty in the bathroom and ignore it', 'Let it become furniture. A potty that has been '
                        'around for a month is far less strange than one that '
                        'appears on day one.'),
                PpStep('Keep up the diaper-free stretches', 'Bare-bottom time is when children notice what '
                        'their own bodies do.'),
                PpStep('Wait for two or three signs, not all six', 'Nobody has the full set. Two or three, steadily, '
                        'is a green light.'),
              ],
            ),
            PpCards(
              heading: 'What not to do',
              hue: 32,
              [
                PpCard('Do not start because of a birthday',
                    'Turning two is not a sign. Neither is a cousin who '
                    'managed it at eighteen months.'),
                PpCard('Do not start in a chaotic month',
                    'A move, a new baby, a hospital stay or a school start '
                    'will undo the work. Wait for a boring fortnight.'),
                PpCard('Do not start because playschool asked',
                    'Talk to them. Most will work with you. A deadline set by '
                    'somebody else is the worst reason to push a child.'),
                PpCard('Do not treat a stop as a defeat',
                    "If it's clearly not working, pausing for six weeks is a "
                    'good decision, not a failure. Say so out loud so your '
                    'child hears it that way too.'),
              ],
            ),
            PpCallout(
              'Even with every sign present, going alone from start to '
              "finish usually isn't solid until around three. Mostly-dry days "
              'with the occasional accident is the real finish line for a '
              "two-year-old, and it's a good one.",
              title: 'What "done" honestly looks like',
            ),
            PpWhenLine('Most families see the signs somewhere between 18 months '
                "and 3 years. Later is common, and it isn't a delay."),
            PpIndiaNote('Summer is the natural time to start in most of India. '
                'Fewer clothes, faster drying, and bare-bottom time is '
                'comfortable rather than cold. If you can choose the month, '
                'choose a warm one.'),
            PpVideoSlot(
              title: 'What readiness looks like in real life',
              subtitle: 'Three real toddlers, and which of the signs each one '
                  'is showing.',
              minutes: '6 MIN',
              slotId: 'potty/readiness_signs',
            ),
          ],
        ),
        PpPage(
          id: 'which_approach',
          title: 'Early cueing, child-led, or the three-day method',
          subtitle: 'Pick by your household, not by the internet',
          format: 'COMPARISON TABLE',
          blocks: [
            PpIntro('There are three approaches families in India really use. '
                "None of them is wrong. They suit very different houses, and "
                "the honest way to choose is by who's home and how your week "
                'looks.'),
            PpTable(
              heading: 'The three, side by side',
              columns: [
                'What matters',
                'Wee cueing',
                'Child-led',
                'Three-day method'
              ],
              rows: [
                [
                  'When it starts',
                  'A few weeks old, onwards',
                  'When the signs show, often 2 to 3 years',
                  'A chosen weekend, usually after 2 years'
                ],
                [
                  'Who does the work',
                  'The adults, for a long time',
                  "Mostly the child, at the child's pace",
                  'The adults, intensely, for 3 days'
                ],
                [
                  'What it needs from you',
                  'Attention daily, for months',
                  'Patience and a relaxed timeline',
                  'Two or three clear days at home'
                ],
                [
                  'Fits a joint family',
                  'Very well, more hands help',
                  'Well, nobody is on a clock',
                  'Only if everyone agrees to the plan'
                ],
                [
                  'Fits working parents',
                  'Hard alone, fine with a helper',
                  'Yes, it has no schedule',
                  'Yes, if you can take the days'
                ],
                [
                  'Accidents to expect',
                  'Many, they are just misses',
                  'Few, because the child led',
                  'A lot in week one, then fewer'
                ],
                [
                  'Honest limitation',
                  'Not the same as independence',
                  'Slower, and elders may push back',
                  'Often needs a second attempt'
                ],
                [
                  'Risk if you push it',
                  'Signalling stops',
                  'Almost none',
                  'Refusal and withholding'
                ],
              ],
            ),
            PpArticle(
              heading: 'How most Indian families end up doing it',
              [
                'In practice this is rarely a clean choice. The common path is '
                    'wee cueing in the first year, because somebody in the '
                    'house knows how. Then comes a long child-led stretch, and '
                    'a more focused fortnight one summer when your child is '
                    "clearly ready. That's three approaches in sequence, and "
                    'it works well.',
                'The three-day method is the one to be careful with. It '
                    'is real and it does work for some children. But it '
                    'assumes an adult can follow a toddler for three days, '
                    "in a house where pressure doesn't build. When it "
                    'goes wrong, it goes wrong in a specific way: the child '
                    'starts holding it in. That outcome is worth '
                    'avoiding, because it takes far longer to undo than '
                    'a slower start ever would.',
              ],
            ),
            PpCallout(
              'Whichever you pick, the deciding factor is your household, not '
              'the method. The best approach is the one the people in your '
              'house can keep up, consistently, without anybody getting '
              'angry.',
            ),
            PpWhenLine('Choose once you see two or three readiness '
                "signs. Re-choose freely if it isn't working."),
            PpIndiaNote('If a helper or a grandparent is with your child most of the '
                'day, the method has to be theirs too. A plan the person doing '
                "the hours didn't agree to isn't a plan."),
            PpLink('Short potty masterclass',
                surfaceId: 'pp_courses',
                blurb: 'A paid 40-minute walkthrough of one full fortnight, '
                    'step by step, if you would rather be shown than read. '
                    'Everything in this section stays free.'),
          ],
        ),
        // ⚠️ [NEW], a scaffold. "The section refuses reward charts
        // everywhere but never says why in one place. A short honest piece
        // gives a parent the words to hold the line when the whole family
        // is pushing stickers and sweets." Copy supplied, not generated.
        PpPage(
          id: 'no_star_charts',
          title: 'Why there are no star charts here',
          subtitle: 'The words for when the family is pushing stickers',
          format: 'SHORT ARTICLE',
          
          blocks: [
            // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
            // REQUIRED_REVIEW.
            PpIntro("You'll be told to use sticker charts and a sweet for every "
                "success. We don't suggest them. Here is why, in words you "
                'can use with the family.'),
            PpArticle([
              'A chart turns learning into a test. On a good day it works. On a '
                  'wet afternoon, the empty square is a visible failure on the '
                  'wall, and a child who is struggling feels worse. Sweets '
                  'handed out for each go teach that the toilet is a deal.',
              'What works better is warm, specific attention: "You felt it and '
                  'you went. Well done." Add a matter-of-fact response to '
                  'accidents. Children want to be big, and being noticed '
                  'being big is enough.',
            ]),
            PpCallout('Many families use sticker charts, and some children enjoy '
                'them. If you do, reward trying (sitting on the potty), not '
                'results. Never take stickers away, and stop if accidents '
                'start to upset your child.'),
            PpScript(heading: 'When the family is pushing', [
              PpScriptLine(
                  say: 'We are cheering our child on with hugs. Sweets and charts make '
                      'accidents feel like failing.',
                  why: 'Explains the why without arguing.'),
            ]),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  BAND B — how to actually do it
    // =========================================================================
    PpArea(
      id: 'how_to_do_it',
      // ⚠️ WIDENED TO 3 TO 6. "A late starter in the 3 to 6 band still
      // needs it." Every page here is about the how, not the age.
      mark: IntentMark.stepsMark,
      title: 'Starting out, day by day',
      blurb: 'The potty, the routine, the words, and the Indian toilet.',
      hue: 88,
      // bands: ['learning'], // widened, see the area note
      bands: ['learning', 'dry'],
      pages: [
        PpPage(
          id: 'introducing_potty',
          title: 'Introducing the potty',
          subtitle: 'The first week, slowly',
          format: 'STEP-LIST',
          blocks: [
            PpIntro("The goal of the first week isn't a single successful wee. "
                'It is that the potty becomes an ordinary, boring, friendly '
                'object your child is happy to sit on.'),
            PpSteps([
              PpStep('Bring it home and let your child explore it', 'Carrying it around, putting a toy in it, sitting on '
                      "it with the lid down. Don't correct any of that."),
              PpStep('Give it a name and a place', 'Same word, same corner of the bathroom, every '
                        'day. Predictability is doing most of the work here.'),
              PpStep('A fully clothed sit, once a day', 'A minute, no expectation, no watching for a reaction. '
                      'This step alone often takes three or four days, and it '
                      "isn't wasted time."),
              PpStep('Then a bare sit, at an easy moment', 'Right after a nappy comes off wet is ideal, '
                      'because the timing is already right.'),
              PpStep('Tip a wet nappy into it and name what happened', '"Wee goes here." A surprisingly effective step, '
                      'because it explains the point of the object.'),
              PpStep('Offer the flush, or the emptying', 'Being the one who deals with it turns the whole '
                      'thing from something done to your child into something '
                      'your child does.'),
              PpStep('Fold it into the day, and stop making it a lesson', 'Once sitting is easy and willing, move to the daily '
                      'routine. The introduction is over.'),
            ]),
            PpCallout(
              'If your child refuses to sit, stop and try again in a few days. '
              'Being held on a potty against your will is something a child '
              'remembers, and that is much harder to undo than a slow start.',
            ),
            PpWhenLine('The introduction takes about a week. Any time from '
                'about 18 months, once your child is interested.'),
            PpIndiaNote('A low plastic potty that lets the feet rest flat on '
                'the floor works better than a seat on the big toilet. It is '
                'also closer to the squat your child will use later anyway. '
                'Feet flat matters more than the design.'),
            PpLink('Which potty, and which seat',
                surfaceId: 'pp_product_guide',
                blurb: 'Compare the low potty, the toilet seat insert and the '
                    'Indian-style squat trainer before you spend.'),
          ],
        ),
        PpPage(
          id: 'daily_routine',
          title: 'The daily routine',
          subtitle: 'Five fixed moments beat asking all day',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Asking "do you need to go?" thirty times a day annoys '
                'everybody and teaches nothing. A handful of fixed moments, '
                'the same ones every day, does most of the work.'),
            PpSteps(
              heading: 'The five moments',
              [
                PpStep('As soon as your child wakes in the morning', 'The most reliable one of the day. Straight from '
                        'bed to potty, before anything else.'),
                PpStep('About twenty minutes after each meal', 'Eating moves the bowel. This is the moment most '
                        'poos are catchable.'),
                PpStep('After every nap', 'Same as the morning, smaller. Do it before play '
                        'takes over.'),
                PpStep('Before the bath', "Clothes are already off, so there's no "
                        'resistance to overcome. An easy win.'),
                PpStep('Last thing before bed', 'Part of the bedtime routine, alongside brushing '
                        'teeth. Not a special event.'),
              ],
            ),
            PpArticle(
              heading: 'Making it stick',
              [
                'Keep each sit short, about a minute or two. A long sit turns '
                    'into a battle, and children learn to resist the whole thing.',
                'Say the same sentence each time, in the same tone. "Potty '
                    'time, then we will read." It is no question and no '
                    "fight. It's just what happens next.",
                'Everyone in the house does the same five moments. If the '
                    'helper does three of them and Grandma does a different two, '
                    'your child learns that the rules depend on who is in '
                    'charge.',
                'Once your child starts telling you in between, drop the moments '
                    'that are no longer needed. The routine is scaffolding, '
                    'and it comes down in time.',
              ],
            ),
            PpCallout(
              'A calm "you did it" is plenty. Big celebrations, clapping and '
              'sweets make the potty high-stakes. Then a day with nothing to '
              'show feels, to your child, like letting you down.',
            ),
            PpWhenLine('Run the five moments for two to six weeks. Longer is '
                'completely normal.'),
            PpIndiaNote('Write the five moments on a paper and stick it in the '
                'bathroom. In a joint family with a helper, that one sheet is '
                'the difference between one routine and four.'),
            PpVideoSlot(
              title: 'A real potty routine, start to finish',
              subtitle: 'One family, one ordinary day, all five moments. '
                  'Including one accident, handled calmly.',
              minutes: '9 MIN',
              slotId: 'potty/routine_walkthrough',
            ),
          ],
        ),
        PpPage(
          id: 'words_and_cues',
          title: 'One word, whole house',
          subtitle: 'The cheapest thing you can get right',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('A toddler learning to ask for the toilet has to learn a '
                'word. If four adults use four different words, your child has '
                'to learn four, and will use none of them at the moment it '
                'matters.'),
            PpArticle([
              'Pick one word for wee and one for poo. Su-su and potty are what '
                  'most Indian families use, and they work perfectly well. '
                  'Which word matters less than everyone using it: grandparents, '
                  'the helper, the father and the playschool teacher.',
              "Say it every time, including when you're the one going and "
                  'when it lands in the nappy. Naming a miss out loud, '
                  'without disapproval, teaches that the word belongs to a '
                  'feeling rather than to a place.',
              'Avoid words that carry disgust. "Dirty", "yuck" and pulling a '
                  'face teach a child that the body is shameful. That is the '
                  'seed of both refusal and holding it in. It is a body '
                  'function, so keep your tone as flat as the one you use '
                  'for eating.',
              'When playschool starts, tell them your child\'s word on day one. '
                  'A child who asks for a wee and is not understood will '
                  'stop asking.',
            ]),
            PpScript(
              heading: 'The words themselves',
              [
                PpScriptLine(
                  say: 'Wee is coming? Let us go to the potty.',
                  notThis: 'Do you need to go? Are you sure? Really sure?',
                  why: 'One clear statement. Three questions in a row invites '
                      'a no and then makes you overrule it.',
                ),
                PpScriptLine(
                  say: 'The wee came in your pants. That happens. Let us change.',
                  notThis: 'Yuck, dirty. Why did you not tell me?',
                  why: 'Disgust and blame are what turn an accident into '
                      'something a child hides from you.',
                ),
                PpScriptLine(
                  say: 'You told me before it came. That was the hard part.',
                  notThis: 'Good girl. See, that was not so difficult.',
                  why: 'Naming what was done teaches. Praising who your child is '
                      'puts the whole self on the line at the next miss.',
                ),
              ],
            ),
            PpWhenLine('Agree the words before you start, from about 15 months. '
                "It's a five-minute conversation."),
            PpIndiaNote('If your home runs in two languages, pick the word from '
                'whichever one the person with your child most of the day '
                'speaks. The other one follows soon enough.'),
          ],
        ),
        PpPage(
          id: 'indian_toilet',
          title: 'The Indian toilet, and going out',
          subtitle: 'Squatting, travel, and other people\'s bathrooms',
          // ⚠️ [reformat: add a film]. "The squat, the balance, the bucket
          // and mug, front to back: this is a physical skill the page itself
          // calls 'the main event', and there is no film for it today. The
          // clearest missing video in the section." The mug and front-to-back
          // technique lives ONCE, here; the washing-and-wiping page points
          // at this film rather than repeating it.
          // format: 'ARTICLE',
          format: 'VIDEO',
          blocks: [
            PpVideoSlot(
              title: 'The squat, the mug, and front to back',
              subtitle: 'The supported squat with something to hold, the '
                  'bucket-and-mug technique, front to back, shown on a real '
                  'Indian toilet.',
              minutes: '6 MIN',
              slotId: 'potty/indian_toilet',
              hue: 160,
            ),
            PpIntro('Most children in India will use a squat toilet, a bucket '
                "and mug, and a bathroom that's nothing like the one at home. "
                "None of that is a complication to solve later. It's the main "
                'event.'),
            PpArticle(
              heading: 'Why squatting is worth teaching properly',
              [
                'A full squat with feet flat makes passing a stool easier, '
                    'which is why so many people find it more comfortable. '
                    'For a child learning, it also means the feet are '
                    'supported. Feet dangling in the air are one reason a '
                    "toddler can't relax on a Western toilet.",
                'A small child\'s balance over an Indian toilet is the real '
                    'difficulty, not the position itself. Your child needs '
                    'something to hold and an adult close by until steady. '
                    'That takes a few weeks of practice, not any '
                    'special skill.',
                'If your home has a Western toilet and you visit family who '
                    'have a squat one, practise before you travel rather than '
                    'on the first night away.',
              ],
            ),
            PpSteps(
              heading: 'Teaching the squat',
              [
                PpStep('Practise the position with clothes on, on the floor', 'Feet flat, knees out, bottom low. Most toddlers '
                        'can already do this better than adults can.'),
                PpStep('Offer something to hold', 'Your hands, a wall bar, the edge of a bucket '
                        'stand. Balance is the whole problem.'),
                PpStep('Stand close, every time, at first', 'A slip into an Indian toilet is frightening and '
                        'it can end the cooperation for weeks.'),
                PpStep('Teach the mug before the wiping', 'Left hand, water, then rinse. Start with you '
                        "pouring and your child's hand guided."),
                PpStep('Then the wash basin, properly, every single time', 'Soap and twenty seconds. This is the part that '
                        'keeps your child well.'),
              ],
            ),
            PpCards(
              heading: 'Away from home',
              hue: 88,
              [
                PpCard('Go before you leave, always',
                    'The most useful travel habit of all. It removes most of '
                    'the problem.'),
                PpCard('Carry a spare set and a bag',
                    'Two changes of clothes and a plastic bag. Planning for '
                    'an accident is what lets you stay calm during one.'),
                PpCard('Scout the bathroom on arrival',
                    'At a wedding, a relative\'s house, a restaurant. Knowing '
                "where it is saves the two minutes you won't have."),
                PpCard('A travel potty for long journeys',
                    'A folding potty or a lined one in the car is worth it '
                    'for train and road travel.'),
                PpCard('Public toilets can wait for later',
                    "It's fine to hold your child over a drain or use a corner "
                    'on a long journey. Nobody is grading you.'),
                PpCard('Expect a step backwards while travelling',
                    'New bathroom, new bed, no routine. It comes back within '
                    'a week of being home.'),
              ],
            ),
            PpCallout(
              "If your child won't poo while you're travelling, don't push "
              'it. Two days of holding on becomes a hard, painful stool, and '
              'then a child who is frightened of pooing at all. Water, fruit '
              'and a relaxed attitude are the whole plan.',
            ),
            PpWhenLine('Start the squat practice from about 2 years, alongside '
                'the potty. Before any long trip.'),
            PpIndiaNote('Bucket and mug washing is a skill for life, and '
                "it's easier to learn at three than later. "
                'Teach the left hand and the soap together, from the start.'),
            PpLink('A step stool, and a travel potty',
                surfaceId: 'pp_products',
                blurb: 'The two purchases that make Indian bathrooms and long '
                    'journeys easier.'),
          ],
        ),
        PpPage(
          id: 'boys_and_girls',
          title: 'Boys and girls, the small differences',
          subtitle: 'Less different than people say',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('There are two or three real practical differences, and a '
                "lot of talk that isn't useful. Here is the short version."),
            PpArticle([
              'Boys do, on average, get there a few months later than girls. '
                  "It's an average across thousands of children, and it says "
                  'nothing at all about your son. Plenty of boys manage it '
                  'before plenty of girls.',
              'Teach a boy sitting down first, for both. Standing to wee is a '
                  'separate skill with its own aim problem. Adding it on '
                  'day one usually leaves a child confused about which '
                  'thing is happening. Once sitting is easy, standing takes a '
                  'week, often taught fastest by an older cousin or the '
                  'father.',
              'For girls, wiping front to back is the one thing worth being '
                  'firm about. Getting it the other way round is a '
                  "common cause of urine infections. With a mug it's the same "
                  'rule: water and hand move front to back.',
              'For boys, a gentle reminder to point down before starting '
                  'saves a great deal of cleaning. If the foreskin is '
                  "tight, don't pull it back to clean. Wash the outside "
                  'only.',
            ]),
            PpCallout(
              'See a doctor if your child cries or strains when passing urine, '
              "or has a fever with no other cause. Go too if the urine smells "
              'strongly or looks cloudy, or if a child who was dry starts '
              'wetting suddenly. Urine infections are common, easy to test '
              'for, and easy to treat once found.',
              kind: PpCalloutKind.doctor,
              title: 'Signs of a urine infection',
            ),
            PpWhenLine('Relevant from about 2 years. Standing to wee usually '
                'somewhere between 3 and 4.'),
          ],
        ),
        // ⚠️ [NEW], two scaffolds. The three-day method is named on the
        // comparison table and taught nowhere (judgement call 2, the user's
        // call 2026-09-13: teach it, with the holding-it-in warning built
        // in). Pull-ups: "a very common question, one honest card."
        PpPage(
          id: 'three_day_method',
          title: 'The three-day method, done safely',
          subtitle: 'Who it suits, and the one risk to watch for',
          format: 'ARTICLE',
          
          blocks: [
            // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
            // REQUIRED_REVIEW.
            PpIntro('The three-day method is a fast, focused start: nappies off, '
                'a few days at home, and lots of trips to the potty. It suits '
                'some children well, if they are clearly ready and you go in '
                'relaxed.'),
            PpArticle(heading: 'Who it suits', [
              'It suits children showing clear readiness. They stay dry for a couple of '
                  'hours, tell you when they have done a poo, are interested in '
                  'the toilet, and can pull trousers up and down. Usually '
                  "over two and a half. It isn't for a child who isn't ready, "
                  'or for a household that is busy or stressed.',
            ]),
            PpSteps(heading: 'The shape of it', [
              PpStep('Day one: nappies off, at home', 'Watch closely. Head '
                  'to the potty at the first sign, and every 20 to 30 '
                  'minutes. Expect lots of accidents.'),
              PpStep('Day two: fewer reminders', 'Short trip outside, potty '
                  'before you go.'),
              PpStep('Day three: more trust', 'Your child starts to tell you. '
                  'Praise each time it happens.'),
            ]),
            PpCards(heading: 'If you try it', [
              PpCard('Clear three days at home', 'No outings, visitors or '
                  'distractions.'),
              PpCard('Have everything ready', 'Potty, spare clothes, extra water '
                  'and easy snacks.'),
              PpCard('Stop if your child is upset or not ready', 'And try again in a '
                  "month or two. It isn't a failure."),
            ]),
            PpCallout('The one risk is a child who starts holding in poo '
                'because of the pressure. If you see straining, crying with poos '
                'or days without one, stop. Go back to nappies for a '
                'while, and talk to your doctor about constipation.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        PpPage(
          id: 'pull_ups',
          title: 'Do pull-ups help or hurt?',
          format: 'CARDS',
          
          blocks: [
            // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
            // REQUIRED_REVIEW.
            PpIntro('Pull-ups are useful for some families, at some times. They '
                "aren't a training method on their own."),
            PpCards([
              PpCard('Where they help', 'Nights, long journeys, and outings while your child '
                  'is still learning. They save a lot of washing.'),
              PpCard('Where they get in the way', 'In the day at home. A pull-up feels '
                  'like a nappy, so the wet feeling never comes through. That '
                  'feeling is how children learn.'),
              PpCard('What works better in the day', 'Cotton underwear or no bottoms at '
                  'home, and accept some puddles for a few weeks.'),
              PpCard('No shame either way', "Using pull-ups isn't failing, and nor is "
                  'taking them off. Do what suits your family.'),
            ]),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  BAND B — when it is bumpy. The health edge lives here.
    // =========================================================================
    PpArea(
      id: 'when_bumpy',
      // ⚠️ WIDENED TO 3 TO 6. "Every one of these problems happens in the
      // 3 to 6 band too": school-start regressions, older-child soiling
      // from constipation, fear. A five-year-old's mother could not reach
      // the withholding page before this.
      mark: IntentMark.chartLog,
      title: 'Accidents, refusals and going backwards',
      blurb: 'All of it normal. What to do, and the two things worth a doctor.',
      hue: 32,
      // bands: ['learning'], // widened, see the area note
      bands: ['learning', 'dry'],
      pages: [
        PpPage(
          id: 'accidents_are_normal',
          title: 'Accidents are normal',
          subtitle: 'Every single child, for months',
          format: 'ARTICLE',
          blocks: [
            PpIntro('There is no version of this where a child learns without '
                "accidents. They aren't a sign that you started too early, "
                'that your child is being lazy, or that anything is going '
                'wrong. They are the learning itself.'),
            PpArticle(
              heading: 'Why they happen, even weeks in',
              [
                'A child who is mostly dry is doing something quite hard: '
                    'noticing a small internal signal, interrupting a good '
                    'game, and acting in time. Any one of those '
                    'three can fail on any given afternoon, and being '
                    'absorbed in play is the most common reason by far.',
                'Accidents also cluster. A run of three in one day after a '
                    'dry week usually means tiredness, illness, '
                    "excitement, or somewhere new. It's almost never a "
                    'decision.',
                'The clean-up is the real lesson, and what your child learns '
                    'from it is decided by your face.',
              ],
            ),
            PpSteps(
              heading: 'What to do, in the moment',
              [
                PpStep('Say one flat sentence', '"The wee came in your pants. Let us change." No '
                        'sigh, no eyebrows, no lecture.'),
                PpStep('Clean up matter-of-factly', 'The same energy you use for a spilled glass of '
                        'water. Warm water, dry clothes, done.'),
                PpStep('Let your child help, if willing', 'Carrying the wet clothes to the bucket. Helping '
                        "isn't punishment as long as your tone isn't."),
                PpStep('Do not insist on a potty sit afterwards', "It's already empty, and it reads as a "
                        'consequence. Skip it.'),
                PpStep('Mention the next time, once, and move on', '"Next time we will come here." Then talk about '
                        'something else entirely.'),
              ],
            ),
            PpCards(
              heading: 'What not to do',
              hue: 32,
              [
                PpCard('Do not scold, shame or mock',
                    'Not "yuck", not "big children do not do this", not telling '
                    'the story to a visitor within earshot.'),
                PpCard('Do not ask why nobody told you',
                    "Your child doesn't know why. The question only teaches "
                    'that the answer matters, and that it was wrong.'),
                PpCard('Do not bring back nappies as a punishment',
                    'Going back to nappies for practical reasons is fine. '
                    "Doing it as a consequence isn't."),
                PpCard('Do not compare your child to anyone',
                    'Not a cousin, not a sibling, not a neighbour\'s child. '
                    'It changes nothing about the bladder, and a great deal '
                    'about how your child feels.'),
                PpCard('Do not let anyone else shame your child either',
                    'Including relatives who mean it kindly. One sentence '
                    'from you, said in front of your child, is worth more '
                    'than an apology later.'),
              ],
            ),
            PpCallout(
              'Nobody has failed here. Not your child, and not you. A child who '
              'is dry four days out of five at two and a half is doing well, '
              "and the fifth day isn't evidence of anything.",
            ),
            PpCallout(
              'Ask a doctor if a child who was reliably dry starts wetting '
              'again with no obvious reason. Ask too about suddenly drinking '
              'and weeing far more than usual, pain when weeing, or constant '
              'dribbling rather than occasional accidents. These are worth a '
              'quick check rather than a wait.',
              kind: PpCalloutKind.doctor,
              title: 'When accidents are worth a doctor',
            ),
            PpWhenLine('Expect accidents for months after the mostly-dry stage, '
                'and the odd one for a year or more.'),
            PpIndiaNote('If a helper or a grandparent is cleaning up most of '
                'the accidents, they need to hear the no-shame rule from you '
                "directly. It isn't fair to expect them to guess it, and one "
                'disgusted face undoes a fortnight.'),
            PpVideoSlot(
              title: 'Staying calm through an accident',
              subtitle: 'What to say, what to do with your face, and how to '
                  'clean up in a way that teaches rather than stings.',
              minutes: '5 MIN',
              slotId: 'potty/calm_through_accidents',
            ),
          ],
        ),
        PpPage(
          id: 'regressions',
          title: "It was going so well, and now it isn't",
          subtitle: 'Regressions, and why they pass',
          format: 'ARTICLE',
          blocks: [
            PpIntro('A child who was dry for a month and is now wetting daily '
                "hasn't forgotten how. Something has changed, and the bladder "
                'is where it shows up. This is one of the most common '
                'things parents write in about.'),
            PpArticle(
              heading: 'Why going backwards happens',
              [
                'Toilet control is one of the first things a small child owns '
                    'entirely. So it is one of the first things to wobble when '
                    "the world moves. It isn't manipulation, and it isn't "
                    'attention-seeking in any deliberate sense. It is a two '
                    'year old with no words for upheaval.',
                'Regressions almost always have a trigger, and the trigger is '
                    'usually obvious once you look for it. Naming it to '
                    'yourself helps. It turns "my child has stopped '
                    'cooperating" back into "there is a new baby at home".',
                'Nearly all of them settle within two to six weeks with no '
                    'intervention at all beyond going gently back to the '
                    'routine.',
              ],
            ),
            PpCards(
              heading: 'The usual triggers',
              hue: 32,
              [
                PpCard('A new baby in the house',
                    'The most common one of all. Toilet independence is '
                    'something a child can give back in exchange for being '
                    'small again.'),
                PpCard('Starting playschool or daycare',
                    'New bathroom, unfamiliar adult to ask, and a rule about '
                    'when children may go.'),
                PpCard('Travel, or a stay with relatives',
                    'Different toilet, different routine, and nobody watching '
                    'the five moments.'),
                PpCard('Any illness',
                    'Fever, loose motions, a cold. Control is the first thing '
                    'to go and the first to come back.'),
                PpCard('A move, or a change of room',
                    'Including moving out of your bed. Anything that changes '
                    'where your child sleeps.'),
                PpCard('Tension between the adults',
                    'Children read a house very accurately. This one is hard '
                    "to hear, and it's often true."),
              ],
            ),
            PpSteps(
              heading: 'What to do',
              [
                PpStep('Go back to the five fixed moments', "Calmly, without announcing that you're "
                        'starting again. Scaffolding back up for a fortnight.'),
                PpStep('Name the real thing, not the wetting', '"There is a lot changing right now." There may be '
                        'no answer. It is still heard.'),
                PpStep('Give time and attention that has nothing to do '
                    'with the potty', 'Ten unhurried minutes a day. For a new-sibling '
                        'regression this does more than anything you '
                        'do in the bathroom.'),
                PpStep('Use a nappy again if it makes life liveable', 'At night, on a journey, at daycare. It is '
                        'not a punishment, and say so.'),
                PpStep('Drop the subject outside the bathroom', 'The more airtime it gets, the more it becomes an '
                        'identity.'),
                PpStep('Wait it out for a few weeks', 'Most regressions end on their own. Doing less is '
                        'usually the correct intervention.'),
              ],
            ),
            PpCallout(
              'Punishing a regression makes it longer, every time. A child who '
              'is already unsettled and is now also in trouble has one more '
              'thing to be unsettled about.',
            ),
            PpCallout(
              'Ask a doctor if the wetting comes with pain, a fever, a strong '
              'smell, blood or a big jump in thirst. Ask too if it has gone on '
              'for more than about six weeks with no trigger you can find. A '
              'sudden regression with no life change behind it is worth a '
              'urine test.',
              kind: PpCalloutKind.doctor,
              title: 'When a regression needs checking',
            ),
            PpConsult(
              title: 'A short call about a stubborn regression',
              whoFor: 'For a regression that has run past six weeks, or one '
                  "you can't find a reason for. A paediatrician looks at what "
                  'changed, rules out an infection, and tells you whether to '
                  "do anything at all. You won't need it for the ordinary kind "
                  'that follows a new baby or a holiday.',
              surfaceId: 'pp_experts',
              role: 'pediatrician',
            ),
            PpWhenLine('Most common between 2 and 4 years. Usually settles in '
                '2 to 6 weeks.'),
            // The triggers are shared ground: a new baby, starting school,
            // a leap. Cross-linked, not rewritten.
            PpLink('A new baby, starting school: the behaviour side',
                surfaceId: 'pp_section/parenting_behaviour',
                blurb: 'Clinginess, going backwards, and the words to use.'),
            PpLink('Is this a leap?',
                surfaceId: 'pp_page/parenting_development/dev_leaps_lens',
                blurb: 'The fussy-then-forward weeks that unsettle everything, '
                    'potty included.'),
          ],
        ),
        PpPage(
          id: 'withholding_constipation',
          title: 'Holding it in',
          subtitle: 'Withholding, painful poos and constipation',
          format: 'ARTICLE',
          blocks: [
            PpIntro('This is the one part of toilet learning that can really '
                "become a medical problem, and it's also the one most likely "
                'to be missed. A child who is refusing to poo needs help '
                'early, not patience.'),
            PpArticle(
              heading: 'How the cycle starts',
              [
                'It usually begins with one hard, painful stool. Your child '
                    'remembers it, so the next time the urge comes, the '
                    'holding on starts. Holding on makes the stool harder and '
                    'drier. The next one hurts more, so the holding gets '
                    'harder. That loop can tighten within a week.',
                'The confusing part is that a badly constipated child often '
                    'has runny leaks in the pants. It looks like diarrhoea '
                    'or like carelessness. Softer stool is passing around a '
                    'hard mass that is stuck. Treating that as an accident '
                    'problem misses what is happening.',
                'Wetting may increase too, because a full bowel presses '
                    'on the bladder. Day wetting and constipation turn up '
                    'together far more often than most parents are told.',
              ],
            ),
            PpCards(
              heading: 'What withholding looks like',
              hue: 32,
              [
                PpCard('Going stiff, on tiptoe, or hiding',
                    'Standing rigid, crossing legs, going behind a door or a '
                    'curtain. This is holding on, not pushing.'),
                PpCard('Fewer than three poos a week',
                    "Or a clear change from your child's own normal pattern."),
                PpCard('Large, hard, or very wide stools',
                    'The kind that hurt, or that a parent notices in the pan.'),
                PpCard('Crying before or during',
                    'Pain is the engine of the whole cycle.'),
                PpCard('Small smears or runny leaks in the pants',
                    "Often mistaken for laziness. It's frequently the "
                    'opposite.'),
                PpCard('Asking for a nappy to poo in',
                    'Very common, and worth allowing for now. A child who '
                    "poos in a nappy is much better off than one who doesn't "
                    'poo at all.'),
              ],
            ),
            PpSteps(
              heading: 'What helps at home',
              [
                PpStep('Take the pressure off completely', 'Stop asking for poos on the potty for now. The '
                        'immediate goal is a soft, painless poo anywhere at '
                        'all.'),
                PpStep('Water, through the day', 'The easiest and most effective thing. A small '
                        'glass at each of the fixed moments.'),
                PpStep('Fruit that helps', 'Papaya, pear, prunes or raisins soaked '
                        'overnight, orange, guava. Papaya is the one most '
                        'Indian families find reliable.'),
                PpStep('Move the food towards whole grains and dal', 'Less refined flour and biscuits, more roti, dal, '
                        'vegetables and curd. Warm milk with a little ghee at '
                        'night helps many children.'),
                PpStep('Feet flat and knees up for every poo', 'A stool under the feet on a Western toilet, or a '
                        'proper squat. Position really changes how hard it '
                        'is.'),
                PpStep('Running and playing every day', 'Movement moves the bowel. A day mostly indoors '
                        'shows up the next morning.'),
                PpStep('Sit after meals with no expectation', 'Five minutes with a book, when the bowel is '
                        'naturally active. Sitting is the goal, not '
                        'producing.'),
              ],
            ),
            PpCallout(
              "Don't keep your child sitting until a poo comes. Don't call "
              "it naughty, and don't let anybody make threats about it. "
              'Fear is what started the cycle, and more fear tightens it.',
            ),
            PpCallout(
              'See a doctor if the withholding has gone on for more than about '
              'a week despite these changes. See one too if there is blood, a '
              'tear or a crack around the anus, or poos hurt enough to cause '
              'crying. Go if there are fewer than three poos a week for a '
              'fortnight, leaking in the pants, a hard or swollen tummy, or '
              'no weight gain. Constipation in a small child is very '
              'treatable, and it gets harder the longer it runs. Do not '
              'give any laxative, digestive powder or home purgative to a child without '
              'a doctor telling you which one and how much.',
              kind: PpCalloutKind.doctor,
              title: 'When to see a doctor about this',
            ),
            PpConsult(
              title: 'A short consult about withholding',
              whoFor: 'For a child who is holding it in, has painful poos, or '
                  'is leaking in the pants. A paediatrician checks whether '
                  'there is a stuck mass to clear first, decides whether '
                  'anything is needed, and gives you a plan. Worth doing '
                  'early rather than after a month of trying.',
              surfaceId: 'pp_experts',
              role: 'pediatrician',
            ),
            PpWhenLine('Act within a week of noticing withholding. This is the '
                "one part of the section where waiting doesn't help."),
            PpIndiaNote('Very common in Indian toddler diets that lean on '
                'refined flour, biscuits and lots of milk with little fruit. Two '
                'papaya slices a day and less milk is often the entire fix. '
                "It's worth trying before anything else."),
            PpLink('No poo for a few days?',
                surfaceId: 'pp_what_changed',
                blurb: 'Answer a few questions about the tummy and get a '
                    'clearer read on what is going on.'),
            // Health owns the medical depth of constipation; this page is
            // the potty side of it.
            PpLink('Constipation, in full',
                surfaceId: 'pp_page/parenting_health/tummy_constipation',
                blurb: "What helps, what doesn't, and when it needs a doctor."),
          ],
        ),
        PpPage(
          id: 'potty_refusal',
          title: 'Scared of the potty',
          subtitle: 'Refusal, and how to un-scare it',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro("A child who screams at the sight of the potty isn't being "
                'difficult. Something about it has become frightening, and '
                'usually you can find out what.'),
            PpArticle([
              'The common fears are specific and reasonable. The flush is very '
                  'loud. A big toilet is a hole to fall into. Feet '
                  'dangle with nothing to brace against. Something '
                  'coming out of the body and then disappearing is '
                  'strange when nobody has explained it. Or there is a memory '
                  'of one poo that hurt.',
              'Work out which one it is by watching where the refusal starts. '
                  'Refusing to enter the bathroom is different from sitting '
                  'happily and then panicking at the flush, and each has a '
                  'different fix.',
              "Then make that one thing smaller. Don't flush while your child "
                  'is in the room. Move to a low potty with feet on the floor. '
                  'Allow a nappy for poos while trust is rebuilt. Sit '
                  'together on the floor and read something.',
              'And stop asking for a fortnight. A refusal that is met with '
                  'daily requests hardens. One that is left alone while the '
                  'fear is gently removed usually softens on its own.',
            ]),
            PpCallout(
              'If your child will only poo in a nappy, allow it for now. '
              'Pooing somewhere matters much more than pooing in the right '
              'place, and forcing the issue is how withholding starts.',
            ),
            PpCallout(
              'Ask a doctor if the refusal is about pain rather than fear, or '
              'there is blood or a crack around the anus. Ask too if several '
              'days have passed without a poo while refusing. Pain has a '
              'physical cause, and it needs treating before any of the above '
              'will work.',
              kind: PpCalloutKind.doctor,
              title: 'When the fear is really pain',
            ),
            PpWhenLine('Most common between 2 and 3.5 years. Give any fix two '
                'to three weeks before changing tack.'),
          ],
        ),
        // ⚠️ [NEW], a scaffold. "A short, calm pointer for the child who is
        // well behind or has other delays, sending them to Development and
        // a paediatrician without alarm."
        PpPage(
          id: 'taking_longer',
          title: 'If it is taking your child a long time',
          subtitle: 'A calm pointer, not a verdict',
          format: 'CARDS',

          blocks: [
            // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
            // REQUIRED_REVIEW.
            PpIntro('Every child learns the toilet at a different pace, and the range is '
                'wide. Some are dry at two, many at three and a half, and night '
                'dryness can take until five or later. Comparing with a cousin '
                'or classmate tells you very little.'),
            PpCards([
              PpCard('Most often, the readiness is not there yet', 'Pause for a month or '
                  'two and try again, calmly.'),
              PpCard('Constipation is a common hidden cause', 'Hard or painful poos '
                  'make children hold on. Treat constipation first.'),
              PpCard('Pressure slows it down', 'Rewards, scolding and comparisons make '
                  'it a battle. Keep it relaxed.'),
              PpCard('Look at the rest of development', 'Speech, play and '
                  'understanding. If those are also slow, mention it.'),
            ]),
            PpCallout('Talk to your paediatrician if your child is not dry in the day by '
                'about four, or was dry and has started wetting again. Talk to them '
                'too if there is pain, or dribbling all the time.',
                kind: PpCalloutKind.doctor),
            PpLink('What most children do at this age',
                surfaceId: 'pp_page/parenting_development/dev_age_3_5'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  BAND B — things to do together. Activities, named.
    // -------------------------------------------------------------------------
    //  ⚠️ THE CHART IS A DRAWING, NOT A SCOREBOARD. The spec asks for a "potty
    //  routine chart" and the honest version is a picture of the five steps
    //  stuck on the bathroom wall, which is a memory aid. It is deliberately NOT
    //  a star chart the app tracks: a count that can drop turns an ordinary
    //  accident into a visible loss, and no-shame is the one rule this section
    //  cannot bend.
    // =========================================================================
    PpArea(
      id: 'things_to_do',
      mark: IntentMark.blocksMark,
      title: 'Things to do together',
      blurb: 'Three small activities that make the bathroom easier.',
      hue: 174,
      bands: ['learning'],
      pages: [
        PpPage(
          id: 'routine_chart',
          title: 'Draw the potty steps',
          subtitle: 'A picture on the wall, not a scoreboard',
          format: 'ACTIVITY',
          blocks: [
        // ⚠️ ADDED IN THE S06 PASS — this area had no video, and the
        // feedback asks that video, tools and expert booking all get the
        // treatment the earlier sections got.
        // ⚠️ NOT `potty/routine_walkthrough` — that slot already exists in
        // "Starting out, day by day" with its own title, and
        // `pp_section_test.dart` correctly refuses to let one slot id mean two
        // different videos. A shared id would have meant one file arriving and
        // silently filling two unrelated players.
        PpVideoSlot(
          title: 'Teaching the toy, and the chart',
          subtitle: 'The two activities that do the most work, shown with a '
              'child who is not in the mood.',
          minutes: '3 MIN',
          slotId: 'potty/activities_together',
        ),
            PpIntro("A toddler can't hold five steps in mind, but can "
                'read five pictures. Half an hour with paper and sketch pens '
                'gives your child something to follow without an adult narrating.'),
            PpArticle(
              heading: 'What it is',
              [
                'One sheet of paper, five simple drawings in a row, stuck at '
                    "your child's eye level in the bathroom. Pants down, sit, "
                    'wipe or wash, pull pants up, wash hands. That is the whole '
                    'thing.',
                "It's a memory aid. It helps most with the steps "
                    'children forget rather than the sitting: the hand '
                    'washing and the pulling up. It also means a helper or a '
                    'grandparent prompts the same sequence you do.',
              ],
            ),
            PpSteps(
              heading: 'How to do it',
              [
                PpStep('Draw it together, badly', 'Stick figures are fine. Having drawn it is '
                        'most of why your child will look at it.'),
                PpStep('Five pictures, left to right, no words', "Your child can't read yet. Numbers are fine; sentences are "
                        'decoration for adults.'),
                PpStep("Stick it at your child's height, by the potty", 'Eye level for your child, not for you.'),
                PpStep('Point at it instead of instructing', 'Tapping the third picture is better than saying '
                        '"now wash". Your child gets to be the one doing it.'),
                PpStep('Leave it up and stop mentioning it', "Once it's in use, your job is done. Take it down "
                        "whenever it isn't needed any more."),
              ],
            ),
            PpCallout(
              'No stars, no ticks, no counting days. A chart that records '
              'success turns a wet afternoon into a visible '
              'failure on the wall. Toilet learning needs no '
              'score attached.',
            ),
            PpWhenLine('From about 2 years, once sitting is willing. '
                'Useful for a few months.'),
            PpIndiaNote("If the bathroom is shared and you can't stick "
                'anything up, keep the sheet in the bucket cupboard and bring '
                'it in. It works just as well.'),
          ],
        ),
        PpPage(
          id: 'sit_and_read',
          title: 'Sit-and-read potty time',
          subtitle: 'Two books by the potty',
          format: 'ACTIVITY',
          blocks: [
            PpIntro('The easiest thing on this list. Keep two or three '
                'board books next to the potty and read one during each sit. '
                'Sitting stops being a task and becomes a pause in the day.'),
            PpArticle(
              heading: 'What it is',
              [
                'A small pile of books that live by the potty and nowhere '
                    'else. Your child sits, you read, and neither of you is '
                    'watching to see whether anything happens.',
                'It works because relaxing is a physical '
                    'requirement. A child who is bored, hurried or being '
                    "watched tenses up, and a tense child can't pass a "
                    'stool. Reading solves that without either of you trying '
                    'to.',
              ],
            ),
            PpSteps(
              heading: 'How to do it',
              [
                PpStep('Choose two or three sturdy board books', "They'll get wet. Don't use the good ones or "
                        'anything borrowed.'),
                PpStep('Keep them only in the bathroom', 'The novelty is what makes sitting appealing.'),
                PpStep('Read during the sit, and stop at standing up', 'Your child decides when it is over, not the end of the '
                        'story.'),
                PpStep('Do not comment on whether anything happened', 'Not even encouragement. The point is that '
                        'nobody is watching.'),
                PpStep('Use it for the after-meal sit especially', 'That is when the bowel is active and when '
                        'relaxing matters most.'),
              ],
            ),
            PpCallout(
              'Cap it at about five minutes. A long sit gets uncomfortable and '
              'starts to feel like being kept there, which defeats the '
              'purpose.',
            ),
            PpWhenLine('From about 2 years. Especially useful for a child who '
                'is withholding poos.'),
            PpIndiaNote('If books by an Indian toilet are impractical, a couple '
                'of picture cards in a plastic sleeve do the same job and wipe '
                'clean.'),
            PpLink('Board books that survive a bathroom',
                surfaceId: 'pp_products',
                blurb: 'Cheap, wipeable and short. That is all they need to be.'),
          ],
        ),
        PpPage(
          id: 'teach_the_toy',
          title: 'Teach the toy',
          subtitle: 'Your child explains it to a doll',
          format: 'ACTIVITY',
          blocks: [
            PpIntro('Hand your child a doll or a soft toy, and ask for a '
                'lesson on how the potty works. A child being taught is being '
                'corrected; a child who is teaching is in charge.'),
            PpArticle(
              heading: 'What it is',
              [
                'A short bit of pretend play where your child is the adult. '
                    'The toy sits on the potty, your child narrates the steps, '
                    'and knows what happens next.',
                'It helps in two ways. You see what has been understood, '
                    'including the parts that came out '
                    'wrong. And it gives some authority over a subject '
                    'where small children are usually being managed. For a '
                    'child who has started refusing, this often reopens the '
                    'door when nothing else does.',
              ],
            ),
            PpSteps(
              heading: 'How to do it',
              [
                PpStep('Pick a favourite toy and hand it over', '"Teddy does not know how to do a wee. Will you '
                        'show Teddy?"'),
                PpStep('Let your child run it, wrong steps included', "Don't correct the order. Watch what gets skipped, "
                        "because that's the part not yet learned."),
                PpStep('Ask the toy the questions', '"Teddy, are you scared of the flush?" Your child '
                        'will answer for Teddy, and sometimes tells you exactly '
                        'what is wrong.'),
                PpStep('Let the toy have an accident', 'And let your child clean it up calmly. This is '
                        "where the tone you've been using gets practised."),
                PpStep('Keep it short, and stop when your child does', "Two minutes is plenty. It's a game, not a "
                        'lesson.'),
              ],
            ),
            PpCallout(
              'Listen to what gets said to the toy. Children who can\'t tell a '
              'parent that the flush is frightening, or that it hurt last time, '
              "will often tell a doll. It's the most reliable way to find "
              'out what the real problem is.',
            ),
            PpWhenLine('From about 2.5 years, once your child is talking in '
                'short sentences.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  BAND C — 3 to 6 years. Nights, wiping, out of the house.
    // =========================================================================
    PpArea(
      id: 'staying_dry',
      mark: IntentMark.moonMark,
      title: 'Dry nights, and doing it alone',
      blurb: 'Night dryness, wiping, and toilets away from home.',
      hue: 232,
      bands: ['dry'],
      pages: [
        PpPage(
          id: 'night_dryness',
          title: 'Dry nights come later',
          subtitle: "And you can't train them",
          format: 'ARTICLE',
          blocks: [
            PpIntro('Day dryness is a skill a child learns. Night dryness is '
                'mostly a physical change that happens on its own, and it '
                'arrives months or years after the days are sorted. That gap '
                "is normal, and it isn't a training problem."),
            PpArticle(
              heading: 'Why nights are different',
              [
                "Staying dry all night needs two things a small child can't "
                    'practise. The body has to make less urine during sleep, '
                    'which depends on a hormone that switches on at its own '
                    'pace. And the bladder has to hold a '
                    'whole night\'s worth. Neither responds to effort, '
                    'encouragement or being woken up.',
                'This is why a child can be perfectly dry in the day for a '
                    'year and still be wet every single night. Nothing has '
                    "gone wrong. The night part just hasn't switched on "
                    'yet.',
                'Roughly one in five five-year-olds still wets the bed, and '
                    'it becomes less common every year after that with no '
                    'treatment at all. It is common enough at five that there '
                    'is very likely another child in the same class in the '
                    'same position.',
              ],
            ),
            PpChartCard(
              title: 'When dry nights usually arrive',
              hue: 232,
              rows: [
                ('Dry days are reliable', 'About 3 years'),
                ('Some dry nights start appearing', 'About 3 to 4 years'),
                ('Dry most nights', 'About 4 to 5 years'),
                ('Still wet at night at 5', 'Around 1 child in 5'),
                ('Still wet at night at 7', 'Around 1 child in 20'),
              ],
              note: 'The gap between dry days and dry nights is commonly one '
                  'to three years. It runs in families, so if a parent was '
                  'dry at night later, your child may be too.',
            ),
            PpSteps(
              heading: 'What really helps',
              [
                PpStep('Wait for a run of dry mornings before dropping the '
                    'nappy', 'Several dry nights in a row means the switch has '
                        'flipped. Removing the nappy earlier just makes '
                        'laundry.'),
                PpStep('Most drinks earlier in the day', "Not a dry evening; that's unkind and "
                        'unnecessary. Just shift the volume forward.'),
                PpStep('Toilet last thing, every night, as routine', 'After brushing, before the story. Part of '
                        'bedtime, not a special request.'),
                PpStep('A waterproof sheet and a spare set within reach', 'Two minutes of preparation buys you a calm 2am '
                        'instead of a stripped bed and a search for sheets.'),
                PpStep('A night light and a clear path to the bathroom', 'Many children wet the bed partly because getting '
                        'there in the dark is frightening.'),
                PpStep('Change the bed without conversation', 'Half asleep, minimal light, no discussion. Talk '
                        'about it in the morning only if your child wants to.'),
              ],
            ),
            PpCards(
              heading: "What doesn't work",
              hue: 32,
              [
                PpCard('Waking your child at midnight',
                    "It empties the bladder, but it doesn't teach the body "
                    'anything, and it costs everybody sleep.'),
                PpCard('Cutting fluids in the evening',
                    'Beyond a mild shift, this means a thirsty child, and it '
                    "doesn't fix a hormone."),
                PpCard('Any kind of reward or chart',
                    "This isn't a choice. A reward for something outside "
                    'anyone\'s control only says "you are failing".'),
                PpCard('Punishment, or washing the sheets as a '
                    'consequence',
                    'This is the fastest way to a child who hides wet '
                    'bedding.'),
                PpCard('Comparing with a sibling',
                    'Bedwetting runs in families and has nothing to do with '
                    'effort.'),
              ],
            ),
            PpCallout(
              'It happens during sleep. Your child is not choosing any of '
              'it, so there is nothing here to be blamed for.',
            ),
            PpWhenLine('Dry nights any time from 3 to 6 years, and later is '
                'still within normal.'),
            PpIndiaNote('In a shared bed or on a floor mattress, a waterproof '
                'sheet under the cotton one saves the whole bedding. Keep a '
                "dry set folded within arm's reach so a 2am change doesn't "
                'wake the house.'),
            PpVideoSlot(
              title: 'Why dry nights take so long',
              subtitle: 'The hormone, the bladder, and why a midnight '
                  "wake-up doesn't help.",
              minutes: '7 MIN',
              slotId: 'potty/night_dryness',
            ),
            PpLink('Waterproof sheets and night pants',
                surfaceId: 'pp_products',
                blurb: 'What is worth having while you wait it out.'),
          ],
        ),
        PpPage(
          id: 'bedwetting',
          title: 'Bedwetting at five and older',
          subtitle: 'Common, not a character flaw, and treatable',
          format: 'ARTICLE',
          blocks: [
            PpIntro('If your child is five or six and still wet most nights, '
                "you aren't alone, and nothing is wrong with your child. "
                "It also isn't something you just have to endure. From about "
                'five there are treatments that work.'),
            PpArticle(
              heading: 'What is going on',
              [
                'Bedwetting past five is usually one of three things. The body '
                    'still makes too much urine at night, the bladder holds '
                    'less than a night\'s worth, or sleep is too deep to '
                    'wake for the signal. Often two of them together. All '
                    'three are physical.',
                'It runs strongly in families. If either parent wet the bed '
                    'for longer as a child, the odds go up considerably. Say that out '
                    'loud in front of your child. It moves the '
                    'story from "what is wrong with me" to "this is how our '
                    'family is built".',
                "Constipation is a very common hidden cause, and it's the "
                    'first thing worth ruling out. A full bowel presses on the '
                    'bladder all night. Treating the constipation sometimes '
                    'ends the bedwetting by itself.',
                "The wet bed isn't what does the real damage. Shame does: a "
                    "child who feels disgusting, won't sleep "
                    'at a cousin\'s house, and hides sheets. Protecting your '
                    'child from that is the real job while you wait or treat.',
              ],
            ),
            PpSteps(
              heading: 'How to handle it in the house',
              [
                PpStep("Say plainly that it isn't anyone's fault", 'In these words. Once, calmly, and then again '
                        'whenever it seems forgotten.'),
                PpStep('Make the clean-up a non-event', 'Sheets ready, minimal light, no discussion, back '
                        'to sleep.'),
                PpStep('Keep it private from the rest of the house', 'Nobody outside needs to know. Not visitors, not '
                        'cousins, not the neighbour who asks.'),
                PpStep('Stop any teasing immediately', 'Siblings, cousins, adults who think it is funny. '
                        'One sentence, in front of your child, every time.'),
                PpStep('Solve sleepovers and school trips practically', 'A discreet pull-up and a quiet word with one '
                        'trusted adult. Missing out hurts more than the '
                        'wetting.'),
                PpStep('Check for constipation', 'Fewer than three poos a week, hard stools, or '
                        'smears in the pants. Fixing that first is sometimes '
                        'the whole answer.'),
              ],
            ),
            PpCallout(
              'See a doctor if your child is five or older and wet most '
              'nights, or was dry for six months or more and starts wetting '
              'again. Go too if there is day wetting, pain on weeing, strong-'
              'smelling urine, great thirst or weeing a lot. Also go for heavy '
              'snoring or pauses in breathing during sleep, or constipation '
              'as well. From about five there '
              'are real options: bladder training, an alarm, or medication for '
              'specific nights. None of it starts with blame.',
              kind: PpCalloutKind.doctor,
              title: 'When bedwetting is worth a doctor',
            ),
            PpConsult(
              title: 'A consult about bedwetting past five',
              whoFor: 'For a child of five or more who is wet most nights, or '
                  'any child who was dry and has started again. A '
                  'paediatrician checks for constipation and infection, and '
                  'talks through whether an alarm, bladder training or '
                  "medication is worth trying now or later. You won't need it "
                  'for a three or four year old, where waiting is still the '
                  'right answer.',
              surfaceId: 'pp_experts',
              role: 'pediatrician',
            ),
            PpWhenLine('Worth a doctor from about 5 years, or sooner if a dry '
                'child starts wetting again.'),
          ],
        ),
        PpPage(
          id: 'wiping_and_washing',
          title: 'Washing and wiping without help',
          subtitle: 'Mug, water, soap, in that order',
          format: 'STEP-LIST',
          blocks: [
            PpIntro("Doing it alone is the last piece, and it's mostly about "
                'small hands being able to reach and coordinate. Most children '
                'manage properly somewhere between four and five.'),
            PpSteps(
              heading: 'Teaching it, in order',
              [
                PpStep('You do it, narrating, for a few weeks', '"Water first, then rinse, then dry." The sequence '
                        'is learned long before the doing.'),
                PpStep("Teach the mug with your child's hand under yours", 'Left hand, pour with the right, front to back. '
                        'Guided, then loosening.'),
                PpStep('Front to back, always, and say why', '"So the dirty water does not go to the front '
                        'part." Especially important for girls, because the '
                        'other way round causes urine infections.'),
                PpStep('Let your child finish the job while you stay in the room', 'Present but not doing it. Expect it to be '
                        'imperfect for months.'),
                PpStep('Check gently, without making it an inspection', 'A glance at the pants at bath time tells you '
                        'what you need. No commentary.'),
                PpStep('Hand washing is the non-negotiable one', 'Soap, both hands, about twenty seconds, every '
                        'single time. This is the step that keeps '
                        'children well, and the one they skip.'),
                PpStep('Teach paper only if it will be needed', 'At school, on a flight, at a mall. Fold, wipe '
                        'front to back, fold again. Water at home stays the '
                        'main method.'),
              ],
            ),
            // The technique is taught once, on the Indian-toilet page's film.
            PpLink('The mug and front to back, shown',
                pageId: 'indian_toilet',
                blurb: 'The technique, on film. This page is about your child '
                    'doing it alone.'),
            PpCallout(
              'Expect this to be done badly for a while. A child who is '
              'criticised about wiping starts saying "finished" too early, '
              'and then you know less than you did.',
            ),
            PpCallout(
              'Ask a doctor if there is redness, itching, a discharge, pain on '
              'passing urine, or repeated urine infections. Wiping the wrong '
              'way is a common and easily fixed cause, and worms are another '
              'that is worth ruling out.',
              kind: PpCalloutKind.doctor,
              title: 'When soreness needs checking',
            ),
            PpWhenLine('Start teaching from about 3 years. Reliable without help '
                'usually between 4 and 5.'),
            PpIndiaNote('A mug light enough to lift when full, and a tap or '
                'bucket within reach, make the difference between learning '
                'this and needing an adult. A step stool at the basin is the '
                'other half of it.'),
          ],
        ),
        PpPage(
          id: 'school_and_public',
          title: 'School toilets, and toilets out in the world',
          subtitle: 'Asking, holding, and not holding all day',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('Plenty of children who are completely reliable at home '
                "have accidents at school, or hold it in for six hours. The "
                "toilet isn't the problem. Asking a stranger for permission "
                'is.'),
            PpArticle([
              'Teach the exact sentence your child needs, and practise it out '
                  'loud until it is automatic. "Ma\'am, I need to go to the '
                  'toilet." A child who has rehearsed the words will use them. '
                  'A child who has to invent them in the moment will wait, and '
                  'then it is too late.',
              "Tell the school your child's word, and ask directly whether "
                  'children may go when they need to or only at fixed times. '
                  'Many Indian schools restrict it. Holding urine all morning '
                  'is a real cause of accidents, infections and '
                  'constipation. That conversation is yours to have, not '
                  "your child's.",
              'Send a spare set of clothes in the school bag every day. Say '
                  'plainly that it is there, and that using it is fine. '
                  'Knowing an accident is survivable prevents more '
                  'accidents than anything else, because tension makes it '
                  'worse.',
              'Public toilets away from home are their own thing. Your child '
                  "may not want to sit on one, and doesn't have to. Teach a "
                  'squat over the seat without touching, holding your hand. '
                  'Carry a small bottle of water and a '
                  'soap or sanitiser. A dirty toilet that gets used is better '
                  'than holding on until the drive home.',
              "And say clearly that holding it in for hours isn't something "
                  'to be proud of. Some children are praised for managing a '
                  'whole school day without going, and they keep doing it.',
            ]),
            PpCallout(
              'If the accidents happen only at school, ask the school about '
              'their toilet rules before you change anything at home. It is '
              'the answer more often than parents expect.',
            ),
            PpCallout(
              'Ask a doctor if your child often holds urine for many hours, '
              'has repeated urine infections or complains of burning. Ask too '
              'about day wetting at school age. Holding on habitually can '
              "cause real bladder problems, and it's worth sorting out "
              'properly.',
              kind: PpCalloutKind.doctor,
              title: 'When holding it in needs a doctor',
            ),
            PpWhenLine('Before school starts, and again at any change of '
                'school or class.'),
            PpIndiaNote('Squat toilets at school are usually easier for a '
                'small child than a high Western seat, as long as there is '
                'something to hold. Practise at home on the version your '
                'child will meet there.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpCards(heading: 'Accidents at daycare or preschool', [
          PpCard('Expect some', 'A new place, busy play and shy asking all '
              'lead to accidents in the first weeks.'),
          PpCard('Send two sets of spare clothes', 'In a labelled bag.'),
          PpCard('Teach the words', 'And how the school toilet works, '
              'before the first day.'),
          PpCard('Ask the teacher for reminders', 'Before play and after '
              'meals.'),
          PpCard('Never shame', 'Keep it matter-of-fact at home and school.'),
        ]),
          ],
        ),
      ],
    ),
  ],
  // ⚠️ NO TOOLS. The spec marks this bracket's tools cell notApplicable, and an
  // empty list is the honest rendering of that: `PpSectionScreen` simply does not
  // draw the TOOLS block. Inventing a "potty tracker" here would be both a
  // fabricated cell and a scoreboard, which this section specifically must not
  // have.
  tools: [],
);
