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
///
/// ⚠️ IN INDIA'S CALENDAR (6b leftover L2): the server compares these with
/// `send_on`, an IST date, and books 19:00 IST. A ring is placed by its IST
/// day and hour, so a phone in another zone names the evening the server
/// means. On an Indian phone nothing changes.
List<DateTime> pushBusyEvenings(Iterable<DateTime> rings, DateTime now) {
  // Kept for revert (L2, local calendar):
  //   final today = DateTime(now.year, now.month, now.day);
  //   if (r.hour < kPregEveningFromHour) continue;
  //   final d = DateTime(r.year, r.month, r.day);
  final today = PushWire.istDay(now);
  // By the calendar, not 14 x 24 hours: abroad, a summer-time change inside
  // the fortnight would put the last day's midnight past the horizon.
  final last = DateTime(today.year, today.month, today.day + kPushAudienceDays);
  final out = <DateTime>{};
  for (final r in rings) {
    if (PushWire.istHour(r) < kPregEveningFromHour) continue;
    final d = PushWire.istDay(r);
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

/// The IST evenings from India's today to [kPushAudienceDays] ahead on which
/// [pushTtcQuiet]'s rule holds, each worked out for that day (6b leftover
/// L3, 0151). The server reads the date; the yes/no stays as its fallback.
///
/// WHY DATES: the yes/no is as fresh as her last app open. Opened on day 12
/// (fertile window) and not again for five days, it still says "not quiet"
/// in her two-week wait. The phone already projects her cycle 14 days ahead
/// for its own messages, so it can say which evenings will be quiet.
///
/// * after a loss: every day, until she logs a period (the phone cannot
///   know when that will be, so it holds for the whole fortnight);
/// * the two-week wait or late: from the day's own phase;
/// * a treatment round: open on that day.
///
/// A day whose phase cannot be worked out is quiet, as in [pushTtcQuiet].
/// Not trying: none, for the same reason the yes/no is false then.
List<DateTime> pushTtcQuietEvenings({DateTime? now}) {
  if (LifeStageStore.instance.stage != LifeStage.tryingToConceive) {
    return const [];
  }
  final t = now ?? DateTime.now();
  final c = CycleStore.instance;
  final afterLoss = c.restartOn != null && c.lastPeriodStart == null;
  final first = PushWire.istDay(t);
  return pushQuietDays(first, (day) {
    try {
      return pushTtcQuietFrom(
        trying: true,
        afterLoss: afterLoss,
        // The phone's TTC engine counts its own calendar days; India's date
        // is handed to it as that day (the same y/m/d on an Indian phone).
        phase: ttcDayContext(day, now: t).phase,
        treatmentActive: ttcTreatmentActive(TtcTreatmentStore.instance.cycle, day),
      );
    } catch (_) {
      return true;
    }
  });
}

/// The days from [first] to [kPushAudienceDays] after it, by the calendar,
/// for which [quietOn] says yes. Pure; the seam [pushTtcQuietEvenings] fills.
List<DateTime> pushQuietDays(DateTime first, bool Function(DateTime day) quietOn) => [
      for (var i = 0; i <= kPushAudienceDays; i++)
        if (quietOn(DateTime(first.year, first.month, first.day + i)))
          DateTime(first.year, first.month, first.day + i),
    ];

class PushAudience {
  PushAudience._();
  static final PushAudience instance = PushAudience._();

  String? _lastSent;

  /// Uploads what the phone has just armed. [rings] is every notification
  /// time set by the stage messages, all stages together. [quietEvenings]
  /// (L3): [pushTtcQuietEvenings].
  void upload({required Iterable<DateTime> rings, required bool quiet,
      List<DateTime> quietEvenings = const [], DateTime? now}) {
    final uid = PushWire.userId();
    if (uid == null) return;
    final t = now ?? DateTime.now();
    final busy = pushBusyEvenings(rings, t);
    final params = PushWire.audienceParams(
        busyEvenings: busy, quiet: quiet, quietEvenings: quietEvenings);
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
