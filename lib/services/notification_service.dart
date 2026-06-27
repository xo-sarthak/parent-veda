// =============================================================================
//  NotificationService — schedules the mother's reminders as OS notifications
// -----------------------------------------------------------------------------
//  Thin wrapper over flutter_local_notifications + timezone. ReminderStore calls
//  schedule / cancel / syncAll as reminders change. Everything is wrapped in
//  try/catch so a missing platform permission never crashes the app — it just
//  means the nudge won't fire until permission is granted.
// =============================================================================

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    // Timezone setup — required so a "9:00 AM" reminder means 9 AM locally.
    try {
      tzdata.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {/* leave default */}
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    try {
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      _ready = true;
    } catch (_) {/* platform not ready — schedule() will simply no-op */}
  }

  /// Ask the OS for permission to post notifications (Android 13+ / iOS).
  Future<bool> requestPermission() async {
    try {
      final android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return (await android.requestNotificationsPermission()) ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return (await ios.requestPermissions(
                alert: true, badge: true, sound: true)) ??
            true;
      }
    } catch (_) {/* ignore */}
    return true;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Reminders',
          channelDescription: 'Your personal ParentVeda reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  tz.TZDateTime _nextTime(int hour, int minute, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    var d = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (weekday != null) {
      while (d.weekday != weekday || !d.isAfter(now)) {
        d = d.add(const Duration(days: 1));
      }
    } else if (!d.isAfter(now)) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  // Next time [dayOfMonth] (clamped to the month length) falls at hh:mm.
  tz.TZDateTime _nextMonthly(int dayOfMonth, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime make(int year, int month) {
      final lastDay = DateTime(year, month + 1, 0).day; // 0th of next month
      final day = dayOfMonth.clamp(1, lastDay);
      return tz.TZDateTime(tz.local, year, month, day, hour, minute);
    }

    var dt = make(now.year, now.month);
    if (!dt.isAfter(now)) {
      var y = now.year, m = now.month + 1;
      if (m > 12) {
        m = 1;
        y += 1;
      }
      dt = make(y, m);
    }
    return dt;
  }

  // Per-occurrence OS id: occurrence 0 keeps the base id (back-compat); the rest
  // derive a stable id from "<reminderId>#<index>".
  int _occId(Reminder r, int index) =>
      index == 0 ? r.notificationId : ('${r.id}#$index').hashCode & 0x7fffffff;

  // The individual firing instances of a reminder (one reminder can fire at
  // several times of day, or on several weekdays).
  List<_Occ> _occurrences(Reminder r) {
    switch (r.repeat) {
      case ReminderRepeat.once:
        return [_Occ(0, r.hour, r.minute)];
      case ReminderRepeat.daily:
        final ts = r.effectiveTimes;
        return [
          for (var i = 0; i < ts.length; i++)
            _Occ(i, ts[i] ~/ 60, ts[i] % 60, match: DateTimeComponents.time),
        ];
      case ReminderRepeat.weekly:
        return [
          _Occ(0, r.hour, r.minute,
              weekday: r.weekday, match: DateTimeComponents.dayOfWeekAndTime),
        ];
      case ReminderRepeat.fortnightly:
        // No native 14-day match → schedule the next weekday occurrence as a
        // ONE-SHOT; syncAll (every launch) re-arms it so it behaves ~fortnightly.
        // Exact 14-day spacing would need a stored anchor (future).
        return [_Occ(0, r.hour, r.minute, weekday: r.weekday)];
      case ReminderRepeat.monthly:
        return [
          _Occ(0, r.hour, r.minute,
              dayOfMonth: r.dayOfMonth,
              match: DateTimeComponents.dayOfMonthAndTime),
        ];
      case ReminderRepeat.customDays:
        final wds = r.effectiveWeekdays;
        return [
          for (var i = 0; i < wds.length; i++)
            _Occ(i, r.hour, r.minute,
                weekday: wds[i], match: DateTimeComponents.dayOfWeekAndTime),
        ];
    }
  }

  Future<void> schedule(Reminder r) async {
    if (!_ready || !r.enabled) return;
    await cancelReminder(r);
    try {
      for (final o in _occurrences(r)) {
        final when = o.dayOfMonth != null
            ? _nextMonthly(o.dayOfMonth!, o.hour, o.minute)
            : _nextTime(o.hour, o.minute, weekday: o.weekday);
        await _plugin.zonedSchedule(
          _occId(r, o.index),
          r.title,
          r.body.isEmpty ? null : r.body,
          when,
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: o.match,
        );
      }
    } catch (_) {/* best-effort */}
  }

  /// Cancel every occurrence of a reminder (covers multi-time reminders).
  Future<void> cancelReminder(Reminder r) async {
    for (var i = 0; i < 8; i++) {
      await cancel(_occId(r, i));
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (_) {/* ignore */}
  }

  /// Re-sync every reminder (called on startup and after bulk changes).
  Future<void> syncAll(List<Reminder> reminders) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {/* ignore */}
    for (final r in reminders) {
      if (r.enabled) await schedule(r);
    }
  }
}

/// One firing instance of a reminder (a time-of-day, optionally on a weekday or
/// day-of-month, with the matching recurrence component).
class _Occ {
  const _Occ(this.index, this.hour, this.minute,
      {this.weekday, this.dayOfMonth, this.match});
  final int index;
  final int hour;
  final int minute;
  final int? weekday;
  final int? dayOfMonth;
  final DateTimeComponents? match;
}
