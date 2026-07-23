// =============================================================================
//  PaymentService — Razorpay checkout for a paid booking
// -----------------------------------------------------------------------------
//  The full, correct three-step flow, never a "trust the client" shortcut:
//
//    1. create the ORDER server-side (Supabase edge function razorpay-create-
//       order), because only the server holds the Key Secret;
//    2. open the Razorpay checkout sheet with that order id;
//    3. VERIFY the returned signature server-side (razorpay-verify-payment)
//       before the app trusts a payment as real.
//
//  Only after step 3 does the caller mint the entitlement. A signature that
//  cannot be verified is treated as a failed payment, full stop.
//
//  GRACEFUL DEGRADATION. A free offering skips payment entirely. And if the
//  edge functions are not reachable — not deployed yet, logged out, offline —
//  checkout returns [PaymentOutcome.notConfigured] so the app can fall back to
//  the existing no-charge preview rather than trapping the user behind a
//  half-built payment stack. Real charging switches on the moment the functions
//  are deployed and the secret is set; nothing else changes.
// =============================================================================

import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../services/remote/supabase_repo.dart';
import 'booking_models.dart';
import 'payment_config.dart';

enum PaymentOutcome { paid, free, cancelled, failed, notConfigured }

class PaymentResult {
  const PaymentResult(this.outcome, [this.message]);
  final PaymentOutcome outcome;
  final String? message;

  /// True when the purchase should be granted — a real paid payment, or a free
  /// offering. [notConfigured] is handled separately (preview mint).
  bool get granted =>
      outcome == PaymentOutcome.paid || outcome == PaymentOutcome.free;
}

class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  /// Run checkout for [offering]. Awaits the full order → pay → verify flow.
  Future<PaymentResult> checkout(Offering offering, {String? email}) async {
    // Free ("Free on ParentVeda+", ₹0) — nothing to charge.
    if (offering.priceMinor <= 0) {
      return const PaymentResult(PaymentOutcome.free);
    }

    // 1) Create the order server-side. Null means the payment backend is not
    //    reachable — fall back to preview rather than block the booking.
    final order = await SupabaseRepo.invokeEdge('razorpay-create-order', {
      'amountMinor': offering.priceMinor,
      'offeringId': offering.id,
    });
    final orderId = order?['orderId'] as String?;
    if (orderId == null) {
      return const PaymentResult(PaymentOutcome.notConfigured);
    }

    // 2) Open checkout and await the native callback.
    final completer = Completer<PaymentResult>();
    final rzp = Razorpay();

    rzp.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) async {
      // 3) Verify the signature server-side before trusting the payment.
      final v = await SupabaseRepo.invokeEdge('razorpay-verify-payment', {
        'orderId': r.orderId,
        'paymentId': r.paymentId,
        'signature': r.signature,
      });
      if (!completer.isCompleted) {
        completer.complete(v?['valid'] == true
            ? const PaymentResult(PaymentOutcome.paid)
            : const PaymentResult(
                PaymentOutcome.failed, 'Payment could not be verified.'));
      }
    });

    rzp.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      if (!completer.isCompleted) {
        final cancelled = r.code == Razorpay.PAYMENT_CANCELLED;
        completer.complete(PaymentResult(
            cancelled ? PaymentOutcome.cancelled : PaymentOutcome.failed,
            r.message));
      }
    });

    rzp.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse r) {
      // The user chose an external wallet (e.g. an offline UPI app). We cannot
      // confirm it here; treat as not completed so nothing is granted.
      if (!completer.isCompleted) {
        completer.complete(const PaymentResult(
            PaymentOutcome.failed, 'Complete the payment and try again.'));
      }
    });

    try {
      rzp.open({
        'key': PaymentConfig.razorpayKeyId,
        'order_id': orderId,
        'amount': offering.priceMinor,
        'currency': 'INR',
        'name': 'ParentVeda',
        'description': offering.title,
        'theme': {'color': '#6A30B6'},
        if (email != null) 'prefill': {'email': email},
      });
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(PaymentResult(PaymentOutcome.failed, e.toString()));
      }
    }

    final result = await completer.future;
    rzp.clear();
    return result;
  }
}
