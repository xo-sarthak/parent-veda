// =============================================================================
//  Parenting problem hubs — all eleven parenting brackets
// -----------------------------------------------------------------------------
//  Doors come from the approved parenting door audit (11 hubs, one door count
//  and one wording per hub — not invented here). See docs/HUB-BUILD-SPEC.md for
//  the contract and lib/data/hubs/pregnancy_hubs.dart for the worked exemplar
//  this file mirrors.
//
//  ⚠️ ENGLISH ONLY. `_en(...)` = English now, Hindi owed.
//
//  ⚠️ PARENTING'S GAP SHAPE IS THE OPPOSITE OF PREGNANCY'S — see
//  lib/data/brackets/parenting_brackets.dart. Content and commerce mostly
//  exist; three brackets (Potty training, Early learning, First 40 days) are
//  almost entirely unbuilt. Their doors below use `action` constants rather
//  than a `surfaceId`, on purpose — forcing a surface onto them would be the
//  "wrong screen" failure the router file explicitly exists to avoid.
// =============================================================================

import '../../localization/app_language.dart';
import '../../screens/brackets/hub/hub_config.dart';
import '../../screens/brackets/hub/hub_intent_art.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// Actions this stage's router does not (yet, or ever) resolve to a plain
// surface — a door uses `surfaceId` when an existing pp_ screen answers it
// exactly, and an `action` when the destination needs a decision the router
// cannot make on an id alone, or does not exist yet.
//
// ⚠️ kPpActConsult IS SHARED ACROSS EVERY CONSULT DESTINATION IN THIS FILE —
// same pattern as `kPgActConsult` in pregnancy_hubs.dart. `ProviderResultsScreen`
// takes an optional `need` filter that a bare surfaceId cannot express (a
// lactation consult and a pelvic-floor consult are not the same booking), so
// the integrator resolves the right need per hub context from one action name.
/// The three doors that land on the What Changed library, each carrying its
/// own topic so she arrives filtered rather than searching for what she just
/// tapped.
/// Her own recovery reading. Pointed at the one collection about the mother,
/// because the library's default hero is about the baby.
/// Rituals — Annaprashan, mundan, malish. Defined in parenting_journeys.dart
/// too; re-exported here so the hub compiles without importing journeys.
const String kPpActTradition = 'pp_tradition';

const String kPpActMaternalRecovery = 'pp_maternal_recovery';

const String kPpActSleepProblem = 'pp_sleep_problem';
const String kPpActFeedingProblem = 'pp_feeding_problem';
const String kPpActBehaviour = 'pp_behaviour';

const String kPpActConsult = 'pp_consult';

// Potty training has almost nothing built (see parenting_brackets.dart §6):
// content, activities, tools and course are all `notReady`. Both doors need a
// destination the integrator has to build from scratch.
const String kPpActPottyReadiness = 'pp_potty_readiness';
const String kPpActPottyTraining = 'pp_potty_training';

// Early learning's content layer is the single biggest gap in the stage by
// search demand (montessori-at-home, good habits, moral stories — see
// parenting_brackets.dart §7) and nothing answers "prepare for school" today.
const String kPpActSchoolReadiness = 'pp_school_readiness';

// First 40 days has one live thing — a recorded masterclass reachable through
// the general `pp_courses` catalogue — and nothing resembling the day-by-day
// structure the bracket doc says is missing. `surfaceId: 'pp_courses'` would
// silently open the WHOLE parent course catalogue rather than that one class,
// which is exactly the "wrong screen" failure the router avoids elsewhere, so
// this stays an action until a dedicated First 40 Days journey exists.
const String kPpActFirst40Days = 'pp_first_40_days';

// Maternal recovery has no mother-facing "something feels off" tool.
// `pp_what_changed` is the closest existing thing in shape, but it is built
// and worded for the BABY (WhatChangedScreen fills `{baby}` into every
// concern) — routing a postpartum mother's own concern through it would be
// the wrong audience behind a right-shaped screen, the same trap the early
// learning bracket doc calls out for `pp_courses`.
const String kPpActMaternalConcern = 'pp_maternal_concern';

// -----------------------------------------------------------------------------
//  Sleep — 2 doors
// -----------------------------------------------------------------------------
//  The tracker (`pp_sleep`) and the diagnostic library (`pp_what_changed`,
//  which the bracket table already lists as this hub's second tool) split
//  cleanly along the two doors: one is "something's wrong tonight", the other
//  is "show me the pattern". A sleep-expert consult is a genuinely good
//  closing offer, but only at the foot — never a third door competing with
//  the two reasons she actually opened the app for.
final HubConfig kPpSleep = HubConfig(
  bracketId: 'parenting_sleep',
  template: HubTemplate.trackerLed,
  coreQuestion: "Is my child's sleep a problem right now, and how do I "
      'actually see what is happening?',
  hero: _en('Sleep, understood rather than chased.'),
  heroSupport: _en("What's keeping the night hard right now, and a calm "
      "record of how it's actually going."),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Help my child sleep'),
      blurb: _en("Search what's going on tonight: a regression, a wake "
          'window, a fussy bedtime, and what usually helps.'),
      mark: IntentMark.bodyMark,
      hue: 344,
      action: kPpActSleepProblem,
    ),
    HubNeed(
      label: _en('Track & understand sleep'),
      blurb: _en('Log naps and nights, watch a pattern emerge, and get '
          'gentle age context, with no target to hit.'),
      mark: IntentMark.chartLog,
      hue: 232,
      surfaceId: 'pp_sleep',
    ),
  ],
  closing: HubClosing(
    label: _en('Talk to a sleep expert'),
    blurb: _en('Book a 1:1 if the nights are wearing you down more than the '
        'day can fix.'),
    action: kPpActConsult,
  ),
);

// -----------------------------------------------------------------------------
//  Feeding — 2 doors
// -----------------------------------------------------------------------------
//  Same split as Sleep: a problem to search versus a plan to follow. The
//  closing offer is a lactation consultant rather than a generic doctor —
//  the bracket doc calls this "the most certain sale" in the stage, and it is
//  also the genuinely right person for what this door actually asks for.
final HubConfig kPpFeeding = HubConfig(
  bracketId: 'parenting_feeding',
  template: HubTemplate.trackerLed,
  coreQuestion: 'Is there a feeding problem to solve, or a plan to make for '
      'what my child eats?',
  hero: _en('Feeding, without the guesswork.'),
  heroSupport: _en("What's going wrong right now, and what your child "
      'actually needs to eat at this age.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Solve a feeding problem'),
      blurb: _en('Latch trouble, supply worries, a fussy eater. Search it '
          'and see what usually helps.'),
      mark: IntentMark.bodyMark,
      hue: 344,
      action: kPpActFeedingProblem,
    ),
    HubNeed(
      label: _en('Plan what my child eats'),
      blurb: _en('What to feed, when to start solids, and recipes you will '
          'actually make.'),
      mark: IntentMark.feedMark,
      hue: 104,
      surfaceId: 'pp_food',
    ),
  ],
  closing: HubClosing(
    label: _en('Talk to a lactation expert'),
    blurb: _en('Book a 1:1 about latch, supply, or the switch to solids.'),
    action: kPpActConsult,
  ),
);

// -----------------------------------------------------------------------------
//  Health & illness — 1 door, opens directly
// -----------------------------------------------------------------------------
//  ⚠️ SPEED MATTERS MOST HERE. No consult upsell in the way, no commerce — a
//  worried parent needs the answer, not an offer. `pp_health` already routes
//  straight to `WhatChangedScreen` for exactly this reason (see
//  pp_surface_router.dart: dropping her into a records category she has not
//  chosen would be the wrong-screen failure the router exists to avoid).
final HubConfig kPpHealth = HubConfig(
  bracketId: 'parenting_health',
  template: HubTemplate.immediateAnswer,
  coreQuestion: 'Is this normal, and does it need a doctor?',
  hero: _en('Whatever is worrying you about your child right now.'),
  heroSupport: _en('A fast, calm answer, and when it is time to call the '
      'doctor.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('My child is unwell'),
      blurb: _en('Fever, rash, a cough. Search it now and see what it '
          'usually means, and what to watch for.'),
      mark: IntentMark.bodyMark,
      hue: 344,
      // ⚠️ WAS 'pp_health', which routed to the generic What Changed search.
      // The review was "I don't like current section, rebuild", and the rebuilt
      // thing is the Health section: triage first, then the illness content that
      // was missing entirely. What Changed is still reachable, as area 7 inside
      // it, which is where a search across everything actually belongs.
      surfaceId: 'pp_section/parenting_health',
    ),
  ],
);

// -----------------------------------------------------------------------------
//  Milestones & development — 2 doors
// -----------------------------------------------------------------------------
//  `pp_milestones` (MilestoneJourneyScreen — "emerging", never "delayed") is
//  the checking door; `pp_development` (DevelopmentHomeScreen — today's
//  activities, the four windows) is the helping door. Both are already live
//  and already distinct screens, so the split costs nothing to build.
final HubConfig kPpDevelopment = HubConfig(
  bracketId: 'parenting_development',
  template: HubTemplate.longTermDevelopment,
  coreQuestion: 'Is my child on track, and what can I do to help them '
      'along?',
  hero: _en('Watching your child grow, without the scoreboard.'),
  heroSupport: _en('What is emerging, what helps, and when a concern is '
      'worth a second look.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en("Check my child's development"),
      blurb: _en("See what's emerging, what's next, and celebrate it, "
          'never a test, never a score.'),
      mark: IntentMark.checkMark,
      hue: 160,
      // ⚠️ WAS 'pp_milestones', the milestone tracker alone.
      //
      // The rebuilt Development section is what this door promises: on-track
      // reassurance, the skill windows, speech and language, and what to do
      // about any of it. The milestone tracker is one answer inside it and is
      // linked from eight pages, so nothing is lost and the door now opens the
      // whole question rather than one tool.
      surfaceId: 'pp_section/parenting_development',
    ),
    HubNeed(
      label: _en('Help my child develop'),
      blurb: _en("Small, joyful activities matched to exactly where your "
          'child is right now.'),
      mark: IntentMark.stepsMark,
      hue: 268,
      surfaceId: 'pp_development',
    ),
  ],
  closing: HubClosing(
    label: _en('Talk to a specialist'),
    blurb: _en('Book a 1:1 if something feels off track. A second, '
        'reassuring opinion.'),
    action: kPpActConsult,
  ),
);

// -----------------------------------------------------------------------------
//  Behaviour & psychology — 1 door, opens directly
// -----------------------------------------------------------------------------
//  The bracket table is honest that there is no dedicated behaviour content:
//  the eight behaviour concerns already living inside `pp_what_changed` are
//  the only real depth here, so the single door goes straight to them.
final HubConfig kPpBehaviour = HubConfig(
  bracketId: 'parenting_behaviour',
  template: HubTemplate.immediateAnswer,
  coreQuestion: 'What is behind this behaviour, and how do I handle it '
      'calmly?',
  hero: _en('The behaviour you are trying to understand right now.'),
  heroSupport: _en('What is actually going on underneath, and what '
      'genuinely helps.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Handle a behaviour'),
      blurb: _en('Tantrums, biting, sharing, screens. Search it and see '
          'what is actually going on underneath.'),
      mark: IntentMark.bodyMark,
      hue: 344,
      action: kPpActBehaviour,
    ),
  ],
);

// -----------------------------------------------------------------------------
//  Potty training — 2 doors
// -----------------------------------------------------------------------------
//  ⚠️ NOTHING IS BUILT HERE. The bracket table marks content, activities,
//  tools and course all `notReady` — this hub is two sentences in a phase
//  description today. Both doors are declared with real marks, hues and
//  promises anyway, per §3 of the spec: the config is where the destination
//  is decided even before it exists. No closing consult — the bracket calls
//  the need here "Light", and an unnecessary booking offer on a two-sentence
//  hub would make the gap worse, not better.
final HubConfig kPpPotty = HubConfig(
  bracketId: 'parenting_potty',
  template: HubTemplate.learnAndPlan,
  coreQuestion: 'Is my child ready, and how do I actually start and stick '
      'with it?',
  hero: _en('Getting ready for potty training, at your own pace.'),
  heroSupport: _en('The real signs of readiness, and a method that will '
      'not fall apart after one setback.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Is my child ready?'),
      blurb: _en('The real signs to look for, so you start at the right '
          'time, not just when everyone else does.'),
      mark: IntentMark.checkMark,
      hue: 42,
      // Nothing renders here yet — see kPpActPottyReadiness above.
      action: kPpActPottyReadiness,
    ),
    HubNeed(
      label: _en('Start & manage potty training'),
      blurb: _en('A method that suits your child, night training, and what '
          'to do after a setback.'),
      mark: IntentMark.seatMark,
      hue: 160,
      // Nothing renders here yet — see kPpActPottyTraining above.
      action: kPpActPottyTraining,
    ),
  ],
);

// -----------------------------------------------------------------------------
//  Early learning & school readiness — 2 doors
// -----------------------------------------------------------------------------
//  ⚠️ THE `pp_courses` TRAP. The bracket doc is explicit that `learning_*`
//  screens are the PARENT course catalogue, not child-directed learning
//  content — mapping "Prepare for school" onto it would be the wrong audience
//  behind a right-sounding label. `pp_activities` genuinely fits "Something
//  to do today" (DevelopmentHomeScreen already renders "Try together today");
//  "Prepare for school" has nothing real to open, so it stays an action. No
//  closing — course is `notReady` and consult is `notCore` for this bracket.
final HubConfig kPpEarlyLearning = HubConfig(
  bracketId: 'parenting_early_learning',
  template: HubTemplate.learnAndPlan,
  coreQuestion: 'What can I do today, and how do I get my child ready for '
      'school?',
  hero: _en('The learning that happens outside a classroom.'),
  heroSupport: _en('A small thing to try today, and the habits that make '
      'school an easier landing.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Something to do today'),
      blurb: _en("A small activity matched to your child's age: playful, "
          'and never a worksheet.'),
      mark: IntentMark.blocksMark,
      hue: 42,
      surfaceId: 'pp_activities',
    ),
    HubNeed(
      label: _en('Prepare for school'),
      blurb: _en('The habits and skills school actually expects, built '
          'gently at home first.'),
      mark: IntentMark.schoolMark,
      hue: 206,
      // Nothing renders here yet — see kPpActSchoolReadiness above.
      action: kPpActSchoolReadiness,
    ),
  ],
);

// -----------------------------------------------------------------------------
//  First 40 days — 1 door, opens directly
// -----------------------------------------------------------------------------
//  ⚠️ A CANDIDATE FOR BESPOKE UI, NOT THE GENERIC RENDERER. `HubConfig`'s own
//  file says a hub that "genuinely needs bespoke UI" can render its own body
//  rather than the generic doors-first shape, and names this bracket as an
//  example. The single door is still declared here, per §3 — the destination
//  is a decision this file makes even though nothing behind it is built yet.
final HubConfig kPpFirst40 = HubConfig(
  bracketId: 'parenting_first_40',
  template: HubTemplate.firstFortyDays,
  coreQuestion: 'What does day by day actually look like in the first '
      'forty days?',
  hero: _en('The forty days after birth, one day at a time.'),
  heroSupport: _en('Newborn care and your own healing, so neither gets '
      'forgotten.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Follow my First 40 Days'),
      blurb: _en('Newborn care and your own recovery, day by day, for the '
          'weeks everyone forgets to plan for.'),
      mark: IntentMark.nextStep,
      hue: 26,
      // Nothing built beyond a recorded masterclass — see kPpActFirst40Days.
      action: kPpActFirst40Days,
    ),
  ],
);

// -----------------------------------------------------------------------------
//  Maternal & postpartum recovery — 2 doors
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS HER RECOVERY, NOT THE BABY'S. Every blurb below says "you", not
//  "your child" — the one hub in the stage that is deliberately not about the
//  baby. `pp_read` genuinely covers this ground (the bracket's content layer
//  is `live(['pp_read', 'pp_watch'])`); "get help with a concern" has no real
//  destination yet, and `pp_what_changed` is explicitly the wrong one — it is
//  built and worded for the baby. Closing is a consult, not a door: the two
//  hubs where consult IS a door are pregnancy-only (Infertility & IVF,
//  Pregnancy mental health).
final HubConfig kPpMaternal = HubConfig(
  bracketId: 'parenting_maternal',
  template: HubTemplate.learnAndPlan,
  coreQuestion: 'How am I actually healing, and where do I get help if '
      'something feels wrong?',
  hero: _en('Your own recovery matters here too.'),
  heroSupport: _en('What is normal as you heal, and where to go when '
      'something is not.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Understand my recovery'),
      blurb: _en('What is normal for your body and your mood, week by week '
          'after birth.'),
      mark: IntentMark.bodyMark,
      hue: 344,
      action: kPpActMaternalRecovery,
    ),
    HubNeed(
      label: _en('Get help with a recovery concern'),
      blurb: _en('Something that does not feel right: pain, mood, or your '
          'body, and what to do about it.'),
      mark: IntentMark.cuppedHands,
      hue: 288,
      // No mother-facing diagnostic tool exists yet — see
      // kPpActMaternalConcern above.
      action: kPpActMaternalConcern,
    ),
  ],
  closing: HubClosing(
    label: _en('Talk to someone about your own recovery'),
    blurb: _en('Book a 1:1 about the pelvic floor, healing, or simply how you are '
        'feeling.'),
    action: kPpActConsult,
  ),
);

// -----------------------------------------------------------------------------
//  Buying guides — 2 doors
// -----------------------------------------------------------------------------
//  ⚠️ THE ONE HUB WHERE COMMERCE IS THE JOB. `HubTemplate.decisionCommerce`,
//  and products are not filler here — the bracket table's own note calls this
//  "the app's strongest" bracket. `pp_product_guide` keeps ParentVeda's stance
//  of saying what to skip as readily as what to buy; `pp_products` is where
//  she actually compares and picks. No closing — course and consult are both
//  `notApplicable` for this bracket.
final HubConfig kPpBuying = HubConfig(
  bracketId: 'parenting_buying',
  template: HubTemplate.decisionCommerce,
  coreQuestion: 'What do I actually need, and how do I choose between the '
      'options?',
  hero: _en('Buying for your child, without the overwhelm.'),
  heroSupport: _en('What is genuinely worth it, what to skip, and how to '
      'choose between real options.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('What do I actually need?'),
      blurb: _en('A trust-first guide to what is genuinely worth buying, '
          'and what you can skip.'),
      mark: IntentMark.listMark,
      hue: 12,
      surfaceId: 'pp_product_guide',
    ),
    HubNeed(
      label: _en('Compare & choose'),
      blurb: _en('See real options side by side and pick with confidence, '
          'not guesswork.'),
      mark: IntentMark.compareMark,
      hue: 42,
      surfaceId: 'pp_products',
    ),
  ],
);

// -----------------------------------------------------------------------------
//  Traditional & cultural — 1 door, opens directly
// -----------------------------------------------------------------------------
//  `pp_nuskhe` is the bracket's only live content, already framed exactly
//  right for this door — remedies and rituals "held up honestly against
//  evidence" rather than dismissed or endorsed outright.
final HubConfig kPpTraditional = HubConfig(
  bracketId: 'parenting_traditional',
  template: HubTemplate.immediateAnswer,
  coreQuestion: 'What does this tradition mean, and is it something I '
      'should actually do?',
  hero: _en('The traditions everyone assumes you already know.'),
  heroSupport: _en('What each one means, and what the evidence actually '
      'says about it.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Explore a tradition'),
      blurb: _en('Annaprashan, mundan, malish and more. What they mean, '
          'and what the evidence actually says.'),
      mark: IntentMark.lampMark,
      hue: 206,
      // ⚠️ WAS pp_nuskhe, WHICH IS HOME REMEDIES FOR ILLNESS — cold, colic,
      // teething. Nothing about the wiring looked broken (the screen is real,
      // live and good), which is exactly why it slipped through: it shares the
      // 'traditional Indian wisdom' voice while answering a different question.
      // A parent looking up Annaprashan or mundan found zero results.
      action: kPpActTradition,
    ),
  ],
);

/// Every parenting hub — all eleven brackets.
final List<HubConfig> kParentingHubs = [
  kPpSleep,
  kPpFeeding,
  kPpHealth,
  kPpDevelopment,
  kPpBehaviour,
  kPpPotty,
  kPpEarlyLearning,
  kPpFirst40,
  kPpMaternal,
  kPpBuying,
  kPpTraditional,
];
