// =============================================================================
//  Communication & articulation — the activity set: two bands filled, one owed
// -----------------------------------------------------------------------------
//  Scaffolded to `ParentVeda_Communication_structure.pdf` ("a full set per
//  band, not a token few … each built on one real skill, tagged, ending on
//  an honest 'what you just practised' line") and FILLED, verbatim, from
//  the task PDFs in `tasks/communication/` on 2026-09-15:
//
//    Task 7 of 36  ·  6 to 8   ·  Say it out loud          ·  twelve, filled
//    Task 8 of 36  ·  8 to 11  ·  Tell it and explain it   ·  twelve, filled
//    (none yet)    ·  11 to 14 ·  Say what you think       ·  twelve slots
//
//  ⚠️ THE COPY IS THE TASK PDFS', WORD FOR WORD. Kid voice, Hinglish-friendly
//  ("nani's", "gully cricket", "jalebis"), mother tongue first: every line
//  is language-neutral and the right-word activities say so. Edit the PDF,
//  not this file.
//
//  ⚠️ WHAT THIS DOOR IS NOT, in the tasks' own words: "It is NOT about the
//  nerve to speak, volume, or facing an audience, that is the Confidence
//  door … Listening is HALF of this door." Two of the six skills receive.
//
//  ⚠️ `offersRecording` IS THE TASKS' FIELD. "The optional 'save your story'
//  step; true for Tell Me What Happened, Once Upon a Time" (6 to 8) and
//  "Retell the Movie, Make It Exciting" (8 to 11). Four activities in
//  twenty-four. The row shows only on those, only on a door that keeps her
//  voice, and only once a parent has turned recording on — off by default,
//  on this phone only, never analysed, graded or transcribed.
//
//  Ids are the scaffold's — `cm_68_01` … `cm_1114_12`, two per skill in
//  the door's skill order — so nothing on the rail moved when the copy
//  landed.
// =============================================================================

import '../../screens/skilling/sk_content.dart';

/// The brief's six real skills, with its own line for each.
const List<SkSkillPurpose> kSkCommunicationSkills = [
  SkSkillPurpose(
    id: 'clarity',
    label: 'Clarity',
    kidLine: 'Saying a thing so the other person gets it the first time, '
        'without having to guess.',
  ),
  SkSkillPurpose(
    id: 'listening',
    label: 'Listening',
    kidLine: 'Actually taking in what someone said, and being able to say '
        'it back in your own words.',
  ),
  SkSkillPurpose(
    id: 'describing',
    label: 'Describing',
    kidLine: 'Making someone picture a thing in their head using only your '
        'words.',
  ),
  SkSkillPurpose(
    id: 'storytelling',
    label: 'Storytelling',
    kidLine: 'Putting what happened in an order that makes sense: a start, '
        'a middle, an end.',
  ),
  SkSkillPurpose(
    id: 'right_word',
    label: 'The right word',
    kidLine: 'Finding the word that fits, instead of "that thing" and '
        'pointing.',
  ),
  SkSkillPurpose(
    id: 'putting_your_point',
    label: 'Putting your point',
    kidLine: 'Saying what you think and the reason for it, so it holds up.',
  ),
];

// =============================================================================
//  Task 7 of 36 — Say it out loud, 6 to 8
// =============================================================================

const List<SkActivity> _sayItOutLoud = [
  SkActivity(
    id: 'cm_68_01',
    band: '6-8',
    skillPurpose: 'clarity',
    title: 'Say It So I Get It',
    oneLine: 'Explain something so the other person really understands it.',
    materials: 'Nothing.',
    steps: [
      'Pick something to explain: how to play your favourite game, or how '
          'to make a jam sandwich.',
      'Explain it to someone. Watch their face. Did they get it?',
      'If they look confused, that is your clue. Say that part again, '
          'clearer.',
      'When they say "ah, got it!", you did it. That is being clear.',
    ],
    theThinking: 'Clarity is measured on the listener\'s face, not your own. '
        'Teaching a child to notice whether she was understood, and to say '
        'it clearer when she was not, is the whole heart of communication '
        '(and different from Confidence, which is the nerve to speak at '
        'all).',
    whatYouPractised: 'You explained something so someone really got it. '
        'Making yourself understood is what communication is all about.',
  ),
  SkActivity(
    id: 'cm_68_02',
    band: '6-8',
    skillPurpose: 'clarity',
    title: 'One Clear Message',
    oneLine: 'Say your one thing clearly, not in a muddle.',
    materials: 'Nothing.',
    steps: [
      'Sometimes what we want comes out jumbled: "um the thing, you know, '
          'can I, the... water".',
      'Stop. What is the ONE thing you want to say?',
      'Say it in one clear sentence: "Can I have some water, please?"',
      'Clear and simple beats long and muddled, every time.',
    ],
    theThinking: 'A young child often buries the message in filler. '
        'Practising boiling a jumbled thought down to one clear sentence is '
        'a real clarity skill that serves her for life.',
    whatYouPractised: 'You took a muddle and made it one clear sentence. '
        'Clear and simple is a real skill.',
  ),
  SkActivity(
    id: 'cm_68_03',
    band: '6-8',
    skillPurpose: 'listening',
    title: 'Say It Back',
    oneLine: 'Really listen, then say it back to check you got it right.',
    materials: 'Nothing.',
    steps: [
      'Someone tells you something (a plan, an instruction, a bit of news).',
      'Listen properly, all of it.',
      'Say it back in your own words: "So we are going to nani\'s at 5?"',
      'If you got it right, great. If not, they can fix it. That is smart '
          'listening.',
    ],
    theThinking: 'Communication is two-way, and listening is half of it. '
        'Repeating back to check (active listening) is a concrete, teachable '
        'skill most adults never learned, and it catches misunderstandings '
        'before they cause trouble.',
    whatYouPractised: 'You listened and checked you got it right. Listening '
        'well is half of good communication.',
  ),
  SkActivity(
    id: 'cm_68_04',
    band: '6-8',
    skillPurpose: 'listening',
    title: 'Listen All the Way',
    oneLine: 'Hear the whole thing before you jump in.',
    materials: 'Nothing.',
    steps: [
      'When someone is talking to you, notice the urge to jump in before '
          'they finish.',
      'Do not. Let them say the whole thing first.',
      'Wait for a little gap, THEN say your bit.',
      'You listened all the way. People love being heard fully.',
    ],
    theThinking: 'Interrupting is the most common listening failure at every '
        'age. Practising hearing someone out fully, resisting the jump-in, '
        'is a gift to every conversation the child will ever have.',
    whatYouPractised: 'You let someone finish before you spoke. Hearing '
        'people all the way is real listening.',
  ),
  SkActivity(
    id: 'cm_68_05',
    band: '6-8',
    skillPurpose: 'describing',
    title: 'Describe It, I\'ll Guess',
    oneLine: 'Describe something without naming it, and let someone guess.',
    materials: 'Anything in the room.',
    steps: [
      'Pick an object, secretly. Do not say what it is.',
      'Describe it: what it looks like, what it is for, what it feels like.',
      'Can the other person guess it from your words?',
      'If not, add a better clue. Good describing paints a picture.',
    ],
    theThinking: 'Describing precisely (enough detail, the right details) so '
        'someone else can picture the thing is a core meaning skill. The '
        'guessing game gives instant feedback on whether the description '
        'worked.',
    whatYouPractised: 'You described something so well someone could guess '
        'it. Painting a picture with words is real describing.',
  ),
  SkActivity(
    id: 'cm_68_06',
    band: '6-8',
    skillPurpose: 'describing',
    title: 'Draw What I Say',
    oneLine: 'Describe a picture so someone can draw it without seeing it.',
    materials: 'Paper and something to draw with, or a finger in the air.',
    steps: [
      'Think of a simple picture in your head (a house with a tree and a '
          'sun).',
      'Describe it, bit by bit, so the other person can draw it: "A square '
          'house in the middle, a round sun in the top corner..."',
      'They draw only what you say. No peeking at your head!',
      'Compare. How close did your words get them?',
    ],
    theThinking: 'This sharpens describing into precise, ordered detail: the '
        'listener can only draw what the words say. It is a delightful, '
        'self-correcting lesson in how much clear description matters.',
    whatYouPractised: 'You described a picture clearly enough for someone to '
        'draw it. That is powerful describing.',
  ),
  SkActivity(
    id: 'cm_68_07',
    band: '6-8',
    skillPurpose: 'storytelling',
    title: 'Tell Me What Happened',
    oneLine: 'Tell about something that happened, in an order that makes '
        'sense.',
    materials: 'Nothing.',
    offersRecording: true,
    steps: [
      'Pick something that happened: your day, a trip, a funny moment.',
      'Tell it so the listener can follow: what happened first, then next, '
          'then the end.',
      'Not too many "and then... and then...". Just the good bits, in '
          'order.',
      'Did they enjoy it? Telling what happened is real storytelling.',
    ],
    theThinking: 'Retelling a real event so a listener can follow, beginning '
        'to end, without losing them, is the everyday form of storytelling. '
        '(Retelling from life sits here; reading a book sits in the Reading '
        'door.)',
    whatYouPractised: 'You told what happened so someone could follow it. '
        'Telling a clear story is a real skill.',
  ),
  SkActivity(
    id: 'cm_68_08',
    band: '6-8',
    skillPurpose: 'storytelling',
    title: 'Once Upon a Time',
    oneLine: 'Make up a tiny story with a beginning, middle and end.',
    materials: 'Nothing.',
    offersRecording: true,
    steps: [
      'Start with a character and a problem: "A puppy lost his bone."',
      'Beginning: what is happening. Middle: the puppy looks everywhere. '
          'End: he finds it, or something better!',
      'Tell your whole story out loud.',
      'Every story needs a start, a middle and an end. You gave yours all '
          'three.',
    ],
    theThinking: 'Making up a story with a shape (beginning, middle, end) '
        'builds narrative sense, imagination, and the idea that a story goes '
        'somewhere. It is pure craft, and pure fun.',
    whatYouPractised: 'You made up a whole story with a beginning, middle '
        'and end. That is real storytelling.',
  ),
  SkActivity(
    id: 'cm_68_09',
    band: '6-8',
    skillPurpose: 'right_word',
    title: 'The Better Word',
    oneLine: 'Swap a boring word for one that fits just right.',
    materials: 'Nothing.',
    steps: [
      'Notice the tired words we use a lot: nice, good, thing, big.',
      'Take one: "The food was nice." Now find a word that fits better. '
          'Crunchy? Spicy? Warm?',
      'Say it again with the better word. Feel the difference?',
      'The right word makes people SEE what you mean.',
    ],
    theThinking: 'Reaching past "nice" and "good" for the word that actually '
        'fits is how meaning gets sharp. This is vocabulary as a tool, not a '
        'test, and it works in any language.',
    whatYouPractised: 'You found a word that fit just right. The right word '
        'makes your meaning come alive.',
  ),
  SkActivity(
    id: 'cm_68_10',
    band: '6-8',
    skillPurpose: 'right_word',
    title: 'What\'s the Word?',
    oneLine: 'Forgot a word? Describe your way to it.',
    materials: 'Nothing.',
    steps: [
      'Sometimes you cannot remember a word. That is okay, everyone forgets '
          'words.',
      'Instead of stopping, describe it: "the round flat thing you cut '
          'vegetables on..."',
      'Keep going till you, or the listener, find it: "a chopping board!"',
      'The word can be in any language you know. Getting your meaning '
          'across is the win.',
    ],
    theThinking: 'Not being stuck when a word will not come (describing '
        'around it) is a real, confidence-preserving communication skill. '
        'Crucially it honours mother tongue: the word can be in any '
        'language, because meaning matters more than which language it '
        'lands in.',
    whatYouPractised: 'You found your way to the word by describing it. '
        'Never being stuck for words is a great skill.',
  ),
  SkActivity(
    id: 'cm_68_11',
    band: '6-8',
    skillPurpose: 'putting_your_point',
    title: 'Say What You Want and Why',
    oneLine: 'Say what you want, and give a reason, so your point lands.',
    materials: 'Nothing.',
    steps: [
      'When you want something, do not just hint or sulk. Say it.',
      'Add a reason: "Can we go to the park? Because I finished my '
          'homework."',
      'A want plus a reason is much easier for someone to say yes to.',
      'You made your point clearly, with a because. That is how points '
          'land.',
    ],
    theThinking: 'Getting your point across (a clear want plus a reason) is '
        'different from the nerve to ask (that is Confidence). Here the '
        'skill is making the point land, and a "because" is the simplest '
        'way to do it. It is the gentle seed of good reasoning too, without '
        'being an argument.',
    whatYouPractised: 'You said what you wanted and gave a reason. A point '
        'with a because is a strong point.',
  ),
  SkActivity(
    id: 'cm_68_12',
    band: '6-8',
    skillPurpose: 'putting_your_point',
    title: 'I Heard You, and...',
    oneLine: 'Show you heard the other person, then add your point.',
    materials: 'Nothing.',
    steps: [
      'When you disagree (you want the ball, so does your friend), do not '
          'just push your side.',
      'First, show you heard them: "I know you want the ball too."',
      'Then add yours: "...and I would like a turn. Let us take turns?"',
      'Making your point while hearing theirs is the best kind of talking.',
    ],
    theThinking: 'The two-way craft: making your point while showing you '
        'heard the other person. Even a simple version at this age plants '
        'the seed of fair, non-steamrolling communication, which is where '
        'real disagreement skills grow from later.',
    whatYouPractised: 'You made your point AND showed you heard the other '
        'person. That is the best kind of communication.',
  ),
];

// =============================================================================
//  Task 8 of 36 — Tell it and explain it, 8 to 11
// =============================================================================

const List<SkActivity> _tellAndExplain = [
  SkActivity(
    id: 'cm_811_01',
    band: '8-11',
    skillPurpose: 'clarity',
    title: 'Explain How It Works',
    oneLine: 'Explain how something works so someone really gets it.',
    materials: 'Nothing.',
    steps: [
      'Pick something you understand: how to play gully cricket, how a fan '
          'works, a game\'s rules.',
      'Explain it in order: what it is, then how it works, step by step.',
      'Watch your listener. Confused face? Go back and make that part '
          'clearer.',
      'When they can explain it back, you nailed it.',
    ],
    theThinking: 'Explaining a whole process clearly, in order, so a listener '
        'can follow, is the heart of this band. Watching for the confused '
        'face and adjusting is the real skill, and it is very different from '
        'just having the courage to speak.',
    whatYouPractised: 'You explained how something works so someone got it. '
        'Clear explaining is a powerful skill.',
  ),
  SkActivity(
    id: 'cm_811_02',
    band: '8-11',
    skillPurpose: 'clarity',
    title: 'Explain It Simpler',
    oneLine: 'Explain something to someone younger, in a way THEY '
        'understand.',
    materials: 'Nothing. A younger child helps, or imagine one.',
    steps: [
      'Pick something you know and explain it to a younger kid.',
      'Use smaller words and simpler ideas. What would a 5-year-old get?',
      'Check: did they understand? If not, make it even simpler.',
      'Explaining so a younger person gets it is a real skill grown-ups '
          'struggle with.',
    ],
    theThinking: 'Matching your explanation to your listener (audience '
        'awareness) is an advanced clarity move. A child who can explain '
        'something to someone younger truly understands it herself, and is '
        'learning that clarity means meeting the listener where they are.',
    whatYouPractised: 'You explained something so a younger person '
        'understood. Matching your words to your listener is a real skill.',
  ),
  SkActivity(
    id: 'cm_811_03',
    band: '8-11',
    skillPurpose: 'listening',
    title: 'Ask a Good Question',
    oneLine: 'Listen, then ask a question that shows you were really '
        'listening.',
    materials: 'Nothing.',
    steps: [
      'Someone tells you about something (their day, a trip, a game).',
      'Listen properly, all of it.',
      'Ask a question that goes deeper: "You went to the fort? What was the '
          'best part?"',
      'A good question shows you listened, and keeps the talk going.',
    ],
    theThinking: 'A follow-up question is proof of listening, and it deepens '
        'a conversation. Teaching a child to listen for the interesting '
        'thread and ask about it is active, generous listening, the kind '
        'people love to be on the receiving end of.',
    whatYouPractised: 'You listened and asked a great question. A good '
        'follow-up question is real listening.',
  ),
  SkActivity(
    id: 'cm_811_04',
    band: '8-11',
    skillPurpose: 'listening',
    title: 'Really Hear the Other Side',
    oneLine: 'In a disagreement, listen to WHY they think that, before you '
        'argue back.',
    materials: 'Nothing.',
    steps: [
      'When someone disagrees with you, hold your reply for a moment.',
      'Listen to their REASON, not just their answer. Why do they think '
          'that?',
      'Say it back: "So you think we should do X because Y?"',
      'Now you actually understand them. That is the best way to talk '
          'things out.',
    ],
    theThinking: 'Listening to understand the other side\'s reasoning, not '
        'just waiting to counter it, is a rare and powerful skill. Repeating '
        'their reason back proves you got it and lowers the heat in any '
        'disagreement. (The reasoning itself lives in the Thinking door; '
        'here it is the listening craft.)',
    whatYouPractised: 'You really heard the other side\'s reason, not just '
        'their answer. That is deep listening.',
  ),
  SkActivity(
    id: 'cm_811_05',
    band: '8-11',
    skillPurpose: 'describing',
    title: 'Give Directions',
    oneLine: 'Tell someone how to get somewhere, clearly enough to follow.',
    materials: 'Nothing.',
    steps: [
      'Pick a route you know: your house to the shop, or around your '
          'school.',
      'Describe it step by step, with landmarks: "Go straight, turn left at '
          'the temple, past the chai stall..."',
      'Could someone follow it without a map?',
      'Clear directions are describing with a job to do.',
    ],
    theThinking: 'Giving directions is describing at its most practical: '
        'ordered steps and clear landmarks so someone can actually follow. '
        'It sharpens the child\'s sense of what detail the listener needs, '
        'and what they do not.',
    whatYouPractised: 'You gave directions clear enough to follow. That is '
        'describing that gets someone somewhere.',
  ),
  SkActivity(
    id: 'cm_811_06',
    band: '8-11',
    skillPurpose: 'describing',
    title: 'Describe So They Feel It',
    oneLine: 'Describe a place or a moment so the listener can almost feel '
        'it.',
    materials: 'Nothing.',
    steps: [
      'Pick something with lots to it: a festival, a favourite meal, the '
          'first rain.',
      'Describe it with your senses: what you saw, heard, smelled, tasted, '
          'felt.',
      'Not just "it was nice", make them SEE it: "the jalebis were hot and '
          'sticky and sweet..."',
      'Good describing puts the listener right there with you.',
    ],
    theThinking: 'The step up from naming features to painting an '
        'experience: using sensory detail so the listener feels it. This is '
        'where describing becomes vivid and memorable, a craft that serves '
        'writing and speaking both.',
    whatYouPractised: 'You described something so well the listener could '
        'almost feel it. Painting a moment with words is real craft.',
  ),
  SkActivity(
    id: 'cm_811_07',
    band: '8-11',
    skillPurpose: 'storytelling',
    title: 'Retell the Movie',
    oneLine: 'Retell a film or book you loved so someone else wants to see '
        'it.',
    materials: 'Nothing.',
    offersRecording: true,
    steps: [
      'Pick a film, show, or book you loved.',
      'Retell it: the setup, the exciting bits, but do NOT spoil the '
          'ending.',
      'Keep the good parts, skip the slow parts.',
      'Did you make them want to watch it? That is a great retell.',
    ],
    theThinking: 'Retelling with a goal (hooking someone) teaches '
        'summarising, choosing what to keep, pacing, and holding back the '
        'spoiler. It is storytelling with judgement about what the listener '
        'needs. (Retelling here; reading a book sits in the Reading door.)',
    whatYouPractised: 'You retold a story so well someone wanted to see it. '
        'Hooking a listener is real storytelling.',
  ),
  SkActivity(
    id: 'cm_811_08',
    band: '8-11',
    skillPurpose: 'storytelling',
    title: 'Make It Exciting',
    oneLine: 'Tell a story with the exciting bits stretched out, so it grips '
        'them.',
    materials: 'Nothing.',
    offersRecording: true,
    steps: [
      'Take a story (real or made up) and find the most exciting moment.',
      'Slow down there. Stretch it out. "...and then, guess what '
          'happened?"',
      'Skip past the boring bits quickly.',
      'Pace and a little suspense turn a plain story into a gripping one.',
    ],
    theThinking: 'The step up from beginning-middle-end to making it land: '
        'pace, suspense, and a hook. Learning to stretch the exciting parts '
        'and skip the dull ones is what separates a story that grips from '
        'one that drags.',
    whatYouPractised: 'You used pace and suspense to grip your listener. '
        'Making a story exciting is real storytelling craft.',
  ),
  SkActivity(
    id: 'cm_811_09',
    band: '8-11',
    skillPurpose: 'right_word',
    title: 'Shades of a Word',
    oneLine: 'Find the exact word, not just the nearest one.',
    materials: 'Nothing.',
    steps: [
      'Take a plain word like "happy". There are shades: glad, thrilled, '
          'cheerful, content.',
      'Which shade fits what you really mean? Thrilled is bigger than '
          'glad.',
      'Try "sad" too: upset, gloomy, disappointed. They are not the same.',
      'The exact shade says exactly what you mean.',
    ],
    theThinking: 'Precision between near-words (glad vs thrilled) is how '
        'meaning gets exact, and it builds a real, in-use vocabulary. '
        '(Feeling-words touch the Feelings door, but here the focus is word '
        'choice, not emotional processing, keep it on the words.)',
    whatYouPractised: 'You found the exact shade of a word, not just the '
        'nearest one. That is precise, powerful word choice.',
  ),
  SkActivity(
    id: 'cm_811_10',
    band: '8-11',
    skillPurpose: 'right_word',
    title: 'Say It Two Ways',
    oneLine: 'Say the same thing to a friend, and to a teacher. Notice the '
        'difference.',
    materials: 'Nothing.',
    steps: [
      'Take something to say, like "that was really good".',
      'Say it the way you would to a FRIEND. Casual, your own words.',
      'Now say it the way you would to a TEACHER or elder. A bit more '
          'careful.',
      'Same meaning, different words for different people. That is a smart '
          'skill.',
    ],
    theThinking: 'Choosing your words for who you are talking to (register) '
        'is a genuinely useful communication skill. It is not about '
        '"proper" versus "wrong", it is about fitting the moment, and it '
        'works in every language, not just English.',
    whatYouPractised: 'You said the same thing two ways for two people. '
        'Fitting your words to who is listening is a real skill.',
  ),
  SkActivity(
    id: 'cm_811_11',
    band: '8-11',
    skillPurpose: 'putting_your_point',
    title: 'Give Two Reasons',
    oneLine: 'Make your point stronger with two reasons, not one.',
    materials: 'Nothing.',
    steps: [
      'Take something you want to argue for: "We should get a plant."',
      'Give one reason: "It makes the room nicer."',
      'Add a second: "And I will take care of it myself."',
      'Two reasons make a point much harder to say no to.',
    ],
    theThinking: 'Building a fuller case (two reasons instead of one) makes '
        'a point land better. This is the craft of getting your point across '
        'clearly, not formal argument (that is the Thinking door). It is '
        'about being clear and convincing, not about winning.',
    whatYouPractised: 'You backed your point with two reasons. A point with '
        'reasons behind it is a strong point.',
  ),
  SkActivity(
    id: 'cm_811_12',
    band: '8-11',
    skillPurpose: 'putting_your_point',
    title: 'Disagree Nicely',
    oneLine: 'Say you see it differently, without it turning into a fight.',
    materials: 'Nothing.',
    steps: [
      'When you disagree, you do not have to argue or go quiet. There is a '
          'third way.',
      'Say it kindly: "I see it differently, and here is why..."',
      'Give your reason calmly. No "you\'re wrong", just your view.',
      'Disagreeing without a fight is one of the best skills there is.',
    ],
    theThinking: 'Voicing a different view kindly, with a reason, and without '
        'attacking the person, is the craft of respectful disagreement. It '
        'differs from just acknowledging the other side; here she puts her '
        'own view forward, warmly. (The reasoning belongs to the Thinking '
        'door; keep this on the how-to-say-it, and consistent with '
        '"question ideas, not people".)',
    whatYouPractised: 'You disagreed without a fight, kindly and with a '
        'reason. That is a rare, grown-up skill.',
  ),
];

// =============================================================================
//  Say what you think, 11 to 14 — twelve slots, no task PDF yet
// =============================================================================

const List<String> _skillOrder = [
  'clarity', 'clarity',
  'listening', 'listening',
  'describing', 'describing',
  'storytelling', 'storytelling',
  'right_word', 'right_word',
  'putting_your_point', 'putting_your_point',
];

final List<SkActivity> _sayWhatYouThink = [
  for (final (i, skill) in _skillOrder.indexed)
    SkActivity(
      id: 'cm_1114_${(i + 1).toString().padLeft(2, '0')}',
      band: '11-14',
      skillPurpose: skill,
      title: 'Activity ${i + 1}',
      comingSoon: true,
    ),
];

final List<SkActivity> kSkCommunicationActivities = [
  ..._sayItOutLoud,
  ..._tellAndExplain,
  ..._sayWhatYouThink,
];
