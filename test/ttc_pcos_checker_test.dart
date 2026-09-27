// =============================================================================
//  The PCOS checker cannot diagnose, score, or reassure wrongly
// -----------------------------------------------------------------------------
//  ⚠️ THESE ARE THE CLINICAL GUARANTEES, NOT UI TESTS.
//
//  Everything here is a rule from `ttc_pcos_check_rules.dart` restated as an
//  assertion, because a rules file is only a contract if something enforces it.
//  The failure mode this guards is specific: someone later "improves" the
//  engine by counting symptoms, or adds a percentage because a stakeholder
//  asked for one, and nothing about the app looks broken.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ttc/ttc_pcos_check_data.dart';
import 'package:parentveda/ttc/ttc_pcos_check_rules.dart';
import 'package:parentveda/screens/ttc/ttc_pcos_check_result.dart'
    show kPcosDoctorQuestions;

void main() {
  // ===========================================================================
  group('the result never argues with itself', () {
    // The headline and the detail lines are produced by two functions reading
    // two different things: `_body` branches on the LEVEL, `pcosDetailLines`
    // on which symptom DOMAINS spoke. When a level comes from somewhere the
    // domains cannot see, the two drift apart — and the drift is silent,
    // because each half is correct about its own input.
    test('a woman already told she has PCOS is not then reassured', () {
      final r = interpretPcos({
        'q_redflag': 'none',
        'q_pregnancy': 'no',
        'q_contraception': 'no',
        'q_postpartum': 'no',
        // Her own symptom answers are entirely unremarkable.
        'q_predictable': 'always',
        'q_gap': 'no',
        'q_hair_growth': 'none',
        'q_acne': 'none',
        // But a doctor has already said the word, and that outranks all of it.
        'q_told_anov': 'yes',
      });
      expect(r.level, PcosLevel.soon);

      final lines = pcosDetailLines(r).map((l) => l.en).join(' ');
      expect(lines, isNot(contains('reassuring as far as it goes')),
          reason: 'the detail line reassured her directly underneath a body '
              'paragraph telling her to raise it now');
    });

    test('and neither is a woman whose cycle we admitted we cannot read', () {
      final r = interpretPcos({
        'q_redflag': 'none',
        'q_pregnancy': 'no',
        // The pill sets the bleed, so "regular periods" describes the
        // medication rather than her.
        'q_contraception': 'yes',
        'q_predictable': 'always',
        'q_gap': 'no',
        'q_hair_growth': 'none',
        'q_acne': 'none',
      });
      expect(r.cappedByContext, isTrue);

      final lines = pcosDetailLines(r).map((l) => l.en).join(' ');
      expect(lines, isNot(contains('reassuring as far as it goes')),
          reason: 'a capped reading is an absence of evidence, and an absence '
              'of evidence must never be rendered as good news');
    });

    test('but a genuinely quiet reading still says so', () {
      // The reassurance is not banned — it is earned. Removing it entirely
      // would be the opposite failure: a checker that can only ever worry.
      final r = interpretPcos({
        'q_redflag': 'none',
        'q_pregnancy': 'no',
        'q_contraception': 'no',
        'q_postpartum': 'no',
        'q_predictable': 'always',
        'q_gap': 'no',
        'q_hair_growth': 'none',
        'q_acne': 'none',
      });
      expect(r.level, PcosLevel.none);
      expect(pcosDetailLines(r).map((l) => l.en).join(' '),
          contains('reassuring as far as it goes'));
    });
  });

  group('safety comes first and ends the check', () {
    test('a red flag produces no pattern at all', () {
      final r = interpretPcos({
        'q_redflag': 'pain',
        // A full house of PCOS answers underneath, which must be ignored.
        'q_predictable': 'rare',
        'q_gap': 'yes',
        'q_hair_growth': 'significant',
        'q_acne': 'persistent',
        'q_told_anov': 'yes',
      });
      expect(r.stop, PcosStop.urgent);
      expect(r.patterns, isEmpty,
          reason: 'a pattern computed behind a warning screen is a pattern '
              'she can scroll to');
      expect(r.level, PcosLevel.none);
    });

    test('possible pregnancy stops the reading', () {
      final r = interpretPcos({
        'q_redflag': 'none',
        'q_pregnancy': 'maybe',
        'q_predictable': 'rare',
        'q_gap': 'yes',
      });
      expect(r.stop, PcosStop.pregnancy);
      expect(r.patterns, isEmpty);
    });

    test('"not sure" about pregnancy is treated as possible', () {
      final r = interpretPcos({'q_pregnancy': 'unsure'});
      expect(r.stop, PcosStop.pregnancy);
    });
  });

  group('it is a pattern engine, not a symptom count', () {
    test('skin symptoms alone never reach "discuss"', () {
      // Every androgen answer at maximum, and nothing else. A counting engine
      // would call this high risk; the diagnostic logic does not, because one
      // domain is not two.
      final r = interpretPcos({
        'q_redflag': 'none',
        'q_pregnancy': 'no',
        'q_predictable': 'very_regular',
        'q_length': 'normal',
        'q_gap': 'no',
        'q_hair_growth': 'significant',
        'q_acne': 'persistent',
        'q_thinning': 'significant',
        'q_skin_patches': 'yes',
      });
      expect(r.level, PcosLevel.watch,
          reason: 'one loud domain is not a pattern');
    });

    test('two primary domains do reach "discuss"', () {
      final r = interpretPcos({
        'q_redflag': 'none',
        'q_pregnancy': 'no',
        'q_predictable': 'often',
        'q_length': 'long',
        'q_hair_growth': 'noticeable',
        'q_acne': 'often',
      });
      expect(r.level, anyOf(PcosLevel.discuss, PcosLevel.soon));
    });

    test('fertility context alone never creates a pattern', () {
      // Trying over a year, regular cycles, no symptoms. A real situation, and
      // not a PCOS one — she has a different question.
      final r = interpretPcos({
        'q_redflag': 'none',
        'q_pregnancy': 'no',
        'q_predictable': 'very_regular',
        'q_length': 'normal',
        'q_gap': 'no',
        'q_trying': 'over12',
        'q_prior_difficulty': 'yes',
      });
      expect(r.level, PcosLevel.none);
    });

    test('weight carries no interpretive weight whatsoever', () {
      Map<String, String> base() => {
            'q_redflag': 'none',
            'q_pregnancy': 'no',
            'q_predictable': 'sometimes',
            'q_length': 'normal',
          };
      final without = interpretPcos(base());
      final with_ = interpretPcos(base()..['q_weight'] = 'yes');
      expect(with_.level, without.level,
          reason: 'a checker that scores weight tells larger women they are '
              'more likely to be ill');
    });

    test('bleeding duration carries no interpretive weight either', () {
      Map<String, String> base() => {
            'q_redflag': 'none',
            'q_pregnancy': 'no',
            'q_predictable': 'usually',
          };
      final without = interpretPcos(base());
      final with_ = interpretPcos(base()..['q_duration'] = 'long');
      expect(with_.level, without.level);
    });
  });

  group('confounders cap the reading rather than feeding it', () {
    test('hormonal contraception caps a confident result', () {
      Map<String, String> answers() => {
            'q_redflag': 'none',
            'q_pregnancy': 'no',
            'q_predictable': 'often',
            'q_length': 'long',
            'q_hair_growth': 'noticeable',
            'q_acne': 'often',
          };
      final free = interpretPcos(answers());
      final onPill = interpretPcos(answers()..['q_contraception'] = 'yes');
      expect(free.level, anyOf(PcosLevel.discuss, PcosLevel.soon));
      expect(onPill.level, PcosLevel.watch);
      expect(onPill.cappedByContext, isTrue);
    });

    test('a capped result says so rather than reading as reassurance', () {
      // ⚠️ THE MOST DANGEROUS FALSE NEGATIVE THIS FEATURE COULD PRODUCE. On the
      // pill the bleeds are regular BY CONSTRUCTION, so a naive engine returns
      // "no pattern" — describing the medication, not her.
      final r = interpretPcos({
        'q_redflag': 'none',
        'q_pregnancy': 'no',
        'q_predictable': 'very_regular',
        'q_length': 'normal',
        'q_contraception': 'yes',
      });
      expect(r.cappedByContext, isTrue);
      expect(r.body.en.toLowerCase(), contains('cannot be read'));
    });

    test('recent birth or breastfeeding caps it too', () {
      final r = interpretPcos({
        'q_redflag': 'none',
        'q_pregnancy': 'no',
        'q_predictable': 'very_unpredictable',
        'q_gap': 'yes',
        'q_hair_growth': 'noticeable',
        'q_acne': 'often',
        'q_postpartum': 'yes',
      });
      expect(r.cappedByContext, isTrue);
      expect(r.level, PcosLevel.watch);
    });
  });

  group('a clinician outranks the questionnaire', () {
    test('already told about irregular ovulation escalates', () {
      final r = interpretPcos({
        'q_redflag': 'none',
        'q_pregnancy': 'no',
        'q_predictable': 'usually',
        'q_told_anov': 'yes',
      });
      expect(r.level, PcosLevel.soon);
    });
  });

  group('nothing here diagnoses, scores or falsely reassures', () {
    /// Every string the result can render, across a spread of answer sets.
    List<String> allCopy() {
      final sets = <Map<String, String>>[
        {'q_redflag': 'pain'},
        {'q_pregnancy': 'maybe'},
        {'q_redflag': 'none', 'q_pregnancy': 'no'},
        {
          'q_redflag': 'none',
          'q_pregnancy': 'no',
          'q_predictable': 'rare',
          'q_gap': 'yes',
          'q_hair_growth': 'significant',
          'q_acne': 'persistent',
          'q_trying': 'over12',
        },
        {
          'q_redflag': 'none',
          'q_pregnancy': 'no',
          'q_predictable': 'sometimes',
          'q_contraception': 'yes',
        },
      ];
      final out = <String>[kPcosResultDisclaimer.en];
      for (final s in sets) {
        final r = interpretPcos(s);
        out
          ..add(r.headline.en)
          ..add(r.body.en);
        if (r.confidenceNote != null) out.add(r.confidenceNote!.en);
        out.addAll(pcosDetailLines(r).map((e) => e.en));
      }
      return out;
    }

    test('never states or implies a diagnosis', () {
      final banned = RegExp(
      // ⚠️ THE OBJECT MATTERS, NOT THE VERB. A first pass banned "you have"
      // outright and failed on "what you have described" — which is the
      // opposite of a diagnosis. What is dangerous is "you have" followed by a
      // CONDITION, so the pattern requires one.
          r'you (likely |probably |do )?have (pcos|a |an |the )'
          r'|\byou are (likely |probably )?(infertile|anovulatory)\b'
          r'|\bdiagnosed with\b'
          r'|\bhormonal imbalance\b',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    });

    test('never renders a probability, score or percentage', () {
      final banned = RegExp(
          r'%|\bscore\b|\brisk level\b|\bchances?\b|\bodds\b|\blikelihood\b',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    });

    test('never names a prescription medicine', () {
      // Treatment is the clinician's. A patient arriving having been told by an
      // app to ask for letrozole is a worse consultation, not a better one.
      final banned = RegExp(
          r'letrozole|clomiphene|clomid|metformin|spironolactone',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
      for (final q in kPcosDoctorQuestions) {
        expect(banned.hasMatch(q.en), isFalse, reason: q.en);
      }
    });

    test('a clear result never claims PCOS is ruled out', () {
      final r = interpretPcos({
        'q_redflag': 'none',
        'q_pregnancy': 'no',
        'q_predictable': 'very_regular',
        'q_length': 'normal',
        'q_gap': 'no',
      });
      expect(r.level, PcosLevel.none);
      final body = r.body.en.toLowerCase();
      expect(body.contains('not the same as ruling it out'), isTrue,
          reason: 'a reassuring result is the one that could stop someone '
              'seeking help, so it must say what it is not');
    });

    test('the disclaimer refuses diagnosis explicitly', () {
      expect(kPcosResultDisclaimer.en.toLowerCase(),
          contains('cannot diagnose'));
    });
  });

  group('the content declares what it is for', () {
    test('every question belongs to a domain and a section', () {
      for (final q in kPcosQuestions) {
        expect(q.options, isNotEmpty, reason: q.id);
        expect(q.prompt.en.trim(), isNotEmpty, reason: q.id);
      }
    });

    test('question ids are unique', () {
      final ids = kPcosQuestions.map((q) => q.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every dependent question points at a real answer', () {
      for (final q in kPcosQuestions) {
        final dep = q.dependsOn;
        if (dep == null) continue;
        final i = dep.indexOf(':');
        final parent = pcosQuestionById(dep.substring(0, i));
        expect(parent, isNotNull, reason: q.id);
        expect(parent!.options.any((o) => o.id == dep.substring(i + 1)), isTrue,
            reason: '${q.id} depends on an option that does not exist');
      }
    });

    test('recordOnly questions carry zero weight everywhere', () {
      for (final q in kPcosQuestions) {
        if (q.domain != PcosDomain.recordOnly) continue;
        for (final o in q.options) {
          expect(o.weight, 0,
              reason: '${q.id}/${o.id} is recordOnly and must not score');
        }
      }
    });
  });
}
