// =============================================================================
//  MasterclassesScreen - Learn · Masterclasses (parenting · S11)
// -----------------------------------------------------------------------------
//  RETIRED (superseded 2026-07) - folded into the merged "Courses &
//  Masterclasses" section: see learning_home_screen.dart (LearningHomeScreen),
//  where masterclasses are one of the three kinds. This landing page is detached
//  from the Explore drawer; its code is kept intact for reference/revert.
// -----------------------------------------------------------------------------
//  "One evening with an expert" - a featured live masterclass plus recorded
//  ones to watch anytime. Reached from the Explore drawer (design path:
//  Products → Learn → Masterclasses). Each class opens the full funnel page.
//  Faithful build of Claude Design "post pregnancy app.dc.html" · S11.
// =============================================================================

import 'package:flutter/material.dart';

import 'masterclass_funnel_screen.dart';
import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'provider_profile_screen.dart';

class MasterclassesScreen extends StatelessWidget {
  const MasterclassesScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _openFunnel(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const MasterclassFunnelScreen()),
      );

  void _openExpert(BuildContext context, String id) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => ProviderProfileScreen(expert: expertById(id))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ppBack(context, 'Explore'),
              ppLangToggle(),
            ])),

            // header
            const SizedBox(height: 22),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppEyebrow('One evening with an expert'),
              const SizedBox(height: 10),
              Text('Masterclasses', style: ppFraunces(32, h: 1.12)),
              const SizedBox(height: 12),
              Text(
                  "A single, focused sitting with India's most trusted paediatricians and consultants. One topic, all your questions answered - live, then yours to rewatch.",
                  style: ppBody(15)),
            ])),

            // featured masterclass
            const SizedBox(height: 22),
            _pad(GestureDetector(
              onTap: () => _openFunnel(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: ppBorder),
                  boxShadow: ppCardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Stack(children: [
                    const PpStriped(height: 150),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(999)),
                        child: Text('LIVE · Sun 13 Jul, 8pm',
                            style: ppBody(11, color: Colors.white, w: FontWeight.w700)),
                      ),
                    ),
                  ]),
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('The 4-Month Sleep Regression, Solved', style: ppJakarta(19)),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => _openExpert(context, 'ananya'),
                        behavior: HitTestBehavior.opaque,
                        child: Row(children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                            clipBehavior: Clip.antiAlias,
                            child: const PpStriped(height: 44, colorA: ppBorder, colorB: ppStripeB),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Dr. Ananya Rao', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                              const SizedBox(height: 1),
                              Text('Paediatrician · 15 yrs', style: ppBody(12)),
                            ]),
                          ),
                          const SizedBox(width: 10),
                          Text('90 min', style: ppBody(12, color: ppMuted, w: FontWeight.w600)),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: Text.rich(TextSpan(children: [
                            TextSpan(text: '₹1,499', style: ppBody(15, color: ppInk, w: FontWeight.w700)),
                            TextSpan(text: '  ·  free on ', style: ppBody(12, color: ppSoft)),
                            TextSpan(text: 'ParentVeda+', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
                          ])),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                          child: Text('Reserve seat',
                              style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
                        ),
                      ]),
                    ]),
                  ),
                ]),
              ),
            )),

            // more masterclasses
            const SizedBox(height: 28),
            _pad(Text('More masterclasses', style: ppJakarta(18))),
            const SizedBox(height: 4),
            _pad(Text('Recorded - watch anytime.', style: ppBody(13))),
            const SizedBox(height: 12),
            _pad(_row(context, 'Starting solids without the stress',
                'Ritu Malhotra, Nutritionist · 75 min', '₹999',
                expertId: 'ritu', top: true)),
            _pad(_row(context, 'Understanding the Wonder Weeks',
                'Dr. Kabir Sen, Child Psychologist · 2 hr', '₹2,499', expertId: 'kabir')),
            _pad(_row(context, 'Baby-proofing for joint families',
                'Meera Iyer, Safety Educator · 60 min', '₹1,299',
                expertId: 'meera', bottom: true)),

            const SizedBox(height: 22),
            _pad(Text(
                'Every masterclass is led by a verified expert. Miss it live? The recording lands in your library.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
      ]),
    );
  }

  Widget _row(BuildContext context, String title, String meta, String price,
      {required String expertId, bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: () => _openExpert(context, expertId),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          const PpStriped(height: 58, width: 74, radius: 14, border: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(15, color: ppInk, w: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(meta, style: ppBody(12)),
            ]),
          ),
          const SizedBox(width: 10),
          Text(price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
        ]),
      ),
    );
  }
}
