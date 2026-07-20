// =============================================================================
//  GuidesToolsScreen - Learn · Guides & Tools (parenting · S13)
// -----------------------------------------------------------------------------
//  "Yours to keep" - beautiful, practical downloads (routines, trackers, plans)
//  made by experts. A featured pick plus a grid of guides. Reached from the
//  Explore drawer (design path: Products → Learn → Guides & Tools).
//  Faithful build of Claude Design · S13 (Digital Products).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class GuidesToolsScreen extends StatelessWidget {
  const GuidesToolsScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
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
              ppLangToggle(),
            ])),

            const SizedBox(height: 22),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppEyebrow('Yours to keep'),
              const SizedBox(height: 10),
              Text('Guides & Tools', style: ppFraunces(32, h: 1.12)),
              const SizedBox(height: 12),
              Text(
                  'Beautiful, practical downloads - routines, trackers and plans made by experts, designed to live on your phone and be used at 3am.',
                  style: ppBody(15)),
            ])),

            // featured download
            const SizedBox(height: 22),
            _pad(GestureDetector(
              onTap: () => _soon(context),
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
                    const PpStriped(height: 140),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                        child: Text('Most loved', style: ppBody(11, color: Colors.white, w: FontWeight.w700)),
                      ),
                    ),
                  ]),
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Sleep Better: a gentle 2-week plan', style: ppJakarta(18)),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: Text.rich(TextSpan(children: [
                            TextSpan(text: '₹699', style: ppBody(15, color: ppInk, w: FontWeight.w700)),
                            TextSpan(text: '  ·  free on ParentVeda+', style: ppBody(12, color: ppSoft)),
                          ])),
                        ),
                        const SizedBox(width: 10),
                        Text('Open →', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                      ]),
                    ]),
                  ),
                ]),
              ),
            )),

            // grid
            const SizedBox(height: 20),
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _card(context, 'Phase-by-phase guide', '₹999')),
              const SizedBox(width: 14),
              Expanded(child: _card(context, 'Feed & sleep tracker', '₹299')),
            ])),
            const SizedBox(height: 14),
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _card(context, 'First Foods playbook', '₹899')),
              const SizedBox(width: 14),
              Expanded(child: _card(context, 'Milestone memory book', '₹1,999')),
            ])),

            const SizedBox(height: 22),
            _pad(Text('Buy once, keep forever. Free updates as your child grows.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String title, String price) {
    return GestureDetector(
      onTap: () => _soon(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ppBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const PpStriped(height: 96),
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(14, color: ppInk, w: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text(price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
            ]),
          ),
        ]),
      ),
    );
  }
}
