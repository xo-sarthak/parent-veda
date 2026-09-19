// =============================================================================
//  Classes — the masterclasses and cohorts this doctor hosts
// -----------------------------------------------------------------------------
//  Posh's event overview and Luma's manage-event page, reduced to what a host
//  needs on a phone: each class as a card — seats sold of capacity, the next
//  real date (or "no bookings yet"), and one button that is live exactly when
//  the server would let them in. Reached from Home and Profile; classes also
//  appear in Appointments on their day, because a class is a booked hour.
//
//  Attendees are not listed by name. A parent who bought a seat at a class of
//  forty did not sign up to be on a roster the host scrolls; the seat count is
//  the number that matters for teaching.
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_roster.dart';
import '../../doctor/doctor_session.dart';
import '../v2/v2_palette.dart' show v2BlockTint;
import 'doctor_chrome.dart';
import 'doctor_class_launch.dart';

class DoctorClassesScreen extends StatelessWidget {
  const DoctorClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([DoctorSession.instance, DoctorRoster.instance]),
      builder: (context, _) {
        final id = DoctorSession.instance.expertId;
        final sessions = id == null ? const [] : DoctorRoster.instance.sessionsBy(id);
        return DcScreen(
          title: 'Your classes',
          subtitle: sessions.isEmpty ? null : '${sessions.length} you host',
          onRefresh: DoctorRoster.instance.refresh,
          children: [
            if (sessions.isEmpty)
              const DcEmpty(
                'No classes yet',
                'When ParentVeda assigns you a masterclass or a cohort, it appears here with its seats and a Start button that opens 30 minutes before.',
                icon: Icons.school_outlined,
              )
            else
              for (final o in sessions) ...[
                ClassCard(session: hostSessionFor(o)),
                const SizedBox(height: 12),
              ],
          ],
        );
      },
    );
  }
}

/// One class, as the host sees it. Shared with Home.
class ClassCard extends StatelessWidget {
  const ClassCard({super.key, required this.session, this.compact = false});
  final HostSession session;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final h = session;
    final p = dcP;
    final next = h.next;
    final seats = next == null ? null : '${next.booked} of ${next.capacity} seats';
    final when = next == null
        ? 'Not scheduled'
        : h.scheduled
            ? '${dcDayDate(next.startsUtc)} · ${dcTime(next.startsUtc)}'
            : 'No bookings yet · start whenever you are ready';
    final wait = h.minutesUntilOpen;
    return DcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: v2BlockTintFor(h.isCohort), borderRadius: BorderRadius.circular(12)),
            child: Icon(h.isCohort ? Icons.groups_outlined : Icons.school_outlined, size: 21, color: p.ink1),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.offering.title, style: dcStrong(15.5), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('${h.kindLabel}${seats != null ? ' · $seats' : ''}', style: dcMeta(13)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Icon(h.scheduled ? Icons.event_outlined : Icons.podcasts_outlined, size: 16, color: p.ink3),
          const SizedBox(width: 6),
          Expanded(child: Text(when, style: dcMeta(13.5))),
        ]),
        if (!compact) ...[
          const SizedBox(height: 14),
          if (h.openable)
            ObPrimary(p: p, label: h.scheduled ? 'Start class' : 'Go live', onTap: () => openHostSession(context, h))
          else
            ObSecondary(
              p: p,
              label: wait == null
                  ? 'Not scheduled'
                  : wait > 120
                      ? 'Opens ${dcDayDate(next!.startsUtc)} at ${dcTime(next.startsUtc.subtract(const Duration(minutes: 30)))}'
                      : 'Opens in $wait min',
            ),
        ],
      ]),
    );
  }
}

Color v2BlockTintFor(bool cohort) => v2BlockTint(cohort ? 104 : 268, dcP);
