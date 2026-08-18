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
  intro: _en("Nothing here is a number we calculate for you — just the "
      'timing and everyday habits that genuinely help this cycle.'),
  steps: [
    JourneyStep(
      question: _en('When exactly should we be trying?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Find your fertile window'),
          value: _en('See the days this cycle when trying has the best '
              'chance of counting.'),
          surfaceId: 'ttc_window',
        ),
      ],
    ),
    JourneyStep(
      question: _en("What actually helps, and what's just noise?"),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Timing myths, sorted from what works'),
          value: _en('Positions, "saving it up", lying down after — what the '
              'evidence actually says about each.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('Is there anything worth adding — a strip, a supplement?'),
      elements: [
        JourneyElement(
          type: SolutionType.product,
          title: _en('Ovulation strips & folic acid'),
          value: _en("The two things worth having in the house — nothing "
              "you don't need."),
          surfaceId: 'ttc_products',
        ),
      ],
      note: _en('Nothing here is a guarantee — just a sensible, inexpensive '
          'baseline.'),
    ),
    JourneyStep(
      question: _en('How do I know if this cycle is different from the last?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Keep a simple log'),
          value: _en('Note what you notice, so a pattern — if there is one — '
              'has somewhere to show up.'),
          surfaceId: 'ttc_calendar',
        ),
      ],
    ),
  ],
  closesWhen: _en("This closes when you know this cycle's fertile days, have "
      "picked up one or two habits worth keeping, and have stopped chasing "
      "the ones that don't."),
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
  intro: _en("You've been told the word, or you suspect it. Here is what "
      'PCOS actually means for someone trying to conceive — not the '
      'worst-case version.'),
  steps: [
    JourneyStep(
      question: _en('How worried should I be?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('How common this actually is'),
          value: _en('PCOS affects roughly 1 in 5 women, and most who have '
              'it go on to conceive — many without any treatment at all.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('What is actually happening in my body?'),
      elements: [
        JourneyElement(
          type: SolutionType.watch,
          title: _en('PCOS, explained in five minutes'),
          value: _en('The hormones and the cycle, drawn simply, by a '
              'doctor.'),
          meta: _en('5 MIN'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en("Does having PCOS mean I'll need medication?"),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('What treatment usually looks like'),
          value: _en('It ranges from a diet change to a tablet to nothing at '
              "all — what decides which."),
          owed: true,
        ),
      ],
      note: _en("What's right for you is a question for your own doctor, "
          'not a general answer.'),
    ),
    JourneyStep(
      question: _en('What actually helps day to day — diet and insulin?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Food, insulin and PCOS'),
          value: _en('The changes that genuinely move the needle, and the '
              "ones that are mostly noise."),
          owed: true,
        ),
        JourneyElement(
          type: SolutionType.product,
          title: _en('Inositol & the supplements worth it'),
          value: _en("What's actually shown to help, and what's just "
              'marketing.'),
          surfaceId: 'ttc_supplements',
        ),
      ],
    ),
    JourneyStep(
      question: _en('How do I keep my cycle readable enough to plan around?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('Track your cycle'),
          value: _en('PCOS can make your cycle hard to read — keep enough '
              'of a record to spot the pattern that is there.'),
          surfaceId: 'ttc_cycle',
        ),
      ],
    ),
    JourneyStep(
      question: _en('Is there a more structured programme?'),
      elements: [
        JourneyElement(
          type: SolutionType.course,
          title: _en('The PCOS programme'),
          value: _en("A guided course built around exactly this — for when "
              "reading isn't enough on its own."),
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
          value: _en('Book a 1:1 and ask about managing PCOS while trying — '
              'with someone who can see your own reports.'),
          action: kTtcActConsult,
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you understand what PCOS means for '
      "trying to conceive, know what's worth changing day to day, and have "
      'a way to track your own cycle going forward.'),
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
  intro: _en("This is not a test you can fail. It's a way to work out, "
      'honestly, whether it is time to see someone — or whether it is still '
      'early.'),
  steps: [
    JourneyStep(
      question: _en("How long is 'long enough' to have been trying on our "
          'own?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('The usual guideline'),
          value: _en('Under 35: most guidance says try for 12 months first. '
              '35 or older: 6 months.'),
          owed: true,
        ),
        JourneyElement(
          type: SolutionType.read,
          title: _en('Reasons not to wait at all'),
          value: _en('Irregular or absent periods, a known condition, a '
              'past surgery — a shortlist of reasons to see someone '
              'sooner.'),
          owed: true,
        ),
      ],
      note: _en('These are population guidelines, not a calculation of your '
          'own case.'),
    ),
    JourneyStep(
      question: _en('Where do I honestly stand?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('The honest self-check'),
          value: _en('A few straightforward questions, to help you see your '
              'own situation clearly.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en("I think it's time — who do I talk to?"),
      elements: [
        JourneyElement(
          type: SolutionType.consult,
          title: _en('Speak to a fertility specialist'),
          value: _en('Book a 1:1 and start from where you actually are, not '
              'where you think you should be.'),
          action: kTtcActConsult,
        ),
      ],
    ),
  ],
  closesWhen: _en("This closes when you know — clearly, in your own words — "
      'whether it is time to book, or whether it is still early. Not when '
      "you've booked."),
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
      "you start trying — nothing urgent, nothing you have to rush."),
  steps: [
    JourneyStep(
      question: _en('What should I be eating, and what should I cut out?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Eating before pregnancy'),
          value: _en('What to add, what to cut back on, and what actually '
              "matters versus what's just advice."),
          surfaceId: 'ttc_nutrition',
        ),
      ],
    ),
    JourneyStep(
      question: _en('What tests and vaccinations are worth doing first?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('The pre-pregnancy checklist'),
          value: _en('Blood tests, vaccinations and screenings worth '
              'getting done before, not after.'),
          surfaceId: 'ttc_tests',
        ),
      ],
    ),
    JourneyStep(
      question: _en('Should I start folic acid or anything else now?'),
      elements: [
        JourneyElement(
          type: SolutionType.product,
          title: _en('Folic acid & preconception supplements'),
          value: _en('What is worth starting now, and how early it actually '
              'needs to start.'),
          surfaceId: 'ttc_supplements',
        ),
      ],
    ),
    JourneyStep(
      question: _en('Is my weight going to make a difference?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('A simple BMI check'),
          value: _en('Where you stand, and whether it is worth doing '
              'anything about before you start.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('What small habits actually help, day to day?'),
      elements: [
        JourneyElement(
          type: SolutionType.activity,
          title: _en('Habits worth building now'),
          value: _en('Sleep, movement and stress — the ordinary things that '
              'quietly help most.'),
          owed: true,
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
              "what's actually worth doing first."),
          action: kTtcActConsult,
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when your diet, tests and supplements are '
      "sorted, and you know there's nothing urgent left to do before you "
      'start trying.'),
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
  intro: _en('Fertility is often a shared picture, not just hers. Here is '
      "what's actually known about sperm health — written so either of you "
      'can read it.'),
  steps: [
    JourneyStep(
      question: _en('Is this even about him, or could it be both of us?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en("Whose 'side' is it, really"),
          value: _en('In roughly a third of cases the factor is his, a '
              "third hers, a third both or unclear."),
          owed: true,
        ),
      ],
      note: _en("Nothing here is about deciding who's 'the reason'. It's "
          'rarely just one person.'),
    ),
    JourneyStep(
      question: _en('What actually affects sperm health?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Heat, habits and time'),
          value: _en('Smoking, alcohol, heat, weight and stress — what the '
              'evidence says moves the number, and by how much.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('Is this something worth testing?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('What a semen analysis actually involves'),
          value: _en("A common, quick test — what it checks, and why it's "
              'nothing to be embarrassed about.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('What can we actually change, starting now?'),
      elements: [
        JourneyElement(
          type: SolutionType.course,
          title: _en('The half nobody talks about'),
          value: _en('A short course on the lifestyle changes that '
              'genuinely move the needle.'),
          surfaceId: 'ttc_prepare',
        ),
        JourneyElement(
          type: SolutionType.product,
          title: _en('Supplements worth considering'),
          value: _en("A short, honest list — most of what's sold here does "
              'very little.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en("We'd like to talk to someone about his results"),
      elements: [
        JourneyElement(
          type: SolutionType.consult,
          title: _en('Talk to a specialist'),
          value: _en('Book a 1:1 and go through his results in confidence, '
              'without it feeling like a verdict.'),
          action: kTtcActConsult,
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you both understand what actually '
      "affects sperm health, know whether testing is worth doing, and know "
      "what's genuinely worth changing — without either of you feeling "
      'blamed.'),
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
  title: _en('Understand recovery & trying again'),
  intro: _en("No rush here, and nothing you have to decide today. Just "
      "what's actually known, said plainly."),
  steps: [
    JourneyStep(
      question: _en('What does my body need to heal?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Physical recovery, in plain terms'),
          value: _en('What usually happens to your body in the weeks '
              'after, and roughly how long it takes.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('When — if ever — is it safe to try again?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('On trying again'),
          value: _en('What doctors usually advise about timing, and why it '
              'is a guideline rather than a rule.'),
          owed: true,
        ),
      ],
      note: _en('This is a guideline, not a deadline.'),
    ),
  ],
  closesWhen: _en("This closes when you know roughly what your body is "
      "doing right now, and that there's no clock you have to beat."),
);

/// Every TTC journey, keyed by the door that opens it.
final Map<String, JourneyConfig> kTtcJourneys = {
  for (final j in [
    kTtcImproveChances,
    kTtcPcosLibrary,
    kTtcFertilityReadinessCheck,
    kTtcPreconceptionReadiness,
    kTtcSpermHealth,
    kTtcLossRecoveryLibrary,
  ])
    j.doorId: j,
};
