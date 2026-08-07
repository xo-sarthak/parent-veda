// =============================================================================
//  Care Circle — the people supporting this family
// -----------------------------------------------------------------------------
//  The spec's reframe, and the reason this module is not an affiliate system:
//  instead of a promotional label attached to a screen, the parent sees a small
//  network of people who support her — her doctor, her hospital, her lactation
//  consultant, and ParentVeda.
//
//  Two rules the screen keeps:
//
//  * PARENTVEDA IS ALWAYS IN THE CIRCLE, and always last. She is not being
//    handed off to a partner; ParentVeda holds the relationship and the partner
//    is credited within it. Listing ourselves first would say the opposite.
//
//  * A PARTNER WHO HAS GONE INACTIVE STILL APPEARS. The introduction happened.
//    Removing them because a commercial arrangement lapsed would quietly
//    rewrite her history, which is exactly the kind of small dishonesty this
//    module cannot afford.
// =============================================================================

import 'package:flutter/material.dart';

import '../../care_partner/care_partner_models.dart';
import '../../care_partner/care_partner_store.dart';
import '../post_pregnancy/pp_common.dart';
import 'care_partner_card.dart';
import '../../localization/app_language.dart';

class CareCircleScreen extends StatefulWidget {
  const CareCircleScreen({super.key});

  @override
  State<CareCircleScreen> createState() => _CareCircleScreenState();
}

class _CareCircleScreenState extends State<CareCircleScreen> {
  final _store = CarePartnerStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init().then((_) => _store.refreshFromServer());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final partner = _store.partner;
        return Scaffold(
          backgroundColor: ppBg,
          // THE EDITORIAL HEADER, like every other screen reached from Explore.
          //
          // This was a Material AppBar with a 16pt Jakarta title, which made it
          // the only page in the parenting app that announced itself in a bar
          // rather than with an eyebrow and a serif hero. Walking in from the
          // drawer, it read as a screen from a different product — and it was
          // the one page with no visible way back except the system gesture.
          //
          // Kept for revert:
          // appBar: AppBar(
          //   backgroundColor: ppBg,
          //   surfaceTintColor: Colors.transparent,
          //   elevation: 0,
          //   title: Text(S.now.uiCareCircle, style: ppJakarta(16)),
          // ),
          body: SafeArea(
            bottom: false,
            child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              ppBack(context, 'Explore'),
              const SizedBox(height: 16),
              ppEyebrow('Your people'),
              const SizedBox(height: 8),
              Text(S.now.uiCareCircle, style: ppFraunces(30, h: 1.1)),
              const SizedBox(height: 6),
              Text(
                partner == null
                    ? 'The people supporting you through this.'
                    : 'The people supporting you through this — and how you '
                        'found us.',
                style: ppBody(13.5, h: 1.55),
              ),
              const SizedBox(height: 20),
              if (partner != null) ...[
                _sectionLabel('YOUR CARE PARTNER'),
                const SizedBox(height: 10),
                CarePartnerCard(
                  partner: partner,
                  shape: CarePartnerCardShape.full,
                  padding: const EdgeInsets.only(bottom: 8),
                ),
                if (partner.status == PartnerStatus.inactive)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'No longer partnered with ParentVeda — but this is still '
                      'how your journey here began.',
                      style: ppBody(11.5, h: 1.45, color: ppSoft),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
              _sectionLabel('ALWAYS WITH YOU'),
              const SizedBox(height: 10),
              _parentVedaCard(),
              const SizedBox(height: 22),
              if (partner == null) _organicNote(),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String s) => Text(s, style: ppJakarta(10.5, color: ppSoft));

  Widget _parentVedaCard() => Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ppBorder),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: ppPanel, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.eco_rounded, size: 22, color: ppPurple),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ParentVeda', style: ppJakarta(15)),
                  const SizedBox(height: 2),
                  Text(S.now.uiEvidenceBasedSupportEvery,
                      style: ppBody(11.5, h: 1.4)),
                ]),
          ),
        ]),
      );

  /// A parent who arrived on her own is not shown an empty screen, and is not
  /// nudged to go and find a doctor. Her circle simply has one member for now.
  Widget _organicNote() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ppPanel,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'As you connect with doctors and specialists through ParentVeda, '
          'they will appear here too.',
          style: ppBody(12.5, h: 1.5),
        ),
      );
}
