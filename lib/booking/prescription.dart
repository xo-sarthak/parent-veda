// =============================================================================
//  Prescription — what a doctor writes for a parent after a consult
// -----------------------------------------------------------------------------
//  A list of medicines (each with a dosage + duration) plus free-text advice,
//  tied to the booking it came from. The doctor writes it through the
//  write_prescription() function; the parent reads their own via RLS. Fetched
//  on demand and cached in PrescriptionStore so both sides render it the same.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // ---- "she has not been told about this one yet" --------------------------
  //
  // The parent app has no push channel for this: `prescriptions` is polled, not
  // subscribed. So "has arrived" has to be worked out by comparing what the
  // server has against what we have already announced.
  //
  // WHY THAT SET IS PERSISTED, and it is the whole design.
  //
  // The obvious version — "anything not already in the in-memory map is new" —
  // is wrong twice, in opposite directions:
  //
  //   * on the FIRST refresh of a launch the map is empty, so every
  //     prescription she has ever had looks new and she gets a fistful of
  //     notifications about consultations from months ago;
  //   * suppressing that by ignoring the first refresh then means a
  //     prescription written while the app was CLOSED — which is the normal
  //     case, since doctors write up after the call — is never announced at
  //     all, because by the next launch it is part of the baseline.
  //
  // Both failures come from using "have I loaded this?" to answer "have I told
  // her?". They are different questions, so this is a different set, and it
  // outlives the process the way the fact it records does.

  static const _announcedKey = 'rx_announced_bookings';
  Set<String>? _announced;
  final Set<String> _newSinceLastRefresh = {};

  Future<Set<String>> _announcedIds() async {
    if (_announced != null) return _announced!;
    try {
      final prefs = await SharedPreferences.getInstance();
      _announced = (prefs.getStringList(_announcedKey) ?? const []).toSet();
    } catch (_) {
      // No storage is not a reason to fail a refresh. An empty set means she
      // may hear about something twice, which is a far smaller harm than a
      // prescription she is never told about.
      _announced = <String>{};
    }
    return _announced!;
  }

  /// Booking ids that have gained a prescription she has not been told about.
  ///
  /// Taking them MARKS them announced and persists that, so the caller must
  /// actually act on what it takes.
  Future<Set<String>> takeNewlyArrived() async {
    if (_newSinceLastRefresh.isEmpty) return const {};
    final out = Set<String>.from(_newSinceLastRefresh);
    _newSinceLastRefresh.clear();
    final announced = await _announcedIds()..addAll(out);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_announcedKey, announced.toList());
    } catch (_) {/* best-effort; see above */}
    return out;
  }

  /// True once a refresh has actually completed, so "no prescription" can be
  /// told apart from "have not looked yet".
  ///
  /// Without this the doctor's list rendered "still needs a prescription" for
  /// every past consult on a cold start, which is an invitation to write a
  /// duplicate of something already written.
  bool _loaded = false;
  bool get loaded => _loaded;

  /// Pull every prescription this user may see (their own as a parent, or
  /// theirs as the hosting expert). Best-effort; keeps the cache on failure.
  Future<void> refresh() async {
    if (!SupabaseRepo.isLoggedIn) return;

    // ORDERED, ascending, so the loop below ends on the NEWEST row for each
    // booking. It used to read an unordered select and assign each row over
    // the last, which with two rows for one booking (easy to produce: nothing
    // stops a doctor writing twice) showed the parent whichever one Postgres
    // happened to hand back first.
    final rows = await SupabaseRepo.selectAll('prescriptions',
        orderBy: 'created_at', ascending: true);
    final announced = await _announcedIds();
    for (final r in rows) {
      final p = Prescription.fromRow(r);
      if (p.bookingId.isEmpty) continue;
      if (!announced.contains(p.bookingId)) {
        _newSinceLastRefresh.add(p.bookingId);
      }
      _byBooking[p.bookingId] = p;
    }
    _loaded = true;
    notifyListeners();
  }

  /// Doctor writes a prescription for [bookingId]. Returns true on success.
  ///
  /// [expertId] is the writer's own expert id. The SERVER decides what actually
  /// goes in the row (`write_prescription` derives it, and a client could not
  /// be trusted with it anyway) — this is only so the local mirror below shows
  /// the same prescriber the server will. It used to write `expertId: ''`, and
  /// the parent's view consequently had no way to say who had prescribed.
  Future<bool> write({
    required String bookingId,
    required List<RxItem> items,
    required String advice,
    String expertId = '',
  }) async {
    // A LIE THIS USED TO TELL. SupabaseRepo.callFunction returns `[]` rather
    // than throwing when nobody is logged in, so the try below caught nothing,
    // this returned true, and the doctor was told "Prescription sent to the
    // parent." for a row that was never written — and, since this store has no
    // persistence, was gone at the next launch.
    //
    // A prescription is not somewhere to be optimistic. Check first.
    if (!SupabaseRepo.isLoggedIn) return false;

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
      expertId: expertId,
      items: items,
      advice: advice,
      createdUtc: DateTime.now().toUtc(),
    );
    notifyListeners();
    return true;
  }
}
