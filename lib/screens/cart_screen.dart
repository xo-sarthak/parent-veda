// =============================================================================
//  CartScreen - a marketplace-style cart + preview checkout (no real payments)
// -----------------------------------------------------------------------------
//  Shows what the mother has chosen (image, name, size/colour, quantity, unit
//  price, line total), a price summary, and a "Buy now" that leads to a tidy
//  preview checkout ending in a friendly "order placed" - no payment is taken.
//  Reusable helpers expose an add-to-cart flow + a cart icon with a live badge.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../models/product_models.dart';
import '../services/bought_store.dart';
import '../services/cart_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';

const Color _accent = AppTheme.primary500;

void _push(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

// ---------------------------------------------------------------------------
//  Reusable: a cart icon with a count badge for any AppBar.
// ---------------------------------------------------------------------------
Widget cartIconButton(
  BuildContext context,
  PregnancyController controller, {
  required String cartId,
  required String title,
}) {
  return AnimatedBuilder(
    animation: CartStore.instance,
    builder: (context, _) {
      final n = CartStore.instance.count(cartId);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            tooltip: title,
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => _push(
                context,
                CartScreen(
                    controller: controller, cartId: cartId, title: title)),
          ),
          if (n > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: AppTheme.secondary500,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('$n',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ),
            ),
        ],
      );
    },
  );
}

// ---------------------------------------------------------------------------
//  Reusable: add a product to the products cart (with an apparel size step).
// ---------------------------------------------------------------------------
List<String> _sizesForCategory(String catId) {
  switch (catId) {
    case 'maternity_wear':
    case 'nursing_bra':
      return const ['S', 'M', 'L', 'XL'];
    case 'compression_socks':
      return const ['S/M', 'L/XL'];
    case 'swaddle':
      return const ['0–3M', '3–6M'];
    default:
      return const [];
  }
}

Future<void> showAddToCartFlow(
    BuildContext context, PregnancyController controller, Product p,
    {bool openCart = false}) async {
  final s = S(controller.language);
  var size = '';
  final sizes = _sizesForCategory(p.categoryId);
  if (sizes.isNotEmpty) {
    final chosen = await _chooseSize(context, s, sizes);
    if (chosen == null) return; // dismissed
    size = chosen;
  }
  CartStore.instance.add(
    kProductsCartId,
    productId: p.id,
    name: p.name,
    emoji: p.emoji,
    unitPrice: parsePriceString(p.price),
    size: size,
  );
  if (!context.mounted) return;
  if (openCart) {
    _push(
        context,
        CartScreen(
            controller: controller,
            cartId: kProductsCartId,
            title: s.cartProductsTitle));
    return;
  }
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(s.cartAddedToCart),
      action: SnackBarAction(
        label: s.cartViewCart,
        onPressed: () => _push(
            context,
            CartScreen(
                controller: controller,
                cartId: kProductsCartId,
                title: s.cartProductsTitle)),
      ),
    ));
}

Future<String?> _chooseSize(BuildContext context, S s, List<String> sizes) {
  final text = Theme.of(context).textTheme;
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.cartChooseSize,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final sz in sizes)
                  ActionChip(
                    label: Text(sz,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    backgroundColor: _accent.withValues(alpha: 0.08),
                    side: BorderSide(color: _accent.withValues(alpha: 0.4)),
                    onPressed: () => Navigator.of(c).pop(sz),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// ===========================================================================
//  Cart screen
// ===========================================================================

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.controller,
    required this.cartId,
    required this.title,
  });
  final PregnancyController controller;
  final String cartId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(title: Text(title)),
      body: AnimatedBuilder(
        animation: CartStore.instance,
        builder: (context, _) {
          final items = CartStore.instance.items(cartId);
          if (items.isEmpty) return _empty(context, s);
          final subtotal = CartStore.instance.subtotal(cartId);
          return Column(children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                children: [
                  Text(s.cartItems(items.length),
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: AppTheme.neutral500)),
                  const SizedBox(height: 10),
                  for (final it in items) _row(context, s, it),
                ],
              ),
            ),
            _summary(context, s, subtotal),
          ]);
        },
      ),
    );
  }

  Widget _empty(BuildContext context, S s) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 38, color: _accent),
            ),
            const SizedBox(height: 16),
            Text(s.cartEmpty,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(s.cartEmptyHint,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: AppTheme.neutral600)),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, S s, CartItem it) {
    final text = Theme.of(context).textTheme;
    final store = CartStore.instance;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14)),
          child: Text(it.emoji, style: const TextStyle(fontSize: 30)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(it.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              ),
              InkWell(
                onTap: () => store.remove(cartId, it.lineId),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: AppTheme.neutral500),
                ),
              ),
            ]),
            if (it.size.isNotEmpty || it.color.isNotEmpty) ...[
              const SizedBox(height: 5),
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (it.size.isNotEmpty) _variantChip('${s.cartSize}: ${it.size}'),
                if (it.color.isNotEmpty)
                  _variantChip('${s.cartColor}: ${it.color}'),
              ]),
            ],
            const SizedBox(height: 8),
            Row(children: [
              _stepper(it),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(formatINR(it.lineTotal),
                    style:
                        text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                if (it.qty > 1)
                  Text('${formatINR(it.unitPrice)} ${s.cartEach}',
                      style: text.labelSmall
                          ?.copyWith(color: AppTheme.neutral500)),
              ]),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _variantChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutral600)),
      );

  Widget _stepper(CartItem it) {
    final store = CartStore.instance;
    Widget btn(IconData ic, VoidCallback onTap) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(ic, size: 17, color: _accent),
          ),
        );
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        btn(Icons.remove_rounded,
            () => store.setQty(cartId, it.lineId, it.qty - 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('${it.qty}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        btn(Icons.add_rounded,
            () => store.setQty(cartId, it.lineId, it.qty + 1)),
      ]),
    );
  }

  Widget _summary(BuildContext context, S s, double subtotal) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
          18, 16, 18, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary900.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _kv(context, s.cartSubtotal, formatINR(subtotal)),
        const SizedBox(height: 6),
        _kv(context, s.cartDelivery, s.cartFree,
            valueColor: const Color(0xFF3FA56A)),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1)),
        _kv(context, s.cartTotal, formatINR(subtotal), bold: true),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _push(
                context,
                _CheckoutScreen(
                    controller: controller, cartId: cartId, title: title)),
            child: Text(s.cartBuyNow,
                style: text.titleSmall
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}

Widget _kv(BuildContext context, String k, String v,
    {bool bold = false, Color? valueColor}) {
  final text = Theme.of(context).textTheme;
  return Row(children: [
    Text(k,
        style: bold
            ? text.titleMedium?.copyWith(fontWeight: FontWeight.w800)
            : text.bodyMedium?.copyWith(color: AppTheme.neutral600)),
    const Spacer(),
    Text(v,
        style: bold
            ? text.titleMedium?.copyWith(fontWeight: FontWeight.w800)
            : text.bodyMedium?.copyWith(
                color: valueColor ?? AppTheme.neutral800,
                fontWeight: FontWeight.w700)),
  ]);
}

// ---------------------------------------------------------------------------
//  Reusable: single-item "Buy now" → the same preview checkout, for ONE product
//  (ParentVeda products only; affiliate products go to Amazon instead). Uses a
//  throwaway one-item cart so the real cart is left untouched.
// ---------------------------------------------------------------------------
const String kBuyNowCartId = 'buyNow';

void showSingleItemBuyNow(
    BuildContext context, PregnancyController controller, Product p) {
  final s = S(controller.language);
  CartStore.instance.clear(kBuyNowCartId);
  CartStore.instance.add(
    kBuyNowCartId,
    productId: p.id,
    name: p.name,
    emoji: p.emoji,
    unitPrice: parsePriceString(p.price),
  );
  _push(
      context,
      _CheckoutScreen(
          controller: controller,
          cartId: kBuyNowCartId,
          title: s.cartProductsTitle));
}

/// Buy-now for a RAW catalogue line (e.g. a hospital-bag ParentVeda product),
/// not tied to the [Product] model. Reuses the preview checkout; once the order
/// is "placed", the [productId] is marked in BoughtStore.
void showSingleBuyNow(
  BuildContext context,
  PregnancyController controller, {
  required String productId,
  required String name,
  required String emoji,
  required double unitPrice,
  String? title,
}) {
  final s = S(controller.language);
  CartStore.instance.clear(kBuyNowCartId);
  CartStore.instance.add(
    kBuyNowCartId,
    productId: productId,
    name: name,
    emoji: emoji,
    unitPrice: unitPrice,
  );
  _push(
      context,
      _CheckoutScreen(
          controller: controller,
          cartId: kBuyNowCartId,
          title: title ?? s.cartProductsTitle));
}

// ===========================================================================
//  Preview checkout
// ===========================================================================

class _CheckoutScreen extends StatefulWidget {
  const _CheckoutScreen(
      {required this.controller, required this.cartId, required this.title});
  final PregnancyController controller;
  final String cartId;
  final String title;
  @override
  State<_CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<_CheckoutScreen> {
  bool _placed = false;

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final text = Theme.of(context).textTheme;
    final items = CartStore.instance.items(widget.cartId);
    final subtotal = CartStore.instance.subtotal(widget.cartId);
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(title: Text(s.cartCheckout)),
      body: _placed
          ? _placedView(context, s)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: [
                _card(context, [
                  Row(children: [
                    const Icon(Icons.location_on_outlined, color: _accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.cartDeliverTo,
                                style: text.labelSmall?.copyWith(
                                    color: AppTheme.neutral500,
                                    fontWeight: FontWeight.w700)),
                            Text(s.cartDeliverToValue,
                                style: text.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                          ]),
                    ),
                    Text(s.cartChange,
                        style: text.labelMedium?.copyWith(
                            color: _accent, fontWeight: FontWeight.w800)),
                  ]),
                ]),
                const SizedBox(height: 14),
                Text(s.cartOrderSummary,
                    style:
                        text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                for (final it in items) _summaryItem(context, it),
                const SizedBox(height: 12),
                _card(context, [
                  _kv(context, s.cartSubtotal, formatINR(subtotal)),
                  const SizedBox(height: 6),
                  _kv(context, s.cartDelivery, s.cartFree,
                      valueColor: const Color(0xFF3FA56A)),
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1)),
                  _kv(context, s.cartTotal, formatINR(subtotal), bold: true),
                ]),
                const SizedBox(height: 12),
                _card(context, [
                  Row(children: [
                    const Icon(Icons.payments_outlined, color: _accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s.cartPaymentMethod,
                          style: text.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(s.cartComingSoonTag,
                          style: text.labelSmall?.copyWith(
                              color: AppTheme.neutral500,
                              fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      // Remember what was bought so checklists can show
                      // "Already bought ✓" against these products.
                      BoughtStore.instance.markBoughtMany(
                          items.map((it) => it.productId));
                      setState(() => _placed = true);
                    },
                    child: Text('${s.cartPlaceOrder}  ·  ${formatINR(subtotal)}',
                        style: text.titleSmall?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _placedView(BuildContext context, S s) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFF3FA56A).withValues(alpha: 0.12),
                shape: BoxShape.circle),
            child: const Text('🎉', style: TextStyle(fontSize: 42)),
          ),
          const SizedBox(height: 18),
          Text(s.cartOrderPlaced,
              textAlign: TextAlign.center,
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(s.cartOrderPlacedSub,
              textAlign: TextAlign.center,
              style:
                  text.bodyMedium?.copyWith(color: AppTheme.neutral600, height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
              child: Text(s.cartContinueShopping,
                  style: text.titleSmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _summaryItem(BuildContext context, CartItem it) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.outlineVariant)),
          child: Text(it.emoji, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(it.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(
                [
                  '×${it.qty}',
                  if (it.size.isNotEmpty) it.size,
                ].join('  ·  '),
                style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
          ]),
        ),
        Text(formatINR(it.lineTotal),
            style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

Widget _card(BuildContext context, List<Widget> children) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
