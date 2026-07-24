// =============================================================================
//  DoctorRoster — what a given expert has on their plate
// -----------------------------------------------------------------------------
//  Two sources, merged:
//    * SERVER — expert_roster() returns bookings made against this expert by
//      ANY parent, on ANY device. This is what makes a real two-device consult
//      work: the doctor sees the mother's booking even though it isn't on their
//      phone. Fetched via [refresh]; cached so the UI reads it synchronously.
//    * LOCAL — the on-device BookingStore filtered by expertId, so the flow also
//      demos on a single device (book as the mother, switch to doctor mode).
//  Deduped by id, so a booking present in both counts once.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../booking/booking_catalog.dart';
import '../booking/booking_models.dart';
import '../booking/booking_store.dart';
import '../services/remote/supabase_repo.dart';

class DoctorRoster extends ChangeNotifier {
  DoctorRoster._();
  static final DoctorRoster instance = DoctorRoster._();

  List<Booking> _server = const [];

  /// Pull the server roster for the logged-in expert. No-op offline / logged
  /// out — the local view still works.
  Future<void> refresh() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final rows = await SupabaseRepo.callFunction('expert_roster');
      _server = rows
          .whereType<Map>()
          .map(_fromRow)
          .toList(growable: false);
      notifyListeners();
    } catch (_) {/* keep whatever we have */}
  }

  List<Booking> _local(String expertId) {
    final cat = BookingCatalog.instance;
    return BookingStore.instance
        .bookings()
        .where((b) => cat.offeringById(b.offeringId)?.expertId == expertId)
        .toList();
  }

  List<Booking> _merged(String expertId) {
    final byId = <String, Booking>{};
    for (final b in [..._local(expertId), ..._server]) {
      byId[b.id] = b;
    }
    return byId.values.toList();
  }

  /// Upcoming consults with this expert, soonest first.
  List<Booking> upcomingConsults(String expertId) {
    final now = DateTime.now().toUtc();
    final all = _merged(expertId)
        .where((b) =>
            b.status == BookingStatus.upcoming && b.endsUtc.isAfter(now))
        .toList()
      ..sort((a, b) => a.startsUtc.compareTo(b.startsUtc));
    return all;
  }

  /// Past consults with this expert.
  List<Booking> pastConsults(String expertId) {
    final now = DateTime.now().toUtc();
    return _merged(expertId)
        .where((b) => !b.isUpcoming || b.endsUtc.isBefore(now))
        .toList()
      ..sort((a, b) => b.startsUtc.compareTo(a.startsUtc));
  }

  /// The sessions this expert runs — their masterclasses and cohorts.
  List<Offering> sessionsBy(String expertId) => BookingCatalog.instance
      .offerings()
      .where((o) =>
          o.expertId == expertId &&
          (o.kind == OfferingKind.masterclass ||
              o.kind == OfferingKind.cohort))
      .toList();

  // The expert_roster() rows are booking_bookings rows (snake_case).
  static Booking _fromRow(Map r) => Booking(
        id: (r['id'] ?? '').toString(),
        offeringId: (r['offering_id'] ?? '').toString(),
        slotId: (r['slot_id'] ?? '').toString(),
        stage: ServiceStage.values.firstWhere(
          (s) => s.name == r['stage'],
          orElse: () => ServiceStage.parenting,
        ),
        title: (r['title'] ?? '').toString(),
        startsUtc: DateTime.parse(r['starts_utc'].toString()).toUtc(),
        durationMin: (r['duration_min'] as num?)?.toInt() ?? 0,
        status: BookingStatus.values.firstWhere(
          (s) => s.name == r['status'],
          orElse: () => BookingStatus.upcoming,
        ),
        bookedUtc: DateTime.parse(
                (r['created_at'] ?? r['starts_utc']).toString())
            .toUtc(),
      );
}
