// =============================================================================
//  Pregnancy problem hubs — the nine besides Scans & tests
// -----------------------------------------------------------------------------
//  Doors come from PARENTVEDA_40_HUB_DOORS_REVISED.xlsx. See
//  docs/HUB-BUILD-SPEC.md for the contract and docs/SCANS-HUB-RECONCILIATION.md
//  for how the door test was arrived at.
//
//  ⚠️ Scans & tests is NOT here — it lives in `scans_hub_v2.dart` because it
//  carries a V1 alongside it for comparison. Nothing else has a V1 worth
//  comparing to, so nothing else has a toggle.
//
//  ⚠️ ENGLISH ONLY. `_en(...)` = English now, Hindi owed.
// =============================================================================

import '../../localization/app_language.dart';
import '../../screens/brackets/hub/hub_config.dart';
import '../../screens/brackets/hub/hub_intent_art.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// Actions this stage's router understands. A door uses `surfaceId` when an
// existing surface answers it exactly, and an `action` when the destination
// needs a decision the router cannot make on an id alone.
/// Skin concern journey — the one hub where a product is the honest answer.
const String kPgActSkinConcern = 'pg_skin_concern';

/// A flagged number at an appointment — iron, weight, a level.
const String kPgActNutritionFlag = 'pg_nutrition_flag';

/// The built Nutrition section: verdicts, stages, nutrients, recipes.
const String kPgActNutritionMain = 'pg_nutrition_main';

const String kPgActConsult = 'pg_consult';

/// ⚠️ ONE ACTION PER EXPERT, so the consult list arrives filtered to whoever
/// the card just named. See ConsultationsScreen.onlyRole for why.
const String kPgActConsultNutrition = 'pg_consult_nutrition';
const String kPgActConsultCounsellor = 'pg_consult_counsellor';
const String kPgActTrackReadings = 'pg_track_readings';
const String kPgActConditionLibrary = 'pg_condition_library';
const String kPgActBirthPrep = 'pg_birth_prep';

/// The birthing-class programme — a class, not a doctor.
///
/// Its own action rather than reusing `kPgActConsult`, because that reuse is
/// exactly how "Join a birthing class" ended up opening a gynaecologist's
/// booking page. Two different offers sharing one action is a bug waiting for
/// someone to write the wrong label next to it.
const String kPgActBirthClass = 'pg_birth_class';
const String kPgActMoodCheck = 'pg_mood_check';
const String kPgActFeelBetter = 'pg_feel_better';

// -----------------------------------------------------------------------------
//  Complications & conditions — 2 doors
// -----------------------------------------------------------------------------
//  ⚠️ "Get personalised help" was cut as a door and became the closing offer.
//  She arrives here to understand a diagnosis or to log a number; booking is
//  what is left when neither finished the job.
final HubConfig kPgComplications = HubConfig(
  bracketId: 'pregnancy_complications',
  template: HubTemplate.trackerLed,
  coreQuestion: 'What is this condition, and what do I have to do about it?',
  // ⚠️ COPY FIX, 2026-08-17. The old line — "The condition you have been
  // given a name for." — read like something written about her rather than
  // to her. This says the same thing the way a person would say it out loud.
  hero: _en('Something your doctor mentioned?'),
  heroSupport: _en('What it means, and what actually needs watching.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Understand my condition'),
      blurb: _en('What it is, how common it is, and what usually happens next.'),
      mark: IntentMark.bodyMark,
      hue: 344,
      action: kPgActConditionLibrary,
    ),
    HubNeed(
      // The repeated visit. GDM and raised BP are managed by logging, and a
      // number logged today is the reason she opens the app tomorrow.
      label: _en('Track my readings'),
      blurb: _en('Sugar, blood pressure or weight — logged, and easy to show '
          'at your next visit.'),
      mark: IntentMark.chartLog,
      hue: 206,
      action: kPgActTrackReadings,
    ),
  ],
  closing: HubClosing(
    label: _en('Talk to a doctor'),
    blurb: _en('Book a 1:1 and ask about your own readings.'),
    action: kPgActConsult,
  ),
);

// -----------------------------------------------------------------------------
//  Is it safe in pregnancy? — 1 door, opens directly
// -----------------------------------------------------------------------------
//  ⚠️ NO CLOSING CONSULT, DELIBERATELY. Nobody books a gynaecologist because
//  papaya was on the list. An offer here would make a two-second lookup feel
//  like the app wanted something.
final HubConfig kPgIsItSafe = HubConfig(
  bracketId: 'pregnancy_is_it_safe',
  template: HubTemplate.immediateAnswer,
  coreQuestion: 'Can I eat, take or do this while pregnant?',
  hero: _en('Can I eat, take or do this?'),
  heroSupport: _en('Look it up and get a straight answer.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Can I eat, take or do this?'),
      blurb: _en('Search the thing you are unsure about and get a plain '
          'answer, with the reason behind it.'),
      mark: IntentMark.questionMark,
      hue: 104,
      surfaceId: 'can_i',
    ),
  ],
);

// -----------------------------------------------------------------------------
//  Nutrition & diet — 2 doors
// -----------------------------------------------------------------------------
//  "Plan my meals" was cut: planning is HOW "what should I eat" is answered,
//  so it is a tool inside that door rather than a door beside it.
final HubConfig kPgNutrition = HubConfig(
  bracketId: 'pregnancy_nutrition',
  template: HubTemplate.immediateAnswer,
  coreQuestion: 'What should I be eating, and is this concern a problem?',
  hero: _en('Eating well, without the panic.'),
  heroSupport: _en('What to eat day to day, and what to do when something is '
      'flagged.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('What should I eat?'),
      blurb: _en('Everyday food, what to add this trimester, and recipes you '
          'will actually cook.'),
      mark: IntentMark.plate,
      hue: 104,
      // ⚠️ WAS `surfaceId: 'nutrition'`, WHICH IS THE PAID-CONSULT FUNNEL.
      // The destination audit found that screen runs a three-question quiz and
      // ends at "book a nutritionist", with the plan it promises after booking
      // being itself a coming-soon stub. A door asking "what should I eat?"
      // cannot be a sales funnel. It now opens the built Nutrition section.
      action: kPgActNutritionMain,
    ),
    HubNeed(
      // Anaemia, low weight gain, high weight gain — a flagged number is a
      // different visit from "what's for dinner".
      label: _en('Something has been flagged'),
      blurb: _en('Low iron, weight gain, or a level your doctor mentioned — '
          'what it means and what helps.'),
      mark: IntentMark.scaleMark,
      hue: 42,
      action: kPgActNutritionFlag,
    ),
  ],
  closing: HubClosing(
    label: _en('Talk to a nutritionist'),
    blurb: _en('Book a 1:1 about your own diet.'),
    action: kPgActConsultNutrition,
  ),
);

// -----------------------------------------------------------------------------
//  Symptoms & discomforts — 1 door, opens directly
// -----------------------------------------------------------------------------
final HubConfig kPgSymptoms = HubConfig(
  bracketId: 'pregnancy_symptoms',
  template: HubTemplate.immediateAnswer,
  coreQuestion: 'Is what I am feeling normal, and how do I make it stop?',
  hero: _en('Whatever you are feeling right now.'),
  heroSupport: _en('Whether it is usual, and what actually helps.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('I have a symptom'),
      blurb: _en('Find it, see whether it is usual at this stage, and what '
          'helps.'),
      mark: IntentMark.bodyMark,
      hue: 344,
      surfaceId: 'symptoms',
    ),
  ],
);

// -----------------------------------------------------------------------------
//  Labour & childbirth prep — 2 doors
// -----------------------------------------------------------------------------
//  "Create my birth plan" was cut as a door — it is a tool inside "Prepare for
//  birth". The bag stayed, because packing is a dated job she returns to.
final HubConfig kPgLabour = HubConfig(
  bracketId: 'pregnancy_labour',
  template: HubTemplate.immediateAnswer,
  coreQuestion: 'How do I get ready for the birth itself?',
  hero: _en('Getting ready for the birth.'),
  heroSupport: _en('What happens, what to decide beforehand, and what to '
      'carry.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Prepare for birth'),
      blurb: _en('What labour is actually like, your options, and the birth '
          'plan to take with you.'),
      mark: IntentMark.nextStep,
      hue: 26,
      action: kPgActBirthPrep,
    ),
    HubNeed(
      label: _en('Pack my hospital bag'),
      blurb: _en('What to pack for you, the baby and whoever comes with you.'),
      mark: IntentMark.bagMark,
      hue: 160,
      surfaceId: 'hospital_bag',
    ),
  ],
  closing: HubClosing(
    // ⚠️ THIS SENT HER TO A GYNAECOLOGIST'S BOOKING PAGE. FIXED.
    //
    // The comment right here said "a birthing class is the genuinely useful
    // escalation — more than a consult, which is why the offer is a class rather
    // than a doctor", and one line below it the action was `kPgActConsult`. So
    // the reasoning was written down, agreed with, and then not implemented —
    // and because both destinations are real screens that open cleanly, nothing
    // failed. It took someone tapping it:
    //
    //   "Join a birthing class right now is taking user to 1-1 consultation,
    //    although in birthing class is taking to correct program."
    //
    // The general lesson, which this repo has now hit fourteen times: a comment
    // is not a test. Anywhere a comment states where a tap goes, the tap is the
    // thing to check — a wrong destination compiles, analyzes clean, and looks
    // right in review, because reviewing a `case` is reading the label next to
    // it. `test/problem_hub_test.dart` now asserts this one by destination.
    label: _en('Join a birthing class'),
    blurb: _en('Live sessions on labour, breathing and what to expect. The '
        'trailer is free.'),
    action: kPgActBirthClass,
  ),
);

// -----------------------------------------------------------------------------
//  Garbh Sanskar & bonding — 1 door, opens directly
// -----------------------------------------------------------------------------
//  "Explore a structured journey" was cut: the programme is offered INSIDE the
//  daily practice, once she has done one. Offering a course to someone who has
//  not tried a single session is selling before showing.
final HubConfig kPgGarbh = HubConfig(
  bracketId: 'pregnancy_garbh',
  template: HubTemplate.practiceLed,
  coreQuestion: 'What can I do today to feel close to my baby?',
  hero: _en("A few quiet minutes with your baby."),
  heroSupport: _en('Reading, music, or simply sitting still together.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en("Do today's practice"),
      blurb: _en('One short practice, ready to start — reading, music, or a '
          'few minutes of quiet.'),
      mark: IntentMark.lotusMark,
      hue: 268,
      surfaceId: 'garbh_daily',
    ),
  ],
);

// -----------------------------------------------------------------------------
//  Fitness & yoga — 1 door, opens directly
// -----------------------------------------------------------------------------
final HubConfig kPgFitness = HubConfig(
  bracketId: 'pregnancy_fitness',
  template: HubTemplate.practiceLed,
  coreQuestion: 'What movement is safe for me right now?',
  hero: _en('Movement that is safe right now.'),
  heroSupport: _en('Short sessions matched to how far along you are.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Practise safely today'),
      blurb: _en('A short session for your stage, with what to avoid this '
          'trimester.'),
      mark: IntentMark.lotusMark,
      hue: 160,
      surfaceId: 'yoga',
    ),
  ],
);

// -----------------------------------------------------------------------------
//  Pregnancy mental health — 3 doors, and consult IS one of them
// -----------------------------------------------------------------------------
//  ⚠️ ONE OF ONLY TWO HUBS WHERE CONSULT IS A DOOR. "I need to talk to
//  someone" is a real arriving intent here, not reassurance — she is not
//  browsing, she has decided. Gated on real counsellor supply: a door that
//  opens on an empty calendar is worse than no door.
final HubConfig kPgMentalHealth = HubConfig(
  bracketId: 'pregnancy_mental_health',
  template: HubTemplate.trackerLed,
  coreQuestion: 'How am I doing, and what would help?',
  hero: _en('How you are doing matters too.'),
  heroSupport: _en('Not just the baby.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Check how I am feeling'),
      blurb: _en('A few gentle questions, kept private, that show you how the '
          'last two weeks have been.'),
      mark: IntentMark.moodArc,
      hue: 206,
      action: kPgActMoodCheck,
    ),
    HubNeed(
      label: _en('Help me feel better'),
      blurb: _en('Small things that genuinely help — breathing, sleep, and '
          'what to say to people.'),
      mark: IntentMark.cuppedHands,
      hue: 104,
      action: kPgActFeelBetter,
    ),
    HubNeed(
      label: _en('Talk to someone'),
      blurb: _en('A 1:1 with someone who works with mothers, in confidence.'),
      mark: IntentMark.askDoctor,
      hue: 268,
      action: kPgActConsultCounsellor,
    ),
  ],
);

// -----------------------------------------------------------------------------
//  Belly & skin care — 1 door, opens directly
// -----------------------------------------------------------------------------
final HubConfig kPgBellySkin = HubConfig(
  bracketId: 'pregnancy_belly_skin',
  template: HubTemplate.immediateAnswer,
  coreQuestion: 'What is happening to my skin, and what can I use on it?',
  hero: _en('What is happening to your skin.'),
  heroSupport: _en('What is normal, and what is safe to use.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Manage a skin concern'),
      blurb: _en('Stretch marks, itching or darkening — what helps, and what '
          'is safe in pregnancy.'),
      mark: IntentMark.bodyMark,
      hue: 42,
      action: kPgActSkinConcern,
    ),
  ],
);

/// Every pregnancy hub except Scans & tests.
final List<HubConfig> kPregnancyHubs = [
  kPgComplications,
  kPgIsItSafe,
  kPgNutrition,
  kPgSymptoms,
  kPgLabour,
  kPgGarbh,
  kPgFitness,
  kPgMentalHealth,
  kPgBellySkin,
];
