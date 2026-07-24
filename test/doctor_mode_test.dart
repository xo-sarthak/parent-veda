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
}
