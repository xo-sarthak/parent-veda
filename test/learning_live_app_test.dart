// L3, the app half: the host-missed reason survives every copy of a booking,
// and Your bookings › Past says it in her words (docs/LEARNING-ARCHITECTURE.md
// L.22, LA-17).

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/screens/learn/pv_my_learning_screen.dart';

Map<String, Object?> _row({String status = 'cancelled', String? reason}) => {
  'id': 'b1',
  'offering_id': 'off_mc_sleepreg',
  'slot_id': 'ps_mc_sleepreg_s1',
  'stage': 'parenting',
  'title': 'Sleep regressions',
  'starts_utc': '2026-10-31T06:16:00Z',
  'duration_min': 60,
  'status': status,
  'created_at': '2026-10-29T10:00:00Z',
  'cancel_reason': reason,
};

void main() {
  test('a server row carries the reason, and the cache keeps it', () {
    final b = Booking.fromRow(_row(reason: 'host_missed'));
    expect(b.status, BookingStatus.cancelled);
    expect(b.hostMissed, isTrue);
    final again = Booking.fromMap(b.toMap());
    expect(again.hostMissed, isTrue);
    expect(again.copyWith(status: BookingStatus.cancelled).hostMissed, isTrue);
  });

  test('her own cancellation has no reason', () {
    final b = Booking.fromRow(_row());
    expect(b.hostMissed, isFalse);
    expect(b.toMap().containsKey('cancelReason'), isFalse);
  });

  test('Past says who did not come, not just "Cancelled"', () {
    expect(
      pvPastStatusLine(Booking.fromRow(_row(reason: 'host_missed'))),
      contains("couldn't make it"),
    );
    expect(pvPastStatusLine(Booking.fromRow(_row())), 'Cancelled');
    expect(pvPastStatusLine(Booking.fromRow(_row(status: 'missed'))), 'Missed');
    expect(
      pvPastStatusLine(Booking.fromRow(_row(status: 'attended'))),
      'Attended',
    );
  });

  test('the recording line follows the server\'s state', () {
    expect(pvPastRecordingLine(null), isNull);
    expect(
      pvPastRecordingLine({'status': 'ready'}),
      'Recording ready to watch',
    );
    expect(
      pvPastRecordingLine({'status': 'importing'}),
      contains('on its way'),
    );
    expect(pvPastRecordingLine({'status': 'failed'}), isNull);
  });

  test(
    'an unknown status still reads as upcoming, which is why 0128 adds a reason, not a status',
    () {
      expect(
        Booking.fromRow(_row(status: 'host_missed')).status,
        BookingStatus.upcoming,
      );
    },
  );
}
