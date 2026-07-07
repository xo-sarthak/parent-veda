// =============================================================================
//  ProviderResultsScreen - Problem Solver · category results (parenting · S18·list)
// -----------------------------------------------------------------------------
//  Ranked paediatricians near you: filter chips, a ParentVeda #1 editorial pick,
//  aggregated partner results, and a labelled sponsored slot. Reached from
//  Problem Solver → Browse by need → Paediatricians. Each provider opens the
//  profile. Faithful build of Claude Design · S18·list.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'provider_profile_screen.dart';

class ProviderResultsScreen extends StatelessWidget {
  const ProviderResultsScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _openProfile(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ProviderProfileScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(Row(children: [
              Expanded(child: ppBack(context, 'Problem Solver')),
              const SizedBox(width: 8),
              ppLocationPill('Delhi NCR'),
            ])),

            const SizedBox(height: 22),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppEyebrow('Paediatricians · Delhi NCR'),
              const SizedBox(height: 10),
              Text('Paediatricians near you', style: ppFraunces(30, h: 1.14)),
              const SizedBox(height: 12),
              Text(
                  'Doctors for everyday illnesses, vaccinations, and growth check-ups - aggregated from our partners, then ranked by ParentVeda.',
                  style: ppBody(15)),
            ])),

            // filter chips
            const SizedBox(height: 18),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _chip(context, 'Top rated', active: true),
                  _chip(context, 'Nearest'),
                  _chip(context, 'Video consult'),
                  _chip(context, 'Open now'),
                ],
              ),
            ),

            // editorial pick
            const SizedBox(height: 22),
            _pad(ppEyebrow("ParentVeda's #1 pick", color: ppBrown, spacing: 0.8)),
            const SizedBox(height: 12),
            _pad(GestureDetector(
              onTap: () => _openProfile(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ppBorder),
                  boxShadow: ppCardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                      clipBehavior: Clip.antiAlias,
                      child: const PpStriped(height: 60, colorA: ppBorder, colorB: ppStripeB),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Dr. Neha Sharma', style: ppJakarta(16)),
                        const SizedBox(height: 2),
                        Text('Paediatrician · 12 yrs · Greater Kailash', style: ppBody(12)),
                        const SizedBox(height: 6),
                        Row(children: [
                          Text('★ 4.9', style: ppBody(12, color: ppCoral, w: FontWeight.w700)),
                          const SizedBox(width: 8),
                          Flexible(
                              child: Text('312 mother reviews',
                                  style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    const Text('→', style: TextStyle(color: ppMuted)),
                  ]),
                ),
              ),
            )),

            // ranked results
            const SizedBox(height: 26),
            _pad(Text('All paediatricians', style: ppJakarta(18))),
            const SizedBox(height: 4),
            _pad(Text('48 near you · booking via partner platforms', style: ppBody(13))),
            const SizedBox(height: 12),
            _pad(_provider(context, 'Dr. Rajan Mehta', 'Paediatrician · Saket · 2.4 km', '★ 4.8', 'via Practo',
                '₹800',
                top: true)),
            _pad(_provider(context, 'Dr. Kavita Reddy', 'Paediatrician · Vasant Kunj · 5.1 km', '★ 4.7',
                'via Apollo 24/7', '₹700',
                bottom: true)),

            // sponsored provider
            const SizedBox(height: 16),
            _pad(GestureDetector(
              onTap: () => _soon(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ppPanel,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const PpStriped(height: 44, width: 44, radius: 12, border: true),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Sponsored', style: ppBody(10, color: ppMuted, w: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text("Rainbow Children's Clinic", style: ppBody(15, color: ppInk, w: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('Multi-specialty · via Practo', style: ppBody(12)),
                    ]),
                  ),
                  const SizedBox(width: 10),
                  const Text('→', style: TextStyle(color: ppMuted)),
                ]),
              ),
            )),

            const SizedBox(height: 22),
            _pad(Text('Ranked by ParentVeda from partner data, our research and mother reviews. Sponsored slots labelled.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, {bool active = false}) => GestureDetector(
        onTap: active ? null : () => _soon(context),
        child: Container(
          margin: const EdgeInsets.only(right: 9),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: active ? ppPurple : ppBorder),
          ),
          child: Text(label, style: ppBody(13, color: active ? Colors.white : ppSoft, w: FontWeight.w700)),
        ),
      );

  Widget _provider(BuildContext context, String name, String meta, String rating, String via, String price,
      {bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: () => _openProfile(context),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
            clipBehavior: Clip.antiAlias,
            child: const PpStriped(height: 54, colorA: ppBorder, colorB: ppStripeB),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: ppBody(15, color: ppInk, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(meta, style: ppBody(12)),
              const SizedBox(height: 5),
              Row(children: [
                Text(rating, style: ppBody(12, color: ppCoral, w: FontWeight.w700)),
                const SizedBox(width: 8),
                Flexible(child: Text(via, style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(price, style: ppBody(14, color: ppInk, w: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('consult', style: ppBody(11, color: ppMuted)),
          ]),
        ]),
      ),
    );
  }
}
