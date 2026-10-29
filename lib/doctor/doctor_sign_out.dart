// =============================================================================
//  forgetDoctorOnThisPhone — everything a signed-in doctor leaves behind
// -----------------------------------------------------------------------------
//  Every doctor store is a singleton, and a singleton outlives the account
//  that filled it. Sign-out used to clear only DoctorSession, DoctorLedger and
//  PartnerDashboardStore, so the next doctor to sign in on the same phone saw
//  the last one's bookings, patient names, prescriptions and week until the
//  first refresh answered, kept them for good when it did not, and got the
//  last one's "In 10 minutes" reminders (Partner Editions D1, item 3).
//
//  ONE function, called by both sign-out paths, so a store added next month
//  is added in one place. test/partner_account_test.dart reads this file and
//  fails if a doctor store is missing from it.
//
//  This is the doctor app's version of the parent app's SyncRegistry wipe. It
//  does not call SyncRegistry.resetAll(): in the parent build "Leave doctor
//  mode" keeps her signed in, and that reset would empty her own app.
// =============================================================================

import '../booking/prescription.dart';
import '../care_partner/partner_dashboard_store.dart';
import 'doctor_ledger.dart';
import 'doctor_reminders.dart';
import 'doctor_roster.dart';
import 'doctor_schedule_store.dart';
import 'doctor_session.dart';

Future<void> forgetDoctorOnThisPhone() async {
  // Reminders first: they are the one thing that reaches the person after
  // the app is closed.
  await DoctorReminders.instance.cancelAll();
  DoctorSession.instance.clear();
  DoctorRoster.instance.clear();
  PrescriptionStore.instance.clear();
  await DoctorScheduleStore.instance.clearForSignOut();
  DoctorLedger.instance.clear();
  PartnerDashboardStore.instance.reset();
}
