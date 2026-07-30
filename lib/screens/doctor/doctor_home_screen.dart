// =============================================================================
//  DoctorHomeScreen — the expert's dashboard
// -----------------------------------------------------------------------------
//  The first thing a doctor sees after logging in: who they are, the calls
//  waiting for them today, the sessions they run, and a way into their
//  availability. Deliberately calm and clinical — this is a work tool, not the
//  warm parent experience. Reuses the app's purple so it still feels ParentVeda.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_models.dart';
import '../../booking/call_screen.dart';
import '../../doctor/doctor_directory.dart';
import '../../doctor/doctor_roster.dart';
import '../../care_partner/care_partner_models.dart';
import '../../care_partner/partner_dashboard_store.dart';
import '../../doctor/doctor_session.dart';
import '../post_pregnancy/pp_common.dart';
import 'doctor_availability_screen.dart';
import 'doctor_prescription_screen.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: c);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([DoctorSession.instance, DoctorRoster.instance]),
      builder: (context, _) {
        // doctorInfoById() falls back to the FIRST doctor for an unknown id, so
        // a referral-only partner — a hospital, lab or IVF centre, none of
        // which belong in the compiled kExperts catalogue — would render
        // somebody else's name as its own. Only resolve a doctor when this
        // session actually has a consulting identity.
        final session = DoctorSession.instance;
        final e = session.consults ? doctorInfoById(session.expertId!) : null;
        final partner = PartnerDashboardStore.instance.partner;

        final name = e?.name ?? partner?.name ?? 'Your practice';
        final sub = e?.credential ??
            (partner == null ? '' : CarePartnerType.label(partner.type));

        // No consulting identity means no roster to read. Empty, not hidden:
        // the sections below still render their invitations.
        final calls = e == null
            ? const <Booking>[]
            : DoctorRoster.instance.upcomingConsults(e.id);
        final sessions = e == null
            ? const <Offering>[]
            : DoctorRoster.instance.sessionsBy(e.id);

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 40),
          children: [
            _pad(_header(name, sub)),
            const SizedBox(height: 16),
            // The stage toggle is a TESTING affordance for flipping between a
            // pregnancy-side and a parenting-side doctor. A partner with no
            // expert record has no stage to flip.
            if (e != null) ...[
              _pad(_stageToggle(e.stage)),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 4),
            _pad(_statRow(calls.length, sessions.length)),
            const SizedBox(height: 24),

            _pad(_sectionLabel('Upcoming calls')),
            const SizedBox(height: 10),
            if (calls.isEmpty)
              _pad(_empty('No consults booked yet.',
                  'When a parent books a slot with you, it shows here.'))
            else
              for (final b in calls) _pad(_callCard(context, b)),

            if (sessions.isNotEmpty) ...[
              const SizedBox(height: 22),
              _pad(_sectionLabel('Your sessions')),
              const SizedBox(height: 10),
              for (final o in sessions) _pad(_sessionRow(o)),
            ],

            const SizedBox(height: 22),
            _pad(GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const DoctorAvailabilityScreen())),
              behavior: HitTestBehavior.opaque,
              child: _availabilityCard(),
            )),
          ],
        );
      },
    );
  }

  // ---- header ---------------------------------------------------------------

  // TESTING: flip between a pregnancy-side and a parenting-side doctor, to see
  // both flows without logging out. A real doctor is one or the other.
  Widget _stageToggle(DoctorStage current) {
    Widget seg(String label, DoctorStage stage) {
      final on = current == stage;
      return Expanded(
        child: GestureDetector(
          onTap: on
              ? null
              : () {
                  final d = firstDoctorOf(stage);
                  if (d != null) DoctorSession.instance.enter(d.id);
                },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 34,
            alignment: Alignment.center,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: on ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: on
                  ? const [
                      BoxShadow(
                          color: Color(0x146A30B6),
                          blurRadius: 8,
                          offset: Offset(0, 2))
                    ]
                  : null,
            ),
            child: Text(label,
                style: ppBody(12.5,
                    color: on ? ppPurple : ppSoft, w: FontWeight.w700)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
          color: ppPanel, borderRadius: BorderRadius.circular(999)),
      child: Row(children: [
        seg('Pregnancy', DoctorStage.pregnancy),
        seg('Parenting', DoctorStage.parenting),
      ]),
    );
  }

  Widget _header(String name, String sub) => Row(children: [
        Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
          child: Text(
            _initial(name),
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_greeting(), style: ppBody(12.5, color: ppMuted)),
            const SizedBox(height: 2),
            Text(name,
                style: ppFraunces(23, color: ppTitleInk, h: 1.05),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(sub,
                style: ppBody(12, color: ppSoft),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]);

  /// First letter, with a title stripped: "Dr Meera Rao" -> M, and
  /// "Rainbow Children's Hospital" -> R.
  static String _initial(String name) {
    final n = name.replaceAll(RegExp(r'^(Dr|Prof)\.?\s*'), '').trim();
    return n.isEmpty ? '?' : n.characters.first.toUpperCase();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    return h < 12
        ? 'Good morning'
        : h < 17
            ? 'Good afternoon'
            : 'Good evening';
  }

  Widget _statRow(int calls, int sessions) => Row(children: [
        Expanded(child: _stat('$calls', calls == 1 ? 'call ahead' : 'calls ahead')),
        const SizedBox(width: 12),
        Expanded(child: _stat('$sessions', sessions == 1 ? 'session' : 'sessions')),
      ]);

  Widget _stat(String value, String label) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: ppPurple.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppPurple.withValues(alpha: 0.15)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: ppFraunces(26, color: ppPurple, h: 1)),
          const SizedBox(height: 2),
          Text(label, style: ppBody(12, color: ppSoft)),
        ]),
      );

  // ---- calls ----------------------------------------------------------------

  Widget _callCard(BuildContext context, Booking b) => ppCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.person_outline_rounded, size: 18, color: ppPurple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(b.title,
                  style: ppJakarta(15, color: ppTitleInk),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.event_rounded, size: 14, color: ppSoft),
            const SizedBox(width: 6),
            Text(_when(b.startsUtc),
                style: ppBody(12.5, color: ppInk, w: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => CallScreen(bookingId: b.id, title: b.title))),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: ppPurple, borderRadius: BorderRadius.circular(12)),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.videocam_rounded,
                        size: 17, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Start',
                        style:
                            ppBody(14, color: Colors.white, w: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => DoctorPrescriptionScreen(
                        bookingId: b.id, title: b.title))),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ppPanel,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.edit_note_rounded, size: 18, color: ppPurple),
                    const SizedBox(width: 6),
                    Text('Prescribe',
                        style: ppBody(13.5, color: ppInk, w: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
          ]),
        ]),
      );

  Widget _sessionRow(Offering o) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ppHair),
        ),
        child: Row(children: [
          Icon(
              o.kind == OfferingKind.cohort
                  ? Icons.groups_outlined
                  : Icons.school_outlined,
              size: 18,
              color: ppPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(o.title,
                style: ppBody(13.5, color: ppInk, w: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Text(o.kind == OfferingKind.cohort ? 'Cohort' : 'Masterclass',
              style: ppBody(11, color: ppMuted, w: FontWeight.w700)),
        ]),
      );

  Widget _availabilityCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ppTitleInk,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          const Icon(Icons.schedule_rounded, size: 26, color: Colors.white),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Set your availability',
                  style: ppJakarta(15, color: Colors.white)),
              const SizedBox(height: 3),
              Text('Choose the times parents can book you.',
                  style: ppBody(12, color: Colors.white.withValues(alpha: 0.75))),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 22, color: Colors.white),
        ]),
      );

  // ---- bits -----------------------------------------------------------------

  Widget _sectionLabel(String t) => Text(t.toUpperCase(),
      style: ppBody(11, color: ppMuted, w: FontWeight.w800)
          .copyWith(letterSpacing: 1.0));

  Widget _empty(String title, String sub) => Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppHair),
        ),
        child: Column(children: [
          const Icon(Icons.event_available_outlined, size: 26, color: ppMuted),
          const SizedBox(height: 10),
          Text(title, style: ppJakarta(14.5, color: ppTitleInk)),
          const SizedBox(height: 4),
          Text(sub,
              textAlign: TextAlign.center,
              style: ppBody(12.5, color: ppSoft, h: 1.4)),
        ]),
      );

  static const _wk = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _mo = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _when(DateTime utc) {
    final d = utc.toLocal();
    final now = DateTime.now();
    final diff = DateTime(d.year, d.month, d.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    final day = diff == 0
        ? 'Today'
        : diff == 1
            ? 'Tomorrow'
            : '${_wk[d.weekday - 1]} ${d.day} ${_mo[d.month - 1]}';
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$day · $h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }
}
