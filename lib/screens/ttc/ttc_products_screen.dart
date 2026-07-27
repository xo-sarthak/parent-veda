// =============================================================================
//  TTC - Products
// -----------------------------------------------------------------------------
//      "Trust before commerce. Recommendations first. Shopping second."
//                                                       - TTC master, §2.14
//
//  Structurally a research page, not a storefront. Every product shows what to
//  look for AND what to watch out for, and the "watch out" is not tucked below
//  a fold - several of these entries exist mainly to talk a couple out of
//  buying something.
//
//  There is no cart and no checkout here. Price ranges are shown so the advice
//  is usable; nothing is sold.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_products_data.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

void openTtcProducts(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcProductsScreen(),
    settings: const RouteSettings(name: 'ttc/products'),
  ));
}

class TtcProductsScreen extends StatefulWidget {
  const TtcProductsScreen({super.key, this.focusId});

  /// A product to scroll to, from an Ask Veda pointer (`ttcprod_folic` →
  /// `folic`). The rest of the library stays on screen - a research page that
  /// narrows to the one thing being pointed at starts to look like a shop.
  final String? focusId;

  @override
  State<TtcProductsScreen> createState() => _TtcProductsScreenState();
}

class _TtcProductsScreenState extends State<TtcProductsScreen> {
  final _focusKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.focusId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _focusKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          alignment: 0.1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcLang.instance,
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(title: t.productsTitle),
                const SizedBox(height: 16),
                Text(t.productsIntro, style: ttcBody(14, h: 1.6)),
                const SizedBox(height: 20),
                for (final (id, en, hiName) in ttcProductCategories) ...[
                  ttcEyebrow(hi ? hiName : en, color: ttcPurple),
                  const SizedBox(height: 11),
                  for (final p in ttcProductsIn(id)) ...[
                    _ProductCard(
                      key: p.id == widget.focusId ? _focusKey : null,
                      product: p,
                      t: t,
                      highlight: p.id == widget.focusId,
                    ),
                    const SizedBox(height: 11),
                  ],
                  const SizedBox(height: 10),
                ],
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(t.productsDisclaimer,
                        style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    super.key,
    required this.product,
    required this.t,
    this.highlight = false,
  });

  final TtcProduct product;
  final TtcS t;

  /// The one Ask Veda pointed at. A quiet border, not a colour change - it says
  /// "this is the one you asked about", not "this one is better".
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return TtcCard(
      border: highlight ? ttcPurple : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(product.name(hi), style: ttcJakarta(16))),
          const SizedBox(width: 10),
          if (product.forPartner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: ttcCoralTint,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(t.forPartnerTag,
                  style: ttcBody(10, color: ttcCoral, w: FontWeight.w800)),
            ),
        ]),
        const SizedBox(height: 8),
        Text(product.why(hi), style: ttcBody(13.5, h: 1.55)),
        const SizedBox(height: 14),

        _block(
          icon: Icons.check_rounded,
          color: ttcPurple,
          label: t.productsLookFor,
          body: product.lookFor(hi),
          tint: ttcPanel,
        ),
        const SizedBox(height: 10),
        // The honesty line, at the same visual weight as the recommendation -
        // never smaller and never below a fold.
        _block(
          icon: Icons.error_outline_rounded,
          color: ttcBrown,
          label: t.productsWatchOut,
          body: product.watchOut(hi),
          tint: const Color(0xFFFDF6EC),
        ),
        const SizedBox(height: 12),
        Text(product.priceEn,
            style: ttcBody(12.5, color: ttcMuted, w: FontWeight.w700)),
      ]),
    );
  }

  Widget _block({
    required IconData icon,
    required Color color,
    required String label,
    required String body,
    required Color tint,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration:
            BoxDecoration(color: tint, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 7),
            Text(label.toUpperCase(),
                style: ttcBody(9.5, color: color, w: FontWeight.w800)),
          ]),
          const SizedBox(height: 7),
          Text(body, style: ttcBody(12.5, color: color, h: 1.55)),
        ]),
      );
}
