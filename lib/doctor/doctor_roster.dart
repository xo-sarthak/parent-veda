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
import '../screens/post_pregnancy/pp_child_profile.dart';
import 'consult_patient.dart';

class DoctorRoster extends ChangeNotifier {
  DoctorRoster._();
  static final DoctorRoster instance = DoctorRoster._();

  List<Booking> _server = const [];

  /// Who each booking is FOR, keyed by booking id. Kept beside the bookings
  /// rather than on Booking itself: a Booking is the parent's own row in their
  /// history, and the parent does not need to be told who they are.
  final Map<String, ConsultPatient> _patients = {};

  /// The parent behind a booking. Never null - an unknown parent still gets a
  /// card that says "Parent" rather than the doctor's own name.
  ///
  /// Server rows carry the real parent (0034). A LOCAL booking has no server
  /// row, which on a single test device means the parent is whoever is using
  /// this phone - so their own profile is the honest answer, and it makes the
  /// book-as-parent-then-switch-to-doctor demo show real details.
  ConsultPatient patientFor(String bookingId, {ServiceStage? stage}) {
    final known = _patients[bookingId];
    if (known != null) return known;
    if (stage == ServiceStage.parenting) {
      final child = ChildProfileStore.instance;
      // No parent NAME exists on device (ChildProfileStore holds the child's
      // name, not the parent's), so the card says "Parent" and shows the stage
      // context we genuinely have. Inventing a name would be worse.
      return ConsultPatient(childAgeMonths: child.ageInMonths);
    }
    return const ConsultPatient();
  }

  /// Pull the server roster for the logged-in expert. No-op offline / logged
  /// out — the local view still works.
  Future<void> refresh() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final rows = await SupabaseRepo.callFunction('expert_roster');
      final maps = rows.whereType<Map>().toList(growable: false);
      _server = maps.map(_fromRow).toList(growable: false);
      // 0034 returns the parent's name + due date alongside each booking, so
      // the doctor knows who they are seeing.
      for (final r in maps) {
        final id = (r['id'] ?? '').toString();
        if (id.isNotEmpty) _patients[id] = ConsultPatient.fromRow(r);
      }
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

  // The expert_roster() rows are booking_bookings rows (snake_case). The
  // mapping moved to Booking.fromRow so the parent side decodes the same row
  // the same way — see the note there.
  static Booking _fromRow(Map r) => Booking.fromRow(r);
}
