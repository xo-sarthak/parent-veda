// =============================================================================
//  Appointments — the doctor's practice, in one list
// -----------------------------------------------------------------------------
//  The doctor app had a dashboard, earnings, availability and a profile, but
//  nowhere to actually WORK THROUGH the day. A doctor's real question is not
//  "how am I doing?" - it is "who is next, and what do I do about them?".
//
//  Three buckets, because that is how a clinic day is actually organised:
//     Today    - what is happening now, in order, with Join
//     Upcoming - everything after today
//     Past     - done, and what still needs a prescription written
//
//  The Past tab deliberately surfaces UNFINISHED work: a consultation with no
//  prescription is not really finished, and it is the thing a doctor forgets
//  once the call ends.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_models.dart';
import '../../booking/call_screen.dart';
import '../../booking/booking_store.dart';
import '../../booking/prescription.dart';
import '../../doctor/consult_policy.dart';
import '../../doctor/doctor_reminders.dart';
import '../../doctor/doctor_roster.dart';
import '../../doctor/doctor_session.dart';
import '../post_pregnancy/pp_common.dart';
import '../post_pregnancy/pp_experts_data.dart';
import '../../widgets/global_ask_fab.dart' show kCallRoute;
import 'doctor_prescription_screen.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    DoctorRoster.instance.refresh();
  }

  static bool _isToday(DateTime d) {
    final n = DateTime.now();
    final l = d.toLocal();
    return l.year == n.year && l.month == n.month && l.day == n.day;
  }

  @override
  Widget build(BuildContext context) {
    final expertId = DoctorSession.instance.expertId;
    if (expertId == null) {
      return Center(child: Text('Not signed in as a doctor', style: ppBody(13)));
    }

    return AnimatedBuilder(
      animation: Listenable.merge(
          [DoctorRoster.instance, PrescriptionStore.instance]),
      builder: (context, _) {
        final upcoming = DoctorRoster.instance.upcomingConsults(expertId);
        final past = DoctorRoster.instance.pastConsults(expertId);
        final today = upcoming.where((b) => _isToday(b.startsUtc)).toList();
        final later = upcoming.where((b) => !_isToday(b.startsUtc)).toList();

        final list = switch (_tab) {
          0 => today,
          1 => later,
          _ => past,
        };

        return RefreshIndicator(
          onRefresh: _pullToRefresh,
          color: ppPurple,
          child: ListView(
          // The pull has to work on an empty afternoon too — that is precisely
          // when a doctor wants to check whether a booking has landed.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            ppEyebrow('YOUR PRACTICE', color: ppPurple),
            const SizedBox(height: 8),
            Text('Appointments', style: ppFraunces(26, h: 1.1)),
            const SizedBox(height: 6),
            Text(_summary(today.length, later.length, past),
                style: ppBody(13, h: 1.5)),
            const SizedBox(height: 16),
            _tabs(today.length, later.length, past.length),
            const SizedBox(height: 18),
            if (list.isEmpty)
              _empty()
            else
              for (final b in list) _card(b, past: _tab == 2),
          ],
        ),
        );
      },
    );
  }

  Future<void> _pullToRefresh() async {
    await Future.wait([
      DoctorRoster.instance.refresh(),
      PrescriptionStore.instance.refresh(),
    ]);
  }

  String _summary(int today, int later, List<Booking> past) {
    final unwritten =
        past.where((b) => !PrescriptionStore.instance.hasFor(b.id)).length;
    if (today > 0) {
      return '$today today, $later coming up.'
          '${unwritten > 0 ? ' $unwritten still need a prescription.' : ''}';
    }
    if (later > 0) return 'Nothing today. $later coming up.';
    return 'No consultations booked yet.';
  }

  Widget _tabs(int today, int later, int past) => Container(
        padding: const EdgeInsets.all(4),
        decoration:
            BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(13)),
        child: Row(children: [
          for (final (i, label, n) in [
            (0, 'Today', today),
            (1, 'Upcoming', later),
            (2, 'Past', past),
          ])
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
                  child: Text(n > 0 ? '$label ($n)' : label,
                      style: ppJakarta(12.5,
                          color: _tab == i ? ppTitleInk : ppSoft)),
                ),
              ),
            ),
        ]),
      );

  Widget _empty() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ppBorder)),
        child: Column(children: [
          const Icon(Icons.event_available_outlined, size: 26, color: ppMuted),
          const SizedBox(height: 10),
          Text(
            switch (_tab) {
              0 => 'Nothing booked for today.',
              1 => 'No upcoming consultations.',
              _ => 'No past consultations yet.',
            },
            style: ppJakarta(13.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            switch (_tab) {
              0 => 'A free day. Parents can still book you if your hours are open.',
              1 => 'Open more hours in Availability and parents can book them.',
              _ => 'Completed consultations will collect here.',
            },
            style: ppBody(12, h: 1.45),
            textAlign: TextAlign.center,
          ),
        ]),
      );

  // ---- one appointment ------------------------------------------------------

  /// The name the parent sees over this doctor's video. Read from the session
  /// rather than passed down, because the identity is the ACCOUNT — the same
  /// reason DoctorAuthScreen has no "sign in as which doctor?" picker.
  String? _myName() {
    final id = DoctorSession.instance.expertId;
    return (id == null || id.isEmpty) ? null : expertById(id).name;
  }

  Widget _card(Booking b, {required bool past}) {
    final start = b.startsUtc.toLocal();
    final patient = DoctorRoster.instance.patientFor(b.id, stage: b.stage);
    final hasRx = PrescriptionStore.instance.hasFor(b.id);
    final soon = !past &&
        start.difference(DateTime.now()).inMinutes <= 15 &&
        start.difference(DateTime.now()).inMinutes >= -60;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: soon ? ppPurple : ppBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: ppPanel, borderRadius: BorderRadius.circular(13)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${start.day}', style: ppJakarta(14)),
                Text(_month(start.month), style: ppBody(9, color: ppMuted)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // WHO, not what. This used to print b.title, which for a
                    // consult is "Consult · <this doctor's own name>" - so the
                    // doctor read their own name on every row.
                    Text(patient.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ppJakarta(14)),
                    const SizedBox(height: 2),
                    Text(patient.contextLine(start),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ppBody(11.5, color: ppPurple)),
                    const SizedBox(height: 3),
                    Text('${_time(start)} · ${b.durationMin} min',
                        style: ppBody(12)),
                  ]),
            ),
            _statusPill(b, past: past, hasRx: hasRx),
            if (b.status == BookingStatus.upcoming)
              GestureDetector(
                onTap: () => _openActions(b),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.more_vert_rounded, size: 18, color: ppMuted),
                ),
              ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            if (!past) ...[
              Expanded(
                child: _action(
                  soon ? 'Join now' : 'Join',
                  Icons.videocam_rounded,
                  filled: soon,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      // Doctor mode is reachable inside the PARENT build too,
                      // where the Ask FAB floats above the Navigator.
                      settings: const RouteSettings(name: kCallRoute),
                      builder: (_) => CallScreen(
                        bookingId: b.id,
                        title: b.title,
                        // The doctor announces themselves, and waits for the
                        // parent by name — the roster already resolved it, so
                        // neither side has to see "Guest".
                        displayName: _myName(),
                        waitingFor: patient.name.isEmpty ? null : patient.name,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: _action(
                hasRx ? 'View prescription' : 'Write prescription',
                hasRx ? Icons.description_outlined : Icons.edit_note_rounded,
                filled: past && !hasRx,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        DoctorPrescriptionScreen(bookingId: b.id, title: b.title),
                  ),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  /// Cancelling and no-shows, with the consequence stated BEFORE the tap.
  /// A doctor should never have to guess what happens to the parent's money.
  Future<void> _openActions(Booking b) async {
    final canNoShow = ConsultPolicy.mayMarkNoShow(b);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                    color: ppLine, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 18),
            _sheetAction(
              icon: Icons.event_busy_rounded,
              colour: ppCoral,
              title: 'Cancel this consultation',
              body: 'The parent gets their full credit back straight away and '
                  'can book any other time. Use this if you cannot make it.',
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _cancelAsDoctor(b);
              },
            ),
            const SizedBox(height: 12),
            _sheetAction(
              icon: Icons.person_off_outlined,
              colour: canNoShow ? ppBrown : ppMuted,
              enabled: canNoShow,
              title: 'Mark as no-show',
              body: canNoShow
                  ? 'The parent did not join. You are still paid for the slot '
                      'you held, and their credit is used.'
                  : 'Available 10 minutes after the start time - joining a '
                      'few minutes late is not a no-show.',
              onTap: canNoShow
                  ? () {
                      Navigator.of(sheetCtx).pop();
                      _markNoShow(b);
                    }
                  : null,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sheetAction({
    required IconData icon,
    required Color colour,
    required String title,
    required String body,
    VoidCallback? onTap,
    bool enabled = true,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: enabled ? ppBorder : ppHair),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 19, color: colour),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: ppJakarta(13.5,
                            color: enabled ? ppTitleInk : ppMuted)),
                    const SizedBox(height: 3),
                    Text(body, style: ppBody(11.5, h: 1.45)),
                  ]),
            ),
          ]),
        ),
      );

  void _cancelAsDoctor(Booking b) {
    final r = ConsultPolicy.doctorCancels(b);
    BookingStore.instance.cancel(b.id, refundCredit: r.creditReturned);
    DoctorReminders.instance.cancelFor(b.id);
    DoctorRoster.instance.refresh();
    if (!mounted) return;
    setState(() {});
    _toast('Cancelled. The parent has their credit back.');
  }

  void _markNoShow(Booking b) {
    final r = ConsultPolicy.parentNoShow(b);
    // The slot is spent, not refunded: the doctor held the time and turned up.
    BookingStore.instance.cancel(b.id, refundCredit: r.creditReturned);
    DoctorReminders.instance.cancelFor(b.id);
    if (!mounted) return;
    setState(() {});
    _toast('Marked as a no-show. You are still paid for this slot.');
  }

  void _toast(String m) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(m)));

  Widget _statusPill(Booking b, {required bool past, required bool hasRx}) {
    final (label, colour) = switch (b.status) {
      BookingStatus.cancelled => ('Cancelled', ppCoral),
      _ when past && !hasRx => ('Needs notes', ppBrown),
      _ when past => ('Done', const Color(0xFF3E7A5E)),
      _ => ('Confirmed', ppPurple),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
          color: colour.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: ppJakarta(10.5, color: colour)),
    );
  }

  Widget _action(String label, IconData icon,
          {required VoidCallback onTap, bool filled = false}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: filled ? ppPurple : ppBorder),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15, color: filled ? Colors.white : ppPurple),
            const SizedBox(width: 7),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ppJakarta(12,
                      color: filled ? Colors.white : ppPurple)),
            ),
          ]),
        ),
      );

  static String _time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  static String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}
