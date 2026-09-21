// The bell's feed is a pure projection of the account's rows — this holds the
// sentences and the ordering, so a seeded month reads the way the panel
// promises and nothing invents an event that has no row behind it.

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/doctor/doctor_updates.dart';

String _r(int paise) => '₹${paise ~/ 100}';
String _d(DateTime d) => '${d.day}/${d.month}';
String _t(DateTime d) => '${d.hour}:${d.minute.toString().padLeft(2, '0')}';

void main() {
  final now = DateTime(2026, 9, 21, 16, 0);

  DoctorUpdateInput input({
    List<UpdateBooking> upcoming = const [],
    List<UpdateClass> classes = const [],
    List<UpdateEarning> earnings = const [],
    List<UpdatePayout> payouts = const [],
    List<UpdateNotice> notices = const [],
  }) =>
      DoctorUpdateInput(
        now: now,
        upcoming: upcoming,
        classes: classes,
        earnings: earnings,
        payouts: payouts,
        notices: notices,
        rupees: _r,
        dayDate: _d,
        time: _t,
      );

  test('an empty account has no updates — nothing is invented', () {
    expect(doctorUpdates(input()), isEmpty);
  });

  test('a booking is news dated when it was booked, and a reminder inside 24h', () {
    final b = UpdateBooking(
      id: 'b1',
      who: 'Meera',
      startsAt: now.add(const Duration(hours: 6)),
      durationMin: 30,
      bookedAt: now.subtract(const Duration(days: 2)),
    );
    final out = doctorUpdates(input(upcoming: [b]));
    expect(out.map((u) => u.kind), [DoctorUpdateKind.callSoon, DoctorUpdateKind.booking]);
    expect(out.first.title, 'Your consultation with Meera is today at 22:00');
    expect(out.last.title, 'Meera booked a consultation');
    expect(out.last.at, b.bookedAt);
  });

  test('a booking more than a day out is news only', () {
    final b = UpdateBooking(id: 'b2', who: 'Meera', startsAt: now.add(const Duration(days: 3)), durationMin: 30, bookedAt: now);
    expect(doctorUpdates(input(upcoming: [b])).map((u) => u.kind), [DoctorUpdateKind.booking]);
  });

  test('a class inside a fortnight says when, relatively', () {
    final c = UpdateClass(id: 'c1', title: 'Sleep in the first year', kind: 'Masterclass', startsAt: now.add(const Duration(days: 8)), seats: 12);
    final out = doctorUpdates(input(classes: [c]));
    expect(out.single.title, 'Your masterclass is on 29/9');
    expect(out.single.body, 'Sleep in the first year · 16:00 · 12 seats');
    final far = UpdateClass(id: 'c2', title: 'x', kind: 'Cohort', startsAt: now.add(const Duration(days: 40)));
    expect(doctorUpdates(input(classes: [far])), isEmpty);
  });

  test('money in and money reversed read differently, and old rows drop off', () {
    final e = UpdateEarning(id: 'e1', headline: 'Meera', source: 'Consultation', at: now.subtract(const Duration(days: 3)), expertPaise: 192000, reversal: false);
    final r = UpdateEarning(id: 'e2', headline: 'Meera', source: 'Consultation', at: now.subtract(const Duration(days: 1)), expertPaise: -192000, reversal: true, note: 'Parent cancelled');
    final old = UpdateEarning(id: 'e3', headline: 'x', source: 'Video', at: now.subtract(const Duration(days: 90)), expertPaise: 100, reversal: false);
    final out = doctorUpdates(input(earnings: [e, r, old]));
    expect(out.map((u) => u.id), ['rev_e2', 'earn_e1']);
    expect(out[0].title, '₹1920 reversed');
    expect(out[0].body, 'Parent cancelled');
    expect(out[1].title, 'You earned ₹1920');
    expect(out[1].body, 'Consultation · Meera');
    // No parent name on the row: the source once, not twice. A zero reversal
    // (a row that froze before its rate existed) is still a sentence.
    final bare = UpdateEarning(id: 'e4', headline: 'Consultation', source: 'Consultation', at: now, expertPaise: 64000, reversal: false);
    final zero = UpdateEarning(id: 'e5', headline: '', source: 'Consultation', at: now, expertPaise: 0, reversal: true);
    final out2 = doctorUpdates(input(earnings: [bare, zero]));
    expect(out2.map((u) => u.body), ['Consultation', 'Consultation']);
    expect(out2.map((u) => u.title), containsAll(['You earned ₹640', 'A consultation was reversed']));
  });

  test('a payout sent names the account; one scheduled says when', () {
    final paid = UpdatePayout(id: 'p1', amountPaise: 2348000, status: 'paid', at: now.subtract(const Duration(days: 14)), bankLast4: '4321', reference: 'UTR1');
    final due = UpdatePayout(id: 'p2', amountPaise: 192000, status: 'scheduled', at: now.add(const Duration(days: 16)));
    final out = doctorUpdates(input(payouts: [paid, due]));
    expect(out[0].title, '₹1920 payout is scheduled');
    expect(out[0].body, 'To your account · 7/10');
    expect(out[1].title, '₹23480 sent to your account ending 4321');
    expect(out[1].body, 'Bank transfer · ref UTR1');
  });

  test('newest first, capped', () {
    final many = [
      for (var i = 0; i < 50; i++)
        UpdateEarning(id: 'e$i', headline: 'x', source: 'Video', at: now.subtract(Duration(hours: i)), expertPaise: 100, reversal: false),
    ];
    final out = doctorUpdates(input(earnings: many));
    expect(out.length, 40);
    expect(out.first.id, 'earn_e0');
  });

  test('relative days', () {
    expect(doctorRelativeDay(now, now, _d), 'today');
    expect(doctorRelativeDay(now.add(const Duration(days: 1)), now, _d), 'tomorrow');
    expect(doctorRelativeDay(now.add(const Duration(days: 3)), now, _d), 'on Thursday');
    expect(doctorRelativeDay(now.add(const Duration(days: 9)), now, _d), 'on 30/9');
  });
}
