// =============================================================================
//  Reminder — a customizable local reminder/notification
// -----------------------------------------------------------------------------
//  The mother can ask the app to nudge her at a chosen time — for a Kegel
//  session, a prenatal vitamin, reading to her baby, a hospital-bag task, water,
//  or anything custom. Pure data; the actual OS notification scheduling lives in
//  NotificationService (wired once flutter_local_notifications is installed).
// =============================================================================

import 'package:flutter/foundation.dart';

/// How often a reminder repeats.
enum ReminderRepeat { once, daily, weekly }

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
  });

  final String id;
  final String title;
  final String body;
  final int hour; // 0–23
  final int minute; // 0–59
  final ReminderRepeat repeat;
  final int weekday; // 1=Mon … 7=Sun (only used when repeat == weekly)
  final bool enabled;

  /// Which feature this nudges: kegel | medication | reads | bag | water | custom.
  final String category;

  /// A stable, positive 31-bit id for the OS notification (derived from [id]).
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
      );
}
