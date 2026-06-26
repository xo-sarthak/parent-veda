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

  Future<void> schedule(Reminder r) async {
    if (!_ready || !r.enabled) return;
    await cancel(r.notificationId);
    try {
      final when = _nextTime(r.hour, r.minute,
          weekday: r.repeat == ReminderRepeat.weekly ? r.weekday : null);
      final DateTimeComponents? match = switch (r.repeat) {
        ReminderRepeat.once => null,
        ReminderRepeat.daily => DateTimeComponents.time,
        ReminderRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
      };
      await _plugin.zonedSchedule(
        r.notificationId,
        r.title,
        r.body.isEmpty ? null : r.body,
        when,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: match,
      );
    } catch (_) {/* best-effort */}
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
