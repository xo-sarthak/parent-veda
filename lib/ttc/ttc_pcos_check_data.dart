// =============================================================================
//  PCOS Symptom Checker — the models and the question content
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS A CONVERSATION-PREPARATION TOOL. IT DOES NOT SCREEN, SCORE OR
//  DIAGNOSE.
//
//  The single most important line in this feature: nothing here may ever tell a
//  woman she has PCOS, or that she probably does, or attach a number to the
//  possibility. PCOS is diagnosed on two of three findings, one of which is a
//  scan and one of which is a blood test — neither of which a phone has. What a
//  phone CAN do is help her describe her own pattern accurately to someone who
//  can.
//
//  So the output is a description of what she reported, and a view on whether
//  it is worth a conversation. Never a verdict.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY THE RULES ARE NOT IN THIS FILE
//  ---------------------------------------------------------------------------
//
//  Content here; interpretation in `ttc_pcos_check_rules.dart`; state in
//  `ttc_pcos_check_store.dart`; UI in the screens. The separation is a clinical
//  requirement rather than a tidiness preference — every medical threshold in
//  this feature has to be reviewable by someone who does not read Dart widgets,
//  and a rule embedded in a `build()` method is a rule nobody will ever audit.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THREE ANSWERS THAT ARE NOT "SYMPTOMS" AND MUST NOT BE SCORED AS ONE
//  ---------------------------------------------------------------------------
//
//  · **Weight.** Asked because unexplained weight change is part of the picture
//    she may want to describe. It carries ZERO interpretive weight — plenty of
//    women with textbook PCOS are slim, the association runs through insulin
//    rather than through the scale, and a tool that scored weight would be
//    telling larger women they are more likely to be ill. See the rules file.
//  · **Bleeding duration.** Asked because it belongs in a doctor summary.
//    Scored at zero on its own; heavy or prolonged bleeding has many causes and
//    is a red-flag question, not a PCOS signal.
//  · **Hormonal contraception.** Not a symptom at all. It is a CONFOUNDER: it
//    sets the bleed rather than the cycle, so cycle answers stop describing
//    ovulation. It caps the interpretation rather than feeding it.
//
//  ENGLISH FIRST — `_en(...)`, so `grep -c '_en('` is the Hindi backlog.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  Sections
// -----------------------------------------------------------------------------

/// The parts of the check, in order.
///
/// ⚠️ `safety` RUNS FIRST AND CAN END THE WHOLE THING. Everything else assumes
/// there is a cycle to describe; the safety section is what establishes that
/// there is. Putting it last — which is where a questionnaire naturally puts
/// "any other symptoms?" — would mean asking a woman with severe one-sided pain
/// fourteen questions about acne before noticing.
enum PcosSection { safety, cycle, ovulation, androgen, fertility, context }

extension PcosSectionCopy on PcosSection {
  LocalizedText get title => switch (this) {
        PcosSection.safety => _en('First, a couple of checks'),
        PcosSection.cycle => _en('Your period pattern'),
        PcosSection.ovulation => _en('Signs of ovulation'),
        PcosSection.androgen => _en('Other things you may have noticed'),
        PcosSection.fertility => _en('Where you are in trying'),
        PcosSection.context => _en('A little context'),
      };
}

/// Which domain an answer feeds. Kept on the QUESTION rather than in the rules
/// so a reviewer can see, reading the content, what each question is for.
enum PcosDomain {
  /// Primary. Irregular or absent periods.
  cycle,

  /// Primary. Evidence that ovulation may not be happening predictably.
  ovulation,

  /// Primary. Signs that can accompany higher androgens.
  androgen,

  /// Modifier. Escalates urgency; never produces a pattern on its own.
  fertility,

  /// Confounder. Can make the cycle answers uninterpretable.
  context,

  /// Recorded for the doctor summary and deliberately not scored.
  recordOnly,

  /// Ends the check.
  safety,
}

// -----------------------------------------------------------------------------
//  Model
// -----------------------------------------------------------------------------

@immutable
class PcosCheckerOption {
  const PcosCheckerOption({
    required this.id,
    required this.label,
    this.weight = 0,
    this.unknown = false,
  });

  final String id;
  final LocalizedText label;

  /// 0–3, meaning nothing on its own. The rules file decides what a domain
  /// total means; this is only how strongly THIS answer speaks.
  final int weight;

  /// ⚠️ "I'm not sure" IS NOT A ZERO AND IS NOT A YES.
  ///
  /// A woman who does not track her cycle cannot answer half of this, and
  /// treating her uncertainty as absence would quietly report a clean pattern
  /// she never described. Unknowns are counted separately and lower the
  /// CONFIDENCE of the reading rather than its level — see the rules file.
  final bool unknown;
}

@immutable
class PcosCheckerQuestion {
  const PcosCheckerQuestion({
    required this.id,
    required this.section,
    required this.domain,
    required this.prompt,
    required this.options,
    this.whyWeAsk,
    this.summaryLabel,
    this.dependsOn,
  });

  final String id;
  final PcosSection section;
  final PcosDomain domain;
  final LocalizedText prompt;
  final List<PcosCheckerOption> options;

  /// The expandable "why we ask" line. Present on every question that could
  /// feel intrusive or arbitrary — which, on a page about facial hair and
  /// weight, is most of them.
  final LocalizedText? whyWeAsk;

  /// How this appears in the doctor summary. Null means it does not appear.
  final LocalizedText? summaryLabel;

  /// Shown only when another question was answered a particular way, as
  /// `questionId:optionId`. Keeps the flow to the two to three minutes the
  /// brief asks for.
  final String? dependsOn;
}

@immutable
class PcosCheckerAnswer {
  const PcosCheckerAnswer({required this.questionId, required this.optionId});
  final String questionId;
  final String optionId;
}

// -----------------------------------------------------------------------------
//  The questions
// -----------------------------------------------------------------------------

final List<PcosCheckerQuestion> kPcosQuestions = [
  // ===========================================================================
  //  SAFETY — first, and able to end the check
  // ===========================================================================
  PcosCheckerQuestion(
    id: 'q_pregnancy',
    section: PcosSection.safety,
    domain: PcosDomain.safety,
    prompt: _en('Is there any chance you could be pregnant right now?'),
    whyWeAsk: _en('A late or missed period has one very common cause. '
        "It's worth ruling that in or out before we look at anything else."),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'maybe', label: _en('Possibly'), weight: 3),
      PcosCheckerOption(
          id: 'unsure', label: _en("I'm not sure"), weight: 3, unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_redflag',
    section: PcosSection.safety,
    domain: PcosDomain.safety,
    prompt: _en('Do you have any of these right now?'),
    whyWeAsk: _en('These need a doctor, not a questionnaire. We would rather '
        'ask now than have you spend three minutes here first.'),
    options: [
      PcosCheckerOption(id: 'none', label: _en('None of these')),
      PcosCheckerOption(
          id: 'pain',
          label: _en('Severe pain, or sudden pain on one side'),
          weight: 3),
      PcosCheckerOption(
          id: 'bleeding',
          label: _en('Bleeding much heavier than a normal period'),
          weight: 3),
      PcosCheckerOption(
          id: 'faint',
          label: _en('Feeling faint, or having fainted'),
          weight: 3),
    ],
  ),

  // ===========================================================================
  //  CYCLE — the primary domain
  // ===========================================================================
  PcosCheckerQuestion(
    id: 'q_predictable',
    section: PcosSection.cycle,
    domain: PcosDomain.cycle,
    prompt: _en('How predictable are your periods?'),
    summaryLabel: _en('Regularity'),
    whyWeAsk: _en('This is the most useful thing you can tell a doctor. '
        "Irregular periods can mean ovulation isn't happening on a regular "
        "schedule. That's worth knowing, whatever the cause turns out to be."),
    options: [
      PcosCheckerOption(id: 'very_regular', label: _en('Very regular')),
      PcosCheckerOption(id: 'usually', label: _en('Usually regular')),
      PcosCheckerOption(
          id: 'sometimes', label: _en('Sometimes irregular'), weight: 1),
      PcosCheckerOption(id: 'often', label: _en('Often irregular'), weight: 2),
      PcosCheckerOption(
          id: 'very_unpredictable',
          label: _en('Very unpredictable'),
          weight: 3),
      PcosCheckerOption(
          id: 'rare', label: _en('I rarely get periods'), weight: 3),
      PcosCheckerOption(
          id: 'unsure', label: _en("I'm not sure"), unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_length',
    section: PcosSection.cycle,
    domain: PcosDomain.cycle,
    prompt: _en('How long is your usual cycle?'),
    summaryLabel: _en('Typical cycle length'),
    whyWeAsk: _en('A cycle runs from the day one period starts until the '
        'next one starts. Anything from about 21 to 35 days is usual.'),
    options: [
      PcosCheckerOption(
          id: 'short', label: _en('Less than 21 days'), weight: 1),
      PcosCheckerOption(id: 'normal', label: _en('21 to 35 days')),
      PcosCheckerOption(id: 'long', label: _en('36 to 45 days'), weight: 2),
      PcosCheckerOption(
          id: 'very_long', label: _en('More than 45 days'), weight: 3),
      PcosCheckerOption(id: 'varies', label: _en('It varies a lot'), weight: 2),
      PcosCheckerOption(
          id: 'unsure', label: _en("I don't know"), unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_gap',
    section: PcosSection.cycle,
    domain: PcosDomain.cycle,
    prompt: _en('Have you ever gone three months or more without a period, '
        "when you weren't pregnant?"),
    summaryLabel: _en('Longest gap'),
    whyWeAsk: _en('A gap that long is one of the clearer signs that a cycle '
        "isn't finishing. It's specific enough to ask about on its own."),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'yes', label: _en('Yes'), weight: 3),
      PcosCheckerOption(
          id: 'unsure', label: _en('Not sure'), unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_duration',
    section: PcosSection.cycle,
    // ⚠️ recordOnly. Bleeding length has many causes and is not a PCOS signal.
    // It is here because it belongs in the doctor summary, and it is scored at
    // zero deliberately.
    domain: PcosDomain.recordOnly,
    prompt: _en('When your period comes, how long does the bleeding usually '
        'last?'),
    summaryLabel: _en('Period length'),
    whyWeAsk: _en('This one is for your doctor summary, not your pattern. '
        "Bleeding length has many causes and isn't really a PCOS sign."),
    options: [
      PcosCheckerOption(id: 'short', label: _en('1 to 2 days')),
      PcosCheckerOption(id: 'normal', label: _en('3 to 7 days')),
      PcosCheckerOption(id: 'long', label: _en('More than 7 days')),
      PcosCheckerOption(id: 'varies', label: _en('Very unpredictable')),
      PcosCheckerOption(
          id: 'unsure', label: _en("I don't know"), unknown: true),
    ],
  ),

  // ===========================================================================
  //  OVULATION — the second primary domain
  // ===========================================================================
  PcosCheckerQuestion(
    id: 'q_mucus',
    section: PcosSection.ovulation,
    domain: PcosDomain.ovulation,
    prompt: _en('Do you usually notice a clear change in your cervical mucus '
        '(discharge) around your fertile days?'),
    summaryLabel: _en('Cervical mucus'),
    whyWeAsk: _en('Clear, slippery, stretchy mucus in the days before '
        "ovulation is a real sign. Not noticing it doesn't mean you're not "
        'ovulating. Most people have never been told to look.'),
    options: [
      PcosCheckerOption(id: 'most', label: _en('Yes, most cycles')),
      PcosCheckerOption(id: 'sometimes', label: _en('Sometimes'), weight: 1),
      PcosCheckerOption(id: 'rarely', label: _en('Rarely'), weight: 2),
      PcosCheckerOption(id: 'never', label: _en('Never'), weight: 2),
      PcosCheckerOption(
          id: 'untracked',
          label: _en("I don't track it"),
          unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_opk',
    section: PcosSection.ovulation,
    domain: PcosDomain.ovulation,
    prompt: _en('Have you used ovulation test strips?'),
    summaryLabel: _en('Ovulation strips'),
    whyWeAsk: _en('With PCOS, these strips can show positive several times '
        'in one cycle without ovulation following. The hormone they pick up '
        'can stay high instead of rising once. That pattern tells your doctor '
        'something too.'),
    options: [
      PcosCheckerOption(
          id: 'positive_expected',
          label: _en('Yes, usually positive around when I expect it')),
      PcosCheckerOption(
          id: 'unpredictable',
          label: _en('Yes, but the results are hard to predict'),
          weight: 2),
      PcosCheckerOption(
          id: 'rarely_positive',
          label: _en('Yes, but I rarely get a positive'),
          weight: 3),
      PcosCheckerOption(
          id: 'never_used', label: _en('No'), unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_told_anov',
    section: PcosSection.ovulation,
    domain: PcosDomain.ovulation,
    prompt: _en("Has a doctor ever told you that you don't ovulate "
        'regularly?'),
    summaryLabel: _en('Told about ovulation'),
    whyWeAsk: _en('If a doctor has already looked at this, what they found '
        'matters far more than anything a questionnaire can work out.'),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'yes', label: _en('Yes'), weight: 3),
      PcosCheckerOption(
          id: 'unsure', label: _en('Not sure'), unknown: true),
    ],
  ),

  // ===========================================================================
  //  ANDROGEN — the third primary domain
  // ===========================================================================
  PcosCheckerQuestion(
    id: 'q_hair_growth',
    section: PcosSection.androgen,
    domain: PcosDomain.androgen,
    prompt: _en('Have you noticed more facial or body hair than feels normal '
        'for you?'),
    summaryLabel: _en('Hair growth'),
    whyWeAsk: _en('"Normal for you" is what matters here. This varies a lot '
        "between people and between families, and there's no standard you "
        'have to meet.'),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'mild', label: _en('Mild'), weight: 1),
      PcosCheckerOption(id: 'noticeable', label: _en('Noticeable'), weight: 2),
      PcosCheckerOption(
          id: 'significant', label: _en('Significant'), weight: 3),
      PcosCheckerOption(
          id: 'unsure', label: _en('Not sure'), unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_acne',
    section: PcosSection.androgen,
    domain: PcosDomain.androgen,
    prompt: _en("Have you had acne that doesn't go away, especially after "
        'your teenage years?'),
    summaryLabel: _en('Acne'),
    whyWeAsk: _en('Acne that starts or carries on into adult life, often '
        'along the jaw and chin, can go with higher androgens (hormones like '
        "testosterone). On its own it's very common and means little."),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'sometimes', label: _en('Sometimes'), weight: 1),
      PcosCheckerOption(id: 'often', label: _en('Often'), weight: 2),
      PcosCheckerOption(
          id: 'persistent', label: _en('Most of the time'), weight: 3),
      PcosCheckerOption(
          id: 'unsure', label: _en('Not sure'), unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_thinning',
    section: PcosSection.androgen,
    domain: PcosDomain.androgen,
    prompt: _en('Have you noticed thinning at the scalp, or more shedding than '
        'usual?'),
    summaryLabel: _en('Scalp hair'),
    whyWeAsk: _en('Thinning on the top of the head in particular can go with '
        'higher androgens. Shedding after an illness, childbirth or a '
        'stressful time is a different and much more common thing.'),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'mild', label: _en('Mild'), weight: 1),
      PcosCheckerOption(id: 'noticeable', label: _en('Noticeable'), weight: 2),
      PcosCheckerOption(
          id: 'significant', label: _en('Significant'), weight: 3),
      PcosCheckerOption(
          id: 'unsure', label: _en('Not sure'), unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_skin_patches',
    section: PcosSection.androgen,
    domain: PcosDomain.androgen,
    prompt: _en('Have you noticed darker, velvety patches of skin at your neck, '
        'underarms or groin?'),
    summaryLabel: _en('Skin changes'),
    whyWeAsk: _en('We ask about this one on its own because it points to '
        'insulin rather than androgens, and almost nobody thinks to mention '
        'it.'),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'yes', label: _en('Yes'), weight: 2),
      PcosCheckerOption(
          id: 'unsure', label: _en('Not sure'), unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_weight',
    section: PcosSection.androgen,
    // ⚠️ recordOnly, AND THIS IS A CLINICAL DECISION RATHER THAN AN OVERSIGHT.
    // Weight carries no interpretive weight anywhere in this tool. Plenty of
    // women with textbook PCOS are slim; the association runs through insulin
    // rather than through the scale; and a checker that scored weight would be
    // telling larger women they are more likely to be ill. It is asked because
    // she may want it in her summary, and for no other reason.
    domain: PcosDomain.recordOnly,
    prompt: _en('Have you had unexplained weight changes, or found it hard '
        'to lose weight?'),
    summaryLabel: _en('Weight changes'),
    whyWeAsk: _en("This doesn't change your result at all. Weight doesn't "
        'cause PCOS or rule it out, and slim women have it too. It is here '
        'only in case you want it in your doctor summary.'),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'sometimes', label: _en('Sometimes')),
      PcosCheckerOption(id: 'yes', label: _en('Yes')),
      PcosCheckerOption(
          id: 'unsure', label: _en('Not sure'), unknown: true),
    ],
  ),

  // ===========================================================================
  //  FERTILITY — a modifier, never a pattern on its own
  // ===========================================================================
  PcosCheckerQuestion(
    id: 'q_trying',
    section: PcosSection.fertility,
    domain: PcosDomain.fertility,
    prompt: _en('How long have you been trying for a baby?'),
    summaryLabel: _en('Trying for'),
    whyWeAsk: _en('This changes how soon a conversation is worth having, not '
        'what your pattern means.'),
    options: [
      PcosCheckerOption(id: 'not_trying', label: _en("I'm not trying yet")),
      PcosCheckerOption(id: 'starting', label: _en('Just starting')),
      PcosCheckerOption(id: 'under6', label: _en('Less than 6 months')),
      PcosCheckerOption(id: 'six_twelve', label: _en('6 to 12 months'), weight: 1),
      PcosCheckerOption(
          id: 'over12', label: _en('More than 12 months'), weight: 2),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_prior_difficulty',
    section: PcosSection.fertility,
    domain: PcosDomain.fertility,
    prompt: _en('Have you had difficulty conceiving before?'),
    summaryLabel: _en('Previous difficulty'),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'yes', label: _en('Yes'), weight: 1),
      PcosCheckerOption(
          id: 'unsure', label: _en('Not sure'), unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_evaluated',
    section: PcosSection.fertility,
    domain: PcosDomain.fertility,
    prompt: _en('Have you had a fertility evaluation?'),
    summaryLabel: _en('Fertility evaluation'),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'yes', label: _en('Yes')),
      PcosCheckerOption(id: 'ongoing', label: _en('Currently having one')),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_eval_result',
    section: PcosSection.fertility,
    domain: PcosDomain.fertility,
    dependsOn: 'q_evaluated:yes',
    prompt: _en('What were you told?'),
    summaryLabel: _en('Told'),
    whyWeAsk: _en('If a doctor has already checked this, what they found '
        'counts for more than anything here.'),
    options: [
      PcosCheckerOption(id: 'pcos', label: _en('PCOS'), weight: 3),
      PcosCheckerOption(
          id: 'anovulation', label: _en('Irregular ovulation'), weight: 3),
      PcosCheckerOption(
          id: 'thyroid', label: _en('A thyroid or hormonal issue'), weight: 2),
      PcosCheckerOption(id: 'other', label: _en('Something else')),
      PcosCheckerOption(
          id: 'unclear',
          label: _en("I wasn't given a clear explanation"),
          unknown: true),
      PcosCheckerOption(id: 'private', label: _en('Prefer not to say')),
    ],
  ),

  // ===========================================================================
  //  CONTEXT — confounders. These CAP the reading, they do not feed it.
  // ===========================================================================
  PcosCheckerQuestion(
    id: 'q_contraception',
    section: PcosSection.context,
    domain: PcosDomain.context,
    prompt: _en('Are you using hormonal contraception, or did you stop '
        'recently?'),
    summaryLabel: _en('Hormonal contraception'),
    whyWeAsk: _en('This matters more than it sounds. Hormonal contraception '
        'controls when you bleed, instead of letting a cycle run on its own. '
        'So period answers stop telling us about ovulation. Cycles can also '
        'take a few months to settle after stopping.'),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'yes', label: _en('Yes, currently'), weight: 3),
      PcosCheckerOption(
          id: 'stopped',
          label: _en('Stopped within the last few months'),
          weight: 2),
      PcosCheckerOption(
          id: 'unsure', label: _en('Not sure'), unknown: true),
    ],
  ),

  PcosCheckerQuestion(
    id: 'q_postpartum',
    section: PcosSection.context,
    domain: PcosDomain.context,
    prompt: _en('Have you given birth or breastfed in the last year?'),
    summaryLabel: _en('Recent birth or breastfeeding'),
    whyWeAsk: _en('Both change cycles a lot, for completely normal reasons. '
        'So a pattern during this time says much less than it would '
        'otherwise.'),
    options: [
      PcosCheckerOption(id: 'no', label: _en('No')),
      PcosCheckerOption(id: 'yes', label: _en('Yes'), weight: 3),
    ],
  ),
];

PcosCheckerQuestion? pcosQuestionById(String id) {
  for (final q in kPcosQuestions) {
    if (q.id == id) return q;
  }
  return null;
}
