// =============================================================================
//  ServerSlotStore — what the booking ledger says about a slot
// -----------------------------------------------------------------------------
//  Two facts, and the app was inventing both.
//
//  1. THE SEAT COUNT. `booking_catalog` generated group slots like this:
//
//         capacity: 100, seatsTaken: 40 + seed % 45     // masterclass
//         capacity:  50, seatsTaken: 18 + seed % 25     // cohort
//
//     `seed` is a hash of the offering id, so "60 seats left" was a
//     deterministic function of a string — stable between reads, which is
//     exactly what made it convincing, and unrelated to whether one person had
//     booked or none had. The server row started at 0 and counted real
//     bookings, so the two were never the same number and the one a buyer saw
//     was the invented one.
//
//  2. THE DATE, which is worse, and is the reason this file grew past its
//     original name.
//
//     A one-off class is generated relative to NOW:
//
//         final local = from.toLocal().add(Duration(days: daysAhead));
//
//     so it is always five to eight days away from whenever you ask. Ask on
//     the 23rd and the class is on the 28th; ask on the 24th and the same slot
//     — same id — is on the 29th. **The class never arrives.** A parent who
//     books "Saturday" is shown "Sunday" the next morning, and a host's
//     "start session" moment is permanently five days in the future, which is
//     why a masterclass could not be hosted even once every other part of that
//     was built.
//
//     That is not a display bug. `booking_slots.starts_utc` is written ONCE —
//     self-seeded by the first booker (0029) or by the host opening the room
//     (0079) — and never moves. So the moment anybody books, there is a real
//     date, and the generated one must get out of its way.
//
// -----------------------------------------------------------------------------
//  THE RULE THIS ENCODES
// -----------------------------------------------------------------------------
//      row exists  ->  the server's date and count are the truth.
//      no row      ->  nobody has booked, so there is nothing to contradict.
//                      The generated date is a placeholder and the host may
//                      start whenever they like.
//
//  Which is honest about where the product actually is: masterclasses have no
//  scheduling system yet — registering programmes and their sessions is the
//  admin-panel work in STILL-OPEN §5.1c. Until that exists, the first real
//  event IS the schedule.
//
// -----------------------------------------------------------------------------
//  WHY A CACHE AND NOT A FETCH AT THE CALL SITE
// -----------------------------------------------------------------------------
//  `BookingCatalog.slotsFor()` is SYNCHRONOUS and called from `build`. That is
//  not an accident to be fixed — a widget cannot await, and threading a Future
//  through the booking sheet would turn a list into a loading state on every
//  rebuild. So this follows the pattern the rest of the app already uses for
//  server-owned data (see DoctorScheduleStore): pull into memory, read from
//  memory, refresh at the moments that matter.
//
//  `booking_slots` is readable by any signed-in user on purpose — 0029's policy
//  is `using (true)`, with the note that "a seat count is not private" — so
//  this needs no special grant and no definer function.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../services/remote/supabase_repo.dart';

@immutable
class ServerSlot {
  const ServerSlot({required this.booked, required this.startsUtc});
  final int booked;
  final DateTime? startsUtc;
}

class ServerSlotStore extends ChangeNotifier {
  ServerSlotStore._();
  static final ServerSlotStore instance = ServerSlotStore._();

  final Map<String, ServerSlot> _slots = {};

  bool _loaded = false;
  bool get isLoaded => _loaded;

  DateTime? _lastPull;

  /// Everything the ledger knows about [slotId], or null if it has never heard
  /// of it.
  ///
  /// Null is a real and common answer, not a failure: `booking_slots`
  /// self-seeds, so a class nobody has booked has no row at all.
  ServerSlot? forSlot(String slotId) => _slots[slotId];

  /// True once this slot exists server-side — i.e. somebody has booked it, or a
  /// host has opened its room. The point at which its date stops being a guess.
  bool isReal(String slotId) => _slots.containsKey(slotId);

  /// Seats taken, or 0 when the server has no row — which is the truth, not a
  /// fallback: no row means no bookings.
  int booked(String slotId) => _slots[slotId]?.booked ?? 0;

  /// The date this slot actually has, or null while it is still a placeholder.
  DateTime? startsUtc(String slotId) => _slots[slotId]?.startsUtc;

  /// Pull every slot the ledger holds. Cheap: one row per slot that has ever
  /// been booked, and the table holds nothing personal.
  ///
  /// Throttled, because this is called from screen entry points a user can
  /// bounce in and out of. [force] is for a deliberate pull-to-refresh.
  Future<void> refresh({bool force = false}) async {
    if (!SupabaseRepo.isLoggedIn) return;
    final now = DateTime.now();
    if (!force &&
        _lastPull != null &&
        now.difference(_lastPull!) < const Duration(seconds: 45)) {
      return;
    }
    _lastPull = now;
    try {
      final rows = await SupabaseRepo.selectAll('booking_slots');
      for (final r in rows) {
        final id = (r['id'] ?? '').toString();
        if (id.isEmpty) continue;
        _slots[id] = ServerSlot(
          booked: (r['booked'] as num?)?.toInt() ?? 0,
          startsUtc: DateTime.tryParse((r['starts_utc'] ?? '').toString())
              ?.toUtc(),
        );
      }
      _loaded = true;
      notifyListeners();
    } catch (_) {
      // Offline. Whatever was cached still stands, and an uncached slot reads
      // as zero seats taken — which understates rather than overstates, and is
      // the safe direction: it can only ever offer a seat that turns out to be
      // gone, which book_slot refuses atomically anyway.
    }
  }

  @visibleForTesting
  void seed(Map<String, ServerSlot> slots) {
    _slots
      ..clear()
      ..addAll(slots);
    _loaded = true;
  }

  @visibleForTesting
  void resetAll() {
    _slots.clear();
    _loaded = false;
    _lastPull = null;
  }
}
