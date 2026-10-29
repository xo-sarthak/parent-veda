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
// =============================================================================

import 'dart:async';

import '../screens/post_pregnancy/pp_child_profile.dart' show ChildProfileStore;
import 'pp_messages_store.dart';
import 'preg_messages_store.dart';

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

String _slot(DateTime at) =>
    '${at.year}-${at.month}-${at.day}|${at.hour < kPregEveningFromHour ? 'am' : 'pm'}';

/// Which pending messages ring, and on which id, for both stores. Pure.
///
/// [childIds] is the family's children in order, to tell whose turn it is.
/// Per calendar day, one morning slot and one evening slot; in each the
/// lowest rank wins (see the header for the ties). Each winner takes the next
/// free id of its own kind; a kind out of ids waits for a later refresh.
({List<(int, PregMessage)> preg, List<(int, PpMessage)> pp}) familyPhonePlan({
  List<PregMessage> preg = const [],
  List<PpMessage> pp = const [],
  List<String> childIds = const [],
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
    final plan = familyPhonePlan(
      preg: preg.isLoaded ? preg.phonePending(now: now) : const [],
      pp: pp.isLoaded ? pp.phonePending(now: now) : const [],
      childIds: ids,
    );
    if (preg.isLoaded) await preg.armPhone(plan.preg);
    if (pp.isLoaded) await pp.armPhone(plan.pp);
  }
}
