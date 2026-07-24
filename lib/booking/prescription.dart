// =============================================================================
//  Prescription — what a doctor writes for a parent after a consult
// -----------------------------------------------------------------------------
//  A list of medicines (each with a dosage + duration) plus free-text advice,
//  tied to the booking it came from. The doctor writes it through the
//  write_prescription() function; the parent reads their own via RLS. Fetched
//  on demand and cached in PrescriptionStore so both sides render it the same.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../services/remote/supabase_repo.dart';

@immutable
class RxItem {
  const RxItem({
    required this.medicine,
    this.dosage = '',
    this.duration = '',
    this.notes = '',
  });

  final String medicine;
  final String dosage; // "1 tablet twice a day"
  final String duration; // "5 days"
  final String notes;

  bool get isEmpty => medicine.trim().isEmpty;

  Map<String, Object?> toMap() =>
      {'medicine': medicine, 'dosage': dosage, 'duration': duration, 'notes': notes};

  static RxItem fromMap(Map d) => RxItem(
        medicine: (d['medicine'] ?? '').toString(),
        dosage: (d['dosage'] ?? '').toString(),
        duration: (d['duration'] ?? '').toString(),
        notes: (d['notes'] ?? '').toString(),
      );
}

@immutable
class Prescription {
  const Prescription({
    required this.id,
    required this.bookingId,
    required this.expertId,
    required this.items,
    required this.advice,
    required this.createdUtc,
  });

  final String id;
  final String bookingId;
  final String expertId;
  final List<RxItem> items;
  final String advice;
  final DateTime createdUtc;

  static Prescription fromRow(Map r) => Prescription(
        id: (r['id'] ?? '').toString(),
        bookingId: (r['booking_id'] ?? '').toString(),
        expertId: (r['expert_id'] ?? '').toString(),
        items: ((r['items'] as List?) ?? const [])
            .whereType<Map>()
            .map(RxItem.fromMap)
            .toList(),
        advice: (r['advice'] ?? '').toString(),
        createdUtc: DateTime.parse(
                (r['created_at'] ?? DateTime.now().toUtc().toIso8601String())
                    .toString())
            .toUtc(),
      );
}

class PrescriptionStore extends ChangeNotifier {
  PrescriptionStore._();
  static final PrescriptionStore instance = PrescriptionStore._();

  // bookingId -> prescription (whichever RLS lets this user see).
  final Map<String, Prescription> _byBooking = {};

  int _seq = 0;

  Prescription? forBooking(String bookingId) => _byBooking[bookingId];
  bool hasFor(String bookingId) => _byBooking.containsKey(bookingId);

  /// Pull every prescription this user may see (their own as a parent, or
  /// theirs as the hosting expert). Best-effort; keeps the cache on failure.
  Future<void> refresh() async {
    if (!SupabaseRepo.isLoggedIn) return;
    final rows = await SupabaseRepo.selectAll('prescriptions');
    for (final r in rows) {
      final p = Prescription.fromRow(r);
      _byBooking[p.bookingId] = p;
    }
    notifyListeners();
  }

  /// Doctor writes a prescription for [bookingId]. Returns true on success.
  Future<bool> write({
    required String bookingId,
    required List<RxItem> items,
    required String advice,
  }) async {
    final id = 'rx_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';
    try {
      await SupabaseRepo.callFunction('write_prescription', {
        'p_id': id,
        'p_booking_id': bookingId,
        'p_items': items.map((i) => i.toMap()).toList(),
        'p_advice': advice,
      });
    } catch (_) {
      return false;
    }
    // Reflect locally so it shows immediately on the writer's side too.
    _byBooking[bookingId] = Prescription(
      id: id,
      bookingId: bookingId,
      expertId: '',
      items: items,
      advice: advice,
      createdUtc: DateTime.now().toUtc(),
    );
    notifyListeners();
    return true;
  }
}
