// =============================================================================
//  Availability — seven rows, one switch, and a preview that cannot lie
// -----------------------------------------------------------------------------
//  OpenPhone's business hours and Swarm's hours page (Mobbin audit #8): a
//  clinician reads a WEEK as seven lines — "Monday · 10:00 am–1:00 pm,
//  5:00–8:00 pm" — not as a grid of chips. So:
//
//     [Taking bookings]  switch, the one thing they change most
//     Monday …  Sunday   seven rows; tap one → a sheet for that day
//     Same hours on every working day       one tap, the common case
//     Consultation rules                    → its own screen; the exceptions
//     Time off                              a list, and Add
//     What parents will see                 the live preview, always
//
//  THE MODEL DOES NOT CHANGE. doctor_schedule.dart (sessions per weekday,
//  rules, time off, overrides, pause) and DoctorScheduleStore (saves to
//  `doctor_schedule`, which the parent side reads) are exactly as before —
//  the preview calls the same generateSlots() the booking path calls, so a
//  toggle here has a visible consequence rather than being an act of faith.
//  The previous screen (doctor_schedule_screen.dart) is kept for revert.
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_schedule.dart';
import '../../doctor/doctor_schedule_store.dart';
import '../../doctor/doctor_session.dart';
import 'doctor_chrome.dart';

const _dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

class DoctorAvailabilityTab extends StatelessWidget {
  const DoctorAvailabilityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([DoctorSession.instance, DoctorScheduleStore.instance]),
      builder: (context, _) {
        final id = DoctorSession.instance.expertId;
        if (id == null || id.isEmpty) {
          return const DcTab(title: 'Availability', children: [
            DcEmpty('No consulting identity', 'An organisation account has no hours of its own; each clinician sets theirs.', icon: Icons.schedule_outlined),
          ]);
        }
        final store = DoctorScheduleStore.instance;
        final s = store.scheduleFor(id);
        void save(DoctorSchedule next) => store.save(id, next);
        final p = dcP;

        return DcTab(
          title: 'Availability',
          subtitle: s.paused ? 'Paused — parents see no slots' : 'Parents book inside these hours',
          children: [
            DcRowGroup(children: [
              DcSwitchRow(
                icon: s.paused ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                title: 'Taking bookings',
                subtitle: s.paused ? 'Off. Existing bookings stand.' : 'On',
                value: !s.paused,
                onChanged: (on) {
                  save(s.copyWith(paused: !on));
                  dcToast(context, on ? 'Taking bookings again.' : 'Paused. Existing bookings stand.');
                },
              ),
            ]),
            const SizedBox(height: 22),

            const DcSectionHead('Your week', title: 'Which days, which hours'),
            DcRowGroup(children: [
              for (var d = 1; d <= 7; d++)
                DcRow(
                  title: _dayNames[d - 1],
                  trailing: Text(
                    _hoursLine(s.dayFor(d)),
                    textAlign: TextAlign.right,
                    style: dcBody(14, color: s.dayFor(d).isWorking ? p.ink1 : p.ink3, w: FontWeight.w600),
                  ),
                  onTap: () => _editDay(context, id, d),
                ),
            ]),
            const SizedBox(height: 10),
            DcRowGroup(children: [
              DcRow(
                icon: Icons.copy_all_outlined,
                title: 'Same hours on every working day',
                subtitle: 'Copies ${_firstWorkingDayName(s)}\'s hours to the others.',
                onTap: !s.hasAnyHours ? null : () => _copyHours(context, id),
                chevron: false,
              ),
            ]),
            const SizedBox(height: 22),

            const DcSectionHead('Rules'),
            DcRowGroup(children: [
              DcRow(
                icon: Icons.tune_rounded,
                title: 'Consultation rules',
                subtitle: '${s.rules.slotMinutes} min each · ${s.rules.bufferAfterMin} min gap · up to ${s.rules.maxPerDay} a day · ${_notice(s.rules.minNoticeMinutes)} notice',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'doctor/rules'),
                    builder: (_) => DoctorRulesScreen(expertId: id))),
              ),
            ]),
            const SizedBox(height: 22),

            DcSectionHead('Time off', note: 'Add', onNote: () => _addTimeOff(context, id)),
            if (s.timeOff.isEmpty)
              DcEmpty(
                'No time off booked',
                'Holidays, leave, or a day you simply cannot take. Your week runs as set.',
                icon: Icons.beach_access_outlined,
                action: 'Add time off',
                onAction: () => _addTimeOff(context, id),
              )
            else
              DcRowGroup(children: [
                for (var i = 0; i < s.timeOff.length; i++)
                  DcRow(
                    icon: Icons.beach_access_outlined,
                    title: _timeOffLine(s.timeOff[i]),
                    subtitle: s.timeOff[i].reason.isEmpty ? null : s.timeOff[i].reason,
                    chevron: false,
                    trailing: IconButton(
                      onPressed: () {
                        final next = [...s.timeOff]..removeAt(i);
                        save(s.copyWith(timeOff: next));
                        dcToast(context, 'Time off removed.');
                      },
                      icon: Icon(Icons.close_rounded, color: p.ink3),
                      tooltip: 'Remove',
                    ),
                  ),
              ]),
            const SizedBox(height: 22),

            const DcSectionHead('What parents will see'),
            _Preview(expertId: id),
          ],
        );
      },
    );
  }

  static String _hoursLine(DaySchedule d) => d.isWorking
      ? d.sessions.map((x) => '${hhmm(x.start)}–${hhmm(x.end)}').join('\n')
      : 'Closed';

  static String _firstWorkingDayName(DoctorSchedule s) {
    for (var d = 1; d <= 7; d++) {
      if (s.dayFor(d).isWorking) return _dayNames[d - 1];
    }
    return 'Monday';
  }

  static String _notice(int minutes) => minutes >= 1440
      ? '${minutes ~/ 1440} day'
      : minutes >= 60
          ? '${minutes ~/ 60} hr'
          : '$minutes min';

  static String _timeOffLine(TimeOff t) {
    final same = t.fromDate.year == t.toDate.year && t.fromDate.month == t.toDate.month && t.fromDate.day == t.toDate.day;
    return same ? dcDayDate(t.fromDate) : '${dcDate(t.fromDate)} – ${dcDate(t.toDate, year: true)}';
  }

  void _copyHours(BuildContext context, String id) {
    final store = DoctorScheduleStore.instance;
    final s = store.scheduleFor(id);
    DaySchedule? first;
    for (var d = 1; d <= 7; d++) {
      if (s.dayFor(d).isWorking) {
        first = s.dayFor(d);
        break;
      }
    }
    if (first == null) return;
    final next = {for (var d = 1; d <= 7; d++) d: s.dayFor(d).isWorking ? first : s.dayFor(d)};
    store.save(id, s.copyWith(byWeekday: next));
    dcToast(context, 'Every working day now runs ${_hoursLine(first).replaceAll('\n', ', ')}.');
  }

  Future<void> _editDay(BuildContext context, String id, int weekday) async {
    await dcSheet<void>(
      context,
      title: _dayNames[weekday - 1],
      child: _DaySheet(expertId: id, weekday: weekday),
    );
  }

  Future<void> _addTimeOff(BuildContext context, String id) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: 'Time off',
      saveText: 'Add',
    );
    if (range == null || !context.mounted) return;
    final reason = TextEditingController();
    final add = await dcSheet<bool>(
      context,
      title: 'Time off',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          range.start == range.end
              ? dcDayDate(range.start)
              : '${dcDate(range.start)} – ${dcDate(range.end, year: true)}',
          style: dcStrong(16),
        ),
        const SizedBox(height: 14),
        DcInput(label: 'Reason (optional, only you see it)', controller: reason, hint: 'Conference, leave…'),
        const SizedBox(height: 18),
        ObPrimary(p: dcP, label: 'Add time off', onTap: () => Navigator.of(context).pop(true)),
      ]),
    );
    if (add != true || !context.mounted) return;
    final store = DoctorScheduleStore.instance;
    final s = store.scheduleFor(id);
    store.save(id, s.copyWith(timeOff: [...s.timeOff, TimeOff(fromDate: range.start, toDate: range.end, reason: reason.text.trim())]));
    dcToast(context, 'Time off added. Those days show no slots.');
  }
}

/// One day's sessions: a working switch, each session as a row with its two
/// times, Add and Remove. Saves on every change, so closing the sheet is
/// never a lost edit.
class _DaySheet extends StatefulWidget {
  const _DaySheet({required this.expertId, required this.weekday});
  final String expertId;
  final int weekday;

  @override
  State<_DaySheet> createState() => _DaySheetState();
}

class _DaySheetState extends State<_DaySheet> {
  DoctorScheduleStore get _store => DoctorScheduleStore.instance;
  DoctorSchedule get _s => _store.scheduleFor(widget.expertId);
  DaySchedule get _day => _s.dayFor(widget.weekday);

  void _put(List<Session> sessions) {
    final next = Map<int, DaySchedule>.from(_s.byWeekday)..[widget.weekday] = DaySchedule(sessions);
    _store.save(widget.expertId, _s.copyWith(byWeekday: next));
    setState(() {});
  }

  Future<void> _pick(int i, bool start) async {
    final ses = _day.sessions[i];
    final cur = start ? ses.start : ses.end;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (cur ~/ 60) % 24, minute: cur % 60),
      helpText: start ? 'Session starts' : 'Session ends',
    );
    if (t == null) return;
    final m = t.hour * 60 + t.minute;
    var next = start ? Session(m, ses.end) : Session(ses.start, m);
    if (!next.isValid) {
      // An end before its start means they meant the next morning — a night
      // clinic — only when it is plausibly short; otherwise refuse quietly.
      if (!start && m < ses.start && (m + 1440 - ses.start) <= 8 * 60) {
        next = Session(ses.start, m + 1440);
      } else {
        if (mounted) dcToast(context, 'The end has to come after the start.');
        return;
      }
    }
    final list = [..._day.sessions]..[i] = next;
    _put(list);
  }

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final day = _day;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DcRowGroup(children: [
        DcSwitchRow(
          title: day.isWorking ? 'Working' : 'Closed all day',
          value: day.isWorking,
          onChanged: (on) => _put(on ? const [Session(10 * 60, 13 * 60)] : const []),
        ),
      ]),
      if (day.isWorking) ...[
        const SizedBox(height: 16),
        const DcSectionHead('Sessions'),
        DcRowGroup(children: [
          for (var i = 0; i < day.sessions.length; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(children: [
                _timeChip(hhmm(day.sessions[i].start), () => _pick(i, true)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('to', style: dcMeta(14))),
                _timeChip(hhmm(day.sessions[i].end), () => _pick(i, false)),
                const Spacer(),
                IconButton(
                  onPressed: day.sessions.length == 1
                      ? null
                      : () => _put([...day.sessions]..removeAt(i)),
                  icon: Icon(Icons.close_rounded, color: day.sessions.length == 1 ? p.line : p.ink3),
                  tooltip: 'Remove session',
                ),
              ]),
            ),
          DcRow(
            icon: Icons.add_rounded,
            title: 'Add a session',
            subtitle: 'Most clinics run a morning and an evening.',
            chevron: false,
            onTap: () {
              final last = day.sessions.last;
              final start = (last.end + 4 * 60).clamp(0, 23 * 60);
              _put([...day.sessions, Session(start, (start + 3 * 60).clamp(0, 1440))]);
            },
          ),
        ]),
      ],
      const SizedBox(height: 16),
      Text('Saved as you go. Parents see the change on their next visit.', style: dcMeta(12.5, color: p.ink3)),
    ]);
  }

  Widget _timeChip(String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dcP.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label, style: dcStrong(15)),
        ),
      );
}

/// The exceptions, on their own screen. Chips for the values a clinic
/// actually picks from; a stepper for the one that is a count.
class DoctorRulesScreen extends StatelessWidget {
  const DoctorRulesScreen({super.key, required this.expertId});
  final String expertId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DoctorScheduleStore.instance,
      builder: (context, _) {
        final store = DoctorScheduleStore.instance;
        final s = store.scheduleFor(expertId);
        final r = s.rules;
        void put(ConsultRules next) => store.save(expertId, s.copyWith(rules: next));

        return DcScreen(
          title: 'Consultation rules',
          subtitle: 'How your hours become slots',
          children: [
            _choice('How long is one consultation?', [15, 20, 30, 45, 60], r.slotMinutes, (v) => put(r.copyWith(slotMinutes: v)), unit: 'min'),
            const SizedBox(height: 20),
            _choice('Gap after each one', [0, 5, 10, 15], r.bufferAfterMin, (v) => put(r.copyWith(bufferAfterMin: v)), unit: 'min'),
            const SizedBox(height: 20),
            _choice('How much notice do you need?', [60, 120, 360, 1440], r.minNoticeMinutes, (v) => put(r.copyWith(minNoticeMinutes: v)),
                labels: const ['1 hr', '2 hr', '6 hr', '1 day']),
            const SizedBox(height: 20),
            _choice('How far ahead can parents book?', [7, 14, 30, 60], r.advanceWindowDays, (v) => put(r.copyWith(advanceWindowDays: v)), unit: 'days'),
            const SizedBox(height: 20),
            DcCard(
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Most consultations in a day', style: dcStrong(15.5)),
                    const SizedBox(height: 3),
                    Text('A ceiling, whatever the hours allow.', style: dcMeta(13)),
                  ]),
                ),
                _round(Icons.remove_rounded, r.maxPerDay <= 1 ? null : () => put(r.copyWith(maxPerDay: r.maxPerDay - 1))),
                SizedBox(width: 44, child: Text('${r.maxPerDay}', textAlign: TextAlign.center, style: dcNum(20))),
                _round(Icons.add_rounded, r.maxPerDay >= 30 ? null : () => put(r.copyWith(maxPerDay: r.maxPerDay + 1))),
              ]),
            ),
            const SizedBox(height: 20),
            DcRowGroup(children: [
              DcSwitchRow(
                title: 'Confirm bookings automatically',
                subtitle: 'Off means each booking waits for your yes.',
                value: r.autoConfirm,
                onChanged: (v) => put(r.copyWith(autoConfirm: v)),
              ),
            ]),
            const SizedBox(height: 22),
            const DcSectionHead('What parents will see'),
            _Preview(expertId: expertId),
          ],
        );
      },
    );
  }

  Widget _choice(String title, List<int> values, int current, ValueChanged<int> onPick, {String? unit, List<String>? labels}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: dcStrong(15.5)),
        const SizedBox(height: 10),
        DcSegments(
          labels: [for (var i = 0; i < values.length; i++) labels != null ? labels[i] : '${values[i]}${unit != null ? ' $unit' : ''}'],
          index: values.indexOf(current).clamp(0, values.length - 1),
          onChanged: (i) => onPick(values[i]),
        ),
      ]);

  Widget _round(IconData icon, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: onTap == null ? dcP.line : dcP.ink1, width: 1.2),
          ),
          child: Icon(icon, size: 20, color: onTap == null ? dcP.ink3 : dcP.ink1),
        ),
      );
}

/// The live preview: the real slots a parent would be offered over the next
/// week, from the same generator the booking path uses.
class _Preview extends StatelessWidget {
  const _Preview({required this.expertId});
  final String expertId;

  @override
  Widget build(BuildContext context) {
    final store = DoctorScheduleStore.instance;
    final s = store.scheduleFor(expertId);
    final slots = store.preview(expertId, days: 7);
    final byDay = groupByDay(slots);
    final days = byDay.keys.toList()..sort();
    final p = dcP;
    return DcCard(
      tint: p.surfaceAlt,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.visibility_outlined, size: 18, color: p.ink2),
          const SizedBox(width: 8),
          Expanded(child: Text('Next 7 days', style: dcStrong(14.5))),
          Text('${slots.length} slots', style: dcMeta(13)),
        ]),
        const SizedBox(height: 12),
        if (slots.isEmpty)
          Text(
            s.paused
                ? 'You are paused, so nothing is bookable right now.'
                : 'Nothing is bookable yet. Turn a day on and give it hours.',
            style: dcBody(14),
          )
        else
          for (final d in days.take(4)) ...[
            Row(children: [
              Text(dcDayDate(d), style: dcStrong(13.5)),
              const Spacer(),
              Text('${byDay[d]!.length}', style: dcMeta(12.5)),
            ]),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final g in byDay[d]!.take(8))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.line)),
                  child: Text(hhmm(g.start.hour * 60 + g.start.minute), style: dcMeta(12, color: p.ink1)),
                ),
              if (byDay[d]!.length > 8) Text('+${byDay[d]!.length - 8}', style: dcMeta(12)),
            ]),
            const SizedBox(height: 10),
          ],
      ]),
    );
  }
}
