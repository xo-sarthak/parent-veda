// =============================================================================
//  Medication + MedicationLog - "Daily Medication & Supplement Tracking"
// -----------------------------------------------------------------------------
//  A pregnancy nourishment companion, not a pillbox. A Medication is something
//  the doctor recommended (supplement / medicine / custom); a MedicationLog
//  records that it was taken on a given day. Tracking only - never advice.
// =============================================================================

import 'package:flutter/foundation.dart';

enum MedType { supplement, medication, custom }

/// How a medication alarm repeats.
///  - daily  : fires every day at each configured time
///  - weekly : fires on the chosen weekdays (a weekly cadence)
///  - custom : fires only on specifically-picked weekdays
/// (weekly & custom share the same weekday storage; the distinction is just the
///  UI intent, so both are honoured identically when scheduling.)
enum MedAlarmRepeat { daily, weekly, custom }

/// A phone-alarm-like reminder attached to a [Medication]. A single medication
/// can carry several alarms; each alarm can itself fire at several times of day.
/// Times are stored as "minutes since midnight" (e.g. 540 == 09:00). Weekdays
/// use Dart's convention: 1 = Monday … 7 = Sunday.
@immutable
class MedAlarm {
  const MedAlarm({
    required this.id,
    this.title = '',
    this.times = const [],
    this.repeat = MedAlarmRepeat.daily,
    this.weekdays = const [],
    this.startDateIso,
    this.endDateIso,
    this.enabled = true,
  });

  final String id;

  /// Custom alarm title. Empty means "use the medication name" at display time.
  final String title;

  /// Times of day, minutes-since-midnight. Multiple entries = multiple alarms
  /// per day for this one config.
  final List<int> times;

  final MedAlarmRepeat repeat;

  /// Selected weekdays (1=Mon..7=Sun) - used for weekly & custom.
  final List<int> weekdays;

  /// Optional ISO start date; alarms don't fire before this day.
  final String? startDateIso;

  /// Optional ISO end date; alarms don't fire after this day.
  final String? endDateIso;

  final bool enabled;

  MedAlarm copyWith({
    String? title,
    List<int>? times,
    MedAlarmRepeat? repeat,
    List<int>? weekdays,
    String? startDateIso,
    String? endDateIso,
    bool? enabled,
    bool clearStart = false,
    bool clearEnd = false,
  }) =>
      MedAlarm(
        id: id,
        title: title ?? this.title,
        times: times ?? this.times,
        repeat: repeat ?? this.repeat,
        weekdays: weekdays ?? this.weekdays,
        startDateIso: clearStart ? null : (startDateIso ?? this.startDateIso),
        endDateIso: clearEnd ? null : (endDateIso ?? this.endDateIso),
        enabled: enabled ?? this.enabled,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'times': times,
        'repeat': repeat.name,
        'weekdays': weekdays,
        'startDateIso': startDateIso,
        'endDateIso': endDateIso,
        'enabled': enabled,
      };

  factory MedAlarm.fromJson(Map<String, dynamic> j) {
    var r = MedAlarmRepeat.daily;
    for (final e in MedAlarmRepeat.values) {
      if (e.name == j['repeat']) {
        r = e;
        break;
      }
    }
    List<int> ints(dynamic v) => v is List
        ? v.map((e) => (e is num) ? e.toInt() : int.tryParse('$e') ?? 0).toList()
        : <int>[];
    return MedAlarm(
      id: (j['id'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      times: ints(j['times']),
      repeat: r,
      weekdays: ints(j['weekdays']),
      startDateIso: j['startDateIso']?.toString(),
      endDateIso: j['endDateIso']?.toString(),
      enabled: j['enabled'] != false,
    );
  }
}

/// Common pregnancy supplements offered at setup (educational text lives in S).
const List<String> kMedPresetKeys = [
  'iron',
  'calcium',
  'folicAcid',
  'vitaminD',
  'dha',
  'multivitamin',
];

@immutable
class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.type,
    this.dose = '',
    this.time = '',
    this.frequency = '',
    this.notes = '',
    this.presetKey,
    required this.startDateIso,
    this.endDateIso,
    this.isActive = true,
    this.alarms = const [],
  });

  final String id;
  final String name;
  final MedType type;
  final String dose;
  final String time;
  final String frequency;
  final String notes;

  /// For preset supplements (iron/calcium/…) - drives the educational blurb.
  final String? presetKey;
  final String startDateIso;
  final String? endDateIso;
  final bool isActive;

  /// Configured phone-alarm-like reminders for this medication (additive; older
  /// records that predate alarms simply decode to an empty list).
  final List<MedAlarm> alarms;

  Medication copyWith({
    String? name,
    String? dose,
    String? time,
    String? frequency,
    String? notes,
    bool? isActive,
    String? endDateIso,
    List<MedAlarm>? alarms,
  }) =>
      Medication(
        id: id,
        name: name ?? this.name,
        type: type,
        dose: dose ?? this.dose,
        time: time ?? this.time,
        frequency: frequency ?? this.frequency,
        notes: notes ?? this.notes,
        presetKey: presetKey,
        startDateIso: startDateIso,
        endDateIso: endDateIso ?? this.endDateIso,
        isActive: isActive ?? this.isActive,
        alarms: alarms ?? this.alarms,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'dose': dose,
        'time': time,
        'frequency': frequency,
        'notes': notes,
        'presetKey': presetKey,
        'startDateIso': startDateIso,
        'endDateIso': endDateIso,
        'isActive': isActive,
        'alarms': alarms.map((a) => a.toJson()).toList(),
      };

  factory Medication.fromJson(Map<String, dynamic> j) {
    var t = MedType.supplement;
    for (final e in MedType.values) {
      if (e.name == j['type']) {
        t = e;
        break;
      }
    }
    return Medication(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      type: t,
      dose: (j['dose'] ?? '').toString(),
      time: (j['time'] ?? '').toString(),
      frequency: (j['frequency'] ?? '').toString(),
      notes: (j['notes'] ?? '').toString(),
      presetKey: j['presetKey']?.toString(),
      startDateIso: (j['startDateIso'] ?? '').toString(),
      endDateIso: j['endDateIso']?.toString(),
      isActive: j['isActive'] != false,
      alarms: (j['alarms'] is List)
          ? (j['alarms'] as List)
              .map((e) => MedAlarm.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

@immutable
class MedicationLog {
  const MedicationLog({
    required this.id,
    required this.medicationId,
    required this.dateKey,
    required this.takenAtIso,
  });

  final String id;
  final String medicationId;
  final String dateKey; // yyyy-MM-dd
  final String takenAtIso;

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicationId': medicationId,
        'dateKey': dateKey,
        'takenAtIso': takenAtIso,
      };

  factory MedicationLog.fromJson(Map<String, dynamic> j) => MedicationLog(
        id: (j['id'] ?? '').toString(),
        medicationId: (j['medicationId'] ?? '').toString(),
        dateKey: (j['dateKey'] ?? '').toString(),
        takenAtIso: (j['takenAtIso'] ?? '').toString(),
      );
}
