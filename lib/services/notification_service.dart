// =============================================================================
//  NotificationService - schedules the mother's reminders as OS notifications
// -----------------------------------------------------------------------------
//  Thin wrapper over flutter_local_notifications + timezone. ReminderStore calls
//  schedule / cancel / syncAll as reminders change. Everything is wrapped in
//  try/catch so a missing platform permission never crashes the app - it just
//  means the nudge won't fire until permission is granted.
// =============================================================================

import 'package:flutter/foundation.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/medication.dart';
import '../models/reminder.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    // Timezone setup - required so a "9:00 AM" reminder means 9 AM locally.
    try {
      tzdata.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {/* leave default */}
    }
    debugPrint('[reminders] tz.local = ${tz.local.name}');
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
    } catch (_) {/* platform not ready - schedule() will simply no-op */}
  }

  /// Ask the OS for permission to post notifications (Android 13+ / iOS).
  Future<bool> requestPermission() async {
    try {
      final android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted =
            (await android.requestNotificationsPermission()) ?? true;
        // Android 12+: also need permission to schedule EXACT alarms, otherwise
        // the OS batches/delays them (Doze) and a reminder can miss its time.
        try {
          await android.requestExactAlarmsPermission();
        } catch (_) {/* older Android - not needed */}
        return granted;
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

  /// Fire a notification immediately - a quick way to confirm notifications
  /// work at all on this device, independent of scheduling/timing.
  Future<void> showNow({
    String title = 'ParentVeda',
    String body = "Test notification - you're all set ✅",
  }) async {
    if (!_ready) await init();
    try {
      await _plugin.show(999001, title, body, _details);
    } catch (_) {/* best-effort */}
  }

  /// Diagnostic: schedule a real EXACT notification ~1 minute out, through the
  /// same path reminders use, logging where it lands (or the error).
  Future<void> scheduleTestIn1Min() async {
    if (!_ready) await init();
    final when = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
    try {
      await _plugin.zonedSchedule(
        999002,
        'Scheduled test',
        'Fired ~1 min after you tapped - scheduling works ✅',
        when,
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('[reminders] TEST scheduled for $when '
          '(now=${tz.TZDateTime.now(tz.local)}, tz=${tz.local.name})');
    } catch (e) {
      debugPrint('[reminders] TEST schedule FAILED: $e');
    }
  }

  /// Schedule a ONE-OFF notification at an absolute date/time - used for
  /// vaccine-due reminders (e.g. "1 day before"). Best-effort: no-ops if the
  /// platform isn't ready or the time is in the past.
  Future<void> scheduleOneOff({
    required int id,
    required String title,
    String? body,
    required DateTime when,
  }) async {
    if (!_ready) await init();
    if (!_ready) return;
    try {
      final tzWhen = tz.TZDateTime.from(when, tz.local);
      if (!tzWhen.isAfter(tz.TZDateTime.now(tz.local))) return;
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzWhen,
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {/* best-effort */}
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

  // ===========================================================================
  //  Medication & Supplement alarms (Section 13)
  // ---------------------------------------------------------------------------
  //  Each Medication carries a list of MedAlarm configs; each alarm can fire at
  //  several times of day, on several weekdays, within an optional start/end
  //  window. We materialise concrete dated occurrences over a rolling horizon
  //  (so both start AND end dates are honoured exactly) and schedule them as
  //  one-shots. Reschedule on every add/edit and on store init re-arms the
  //  horizon. IDs are derived deterministically per (medication, index) so we
  //  can cancel a medication's alarms without touching reminder notifications.
  // ===========================================================================

  // A louder, alarm-flavoured channel distinct from gentle reminders.
  NotificationDetails get _medDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_alarms',
          'Medication & Supplement Alarms',
          channelDescription:
              'Reminders to take your medications and supplements',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(),
      );

  // How many occurrences we pre-schedule per medication (also the cancel span).
  // 64 keeps us within iOS' 64 pending-notification budget per feature.
  static const int _medMaxOcc = 64;

  // Rolling horizon (days) over which we materialise recurring alarms.
  static const int _medHorizonDays = 60;

  int _medOccId(String medId, int index) =>
      ('medalarm_$medId#$index').hashCode & 0x7fffffff;

  DateTime? _dayOf(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final d = DateTime.tryParse(iso);
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  /// Cancel + (re)schedule every alarm on [m]. Disabled alarms are skipped.
  Future<void> scheduleMedicationAlarms(Medication m) async {
    if (!_ready) await init();
    if (!_ready) return;
    await cancelMedicationAlarms(m.id);

    final now = tz.TZDateTime.now(tz.local);
    final today = DateTime(now.year, now.month, now.day);
    var index = 0;

    for (final a in m.alarms) {
      if (!a.enabled || a.times.isEmpty) continue;
      final start = _dayOf(a.startDateIso);
      final end = _dayOf(a.endDateIso);
      final title = a.title.trim().isNotEmpty ? a.title.trim() : m.name;
      final body = m.dose.trim().isNotEmpty
          ? "It's time for your ${m.name} (${m.dose})"
          : "It's time for your ${m.name}";

      for (int d = 0; d <= _medHorizonDays && index < _medMaxOcc; d++) {
        final day = today.add(Duration(days: d));
        if (start != null && day.isBefore(start)) continue;
        if (end != null && day.isAfter(end)) break;
        // Daily fires every day; weekly/custom only on the selected weekdays.
        if (a.repeat != MedAlarmRepeat.daily &&
            !a.weekdays.contains(day.weekday)) {
          continue;
        }
        final sortedTimes = a.times.toList()..sort();
        for (final mins in sortedTimes) {
          if (index >= _medMaxOcc) break;
          final when = tz.TZDateTime(
              tz.local, day.year, day.month, day.day, mins ~/ 60, mins % 60);
          if (!when.isAfter(now)) continue;
          try {
            await _plugin.zonedSchedule(
              _medOccId(m.id, index),
              title,
              body,
              when,
              _medDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          } catch (_) {/* best-effort */}
          index++;
        }
      }
    }
    debugPrint('[medalarms] scheduled $index occurrence(s) for "${m.name}"');
  }

  /// Cancel all pending alarm occurrences for a medication id.
  Future<void> cancelMedicationAlarms(String medId) async {
    for (var i = 0; i < _medMaxOcc; i++) {
      await cancel(_medOccId(medId, i));
    }
  }

  /// Re-arm alarms for a batch of medications (call on store init).
  Future<void> syncMedicationAlarms(List<Medication> meds) async {
    if (!_ready) await init();
    if (!_ready) return;
    for (final m in meds) {
      await scheduleMedicationAlarms(m);
    }
  }

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
    if (!_ready || !r.enabled) {
      debugPrint('[reminders] schedule skipped (ready=$_ready enabled=${r.enabled})');
      return;
    }
    await cancelReminder(r);
    for (final o in _occurrences(r)) {
      final when = o.dayOfMonth != null
          ? _nextMonthly(o.dayOfMonth!, o.hour, o.minute)
          : _nextTime(o.hour, o.minute, weekday: o.weekday);
      try {
        await _plugin.zonedSchedule(
          _occId(r, o.index),
          r.title,
          r.body.isEmpty ? null : r.body,
          when,
          _details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: o.match,
        );
        debugPrint('[reminders] scheduled "${r.title}" #${o.index} for $when '
            '(now=${tz.TZDateTime.now(tz.local)}, tz=${tz.local.name})');
      } catch (e) {
        debugPrint('[reminders] FAILED "${r.title}" #${o.index}: $e');
      }
    }
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
