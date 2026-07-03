// =============================================================================
//  ProductsCategoryScreen — Products · category (parenting app · S3·category)
// -----------------------------------------------------------------------------
//  A curated category (Sleep): intro + why-it-matters, a stage-relevance note,
//  and its subcategories. Faithful build of Claude Design S3·category. Pushed
//  from the Products home; opens a subcategory. No bottom nav.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'products_subcategory_screen.dart';

class ProductsCategoryScreen extends StatelessWidget {
  const ProductsCategoryScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _openSub(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const ProductsSubcategoryScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            // breadcrumb
            _pad(GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: Text.rich(TextSpan(children: [
                TextSpan(text: 'Products', style: TextStyle(color: ppPurple, fontWeight: FontWeight.w600)),
                const TextSpan(text: '  ›  ', style: TextStyle(color: Color(0xFFC7BBD6))),
                const TextSpan(text: 'Sleep'),
              ]), style: ppBody(12, color: ppMuted)),
            )),

            // intro
            const SizedBox(height: 16),
            _pad(Row(children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.bedtime_outlined, size: 26, color: ppPurple),
              ),
              const SizedBox(width: 14),
              Text('Sleep', style: ppFraunces(30, h: 1.1)),
            ])),
            const SizedBox(height: 16),
            _pad(Text(
                "Good sleep is built, not bought — but a few well-chosen things genuinely help. At 4 months, when cycles are maturing, the right environment does more than any single gadget. Here's what actually matters, and what to skip.",
                style: ppBody(15, h: 1.65))),

            const SizedBox(height: 16),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 18, color: ppPurple),
                const SizedBox(width: 11),
                Expanded(
                  child: Text.rich(TextSpan(children: [
                    const TextSpan(text: 'Relevant for Aarav now — he\'s in the '),
                    TextSpan(text: '4-month regression', style: TextStyle(fontWeight: FontWeight.w700, color: ppInk)),
                    const TextSpan(text: '.'),
                  ]), style: ppBody(13, color: ppInk, h: 1.55)),
                ),
              ]),
            )),

            // subcategories
            const SizedBox(height: 28),
            _pad(Text('Browse Sleep', style: ppJakarta(18))),
            const SizedBox(height: 4),
            _pad(Text('3 subcategories', style: ppBody(12))),
            const SizedBox(height: 8),
            _pad(_sub(context, 'Soothers & white noise', 'Mask household sound between cycles.', top: true)),
            _pad(_sub(context, 'Sleepwear & sacks', 'Safe, cosy layers for the night.', top: true)),
            _pad(_sub(context, 'Bedding & blackout', 'Darkness & a safe sleep surface.', top: true, bottom: true)),

            const SizedBox(height: 22),
            _pad(Text('Every subcategory is curated for safe infant sleep, reviewed by a paediatric sleep consultant.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _sub(BuildContext context, String name, String desc, {bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: () => _openSub(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          const PpStriped(height: 56, width: 56, radius: 16, border: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: ppJakarta(16)),
              const SizedBox(height: 2),
              Text(desc, style: ppBody(12)),
            ]),
          ),
          const SizedBox(width: 10),
          const Text('→', style: TextStyle(color: ppMuted)),
        ]),
      ),
    );
  }
}
