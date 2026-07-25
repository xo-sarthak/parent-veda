// =============================================================================
//  Phase 3 — the doctor's schedule IS the parent's slot list
// -----------------------------------------------------------------------------
//  The whole point of the redesign: what a doctor sets in Availability is
//  exactly what a parent is offered. Before this, consult slots were INVENTED
//  from a hash of the offering id, so a doctor could close their diary and
//  parents would carry on booking them.
//
//  These tests go through BookingCatalog - the parent's real path - rather than
//  calling generateSlots directly, so they would catch the wiring coming loose
//  as well as the maths.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/doctor/doctor_schedule.dart';
import 'package:parentveda/doctor/doctor_schedule_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final store = DoctorScheduleStore.instance;
  setUp(store.resetAll);
  tearDown(store.resetAll);

  /// Any in-app consult offering — the doctor case.
  Offering consultOffering() => BookingCatalog.instance
      .offerings()
      .firstWhere((o) => o.kind == OfferingKind.consult);

  test('a consult offering exists to hang a schedule on', () {
    expect(() => consultOffering(), returnsNormally);
  });

  test('with NO schedule set, the seeded calendar still fills the screen', () {
    final o = consultOffering();
    final slots = BookingCatalog.instance.slotsFor(o.id);
    expect(slots, isNotEmpty,
        reason: 'an empty booking screen reads as a broken app');
  });

  test('once a doctor sets hours, parents are offered exactly those', () {
    final o = consultOffering();
    store.save(
      o.expertId,
      DoctorSchedule(
        byWeekday: {
          for (var d = DateTime.monday; d <= DateTime.sunday; d++)
            d: const DaySchedule([Session(10 * 60, 12 * 60)]) // 10-12 only
        },
        rules: const ConsultRules(
            slotMinutes: 30,
            bufferAfterMin: 0,
            minNoticeMinutes: 0,
            maxPerDay: 100,
            maxConsecutive: 0),
      ),
    );

    final slots = BookingCatalog.instance.slotsFor(o.id);
    expect(slots, isNotEmpty);
    for (final s in slots) {
      final local = s.startsUtc.toLocal();
      expect(local.hour, inInclusiveRange(10, 11),
          reason: 'a slot outside the doctor\'s stated hours was offered');
      expect(s.durationMin, 30);
      expect(s.capacity, 1, reason: 'a 1:1 consultation is one seat');
    }
  });

  test('a doctor who pauses cannot be booked at all', () {
    final o = consultOffering();
    store.save(o.expertId, DoctorSchedule.starter.copyWith(paused: true));
    expect(BookingCatalog.instance.slotsFor(o.id), isEmpty,
        reason: 'pausing must actually close the diary, not just the doctor UI');
  });

  test('a doctor working no days offers nothing, rather than invented times', () {
    final o = consultOffering();
    store.save(o.expertId, const DoctorSchedule(byWeekday: {}));
    expect(BookingCatalog.instance.slotsFor(o.id), isEmpty);
  });

  test('time off removes those days from what parents see', () {
    final o = consultOffering();
    final now = DateTime.now();
    store.save(
      o.expertId,
      DoctorSchedule.starter.copyWith(
        rules: const ConsultRules(minNoticeMinutes: 0, maxConsecutive: 0),
        timeOff: [
          TimeOff(
              fromDate: now,
              toDate: now.add(const Duration(days: 10)),
              reason: 'Leave'),
        ],
      ),
    );
    final slots = BookingCatalog.instance.slotsFor(o.id);
    for (final s in slots) {
      expect(s.startsUtc.toLocal().difference(now).inDays, greaterThan(9),
          reason: 'a slot was offered during the doctor\'s leave');
    }
  });

  test('the consultation length the doctor picked is what gets booked', () {
    final o = consultOffering();
    store.save(
      o.expertId,
      DoctorSchedule.starter.copyWith(
        rules: const ConsultRules(
            slotMinutes: 15, minNoticeMinutes: 0, maxConsecutive: 0),
      ),
    );
    final slots = BookingCatalog.instance.slotsFor(o.id);
    expect(slots.first.durationMin, 15);
  });

  test('slot ids are stable across reads, so a booking cannot shift underneath',
      () {
    final o = consultOffering();
    store.save(
      o.expertId,
      DoctorSchedule.starter.copyWith(
        rules: const ConsultRules(minNoticeMinutes: 0, maxConsecutive: 0),
      ),
    );
    final a = BookingCatalog.instance.slotsFor(o.id).map((s) => s.id).toList();
    final b = BookingCatalog.instance.slotsFor(o.id).map((s) => s.id).toList();
    expect(a, b);
  });

  test('the max-per-day cap is honoured on the parent side too', () {
    final o = consultOffering();
    store.save(
      o.expertId,
      DoctorSchedule(
        byWeekday: {
          for (var d = DateTime.monday; d <= DateTime.sunday; d++)
            d: const DaySchedule([Session(9 * 60, 18 * 60)]) // a long day
        },
        rules: const ConsultRules(
            slotMinutes: 30,
            bufferAfterMin: 0,
            minNoticeMinutes: 0,
            maxPerDay: 3,
            maxConsecutive: 0),
      ),
    );
    final slots = BookingCatalog.instance.slotsFor(o.id);
    final byDay = <String, int>{};
    for (final s in slots) {
      final d = s.startsUtc.toLocal();
      final k = '${d.year}-${d.month}-${d.day}';
      byDay[k] = (byDay[k] ?? 0) + 1;
    }
    for (final count in byDay.values) {
      expect(count, lessThanOrEqualTo(3));
    }
  });
}
