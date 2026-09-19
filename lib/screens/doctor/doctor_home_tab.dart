// =============================================================================
//  Home — what needs attention, then what is coming
// -----------------------------------------------------------------------------
//  Airbnb's host Today tab and Future Pro's coach home, in that order:
//
//     Good morning, Dr Meera             ← who, and the one line under it
//     [Needs your attention]             ← 0..n rows, each ONE action:
//         add your bank account · a prescription owed · a class opening ·
//         no hours set · bookings paused
//     NEXT UP — the next consult as one big card with Join and Prescribe
//     LATER TODAY — the rest of the day as rows
//     THIS WEEK — calls · classes · we owe you        (taps into the tabs)
//     YOUR CLASSES — the next one, → all
//     TAKING BOOKINGS — the switch and the week in one line, → Availability
//
//  Nothing here is a second implementation: join goes through the same
//  green room as Appointments (doctor_class_launch), the money is the
//  ledger's, the hours are the schedule store's. The old dashboard
//  (doctor_home_screen.dart) is kept for revert; the stage toggle it carried
//  for testing now lives under Profile → Developer.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_models.dart';
import '../../booking/prescription.dart';
import '../../care_partner/care_partner_models.dart';
import '../../care_partner/partner_dashboard_store.dart';
import '../../doctor/doctor_directory.dart';
import '../../doctor/doctor_ledger.dart';
import '../../doctor/doctor_roster.dart';
import '../../doctor/doctor_schedule.dart';
import '../../doctor/doctor_schedule_store.dart';
import '../../doctor/doctor_session.dart';
import 'doctor_chrome.dart';
import 'doctor_class_launch.dart';
import 'doctor_classes_screen.dart';
import 'doctor_payout_account_screen.dart';
import 'doctor_prescription_screen.dart';

/// The scaffold's tabs, so Home can send the doctor to one by name rather
/// than by an index that would silently point elsewhere if the order changed.
enum DoctorTab { home, appointments, availability, earnings, profile }

class DoctorHomeTab extends StatelessWidget {
  const DoctorHomeTab({super.key, required this.goTo});
  final void Function(DoctorTab tab) goTo;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        DoctorSession.instance,
        DoctorRoster.instance,
        DoctorScheduleStore.instance,
        DoctorLedger.instance,
        PrescriptionStore.instance,
      ]),
      builder: (context, _) {
        final session = DoctorSession.instance;
        final e = session.consults ? doctorInfoById(session.expertId!) : null;
        final partner = PartnerDashboardStore.instance.partner;
        final name = e?.name ?? partner?.name ?? 'Your practice';
        final sub = e?.credential ?? (partner == null ? '' : CarePartnerType.label(partner.type));

        final roster = DoctorRoster.instance;
        final upcoming = e == null ? const <Booking>[] : roster.upcomingConsults(e.id);
        final past = e == null ? const <Booking>[] : roster.pastConsults(e.id);
        final sessions = e == null ? const <Offering>[] : roster.sessionsBy(e.id);
        final hosts = sessions.map(hostSessionFor).toList();
        final schedule = e == null ? null : DoctorScheduleStore.instance.scheduleFor(e.id);
        final ledger = DoctorLedger.instance;

        final now = DateTime.now();
        final todayEnd = DateTime(now.year, now.month, now.day + 1);
        final weekEnd = DateTime(now.year, now.month, now.day + 7);
        final today = upcoming.where((b) => b.startsUtc.toLocal().isBefore(todayEnd)).toList();
        final next = upcoming.isEmpty ? null : upcoming.first;
        final laterToday = today.where((b) => b != next).toList();
        final thisWeek = upcoming.where((b) => b.startsUtc.toLocal().isBefore(weekEnd)).length;
        final owedRx = past.where((b) => !PrescriptionStore.instance.hasFor(b.id)).length;
        final liveClass = hosts.where((h) => h.openable && h.scheduled).toList();

        final attention = <Widget>[
          if (ledger.accountKnown && ledger.account == null)
            DcAttention(
              icon: Icons.account_balance_outlined,
              title: 'Add your bank account',
              body: 'Required to get paid.',
              action: 'Add account',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  settings: const RouteSettings(name: 'doctor/payout-account'),
                  builder: (_) => const DoctorPayoutAccountScreen())),
            ),
          for (final h in liveClass)
            DcAttention(
              icon: Icons.podcasts_outlined,
              urgent: true,
              title: '${h.offering.title} is open',
              body: '${h.next!.booked} booked · starts ${dcTime(h.next!.startsUtc)}',
              action: 'Start class',
              onTap: () => openHostSession(context, h),
            ),
          if (owedRx > 0)
            DcAttention(
              icon: Icons.edit_note_rounded,
              title: owedRx == 1 ? 'A prescription is waiting' : '$owedRx prescriptions are waiting',
              body: 'Past consultations without one. Parents see it in their app the moment you save.',
              action: 'Write them',
              onTap: () => goTo(DoctorTab.appointments),
            ),
          if (schedule != null && !schedule.hasAnyHours)
            DcAttention(
              icon: Icons.schedule_outlined,
              title: 'Set your hours',
              body: 'Parents cannot book you until you say when you are free.',
              action: 'Set hours',
              onTap: () => goTo(DoctorTab.availability),
            )
          else if (schedule != null && schedule.paused)
            DcAttention(
              icon: Icons.pause_circle_outline_rounded,
              title: 'You are not taking bookings',
              body: 'Your hours are set but paused. Parents see no slots.',
              action: 'Resume',
              onTap: () => goTo(DoctorTab.availability),
            ),
        ];

        // A doctor is greeted by name; an organisation is greeted, then named
        // in full on the line beneath — "Good morning, Nova" would read as a
        // person, and a partner with no consulting identity must never be
        // shown as one (partner_account_test holds this).
        return DcTab(
          title: e != null ? _greeting(name) : _greeting(null),
          subtitle: e != null ? (sub.isEmpty ? null : sub) : name,
          onRefresh: () async {
            await Future.wait([roster.refresh(), ledger.refresh()]);
          },
          children: [
            if (attention.isNotEmpty) ...[
              const DcSectionHead('Needs your attention'),
              for (final w in attention) ...[w, const SizedBox(height: 10)],
              const SizedBox(height: 12),
            ],

            // ---- next up ---------------------------------------------------
            DcSectionHead(next == null ? 'Today' : (today.contains(next) ? 'Next up' : 'Next consultation')),
            if (next == null)
              DcEmpty(
                'No consultations booked',
                schedule == null || !schedule.hasAnyHours
                    ? 'Set your hours and parents can book you.'
                    : 'When a parent books a slot with you, it appears here with a Join button.',
                icon: Icons.videocam_outlined,
                action: schedule == null || !schedule.hasAnyHours ? 'Set hours' : null,
                onAction: schedule == null || !schedule.hasAnyHours ? () => goTo(DoctorTab.availability) : null,
              )
            else
              _NextCard(booking: next),
            if (laterToday.isNotEmpty) ...[
              const SizedBox(height: 16),
              const DcSectionHead('Later today'),
              DcRowGroup(children: [
                for (final b in laterToday) _consultRow(context, b),
              ]),
            ],
            const SizedBox(height: 22),

            // ---- this week --------------------------------------------------
            const DcSectionHead('This week'),
            DcStatRow([
              DcStat('Consults', '$thisWeek', sub: 'next 7 days'),
              DcStat('Classes', '${sessions.length}', sub: sessions.isEmpty ? 'none assigned' : 'you host'),
              DcStat('We owe you', dcRupees(ledger.summary.owedPaise),
                  sub: ledger.summary.nextPayout == null ? 'next payout' : 'on ${dcDate(ledger.summary.nextPayout!)}'),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 18, children: [
              _link(context, 'Appointments', () => goTo(DoctorTab.appointments)),
              _link(context, 'Earnings', () => goTo(DoctorTab.earnings)),
            ]),
            const SizedBox(height: 22),

            // ---- classes ----------------------------------------------------
            DcSectionHead('Your classes',
                note: hosts.length > 1 ? 'All ${hosts.length}' : (hosts.isEmpty ? null : 'Open'),
                onNote: hosts.isEmpty ? null : () => _openClasses(context)),
            if (hosts.isEmpty)
              const DcEmpty(
                'No classes yet',
                'When ParentVeda assigns you a masterclass or a cohort, it appears here with its seats and a Start button.',
                icon: Icons.school_outlined,
              )
            else
              ClassCard(session: _soonest(hosts)),
            const SizedBox(height: 22),

            // ---- availability -----------------------------------------------
            if (schedule != null) ...[
              const DcSectionHead('Availability'),
              DcRowGroup(children: [
                DcSwitchRow(
                  icon: Icons.schedule_outlined,
                  title: schedule.paused ? 'Not taking bookings' : 'Taking bookings',
                  subtitle: _weekLine(schedule),
                  value: !schedule.paused,
                  onChanged: (on) {
                    DoctorScheduleStore.instance.save(e!.id, schedule.copyWith(paused: !on));
                    dcToast(context, on ? 'Taking bookings again.' : 'Bookings paused. Existing ones stand.');
                  },
                ),
                DcRow(
                  title: 'Change hours, rules or time off',
                  onTap: () => goTo(DoctorTab.availability),
                ),
              ]),
            ],
          ],
        );
      },
    );
  }

  Widget _link(BuildContext context, String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: dcStrong(14, color: dcP.action)),
            Icon(Icons.chevron_right_rounded, size: 18, color: dcP.action),
          ]),
        ),
      );

  Widget _consultRow(BuildContext context, Booking b) {
    final patient = DoctorRoster.instance.patientFor(b.id, stage: b.stage);
    return DcRow(
      icon: Icons.person_outline_rounded,
      title: patient.displayName,
      subtitle: '${dcTime(b.startsUtc)} · ${b.durationMin} min',
      onTap: () => openConsult(context, b, waitingFor: patient.displayName),
    );
  }

  void _openClasses(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
      settings: const RouteSettings(name: 'doctor/classes'),
      builder: (_) => const DoctorClassesScreen()));

  static HostSession _soonest(List<HostSession> hosts) {
    final sorted = [...hosts]..sort((a, b) {
        if (a.openable != b.openable) return a.openable ? -1 : 1;
        final ad = a.scheduled ? a.next!.startsUtc : DateTime(2100);
        final bd = b.scheduled ? b.next!.startsUtc : DateTime(2100);
        return ad.compareTo(bd);
      });
    return sorted.first;
  }

  static String _greeting(String? name) {
    final h = DateTime.now().hour;
    final g = h < 12 ? 'Good morning' : h < 17 ? 'Good afternoon' : 'Good evening';
    if (name == null) return g;
    final short = name.replaceAll(RegExp(r'^(Dr|Prof)\.?\s*'), '').trim().split(' ').first;
    return short.isEmpty ? g : '$g, ${name.startsWith('Dr') ? 'Dr $short' : short}';
  }

  /// "Mon–Sat · 10:00 am–1:00 pm, 5:00–8:00 pm" — the week in one line.
  static String _weekLine(DoctorSchedule s) {
    if (!s.hasAnyHours) return 'No hours set';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final working = [for (var d = 1; d <= 7; d++) if (s.dayFor(d).isWorking) d];
    final contiguous = working.length == working.last - working.first + 1;
    final days = contiguous && working.length > 2
        ? '${names[working.first - 1]}–${names[working.last - 1]}'
        : working.map((d) => names[d - 1]).join(', ');
    final first = s.dayFor(working.first).sessions;
    final same = working.every((d) => s.dayFor(d).sessions.toString() == first.toString());
    final hours = same ? first.map(_compactSession).join(', ') : 'hours vary by day';
    return '$days · $hours';
  }

  /// "10am–1pm", "5–8pm": the meridian once when both ends share it, and no
  /// ":00". Walked 2026-09-18: the full form ran to "5:00 PM–8:…" beside the
  /// switch, and a clinician does not need the zeros.
  static String _compactSession(Session x) {
    String part(int m, {required bool withMeridian}) {
      final h24 = (m ~/ 60) % 24;
      final mm = m % 60;
      final h = h24 % 12 == 0 ? 12 : h24 % 12;
      final min = mm == 0 ? '' : ':${mm.toString().padLeft(2, '0')}';
      return '$h$min${withMeridian ? (h24 < 12 ? 'am' : 'pm') : ''}';
    }
    final sameHalf = ((x.start ~/ 60) % 24 < 12) == ((x.end ~/ 60) % 24 < 12);
    return '${part(x.start, withMeridian: !sameHalf)}–${part(x.end, withMeridian: true)}';
  }
}

/// The next consultation as one card: who, when, Join and Prescribe.
class _NextCard extends StatelessWidget {
  const _NextCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final p = dcP;
    final patient = DoctorRoster.instance.patientFor(b.id, stage: b.stage);
    final ctx = patient.contextLine(b.startsUtc);
    final now = DateTime.now();
    final start = b.startsUtc.toLocal();
    final isToday = start.year == now.year && start.month == now.month && start.day == now.day;
    final mins = start.difference(now).inMinutes;
    final soon = mins <= 10 && mins >= -b.durationMin;
    return DcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.surfaceAlt, shape: BoxShape.circle),
            child: Text(patient.displayName.characters.first.toUpperCase(), style: dcNum(20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(patient.displayName, style: dcStrong(17), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (ctx.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(ctx, style: dcMeta(13.5), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Icon(Icons.event_outlined, size: 16, color: p.ink3),
          const SizedBox(width: 6),
          Text(
            isToday
                ? 'Today · ${dcTime(b.startsUtc)} · ${b.durationMin} min'
                : '${dcDayDate(b.startsUtc)} · ${dcTime(b.startsUtc)} · ${b.durationMin} min',
            style: dcStrong(14),
          ),
          if (soon) ...[
            const SizedBox(width: 10),
            const DcStatusPill('Starting', hue: 104),
          ],
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: ObPrimary(
              p: p,
              label: soon ? 'Join now' : 'Join',
              leading: Icon(Icons.videocam_rounded, size: 18, color: p.surface),
              onTap: () => openConsult(context, b, waitingFor: patient.displayName),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ObSecondary(
              p: p,
              label: 'Prescribe',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'doctor/prescribe'),
                  builder: (_) => DoctorPrescriptionScreen(bookingId: b.id, title: b.title))),
            ),
          ),
        ]),
      ]),
    );
  }
}
