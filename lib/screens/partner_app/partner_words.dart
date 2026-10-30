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

// ---- P2: the sponsor tabs' recurring sentences -------------------------------

/// Every seat is taken: what that stops, and the next step.
String partnerSeatsFullText(PartnerOrg org, int seats) =>
    'All $seats seats are taken. New ${org.peopleWord} cannot activate until '
    'seats are added. Contact your ParentVeda manager.';

/// A behavioural figure held back. [min] is the server's min_cohort.
String partnerWithheldText(int min) => 'Shown once $min have activated';

/// What the organisation will never see, said where it looks at its numbers.
String partnerPrivacyText(PartnerOrg org) =>
    'You see totals, never a person: not who booked, read or asked anything, '
    'and no breakdown by section, because in a small group that narrows down '
    'who is worried about what. Every total is held back below a minimum '
    'group size. Your ${org.peopleWord} were promised this when they '
    'activated.';

// ---- P3: an IVF centre's tabs -------------------------------------------------

/// A centre's behavioural figure held back. [min] is the server's min_cohort.
String partnerCareWithheldText(int min) => 'Shown once $min families join';

/// How a centre adds a doctor: we do it (STILL-OPEN §5.1c).
const kPartnerAddDoctorText =
    'To add a doctor, contact your ParentVeda manager.';

/// What a centre will never see, said where it looks at its numbers.
String partnerCarePrivacyText(int min) =>
    'You see totals, never a family: no names, no contact details, nothing '
    'any one family did. What families did is held back until $min have '
    'joined, because in a small group a single pregnancy is close to a name. '
    'The families you brought were promised this when they joined.';
