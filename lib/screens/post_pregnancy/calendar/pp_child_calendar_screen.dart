// =============================================================================
//  A child's calendar (STAGE-TRANSITIONS F7, 2026-10-25)
// -----------------------------------------------------------------------------
//  Behind the Calendar button in the parenting header (F1 opened the vaccine
//  list there "until a child calendar exists"). The pregnancy calendar's hub
//  for one child: the month with a dot per kind, the picked day, Coming up,
//  the next usual check-up as a window, and Add an appointment. Whose calendar
//  it is follows the family switch: the child on screen.
//
//  The look is the pregnancy calendar's own parts (preg_cal_parts.dart), so
//  the two calendars read as one ParentVeda. Approved prototype:
//  claude.ai/artifact/QGDv1tigpwXAg7PTrZpyHj.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_date_sheet.dart';
import '../../../widgets/pv_feedback.dart';
import '../../../widgets/pv_toast.dart';
import '../../pregnancy/calendar/preg_cal_parts.dart';
import '../../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
import '../pp_child_profile.dart';
import '../pp_health_data.dart';
import '../pp_vaccine_data.dart';
import '../vax_tracker_screen.dart';
import 'pp_cal_data.dart';

const String kPpChildCalendarRoute = 'pp/calendar';

void openPpChildCalendar(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPpChildCalendarRoute),
    builder: (_) => const PpChildCalendarScreen(),
  ));
}

/// The colour of each kind's dot, and its words.
({Color color, String label}) ppCalMeta(PpCalKind k) => switch (k) {
      PpCalKind.vaccine => (color: const Color(0xFF5E9C7B), label: 'Vaccine'),
      PpCalKind.checkup => (color: const Color(0xFF8B74B8), label: 'Check-up'),
      PpCalKind.visit => (color: const Color(0xFFD08A5C), label: 'Appointment'),
    };

class PpChildCalendarScreen extends StatefulWidget {
  const PpChildCalendarScreen({super.key, this.today});

  /// Tests pin the day.
  final DateTime? today;

  @override
  State<PpChildCalendarScreen> createState() => _PpChildCalendarScreenState();
}

class _PpChildCalendarScreenState extends State<PpChildCalendarScreen> {
  late DateTime _today;
  late DateTime _month; // the first of the month on screen
  late DateTime _pick;

  @override
  void initState() {
    super.initState();
    final t = widget.today ?? DateTime.now();
    _today = DateTime(t.year, t.month, t.day);
    _month = DateTime(_today.year, _today.month);
    _pick = _today;
  }

  List<PpCalItem> _items() {
    final kids = ChildProfileStore.instance;
    final vax = VaxStore.instance;
    return ppCalItems(
      dob: kids.dob,
      today: _today,
      vaxVisits: kVaxVisits,
      isGiven: vax.isDone,
      givenOn: vax.givenOn,
      visits: HealthStore.instance.visits,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: Listenable.merge(
          [ChildProfileStore.instance, VaxStore.instance, HealthStore.instance]),
      builder: (context, _) {
        final kids = ChildProfileStore.instance;
        final name = kids.hasRealChild ? kids.name : 'Your child';
        final items = _items();
        final day = ppCalOn(items, _pick);
        final soon = ppCalComingUp(items, _today);
        final checks = ppNextCheckups(kids.dob, _today, items);
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(backgroundColor: p.ground, elevation: 0, foregroundColor: p.ink1),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
              children: [
                Text("$name's calendar", style: pregCalSerif(28)),
                const SizedBox(height: 6),
                Text('Vaccines, check-ups and appointments. Switch child in the name at the top of the home and this is theirs.',
                    style: pregCalBody(size: 13.5, color: p.ink2, height: 1.45)),
                const SizedBox(height: 16),
                PregCalCard(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                  child: _monthView(items),
                ),
                const SizedBox(height: 18),
                Text(_dayLabel(_pick).toUpperCase(), style: pregCalEyebrow()),
                const SizedBox(height: 4),
                if (day.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('Nothing on this day. Add an appointment below and it shows here.',
                        style: pregCalBody(size: 13, color: p.ink2)),
                  )
                else
                  for (var i = 0; i < day.length; i++) _row(day[i], first: i == 0),
                const SizedBox(height: 18),
                Text('COMING UP', style: pregCalEyebrow()),
                const SizedBox(height: 4),
                if (soon.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('Nothing booked or due. The next usual check-up is below.',
                        style: pregCalBody(size: 13, color: p.ink2)),
                  )
                else
                  for (var i = 0; i < soon.length; i++) _row(soon[i], first: i == 0, countdown: true),
                if (checks.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text('THE USUAL CHECK-UP', style: pregCalEyebrow()),
                  const SizedBox(height: 4),
                  for (final c in checks) _checkupRow(c),
                ],
                const SizedBox(height: 18),
                pregCalSaveButton('Add an appointment', () => _addAppointment(name)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- the month -------------------------------------------------------------

  Widget _monthView(List<PpCalItem> items) {
    final p = pvStorePalette;
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final first = _month;
    final lead = (first.weekday + 6) % 7; // Monday first
    final days = DateTime(first.year, first.month + 1, 0).day;
    final byDay = <int, Set<PpCalKind>>{};
    for (final x in items) {
      if (x.day.year == first.year && x.day.month == first.month) {
        (byDay[x.day.day] ??= {}).add(x.kind);
      }
    }
    Widget arrow(IconData i, String label, int delta) => Semantics(
          button: true,
          label: label,
          child: pregCalTap(
            onTap: () => setState(() => _month = DateTime(_month.year, _month.month + delta)),
            child: Padding(padding: const EdgeInsets.all(8), child: Icon(i, size: 22, color: p.ink1)),
          ),
        );
    return Column(children: [
      Row(children: [
        arrow(Icons.chevron_left_rounded, 'Previous month', -1),
        Expanded(
          child: Text('${months[first.month - 1]} ${first.year}',
              textAlign: TextAlign.center, style: pregCalBody(weight: FontWeight.w800)),
        ),
        arrow(Icons.chevron_right_rounded, 'Next month', 1),
      ]),
      const SizedBox(height: 4),
      Row(children: [
        for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
          Expanded(
            child: Text(d, textAlign: TextAlign.center, style: pregCalEyebrow()),
          ),
      ]),
      const SizedBox(height: 4),
      for (var w = 0; w * 7 < lead + days; w++)
        Row(children: [
          for (var c = 0; c < 7; c++)
            Expanded(child: _cell(w * 7 + c - lead + 1, days, byDay)),
        ]),
      const SizedBox(height: 8),
      Wrap(spacing: 14, runSpacing: 6, children: [
        for (final k in PpCalKind.values)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: ppCalMeta(k).color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(ppCalMeta(k).label, style: pregCalBody(size: 11.5, weight: FontWeight.w700, color: p.ink2)),
          ]),
      ]),
    ]);
  }

  Widget _cell(int n, int days, Map<int, Set<PpCalKind>> byDay) {
    if (n < 1 || n > days) return const SizedBox(height: 42);
    final d = DateTime(_month.year, _month.month, n);
    final picked = d == _pick;
    final today = d == _today;
    final kinds = byDay[n] ?? const {};
    return Semantics(
      button: true,
      selected: picked,
      label: '$n, ${kinds.length} things',
      child: pregCalTap(
        onTap: () => setState(() => _pick = d),
        child: Container(
          height: 42,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: picked ? kPvInk : null,
            borderRadius: BorderRadius.circular(10),
            border: today && !picked ? Border.all(color: kPvInk, width: 1.5) : null,
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('$n',
                style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: picked ? Colors.white : pvStorePalette.ink1)),
            const SizedBox(height: 2),
            SizedBox(
              height: 5,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                for (final k in kinds)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(color: ppCalMeta(k).color, shape: BoxShape.circle),
                  ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  String _dayLabel(DateTime d) {
    const w = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const m = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${w[d.weekday - 1]} ${d.day} ${m[d.month - 1]}${d == _today ? ' · today' : ''}';
  }

  String _countdown(DateTime d) {
    final n = d.difference(_today).inDays;
    if (n <= 0) return 'Today';
    if (n == 1) return 'Tomorrow';
    return 'In $n days';
  }

  // ---- rows ------------------------------------------------------------------

  Widget _row(PpCalItem x, {bool first = false, bool countdown = false}) {
    final p = pvStorePalette;
    const wd = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final status = countdown && x.status != 'Due' ? _countdown(x.day) : x.status;
    return pregCalTap(
      onTap: () => _open(x),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: kPvLine))),
        child: Row(children: [
          PregCalDateBlock(top: wd[x.day.weekday - 1], big: '${x.day.day}'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(x.title, maxLines: 2, style: pregCalBody(size: 14.5, weight: FontWeight.w700)),
              if (x.detail.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(x.detail, maxLines: 2, style: pregCalBody(size: 12.5, color: p.ink3)),
              ],
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: kPregCalTint, borderRadius: BorderRadius.circular(999)),
            child: Text(status, style: pregCalBody(size: 11, weight: FontWeight.w800, color: p.ink2)),
          ),
        ]),
      ),
    );
  }

  Widget _checkupRow(({PpCheckup c, DateTime from, DateTime to, bool booked}) w) {
    final p = pvStorePalette;
    final kids = ChildProfileStore.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PregCalDateBlock(top: 'AROUND', big: _shortMonth(w.from.add(const Duration(days: 7))), dashed: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(w.c.label, style: pregCalBody(size: 14.5, weight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('${ppRecordDate(w.from)} to ${ppRecordDate(w.to)}. $kPpCheckupLine',
                style: pregCalBody(size: 12.5, color: p.ink3, height: 1.4)),
            const SizedBox(height: 8),
            if (w.booked)
              Text('Booked: it is in Coming up.', style: pregCalBody(size: 12.5, weight: FontWeight.w700))
            else
              PregCalPill(
                label: 'Add the date',
                icon: Icons.add_rounded,
                onTap: () => _addAppointment(kids.hasRealChild ? kids.name : 'your child',
                    title: w.c.label, initial: w.from.add(const Duration(days: 7))),
              ),
          ]),
        ),
      ]),
    );
  }

  String _shortMonth(DateTime d) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1];

  void _open(PpCalItem x) {
    pvCommitFeedback();
    if (x.kind == PpCalKind.vaccine) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp/vaccines'),
        builder: (_) => const VaxTrackerScreen(),
      ));
      return;
    }
    final booked = x.status == 'Booked';
    showPregCalSheet<void>(
      context,
      (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(x.title, style: pregCalSerif(22)),
        const SizedBox(height: 6),
        Text(_dayLabel(x.day), style: pregCalBody(size: 14, weight: FontWeight.w700)),
        if (x.detail.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(x.detail, style: pregCalBody(size: 14, color: pvStorePalette.ink2, height: 1.45)),
        ],
        const SizedBox(height: 6),
        Text(
            booked
                ? (PpApptReminders.instance.isOn(x.healthId ?? '')
                    ? 'We will remind you at 7 pm the evening before.'
                    : 'No reminder set.')
                : 'Kept in Health records.',
            style: pregCalBody(size: 13, color: pvStorePalette.ink3)),
        const SizedBox(height: 16),
        if (booked)
          PregCalPill(
            label: 'Remove this appointment',
            icon: Icons.delete_outline_rounded,
            onTap: () {
              Navigator.of(ctx).pop();
              _remove(x);
            },
          ),
      ]),
    );
  }

  void _remove(PpCalItem x) {
    final store = HealthStore.instance;
    final i = store.visits.indexWhere((v) => v.id == x.healthId);
    if (i < 0) return;
    final gone = store.visits[i];
    store.removeVisit(i);
    PpApptReminders.instance.forget(gone.id);
    pvToast(context, 'Appointment removed.', kind: PvToastKind.done, action: 'Undo', onAction: () {
      store.addVisit(gone);
    });
  }

  // ---- add -------------------------------------------------------------------

  Future<void> _addAppointment(String name, {String? title, DateTime? initial}) async {
    final saved = await showPregCalSheet<bool>(
      context,
      (ctx) => _ApptForm(
        childName: name,
        today: _today,
        title: title,
        initial: initial ?? (_pick.isBefore(_today) ? _today : _pick),
      ),
    );
    if (saved == true && mounted) {
      pvToast(context, "Saved to $name's health records.", kind: PvToastKind.done);
    }
  }
}

/// The appointment form: what, when, with whom, the reminder. Written to
/// Health as an upcoming visit.
class _ApptForm extends StatefulWidget {
  const _ApptForm({required this.childName, required this.today, required this.initial, this.title});
  final String childName;
  final DateTime today;
  final DateTime initial;
  final String? title;

  @override
  State<_ApptForm> createState() => _ApptFormState();
}

class _ApptFormState extends State<_ApptForm> {
  late final TextEditingController _what = TextEditingController(text: widget.title ?? '');
  final TextEditingController _with = TextEditingController();
  late DateTime _date = widget.initial;
  TimeOfDay _time = const TimeOfDay(hour: 11, minute: 0);
  bool _remind = true;

  @override
  void dispose() {
    _what.dispose();
    _with.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final what = _what.text.trim();
    if (what.isEmpty) {
      pvToast(context, 'Give it a name first, like "Paediatrician" or "Eye check".');
      return;
    }
    final at = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final hhmm = '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
    final who = _with.text.trim();
    final v = HealthEvent(
      id: 'v_added_${DateTime.now().microsecondsSinceEpoch}',
      type: HealthEventType.doctorVisit,
      date: ppRecordDate(_date),
      title: what,
      summary: who.isEmpty ? hhmm : '$hhmm · $who',
      doctor: who.isEmpty ? null : who,
      sortKey: 1000, // as Health's own Add: a parent-added visit sorts first
      upcoming: true,
    );
    HealthStore.instance.addVisit(v);
    if (_remind) {
      await PpApptReminders.instance.remind(v.id, at,
          title: 'Tomorrow: $what',
          body: who.isEmpty ? '${widget.childName}, at $hhmm.' : '${widget.childName}, at $hhmm with $who.');
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    InputDecoration deco(String label, String hint) => InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPvLine)),
        );
    Widget pick(String label, String value, VoidCallback onTap) => pregCalTap(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(border: Border.all(color: kPvLine), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Text(label, style: pregCalBody(size: 13, weight: FontWeight.w800, color: p.ink3)),
              const Spacer(),
              Text(value, style: pregCalBody(size: 14.5, weight: FontWeight.w700)),
            ]),
          ),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('An appointment for ${widget.childName}', style: pregCalSerif(22)),
      const SizedBox(height: 4),
      Text('Saved to their Health records, so it is the same visit everywhere.',
          style: pregCalBody(size: 13.5, color: p.ink2)),
      const SizedBox(height: 14),
      TextField(key: const ValueKey('pp_cal_what'), controller: _what, decoration: deco('What', 'Paediatrician, eye check')),
      const SizedBox(height: 10),
      pick('Day', ppRecordDate(_date), () async {
        final d = await showPvDateSheet(context,
            title: 'Which day?',
            initial: _date,
            first: widget.today,
            last: widget.today.add(const Duration(days: 730)));
        if (d != null) setState(() => _date = DateTime(d.year, d.month, d.day));
      }),
      pick('Time', _time.format(context), () async {
        final t = await showTimePicker(context: context, initialTime: _time);
        if (t != null) setState(() => _time = t);
      }),
      TextField(key: const ValueKey('pp_cal_with'), controller: _with, decoration: deco('With (optional)', 'Dr Mehta, Rainbow Clinic')),
      const SizedBox(height: 6),
      // A row and the app's one switch, not a SwitchListTile: the sheet paints
      // its own white, which would hide the tile's ripple.
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Remind me the evening before', style: pregCalBody(weight: FontWeight.w700)),
            Text('At 7 pm, on this phone', style: pregCalBody(size: 12.5, color: p.ink3)),
          ]),
        ),
        Switch.adaptive(
          key: const ValueKey('pp_cal_remind'),
          value: _remind,
          onChanged: (v) => setState(() => _remind = v),
        ),
      ]),
      const SizedBox(height: 8),
      pregCalSaveButton('Save appointment', _save),
    ]);
  }
}
