// =============================================================================
//  forgetPartnerOrgOnThisPhone — everything a signed-in organisation leaves
// -----------------------------------------------------------------------------
//  The Partners app's version of forgetDoctorOnThisPhone (Partner Editions D1):
//  every store it fills is a singleton, a singleton outlives the account that
//  filled it, and a desk phone at a company or a clinic is exactly the phone
//  two different admins will share.
//
//  ONE function, called by every sign-out path (the Account tab, and the
//  refusal and paused screens in main_partner.dart), so a store P2-P4 add is
//  added here once. test/partner_app_shell_test.dart reads this file and fails
//  if a store is missing from it.
//
//  It signs out of Supabase too, unlike the doctor version: in this app there
//  is no "leave the mode but stay signed in". The sign-out is first and its
//  failure is swallowed, because clearing the phone is still right offline.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../care_partner/partner_dashboard_store.dart';
import '../services/sponsor_admin_store.dart';
import 'partner_org_session.dart';

Future<void> forgetPartnerOrgOnThisPhone() async {
  try {
    await Supabase.instance.client.auth.signOut();
  } catch (e) {
    // Offline, an expired token, or a backend that never started.
    debugPrint('[partners] signOut: $e');
  }
  PartnerOrgSession.instance.clear();
  // Employer and school: the dashboard and the roster of names (P2).
  SponsorAdminStore.instance.clear();
  // IVF centre: the care-partner numbers (P3).
  PartnerDashboardStore.instance.reset();
}
