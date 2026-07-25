// =============================================================================
//  Patient context, cancellation policy, and onboarding
// -----------------------------------------------------------------------------
//  The first group guards a DEFECT that shipped: the doctor's appointment list
//  showed the doctor's own name instead of the parent's.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/doctor/consult_patient.dart';
import 'package:parentveda/doctor/consult_policy.dart';
import 'package:parentveda/doctor/doctor_onboarding_store.dart';
import 'package:parentveda/doctor/doctor_session.dart';
import 'package:parentveda/screens/doctor/doctor_onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  Booking booking(DateTime start) => Booking(
        id: 'bk_${start.millisecondsSinceEpoch}',
        offeringId: 'off_x',
        slotId: 'slot_x',
        stage: ServiceStage.pregnancy,
        title: 'Consult · Dr. Neha',
        startsUtc: start.toUtc(),
        durationMin: 30,
        status: BookingStatus.upcoming,
        bookedUtc: DateTime.now().toUtc(),
      );

  group('who the doctor is seeing', () {
    test('a parent with no name is "Parent", never the doctor\'s own name', () {
      const p = ConsultPatient();
      expect(p.displayName, 'Parent');
      expect(p.displayName, isNot(contains('Dr.')));
    });

    test('a due date becomes the pregnancy week at the time of the consult', () {
      final consult = DateTime(2026, 8, 10);
      // 16 weeks before the due date == week 24.
      final p = ConsultPatient(
          name: 'Meera', dueDate: consult.add(const Duration(days: 112)));
      expect(p.weeksPregnantOn(consult), 24);
      expect(p.contextLine(consult), 'Week 24 of pregnancy');
    });

    test('an implausible due date shows nothing rather than a wrong week', () {
      final consult = DateTime(2026, 8, 10);
      final stale = ConsultPatient(
          name: 'Meera', dueDate: consult.subtract(const Duration(days: 400)));
      expect(stale.weeksPregnantOn(consult), isNull);
      expect(stale.contextLine(consult), 'No stage details shared');
    });

    test('a child age reads naturally at every scale', () {
      final at = DateTime(2026, 8, 10);
      expect(const ConsultPatient(childAgeMonths: 0).contextLine(at), 'Newborn');
      expect(
          const ConsultPatient(childAgeMonths: 1).contextLine(at), '1 month old');
      expect(const ConsultPatient(childAgeMonths: 7).contextLine(at),
          '7 months old');
      expect(
          const ConsultPatient(childAgeMonths: 12).contextLine(at), '1 year old');
      expect(const ConsultPatient(childAgeMonths: 30).contextLine(at),
          '2 years old');
    });

    test('a server row maps straight onto the patient', () {
      final p = ConsultPatient.fromRow(
          {'patient_name': 'Aarav', 'patient_due': '2026-12-01'});
      expect(p.name, 'Aarav');
      expect(p.dueDate, DateTime(2026, 12, 1));
    });
  });

  group('what happens when a consultation does not happen', () {
    final soon = booking(DateTime.now().add(const Duration(minutes: 30)));
    final later = booking(DateTime.now().add(const Duration(days: 3)));

    test('the doctor cancelling always returns the credit, at any notice', () {
      for (final b in [soon, later]) {
        final r = ConsultPolicy.doctorCancels(b);
        expect(r.creditReturned, isTrue);
        expect(r.doctorPaid, isFalse);
        // The wording must not attribute fault to the parent, and must tell
        // them the credit is back. (An earlier version of this test banned the
        // word "you" outright, which is nonsense - "your credit is back" is
        // exactly what a parent needs to read.)
        expect(r.parentMessage.toLowerCase(), isNot(contains('you missed')));
        expect(r.parentMessage.toLowerCase(), contains('credit'));
      }
    });

    test('a parent cancelling early gets their credit back', () {
      final r = ConsultPolicy.parentCancels(later);
      expect(r.outcome, ConsultOutcome.parentCancelledEarly);
      expect(r.creditReturned, isTrue);
    });

    test('a parent cancelling inside 2 hours keeps the slot but may rebook once',
        () {
      final r = ConsultPolicy.parentCancels(soon);
      expect(r.outcome, ConsultOutcome.parentCancelledLate);
      expect(r.creditReturned, isFalse);
      expect(r.freeReschedule, isTrue,
          reason: 'taking the money AND the appointment would be punitive');
      expect(r.doctorPaid, isTrue);
    });

    test('a no-show pays the doctor, who held the time and turned up', () {
      final r = ConsultPolicy.parentNoShow(soon);
      expect(r.doctorPaid, isTrue);
      expect(r.creditReturned, isFalse);
      expect(r.freeReschedule, isFalse);
    });

    test('no-show cannot be marked until the grace period has passed', () {
      final justStarted = booking(DateTime.now());
      expect(ConsultPolicy.mayMarkNoShow(justStarted), isFalse,
          reason: 'joining a few minutes late is not a no-show');
      final wellPast =
          booking(DateTime.now().subtract(const Duration(minutes: 20)));
      expect(ConsultPolicy.mayMarkNoShow(wellPast), isTrue);
    });

    test('the free-cancellation window is exactly 2 hours', () {
      expect(kFreeCancelWindow, const Duration(hours: 2));
      expect(
          ConsultPolicy.parentMayCancelFree(
              booking(DateTime.now().add(const Duration(hours: 3)))),
          isTrue);
      expect(
          ConsultPolicy.parentMayCancelFree(
              booking(DateTime.now().add(const Duration(hours: 1)))),
          isFalse);
    });
  });

  group('practice setup', () {
    setUp(DoctorOnboardingStore.instance.resetAll);

    testWidgets('walks all five steps, and every one can be skipped', (t) async {
      // Tall viewport so the whole step is built: a ListView does not build
      // children far below the fold, so an off-screen button cannot even be
      // found, let alone scrolled to.
      t.view.physicalSize = const Size(1170, 5600);
      t.view.devicePixelRatio = 3.0;
      addTearDown(t.view.reset);
      DoctorSession.instance.enter('neha');
      addTearDown(DoctorSession.instance.exit);

      await t.pumpWidget(const MaterialApp(home: DoctorOnboardingScreen()));
      await t.pump();

      for (final title in [
        'Basic details',
        'Qualifications',
        'Registration',
        'Documents',
        'Payouts',
      ]) {
        expect(find.text(title), findsOneWidget, reason: '$title missing');
        expect(find.text('Skip for now'), findsOneWidget,
            reason: 'every step must be skippable while testing');
        await t.tap(find.text('Skip for now'));
        await t.pump();
      }
      // All five recorded as skipped.
      expect(DoctorOnboardingStore.instance.skippedFor('neha').length, 5);
    });
  });
}
