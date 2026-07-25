// =============================================================================
//  DoctorEarnings — what a doctor has made, computed from their bookings
// -----------------------------------------------------------------------------
//  Every booking against this doctor is money: the parent paid the offering
//  price, the platform keeps a cut, the doctor takes the rest. This computes
//  that split from the roster — real numbers from real bookings — for the
//  earnings dashboard. Actually MOVING the money to the doctor is Razorpay
//  Route (a linked account + a transfer at checkout); that's the payout setup,
//  separate from this reporting.
// =============================================================================

import '../booking/booking_catalog.dart';
import '../booking/booking_models.dart';
import 'doctor_roster.dart';

/// The doctor's share of each booking. The platform keeps the remainder. A
/// single knob — a real deal per doctor would override it.
const double kDoctorSharePct = 0.80;

class ConsultEarning {
  const ConsultEarning({required this.booking, required this.grossMinor});
  final Booking booking;
  final int grossMinor;

  int get doctorMinor => (grossMinor * kDoctorSharePct).round();
  int get platformMinor => grossMinor - doctorMinor;
  bool get isPast => !booking.isUpcoming ||
      booking.endsUtc.isBefore(DateTime.now().toUtc());
}

class EarningsSummary {
  const EarningsSummary({
    required this.items,
    required this.earnedMinor,
    required this.thisMonthMinor,
    required this.upcomingMinor,
    required this.grossMinor,
  });

  final List<ConsultEarning> items; // newest first
  final int earnedMinor; // doctor's share from completed sessions
  final int thisMonthMinor; // earned in the current calendar month
  final int upcomingMinor; // doctor's share still to come
  final int grossMinor; // total the parents paid (for the platform-fee line)

  /// Nothing paid out yet in this build — Route payouts are the next step.
  int get pendingMinor => earnedMinor;
}

class DoctorEarnings {
  DoctorEarnings._();

  static EarningsSummary summary(String expertId) {
    final roster = DoctorRoster.instance;
    final all = [
      ...roster.upcomingConsults(expertId),
      ...roster.pastConsults(expertId),
    ];
    final cat = BookingCatalog.instance;
    final items = all
        .map((b) => ConsultEarning(
              booking: b,
              grossMinor: cat.offeringById(b.offeringId)?.priceMinor ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.booking.startsUtc.compareTo(a.booking.startsUtc));

    final now = DateTime.now();
    var earned = 0, month = 0, upcoming = 0, gross = 0;
    for (final e in items) {
      gross += e.grossMinor;
      if (e.isPast) {
        earned += e.doctorMinor;
        final d = e.booking.startsUtc.toLocal();
        if (d.year == now.year && d.month == now.month) month += e.doctorMinor;
      } else {
        upcoming += e.doctorMinor;
      }
    }
    return EarningsSummary(
      items: items,
      earnedMinor: earned,
      thisMonthMinor: month,
      upcomingMinor: upcoming,
      grossMinor: gross,
    );
  }
}
