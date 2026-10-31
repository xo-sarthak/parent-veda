// =============================================================================
//  A child's calendar: the data (STAGE-TRANSITIONS F7, 2026-10-25)
// -----------------------------------------------------------------------------
//  The pregnancy calendar's rule, kept: READ FROM THE OWNERS, WRITE TO THE
//  OWNERS, STORE NOTHING (docs/PREG-CALENDAR.md). The calendar holds no copy:
//  vaccine visits come from the vaccine tracker (`VaxStore`, the child on
//  screen's doses), visits from Health (`HealthStore.visits`, the same
//  child's), and an appointment added here is a Health visit marked upcoming,
//  so Health and the calendar can never disagree about it.
//
//  The one thing it keeps is phone-only and is not a record: which visits want
//  an evening-before reminder ([PpApptReminders]). The alarm is a property of
//  this phone, as the vaccine alarms are, so it never syncs.
//
//  Approved prototype: claude.ai/artifact/QGDv1tigpwXAg7PTrZpyHj (2026-10-25).
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/notification_link.dart';
import '../../../services/notification_service.dart';
import '../../../services/remote/sync_registry.dart';
import '../health_doctor_visit_screen.dart' show ppParseRecordDate;
import '../pp_child_profile.dart' show ChildProfileStore;
import '../pp_health_data.dart';
import '../pp_vaccine_data.dart';

enum PpCalKind { vaccine, checkup, visit }

/// One thing on a day of a child's calendar, with the row it came from.
@immutable
class PpCalItem {
  const PpCalItem({
    required this.kind,
    required this.day,
    required this.title,
    required this.detail,
    required this.status,
    this.vaxVisitId,
    this.healthId,
  });

  final PpCalKind kind;
  final DateTime day;
  final String title;
  final String detail;

  /// The state in her words: 'Given', 'Due', 'Coming', 'Booked', 'Seen'.
  final String status;
  final String? vaxVisitId;
  final String? healthId;

  bool get done => status == 'Given' || status == 'Seen';
}

/// A usual check-up: a window around an age, never a date of ours.
@immutable
class PpCheckup {
  const PpCheckup(this.label, this.ageDays);
  final String label;
  final int ageDays;
}

/// The usual well-baby check-ups in India: they fall on the vaccine visits
/// (IAP schedule), then once a year to five. A window, never a date, until
/// she adds the one she booked: the doctor decides when, we only remind.
const List<PpCheckup> kPpCheckups = [
  PpCheckup('6-week check-up', 42),
  PpCheckup('10-week check-up', 70),
  PpCheckup('14-week check-up', 98),
  PpCheckup('6-month check-up', 182),
  PpCheckup('9-month check-up', 274),
  PpCheckup('1-year check-up', 365),
  PpCheckup('15-month check-up', 456),
  PpCheckup('18-month check-up', 540),
  PpCheckup('2-year check-up', 730),
  PpCheckup('3-year check-up', 1095),
  PpCheckup('4-year check-up', 1461),
  PpCheckup('5-year check-up', 1826),
];

/// What a usual check-up looks at. General, never a diagnosis.
const String kPpCheckupLine =
    'Usually at the vaccine visit: weight, length and head, feeding, and how they move and respond.';

/// A window: a week before the age to three weeks after it.
({DateTime from, DateTime to}) ppCheckupWindow(PpCheckup c, DateTime dob) {
  final at = DateTime(dob.year, dob.month, dob.day).add(Duration(days: c.ageDays));
  return (from: at.subtract(const Duration(days: 7)), to: at.add(const Duration(days: 21)));
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Every item on a child's calendar, oldest first. Pure: the screen passes
/// the stores' answers, the tests pass their own.
List<PpCalItem> ppCalItems({
  required DateTime dob,
  required DateTime today,
  required List<VaxVisit> vaxVisits,
  required bool Function(String visitId) isGiven,
  required DateTime? Function(String visitId) givenOn,
  required List<HealthEvent> visits,
}) {
  final now = _day(today);
  final born = _day(dob);
  final out = <PpCalItem>[];
  for (final v in vaxVisits) {
    final given = isGiven(v.id);
    final day = _day(given ? (givenOn(v.id) ?? born.add(Duration(days: v.ageDays)))
        : born.add(Duration(days: v.ageDays)));
    out.add(PpCalItem(
      kind: PpCalKind.vaccine,
      day: day,
      title: v.ageDays == 0 ? 'Birth vaccines' : '${v.ageLabel} vaccines',
      detail: [for (final x in v.vaccines) x.shortName].join(', '),
      // ⚠️ "Due", never "overdue": a late dose is caught up, not failed.
      status: given ? 'Given' : (day.isAfter(now) ? 'Coming' : 'Due'),
      vaxVisitId: v.id,
    ));
  }
  for (final e in visits) {
    if (e.type != HealthEventType.doctorVisit &&
        e.type != HealthEventType.growthCheck &&
        e.type != HealthEventType.labTest) {
      continue;
    }
    final d = ppParseRecordDate(e.date);
    if (d == null) continue;
    final upcoming = e.upcoming && !d.isBefore(now);
    out.add(PpCalItem(
      kind: PpCalKind.visit,
      day: d,
      title: e.title,
      detail: e.summary.isNotEmpty ? e.summary : (e.doctor ?? ''),
      status: upcoming ? 'Booked' : 'Seen',
      healthId: e.id,
    ));
  }
  out.sort((a, b) => a.day.compareTo(b.day));
  return out;
}

/// The items on [day].
List<PpCalItem> ppCalOn(List<PpCalItem> all, DateTime day) =>
    [for (final x in all) if (x.day == _day(day)) x];

/// What is still ahead, nearest first.
List<PpCalItem> ppCalComingUp(List<PpCalItem> all, DateTime today, {int take = 4}) =>
    [for (final x in all) if (!x.done && !x.day.isBefore(_day(today))) x].take(take).toList();

/// The next usual check-ups whose window has not closed, each with whether a
/// visit is already booked inside it.
List<({PpCheckup c, DateTime from, DateTime to, bool booked})> ppNextCheckups(
    DateTime dob, DateTime today, List<PpCalItem> items, {int take = 1}) {
  final now = _day(today);
  final out = <({PpCheckup c, DateTime from, DateTime to, bool booked})>[];
  for (final c in kPpCheckups) {
    final w = ppCheckupWindow(c, dob);
    if (w.to.isBefore(now)) continue;
    final booked = items.any((x) =>
        x.kind == PpCalKind.visit && x.status == 'Booked' &&
        !x.day.isBefore(w.from) && !x.day.isAfter(w.to));
    out.add((c: c, from: w.from, to: w.to, booked: booked));
    if (out.length == take) break;
  }
  return out;
}

/// "29 Oct 2026", the way Health writes a visit's date.
String ppRecordDate(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

/// The appointment's reminder id: a block of its own (0x3B), as the TTC
/// appointments keep 0x3A, so neither can cancel the other's.
int ppApptReminderId(String visitId) {
  var h = 0x811c9dc5;
  for (final c in visitId.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return 0x3B000000 | (h & 0xFFFFF);
}

/// 7 pm the evening before [at]; null once that has passed.
DateTime? ppEveningBefore(DateTime at, DateTime now) {
  final d = DateTime(at.year, at.month, at.day).subtract(const Duration(days: 1));
  final when = DateTime(d.year, d.month, d.day, 19);
  return when.isAfter(now) ? when : null;
}

/// Which appointments want an evening-before reminder. Phone-only, like the
/// vaccine alarms; re-armed after launch, because the launch's `syncAll`
/// cancels everything scheduled before it (main.dart).
class PpApptReminders {
  PpApptReminders._() {
    SyncRegistry.registerReset(_reset);
  }
  static final PpApptReminders instance = PpApptReminders._();

  static const String _key = 'pp_appt_reminders_v1';

  /// visit id -> (when it rings, title, body, whose visit). [child] (6b
  /// leftover L4): the child active when it was set, so a tap opens that
  /// child's calendar. Null on a reminder saved before L4.
  final Map<String, ({DateTime at, String title, String body, String? child})> _on = {};
  bool _loaded = false;

  @visibleForTesting
  // Kept for revert (6b L4, no payload):
  //   static Future<void> Function({required int id, required String title, String? body, required DateTime when})
  static Future<void> Function(
          {required int id, required String title, String? body, required DateTime when, String? payload})
      schedule = NotificationService.instance.scheduleOneOff;

  /// What a tap on [visitId]'s reminder opens: that child's calendar.
  static String payloadFor(String visitId, String? child) =>
      NotificationLink(NotificationLink.ppAppointment, NotificationLink.withChild(child, visitId)).payload;
  @visibleForTesting
  static Future<void> Function(int id) cancelPhone = NotificationService.instance.cancel;

  bool isOn(String visitId) => _on.containsKey(visitId);

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw == null) return;
      final m = jsonDecode(raw) as Map<String, dynamic>;
      for (final e in m.entries) {
        final v = e.value as Map<String, dynamic>;
        final at = DateTime.tryParse(v['at'] as String? ?? '');
        if (at == null) continue;
        _on[e.key] = (
          at: at,
          title: v['title'] as String? ?? '',
          body: v['body'] as String? ?? '',
          child: v['child'] as String?,
        );
      }
    } catch (_) {/* a corrupt record reads as none */}
  }

  Future<void> _save() async {
    try {
      await (await SharedPreferences.getInstance()).setString(_key, jsonEncode({
        for (final e in _on.entries)
          e.key: {
            'at': e.value.at.toIso8601String(),
            'title': e.value.title,
            'body': e.value.body,
            if (e.value.child != null) 'child': e.value.child,
          },
      }));
    } catch (_) {/* the alarm still rings this run */}
  }

  /// Ring at 7 pm the evening before [appointmentAt]. Returns the time it will
  /// ring, or null when that evening has already passed.
  Future<DateTime?> remind(String visitId, DateTime appointmentAt,
      {required String title, required String body, DateTime? now}) async {
    await _load();
    final when = ppEveningBefore(appointmentAt, now ?? DateTime.now());
    if (when == null) return null;
    final child = ChildProfileStore.instance.activeChildId;
    _on[visitId] = (at: when, title: title, body: body, child: child);
    await _save();
    await schedule(
            id: ppApptReminderId(visitId),
            title: title,
            body: body,
            when: when,
            payload: payloadFor(visitId, child))
        .catchError((_) {});
    return when;
  }

  Future<void> forget(String visitId) async {
    await _load();
    if (_on.remove(visitId) == null) return;
    await _save();
    await cancelPhone(ppApptReminderId(visitId)).catchError((_) {});
  }

  /// ⚠️ MUST RUN AFTER `ReminderStore.init` (main.dart), whose `syncAll`
  /// wipes every scheduled alarm on launch. Past ones are dropped.
  Future<void> rearmAfterStartup({DateTime? now}) async {
    await _load();
    final t = now ?? DateTime.now();
    _on.removeWhere((_, v) => !v.at.isAfter(t));
    await _save();
    for (final e in _on.entries) {
      await schedule(
              id: ppApptReminderId(e.key),
              title: e.value.title,
              body: e.value.body,
              when: e.value.at,
              payload: payloadFor(e.key, e.value.child))
          .catchError((_) {});
    }
  }

  void _reset() {
    _on.clear();
    _loaded = false;
  }

  @visibleForTesting
  void debugReset() {
    _on.clear();
    _loaded = false;
    schedule = NotificationService.instance.scheduleOneOff;
    cancelPhone = NotificationService.instance.cancel;
  }
}
