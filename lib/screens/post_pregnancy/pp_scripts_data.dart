// =============================================================================
//  "What to say when…" — the script library
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE ONE TOOL IN THE BEHAVIOUR SECTION THAT NOTHING ELSE OFFERS,
//  and the build prompt names it as the differentiator. It is also the only
//  part of the section a parent uses WHILE the thing is happening, which
//  changes every design decision in it.
//
//  A parent standing in a supermarket with a screaming toddler cannot read an
//  article about co-regulation. She needs the sentence. So each entry leads
//  with the exact words, and the reasoning sits underneath for later.
//
//  ⚠️ "NOT THIS" IS AS IMPORTANT AS "SAY THIS", AND IT IS THE HARDER HALF TO
//  GET RIGHT. Every not-this line here is something ordinary, loving parents
//  say — "you're fine", "don't cry", "say sorry" — not a strawman. A library
//  that only lists things a bad parent would say teaches nothing, because
//  nobody recognises themselves in it. The point is never that the parent was
//  wrong; it is that a different sentence works better.
//
//  ⚠️ NO SHAMING, ANYWHERE. The `why` explains what the child hears, not what
//  the parent did. A tool that makes a parent feel worse at the exact moment
//  she reached for help is worse than no tool.
//
//  ⚠️ INDIA IS IN THE SITUATIONS, NOT IN A NOTE AT THE BOTTOM. Hitting a
//  grandparent, being watched at a family function, the forced "sorry bolo" —
//  these are the moments Indian parents actually ask about, and a library
//  built from Western examples would be missing its most-used pages.
//
//  English only for now, plain `String`, per the standing instruction.
// =============================================================================

/// One situation, and what to say in it.
class PpScript {
  const PpScript({
    required this.id,
    required this.situation,
    required this.bands,
    required this.sayThis,
    required this.notThis,
    required this.principle,
    this.pageId,
    this.words = const [],
    this.safety,
  });

  /// Stable slug: routing (`pp_scripts/<id>`), never derived from the title.
  /// (Was "routing and saved items"; nothing saves a script.)
  final String id;

  /// The words a parent types that are in no line of the script (tools pass
  /// 29). The Tools row sold "tantrums", and a search for "tantrum" or
  /// "bedtime" found nothing, because those words were only in page ids and
  /// comments. Search reads these too; they are never shown.
  final List<String> words;

  /// A safety line shown on the script itself, above the words (BH2: no honey
  /// before one). REQUIRED_REVIEW wherever it is set.
  final String? safety;

  /// Phrased as the moment, not as the behaviour: "He won't leave the park",
  /// not "Transitions". A parent searches for what is happening to her.
  final String situation;

  /// Which age bands this fits. Empty means all of them.
  final List<String> bands;

  /// The words. First one is the one to reach for.
  final List<String> sayThis;

  /// What to leave unsaid, and each is something ordinary parents do say.
  final List<String> notThis;

  /// One or two sentences on what the child hears. Never on what the parent
  /// did wrong.
  final String principle;

  /// The article this belongs to, so the tool is a door into the section
  /// rather than a dead end.
  final String? pageId;
}

const List<PpScript> kPpScripts = [
  // ------------------------------------------- the family, under one -----
  // ⚠️ FOR ANSWERING THE FAMILY, NOT THE BABY (Behaviour BH2, built in the
  // tools pass, 2026-10-26). The baby tab promised lines for "you are spoiling
  // him" and "let him cry", and a baby's parent found one script, about
  // throwing food. Copy: docs/pp-door-plans/08-behaviour-content.md §1.
  PpScript(
    id: 'family_spoiling',
    situation: '"You\'re spoiling him, putting him down is better"',
    bands: ['infant'],
    sayThis: [
      "He's too little to be spoiled. Babies who get picked up when they cry "
          "end up crying less, not more. I'd rather he learns that someone comes.",
    ],
    notThis: ['You did it wrong with your children.'],
    principle: 'That line turns a care question into a fight about the past. '
        'One calm sentence about the baby keeps it about the baby.',
    pageId: 'cant_spoil',
    words: ['spoil', 'spoiling', 'family', 'mother-in-law', 'saas', 'dadi', 'nani', 'pick up', 'crying'],
  ),
  // REQUIRED_REVIEW (child psychologist): the lungs line.
  PpScript(
    id: 'family_let_cry',
    situation: '"Let him cry, it\'s good for his lungs"',
    bands: ['infant'],
    sayThis: [
      "Crying doesn't make his lungs stronger. It just tires him out. I'll try "
          "to calm him, and if he keeps going, we'll try the next thing together.",
    ],
    notThis: ['(a lecture)'],
    principle: 'One line and a calm pick-up says more than an argument, and it '
        'invites the family in rather than shutting them out.',
    pageId: 'crying_normal',
    words: ['cry', 'crying', 'lungs', 'family', 'let him cry'],
  ),
  // REQUIRED_REVIEW (paediatrician, lactation): crying and hunger.
  PpScript(
    id: 'family_milk',
    situation: '"Your milk isn\'t enough, that\'s why he cries"',
    bands: ['infant'],
    sayThis: [
      "Crying isn't a sign of hunger on its own. The doctor checks his weight, "
          "and that tells us if he's getting enough. I'll ask at his next visit.",
    ],
    notThis: ['(anything about how you feed him)'],
    principle: 'The worry is real, and the weight check answers it. She does '
        'not have to defend how she feeds to anyone.',
    pageId: 'bf_how_often',
    words: ['milk', 'enough', 'hungry', 'feeding', 'breastfeeding', 'family', 'crying'],
  ),
  // REQUIRED_REVIEW (paediatrician): no honey before one, janam ghutti.
  PpScript(
    id: 'family_honey',
    situation: '"Give him a little honey, or gripe water"',
    bands: ['infant'],
    safety: 'No honey, in any amount, before 1 year. This includes janam '
        'ghutti made with honey.',
    sayThis: [
      "Not honey before his first birthday. The doctor says it can make babies "
          "very ill. For the crying, I'd rather ask the doctor before giving him anything.",
    ],
    notThis: ['That the old ways are wrong.'],
    principle: 'Say what the doctor says, then stop. It keeps the elders on '
        'your side and the baby safe.',
    pageId: 'crying_doctor',
    words: ['honey', 'gripe water', 'janam ghutti', 'ghutti', 'colic', 'family', 'crying'],
  ),

  // ---------------------------------------------------------- hitting -----
  PpScript(
    id: 'hit_friend',
    situation: 'He hit another child', // was 'She hit another child'; ppFillChild makes it hers (tools pass 29)
    bands: ['toddler_1', 'toddler_2'],
    sayThis: [
      'I will not let you hit. Hitting hurts.',
      'You were angry. Tell me with your words, or come and find me.',
      'Look at her face. She is sad. What could we do to help?',
    ],
    notThis: [
      'Say sorry. Say it NOW.',
      'Why did you do that? (a two-year-old does not know)',
      'Bad girl.',
    ],
    principle:
        'Stop the hand first, name the feeling second. A forced sorry teaches '
        'that the word ends the trouble, not that the other child hurts — and '
        '"why did you do that" is a question she genuinely cannot answer yet.',
    pageId: 'hitting_biting',
  ),
  PpScript(
    id: 'hit_grandparent',
    situation: 'He hit his dadi, in front of everyone',
    bands: ['toddler_1', 'toddler_2'],
    sayThis: [
      'I will not let you hit. Come with me a minute.',
      '(to the room, calmly) He is two. We are working on it.',
      '(later, to him) Hands are for holding. Dadi wants to play with you.',
    ],
    notThis: [
      'Look what you did! Everyone is watching!',
      'Sorry bolo. Abhi bolo.',
      'Do you want everyone to think you are a bad boy?',
    ],
    principle:
        'The audience is the hard part, not the hitting. Handling it quietly '
        'in front of family looks like doing nothing and is the thing that '
        'actually works — shame in front of a room teaches him to hide, not to '
        'stop.',
    pageId: 'hitting_biting',
  ),
  PpScript(
    id: 'bit_baby',
    situation: 'He bit the new baby',
    bands: ['toddler_1', 'toddler_2'],
    sayThis: [
      'I will not let you bite. Teeth are for food.',
      'It is hard when the baby needs me so much.',
      'Come, sit with me. You can help me hold her, or you can sit close.',
    ],
    notThis: [
      'You are supposed to be the big brother!',
      'Do you want me to bite you and see how it feels?',
      'I cannot trust you with her.',
    ],
    principle:
        'Biting a new sibling is almost always about you, not about her. The '
        'limit still has to be absolute, and the sentence after it has to be '
        'about him — otherwise the only reliable way to get your attention '
        'stays biting.',
    pageId: 'hitting_biting',
  ),

  // -------------------------------------------------------- transitions ---
  PpScript(
    id: 'leave_park',
    situation: 'He will not leave the park',
    bands: ['toddler_1', 'toddler_2', 'preschool'],
    sayThis: [
      'Two more slides, then shoes. You choose which two.',
      'It is hard to stop when you are having fun.',
      'Do you want to walk to the gate, or shall I carry you like a bag of rice?',
    ],
    notThis: [
      'Right, we are going NOW.',
      'Fine, stay here. I am leaving.',
      'If you do not come I will never bring you again.',
    ],
    principle:
        'The meltdown is the ambush, not the leaving. A warning plus a choice '
        'inside the boundary gives him somewhere to put his will, and walking '
        'away as a threat frightens him without teaching anything.',
    // pageId: null, // no transitions page yet; see D7 (kept for revert)
    pageId: 'beh_tantrum_steps', // the closest page (BH2, tools pass 29)
    words: ['leaving', 'transition', 'tantrum', 'meltdown', 'time to go'],
  ),
  PpScript(
    id: 'screen_off',
    situation: 'Screaming for the phone when it goes off',
    bands: ['toddler_1', 'toddler_2', 'preschool'],
    sayThis: [
      'When the timer beeps, the phone goes to sleep. Then we have our snack.',
      'You really want more. I know. It is finished for now.',
      'You can be cross about it. I will sit here with you.',
    ],
    notThis: [
      '(snatching it) Enough!',
      'Okay okay, five more minutes. (after the fifth five minutes)',
      'You are addicted to this thing.',
    ],
    principle:
        'What he is protesting is the sudden cut, not the screen. A timer he '
        'can hear and a next thing to move to do most of the work — and giving '
        'in after saying no teaches that shouting is what changes an answer.',
    // Repointed when screen time became its own door. The old `screens` page
    // was retired into `kBehScreens`.
    pageId: 'beh_screen_ending',
    words: ['tantrum', 'screen', 'tv', 'mobile', 'tablet'],
  ),
  PpScript(
    id: 'shoes',
    situation: 'He will not put his shoes on', // was 'She will not put her shoes on'
    bands: ['toddler_1', 'toddler_2'],
    sayThis: [
      'Red shoes or blue shoes?',
      'You can put them on, or I can help you. You choose.',
      'Shoes first, then we open the door.',
    ],
    notThis: [
      'We are already late. Just put them on!',
      'Why do you do this every single day?',
      '(doing it for her while she screams)',
    ],
    principle:
        'At this age refusing is not defiance, it is practising having a say. '
        'Two options you are equally happy with give her the say without giving '
        'you a problem, and both of them end with shoes on.',
    pageId: 'beh_choices',
  ),

  // ------------------------------------------------------------ meltdowns -
  PpScript(
    id: 'supermarket',
    situation: 'A full meltdown in a shop, with people watching',
    bands: ['toddler_1', 'toddler_2'],
    sayThis: [
      '(quietly, down at her level) I am here. We will wait together.',
      'You are so upset. It is alright to be upset.',
      '(afterwards) That was hard. Shall we finish the shopping together?',
    ],
    notThis: [
      'Stop it. People are looking.',
      'Fine, take the chocolate. Just stop.',
      'You are embarrassing me.',
    ],
    principle:
        'Mid-storm she cannot hear reasoning, so there is nothing to explain '
        'yet — presence is the whole intervention. Giving in to end it works '
        'once and costs you every future shop.',
    pageId: 'first_tantrums',
    words: ['tantrum', 'meltdown', 'shop', 'supermarket', 'public', 'crying'],
  ),
  PpScript(
    id: 'i_hate_you',
    situation: 'He said "I hate you"', // was 'She said ...'
    bands: ['toddler_2', 'preschool'],
    sayThis: [
      'You are really angry with me. I can hear that.',
      'I still love you, even when you are this cross.',
      '(later) You said you hate me. What was going on for you then?',
    ],
    notThis: [
      'That is a horrible thing to say.',
      'After everything I do for you.',
      'Fine. Then I do not want to talk to you either.',
    ],
    principle:
        'She has a feeling far bigger than her vocabulary, and "hate" is the '
        'strongest word she owns. Answering the feeling rather than the word '
        'is what stops it becoming the sentence she reaches for every time.',
    pageId: 'beh_big_feelings',
    words: ['anger', 'angry', 'feelings', 'rude'],
  ),

  // ------------------------------------------------------------ mealtimes -
  PpScript(
    id: 'throwing_food',
    situation: 'He is throwing food off the tray',
    bands: ['infant', 'toddler_1'],
    sayThis: [
      'Food stays on the tray. If you are finished, say all done.',
      'You want to see it fall. Here — throw this ball instead.',
      '(calmly lifting him down) Looks like you are finished.',
    ],
    notThis: [
      'Stop it! (which is the reaction he is testing for)',
      'No dinner for you then.',
      '(laughing the first three times, then getting cross)',
    ],
    principle:
        'Early on this is cause and effect, not rudeness — he is finding out '
        'whether it falls every time, and whether you react every time. Ending '
        'the meal calmly answers both questions honestly.',
    // ⚠️ NOW HAS A HOME. This was null because no page covered food
    // throwing; `beh_throwing` was written in the same pass that finished the
    // behaviour build.
    pageId: 'beh_throwing',
  ),
  PpScript(
    id: 'refuses_food',
    situation: 'He refuses to eat what everyone else is eating', // was 'She refuses ...'
    bands: ['toddler_1', 'toddler_2', 'preschool'],
    sayThis: [
      'This is what there is tonight. You can eat it or leave it.',
      'You do not have to like it. It can just sit on your plate.',
      '(no comment at all when she does eat it)',
    ],
    notThis: [
      'Two more bites and then you can go.',
      'Do you know how many children have nothing to eat?',
      '(making a separate dish, every night)',
    ],
    principle:
        'Appetite is one of the very few things she fully controls, so a fight '
        'about food is a fight she can always win. Deciding WHAT is offered and '
        'leaving WHETHER to her ends the fight without ending the meal.',
    // pageId: null, // no mealtime-behaviour page yet; see D7 (kept for revert)
    pageId: 'picky_battles', // Feeding's "Mealtime battles" (BH2, tools pass 29)
    words: ['picky', 'fussy', 'eating', 'meal', 'dinner', 'lunch'],
  ),

  // ---------------------------------------------------------- sharing -----
  PpScript(
    id: 'wont_share',
    situation: 'He will not share at a playdate', // was 'She will not share ...'
    bands: ['toddler_1', 'toddler_2'],
    sayThis: [
      'She is using it right now. You can have a turn when she is finished.',
      'Shall we set a timer for the turns?',
      '(to the other parent) They are two. We are doing turns rather than '
      'sharing.',
    ],
    notThis: [
      'Do not be selfish. Give it to her.',
      'Sharing is caring!',
      '(taking it out of her hands to hand over)',
    ],
    principle:
        'Sharing on demand is genuinely beyond most children before about '
        'three — turn-taking is the version they can actually do. Forcing it '
        'teaches that a bigger person can take your things, which is the '
        'opposite of the lesson.',
    pageId: 'sharing',
  ),

  // -------------------------------------------------------------- bedtime -
  PpScript(
    id: 'wont_stay_in_bed',
    situation: 'He keeps getting out of bed',
    bands: ['toddler_2', 'preschool'],
    sayThis: [
      'It is sleep time. I will walk you back.',
      'One more hug, then back to bed. (and mean it)',
      'I am just outside. You are safe.',
    ],
    notThis: [
      'If you get up one more time, I am shutting the door.',
      '(a long negotiation each time)',
      'Why can you never just sleep?',
    ],
    principle:
        'The fewer words the better here — every extra sentence is a reason to '
        'get up again. Boring, calm and identical fifteen times beats one '
        'stern conversation, and threats about the door add fear to a room he '
        'has to sleep in.',
    // pageId: null, // bedtime limits live in Sleep; see D7 (kept for revert)
    pageId: 'bedtime_routine', // Sleep's "A calming bedtime routine" (BH2, tools pass 29)
    words: ['bedtime', 'bed', 'sleep', 'night', 'getting up'],
  ),
];

/// Scripts that fit a band; empty band means everything.
List<PpScript> ppScriptsForBand(String band) =>
    [for (final s in kPpScripts) if (s.bands.isEmpty || s.bands.contains(band)) s];

/// ⚠️ SEARCHES THE SITUATION AND THE LINES, NOT JUST THE TITLE. A parent types
/// what is happening ("biting", "park", "phone"), and the word she uses is
/// often in the script rather than in the heading.
List<PpScript> ppScriptSearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return kPpScripts;
  return [
    for (final s in kPpScripts)
      if (s.situation.toLowerCase().contains(q) ||
          s.words.any((w) => w.contains(q) || q.contains(w)) ||
          s.principle.toLowerCase().contains(q) ||
          s.sayThis.any((l) => l.toLowerCase().contains(q)) ||
          s.notThis.any((l) => l.toLowerCase().contains(q)))
        s,
  ];
}
