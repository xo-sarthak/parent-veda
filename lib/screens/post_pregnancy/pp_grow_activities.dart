// =============================================================================
//  Grow — the activity library, widened to birth-to-five.
// -----------------------------------------------------------------------------
//  WHY THIS FILE EXISTS SEPARATELY FROM pp_development_data.dart.
//
//  The redesign brief asks for "the single best activity today, every day", a
//  daily habit and a streak. The library it would draw on had EIGHT activities,
//  every one of them an infant activity — tummy time, reach for the ring,
//  black-white-and-red. Nothing for a two-year-old, let alone a five-year-old.
//
//  So a parent hits a repeat on day nine, and "ParentVeda already knows what to
//  do today" becomes visibly untrue inside a fortnight. That is a CONTENT
//  problem wearing a design problem's clothes: every screen in the brief could
//  be built perfectly and the feature would still fail in week two.
//
//  These are additive. kDevActivities is untouched, so V1 — "what it is right
//  now" — keeps showing exactly the eight it always did, and the comparison
//  stays honest. V2 and V3 read kGrowActivities, which is the eight plus these.
//
//  AGE IS CARRIED IN ageTag, not a new field, on purpose. Adding required
//  fields to DevActivity would mean editing all eight existing entries, which
//  is precisely the "rewrite a shipped thing" the repo warns about. growAgeRange
//  in pp_grow_data.dart parses these strings instead, and a test pins every one
//  of them so a typo cannot silently drop an activity out of every age band.
//
//  FORMAT RULE: '0–3 mo', '12–18 mo', '2–3 yr'. En dash, lowercase unit, always
//  a range. The parser is strict so that a malformed tag fails loudly in a test
//  rather than quietly making an activity unreachable.
// =============================================================================

import 'pp_development_data.dart';

/// Everything added for birth-to-five coverage. Combined with the original
/// eight in `kGrowActivities` (pp_grow_data.dart).
const List<DevActivity> kGrowExtraActivities = [
  // ---- 0–3 months ---------------------------------------------------------
  DevActivity(
    id: 'g_face_time',
    title: 'Face to face, up close',
    areaId: 'social',
    minutes: 3,
    difficulty: 'Easy',
    ageTag: '0–3 mo',
    materials: ['Nothing — just your face'],
    skills: ['Bonding', 'Focus', 'Face recognition'],
    safety: ['Stop if he turns away — that is him asking for a break'],
    benefit:
        'A newborn sees clearest at about 20–30 cm, roughly the distance to your face while feeding. Time spent there is how he learns what a face is.',
    steps: [
      'Hold him about a forearm away, facing you.',
      'Say nothing for a moment. Just let him look.',
      'Slowly stick out your tongue, or open your mouth wide.',
      'Wait. Some babies copy — days or weeks later, not always today.',
    ],
    seed: 21,
  ),
  DevActivity(
    id: 'g_tracking',
    title: 'Follow the slow toy',
    areaId: 'cognitive',
    minutes: 3,
    difficulty: 'Easy',
    ageTag: '0–3 mo',
    materials: ['One high-contrast toy or a red ribbon'],
    skills: ['Visual tracking', 'Attention'],
    safety: ['Keep the object well clear of his face'],
    benefit:
        'Tracking a moving object is the eye muscles and the brain learning to work together — the same skill that later becomes reading across a line.',
    steps: [
      'Hold the toy about 25 cm from his eyes until he settles on it.',
      'Move it slowly to one side. Slower than feels natural.',
      'If he loses it, bring it back to the middle and start again.',
      'Two or three passes is plenty.',
    ],
    seed: 22,
  ),
  DevActivity(
    id: 'g_first_tummy',
    title: 'The first tummy minutes',
    areaId: 'gross_motor',
    minutes: 2,
    difficulty: 'Easy',
    ageTag: '0–3 mo',
    materials: ['A firm flat surface, or your own chest'],
    skills: ['Neck strength', 'Shoulder strength'],
    safety: [
      'Always awake and always watched',
      'Never on a soft mattress or pillow',
      'Stop at the first real protest — short and often beats long and unhappy',
    ],
    benefit:
        'Everything above the waist starts here. Head control comes before sitting, and sitting before crawling.',
    steps: [
      'Lie back and put him tummy-down on your chest, face turned to one side.',
      'Talk, so he has a reason to lift his head towards you.',
      'A minute is a real session at this age.',
      'Repeat two or three times a day rather than once for longer.',
    ],
    seed: 23,
  ),
  DevActivity(
    id: 'g_open_fist',
    title: 'Open the little fist',
    areaId: 'fine_motor',
    minutes: 3,
    difficulty: 'Easy',
    ageTag: '0–3 mo',
    materials: ['Your finger'],
    skills: ['Grasp reflex', 'Touch', 'Hand awareness'],
    safety: ['Never pull his fingers open — only ever stroke'],
    benefit:
        'Newborn hands are fisted by reflex. Gentle stroking helps them open, and an open hand is the beginning of reaching.',
    steps: [
      'Stroke the back of his hand from wrist to knuckles.',
      'The fist usually opens on its own.',
      'Let him close around your finger and hold.',
      'Do the other hand.',
    ],
    seed: 24,
  ),
  DevActivity(
    id: 'g_calm_voice',
    title: 'The 3am voice',
    areaId: 'emotional',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '0–3 mo',
    materials: ['Nothing'],
    skills: ['Co-regulation', 'Trust', 'Soothing'],
    safety: ['If crying is unusual, inconsolable or feverish, call your doctor'],
    benefit:
        'A baby cannot calm himself yet — he borrows your calm. Being soothed thousands of times is how the ability to self-soothe is eventually built.',
    steps: [
      'Hold him close enough to hear your heartbeat.',
      'Lower your voice rather than raising it. Slow, low, repetitive.',
      'Sway or pat at about the speed of a resting heartbeat.',
      'If you are running out, hand him over. That is co-regulation too.',
    ],
    seed: 25,
  ),

  // ---- 3–6 months ---------------------------------------------------------
  DevActivity(
    id: 'g_musical_babble',
    title: 'Musical babble',
    areaId: 'language',
    minutes: 5,
    difficulty: 'Easy',
    ageTag: '3–6 mo',
    materials: ['Nothing at all'],
    skills: ['Turn-taking', 'Vocalising', 'Attention'],
    safety: ['None'],
    benefit:
        'He is learning that a conversation has turns long before he has words. Every pause you leave is a turn he gets to take.',
    steps: [
      'Say one short thing, warmly and slowly.',
      'Then stop. Wait longer than is comfortable — three or four seconds.',
      'Whatever sound he makes, answer it as though he said something.',
      'Repeat. Follow his sound rather than leading with yours.',
    ],
    seed: 26,
  ),
  DevActivity(
    id: 'g_mirror_faces',
    title: 'Mirror faces',
    areaId: 'social',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '3–6 mo',
    materials: ['A mirror, or the dark screen of a switched-off phone'],
    skills: ['Self-recognition', 'Expression', 'Social interest'],
    safety: ['Use a shatterproof mirror if he can reach it'],
    benefit:
        'He will not know the baby is him for many months yet. What he is learning first is that faces are interesting and that expressions mean something.',
    steps: [
      'Hold him so you are both in the mirror.',
      'Make one big expression — surprise works best.',
      'Name it: "Oh! Surprised."',
      'Wait, and let him look as long as he wants to.',
    ],
    seed: 27,
  ),
  DevActivity(
    id: 'g_kick_chime',
    title: 'Kick, and it sings',
    areaId: 'cognitive',
    minutes: 5,
    difficulty: 'Easy',
    ageTag: '3–6 mo',
    materials: ['A rattle or bell tied loosely where his feet can reach'],
    skills: ['Cause & effect', 'Leg strength', 'Attention'],
    safety: [
      'Nothing tied around his leg, and no loose string longer than a hand',
      'Only while you are watching',
    ],
    benefit:
        'The first realisation that "I did that" — the seed of agency, and it arrives through the feet before the hands.',
    steps: [
      'Lie him on his back with the rattle within kicking distance.',
      'Wait for an accidental kick.',
      'When it rings, react: "You did it!"',
      'Watch for the moment the kicking stops being accidental.',
    ],
    seed: 28,
  ),

  // ---- 6–9 months ---------------------------------------------------------
  DevActivity(
    id: 'g_treasure_basket',
    title: 'A basket of real things',
    areaId: 'creativity',
    minutes: 8,
    difficulty: 'Easy',
    ageTag: '6–9 mo',
    materials: [
      'A shallow basket',
      'Six safe household objects — a wooden spoon, a steel katori, a loofah, a large pinecone',
    ],
    skills: ['Exploration', 'Texture', 'Choice-making', 'Concentration'],
    safety: [
      'Nothing that passes through a toilet-roll tube — that is the choking gauge',
      'Nothing sharp, painted or breakable',
      'Sit with him the whole time',
    ],
    benefit:
        'Real objects have more to teach than most toys: weight, temperature, smell, sound. And the choosing is his, which is where concentration is built.',
    steps: [
      'Set the basket in front of him while he sits supported.',
      'Say nothing. Genuinely nothing.',
      'Let him pick, mouth, drop and pick again.',
      'Swap two objects next time to keep it fresh.',
    ],
    seed: 29,
  ),
  DevActivity(
    id: 'g_ball_drop',
    title: 'Ball drop',
    areaId: 'cognitive',
    minutes: 5,
    difficulty: 'Easy',
    ageTag: '6–9 mo',
    materials: ['A ball and a steel tumbler, or a cardboard tube'],
    skills: ['Cause & effect', 'Hand-eye coordination', 'Anticipation'],
    safety: ['Ball bigger than his mouth', 'No plastic bags or thin film'],
    benefit:
        'Drop, look, listen, repeat. It looks repetitive because it is: he is running the same experiment until the result is certain.',
    steps: [
      'Show him the ball going in and coming out the bottom.',
      'Do it twice, slowly.',
      'Hand him the ball.',
      'Let him repeat it far more times than seems interesting to you.',
    ],
    seed: 30,
  ),
  DevActivity(
    id: 'g_hold_spoon',
    title: 'Let him hold the spoon',
    areaId: 'selfcare',
    minutes: 10,
    difficulty: 'Medium',
    ageTag: '6–9 mo',
    materials: ['Two spoons', 'A mat under the chair, and low expectations'],
    skills: ['Self-feeding', 'Grip', 'Independence'],
    safety: [
      'Always seated upright, never reclined',
      'Stay within arm’s reach for the whole meal',
    ],
    benefit:
        'Feeding himself starts months before he can actually do it. Holding the spoon while you feed with the other one is the whole first step.',
    steps: [
      'Give him one spoon to hold. Keep the second for yourself.',
      'Feed with yours; let him wave, bang and mouth his.',
      'Expect almost nothing to reach his mouth.',
      'The mess is the lesson, not a failure of the lesson.',
    ],
    seed: 31,
  ),
  DevActivity(
    id: 'g_name_it',
    title: 'Name what he is already looking at',
    areaId: 'language',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '6–9 mo',
    materials: ['Nothing'],
    skills: ['Vocabulary', 'Joint attention'],
    safety: ['None'],
    benefit:
        'Words stick when they land on something he had already chosen to look at. Naming what YOU find interesting teaches far less.',
    steps: [
      'Watch where his eyes go.',
      'Name that thing, once, clearly. "Fan."',
      'Pause.',
      'Say it once more, then let it go. Do not turn it into a lesson.',
    ],
    seed: 32,
  ),

  // ---- 9–12 months --------------------------------------------------------
  DevActivity(
    id: 'g_sorting_cups',
    title: 'Sorting cups',
    areaId: 'cognitive',
    minutes: 8,
    difficulty: 'Easy',
    ageTag: '9–12 mo',
    materials: ['A set of nesting cups, or four steel katoris of different sizes'],
    skills: ['Size ordering', 'Problem solving', 'Fine motor', 'Persistence'],
    safety: ['Nothing with a chipped or sharp rim'],
    benefit:
        'Nesting is his first real experiment in size and order. Getting it wrong repeatedly is how the rule gets learned.',
    steps: [
      'Put them out unstacked.',
      'Let him try. Do not correct the order.',
      'If frustration builds, nest two for him and hand back the rest.',
      'Stacking upward comes months after nesting — both count.',
    ],
    seed: 33,
  ),
  DevActivity(
    id: 'g_cruise',
    title: 'Cruise the sofa',
    areaId: 'gross_motor',
    minutes: 6,
    difficulty: 'Medium',
    ageTag: '9–12 mo',
    materials: ['A low, steady sofa or bed'],
    skills: ['Standing', 'Side-stepping', 'Balance', 'Confidence'],
    safety: [
      'Clear the floor of hard toys first',
      'Check nothing he pulls on can tip — no light stools, no tablecloths',
      'Bare feet grip better than socks',
    ],
    benefit:
        'Side-stepping along furniture is where balance and leg strength are built. Walking is what happens after this, not instead of it.',
    steps: [
      'Stand him at one end, both hands on the sofa.',
      'Put something he wants a little way along it.',
      'Let him work out the route. Do not walk him there.',
      'Cheer the reaching, not the arriving.',
    ],
    seed: 34,
  ),
  DevActivity(
    id: 'g_pincer',
    title: 'Pincer practice',
    areaId: 'fine_motor',
    minutes: 6,
    difficulty: 'Medium',
    ageTag: '9–12 mo',
    materials: ['Soft cooked peas, or well-steamed carrot cubes'],
    skills: ['Pincer grip', 'Hand-eye coordination', 'Self-feeding'],
    safety: [
      'Everything soft enough to squash between two fingers',
      'Seated upright, watched the whole time',
      'Never in a moving car or pram',
    ],
    benefit:
        'Thumb-and-forefinger is the grip that later holds a pencil. Picking up single small soft foods is the best practice there is.',
    steps: [
      'Put five or six pieces on the tray. Not a pile.',
      'Let him work at them.',
      'Refill in small numbers rather than all at once.',
      'Stop when he starts sweeping them off — that is done, not naughty.',
    ],
    seed: 35,
  ),
  DevActivity(
    id: 'g_wave_bye',
    title: 'Wave, clap, bye-bye',
    areaId: 'social',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '9–12 mo',
    materials: ['Nothing'],
    skills: ['Imitation', 'Gesture', 'Social routine'],
    safety: ['None'],
    benefit:
        'Gestures come before words and predict them. A baby who waves and points is building the same system that speech will use.',
    steps: [
      'Wave every single time someone leaves. Every time.',
      'Say "bye-bye" as you do it.',
      'Take his hand and wave it once, then let go.',
      'Wait for the day he does it first.',
    ],
    seed: 36,
  ),
  DevActivity(
    id: 'g_open_cup',
    title: 'Sips from an open cup',
    areaId: 'selfcare',
    minutes: 5,
    difficulty: 'Medium',
    ageTag: '9–12 mo',
    materials: ['A small open cup', 'Water', 'A towel'],
    skills: ['Drinking', 'Mouth control', 'Independence'],
    safety: ['Small sips only', 'Always seated and upright'],
    benefit:
        'An open cup uses the mouth differently from a bottle or spout, and that same control is used for speech sounds later.',
    steps: [
      'Fill 2 cm of water — no more.',
      'Hold the cup to his lips and tip very slightly.',
      'Let him put his hands on it.',
      'Expect spills for weeks. That is the normal path, not a setback.',
    ],
    seed: 37,
  ),

  // ---- 12–18 months -------------------------------------------------------
  DevActivity(
    id: 'g_stack_crash',
    title: 'Stack it, crash it',
    areaId: 'cognitive',
    minutes: 8,
    difficulty: 'Easy',
    ageTag: '12–18 mo',
    materials: ['Four or five blocks, or stacking cups'],
    skills: ['Planning', 'Balance', 'Cause & effect', 'Persistence'],
    safety: ['Blocks light enough not to hurt when they land on a foot'],
    benefit:
        'Knocking it down is not the failure of the activity — it is the most interesting part, because it is the part he causes.',
    steps: [
      'Build a tower of three while he watches.',
      'Let him knock it over. React with delight.',
      'Rebuild. Then offer him a block to place.',
      'Two of his own blocks stacked is a genuine milestone.',
    ],
    seed: 38,
  ),
  DevActivity(
    id: 'g_point_book',
    title: 'Point-and-name a book',
    areaId: 'language',
    minutes: 6,
    difficulty: 'Easy',
    ageTag: '12–18 mo',
    materials: ['Any picture book with big, single objects'],
    skills: ['Vocabulary', 'Pointing', 'Joint attention'],
    safety: ['Board books at this age — paper pages get eaten'],
    benefit:
        'Asking "where is the dog?" and waiting is worth more than reading the words. Pointing on request is a real language milestone.',
    steps: [
      'Forget the story. Open at any page.',
      'Ask "where is the ___?" and wait.',
      'If nothing happens, point yourself and name it.',
      'Let him turn the pages, even out of order.',
    ],
    seed: 39,
  ),
  DevActivity(
    id: 'g_push_walk',
    title: 'Push something heavy',
    areaId: 'gross_motor',
    minutes: 8,
    difficulty: 'Medium',
    ageTag: '12–18 mo',
    materials: ['A sturdy chair, or a laundry basket with a couple of books in it'],
    skills: ['Walking', 'Balance', 'Leg strength'],
    safety: [
      'Only on a non-slip floor',
      'Never near stairs',
      'Weighted enough not to shoot away from him',
    ],
    benefit:
        'Pushing gives him something to lean into, so his legs work while his balance catches up. Better than a baby walker, and free.',
    steps: [
      'Set the basket in a clear stretch of floor.',
      'Show him one push.',
      'Stay behind and to the side rather than holding on.',
      'Let him fall onto his bottom. That is how balance is calibrated.',
    ],
    seed: 40,
  ),
  DevActivity(
    id: 'g_first_scribble',
    title: 'The first scribble',
    areaId: 'creativity',
    minutes: 6,
    difficulty: 'Easy',
    ageTag: '12–18 mo',
    materials: ['Chunky non-toxic crayons', 'A big sheet of paper'],
    skills: ['Mark-making', 'Grip', 'Creative expression'],
    safety: ['Non-toxic only', 'Sit with him — crayons get tasted'],
    benefit:
        'A scribble is not a failed drawing. It is the discovery that his hand can leave a mark on the world, which is the whole idea behind writing.',
    steps: [
      'Tape the paper down so it cannot slide.',
      'Make one mark yourself, then hand over the crayon.',
      'Say nothing about what it looks like.',
      'Keep the first one.',
    ],
    seed: 41,
  ),
  DevActivity(
    id: 'g_shoes_off',
    title: 'Shoes off, by himself',
    areaId: 'selfcare',
    minutes: 5,
    difficulty: 'Easy',
    ageTag: '12–18 mo',
    materials: ['His own shoes and socks'],
    skills: ['Dressing', 'Independence', 'Sequencing'],
    safety: ['None'],
    benefit:
        'Taking off comes long before putting on. Starting with the easy half is what makes the hard half feel possible later.',
    steps: [
      'Loosen the straps so it is genuinely doable.',
      'Say "your turn" and wait.',
      'Help only with the part that has actually stalled.',
      'Let it take four minutes.',
    ],
    seed: 42,
  ),

  // ---- 18–24 months -------------------------------------------------------
  DevActivity(
    id: 'g_pretend_tea',
    title: 'Pretend chai',
    areaId: 'creativity',
    minutes: 8,
    difficulty: 'Easy',
    ageTag: '18–24 mo',
    materials: ['A cup and a spoon. Nothing in them'],
    skills: ['Pretend play', 'Imagination', 'Social routine'],
    safety: ['Nothing hot, obviously — and say so, so the pretend stays pretend'],
    benefit:
        'Pretending an empty cup is full is abstract thinking arriving. The child who can do this is holding two ideas at once.',
    steps: [
      'Pour nothing into the cup with great seriousness.',
      'Sip. Say "aah, garam".',
      'Offer him a cup.',
      'Follow whatever he invents next, even if it makes no sense.',
    ],
    seed: 43,
  ),
  DevActivity(
    id: 'g_two_words',
    title: 'Add one word to his',
    areaId: 'language',
    minutes: 5,
    difficulty: 'Easy',
    ageTag: '18–24 mo',
    materials: ['Nothing'],
    skills: ['Sentence building', 'Vocabulary', 'Grammar'],
    safety: ['None'],
    benefit:
        'When he says one word, saying it back with one more added is the single best-evidenced way to grow sentences. Not correcting — extending.',
    steps: [
      'He says "car".',
      'You say "red car" or "car going".',
      'Do not ask him to repeat it.',
      'Do this ten times a day and it compounds.',
    ],
    seed: 44,
  ),
  DevActivity(
    id: 'g_name_feeling',
    title: 'Name the big feeling',
    areaId: 'emotional',
    minutes: 5,
    difficulty: 'Medium',
    ageTag: '18–24 mo',
    materials: ['Nothing'],
    skills: ['Emotional vocabulary', 'Regulation', 'Feeling understood'],
    safety: ['If a tantrum turns into breath-holding or fainting, see a doctor'],
    benefit:
        'Putting a word to a feeling makes it smaller. He cannot do that for himself yet, so you do it for him — thousands of times.',
    steps: [
      'Get down to his level first.',
      'Name it plainly: "You are angry. The tower fell."',
      'Do not explain, fix or reason yet. Wait for the peak to pass.',
      'Once he is calm, then talk about what to do next time.',
    ],
    seed: 45,
  ),
  DevActivity(
    id: 'g_climb_safe',
    title: 'A safe thing to climb',
    areaId: 'gross_motor',
    minutes: 10,
    difficulty: 'Medium',
    ageTag: '18–24 mo',
    materials: ['Sofa cushions on the floor, or a low step'],
    skills: ['Climbing', 'Balance', 'Risk judgement', 'Confidence'],
    safety: [
      'Soft landing on every side',
      'Stay close enough to catch, far enough not to hover',
      'Never leave him climbing alone',
    ],
    benefit:
        'A toddler who is never allowed to climb still climbs — just somewhere you have not made safe. Giving him a sanctioned one is the safer choice.',
    steps: [
      'Build a low, wide pile of cushions.',
      'Let him find his own way up.',
      'Say "you are nearly at the top" rather than "be careful".',
      'Show him how to come down backwards.',
    ],
    seed: 46,
  ),

  // ---- 2–3 years ----------------------------------------------------------
  DevActivity(
    id: 'g_sort_colour',
    title: 'Sort the socks',
    areaId: 'cognitive',
    minutes: 10,
    difficulty: 'Easy',
    ageTag: '2–3 yr',
    materials: ['A pile of clean socks, or blocks in two colours'],
    skills: ['Sorting', 'Matching', 'Categories', 'Attention'],
    safety: ['None'],
    benefit:
        'Sorting is the first form of categorising, and categorising is what most later thinking is built on. Real laundry works better than a toy.',
    steps: [
      'Start with just two clearly different colours.',
      'Make two piles and put one sock in each.',
      'Hand him the rest.',
      'Add a third colour only once two is easy.',
    ],
    seed: 47,
  ),
  DevActivity(
    id: 'g_turn_taking',
    title: 'My turn, your turn',
    areaId: 'social',
    minutes: 8,
    difficulty: 'Medium',
    ageTag: '2–3 yr',
    materials: ['One ball, or any single toy'],
    skills: ['Turn-taking', 'Waiting', 'Sharing'],
    safety: ['None'],
    benefit:
        'Sharing is genuinely hard at two — the brain part that manages waiting is years from finished. Practising with you first is how it becomes possible with other children.',
    steps: [
      'Say "my turn" out loud, take a short one, hand it back.',
      'Say "your turn" and let his be longer.',
      'Keep your turns brief at first.',
      'Praise the handing over, not the waiting.',
    ],
    seed: 48,
  ),
  DevActivity(
    id: 'g_playdough',
    title: 'Squeeze, roll, poke',
    areaId: 'fine_motor',
    minutes: 12,
    difficulty: 'Easy',
    ageTag: '2–3 yr',
    materials: ['Atta dough, or shop playdough'],
    skills: ['Hand strength', 'Fine motor', 'Focus'],
    safety: ['Sit with him', 'Home dough is salty — discourage tasting'],
    benefit:
        'Hand strength is the quiet prerequisite for holding a pencil. Squeezing dough builds it far better than tracing letters does.',
    steps: [
      'Give him a fist-sized lump and no instructions.',
      'If he stalls, roll a snake and leave it there.',
      'Add a fork or a bottle cap for texture.',
      'No shapes to copy, no result required.',
    ],
    seed: 49,
  ),
  DevActivity(
    id: 'g_dress_self',
    title: 'One thing he puts on himself',
    areaId: 'selfcare',
    minutes: 8,
    difficulty: 'Medium',
    ageTag: '2–3 yr',
    materials: ['Loose clothes, a size too big'],
    skills: ['Dressing', 'Sequencing', 'Independence', 'Patience'],
    safety: ['Nothing with a drawstring near the neck'],
    benefit:
        'Doing the last step himself — pulling the shirt down after you have got it over his head — is the way in. Backward chaining, and it works.',
    steps: [
      'Do all of it except the final pull.',
      'Say "you finish".',
      'Next week, leave him two steps. Then three.',
      'Build in ten extra minutes rather than taking over.',
    ],
    seed: 50,
  ),

  // ---- 3–4 years ----------------------------------------------------------
  DevActivity(
    id: 'g_invent_story',
    title: 'Tell it wrong on purpose',
    areaId: 'creativity',
    minutes: 8,
    difficulty: 'Easy',
    ageTag: '3–4 yr',
    materials: ['A story he knows well'],
    skills: ['Imagination', 'Memory', 'Humour', 'Language'],
    safety: ['None'],
    benefit:
        'Correcting you proves he holds the whole story in his head — and inventing the next wrong version is where his own storytelling starts.',
    steps: [
      'Start a familiar story and get a detail obviously wrong.',
      'Let him correct you. Act amazed.',
      'Then ask "what should happen instead?"',
      'Follow his version wherever it goes.',
    ],
    seed: 51,
  ),
  DevActivity(
    id: 'g_balance_line',
    title: 'Walk the line',
    areaId: 'gross_motor',
    minutes: 8,
    difficulty: 'Medium',
    ageTag: '3–4 yr',
    materials: ['A chalk line, a rope on the floor, or a row of floor tiles'],
    skills: ['Balance', 'Coordination', 'Body awareness'],
    safety: ['Flat, clear floor', 'Bare feet'],
    benefit:
        'Balance is a skill the body practises, not one it grows into. Two minutes of this beats an hour of being told to sit still.',
    steps: [
      'Lay a straight line and walk it yourself first.',
      'Let him try — arms out is allowed and helps.',
      'Then backwards. Then heel-to-toe.',
      'Add a book on the head only if he is enjoying it.',
    ],
    seed: 52,
  ),
  DevActivity(
    id: 'g_feelings_faces',
    title: 'Which face is this?',
    areaId: 'emotional',
    minutes: 6,
    difficulty: 'Easy',
    ageTag: '3–4 yr',
    materials: ['Your face, or pictures in any book'],
    skills: ['Empathy', 'Emotional vocabulary', 'Reading expressions'],
    safety: ['None'],
    benefit:
        'Naming other people’s feelings is where empathy begins. It is also the skill that makes his own feelings less frightening.',
    steps: [
      'Make one clear face and ask "how am I feeling?"',
      'Whatever he says, take it seriously.',
      'Ask "when do you feel like that?"',
      'Let him make one for you to guess.',
    ],
    seed: 53,
  ),
  DevActivity(
    id: 'g_count_real',
    title: 'Count something real',
    areaId: 'cognitive',
    minutes: 6,
    difficulty: 'Easy',
    ageTag: '3–4 yr',
    materials: ['Stairs, rotis, or anything there are a few of'],
    skills: ['Counting', 'Number sense', 'One-to-one matching'],
    safety: ['Hold the rail on stairs'],
    benefit:
        'Reciting "one two three" is memory. Touching each thing once as he says the number is actual counting, and they are not the same skill.',
    steps: [
      'Count as you climb, one number per step.',
      'Touch each item as it is counted.',
      'Stop at five before going higher.',
      'Ask "how many?" at the end — repeating the last number is the real leap.',
    ],
    seed: 54,
  ),

  // ---- 4–5 years ----------------------------------------------------------
  DevActivity(
    id: 'g_rhyme_time',
    title: 'Words that sound the same',
    areaId: 'language',
    minutes: 6,
    difficulty: 'Medium',
    ageTag: '4–5 yr',
    materials: ['Nothing'],
    skills: ['Rhyme', 'Sound awareness', 'Pre-reading'],
    safety: ['None'],
    benefit:
        'Hearing that "cat" and "hat" end the same is the single best predictor of easy reading later. Nonsense words count fully.',
    steps: [
      'Say two rhyming words and one that does not. Ask which is the odd one.',
      'Then ask him for a word that rhymes with "cat".',
      'Accept made-up words with enthusiasm.',
      'Do it in the car, not at a table.',
    ],
    seed: 55,
  ),
  DevActivity(
    id: 'g_scissors',
    title: 'First cuts',
    areaId: 'fine_motor',
    minutes: 10,
    difficulty: 'Medium',
    ageTag: '4–5 yr',
    materials: ['Child-safe scissors', 'Old newspaper, or a magazine'],
    skills: ['Scissor grip', 'Hand strength', 'Focus', 'Hand-eye coordination'],
    safety: [
      'Blunt-tipped child scissors only',
      'Sitting down, never walking with them',
      'Put them away out of reach afterwards',
    ],
    benefit:
        'Opening and closing scissors uses exactly the muscles a pencil needs. Snipping strips is a better start than cutting along a line.',
    steps: [
      'Cut a page into long thin strips first — one snip each.',
      'Then let him snip the strips into confetti.',
      'Lines to follow come much later.',
      'Ten minutes is a long session.',
    ],
    seed: 56,
  ),
  DevActivity(
    id: 'g_real_job',
    title: 'A job that actually matters',
    areaId: 'selfcare',
    minutes: 10,
    difficulty: 'Medium',
    ageTag: '4–5 yr',
    materials: ['Whatever the household is already doing'],
    skills: ['Responsibility', 'Sequencing', 'Belonging', 'Confidence'],
    safety: ['Nothing hot, sharp or electrical'],
    benefit:
        'A pretend job teaches less than a real one. Being genuinely needed by the family is where a child’s sense of capability comes from.',
    steps: [
      'Pick something real — laying out plates, watering a plant, sorting spoons.',
      'Give him the whole job, not a token part of it.',
      'Let it be done imperfectly and leave it that way.',
      'Make it his, every day, not a one-off.',
    ],
    seed: 57,
  ),
  DevActivity(
    id: 'g_calm_corner',
    title: 'Build a calm-down corner',
    areaId: 'emotional',
    minutes: 12,
    difficulty: 'Medium',
    ageTag: '4–5 yr',
    materials: ['A cushion, a soft toy, a book — in one chosen spot'],
    skills: ['Self-regulation', 'Recognising feelings', 'Independence'],
    safety: ['Never used as a punishment or a time-out — that breaks it entirely'],
    benefit:
        'A place to go when feelings get big is a tool he can eventually use without you. It only works if he chooses it, which is why it must never be where he gets sent.',
    steps: [
      'Build it together, on a calm day. Let him choose the spot.',
      'Use it yourself once, out loud: "I am cross, I am going to sit here."',
      'Offer it, never order it.',
      'Go with him the first several times.',
    ],
    seed: 58,
  ),
  DevActivity(
    id: 'g_make_a_plan',
    title: 'Say the plan before doing it',
    areaId: 'cognitive',
    minutes: 8,
    difficulty: 'Medium',
    ageTag: '4–5 yr',
    materials: ['Blocks, or any build-it toy'],
    skills: ['Planning', 'Executive function', 'Working memory', 'Language'],
    safety: ['None'],
    benefit:
        'Saying what he is going to do before he does it is executive function in training — the skill that later becomes homework, and patience.',
    steps: [
      'Before he starts, ask "what are you going to build?"',
      'Let him say it out loud, however vague.',
      'Do not hold him to it if he changes course.',
      'At the end ask "did it work how you thought?"',
    ],
    seed: 59,
  ),
];
