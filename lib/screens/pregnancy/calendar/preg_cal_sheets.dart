// =============================================================================
//  The pregnancy calendar's sheets (2026-10-17)
// -----------------------------------------------------------------------------
//  Add (a list of rows, Apple Health's "Log", Mobbin 9710c735; Withings Cycle
//  Logs, 00c25e9d), an item's sheet (CVS c3a9a7d5, Zocdoc 71930370: when,
//  where, with whom, then the actions), a usual check's sheet (a window, never
//  her date, with "Add as appointment"), the note and the weight sheets.
//
//  ⚠️ EVERY ADD GOES TO THE STORE THAT OWNS IT. An appointment is the same row
//  Scans & appointments shows, a weight the same row the chart reads. Nothing
//  here keeps a copy, so nothing can drift.
//
//  ⚠️ WHAT CAN BE ADDED ON WHICH DAY, and the sheet says why when it cannot:
//    · appointment, note: any day of the pregnancy, future included;
//    · weight: today or a past day;
//    · symptom: today (the Symptoms tool logs today);
//    · kick count: today, from 28 weeks (ACOG counts from 28; RCOG asks her to
//      know her baby's usual pattern). Earlier, movements go in a note.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../models/calendar_event.dart';
import '../../../models/scan_appointment.dart';
import '../../../services/appointment_reminders.dart';
import '../../../services/calendar_store.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../services/scans_store.dart';
import '../../../services/tools_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_toast.dart';
import '../../journal/pv_journal_screen.dart' show JournalScreen;
import '../../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
import '../../tools/baby_movement_screen.dart';
import '../../brackets/scan_timeline_screen.dart' show ScanTimelineScreen;
import '../../tools/scans_appointments_screen.dart' show showPregAppointmentSheet;
import '../../tools/symptom_companion_screen.dart';
import '../../tools/weight_tracker_screen.dart';
import '../../weekly_card_stack_screen.dart';
import 'preg_cal_data.dart';
import 'preg_cal_parts.dart';

// ---------------------------------------------------------------------------
//  Opening the tools
// ---------------------------------------------------------------------------

void _push(BuildContext context, String name, WidgetBuilder b) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(settings: RouteSettings(name: name), builder: b));

// P3 D3 (2026-10-28): her scans, not the retired Scans and appointments
// screen (which now opens this Calendar, so the row would open itself).
// Kept for revert:
//   (_) => ScansAppointmentsScreen(controller: p));
void pregCalOpenScans(BuildContext context, PregnancyController p) => _push(
    context, 'calendar/scans', (_) => ScanTimelineScreen(pregnancy: p));

void pregCalOpenWeight(BuildContext context, PregnancyController p) => _push(
    context, 'calendar/weight', (_) => WeightTrackerScreen(controller: p));

void pregCalOpenKicks(BuildContext context, PregnancyController p) => _push(
    context, 'calendar/kicks', (_) => BabyMovementScreen(controller: p));

void pregCalOpenSymptoms(BuildContext context, PregnancyController p) => _push(
    context, 'calendar/symptoms', (_) => SymptomCompanionScreen(controller: p));

void pregCalOpenWeek(BuildContext context, PregnancyController p, int week) {
  p.selectWeek(week);
  _push(context, 'calendar/week', (_) => WeeklyCardStackScreen(controller: p));
}

void pregCalOpenJournal(BuildContext context, PregnancyController p) =>
    _push(context, 'calendar/journal', (_) => JournalScreen(controller: p));

// ---------------------------------------------------------------------------
//  Add
// ---------------------------------------------------------------------------

/// Why a kind cannot be added on [day], or null when it can.
String? pregCalAddBlocked(PregCalKind k, DateTime day, DateTime today, DateTime due) {
  final d = pregDayOnly(day), t = pregDayOnly(today);
  final future = d.isAfter(t), isToday = pregSameDay(d, t);
  switch (k) {
    case PregCalKind.appointment:
    case PregCalKind.note:
      return null;
    case PregCalKind.weight:
      return future ? 'Log weight on the day' : null;
    case PregCalKind.symptom:
      return isToday ? null : 'Symptoms are logged for today';
    case PregCalKind.kicks:
      if (!isToday) return 'Kicks are counted live, on the day';
      if (pregCompletedWeeks(due, d) < 28) {
        return 'Kick counts usually start around week 28. Note movements in a note';
      }
      return null;
    case PregCalKind.check:
    case PregCalKind.journal:
      return 'Not added here';
  }
}

String _addHint(PregCalKind k) => switch (k) {
      PregCalKind.appointment => 'Check-up, scan, test or injection',
      PregCalKind.weight => 'Saved to your weight chart',
      PregCalKind.symptom => 'Opens Symptoms',
      PregCalKind.kicks => 'Opens the kick counter',
      PregCalKind.note => 'Anything you want to remember',
      _ => '',
    };

String _addLabel(PregCalKind k) => switch (k) {
      PregCalKind.appointment => 'Appointment',
      PregCalKind.weight => 'Weight',
      PregCalKind.symptom => 'Symptom',
      PregCalKind.kicks => 'Kick count',
      PregCalKind.note => 'Note',
      _ => '',
    };

Future<void> showPregCalAdd(
    BuildContext context, PregnancyController p, DateTime day,
    {DateTime? today}) async {
  final now = today ?? DateTime.now();
  final week = pregWeekOf(p.dueDate, day);
  final dow = pregGaDays(p.dueDate, day) % 7 + 1;
  final picked = await showPregCalSheet<PregCalKind>(
    context,
    (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Add to ${pregDayLabel(day)}', style: pregCalSerif(22)),
      const SizedBox(height: 3),
      Text('Week $week, day $dow',
          style: pregCalBody(size: 13, weight: FontWeight.w600, color: pvStorePalette.ink3)),
      const SizedBox(height: 8),
      for (final (i, k) in const [
        PregCalKind.appointment,
        PregCalKind.weight,
        PregCalKind.symptom,
        PregCalKind.kicks,
        PregCalKind.note,
      ].indexed)
        _AddRow(
          kind: k,
          label: _addLabel(k),
          hint: pregCalAddBlocked(k, day, now, p.dueDate) ?? _addHint(k),
          enabled: pregCalAddBlocked(k, day, now, p.dueDate) == null,
          first: i == 0,
          onTap: () => Navigator.pop(ctx, k),
        ),
    ]),
  );
  if (picked == null || !context.mounted) return;
  switch (picked) {
    case PregCalKind.appointment:
      final a = await showPregAppointmentSheet(context, initial: day);
      if (a != null && context.mounted) {
        // Kept for revert: '... Also in Scans & appointments' (retired, P3 D3).
        pvToast(context,
            'Added to ${pregDayLabel(a.date)}.${AppointmentReminders.instance.bookingLine(a)}',
            kind: PvToastKind.done);
      }
    case PregCalKind.weight:
      await showPregCalWeight(context, p, day);
    case PregCalKind.symptom:
      pregCalOpenSymptoms(context, p);
    case PregCalKind.kicks:
      pregCalOpenKicks(context, p);
    case PregCalKind.note:
      await showPregCalNote(context, day: day);
    case PregCalKind.check:
    case PregCalKind.journal:
      break;
  }
}

class _AddRow extends StatelessWidget {
  const _AddRow({
    required this.kind,
    required this.label,
    required this.hint,
    required this.enabled,
    required this.first,
    required this.onTap,
  });
  final PregCalKind kind;
  final String label;
  final String hint;
  final bool enabled;
  final bool first;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          border: first ? null : const Border(top: BorderSide(color: kPvLine))),
      child: Row(children: [
        pregCalMark(kind, size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: pregCalBody(size: 15, weight: FontWeight.w700)),
            const SizedBox(height: 1),
            Text(hint, style: pregCalBody(size: 12.5, color: pvStorePalette.ink3)),
          ]),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(color: kPregCalTint, shape: BoxShape.circle),
          child: const Icon(Icons.add_rounded, size: 18, color: kPvInk),
        ),
      ]),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: '$label. $hint',
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: pregCalTap(onTap: enabled ? onTap : null, child: row),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Weight
// ---------------------------------------------------------------------------

Future<void> showPregCalWeight(
    BuildContext context, PregnancyController p, DateTime day) async {
  final entries = [...ToolsStore.instance.weightEntries]
    ..sort((a, b) => a.timeIso.compareTo(b.timeIso));
  final last = entries.isEmpty ? null : entries.last;
  var kg = last?.weight ?? 60.0;
  final saved = await showPregCalSheet<double>(
    context,
    (ctx) => StatefulBuilder(
      builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Weight', style: pregCalSerif(22)),
        const SizedBox(height: 3),
        Text(pregDayLabel(day),
            style: pregCalBody(size: 13, weight: FontWeight.w600, color: pvStorePalette.ink3)),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _StepButton(
              icon: Icons.remove_rounded,
              label: 'Less',
              onTap: () => set(() => kg = (kg - 0.1).clamp(30, 200).toDouble())),
          SizedBox(
            width: 160,
            child: Text('${kg.toStringAsFixed(1)} kg',
                textAlign: TextAlign.center, style: pregCalSerif(40)),
          ),
          _StepButton(
              icon: Icons.add_rounded,
              label: 'More',
              onTap: () => set(() => kg = (kg + 0.1).clamp(30, 200).toDouble())),
        ]),
        const SizedBox(height: 10),
        Center(
          child: Text(
            last == null
                ? 'Your doctor tells you what gain suits you.'
                : 'Last: ${last.weight.toStringAsFixed(1)} kg on ${pregShortDate(DateTime.tryParse(last.timeIso) ?? day)}. Your doctor tells you what gain suits you.',
            textAlign: TextAlign.center,
            style: pregCalBody(size: 12.5, color: pvStorePalette.ink3, height: 1.45),
          ),
        ),
        const SizedBox(height: 16),
        pregCalSaveButton('Save weight', () => Navigator.pop(ctx, kg)),
      ]),
    ),
  );
  if (saved == null) return;
  final now = DateTime.now();
  final ts = DateTime(day.year, day.month, day.day, now.hour, now.minute, now.second);
  await ToolsStore.instance.addWeightEntry(WeightEntry(
    id: 'w_${now.microsecondsSinceEpoch}',
    dateIso:
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
    timeIso: ts.toIso8601String(),
    // The week of the day she logged it for, not of today: a weight added for
    // last Tuesday belongs to last Tuesday's week.
    week: pregWeekOf(p.dueDate, day).clamp(1, 42),
    weight: double.parse(saved.toStringAsFixed(1)),
  ));
  if (context.mounted) {
    pvToast(context, '${saved.toStringAsFixed(1)} kg saved to your weight chart',
        kind: PvToastKind.done);
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: pregCalTap(
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                shape: BoxShape.circle, border: Border.all(color: kPvLine)),
            child: Icon(icon, color: kPvInk),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
//  Note
// ---------------------------------------------------------------------------

Future<void> showPregCalNote(BuildContext context,
    {required DateTime day, CalendarEvent? editing}) async {
  final titleCtrl = TextEditingController(text: editing?.title ?? '');
  final bodyCtrl = TextEditingController(text: editing?.description ?? '');
  var date = editing?.date ?? day;
  final ok = await showPregCalSheet<bool>(
    context,
    (ctx) => StatefulBuilder(
      builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(editing == null ? 'Note' : 'Edit note', style: pregCalSerif(22)),
        const SizedBox(height: 12),
        _field('Title, for example "First flutter"', titleCtrl, autofocus: editing == null),
        _field('Note', bodyCtrl, lines: 3),
        pregCalTap(
          onTap: () async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate: date,
              firstDate: DateTime(date.year - 1),
              lastDate: DateTime(date.year + 2),
            );
            if (picked != null) set(() => date = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
                border: Border.all(color: kPvLine),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded, size: 18, color: kPvInk),
              const SizedBox(width: 12),
              Text(pregDayLabel(date), style: pregCalBody(size: 14)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        pregCalSaveButton(editing == null ? 'Save note' : 'Save changes',
            () => Navigator.pop(ctx, true)),
      ]),
    ),
  );
  final title = titleCtrl.text.trim();
  if (ok != true || title.isEmpty) return;
  if (editing == null) {
    await CalendarStore.instance
        .addPersonal(title: title, description: bodyCtrl.text.trim(), date: date);
    if (context.mounted) {
      pvToast(context, 'Note saved to ${pregDayLabel(date)}', kind: PvToastKind.done);
    }
  } else {
    await CalendarStore.instance.updatePersonal(editing.id,
        title: title, description: bodyCtrl.text.trim(), date: date);
    if (context.mounted) pvToast(context, 'Note updated', kind: PvToastKind.done);
  }
}

Widget _field(String hint, TextEditingController c, {int lines = 1, bool autofocus = false}) {
  OutlineInputBorder b(Color color, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: w));
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c,
      autofocus: autofocus,
      minLines: lines,
      maxLines: lines,
      style: pvManrope(fontSize: 15, color: pvStorePalette.ink1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: pvManrope(fontSize: 14, color: pvStorePalette.ink3),
        filled: true,
        fillColor: Colors.white,
        border: b(kPvLine),
        enabledBorder: b(kPvLine),
        focusedBorder: b(kPvInk, 1.4),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
//  An item's sheet
// ---------------------------------------------------------------------------

Future<void> showPregCalItem(BuildContext context, PregnancyController p,
    PregCalItem item, {bool readOnly = false}) async {
  if (item.check != null) {
    return showPregCalCheck(context, p, item.check!, readOnly: readOnly);
  }
  final a = item.appointment;
  final week = pregWeekOf(p.dueDate, item.date);
  final whenLine = [
    '${pregDayLabel(item.date)} ${item.date.year}',
    if (a != null && a.time.trim().isNotEmpty) a.time.trim(),
    if (week >= 1 && week <= 42) 'week $week',
  ].join(' · ');
  final action = await showPregCalSheet<String>(
    context,
    (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        pregCalMark(item.kind, size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, style: pregCalSerif(21)),
            const SizedBox(height: 2),
            Text('${item.meta.label}${item.done ? ' · Done' : ''}',
                style: pregCalBody(size: 13, weight: FontWeight.w600, color: pvStorePalette.ink3)),
          ]),
        ),
      ]),
      const SizedBox(height: 10),
      _kv(Icons.calendar_today_rounded, 'When', whenLine, first: true),
      if (a != null && a.location.trim().isNotEmpty)
        _kv(Icons.place_outlined, 'Where', a.location.trim()),
      if (a != null && a.doctor.trim().isNotEmpty)
        _kv(Icons.person_outline_rounded, 'With', a.doctor.trim()),
      if (a != null && a.notes.trim().isNotEmpty)
        _kv(Icons.notes_rounded, 'Notes', a.notes.trim()),
      if (a == null && item.detail.trim().isNotEmpty)
        _kv(Icons.notes_rounded,
            item.kind == PregCalKind.weight ? 'Reading' : 'Details', item.detail.trim()),
      const SizedBox(height: 14),
      if (readOnly || !item.ownedByHer)
        _readOnlyLine(readOnly
            ? 'Only she can change this.'
            : 'Added by your partner, so it is changed from their phone.')
      else
        Wrap(spacing: 8, runSpacing: 8, children: _actionsFor(ctx, item)),
    ]),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case 'edit_appt':
      final saved = await showPregAppointmentSheet(context, editing: a);
      if (saved != null && context.mounted) {
        pvToast(context,
            'Saved. ${saved.title} is on ${pregDayLabel(saved.date)}.'
            '${AppointmentReminders.instance.bookingLine(saved)}',
            kind: PvToastKind.done);
      }
    case 'delete_appt':
      await ScansStore.instance.deleteAppointment(a!.id);
      if (context.mounted) pvToast(context, '${a.title} removed', kind: PvToastKind.done);
    case 'edit_note':
      await showPregCalNote(context, day: item.date, editing: item.note);
    case 'delete_note':
      await CalendarStore.instance.deletePersonal(item.note!.id);
      if (context.mounted) pvToast(context, 'Note removed', kind: PvToastKind.done);
    case 'scans':
      pregCalOpenScans(context, p);
    case 'weight':
      pregCalOpenWeight(context, p);
    case 'kicks':
      pregCalOpenKicks(context, p);
    case 'symptoms':
      pregCalOpenSymptoms(context, p);
    case 'journal':
      pregCalOpenJournal(context, p);
  }
}

List<Widget> _actionsFor(BuildContext ctx, PregCalItem item) {
  void go(String a) => Navigator.pop(ctx, a);
  return switch (item.kind) {
    PregCalKind.appointment => [
        PregCalPill(label: 'Edit', ink: true, icon: Icons.edit_outlined, onTap: () => go('edit_appt')),
        PregCalPill(label: 'Open Scans', onTap: () => go('scans')),
        PregCalPill(label: 'Delete', icon: Icons.delete_outline_rounded, onTap: () => go('delete_appt')),
      ],
    PregCalKind.note => [
        PregCalPill(label: 'Edit', ink: true, icon: Icons.edit_outlined, onTap: () => go('edit_note')),
        PregCalPill(label: 'Delete', icon: Icons.delete_outline_rounded, onTap: () => go('delete_note')),
      ],
    PregCalKind.weight => [
        PregCalPill(label: 'Open weight chart', ink: true, onTap: () => go('weight'))
      ],
    PregCalKind.kicks => [
        PregCalPill(label: 'Open kick counter', ink: true, onTap: () => go('kicks'))
      ],
    PregCalKind.symptom => [
        PregCalPill(label: 'Open Symptoms', ink: true, onTap: () => go('symptoms'))
      ],
    PregCalKind.journal => [
        PregCalPill(label: 'Open Journal', ink: true, onTap: () => go('journal'))
      ],
    PregCalKind.check => [
        PregCalPill(label: 'Open Scans', ink: true, onTap: () => go('scans'))
      ],
  };
}

Widget _kv(IconData icon, String label, String value, {bool first = false}) =>
    Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          border: first ? null : const Border(top: BorderSide(color: kPvLine))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: pvStorePalette.ink3),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: pregCalBody(size: 12, weight: FontWeight.w700, color: pvStorePalette.ink3)),
            const SizedBox(height: 1),
            Text(value, style: pregCalBody(size: 14)),
          ]),
        ),
      ]),
    );

Widget _readOnlyLine(String text) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: kPregCalTint, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(Icons.visibility_outlined, size: 16, color: pvStorePalette.ink2),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: pregCalBody(size: 13, color: pvStorePalette.ink2))),
      ]),
    );

/// The line his read-only calendar opens with.
Widget pregCalReadOnlyBanner() =>
    _readOnlyLine('Shared from her calendar. She adds and changes things.');

// ---------------------------------------------------------------------------
//  A usual check
// ---------------------------------------------------------------------------

/// "13 Nov to 17 Dec": the days a check's window covers for her due date.
String pregCheckDates(PregCheck c, DateTime due) =>
    '${pregShortDate(pregWeekStart(due, c.fromWeek))} to '
    '${pregShortDate(pregWeekStart(due, c.toWeek + 1).subtract(const Duration(days: 1)))}';

Future<void> showPregCalCheck(
    BuildContext context, PregnancyController p, PregCheck c,
    {bool readOnly = false}) async {
  final st = pregCheckStatus(c);
  final hasWeeks = c.windowLabel.startsWith('Around');
  final action = await showPregCalSheet<String>(
    context,
    (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        pregCalMark(PregCalKind.check, size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.title, style: pregCalSerif(21)),
            const SizedBox(height: 2),
            Text(
                hasWeeks
                    ? '${c.windowLabel} · ${pregCheckDates(c, p.dueDate)}'
                    : c.windowLabel,
                style: pregCalBody(size: 13, weight: FontWeight.w600, color: pvStorePalette.ink3)),
          ]),
        ),
      ]),
      const SizedBox(height: 14),
      if (c.about.isNotEmpty) Text(c.about, style: pregCalBody(size: 14.5, height: 1.5)),
      if (c.timing.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(c.timing, style: pregCalBody(size: 14, height: 1.5, color: pvStorePalette.ink2)),
      ],
      const SizedBox(height: 10),
      Text(
        switch (st.state) {
          PregCheckState.done => 'Marked done on ${pregShortDate(st.date ?? DateTime.now())}.',
          PregCheckState.booked => 'Booked for ${pregDayLabel(st.date!)}.',
          PregCheckState.open => 'Your doctor sets the real date. Add it here once it is booked.',
        },
        style: pregCalBody(size: 12.5, color: pvStorePalette.ink3, height: 1.45),
      ),
      const SizedBox(height: 14),
      Wrap(spacing: 8, runSpacing: 8, children: [
        if (!readOnly && st.state == PregCheckState.open)
          PregCalPill(
              label: 'Add as appointment',
              ink: true,
              icon: Icons.event_outlined,
              onTap: () => Navigator.pop(ctx, 'book')),
        PregCalPill(
            label: 'Open week ${c.fromWeek}', onTap: () => Navigator.pop(ctx, 'week')),
      ]),
    ]),
  );
  if (action == null || !context.mounted) return;
  if (action == 'week') pregCalOpenWeek(context, p, c.fromWeek);
  if (action == 'book') await pregCalBookCheck(context, p, c);
}

/// "Add as appointment": the appointment form, with the check's name and type
/// and the first day of its window (or three days from today when the window
/// is already open). She sets the real date.
Future<void> pregCalBookCheck(
    BuildContext context, PregnancyController p, PregCheck c, {DateTime? today}) async {
  final t = pregDayOnly(today ?? DateTime.now());
  final start = pregWeekStart(p.dueDate, c.fromWeek);
  final initial = start.isAfter(t) ? start : t.add(const Duration(days: 3));
  final lower = c.title.toLowerCase();
  final type = lower.contains('injection')
      ? ApptType.vaccination
      : (lower.contains('test') ? ApptType.test : ApptType.scan);
  final a = await showPregAppointmentSheet(context,
      initial: initial, title: c.title, type: type);
  if (a != null && context.mounted) {
    pvToast(context,
        '${a.title} booked for ${pregDayLabel(a.date)}.${AppointmentReminders.instance.bookingLine(a)}',
        kind: PvToastKind.done);
  }
}
