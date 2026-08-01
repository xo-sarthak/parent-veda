// =============================================================================
//  The slot engine — every rule that can remove a slot, pinned
// -----------------------------------------------------------------------------
//  This is the file where double-bookings and off-by-one errors would live, so
//  each rule gets a test that FAILS if the rule stops working: session bounds,
//  buffers, notice, advance window, per-day cap, consecutive cap, time off,
//  date overrides, pause, and never offering a taken slot twice.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/doctor/doctor_schedule.dart';

/// Mon 2026-08-03 09:00 — a fixed "now" so nothing depends on the real clock.
final _now = DateTime(2026, 8, 3, 9, 0);

DoctorSchedule _sched({
  List<Session> sessions = const [Session(600, 780)], // 10:00-13:00
  ConsultRules rules = const ConsultRules(
    slotMinutes: 30,
    bufferAfterMin: 0,
    minNoticeMinutes: 0,
    maxPerDay: 100,
    maxConsecutive: 0,
  ),
  List<TimeOff> timeOff = const [],
  Map<String, DateOverride> overrides = const {},
  bool paused = false,
}) =>
    DoctorSchedule(
      byWeekday: {
        for (var d = DateTime.monday; d <= DateTime.sunday; d++)
          d: DaySchedule(sessions),
      },
      rules: rules,
      timeOff: timeOff,
      overrides: overrides,
      paused: paused,
    );

List<GeneratedSlot> _oneDay(DoctorSchedule s, {Set<DateTime> booked = const {}}) =>
    generateSlots(s, from: _now, days: 1, booked: booked, now: _now);

void main() {
  group('session maths', () {
    test('a 3-hour session at 30 min yields 6 slots, none past the end', () {
      final slots = _oneDay(_sched());
      expect(slots.length, 6);
      expect(slots.first.start, DateTime(2026, 8, 3, 10, 0));
      expect(slots.last.start, DateTime(2026, 8, 3, 12, 30));
      // The last consultation must FINISH inside the session.
      expect(slots.last.end.isAfter(DateTime(2026, 8, 3, 13, 0)), isFalse);
    });

    test('two sessions produce two blocks, with the midday gap respected', () {
      final slots = _oneDay(_sched(sessions: const [
        Session(10 * 60, 13 * 60),
        Session(17 * 60, 20 * 60),
      ]));
      expect(slots.length, 12);
      final noon = slots.where((s) => s.start.hour >= 13 && s.start.hour < 17);
      expect(noon, isEmpty, reason: 'booked straight through the doctor\'s break');
    });

    test('a session too short for one consultation yields nothing', () {
      final slots = _oneDay(_sched(sessions: const [Session(600, 620)])); // 20 min
      expect(slots, isEmpty);
    });

    test('an inverted session is ignored rather than exploding', () {
      expect(_oneDay(_sched(sessions: const [Session(780, 600)])), isEmpty);
    });
  });

  group('buffers', () {
    test('a gap after each consultation spaces the starts out', () {
      final slots = _oneDay(_sched(
          rules: const ConsultRules(
              slotMinutes: 30,
              bufferAfterMin: 15,
              minNoticeMinutes: 0,
              maxConsecutive: 0)));
      // 45-minute stride: 10:00, 10:45, 11:30, 12:15
      expect(slots.map((s) => s.start.hour * 60 + s.start.minute).toList(),
          [600, 645, 690, 735]);
    });

    test('a lead-in buffer delays the first consultation of a session', () {
      final slots = _oneDay(_sched(
          rules: const ConsultRules(
              slotMinutes: 30,
              bufferBeforeMin: 10,
              bufferAfterMin: 0,
              minNoticeMinutes: 0,
              maxConsecutive: 0)));
      expect(slots.first.start, DateTime(2026, 8, 3, 10, 10));
    });
  });

  group('the rules that protect the doctor', () {
    test('minimum notice hides slots that are too soon', () {
      // now = 09:00, notice = 120 min -> nothing before 11:00.
      final slots = _oneDay(_sched(
          rules: const ConsultRules(
              slotMinutes: 30,
              bufferAfterMin: 0,
              minNoticeMinutes: 120,
              maxConsecutive: 0)));
      expect(slots.first.start, DateTime(2026, 8, 3, 11, 0));
    });

    test('the advance window closes the far future', () {
      final s = _sched(
          rules: const ConsultRules(
              slotMinutes: 30,
              bufferAfterMin: 0,
              minNoticeMinutes: 0,
              advanceWindowDays: 3,
              maxConsecutive: 0));
      final slots = generateSlots(s, from: _now, days: 30, now: _now);
      final furthest = slots.map((e) => e.start).reduce((a, b) => a.isAfter(b) ? a : b);
      expect(furthest.difference(_now).inDays, lessThanOrEqualTo(3));
    });

    test('max per day caps how many are offered', () {
      final slots = _oneDay(_sched(
          rules: const ConsultRules(
              slotMinutes: 30,
              bufferAfterMin: 0,
              minNoticeMinutes: 0,
              maxPerDay: 2,
              maxConsecutive: 0)));
      expect(slots.length, 2);
    });

    test('max per day counts appointments ALREADY booked that day', () {
      final booked = {DateTime(2026, 8, 3, 10, 0), DateTime(2026, 8, 3, 10, 30)};
      final slots = _oneDay(
        _sched(
            rules: const ConsultRules(
                slotMinutes: 30,
                bufferAfterMin: 0,
                minNoticeMinutes: 0,
                maxPerDay: 3,
                maxConsecutive: 0)),
        booked: booked,
      );
      expect(slots.length, 1, reason: '3 allowed, 2 already taken');
    });

    test('max consecutive forces a break after a back-to-back run', () {
      // 10:00 and 10:30 booked -> 11:00 would be a third in a row.
      final booked = {DateTime(2026, 8, 3, 10, 0), DateTime(2026, 8, 3, 10, 30)};
      final slots = _oneDay(
        _sched(
            rules: const ConsultRules(
                slotMinutes: 30,
                bufferAfterMin: 0,
                minNoticeMinutes: 0,
                maxConsecutive: 2)),
        booked: booked,
      );
      expect(slots.any((s) => s.start == DateTime(2026, 8, 3, 11, 0)), isFalse);
      expect(slots.any((s) => s.start == DateTime(2026, 8, 3, 11, 30)), isTrue,
          reason: 'the run is broken by 11:00, so 11:30 is fine again');
    });
  });

  group('exceptions', () {
    test('a booked slot is never offered again', () {
      final booked = {DateTime(2026, 8, 3, 11, 0)};
      final slots = _oneDay(_sched(), booked: booked);
      expect(slots.any((s) => s.start == DateTime(2026, 8, 3, 11, 0)), isFalse);
      expect(slots.length, 5);
    });

    test('time off removes the whole day', () {
      final slots = _oneDay(_sched(timeOff: [
        TimeOff(
            fromDate: DateTime(2026, 8, 1),
            toDate: DateTime(2026, 8, 5),
            reason: 'Vacation'),
      ]));
      expect(slots, isEmpty);
    });

    test('a date override can close a single day', () {
      final slots = _oneDay(_sched(overrides: {
        DateOverride.keyFor(DateTime(2026, 8, 3)):
            DateOverride(date: DateTime(2026, 8, 3), closed: true),
      }));
      expect(slots, isEmpty);
    });

    test('a date override can replace that day\'s hours', () {
      final slots = _oneDay(_sched(overrides: {
        DateOverride.keyFor(DateTime(2026, 8, 3)): DateOverride(
          date: DateTime(2026, 8, 3),
          sessions: const [Session(15 * 60, 16 * 60)], // 3-4pm only
        ),
      }));
      expect(slots.length, 2);
      expect(slots.first.start, DateTime(2026, 8, 3, 15, 0));
    });

    test('a non-working weekday produces nothing', () {
      final s = DoctorSchedule(
        byWeekday: {DateTime.monday: const DaySchedule.off()},
        rules: const ConsultRules(minNoticeMinutes: 0, maxConsecutive: 0),
      );
      expect(_oneDay(s), isEmpty);
    });

    test('pause stops every new booking without losing the schedule', () {
      final s = _sched(paused: true);
      expect(_oneDay(s), isEmpty);
      expect(s.hasAnyHours, isTrue, reason: 'the hours are kept, just not offered');
    });
  });

  group('helpers', () {
    test('groupByDay buckets slots per calendar day', () {
      final slots = generateSlots(_sched(), from: _now, days: 3, now: _now);
      expect(groupByDay(slots).keys.length, 3);
    });

    test('describeWeek collapses an identical run of days', () {
      expect(describeWeek(DoctorSchedule.starter), contains('Mon-Sat'));
      expect(describeWeek(DoctorSchedule.starter), contains('10:00 AM'));
    });

    test('describeWeek says so when hours vary', () {
      final s = DoctorSchedule(byWeekday: {
        DateTime.monday: const DaySchedule([Session(600, 780)]),
        DateTime.tuesday: const DaySchedule([Session(900, 1080)]),
      });
      expect(describeWeek(s), contains('vary'));
    });

    test('an empty schedule describes itself honestly', () {
      expect(describeWeek(const DoctorSchedule(byWeekday: {})),
          'No working days set');
    });
  });


  // ---------------------------------------------------------------------------
  //  Sessions that run past midnight
  // ---------------------------------------------------------------------------
  //  A late clinic - 11 PM to 1 AM - used to be rejected as "ends before it
  //  starts", because 60 really is less than 1380 on one day's clock. `end` may
  //  now count past 1440, which keeps every comparison linear. These pin the
  //  three things that could quietly break: the arithmetic, the slots landing
  //  on the RIGHT calendar day, and the daily cap counting a night as one shift
  //  rather than handing out a fresh allowance at midnight.
  group('overnight sessions', () {
    test('11 PM to 1 AM is a valid two-hour session, not a backwards one', () {
      const s = Session(23 * 60, 25 * 60); // 1380 -> 1500
      expect(s.isValid, isTrue);
      expect(s.crossesMidnight, isTrue);
      expect(s.lengthMin, 120);
      expect(s.spillMin, 60);
      expect(s.toString(), '11:00 PM-1:00 AM (next day)');
    });

    test('a session may not exceed 24 hours', () {
      expect(const Session(23 * 60, 23 * 60 + 1441).isValid, isFalse);
      expect(const Session(23 * 60, 23 * 60 + 1440).isValid, isTrue);
    });

    test('the slots after midnight land on the NEXT calendar day', () {
      final slots = _oneDay(_sched(sessions: const [Session(23 * 60, 25 * 60)]));
      // 23:00, 23:30, 00:00, 00:30 - four 30-minute slots inside two hours.
      expect(slots.length, 4);
      expect(slots.first.start, DateTime(2026, 8, 3, 23, 0));
      expect(slots.last.start, DateTime(2026, 8, 4, 0, 30));
      // The last one must still FINISH inside the session.
      expect(slots.last.end, DateTime(2026, 8, 4, 1, 0));
    });

    test('a night is ONE working day for the per-day cap', () {
      // Two already booked, cap of three: exactly one slot may remain, and the
      // booking after midnight has to count against the same night. Counting by
      // calendar date would reset the cap at 00:00 and offer more.
      final slots = generateSlots(
        _sched(
          sessions: const [Session(23 * 60, 25 * 60)],
          rules: const ConsultRules(
            slotMinutes: 30,
            bufferAfterMin: 0,
            minNoticeMinutes: 0,
            maxPerDay: 3,
            maxConsecutive: 0,
          ),
        ),
        from: _now,
        days: 1,
        booked: {
          DateTime(2026, 8, 3, 23, 0),
          DateTime(2026, 8, 4, 0, 0), // after midnight, same shift
        },
        now: _now,
      );
      expect(slots.length, 1);
    });

    test('spillsInto catches a clash the same-day overlap check cannot', () {
      const late = Session(23 * 60, 26 * 60); // 11 PM - 2 AM
      const earlyNext = DaySchedule([Session(60, 9 * 60)]); // 1 AM - 9 AM
      const clearNext = DaySchedule([Session(10 * 60, 13 * 60)]);
      expect(spillsInto(late, earlyNext), isTrue);
      expect(spillsInto(late, clearNext), isFalse);
      // An ordinary session never spills, whatever the next day looks like.
      expect(spillsInto(const Session(600, 780), earlyNext), isFalse);
    });

    test('an overnight session survives toMap/fromMap unchanged', () {
      const s = Session(23 * 60, 25 * 60);
      final back = Session.fromMap(s.toMap());
      expect(back, s);
      expect(back.crossesMidnight, isTrue);
    });
  });

  group('round trips', () {
    test('a whole schedule survives toMap/fromMap', () {
      final s = DoctorSchedule.starter.copyWith(
        rules: const ConsultRules(slotMinutes: 20, maxPerDay: 5),
        timeOff: [
          TimeOff(
              fromDate: DateTime(2026, 9, 1),
              toDate: DateTime(2026, 9, 7),
              reason: 'Conference')
        ],
        overrides: {
          DateOverride.keyFor(DateTime(2026, 8, 20)):
              DateOverride(date: DateTime(2026, 8, 20), closed: true),
        },
      );
      final back = DoctorSchedule.fromMap(s.toMap());
      expect(back.rules.slotMinutes, 20);
      expect(back.rules.maxPerDay, 5);
      expect(back.timeOff.single.reason, 'Conference');
      expect(back.overrides.values.single.closed, isTrue);
      expect(back.dayFor(DateTime.monday).sessions.length, 2);
      expect(back.dayFor(DateTime.sunday).isWorking, isFalse);
    });
  });
}
