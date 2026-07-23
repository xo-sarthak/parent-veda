// =============================================================================
//  PaymentConfig — Razorpay client configuration
// -----------------------------------------------------------------------------
//  The Key ID is the PUBLISHABLE half of a Razorpay key pair — safe to ship in
//  the app (it only identifies the merchant to open checkout). The Key SECRET
//  is NOT here and must never be: it lives only in the Supabase payment edge
//  function's environment, where it signs and verifies orders server-side. A
//  secret in the client is a secret leaked.
//
//  [live] is false while we are on test keys (rzp_test_…). Flip it, and swap in
//  the live Key ID, once Razorpay KYC is activated.
// =============================================================================

class PaymentConfig {
  PaymentConfig._();

  /// Razorpay TEST publishable key. Real payments are off until KYC is live.
  static const String razorpayKeyId = 'rzp_test_TGxRqeBTGuJAzQ';

  /// True once we move to a live (rzp_live_…) key after KYC.
  static const bool live = false;
}
