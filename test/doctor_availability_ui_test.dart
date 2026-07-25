// =============================================================================
//  Availability screen + schedule store
// -----------------------------------------------------------------------------
//  The point of the redesign was that a doctor can express their real day, so
//  the tests check exactly that: a two-session clinic day survives, the preview
//  reflects the rules rather than being decorative, and pausing keeps the hours.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/doctor/doctor_schedule.dart';
import 'package:parentveda/doctor/doctor_schedule_store.dart';
import 'package:parentveda/screens/doctor/doctor_schedule_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final store = DoctorScheduleStore.instance;
  setUp(store.resetAll);
  tearDown(store.resetAll);

  group('store', () {
    test('a doctor who has set nothing gets the starter clinic week', () {
      final s = store.scheduleFor('dr_new');
      expect(store.hasSetUp('dr_new'), isFalse);
      expect(s.dayFor(DateTime.monday).sessions.length, 2,
          reason: 'morning + evening is the common Indian clinic pattern');
      expect(s.dayFor(DateTime.sunday).isWorking, isFalse);
      expect(s.workingDays, 6);
    });

    test('a saved schedule is kept per expert', () {
      store.save(
        'dr_a',
        DoctorSchedule(byWeekday: {
          DateTime.monday: const DaySchedule([Session(540, 600)]),
        }),
      );
      expect(store.hasSetUp('dr_a'), isTrue);
      expect(store.scheduleFor('dr_a').workingDays, 1);
      // A different doctor is unaffected.
      expect(store.scheduleFor('dr_b').workingDays, 6);
    });

    test('the preview is the SAME engine parents get, not a mock', () {
      store.save(
        'dr_c',
        DoctorSchedule(
          byWeekday: {
            for (var d = DateTime.monday; d <= DateTime.sunday; d++)
              d: const DaySchedule([Session(600, 720)]) // 10:00-12:00
          },
          rules: const ConsultRules(
              slotMinutes: 30,
              bufferAfterMin: 0,
              minNoticeMinutes: 0,
              maxConsecutive: 0),
        ),
      );
      final now = DateTime(2026, 8, 3, 6, 0);
      final slots = store.preview('dr_c', days: 1, now: now);
      expect(slots.length, 4); // 10:00 10:30 11:00 11:30
    });

    test('pausing empties the preview but keeps the hours', () {
      store.save('dr_d', DoctorSchedule.starter.copyWith(paused: true));
      expect(store.preview('dr_d', days: 7), isEmpty);
      expect(store.scheduleFor('dr_d').hasAnyHours, isTrue);
    });
  });

  group('screen', () {
    Future<void> pump(WidgetTester t) async {
      t.view.physicalSize = const Size(1170, 2600);
      t.view.devicePixelRatio = 3.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(
        home: Scaffold(body: DoctorScheduleScreen()),
      ));
      await t.pump();
      await t.pump(const Duration(milliseconds: 250));
    }

    testWidgets('opens on the week, showing days and the live preview',
        (t) async {
      await pump(t);
      expect(find.text('Working days'), findsOneWidget);
      expect(find.text('Mon'), findsWidgets);
      // The preview sits below the fold on a phone, so scroll to it the way a
      // doctor would.
      await t.scrollUntilVisible(find.text('What parents will see'), 300);
      expect(find.text('What parents will see'), findsOneWidget);
    });

    testWidgets('the three sections switch', (t) async {
      await pump(t);
      await t.tap(find.text('Rules'));
      await t.pump();
      expect(find.text('How long is one consultation?'), findsOneWidget);

      await t.tap(find.text('Time off'));
      await t.pump();
      expect(find.text('Add time off'), findsOneWidget);
    });

    testWidgets('changing the consultation length updates the schedule',
        (t) async {
      await pump(t);
      await t.tap(find.text('Rules'));
      await t.pump();
      await t.tap(find.text('15 min'));
      await t.pump();
      expect(store.scheduleFor('').rules.slotMinutes, 15);
    });

    testWidgets('pause is reachable and reversible from the header', (t) async {
      await pump(t);
      expect(find.text('Taking bookings'), findsOneWidget);
      await t.tap(find.byType(Switch).first);
      await t.pump();
      expect(store.scheduleFor('').paused, isTrue);
      expect(find.text('Not taking bookings'), findsOneWidget);
    });

    testWidgets('turning every day off says so instead of showing nothing',
        (t) async {
      store.save('', const DoctorSchedule(byWeekday: {}));
      await pump(t);
      await t.scrollUntilVisible(
          find.textContaining('Nothing is bookable yet'), 300);
      expect(find.textContaining('Nothing is bookable yet'), findsOneWidget);
    });
  });
}
