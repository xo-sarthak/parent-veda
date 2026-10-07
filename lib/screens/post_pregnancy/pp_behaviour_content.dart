// =============================================================================
//  Behaviour — the section's content
// -----------------------------------------------------------------------------
//  Built from pp_specs/05-behavioural.md. Nine areas plus three tools.
//
//  ⚠️ THE SPEC'S FIXED ARTICLE SKELETON IS THE SHAPE OF EVERY [ARTICLE] PAGE
//  HERE, IN THIS ORDER, and it is not a style preference:
//
//    why they do it  ->  PpIntro / PpArticle
//    in the moment   ->  PpSteps
//    what NOT to do  ->  PpCards
//    words to use    ->  PpScript
//    when to worry   ->  PpCallout(kind: doctor)
//    age + related   ->  PpWhenLine + PpLink
//
//  A behaviour page that is missing the middle of that list is the failure mode
//  the spec is guarding against: a warm essay about why toddlers hit, read by a
//  parent whose child is hitting right now, that never says what to do with the
//  hand. The skeleton makes the answer arrive before the explanation runs out.
//
//  ⚠️ REFRAME, NEVER PATHOLOGISE. Stubbornness is independence arriving;
//  tantrums are a nervous system overflowing. The word "naughty" appears nowhere
//  in this file, and neither does a label for a child. Behaviour is described,
//  children are not.
//
//  ⚠️ BAND A (0 to 12 months) IS NOT "BEHAVIOUR" YET, and that is the whole
//  reason the section is banded. A parent of a three-month-old lands on crying
//  and temperament, not on an empty tantrum library. `_crying` is banded
//  `infant`, every toddler area excludes it, and `_activities` carries one
//  age-right page for that band so the section never opens with a single door.
//
//  ⚠️ A5 IS A SAFETY PAGE AND CARRIES NO OFFER. `_cryingTooMuch` has no
//  PpConsult, no PpLink to products or courses, and nothing that could read as
//  a sale. Inconsolable crying is when shaken-baby harm happens, and the page a
//  parent opens at 2am at the end of their rope is the one page in the app that
//  must want nothing from them. The spec's Band A note says "consult: pediatric,
//  on A5/A6" while the A5 note says the page "must never carry a product or
//  upsell"; the two cannot both hold, so the consult sits on A6 and A5 stays
//  clean. Flagged in the build report.
//
//  ⚠️ NEVER A DIAGNOSIS, AND NO SCREENING CHECKLISTS. `_moreThanAPhase` is
//  deliberately prose plus one doctor callout rather than a list of signs with
//  boxes beside them: a list of autism or ADHD markers in a parenting app gets
//  read as a test, scored at midnight, and either frightens a parent whose child
//  is ordinary or reassures one whose child needs to be seen. The honest product
//  is "here is when to ask someone, and here is how to ask".
//
//  Bands: `kPpChildBands` (infant / toddler_1 / toddler_2 / preschool). The
//  spec's own bands are A 0-12m, B 1-3y, C 3-6y, so Band B is expressed as
//  toddler_1 + toddler_2 and Band C as preschool. No new band set is needed, and
//  a section-specific one would have put behaviour's boundaries out of step with
//  every other parenting section for no gain.
//
//  ⚠️ ENGLISH ONLY FOR NOW. Plain `String`, never `LocalizedText`.
// =============================================================================

import 'package:flutter/material.dart' show Icons;
import 'pp_age_bands.dart';
import 'pp_behaviour_bands.dart';
import 'pp_behaviour_more.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// The bands, spelled out once so a page's tag list reads as intent rather than
// as three magic strings. Band A is the odd one out and is written on its own
// wherever it appears.
const List<String> _toddler = ['toddler_1', 'toddler_2'];
const List<String> _toddlerAndUp = ['toddler_1', 'toddler_2', 'preschool'];
const List<String> _olderToddlerAndUp = ['toddler_2', 'preschool'];

// =============================================================================
//  BAND A (0 to 12 months) — crying and temperament
// -----------------------------------------------------------------------------
//  Reassurance first, with the safety layer sitting inside the same door rather
//  than hidden behind a separate one. No script library here: the child is
//  pre-verbal, so scripts in this band are for answering the family, not the
//  baby.
// =============================================================================

const PpArea _crying = PpArea(
  id: 'crying',
  mark: IntentMark.moodArc,
  title: 'Why is my baby crying so much?',
  blurb: 'Crying, settling, temperament, and what to do on the hardest nights.',
  hue: 206,
  bands: ['infant'],
  pages: [
    // ---- A1 ----------------------------------------------------------------
    PpPage(
      id: 'crying_normal',
      title: "Is my baby's crying normal?",
      subtitle: 'The curve almost every baby follows.',
      format: 'ARTICLE',
      bands: ['infant'],
      blocks: [
        PpIntro('Crying is how a newborn tells you something. It usually '
            'builds from around two weeks old, peaks at six to eight weeks, '
            'and then eases. That curve is normal development, not a fault in '
            'you or in your baby.'),
        PpArticle(
          heading: 'Why there is so much of it',
          [
            'A newborn can\'t move away from discomfort, can\'t ask for '
                'anything and can\'t wait. Crying is the only tool a newborn '
                'has, so it covers everything: hunger, wind, tiredness, a wet '
                'nappy, too much noise. Sometimes it\'s for a reason you\'ll '
                'never find.',
            'Researchers who plotted crying across large numbers of babies '
                'found the same shape again and again. It rises through the '
                'first weeks, peaks at around six to eight weeks, then falls '
                'steadily. Some babies cry under two hours a day at that peak '
                'and some cry five. Both are normal.',
            'Evenings are usually the hardest. A long stretch of fussing '
                'between about 5pm and 10pm is so common that most families '
                'have a name for it. It passes on its own, without anything '
                'being done about it.',
          ],
        ),
        PpSteps(
          heading: 'What to do in the moment',
          [
            PpStep('Run through the basics first', 'Hungry, wind, nappy, too hot or too cold, overtired, too much '
                    'going on around your baby. Most crying is one of these.'),
            PpStep('Find somewhere quieter', 'Dim the light, lower the voices, switch the television off. An '
                    'overstimulated baby can\'t settle in a busy room, however '
                    'tired.'),
            PpStep('Hold your baby close and move slowly', 'Upright against your chest, skin to skin if you can, '
                    'with a slow steady sway or walk. Rhythm settles a baby far '
                    'better than variety does.'),
            PpStep('Add one sound, not three', 'A long shhh close to the ear, a fan, a tap running. White '
                    'noise is close to what your baby heard inside you.'),
            PpStep('Offer a feed if it is anywhere near due', 'Sucking calms babies even when they are not especially '
                    'hungry.'),
            PpStep('If your baby is fed, clean, safe and still crying, holding is '
                'enough', 'You do not have to solve it. Some crying only needs '
                    'company.'),
          ],
        ),
        PpCards(
          heading: 'What not to do',
          hue: 206,
          [
            PpCard('Do not assume every cry is hunger',
                'Feeding a baby who is overtired or windy adds discomfort to '
                'discomfort. It\'s the easiest mistake to make, because feeding '
                'sometimes works.'),
            PpCard('Do not read it as a verdict on you',
                'A baby who cries a lot is not evidence of a mother getting it '
                'wrong. The two are not connected, and every study of this has '
                'said so.'),
            PpCard('Don\'t compare your baby with anyone else\'s',
                'A cousin who slept through from week three tells you something '
                'about that baby. It tells you nothing about yours.'),
          ],
        ),
        PpCallout(
          'Call your paediatrician if the cry is high pitched, weak or '
          'very different from usual, or if there is any fever in a baby '
          'under three months. Call too if your baby is feeding poorly, '
          'has fewer wet nappies than normal, or is floppy or hard to '
          'wake. Crying that starts suddenly, won\'t settle at all and '
          'seems unlike your baby also needs a call today.',
          kind: PpCalloutKind.doctor,
          title: 'When crying needs a doctor',
        ),
        PpVideoSlot(
          title: 'The crying curve, explained',
          subtitle: 'A paediatrician walks through why crying peaks at around '
              'six weeks, and why it falls again on its own.',
          minutes: '5 MIN',
          slotId: 'behaviour/crying_curve',
        ),
        PpWhenLine('Most relevant from birth to about four months.'),
        PpIndiaNote('In a joint family everyone will have a theory, and most of '
            'them will be about your milk. Crying at six weeks is a stage, '
            'not a supply problem. If you\'re really worried about feeding, '
            'get your baby weighed rather than arguing about it.'),
        PpCallout('If the crying has stopped feeling survivable, read "When the '
            'crying is too much" in this same door before the next hard '
            'evening, not during it.'),
        PpLink('Sleep and settling at this age',
            surfaceId: 'pp_sleep',
            blurb: 'Naps, night waking, and what is normal right now.'),
      ],
    ),

    // ---- A2 ----------------------------------------------------------------
    PpPage(
      id: 'wont_settle',
      title: "Why won't my baby settle?",
      subtitle: 'Overtired, overstimulated, or needing to be held.',
      format: 'ARTICLE',
      bands: ['infant'],
      blocks: [
        PpIntro('Some babies drop off anywhere. Others fight it hard. A baby '
            'who won\'t settle is usually overtired, taking in too much, or '
            'not finished being held yet.'),
        PpArticle(
          heading: 'The three usual reasons',
          [
            'Sleep pressure builds far faster in a baby than in you. Miss '
                'the window by fifteen minutes and your baby isn\'t sleepy any '
                'more but wired. You\'ll see stiff legs, an arched back, and a '
                'cry that gets louder the more you rock.',
            'The second reason is the room. A baby can\'t filter noise, '
                'light and touch the way you can. A bright room with three '
                'people talking isn\'t restful, even to an exhausted baby.',
            'The third is contact. To a very new baby, being put down flat '
                'and alone means something has gone wrong. Wanting your body '
                'isn\'t a habit your baby has picked up.',
          ],
        ),
        PpSteps(
          heading: 'What to do in the moment',
          [
            PpStep('Lower the room before you do anything else', 'Dim the light, drop your voice, move to the quietest '
                    'space you have.'),
            PpStep('Wrap or hold firmly', 'A snug swaddle or a firm hold against your chest gives back '
                    'the boundary your baby lost at birth. Keep the hips loose and '
                    'never put anything near the face.'),
            PpStep('Pick one rhythm and stay with it', 'Slow sway, patting, or walking. Same speed for several '
                    'minutes rather than something new every few seconds.'),
            PpStep('Add white noise', 'Steady and boring is the point. A fan, a shhh, a tap.'),
            PpStep('Offer a feed if it is due', 'Comfort sucking does real work in calming your baby.'),
            PpStep('When your baby goes drowsy, stop adding things', 'This is where most of us wake the baby back up. Slow '
                    'down, then be still.'),
          ],
        ),
        PpCards(
          heading: 'What not to do',
          hue: 206,
          [
            PpCard('Do not change method every thirty seconds',
                'Rock, then dummy, then feed, then a different room, all inside '
                'two minutes. Your baby never gets long enough with any one of '
                'them to slow down.'),
            PpCard('Do not add stimulation to fix crying',
                'Bouncing harder, singing louder or switching on a bright toy '
                'usually makes an overtired baby worse.'),
            PpCard('Do not chase a perfect routine yet',
                'Under three months the routine follows your baby. It isn\'t the '
                'other way round for a while.'),
          ],
        ),
        PpCallout(
          'Get your baby checked by your paediatrician, rather than '
          'trying more settling, if there is arching and screaming during '
          'or after most feeds, or forceful vomiting. The same goes for '
          'blood or mucus in the stool, weight that isn\'t going up, or '
          'unsettledness that arrived suddenly and stayed.',
          kind: PpCalloutKind.doctor,
          title: 'When it is not a settling problem',
        ),
        PpWhenLine('Most relevant from birth to about six months.'),
        PpLink('Something has changed in sleeping or crying',
            surfaceId: 'pp_what_changed',
            blurb: 'Look up the change and see what it usually means.'),
        PpLink('Settling, naps and night waking',
            surfaceId: 'pp_sleep',
            blurb: 'The full sleep door for your baby\'s age.'),
        PpLink('Comfort feeding and feeding to sleep',
            surfaceId: 'pp_feeding',
            blurb: 'Whether it is a problem, and when it is not.'),
      ],
    ),

    // ---- A3 ----------------------------------------------------------------
    PpPage(
      id: 'cant_spoil',
      title: 'You cannot spoil a newborn',
      subtitle: 'And what to say when the family disagrees.',
      format: 'SHORT ARTICLE',
      bands: ['infant'],
      blocks: [
        PpIntro('Picking up a crying baby doesn\'t spoil anyone. In the first '
            'six months, coming when your baby calls is what builds a sense '
            'that the world is safe.'),
        PpArticle(
          [
            'A young baby can\'t calm down alone yet. When your baby cries '
                'and you come, the body learns that distress ends. That '
                'learning is the floor everything else is built on, including '
                'calming down alone as a toddler.',
            'The opposite worry, that a carried baby will always want to be '
                'carried, does not hold up. Babies who are picked up promptly in '
                'the early months tend to cry less by the end of the first year, '
                'not more.',
            'There is no habit to break at six weeks, because there is no habit '
                'yet. A habit needs memory and expectation, and both of those '
                'arrive later.',
          ],
        ),
        PpCallout(
          'The line you\'ll hear is that you keep the baby in your arms '
          'too much and it will spoil the child. Being held a great deal '
          'isn\'t what spoils a child. It\'s what a newborn is built for.',
          kind: PpCalloutKind.myth,
        ),
        PpScript(
          heading: 'Words to use, when it is said in front of you',
          [
            PpScriptLine(
              say: 'The doctor said holding the baby this much is exactly right at '
                  'this age.',
              notThis: 'You do not know anything about babies.',
              why: 'Naming the paediatrician ends the argument without turning '
                  'it into a question of respect.',
            ),
            PpScriptLine(
              say: 'Babies are only this small for a few weeks. I want to hold '
                  'mine while I still can.',
              notThis: 'Please stop telling me what to do with my child.',
              why: 'Agreeing that it is temporary lets an elder step back '
                  'without losing face, which is usually what the argument is '
                  'really about.',
            ),
            PpScriptLine(
              say: 'Would you hold the baby for a while? My arms are done.',
              why: 'Turning the criticism into a request changes the room. It\'s '
                  'also the help you need.',
            ),
          ],
        ),
        PpCallout(
          'Nothing here is about ignoring illness. A baby who has become much '
          'harder to settle, is feeding less, or seems unwell needs a doctor, '
          'not more holding.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Most relevant from birth to about six months.'),
        PpIndiaNote('In a shared home this advice comes from people who love your '
            'baby and mean well. You don\'t need to win the argument. You '
            'need to keep picking your baby up.'),
      ],
    ),

    // ---- A4 ----------------------------------------------------------------
    PpPage(
      id: 'temperament',
      title: "Understanding your baby's temperament",
      subtitle: 'Descriptions, not labels, and not a verdict.',
      format: 'CARDS',
      bands: ['infant'],
      blocks: [
        PpIntro('Babies arrive with a style already fitted. You didn\'t cause it '
            'and you don\'t have to correct it. Knowing your baby\'s style '
            'mainly makes the day easier to plan.'),
        PpCards(
          heading: 'Three rough styles',
          hue: 206,
          [
            PpCard('The easy going baby',
                'Feeds and sleeps fairly predictably, settles with a little '
                'help, recovers from upset quickly. Needs the same care as any '
                'baby, and it\'s worth checking that a baby who rarely complains '
                'isn\'t being overlooked.'),
            PpCard('The spirited baby',
                'Big reactions in both directions. Cries hard, laughs hard, '
                'notices everything, needs more help winding down. Lower the '
                'noise and light earlier than feels necessary, and keep the day '
                'less packed than you would like to.'),
            PpCard('The slow to warm baby',
                'Watches from the edge before joining in, dislikes sudden '
                'change, takes longer with new people and new places. Give '
                'warning, give time, and let your baby join in slowly instead '
                'of being handed over.'),
            PpCard('Most babies, which is a mix',
                'Most sit somewhere between these and shift with teeth, illness '
                'and growth spurts. Use them as a rough map, never as a '
                'category.'),
          ],
        ),
        PpArticle(
          heading: 'What this changes day to day',
          [
            'Temperament doesn\'t tell you what your child will be like at '
                'twenty. It tells you what will help this week: how much noise '
                'your baby can take and how much warning is needed. It also '
                'shows how long recovery from upset takes.',
            'Where your style and your baby\'s sit far apart, the friction '
                'is real and it\'s nobody\'s fault. A quiet parent with a '
                'spirited baby isn\'t doing anything wrong, and neither is the '
                'baby.',
          ],
        ),
        PpCallout('These are descriptions of behaviour, not labels for a child '
            'and not a diagnosis of anything. There is no such thing as a '
            'difficult baby.'),
        PpCallout(
          'Temperament is about style, not skills. Some things are a '
          'separate question, worth raising with your paediatrician: no '
          'eye contact, not turning to your voice, or no social smile by '
          'around three months. The same goes for losing something your '
          'baby could already do.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Useful from birth through the whole first year.'),
        PpLink('Age right things to do together',
            surfaceId: 'pp_activities',
            blurb: 'Play and connection activities for your baby\'s month.'),
      ],
    ),

    // ---- A5 — THE MANDATORY SAFETY PAGE. NO OFFER ON THIS PAGE. ------------
    PpPage(
      id: 'crying_too_much',
      title: 'When the crying is too much',
      subtitle: 'For the moment you feel you cannot take another minute.',
      // ⚠️ [reformat: Article + red flag > Interactive]. "The worst mismatch
      // and the highest stakes. A parent at the edge at 2am cannot read a
      // six-item list. One calm instruction on screen at a time, dark and
      // glanceable, same as Sleep's 3am fix. The never-shake-a-baby block
      // and get-help-today routing stay, spoken to her." The page is its
      // one block; the prose it replaced is kept below for revert.
      // format: 'ARTICLE + FLAGGED CALLOUT',
      format: 'INTERACTIVE',
      bands: ['infant'],
      blocks: [
        PpInteractive(
          kind: PpInteractiveKind.night,
          title: 'When the crying is too much',
          blurb: 'One calm step per screen, dark and dim. For right now.',
          hue: 14,
          items: [
            PpInteractiveItem('You are not a bad parent',
                'Hours of crying push almost every parent to anger, or panic, '
                    'or nothing at all. Your body has reached its limit and '
                    'needs a break. The break is the whole plan.'),
            PpInteractiveItem('Put your baby down somewhere safe',
                'On the back in the cot, or on a firm flat surface with nothing '
                    'near the face. A baby put down safely and crying is completely '
                    'fine for a few minutes.'),
            PpInteractiveItem('Walk out of the room',
                'Close the door if you need to. You\'re not abandoning anyone. '
                    'You\'re keeping your baby safe.'),
            PpInteractiveItem('Do one slow thing for two minutes',
                'Splash your face, drink a glass of water, stand at a window, '
                    'and let each breath out last longer than the breath in.'),
            PpInteractiveItem('Call someone before you go back in',
                'Your partner, your mother, your sister, a friend, a '
                    'neighbour. Say the true sentence: I am finding this very '
                    'hard right now.'),
            PpInteractiveItem('Go back when your hands feel steady',
                'Then hand the baby over if there is anyone to hand over to. '
                    'Twenty-minute shifts through the worst evenings is a normal '
                    'way to get through them.'),
            PpInteractiveItem('Never shake your baby, not even lightly',
                'A baby\'s head is heavy and the neck is weak. Shaking can tear '
                    'blood vessels inside the brain in seconds, and the damage is '
                    'permanent. It happens to loving parents at the end of long '
                    'nights, which is exactly why the steps before this matter.'),
            PpInteractiveItem('If it has already happened',
                'If a baby has been shaken or has had a hard knock to the head, '
                    'the baby needs to be seen straight away, even if all seems '
                    'well. Whoever takes the baby should say plainly what happened.'),
          ],
          closing: 'Tell your doctor today, not next week, if you\'re frightened of '
              'what you might do, or have thoughts of harming yourself or the '
              'baby. Tell them too if you feel nothing at all towards your '
              'baby, or have already handled the baby more roughly than you '
              'meant to. All four are common and treatable, and none of them '
              'make you a bad mother. If you can\'t reach a doctor and you\'re '
              'frightened, go to the nearest hospital and say exactly that '
              'sentence.',
        ),
        /* kept for revert: the article the step-through replaced
        PpIntro('If the crying has pushed you to the edge, you are not a bad '
            'parent and you are very far from the only one. This page is for '
            'that exact moment.'),
        PpArticle(
          heading: 'Why it gets this hard',
          [
            'A crying baby is built to be impossible to ignore. Hours of it '
                'raise your heart rate and your stress hormones whether you '
                'agree to that or not. Add broken sleep for weeks, and almost '
                'every parent reaches a point of feeling anger, or panic, or '
                'nothing at all.',
            'Feeling that way does not mean you are going to hurt your baby. It '
                'means your body has reached its limit and needs a break. The '
                'break is the whole plan, and it is a plan that works.',
          ],
        ),
        PpSteps(
          heading: 'What to do, right now',
          [
            PpStep('Put him down somewhere safe', 'On his back in his cot, or on a firm flat surface with '
                    'nothing near his face. A baby who has been put down safely '
                    'and is crying is completely fine for a few minutes.'),
            PpStep('Walk out of the room', 'Close the door if you need to. You are not abandoning '
                    'him. You are keeping him safe.'),
            PpStep('Do one slow thing for two minutes', 'Splash your face, drink a glass of water, stand at a '
                    'window, breathe out for longer than you breathe in.'),
            PpStep('Call someone before you go back in', 'Your partner, your mother, your sister, a friend, a '
                    'neighbour. Say the true sentence: I am finding this very '
                    'hard right now.'),
            PpStep('Go back when your hands feel steady', 'Then hand him over if there is anyone to hand him to. '
                    'Twenty minute shifts through the worst evenings is a normal '
                    'way to get through them.'),
            PpStep('Plan the next bad night while today is calm', 'Decide now who you will call, and tell that person in '
                    'advance that you might. Asking is much harder at 2am.'),
          ],
        ),
        PpCards(
          heading: 'What not to do',
          hue: 14,
          [
            PpCard('Never shake a baby, not even lightly',
                'A baby head is heavy and the neck is weak. Shaking can tear '
                'blood vessels inside the brain in seconds and the damage is '
                'permanent. It happens to loving parents at the end of long '
                'nights, which is exactly why the steps above matter.'),
            PpCard('Do not jerk, throw or hard bounce him to make it stop',
                'Rough handling frightens a baby and lengthens the crying, and '
                'hard jolting carries the same risk as shaking.'),
            PpCard('Do not shout into his face',
                'It will not stop the crying and it raises both of your stress '
                'levels. If you are shouting, that is the signal to put him '
                'down and step out.'),
            PpCard('Do not carry this alone for weeks',
                'Being worn down slowly is more dangerous than one bad hour. '
                'Tell someone what these evenings are actually like.'),
          ],
        ),
        PpCallout(
          'Tell your doctor or paediatrician today, not next week, if you are '
          'frightened of what you might do, if you have thoughts of harming '
          'yourself or the baby, if you feel nothing at all towards him, or if '
          'you have already handled him more roughly than you meant to. All '
          'four of those are common and treatable, and none of them make you a '
          'bad mother. If you cannot reach a doctor and you are frightened, go '
          'to the nearest hospital and say exactly that sentence.',
          kind: PpCalloutKind.doctor,
          title: 'Get help today',
        ),
        PpCallout(
          'If a baby has been shaken or has taken a hard knock to the head, he '
          'needs to be seen straight away even if he seems fine, and whoever '
          'takes him should say plainly what happened. Getting him looked at '
          'matters more than how the question feels to answer.',
          kind: PpCalloutKind.doctor,
          title: 'If it has already happened',
        ),
        PpIndiaNote('In a joint family, ask for the shift rather than for the '
            'advice. "Can you hold him from eight to nine" is something people '
            'can actually do, and it is the request that helps.'),
        PpWhenLine('Worth knowing for the whole first year, and especially '
            'between four and sixteen weeks when crying peaks.'),
        */
      ],
    ),

    // ---- A6 ----------------------------------------------------------------
    PpPage(
      id: 'crying_doctor',
      title: 'When crying needs a doctor',
      subtitle: 'The honest signs, and how to describe them.',
      format: 'FLAGGED CALLOUT',
      bands: ['infant'],
      blocks: [
        PpIntro('Most crying is normal and passes. A small number of babies are '
            'crying because something is wrong, and these are the signs worth '
            'acting on rather than waiting out.'),
        PpCallout(
          'Today, without waiting: any fever in a baby under three '
          'months, a weak, moaning or high pitched cry, refusing feeds, '
          'or far fewer wet nappies. Also today: vomiting that shoots '
          'out, blood in the stool, or breathing that looks like hard '
          'work. The same for floppiness or being hard to wake, a swollen '
          'tender tummy, or crying that started suddenly and nothing '
          'settles at all.',
          kind: PpCalloutKind.doctor,
          title: 'Same day',
        ),
        PpCallout(
          'An appointment this week: crying that is still intense past four '
          'months, especially alongside poor feeding, poor weight gain or badly '
          'broken sleep. Also worth raising if the character of the cry changed '
          'and has stayed changed.',
          kind: PpCalloutKind.doctor,
          title: 'Book it, but not an emergency',
        ),
        PpCards(
          heading: 'Usually not an emergency',
          hue: 206,
          [
            PpCard('Long evening fussing',
                'The 5pm to 10pm stretch is the most common crying in the '
                'world. Uncomfortable for everyone, dangerous for nobody.'),
            PpCard('Crying the moment your baby is put down',
                'A preference for your body, not a symptom.'),
            PpCard('Crying during a nappy change or a bath',
                'Young babies find being undressed really unpleasant. It passes '
                'with age, not with technique.'),
            PpCard('Wind, straining and grunting',
                'Newborn digestion is loud and dramatic. What matters is weight '
                'gain and wet nappies, not the noise.'),
          ],
        ),
        PpArticle(
          heading: 'How to describe it so the appointment is useful',
          [
            'Doctors are trying to separate a pattern from an event. Note when '
                'the crying starts, roughly how long it lasts, what you have '
                'tried, and whether anything reliably helps.',
            'Take two numbers with you: how many feeds and how many wet nappies '
                'in the last twenty four hours. Those two answer more clinical '
                'questions than a long description does.',
            'If the cry itself sounds different from usual, record thirty '
                'seconds of it on your phone. A cry described from memory and a '
                'cry heard are not the same evidence.',
          ],
        ),
        PpConsult(
          title: 'Paediatric consultation',
          whoFor: 'For crying that has changed, or that is not easing after '
              'four months, when you want someone to properly look rather than '
              'reassure you.',
          surfaceId: 'pp_experts',
          role: 'paediatrician',
        ),
        PpWhenLine('Any time in the first year.'),
      ],
    ),
  ],
);

// =============================================================================
//  BAND B (1 to 2 years) — the first big feelings
// -----------------------------------------------------------------------------
//  The year the child gets opinions before they get words. Almost everything in
//  this band is a communication problem wearing a behaviour costume, and saying
//  so is most of the help.
// =============================================================================

const List<String> _bandB = ['toddler_1', 'toddler_2'];

const PpArea _firstFeelings = PpArea(
  id: 'first_feelings',
  mark: IntentMark.listMark,
  title: 'The first tantrums, and hitting',
  blurb: 'Big feelings in a body with no words yet.',
  hue: 344,
  bands: _toddler,
  pages: [
    PpPage(
      id: 'first_tantrums',
      title: 'The first tantrums',
      subtitle: 'Why they start now, and what shortens them.',
      format: 'ARTICLE',
      bands: _toddler,
      blocks: [
        // ⚠️ ADDED IN THE S05 PASS — this area had no video at all,
        // and the feedback opens with "wherever video is needed in any
        // sub section, add it at top". Behaviour is the section where a
        // demonstration earns the most: tone of voice and what a parent
        // does with her hands are most of the technique, and neither
        // survives being written down.
        PpVideoSlot(
          title: 'A tantrum, and what to do in it',
          subtitle: 'Filmed in a real kitchen: staying close, saying almost nothing, and what happens after.',
          minutes: '5 MIN',
          slotId: 'behaviour/tantrum_moment',
        ),
        PpIntro('Somewhere around the first birthday your child starts wanting '
            'things very much and having almost no way to say so. That gap is '
            'where tantrums live.'),
        PpArticle([
          'A tantrum at this age isn\'t manipulation and it isn\'t a '
              'decision. The part of the brain that manages strong feeling is '
              'years away from being finished. So when the feeling is bigger '
              'than the child, it spills out.',
          'Which is why reasoning doesn\'t work in the moment. Your child '
              'can\'t hear you yet. The thinking part of the brain is offline '
              'until the feeling passes.',
        ], heading: 'Why they do it'),
        PpSteps([
          PpStep('Get down to your child\'s level',
              'Standing over a small person having a big feeling makes it '
              'bigger.'),
          PpStep('Say the feeling, not the rule',
              'You wanted the biscuit. You are so angry. Naming it is what '
              'starts bringing it down.'),
          PpStep('Stay, and stay quiet',
              'You do not have to fix it or talk it through. Being there while '
              'it passes is the whole job.'),
          PpStep('Wait for the body to settle before saying anything else',
              'Breathing slows, the crying changes pitch. That\'s when your '
              'child can hear you again.'),
          PpStep('Move on properly', 'No lecture afterwards. It is finished.'),
        ], heading: 'What to do in the moment'),
        PpCards([
          PpCard('Do not reason mid-tantrum',
              'Every sentence you say at full volume is one your child can\'t '
              'take in.'),
          PpCard('Do not give in to end it',
              'Giving in doesn\'t spoil a child. The trouble is that it '
              'teaches that the tantrum is the way to ask.'),
          PpCard('Do not laugh or film it',
              'It\'s real to your child, and being laughed at while '
              'overwhelmed is the part children remember.'),
          PpCard('Don\'t send your child away alone',
              'At this age the feeling is too big to be alone with.'),
        ], heading: 'What not to do', hue: 12),
        PpScript([
          PpScriptLine(
            say: 'You really wanted that. I know.',
            notThis: 'Stop crying, it is not a big deal.',
            why: 'The first tells your child the feeling makes sense. The second '
                'says it doesn\'t, which usually makes it louder.',
          ),
          PpScriptLine(
            say: 'I am right here. I will wait with you.',
            notThis: 'Come and talk to me when you have calmed down.',
            why: 'A one-year-old cannot calm down alone yet. That comes later, '
                'and it comes from being helped to do it now.',
          ),
        ], heading: 'Words to use'),
        PpCallout(
          'Worth raising with your paediatrician if tantrums come with '
          'holding the breath until your child goes limp or blue, or with '
          'serious, deliberate self-injury. Raise it too if they are so '
          'frequent and so long that most of the day is spent in one.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('From about 12 months, peaking through the second year.'),
        PpIndiaNote('In a joint family a tantrum has an audience, and half the '
            'pressure you feel comes from them. It\'s fair to pick your '
            'child up and go to another room, for both your sakes.'),
      ],
    ),
    PpPage(
      id: 'hitting_biting',
      title: 'Hitting, biting and pulling hair',
      subtitle: 'Almost always communication, not aggression.',
      format: 'ARTICLE',
      bands: _toddlerAndUp,
      blocks: [
        PpIntro('It is shocking the first time, and it is extremely common. A '
            'child who bites at this age is not a child who will grow up '
            'violent.'),
        // ⚠️ THE MECHANISM, ONCE. "Why a child lashes out physically" was
        // written three times (here, Anger, Guiding without hitting); the
        // brief: single-source it. The anger page keeps the explanation;
        // this page keeps the moment (she bit someone) and points at it.
        // The paragraph is kept below for revert.
        PpArticle([
          'Biting and hitting peak in the second year for a simple reason: '
              'strong feeling, no words.',
        ], heading: 'Why they do it'),
        PpLink('Why a child lashes out, in full',
            pageId: 'beh_anger',
            blurb: 'The one explanation the three hitting pages share.'),
        /* kept for revert
        PpArticle([
          'Biting and hitting peak in the second year for a simple reason: '
              'strong feeling, no words. Frustration, excitement, tiredness and '
              'teething all come out through the body, because the body is what '
              'she has.',
        ], heading: 'Why they do it'),
        */
        PpSteps([
          PpStep('Attend to the child who was hurt first',
              'It teaches more than any telling-off, and it is the right thing '
              'to do anyway.'),
          PpStep('Be short and clear',
              'No biting. Biting hurts. Two sentences, calm voice.'),
          PpStep('Give the word that was missing',
              'You wanted the toy. Say: my turn.'),
          PpStep('Move your child to something else',
              'At this age separation from the situation works; a long '
              'explanation does not.'),
        ], heading: 'What to do in the moment'),
        PpCards([
          PpCard('Never bite back',
              'It is still advised in some families. It teaches that biting is '
              'what big people do when they are angry.'),
          PpCard('Don\'t label your child',
              'A label like "biter" turns into something a child believes.'),
          PpCard('Don\'t make your child say sorry',
              'A forced sorry teaches the word, not the meaning. Show how to '
              'help instead.'),
        ], heading: 'What not to do', hue: 12),
        PpScript([
          PpScriptLine(
            say: 'Teeth are not for people. Here, bite this.',
            notThis: 'Bad girl. Say sorry right now.',
            why: 'The first replaces the behaviour with an allowed one. The '
                'second attaches shame to a child who does not yet have the '
                'skill you are asking for.',
          ),
        ], heading: 'Words to use'),
        PpCallout(
          'Worth raising with your paediatrician if it\'s getting worse '
          'after a few months rather than better, or happens calmly and '
          'unprovoked rather than in frustration. Raise it too if your '
          'child is over three and still biting often.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('Common from about 12 months, usually fading through the '
            'third year as language arrives.'),
        PpLink('Something to do today',
            surfaceId: 'pp_activities',
            blurb: 'Play that burns off the feeling before it comes out.'),
      ],
    ),
    PpPage(
      id: 'separation',
      title: 'My child cries every time I leave',
      subtitle: 'Separation anxiety, and why it is a good sign.',
      format: 'ARTICLE',
      bands: _toddler,
      blocks: [
        PpIntro('It usually arrives around eight months, gets stronger through '
            'the second year, and it means the attachment is working.'),
        PpArticle([
          'A baby who protests when you leave has understood two things: '
              'that you are a specific and irreplaceable person, and that you '
              'go on existing out of sight. Both are developmental wins that '
              'happen to be extremely inconvenient.',
        ], heading: 'Why they do it'),
        PpSteps([
          PpStep('Always say you are going',
              'Slipping away avoids the crying now and costs you trust later.'),
          PpStep('Keep the goodbye short and the same every time',
              'A ritual beats a long reassurance.'),
          PpStep('Say when you\'ll be back, in your child\'s terms',
              'After your nap. Clock time means nothing yet.'),
          PpStep('Hand over to the same person where you can',
              'One familiar pair of arms is worth more than any distraction.'),
        ], heading: 'What to do'),
        PpCards([
          PpCard('Do not sneak out', 'It makes every future exit frightening.'),
          PpCard('Don\'t come back in at the crying',
              'It teaches that crying reopens the door, which makes the next '
              'goodbye longer.'),
          PpCard('Don\'t call the fear silly',
              'The feeling is real even when the danger is not.'),
        ], heading: 'What not to do', hue: 12),
        PpCallout(
          'Worth raising with your paediatrician if nobody at all can '
          'settle your child for long periods, or if it appears suddenly '
          'in a child who was fine. Raise it too if it\'s still severe '
          'enough at four or five to stop school.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('From about 8 months, strongest between 1 and 2 years.'),
        PpIndiaNote('If grandparents or a maid share the care, the goodbye '
            'ritual works best when it is the same whoever is doing it. Agree '
            'it out loud with them once.'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  ⚠️ THE THREE PAGES B2 SPECIFIES AND THE BUILD NEVER HAD. The area had
    //  "the first tantrums" and stopped, so a parent mid-tantrum got the
    //  explanation and not the method. These are the method.
    PpPage(
      id: 'beh_tantrum_or_meltdown',
      title: 'Tantrum, or meltdown?',
      format: 'SHORT ARTICLE',
      bands: _bandB,
      blocks: [
        PpIntro('They look the same from outside and they are not the same '
            'thing. Getting it wrong is the difference between a storm that '
            'passes in four minutes and one that lasts forty.'),
        PpTable(
          heading: 'The difference, in the moment',
          columns: ['', 'A tantrum', 'A meltdown'],
          rows: [
            ['What set it off', 'A no. Something your child wanted and didn\'t get.',
                'Too much. Noise, people, tiredness, hunger stacked up.'],
            ['Is your child checking on you',
                'Usually yes. There is a glance.',
                'No. Your child isn\'t really in the room with you.'],
            ['What ends it',
                'Time, and the answer not changing.',
                'Less input. Fewer people, less light, less talking.'],
            ['What makes it worse',
                'Negotiating, or giving in halfway.',
                'Questions. Reasoning. Anyone new arriving to help.'],
          ],
        ),
        PpArticle(heading: 'Why the label matters', [
          'A tantrum is communication: your child wants something and '
              'this is the strongest argument available. Holding the limit '
              'calmly is the whole job.',
          'A meltdown isn\'t an argument at all. The nervous system has '
              'run out of room, and there is nothing to hold a line against. '
              'Treating it like a tantrum by being firmer adds one more thing '
              'to a system that is already full.',
          'A child who has frequent meltdowns rather than tantrums, well '
              'past the age most children have stopped, is worth mentioning '
              'to your paediatrician. That isn\'t because something is wrong. '
              'Sensory overwhelm has real strategies, and they help.',
        ]),
        PpWhenLine('One to five, with meltdowns lasting longer into '
            'childhood than tantrums do.'),
        PpLink('What to do in either one',
            pageId: 'beh_tantrum_steps',
            blurb: 'The five steps, in order.'),
      ],
    ),

    PpPage(
      id: 'beh_tantrum_steps',
      title: 'The five steps, in the moment',
      format: 'STEP-LIST',
      bands: _bandB,
      blocks: [
        PpVideoSlot(
          title: 'All five, in one real tantrum',
          subtitle: 'Filmed start to finish, including the part where nothing '
              'seems to be working.',
          minutes: '5 MIN',
          slotId: 'behaviour/five_steps',
        ),
        PpIntro('Short enough to remember while it is happening, which is the '
            'only test that matters. Safe, calm, present, name it, reconnect.'),
        PpSteps([
          PpStep('1. Safe',
              'Move anything hard, or move your child. Nothing else matters '
              'until this is done, and it takes four seconds.'),
          PpStep('2. Calm',
              'Yours, not your child\'s. Sit down if you can. Your body is the '
              'regulating thing in the room, and it works even without eye '
              'contact.'),
          PpStep('3. Present',
              'Close enough to touch, quiet enough to be ignored. Not talking. '
              'This step feels like doing nothing and is most of the work.'),
          PpStep('4. Name it, once, when the volume drops',
              '"You wanted the biscuit. You are so upset." Not before the '
              'peak: nothing goes in during it.'),
          PpStep('5. Reconnect, and move on',
              'A hug if your child wants one, then the next ordinary thing. '
              'No debrief, no lesson, no forced sorry for the feeling.'),
        ], heading: 'The five'),
        PpCards([
          PpCard('The answer does not change',
              'Not halfway, not at minute eight. Changing it once teaches that '
              'minute eight is where the answer changes.'),
          PpCard('It is allowed to take a while',
              'Four to fifteen minutes is ordinary. Doing this right does not '
              'make it short, it makes it end properly.'),
          PpCard('You will lose it sometimes',
              'Repair afterwards. "I shouted. That was not about you." Your '
              'child learns more from that than from a tantrum handled '
              'perfectly.'),
        ], heading: 'Three things that make it work', hue: 128),
        PpWhenLine('One to four.'),
        PpLink('The exact words',
            surfaceId: 'pp_scripts',
            blurb: 'For the supermarket, the park, and the phone.'),
      ],
    ),

    PpPage(
      id: 'beh_tantrum_public',
      title: 'When it happens in front of everyone',
      format: 'ARTICLE',
      bands: _bandB,
      blocks: [
        PpIntro('The technique does not change in a shop or at a function. What '
            'changes is that you are now managing your own embarrassment as '
            'well, and that is the part worth planning for.'),
        PpArticle(heading: 'The honest bit', [
          'Most of what makes a public tantrum unbearable is the audience, and '
              'most of the audience is not judging you. The ones who have had '
              'children remember it; the ones who have not do not matter.',
          'The pressure to end it fast is what causes the mistake. Giving '
              'in to stop the noise works once and costs you every future '
              'outing. Your child has learned that the shop is where the '
              'answer changes.',
        ]),
        PpSteps([
          PpStep('Move, if you can, before you talk',
              'Out of the aisle, to the side of the hall, into a corridor. '
              'Fewer eyes helps you both.'),
          PpStep('Go quiet rather than firm',
              'A whisper draws less attention than a hiss, and works better.'),
          PpStep('Say the same thing you would say at home',
              '"I am here. We will wait." The audience does not get a '
              'different script.'),
          PpStep('Leave if it is not settling',
              'Abandoning a half-full trolley is allowed. It is a bad twenty '
              'minutes, not a bad decision.'),
          PpStep('Say nothing to the audience',
              'You owe nobody an explanation. Explaining in front of your '
              'child sends a message: you are a problem I\'m apologising for.'),
        ], heading: 'What to do'),
        PpCards([
          PpCard('Do not bargain to buy quiet',
              'Of everything on this page, it costs you the most.'),
          PpCard('Don\'t threaten to leave your child there',
              'It works fast only because it\'s frightening.'),
          PpCard('Don\'t apologise to onlookers',
              'Your child hears it, and it\'s the sentence that stays.'),
        ], heading: 'What not to do', hue: 128),
        PpWhenLine('One to four.'),
        PpIndiaNote('At a wedding or a family function there will be advice, and '
            'somebody will offer to take your child. Sometimes handing over '
            'to a favourite person really helps and isn\'t a failure. '
            'Sometimes a new pair of arms is one more input, and it\'s fine '
            'to say "give us five minutes".'),
        PpLink('The words for exactly this',
            surfaceId: 'pp_scripts'),
      ],
    ),
  ],
);

// =============================================================================
//  BAND C (2 to 3 years) — the year of no
// =============================================================================

const PpArea _theNoYear = PpArea(
  id: 'the_no_year',
  mark: IntentMark.questionMark,
  title: 'No to everything',
  blurb: 'Defiance, big tantrums, and sharing.',
  hue: 268,
  bands: _olderToddlerAndUp,
  pages: [
    PpPage(
      id: 'defiance',
      title: 'Saying no to everything',
      subtitle: 'What defiance at two really is.',
      format: 'ARTICLE',
      bands: _olderToddlerAndUp,
      blocks: [
        // ⚠️ ADDED IN THE S05 PASS — this area had no video at all,
        // and the feedback opens with "wherever video is needed in any
        // sub section, add it at top". Behaviour is the section where a
        // demonstration earns the most: tone of voice and what a parent
        // does with her hands are most of the technique, and neither
        // survives being written down.
        PpVideoSlot(
          title: 'When no is the answer to everything',
          subtitle: 'Why two-year-olds refuse things they want, and what gets them moving.',
          minutes: '4 MIN',
          slotId: 'behaviour/the_no_year',
        ),
        PpIntro('Around two, children work out that they are separate people '
            'with their own opinions. No is how they practise that.'),
        PpArticle([
          'This is a self arriving, not a discipline problem starting. A '
              'child who never pushed back would be more of a worry. This one '
              'is doing exactly what a two-year-old is meant to do.',
          'The practical consequence is that most battles at this age are about '
              'autonomy rather than about the thing you are arguing over. Give '
              'the autonomy somewhere harmless to go and a lot of the fights '
              'stop.',
        ], heading: 'Why they do it'),
        PpSteps([
          PpStep('Offer two acceptable choices',
              'Red shirt or blue shirt, not do you want to get dressed.'),
          PpStep('Say what happens, not what you want',
              'Shoes on, then we go to the park.'),
          PpStep('Give a warning before a change',
              'Two minutes notice prevents more refusals than any '
              'negotiation.'),
          PpStep('Let your child do the easy bits alone',
              'Slowly and messily, but alone. It buys cooperation everywhere '
              'else.'),
          PpStep('Hold the line on the few that matter',
              'Safety, kindness, and not much else. Everything is not a hill.'),
        ], heading: 'What to do'),
        // Kept as its own area beside The ziddi child on the user's call
        // (2026-09-13); the shared "why the will arrives before the words"
        // is the ziddi page's, referenced here rather than written twice.
        PpLink('Why the will arrives before the words',
            pageId: 'beh_ziddi',
            blurb: 'The same discovery, seen from the stubborn side.'),
        PpCards([
          PpCard('Do not ask a question you cannot accept no to',
              'Shall we go home now invites the answer you do not want.'),
          PpCard('Do not turn it into a contest',
              'Your child has more time and less shame than you do.'),
          PpCard('Do not threaten what you will not do',
              'One unkept threat costs you the next ten.'),
        ], heading: 'What not to do', hue: 12),
        PpScript([
          PpScriptLine(
            say: 'You can walk to the car, or I can carry you. You choose.',
            notThis: 'If you do not come now I am leaving you here.',
            why: 'The first keeps your child\'s autonomy inside your limit. The '
                'second is a threat you won\'t carry out, and children know it.',
          ),
        ], heading: 'Words to use'),
        PpCallout(
          'Worth raising with your paediatrician if the defiance is '
          'extreme and constant in every setting, or if there seem to be '
          'no happy periods at all. Raise it too if skills your child had '
          'are being lost.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('Peaks between 2 and 3 years, eases through the fourth.'),
        PpIndiaNote('"Why is this child so stubborn?" is the line most families reach for, '
            'and it lands on the child as a judgement of character. Stubbornness at '
            'two is a stage, not a personality.'),
      ],
    ),
    PpPage(
      id: 'sharing',
      title: 'Not ready to share',
      subtitle: 'Because the skill isn\'t there yet, not out of selfishness.',
      format: 'ARTICLE',
      bands: _olderToddlerAndUp,
      blocks: [
        PpIntro('Real sharing needs the ability to imagine how somebody else '
            'feels. That arrives properly around four, not two.'),
        PpArticle([
          'What looks like selfishness at two is usually an honest report '
              'of what your child understands: this is mine, and giving it '
              'away means losing it forever. Turn-taking is what works at '
              'this age, because the toy comes back.',
        ], heading: 'Why they do it'),
        PpSteps([
          PpStep('Teach turns instead of sharing',
              'Your turn, then Riya\'s turn. A timer helps, and it takes you '
              'out of the argument.'),
          PpStep('Let your child finish',
              'Being made to hand over mid-play teaches that turns are '
              'unsafe.'),
          PpStep('Put the treasured things away before friends come',
              'One or two special toys can belong to your child alone.'),
          PpStep('Name what the other child feels',
              'Your friend is sad because of the waiting. That is the seed of '
              'the skill.'),
        ], heading: 'What to do'),
        PpCards([
          PpCard('Don\'t force your child to hand it over',
              'It teaches compliance to whoever is loudest, not generosity.'),
          PpCard('Don\'t call your child selfish',
              'Two is very young. The word will stay long after the stage has gone.'),
        ], heading: 'What not to do', hue: 12),
        PpCallout(
          'Worth raising with your paediatrician if by four or five your '
          'child shows no interest in other children at all. The same if '
          'someone else being upset seems to go unnoticed.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('Turn-taking from about 2. Real sharing from about 4.'),
      ],
    ),
  ],
);

// =============================================================================
//  BAND D (3 to 5 years) — words, rules and other people
// =============================================================================

// ignore: unused_element
const PpArea _rulesAndOthers = PpArea(
  id: 'rules_and_others',
  mark: IntentMark.blocksMark,
  title: 'Lying, back-talk and screens',
  blurb: 'The behaviours that arrive once there are words for everything.',
  hue: 42,
  bands: ['preschool'],
  pages: [
    /* ⚠️ MERGED INTO `beh_older_lying` (pp_behaviour_bands.dart), KEPT FOR
       REVERT. "One lying page, not two. 'She told me a lie' and 'Lying,
       fairness and telling on people' are the same page for the same age.
       Keep one, delete the copy." The film, the script and the doctor line
       went with it.
    PpPage(
      id: 'lying',
      title: 'She told me a lie',
      subtitle: 'What lying at four actually means.',
      format: 'ARTICLE',
      bands: ['preschool'],
      blocks: [
        // ⚠️ ADDED WHEN SCREEN TIME MOVED OUT TO ITS OWN DOOR. This area
        // held the only video in it, so retiring that page left the area
        // bare. Worth noting as a general hazard: moving a page can take a
        // section's only video with it, and nothing complains.
        PpVideoSlot(
          title: 'Why small children lie',
          subtitle: 'A child psychologist on why it is a milestone rather '
              'than a character problem, and what to do at the moment it '
              'happens.',
          minutes: '5 MIN',
          slotId: 'behaviour/lying',
        ),
        PpIntro('The first lies are a developmental milestone, uncomfortable as '
            'that is to read. She has worked out that you cannot see inside her '
            'head.'),
        PpArticle([
          'Most early lies are wishes rather than deceptions. I did not break it '
              'often means I wish I had not broken it. Some are pure '
              'imagination, and at four the line between a story and a report '
              'is genuinely blurry.',
        ], heading: 'Why they do it'),
        PpSteps([
          PpStep('Do not set a trap',
              'If you know she broke it, do not ask whether she did.'),
          PpStep('Say what you saw, calmly',
              'The glass is broken. Let us clean it up together.'),
          PpStep('Make the truth cheap',
              'Thank her when she owns something, even while you deal with '
              'it.'),
          PpStep('Separate the mess from the lie',
              'Deal with one thing, not two, and never with a lecture on '
              'honesty.'),
        ], heading: 'What to do'),
        PpCards([
          PpCard('Do not call her a liar',
              'A label is the fastest way to make a habit permanent.'),
          PpCard('Do not punish the confession',
              'If owning up costs more than hiding, she will hide next time.'),
        ], heading: 'What not to do', hue: 12),
        PpScript([
          PpScriptLine(
            say: 'I know that was hard to say. Thank you for telling me.',
            notThis: 'Do not lie to me. I always find out.',
            why: 'The first makes honesty worth it. The second makes it a '
                'contest she will try harder to win.',
          ),
        ], heading: 'Words to use'),
        PpCallout(
          'Worth raising with your paediatrician if lying is constant, '
          'elaborate and unbothered by being found out, or if it comes together '
          'with taking things and hurting animals or other children.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('First lies from about 3, common through 4 and 5.'),
      ],
    ),
    */

    /* ⚠️ MOVED OUT TO ITS OWN DOOR, KEPT FOR REVERT.
       The prompt gives screen time its own door with four pages; it was one
       page filed under "lying, back-talk and screens". `kBehScreens` in
       pp_behaviour_more.dart now carries it properly.

       Retired rather than left in place, because two screen-time entries in
       one section is the duplicate-door problem this review has now found
       three times elsewhere. If the new door is ever dropped, uncomment this
       so the content does not vanish with it.

    PpPage(
      id: 'screens',
      title: 'Screens, and the fight to turn them off',
      subtitle: 'Where the actual problem is, and it is not the screen.',
      format: 'ARTICLE',
      bands: ['preschool'],
      blocks: [
        // ⚠️ ADDED IN THE S05 PASS — this area had no video at all,
        // and the feedback opens with "wherever video is needed in any
        // sub section, add it at top". Behaviour is the section where a
        // demonstration earns the most: tone of voice and what a parent
        // does with her hands are most of the technique, and neither
        // survives being written down.
        PpVideoSlot(
          title: 'Ending screen time without a meltdown',
          subtitle: 'The warning, the timer, and the thing to move to next.',
          minutes: '4 MIN',
          slotId: 'behaviour/screen_transition',
        ),
        PpIntro('Almost every screen argument is about the ending, not the '
            'watching. Fix the ending and most of it goes.'),
        PpArticle([
          'A show stops mid-feeling: she is inside a story and it is taken '
              'away. An adult would also protest. What makes it worse is that '
              'screens are usually offered when everyone is already tired, so '
              'the ending lands at the worst moment of the day.',
        ], heading: 'Why the fight happens'),
        PpSteps([
          PpStep('Decide the amount before you start, out loud',
              'Two episodes, then we make dinner.'),
          PpStep('End on a natural boundary',
              'The end of an episode, not the middle. Mid-story is what causes '
              'the meltdown.'),
          PpStep('Give a warning inside her world', 'One more song, then off.'),
          PpStep('Have the next thing ready',
              'Turning it off into nothing is what she is really resisting.'),
          PpStep('Watch with her sometimes',
              'It changes the screen from a babysitter into something shared.'),
        ], heading: 'What to do'),
        PpCards([
          PpCard('Do not use it as the reward for everything',
              'It makes it the most valuable thing in the house.'),
          PpCard('Do not take it away as the punishment for everything',
              'Same reason, from the other side.'),
          PpCard('Do not feel guilty about needing it sometimes',
              'A cooked meal and a calm parent are also good for her.'),
        ], heading: 'What not to do', hue: 12),
        PpCallout(
          'Worth raising with your paediatrician if screens have replaced '
          'eating, sleeping or playing, if she is not talking as much as she '
          'was, or if she cannot play at all without one.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('Relevant from about 2, hardest between 3 and 5.'),
        PpIndiaNote('Phones get handed over at mealtimes by whoever is feeding '
            'her, and that is often not you. It is worth one calm conversation '
            'with the family rather than ten corrections in front of her.'),
      ],
    ),
    */
    // `siblings` moved out to `_siblings` below: it is reslotted into
    // Three to six.
    // Added 2026-10-02 from the parenting gap analysis (P2/P3).
    PpPage(
      id: 'beh_words_that_hurt',
      title: 'Everyday phrases that hurt more than we mean, and what to say instead',
      subtitle: 'Small changes in words, big changes in how your child feels',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Every parent says things in frustration they didn\'t mean. Some '
            'everyday phrases, said often, can teach a child that feelings '
            'are wrong or that love depends on behaving. Small swaps make a '
            'big difference over time.'),
        PpScript(heading: 'Swaps worth trying', [
          PpScriptLine(say: 'You are upset. I am here.',
              notThis: 'Stop crying, it is nothing.',
              why: 'Those feelings are real to your child.'),
          PpScriptLine(say: 'I love you. I do not like that behaviour.',
              notThis: 'You are a bad boy.',
              why: 'Your child is more than the behaviour.'),
          PpScriptLine(say: 'Let us do it together.',
              notThis: 'Why can\'t you be like your cousin?',
              why: 'Comparisons breed shame, not effort.'),
          PpScriptLine(say: 'We are leaving in five minutes.',
              notThis: 'I will leave you here.',
              why: 'Threats of leaving frighten young children deeply.'),
          PpScriptLine(say: 'Boys and girls can both cry.',
              notThis: 'Boys don\'t cry.',
              why: 'Every child needs to express sadness.'),
        ]),
        PpCallout('If you said something you regret, a simple "I was angry '
            'and I should not have said that. I love you" repairs more than '
            'you think.'),
      ],
    ),
  ],
);


// =============================================================================
//  RESLOT — the sibling page, out of the dissolved area
// =============================================================================

const PpPage _siblings = PpPage(
  id: 'siblings',
  title: 'The fighting between them',
  subtitle: 'Sibling rivalry, and the one thing that helps most.',
  format: 'ARTICLE',
  bands: ['preschool'],
  blocks: [
    PpIntro('Some fighting is how siblings learn to negotiate. Constant '
        'fighting is usually about something else.'),
    PpArticle([
      'Underneath most of it is a question about whether there is enough of '
          'you to go round. The children who fight least are usually the '
          'ones who each get a small amount of a parent entirely to '
          'themselves, reliably, on purpose.',
    ], heading: 'Why they do it'),
    PpSteps([
      PpStep('Ten minutes each, alone, most days',
          'It sounds too simple. It works better than any refereeing.'),
      PpStep('Stay out of the small ones',
          'Stepping in every time makes you the prize they are competing '
          'for.'),
      PpStep('Step in immediately for anything physical',
          'Separate first, discuss later.'),
      PpStep('Do not investigate who started it',
          'You will never know, and the search itself teaches them to build '
          'a case.'),
      PpStep('Never compare them out loud',
          'Not even favourably. Especially not favourably.'),
    ], heading: 'What to do'),
    PpCards([
      PpCard('Do not make the older one always give way',
          'You are bigger is not a reason, and it builds real resentment.'),
      PpCard('Do not label them',
          'The clever one and the naughty one both live up to it.'),
    ], heading: 'What not to do', hue: 12),
    PpCallout(
      'Worth raising with your paediatrician if one child is really '
      'frightened of another, or if there is real injury. The same '
      'goes for aggression that is one-way and constant, rather than '
      'a squabble between equals.',
      kind: PpCalloutKind.doctor,
      title: 'When to ask',
    ),
    PpWhenLine('Anywhere from the arrival of a second child onwards.'),
    PpConsult(
      title: 'Talk to a child psychologist',
      whoFor: 'For behaviour that has stopped responding to anything you '
          'try, or that is frightening you. One conversation often changes '
          'the picture, and nothing here is a diagnosis.',
      surfaceId: 'pp_experts',
      role: 'psychologist',
    ),
  ],
);

// =============================================================================
//  NEW — "Back-talk, and 'I hate you'" (3 to 5), the brief's one written page
// -----------------------------------------------------------------------------
//  Copy supplied in full by the brief, dropped in as written.
// =============================================================================

const PpPage _backTalk = PpPage(
  id: 'beh_back_talk',
  title: 'Back-talk, and "I hate you"',
  subtitle: 'Words sharp enough to sting, and no idea yet what they do.',
  format: 'ARTICLE',
  bands: ['preschool'],
  blocks: [
    PpIntro('Around four, children get words sharp enough to sting, and no '
        'idea yet what they do. "I hate you." "You are not my friend." '
        'It lands hard. It almost never means what it says.'),
    PpArticle(heading: 'Why it happens', [
      'A four-year-old feels something huge and grabs the biggest '
          'word to hand. Often "I hate you" means "I am so angry and I do '
          'not know where to put it". Children are finding out what words '
          'do, the way they once found out what a thrown spoon does. The '
          'sting you feel proves the words work, not that they are meant.',
    ]),
    PpSteps([
      PpStep('Do not flinch out loud',
          'Your calm says the word isn\'t a bomb. A big reaction just '
          'shows your child a button.'),
      PpStep('Name what is under it',
          '"You are really angry we are leaving." That\'s the thing your '
          'child couldn\'t say.'),
      PpStep('Hold the line and the love together',
          '"You can be angry with me. I am still not letting you hit."'),
      PpStep('Do not argue the word',
          '"You do not mean that" starts a fight your child wins by '
          'saying it louder. Let it sit.'),
      PpStep('Come back to it small, later',
          '"Earlier you said you hated me. That is okay, you were cross. I '
          'still love you."'),
    ], heading: 'What to do'),
    PpCards([
      PpCard('Do not punish the feeling',
          'You can limit what your child does. Punishing the feeling '
          'teaches hiding it, which is worse at fifteen.'),
      PpCard('Do not say it back', 'Not even as a joke.'),
      PpCard('Don\'t demand a sorry for it',
          'A forced sorry teaches the word, not the meaning.'),
    ], heading: 'What not to do', hue: 232),
    PpScript([
      PpScriptLine(
        say: 'You are allowed to be this angry with me.',
        notThis: 'Do not you dare talk to me like that.',
      ),
      PpScriptLine(
        say: 'I still love you, even when you are this cross.',
        notThis: 'Fine, hate me then.',
      ),
    ], heading: 'The words'),
    PpIndiaNote('In front of family, "I hate you" from a child lands like an '
        'insult to the whole way you are raising your child. Someone '
        'will say "look how this child talks back". You don\'t owe the room '
        'a correction on the spot. Handle it quietly, your way. A calm '
        'child a week later persuades them more than a scolding today.'),
    PpCallout(
      'Worth mentioning to your paediatrician if the rage behind it '
      'is extreme and daily well past four, or if it turns into '
      'hurting. Mention it too if your child seems flat and joyless '
      'rather than stormy.',
      kind: PpCalloutKind.doctor,
      title: 'When to ask',
    ),
    PpWhenLine('Three to five, once the words arrive.'),
  ],
);

// =============================================================================
//  MERGE — Three to six absorbs the dissolved area and gains the new page
// -----------------------------------------------------------------------------
//  `kBehOlderChild` (pp_behaviour_bands.dart) is const and untouched; this is
//  the same area with the sibling page reslotted in and the back-talk page
//  added, assembled here because the pages live in this file.
// =============================================================================

final PpArea _olderChild = PpArea(
  id: kBehOlderChild.id,
  mark: kBehOlderChild.mark,
  title: kBehOlderChild.title,
  blurb: kBehOlderChild.blurb,
  hue: kBehOlderChild.hue,
  bands: kBehOlderChild.bands,
  pages: [...kBehOlderChild.pages, _siblings, _backTalk],
);

// =============================================================================
//  NEW AREAS — the two missing pillars
// -----------------------------------------------------------------------------
//  "The 41 built pages are excellent on one axis and nearly silent on two
//  others. Almost everything here is about the child who acts out. But a
//  parent whose child is the opposite, scared, shy, clingy, or stuck on a
//  habit, opens Behaviour and finds almost nothing." The cards and slots are
//  built now; the copy is being written separately in the house voice and is
//  NOT auto-generated. Each is a coming-soon card that holds its place; the
//  owed ledger (docs/DOOR-CONTENT-OWED.md) lists every one, and the door
//  test fails if one falls out of it.
// =============================================================================

const PpArea _scared = PpArea(
  id: 'scared',
  mark: IntentMark.moonMark,
  title: 'When your child is scared, shy or clingy',
  blurb: 'The fearful, shy or clingy child: the dark, the doctor, dogs, '
      'strangers, and the "say hello, sweetheart" moment.',
  hue: 232,
  bands: _toddlerAndUp,
  pages: [
    PpPage(
      id: 'beh_scared_everything',
      title: 'Why everything is suddenly scary',
      format: 'ARTICLE',
      bands: _toddlerAndUp,
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW by a child psychologist.
        PpIntro('One day your child loved the bath; the next, the bath brings '
            'screams. Sudden fears are a normal part of growing up. They '
            'show that understanding of the world has grown faster than the '
            'sense of safety in it. Most pass in weeks or months.'),
        PpArticle(heading: 'Why fears appear now', [
          'Around eight to ten months, babies start to understand that things '
              'can go wrong: that the vacuum is loud, that you can leave. '
              'Toddlers add imagination, so a shadow can become a monster. '
              'Preschoolers worry about things they hear adults talk about.',
          'A fear is not a sign of a weak or spoilt child. Brave children feel '
              'fear too; they have just had a calm adult beside them while '
              'they faced it.',
        ]),
        PpSteps(heading: 'What helps', [
          PpStep('Hold your child and name it', '"That was loud. You got a fright. I '
              'have you."'),
          PpStep('Do not force it, do not avoid it forever',
              'Let your child watch the scary thing from your arms, then a '
                  'little closer, at a pace that feels okay.'),
          PpStep('Give simple, honest answers', 'To a preschooler\'s worries.'),
          PpStep('Keep your own voice calm', 'Your child reads your face for how dangerous something is.'),
        ]),
        PpScript(heading: 'Words to borrow', [
          PpScriptLine(say: 'You are scared of the mixer. It is loud. Let us '
              'cover our ears together.',
              notThis: 'Don\'t be silly, it is just a mixer.',
              why: 'Naming the fear makes it smaller.'),
        ]),
        PpLink('When fear is worth checking',
            surfaceId: 'pp_page/parenting_behaviour/beh_fear_worth_checking'),
      ],
    ),
    PpPage(
      id: 'beh_fear_dark',
      title: 'Fear of the dark, and the monster under the bed',
      subtitle: 'Night fears, and what helps at bedtime',
      format: 'ARTICLE',
      bands: _toddlerAndUp,
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW by a child psychologist.
        PpIntro('Fear of the dark usually starts between two and four, as '
            'imagination takes off. The monster under the bed is very real '
            'to your child. Arguing won\'t make it go away. What helps is '
            'feeling safe enough to sleep.'),
        PpCards(heading: 'What helps', [
          PpCard('A night light', 'A soft, warm one, or the door left ajar '
              'with the hall light on.'),
          PpCard('Take the fear seriously', 'No teasing, and no "there is '
              'nothing to be scared of". Say "I am here, you are safe."'),
          PpCard('A brave toy', 'A soft toy whose job is to stand guard.'),
          PpCard('Calm bedtimes', 'No scary stories, shows or games before '
              'bed.'),
          PpCard('Check the room together once', 'Then the checking is done. '
              'Looking every night can feed the fear.'),
          PpCard('After a nightmare', 'Hold your child close and offer comfort. Talk it over in the '
              'morning, if your child wants to.'),
        ]),
        PpLink('Nightmares and night terrors',
            surfaceId: 'pp_page/parenting_sleep/night_fears',
            blurb: 'Two very different things, in the Sleep door.'),
      ],
    ),
    PpPage(
      id: 'beh_fear_doctor',
      title: 'The doctor, the injection, the haircut',
      format: 'STEP-LIST',
      bands: _toddlerAndUp,
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW by a child psychologist.
        PpIntro('Doctors, injections and haircuts mean being held still by '
            'strangers, which is frightening at this age. A little '
            'preparation and a lot of honesty make these visits much '
            'easier.'),
        PpSteps(heading: 'Before', [
          PpStep('Play doctor at home', 'With a toy kit, taking turns being '
              'the doctor and the patient.'),
          PpStep('Tell your child what will happen', 'Plainly, the day before. "The doctor will listen to your chest '
              'and look in your ears."'),
          PpStep('Be honest about injections', '"It will pinch for a moment, '
              'and I will hold you." Never "it will not hurt".'),
          PpStep('For a haircut, go to a quiet salon at a quiet time',
              'Or cut it at home during a favourite show.'),
        ]),
        PpSteps(heading: 'During and after', [
          PpStep('Hold your child on your lap', 'A hug hold is calmer than lying '
              'down.'),
          PpStep('Feed or distract', 'Breastfeeding during an injection eases '
              'pain for babies; a song or bubbles for toddlers.'),
          PpStep('Praise the bravery, not the not-crying', '"You were so '
              'brave. It is okay that you cried."'),
        ]),
      ],
    ),
    PpPage(
      id: 'beh_fear_dogs',
      title: 'Scared of dogs, lifts and loud noises',
      format: 'SHORT ARTICLE',
      bands: _toddlerAndUp,
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW by a child psychologist.
        PpIntro('Dogs that bark, lifts that close, loud crackers and pressure '
            'cookers: many toddlers are scared of these. It is normal, and '
            'it usually fades with calm, gradual exposure.'),
        PpSteps(heading: 'What helps', [
          PpStep('Never force your child close', 'Let your child watch from a safe distance in your arms.'),
          PpStep('Small steps', 'A calm dog across the park, then a friend\'s '
              'gentle dog, over weeks.'),
          PpStep('Warn your child before loud things', '"The cooker will whistle '
              'soon."'),
          PpStep('Teach safe rules for dogs', 'Never touch a street dog, or '
              'any dog that is eating or sleeping.'),
        ]),
        PpCallout('A healthy wariness of street dogs keeps your child safe. Keep '
            'that part.'),
      ],
    ),
    PpPage(
      id: 'beh_shy_child',
      title: 'The shy child, and "say hello, sweetheart"',
      format: 'ARTICLE',
      bands: _toddlerAndUp,
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW by a child psychologist.
        PpIntro('"Say hello to aunty, sweetheart." For a shy child, this is torture. '
            'Shyness is a temperament, not a fault. Many shy children grow '
            'into thoughtful, kind adults who warm up slowly and deeply.'),
        PpArticle([
          'Shy children need time to watch before they join in. Pushing them '
              'into the spotlight usually makes them cling more. Giving them '
              'time, and some words for the situation, helps them warm up on '
              'their own.',
        ]),
        PpScript(heading: 'Words to borrow', [
          PpScriptLine(say: 'Give us a little time to warm up. The hello will come when '
              'we\'re ready.',
              notThis: 'Why are you so shy? Say namaste.',
              why: 'Calling a child shy in front of others makes it stick.'),
          PpScriptLine(say: 'You can wave instead of talking, if you like.',
              why: 'A small step your child can manage.'),
        ]),
        PpSteps(heading: 'Helping your child warm up', [
          PpStep('Arrive early at parties', 'Before the crowd.'),
          PpStep('Practise greetings at home', 'With toys and role play.'),
          PpStep('Invite one friend at a time', 'Small groups first.'),
        ]),
      ],
    ),
    PpPage(
      id: 'beh_fear_worth_checking',
      title: 'When fear or clinginess is worth checking',
      format: 'FLAGGED CALLOUT',
      bands: _toddlerAndUp,
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW by a child psychologist.
        PpIntro('Most fears and clinginess are a normal part of growing up. A '
            'few signs suggest a child is struggling more than usual and '
            'would benefit from help. Asking is never an overreaction.'),
        PpCards(heading: 'Worth talking to someone about', [
          PpCard('Fear that stops ordinary life', 'Your child can\'t go to playschool, sleep, or leave the house '
              'because of it.'),
          PpCard('Clinginess that gets worse, not better', 'Over months, '
              'especially after a change or upset.'),
          PpCard('Panic', 'Shaking, sweating, or tummy aches before every '
              'separation.'),
          PpCard('Sad or irritable most days', 'For more than two weeks.'),
          PpCard('No joy in play', 'Things your child loved stop being fun.'),
          PpCard('Changes in sleep or eating', 'Much more or less than usual.'),
          PpCard('Talking about being bad or unloved', 'Or about wishing not to be here.'),
        ]),
        PpCallout('Talk to your paediatrician, who can refer you to a child '
            'psychologist. Young children respond well to help, and parents '
            'are part of the treatment.',
            kind: PpCalloutKind.doctor),
      ],
    ),
    // Added 2026-10-02 from the parenting gap analysis (P2/P3).
    PpPage(
      id: 'beh_comfort_object',
      title: 'The blanket, the soft toy: comfort objects',
      subtitle: 'A healthy way to feel safe',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Many babies and toddlers fall in love with a blanket, a '
            'soft toy or even your old dupatta. It helps them feel safe when '
            'you are not right there. It is a healthy step towards '
            'independence, not a bad habit.'),
        PpSteps([
          PpStep('Let your child choose it', 'Children usually do.'),
          PpStep('Keep a spare', 'Losing it can be a crisis.'),
          PpStep('Wash it now and then', 'Even over protests.'),
          PpStep('No loose objects in the cot under a year',
              'From about a year, one small soft toy is fine.'),
        ]),
      ],
    ),
  ],
);

const PpArea _habits = PpArea(
  id: 'habits',
  mark: IntentMark.bodyMark,
  title: 'The habits that worry you',
  blurb: 'Thumb-sucking, head-banging, rocking, breath-holding, and the '
      'relatives who have noticed.',
  hue: 42,
  bands: _toddlerAndUp,
  pages: [
    PpPage(
      id: 'beh_thumb_sucking',
      title: 'Thumb-sucking, and when to just leave it',
      format: 'ARTICLE',
      bands: _toddlerAndUp,
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW by a child psychologist.
        PpIntro('Sucking a thumb or fingers is one of the first ways babies '
            'learn to calm themselves, and many start in the womb. In the '
            'first years there is nothing to stop, and most children give '
            'it up on their own between two and four.'),
        PpArticle([
          'Thumb-sucking only matters for teeth if it carries on strongly once '
              'adult teeth come in, around five or six. Before then, scolding, '
              'bitter nail paint or tying the hands just adds stress and makes '
              'the habit stronger.',
        ]),
        PpSteps(heading: 'Helping an older child stop', [
          PpStep('Notice when it happens', 'Tired, bored, upset?'),
          PpStep('Offer something else', 'A soft toy to hold, or something '
              'for the hands.'),
          PpStep('Praise the times without it', 'Gently, without a chart.'),
        ]),
        PpCallout('Ask your dentist or doctor if thumb-sucking is still frequent '
            'after five, or if you notice the front teeth changing shape.',
            kind: PpCalloutKind.doctor),
      ],
    ),
    PpPage(
      id: 'beh_head_banging',
      title: 'Head-banging and rocking',
      format: 'ARTICLE',
      bands: _toddlerAndUp,
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW by a child psychologist.
        PpIntro('Some babies and toddlers rock, roll their heads or even bang '
            'their heads against the cot, especially when falling asleep. It '
            'looks alarming, but it is common, and most children are '
            'soothing themselves. It usually stops by three or four.'),
        PpArticle([
          'Rhythmic movement calms the body, a bit like being rocked. Children '
              'rarely hurt themselves. Paying it a lot of attention can make '
              'it last longer.',
        ]),
        PpSteps(heading: 'What helps', [
          PpStep('Keep the cot safe', 'Tighten screws, and move it away from '
              'the wall. No bumpers.'),
          PpStep('Plenty of movement in the day', 'Swings, dancing, rocking '
              'games.'),
          PpStep('A calm bedtime routine', 'With a song to sway to.'),
        ]),
        PpCallout('See your doctor if there are injuries, frequent head-banging '
            'during the day, or other delays in talking or play. The same '
            'goes if it started after your child was developing normally.',
            kind: PpCalloutKind.doctor),
      ],
    ),
    PpPage(
      id: 'beh_breath_holding',
      title: 'Breath-holding spells',
      subtitle: 'The reassurance parents need, and the one line for the doctor',
      format: 'ARTICLE',
      bands: _toddlerAndUp,
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW by a child psychologist.
        PpIntro('A breath-holding spell is one of the most frightening things a '
            'parent can see. Your child cries, holds the breath, turns blue '
            'or pale, and may even go limp for a few seconds. Then the '
            'breathing starts again. Spells are common between six months '
            'and six years, and they are harmless.'),
        PpArticle([
          'They are a reflex, not a choice and not naughtiness. They are '
              'triggered by anger, a fright or a sudden bump. The body always '
              'restarts breathing on its own, and children outgrow them.',
        ]),
        PpSteps(heading: 'During a spell', [
          PpStep('Lay your child on one side', 'Somewhere safe.'),
          PpStep('Stay calm and stay close', 'It lasts under a minute.'),
          PpStep('Don\'t shake or splash water', 'Or put anything in the mouth.'),
          PpStep('Afterwards, comfort your child normally', 'And do not give in to '
              'whatever triggered it.'),
        ]),
        PpCallout('See your doctor after the first spell, to make sure it is not '
            'something else. Some children with spells have low iron, which '
            'can be treated. Call 112 if breathing doesn\'t start within a '
            'minute, or if there is jerking for longer than that.',
            kind: PpCalloutKind.doctor),
      ],
    ),
    PpPage(
      id: 'beh_nail_biting',
      title: 'Nail-biting and the other little habits',
      format: 'SHORT ARTICLE',
      bands: _toddlerAndUp,
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW by a child psychologist.
        PpIntro('Nail-biting, hair-twirling, nose-picking and lip-chewing are '
            'all common in young children, often when they are bored, tired '
            'or worried. Most fade with time, especially when nobody makes '
            'a fuss.'),
        PpSteps(heading: 'Helping with nail biting', [
          PpStep('Notice when it happens', 'Bored, worried, watching TV?'),
          PpStep('Give the hands something to do', 'A squeeze ball or play '
              'dough.'),
          PpStep('Keep nails short', 'Less to bite.'),
          PpStep('Praise the gaps, ignore the biting', 'Scolding makes it '
              'more of a habit.'),
        ]),
      ],
    ),
    // The brief's judgement call 3, included on the user's call
    // (2026-09-13): normal, do not shame, redirect gently, when to mention
    // it. Copy supplied later, like the rest.
    PpPage(
      id: 'beh_self_touching',
      title: 'Touching private parts, and what to do about it',
      subtitle: 'Normal, and the one thing not to do',
      format: 'ARTICLE',
      bands: _toddlerAndUp,
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW by a child psychologist.
        PpIntro('Babies and toddlers discover every part of their bodies, '
            'including their private parts. Touching them is normal, common, '
            'and not sexual in the way adults think of it. It usually just '
            'feels nice or soothing.'),
        PpArticle([
          'The aim is to teach privacy, not to stop it with shame. A '
              'scolded child learns that the body is bad, and becomes less '
              'likely to tell you about inappropriate touch from anyone.',
        ]),
        PpScript(heading: 'Words to borrow', [
          PpScriptLine(say: 'That is your private part. We touch our private '
              'parts in private, like in your room or the bathroom.',
              notThis: 'Yuck. Dirty. Stop that.',
              why: 'Privacy, not shame.'),
        ]),
        PpSteps(heading: 'What helps', [
          PpStep('Redirect calmly', 'Give the hands something else to do.'),
          PpStep('Use the real names for body parts', 'It helps body safety '
              'too.'),
          PpStep('Check comfort', 'Tight clothes, an itch or a nappy rash can '
              'start it.'),
        ]),
        PpCallout('Mention it to your paediatrician if it\'s constant and gets in '
            'the way of play, or if there is redness or discharge. Mention '
            'it too if your child acts out adult sexual behaviour or knows '
            'things a young child shouldn\'t. That can be a sign that '
            'someone has harmed your child.',
            kind: PpCalloutKind.doctor),
        PpLink('Talking about bodies and safe touch',
            surfaceId: 'pp_page/parenting_safety/safety_body_talk'),
      ],
    ),
    // Added 2026-10-02 from the parenting gap analysis (P2/P3).
    PpPage(
      id: 'beh_nappy_fights',
      title: 'Nappy fights, undressing and poo play',
      subtitle: 'The messy phases, handled calmly',
      bands: ['toddler_1', 'toddler_2'],
      format: 'CARDS',
      blocks: [
        PpIntro('Toddlers want control over their bodies, and nappies, '
            'clothes and even poo are where they find it. These phases are '
            'normal and they pass. A calm, matter-of-fact response works '
            'far better than a big reaction.'),
        PpCards(heading: 'Fighting nappy changes and washing', [
          PpCard('Change standing up', 'Many toddlers hate lying down.'),
          PpCard('Give your child a job', 'Holding the clean nappy or the wipes.'),
          PpCard('Make it quick and fun', 'A song, a countdown, a funny face.'),
          PpCard('Offer choices', 'This nappy or that one? Brush now or after '
              'your song?'),
        ]),
        PpCards(heading: 'Taking off clothes and nappies', [
          PpCard('Why', 'Your child has just learned how, and it feels free.'),
          PpCard('What helps', 'Onesies that snap underneath, trousers over '
              'the nappy, and lots of naked time when it is safe.'),
          PpCard('It can be a potty sign', 'Readiness may be close.'),
        ]),
        PpCards(heading: 'Playing with poo', [
          PpCard('Stay calm', 'A big reaction makes it interesting.'),
          PpCard('Clean up together, plainly', '"Poo goes in the nappy."'),
          PpCard('Offer messy play', 'Play dough, sand and water meet the same '
              'need.'),
        ]),
      ],
    ),
    PpPage(
      id: 'beh_eating_nonfood',
      title: 'Eating mud, chalk or paper',
      subtitle: 'Exploring, or something to check',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Babies and young toddlers put everything in their mouths, '
            'and the occasional bit of mud is part of exploring. When a '
            'child keeps eating things that are not food, like mud, chalk, '
            'plaster, wool or paper, past about two years, it has a name: '
            'pica.'),
        PpArticle([
          'Pica is sometimes linked to iron deficiency, which is common '
              'in Indian children, and is more common in autistic children '
              'and children with developmental differences. It can be '
              'dangerous if a child swallows paint flakes, which may contain '
              'lead, or things that can block the gut.',
        ]),
        PpCallout('Talk to your paediatrician if your child keeps eating non-food '
            'things after about two, or eats anything harmful. A simple '
            'blood test for iron and lead may help.',
            kind: PpCalloutKind.doctor),
      ],
    ),
  ],
);

// =============================================================================
//  THE SECTION
// -----------------------------------------------------------------------------
//  ⚠️ FOUR AREAS ACROSS FOUR BANDS, AND THE FIRST ONE IS NOT ABOUT BEHAVIOUR.
//
//  Band A is crying and temperament, because a parent of a three-month-old who
//  opens "Behaviour" has not got a behaviour problem and must not be shown a
//  tantrum library. The spec put it plainly: "Not behaviour yet. This is what a
//  0-1 parent sees."
// =============================================================================

final PpSection kPpBehaviourSection = PpSection(
  id: 'parenting_behaviour',
  title: 'Behaviour',
  intro: 'Why children do it, what to do in the moment, and the words to use.',
  bandSet: kPpChildBands,
  // ⚠️ THE AGE RULE. "The four bands come out. The app knows his age, so
  // the library opens on his band and shows only that band's areas. No band
  // chooser, no 'show every age'."
  autoScope: true,
  // ⚠️ ORDER IS THE SPEC'S ORDER, NOT THE FILE'S. Band A first, then the
  // toddler doors in the sequence the prompt lays them out, then Band C. The
  // band chooser narrows what LEADS; this list decides what a parent scrolling
  // past her own band meets next, and "crying" then "three to six" then
  // "tantrums" would read as a section assembled by whoever wrote it last.
  areas: [
    _crying, // Band A, A1–A6, built in full and untouched
    kBehZiddi, // B1 — the dominant India door, previously absent
    _firstFeelings, // B2 — tantrums and first hitting
    _theNoYear, // B3 — the specific behaviours
    // ⚠️ DISSOLVED. "Fold the old 'Lying, back-talk and screens' area into
    // 'Three to six' (both 3 to 5). Its title promised back-talk and screens
    // but held only lying plus sibling fighting; screens are their own
    // area." Lying merged, siblings reslotted, the const kept for revert.
    // _rulesAndOthers, // B3 — lying, siblings
    kBehSpecific, // B3 — the "he keeps doing this" lookup door
    kBehScreens, // B4 — screens as its own door, per the prompt
    kBehDiscipline, // B5 — previously absent
    kBehCalm, // the regulation activities
    _olderChild, // Band C — kBehOlderChild plus the reslot and the new page
    _scared, // [NEW AREA] the missing half of the section
    _habits, // [NEW AREA] the habits that worry parents
  ],
  // ⚠️ THE SECTION HAD NO TOOLS AT ALL, while this file's header said
  // "nine areas plus three tools". The header was describing the spec rather
  // than the build — which is the most expensive kind of comment, because it
  // reads as a description of what shipped.
  tools: [
    PpSectionTool(
      label: 'What to say when…',
      blurb: 'The exact words for the moment you are in, and what to leave '
          'unsaid. Search it while it is happening.',
      surfaceId: 'pp_scripts',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    // Reused, not rebuilt — the spec is explicit that What Changed carries the
    // behaviour subset and must not be duplicated here.
    PpSectionTool(
      label: 'Something has changed',
      blurb: 'Started biting, head-banging, suddenly clingy. Work through it '
          'calmly.',
      // Pre-filtered to the Behaviour and Mood concerns, the full list one
      // tap away. The user's call (2026-09-13) on the brief's judgement
      // call 1: wire the entry context rather than delete the dead arm.
      surfaceId: 'pp_what_changed/behaviour',
      icon: Icons.swap_horiz_rounded,
    ),
  ],
);
