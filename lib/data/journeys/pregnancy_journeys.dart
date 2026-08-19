// =============================================================================
//  Pregnancy journeys — what happens inside a door
// -----------------------------------------------------------------------------
//  See `journey_config.dart` for the rules. The two that matter most:
//
//    · every step heading is HER question, never our category;
//    · there is NO template — these come out different lengths on purpose, and
//      if two journeys look the same, one of them is wrong.
//
//  ⚠️ A DOOR ONLY GETS A JOURNEY WHEN ITS DESTINATION DOES NOT FINISH THE JOB.
//  "Can I eat, take or do this?" opens a complete checker and needs nothing
//  wrapped around it; putting a journey in front of a good screen is the same
//  tax as a hub screen in front of a single door.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import '../../localization/app_language.dart';
import '../../screens/brackets/hub/hub_solution_cards.dart';
import '../../screens/brackets/hub/journey_config.dart';
import '../hubs/pregnancy_hubs.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  Understand my condition — FIVE steps, and it ends at her doctor
// -----------------------------------------------------------------------------
//  Persona: she was handed a word at an appointment — gestational diabetes,
//  low-lying placenta, raised BP — and is looking it up in the car park. She is
//  frightened, and the first thing she needs is not information, it is scale:
//  is this common, and is my baby in danger right now.
//
//  ⚠️ SO STEP ONE IS "HOW WORRIED SHOULD I BE", NOT "WHAT IS IT". Leading with
//  a definition answers the question she would ask second.
//
//  ⚠️ ENDS AT A PERSON, DELIBERATELY. A condition journey that closes with an
//  article has told her about her diagnosis and left her alone with it.
//
//  ⚠️ SUPERSEDED BY `ConditionsHomeScreen` / `ConditionDetailScreen` —
//  `lib/screens/conditions/`, built 2026-08-17. That build is a real,
//  searchable library of 27 named conditions, each with its own page (what
//  it is, how common in India, symptoms, when to call vs monitor, tests,
//  management, baby impact, FAQ) — everything this five-step generic journey
//  was standing in for with `owed: true` placeholders.
//
//  This config is kept, not deleted, per "comment out, never delete" — and
//  because `_hubAction` in `home_v3_screen.dart` currently finds it FIRST:
//  `journeyFor(kPgActConditionLibrary)` returns this journey and pushes it,
//  which is why the switch-case below it (`_openSurfaceScreen(context,
//  'tests_scans')`) never actually runs today. **The integrator must change
//  that dispatch to open `conditionsHomeScreen(pregnancy: pregnancy)`
//  instead** — either by removing this entry from `kPregnancyJourneys` so the
//  switch-case fires and can be pointed at the new screen, or by special-
//  casing `kPgActConditionLibrary` in `_hubAction` before the `journeyFor`
//  lookup. Until that lands, tapping "Understand my condition" still opens
//  this journey, not the new library.
final JourneyConfig kPgUnderstandCondition = JourneyConfig(
  doorId: kPgActConditionLibrary,
  title: _en('Understand my condition'),
  // ⚠️ COPY FIX. The old line — "You have been given a name for something.
  // Here is what it usually means, and what it usually does not." — is the
  // same defect already fixed on the hub's hero, still sitting here because
  // the two were reworded in different passes.
  //
  // What makes it read as machine-written is the passive construction. "You
  // have been given a name for something" describes her situation to her from
  // the outside, in a voice with no speaker; nobody has ever said that
  // sentence out loud. The "X — and not Y" tail is the other tell, a rhythm
  // that sounds balanced and carries almost no information.
  //
  // The replacement says the same two things — here is the meaning, most of it
  // is less frightening than the word — in the words a person would use.
  intro: _en('Your doctor used a word you did not know. Here is what it '
      'actually means, in plain language.'),
  steps: [
    JourneyStep(
      question: _en('How worried should I be?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('How common is this, really'),
          value: _en('Most of what gets flagged in pregnancy is watched, not '
              'treated. Where yours sits.'),
          owed: true,
        ),
      ],
      note: _en('Nothing here is about your own scan. Your doctor has seen it '
          'and we have not.'),
    ),
    JourneyStep(
      question: _en('What is actually happening?'),
      elements: [
        JourneyElement(
          type: SolutionType.watch,
          title: _en('Explained in five minutes'),
          value: _en('What the condition is doing, drawn simply, by a doctor.'),
          meta: _en('5 MIN'),
          owed: true,
        ),
        JourneyElement(
          type: SolutionType.read,
          title: _en('The words on your report'),
          value: _en('Look up a term you did not recognise, in plain language.'),
          surfaceId: 'reports',
        ),
      ],
    ),
    JourneyStep(
      question: _en('What do I have to do differently?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Keep your readings'),
          value: _en('Log what you have been asked to log, and take the record '
              'to your next visit.'),
          action: kPgActTrackReadings,
        ),
      ],
      // ⚠️ NO PRODUCT CARD HERE. A monitor is a real need for SOME conditions
      // and not for others, and a shelf on a diagnosis page reads as selling
      // into fear. It appears inside the tracking journey, once she knows she
      // has been asked to measure something.
    ),
    JourneyStep(
      question: _en('What should make me call?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('When to ring, and when to wait'),
          value: _en('The handful of signs worth a call today rather than at '
              'your next appointment.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('I still have questions'),
      elements: [
        JourneyElement(
          type: SolutionType.consult,
          title: _en('Ask a doctor about your own case'),
          value: _en('A 1:1 where you can say the thing you did not think to '
              'ask in the appointment.'),
          action: kPgActConsult,
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you understand the word you were given, '
      'know what you are being asked to do, and know what would make you pick '
      'up the phone.'),
);

// -----------------------------------------------------------------------------
//  Manage a skin concern — THREE steps, and a product genuinely belongs
// -----------------------------------------------------------------------------
//  Persona: itching, stretch marks, or a dark line she was not expecting. She
//  is not frightened; she wants to know it is normal and what to put on it.
//
//  ⚠️ THIS IS THE HUB WHERE A PRODUCT IS THE HONEST ANSWER, and saying so
//  matters as much as refusing one elsewhere. She has an established need, she
//  is going to buy a cream today either way, and the useful thing we can do is
//  tell her what is safe and what is a waste of money. Withholding that to look
//  minimal would be under-using something we actually have.
//
//  ⚠️ AND IT ENDS WITHOUT A CONSULT. Nobody books a gynaecologist about
//  stretch marks. One exception is carried in the note instead.
final JourneyConfig kPgSkinConcern = JourneyConfig(
  doorId: kPgActSkinConcern,
  title: _en('Manage a skin concern'),
  intro: _en('Skin changes a lot in pregnancy. Most of it settles.'),
  steps: [
    JourneyStep(
      question: _en('Is this normal?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('What pregnancy does to skin'),
          value: _en('Stretch marks, the dark line, pigmentation and itching — '
              'what causes each, and what fades.'),
          owed: true,
        ),
      ],
      // The one thing on this screen that is not cosmetic, and it earns its
      // place: intense itching without a rash, especially at night, can be a
      // liver condition and is the reason this hub is not purely beauty.
      note: _en('Itching that is intense, mostly at night, and has no rash is '
          'the one to mention to your doctor rather than treat at home.'),
    ),
    JourneyStep(
      question: _en('What is safe to use?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Check an ingredient'),
          value: _en('Retinol, salicylic acid, hair colour — look it up before '
              'you use it.'),
          surfaceId: 'can_i',
        ),
      ],
    ),
    JourneyStep(
      question: _en('What actually helps?'),
      elements: [
        // ⚠️ NOT WIRED TO `product_guide`, AND THAT IS THE POINT.
        // The guide catalogue is baby products only — baby wash, diapers,
        // bottles, prams. It holds no maternal skincare at all, so sending her
        // there would have answered "what should I put on my stretch marks?"
        // with a page about nappies. Owed until the catalogue has her half.
        JourneyElement(
          type: SolutionType.product,
          title: _en('What to buy, and what to skip'),
          value: _en('Honest notes on oils and creams — including the ones we '
              'would not bother with.'),
          owed: true,
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you know the change is expected, know what '
      'is safe to put on it, and have stopped worrying about it.'),
);

// -----------------------------------------------------------------------------
//  Track my readings — FOUR steps, and it LOOPS
// -----------------------------------------------------------------------------
//  Persona: she has been told to measure something daily — sugar after meals,
//  blood pressure, sometimes weight — and will open this more often than any
//  other screen in the hub. She is not learning; she is reporting.
//
//  ⚠️ SO STEP ONE IS THE LOG, NOT AN EXPLANATION. Anything in front of the
//  input is a toll on someone doing a chore she did not choose.
//
//  ⚠️ AND THIS IS WHERE A PRODUCT IS HONEST. She has been asked to measure
//  something; she needs the device. A monitor offered HERE is help. The same
//  card on the diagnosis page would have been selling into fear, which is why
//  it is deliberately absent there.
final JourneyConfig kPgTrackReadings = JourneyConfig(
  doorId: kPgActTrackReadings,
  title: _en('Track my readings'),
  intro: _en("Log it, and it is ready to show at your next visit."),
  steps: [
    JourneyStep(
      question: _en("Today's reading"),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Log it now'),
          value: _en('Takes a few seconds, and builds the record your doctor '
              'will ask for.'),
          surfaceId: 'weight',
        ),
      ],
    ),
    JourneyStep(
      question: _en('What do I need to measure it?'),
      elements: [
        // ⚠️ THERE IS NO MONITOR IN THE CATALOGUE. Not a BP cuff, not a
        // glucometer. Pointing this at the product guide would have sent
        // someone told to measure her blood pressure to a page of prams.
        JourneyElement(
          type: SolutionType.product,
          title: _en('Monitors, and what to look for'),
          value: _en('Which ones are worth buying, and what a fair price is.'),
          owed: true,
        ),
      ],
      note: _en('Only if you have been asked to measure at home. Many people '
          'are not.'),
    ),
    JourneyStep(
      question: _en('Is this number all right?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('What the ranges usually mean'),
          value: _en('General ranges, and why one high reading on its own '
              'rarely changes anything.'),
          owed: true,
        ),
      ],
      // ⚠️ THE LINE THIS JOURNEY EXISTS TO HOLD. We show her own numbers back
      // and explain ranges in general. We never tell her what HER number means
      // — that is her clinician's, and a tracker that starts interpreting is a
      // tracker that has started diagnosing.
      note: _en('We can show you your readings. We cannot tell you what yours '
          'mean — that is your doctor reading your whole picture.'),
    ),
    JourneyStep(
      question: _en('Taking it to my appointment'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Your appointments'),
          value: _en('What is booked, so the log goes with you.'),
          surfaceId: 'appointments',
        ),
      ],
    ),
  ],
  closesWhen: _en("This one does not really close — it is a habit, and it ends "
      "each time at your next appointment with a record you did not have to "
      "remember."),
);

// -----------------------------------------------------------------------------
//  Prepare for birth — FIVE steps
// -----------------------------------------------------------------------------
//  Persona: third trimester, and the thing she has been not-thinking-about is
//  now close. She wants to know what actually happens, what she gets a say in,
//  and to have done something about it.
//
//  ⚠️ A CLASS IS THE RIGHT CLOSING OFFER HERE, NOT A CONSULT. Birth is taught,
//  not diagnosed — and this is one of the few places where a paid programme is
//  plainly the most useful thing we sell.
final JourneyConfig kPgBirthPrep = JourneyConfig(
  doorId: kPgActBirthPrep,
  title: _en('Prepare for birth'),
  intro: _en('What happens, what you get a say in, and what to have ready.'),
  //
  //  ⚠️ THE ORDER OF THE LAST THREE STEPS IS THE WHOLE REVIEW.
  //
  //  It used to run: hospital bag → birthing class. Which put the cheapest,
  //  most obvious step in front of the one thing here she would actually pay
  //  for, and left the class reading as an afterthought at the bottom of a
  //  page — "Join a birth class section seems like unimportant, but for us it
  //  is most important". It now runs:
  //
  //    what happens → how to use the timer → be taught properly → pack the bag
  //
  //  That is also the honest reading order: learning comes before doing, and
  //  packing is the last thing you do before you leave.
  steps: [
    JourneyStep(
      question: _en('What actually happens in labour?'),
      elements: [
        JourneyElement(
          type: SolutionType.watch,
          title: _en('Labour, start to finish'),
          value: _en('The stages, how long each usually takes, and what it '
              'feels like.'),
          meta: _en('12 MIN'),
          owed: true,
        ),
      ],
    ),
    // ⚠️ REMOVED, KEPT FOR REVERT — "What do I get to choose?" and "Can I
    // write it down?".
    //
    // Two steps, both owed, both about a birth plan, in the middle of a journey
    // whose job is to get her ready. The review: "Remove What Do I get to
    // Choose article... Remove can I write down." The birth-plan tool does not
    // exist, so the step promised a page and delivered a grey card; and the
    // choices article was one owed read where the reads that belong here rotate.
    //
    // What replaced the reading is `readsRotate` below — two or three topics
    // that change, rather than one fixed article that never arrives.
    //
    //    JourneyStep(
    //      question: _en('What do I get to choose?'),
    //      elements: [
    //        JourneyElement(
    //          type: SolutionType.read,
    //          title: _en('Your choices, and when to make them'),
    //          value: _en('Pain relief, positions, who is in the room — '
    //              'decided calmly now rather than mid-contraction.'),
    //          owed: true,
    //        ),
    //      ],
    //      note: _en('A plan is a preference, not a promise. Births change, '
    //          'and changing yours is not a failure.'),
    //    ),
    //    JourneyStep(
    //      question: _en('Can I write it down?'),
    //      elements: [
    //        JourneyElement(
    //          type: SolutionType.tool,
    //          title: _en('Your birth plan'),
    //          value: _en('One page your hospital can actually read at 3am.'),
    //          owed: true,
    //        ),
    //      ],
    //    ),

    // ⚠️ THE TOOL IS TAUGHT BEFORE IT IS HANDED OVER.
    //
    // The contraction timer has been built and shipped for months, and nobody
    // opens it before labour — which is the one time it is impossible to learn
    // anything. "Learn how to use Labour tool the one we have already built,
    // and in that section have a video first explaining the tool and then tool
    // below and ask user to try."
    //
    // So the video and the tool are ONE step with two elements, in that order.
    // A journey step is allowed more than one element precisely for this: the
    // explaining and the doing are not two questions she has.
    JourneyStep(
      question: _en('How do I use the contraction timer?'),
      elements: [
        JourneyElement(
          type: SolutionType.watch,
          title: _en('The contraction timer, in two minutes'),
          value: _en('When to start timing, what the numbers mean, and the '
              'one pattern that means leave for the hospital.'),
          meta: _en('2 MIN'),
          owed: true,
        ),
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Try it now'),
          value: _en('Open it once today, while nothing is happening. That is '
              'the whole point.'),
          surfaceId: 'contractions',
        ),
      ],
      note: _en('Learning it now is the only time you can. In labour you will '
          'want it to already be familiar.'),
    ),

    // ⚠️ THE CLASS SITS ABOVE THE BAG NOW. See the note on `steps`.
    JourneyStep(
      question: _en('I would rather be taught this properly'),
      elements: [
        JourneyElement(
          type: SolutionType.course,
          title: _en('Birthing classes'),
          value: _en('Live sessions on labour, breathing and what to expect — '
              'with your partner. Watch the trailer free before you decide.'),
          surfaceId: 'birthing_classes',
        ),
      ],
    ),
    JourneyStep(
      question: _en('What do I need to have ready?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Your hospital bag'),
          value: _en('What to pack for you, the baby, and whoever comes.'),
          surfaceId: 'hospital_bag',
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you know roughly what will happen, have '
      'made the two or three choices that are yours, and the bag is packed.'),
  // ⚠️ SEVEN TOPICS, THREE SHOWN, ROTATING BY THE DAY.
  //
  // These are what replaced the removed "What do I get to choose?" step. The
  // choices article is still here — as one topic among several rather than as a
  // step she has to walk through to reach the hospital bag.
  //
  // Chosen on one test: would a woman at 34 weeks tap it at 11pm. "The stages of
  // labour, explained" would not — she has the video for that. "Will I tear, and
  // what actually helps" would, and nobody writes it.
  reads: [
    JourneyRead(
      title: _en('Your choices, and when to make them'),
      value: _en('Pain relief, positions, who is in the room — decided calmly '
          'now rather than mid-contraction.'),
      minutes: _en('5 MIN'),
    ),
    JourneyRead(
      title: _en('Will I tear, and what actually helps'),
      value: _en('The honest answer, the numbers, and the two things that are '
          'shown to reduce it.'),
      minutes: _en('4 MIN'),
    ),
    JourneyRead(
      title: _en('How to tell false labour from the real thing'),
      value: _en('The three differences that actually separate them, without '
          'a trip to the hospital to find out.'),
      minutes: _en('4 MIN'),
    ),
    JourneyRead(
      title: _en('What your partner should actually do'),
      value: _en('Most of the useful things are small, and none of them are '
          'holding your hand and saying breathe.'),
      minutes: _en('5 MIN'),
    ),
    JourneyRead(
      title: _en('If it becomes a C-section'),
      value: _en('What changes, what does not, and why it is not the plan '
          'failing.'),
      minutes: _en('6 MIN'),
    ),
    JourneyRead(
      title: _en('The first hour after birth'),
      value: _en('Skin to skin, the first feed, and what is happening while '
          'the room is busy.'),
      minutes: _en('5 MIN'),
    ),
    JourneyRead(
      title: _en('What to expect at an Indian hospital'),
      value: _en('Who is in the room, what you will be asked to sign, and '
          'what you can ask for.'),
      minutes: _en('6 MIN'),
    ),
  ],
);

// -----------------------------------------------------------------------------
//  Check how I am feeling — TWO steps, and it must stay two
// -----------------------------------------------------------------------------
//  Persona: something is off and she has not said it out loud. She is not
//  looking for a library; she is looking for permission to notice.
//
//  ⚠️ THE SHORTEST JOURNEY IN THE APP, ON PURPOSE. Every extra step here is a
//  reason to close the screen. A check-in that opens with reading is a
//  check-in nobody completes.
//
//  ⚠️ IT NEVER RETURNS A SCORE, A LABEL OR A DIAGNOSIS. It reflects back what
//  she said and offers a person. Anything more is us diagnosing depression
//  from a phone, which we will not do.
final JourneyConfig kPgMoodCheck = JourneyConfig(
  doorId: kPgActMoodCheck,
  title: _en('Check how I am feeling'),
  intro: _en('A few quiet questions about the last two weeks. Only you see '
      'the answers.'),
  steps: [
    JourneyStep(
      question: _en('How has the last fortnight been?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('The check-in'),
          value: _en('Ten questions, two minutes, no score at the end.'),
          owed: true,
        ),
      ],
      note: _en('There is no pass or fail here, and nothing is shared with '
          'anyone.'),
    ),
    JourneyStep(
      question: _en('I would like to talk to someone'),
      elements: [
        JourneyElement(
          type: SolutionType.consult,
          title: _en('Talk to someone who works with mothers'),
          value: _en('A 1:1, in confidence, with someone who does this every '
              'day.'),
          action: kPgActConsult,
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you have said it to yourself honestly — '
      'and, if you want, to someone else.'),
);

// -----------------------------------------------------------------------------
//  Help me feel better — THREE steps, activity-led
// -----------------------------------------------------------------------------
//  Persona: she knows how she feels and wants something to DO about it today.
//  Reading is the least useful thing we could hand her first.
final JourneyConfig kPgFeelBetter = JourneyConfig(
  doorId: kPgActFeelBetter,
  title: _en('Help me feel better'),
  intro: _en('Small things that genuinely help. None of them take long.'),
  steps: [
    JourneyStep(
      question: _en('Something for right now'),
      elements: [
        JourneyElement(
          type: SolutionType.activity,
          title: _en('Five quiet minutes'),
          value: _en('Breathing and a short practice you can do sitting down.'),
          surfaceId: 'garbh_daily',
        ),
      ],
    ),
    JourneyStep(
      question: _en('Something for this week'),
      elements: [
        JourneyElement(
          type: SolutionType.activity,
          title: _en('Gentle movement'),
          value: _en('Short prenatal sessions — the single most reliable thing '
              'for mood in pregnancy.'),
          surfaceId: 'yoga',
        ),
        JourneyElement(
          type: SolutionType.read,
          title: _en('Sleeping better while pregnant'),
          value: _en('What actually helps when lying down is the problem.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('What do I say to people?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Telling someone you are struggling'),
          value: _en('Words for your partner, your mother, and your doctor — '
              'when you cannot find your own.'),
          owed: true,
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you have done one thing, not read five.'),
);

// -----------------------------------------------------------------------------
//  Something has been flagged — THREE steps
// -----------------------------------------------------------------------------
//  Persona: a number was mentioned at an appointment — low haemoglobin, weight
//  gain, a level. She is not ill; she has been given homework.
final JourneyConfig kPgNutritionFlag = JourneyConfig(
  doorId: kPgActNutritionFlag,
  title: _en('Something has been flagged'),
  intro: _en('A number came up at your appointment. Here is what usually '
      'moves it.'),
  steps: [
    JourneyStep(
      question: _en('What does this one mean?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Iron, weight and the usual flags'),
          value: _en('What each is measuring, and why it gets watched in '
              'pregnancy.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('What should I eat differently?'),
      elements: [
        // ⚠️ `nutrition` IS A PAID-CONSULT FUNNEL, NOT FOOD CONTENT.
        // It runs a three-question quiz and ends at "book a nutritionist" —
        // and the plan it promises after booking is itself a coming-soon stub.
        // A step titled "what should I eat differently" cannot be a sales
        // funnel with nothing at the end of it.
        JourneyElement(
          type: SolutionType.read,
          title: _en('Food that helps'),
          value: _en('Everyday Indian food that moves this, not a list of '
              'imported superfoods.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('Am I taking the right supplement?'),
      elements: [
        // The medicine screen is a REMINDER tracker — add, alarm, mark taken.
        // It is genuinely useful for "am I taking them", which is what this
        // element now promises. It does not explain dosage, timing or
        // interactions, so the promise was narrowed to what the screen does
        // rather than the screen being blamed for a promise it never made.
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Keep track of what you take'),
          value: _en('Set a reminder for each one, and see what you have '
              'actually been taking.'),
          surfaceId: 'medication',
        ),
      ],
      note: _en('Do not start or stop a supplement because of this page — '
          'take the question to whoever flagged the number.'),
    ),
  ],
  closesWhen: _en('This closes when you know what the number was about and '
      'have changed one thing you actually eat.'),
);

/// Every pregnancy journey, keyed by the door that opens it.
final Map<String, JourneyConfig> kPregnancyJourneys = {
  for (final j in [
    kPgUnderstandCondition,
    kPgSkinConcern,
    kPgTrackReadings,
    kPgBirthPrep,
    kPgMoodCheck,
    kPgFeelBetter,
    kPgNutritionFlag,
  ])
    j.doorId: j,
};
