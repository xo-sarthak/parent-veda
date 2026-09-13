// =============================================================================
//  Behaviour: the doors that were specified and never built
// -----------------------------------------------------------------------------
//  ⚠️ THE SECTION SHIPPED AT ABOUT A THIRD OF ITS SPEC, AND ITS OWN HEADER SAID
//  OTHERWISE. `pp_behaviour_content.dart` opens with "Nine areas plus three
//  tools"; the section registered four areas and no tools. Nothing failed and
//  nothing looked broken: four good areas render as a complete section, and
//  the file comment read as a description of what was there.
//
//  Feedback: "Redo, has not come out as per the prompt."
//
//  Band A (0–12 months) was in fact built in full, six pages matching A1 to A6
//  exactly, so it is untouched. What was missing is the middle of the spec:
//  the stubborn/ziddi door the prompt calls "the dominant India door", the
//  discipline-without-hitting door, and Band C entirely.
//
//  ⚠️ THESE LIVE IN THEIR OWN FILE ON PURPOSE. `pp_behaviour_content.dart` is
//  already 1,100 lines and Band A inside it is correct and reviewed; splicing
//  three new doors into the middle of it would put a large diff through content
//  nobody asked to change. Same section, same registration, one import.
//
//  ⚠️ EVERY PAGE FOLLOWS THE SPEC'S FIXED SKELETON, in this order:
//    why they do it  ->  PpIntro / PpArticle
//    in the moment   ->  PpSteps
//    what NOT to do  ->  PpCards
//    words to use    ->  PpScript
//    when to worry   ->  PpCallout(kind: doctor)
//    age + related   ->  PpWhenLine + PpLink
//  A page missing the middle of that is the failure the skeleton guards
//  against: a warm essay about why toddlers hit, read by a parent whose child
//  is hitting right now, that never says what to do with the hand.
//
//  ⚠️ REFRAME, NEVER PATHOLOGISE, AND NEVER PREACH. "Ziddi" is independence
//  arriving, not defiance to be broken. The discipline door says plainly that
//  hitting does not work and says it once, kindly, aware that it is a norm in
//  many Indian homes: a page that lectures gets closed, and a closed page
//  changes nothing.
//
//  English only for now, plain `String`, per the standing instruction.
// =============================================================================

import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// Band B is toddler_1 + toddler_2; Band C is preschool. Matches
// `kPpChildBands`, so behaviour's boundaries stay in step with every other
// parenting section.
//
// ⚠️ THERE IS NO `_bandB` CONSTANT, DELIBERATELY. It was written and then
// removed unused: every page here that belongs to Band B also reads fine to a
// preschool parent, so they all take `_bandBC`. A constant that exists because
// the spec has a name for it, rather than because a page needs it, is the
// start of a taxonomy nobody is maintaining.
const List<String> _bandBC = ['toddler_1', 'toddler_2', 'preschool'];
const List<String> _bandC = ['preschool'];

// =============================================================================
//  B1: the stubborn / ziddi door
// =============================================================================

const PpArea kBehZiddi = PpArea(
  id: 'ziddi',
  // ⚠️ NOT `moodArc` — Band A's crying area already owns it in this section,
  // and `pp_area_marks_test.dart` fails on a repeat. The rule is worth keeping
  // rather than working around: two areas sharing a drawn mark makes the
  // landing grid unscannable, which is the one job the marks have.
  //
  // `improveMark` because this door is about a will being guided rather than
  // broken, and it is the mark this app already uses for "getting better at
  // something" elsewhere. Meaning picks the mark, per hub_intent_art.dart.
  mark: IntentMark.improveMark,
  title: 'The ziddi child',
  blurb: 'Stubbornness, and what to do with a will that has arrived before the '
      'words have.',
  hue: 344,
  bands: _bandBC,
  pages: [
    PpPage(
      id: 'beh_ziddi',
      title: 'How to handle a ziddi bachcha',
      format: 'ARTICLE',
      bands: _bandBC,
      blocks: [
        PpVideoSlot(
          title: 'Ziddi is not naughty',
          subtitle: 'A child psychologist on what stubbornness at two actually '
              'is, and why breaking it is the wrong goal.',
          minutes: '6 MIN',
          slotId: 'behaviour/ziddi_reframe',
        ),
        PpIntro('Somewhere around eighteen months a child works out that he is '
            'a separate person with his own opinions. Ziddi is that discovery '
            'arriving before he has the words, the patience or the sense of '
            'time to express it any other way.'),
        PpArticle(heading: 'Why it is happening', [
          'A two-year-old wants things with an intensity adults have mostly '
              'forgotten. He also has almost no ability to wait, no way to '
              'argue his case, and no concept of "later". When those three '
              'meet a no, what comes out is what we call ziddi.',
          'It is worth being honest about the reframe, because it is not a '
              'trick: the trait underneath, knowing his own mind and holding '
              'on to it, is one you will spend his teenage years being '
              'grateful for. The job now is to guide it, not to win against it.',
        ]),
        PpSteps([
          PpStep('Get to his level and slow down',
              'Standing over a child who is already overwhelmed adds to it. '
              'Crouch, lower your voice rather than raising it.'),
          PpStep('Name what he wants, out loud',
              '"You really want the phone." Being understood removes half the '
              'fight, and costs you nothing.'),
          PpStep('Offer two choices you are happy with',
              'Red cup or blue cup. Walk to the gate or be carried. He gets a '
              'say; you keep the boundary.'),
          PpStep('Hold the limit without arguing it',
              'One clear sentence, repeated calmly. Explaining a fourth time '
              'is not persuading him, it is showing him the answer is '
              'negotiable.'),
          PpStep('Reconnect once it passes',
              'No lecture afterwards. He will not learn anything from a '
              'summary of what just happened.'),
        ], heading: 'In the moment'),
        PpCards([
          PpCard('Do not make it a contest',
              'Once it is about who wins, you have to win every time, and he '
              'has more stamina than you do.'),
          PpCard('Do not give in after saying no',
              'Not because it spoils him, but because it teaches that the '
              'answer changes if he pushes for long enough.'),
          PpCard('Do not label him',
              '"Ziddi bachcha" said often enough stops being a description and '
              'becomes an identity he lives up to.'),
          PpCard('Do not hit',
              'It ends the moment and teaches that the biggest person decides. '
              'There is a whole page on this in this section.'),
        ], heading: 'What not to do', hue: 344),
        PpScript([
          PpScriptLine(
            say: 'You can have the red cup or the blue cup.',
            notThis: 'Take this one and stop it.',
            why: 'A choice inside your boundary gives his will somewhere to go.',
          ),
          PpScriptLine(
            say: 'I know you want it. The answer is still no, and I am here.',
            notThis: 'I said NO. How many times?',
            why: 'Acknowledging the want is not the same as granting it, and it '
                'is what stops the escalation.',
          ),
          PpScriptLine(
            say: 'You are allowed to be cross with me.',
            notThis: 'Do not look at me like that.',
            why: 'His anger at you is safe. Being told it is not is what teaches '
                'a child to hide feelings rather than manage them.',
          ),
        ], heading: 'Words to use'),
        PpCallout(
          'Worth mentioning to your paediatrician: aggression that regularly '
          'injures someone, no words at all by around two, or a rigidity so '
          'extreme that ordinary daily changes cause distress every time. Not '
          'because stubbornness is a problem, but because these are separate '
          'things worth a proper look.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('Peaks between about eighteen months and three years, and '
            'eases as language arrives.'),
        PpIndiaNote('In a joint family you are often managing an audience as '
            'well as a child, and "yeh toh bahut ziddi hai" gets said in front '
            'of him. You are allowed to handle it your way and explain later, '
            'and elders are usually more persuaded by a calm child a month on '
            'than by an argument today.'),
        PpLink('What to say when he digs in',
            surfaceId: 'pp_scripts',
            blurb: 'The exact words for the shoes, the park and the phone.'),
      ],
    ),
    PpPage(
      id: 'beh_choices',
      title: 'Choices within limits',
      format: 'STEP-LIST',
      bands: _bandBC,
      blocks: [
        PpIntro('The single most useful technique at this age, and the one that '
            'sounds too simple to work. Offer two options you are equally happy '
            'with, and let him pick.'),
        PpSteps([
          PpStep('Decide the boundary first',
              'Shoes are going on. That part is not a choice, and pretending it '
              'is will cost you.'),
          PpStep('Find two acceptable routes to it',
              'Red shoes or blue shoes. Sitting on the step or on my lap.'),
          PpStep('Offer exactly two',
              'Three is a decision; five is a shop. Two is a choice a '
              'two-year-old can actually make.'),
          PpStep('Accept either answer immediately',
              'If you flinch at one of them, it was not really an option and he '
              'will notice.'),
          PpStep('If he refuses both, choose for him, calmly',
              '"You are not choosing, so I will choose. Blue today." Then move '
              'on without commentary.'),
        ], heading: 'How to do it'),
        PpCards([
          PpCard('Not a bribe',
              '"Shoes on and you can have a biscuit" is a different technique '
              'with different costs. This one offers control, not payment.'),
          PpCard('Not a threat in disguise',
              '"Walk or I leave you here" is not two acceptable options.'),
          PpCard('Not for everything',
              'Used all day it becomes noise. Save it for the three or four '
              'moments that reliably go wrong.'),
        ], heading: 'What it is not', hue: 344),
        PpWhenLine('Works from about eighteen months, and keeps working for '
            'years with bigger choices.'),
        PpLink('The whole ziddi picture',
            pageId: 'beh_ziddi',
            blurb: 'Why the will arrives before the words.'),
      ],
    ),
    PpPage(
      id: 'beh_strict_or_soft',
      title: 'Am I too strict, or too soft?',
      format: 'ARTICLE',
      bands: _bandBC,
      blocks: [
        PpIntro('Almost every parent asks this, usually at midnight, usually '
            'after a day that went badly. The honest answer is that the '
            'question has the wrong shape.'),
        PpArticle(heading: 'It is not a dial between two extremes', [
          'Warmth and firmness are not opposite ends of one slider: they are '
              'two separate things, and the children who do best have parents '
              'high on both. Warm and firm is not a compromise between strict '
              'and soft; it is a third thing.',
          'What matters far more than where you sit is whether you are '
              'PREDICTABLE. A child can work with a firm rule and can work with '
              'a relaxed one. What he cannot work with is a rule that depends '
              'on how tired you are, because then testing it every single time '
              'is the only rational thing to do.',
          'And you will be inconsistent, because you are a person. The repair '
              'matters more than the slip: "I shouted earlier. That was not '
              'about you" teaches more than never shouting would have.',
        ]),
        PpCards([
          PpCard('Too strict usually looks like',
              'A child who is careful around you, who lies early to avoid '
              'trouble, and who behaves differently when you leave the room.'),
          PpCard('Too soft usually looks like',
              'A child who escalates because escalation has worked, and a '
              'parent who feels held hostage in their own house.'),
          PpCard('Both usually come from the same place',
              'Not wanting him to be unhappy. Firmness and warmth are both ways '
              'of caring; they just feel different in the moment.'),
        ], heading: 'What each one looks like', hue: 344),
        PpWhenLine('True at every age in this section, and beyond it.'),
        PpIndiaNote('You may be the strict one in a house where somebody else '
            'is the soft one, or the reverse. Children are extremely good at '
            'learning who says yes, and it is not a disaster: what helps is '
            'that the two of you disagree away from him rather than in front '
            'of him.'),
        PpLink('When elders discipline differently',
            pageId: 'beh_elders',
            blurb: 'The version of this that is about your family, not you.'),
      ],
    ),
  ],
);

// =============================================================================
//  B5: discipline without hitting
// =============================================================================

const PpArea kBehDiscipline = PpArea(
  id: 'discipline',
  mark: IntentMark.compassMark,
  title: 'Guiding without hitting',
  blurb: 'What works instead, why it works, and how to hold your line when the '
      'house disagrees.',
  hue: 268,
  bands: _bandBC,
  pages: [
    PpPage(
      id: 'beh_no_hitting',
      title: 'Why hitting does not do what it looks like it does',
      format: 'ARTICLE',
      bands: _bandBC,
      blocks: [
        PpVideoSlot(
          title: 'Calm discipline, shown',
          subtitle: 'What holding a limit looks like when nobody raises a hand '
              'or a voice.',
          minutes: '7 MIN',
          slotId: 'behaviour/calm_discipline',
        ),
        PpIntro('This is said once, plainly, and then this section moves on to '
            'what to do instead. Most Indian parents were smacked and are fine, '
            'and that is exactly why the argument has to be about what works '
            'rather than about who is a good parent.'),
        PpArticle(heading: 'What actually happens', [
          'A smack stops the behaviour immediately, which is why it feels '
              'effective. What it does not do is teach the child what to do '
              'instead, so the same thing happens again, and the next smack '
              'has to be a little harder to have the same effect.',
          'Below about three, a child genuinely does not connect the smack with '
              'what he did a moment ago. What he learns is that the person he '
              'depends on sometimes hurts him, and that big people solve '
              'problems with their hands. The second lesson tends to show up at '
              'the playgroup within a week.',
          'The research is unusually consistent here, across cultures including '
              'ours: physical punishment is not more effective than calmer '
              'methods at changing behaviour, and it carries costs they do not.',
        ]),
        PpSteps([
          PpStep('Connect before you correct',
              'Get down, get his attention, make sure he is actually with you.'),
          PpStep('Say the limit in one short sentence',
              '"I will not let you hit." Not a paragraph, not a question.'),
          PpStep('Give the behaviour you DO want',
              '"Hands are for holding. Show me gentle." A child cannot obey '
              '"stop" if he does not know what to start.'),
          PpStep('Let the natural consequence happen where it is safe',
              'He throws the toy, the toy goes away for now. Related, immediate, '
              'and not a punishment you invented.'),
          PpStep('Be the same tomorrow',
              'Consistency is doing more work here than severity ever could.'),
        ], heading: 'What to do instead'),
        PpCards([
          PpCard('Not a lecture',
              'A two-year-old has stopped listening by your second sentence.'),
          PpCard('Not a delayed punishment',
              '"Wait till your father comes home" means nothing at this age '
              'except several hours of fear.'),
          PpCard('Not shaming in front of people',
              'It works fastest and costs the most. He learns to hide, not to '
              'stop.'),
        ], heading: 'What not to do', hue: 268),
        PpCallout(
          'If you have hit him and feel awful about it, that feeling is worth '
          'listening to and is not a verdict on you. Repair works: "I was angry '
          'and I hit you. That was not okay, and I am sorry." Children forgive '
          'far more readily than we expect. If it is happening often, or you '
          'are frightened of your own temper, that is worth saying out loud to '
          'a doctor or a counsellor.',
          kind: PpCalloutKind.safety,
          title: 'If it has already happened',
        ),
        PpWhenLine('Relevant from about one, and most useful between two and '
            'six.'),
        // The mechanism, once: why a small child lashes out lives on the
        // anger page; this page is the parent's hand, not the child's.
        PpLink('Why a child lashes out, and why a smack teaches the wrong thing',
            pageId: 'beh_anger',
            blurb: 'The one explanation the three hitting pages share.'),
        PpLink('What to say instead, situation by situation',
            surfaceId: 'pp_scripts',
            blurb: 'The sentences, for the moments this actually comes up.'),
      ],
    ),
    PpPage(
      id: 'beh_consequences',
      title: 'Redirection, consequences and consistency',
      format: 'STEP-LIST',
      bands: _bandBC,
      blocks: [
        PpIntro('Three everyday tools that do most of the work, none of which '
            'require you to be angry.'),
        PpSteps([
          PpStep('Redirect (under about two)',
              'Move him, or move the object, and offer something he CAN do. At '
              'this age changing the situation beats changing his mind, every '
              'time.'),
          PpStep('Natural consequence (from about two)',
              'He refuses his jumper, he feels cold on the balcony, he asks for '
              'the jumper. You did nothing, and he learned it properly.'),
          PpStep('Logical consequence (from about two and a half)',
              'Related to what happened and delivered without anger: paint on '
              'the wall means the paints go away for today.'),
          PpStep('Consistency, which is the one that matters',
              'A rule enforced four times out of five teaches him to try a '
              'fifth time. This is why fewer rules, held properly, beat many '
              'rules held loosely.'),
        ], heading: 'The three tools'),
        PpCards([
          PpCard('A consequence is not a punishment',
              'The test is whether it teaches something. Taking away a birthday '
              'party for spilled milk teaches only that you are unpredictable.'),
          PpCard('Never withdraw love as a consequence',
              '"I do not like you when you are like this" is the one that '
              'genuinely lasts.'),
          PpCard('Do not stack them',
              'One consequence, delivered calmly. A list of punishments read '
              'out in anger is a mood, not a method.'),
        ], heading: 'Where it goes wrong', hue: 268),
        PpWhenLine('One to six years, with the tools shifting as he does.'),
      ],
    ),
    PpPage(
      id: 'beh_timeouts',
      title: 'Time-outs, and whether they are worth it',
      format: 'SHORT ARTICLE',
      bands: _bandC,
      blocks: [
        PpIntro('Popular, frequently done in a way that does not work, and '
            'genuinely unsuitable before about three.'),
        PpArticle(heading: 'If you use one', [
          'It only makes sense once a child can understand what it is for: '
              'roughly three and up. Below that he experiences being sent away '
              'by the person he was already upset with, and learns nothing '
              'except that.',
          'Keep it short: about a minute per year of age is the usual guide, '
              'and the point is not the duration. It is a pause to let a '
              'nervous system settle, not a sentence to be served.',
          'A calm-down corner he can choose is a better version of the same '
              'idea: same pause, no banishment, and he keeps some agency in it.',
        ]),
        PpCards([
          PpCard('Not in a dark room, ever', 'Fear is not calm.'),
          PpCard('Not with a lock or a closed door',
              'The message becomes abandonment rather than pause.'),
          PpCard('Not without a return',
              'It ends with reconnection, not with him creeping back in.'),
        ], heading: 'Lines not to cross', hue: 268),
        PpWhenLine('Three years and up. Below that, redirect instead.'),
      ],
    ),
    PpPage(
      id: 'beh_elders',
      title: 'When elders discipline differently',
      format: 'ARTICLE',
      bands: _bandBC,
      blocks: [
        PpIntro('Probably the most common behaviour question in an Indian '
            'household, and the one least covered by parenting advice written '
            'elsewhere.'),
        PpArticle(heading: 'The real situation', [
          'Your parents or in-laws raised children successfully, love this one, '
              'and are often doing more of the daily care than anyone admits. '
              'They also smacked, or bribed, or fed with a phone, and it is '
              'genuinely hard to hear that any of it was wrong, because it '
              'sounds like a judgement on them.',
          'So the conversation that works is almost never about evidence. It is '
              'about asking for a favour rather than announcing a policy, and '
              'picking the two things that actually matter to you instead of '
              'the fifteen you would ideally like.',
        ]),
        PpSteps([
          PpStep('Choose your two',
              'Not hitting, and not being called names, are the usual two. Let '
              'the biscuit go.'),
          PpStep('Ask privately, and ask rather than tell',
              '"Can you help me with something I am trying?" lands where "the '
              'doctor says" does not.'),
          PpStep('Give them the alternative',
              'People do not stop doing something because it is wrong; they '
              'stop when they have something else to do instead.'),
          PpStep('Never correct an elder in front of the child',
              'It undermines them, and it teaches him that adults can be '
              'overruled in public.'),
          PpStep('Accept a different house has different rules',
              'Children handle "at dadi house it is different" much better than '
              'they handle their parents fighting about it.'),
        ], heading: 'What tends to work'),
        PpWhenLine('Any age, and it gets easier as they see the results.'),
        PpIndiaNote('If the person doing most of the childcare is a helper or a '
            'nanny rather than family, the same approach applies and the '
            'conversation is usually easier, but it has to actually happen, '
            'and be specific.'),
      ],
    ),
  ],
);

// =============================================================================
//  Band C: three to six
// =============================================================================

const PpArea kBehOlderChild = PpArea(
  id: 'older_child',
  mark: IntentMark.stepsMark,
  title: 'Three to six',
  blurb: 'Bigger feelings, better words, and a child who can now argue back.',
  hue: 232,
  bands: _bandC,
  pages: [
    PpPage(
      id: 'beh_big_feelings',
      title: 'Big feelings, and helping him manage them',
      format: 'ARTICLE',
      bands: _bandC,
      blocks: [
        PpVideoSlot(
          title: 'Naming feelings, with a four-year-old',
          subtitle: 'What co-regulation looks like once a child can talk.',
          minutes: '5 MIN',
          slotId: 'behaviour/big_feelings',
        ),
        PpIntro('Tantrums fade and something harder replaces them: a child with '
            'real feelings, real words, and not much idea what to do with '
            'either.'),
        PpArticle(heading: 'What changes at three', [
          'He can now tell you he is angry, which is progress, and he can also '
              'tell you he hates you, which does not feel like progress. Both '
              'come from the same new ability.',
          'The work at this age is naming rather than stopping. A child who can '
              'say "I am frustrated" has a tool that lasts him the rest of his '
              'life; a child who is only told to calm down has nothing.',
        ]),
        PpSteps([
          PpStep('Name it before you fix it',
              '"You are disappointed we are not going." Getting the feeling '
              'right matters more than getting it solved.'),
          PpStep('Let it be allowed',
              'The feeling is never the problem. What he does with it might be.'),
          PpStep('Separate feeling from action',
              '"You can be furious. You cannot throw that."'),
          PpStep('Teach one physical thing',
              'Balloon breathing, squeezing hands, going to the calm corner. '
              'One, practised when he is calm, not invented mid-storm.'),
          PpStep('Come back to it later, briefly',
              'Ten seconds after dinner, not a debrief.'),
        ], heading: 'In the moment'),
        PpCards([
          PpCard('Do not argue with the feeling',
              '"There is nothing to be sad about" teaches him his own reading '
              'of himself is wrong.'),
          PpCard('Do not rush to fix it',
              'Most feelings only need company. Solving them early teaches him '
              'that discomfort is an emergency.'),
          PpCard('Do not match his volume',
              'He borrows whichever nervous system is louder.'),
        ], heading: 'What not to do', hue: 232),
        PpScript([
          PpScriptLine(
            say: 'You are really angry. I am going to sit here with you.',
            notThis: 'Stop crying, it is not a big deal.',
            why: 'Company is the intervention. Minimising ends the conversation.',
          ),
          PpScriptLine(
            say: 'I still love you, even when you are this cross with me.',
            notThis: 'Do not talk to me like that.',
            why: 'Separates the relationship from the moment, which is what '
                'makes it safe for him to calm down.',
          ),
        ], heading: 'Words to use'),
        PpCallout(
          'Worth asking about: rages that are extreme and frequent well past '
          'four, aggression that injures, or a child who seems flat and '
          'joyless rather than stormy. Different things, all worth a proper '
          'look rather than a search at midnight.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('Three to six, and the naming habit lasts far longer.'),
      ],
    ),
    PpPage(
      id: 'beh_cooperation',
      title: 'Listening and cooperation',
      // ⚠️ MERGED. "He does not listen to anything I say" (pp_behaviour_more)
      // and this page said the same thing; the brief: "Keep ONE listening
      // page. Reference from both areas, no second copy." That one is the
      // canonical (it has the why, and the joint-family note); this card
      // opens it. The badge follows the content it opens. Copy kept below.
      // format: 'STEP-LIST',
      format: 'ARTICLE',
      bands: _bandC,
      toolSurfaceId: 'pp_page/parenting_behaviour/beh_not_listening',
      blocks: [],
    ),
    /* kept for revert: the second listening page
    PpPage(
      id: 'beh_cooperation_copy',
      title: 'Listening and cooperation',
      format: 'STEP-LIST',
      bands: _bandC,
      blocks: [
        PpIntro('"He never listens" is almost always a description of how the '
            'asking is happening, not of the child.'),
        PpSteps([
          PpStep('Get his attention first',
              'Across the room over a television is not asking, it is '
              'broadcasting. Go to him.'),
          PpStep('One instruction at a time',
              '"Shoes on" beats "get ready, we are late, where is your bag".'),
          PpStep('Say what to do, not what to stop',
              '"Walk" lands better than "do not run", because it names the '
              'action.'),
          PpStep('Give a moment to comply',
              'Most children need three or four seconds to switch. Repeating at '
              'second two teaches him that the first ask never counts.'),
          PpStep('Follow through the first time',
              'If it matters enough to ask, it matters enough to see through.'),
        ], heading: 'What works'),
        PpCards([
          PpCard('Do not count to three',
              'It teaches that nothing happens until three.'),
          PpCard('Do not ask when it is not a choice',
              '"Shall we go now?" invites a no you are not going to accept.'),
          PpCard('Do not save it all up',
              'Twelve corrections before breakfast means none of them register.'),
        ], heading: 'What quietly backfires', hue: 232),
        PpWhenLine('Three to six, and useful well beyond.'),
      ],
    ),
    */
    PpPage(
      id: 'beh_friendships',
      title: 'Early friendships and falling out',
      format: 'ARTICLE',
      bands: _bandC,
      blocks: [
        PpIntro('The first real friendships arrive around three, and so do the '
            'first betrayals, exclusions and "she is not my friend any more".'),
        PpArticle(heading: 'What is normal here', [
          'Friendships at this age are intense, short and largely about who is '
              'physically nearby. A best friend can change twice in a week and '
              'neither child will remember by Sunday.',
          'Exclusion, "you cannot play", is extremely common and is usually '
              'about controlling a game rather than about cruelty. It still '
              'needs naming, because this is the age where the habit forms.',
        ]),
        PpSteps([
          PpStep('Coach, do not referee',
              'Ask what happened, ask what he could try, resist supplying the '
              'answer.'),
          PpStep('Give him the sentence',
              '"I do not like that. Stop." Practised at home, it works at '
              'school.'),
          PpStep('Do not solve it with the other parent',
              'Unless somebody is being hurt, this is his to navigate.'),
        ], heading: 'How to help'),
        PpCallout(
          'Worth a conversation with his teacher if he is consistently alone '
          'and unhappy about it, if he is being hurt, or if he seems to have no '
          'interest in other children at all rather than difficulty with them.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('Three to six.'),
      ],
    ),
    PpPage(
      id: 'beh_older_lying',
      title: 'Lying, fairness and telling on people',
      // ⚠️ THE ONE LYING PAGE. "She told me a lie" (pp_behaviour_content.dart,
      // kept in a comment) said the same thing for the same age; the brief:
      // "Keep one, delete the copy." Its film, its script and its doctor
      // line moved here so the merge lost nothing worth keeping.
      format: 'ARTICLE',
      bands: _bandC,
      blocks: [
        PpVideoSlot(
          title: 'Why small children lie',
          subtitle: 'A child psychologist on why it is a milestone rather '
              'than a character problem, and what to do at the moment it '
              'happens.',
          minutes: '5 MIN',
          slotId: 'behaviour/lying',
        ),
        PpIntro('Lying at four is not a moral failure. It is a cognitive '
            'achievement he is trying out, and how you respond decides whether '
            'it becomes a habit.'),
        PpArticle(heading: 'Why it starts', [
          'To lie he has to understand that you do not know what he knows. That '
              'is a genuine leap in thinking, and it usually arrives around '
              'three or four.',
          'Most early lies are wishful rather than deceptive: he did not break '
              'it because he wishes he had not. Some are simply to avoid a '
              'reaction he is frightened of, which is worth noticing, because '
              'it tells you something about how mistakes are met in the house.',
        ]),
        PpSteps([
          PpStep('Do not set the trap',
              'You saw the broken cup. Do not ask who broke it. Say what you '
              'saw and ask what happened.'),
          PpStep('Make the truth cheaper than the lie',
              'Owning it should reliably go better than hiding it. Every time.'),
          PpStep('Name it without the label',
              '"That is not what happened, and I am not cross" beats "liar".'),
          PpStep('Praise the telling, not the tidiness',
              '"That was hard to say. Thank you for saying it."'),
        ], heading: 'What to do'),
        PpCards([
          PpCard('Do not call him a liar',
              'Labels stick at this age, and a child who is one lives up to it.'),
          PpCard('Do not punish the confession',
              'It is the fastest way to guarantee the next lie.'),
        ], heading: 'What not to do', hue: 232),
        PpScript([
          PpScriptLine(
            say: 'I know that was hard to say. Thank you for telling me.',
            notThis: 'Do not lie to me. I always find out.',
            why: 'The first makes honesty worth it. The second makes it a '
                'contest he will try harder to win.',
          ),
        ], heading: 'Words to use'),
        PpCallout(
          'Worth raising with your paediatrician if lying is constant, '
          'elaborate and unbothered by being found out, or if it comes together '
          'with taking things and hurting animals or other children.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask',
        ),
        PpWhenLine('Three to six.'),
      ],
    ),
  ],
);
