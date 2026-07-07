// =============================================================================
//  ProviderProfileScreen - reusable expert / provider profile (parenting · S18·detail)
// -----------------------------------------------------------------------------
//  A single expert or provider: why ParentVeda picks them, languages &
//  specialties, verified-mother reviews, a disclosure, and a sticky book bar.
//  Data-driven - pass any `Expert` (from pp_experts_data) and it renders that
//  person; with no expert it defaults to Dr. Neha Sharma (the Problem Solver
//  provider), so the S18·detail flow is unchanged. Reused everywhere an expert
//  is named: masterclasses, cohorts, courses, and local services. Faithful build
//  of Claude Design · S18·detail.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_experts_data.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key, this.expert});

  /// The person to render. Defaults to Dr. Neha Sharma when null.
  final Expert? expert;

  static const Color _green = Color(0xFF1F8A5B);

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking opens soon'), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    final e = expert ?? expertById('neha');
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 120),
            children: [
              _pad(ppBack(context, e.backLabel)),

              // header
              const SizedBox(height: 20),
              _pad(Row(children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                  clipBehavior: Clip.antiAlias,
                  child: const PpStriped(height: 82, colorA: ppBorder, colorB: ppStripeB),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (e.topPick)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFFEAF6EF), borderRadius: BorderRadius.circular(999)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.check_rounded, size: 12, color: _green),
                          const SizedBox(width: 5),
                          Flexible(
                              child: Text(e.topPickLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ppBody(11, color: _green, w: FontWeight.w700))),
                        ]),
                      ),
                    if (e.topPick) const SizedBox(height: 8),
                    Text(e.name, style: ppFraunces(24, h: 1.1)),
                    const SizedBox(height: 2),
                    Text(e.credential, style: ppBody(13)),
                  ]),
                ),
              ])),

              // stats
              const SizedBox(height: 20),
              _pad(Row(children: [
                _stat('★ ${e.rating}', e.reviewsCount),
                _statDivider(),
                _stat(e.mid.$1, e.mid.$2),
                _statDivider(),
                _stat(e.fee.$1, e.fee.$2),
              ])),

              // why
              const SizedBox(height: 26),
              _pad(Text(e.whyHeading, style: ppJakarta(18))),
              const SizedBox(height: 8),
              _pad(Text(e.why, style: ppBody(15, h: 1.6))),

              // languages & specialties
              const SizedBox(height: 22),
              _pad(Wrap(spacing: 9, runSpacing: 9, children: [for (final t in e.tags) _tag(t)])),

              // reviews
              const SizedBox(height: 28),
              _pad(Text('From verified mothers', style: ppJakarta(18))),
              const SizedBox(height: 4),
              _pad(Text('Same review system as Products - named, never anonymous.', style: ppBody(12))),
              const SizedBox(height: 14),
              for (var i = 0; i < e.reviews.length; i++)
                _pad(_review(e.reviews[i].$1, e.reviews[i].$2, '★★★★★', e.reviews[i].$3,
                    top: i == 0, bottom: i == e.reviews.length - 1)),

              const SizedBox(height: 22),
              _pad(Text(e.disclaimer, textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),

          // sticky CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FBF9FE), ppBg],
                  stops: [0, 0.22],
                ),
              ),
              child: Row(children: [
                Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.ctaPrice, style: ppBody(16, color: ppInk, w: FontWeight.w700)),
                  Text(e.ctaSub, style: ppBody(11, color: ppMuted, w: FontWeight.w600)),
                ]),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _soon(context),
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                      child: Text(e.ctaLabel, style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _stat(String value, String label) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: ppBody(11, color: ppMuted)),
        ]),
      );

  Widget _statDivider() => Container(
        width: 1,
        height: 30,
        color: ppLine,
        margin: const EdgeInsets.symmetric(horizontal: 12),
      );

  Widget _tag(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: ppBody(12, color: ppInk, w: FontWeight.w600)),
      );

  Widget _review(String name, String who, String stars, String quote,
          {bool top = false, bool bottom = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '$name ', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                  TextSpan(text: '· $who', style: ppBody(13, color: ppMuted)),
                ]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(stars, style: ppBody(12, color: ppCoral, w: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text(quote, style: ppBody(14, color: ppInk, h: 1.55)),
        ]),
      );
}
