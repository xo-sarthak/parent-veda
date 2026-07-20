// =============================================================================
//  VaxTrackerScreen - Vaccination Tracker home (redesign · journey-first)
// -----------------------------------------------------------------------------
//  Answers "What does my child need today, why does it matter, and what should I
//  do next?" - not "which vaccine is due?". A calm snapshot hero (completed,
//  next, reminder, progress), a single Due-Today action, a preview of the
//  journey timeline, and quiet entries to the doctor summary. Calm before
//  clinical; reassuring language throughout. Replaces the old VaccinationScreen
//  as the live entry (old code kept, commented, for revert).
// =============================================================================

import 'dart:math' as math;
import 'pp_child_profile.dart';

import 'package:flutter/material.dart';

import '../../services/notification_service.dart';
import 'doctor_record_screen.dart';
import 'pp_common.dart';
import 'pp_vaccine_data.dart';
import 'vax_detail_screen.dart';
import 'vax_timeline_screen.dart';

const Color _green = Color(0xFF1F8A5B);
const Color _greenTint = Color(0xFFEAF4EE);
const Color _ringTrack = Color(0xFFECE5F2);

class VaxTrackerScreen extends StatelessWidget {
  const VaxTrackerScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      floatingActionButton: GestureDetector(
        onTap: () => openPpTab(context, 1),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 22, spreadRadius: -6, offset: Offset(0, 10))]),
          child: const Icon(Icons.auto_awesome, size: 24, color: Colors.white),
        ),
      ),
      body: AnimatedBuilder(
        animation: VaxStore.instance,
        builder: (context, _) {
          final store = VaxStore.instance;
          final done = store.completedVaccineCount;
          final total = store.firstYearTotal;
          final due = store.dueVisit;
          final next = store.nextVisit;
          return ListView(
            padding: const EdgeInsets.only(top: 60, bottom: 40),
            children: [
              _pad(ppCircleBack(context, eyebrow: 'Vaccinations')),

              const SizedBox(height: 22),
              _pad(ppEyebrow('${ChildProfileStore.instance.name} · 4 months', color: ppMuted, spacing: 1.4)),
              const SizedBox(height: 8),
              _pad(Text.rich(TextSpan(children: [
                const TextSpan(text: 'On track, '),
                TextSpan(text: 'and protected.', style: ppFraunces(34, color: ppPurple, h: 1.1).copyWith(fontStyle: FontStyle.italic)),
              ]), style: ppFraunces(34, h: 1.1))),

              // snapshot hero
              const SizedBox(height: 22),
              _pad(_snapshot(context, done, total, due, next)),

              // next vaccination
              if (due != null) ...[
                const SizedBox(height: 26),
                _pad(_railLabel('Next vaccination', color: ppPurple)),
                const SizedBox(height: 14),
                _pad(_dueCard(context, due)),
              ],

              // timeline preview
              const SizedBox(height: 26),
              _pad(_railLabel('His journey', color: ppSoft, trailing: GestureDetector(
                onTap: () => _push(context, const VaxTimelineScreen()),
                behavior: HitTestBehavior.opaque,
                child: Text('Full timeline →', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
              ))),
              const SizedBox(height: 14),
              _pad(Column(children: [
                for (final v in _previewVisits(store)) _timelineRow(context, v, store),
              ])),

              // doctor record
              const SizedBox(height: 18),
              _pad(GestureDetector(
                onTap: () => _push(context, const DoctorRecordScreen()),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair), boxShadow: const [BoxShadow(color: Color(0x146A30B6), blurRadius: 20, spreadRadius: -18, offset: Offset(0, 8))]),
                  child: Row(children: [
                    const Icon(Icons.description_outlined, size: 22, color: ppPurple),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Doctor-ready record', style: ppJakarta(14)),
                        const SizedBox(height: 1),
                        Text('A clean summary to share at the next visit', style: ppBody(12, color: ppMuted)),
                      ]),
                    ),
                    const Text('→', style: TextStyle(color: Color(0xFFC7BBD6))),
                  ]),
                ),
              )),

              const SizedBox(height: 22),
              _pad(Text(
                'A reminder & record companion, not medical advice. Your paediatrician designs any catch-up. Reviewed by Dr. Ananya Rao · schedule v2026.1',
                textAlign: TextAlign.center,
                style: ppBody(12, color: ppMuted, h: 1.55),
              )),
            ],
          );
        },
      ),
    );
  }

  List<VaxVisit> _previewVisits(VaxStore store) {
    // the due one + the next two upcoming, so the preview looks forward
    final out = <VaxVisit>[];
    if (store.dueVisit != null) out.add(store.dueVisit!);
    for (final v in kVaxVisits) {
      if (store.statusOf(v) == VaxStatus.upcoming) {
        out.add(v);
        if (out.length >= 3) break;
      }
    }
    return out;
  }

  // ---- snapshot hero ------------------------------------------------------
  Widget _snapshot(BuildContext context, int done, int total, VaxVisit? due, VaxVisit? next) {
    final store = VaxStore.instance;
    final reminder = store.nextReminderLabel;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ppHair),
        boxShadow: const [BoxShadow(color: Color(0x1A6A30B6), blurRadius: 30, spreadRadius: -20, offset: Offset(0, 12))],
      ),
      child: Column(children: [
        Row(children: [
          _ring(done: done, total: total),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("${ChildProfileStore.instance.name}'s had $done of his first-year vaccines.", style: ppBody(14, color: ppInk, w: FontWeight.w600, h: 1.5)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 6, children: [
                _statChip('${due != null ? 1 : 0} due', ppPurple),
                _statChip('0 overdue', _green),
              ]),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        const Divider(height: 1, color: ppHair),
        const SizedBox(height: 14),
        Row(children: [
          const Icon(Icons.notifications_none_rounded, size: 17, color: ppPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: 'Next reminder: ', style: ppBody(12.5, color: ppSoft, w: FontWeight.w700)),
              TextSpan(text: reminder ?? 'none set yet - add one from any vaccine', style: ppBody(12.5, color: ppInk)),
            ]), maxLines: 2),
          ),
        ]),
      ]),
    );
  }

  Widget _statChip(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
        child: Text(t, style: ppBody(11, color: c, w: FontWeight.w700)),
      );

  Widget _ring({required int done, required int total}) => SizedBox(
        width: 78,
        height: 78,
        child: CustomPaint(
          painter: _RingPainter(total == 0 ? 0 : done / total),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$done/$total', style: ppJakarta(17)),
              Text('done', style: ppBody(9, color: ppMuted)),
            ]),
          ),
        ),
      );

  // ---- due today card -----------------------------------------------------
  Widget _dueCard(BuildContext context, VaxVisit v) {
    final lead = v.lead;
    return GestureDetector(
      onTap: () => _push(context, VaxDetailScreen(visitId: v.id)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, ppStripeB]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ppBorder),
          boxShadow: const [BoxShadow(color: Color(0x1F6A30B6), blurRadius: 32, spreadRadius: -18, offset: Offset(0, 14))],
        ),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${lead.shortName} · ${v.ageLabel}', style: ppJakarta(18)),
                const SizedBox(height: 3),
                Text(lead.protects, style: ppBody(12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            _statChip('Due ${v.date.split(' ').take(2).join(' ')}', ppPurple),
          ]),
          const SizedBox(height: 14),
          const Divider(height: 1, color: ppHair),
          const SizedBox(height: 14),
          // alarm on its own row, so nothing crowds it
          Row(children: [_alarmChip(context, v), const Spacer()]),
          const SizedBox(height: 10),
          Row(children: [
            if (v.govtFree) ...[
              Flexible(child: _pill('Free at govt centre', fg: _green, bg: _greenTint)),
              const SizedBox(width: 8),
            ],
            const Spacer(),
            Text('Learn why →', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
          ]),
        ]),
      ),
    );
  }

  Widget _alarmChip(BuildContext context, VaxVisit v) {
    final on = VaxStore.instance.hasReminder(v.id);
    return GestureDetector(
      onTap: () => _alarmSheet(context, v),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(color: ppPurple.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(on ? Icons.alarm_on_rounded : Icons.add_alarm_rounded, size: 15, color: ppPurple),
          const SizedBox(width: 6),
          Text(on ? 'Alarm set' : 'Set alarm', style: ppBody(11.5, color: ppPurple, w: FontWeight.w700)),
        ]),
      ),
    );
  }

  // ---- alarm / reminder scheduling (mirrors the vaccine detail's flow) -----
  void _alarmSheet(BuildContext context, VaxVisit v) {
    final lead = v.lead;
    final base = vaxVisitDate(v) ?? vaxDueDate();
    void set(int daysBefore, String label) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      VaxStore.instance.setReminder(v.id, true);
      NotificationService.instance.requestPermission();
      NotificationService.instance.scheduleOneOff(
        id: (v.id.hashCode & 0x7fffffff),
        title: 'Vaccine reminder - ${lead.shortName}',
        body: daysBefore == 0
            ? "${ChildProfileStore.instance.name}'s ${lead.shortName} (${v.ageLabel}) is due today."
            : "${ChildProfileStore.instance.name}'s ${lead.shortName} (${v.ageLabel}) is due ${daysBefore == 1 ? 'tomorrow' : 'in $daysBefore days'} - ${v.date}.",
        when: base.subtract(Duration(days: daysBefore)),
      );
      messenger.showSnackBar(SnackBar(content: Text('Alarm set - $label'), behavior: SnackBarBehavior.floating));
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Text('Set a vaccination alarm', style: ppJakarta(17)),
            const SizedBox(height: 4),
            Text('${lead.shortName} · due ${v.date}. We\'ll send a gentle reminder.', style: ppBody(12.5, color: ppMuted)),
            const SizedBox(height: 14),
            _alarmOption('The day before', () => set(1, '1 day before')),
            _alarmOption('3 days before', () => set(3, '3 days before')),
            _alarmOption('A week before', () => set(7, '1 week before')),
            _alarmOption('On the day', () => set(0, 'on the day')),
            if (VaxStore.instance.hasReminder(v.id)) ...[
              const SizedBox(height: 4),
              Center(child: GestureDetector(
                onTap: () {
                  VaxStore.instance.setReminder(v.id, false);
                  Navigator.of(ctx).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: Text('Remove alarm', style: ppBody(13, color: ppCoral, w: FontWeight.w700)),
              )),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _alarmOption(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
          child: Row(children: [
            const Icon(Icons.notifications_none_rounded, size: 18, color: ppPurple),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: ppBody(14, color: ppInk, w: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );

  Widget _pill(String t, {required Color fg, required Color bg}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(t, style: ppBody(11, color: fg, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
      );

  // ---- timeline preview rows ----------------------------------------------
  Widget _railLabel(String t, {required Color color, Widget? trailing}) => Row(children: [
        Text(t.toUpperCase(), style: ppBody(11, color: color, w: FontWeight.w700).copyWith(letterSpacing: 1.0)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: ppHair)),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ]);

  Widget _timelineRow(BuildContext context, VaxVisit v, VaxStore store) {
    final status = store.statusOf(v);
    final (Color dot, Color txt) = switch (status) {
      VaxStatus.done => (_green, ppSoft),
      VaxStatus.due => (ppPurple, ppInk),
      VaxStatus.upcoming => (const Color(0xFFC7BBD6), ppInk),
    };
    return GestureDetector(
      onTap: () => _push(context, VaxDetailScreen(visitId: v.id)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ppHair))),
        child: Row(children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: status == VaxStatus.done ? dot : ppBg, shape: BoxShape.circle, border: Border.all(color: dot, width: 2))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${v.ageLabel} · ${v.vaccines.map((x) => x.shortName).join(', ')}', style: ppBody(13.5, color: txt, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('${vaxStatusLabel(status)} · ${v.date}', style: ppBody(11.5, color: ppMuted)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
        ]),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.frac);
  final double frac;

  @override
  void paint(Canvas canvas, Size size) {
    const width = 9.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - width) / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = _ringTrack;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = _green;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, frac * 2 * math.pi, false, fill);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.frac != frac;
}
