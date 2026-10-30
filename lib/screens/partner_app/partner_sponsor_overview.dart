// =============================================================================
//  Overview for an employer or a school (P2)
// -----------------------------------------------------------------------------
//  Three server calls, all through SponsorAdminStore, all answering only the
//  signed-in admin's own organisation (my_sponsor_admin_id, 0136):
//
//    sponsor_dashboard()      seats, activated, take-up, consultations
//    sponsor_trend(12)        take-up month by month
//    sponsor_engagement(6)    people who opened the app each month
//
//  A RENDERER, as the in-app HR screen is. Nothing is counted here; the rows
//  behind these numbers never reach the phone.
//
//  TWO KINDS OF NUMBER, TWO RULES (the sponsor rule, R3 in MASTER.md):
//    * contract facts (seats, activated, joined) are never withheld;
//    * behaviour (consultations, who opened the app) is null below the
//      server's min_cohort, and is shown as "—" with the reason, never as 0.
//  The threshold in every sentence is the server's `min_cohort`, never a
//  hard-coded 5: the day ops raises it, the words follow.
//
//  NOT HERE, ON PURPOSE: "Where your families are" (a stage mix) and "Most
//  used" (a section breakdown) were in the P2 plan. No RPC returns either,
//  and 0065 declines the second outright: in a small team "your people spend
//  their time in Health" narrows down who is worried about what. Recorded in
//  PARTNERS-APP.md's P2 as-built; the privacy note at the foot of this tab
//  says so in the product's voice.
// =============================================================================

import 'package:flutter/material.dart';

import '../../partner_app/partner_org_session.dart';
import '../../services/sponsor_admin_store.dart';
import '../doctor/doctor_chrome.dart';
import 'partner_report_screen.dart';
import 'partner_tabs.dart';
import 'partner_words.dart';

class PartnerSponsorOverview extends StatefulWidget {
  const PartnerSponsorOverview({super.key, required this.org});
  final PartnerOrg org;

  @override
  State<PartnerSponsorOverview> createState() => _PartnerSponsorOverviewState();
}

class _PartnerSponsorOverviewState extends State<PartnerSponsorOverview> {
  @override
  void initState() {
    super.initState();
    partnerLoadSponsorOnce();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: SponsorAdminStore.instance,
    builder: (context, _) {
      final org = widget.org;
      final store = SponsorAdminStore.instance;
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
              PartnerLoadProblem(store.error!)
            else
              DcEmpty(
                'Your numbers live here',
                'How many ${org.peopleWord} activated, who is active this '
                    'month and the consults used appear on this tab.',
                icon: Icons.insights_outlined,
              ),
          ] else
            ..._loaded(context, org, store, d),
          const SizedBox(height: DcTab.barClearance),
        ],
      );
    },
  );

  List<Widget> _loaded(
    BuildContext context,
    PartnerOrg org,
    SponsorAdminStore store,
    SponsorDashboard d,
  ) {
    final min = d.minCohort;
    final month = store.thisMonth;
    final seats = d.seatsPurchased;
    return [
      if (d.renewalAt != null) ...[
        Text('Renews ${dcDate(d.renewalAt!, year: true)}', style: dcMeta(13)),
        const SizedBox(height: 12),
      ],
      if (store.error != null) ...[
        PartnerLoadProblem(store.error!),
        const SizedBox(height: 12),
      ],
      if (d.seatsLeft == 0) ...[
        DcNotice(partnerSeatsFullText(org, seats ?? 0), problem: true),
        const SizedBox(height: 12),
      ],
      DcStatRow([
        DcStat(
          'Seats',
          seats == null ? 'Unlimited' : '$seats',
          sub: seats == null ? 'No cap' : '${d.seatsLeft ?? 0} left',
        ),
        DcStat(
          'Activated',
          '${d.activated}',
          sub: d.activationRate == null
              ? '${d.activatedLast30d} in the last 30 days'
              : d.denominatorIsRoster
              ? '${d.activationRate}% of your list'
              : '${d.activationRate}% of seats',
        ),
      ]),
      DcStatRow([
        DcStat(
          'Active this month',
          month?.activePeople?.toString() ?? '—',
          sub: month == null
              ? 'Not counted yet'
              : month.withheld
              ? 'Shown when $min or more open it'
              : 'opened ParentVeda',
        ),
        DcStat(
          'Consultations',
          d.suppressed ? '—' : '${d.consultationsBooked ?? 0}',
          sub: d.suppressed
              ? partnerWithheldText(min)
              : '${d.consultationsCompleted ?? 0} attended · '
                    '${d.consultationsUpcoming ?? 0} upcoming',
        ),
      ]),
      const SizedBox(height: 16),
      DcSectionHead('Take-up', title: _trendTitle(store)),
      if (store.trend.isEmpty)
        const DcNotice(
          'Month by month appears once the programme has a month behind it.',
        )
      else
        PartnerBars(
          values: [for (final p in store.trend) p.activatedCumulative],
          months: [for (final p in store.trend) p.month],
        ),
      const SizedBox(height: 16),
      const DcSectionHead('Coming back', title: 'Opened ParentVeda, by month'),
      if (store.engagement.isEmpty || store.engagement.every((e) => e.withheld))
        DcNotice(
          'Shown once $min or more ${org.peopleWord} open the app in a month. '
          'In a small group a monthly total is close to a name.',
        )
      else ...[
        PartnerBars(
          values: [for (final e in store.engagement) e.activePeople],
          months: [for (final e in store.engagement) e.month],
        ),
        if (month?.avgSessionMin != null) ...[
          const SizedBox(height: 8),
          Text(
            'An average visit this month: '
            '${month!.avgSessionMin!.toStringAsFixed(1)} min',
            style: dcMeta(13),
          ),
        ],
        if (store.engagement.any((e) => e.withheld)) ...[
          const SizedBox(height: 6),
          Text(
            'A dash is a month with fewer than $min people, held back.',
            style: dcMeta(12.5),
          ),
        ],
      ],
      const SizedBox(height: 20),
      DcRowGroup(
        children: [
          DcRow(
            title: 'Monthly report',
            subtitle: 'One page to forward, shared as a PDF',
            icon: Icons.description_outlined,
            onTap: () =>
                Navigator.of(context).push(PartnerReportScreen.route(org)),
          ),
        ],
      ),
      const SizedBox(height: 20),
      DcNotice(partnerPrivacyText(org)),
    ];
  }

  String _trendTitle(SponsorAdminStore store) {
    final c = store.activationChange3m;
    if (c == null) return 'Activated so far';
    if (c > 0) return 'Up $c since three months ago';
    if (c == 0) return 'Level with three months ago';
    // Said as plainly as growth: a dashboard that only narrates good news is
    // one nobody trusts the good news on.
    return 'Down ${-c} since three months ago';
  }
}

/// Bars for a short run of months. A null value is a withheld month: a
/// hairline stub and a dash, never a zero-height bar that reads as "nobody".
class PartnerBars extends StatelessWidget {
  const PartnerBars({super.key, required this.values, required this.months});
  final List<int?> values;
  final List<DateTime> months;

  static const _mo = 'JFMAMJJASOND';

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final peak = values.whereType<int>().fold<int>(1, (a, b) => b > a ? b : a);
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(values[i]?.toString() ?? '—', style: dcMeta(10.5)),
                    const SizedBox(height: 3),
                    Container(
                      height: values[i] == null
                          ? 2
                          : 4 + 48 * (values[i]! / peak),
                      decoration: BoxDecoration(
                        color: values[i] == null ? p.line : p.ink1,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(_mo[months[i].month - 1], style: dcMeta(10.5)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A load problem with the way out: pull down, or tap. [onRetry] defaults to
/// the sponsor store; an IVF centre's tabs (P3) pass their own.
class PartnerLoadProblem extends StatelessWidget {
  const PartnerLoadProblem(this.text, {super.key, this.onRetry});
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DcNotice(text, problem: true),
      const SizedBox(height: 6),
      TextButton(
        onPressed: onRetry ?? SponsorAdminStore.instance.refresh,
        child: Text('Try again', style: dcStrong(14, color: dcP.action)),
      ),
    ],
  );
}

/// Loads the programme once per sign-in; Overview and People share it, so
/// switching tabs does not refetch. Pull to refresh fetches again. After the
/// first frame, so the store's notify never lands inside a build.
void partnerLoadSponsorOnce() {
  final store = SponsorAdminStore.instance;
  if (store.everLoaded || store.loading) return;
  WidgetsBinding.instance.addPostFrameCallback((_) => store.refresh());
}
