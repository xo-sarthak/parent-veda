// =============================================================================
//  Early Learning - the section's content
// -----------------------------------------------------------------------------
//  Built from pp_specs/07-early-learning.md, against the mechanism in
//  docs/PP-SECTION-PATTERN.md. The review said "Don't like what we have", and
//  what it did not like was emptiness: the shell existed and had nothing in it.
//  So this file is deliberately the largest section in the parenting stage.
//  Twelve areas, and the story library is real pages with real stories in them
//  rather than a list of titles that open nothing.
//
//  THIS FILE IS DATA. No layout, no Scaffold, no TextStyle. `PpSectionScreen`
//  renders the landing and `PpContentPage` renders every page.
//
//  THREE GUARDRAILS, AND EACH ONE IS LOAD-BEARING RATHER THAN DECORATIVE.
//
//  1. SECULAR VALUES, NOT SCRIPTURE. The demand data is decisive: moral stories
//     around 27,100 searches a month, scripture around 480. So Panchatantra,
//     Jataka, Birbal and Tenali Rama are told here as what they have always been
//     in most Indian homes: clever stories about kindness, honesty and thinking
//     before you act. No verse, no deity, no instruction to believe anything. A
//     Jataka tale about a monkey who saves his troop teaches sacrifice whether
//     or not the family reading it is Buddhist, and framing it as religious
//     teaching would lose most of the families who search for it.
//
//  2. EVERYDAY OBJECTS ONLY. Every activity in Door 1 is doable with a steel
//     katori, a dupatta, dal, bottle caps, old newspaper and a bedsheet. This is
//     the difference between a section a family in a two-room flat uses and one
//     they scroll past. Anything purchasable is a convenience, never a
//     requirement, and it is named as such on the page itself.
//
//  3. NO ACADEMIC DRILLING. This is the one place the section could actively
//     harm a child. India's early-learning market sells worksheets to
//     two-year-olds, and a three-year-old made to write for an hour learns that
//     learning is punishment. So school readiness here means independence,
//     sitting with a group, following two instructions and separating from a
//     parent. Pre-writing means big arm movements and mud, not letters. The
//     anti-drilling line is repeated on every page where a parent might reach
//     for a workbook, because saying it once in an intro is saying it nowhere.
//
//  WHAT THIS SECTION DOES NOT OWN, AND MUST NOT REBUILD.
//  Milestones, speech worries and "is he on track" belong to the Development
//  section. Tantrums, discipline and screen-time battles belong to Behaviour.
//  Both are already built. This file links to them and stops. A second answer to
//  "is my child behind" is worse than no answer, because a worried parent will
//  find the one that frightens her most.
//
//  English only for now, plain `String`, per the standing instruction.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_age_bands.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// =============================================================================
//  THE BANDS
// -----------------------------------------------------------------------------
//  FIVE BANDS, NOT THE SHARED FOUR, and the reason is the split between three
//  and four years. `kPpChildBands` has one 3-to-5 band, which is right for sleep
//  and for behaviour. It is wrong here: a three-year-old is drawing wavy lines
//  and a four-and-a-half-year-old is copying his own name, and one band would
//  have to either show the four-year-old baby content or show the three-year-old
//  writing practice. The second of those is exactly the drilling this section
//  exists to prevent, so the band split is a guardrail, not a preference.
//
//  Inclusive lower, exclusive upper, no gaps, first starts at 0.
// =============================================================================

const PpBandSet kPpEarlyLearningBands = PpBandSet([
  PpBand(
    id: 'baby',
    label: '0 to 12 months',
    fromMonths: 0,
    toMonths: 12,
    blurb: 'Play is how the brain is built. Nothing here is a lesson.',
  ),
  PpBand(
    id: 'one',
    label: '1 to 2 years',
    fromMonths: 12,
    toMonths: 24,
    blurb: 'Moving, sorting, first words, first little habits.',
  ),
  PpBand(
    id: 'two',
    label: '2 to 3 years',
    fromMonths: 24,
    toMonths: 36,
    blurb: 'Pouring, pretending, and the first real stories.',
  ),
  PpBand(
    id: 'three',
    label: '3 to 4 years',
    fromMonths: 36,
    toMonths: 48,
    blurb: 'Lines before letters, counting things small hands can touch.',
  ),
  PpBand(
    id: 'four',
    label: '4 to 6 years',
    fromMonths: 48,
    toMonths: 72,
    blurb: 'A first written name, first sums, getting ready for school.',
  ),
]);

/// Band groups, named once so a retag is one edit rather than forty.
const List<String> _fromOne = ['one', 'two', 'three', 'four'];
const List<String> _fromTwo = ['two', 'three', 'four'];
const List<String> _fromThree = ['three', 'four'];
const List<String> _earlyYears = ['one', 'two', 'three'];

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpEarlyLearningSection = PpSection(
  id: 'parenting_early_learning', // MUST match the hub's bracketId.
  title: 'Early Learning',
  subtitle: 'Play, stories, habits and getting ready for school',
  intro:
      'Small children learn almost everything by playing, helping and hearing '
      'stories. Here is something to do today, right for your child\'s age, '
      'with what is already in your house.',
  bandSet: kPpEarlyLearningBands,
  // ⚠️ THE AGE RULE. "Remove the five band tabs and the band chooser. App
  // knows the age. Open on his band, show only his band, hide the others."
  autoScope: true,
  areas: [
    _today,
    _montessori,
    _storyTime,
    _bedtimeTales,
    _panchatantra,
    _jataka,
    _birbal,
    _tenali,
    _worldTales,
    _rhymes, // [NEW] the collection the section had none of
    _habits,
    _earlySkills,
    _school,
  ],
  tools: [
    // REUSED, NOT REBUILT. `pp_activities` is DevelopmentHomeScreen, the
    // existing activity engine that already reads the child's age. A second
    // activity surface would mean two answers to "what should we do today".
    PpSectionTool(
      label: 'Something to do today',
      blurb: 'The activity picker, already set to your child\'s age. Two '
          'minutes to find one, ten minutes to do it.',
      surfaceId: 'pp_activities',
      icon: Icons.child_care_outlined,
    ),
    PpSectionTool(
      label: 'Where your child is right now',
      blurb: 'Milestones, speech and what usually comes next. Kept in one '
          'place so nothing here has to guess.',
      surfaceId: 'pp_development',
      icon: Icons.timeline_outlined,
    ),
    PpSectionTool(
      label: 'Story books, crayons and activity boxes',
      blurb: 'Only where buying something really helps. Everything in this '
          'door works without any of it.',
      surfaceId: 'pp_recos',
      icon: Icons.shopping_bag_outlined,
    ),
    PpSectionTool(
      label: 'The early learning masterclass',
      blurb: 'A short course on learning through play at home, and what school '
          'readiness really asks of a child.',
      surfaceId: 'pp_courses',
      icon: Icons.school_outlined,
    ),
  ],
);

// =============================================================================
//  DOOR 1 - Something to do today
// -----------------------------------------------------------------------------
//  Thirty six named activities, each one a page with the same four things on it:
//  what happens, what you need, what it builds, and the age it fits. The shape
//  is fixed on purpose. A parent who has opened three of these knows where the
//  materials line is on the fourth, and can decide in four seconds whether she
//  has the things for it.
//
//  BAND TAGS ARE THE WHOLE FEATURE HERE. A parent of a seven-month-old opening
//  this door sees eight activities, all of which she can do today. She never
//  scrolls past threading beads, and she never has to work out whether her baby
//  is old enough. The other bands stay browsable because a parent reading ahead
//  is a good thing, not a risk.
//
//  MATERIALS ARE HOUSEHOLD FIRST, ALWAYS. Where a shop item genuinely helps it
//  is named as optional on the page. Nothing in this door requires a purchase.
// =============================================================================

const PpArea _today = PpArea(
  id: 'today',
  mark: IntentMark.stepsMark,
  title: 'Something to do together today',
  blurb: 'Thirty six things to do together, sorted by age, using what is '
      'already in your kitchen.',
  hue: 42,
  pages: [
    // ---- BAND: 0 to 12 months ----------------------------------------------
    PpPage(
      id: 'act_tummy_reach',
      title: 'Tummy time reach',
      subtitle: 'For 0 to 6 months',
      format: 'ACTIVITY',
      bands: ['baby'],
      blocks: [
        PpIntro('One of the most useful things you can do with a small baby who '
            'is awake and content. Five minutes, a few times a day, is plenty.'),
        PpSteps([
          PpStep('Spread a dupatta or a thin quilt on the floor',
              'The floor is better than a bed. A soft surface makes the work '
              'harder for your baby, and it is less safe.'),
          PpStep('Lay your baby tummy down, arms forward under the chest',
              'Getting the elbows in front of the shoulders is what makes '
              'pushing up possible at all.'),
          PpStep('Put one bright thing just out of reach',
              'A small steel bowl catches the light beautifully and costs nothing.'),
          PpStep('Get down on the floor at eye level and talk',
              'Your face is the best toy in the room. Babies lift their heads '
              'higher for a face than for any object.'),
          PpStep('Stop when your baby fusses, not when the timer says',
              'Two good minutes beat ten miserable ones. Try again after the '
              'next nappy change.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('A firm flat surface', 'A dupatta or a bedsheet on the floor.'),
          PpCard('One bright object',
              'A small steel bowl, a red bangle, a folded orange cloth.'),
          PpCard('Your face', 'The part that does most of the work.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Tummy time builds the neck, shoulder and back muscles that every '
          'later movement sits on top of. Rolling, sitting, crawling and '
          'walking all begin with holding the head up against gravity.',
          'It does something less obvious too. Lying tummy down, your baby '
          'sweeps the eyes side to side to follow whatever caught them. '
          'It is the same eye movement that will one day follow a line of print.',
        ], heading: 'What it builds'),
        PpWhenLine('From the first weeks, whenever your baby is awake and not '
            'just fed. A few short goes a day work better than one long one.'),
        PpIndiaNote('If baby massage is part of your day, tummy time fits neatly '
            'right after it. Your baby is already undressed, warm and on the '
            'floor, and loose and comfortable after the oil massage.'),
        PpVideoSlot(
          title: 'How to position a baby for tummy time',
          subtitle: 'Where the arms go, and the rolled-cloth trick for a baby '
              'who hates it.',
          minutes: '4 MIN',
          slotId: 'learning/act/tummy_reach',
        ),
      ],
    ),
    PpPage(
      id: 'act_contrast_cards',
      title: 'Black and white card gazing',
      subtitle: 'For 0 to 3 months',
      format: 'ACTIVITY',
      bands: ['baby'],
      blocks: [
        PpIntro('Newborns see strong edges long before soft colours. Black on '
            'white is the first thing your baby can properly look at.'),
        PpSteps([
          PpStep('Draw thick black shapes on white paper',
              'Stripes, big spots, a chessboard square. A marker on the back of '
              'an old greeting card is just as good as a bought set.'),
          PpStep('Hold it about a hand-span from your baby\'s face',
              'Roughly 25cm. Any further and it becomes a blur.'),
          PpStep('Wait until the eyes lock on to it',
              'This can take several seconds. Keep it still while your baby is '
              'still finding it.'),
          PpStep('Move it slowly to one side, then the other',
              'Slow enough for the eyes to follow. If your baby loses it, stop '
              'and start again from the middle.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Paper and a black marker', 'Or the back of an old carton.'),
          PpCard('Nothing else', 'Bought contrast card sets do the same job at '
              'a price. Yours will be fine.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Newborn vision is blurry and low in contrast, so a pastel toy is '
          'mostly invisible. A hard black edge on white is the first thing a '
          'newborn\'s eyes can really use. Looking at it is how the seeing part '
          'of the brain wires itself up.',
          'Tracking a slow-moving object left and right is the beginning of eye '
          'control. It arrives on its own, but it arrives sooner in a baby who '
          'is given something worth following.',
        ], heading: 'What it builds'),
        PpWhenLine('From birth to about three months. After that colour vision '
            'has come in, and bright colours are more interesting.'),
      ],
    ),
    PpPage(
      id: 'act_peekaboo',
      title: 'Peekaboo',
      subtitle: 'For 4 to 12 months',
      format: 'ACTIVITY',
      bands: ['baby'],
      blocks: [
        PpIntro('The oldest baby game in the world, and one of the most useful. '
            'It teaches your baby that things which disappear come back.'),
        PpSteps([
          PpStep('Cover your face with your hands or the end of your dupatta'),
          PpStep('Wait one beat longer than feels natural',
              'The pause is where the excitement builds. Rushing it makes the '
              'game less funny, not more.'),
          PpStep('Drop the cloth and say the word',
              'Peekaboo, or a-boo, or whatever your family says. Use the same '
              'word every time.'),
          PpStep('Let your baby do it back to you',
              'Around nine or ten months, your baby will start pulling the '
              'cloth off your face. Act surprised every time.'),
          PpStep('Hide small things too',
              'Put a spoon under a cloth in front of your baby and wait for a '
              'small hand to lift it. Same lesson, different hands.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Your hands', 'That is the whole list.'),
          PpCard('Or a dupatta', 'A thin one your baby can half see through is '
              'a gentler start for a young baby.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'This is object permanence: knowing a thing still exists when you '
          'cannot see it. It is one of the biggest ideas a baby ever has, and '
          'it arrives somewhere between eight and twelve months.',
          'It helps in everyday life too. A baby who knows things come back '
          'finds it easier when you leave the room, because your going no '
          'longer feels like your ending. Peekaboo is separation practice '
          'dressed up as a joke.',
        ], heading: 'What it builds'),
        PpWhenLine('From about four months, when the first smiles at it come, '
            'right through the first year. Babies play it for months.'),
      ],
    ),
    PpPage(
      id: 'act_narrate',
      title: 'Naming things as you carry your baby',
      subtitle: 'For 0 to 12 months',
      format: 'ACTIVITY',
      bands: ['baby'],
      blocks: [
        PpIntro('The cheapest and most powerful language activity there is. You '
            'walk around your own house and say what you touch.'),
        PpSteps([
          PpStep('Carry your baby on your hip and walk slowly around a room'),
          PpStep('Touch a thing, then name it',
              'This is the fan. It is going round and round. This water is '
              'cold, feel it.'),
          PpStep('Use both languages, freely',
              'Say the word in your home language and in English. A baby hearing two languages sorts them out '
              'perfectly well and ends up with both.'),
          PpStep('Leave gaps',
              'Stop talking for a few seconds. Your baby may make a sound. '
              'Answer it as though it meant something, because it did.'),
          PpStep('Do it while you work',
              "Chopping vegetables, folding clothes, hanging washing. It costs no "
              "extra time at all."),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Nothing', 'Your house and your voice.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'The number of words babies hear in their first three years strongly '
          'predicts their language later. Not flash cards, not videos. '
          'Ordinary talk from a person who is right there with them.',
          'Naming while touching works better than naming alone. The word '
          'arrives attached to a real object your baby can feel and see at the '
          'same moment. That is how the word sticks.',
          'The gaps matter as much as the words. Pausing, then answering the '
          'babble, teaches your baby that talking means taking turns. That is '
          'the shape of every conversation to come.',
        ], heading: 'What it builds'),
        PpWhenLine('From birth. It never stops being worth doing. It just turns '
            'into ordinary conversation.'),
        PpIndiaNote('In a joint family this happens naturally, all day long. '
            'A grandmother naming things in one language and you in another will not '
            'confuse your baby. It means two vocabularies for the price of one.'),
      ],
    ),
    PpPage(
      id: 'act_rattle_katori',
      title: 'Shake it and hear it',
      subtitle: 'For 4 to 9 months',
      format: 'ACTIVITY',
      bands: ['baby'],
      blocks: [
        PpIntro('Your baby\'s very first experiment. A hand moves, a sound '
            'happens, and your baby works out who caused it.'),
        PpSteps([
          PpStep('Sit your baby supported, or lying on the back'),
          PpStep('Put a light rattle or a small steel bowl and spoon in your '
              'baby\'s hand'),
          PpStep('Let your baby wave it and be startled by the noise',
              'The startled face is the moment the connection is being made.'),
          PpStep('Do it again, and again, and again',
              'Repetition is not boredom to a baby. It is how babies check the '
              'rule they just discovered.'),
          PpStep('Swap the object for something with a different sound',
              'A steel glass with two rajma beans inside, lid taped shut. A '
              'paper packet that crackles.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('A small steel bowl and spoon', 'Light enough for a baby to '
              'lift.'),
          PpCard('Or a sealed jar with two beans in it',
              'Tape the lid firmly. Check the tape before every use.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'This is cause and effect: the idea that my own actions change the '
          'world. All later problem solving is built on it. It is also where '
          'the feeling of being able to do things begins.',
          'Grasping, holding on while moving the arm, and letting go on purpose '
          'are three separate skills. This activity practises all three '
          'without either of you noticing.',
        ], heading: 'What it builds'),
        PpWhenLine('From about four months, when your baby can hold an object, '
            'to around nine months, when posting and banging games take over.'),
        PpCallout(
          'Anything you give a baby must be too big to pass through a toilet '
          'roll tube, with nothing that can come loose. Check sealed jars and '
          'taped lids before every use, and take it away if the tape '
          'has lifted.',
          kind: PpCalloutKind.safety,
          title: 'The toilet roll test',
        ),
      ],
    ),
    PpPage(
      id: 'act_mirror',
      title: 'Mirror play',
      subtitle: 'For 5 to 12 months',
      format: 'ACTIVITY',
      bands: ['baby'],
      blocks: [
        PpIntro('Babies don\'t know the baby in the mirror is them. That is '
            'what makes the mirror such good company.'),
        PpSteps([
          PpStep('Hold your baby in front of a mirror, or prop one safely at '
              'floor level'),
          PpStep('Point at the reflection and say your baby\'s name',
              'Look, baby. And that is Mummy. Use your baby\'s own name often.'),
          PpStep('Make faces and let your baby watch you both',
              'Stick your tongue out, open your mouth wide, smile slowly.'),
          PpStep('Touch your baby\'s nose, then the nose in the mirror',
              'Name the parts as you go. Nose, ears, eyes, mouth.'),
          PpStep('Try it during tummy time',
              'A mirror propped against the wall gives your baby a reason to '
              'keep the head up much longer.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Any mirror', 'A wardrobe mirror, a hand mirror you hold, the '
              'back of a steel thali.'),
          PpCard('A safe position', 'Never leave a baby alone with glass. Hold '
              'it, or use a fixed wall mirror.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Somewhere between fifteen and twenty four months, children work out '
          'that the reflection is their own. Long before that, the moving face '
          'is wonderful company. Watching a mouth make shapes feeds straight '
          'into your baby\'s own speech.',
          'Naming body parts at a mirror is the easiest vocabulary there is. '
          'The object is right there, and it belongs to your baby.',
        ], heading: 'What it builds'),
        PpWhenLine('From about five months, once your baby holds the head '
            'steadily, through the whole first year.'),
      ],
    ),
    PpPage(
      id: 'act_texture_basket',
      title: 'The touch basket',
      subtitle: 'For 6 to 12 months',
      format: 'ACTIVITY',
      bands: ['baby'],
      blocks: [
        PpIntro('One basket, five or six things that feel completely different '
            'from each other. Your baby does the rest.'),
        PpSteps([
          PpStep('Find a basket or a wide steel bowl your baby can reach into'),
          PpStep('Put in five or six safe things with very different textures',
              'A wooden spoon, a square of soft cloth, a silicone spatula, a '
              'loofah, a smooth stone too big to swallow, a crumpled paper.'),
          PpStep('Sit your baby down with it and say nothing',
              'This is the hard part. Let your baby choose, mouth, drop and '
              'choose again without being directed.'),
          PpStep('Name things only when your baby looks up at you',
              'That look is a question. Answer it, then go silent again.'),
          PpStep('Change two things in the basket each week',
              'Familiar plus new is more interesting than all new.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('A low basket', 'Low enough to reach into sitting down.'),
          PpCard('Five or six household textures',
              'Nothing smaller than your baby\'s fist. Nothing that sheds bits.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Touch is a whole channel of information. A baby who has handled '
          'rough, smooth, soft and cold builds a richer map of the world than '
          'one who has only handled plastic.',
          'Picking things out of a container and dropping them back in is '
          'serious fine motor work. It leads straight to holding a crayon '
          'four years later.',
          'The silence is on purpose. Unbroken focus on a chosen object grows '
          'into an attention span. An adult voice arriving mid-thought is what '
          'breaks it.',
        ], heading: 'What it builds'),
        PpWhenLine('From about six months, when your baby sits with support, to '
            'the end of the first year.'),
        PpCallout(
          'Everything in the basket will go in your baby\'s mouth. That is how '
          'babies examine things, so there is no need to stop it. It does mean '
          'each item must pass the toilet roll tube test and be washable.',
          kind: PpCalloutKind.safety,
          title: 'It will all be mouthed',
        ),
      ],
    ),
    PpPage(
      id: 'act_roll_ball',
      title: 'Rolling a ball back',
      subtitle: 'For 8 to 12 months',
      format: 'ACTIVITY',
      bands: ['baby'],
      blocks: [
        PpIntro('The first game with a rule in it, and the rule is the whole '
            'point: my turn, then your turn.'),
        PpSteps([
          PpStep('Sit facing your baby with your legs open, close at first'),
          PpStep('Roll a soft ball slowly across and say your baby\'s name'),
          PpStep('Wait',
              'Your baby may just hold it. That is fine. Waiting is the activity.'),
          PpStep('Help the little hands push it back the first few times',
              'Then stop helping and let it be clumsy.'),
          PpStep('Say the same two words every time',
              "My turn, your turn. Your baby won't say it back for a year, "
              "but is learning it now."),
        ], heading: 'What happens'),
        PpCards([
          PpCard('A soft ball', 'Or a rolled ball of cloth, or an empty plastic '
              'bottle which rolls beautifully.'),
          PpCard('Floor space', 'A metre is enough to start.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Sitting up while reaching and pushing is real trunk work. It builds '
          'the very muscles needed for crawling and standing.',
          'Underneath it is something bigger. Turn taking is the seed of every '
          'social skill that follows, from sharing a toy at two to waiting to '
          'speak at six. It starts here, without words, with a ball.',
        ], heading: 'What it builds'),
        PpWhenLine('From about eight months, once your baby sits steadily '
            'without toppling, and for a long time afterwards.'),
      ],
    ),

    // ---- BAND: 1 to 2 years ------------------------------------------------
    PpPage(
      id: 'act_stacking_bowls',
      title: 'Stacking and nesting steel bowls',
      subtitle: 'For 1 to 2 years',
      format: 'ACTIVITY',
      bands: ['one'],
      blocks: [
        PpIntro('Your kitchen already has the best stacking toy ever made. '
            'It nests, it stacks, it makes a wonderful noise when it falls.'),
        PpSteps([
          PpStep('Take out four or five steel bowls of clearly different sizes'),
          PpStep('Show your toddler once, slowly, how the small one goes inside '
              'the big one'),
          PpStep('Push the pile across and let your toddler try',
              'It will go wrong for weeks. Leave the little hands to it.'),
          PpStep('Build a tower and let your toddler knock it down',
              'Knocking down comes before building. Both are learning.'),
          PpStep('Add a spoon and a lid once the bowls get boring',
              'Now it is a posting game and a drum as well.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Four or five steel bowls', 'Different sizes, no sharp rims.'),
          PpCard('Nothing else', 'Bought stacking cups do the same job. The '
              'kitchen ones are heavier, which makes them better practice.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Getting one bowl inside another is a size problem, solved by trial '
          'and error. It is the first ordering of the world by size. That is '
          'real early maths, with no numbers in it at all.',
          'Placing a bowl carefully on another without knocking it over '
          'needs hand control, wrist turning and the patience to let go '
          'slowly. Those three things are what a pencil will one day need.',
        ], heading: 'What it builds'),
        PpWhenLine('From about twelve months. Nesting comes before stacking, '
            'usually by eighteen months.'),
      ],
    ),
    PpPage(
      id: 'act_posting_box',
      title: 'The posting box',
      subtitle: 'For 1 to 1.5 years',
      format: 'ACTIVITY',
      bands: ['one'],
      blocks: [
        PpIntro('Cut a slot in an old carton and a toddler will feed it for '
            'twenty minutes. It is oddly satisfying to watch.'),
        PpSteps([
          PpStep('Find a shoebox or a small carton with a lid'),
          PpStep('Cut one slot in the lid, big enough for a bottle cap to drop '
              'through',
              'One slot only at first. Two shapes is a harder game for later.'),
          PpStep('Give your toddler a small pile of bottle caps or large buttons',
              'Everything must be too big to swallow. Bottle caps from a two '
              'litre bottle are about right.'),
          PpStep('Show how once, then step back'),
          PpStep('Open the box and tip it out together when it is full',
              'The emptying is half the fun, and it is where counting talk '
              'comes in later.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('A carton and a lid', 'Any box that closes.'),
          PpCard('Bottle caps', 'Ten or twelve. Wash them first.'),
          PpCard('Adult scissors, used once',
              'You cut the slot, not your toddler. Then the scissors go away.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Lining a small object up with a small hole is precise fine motor '
          'work. It needs the eyes and hands to agree with each other.',
          'It is also object permanence again, one level up. It went in, it '
          'cannot be seen, and your toddler now knows for sure it is still in '
          'there. A year ago that was a mystery.',
        ], heading: 'What it builds'),
        PpWhenLine('From about twelve months to eighteen months. After that, '
            'two different shapes and two different slots are more fun.'),
        PpCallout(
          'A small bottle cap is exactly the size that can choke a toddler. Use '
          'caps from large bottles only, count them out and count them back '
          'in, and put the box on a high shelf between goes.',
          kind: PpCalloutKind.safety,
          title: 'Count them out, count them back',
        ),
      ],
    ),
    PpPage(
      id: 'act_colour_sort',
      title: 'Sorting into two bowls',
      subtitle: 'For 1.5 to 2 years',
      format: 'ACTIVITY',
      bands: ['one'],
      blocks: [
        PpIntro('Two bowls, one pile of mixed caps, and the first time your '
            'toddler puts the world into groups.'),
        PpSteps([
          PpStep('Start with only two colours, and only a few of each',
              'Six red caps and six blue ones. More than that is a mess, not a '
              'game.'),
          PpStep('Put one red cap in the red bowl and one blue in the blue bowl',
              'Then hand over the pile without instructions.'),
          PpStep('Name the colour as each one lands, without correcting',
              'If a red goes in the blue bowl, just say red as you would '
              'anyway. Your toddler will fix it within a few weeks.'),
          PpStep('When two colours are easy, add a third'),
          PpStep('Then sort by something other than colour',
              'Big and small. Spoons and caps. Smooth and rough.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Two bowls', 'Small steel bowls are perfect.'),
          PpCard('Twelve bottle caps in two colours',
              'Or buttons, or two kinds of dal in a bigger version for older '
              'children.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Sorting is the beginning of maths thinking. Before children can '
          'count things, they have to see them as a group of the same kind. '
          'That is exactly the skill this builds.',
          'Deciding that this one belongs here and that one does not is also '
          'a first logical rule. Your toddler applies it alone, with no adult '
          'giving the answer each time.',
        ], heading: 'What it builds'),
        PpWhenLine('From about eighteen months, when colour words start to '
            'mean something. Sorting by size works a little earlier.'),
      ],
    ),
    PpPage(
      id: 'act_water_pouring',
      title: 'Pouring water between two glasses',
      subtitle: 'For 1.5 to 2 years',
      format: 'ACTIVITY',
      bands: ['one'],
      blocks: [
        PpIntro('It will spill. That means the activity is working. Put a tray '
            'under it and let your toddler pour.'),
        PpSteps([
          PpStep('Sit your toddler at a low table or on the floor with a steel '
              'tray'),
          PpStep('Give two small glasses, one with a little water in it',
              'Start with two fingers of water only. A full glass is a flood '
              'and a letdown.'),
          PpStep('Pour slowly once yourself, making the tilt big and clear'),
          PpStep('Hand it over and sit on your hands',
              'Don\'t steady the glass. The wobble is the learning.'),
          PpStep('Give your toddler a cloth to wipe the spill',
              'Cleaning up is part of the work, not a punishment for it. '
              'Toddlers love the wiping.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Two small steel glasses', 'Light ones a toddler can lift when '
              'full.'),
          PpCard('A tray with a rim', 'A thali works. It contains the mess.'),
          PpCard('A small cloth', 'Your toddler\'s own, for wiping.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Pouring needs both hands to do different jobs while the eyes judge a '
          'moving level. Very few activities at this age ask for that much '
          'coordination at once.',
          'It is also a first real job. Two-year-olds who pour their own water '
          'learn that they can do things for themselves. That belief is worth '
          'more than the skill.',
          'Watch how long the pouring lasts. Focus this deep is rare and '
          'valuable at eighteen months, and it is the same attention a '
          'classroom will need later. Don\'t interrupt it to offer praise.',
        ], heading: 'What it builds'),
        PpWhenLine('From about eighteen months. It stays useful right through '
            'to four, with the glasses getting bigger.'),
        PpIndiaNote('In most Indian homes this can happen at the tap during '
            'the daily bath, with a mug and a bucket. No special setup '
            'needed, and the floor is already wet.'),
        PpVideoSlot(
          title: 'Setting up a pouring tray',
          subtitle: 'How much water to start with, and where to sit so you do '
              'not take over.',
          minutes: '3 MIN',
          slotId: 'learning/act/water_pouring',
        ),
      ],
    ),
    PpPage(
      id: 'act_first_pretend',
      title: 'Feeding the doll, putting teddy to sleep',
      subtitle: 'For 1.5 to 2 years',
      format: 'ACTIVITY',
      bands: ['one'],
      blocks: [
        PpIntro('The first time your toddler does to a toy what you do every '
            'day. It is a much bigger moment than it looks.'),
        PpSteps([
          PpStep('Give your toddler a doll or a soft toy, a small bowl and a '
              'spoon'),
          PpStep('Feed the doll yourself once, with sound effects',
              'Aa aa aa, one more bite. Just the way you feed your toddler.'),
          PpStep('Hand it over and follow your toddler\'s lead'),
          PpStep('Add the rest of the routine one piece at a time',
              'A cloth to burp it, a scrap of dupatta as a blanket, a pat and a '
              'hum to put it to sleep.'),
          PpStep('Join in as a character, not as a director',
              "Say the doll is hungry. Don't say, now feed the doll properly."),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Any soft toy or doll', 'A rolled towel with a knot for a head '
              'works perfectly.'),
          PpCard('A small bowl and spoon', 'Real ones. Toddlers prefer real.'),
          PpCard('A scrap of cloth', 'Blanket, towel, sling. It becomes all '
              'three.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Pretending is the mind holding two things at once: this is a cloth, '
          'and this is a blanket. Letting one thing stand for another is the '
          'same ability that later lets a written mark stand for a sound.',
          'Caring for a toy is also the first practice of empathy. Your toddler '
          'is learning to be the one who notices that somebody else is hungry, '
          'cold or sleepy.',
        ], heading: 'What it builds'),
        PpWhenLine('From about eighteen months. It grows into full role play '
            'between two and four.'),
        PpCallout('Boys need dolls as much as girls do. Caring for something '
            'small is not a girls\' skill, and a boy who has practised it becomes '
            'a man who notices when someone needs help.'),
      ],
    ),
    PpPage(
      id: 'act_music_movement',
      title: 'Clapping and dancing to a song',
      subtitle: 'For 1 to 2 years',
      format: 'ACTIVITY',
      bands: ['one'],
      blocks: [
        PpIntro('Five minutes of music, and both of you moving. It is the '
            'easiest thing in this whole door and one of the most useful.'),
        PpSteps([
          PpStep('Put on one song, the same one most days',
              'Familiar beats new for a toddler. Half the joy is waiting for '
              'the part that is coming.'),
          PpStep('Clap on the beat and invite your toddler to copy'),
          PpStep('Add a body part each time',
              'Stamp your feet. Turn around. Hands up high. Sit down fast.'),
          PpStep('Stop the music suddenly and freeze',
              'Toddlers find the stopping game hilarious, and it is real self '
              'control practice.'),
          PpStep('Sing it with no music too',
              'Your voice, out of tune, is better than any recording.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('One song', 'A lullaby, a film song, a nursery rhyme. Any of it.'),
          PpCard('A little floor space', 'And no audience.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Rhythm and language sit close together in the brain. Children who '
          'clap in time find the beats inside words more easily later. That is '
          'the exact skill that makes reading click.',
          'Copying a movement you have just made is imitation, and toddlers '
          'learn almost everything that way. Freezing when the music stops is '
          'the beginning of self control. Every classroom asks for that skill.',
        ], heading: 'What it builds'),
        PpWhenLine('From twelve months, as soon as your toddler can stand and '
            'bounce. It never stops working.'),
        PpIndiaNote('A grandmother humming as she works is the same activity. A child '
            'growing up around live singing hears far more musical variety '
            'than one who only hears a speaker.'),
      ],
    ),
    PpPage(
      id: 'act_picture_point',
      title: 'Pointing at pictures in a book',
      subtitle: 'For 1 to 2 years',
      format: 'ACTIVITY',
      bands: ['one'],
      blocks: [
        PpIntro('Not reading the story. Just one page, one picture, one word, '
            'and a long pause afterwards.'),
        PpSteps([
          PpStep('Sit your toddler on your lap with a board book, or a magazine'),
          PpStep('Point at one thing and name it',
              'Cow. That is the whole sentence.'),
          PpStep('Wait. Count to five in your head',
              'This pause is where your toddler\'s try at the word goes. If you '
              'fill it, there is no room left to speak.'),
          PpStep('Accept any sound as the word',
              'Oo for cow counts. Say cow back, warmly, and move on.'),
          PpStep('Let your toddler turn the pages and skip about',
              'Finishing the book is not the goal at this age.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Any book with pictures', 'Board books last longest, but old '
              'magazines and food packets work.'),
          PpCard('Your lap', 'The closeness is doing half the work.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Pointing at a picture together is called joint attention. It is one '
          'of the strongest engines of early vocabulary. You are both looking '
          'at the same thing, so it is clear which object the word belongs to.',
          'It also shows your toddler what a book is: something you hold, turn '
          'and find things in. That comfort with books is worth more at '
          'eighteen months than knowing a single letter.',
        ], heading: 'What it builds'),
        PpWhenLine('From about twelve months. Three minutes is a long time at '
            'this age and plenty.'),
        PpLink(
          'Books worth having at this age',
          surfaceId: 'pp_read',
          blurb: 'Board books and picture books, and what makes one good for a '
              'toddler.',
        ),
      ],
    ),

    // ---- BAND: 2 to 3 years ------------------------------------------------
    PpPage(
      id: 'act_spooning_dal',
      title: 'Spooning dal from one bowl to another',
      subtitle: 'For 2 to 3 years',
      format: 'ACTIVITY',
      bands: ['two'],
      blocks: [
        PpIntro('The calmest ten minutes of your day. Moving dal one spoonful '
            'at a time absorbs a two-year-old completely.'),
        PpSteps([
          PpStep('Put two small bowls on a tray, one with half a cup of dal in it'),
          PpStep('Give your child a spoon that fits a small hand',
              'A small steel spoon, not a serving one.'),
          PpStep('Move one spoonful yourself, slowly, and then stop'),
          PpStep('Let your child keep going until the interest runs out',
              'Don\'t count, don\'t praise mid-way, don\'t tidy the spills as '
              'they happen.'),
          PpStep('Tip it back and let your child go again, if wanted',
              'Repetition is the point. The aim is not finishing a task. It is '
              'refining a movement.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Two small bowls and a small spoon', 'From your own kitchen.'),
          PpCard('Half a cup of dal or rice',
              'Chana dal is a good size to start. It goes back in the packet '
              'afterwards.'),
          PpCard('A tray', 'So the spills stay in one place.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'The grip on the spoon is almost exactly the grip a pencil needs. '
          'Building it here, with no pressure and no letters, is why children '
          'who do everyday practical work often write comfortably later, '
          'without ever being drilled.',
          'The deeper thing being built is concentration. A two-year-old who '
          'stays with one chosen task for eight minutes is stretching an '
          'attention span. School will ask for attention before it asks for '
          'anything academic.',
        ], heading: 'What it builds'),
        PpWhenLine('From about two years. Move from dal to water once the '
            'spills are small.'),
        PpVideoSlot(
          title: 'Practical life at your kitchen counter',
          subtitle: 'Spooning, pouring and scooping, set up with ordinary '
              'utensils.',
          minutes: '5 MIN',
          slotId: 'learning/act/spooning_dal',
        ),
      ],
    ),
    PpPage(
      id: 'act_colour_hunt',
      title: 'Find something red',
      subtitle: 'For 2 to 3 years',
      format: 'ACTIVITY',
      bands: ['two'],
      blocks: [
        PpIntro('A game you can play while cooking, without stopping cooking. '
            'One colour, one room, and a small person running.'),
        PpSteps([
          PpStep('Name one colour and give your child the whole room',
              'Go and find something red. Anything red.'),
          PpStep('Accept whatever comes back',
              'If the orange dupatta arrives, say that is close, that is '
              'orange, and take it happily.'),
          PpStep('Line up everything your child finds',
              'Five red things in a row feels better to a small child than any '
              'praise.'),
          PpStep('Swap roles and let your child pick the colour for you',
              'Getting it wrong on purpose is very funny at this age.'),
          PpStep('Play the same game with shapes and sizes later',
              'Find something round. Find something bigger than this book.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Your house', 'Exactly as it already is.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Colour words are abstract in a way object words are not. Red is not '
          'a thing. It is something unrelated things share, and hunting for it '
          'across a room is how that idea lands.',
          'Scanning a busy room for one feature is also visual discrimination. '
          'Later, it helps your child spot the difference between two very '
          'similar letters, without anyone teaching it.',
        ], heading: 'What it builds'),
        PpWhenLine('From about two years, once your child has a few colour '
            'words. It stays fun until four or five.'),
      ],
    ),
    PpPage(
      id: 'act_lid_matching',
      title: 'Matching lids to their containers',
      subtitle: 'For 2 to 3 years',
      format: 'ACTIVITY',
      bands: ['two'],
      blocks: [
        PpIntro('Empty the shelf of tins and boxes onto the floor, separate the lids, and '
            'hand the whole problem to your child.'),
        PpSteps([
          PpStep('Choose four or five containers of clearly different sizes'),
          PpStep('Put the lids in one pile and the boxes in another'),
          PpStep('Let your child try lids on boxes until they fit',
              'Wrong fits are the most useful tries. This is learning by '
              'ruling things out.'),
          PpStep('Add a screw-top jar once the press-on lids are easy',
              'Twisting is a different wrist movement and a harder one.'),
          PpStep('Make it a real job at tidy-up time',
              'Now it is helping, and small children want that even more than '
              'a game.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Four or five tins or boxes with lids',
              'Different sizes. Nothing glass, nothing sharp.'),
          PpCard('One screw-top jar', 'For when your child is ready for harder.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Matching a lid to a box is a shape and size problem. Your child '
          'holds it in mind while the hands test it. That is early spatial '
          'reasoning and early problem solving in one.',
          'Screwing a lid on is a turning wrist movement that little else in a '
          'toddler\'s day practises. It feeds straight into every later tool, '
          'including a pencil.',
        ], heading: 'What it builds'),
        PpWhenLine('From about two years for press-on lids, closer to three for '
            'screw tops.'),
      ],
    ),
    PpPage(
      id: 'act_threading',
      title: 'Threading pasta on a string',
      subtitle: 'For 2.5 to 3 years',
      format: 'ACTIVITY',
      bands: ['two'],
      blocks: [
        PpIntro('Dry penne and a shoelace. It looks like nothing, and it is one '
            'of the hardest fine motor jobs a two-year-old can do.'),
        PpSteps([
          PpStep('Tie a knot at one end of a shoelace or a stiff thread',
              'Stiff matters. A soft thread collapses and the whole thing '
              'becomes impossible.'),
          PpStep('Put a bowl of dry penne or macaroni within reach'),
          PpStep('Thread the first two yourself, then hand it over'),
          PpStep('Say nothing during the struggle',
              'The near-misses are where the coordination is being built. '
              'Taking over ends the learning instantly.'),
          PpStep('Tie the ends so your child can wear it or hang it up',
              'Making something that lasts matters enormously at this age.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Dry pasta with a hole', 'Penne, macaroni, or short straws cut '
              'into pieces.'),
          PpCard('A shoelace or stiff string', 'Wrap one end with tape to make '
              'a firm tip.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Threading needs the two hands to do different jobs at the same time '
          'while the eyes guide both. That two-handed teamwork is a big step '
          'up from anything at eighteen months.',
          'It is also a lesson in persistence. A child who keeps trying after '
          'six failed threads has practised something no worksheet teaches.',
        ], heading: 'What it builds'),
        PpWhenLine('From about two and a half. Before that the hole is usually '
            'too small a target, and it ends in frustration.'),
        PpCallout(
          'Dry pasta and straws are choking-sized, and string is a strangling '
          'risk. Stay in the room for the whole activity, and put the string '
          'away on a high shelf the moment it ends.',
          kind: PpCalloutKind.safety,
          title: 'Stay in the room',
        ),
      ],
    ),
    PpPage(
      id: 'act_pretend_shop',
      title: 'Playing vegetable shop',
      subtitle: 'For 2 to 3 years',
      format: 'ACTIVITY',
      bands: ['two'],
      blocks: [
        PpIntro('You are the customer, your child is the vegetable seller, and the '
            'vegetables are the ones you bought this morning.'),
        PpSteps([
          PpStep('Spread a cloth on the floor and lay out real vegetables',
              'Onions, a bottle gourd, some lemons. Real is more interesting than '
              'plastic.'),
          PpStep('Hand over a bowl for a weighing pan and some bottle caps as '
              'coins'),
          PpStep('Be the customer and ask properly',
              'Excuse me, how much for the tomatoes? Give me two.'),
          PpStep('Let your child set the prices and get them wrong',
              'A tomato can cost a hundred rupees. Leave the maths alone. It '
              'is not the point.'),
          PpStep('Swap roles halfway through',
              'Being the customer needs a whole different set of words.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Real vegetables', 'Whatever came home in the bag today.'),
          PpCard('Bottle caps or old coins', 'For money.'),
          PpCard('A cloth and a bowl', 'Shop and weighing pan.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Role play is one of the richest language activities of the toddler '
          'years. Your child has to use new words, ask questions, answer them, '
          'and stay in a role while doing it.',
          'It is also social practice. Greeting, asking politely, handing '
          'over, saying thank you and ending an exchange are all being '
          'practised in a place where getting it wrong costs nothing.',
        ], heading: 'What it builds'),
        PpWhenLine('From about two years. It gets more detailed and much '
            'funnier through to four.'),
        PpIndiaNote('Kitchen play, chai making and shop play last longest in '
            'Indian homes, because your child has watched all three happen a '
            'thousand times. Familiar scripts make the best play.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpCards(heading: 'More ways to learn about money', [
              PpCard('Sort the coins', 'By size or colour, with you watching '
                  'closely: coins are a choking risk under four.'),
              PpCard('A piggy bank', 'For the gift money relatives hand over. Watching it '
                  'fill teaches saving.'),
              PpCard('Shop together', 'Let your child hand over the money and '
                  'take the change.'),
              PpCard('Wants and needs', 'Talk through one small choice: this '
                  'toy, or save for that one.'),
            ]),
      ],
    ),
    PpPage(
      id: 'act_mark_making',
      title: 'Scribbling with fat crayons',
      subtitle: 'For 2 to 3 years',
      format: 'ACTIVITY',
      bands: ['two'],
      blocks: [
        PpIntro('Big paper, fat crayons, and no instructions at all about what '
            'to draw. This is the beginning of writing, and it is meant to look '
            'like nothing.'),
        PpSteps([
          PpStep('Tape a large sheet of newspaper or chart paper to the floor',
              'Bigger paper means bigger arm movements, which is what you want '
              'at this age.'),
          PpStep('Hand over two or three fat crayons and step back'),
          PpStep('Don\'t ask what it is',
              'Say tell me about your picture, or just describe what you see. '
              'Lots of blue here. This one goes round and round.'),
          PpStep('Try scribbling on a vertical surface too',
              'Paper taped to a wall or a door builds shoulder strength, and '
              'that is where pencil control comes from.'),
          PpStep('Keep one and put it up',
              'Not all of them. One at a time on the fridge means more than a '
              'drawer full.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Fat crayons', 'Chunky ones. Thin pencils force a grip small '
              'hands are not ready for.'),
          PpCard('Big paper', 'Old newspaper, the back of a calendar, brown '
              'paper from a parcel.'),
          PpCard('Tape', 'So the paper does not chase the crayon.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Every letter your child will write is made of lines and curves. Both '
          'live in the shoulder and elbow long before they live in the '
          'fingers. Big scribbling is how those muscles get built.',
          'Scribbling is also the first sign that a mark on paper can mean '
          'something. Around three, your child will start telling you what a '
          'scribble is. That is an enormous leap, and the real start of '
          'writing.',
        ], heading: 'Why scribbling is writing practice'),
        PpWhenLine('From about eighteen months to two years. No child, at any '
            'age, needs to be made to draw a specific shape.'),
        PpCallout(
          'Don\'t ask a two-year-old to copy a letter, and don\'t hold the hand '
          'to make one. Bring out bigger paper and let the scribble stay a '
          'scribble.',
          kind: PpCalloutKind.safety,
          title: 'No letters yet',
        ),
      ],
    ),
    PpPage(
      id: 'act_count_the_table',
      title: 'Counting out the bowls',
      subtitle: 'For 2.5 to 3 years',
      format: 'ACTIVITY',
      bands: ['two'],
      blocks: [
        PpIntro('Laying the table is a real job with real numbers in it. Small '
            'children would rather do a real job than any game.'),
        PpSteps([
          PpStep('Ask for a number of things you really need',
              'We are four people. Bring four spoons.'),
          PpStep('Count them out together, touching each one',
              'One, two, three, four. Touching is what makes counting mean '
              'anything at this age.'),
          PpStep('Let your child carry them and place them',
              'One at each place. That is matching one thing to one person.'),
          PpStep('Ask a question with a number in it',
              'Is that enough? Grandma is coming, how many now?'),
          PpStep('Don\'t correct a wrong count',
              'Just count it again together, touching. Your child will land on '
              'it over a few weeks.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Your actual dinner', 'Bowls, spoons, plates.'),
          PpCard('One real job', 'That is the whole activity.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Reciting one two three four is a song. Touching four objects and '
          'knowing there are four is maths. The two are completely different, '
          'and this activity builds the second one.',
          'Matching one spoon to one person is called one-to-one '
          'correspondence. It sits underneath all the arithmetic to come, and '
          'it is far more valuable at three than counting to fifty.',
        ], heading: 'What it builds'),
        PpWhenLine('From about two and a half, and it grows with your child. At '
            'five, it becomes working out how many more are needed.'),
      ],
    ),
    PpPage(
      id: 'act_story_actout',
      title: 'Acting out a story with sounds',
      subtitle: 'For 2.5 to 3 years',
      format: 'ACTIVITY',
      bands: ['two'],
      blocks: [
        PpIntro('Take a story your child already knows, and get up and be it. '
            'Ten minutes, no props, a lot of roaring.'),
        PpSteps([
          PpStep('Pick a very short story your child has heard many times',
              'The lion and the mouse works well. So does anything with two '
              'animals in it.'),
          PpStep('Give each of you a part, and use your whole body'),
          PpStep('Do the sounds loudly',
              'The roar, the squeak, the running feet. Sound is what small '
              'children remember.'),
          PpStep('Stop and ask what happens next',
              'Let your child tell you. If the order comes out wrong, follow '
              'that version.'),
          PpStep('Swap parts and do it again',
              'Playing the other character means remembering different lines.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('A story you both know', 'From this door, or any book.'),
          PpCard('Nothing else', 'A dupatta becomes a mane, a cave and a river '
              'as needed.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Retelling a story in order is sequencing. Sequencing is the '
          'backbone of understanding, and of explaining anything. It is the '
          'same skill your child will use to tell you about a day at school.',
          'Speaking as a character stretches language beyond everyday words, '
          'because a lion does not talk the way a three-year-old talks.',
        ], heading: 'What it builds'),
        PpWhenLine('From about two and a half, once your child can hold a short '
            'story in mind.'),
        PpLink(
          'Short stories that act out well',
          pageId: 'st_world_lion_mouse',
          blurb: 'The lion and the mouse, one of the easiest to play out.',
        ),
      ],
    ),

    // ---- BAND: 3 to 4 years ------------------------------------------------
    PpPage(
      id: 'act_prewriting_lines',
      title: 'Lines, zigzags and circles before letters',
      subtitle: 'For 3 to 4 years',
      format: 'ACTIVITY',
      bands: ['three'],
      blocks: [
        PpIntro('Every letter is made of six or seven basic strokes. Practise '
            'the strokes, in the air and in the mud, and the letters come '
            'almost by themselves later.'),
        PpSteps([
          PpStep('Draw the shape hugely in the air with your whole arm first',
              'A circle drawn with the shoulder, not the fingers. Your child '
              'copies you, standing up.'),
          PpStep('Move it down to a tray of flour, rice or wet sand',
              'Drawing with one finger in a tray is forgiving and endlessly '
              'repeatable. No pencil pressure to think about.'),
          PpStep('Then a fat crayon on big paper',
              'Straight down, across, a zigzag, a wave, a circle, a cross.'),
          PpStep('Keep every session under ten minutes',
              'Stop while your child still wants more. That is what brings '
              'your child back tomorrow.'),
          PpStep('Never ask for a second go because it was untidy',
              'Neatness is not a three-year-old skill. Asking for it teaches a '
              'child, I am bad at this.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('A tray of flour or rice', 'The best pre-writing surface there '
              'is, and free.'),
          PpCard('Fat crayons and big paper', 'Nothing thinner yet.'),
          PpCard('A wall or door to work on',
              'Vertical work builds the shoulder, and the shoulder is what '
              'holds a pencil steady.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Writing is a whole-arm skill that ends at the hand. Children pushed '
          'into small letters before the shoulder and wrist are ready end up '
          'gripping hard, tiring fast and hating it.',
          'The strokes that matter are the vertical line, the horizontal line, '
          'the circle, the cross, the diagonal and the zigzag. Every letter and '
          'every number in every Indian script is built from those.',
        ], heading: 'What it builds'),
        PpWhenLine('From three years, in short bursts. For most children, '
            'formal letter writing has no place before five.'),
        PpVideoSlot(
          title: 'The strokes that come before letters',
          subtitle: 'The six shapes, shown big in a tray of flour and on paper.',
          minutes: '6 MIN',
          slotId: 'learning/act/prewriting_lines',
        ),
        PpCallout(
          'If a preschool sends home writing worksheets for a three-year-old, '
          'it is fine to do ten minutes and stop. No evidence supports early '
          'formal writing, and plenty shows it puts children off.',
          kind: PpCalloutKind.myth,
          title: 'Earlier is not better',
        ),
      ],
    ),
    PpPage(
      id: 'act_counting_games',
      title: 'Counting the stairs and the rotis',
      subtitle: 'For 3 to 4 years',
      format: 'ACTIVITY',
      bands: ['three'],
      blocks: [
        PpIntro('Numbers are everywhere in a normal day. You don\'t need a '
            'single worksheet to teach a three-year-old to count.'),
        PpSteps([
          PpStep('Count things you are already touching',
              'Stairs as you climb, rotis as they come off the pan, bangles on '
              'a wrist, buttons as you do them up.'),
          PpStep('Touch each one as you say the number',
              'The touch is what links the word to the amount.'),
          PpStep('Stop and ask how many',
              'Say the numbers, then ask, so how many rotis? Getting from '
              'counting to knowing the total is a real leap.'),
          PpStep('Play give me three',
              'Give me three spoons. This is much harder than counting, and it '
              'is the skill that matters.'),
          PpStep('Count backwards while something happens',
              'Five, four, three, two, one, and the light goes off. Counting '
              'backwards is the seed of subtraction.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Whatever you are doing', 'Stairs, rotis, buttons, steps to '
              'the gate.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'A child who can rattle off numbers to fifty may not be able to hand '
          'you three spoons. The second is real number sense. It is built by '
          'touching and giving, not by reciting.',
          'Counting during a real activity also gives numbers a purpose. Your '
          'child learns that we count because we need to know how many, which '
          'is why counting exists.',
        ], heading: 'What it builds'),
        PpWhenLine('From about three. Most children reliably know how many up '
            'to four or five by four years old.'),
      ],
    ),
    PpPage(
      id: 'act_letter_sounds',
      title: 'What starts with mmm',
      subtitle: 'For 3 to 4 years',
      format: 'ACTIVITY',
      bands: ['three'],
      blocks: [
        PpIntro('A listening game, not a reading lesson. No cards, no letters '
            'on paper, just the sounds at the front of words.'),
        PpSteps([
          PpStep('Make the sound, don\'t say the letter name',
              'Say mmm, not em. The sound is what reading will need.'),
          PpStep('Give two examples from your child\'s own life',
              'Mmm for mummy, mmm for mango. What else starts with mmm?'),
          PpStep('Accept wrong answers cheerfully',
              'If the answer is banana, say banana starts with buh, listen, mmm '
              'mango. And move on.'),
          PpStep('Play it in the car and in a queue',
              'It needs nothing at all, which is what makes it stick.'),
          PpStep('Do the same with the sounds of your child\'s own name',
              'Small children find their own names the most interesting words '
              'there are.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Nothing', 'This is purely a listening game.'),
          PpCard('Not flash cards',
              'Flash cards teach letter names. That is the least useful part, '
              'and the part that makes children think reading is a test.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Hearing that mango and mummy begin with the same sound is called '
          'phonemic awareness. It is the strongest single predictor of how '
          'easily a child learns to read, and it is entirely an ear skill.',
          'It works in every language your family speaks. Doing it in Hindi as '
          'well as English is a bonus, not a confusion.',
        ], heading: 'What it builds'),
        PpWhenLine('From about three and a half. Rhyming usually comes easily '
            'first, first sounds a little later.'),
        PpCallout(
          'Does your child miss sounds from behind, mishear often, or seem very '
          'hard to understand at three? Ask your paediatrician for a hearing '
          'check before assuming it is a learning issue. Fluid behind '
          'the ears after repeated colds is common and treatable.',
          kind: PpCalloutKind.doctor,
          title: 'Sound games need working ears',
        ),
      ],
    ),
    PpPage(
      id: 'act_patterns',
      title: 'Making a pattern and continuing it',
      subtitle: 'For 3 to 4 years',
      format: 'ACTIVITY',
      bands: ['three'],
      blocks: [
        PpIntro('Red, blue, red, blue, and then a pause to see if your child '
            'can guess what comes next. Small game, big idea.'),
        PpSteps([
          PpStep('Lay out a simple two-item pattern and say it aloud',
              'Cap, spoon, cap, spoon. Pointing as you say it.'),
          PpStep('Stop mid-pattern and wait',
              'The pause is the question. Don\'t ask what comes next straight '
              'away. Leave the gap for your child to fill.'),
          PpStep('Let your child make one for you to continue',
              'It will be wild. Continue it anyway, out loud.'),
          PpStep('Move to three-item patterns once two is easy',
              'Cap, cap, spoon. Cap, cap, spoon.'),
          PpStep('Find patterns in the house',
              'Tiles on the floor, stripes on a dupatta, the railing on the '
              'stairs.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Two kinds of small object',
              'Caps and spoons, two colours of dal, big and small stones.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Spotting a pattern and predicting what comes next is the core of '
          'maths and logical thinking. Everything from times tables to grammar '
          'is pattern spotting in different clothes.',
          'Saying the pattern aloud while pointing links the spoken order to '
          'the one on the floor. That is exactly what reading a line of print '
          'asks for later.',
        ], heading: 'What it builds'),
        PpWhenLine('From about three years for two-item patterns, closer to '
            'four for three-item ones.'),
      ],
    ),
    PpPage(
      id: 'act_dressing_self',
      title: 'Buttons, zips and pouring water alone',
      subtitle: 'For 3 to 4 years',
      format: 'ACTIVITY',
      bands: ['three'],
      blocks: [
        PpIntro('Slower than doing it yourself, every single morning. It is '
            'still the most valuable ten minutes of the day.'),
        PpSteps([
          PpStep('Start at the end of the task, not the beginning',
              'You pull the shirt on, your child does the last button. '
              'Finishing feels like succeeding.'),
          PpStep('Practise buttons on a shirt laid flat on the floor first',
              'Buttons on your own chest are much harder, because you cannot '
              'see them properly.'),
          PpStep('Put water in a small jug your child can lift',
              'A jug and a glass on a low shelf means a drink without asking '
              'anyone.'),
          PpStep('Build in ten extra minutes rather than taking over',
              'The rushing is what kills this. Waking up ten minutes earlier '
              'is the whole solution.'),
          PpStep('Let the badly buttoned shirt go out of the house',
              'A crooked shirt your child did is worth more than a neat one you '
              'did.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Your child\'s own clothes', 'Big buttons and elastic waists '
              'are the kindest to start with.'),
          PpCard('A small jug and glass', 'Kept somewhere within easy reach.'),
          PpCard('Ten extra minutes', 'The only real material this needs.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Buttons, zips and pouring are demanding fine motor work. They come '
          'with a reason your child cares about, which is why children '
          'practise them so willingly.',
          'This is also the exact list a preschool will expect your child to '
          'manage. School readiness is far more about this page than about '
          'letters, and it is the part families most often skip.',
        ], heading: 'What it builds'),
        PpWhenLine('From about three years. Most children manage large buttons '
            'by four and shoelaces closer to six.'),
        PpIndiaNote('In a joint family, several loving hands can dress a child '
            'faster than the child can. It helps to say out loud, once, that '
            'your child is learning to do it alone now, so everyone is on the '
            'same side.'),
      ],
    ),
    PpPage(
      id: 'act_junk_modelling',
      title: 'Building something from the recycling',
      subtitle: 'For 3 to 4 years',
      format: 'ACTIVITY',
      bands: ['three'],
      blocks: [
        PpIntro('Boxes, caps, newspaper and tape. No picture to copy and no '
            'right answer, which is the whole point.'),
        PpSteps([
          PpStep('Keep a bag of clean recycling',
              'Matchboxes, toothpaste cartons, bottle caps, cardboard tubes, '
              'old newspaper.'),
          PpStep('Tip it out and ask what your child wants to make',
              'If there is no idea yet, start sticking two things together '
              'yourself and stay silent.'),
          PpStep('Offer tape rather than glue, for speed',
              'Waiting for glue to dry loses a three-year-old completely.'),
          PpStep('Don\'t fix what your child builds',
              'A wobbly robot your child built beats a neat one you rescued.'),
          PpStep('Photograph it, then let it go in a week',
              'Otherwise your house fills up. Most children are fine with this '
              'once they see the photo.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Clean recycling', 'Cartons, tubes, caps, newspaper.'),
          PpCard('Tape and blunt scissors', 'Child scissors from three years, '
              'with you sitting there.'),
          PpCard('No craft kit', 'Bought kits come with a picture of the right '
              'answer, which is the opposite of what this is for.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Open-ended building is where imagination and planning meet. Your '
          'child holds an idea in mind, then works out how to make the '
          'materials do it. That is early engineering thinking.',
          'It also builds patience with things not working. Towers fall, tape '
          'does not hold, and your child tries again. That is an important '
          'thing to be practising at three.',
        ], heading: 'What it builds'),
        PpWhenLine('From about three. It grows straight into proper model '
            'building at six and seven.'),
      ],
    ),
    PpPage(
      id: 'act_story_questions',
      title: 'Asking what happens next',
      subtitle: 'For 3 to 4 years',
      format: 'ACTIVITY',
      bands: ['three'],
      blocks: [
        PpIntro('The same story you already read, with four questions in it. '
            'That is the difference between hearing a story and thinking about '
            'one.'),
        PpSteps([
          PpStep('Read or tell the story straight through once, no interruptions'),
          PpStep('Go back and ask what happens next before a big moment',
              'Only once or twice. Stopping every page ruins the story.'),
          PpStep('Ask a why question at the end',
              'Why do you think the crocodile was sad? There is no wrong '
              'answer to a why.'),
          PpStep('Ask what your child would have done',
              'This is where the lesson in the story becomes your child\'s, '
              'not yours.'),
          PpStep('Let your child tell the story to somebody else',
              'Telling Papa at dinner is the strongest version of this whole '
              'activity.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Any story', 'From the collections in this door, or a book.'),
          PpCard('Four questions', 'What next, why, how did the crow feel, '
              'what would you do.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Answering why questions about a story is comprehension, and that is '
          'the real goal of reading. A child can read every word on a page and '
          'still not be a reader without this.',
          'Guessing what comes next also shows your child that stories have a '
          'shape. That shape is what will one day help your child write one.',
        ], heading: 'What it builds'),
        PpWhenLine('From about three years, once your child has enough words to '
            'answer a why. Before that, just tell the story.'),
      ],
    ),

    // ---- BAND: 4 to 6 years ------------------------------------------------
    PpPage(
      id: 'act_name_writing',
      title: 'Writing my own name',
      subtitle: 'For 4 to 6 years',
      format: 'ACTIVITY',
      bands: ['four'],
      blocks: [
        PpIntro('The first word worth writing, because it belongs to your child. '
            'Trace it, then copy it, and let it be wobbly for a long time.'),
        PpSteps([
          PpStep('Write your child\'s name once, large, in capitals or in your '
              'script',
              'One capital and the rest small is easier to read later, but '
              'start with whatever the school uses.'),
          PpStep('Trace over it with a finger first, then a crayon',
              'Finger tracing on a big letter teaches the movement before the '
              'tool gets involved.'),
          PpStep('Move to copying underneath your version'),
          PpStep('Stop at five minutes, always',
              'Short and daily beats long and weekly, and it keeps your child '
              'from ever dreading it.'),
          PpStep('Find real reasons to write it',
              'On a drawing, on a birthday card, on the lunch box label. '
              'Purpose is what makes practice worth doing.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Paper and a pencil', 'A triangular or chunky pencil is '
              'kinder on a young grip.'),
          PpCard('The name, written by you', 'Big, clear and always the same.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Children find their own name the most motivating word there is, '
          'which is why it is the usual place to start. It teaches letter '
          'shapes, left-to-right movement and pencil control all at once.',
          'Expect reversed letters until at least six or seven. A backwards N '
          'is completely normal at this age and is not a sign of anything.',
        ], heading: 'What it builds'),
        PpWhenLine('From about four years, if your child is interested. If not '
            'at four, wait. Five is early enough.'),
        PpCallout('Interest is the signal, not the calendar. Children pushed '
            'into writing before they want to often avoid it for years, and '
            'there is no prize for starting first.'),
      ],
    ),
    PpPage(
      id: 'act_first_sums',
      title: 'First sums with cashews and stones',
      subtitle: 'For 4 to 6 years',
      format: 'ACTIVITY',
      bands: ['four'],
      blocks: [
        PpIntro('Adding and taking away with things your child can touch and '
            'eat. No plus signs, no book, no right answers to be wrong about.'),
        PpSteps([
          PpStep('Put three cashews in your child\'s hand and two in yours'),
          PpStep('Ask how many altogether, then push them together and '
              'count',
              'Pushing the two piles into one is what addition really is.'),
          PpStep('Then take some away and ask how many are left',
              'Eating one is the most popular version of subtraction ever '
              'invented.'),
          PpStep('Say the story of the sum out loud',
              'You had five, you ate two, now you have three. Story first, '
              'symbols much later.'),
          PpStep('Use it in real moments',
              'Sharing biscuits between three cousins is a real division '
              'problem, and your child will care about the answer.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Small countable things', 'Cashews, raisins, stones, bottle '
              'caps, beads.'),
          PpCard('No worksheet', 'Written sums come after the idea is solid, '
              'not before.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Doing sums with objects builds a picture in the mind of what adding '
          'and taking away mean. Children who only meet sums as symbols on '
          'paper can get answers right for a year, then struggle when the '
          'problems get harder.',
          'Small numbers are enough. Being really secure up to five, then '
          'ten, is worth far more than being shaky up to fifty.',
        ], heading: 'What it builds'),
        PpWhenLine('From about four years. Most children handle sums within '
            'five by five, and within ten by six.'),
      ],
    ),
    PpPage(
      id: 'act_rhyming_games',
      title: 'Which words sound the same',
      subtitle: 'For 4 to 6 years',
      format: 'ACTIVITY',
      bands: ['four'],
      blocks: [
        PpIntro('A word game for the auto, the queue and the kitchen. It costs '
            'nothing and it does more for reading than any app.'),
        PpSteps([
          PpStep('Say two words and ask if they sound the same at the end',
              'Cat and mat. Sun and fun.'),
          PpStep('Ask for a word that rhymes with one you give',
              'Nonsense words count. Bat, mat, zat is a correct answer.'),
          PpStep('Play the first-sound version too',
              'Say a word without its first sound and ask what it is. Say '
              'AAT for cat.'),
          PpStep('Clap the parts of long words',
              'Ba-nan-a. Cha-pa-ti. Three claps. This is syllable work, and it '
              'is surprisingly hard.'),
          PpStep('Make up silly rhyming songs about the day',
              'Silliness keeps children playing, and playing is what makes it '
              'work.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Nothing at all', 'Purely spoken.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Rhyming, clapping syllables and hearing first sounds are the three '
          'ear skills reading is built on. Children who are strong in these '
          'learn to read faster, almost whatever way they are taught.',
          'Because it is all spoken, it works just as well in Hindi, in your '
          'mother tongue and in English. Doing it in more than one is a real '
          'advantage.',
        ], heading: 'What it builds'),
        PpWhenLine('From about four years, though many children enjoy rhyme '
            'much earlier through songs.'),
      ],
    ),
    PpPage(
      id: 'act_sequencing',
      title: 'Putting a story back in order',
      subtitle: 'For 4 to 6 years',
      format: 'ACTIVITY',
      bands: ['four'],
      blocks: [
        PpIntro('Four little drawings, shuffled, and one child working out what '
            'happened first. It looks like a puzzle, and it is thinking '
            'practice.'),
        PpSteps([
          PpStep('Draw four rough pictures of a story you both know',
              'Stick figures are completely fine. Four boxes on one sheet, cut '
              'apart.'),
          PpStep('Shuffle them and ask your child to lay them out in order'),
          PpStep('Ask your child to tell the story from that order',
              'If the order is different but the story makes sense, your child '
              'is right.'),
          PpStep('Do the same with a real routine',
              'Getting ready for school in four pictures. Now it is useful as '
              'well as fun.'),
          PpStep('Let your child draw the pictures once ready',
              'Drawing the sequence is harder and better than arranging one.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('Paper and a pen', 'Yours, for the four rough pictures.'),
          PpCard('A story your child knows well', 'From this door or a '
              'favourite book.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Ordering events is the backbone of understanding, of explaining '
          'anything clearly, and later of writing. It is also how cause and '
          'effect in history and science will one day make sense.',
          'A picture sequence of your child\'s own morning routine has a '
          'second use. It lets your child get ready without being told each '
          'step, which is exactly the independence school will expect.',
        ], heading: 'What it builds'),
        PpWhenLine('From about four years for four pictures. Three pictures '
            'works from three and a half.'),
      ],
    ),
    PpPage(
      id: 'act_his_own_job',
      title: 'A job to own',
      subtitle: 'For 4 to 6 years',
      format: 'ACTIVITY',
      bands: ['four'],
      blocks: [
        PpIntro('One small task that belongs to your child and nobody else, '
            'done every day, with nobody redoing it afterwards.'),
        PpSteps([
          PpStep('Offer a choice of two or three jobs you really need done',
              'Watering the plants, laying the napkins, filling the water '
              'bottles, feeding the fish.'),
          PpStep('Do it together for the first week'),
          PpStep('Then hand it over completely and step back'),
          PpStep('Don\'t redo it in front of your child',
              'A crooked napkin is the price of a child who feels useful. '
              'Straighten it later if you must.'),
          PpStep('Notice it out loud when it is done, without making it a '
              'reward',
              'The plants look happy today. Not: good job, here is a sticker.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('One real job', 'Something the household really needs.'),
          PpCard('No chart with stars',
              'A job done for a sticker stops the day the stickers stop. A job '
              'that belongs to your child keeps going.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Helping run the home is one of the strongest builders of self worth '
          'in a young child. It is different from praise. Your child is not '
          'hearing, you are good. Your child is finding out, I am needed.',
          'A daily task at the same time each day is also how a habit forms. '
          'Your child is practising remembering without a reminder. That is '
          'the beginning of managing oneself.',
        ], heading: 'What it builds'),
        PpWhenLine('From about four years for a job your child can own. Younger '
            'children help alongside you rather than owning a task.'),
        PpIndiaNote('In many Indian homes a child is served rather than asked '
            'to serve, often out of love. One small job is not making a child '
            'work. It gives your child a place in the running of the house.'),
      ],
    ),
    PpPage(
      id: 'act_show_and_tell',
      title: 'Talking to the family for one minute',
      subtitle: 'For 4 to 6 years',
      format: 'ACTIVITY',
      bands: ['four'],
      blocks: [
        PpIntro('Your child picks one loved thing and tells everyone about it '
            'for a minute, standing up. It is a very first speech.'),
        PpSteps([
          PpStep('Let your child choose the object',
              'A stone, a toy car, a drawing. Interest is what carries a child '
              'through the nerves.'),
          PpStep('Plan three things to say together',
              'What it is, where it came from, why it is special. Three is '
              'enough structure.'),
          PpStep('Find a real audience',
              'Everyone at dinner, or a grandparent on a video call. A real audience is '
              'the whole point.'),
          PpStep('Let people ask one question each',
              'Answering a question on the spot is the harder half of speaking.'),
          PpStep('Don\'t correct the grammar afterwards',
              'Say what you found interesting instead. Correction now buys '
              'silence later.'),
        ], heading: 'What happens'),
        PpCards([
          PpCard('One object your child loves', 'Chosen by your child, not you.'),
          PpCard('People willing to listen', 'The family at dinner is perfect.'),
        ], heading: 'What you need', hue: 42),
        PpArticle([
          'Speaking to a group is a skill, not a personality trait. It is '
          'built by doing it in a safe place many times. Starting at five with '
          'your own family is as gentle a start as there is.',
          'Putting three things in order before speaking is also early '
          'planning. It is the same structure your child will use to write a '
          'paragraph in a few years.',
        ], heading: 'What it builds'),
        PpWhenLine('From about four and a half. Once a week is plenty, and a '
            'shy child may listen for months before joining in.'),
        PpCallout('Never make a shy child perform. Start with telling one '
            'person, or telling it from your lap. Forcing it teaches that '
            'speaking up is frightening, the opposite of what this is for.'),
      ],
    ),
  ],
);

// =============================================================================
//  DOOR 2 - Learn through play, the Montessori-at-home idea
// -----------------------------------------------------------------------------
//  MONTESSORI IS AN ASPIRATIONAL SEARCH IN INDIA, around 18,100 a month, and
//  most of the results sell either a school at forty thousand rupees a term or a
//  wooden kit at four thousand. The honest version is that the parts of the
//  method which matter most in a home are free: real objects instead of toys, a
//  low shelf, a job the child can finish alone, and an adult who does not
//  interrupt.
//
//  So this area is careful to sell nothing. It names the kit as optional on the
//  page itself, because a parent who buys the kit and then does not change how
//  she behaves has spent money and gained nothing.
// =============================================================================

const PpArea _montessori = PpArea(
  id: 'montessori',
  mark: IntentMark.blocksMark,
  title: 'Learning through play at home',
  blurb: 'What the Montessori idea really means in a normal Indian house, '
      'without the school fees or the wooden kit.',
  hue: 160,
  bands: _fromOne,
  pages: [
    PpPage(
      id: 'mont_what_it_means',
      title: 'Montessori without the forty thousand rupee school',
      format: 'ARTICLE',
      bands: _fromOne,
      blocks: [
        PpIntro('Take away the branding and the idea is small and free: give a '
            'child real things, at child height, and let the child finish the '
            'job.'),
        PpArticle([
          'Maria Montessori was a doctor who spent years watching what children '
          'did when adults stopped directing them. She found that small '
          'children choose serious, repetitive, useful work over entertainment '
          'almost every time, if the work is within reach and nobody takes '
          'over.',
          'That is the whole of it. Everything else, the wooden equipment, the '
          'pink tower, the school fees, is one way of doing the idea. The idea '
          'itself costs nothing and fits into any home.',
        ], heading: 'What it really is'),
        PpSteps([
          PpStep('Real objects, not toy versions',
              'A real jug and a real cloth. Toddlers work harder for real '
              'things because they have watched you use them.'),
          PpStep('At child height, so your child can start without asking',
              'A low shelf, a stool at the basin, a glass on a low table.'),
          PpStep('One job, with a beginning and an end',
              'Pour the water, wipe the spill, put it back. A finished task is '
              'deeply satisfying to a small child.'),
          PpStep('Choice, from a small number of options',
              'Two or three things out on a shelf, not twenty in a toy box.'),
          PpStep('An adult who watches without interrupting',
              'This is the hardest part and the one that matters most.'),
        ], heading: 'How to do it in your house'),
        PpCards([
          PpCard('Buying the kit and changing nothing else',
              'The wooden materials are the least important part. How you '
              'behave is the method.'),
          PpCard('Correcting your child\'s hands',
              'Taking over to show the right way ends the concentration you '
              'were trying to build.'),
          PpCard('Twenty toys out at once',
              'Choice from three is freedom. Choice from twenty is noise, and '
              'your child will flit between all of them.'),
          PpCard('Turning it into a curriculum',
              'Once it becomes a syllabus with an outcome, it stops being led '
              'by the child. It becomes drilling with wooden blocks.'),
        ], heading: 'What to avoid', hue: 160),
        PpWhenLine('From about one year, once your child can carry and place '
            'things, through to six. The practical life part is strongest from '
            'two to four.'),
        PpIndiaNote('Indian homes are already full of the right materials. '
            'Steel bowls, a small broom, dal to spoon, a small water pot, dough to '
            'knead. A child who helps in an Indian kitchen is doing more '
            'practical life work than most Montessori classrooms offer.'),
        PpLink(
          'The activities that come from this idea',
          pageId: 'act_water_pouring',
          blurb: 'Pouring water, the classic starting point.',
        ),
        PpVideoSlot(
          title: 'A Montessori-style corner in one bedroom',
          subtitle: 'Set up in a normal flat, with a low shelf, three trays and '
              'nothing bought.',
          minutes: '8 MIN',
          slotId: 'learning/mont/setup_walkthrough',
        ),
      ],
    ),
    PpPage(
      id: 'mont_yes_space',
      title: 'Setting up a corner your child can touch',
      format: 'STEP-LIST',
      bands: _fromOne,
      blocks: [
        PpIntro('One corner of one room where the answer to can I touch that is '
            'always yes. It changes the whole tone of the day.'),
        PpSteps([
          PpStep('Pick one corner and clear it completely',
              'A metre square is enough. It does not need to be a whole room.'),
          PpStep('Put a low shelf there, or a stool on its side',
              'Low enough for your child to see and reach everything without '
              'help.'),
          PpStep('Put out only three or four things',
              'A tray of pouring things, a basket of books, one puzzle, one '
              'basket of blocks. That is a full shelf.'),
          PpStep('Give each thing its own tray or basket',
              'A clear container makes it obvious what belongs together and '
              'where it goes back.'),
          PpStep('Rotate one item a week',
              'Put the rest away in a cupboard. Things that vanish for a month '
              'come back fascinating.'),
          PpStep('Sit on the floor and check the view from your child\'s height',
              'You will see cables, sharp corners and temptations you cannot '
              'see standing up.'),
          PpStep('Make everything else in that corner fully safe',
              'Covered sockets, no cords, nothing heavy that can be pulled '
              'down, no small parts.'),
        ], heading: 'Setting it up'),
        PpCards([
          PpCard('A low shelf', 'Or a stool, a wooden crate, the bottom shelf '
              'of an existing cupboard.'),
          PpCard('Three or four trays or baskets', 'Steel plates work well.'),
          PpCard('Three or four activities', 'From this door. Nothing bought is '
              'needed.'),
        ], heading: 'What you need', hue: 160),
        PpArticle([
          'This works because it removes the endless no. A child who hears no '
          'forty times a day about touching things stops exploring, or stops '
          'listening. Neither is what you want.',
          'It also builds the start of independent choice. Walking over, '
          'picking something, using it and putting it back without asking is '
          'a small piece of self direction, repeated many times a day.',
        ], heading: 'Why a yes-space works'),
        PpWhenLine('From about ten months, once your child is moving around. It '
            'stays useful until five, with the contents changing.'),
        PpCallout(
          'A yes-space is only a yes-space if it is fully safe while you are '
          'in the kitchen for two minutes. Anchor any furniture that can tip, '
          'cover the sockets, and remove anything smaller than a toilet roll '
          'tube before you rely on it.',
          kind: PpCalloutKind.safety,
          title: 'Safe enough to turn your back on',
        ),
      ],
    ),
    PpPage(
      id: 'mont_practical_life',
      title: 'Letting your child help with real work',
      format: 'SHORT ARTICLE',
      bands: _fromTwo,
      blocks: [
        PpIntro('Washing a plate, kneading a small ball of dough, sweeping up '
            'crumbs. The most underrated learning there is.'),
        PpArticle([
          'Practical life means the ordinary work of running a home, done by a '
          'child at child size. Montessori classrooms spend a lot of time on '
          'it, and Indian homes hold more of it than almost any classroom '
          'could set up.',
          'It is slow. The plate gets washed badly, and you wash it again '
          'later. The point was never a clean plate. Your child is holding a '
          'set of steps in mind, a body is learning control, and there is the '
          'settled feeling of having done something real.',
        ], heading: 'What it is'),
        PpSteps([
          PpStep('Choose a job that is really part of what you are doing',
              'Peeling garlic, tearing coriander, putting spoons away.'),
          PpStep('Make the tools child-sized',
              'A small jug, a short-handled cloth, a low stool at the counter.'),
          PpStep('Show the whole thing once, slowly, with no talking',
              'Words and hands at the same time split a small child\'s '
              'attention. Do it silently, then hand it over.'),
          PpStep('Let your child finish, however long it takes'),
          PpStep('Include the putting away',
              'The job is not done until the cloth is back on the hook. That '
              'part is where most of the order-building happens.'),
        ], heading: 'How to do it'),
        PpCards([
          PpCard('Rescuing too soon', 'Stepping in at the first wobble is the '
              'most common way this gets ruined.'),
          PpCard('Praising every step', 'A constant well done interrupts as '
              'surely as criticism does.'),
          PpCard('Making it a chore chart',
              'Once it is tracked and rewarded, it stops being work your child '
              'wanted to do.'),
        ], heading: 'What to avoid', hue: 160),
        PpWhenLine('From about two years for simple jobs, and it grows all the '
            'way through childhood.'),
        PpIndiaNote('Grandparents often object that a child should not work. It '
            'usually helps to call it learning, not helping, and to start '
            'with jobs that look like play, such as tearing coriander or '
            'shelling peas.'),
      ],
    ),
    PpPage(
      id: 'mont_follow_the_child',
      title: 'Following what your child already loves',
      format: 'SHORT ARTICLE',
      bands: _fromOne,
      blocks: [
        PpIntro('Four days spent opening and closing the gate? That is the '
            'lesson plan. You don\'t have to invent one.'),
        PpArticle([
          'Small children go through phases of intense interest in one thing: '
          'opening and shutting, putting things inside other things, throwing, '
          'lining objects up, carrying heavy loads about. Each phase is a piece '
          'of development running itself.',
          'Following the child means noticing the phase and offering more of '
          'it, in a form you can live with. A child throwing everything needs '
          'to throw. Offer a basket of rolled socks and a target, rather than '
          'trying to stop the throwing.',
        ], heading: 'What it means'),
        PpSteps([
          PpStep('Watch for three days without steering',
              'Note what your child goes back to. That repetition is the '
              'signal.'),
          PpStep('Name the urge underneath, not the object',
              'Not obsessed with the gate. Interested in things that open and '
              'shut.'),
          PpStep('Offer two or three more things that feed the same urge',
              'Tins with lids, a door hook, a purse with a zip, a posting '
              'box.'),
          PpStep('Let the phase run out on its own',
              'It will end suddenly and be replaced. Trying to stretch it once '
              'it is over is pointless.'),
        ], heading: 'How to follow it'),
        PpCards([
          PpCard('Deciding what your child must be interested in this week',
              'A plan you made is easier for you and far less absorbing for '
              'your child.'),
          PpCard('Worrying the interest is too narrow',
              'Deep and repetitive is how young children learn. Breadth comes '
              'later on its own.'),
        ], heading: 'What to avoid', hue: 160),
        PpWhenLine('From about ten months onwards. The phases are most obvious '
            'and most intense between one and three.'),
        PpLink(
          'What is developing at your child\'s age right now',
          surfaceId: 'pp_development',
          blurb: 'Milestones and leaps, which often explain the current phase.',
        ),
        PpConsult(
          title: 'The early learning masterclass',
          whoFor: 'For a parent who wants the whole picture in one sitting. '
              'how learning through play works at home, and how to answer '
              'relatives who think a child must be writing by now.',
          surfaceId: 'pp_courses',
          role: 'early_learning',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  DOOR 3 - The stories
// -----------------------------------------------------------------------------
//  MORAL STORIES IS THE BIGGEST SINGLE CONTENT MAGNET IN THE PARENTING STAGE,
//  around 27,100 searches a month. It is also the cell most often shipped as a
//  list of titles that open nothing, which is exactly what the review objected
//  to.
//
//  So every story here is a real page with the story written out on it. Six
//  collections, each its own area so a parent browses the way she thinks
//  ("Panchatantra" is a thing she is looking for, "story library" is not).
//
//  THE SECULAR RULE, STATED ONCE AND APPLIED EVERYWHERE. These tales come from
//  Buddhist, Hindu and Mughal-court sources, and they are told here as stories
//  about behaviour, not as religious instruction. A Jataka tale is a tale about
//  a monkey who saves his troop. No verse, no deity, no doctrine, nothing a
//  family of any faith or none would hesitate to read at bedtime. The demand
//  data supports this decisively: moral stories around 27,100, scripture around
//  480.
//
//  AGE GATING. Bedtime tales open from about one year. The full collections
//  carry from two and a half, and the discussion question on each is written for
//  a child of three and over. A younger child hears the same story and enjoys
//  the animals, which is the correct amount of moral instruction for a
//  two-year-old.
//
//  AUDIO ON EVERY STORY. The slot ids are declared now so the narration files
//  land in known places. The Hindi voice work reuses the existing narration
//  service rather than anything new here.
// =============================================================================

const PpArea _storyTime = PpArea(
  id: 'story_time',
  mark: IntentMark.moonMark,
  title: 'Telling a story tonight',
  blurb: 'How to read to a baby, how to tell a story with no book, and what to '
      'say afterwards.',
  hue: 268,
  pages: [
    PpPage(
      id: 'story_to_a_baby',
      title: 'Reading to a baby who cannot understand a word',
      format: 'SHORT ARTICLE',
      bands: ['baby', 'one'],
      blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'How to tell a story to a baby who cannot talk yet',
          subtitle: 'Voice, pace and the pauses. It is less about the story than about the back-and-forth.',
          minutes: '4 MIN',
          slotId: 'early_learning/telling_a_story',
        ),
        PpIntro('Your baby won\'t follow the plot, and that is fine. What your '
            'baby gets is your voice, your closeness and the shape of language.'),
        PpArticle([
          'A baby read to daily hears thousands more words than one who is not. '
          'Book language is different from everyday speech. Books use words '
          'you would never say while cooking, and that is exactly their value.',
          'Expect chewing, three pages turned at once and lost interest after '
          'ninety seconds. All of that is normal, and none of it means it is '
          'not working.',
        ], heading: 'Why it is worth doing this early'),
        PpSteps([
          PpStep('Choose board books or cloth books', 'They survive being '
              'eaten, which paper does not.'),
          PpStep('Sit your baby on your lap, facing both you and the page'),
          PpStep('Skip the words if your baby is not interested in them',
              'Point at pictures and talk about them instead. That counts '
              'fully as reading together.'),
          PpStep('Use a lot of voice',
              'High, low, slow, a whisper. Your voice is doing most of the '
              'work.'),
          PpStep('Stop the moment your baby squirms',
              'Two minutes a day for a year beats twenty minutes once.'),
        ], heading: 'How to do it'),
        PpWhenLine('From birth. Newborns settle to a read-aloud voice, and by '
            'six months your baby will reach for the book.'),
        PpIndiaNote('Reading in the language you are most at ease in beats '
            'reading in English badly. A warm, fluent Hindi voice gives your '
            'baby more language than a hesitant English one.'),
        PpLink(
          'Books for this age',
          surfaceId: 'pp_read',
          blurb: 'What makes a board book worth having.',
        ),
      ],
    ),
    PpPage(
      id: 'story_telling_no_book',
      title: 'Telling a story with no book at all',
      format: 'STEP-LIST',
      bands: _fromOne,
      blocks: [
        PpIntro('At this age a told story beats a read one. You can watch your '
            'child\'s face and change the story to suit it. And you can do it '
            'in the dark.'),
        PpSteps([
          PpStep('Put your child in the story',
              'Once there was a child called Arjun who had a red cycle. Use your '
              'child\'s name and attention doubles at once.'),
          PpStep('Keep it to three things that happen',
              'Arjun went out, met a dog, and they came home. That is a '
              'complete story for a two-year-old.'),
          PpStep('Use sounds rather than description',
              'The gate went creeeak. The dog went woof woof. Sounds are what '
              'a small child follows.'),
          PpStep('Slow down and drop your voice as it ends',
              'For a bedtime story, the last three sentences are almost a '
              'whisper.'),
          PpStep('Tell the same story again tomorrow, the same way',
              'Repetition is what small children want. Changing details will '
              'be objected to, loudly.'),
        ], heading: 'How to tell one'),
        PpCards([
          PpCard('Making it too long', 'Three minutes is a long story at two.'),
          PpCard('Making it a lesson', 'A story with a moral pinned on the end '
              'every night stops being a treat and starts being a lecture.'),
          PpCard('Refusing to repeat it', 'The fortieth telling does more for '
              'your child than the first did.'),
        ], heading: 'What to avoid', hue: 268),
        PpWhenLine('From about eighteen months for a very simple told story. '
            'By three, your child will want to tell you one back.'),
      ],
    ),
    PpPage(
      id: 'story_talking_after',
      title: 'What to say when the story ends',
      format: 'SHORT ARTICLE',
      bands: _fromThree,
      blocks: [
        PpIntro('The lesson in a story does not land by being announced. It '
            'lands in the two minutes of talking afterwards, if that talk is a '
            'conversation rather than a test.'),
        PpArticle([
          'A story that ends with, and the moral is that we must always be '
          'honest, teaches a child to recognise the sentence, not the idea. '
          'Asking what would you have done makes your child do the thinking. '
          'Thinking is what changes behaviour.',
          'Every story page in this door carries one question at the bottom for '
          'exactly this reason. One question is enough. Two becomes an exam.',
        ], heading: 'Why the question matters more than the moral'),
        PpSteps([
          PpStep('Ask one open question, then stay silent',
              'Why do you think the jackal did that? Wait through the silence. '
              'It is longer than feels comfortable.'),
          PpStep('Accept the answer even when it is odd',
              'A four-year-old may side with the crocodile. Ask why rather than '
              'correcting.'),
          PpStep('Connect it to something real, lightly',
              'That is a bit like what happened with your cousin, no? One '
              'sentence, not a speech.'),
          PpStep('Let it go if your child does not want to talk',
              'The story has still done its work. Children think about a story '
              'even when they won\'t discuss it.'),
        ], heading: 'How to do it'),
        PpCards([
          PpCard('Turning it into a test',
              'What was the moral, tell me properly, is the fastest way to end '
              'your child\'s love of stories.'),
          PpCard('Using the story as a telling-off',
              'You are just like that greedy jackal turns the story into a '
              'weapon. That is what your child will remember, not the tale.'),
        ], heading: 'What to avoid', hue: 268),
        PpWhenLine('From about three years, once your child can answer a why. '
            'Before that, just tell the story and stop.'),
      ],
    ),
  ],
);

// =============================================================================
//  Collection 1 - Little bedtime tales
// -----------------------------------------------------------------------------
//  Deliberately the gentlest collection: nothing happens, nobody is tricked,
//  nobody learns a hard lesson. A one-year-old does not need a moral, he needs
//  the same soft shape every night, and a story written to slow a child down is
//  a different craft from a story written to teach one.
// =============================================================================

const PpArea _bedtimeTales = PpArea(
  id: 'bedtime_tales',
  mark: IntentMark.listMark,
  title: 'Little bedtime tales',
  blurb: 'Ten very short, very calm stories for the last ten minutes of the '
      'day. From about one year.',
  hue: 232,
  bands: _earlyYears,
  pages: [
    PpPage(
      id: 'st_bed_sleepy_elephant',
      title: 'The sleepy little elephant',
      subtitle: 'Little bedtime tales',
      format: 'STORY',
      blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'The sleepy elephant, read aloud',
          subtitle: 'A calm bedtime reading to listen to together, or to borrow the pace from.',
          minutes: '6 MIN',
          slotId: 'early_learning/read_bedtime',
        ),
        PpIntro('A very short story about being tired and being carried home. '
            'About two minutes to tell.'),
        PpArticle([
          'There was once a little elephant who played all day by the river. He '
          'splashed. He rolled in the mud. He sprayed water on his own back and '
          'then on his mother, who did not mind at all.',
          'When the sun went down and the sky turned orange, the little '
          'elephant found that his legs had gone slow. Very, very slow. He took '
          'one step, and then another, and then he sat down in the warm sand.',
          'His mother came and stood beside him, big and grey and patient. She '
          'curled her trunk around him gently, the way she always did, and she '
          'said, come, we will go slowly.',
          'So they walked home together in the last of the light, past the tall '
          'grass and the sleeping birds. By the time they reached the '
          'trees, the little elephant was already dreaming about the river.',
        ]),
        PpCards([
          PpCard('The gentle idea in it',
              'Being tired is fine, and somebody is always there to walk you '
              'home.'),
          PpCard('How to tell it',
              'Slow right down at the third paragraph, and almost whisper the '
              'last one.'),
        ], heading: 'Before you switch off the light', hue: 232),
        PpWhenLine('From about one year. It works right up to four.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Bedtime tale',
          minutes: '2 MIN',
          slotId: 'learning/story/bed_sleepy_elephant',
        ),
      ],
    ),
    PpPage(
      id: 'st_bed_goodnight_house',
      title: 'Goodnight to everything in the house',
      subtitle: 'Little bedtime tales',
      format: 'STORY',
      blocks: [
        PpIntro('A saying-goodnight story you can stretch or shorten to fit the '
            'exact number of minutes you have left.'),
        PpArticle([
          'When it was time to sleep, the little girl did not want to go. So '
          'her mother said, all right, but first we must say goodnight to '
          'everything, or how will they know it is night?',
          'So they said goodnight to the fan, going round and round more slowly '
          'now. Goodnight to the shoes by the door, lined up and waiting for '
          'the morning. Goodnight to the steel glasses, standing in a row.',
          'They said goodnight to the basil plant on the balcony, and to the street '
          'light outside. They said goodnight to the dog who lives near the '
          'gate. He was already asleep with his nose under his tail.',
          'And then they said goodnight to her toes, and her knees, and her '
          'hands, and her eyes. And by the time they reached her eyes, they '
          'were already closed.',
        ]),
        PpCards([
          PpCard('The gentle idea in it',
              'The day ends for everything, and ending it is peaceful rather '
              'than a loss.'),
          PpCard('How to tell it',
              'Use the real things in your own house. Say goodnight to your '
              'child\'s own shoes and your own fan.'),
        ], heading: 'Before you switch off the light', hue: 232),
        PpWhenLine('From about one year, and it becomes your child\'s own '
            'routine by two.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Bedtime tale',
          minutes: '2 MIN',
          slotId: 'learning/story/bed_goodnight_house',
        ),
      ],
    ),
    PpPage(
      id: 'st_bed_moon_follows',
      title: 'The moon that followed us home',
      subtitle: 'Little bedtime tales',
      format: 'STORY',
      blocks: [
        PpIntro('A story about the thing every child notices from a moving car '
            'or a scooter, and finds a little bit wonderful.'),
        PpArticle([
          "One night, a boy was coming home on the back of his Papa's scooter, "
          'holding on tight with both arms. He looked up and saw the moon '
          'sitting in the sky like a piece of chalk.',
          'They turned left at the big tree. The moon turned left too. They '
          'went past the vegetable market, all shut up for the night, and the moon '
          'came past the vegetable market as well.',
          'The boy said, Papa, the moon is following us. And his father said, '
          'yes, it does that. It walks people home.',
          'When they stopped at their own gate, the moon stopped too, resting '
          'just above the water tank. The boy waved at it. And when he lay down '
          'in his bed, he could still see it through the window, waiting there '
          'until he fell asleep.',
        ]),
        PpCards([
          PpCard('The gentle idea in it',
              'Something bright keeps watch, even after the lights go '
              'off.'),
          PpCard('How to tell it',
              'Look at the moon together on the way home first. The story means '
              'much more the same night.'),
        ], heading: 'Before you switch off the light', hue: 232),
        PpWhenLine('From about two years, when your child starts noticing the '
            'moon.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Bedtime tale',
          minutes: '2 MIN',
          slotId: 'learning/story/bed_moon_follows',
        ),
      ],
    ),
    PpPage(
      id: 'st_bed_sparrow_nest',
      title: 'The little sparrow who came home',
      subtitle: 'Little bedtime tales',
      format: 'STORY',
      blocks: [
        PpIntro('A story about a small bird, a big day, and a nest waiting at '
            'the end of it.'),
        PpArticle([
          'High up under the balcony, behind the old air conditioner, there was '
          'a nest made of twigs and thread and one piece of a plastic bag. In '
          'it lived a very small sparrow called Chuk.',
          'One morning Chuk flew further than she had ever flown. She flew over '
          'the terrace where the clothes were drying. She flew past the neem '
          'tree, which was full of loud green parrots. She flew all the way to '
          'the shop at the corner and sat on the awning, watching everybody buy '
          'their bread.',
          'But when the sky began to go dark, Chuk felt something in her small '
          'chest that meant it was time. So she turned around and flew back the '
          'way she had come, past the neem tree, over the drying clothes.',
          'And there was the balcony, and the old air conditioner, and the '
          'nest, exactly where she had left it. She hopped in, tucked her head '
          'under her wing, and slept.',
        ]),
        PpCards([
          PpCard('The gentle idea in it',
              'You can go a long way out and home stays exactly where it was.'),
          PpCard('How to tell it',
              'Good for a child starting playschool. The going out and the '
              'coming back is the whole point.'),
        ], heading: 'Before you switch off the light', hue: 232),
        PpWhenLine('From about two years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Bedtime tale',
          minutes: '2 MIN',
          slotId: 'learning/story/bed_sparrow_nest',
        ),
      ],
    ),
    PpPage(
      id: 'st_bed_puppy_blanket',
      title: 'Moti finds his blanket',
      subtitle: 'Little bedtime tales',
      format: 'STORY',
      blocks: [
        PpIntro('A looking-for-something story, which is the easiest kind for a '
            'small child to join in with.'),
        PpArticle([
          'Moti was a brown puppy with one white ear, and he could not sleep, '
          'because his blanket was gone.',
          'He looked under the bed. There was a slipper there, and a lot of '
          'dust, but no blanket. He looked behind the door. There was a bucket '
          'there, but no blanket. He looked in the kitchen, and found only a '
          'very surprised cockroach, who ran away.',
          'He looked and he looked until his legs were tired. And then he went '
          'and sat down in his own basket to think about it. And do you know '
          'what he was sitting on?',
          'His blanket. It had been in his basket the whole time, exactly where '
          'a blanket should be. Moti turned around three times, the way dogs '
          'do, and lay down on it, and did not think about anything else at '
          'all.',
        ]),
        PpCards([
          PpCard('The gentle idea in it',
              'What you are looking for is often already where it belongs.'),
          PpCard('How to tell it',
              'Let your child guess where the blanket is at each stop. Expect '
              'the answer shouted long before the end.'),
        ], heading: 'Before you switch off the light', hue: 232),
        PpWhenLine('From about eighteen months.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Bedtime tale',
          minutes: '2 MIN',
          slotId: 'learning/story/bed_puppy_blanket',
        ),
      ],
    ),
    PpPage(
      id: 'st_bed_one_more_story',
      title: 'The cat who wanted one more story',
      subtitle: 'Little bedtime tales',
      format: 'STORY',
      blocks: [
        PpIntro('A story about the exact thing your child is about to ask for, '
            'which is why it works so well.'),
        PpArticle([
          'There was a small grey cat who lived on a windowsill, and every '
          'night when the story ended, she said, one more.',
          'So her mother told her one more, about a fish. And at the end of it '
          'the small grey cat said, one more. So her mother told her one more, '
          'about a bird who was rude to a bus. And at the end of that one, the '
          'small grey cat said, one more.',
          'Her mother said, all right, the last one. And this story was about a '
          'small grey cat who lived on a windowsill. She was warm, and full of '
          'milk, and safe, and her eyes were getting heavier and heavier and '
          'heavier.',
          'And that story was so good that the small grey cat did not hear the '
          'end of it.',
        ]),
        PpCards([
          PpCard('The gentle idea in it',
              'The last story is a nice place to stop, not something taken away '
              'from you.'),
          PpCard('How to tell it',
              'Say the last paragraph very slowly. It is written to be the '
              'thing that ends the night.'),
        ], heading: 'Before you switch off the light', hue: 232),
        PpWhenLine('From about two years, and it is most useful with a child '
            'who negotiates at bedtime.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Bedtime tale',
          minutes: '2 MIN',
          slotId: 'learning/story/bed_one_more_story',
        ),
      ],
    ),
    PpPage(
      id: 'st_bed_tired_auto',
      title: 'The tired little auto',
      subtitle: 'Little bedtime tales',
      format: 'STORY',
      blocks: [
        PpIntro('For the child who loves anything with wheels. A busy day, and '
            'then a quiet parking spot.'),
        PpArticle([
          'The little yellow and green auto worked all day. In the morning he '
          'took a girl to school, and she sang the whole way. At lunchtime he '
          'took a man with two enormous bags of onions, and the bags kept '
          'trying to fall out.',
          'In the afternoon he took a grandmother to the doctor, very slowly, '
          'over all the speed breakers, so carefully that she did not feel a '
          'single one.',
          'In the evening the sky went pink and all the horns were shouting at '
          'each other. He took two brothers home from cricket, with '
          'the bat sticking straight out of the side.',
          'Then the driver parked him under the big tree near the gate, and '
          'switched off his lights, and patted his roof once. And the little '
          'auto sat there in the dark, not going anywhere at all, which was '
          'exactly what he wanted.',
        ]),
        PpCards([
          PpCard('The gentle idea in it',
              'After a busy day, stopping is a good thing and not a boring '
              'one.'),
          PpCard('How to tell it',
              'Do the horn sounds in the middle and then take them all away at '
              'the end. The quiet does the work.'),
        ], heading: 'Before you switch off the light', hue: 232),
        PpWhenLine('From about two years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Bedtime tale',
          minutes: '2 MIN',
          slotId: 'learning/story/bed_tired_auto',
        ),
      ],
    ),
    PpPage(
      id: 'st_bed_ten_toes',
      title: 'Ten little toes go to sleep',
      subtitle: 'Little bedtime tales',
      format: 'STORY',
      blocks: [
        PpIntro('A counting-down story that ends with a child already still. '
            'Touch each part as you say it.'),
        PpArticle([
          'First the toes went to sleep, all ten of them, one after the other. '
          'Then the feet went to sleep, and then the legs, which had run about '
          'quite enough for one day.',
          'The tummy went to sleep, full of dinner. The back went to sleep '
          'against the sheet. The hands went to sleep, and they did not want to '
          'hold anything at all.',
          'The shoulders went to sleep, and dropped down soft. The mouth went '
          'to sleep and stopped talking, even though it had a lot more it '
          'wanted to say.',
          'And last of all, the eyes went to sleep. And the whole child was '
          'asleep, from the toes right up to the top of the head.',
        ]),
        PpCards([
          PpCard('The gentle idea in it',
              'A tired body can let go of the day, one part at a time.'),
          PpCard('How to tell it',
              'Touch each part very lightly as you name it, and get quieter '
              'with every paragraph.'),
        ], heading: 'Before you switch off the light', hue: 232),
        PpWhenLine('From about eighteen months, and it stays useful for years '
            'as a settling routine.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Bedtime tale',
          minutes: '2 MIN',
          slotId: 'learning/story/bed_ten_toes',
        ),
      ],
    ),
    PpPage(
      id: 'st_bed_rain_on_roof',
      title: 'The night it rained on the roof',
      subtitle: 'Little bedtime tales',
      format: 'STORY',
      blocks: [
        PpIntro('A story for a rainy night, about being dry and warm while '
            'something loud happens outside.'),
        PpArticle([
          'It started with one drop on the roof. Tup. Then another one. Tup. '
          'And then all of them at once, tup tup tup tup tup, until the roof '
          'was singing.',
          'Outside, the water ran down the drainpipe and made a small river '
          'along the side of the road. The neem tree got a wash. The dusty '
          'scooter got a wash. Even the crow on the wall got a wash, which he '
          'had not asked for at all.',
          'But inside, it was dry. The blanket was warm. The window was shut, '
          'with just enough of a gap to let in that smell the mud makes when '
          'the first rain hits it.',
          'And the boy lay in his bed and listened to the roof singing. He '
          'thought it was a very good thing to be inside, until he was not '
          'thinking anything at all.',
        ]),
        PpCards([
          PpCard('The gentle idea in it',
              'Loud things outside are interesting when you are safe inside.'),
          PpCard('How to tell it',
              'Do the tup tup with your fingers on the bed. Then slow them '
              'down until they stop.'),
        ], heading: 'Before you switch off the light', hue: 232),
        PpWhenLine('From about eighteen months. Best told on an actual rainy '
            'night.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Bedtime tale',
          minutes: '2 MIN',
          slotId: 'learning/story/bed_rain_on_roof',
        ),
      ],
    ),
    PpPage(
      id: 'st_bed_star_waited',
      title: 'The star that waited',
      subtitle: 'Little bedtime tales',
      format: 'STORY',
      blocks: [
        PpIntro('The last story in this collection, and the quietest. Very '
            'little happens, on purpose.'),
        PpArticle([
          'There was a star that came out early, before all the others, when '
          'the sky was still a little bit blue.',
          'It waited while the birds went into the trees and stopped arguing. '
          'It waited while the shops pulled their shutters down, one after '
          'another, with a rattle. It waited while the last scooter went home '
          'and the road went quiet.',
          'It waited while a small child had her dinner, and had her bath, and '
          'brushed her teeth. It waited while she put on her night clothes, got '
          'into bed and heard a story.',
          'And when at last she closed her eyes, the star was still there, '
          'shining away very calmly, keeping the sky lit up until the morning '
          'came back.',
        ]),
        PpCards([
          PpCard('The gentle idea in it',
              'Something steady is there through the night, whether or not '
              'anyone is awake to see it.'),
          PpCard('How to tell it',
              'This one is written to be told almost in a whisper the whole way '
              'through.'),
        ], heading: 'Before you switch off the light', hue: 232),
        PpWhenLine('From about one year.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Bedtime tale',
          minutes: '2 MIN',
          slotId: 'learning/story/bed_star_waited',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  Collection 2 - Panchatantra
// -----------------------------------------------------------------------------
//  The oldest and most searched of the Indian collections. Told here as animal
//  stories about thinking clearly, keeping friends and not being greedy. The
//  frame story of a teacher and three princes is left out entirely: it is the
//  part children never remember and the part that makes the collection sound
//  like a syllabus.
// =============================================================================

const PpArea _panchatantra = PpArea(
  id: 'panchatantra',
  mark: IntentMark.schoolMark,
  title: 'Panchatantra stories',
  blurb: 'Twelve of the best known, told plainly. Cleverness, friendship and '
      'the cost of greed. From about two and a half.',
  hue: 28,
  bands: _fromTwo,
  pages: [
    PpPage(
      id: 'st_pan_monkey_crocodile',
      title: 'The monkey and the crocodile',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'The monkey and the crocodile, told properly',
          subtitle: 'The Panchatantra story as a grandmother tells it, not as a summary.',
          minutes: '7 MIN',
          slotId: 'early_learning/read_panchatantra',
        ),
        PpIntro('A story about a friendship, a betrayal, and a monkey who keeps '
            'his head when he most needs it. About four minutes.'),
        PpArticle([
          'On the bank of a wide river stood a jamun tree, and in it lived a '
          'monkey. Every day a crocodile swam up to rest in its shade, and '
          'every day the monkey threw down sweet purple jamuns for him. They '
          'became great friends.',
          'The crocodile began carrying some fruit home to his wife. She ate '
          'them and thought, if the fruit is this sweet, the heart of the '
          'monkey who eats them all day must be sweeter still. And she told her '
          'husband she would not be happy until she had eaten it.',
          'The crocodile was ashamed, but he did as she asked. He invited the '
          'monkey to his home across the water, and the monkey climbed happily '
          'onto his back. Halfway across, feeling wretched, the crocodile '
          'admitted why they were going.',
          'The monkey did not shout or struggle. He said, oh, why did you not '
          'say so earlier? We monkeys keep our hearts hanging in the tree while '
          'we travel. Take me back and I will fetch mine. The crocodile turned '
          'around at once, and the moment they touched the bank the monkey '
          'sprang into the branches and stayed there. He never came down for '
          'that crocodile again.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'A clear head is worth more than a strong body, and a friend who '
              'plans to hurt you is not a friend.'),
          PpCard('Talk about it',
              'The monkey was frightened but he did not shout. What did he do '
              'instead?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about three years. Younger children enjoy it as a '
            'river-and-animals story without the betrayal registering.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '4 MIN',
          slotId: 'learning/story/pan_monkey_crocodile',
        ),
      ],
    ),
    PpPage(
      id: 'st_pan_lion_rabbit',
      title: 'The lion and the clever rabbit',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        PpIntro('The smallest animal in the forest solves a problem the biggest '
            'ones could not. Four minutes, with a very satisfying ending.'),
        PpArticle([
          'A lion lived in a forest and killed far more animals than he needed. '
          'At last the animals came to him with a bargain. Leave us in '
          'peace, and one of us will come to you every day, so you need never '
          'hunt again. The lion agreed.',
          'Each day one animal walked sadly to the lion. Then came the turn of '
          'a small rabbit, who took his time on the road and arrived very late.',
          'The lion was roaring with hunger. The rabbit said, forgive me, I set '
          'out early, but on the way another lion stopped me and said this '
          'forest belonged to him. The lion demanded to be taken to this rival '
          'at once.',
          'The rabbit led him to a deep old well and said, he lives down there. '
          'The lion looked over the edge and saw a furious lion staring back up '
          'at him. He roared, and the other roared back. He leapt in to fight '
          'him, and that was the end of him. The rabbit walked home, and the '
          'forest was quiet again.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Being clever can protect you when being strong cannot.'),
          PpCard('Talk about it',
              'Who was really in the well? Why did the lion not work it out?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about three years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '4 MIN',
          slotId: 'learning/story/pan_lion_rabbit',
        ),
      ],
    ),
    PpPage(
      id: 'st_pan_blue_jackal',
      title: 'The blue jackal',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        PpIntro('A jackal falls into a tub of dye and decides to become a king. '
            'A funny story with a sharp point in it.'),
        PpArticle([
          'A hungry jackal wandered into a town, was chased by dogs, and to '
          'escape them jumped over a wall into a dyer yard. He landed in a '
          'great tub of blue dye and came out the colour of the evening sky.',
          'Back in the forest, no animal recognised him. The lion, the tiger '
          'and the elephant all stared at this strange blue creature. The '
          'jackal saw his chance and announced that he had been sent to rule '
          'over them all.',
          'The animals believed him. They brought him food, they fanned him, '
          'they called him king. He grew grand and lazy, and he sent all the '
          'other jackals away, because they made him nervous.',
          'One evening a pack of jackals began to howl in the distance, as '
          'jackals do at dusk. Without thinking, he lifted his head and howled '
          'back. Every animal there knew that sound. They saw exactly what he '
          'was under the blue, and he had to run for his life.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'You can change your colour but not what you are, and pretending '
              'gets tiring.'),
          PpCard('Talk about it',
              'What gave the jackal away in the end? Why could he not stop '
              'himself?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about three years. The blue jackal is a favourite '
            'picture to draw afterwards.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '4 MIN',
          slotId: 'learning/story/pan_blue_jackal',
        ),
      ],
    ),
    PpPage(
      id: 'st_pan_four_friends',
      title: 'The four friends',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        PpIntro('A crow, a mouse, a tortoise and a deer, and what four very '
            'different friends can do that one animal cannot.'),
        PpArticle([
          'A crow, a mouse and a tortoise lived beside a lake and were close '
          'friends. One day a deer came crashing through the trees, terrified, '
          'with a hunter behind her. The friends hid her and she stayed.',
          'Some days later the deer did not return. The crow flew up and up '
          'and saw her from the sky, caught fast in a hunter net at the far end '
          'of the field.',
          'The crow carried the mouse there in his beak, and the mouse set to '
          'work with his small sharp teeth on the ropes. But the tortoise, who '
          'was slow, had followed on foot to help, and when the hunter came '
          'back he found the deer free and the tortoise there instead. He tied '
          'the tortoise up and set off home.',
          'Then the deer lay down in the road and played dead, and the crow '
          'stood on her and pecked at her as if she were finished. The hunter '
          'put down his bundle to fetch this easy meat. The mouse bit through '
          'the last rope, the deer leapt up, and all four ran back to the lake '
          'together.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Friends who are good at different things can get each other out '
              'of almost anything.'),
          PpCard('Talk about it',
              'What was each animal good at? What are you good at that your '
              'friend is not?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about three and a half. It has four characters, which '
            'is a lot to hold before that.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '5 MIN',
          slotId: 'learning/story/pan_four_friends',
        ),
      ],
    ),
    PpPage(
      id: 'st_pan_talkative_tortoise',
      title: 'The talkative tortoise',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        PpIntro('A tortoise flies through the air holding on to a stick. It '
            'goes wrong for a reason every child understands.'),
        PpArticle([
          'A tortoise lived in a pond with two geese for friends. He talked '
          'constantly and could never keep quiet for long, but the geese were '
          'fond of him anyway.',
          'One summer the pond began to dry up. The geese said they would fly '
          'to a bigger lake, and the tortoise begged to come. So they thought '
          'of a plan. The geese would hold the two ends of a stick in their '
          'beaks, and the tortoise would bite the middle and hold on tight. But '
          'he must not open his mouth, not once, not for anything.',
          'Up they went. People in the village below looked up and pointed and '
          'shouted, look at that, a flying tortoise, what a strange thing, who '
          'thought of that.',
          'The tortoise heard them saying it and could not bear it. He opened '
          'his mouth to tell them it had been his idea, and of course he fell. '
          'The geese circled sadly above him, and the tortoise learned, rather '
          'painfully, that there are moments to speak and moments to hold on.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Knowing when not to speak is its own kind of cleverness.'),
          PpCard('Talk about it',
              'Why could the tortoise not stay quiet? Is that hard for you '
              'sometimes too?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about three years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '4 MIN',
          slotId: 'learning/story/pan_talkative_tortoise',
        ),
      ],
    ),
    PpPage(
      id: 'st_pan_three_tricksters',
      title: 'The man, the goat and the three tricksters',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        PpIntro('Three men tell one man the same lie, one after another, and he '
            'ends up believing them over his own eyes.'),
        PpArticle([
          'A man bought a healthy goat at the market and set off home with it '
          'across his shoulders. Three tricksters saw him and wanted the goat, '
          'so they made a plan and spread themselves out along the road.',
          'The first stepped out and said, sir, why is a respectable man like '
          'you carrying a dog on your shoulders? The man said it was a goat, '
          'and walked on, annoyed.',
          'A little further, the second said, sir, that is a dog you are '
          'carrying. The man stopped and looked at his goat. It looked like a '
          'goat. But he began to feel uneasy.',
          'When the third man said the same thing, the man was sure something '
          'strange had happened. He put the goat down and hurried away from it, '
          'and the three tricksters ate very well that night. He had trusted '
          'three strangers who agreed with each other more than he trusted his '
          'own two eyes.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Something is not true just because several people say it. Check '
              'for yourself.'),
          PpCard('Talk about it',
              'How did the man know it was a goat? What should he have done '
              'when the third man spoke?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about four years. This one needs enough age to enjoy '
            'knowing more than the character does.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '4 MIN',
          slotId: 'learning/story/pan_three_tricksters',
        ),
      ],
    ),
    PpPage(
      id: 'st_pan_crows_snake',
      title: 'The crows and the snake',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        PpIntro('Two small birds cannot fight a snake, so they arrange for '
            'somebody much larger to do it for them.'),
        PpArticle([
          'A pair of crows built their nest in a tall tree, and in a hollow at '
          'the foot of that tree lived a black snake. Every time the crows had '
          'eggs, the snake climbed up and ate them, and the crows could do '
          'nothing at all about it.',
          'They went to their friend the old jackal and told him their trouble. '
          'The jackal thought for a while and said, you cannot beat him with '
          'your beaks. You will have to use somebody else.',
          'So the next morning the mother crow flew to the lake where the queen '
          'and her women were bathing. She snatched a gold necklace from the '
          'bank and flew away slowly, cawing loudly, making quite sure the '
          'guards saw her go.',
          'The guards ran after her with sticks. She dropped the necklace '
          'neatly into the hollow at the foot of the tree. The guards reached '
          'in for it, found the black snake, and dealt with him then and there. '
          'The crows raised their next family in peace.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'When you cannot solve a problem by force, a good plan and good '
              'advice will do it.'),
          PpCard('Talk about it',
              'Why did the crows ask the jackal instead of fighting the snake?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about four years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '4 MIN',
          slotId: 'learning/story/pan_crows_snake',
        ),
      ],
    ),
    PpPage(
      id: 'st_pan_iron_scales',
      title: 'The mice that ate the iron scales',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        PpIntro('A merchant tells a ridiculous lie, and gets an equally '
            'ridiculous lie straight back. Children find this one very funny.'),
        PpArticle([
          'A young trader, going away on business, left his heavy iron weighing '
          'scales with a rich merchant for safe keeping. When he came back, he '
          'asked for them.',
          'The merchant said, I am very sorry, the mice ate them. Iron is a '
          'great favourite with the mice in this house. The young man knew '
          'exactly what had happened to his scales, but he only nodded and said '
          'what a pity.',
          "A little later he offered to take the merchant's small son to the "
          'river for a bath, and the merchant agreed. He came back alone, '
          'looking very sad, and said, a hawk swooped down and carried your boy '
          'away.',
          'The merchant shouted that no hawk could carry off a boy. The young '
          'man said, in a place where mice can eat iron scales, a hawk can '
          'certainly carry off a boy. The merchant went red, fetched the '
          'scales, and got his son back the same hour.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'A lie is easiest to answer with the same lie told back, and '
              'honesty saves a great deal of trouble.'),
          PpCard('Talk about it',
              'How did the young man make the merchant see what he had done?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about four and a half. The joke needs a child who can '
            'hold both halves of it.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '4 MIN',
          slotId: 'learning/story/pan_iron_scales',
        ),
      ],
    ),
    PpPage(
      id: 'st_pan_hare_elephants',
      title: 'The hare and the elephants',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        PpIntro('A herd of elephants is trampling the hares. One small hare '
            'talks them into leaving, using nothing but the moon.'),
        PpArticle([
          'There was a long dry spell, and a herd of elephants came looking for '
          'water. They found a lake in the middle of the sandy ground where '
          'hundreds of hares had their burrows. Going to and from it, '
          'they crushed many burrows and many hares.',
          'The hares did not know what to do. Then a small hare called Vijay '
          'said he would go and speak to them, and off he went alone.',
          'He climbed onto a high rock where the elephant king could see him '
          'and said, I am the messenger of the moon, and the moon is angry. '
          'That lake belongs to him, and your herd has muddied it and '
          'frightened the hares, who are his own creatures.',
          'The elephant king went to the lake that night to apologise. The '
          'water was still, and the moon lay perfectly on its surface. But when '
          'he dipped his trunk in to touch it, the water shivered and the moon '
          'broke into pieces. See, said the little hare, now he is angrier '
          'still. The elephants went away and never came back.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'A small creature with a plan can move a very large problem.'),
          PpCard('Talk about it',
              'Why did the moon break when the elephant touched the water?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about four years. Try it on a full moon night with a '
            'bucket of water afterwards.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '4 MIN',
          slotId: 'learning/story/pan_hare_elephants',
        ),
      ],
    ),
    PpPage(
      id: 'st_pan_two_headed_bird',
      title: 'The bird with two heads',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        PpIntro('One body, two heads, and a quarrel that neither of them can '
            'win. A short story with a very clear point.'),
        PpArticle([
          'There was once a strange bird with one body and two heads, who '
          'shared everything, including a stomach.',
          'One day the first head found a sweet golden fruit on the sand and '
          'began to eat it, sighing with pleasure. The second head asked for a '
          'taste. The first said, why? It all goes to the same stomach anyway. '
          'And it finished the fruit alone.',
          'The second head said nothing, but it did not forget. Some days '
          'later, it found a strange fruit growing near the water, and it knew '
          'the fruit was a poisonous one. It began to eat it.',
          'The first head cried out, stop, that will kill us both. The second '
          'head said, it all goes to the same stomach anyway. And of course it '
          'was quite right, and that was the end of them both.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'People who live together sink or swim together, so a small '
              'unkindness costs more than it seems to.'),
          PpCard('Talk about it',
              'What should the first head have done with the sweet fruit?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about four years. It is a good story for siblings who '
            'are refusing to share.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '3 MIN',
          slotId: 'learning/story/pan_two_headed_bird',
        ),
      ],
    ),
    PpPage(
      id: 'st_pan_donkey_tiger_skin',
      title: 'The donkey in the tiger skin',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        PpIntro('A donkey is dressed in a tiger skin so he can eat the '
            "villagers' crops at night. It works beautifully until he opens "
            'his mouth.'),
        PpArticle([
          'A washerman had a donkey who worked hard all day and was always '
          'hungry, because grain was expensive and there was little to spare.',
          'One day the washerman found an old tiger skin. He had an idea. At '
          'night he threw the skin over his donkey and let him loose in the '
          'green fields near the village. The farmers saw a tiger among their '
          'crops and ran, and the donkey ate his fill of young barley every '
          'night and grew fat and glossy.',
          'This went on happily for weeks. Then one night, from a nearby field, '
          'the donkey heard a she-donkey braying.',
          'He forgot everything. He lifted his head and brayed back at the top '
          'of his voice. Every farmer in the fields knew at once that their '
          'tiger was nothing but a donkey. They came with sticks, and that was '
          'the end of the good nights in the barley.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'A disguise only lasts until you behave like yourself, so it is '
              'simpler not to pretend.'),
          PpCard('Talk about it',
              'The donkey knew he had to be silent. Why do you think he brayed '
              'anyway?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about three and a half.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '4 MIN',
          slotId: 'learning/story/pan_donkey_tiger_skin',
        ),
      ],
    ),
    PpPage(
      id: 'st_pan_three_fishes',
      title: 'The three fishes',
      subtitle: 'Panchatantra',
      format: 'STORY',
      blocks: [
        PpIntro('Three fish hear the same warning. One acts, one waits, one '
            'refuses to believe it. A story about not putting things off.'),
        PpArticle([
          'In a quiet pond lived three fish. The first was a planner, the '
          'second was quick on his feet, and the third believed that whatever '
          'happened would happen and there was no use worrying.',
          'One evening some fishermen walked past and said to each other, that '
          'pond is full of fish, we will come back tomorrow with our nets.',
          'The first fish heard them and left that same night, swimming down '
          'the channel to the river while there was still time. The second fish '
          'said, tomorrow is far away, and stayed. The third said, ponds like '
          'this have been here forever, and went to sleep.',
          'The nets came at dawn. The second fish saw them, held his breath '
          'and floated on his side pretending to be dead. He was thrown back '
          'onto the bank, and from there he flapped his way to the river. The third '
          'fish was still explaining that nothing ever really happens when he '
          'was caught.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Doing the thing early is easier than doing it in a hurry, and '
              'much easier than not doing it at all.'),
          PpCard('Talk about it',
              'Which fish would you have been? Is there something you are '
              'leaving for tomorrow?'),
        ], heading: 'After the story', hue: 28),
        PpWhenLine('From about four years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Panchatantra',
          minutes: '4 MIN',
          slotId: 'learning/story/pan_three_fishes',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  Collection 3 - Jataka tales
// -----------------------------------------------------------------------------
//  SECULAR TELLING, AND THIS IS THE COLLECTION WHERE THAT DECISION IS MOST
//  VISIBLE. The Jatakas are Buddhist birth stories, and traditionally each one
//  ends by identifying an animal as the Buddha in a former life. That framing is
//  removed here completely. What is left is a set of unusually kind animal
//  stories about giving something up for somebody else, which is what a child
//  takes from them in any case.
// =============================================================================
const PpArea _jataka = PpArea(
  id: 'jataka',
  mark: IntentMark.compassMark,
  title: 'Jataka tales',
  blurb: 'Ten animal stories about kindness, courage and keeping a promise. '
      'The gentlest of the older collections.',
  hue: 100,
  bands: _fromTwo,
  pages: [
    PpPage(
      id: 'st_jat_monkey_bridge',
      title: 'The monkey king who made a bridge',
      subtitle: 'Jataka tales',
      format: 'STORY',
      blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'The monkey king who made himself the bridge',
          subtitle: 'A Jataka tale read aloud, with the ending left to sit.',
          minutes: '6 MIN',
          slotId: 'early_learning/read_jataka',
        ),
        PpIntro('A leader who puts himself last. One of the best known of these '
            'stories, and one of the kindest.'),
        PpArticle([
          'By a river grew an enormous mango tree, and in it lived a troop of '
          'monkeys with their king, who was the largest and strongest of them '
          'all. The mangoes were the sweetest anywhere.',
          'One day a mango fell into the river and floated down to the city, '
          'where it was found and carried to the king of that country. He '
          'tasted it and wanted the tree, and he came upriver with his men to '
          'take it.',
          'They found the tree full of monkeys and surrounded it. There was one '
          'way out, a leap to a tree on the far bank, too far for most of the '
          'troop. So the monkey king made that leap himself. He tied a long creeper '
          'to his feet and to the far tree, and found the creeper was a little '
          'too short. He stretched out his own body to make up the difference '
          'and held on.',
          'The whole troop ran across his back to safety, every one of them. '
          'The king of the country watched. When it was over, he had the '
          'monkey king lifted down gently and cared for. He said he had '
          'never seen anyone rule so well.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Being in charge of others means going last, not first.'),
          PpCard('Talk about it',
              'Why did the monkey king let everyone run over him? Was he '
              'brave?'),
        ], heading: 'After the story', hue: 100),
        PpWhenLine('From about four years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Jataka tales',
          minutes: '4 MIN',
          slotId: 'learning/story/jat_monkey_bridge',
        ),
      ],
    ),
    PpPage(
      id: 'st_jat_deer_river',
      title: 'The golden deer and the drowning man',
      subtitle: 'Jataka tales',
      format: 'STORY',
      blocks: [
        PpIntro('A deer saves a man from a river, and asks for one thing in '
            'return. A story about keeping your word.'),
        PpArticle([
          'Deep in a forest lived a deer whose coat shone like gold. He kept '
          'away from people, because a coat like that attracts hunters.',
          'One day he heard shouting from the river and saw a man being carried '
          'away by the water. The deer went in, took hold of him, and dragged '
          'him to the bank. The man wept with gratitude and asked how he could '
          'repay him.',
          'The deer said, tell nobody that you saw me. That is all I ask. The '
          'man promised, and went home.',
          'Not long after, the queen of that country offered a great reward to '
          'anyone who could lead her to the golden deer she had dreamed of. The '
          'man thought about his family and his promise, and in the end he took '
          'the reward and led the hunters to the river. But the queen saw '
          'the deer standing there quietly, and heard the whole story. She was '
          'so ashamed of what her reward had bought that she let him go. She '
          'forbade anyone to hunt him for the rest of his life.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'A promise made to someone who helped you is worth more than a '
              'reward.'),
          PpCard('Talk about it',
              'The man had a good reason for breaking his promise. Was it '
              'enough?'),
        ], heading: 'After the story', hue: 100),
        PpWhenLine('From about four and a half. It is a good one for a child '
            'starting to understand promises.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Jataka tales',
          minutes: '4 MIN',
          slotId: 'learning/story/jat_deer_river',
        ),
      ],
    ),
    PpPage(
      id: 'st_jat_quail_fire',
      title: 'The little quail and the forest fire',
      subtitle: 'Jataka tales',
      format: 'STORY',
      blocks: [
        PpIntro('A baby bird who cannot fly, a fire coming towards him, and the '
            'only thing he has left to use.'),
        PpArticle([
          'In a nest on the forest floor sat a quail chick, too young to fly '
          'and too young even to walk far. His parents brought him food and '
          'went out again, as birds do.',
          'One dry afternoon a fire started at the edge of the forest. Every '
          'animal that could run, ran. Every bird that could fly, flew. His '
          'parents called to him and then they too had to go, because they '
          'could not carry him.',
          'The chick sat quite still and watched the smoke coming. He could not '
          'run and he could not fly. But he thought about what was true: that '
          'he had never harmed anything, that his wings were not ready, and '
          'that this was his place.',
          'And he said it out loud to the fire, calmly, as it came. The story '
          'says the fire reached the edge of that patch of ground, and stopped, '
          'and went out, and that no fire has ever burned that spot since. His '
          'parents came back at dusk and found him exactly where they had left '
          'him.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Staying calm and honest when you are frightened is its own kind '
              'of strength.'),
          PpCard('Talk about it',
              'What do you do when you are frightened and you cannot run away?'),
        ], heading: 'After the story', hue: 100),
        PpWhenLine('From about four years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Jataka tales',
          minutes: '3 MIN',
          slotId: 'learning/story/jat_quail_fire',
        ),
      ],
    ),
    PpPage(
      id: 'st_jat_banyan_deer',
      title: 'The deer who took another deer place',
      subtitle: 'Jataka tales',
      format: 'STORY',
      blocks: [
        PpIntro('A king who hunts, a bargain that seems fair, and the deer who '
            'shows him what it really costs.'),
        PpArticle([
          'A king loved to hunt deer, and his hunts frightened the whole herd '
          'and injured many who were not even caught. So the leader of the '
          'deer, a great banyan-coloured stag, made a bargain with him. Leave '
          'the herd in peace, and each day one deer will come to the palace on '
          'its own.',
          'Every day a deer went, chosen by lot, and the rest lived quietly. '
          'Then the lot fell on a young doe who was expecting a fawn. She went '
          'to the stag and said, I will go when my turn comes, but let it come '
          'after my fawn is born.',
          'The stag looked for another deer to take her place that day, and '
          'nobody would. So he walked to the palace and laid his own head on '
          'the block himself.',
          'The king came out and stopped everything. He said, I gave your herd '
          'my word, why are you here? The stag said, because a mother asked me '
          'for a few more days and there was no one else to send. The king put '
          'down his weapons and ended the hunting in his kingdom altogether.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Taking somebody else turn when they are in trouble is the '
              'plainest kind of goodness there is.'),
          PpCard('Talk about it',
              'Why did the king change his mind when he saw the stag?'),
        ], heading: 'After the story', hue: 100),
        PpWhenLine('From about five years. It carries real weight and works '
            'best with a child who can sit with it.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Jataka tales',
          minutes: '5 MIN',
          slotId: 'learning/story/jat_banyan_deer',
        ),
      ],
    ),
    PpPage(
      id: 'st_jat_elephant_dog',
      title: 'The elephant and the dog',
      subtitle: 'Jataka tales',
      format: 'STORY',
      blocks: [
        PpIntro('An unlikely friendship, and what happens to one friend when '
            'the other is taken away.'),
        PpArticle([
          'A stray dog took to sleeping in the shed of the royal elephant, '
          'eating the rice that fell from his mouth. The elephant did not mind '
          'at all, and soon the two were inseparable. The dog would swing on '
          'his trunk and sleep between his feet.',
          'A farmer visiting the city saw the dog, liked the look of him, and '
          'bought him from the elephant keeper for a few coins. He took him '
          'away to his village.',
          'The elephant would not eat. He would not bathe, he would not work, '
          'and he stood in his shed with his ears down. The keepers called '
          'doctors, who could find nothing wrong with him at all.',
          'At last a wise old minister came, looked around the empty shed and '
          'asked, was there not a dog here? They sent messengers to find him. '
          'The day the dog came trotting back into the yard, the elephant '
          'lifted him up with his trunk and put him on his own head. Then he went '
          'straight to his food.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Friendship is not about being the same size or the same kind, '
              'and missing someone is a real thing.'),
          PpCard('Talk about it',
              'Why did nobody understand what was wrong with the elephant?'),
        ], heading: 'After the story', hue: 100),
        PpWhenLine('From about three and a half.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Jataka tales',
          minutes: '4 MIN',
          slotId: 'learning/story/jat_elephant_dog',
        ),
      ],
    ),
    PpPage(
      id: 'st_jat_ox_kind_words',
      title: 'The ox who would not pull',
      subtitle: 'Jataka tales',
      format: 'STORY',
      blocks: [
        PpIntro('A story about how much difference the words you use make. Very '
            'useful for a household that shouts.'),
        PpArticle([
          'A farmer had a fine strong ox that he had raised from a calf, and he '
          'was very proud of him. He made a bet with a rich merchant that his '
          'ox could pull a hundred loaded carts tied together.',
          'On the day, a crowd gathered. The farmer harnessed him up, and then, '
          'showing off in front of everyone, he shouted, pull, you stupid '
          'animal, get on with it.',
          'The ox had never been spoken to like that in his life. He stood '
          'completely still. Not one cart moved, and the farmer lost his money '
          'and went home furious and ashamed.',
          'That evening the ox said, in the way animals do in stories, why did '
          'you call me stupid? Have I ever been stupid? Make the bet again, and '
          'this time speak to me the way you always did. The farmer did, and '
          'the next time he said, come on my beauty, pull, and the ox pulled a '
          'hundred carts the length of the road.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'The same instruction said kindly gets a completely different '
              'result.'),
          PpCard('Talk about it',
              'How does it feel when somebody asks you for something in a '
              'shouting voice?'),
        ], heading: 'After the story', hue: 100),
        PpWhenLine('From about four years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Jataka tales',
          minutes: '4 MIN',
          slotId: 'learning/story/jat_ox_kind_words',
        ),
      ],
    ),
    PpPage(
      id: 'st_jat_hare_moon',
      title: 'The hare who had nothing to give',
      subtitle: 'Jataka tales',
      format: 'STORY',
      blocks: [
        PpIntro('Four animals decide to give something away. Three of them find '
            'it easy. The fourth has nothing at all.'),
        PpArticle([
          'An otter, a jackal, a monkey and a hare agreed that if any hungry '
          'traveller came by, each would share whatever food he had.',
          'A tired old traveller did come. The otter brought fish from the '
          'river. The jackal brought a pot of curd he had found. The monkey '
          'brought a great armful of mangoes.',
          'The hare had nothing but grass, and no traveller eats grass. He '
          'thought about it for a long time. Then he built up the fire, and '
          'told the traveller that since he had nothing else, he would give '
          'himself, and he jumped towards the flames.',
          'The traveller caught him in the air and set him down on the ground. '
          'He said, no one has ever offered me so much. And so that nobody '
          'would forget it, he drew the shape of the hare on the face of the '
          'moon. On a clear full moon night, if you look carefully, you can '
          'still see him there.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'What matters about a gift is what it costs the giver, not what '
              'it is worth.'),
          PpCard('Talk about it',
              'Go outside on a full moon night and look for the hare together.'),
        ], heading: 'After the story', hue: 100),
        PpWhenLine('From about four and a half.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Jataka tales',
          minutes: '4 MIN',
          slotId: 'learning/story/jat_hare_moon',
        ),
      ],
    ),
    PpPage(
      id: 'st_jat_woodpecker_lion',
      title: 'The woodpecker and the lion',
      subtitle: 'Jataka tales',
      format: 'STORY',
      blocks: [
        PpIntro('A small bird helps a big animal, and then finds out what kind '
            'of animal he helped.'),
        PpArticle([
          'A lion eating in a hurry got a bone stuck fast in his throat. He '
          'could not eat, could not roar, and lay in the shade in real misery.',
          'A woodpecker saw him and felt sorry for him. She said she would '
          'help, but she was not going to put her head inside a lion mouth '
          'without a precaution. So she propped his jaws open with a stick, '
          'went in, and worked the bone free.',
          'The lion recovered completely. Some weeks later the woodpecker, who '
          'had eaten nothing all day, saw him with a fresh kill. She came near, '
          'hoping he might remember her and leave a little.',
          'The lion looked at her coldly and said, you put your head inside my '
          'mouth once and came out alive. That is your reward, and it is more '
          'than most get. The woodpecker flew away and found her own food, and '
          'she was careful, ever after, about who she gave her help to for a '
          'second time.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Help people because it is right, and notice who says thank you '
              'and who does not.'),
          PpCard('Talk about it',
              'Was the woodpecker wrong to help him? What would you have done '
              'next time?'),
        ], heading: 'After the story', hue: 100),
        PpWhenLine('From about four and a half.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Jataka tales',
          minutes: '4 MIN',
          slotId: 'learning/story/jat_woodpecker_lion',
        ),
      ],
    ),
    PpPage(
      id: 'st_jat_crane_crab',
      title: 'The crane and the crab',
      subtitle: 'Jataka tales',
      format: 'STORY',
      blocks: [
        PpIntro('A crane offers to move the fish to a better lake. Only the '
            'crab thinks to ask a question first.'),
        PpArticle([
          'An old crane stood at the edge of a drying pond and thought about '
          'how tired he was of catching his own fish. So he stood there looking '
          'sad until the fish asked him what was wrong.',
          'He said, I am grieving for you. This pond will be dry in a week and '
          'you will all die. But I know a deep cool lake beyond those trees, '
          'and I am strong enough to carry you there, one at a time.',
          'The fish were suspicious, so he took one, showed it the lake, and '
          'brought it safely back to tell the others. After that they queued up '
          'eagerly. But he did not take the rest to the lake at all. He took '
          'each one to a tree and ate it, until the pond was almost empty.',
          'Last of all came the crab. The crane picked him up, and the crab, '
          'being cautious, held on to the crane neck with his claws. When he '
          'saw the pile of bones under the tree, he understood everything. He '
          'tightened his grip until the crane had to carry him back to the '
          'water and let him go.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Somebody being very helpful is not the same as somebody being '
              'honest. It is all right to check.'),
          PpCard('Talk about it',
              'The crab was careful even though everyone else was happy. Was '
              'that rude of him, or sensible?'),
        ], heading: 'After the story', hue: 100),
        PpWhenLine('From about four and a half.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Jataka tales',
          minutes: '4 MIN',
          slotId: 'learning/story/jat_crane_crab',
        ),
      ],
    ),
    PpPage(
      id: 'st_jat_parrot_tree',
      title: 'The parrot who stayed with his tree',
      subtitle: 'Jataka tales',
      format: 'STORY',
      blocks: [
        PpIntro('Every other bird leaves the dying tree. One parrot does not, '
            'and is asked to explain himself.'),
        PpArticle([
          'A flock of parrots lived in a huge old fig tree by a river. It fed '
          'them for years, and they were happy there.',
          'In time the tree grew old. Its bark cracked, its branches went '
          'hollow, and at last it stopped fruiting altogether. One by one the '
          'parrots left for greener trees, until only one was still there, '
          'sitting on a bare branch.',
          'A traveller passing by asked him why he stayed in a dead tree when '
          'there were fruiting trees a mile away. The parrot said, this tree '
          'fed me and sheltered me when it had plenty. I am not going to leave '
          'it now that it has nothing, only because it has nothing.',
          'The traveller was so struck by the answer that he fetched water from '
          'the river, day after day, and poured it at the roots. Slowly the old '
          'tree came back to life, put out green leaves, and fruited again, and '
          'the rest of the flock came home.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'You do not leave the people who looked after you just because '
              'they need looking after now.'),
          PpCard('Talk about it',
              'Who in our family looked after us when we were small?'),
        ], heading: 'After the story', hue: 100),
        PpWhenLine('From about four years. It is a good story to tell near '
            'grandparents.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Jataka tales',
          minutes: '4 MIN',
          slotId: 'learning/story/jat_parrot_tree',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  Collection 4 - Akbar and Birbal
// -----------------------------------------------------------------------------
//  BANDED FROM THREE, NOT FROM TWO AND A HALF LIKE THE ANIMAL COLLECTIONS. The
//  whole pleasure of a Birbal story is watching a clever answer arrive, and a
//  child who cannot yet hold the problem in his head while the answer is
//  delivered gets nothing from it. These are court stories with no animals to
//  carry a younger listener through.
// =============================================================================
const PpArea _birbal = PpArea(
  id: 'birbal',
  mark: IntentMark.lampMark,
  title: 'Akbar and Birbal',
  blurb: 'Ten stories about a clever answer arriving just in time. Wit, '
      'fairness, and not being fooled. From about three and a half.',
  hue: 300,
  bands: _fromThree,
  pages: [
    PpPage(
      id: 'st_bir_shorter_line',
      title: 'Make this line shorter',
      subtitle: 'Akbar and Birbal',
      format: 'STORY',
      blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'How Birbal made the line shorter',
          subtitle: 'Told at the speed a four-year-old can follow, with the pause before the answer.',
          minutes: '5 MIN',
          slotId: 'early_learning/read_birbal',
        ),
        PpIntro('The most famous of them all, and the shortest. Two minutes, '
            'and a lesson a child will use at school.'),
        PpArticle([
          'One morning the emperor Akbar drew a line on the floor of his court '
          'with a piece of chalk. He turned to his ministers and said, make '
          'this line shorter. But you may not rub out any part of it, and you '
          'may not touch it at all.',
          'The ministers looked at the line. They walked around it. They '
          'suggested covering part of it, which was touching it, and washing '
          'part of it, which was rubbing it out. Nobody could do it.',
          'Then Birbal came forward, took the chalk, and drew a second, much '
          'longer line right beside the first one. He did not touch the '
          'original at all.',
          'Everybody looked. The first line was now clearly the shorter of the '
          'two. Akbar laughed and said that was exactly what he had asked for.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'When a problem seems impossible, the way out is often to change '
              'what you are comparing it to.'),
          PpCard('Talk about it',
              'Draw two lines together and try it. Did the first line change at '
              'all?'),
        ], heading: 'After the story', hue: 300),
        PpWhenLine('From about four years. Do it with chalk on the floor while '
            'you tell it.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Akbar and Birbal',
          minutes: '2 MIN',
          slotId: 'learning/story/bir_shorter_line',
        ),
      ],
    ),
    PpPage(
      id: 'st_bir_crows',
      title: 'How many crows in the kingdom',
      subtitle: 'Akbar and Birbal',
      format: 'STORY',
      blocks: [
        PpIntro('An impossible question, answered with complete confidence. '
            'Children find this one extremely funny.'),
        PpArticle([
          'Akbar was in a playful mood and asked his court a question nobody '
          'could possibly answer: how many crows are there in my kingdom?',
          'The ministers went pale. You cannot count crows. They fly, they come '
          'and go, and there are thousands of them.',
          'Birbal said at once, ninety five thousand four hundred and sixty '
          'three, your majesty. Akbar said, and if I count them and there are '
          'more?',
          'Birbal said, then some crows from the neighbouring kingdom are '
          'visiting their relatives here. And if there are fewer? Then some of '
          'ours have gone to visit theirs. Akbar could not fault him, and gave '
          'up the question.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'A confident answer with a reason attached is worth more than no '
              'answer at all.'),
          PpCard('Talk about it',
              'Was Birbal telling the truth? Was he lying? What was he doing?'),
        ], heading: 'After the story', hue: 300),
        PpWhenLine('From about four years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Akbar and Birbal',
          minutes: '3 MIN',
          slotId: 'learning/story/bir_crows',
        ),
      ],
    ),
    PpPage(
      id: 'st_bir_well_water',
      title: 'The man who sold his well',
      subtitle: 'Akbar and Birbal',
      format: 'STORY',
      blocks: [
        PpIntro('A dispute about a well, settled by reading the agreement '
            'exactly as it was written. A story about fairness.'),
        PpArticle([
          'A farmer bought a well from his neighbour so he could water his '
          'fields. He paid the money and went out the next morning with his '
          'buckets.',
          'The neighbour stopped him. He said, I sold you the well. I did not '
          'sell you the water in it. If you want the water you must pay me '
          'again, every month.',
          'The farmer went to the court in tears, and the case came to Birbal. '
          'He read the agreement, and then he asked the neighbour, is this what '
          'you say? The neighbour said proudly, yes, the well is his, the water '
          'is mine.',
          'Birbal said, very well. Then you are keeping your water in another '
          "man's well without paying rent. Either pay him rent for storing it, "
          'or take all your water out of his well today. The neighbour stopped '
          'talking and the farmer watered his fields.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'A clever trick can be undone by taking it seriously and '
              'following it to the end.'),
          PpCard('Talk about it',
              'Why did the neighbour stop arguing? What had he agreed to '
              'without noticing?'),
        ], heading: 'After the story', hue: 300),
        PpWhenLine('From about five years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Akbar and Birbal',
          minutes: '3 MIN',
          slotId: 'learning/story/bir_well_water',
        ),
      ],
    ),
    PpPage(
      id: 'st_bir_pot_baby',
      title: 'The pot that had a baby',
      subtitle: 'Akbar and Birbal',
      format: 'STORY',
      blocks: [
        PpIntro('A greedy man is caught by his own greed, using nothing but a '
            'small cooking pot.'),
        PpArticle([
          'A poor man borrowed a large pot from his rich neighbour for a '
          'wedding. When he returned it, he put a small pot inside it, and said '
          'with a straight face, your pot had a baby while it was at my house.',
          'The rich man thought this was very fine indeed and kept both pots '
          'without a word of protest.',
          'Some weeks later the poor man borrowed the big pot again, and this '
          'time he did not bring it back. When the rich man came to ask for it, '
          'he said sadly, I am very sorry, your pot died at my house.',
          'The rich man shouted that a pot cannot die. The poor man said, a pot '
          'that can have a baby can certainly die. The case went to Birbal, who '
          'listened to both, and told the rich man he had accepted the first '
          'story very cheerfully and must now accept the second.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'If you happily believe something because it suits you, you '
              'cannot object when it stops suiting you.'),
          PpCard('Talk about it',
              'Why did the rich man believe the first story so easily?'),
        ], heading: 'After the story', hue: 300),
        PpWhenLine('From about four and a half.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Akbar and Birbal',
          minutes: '3 MIN',
          slotId: 'learning/story/bir_pot_baby',
        ),
      ],
    ),
    PpPage(
      id: 'st_bir_khichdi',
      title: 'The khichdi cooked far from the fire',
      subtitle: 'Akbar and Birbal',
      format: 'STORY',
      blocks: [
        PpIntro('A man stands in a freezing river all night to win a prize, and '
            'then needs Birbal to defend him before he can get it.'),
        PpArticle([
          'One winter Akbar offered a bag of gold to anyone who could stand in '
          'the freezing river all night without a fire and without a blanket. A '
          'poor man said he would do it, and he did, shivering, until sunrise.',
          'When he came to collect the gold, one of the courtiers asked how he '
          'had survived. The man said honestly that he had kept his eyes on a '
          'lamp burning in a window far away on the bank. It had helped him '
          'through the night.',
          'The courtiers said at once that this was cheating: he had used the '
          'warmth of the lamp. Akbar, not thinking, agreed, and the man was '
          'sent away with nothing.',
          'The next day Birbal did not come to court. Akbar went looking for '
          'him and found him sitting outside. A pot of khichdi hung '
          'from a tall pole, and a small fire burned on the ground far below '
          'it. He said he was cooking his lunch. Akbar said, that fire is '
          'nowhere near the pot, it will never cook. Birbal said, if a lamp '
          'across a river can warm a man, this fire can certainly cook my '
          'khichdi. The poor man got his gold that afternoon.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'It is worth speaking up when somebody is treated unfairly, even '
              'if the person in charge has already decided.'),
          PpCard('Talk about it',
              'Why did Birbal cook khichdi instead of just arguing?'),
        ], heading: 'After the story', hue: 300),
        PpWhenLine('From about five years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Akbar and Birbal',
          minutes: '4 MIN',
          slotId: 'learning/story/bir_khichdi',
        ),
      ],
    ),
    PpPage(
      id: 'st_bir_brinjal',
      title: 'Birbal and the brinjals',
      subtitle: 'Akbar and Birbal',
      format: 'STORY',
      blocks: [
        PpIntro('A story that makes fun of Birbal himself, which is why it is '
            'one of the most useful ones.'),
        PpArticle([
          'At dinner one evening Akbar ate a brinjal dish and said it was '
          'wonderful. Birbal agreed enthusiastically and said the brinjal was '
          'the king of vegetables, glossy, purple and crowned like a royal.',
          'A few weeks later the same dish did not agree with the emperor, and '
          'he said he never wanted to see a brinjal again. Birbal agreed '
          'immediately and said the brinjal was a useless vegetable, no taste '
          'of its own, full of seeds, fit for nobody.',
          'Akbar caught him. He said, only last month you told me it was the '
          'king of vegetables. How can you say the opposite now?',
          'Birbal said, your majesty, I am your servant, not the brinjal '
          'servant. The whole court laughed, including Akbar, who knew exactly '
          'what he had just been told about flatterers.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'People who agree with everything you say are not really telling '
              'you anything.'),
          PpCard('Talk about it',
              'Is it a good thing to agree with somebody just because they are '
              'important?'),
        ], heading: 'After the story', hue: 300),
        PpWhenLine('From about five years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Akbar and Birbal',
          minutes: '3 MIN',
          slotId: 'learning/story/bir_brinjal',
        ),
      ],
    ),
    PpPage(
      id: 'st_bir_beautiful_child',
      title: 'The most beautiful child',
      subtitle: 'Akbar and Birbal',
      format: 'STORY',
      blocks: [
        PpIntro('A short one about how every mother sees her own child, which '
            'is a lovely thing to tell a child.'),
        PpArticle([
          'Akbar asked Birbal to go out into the kingdom and bring back the '
          'most beautiful child in it.',
          'Birbal was gone for several days. He came back carrying a child who '
          'was, by any ordinary reckoning, quite plain, with a snub nose and a '
          'great deal of dust on him.',
          'The court laughed. Akbar said, is this really the most beautiful '
          'child in my kingdom?',
          'Birbal said, I visited many houses, and in every one, the mother '
          'told me her own child was the most beautiful in the world. This one '
          "is that child's mother's answer. There is no other kind of most "
          'beautiful child.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Being loved and being the best-looking are different things, and '
              'the first one is what people really mean.'),
          PpCard('Talk about it',
              'Who thinks you are the most beautiful child in the world?'),
        ], heading: 'After the story', hue: 300),
        PpWhenLine('From about four years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Akbar and Birbal',
          minutes: '3 MIN',
          slotId: 'learning/story/bir_beautiful_child',
        ),
      ],
    ),
    PpPage(
      id: 'st_bir_parrot',
      title: 'The parrot that would not die',
      subtitle: 'Akbar and Birbal',
      format: 'STORY',
      blocks: [
        PpIntro('Nobody dares tell the emperor bad news, so Birbal has to find '
            'a way of saying it without saying it.'),
        PpArticle([
          'Akbar had a parrot he loved above all his other birds. He '
          'announced that anyone who came and told him the parrot was dead '
          'would be severely punished.',
          'The parrot was old, and one morning the keeper found it stiff on the '
          'floor of its cage. He was terrified. He went to Birbal.',
          'Birbal went to the emperor and said, your majesty, your parrot is '
          'behaving very strangely. It will not eat, it will not drink, it will '
          'not open its eyes, it will not move a feather, and it has stopped '
          'breathing altogether.',
          'Akbar said, you fool, that means it is dead. Birbal bowed and said, '
          'your majesty said it, not I. And Akbar, who was a fair man when he '
          'was not being obeyed too well, saw the silliness of his own order '
          'and cancelled it.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Bad news is easier to hear when somebody is careful about how '
              'they tell it, and it still has to be told.'),
          PpCard('Talk about it',
              'Why was everybody so afraid to tell the emperor the truth?'),
        ], heading: 'After the story', hue: 300),
        PpWhenLine('From about five years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Akbar and Birbal',
          minutes: '3 MIN',
          slotId: 'learning/story/bir_parrot',
        ),
      ],
    ),
    PpPage(
      id: 'st_bir_magic_stick',
      title: 'The stick that grew in the night',
      subtitle: 'Akbar and Birbal',
      format: 'STORY',
      blocks: [
        PpIntro('A thief among ten men, and a test that catches him without '
            'anybody being questioned at all.'),
        PpArticle([
          'A rich man came to court to say that a gold chain had been stolen '
          'from his house. It had to be one of his ten servants, but '
          'he could not tell which.',
          'Birbal called all ten in and gave each of them a stick of exactly '
          'the same length. He said, these sticks are not ordinary. Tonight, '
          'the stick belonging to the thief will grow two inches longer. Bring '
          'them all back to me in the morning.',
          'In the morning the ten men lined up with their sticks. Nine were the '
          'length they had been. One was two inches shorter than the rest.',
          'Birbal pointed at the man holding it. He had believed the story, and '
          'in the night he had cut two inches off his own stick so that it '
          'would look ordinary in the morning. Nobody had been shouted at and '
          'nobody had been searched.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'A guilty person is often given away by trying too hard not '
              'to be.'),
          PpCard('Talk about it',
              'Why did the thief cut his stick? What would have happened if he '
              'had done nothing?'),
        ], heading: 'After the story', hue: 300),
        PpWhenLine('From about five years. It is a favourite at this age '
            'because the child works it out one beat before the ending.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Akbar and Birbal',
          minutes: '3 MIN',
          slotId: 'learning/story/bir_magic_stick',
        ),
      ],
    ),
    PpPage(
      id: 'st_bir_barber_dream',
      title: 'The barber and the dream',
      subtitle: 'Akbar and Birbal',
      format: 'STORY',
      blocks: [
        PpIntro('Somebody plots against Birbal, and Birbal turns the plot back '
            'on him without raising his voice.'),
        PpArticle([
          'The court barber was jealous of Birbal and wanted him out of the '
          'way. So one day, while shaving the emperor, he spoke quietly. He '
          'had heard the emperor ancestors were unhappy in the next world and '
          'needed a wise man sent to advise them.',
          'Akbar was troubled and, foolishly, agreed that Birbal should be the '
          'one sent. Birbal asked only for a month to put his affairs in order, '
          'and it was granted.',
          'In that month he had a long tunnel dug from the appointed spot to '
          'his own house. When the day came he went down as arranged, and came '
          'back a few weeks later, alive and with a magnificent new beard.',
          'He told the court his ancestors were extremely well. They '
          'had said only one thing. They had no barber up there, and would '
          'very much like the court barber to be sent next. The barber '
          'confessed everything before the emperor could open his mouth.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'A trap set for somebody else is a dangerous thing to stand '
              'near.'),
          PpCard('Talk about it',
              'Why did the barber confess? What was he suddenly afraid of?'),
        ], heading: 'After the story', hue: 300),
        PpWhenLine('From about five years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Akbar and Birbal',
          minutes: '4 MIN',
          slotId: 'learning/story/bir_barber_dream',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  Collection 5 - Tenali Rama
// -----------------------------------------------------------------------------
//  SIX, NOT THIRTY. The specification asked for thirty seeded entries here, and
//  six well known tales told properly is the honest version. The Tenali corpus
//  that is genuinely well known and genuinely secular is small: several of the
//  famous ones are temple stories, and padding the rest with invented tales
//  would mean shipping made-up folklore under a real name. That is the one kind
//  of filler that does actual harm, because a parent would repeat it as
//  heritage. The gap is named in the build report rather than hidden.
// =============================================================================
const PpArea _tenali = PpArea(
  id: 'tenali',
  mark: IntentMark.improveMark,
  title: 'Tenali Rama',
  blurb: 'Six tales from the court at Vijayanagara. Quick thinking, and a poet '
      'who was never quite as foolish as he looked.',
  hue: 12,
  bands: _fromThree,
  pages: [
    PpPage(
      id: 'st_ten_thieves_garden',
      title: 'The thieves who watered the garden',
      subtitle: 'Tenali Rama',
      format: 'STORY',
      blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'Tenali Rama and the thieves in the garden',
          subtitle: 'Read aloud, with the joke given room to land.',
          minutes: '5 MIN',
          slotId: 'early_learning/read_tenali',
        ),
        PpIntro('Tenali gets his garden dug and watered by the very people who '
            'came to rob him, without ever getting out of bed.'),
        PpArticle([
          'Tenali Rama heard that thieves were planning to visit his house that '
          'night. He did not call the guards. Instead he waited until he could '
          'hear them at the wall, and then he spoke loudly to his wife in the '
          'courtyard.',
          'He said, listen, there are thieves about these days. All our gold is '
          'in this trunk. We had better bury it in the garden, and I am too '
          'tired, so we will do it tomorrow.',
          'The thieves waited until the house was dark, and then set to work. '
          'They dug up the whole garden, every corner of it, looking for the '
          'trunk. They found nothing. Then they thought the earth looked too '
          'obviously disturbed, so they watered it all down to hide their '
          'digging, and went away exhausted before dawn.',
          'In the morning Tenali came out and looked at his beautifully dug and '
          'watered garden. He told his wife that they now had the best '
          'prepared soil in the city, and had not lifted a finger.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Thinking ahead can turn a problem into something useful.'),
          PpCard('Talk about it',
              'Why did Tenali say the gold was in the garden when it was not?'),
        ], heading: 'After the story', hue: 12),
        PpWhenLine('From about four years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Tenali Rama',
          minutes: '3 MIN',
          slotId: 'learning/story/ten_thieves_garden',
        ),
      ],
    ),
    PpPage(
      id: 'st_ten_cats_milk',
      title: 'The king cats and the milk',
      subtitle: 'Tenali Rama',
      format: 'STORY',
      blocks: [
        PpIntro('A royal order that nobody dares question, and one man who '
            'shows the king why it was silly.'),
        PpArticle([
          'The city had too many rats, so the king gave every household a cat '
          'and a measure of milk a day to feed it. He ordered that the cats be '
          'kept healthy and inspected regularly.',
          'Tenali took his cat home and gave it milk that was far too hot. The '
          'cat burnt its tongue, and after that it would not go near milk at '
          'all, not even when it was cold.',
          'When the inspectors came, Tenali cat was thin and the milk was '
          'untouched. He was called before the king and accused of starving it. '
          'He asked the king to place a bowl of milk in front of the cat there '
          'and then. The whole court watched the cat back away from it in '
          'horror.',
          'Tenali said, the cat has decided, your majesty, not I. And then he '
          'said the thing he had come to say. The rats are gone, the milk is '
          'costing the treasury a fortune every day. Perhaps it is time the '
          'cats caught their own dinner. The king ended the order.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'A rule that made sense once may stop making sense, and somebody '
              'has to be willing to say so.'),
          PpCard('Talk about it',
              'Why was everybody else afraid to tell the king about the milk?'),
        ], heading: 'After the story', hue: 12),
        PpWhenLine('From about four and a half.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Tenali Rama',
          minutes: '4 MIN',
          slotId: 'learning/story/ten_cats_milk',
        ),
      ],
    ),
    PpPage(
      id: 'st_ten_smell_and_sound',
      title: 'The smell of the food and the sound of the coins',
      subtitle: 'Tenali Rama',
      format: 'STORY',
      blocks: [
        PpIntro('A shopkeeper wants to be paid for something nobody can hold. '
            'The judgement is perfect.'),
        PpArticle([
          'A poor man used to sit every day outside a food shop and eat his dry '
          'roti there, because the smell of the cooking made it taste better.',
          'The shopkeeper noticed, and one day he stopped him and demanded '
          'payment. He said, you have been enjoying my food for months. The '
          'smell is mine and you must pay for it.',
          'The poor man had nothing, and the case came before Tenali. He '
          'listened to both of them, and then he asked the poor man to fetch '
          'whatever coins he had. The man brought a few small ones in his palm.',
          'Tenali took them and shook them in his cupped hands beside the '
          "shopkeeper's ear, so that they rang. Then he gave them back to the "
          'poor man. He said to the shopkeeper, he enjoyed the smell of your '
          'food and you have enjoyed the sound of his money. You are paid '
          'exactly in kind.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Being greedy about something that costs you nothing usually ends '
              'in looking foolish.'),
          PpCard('Talk about it',
              'Was the shopkeeper really losing anything?'),
        ], heading: 'After the story', hue: 12),
        PpWhenLine('From about four and a half.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Tenali Rama',
          minutes: '3 MIN',
          slotId: 'learning/story/ten_smell_and_sound',
        ),
      ],
    ),
    PpPage(
      id: 'st_ten_half_portrait',
      title: 'The painter who painted only half',
      subtitle: 'Tenali Rama',
      format: 'STORY',
      blocks: [
        PpIntro('How do you paint an honest picture of a king who will be angry '
            'either way? Very carefully.'),
        PpArticle([
          'A neighbouring king who had lost one eye and one leg wanted his '
          'portrait painted. Every painter who tried was in trouble. If they '
          'painted him as he was, he was insulted. If they painted him '
          'whole, he said they were liars and flatterers.',
          'Several painters had already been punished when Tenali happened to '
          'be visiting that court, and he offered to solve it.',
          'He painted the king in profile, sitting on a horse, taking aim with '
          'a bow. The good eye was towards the viewer and closed in aim. The '
          'good leg was on this side of the horse, and the other was hidden '
          'behind it.',
          'Nothing was invented and nothing was insulting. The king looked at '
          'himself as a hunter and was delighted, and every painter in the '
          'kingdom went back to work.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'You can be completely truthful and completely kind at the same '
              'time, if you think hard enough about how to say it.'),
          PpCard('Talk about it',
              'How did the painting tell the truth without hurting anybody?'),
        ], heading: 'After the story', hue: 12),
        PpWhenLine('From about five years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Tenali Rama',
          minutes: '3 MIN',
          slotId: 'learning/story/ten_half_portrait',
        ),
      ],
    ),
    PpPage(
      id: 'st_ten_horse',
      title: 'The horse nobody could ride',
      subtitle: 'Tenali Rama',
      format: 'STORY',
      blocks: [
        PpIntro('Tenali is given the most difficult horse in the royal stable '
            'and told to train it. He keeps it on the first floor.'),
        PpArticle([
          'The king bought a batch of new horses and gave one to each courtier '
          'to train, with a grain allowance for its feed. Tenali was given the '
          'wildest of them, an animal nobody could get near.',
          'He took it home, put it in a small room upstairs, and fed it through '
          'the window. Every day he collected the grain allowance and every day '
          'he told anyone who asked that the training was going beautifully.',
          'Months later the king announced an inspection. The courtiers brought '
          'out their horses, smooth and obedient. Tenali arrived carrying a '
          'thick rope and looking nervous, and said his horse was so fierce '
          'that it could not be brought out of the house at all.',
          'The king went to see for himself. The horse had been shut in a small '
          'room for months and came out blinking and furious, and it took '
          'several men to hold it. The king asked how it had got up there in '
          'the first place, and Tenali admitted the whole thing. The king '
          'laughed at his cheek and let him off, but he never got the horse '
          'allowance again.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'You can be clever and still be in the wrong, and getting away '
              'with it is not the same as being right.'),
          PpCard('Talk about it',
              'Tenali was clever here, but was he honest? Are those the same '
              'thing?'),
        ], heading: 'After the story', hue: 12),
        PpWhenLine('From about five years, when a child can enjoy a character '
            'who is not simply good.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Tenali Rama',
          minutes: '4 MIN',
          slotId: 'learning/story/ten_horse',
        ),
      ],
    ),
    PpPage(
      id: 'st_ten_bag_of_gold',
      title: 'The three men and the bag of gold',
      subtitle: 'Tenali Rama',
      format: 'STORY',
      blocks: [
        PpIntro('Three travellers, one bag, and a rule that sounds fair until '
            'you look at it properly.'),
        PpArticle([
          'Three travellers put all their money into one bag and gave it to the '
          'innkeeper to keep. He must only hand it back, they said, when all three '
          'of them came to ask for it together.',
          'One of them came back alone the next morning, said the others had '
          'sent him, and the innkeeper gave him the bag. He disappeared with '
          'it. When the other two came, there was nothing.',
          'They took the innkeeper to court, and the case came to Tenali. The '
          'innkeeper admitted everything and offered to repay what he could, '
          'which was very little.',
          'Tenali gave his judgement to the two travellers instead. He said, '
          'the bag will be returned to you the moment all three of you come to '
          'ask for it, exactly as your own rule says. Bring your friend, and '
          'the innkeeper will pay in full. Until then there is nothing to '
          'answer. The two men went off to find the one who had run, which is '
          'what they should have been doing all along.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Blaming the nearest person is easier than finding the one who '
              'really did it.'),
          PpCard('Talk about it',
              'Who really took the money? Why were the two men shouting at the '
              'innkeeper?'),
        ], heading: 'After the story', hue: 12),
        PpWhenLine('From about five years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'Tenali Rama',
          minutes: '4 MIN',
          slotId: 'learning/story/ten_bag_of_gold',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  Collection 6 - Stories from around the world
// -----------------------------------------------------------------------------
//  The secular values collection the specification asked for. Sharing, courage,
//  perseverance, honesty. Most are Aesop, which is convenient: they are short,
//  they are famous enough that a grandparent will know them too, and they carry
//  no religious content of any kind.
// =============================================================================

const PpArea _worldTales = PpArea(
  id: 'world_tales',
  mark: IntentMark.nextStep,
  title: 'Stories from around the world',
  blurb: 'Ten short tales other countries tell their children, about sharing, '
      'courage and sticking at things.',
  hue: 190,
  bands: _fromTwo,
  pages: [
    PpPage(
      id: 'st_world_lion_mouse',
      title: 'The lion and the mouse',
      subtitle: 'Stories from around the world',
      format: 'STORY',
      blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'The lion and the mouse, read aloud',
          subtitle: 'A short one for a child who is nearly asleep.',
          minutes: '4 MIN',
          slotId: 'early_learning/read_world',
        ),
        PpIntro('The best first moral story there is. Short, only two '
            'characters, and easy to act out afterwards.'),
        PpArticle([
          'A lion was asleep in the sun when a small mouse ran right across his '
          'paw and woke him up. He caught her at once under one claw.',
          'The mouse squeaked, please let me go. One day I will help you, I '
          'promise. The lion laughed so much at the idea of a mouse helping him '
          'that he lifted his paw and let her run.',
          'Some weeks later the lion walked into a hunter net and was caught '
          'fast. He roared and pulled and only tangled himself worse, and the '
          'whole forest heard him.',
          'The mouse heard him too. She came running, and she began to chew '
          'through the ropes with her small sharp teeth, one strand at a time. '
          'Soon there was a hole big enough for a lion to walk out of. And the '
          'lion never laughed at small friends again.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Nobody is too small to be useful, and a kindness usually comes '
              'back.'),
          PpCard('Talk about it',
              'Act it out. You be the lion and your child the mouse, then swap.'),
        ], heading: 'After the story', hue: 190),
        PpWhenLine('From about two and a half. This is usually the first moral '
            'story a child really follows.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'World tales',
          minutes: '3 MIN',
          slotId: 'learning/story/world_lion_mouse',
        ),
      ],
    ),
    PpPage(
      id: 'st_world_cried_wolf',
      title: 'The boy who cried wolf',
      subtitle: 'Stories from around the world',
      format: 'STORY',
      blocks: [
        PpIntro('The clearest story about lying ever written, and it does not '
            'need a single word of explanation afterwards.'),
        PpArticle([
          'A boy was sent up the hill every day to watch the village sheep. It '
          'was quiet work and he was bored.',
          'One afternoon, for something to do, he stood up and shouted, wolf, '
          'wolf, there is a wolf. Everybody dropped what they were doing and '
          'came running up the hill with sticks, and found him laughing. He '
          'thought it was the funniest thing he had ever done.',
          'A few days later he did it again. The villagers came again, more '
          'slowly this time, and went home again very annoyed.',
          'Then one evening a wolf really did come out of the trees and walk in '
          'among the sheep. The boy stood up and shouted with everything he '
          'had, wolf, wolf. And down in the village they heard him, and they '
          'looked at each other, and nobody came.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Once people stop believing you, they do not start again just '
              'because this time it is true.'),
          PpCard('Talk about it',
              'Why did nobody come the third time? What could the boy have '
              'done differently?'),
        ], heading: 'After the story', hue: 190),
        PpWhenLine('From about three and a half.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'World tales',
          minutes: '3 MIN',
          slotId: 'learning/story/world_cried_wolf',
        ),
      ],
    ),
    PpPage(
      id: 'st_world_tortoise_hare',
      title: 'The tortoise and the hare',
      subtitle: 'Stories from around the world',
      format: 'STORY',
      blocks: [
        PpIntro('A race between the fastest animal and the slowest. Everybody '
            'knows how it ends and children still want to hear it.'),
        PpArticle([
          'The hare was always boasting about how fast he was, until one day '
          'the tortoise got tired of it and challenged him to a race. The whole '
          'field came to watch, laughing.',
          'The hare shot off and was out of sight in seconds. The tortoise put '
          'one foot in front of the other and kept going.',
          'Halfway along, the hare looked back and could not even see his '
          'opponent. There was a shady tree and long grass, and he thought, I '
          'have hours. He lay down for a short rest and fell fast asleep.',
          'The tortoise came past him, still walking, and did not stop. The '
          'hare woke up and ran the rest of the way as fast as his legs '
          'would go. But the tortoise was already sitting quietly at the finishing '
          'line, waiting for him.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Keeping going beats being quick in bursts, and being good at '
              'something is not a reason to stop trying.'),
          PpCard('Talk about it',
              'What is something you are slow at but you keep doing?'),
        ], heading: 'After the story', hue: 190),
        PpWhenLine('From about three years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'World tales',
          minutes: '3 MIN',
          slotId: 'learning/story/world_tortoise_hare',
        ),
      ],
    ),
    PpPage(
      id: 'st_world_ant_grasshopper',
      title: 'The ant and the grasshopper',
      subtitle: 'Stories from around the world',
      format: 'STORY',
      blocks: [
        PpIntro('One works all summer, one sings all summer. A story about '
            'doing the boring thing before you need it.'),
        PpArticle([
          'All through the hot months, a line of ants carried grain across the '
          'field, back and forth, back and forth, storing it away.',
          'A grasshopper sat in the shade with his legs crossed and sang. He '
          'called out to them, why are you working in this heat? There is food '
          'everywhere. Come and sing. The ants said, we are getting ready for '
          'the cold, and kept walking.',
          'Then the weather turned. The grass dried up and the field went bare, '
          'and there was nothing at all to eat.',
          'The grasshopper, thin and cold, came to the door of the ants and '
          'asked for food. And they took him in and fed him, because they were '
          'not unkind. But they told him plainly that next summer he would be '
          'carrying grain with everybody else.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Doing the dull work in good times is what makes the hard times '
              'survivable.'),
          PpCard('Talk about it',
              'The ants shared in the end. Should they have? What would you '
              'have done?'),
        ], heading: 'After the story', hue: 190),
        PpWhenLine('From about four years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'World tales',
          minutes: '3 MIN',
          slotId: 'learning/story/world_ant_grasshopper',
        ),
      ],
    ),
    PpPage(
      id: 'st_world_crow_pitcher',
      title: 'The thirsty crow',
      subtitle: 'Stories from around the world',
      format: 'STORY',
      blocks: [
        PpIntro('A problem solved with patience and small stones. This one is '
            'worth doing with a real pot afterwards.'),
        PpArticle([
          'It was the hottest part of the summer and a crow had been flying for '
          'hours looking for water. Every pond he found was dry.',
          'At last he came to a garden with a tall clay pot standing in it, and '
          'when he looked inside there was water at the bottom. But the pot was '
          'deep and narrow, and however he twisted his head he could not reach '
          'it. He tried to knock it over and it was far too heavy.',
          'He sat on the edge and thought. Then he flew down, picked up a small '
          'pebble in his beak, and dropped it into the pot.',
          'He did it again, and again, and again. Each pebble sank to the '
          'bottom and pushed the water a little higher. He must have dropped in '
          'fifty of them. And at last the water came up to the top of the pot, '
          'and he drank as much as he wanted.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'A problem that cannot be solved in one go can often be solved '
              'fifty small times.'),
          PpCard('Talk about it',
              'Try it. Half fill a glass, drop in stones, and watch the water '
              'come up.'),
        ], heading: 'After the story', hue: 190),
        PpWhenLine('From about three years, and the experiment afterwards works '
            'from four.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'World tales',
          minutes: '3 MIN',
          slotId: 'learning/story/world_crow_pitcher',
        ),
      ],
    ),
    PpPage(
      id: 'st_world_wind_and_sun',
      title: 'The north wind and the sun',
      subtitle: 'Stories from around the world',
      format: 'STORY',
      blocks: [
        PpIntro('A competition about who is stronger, settled by a man walking '
            'along a road in a coat.'),
        PpArticle([
          'The north wind and the sun were arguing about which of them was the '
          'stronger, and neither would give in.',
          'Then they saw a traveller walking along the road below in a heavy '
          'coat. They agreed on a test. Whichever of them could get the '
          'coat off him was the stronger.',
          'The north wind went first. He blew until the trees bent and the dust '
          'flew. But the harder he blew, the tighter the man pulled his coat '
          'around him and held on to the collar. In the end the wind gave '
          'up, out of breath.',
          'Then the sun came out from behind a cloud and simply shone, gently '
          'at first and then warmly. Within a few minutes the traveller '
          'unbuttoned his coat, and a little further along the road he took it '
          'off altogether and carried it over his arm.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'You get further with people by being warm than by pushing '
              'harder.'),
          PpCard('Talk about it',
              'What happens when somebody shouts at you to do something?'),
        ], heading: 'After the story', hue: 190),
        PpWhenLine('From about four years. It is a useful one for a household '
            'trying to shout less.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'World tales',
          minutes: '3 MIN',
          slotId: 'learning/story/world_wind_and_sun',
        ),
      ],
    ),
    PpPage(
      id: 'st_world_stone_soup',
      title: 'Stone soup',
      subtitle: 'Stories from around the world',
      format: 'STORY',
      blocks: [
        PpIntro('A whole village that has nothing to spare ends up making '
            'dinner together, one ingredient at a time.'),
        PpArticle([
          'A tired traveller came to a village and knocked on doors asking for '
          'food. Times were hard, and at every house he was told there was '
          'nothing to spare, which was very nearly true.',
          'So he went to the square, built a fire, filled a big pot with water, '
          'and dropped in a smooth round stone. People came out to watch. He '
          'stirred it and said, stone soup. Wonderful stuff. Of course it is '
          'even better with a little salt.',
          'Somebody fetched salt. He tasted it and said it was coming along '
          'nicely, though an onion would lift it. A woman went home for an '
          'onion. Then a man remembered two potatoes, and a boy brought a '
          'handful of dal, and somebody found a bunch of coriander going soft '
          'at home.',
          'By evening the pot was full of thick, good soup. The whole '
          'village sat around the fire eating it and saying what a remarkable '
          'stone it must be.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Nobody had enough alone and everybody had enough together.'),
          PpCard('Talk about it',
              'What did each person bring? What could our family bring if '
              'somebody needed help?'),
        ], heading: 'After the story', hue: 190),
        PpWhenLine('From about four years. It is an excellent story to tell '
            'while you are cooking.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'World tales',
          minutes: '4 MIN',
          slotId: 'learning/story/world_stone_soup',
        ),
      ],
    ),
    PpPage(
      id: 'st_world_bundle_sticks',
      title: 'The bundle of sticks',
      subtitle: 'Stories from around the world',
      format: 'STORY',
      blocks: [
        PpIntro('An old man, four quarrelling sons, and a demonstration that '
            'needs no words at all. Good for a house with siblings.'),
        PpArticle([
          'An old farmer had four sons who could not be in the same room '
          'without arguing. He worried about what would happen to the farm '
          'after he was gone.',
          'One day he called them all in and put a bundle of sticks, tied '
          'tightly together, on the table. He said, whichever of you can break '
          'this bundle can have the farm.',
          'The eldest tried first. He put it over his knee and pulled with '
          'everything he had, and it did not move. The second tried, and the '
          'third, and the fourth. The bundle did not even bend.',
          'Then the old man untied the string and gave each of them one single '
          'stick. Every one of them snapped it between two fingers without '
          'thinking about it. He said, that is all I wanted to show you. Now go '
          'and run the farm.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'People who stay together are much harder to knock over than '
              'people standing alone.'),
          PpCard('Talk about it',
              'Try it with a handful of dry twigs or incense sticks.'),
        ], heading: 'After the story', hue: 190),
        PpWhenLine('From about four years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'World tales',
          minutes: '3 MIN',
          slotId: 'learning/story/world_bundle_sticks',
        ),
      ],
    ),
    PpPage(
      id: 'st_world_honest_woodcutter',
      title: 'The honest woodcutter',
      subtitle: 'Stories from around the world',
      format: 'STORY',
      blocks: [
        PpIntro('A man loses the only thing he owns, and is offered two much '
            'better ones. What he says next is the story.'),
        PpArticle([
          'A woodcutter was chopping at the edge of a deep river when the head '
          'of his axe flew off the handle and sank. It was the only tool he '
          'had, and without it he could not work at all. He sat down on the '
          'bank and put his head in his hands.',
          'An old woman came along the path and asked what was wrong. When he '
          'told her, she waded in and came back holding an axe made entirely of '
          'gold. Is this yours? The woodcutter said no.',
          'She went in again and came back with one of silver. Is this yours? '
          'He said no again, though he could see perfectly well what either of '
          'them was worth.',
          'The third time she brought up an old iron axe head with a chip in '
          'the blade, and his face lit up, because it was his. She gave it to '
          'him, and then she gave him the gold one and the silver one as well. '
          'She said that an honest man who is offered a fortune and says no '
          'twice ought to have something for it.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'Telling the truth when a lie would pay very well is what honesty '
              'really means.'),
          PpCard('Talk about it',
              'Was it hard for him to say no? Why do you think he did?'),
        ], heading: 'After the story', hue: 190),
        PpWhenLine('From about four years.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'World tales',
          minutes: '3 MIN',
          slotId: 'learning/story/world_honest_woodcutter',
        ),
      ],
    ),
    PpPage(
      id: 'st_world_two_brothers_rice',
      title: 'The two brothers and the sacks of rice',
      subtitle: 'Stories from around the world',
      format: 'STORY',
      blocks: [
        PpIntro('Two brothers each secretly try to give the other more, and '
            'neither can work out why it is not working.'),
        PpArticle([
          'Two brothers farmed neighbouring fields. At harvest they divided the '
          'rice exactly in half, sack for sack, and each stored his share in '
          'his own barn.',
          'That night the elder brother lay awake thinking, my brother has a '
          'wife and children to feed and I have only myself. He got up in the '
          'dark, carried three sacks across to his brother barn, and went back '
          'to bed.',
          'At the same time the younger brother was lying awake thinking, my '
          'brother lives alone and has nobody to look after him when he is old. '
          'He got up, carried three sacks across to his brother barn, and went '
          'back to bed.',
          'In the morning each of them counted his sacks and found exactly the '
          'number he had started with, and neither could understand it. It went '
          'on for three nights. On the fourth, they met each other in the '
          'middle of the field in the dark, each with a sack on his shoulder, '
          'and understood everything.',
        ]),
        PpCards([
          PpCard('What it teaches',
              'The best kind of giving is the kind nobody was supposed to find '
              'out about.'),
          PpCard('Talk about it',
              'Why did they do it secretly instead of just offering?'),
        ], heading: 'After the story', hue: 190),
        PpWhenLine('From about four and a half.'),
        PpAudioSlot(
          title: 'Listen to this story',
          category: 'World tales',
          minutes: '4 MIN',
          slotId: 'learning/story/world_two_brothers_rice',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  DOOR 4 - Good habits, one habit at a time
// -----------------------------------------------------------------------------
//  AROUND 14,800 SEARCHES A MONTH, and almost all of the existing content is
//  either a chart with stars on it or a list of virtues. Neither works. So every
//  habit here is one page with the same four parts: why it matters, how to build
//  it, what to avoid, and one small named thing to do together.
//
//  NO STAR CHARTS. This is not squeamishness about rewards, it is the specific
//  finding that a reward attached to a behaviour a child was doing willingly
//  makes him do it less once the reward stops. Every "what to avoid" block here
//  says so in its own words. It is also the repo's standing rule: a count is
//  fine, a streak is not.
//
//  NAGGING AND SHAMING ARE NAMED AS THE FAILURE MODE on nearly every page,
//  because they are what a tired parent actually reaches for at eight in the
//  evening, and because shame reliably produces hiding rather than the habit.
//
//  WHERE THIS ENDS AND BEHAVIOUR BEGINS. Refusing, hitting back, tantrums about
//  the rule and screen-time battles belong to the Behaviour section, which is
//  built. These pages link there and stop.
// =============================================================================

const PpArea _habits = PpArea(
  id: 'habits',
  mark: IntentMark.timelineRail,
  title: 'The small habits that make a day easier',
  blurb: 'Fifteen habits, one page each. Why it matters, how to build it, and '
      'what makes it go wrong.',
  hue: 344,
  bands: _fromOne,
  pages: [
    PpPage(
      id: 'hab_brushing',
      title: 'Brushing teeth',
      format: 'ARTICLE',
      bands: _fromOne,
      blocks: [
        PpIntro('The habit most likely to end in a wrestling match, and the one '
            'that pays back most clearly. It gets easier once it stops being '
            'a negotiation.'),
        PpArticle([
          'Decay in milk teeth is very common in India. It hurts, it costs '
          'money, and it can affect the adult teeth coming in behind. '
          'Twice a day with a smear of fluoride toothpaste is the whole '
          'prevention.',
          'The hard part is not the brushing. It is that brushing happens when '
          'everybody is tired. Making it a fixed point in the evening, before '
          'the tiredness peaks, solves most of it.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Start the day the first tooth appears',
              'A soft brush or a clean cloth. A rice-grain smear of fluoride '
              'toothpaste for under threes, a pea-sized amount after that.'),
          PpStep('Make it the same two moments every day',
              'After the morning bath and just before the bedtime story. A '
              'fixed slot beats a reminder.'),
          PpStep('Your child brushes first, then you finish',
              'Their own turn matters to children. Your turn is the one that '
              'cleans the teeth, and children need help until about seven.'),
          PpStep('Brush your own teeth alongside',
              'Copying is the strongest force you have at this age.'),
          PpStep('Sing something two minutes long',
              'Time it with a song rather than a timer. It turns a chore into a '
              'routine.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Chasing your child around the house',
              'It turns brushing into a game of catch, and your child wins.'),
          PpCard('Sweet drinks in a bottle at bedtime',
              'Milk or juice pooling around the teeth all night is the '
              'biggest cause of early decay.'),
          PpCard('A star chart',
              'It works for a fortnight and then stops working, and the '
              'brushing often goes with it.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Play Find the Sugar Bugs. Your child '
            'brushes, then you take a torch and look for any bugs left behind, '
            'and those spots get brushed again. It takes thirty seconds, and '
            'the job moves from being told to being checked.'),
        PpWhenLine('From the first tooth, usually around six months. Supervise '
            'until about seven years.'),
        PpVideoSlot(
          title: "Brushing a toddler's teeth without a fight",
          subtitle: 'How to hold your toddler, where to stand, and what to do '
              'when the mouth clamps shut.',
          minutes: '5 MIN',
          slotId: 'learning/habit/brushing',
        ),
        PpCallout(
          'Brown or black marks on a tooth, a hole you can see, or pain when '
          'eating something cold all need a dentist, not harder brushing. '
          'If you do not have one, your paediatrician will tell you where to '
          'go. Decay does not reverse on its own.',
          kind: PpCalloutKind.doctor,
          title: 'When to see a dentist',
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpLink('Teeth: when they come, brushing and the first dentist',
                surfaceId: 'pp_page/parenting_health/teeth_brushing'),
      ],
    ),
    PpPage(
      id: 'hab_handwashing',
      title: 'Washing hands',
      format: 'ARTICLE',
      bands: _fromOne,
      blocks: [
        PpIntro('The cheapest illness prevention there is, and one small '
            'children take to easily because it involves water and mess.'),
        PpArticle([
          'Handwashing with soap before eating and after the toilet cuts '
          'diarrhoea and chest infections a lot. Both are common in small '
          'children in India, and this one habit does more than most '
          'supplements.',
          'The part that gets missed is the twenty seconds. A quick pass under '
          'the tap does very little, so the habit worth building is the length, '
          'not the act.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Put a stool at the basin so the tap is within reach',
              'A habit that needs help to start will not become automatic.'),
          PpStep('Keep the soap where a small hand lands',
              'A bar in a dish at child height, not a bottle to ask for.'),
          PpStep('Count or sing for twenty seconds',
              'One verse of any song. The song is the timer.'),
          PpStep('Name the four moments',
              'Before eating, after the toilet, after coming home, after '
              'playing outside. Four is easy to remember.'),
          PpStep('Hang your child\'s own towel at child height',
              'Wet hands wiped on clothes is where the habit slowly falls '
              'apart.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Doing it for your child',
              'You washing the hands is a different habit from your child '
              'washing them.'),
          PpCard('Only mentioning it when it is forgotten',
              'A habit built only out of corrections feels like being told '
              'off five times a day.'),
          PpCard('Sanitiser as the default',
              'Useful when out. Soap and water is better, and children swallow '
              'sanitiser more often than you would think.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Do the Pepper Trick once. Float ground '
            'black pepper on a bowl of water and dip a clean finger in: nothing '
            'happens. Dip a soapy finger and watch the pepper shoot to the '
            'edges. Children talk about it for weeks.'),
        PpWhenLine('From about eighteen months with help, and mostly done alone '
            'by three.'),
        PpIndiaNote('Where water is stored rather than running, keep a small '
            'lota and a soap dish by the storage drum, at child height. The '
            'habit depends on your child doing it without calling '
            'anyone.'),
      ],
    ),
    PpPage(
      id: 'hab_please_thankyou',
      title: 'Please and thank you',
      format: 'ARTICLE',
      bands: _fromTwo,
      blocks: [
        PpIntro('Not because it looks good in front of guests. A child who can '
            'ask for things pleasantly gets a warmer response from the world, '
            'for life.'),
        PpArticle([
          'Politeness at three is all imitation. Your child is not being '
          'considerate yet, only copying the words heard in moments like this '
          'one. That is exactly how it is meant to start.',
          'The care behind the words grows in later, at four and five, once '
          'children understand that the other person has feelings about it. '
          'Forcing that early usually produces a resentful mumble.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Say it to your child first, many times a day',
              'Thank you for bringing my slippers. Please pass me that. '
              'Children learn the words from hearing them aimed at themselves.'),
          PpStep('Say it to everybody, where your child can hear',
              'To the delivery man, to the person who cleans your house, to the '
              'auto driver. Children notice exactly who you are polite to.'),
          PpStep('Model the sentence instead of demanding it',
              'Say you can say, please give me water, rather than say please.'),
          PpStep('Hand the thing over anyway, then model it',
              'Holding back water until the magic word appears turns '
              'politeness into a toll.'),
          PpStep('Notice it when it happens on its own',
              'That was a nice way to ask. Once, lightly, not a fuss.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Performing for guests',
              'Say thank you to auntie, say it properly, in front of people is '
              'humiliating, and it works against you.'),
          PpCard('Only being polite to important people',
              'Your child is watching, and learns who you think deserves it.'),
          PpCard('Correcting the tone',
              'Say it nicely, again, turns a two-second exchange into a '
              'standoff.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Play Thank You at Dinner. Each person '
            'says one thing they are thankful for and one person they want to '
            'thank today. It takes two minutes, and the words become ordinary '
            'rather than ceremonial.'),
        PpWhenLine('From about two years for the words, and about four before '
            'they are really meant.'),
      ],
    ),
    PpPage(
      id: 'hab_sharing',
      title: 'Sharing',
      format: 'ARTICLE',
      bands: _fromTwo,
      blocks: [
        PpIntro('The habit parents most want, and the one most often asked for '
            'too early. A two-year-old who won\'t share is not selfish, just two.'),
        PpArticle([
          'Real sharing needs a child to understand that another person wants '
          'something, and to care about that more than about having it. That '
          'arrives around three and a half or four. No amount of insisting '
          'brings it forward.',
          'What can be built earlier is turn taking, which is quite '
          'different. My turn, then your turn, with a clear end to each turn, '
          'is manageable from about two. It is the road to sharing.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Use turns, not sharing, until about four',
              'When you are finished, it is Riya\'s turn. Not: give it to Riya now.'),
          PpStep('Let your child finish the turn',
              'Ending a turn on their own terms is what teaches children that '
              'giving something up is survivable.'),
          PpStep('Put away the two or three most precious things before guests '
              'arrive',
              'Nobody shares their favourite thing. Adults do not either.'),
          PpStep('Share out loud yourself',
              'I have got two, you can have one. Say it aloud so your child can '
              'hear the thinking.'),
          PpStep('Notice it once, plainly, when it happens',
              'You gave Riya a turn. Riya looked happy. No fuss, no reward.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Grabbing the toy and handing it over',
              'It teaches that the bigger person takes what they want, which '
              'is the opposite lesson.'),
          PpCard('Calling your child selfish',
              'The word sticks. Children who are told what they are tend to '
              'become it.'),
          PpCard('Forcing sharing in front of relatives',
              'It is about your embarrassment at that moment, and your child can '
              'feel it.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Use a Turn Timer: a small sand timer or a '
            'two-minute song. When it ends, the toy moves. The timer becomes '
            'the one saying no, not you, and the fighting drops sharply.'),
        PpWhenLine('Turn taking from about two years. Real sharing from '
            'about four, and unevenly even then.'),
        // ⚠️ THE OTHER VERSION, BY PAGE. Five habit pages also live in
        // Behaviour; the brief keeps both ("build the habit calmly" here,
        // "when it is going wrong right now" there) and cross-links them.
        // The link lands on that page, not on the door.
        PpLink(
          'When sharing turns into hitting and grabbing',
          // surfaceId: 'pp_section/parenting_behaviour',
          surfaceId: 'pp_page/parenting_behaviour/sharing',
          blurb: 'The Behaviour side: what to do in the moment.',
        ),
      ],
    ),
    PpPage(
      id: 'hab_tidying',
      title: 'Putting toys away',
      format: 'ARTICLE',
      bands: _fromOne,
      blocks: [
        PpIntro('Tidying up is far more doable than it looks, as long as '
            'there are fewer things out and a place for each of them.'),
        PpArticle([
          'A child cannot tidy a room with forty toys in it. The task is too '
          'big to see the end of, so the child stops. Having less out '
          'solves more of this than any technique.',
          'Tidying is also a sequence: pick up, carry, put in the right place, '
          'come back. That is real planning practice for the brain, which is '
          'why it is hard at two and easy at five.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Keep only a few things out at a time',
              'Three or four baskets on a low shelf, the rest in a cupboard, '
              'rotated weekly.'),
          PpStep('Give everything one obvious home',
              'One basket for blocks, one for cars. If you cannot say where a '
              'thing lives, your child certainly cannot.'),
          PpStep('Tidy together, not instead of your child',
              'You do the big things, your child does the small ones. '
              'Alongside works at this age, alone does not.'),
          PpStep('Make it the same moment every day',
              'Before dinner, or before the bedtime story. The story is the '
              'natural next thing, not a bribe.'),
          PpStep('Sing the same tidy-up song every time',
              'Two years of the same silly song is worth more than any '
              'reasoning.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Asking at the wrong moment',
              'Mid-game and just before bed are the two worst. Give a warning '
              'first: two more minutes, then we tidy.'),
          PpCard('Threatening to throw the toys away',
              'Children know you won\'t. And if you do, they learn their things '
              'are not safe with you.'),
          PpCard('Redoing it in front of your child',
              'It says the effort did not count.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Play Ten Things. Your child puts away ten '
            'things while you count them out loud, and then the job is done, '
            'whatever the room looks like. A finishable job gets started.'),
        PpWhenLine('From about eighteen months alongside you, and mostly alone '
            'by four or five.'),
      ],
    ),
    PpPage(
      id: 'hab_eating_self',
      title: 'Eating without help',
      format: 'ARTICLE',
      bands: _fromOne,
      blocks: [
        PpIntro('It is slower, it is messier, and it is one of the most '
            'important independence habits of the toddler years.'),
        PpArticle([
          'Children who feed themselves decide when they have had enough. That '
          'sense of their own fullness protects them for life. A child who is '
          'fed while distracted loses it early.',
          'Self feeding is also serious hand and mouth coordination practice, '
          'and it is one of the first things a preschool will expect.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Let your child use hands first, properly',
              'Hand feeding is how most of India eats, and it is excellent '
              'practice. Spoons can come later.'),
          PpStep('Bring your child to the family meal, at the same time as everyone',
              'Eating alone at four and being fed at eight is the pattern that '
              'stalls this.'),
          PpStep('Serve a small amount and offer more',
              'A full plate is discouraging. Seconds are encouraging.'),
          PpStep('Put a newspaper or a sheet under the chair',
              'Deciding in advance that mess is fine is what lets you stay '
              'relaxed.'),
          PpStep('Stop when your child stops, without persuading',
              'One more bite, ten times over, is how children learn to ignore '
              'their own stomachs.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Feeding in front of a screen',
              'Children eat more and notice less, and it is very hard to undo '
              'later.'),
          PpCard('Chasing your child around the house with the plate',
              'Food becomes something done to your child, not something your '
              'child does.'),
          PpCard('Comparing with the child next door',
              'Appetites vary enormously, and comparison at the table sours '
              'meals for years.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Give your child one Serving Job at every '
            'meal: rotis into the casserole, or curd spooned into '
            "everybody's bowls. Children eat noticeably better at a meal they "
            'helped serve.'),
        PpWhenLine('Hands from about eight months, a spoon with real success '
            'from about eighteen months to two years.'),
        PpLink(
          'What your child can eat at this age',
          surfaceId: 'pp_food',
          blurb: 'Meals, portions and recipes by age.',
        ),
      ],
    ),
    PpPage(
      id: 'hab_water',
      title: 'Drinking enough water',
      format: 'ARTICLE',
      bands: _fromTwo,
      blocks: [
        PpIntro('Small children forget to drink, especially when they are '
            'playing and especially in an Indian summer. It is an easy habit to '
            'build with one piece of furniture.'),
        PpArticle([
          'Mild dehydration in a small child shows up as crankiness, headache, '
          'dark wee and constipation, long before anybody thinks about water. '
          'It is one of the commonest hidden causes of a difficult afternoon.',
          'The reliable fix is access. A child who has to ask an adult every '
          'time drinks far less than one who can pour a glass alone.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Put a small jug and glass at child height',
              'A low table or a bottom shelf. This one change does most of the '
              'work.'),
          PpStep('Attach it to things that already happen',
              'A glass after coming home, after the toilet, and at each meal. '
              'Fixed moments beat reminders.'),
          PpStep('Send water out to play too',
              'In summer, a bottle goes wherever your child goes.'),
          PpStep('Drink water yourself where your child can see, often'),
          PpStep('Watch the wee rather than counting glasses',
              'Pale and often is right. Dark yellow and rare means more water.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Juice and sweet drinks to get fluids in',
              'They train a taste for sweet and they are hard on the '
              'teeth. Let water be the boring default.'),
          PpCard('Nagging your child to drink',
              'Access works, reminders do not.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Make a Water Station: your child\'s own '
            'steel glass and a small jug on a low stool, refilled by your child '
            'each morning. Owning the station is what makes it get used.'),
        PpWhenLine('From about two years for pouring alone. Water is offered '
            'from six months, alongside food.'),
        PpCallout(
          'Is your child not passing wee for many hours, unusually '
          'sleepy, dry in the mouth or refusing all fluids? See a doctor the '
          'same day, especially with fever, vomiting or loose motions.',
          kind: PpCalloutKind.doctor,
          title: 'When it is more than a habit',
        ),
      ],
    ),
    PpPage(
      id: 'hab_bedtime',
      title: 'Going to bed on time',
      format: 'ARTICLE',
      bands: _fromOne,
      blocks: [
        PpIntro('Late nights are normal in Indian homes, and they are not always '
            'a problem. What matters is that the last half hour is the same '
            'every night.'),
        PpArticle([
          'Predictability matters more than the clock time. A child whose '
          'evening runs in the same order every night falls asleep faster. '
          'The body starts winding down at the first step, not the last.',
          'That said, sleep is when growth happens and memories settle. A child '
          'who is short of sleep night after night is harder work in every '
          'other way the next day.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Pick four steps and never change their order',
              'Dinner, brush, pyjamas, story. Four is enough.'),
          PpStep('Dim the lights for the last half hour',
              'A bright tube light tells a small body it is still daytime.'),
          PpStep('Screens off well before bed',
              'If the end of the screen is the start of bedtime, the two '
              'become the same fight.'),
          PpStep('Keep the same wake-up time even after a late night',
              'Wake time anchors the whole rhythm more than bedtime does.'),
          PpStep('Say what comes next, always',
              'One more story and then lights off. Announced endings are much '
              'easier than sudden ones.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('A different routine every night',
              'Unpredictability is what makes bedtime a negotiation.'),
          PpCard('Bed as a punishment',
              'Go and sleep, said angrily, makes the bed a bad place to be.'),
          PpCard('Skipping the wind-down when you are late',
              'A shortened routine still works. Skipping it entirely usually '
              'costs you more time than it saves.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Make a Four Picture Card. Draw the four '
            'steps of bedtime and stick it up at child height. Your child '
            'points at what comes next instead of being told, which removes '
            'most of the arguing.'),
        PpWhenLine('From about one year for a fixed routine. It stays useful '
            'through primary school.'),
        PpLink(
          'Everything about sleep at this age',
          surfaceId: 'pp_section/parenting_sleep',
          blurb: 'How much sleep your child needs, night waking, and settling.',
        ),
      ],
    ),
    PpPage(
      id: 'hab_greeting',
      title: 'Greeting people, namaste and hello',
      format: 'ARTICLE',
      bands: _fromTwo,
      blocks: [
        PpIntro('Warmth towards people is worth teaching. Being made to perform '
            'for relatives is not, and the two get mixed up all the time.'),
        PpArticle([
          'Greeting is a small social skill with a large effect. A child who '
          'looks up and says hello is met with warmth almost everywhere. That '
          'warmth shapes how your child expects people to behave.',
          'But many children are uneasy with unfamiliar adults, and being '
          'pushed at them makes it worse. The goal is a child who greets '
          'people, not a child who obeys on cue.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Greet people warmly yourself, every time',
              'Including the guard, the maid and the delivery man. Your child '
              'is learning who counts as a person to greet.'),
          PpStep('Say who is coming before they arrive',
              'Grandma\'s sister is coming. She has not seen you since you were a '
              'baby. Getting ready ahead removes most of the freezing.'),
          PpStep('Offer a choice of greeting',
              'Namaste, a hello, or a wave. All three count.'),
          PpStep('A greeting from behind your leg is fine',
              'Standing close to you and saying it softly is a completely '
              'successful greeting at three.'),
          PpStep('Never force a hug or a kiss',
              'Your child\'s body, your child\'s choice. This is where that lesson '
              'starts.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Apologising for your child, within earshot',
              'Very shy, sorry, hands your child a label to grow into.'),
          PpCard('Making your child touch feet on command',
              'A tradition performed under pressure loses everything that made '
              'it warm.'),
          PpCard('Repeating say namaste four times',
              'The fourth time is about you, and everybody in the room can '
              'tell.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Play Doorbell Practice. Your child opens '
            'the door for family, says the greeting and offers water. Having a '
            'job removes the awkwardness completely.'),
        PpWhenLine('From about two years for the words. Comfort with '
            'unfamiliar adults often takes until four or five.'),
        PpIndiaNote('In a joint family the pressure to perform for visitors is '
            'real, and it comes from love. It usually helps to give your child '
            'a job instead, like carrying the water tray in. Everyone is happy '
            'and nobody is put on the spot.'),
      ],
    ),
    PpPage(
      id: 'hab_kindness',
      title: 'Being kind to other people',
      format: 'ARTICLE',
      bands: _fromThree,
      blocks: [
        PpIntro('Kindness is not taught by being told to be kind. It is caught, '
            'from watching how the people at home treat those who cannot do '
            'anything for them.'),
        PpArticle([
          'Small children are naturally sympathetic. A two-year-old will bring '
          'a blanket to a crying friend. What develops later is noticing '
          'somebody who is not making a noise about it.',
          'Children read behaviour far more accurately than words. How you '
          'speak to the person who cleans your house teaches more about '
          'kindness than any story, including the ones in this door.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Name feelings out loud, including strangers\'',
              'That uncle looks tired. Your friend went silent, maybe your '
              'friend is sad. Noticing is the skill.'),
          PpStep('Hand your child small kind jobs',
              'Carrying something for Grandma, saving a biscuit for a brother or '
              'sister, putting water out for the birds in summer.'),
          PpStep('Describe rather than praise',
              'You gave Riya your toy and the crying stopped, rather than good '
              'job. Your child learns the effect, not the approval.'),
          PpStep('Be kind where your child can see, when it costs something',
              'Letting someone go first, being patient with a slow shopkeeper.'),
          PpStep('Use the stories, then stop talking',
              'One question after a story does more than a lecture ever will.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Shaming your child into it',
              "Are you not ashamed, look how selfish you are, produces hiding, "
              'not kindness.'),
          PpCard('Rewarding kindness with money or treats',
              'It turns a good instinct into a transaction.'),
          PpCard('Being kind in public and harsh at home',
              'Children notice, and the home version is the one they learn.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Do One Kind Thing at dinner. Everyone '
            'says one kind thing they did or saw today. It makes kindness '
            'visible, which is most of the work.'),
        PpWhenLine('From about three years, once your child can name feelings. '
            'It grows steadily from there.'),
        PpLink(
          'Stories that carry this without a lecture',
          pageId: 'st_jat_monkey_bridge',
          blurb: 'The monkey king who went last.',
        ),
        PpLink(
          'Unkind right now: hitting, or falling out with a friend',
          surfaceId: 'pp_page/parenting_behaviour/beh_friendships',
          blurb: 'The Behaviour side, for the moment itself.',
        ),
      ],
    ),
    PpPage(
      id: 'hab_waiting',
      title: 'Waiting for a turn',
      format: 'ARTICLE',
      bands: _fromTwo,
      blocks: [
        PpIntro('Waiting is a skill that lives in a real part of the brain, and '
            'it is hard until about four. It can be built in small '
            'doses.'),
        PpArticle([
          'A two-year-old asked to wait ten minutes is being asked for '
          'something not yet possible. Waiting while you count to five is just '
          'about manageable, and that is where it starts.',
          'What makes waiting bearable is knowing how long. Time means nothing '
          'to a small child, so the wait has to be made visible: a timer, a '
          'song, a number of things.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Make the wait visible',
              'A sand timer, one song, or when this glass of water is finished.'),
          PpStep('Start with waits your child can win',
              'Ten seconds at two, a minute at three. Success is what builds '
              'the muscle.'),
          PpStep('Give your child something to do inside the wait',
              'Hold this for me, count the spoons. An empty wait is much '
              'harder.'),
          PpStep('Say out loud that it is hard',
              'It is hard to wait. You are doing it though.'),
          PpStep('Keep your side of it exactly',
              'When the song finishes, it is your child\'s turn, without fail. '
              'Waiting is only worth it if the end is reliable.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Just wait, with no end in sight',
              'A wait with no end is the same as no, for a small child.'),
          PpCard('Giving in halfway',
              'It teaches that whining shortens the wait, which is a habit that '
              'is expensive later.'),
          PpCard('Expecting patience from a hungry or tired child',
              'The patience is not there at that moment. Save the practice for '
              'another time.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Use a Turn Song. The same short song '
            'plays for each turn on the swing or the cycle. The song ends the '
            'turn instead of you, and the arguing drops away.'),
        PpWhenLine('Ten to thirty seconds from two years, a few minutes by four, '
            'and reliably by six.'),
        PpLink(
          'When waiting is already a fight',
          surfaceId: 'pp_page/parenting_behaviour/sharing',
          blurb: 'The Behaviour side: turns, grabbing, and the timer trick.',
        ),
      ],
    ),
    PpPage(
      id: 'hab_truth',
      title: 'Telling the truth',
      format: 'ARTICLE',
      bands: _fromThree,
      blocks: [
        PpIntro('Almost every young child lies, and almost none of it means '
            'what parents fear. How you react decides whether it grows '
            'or fades.'),
        PpArticle([
          'A three-year-old who says I did not spill it is often not lying in '
          'the adult sense. It is a wish, or the version your child would '
          'prefer. Truth and wish are not yet cleanly separate at that age.',
          'From four or five it becomes deliberate, and it is almost always to '
          'avoid trouble. So the size of the trouble is the strongest lever '
          'you have. A child frightened of the consequence gets better at '
          'hiding, not more honest.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Don\'t ask a question you already know the answer to',
              'Did you break this, when you saw it happen, is an invitation '
              'to lie. Say I saw the glass break, let us clean it up.'),
          PpStep('Make telling the truth cheap',
              'Thank you for telling me, now let us fix it. If honesty costs '
              'less than hiding, honesty wins.'),
          PpStep('Separate the mess from the lie',
              'Deal with the spilt milk first and calmly, and mention the '
              'telling separately.'),
          PpStep('Notice honesty out loud when it was hard',
              'That was hard to say and you said it. That is the whole reward '
              'needed.'),
          PpStep('Never call your child a liar',
              'A label becomes an identity, and an identity is much harder to '
              'change than a behaviour.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Interrogating your child',
              'Repeated questioning teaches a child to hold a story, which is '
              'a skill you did not want to teach.'),
          PpCard('A big punishment for the lie',
              'It raises the cost of honesty and makes the next lie better '
              'built.'),
          PpCard('Telling the story to relatives within your child\'s earshot',
              'Public shaming is remembered for years and changes nothing.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Read The boy who cried wolf and ask one '
            'question: why did nobody come the third time? It does the whole '
            'job with no lecture attached.'),
        PpWhenLine('Wishful stories from about three, deliberate ones from '
            'about four and a half. Both are normal.'),
        PpLink(
          'The story for this one',
          pageId: 'st_world_cried_wolf',
          blurb: 'The boy who cried wolf.',
        ),
        PpLink(
          'When your child has just told you a lie',
          surfaceId: 'pp_page/parenting_behaviour/beh_older_lying',
          blurb: 'The Behaviour side: what to say in the moment.',
        ),
      ],
    ),
    PpPage(
      id: 'hab_screens',
      title: 'Screens, as a habit rather than a battle',
      format: 'ARTICLE',
      bands: _fromTwo,
      blocks: [
        PpIntro('The habit here is when and how it ends, more than how much. A '
            'predictable screen time causes far fewer fights than a generous '
            'unpredictable one.'),
        PpArticle([
          'The hard part of screens is the ending. A show that stops when a '
          'parent decides feels random and brings on a tantrum. A show that '
          'stops at a point everybody agreed on in advance usually does not.',
          'For the how much question and for the fights themselves, the '
          'Behaviour section is the right place. This page is only about '
          'building the habit shape.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Fix the slot, not the amount',
              'After the evening bath, two episodes. Same time, same length, '
              'every day.'),
          PpStep('Agree the ending before it starts',
              'Two episodes and then we switch it off. Say it, and have your '
              'child say it back.'),
          PpStep('Warn before the end',
              'One minute left. An announced ending feels completely different '
              'from a sudden one.'),
          PpStep('Have the next thing ready',
              'Dinner on the table, or the blocks already out. An empty gap '
              'after a screen is where the crying goes.'),
          PpStep('Keep meals and the hour before bed screen free',
              'These two rules do more than any total time limit.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Screens to get through a meal',
              'It is the fastest way to lose both the eating habit and the '
              'screen habit at once.'),
          PpCard('Taking it away as a punishment for something unrelated',
              'It makes the screen enormous in your child\'s mind.'),
          PpCard('Endless autoplay',
              'A show that never ends by itself makes you the ending every '
              'time. Choose the episodes in advance.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Make a Two Card: two paper tickets a day, '
            'each worth one show. Your child hands one over to start. Holding '
            'the ending in a small hand changes the whole feeling of it.'),
        PpWhenLine('From about two years, when screens usually enter the '
            'picture. Under two, video calls with family are a different thing '
            'and are fine.'),
        PpLink(
          'When screens are already a daily fight',
          // surfaceId: 'pp_section/parenting_behaviour',
          surfaceId: 'pp_page/parenting_behaviour/beh_screen_ending',
          blurb: 'The Behaviour side: ending it without a meltdown.',
        ),
      ],
    ),
    PpPage(
      id: 'hab_hygiene',
      title: 'Bath, nails and hair, done alone',
      format: 'ARTICLE',
      bands: _fromThree,
      blocks: [
        PpIntro('Bathing, nails, hair, changing after playing outside. Small '
            'things that, together, teach a child to care for a growing body.'),
        PpArticle([
          'These jobs are usually done for a child for years, then suddenly '
          'expected. Handing them over one at a time, early, avoids that '
          'cliff.',
          'There is a second reason, worth naming. Children who know their '
          'bodies are theirs to look after are better placed to speak up about '
          'anything that feels wrong. Body ownership starts in ordinary places '
          'like this.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Hand over one job at a time',
              'This month your child soaps arms and legs. Next month, drying '
              'off.'),
          PpStep('Make the tools reachable',
              'A stool, a low hook for the towel, a comb kept within easy '
              'reach.'),
          PpStep('Attach each job to a fixed moment',
              'Nails on Sunday. Change clothes as soon as we come in from '
              'playing.'),
          PpStep('Offer choices within limits',
              'Which of these two shirts. Choice is what makes it your '
              'child\'s own.'),
          PpStep('Use correct names for body parts',
              'It makes your child precise, it removes shame, and it matters '
              'if your child ever needs to tell you something.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Doing it all for speed',
              'Quicker today, and it delays the handover by a year.'),
          PpCard('Making your child feel dirty',
              'Yuck, dirty, said often, attaches shame to the body itself '
              'rather than to the mud.'),
          PpCard('Nicknames for private parts',
              'They make it harder for your child to tell you clearly if '
              'something happens.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Make a My Body Chart: four small drawings '
            'of the jobs your child now owns, at child height in the bathroom. '
            'Your child checks the pictures rather than being told.'),
        PpWhenLine('From about three years for the first jobs, most of them by '
            'six.'),
      ],
    ),
    PpPage(
      id: 'hab_helping',
      title: 'Helping at home',
      format: 'ARTICLE',
      bands: _fromTwo,
      blocks: [
        PpIntro('Small children want to help far more than older ones do. If '
            'you use that window at two and three, it does not close.'),
        PpArticle([
          'The urge to join in with adult work is strongest between two '
          'and four, exactly when the help is least useful. Families that '
          'accept the slower, messier version in those years usually have a '
          'child who still helps at eight.',
          'Helping is also where a child learns that a household is shared, '
          'not a service. That belief is very hard to put in later by '
          'asking.',
        ], heading: 'Why this one matters'),
        PpSteps([
          PpStep('Say yes when your child offers, even when it is inconvenient',
              'A refused offer at three is not repeated at eight.'),
          PpStep('Give a real job, not a pretend one',
              'Tearing coriander, putting spoons away, carrying a plate to '
              'the sink.'),
          PpStep('Make the tools child-sized',
              'A small broom, a light jug, a low stool at the counter.'),
          PpStep('Accept the standard your child can manage',
              'A crooked stack of spoons is a success.'),
          PpStep('Say thank you the way you would to an adult',
              'That was a real help, thank you. Not a reward, just the truth.'),
        ], heading: 'How to build it'),
        PpCards([
          PpCard('Paying for chores',
              'It turns belonging into employment, and the price goes up '
              'every year.'),
          PpCard('Only asking the girls',
              'Children notice this immediately and it lasts a lifetime.'),
          PpCard('Redoing the work while your child watches',
              'It says plainly that the help was not real.'),
        ], heading: 'What to avoid', hue: 344),
        PpCallout('Try this together. Give your child a Helper of the Day role: '
            'one rotating job for the whole day, announced at breakfast. '
            'Children take a named role far more seriously than an instruction.'),
        PpWhenLine('From about two years alongside you. A job your child owns '
            'from about four.'),
        PpLink(
          'The activity version of this',
          pageId: 'act_his_own_job',
          blurb: 'A job to own, in the activities above.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  DOOR 5 - Early skills, through play
// -----------------------------------------------------------------------------
//  THE MOST DANGEROUS DOOR IN THE SECTION, and the reason the anti-drilling
//  callout appears on all four pages rather than once in an intro.
//
//  A parent arrives here having been told by a relative, a neighbour or a
//  preschool that her three-year-old should be writing. She is anxious, and an
//  anxious parent will buy a worksheet book on the way home. The four pages
//  below have to be more useful than that book while saying clearly that the
//  book is the wrong thing, and being merely disapproving would send her
//  straight back to it.
//
//  So each page answers the real question, which is what do I do instead, with
//  named activities from Door 1 rather than a general principle.
// =============================================================================

const PpArea _earlySkills = PpArea(
  id: 'early_skills',
  mark: IntentMark.bodyMark,
  title: 'Getting ready to read, write and count',
  blurb: 'What really comes before letters and numbers, and why the '
      'worksheets can wait.',
  hue: 268,
  bands: _fromTwo,
  pages: [
    PpPage(
      id: 'skills_prewriting',
      title: 'What comes before writing',
      format: 'ARTICLE',
      bands: _fromTwo,
      blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'What comes before writing',
          subtitle: 'Why scribbling, tearing paper and picking up daal matter more than holding a pencil correctly.',
          minutes: '5 MIN',
          slotId: 'early_learning/prewriting',
        ),
        PpIntro('Writing sits on top of about four years of other work. Skip '
            'that work and start with letters, and the letters are harder, and '
            'they stay harder.'),
        PpArticle([
          'Holding a pencil comfortably needs a strong shoulder, a steady '
          'wrist, and fingers that can move on their own. None of those are '
          'built by writing. They are built by hanging from things, '
          'squeezing things, tearing, threading, pouring and playing with dough.',
          'On top of that sits the six shapes every letter is built from: the '
          'down line, the across line, the circle, the cross, the diagonal and '
          'the zigzag. A child who draws those confidently learns letters '
          'quickly. Without them, letters stay a struggle however long the '
          'practice.',
        ], heading: 'What it really is'),
        PpSteps([
          PpStep('Build the shoulder and hand first',
              'Hanging, climbing, carrying a heavy bucket, squeezing a wet '
              'cloth, kneading dough, tearing newspaper.'),
          PpStep('Work big and vertical',
              'Paper taped to a wall, drawing in the air, chalk on the floor. '
              'Small paper on a table is the last stage, not the first.'),
          PpStep('Use a tray of flour or wet sand',
              'One finger, no pressure, endlessly repeatable, and nothing to '
              'get wrong.'),
          PpStep('Do the six shapes, not letters',
              'Down, across, round, cross, slanting, zigzag.'),
          PpStep('Move to a crayon, then a pencil, when the shapes are easy',
              'For most children that is somewhere between four and five.'),
        ], heading: 'How to do it'),
        PpCards([
          PpCard('Worksheet books at two and three',
              'They ask for control the hand does not have yet. The usual '
              'result is a child who says, I am bad at writing.'),
          PpCard('Holding your child\'s hand and moving it',
              'Children learn nothing from a movement they did not make.'),
          PpCard('Correcting the grip constantly',
              'Grip settles between four and six on its own in a child who does '
              'plenty of hand work. Nagging does not speed it up.'),
        ], heading: 'What to avoid', hue: 268),
        PpCallout(
          'This is readiness through play, not academics. There is no evidence '
          'that a child who writes at three reads or writes better at eight, '
          'and good evidence that early pressure puts children off. '
          'Play, and start formal writing when your child\'s hand is ready.',
          kind: PpCalloutKind.myth,
          title: 'Earlier is not better',
        ),
        PpWhenLine('Hand-strengthening play from two. The six shapes from '
            'three. Letters from four or five, and only if your child is '
            'interested.'),
        PpLink(
          'The activity for this',
          pageId: 'act_prewriting_lines',
          blurb: 'Lines, zigzags and circles, in a tray of flour.',
        ),
        PpLink(
          'And the one before it',
          pageId: 'act_mark_making',
          blurb: 'Scribbling with fat crayons, from two years.',
        ),
      ],
    ),
    PpPage(
      id: 'skills_numeracy',
      title: 'First numbers, without a single worksheet',
      format: 'ARTICLE',
      bands: _fromTwo,
      blocks: [
        PpIntro('Counting to fifty is a song. Knowing that four means four '
            'things is maths. Almost all the value is in the second one.'),
        PpArticle([
          'Number sense is built from four things: counting objects by '
          'touching them, matching one thing to one thing, knowing how many '
          'without recounting, and comparing more and less. All four are built '
          'with utensils and stones, not on paper.',
          'A child who is secure with numbers up to five, and then to ten, has '
          'a far better base than one who can recite to a hundred. The '
          'reciting looks more impressive to visitors and means far '
          'less.',
        ], heading: 'What it really is'),
        PpSteps([
          PpStep('Count things you are touching, every day',
              'Stairs, rotis, bangles, buttons, steps to the gate.'),
          PpStep('Play give me three',
              'Much harder than counting, and the skill that really matters.'),
          PpStep('Lay the table together',
              'One spoon for each person is one-to-one matching, which is the '
              'idea underneath arithmetic.'),
          PpStep('Compare, out loud, constantly',
              'Who has more? Which is bigger? Is this enough for everybody?'),
          PpStep('Add and take away with objects from four years',
              'Cashews, stones, caps. The story of the sum first, the symbols much '
              'later.'),
        ], heading: 'How to do it'),
        PpCards([
          PpCard('Rote counting drills',
              'Reciting numbers without objects builds a party trick, not '
              'understanding.'),
          PpCard('Number writing at three',
              'Same problem as letters. The hand is not ready, and the idea '
              'does not need paper.'),
          PpCard('Testing your child in front of people',
              'Count to twenty for auntie, sweetheart, is the fastest way to make '
              'numbers feel like an exam.'),
        ], heading: 'What to avoid', hue: 268),
        PpCallout(
          'Play, not drilling. A toddler who is made to sit and do number work '
          'learns that numbers are a chore. Everything on this page happens '
          'while doing something else, which is why it sticks.',
          kind: PpCalloutKind.key,
        ),
        PpWhenLine('Counting objects from two and a half. How many without '
            'recounting from about four. First sums from four to five.'),
        PpLink(
          'The activity for this',
          pageId: 'act_counting_games',
          blurb: 'Counting the stairs and the rotis.',
        ),
        PpLink(
          'And the next one',
          pageId: 'act_first_sums',
          blurb: 'First sums with cashews and stones, from four.',
        ),
      ],
    ),
    PpPage(
      id: 'skills_literacy',
      title: 'Getting ready to read',
      format: 'ARTICLE',
      bands: _fromTwo,
      blocks: [
        PpIntro('Reading is built out of listening, long before it is built out '
            'of letters. Almost everything useful you can do before five is '
            'spoken.'),
        PpArticle([
          'Three ear skills predict reading better than anything else: hearing '
          'rhyme, clapping the parts of a word, and hearing the first sound in '
          'a word. None of them need print, and all three can be played in an '
          'auto or a queue.',
          'The fourth piece is knowing what print is for. A child who has '
          'watched you follow words with a finger, turn pages, and read a shop '
          'sign aloud knows those marks carry meaning. The letters then attach '
          'to that idea.',
        ], heading: 'What it really is'),
        PpSteps([
          PpStep('Read aloud every day, in any language',
              'The strongest thing on this page.'),
          PpStep('Play rhyming games',
              'Which words sound the same? Nonsense words count.'),
          PpStep('Clap the parts of words',
              'Cha-pa-ti. Ba-nan-a. Harder than it sounds and very useful.'),
          PpStep('Play first sounds from three and a half',
              'What starts with mmm. Use the sound, not the letter name.'),
          PpStep('Point at print in the real world',
              'The bus number, the shop board, the name on your child\'s bag.'),
        ], heading: 'How to do it'),
        PpCards([
          PpCard('Flash card drilling',
              'It teaches letter names, the least useful part, and it makes '
              'reading feel like a test your child can fail.'),
          PpCard('Reading apps instead of a lap',
              'The value of a story is mostly in the person telling it and the '
              'talking around it.'),
          PpCard('Pushing your child to read words at three',
              'Most children are not ready before five or six, and being early '
              'has no lasting advantage.'),
        ], heading: 'What to avoid', hue: 268),
        PpCallout(
          'Readiness through play, not academics. A child who is read to daily '
          'and plays sound games arrives at reading with everything needed. A '
          'child drilled on flash cards arrives with letter names and no '
          'appetite.',
          kind: PpCalloutKind.myth,
          title: 'Flash cards are not reading',
        ),
        PpWhenLine('Reading aloud from birth. Rhyme from three. First sounds '
            'from three and a half. Real reading, for most children, from '
            'five or six.'),
        PpLink(
          'The activity for this',
          pageId: 'act_letter_sounds',
          blurb: 'What starts with mmm, a listening game.',
        ),
        PpCallout(
          'Is your child very hard to understand at three, mishearing often, or '
          'not responding to sounds from behind? Ask your paediatrician about a '
          'hearing check. Sound games cannot work through blocked ears, and '
          'fluid after repeated colds is common and treatable.',
          kind: PpCalloutKind.doctor,
          title: 'When to get hearing checked',
        ),
      ],
    ),
    PpPage(
      id: 'skills_colours_shapes',
      title: 'Colours, shapes and sorting',
      format: 'ARTICLE',
      bands: _fromTwo,
      blocks: [
        PpIntro('The steady base under both maths and reading: '
            'noticing that things are alike, and that they are different.'),
        PpArticle([
          'Sorting comes before counting. Before a child can count four spoons, '
          'the spoons have to be seen as four of the same kind of thing. '
          'Sorting games build that grouping.',
          'Telling similar shapes apart is also exactly what reading asks for '
          'later, when two letters differ only by which way a stick points. A '
          'child who has matched lids to boxes for a year finds that easy.',
        ], heading: 'What it really is'),
        PpSteps([
          PpStep('Sort by one thing at a time',
              'Colour first, then size, then shape. Two groups before '
              'three.'),
          PpStep('Use household objects, not a toy set',
              'Bottle caps, two kinds of dal, spoons and forks, big and small '
              'stones.'),
          PpStep('Name shapes in real things',
              'The roti is a circle. The window is a rectangle. The samosa is '
              'a triangle.'),
          PpStep('Play find something red around the house'),
          PpStep('Make patterns from about three',
              'Cap, spoon, cap, spoon. Then stop and let your child continue it.'),
        ], heading: 'How to do it'),
        PpCards([
          PpCard('Quizzing your child on colours',
              'What colour is this, again and again, turns a game into a test.'),
          PpCard('Correcting every mistake',
              'Just name it correctly in passing. Your child will sort it out '
              'within a few weeks.'),
        ], heading: 'What to avoid', hue: 268),
        PpCallout(
          'All of this is play. Nothing here needs a child to be sat '
          'down and taught, and sitting a child down is what makes it feel '
          'like work.',
          kind: PpCalloutKind.key,
        ),
        PpWhenLine('Sorting by colour from about eighteen months. Shapes from '
            'two and a half. Patterns from three.'),
        PpLink(
          'The activity for this',
          pageId: 'act_colour_sort',
          blurb: 'Sorting into two bowls, from eighteen months.',
        ),
        PpLink(
          'And the harder version',
          pageId: 'act_patterns',
          blurb: 'Making a pattern and continuing it, from three.',
        ),
      ],
    ),
    // ⚠️ [NEW], a scaffold. "The push to start ABCs and English at two is
    // intense in Indian homes. The section refuses worksheets everywhere,
    // but does not yet give the parent the words to hold that line on
    // language." Copy supplied, not generated.
    PpPage(
      id: 'skills_language',
      title: 'English or the mother tongue, and when to start letters',
      subtitle: 'The words to hold the line when the pressure starts at two',
      format: 'ARTICLE',
      bands: _fromOne,

      blocks: [
            // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
            // REQUIRED_REVIEW.
            PpIntro('From about two, the pressure starts: ABC classes, English '
                'worksheets, flash cards. Here is the honest picture, and the '
                'words to hold the line when the family worries it is getting '
                'late.'),
            PpArticle(heading: 'Your mother tongue is an advantage', [
              'Children who are fluent in their home language learn English, and '
                  'reading, more easily, not less. The thinking and vocabulary '
                  'built in one language carry over to the next. Many Indian '
                  'children grow up with two or three languages, and that is a '
                  'gift.',
              'Speak to your child in the language you are most at ease in. '
                  'Rich, warm talk in Hindi, Tamil or Bengali is worth far more '
                  'than stilted English.',
            ]),
            PpArticle(heading: 'When to start letters', [
              'Before about four or five, play builds what reading needs: '
                  'listening to stories, rhymes, noticing sounds, holding a '
                  'crayon, and talking a lot. Worksheets and drilling letters '
                  'at two or three add little and can put a child off.',
              'If letters spark curiosity, follow that lead. Point out the '
                  'first letter of your child\'s name on signs, play with letter '
                  'puzzles. Fun, never a test.',
            ]),
            PpCallout('Songs, stories and cooking together keep a mother '
                'tongue alive: a lullaby at bedtime, nursery rhymes in your '
                'language, naming spices as you cook.'),
            PpScript(heading: 'When the family worries', [
              PpScriptLine(
                  say: 'We read to our child every day in both languages. '
                      'Letters come easily later when the talking is strong.',
                  notThis: 'Tuition has to start now, or it will be too '
                      'late.',
                  why: 'Talking first, letters later, is what the evidence '
                      'shows.'),
            ]),
          ],
    ),
  ],
);

// =============================================================================
//  DOOR 6 - Getting ready for school
// -----------------------------------------------------------------------------
//  THE STUB THAT EXISTED HERE ANSWERED NOTHING, and the honest filling of it is
//  mostly a correction. Indian preschool marketing has taught a generation of
//  parents that readiness means reading, writing and counting, and every
//  admission conversation reinforces it.
//
//  The evidence says the opposite, and it says it clearly: what predicts a good
//  first year is whether a child can manage himself for a few hours away from
//  his parent. Toilet, food, shoes, sitting with a group, following two
//  instructions, asking for help, and surviving the separation. A child who can
//  do those and cannot write learns to write in a term. A child who can write
//  and cannot do those has a miserable year.
//
//  So this door leads with that, checklists it, and then handles the two things
//  a parent actually loses sleep over: choosing the place, and the crying at the
//  gate.
// =============================================================================

// =============================================================================
//  [NEW] Rhymes and songs — the collection the section had none of
// -----------------------------------------------------------------------------
//  "The section has 58 stories and not one rhyme, and rhymes are half of
//  early learning at this age." Audio-first like the stories, original or
//  public-domain only. The collection is a scaffold until the copy and the
//  recordings land; one card holds the place. Logged in
//  docs/DOOR-CONTENT-OWED.md; the door test holds it there.
// =============================================================================

const PpArea _rhymes = PpArea(
  id: 'rhymes',
  mark: IntentMark.feedMark,
  title: 'Rhymes and songs',
  blurb: 'Action rhymes and songs in Hindi, English and the languages at '
      'home, to listen to and do together.',
  hue: 42,
  pages: [
    PpPage(
      id: 'rhymes_collection',
      title: 'Rhymes and songs',
      subtitle: 'Clapping, actions and the tunes the house already knows',
      format: 'AUDIO LIBRARY',
      comingSoon: true,
      blocks: [],
    ),
  ],
);

const PpArea _school = PpArea(
  id: 'school',
  mark: IntentMark.cuppedHands,
  title: 'Getting ready for school',
  blurb: 'What readiness really means, how to choose a place, and how to '
      'get through the first week.',
  hue: 206,
  bands: _fromThree,
  pages: [
    PpPage(
      id: 'school_what_readiness',
      title: 'What school readiness really means',
      format: 'ARTICLE',
      bands: _fromThree,
      blocks: [
        PpIntro('It is not reading. It is not writing. It is whether your child '
            'can manage for three hours in a room full of other children, '
            'without you.'),
        PpArticle([
          'Ask any experienced preschool teacher which children have a good '
          'first term. It is never the ones who arrived knowing their letters. '
          'It is the ones who can go to the toilet, eat their own lunch and put '
          'on their own shoes. They can sit with a group for ten minutes and ask '
          'an adult for help.',
          'That is not a lowering of the bar. Those skills are harder to build '
          'than letter recognition and they take longer. That is exactly why '
          'the year before school is best spent on them.',
          'The academic part follows easily once a child is settled, confident '
          'and able to pay attention. An anxious child who cannot yet sit or '
          'manage alone will not read on schedule, however early the letters '
          'started.',
        ], heading: 'The honest version'),
        PpCards([
          PpCard('Can manage the body basics',
              'Toilet, hands, eating, shoes, water bottle.'),
          PpCard('Can be apart from you',
              'A few hours with a familiar adult who is not a parent.'),
          PpCard('Can be with other children',
              'Not sharing perfectly, just able to be in a group without '
              'panic.'),
          PpCard('Can follow two instructions',
              'Put your bag on the hook and come and sit down.'),
          PpCard('Can ask for what is needed',
              'I need a wee. I do not like this. Help me.'),
          PpCard('Can sit and pay attention for ten minutes',
              'To a story, to a chosen task. This is built by not being '
              'interrupted at home.'),
        ], heading: 'What really matters', hue: 206),
        PpCallout(
          'School readiness is independence and social skill, not early '
          'academics. If a preschool tells you a three-year-old must be '
          'writing, that is a claim about their marketing, not about your '
          'child.',
          kind: PpCalloutKind.myth,
          title: 'The thing everybody gets wrong',
        ),
        PpWhenLine('Worth thinking about from about three, and worth working on '
            'in the six months before school starts.'),
        PpIndiaNote('In a joint family a child is often dressed, fed and '
            'carried by four loving adults. That is lovely, and it does delay '
            'exactly the skills school will ask for. One talk with everyone '
            'at home, six months before school starts, is usually all it '
            'takes.'),
        PpVideoSlot(
          title: 'What readiness really means',
          subtitle: 'A preschool teacher on which children settle well, and '
              'what teachers wish parents had practised instead of letters.',
          minutes: '7 MIN',
          slotId: 'learning/school/readiness_explainer',
        ),
      ],
    ),
    PpPage(
      id: 'school_checklist',
      title: 'The readiness checklist',
      format: 'CHECKLIST',
      bands: _fromThree,
      blocks: [
        PpIntro('Go through this in the six months before school starts. It is '
            'a list of things to practise, not a test to pass or fail.'),
        PpTable(
          columns: ['What to practise', 'What it looks like when it is there'],
          rows: [
            ['Toilet alone', 'Tells an adult in time, manages own '
                'clothes, washes hands afterwards'],
            ['Eating own lunch', 'Opens the box, eats without being fed, '
                'finishes in about twenty minutes'],
            ['Drinking from own bottle', 'Opens and closes it without '
                'soaking the bag'],
            ['Shoes and socks', 'Gets them on, even if they are on the wrong '
                'feet'],
            ['Being apart from you', 'A few hours with a grandparent or a '
                'neighbour without distress'],
            ['Sitting with a group', 'Stays for a ten minute story with other '
                'children around'],
            ['Two step instructions', 'Put this away and come here, done '
                'without a reminder'],
            ['Asking for help', 'Speaks to an unfamiliar adult when something '
                'is needed'],
            ['Saying own name', 'Clearly enough for a stranger to '
                'understand'],
            ['Playing near other children', 'Alongside them without hitting or '
                'panicking'],
          ],
          heading: 'The ten that matter',
        ),
        PpSteps([
          PpStep('Pick the two weakest and work only on those',
              'Ten at once is overwhelming for both of you.'),
          PpStep('Practise them in real life, not as drills',
              'Lunch in the real lunch box at home. Shoes on before every '
              'trip out.'),
          PpStep('Build in the extra ten minutes',
              'Almost all of these fail because of rushing, not because a '
              'child cannot.'),
          PpStep('Do a practice separation',
              'Two hours at a relative house, then half a day. Twice before '
              'school starts.'),
          PpStep('Stop practising a week before school starts',
              'Keep the last week calm and ordinary.'),
        ], heading: 'How to use this list'),
        PpCallout('Nothing on this list is about letters or numbers, and that '
            'is on purpose. A child who arrives able to do these things learns '
            'the academic part comfortably, in good time.'),
        PpWhenLine('Start about six months before school begins. Most children '
            'have most of this by three and a half to four.'),
        PpCallout(
          'Is your child at four doing almost none of this, not speaking in '
          'sentences, not turning when called by name, or unable to bear being '
          'near other children? Talk to your paediatrician before school '
          'starts, not after. Support that begins early works better, and '
          'this is a conversation, not a diagnosis.',
          kind: PpCalloutKind.doctor,
          title: 'When to ask someone first',
        ),
        PpLink(
          'Where your child is developmentally',
          surfaceId: 'pp_development',
          blurb: 'Milestones and speech, kept in one place.',
        ),
      ],
    ),
    PpPage(
      id: 'school_choosing',
      title: 'Choosing a preschool',
      format: 'ARTICLE',
      bands: _fromThree,
      blocks: [
        PpIntro('The building matters far less than what happens inside it. '
            'Spend your visit watching the children, not the marketing '
            'material.'),
        PpArticle([
          'Most Indian preschools sit somewhere on a line between play-based '
          'and academic. Play-based means the day is built around choosing, '
          'moving, making and talking. Academic means worksheets, writing '
          'practice and a syllabus for three-year-olds.',
          'The research is clear about which suits this age, and honest about '
          'the size of the difference. Children from academic preschools may '
          'score slightly higher at five, and the gap has gone by seven. The '
          'difference in how much they enjoy school tends to last.',
          'That said, the biggest factor of all is the teacher, and how warm '
          'that teacher is. A warm teacher in an ordinary school beats a '
          'cold one in a beautiful building every time.',
        ], heading: 'What you are really choosing between'),
        PpSteps([
          PpStep('Visit during a working session, not at admission time',
              'Ask to stand at the back for fifteen minutes on an ordinary '
              'day. A school that refuses has told you something.'),
          PpStep('Watch the children, not the walls',
              'Are they busy and talking, or waiting and silent? Are they '
              'moving? Do they go to the teacher easily?'),
          PpStep('Watch how a crying child is handled',
              'These are the most telling thirty seconds of your visit.'),
          PpStep('Ask what a normal day looks like, hour by hour',
              'Count how much of it is sitting.'),
          PpStep('Check the practical things',
              'Toilets, drinking water, how many adults per child, what '
              'happens if a child is unwell, who is at the gate.'),
        ], heading: 'How to look'),
        PpCards([
          PpCard('How many children to one adult?',
              'Under three years, fewer than eight per adult. Three to five, '
              'fewer than fifteen.'),
          PpCard('What do the children do all morning?',
              'Listen for choosing, playing and outdoor time in the answer.'),
          PpCard('How much writing do three-year-olds do?',
              'An honest answer of very little is a good sign.'),
          PpCard('What do you do when a child is upset?',
              'You want comfort in the answer, not a policy.'),
          PpCard('How do you tell parents about the day?',
              'And how quickly can I speak to the teacher if I need to?'),
          PpCard('How long have the teachers been here?',
              'Children feel teachers leaving more than anything else on '
              'this list.'),
        ], heading: 'Six questions worth asking', hue: 206),
        PpCallout('Be careful of a school that markets what three-year-olds '
            'will be able to write by March. It tells you what their day is '
            'built around.'),
        PpWhenLine('Most Indian children start playgroup at two and a half to '
            'three, and nursery at three to four. Starting later is not a '
            'disadvantage.'),
        PpIndiaNote('Fees vary enormously, and expensive is not the same as '
            'better. A neighbourhood school with a warm teacher and a bit of '
            'outdoor space is a good choice, and the money saved is '
            'worth more later.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpCallout('Ask how much screen time and how many apps the '
                'preschool uses. Young children learn best through play, '
                'talk and hands-on activity; tablets add little at this age.'),
      ],
    ),
    PpPage(
      id: 'school_first_day',
      title: 'The crying at the gate',
      format: 'STEP-LIST',
      bands: _fromThree,
      blocks: [
        PpIntro('Almost every child cries at drop-off, and almost every one of '
            'them stops within ten minutes of you leaving. Knowing that does '
            'not make it easier, but it does make it bearable.'),
        PpArticle([
          'Crying at separation, at this age, shows a healthy bond. It does '
          'not mean anything is wrong, or that the school is bad. Your child '
          'cries out of wanting to be with you, which is what a securely '
          'attached three-year-old feels.',
          'What matters is the shape of the goodbye. A short, confident, '
          'predictable goodbye settles a child faster than a long loving one. '
          'A drawn-out departure says there is something here worth being '
          'afraid of.',
        ], heading: 'Why it happens'),
        PpSteps([
          PpStep('Visit the school together twice before the first day',
              'Walk in, see the toilet, meet the teacher, come home. Familiar '
              'is half the battle.'),
          PpStep('Practise being apart in advance',
              'Two hours somewhere else, a few times, in the month before.'),
          PpStep('Say exactly what will happen',
              'I will leave you with Sunita, you will have snack and play, '
              'and I will come back after your lunch box is finished.'),
          PpStep('Invent one small goodbye ritual and never change it',
              'Two hugs and a wave from the gate. The same one every day.'),
          PpStep('Say goodbye and go',
              'Don\'t sneak out and don\'t come back. Sneaking out teaches your '
              'child to watch for you all morning, for the rest of the term.'),
          PpStep('Come back exactly when you said',
              'Being early is fine. Being late once costs a week.'),
          PpStep('Ask the teacher how long the crying lasted',
              'Almost always the answer is a few minutes. That fact is what '
              'gets you through the next morning.'),
        ], heading: 'The first two weeks'),
        PpCards([
          PpCard('A long emotional goodbye',
              'It raises the alarm rather than lowering it.'),
          PpCard('Leaving without saying goodbye',
              'It buys a calm exit today and a much clingier child for weeks.'),
          PpCard('Bribes at the gate',
              'It turns going to school into a daily negotiation.'),
          PpCard('Threatening with the teacher',
              'Making the school frightening to get obedience at home is very '
              'hard to undo.'),
        ], heading: 'What to avoid', hue: 206),
        PpCallout('Expect it to get worse in week three. Many children '
            'settle at once, then protest once the novelty wears off and '
            'they realise this is permanent. It passes.'),
        PpWhenLine('Most children settle within two to four weeks. Some take a '
            'term, and that is still within normal.'),
        PpCallout(
          'Still deeply distressed after about six weeks? Not eating or '
          'sleeping, withdrawn at home, or frightened of one particular adult? '
          'Talk to the teacher first and then to your paediatrician. Distress '
          'that lasts at that level is worth looking at properly, not waiting '
          'out.',
          kind: PpCalloutKind.doctor,
          title: 'When it is more than settling in',
        ),
        PpLink(
          'Separation anxiety in general',
          surfaceId: 'pp_section/parenting_behaviour',
          blurb: 'The Behaviour section covers clinginess beyond the school '
              'gate.',
        ),
      ],
    ),
    PpPage(
      id: 'school_what_next',
      title: 'What comes after preschool',
      format: 'SHORT ARTICLE',
      bands: ['four'],
      blocks: [
        PpIntro('Once school is settled, the useful thing you do at home '
            'changes shape. It stops being readiness and becomes the '
            'things school does not have time for.'),
        PpArticle([
          'School will handle letters, numbers and the syllabus. With thirty '
          'children in a room, it usually cannot give your child time to talk, '
          'to build something over three days, or to be listened to '
          'properly.',
          'So the home job flips. Less teaching, more conversation, more '
          'making, and more reading aloud, long past the age of reading '
          'alone. Plus one small responsibility that belongs to your child.',
        ], heading: 'The handover'),
        PpCards([
          PpCard('Keep reading aloud',
              'Long after your child can read alone. Understanding by ear runs '
              'years ahead of reading ability.'),
          PpCard('Talk at dinner, every day',
              'Vocabulary at eight is built more at the table than in the '
              'classroom.'),
          PpCard('Protect free time',
              'A child with three classes after school has no time to be bored, '
              'and boredom is where a child\'s own ideas come from.'),
          PpCard('Let your child speak to people',
              'Ordering a dosa, greeting a neighbour, telling the family '
              'about the day.'),
          PpCard('One real responsibility',
              'A job your child owns, kept up over months.'),
        ], heading: 'What to do at home now', hue: 206),
        PpCallout('Resist the urge to fill the afternoon with classes. A child '
            'who has time to play, potter and be bored is not losing out.'),
        PpWhenLine('From about four and a half, once school is a settled part '
            'of the week.'),
        PpLink(
          'Speaking and confidence, for later',
          pageId: 'act_show_and_tell',
          blurb: 'Talking to the family for one minute, which is where public '
              'speaking begins.',
        ),
        PpConsult(
          title: 'The school readiness masterclass',
          whoFor: 'For a parent choosing a preschool this year, or preparing a '
              'child who has never been away from home. Covers what to look '
              'for, the six months before, and the first fortnight.',
          surfaceId: 'pp_courses',
          role: 'school_readiness',
        ),
        PpLink(
          'Bags, boxes, bottles and shoes',
          surfaceId: 'pp_recos',
          blurb: 'Only the few things that really matter, and what makes one '
              'lunch box easier for a four-year-old to open than another.',
        ),
      ],
    ),
  ],
);
