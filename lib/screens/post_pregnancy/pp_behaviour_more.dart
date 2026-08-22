// =============================================================================
//  Behaviour — the specific-behaviour, screen-time and regulation doors
// -----------------------------------------------------------------------------
//  The remainder of the build prompt, finished. `pp_behaviour_bands.dart` added
//  the three doors that were entirely absent (ziddi, discipline, Band C); this
//  file adds the three that were thin: the "he is doing X" lookup door, screen
//  time as its own door, and the calm-down activities.
//
//  ⚠️ THE BRIEF FOR THIS BUILD WAS "IT SHOULD NOT LOOK INCOMPLETE", AND IN THIS
//  SYSTEM THAT IS A CONTENT DECISION RATHER THAN A STYLING ONE.
//
//  Every page here renders through the same V3 renderer as every other section,
//  so the way to make a page look finished is to USE THE VOCABULARY: a video at
//  the top, the fixed skeleton underneath, a chart where numbers are the
//  answer, a script box where the answer is words, an India note where the
//  situation is genuinely Indian. A page built from an intro and two
//  paragraphs is what "basic" looks like on this renderer, and no amount of
//  styling fixes it.
//
//  ⚠️ THE FIXED SKELETON, IN THIS ORDER, ON EVERY [ARTICLE]:
//    why they do it  ->  PpIntro / PpArticle
//    in the moment   ->  PpSteps
//    what NOT to do  ->  PpCards
//    words to use    ->  PpScript
//    when to worry   ->  PpCallout(kind: doctor)
//    age + related   ->  PpWhenLine + PpLink
//
//  ⚠️ THE ACTIVITIES ARE PAGES, NOT ENTRIES IN THE ACTIVITY ENGINE. The engine
//  (`kDevActivities` / `kGrowExtraActivities`) is age-tagged play for
//  development; these are regulation techniques a parent reaches for mid-storm,
//  and they belong beside the behaviour they defuse. Putting them in the engine
//  would file "balloon breathing" next to "peekaboo".
//
//  ⚠️ NO EM DASHES. The section's copy rule forbids them and
//  `pp_section_test.dart` enforces it. Nineteen slipped into the last file and
//  had to be unpicked; they are absent here by construction.
//
//  English only for now, plain `String`, per the standing instruction.
// =============================================================================

import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

const List<String> _bandB = ['toddler_1', 'toddler_2'];
const List<String> _bandBC = ['toddler_1', 'toddler_2', 'preschool'];

// =============================================================================
//  B3 — the "he is doing X" lookup door
// =============================================================================

const PpArea kBehSpecific = PpArea(
  id: 'specific_behaviours',
  // ⚠️ NOT `questionMark` — "She says no to everything" already owns it in
  // this section. `compareMark` because this door is a lookup: a parent
  // arrives knowing the behaviour and is matching it against a list.
  mark: IntentMark.compareMark,
  title: 'He keeps doing this one thing',
  blurb: 'Throwing, screaming, hitting out, ignoring you, whining. What each '
      'one usually means, and what to do with it tonight.',
  hue: 42,
  bands: _bandBC,
  pages: [
    // ---------------------------------------------------------------- throwing
    PpPage(
      id: 'beh_throwing',
      title: 'He throws everything',
      format: 'ARTICLE',
      bands: _bandB,
      blocks: [
        PpVideoSlot(
          title: 'Why throwing is an experiment',
          subtitle: 'What a one-year-old is actually testing when the spoon '
              'goes over the side for the fortieth time.',
          minutes: '4 MIN',
          slotId: 'behaviour/throwing',
        ),
        PpIntro('Somewhere around one, throwing stops being an accident and '
            'becomes a project. He is not being destructive. He is running the '
            'same experiment over and over to find out whether the world '
            'behaves the same way every time.'),
        PpArticle(heading: 'What he is working out', [
          'Three things at once: that letting go makes something fall, that it '
              'falls the same way each time, and that YOU react. The third one '
              'is usually the most interesting to him, which is why the '
              'throwing gets worse the more spectacular your response is.',
          'It is also a motor skill. Releasing on purpose is harder than '
              'grabbing, and throwing is how it gets practised.',
        ]),
        PpSteps([
          PpStep('Say what stays and what goes',
              '"Food stays on the tray. Balls can be thrown." A rule about '
              'everything is one he cannot follow.'),
          PpStep('Give him something he IS allowed to throw',
              'A soft ball, a rolled sock, a basket to aim at. The urge is '
              'real and it needs an outlet, not just a no.'),
          PpStep('Make your reaction boring',
              'Pick it up once without comment. Twice, and the meal is over. '
              'Said flatly, not crossly.'),
          PpStep('End the activity rather than punish it',
              '"Looks like you are finished." Lift him down calmly. Related, '
              'immediate, and nothing to argue with.'),
          PpStep('Try again cheerfully next time',
              'He is not holding a grudge and neither should the next meal.'),
        ], heading: 'In the moment'),
        PpCards([
          PpCard('Do not laugh the first three times',
              'It is genuinely funny, and it teaches him this is a game the '
              'two of you play. Then getting cross on the fourth is a change '
              'of rules he cannot follow.'),
          PpCard('Do not hand it back repeatedly',
              'That IS the game. One retrieval, then the thing goes away.'),
          PpCard('Do not call him naughty for it',
              'This is cause and effect, which is the same thing you praise '
              'him for on a stacking toy.'),
        ], heading: 'What not to do', hue: 42),
        PpScript([
          PpScriptLine(
            say: 'Food stays on the tray. If you are finished, say all done.',
            notThis: 'Stop it! Stop throwing!',
            why: 'Names what to do instead. "Stop" tells him nothing about '
                'what comes next.',
          ),
          PpScriptLine(
            say: 'You want to throw. Here, throw this instead.',
            notThis: 'How many times do I have to tell you?',
            why: 'The urge is legitimate. Redirecting it works far better than '
                'suppressing it.',
          ),
        ], heading: 'Words to use'),
        PpCallout(
          'Worth mentioning if the throwing is aimed at people and connects '
          'often, if it comes with hurting himself, or if it is still the main '
          'way he handles frustration well past three. Not the throwing '
          'itself, which is ordinary.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('Peaks between about one and two, and fades as words '
            'arrive.'),
        PpIndiaNote('Food thrown on the floor lands differently in a house '
            'where somebody else is cleaning it, and the pressure to stop it '
            'immediately comes from that rather than from him. A mat under the '
            'chair settles more arguments than any technique.'),
        PpLink('What to say when it happens',
            surfaceId: 'pp_scripts',
            blurb: 'The mealtime lines, ready to use.'),
      ],
    ),

    // --------------------------------------------------------------- screaming
    PpPage(
      id: 'beh_screaming',
      title: 'The screaming',
      format: 'ARTICLE',
      bands: _bandB,
      blocks: [
        PpIntro('Some children find a volume and then find out what it does. '
            'Others scream because everything is too much and it is the only '
            'sound big enough. The two look identical and need opposite '
            'responses.'),
        PpArticle(heading: 'Telling them apart', [
          'A for-effect scream usually comes with a look at you. He is '
              'checking. It stops when nobody reacts and starts again when '
              'somebody does.',
          'An overwhelm scream has no audience in it. Eyes shut, body rigid, '
              'and it keeps going whether you are watching or not. This one '
              'needs less noise and less light, not a firmer boundary.',
          'You will get it wrong sometimes and that is fine. Responding gently '
              'to a for-effect scream costs nothing; responding firmly to an '
              'overwhelmed child makes it longer.',
        ]),
        PpSteps([
          PpStep('Lower your own voice instead of raising it',
              'He matches whichever volume is in the room. Going quieter '
              'forces him to come down to hear you.'),
          PpStep('Name it once',
              '"That is very loud. My ears hurt." Then stop explaining.'),
          PpStep('Give the indoor version',
              '"You can shout in the balcony." A place to be loud beats never '
              'being loud.'),
          PpStep('For overwhelm, reduce everything',
              'Fewer people, less light, no questions. Take him somewhere '
              'smaller and wait.'),
        ], heading: 'In the moment'),
        PpCards([
          PpCard('Do not out-shout him', 'You will lose, and he learns that '
              'the loudest person wins.'),
          PpCard('Do not laugh at it', 'Even once. It is a very good sound to '
              'get a reaction with.'),
          PpCard('Do not reason mid-scream',
              'Nothing is going in. Wait for the volume to drop first.'),
        ], heading: 'What not to do', hue: 42),
        PpWhenLine('One to three, and much less common once talking is fluent.'),
        PpLink('If it is really a tantrum',
            pageId: 'first_tantrums',
            blurb: 'The overwhelmed version, and what it needs.'),
      ],
    ),

    // ------------------------------------------------------------------- anger
    PpPage(
      id: 'beh_anger',
      title: 'Anger, and hurting out of it',
      format: 'ARTICLE',
      bands: _bandBC,
      blocks: [
        PpVideoSlot(
          title: 'Lending calm to an angry child',
          subtitle: 'Co-regulation shown in real time, with a child who is '
              'genuinely furious.',
          minutes: '6 MIN',
          slotId: 'behaviour/anger',
        ),
        PpIntro('Anger is not a behaviour problem. It is a feeling, and a young '
            'child has the same size of it as an adult with none of the '
            'equipment for holding it.'),
        PpArticle(heading: 'What is actually happening', [
          'The part of the brain that manages impulses is years from finished. '
              'When anger arrives it goes almost straight to the body, which '
              'is why it comes out as a hand or a foot rather than a sentence.',
          'That is not an excuse for hitting, and it is the reason punishment '
              'does not work on it. He is not choosing not to control himself; '
              'he cannot yet, and he learns how by borrowing yours enough '
              'times.',
        ]),
        PpSteps([
          PpStep('Keep everyone safe first',
              'Move him, or move the other child. Nothing else can happen '
              'until this is done.'),
          PpStep('Be the calm one',
              'Slower voice, slower movements. He is looking for something '
              'steady to copy and there is nothing else in the room.'),
          PpStep('Name the feeling, not the crime',
              '"You are so angry." Not "that was very naughty".'),
          PpStep('Give the body somewhere to go',
              'Push the wall, stamp, squeeze a cushion. Anger is physical and '
              'it will come out somewhere.'),
          PpStep('Repair afterwards, together',
              'Ice for the other child, a hand held. Doing rather than '
              'apologising.'),
        ], heading: 'In the moment'),
        PpCards([
          PpCard('Do not punish the feeling',
              'You can limit what he does. Telling him not to feel it teaches '
              'him to hide it, which is worse at fifteen.'),
          PpCard('Do not hit a child for hitting',
              'It is the one lesson that definitely lands, and it is the '
              'opposite of the one intended.'),
          PpCard('Do not force a sorry',
              'It teaches that a word closes the incident. Repair does more.'),
        ], heading: 'What not to do', hue: 42),
        PpScript([
          PpScriptLine(
            say: 'You are so angry. I am going to keep everyone safe.',
            notThis: 'Say sorry right now.',
            why: 'Names the feeling and the limit in one sentence, without '
                'asking for something he cannot yet mean.',
          ),
          PpScriptLine(
            say: 'Your body wants to hit. Hit the cushion, not your sister.',
            notThis: 'Do not you dare.',
            why: 'Redirects the impulse rather than trying to delete it.',
          ),
        ], heading: 'Words to use'),
        PpCallout(
          'Worth a conversation with your paediatrician if the aggression is '
          'daily, if it regularly injures someone, if he turns it on himself, '
          'or if it is getting worse rather than slowly better past four. '
          'These are separate from ordinary toddler anger and worth a proper '
          'look.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('One to six, easing as language and impulse control grow.'),
        PpLink('Calm-down corner',
            pageId: 'beh_calm_corner',
            blurb: 'A place to go, set up before it is needed.'),
      ],
    ),

    // ------------------------------------------------------------ not listening
    PpPage(
      id: 'beh_not_listening',
      title: 'He does not listen to anything I say',
      format: 'ARTICLE',
      bands: _bandBC,
      blocks: [
        PpIntro('Almost always this is about how the asking is happening rather '
            'than about the child, and that is good news, because the asking '
            'is the part you can change.'),
        PpArticle(heading: 'Why it happens', [
          'A young child can hold roughly one instruction at a time, needs a '
              'few seconds to switch from what he is doing, and genuinely does '
              'not hear a sentence shouted from another room while he is '
              'absorbed in something.',
          'And if a request is repeated four times before anything happens, he '
              'has learned, correctly, that the first three do not count.',
        ]),
        PpSteps([
          PpStep('Go to him',
              'Broadcasting from the kitchen is not asking.'),
          PpStep('Get his eyes first',
              'A hand on the shoulder, his name, a pause. Then speak.'),
          PpStep('One thing, said as an action',
              '"Shoes on" beats "we are late, get ready, where is your bag".'),
          PpStep('Wait four seconds',
              'Longer than it feels. Repeating at second two is what taught '
              'him to wait for the third ask.'),
          PpStep('Follow through the first time',
              'If it mattered enough to ask, see it through calmly. This is '
              'the whole technique.'),
        ], heading: 'What works'),
        PpCards([
          PpCard('Do not count to three',
              'It works, and what it teaches is that nothing happens until '
              'three.'),
          PpCard('Do not ask when it is not a choice',
              '"Shall we go now?" invites a no you will not accept.'),
          PpCard('Do not save up corrections',
              'Twelve before breakfast and none of them register.'),
        ], heading: 'What quietly backfires', hue: 42),
        PpWhenLine('Two to six.'),
        PpIndiaNote('In a house with several adults he may be getting four '
            'different instructions at once, and ignoring all of them is a '
            'reasonable response. Agreeing who is asking, in the moment, does '
            'more than any technique.'),
      ],
    ),

    // -------------------------------------------------------------- whining ---
    PpPage(
      id: 'beh_whining',
      title: 'The whining',
      format: 'SHORT ARTICLE',
      bands: _bandBC,
      blocks: [
        PpIntro('The sound that gets through your skin faster than screaming '
            'does. It is almost always tiredness, hunger, or a bid for you '
            'that has not worked yet in a normal voice.'),
        PpSteps([
          PpStep('Answer the need, not the tone',
              'If he is hungry, feed him. Refusing on principle while he is '
              'genuinely tired teaches nothing except that you did not '
              'notice.'),
          PpStep('Name the voice, once, without irritation',
              '"I cannot hear that voice. Try your big voice."'),
          PpStep('Respond immediately when the voice changes',
              'The reward has to be instant or the lesson does not connect.'),
          PpStep('Check the day before blaming the sound',
              'Whining spikes before meals, before naps, and after too much '
              'company. It is usually a symptom.'),
        ], heading: 'What to do'),
        PpCards([
          PpCard('Do not mimic it', 'It stings, and he will remember it much '
              'longer than you will.'),
          PpCard('Do not give in to it',
              'Then it is the voice that works, and it will be used again.'),
        ], heading: 'What not to do', hue: 42),
        PpWhenLine('Two to six.'),
      ],
    ),
  ],
);

// =============================================================================
//  B4 — screen time, as its own door
// =============================================================================

const PpArea kBehScreens = PpArea(
  id: 'screen_time',
  mark: IntentMark.lampMark,
  title: 'Screens, in a real house',
  blurb: 'How much, how to end it without a meltdown, and how to hold a line '
      'when the phone is how everyone gets fed.',
  hue: 188,
  bands: _bandBC,
  pages: [
    PpPage(
      id: 'beh_screen_limits',
      title: 'How much is too much, honestly',
      format: 'CHART',
      bands: _bandBC,
      blocks: [
        PpVideoSlot(
          title: 'What screens do and do not do at this age',
          subtitle: 'A paediatrician on what the evidence actually says, '
              'without the panic.',
          minutes: '6 MIN',
          slotId: 'behaviour/screen_evidence',
        ),
        PpIntro('The guidance below is a starting point, not a verdict on your '
            'parenting. Almost every Indian household is above it, including '
            'the ones giving the advice, and a number you cannot hit is not '
            'guidance, it is a way to feel bad.'),
        PpTable(
          heading: 'Rough guidance by age',
          columns: ['Age', 'Usual advice', 'What matters more'],
          rows: [
            ['Under 18 months', 'None, except video calls',
                'Video calls with family are genuinely different. They are a '
                'conversation, not a broadcast.'],
            ['18 months to 2', 'A little, watched together',
                'Sitting with him and talking about it changes what a screen '
                'is. Alone in another room is the version that costs.'],
            ['2 to 5', 'About an hour a day',
                'What it replaces. An hour instead of a nap is different from '
                'an hour instead of the third bout of nagging.'],
          ],
        ),
        PpArticle(heading: 'The part nobody says out loud', [
          'A screen at mealtimes so that a toddler eats, or during a work '
              'call, or on a four-hour train, is not a failure. It is a tool '
              'with a cost, and the cost is smaller than a mother who has not '
              'sat down in eleven hours.',
          'What the evidence is clearest about is not the total minutes. It is '
              'that passive watching alone displaces talking, moving and '
              'sleeping, and that background television in a room reduces how '
              'much anyone in it speaks. Those are the levers worth pulling.',
        ]),
        PpCards([
          PpCard('Quality is not a marketing word here',
              'Slow, narrated, repetitive things a child can follow beat fast '
              'cuts and bright noise, at any duration.'),
          PpCard('Watch with him when you can',
              'Talking about what is on screen turns watching into language.'),
          PpCard('Not in the hour before bed',
              'This one has the clearest effect of any rule on this page.'),
        ], heading: 'Three things worth more than the number', hue: 188),
        PpWhenLine('Eighteen months and up.'),
        PpIndiaNote('If the phone is how he eats, you are not alone and it is '
            'not a moral failing. Changing one meal a day is a realistic goal; '
            'changing all of them at once is how a plan gets abandoned by '
            'Thursday.'),
      ],
    ),
    PpPage(
      id: 'beh_screen_ending',
      title: 'Ending it without a meltdown',
      format: 'STEP-LIST',
      bands: _bandBC,
      blocks: [
        PpVideoSlot(
          title: 'The handover, shown',
          subtitle: 'Warning, timer, landing spot. Filmed with a child who '
              'does not want to stop.',
          minutes: '3 MIN',
          slotId: 'behaviour/screen_transition',
        ),
        PpIntro('What he is protesting is almost never the screen. It is the '
            'ambush: absorbed one second, empty-handed the next, with no '
            'warning and nothing to move to.'),
        PpSteps([
          PpStep('Warn before the end, in his units',
              '"Two more songs", not "five more minutes". A three-year-old '
              'has no idea what five minutes is.'),
          PpStep('Use a timer he can hear',
              'It makes the rule the timer instead of you, which takes you out '
              'of the fight entirely.'),
          PpStep('End at a natural stop',
              'The end of an episode, not the middle. Stopping mid-story is '
              'genuinely harder for him.'),
          PpStep('Have the next thing ready',
              'Snack on the table, bath running, you on the floor. An empty '
              'gap after a screen is what the meltdown fills.'),
          PpStep('Let him be cross about it anyway',
              'Sometimes he will be. Doing all of this and still getting '
              'protest is not the technique failing.'),
        ], heading: 'The handover'),
        PpCards([
          PpCard('Do not snatch it', 'It is the single most reliable way to '
              'produce a scream.'),
          PpCard('Do not extend once',
              'The fifth "five more minutes" taught him that the number is '
              'negotiable.'),
          PpCard('Do not use it as the only calming tool',
              'If a screen is the only thing that settles him, that is the '
              'thing worth slowly widening.'),
        ], heading: 'What not to do', hue: 188),
        PpScript([
          PpScriptLine(
            say: 'When the timer beeps, the phone goes to sleep. Then snack.',
            notThis: 'Give it to me. Now.',
            why: 'Makes the timer the authority and names what comes next.',
          ),
          PpScriptLine(
            say: 'You really wanted more. It is finished for today.',
            notThis: 'You have had enough, do not start.',
            why: 'Acknowledges the want without reopening the decision.',
          ),
        ], heading: 'Words to use'),
        PpWhenLine('Eighteen months and up.'),
        PpLink('The words, for this and eleven other moments',
            surfaceId: 'pp_scripts'),
      ],
    ),
    PpPage(
      id: 'beh_screens_family',
      title: 'When everyone in the house has a phone',
      format: 'ARTICLE',
      bands: _bandBC,
      blocks: [
        PpIntro('Every rule you set is competing with what he can see, and what '
            'he can see is four adults on their phones and a television that '
            'has been on since morning.'),
        PpArticle(heading: 'The honest problem', [
          'Grandparents hand over a phone out of love, to stop a cry they find '
              'unbearable. Helpers use it because a settled child is a safer '
              'child while they cook. Neither is being careless, and both will '
              'keep doing it unless there is something else to do instead.',
          'And background television is doing quiet damage nobody attributes '
              'to it: a room with a TV on has measurably less conversation in '
              'it, which is the one thing that matters most at this age.',
        ]),
        PpSteps([
          PpStep('Pick one rule, not five',
              'No screens at the dining table is the highest-value single '
              'rule in most Indian homes.'),
          PpStep('Make it about the house, not the child',
              '"We are not using phones at the table" includes you, and is '
              'much easier for elders to accept.'),
          PpStep('Turn the TV off rather than down',
              'Background sound is the part that costs, and nobody is '
              'watching it anyway.'),
          PpStep('Give the alternative, physically',
              'A box of things by the sofa. People stop doing something when '
              'there is something else in reach.'),
          PpStep('Accept a different standard elsewhere',
              'At dadi house it is different. Children handle that far better '
              'than they handle their parents fighting about it.'),
        ], heading: 'What tends to work'),
        PpWhenLine('Any age, and easiest to set before he can ask.'),
        PpIndiaNote('If a helper is with him most of the day, the conversation '
            'has to be with her, specifically, and it has to come with an '
            'alternative rather than only a rule. She is managing a child, a '
            'kitchen and a clock at the same time.'),
        PpLink('When elders do it differently',
            pageId: 'beh_elders',
            blurb: 'The wider version of this conversation.'),
      ],
    ),
  ],
);

// =============================================================================
//  Regulation activities
// =============================================================================

const PpArea kBehCalm = PpArea(
  id: 'calming',
  mark: IntentMark.lotusMark,
  title: 'Things that actually calm him',
  blurb: 'Six small practices to set up before you need them. Each one takes '
      'ten minutes to learn and works for years.',
  hue: 96,
  bands: _bandBC,
  pages: [
    PpPage(
      id: 'beh_calm_corner',
      title: 'A calm-down corner',
      format: 'ACTIVITY',
      bands: _bandBC,
      blocks: [
        PpVideoSlot(
          title: 'Setting one up, in a small flat',
          subtitle: 'It needs a corner, not a room. Shown in a real house.',
          minutes: '3 MIN',
          slotId: 'behaviour/calm_corner',
        ),
        PpIntro('A chosen spot with two or three soft things in it, that he can '
            'go to when everything is too much. It is a reset, and it is the '
            'opposite of being sent away.'),
        PpSteps([
          PpStep('Pick it together, when he is calm',
              'Behind the sofa, a corner of the bedroom, under the dining '
              'table. His choice matters more than the spot.'),
          PpStep('Put two or three things in it',
              'A cushion, a soft toy, a book. Not a toy box. Too much to do '
              'and it stops being calm.'),
          PpStep('Name it, and let him name it',
              'The cosy corner, the quiet place, whatever he calls it.'),
          PpStep('Practise going there when nothing is wrong',
              'This is the step everyone skips and the one that makes it work.'),
          PpStep('Go with him the first several times',
              'Sending him alone makes it a punishment. Going together makes '
              'it a place.'),
        ], heading: 'How to set it up'),
        PpCards([
          PpCard('Never as a punishment',
              'The moment it is where he gets sent, it stops being somewhere '
              'he chooses.'),
          PpCard('Never with a door that closes', 'A pause, not a removal.'),
          PpCard('He can refuse it',
              'Being made to calm down is not calming down.'),
        ], heading: 'The lines that keep it working', hue: 96),
        PpWhenLine('Two years and up.'),
      ],
    ),
    PpPage(
      id: 'beh_balloon_breathing',
      title: 'Balloon breathing',
      format: 'ACTIVITY',
      bands: _bandBC,
      blocks: [
        PpIntro('One hand on the belly, breathe in until it fills like a '
            'balloon, then let it out slowly. The only technique on this page '
            'that works on the adult too.'),
        PpSteps([
          PpStep('Hands on the belly, both of you',
              'Seeing it move is what makes it real to a small child.'),
          PpStep('In through the nose, slowly, filling the balloon',
              'Count to three out loud, not fast.'),
          PpStep('Out through the mouth, longer than in',
              'The long out-breath is the part that does the work. Count to '
              'five.'),
          PpStep('Three times, then stop',
              'More than that and it becomes a task he is failing at.'),
          PpStep('Learn it on ordinary days',
              'Nobody learns a breathing technique mid-tantrum. Practise it '
              'in the bath.'),
        ], heading: 'How to do it'),
        PpWhenLine('Two and a half years and up.'),
        PpLink('Why lending your calm works',
            pageId: 'beh_anger',
            blurb: 'The idea underneath all six of these.'),
      ],
    ),
    PpPage(
      id: 'beh_name_the_feeling',
      title: 'Naming the feeling',
      format: 'ACTIVITY',
      bands: _bandBC,
      blocks: [
        PpIntro('You say what you see, out loud, without fixing it. It sounds '
            'too simple to be a technique and it is the most useful one here.'),
        PpSteps([
          PpStep('Describe, do not diagnose',
              '"You are angry the tower fell." Not "there is no need to be '
              'upset".'),
          PpStep('Get it wrong out loud',
              '"Are you sad? No? Frustrated?" Being corrected is him learning '
              'the words.'),
          PpStep('Name yours too',
              '"I am frustrated. I am going to take a breath." He learns more '
              'from this than from anything said to him.'),
          PpStep('Stop there',
              'Do not add a lesson. Naming it IS the intervention.'),
        ], heading: 'How to do it'),
        PpCards([
          PpCard('Not a quiz', 'Asking "how do you feel?" mid-storm gets you '
              'nothing. Say what you see instead.'),
          PpCard('Not a way to end it faster',
              'It often makes the crying louder for a minute, because being '
              'understood lets it out. That is it working.'),
        ], heading: 'Two things to expect', hue: 96),
        PpWhenLine('Eighteen months and up.'),
      ],
    ),
    PpPage(
      id: 'beh_calm_jar',
      title: 'A calm jar',
      format: 'ACTIVITY',
      bands: _bandBC,
      blocks: [
        PpIntro('A sealed bottle of water with glitter in it. Shake it, watch '
            'it settle, and breathe while it does. The settling is the point: '
            'it gives a feeling a shape and an ending.'),
        PpSteps([
          PpStep('Make it together',
              'Warm water, a spoon of glitter glue, a pinch of glitter. Seal '
              'the lid properly and then tape it.'),
          PpStep('Watch it settle once, calmly',
              'Say nothing while it does. About a minute.'),
          PpStep('Use it before the storm, not during',
              'Handing a jar to a screaming child is a projectile. Use it '
              'when he is winding up.'),
          PpStep('Let him shake it as hard as he likes',
              'The shaking is part of it.'),
        ], heading: 'How to make and use it'),
        PpWhenLine('Two and a half years and up.'),
      ],
    ),
    PpPage(
      id: 'beh_connection_games',
      title: 'Filling the tank',
      format: 'ACTIVITY',
      bands: _bandBC,
      blocks: [
        PpVideoSlot(
          title: 'Ten minutes that change the evening',
          subtitle: 'Child-led play, with a parent who does not take over.',
          minutes: '4 MIN',
          slotId: 'behaviour/connection_play',
        ),
        PpIntro('Ten minutes of play he leads, with your phone in another room. '
            'A surprising amount of difficult behaviour is a bid for you that '
            'has not worked yet, and this is the cheapest way to answer it.'),
        PpSteps([
          PpStep('Set a time and say it',
              '"Ten minutes, and you choose what we do."'),
          PpStep('Let him lead completely',
              'No suggestions, no improvements, no turning it into learning.'),
          PpStep('Narrate rather than direct',
              '"You are putting the red one on top." Commentary, not '
              'instruction.'),
          PpStep('Rough-and-tumble counts',
              'For many children it counts more. Wrestling, chasing, being '
              'thrown on the bed.'),
          PpStep('Do it before the hard part of the day',
              'Before dinner beats after the meltdown.'),
        ], heading: 'How to do it'),
        PpCards([
          PpCard('Ten real minutes beats an hour of half-attention',
              'He can tell the difference immediately.'),
          PpCard('Not a reward',
              'It does not get withdrawn for bad behaviour. That is exactly '
              'when it is needed most.'),
        ], heading: 'What makes it work', hue: 96),
        PpWhenLine('Any age, from about six months.'),
      ],
    ),
    PpPage(
      id: 'beh_feelings_checkin',
      title: 'A daily feelings check-in',
      format: 'ACTIVITY',
      bands: ['preschool'],
      blocks: [
        PpIntro('One question at the same time every day, usually at bedtime. '
            'Not a conversation about feelings, just a habit of having words '
            'for them.'),
        PpSteps([
          PpStep('Pick a fixed moment',
              'After the story, lights off. Predictable matters more than '
              'when.'),
          PpStep('Ask something small and answerable',
              '"What was the best bit and the worst bit?" beats "how do you '
              'feel?"'),
          PpStep('Answer it yourself first',
              'Including a real worst bit. It teaches him that adults have '
              'them too.'),
          PpStep('Accept nothing as an answer',
              '"Do not want to" is fine. Asking again tomorrow is the habit.'),
        ], heading: 'How to do it'),
        PpWhenLine('Three years and up.'),
        PpLink('Big feelings at this age',
            pageId: 'beh_big_feelings',
            blurb: 'What is changing at three, and what helps.'),
      ],
    ),
  ],
);
