// =============================================================================
//  ConsultPolicy — what happens when a consultation does not happen
// -----------------------------------------------------------------------------
//  Every telemedicine platform has to answer three questions. These are the
//  answers ParentVeda uses, chosen to match how Practo, Apollo and the rest of
//  the category behave, because parents and doctors arrive with those
//  expectations already formed:
//
//  1. THE DOCTOR CANCELS -> the parent is made whole, immediately and in full.
//     They did nothing wrong, and this is the one failure that is entirely
//     ours. No window, no fee, no discretion.
//
//  2. THE PARENT DOES NOT TURN UP -> the doctor is paid in full, after a
//     10-minute grace period. The doctor blocked the time, turned up, and
//     cannot re-sell that half hour. The grace period matters: joining five
//     minutes late is ordinary life, not a no-show.
//
//  3. THE PARENT CANCELS LATE -> free up to 2 HOURS before; inside that, the
//     credit is not returned, but they get ONE free reschedule. Two hours is
//     roughly the point past which a doctor cannot fill the slot. Taking the
//     money AND the appointment would be punitive, so the reschedule is the
//     release valve.
//
//  HOW A "REFUND" WORKS HERE. The booking engine is credit-based: a parent buys
//  an entitlement and spends credits on slots. So a refund RETURNS THE CREDIT
//  rather than moving money. That is honest under the current test-mode
//  Razorpay setup - nothing pretends a rupee has moved - and it is what a
//  parent actually wants: the ability to rebook. Cash-out refunds attach here
//  when live payments land.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../booking/booking_models.dart';

/// Free-cancellation window for the PARENT, before the consultation starts.
const Duration kFreeCancelWindow = Duration(hours: 2);

/// How late a parent may join before the doctor may mark them a no-show.
const Duration kNoShowGrace = Duration(minutes: 10);

enum ConsultOutcome {
  /// Cancelled by the doctor. Credit returned, always.
  doctorCancelled,

  /// Cancelled by the parent outside the free window. Credit returned.
  parentCancelledEarly,

  /// Cancelled by the parent inside the window. Credit kept, one free
  /// reschedule offered.
  parentCancelledLate,

  /// Parent never joined. Doctor is paid; the credit is spent.
  parentNoShow,
}

@immutable
class ConsultResolution {
  const ConsultResolution({
    required this.outcome,
    required this.creditReturned,
    required this.doctorPaid,
    required this.freeReschedule,
    required this.parentMessage,
  });

  final ConsultOutcome outcome;

  /// The parent gets their consultation credit back to spend again.
  final bool creditReturned;

  /// The doctor still earns for this slot.
  final bool doctorPaid;

  /// The parent may rebook once at no cost, even though no credit came back.
  final bool freeReschedule;

  /// Said to the parent, in plain words. Never blames them.
  final String parentMessage;
}

class ConsultPolicy {
  ConsultPolicy._();

  /// True while a parent may still cancel without losing the credit.
  static bool parentMayCancelFree(Booking b, {DateTime? now}) =>
      b.startsUtc.difference((now ?? DateTime.now()).toUtc()) >
          kFreeCancelWindow;

  /// True once the doctor may fairly record a no-show.
  static bool mayMarkNoShow(Booking b, {DateTime? now}) =>
      (now ?? DateTime.now()).toUtc().isAfter(b.startsUtc.add(kNoShowGrace));

  /// Whether this consultation can still be CANCELLED.
  ///
  /// Only before its slot has finished. Cancelling is a statement about
  /// something that has not happened yet — "I cannot make it" — and once the
  /// slot has passed the question is no longer whether it will happen but what
  /// happened: it was completed, or the parent did not attend. Those are
  /// different outcomes with different money attached, and no-show is the one
  /// that records the second.
  ///
  /// The Past tab was offering "Cancel this consultation · use this if you
  /// cannot make it" on a consultation that finished days ago, which reads as
  /// an app that has not noticed time passing — and would have refunded a
  /// parent for a call the doctor actually took.
  static bool mayCancel(Booking b, {DateTime? now}) =>
      (now ?? DateTime.now()).toUtc().isBefore(b.endsUtc);

  /// The doctor cancelling. Unconditional, at any notice.
  static ConsultResolution doctorCancels(Booking b) => const ConsultResolution(
        outcome: ConsultOutcome.doctorCancelled,
        creditReturned: true,
        doctorPaid: false,
        freeReschedule: true,
        parentMessage:
            'Your doctor had to cancel. Your consultation credit is back in '
            'your account and you can book any other time that suits you.',
      );

  /// The parent cancelling — which side of the window they are on decides it.
  static ConsultResolution parentCancels(Booking b, {DateTime? now}) {
    if (parentMayCancelFree(b, now: now)) {
      return const ConsultResolution(
        outcome: ConsultOutcome.parentCancelledEarly,
        creditReturned: true,
        doctorPaid: false,
        freeReschedule: true,
        parentMessage:
            'Cancelled. Your credit is back in your account - book again '
            'whenever you are ready.',
      );
    }
    return const ConsultResolution(
      outcome: ConsultOutcome.parentCancelledLate,
      creditReturned: false,
      doctorPaid: true,
      freeReschedule: true,
      parentMessage:
          'Cancelled. This was inside the 2-hour window, so the credit stays '
          'with this consultation - but you can reschedule it once, free.',
    );
  }

  /// The parent never arrived.
  static ConsultResolution parentNoShow(Booking b) => const ConsultResolution(
        outcome: ConsultOutcome.parentNoShow,
        creditReturned: false,
        doctorPaid: true,
        freeReschedule: false,
        parentMessage:
            'You missed this consultation. Book again whenever you are ready.',
      );
}
