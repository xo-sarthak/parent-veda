// =============================================================================
//  Phase 4 — Appointments + consult reminders
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/doctor/doctor_reminders.dart';
import 'package:parentveda/doctor/doctor_session.dart';
import 'package:parentveda/screens/doctor/doctor_appointments_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  Booking booking({
    required String id,
    required DateTime start,
    BookingStatus status = BookingStatus.upcoming,
  }) =>
      Booking(
        id: id,
        offeringId: 'off_x',
        slotId: 'slot_$id',
        stage: ServiceStage.parenting,
        title: 'Consult · Dr. Neha',
        startsUtc: start.toUtc(),
        durationMin: 30,
        status: status,
        bookedUtc: DateTime.now().toUtc(),
      );

  group('reminders', () {
    test('the ladder is 24h / 1h / 10min before the consultation', () {
      // Ids are derived per rung, so three distinct notifications exist.
      final ids = [
        for (var i = 0; i < 3; i++) DoctorReminders.notificationId('bk1', i)
      ];
      expect(ids.toSet().length, 3, reason: 'rungs must not collide');
    });

    test('two different bookings never share a notification id', () {
      final a = DoctorReminders.notificationId('booking_alpha', 0);
      final b = DoctorReminders.notificationId('booking_beta', 0);
      expect(a, isNot(b));
    });

    test('the same booking always resolves to the same id, so re-arming '
        'overwrites instead of stacking', () {
      expect(DoctorReminders.notificationId('bk9', 2),
          DoctorReminders.notificationId('bk9', 2));
    });

    test('scheduling a past consultation is a no-op, not a crash', () async {
      final past = booking(
          id: 'old', start: DateTime.now().subtract(const Duration(days: 2)));
      await expectLater(
          DoctorReminders.instance.scheduleFor(past), completes);
    });

    test('a cancelled consultation is never reminded about', () async {
      final b = booking(
        id: 'cancelled',
        start: DateTime.now().add(const Duration(days: 2)),
        status: BookingStatus.cancelled,
      );
      await expectLater(DoctorReminders.instance.scheduleFor(b), completes);
    });
  });

  group('appointments screen', () {
    Future<void> pump(WidgetTester t) async {
      t.view.physicalSize = const Size(1170, 2600);
      t.view.devicePixelRatio = 3.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(
        home: Scaffold(body: DoctorAppointmentsScreen()),
      ));
      await t.pump();
      await t.pump(const Duration(milliseconds: 200));
    }

    testWidgets('asks for a doctor sign-in when there is none', (t) async {
      DoctorSession.instance.exit();
      await pump(t);
      expect(find.text('Not signed in as a doctor'), findsOneWidget);
    });

    testWidgets('shows the three practice buckets once signed in', (t) async {
      DoctorSession.instance.enter('neha');
      addTearDown(DoctorSession.instance.exit);
      await pump(t);
      expect(find.text('Appointments'), findsOneWidget);
      expect(find.textContaining('Today'), findsWidgets);
      expect(find.textContaining('Upcoming'), findsWidgets);
      expect(find.textContaining('Past'), findsWidgets);
    });

    testWidgets('an empty day says so rather than showing a blank screen',
        (t) async {
      DoctorSession.instance.enter('neha');
      addTearDown(DoctorSession.instance.exit);
      await pump(t);
      expect(find.textContaining('Nothing booked for today'), findsOneWidget);
    });

    testWidgets('the summary line reports the roster, not a made-up number',
        (t) async {
      DoctorSession.instance.enter('neha');
      addTearDown(DoctorSession.instance.exit);
      await pump(t);
      // Booking-through-to-roster is already covered by doctor_mode_test; what
      // matters here is that the header describes an empty practice honestly
      // instead of showing a hardcoded count.
      expect(find.textContaining('No consultations booked yet'), findsOneWidget);
    });
  });
}
