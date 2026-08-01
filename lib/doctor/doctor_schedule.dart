// =============================================================================
//  DoctorSchedule — what a doctor is actually available for, and the engine
//  that turns that into bookable slots
// -----------------------------------------------------------------------------
//  Replaces AvailWindow (doctor_availability.dart), which stored a set of
//  discrete tap points against a HARDCODED list of six times: 9, 11, 2, 5, 6:30,
//  8. A doctor who works 10:30-13:00 and 17:00-20:30 - the ordinary Indian
//  clinic pattern - could not express their own working day at all.
//
//  The shape here follows how practice software actually models this:
//
//      working hours  ->  sessions  ->  duration  ->  exceptions
//
//  A weekly pattern of SESSIONS (morning clinic, evening clinic), a set of
//  RULES (how long a consult is, what gaps to leave, how many a day, how much
//  notice), and EXCEPTIONS (a holiday, a one-off closed afternoon). Slots are
//  then DERIVED, never stored by hand - which is what makes the parent's list
//  and the doctor's intent the same thing by construction.
//
//  Time zone: everything is local wall-clock (IST for now, by decision). The
//  types keep a single conversion point so a real tz can be threaded later.
//
//  This file is pure Dart on purpose - no Flutter, no storage, no network - so
//  the slot maths can be tested exhaustively. That matters: this is where
//  double-bookings and off-by-one errors live.
// =============================================================================

import 'package:flutter/foundation.dart';

/// Minutes from midnight, local. 0 = 00:00, 570 = 09:30.
typedef Minutes = int;

String hhmm(Minutes m) {
  final h = (m ~/ 60) % 24;
  final mm = m % 60;
  final ampm = h < 12 ? 'AM' : 'PM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${mm.toString().padLeft(2, '0')} $ampm';
}

/// A continuous stretch of a working day, e.g. 10:00-13:00.
///
/// OVERNIGHT SESSIONS. [end] may run PAST 1440 — 11:00 PM to 1:00 AM is
/// `Session(1380, 1500)`, not `Session(1380, 60)`. The second form is the one
/// that reads as "ends before it starts", and refusing it was a real bug: a
/// doctor who consults late could not describe their own hours.
///
/// Minutes-past-midnight-of-the-START-day is the fix, and it is worth saying
/// why it beats the alternatives. A wrap-around flag (`crossesMidnight: true`)
/// puts a special case into every comparison — `overlaps`, sorting, the slot
/// loop — and each one is a chance to forget it. A pair of DateTimes drags a
/// calendar date into a WEEKLY pattern that deliberately has none. Letting the
/// number keep counting past midnight leaves the arithmetic linear, so
/// `end > start`, `end - start` and `overlaps` all keep working unchanged.
///
/// [hhmm] already wraps the hour with `% 24`, so 1500 has always printed as
/// "1:00 AM" — the display half was correct before the model allowed it.
///
/// A session may not exceed 24 hours, so [end] is bounded at `start + 1440`.
/// That is the difference between "a late clinic" and a typo.
@immutable
class Session {
  const Session(this.start, this.end);
  final Minutes start;
  final Minutes end;

  /// True when this session runs into the following calendar day.
  bool get crossesMidnight => end > 1440;

  /// How far into the NEXT day it reaches, in minutes. 0 when it does not.
  /// Used to check a late session against the next morning's first one.
  Minutes get spillMin => crossesMidnight ? end - 1440 : 0;

  bool get isValid =>
      start >= 0 && start < 1440 && end > start && (end - start) <= 1440;
  int get lengthMin => end - start;

  /// Same-day overlap only. Two sessions on DIFFERENT days can still collide in
  /// real time when the earlier one crosses midnight — see [spillsInto], which
  /// is the check that catches it.
  bool overlaps(Session o) => start < o.end && o.start < end;

  Map<String, Object?> toMap() => {'start': start, 'end': end};
  static Session fromMap(Map d) =>
      Session((d['start'] as num).toInt(), (d['end'] as num).toInt());

  @override
  String toString() =>
      '${hhmm(start)}-${hhmm(end)}${crossesMidnight ? ' (next day)' : ''}';

  @override
  bool operator ==(Object other) =>
      other is Session && other.start == start && other.end == end;
  @override
  int get hashCode => Object.hash(start, end);
}

/// One weekday. `sessions` empty == not working that day.
@immutable
class DaySchedule {
  const DaySchedule(this.sessions);
  const DaySchedule.off() : sessions = const [];

  final List<Session> sessions;
  bool get isWorking => sessions.isNotEmpty;
  int get totalMin => sessions.fold(0, (a, s) => a + s.lengthMin);

  /// How far past midnight this day reaches, in minutes. 0 for an ordinary
  /// day. The slot engine needs it to know how wide "one working day" is when
  /// counting a daily cap.
  Minutes get spillMin =>
      sessions.fold(0, (a, s) => s.spillMin > a ? s.spillMin : a);

  Map<String, Object?> toMap() =>
      {'sessions': sessions.map((s) => s.toMap()).toList()};
  static DaySchedule fromMap(Map d) => DaySchedule(
      ((d['sessions'] as List?) ?? const [])
          .map((e) => Session.fromMap(e as Map))
          .toList());
}

/// Does a session that runs past midnight collide with the FOLLOWING day's
/// work? A Monday 11 PM - 2 AM session and a Tuesday 1 AM start are the same
/// hour of the same night, and [Session.overlaps] cannot see it because it
/// compares two numbers on one day's axis.
///
/// Kept as a free function rather than a method because it is a fact about a
/// PAIR of days, and putting it on either one would imply the other is the
/// special case.
bool spillsInto(Session s, DaySchedule nextDay) {
  if (!s.crossesMidnight) return false;
  return nextDay.sessions.any((n) => n.start < s.spillMin);
}

/// The sessions actually in force on [day]: a date override if one exists,
/// otherwise the weekly pattern, and nothing at all on a closed day or during
/// time off. One place, because the slot loop now needs to ask this about the
/// PREVIOUS day too — and two copies of "what is this doctor doing on date X"
/// is how a holiday ends up honoured in one calculation and ignored in the next.
List<Session> _sessionsFor(DoctorSchedule schedule, DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  if (schedule.timeOff.any((t) => t.covers(d))) return const [];
  final ov = schedule.overrides[DateOverride.keyFor(d)];
  if (ov != null && ov.closed) return const [];
  return ov?.sessions ?? schedule.dayFor(d.weekday).sessions;
}

/// How consultations are spaced. All doctor-editable.
@immutable
class ConsultRules {
  const ConsultRules({
    this.slotMinutes = 30,
    this.bufferBeforeMin = 0,
    this.bufferAfterMin = 5,
    this.maxPerDay = 8,
    this.maxConsecutive = 4,
    this.minNoticeMinutes = 120,
    this.advanceWindowDays = 30,
    this.autoConfirm = true,
  });

  /// How long one consultation runs. Doctor's choice (15/20/30/45).
  final int slotMinutes;

  /// Protected gap immediately BEFORE a consultation (prep, notes from the
  /// last one running over).
  final int bufferBeforeMin;

  /// Protected gap immediately AFTER (writing the prescription).
  final int bufferAfterMin;

  /// Hard cap on bookings in one day, however much free time is left.
  final int maxPerDay;

  /// Longest run of BACK-TO-BACK consultations before a gap is forced.
  final int maxConsecutive;

  /// A parent cannot book something starting sooner than this.
  final int minNoticeMinutes;

  /// How far ahead the calendar opens.
  final int advanceWindowDays;

  /// True: a booking is confirmed the moment it is paid for - the doctor
  /// already said they were free, so a second yes is a second yes to a question
  /// they answered. False (not used yet) would make bookings a request the
  /// doctor accepts. Kept on the model so switching it later is data, not a
  /// rewrite.
  final bool autoConfirm;

  /// The clock advance per slot: the consultation plus the gaps that protect it.
  int get strideMin => bufferBeforeMin + slotMinutes + bufferAfterMin;

  ConsultRules copyWith({
    int? slotMinutes,
    int? bufferBeforeMin,
    int? bufferAfterMin,
    int? maxPerDay,
    int? maxConsecutive,
    int? minNoticeMinutes,
    int? advanceWindowDays,
    bool? autoConfirm,
  }) =>
      ConsultRules(
        slotMinutes: slotMinutes ?? this.slotMinutes,
        bufferBeforeMin: bufferBeforeMin ?? this.bufferBeforeMin,
        bufferAfterMin: bufferAfterMin ?? this.bufferAfterMin,
        maxPerDay: maxPerDay ?? this.maxPerDay,
        maxConsecutive: maxConsecutive ?? this.maxConsecutive,
        minNoticeMinutes: minNoticeMinutes ?? this.minNoticeMinutes,
        advanceWindowDays: advanceWindowDays ?? this.advanceWindowDays,
        autoConfirm: autoConfirm ?? this.autoConfirm,
      );

  Map<String, Object?> toMap() => {
        'slotMinutes': slotMinutes,
        'bufferBeforeMin': bufferBeforeMin,
        'bufferAfterMin': bufferAfterMin,
        'maxPerDay': maxPerDay,
        'maxConsecutive': maxConsecutive,
        'minNoticeMinutes': minNoticeMinutes,
        'advanceWindowDays': advanceWindowDays,
        'autoConfirm': autoConfirm,
      };

  static ConsultRules fromMap(Map d) => ConsultRules(
        slotMinutes: (d['slotMinutes'] as num?)?.toInt() ?? 30,
        bufferBeforeMin: (d['bufferBeforeMin'] as num?)?.toInt() ?? 0,
        bufferAfterMin: (d['bufferAfterMin'] as num?)?.toInt() ?? 5,
        maxPerDay: (d['maxPerDay'] as num?)?.toInt() ?? 8,
        maxConsecutive: (d['maxConsecutive'] as num?)?.toInt() ?? 4,
        minNoticeMinutes: (d['minNoticeMinutes'] as num?)?.toInt() ?? 120,
        advanceWindowDays: (d['advanceWindowDays'] as num?)?.toInt() ?? 30,
        autoConfirm: d['autoConfirm'] as bool? ?? true,
      );
}

/// A stretch of days the doctor is away. Vacation, a public holiday, or an
/// emergency closure - the same shape, different label.
@immutable
class TimeOff {
  const TimeOff({required this.fromDate, required this.toDate, this.reason = ''});

  /// Inclusive, date-only (time is ignored).
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;

  bool covers(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final a = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final b = DateTime(toDate.year, toDate.month, toDate.day);
    return !d.isBefore(a) && !d.isAfter(b);
  }

  Map<String, Object?> toMap() => {
        'from': fromDate.toIso8601String(),
        'to': toDate.toIso8601String(),
        'reason': reason,
      };
  static TimeOff fromMap(Map d) => TimeOff(
        fromDate: DateTime.parse(d['from'].toString()),
        toDate: DateTime.parse(d['to'].toString()),
        reason: (d['reason'] ?? '').toString(),
      );
}

/// One date behaving differently from its weekday: closed, or different hours.
@immutable
class DateOverride {
  const DateOverride({required this.date, this.closed = false, this.sessions});
  final DateTime date;
  final bool closed;

  /// Replacement sessions for this date. Null + !closed is meaningless.
  final List<Session>? sessions;

  static String keyFor(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String get key => keyFor(date);

  Map<String, Object?> toMap() => {
        'date': date.toIso8601String(),
        'closed': closed,
        if (sessions != null)
          'sessions': sessions!.map((s) => s.toMap()).toList(),
      };
  static DateOverride fromMap(Map d) => DateOverride(
        date: DateTime.parse(d['date'].toString()),
        closed: d['closed'] as bool? ?? false,
        sessions: (d['sessions'] as List?)
            ?.map((e) => Session.fromMap(e as Map))
            .toList(),
      );
}

/// A doctor's whole availability: the weekly pattern, the rules, the exceptions.
///
/// ONE schedule serves BOTH stages (pregnancy + parenting). A doctor's free
/// hours are a fact about their day, not about which of our apps a parent came
/// from - and two schedules would be two things to keep in sync, which is two
/// things to get wrong.
@immutable
class DoctorSchedule {
  const DoctorSchedule({
    required this.byWeekday,
    this.rules = const ConsultRules(),
    this.timeOff = const [],
    this.overrides = const {},
    this.paused = false,
  });

  /// DateTime.monday(1) .. DateTime.sunday(7).
  final Map<int, DaySchedule> byWeekday;
  final ConsultRules rules;
  final List<TimeOff> timeOff;

  /// Keyed by DateOverride.keyFor(date).
  final Map<String, DateOverride> overrides;

  /// The big red switch: take no new bookings at all, without losing the
  /// schedule. Existing appointments are untouched.
  final bool paused;

  DaySchedule dayFor(int weekday) =>
      byWeekday[weekday] ?? const DaySchedule.off();

  bool get hasAnyHours => byWeekday.values.any((d) => d.isWorking);
  int get workingDays => byWeekday.values.where((d) => d.isWorking).length;

  /// A sensible starting point for a doctor who has set nothing: the two-session
  /// clinic day, Mon-Sat, which is the pattern most Indian practices run.
  static DoctorSchedule get starter => DoctorSchedule(
        byWeekday: {
          for (var d = DateTime.monday; d <= DateTime.saturday; d++)
            d: const DaySchedule([Session(10 * 60, 13 * 60), Session(17 * 60, 20 * 60)]),
          DateTime.sunday: const DaySchedule.off(),
        },
      );

  DoctorSchedule copyWith({
    Map<int, DaySchedule>? byWeekday,
    ConsultRules? rules,
    List<TimeOff>? timeOff,
    Map<String, DateOverride>? overrides,
    bool? paused,
  }) =>
      DoctorSchedule(
        byWeekday: byWeekday ?? this.byWeekday,
        rules: rules ?? this.rules,
        timeOff: timeOff ?? this.timeOff,
        overrides: overrides ?? this.overrides,
        paused: paused ?? this.paused,
      );

  Map<String, Object?> toMap() => {
        'byWeekday': byWeekday.map((k, v) => MapEntry('$k', v.toMap())),
        'rules': rules.toMap(),
        'timeOff': timeOff.map((t) => t.toMap()).toList(),
        'overrides': overrides.map((k, v) => MapEntry(k, v.toMap())),
        'paused': paused,
      };

  static DoctorSchedule fromMap(Map d) => DoctorSchedule(
        byWeekday: {
          for (final e in ((d['byWeekday'] as Map?) ?? {}).entries)
            int.parse('${e.key}'): DaySchedule.fromMap(e.value as Map),
        },
        rules: ConsultRules.fromMap((d['rules'] as Map?) ?? const {}),
        timeOff: ((d['timeOff'] as List?) ?? const [])
            .map((e) => TimeOff.fromMap(e as Map))
            .toList(),
        overrides: {
          for (final e in ((d['overrides'] as Map?) ?? {}).entries)
            '${e.key}': DateOverride.fromMap(e.value as Map),
        },
        paused: d['paused'] as bool? ?? false,
      );
}

// ===========================================================================
//  The engine
// ===========================================================================

/// One generated, bookable start time.
@immutable
class GeneratedSlot {
  const GeneratedSlot(this.start, this.durationMin);
  final DateTime start;
  final int durationMin;
  DateTime get end => start.add(Duration(minutes: durationMin));

  @override
  bool operator ==(Object other) =>
      other is GeneratedSlot &&
      other.start == start &&
      other.durationMin == durationMin;
  @override
  int get hashCode => Object.hash(start, durationMin);

  @override
  String toString() => '${start.toIso8601String()} (${durationMin}m)';
}

/// Turn a schedule into the actual slots a parent may book.
///
/// [from]    first day to consider (date part only).
/// [days]    how many days forward to walk.
/// [booked]  starts already taken, so they are never offered twice.
/// [now]     injected for testability; defaults to the real clock.
///
/// Every rule that can remove a slot is applied here and nowhere else, so
/// "why can I not see 5pm?" always has exactly one place to look.
List<GeneratedSlot> generateSlots(
  DoctorSchedule schedule, {
  required DateTime from,
  int days = 30,
  Set<DateTime> booked = const {},
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  if (schedule.paused) return const [];

  final rules = schedule.rules;
  if (rules.slotMinutes <= 0) return const [];

  final earliest = clock.add(Duration(minutes: rules.minNoticeMinutes));
  final latest = DateTime(clock.year, clock.month, clock.day)
      .add(Duration(days: rules.advanceWindowDays));

  final bookedSet = booked.map((d) => d.millisecondsSinceEpoch).toSet();
  final out = <GeneratedSlot>[];

  for (var i = 0; i < days; i++) {
    final day = DateTime(from.year, from.month, from.day).add(Duration(days: i));
    if (day.isAfter(latest)) break;

    // A holiday or vacation removes the day outright.
    if (schedule.timeOff.any((t) => t.covers(day))) continue;

    // A date override beats the weekly pattern.
    final sessions = _sessionsFor(schedule, day);
    if (sessions.isEmpty) continue;

    // How many more bookings this WORKING day can take at all.
    //
    // "Day" here is the SHIFT, not the calendar square. A session running
    // 11 PM - 2 AM belongs to the evening it started, so a consult at 00:30
    // spends the same daily cap as one at 11:30 PM. Counting by calendar date
    // would hand a doctor working nights a fresh maxPerDay at midnight, which
    // is exactly the exhaustion the cap exists to prevent.
    //
    // The window therefore starts where YESTERDAY's shift ended, so a booking
    // in the small hours is charged to one night and not to both.
    final from0 = day.add(Duration(
        minutes: DaySchedule(
                _sessionsFor(schedule, day.subtract(const Duration(days: 1))))
            .spillMin));
    final to0 = day.add(const Duration(days: 1)).add(
        Duration(minutes: DaySchedule(sessions).spillMin));
    final bookedToday =
        booked.where((b) => !b.isBefore(from0) && b.isBefore(to0)).length;
    var remaining = rules.maxPerDay - bookedToday;
    if (remaining <= 0) continue;

    final dayStarts = <GeneratedSlot>[];
    for (final s in sessions) {
      if (!s.isValid) continue;
      // The consultation sits INSIDE its buffers, so the first one cannot start
      // before the session opens plus its own lead-in.
      var cursor = s.start + rules.bufferBeforeMin;
      while (cursor + rules.slotMinutes <= s.end) {
        final start = DateTime(day.year, day.month, day.day)
            .add(Duration(minutes: cursor));
        cursor += rules.slotMinutes + rules.bufferAfterMin + rules.bufferBeforeMin;

        if (bookedSet.contains(start.millisecondsSinceEpoch)) continue;
        if (start.isBefore(earliest)) continue;
        if (start.isAfter(latest)) continue;
        // maxConsecutive: if the doctor already has this many booked
        // appointments running back-to-back into this moment, stop offering -
        // the next one has to come after a break. Counting BACKWARDS by the
        // stride is what "consecutive" actually means here.
        if (rules.maxConsecutive > 0) {
          var run = 0;
          var probe = start;
          while (run < rules.maxConsecutive) {
            probe = probe.subtract(Duration(minutes: rules.strideMin));
            if (!bookedSet.contains(probe.millisecondsSinceEpoch)) break;
            run++;
          }
          if (run >= rules.maxConsecutive) continue;
        }
        dayStarts.add(GeneratedSlot(start, rules.slotMinutes));
      }
    }

    if (remaining < dayStarts.length) {
      dayStarts.removeRange(remaining, dayStarts.length);
    }
    out.addAll(dayStarts);
  }

  return out;
}

/// Group slots by calendar day — what every calendar UI actually needs.
Map<DateTime, List<GeneratedSlot>> groupByDay(List<GeneratedSlot> slots) {
  final map = <DateTime, List<GeneratedSlot>>{};
  for (final s in slots) {
    final k = DateTime(s.start.year, s.start.month, s.start.day);
    (map[k] ??= []).add(s);
  }
  return map;
}

/// A plain-language summary of the week, for the doctor to sanity-check at a
/// glance ("Mon-Sat · 10:00 AM-1:00 PM, 5:00 PM-8:00 PM").
String describeWeek(DoctorSchedule s) {
  const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final working = [
    for (var d = DateTime.monday; d <= DateTime.sunday; d++)
      if (s.dayFor(d).isWorking) d
  ];
  if (working.isEmpty) return 'No working days set';

  // Contiguous run of identical days collapses to "Mon-Sat".
  final allSame = working.every((d) =>
      s.dayFor(d).sessions.toString() ==
      s.dayFor(working.first).sessions.toString());
  final contiguous = working.last - working.first + 1 == working.length;

  final label = (allSame && contiguous && working.length > 1)
      ? '${names[working.first]}-${names[working.last]}'
      : working.map((d) => names[d]).join(', ');

  if (!allSame) return '$label · hours vary by day';
  final times = s.dayFor(working.first).sessions.join(', ');
  return '$label · $times';
}
