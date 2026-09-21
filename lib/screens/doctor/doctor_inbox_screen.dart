// =============================================================================
//  Inbox — everything that needs the doctor, in one list
// -----------------------------------------------------------------------------
//  Opened from the bell in the Home hero and from "See all" under Needs you.
//  Asana's "My tasks" and Greenlight's notifications list: rows, the urgent
//  ones first, each with one verb. Setup items she has finished are shown
//  ticked at the bottom rather than hidden, so the list also reads as
//  "what I have done" — a doctor's first week is mostly that.
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_tasks.dart';
import 'doctor_art.dart';
import 'doctor_chrome.dart';

class DoctorInboxScreen extends StatelessWidget {
  const DoctorInboxScreen({super.key, required this.tasks, required this.onTask});
  final List<DoctorTask> tasks;
  final void Function(BuildContext context, DoctorTask task) onTask;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final pending = tasks.pending;
    final done = tasks.where((t) => t.done).toList();
    return DcScreen(
      title: 'Needs you',
      subtitle: pending.isEmpty ? 'You are all caught up' : '${pending.length} ${pending.length == 1 ? 'thing' : 'things'}',
      children: [
        if (pending.isEmpty)
          const DcEmpty(
            'Nothing waiting',
            'Prescriptions owed, a class about to open, a paused calendar — anything that needs you lands here.',
            mark: DoctorMark.done,
          )
        else
          DcRowGroup(children: [
            for (final t in pending)
              DcRow(
                mark: doctorMarkForTask(t.id),
                title: t.title,
                subtitle: t.body,
                trailing: Text(t.action, style: dcStrong(14, color: p.action)),
                onTap: () => onTask(context, t),
              ),
          ]),
        if (done.isNotEmpty) ...[
          const SizedBox(height: 22),
          const DcSectionHead('Done'),
          DcRowGroup(children: [
            for (final t in done)
              DcRow(
                leading: DoctorArtTile(mark: DoctorMark.done, p: p, size: 44, radius: 13, muted: true),
                title: t.title,
                titleColor: p.ink3,
                chevron: false,
              ),
          ]),
        ],
      ],
    );
  }
}
