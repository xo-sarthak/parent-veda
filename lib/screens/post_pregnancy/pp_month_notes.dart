// =============================================================================
//  A note for every month from 12 to 36, then every three months to six
// -----------------------------------------------------------------------------
//  Parenting gap analysis, P1 (Behind · Age by age): "From 13 months our page
//  changes every 3, 6 and then 12 months. A parent of a 2 year old sees the
//  same page for half a year, and a 4 year old's for a whole year. Keep the 20
//  phases as the spine, and add a monthly page inside each phase from 12 to 36
//  months (24 pages), then every 3 months from 3 to 6 years (12 pages). Each
//  monthly page: 3 lines on what is new this month, ... 3 milestones, one thing
//  to try, one 'call the doctor if'." (The sleep and feeding basics sit on the
//  phase, in "At this age", so they are not repeated per month.)
//
//  Written 2026-10-07 for ParentVeda, in docs/PARENTING-VOICE.md: neutral
//  ("your toddler", "your child") because the same note reaches every family;
//  ranges, never deadlines ("usually around now", "many children"); the
//  milestones follow the CDC and AAP 2022 checkpoints (15, 18, 24 and 30
//  months, 3, 4 and 5 years), where three in four children can do the thing,
//  and the months between say "starting" rather than "should".
//  REQUIRED_REVIEW (paediatrician): every line, before launch.
// =============================================================================

class PpMonthNote {
  const PpMonthNote({
    required this.fromMonth,
    required this.label,
    required this.whatsNew,
    required this.usually,
    required this.tryThis,
    required this.callIf,
  });

  /// The first month this note covers (12..35 one each; 36..69 every three).
  final int fromMonth;

  /// "18 months", "3 years 3 months".
  final String label;
  final String whatsNew;

  /// Three things many children do around now.
  final List<String> usually;
  final String tryThis;
  final String callIf;
}

/// The note for a child of [months], or null under one year (the monthly
/// phases already change every month then) and past six years.
PpMonthNote? ppMonthNoteFor(int months) {
  if (months < 12 || months >= 72) return null;
  PpMonthNote? best;
  for (final n in kPpMonthNotes) {
    if (n.fromMonth <= months) best = n;
  }
  return best;
}

const List<PpMonthNote> kPpMonthNotes = [
  PpMonthNote(
    fromMonth: 12,
    label: '12 months',
    whatsNew: 'A first birthday, and a baby turning into a toddler. Some children are walking, many are cruising '
        'along the furniture, and a few first words may be coming. Big feelings arrive with all this new freedom.',
    usually: ['Pulls up to stand and walks holding on', 'Waves bye-bye and plays peekaboo', 'Picks up small food with thumb and finger'],
    tryThis: 'Name everything you hand over: "cup", "spoon", "ball". Pause, so there is room to answer.',
    callIf: 'there is no babbling, no pointing or waving, or a skill that had come seems to have gone.',
  ),
  PpMonthNote(
    fromMonth: 13,
    label: '13 months',
    whatsNew: 'Exploring everything, often with the mouth. Wobbly first steps are common now, and so are falls. '
        'Family food on the plate becomes most of the day\'s eating, with milk alongside.',
    usually: ['Takes a few steps, or walks holding one hand', 'Says one or two words with meaning', 'Looks at you to see how to react'],
    tryThis: 'Sit on the floor and roll a ball back and forth. Turn-taking is the start of conversation.',
    callIf: 'your toddler cannot bear weight on the legs, or does not respond to a name.',
  ),
  PpMonthNote(
    fromMonth: 14,
    label: '14 months',
    whatsNew: 'Pointing at things to show you, not only to ask. Stacking, emptying and filling are the favourite '
        'games. Sleep may wobble as one nap starts to feel like enough.',
    usually: ['Points to show you something interesting', 'Puts things in a container and takes them out', 'Copies simple actions, like brushing hair'],
    tryThis: 'Give a box and some safe objects to drop in and tip out. Say "in" and "out" as it happens.',
    callIf: 'there is no pointing at all, or eye contact is rare.',
  ),
  PpMonthNote(
    fromMonth: 15,
    label: '15 months',
    whatsNew: 'Walking for many, climbing for some. A few words, and a lot of meaning in sounds and gestures. '
        'This is a check-up age, with vaccines due on most schedules.',
    usually: ['Takes a few steps alone', 'Tries one or two words besides first sounds like "ma" and "pa"', 'Points to ask for something or to get help'],
    tryThis: 'Read the same short picture book every day, and let your toddler turn the pages.',
    callIf: 'there are no words at all, no walking with support, or no interest in other people.',
  ),
  PpMonthNote(
    fromMonth: 16,
    label: '16 months',
    whatsNew: 'Words grow slowly at first, then quickly. Your toddler understands far more than comes out in words. '
        'Saying "no" is a new and exciting skill.',
    usually: ['Follows a one-step request like "give me the cup"', 'Uses a spoon, messily', 'Scribbles if given a crayon'],
    tryThis: 'Offer two choices instead of a question: "the red cup or the blue cup?" It cuts the "no"s.',
    callIf: 'your toddler does not understand simple words like "no", or has lost words that were there before.',
  ),
  PpMonthNote(
    fromMonth: 17,
    label: '17 months',
    whatsNew: 'Busy, curious and fast. Safety at home matters more than ever now that drawers, stairs and taps '
        'are within reach. Tantrums may start as wants outrun words.',
    usually: ['Walks well and starts to run', 'Climbs onto low furniture', 'Points to one or two body parts when asked'],
    tryThis: 'Walk round your home at your toddler\'s height and move what can be pulled, opened or swallowed.',
    callIf: 'walking has not started by 18 months, or there are falls on one side every time.',
  ),
  PpMonthNote(
    fromMonth: 18,
    label: '18 months',
    whatsNew: 'A real toddler now: walking, trying words, wanting to do it alone. This is a check-up age, and '
        'many doctors use a short development screen at this visit.',
    usually: ['Walks without holding on', 'Says three or more words', 'Points to show you something, and looks back at you'],
    tryThis: 'Give simple jobs: "put the shoes by the door". Toddlers love to help, and it builds understanding.',
    callIf: 'your toddler is not walking, has fewer than six words, or has lost skills. Early help works best.',
  ),
  PpMonthNote(
    fromMonth: 19,
    label: '19 months',
    whatsNew: 'Pretend play begins: feeding a doll, talking on a toy phone. Words come in bursts, sometimes '
        'several a week. Sleep often settles into one longer afternoon nap.',
    usually: ['Pretends with toys, like feeding a doll', 'Kicks a ball forward', 'Drinks from an open cup with spills'],
    tryThis: 'Join the pretend game for five minutes and let your toddler lead it.',
    callIf: 'there is no pretend play at all, or your toddler seems not to hear you.',
  ),
  PpMonthNote(
    fromMonth: 20,
    label: '20 months',
    whatsNew: 'Strong opinions about clothes, food and who does what. Climbing gets more ambitious. '
        'Words like "mine" and "more" are everywhere.',
    usually: ['Says 10 to 20 words', 'Takes off socks or a hat', 'Stacks three or four blocks'],
    tryThis: 'Describe feelings out loud: "you are cross because the game ended". Naming comes before managing.',
    callIf: 'your toddler has no words to ask for things and is not using gestures either.',
  ),
  PpMonthNote(
    fromMonth: 21,
    label: '21 months',
    whatsNew: 'Two words together may appear: "more milk", "papa gone". Running is faster than walking. '
        'Many toddlers start showing interest when others use the toilet.',
    usually: ['Puts two words together, or is close to it', 'Runs and climbs stairs holding on', 'Turns pages of a board book one at a time'],
    tryThis: 'Repeat and add a word: if your toddler says "car", you say "big car".',
    callIf: 'there are fewer than 10 words, or no copying of words or sounds.',
  ),
  PpMonthNote(
    fromMonth: 22,
    label: '22 months',
    whatsNew: 'Playing beside other children more than with them, which is exactly right for now. Sharing is '
        'still hard. Sleep can be disturbed by molars coming through.',
    usually: ['Follows two simple steps, like "pick up the ball and bring it"', 'Recognises familiar people in photos', 'Helps with undressing'],
    tryThis: 'Look at family photos together and name everyone: grandma, uncle, big sister.',
    callIf: 'your toddler does not seem to notice other children at all, or does not follow simple requests.',
  ),
  PpMonthNote(
    fromMonth: 23,
    label: '23 months',
    whatsNew: 'Lots of "why" faces even before the "why" questions. Independence and tears often arrive '
        'together. A steady daily rhythm helps more than anything else this month.',
    usually: ['Names a few pictures in a book', 'Uses a spoon with less mess', 'Shows affection without being asked'],
    tryThis: 'Keep the same small bedtime routine every night: bath, book, bed. Predictable feels safe.',
    callIf: 'there are no two-word phrases coming, or play is the same repeated action all day.',
  ),
  PpMonthNote(
    fromMonth: 24,
    label: '2 years',
    whatsNew: 'Two years old. Language often takes off now, with new words every day. This is a check-up age, '
        'and a common age for a development screen.',
    usually: ['Says at least two words together, like "more milk"', 'Points to things in a book when you ask', 'Kicks a ball'],
    tryThis: 'Talk through what you are doing while you cook or fold clothes. Everyday talk builds language best.',
    callIf: 'your child is not using two-word phrases, does not copy actions or words, or has lost skills.',
  ),
  PpMonthNote(
    fromMonth: 25,
    label: '25 months',
    whatsNew: 'Running, jumping and climbing everywhere. Your child may want the same story, the same cup and the '
        'same seat every time. That sameness is comforting, not stubbornness.',
    usually: ['Jumps with both feet off the ground', 'Uses about 50 words or more', 'Sorts shapes or colours with help'],
    tryThis: 'Play "what\'s missing": hide one of three toys under a cloth and guess which.',
    callIf: 'your child falls a lot more than other children, or speech is very hard to understand at home.',
  ),
  PpMonthNote(
    fromMonth: 26,
    label: '26 months',
    whatsNew: 'Pretend play gets richer, with little stories. Many children show signs of being ready for potty '
        'learning around now, and many are not, and both are normal.',
    usually: ['Makes up simple pretend stories with toys', 'Washes and dries hands with help', 'Says "I" or "me"'],
    tryThis: 'If your child tells you about a wet nappy or hides to poo, that is a sign of readiness. Follow the cue.',
    callIf: 'there is no pretend play, or your child does not respond when spoken to.',
  ),
  PpMonthNote(
    fromMonth: 27,
    label: '27 months',
    whatsNew: 'Strong feelings, short fuses. Tantrums usually peak somewhere between two and three. Calm, short '
        'words and staying close help more than long explanations.',
    usually: ['Takes turns in a simple game', 'Draws a line when shown how', 'Asks for things with words, not only pointing'],
    tryThis: 'After a tantrum, a hug and one sentence: "that was hard, you are okay now". Then move on.',
    callIf: 'tantrums are very long or very frequent, or your child gets hurt during them.',
  ),
  PpMonthNote(
    fromMonth: 28,
    label: '28 months',
    whatsNew: 'Questions begin: "what\'s that?", again and again. Your child can follow more of a story and '
        'may join in with rhymes. Fine fingers are getting better at small tasks.',
    usually: ['Asks simple questions', 'Joins in with familiar rhymes', 'Turns a door handle or unscrews a lid'],
    tryThis: 'Sing the rhymes your own family grew up with, in your home language. Every language helps.',
    callIf: 'your child is not asking for things with words, or seems not to understand simple questions.',
  ),
  PpMonthNote(
    fromMonth: 29,
    label: '29 months',
    whatsNew: 'Playing near other children, and starting to play with them. Many families start thinking about '
        'playschool now. There is no rush; readiness matters more than age.',
    usually: ['Plays alongside other children and starts to join in', 'Follows two-step instructions', 'Puts on loose clothes with help'],
    tryThis: 'Arrange a short playdate with one child. One friend is easier than a crowd.',
    callIf: 'your child avoids other children completely, or loses words or skills.',
  ),
  PpMonthNote(
    fromMonth: 30,
    label: '30 months',
    whatsNew: 'Two and a half. Sentences of three words are common, and so is a lot of "I do it". This is a '
        'check-up age and a common time for a development screen.',
    usually: ['Says about 50 words or more and uses two or three together', 'Plays with other children, like a chasing game', 'Takes some clothes off alone'],
    tryThis: 'Give your child a small daily job, like putting spoons on the table. Pride grows with responsibility.',
    callIf: 'your child is not putting words together, does not play with others, or has lost skills.',
  ),
  PpMonthNote(
    fromMonth: 31,
    label: '31 months',
    whatsNew: 'Imagination is everywhere: boxes become cars, sticks become spoons. Fears can appear too, of the '
        'dark, dogs or loud noises. Taking a fear seriously helps it pass.',
    usually: ['Uses things to stand for other things in play', 'Names a few colours, maybe not always right', 'Climbs well'],
    tryThis: 'Keep a box of safe household things for pretend play: a dupatta, steel bowls, an old phone.',
    callIf: 'fears stop your child from everyday things, or play is always the same narrow routine.',
  ),
  PpMonthNote(
    fromMonth: 32,
    label: '32 months',
    whatsNew: 'Longer stretches of focus on one game. Your child may be dry during the day, or still in nappies, '
        'and both are within the normal range.',
    usually: ['Plays one game for a few minutes', 'Copies a circle when shown', 'Understands "in", "on" and "under"'],
    tryThis: 'Play hide the toy and give clues with "under", "behind" and "next to".',
    callIf: 'strangers understand almost none of your child\'s speech.',
  ),
  PpMonthNote(
    fromMonth: 33,
    label: '33 months',
    whatsNew: 'Friendships begin, with a favourite name mentioned often. Sharing is still hard, and turn-taking '
        'is easier with a grown-up nearby. Sleep may change if the nap fades.',
    usually: ['Talks about a friend by name', 'Uses "my", "me" and "you" correctly most of the time', 'Pedals a tricycle, or tries to'],
    tryThis: 'Use a sand timer or a song to make turns visible: "when the song ends, it is your turn".',
    callIf: 'your child shows no interest in other children, or cannot follow simple rules in play.',
  ),
  PpMonthNote(
    fromMonth: 34,
    label: '34 months',
    whatsNew: 'Stories with a beginning, middle and end start to make sense. Your child may tell you about the '
        'day in a few short sentences, if you ask at the right moment.',
    usually: ['Talks in short sentences', 'Remembers a part of a familiar story', 'Washes hands without help'],
    tryThis: 'At bedtime, ask "what was the best part of today?" and wait for the answer.',
    callIf: 'your child speaks only in single words, or you notice skills being lost.',
  ),
  PpMonthNote(
    fromMonth: 35,
    label: '35 months',
    whatsNew: 'Nearly three. More able to wait a moment, share a little and say how it feels. A few children are '
        'starting playschool; there is no single right age for it.',
    usually: ['Says a first name when asked', 'Draws a rough circle', 'Takes turns with a little help'],
    tryThis: 'Practise little goodbyes with someone your child trusts, so the first school goodbye is not the first.',
    callIf: 'separation is so hard that daily life cannot go on, or speech is still very hard to understand.',
  ),
  PpMonthNote(
    fromMonth: 36,
    label: '3 years',
    whatsNew: 'Three. Talking in sentences, asking "why", and playing with other children. This is a check-up '
        'age, with an eye and hearing check worth asking about.',
    usually: ['Talks with you in conversation, back and forth', 'Draws a circle when you show how', 'Asks who, what, where or why questions'],
    tryThis: 'Answer "why" questions with a question back: "why do you think?" It grows thinking, not only words.',
    callIf: 'your child does not speak in sentences, does not play pretend, or has lost skills.',
  ),
  PpMonthNote(
    fromMonth: 39,
    label: '3 years 3 months',
    whatsNew: 'Hands are getting clever: buttons, crayons, scissors with help. Many children enjoy simple counting '
        'and sorting games now.',
    usually: ['Counts a few objects, maybe not in order', 'Uses child scissors with help', 'Plays a simple game with rules'],
    tryThis: 'Sort the laundry together by colour or by whose it is. Sorting is early maths.',
    callIf: 'your child cannot do any fine finger tasks, or avoids drawing and play entirely.',
  ),
  PpMonthNote(
    fromMonth: 42,
    label: '3 years 6 months',
    whatsNew: 'Friendships matter more. Playing family, shop or doctor is common. Many children can be dry at '
        'night, and many cannot yet, and that is normal until five or later.',
    usually: ['Plays pretend with other children', 'Tells a short story about something that happened', 'Dresses with little help'],
    tryThis: 'Set up a small "shop" with packets from the kitchen and real coins. Talk, count and take turns.',
    callIf: 'your child is not interested in playing with others, or speech is hard for family to follow.',
  ),
  PpMonthNote(
    fromMonth: 45,
    label: '3 years 9 months',
    whatsNew: 'Questions get deeper: where babies come from, what happens when things die. Simple, true answers '
        'are enough.',
    usually: ['Asks lots of questions about the world', 'Knows some colours and shapes', 'Hops on one foot, or tries'],
    tryThis: 'Teach the right names for body parts, and that some parts are private. It keeps children safe.',
    callIf: 'your child stutters badly enough to be upset by it, or the stutter lasts many months.',
  ),
  PpMonthNote(
    fromMonth: 48,
    label: '4 years',
    whatsNew: 'Four. Stories, jokes, rules and a strong sense of fair. This is a check-up age, and a good time to '
        'check vision and hearing before school.',
    usually: ['Says sentences of four words or more', 'Names some colours', 'Catches a large ball most of the time'],
    tryThis: 'Play simple board games and let your child lose sometimes. Losing kindly is a skill to practise.',
    callIf: 'your child cannot tell a simple story, does not play with others, or has lost skills.',
  ),
  PpMonthNote(
    fromMonth: 51,
    label: '4 years 3 months',
    whatsNew: 'Drawing people with heads and legs, and maybe a body. Writing-like squiggles may appear. There is no '
        'need to push letters yet.',
    usually: ['Draws a person with two or three parts', 'Uses scissors to cut a line', 'Follows three-step instructions'],
    tryThis: 'Ask your child to tell you about a drawing, and write the words down under it.',
    callIf: 'your child holds a crayon with great difficulty or avoids all drawing.',
  ),
  PpMonthNote(
    fromMonth: 54,
    label: '4 years 6 months',
    whatsNew: 'Bigger feelings, better words for them. Your child may want to win every game and find '
        'losing hard. Patience and practice help.',
    usually: ['Talks about feelings using words like sad or angry', 'Plays cooperatively with other children', 'Counts up to ten'],
    tryThis: 'Name a feeling you had today and what you did about it. Children learn calm by watching it.',
    callIf: 'anger or worry is so big it stops your child joining in at school or with family.',
  ),
  PpMonthNote(
    fromMonth: 57,
    label: '4 years 9 months',
    whatsNew: 'Getting ready for big school, whatever age it starts where you live. Independence at the toilet, '
        'opening a tiffin and asking for help all matter more than reading early.',
    usually: ['Uses the toilet without help', 'Opens a tiffin box and eats without help', 'Asks an adult for help when needed'],
    tryThis: 'Practise the school routine at home: tiffin, water bottle, shoes, bag. Small rehearsals ease the first week.',
    callIf: 'your child still cannot manage the toilet in the day, or is very withdrawn with other adults.',
  ),
  PpMonthNote(
    fromMonth: 60,
    label: '5 years',
    whatsNew: 'Five. Telling stories, following rules, and caring about friends. This is a check-up age, and a '
        'good time for school-entry vaccines and an eye check.',
    usually: ['Tells a story with at least two events', 'Answers simple questions about a story', 'Writes some letters, maybe a name'],
    tryThis: 'Read together every day, and let your child "read" the pictures back to you.',
    callIf: 'your child cannot keep up with others in play or talk, or has lost skills.',
  ),
  PpMonthNote(
    fromMonth: 63,
    label: '5 years 3 months',
    whatsNew: 'Friends, games with rules, and a lot of talk about fairness. Many children start losing baby teeth '
        'from around six, some a little earlier.',
    usually: ['Plays games with simple rules', 'Hops and skips', 'Knows the home address or a parent\'s phone number, with practice'],
    tryThis: 'Practise your phone number as a song until it sticks. It is a real safety skill.',
    callIf: 'your child has trouble making any friends, or is often left out and very unhappy.',
  ),
  PpMonthNote(
    fromMonth: 66,
    label: '5 years 6 months',
    whatsNew: 'Reading and counting may click, or may not yet, and both are normal. Confidence comes from feeling '
        'capable at home: small jobs, small choices, praise for effort.',
    usually: ['Recognises some written words', 'Counts ten or more things', 'Gets dressed without help'],
    tryThis: 'Praise the effort, not the result: "you kept trying with those buttons".',
    callIf: 'your child seems not to see the board or a page clearly, or does not follow class instructions.',
  ),
  PpMonthNote(
    fromMonth: 69,
    label: '5 years 9 months',
    whatsNew: 'Almost six. Bigger questions, bigger friendships, and a growing sense of self. The Skilling '
        'stage of ParentVeda picks up from six.',
    usually: ['Explains the rules of a game', 'Shows care when someone is hurt', 'Ties a knot, or is learning to'],
    tryThis: 'Let your child plan a small family activity: what to cook on Sunday, which park to visit.',
    callIf: 'worry, sadness or anger seem bigger than you would expect, and last for weeks.',
  ),
];
