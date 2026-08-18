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

import 'pp_age_bands.dart';
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
            'A newborn cannot move away from what bothers her, cannot ask for '
                'anything, and cannot wait. Crying is the only tool she has, so '
                'she uses it for hunger, wind, tiredness, a wet nappy, too much '
                'noise, and sometimes for a reason you will never identify.',
            'Researchers who plotted crying across large numbers of babies '
                'found the same shape again and again: a rise through the first '
                'weeks, a peak at around six to eight weeks, then a steady fall. '
                'Some babies cry under two hours a day at that peak and some cry '
                'five. Both sit inside normal.',
            'Evenings are usually the worst of it. A long stretch of fussing '
                'between about 5pm and 10pm is so common that most families have '
                'a name for it, and it passes on its own without anything being '
                'done about it.',
          ],
        ),
        PpSteps(
          heading: 'What to do in the moment',
          [
            PpStep('Run through the basics first', 'Hungry, wind, nappy, too hot or too cold, overtired, '
                    'too much going on around her. Most crying is one of these.'),
            PpStep('Take her somewhere quieter', 'Dim the light, lower the voices, switch the television '
                    'off. An overstimulated baby cannot settle in a busy room, '
                    'however tired she is.'),
            PpStep('Hold her close and move slowly', 'Upright against your chest, skin to skin if you can, '
                    'with a slow steady sway or walk. Rhythm settles a baby far '
                    'better than variety does.'),
            PpStep('Add one sound, not three', 'A long shhh near her ear, a fan, a tap running. White '
                    'noise is close to what she heard inside you.'),
            PpStep('Offer a feed if it is anywhere near due', 'Sucking calms babies even when they are not especially '
                    'hungry.'),
            PpStep('If she is fed, clean and safe and still crying, holding her '
                'is enough', 'You do not have to solve it. Some crying only needs '
                    'company.'),
          ],
        ),
        PpCards(
          heading: 'What not to do',
          hue: 206,
          [
            PpCard('Do not assume every cry is hunger',
                'Feeding a baby who is actually overtired or windy adds '
                'discomfort to discomfort, and it is the easiest mistake to '
                'make because feeding sometimes works.'),
            PpCard('Do not read it as a verdict on you',
                'A baby who cries a lot is not evidence of a mother getting it '
                'wrong. The two are not connected, and every study of this has '
                'said so.'),
            PpCard('Do not measure her against a good baby',
                'A cousin who slept through from week three tells you something '
                'about that baby. It tells you nothing about yours.'),
          ],
        ),
        PpCallout(
          'Call your paediatrician if the cry is high pitched, weak or very '
          'different from usual, if there is any fever in a baby under three '
          'months, if she is feeding poorly, if there are fewer wet nappies '
          'than normal, or if she is floppy or hard to wake. Crying that starts '
          'suddenly, will not settle at all and is unlike her also deserves a '
          'call today.',
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
        PpIndiaNote('In a joint family everyone will have a theory and most of '
            'them will be about your milk. Crying at six weeks is a stage, not '
            'a supply problem. If you are genuinely worried about feeding, '
            'weigh her rather than argue about it.'),
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
            'who will not settle is usually overtired, taking in too much, or '
            'simply not finished being held yet.'),
        PpArticle(
          heading: 'The three usual reasons',
          [
            'Sleep pressure builds far faster in a baby than in you. Miss the '
                'window by fifteen minutes and she is not sleepy any more, she is '
                'wired: stiff legs, arched back, and a cry that gets louder the '
                'more you rock her.',
            'The second reason is the room. A baby cannot filter noise, light '
                'and touch the way you can, so a bright room with three people '
                'talking is not restful to her even when she is exhausted.',
            'The third is contact. Being put down flat and alone is, to a very '
                'new baby, information that something has gone wrong. Wanting '
                'your body is not a habit she has picked up.',
          ],
        ),
        PpSteps(
          heading: 'What to do in the moment',
          [
            PpStep('Lower the room before you do anything else', 'Dim the light, drop your voice, move to the quietest '
                    'space you have.'),
            PpStep('Wrap or hold firmly', 'A snug swaddle or a firm hold against your chest gives '
                    'her back the boundary she lost at birth. Keep the hips loose '
                    'and never anything near her face.'),
            PpStep('Pick one rhythm and stay with it', 'Slow sway, patting, or walking. Same speed for several '
                    'minutes rather than something new every few seconds.'),
            PpStep('Add white noise', 'Steady and boring is the point. A fan, a shhh, a tap.'),
            PpStep('Offer a feed if it is due', 'Comfort sucking is doing something real, not spoiling '
                    'her.'),
            PpStep('When she goes drowsy, stop adding things', 'This is where most of us wake the baby back up. Slow '
                    'down, then be still.'),
          ],
        ),
        PpCards(
          heading: 'What not to do',
          hue: 206,
          [
            PpCard('Do not change method every thirty seconds',
                'Rock, then dummy, then feed, then a different room, all inside '
                'two minutes, and she never gets long enough with any one of '
                'them to slow down.'),
            PpCard('Do not add stimulation to fix crying',
                'Bouncing harder, singing louder or switching on a bright toy '
                'usually makes an overtired baby worse.'),
            PpCard('Do not chase a perfect routine yet',
                'Under three months the routine follows her. It is not the '
                'other way round for a while.'),
          ],
        ),
        PpCallout(
          'Get her checked by your paediatrician rather than trying more '
          'settling techniques if she '
          'arches and screams during or after most feeds, vomits forcefully, '
          'has blood or mucus in her stool, is not gaining weight, or if the '
          'unsettledness arrived suddenly and stayed.',
          kind: PpCalloutKind.doctor,
          title: 'When it is not a settling problem',
        ),
        PpWhenLine('Most relevant from birth to about six months.'),
        PpLink('Something has changed in her sleeping or crying',
            surfaceId: 'pp_what_changed',
            blurb: 'Look up the change and see what it usually means.'),
        PpLink('Settling, naps and night waking',
            surfaceId: 'pp_sleep',
            blurb: 'The full sleep door for her age.'),
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
        PpIntro('Picking up a crying baby does not spoil her. In the first six '
            'months, coming when she calls is the thing that builds her sense '
            'that the world is safe.'),
        PpArticle(
          [
            'A young baby has no way to soothe herself. When she cries and you '
                'come, her body learns that distress ends. That learning is the '
                'floor everything else is built on, including her ability to calm '
                'herself as a toddler.',
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
          'The line you will hear is that you keep him in your godi too much '
          'and he will get spoiled. Being held a great deal is not what spoils '
          'a child. It is what a newborn is built for.',
          kind: PpCalloutKind.myth,
        ),
        PpScript(
          heading: 'Words to use, when it is said in front of you',
          [
            PpScriptLine(
              say: 'The doctor said holding him this much is exactly right at '
                  'his age.',
              notThis: 'You do not know anything about babies.',
              why: 'Naming the paediatrician ends the argument without turning '
                  'it into a question of respect.',
            ),
            PpScriptLine(
              say: 'He is only this small for a few weeks. I want to hold him '
                  'while he still lets me.',
              notThis: 'Please stop telling me what to do with my child.',
              why: 'Agreeing that it is temporary lets an elder step back '
                  'without losing face, which is usually what the argument is '
                  'really about.',
            ),
            PpScriptLine(
              say: 'Would you hold him for a while? My arms are done.',
              why: 'Turning the criticism into a request changes the room. It '
                  'is also the help you actually need.',
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
        PpIndiaNote('In a shared home this advice comes from people who love '
            'your baby and mean well. You do not need to win the argument. You '
            'need to keep picking him up.'),
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
        PpIntro('Babies arrive with a style already fitted. You did not cause '
            'it and you do not have to correct it. Knowing your baby style '
            'mainly makes the day easier to plan.'),
        PpCards(
          heading: 'Three rough styles',
          hue: 206,
          [
            PpCard('The easy going baby',
                'Feeds and sleeps fairly predictably, settles with a little '
                'help, recovers from upset quickly. She needs the same care as '
                'any baby, and it is worth checking she is not being overlooked '
                'simply because she rarely complains.'),
            PpCard('The spirited baby',
                'Big reactions in both directions. Cries hard, laughs hard, '
                'notices everything, needs more help winding down. Lower the '
                'noise and light earlier than feels necessary, and keep the day '
                'less packed than you would like to.'),
            PpCard('The slow to warm baby',
                'Watches from the edge before joining in, dislikes sudden '
                'change, takes longer with new people and new places. Give '
                'warning, give time, and let her arrive at her own speed instead '
                'of handing her over.'),
            PpCard('Most babies, which is a mix',
                'Most sit somewhere between these and shift with teeth, illness '
                'and growth spurts. Use them as a rough map, never as a '
                'category.'),
          ],
        ),
        PpArticle(
          heading: 'What this actually changes',
          [
            'Temperament does not tell you what your child will be like at '
                'twenty. It tells you what will help this week: how much noise '
                'she can take, how much warning she needs, how long she takes to '
                'recover from being upset.',
            'Where your style and hers sit far apart, the friction is real and '
                'it is nobody fault. A quiet parent with a spirited baby is not '
                'doing anything wrong, and neither is the baby.',
          ],
        ),
        PpCallout('These are descriptions of behaviour, not labels for a child '
            'and not a diagnosis of anything. There is no such thing as a '
            'difficult baby.'),
        PpCallout(
          'Temperament is about style, not skills. If she is not making eye '
          'contact, not turning to your voice, not smiling socially by around '
          'three months, or has lost something she was already doing, that is a '
          'separate question and worth raising with your paediatrician.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Useful from birth through the whole first year.'),
        PpLink('Age right things to do together',
            surfaceId: 'pp_activities',
            blurb: 'Play and connection activities for her month.'),
      ],
    ),

    // ---- A5 — THE MANDATORY SAFETY PAGE. NO OFFER ON THIS PAGE. ------------
    PpPage(
      id: 'crying_too_much',
      title: 'When the crying is too much',
      subtitle: 'For the moment you feel you cannot take another minute.',
      format: 'ARTICLE + FLAGGED CALLOUT',
      bands: ['infant'],
      blocks: [
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
          'Today, without waiting: any fever in a baby under three months, a '
          'weak or moaning or high pitched cry, refusing feeds, far fewer wet '
          'nappies, vomiting that shoots out, blood in the stool, breathing '
          'that looks like hard work, floppiness or being hard to wake, a '
          'swollen tender tummy, or crying that started suddenly and nothing '
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
            PpCard('Crying the moment she is put down',
                'A preference for your body, not a symptom.'),
            PpCard('Crying during a nappy change or a bath',
                'Being undressed is genuinely unpleasant to a young baby. It '
                'passes with age, not with technique.'),
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
      subtitle: 'Why they start now, and what actually shortens them.',
      format: 'ARTICLE',
      bands: _toddler,
      blocks: [
        PpIntro('Somewhere around the first birthday your child starts wanting '
            'things very much and having almost no way to say so. That gap is '
            'where tantrums live.'),
        PpArticle([
          'A tantrum at this age is not manipulation and it is not a decision. '
              'The part of the brain that manages strong feeling is years away '
              'from being finished, so when the feeling is bigger than the '
              'child, it simply comes out.',
          'Which is why reasoning does not work in the moment. She cannot hear '
              'you, not because she is refusing to, but because the thinking '
              'part of her brain is offline until the feeling passes.',
        ], heading: 'Why they do it'),
        PpSteps([
          PpStep('Get down to her level',
              'Standing over a small person having a big feeling makes it '
              'bigger.'),
          PpStep('Say the feeling, not the rule',
              'You wanted the biscuit. You are so angry. Naming it is what '
              'starts bringing it down.'),
          PpStep('Stay, and stay quiet',
              'You do not have to fix it or talk it through. Being there while '
              'it passes is the whole job.'),
          PpStep('Wait for the body to settle before saying anything else',
              'Breathing slows, the crying changes pitch. That is when she can '
              'hear you again.'),
          PpStep('Move on properly', 'No lecture afterwards. It is finished.'),
        ], heading: 'What to do in the moment'),
        PpCards([
          PpCard('Do not reason mid-tantrum',
              'Every sentence you say while she is at full volume is one she '
              'cannot process.'),
          PpCard('Do not give in to end it',
              'Not because giving in spoils her, but because it teaches that '
              'the tantrum is the way to ask.'),
          PpCard('Do not laugh or film it',
              'It is real to her, and being laughed at while overwhelmed is the '
              'part children remember.'),
          PpCard('Do not send her away alone',
              'At this age the feeling is too big to be alone with.'),
        ], heading: 'What not to do', hue: 12),
        PpScript([
          PpScriptLine(
            say: 'You really wanted that. I know.',
            notThis: 'Stop crying, it is not a big deal.',
            why: 'The first tells her the feeling makes sense. The second tells '
                'her it does not, which usually makes it louder.',
          ),
          PpScriptLine(
            say: 'I am right here. I will wait with you.',
            notThis: 'Come and talk to me when you have calmed down.',
            why: 'A one-year-old cannot calm down alone yet. That comes later, '
                'and it comes from being helped to do it now.',
          ),
        ], heading: 'Words to use'),
        PpCallout(
          'Worth raising with your paediatrician if tantrums come with holding '
          'the breath until she goes limp or blue, if she hurts herself badly '
          'and on purpose, or if they are so frequent and so long that most of '
          'the day is spent in one.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('From about 12 months, peaking through the second year.'),
        PpIndiaNote('In a joint family a tantrum has an audience, and half the '
            'pressure you feel is theirs and not hers. It is fair to pick her '
            'up and take her to another room, for your sake as much as hers.'),
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
        PpArticle([
          'Biting and hitting peak in the second year for a simple reason: '
              'strong feeling, no words. Frustration, excitement, tiredness and '
              'teething all come out through the body, because the body is what '
              'she has.',
        ], heading: 'Why they do it'),
        PpSteps([
          PpStep('Attend to the child who was hurt first',
              'It teaches more than any telling-off, and it is the right thing '
              'to do anyway.'),
          PpStep('Be short and clear',
              'No biting. Biting hurts. Two sentences, calm voice.'),
          PpStep('Give her the word she was missing',
              'You wanted the toy. Say: my turn.'),
          PpStep('Move her to something else',
              'At this age separation from the situation works; a long '
              'explanation does not.'),
        ], heading: 'What to do in the moment'),
        PpCards([
          PpCard('Never bite back',
              'It is still advised in some families. It teaches that biting is '
              'what big people do when they are angry.'),
          PpCard('Do not label her',
              'She is a biter becomes something she believes about herself.'),
          PpCard('Do not make her say sorry',
              'A forced sorry teaches the word, not the meaning. Show her how '
              'to help instead.'),
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
          'Worth raising with your paediatrician if it is getting worse rather '
          'than better after a few months, if it happens in a calm and '
          'unprovoked way rather than in frustration, or if she is over three '
          'and still biting often.',
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
      title: 'She cries every time I leave',
      subtitle: 'Separation anxiety, and why it is a good sign.',
      format: 'ARTICLE',
      bands: _toddler,
      blocks: [
        PpIntro('It usually arrives around eight months, gets stronger through '
            'the second year, and it means the attachment is working.'),
        PpArticle([
          'A baby who protests when you leave has understood two things: that '
              'you are a specific and irreplaceable person, and that you carry '
              'on existing when she cannot see you. Both are developmental wins '
              'that happen to be extremely inconvenient.',
        ], heading: 'Why they do it'),
        PpSteps([
          PpStep('Always say you are going',
              'Slipping away avoids the crying now and costs you trust later.'),
          PpStep('Keep the goodbye short and the same every time',
              'A ritual beats a long reassurance.'),
          PpStep('Say when you will be back in her terms',
              'After your nap. Clock time means nothing yet.'),
          PpStep('Hand over to the same person where you can',
              'One familiar pair of arms is worth more than any distraction.'),
        ], heading: 'What to do'),
        PpCards([
          PpCard('Do not sneak out', 'It makes every future exit frightening.'),
          PpCard('Do not come back in when she cries',
              'It teaches that crying reopens the door, which makes the next '
              'goodbye longer.'),
          PpCard('Do not tell her she is being silly',
              'The feeling is real even when the danger is not.'),
        ], heading: 'What not to do', hue: 12),
        PpCallout(
          'Worth raising with your paediatrician if she cannot be settled by '
          'anyone at all for long periods, if it appears suddenly in a child '
          'who was fine, or if it is still severe enough at four or five to '
          'stop her going to school.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('From about 8 months, strongest between 1 and 2 years.'),
        PpIndiaNote('If grandparents or a maid share the care, the goodbye '
            'ritual works best when it is the same whoever is doing it. Agree '
            'it out loud with them once.'),
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
  title: 'She says no to everything',
  blurb: 'Defiance, big tantrums, and sharing.',
  hue: 268,
  bands: _olderToddlerAndUp,
  pages: [
    PpPage(
      id: 'defiance',
      title: 'Saying no to everything',
      subtitle: 'What defiance at two actually is.',
      format: 'ARTICLE',
      bands: _olderToddlerAndUp,
      blocks: [
        PpIntro('Around two, a child works out that she is a separate person '
            'with her own opinion. No is her practising that.'),
        PpArticle([
          'This is not the start of a discipline problem. It is the start of a '
              'self. A child who never pushed back would be a worry; this one '
              'is doing exactly what a two-year-old is supposed to do.',
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
          PpStep('Let her do the bit she can do',
              'Slowly and badly, but herself. It buys cooperation everywhere '
              'else.'),
          PpStep('Hold the line on the few that matter',
              'Safety, kindness, and not much else. Everything is not a hill.'),
        ], heading: 'What to do'),
        PpCards([
          PpCard('Do not ask a question you cannot accept no to',
              'Shall we go home now invites the answer you do not want.'),
          PpCard('Do not turn it into a contest',
              'She has more time and less shame than you do.'),
          PpCard('Do not threaten what you will not do',
              'One unkept threat costs you the next ten.'),
        ], heading: 'What not to do', hue: 12),
        PpScript([
          PpScriptLine(
            say: 'You can walk to the car, or I can carry you. You choose.',
            notThis: 'If you do not come now I am leaving you here.',
            why: 'The first keeps her autonomy inside your boundary. The second '
                'is a threat you will not carry out, and she knows it.',
          ),
        ], heading: 'Words to use'),
        PpCallout(
          'Worth raising with your paediatrician if the defiance is extreme and '
          'constant across every setting, if she seems to have no happy periods '
          'at all, or if she is losing skills she previously had.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('Peaks between 2 and 3 years, eases through the fourth.'),
        PpIndiaNote('Itni zid kyun karti hai is the line most families reach '
            'for, and it lands on the child as a judgement about who she is. '
            'Zid at two is a stage, not a personality.'),
      ],
    ),
    PpPage(
      id: 'sharing',
      title: 'She will not share',
      subtitle: 'Because she cannot yet, not because she will not.',
      format: 'ARTICLE',
      bands: _olderToddlerAndUp,
      blocks: [
        PpIntro('Real sharing needs the ability to imagine how somebody else '
            'feels. That arrives properly around four, not two.'),
        PpArticle([
          'What looks like selfishness at two is usually an accurate report of '
              'what she understands: this is mine, and giving it away means '
              'losing it forever. Turn-taking is the skill that actually works '
              'at this age, because it comes with a promise that the toy comes '
              'back.',
        ], heading: 'Why they do it'),
        PpSteps([
          PpStep('Teach turns instead of sharing',
              'Your turn, then her turn. A timer helps, and it takes you out of '
              'the argument.'),
          PpStep('Let her finish',
              'Being made to hand over mid-play teaches that turns are '
              'unsafe.'),
          PpStep('Put the treasured things away before friends come',
              'One or two special toys are allowed to be hers alone.'),
          PpStep('Name what the other child feels',
              'She is sad because she is waiting. That is the seed of the '
              'skill.'),
        ], heading: 'What to do'),
        PpCards([
          PpCard('Do not force her to hand it over',
              'It teaches compliance to whoever is loudest, not generosity.'),
          PpCard('Do not call her selfish',
              'She is two. The word will stay long after the stage has gone.'),
        ], heading: 'What not to do', hue: 12),
        PpCallout(
          'Worth raising with your paediatrician if by four or five she shows '
          'no interest in other children at all, or does not seem to notice '
          'when someone else is upset.',
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

const PpArea _rulesAndOthers = PpArea(
  id: 'rules_and_others',
  mark: IntentMark.blocksMark,
  title: 'Lying, back-talk and screens',
  blurb: 'The behaviours that arrive once there are words for everything.',
  hue: 42,
  bands: ['preschool'],
  pages: [
    PpPage(
      id: 'lying',
      title: 'She told me a lie',
      subtitle: 'What lying at four actually means.',
      format: 'ARTICLE',
      bands: ['preschool'],
      blocks: [
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
    PpPage(
      id: 'screens',
      title: 'Screens, and the fight to turn them off',
      subtitle: 'Where the actual problem is, and it is not the screen.',
      format: 'ARTICLE',
      bands: ['preschool'],
      blocks: [
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
    PpPage(
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
          'Worth raising with your paediatrician if one child is genuinely '
          'frightened of another, if there is real injury, or if the aggression '
          'is one-way and constant rather than a squabble between equals.',
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

const PpSection kPpBehaviourSection = PpSection(
  id: 'parenting_behaviour',
  title: 'Behaviour',
  intro: 'Why she does it, what to do in the moment, and the words to use.',
  bandSet: kPpChildBands,
  areas: [
    _crying,
    _firstFeelings,
    _theNoYear,
    _rulesAndOthers,
  ],
);
