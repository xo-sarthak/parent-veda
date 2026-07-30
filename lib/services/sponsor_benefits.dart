// =============================================================================
//  SponsorBenefits — keeping the phone's copy honest about what the server says.
// -----------------------------------------------------------------------------
//  THIS FILE USED TO MINT CREDITS. It called
//  BookingStore.grantFloatingCredit() when a sponsor appeared, which meant the
//  phone decided how many consultations somebody had and the server never
//  checked. Migration 0066 moved the ledger server-side, so the direction of
//  travel has reversed:
//
//      before   the phone granted, and the server trusted it
//      after    the server grants, and the phone mirrors it
//
//  It still writes into BookingStore, and that is deliberate rather than
//  leftover. The booking UI reads entitlements from there to decide whether to
//  show "Book with your credit" or "Pay" — rewiring every one of those call
//  sites to a second source would be a large change for no gain, and would
//  leave two places answering "can she book this".
//
//  So BookingStore stays the one thing screens ask, and this keeps its answer
//  equal to the server's. The important part is what that local row now IS: a
//  rendering hint. book_slot() claims a real row from consult_credits or
//  records the booking as unpaid, so a phone that says 99 gains nothing.
//
//  > When you move an authority, do not also move every reader. Keep the
//  > interface screens already use and make it a mirror — otherwise a security
//  > fix becomes a refactor, and refactors are where the bugs are.
// =============================================================================

import '../booking/booking_store.dart';
import 'credits_store.dart';
import 'entitlement_store.dart';

class SponsorBenefits {
  const SponsorBenefits._();

  /// What a sponsored activation is worth, and the number HR is told.
  ///
  /// Duplicated from `0067`, which is the authority — this exists so a screen
  /// can say "1 of 2 left" without a round trip. If they disagree, the server
  /// is right; the test in `sponsor_enterprise_test.dart` pins them together.
  static const int consultationsPerActivation = 2;

  /// Make the local entitlement equal the server's count.
  ///
  /// Safe to call any number of times: the credit id is derived from the
  /// sponsor, so this is an upsert rather than a grant.
  static void sync() {
    final ent = EntitlementStore.instance;
    final sponsor = ent.sponsor;
    if (sponsor == null) return;
    if (!ent.can(Caps.consultationCredit)) return;

    // THE SERVER'S NUMBER, not a constant. If a credit was spent, voided or
    // expired, the phone must stop advertising it — the old version granted a
    // fixed 1 forever and would have shown a credit that no longer existed,
    // which is the worst of both: a button that fails at the last step.
    final available = CreditsStore.instance.available;

    // MIRROR, not grant. grantFloatingCredit() is grant-once by design — it
    // returns the existing row untouched, so it can only ever count upward and
    // a spent credit would stay on screen forever. mirrorFloatingCredit() sets
    // the number, and removes the row at zero.
    BookingStore.instance.mirrorFloatingCredit(
      sourceId: 'sponsor_${sponsor.id}',
      title: 'Consultation, provided by ${sponsor.name}',
      credits: available,
      // A year, matching booking_policy.default_validity_days. Tied to an
      // annual contract; expiring it mid-term would take away something the
      // employer has already paid for.
      validFor: const Duration(days: 365),
    );
  }

  static bool _attached = false;

  /// Mirror whenever either side changes. Called once from main().
  ///
  /// Listens to BOTH stores: the entitlement tells us there is a sponsor at
  /// all, and the credit count tells us how many. Either arriving first is
  /// fine, because sync() is idempotent and reads both.
  static void attach() {
    if (_attached) return;
    _attached = true;
    EntitlementStore.instance.addListener(sync);
    CreditsStore.instance.addListener(sync);
    sync();
  }
}
