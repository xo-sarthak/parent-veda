// =============================================================================
//  The Partners app's refusals and holds, in one place
// -----------------------------------------------------------------------------
//  Every "you cannot come in" says WHY and WHAT NEXT (PARTNERS-APP.md P1, item
//  4). They live here, not inline in the screens, because two screens say them
//  (the sign-in form after a refusal, and the boot after a restored session no
//  longer resolves) and the test reads them from one source.
//
//  The codes are the server's (my_partner_org, 0136). An unknown code reads as
//  "not set up", which is always true when the server said no.
// =============================================================================

import '../../partner_app/partner_org_session.dart';

/// Why a signed-in login was turned away, and where to go instead.
String partnerRefusalText(String? code) => switch (code) {
  'doctor' =>
    "You're a doctor on ParentVeda. Use the ParentVeda+ app to "
        'see your families and bookings.',
  'parent' =>
    'This is a parent account. Use the ParentVeda app for your '
        'own journey.',
  _ =>
    "This email isn't set up for ParentVeda Partners. "
        'Ask your ParentVeda contact to add it.',
};

/// The line for an organisation that exists but is not live.
String partnerHoldText(PartnerOrg org) {
  final who = org.name.isEmpty ? 'Your programme' : org.name;
  return switch (org.status) {
    'pending' =>
      "$who isn't live yet. Your ParentVeda manager will tell you "
          'when it starts.',
    'ended' => '$who has ended. To renew it, contact your ParentVeda manager.',
    // suspended (sponsor) and inactive (care_org): paused, not over.
    _ => '$who is paused. Contact your ParentVeda manager.',
  };
}

/// Where an admin reaches ParentVeda. One address, also used by the Account tab.
const kPartnersSupportEmail = 'partners@parentveda.com';
