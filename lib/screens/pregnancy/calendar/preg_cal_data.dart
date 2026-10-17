// =============================================================================
//  The pregnancy calendar's data: one list of things on days (2026-10-17)
// -----------------------------------------------------------------------------
//  The calendar was rebuilt from three tabs into one hub (Mobbin pass, see
//  docs/MOBBIN-DISCOVERY.md "Pregnancy calendar"). This file is everything it
//  READS, assembled once, so the hub, Coming up and Whole journey can never
//  disagree about a day:
//
//    · appointments        ← ScansStore (her own + her partner's)
//    · completed scans     ← ScansStore.completed
//    · weight              ← ToolsStore.weightEntries
//    · kick counts         ← ToolsStore.movementSessionHistory
//    · symptoms            ← SymptomStore.logs
//    · her notes           ← CalendarStore.personal (synced)
//    · journal memories    ← JournalStore.manualEntries
//
//  Nothing is stored here. Every add goes to the store that already owns it,
//  so a weight added from the calendar is the same row the weight chart reads.
//
//  ⚠️ WHY NOT `CalendarStore.allEvents`. That list squeezed weight and kicks
//  into "journal", put every enrolled program on today, and carried no time,
//  place or source row, so the calendar could not open the right tool or edit
//  anything. It stays, unchanged, for the old screen kept for revert.
//
//  ⚠️ USUAL CHECKS ARE WINDOWS, NEVER HER DATES. "NT scan, around weeks 11 to
//  13" is what most clinics follow; her doctor sets the day. A check only
//  takes a date when SHE books it (an appointment) or marks it done (a
//  completed scan). Clinical ownership: CLAUDE.md, "Clinical invariants".
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/journey_milestones.dart';
import '../../../data/prepare_data.dart';
import '../../../data/scan_schedule.dart';
import '../../../data/symptoms/symptom_library.dart';
import '../../../models/calendar_event.dart';
import '../../../models/journey_node.dart';
import '../../../models/scan_appointment.dart';
import '../../../services/calendar_store.dart';
import '../../../services/journal_store.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../services/prepare_store.dart';
import '../../../services/reminder_store.dart';
import '../../../services/scans_store.dart';
import '../../../services/symptom_store.dart';
import '../../../services/tools_store.dart';
import '../../brackets/hub/hub_intent_art.dart' show IntentMark;

// ---------------------------------------------------------------------------
//  Days and weeks
// ---------------------------------------------------------------------------

DateTime pregDayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool pregSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Days of pregnancy on [day], counted from the due date: the due date is day
/// 280, so day 0 is the first day of the last period (Naegele). The same sum
/// `PregnancyController.currentDay` does, for any day, not only today.
int pregGaDays(DateTime due, DateTime day) =>
    PregnancyController.termDays -
    pregDayOnly(due).difference(pregDayOnly(day)).inDays;

/// Completed weeks on [day] ("20 weeks 2 days" → 20).
int pregCompletedWeeks(DateTime due, DateTime day) =>
    (pregGaDays(due, day) / 7).floor();

/// The week she is IN on [day], 1-based ("week 21 of 40" at 20w2d). The same
/// count `PregnancyController.currentWeek` gives for today.
int pregWeekOf(DateTime due, DateTime day) => pregCompletedWeeks(due, day) + 1;

/// The first day of pregnancy week [week] (1-based).
DateTime pregWeekStart(DateTime due, int week) => pregDayOnly(due)
    .subtract(Duration(days: PregnancyController.termDays - (week - 1) * 7));

/// The trimester for a number of COMPLETED weeks, stated once for the whole
/// calendar (2026-10-17 fact check, ACOG and NHS): the first runs to 13 weeks
/// 6 days, the second from 14 weeks 0 days to 27 weeks 6 days, the third from
/// 28 weeks. The old grid tagged week 4 as a trimester start; it is not one.
int pregTrimesterFor(int completedWeeks) =>
    completedWeeks < 14 ? 1 : (completedWeeks < 28 ? 2 : 3);

const List<String> kPregTrimesterNames = [
  '',
  'First trimester',
  'Second trimester',
  'Third trimester',
];

const List<String> _kWd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> _kMo = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const List<String> kPregMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// "Sat 17 Oct".
String pregDayLabel(DateTime d) =>
    '${_kWd[d.weekday - 1]} ${d.day} ${_kMo[d.month - 1]}';

/// "17 Oct".
String pregShortDate(DateTime d) => '${d.day} ${_kMo[d.month - 1]}';

/// "SAT".
String pregWeekdayCaps(DateTime d) => _kWd[d.weekday - 1].toUpperCase();

// ---------------------------------------------------------------------------
//  Kinds
// ---------------------------------------------------------------------------

enum PregCalKind { appointment, check, weight, kicks, symptom, note, journal }

/// One colour per kind, and only kinds carry colour (the TTC palette rule):
/// everything else on the calendar is ink or grey. These replace the
/// hardcoded hexes the old grid scattered through its cells.
class PregCalMeta {
  const PregCalMeta(this.label, this.color, this.mark);
  final String label;
  final Color color;
  final IntentMark mark;

  double get hue => HSLColor.fromColor(color).hue;
}

const Map<PregCalKind, PregCalMeta> kPregCalMeta = {
  PregCalKind.appointment:
      PregCalMeta('Appointment', Color(0xFF3E6DA6), IntentMark.askDoctor),
  PregCalKind.check:
      PregCalMeta('Usual check', Color(0xFF2E9C8E), IntentMark.scanFan),
  PregCalKind.weight:
      PregCalMeta('Weight', Color(0xFF5B7F3A), IntentMark.scaleMark),
  PregCalKind.kicks:
      PregCalMeta('Kicks', Color(0xFFB5651D), IntentMark.stepsMark),
  PregCalKind.symptom:
      PregCalMeta('Symptom', Color(0xFFC6295A), IntentMark.bodyMark),
  PregCalKind.note:
      PregCalMeta('My note', Color(0xFFC98A2B), IntentMark.calendarDay),
  PregCalKind.journal:
      PregCalMeta('Journal', Color(0xFF6D6E72), IntentMark.pageMark),
};

PregCalMeta pregCalMeta(PregCalKind k) => kPregCalMeta[k]!;

// ---------------------------------------------------------------------------
//  Usual checks (windows from kJourneyMilestones, medical)
// ---------------------------------------------------------------------------

class PregCheck {
  const PregCheck({
    required this.milestone,
    required this.fromWeek,
    required this.toWeek,
    required this.windowLabel,
  });

  final JourneyMilestone milestone;
  final int fromWeek;
  final int toWeek;

  /// "Around weeks 24–28", or the milestone's own words when it has no weeks
  /// ("At booking, then 4 weeks later").
  final String windowLabel;

  String get id => milestone.id;
  String get title => milestone.title.en;

  int get trimester => pregTrimesterFor(fromWeek - 1);

  /// The first "Why this matters" style paragraph, for the check's sheet.
  String get about {
    for (final sec in milestone.sections) {
      final b = sec.body.en.trim();
      if (b.isNotEmpty) return b;
    }
    return '';
  }

  /// The "Typical timing" words, when the milestone has them.
  String get timing {
    for (final sec in milestone.sections) {
      if (sec.label.en.toLowerCase().contains('timing')) {
        return sec.body.en.trim();
      }
    }
    return '';
  }
}

/// Every usual check, earliest first. The window comes from the milestone's
/// `rangeLabel` ("Week 18–22"); a milestone with no weeks in its label keeps
/// its anchor week and shows the label as written.
List<PregCheck> pregChecks() {
  final out = <PregCheck>[];
  for (final m in allMedicalScans()) {
    final label = m.rangeLabel?.en ?? '';
    final nums = RegExp(r'\d+')
        .allMatches(label)
        .map((x) => int.parse(x.group(0)!))
        .toList();
    // Only a label that IS a week range ("Week 18–22") is read as one; "At
    // booking, then 4 weeks later" names a number of weeks, not a window.
    final weeksInLabel =
        label.toLowerCase().startsWith('week') && nums.isNotEmpty;
    final from = weeksInLabel ? nums.first : m.anchorWeek;
    final to = weeksInLabel ? nums.last : m.anchorWeek;
    final window = weeksInLabel
        ? (from == to ? 'Around week $from' : 'Around weeks $from–$to')
        : (label.isNotEmpty ? label : 'Around week ${m.anchorWeek}');
    out.add(PregCheck(
        milestone: m, fromWeek: from, toWeek: to, windowLabel: window));
  }
  return out;
}

/// Where a check stands for her: done (a completed scan), booked (one of her
/// appointments carries its name), or open.
enum PregCheckState { open, booked, done }

class PregCheckStatus {
  const PregCheckStatus(this.state, [this.date]);
  final PregCheckState state;
  final DateTime? date;
}

PregCheckStatus pregCheckStatus(PregCheck c) {
  final done = ScansStore.instance.completedOf(c.id);
  if (done != null) {
    return PregCheckStatus(
        PregCheckState.done, DateTime.tryParse(done.dateIso));
  }
  // The appointment model has no link to a check, so "booked" is matched by
  // name: "Add as appointment" fills the title with the check's name, and
  // she may rename it (then it simply reads as open again, never wrong).
  final key = c.title.toLowerCase();
  for (final a in ScansStore.instance.appointments) {
    if (a.status == 'completed') continue;
    if (a.title.trim().toLowerCase() == key) {
      return PregCheckStatus(PregCheckState.booked, pregDayOnly(a.date));
    }
  }
  return const PregCheckStatus(PregCheckState.open);
}

// ---------------------------------------------------------------------------
//  Items on days
// ---------------------------------------------------------------------------

class PregCalItem {
  const PregCalItem({
    required this.id,
    required this.kind,
    required this.date,
    required this.title,
    this.detail = '',
    this.done = false,
    this.appointment,
    this.note,
    this.check,
    this.ownedByHer = true,
  });

  final String id;
  final PregCalKind kind;

  /// The day, time stripped.
  final DateTime date;
  final String title;
  final String detail;
  final bool done;

  /// The source row, so a tap can open, edit or delete the real thing.
  final Appointment? appointment;
  final CalendarEvent? note;
  final PregCheck? check;

  /// False for a partner's appointment: shown, never editable here.
  final bool ownedByHer;

  PregCalMeta get meta => pregCalMeta(kind);
}

String _kg(double w) => '${w.toStringAsFixed(1)} kg';

/// Everything on the calendar, assembled from the stores that own it,
/// earliest first.
List<PregCalItem> pregCalItems() {
  final out = <PregCalItem>[];
  final scans = ScansStore.instance;

  for (final a in scans.appointments) {
    final detail = [a.doctor, a.time, a.location]
        .where((x) => x.trim().isNotEmpty)
        .join(' · ');
    out.add(PregCalItem(
      id: 'ap_${a.id}',
      kind: PregCalKind.appointment,
      date: pregDayOnly(a.date),
      title: a.title,
      detail: detail,
      done: a.status == 'completed',
      appointment: a,
      ownedByHer: scans.ownsAppointment(a.id),
    ));
  }

  final checks = {for (final c in pregChecks()) c.id: c};
  for (final c in scans.completed) {
    final d = DateTime.tryParse(c.dateIso);
    final check = checks[c.scanId];
    if (d == null || check == null) continue;
    out.add(PregCalItem(
      id: 'cs_${c.scanId}',
      kind: PregCalKind.check,
      date: pregDayOnly(d),
      title: check.title,
      detail: 'Done',
      done: true,
      check: check,
    ));
  }

  final tools = ToolsStore.instance;
  final weights = [...tools.weightEntries]
    ..sort((a, b) => a.timeIso.compareTo(b.timeIso));
  double? prev;
  for (final w in weights) {
    final d = DateTime.tryParse(w.timeIso) ?? DateTime.tryParse(w.dateIso);
    if (d == null) continue;
    final change = prev == null ? null : w.weight - prev;
    prev = w.weight;
    out.add(PregCalItem(
      id: 'wt_${w.id}',
      kind: PregCalKind.weight,
      date: pregDayOnly(d),
      title: 'Weight',
      detail: change == null || change.abs() < 0.05
          ? _kg(w.weight)
          : '${_kg(w.weight)} · ${change > 0 ? 'up' : 'down'} ${change.abs().toStringAsFixed(1)} kg',
    ));
  }

  for (final m in tools.movementSessionHistory) {
    final mins = m.end.difference(m.start).inMinutes;
    out.add(PregCalItem(
      id: 'kc_${m.id}',
      kind: PregCalKind.kicks,
      date: pregDayOnly(m.start),
      title: 'Kick count',
      detail: '${m.times.length} movements${mins > 0 ? ' in $mins min' : ''}',
    ));
  }

  for (final l in SymptomStore.instance.logs) {
    final d = DateTime.tryParse(l.dateKey);
    if (d == null) continue;
    final name = symptomById(l.symptomId)?.name.en ?? 'Symptom';
    final sev = l.severity.isEmpty
        ? ''
        : '${l.severity[0].toUpperCase()}${l.severity.substring(1)}';
    out.add(PregCalItem(
      id: 'sy_${l.id}',
      kind: PregCalKind.symptom,
      date: pregDayOnly(d),
      title: name,
      detail: [sev, l.notes.trim()].where((x) => x.isNotEmpty).join(' · '),
    ));
  }

  for (final e in CalendarStore.instance.personal) {
    out.add(PregCalItem(
      id: 'nt_${e.id}',
      kind: PregCalKind.note,
      date: pregDayOnly(e.date),
      title: e.title,
      detail: e.description,
      note: e,
    ));
  }

  for (final j in JournalStore.instance.manualEntries) {
    out.add(PregCalItem(
      id: 'jr_${j.id}',
      kind: PregCalKind.journal,
      date: pregDayOnly(j.date),
      title: j.title,
      detail: j.description,
    ));
  }

  out.sort((a, b) => a.date.compareTo(b.date));
  return out;
}

/// The items on [day].
List<PregCalItem> pregItemsOn(List<PregCalItem> all, DateTime day) =>
    [for (final i in all) if (pregSameDay(i.date, day)) i];

// ---------------------------------------------------------------------------
//  Coming up
// ---------------------------------------------------------------------------

/// One row of Coming up: an item with a real date, or an open usual check
/// shown from the start of its window ("around").
class PregUpcoming {
  const PregUpcoming({required this.date, this.item, this.check});
  final DateTime date;
  final PregCalItem? item;
  final PregCheck? check;

  bool get around => check != null;
  PregCalKind get kind => item?.kind ?? PregCalKind.check;
  String get title => item?.title ?? check!.title;
  String get detail => item?.detail ?? check!.windowLabel;
}

/// Her appointments and notes from [today] on, and the usual checks still
/// ahead of her that she has not booked or done. Soonest first.
List<PregUpcoming> pregUpcoming(
    List<PregCalItem> all, DateTime due, DateTime today) {
  final t = pregDayOnly(today);
  final out = <PregUpcoming>[
    for (final i in all)
      if (!i.done &&
          !i.date.isBefore(t) &&
          (i.kind == PregCalKind.appointment || i.kind == PregCalKind.note))
        PregUpcoming(date: i.date, item: i),
  ];
  for (final c in pregChecks()) {
    if (pregCheckStatus(c).state != PregCheckState.open) continue;
    final end = pregWeekStart(due, c.toWeek + 1);
    if (!end.isAfter(t)) continue; // its window has passed
    final start = pregWeekStart(due, c.fromWeek);
    out.add(PregUpcoming(date: start.isBefore(t) ? t : start, check: c));
  }
  out.sort((a, b) => a.date.compareTo(b.date));
  return out;
}

/// "In 3 days", "Tomorrow", "Today", or for a check "From 13 Nov" / "Now".
String pregCountdown(PregUpcoming u, DateTime today) {
  final n = pregDayOnly(u.date).difference(pregDayOnly(today)).inDays;
  if (u.around) return n <= 0 ? 'Now' : 'From ${pregShortDate(u.date)}';
  if (n == 0) return 'Today';
  if (n == 1) return 'Tomorrow';
  return 'In $n days';
}

// ---------------------------------------------------------------------------
//  Every-day things: reminders and programs (Coming up only, never a dot)
// ---------------------------------------------------------------------------

class PregCalLine {
  const PregCalLine(this.title, this.detail);
  final String title;
  final String detail;
}

String _hm(int h, int m) =>
    '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

List<PregCalLine> pregReminderLines() => [
      for (final r in ReminderStore.instance.active)
        PregCalLine(r.title, _hm(r.hour, r.minute)),
    ];

/// Enrolled programs. They have no real session date stored (PrepareStore
/// keeps the id only), so they are listed, never pinned to a day. The old grid
/// put every one of them on today, every day.
List<PregCalLine> pregProgramLines() {
  final prep = PrepareStore.instance;
  return [
    for (final c in kCohorts)
      if (prep.isBooked(c.id))
        PregCalLine(
            c.name.en,
            (c.start != null && c.start!.en.trim().isNotEmpty)
                ? '${c.duration.en} · ${c.start!.en}'
                : c.duration.en),
    for (final sp in kSpecialists)
      if (prep.isBooked(sp.id))
        PregCalLine('${sp.role} · ${sp.name}', '30-min video consultation'),
    if (prep.isBooked('course_birthing'))
      const PregCalLine('Birthing course', '6 classes, at your own pace'),
  ];
}

/// The achievement milestones for a week (Whole journey's week cards).
List<JourneyMilestone> pregMilestonesForWeek(int week) => [
      for (final m in kJourneyMilestones)
        if (m.type == JourneyNodeType.achievement && m.anchorWeek == week) m,
    ];
