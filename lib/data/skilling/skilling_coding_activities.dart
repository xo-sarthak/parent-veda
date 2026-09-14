// =============================================================================
//  Coding & AI literacy — the activity set, all three bands, filled
// -----------------------------------------------------------------------------
//  Scaffolded to `ParentVeda_Coding_structure_v2.pdf` ("a FULL set per band,
//  not a token one") and FILLED, verbatim, from the three task PDFs in
//  `tasks/coding/` on 2026-09-14:
//
//    Task 1 of 36  ·  6 to 8   ·  Unplugged  ·  twelve physical activities
//    Task 2 of 36  ·  8 to 11  ·  Blocks     ·  twelve in a free block tool
//    Task 3 of 36  ·  11 to 14 ·  Projects   ·  twelve projects, four of them
//                                              honest AI-literacy builds
//
//  ⚠️ THE COPY IS THE TASK PDFS', WORD FOR WORD. Kid voice, Hinglish-friendly
//  ("Silly, na?", "ulta", "tiffin", "chappal"), India first. The house rule
//  against Latin-script Hinglish is a rule for copy WE write; this copy is
//  supplied, and the tasks say "use it verbatim". Edit the PDF, not this
//  file. One deliberate omission: task 2's activity 12 carried a builder's
//  note inside `theThinking` ("point to the Stillness door, do not rebuild
//  it") — that is an instruction, not parent copy, and the Stillness door
//  does not exist yet; it is logged as an owed cross-link in the review file.
//
//  ⚠️ THE IDS ARE THE SCAFFOLD'S. `cd_68_01` … `cd_1114_12`, in the tasks'
//  order — sequencing ×2, pattern ×2, debugging ×2, decomposition ×2,
//  logic ×2, persistence ×2 — so nothing on the rail moved when the copy
//  landed and the keepsake's entries survive.
//
//  ⚠️ ONE ACTIVITY SAYS "SCORE", ON PURPOSE. `cd_1114_10` Make a Quiz Game
//  builds a quiz that keeps its PLAYERS' points; the task is explicit that
//  "a GAME the child builds may keep points for its players … the rule
//  forbids the app scoring the child's own skill". The sanity test's
//  vocabulary scan therefore excludes this file and instead checks every
//  activity's copy against an allow-list that names that one id.
// =============================================================================

import '../../screens/skilling/sk_content.dart';
import '../../screens/skilling/sk_door_content.dart';

/// Coding's six real thinking skills — the brief's list, in the brief's
/// words for the child ("putting steps in the right order, spotting the
/// mistake, seeing the pattern, breaking a big thing into small ones,
/// if-this-then-that, and sticking with it").
const List<SkSkillPurpose> kSkCodingSkills = [
  SkSkillPurpose(
    id: 'sequencing',
    label: 'Putting steps in order',
    kidLine: 'What comes first, what comes next.',
  ),
  SkSkillPurpose(
    id: 'pattern',
    label: 'Seeing the pattern',
    kidLine: 'Spotting what repeats, and what comes after.',
  ),
  SkSkillPurpose(
    id: 'debugging',
    label: 'Spotting the mistake',
    kidLine: 'Finding the step that went wrong, and fixing it.',
  ),
  SkSkillPurpose(
    id: 'decomposition',
    label: 'Breaking a big thing into small ones',
    kidLine: 'One big job is lots of little jobs.',
  ),
  SkSkillPurpose(
    id: 'logic',
    label: 'If this, then that',
    kidLine: 'Choices, and what happens because of them.',
  ),
  SkSkillPurpose(
    id: 'persistence',
    label: 'Sticking with it',
    kidLine: 'When it does not work the first time, trying again.',
  ),
];

// =============================================================================
//  Task 1 of 36 — Unplugged, 6 to 8
// =============================================================================

const List<SkActivity> _unplugged = [
  SkActivity(
    id: 'cd_68_01',
    band: '6-8',
    skillPurpose: 'sequencing',
    title: 'Be My Robot',
    oneLine: 'You are the boss. Someone in your house is your robot, and the '
        'robot only does exactly what you say.',
    materials: 'Nothing. Just you and one other person (or a soft toy you '
        'move for it).',
    steps: [
      'Pick a tiny job for your robot, like pick up one chappal and put it '
          'by the door.',
      'Your robot does ONE thing at a time, and only what you say. No '
          'guessing allowed.',
      'Give your steps out loud, one by one: walk three steps, turn left, '
          'bend down, pick up the chappal.',
      'If the robot ends up in the wrong place, that is not a mistake, it '
          'is a clue. Fix the step and try again.',
    ],
    theThinking: 'This is sequencing, the first coding skill. A computer, '
        'like the robot, does exactly what it is told in the exact order, '
        'nothing more. When it goes wrong, the child sees the instruction '
        'was unclear, not that anyone is silly. It is also her first real '
        'idea of how a machine thinks.',
    whatYouPractised: 'You gave steps in the right order and fixed them when '
        'they did not work. That is exactly what coding is.',
  ),
  SkActivity(
    id: 'cd_68_02',
    band: '6-8',
    skillPurpose: 'sequencing',
    title: 'The Morning Mix-Up',
    oneLine: 'Your getting-ready steps got all jumbled. Can you put them '
        'back in the right order?',
    materials: 'Nothing, or small paper scraps to draw the steps on.',
    steps: [
      'Think of something you do every day, like getting ready for school.',
      'Say the steps in the wrong order on purpose: wear shoes, wake up, '
          'eat breakfast, brush teeth. Silly, na?',
      'Now put them in the order that actually works. What has to come '
          'first? Can you wear shoes before you wake up?',
      'Try a harder one: making a jam sandwich, or packing your school bag.',
    ],
    theThinking: 'Order is everything in code, just like in real life. Some '
        'steps only work if another step happened first. Spotting "this '
        'must come before that" is real computational thinking.',
    whatYouPractised: 'You found the right order, and you noticed some steps '
        'have to come before others. Coders think about that all day.',
  ),
  SkActivity(
    id: 'cd_68_03',
    band: '6-8',
    skillPurpose: 'pattern',
    title: 'Rangoli Repeat',
    oneLine: 'Make a pattern that repeats, like a rangoli at the door.',
    materials: 'Nothing (draw with your finger on the floor or in the air). '
        'Or use small things you have: pulses, buttons, flowers, bindis.',
    steps: [
      'Start a simple repeat: dot, line, dot, line.',
      'Keep it going. What comes next? And after that?',
      'Now make your own repeat with two things, like flower, leaf, flower, '
          'leaf.',
      'Make it harder with three things that repeat. Can someone else guess '
          'what comes next?',
    ],
    theThinking: 'A pattern is a rule that repeats. Recognising and '
        'continuing a pattern is how a child starts to see the rules '
        'underneath things, which sits under both maths and code. A loop is '
        'just a pattern that repeats.',
    whatYouPractised: 'You spotted the rule and kept the pattern going. In '
        'coding, a pattern that repeats is called a loop. You just made one.',
  ),
  SkActivity(
    id: 'cd_68_04',
    band: '6-8',
    skillPurpose: 'pattern',
    title: 'Clap the Beat',
    oneLine: 'Make a sound pattern with your hands and feet, and pass it on.',
    materials: 'Nothing. Just your hands, feet and voice.',
    steps: [
      'Make a short beat: clap, clap, stomp.',
      'Do it again the same way. And again. That is your pattern.',
      'Ask someone to copy it back to you.',
      'Now make a longer one: clap, stomp, clap, snap. Can they still '
          'follow?',
    ],
    theThinking: 'Same skill as Rangoli Repeat, but with sound and movement, '
        'which suits a child who thinks with her body. Repeating and '
        'extending a pattern reliably is the skill; the medium does not '
        'matter.',
    whatYouPractised: 'You made a pattern and someone followed it exactly. '
        'Making a pattern others can follow is a real coding skill.',
  ),
  SkActivity(
    id: 'cd_68_05',
    band: '6-8',
    skillPurpose: 'debugging',
    title: 'Spot the Mistake',
    oneLine: 'There is one wrong step hiding in these instructions. Can you '
        'catch it?',
    materials: 'Nothing.',
    steps: [
      'A grown-up reads steps to draw a face: draw a circle, put two eyes '
          'at the bottom, put a nose in the middle, put a mouth at the top.',
      'Something is wrong. Eyes at the bottom? Mouth at the top?',
      'Find the steps that do not make sense and say them the right way.',
      'Try another: steps to get dressed where socks come after shoes. '
          'Catch the mix-up.',
    ],
    theThinking: 'This is debugging, and it is the door\'s most important '
        'habit. The instruction is wrong, not the child. Finding the broken '
        'step calmly, with no blame, is what a coder does most of the day. '
        'Keep it light and funny.',
    whatYouPractised: 'You found the step that was wrong and fixed it. '
        'Coders call that debugging. It is most of what they do.',
  ),
  SkActivity(
    id: 'cd_68_06',
    band: '6-8',
    skillPurpose: 'debugging',
    title: 'The Wrong Turn',
    oneLine: 'Your robot ended up in the wrong place. Which step sent it '
        'wrong?',
    materials: 'Nothing. (Plays best right after Be My Robot.)',
    steps: [
      'Give your robot steps to reach something, like the door.',
      'This time the robot ends up at the wrong spot, say the window '
          'instead of the door.',
      'Do not start all over. Go back through your steps. Which ONE was '
          'wrong? Was it "turn left" when it should have been "turn right"?',
      'Change just that step. Run it again. Did it work now?',
    ],
    theThinking: 'The key move is fixing one broken step, not scrapping the '
        'whole plan. That "find the one thing, change it, try again" loop is '
        'the real engine of coding, and of solving hard problems anywhere.',
    whatYouPractised: 'You did not start over. You found the one step that '
        'was wrong and changed it. That is clever debugging.',
  ),
  SkActivity(
    id: 'cd_68_07',
    band: '6-8',
    skillPurpose: 'decomposition',
    title: 'Big Job, Little Steps',
    oneLine: 'Big jobs feel easier when you cut them into small steps.',
    materials: 'Nothing.',
    steps: [
      'Pick a big job you know: tidy your room, pack your school bag, lay '
          'the plates for dinner.',
      'It feels big, na? Now break it into tiny steps. For the bag: put in '
          'the tiffin, then the water bottle, then the books, then the '
          'pencil box.',
      'Say all the little steps out loud.',
      'Do the job by your little steps. See how the big job got easy?',
    ],
    theThinking: 'Breaking a big thing into small parts is called '
        'decomposition, and it is how every hard problem in coding, and '
        'life, gets solved. A big scary task becomes a short list of small '
        'easy ones.',
    whatYouPractised: 'You took one big job and broke it into little steps. '
        'That is called decomposition. It makes hard things easy.',
  ),
  SkActivity(
    id: 'cd_68_08',
    band: '6-8',
    skillPurpose: 'decomposition',
    title: 'Shape by Shape',
    oneLine: 'Draw a big thing by breaking it into simple shapes.',
    materials: 'A stick in sand or mud, a finger on a foggy window, or paper '
        'if you have it. Nothing fancy.',
    steps: [
      'Pick something to draw: an elephant, a house, a diya.',
      'Do not draw it all at once. What simple shapes is it made of? An '
          'elephant is a big oval body, a round head, four rectangle legs, '
          'two triangle ears.',
      'Draw the shapes one at a time.',
      'Join them up. You made a big thing out of small shapes.',
    ],
    theThinking: 'Same skill as Big Job, Little Steps, but for making '
        'things: see the big thing as a set of small parts. This is how '
        'coders build big programs and how artists build big drawings, one '
        'small piece at a time.',
    whatYouPractised: 'You saw the small shapes inside a big picture and '
        'built it piece by piece. Coders build big things the same way.',
  ),
  SkActivity(
    id: 'cd_68_09',
    band: '6-8',
    skillPurpose: 'logic',
    title: 'If This, Then That',
    oneLine: 'A rule game. If I do this, you do that.',
    materials: 'Nothing. Just you and one other person.',
    steps: [
      'Set a rule together: IF I clap, THEN you hop. IF I stomp, THEN you '
          'freeze.',
      'Play. Clap, they hop. Stomp, they freeze. Mix it up fast.',
      'Add one more rule: IF I say "ulta", THEN swap them around.',
      'Now YOU make the rules and let someone else follow.',
    ],
    theThinking: '"If this, then that" is a conditional, one of the most '
        'important ideas in all of coding. Here it is a body game, so the '
        'child feels the idea long before she ever sees code. Making her '
        'own rules is the real leap.',
    whatYouPractised: 'You followed if-then rules, then made your own. '
        'Coders use if-then all the time to tell a computer what to do, and '
        'when.',
  ),
  SkActivity(
    id: 'cd_68_10',
    band: '6-8',
    skillPurpose: 'logic',
    title: 'Guess My Rule',
    oneLine: 'Someone sorts things by a secret rule. Can you crack it?',
    materials: 'A handful of small things from around the house: spoons, '
        'buttons, socks, toys.',
    steps: [
      'A grown-up quietly picks a secret rule, like "all the round things" '
          'or "all the red things".',
      'They put things into two piles by the secret rule, without telling '
          'you.',
      'Watch the piles. Guess the rule. Why is the spoon here and the ball '
          'there?',
      'Got it? Now YOU make a secret rule and let them guess.',
    ],
    theThinking: 'Working out a hidden rule from what you can see is logical '
        'reasoning. It is how a child learns to reason from evidence, the '
        'same muscle behind clear thinking everywhere.',
    whatYouPractised: 'You watched carefully and worked out the hidden rule. '
        'Figuring out the rule from clues is real logic.',
  ),
  SkActivity(
    id: 'cd_68_11',
    band: '6-8',
    skillPurpose: 'persistence',
    title: 'Try, Try Again',
    oneLine: 'Pick something hard that will not work the first time. The '
        'trying is the whole game.',
    materials: 'A sheet of paper (a paper plane or boat), or cups and '
        'vessels to stack, or a shoelace to tie.',
    steps: [
      'Choose your challenge: fold a paper plane that flies, stack five '
          'cups into a tower, tie a bow.',
      'Try it. It probably will not work the first time. Good. That is '
          'normal.',
      'Try again. And again. Change one small thing each time.',
      'Count your tries, not your wins. Every try taught you something.',
    ],
    theThinking: 'This is persistence, the emotional core of coding. Code '
        'almost never works the first time; the job IS trying again without '
        'giving up. We celebrate the attempts on purpose, never the success, '
        'so the child learns that retrying is the skill, not a sign of '
        'failing.',
    whatYouPractised: 'It did not work the first time, and you kept going. '
        'That is exactly what coders do. The trying IS the skill.',
  ),
  SkActivity(
    id: 'cd_68_12',
    band: '6-8',
    skillPurpose: 'persistence',
    title: 'A Different Way',
    oneLine: 'Same goal, three different ways. Do not just repeat, change '
        'your plan.',
    materials: 'A paper ball and a bin or bucket, or any "get it to work" '
        'challenge you have at home.',
    steps: [
      'Pick a goal: get the paper ball into the bucket from far away.',
      'Try it your first way.',
      'Missed? Do not do the exact same thing. Try a DIFFERENT way: throw '
          'softer, stand closer, go underarm.',
      'Three different tries, three different ideas. Which one worked best?',
    ],
    theThinking: 'This goes past "try again" to "try differently", which is '
        'iteration. Changing your approach when the first one fails, '
        'instead of repeating it, is how coders and problem-solvers '
        'actually get unstuck.',
    whatYouPractised: 'You did not just repeat, you tried a new way each '
        'time. Changing your plan when something fails is a superpower.',
  ),
];

// =============================================================================
//  Task 2 of 36 — Blocks, 8 to 11
// =============================================================================

const List<SkActivity> _blocks = [
  SkActivity(
    id: 'cd_811_01',
    band: '8-11',
    skillPurpose: 'sequencing',
    title: 'Make it Move',
    oneLine: 'Snap blocks together to walk your character across the '
        'screen.',
    tool: 'Scratch, or ScratchJr',
    steps: [
      'Pick a character (a cat, an auto, anyone you like).',
      'Drag a "move" block. Then a "turn" block. Then another "move".',
      'Click it. Watch your character go. Did it walk the way you wanted?',
      'Change the order of your blocks. See how the path changes? Order is '
          'everything.',
    ],
    theThinking: 'This is sequencing in blocks. Just like Be My Robot in the '
        'last band, the computer runs the blocks in the exact order you '
        'snapped them. The child now sees that order made visible.',
    whatYouPractised: 'You put blocks in the right order and your character '
        'followed them exactly. That is coding.',
  ),
  SkActivity(
    id: 'cd_811_02',
    band: '8-11',
    skillPurpose: 'sequencing',
    title: 'Dance Steps',
    oneLine: 'Make your character do a little dance, in time.',
    tool: 'Scratch, or ScratchJr',
    steps: [
      'Line up some moves: move, spin, jump, spin.',
      'Add a "wait" block between them so we can see each move.',
      'Play it. Too fast? Add more wait. Too slow? Take some out.',
      'Try changing the order of the dance. A new order makes a new dance.',
    ],
    theThinking: 'Order plus timing. The "wait" blocks teach that when '
        'things happen matters as much as what happens, which is real '
        'sequencing with a clock.',
    whatYouPractised: 'You ordered the moves and got the timing right. '
        'Coders think about order and timing all the time.',
  ),
  SkActivity(
    id: 'cd_811_03',
    band: '8-11',
    skillPurpose: 'pattern',
    title: 'Repeat It',
    oneLine: 'Instead of ten "move" blocks, use ONE repeat block.',
    tool: 'Scratch, or ScratchJr',
    steps: [
      'Make your character walk far by dragging "move" many times. Tiring, '
          'na?',
      'Now delete them. Find the "repeat" block.',
      'Put ONE "move" inside "repeat 10". Same walk, way less work.',
      'Change the number. Repeat 20. Repeat 3. Watch it change.',
    ],
    theThinking: 'A repeat block is a loop, and a loop is just the "Rangoli '
        'Repeat" pattern from the last band made real in code. Spotting '
        '"this repeats, so loop it" is a core coding move.',
    whatYouPractised: 'You found the repeating part and used a loop instead '
        'of doing it by hand. That is exactly how coders save work.',
  ),
  SkActivity(
    id: 'cd_811_04',
    band: '8-11',
    skillPurpose: 'pattern',
    title: 'Draw a Shape',
    oneLine: 'Use a loop to draw a perfect shape.',
    tool: 'Scratch (with the pen blocks)',
    steps: [
      'Turn on the pen so your character leaves a line as it moves.',
      'To draw a square: repeat 4 times [move, turn 90].',
      'Run it. A square appears. Magic? No, a pattern.',
      'Now try repeat 3 with turn 120 (a triangle), or a big number for a '
          'rangoli-like circle.',
    ],
    theThinking: 'The same loop, now making a visible pattern. The child '
        'feels how a small repeated rule (move, turn) builds a whole shape, '
        'which is the heart of how patterns and loops work together.',
    whatYouPractised: 'You made a loop draw a shape. A tiny rule, repeated, '
        'made something big. That is a loop doing a pattern.',
  ),
  SkActivity(
    id: 'cd_811_05',
    band: '8-11',
    skillPurpose: 'debugging',
    title: 'Fix the Cat',
    oneLine: 'This script is broken. Find the one block that is wrong.',
    tool: 'Scratch, or ScratchJr (parent loads the broken script from setup)',
    steps: [
      'Run the script. The character does something silly (walks off the '
          'screen, or turns the wrong way).',
      'Do not delete everything. Look block by block. Which one is wrong?',
      'Maybe a "turn right" should be "turn left". Maybe a number is too '
          'big.',
      'Change just that one block. Run it again. Fixed?',
    ],
    theThinking: 'Debugging in blocks. The habit is the same as The Wrong '
        'Turn: the block is wrong, not the child. Fix one thing, run again, '
        'stay calm. This is most of what coding actually is.',
    whatYouPractised: 'You found the one wrong block and fixed it. Coders '
        'call that debugging, and you just did it.',
  ),
  SkActivity(
    id: 'cd_811_06',
    band: '8-11',
    skillPurpose: 'debugging',
    title: "Why Won't It Work",
    oneLine: 'The blocks look right, but nothing happens. What is missing?',
    tool: 'Scratch (parent loads the script from setup)',
    steps: [
      'There is a script, but when you click, nothing moves.',
      'Check the top. Is there a "when green flag clicked" hat on it? '
          'Blocks with no hat never run.',
      'Or maybe the moves are so fast with no "wait" that you cannot see '
          'them.',
      'Add the missing block. Now it works.',
    ],
    theThinking: 'The trickiest bug is not a wrong block but a missing one. '
        'Learning to ask "what is missing or in the wrong place" is a big '
        'step up in debugging.',
    whatYouPractised: 'You worked out what was missing, not just what was '
        'wrong. That is clever debugging.',
  ),
  SkActivity(
    id: 'cd_811_07',
    band: '8-11',
    skillPurpose: 'decomposition',
    title: 'One Sprite at a Time',
    oneLine: 'Build a whole scene by adding one character at a time.',
    tool: 'Scratch, or ScratchJr',
    steps: [
      'Pick a scene: a fish tank, a busy road, a garden.',
      'Do not build it all at once. Add ONE thing first (one fish) and '
          'give it its own small script.',
      'Add the next thing (another fish, a bubble) with its own script.',
      'Keep going. Big scene, built from small parts.',
    ],
    theThinking: 'Decomposition in blocks. Instead of one giant confusing '
        'script, the child breaks the scene into small parts, each with its '
        'own simple job. This is how coders build big things without '
        'drowning.',
    whatYouPractised: 'You built a big scene one small part at a time. '
        'Breaking a big thing into small parts is called decomposition.',
  ),
  SkActivity(
    id: 'cd_811_08',
    band: '8-11',
    skillPurpose: 'decomposition',
    title: 'Break the Story',
    oneLine: 'Plan a tiny animation by breaking it into beats before you '
        'build.',
    tool: 'Scratch, or ScratchJr',
    steps: [
      'Pick a mini story: a character walks in, says hello, and waves.',
      'Before touching blocks, say the beats out loud: 1 walk in, 2 say '
          'hello, 3 wave.',
      'Now build ONE beat at a time. Get "walk in" working before you add '
          '"say hello".',
      'Join your beats. You planned it, then built it.',
    ],
    theThinking: 'Breaking a goal into beats before building is '
        'decomposition and planning together. It stops the child from '
        'getting lost in one big tangled script.',
    whatYouPractised: 'You broke your story into small beats and built them '
        'one by one. That is how coders plan.',
  ),
  SkActivity(
    id: 'cd_811_09',
    band: '8-11',
    skillPurpose: 'logic',
    title: 'When You Tap',
    oneLine: 'Make your character react. When you tap it, something '
        'happens.',
    tool: 'Scratch, or ScratchJr',
    steps: [
      'Find an event block: "when this sprite clicked" (or tapped).',
      'Under it, add an action: grow bigger, make a sound, change colour.',
      'Click your character. It reacts. WHEN this, THEN that.',
      'Add a second rule to a different character. Now two things react '
          'differently.',
    ],
    theThinking: '"When this, then that" is a conditional, the block version '
        'of the If This, Then That game from the last band. The program now '
        'decides what to do based on what happens.',
    whatYouPractised: 'You made your character follow a "when this, then '
        'that" rule. Coders use these rules to make things react.',
  ),
  SkActivity(
    id: 'cd_811_10',
    band: '8-11',
    skillPurpose: 'logic',
    title: 'Make a Choice',
    oneLine: 'Teach your program to decide by itself.',
    tool: 'Scratch',
    steps: [
      'Find an "if" block and a sensing block like "if touching the edge".',
      'Make a rule: if touching the edge, then turn around.',
      'Run it and watch your character bounce back on its own.',
      'Try another: if a key is pressed, then change colour.',
    ],
    theThinking: 'A real "if" block. The program checks a condition and '
        'chooses. This is deeper logic than a simple "when tap", because '
        'the computer is now deciding based on something it senses.',
    whatYouPractised: 'You gave your program a rule to decide by itself. '
        'Making the computer choose is real logic.',
  ),
  SkActivity(
    id: 'cd_811_11',
    band: '8-11',
    skillPurpose: 'persistence',
    title: 'Make it Better',
    oneLine: 'Build something simple, then keep making it better.',
    tool: 'Scratch, or ScratchJr',
    steps: [
      'Build one small working thing (a character that moves and makes a '
          'sound).',
      'It works? Good. Now make it better. Add a colour change.',
      'Better again. Add a background. Then a second character.',
      'Notice: it is never really "finished". There is always a next '
          'version.',
    ],
    theThinking: 'Persistence as iteration. Coders rarely finish in one go; '
        'they keep improving. Teaching a child that "done" is really "the '
        'next version" builds patience and pride instead of the fear of not '
        'getting it perfect first time.',
    whatYouPractised: 'You kept making your project better, bit by bit. '
        'Coders never stop at version one, and neither did you.',
  ),
  SkActivity(
    id: 'cd_811_12',
    band: '8-11',
    skillPurpose: 'persistence',
    title: 'Stuck? Try, Save, Try',
    oneLine: 'When it will not work and you feel cross, here is the '
        'coder\'s way through.',
    tool: 'Scratch',
    steps: [
      'Working on something and it just will not go right? That happens to '
          'every coder, every day.',
      'Try one change. Did it get closer? Keep it. Further? Undo it.',
      'Feeling cross? Take a slow breath first, then try the next thing.',
      'One small try at a time. This is how hard problems actually get '
          'solved.',
    ],
    // The task's parenthetical builder note ("the settle-breath here is
    // the same calming practice the app already has in the Stillness door;
    // point to it, do not rebuild it") is not parent copy and is logged as
    // an owed cross-link. See the file header.
    theThinking: 'Persistence as stamina. The real skill is not '
        'rage-quitting: try one change, keep what is closer, breathe if '
        'frustrated, go again.',
    whatYouPractised: 'It was hard and you stayed with it, one small try at '
        'a time. Not giving up is a coder\'s biggest strength.',
  ),
];

// =============================================================================
//  Task 3 of 36 — Projects, 11 to 14
// =============================================================================

const List<SkActivity> _projects = [
  SkActivity(
    id: 'cd_1114_01',
    band: '11-14',
    skillPurpose: 'sequencing',
    title: 'Build a Story Game',
    oneLine: 'Make a choose-your-path story where the player decides what '
        'happens next.',
    tool: 'Scratch',
    multiSession: true,
    steps: [
      'Write a short story with choices: a door on the left or the right, '
          'fight or run.',
      'Map the flow. Each choice leads to a different next scene. Draw it '
          'out first.',
      'Build the scenes and wire the choices so the story flows the right '
          'way.',
      'Play your own game. Does every path lead somewhere? Fix any dead '
          'ends.',
    ],
    theThinking: 'Sequencing at project scale is about the flow of a whole '
        'program, not just a few steps. Designing branching paths that all '
        'work is a real step up from a straight line of blocks.',
    whatYouPractised: 'You designed a story that flows in the right order, '
        'with choices. Getting the flow right is a real coder\'s job.',
  ),
  SkActivity(
    id: 'cd_1114_02',
    band: '11-14',
    skillPurpose: 'sequencing',
    title: 'Make a How-To App',
    oneLine: 'Build something that walks a user through a task, step by '
        'step.',
    tool: 'Scratch, or a free text editor',
    multiSession: true,
    steps: [
      'Pick a task you can teach: making chai, folding a paper boat, a '
          'simple rangoli.',
      'Break it into clear ordered steps for someone who has never done it.',
      'Build it so the user moves one step at a time, with a next button.',
      'Give it to a family member to follow. Where did they get stuck? Fix '
          'that step.',
    ],
    theThinking: 'Now the child sequences for a USER, not just for the '
        'computer. Designing the right order for a real person to follow is '
        'sequencing plus a first taste of thinking about who uses your '
        'thing.',
    whatYouPractised: 'You built something that guides a real person, step '
        'by step. Coders design flows for users all the time.',
  ),
  SkActivity(
    id: 'cd_1114_03',
    band: '11-14',
    skillPurpose: 'pattern',
    title: 'Draw Art with Code',
    oneLine: 'Use loops inside loops to make art you could never draw by '
        'hand.',
    tool: 'Scratch pen, or Python turtle',
    steps: [
      'Start with one loop that draws a shape (a square, from the last '
          'band).',
      'Now wrap it in ANOTHER loop that turns a little each time.',
      'Run it. Squares fan out into a mandala or a rangoli-like pattern.',
      'Change the numbers and colours. Small changes, wildly different art.',
    ],
    theThinking: 'A loop inside a loop is a pattern inside a pattern. Seeing '
        'how tiny repeated rules build rich, complex results is one of the '
        'most powerful ideas in coding, and it is beautiful.',
    whatYouPractised: 'You made loops build art too complex to draw by '
        'hand. Small rules, repeated, make big things.',
  ),
  SkActivity(
    id: 'cd_1114_04',
    band: '11-14',
    skillPurpose: 'pattern',
    title: 'Teach the Computer to Guess',
    oneLine: 'Show a computer some examples and watch it learn to spot the '
        'pattern. This is how AI really works.',
    tool: 'A free kid ML tool (for example Machine Learning for Kids), with '
        'a grown-up',
    withGrownUp: true,
    steps: [
      'Pick something simple to teach: happy faces vs sad faces, or cats '
          'vs dogs.',
      'Give the computer lots of EXAMPLES of each. This is called training.',
      'Now show it a new one. Does it guess right?',
      'Feed it messy or unfair examples on purpose. Watch it start guessing '
          'wrong. Why?',
    ],
    theThinking: 'This is honest AI literacy through the pattern skill. Real '
        'AI is not magic; it learns patterns from the examples we give it. '
        'And if the examples are bad or unfair, it learns wrong. A child '
        'who has trained one herself is much harder to fool later.',
    whatYouPractised: 'You taught a computer to spot a pattern from '
        'examples. That is exactly how real AI learns, and you saw why it '
        'makes mistakes.',
  ),
  SkActivity(
    id: 'cd_1114_05',
    band: '11-14',
    skillPurpose: 'debugging',
    title: 'Fix a Real Project',
    oneLine: 'Take a bigger project with several bugs and hunt them down '
        'one by one.',
    tool: 'Scratch (parent loads the buggy project from setup)',
    steps: [
      'Play the project. Notice everything that is wrong (it might be three '
          'or four things).',
      'Pick ONE bug. Make it happen again on purpose so you understand it.',
      'Find the block causing it, fix it, test just that one thing.',
      'Now the next bug. One at a time, calm and steady, until it all '
          'works.',
    ],
    theThinking: 'Real debugging is a discipline: reproduce, isolate, fix '
        'one thing, test. Doing it on a project with several bugs, without '
        'panicking, is a genuine coder skill and a genuine life skill.',
    whatYouPractised: 'You hunted down several bugs one at a time and stayed '
        'calm. That patient, one-at-a-time habit is what real debugging is.',
  ),
  SkActivity(
    id: 'cd_1114_06',
    band: '11-14',
    skillPurpose: 'debugging',
    title: 'Why AI Gets It Wrong',
    oneLine: 'Try to trip up an AI tool on purpose, and work out why it '
        'fails.',
    tool: 'A supervised look at a real AI tool, with a grown-up',
    withGrownUp: true,
    steps: [
      'With a grown-up, try an AI tool (a chatbot or an image maker).',
      'Ask it something you already know the answer to. Is it right?',
      'Now try to trip it: a trick question, something very local, '
          'something made up.',
      'Watch it answer confidently and be wrong. Talk about why: it learned '
          'from text and can be biased or just make things up.',
    ],
    theThinking: 'Debugging your own trust in the machine. Understanding '
        'that AI can be confidently wrong, and why, is the single most '
        'useful thing a child can learn about it right now. This is the '
        'mechanism side; the Thinking door handles the "is this true" '
        'reasoning side.',
    whatYouPractised: 'You found where an AI gets things wrong and worked '
        'out why. Knowing that machines can be confidently wrong keeps you '
        'smart about them.',
  ),
  SkActivity(
    id: 'cd_1114_07',
    band: '11-14',
    skillPurpose: 'decomposition',
    title: 'Plan Before You Build',
    oneLine: 'Take a big project idea and turn it into a real build plan.',
    tool: 'Paper or notes first, then Scratch or a text editor',
    multiSession: true,
    steps: [
      'Write down an ambitious idea (a game, an app, a tool you wish '
          'existed).',
      'Break it into parts. What are all the pieces it needs?',
      'Decide the smallest version that still works. What is the ONE thing '
          'to build first?',
      'Build that smallest version before adding anything else.',
    ],
    theThinking: 'Turning a big dream into a buildable plan is decomposition '
        'at its most useful. Learning to find the "smallest version that '
        'works" first is how real projects get finished instead of '
        'abandoned.',
    whatYouPractised: 'You broke a big idea into parts and found the first '
        'thing to build. That is how real projects actually get made.',
  ),
  SkActivity(
    id: 'cd_1114_08',
    band: '11-14',
    skillPurpose: 'decomposition',
    title: 'Build in Pieces',
    oneLine: 'Spot the part of your project you keep repeating, and turn it '
        'into one reusable piece.',
    tool: 'Scratch (custom blocks), or functions in text code',
    steps: [
      'In a project, find something you built more than once (a jump, a '
          'greeting, a bit of art).',
      'Make it ONCE as a custom block (or a function) with a clear name.',
      'Now use that named block wherever you need it, instead of '
          'rebuilding it.',
      'Change it in one place and watch it update everywhere. Neat, na?',
    ],
    theThinking: 'Naming a reusable piece is decomposition growing into real '
        'structure. This is the move from a pile of blocks to organised '
        'code, and it is exactly how professionals keep big projects sane.',
    whatYouPractised: 'You turned a repeated part into one named, reusable '
        'piece. That is how coders keep big projects tidy.',
  ),
  SkActivity(
    id: 'cd_1114_09',
    band: '11-14',
    skillPurpose: 'logic',
    title: 'Build a Chatbot',
    oneLine: 'Make a chatbot that replies by rules you write, then see how '
        'a real AI is different.',
    tool: 'Scratch, or a text editor',
    multiSession: true,
    steps: [
      'Build a simple bot: if the user says "hello", reply "namaste". If '
          'they say "bye", reply back.',
      'Add more rules. Notice it only knows what YOU told it.',
      'Ask it something you never gave a rule for. It has no idea. That is '
          'honest.',
      'Talk about it: a real AI chatbot did not get rules from a person, it '
          'learned from huge amounts of text, so it can answer almost '
          'anything, and can also be wrong or make things up.',
    ],
    theThinking: 'If-then logic at project scale, plus a true picture of AI. '
        'Building a rule-bot herself makes the difference crystal clear: '
        'her bot follows rules, a real AI learned patterns and guesses. '
        'That contrast is gold.',
    whatYouPractised: 'You built a bot from your own if-then rules, and you '
        'understood how a real AI is different. That is real logic and real '
        'AI sense.',
  ),
  SkActivity(
    id: 'cd_1114_10',
    band: '11-14',
    skillPurpose: 'logic',
    title: 'Make a Quiz Game',
    oneLine: 'Build a quiz that keeps score and reacts to right and wrong '
        'answers.',
    tool: 'Scratch, or a text editor',
    multiSession: true,
    steps: [
      'Pick a topic you love: cricket, space, your favourite show.',
      'Write questions. Use an "if" to check: if the answer is right, add '
          'a point.',
      'Use a variable to keep the player\'s points across the whole quiz.',
      'Add a friendly ending that shows the player how they did.',
    ],
    theThinking: 'Variables plus conditionals, the two workhorses of logic, '
        'in one build. (The points here are the game keeping score for its '
        'players, which is the child making a game. This is not the app '
        'grading the child.)',
    whatYouPractised: 'You used rules and a score-keeper to build a real '
        'quiz game. Variables and if-then are the tools coders use most.',
  ),
  SkActivity(
    id: 'cd_1114_11',
    band: '11-14',
    skillPurpose: 'persistence',
    title: 'Finish One Thing',
    oneLine: 'Take ONE project all the way to finished. Not perfect. '
        'Finished.',
    tool: 'Any, whatever the project uses',
    multiSession: true,
    steps: [
      'Pick one project you have started. Just one.',
      'Decide what "finished enough to show" means for it. Write that '
          'down.',
      'Work toward only that, across as many sittings as it takes. Come '
          'back to it.',
      'Reach finished. Then stop and notice: you finished something real.',
    ],
    theThinking: 'Persistence, and the skill most people never build: '
        'finishing. Real coders ship. Learning to take one thing to done, '
        'over several sessions, instead of starting ten and finishing none, '
        'is worth more than any single trick.',
    whatYouPractised: 'You took one project all the way to done, across '
        'many sittings. Finishing something real is a rare and powerful '
        'skill.',
  ),
  SkActivity(
    id: 'cd_1114_12',
    band: '11-14',
    skillPurpose: 'persistence',
    title: 'Share It and Make It Better',
    oneLine: 'Put your finished project in front of a real person and use '
        'what they tell you.',
    tool: 'Any, plus a family member to try it',
    steps: [
      'Show your finished project to someone at home. Let them actually '
          'use it.',
      'Watch, do not explain. Where do they get confused or stuck?',
      'Their confusion is not about you. It is information. Note what to '
          'improve.',
      'Fix one or two of those things. Your project just got better '
          'because you listened.',
    ],
    theThinking: 'Persistence in public: sharing your work, taking feedback '
        'without taking it personally, and improving. This is a big '
        'maturity step. Keep sharing private and to family only, never a '
        'public gallery with likes or ranking.',
    whatYouPractised: 'You showed your work, took real feedback, and made it '
        'better. Listening and improving is what the best makers do.',
  ),
];

final List<SkActivity> kSkCodingActivities = [
  ..._unplugged,
  ..._blocks,
  ..._projects,
];

// =============================================================================
//  The access rail — task 2's, extended by task 3
// -----------------------------------------------------------------------------
//  "Name the free tools, parent sets up once, prefer offline and no-account
//  options at this age … All are free. Never point a child to a paid tool
//  or one that shows ads to children. The parent chooses and sets up the
//  tool (and any account) under the shell's existing consent posture.
//  ParentVeda itself collects nothing and hosts no editor."
//
//  Task 3: "Keep leading with free tools the parent sets up once, prefer
//  offline and no-account … Scratch (offline app, no account) … Python
//  (with turtle for art) via a free editor. Introduce text code honestly and
//  optionally; never force it, never gate it … For the AI-literacy projects:
//  a free kid ML tool (for example Machine Learning for Kids) or a
//  supervised look at a real AI tool … done WITH a grown-up alongside."
//
//  The lines are the tasks' own words. No paid tool, no ads-at-kids, no
//  hardware. The Unplugged band has no entry — nothing to set up.
// =============================================================================

const List<SkAccessTool> kSkCodingAccess = [
  SkAccessTool(
    name: 'ScratchJr',
    line: 'Offline, no account, tablet. For the younger 8 to 9 end.',
    bands: ['8-11'],
    url: 'https://www.scratchjr.org/',
    offline: true,
    noAccount: true,
  ),
  SkAccessTool(
    name: 'Scratch, the offline app',
    line: 'Free from MIT, no account needed offline. The main tool for 8 '
        'to 11, and still excellent for games, art and animations at 11 to '
        '14.',
    bands: ['8-11', '11-14'],
    url: 'https://scratch.mit.edu/download',
    offline: true,
    noAccount: true,
  ),
  SkAccessTool(
    name: 'code.org',
    line: 'Browser, most puzzles need no account. A no-install option.',
    bands: ['8-11'],
    url: 'https://code.org/',
    noAccount: true,
  ),
  SkAccessTool(
    name: 'Blockly Games',
    line: 'Browser, no account. A no-install option.',
    bands: ['8-11'],
    url: 'https://blockly.games/',
    noAccount: true,
  ),
  SkAccessTool(
    name: 'Python, with turtle for art',
    line: 'For those ready to see real text code, via a free editor. '
        'Optional, never forced, never gated.',
    bands: ['11-14'],
    url: 'https://www.python.org/downloads/',
    offline: true,
    noAccount: true,
  ),
  SkAccessTool(
    name: 'Machine Learning for Kids',
    line: 'A free kid ML tool for the AI-literacy projects. Done with a '
        'grown-up alongside; AI tools have age limits and data rules.',
    bands: ['11-14'],
    url: 'https://machinelearningforkids.co.uk/',
  ),
  SkAccessTool(
    name: 'A supervised look at a real AI tool',
    line: 'A chatbot or an image maker, with a grown-up, for "Why AI Gets '
        'It Wrong". Your choice of tool; ParentVeda hosts none and sends no '
        'child data anywhere.',
    bands: ['11-14'],
  ),
];
