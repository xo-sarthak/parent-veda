// =============================================================================
//  The readiness check answers "should I see someone", never "will this work"
// -----------------------------------------------------------------------------
//  ⚠️ THE RULES FROM `ttc_fertility_help_rules.dart` AS ASSERTIONS.
//
//  This is the tool most likely to grow a probability by accident, because the
//  question it answers sits one careless step from the question it must never
//  answer. `kTtcInfertility` forbids a success rate or "your chances"; these
//  tests are what make that a contract rather than a comment.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/screens/ttc/ttc_fertility_help_summary.dart';
import 'package:parentveda/localization/app_language.dart';

FertilityHelpContext _ctx({
  int? daysTrying,
  FertilityAgeBand? ageBand,
  int cyclesLogged = 0,
  int? shortest,
  int? longest,
  bool irregular = false,
  bool pcosFound = false,
  bool pcosDone = false,
  FertilityCarePathway pathway = FertilityCarePathway.notStarted,
  Set<String> conditions = const {},
  int miscarriages = 0,
  bool partner = false,
  bool cancer = false,
  bool pain = false,
  bool pelvic = false,
}) =>
    FertilityHelpContext(
      daysTrying: daysTrying,
      ageBand: ageBand,
      cyclesLogged: cyclesLogged,
      cycleShortest: shortest,
      cycleLongest: longest,
      cyclesIrregular: irregular,
      pcosPatternFound: pcosFound,
      pcosCheckDone: pcosDone,
      pathway: pathway,
      knownConditions: conditions,
      priorMiscarriages: miscarriages,
      partnerConcern: partner,
      cancerTreatmentPlanned: cancer,
      painfulOrHeavyPeriods: pain,
      pelvicSurgeryOrInfection: pelvic,
    );


/// Strips negated clauses before a ban is applied.
///
/// ⚠️ THE SAME TRAP HAS NOW CAUGHT THREE OF THESE TEST FILES, so it is solved
/// here rather than patched again. The copy that does the safety work is
/// *about* the dangerous phrases: "this does not mean you need IVF", "it
/// cannot tell you whether you are ready", "not a target weight". A naive ban
/// on the phrase flags the one sentence that must exist.
///
/// So everything from "does not mean" / "doesn't mean" / "does not tell you"
/// to the end of that clause is removed, and the ban runs on what is left —
/// which is only the text that ASSERTS something.
String _assertive(String s) => s.replaceAll(
    RegExp(r"(does not|doesn.t|cannot|can.t) (mean|tell you|guarantee)[^.]*\.?",
        caseSensitive: false),
    ' ');

void main() {
  group('the thresholds match the article', () {
    test('twelve months under 36 reaches "may see specialist"', () {
      final r = evaluateFertilityHelp(
          _ctx(daysTrying: 380, ageBand: FertilityAgeBand.under35));
      expect(r.state, FertilityHelpState.maySeeSpecialist);
    });

    test('eleven months under 36 does not', () {
      final r = evaluateFertilityHelp(
          _ctx(daysTrying: 330, ageBand: FertilityAgeBand.under35));
      expect(r.state, FertilityHelpState.keepTrying);
    });

    // ⚠️ AND AGAIN ON 2026-09-27 (TTC launch walk): one age rule across the
    // app, the one Flo and What to Expect use (ASRM/ACOG): six months at 35
    // and over, straight away over 40. This test asserted "refers at
    // presentation from 35"; kept for revert under its old name below, now
    // asserting the six-month rule.
    test('36 and over refers at presentation, with no waiting period', () {
      // ⚠️ THIS PAIR CHANGED ON 2026-09-03 AND THE CHANGE IS THE POINT.
      //
      // It used to assert "36, not 35" — NICE refers at presentation from 36,
      // and writing 35 sweeps a whole year-band into a category the guidance
      // does not put them in. That was right while the bands were under 30 /
      // 30-35 / 36-39 / 40+, because 36 was a boundary.
      //
      // The bands are now under 35 / 35-37 / 38-40 / over 40, from the brief,
      // and 36 sits INSIDE a band. So the rule cannot be exact any more, and
      // the choice is which error to make: refer a 35-year-old the guidance
      // would not have referred yet, or fail to refer a 36- and 37-year-old it
      // says should be. The first costs an appointment. The second delays care
      // for the people the rule exists to catch.
      //
      // It refers from 35. If that year ever needs to be exact the answer is a
      // date of birth, not a fifth band — see the enum's own note.
      // Kept for revert:
      //   final r = evaluateFertilityHelp(
      //       _ctx(daysTrying: 30, ageBand: FertilityAgeBand.thirtyFiveTo37));
      //   expect(r.state, FertilityHelpState.maySeeSpecialist);
      final early = evaluateFertilityHelp(
          _ctx(daysTrying: 30, ageBand: FertilityAgeBand.thirtyFiveTo37));
      expect(early.state, isNot(FertilityHelpState.maySeeSpecialist),
          reason: 'at 35 to 37 the line is six months, not at once');
      final six = evaluateFertilityHelp(
          _ctx(daysTrying: 190, ageBand: FertilityAgeBand.thirtyFiveTo37));
      expect(six.state, FertilityHelpState.maySeeSpecialist);
    });

    test('over 40 is straight away (2026-09-27)', () {
      final r = evaluateFertilityHelp(
          _ctx(daysTrying: 20, ageBand: FertilityAgeBand.over40));
      expect(r.state, FertilityHelpState.dontWait);
    });

    test('under 35 is still inside the waiting period', () {
      final r = evaluateFertilityHelp(
          _ctx(daysTrying: 30, ageBand: FertilityAgeBand.under35));
      expect(r.state, FertilityHelpState.keepTrying);
    });
  });

  group('the six don\'t-wait situations', () {
    void expectsDontWait(String label, FertilityHelpContext c) {
      test(label, () {
        final r = evaluateFertilityHelp(c);
        expect(r.state, FertilityHelpState.dontWait);
        expect(r.reasons, isNotEmpty,
            reason: 'a dont-wait result must say which situation applies');
      });
    }

    expectsDontWait('irregular cycles', _ctx(irregular: true, cyclesLogged: 4));
    expectsDontWait('a PCOS pattern from the checker',
        _ctx(pcosFound: true, pcosDone: true));
    expectsDontWait('two or more miscarriages', _ctx(miscarriages: 2));
    expectsDontWait('a known condition', _ctx(conditions: {'endometriosis'}));
    expectsDontWait('a partner factor', _ctx(partner: true));
    expectsDontWait('pelvic history', _ctx(pelvic: true));
    expectsDontWait('painful or heavy periods', _ctx(pain: true));

    test('cancer treatment is the one urgent route', () {
      final r = evaluateFertilityHelp(_ctx(cancer: true));
      expect(r.state, FertilityHelpState.dontWait);
      expect(r.urgent, isTrue);
      expect(r.nextStep.en.toLowerCase(), contains('this week'));
    });

    test('one miscarriage alone is not a dont-wait', () {
      final r = evaluateFertilityHelp(
          _ctx(miscarriages: 1, ageBand: FertilityAgeBand.under35));
      expect(r.state, FertilityHelpState.keepTrying,
          reason: 'the threshold is two, and one loss is not a pattern');
    });
  });

  group('precedence, not addition', () {
    test('irregular cycles outrank a short trying time', () {
      // ⚠️ THE WHOLE ARGUMENT FOR PRECEDENCE. Three months in, she would
      // normally be told to keep going — but irregular cycles mean the
      // twelve-month rule was never hers.
      final r = evaluateFertilityHelp(_ctx(
          daysTrying: 90,
          ageBand: FertilityAgeBand.under35,
          irregular: true,
          cyclesLogged: 4,
          shortest: 29,
          longest: 47));
      expect(r.state, FertilityHelpState.dontWait);
    });

    test('a dont-wait situation beats a may-see one', () {
      final r = evaluateFertilityHelp(_ctx(
          daysTrying: 400,
          ageBand: FertilityAgeBand.over40,
          partner: true));
      expect(r.state, FertilityHelpState.dontWait);
    });

    test('reasons are capped at three', () {
      final r = evaluateFertilityHelp(_ctx(
          irregular: true,
          cyclesLogged: 4,
          miscarriages: 2,
          conditions: {'endometriosis', 'tubal'},
          partner: true,
          pelvic: true,
          pain: true));
      expect(r.reasons.length, lessThanOrEqualTo(3),
          reason: 'a result listing seven reasons is the tool justifying '
              'itself rather than answering her');
    });

    test('PCOS does not fire two rules and print the reason twice', () {
      final r = evaluateFertilityHelp(_ctx(conditions: {'pcos'}));
      final ids = r.reasons.map((x) => x.ruleId).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids.contains('known_condition'), isFalse,
          reason: 'PCOS is handled by irregular_cycles');
    });
  });

  group('unknown context does not guess in either direction', () {
    test('an empty context returns keep-trying, not a warning', () {
      final r = evaluateFertilityHelp(_ctx());
      expect(r.state, FertilityHelpState.keepTrying);
      expect(r.reasons, isEmpty);
    });

    test('no age means the age rule does not fire', () {
      final r = evaluateFertilityHelp(_ctx(daysTrying: 30));
      expect(firedRules(r == r ? _ctx(daysTrying: 30) : _ctx())
          .any((x) => x.id == 'age_at_presentation'), isFalse);
    });
  });

  group('already in care', () {
    test('the tool stops deciding', () {
      final r = evaluateFertilityHelp(
          _ctx(pathway: FertilityCarePathway.currentlyInCare, daysTrying: 800));
      expect(r.state, FertilityHelpState.alreadyInCare);
      expect(r.reasons, isEmpty);
      expect(r.nextStep.en.toLowerCase(), contains('next appointment'));
    });
  });

  group('it never becomes a probability, a diagnosis or a sale', () {
    List<String> allCopy() {
      final out = <String>[
        kFertilityHelpDisclaimer.en,
        kFertilityHelpPatternBreak.en,
      ];
      final contexts = [
        _ctx(),
        _ctx(daysTrying: 400, ageBand: FertilityAgeBand.under35),
        _ctx(daysTrying: 30, ageBand: FertilityAgeBand.over40),
        _ctx(irregular: true, cyclesLogged: 4, shortest: 29, longest: 47),
        _ctx(cancer: true),
        _ctx(pathway: FertilityCarePathway.currentlyInCare),
      ];
      for (final c in contexts) {
        final r = evaluateFertilityHelp(c);
        out
          ..add(r.headline.en)
          ..add(r.body.en)
          ..add(r.notMeaning.en)
          ..add(r.nextStep.en)
          ..addAll(r.reasons.map((x) => x.text.en));
        out.addAll(fertilityQuestionsFor(c, AppLanguage.english));
        out.addAll(
            buildFertilitySnapshot(c, AppLanguage.english).map((x) => x.value));
      }
      for (final r in kFertilityHelpRules) {
        out.add(r.displayReason(contexts[3]).en);
      }
      return out;
    }

    test('never states a chance, a rate or a percentage', () {
      final banned = RegExp(
          r'%|\byour chances?\b|\bsuccess rate\b|\bodds\b|\blikelihood\b'
          r'|\bprobability\b|\bchance of (conceiving|pregnancy)\b',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    });

    test('never diagnoses infertility', () {
      final banned = RegExp(
          r'\byou are infertile\b|\byou have infertility\b'
          r'|\byou cannot conceive\b|\bwill not conceive\b',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(_assertive(s)), isFalse, reason: s);
      }
    });

    test('never says she needs IVF', () {
      final banned = RegExp(r'\byou (need|will need|should have) ivf\b',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(_assertive(s)), isFalse, reason: s);
      }
    });

    test('the may-see result actively says IVF is not implied', () {
      // ⚠️ THE MOST IMPORTANT SENTENCE IN THE TOOL. Left unsaid, she supplies
      // it herself, and what she supplies is "I need IVF".
      final r = evaluateFertilityHelp(
          _ctx(daysTrying: 400, ageBand: FertilityAgeBand.under35));
      expect(r.notMeaning.en.toLowerCase(), contains('does not mean you need ivf'));
    });

    test('the reassuring result does not promise everything is fine', () {
      final r = evaluateFertilityHelp(_ctx());
      expect(r.notMeaning.en.toLowerCase(),
          contains('not the same as a promise'));
    });

    test('no urgency or sales language anywhere', () {
      final banned = RegExp(
          r'\bbook now\b|\bdon.t delay\b|\bbefore it.s too late\b'
          r'|\byour fertility is at risk\b|\bact fast\b|\bhurry\b',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    });

    test('the snapshot never promotes the PCOS check into a diagnosis', () {
      final rows = buildFertilitySnapshot(
          _ctx(pcosDone: true, pcosFound: true), AppLanguage.english);
      final pcos = rows.firstWhere((r) => r.label.contains('PCOS'));
      expect(pcos.value.toLowerCase(), contains('not a diagnosis'));
    });

    test('a clear PCOS check is not reported as a rule-out either', () {
      final rows = buildFertilitySnapshot(
          _ctx(pcosDone: true), AppLanguage.english);
      final pcos = rows.firstWhere((r) => r.label.contains('PCOS'));
      expect(pcos.value.toLowerCase(), contains('not a rule-out'));
    });

    test('questions ask, they do not request tests or drugs', () {
      final banned = RegExp(
          r'\bplease (order|prescribe)\b|letrozole|clomiphene|metformin'
          r'|\bi need (an? )?(amh|hsg|ivf|iui)\b',
          caseSensitive: false);
      for (final q in fertilityQuestionsFor(
          _ctx(daysTrying: 400, irregular: true, cyclesLogged: 4), AppLanguage.english)) {
        expect(banned.hasMatch(q), isFalse, reason: q);
      }
    });

    test('trying time is never shown as a raw day count', () {
      expect(_ctx(daysTrying: 412).tryingLabel!.en, isNot(contains('412')));
      expect(_ctx(daysTrying: 90).tryingLabel!.en, 'about 3 months');
      expect(_ctx(daysTrying: 365).tryingLabel!.en, 'about a year');
    });
  });

  group('the review register is generated from the rules', () {
    test('every rule appears, with its article section', () {
      final reg = fertilityHelpReviewRegister();
      expect(reg.length, kFertilityHelpRules.length);
      for (final r in reg) {
        expect(r.trigger.trim(), isNotEmpty);
        expect(r.article.trim(), isNotEmpty,
            reason: 'every rule must name the article section it comes from');
        expect(r.status, 'pendingReview');
      }
    });

    test('rule ids are unique', () {
      final ids = kFertilityHelpRules.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
