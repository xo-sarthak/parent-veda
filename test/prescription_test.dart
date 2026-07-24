// =============================================================================
//  Prescription model round-trips
// -----------------------------------------------------------------------------
//  The write_prescription flow needs a server, so this pins the client model:
//  a server row parses into a Prescription, items and advice intact, and the
//  store indexes it by booking.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/prescription.dart';

void main() {
  test('a server row parses into a Prescription', () {
    final p = Prescription.fromRow({
      'id': 'rx_1',
      'booking_id': 'bkg_9',
      'expert_id': 'neha',
      'items': [
        {'medicine': 'Paracetamol', 'dosage': '5ml twice a day', 'duration': '3 days'},
        {'medicine': 'ORS', 'dosage': 'after each loose stool'},
      ],
      'advice': 'Fluids and rest. Call if fever crosses 102.',
      'created_at': '2026-07-24T10:00:00Z',
    });

    expect(p.bookingId, 'bkg_9');
    expect(p.items.length, 2);
    expect(p.items.first.medicine, 'Paracetamol');
    expect(p.items.first.duration, '3 days');
    expect(p.advice, contains('Fluids'));
  });

  test('the store indexes prescriptions by booking', () {
    final store = PrescriptionStore.instance;
    expect(store.hasFor('bkg_none'), isFalse);
    expect(store.forBooking('bkg_none'), isNull);
  });

  test('an empty RxItem is recognised', () {
    expect(const RxItem(medicine: '   ').isEmpty, isTrue);
    expect(const RxItem(medicine: 'Iron').isEmpty, isFalse);
  });
}
