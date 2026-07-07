// =============================================================================
//  Reminder - a customizable local reminder/notification
// -----------------------------------------------------------------------------
//  The mother can ask the app to nudge her at a chosen time - for a Kegel
//  session, a prenatal vitamin, reading to her baby, a hospital-bag task, water,
//  or anything custom. Pure data; the actual OS notification scheduling lives in
//  NotificationService (wired once flutter_local_notifications is installed).
//
//  A single reminder can fire at MULTIPLE times of day ([times], for twice/thrice
//  daily) and supports richer cadences (fortnightly / monthly / specific
//  weekdays) - used by the medication-reminders feature on the Daily Medication
//  card, which is deliberately NOT tied to any specific medicine.
// =============================================================================

import 'package:flutter/foundation.dart';

/// How often a reminder repeats.
enum ReminderRepeat { once, daily, weekly, fortnightly, monthly, customDays }

@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    this.body = '',
    required this.hour,
    required this.minute,
    this.repeat = ReminderRepeat.daily,
    this.weekday = DateTime.monday,
    this.enabled = true,
    this.category = 'custom',
    this.times = const [],
    this.dayOfMonth = 1,
    this.weekdays = const [],
  });

  final String id;
  final String title;
  final String body;
  final int hour; // 0–23 (the first/primary time)
  final int minute; // 0–59
  final ReminderRepeat repeat;
  final int weekday; // 1=Mon … 7=Sun (weekly / fortnightly)
  final bool enabled;

  /// Which feature this nudges: kegel | medication | reads | bag | water | custom.
  final String category;

  /// Extra times-of-day (minutes since midnight) for a multi-time DAILY reminder
  /// (twice/thrice a day). Empty → just the single [hour]:[minute] is used.
  final List<int> times;

  /// Day of month (1–28) - only used when repeat == monthly.
  final int dayOfMonth;

  /// Specific weekdays (1=Mon … 7=Sun) - only used when repeat == customDays.
  final List<int> weekdays;

  /// Every time-of-day this reminder fires (minutes since midnight).
  List<int> get effectiveTimes =>
      times.isNotEmpty ? List.unmodifiable(times) : [hour * 60 + minute];

  /// Every weekday for a customDays reminder.
  List<int> get effectiveWeekdays =>
      weekdays.isNotEmpty ? List.unmodifiable(weekdays) : [weekday];

  bool get isMedication => category == 'medication';

  /// A stable, positive 31-bit base id for the OS notification (derived from
  /// [id]). Multi-time reminders derive per-occurrence ids from this.
  int get notificationId => id.hashCode & 0x7fffffff;

  Reminder copyWith({
    String? title,
    String? body,
    int? hour,
    int? minute,
    ReminderRepeat? repeat,
    int? weekday,
    bool? enabled,
    String? category,
    List<int>? times,
    int? dayOfMonth,
    List<int>? weekdays,
  }) =>
      Reminder(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        repeat: repeat ?? this.repeat,
        weekday: weekday ?? this.weekday,
        enabled: enabled ?? this.enabled,
        category: category ?? this.category,
        times: times ?? this.times,
        dayOfMonth: dayOfMonth ?? this.dayOfMonth,
        weekdays: weekdays ?? this.weekdays,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'hour': hour,
        'minute': minute,
        'repeat': repeat.name,
        'weekday': weekday,
        'enabled': enabled,
        'category': category,
        'times': times,
        'dayOfMonth': dayOfMonth,
        'weekdays': weekdays,
      };

  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        hour: (j['hour'] as num?)?.toInt() ?? 9,
        minute: (j['minute'] as num?)?.toInt() ?? 0,
        repeat: ReminderRepeat.values.firstWhere(
            (r) => r.name == j['repeat'],
            orElse: () => ReminderRepeat.daily),
        weekday: (j['weekday'] as num?)?.toInt() ?? DateTime.monday,
        enabled: j['enabled'] as bool? ?? true,
        category: j['category'] as String? ?? 'custom',
        times: ((j['times'] as List?) ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
        dayOfMonth: (j['dayOfMonth'] as num?)?.toInt() ?? 1,
        weekdays: ((j['weekdays'] as List?) ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
      );
}
