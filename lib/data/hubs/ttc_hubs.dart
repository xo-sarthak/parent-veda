// =============================================================================
//  TTC problem hubs — all seven
// -----------------------------------------------------------------------------
//  Doors come from the approved TTC hub-door audit (see the task that produced
//  this file — there is no revised-Excel sibling for TTC yet, unlike pregnancy's
//  PARENTVEDA_40_HUB_DOORS_REVISED.xlsx). See docs/HUB-BUILD-SPEC.md for the
//  contract this file follows, and `lib/data/hubs/pregnancy_hubs.dart` for the
//  worked exemplar this mirrors.
//
//  ⚠️ ENGLISH ONLY, EVEN THOUGH THIS STAGE'S OWN CHROME IS HINGLISH.
//  `lib/data/brackets/ttc_brackets.dart` deliberately keeps Hinglish, because the
//  Devanagari migration (CLAUDE.md) covers Pregnancy only and a half-migrated
//  stage is worse than a consistent one. HUB-BUILD-SPEC.md overrides that for
//  every hub file regardless of stage — "every string is `_en`" — so this file
//  is English-only like `pregnancy_hubs.dart`, and the Hinglish body copy is a
//  separate, later decision for whoever migrates TTC chrome as a whole.
//  `_en(...)` = English now, Hindi (or Hinglish) owed.
// =============================================================================

import '../../localization/app_language.dart';
import '../../screens/brackets/hub/hub_config.dart';
import '../../screens/brackets/hub/hub_intent_art.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  Actions this stage's router does not answer with a plain surface id.
// -----------------------------------------------------------------------------
//  `ttc_surface_router.dart` only resolves a fixed list of ids (§4 of the spec).
//  Where a door's real destination is a decision, a not-yet-built screen, or a
//  gated booking flow rather than a screen the id alone can open, it gets an
//  `action` here instead — the integrator wires the actual behaviour.
//
//  ⚠️ `kTtcActConsult` is deliberately ONE constant reused across hubs, exactly
//  as `kPgActConsult` is in pregnancy_hubs.dart. It always resolves through
//  `ttc_prepare` (the one paid course/consult browse surface this stage has),
//  and the hub it was tapped from is the context a resolver uses to pick the
//  right specific offer — the constant names the OFFER TYPE ("talk to
//  someone"), not a specific screen.
/// Male-fertility explainer. Owed: the existing partner screens carry the
/// content in scattered daily cards rather than as one explainer.
const String kTtcActSpermHealth = 'ttc_sperm_health';

const String kTtcActConsult = 'ttc_consult';

// "Improve my chances this cycle" is about timing and everyday habits, not a
// number the app calculates for her — no existing surface answers exactly
// this, and `ttc_chapter` is too general (whichever chapter she happens to be
// in, not specifically this). The integrator wires a focused timing/habits
// view. ⚠️ Must never grow into a personalised probability — see CLAUDE.md's
// clinical invariants and the door's own instruction in the build brief.
const String kTtcActImproveChances = 'ttc_improve_chances';

// No PCOS-specific explainer screen exists yet; `ttc_chapter` shows whichever
// chapter the engine has her in, not a condition library. Same shape as
// pregnancy's `kPgActConditionLibrary`.
const String kTtcActPcosLibrary = 'ttc_pcos_library';

// The bracket table (`ttc_brackets.dart`, Infertility → tools) already names
// this exact thing and marks it `notReady`: "'See a specialist?' readiness
// checklist." Declared here so the door exists and the destination is a real,
// scoped self-check — never a probability, never a diagnosis — once built.
const String kTtcActFertilityReadinessCheck = 'ttc_fertility_readiness_check';

// The bracket table's tools layer for this bracket is `notReady`: "Pre-
// pregnancy checklist, BMI." `ttc_nutrition` and `ttc_tests` each cover half
// of "get ready" (diet vs. tests/vaccinations) and neither covers the whole
// promise on its own, so this stays a named action rather than a forced pick
// of one half.
const String kTtcActPreconceptionReadiness = 'ttc_preconception_readiness';

// The bracket table's content layer for After a loss is `notReady`, in full:
// "Physical recovery, when it is safe to try again, emotional support." No
// existing screen carries this. ⚠️ Whatever fills this in must stay quiet and
// unhurried, per CLAUDE.md — no cheerful language, no commerce, and no
// timeline presented as a rule everyone must follow.
const String kTtcActLossRecoveryLibrary = 'ttc_loss_recovery_library';

// -----------------------------------------------------------------------------
//  1. Conceiving & fertile window — 2 doors
// -----------------------------------------------------------------------------
final HubConfig kTtcConceiving = HubConfig(
  bracketId: 'ttc_conceiving',
  template: HubTemplate.trackerLed,
  coreQuestion:
      'How do I find my fertile window, and what actually helps this cycle?',
  hero: _en('Trying to conceive, understood.'),
  heroSupport: _en('How conception actually works, and what helps this '
      'cycle.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Find my fertile window'),
      blurb: _en('See the days this cycle when trying has the best chance '
          'of working.'),
      mark: IntentMark.cycleRing,
      hue: 344,
      surfaceId: 'ttc_window',
    ),
    HubNeed(
      // Timing and habits, never a computed number — see kTtcActImproveChances
      // above.
      label: _en('Improve my chances this cycle'),
      blurb: _en('The timing and everyday habits that genuinely help, '
          'explained plainly.'),
      mark: IntentMark.improveMark,
      hue: 104,
      action: kTtcActImproveChances,
    ),
  ],
  closing: HubClosing(
    label: _en('Talk to a fertility expert'),
    blurb: _en('Book a short session and ask about your own cycle.'),
    action: kTtcActConsult,
  ),
);

// -----------------------------------------------------------------------------
//  2. PCOS & hormonal blocks — 2 doors
// -----------------------------------------------------------------------------
//  The highest-demand bracket in the stage (see the note at the top of
//  ttc_brackets.dart), which is why the closing offer here — the PCOS
//  programme cohort — earns its place rather than being filler.
final HubConfig kTtcPcos = HubConfig(
  bracketId: 'ttc_pcos',
  template: HubTemplate.trackerLed,
  coreQuestion: 'What does PCOS mean for me, and how do I manage it while '
      'trying to conceive?',
  hero: _en('PCOS, without the panic.'),
  heroSupport: _en('What it means for your body, and what helps while '
      "you're trying."),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Understand my PCOS'),
      blurb: _en('What PCOS actually is, how common it is, and what it '
          'means for trying.'),
      mark: IntentMark.bodyMark,
      hue: 288,
      action: kTtcActPcosLibrary,
    ),
    HubNeed(
      // The cycle tool is the real, live day-to-day management surface — see
      // ttc_brackets.dart's note on this bracket's tools layer.
      label: _en('Manage PCOS while trying'),
      blurb: _en('Track your cycle and keep an eye on the pattern PCOS '
          'makes harder to read.'),
      mark: IntentMark.chartLog,
      hue: 206,
      surfaceId: 'ttc_cycle',
    ),
  ],
  closing: HubClosing(
    label: _en('Talk to a PCOS specialist'),
    blurb: _en('Book a 1:1 and ask about managing PCOS while trying.'),
    action: kTtcActConsult,
  ),
);

// -----------------------------------------------------------------------------
//  3. Infertility & IVF — 3 doors, and consult IS one of them
// -----------------------------------------------------------------------------
//  ⚠️ ONE OF ONLY TWO HUBS IN THE WHOLE APP WHERE CONSULT IS A DOOR (the other
//  is pregnancy's Mental health). Seeking the specialist is not a fallback
//  after reading fails here — it is the reason she opened this hub. Gated on
//  real provider supply: a door that opens on an empty calendar is worse than
//  no door, same call pregnancy's mental-health hub makes.
//
//  ⚠️ NEVER A SUCCESS-RATE FIGURE. NEVER "YOUR CHANCES." No personalised
//  probability, anywhere, ever — see CLAUDE.md's clinical invariants. Nothing
//  in this hub's copy states or implies one.
//
//  ⚠️ NO COMMERCE. The bracket table marks products `notApplicable` on this
//  exact bracket with the plainest reason in the whole file: "Not a fit
//  (clinical)." No product tile, no course upsell — the consult door above is
//  the one paid thing here, and it is a door because she asked for it, not
//  because we are selling it.
final HubConfig kTtcInfertility = HubConfig(
  bracketId: 'ttc_infertility',
  // ⚠️ NOT decisionCommerce. That template names the buying-guide shape, and
  // this hub bans commerce outright three lines above. A template that says
  // 'commerce' on the one hub where products are notApplicable is exactly the
  // kind of label someone later reads as permission.
  template: HubTemplate.learnAndPlan,
  coreQuestion: 'Is it time to seek help, what do the tests and treatments '
      'involve, and who do I talk to?',
  hero: _en("When it's taking longer than expected."),
  heroSupport: _en('When to seek help, what the tests mean, and where to '
      'go next.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      // Not yet built — see kTtcActFertilityReadinessCheck above. A self-check,
      // never a probability.
      label: _en('Should I seek fertility help?'),
      blurb: _en('A few honest questions to help you decide if it is time '
          'to see someone.'),
      mark: IntentMark.questionMark,
      hue: 206,
      action: kTtcActFertilityReadinessCheck,
    ),
    HubNeed(
      label: _en('Understand my tests & treatment'),
      blurb: _en('What IUI and IVF actually involve, step by step, '
          'including what they cost.'),
      mark: IntentMark.reportPage,
      hue: 42,
      surfaceId: 'ttc_treatment',
    ),
    HubNeed(
      // ⚠️ Gated on real provider supply — do not wire this open until fertility
      // specialists actually have bookable slots. An empty calendar behind this
      // door would be worse than the door not existing.
      label: _en('Speak to a fertility specialist'),
      blurb: _en('Book a 1:1 with a fertility specialist, when you are '
          'ready.'),
      mark: IntentMark.askDoctor,
      hue: 26,
      action: kTtcActConsult,
    ),
  ],
  // No closing — consult is already a door. Adding one at the foot too would
  // make the one hub that has earned a consult ask for it twice.
);

// -----------------------------------------------------------------------------
//  4. Preconception health & nutrition — 1 door, opens directly
// -----------------------------------------------------------------------------
//  ⚠️ NO CLOSING, DELIBERATELY — one door means the hub screen is never shown,
//  so there is no foot to put an offer on. See §3 of the spec.
final HubConfig kTtcPreconceptionHealth = HubConfig(
  bracketId: 'ttc_preconception_health',
  template: HubTemplate.learnAndPlan,
  coreQuestion: 'What should I be doing before we start trying?',
  hero: _en('Getting your body ready, before you start trying.'),
  heroSupport: _en('Diet, tests and habits worth sorting out before you '
      'begin.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en('Get ready before trying'),
      blurb: _en('Diet, folic acid, weight and the tests worth doing '
          'before you start.'),
      mark: IntentMark.checkMark,
      hue: 104,
      action: kTtcActPreconceptionReadiness,
    ),
  ],
);

// -----------------------------------------------------------------------------
//  5. Male fertility — 2 doors
// -----------------------------------------------------------------------------
final HubConfig kTtcMaleFertility = HubConfig(
  bracketId: 'ttc_male_fertility',
  template: HubTemplate.learnAndPlan,
  coreQuestion: 'What does sperm health depend on, and how do we improve '
      'it?',
  hero: _en('His fertility matters just as much.'),
  heroSupport: _en('What affects sperm health, and what genuinely helps.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      // ⚠️ HER view of the partner material — see the note in
      // ttc_surface_router.dart on why a bracket must never route at his own
      // account.
      label: _en('Understand sperm health'),
      blurb: _en('What actually affects sperm health, explained plainly '
          'for both of you.'),
      mark: IntentMark.spermMark,
      hue: 186,
      // ⚠️ WAS `ttc_partner`, WHICH IS THE PARTNER'S WHOLE DAILY HOME.
      // A woman tapping "Understand sperm health" was dropped into his
      // dashboard, where sperm content is one card among many, chapter-
      // dependent, and in one chapter reads "nothing special is required of
      // you this week". The screen is fine; the arrival was wrong.
      action: kTtcActSpermHealth,
    ),
    HubNeed(
      // A real, standalone course ships for exactly this — "The half nobody
      // talks about" — rather than a module folded into the general
      // conception class. See the ⚑ note on this bracket in ttc_brackets.dart.
      label: _en('Improve sperm health'),
      blurb: _en('A short course on the lifestyle changes that genuinely '
          'move the needle.'),
      mark: IntentMark.improveMark,
      hue: 42,
      surfaceId: 'ttc_prepare',
    ),
  ],
  closing: HubClosing(
    label: _en('Talk to a specialist'),
    blurb: _en('Book a 1:1 and ask about his results, in confidence.'),
    action: kTtcActConsult,
  ),
);

// -----------------------------------------------------------------------------
//  6. Trying again after loss — 2 doors
// -----------------------------------------------------------------------------
//  ⚠️ NO COMMERCE. NO CONSULT UPSELL. NO CHEERFUL LANGUAGE. Someone here has
//  just lost a pregnancy. Five of this bracket's seven layers are "Not a fit"
//  in the workbook (see ttc_brackets.dart) and every refusal there is right.
//  The tone below is quiet and unhurried on purpose — short sentences, no
//  encouragement, nothing implying a timeline she is behind on.
final HubConfig kTtcAfterLoss = HubConfig(
  bracketId: 'ttc_after_loss',
  template: HubTemplate.afterALoss,
  coreQuestion: 'What does my body need to recover, and when — if ever — do '
      'we try again?',
  hero: _en('Trying again, after a loss.'),
  heroSupport: _en('No rush, and no timeline you have to keep.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      // Not yet built — see kTtcActLossRecoveryLibrary above. The bracket's
      // content layer is notReady in full.
      label: _en('Understand recovery & trying again'),
      blurb: _en('What your body needs to heal, and when it may be safe '
          'to try again.'),
      mark: IntentMark.bodyMark,
      hue: 26,
      action: kTtcActLossRecoveryLibrary,
    ),
    HubNeed(
      // Free, real, and already live — other people who have been exactly
      // here, not a paid session. This is the layer the bracket table calls
      // "the one layer the workbook actively wanted here."
      label: _en('Get emotional support'),
      blurb: _en('Other people who have been exactly here, whenever you '
          'want to talk.'),
      mark: IntentMark.cuppedHands,
      hue: 268,
      surfaceId: 'ttc_community',
    ),
  ],
  // ⚠️ NO CLOSING. A consult offer at the foot of this hub is a consult
  // upsell whatever label it carries, and the brief for this hub rules that
  // out explicitly. The one live consult this bracket has (a psychologist,
  // via ttc_prepare) is reached through Prepare and through people, not
  // merchandised here.
);

// -----------------------------------------------------------------------------
//  7. Mind-body preparation — 1 door, opens directly
// -----------------------------------------------------------------------------
//  ⚠️ NO CLOSING, DELIBERATELY — one door means the hub screen is never shown.
final HubConfig kTtcMindBody = HubConfig(
  bracketId: 'ttc_mind_body',
  template: HubTemplate.practiceLed,
  coreQuestion: 'What can we do today that helps, without adding pressure?',
  hero: _en('A few quiet minutes, today.'),
  heroSupport: _en('Reflection, breath and connection while you wait.'),
  needsTitle: _en('What do you need?'),
  needs: [
    HubNeed(
      label: _en("Do today's practice"),
      blurb: _en('Reflection, breath, conversation and gratitude — five '
          'quiet minutes.'),
      mark: IntentMark.lotusMark,
      hue: 42,
      surfaceId: 'ttc_ritual',
    ),
  ],
);

/// All seven TTC problem hubs.
final List<HubConfig> kTtcHubs = [
  kTtcConceiving,
  kTtcPcos,
  kTtcInfertility,
  kTtcPreconceptionHealth,
  kTtcMaleFertility,
  kTtcAfterLoss,
  kTtcMindBody,
];
