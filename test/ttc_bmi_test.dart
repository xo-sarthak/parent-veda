// =============================================================================
//  The BMI engine is deterministic, and the tool refuses to be a verdict
// -----------------------------------------------------------------------------
//  §30 of the brief asks for boundary coverage on the calculation. That is the
//  first half of this file. The second half is the part that matters more: the
//  copy rules, restated as assertions, so nobody later turns a screening
//  measure into a judgement about a body.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as math;

import 'package:parentveda/ttc/ttc_bmi_rules.dart';

BmiInput _metric({double? cm, double? kg}) => BmiInput(
      heightUnit: BmiHeightUnit.cm,
      weightUnit: BmiWeightUnit.kg,
      cm: cm,
      kg: kg,
    );

/// Height in metres that puts [target] BMI at [kg].
///
/// BMI = kg / m², so m = sqrt(kg / bmi). An earlier version of this helper
/// omitted the root and produced a 2.6 m subject.
double _mFor(double kg, double target) => math.sqrt(kg / target);

void main() {
  group('the calculation', () {
    test('metric, the worked example from the brief', () {
      final c = calculateBmi(_metric(cm: 165, kg: 65))!;
      expect(c.display, '23.9');
    });

    test('imperial converts correctly', () {
      // 5 ft 5 in = 1.651 m, 143 lb = 64.86 kg -> ~23.8
      final c = calculateBmi(const BmiInput(
        heightUnit: BmiHeightUnit.ftIn,
        weightUnit: BmiWeightUnit.lb,
        feet: 5,
        inches: 5,
        lb: 143,
      ))!;
      expect(c.bmi, closeTo(23.79, 0.05));
    });

    test('metric and imperial for the same body agree', () {
      // ⚠️ THE CONVERSION TEST THAT ACTUALLY MATTERS. A unit toggle that
      // shifts the number is worse than no toggle — she would think her body
      // changed when only the dropdown did.
      final a = calculateBmi(_metric(cm: 170, kg: 70))!;
      final b = calculateBmi(const BmiInput(
        heightUnit: BmiHeightUnit.ftIn,
        weightUnit: BmiWeightUnit.lb,
        feet: 5,
        inches: 7, // 5'7" = 170.18 cm
        lb: 154.324, // = 70 kg
      ))!;
      expect(b.bmi, closeTo(a.bmi, 0.1));
    });

    test('decimals are respected, not truncated', () {
      final c = calculateBmi(_metric(cm: 162.5, kg: 58.4))!;
      expect(c.bmi, closeTo(58.4 / (1.625 * 1.625), 0.0001));
    });

    test('intermediate values are not rounded', () {
      // A body that lands a hair under a boundary must not be rounded over it.
      final c = calculateBmi(_metric(cm: 100 * _mFor(60, 22.999), kg: 60))!;
      expect(c.bmi, lessThan(23.0));
      expect(categoriseBmi(c.bmi, BmiStandard.southAsian).band,
          BmiBand.healthy);
    });
  });

  group('category boundaries — international', () {
    const s = BmiStandard.international;
    test('18.4 is under, 18.5 is healthy', () {
      expect(categoriseBmi(18.4, s).band, BmiBand.under);
      expect(categoriseBmi(18.5, s).band, BmiBand.healthy);
    });
    test('24.9 is healthy, 25.0 is over', () {
      expect(categoriseBmi(24.9, s).band, BmiBand.healthy);
      expect(categoriseBmi(25.0, s).band, BmiBand.over);
    });
    test('29.9 is over, 30.0 is obese', () {
      expect(categoriseBmi(29.9, s).band, BmiBand.over);
      expect(categoriseBmi(30.0, s).band, BmiBand.obese);
    });
  });

  group('category boundaries — South Asian, and these are the primary ones',
      () {
    const s = BmiStandard.southAsian;
    test('the default standard is South Asian', () {
      // ⚠️ INDIA-FIRST, DECIDED EXPLICITLY. If this ever flips, an Indian
      // woman is being read against European thresholds — which is the exact
      // thing `ttc_read_three_months_before` tells her is wrong.
      expect(kBmiPrimaryStandard, BmiStandard.southAsian);
      expect(kBmiSecondaryStandard, BmiStandard.international);
    });
    test('22.9 is healthy, 23.0 is over', () {
      expect(categoriseBmi(22.9, s).band, BmiBand.healthy);
      expect(categoriseBmi(23.0, s).band, BmiBand.over);
    });
    test('24.9 is over, 25.0 is obese', () {
      expect(categoriseBmi(24.9, s).band, BmiBand.over);
      expect(categoriseBmi(25.0, s).band, BmiBand.obese);
    });
    test('the same number reads differently under each standard', () {
      // 24.0: "over" for South Asian, "healthy" internationally. This is the
      // case the second reading on the result screen exists to explain.
      expect(categoriseBmi(24.0, BmiStandard.southAsian).band, BmiBand.over);
      expect(categoriseBmi(24.0, BmiStandard.international).band,
          BmiBand.healthy);
    });
  });

  group('invalid input is refused with a sentence, not a shrug', () {
    test('zero and negative are refused', () {
      expect(validateBmiInput(_metric(cm: 0, kg: 60)),
          BmiInputError.heightMissing);
      expect(validateBmiInput(_metric(cm: -165, kg: 60)),
          BmiInputError.heightMissing);
      expect(validateBmiInput(_metric(cm: 165, kg: 0)),
          BmiInputError.weightMissing);
      expect(validateBmiInput(_metric(cm: 165, kg: -60)),
          BmiInputError.weightMissing);
    });

    test('missing values are refused', () {
      expect(validateBmiInput(_metric(kg: 60)), BmiInputError.heightMissing);
      expect(validateBmiInput(_metric(cm: 165)), BmiInputError.weightMissing);
    });

    test('implausible values are refused', () {
      expect(validateBmiInput(_metric(cm: 16, kg: 60)),
          BmiInputError.heightImplausible);
      expect(validateBmiInput(_metric(cm: 165, kg: 700)),
          BmiInputError.weightImplausible);
    });

    test('inches out of range are refused', () {
      expect(
          validateBmiInput(const BmiInput(
            heightUnit: BmiHeightUnit.ftIn,
            weightUnit: BmiWeightUnit.kg,
            feet: 5,
            inches: 13,
            kg: 60,
          )),
          BmiInputError.inchesOutOfRange);
    });

    test('calculateBmi returns null rather than a wrong number', () {
      expect(calculateBmi(_metric(cm: 0, kg: 60)), isNull);
    });

    test('every error names what to type', () {
      for (final e in BmiInputError.values) {
        if (e == BmiInputError.none) continue;
        expect(bmiErrorCopy(e).en.trim(), isNotEmpty, reason: e.name);
        expect(bmiErrorCopy(e).en.toLowerCase().contains('invalid'), isFalse,
            reason: '"invalid" tells her nothing about what to do');
      }
    });
  });

  group('scope — the two cases that refuse to interpret at all', () {
    test('pregnancy is not interpreted as a BMI reading', () {
      final c = calculateBmi(_metric(cm: 165, kg: 65));
      final r = interpretBmi(c, const BmiContext(isPregnant: true));
      expect(r.scope, BmiScope.pregnant);
      expect(r.interpreted, isFalse);
    });

    test('under 18 gets no adult category', () {
      final c = calculateBmi(_metric(cm: 160, kg: 50));
      final r = interpretBmi(c, const BmiContext(isMinor: true));
      expect(r.scope, BmiScope.minor);
      expect(r.interpreted, isFalse);
    });
  });

  group('it never becomes a verdict, a target or a fertility score', () {
    List<String> allCopy() {
      final out = <String>[
        kBmiDisclaimer.en,
        kBmiNotTheWholeStory.en,
        kBmiStandardsExplainer.en,
        for (final l in kBmiLimitations) l.en,
      ];
      for (final band in BmiBand.values) {
        for (final std in BmiStandard.values) {
          // Pick a BMI inside each band for each standard.
          final bmi = switch (band) {
            BmiBand.under => 17.0,
            BmiBand.healthy => 21.0,
            BmiBand.over => std == BmiStandard.southAsian ? 24.0 : 27.0,
            BmiBand.obese => std == BmiStandard.southAsian ? 26.0 : 32.0,
          };
          final c = calculateBmi(_metric(cm: 165, kg: bmi * 1.65 * 1.65))!;
          final r = interpretBmi(c, const BmiContext(), standard: std);
          out..add(r.headline.en)..add(r.body.en)..add(r.preconception.en);
        }
      }
      // Context and change notes.
      final c = calculateBmi(_metric(cm: 165, kg: 80))!;
      final withCtx = interpretBmi(
          c, const BmiContext(hasPcosPattern: true, previousKg: 60));
      out
        ..add(withCtx.contextNote?.en ?? '')
        ..add(withCtx.changeNote?.en ?? '');
      for (final e in BmiInputError.values) {
        out.add(bmiErrorCopy(e).en);
      }
      return out;
    }

    test('never says "you are" a category', () {
      // ⚠️ THE TONE RULE, AS A TEST. "Your BMI is above the standard range"
      // describes a number. "You are overweight" describes a person.
      final banned = RegExp(
          r'\byou are (over|under)weight\b|\byou are obese\b'
          r'|\byou are too (fat|thin|heavy|light)\b',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    });

    test('never prescribes weight loss or a target', () {
      final banned = RegExp(
          r'\byou (should|must|need to) lose\b'
          r'|\blose weight before\b'
          r'|\btarget weight of\b'
          r'|\bideal weight\b'
          r'|\blose \d+\s?(kg|kilos|pounds|lb)\b',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    });

    test('never links BMI to a chance of conceiving', () {
      final banned = RegExp(
          r'%|\bfertility score\b|\byour chances?\b|\bodds\b'
          r'|\bwill struggle to conceive\b|\bcannot conceive\b',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    });

    test('the higher bands say BMI cannot predict conceiving', () {
      final c = calculateBmi(_metric(cm: 165, kg: 70))!; // ~25.7, over/obese
      final r = interpretBmi(c, const BmiContext());
      final all = '${r.body.en} ${r.preconception.en}'.toLowerCase();
      expect(all.contains('cannot tell you whether you will have difficulty') ||
          all.contains('says nothing about whether you can have a healthy'),
          isTrue,
          reason: 'the higher bands must actively refuse the inference');
    });

    test('a low BMI is not assumed to be unhealthy', () {
      final c = calculateBmi(_metric(cm: 165, kg: 45))!; // ~16.5
      final r = interpretBmi(c, const BmiContext());
      expect(r.body.en.toLowerCase(),
          contains('does not tell us why'));
    });

    test('the context note never infers a condition from the number', () {
      // No PCOS told to us -> no PCOS mentioned, whatever the BMI.
      final c = calculateBmi(_metric(cm: 165, kg: 95))!;
      final r = interpretBmi(c, const BmiContext());
      expect(r.contextNote, isNull,
          reason: 'a high BMI must never suggest PCOS on its own');
    });

    test('the change note names no reason', () {
      final c = calculateBmi(_metric(cm: 165, kg: 72))!;
      final r = interpretBmi(c, const BmiContext(previousKg: 62));
      expect(r.changeNote, isNotNull);
      final note = r.changeNote!.en.toLowerCase();
      expect(note.contains('great') || note.contains('well done'), isFalse);
      expect(note.contains('worth mentioning'), isTrue);
    });

    test('a small change is not remarked on at all', () {
      final c = calculateBmi(_metric(cm: 165, kg: 64))!;
      final r = interpretBmi(c, const BmiContext(previousKg: 62));
      expect(r.changeNote, isNull,
          reason: 'a calculator that comments on two kilos is a scale that '
              'judges');
    });

    test('the disclaimer refuses diagnosis and prediction', () {
      final d = kBmiDisclaimer.en.toLowerCase();
      expect(d.contains('does not diagnose'), isTrue);
      expect(d.contains('does not predict fertility'), isTrue);
    });
  });

  group('the clinical-review register covers the thresholds', () {
    test('it is non-empty and names both standards', () {
      expect(kBmiReviewRegister, isNotEmpty);
      final areas = kBmiReviewRegister.map((r) => r.area).join(' ');
      expect(areas.contains('international'), isTrue);
      expect(areas.contains('South Asian'), isTrue);
    });

    test('the unsettled South Asian obesity cut-off is flagged', () {
      // 25 vs 27.5 is a genuine disagreement between sources and must not be
      // shipped as though it were settled.
      final claim = kBmiReviewRegister
          .firstWhere((r) => r.area.contains('South Asian'))
          .claim;
      expect(claim.contains('27.5'), isTrue);
      expect(claim.toUpperCase().contains('NOT SETTLED'), isTrue);
    });
  });
}
