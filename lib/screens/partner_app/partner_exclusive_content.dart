// =============================================================================
//  The Content tab: sessions and offers only this organisation's people see (P4)
// -----------------------------------------------------------------------------
//  One server call, partner_exclusive_content() (0142), through
//  PartnerContentStore. The same screen for an employer, a school and an IVF
//  centre: the server picks the audience from the organisation's kind, and
//  only the people-word changes here.
//
//  READ-ONLY (R9). No add, edit or delete: ParentVeda writes an organisation's
//  sessions and offers, so the screen says who to ask instead.
//
//  Booked and redeemed are behaviour: "—" below the server's min_cohort, with
//  the reason in words, never a 0. There is no "viewed" figure: nothing in
//  ParentVeda records who opened which session (0065's rule, 0142's header).
// =============================================================================

import 'package:flutter/material.dart';

import '../../partner_app/partner_content_store.dart';
import '../../partner_app/partner_org_session.dart';
import '../doctor/doctor_chrome.dart';
import 'partner_sponsor_overview.dart' show PartnerLoadProblem;
import 'partner_words.dart';

class PartnerExclusiveContent extends StatefulWidget {
  const PartnerExclusiveContent({super.key, required this.org});
  final PartnerOrg org;

  @override
  State<PartnerExclusiveContent> createState() =>
      _PartnerExclusiveContentState();
}

class _PartnerExclusiveContentState extends State<PartnerExclusiveContent> {
  @override
  void initState() {
    super.initState();
    final store = PartnerContentStore.instance;
    if (!store.everLoaded && !store.loading) {
      // After the first frame, so the store's notify never lands in a build.
      WidgetsBinding.instance.addPostFrameCallback((_) => store.refresh());
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: PartnerContentStore.instance,
    builder: (context, _) {
      final org = widget.org;
      final who = partnerContentAudienceWord(org);
      final store = PartnerContentStore.instance;
      final c = store.content;
      return DcTab(
        title: 'Content',
        subtitle: 'Sessions and offers only your $who see',
        onRefresh: store.refresh,
        children: [
          if (store.error != null) ...[
            PartnerLoadProblem(store.error!, onRetry: store.refresh),
            const SizedBox(height: 12),
          ],
          if (c == null && store.loading && !store.everLoaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (c == null || c.isEmpty)
            // P1's empty state, unchanged: it is the advertisement.
            const DcEmpty(
              'No exclusive sessions yet',
              'Your ParentVeda manager can set one up.',
              icon: Icons.event_available_outlined,
            )
          else ...[
            const DcSectionHead('Sessions'),
            if (c.programmes.isEmpty)
              Text('No sessions yet.', style: dcMeta(14))
            else
              DcRowGroup(
                children: [
                  for (final p in c.programmes) PartnerExclusiveProgrammeRow(p),
                ],
              ),
            const SizedBox(height: 20),
            const DcSectionHead('Offers'),
            if (c.offers.isEmpty)
              Text('No offers yet.', style: dcMeta(14))
            else
              DcRowGroup(
                children: [
                  for (final o in c.offers) PartnerExclusiveOfferRow(o),
                ],
              ),
            const SizedBox(height: 16),
            DcNotice(partnerContentHeldBackText(c.minCohort)),
            const SizedBox(height: 10),
            DcNotice(partnerContentReadOnlyText(who)),
          ],
          const SizedBox(height: DcTab.barClearance),
        ],
      );
    },
  );
}

String _kindLabel(String kind) => switch (kind) {
  'masterclass' => 'Masterclass',
  'cohort' => 'Live course',
  'course' => 'Recorded course',
  'class_pack' => 'Class pack',
  'workshop' => 'Workshop',
  'webinar' => 'Webinar',
  _ =>
    kind.isEmpty
        ? 'Session'
        : kind[0].toUpperCase() + kind.substring(1).replaceAll('_', ' '),
};

class PartnerExclusiveProgrammeRow extends StatelessWidget {
  const PartnerExclusiveProgrammeRow(this.p, {super.key});
  final ExclusiveProgramme p;

  String _when(DateTime now) {
    final first = p.firstSession;
    final last = p.lastSession;
    return switch (p.stateAt(now)) {
      ExclusiveState.comingSoon => 'Coming soon',
      ExclusiveState.finished =>
        last == null ? 'Finished' : 'Finished ${dcDate(last, year: true)}',
      ExclusiveState.open =>
        first == null
            ? 'Open now'
            : first.isAfter(now)
            ? 'Starts ${dcDate(first, year: true)}'
            : 'Running now',
    };
  }

  @override
  Widget build(BuildContext context) => DcRow(
    title: p.title.isEmpty ? 'A session' : p.title,
    subtitle: '${_kindLabel(p.kind)} · ${_when(DateTime.now())}',
    icon: Icons.event_available_outlined,
    trailingText: p.booked == null ? '—' : '${p.booked}',
    trailingSub: 'booked',
    chevron: false,
  );
}

class PartnerExclusiveOfferRow extends StatelessWidget {
  const PartnerExclusiveOfferRow(this.o, {super.key});
  final ExclusiveOffer o;

  String get _off =>
      o.isPercent ? '${o.value}% off' : '${dcRupees(o.value)} off';

  String get _subtitle {
    final what = (o.programmeTitle?.isNotEmpty ?? false)
        ? o.programmeTitle!
        : 'Any session';
    if (!o.active) return '$what · Not live';
    final end = o.endsAt;
    return end == null ? what : '$what · until ${dcDate(end, year: true)}';
  }

  @override
  Widget build(BuildContext context) => DcRow(
    title: '$_off · ${o.code}',
    subtitle: _subtitle,
    icon: Icons.sell_outlined,
    trailingText: o.redeemed == null ? '—' : '${o.redeemed}',
    trailingSub: 'used',
    chevron: false,
  );
}
