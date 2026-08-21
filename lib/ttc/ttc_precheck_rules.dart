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
      cyclesLookIrregular: cycles.length >= 2 && spread > 7,
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
          '${c.loggedCycles == 1 ? 'cycle' : 'cycles'} — this one is already '
          'covered.');

    case 'fertile_window':
      if (c.loggedCycles < 2) return null;
      return _en('Your logged cycles already drive the fertile-window '
          'estimate, so you have this.');

    case 'medication_review':
      if (c.medicineCount == 0) return null;
      return _en('You have ${c.medicineCount} '
          '${c.medicineCount == 1 ? 'medicine' : 'medicines'} saved in the '
          'app. That is a list ready to take to a review — not a review.');

    case 'supplement_review':
      if (c.supplementCount == 0) return null;
      return _en('You have ${c.supplementCount} '
          '${c.supplementCount == 1 ? 'supplement' : 'supplements'} recorded. '
          'Worth taking the list rather than the bottles.');

    case 'folate':
      if (!c.takesFolate) return null;
      return _en('You have folic acid on your supplement list. The dose is '
          'still worth confirming with whoever prescribes for you.');

    case 'vaccines':
      if (c.liveVaccineOutstanding) {
        return _en('Your vaccination list has a live vaccine still to have — '
            'that is the one with a month attached to it.');
      }
      if (c.vaccinesRecorded == 0) return null;
      return _en('You have recorded where you stand on '
          '${c.vaccinesRecorded} of the vaccination list.');

    case 'conditions':
      if (!c.pcosLevelAtLeastDiscuss) return null;
      return _en('Your PCOS check found a pattern worth discussing, which '
          'makes this conversation more useful than usual.');

    case 'when_to_seek_help':
      if (c.tryingOverAYear) {
        return _en('You have been trying over a year. The usual guidance says '
            'that is the point to be seen.');
      }
      if (c.cyclesLookIrregular) {
        return _en('Your logged cycles vary quite a bit — which means the '
            '"try for a year first" advice was never written for you.');
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
    final s = statusOf(id);
    // Something she has settled, either way, is not a next step.
    if (s == PrecheckStatus.done || s == PrecheckStatus.notRelevant) return;
    out.add(PrecheckPriority(item: item, reason: reason));
  }

  // ---- context-driven, in order of how much it changes her next month ------

  if (c.liveVaccineOutstanding) {
    consider(
        'vaccines',
        _en('A live vaccine on your list means about a month before trying — '
            'the only item here that can move your timing.'));
  }

  if (c.pcosLevelAtLeastDiscuss) {
    consider(
        'preconception_visit',
        _en('Your PCOS check found a pattern worth discussing, and one visit '
            'covers that alongside everything else here.'));
  }

  if (c.medicineCount > 0) {
    consider(
        'medication_review',
        _en('You have ${c.medicineCount} '
            '${c.medicineCount == 1 ? 'medicine' : 'medicines'} saved — the '
            'list is ready, the review is not.'));
  }

  if (c.cyclesLookIrregular || c.tryingOverAYear) {
    consider(
        'when_to_seek_help',
        c.tryingOverAYear
            ? _en('You have been trying over a year, which is the usual point '
                'to be seen.')
            : _en('Your cycles vary enough that the "wait a year" advice was '
                'not written for your situation.'));
  }

  if (!c.takesFolate) {
    consider(
        'folate',
        _en('The one item with the strongest evidence behind it, and the one '
            'that has to be started before rather than after.'));
  }

  if (c.loggedCycles < 2) {
    consider(
        'cycle_tracking',
        _en('Just the first day of each period. It is the most useful thing '
            'you can bring to any appointment.'));
  }

  // ---- fall back to her own flagged items, core first ----------------------
  for (final tier in PrecheckTier.values) {
    for (final item in kPrecheckItems) {
      if (item.tier != tier) continue;
      if (statusOf(item.id).isOpen) {
        consider(item.id, _en('You marked this as something to come back to.'));
      }
    }
  }

  // ---- and finally anything core she has not looked at ---------------------
  for (final item in kPrecheckItems) {
    if (item.tier != PrecheckTier.core) continue;
    consider(item.id, _en('One of the few here that applies to almost '
        'everyone.'));
  }

  return out;
}

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
    'This checklist is for planning and for preparing a conversation. It is '
    'not medical clearance, it cannot tell you whether you are ready to '
    'conceive, and not every item applies to everyone. Your doctor can tell '
    'you which of these are relevant to you.');
