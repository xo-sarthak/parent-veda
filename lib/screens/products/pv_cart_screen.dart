// =============================================================================
//  PvCartScreen — the bag
// -----------------------------------------------------------------------------
//  foodpanda / adidas / Zara's bag: lines with a stepper, a free-delivery
//  nudge that tells the truth ("₹250 more for free delivery"), the total, and
//  ONE commit — "Review address and payment". Nothing sells here; the bag is
//  a list she edits.
//
//  Reads `CartStore` (kProductsCartId) — the cart that already existed — with
//  the photo it gained today. An empty bag is an invitation, not a blank.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/cart_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../services/pv_order_store.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pv_checkout_screen.dart';
import 'pv_store_chrome.dart';

class PvCartScreen extends StatelessWidget {
  const PvCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    // The "Added to your cart" snack is app-level and would cover this
    // screen's commit button; the bag IS the confirmation, so clear it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) ScaffoldMessenger.of(context).clearSnackBars();
    });
    return ListenableBuilder(
      listenable: CartStore.instance,
      builder: (context, _) {
        final cart = CartStore.instance;
        final lines = cart.items(kProductsCartId);
        final subtotal = cart.subtotal(kProductsCartId);
        final delivery = PvOrderStore.deliveryFor(subtotal);
        final toFree = PvOrderStore.freeDeliveryAbove - subtotal;
        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        MediaQuery.of(context).padding.top + 10,
                        16,
                        8,
                      ),
                      child: Row(
                        children: [
                          PvRoundIcon(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              // One name, "cart", everywhere in the store
                              // (2026-09-29). Kept for revert: 'Your bag'.
                              'Your cart',
                              style: pvFraunces(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: p.ink1,
                              ),
                            ),
                          ),
                          Text(
                            '${cart.count(kProductsCartId)} ${cart.count(kProductsCartId) == 1 ? 'item' : 'items'}',
                            style: pvManrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: p.ink3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (lines.isEmpty)
                    SliverToBoxAdapter(child: _empty(context, p))
                  else ...[
                    if (toFree > 0)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${PvProduct.groupRupees(toFree.round())} more for free delivery',
                                style: pvManrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: p.ink1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value:
                                      (subtotal /
                                              PvOrderStore.freeDeliveryAbove)
                                          .clamp(0, 1),
                                  minHeight: 4,
                                  backgroundColor: p.surfaceAlt,
                                  color: kPvInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: pvToneColor(0),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'You\'ve got free delivery',
                                style: pvManrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: pvToneColor(0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      sliver: SliverList.builder(
                        itemCount: lines.length,
                        itemBuilder: (_, i) => _line(context, p, lines[i]),
                      ),
                    ),
                    SliverToBoxAdapter(child: _summary(p, subtotal, delivery)),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
              if (lines.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      MediaQuery.of(context).padding.bottom + 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: kPvLine)),
                    ),
                    child: PvCommit(
                      label: 'Review address and payment',
                      trailing:
                          '₹${PvProduct.groupRupees((subtotal + delivery).round())}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PvCheckoutScreen(),
                          settings: const RouteSettings(name: 'store/checkout'),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _empty(BuildContext context, V2Palette p) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // Kept for revert: 'Nothing in your bag yet.'
          'Nothing in your cart yet.',
          style: pvFraunces(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Products that ship from ParentVeda land here. Affiliate products open the retailer instead — the product page says which.',
          style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
        ),
        const SizedBox(height: 18),
        PvSecondary(
          label: 'Back to the store',
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ],
    ),
  );

  Widget _line(BuildContext context, V2Palette p, CartItem l) {
    final product = PvCatalogStore.instance.byId(l.productId);
    final cart = CartStore.instance;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: product != null
                ? InkWell(
                    onTap: () => pvOpenProduct(context, product),
                    child: PvProductImage(product: product, radius: 14),
                  )
                : PvCoverBlock(hue: 268, name: l.name, radius: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: p.ink1,
                  ),
                ),
                if (l.size.isNotEmpty)
                  Text(l.size, style: pvManrope(fontSize: 12.5, color: p.ink3)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '₹${PvProduct.groupRupees(l.lineTotal.round())}',
                      style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: p.ink1,
                      ),
                    ),
                    const Spacer(),
                    _stepper(
                      p,
                      l.qty,
                      (q) => cart.setQty(kProductsCartId, l.lineId, q),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => cart.remove(kProductsCartId, l.lineId),
                  child: Text(
                    'Remove',
                    style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepper(V2Palette p, int qty, ValueChanged<int> set) => Container(
    height: 34,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: kPvLine),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepBtn(p, Icons.remove_rounded, () => set(qty - 1)),
        SizedBox(
          width: 28,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: pvManrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: p.ink1,
            ),
          ),
        ),
        _stepBtn(p, Icons.add_rounded, () => set(qty + 1)),
      ],
    ),
  );

  Widget _stepBtn(V2Palette p, IconData i, VoidCallback f) => InkWell(
    onTap: f,
    borderRadius: BorderRadius.circular(999),
    child: SizedBox(
      width: 34,
      height: 34,
      child: Icon(i, size: 18, color: p.ink1),
    ),
  );

  Widget _summary(V2Palette p, double subtotal, double delivery) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
    // A white card, not a slab (2026-09-29). Kept for revert: PvWell.
    child: PvCard(
      child: Column(
        children: [
          _sumRow(p, 'Subtotal', '₹${PvProduct.groupRupees(subtotal.round())}'),
          _sumRow(
            p,
            'Delivery',
            delivery == 0 ? 'Free' : '₹${delivery.round()}',
          ),
          const Divider(height: 18),
          _sumRow(
            p,
            'Total',
            '₹${PvProduct.groupRupees((subtotal + delivery).round())}',
            bold: true,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Inclusive of taxes. Paid securely through Razorpay.',
              style: pvManrope(fontSize: 11.5, color: p.ink3),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _sumRow(V2Palette p, String k, String v, {bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                k,
                style: pvManrope(
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                  color: bold ? p.ink1 : p.ink2,
                ),
              ),
            ),
            Text(
              v,
              style: pvManrope(
                fontSize: bold ? 17 : 14,
                fontWeight: FontWeight.w800,
                color: p.ink1,
              ),
            ),
          ],
        ),
      );
}
