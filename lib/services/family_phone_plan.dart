// =============================================================================
//  One phone plan for the family: Pregnancy and Parenting share two slots a
//  day (PP 11, 2026-10-29; docs/NOTIFICATIONS-PLAN.md, "As built: Parenting")
// -----------------------------------------------------------------------------
//  A mother pregnant again with a toddler has two message stores speaking at
//  once: `PregMessagesStore` (hers) and `PpMessagesStore` (the toddler's).
//  Pregnancy capped itself at two a day; Parenting had no cap at all, so the
//  phone could ring five times. The user's rule (2026-10-28, kept for both):
//  at most two a day, one slot before 2 pm and one after.
//
//  TWO PIECES, ON PURPOSE:
//
//  1. [familyPhonePlan] is the RULE, and it is pure: both pending lists in,
//     the winners and their ids out. One scale for both stores:
//
//       1    a vaccine visit, a pregnancy dated moment (scans, Tdap, the bag)
//       2    an age, a new stage
//       3    Pregnancy's new week
//       4    the Monday activity
//       4.5  a tip (the child's, or Pregnancy's day line)
//       5    the check-in
//       6    an offer
//
//     On a tie, the earlier time; then, between the stores, Parenting on odd
//     days and Pregnancy on even ones (the toddler's tip only comes on odd
//     days, so on those mornings it wins); then, between two children, the
//     one whose week it is. Pregnancy's own ranks keep their order on this
//     scale, so with no child the plan is `pregPhonePlan`'s exactly.
//
//  2. [FamilyPhone] is the OWNER of arming: the one place that reads both
//     stores and arms both. Each store still cancels and arms only its own
//     id block (919101.., 929101..), through its own phone interface, so a
//     stage change can never cancel the other's alarms and each store's
//     tests still see exactly what it scheduled.
//
//  ⚠️ THE TRADE-OFF. A refresh of either store now re-arms both: a few dozen
//  cancel and schedule calls instead of one store's share. That is the price
//  of a cap that is right by construction. The alternative, each store
//  arming itself while reading the other's list, keeps refreshes cheap but
//  lets the two race: Pregnancy arms its morning winner from Parenting's old
//  list, Parenting re-arms from Pregnancy's, and for a moment both ring the
//  same slot. One owner, serialised, has no such moment.
//
//  A store that has not loaded yet is left alone: it has armed nothing this
//  session, and its own init triggers the next re-arm.
//
//  NOT PREGNANT: MOMENTS ALWAYS RING, AND NOTHING RINGS TOGETHER
//  (2026-10-29, the user's call after PP 11)
//
//  Two a day was right for a pregnancy and a toddler at once. For Parenting
//  on its own, and for a child while she is trying again, the user decided
//  otherwise: "it has to be dynamic. We cannot be fixing something and then
//  just missing out on information." So with no pregnancy, [parentingPhonePlan]:
//
//    * a MOMENT (a vaccine visit, an age, a new stage: rank 2 or better)
//      always rings, for every child;
//    * a DAILY kind (the tip, the Monday activity, an offer) keeps one slot
//      per half day, and only in a half with no moment in it;
//    * and [spacePhoneRings] keeps every ring at least [kFamilyRingGap] from
//      every other one, hers from TTC included.
//
//  TRYING AGAIN WITH A CHILD. TTC arms itself, exactly as on its own
//  (`ttcPhonePlan`, its own two a day, treatment never capped), and never
//  moves. Parenting's rings step out of its way. That makes the dependency
//  ONE-WAY: TTC's plan never reads Parenting's, so there is no race of the
//  kind the header warns about, and TTC needs no shared owner. TTC asks for a
//  re-arm after it arms, and a re-arm reads TTC's latest plan; a stale read
//  is corrected by the next one. The cost: a TTC refresh re-arms Parenting
//  too. The gain: TTC's arming is untouched by construction, not by care.
//
//  ⚠️ ONLY THE PHONE TIME MOVES. The message keeps its own time in Messages,
//  its id and its cloud row: a corrected cycle date must never rewrite a
//  child's message, which it would if the store's `at` depended on TTC's.
//
//  A CAMPAIGN TAKES THE EVENING (6b B5, 2026-10-30; `push_bookings.dart`).
//  On an evening the server has booked a campaign for her, the capped evening
//  message stays in Messages and does not ring: the campaign is that
//  evening's one. A moment (rank 2 or better) still rings, here and in
//  [parentingPhonePlan]: an offer never silences care. The server books only
//  evenings the phone called free, so this is the backstop for a stale copy,
//  not the everyday path.
// =============================================================================

import 'dart:async';

import '../screens/post_pregnancy/pp_child_profile.dart' show ChildProfileStore;
import '../ttc/ttc_messages_store.dart';
import 'life_stage_store.dart';
import 'pp_messages_store.dart';
import 'preg_messages_store.dart';
import 'push_audience.dart';
import 'push_bookings.dart';
import 'push_wire.dart' show PushWire;

/// Pregnancy's kinds on the family scale. The order is [PregMessageKindInfo.slotRank]'s.
double pregFamilyRank(PregMessageKind k) => switch (k) {
  PregMessageKind.newWeek => 3,
  PregMessageKind.dayLine => 4.5,
  PregMessageKind.checkIn => 5,
  PregMessageKind.offer => 6,
  _ => 1,
};

class _Item {
  _Item.preg(PregMessage m)
    : preg = m,
      pp = null,
      at = m.at,
      rank = pregFamilyRank(m.kind),
      child = 0;
  _Item.pp(PpMessage m, this.child)
    : preg = null,
      pp = m,
      at = m.at,
      rank = m.kind.slotRank;

  final PregMessage? preg;
  final PpMessage? pp;
  final DateTime at;
  final double rank;

  /// The child's place in the family (Parenting only).
  final int child;
}

/// The ranks a campaign never silences (6b B5): the moments.
const double kFamilyMomentRank = 2;

/// The hour a booked campaign arrives (19:00 IST, B4). A moment that still
/// rings on that evening keeps [kFamilyRingGap] clear of it.
const int kPushCampaignHour = 19;

String _slot(DateTime at) =>
    '${at.year}-${at.month}-${at.day}|${at.hour < kPregEveningFromHour ? 'am' : 'pm'}';

/// Which pending messages ring, and on which id, for both stores. Pure.
///
/// [childIds] is the family's children in order, to tell whose turn it is.
/// Per calendar day, one morning slot and one evening slot; in each the
/// lowest rank wins (see the header for the ties). Each winner takes the next
/// free id of its own kind; a kind out of ids waits for a later refresh.
///
/// [bookedEvenings] (6b B5): days whose evening a campaign holds. There only
/// a moment may still ring; everything else stays in Messages.
({List<(int, PregMessage)> preg, List<(int, PpMessage)> pp}) familyPhonePlan({
  List<PregMessage> preg = const [],
  List<PpMessage> pp = const [],
  List<String> childIds = const [],
  Set<DateTime> bookedEvenings = const {},
}) {
  final n = childIds.isEmpty ? 1 : childIds.length;
  int childOf(PpMessage m) {
    final id = ppMessageChildId(m.id, childIds);
    final i = id == null ? 0 : childIds.indexOf(id);
    return i < 0 ? 0 : i;
  }

  bool beats(_Item a, _Item cur) {
    if (a.rank != cur.rank) return a.rank < cur.rank;
    if (a.at != cur.at) return a.at.isBefore(cur.at);
    final aPp = a.pp != null, curPp = cur.pp != null;
    if (aPp != curPp) return aPp == ppDayNumber(a.at).isOdd;
    if (aPp) {
      final turn = ppWeekNumber(a.at) % n;
      return a.child == turn && cur.child != turn;
    }
    return false;
  }

  final best = <String, _Item>{};
  for (final it in [
    for (final m in preg) _Item.preg(m),
    for (final m in pp) _Item.pp(m, childOf(m)),
  ]) {
    if (it.rank > kFamilyMomentRank &&
        pushEveningBooked(it.at, bookedEvenings, kPregEveningFromHour)) {
      continue;
    }
    final key = _slot(it.at);
    final cur = best[key];
    if (cur == null || beats(it, cur)) best[key] = it;
  }

  final winners = best.values.toList()..sort((a, b) => a.at.compareTo(b.at));
  final usedPreg = <PregMessageKind, int>{};
  final usedPp = <PpMessageKind, int>{};
  final outPreg = <(int, PregMessage)>[];
  final outPp = <(int, PpMessage)>[];
  for (final w in winners) {
    final p = w.preg;
    if (p != null) {
      final ids = p.kind.phoneIds;
      final i = usedPreg[p.kind] ?? 0;
      if (i >= ids.length) continue;
      usedPreg[p.kind] = i + 1;
      outPreg.add((ids[i], p));
    } else {
      final m = w.pp!;
      final ids = m.kind.phoneIds;
      final i = usedPp[m.kind] ?? 0;
      if (i >= ids.length) continue;
      usedPp[m.kind] = i + 1;
      outPp.add((ids[i], m));
    }
  }
  return (preg: outPreg, pp: outPp);
}

/// The least time between two rings on her phone, when she is not pregnant.
const Duration kFamilyRingGap = Duration(minutes: 60);

/// A moved ring steps by this, and stays between these hours of its own day.
const Duration kFamilyRingStep = Duration(minutes: 30);
const int kFamilyRingFromHour = 8;
const int kFamilyRingUntilHour = 21;

/// Parenting's phone plan with no pregnancy (see the header). Pure.
///
/// Moments (rank 2 or better) all ring; a daily kind wins its half day the
/// [familyPhonePlan] way, only where no moment is. Then [spacePhoneRings]
/// keeps them [kFamilyRingGap] apart and clear of [keepClearOf] (what TTC
/// armed). Each ring takes the next free id of its kind, soonest first.
///
/// [bookedEvenings] (6b B5): on those evenings no daily kind rings, and the
/// moments keep clear of the campaign's 19:00 as they do of TTC's rings.
List<(int, PpMessage)> parentingPhonePlan({
  List<PpMessage> pp = const [],
  List<String> childIds = const [],
  List<DateTime> keepClearOf = const [],
  DateTime? now,
  Set<DateTime> bookedEvenings = const {},
}) {
  // Kept for revert (6b B5, one constant): m.kind.slotRank <= 2
  bool moment(PpMessage m) => m.kind.slotRank <= kFamilyMomentRank;
  final busy = {
    for (final m in pp)
      if (moment(m)) _slot(m.at),
  };
  final daily = familyPhonePlan(
    pp: [
      for (final m in pp)
        if (!moment(m) && !busy.contains(_slot(m.at))) m,
    ],
    childIds: childIds,
    bookedEvenings: bookedEvenings,
  ).pp;
  final rings = [
    for (final m in pp)
      if (moment(m)) m,
    for (final (_, m) in daily) m,
  ]..sort((a, b) => a.at.compareTo(b.at));
  final used = <PpMessageKind, int>{};
  final out = <(int, PpMessage)>[];
  for (final m in rings) {
    final ids = m.kind.phoneIds;
    final i = used[m.kind] ?? 0;
    if (i >= ids.length) continue;
    used[m.kind] = i + 1;
    out.add((ids[i], m));
  }
  // Kept for revert (6b B5, the campaign's 19:00 is kept clear too):
  //   return spacePhoneRings(out, keepClearOf: keepClearOf, now: now);
  return spacePhoneRings(
    out,
    keepClearOf: [
      ...keepClearOf,
      // 19:00 IST, as a phone time (6b leftover L2). Kept for revert:
      //   DateTime(d.year, d.month, d.day, kPushCampaignHour),
      for (final d in bookedEvenings)
        PushWire.istTime(d, kPushCampaignHour),
    ],
    now: now,
  );
}

/// Moves each ring that would land within [kFamilyRingGap] of another to the
/// nearest clear time, in [kFamilyRingStep]s, later first on a tie, inside
/// [kFamilyRingFromHour]..[kFamilyRingUntilHour] of its own day and after
/// [now]. [keepClearOf] never moves; among [rings], the earlier keeps its
/// time. With no clear time that day it rings at its own: moved, never
/// dropped. Pure; only the phone time changes (`copyWith(at:)`).
List<(int, PpMessage)> spacePhoneRings(
  List<(int, PpMessage)> rings, {
  List<DateTime> keepClearOf = const [],
  DateTime? now,
}) {
  final placed = [...keepClearOf];
  bool clear(DateTime t) =>
      placed.every((o) => t.difference(o).abs() >= kFamilyRingGap);
  bool fits(DateTime t, DateTime own) {
    final from = DateTime(own.year, own.month, own.day, kFamilyRingFromHour);
    final until = DateTime(own.year, own.month, own.day, kFamilyRingUntilHour);
    return !t.isBefore(from) &&
        !t.isAfter(until) &&
        (now == null || t.isAfter(now));
  }

  final sorted = [...rings]..sort((a, b) => a.$2.at.compareTo(b.$2.at));
  final out = <(int, PpMessage)>[];
  for (final (id, m) in sorted) {
    var at = m.at;
    if (!clear(at)) {
      for (var k = 1; k < 48; k++) {
        final later = m.at.add(kFamilyRingStep * k);
        final earlier = m.at.subtract(kFamilyRingStep * k);
        if (fits(later, m.at) && clear(later)) {
          at = later;
          break;
        }
        if (fits(earlier, m.at) && clear(earlier)) {
          at = earlier;
          break;
        }
      }
    }
    placed.add(at);
    out.add((id, at == m.at ? m : m.copyWith(at: at)));
  }
  return out;
}

/// The one owner of arming for Pregnancy and Parenting (see the header).
class FamilyPhone {
  FamilyPhone._();
  static final FamilyPhone instance = FamilyPhone._();

  Future<void>? _running;
  bool _again = false;
  DateTime? _againNow;

  /// Re-plans both stores and re-arms both. Concurrent calls collapse into
  /// one more run, as the stores' refreshes do, so the last plan armed is
  /// always made from both stores' latest lists.
  Future<void> rearm({DateTime? now}) async {
    if (_running != null) {
      _again = true;
      _againNow = now;
      return _running;
    }
    final run = _rearm(now);
    _running = run;
    try {
      await run;
    } finally {
      _running = null;
    }
    if (_again) {
      _again = false;
      await rearm(now: _againNow);
    }
  }

  Future<void> _rearm(DateTime? fixedNow) async {
    final now = fixedNow ?? DateTime.now();
    final preg = PregMessagesStore.instance;
    final pp = PpMessagesStore.instance;
    List<String> ids;
    try {
      ids = [for (final c in ChildProfileStore.instance.children) c.id];
    } catch (_) {
      ids = const [];
    }
    final pregList = preg.isLoaded
        ? preg.phonePending(now: now)
        : const <PregMessage>[];
    final ppList = pp.isLoaded
        ? pp.phonePending(now: now)
        : const <PpMessage>[];
    // 6b B5: the evenings a campaign holds (`push_bookings.dart`).
    final booked = PushBookings.instance.bookedEvenings(now: now);
    // Pregnant (or a pregnancy still speaking): one cap of two for both, as
    // PP 11 built it. Otherwise moments always ring, spaced clear of TTC.
    if (LifeStageStore.instance.stage == LifeStage.pregnancy ||
        pregList.isNotEmpty) {
      // Kept for revert (2026-10-29, this branch was the whole plan):
      //   final plan = familyPhonePlan(
      //     preg: preg.isLoaded ? preg.phonePending(now: now) : const [],
      //     pp: pp.isLoaded ? pp.phonePending(now: now) : const [],
      //     childIds: ids,
      //   );
      // Kept for revert (6b B5, the booked evenings go in):
      //   final plan = familyPhonePlan(preg: pregList, pp: ppList, childIds: ids);
      final plan = familyPhonePlan(
        preg: pregList,
        pp: ppList,
        childIds: ids,
        bookedEvenings: booked,
      );
      if (preg.isLoaded) await preg.armPhone(plan.preg);
      if (pp.isLoaded) await pp.armPhone(plan.pp);
      _tellServer(now, [
        for (final (_, m) in plan.preg) m.at,
        for (final (_, m) in plan.pp) m.at,
      ]);
      return;
    }
    final ttc = TtcMessagesStore.instance;
    final ttcRings = ttc.isLoaded
        ? [for (final (_, m) in ttc.phonePlanned(now: now)) m.at]
        : const <DateTime>[];
    if (preg.isLoaded) await preg.armPhone(const []);
    final ppPlan = parentingPhonePlan(
      pp: ppList,
      childIds: ids,
      keepClearOf: ttcRings,
      now: now,
      bookedEvenings: booked,
    );
    // Kept for revert (6b B2, the plan is now named so the server hears it):
    //   if (pp.isLoaded) {
    //     await pp.armPhone(
    //       parentingPhonePlan(
    //         pp: ppList,
    //         childIds: ids,
    //         keepClearOf: ttcRings,
    //         now: now,
    //       ),
    //     );
    //   }
    if (pp.isLoaded) await pp.armPhone(ppPlan);
    _tellServer(now, [for (final (_, m) in ppPlan) m.at]);
  }

  /// 6b B2: tells the server which evenings now ring and whether TTC is
  /// quiet (a loss, the two-week wait, a treatment round; B3) (`push_audience.dart`). Every stage's rings, TTC's
  /// included, since its own plan arms apart from this one.
  ///
  /// ⚠️ A BOOKED EVENING DROPS OUT OF THE LIST (6b B5): the rings here are
  /// what the phone itself arms, after the campaign took the evening. That
  /// is correct. The server holds a booked evening with its own
  /// one-campaign-an-evening index, not with this list. If the campaign is
  /// cancelled, the next refresh finds no booking, the phone's own message
  /// rings again, and the evening comes back as busy.
  ///
  /// ⚠️ ONLY WHEN ALL THREE STORES HAVE LOADED. One still loading may have
  /// alarms set on the phone from the last run that this run cannot see, and
  /// an upload then would say an evening is free when it rings. Skipping is
  /// safe: the store's own load triggers the next re-arm.
  void _tellServer(DateTime now, List<DateTime> rings) {
    final ttc = TtcMessagesStore.instance;
    if (!PregMessagesStore.instance.isLoaded ||
        !PpMessagesStore.instance.isLoaded ||
        !ttc.isLoaded) {
      return;
    }
    try {
      PushAudience.instance.upload(
        rings: [...rings, for (final (_, m) in ttc.phonePlanned(now: now)) m.at],
        quiet: pushTtcQuiet(now: now),
        quietEvenings: pushTtcQuietEvenings(now: now),
        now: now,
      );
    } catch (_) {/* never let the server copy break the phone's arming */}
  }
}
