// =============================================================================
//  Updates — the panel behind the bell
// -----------------------------------------------------------------------------
//  Monzo's feed and Deel's notifications: a plain dated list grouped Today /
//  This week / Earlier, one drawn mark per kind, the unread ones in full ink
//  and the read ones quieter. Opening the panel marks everything on it read,
//  so the bell's number means "since you last looked" and nothing else.
//
//  Chores are NOT here — a prescription owed, a bank account missing — they
//  are the "Needs you" rail on Home (2026-09-21, the user: "a bell is a
//  notification panel"). What is here is news: a parent booked, a call is
//  about to start, a class is next week, money came in, a payout went out,
//  a word from ParentVeda. All of it derived from rows the app holds —
//  lib/doctor/doctor_updates.dart.
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_updates.dart';
import 'doctor_art.dart';
import 'doctor_chrome.dart';

class DoctorUpdatesScreen extends StatefulWidget {
  const DoctorUpdatesScreen({super.key, required this.updates, required this.onOpen});
  final List<DoctorUpdate> updates;
  final void Function(BuildContext context, DoctorUpdate update) onOpen;

  @override
  State<DoctorUpdatesScreen> createState() => _DoctorUpdatesScreenState();
}

class _DoctorUpdatesScreenState extends State<DoctorUpdatesScreen> {
  /// What was unread when the panel opened — those rows stay in full ink for
  /// this visit even though they are marked read the moment it opens.
  late final Set<String> _freshIds;

  @override
  void initState() {
    super.initState();
    final read = DoctorUpdatesRead.instance;
    _freshIds = {for (final u in widget.updates) if (!read.isRead(u.id)) u.id};
    WidgetsBinding.instance.addPostFrameCallback((_) => read.markAllRead(widget.updates));
  }

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 6));
    final today = <DoctorUpdate>[];
    final week = <DoctorUpdate>[];
    final earlier = <DoctorUpdate>[];
    for (final u in widget.updates) {
      if (!u.at.isBefore(todayStart)) {
        today.add(u);
      } else if (!u.at.isBefore(weekStart)) {
        week.add(u);
      } else {
        earlier.add(u);
      }
    }
    final fresh = _freshIds.length;
    return DcScreen(
      title: 'Updates',
      subtitle: widget.updates.isEmpty
          ? 'Nothing yet'
          : fresh == 0
              ? 'You are up to date'
              : '$fresh new since you last looked',
      children: [
        if (widget.updates.isEmpty)
          const DcEmpty(
            'Nothing yet',
            'When a parent books, a class is coming up, money comes in or a payout goes out, it appears here.',
            mark: DoctorMark.inbox,
          ),
        for (final (label, list) in [('Today', today), ('This week', week), ('Earlier', earlier)])
          if (list.isNotEmpty) ...[
            DcSectionHead(label),
            DcRowGroup(children: [
              for (final u in list)
                DcRow(
                  mark: _markFor(u.kind),
                  title: u.title,
                  titleColor: _freshIds.contains(u.id) ? null : p.ink2,
                  subtitle: '${u.body} · ${_when(u.at, now)}',
                  onTap: () => widget.onOpen(context, u),
                ),
            ]),
            const SizedBox(height: 22),
          ],
      ],
    );
  }

  static DoctorMark _markFor(DoctorUpdateKind k) => switch (k) {
        DoctorUpdateKind.booking => DoctorMark.calendar,
        DoctorUpdateKind.callSoon => DoctorMark.video,
        DoctorUpdateKind.classSoon => DoctorMark.classes,
        DoctorUpdateKind.earning => DoctorMark.earnings,
        DoctorUpdateKind.reversal => DoctorMark.earnings,
        DoctorUpdateKind.payout => DoctorMark.bank,
        DoctorUpdateKind.payoutScheduled => DoctorMark.bank,
        DoctorUpdateKind.notice => DoctorMark.inbox,
      };

  /// "just now", "2h ago", "yesterday", "14 Sep".
  static String _when(DateTime at, DateTime now) {
    final d = now.difference(at);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24 && at.day == now.day) return '${d.inHours}h ago';
    final y = now.subtract(const Duration(days: 1));
    if (at.year == y.year && at.month == y.month && at.day == y.day) return 'yesterday';
    return dcDate(at);
  }
}
