// =============================================================================
//  TTC journeys — what happens inside a door
// -----------------------------------------------------------------------------
//  See `journey_config.dart` for the rules. The two that matter most:
//
//    · every step heading is HER question, never our category;
//    · there is NO template — these come out different lengths on purpose, and
//      if two journeys look the same, one of them is wrong.
//
//  Six doors, six shapes, deliberately: 2, 3, 4, 5, 6 and 7 steps. The count is
//  not chosen for variety's own sake — it falls out of how much the question
//  actually holds. "Understand recovery & trying again" is two steps because
//  padding a grieving woman's screen with more would be the injury, not the
//  care. "Understand my PCOS" is seven because it is the highest-demand
//  bracket in the stage and the real question has that many honest parts.
//
//  ⚠️ NEVER A PERSONALISED PROBABILITY. No "your chances this month", no
//  computed odds, anywhere below — see CLAUDE.md's clinical invariants.
//  Population guidance stays in, because it lowers pressure rather than
//  setting a target: "PCOS affects roughly 1 in 5 women" is allowed;
//  "your chance this cycle is X%" would never be.
//
//  ⚠️ ENGLISH ONLY FOR NOW — same call as `pregnancy_journeys.dart` and
//  `ttc_hubs.dart`. `_en(...)` = English now, Hindi (or Hinglish) owed.
// =============================================================================

import '../../localization/app_language.dart';
import '../../screens/brackets/hub/hub_solution_cards.dart';
import '../../screens/brackets/hub/journey_config.dart';
import '../hubs/ttc_hubs.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  1. Improve my chances this cycle — FOUR steps, and it never asks for a talk
// -----------------------------------------------------------------------------
//  Persona: already trying, this cycle, and wants practical answers — timing
//  and habits, not a course and not a consult. The hub itself already carries
//  a closing offer ("Talk to a fertility expert"), so this journey does not
//  repeat it; ending on a tracking habit rather than an escalation is the
//  honest shape for a door that is about THIS cycle, not a decision.
//
//  ⚠️ THE DOOR'S OWN NAME IS THE TRAP. "Improve my chances" must never grow a
//  number. Every element here is timing or habit, never a computed odds.
final JourneyConfig kTtcImproveChances = JourneyConfig(
  doorId: kTtcActImproveChances,
  title: _en('Improve my chances this cycle'),
  intro: _en("We don't work out a number for you here. Just the timing "
      'and the everyday habits that really help this cycle.'),
  steps: [
    JourneyStep(
      question: _en('When exactly should we be trying?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Find your fertile window'),
          value: _en('See which days in this cycle trying is most likely '
              'to count.'),
          surfaceId: 'ttc_window',
        ),
      ],
    ),
    JourneyStep(
      question: _en("What really helps, and what's just noise?"),
      elements: [
        // Real, as of the fertile-window content pass. Carries the six-day
        // window, the every-one-to-two-days guidance, and the four myths —
        // sourced to the ASRM/SREI committee opinion.
        JourneyElement(
          type: SolutionType.read,
          title: _en('Timing, and the advice you can let go of'),
          value: _en('Positions, "saving it up", lying down after. What the '
              'evidence says about each one.'),
          meta: _en('7 MIN'),
          surfaceId: 'ttc_read/ttc_read_timing_myths',
        ),
        // ⚠️ THE MECHANISM SITS BESIDE THE TIMING, NOT BEFORE IT.
        //
        // The workbook's Content cell for this bracket names four topics —
        // "How conception works, timing, cycle basics, common myths" — and the
        // first two belong to different questions. Someone asking "what
        // actually helps" wants the timing; someone who wants to understand
        // the machinery is asking a calmer question and can take the second
        // tile. Two tiles in one row, which is exactly what the grid is for.
        JourneyElement(
          type: SolutionType.read,
          title: _en('How conception works'),
          value: _en('Your cycle comes in two halves. Here is why only one '
              'of them changes length.'),
          meta: _en('8 MIN'),
          surfaceId: 'ttc_read/ttc_read_how_conception_works',
        ),
      ],
    ),
    JourneyStep(
      question: _en('Is there anything worth adding, like a strip or a '
          'supplement?'),
      elements: [
        JourneyElement(
          type: SolutionType.product,
          title: _en('Ovulation strips and folic acid'),
          value: _en("The two things worth keeping at home, and nothing "
              "you don't need."),
          surfaceId: 'ttc_products',
        ),
      ],
      note: _en("None of this is a guarantee. It's a sensible, low-cost "
          'place to start.'),
    ),
    JourneyStep(
      question: _en('How do I know if this cycle is different from the last?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Keep a simple log'),
          value: _en('Write down what you notice. If there is a pattern, '
              'this is where it will show up.'),
          surfaceId: 'ttc_calendar',
        ),
      ],
    ),
  ],
  closesWhen: _en("You're done here when you know this cycle's fertile "
      "days, have picked up one or two habits worth keeping, and have "
      "stopped chasing the ones that don't help."),
);

// -----------------------------------------------------------------------------
//  2. Understand my PCOS — SEVEN steps, the richest journey in the stage
// -----------------------------------------------------------------------------
//  Persona: just been told the word, or suspects it, and is frightened before
//  she is curious. PCOS is the highest-demand bracket in TTC (see the note at
//  the top of ttc_brackets.dart), which is why this is allowed to be the
//  longest journey rather than trimmed to look consistent with the others.
//
//  ⚠️ STEP ONE IS SCALE, NOT DEFINITION — same move as pregnancy's condition
//  journey. "How worried should I be" answers what she actually asked first.
//
//  ⚠️ ENDS AT A PERSON, via the programme first. PCOS management is not a
//  single fact she reads once; it earns both a structured course AND a
//  specialist at the close, where a lighter condition would only need one.
final JourneyConfig kTtcPcosLibrary = JourneyConfig(
  doorId: kTtcActPcosLibrary,
  title: _en('Understand my PCOS'),
  intro: _en("Maybe a doctor has said PCOS, or maybe you think you have "
      "it. Here's what it really means when you're trying to conceive. "
      'Not the worst-case version.'),
  steps: [
    JourneyStep(
      question: _en('How worried should I be?'),
      elements: [
        // ⚠️ THE FIRST SLOT IN THIS STAGE TO STOP BEING A PLACEHOLDER.
        // `ttc_read_pcos_cycle` is a real ~1,600-word piece written against the
        // 2023 ESHRE/ASRM/Monash guideline, and it opens in `PvReaderScreen`.
        // Its own scale-setter answers this step's question before the first
        // section — which is why this step points at the whole read rather than
        // at a fragment of it.
        JourneyElement(
          type: SolutionType.read,
          title: _en('What PCOS is doing to your cycle'),
          value: _en("How common it is, what's really going on, and why "
              "irregular cycles don't mean it can't happen."),
          meta: _en('8 MIN'),
          surfaceId: 'ttc_read/ttc_read_pcos_cycle',
        ),
      ],
    ),
    JourneyStep(
      question: _en('What is happening in my body?'),
      elements: [
        // ⚠️ NAMES THE DECLARED FILM. Without `videoSlot` this placeholder
        // generates its own id from the door and the title, while the same
        // intended film sits in `ttc_videos_data.dart` as
        // `ttc_vid_pcos_explained` and heads the PCOS article. One upload would
        // have filled one surface and left the other a placeholder forever.
        JourneyElement(
          type: SolutionType.watch,
          title: _en('PCOS, explained in five minutes'),
          value: _en('A doctor draws out the hormones and the cycle in '
              'plain pictures.'),
          meta: _en('5 MIN'),
          owed: true,
          videoSlot: 'ttc_vid_pcos_explained',
        ),
      ],
    ),
    JourneyStep(
      question: _en("Does having PCOS mean I'll need medication?"),
      elements: [
        // Real. Follows the 2023 ESHRE/ASRM/Monash order, and is written to
        // EXPLAIN what she is likely to be offered rather than to recommend —
        // treatment is the clinician's decision. See TimingOwnership.
        JourneyElement(
          type: SolutionType.read,
          title: _en('What treatment usually looks like'),
          value: _en('The order doctors usually try things in, and what to '
              'ask before you agree to any of it.'),
          meta: _en('9 MIN'),
          surfaceId: 'ttc_read/ttc_read_pcos_treatment',
        ),
      ],
      note: _en("What's right for you is one for your own doctor to "
          'answer. They know your case.'),
    ),
    JourneyStep(
      question: _en('What helps day to day, with food and insulin?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Food, insulin and PCOS'),
          value: _en('What makes a real difference to blood sugar in an '
              'Indian kitchen. And no food has to be cut out.'),
          meta: _en('9 MIN'),
          surfaceId: 'ttc_read/ttc_read_pcos_food',
        ),
        JourneyElement(
          type: SolutionType.product,
          title: _en('Inositol and the supplements worth taking'),
          value: _en("What has been shown to help, and what's just "
              'marketing.'),
          surfaceId: 'ttc_supplements',
        ),
      ],
    ),
    JourneyStep(
      question: _en('How do I keep track of my cycle well enough to plan '
          'around it?'),
      elements: [
        // ⚠️ THE CHECKER FIRST, THE TRACKER SECOND, and the order is the
        // point. The checker reads her logged cycles and tells her what they
        // already say; the tracker is what she uses afterwards to sharpen it.
        // Offering the tracker first asks her to go away and come back in
        // three months before the app tells her anything.
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Check your own pattern'),
          value: _en("Three minutes, using the cycles you've already "
              "logged. It doesn't diagnose anything."),
          meta: _en('3 MIN'),
          surfaceId: 'ttc_pcos_check',
        ),
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Track your cycle'),
          value: _en('PCOS can make your cycle hard to read. A steady record '
              "helps you spot the pattern that's there."),
          surfaceId: 'ttc_cycle',
        ),
      ],
    ),
    JourneyStep(
      question: _en('Is there a step-by-step programme?'),
      elements: [
        JourneyElement(
          type: SolutionType.course,
          title: _en('The PCOS programme'),
          value: _en("A guided course made for exactly this, for when "
              "reading on your own isn't enough."),
          surfaceId: 'ttc_prepare',
        ),
      ],
    ),
    JourneyStep(
      question: _en('I still have questions about my own case'),
      elements: [
        JourneyElement(
          type: SolutionType.consult,
          title: _en('Talk to a PCOS specialist'),
          value: _en('Book a 1:1 with someone who can look at your own '
              'reports, and ask about managing PCOS while trying.'),
          action: kTtcActConsult,
        ),
      ],
    ),
  ],
  closesWhen: _en("You're done here when you understand what PCOS means "
      "for trying to conceive, know what's worth changing day to day, and "
      'have a way to keep track of your cycle from here on.'),
);

// -----------------------------------------------------------------------------
//  3. Should I seek fertility help? — THREE steps, and it is a decision, not
//     a booking
// -----------------------------------------------------------------------------
//  Persona: has been trying a while, keeps wondering "is this normal", and
//  wants to know if it's time — not to be told to book.
//
//  ⚠️ THIS JOURNEY ENDS WHEN SHE KNOWS, NOT WHEN SHE HAS BOOKED. The self-check
//  is the actual destination; the consult sits after it as what to do WITH
//  the answer, never before it.
//
//  ⚠️ THE GUIDELINE IS POPULATION-LEVEL, NEVER CALCULATED FOR HER. "Under 35,
//  try 12 months" is the same sentence every clinic gives every patient — it
//  is not a personalised estimate, and the note under step one says so.
final JourneyConfig kTtcFertilityReadinessCheck = JourneyConfig(
  doorId: kTtcActFertilityReadinessCheck,
  title: _en('Should I seek fertility help?'),
  intro: _en("This isn't a test you can fail. It helps you work out, "
      "honestly, if it's time to see someone or if it's still early."),
  steps: [
    JourneyStep(
      question: _en("How long is 'long enough' to have been trying on our "
          'own?'),
      elements: [
        // Both owed slots are answered by one read: the piece carries the
        // NICE threshold AND the six situations where the clock does not
        // apply. Splitting one article across two tiles to keep a one-to-one
        // map with the old placeholders would be inventory UX — two tiles
        // opening the same page.
        JourneyElement(
          type: SolutionType.read,
          title: _en("When it's time to see a doctor"),
          value: _en('The twelve-month guideline, and the times when you '
              "shouldn't wait that long at all."),
          meta: _en('8 MIN'),
          surfaceId: 'ttc_read/ttc_read_when_to_seek_help',
        ),
      ],
      note: _en('These are general guidelines for most couples. They are '
          'not worked out for you.'),
    ),
    JourneyStep(
      question: _en('Where do I honestly stand?'),
      elements: [
        // ⚠️ THE LAST PLACEHOLDER IN THE STAGE, AND IT IS NOW REAL. It opens
        // already knowing how long she has been trying, what her cycles look
        // like and what her PCOS check found — so it asks only what nothing
        // else can answer, and often that is two questions.
        JourneyElement(
          type: SolutionType.tool,
          title: _en('The honest self-check'),
          value: _en('It already knows most of this. A couple of questions, '
              'then a clear answer. Never a probability.'),
          meta: _en('2 MIN'),
          surfaceId: 'ttc_fertility_help',
        ),
      ],
    ),
    JourneyStep(
      question: _en("I think it's time. Who do I talk to?"),
      elements: [
        JourneyElement(
          type: SolutionType.consult,
          title: _en('Speak to a fertility specialist'),
          value: _en('Book a 1:1 and start from where you are now, not '
              'where you think you should be.'),
          action: kTtcActConsult,
        ),
      ],
    ),
  ],
  closesWhen: _en("You're done here when you can say clearly, in your own "
      "words, whether it's time to book or still early. You don't need to "
      'have booked.'),
);

// -----------------------------------------------------------------------------
//  4. Get ready before trying — SIX steps, and it is the only checklist
//     journey in the stage
// -----------------------------------------------------------------------------
//  Persona: hasn't started trying yet and wants the practical groundwork
//  done properly — diet, tests, supplements, weight, habits — before the
//  cycle-tracking starts. Unhurried, because nothing here is urgent; ordered,
//  because that is exactly what she is asking for.
//
//  ⚠️ PRODUCT SITS AT STEP THREE, NOT STEP ONE. The need (what to eat, what
//  to test) is established first; folic acid then follows as the honest next
//  question rather than a shelf on a landing step.
final JourneyConfig kTtcPreconceptionReadiness = JourneyConfig(
  doorId: kTtcActPreconceptionReadiness,
  title: _en('Get ready before trying'),
  intro: _en("A short, practical list of what's worth sorting out before "
      "you start trying. Nothing urgent, nothing you have to rush."),
  steps: [
    JourneyStep(
      question: _en('What should I be eating, and what should I cut out?'),
      elements: [
        // ⚠️ WAS `ttc_nutrition` TYPED AS A READ, AND IT IS NOT ONE.
        // That surface is a day-by-day eating planner — genuinely useful, and
        // not an answer to "what should I change before we start". A planner
        // says what to eat on Thursday; the read says why the three months
        // matter at all. Both now appear, each as what it actually is.
        JourneyElement(
          type: SolutionType.read,
          title: _en('The three months before'),
          value: _en('Why these months matter, what folic acid does, and '
              'how much weight really matters. For both of you.'),
          meta: _en('9 MIN'),
          surfaceId: 'ttc_read/ttc_read_three_months_before',
        ),
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Eating, day to day'),
          value: _en('A meal planner built around the Indian food you '
              'already cook.'),
          surfaceId: 'ttc_nutrition',
        ),
      ],
    ),
    JourneyStep(
      question: _en('What tests and vaccinations are worth doing first?'),
      elements: [
        // ⚠️ THE VACCINATION HALF OF THIS DID NOT EXIST ANYWHERE IN TTC until
        // now — a grep for rubella, MMR or "vaccin" across the whole stage
        // returned nothing, while the workbook names it in this bracket's
        // Content cell. `ttc_tests` is the fertility-workup library and never
        // covered it.
        JourneyElement(
          type: SolutionType.read,
          title: _en('The tests and vaccinations worth doing first'),
          value: _en('Including two vaccines to have a month before you '
              'start, and one screening test that matters more in India.'),
          meta: _en('8 MIN'),
          surfaceId: 'ttc_read/ttc_read_preconception_tests',
        ),
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Check your vaccinations'),
          value: _en('Which to ask for by name, and whether anything means '
              'waiting a month before you start.'),
          surfaceId: 'ttc_vaccinations',
        ),
        JourneyElement(
          type: SolutionType.tool,
          title: _en('The full test library'),
          value: _en('Every test, when to have it, and what it costs in '
              'India.'),
          surfaceId: 'ttc_tests',
        ),
      ],
    ),
    JourneyStep(
      question: _en('Should I start folic acid or anything else now?'),
      elements: [
        JourneyElement(
          type: SolutionType.product,
          title: _en('Folic acid and other supplements before pregnancy'),
          value: _en("What's worth starting now, and how early to start "
              'it.'),
          surfaceId: 'ttc_supplements',
        ),
      ],
    ),
    JourneyStep(
      question: _en('Is my weight going to make a difference?'),
      elements: [
        // ⚠️ THE BMI SLOT IS ANSWERED BY THE CHECKLIST, NOT BY A BMI TOOL.
        //
        // The workbook's Tools cell reads "Pre-pregnancy checklist, BMI", and
        // the checklist carries the weight item — deliberately with no BMI
        // number, no target and no calculator. Weight affects ovulation at
        // both ends, the evidence supports a modest five per cent rather than
        // reaching a figure, and BMI reads Indian bodies badly. A calculator
        // here would produce a number that means less than the sentence it
        // replaced, on the one topic in this stage most likely to be heard as
        // blame.
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Your pre-pregnancy checklist'),
          value: _en("What you've already covered, what's still worth "
              'talking over, and your next three steps.'),
          meta: _en('CHECKLIST'),
          surfaceId: 'ttc_precheck',
        ),
      ],
    ),
    JourneyStep(
      question: _en('What small habits help, day to day?'),
      elements: [
        // ⚠️ THE WORKBOOK'S ACTIVITIES CELL HERE IS THREE WORDS — "Light
        // habit-building" — AND IT SPECIFIES NO MECHANISM.
        //
        // TTC already has three surfaces doing this: the checklist's Lifestyle
        // section holds the decisions, the Tools hub holds Sleep, Movement,
        // Stress and Lifestyle trackers for the repetition, and `ttc_ritual` is
        // the mind-body half. A fifth habit surface would be exactly the
        // inventory sprawl the bracket restructure removed.
        //
        // So this was never a missing feature. It was a missing route.
        JourneyElement(
          type: SolutionType.activity,
          title: _en('Habits worth building now'),
          value: _en('Sleep, movement, alcohol and tobacco. Decide where you '
              'stand on each, all in one place.'),
          surfaceId: 'ttc_precheck/lifestyle',
        ),
        JourneyElement(
          type: SolutionType.tool,
          title: _en("Track the ones you're working on"),
          value: _en('Sleep, movement and stress each have a tracker, to '
              'help a new habit stick.'),
          surfaceId: 'ttc_tools',
        ),
      ],
    ),
    JourneyStep(
      question: _en("I'd like to talk this through before we start"),
      elements: [
        JourneyElement(
          type: SolutionType.consult,
          title: _en('Talk to someone before you start'),
          value: _en('Book a short session and ask a doctor or nutritionist '
              "what's really worth doing first."),
          action: kTtcActConsult,
        ),
      ],
    ),
  ],
  closesWhen: _en("You're done here when your diet, tests and supplements "
      "are sorted, and you know there's nothing urgent left to do before "
      'you start trying.'),
);

// -----------------------------------------------------------------------------
//  5. Understand sperm health — FIVE steps, written for two readers
// -----------------------------------------------------------------------------
//  Persona: she opened this, but he may read it too, and it must not read as
//  a report card on either of them. See CLAUDE.md's brief for this door.
//
//  ⚠️ STEP ONE IS THE NON-BLAME FRAME, BEFORE A SINGLE FACT ABOUT SPERM. A
//  journey that opens with "what affects sperm health" without first saying
//  fertility is usually shared reads as diagnosis-first, and that is exactly
//  the arrival CLAUDE.md and ttc_hubs.dart both flag as the wrong one.
//
//  ⚠️ CONSULT LANGUAGE STAYS "IN CONFIDENCE", NOT "GET HIS RESULTS SORTED" —
//  this is a test result, not a chore.
final JourneyConfig kTtcSpermHealth = JourneyConfig(
  doorId: kTtcActSpermHealth,
  title: _en('Understand sperm health'),
  intro: _en('Fertility is often about both of you, not only her. Here '
      "is what's known about sperm health, written so either of you can "
      'read it.'),
  steps: [
    JourneyStep(
      question: _en('Is this even about him, or could it be both of us?'),
      elements: [
        // ⚠️ THE FIGURE WAS RESTATED TO MATCH THE READ. The step said "a
        // third his, a third hers, a third both", the article says "a male
        // factor is involved in roughly half" — both are common framings and
        // they are arithmetically compatible (his-alone plus both), but a tile
        // and the page it opens must not appear to disagree.
        JourneyElement(
          type: SolutionType.read,
          title: _en('Whose "side" is it, really'),
          value: _en('A male factor is involved in about half of couples. '
              'His side is also the quickest to check.'),
          meta: _en('8 MIN'),
          surfaceId: 'ttc_read/ttc_read_whose_side',
        ),
      ],
      note: _en("Nothing here is about deciding who's 'the reason'. It's "
          'rarely just one person.'),
    ),
    JourneyStep(
      question: _en('What affects sperm health?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Heat, habits and time'),
          value: _en('Three things with real evidence behind them, how much '
              'each helps, and how long before it shows.'),
          meta: _en('8 MIN'),
          surfaceId: 'ttc_read/ttc_read_heat_habits',
        ),
      ],
    ),
    JourneyStep(
      question: _en('Is this something worth testing?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('What a semen analysis involves'),
          value: _en('How it\'s done, and why "below normal" doesn\'t mean '
              'what it sounds like.'),
          meta: _en('9 MIN'),
          surfaceId: 'ttc_read/ttc_read_semen_analysis',
        ),
      ],
    ),
    JourneyStep(
      question: _en('What can we change, starting now?'),
      elements: [
        JourneyElement(
          type: SolutionType.course,
          title: _en('The half nobody talks about'),
          value: _en('A short course on the lifestyle changes that make a '
              'real difference.'),
          surfaceId: 'ttc_prepare',
        ),
        JourneyElement(
          type: SolutionType.product,
          title: _en('Supplements worth considering'),
          value: _en('Zinc and CoQ10, explained for him, and honest that the '
              'evidence here is weak.'),
          surfaceId: 'ttc_supplements',
        ),
      ],
    ),
    JourneyStep(
      question: _en("We'd like to talk to someone about his results"),
      elements: [
        JourneyElement(
          type: SolutionType.consult,
          title: _en('Talk to a specialist'),
          value: _en('Book a 1:1 and go through his results privately, '
              'without it feeling like a judgement.'),
          action: kTtcActConsult,
        ),
      ],
    ),
  ],
  closesWhen: _en("You're done here when you both understand what affects "
      'sperm health, know if testing is worth doing, and know what is worth '
      'changing. And neither of you is left feeling blamed.'),
);

// -----------------------------------------------------------------------------
//  6. Understand recovery & trying again — TWO steps, and that is deliberate
// -----------------------------------------------------------------------------
//  Persona: has just lost a pregnancy. See ttc_hubs.dart's note on this
//  bracket — five of its seven layers are `notApplicable` in the workbook,
//  and every refusal there is right.
//
//  ⚠️ NO PRODUCT. NO COURSE. NO CONSULT PUSH. The one live consult and
//  community this bracket has already live elsewhere on the hub — a
//  psychologist reached through Prepare, and the community door beside this
//  one. Repeating either here would turn a quiet library into an upsell.
//
//  ⚠️ THIS IS THE SHORTEST JOURNEY IN THE FILE, ON PURPOSE. The instinct to
//  add a third step — "what's next", "when you're ready" — was resisted: it
//  is exactly the false momentum this door must never carry.
final JourneyConfig kTtcLossRecoveryLibrary = JourneyConfig(
  doorId: kTtcActLossRecoveryLibrary,
  title: _en('Understand recovery and trying again'),
  intro: _en("There's no rush here, and nothing you have to decide today. "
      "Just what's known, said plainly."),
  steps: [
    JourneyStep(
      question: _en('What does my body need to heal?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Physical recovery, in plain terms'),
          value: _en('What usually happens over the next few weeks, and the '
              'few signs that need a doctor today.'),
          meta: _en('8 MIN'),
          surfaceId: 'ttc_read/ttc_read_loss_recovery',
        ),
      ],
    ),
    JourneyStep(
      question: _en('When is it safe to try again, if I want to?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('On trying again'),
          value: _en('What the evidence says about waiting, and the part '
              'only you can answer.'),
          meta: _en('8 MIN'),
          surfaceId: 'ttc_read/ttc_read_trying_again',
        ),
      ],
      note: _en('This is a guide. There is no deadline.'),
    ),
  ],
  closesWhen: _en("You're done here when you know roughly what your body "
      "is doing right now, and that there's no deadline you have to meet."),
);

/// Every TTC journey, keyed by the door that opens it.
///
/// ⚠️ `kTtcImproveChances` IS OUT, BECAUSE ITS DOOR IS GONE. It was opened by
/// the "Improve my chances this cycle" card on the conceiving hub, and that hub
/// no longer exists — the bracket opens `TtcFocusScreen` directly now. A
/// journey registered against a door nobody can reach is unreachable code that
/// still looks live in this list, which is the exact thing the wiring gate in
/// CLAUDE.md exists to catch.
///
/// ⚠️ NOTHING IT REACHED WAS LOST, and that was checked destination by
/// destination rather than assumed:
///
///   · `ttc_window` — section one of the focus page, as the tool.
///   · `ttc_read_how_conception_works` — section one, as an article.
///   · `ttc_read_timing_myths` — under "How often is best", and also still on
///     the preconception checklist.
///   · `ttc_products` — the ovulation-kit tile.
///   · `ttc_calendar` — the home header and the More tab.
///
/// The journey config stays defined above so restoring it is uncommenting one
/// line, and so the four steps it sequenced are on record.
final Map<String, JourneyConfig> kTtcJourneys = {
  for (final j in [
    // kTtcImproveChances,
    kTtcPcosLibrary,
    kTtcFertilityReadinessCheck,
    kTtcPreconceptionReadiness,
    kTtcSpermHealth,
    kTtcLossRecoveryLibrary,
  ])
    j.doorId: j,
};
