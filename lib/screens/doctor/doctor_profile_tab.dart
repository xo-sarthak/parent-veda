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
import '../../doctor/doctor_hero_images.dart';
import '../post_pregnancy/pp_experts_data.dart' show expertByIdOrNull;
import 'doctor_art.dart';
import 'doctor_chrome.dart';
import 'doctor_task_feed.dart';
import 'doctor_classes_screen.dart';
// import 'doctor_onboarding_screen.dart'; // kept for revert — see Your practice
import 'doctor_photo_sheet.dart';
import 'doctor_payout_account_screen.dart';
import 'doctor_referral_kit_screen.dart';

class DoctorProfileTab extends StatelessWidget {
  const DoctorProfileTab({super.key, required this.goTo});
  final void Function(DoctorTab) goTo;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([doctorFeedListenable(), PartnerDashboardStore.instance]),
      builder: (context, _) {
        final feed = DoctorFeed.now();
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
          // LinkedIn's arrangement (Mobbin, 2026-09-21; the user's call, after
          // seeing the centred Places/Grab version side by side): the band is
          // the picture; the photo circle straddles the seam at the LEFT; the
          // name and credential sit under it in the sheet, left-aligned like
          // everything else. The band is a BANNER (DcHero.bannerHeight), not
          // the door's 332: at the door's height the photograph was the page
          // and neither alignment sat well on it. No small avatar in the
          // corner: two of the same face is one too many.
          hero: DcHero(
            asset: kDoctorHeroImages['profile']!.asset,
            // A banner, not a door: LinkedIn's cover height.
            height: DcHero.bannerHeight,
            // No eyebrow either: it would sit under the circle, and the tab
            // bar already says Profile.
            greeting: '',
            badge: feed.unread,
            onBell: () => feed.openUpdates(context, goTo),
          ),
          children: [
            // The circle: its centre on the seam, a ground ring so it sits on
            // the photograph and the sheet alike, the camera badge on its
            // rim. The first thing on the page and half of it on the picture.
            SizedBox(
              height: _PhotoCircle.d / 2 + 4,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                // Tight on both axes: left loose, the circle's Stack takes
                // the whole row and its badge lands at the screen's edge.
                minWidth: _PhotoCircle.d + 8,
                maxWidth: _PhotoCircle.d + 8,
                maxHeight: _PhotoCircle.d + 8,
                minHeight: _PhotoCircle.d + 8,
                child: Transform.translate(
                  // Up by the sheet's top padding and half the circle.
                  offset: const Offset(-4, -(22 + _PhotoCircle.d / 2)),
                  child: _PhotoCircle(
                    url: session.profile?.photoUrl,
                    initial: _initial(name),
                    onTap: session.expertId == null ? null : () => showDoctorPhotoSheet(context),
                    editable: session.expertId != null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(name, style: dcTitle(26)),
            if (sub.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(sub, style: dcBody(15, color: p.ink2)),
            ],
            if (email != null) ...[
              const SizedBox(height: 2),
              Text(email, style: dcMeta(13)),
            ],
            if (session.expertId != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => showDoctorPhotoSheet(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      session.profile?.photoUrl == null ? 'Add your photo' : 'Change photo',
                      style: dcStrong(14, color: p.action),
                    ),
                  ),
                ),
              ),
            ],
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
              'Your photo is yours to change. The rest of your public profile is set by ParentVeda from your onboarding — write to partners@parentveda.com for a correction.',
              style: dcMeta(12.5, color: p.ink3),
            ),
            const SizedBox(height: 22),

            const DcSectionHead('Your practice'),
            DcRowGroup(children: [
              DcRow(
                mark: DoctorMark.bank,
                title: 'Payout account',
                subtitle: acct == null
                    ? 'Not set up. Required to get paid.'
                    : '${acct.masked} · ${acct.verified ? 'Verified' : acct.status == 'rejected' ? 'Needs attention' : 'Being verified'}',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'doctor/payout-account'),
                    builder: (_) => const DoctorPayoutAccountScreen())),
              ),
              DcRow(
                mark: DoctorMark.classes,
                title: 'Your classes',
                subtitle: 'Masterclasses and cohorts you host.',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'doctor/classes'),
                    builder: (_) => const DoctorClassesScreen())),
              ),
              DcRow(
                mark: DoctorMark.qr,
                title: 'Referral kit',
                subtitle: 'QR code, link and a message for your patients.',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'doctor/referral-kit'),
                    builder: (_) => const DoctorReferralKitScreen())),
              ),
              // Kept for revert (2026-09-21): the practice-setup form. A doctor
              // is onboarded AFTER KYC — qualifications, registration and
              // documents are collected before the account exists — so
              // asking again in the app was asking twice. The screen stays
              // in the tree (doctor_onboarding_screen.dart), unreachable.
              // DcRow(
              //   mark: DoctorMark.done,
              //   title: 'Practice setup',
              //   subtitle: 'Qualifications, registration, documents.',
              //   onTap: () => Navigator.of(context).push(MaterialPageRoute(
              //       settings: const RouteSettings(name: 'doctor/onboarding'),
              //       builder: (_) => const DoctorOnboardingScreen())),
              // ),
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
                mark: DoctorMark.leave,
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

/// The circle: 104pt, the photograph or the initial on the neutral
/// surface, a 4pt ground ring so it sits on the photograph and the sheet
/// alike, a 34pt ink badge on the rim with a camera glyph — the verb, so an
/// icon (DESIGN-SYSTEM §3.4). The whole circle is the tap target.
class _PhotoCircle extends StatelessWidget {
  const _PhotoCircle({required this.url, required this.initial, required this.onTap, this.editable = true});
  final String? url;
  final String initial;
  final VoidCallback? onTap;
  /// An organisation account has no photo of its own: no badge, no tap.
  final bool editable;

  static const double d = 104;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: d + 8,
        height: d + 8,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: 4,
            top: 4,
            child: Container(
              width: d,
              height: d,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.surfaceAlt,
                border: Border.all(color: p.ground, width: 4),
              ),
              clipBehavior: Clip.antiAlias,
              child: url == null
                  ? Center(child: Text(initial, style: dcTitle(44)))
                  : Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => Center(child: Text(initial, style: dcTitle(44)))),
            ),
          ),
          if (editable)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.ink1,
                border: Border.all(color: p.ground, width: 3),
              ),
              child: Icon(Icons.photo_camera_rounded, size: 16, color: p.surface),
            ),
          ),
        ]),
      ),
    );
  }
}
