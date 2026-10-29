// =============================================================================
//  DoctorReminders — the nudges that stop a doctor missing a consultation
// -----------------------------------------------------------------------------
//  The spec's ladder, and the reasoning behind each rung:
//     24 hours  — plan the day around it
//      1 hour   — be somewhere with signal
//     10 minutes— actually open the app
//
//  A missed consultation is the worst outcome in the whole product: the parent
//  waited, paid, and nobody came. It costs more trust than a dozen small UI
//  faults, so this is deliberately the one place the doctor app is pushy.
//
//  Ids are DERIVED from the booking id, so re-syncing cannot double-book a
//  notification and cancelling ONE booking needs no side table. Cancelling ALL
//  of them at sign-out does: see [DoctorReminders.cancelAll].
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../booking/booking_models.dart';
import '../services/notification_service.dart';

class DoctorReminders {
  DoctorReminders._();
  static final DoctorReminders instance = DoctorReminders._();

  /// Minutes before the consultation, and how each one reads.
  static const _ladder = <(int, String)>[
    (24 * 60, 'Tomorrow'),
    (60, 'In an hour'),
    (10, 'In 10 minutes'),
  ];

  /// A stable, collision-resistant id per (booking, rung). Deriving it from the
  /// booking id means scheduling twice overwrites rather than duplicates.
  static int notificationId(String bookingId, int rung) =>
      (bookingId.hashCode & 0x0fffffff) * 4 + rung;

  /// (Re)schedule the whole ladder for one upcoming consultation.
  Future<void> scheduleFor(Booking b) async {
    if (b.status != BookingStatus.upcoming) return;
    final start = b.startsUtc.toLocal();
    for (var i = 0; i < _ladder.length; i++) {
      final (minsBefore, lead) = _ladder[i];
      final when = start.subtract(Duration(minutes: minsBefore));
      // scheduleOneOff already refuses times in the past, but skipping here
      // keeps the intent obvious: a consult booked in 20 minutes gets ONE
      // reminder, not three silent failures.
      if (!when.isAfter(DateTime.now())) continue;
      await _remember(b.id);
      await NotificationService.instance.scheduleOneOff(
        id: notificationId(b.id, i),
        title: '$lead · ${b.title}',
        body: _body(b, minsBefore),
        when: when,
      );
    }
  }

  static String _body(Booking b, int minsBefore) {
    final t = b.startsUtc.toLocal();
    final hh = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final mm = t.minute.toString().padLeft(2, '0');
    final ap = t.hour < 12 ? 'AM' : 'PM';
    final at = '$hh:$mm $ap';
    return minsBefore == 10
        ? 'Starting at $at. Open ParentVeda to join.'
        : 'Consultation at $at, ${b.durationMin} minutes.';
  }

  Future<void> cancelFor(String bookingId) async {
    for (var i = 0; i < _ladder.length; i++) {
      await NotificationService.instance.cancel(notificationId(bookingId, i));
    }
    await _forget({bookingId});
  }

  // ---- what is armed, so sign-out can disarm it (Partner Editions D1) -----
  //
  // Ids are derived, which makes re-arming safe, but cancelling needs the
  // booking ids, and after sign-out the roster that knew them is gone. So the
  // booking ids are written down as they are armed. Without this a doctor
  // who signed out kept getting "In 10 minutes" for consults that are no
  // longer theirs to see, and so did whoever signed in next on that phone.
  //
  // Why not NotificationService.cancelAllScheduled()? In the parent build the
  // same plugin carries her pregnancy and medicine reminders, and the old
  // doctor profile screen signs out from there too. This cancels only what
  // this class scheduled.
  static const _armedKey = 'doctor_reminders_armed';

  Future<void> _remember(String bookingId) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final ids = (sp.getStringList(_armedKey) ?? const []).toSet();
      if (ids.add(bookingId)) await sp.setStringList(_armedKey, ids.toList());
    } catch (_) {/* best-effort: the reminder itself still goes out */}
  }

  Future<void> _forget(Set<String> bookingIds) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final ids = (sp.getStringList(_armedKey) ?? const []).toSet()..removeAll(bookingIds);
      await sp.setStringList(_armedKey, ids.toList());
    } catch (_) {}
  }

  /// Sign-out: cancel every reminder this class ever armed on this phone.
  Future<void> cancelAll() async {
    List<String> ids;
    try {
      final sp = await SharedPreferences.getInstance();
      ids = sp.getStringList(_armedKey) ?? const [];
    } catch (_) {
      return;
    }
    for (final id in ids) {
      for (var i = 0; i < _ladder.length; i++) {
        await NotificationService.instance.cancel(notificationId(id, i));
      }
    }
    await _forget(ids.toSet());
  }

  /// Re-arm everything for this doctor's upcoming consultations. Safe to call
  /// on every app open: ids are derived, so repeats overwrite.
  Future<void> syncAll(List<Booking> upcoming) async {
    for (final b in upcoming) {
      await scheduleFor(b);
    }
    if (kDebugMode) {
      debugPrint('[doctor] reminders armed for ${upcoming.length} consults');
    }
  }
}
