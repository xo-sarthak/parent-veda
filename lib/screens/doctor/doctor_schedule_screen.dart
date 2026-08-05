// =============================================================================
//  Availability — the doctor's most important screen
// -----------------------------------------------------------------------------
//  Replaces the old 7x6 grid of six HARDCODED times, in which a doctor working
//  10:30-13:00 could not describe their own day.
//
//  The UX rule, taken from how practice software gets this right: ONE screen for
//  the ordinary case, progressive disclosure for the exceptions. A doctor whose
//  week is "Mon-Sat, morning and evening clinic" should be done in under a
//  minute and never see a per-day editor. A doctor with a different Wednesday
//  flips one switch and gets it.
//
//  Three sections, in the order a doctor actually thinks:
//     Week    - which days, which hours
//     Rules   - how long, what gaps, how many
//     Time off - when I am away
//
//  A LIVE PREVIEW sits under all three, always, showing the real slots a parent
//  would be offered. It calls the same generateSlots() the parent side calls,
//  so it cannot drift from reality - and it means every toggle has a visible
//  consequence instead of being an act of faith.
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_schedule.dart';
import '../../doctor/doctor_schedule_store.dart';
import '../../doctor/doctor_session.dart';
import '../post_pregnancy/pp_common.dart';

const _dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Month names, so a slot reads "Mon 3 Aug" rather than "Mon 3/8".
///
/// d/m is unambiguous only if you already know the convention, and the two
/// readings of 3/8 are five months apart. On a clinical schedule that is not
/// a style question - a doctor scanning for a clinic day should never have to
/// work out which half is the month.
const _monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
    'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _dayMonth(DateTime x) => '${x.day} ${_monthNames[x.month]}';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  final _store = DoctorScheduleStore.instance;
  int _tab = 0; // 0 Week · 1 Rules · 2 Time off
  bool _perDay = false;

  String get _expertId => DoctorSession.instance.expertId ?? '';
  DoctorSchedule get _s => _store.scheduleFor(_expertId);

  @override
  void initState() {
    super.initState();
    _store.init().then((_) {
      if (!mounted) return;
      // Open the per-day editor automatically if the saved week already varies -
      // hiding it would make their own schedule uneditable.
      setState(() => _perDay = _hoursVary(_s));
    });
  }

  static bool _hoursVary(DoctorSchedule s) {
    final working = [
      for (var d = DateTime.monday; d <= DateTime.sunday; d++)
        if (s.dayFor(d).isWorking) d
    ];
    if (working.length < 2) return false;
    final first = s.dayFor(working.first).sessions.toString();
    return working.any((d) => s.dayFor(d).sessions.toString() != first);
  }

  void _update(DoctorSchedule next) {
    _store.save(_expertId, next);
    setState(() {});
  }

  // ---- section: week --------------------------------------------------------

  void _toggleDay(int weekday) {
    final map = Map<int, DaySchedule>.from(_s.byWeekday);
    final day = _s.dayFor(weekday);
    if (day.isWorking) {
      map[weekday] = const DaySchedule.off();
    } else {
      // Turning a day ON copies the pattern from an existing working day, so a
      // doctor never has to retype hours they have already entered.
      final template = _s.byWeekday.values.firstWhere((d) => d.isWorking,
          orElse: () => const DaySchedule([Session(600, 780)]));
      map[weekday] = DaySchedule(List.of(template.sessions));
    }
    _update(_s.copyWith(byWeekday: map));
  }

  Future<void> _editSession(int weekday, int index) async {
    final day = _s.dayFor(weekday);
    final existing = index < day.sessions.length ? day.sessions[index] : null;
    final result = await _pickRange(existing);
    if (result == null) return;
    final sessions = List<Session>.from(day.sessions);
    if (index < sessions.length) {
      sessions[index] = result;
    } else {
      sessions.add(result);
    }
    sessions.sort((a, b) => a.start.compareTo(b.start));

    // A session that runs past midnight lands in the NEXT day's hours, where
    // Session.overlaps cannot see it — that comparison works on one day's axis
    // and these are two. Refused rather than merged: a doctor who is booked
    // 11 PM-2 AM and again from 1 AM has described two consults at once, and
    // silently trimming one of them decides something that is theirs to decide.
    //
    // In "same hours every day" mode the next day carries the same sessions,
    // so this also catches a nightly session that would collide with itself.
    final nextDay = _perDay
        ? _s.dayFor(weekday == DateTime.sunday ? DateTime.monday : weekday + 1)
        : DaySchedule(sessions);
    final clash = sessions.where((s) => spillsInto(s, nextDay)).firstOrNull;
    if (clash != null) {
      _toast('${clash.toString()} runs into the next day\'s hours.');
      return;
    }

    _applyDay(weekday, DaySchedule(sessions));
  }

  void _removeSession(int weekday, int index) {
    final sessions = List<Session>.from(_s.dayFor(weekday).sessions);
    if (index >= sessions.length) return;
    sessions.removeAt(index);
    _applyDay(weekday, DaySchedule(sessions));
  }

  /// In "same hours every day" mode an edit applies to EVERY working day —
  /// that is the whole point of the mode.
  void _applyDay(int weekday, DaySchedule day) {
    final map = Map<int, DaySchedule>.from(_s.byWeekday);
    if (_perDay) {
      map[weekday] = day;
    } else {
      for (var d = DateTime.monday; d <= DateTime.sunday; d++) {
        if (_s.dayFor(d).isWorking) map[d] = DaySchedule(List.of(day.sessions));
      }
    }
    _update(_s.copyWith(byWeekday: map));
  }

  Future<Session?> _pickRange(Session? initial) async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: (initial?.start ?? 600) ~/ 60, minute: (initial?.start ?? 600) % 60),
      helpText: 'Session starts',
    );
    if (start == null || !mounted) return null;
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: (initial?.end ?? 780) ~/ 60, minute: (initial?.end ?? 780) % 60),
      helpText: 'Session ends',
    );
    if (end == null) return null;

    final startMin = start.hour * 60 + start.minute;
    var endMin = end.hour * 60 + end.minute;

    // AN END BEFORE THE START MEANS TOMORROW, NOT A MISTAKE.
    //
    // A doctor picking 11:00 PM to 1:00 AM used to be told "that session ends
    // before it starts", because 60 really is less than 1380 on one day's
    // clock. But nobody schedules a session backwards — there is no other
    // thing they could have meant. So the only reading that makes sense is the
    // one the clock gives you when you keep going: 1:00 AM is minute 1500.
    //
    // EQUAL is still refused, and that one is genuinely ambiguous: 11 PM to
    // 11 PM is either a zero-length session or a twenty-four hour one, and
    // guessing between them is worse than asking again.
    if (endMin < startMin) endMin += 1440;

    final s = Session(startMin, endMin);
    if (!s.isValid) {
      if (mounted) {
        _toast(endMin == startMin
            ? 'Start and end are the same time.'
            : 'That session is not a valid stretch of time.');
      }
      return null;
    }
    return s;
  }

  void _toast(String m) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(m)));

  // ---- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        if (!_store.isLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _header(),
            const SizedBox(height: 16),
            _tabs(),
            const SizedBox(height: 18),
            switch (_tab) {
              0 => _weekSection(),
              1 => _rulesSection(),
              _ => _timeOffSection(),
            },
            const SizedBox(height: 26),
            _preview(),
          ],
        );
      },
    );
  }

  Widget _header() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ppEyebrow('YOUR AVAILABILITY', color: ppPurple),
        const SizedBox(height: 8),
        Text(describeWeek(_s), style: ppFraunces(24, h: 1.15)),
        const SizedBox(height: 6),
        Text(
          _s.paused
              ? 'Paused — parents cannot book anything new.'
              : 'This is what parents can book. Change anything and the preview below updates.',
          style: ppBody(13, h: 1.5),
        ),
        const SizedBox(height: 14),
        _pauseCard(),
      ]);

  Widget _pauseCard() => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: _s.paused ? ppCoralTint : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _s.paused ? ppCoral : ppBorder),
        ),
        child: Row(children: [
          Icon(_s.paused ? Icons.pause_circle_filled_rounded : Icons.play_circle_outline_rounded,
              size: 20, color: _s.paused ? ppCoral : ppPurple),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_s.paused ? 'Not taking bookings' : 'Taking bookings',
                  style: ppJakarta(14)),
              const SizedBox(height: 2),
              Text(
                  _s.paused
                      ? 'Your hours are saved. Turn this back on when you are ready.'
                      : 'Pause to stop new bookings without losing your hours.',
                  style: ppBody(11.5, h: 1.4)),
            ]),
          ),
          Switch(
            value: !_s.paused,
            activeTrackColor: ppPurple,
            activeThumbColor: Colors.white,
            onChanged: (v) => _update(_s.copyWith(paused: !v)),
          ),
        ]),
      );

  Widget _tabs() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: ppPanel, borderRadius: BorderRadius.circular(13)),
        child: Row(children: [
          for (final (i, label) in [(0, 'Week'), (1, 'Rules'), (2, 'Time off')])
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _tab == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(label,
                      style: ppJakarta(13.5,
                          color: _tab == i ? ppTitleInk : ppSoft)),
                ),
              ),
            ),
        ]),
      );

  // ---- week -----------------------------------------------------------------

  Widget _weekSection() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Working days', style: ppJakarta(15)),
        const SizedBox(height: 4),
        Text('Tap a day to turn it on or off.', style: ppBody(12)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var d = DateTime.monday; d <= DateTime.sunday; d++)
              _dayChip(d),
          ],
        ),
        const SizedBox(height: 20),
        // The progressive-disclosure switch: the simple case never sees a
        // per-day editor at all.
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: ppBorder)),
          child: Row(children: [
            Expanded(
              child: Text('Hours differ by day', style: ppJakarta(13.5)),
            ),
            Switch(
              value: _perDay,
              activeTrackColor: ppPurple,
            activeThumbColor: Colors.white,
              onChanged: (v) => setState(() => _perDay = v),
            ),
          ]),
        ),
        const SizedBox(height: 18),
        if (_perDay)
          for (var d = DateTime.monday; d <= DateTime.sunday; d++)
            if (_s.dayFor(d).isWorking) _dayEditor(d, showName: true)
          else
            const SizedBox.shrink()
        else ...[
          Text('Hours', style: ppJakarta(15)),
          const SizedBox(height: 4),
          Text('Applies to every working day. Most clinics run two sessions.',
              style: ppBody(12)),
          const SizedBox(height: 12),
          _dayEditor(_firstWorkingDay(), showName: false),
        ],
      ]);

  int _firstWorkingDay() {
    for (var d = DateTime.monday; d <= DateTime.sunday; d++) {
      if (_s.dayFor(d).isWorking) return d;
    }
    return DateTime.monday;
  }

  Widget _dayChip(int d) {
    final on = _s.dayFor(d).isWorking;
    return GestureDetector(
      onTap: () => _toggleDay(d),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? ppPurple : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: on ? ppPurple : ppBorder),
        ),
        child: Text(_dayNames[d],
            style: ppJakarta(12, color: on ? Colors.white : ppSoft)),
      ),
    );
  }

  /// Derived from the session's own start time, not its index — a third
  /// session would otherwise be labelled "Evening" whatever time it ran.
  static String _partOfDay(Session s) {
    if (s.start < 12 * 60) return 'Morning';
    if (s.start < 17 * 60) return 'Afternoon';
    return 'Evening';
  }

  Widget _dayEditor(int weekday, {required bool showName}) {
    final day = _s.dayFor(weekday);
    if (!day.isWorking) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ppBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (showName) ...[
            Text(_dayNames[weekday], style: ppJakarta(13.5)),
            const SizedBox(height: 9),
          ],
          for (var i = 0; i < day.sessions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _editSession(weekday, i),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                          color: ppPanel, borderRadius: BorderRadius.circular(11)),
                      child: Row(children: [
                        const Icon(Icons.schedule_rounded, size: 15, color: ppPurple),
                        const SizedBox(width: 9),
                        // Flexible + ellipsis: "10:00 AM-1:00 PM" plus the part
                        // label is wider than the card on a small phone.
                        Flexible(
                          child: Text(day.sessions[i].toString(),
                              style: ppJakarta(13),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text(_partOfDay(day.sessions[i]),
                            style: ppBody(11, color: ppMuted)),
                      ]),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeSession(weekday, i),
                  icon: const Icon(Icons.close_rounded, size: 17, color: ppMuted),
                  tooltip: 'Remove session',
                ),
              ]),
            ),
          if (day.sessions.length < 3)
            GestureDetector(
              onTap: () => _editSession(weekday, day.sessions.length),
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                const Icon(Icons.add_rounded, size: 16, color: ppPurple),
                const SizedBox(width: 6),
                Text('Add a session', style: ppJakarta(12.5, color: ppPurple)),
              ]),
            ),
        ]),
      ),
    );
  }

  // ---- rules ----------------------------------------------------------------

  Widget _rulesSection() {
    final r = _s.rules;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('How long is one consultation?', style: ppJakarta(15)),
      const SizedBox(height: 10),
      Wrap(spacing: 9, runSpacing: 9, children: [
        for (final m in [15, 20, 30, 45, 60])
          _chip('$m min', r.slotMinutes == m,
              () => _update(_s.copyWith(rules: r.copyWith(slotMinutes: m)))),
      ]),
      const SizedBox(height: 22),
      _stepper('Gap after each consultation', '${r.bufferAfterMin} min',
          onMinus: r.bufferAfterMin >= 5
              ? () => _update(_s.copyWith(
                  rules: r.copyWith(bufferAfterMin: r.bufferAfterMin - 5)))
              : null,
          onPlus: r.bufferAfterMin < 30
              ? () => _update(_s.copyWith(
                  rules: r.copyWith(bufferAfterMin: r.bufferAfterMin + 5)))
              : null,
          hint: 'Time to write notes before the next parent.'),
      _stepper('Most consultations in a day', '${r.maxPerDay}',
          onMinus: r.maxPerDay > 1
              ? () => _update(
                  _s.copyWith(rules: r.copyWith(maxPerDay: r.maxPerDay - 1)))
              : null,
          onPlus: r.maxPerDay < 30
              ? () => _update(
                  _s.copyWith(rules: r.copyWith(maxPerDay: r.maxPerDay + 1)))
              : null,
          hint: 'A hard stop, however much free time is left.'),
      _stepper('Most back-to-back in a row', '${r.maxConsecutive}',
          onMinus: r.maxConsecutive > 0
              ? () => _update(_s.copyWith(
                  rules: r.copyWith(maxConsecutive: r.maxConsecutive - 1)))
              : null,
          onPlus: r.maxConsecutive < 12
              ? () => _update(_s.copyWith(
                  rules: r.copyWith(maxConsecutive: r.maxConsecutive + 1)))
              : null,
          hint: r.maxConsecutive == 0
              ? 'No limit.'
              : 'After ${r.maxConsecutive} in a row, a gap is protected for you.'),
      _stepper('Shortest notice a parent can give', _noticeLabel(r.minNoticeMinutes),
          onMinus: r.minNoticeMinutes >= 60
              ? () => _update(_s.copyWith(
                  rules: r.copyWith(minNoticeMinutes: r.minNoticeMinutes - 60)))
              : null,
          onPlus: r.minNoticeMinutes < 60 * 48
              ? () => _update(_s.copyWith(
                  rules: r.copyWith(minNoticeMinutes: r.minNoticeMinutes + 60)))
              : null,
          hint: 'Nobody can book something starting sooner than this.'),
      _stepper('How far ahead parents can book', '${r.advanceWindowDays} days',
          onMinus: r.advanceWindowDays > 7
              ? () => _update(_s.copyWith(
                  rules: r.copyWith(advanceWindowDays: r.advanceWindowDays - 7)))
              : null,
          onPlus: r.advanceWindowDays < 90
              ? () => _update(_s.copyWith(
                  rules: r.copyWith(advanceWindowDays: r.advanceWindowDays + 7)))
              : null,
          hint: 'Your calendar opens this far into the future.'),
    ]);
  }

  static String _noticeLabel(int min) {
    if (min == 0) return 'Any time';
    if (min < 60) return '$min min';
    final h = min ~/ 60;
    return h == 1 ? '1 hour' : '$h hours';
  }

  Widget _chip(String label, bool on, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: on ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: on ? ppPurple : ppBorder),
          ),
          child: Text(label,
              style: ppJakarta(13, color: on ? Colors.white : ppSoft)),
        ),
      );

  Widget _stepper(String label, String value,
          {VoidCallback? onMinus, VoidCallback? onPlus, String? hint}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ppBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(label, style: ppJakarta(13.5))),
              _round(Icons.remove_rounded, onMinus),
              SizedBox(
                width: 74,
                child: Text(value,
                    textAlign: TextAlign.center, style: ppJakarta(13.5, color: ppPurple)),
              ),
              _round(Icons.add_rounded, onPlus),
            ]),
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(hint, style: ppBody(11.5, h: 1.4)),
            ],
          ]),
        ),
      );

  Widget _round(IconData icon, VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: onTap == null ? ppPanel : ppPurple.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: onTap == null ? ppMuted : ppPurple),
        ),
      );

  // ---- time off -------------------------------------------------------------

  Widget _timeOffSection() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Time off', style: ppJakarta(15)),
        const SizedBox(height: 4),
        Text('Holidays, leave, or a day you simply cannot take.',
            style: ppBody(12)),
        const SizedBox(height: 14),
        if (_s.timeOff.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ppBorder)),
            child: Row(children: [
              const Icon(Icons.beach_access_outlined, size: 18, color: ppMuted),
              const SizedBox(width: 11),
              Expanded(
                child: Text('No time off booked. Your week runs as set.',
                    style: ppBody(12.5)),
              ),
            ]),
          )
        else
          for (var i = 0; i < _s.timeOff.length; i++) _timeOffRow(i),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _addTimeOff,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: ppPurple, borderRadius: BorderRadius.circular(13)),
            child: Text('Add time off',
                style: ppJakarta(13.5, color: Colors.white)),
          ),
        ),
      ]);

  Widget _timeOffRow(int i) {
    final t = _s.timeOff[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ppBorder)),
        child: Row(children: [
          const Icon(Icons.event_busy_outlined, size: 18, color: ppCoral),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_rangeLabel(t), style: ppJakarta(13)),
              if (t.reason.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(t.reason, style: ppBody(11.5)),
              ],
            ]),
          ),
          IconButton(
            onPressed: () {
              final list = List<TimeOff>.from(_s.timeOff)..removeAt(i);
              _update(_s.copyWith(timeOff: list));
            },
            icon: const Icon(Icons.close_rounded, size: 17, color: ppMuted),
            tooltip: 'Remove',
          ),
        ]),
      ),
    );
  }

  static String _rangeLabel(TimeOff t) {
    String d(DateTime x) => _dayMonth(x);
    return t.fromDate.difference(t.toDate).inDays == 0
        ? d(t.fromDate)
        : '${d(t.fromDate)} — ${d(t.toDate)}';
  }

  Future<void> _addTimeOff() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: 'Which days are you away?',
    );
    if (range == null) return;
    final list = List<TimeOff>.from(_s.timeOff)
      ..add(TimeOff(fromDate: range.start, toDate: range.end));
    _update(_s.copyWith(timeOff: list));
  }

  // ---- preview --------------------------------------------------------------

  /// The consequence of every setting above, in the parent's terms. Uses the
  /// same generateSlots() the parent side uses, so it cannot lie.
  Widget _preview() {
    final slots = _store.preview(_expertId, days: 7);
    final byDay = groupByDay(slots);
    final days = byDay.keys.toList()..sort();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: ppPanel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ppPanelDiv),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.visibility_outlined, size: 17, color: ppPurple),
          const SizedBox(width: 9),
          Expanded(child: Text('What parents will see', style: ppJakarta(14))),
          Text('${slots.length} slots · 7 days',
              style: ppBody(11.5, color: ppSoft)),
        ]),
        const SizedBox(height: 12),
        if (slots.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text(
              _s.paused
                  ? 'You are paused, so nothing is bookable right now.'
                  : 'Nothing is bookable yet. Add a working day and some hours above.',
              style: ppBody(12.5, h: 1.5),
            ),
          )
        else
          for (final d in days.take(4)) _previewDay(d, byDay[d]!),
      ]),
    );
  }

  Widget _previewDay(DateTime day, List<GeneratedSlot> slots) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('${_dayNames[day.weekday]} ${_dayMonth(day)}',
                  style: ppJakarta(12.5)),
              const Spacer(),
              Text('${slots.length}', style: ppBody(11.5, color: ppMuted)),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final s in slots.take(8))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                      color: ppStripeB, borderRadius: BorderRadius.circular(7)),
                  child: Text(hhmm(s.start.hour * 60 + s.start.minute),
                      style: ppBody(11, color: ppTitleInk)),
                ),
              if (slots.length > 8)
                Text('+${slots.length - 8}', style: ppBody(11, color: ppMuted)),
            ]),
          ]),
        ),
      );
}
