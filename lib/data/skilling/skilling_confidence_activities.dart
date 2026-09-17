// =============================================================================
//  Confidence & public speaking — the activity set, all three bands filled
// -----------------------------------------------------------------------------
//  Scaffolded to `ParentVeda_Confidence_structure.pdf` ("Activity set × 3 —
//  Use your voice (6 to 8) · Stand up and say it (8 to 11) · Give a real
//  talk (11 to 14). The heart. A full practice set per band, each on one
//  real skill, tagged, honest end-line, no score. Recording a turn is
//  offered, never forced.") and FILLED, verbatim, from the task PDFs in
//  `tasks/confidence/` on 2026-09-17:
//
//    Task 4 of 36  ·  6 to 8   ·  Use your voice         ·  twelve, filled
//    Task 5 of 36  ·  8 to 11  ·  Stand up and say it    ·  twelve, filled
//    Task 6 of 36  ·  11 to 14 ·  Give a real talk       ·  twelve, filled
//
//  ⚠️ THE COPY IS THE TASK PDFS', WORD FOR WORD. Kid voice, Hinglish-friendly
//  ("kachcha papad, pakka papad", "dadaji"). Edit the PDF, not this file.
//
//  ⚠️ THE SIX ARE DELIVERY AND NERVE, NOT MEANING. The tasks: "Confidence
//  owns DELIVERY and NERVE: speaking up, being heard, facing a room,
//  steadying nerves, keeping going, being yourself. It is NOT about
//  meaning, clarity, or the right word, that is the Communication door."
//  And: "Nerves are the skill, not a bug to remove. The honest message
//  throughout: nervous-and-doing-it-anyway is what confidence actually is."
//  The quiet child is protected by name — The Puppet Speaks, Your Own Way,
//  Your Own Style, Don't Shrink, Real Not Performed, Own the Room as You.
//
//  ⚠️ `offersRecording` IS THE TASKS' FIELD, and the tasks name the ones:
//  Loud and Proud Name, Show and Tell at Home, Your Own Way (6 to 8);
//  Answer in Class, Two-Minute Talk, Read it Out Loud (8 to 11); Give the
//  Real Talk (11 to 14). Seven in thirty-six. Off by default, on this phone
//  only, never analysed, graded, scored, transcribed or profiled; the
//  child's own "notice one thing" is the only review.
//
//  ⚠️ `breathPageId` IS THE TASKS' "(Uses the app's breathing circle.)" —
//  Butterflies Breath, Your Calm-Down Routine, The Big-Day Routine, one per
//  band, open `cf_breath`, the door's one breath page, which is the app's
//  one circle. No second circle.
//
//  Ids are the scaffold's — `cf_68_01` … `cf_1114_12`, two per skill in
//  the door's skill order — so nothing on the rail moved when the copy
//  landed.
// =============================================================================

import '../../screens/skilling/sk_content.dart';

const List<SkSkillPurpose> kSkConfidenceSkills = [
  SkSkillPurpose(
    id: 'speaking_up',
    label: 'Speaking up',
    kidLine: 'Taking your turn out loud when it comes, instead of going '
        'quiet and letting it pass.',
  ),
  SkSkillPurpose(
    id: 'being_heard',
    label: 'Being heard',
    kidLine: 'A voice loud and clear enough to reach the back of the room, '
        'not a mumble at the floor.',
  ),
  SkSkillPurpose(
    id: 'facing_the_room',
    label: 'Facing the room',
    kidLine: 'Standing in front of people and looking at them, not turning '
        'away or hiding behind a book.',
  ),
  SkSkillPurpose(
    id: 'steadying_nerves',
    label: 'Steadying nerves',
    kidLine: 'The butterflies before you speak are normal. This is going '
        'anyway, not making them vanish.',
  ),
  SkSkillPurpose(
    id: 'keeping_going',
    label: 'Keeping going',
    kidLine: 'When you lose your place or fumble a word, carrying on '
        'instead of freezing or walking off.',
  ),
  SkSkillPurpose(
    id: 'being_yourself',
    label: 'Being yourself',
    kidLine: 'Saying it in your own words and your own way, not performing '
        'a memorised script perfectly.',
  ),
];

// -----------------------------------------------------------------------------
//  Task 4 of 36 — Use your voice, 6 to 8
// -----------------------------------------------------------------------------

const List<SkActivity> _useYourVoice = [
  SkActivity(
    id: 'cf_68_01',
    band: '6-8',
    skillPurpose: 'speaking_up',
    title: 'Loud and Proud Name',
    oneLine: 'Say your own name big and proud, like it is the best name in '
        'the world.',
    materials: 'Nothing.',
    offersRecording: true,
    steps: [
      'Whisper your name, very small and quiet.',
      'Now say it a bit louder.',
      'Now say it BIG, like a lion: "I am ___!"',
      'Stand tall while you say it. Feel how big your voice can be.',
    ],
    theThinking: 'Owning your own name out loud is the smallest, safest '
        'first rep of speaking up. Volume is a real skill a child can feel '
        'growing, with no meaning to get right, just the courage to be '
        'heard.',
    whatYouPractised: 'You made your voice big and proud. Speaking up '
        'starts with owning your own voice.',
  ),
  SkActivity(
    id: 'cf_68_02',
    band: '6-8',
    skillPurpose: 'speaking_up',
    title: 'Ask for It Yourself',
    oneLine: 'Next time you want something small, ask for it yourself.',
    materials: 'Nothing. A real everyday moment.',
    steps: [
      'Pick a small thing to ask for: water at a relative\'s house, your '
          'ice-cream flavour, a book from a high shelf.',
      'Instead of a grown-up asking, YOU ask. Out loud, to the person.',
      'Feeling shy? That is okay. Ask anyway.',
      'You did it. You spoke up for yourself.',
    ],
    theThinking: 'A real-world rep beats any drill. Asking for something '
        'herself, in a real moment, is speaking up where it counts. Keep it '
        'small and safe and let her do the talking.',
    whatYouPractised: 'You asked for something yourself, out loud. That is '
        'speaking up in real life.',
  ),
  SkActivity(
    id: 'cf_68_03',
    band: '6-8',
    skillPurpose: 'being_heard',
    title: 'Across the Room',
    oneLine: 'Send your voice all the way across the room, no shouting '
        'needed.',
    materials: 'Nothing. One person to listen.',
    steps: [
      'Ask someone to stand far away, across the room or in the next room.',
      'Say a sentence so they can hear every word. Not a scream, a big '
          'clear voice.',
      'Can they say it back to you? If not, send it a little bigger.',
      'Now swap. They send, you catch.',
    ],
    theThinking: 'Being heard is about reaching your listener, which is '
        'delivery, not what you say. Learning the difference between '
        'shouting and a voice that carries clearly is a real skill.',
    whatYouPractised: 'You sent your voice across the room and were heard. '
        'Making sure people can hear you is a real skill.',
  ),
  SkActivity(
    id: 'cf_68_04',
    band: '6-8',
    skillPurpose: 'being_heard',
    title: 'The Puppet Speaks',
    oneLine: 'Let a puppet do the talking, so your voice can come out to '
        'play.',
    materials: 'Any toy, sock, or a spoon with a face. Or just your hand.',
    steps: [
      'Pick a puppet (a soft toy, a sock, your own hand).',
      'Give it a voice and let IT say the lines out loud.',
      'Do a tiny show for one person: the puppet says hello, tells a joke, '
          'says bye.',
      'Notice, your voice came out loud and clear, through the puppet.',
    ],
    theThinking: 'A puppet gives a shy child cover. The voice comes out '
        'because it is the puppet being watched, not her. This is the '
        'gentlest on-ramp to being heard, and it genuinely works.',
    whatYouPractised: 'You gave the puppet a big clear voice. That voice is '
        'yours, and now you know it can come out.',
  ),
  SkActivity(
    id: 'cf_68_05',
    band: '6-8',
    skillPurpose: 'facing_the_room',
    title: 'Show and Tell at Home',
    oneLine: 'Show your family one thing you love and say a little about '
        'it.',
    materials: 'One thing you love (a toy, a drawing, a rock you found).',
    offersRecording: true,
    steps: [
      'Pick one thing that is special to you.',
      'Stand in front of your family, your safest audience.',
      'Show it and say two things: what it is, and why you love it.',
      'That is it. You faced the room and they smiled.',
    ],
    theThinking: 'Family is the safest possible audience, so it is where '
        'facing a room should begin. Standing and being looked at while you '
        'talk is the core skill, practised where it feels safe.',
    whatYouPractised: 'You stood up, faced your family, and spoke. That is '
        'real confidence, in the safest room there is.',
  ),
  SkActivity(
    id: 'cf_68_06',
    band: '6-8',
    skillPurpose: 'facing_the_room',
    title: 'Eyes Up',
    oneLine: 'Say something while looking right at someone, just for a '
        'moment.',
    materials: 'Nothing. One person.',
    steps: [
      'Say a short thing to someone: "I like your shirt", "Can I have a '
          'hug?"',
      'This time, look at their eyes while you say it. Too hard? Look at '
          'their forehead, it works just as well.',
      'Just for the length of your sentence. Then relax.',
      'Try it a few times. It gets easier.',
    ],
    theThinking: 'Looking at someone while speaking is a delivery skill that '
        'makes a child feel, and seem, more sure. The forehead trick removes '
        'the pressure for a shy child. Small, and it builds fast.',
    whatYouPractised: 'You looked at someone and spoke at the same time. '
        'That is a big confidence skill, and you did it.',
  ),
  SkActivity(
    id: 'cf_68_07',
    band: '6-8',
    skillPurpose: 'steadying_nerves',
    title: 'Butterflies Breath',
    oneLine: 'Feeling wobbly before you speak? Breathe the butterflies calm.',
    materials: 'Nothing. (Uses the app\'s breathing circle.)',
    breathPageId: 'cf_breath',
    steps: [
      'Before something that makes you nervous, notice the butterflies in '
          'your tummy.',
      'Open the breathing circle and take three slow balloon breaths with '
          'it.',
      'Feel the butterflies settle, just a little.',
      'Now go. The nerves may still be there, and that is fine. You can '
          'speak anyway.',
    ],
    theThinking: 'Nerves are the skill, not a bug. The child learns a real '
        'tool (the breath) to steady herself, and the honest truth that '
        'nervous-and-doing-it-anyway is what confidence is. Reuses the '
        'app\'s existing breathing circle.',
    whatYouPractised: 'You felt the nerves and breathed them steadier, then '
        'spoke anyway. That is exactly what brave feels like.',
  ),
  SkActivity(
    id: 'cf_68_08',
    band: '6-8',
    skillPurpose: 'steadying_nerves',
    title: 'Shake it Out',
    oneLine: 'Get the jitters out of your body before you speak.',
    materials: 'Nothing. Just your body.',
    steps: [
      'Feeling jittery? Stand up.',
      'Shake your hands, then your legs, then wiggle all over like a wet '
          'dog.',
      'Big stretch up tall. Big breath out.',
      'Now you are loose and ready. Go say your thing.',
    ],
    theThinking: 'For a young child, nerves live in the body, and moving '
        'them out is quick and real. Shaking and stretching before speaking '
        'is a tool she can use anywhere, and it is fun.',
    whatYouPractised: 'You shook the jitters out and got ready. Now you '
        'have a trick for whenever nerves show up.',
  ),
  SkActivity(
    id: 'cf_68_09',
    band: '6-8',
    skillPurpose: 'keeping_going',
    title: 'Oops, Keep Going',
    oneLine: 'Trip over your words? Laugh, and keep going.',
    materials: 'Nothing. A tongue-twister or a fast rhyme.',
    steps: [
      'Pick a tongue-twister or a fast rhyme (kachcha papad, pakka papad).',
      'Say it fast. You WILL trip. That is the whole point.',
      'When you trip, do not stop. Laugh, and keep going to the end.',
      'Do it again. Every time, finish, stumbles and all.',
    ],
    theThinking: 'The real skill is not "never make a mistake", it is '
        '"carry on after one". A tongue-twister makes mistakes certain and '
        'funny, so the child practises the recovery, calmly and with a '
        'laugh.',
    whatYouPractised: 'You tripped and kept going anyway. Carrying on after '
        'a stumble is what brave speakers do.',
  ),
  SkActivity(
    id: 'cf_68_10',
    band: '6-8',
    skillPurpose: 'keeping_going',
    title: 'Finish Your Sentence',
    oneLine: 'Start a thing to say, and finish it, all the way to the end.',
    materials: 'Nothing.',
    steps: [
      'Think of something to tell someone (about your day, a game you '
          'played).',
      'Say it all the way to the end, even if you feel shy halfway.',
      'If you get stuck, take a breath and pick it back up. Do not just '
          'trail off.',
      'Ta-da. You finished your whole thought out loud.',
    ],
    theThinking: 'Shy children often trail off and swallow the end. '
        'Practising finishing the sentence, even quietly, builds the habit '
        'of being heard all the way through. Keeping going is the skill.',
    whatYouPractised: 'You finished your whole thought out loud, right to '
        'the end. Finishing what you start saying is real confidence.',
  ),
  SkActivity(
    id: 'cf_68_11',
    band: '6-8',
    skillPurpose: 'being_yourself',
    title: 'Your Own Way',
    oneLine: 'Tell it your way. There is no wrong way to be you.',
    materials: 'Nothing.',
    offersRecording: true,
    steps: [
      'Tell about your day, or a story you like.',
      'Tell it YOUR way. Fast, slow, with your hands, with sound effects, '
          'however feels like you.',
      'There is no correct way. Your way is the right way.',
      'Notice how it feels to just be yourself out loud.',
    ],
    theThinking: 'Confidence is not performing a correct version, it is '
        'being yourself out loud. A quiet child is not broken and a loud one '
        'is not too much. This activity protects the child\'s own way of '
        'speaking, which is the whole point of the door.',
    whatYouPractised: 'You told it your own way. Being yourself out loud is '
        'the best kind of confidence.',
  ),
  SkActivity(
    id: 'cf_68_12',
    band: '6-8',
    skillPurpose: 'being_yourself',
    title: 'Silly Voices',
    oneLine: 'Be goofy on purpose, so being watched feels fun, not scary.',
    materials: 'Nothing.',
    steps: [
      'Pick a silly voice: a robot, a tiny mouse, a giant, dadaji.',
      'Say a normal sentence in that silly voice, big and bold.',
      'Get someone to guess who you are being.',
      'Try three different voices. Being watched is fun when you are '
          'playing.',
    ],
    theThinking: 'Play lowers the stakes of being seen. A child who can be '
        'goofy in front of others has already crossed the hardest part of '
        'confidence, not minding being watched. Silliness is a serious tool '
        'here.',
    whatYouPractised: 'You were big and goofy in front of someone, and it '
        'was fun. Being watched got a whole lot less scary.',
  ),
];

// -----------------------------------------------------------------------------
//  Task 5 of 36 — Stand up and say it, 8 to 11
// -----------------------------------------------------------------------------

const List<SkActivity> _standUpAndSayIt = [
  SkActivity(
    id: 'cf_811_01',
    band: '8-11',
    skillPurpose: 'speaking_up',
    title: 'Answer in Class',
    oneLine: 'Practise putting your hand up and answering, then do it for '
        'real.',
    materials: 'Nothing.',
    offersRecording: true,
    steps: [
      'At home, imagine you are in class. Say an answer out loud, clear and '
          'steady, like the teacher just called on you.',
      'Practise the hand going up too. "I know this one."',
      'Tomorrow in class, answer once. Just once. Even a small question.',
      'You did it. The first one is the hardest, and it is behind you now.',
    ],
    theThinking: 'Answering in class is the single most common place a '
        'child\'s confidence is tested, and dreaded. Rehearsing at home '
        'lowers the fear, and the honest goal is just one answer, because '
        'the first rep is what breaks the wall.',
    whatYouPractised: 'You spoke up in class. That is one of the bravest '
        'small things there is, and you did it.',
  ),
  SkActivity(
    id: 'cf_811_02',
    band: '8-11',
    skillPurpose: 'speaking_up',
    title: 'Say What You Think',
    oneLine: 'Share what YOU think, out loud, even if others think '
        'differently.',
    materials: 'Nothing. A real conversation.',
    steps: [
      'In a chat at home or with friends, notice when you have an opinion: '
          '"I think..."',
      'Say it out loud. Not louder than others, just clearly, as your view.',
      'It is okay if someone disagrees. Your job was to say what you think, '
          'and you did.',
      'Try it again another day. Having a view and voicing it gets easier.',
    ],
    theThinking: 'Speaking up grows from saying facts to voicing an opinion, '
        'which takes more nerve. This is about the courage to put your view '
        'in the room, not about winning the argument (a different skill, and '
        'a different door). Voicing it is the whole win.',
    whatYouPractised: 'You said what you think, out loud, as your own view. '
        'Voicing your opinion takes real nerve, and you have it.',
  ),
  SkActivity(
    id: 'cf_811_03',
    band: '8-11',
    skillPurpose: 'being_heard',
    title: 'Heard in the Group',
    oneLine: 'Get your point into a busy conversation without shouting or '
        'giving up.',
    materials: 'Nothing. A group chat at home or with friends.',
    steps: [
      'In a group where everyone is talking, you have something to add.',
      'Wait for a tiny gap, then say it with a clear, steady voice. Not a '
          'shout.',
      'Talked over? Do not shrink. Try once more: "I wanted to say..."',
      'You got heard. Being part of a busy group is a real skill.',
    ],
    theThinking: 'Being heard in a group, without either shouting or '
        'vanishing, is a genuinely hard delivery skill. Learning to find the '
        'gap and hold your turn is far more useful than "just be louder".',
    whatYouPractised: 'You got your point into a busy group and were heard. '
        'Finding your moment is a real skill.',
  ),
  SkActivity(
    id: 'cf_811_04',
    band: '8-11',
    skillPurpose: 'being_heard',
    title: 'On the Call',
    oneLine: 'Speak up clearly on a video or phone call.',
    materials: 'A real call (a relative, an online class), with a '
        'grown-up\'s okay.',
    steps: [
      'On a call it is harder to be heard, so look at the camera, not at '
          'yourself.',
      'Speak a little bigger and clearer than you would in the room.',
      'Wait for your turn, then say your bit without rushing.',
      'You spoke up on a call. That is a skill you will use your whole '
          'life.',
    ],
    theThinking: 'Calls are their own room, and being heard through a screen '
        '(camera, volume, turn-taking) is a modern delivery skill children '
        'now need early. Keep the call itself under the parent\'s okay.',
    whatYouPractised: 'You spoke up clearly on a call. Being heard through a '
        'screen is a real, modern skill.',
  ),
  SkActivity(
    id: 'cf_811_05',
    band: '8-11',
    skillPurpose: 'facing_the_room',
    title: 'Two-Minute Talk',
    oneLine: 'Give a short prepared talk about something you love.',
    materials: 'Nothing, or one small note card.',
    offersRecording: true,
    steps: [
      'Pick something you love and know well: a game, an animal, a place.',
      'Plan three things to say about it. Just three. Keep it to about two '
          'minutes.',
      'Stand up and give your talk to your family or a small group.',
      'You stood, you faced them, you finished. That is a real talk.',
    ],
    theThinking: 'The step up from show-and-tell: prepared, a little longer, '
        'delivered standing to a small audience. The focus stays on delivery '
        'and holding the room, not on perfect content. Three points keeps it '
        'doable.',
    whatYouPractised: 'You stood up and gave a whole talk, start to finish. '
        'Facing a room and holding it is real confidence.',
  ),
  SkActivity(
    id: 'cf_811_06',
    band: '8-11',
    skillPurpose: 'facing_the_room',
    title: 'Read it Out Loud',
    oneLine: 'Read a poem or a passage aloud to people, looking up as you '
        'go.',
    materials: 'Any book, poem, or something you wrote.',
    offersRecording: true,
    steps: [
      'Pick a short piece to read (a poem, a paragraph, your own writing).',
      'Read it out loud, not too fast, so every word lands.',
      'Look up at your listeners now and then, not just at the page.',
      'Reading aloud well is a skill you will use in class all the time.',
    ],
    theThinking: 'Reading aloud is a lower-stakes way to face a room (the '
        'words are given), while still practising pace, volume, and looking '
        'up. It maps straight onto a very common school task, so the reps '
        'pay off fast.',
    whatYouPractised: 'You read aloud to people, clear and steady, looking '
        'up. That is a delivery skill school asks for often.',
  ),
  SkActivity(
    id: 'cf_811_07',
    band: '8-11',
    skillPurpose: 'steadying_nerves',
    title: 'Your Calm-Down Routine',
    oneLine: 'Build your own quick routine for the moment before you speak.',
    materials: 'Nothing. (Uses the app\'s breathing circle.)',
    breathPageId: 'cf_breath',
    steps: [
      'Pick your three moves for right before you speak.',
      'One: a slow breath (use the breathing circle).',
      'Two: stand tall, shoulders back, like you mean it.',
      'Three: a quiet line in your head, like "I can do this." That is YOUR '
          'routine, ready anytime.',
    ],
    theThinking: 'A repeatable pre-speaking routine gives a child something '
        'to DO with the nerves instead of being swept by them. Building her '
        'own (breath, posture, a line) makes it hers and portable. Reuses '
        'the existing breathing circle.',
    whatYouPractised: 'You built your own calm-down routine. Now you have a '
        'plan for the wobbly moment before you speak.',
  ),
  SkActivity(
    id: 'cf_811_08',
    band: '8-11',
    skillPurpose: 'steadying_nerves',
    title: 'Nerves Are Normal',
    oneLine: 'Learn what nerves feel like, and why they are actually on your '
        'side.',
    materials: 'Nothing.',
    steps: [
      'Think about the last time you were nervous to speak. What did your '
          'body do? Racing heart? Dry mouth? Shaky hands?',
      'Here is the secret: that is your body giving you ENERGY to do the '
          'thing. It is not a warning that you will fail.',
      'Next time you feel it, say "that is just my energy showing up".',
      'Nerves and brave live in the same feeling. You can use them.',
    ],
    theThinking: 'A gentle, honest reframe: the physical signs of nerves are '
        'the body\'s readiness, not proof of coming failure. A child who '
        'understands this stops fearing the feeling itself, which is half '
        'the battle. Nerves are the skill, not a bug.',
    whatYouPractised: 'You learned that nerves are your body\'s energy, not '
        'a warning. Now they are on your side.',
  ),
  SkActivity(
    id: 'cf_811_09',
    band: '8-11',
    skillPurpose: 'keeping_going',
    title: 'Lost Your Place',
    oneLine: 'Forgot what to say mid-talk? Here is exactly what to do.',
    materials: 'Nothing.',
    steps: [
      'Practise a short talk, then on purpose, freeze in the middle like '
          'you forgot.',
      'Now the recovery: pause (that is allowed), take one breath.',
      'Glance at your note, or just start your last line again.',
      'Pick it back up and carry on. See? A blank is not the end.',
    ],
    theThinking: 'Every speaker goes blank sometimes. The child who has '
        'practised the recovery (pause, breathe, glance, resume) will not '
        'panic when it happens for real. Rehearsing the freeze removes its '
        'power.',
    whatYouPractised: 'You practised what to do when you go blank. Now a '
        'forgotten line is just a pause, not a disaster.',
  ),
  SkActivity(
    id: 'cf_811_10',
    band: '8-11',
    skillPurpose: 'keeping_going',
    title: 'Keep Going When They Laugh',
    oneLine: 'Someone giggles or a phone rings. You keep going anyway.',
    materials: 'Nothing. One person to "interrupt" on purpose.',
    steps: [
      'Start saying something. Ask someone to giggle, cough, or make a '
          'small noise in the middle, on purpose.',
      'Do not stop. Do not shrink. Take a breath and keep going.',
      'Try it a few times, with different interruptions.',
      'Now real ones will not throw you. You can carry on through '
          'anything.',
    ],
    theThinking: 'At this age the big fear is being laughed at. Practising '
        'carrying on through a giggle or a noise, safely and on purpose, '
        'takes the sting out of the real thing. Recovery, not perfection, is '
        'the skill.',
    whatYouPractised: 'You kept going through the giggles and noise. '
        'Carrying on when something interrupts is a strong, real skill.',
  ),
  SkActivity(
    id: 'cf_811_11',
    band: '8-11',
    skillPurpose: 'being_yourself',
    title: 'Your Own Style',
    oneLine: 'Find how YOU like to speak. There is no one right way.',
    materials: 'Nothing.',
    steps: [
      'Watch how different people speak: some are calm, some funny, some '
          'use their hands, some tell stories.',
      'Which feels like you? Try saying the same thing a few different '
          'ways.',
      'Keep the way that feels most like YOU. That is your style.',
      'You do not have to copy anyone. Your way is a real way.',
    ],
    theThinking: 'There is no single "confident" template. A quietly sure '
        'child and a bubbly one are both confident. Helping her find her own '
        'style protects her from performing a version that is not her, which '
        'is the opposite of real confidence.',
    whatYouPractised: 'You found the way of speaking that feels like you. '
        'Your own style is real confidence.',
  ),
  SkActivity(
    id: 'cf_811_12',
    band: '8-11',
    skillPurpose: 'being_yourself',
    title: 'Don\'t Shrink',
    oneLine: 'Practise not making yourself smaller when others are around.',
    materials: 'Nothing.',
    steps: [
      'Notice the ways we shrink: mumbling, saying "it\'s nothing", taking '
          'back what we said, staring at the floor.',
      'Say something you mean, in a normal clear voice, and just leave it '
          'there. Do not shrink it.',
      'If you feel the urge to take it back, do not. It was fine as it was.',
      'Standing at your normal size is enough. You do not have to be loud, '
          'just do not disappear.',
    ],
    theThinking: 'This is not "be louder". It is about not shrinking under '
        'peer pressure, not swallowing your own words. It protects the '
        'introvert especially, whose confidence is calm presence, not '
        'volume. Taking up your normal space is the win.',
    whatYouPractised: 'You said your thing and did not shrink it. Taking up '
        'your own space, calmly, is real confidence.',
  ),
];

// -----------------------------------------------------------------------------
//  Task 6 of 36 — Give a real talk, 11 to 14
// -----------------------------------------------------------------------------

const List<SkActivity> _giveARealTalk = [
  SkActivity(
    id: 'cf_1114_01',
    band: '11-14',
    skillPurpose: 'speaking_up',
    title: 'Speak Up to a Grown-Up',
    oneLine: 'Raise something with a teacher or adult, clearly and '
        'respectfully.',
    materials: 'Nothing. A real moment.',
    steps: [
      'Pick a real thing: ask a teacher to explain again, request '
          'something, or say you see it differently.',
      'Plan it in one or two clear lines. Respectful, not a fight.',
      'Say it to them, calmly, looking at them.',
      'You spoke up to someone in charge, politely. That takes real nerve.',
    ],
    theThinking: 'In a culture that prizes deference, speaking up to an '
        'adult is genuinely hard and genuinely important. Frame it as '
        'questioning the idea or making a request with respect, never '
        'defiance. (Cross-links to the Thinking door\'s "question ideas, not '
        'elders" line; keep the tone consistent across both.) The skill is '
        'the nerve to voice it, not the argument.',
    whatYouPractised: 'You spoke up to a grown-up, clearly and with '
        'respect. That is a brave, grown-up skill.',
  ),
  SkActivity(
    id: 'cf_1114_02',
    band: '11-14',
    skillPurpose: 'speaking_up',
    title: 'Ask the Real Question',
    oneLine: 'In a full room, put your hand up and ask YOUR question.',
    materials: 'Nothing. A real forum (class, assembly, a guest talk).',
    steps: [
      'When something is not clear, or you are curious, you have a real '
          'question.',
      'In front of everyone, raise your hand and ask it. Clearly, no '
          'apologising for asking.',
      'Others were probably wondering the same thing.',
      'You were the one brave enough to ask. That is leadership, quietly.',
    ],
    theThinking: 'Asking a question in a full room, without shrinking or '
        'over-apologising, is a real act of nerve at this age. It also '
        'models that not-knowing-and-asking is strength, not weakness, which '
        'is worth protecting.',
    whatYouPractised: 'You asked your question in front of everyone. Being '
        'the one who asks takes real nerve.',
  ),
  SkActivity(
    id: 'cf_1114_03',
    band: '11-14',
    skillPurpose: 'being_heard',
    title: 'Hold the Floor',
    oneLine: 'When it is your turn to speak to a group, hold it. Do not rush '
        'to hand it back.',
    materials: 'Nothing. A group.',
    steps: [
      'When you get the floor, do not gabble to get it over with.',
      'Say your point at a steady pace. Let a pause sit if you need one.',
      'Finish your thought fully before you stop. Do not trail off.',
      'You held the room\'s attention for your whole point. That is '
          'presence.',
    ],
    theThinking: 'Being heard grows from getting a word in to holding the '
        'floor: steady pace, allowing a pause, finishing fully. Owning your '
        'moment without rushing is a big delivery step up, and it reads as '
        'confidence.',
    whatYouPractised: 'You held the floor and let your point land, no '
        'rushing. Owning your moment is real presence.',
  ),
  SkActivity(
    id: 'cf_1114_04',
    band: '11-14',
    skillPurpose: 'being_heard',
    title: 'Reach the Back Row',
    oneLine: 'Practise being heard in a big space, with or without a mic.',
    materials: 'Nothing, or a mic if you have one. A big room if you can.',
    steps: [
      'Stand at one end of a big room (a hall, a terrace).',
      'Speak so someone at the FAR end hears every word. Aim your voice at '
          'them.',
      'On a mic? Keep it a hand\'s width away, speak steady, do not shout '
          'into it.',
      'You filled a big space with your voice. That is a real-stage skill.',
    ],
    theThinking: 'Assembly, annual day, and any hall need a voice that '
        'reaches the back row, a physical skill (projection, aim, mic '
        'distance) most kids never practise until they are on stage '
        'panicking. A few reps now change everything.',
    whatYouPractised: 'You made your voice reach the back of a big room. '
        'Filling a space is a real skill for any stage.',
  ),
  SkActivity(
    id: 'cf_1114_05',
    band: '11-14',
    skillPurpose: 'facing_the_room',
    title: 'Give the Real Talk',
    oneLine: 'Prepare and give a proper talk to a real audience. Standing, '
        'start to finish.',
    materials: 'Nothing, or a few note cards.',
    offersRecording: true,
    steps: [
      'Pick a topic and plan a real shape: an opening line, three points, a '
          'closing line. Aim for about five minutes.',
      'Practise it out loud a couple of times. Use notes as a map, do not '
          'read them word for word.',
      'Give it for real to a class, a club, or a family gathering. Stand '
          'tall, look around the room, take your time.',
      'You gave a real talk, all the way through. That is the big one.',
    ],
    theThinking: 'The band\'s headline skill: a full prepared talk delivered '
        'standing to a real audience, with eye contact and notes-not-'
        'reading. Keep the focus on DELIVERY (how you stand, look, pace); '
        'content craft belongs to the Communication door. Five minutes and '
        'three points keeps it real but doable.',
    whatYouPractised: 'You planned and delivered a whole talk to a real '
        'audience. Standing up and giving a real talk is a milestone. You '
        'hit it.',
  ),
  SkActivity(
    id: 'cf_1114_06',
    band: '11-14',
    skillPurpose: 'facing_the_room',
    title: 'Handle the Questions',
    oneLine: 'After your talk, take questions. Even the ones you cannot '
        'answer.',
    materials: 'Nothing. Someone to ask you a few questions.',
    steps: [
      'After a talk (or a practice one), invite questions.',
      'Listen to the whole question. Take a beat before you answer. A pause '
          'is fine.',
      'Answer what you can. If you do not know, say so honestly: "Good '
          'question, I am not sure, I will find out."',
      'You handled live questions with composure. That is the hardest, '
          'best part.',
    ],
    theThinking: 'The unscripted Q&A is the scariest moment for any speaker, '
        'and a distinct skill: listen fully, pause, answer, and say "I do '
        'not know" without shame. Composure under a question you cannot '
        'predict is real confidence, and honesty beats bluffing every time.',
    whatYouPractised: 'You took real questions and kept your cool, even the '
        'hard ones. Handling questions is the mark of a real speaker.',
  ),
  SkActivity(
    id: 'cf_1114_07',
    band: '11-14',
    skillPurpose: 'steadying_nerves',
    title: 'The Big-Day Routine',
    oneLine: 'Build your routine for a high-stakes speaking day.',
    materials: 'Nothing. (Uses the breathing circle.)',
    breathPageId: 'cf_breath',
    steps: [
      'For a real event (a presentation, an interview, annual day), plan '
          'the night before: prepare enough, then sleep. Cramming at '
          'midnight makes nerves worse.',
      'Plan the hour before: eat something light, look over your notes '
          'once, no panic-rehearsing.',
      'Plan the moment before: one slow breath (breathing circle), stand '
          'tall, your quiet line.',
      'Now you have a routine for the days that matter. Run it and trust '
          'it.',
    ],
    theThinking: 'A real pre-performance routine (night-before and '
        'moment-before) is what steady speakers rely on. Teaching a child to '
        'prepare-then-rest, rather than panic-cram, is a genuinely useful '
        'life skill for any high-stakes day. Reuses the breathing circle.',
    whatYouPractised: 'You built a routine for the big days. When it '
        'matters, you now have a plan you can trust.',
  ),
  SkActivity(
    id: 'cf_1114_08',
    band: '11-14',
    skillPurpose: 'steadying_nerves',
    title: 'Turn Nerves Into Fuel',
    oneLine: 'You cannot delete nerves. You can use them.',
    materials: 'Nothing.',
    steps: [
      'Here is the truth: even experienced speakers feel nervous. It never '
          'fully goes.',
      'That buzzing energy? It is fuel. It makes you sharper, more alive, '
          'more present.',
      'Before you speak, tell yourself: "I am not scared, I am charged '
          'up."',
      'The goal was never zero nerves. It is using the ones you have.',
    ],
    theThinking: 'The honest, grown-up reframe past "nerves are normal": the '
        'feeling never disappears, even for pros, and the real skill is '
        'channelling the adrenaline into energy and presence. This frees a '
        'child from the false goal of "no nerves", which only makes them '
        'worse.',
    whatYouPractised: 'You learned nerves are fuel, not a fault, and that '
        'even pros feel them. Now you can use yours.',
  ),
  SkActivity(
    id: 'cf_1114_09',
    band: '11-14',
    skillPurpose: 'keeping_going',
    title: 'Recover Out Loud',
    oneLine: 'Something goes wrong mid-talk? Recover in the open, with '
        'grace.',
    materials: 'Nothing. A practice talk with a planned "disaster".',
    steps: [
      'Practise a talk, and have someone throw a spanner: you lose your '
          'place, a "slide" fails, you misspeak.',
      'Do not hide it or freeze. Acknowledge it lightly: "Let me find my '
          'place... okay, here."',
      'Breathe, and carry on. A calm recovery often looks MORE confident '
          'than a perfect talk.',
      'You recovered in front of everyone, and kept going. That is real '
          'poise.',
    ],
    theThinking: 'The advanced recovery skill is not hiding a stumble but '
        'handling it openly and gracefully. Audiences warm to a human, '
        'composed recovery. Rehearsing the disaster on purpose means the '
        'real one will not derail her.',
    whatYouPractised: 'You hit a problem in front of people and recovered '
        'with grace. Handling a stumble out loud is real poise.',
  ),
  SkActivity(
    id: 'cf_1114_10',
    band: '11-14',
    skillPurpose: 'keeping_going',
    title: 'After a Rough One',
    oneLine: 'A talk went badly. Here is how you bounce back.',
    materials: 'Nothing.',
    steps: [
      'Sometimes a talk just goes wrong. You froze, or forgot, or it felt '
          'awful. It happens to everyone, truly.',
      'One rough talk is not who you are. It is one talk.',
      'Notice one thing you would do differently, then let the rest go. Do '
          'not replay it on a loop.',
      'Speak again soon, before the fear settles in. Getting back up is the '
          'whole skill.',
    ],
    theThinking: 'Resilience across time, not just in the moment: a bad talk '
        'is one event, not an identity, and the bounce-back is getting up '
        'and speaking again. Keep this warm and about ordinary speaking '
        'setbacks. If a child\'s distress runs deeper than a rough talk, the '
        'door\'s help line points to a trusted adult or professional.',
    whatYouPractised: 'You learned how to bounce back from a rough talk. '
        'Getting back up and speaking again is the bravest part.',
  ),
  SkActivity(
    id: 'cf_1114_11',
    band: '11-14',
    skillPurpose: 'being_yourself',
    title: 'Real, Not Performed',
    oneLine: 'Speak as yourself, not as a fake "presenter" or a copied '
        'style.',
    materials: 'Nothing.',
    steps: [
      'Notice the temptation to put on a fake voice, or copy an '
          'influencer\'s style, when you present.',
      'Try your talk two ways: the performed version, and just... you, '
          'talking honestly.',
      'Feel the difference? Real is warmer, and people trust it more.',
      'Be yourself at full volume. That beats any performance.',
    ],
    theThinking: 'At this age the pull is to perform a persona. But '
        'audiences trust real over polished-fake, and performing someone '
        'else is exhausting and hollow. The mature version of "your own '
        'style": deliver as genuinely you, just bigger.',
    whatYouPractised: 'You spoke as yourself, not a performance. Real always '
        'beats fake, and you found yours.',
  ),
  SkActivity(
    id: 'cf_1114_12',
    band: '11-14',
    skillPurpose: 'being_yourself',
    title: 'Own the Room as You',
    oneLine: 'Walk in, take your space, and let being yourself be enough.',
    materials: 'Nothing.',
    steps: [
      'Before you speak, remember: owning a room does not mean becoming '
          'someone louder or slicker.',
      'Walk in and take your space. Stand as yourself, calm or bright, '
          'whatever you are.',
      'Speak as you, and let that be enough. It is.',
      'Quiet-and-clear or warm-and-funny, both own a room. Yours is real.',
    ],
    theThinking: 'The capstone of the whole Confidence door, closing it on '
        'the note it opened: confidence is being yourself, out loud, at full '
        'size, even in the biggest room. It honours the introvert (quiet '
        'presence owns a room too) and the extrovert equally. No one has to '
        'become someone else to be confident.',
    whatYouPractised: 'You owned the room as yourself, no costume, no act. '
        'That is what real confidence looks like.',
  ),
];

/* kept for revert — the scaffold that filled the thirty-six slots before
   the task PDFs did (2026-09-16 → 2026-09-17). The ids it minted are the
   ids above.
const List<String> _skillOrder = [
  'speaking_up', 'speaking_up',
  'being_heard', 'being_heard',
  'facing_the_room', 'facing_the_room',
  'steadying_nerves', 'steadying_nerves',
  'keeping_going', 'keeping_going',
  'being_yourself', 'being_yourself',
];

List<SkActivity> _band(String band, String idBand) => [
      for (final (i, skill) in _skillOrder.indexed)
        SkActivity(
          id: 'cf_${idBand}_${(i + 1).toString().padLeft(2, '0')}',
          band: band,
          skillPurpose: skill,
          title: 'Activity ${i + 1}',
          comingSoon: true,
        ),
    ];
*/

final List<SkActivity> kSkConfidenceActivities = [
  ..._useYourVoice,
  ..._standUpAndSayIt,
  ..._giveARealTalk,
];
