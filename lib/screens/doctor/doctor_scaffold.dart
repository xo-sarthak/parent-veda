// =============================================================================
//  DoctorScaffold — the shell of the doctor app
// -----------------------------------------------------------------------------
//  Shown by the app root whenever DoctorSession.active is true, in place of the
//  parent MainScaffold. Three tabs: the dashboard, availability, and profile.
//  Its own bottom nav, its own header — a separate app that happens to live in
//  the same binary.
// =============================================================================

import 'dart:async';

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
import 'doctor_home_screen.dart';
import 'doctor_impact_tab.dart';
import 'doctor_profile_screen.dart';

class DoctorScaffold extends StatefulWidget {
  const DoctorScaffold({super.key});

  @override
  State<DoctorScaffold> createState() => _DoctorScaffoldState();
}

class _DoctorScaffoldState extends State<DoctorScaffold>
    with WidgetsBindingObserver {
  int _tab = 0;

  /// KEEPING THE ROSTER CURRENT WITHOUT ASKING THE DOCTOR TO DO ANYTHING.
  ///
  /// The roster used to load exactly once, in initState. That is why a booking
  /// made on the parent's phone only appeared after a hot RESTART and not a hot
  /// reload: reload keeps the widget state, so initState never runs again, so
  /// nothing refetched. Nothing was broken — the app simply never asked twice.
  ///
  /// In a doctor's hands that is worse than a bug. They leave the app open on a
  /// desk between consults; a parent books ten minutes before their slot; the
  /// screen keeps showing an empty afternoon until the app is killed. So three
  /// triggers now, each covering what the others miss:
  ///
  ///   * app RESUMED  — the common case. Any switch away and back is current.
  ///   * a POLL       — for the phone left open on the desk, which never
  ///                    resumes because it never left.
  ///   * pull-to-refresh on the lists — the deliberate "is it there yet?"
  ///
  /// Ninety seconds for the poll: a consult is fifteen minutes and the shortest
  /// booking notice is measured in minutes, so a minute and a half of staleness
  /// is never the difference between making a call and missing it. Shorter
  /// would be a request per doctor per few seconds, all day, to change nothing
  /// almost every time.
  static const _pollEvery = Duration(seconds: 90);
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshRoster();
    _poll = Timer.periodic(_pollEvery, (_) => _refreshRoster());
    DoctorScheduleStore.instance.init();
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshRoster();
  }

  Future<void> _refreshRoster() async {
    await DoctorRoster.instance.refresh();
    if (!mounted) return;
    // A missed consultation is the worst outcome in the product - the parent
    // waited, paid, and nobody came. Re-arming on every refresh is safe: the
    // notification ids are derived from the booking id, so repeats overwrite
    // rather than stack up.
    final id = DoctorSession.instance.expertId;
    if (id != null) {
      DoctorReminders.instance
          .syncAll(DoctorRoster.instance.upcomingConsults(id));
    }
  }

  static const _tabs = [
    (Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
    (Icons.event_note_outlined, Icons.event_note_rounded, 'Appointments'),
    (Icons.schedule_outlined, Icons.schedule_rounded, 'Availability'),
    // Was 'Earnings'. The Partner Journey Dashboard absorbed it: impact first,
    // earnings one tap inside. See DoctorImpactTab for why they stay separate.
    (Icons.insights_outlined, Icons.insights_rounded, 'Impact'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final body = switch (_tab) {
      0 => const DoctorHomeScreen(),
      1 => const DoctorAppointmentsScreen(),
      2 => const DoctorScheduleScreen(),
      3 => const DoctorImpactTab(),
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
