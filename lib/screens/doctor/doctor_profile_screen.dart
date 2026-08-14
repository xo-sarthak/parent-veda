// =============================================================================
//  DoctorProfileScreen — the expert's own profile + exit doctor mode
// -----------------------------------------------------------------------------
//  What the doctor manages about themselves, and the way OUT of doctor mode back
//  to the parent app (the testing affordance — later this is a real sign-out).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../doctor/doctor_directory.dart';
import '../../care_partner/care_partner_models.dart';
import '../../care_partner/partner_dashboard_store.dart';
import '../../doctor/doctor_session.dart';
import '../post_pregnancy/pp_common.dart';
import '../post_pregnancy/pp_experts_data.dart' show needLabel;
import 'doctor_onboarding_screen.dart';
import 'doctor_referral_kit_screen.dart';

/// End the session properly: Supabase first, then the local identity.
///
/// ORDER MATTERS. Clearing DoctorSession first would return the app to the
/// sign-in screen while the Supabase session was still live, and the next
/// resolve would silently sign the same person back in — which reads as a
/// sign-out button that does not work.
///
/// A confirm step, because on a shared clinic phone an accidental tap costs
/// somebody their password.
Future<void> _signOut(BuildContext context) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: ppBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
              color: ppBorder, borderRadius: BorderRadius.circular(999)),
        ),
        const SizedBox(height: 22),
        Text('Sign out of ParentVeda+?', style: ppJakarta(17)),
        const SizedBox(height: 10),
        Text(
            'Your patients, hours and records stay exactly as they are. You '
            'will need your email and password to sign back in.',
            textAlign: TextAlign.center,
            style: ppBody(13, h: 1.6)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.of(ctx).pop(true),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ppPurple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('Sign out',
                style: ppBody(14, color: Colors.white, w: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.of(ctx).pop(false),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ppPanel,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('Stay signed in', style: ppJakarta(14, color: ppPurple)),
          ),
        ),
      ]),
    ),
  );
  if (ok != true) return;
  try {
    await Supabase.instance.client.auth.signOut();
  } catch (_) {
    // Offline, or the token was already gone. Clearing the local identity is
    // still the right thing — a doctor who taps sign out must not stay signed
    // in because the network was down.
  }
  DoctorSession.instance.clear();
  PartnerDashboardStore.instance.reset();
}

/// The signed-in account's email, or null if there is no backend to ask.
///
/// `Supabase.instance` THROWS when initialize() has not run — it does not
/// return null. That is fine in the app, where main() initialises before any
/// screen builds, and fatal anywhere else: a widget test that pumps this screen
/// on its own took the whole test down, and so would any future entry point
/// that renders a doctor screen before the backend is up.
///
/// Which is the house rule anyway — an uninitialised backend must behave
/// exactly like being logged out, never like a crash. Returning null simply
/// hides the email line.
String? _signedInEmail() {
  try {
    return Supabase.instance.client.auth.currentUser?.email;
  } catch (_) {
    return null;
  }
}

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  static String _initial(String name) {
    final n = name.replaceAll(RegExp(r'^(Dr|Prof)\.?\s*'), '').trim();
    return n.isEmpty ? '?' : n.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Same shape as the home header. doctorInfoById() now returns null for an
    // unknown id instead of the first doctor in the list, so an unresolved
    // identity falls through to the partner name rather than to a stranger's.
    final session = DoctorSession.instance;
    final e = session.consults ? doctorInfoById(session.expertId!) : null;
    final partner = PartnerDashboardStore.instance.partner;
    final email = _signedInEmail();
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
              // WHICH ACCOUNT AM I? Nothing on this screen answered that, and
              // on a shared clinic phone it is the first thing you need to
              // know before signing out or handing the phone over. It is also
              // what made "why does doctor@test.com show Dr. Neha Sharma?"
              // impossible to answer from inside the app.
              if (email != null && email.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(email,
                    style: ppBody(11.5, color: ppMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          // A referral-only partner has no consulting category or rating. It
          // shows what it does have — what kind of partner it is, and the city.
          // needLabel(), not the raw category. Expert.category is a matching
          // key that stays spelled "Pediatrician"; the credential two lines
          // above already said "Paediatrician", so the same screen showed both
          // spellings of the same word.
          _stat(
              e != null && e.category.isNotEmpty
                  ? needLabel(e.category)
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
        // TWO DIFFERENT ACTIONS, and conflating them is what left ParentVeda+
        // with no way out at all.
        //
        //   parent build   "Exit doctor mode" — you are still signed in, and
        //                  you go back to your own app.
        //   ParentVeda+    "Sign out" — there is nothing to go back to, so the
        //                  only sensible action is to end the session.
        //
        // Previously only the first existed, and in the standalone app it did
        // nothing: it cleared DoctorSession while main_doctor decided what to
        // show from a local flag that never heard about it.
        GestureDetector(
          onTap: () => DoctorSession.standalone
              ? _signOut(context)
              : DoctorSession.instance.exit(),
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
              Text(DoctorSession.standalone ? 'Sign out' : 'Exit doctor mode',
                  style: ppBody(14, color: ppInk, w: FontWeight.w700)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
              DoctorSession.standalone
                  ? 'You’ll need your email and password to get back in.'
                  : 'You’ll return to the parent app.',
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
