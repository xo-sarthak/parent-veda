// =============================================================================
//  Profile — who parents see, where the money goes, and the way out
// -----------------------------------------------------------------------------
//  Airbnb's menu, Notion's settings list: rows, hairlines, chevrons. Nothing
//  here is edited inline; each row opens the one screen that owns it.
//
//     What parents see       name · credential · category · fee   (read-only,
//                            edited in the panel — a public profile is an
//                            editorial act, STILL-OPEN §5.1)
//     Payout account         → the form (0084)
//     Your classes           → the host view
//     Referral kit           → QR, link, message
//     Practice setup         → the walkthrough (demoted; §12.3 keeps it inert)
//     Developer              stage toggle (testing), version
//     Sign out
//
//  Restyled from doctor_profile_screen.dart (kept for revert); sign-out is
//  the same function — clearing the local identity even when the network is
//  down, because a doctor who taps sign out must not stay signed in.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../care_partner/care_partner_models.dart';
import '../../care_partner/partner_dashboard_store.dart';
import '../../doctor/doctor_directory.dart';
import '../../doctor/doctor_ledger.dart';
import '../../doctor/doctor_session.dart';
import '../post_pregnancy/pp_experts_data.dart' show expertByIdOrNull;
import 'doctor_chrome.dart';
import 'doctor_classes_screen.dart';
import 'doctor_onboarding_screen.dart';
import 'doctor_payout_account_screen.dart';
import 'doctor_referral_kit_screen.dart';

class DoctorProfileTab extends StatelessWidget {
  const DoctorProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([DoctorSession.instance, DoctorLedger.instance, PartnerDashboardStore.instance]),
      builder: (context, _) {
        final session = DoctorSession.instance;
        final d = session.consults ? doctorInfoById(session.expertId!) : null;
        final e = session.consults ? expertByIdOrNull(session.expertId!) : null;
        final partner = PartnerDashboardStore.instance.partner;
        final name = d?.name ?? e?.name ?? partner?.name ?? 'Your practice';
        final sub = d?.credential ?? (partner == null ? '' : CarePartnerType.label(partner.type));
        final email = _signedInEmail();
        final p = dcP;
        final acct = DoctorLedger.instance.account;

        return DcTab(
          title: 'Profile',
          children: [
            DcCard(
              child: Row(children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: p.surfaceAlt, shape: BoxShape.circle),
                  child: Text(_initial(name), style: dcNum(24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: dcStrong(17), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (sub.isNotEmpty) Text(sub, style: dcMeta(13.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (email != null) Text(email, style: dcMeta(12.5, color: p.ink3), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 22),

            const DcSectionHead('What parents see'),
            DcRowGroup(children: [
              DcKeyValue('Name', name),
              if (d != null) DcKeyValue('Credential', d.credential),
              if (d != null && d.category.isNotEmpty) DcKeyValue('Speciality', d.category),
              if (e != null && e.location.isNotEmpty) DcKeyValue('City', e.location),
            ]),
            const SizedBox(height: 8),
            Text(
              'Changes to your public profile are made by ParentVeda. Write to partners@parentveda.com.',
              style: dcMeta(12.5, color: p.ink3),
            ),
            const SizedBox(height: 22),

            const DcSectionHead('Your practice'),
            DcRowGroup(children: [
              DcRow(
                icon: Icons.account_balance_outlined,
                title: 'Payout account',
                subtitle: acct == null
                    ? 'Not set up. Required to get paid.'
                    : '${acct.masked} · ${acct.verified ? 'Verified' : acct.status == 'rejected' ? 'Needs attention' : 'Being verified'}',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'doctor/payout-account'),
                    builder: (_) => const DoctorPayoutAccountScreen())),
              ),
              DcRow(
                icon: Icons.school_outlined,
                title: 'Your classes',
                subtitle: 'Masterclasses and cohorts you host.',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'doctor/classes'),
                    builder: (_) => const DoctorClassesScreen())),
              ),
              DcRow(
                icon: Icons.qr_code_2_rounded,
                title: 'Referral kit',
                subtitle: 'QR code, link and a message for your patients.',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'doctor/referral-kit'),
                    builder: (_) => const DoctorReferralKitScreen())),
              ),
              DcRow(
                icon: Icons.checklist_rounded,
                title: 'Practice setup',
                subtitle: 'Qualifications, registration, documents.',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'doctor/onboarding'),
                    builder: (_) => const DoctorOnboardingScreen())),
              ),
            ]),
            const SizedBox(height: 22),

            if (d != null && d.blurb.isNotEmpty) ...[
              const DcSectionHead('About'),
              DcCard(child: Text(d.blurb, style: dcBody(14.5, h: 1.55))),
              const SizedBox(height: 22),
            ],

            // Developer: the stage toggle the old dashboard carried in its
            // header. A testing affordance for flipping between a pregnancy-
            // side and a parenting-side doctor; nothing a clinician needs.
            if (d != null) ...[
              const DcSectionHead('Developer'),
              DcCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Test as', style: dcStrong(15.5)),
                  const SizedBox(height: 3),
                  Text('Switches the signed-in expert. Testing only.', style: dcMeta(13)),
                  const SizedBox(height: 12),
                  DcSegments(
                    labels: const ['Pregnancy', 'Parenting'],
                    index: d.stage == DoctorStage.pregnancy ? 0 : 1,
                    onChanged: (i) {
                      final stage = i == 0 ? DoctorStage.pregnancy : DoctorStage.parenting;
                      final first = firstDoctorOf(stage);
                      if (first != null) DoctorSession.instance.enter(first.id);
                    },
                  ),
                ]),
              ),
              const SizedBox(height: 22),
            ],

            DcRowGroup(children: [
              DcRow(
                icon: Icons.logout_rounded,
                title: DoctorSession.standalone ? 'Sign out' : 'Leave doctor mode',
                chevron: false,
                onTap: () => DoctorSession.standalone ? _signOut(context) : DoctorSession.instance.exit(),
              ),
            ]),
            const SizedBox(height: 12),
            Text('ParentVeda+ · for doctors, counsellors and partner clinics', style: dcMeta(12, color: p.ink3)),
          ],
        );
      },
    );
  }

  static String _initial(String name) {
    final n = name.replaceAll(RegExp(r'^(Dr|Prof)\.?\s*'), '').trim();
    return n.isEmpty ? '?' : n.characters.first.toUpperCase();
  }
}

/// The signed-in account's email, or null if there is no backend to ask.
/// `Supabase.instance` THROWS when initialize() has not run; an uninitialised
/// backend must behave exactly like being logged out, so the line hides.
String? _signedInEmail() {
  try {
    return Supabase.instance.client.auth.currentUser?.email;
  } catch (_) {
    return null;
  }
}

Future<void> _signOut(BuildContext context) async {
  final ok = await dcSheet<bool>(
    context,
    title: 'Sign out of ParentVeda+?',
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Your schedule and bookings stay on the server. Sign back in any time with a code.', style: dcMeta(14.5)),
      const SizedBox(height: 18),
      ObPrimary(p: dcP, label: 'Sign out', onTap: () => Navigator.of(context).pop(true)),
      const SizedBox(height: 10),
      ObSecondary(p: dcP, label: 'Stay signed in', onTap: () => Navigator.of(context).pop(false)),
    ]),
  );
  if (ok != true) return;
  try {
    await Supabase.instance.client.auth.signOut();
  } catch (_) {
    // Offline, or the token was already gone. Clearing the local identity is
    // still the right thing.
  }
  DoctorSession.instance.clear();
  DoctorLedger.instance.clear();
  PartnerDashboardStore.instance.reset();
}
