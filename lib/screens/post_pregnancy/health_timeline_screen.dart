// =============================================================================
//  HealthTimelineScreen — the health story, chronologically (the backbone)
// -----------------------------------------------------------------------------
//  Every health event as a vertical timeline — doctor visits, vaccines,
//  illnesses, growth checks, lab tests, milestones — newest first, with the one
//  upcoming event pinned on top. Tap any event for its detail. Never folders.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_health_data.dart';

class HealthTimelineScreen extends StatelessWidget {
  const HealthTimelineScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final events = healthTimelineSorted();
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Health')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('Health timeline', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('Aarav’s health story', style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 6),
            _pad(Text('${events.where((e) => !e.upcoming).length} events so far — the whole journey in one place.', style: ppBody(13))),
            const SizedBox(height: 22),
            _pad(Column(children: [
              for (int i = 0; i < events.length; i++) _row(context, events[i], first: i == 0, last: i == events.length - 1),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, HealthEvent e, {bool first = false, bool last = false}) {
    final accent = e.upcoming ? ppCoral : ppPurple;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 40,
          child: Column(children: [
            SizedBox(height: 4, child: first ? null : Container(width: 2, color: ppBorder)),
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: e.upcoming ? ppCoralTint : ppPanel, shape: BoxShape.circle, border: e.upcoming ? Border.all(color: ppCoral, width: 1.5) : null),
              child: Icon(healthEventIcon(e.type), size: 19, color: accent),
            ),
            if (!last) Expanded(child: Container(width: 2, color: ppBorder)),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: () => _detail(context, e),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: e.upcoming ? ppCoral.withValues(alpha: 0.4) : ppHair)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text('${e.upcoming ? 'UPCOMING · ' : ''}${healthEventLabel(e.type).toUpperCase()}', style: ppBody(9.5, color: accent, w: FontWeight.w800).copyWith(letterSpacing: 0.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Text(e.date, style: ppBody(10.5, color: ppMuted)),
                ]),
                const SizedBox(height: 5),
                Text(e.title, style: ppJakarta(15).copyWith(height: 1.2)),
                const SizedBox(height: 5),
                Text(e.summary, style: ppBody(13, h: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
                if (e.doctor != null || e.attachments > 0) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    if (e.doctor != null) ...[
                      const Icon(Icons.person_outline_rounded, size: 13, color: ppMuted),
                      const SizedBox(width: 5),
                      Flexible(child: Text(e.doctor!, style: ppBody(11.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                    if (e.attachments > 0) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.attach_file_rounded, size: 13, color: ppMuted),
                      const SizedBox(width: 4),
                      Text('${e.attachments}', style: ppBody(11.5, color: ppMuted)),
                    ],
                  ]),
                ],
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  void _detail(BuildContext context, HealthEvent e) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Row(children: [
              Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, shape: BoxShape.circle), child: Icon(healthEventIcon(e.type), size: 19, color: ppPurple)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ppEyebrow(healthEventLabel(e.type), color: ppPurple, spacing: 0.8), const SizedBox(height: 3), Text(e.date, style: ppBody(12))])),
            ]),
            const SizedBox(height: 16),
            Text(e.title, style: ppFraunces(21, h: 1.2)),
            const SizedBox(height: 10),
            Text(e.summary, style: ppBody(14.5, color: ppInk, h: 1.6)),
            if (e.doctor != null) ...[const SizedBox(height: 14), _row2(Icons.person_outline_rounded, 'Doctor', e.doctor!)],
            if (e.notes != null) ...[const SizedBox(height: 10), _row2(Icons.sticky_note_2_outlined, 'Notes', e.notes!)],
            if (e.attachments > 0) ...[const SizedBox(height: 10), _row2(Icons.attach_file_rounded, 'Attachments', '${e.attachments} file${e.attachments > 1 ? 's' : ''} on record')],
          ]),
        ),
      ),
    );
  }

  Widget _row2(IconData i, String label, String value) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, size: 16, color: ppMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(TextSpan(children: [
            TextSpan(text: '$label: ', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
            TextSpan(text: value, style: ppBody(13, color: ppSoft)),
          ]), style: const TextStyle(height: 1.5)),
        ),
      ]);
}
