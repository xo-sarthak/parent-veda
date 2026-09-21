// =============================================================================
//  DoctorScaffold — the shell of the doctor app
// -----------------------------------------------------------------------------
//  Shown by the app root whenever DoctorSession.active is true, in place of the
//  parent MainScaffold. Five tabs — Home · Appointments · Availability ·
//  Earnings · Profile — on the SAME PvNavBar the three parent stages use
//  (DESIGN-SYSTEM §4.9: tab sets differ, treatment never does). A separate
//  app that happens to live in the same binary, wearing the same clothes.
//
//  2026-09-18 (Mobbin audit #8, docs/DOCTOR-APP-AUDIT.md): Earnings replaces
//  Impact as the fourth tab — the user's call; the families count lives
//  inside Earnings → Referrals. The tab bodies are the *_tab.dart files; the
//  old *_screen.dart files are kept for revert and are no longer reachable
//  from here (test/doctor_app_shell_test.dart holds that).
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../booking/prescription.dart';
import '../../doctor/doctor_ledger.dart';
import '../../doctor/doctor_reminders.dart';
import '../../doctor/doctor_roster.dart';
import '../../doctor/doctor_schedule_store.dart';
import '../../doctor/doctor_session.dart';
import '../../doctor/doctor_updates.dart';
import '../../widgets/pv_nav_bar.dart';
import 'doctor_appointments_tab.dart';
import 'doctor_availability_tab.dart';
import 'doctor_chrome.dart';
import 'doctor_earnings_tab.dart';
import 'doctor_home_tab.dart';
import 'doctor_profile_tab.dart';
import 'doctor_task_feed.dart';
// Retired 2026-09-18, kept for revert:
// import 'doctor_home_screen.dart';
// import 'doctor_appointments_screen.dart';
// import 'doctor_schedule_screen.dart';
// import 'doctor_impact_tab.dart';
// import 'doctor_profile_screen.dart';

class DoctorScaffold extends StatefulWidget {
  const DoctorScaffold({super.key});

  @override
  State<DoctorScaffold> createState() => _DoctorScaffoldState();
}

class _DoctorScaffoldState extends State<DoctorScaffold>
    with WidgetsBindingObserver {
  DoctorTab _tab = DoctorTab.home;

  /// KEEPING THE ROSTER CURRENT WITHOUT ASKING THE DOCTOR TO DO ANYTHING.
  ///
  /// Three triggers, each covering what the others miss: app RESUMED (any
  /// switch away and back), a POLL (the phone left open on the desk, which
  /// never resumes because it never left), and pull-to-refresh on the lists.
  /// Ninety seconds: a consult is fifteen minutes and the shortest booking
  /// notice is measured in minutes, so a minute and a half of staleness is
  /// never the difference between making a call and missing it.
  static const _pollEvery = Duration(seconds: 90);
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _poll = Timer.periodic(_pollEvery, (_) => _refresh());
    DoctorScheduleStore.instance.init();
    DoctorLedger.instance.bind(DoctorSession.instance.expertId);
    DoctorUpdatesRead.instance.load();
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    // Prescriptions ride along with the roster: every screen decides what to
    // SAY about a past consult from PrescriptionStore.hasFor(), and a store
    // that never loaded answers false to all of it — the app telling a doctor
    // to write something they have already written.
    await Future.wait([
      DoctorRoster.instance.refresh(),
      PrescriptionStore.instance.refresh(),
      DoctorLedger.instance.refreshSummary(),
      // The itemised month feeds the bell ("you earned 1,920"), so it loads
      // with the summary rather than waiting for the Earnings tab.
      DoctorLedger.instance.loadRows(null),
    ]);
    if (!mounted) return;
    // A missed consultation is the worst outcome in the product. Re-arming on
    // every refresh is safe: the notification ids derive from the booking id,
    // so repeats overwrite rather than stack.
    final id = DoctorSession.instance.expertId;
    if (id != null) {
      DoctorReminders.instance.syncAll(
        DoctorRoster.instance.upcomingConsults(id),
      );
    }
  }

  static const _items = [
    PvNavItem(Icons.home_outlined, 'Home'),
    PvNavItem(Icons.event_note_outlined, 'Appointments'),
    PvNavItem(Icons.schedule_outlined, 'Availability'),
    PvNavItem(Icons.account_balance_wallet_outlined, 'Earnings'),
    PvNavItem(Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final body = switch (_tab) {
      DoctorTab.home => DoctorHomeTab(goTo: (t) => setState(() => _tab = t)),
      DoctorTab.appointments => DoctorAppointmentsTab(
        goTo: (t) => setState(() => _tab = t),
      ),
      DoctorTab.availability => DoctorAvailabilityTab(
        goTo: (t) => setState(() => _tab = t),
      ),
      DoctorTab.earnings => DoctorEarningsTab(
        goTo: (t) => setState(() => _tab = t),
      ),
      DoctorTab.profile => DoctorProfileTab(
        goTo: (t) => setState(() => _tab = t),
      ),
    };
    // ⚠️ BACK ON A TAB GOES HOME, NOT OUT. A task's verb ("Write" on the
    // prescriptions card) SWITCHES a tab rather than pushing a route, so
    // there is nothing on the Navigator for Back to pop and Android closed
    // the app — from Home to Appointments to gone, on one tap of Back (the
    // user, 2026-09-21). The convention every tabbed app follows (YouTube,
    // Instagram, Gmail): Back on a non-Home tab returns to Home; only Back
    // on Home leaves. canPop is recomputed on every tab change, which is
    // why it is derived here and not stored.
    return PopScope(
      canPop: _tab == DoctorTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _tab != DoctorTab.home)
          setState(() => _tab = DoctorTab.home);
      },
      child: Scaffold(
        backgroundColor: dcP.ground,
        // Home carries a full-bleed photo band that runs under the status bar
        // (DcHero pads itself by the real inset); every other tab starts below
        // it. SafeArea would strip the inset from MediaQuery and leave a white
        // strip above the photograph.
        // Every tab is a door now: the photograph runs under the status bar
        // on all five, and DcHero pads itself by the real inset.
        // The bar FLOATS, as it does on the parenting home (post_pregnancy_home
        // 2026-09-16): a pill 16 in from each edge, 18 above the system inset,
        // with the page scrolling under it. Docked in `bottomNavigationBar` it
        // ran edge to edge and read as a different component from the parent
        // app's, though it is the same PvNavBar. Every tab body pads its list
        // by `DcTab.barClearance` so the last row clears the pill.
        body: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(bottom: false, top: false, child: body),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewPadding.bottom + 18,
              child: PvNavBar(
                items: _items,
                activeIndex: _tab.index,
                onTap: (i) => setState(() => _tab = DoctorTab.values[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
