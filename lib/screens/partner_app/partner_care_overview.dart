// =============================================================================
//  Overview for an IVF centre (P3)
// -----------------------------------------------------------------------------
//  One server call, care_org_dashboard() (0139), through CareOrgStore. It finds
//  the centre with my_partner_org(), the resolver that opened this app, so the
//  header and the numbers always belong to the same partner.
//
//  WHY NOT partner_impact + partner_funnel + partner_earnings + the breakdown,
//  as the plan said: the breakdown takes no partner id and mixes a dual-role
//  login's centre with her own practice, and partner_impact sends behaviour
//  unwithheld, so hiding it here would only hide it from the honest. The
//  reasoning is in 0139's header.
//
//  TWO KINDS OF NUMBER (R3):
//    * referral facts (families joined, scanned, installed, signed up, active
//      in the last 30 days, per-doctor counts, money): shown as they are;
//    * behaviour (set up a pregnancy or a child, pregnancies, children,
//      consultations, vaccinations, reads): null below the server's
//      min_cohort, shown as "—" with the reason, never as 0.
// =============================================================================

import 'package:flutter/material.dart';

import '../../partner_app/care_org_store.dart';
import '../../partner_app/partner_org_session.dart';
import '../doctor/doctor_chrome.dart';
import 'partner_care_doctors.dart';
import 'partner_sponsor_overview.dart' show PartnerLoadProblem;
import 'partner_tabs.dart';
import 'partner_words.dart';

class PartnerCareOverview extends StatefulWidget {
  const PartnerCareOverview({super.key, required this.org});
  final PartnerOrg org;

  @override
  State<PartnerCareOverview> createState() => _PartnerCareOverviewState();
}

class _PartnerCareOverviewState extends State<PartnerCareOverview> {
  /// How many doctors Overview shows before pointing at the Doctors tab.
  static const _topDoctors = 3;

  @override
  void initState() {
    super.initState();
    partnerLoadCareOrgOnce();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: CareOrgStore.instance,
    builder: (context, _) {
      final org = widget.org;
      final store = CareOrgStore.instance;
      final d = store.dashboard;
      return DcTab(
        title: 'Overview',
        subtitle: org.name,
        onRefresh: store.refresh,
        children: [
          PartnerOrgHeader(org),
          const SizedBox(height: 20),
          if (d == null) ...[
            if (store.loading && !store.everLoaded)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (store.error != null)
              PartnerLoadProblem(store.error!, onRetry: store.refresh)
            else
              // P1's empty state, unchanged.
              const DcEmpty(
                'Your numbers live here',
                'Families each of your doctors brought, and how many are '
                    'active, appear on this tab.',
                icon: Icons.insights_outlined,
              ),
          ] else
            ..._loaded(store, d),
          const SizedBox(height: DcTab.barClearance),
        ],
      );
    },
  );

  List<Widget> _loaded(CareOrgStore store, CareOrgDashboard d) {
    final min = d.minCohort;
    String held(int? v) => v?.toString() ?? '—';
    final why = partnerCareWithheldText(min);
    return [
      if (store.error != null) ...[
        PartnerLoadProblem(store.error!, onRetry: store.refresh),
        const SizedBox(height: 12),
      ],
      DcStatRow([
        DcStat('Families joined', '${d.families}', sub: 'through your codes'),
        DcStat('Active', '${d.active30d}', sub: 'in the last 30 days'),
      ]),
      const SizedBox(height: 16),
      const DcSectionHead('From code to family', title: 'How they reached you'),
      DcStatRow([
        DcStat('Scanned', '${d.scanned}'),
        DcStat('Installed', '${d.installed}'),
        DcStat('Signed up', '${d.signedUp}'),
      ]),
      const SizedBox(height: 6),
      Text(
        'A scan is counted only for a family who went on to join. Nobody is '
        'tracked before they agree to anything.',
        style: dcMeta(12.5),
      ),
      const SizedBox(height: 16),
      DcSectionHead(
        'What families did',
        title: d.suppressed ? why : 'Across all your families',
      ),
      DcStatRow([
        DcStat(
          'Set up a pregnancy or child',
          held(d.activated),
          sub: d.suppressed ? why : 'families',
        ),
        DcStat(
          'Pregnancies',
          held(d.pregnancies),
          sub: d.suppressed ? why : 'added',
        ),
      ]),
      DcStatRow([
        DcStat('Children', held(d.children), sub: d.suppressed ? why : 'added'),
        DcStat(
          'Consultations',
          held(d.consultations),
          sub: d.suppressed ? why : 'attended',
        ),
      ]),
      DcStatRow([
        DcStat(
          'Vaccinations',
          held(d.vaccinations),
          sub: d.suppressed ? why : 'marked done',
        ),
        DcStat(
          'Reads',
          held(d.contentRead),
          sub: d.suppressed ? why : 'articles opened',
        ),
      ]),
      const SizedBox(height: 16),
      const DcSectionHead('By doctor', title: 'Who brought them'),
      if (d.doctors.isEmpty)
        const DcNotice(
          'Each doctor appears here once your centre has a doctor listed or '
          'a family joins. $kPartnerAddDoctorText',
        )
      else ...[
        DcRowGroup(
          children: [
            for (final r in d.doctors.take(_topDoctors))
              PartnerCareDoctorRow(r),
          ],
        ),
        if (d.doctors.length > _topDoctors) ...[
          const SizedBox(height: 6),
          Text(
            'All ${d.doctors.length} on the Doctors tab.',
            style: dcMeta(12.5),
          ),
        ],
      ],
      const SizedBox(height: 16),
      DcSectionHead(
        'Earnings',
        title: d.earnings.isEmpty
            ? 'Nothing accrued yet'
            : '${dcRupees(d.totalEarnedMinor)} in all',
      ),
      if (d.earnings.isEmpty)
        const DcNotice(
          'Commission on bookings your families make appears here, by kind '
          'and by status.',
        )
      else
        DcRowGroup(
          children: [
            for (final e in d.earnings)
              DcRow(
                title: e.sourceLabel,
                subtitle:
                    '${e.entries} ${e.entries == 1 ? 'entry' : 'entries'} · '
                    '${e.statusLabel}',
                trailingText: dcRupees(e.partnerMinor),
                chevron: false,
              ),
          ],
        ),
      const SizedBox(height: 20),
      DcNotice(partnerCarePrivacyText(min)),
    ];
  }
}

/// Loads the centre once per sign-in; Overview and Doctors share it, so
/// switching tabs does not refetch. Pull to refresh fetches again. After the
/// first frame, so the store's notify never lands inside a build.
void partnerLoadCareOrgOnce() {
  final store = CareOrgStore.instance;
  if (store.everLoaded || store.loading) return;
  WidgetsBinding.instance.addPostFrameCallback((_) => store.refresh());
}
