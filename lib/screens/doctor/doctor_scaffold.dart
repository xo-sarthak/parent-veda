// =============================================================================
//  DoctorScaffold — the shell of the doctor app
// -----------------------------------------------------------------------------
//  Shown by the app root whenever DoctorSession.active is true, in place of the
//  parent MainScaffold. Three tabs: the dashboard, availability, and profile.
//  Its own bottom nav, its own header — a separate app that happens to live in
//  the same binary.
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_reminders.dart';
import '../../doctor/doctor_roster.dart';
import '../../doctor/doctor_session.dart';
import '../../doctor/doctor_schedule_store.dart';
import '../post_pregnancy/pp_common.dart';
// Retired: the old 7x6 grid of six hardcoded times, in which a doctor working
// 10:30-13:00 could not describe their own day. Replaced by
// DoctorScheduleScreen. Kept (with doctor_availability.dart) for easy revert.
// import '../../doctor/doctor_availability.dart';
// import 'doctor_availability_screen.dart';
import 'doctor_schedule_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_earnings_screen.dart';
import 'doctor_home_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorScaffold extends StatefulWidget {
  const DoctorScaffold({super.key});

  @override
  State<DoctorScaffold> createState() => _DoctorScaffoldState();
}

class _DoctorScaffoldState extends State<DoctorScaffold> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // Pull the server roster (bookings other parents made with this expert) and
    // load saved availability the moment the doctor app opens.
    DoctorRoster.instance.refresh().then((_) {
      // A missed consultation is the worst outcome in the product - the parent
      // waited, paid, and nobody came. Re-arming on every open is safe: the
      // notification ids are derived from the booking id, so repeats overwrite
      // rather than stack up.
      final id = DoctorSession.instance.expertId;
      if (id != null) {
        DoctorReminders.instance
            .syncAll(DoctorRoster.instance.upcomingConsults(id));
      }
    });
    DoctorScheduleStore.instance.init();
  }

  static const _tabs = [
    (Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
    (Icons.event_note_outlined, Icons.event_note_rounded, 'Appointments'),
    (Icons.schedule_outlined, Icons.schedule_rounded, 'Availability'),
    (Icons.payments_outlined, Icons.payments_rounded, 'Earnings'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final body = switch (_tab) {
      0 => const DoctorHomeScreen(),
      1 => const DoctorAppointmentsScreen(),
      2 => const DoctorScheduleScreen(),
      3 => const DoctorEarningsScreen(),
      _ => const DoctorProfileScreen(),
    };
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(bottom: false, child: body),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: ppHair)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(child: _navItem(i)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i) {
    final on = _tab == i;
    final t = _tabs[i];
    return GestureDetector(
      onTap: () => setState(() => _tab = i),
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(on ? t.$2 : t.$1, size: 23, color: on ? ppPurple : ppMuted),
        const SizedBox(height: 3),
        Text(t.$3,
            style: ppBody(10.5,
                color: on ? ppPurple : ppMuted,
                w: on ? FontWeight.w700 : FontWeight.w600)),
      ]),
    );
  }
}
