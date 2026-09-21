// =============================================================================
//  Appointments — the doctor's practice, in one list
// -----------------------------------------------------------------------------
//  Restyled from doctor_appointments_screen.dart (kept for revert), whose
//  shape was already right and stays: Today · Upcoming · Past, with Past
//  surfacing the UNFINISHED work — a consultation without a prescription is
//  not really finished, and it is the thing a doctor forgets once the call
//  ends. Jobber's today-view and Apple Store's dated list confirmed the
//  shape in Mobbin audit #8.
//
//  What this adds: classes. A masterclass is a booked hour, so the one the
//  doctor hosts appears in Today/Upcoming on its day, with the same Start
//  rule the Classes screen uses (doctor_class_launch).
//
//  Cancel and no-show go through the SERVER and are reported only on what
//  it answered — the lesson from the old screen, unchanged: a toast written
//  beside a call stays true about an intention long after the action has
//  become a no-op.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../booking/prescription.dart';
import '../../doctor/consult_policy.dart';
import '../../doctor/doctor_reminders.dart';
import '../../doctor/doctor_roster.dart';
import '../../doctor/doctor_session.dart';
import '../../doctor/doctor_hero_images.dart';
import 'doctor_art.dart';
import 'doctor_chrome.dart';
import 'doctor_class_launch.dart';
import 'doctor_task_feed.dart';
import 'doctor_classes_screen.dart';
import 'doctor_prescription_screen.dart';

class DoctorAppointmentsTab extends StatefulWidget {
  const DoctorAppointmentsTab({super.key, required this.goTo});
  final void Function(DoctorTab) goTo;

  /// Which segment the next build opens on — 0 today, 1 upcoming, 2 past.
  /// Set by a task's verb before `goTo(appointments)`: "Write" on the
  /// prescriptions card must land on Past, where the owed ones are, not on
  /// an empty Today (the walk, 2026-09-21). Consumed once, then cleared, so
  /// a later tap on the tab itself opens on Today as usual.
  static int? openOn;

  @override
  State<DoctorAppointmentsTab> createState() => _DoctorAppointmentsTabState();
}

class _DoctorAppointmentsTabState extends State<DoctorAppointmentsTab> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    final asked = DoctorAppointmentsTab.openOn;
    if (asked != null) {
      _tab = asked.clamp(0, 2);
      DoctorAppointmentsTab.openOn = null;
    }
    DoctorRoster.instance.refresh();
    PrescriptionStore.instance.refresh();
  }

  static bool _isToday(DateTime d) {
    final n = DateTime.now();
    final l = d.toLocal();
    return l.year == n.year && l.month == n.month && l.day == n.day;
  }

  Future<void> _pull() async {
    await Future.wait([DoctorRoster.instance.refresh(), PrescriptionStore.instance.refresh()]);
  }

  @override
  Widget build(BuildContext context) {
    final expertId = DoctorSession.instance.expertId;
    if (expertId == null) {
      return const DcTab(title: 'Appointments', children: [
        DcEmpty('No consulting identity', 'An organisation account sees no roster of its own.', mark: DoctorMark.calendar),
      ]);
    }
    return ListenableBuilder(
      listenable: doctorFeedListenable(),
      builder: (context, _) {
        final feed = DoctorFeed.now();
        final roster = DoctorRoster.instance;
        final upcoming = roster.upcomingConsults(expertId);
        final past = roster.pastConsults(expertId);
        final today = upcoming.where((b) => _isToday(b.startsUtc)).toList();
        final later = upcoming.where((b) => !_isToday(b.startsUtc)).toList();
        final hosts = roster.sessionsBy(expertId).map(hostSessionFor).toList();
        final classesToday = hosts.where((h) => h.scheduled && _isToday(h.next!.startsUtc)).toList();
        final classesLater = hosts.where((h) => h.scheduled && !_isToday(h.next!.startsUtc)).toList();
        final unwritten = past.where((b) => !PrescriptionStore.instance.hasFor(b.id)).length;

        final counts = [today.length + classesToday.length, later.length + classesLater.length, past.length];

        return DcTab(
          title: 'Appointments',
          hero: DcHero(
            asset: kDoctorHeroImages['appointments']!.asset,
            eyebrow: 'Appointments',
            greeting: today.isEmpty ? 'Who is next' : (today.length == 1 ? 'One today' : '${today.length} today'),
            infoLine: _summary(today.length, later.length, past.length, unwritten),
            badge: feed.unread,
            onBell: () => feed.openUpdates(context, widget.goTo),
          ),
          onRefresh: _pull,
          children: [
            DcSegments(
              expand: true,
              labels: ['Today (${counts[0]})', 'Upcoming (${counts[1]})', 'Past (${counts[2]})'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 18),
            ...switch (_tab) {
              0 => _day(context, today, classesToday, emptyTitle: 'Nothing today', emptyBody: 'Pull down to check for a new booking. Parents can book up to a few minutes before a slot.'),
              1 => _grouped(context, later, classesLater),
              _ => _past(context, past),
            },
            // Never one card over blank space. When the list is empty the
            // page still teaches how the day will work — the same three
            // facts a doctor asks on their first week.
            if ((_tab == 0 && today.isEmpty && classesToday.isEmpty) ||
                (_tab == 1 && later.isEmpty && classesLater.isEmpty) ||
                (_tab == 2 && past.isEmpty)) ...[
              const SizedBox(height: 10),
              const DcSectionHead('How a consultation works'),
              // Rings, not wells: these rows explain, they do not act.
              const DcRowGroup(children: [
                DcRow(mark: DoctorMark.hours, markRing: true, title: 'Parents book inside your hours', subtitle: 'Set on the Availability tab. Each slot is one consultation.', chevron: false),
                DcRow(mark: DoctorMark.calendar, markRing: true, title: 'You get a reminder an hour before', subtitle: 'And the parent gets one too.', chevron: false),
                DcRow(mark: DoctorMark.video, markRing: true, title: 'Join opens ten minutes before', subtitle: 'From here or from Home. Cancel or mark a no-show from the ⋯ on the card.', chevron: false),
                DcRow(mark: DoctorMark.prescribe, markRing: true, title: 'Write the prescription after', subtitle: 'It lands in the parent\'s app the moment you save.', chevron: false),
              ]),
            ],
          ],
        );
      },
    );
  }

  String _summary(int today, int later, int past, int unwritten) {
    if (today > 0) return '$today today, $later coming up.${unwritten > 0 ? ' $unwritten need a prescription.' : ''}';
    if (later > 0) return 'Nothing today. $later coming up.';
    if (past > 0) return 'Nothing coming up. $past past${unwritten > 0 ? ', $unwritten needing a prescription' : ''}.';
    return 'No consultations booked yet.';
  }

  List<Widget> _day(BuildContext context, List<Booking> calls, List<HostSession> classes, {required String emptyTitle, required String emptyBody}) {
    if (calls.isEmpty && classes.isEmpty) {
      return [DcEmpty(emptyTitle, emptyBody, mark: DoctorMark.calendar)];
    }
    final items = <(DateTime, Widget)>[
      for (final b in calls) (b.startsUtc, _ConsultCard(booking: b, past: false, onMore: () => _openActions(b))),
      for (final h in classes) (h.next!.startsUtc, ClassCard(session: h)),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final i in items) ...[i.$2, const SizedBox(height: 12)]];
  }

  List<Widget> _grouped(BuildContext context, List<Booking> calls, List<HostSession> classes) {
    if (calls.isEmpty && classes.isEmpty) {
      return const [DcEmpty('Nothing coming up', 'When a parent books a slot with you, it appears here.', mark: DoctorMark.calendar)];
    }
    final items = <(DateTime, Widget)>[
      for (final b in calls) (b.startsUtc, _ConsultCard(booking: b, past: false, onMore: () => _openActions(b))),
      for (final h in classes) (h.next!.startsUtc, ClassCard(session: h, compact: true)),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    final out = <Widget>[];
    String? lastDay;
    for (final i in items) {
      final d = dcDayDate(i.$1);
      if (d != lastDay) {
        out.add(DcSectionHead(d));
        lastDay = d;
      }
      out..add(i.$2)..add(const SizedBox(height: 12));
    }
    return out;
  }

  List<Widget> _past(BuildContext context, List<Booking> past) {
    if (past.isEmpty) {
      return const [DcEmpty('No past consultations', 'Finished consultations, and the ones still needing a prescription, live here.', mark: DoctorMark.prescribe)];
    }
    final owed = past.where((b) => !PrescriptionStore.instance.hasFor(b.id) && b.status != BookingStatus.cancelled).toList();
    final rest = past.where((b) => !owed.contains(b)).toList();
    return [
      if (owed.isNotEmpty) ...[
        const DcSectionHead('Needs a prescription'),
        for (final b in owed) ...[_ConsultCard(booking: b, past: true, onMore: () => _openActions(b)), const SizedBox(height: 12)],
        const SizedBox(height: 8),
        if (rest.isNotEmpty) const DcSectionHead('Done'),
      ],
      for (final b in rest) ...[_ConsultCard(booking: b, past: true, onMore: () => _openActions(b)), const SizedBox(height: 12)],
    ];
  }

  // ---- actions --------------------------------------------------------------

  Future<void> _openActions(Booking b) async {
    final canNoShow = ConsultPolicy.mayMarkNoShow(b);
    final canCancel = ConsultPolicy.mayCancel(b);
    final hasRx = PrescriptionStore.instance.hasFor(b.id);
    await dcSheet<void>(
      context,
      title: 'This consultation',
      child: DcRowGroup(children: [
        if (canCancel)
          DcRow(
            mark: DoctorMark.cancelled,
            title: 'Cancel this consultation',
            subtitle: 'The parent gets their full credit back straight away. Use this if you cannot make it.',
            chevron: false,
            onTap: () {
              Navigator.of(context).pop();
              _resolve(b, DoctorOutcome.cancelled);
            },
          ),
        DcRow(
          mark: DoctorMark.noShow,
          markMuted: !canNoShow,
          title: 'Mark as no-show',
          subtitle: canNoShow
              ? 'The parent did not join. You are still paid for the slot you held.'
              : 'Available 10 minutes after the start time — a few minutes late is not a no-show.',
          chevron: false,
          titleColor: canNoShow ? null : dcP.ink3,
          onTap: canNoShow
              ? () {
                  Navigator.of(context).pop();
                  _resolve(b, DoctorOutcome.missed);
                }
              : null,
        ),
        if (!canCancel)
          DcRow(
            mark: hasRx ? DoctorMark.done : DoctorMark.prescribe,
            title: hasRx ? 'View the prescription' : 'Write the prescription',
            subtitle: hasRx ? 'What you sent the parent after this consultation.' : 'Finished, but nothing sent to the parent yet.',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'doctor/prescribe'),
                builder: (_) => DoctorPrescriptionScreen(bookingId: b.id, title: b.title, backLabel: 'Appointments'),
              ));
            },
          ),
      ]),
    );
  }

  /// Through the SERVER, and claimed only on the strength of its answer.
  Future<void> _resolve(Booking b, DoctorOutcome outcome) async {
    final code = await BookingStore.instance.expertResolve(b.id, outcome);
    DoctorReminders.instance.cancelFor(b.id);
    await DoctorRoster.instance.refresh();
    if (!mounted) return;
    setState(() {});
    final msg = switch (code) {
      'ok' => outcome == DoctorOutcome.cancelled
          ? 'Cancelled. The parent has their credit back.'
          : 'Marked as a no-show. You are still paid for this slot.',
      'already_cancelled' => 'This consultation was already cancelled.',
      'already_missed' => 'This consultation was already marked a no-show.',
      'not_your_patient' => 'This booking is not on your roster. Pull to refresh and retry.',
      'not_authenticated' => 'You are signed out. Sign in and try again.',
      _ => 'Could not update this consultation. Please try again.',
    };
    dcToast(context, msg);
  }
}

/// One consultation. Upcoming: who, when, Join and more. Past: who, when,
/// the prescription state and a way to write it.
class _ConsultCard extends StatelessWidget {
  const _ConsultCard({required this.booking, required this.past, required this.onMore});
  final Booking booking;
  final bool past;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final p = dcP;
    final patient = DoctorRoster.instance.patientFor(b.id, stage: b.stage);
    final hasRx = PrescriptionStore.instance.hasFor(b.id);
    final ctx = patient.contextLine(b.startsUtc);
    final mins = b.startsUtc.toLocal().difference(DateTime.now()).inMinutes;
    final soon = !past && mins <= 15 && mins >= -60;
    final cancelled = b.status == BookingStatus.cancelled;

    final (status, hue) = switch (b.status) {
      BookingStatus.cancelled => ('Cancelled', 344.0),
      _ when past && !hasRx => ('Needs a prescription', 42.0),
      _ when past => ('Done', 104.0),
      _ when soon => ('Starting', 104.0),
      _ => ('Confirmed', null),
    };

    return DcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(14)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(dcTime(b.startsUtc).split(' ').first, style: dcStrong(13)),
              Text(dcTime(b.startsUtc).split(' ').last, style: dcMeta(10.5)),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(patient.displayName, style: dcStrong(16, color: cancelled ? p.ink3 : null), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                past ? dcDayDate(b.startsUtc) : (ctx.isNotEmpty ? ctx : '${b.durationMin} min'),
                style: dcMeta(13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          const SizedBox(width: 8),
          DcStatusPill(status, hue: hue),
        ]),
        if (!cancelled) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: past
                  ? ObSecondary(
                      p: p,
                      label: hasRx ? 'View prescription' : 'Write prescription',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                          settings: const RouteSettings(name: 'doctor/prescribe'),
                          builder: (_) => DoctorPrescriptionScreen(bookingId: b.id, title: b.title, backLabel: 'Appointments'))),
                    )
                  : ObPrimary(
                      p: p,
                      label: soon ? 'Join now' : 'Join',
                      leading: Icon(Icons.videocam_rounded, size: 18, color: p.surface),
                      onTap: () => openConsult(context, b, waitingFor: patient.displayName),
                    ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 52,
              height: 52,
              child: Material(
                color: Colors.transparent,
                shape: CircleBorder(side: BorderSide(color: p.line, width: 1.2)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onMore,
                  child: Icon(Icons.more_horiz_rounded, color: p.ink1),
                ),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}
