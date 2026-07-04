// =============================================================================
//  ProblemSolverScreen — Find the right help · local services (parenting · S18)
// -----------------------------------------------------------------------------
//  "Trusted help, near you" — a ParentVeda top pick, browse-by-need categories
//  routing to vetted partner platforms, and a labelled sponsored slot. Reached
//  from the Explore drawer (design path: from My Child). "Paediatricians" opens
//  the ranked results. Faithful build of Claude Design · S18.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'provider_results_screen.dart';

class ProblemSolverScreen extends StatelessWidget {
  const ProblemSolverScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _openResults(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ProviderResultsScreen()),
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
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ppBack(context, 'Explore'),
              ppLocationPill('Delhi NCR'),
            ])),

            const SizedBox(height: 22),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppEyebrow('Trusted help, near you'),
              const SizedBox(height: 10),
              Text('Find the right help', style: ppFraunces(32, h: 1.12)),
              const SizedBox(height: 12),
              Text(
                  'Paediatricians, therapists, nannies, daycare — we point you to vetted partners and add our own top picks for your city.',
                  style: ppBody(15)),
            ])),

            // search
            const SizedBox(height: 20),
            _pad(GestureDetector(
              onTap: () => _soon(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppBorder)),
                child: Row(children: [
                  const Icon(Icons.search_rounded, size: 18, color: ppMuted),
                  const SizedBox(width: 10),
                  Flexible(
                      child: Text('What do you need help with?',
                          style: ppBody(14, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ),
            )),

            // top pick
            const SizedBox(height: 22),
            _pad(ppEyebrow("ParentVeda's top pick · Delhi NCR", color: ppBrown, spacing: 0.8)),
            const SizedBox(height: 12),
            _pad(Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ppBorder),
                boxShadow: ppCardShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
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
                        Text('Paediatrician · Greater Kailash', style: ppBody(12)),
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
                  ]),
                  const SizedBox(height: 14),
                  Text('Curated from partner data, our research, and real parent reviews.', style: ppBody(13, h: 1.5)),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: Text('Booking via Practo', style: ppBody(12, color: ppMuted))),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _soon(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                        child: Text('Book', style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ]),
              ),
            )),

            // categories
            const SizedBox(height: 28),
            _pad(Text('Browse by need', style: ppJakarta(18))),
            const SizedBox(height: 4),
            _pad(Text('Each routes you to a trusted partner platform.', style: ppBody(13))),
            const SizedBox(height: 12),
            _pad(_cat(context, Icons.medical_services_outlined, 'Paediatricians', 'via Practo · Apollo 24/7',
                onTap: () => _openResults(context), top: true)),
            _pad(_cat(context, Icons.record_voice_over_outlined, 'Speech therapists',
                'via 1SpecialPlace · BabyChakra')),
            _pad(_cat(context, Icons.spa_outlined, 'Child dermatologists', 'via Practo · Apollo 24/7')),
            _pad(_cat(context, Icons.restaurant_outlined, 'Organic food suppliers', 'via BigBasket · Licious')),
            _pad(_cat(context, Icons.child_care_outlined, 'Japa & nanny services', 'via Urban Company · Care.com')),
            _pad(_cat(context, Icons.school_outlined, 'Daycare', 'via KLAY · Footprints · JustDial', bottom: true)),

            // sponsored
            const SizedBox(height: 24),
            _pad(Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ppBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Stack(children: [
                  const PpStriped(height: 120),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                      child: Text('Sponsored by Urban Company', style: ppBody(10, color: Colors.white, w: FontWeight.w700)),
                    ),
                  ),
                ]),
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Trained japa maids, background-verified', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('Available across Delhi NCR this week.', style: ppBody(12)),
                  ]),
                ),
              ]),
            )),

            const SizedBox(height: 22),
            _pad(Text(
                "ParentVeda routes you to trusted partners and adds its own top picks & mother reviews. Sponsored placements are always labelled. We don't run the vetting — the partner does.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _cat(BuildContext context, IconData icon, String name, String via,
      {VoidCallback? onTap, bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: onTap ?? () => _soon(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 20, color: ppPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: ppBody(15, color: ppInk, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(via, style: ppBody(12)),
            ]),
          ),
          const SizedBox(width: 10),
          const Text('→', style: TextStyle(color: ppMuted)),
        ]),
      ),
    );
  }
}
