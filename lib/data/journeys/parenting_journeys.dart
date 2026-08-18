// =============================================================================
//  Parenting journeys — what happens inside a door
// -----------------------------------------------------------------------------
//  See `journey_config.dart` for the rules. The two that matter most:
//
//    · every step heading is HER question, never our category;
//    · there is NO template — these come out different lengths and shapes on
//      purpose, and if two journeys look the same, one of them is wrong.
//
//  ⚠️ TWO DOORS IN THIS FILE ARE ABOUT THE MOTHER, NOT THE CHILD.
//  `kPpActMaternalConcern` and `kPpActMaternalRecovery` say "you"/"your"
//  throughout — never "your child". Parenting content in this app is
//  overwhelmingly baby-centric; these two doors are the correction, and
//  letting the baby back in in this file would undo the point of the hub
//  that houses them (see `kPpMaternal` in `parenting_hubs.dart`).
//
//  ⚠️ POTTY TRAINING IS WHERE PARENTS FEEL JUDGED. No age, no "by now", no
//  language that lets a step read as a milestone she has missed. See
//  `kPpReadyForPotty` below for how "not yet" stays a real, non-failure close.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import '../../localization/app_language.dart';
import '../../screens/brackets/hub/hub_solution_cards.dart';
import '../../screens/brackets/hub/journey_config.dart';
import '../hubs/parenting_hubs.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  A SEVENTH DOOR — "Explore a tradition" currently opens the WRONG SCREEN
// -----------------------------------------------------------------------------
//  `kPpTraditional` in `parenting_hubs.dart` wires its one door as
//  `surfaceId: 'pp_nuskhe'`. `NuskheScreen` (see
//  `lib/screens/post_pregnancy/nuskhe_screen.dart`) is real and live, but it is
//  a home-remedy lookup for ILLNESS — its own placeholder text reads "Try a
//  situation like 'cold', 'colic', 'teething' or 'sleep'". A mother who taps
//  "Explore a tradition" wanting to understand Annaprashan or mundan lands on a
//  screen built to answer a completely different question. That is the exact
//  "wrong screen" failure `pp_surface_router.dart` exists to avoid — it just
//  wasn't caught here because `pp_nuskhe` genuinely IS live, so nothing about
//  the wiring looks broken.
//
//  This file cannot fix `parenting_hubs.dart` — out of scope for this change —
//  so it declares the correct action and leaves the retarget as a note for
//  whoever wires this journey in:
//
//  ⚠️ INTEGRATOR TODO: in `lib/data/hubs/parenting_hubs.dart`, change
//  `kPpTraditional`'s single `HubNeed` from `surfaceId: 'pp_nuskhe'` to
//  `action: kPpActTradition` (import this file to reach the constant). Until
//  that one-line change lands, the door still opens the illness screen and
//  this journey is unreachable.
const String kPpActTradition = 'pp_tradition';

// -----------------------------------------------------------------------------
//  Is my child ready? — THREE steps, and "not yet" is a real ending
// -----------------------------------------------------------------------------
//  Persona: she is watching for signs because everyone around her already
//  seems to have started, and the anxiety is comparison, not confusion. The
//  bracket table marks every layer here `notReady` (see
//  `parenting_brackets.dart` §6), so nothing below is live except the one
//  place she can go while she waits.
//
//  ⚠️ NO AGE ANYWHERE IN THIS JOURNEY. Every line is a behaviour she can
//  actually see today, never a number of months. The tool in step two is
//  explicitly "not a test" — it produces a private read, not a score, and
//  "not yet" coming out of it is not a worse result than "ready".
final JourneyConfig kPpReadyForPotty = JourneyConfig(
  doorId: kPpActPottyReadiness,
  title: _en('Is my child ready?'),
  intro: _en("There isn't one right age for this. Here is what actually "
      'tells you it is time — and what to do if it is not, yet.'),
  steps: [
    JourneyStep(
      question: _en('What are the real signs, not the age?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('The signs that actually matter'),
          value: _en('Staying dry for longer, telling you before or after, '
              'showing interest in the bathroom — not a birthday.'),
          owed: true,
        ),
      ],
      note: _en('Nothing here is about how your child compares to anyone '
          "else's."),
    ),
    JourneyStep(
      question: _en('Can I check this myself, honestly?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('A private check, not a test'),
          value: _en("A few honest questions about what you're seeing at "
              'home — no score, no pass or fail.'),
          owed: true,
        ),
      ],
      note: _en("'Not yet' is a genuine answer here, not a setback."),
    ),
    JourneyStep(
      question: _en("What if we're not there yet?"),
      elements: [
        JourneyElement(
          type: SolutionType.activity,
          title: _en('Something to do together in the meantime'),
          value: _en("Play that builds the small skills this needs, at "
              "your child's own pace — not a countdown."),
          surfaceId: 'pp_development',
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you know what to actually watch for, '
      "have an honest read on where your child is today, and know that "
      "'not yet' is a fine place to be — with something worth doing while "
      'you wait.'),
);

// -----------------------------------------------------------------------------
//  Start & manage potty training — FOUR steps, and a product waits its turn
// -----------------------------------------------------------------------------
//  Persona: she has decided to start (or already started) and needs a method,
//  a way to handle the bad days, and to know night training is a separate,
//  later thing rather than a sign the whole approach failed.
//
//  ⚠️ A PRODUCT APPEARS LAST, NOT FIRST — the rule that a product belongs only
//  after a need is established. It is also `owed`, not `surfaceId:
//  'pp_products'`: the live catalogue's categories are Sleep, Skincare,
//  Feeding, Play & Development, Health & Safety and On the move (see
//  `pp_products_data.dart`) — there is no Potty category yet, so pointing her
//  at the general catalogue would drop her among nappies and lotions with
//  nothing to actually compare. That is the same "wrong screen" trap the
//  tradition door fell into above; `owed: true` says so honestly instead.
final JourneyConfig kPpStartPottyTraining = JourneyConfig(
  doorId: kPpActPottyTraining,
  title: _en('Start & manage potty training'),
  intro: _en('A plan that survives a bad week is worth more than a perfect '
      'first day.'),
  steps: [
    JourneyStep(
      question: _en('How do I actually start?'),
      elements: [
        JourneyElement(
          type: SolutionType.course,
          title: _en('A method you can start this week'),
          value: _en('One simple, step-by-step approach — not eleven '
              'contradictory ones from eleven relatives.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en("What do I do when there's an accident?"),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Accidents and setbacks, without the drama'),
          value: _en('What actually helps in the moment, and what to never '
              'say — to your child, or to yourself.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('What about night training?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Night is its own thing'),
          value: _en('Why it usually settles later than daytime training, '
              'and how to know when to try it.'),
          owed: true,
        ),
      ],
      note: _en('Later is normal here — this is not a sign daytime training '
          "didn't work."),
    ),
    JourneyStep(
      question: _en('What will actually make this easier?'),
      elements: [
        JourneyElement(
          type: SolutionType.product,
          title: _en('Seats, step stools and what is worth buying'),
          value: _en("What genuinely helps, and what's a gimmick you can "
              'skip.'),
          owed: true,
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you have a method to start with this '
      'week, know accidents are part of the process rather than a failure, '
      'and know what actually helps at night and at the shops.'),
);

// -----------------------------------------------------------------------------
//  Prepare for school — TWO steps, and one of them is already live
// -----------------------------------------------------------------------------
//  Persona: school is a few months out and she wants to know what it will
//  actually expect, and something playful to build toward it now. The
//  bracket table calls the content layer here the single biggest gap in the
//  stage, so step one is owed — but `pp_activities` genuinely answers step
//  two today (`kPpEarlyLearning`'s own "Something to do today" door uses the
//  same surface), so this journey gets to close on something real.
final JourneyConfig kPpPrepareForSchool = JourneyConfig(
  doorId: kPpActSchoolReadiness,
  title: _en('Prepare for school'),
  intro: _en("Not academics before it's time — the habits that make the "
      'first weeks land softly.'),
  steps: [
    JourneyStep(
      question: _en('What does school actually expect, on day one?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('What schools actually look for'),
          value: _en('Following a simple instruction, separating for a few '
              'hours, using words for needs — not letters and numbers yet.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('What can we practise at home, playfully?'),
      elements: [
        JourneyElement(
          type: SolutionType.activity,
          title: _en('Something to try today'),
          value: _en("Small play that builds exactly these habits, matched "
              "to your child's age."),
          surfaceId: 'pp_activities',
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you know what school will actually '
      'expect on day one, and have something playful to try at home before '
      'then.'),
);

// -----------------------------------------------------------------------------
//  Follow my First 40 Days — TWO steps, and it resists padding on purpose
// -----------------------------------------------------------------------------
//  Persona: newborn and days-old-mother at once, looking for a shape to the
//  weeks rather than a schedule. The bracket doc's own note says this hub is
//  close to bespoke UI and has "one live thing — a recorded masterclass" that
//  is not individually deep-linkable (see `kPpActFirst40Days`'s comment in
//  `parenting_hubs.dart` — `surfaceId: 'pp_courses'` would silently open the
//  WHOLE course catalogue, the same wrong-screen trap noted twice already
//  above). So step one stays honest rather than half-linking to the wrong
//  thing, and step two is where this journey earns a live element: it hands
//  off to `kPpActMaternalRecovery`, the door that exists precisely so her own
//  healing does not get lost inside a journey about the baby.
final JourneyConfig kPpFollowFirst40Days = JourneyConfig(
  doorId: kPpActFirst40Days,
  title: _en('Follow my First 40 Days'),
  intro: _en('Day by day through the weeks everyone forgets to plan for — '
      'for your baby, and for you.'),
  steps: [
    JourneyStep(
      question: _en('What does each day actually involve?'),
      elements: [
        JourneyElement(
          type: SolutionType.course,
          title: _en('A day-by-day companion'),
          value: _en("Feeding, healing, visitors and what's normal — "
              'walked through a day at a time.'),
          owed: true,
        ),
      ],
      note: _en('A recorded class touching this already exists in the '
          'course library; a dedicated day-by-day guide does not, yet.'),
    ),
    JourneyStep(
      question: _en('What about my own healing, alongside all this?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en("Your own recovery, not just the baby's"),
          value: _en("What's normal for your body and your mood in these "
              'same weeks.'),
          action: kPpActMaternalRecovery,
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you know roughly what each stretch of '
      'days holds, for your baby and for you — not a schedule to fall '
      'behind on, a shape to expect.'),
);

// -----------------------------------------------------------------------------
//  Get help with a recovery concern — THREE steps, and it ends at a person
// -----------------------------------------------------------------------------
//  Persona: pain, bleeding or a mood that doesn't feel right, and she is
//  trying to work out alone whether it's serious. This is her, not the baby,
//  throughout — see the file header.
//
//  ⚠️ NEVER A DIAGNOSIS. Step one only widens or narrows worry; it never
//  names what she has. Both closing elements route to an actual person —
//  booked or searched — because that is the only honest answer to "is this
//  serious", and this hub's own closing offer already says so
//  (`kPpMaternal.closing` in `parenting_hubs.dart`).
final JourneyConfig kPpMaternalConcern = JourneyConfig(
  doorId: kPpActMaternalConcern,
  title: _en('Get help with a recovery concern'),
  intro: _en("Pain, bleeding, your mood, or something that just doesn't "
      "feel right — you shouldn't have to work out alone whether it's "
      'serious.'),
  steps: [
    JourneyStep(
      question: _en('Is what I am feeling usual?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en("What's usual after birth, and what isn't"),
          value: _en('Bleeding, pain and mood — the ranges that are '
              'ordinary, and roughly where they stop being ordinary.'),
          owed: true,
        ),
      ],
      note: _en('Nothing here is about your own body specifically. If in '
          'doubt, the next step is faster than reading further.'),
    ),
    JourneyStep(
      question: _en('Who do I actually tell about this?'),
      elements: [
        JourneyElement(
          type: SolutionType.consult,
          title: _en('Talk to someone now'),
          value: _en('A 1:1 with someone who can hear the specific thing '
              "you're feeling and tell you what it means."),
          action: kPpActConsult,
        ),
      ],
      note: _en('This is never a diagnosis — it is a fast way to find out '
          'if what you are feeling needs attention today.'),
    ),
    JourneyStep(
      question: _en('What if I would rather just find someone nearby?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('People who work with new mothers'),
          value: _en('Search for postpartum-focused support near you, '
              "without booking anything yet."),
          surfaceId: 'pp_find_help',
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you know whether what you are feeling '
      'is usual, and have either talked to someone or found someone you can '
      'reach when you are ready.'),
);

// -----------------------------------------------------------------------------
//  Understand my recovery — THREE steps, and it never routes to a consult
// -----------------------------------------------------------------------------
//  Persona: not alarmed, just trying to understand what her body is doing
//  week to week. Deliberately the calmer sibling of `kPpMaternalConcern`
//  above — same hub, same "you" throughout, but this one closes by pointing
//  at the worried door rather than by booking anyone, exactly the way
//  pregnancy's skin-concern journey closes without a consult on purpose (see
//  `pregnancy_journeys.dart`).
//
//  ⚠️ STEP ONE IS LIVE. `kPpActMaternalRecovery` already resolves to
//  `ReadingHomeScreen(initialCollection: 'The Parent, Too')` — the one
//  reading collection actually about her, not the baby (see the case in
//  `pp_home_v3.dart`). Reusing the door's own action here is the same
//  pattern pregnancy's condition journey uses for `kPgActTrackReadings`: an
//  element pointing at a real, already-wired destination.
final JourneyConfig kPpUnderstandMyRecovery = JourneyConfig(
  doorId: kPpActMaternalRecovery,
  title: _en('Understand my recovery'),
  intro: _en('What your body and your mood are actually doing right now — '
      'written for you, not for your baby.'),
  steps: [
    JourneyStep(
      question: _en('What is actually normal for my body right now?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Written for you, not the baby'),
          value: _en('Bleeding, healing, hormones and mood, week by week '
              "after birth — the collection that's actually about you."),
          action: kPpActMaternalRecovery,
        ),
      ],
    ),
    JourneyStep(
      question: _en('How does this change over the weeks?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('A week-by-week shape'),
          value: _en("What's ordinary in week one looks different by week "
              'six — a rough shape, not a schedule to keep pace with.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('Is there something I can track, quietly?'),
      elements: [
        JourneyElement(
          type: SolutionType.tool,
          title: _en('A simple, private log'),
          value: _en('Bleeding, mood, sleep — a place to notice a pattern '
              'for yourself, not to report to anyone.'),
          owed: true,
        ),
      ],
      note: _en('If something here feels off rather than merely uncertain, '
          '"Get help with a recovery concern" is the door that routes you '
          'to a person.'),
    ),
  ],
  closesWhen: _en('This closes when you know what is normal for you this '
      'week and roughly how that will shift over the next few — with '
      'somewhere to go if it stops feeling merely uncertain.'),
);

// -----------------------------------------------------------------------------
//  Explore a tradition — FOUR steps, and almost none of it exists yet
// -----------------------------------------------------------------------------
//  Persona: Annaprashan, mundan, the first oil massage, a naming day — an
//  event her own family assumes she already understands, and she would
//  rather ask an app than admit she doesn't. See the header note above:
//  this door currently opens `pp_nuskhe`, an illness-remedy screen, so
//  everything here is a genuine gap rather than an under-used capability.
//
//  ⚠️ EVERYTHING IS `owed`. `pp_names` (BabyNamingHomeScreen) sits nearby in
//  spirit but answers a different question — choosing a name, not what a
//  naming ceremony means or whether to hold one — so reusing it here would
//  repeat the exact wrong-screen mistake this journey exists to correct.
//  Nothing else in the parenting surface list answers "what does this
//  tradition mean" at all.
final JourneyConfig kPpExploreTradition = JourneyConfig(
  doorId: kPpActTradition,
  title: _en('Explore a tradition'),
  intro: _en('Annaprashan, mundan, the first oil massage, a naming day — '
      'the days everyone assumes you already understand.'),
  steps: [
    JourneyStep(
      question: _en('What does each of these actually mean?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Annaprashan, mundan, malish and naming, plainly '
              'explained'),
          value: _en('What each tradition marks, and roughly when families '
              'tend to do it — without assuming you already know.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('Is any of this backed by evidence, or is it just '
          'custom?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('Held up against what is actually known'),
          value: _en("Where a tradition lines up with what paediatricians "
              "say today, and where it's simply culture — both are fine "
              'things to know.'),
          owed: true,
        ),
      ],
      note: _en('This never tells you what to do. It tells you what is '
          'actually known, so the choice stays yours.'),
    ),
    JourneyStep(
      question: _en('What if my family wants this and I am not sure?'),
      elements: [
        JourneyElement(
          type: SolutionType.read,
          title: _en('When the pressure is the hard part, not the ritual'),
          value: _en('How to navigate a tradition you are unsure about, '
              'without a fight at a family gathering.'),
          owed: true,
        ),
      ],
    ),
    JourneyStep(
      question: _en('How do I actually plan the day, if we are doing it?'),
      elements: [
        JourneyElement(
          type: SolutionType.activity,
          title: _en('A simple checklist for the day itself'),
          value: _en('What families typically arrange — priest, food, who '
              "to invite — so nothing's a last-minute scramble."),
          owed: true,
        ),
      ],
    ),
  ],
  closesWhen: _en('This closes when you know what a tradition actually '
      'means, what is evidence and what is custom, and have a simple way '
      'to plan the day if you choose to mark it.'),
);

/// Every parenting journey, keyed by the door that opens it.
final Map<String, JourneyConfig> kParentingJourneys = {
  for (final j in [
    kPpReadyForPotty,
    kPpStartPottyTraining,
    kPpPrepareForSchool,
    kPpFollowFirst40Days,
    kPpMaternalConcern,
    kPpUnderstandMyRecovery,
    kPpExploreTradition,
  ])
    j.doorId: j,
};
