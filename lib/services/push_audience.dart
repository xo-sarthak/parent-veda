// =============================================================================
//  PushAudience - the two facts only the phone knows, told to the server
// -----------------------------------------------------------------------------
//  Phase 6b, B2 (2026-10-30). docs/NOTIFICATIONS-6B-PLAN.md, "push_audience".
//
//  The server books a campaign on an evening only if the phone is not already
//  ringing then (two a day, decision 3), and never while TTC is quiet: after a
//  loss, in the two-week wait, or in a treatment round (decision 8, row 18;
//  B3 widened it). It cannot work either out, so `FamilyPhone` hands over
//  what it has just armed, and this uploads it. No new computing on the
//  phone: only a write of what was already decided.
//
//  ⚠️ BUSY EVENINGS, NOT FREE ONES. An evening missing from the list is free,
//  and that is TRUE by default: the phone only arms 14 days ahead, so every
//  evening past the upload's horizon really has nothing set. A "free" list
//  would be wrong by default, and a phone that had not opened the app in
//  weeks would read as full and never get a re-engagement offer.
//
//  Fire-and-forget, and only when something changed (or once a day, to keep
//  planned_at fresh). A lost upload costs at worst one extra notification on
//  one evening, so a retry is not worth its code.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../ttc/cycle_store.dart';
import '../ttc/ttc_day_context.dart' show ttcDayContext;
import '../ttc/ttc_phase.dart' show TtcDayPhase;
import '../ttc/ttc_treatment_round.dart' show ttcTreatmentActive;
import '../ttc/ttc_treatment_store.dart' show TtcTreatmentStore;
import 'life_stage_store.dart';
import 'preg_messages_store.dart' show kPregEveningFromHour;
import 'push_wire.dart';

/// How far ahead the phone arms, and so how far the list can know.
const int kPushAudienceDays = 14;

/// The evenings in [rings] from today to [kPushAudienceDays] ahead, each once,
/// in order. An evening is the afternoon slot, from [kPregEveningFromHour]:
/// the same split the phone's two-a-day plans use. Pure.
List<DateTime> pushBusyEvenings(Iterable<DateTime> rings, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final last = today.add(const Duration(days: kPushAudienceDays));
  final out = <DateTime>{};
  for (final r in rings) {
    if (r.hour < kPregEveningFromHour) continue;
    final d = DateTime(r.year, r.month, r.day);
    if (d.isBefore(today) || d.isAfter(last)) continue;
    out.add(d);
  }
  return out.toList()..sort();
}

// Kept for revert (6b B3, the flag grew from a loss to row 18's three
// reasons, and now speaks only while she is trying):
// /// TTC's quiet after a loss: a loss is recorded while she is trying, and she
// /// has not logged a period since. The same condition that keeps 6a's daily
// /// TTC messages silent (`CycleStore.restartOn`, `lastPeriodStart`).
// bool pushTtcQuiet() {
//   final c = CycleStore.instance;
//   return c.restartOn != null && c.lastPeriodStart == null;
// }

/// The phone's "no offers now" while she is trying (decision 8, row 18).
/// Still ONE yes/no: the server never reads her TTC data, only this. Pure.
///
/// * [afterLoss]: a loss recorded, no period logged since.
/// * [phase]: today's phase. The two-week wait and a late period are quiet:
///   an offer then reads as noise at best and as a nudge to test at worst.
/// * [treatmentActive]: an IVF, IUI, FET or tablet round runs from its first
///   date until she closes it.
///
/// ⚠️ ONLY WHILE TRYING. A TTC cycle that reads "late" because she got
/// pregnant would otherwise silence her pregnancy offers for good. A loss in
/// pregnancy is the server's to see (the 0112 condition).
bool pushTtcQuietFrom({
  required bool trying,
  required bool afterLoss,
  required TtcDayPhase phase,
  required bool treatmentActive,
}) {
  if (!trying) return false;
  return afterLoss ||
      phase == TtcDayPhase.waiting ||
      phase == TtcDayPhase.late ||
      treatmentActive;
}

/// [pushTtcQuietFrom], read from the stores. A phase that cannot be worked
/// out reads as quiet: an unknown day gets no offer, the safe direction.
bool pushTtcQuiet({DateTime? now}) {
  if (LifeStageStore.instance.stage != LifeStage.tryingToConceive) {
    return false;
  }
  final t = now ?? DateTime.now();
  final c = CycleStore.instance;
  final afterLoss = c.restartOn != null && c.lastPeriodStart == null;
  TtcDayPhase phase;
  bool treating;
  try {
    phase = ttcDayContext(t, now: t).phase;
    treating = ttcTreatmentActive(TtcTreatmentStore.instance.cycle, t);
  } catch (_) {
    return true;
  }
  return pushTtcQuietFrom(
    trying: true,
    afterLoss: afterLoss,
    phase: phase,
    treatmentActive: treating,
  );
}

class PushAudience {
  PushAudience._();
  static final PushAudience instance = PushAudience._();

  String? _lastSent;

  /// Uploads what the phone has just armed. [rings] is every notification
  /// time set by the stage messages, all stages together.
  void upload({required Iterable<DateTime> rings, required bool quiet,
      DateTime? now}) {
    final uid = PushWire.userId();
    if (uid == null) return;
    final t = now ?? DateTime.now();
    final busy = pushBusyEvenings(rings, t);
    final params = PushWire.audienceParams(busyEvenings: busy, quiet: quiet);
    // The same plan, for the same person, on the same day: nothing to say.
    final sig = '$uid|${PushWire.dateKey(t)}|$params';
    if (sig == _lastSent) return;
    _lastSent = sig;
    void failed(Object e) {
      // Let the next re-arm try again; the loss is one evening at worst.
      if (_lastSent == sig) _lastSent = null;
      debugPrint('[push] audience not sent: $e');
    }

    try {
      PushWire.call(PushWire.audience, params).then((_) {}, onError: failed);
    } catch (e) {
      failed(e);
    }
  }

  /// Test seam.
  @visibleForTesting
  void debugReset() => _lastSent = null;
}
