// =============================================================================
//  AskVedaScreen — AskVeda · search result (parenting app · S2)
// -----------------------------------------------------------------------------
//  The unified search: one query returns a structured page — expert answer
//  (pinned), then community, videos, articles, research, products, courses,
//  services. Faithful build of Claude Design S2. Isolated module.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class AskVedaScreen extends StatelessWidget {
  const AskVedaScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 116),
            children: [
              // search bar
              _pad(GestureDetector(
                onTap: () => _soon(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppLine)),
                  child: Row(children: [
                    const Icon(Icons.search_rounded, color: ppMuted, size: 18),
                    const SizedBox(width: 11),
                    Expanded(
                        child: Text('Aarav suddenly wakes every 2 hours at night',
                            style: ppBody(14, color: ppInk, h: 1.35))),
                  ]),
                ),
              )),
              const SizedBox(height: 12),
              _pad(Text('One answer, drawn from every part of ParentVeda.', style: ppBody(12, color: ppMuted))),

              // expert answer hero
              const SizedBox(height: 20),
              _pad(Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(22)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ppEyebrow('Expert answer', color: ppPurple, spacing: 1.0),
                  const SizedBox(height: 12),
                  Text(
                      "This is the classic 4-month sleep regression — a normal, temporary part of Leap 4. Your baby's sleep is maturing into adult-like cycles with lighter phases he briefly wakes in. It's a sign of development, not a step back. Hold the routine; it settles in 2–6 weeks.",
                      style: ppFraunces(20, h: 1.45)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE1D7EC)))),
                    child: Row(children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                        clipBehavior: Clip.antiAlias,
                        child: const PpStriped(height: 40, colorA: ppBorder, colorB: ppStripeB),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(TextSpan(children: [
                          const TextSpan(text: 'Reviewed by '),
                          TextSpan(text: 'Dr. Ananya Rao', style: TextStyle(color: ppInk, fontWeight: FontWeight.w700)),
                          const TextSpan(text: ', Paediatrician'),
                        ]), style: ppBody(12, color: ppSoft)),
                      ),
                    ]),
                  ),
                ]),
              )),

              // community
              const SizedBox(height: 26),
              _pad(_secHeader(context, 'Community discussion', seeAll: true)),
              _pad(_communityItem('How we survived the 4-month regression', ' (March 2025 babies)', '42 replies')),
              _pad(_communityItem("Anyone else's baby fighting naps?", '', '18 replies')),

              // videos
              const SizedBox(height: 24),
              _pad(_secHeader(context, 'Videos', seeAll: true)),
              _pad(_topItem(Row(children: [
                SizedBox(
                  width: 76,
                  height: 52,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(alignment: Alignment.center, children: const [
                      PpStriped(height: 60),
                      Icon(Icons.play_arrow_rounded, color: ppPurple, size: 24),
                    ]),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('The 4-month sleep regression, explained', style: ppBody(14, color: ppInk, h: 1.35)),
                    const SizedBox(height: 4),
                    Text('3 min', style: ppBody(12, color: ppMuted)),
                  ]),
                ),
              ]))),

              // articles
              const SizedBox(height: 24),
              _pad(_secHeader(context, 'Articles', seeAll: true)),
              _pad(_topItem(Text('Why baby sleep cycles change at 4 months', style: ppBody(14, color: ppInk, h: 1.4)))),

              // research
              const SizedBox(height: 24),
              _pad(_secHeader(context, 'Research')),
              _pad(_topItem(Row(children: [
                Expanded(child: Text('Infant sleep architecture at 3–5 months', style: ppBody(14, color: ppInk, h: 1.4))),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.lock_outline_rounded, size: 11, color: ppBrown),
                    const SizedBox(width: 5),
                    Text('Deep access · ParentVeda+', style: ppBody(10, color: ppBrown, w: FontWeight.w700)),
                  ]),
                ),
              ]))),

              // products
              const SizedBox(height: 24),
              _pad(_secHeader(context, 'Products', seeAll: true)),
              _pad(_productItem('Sleep Better plan', 'The routine that answers this exact problem.')),
              _pad(_productItem('White-noise soother', 'Masks the sounds that wake him in lighter sleep.')),

              // courses
              const SizedBox(height: 24),
              _pad(_secHeader(context, 'Courses')),
              _pad(_topItem(Text('Sleep Bootcamp — 2-week cohort', style: ppBody(14, color: ppInk, h: 1.4)))),

              // services
              const SizedBox(height: 24),
              _pad(_secHeader(context, 'Services')),
              _pad(_topItem(Text('Find a paediatric sleep consultant near you →',
                  style: ppBody(14, color: ppPurple, w: FontWeight.w700)))),
            ],
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: SizedBox(
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)]),
                ),
              ),
            ),
          ),
        ),
        const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 1)),
      ]),
    );
  }

  Widget _secHeader(BuildContext context, String title, {bool seeAll = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: ppJakarta(15)),
          if (seeAll)
            GestureDetector(
              onTap: () => _soon(context),
              child: Text('See all', style: ppBody(12, color: ppPurple, w: FontWeight.w600)),
            ),
        ]),
      );

  Widget _topItem(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair))),
        child: child,
      );

  Widget _communityItem(String title, String muted, String replies) => _topItem(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text.rich(TextSpan(children: [
            TextSpan(text: title, style: TextStyle(color: ppInk)),
            if (muted.isNotEmpty) TextSpan(text: muted, style: const TextStyle(color: ppMuted)),
          ]), style: ppBody(14, h: 1.4)),
          const SizedBox(height: 4),
          Text(replies, style: ppBody(12, color: ppMuted)),
        ]),
      );

  Widget _productItem(String title, String desc) => _topItem(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: ppBody(14, color: ppInk, w: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(desc, style: ppBody(12)),
        ]),
      );
}
