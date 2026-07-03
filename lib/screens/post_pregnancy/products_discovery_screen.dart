// =============================================================================
//  ProductsDiscoveryScreen — Products · home / categories (parenting app · S3)
// -----------------------------------------------------------------------------
//  The Products tab landing: AskVeda-in-products, a curated category list, and a
//  compare shortcut. Faithful build of Claude Design "post pregnancy
//  app.dc.html" · S3. Flow: home → category (S3cat) → subcategory (S3sub) →
//  detail (S3d); Compare (S3c) is reachable throughout. Isolated module.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'products_category_screen.dart';
import 'products_compare_screen.dart';

class ProductsDiscoveryScreen extends StatelessWidget {
  const ProductsDiscoveryScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _openCategory(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsCategoryScreen()));

  void _openCompare(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsCompareScreen()));

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
              _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Products', style: ppJakarta(24)),
                    const SizedBox(height: 3),
                    Text("Research first. Buy when you're sure.", style: ppBody(13)),
                  ]),
                ),
                const PpStriped(height: 36, width: 36, radius: 999, border: true),
              ])),

              // AskVeda-in-products
              const SizedBox(height: 20),
              _pad(GestureDetector(
                onTap: () => _soon(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ppLine),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A6A30B6), blurRadius: 22, spreadRadius: -12, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome_outlined, color: ppPurple, size: 16),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text('"My 2-year-old has red rashes — what should I buy?"',
                          style: ppBody(13, color: ppMuted, h: 1.35)),
                    ),
                  ]),
                ),
              )),
              const SizedBox(height: 8),
              _pad(Text('Ask in plain words — AskVeda ranks products with reasons.',
                  style: ppBody(11, color: ppMuted))),

              // categories
              const SizedBox(height: 26),
              _pad(Text('Shop by category', style: ppJakarta(18))),
              const SizedBox(height: 4),
              _pad(Text('Every category is curated and reviewed by ParentVeda.', style: ppBody(12))),
              const SizedBox(height: 16),
              _pad(Column(children: [
                _cat(context, Icons.bedtime_outlined, 'Sleep', 'Soothers · Sleepwear · Bedding', first: true),
                _catDivider(),
                _cat(context, Icons.spa_outlined, 'Skincare', 'Lotions · Rash creams · Bath'),
                _catDivider(),
                _cat(context, Icons.local_drink_outlined, 'Feeding', 'Bottles · Weaning · Sterilisers'),
                _catDivider(),
                _cat(context, Icons.toys_outlined, 'Play & Development', 'Toys · Books · Sensory'),
                _catDivider(),
                _cat(context, Icons.health_and_safety_outlined, 'Health & Safety', 'Thermometers · Baby-proofing'),
                _catDivider(),
                _cat(context, Icons.child_friendly_outlined, 'On the move', 'Strollers · Carriers · Travel'),
              ])),

              // compare shortcut
              const SizedBox(height: 24),
              _pad(GestureDetector(
                onTap: () => _openCompare(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
                  child: Row(children: [
                    const Icon(Icons.compare_arrows_rounded, color: ppPurple, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Compare any two', style: ppJakarta(14)),
                        const SizedBox(height: 1),
                        Text("Side by side, ParentVeda's honest read.", style: ppBody(12)),
                      ]),
                    ),
                    const Text('→', style: TextStyle(color: ppPurple)),
                  ]),
                ),
              )),

              const SizedBox(height: 22),
              _pad(Text(
                  'Named, verified-mother reviews on every product. Sponsored slots are always labelled. Your research stays on ParentVeda.',
                  textAlign: TextAlign.center,
                  style: ppBody(12, color: ppMuted, h: 1.55))),
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
        const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 3)),
      ]),
    );
  }

  Widget _catDivider() =>
      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: SizedBox(height: 1, child: ColoredBox(color: ppHair)));

  Widget _cat(BuildContext context, IconData icon, String name, String subs, {bool first = false}) {
    return GestureDetector(
      onTap: () => _openCategory(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(top: first ? 4 : 0),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 22, color: ppPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: ppJakarta(16)),
              const SizedBox(height: 2),
              Text(subs, style: ppBody(12)),
            ]),
          ),
          const SizedBox(width: 10),
          const Text('→', style: TextStyle(color: ppMuted)),
        ]),
      ),
    );
  }
}
