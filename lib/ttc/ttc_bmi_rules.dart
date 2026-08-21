// =============================================================================
//  BMI — the calculation engine, the category rules, and the interpretation
// -----------------------------------------------------------------------------
//  ⚠️ A SCREENING MEASURE. NOT A DIAGNOSIS, NOT A FERTILITY SCORE, NOT A
//  VERDICT ON A BODY.
//
//  Nothing in this file may produce a target weight, a probability of
//  conceiving, or any sentence beginning "you are". BMI is one number derived
//  from two others; it cannot see body composition, metabolic health,
//  nutrition or fertility, and a tool that implies otherwise is doing harm on
//  the topic most likely to be heard as blame.
//
//  ---------------------------------------------------------------------------
//  ⚠️ TWO SETS OF THRESHOLDS, AND WHY BOTH ARE SHOWN
//  ---------------------------------------------------------------------------
//
//  The brief specifies the WHO international cut-offs — 18.5 / 25 / 30. Those
//  are correct and they are also not the ones used in India.
//
//  ICMR, the WHO Asia-Pacific classification and NICE's 2023 South Asian
//  guidance all place overweight at 23 and obesity at 25, because South Asians
//  accumulate visceral fat at lower body weights and metabolic risk appears
//  earlier. `ttc_read_three_months_before` — already shipped — says exactly
//  this: "BMI reads Indian bodies badly. The thresholds were derived from
//  European populations."
//
//  So a calculator showing only the international bands would contradict an
//  article two taps away inside the same app, in an India-first product.
//
//  ⚠️ THE SOUTH ASIAN BANDS ARE THE PRIMARY READING. Decided explicitly — this
//  is an India-first product and these are the thresholds Indian clinical
//  bodies use. The international band is still shown, clearly labelled and
//  second, for one practical reason: plenty of Indian labs, apps and doctors
//  still quote the international figure, and a woman who sees 24.2 called
//  "overweight" here and "healthy" on a lab printout needs to know why rather
//  than assume one of them is broken.
//
//  ⚠️ THE SOUTH ASIAN OBESITY CUT-OFF IS NOT SETTLED. Widely-cited sources give
//  25; more recent ICMR guidance gives 27.5. 25 is used here as the commoner
//  figure and the whole band is flagged for clinical review below.
//
//  ---------------------------------------------------------------------------
//  ⚠️ DETERMINISTIC AND PURE. `calculateBmi` touches no store, no clock and no
//  locale, so `test/ttc_bmi_test.dart` can pin every boundary. Intermediate
//  values are never rounded — only the displayed number is.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  Input
// -----------------------------------------------------------------------------

enum BmiHeightUnit { cm, ftIn }

enum BmiWeightUnit { kg, lb }

@immutable
class BmiInput {
  const BmiInput({
    required this.heightUnit,
    required this.weightUnit,
    this.cm,
    this.feet,
    this.inches,
    this.kg,
    this.lb,
  });

  final BmiHeightUnit heightUnit;
  final BmiWeightUnit weightUnit;

  final double? cm;
  final int? feet;
  final double? inches;
  final double? kg;
  final double? lb;

  /// Height in metres, or null when the input cannot produce one.
  ///
  /// ⚠️ NO ROUNDING HERE. Converting to centimetres and back loses precision
  /// that shows up as a BMI landing on the wrong side of a boundary.
  double? get metres {
    switch (heightUnit) {
      case BmiHeightUnit.cm:
        final v = cm;
        return (v == null || v <= 0) ? null : v / 100.0;
      case BmiHeightUnit.ftIn:
        final f = feet, i = inches ?? 0;
        if (f == null || f <= 0 || i < 0 || i >= 12) return null;
        return ((f * 12) + i) * 0.0254;
    }
  }

  double? get kilograms {
    switch (weightUnit) {
      case BmiWeightUnit.kg:
        final v = kg;
        return (v == null || v <= 0) ? null : v;
      case BmiWeightUnit.lb:
        final v = lb;
        return (v == null || v <= 0) ? null : v * 0.45359237;
    }
  }
}

/// Why an input could not be used. Each maps to a sentence that says what to
/// type, rather than "invalid input".
enum BmiInputError {
  none,
  heightMissing,
  heightImplausible,
  weightMissing,
  weightImplausible,
  inchesOutOfRange,
}

/// ⚠️ PLAUSIBILITY BOUNDS, NOT VALIDATION THEATRE. The point is to catch a
/// mis-tap — 16 cm, 700 kg — not to tell anyone their body is out of range.
/// Deliberately wide.
const double kBmiMinHeightM = 1.20;
const double kBmiMaxHeightM = 2.30;
const double kBmiMinWeightKg = 25.0;
const double kBmiMaxWeightKg = 300.0;

BmiInputError validateBmiInput(BmiInput input) {
  if (input.heightUnit == BmiHeightUnit.ftIn) {
    final i = input.inches;
    if (i != null && (i < 0 || i >= 12)) return BmiInputError.inchesOutOfRange;
  }
  final m = input.metres;
  if (m == null) return BmiInputError.heightMissing;
  if (m < kBmiMinHeightM || m > kBmiMaxHeightM) {
    return BmiInputError.heightImplausible;
  }
  final kg = input.kilograms;
  if (kg == null) return BmiInputError.weightMissing;
  if (kg < kBmiMinWeightKg || kg > kBmiMaxWeightKg) {
    return BmiInputError.weightImplausible;
  }
  return BmiInputError.none;
}

LocalizedText bmiErrorCopy(BmiInputError e) => switch (e) {
      BmiInputError.none => _en(''),
      BmiInputError.heightMissing =>
        _en('Add your height. If you are 165 cm, enter 165.'),
      BmiInputError.heightImplausible =>
        _en('That height looks like a typo — check the number and the unit.'),
      BmiInputError.weightMissing =>
        _en('Add your weight. If you are 62 kg, enter 62.'),
      BmiInputError.weightImplausible =>
        _en('That weight looks like a typo — check the number and the unit.'),
      BmiInputError.inchesOutOfRange =>
        _en('Inches should be between 0 and 11. For 5 foot 4, enter 5 and 4.'),
    };

// -----------------------------------------------------------------------------
//  Categories
// -----------------------------------------------------------------------------

enum BmiBand { under, healthy, over, obese }

/// Which set of thresholds a band came from.
enum BmiStandard {
  /// WHO international: 18.5 / 25 / 30.
  international,

  /// ICMR / WHO Asia-Pacific / NICE South Asian: 18.5 / 23 / 25.
  southAsian,
}

@immutable
class BmiCategory {
  const BmiCategory({required this.band, required this.standard});
  final BmiBand band;
  final BmiStandard standard;

  /// ⚠️ NEVER "YOU ARE". The band describes where a number falls, not a person.
  LocalizedText get label => switch (band) {
        BmiBand.under => _en('Below the standard range'),
        BmiBand.healthy => _en('Within the standard range'),
        BmiBand.over => _en('Above the standard range'),
        BmiBand.obese => _en('In the obesity category'),
      };
}

/// ⚠️ THE THRESHOLDS. Everything else in this feature reads them from here.
const double kBmiUnderCut = 18.5;
const double kBmiOverCutIntl = 25.0;
const double kBmiObeseCutIntl = 30.0;
const double kBmiOverCutSouthAsian = 23.0;
const double kBmiObeseCutSouthAsian = 25.0;

/// ⚠️ THE DEFAULT, AND IT IS THE SOUTH ASIAN ONE. India-first is not a
/// tagline here — reading an Indian woman against European thresholds is the
/// specific thing `ttc_read_three_months_before` already tells her is wrong.
const BmiStandard kBmiPrimaryStandard = BmiStandard.southAsian;

const BmiStandard kBmiSecondaryStandard = BmiStandard.international;

BmiCategory categoriseBmi(double bmi, BmiStandard standard) {
  final over = standard == BmiStandard.international
      ? kBmiOverCutIntl
      : kBmiOverCutSouthAsian;
  final obese = standard == BmiStandard.international
      ? kBmiObeseCutIntl
      : kBmiObeseCutSouthAsian;

  final band = bmi < kBmiUnderCut
      ? BmiBand.under
      : bmi < over
          ? BmiBand.healthy
          : bmi < obese
              ? BmiBand.over
              : BmiBand.obese;
  return BmiCategory(band: band, standard: standard);
}

// -----------------------------------------------------------------------------
//  The calculation
// -----------------------------------------------------------------------------

/// Why the tool declined to interpret a number.
enum BmiScope {
  /// Interpreted normally.
  adultPreconception,

  /// Under 18 — adult bands do not apply, so none is shown.
  minor,

  /// Already pregnant — BMI is not a pregnancy weight measure.
  pregnant,
}

@immutable
class BmiCalculation {
  const BmiCalculation({
    required this.bmi,
    required this.metres,
    required this.kilograms,
  });

  final double bmi;
  final double metres;
  final double kilograms;

  /// One decimal place, for display only.
  String get display => bmi.toStringAsFixed(1);
}

/// The engine. Pure, deterministic, and the thing the unit tests pin.
BmiCalculation? calculateBmi(BmiInput input) {
  if (validateBmiInput(input) != BmiInputError.none) return null;
  final m = input.metres!;
  final kg = input.kilograms!;
  return BmiCalculation(bmi: kg / (m * m), metres: m, kilograms: kg);
}

// -----------------------------------------------------------------------------
//  Interpretation
// -----------------------------------------------------------------------------

/// What the app already knows that changes what is worth saying.
@immutable
class BmiContext {
  const BmiContext({
    this.isPregnant = false,
    this.isMinor = false,
    this.hasPcosPattern = false,
    this.irregularCycles = false,
    this.previousKg,
  });

  final bool isPregnant;
  final bool isMinor;

  /// From the PCOS checker. Used ONLY to suggest that a preconception
  /// conversation is more useful — never to imply BMI caused or indicates it.
  final bool hasPcosPattern;
  final bool irregularCycles;

  /// The last saved weight, for the change note.
  final double? previousKg;
}

@immutable
class BmiInterpretation {
  const BmiInterpretation({
    required this.scope,
    required this.headline,
    required this.body,
    required this.preconception,
    this.contextNote,
    this.changeNote,
  });

  final BmiScope scope;
  final LocalizedText headline;
  final LocalizedText body;

  /// "What does this mean before pregnancy?"
  final LocalizedText preconception;

  /// Surfaced only where the app genuinely knows something relevant.
  final LocalizedText? contextNote;

  /// Shown when this measurement differs a lot from the last one.
  final LocalizedText? changeNote;

  bool get interpreted => scope == BmiScope.adultPreconception;
}

/// ⚠️ WEIGHT CHANGE THAT EARNS A MENTION. Deliberately large — a couple of
/// kilos between entries is noise, and flagging it would turn a calculator
/// into a scale that comments.
const double kBmiNotableChangeKg = 5.0;

BmiInterpretation interpretBmi(BmiCalculation? calc, BmiContext context,
    {BmiStandard standard = kBmiPrimaryStandard}) {
  // ---- SCOPE FIRST. Both of these refuse to interpret. ----------------------
  if (context.isPregnant) {
    return BmiInterpretation(
      scope: BmiScope.pregnant,
      headline: _en('This is not the right tool right now'),
      body: _en('BMI is calculated differently from pregnancy weight gain, and '
          'a preconception reading of it would not tell you anything useful '
          'now that you are pregnant.'),
      preconception: _en('Your pregnancy journey tracks weight the way it is '
          'actually monitored in pregnancy.'),
    );
  }

  if (context.isMinor) {
    return BmiInterpretation(
      scope: BmiScope.minor,
      headline: _en('Adult BMI bands do not apply here'),
      body: _en('BMI is read differently under 18, because age and sex are '
          'taken into account while a body is still growing. This calculator '
          'is built for adults, so it will not give you a category.'),
      preconception: _en('A doctor can interpret it properly using the charts '
          'made for it.'),
    );
  }

  if (calc == null) {
    return BmiInterpretation(
      scope: BmiScope.adultPreconception,
      headline: _en('Add your height and weight'),
      body: _en('Both are needed to work anything out.'),
      preconception: _en(''),
    );
  }

  final cat = categoriseBmi(calc.bmi, standard);

  // ---- CHANGE NOTE ---------------------------------------------------------
  LocalizedText? change;
  final prev = context.previousKg;
  if (prev != null && (calc.kilograms - prev).abs() >= kBmiNotableChangeKg) {
    // ⚠️ NAMES NO REASON AND OFFERS NO CONGRATULATION. Weight moves for many
    // reasons, several of them worth a doctor and none of them ours to guess.
    change = _en('This is quite different from your last entry. If the change '
        'was unexpected, it is worth mentioning to your doctor.');
  }

  // ---- CONTEXT NOTE --------------------------------------------------------
  //
  // ⚠️ NEVER INFERS A CONDITION FROM A NUMBER. A higher BMI does not suggest
  // PCOS and a lower one does not suggest undernutrition. This only fires when
  // she has ALREADY told us something, and it only ever says a conversation
  // may be useful.
  LocalizedText? contextNote;
  if (context.hasPcosPattern) {
    contextNote = _en('You have already told us about a PCOS pattern. That '
        'makes a preconception conversation more useful than usual — not '
        'because of this number, but because it is worth looking at these '
        'things together.');
  } else if (context.irregularCycles) {
    contextNote = _en('You have logged cycles that vary quite a bit. Worth '
        'raising alongside anything else, rather than on its own.');
  }

  return BmiInterpretation(
    scope: BmiScope.adultPreconception,
    headline: cat.label,
    body: _bandBody(cat),
    preconception: _bandPreconception(cat.band),
    contextNote: contextNote,
    changeNote: change,
  );
}

LocalizedText _bandBody(BmiCategory cat) {
  final southAsian = cat.standard == BmiStandard.southAsian;
  return switch (cat.band) {
    BmiBand.healthy => _en('Your BMI falls within the standard adult range '
        '${southAsian ? 'used for South Asian populations' : 'used '
            'internationally'}. BMI is one measure among several, and it is '
        'best read alongside your overall health, nutrition, activity and '
        'medical history.'),
    BmiBand.under => _en('Your BMI is below the standard adult range. That on '
        'its own does not tell us why. If you have irregular periods, '
        'unintentional weight loss, low appetite or any concern about '
        'nutrition, those are the things worth raising with a doctor.'),
    BmiBand.over => _en('Your BMI is above the standard adult range '
        '${southAsian ? 'used for South Asian populations' : 'used '
            'internationally'}. ⚠️ BMI alone cannot tell you how healthy you '
        'are, and it cannot tell you whether you will have difficulty '
        'conceiving. It is a starting point for a conversation, not a '
        'conclusion.'),
    BmiBand.obese => _en('Your BMI falls in the obesity category used in '
        'standard adult classifications. ⚠️ This is a screening category, not '
        'a diagnosis. Some pregnancy risks are higher at this BMI, which makes '
        'a preconception conversation worth having — and it says nothing about '
        'whether you can have a healthy pregnancy.'),
  };
}

LocalizedText _bandPreconception(BmiBand band) => switch (band) {
      BmiBand.healthy => _en('BMI can be one part of a preconception '
          'conversation. A doctor reads it alongside blood pressure, blood '
          'sugar, nutrition, activity and your history — which is why none of '
          'them is looked at on its own.'),
      BmiBand.under => _en('Rather than focusing on the number, the useful '
          'questions are whether you are getting enough energy and nutrients, '
          'and whether your cycles are regular. Both are worth raising.'),
      // ⚠️ NO TARGET, NO DIET, NO "LOSE WEIGHT BEFORE TRYING". The evidence
      // supports a modest sustained change where weight is raised — and
      // postponing trying for a year to reach a number trades a small benefit
      // for a year of age, which for many women is the worse deal.
      BmiBand.over => _en('Rather than aiming at a number, the more useful '
          'question is overall health. If you have concerns about blood '
          'pressure, blood sugar, PCOS, periods or nutrition, a preconception '
          'review covers all of it at once. Any change to eating or weight is '
          'more useful gradual and sustainable than rapid — and that is a '
          'conversation for a doctor or dietitian who knows you.'),
      BmiBand.obese => _en('Rather than aiming at a number, the more useful '
          'question is overall health. A preconception review can look at '
          'blood pressure, blood sugar and anything else relevant together. If '
          'you are considering changes to eating or weight, gradual and '
          'sustainable is generally more useful than rapid dieting, and a '
          'doctor or dietitian can tailor it to you.'),
    };

/// The "not the whole picture" card. Editorial, never labelled a tip.
final LocalizedText kBmiNotTheWholeStory = _en(
    'Two people can have the same BMI and completely different health. Muscle, '
    'body composition, where fat sits, nutrition and medical history all '
    'matter, and BMI sees none of them.');

/// What BMI does not measure. Shown in a collapsible section.
final List<LocalizedText> kBmiLimitations = [
  _en('Body fat percentage, or how much of your weight is muscle'),
  _en('Where body fat is distributed — which matters more than the total'),
  _en('Nutritional status'),
  _en('Metabolic health, such as blood sugar or blood pressure'),
  _en('Fertility'),
  _en('Fitness'),
];

/// The disclaimer, on every result.
final LocalizedText kBmiDisclaimer = _en(
    'BMI is a screening measure. It does not diagnose any condition and it '
    'does not predict fertility. A healthcare professional can read it '
    'alongside your overall health and history.');

/// Why the two sets of numbers differ. Shown beside the second reading.
final LocalizedText kBmiStandardsExplainer = _en(
    'We use the South Asian thresholds, because you are being read against '
    'people built like you. ICMR, the WHO Asia-Pacific classification and NICE '
    'all set overweight at 23 and obesity at 25 for South Asian people, since '
    'metabolic risk tends to appear at a lower BMI than the international '
    'numbers assume — those were derived largely from European populations. '
    'The international figure is shown below it because you will meet it: '
    'plenty of labs, apps and doctors still quote it. The same number can be '
    '"above the range" here and "within" there, and neither is broken. Waist '
    'measurement is often more informative than either.');

// -----------------------------------------------------------------------------
//  Clinical-review register
// -----------------------------------------------------------------------------

/// ⚠️ EVERY CLAIM IN THIS FEATURE NEEDING A NAMED CLINICIAN, IN ONE PLACE —
/// §28. Kept here rather than in a doc so it cannot drift from the code, and
/// generated as data so it can be printed into a review pack.
///
/// `docs/STILL-OPEN.md` §14.0 holds the named-clinician question itself.
const List<({String area, String claim})> kBmiReviewRegister = [
  (
    area: 'Category thresholds — international',
    claim: 'Underweight <18.5, healthy 18.5–24.9, overweight 25.0–29.9, '
        'obesity ≥30.0.'
  ),
  (
    area: 'Category thresholds — South Asian',
    claim: '⚠️ NOT SETTLED. Overweight ≥23 and obesity ≥25 are used here per '
        'WHO Asia-Pacific, ICMR and NICE 2023 South Asian guidance. More '
        'recent ICMR material gives obesity ≥27.5. Which to ship needs a call.'
  ),
  (
    area: 'Showing both standards',
    claim: 'The decision to show international and South Asian bands side by '
        'side rather than picking one.'
  ),
  (
    area: 'Higher-BMI wording',
    claim: 'That some pregnancy risks are higher, stated without implying '
        'inability to conceive or to have a healthy pregnancy.'
  ),
  (
    area: 'Lower-BMI wording',
    claim: 'That a low BMI is not assumed to be unhealthy, and the symptoms '
        'named as worth raising.'
  ),
  (
    area: 'Weight-change guidance',
    claim: 'Gradual and sustainable over rapid dieting; no target weight and '
        'no instruction to lose weight before trying.'
  ),
  (
    area: 'Pregnancy handling',
    claim: 'Refusing to interpret BMI as a pregnancy weight measure.'
  ),
  (
    area: 'Adolescent handling',
    claim: 'Refusing adult bands under 18.'
  ),
  (
    area: 'Weight-change flag',
    claim: 'The 5 kg threshold for suggesting a doctor conversation.'
  ),
];
