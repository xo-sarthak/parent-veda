// =============================================================================
//  PushAudience - the two facts only the phone knows, told to the server
// -----------------------------------------------------------------------------
//  Phase 6b, B2 (2026-10-30). docs/NOTIFICATIONS-6B-PLAN.md, "push_audience".
//
//  The server books a campaign on an evening only if the phone is not already
//  ringing then (two a day, decision 3), and never during TTC's quiet after a
//  loss (decision 8). It cannot work either out, so `FamilyPhone` hands over
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

/// TTC's quiet after a loss: a loss is recorded while she is trying, and she
/// has not logged a period since. The same condition that keeps 6a's daily
/// TTC messages silent (`CycleStore.restartOn`, `lastPeriodStart`).
bool pushTtcQuiet() {
  final c = CycleStore.instance;
  return c.restartOn != null && c.lastPeriodStart == null;
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
