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
//  L2c (2026-10-29): THE PHONE NO LONGER SAYS WHAT IT COSTS, OR WHAT IT BOUGHT.
//  [checkout] sends only the offering id; the server prices it (0126
//  `price_offering`) and verify writes the receipt. The caller then reads the
//  receipt back (`BookingStore.acquire`) instead of minting one. And a server
//  REFUSAL keeps its reason: before, "already owned", "no price" and "not
//  deployed" all came back as null, and null meant "fall back to the free
//  preview" - so a refusal could quietly turn into a grant. Now only a backend
//  that is genuinely absent reads as [PaymentOutcome.notConfigured].
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

enum PaymentOutcome {
  paid,
  free,
  cancelled,
  failed,
  notConfigured,

  /// The server says she already holds an active receipt for this (0126
  /// `open_payment_order`). Not a failure: nothing to charge.
  alreadyOwned,

  /// The server has no price for this offering (LA-30): it cannot be sold.
  unpriced,

  /// Buying needs an account: the receipt is written against it.
  signedOut,
}

class PaymentResult {
  const PaymentResult(this.outcome, [this.message]);
  final PaymentOutcome outcome;

  /// On [PaymentOutcome.paid], the Razorpay payment id; otherwise a reason.
  final String? message;

  String get paymentId => outcome == PaymentOutcome.paid ? (message ?? '') : '';

  /// True when the purchase should be granted — a real paid payment, or a free
  /// offering. [notConfigured] is handled separately (preview mint).
  bool get granted =>
      outcome == PaymentOutcome.paid || outcome == PaymentOutcome.free;
}

class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  /// Run checkout for a booking [offering]. Awaits order → pay → verify.
  ///
  /// Only the id goes to the server (L2c). [Offering.priceMinor] is used for
  /// two things on the phone and nothing else: skipping checkout for a free
  /// thing (the server checks that too, in `claim_free_offering`) and the
  /// label. The amount the sheet opens with is the one the server returns.
  Future<PaymentResult> checkout(Offering offering, {String? email}) {
    if (!SupabaseRepo.isLoggedIn) {
      return Future.value(const PaymentResult(PaymentOutcome.signedOut));
    }
    return pay(
      amountMinor: offering.priceMinor,
      title: offering.title,
      reference: offering.id,
      email: email,
      sendAmount: false,
    );
  }

  /// The general three-step flow, shared by bookings and the product store.
  ///
  /// [reference] is what the server writes into the Razorpay order's notes
  /// (an offering id, or a product order id). [lines] is the product-store
  /// case: the edge function re-prices them from the `products` table so
  /// the amount charged is the server's, not the phone's — "money is decided
  /// server-side, always". When it cannot price a line it falls back to
  /// [amountMinor] and marks the order `priced_by: client`, which is
  /// auditable rather than silent.
  Future<PaymentResult> pay({
    required int amountMinor,
    required String title,
    required String reference,
    String? email,
    String? contact,
    List<Map<String, Object>> lines = const [],
    // The shop still sends its total: create-order prices the lines from
    // `products` and reads the phone's figure only in stub mode, for a line
    // it cannot price (0126 open_payment_order). An offering sends nothing.
    bool sendAmount = true,
  }) async {
    // Free — nothing to charge.
    if (amountMinor <= 0) {
      return const PaymentResult(PaymentOutcome.free);
    }

    // 1) Create the order server-side. Null means the payment backend is not
    //    reachable — fall back to preview rather than block the purchase.
    final res = await SupabaseRepo.invokeEdgeResult('razorpay-create-order', {
      if (sendAmount) 'amountMinor': amountMinor,
      'offeringId': reference,
      if (lines.isNotEmpty) 'lines': lines,
    });
    final order = res.data;
    final orderId = order?['orderId'] as String?;
    if (orderId == null) return _refusal(res);
    // The server's amount wins when it re-priced the lines.
    final chargeMinor = (order?['amount'] as num?)?.toInt() ?? amountMinor;

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
            ? PaymentResult(PaymentOutcome.paid, r.paymentId)
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
        'amount': chargeMinor,
        'currency': 'INR',
        'name': 'ParentVeda',
        'description': title,
        'theme': {'color': '#201C24'},
        if (email != null || contact != null)
          'prefill': {
            'email': ?email,
            'contact': ?contact,
          },
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

  /// What a create-order refusal means. The reasons are 0126's
  /// `open_payment_order` words, passed through by the function.
  ///
  /// Only an ABSENT backend is [PaymentOutcome.notConfigured] - unreachable,
  /// not deployed, keys or server env missing. That is the one case the
  /// no-charge preview exists for, and the preview itself is now the server's
  /// to allow (`record_stub_purchase`, stub mode only).
  static PaymentResult _refusal(EdgeResult res) {
    final reason = res.reason ?? '';
    switch (reason) {
      case 'free':
        return const PaymentResult(PaymentOutcome.free);
      case 'already_owned':
        return const PaymentResult(PaymentOutcome.alreadyOwned);
      case 'unknown_offering':
        return const PaymentResult(PaymentOutcome.unpriced);
      case 'not_signed_in':
      case 'not signed in':
        return const PaymentResult(PaymentOutcome.signedOut);
      case 'keys not set':
      case 'server not set':
      // The shop's refusal: a line the server cannot price. Before L2c every
      // refusal read as "not configured" and the shop placed a preview order;
      // the shop keeps that (it is outside this pass).
      case 'unpriced_lines':
        return const PaymentResult(PaymentOutcome.notConfigured);
    }
    if (res.offline || res.status == 404 || res.status >= 500) {
      return const PaymentResult(PaymentOutcome.notConfigured);
    }
    return PaymentResult(PaymentOutcome.failed,
        reason.isEmpty ? 'Payment could not be started.' : reason);
  }
}
