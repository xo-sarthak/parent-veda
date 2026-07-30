// =============================================================================
//  DoctorProfileScreen — the expert's own profile + exit doctor mode
// -----------------------------------------------------------------------------
//  What the doctor manages about themselves, and the way OUT of doctor mode back
//  to the parent app (the testing affordance — later this is a real sign-out).
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_directory.dart';
import '../../care_partner/care_partner_models.dart';
import '../../care_partner/partner_dashboard_store.dart';
import '../../doctor/doctor_session.dart';
import '../post_pregnancy/pp_common.dart';
import 'doctor_onboarding_screen.dart';
import 'doctor_referral_kit_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  static String _initial(String name) {
    final n = name.replaceAll(RegExp(r'^(Dr|Prof)\.?\s*'), '').trim();
    return n.isEmpty ? '?' : n.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Same trap as the home header: doctorInfoById() returns the FIRST doctor
    // for an unknown id, so a hospital or lab would see a stranger's name and
    // credential presented as its own.
    final session = DoctorSession.instance;
    final e = session.consults ? doctorInfoById(session.expertId!) : null;
    final partner = PartnerDashboardStore.instance.partner;
    final name = e?.name ?? partner?.name ?? 'Your practice';
    final sub = e?.credential ??
        (partner == null ? '' : CarePartnerType.label(partner.type));
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        const SizedBox(height: 8),
        // Practice setup: profile, qualifications, council registration,
        // documents and payout details. Every step can be skipped while we are
        // testing - the point today is that the screens exist and can be walked.
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const DoctorOnboardingScreen())),
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: ppBorder),
            ),
            child: Row(children: [
              const Icon(Icons.verified_user_outlined, size: 20, color: ppPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Complete your practice setup', style: ppJakarta(13.5)),
                      const SizedBox(height: 2),
                      Text(
                          'Qualifications, council registration, documents and payouts.',
                          style: ppBody(11.5, h: 1.4)),
                    ]),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
            ]),
          ),
        ),
        // The QR/link a doctor puts on their wall. This is the entry point to
        // the whole Care Partner platform - without it nothing downstream ever
        // fires.
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const DoctorReferralKitScreen())),
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: ppBorder),
            ),
            child: Row(children: [
              const Icon(Icons.qr_code_2_rounded, size: 20, color: ppPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your referral kit', style: ppJakarta(13.5)),
                      const SizedBox(height: 2),
                      Text('QR code, link and a message for your patients.',
                          style: ppBody(11.5, h: 1.4)),
                    ]),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
            ]),
          ),
        ),
        Row(children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
            child: Text(
              _initial(name),
              style: const TextStyle(
                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: ppFraunces(23, color: ppTitleInk, h: 1.05),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(sub,
                  style: ppBody(12.5, color: ppSoft),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          // A referral-only partner has no consulting category or rating. It
          // shows what it does have — what kind of partner it is, and the city.
          _stat(
              e != null && e.category.isNotEmpty
                  ? e.category
                  : (partner == null
                      ? 'Partner'
                      : CarePartnerType.label(partner.type)),
              'Field'),
          const SizedBox(width: 12),
          _stat(
              e != null && e.rating.isNotEmpty
                  ? e.rating
                  : (partner?.city.isNotEmpty == true ? partner!.city : '—'),
              e != null && e.rating.isNotEmpty ? 'Rating' : 'Location'),
        ]),
        if ((e?.blurb ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 22),
          Text('About', style: ppJakarta(16)),
          const SizedBox(height: 8),
          Text(e!.blurb, style: ppBody(14, color: ppInk, h: 1.6)),
        ],
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () => DoctorSession.instance.exit(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ppPanel,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.logout_rounded, size: 18, color: ppInk),
              const SizedBox(width: 8),
              Text('Exit doctor mode',
                  style: ppBody(14, color: ppInk, w: FontWeight.w700)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('You’ll return to the parent app.',
              style: ppBody(11.5, color: ppMuted)),
        ),
      ],
    );
  }

  Widget _stat(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ppHair),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: ppJakarta(15, color: ppTitleInk),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label, style: ppBody(11.5, color: ppMuted)),
          ]),
        ),
      );
}
