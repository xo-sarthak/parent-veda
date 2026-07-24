// =============================================================================
//  Doctor mode renders, and shows the expert's calls
// -----------------------------------------------------------------------------
//  Pins the doctor experience: the scaffold builds, the dashboard shows the
//  logged-in expert, and a consult booked with them appears on their roster.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_store.dart';
import 'package:parentveda/doctor/doctor_availability.dart';
import 'package:parentveda/doctor/doctor_directory.dart';
import 'package:parentveda/doctor/doctor_roster.dart';
import 'package:parentveda/doctor/doctor_session.dart';
import 'package:parentveda/screens/doctor/doctor_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final store = BookingStore.instance;

  setUp(() {
    store.resetAll();
    DoctorSession.instance.enter('neha'); // Dr. Neha Sharma, a consult doctor
  });
  tearDown(() {
    store.resetAll();
    DoctorSession.instance.exit();
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: DoctorScaffold()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('the doctor dashboard renders for the logged-in expert',
      (tester) async {
    await pump(tester);
    expect(find.textContaining('Dr. Neha'), findsWidgets);
    expect(find.text('UPCOMING CALLS'), findsOneWidget);
  });

  test('a consult booked with the doctor lands on their roster', () {
    final o = BookingCatalog.instance.offeringForCatalog('neha')!;
    store.purchase(o);
    store.book(BookingCatalog.instance.slotsFor(o.id).first);
    expect(DoctorRoster.instance.upcomingConsults('neha'), isNotEmpty,
        reason: 'the doctor should see the call booked with them');
  });

  test('doctors exist on BOTH sides — a pregnancy specialist is bookable', () {
    // sp_ob is a pregnancy specialist (not in kExperts).
    final info = doctorInfoById('sp_ob');
    expect(info.stage, DoctorStage.pregnancy);
    expect(doctorsForStage(DoctorStage.pregnancy), isNotEmpty);
    expect(doctorsForStage(DoctorStage.parenting), isNotEmpty);

    final o = BookingCatalog.instance.offeringForCatalog('sp_ob')!;
    store.purchase(o);
    store.book(BookingCatalog.instance.slotsFor(o.id).first);
    expect(DoctorRoster.instance.upcomingConsults('sp_ob'), isNotEmpty,
        reason: 'a pregnancy-side doctor sees their pregnancy consults');
  });

  test("the doctor's availability becomes the parent's consult slots", () {
    final o = BookingCatalog.instance.offeringForCatalog('neha')!;
    final avail = DoctorAvailability.instance;
    // Mark Dr. Neha free Mon & Wed at 10:00.
    avail.toggle('neha', const AvailWindow(DateTime.monday, 10, 0));
    avail.toggle('neha', const AvailWindow(DateTime.wednesday, 10, 0));

    final slots = BookingCatalog.instance.slotsFor(o.id);
    expect(slots, isNotEmpty);
    // Every generated slot falls on one of the days/times she set.
    for (final s in slots) {
      final d = s.startsUtc.toLocal();
      expect(d.hour, 10);
      expect([DateTime.monday, DateTime.wednesday], contains(d.weekday));
      expect(s.capacity, 1);
    }

    // Clean up so other tests see the generated fallback.
    avail.toggle('neha', const AvailWindow(DateTime.monday, 10, 0));
    avail.toggle('neha', const AvailWindow(DateTime.wednesday, 10, 0));
  });
}
