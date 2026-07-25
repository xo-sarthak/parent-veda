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
//  notification and cancelling is possible without keeping a side table.
// =============================================================================

import 'package:flutter/foundation.dart';

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
