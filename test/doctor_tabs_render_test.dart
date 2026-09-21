// =============================================================================
//  Every ParentVeda+ tab renders at phone width, logged out, without a layout
//  error — and the retired screens are not what is on screen.
// -----------------------------------------------------------------------------
//  Logged out is the honest floor: no Supabase, so the ledger has only its
//  (empty) cache, the roster only its local half, and every section must
//  still render its invitation rather than a blank or an overflow. A RenderFlex
//  overflow in the test font is caught here before it is caught on a 40-year-
//  old's phone with the OS font size turned up.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_store.dart';
import 'package:parentveda/doctor/doctor_session.dart';
import 'package:parentveda/screens/doctor/doctor_appointments_tab.dart';
import 'package:parentveda/screens/doctor/doctor_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  setUp(() {
    BookingStore.instance.resetAll();
    DoctorSession.instance.enter('neha');
  });
  tearDown(() {
    BookingStore.instance.resetAll();
    DoctorSession.instance.exit();
  });

  Future<void> pump(WidgetTester tester) async {
    // A narrow phone, deliberately: 360 logical px, the common Indian Android
    // width, so a row that fits a Pixel does not pass here and fail there.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: DoctorScaffold()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> goTo(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// The tabs are lazy ListViews: a row below the fold does not exist until
  /// it is scrolled to, so "found nothing" would be a lie about the screen.
  Future<void> see(WidgetTester tester, Finder f) async {
    await tester.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
    await tester.pump();
    expect(f, findsOneWidget);
  }

  testWidgets('Home', (tester) async {
    await pump(tester);
    expect(find.textContaining('Dr Neha'), findsWidgets);
    // Home v2 (2026-09-21): the fixed spine, top to bottom. The week strip
    // is the card under the band when nothing is booked; quick actions;
    // this week; needs you (work + set-up, one rail); for you (three
    // reads); your classes; how parents see you. No 'Availability' block
    // any more — the switch lives in the strip's tab.
    for (final l in const ['Hours', 'Prescribe', 'QR kit', 'Earnings']) {
      expect(find.text(l), findsWidgets, reason: '$l quick action missing');
    }
    await see(tester, find.text('THIS WEEK'));
    // 2026-09-21: set-up and work share one swipe rail under NEEDS YOU; the
    // bell holds updates, not chores.
    await see(tester, find.text('NEEDS YOU'));
    expect(find.text('Print your QR poster'), findsWidgets, reason: 'the set-up cards ride in the Needs you rail');
    await see(tester, find.text('FOR YOU'));
    await see(tester, find.text('How a consultation runs here'));
    await see(tester, find.text('YOUR CLASSES'));
    await see(tester, find.text('HOW PARENTS SEE YOU'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Write on the prescriptions task opens Appointments on Past', (tester) async {
    await pump(tester);
    DoctorAppointmentsTab.openOn = 2;
    await goTo(tester, 'Appointments');
    expect(find.text('No past consultations'), findsOneWidget, reason: 'Past segment is open');
    expect(DoctorAppointmentsTab.openOn, isNull, reason: 'consumed once');
    // A plain tap on the tab later opens on Today again.
    await goTo(tester, 'Home');
    await goTo(tester, 'Appointments');
    expect(find.text('Nothing today'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Back on a tab goes Home, not out of the app', (tester) async {
    // A task's verb switches a tab rather than pushing a route, so Back has
    // nothing to pop; the scaffold's PopScope sends it Home first
    // (2026-09-21: "when I go back, I exit the app").
    await pump(tester);
    await goTo(tester, 'Appointments');
    expect(find.textContaining('Upcoming ('), findsOneWidget);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    final popped = await nav.maybePop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // maybePop answers true when a PopScope consumed the pop, false when it
    // would have bubbled to the system — which on the root route closes the app.
    expect(popped, isTrue, reason: 'the scaffold must consume Back, or the app closes');
    expect(find.text('THIS WEEK'), findsOneWidget, reason: 'Back returned to Home');
    // On Home, Back is the system's again.
    expect(await nav.maybePop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Appointments — three segments, empty states, no overflow', (tester) async {
    await pump(tester);
    await goTo(tester, 'Appointments');
    expect(find.textContaining('Today ('), findsOneWidget);
    expect(find.textContaining('Upcoming ('), findsOneWidget);
    expect(find.textContaining('Past ('), findsOneWidget);
    expect(find.text('Nothing today'), findsOneWidget);
    await goTo(tester, 'Past (0)');
    await see(tester, find.text('No past consultations'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Availability — seven rows, the switch, the preview', (tester) async {
    await pump(tester);
    await goTo(tester, 'Availability');
    // Top to bottom, because see() only scrolls down.
    expect(find.text('Taking bookings'), findsOneWidget);
    for (final d in const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']) {
      await see(tester, find.text(d));
    }
    await see(tester, find.text('Consultation rules'));
    await see(tester, find.text('WHAT PARENTS WILL SEE'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Earnings — we owe you, every source, payouts, statement', (tester) async {
    await pump(tester);
    await goTo(tester, 'Earnings');
    expect(find.text('WE OWE YOU'), findsOneWidget);
    expect(find.text('₹0'), findsWidgets);
    for (final s in const ['Consultations', 'Masterclasses', 'Cohorts', 'Recorded courses', 'Videos', 'Articles', 'Affiliate income', 'Brand sponsorship', 'Products', 'Referrals']) {
      await see(tester, find.text(s));
    }
    await see(tester, find.textContaining('No videos yet'));
    await see(tester, find.text('No payouts yet'));
    await see(tester, find.textContaining('as a statement'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile — rows for the practice and the way out', (tester) async {
    await pump(tester);
    await goTo(tester, 'Profile');
    await see(tester, find.text('Payout account'));
    await see(tester, find.text('Your classes'));
    await see(tester, find.text('Referral kit'));
    await see(tester, find.text('Leave doctor mode'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the nav carries the five decided labels and nothing else', (tester) async {
    await pump(tester);
    for (final l in const ['Home', 'Appointments', 'Availability', 'Earnings', 'Profile']) {
      expect(find.text(l), findsWidgets, reason: '$l tab missing');
    }
    expect(find.text('Impact'), findsNothing);
  });
}
