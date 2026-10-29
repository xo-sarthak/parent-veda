// =============================================================================
//  seedTimetable — give a class the server dates it needs for a test
// -----------------------------------------------------------------------------
//  Since L2c (2026-10-29) a masterclass, cohort or class pack has exactly the
//  dates the server's timetable gives it: the `ps_<session id>` slots that
//  0126 writes from `programme_sessions`. Nothing is generated on the phone,
//  so a test that books a class must first say when the class is - the same
//  thing an editor does in the panel.
// =============================================================================

import 'package:parentveda/booking/server_slots.dart';

/// Seed [count] future `ps_` slots for each of [offeringIds], a day apart,
/// replacing whatever the slot store held.
void seedTimetable(
  List<String> offeringIds, {
  int count = 3,
  int capacity = 40,
  int booked = 0,
  DateTime? from,
}) {
  final start = (from ?? DateTime.now().toUtc()).add(const Duration(days: 2));
  final slots = <String, ServerSlot>{};
  for (final o in offeringIds) {
    for (var i = 0; i < count; i++) {
      final id = 'ps_${o}_$i';
      slots[id] = ServerSlot(
        id: id,
        offeringId: o,
        booked: booked,
        startsUtc: start.add(Duration(days: i)),
        expertId: 'exp_host',
        durationMin: 60,
        capacity: capacity,
      );
    }
  }
  ServerSlotStore.instance.seed(slots);
}
