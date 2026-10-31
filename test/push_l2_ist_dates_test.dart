// =============================================================================
//  Phase 6b leftover L2: the phone reads the server's dates in India's calendar
// -----------------------------------------------------------------------------
//  push_sends.send_on and push_audience.busy_evenings are IST dates, and the
//  campaign goes at 19:00 IST. Before L2 the phone compared them with its OWN
//  calendar: the same in India, wrong anywhere else.
//
//  Every time below is written as a UTC instant, so the test means the same
//  on any machine, whatever zone it runs in. 13:30 UTC is 19:00 IST.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/services/push_audience.dart';
import 'package:parentveda/services/push_bookings.dart';
import 'package:parentveda/services/push_wire.dart';
import 'package:parentveda/widgets/pv_campaign_tonight.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  group('the IST helpers', () {
    test('a day and an hour are India\'s, whatever the instant\'s zone', () {
      // 23:00 in London on 31 Oct (GMT) is 04:30 on 1 Nov in India.
      final londonLate = DateTime.utc(2026, 10, 31, 23);
      expect(PushWire.istDay(londonLate), DateTime(2026, 11, 1));
      expect(PushWire.istHour(londonLate), 4);
      // 13:30 UTC is 19:00 IST the same day.
      expect(PushWire.istDay(DateTime.utc(2026, 10, 31, 13, 30)),
          DateTime(2026, 10, 31));
      expect(PushWire.istHour(DateTime.utc(2026, 10, 31, 13, 30)), 19);
      // 18:29 UTC is 23:59 IST, 18:30 UTC is midnight: the day turns there.
      expect(PushWire.istDay(DateTime.utc(2026, 10, 31, 18, 29)),
          DateTime(2026, 10, 31));
      expect(PushWire.istDay(DateTime.utc(2026, 10, 31, 18, 30)),
          DateTime(2026, 11, 1));
    });

    test('istTime is the 19:00 IST instant', () {
      expect(PushWire.istTime(DateTime(2026, 10, 31), 19).toUtc(),
          DateTime.utc(2026, 10, 31, 13, 30));
    });

    test('dateKey of an IST day is the send_on string', () {
      expect(PushWire.dateKey(PushWire.istDay(DateTime.utc(2026, 10, 31, 23))),
          '2026-11-01');
    });
  });

  group('busy evenings are India\'s evenings', () {
    final now = DateTime.utc(2026, 10, 31, 4); // 09:30 IST

    test('a ring in India\'s evening counts on India\'s date', () {
      expect(pushBusyEvenings([DateTime.utc(2026, 10, 31, 14)], now),
          [DateTime(2026, 10, 31)]); // 19:30 IST
    });

    test('a London evening that is India\'s next morning is not busy', () {
      // 20:00 GMT on 31 Oct = 01:30 IST on 1 Nov: a night, not an evening.
      expect(pushBusyEvenings([DateTime.utc(2026, 10, 31, 20)], now), isEmpty);
    });

    test('the horizon is India\'s today plus 14, by the calendar', () {
      final out = pushBusyEvenings([
        DateTime.utc(2026, 11, 14, 14), // day 14 IST: kept
        DateTime.utc(2026, 11, 15, 14), // day 15: past what the phone arms
        DateTime.utc(2026, 10, 30, 14), // yesterday
      ], now);
      expect(out, [DateTime(2026, 11, 14)]);
    });

    test('just after India\'s midnight, "today" is already the next day', () {
      // 19:00 UTC on 31 Oct = 00:30 IST on 1 Nov. An evening ring on 31 Oct
      // IST is yesterday's, and the server would drop it anyway.
      final late = DateTime.utc(2026, 10, 31, 19);
      expect(pushBusyEvenings([DateTime.utc(2026, 10, 31, 14)], late), isEmpty);
    });
  });

  group('a booked evening is India\'s evening', () {
    final booked = {DateTime(2026, 10, 31)}; // send_on 2026-10-31

    test('a ring at 19:30 IST on the booked day is in the campaign\'s evening', () {
      expect(pushEveningBooked(DateTime.utc(2026, 10, 31, 14), booked, 14), isTrue);
    });

    test('a morning in India is not, whatever the phone\'s clock says', () {
      // 03:00 UTC = 08:30 IST.
      expect(pushEveningBooked(DateTime.utc(2026, 10, 31, 3), booked, 14), isFalse);
    });

    test('India\'s next day is not the booked day', () {
      // 19:00 UTC on 31 Oct = 00:30 IST on 1 Nov.
      expect(pushEveningBooked(DateTime.utc(2026, 10, 31, 19), booked, 14), isFalse);
    });

    test('the booked set starts at India\'s today', () {
      final b = [
        PushBooking(rowId: 'a', day: DateTime(2026, 10, 31), status: 'queued'),
        PushBooking(rowId: 'b', day: DateTime(2026, 11, 1), status: 'queued'),
      ];
      // 19:00 UTC on 31 Oct is already 1 Nov in India.
      expect(pushBookedEvenings(b, DateTime.utc(2026, 10, 31, 19)),
          {DateTime(2026, 11, 1)});
    });

    test('tonight is India\'s tonight', () {
      final s = PushBookings.instance
        ..debugSet([
          PushBooking(rowId: 'a', day: DateTime(2026, 11, 1), status: 'queued',
              title: 'A calm class'),
        ]);
      expect(s.tonight(now: DateTime.utc(2026, 10, 31, 19))?.rowId, 'a');
      expect(s.tonight(now: DateTime.utc(2026, 10, 31, 12)), isNull);
      s.debugReset();
    });

    test('Messages shows the campaign from 19:00 IST', () {
      final b = PushBooking(rowId: 'a', day: DateTime(2026, 10, 31),
          status: 'queued', title: 'A calm class');
      expect(pvCampaignShowsNow(b, DateTime.utc(2026, 10, 31, 13, 29)), isFalse);
      expect(pvCampaignShowsNow(b, DateTime.utc(2026, 10, 31, 13, 30)), isTrue);
    });
  });

  group('no local date is left on the push path', () {
    test('the comparisons go through PushWire.ist*', () {
      final audience = _code('lib/services/push_audience.dart');
      expect(audience, contains('PushWire.istDay(now)'));
      expect(audience, contains('PushWire.istHour(r)'));
      final bookings = _code('lib/services/push_bookings.dart');
      expect(bookings, contains('PushWire.istHour(at) >= eveningFromHour'));
      expect(bookings, contains('booked.contains(PushWire.istDay(at))'));
      expect(bookings, contains('PushWire.dateKey(PushWire.istDay(t))'));
      expect(bookings, isNot(contains('DateTime(now.year, now.month, now.day)')));
      expect(bookings, isNot(contains('DateTime(t.year, t.month, t.day)')));
      expect(_code('lib/services/family_phone_plan.dart'),
          contains('PushWire.istTime(d, kPushCampaignHour)'));
      expect(_code('lib/widgets/pv_campaign_tonight.dart'),
          contains('PushWire.istTime(b.day, kPushCampaignHour)'));
    });
  });
}
