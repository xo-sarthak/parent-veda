// =============================================================================
//  Pre-Pregnancy Checklist — THE RULES LAYER
// -----------------------------------------------------------------------------
//  Personalisation, priority, and the clinical-review register. No widgets, no
//  navigation, no persistence — this is the file a clinician and a product lead
//  can both read.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT MAKES THIS DIFFERENT FROM A GENERIC CHECKLIST
//  ---------------------------------------------------------------------------
//
//  A twenty-item preconception list exists on every health site in the world
//  and is closed within ten seconds, because it asks a woman to re-enter things
//  she has already done. ParentVeda knows:
//
//    · how many cycles she has logged            (`CycleStore`)
//    · what her cycles actually look like        (`CycleStore.cycleLengths`)
//    · whether she has run the PCOS check, and what it found
//    · which vaccinations she has recorded       (`TtcVaccineStore`)
//    · what supplements she is taking            (`TtcSupplementsStore`)
//    · what medicines she is taking              (`MedicineStore`)
//    · how long she has been trying              (`TtcStore.daysTrying`)
//
//  So the checklist opens already knowing where she is. `PrecheckContext` is
//  that reading, gathered in one place, and `precheckPriorities` turns it into
//  the three things actually worth doing next.
//
//  ---------------------------------------------------------------------------
//  ⚠️ EVIDENCE IS NOT COMPLETION, AND THE DISTINCTION IS CLINICAL
//  ---------------------------------------------------------------------------
//
//  "You have three medicines saved" is a fact about the app. It is NOT evidence
//  that a doctor has reviewed them, and auto-ticking `medication_review` from a
//  medicines list would tell her something had happened that has not.
//
//  So app data does two different things depending on the item:
//
//    · on an `autoCompletable` item (practical, done in the app) it COMPLETES;
//    · on a medical item it becomes EVIDENCE, shown on the card, and it RAISES
//      priority rather than lowering it — three saved medicines makes a
//      medication review more worth doing, not less.
//
//  Held by `test/ttc_precheck_test.dart`.
//
//  ⚠️ AND NOTHING HERE PRODUCES A READINESS SCORE. There is no percentage, no
//  ring measuring her health, and no state in which the tool says she is ready
//  or not ready to conceive. Counts are of HER OWN LIST — "8 of the 12 you are
//  tracking" — which is a fact about a checklist, not a claim about a body.
// =============================================================================

import '../localization/app_language.dart';
import '../services/medicine_store.dart';
import 'cycle_store.dart';
import 'ttc_chapter.dart' show kTtcIrregularSpreadDays;
import 'ttc_pcos_check_rules.dart';
import 'ttc_pcos_check_store.dart';
import 'ttc_precheck_data.dart';
import 'ttc_store.dart';
import 'ttc_supplements_store.dart';
import 'ttc_vaccine_store.dart';
import 'ttc_vaccines_data.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  What the app already knows
// -----------------------------------------------------------------------------

/// A read-only snapshot of her journey, gathered from the stores that own it.
///
/// ⚠️ READ, NEVER WRITTEN. This type owns no state and mutates nothing — it is
/// a view over stores that are each authoritative for their own data. Copying
/// any of it would create a second source of truth for facts that already have
/// one.
class PrecheckContext {
  const PrecheckContext({
    required this.loggedCycles,
    required this.cyclesLookIrregular,
    required this.ranPcosCheck,
    required this.pcosLevelAtLeastDiscuss,
    required this.medicineCount,
    required this.supplementCount,
    required this.takesFolate,
    required this.vaccinesRecorded,
    required this.liveVaccineOutstanding,
    required this.daysTrying,
    this.liveImmunitySettled = false,
  });

  final int loggedCycles;
  final bool cyclesLookIrregular;

  final bool ranPcosCheck;
  final bool pcosLevelAtLeastDiscuss;

  final int medicineCount;
  final int supplementCount;

  /// Whether anything in her supplement list looks like folate. Deliberately a
  /// loose name match — see the note at the call site.
  final bool takesFolate;

  final int vaccinesRecorded;
  final bool liveVaccineOutstanding;

  final int? daysTrying;

  /// Her vaccination record says every live vaccine is settled: immune, not
  /// needed, or had with its month's wait already over (2026-09-29).
  ///
  /// ⚠️ HER OWN RECORD, NOT AN INFERENCE. Each live vaccine has a status she
  /// set herself on the Vaccinations tool, usually from a blood test. Optional
  /// with a false default so a context built by hand (the tests) stays
  /// exactly what it was.
  final bool liveImmunitySettled;

  bool get tryingOverAYear => (daysTrying ?? 0) >= 365;
  bool get tryingOverSixMonths => (daysTrying ?? 0) >= 182;

  /// Gathers the snapshot. The one place that reaches across stores.
  static PrecheckContext gather() {
    final cycles = CycleStore.instance.cycleLengths;
    final spread =
        cycles.isEmpty ? 0 : (cycles.reduce((a, b) => a > b ? a : b) -
            cycles.reduce((a, b) => a < b ? a : b));

    final pcos = TtcPcosCheckStore.instance;
    final pcosResult = pcos.hasCompleted ? pcos.result : null;

    final supplements = TtcSupplementsStore.instance.items;

    final vax = TtcVaccineStore.instance;
    final recorded = kTtcVaccines
        .where((v) => vax.statusOf(v.id) != TtcVaccineStatus.unknown)
        .length;

    return PrecheckContext(
      loggedCycles: cycles.length,
      // Two cycles is the floor, matching the PCOS checker's — one interval
      // says nothing about regularity.
      // The one definition of irregular (2026-09-26). Was `spread > 7`.
      cyclesLookIrregular:
          cycles.length >= 2 && spread > kTtcIrregularSpreadDays,
      ranPcosCheck: pcos.hasCompleted,
      pcosLevelAtLeastDiscuss: pcosResult != null &&
          !pcosResult.stopped &&
          (pcosResult.level == PcosLevel.discuss ||
              pcosResult.level == PcosLevel.soon),
      medicineCount: MedicineStore.instance.all.length,
      supplementCount: supplements.length,
      // ⚠️ A LOOSE NAME MATCH, AND IT ONLY EVER SHOWS EVIDENCE. It is used to
      // say "you have folic acid on your list", never to tick the item — the
      // folate item is core and medical, so it is not auto-completable and a
      // matching string is not a conversation with a pharmacist.
      takesFolate: supplements.any((s) {
        final n = s.name.toLowerCase();
        return n.contains('folic') || n.contains('folate');
      }),
      vaccinesRecorded: recorded,
      liveVaccineOutstanding: vax.liveOutstanding.isNotEmpty,
      daysTrying: TtcStore.instance.daysTrying,
      liveImmunitySettled: ttcLiveVaccines.isNotEmpty &&
          ttcLiveVaccines.every((v) => const {
                TtcVaccineStatus.immune,
                TtcVaccineStatus.notApplicable,
                TtcVaccineStatus.done,
              }.contains(vax.statusOf(v.id))) &&
          vax.clearToTryFrom() == null,
    );
  }
}

// -----------------------------------------------------------------------------
//  Evidence
// -----------------------------------------------------------------------------

/// What the app can honestly say about this item already.
///
/// Null where it knows nothing. Never phrased as an achievement on a medical
/// item — "you have 3 medicines saved" states a fact and leaves the conclusion
/// to her.
LocalizedText? precheckEvidenceFor(PrecheckItem item, PrecheckContext c) {
  switch (item.id) {
    case 'cycle_tracking':
      if (c.loggedCycles == 0) return null;
      return _en('You have logged ${c.loggedCycles} '
          '${c.loggedCycles == 1 ? 'cycle' : 'cycles'}, so this one is already '
          'covered.');

    case 'fertile_window':
      if (c.loggedCycles < 2) return null;
      return _en('Your logged cycles already feed your fertile-window '
          'estimate, so this one is done.');

    case 'medication_review':
      if (c.medicineCount == 0) return null;
      return _en('You have ${c.medicineCount} '
          '${c.medicineCount == 1 ? 'medicine' : 'medicines'} saved in the '
          'app. That gives you a list to take to a review. It is not a review '
          'itself.');

    case 'supplement_review':
      if (c.supplementCount == 0) return null;
      return _en('You have ${c.supplementCount} '
          '${c.supplementCount == 1 ? 'supplement' : 'supplements'} recorded. '
          'Take the list with you, not the bottles.');

    case 'folate':
      if (!c.takesFolate) return null;
      return _en('You have folic acid on your supplement list. Still check '
          'the dose with the doctor who prescribes for you.');

    case 'vaccines':
      if (c.liveVaccineOutstanding) {
        return _en('Your vaccine list has a live vaccine still to get. '
            "That's the one that needs a month's gap before trying.");
      }
      if (c.vaccinesRecorded == 0) return null;
      return _en('You have noted where you stand on '
          '${c.vaccinesRecorded} of the vaccines on your list.');

    case 'conditions':
      if (!c.pcosLevelAtLeastDiscuss) return null;
      return _en('Your PCOS check found a pattern worth talking about, so '
          'this conversation is more useful than usual.');

    case 'when_to_seek_help':
      if (c.tryingOverAYear) {
        return _en("You've been trying for over a year. The usual advice is "
            'to see a doctor at this point.');
      }
      if (c.cyclesLookIrregular) {
        return _en('Your logged cycles vary quite a bit. So the "try for a '
            'year first" advice was never meant for you.');
      }
      return null;

    default:
      return null;
  }
}

/// True when the app can honestly tick this item without her.
///
/// ⚠️ ONLY EVER TRUE FOR `autoCompletable` ITEMS. The guard is here as well as
/// on the model because this is the function callers actually use, and a check
/// that lives only in the data is a check somebody routes around.
bool precheckAutoDone(PrecheckItem item, PrecheckContext c) {
  if (!item.autoCompletable) return false;
  return switch (item.id) {
    'cycle_tracking' => c.loggedCycles >= 2,
    'fertile_window' => c.loggedCycles >= 2,
    _ => false,
  };
}

// -----------------------------------------------------------------------------
//  Done, from her own records (2026-09-29, launch sanity D12)
// -----------------------------------------------------------------------------
//
// ⚠️ A SECOND KIND OF "ALREADY DONE", AND IT IS NOT AUTO-COMPLETION. The walk
// found the folic acid item saying "You have folic acid on your supplement
// list" beside an empty circle: we knew, and still made her tick it, and the
// count under-reported her. `precheckAutoDone` stays what it was (only things
// she does IN THE APP, never a core medical item, held by the test). This is
// narrower and separate: two items whose whole action is a fact she has
// already RECORDED herself on another tool.
//
//   · `folate`: the item is "Folic acid", and folic acid on her own
//     supplement list is her saying she takes it. The dose check is a
//     different fact, and it stays open: the evidence line on the row still
//     says to check the dose, and "I talked to my doctor about this" is
//     still hers to tick. Taking it and having the dose confirmed are two
//     facts, which is why the store keeps them as two fields.
//   · `vaccines`: every live vaccine on her Vaccinations list is immune, not
//     needed, or had with the month's wait over. That is the item's whole
//     point ("the one item on this list with a deadline").
//
// Never the medication or supplement review: a list of medicines is not a
// review of them, and nothing she can record elsewhere says one happened.
// Her own answer always wins (see `TtcPrecheckStore.statusOf`), so a derived
// tick is one tap from being taken off, with Undo.

/// The items that may be ticked from her own records. Nothing else, ever.
const Set<String> kPrecheckFromRecords = {'folate', 'vaccines'};

/// True when her own records on another tool already settle this item.
bool precheckDerivedDone(PrecheckItem item, PrecheckContext c) {
  if (!kPrecheckFromRecords.contains(item.id)) return false;
  return switch (item.id) {
    'folate' => c.takesFolate,
    'vaccines' => c.liveImmunitySettled && !c.liveVaccineOutstanding,
    _ => false,
  };
}

/// Where a tick she did not make came from, said on the row ("From your
/// supplements"). Null when the app has not ticked it.
LocalizedText? precheckDoneSource(PrecheckItem item, PrecheckContext c) {
  if (precheckAutoDone(item, c)) return _en('From your cycle log');
  if (!precheckDerivedDone(item, c)) return null;
  return switch (item.id) {
    'folate' => _en('From your supplements'),
    'vaccines' => _en('From your vaccinations'),
    _ => null,
  };
}

// -----------------------------------------------------------------------------
//  Priority
// -----------------------------------------------------------------------------

class PrecheckPriority {
  const PrecheckPriority({required this.item, required this.reason});
  final PrecheckItem item;

  /// Why THIS is near the top for HER. Shown on the summary — a priority list
  /// without reasons is just a reordered checklist.
  final LocalizedText reason;
}

/// The next three things, chosen from her context and her own statuses.
///
/// ⚠️ THREE, AND NEVER MORE. §18 of the brief, and it is right: a "next steps"
/// list of nine is the checklist again, and the whole value of a summary is
/// that it is shorter than the thing it summarises.
///
/// ⚠️ NEVER A TEST OR A TREATMENT. Every reason below points at a conversation
/// or at something she does herself. Nothing here says she needs a particular
/// test — that is the clinician's call, and §13 and §27 both forbid it.
List<PrecheckPriority> precheckPriorities(
    PrecheckContext c, PrecheckStatus Function(String) statusOf) {
  final out = <PrecheckPriority>[];

  void consider(String id, LocalizedText reason) {
    if (out.length >= 3) return;
    if (out.any((p) => p.item.id == id)) return;
    final item = precheckItemById(id);
    if (item == null) return;
    // ⚠️ ONLY WHAT THE LIST DRAWS (2026-09-29). "His side of it" is core and
    // sits in the hidden partner section, so the core fallback below could
    // offer a step the checklist has no row for. Kept for revert: no check.
    if (!ttcVisiblePrecheckSections.contains(item.section)) return;
    final s = statusOf(id);
    // Something she has settled, either way, is not a next step.
    if (s == PrecheckStatus.done || s == PrecheckStatus.notRelevant) return;
    out.add(PrecheckPriority(item: item, reason: reason));
  }

  // ---- context-driven, in order of how much it changes her next month ------

  if (c.liveVaccineOutstanding) {
    consider(
        'vaccines',
        _en('A live vaccine on your list means waiting about a month before '
            'trying. This is the only item here that can change your timing.'));
  }

  if (c.pcosLevelAtLeastDiscuss) {
    consider(
        'preconception_visit',
        _en('Your PCOS check found a pattern worth talking about. One visit '
            'can cover that and everything else here.'));
  }

  if (c.medicineCount > 0) {
    consider(
        'medication_review',
        _en('You have ${c.medicineCount} '
            '${c.medicineCount == 1 ? 'medicine' : 'medicines'} saved. The '
            "list is ready. The review hasn't happened yet."));
  }

  if (c.cyclesLookIrregular || c.tryingOverAYear) {
    consider(
        'when_to_seek_help',
        c.tryingOverAYear
            ? _en("You've been trying for over a year. That's usually when "
                'to see a doctor.')
            : _en('Your cycles vary enough that the "wait a year" advice '
                "wasn't meant for you."));
  }

  if (!c.takesFolate) {
    consider(
        'folate',
        _en('The item with the strongest evidence behind it. It needs to '
            'start before pregnancy, not after.'));
  }

  if (c.loggedCycles < 2) {
    consider(
        'cycle_tracking',
        _en("Just the first day of each period. It's the most useful thing "
            'you can bring to any appointment.'));
  }

  // ---- fall back to her own flagged items, core first ----------------------
  for (final tier in PrecheckTier.values) {
    for (final item in kPrecheckItems) {
      if (item.tier != tier) continue;
      if (statusOf(item.id).isOpen) {
        consider(item.id, _en('You marked this to come back to.'));
      }
    }
  }

  // ---- and finally anything core she has not looked at ---------------------
  for (final item in kPrecheckItems) {
    if (item.tier != PrecheckTier.core) continue;
    // ⚠️ THE ITEM'S OWN REASON (2026-09-30, tools review, fix E): this line
    // said "One of the few items here that applies to almost everyone" under
    // every core item she had not looked at, which says nothing about THIS one
    // and had to be reworded "Also core…" when it repeated. The first
    // sentence of the item's own "why" is specific and cannot repeat. Kept for
    // revert: _en('One of the few items here that applies to almost everyone.').
    consider(item.id, _firstSentence(item.why));
  }

  // ⚠️ ONE REASON, SAID ONCE (no-repetition sweep, 2026-09-29). The two
  // fallbacks give every step they pick the same line, so two core items
  // she has not looked at read "One of the few items here that applies to
  // almost everyone." twice, one above the other. The second says "also".
  final times = <String, int>{};
  for (var i = 0; i < out.length; i++) {
    final r = out[i].reason.en;
    final n = times[r] = (times[r] ?? 0) + 1;
    final also = _kPrecheckAlsoReason[r];
    if (n < 2 || also == null) continue;
    out[i] = PrecheckPriority(
        item: out[i].item, reason: also[(n - 2).clamp(0, also.length - 1)]);
  }

  return out;
}

/// The first sentence of [t], for a one-line reason (2026-09-30).
LocalizedText _firstSentence(LocalizedText t) {
  String first(String s) {
    final m = RegExp(r'^.*?[.!?](?=\s|$)').firstMatch(s.trim());
    return m?.group(0) ?? s.trim();
  }

  return LocalizedText(en: first(t.en), hi: first(t.hi));
}

/// What a fallback reason says the second and the third time.
final Map<String, List<LocalizedText>> _kPrecheckAlsoReason = {
  'You marked this to come back to.': [
    _en('Also marked by you to come back to.'),
    _en('You marked this one too.'),
  ],
  'One of the few items here that applies to almost everyone.': [
    _en('Also core: most people should do this one.'),
    _en('Core as well: it applies to almost everyone.'),
  ],
};

// -----------------------------------------------------------------------------
//  The clinical-review register
// -----------------------------------------------------------------------------

/// Every claim in this feature that needs a named clinician to sign it off.
///
/// ⚠️ GENERATED FROM THE CONTENT, NOT MAINTAINED BESIDE IT. §28 asks for a
/// visible configuration of everything requiring review; keeping that as a
/// hand-written list guarantees it goes stale the first time someone edits a
/// line of copy. Marking the claim in place and deriving the register means the
/// two cannot disagree.
///
/// `docs/STILL-OPEN.md` §14.0 is where the named-clinician question lives.
List<({String itemId, String title, String claim})> precheckReviewRegister() =>
    [
      for (final i in kPrecheckItems)
        if (i.medicalReview != null)
          (itemId: i.id, title: i.title.en, claim: i.medicalReview!.en),
    ];

/// The disclaimer shown on the intro and on the summary, without exception.
final LocalizedText kPrecheckDisclaimer = _en(
    'This checklist helps you plan and get ready to talk to a doctor. It is '
    "not medical clearance. It can't tell you whether you're ready to "
    "conceive, and not every item applies to everyone. Your doctor can tell "
    'you which ones matter for you.');
