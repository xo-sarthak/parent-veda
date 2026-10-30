// =============================================================================
//  PartnerScaffold — the shell of ParentVeda Partners
// -----------------------------------------------------------------------------
//  Four tabs, Overview · People · Content · Account, on the same floating
//  PvNavBar the doctor app and the three parent stages use (tab sets differ,
//  treatment never does). The same tab grammar as DoctorScaffold too: Back on
//  any tab other than Overview returns to Overview, and only Back on Overview
//  leaves (the user's rule from the doctor app, 2026-09-21).
//
//  The shell reads the organisation from PartnerOrgSession and passes it down;
//  no tab looks it up on its own, so there is one answer on screen at a time.
// =============================================================================

import 'package:flutter/material.dart';

import '../../partner_app/partner_org_session.dart';
import '../../widgets/pv_nav_bar.dart';
import '../doctor/doctor_chrome.dart';
import 'partner_tabs.dart';

class PartnerScaffold extends StatefulWidget {
  const PartnerScaffold({super.key, required this.org});
  final PartnerOrg org;

  @override
  State<PartnerScaffold> createState() => _PartnerScaffoldState();
}

class _PartnerScaffoldState extends State<PartnerScaffold> {
  PartnerTab _tab = PartnerTab.overview;

  // The People label follows the organisation: an IVF centre's people are
  // its doctors.
  List<PvNavItem> get _items => [
    const PvNavItem(Icons.insights_outlined, 'Overview'),
    PvNavItem(
      Icons.groups_outlined,
      widget.org.kind == PartnerOrgKind.careOrg ? 'Doctors' : 'People',
    ),
    const PvNavItem(Icons.event_available_outlined, 'Content'),
    const PvNavItem(Icons.person_outline_rounded, 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final org = widget.org;
    final body = switch (_tab) {
      PartnerTab.overview => PartnerOverviewTab(org: org),
      PartnerTab.people => PartnerPeopleTab(org: org),
      PartnerTab.content => PartnerContentTab(org: org),
      PartnerTab.account => PartnerAccountTab(org: org),
    };
    return PopScope(
      canPop: _tab == PartnerTab.overview,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _tab != PartnerTab.overview) {
          setState(() => _tab = PartnerTab.overview);
        }
      },
      child: Scaffold(
        backgroundColor: dcP.ground,
        // The bar floats, as in DoctorScaffold; DcTab pads its list by
        // DcTab.barClearance so the last row clears the pill.
        body: Stack(
          children: [
            Positioned.fill(child: SafeArea(bottom: false, child: body)),
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewPadding.bottom + 18,
              child: PvNavBar(
                items: _items,
                activeIndex: _tab.index,
                onTap: (i) => setState(() => _tab = PartnerTab.values[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
