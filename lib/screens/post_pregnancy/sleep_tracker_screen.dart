// =============================================================================
//  SleepTrackerScreen - everyday Sleep tracker (parenting · Tools)
// -----------------------------------------------------------------------------
//  A calm read on rest: how much sleep today added up to, when the last stretch
//  ended, and each nap/night as a quiet list. "Log sleep" captures a start and
//  end time (via the time picker) with an optional quality + note. Reads the
//  shared PpTrackerStore and rebuilds on change. Sibling to the Feeding tracker;
//  same editorial language as the Vax + Health screens.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_trackers_data.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  final _store = PpTrackerStore.instance;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _store,
          builder: (context, _) {
            final today = _store.todaysSleeps;
            final total = _store.totalSleepMinutesToday;
            final last = _store.lastSleep;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 48),
              children: [
                _pad(ppBack(context, 'Tools')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('ParentVeda', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Sleep tracker', style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 8),
                _pad(Text('Rest, gently noted. A picture of the day rather than a target to hit.',
                    style: ppBody(14, h: 1.55))),

                const SizedBox(height: 20),
                _pad(_hero(total, last)),

                const SizedBox(height: 16),
                _pad(_logButton()),

                const SizedBox(height: 26),
                _pad(Row(children: [
                  Expanded(child: Text("Today's sleep", style: ppJakarta(16))),
                  Text(today.isEmpty ? '' : '${today.length} logged', style: ppBody(12, color: ppMuted)),
                ])),
                const SizedBox(height: 14),
                if (today.isEmpty)
                  _pad(_empty())
                else
                  _pad(Column(children: [for (final s in today) _sleepRow(s)])),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- summary hero -------------------------------------------------------
  Widget _hero(int totalMins, SleepEntry? last) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, ppStripeB]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ppHair),
          boxShadow: const [BoxShadow(color: Color(0x1A6A30B6), blurRadius: 30, spreadRadius: -20, offset: Offset(0, 12))],
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(totalMins == 0 ? '0m' : _dur(totalMins), style: ppFraunces(34, color: ppPurple, h: 1.0)),
              const SizedBox(height: 3),
              Text('slept today', style: ppBody(12.5, color: ppSoft, w: FontWeight.w600)),
            ]),
          ),
          Container(width: 1, height: 46, color: ppHair),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.bedtime_outlined, size: 15, color: ppPurple),
                const SizedBox(width: 6),
                Text('Last sleep', style: ppBody(11.5, color: ppMuted, w: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              Text(last == null ? 'none yet' : _dur(last.durationMinutes), style: ppJakarta(17)),
              const SizedBox(height: 2),
              Text(last == null ? 'log the first below' : 'ended ${_relative(last.end)}', style: ppBody(12, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      );

  Widget _logButton() => GestureDetector(
        onTap: _openLogSheet,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16), boxShadow: ppCardShadow),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text('Log sleep', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
          ]),
        ),
      );

  Widget _empty() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.bedtime_outlined, size: 20, color: ppPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('No sleep logged today yet. Add a nap or last night whenever it suits - even a rough note helps.',
                style: ppBody(13, h: 1.5)),
          ),
        ]),
      );

  // ---- sleep row ----------------------------------------------------------
  Widget _sleepRow(SleepEntry s) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFEDEAF7), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.bedtime_outlined, size: 19, color: ppInk),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(_dur(s.durationMinutes), style: ppJakarta(14.5)),
                const SizedBox(width: 8),
                Flexible(child: Text('${_clock(s.start)} - ${_clock(s.end)}', style: ppBody(11.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              if (s.quality != null || s.note != null) ...[
                const SizedBox(height: 3),
                Text(_sleepDetail(s), style: ppBody(12.5, color: ppSoft, h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ]),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _confirmDelete('Remove this sleep?', () => _store.removeSleep(s.id)),
            behavior: HitTestBehavior.opaque,
            child: const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.delete_outline_rounded, size: 20, color: ppMuted)),
          ),
        ]),
      );

  // ---- log sheet ----------------------------------------------------------
  void _openLogSheet() {
    final now = TimeOfDay.now();
    TimeOfDay start = _minus(now, 90); // default: a 90-min stretch ending now
    TimeOfDay end = now;
    SleepQuality? quality;
    final note = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                Text('Log sleep', style: ppJakarta(18)),
                const SizedBox(height: 16),

                Row(children: [
                  Expanded(child: _timeField('Fell asleep', start, () async {
                    final t = await showTimePicker(context: ctx, initialTime: start);
                    if (t != null) setSheet(() => start = t);
                  })),
                  const SizedBox(width: 12),
                  Expanded(child: _timeField('Woke up', end, () async {
                    final t = await showTimePicker(context: ctx, initialTime: end);
                    if (t != null) setSheet(() => end = t);
                  })),
                ]),
                const SizedBox(height: 8),
                Text('That is ${_dur(_spanMinutes(start, end))} of rest.', style: ppBody(12, color: ppMuted)),
                const SizedBox(height: 16),

                _label('How did it go? (optional)'),
                Row(children: [
                  for (final q in SleepQuality.values) ...[
                    _qualityChip(q, quality == q, () => setSheet(() => quality = quality == q ? null : q)),
                    if (q != SleepQuality.values.last) const SizedBox(width: 8),
                  ],
                ]),
                const SizedBox(height: 16),

                _tf(note, 'Note (optional)', maxLines: 2),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    final now = DateTime.now();
                    DateTime at(TimeOfDay t) => DateTime(now.year, now.month, now.day, t.hour, t.minute);
                    var s = at(start);
                    var e = at(end);
                    if (e.isBefore(s)) e = e.add(const Duration(days: 1)); // crossed midnight
                    _store.logSleep(
                      start: s,
                      end: e,
                      quality: quality,
                      note: note.text.trim().isEmpty ? null : note.text.trim(),
                    );
                    Navigator.of(ctx).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                    child: Text('Save sleep', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String title, VoidCallback onConfirm) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: ppJakarta(16)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
                    child: Text('Cancel', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onConfirm();
                    Navigator.of(ctx).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(14)),
                    child: Text('Remove', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ---- small parts --------------------------------------------------------
  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
      );

  Widget _timeField(String label, TimeOfDay value, VoidCallback onTap) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
              child: Row(children: [
                const Icon(Icons.schedule_rounded, size: 16, color: ppPurple),
                const SizedBox(width: 8),
                Text(_fmtTod(value), style: ppBody(14, color: ppInk, w: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      );

  Widget _qualityChip(SleepQuality q, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? ppPurple : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: on ? ppPurple : ppLine),
            ),
            child: Text(_qualityLabel(q), style: ppBody(12.5, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
          ),
        ),
      );

  Widget _tf(TextEditingController c, String label, {int maxLines = 1}) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label(label),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: c,
              maxLines: maxLines,
              style: ppBody(14, color: ppInk),
              decoration: const InputDecoration(isDense: true, filled: false, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ]),
      );

  // ---- formatting helpers -------------------------------------------------
  String _qualityLabel(SleepQuality q) => switch (q) {
        SleepQuality.sound => 'Sound',
        SleepQuality.restless => 'Restless',
        SleepQuality.brief => 'Brief',
      };

  String _sleepDetail(SleepEntry s) {
    final parts = <String>[
      if (s.quality != null) _qualityLabel(s.quality!),
      if (s.note != null) s.note!,
    ];
    return parts.join(' · ');
  }

  // Minutes in a start→end span, treating end-before-start as crossing midnight.
  int _spanMinutes(TimeOfDay a, TimeOfDay b) {
    var mins = (b.hour * 60 + b.minute) - (a.hour * 60 + a.minute);
    if (mins < 0) mins += 24 * 60;
    return mins;
  }

  TimeOfDay _minus(TimeOfDay t, int minutes) {
    var total = t.hour * 60 + t.minute - minutes;
    total %= 24 * 60;
    if (total < 0) total += 24 * 60;
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  String _dur(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _relative(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return m == 0 ? '${h}h ago' : '${h}h ${m}m ago';
    }
    return '${diff.inDays}d ago';
  }

  String _fmtTod(TimeOfDay t) {
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    var h = t.hour % 12;
    if (h == 0) h = 12;
    return '$h:${t.minute.toString().padLeft(2, '0')} $ampm';
  }

  String _clock(DateTime t) {
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    var h = t.hour % 12;
    if (h == 0) h = 12;
    return '$h:${t.minute.toString().padLeft(2, '0')} $ampm';
  }
}
