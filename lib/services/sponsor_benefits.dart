// =============================================================================
//  SponsorBenefits — turning a capability into the thing it promises.
// -----------------------------------------------------------------------------
//  An entitlement says "this user may have a sponsored consultation". A
//  consultation is booked against a CREDIT. Something has to bridge the two,
//  and this is deliberately the whole of it.
//
//  IT REUSES THE REFERRAL CREDIT. BookingStore.grantFloatingCredit() already
//  mints "a free consultation, with whoever you like" — built for referral
//  rewards, minted against kAnyConsultOffering. An enterprise credit is the
//  same fact with a different payer, so it uses the same counter.
//
//  Inventing a second one is the tempting alternative and it is a trap: two
//  counters disagree the first time someone holds both, and then the question
//  "how many free consultations does she have left" has two answers and no
//  authority. Same rule that made programmes mirror into booking_slots rather
//  than count seats separately.
//
//  IDEMPOTENCE IS THE WHOLE DESIGN. The credit id is derived from the sponsor
//  id, so this can run on every notification from EntitlementStore — every app
//  launch, every refresh, every reconnect — and still grant exactly one. That
//  is what lets it be attached to a listener instead of carefully called once.
//
//  ⚠️ KNOWN GAP, stated rather than hidden. This grants the credit CLIENT-SIDE,
//  exactly as the referral reward does, and book_slot() does not yet check an
//  entitlement server-side. So the credit is currently a local fact. It is
//  recorded in STILL-OPEN §11.7; the fix is a check inside book_slot(), not a
//  better client. Nothing here should be read as a boundary.
// =============================================================================

import '../booking/booking_store.dart';
import 'entitlement_store.dart';

class SponsorBenefits {
  const SponsorBenefits._();

  /// How many consultations a sponsored parent gets. One, for now, and it
  /// lives here rather than in the database because it is the same for every
  /// sponsor today — the day a plan disagrees, it becomes a column on `plans`
  /// and this constant goes. Registering the variation before there is any is
  /// the config-object mistake CLAUDE.md warns about.
  static const int consultationsPerActivation = 1;

  /// Keep the booking side in step with what the server says this user holds.
  ///
  /// Safe to call any number of times.
  static void sync() {
    final ent = EntitlementStore.instance;
    final sponsor = ent.sponsor;
    if (sponsor == null) return;
    if (!ent.can(Caps.consultationCredit)) return;

    BookingStore.instance.grantFloatingCredit(
      // Derived from the sponsor, so re-activating, re-installing or simply
      // launching the app again all resolve to the one credit.
      sourceId: 'sponsor_${sponsor.id}',
      title: 'Consultation, provided by ${sponsor.name}',
      credits: consultationsPerActivation,
      // A year rather than the referral reward's 90 days: this one is tied to
      // an annual contract, and expiring it mid-term would take away something
      // the employer has already paid for.
      validFor: const Duration(days: 365),
    );
  }

  static bool _attached = false;

  /// Run [sync] whenever entitlements change. Called once from main().
  ///
  /// A listener rather than a single call at startup because the entitlement
  /// fetch is asynchronous — calling once during boot would usually run before
  /// the answer arrived, and the credit would appear a launch late.
  static void attach() {
    if (_attached) return;
    _attached = true;
    EntitlementStore.instance.addListener(sync);
    sync();
  }
}
