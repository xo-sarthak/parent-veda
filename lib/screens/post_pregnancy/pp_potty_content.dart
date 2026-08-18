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
    blurb: 'The su-su cue. Reading her timing, and fewer diapers to wash.',
  ),
  PpBand(
    id: 'learning',
    label: '1 to 3 years',
    fromMonths: 12,
    toMonths: 36,
    blurb: 'Learning to use the potty, at her pace, with accidents along the way.',
  ),
  PpBand(
    id: 'dry',
    label: '3 to 6 years',
    fromMonths: 36,
    toMonths: 72,
    blurb: 'Dry nights, wiping on her own, and managing a toilet away from home.',
  ),
]);

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpPottySection = PpSection(
  id: 'parenting_potty',
  title: 'Toilet learning',
  subtitle: 'The su-su way, honestly told',
  intro: 'In most Indian homes this starts long before any training does, with '
      'the su-su cue and a grandmother who already knows the timing. Here is '
      'that path, and the truth about how long each part really takes.',
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
      mark: IntentMark.listMark,
      title: 'How long does this actually take?',
      blurb: 'The honest timeline, from the first su-su to dry nights.',
      hue: 206,
      pages: [
        PpPage(
          id: 'honest_timeline',
          title: 'How long this actually takes',
          subtitle: 'One chart, and no rushing',
          format: 'CHART-CARD',
          blocks: [
            PpIntro('Toilet learning is not one event you get through in a '
                'weekend. It is a long, slow conversation that starts with you '
                'reading her signals and ends, years later, with her going on '
                'her own. Here is the real shape of it.'),
            PpChartCard(
              title: 'What usually happens, and roughly when',
              subtitle: 'Wide ranges, on purpose',
              rows: [
                ('Su-su cueing can begin', 'From a few weeks old'),
                ('She tells you after she has gone', 'About 18 to 24 months'),
                ('She tells you just before', 'About 2 to 3 years'),
                ('Mostly dry days, with accidents', 'About 2.5 to 3 years'),
                ('Goes on her own, start to finish', 'About 3 years, often later'),
                ('Dry most nights', 'Anywhere from 3 to 6 years'),
              ],
              note: 'A child who gets there at four is not late. Boys often '
                  'take a little longer than girls, and that is not a problem '
                  'either.',
            ),
            PpCallout(
              'Su-su cueing is you learning her timing. Being trained is her '
              'knowing her own. Both are worth doing, in that order, and the '
              'first does not skip you past the second.',
            ),
            PpCallout(
              'A baby held over a basin at six months is not potty trained. She '
              'is being caught, which is genuinely useful and means far fewer '
              'wet nappies. Independent toileting is a different skill that '
              'needs speech, bladder control and the ability to wait, and none '
              'of those arrive before about two.',
              kind: PpCalloutKind.myth,
              title: 'Nobody is trained at six months',
            ),
            PpWhenLine('Useful at any age. Worth re-reading on the day '
                'somebody tells you your child is behind.'),
            PpIndiaNote('If your mother or mother-in-law started cueing su-su '
                'with her own babies at three weeks, she is not wrong and she '
                'is not exaggerating. That method works. It is doing something '
                'slightly different from what a training chart measures, and '
                'both of those things are real.'),
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
      title: 'Catching the su-su',
      blurb: 'The cue method your family already knows, done gently.',
      hue: 152,
      bands: ['su_su'],
      pages: [
        PpPage(
          id: 'what_is_su_su',
          title: 'What is su-su cueing?',
          subtitle: 'Communication first, diapers second',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Su-su cueing is simple. You notice when your baby is about '
                'to go, hold her over a potty or basin, and make a soft "sss" '
                'or "su-su" sound. Over weeks she learns that the sound and the '
                'position go together.'),
            PpArticle(
              heading: 'Why it works',
              [
                'A newborn does not wee at random. She goes soon after a feed, '
                    'soon after waking, and often at the same points in the '
                    'day. She also gives small signs first. Cueing works '
                    'because you are joining two things she can already do, a '
                    'predictable rhythm and a clear signal, rather than '
                    'teaching her a brand new skill.',
                'The sound is the important part. It is not magic and it does '
                    'not have to be "su-su", though that is the word most '
                    'Indian families use and there is no reason to change it. '
                    'What matters is that it is always the same sound, made at '
                    'the same moment, by everyone in the house.',
                'This is what the elders in your family mean when they say a '
                    'baby can be trained early. They are describing something '
                    'real, and it is closer to a shared language than to '
                    'training.',
              ],
            ),
            PpSteps(
              heading: 'How families actually do it',
              [
                PpStep('Pick two easy windows to start', 'First thing after she wakes, and about ten to '
                        'twenty minutes after a feed. Those are the times you '
                        'are most likely to be right.'),
                PpStep('Hold her in a supported squat', 'Back against your chest, your hands under her '
                        'thighs, knees drawn up. Over a small basin, a potty, '
                        'or the bathroom floor. Her whole body should feel '
                        'held, never dangling.'),
                PpStep('Make the sound, softly, and wait', 'A quiet "sssss". Wait less than a minute. If '
                        'nothing comes, that is fine, put her down.'),
                PpStep('Say the same thing when she goes', 'A calm "su-su" as it happens. That is the whole '
                        'lesson. No clapping, no fuss.'),
                PpStep('Tell everyone the same sound', 'Dadi, nani, the helper, the father. One sound, '
                        'one word, or she is learning three languages at once.'),
              ],
            ),
            PpCallout(
              'This is not training and it is not meant to be. What you get is '
              'fewer wet nappies, more diaper-free time, and a baby whose '
              'signals you can read. Her own bladder control comes years later '
              'and nothing here speeds that up.',
              title: 'What su-su cueing gives you, honestly',
            ),
            PpCards(
              heading: 'When to stop for the day',
              hue: 152,
              [
                PpCard('She arches or cries in the position',
                    'She has said no. Put her down and try another time. A '
                    'baby who learns to dread the hold will stop signalling '
                    'at all.'),
                PpCard('You are holding her for minutes',
                    'Long holds are hard on her hips and yours. Under a '
                    'minute, then stop.'),
                PpCard('She is unwell, or teething badly',
                    'Her rhythm goes off when she is ill. Pause without '
                    'guilt and pick it up in a quieter week.'),
                PpCard('You are exhausted',
                    'This is a nice-to-have, not a duty. A week off costs '
                    'nothing at all.'),
              ],
            ),
            PpWhenLine('Any time from a few weeks old. Most families find it '
                'easiest between 3 and 9 months, before she starts crawling '
                'away mid-hold.'),
            PpIndiaNote('In a joint family this is often easier, not harder. '
                'More arms means more chances to catch the moment, and someone '
                'in the house has almost certainly done it before. The one '
                'thing to agree on early is the sound. Read next in this area: '
                'how to read your baby\'s signals.'),
            PpVideoSlot(
              title: 'Cue-based holding, shown properly',
              subtitle: 'A supported squat, the su-su sound, and the moments '
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
          subtitle: 'She tells you. It is just quiet.',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Almost every baby gives a small sign before she goes. It '
                'is easy to miss because it is subtle and it lasts a few '
                'seconds. Once you have seen it two or three times you will '
                'not un-see it.'),
            PpArticle(
              heading: 'Why the signs are there at all',
              [
                'A full bladder or a moving bowel is a strange feeling, and a '
                    'baby responds to strange feelings with her whole body. '
                    'She is not trying to tell you anything yet. She is simply '
                    'reacting, and you are reading it.',
                'This is also why the signs change. What she does at two '
                    'months is not what she does at eight. Expect to relearn '
                    'her a few times.',
              ],
            ),
            PpCards(
              heading: 'The signs to watch for',
              hue: 152,
              [
                PpCard('She goes suddenly still',
                    'Mid-play, mid-feed, a small pause. The most common sign '
                    'and the easiest to miss.'),
                PpCard('A change in her face',
                    'A frown, a faraway look, a red face for a poo. Often the '
                    'clearest one.'),
                PpCard('Squirming and kicking',
                    'Restless legs, arching, twisting away from the breast '
                    'when she is not actually finished.'),
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
                PpStep('Move without hurrying', 'Rushing and gasping teaches her that this is an '
                        'emergency. Walk her over calmly.'),
                PpStep('Get her into the squat and make the sound', 'Same position, same "sssss", every time.'),
                PpStep('Give it thirty to sixty seconds', 'That is long enough. If it was the right moment '
                        'it usually happens quickly.'),
                PpStep('If nothing comes, stop cheerfully', 'You read it wrong, or she changed her mind. '
                        'Neither is a failure and she should not feel one.'),
                PpStep('Notice what you missed, later', 'If she goes in the nappy five minutes after, '
                        'think back to what she did just before. That is the '
                        'sign for next time.'),
              ],
            ),
            PpCards(
              heading: 'What not to do',
              hue: 32,
              [
                PpCard('Do not force the position',
                    'If she stiffens or pushes back, she is done. Holding on '
                    'through it is the fastest way to lose her cooperation.'),
                PpCard('Do not hold her there waiting',
                    'Three minutes over a basin is uncomfortable and teaches '
                    'her nothing. Under a minute.'),
                PpCard('Do not chase every single wee',
                    'Aiming to catch them all makes the day miserable and the '
                    'method feel like failure. Two or three a day is a fine '
                    'place to live.'),
                PpCard('Do not show disappointment when you miss',
                    'A baby reads your face long before your words. A missed '
                    'catch is your miss, not hers, and neither of you should '
                    'wear it.'),
              ],
            ),
            PpCallout(
              'Some days there is no signal at all, and some babies simply '
              'never give an obvious one. That is a fact about her, not a '
              'verdict on you. Timing after feeds and naps works even when you '
              'cannot read a thing.',
              title: 'When it is just not the moment',
            ),
            PpCallout(
              'Ask a doctor if she seems to strain or cry when passing urine, '
              'if her nappies are suddenly much drier than usual for a day, or '
              'if there is a smell or colour that worries you. These are quick '
              'things to check and worth checking rather than watching.',
              kind: PpCalloutKind.doctor,
              title: 'When to ask a doctor instead',
            ),
            PpWhenLine('From birth onwards. The signals get easier to read from '
                'about 2 months and harder again once she is mobile.'),
          ],
        ),
        PpPage(
          id: 'grandmother_and_diapers',
          title: 'The grandmother method and diapers, together',
          subtitle: 'Both sides of this argument are right',
          format: 'ARTICLE',
          blocks: [
            PpIntro('This is one of the most common quiet arguments in an '
                'Indian home with a new baby. She started catching su-su at '
                'three weeks. You are using disposables and going back to '
                'work. Neither of you is being careless.'),
            PpArticle(
              heading: 'What each side is actually protecting',
              [
                'The elders in your house grew up where a nappy was a langot '
                    'that somebody washed by hand, and where a baby who was '
                    'caught reliably was a baby who made less work and got '
                    'fewer rashes. Cueing was not a philosophy, it was how the '
                    'house ran. When she says the baby can be trained now, she '
                    'is remembering something that worked.',
                'You are protecting your sleep, your job, a night feed at 3am '
                    'and the ability to leave the house without three changes '
                    'of clothes. A disposable nappy is not laziness. It is a '
                    'genuine solution to problems the older method did not '
                    'have to solve.',
                'The good news is that these two things do not actually '
                    'compete. Cueing does not require you to give up nappies, '
                    'and nappies do not stop you cueing. Almost every family '
                    'who does this well does both, at different times of day.',
              ],
            ),
            PpSteps(
              heading: 'How to blend the two',
              [
                PpStep('Nappy on as the backup, not the plan', 'She still wears one. You still offer the potty. '
                        'A catch means one less change, a miss means the '
                        'nappy did its job.'),
                PpStep('Cue at the easy times only', 'After waking, after feeds, before a bath. Give '
                        'the elders those windows and keep the nappy for '
                        'outings and nights.'),
                PpStep('Let whoever is holding her, catch her', 'If dadi is better at reading the signs, she is '
                        'better at it. That is a resource, not a comment on '
                        'you.'),
                PpStep('Agree the one sound out loud', 'Say it as a decision, at a calm moment, not '
                        'mid-catch. "We will all say su-su." Done.'),
                PpStep('Name what you will not do', 'No long holds, no scolding, no sitting her on a '
                        'cold floor in winter. Boundaries are easier to hold '
                        'when they are stated once, kindly, in advance.'),
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
                      'opponent. Handing her the part she is good at ends the '
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
                  say: 'She did not go this time, let us try after her feed.',
                  notThis: 'See, it did not work.',
                  why: 'A miss is a miss for both of you. Scoring points off '
                      'it in front of the baby teaches her the potty is where '
                      'the tension lives.',
                ),
              ],
            ),
            PpCallout(
              'There is no better mother here. A family that catches su-su '
              'from week three and a family that starts at two and a half both '
              'end up with a child who uses the toilet. The route is a '
              'household decision, not a moral one.',
            ),
            PpIndiaNote('If the disagreement is really about the washing, say '
                'so. A lot of nappy arguments are workload arguments wearing a '
                'parenting costume, and they get solved by deciding who does '
                'the buckets, not by anybody being right about babies.'),
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
                'is good for her skin. This is the least controversial thing in '
                'the whole section.'),
            PpArticle([
              'Nappy rash is mostly caused by three things together: warmth, '
                  'moisture and rubbing. Time with nothing on removes all '
                  'three at once, which is why an hour of bare-bottom floor '
                  'time often does more than a second layer of cream. In '
                  'Indian summers, when a nappy sits against skin in real '
                  'heat, that matters more than it does in a cold country.',
              'Parents who do diaper-free time also tend to notice their '
                  'baby\'s bowel rhythm, simply because it is impossible not '
                  'to. That is the practical connection between this and '
                  'su-su cueing. You are not doing anything clever, you are '
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
                PpStep('Mop with plain water and move on', 'No reaction, no comment. She should never learn '
                        'that a puddle is an event.'),
              ],
            ),
            PpCallout(
              'For a rash that is bright red with small spots at the edges, or '
              'one that has not settled in a week of air and barrier cream, '
              'ask a doctor. That pattern is often a yeast rash and it needs a '
              'different cream, not more of the same one.',
              kind: PpCalloutKind.doctor,
              title: 'When a rash needs more than air',
            ),
            PpWhenLine('From the first weeks. Easiest before she crawls, and '
                'worth restarting every summer.'),
            PpIndiaNote('A langot or a soft cotton nappy in the daytime is a '
                'good middle option, and it is what most Indian homes used '
                'before disposables. It breathes, it tells you immediately '
                'when it is wet, and it washes.'),
            PpLink('What changed with her skin or tummy?',
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
      mark: IntentMark.schoolMark,
      title: 'Is she ready yet?',
      blurb: 'The real signs, and why there is no prize for early.',
      hue: 268,
      bands: ['learning'],
      pages: [
        PpPage(
          id: 'readiness_signs',
          title: 'The signs she is ready',
          subtitle: 'And what it means when they are not there',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Readiness is not an age. It is a small cluster of things '
                'happening around the same time, and when they do, this gets '
                'dramatically easier. When they have not, effort mostly buys '
                'you frustration.'),
            PpArticle(
              heading: 'Why waiting is not losing time',
              [
                'Using a toilet needs several separate skills to arrive '
                    'together: feeling a full bladder, holding it for a '
                    'minute, telling somebody, getting there, and managing '
                    'clothes. A child who has four of those five will look '
                    'like she is failing at potty training when she is really '
                    'just missing one piece.',
                'Starting before the pieces are there does not build them '
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
                PpCard('She stays dry for two hours or more',
                    'Or wakes dry from a nap. This is bladder capacity and it '
                    'cannot be taught. It is the single most useful sign.'),
                PpCard('She tells you after she has gone',
                    'Even just pulling at the nappy or saying "gandi". She '
                    'has connected the feeling to the event.'),
                PpCard('She tells you before',
                    'The one you are waiting for. Once this appears, the rest '
                    'is usually weeks not months.'),
                PpCard('She is interested in the bathroom',
                    'Follows you in, wants to flush, copies. Curiosity is '
                    'half of the motivation.'),
                PpCard('She can pull her own pants down',
                    'Roughly. It matters more than people expect, because a '
                    'child who cannot undress will not make it in time.'),
                PpCard('She can follow a two-step instruction',
                    '"Take your pants off and sit down." Without that, every '
                    'trip needs you.'),
              ],
            ),
            PpSteps(
              heading: 'What to do while you wait',
              [
                PpStep('Let her see people use the toilet', 'The most effective preparation there is, and it '
                        'costs nothing. Indian homes are rarely private '
                        'enough for this to be a problem.'),
                PpStep('Name what is happening, plainly', 'One word for wee and one for poo, used by '
                        'everybody. Start using them now.'),
                PpStep('Put a potty in the bathroom and ignore it', 'Let it become furniture. A potty she has known '
                        'for a month is far less strange than one that '
                        'appears on day one.'),
                PpStep('Keep up the diaper-free stretches', 'Bare-bottom time is where she notices what her '
                        'own body does.'),
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
                    'If it is clearly not working, pausing for six weeks is a '
                    'good decision, not a failure. Say so out loud so she '
                    'hears it that way too.'),
              ],
            ),
            PpCallout(
              'Even with every sign present, going on her own from start to '
              'finish is usually not solid until around three. Mostly-dry days '
              'with the occasional accident is the real finish line for a '
              'two-year-old, and it is a good one.',
              title: 'What "done" honestly looks like',
            ),
            PpWhenLine('Most families see the signs somewhere between 18 months '
                'and 3 years. Later is common and it is not a delay.'),
            PpIndiaNote('Summer is the natural time to start in most of India. '
                'Fewer clothes, faster drying, and bare-bottom time is '
                'comfortable rather than cold. If you can choose the month, '
                'choose a warm one.'),
            PpVideoSlot(
              title: 'What readiness actually looks like',
              subtitle: 'Three real toddlers, and which of the signs each one '
                  'is showing.',
              minutes: '6 MIN',
              slotId: 'potty/readiness_signs',
            ),
          ],
        ),
        PpPage(
          id: 'which_approach',
          title: 'Su-su, child-led, or the three-day method',
          subtitle: 'Pick by your household, not by the internet',
          format: 'COMPARISON TABLE',
          blocks: [
            PpIntro('There are three approaches families in India actually use. '
                'None of them is wrong. They suit very different houses, and '
                'the honest way to choose is by who is home and how your week '
                'looks.'),
            PpTable(
              heading: 'The three, side by side',
              columns: [
                'What matters',
                'Su-su cueing',
                'Child-led',
                'Three-day method'
              ],
              rows: [
                [
                  'When it starts',
                  'A few weeks old, onwards',
                  'When she shows the signs, often 2 to 3 years',
                  'A chosen weekend, usually after 2 years'
                ],
                [
                  'Who does the work',
                  'The adults, for a long time',
                  'Mostly the child, at her pace',
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
                  'Few, because she led',
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
                  'She stops signalling',
                  'Almost none',
                  'Refusal and withholding'
                ],
              ],
            ),
            PpArticle(
              heading: 'How most Indian families actually end up doing it',
              [
                'In practice this is rarely a clean choice. The common path is '
                    'su-su cueing in the first year because somebody in the '
                    'house knows how, then a long child-led stretch, then a '
                    'more focused fortnight in one summer when she is clearly '
                    'ready. That is three approaches in sequence and it works '
                    'well.',
                'The three-day method is the one worth being careful with. It '
                    'is real and it does work for some children, but it '
                    'assumes a house where an adult can follow a toddler for '
                    'three days and where pressure does not build. When it '
                    'goes wrong it goes wrong in a specific way: the child '
                    'starts holding it in. That is the one outcome worth '
                    'avoiding, because it takes far longer to undo than '
                    'starting late ever would.',
              ],
            ),
            PpCallout(
              'Whichever you pick, the deciding factor is your household, not '
              'the method. The best approach is the one the people in your '
              'house can actually do, consistently, without anybody getting '
              'angry.',
            ),
            PpWhenLine('Choose once she is showing two or three readiness '
                'signs. Re-choose freely if it is not working.'),
            PpIndiaNote('If a helper or a grandparent is with her most of the '
                'day, the method has to be theirs too. A plan the person doing '
                'the hours did not agree to is not a plan.'),
            PpLink('Short potty masterclass',
                surfaceId: 'pp_courses',
                blurb: 'A paid 40-minute walkthrough of one full fortnight, '
                    'step by step, if you would rather be shown than read. '
                    'Everything in this section stays free.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  BAND B — how to actually do it
    // =========================================================================
    PpArea(
      id: 'how_to_do_it',
      mark: IntentMark.stepsMark,
      title: 'Starting out, day by day',
      blurb: 'The potty, the routine, the words, and the Indian toilet.',
      hue: 88,
      bands: ['learning'],
      pages: [
        PpPage(
          id: 'introducing_potty',
          title: 'Introducing the potty',
          subtitle: 'The first week, slowly',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('The goal of the first week is not a single successful wee. '
                'It is that the potty becomes an ordinary, boring, friendly '
                'object she is happy to sit on.'),
            PpSteps([
              PpStep('Bring it home and let her look at it', 'Let her carry it around, put a toy in it, sit on '
                      'it with the lid down. Do not correct any of that.'),
              PpStep('Give it a name and a place', 'Same word, same corner of the bathroom, every '
                        'day. Predictability is doing most of the work here.'),
              PpStep('Sit her on it fully clothed, once a day', 'A minute, no expectation, no watching her face. '
                      'This step alone often takes three or four days and it '
                      'is not wasted time.'),
              PpStep('Then sit her on it bare, at an easy moment', 'Right after a nappy comes off wet is ideal, '
                      'because the timing is already right.'),
              PpStep('Tip a wet nappy into it and name what happened', '"Su-su goes here." A surprisingly effective step, '
                      'because it explains the point of the object.'),
              PpStep('Let her flush, or empty it, if she wants to', 'Being the one who deals with it turns the whole '
                      'thing from something done to her into something she '
                      'does.'),
              PpStep('Fold it into the day, and stop making it a lesson', 'Once she sits willingly, move to the daily '
                      'routine. The introduction is over.'),
            ]),
            PpCallout(
              'If she refuses to sit, stop and try again in a few days. A child '
              'who has been held on a potty against her will remembers it, and '
              'that is much harder to undo than a slow start.',
            ),
            PpWhenLine('The introduction takes about a week. Any time from '
                'about 18 months, once she is interested.'),
            PpIndiaNote('A low plastic potty that lets her feet rest flat on '
                'the floor works better than a seat on the big toilet, and it '
                'is closer to the squat she will eventually use anyway. Feet '
                'flat matters more than the design.'),
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
                PpStep('As soon as she wakes in the morning', 'The most reliable one of the day. Straight from '
                        'bed to potty, before anything else.'),
                PpStep('About twenty minutes after each meal', 'Eating moves the bowel. This is the moment most '
                        'poos are catchable.'),
                PpStep('After every nap', 'Same as the morning, smaller. Do it before she '
                        'is fully distracted.'),
                PpStep('Before the bath', 'She is already undressed, so there is no '
                        'resistance to overcome. An easy win.'),
                PpStep('Last thing before bed', 'Part of the bedtime routine, alongside brushing '
                        'teeth. Not a special event.'),
              ],
            ),
            PpArticle(
              heading: 'Making it stick',
              [
                'Keep each sit short, about a minute or two. A long sit turns '
                    'into a battle and she learns to resist the whole thing.',
                'Say the same sentence each time, in the same tone. "Potty '
                    'time, then we will read." It is not a question and it is '
                    'not a fight, it is just what happens next.',
                'Everyone in the house does the same five moments. If the '
                    'helper does three of them and dadi does a different two, '
                    'she is learning that the rules depend on who is holding '
                    'her.',
                'Once she starts telling you in between, drop the moments she '
                    'no longer needs. The routine is scaffolding, not the '
                    'finished building.',
              ],
            ),
            PpCallout(
              'A calm "you did it" is plenty. Big celebrations, clapping and '
              'sweets make the potty high-stakes, and the day she cannot '
              'perform she will feel she has let you down.',
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
                'word. If the four adults around her use four different words, '
                'she has to learn four, and she will use none of them at the '
                'moment it matters.'),
            PpArticle([
              'Pick one word for wee and one for poo. Su-su and potty are what '
                  'most Indian families use and they work perfectly well. '
                  'What matters is not which word, it is that dadi, nani, the '
                  'helper, the father and the playschool teacher all use the '
                  'same one.',
              'Say it every time, including when you are the one going and '
                  'including when it lands in the nappy. Naming the miss out '
                  'loud, without any disapproval, is how she learns the word '
                  'attaches to a feeling rather than to a place.',
              'Avoid words that carry disgust. "Gandi", "chee" and pulling a '
                  'face teach her that what her body does is shameful, which '
                  'is the seed of both refusal and holding it in. It is a '
                  'body function and the tone should be as flat as the one you '
                  'use for eating.',
              'When she starts at playschool, tell them her word on day one. A '
                  'child who asks for su-su and is not understood will simply '
                  'stop asking.',
            ]),
            PpScript(
              heading: 'The words themselves',
              [
                PpScriptLine(
                  say: 'Su-su is coming? Let us go to the potty.',
                  notThis: 'Do you need to go? Are you sure? Really sure?',
                  why: 'One clear statement. Three questions in a row invites '
                      'a no and then makes you overrule it.',
                ),
                PpScriptLine(
                  say: 'Su-su came in your pants. That happens. Let us change.',
                  notThis: 'Chee, gandi! Why did you not tell me?',
                  why: 'Disgust and blame are what turn an accident into '
                      'something she hides from you.',
                ),
                PpScriptLine(
                  say: 'You told me before it came. That was the hard part.',
                  notThis: 'Good girl! See, that was not so difficult!',
                  why: 'Naming what she did teaches. Praising who she is puts '
                      'her whole self on the line the next time she misses.',
                ),
              ],
            ),
            PpWhenLine('Agree the words before you start, from about 15 months. '
                'It is a five-minute conversation.'),
            PpIndiaNote('If your home runs in two languages, pick the word from '
                'whichever one the person with her most of the day speaks. She '
                'will pick up the other soon enough.'),
          ],
        ),
        PpPage(
          id: 'indian_toilet',
          title: 'The Indian toilet, and going out',
          subtitle: 'Squatting, travel, and other people\'s bathrooms',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Most children in India will use a squat toilet, a bucket '
                'and mug, and a bathroom that is nothing like the one at home. '
                'None of that is a complication to solve later. It is the main '
                'event.'),
            PpArticle(
              heading: 'Why squatting is worth teaching properly',
              [
                'A full squat with feet flat puts the body in a position that '
                    'makes passing a stool easier, which is why so many '
                    'people find it more comfortable. For a child learning, it '
                    'also means her feet are supported, and feet dangling in '
                    'the air is one of the quiet reasons a toddler cannot '
                    'relax on a Western toilet.',
                'A small child\'s balance over an Indian toilet is the real '
                    'difficulty, not the position itself. She needs something '
                    'to hold and an adult close by until she is steady, and '
                    'that takes a few weeks of practice rather than any '
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
                PpStep('Give her something to hold', 'Your hands, a wall bar, the edge of a bucket '
                        'stand. Balance is the whole problem.'),
                PpStep('Stand close, every time, at first', 'A slip into an Indian toilet is frightening and '
                        'it can end the cooperation for weeks.'),
                PpStep('Teach the mug before the wiping', 'Left hand, water, then rinse. Start with you '
                        'pouring and her hand guided.'),
                PpStep('Then the wash basin, properly, every single time', 'Soap and twenty seconds. This is the part that '
                        'actually keeps her well.'),
              ],
            ),
            PpCards(
              heading: 'Away from home',
              hue: 88,
              [
                PpCard('Go before you leave, always',
                    'The single most useful travel habit. It removes most of '
                    'the problem.'),
                PpCard('Carry a spare set and a bag',
                    'Two changes of clothes and a plastic bag. Planning for '
                    'an accident is what lets you stay calm during one.'),
                PpCard('Scout the bathroom on arrival',
                    'At a wedding, a relative\'s house, a restaurant. Knowing '
                    'where it is saves the two minutes you will not have.'),
                PpCard('A travel potty for long journeys',
                    'A folding potty or a lined one in the car is worth it '
                    'for train and road travel.'),
                PpCard('Public toilets can wait for later',
                    'It is fine to hold her over a drain or use a corner on a '
                    'long journey. Nobody is grading you.'),
                PpCard('Expect a step backwards while travelling',
                    'New bathroom, new bed, no routine. It comes back within '
                    'a week of being home.'),
              ],
            ),
            PpCallout(
              'If she is refusing to poo while you are travelling, do not push '
              'it. Two days of holding on becomes a hard, painful stool and '
              'then a child who is frightened of pooing at all. Water, fruit '
              'and a relaxed attitude are the whole plan.',
            ),
            PpWhenLine('Start the squat practice from about 2 years, alongside '
                'the potty. Before any long trip.'),
            PpIndiaNote('Bucket and mug washing is a skill she will use her '
                'whole life, and it is easier to learn at three than later. '
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
            PpIntro('There are two or three genuine practical differences and a '
                'lot of talk that is not useful. Here is the short version.'),
            PpArticle([
              'Boys do, on average, get there a few months later than girls. '
                  'It is an average across thousands of children and it says '
                  'nothing at all about your son. Plenty of boys manage it '
                  'before plenty of girls.',
              'Teach a boy sitting down first, for both. Standing to wee is a '
                  'separate skill with its own aim problem, and adding it on '
                  'day one usually means a child who is confused about which '
                  'thing he is doing. Once sitting is easy, standing takes a '
                  'week, often taught fastest by an older cousin or his '
                  'father.',
              'For girls, wiping front to back is the one thing worth being '
                  'firm about, because getting it the other way round is a '
                  'common cause of urine infections. With a mug it is the same '
                  'rule: water and hand move front to back.',
              'For boys, a gentle reminder to point down before he starts '
                  'saves a great deal of cleaning, and if the foreskin is '
                  'tight, do not pull it back to clean. Wash the outside '
                  'only.',
            ]),
            PpCallout(
              'See a doctor if she or he cries or strains when passing urine, '
              'if there is a fever with no other cause, if the urine smells '
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
      ],
    ),

    // =========================================================================
    //  BAND B — when it is bumpy. The health edge lives here.
    // =========================================================================
    PpArea(
      id: 'when_bumpy',
      mark: IntentMark.chartLog,
      title: 'Accidents, refusals and going backwards',
      blurb: 'All of it normal. What to do, and the two things worth a doctor.',
      hue: 32,
      bands: ['learning'],
      pages: [
        PpPage(
          id: 'accidents_are_normal',
          title: 'Accidents are normal',
          subtitle: 'Every single child, for months',
          format: 'ARTICLE',
          blocks: [
            PpIntro('There is no version of this where a child learns without '
                'accidents. They are not a sign that you started too early, '
                'that she is being lazy, or that anything is going wrong. They '
                'are the learning itself.'),
            PpArticle(
              heading: 'Why they happen, even weeks in',
              [
                'A child who is mostly dry is doing something quite hard: '
                    'noticing a small internal signal, interrupting whatever '
                    'she is enjoying, and acting in time. Any one of those '
                    'three can fail on any given afternoon, and being '
                    'absorbed in play is the most common reason by far.',
                'Accidents also cluster. A run of three in one day after a '
                    'dry week usually means she is tired, unwell, '
                    'over-excited, or somewhere new. It is almost never a '
                    'decision.',
                'The clean-up is the actual lesson, and what she learns from '
                    'it is decided entirely by your face.',
              ],
            ),
            PpSteps(
              heading: 'What to do, in the moment',
              [
                PpStep('Say one flat sentence', '"Su-su came in your pants. Let us change." No '
                        'sigh, no eyebrows, no lecture.'),
                PpStep('Clean her up matter-of-factly', 'The same energy you use for a spilled glass of '
                        'water. Warm water, dry clothes, done.'),
                PpStep('Let her help, if she is willing', 'Carrying the wet clothes to the bucket. Helping '
                        'is not punishment as long as your tone is not.'),
                PpStep('Do not make her sit on the potty afterwards', 'It is already empty and it reads as a '
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
                    'Not "chee", not "big girls do not do this", not telling '
                    'the story to a visitor while she is in the room.'),
                PpCard('Do not ask why she did not tell you',
                    'She does not know why. The question only teaches her '
                    'that the answer matters and that she got it wrong.'),
                PpCard('Do not put her back in nappies as a punishment',
                    'Going back to nappies for practical reasons is fine. '
                    'Doing it as a consequence is not.'),
                PpCard('Do not compare her to anyone',
                    'Not a cousin, not a sibling, not a neighbour\'s child. '
                    'It changes nothing about her bladder and a great deal '
                    'about how she feels.'),
                PpCard('Do not let anyone else shame her either',
                    'Including relatives who mean it kindly. One sentence '
                    'from you, in front of her, is worth more than an '
                    'apology later.'),
              ],
            ),
            PpCallout(
              'Nobody has failed here. Not her, and not you. A child who is '
              'dry four days out of five at two and a half is doing well, and '
              'the fifth day is not evidence of anything.',
            ),
            PpCallout(
              'Ask a doctor if a child who was reliably dry starts wetting '
              'again with no obvious reason, if she is suddenly drinking and '
              'weeing far more than usual, if it hurts when she goes, or if '
              'she is dribbling constantly rather than having occasional '
              'accidents. These are worth a quick check rather than a wait.',
              kind: PpCalloutKind.doctor,
              title: 'When accidents are worth a doctor',
            ),
            PpWhenLine('Expect accidents for months after she is mostly dry, '
                'and the odd one for a year or more.'),
            PpIndiaNote('If a helper or a grandparent is cleaning up most of '
                'the accidents, they need to hear the no-shame rule from you '
                'directly. It is not fair to expect them to guess it, and one '
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
          title: 'She was doing so well, and now she is not',
          subtitle: 'Regressions, and why they pass',
          format: 'ARTICLE',
          blocks: [
            PpIntro('A child who was dry for a month and is now wetting daily '
                'has not forgotten how. Something has changed, and her bladder '
                'is where it is showing up. This is one of the most common '
                'things parents write in about.'),
            PpArticle(
              heading: 'Why going backwards happens',
              [
                'Toilet control is one of the first things a small child owns '
                    'entirely, so it is one of the first things to wobble when '
                    'her world moves. It is not manipulation and it is not '
                    'attention-seeking in any deliberate sense. It is a two '
                    'year old with no words for upheaval.',
                'Regressions almost always have a trigger, and the trigger is '
                    'usually obvious once you look for it. Naming it out loud '
                    'to yourself helps, because it turns "she has stopped '
                    'cooperating" back into "she has a new baby brother".',
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
                    'The most common one of all. Toilet independence is a '
                    'thing she can give back in exchange for being small '
                    'again.'),
                PpCard('Starting playschool or daycare',
                    'New bathroom, unfamiliar adult to ask, and a rule about '
                    'when she may go.'),
                PpCard('Travel, or a stay with relatives',
                    'Different toilet, different routine, and nobody watching '
                    'the five moments.'),
                PpCard('Any illness',
                    'Fever, loose motions, a cold. Control is the first thing '
                    'to go and the first to come back.'),
                PpCard('A move, or a change of room',
                    'Including moving out of your bed. Anything that changes '
                    'where she sleeps.'),
                PpCard('Tension between the adults',
                    'Children read a house very accurately. This one is hard '
                    'to hear and it is often true.'),
              ],
            ),
            PpSteps(
              heading: 'What to do',
              [
                PpStep('Go back to the five fixed moments', 'Quietly, without announcing that you are '
                        'starting again. Scaffolding back up for a fortnight.'),
                PpStep('Name the real thing, not the wetting', '"There is a lot changing right now." She may not '
                        'answer. She still hears it.'),
                PpStep('Give her time and attention that has nothing to do '
                    'with the potty', 'Ten unhurried minutes a day. For a new-sibling '
                        'regression this is more effective than anything you '
                        'do in the bathroom.'),
                PpStep('Use a nappy again if it makes life liveable', 'At night, on a journey, at daycare. Explicitly '
                        'not a punishment and say so.'),
                PpStep('Drop the subject when she is not in the bathroom', 'The more airtime it gets, the more it becomes an '
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
              'smell, blood, a big jump in thirst, or if it has gone on for '
              'more than about six weeks with no trigger you can find. A '
              'sudden regression with no life change behind it is worth a '
              'urine test.',
              kind: PpCalloutKind.doctor,
              title: 'When a regression needs checking',
            ),
            PpConsult(
              title: 'A short call about a stubborn regression',
              whoFor: 'For a regression that has run past six weeks, or one '
                  'you cannot find a reason for. A paediatrician looks at what '
                  'changed, rules out an infection, and tells you whether to '
                  'do anything at all. Not needed for the ordinary kind that '
                  'follows a new baby or a holiday.',
              surfaceId: 'pp_experts',
              role: 'pediatrician',
            ),
            PpWhenLine('Most common between 2 and 4 years. Usually settles in '
                '2 to 6 weeks.'),
          ],
        ),
        PpPage(
          id: 'withholding_constipation',
          title: 'She is holding it in',
          subtitle: 'Withholding, painful poos and constipation',
          format: 'ARTICLE',
          blocks: [
            PpIntro('This is the one part of toilet learning that can genuinely '
                'become a medical problem, and it is also the one most likely '
                'to be missed. A child who is refusing to poo needs help '
                'early, not patience.'),
            PpArticle(
              heading: 'How the cycle starts',
              [
                'It usually begins with one hard, painful stool. She '
                    'remembers it, so the next time the urge comes she holds '
                    'on. Holding on makes the stool harder and drier, which '
                    'makes the next one hurt more, which makes her hold on '
                    'harder. That loop can tighten within a week.',
                'The confusing part is that a badly constipated child often '
                    'has runny leaks in her pants, which looks like diarrhoea '
                    'or like carelessness. Softer stool is passing around a '
                    'hard mass that is stuck. Treating that as an accident '
                    'problem misses what is happening.',
                'She may also start wetting more, because a full bowel presses '
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
                    'Or a clear change from her own normal pattern.'),
                PpCard('Large, hard, or very wide stools',
                    'The kind that hurt, or that a parent notices in the pan.'),
                PpCard('Crying before or during',
                    'Pain is the engine of the whole cycle.'),
                PpCard('Small smears or runny leaks in her pants',
                    'Often mistaken for laziness. It is frequently the '
                    'opposite.'),
                PpCard('Asking for a nappy to poo in',
                    'Very common, and worth allowing for now. A child who '
                    'poos in a nappy is much better off than one who does not '
                    'poo at all.'),
              ],
            ),
            PpSteps(
              heading: 'What helps at home',
              [
                PpStep('Take the pressure off completely', 'Stop asking her to poo on the potty for now. The '
                        'immediate goal is a soft, painless poo anywhere at '
                        'all.'),
                PpStep('Water, through the day', 'The simplest and most effective thing. A small '
                        'glass at each of the fixed moments.'),
                PpStep('Fruit that actually works', 'Papaya, pear, prunes or kishmish soaked '
                        'overnight, orange, guava. Papaya is the one most '
                        'Indian families find reliable.'),
                PpStep('Move the food towards whole grains and dal', 'Less maida and biscuits, more roti, dal, '
                        'vegetables and curd. Warm milk with a little ghee at '
                        'night helps many children.'),
                PpStep('Feet flat and knees up when she does go', 'A stool under her feet on a Western toilet, or a '
                        'proper squat. Position genuinely changes how hard it '
                        'is.'),
                PpStep('Running and playing every day', 'Movement moves the bowel. A day mostly indoors '
                        'shows up the next morning.'),
                PpStep('Sit after meals with no expectation', 'Five minutes with a book, when the bowel is '
                        'naturally active. Sitting is the goal, not '
                        'producing.'),
              ],
            ),
            PpCallout(
              'Do not make her sit until she poos, do not tell her she is '
              'being naughty, and do not let anybody threaten her about it. '
              'Fear is what started the cycle and more fear tightens it.',
            ),
            PpCallout(
              'See a doctor if she has been withholding for more than about a '
              'week despite these changes, if there is blood, a tear or a '
              'crack around the anus, if poos are painful enough that she '
              'cries, if she has fewer than three a week for a fortnight, if '
              'she is leaking in her pants, if her tummy is hard or swollen, '
              'or if she is not gaining weight. Constipation in a small child '
              'is very treatable and it gets harder the longer it runs. Do not '
              'give any laxative, churan or home purgative to a child without '
              'a doctor telling you which one and how much.',
              kind: PpCalloutKind.doctor,
              title: 'When to see a doctor about this',
            ),
            PpConsult(
              title: 'A short consult about withholding',
              whoFor: 'For a child who is holding it in, has painful poos, or '
                  'is leaking in her pants. A paediatrician checks whether '
                  'there is a stuck mass to clear first, decides whether '
                  'anything is needed, and gives you a plan. Worth doing '
                  'early rather than after a month of trying.',
              surfaceId: 'pp_experts',
              role: 'pediatrician',
            ),
            PpWhenLine('Act within a week of noticing withholding. This is the '
                'one part of the section where waiting does not help.'),
            PpIndiaNote('Very common in Indian toddler diets that lean on '
                'maida, biscuits and lots of milk with little fruit. Two '
                'papaya slices a day and less milk is often the entire fix, '
                'and it is worth trying before anything else.'),
            PpLink('She has not pooped in a few days',
                surfaceId: 'pp_what_changed',
                blurb: 'Answer a few questions about her tummy and get a '
                    'clearer read on what is going on.'),
          ],
        ),
        PpPage(
          id: 'potty_refusal',
          title: 'She is scared of the potty',
          subtitle: 'Refusal, and how to un-scare it',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('A child who screams at the sight of the potty is not being '
                'difficult. Something about it has become frightening, and '
                'usually you can find out what.'),
            PpArticle([
              'The common fears are specific and reasonable. The flush is very '
                  'loud. A big toilet is a hole she could fall into. Her feet '
                  'dangle and she has nothing to brace against. Something '
                  'coming out of her body and then disappearing is genuinely '
                  'strange when nobody has explained it. Or she remembers one '
                  'poo that hurt.',
              'Work out which one it is by watching where the refusal starts. '
                  'Refusing to enter the bathroom is different from sitting '
                  'happily and then panicking at the flush, and each has a '
                  'different fix.',
              'Then make that one thing smaller. Do not flush while she is in '
                  'the room. Move to a low potty with feet on the floor. Let '
                  'her keep a nappy for poos while she rebuilds trust. Sit '
                  'with her, on the floor, and read something.',
              'And stop asking for a fortnight. A refusal that is met with '
                  'daily requests hardens. One that is left alone while the '
                  'fear is quietly removed usually softens on its own.',
            ]),
            PpCallout(
              'If she will only poo in a nappy, let her, for now. Pooing '
              'somewhere is much more important than pooing in the right '
              'place, and forcing the issue is how withholding starts.',
            ),
            PpCallout(
              'Ask a doctor if the refusal is about pain rather than fear, if '
              'there is blood or a crack around the anus, or if she has gone '
              'several days without a poo while refusing. Pain has a physical '
              'cause and it needs treating before any of the above will work.',
              kind: PpCalloutKind.doctor,
              title: 'When the fear is really pain',
            ),
            PpWhenLine('Most common between 2 and 3.5 years. Give any fix two '
                'to three weeks before changing tack.'),
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
            PpIntro('A toddler cannot hold five steps in her head, but she can '
                'read five pictures. Half an hour with a paper and sketch pens '
                'gives her something to follow without an adult narrating.'),
            PpArticle(
              heading: 'What it is',
              [
                'One sheet of paper, five simple drawings in a row, stuck at '
                    'her eye level in the bathroom. Pants down, sit, wipe or '
                    'wash, pull pants up, wash hands. That is the whole '
                    'thing.',
                'It is a memory aid, and it is most useful for the steps '
                    'children forget rather than the sitting: the hand '
                    'washing and the pulling up. It also means a helper or a '
                    'grandparent prompts the same sequence you do.',
              ],
            ),
            PpSteps(
              heading: 'How to do it',
              [
                PpStep('Draw it with her, badly', 'Stick figures are fine. Her having drawn it is '
                        'most of why she will look at it.'),
                PpStep('Five pictures, left to right, no words', 'She cannot read. Numbers are fine, sentences are '
                        'decoration for adults.'),
                PpStep('Stick it at her height, where she squats or sits', 'Eye level for her, not for you.'),
                PpStep('Point at it instead of instructing', 'Tapping the third picture is better than saying '
                        '"now wash". She gets to be the one doing it.'),
                PpStep('Leave it up and stop mentioning it', 'Once she uses it, your job is done. Take it down '
                        'whenever she stops needing it.'),
              ],
            ),
            PpCallout(
              'No stars, no ticks, no counting days. A chart that records '
              'whether she succeeded turns a wet afternoon into a visible '
              'failure on the wall, and this is the last subject that should '
              'have a score attached.',
            ),
            PpWhenLine('From about 2 years, once she is sitting willingly. '
                'Useful for a few months.'),
            PpIndiaNote('If the bathroom is shared and you cannot stick '
                'anything up, keep the sheet in the bucket cupboard and bring '
                'it in. It works exactly as well.'),
          ],
        ),
        PpPage(
          id: 'sit_and_read',
          title: 'Sit-and-read potty time',
          subtitle: 'Two books by the potty',
          format: 'ACTIVITY',
          blocks: [
            PpIntro('The single easiest thing on this list. Keep two or three '
                'board books next to the potty and read one while she sits. '
                'Sitting stops being a task and becomes a pause in the day.'),
            PpArticle(
              heading: 'What it is',
              [
                'A small pile of books that live by the potty and nowhere '
                    'else. She sits, you read, and neither of you is watching '
                    'to see whether anything happens.',
                'The reason it works is that relaxing is a physical '
                    'requirement. A child who is bored, hurried or being '
                    'watched tenses up, and a tense child cannot pass a '
                    'stool. Reading solves that without either of you trying '
                    'to.',
              ],
            ),
            PpSteps(
              heading: 'How to do it',
              [
                PpStep('Choose two or three sturdy board books', 'They will get wet. Do not use the good ones or '
                        'anything borrowed.'),
                PpStep('Keep them only in the bathroom', 'The novelty is what makes sitting appealing.'),
                PpStep('Read while she sits, and stop when she stands', 'She decides when it is over, not the end of the '
                        'story.'),
                PpStep('Do not comment on whether anything happened', 'Not even encouragement. The point is that '
                        'nobody is watching.'),
                PpStep('Use it for the after-meal sit especially', 'That is when the bowel is active and when '
                        'relaxing matters most.'),
              ],
            ),
            PpCallout(
              'Cap it at about five minutes. A long sit gets uncomfortable and '
              'starts to feel like being kept there, which is the opposite of '
              'what this is for.',
            ),
            PpWhenLine('From about 2 years. Especially useful for a child who '
                'is withholding poos.'),
            PpIndiaNote('If books by an Indian toilet are impractical, a couple '
                'of picture cards in a plastic sleeve do the same job and wipe '
                'clean.'),
            PpLink('Board books that survive a bathroom',
                surfaceId: 'pp_products',
                blurb: 'Cheap, wipeable and short. That is the whole brief.'),
          ],
        ),
        PpPage(
          id: 'teach_the_toy',
          title: 'Teach the toy',
          subtitle: 'She explains it to a doll',
          format: 'ACTIVITY',
          blocks: [
            PpIntro('Give her a doll or a soft toy and ask her to show it how '
                'the potty works. A child who is being taught is being '
                'corrected; a child who is teaching is in charge.'),
            PpArticle(
              heading: 'What it is',
              [
                'A short bit of pretend play where she is the adult. The toy '
                    'sits on the potty, she narrates the steps, and she is the '
                    'one who knows what happens next.',
                'It is useful for two reasons. It shows you what she has '
                    'actually understood, including the parts she has got '
                    'wrong, and it gives her some authority over a subject '
                    'where she is usually being managed. For a child who has '
                    'started refusing, this often reopens the door when '
                    'nothing else does.',
              ],
            ),
            PpSteps(
              heading: 'How to do it',
              [
                PpStep('Pick a toy she likes and hand it over', '"Teddy does not know how to do su-su. Will you '
                        'show him?"'),
                PpStep('Let her run it, wrong steps included', 'Do not correct the order. Watch what she skips, '
                        'because that is the part she has not learned.'),
                PpStep('Ask the toy the questions, not her', '"Teddy, are you scared of the flush?" She will '
                        'answer for him, and sometimes she tells you exactly '
                        'what is wrong.'),
                PpStep('Let the toy have an accident', 'And let her clean it up calmly. This is where '
                        'she practises the tone you have been using on her.'),
                PpStep('Keep it short and let her walk away', 'Two minutes is plenty. It is a game, not a '
                        'lesson.'),
              ],
            ),
            PpCallout(
              'Listen to what she says to the toy. Children who cannot tell a '
              'parent that the flush is frightening or that it hurt last time '
              'will often tell a doll, and it is the most reliable way to find '
              'out what the real problem is.',
            ),
            PpWhenLine('From about 2.5 years, once she is talking in short '
                'sentences.'),
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
      title: 'Dry nights, and doing it herself',
      blurb: 'Night dryness, wiping, and toilets away from home.',
      hue: 232,
      bands: ['dry'],
      pages: [
        PpPage(
          id: 'night_dryness',
          title: 'Dry nights come later',
          subtitle: 'And you cannot train them',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Day dryness is a skill she learns. Night dryness is mostly '
                'a physical development that happens to her, and it arrives '
                'months or years after the days are sorted. That gap is normal '
                'and it is not a training problem.'),
            PpArticle(
              heading: 'Why nights are different',
              [
                'Staying dry all night needs two things a small child cannot '
                    'practise. Her body has to make less urine while she '
                    'sleeps, which depends on a hormone that switches on at '
                    'its own pace, and her bladder has to be able to hold a '
                    'whole night\'s worth. Neither responds to effort, '
                    'encouragement or waking her up.',
                'This is why a child can be perfectly dry in the day for a '
                    'year and still be wet every single night. Nothing has '
                    'gone wrong. The night part simply has not switched on '
                    'yet.',
                'Roughly one in five five-year-olds still wets the bed, and '
                    'it becomes less common every year after that with no '
                    'treatment at all. Being wet at night at five is common '
                    'enough that there is very likely another child in her '
                    'class in the same position.',
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
                  'late, she may be too.',
            ),
            PpSteps(
              heading: 'What actually helps',
              [
                PpStep('Wait for a run of dry mornings before dropping the '
                    'nappy', 'Several dry nights in a row means the switch has '
                        'flipped. Removing the nappy earlier just makes '
                        'laundry.'),
                PpStep('Most of her drinking earlier in the day', 'Not a dry evening, that is unkind and '
                        'unnecessary. Just shift the volume forward.'),
                PpStep('Toilet last thing, every night, as routine', 'After brushing, before the story. Part of '
                        'bedtime, not a special request.'),
                PpStep('A waterproof sheet and a spare set within reach', 'Two minutes of preparation buys you a calm 2am '
                        'instead of a stripped bed and a search for sheets.'),
                PpStep('A night light and a clear path to the bathroom', 'Many children wet the bed partly because getting '
                        'there in the dark is frightening.'),
                PpStep('Change her without conversation', 'Half asleep, minimal light, no discussion. Talk '
                        'about it in the morning only if she wants to.'),
              ],
            ),
            PpCards(
              heading: 'What does not work',
              hue: 32,
              [
                PpCard('Waking her at midnight',
                    'It empties the bladder but it does not teach her body '
                    'anything, and it costs everybody sleep.'),
                PpCard('Cutting fluids in the evening',
                    'Beyond a mild shift, this leaves her thirsty and does '
                    'not fix a hormone.'),
                PpCard('Any kind of reward or chart',
                    'She is not choosing this. A reward for something outside '
                    'her control only tells her she is failing.'),
                PpCard('Punishment, or making her wash her own sheets as a '
                    'consequence',
                    'This is the fastest way to a child who hides wet '
                    'bedding.'),
                PpCard('Comparing her to a sibling',
                    'Bedwetting runs in families and has nothing to do with '
                    'effort.'),
              ],
            ),
            PpCallout(
              'She is asleep when it happens. There is no version of this she '
              'is choosing, so there is nothing here she can be blamed for.',
            ),
            PpWhenLine('Dry nights any time from 3 to 6 years, and later is '
                'still within normal.'),
            PpIndiaNote('In a shared bed or on a floor mattress, a waterproof '
                'sheet under the cotton one saves the whole bedding. Keep a '
                'dry set folded within arm\'s reach so a 2am change does not '
                'wake the house.'),
            PpVideoSlot(
              title: 'Why dry nights take so long',
              subtitle: 'The hormone, the bladder, and why waking her at '
                  'midnight does not help.',
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
            PpIntro('If she is five or six and still wet most nights, you are '
                'not alone and there is nothing wrong with her. It is also not '
                'something you simply have to endure, because from about five '
                'there are treatments that work.'),
            PpArticle(
              heading: 'What is going on',
              [
                'Bedwetting past five is usually one of three things: her body '
                    'still makes too much urine at night, her bladder holds '
                    'less than a night\'s worth, or she sleeps too deeply to '
                    'wake for the signal. Often two of them together. All '
                    'three are physical.',
                'It runs strongly in families. If either parent was a late '
                    'bedwetter, the odds go up considerably, which is worth '
                    'saying out loud in front of her because it moves the '
                    'story from "what is wrong with me" to "this is how our '
                    'family is built".',
                'Constipation is a very common hidden cause, and it is the '
                    'first thing worth ruling out. A full bowel presses on the '
                    'bladder all night. Treating the constipation sometimes '
                    'ends the bedwetting by itself.',
                'The part that does real damage is not the wet bed. It is a '
                    'child who has decided she is disgusting, will not sleep '
                    'at a cousin\'s house, and hides sheets. Protecting her '
                    'from that is the actual job while you wait or treat.',
              ],
            ),
            PpSteps(
              heading: 'How to handle it in the house',
              [
                PpStep('Tell her plainly that it is not her fault', 'In these words. Once, calmly, and then again '
                        'whenever she seems to have forgotten.'),
                PpStep('Make the clean-up a non-event', 'Sheets ready, minimal light, no discussion, back '
                        'to sleep.'),
                PpStep('Keep it private from the rest of the house', 'Nobody outside needs to know. Not visitors, not '
                        'cousins, not the neighbour who asks.'),
                PpStep('Stop any teasing immediately', 'Siblings, cousins, adults who think it is funny. '
                        'One sentence, in front of her, every time.'),
                PpStep('Solve sleepovers and school trips practically', 'A discreet pull-up and a quiet word with one '
                        'trusted adult. Missing out is worse for her than the '
                        'wetting.'),
                PpStep('Check whether she is constipated', 'Fewer than three poos a week, hard stools, or '
                        'smears in her pants. Fixing that first is sometimes '
                        'the whole answer.'),
              ],
            ),
            PpCallout(
              'It is worth seeing a doctor if she is five or older and wet most '
              'nights, if a child who was dry for six months or more starts '
              'wetting again, if she is also wetting in the day, if it hurts '
              'to wee or the urine smells strong, if she is very thirsty or '
              'weeing a lot, if she snores heavily or stops breathing in her '
              'sleep, or if she is constipated as well. From about five there '
              'are real options: bladder training, an alarm, or medication for '
              'specific nights. None of it starts with blaming her.',
              kind: PpCalloutKind.doctor,
              title: 'When bedwetting is worth a doctor',
            ),
            PpConsult(
              title: 'A consult about bedwetting past five',
              whoFor: 'For a child of five or more who is wet most nights, or '
                  'any child who was dry and has started again. A '
                  'paediatrician checks for constipation and infection, and '
                  'talks through whether an alarm, bladder training or '
                  'medication is worth trying now or later. Not needed for a '
                  'three or four year old, where waiting is still the right '
                  'answer.',
              surfaceId: 'pp_experts',
              role: 'pediatrician',
            ),
            PpWhenLine('Worth a doctor from about 5 years, or sooner if a dry '
                'child starts wetting again.'),
          ],
        ),
        PpPage(
          id: 'wiping_and_washing',
          title: 'Washing and wiping on her own',
          subtitle: 'Mug, water, soap, in that order',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Doing it herself is the last piece, and it is mostly about '
                'her hands being able to reach and coordinate. Most children '
                'manage properly somewhere between four and five.'),
            PpSteps(
              heading: 'Teaching it, in order',
              [
                PpStep('You do it, narrating, for a few weeks', '"Water first, then rinse, then dry." She learns '
                        'the sequence long before she can do it.'),
                PpStep('Teach the mug with her hand under yours', 'Left hand, pour with the right, front to back. '
                        'Guided, then loosening.'),
                PpStep('Front to back, always, and say why', '"So the dirty water does not go to the front '
                        'part." Especially important for girls, because the '
                        'other way round causes urine infections.'),
                PpStep('Let her finish the job while you stay in the room', 'Present but not doing it. Expect it to be '
                        'imperfect for months.'),
                PpStep('Check quietly, without making it an inspection', 'A glance at her pants at bath time tells you '
                        'what you need. No commentary.'),
                PpStep('Hand washing is the non-negotiable one', 'Soap, both hands, about twenty seconds, every '
                        'single time. This is the step that actually keeps '
                        'her well and the one children skip.'),
                PpStep('Teach paper only if she will meet it', 'At school, on a flight, at a mall. Fold, wipe '
                        'front to back, fold again. Water at home stays the '
                        'main method.'),
              ],
            ),
            PpCallout(
              'Expect this to be done badly for a while. A child who is '
              'criticised about wiping starts saying she has finished when she '
              'has not, and then you know less than you did.',
            ),
            PpCallout(
              'Ask a doctor if there is redness, itching, a discharge, pain on '
              'passing urine, or repeated urine infections. Wiping the wrong '
              'way is a common and easily fixed cause, and worms are another '
              'that is worth ruling out.',
              kind: PpCalloutKind.doctor,
              title: 'When soreness needs checking',
            ),
            PpWhenLine('Start teaching from about 3 years. Reliable on her own '
                'usually between 4 and 5.'),
            PpIndiaNote('A mug she can lift when it is full and a tap or '
                'bucket she can reach make the difference between learning '
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
                'have accidents at school, or hold it in for six hours. The '
                'toilet is not the problem. Asking a stranger for permission '
                'is.'),
            PpArticle([
              'Teach the exact sentence she needs, and practise it out loud '
                  'until it is automatic. "Ma\'am, I need to go to the '
                  'toilet." A child who has rehearsed the words will use them; '
                  'a child who has to invent them in the moment will wait, and '
                  'then it is too late.',
              'Tell the school her word, and ask directly whether children may '
                  'go when they need to or only at fixed times. Many Indian '
                  'schools restrict it, and a child holding urine all morning '
                  'is a genuine cause of accidents, infections and '
                  'constipation. That conversation is yours to have, not '
                  'hers.',
              'Send a spare set of clothes in her bag every day and tell her, '
                  'plainly, that it is there and that using it is fine. The '
                  'knowledge that an accident is survivable prevents more '
                  'accidents than anything else, because tension makes it '
                  'worse.',
              'Public toilets away from home are their own thing. She may not '
                  'want to sit on one, and she does not have to. Teach her to '
                  'squat over without touching, teach her to hold your hand '
                  'while she does it, and carry a small bottle of water and a '
                  'soap or sanitiser. A dirty toilet she can use is better '
                  'than holding on until the drive home.',
              'And say clearly that holding it in for hours is not something '
                  'to be proud of. Some children are praised for managing a '
                  'whole school day without going, and they keep doing it.',
            ]),
            PpCallout(
              'If she is having accidents only at school, ask the school about '
              'their toilet rules before you change anything at home. It is '
              'the answer more often than parents expect.',
            ),
            PpCallout(
              'Ask a doctor if she is regularly holding urine for many hours, '
              'has repeated urine infections, complains of burning, or is '
              'wetting in the day at school age. Holding on habitually can '
              'cause real bladder problems and it is worth sorting out '
              'properly.',
              kind: PpCalloutKind.doctor,
              title: 'When holding it in needs a doctor',
            ),
            PpWhenLine('Before she starts school, and again at any change of '
                'school or class.'),
            PpIndiaNote('Squat toilets at school are usually easier for a '
                'small child than a high Western seat, as long as she has '
                'something to hold. Practise at home on the version she will '
                'meet there.'),
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
