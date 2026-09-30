// =============================================================================
//  The pre-pregnancy checklist cannot clear anyone, score anyone, or prescribe
// -----------------------------------------------------------------------------
//  ⚠️ THE RULES FROM `ttc_precheck_rules.dart` AND `ttc_precheck_data.dart`,
//  RESTATED AS ASSERTIONS. A rules file is only a contract if something
//  enforces it, and the failure this guards is quiet: someone adds a readiness
//  percentage because it looks good on a summary screen, or auto-ticks
//  "medication review" from a medicines list because the data is right there.
//  Neither would break the app. Both would be wrong.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ttc/ttc_precheck_data.dart';
import 'package:parentveda/ttc/ttc_precheck_rules.dart';
import 'package:parentveda/screens/ttc/ttc_precheck_summary.dart'
    show kPrecheckFallbackQuestions;

/// A context with nothing known — the first-visit case.
const _empty = PrecheckContext(
  loggedCycles: 0,
  cyclesLookIrregular: false,
  ranPcosCheck: false,
  pcosLevelAtLeastDiscuss: false,
  medicineCount: 0,
  supplementCount: 0,
  takesFolate: false,
  vaccinesRecorded: 0,
  liveVaccineOutstanding: false,
  daysTrying: null,
);

PrecheckContext _ctx({
  int loggedCycles = 0,
  bool cyclesLookIrregular = false,
  bool ranPcosCheck = false,
  bool pcosLevelAtLeastDiscuss = false,
  int medicineCount = 0,
  int supplementCount = 0,
  bool takesFolate = false,
  int vaccinesRecorded = 0,
  bool liveVaccineOutstanding = false,
  int? daysTrying,
}) =>
    PrecheckContext(
      loggedCycles: loggedCycles,
      cyclesLookIrregular: cyclesLookIrregular,
      ranPcosCheck: ranPcosCheck,
      pcosLevelAtLeastDiscuss: pcosLevelAtLeastDiscuss,
      medicineCount: medicineCount,
      supplementCount: supplementCount,
      takesFolate: takesFolate,
      vaccinesRecorded: vaccinesRecorded,
      liveVaccineOutstanding: liveVaccineOutstanding,
      daysTrying: daysTrying,
    );

void main() {
  group('evidence is not completion', () {
    test('no medical item is ever auto-completable', () {
      // ⚠️ THE CENTRAL RULE. App data can show she takes medicines; it cannot
      // show that a doctor has reviewed them. Only items she performs IN THE
      // APP may be ticked without her.
      const allowed = {'cycle_tracking', 'fertile_window'};
      for (final i in kPrecheckItems) {
        if (!i.autoCompletable) continue;
        expect(allowed.contains(i.id), isTrue,
            reason: '${i.id} is auto-completable but is not something she does '
                'inside the app');
        expect(i.tier, isNot(PrecheckTier.core),
            reason: '${i.id} is core and auto-completable — a core item is a '
                'conversation, and the app cannot have it for her');
      }
    });

    test('saved medicines never complete the medication review', () {
      final item = precheckItemById('medication_review')!;
      final c = _ctx(medicineCount: 5);
      expect(precheckAutoDone(item, c), isFalse);
      // ...and they DO produce evidence, which is the whole point.
      expect(precheckEvidenceFor(item, c), isNotNull);
      expect(precheckEvidenceFor(item, c)!.en.toLowerCase(),
          contains('not a review'));
    });

    test('folic acid on the supplement list never completes the folate item',
        () {
      final item = precheckItemById('folate')!;
      final c = _ctx(supplementCount: 3, takesFolate: true);
      expect(precheckAutoDone(item, c), isFalse,
          reason: 'a matching string is not a conversation with a pharmacist');
      expect(precheckEvidenceFor(item, c), isNotNull);
      // ⚠️ 2026-09-29 (launch sanity D12): the item IS shown done now, by a
      // separate and narrower path, `precheckDerivedDone`: folic acid on her
      // own list is her saying she takes it. The dose conversation stays
      // open (the evidence line, and the "talked to my doctor" flag). Held
      // in test/ttc_precheck_rebuild_test.dart.
      expect(precheckDerivedDone(item, c), isTrue);
    });

    test('logged cycles do complete cycle tracking', () {
      final item = precheckItemById('cycle_tracking')!;
      expect(precheckAutoDone(item, _ctx(loggedCycles: 4)), isTrue);
      expect(precheckAutoDone(item, _ctx(loggedCycles: 1)), isFalse,
          reason: 'one interval says nothing');
    });
  });

  group('priorities are personalised, capped at three, and never medical '
      'instructions', () {
    PrecheckStatus untouched(String _) => PrecheckStatus.untouched;

    test('never more than three', () {
      final p = precheckPriorities(
          _ctx(
              liveVaccineOutstanding: true,
              pcosLevelAtLeastDiscuss: true,
              medicineCount: 4,
              cyclesLookIrregular: true,
              daysTrying: 400),
          untouched);
      expect(p.length, lessThanOrEqualTo(3));
    });

    test('an outstanding live vaccine leads, because it moves her timing', () {
      final p = precheckPriorities(
          _ctx(liveVaccineOutstanding: true, medicineCount: 3), untouched);
      expect(p.first.item.id, 'vaccines');
    });

    test('a PCOS pattern promotes the preconception visit', () {
      final p = precheckPriorities(
          _ctx(ranPcosCheck: true, pcosLevelAtLeastDiscuss: true), untouched);
      expect(p.any((x) => x.item.id == 'preconception_visit'), isTrue);
    });

    test('saved medicines promote the medication review', () {
      final p = precheckPriorities(_ctx(medicineCount: 2), untouched);
      expect(p.any((x) => x.item.id == 'medication_review'), isTrue);
    });

    test('items she has settled are never offered as next steps', () {
      PrecheckStatus done(String id) =>
          id == 'vaccines' ? PrecheckStatus.done : PrecheckStatus.untouched;
      final p =
          precheckPriorities(_ctx(liveVaccineOutstanding: true), done);
      expect(p.any((x) => x.item.id == 'vaccines'), isFalse);
    });

    test('an empty context still produces something to do', () {
      final p = precheckPriorities(_empty, untouched);
      expect(p, isNotEmpty,
          reason: 'a first-time user with no data must not get an empty '
              'next-steps list');
      expect(p.length, lessThanOrEqualTo(3));
    });

    test('every priority states why', () {
      final p = precheckPriorities(_ctx(medicineCount: 2), untouched);
      for (final x in p) {
        expect(x.reason.en.trim(), isNotEmpty,
            reason: 'a priority list without reasons is the checklist '
                'reordered');
      }
    });
  });

  group('nothing clears, scores, diagnoses or prescribes', () {
    List<String> allCopy() => [
          kPrecheckDisclaimer.en,
          for (final i in kPrecheckItems) ...[
            i.title.en,
            i.why.en,
            i.whatToDo.en,
            if (i.askDoctor != null) i.askDoctor!.en,
          ],
          for (final q in kPrecheckFallbackQuestions) q.en,
        ];

    test('never tells her she is ready, or not ready', () {
      final banned = RegExp(
      // ⚠️ NEGATION IS THE TRAP, AGAIN. A first pass banned "ready to
      // conceive" outright and failed on the DISCLAIMER — "it cannot tell
      // you whether you are ready to conceive" — which is the sentence doing
      // the job. What is dangerous is an ASSERTION, so the lookbehind
      // excludes the refusals.
          r'(?<!whether )(?<!not )you are (now )?(medically )?(ready|cleared)'
          r'|you have been medically cleared',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    });

    test('never renders a readiness score or percentage', () {
      final banned = RegExp(r'%|\breadiness score\b|\b\d+% ready\b',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    });

    test('never names a supplement dose or a prescription medicine', () {
      // ⚠️ FOLIC ACID IS THE ONE MOST LIKELY TO SLIP, because the number is so
      // well known. The item deliberately carries no dose — which of 400 mcg
      // and 5 mg applies to HER is a prescription decision, and the article
      // carries both with their conditions attached.
      final banned = RegExp(
          r'\b\d+\s?(mcg|microgram|mg)\b'
          r'|letrozole|clomiphene|clomid|metformin',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    });

    test('never tells anyone they need genetic testing', () {
      final banned = RegExp(
          r'\byou (need|should get|must have) (a )?(genetic|carrier) (test|screening)\b',
          caseSensitive: false);
      for (final s in allCopy()) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    });

    test('the weight item carries no BMI figure or target', () {
      final item = precheckItemById('body')!;
      final all = '${item.why.en} ${item.whatToDo.en}'.toLowerCase();
      expect(all.contains('bmi'), isFalse);
      // ⚠️ THE COPY SAYS "not a target weight" — a refusal, which an
      // earlier version of this test read as a prescription. What must be
      // absent is an actual FIGURE, so assert on that instead.
      expect(RegExp(r'\d+\s?(kg|kilos|kilograms)').hasMatch(all), isFalse,
          reason: 'no target weight may be named');
      expect(all.contains('not a target weight'), isTrue,
          reason: 'and it should refuse one out loud');
      // And it must name both directions, not just one.
      expect(all.contains('underweight'), isTrue,
          reason: 'weight affects ovulation at both ends and only one end is '
              'ever discussed');
    });

    test('the medication item carries the do-not-stop warning', () {
      final item = precheckItemById('medication_review')!;
      expect(item.whatToDo.en.toLowerCase(),
          contains('do not stop a prescribed medicine'));
    });

    test('the disclaimer refuses clearance explicitly', () {
      expect(kPrecheckDisclaimer.en.toLowerCase(),
          contains('not medical clearance'));
    });
  });

  group('the content declares itself', () {
    test('item ids are unique', () {
      final ids = kPrecheckItems.map((i) => i.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every item has a why and a what-to-do', () {
      for (final i in kPrecheckItems) {
        expect(i.why.en.trim(), isNotEmpty, reason: i.id);
        expect(i.whatToDo.en.trim(), isNotEmpty, reason: i.id);
      }
    });

    test('every section has at least one item', () {
      for (final s in PrecheckSection.values) {
        expect(precheckItemsIn(s), isNotEmpty, reason: s.name);
      }
    });

    test('the clinical-review register is generated and non-empty', () {
      // ⚠️ DERIVED FROM THE CONTENT, so it cannot drift from the claims it
      // covers. A hand-maintained register goes stale on the first copy edit.
      final reg = precheckReviewRegister();
      expect(reg, isNotEmpty);
      for (final r in reg) {
        expect(precheckItemById(r.itemId), isNotNull);
        expect(r.claim.trim(), isNotEmpty);
      }
    });

    test('every core item is in the review register', () {
      // Not strictly every one needs sign-off, but a core item with no claim
      // recorded is far more likely an oversight than a decision.
      final flagged = precheckReviewRegister().map((r) => r.itemId).toSet();
      const exempt = {
        'preconception_visit', // "see a doctor" needs no clinical review
        'family_history', // flagged, but keep the set explicit
      };
      for (final i in kPrecheckItems) {
        if (i.tier != PrecheckTier.core) continue;
        if (exempt.contains(i.id)) continue;
        expect(flagged.contains(i.id), isTrue,
            reason: '${i.id} is core and carries no clinical-review note');
      }
    });
  });
}
