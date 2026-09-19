// =============================================================================
//  Hosting a class — the one place the "may the host go live?" rule lives
// -----------------------------------------------------------------------------
//  Extracted from doctor_home_screen._sessionRow (kept there for revert) so
//  the Home's attention card, the Classes screen and Appointments all decide
//  the same way. The reasoning, unchanged:
//
//  * sessionSlotsFor, NOT slotsFor: the parent-facing one drops slots that are
//    full or already running — right for a parent choosing a seat, fatal for
//    the person teaching.
//  * A generated class date is `now + 5..8 days`, recomputed on every read,
//    so a window check against it can never open. `booking_slots.starts_utc`
//    is written once: a real row means a real date; no row means nobody has
//    booked and the host may go live now — starting the session IS the
//    schedule until programmes get a real one (STILL-OPEN §5.1c).
//  * Thirty minutes of lead against the attendee's ten (0079 holds the same
//    rule server-side); this only decides whether the button looks live.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import '../../booking/booking_models.dart';
import '../../booking/call_prejoin_screen.dart';
import '../../booking/server_slots.dart';
import '../../doctor/doctor_session.dart';
import '../../widgets/global_ask_fab.dart' show kCallRoute;
import '../../doctor/doctor_directory.dart';
import '../post_pregnancy/pp_experts_data.dart' show expertByIdOrNull;

class HostSession {
  const HostSession({required this.offering, required this.next, required this.scheduled, required this.openable});
  final Offering offering;
  final Slot? next;
  /// Somebody has booked: the date is real.
  final bool scheduled;
  /// The host may enter now.
  final bool openable;

  bool get isCohort => offering.kind == OfferingKind.cohort;
  String get kindLabel => isCohort ? 'Cohort' : 'Masterclass';

  /// Minutes until the window opens, when it is not open yet and there is a
  /// real date. Null otherwise.
  int? get minutesUntilOpen {
    if (openable || !scheduled || next == null) return null;
    final opens = next!.startsUtc.subtract(const Duration(minutes: 30));
    final d = opens.difference(DateTime.now().toUtc()).inMinutes;
    return d < 0 ? 0 : d;
  }
}

HostSession hostSessionFor(Offering o, {DateTime? now}) {
  final slots = BookingCatalog.instance.sessionSlotsFor(o.id);
  final next = slots.isEmpty ? null : slots.first;
  final n = (now ?? DateTime.now()).toUtc();
  final scheduled = next != null && ServerSlotStore.instance.isReal(next.id);
  final openable = next != null &&
      (!scheduled ||
          (n.isAfter(next.startsUtc.subtract(const Duration(minutes: 30))) &&
              n.isBefore(next.endsUtc.add(const Duration(minutes: 15)))));
  return HostSession(offering: o, next: next, scheduled: scheduled, openable: openable);
}

/// The name a parent sees in the call. Null-safe on purpose: expertById()
/// falls back to the FIRST expert for an unknown id — the stranger's-name
/// defect the roster once had — so the null-returning lookups are used.
String? doctorDisplayName() {
  final id = DoctorSession.instance.expertId;
  if (id == null || id.isEmpty) return null;
  return doctorInfoById(id)?.name ?? expertByIdOrNull(id)?.name;
}

/// Into the green room as the host. A host has no booking id; the slot IS
/// the session. An unbooked class is seeded at the moment the host starts
/// it, not at the generated placeholder date — otherwise open_session_room
/// would write a row saying the session is next Friday and refuse to open it
/// for five days.
void openHostSession(BuildContext context, HostSession h) {
  if (!h.openable || h.next == null) return;
  final now = DateTime.now().toUtc();
  final next = h.next!;
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kCallRoute),
    builder: (_) => CallPrejoinScreen(
      bookingId: '',
      title: h.offering.title,
      displayName: doctorDisplayName(),
      waitingFor: h.offering.title,
      startsUtc: h.scheduled ? next.startsUtc : now,
      hostSlot: h.scheduled
          ? next
          : Slot(
              id: next.id,
              offeringId: next.offeringId,
              expertId: next.expertId,
              startsUtc: now,
              durationMin: next.durationMin,
              capacity: next.capacity,
              booked: next.booked,
            ),
    ),
  ));
}

/// Into the green room for a 1:1 consult.
void openConsult(BuildContext context, Booking b, {required String waitingFor}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kCallRoute),
    builder: (_) => CallPrejoinScreen(
      bookingId: b.id,
      title: b.title,
      displayName: doctorDisplayName(),
      waitingFor: waitingFor,
      startsUtc: b.startsUtc,
    ),
  ));
}
