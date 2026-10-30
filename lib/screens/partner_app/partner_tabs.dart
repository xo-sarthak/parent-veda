// =============================================================================
//  The Partners app's four tab bodies (P1)
// -----------------------------------------------------------------------------
//  Overview · People · Content · Account. P1 built the frame and the Account
//  tab; P2 gave an employer or a school its Overview and People
//  (partner_sponsor_overview.dart, partner_sponsor_people.dart). What is left
//  opens on its empty state, which is the
//  house rule rather than a placeholder: a feature is never hidden, and the
//  empty state is the feature's advertisement. Each one is replaced in place
//  by its phase, and its file is the obvious place to do it:
//
//    Overview  P2 (employer, school), P3 (IVF centre)
//    People    P2 (the roster), P3 (your doctors)
//    Content   P4 (exclusive programmes; read-only, R9)
//
//  Plain DcTab pages, no photo hero: this is a desk tool about numbers, and a
//  door photograph on every tab would be decoration for its own sake. A plain
//  DcTab does not pad for the floating bar (only the hero sheet does), so
//  every tab ends with [_barRoom].
// =============================================================================

import 'package:flutter/material.dart';

import '../../partner_app/partner_org_session.dart';
import '../../partner_app/partner_sign_out.dart';
import '../../services/remote/supabase_repo.dart';
import '../doctor/doctor_chrome.dart';
import 'partner_sponsor_overview.dart';
import 'partner_sponsor_people.dart';
import 'partner_words.dart';

enum PartnerTab { overview, people, content, account }

/// Room under the last row for the floating PvNavBar.
const _barRoom = SizedBox(height: DcTab.barClearance);

/// The organisation's logo, or its initial when there is none or it fails.
class PartnerOrgLogo extends StatelessWidget {
  const PartnerOrgLogo({super.key, required this.org, this.size = 48});
  final PartnerOrg org;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final initial = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: p.line),
      ),
      child: Text(
        org.name.isEmpty ? '?' : org.name.characters.first.toUpperCase(),
        style: dcTitle(size * 0.45),
      ),
    );
    final url = org.logoUrl;
    if (url == null) return initial;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.3),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => initial,
      ),
    );
  }
}

/// What kind of programme this is, in a reader's words.
String partnerOrgKindLabel(PartnerOrg org) => switch (org.kind) {
  PartnerOrgKind.careOrg => 'Care partner',
  PartnerOrgKind.sponsor =>
    org.isSchool ? 'School programme' : 'Employer programme',
};

/// The organisation as a header row, at the top of Overview and Account.
class PartnerOrgHeader extends StatelessWidget {
  const PartnerOrgHeader(this.org, {super.key});
  final PartnerOrg org;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      PartnerOrgLogo(org: org),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(org.name, style: dcStrong(17)),
            const SizedBox(height: 2),
            Text(partnerOrgKindLabel(org), style: dcMeta(13)),
          ],
        ),
      ),
    ],
  );
}

class PartnerOverviewTab extends StatelessWidget {
  const PartnerOverviewTab({super.key, required this.org});
  final PartnerOrg org;

  // P2: an employer or a school gets its numbers; an IVF centre keeps the
  // empty state until P3.
  @override
  Widget build(BuildContext context) => org.kind == PartnerOrgKind.sponsor
      ? PartnerSponsorOverview(org: org)
      : DcTab(
          title: 'Overview',
          subtitle: org.name,
          children: [
            PartnerOrgHeader(org),
            const SizedBox(height: 20),
            const DcEmpty(
              'Your numbers live here',
              'Families each of your doctors brought, and how many are active, '
                  'appear on this tab.',
              icon: Icons.insights_outlined,
            ),
            _barRoom,
          ],
        );
}

class PartnerPeopleTab extends StatelessWidget {
  const PartnerPeopleTab({super.key, required this.org});
  final PartnerOrg org;

  @override
  Widget build(BuildContext context) {
    if (org.kind == PartnerOrgKind.careOrg) {
      return const DcTab(
        title: 'Your doctors',
        children: [
          DcEmpty(
            'Your doctors appear here',
            'Each doctor at your centre, with the families they brought. '
                'No family is ever named. To add a doctor, contact your ParentVeda manager.',
            icon: Icons.medical_services_outlined,
          ),
          _barRoom,
        ],
      );
    }
    // P2: the roster. Its empty state is the one that stood here.
    return PartnerSponsorPeople(org: org);
  }
}

class PartnerContentTab extends StatelessWidget {
  const PartnerContentTab({super.key, required this.org});
  final PartnerOrg org;

  @override
  Widget build(BuildContext context) => DcTab(
    title: 'Content',
    // A care_org's members are the families its doctors brought, not
    // the doctors themselves.
    subtitle:
        'Sessions and offers only your '
        '${org.kind == PartnerOrgKind.careOrg ? 'families' : org.peopleWord} see',
    children: const [
      DcEmpty(
        'No exclusive sessions yet',
        'Your ParentVeda manager can set one up.',
        icon: Icons.event_available_outlined,
      ),
      _barRoom,
    ],
  );
}

class PartnerAccountTab extends StatefulWidget {
  const PartnerAccountTab({super.key, required this.org});
  final PartnerOrg org;

  @override
  State<PartnerAccountTab> createState() => _PartnerAccountTabState();
}

class _PartnerAccountTabState extends State<PartnerAccountTab> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    // The app root listens to PartnerOrgSession and swaps to the sign-in
    // screen when this clears it; nothing to navigate here.
    await forgetPartnerOrgOnThisPhone();
  }

  @override
  Widget build(BuildContext context) {
    final org = widget.org;
    final email = SupabaseRepo.userEmail;
    return DcTab(
      title: 'Account',
      children: [
        PartnerOrgHeader(org),
        const SizedBox(height: 20),
        DcRowGroup(
          children: [
            if (email != null)
              DcRow(
                title: 'Signed in as',
                subtitle: email,
                chevron: false,
                icon: Icons.person_outline_rounded,
              ),
            DcRow(
              title: 'ParentVeda support',
              subtitle: kPartnersSupportEmail,
              chevron: false,
              icon: Icons.mail_outline_rounded,
            ),
            if (org.supportContact != null)
              DcRow(
                title: 'Support line for your ${org.peopleWord}',
                subtitle: org.supportContact,
                chevron: false,
                icon: Icons.support_agent_outlined,
              ),
          ],
        ),
        const SizedBox(height: 28),
        ObSecondary(
          p: dcP,
          label: _signingOut ? 'Signing out…' : 'Sign out',
          onTap: _signingOut ? null : _signOut,
        ),
        _barRoom,
      ],
    );
  }
}
