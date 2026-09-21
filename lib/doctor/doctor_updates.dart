// =============================================================================
//  Updates — what the bell holds
// -----------------------------------------------------------------------------
//  2026-09-21: the bell used to open the task list ("add your bank account",
//  "19 prescriptions"). The user's correction: a bell is a notification
//  panel — missed things and updates — and chores belong on Home as a rail.
//  So the bell now holds UPDATES: a parent booked, a consultation is about to
//  start, a class is next week, money came in, a payout went out, a word from
//  ParentVeda.
//
//  There is no notifications table. Every update here is DERIVED from rows
//  the app already holds (bookings, the ledger, payouts, notices), which is
//  what Monzo's and Deel's feeds are too: a projection of the account's own
//  events, ordered by time. That buys two things. Nothing can be stale —
//  the feed is recomputed from the stores on every build. And nothing can be
//  fake — a seeded month produces a real month of updates, and an empty
//  account produces an honest "nothing yet". The cost is that read-state has
//  nowhere to live server-side, so it lives in shared_preferences keyed by
//  the update's id; ids are deterministic (derived from the row's id) so a
//  refresh does not resurrect what she has already seen.
//
//  The function is pure — plain inputs in, a sorted list out — so a test can
//  hand it a day and check the sentences.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What kind of thing happened, which decides the mark and where a tap goes.
enum DoctorUpdateKind { booking, callSoon, classSoon, earning, reversal, payout, payoutScheduled, notice }

class DoctorUpdate {
  const DoctorUpdate({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.at,
    this.refId,
  });

  /// Deterministic: derived from the row's id, so read-state survives a refresh.
  final String id;
  final DoctorUpdateKind kind;
  final String title;
  final String body;
  /// When it happened (or, for a reminder, when it started to matter).
  final DateTime at;
  /// The row behind it (booking id, payout id, notice url…), for the tap.
  final String? refId;
}

// ---- inputs, kept plain so the function needs no store ---------------------

class UpdateBooking {
  const UpdateBooking({required this.id, required this.who, required this.startsAt, required this.durationMin, required this.bookedAt});
  final String id;
  final String who;
  final DateTime startsAt;
  final int durationMin;
  final DateTime bookedAt;
}

class UpdateClass {
  const UpdateClass({required this.id, required this.title, required this.kind, required this.startsAt, this.seats});
  final String id;
  final String title;
  /// "Masterclass" / "Cohort".
  final String kind;
  final DateTime startsAt;
  final int? seats;
}

class UpdateEarning {
  const UpdateEarning({required this.id, required this.headline, required this.source, required this.at, required this.expertPaise, required this.reversal, this.note});
  final String id;
  final String headline;
  final String source;
  final DateTime at;
  final int expertPaise;
  final bool reversal;
  final String? note;
}

class UpdatePayout {
  const UpdatePayout({required this.id, required this.amountPaise, required this.status, required this.at, this.bankLast4, this.reference});
  final String id;
  final int amountPaise;
  /// scheduled | processing | paid | failed
  final String status;
  final DateTime at;
  final String? bankLast4;
  final String? reference;
}

class UpdateNotice {
  const UpdateNotice({required this.id, required this.title, required this.body, required this.at, this.url});
  final String id;
  final String title;
  final String body;
  final DateTime at;
  final String? url;
}

class DoctorUpdateInput {
  const DoctorUpdateInput({
    required this.now,
    this.upcoming = const [],
    this.classes = const [],
    this.earnings = const [],
    this.payouts = const [],
    this.notices = const [],
    required this.rupees,
    required this.dayDate,
    required this.time,
  });
  final DateTime now;
  final List<UpdateBooking> upcoming;
  final List<UpdateClass> classes;
  final List<UpdateEarning> earnings;
  final List<UpdatePayout> payouts;
  final List<UpdateNotice> notices;
  // Formatting is the chrome's job; passed in so this file owns no style.
  final String Function(int paise) rupees;
  final String Function(DateTime d) dayDate;
  final String Function(DateTime d) time;
}

/// "today", "tomorrow", "on Thursday", "on Tue 29 Sep".
String doctorRelativeDay(DateTime d, DateTime now, String Function(DateTime) dayDate) {
  final l = d.toLocal();
  final n = now.toLocal();
  final day = DateTime(l.year, l.month, l.day);
  final today = DateTime(n.year, n.month, n.day);
  final diff = day.difference(today).inDays;
  if (diff == 0) return 'today';
  if (diff == 1) return 'tomorrow';
  if (diff == -1) return 'yesterday';
  const wd = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  if (diff > 1 && diff < 7) return 'on ${wd[l.weekday - 1]}';
  return 'on ${dayDate(d)}';
}

/// The feed, newest first, at most [cap] rows.
List<DoctorUpdate> doctorUpdates(DoctorUpdateInput i, {int cap = 40}) {
  final out = <DoctorUpdate>[];
  final now = i.now;

  // A parent booked — dated when she booked, so it reads as news.
  for (final b in i.upcoming) {
    out.add(DoctorUpdate(
      id: 'bk_${b.id}',
      kind: DoctorUpdateKind.booking,
      title: '${b.who} booked a consultation',
      body: '${i.dayDate(b.startsAt)} · ${i.time(b.startsAt)} · ${b.durationMin} min',
      at: b.bookedAt,
      refId: b.id,
    ));
  }

  // A consultation inside the next 24 hours — a reminder, dated now.
  for (final b in i.upcoming) {
    final until = b.startsAt.difference(now);
    if (until.inMinutes < -b.durationMin || until.inHours >= 24) continue;
    final when = until.inMinutes <= 0
        ? 'is on now'
        : until.inMinutes < 60
            ? 'starts in ${until.inMinutes} min'
            : 'is ${doctorRelativeDay(b.startsAt, now, i.dayDate)} at ${i.time(b.startsAt)}';
    out.add(DoctorUpdate(
      id: 'soon_${b.id}',
      kind: DoctorUpdateKind.callSoon,
      title: 'Your consultation with ${b.who} $when',
      body: 'Join opens ten minutes before. ${b.durationMin} min.',
      at: now,
      refId: b.id,
    ));
  }

  // A class within the next fortnight.
  for (final c in i.classes) {
    final until = c.startsAt.difference(now);
    if (until.isNegative || until.inDays > 14) continue;
    final seats = c.seats == null ? '' : ' · ${c.seats} seats';
    out.add(DoctorUpdate(
      id: 'cls_${c.id}',
      kind: DoctorUpdateKind.classSoon,
      title: 'Your ${c.kind.toLowerCase()} is ${doctorRelativeDay(c.startsAt, now, i.dayDate)}',
      body: '${c.title} · ${i.time(c.startsAt)}$seats',
      at: c.startsAt.subtract(const Duration(days: 7)).isBefore(now) ? c.startsAt.subtract(const Duration(days: 7)) : now,
      refId: c.id,
    ));
  }

  // Money in, and money taken back.
  for (final e in i.earnings) {
    if (now.difference(e.at).inDays > 60) continue;
    // "Consultation · Consultation" when the row has no parent name: say
    // the source once.
    final what = e.headline.trim().isEmpty || e.headline.trim().toLowerCase() == e.source.toLowerCase()
        ? e.source
        : '${e.source} · ${e.headline.trim()}';
    final amount = e.expertPaise.abs();
    out.add(e.reversal
        ? DoctorUpdate(
            id: 'rev_${e.id}',
            kind: DoctorUpdateKind.reversal,
            title: amount == 0 ? 'A ${e.source.toLowerCase()} was reversed' : '${i.rupees(amount)} reversed',
            body: e.note?.trim().isNotEmpty == true ? e.note!.trim() : what,
            at: e.at,
            refId: e.id,
          )
        : DoctorUpdate(
            id: 'earn_${e.id}',
            kind: DoctorUpdateKind.earning,
            title: 'You earned ${i.rupees(amount)}',
            body: what,
            at: e.at,
            refId: e.id,
          ));
  }

  // Payouts: sent, or on the way.
  for (final p in i.payouts) {
    final to = p.bankLast4 == null ? 'your account' : 'your account ending ${p.bankLast4}';
    switch (p.status) {
      case 'paid':
        out.add(DoctorUpdate(
          id: 'po_${p.id}',
          kind: DoctorUpdateKind.payout,
          title: '${i.rupees(p.amountPaise)} sent to $to',
          body: p.reference == null ? 'Bank transfer' : 'Bank transfer · ref ${p.reference}',
          at: p.at,
          refId: p.id,
        ));
      case 'scheduled':
      case 'processing':
        out.add(DoctorUpdate(
          id: 'pos_${p.id}',
          kind: DoctorUpdateKind.payoutScheduled,
          title: '${i.rupees(p.amountPaise)} payout ${p.status == 'processing' ? 'is on its way' : 'is scheduled'}',
          body: 'To $to · ${i.dayDate(p.at)}',
          at: p.at.isAfter(now) ? now : p.at,
          refId: p.id,
        ));
      case 'failed':
        out.add(DoctorUpdate(
          id: 'pof_${p.id}',
          kind: DoctorUpdateKind.reversal,
          title: '${i.rupees(p.amountPaise)} payout did not go through',
          body: 'Check your payout account. We retry once it is corrected.',
          at: p.at,
          refId: p.id,
        ));
    }
  }

  for (final n in i.notices) {
    out.add(DoctorUpdate(
      id: 'ntc_${n.id}',
      kind: DoctorUpdateKind.notice,
      title: n.title,
      body: n.body,
      at: n.at,
      refId: n.url,
    ));
  }

  out.sort((a, b) => b.at.compareTo(a.at));
  return out.length > cap ? out.sublist(0, cap) : out;
}

// ---- read state --------------------------------------------------------------

/// Which update ids she has seen. Opening the panel marks everything on it
/// read (Deel, Monzo): the badge is "since you last looked", not a to-do
/// count — the to-do count lives on Home's rail.
class DoctorUpdatesRead extends ChangeNotifier {
  DoctorUpdatesRead._();
  static final DoctorUpdatesRead instance = DoctorUpdatesRead._();

  static const _key = 'doctor_updates_read';
  static const _cap = 200;

  final Set<String> _read = {};
  bool _loaded = false;

  bool isRead(String id) => _read.contains(id);
  int unread(Iterable<DoctorUpdate> all) => all.where((u) => !_read.contains(u.id)).length;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final sp = await SharedPreferences.getInstance();
      _read.addAll(sp.getStringList(_key) ?? const []);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllRead(Iterable<DoctorUpdate> all) async {
    var changed = false;
    for (final u in all) {
      if (_read.add(u.id)) changed = true;
    }
    if (!changed) return;
    notifyListeners();
    try {
      final sp = await SharedPreferences.getInstance();
      // Keep the newest ids only; anything older has scrolled off the feed.
      final list = _read.toList();
      await sp.setStringList(_key, list.length > _cap ? list.sublist(list.length - _cap) : list);
    } catch (_) {}
  }
}
