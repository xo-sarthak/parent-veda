// =============================================================================
//  CareJourney — the milestones a Care Partner is allowed to see the COUNT of
// -----------------------------------------------------------------------------
//  partner_impact() (0037) counts rows in parent_timeline by event name. This
//  file is the only place those event names are written, for two reasons:
//
//  1. A typo is invisible. 'vaccination_complete' instead of
//     'vaccination_completed' does not throw, does not fail a test, and simply
//     makes a doctor's dashboard read zero forever. Named methods make the
//     compiler responsible for the strings.
//
//  2. It fixes what is countable. A future contributor cannot quietly start
//     logging 'opened_app_at_2am' from a screen; adding a countable milestone
//     means adding a method here, which means someone looks at whether a
//     partner should be able to count it.
//
//  WHAT IS NOT HERE, deliberately: anything about the child's health, weight,
//  feeding, mood, or any content title. 'content_read' carries no detail. The
//  partner learns that a family read guides, not which guides — a paediatrician
//  who could see that a mother has been reading about postnatal depression
//  knows something she did not tell them.
//
//  Every call is a no-op when the family has no partner and when signed out, so
//  callers never guard.
// =============================================================================

import 'care_partner_store.dart';

class CareJourney {
  CareJourney._();

  /// Names the SQL in 0037 counts. Changing one silently zeroes a dashboard —
  /// they are contract, not labels.
  static const String pregnancyAdded = 'pregnancy_added';
  static const String childAdded = 'child_added';
  static const String consultationCompleted = 'consultation_completed';
  static const String vaccinationCompleted = 'vaccination_completed';
  static const String contentRead = 'content_read';
  static const String purchaseMade = 'purchase_made';
  static const String consultationBooked = 'consultation_booked';

  static void _log(String event) {
    final store = CarePartnerStore.instance;
    // No partner, nothing to attribute. The row would be orphaned and would
    // still cost a write.
    if (store.partner == null) return;
    store.recordEvent(event);
  }

  /// She told us her due date — a pregnancy is now being supported.
  static void pregnancyStarted() => _log(pregnancyAdded);

  /// A child was added to the family profile.
  static void childBorn() => _log(childAdded);

  /// A consultation actually happened (not merely booked — a booking that
  /// nobody attended is not an outcome anyone should be credited for).
  static void consultationDone() => _log(consultationCompleted);

  /// A dose was marked given. No vaccine name: the count is the point.
  static void vaccinationDone() => _log(vaccinationCompleted);

  /// A guide was read to the end. No title, ever.
  static void guideRead() => _log(contentRead);

  /// Something was bought. No offering, no amount — the ledger carries the
  /// money, and this only records that the journey reached that step.
  static void purchased() => _log(purchaseMade);

  /// A session was booked. Distinct from consultationDone(): a booking nobody
  /// attended is not an outcome, and a doctor's dashboard should not count it
  /// as one.
  static void consultationBookedNow() => _log(consultationBooked);
}
