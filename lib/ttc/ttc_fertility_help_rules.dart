// =============================================================================
//  "See a specialist?" — the rule set
// -----------------------------------------------------------------------------
//  ⚠️ A READINESS READ. NOT A PROBABILITY, NOT A DIAGNOSIS, NOT A PREDICTION.
//
//  `kTtcInfertility` bans a success rate or "your chances" outright, and this
//  is the tool most likely to grow one by accident — because the question it
//  answers ("should I see someone?") sits one careless step from the question
//  it must never answer ("will this work?"). Nothing here produces a number.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THIS TOOL OWNS NO CLINICAL FRAMEWORK OF ITS OWN
//  ---------------------------------------------------------------------------
//
//  Every threshold below is already written, sourced and shipped in
//  `ttc_read_when_to_seek_help` — the NICE referral thresholds and the six
//  situations where the clock does not apply. The article is the educational
//  layer; this is the decision layer.
//
//  So each rule carries `article` naming the section it comes from, and the
//  result always offers the article rather than restating it. If a threshold
//  ever changes, it changes in the article FIRST and here second — inventing a
//  second medical framework in a rules file is how an app ends up telling a
//  woman something its own content contradicts.
//
//  ---------------------------------------------------------------------------
//  ⚠️ AND IT IS NOT A COUNT
//  ---------------------------------------------------------------------------
//
//  No "7 of 10 risk factors". A single don't-wait situation outranks any number
//  of soft ones, because that is how the guidance actually works: irregular
//  cycles mean the twelve-month rule was never hers, however long she has been
//  trying. Rules are evaluated by PRECEDENCE, not by addition.
//
//  Held by `test/ttc_fertility_help_test.dart`.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  Context
// -----------------------------------------------------------------------------

/// The age bands, and there is exactly one set of them.
///
/// ⚠️ CHANGED 2026-09-03 TO THE BANDS THE BRIEF ASKS FOR: under 35 / 35-37 /
/// 38-40 / over 40. They were under 30 / 30-35 / 36-39 / 40+.
///
/// This existed as TWO enums — these bands in the engine and an identical-in-
/// purpose `IvfAge` on the screen — with different cut points, so a woman's
/// answer on the live screen could not be written into the store behind it
/// without guessing which side of a boundary she fell. "Under 35" is both
/// "under 30" and "30 to 35"; there is no honest translation, and the fix for
/// that is not a cleverer mapping, it is one set of bands. `IvfAge` is retired.
///
/// ⚠️ AND THIS BAND NOW OVER-REFERS BY UP TO ONE YEAR, DELIBERATELY.
///
/// NICE refers at presentation from **36**. The band is **35 to 37**, so it
/// straddles that line and cannot tell a 35-year-old from a 36-year-old. One of
/// two errors is unavoidable:
///
///   * treat the band as referring  → a 35-year-old is offered a conversation
///     the guidance would not have offered her yet;
///   * treat it as not referring    → a 36- and a 37-year-old are NOT offered
///     one the guidance says they should have.
///
/// The first costs an unnecessary appointment. The second delays care for
/// exactly the people the rule exists to catch, and this tool's own promise is
/// that it "only says whether a conversation is worth having". Where it is
/// unsure it leans toward the conversation. So: refers from 35.
///
/// If that year ever needs to be exact, the answer is not a fifth band — it is
/// a date of birth. `FamilyProfileStore` already holds `dob` and derives `age`;
/// nothing collects it yet. With a real age, this rule reads 36 and the
/// reassurance rule reads 35, both correct, with nothing translated between
/// them. See `docs/STILL-OPEN.md` §18.7.
enum FertilityAgeBand { under35, thirtyFiveTo37, thirtyEightTo40, over40 }

extension FertilityAgeBandCopy on FertilityAgeBand {
  LocalizedText get label => switch (this) {
        FertilityAgeBand.under35 => _en('Under 35'),
        FertilityAgeBand.thirtyFiveTo37 => _en('35 to 37'),
        FertilityAgeBand.thirtyEightTo40 => _en('38 to 40'),
        FertilityAgeBand.over40 => _en('Over 40'),
      };

  /// See the enum's own note: 35, not 36, and the reason is which error is
  /// survivable.
  bool get refersAtPresentation => this != FertilityAgeBand.under35;

  /// The point where the tool stops saying "it is early yet, keep going".
  ///
  /// Same boundary as [refersAtPresentation] now that there is one set of
  /// bands. It is kept as a separate name because the two are separate ideas —
  /// "guidance says refer" and "stop reassuring" — and if a date of birth ever
  /// arrives they part company again at 36 and 35.
  bool get holdsBackReassurance => this != FertilityAgeBand.under35;
}

enum FertilityCarePathway { notStarted, evaluated, currentlyInCare }

/// Everything the engine reads. Assembled from stores where the app already
/// knows, and from the few questions it has to ask.
@immutable
class FertilityHelpContext {
  const FertilityHelpContext({
    this.daysTrying,
    this.ageBand,
    this.cyclesLogged = 0,
    this.cycleShortest,
    this.cycleLongest,
    this.cyclesIrregular = false,
    this.pcosPatternFound = false,
    this.pcosCheckDone = false,
    this.pathway = FertilityCarePathway.notStarted,
    this.knownConditions = const {},
    this.priorMiscarriages = 0,
    this.partnerConcern = false,
    this.cancerTreatmentPlanned = false,
    this.painfulOrHeavyPeriods = false,
    this.pelvicSurgeryOrInfection = false,
  });

  final int? daysTrying;
  final FertilityAgeBand? ageBand;

  final int cyclesLogged;
  final int? cycleShortest;
  final int? cycleLongest;
  final bool cyclesIrregular;

  final bool pcosPatternFound;
  final bool pcosCheckDone;

  final FertilityCarePathway pathway;

  /// Ids from [kFertilityConditions].
  final Set<String> knownConditions;

  final int priorMiscarriages;
  final bool partnerConcern;

  /// ⚠️ THE ONE GENUINELY URGENT ROUTE. Fertility preservation has to happen
  /// before treatment starts, so this is days rather than weeks.
  final bool cancerTreatmentPlanned;

  final bool painfulOrHeavyPeriods;
  final bool pelvicSurgeryOrInfection;

  int? get monthsTrying =>
      daysTrying == null ? null : (daysTrying! / 30.44).round();

  bool get hasEnoughCycleData => cyclesLogged >= 2;

  /// ⚠️ NEVER A RAW DAY COUNT ON SCREEN — §17. "412 days" reads as a sentence
  /// served; "about 14 months" reads as a fact.
  LocalizedText? get tryingLabel {
    final m = monthsTrying;
    if (m == null) return null;
    if (m < 1) return _en('less than a month');
    if (m == 1) return _en('about a month');
    if (m < 12) return _en('about $m months');
    final y = m ~/ 12;
    final rem = m % 12;
    if (rem == 0) return _en(y == 1 ? 'about a year' : 'about $y years');
    return _en('about $m months');
  }
}

/// The conditions the tool may be told about. Never inferred.
const List<({String id, String label})> kFertilityConditions = [
  (id: 'pcos', label: 'PCOS'),
  (id: 'endometriosis', label: 'Endometriosis'),
  (id: 'ectopic', label: 'A previous ectopic pregnancy'),
  (id: 'tubal', label: 'A tubal problem'),
  (id: 'reserve', label: 'Reduced ovarian reserve'),
  (id: 'other', label: 'Another fertility-related condition'),
];

// -----------------------------------------------------------------------------
//  Results
// -----------------------------------------------------------------------------

enum FertilityHelpState {
  /// Nothing in the guidance applies yet.
  keepTrying,

  /// A normal evaluation threshold has been reached.
  maySeeSpecialist,

  /// One of the don't-wait situations applies.
  dontWait,

  /// She is already in the pathway — the tool has nothing to decide.
  alreadyInCare,
}

/// Whether a claim has been signed off. §25 asks for it on every rule.
enum ClinicalReviewStatus { pendingReview, reviewed }

/// One rule. Data, so it can be printed into a review pack.
@immutable
class FertilityHelpRule {
  const FertilityHelpRule({
    required this.id,
    required this.trigger,
    required this.requiredContext,
    required this.resultState,
    required this.displayReason,
    required this.article,
    this.clinicalReviewStatus = ClinicalReviewStatus.pendingReview,
  });

  final String id;

  /// Plain-language statement of what fires it. For the review pack.
  final String trigger;

  /// Which context fields it needs — so a reviewer can see what it depends on.
  final List<String> requiredContext;

  final FertilityHelpState resultState;

  /// The personalised sentence shown under "why". Takes the context so it can
  /// name her actual numbers.
  final LocalizedText Function(FertilityHelpContext) displayReason;

  /// Which part of `ttc_read_when_to_seek_help` this comes from.
  final String article;

  final ClinicalReviewStatus clinicalReviewStatus;
}

/// The reason shown to her, paired with the rule that produced it.
@immutable
class FertilityHelpReason {
  const FertilityHelpReason({required this.ruleId, required this.text});
  final String ruleId;
  final LocalizedText text;
}

@immutable
class FertilityHelpResult {
  const FertilityHelpResult({
    required this.state,
    required this.reasons,
    required this.headline,
    required this.body,
    required this.notMeaning,
    required this.nextStep,
    this.urgent = false,
  });

  final FertilityHelpState state;

  /// ⚠️ AT MOST THREE — §12. A result listing seven reasons is the tool
  /// justifying itself rather than answering her.
  final List<FertilityHelpReason> reasons;

  final LocalizedText headline;
  final LocalizedText body;

  /// "What this does not mean" — required on every state that suggests a
  /// specialist, because that is the sentence she will otherwise supply herself
  /// and get wrong.
  final LocalizedText notMeaning;

  final LocalizedText nextStep;

  /// Cancer treatment planned. Days, not weeks.
  final bool urgent;
}

// -----------------------------------------------------------------------------
//  THE RULES
// -----------------------------------------------------------------------------
//  ⚠️ ORDERED BY PRECEDENCE, STRONGEST FIRST. The engine takes the highest
//  state any rule reaches — it does not add them up.

final List<FertilityHelpRule> kFertilityHelpRules = [
  // ---- don't wait ----------------------------------------------------------
  FertilityHelpRule(
    id: 'cancer_treatment',
    trigger: 'Cancer treatment planned for either partner',
    requiredContext: ['cancerTreatmentPlanned'],
    resultState: FertilityHelpState.dontWait,
    article: "When shouldn't you wait at all? (cancer treatment)",
    displayReason: (_) => _en('Fertility preservation (saving eggs or sperm) '
        'has to happen before cancer treatment starts. That makes this the one '
        'situation here where timing really matters.'),
  ),
  FertilityHelpRule(
    id: 'irregular_cycles',
    trigger: 'Irregular or absent cycles, from logged data or from a known '
        'PCOS diagnosis',
    requiredContext: ['cyclesIrregular', 'knownConditions', 'pcosPatternFound'],
    resultState: FertilityHelpState.dontWait,
    article: "When shouldn't you wait at all? (irregular cycles)",
    displayReason: (c) {
      if (c.cycleShortest != null && c.cycleLongest != null) {
        return _en('Your logged cycles have ranged from ${c.cycleShortest} to '
            '${c.cycleLongest} days. The "try for a year first" advice assumes '
            'regular ovulation, so it was never meant for you.');
      }
      return _en("Irregular cycles mean the usual waiting time doesn't apply, "
          'because it assumes ovulation is regular.');
    },
  ),
  FertilityHelpRule(
    id: 'two_miscarriages',
    trigger: 'Two or more previous miscarriages',
    requiredContext: ['priorMiscarriages'],
    resultState: FertilityHelpState.dontWait,
    article: "When shouldn't you wait at all? (two or more losses)",
    displayReason: (_) => _en("After two or more losses, it's reasonable to "
        "start looking for a cause. You don't need to wait for a third."),
  ),
  FertilityHelpRule(
    id: 'known_condition',
    trigger: 'A known condition affecting fertility — endometriosis, tubal '
        'factor, reduced reserve, previous ectopic',
    requiredContext: ['knownConditions'],
    resultState: FertilityHelpState.dontWait,
    article: "When shouldn't you wait at all? (a known cause)",
    displayReason: (_) => _en('You already know about something that can '
        "affect getting pregnant. That's a reason in itself not to wait out the "
        'usual timeline.'),
  ),
  FertilityHelpRule(
    id: 'partner_factor',
    trigger: 'A known concern about sperm health, or an abnormal semen '
        'analysis',
    requiredContext: ['partnerConcern'],
    resultState: FertilityHelpState.dontWait,
    article: "When shouldn't you wait at all? (a male factor)",
    displayReason: (_) => _en('A known concern on his side is a reason to be '
        'seen now. His tests are also the quickest part of any check-up.'),
  ),
  FertilityHelpRule(
    id: 'pelvic_history',
    trigger: 'Previous pelvic surgery, ruptured appendix or pelvic infection',
    requiredContext: ['pelvicSurgeryOrInfection'],
    resultState: FertilityHelpState.dontWait,
    article: "When shouldn't you wait at all? (pelvic history)",
    displayReason: (_) => _en('Past surgery or infection in the pelvis can '
        "affect the tubes. That's worth checking, not waiting out."),
  ),
  FertilityHelpRule(
    id: 'painful_periods',
    trigger: 'Very painful or very heavy periods, or pain during sex',
    requiredContext: ['painfulOrHeavyPeriods'],
    resultState: FertilityHelpState.dontWait,
    article: "When shouldn't you wait at all? (pain and heavy bleeding)",
    displayReason: (_) => _en('Very painful or heavy periods are the usual '
        "reason doctors look for endometriosis. That's worth talking about "
        'sooner.'),
  ),

  // ---- the normal thresholds ----------------------------------------------
  FertilityHelpRule(
    id: 'age_at_presentation',
    trigger: 'Age 36 or over — NICE refers at presentation rather than after '
        'a waiting period',
    requiredContext: ['ageBand'],
    resultState: FertilityHelpState.maySeeSpecialist,
    article: 'How long should you try first? (36 and over)',
    displayReason: (c) => _en('From 36, the advice is to be seen as soon as '
        'you ask, not after a waiting period. Nothing changes suddenly at that '
        "age. It's because tests and treatment both take months."),
  ),
  FertilityHelpRule(
    id: 'twelve_months',
    trigger: 'Twelve months of trying, under 36',
    requiredContext: ['daysTrying', 'ageBand'],
    resultState: FertilityHelpState.maySeeSpecialist,
    article: 'How long should you try first? (twelve months)',
    displayReason: (c) => _en('You\'ve been trying for '
        '${c.tryingLabel?.en ?? 'over a year'}, which is when the usual advice '
        'says it\'s worth looking into.'),
  ),
];

// -----------------------------------------------------------------------------
//  The engine
// -----------------------------------------------------------------------------

/// Which rules fire for this context.
///
/// ⚠️ EACH RULE ANSWERS ONLY FROM CONTEXT IT HAS. A rule whose inputs are
/// unknown does not fire — it does not guess, and it does not default to the
/// cautious answer either. Telling a woman to see a specialist because we
/// could not read her cycles would be as wrong as telling her not to.
List<FertilityHelpRule> firedRules(FertilityHelpContext c) {
  bool fires(FertilityHelpRule r) => switch (r.id) {
        'cancer_treatment' => c.cancerTreatmentPlanned,
        'irregular_cycles' => c.cyclesIrregular ||
            c.knownConditions.contains('pcos') ||
            c.pcosPatternFound,
        'two_miscarriages' => c.priorMiscarriages >= 2,
        // PCOS is handled by `irregular_cycles`, so it is excluded here — two
        // rules firing on one fact would print the same reason twice.
        'known_condition' => c.knownConditions.any((k) => k != 'pcos'),
        'partner_factor' => c.partnerConcern,
        'pelvic_history' => c.pelvicSurgeryOrInfection,
        'painful_periods' => c.painfulOrHeavyPeriods,
        'age_at_presentation' => c.ageBand?.refersAtPresentation ?? false,
        'twelve_months' => (c.daysTrying ?? 0) >= 365 &&
            !(c.ageBand?.refersAtPresentation ?? false),
        _ => false,
      };
  return [for (final r in kFertilityHelpRules) if (fires(r)) r];
}

FertilityHelpResult evaluateFertilityHelp(FertilityHelpContext c) {
  // ---- already in care: the tool has nothing to decide ---------------------
  if (c.pathway == FertilityCarePathway.currentlyInCare) {
    return FertilityHelpResult(
      state: FertilityHelpState.alreadyInCare,
      reasons: const [],
      headline: _en("You're already getting fertility care"),
      body: _en("This check helps you work out whether it's time to see "
          "someone, and you're past that. Nothing here would tell you anything "
          "your own team can't."),
      notMeaning: _en(''),
      nextStep: _en('What helps more now is going to your next appointment '
          'with your dates, your reports and your questions all in one '
          'place.'),
    );
  }

  final fired = firedRules(c);

  // ⚠️ PRECEDENCE, NOT ADDITION. One don't-wait situation outranks any number
  // of softer ones — irregular cycles mean the twelve-month rule was never
  // hers, whatever else is or is not true.
  final dontWait =
      fired.where((r) => r.resultState == FertilityHelpState.dontWait).toList();
  final maySee = fired
      .where((r) => r.resultState == FertilityHelpState.maySeeSpecialist)
      .toList();

  List<FertilityHelpReason> reasonsFrom(List<FertilityHelpRule> rules) => [
        // At most three — §12.
        for (final r in rules.take(3))
          FertilityHelpReason(ruleId: r.id, text: r.displayReason(c)),
      ];

  if (dontWait.isNotEmpty) {
    final urgent = dontWait.any((r) => r.id == 'cancer_treatment');
    return FertilityHelpResult(
      state: FertilityHelpState.dontWait,
      reasons: reasonsFrom(dontWait),
      urgent: urgent,
      headline: _en("It's worth talking to a doctor sooner"),
      body: _en("Something you've shared is one of the situations where the "
          'advice is to raise it earlier, not wait out the usual timeline.'),
      notMeaning: _en('This does not mean anything is wrong, and it does not '
          'mean you are infertile. It means the usual "wait and see" advice '
          'was written for a different situation from yours.'),
      nextStep: urgent
          ? _en('Ask about fertility preservation this week, before treatment '
              'starts.')
          : _en("Book a visit with a gynaecologist. In India, that's where "
              'this starts, not at a fertility clinic.'),
    );
  }

  if (maySee.isNotEmpty) {
    return FertilityHelpResult(
      state: FertilityHelpState.maySeeSpecialist,
      reasons: reasonsFrom(maySee),
      headline: _en('It may be a good time to talk to someone'),
      body: _en("From what you've shared, you've reached the point where the "
          "usual advice says it's worth looking into."),
      // ⚠️ THE MOST IMPORTANT SENTENCE IN THE TOOL. Left unsaid, she supplies
      // it herself, and what she supplies is "I need IVF".
      notMeaning: _en('This does not mean you need IVF, and it does not mean '
          'you cannot conceive without help. Most couples who have tests '
          "don't end up having IVF. Tests are how the exact reason gets found, "
          "and it's often something small."),
      nextStep: _en('Think about getting a fertility check-up. A gynaecologist '
          'does the first round of tests. A referral to a specialist comes '
          "later, if it's needed."),
    );
  }

  return FertilityHelpResult(
    state: FertilityHelpState.keepTrying,
    reasons: const [],
    headline: _en("There's no clear reason to see a specialist yet"),
    body: _en("From what you've shared, none of the situations that usually "
        'lead to a check-up applies to you right now.'),
    // ⚠️ NOT A GUARANTEE, AND THIS IS WHERE ONE WOULD SLIP IN. "Everything is
    // fine" is the sentence a reassuring result wants to write and must not.
    notMeaning: _en("That's not the same as a promise that everything is "
        "fine, and it's not a prediction. It only means nothing you've told us "
        'is a reason to have the conversation sooner.'),
    nextStep: _en("If you're happy to keep going, keep tracking your cycles. "
        'Come back to this whenever something changes.'),
  );
}

/// The editorial beat after the result. Not labelled a tip — §23.
final LocalizedText kFertilityHelpPatternBreak = _en(
    "Seeing a specialist doesn't mean you've stopped believing it can happen "
    'on its own. Often it just means swapping guesswork for real '
    'information.');

final LocalizedText kFertilityHelpDisclaimer = _en(
    'This helps you work out whether a talk with a doctor is worth having. It '
    'does not diagnose infertility, and it does not predict whether you will '
    "conceive. It can't replace your own doctor looking at your history.");

/// The review pack — generated from the rules so it cannot drift from them.
List<({String id, String trigger, String article, String status})>
    fertilityHelpReviewRegister() => [
          for (final r in kFertilityHelpRules)
            (
              id: r.id,
              trigger: r.trigger,
              article: r.article,
              status: r.clinicalReviewStatus.name
            ),
        ];
