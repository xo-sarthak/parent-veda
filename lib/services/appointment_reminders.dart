// =============================================================================
//  AppointmentReminders: the evening before a booked pregnancy appointment
// -----------------------------------------------------------------------------
//  P3 D7 (user, 2026-10-28): "reminder... by default, yes obviously. Just
//  prompt the user and then tell the user where they can see their
//  reminders." Before this, an appointment she added in the Calendar or the
//  Scans timeline was a row and nothing more (P3 CA4).
//
//  ONE RUNG, NOT A LADDER. The doctor app nudges three times because a missed
//  consultation is its worst failure (`doctor_reminders.dart`). Her scan is
//  booked by the clinic, which often calls too, so one calm line at 7 pm the
//  day before is the industry habit (Flo, BabyCenter, the NHS app): enough to
//  plan the morning. If 7 pm has gone already, 8 am on the day, when the
//  appointment is later than that or has no time.
//
//  ON BY DEFAULT, OFF PER APPOINTMENT. The switch is a set of the ids she has
//  turned off, on this phone. Trade-off: a column on `appointments` would
//  travel to her other phone, but costs a migration and a two-repo contract
//  for a preference that only matters where the notification fires, which is
//  this phone. So local, like every other notification switch here.
//
//  Ids are DERIVED from the appointment id (as the doctor reminders do), so
//  re-arming on every launch overwrites rather than duplicates, and cancelling
//  needs no side table. The hash is our own (FNV-1a), not `String.hashCode`,
//  so it cannot change between Dart versions and strand a scheduled alarm.
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/scan_appointment.dart';
import 'notification_service.dart';
import 'remote/sync_registry.dart';

class AppointmentReminders extends ChangeNotifier {
  AppointmentReminders._();
  static final AppointmentReminders instance = AppointmentReminders._();

  static const String kOffKey = 'appt_reminders_off_v1';

  final Set<String> _off = {};
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    // A sign-out forgets her switches in memory; the next person reads their
    // own (the notifications themselves are cancelled by the sign-out).
    SyncRegistry.registerReset(_resetLocal);
    try {
      final prefs = await SharedPreferences.getInstance();
      _off.addAll(prefs.getStringList(kOffKey) ?? const []);
    } catch (_) {/* start with every reminder on */}
    _loaded = true;
    notifyListeners();
  }

  /// True unless she turned this appointment's reminder off.
  bool isOn(String apptId) => !_off.contains(apptId);

  /// The stable notification id for one appointment.
  static int notificationId(String apptId) {
    var h = 0x811c9dc5;
    for (final c in apptId.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0x7fffffff;
    }
    // Kept clear of the reminder and medicine ranges, which count from 0.
    return 0x40000000 | (h & 0x3fffffff);
  }

  /// When the reminder fires for [a], or null when there is none to set: 7 pm
  /// the day before; failing that 8 am on the day, if that is still ahead of
  /// the appointment.
  static DateTime? whenFor(Appointment a, DateTime now) {
    if (a.status != 'upcoming') return null;
    final day = DateTime.tryParse(a.dateIso);
    if (day == null) return null;
    final d = DateTime(day.year, day.month, day.day);
    final evening = d.subtract(const Duration(days: 1)).add(const Duration(hours: 19));
    if (evening.isAfter(now)) return evening;
    final morning = d.add(const Duration(hours: 8));
    final at = _timeOf(a, d);
    if (morning.isAfter(now) && (at == null || at.isAfter(morning))) return morning;
    return null;
  }

  /// The appointment's own time, when "time" holds one ("10:30", "4:15 PM").
  static DateTime? _timeOf(Appointment a, DateTime day) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])?').firstMatch(a.time.trim());
    if (m == null) return null;
    var h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final ap = m.group(3)?.toLowerCase();
    if (ap == 'pm' && h < 12) h += 12;
    if (ap == 'am' && h == 12) h = 0;
    return day.add(Duration(hours: h, minutes: min));
  }

  /// The words she sees, in the Calendar and in the booking's message.
  static String describe(DateTime when, DateTime apptDay) =>
      when.day == apptDay.day && when.month == apptDay.month
          ? 'the morning of'
          : 'the evening before';

  /// What a booking's message adds (D7: "tell the user where they can see
  /// their reminders"): when the reminder fires and where to find it, or
  /// nothing when there is none to set.
  String bookingLine(Appointment a) {
    if (!isOn(a.id)) return '';
    final when = whenFor(a, DateTime.now());
    final day = DateTime.tryParse(a.dateIso);
    if (when == null || day == null) return '';
    return ' We will remind you ${describe(when, day)}. Your reminders are in '
        'Tools, then Reminders.';
  }

  /// (Re)arm or clear the reminder for one appointment. Best-effort: a
  /// platform that cannot schedule is never an error for her save.
  Future<void> sync(Appointment a) async {
    final id = notificationId(a.id);
    try {
      final when = isOn(a.id) ? whenFor(a, DateTime.now()) : null;
      if (when == null) {
        await NotificationService.instance.cancel(id);
        return;
      }
      final body = [
        if (a.time.trim().isNotEmpty) 'At ${a.time.trim()}',
        if (a.location.trim().isNotEmpty) a.location.trim(),
      ].join(', ');
      await NotificationService.instance.scheduleOneOff(
        id: id,
        title: when.hour == 8 ? 'Today: ${a.title}' : 'Tomorrow: ${a.title}',
        body: body.isEmpty ? 'Your appointment, in your ParentVeda Calendar' : body,
        when: when,
      );
    } catch (_) {/* best-effort */}
  }

  Future<void> cancelFor(String apptId) async {
    try {
      await NotificationService.instance.cancel(notificationId(apptId));
    } catch (_) {/* best-effort */}
  }

  /// Her switch for one appointment.
  Future<void> setOn(Appointment a, bool on) async {
    await load();
    on ? _off.remove(a.id) : _off.add(a.id);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(kOffKey, _off.toList());
    } catch (_) {/* best-effort */}
    await sync(a);
  }

  /// Re-arm every one of her own upcoming appointments (on launch and after a
  /// cloud pull). Safe to repeat: the ids are derived.
  Future<void> syncAll(Iterable<Appointment> mine) async {
    await load();
    for (final a in mine) {
      await sync(a);
    }
  }

  /// Fire-and-forget form for store mutations, so a save never waits on the
  /// notification plugin.
  void kick(Appointment a) => unawaited(sync(a));

  void _resetLocal() {
    _off.clear();
    _loaded = false;
    notifyListeners();
  }

  @visibleForTesting
  void resetForTesting() {
    _off.clear();
    _loaded = false;
  }
}
