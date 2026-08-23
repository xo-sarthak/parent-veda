// =============================================================================
//  PrescriptionWatch — telling her a prescription has arrived
// -----------------------------------------------------------------------------
//  THE DEFECT. A doctor writes a prescription; it lands in `prescriptions` and
//  is correctly readable by the parent. And then nothing happens. The only
//  place it surfaced was a "View prescription" link inside My Bookings, on the
//  PAST list — so it was invisible until the booking aged out of Upcoming, and
//  invisible forever to a parent who never went looking. Nothing in
//  NotificationService mentioned prescriptions at all.
//
//  A prescription is time-sensitive by definition. "She will find it eventually"
//  is not a delivery mechanism.
//
// -----------------------------------------------------------------------------
//  WHY A POLL AND NOT A PUSH
// -----------------------------------------------------------------------------
//  Real push would need Firebase, which STILL-OPEN 5.3 records as not yet
//  wired, and a device token per parent. Neither is a small job, and neither is
//  needed to close this gap: the prescription is written minutes to hours after
//  a call, and the app is opened daily. Checking on resume is enough to turn
//  "never told" into "told the next time she picks up her phone", which is the
//  whole distance that matters.
//
//  So this deliberately does the cheap version WELL rather than the expensive
//  version badly, and leaves a clean seam: when push arrives, it calls
//  `_announce` and this file's polling half goes away.
//
//  THROTTLED, because `didChangeAppLifecycleState` fires on every alt-tab and a
//  network round trip per glance is a bad trade for a change that happens a
//  handful of times a month.
// =============================================================================

import '../services/notification_service.dart';
import '../services/remote/supabase_repo.dart';
import 'booking_store.dart';
import 'prescription.dart';

class PrescriptionWatch {
  PrescriptionWatch._();
  static final PrescriptionWatch instance = PrescriptionWatch._();

  static const _minGap = Duration(minutes: 5);
  DateTime? _lastCheck;
  bool _running = false;

  /// Notification ids for prescription arrivals.
  ///
  /// Its own band, well clear of the booking reminders at 700000 and the
  /// vaccine/medication bands, so a prescription never silently replaces a
  /// reminder about the appointment that produced it.
  static int _noticeId(String bookingId) => 760000 + (bookingId.hashCode & 0x3ffff);

  /// Check for prescriptions the parent has not been told about, and tell her.
  ///
  /// Safe to call on every app resume; safe to call when logged out; never
  /// throws. [force] skips the throttle for a deliberate check (pull to
  /// refresh, or straight after a consultation ends).
  Future<void> check({bool force = false}) async {
    if (_running) return;
    if (!SupabaseRepo.isLoggedIn) return;
    final now = DateTime.now();
    if (!force && _lastCheck != null && now.difference(_lastCheck!) < _minGap) {
      return;
    }
    _running = true;
    _lastCheck = now;
    try {
      await PrescriptionStore.instance.refresh();
      // takeNewlyArrived MARKS them told, so everything it hands back must
      // actually be announced below — dropping one here loses it for good.
      final arrived = await PrescriptionStore.instance.takeNewlyArrived();
      for (final bookingId in arrived) {
        await _announce(bookingId);
      }
    } catch (_) {
      // A failed check is a check that did not happen. Never a crash, and never
      // a reason to lose the session.
    } finally {
      _running = false;
    }
  }

  Future<void> _announce(String bookingId) async {
    final rx = PrescriptionStore.instance.forBooking(bookingId);
    if (rx == null) return;

    // Name the consultation if we can. "Your prescription is ready" is true but
    // anonymous; a parent with two doctors wants to know which one.
    final booking = BookingStore.instance.byId(bookingId);
    final what = booking?.title.trim();

    final n = rx.items.where((i) => !i.isEmpty).length;
    final detail = n == 0
        ? 'Advice from your consultation is ready to read.'
        : n == 1
            ? '1 medicine and instructions are ready to read.'
            : '$n medicines and instructions are ready to read.';

    await NotificationService.instance.showNow(
      id: _noticeId(bookingId),
      title: (what == null || what.isEmpty)
          ? 'Your prescription is ready'
          : 'Prescription from $what',
      body: detail,
    );
  }
}
