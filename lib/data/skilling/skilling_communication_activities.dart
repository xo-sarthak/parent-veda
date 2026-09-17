// =============================================================================
//  Communication & articulation — the activity set, all three bands filled
// -----------------------------------------------------------------------------
//  Scaffolded to `ParentVeda_Communication_structure.pdf` ("a full set per
//  band, not a token few … each built on one real skill, tagged, ending on
//  an honest 'what you just practised' line") and FILLED, verbatim, from
//  the task PDFs in `tasks/communication/` on 2026-09-15:
//
//    Task 7 of 36  ·  6 to 8   ·  Say it out loud          ·  twelve, filled
//    Task 8 of 36  ·  8 to 11  ·  Tell it and explain it   ·  twelve, filled
//    Task 9 of 36  ·  11 to 14 ·  Say what you think       ·  twelve, filled
//                     (written by Claude Code on 2026-09-17 at the user's
//                     instruction, not by the task author; sits with the
//                     other task PDFs, `.md` beside `.pdf`)
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
//  step; true for Tell Me What Happened, Once Upon a Time" (6 to 8),
//  "Retell the Movie, Make It Exciting" (8 to 11) and "Tell It So It Lands,
//  Short Version, Long Version" (11 to 14). Six activities in thirty-six,
//  the two storytelling ones per band. The row shows only on those, only
//  on a door that keeps her voice, and only once a parent has turned
//  recording on — off by default, on this phone only, never analysed,
//  graded or transcribed.
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
//  Task 9 of 36 — Say what you think, 11 to 14
// -----------------------------------------------------------------------------
//  ⚠️ THIS TASK WAS WRITTEN BY CLAUDE CODE, NOT THE TASK AUTHOR. The user
//  asked for it on 2026-09-17 ("write 11-14 tasks then"). It sits with the
//  other task PDFs — `tasks/communication/ParentVeda Communication 11-14
//  activities prompt.pdf`, the editable `.md` beside it — in their
//  shape and under their rules, and the copy below is generated from the
//  `.md` verbatim. Edit the document, regenerate; never this.
// =============================================================================

const List<SkActivity> _sayWhatYouThink = [
  SkActivity(
    id: 'cm_1114_01',
    band: '11-14',
    skillPurpose: 'clarity',
    title: 'Explain the Hard Thing',
    oneLine: 'Take something genuinely complicated and explain it to someone '
        'who does not know it.',
    materials: 'Nothing. One person who does not already know the thing.',
    steps: [
      'Pick something you actually understand that is not simple: how a UPI '
          'payment goes through, the offside rule, why the sky is blue, a '
          'chapter from school.',
      'Start with the one-line version. If they only hear one sentence, what '
          'must it be?',
      'Add detail only when they ask, or when their face says "wait, what?"',
      'Ask them to tell it back to you. Where they wobble is where your '
          'explanation needs work, not where they were slow.',
    ],
    theThinking: 'The step up from "explain how it works": a complex thing, to '
        'a listener who starts from zero, led by the one-line version and then '
        'only the detail that is needed. The habit of blaming the explanation '
        'and not the listener is the whole skill.',
    whatYouPractised: 'You explained something hard to someone who did not '
        'know it, and fixed the parts that did not land. Clarity on a hard '
        'thing is a real skill.',
  ),
  SkActivity(
    id: 'cm_1114_02',
    band: '11-14',
    skillPurpose: 'clarity',
    title: 'Say It Once for the Group',
    oneLine: 'Give a group one instruction so clear that nobody has to ask '
        '"matlab?"',
    materials: 'Nothing. A group: a project team, cousins, the family before '
        'an outing.',
    steps: [
      'When you need a group to do something (meet at the gate at four, bring '
          'one thing each, split the work), plan the message before you say '
          'it.',
      'Say it in order: what, who, when, where. One time, at a normal pace.',
      'Watch. Did anyone ask "wait, which gate?" That is a missing piece, not '
          'a slow listener.',
      'Next time, put that piece in from the start. A group that does not need '
          'to ask has been told clearly.',
    ],
    theThinking: 'Clarity to a group is harder than clarity to one person, '
        'because there is no single face to read and no second try. Planning '
        'the message and listening for the questions that come back, then '
        'closing those gaps, is how clear people get clear.',
    whatYouPractised: 'You told a group something once, clearly, and noticed '
        'what they still had to ask. Saying it right the first time is a real '
        'skill.',
  ),
  SkActivity(
    id: 'cm_1114_03',
    band: '11-14',
    skillPurpose: 'listening',
    title: 'Listen Past the First Answer',
    oneLine: 'Ask a grandparent or elder about their life, and keep going past '
        'the first answer.',
    materials: 'Nothing. Someone older, with a little time.',
    steps: [
      'Ask something real: "What was school like for you?" "How did you and '
          'dadaji meet?" "What was the first job you did?"',
      'Listen to the whole answer. Do not plan your next question while they '
          'are talking.',
      'Ask a follow-up that comes FROM what they just said: "You walked how '
          'far? What happened when it rained?"',
      'Then one more. The real story is usually under the third question, not '
          'the first.',
    ],
    theThinking: 'Listening at this age grows from asking a good question to '
        'sustaining attention: following up on what was actually said, three '
        'questions deep. An elder\'s story is the kindest place to practise '
        'it, and the child usually comes away with something she did not know '
        'about her own family.',
    whatYouPractised: 'You listened past the first answer and found the real '
        'story underneath. Following what someone actually said is deep '
        'listening.',
  ),
  SkActivity(
    id: 'cm_1114_04',
    band: '11-14',
    skillPurpose: 'listening',
    title: 'Say It Back Before You Answer',
    oneLine: 'In a real disagreement, say their side back until they say "yes, '
        'that is it", and only then reply.',
    materials: 'Nothing. A real disagreement, with a sibling, a friend, a '
        'parent.',
    steps: [
      'Next time you disagree with someone, hold your reply.',
      'Say their view back in your own words, fairly, not as a joke: "So you '
          'think I should not go because it ends late and you would be '
          'worried?"',
      'Wait for "yes, that is it." If they say "no, not quite", listen again '
          'and try again.',
      'Only now give your side. You will notice it is a different '
          'conversation.',
    ],
    theThinking: 'The step up from "really hear the other side": the child '
        'does not move on until the other person confirms she has understood '
        'them. This is the single most useful listening habit there is, and '
        'almost no adult does it. The point is understanding, not agreeing; '
        'she can still disagree, and the disagreement will be cleaner.',
    whatYouPractised: 'You said someone\'s side back until they agreed you had '
        'it, before you answered. Understanding first is the hardest, best '
        'listening.',
  ),
  SkActivity(
    id: 'cm_1114_05',
    band: '11-14',
    skillPurpose: 'describing',
    title: 'Describe It So They Could Draw It',
    oneLine: 'Describe something the listener cannot see, well enough that '
        'they could draw it.',
    materials: 'Nothing. A picture on a phone, or a view from a window, and '
        'one person who cannot see it. Paper if they want to draw.',
    steps: [
      'Pick a photo, a poster, or the view from your window. Your listener '
          'faces the other way, or is on a call.',
      'Describe it in an order: the big shape first, then left to right, then '
          'the details. Sizes, colours, what is next to what.',
      'Let them draw it, or say back what they see in their head.',
      'Compare. What did you leave out? What did you say that did not help? '
          'That gap is the whole lesson.',
    ],
    theThinking: 'Describing with a hard test: could someone rebuild the '
        'picture from your words alone? The step up from giving directions is '
        'that there is no landmark to lean on, only order and precision. The '
        'comparison at the end teaches more than any amount of "describe it '
        'nicely".',
    whatYouPractised: 'You described something so someone could almost draw '
        'it, and saw exactly what your words missed. Precise describing is a '
        'real skill.',
  ),
  SkActivity(
    id: 'cm_1114_06',
    band: '11-14',
    skillPurpose: 'describing',
    title: 'Say What Happened, Exactly',
    oneLine: 'Describe something that happened, in order, only what you saw, '
        'not what you guessed.',
    materials: 'Nothing. Something that actually happened: at school, in the '
        'colony, at home.',
    steps: [
      'Pick a real event with more than one person in it: a fight in the '
          'corridor, a broken thing, a mix-up over whose turn it was.',
      'Tell it in order, from the start. First this, then this.',
      'Keep to what you actually saw and heard. "He looked angry" is a guess. '
          '"He shouted and left" is what happened.',
      'If you did not see a part, say so: "I do not know what happened before '
          'I came in." That line makes you the person people trust to tell it.',
    ],
    theThinking: 'Describing with a job to do, fairly: separating what was '
        'observed from what was assumed, and saying plainly what she does not '
        'know. It is the description a teacher or a parent actually needs, and '
        'it is a skill many adults never build. Keep it on the telling, not on '
        'who was right.',
    whatYouPractised: 'You told what happened in order, with only what you '
        'saw, and said what you did not know. Fair, exact describing is a real '
        'skill.',
  ),
  SkActivity(
    id: 'cm_1114_07',
    band: '11-14',
    skillPurpose: 'storytelling',
    title: 'Tell It So It Lands',
    oneLine: 'Tell a true story from your life so it lands: a hook, the '
        'middle, and a last line.',
    materials: 'Nothing. Something that happened to you and a few people to '
        'tell it to, at dinner or on a call.',
    offersRecording: true,
    steps: [
      'Pick something that happened to you this week or this year. Funny, '
          'strange, small is fine.',
      'Start with a line that makes them want the rest: "So the bus did not '
          'come."',
      'Tell the middle in order, only the parts that matter to the story.',
      'End on a line, not a fade. "And that is why I am never trusting that '
          'timetable again." Then stop.',
    ],
    theThinking: 'Retelling a film becomes telling her own story with a shape: '
        'an opening that pulls, a middle that keeps only what matters, and an '
        'ending line she chooses instead of trailing off. The story that lands '
        'at dinner is the one she will tell for years, and this is where it '
        'gets its shape.',
    whatYouPractised: 'You told a true story with a hook, a middle and a last '
        'line, and it landed. Telling your own story well is real '
        'storytelling.',
  ),
  SkActivity(
    id: 'cm_1114_08',
    band: '11-14',
    skillPurpose: 'storytelling',
    title: 'Short Version, Long Version',
    oneLine: 'Tell the same story in two lines, then in full. Know what you '
        'cut and why.',
    materials: 'Nothing. A story you have already told, and someone to tell it '
        'to twice.',
    offersRecording: true,
    steps: [
      'Take a story you know well: something from a trip, a match, a school '
          'day.',
      'Tell the two-line version, the one for a corridor or a lift: what '
          'happened, and why it mattered.',
      'Now tell the full version, the one for dinner, with the details that '
          'make it good.',
      'Notice what you cut for the short one. That is you deciding what the '
          'story is really about.',
    ],
    theThinking: '"Make it exciting" becomes control over length: the same '
        'story at two sizes, on purpose, for two situations. Knowing what to '
        'cut is the mark of someone who understands her own story, and it is '
        'the same skill she will use for a summary, an answer in class, a '
        'message.',
    whatYouPractised: 'You told one story short and then in full, and knew '
        'what you cut. Fitting a story to the moment is real storytelling.',
  ),
  SkActivity(
    id: 'cm_1114_09',
    band: '11-14',
    skillPurpose: 'right_word',
    title: 'Drop the Fillers',
    oneLine: 'Say a thing without "like", "basically", "matlab", "you know", '
        'and hear what is left.',
    materials: 'Nothing. A friend or a sibling to catch you.',
    steps: [
      'Explain something for a minute or two while a friend counts your '
          'fillers: like, basically, matlab, you know, actually, umm.',
      'Say the same thing again. Every time a filler comes, pause instead. A '
          'pause is allowed.',
      'Notice: the pause is usually where you did not yet have the word. Find '
          'the word.',
      'Fillers live in every language. You do not have to lose them all, just '
          'know when you are leaning on them.',
    ],
    theThinking: 'The right word at this age often means noticing the '
        'non-words that stand in for it. A filler is a placeholder for a word '
        'she has not found yet; swapping it for a pause, and then for the '
        'word, is precision she can hear immediately. A friend counting is '
        'play, not a score, and nothing is written down.',
    whatYouPractised: 'You said a thing without leaning on fillers, and found '
        'the words that were hiding behind them. Choosing the word over the '
        'filler is a real skill.',
  ),
  SkActivity(
    id: 'cm_1114_10',
    band: '11-14',
    skillPurpose: 'right_word',
    title: 'Write It to a Teacher',
    oneLine: 'Write a short message to a teacher or coach that is clear, '
        'polite, and easy to say yes to.',
    materials: 'Nothing, or a phone with a grown-up\'s okay. Any language the '
        'teacher reads.',
    steps: [
      'Pick a real ask: a doubt about homework, a day off from practice, an '
          'extension, a form you need signed.',
      'Shape it: a greeting, the ask in one clear line, the reason in one '
          'line, a thank you. Four parts, that is all.',
      'Read it as the teacher. Is anything missing that they would have to '
          'ask? Is anything in it that sounds like a friend chat?',
      'Send it, or show it to a grown-up first. A clear, polite ask is one '
          'most people want to say yes to.',
    ],
    theThinking: 'Friend-versus-teacher becomes the real thing: a written '
        'request to an adult in charge, in the right register, with the ask '
        'and the reason visible in one read. Register lives in every language, '
        'and the four-part shape travels to every message she will ever need '
        'to write to someone in charge.',
    whatYouPractised: 'You wrote a clear, polite message to a teacher with the '
        'ask and the reason in it. Choosing the right words for the right '
        'person is a real skill.',
  ),
  SkActivity(
    id: 'cm_1114_11',
    band: '11-14',
    skillPurpose: 'putting_your_point',
    title: 'Point, Reason, Example',
    oneLine: 'Make your point in three moves: the point, the reason, one '
        'example.',
    materials: 'Nothing. A class discussion, a family decision, a debate with '
        'a friend.',
    steps: [
      'Take something you think: "We should keep the school library open at '
          'lunch."',
      'Say the point in one line. Then the reason: "because a lot of us have '
          'nowhere quiet to sit."',
      'Then one example that makes it real: "Last week four of us were doing '
          'homework on the stairs."',
      'Stop there. Point, reason, example. Three moves, and your point stands '
          'up on its own.',
    ],
    theThinking: 'Two reasons become a shape: point, reason, example. It is '
        'the craft of putting a view across so it can be followed and '
        'remembered, not the logic of whether the reason is a good one (that '
        'is the Thinking door). A child who has the shape can use it in class, '
        'at home, and in writing, without having to be the loudest.',
    whatYouPractised: 'You made a point with a reason and an example, in three '
        'clear moves. Putting your point so it stands up is a real skill.',
  ),
  SkActivity(
    id: 'cm_1114_12',
    band: '11-14',
    skillPurpose: 'putting_your_point',
    title: 'Hold a Real Back-and-Forth',
    oneLine: 'Have a proper exchange: say your view, hear theirs, answer what '
        'they actually said, and be able to change your mind out loud.',
    materials: 'Nothing. Someone who sees it differently, and a few minutes.',
    steps: [
      'Pick something you two see differently: which film, whether the rule is '
          'fair, what to do on Sunday.',
      'Say your view with a reason. Then listen to theirs, all of it.',
      'Answer what THEY said, not what you had ready. "You said it is unfair '
          'to the younger ones. I had not thought of that, but..."',
      'If they change your mind a little, say so out loud: "Okay, that shifts '
          'it for me." That is not losing. That is the whole point of talking.',
    ],
    theThinking: 'The band\'s capstone and the brief\'s own words, "holding a '
        'real back-and-forth": a view with a reason, listening in full, '
        'responding to what was actually said, and saying out loud when her '
        'mind has moved. Disagreeing nicely grows into a conversation that '
        'goes somewhere. Keep it on the craft of the exchange; the quality of '
        'the arguments is the Thinking door\'s.',
    whatYouPractised: 'You held a real back-and-forth: your view, their view, '
        'an answer to what they actually said, and an honest "that shifts it" '
        'when it did. That is communication at its best.',
  ),
];

/* kept for revert — the scaffold that held the twelve slots from 2026-09-15
   to 2026-09-17. The ids it minted are the ids above.
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
*/

final List<SkActivity> kSkCommunicationActivities = [
  ..._sayItOutLoud,
  ..._tellAndExplain,
  ..._sayWhatYouThink,
];
