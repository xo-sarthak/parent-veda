// =============================================================================
//  PvOrdersScreen — her orders, newest first; tap for the detail
// -----------------------------------------------------------------------------
//  Starlink / Apple Store's orders list: a card per order with the first
//  photo, the reference, the date, the status word, the total. The detail is
//  the receipt: status, lines, address, breakdown. Preview orders are
//  labelled as such everywhere — they are rehearsals, never purchases.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/pv_product.dart';
import '../../services/pv_catalog_store.dart';
import '../../services/pv_order_store.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pv_store_chrome.dart';

class PvOrdersScreen extends StatefulWidget {
  const PvOrdersScreen({super.key, this.openId});

  /// Open this order's detail straight away (from the placed screen).
  final String? openId;

  @override
  State<PvOrdersScreen> createState() => _PvOrdersScreenState();
}

class _PvOrdersScreenState extends State<PvOrdersScreen> {
  @override
  void initState() {
    super.initState();
    PvOrderStore.instance.init();
    if (widget.openId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final o = PvOrderStore.instance.order(widget.openId!);
        if (o != null && mounted) _open(o);
      });
    }
  }

  void _open(PvOrder o) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PvOrderDetailScreen(orderId: o.id),
      settings: RouteSettings(name: 'store/order/${o.id}'),
    ),
  );

  static String _date(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: PvOrderStore.instance,
      builder: (context, _) {
        final orders = PvOrderStore.instance.orders;
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(
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
                          'Your orders',
                          style: pvFraunces(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: p.ink1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (orders.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: PvWell(
                      child: Text(
                        'No orders yet. Anything you buy from ParentVeda shows here with its status.',
                        style: pvManrope(
                          fontSize: 14,
                          height: 1.5,
                          color: p.ink2,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  sliver: SliverList.builder(
                    itemCount: orders.length,
                    itemBuilder: (_, i) => _card(p, orders[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _card(V2Palette p, PvOrder o) {
    final first = o.lines.isEmpty
        ? null
        : PvCatalogStore.instance.byId(o.lines.first.productId);
    final preview = o.status == PvOrderStatus.preview;
    return InkWell(
      onTap: () => _open(o),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPvLine),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: first != null
                  ? PvProductImage(product: first, radius: 12)
                  : PvCoverBlock(
                      hue: 268,
                      name: o.lines.isEmpty ? '?' : o.lines.first.name,
                      radius: 12,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.lines.length == 1
                        ? o.lines.first.name
                        : '${o.lines.first.name} + ${o.lines.length - 1} more',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${o.reference} · ${_date(o.createdAt)}',
                    style: pvManrope(fontSize: 12, color: p.ink3),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: preview
                              ? p.surfaceAlt
                              : const Color(0xFFE3F3EA),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          o.status.label,
                          style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: preview ? p.ink2 : pvToneColor(0),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${PvProduct.groupRupees(o.total.round())}',
                        style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: p.ink1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: p.ink3),
          ],
        ),
      ),
    );
  }
}

class PvOrderDetailScreen extends StatelessWidget {
  const PvOrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final o = PvOrderStore.instance.order(orderId);
    return Scaffold(
      backgroundColor: p.ground,
      body: CustomScrollView(
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
                      o?.reference ?? 'Order',
                      style: pvFraunces(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: p.ink1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (o == null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'This order is not on this phone.',
                  style: pvManrope(fontSize: 14, color: p.ink2),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              sliver: SliverList.list(
                children: [
                  _status(p, o),
                  const SizedBox(height: 12),
                  _box(
                    p,
                    'Items',
                    Column(
                      children: [
                        for (final l in o.lines)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 44,
                                  height: 44,
                                  child:
                                      PvCatalogStore.instance.byId(
                                            l.productId,
                                          ) !=
                                          null
                                      ? PvProductImage(
                                          product: PvCatalogStore.instance.byId(
                                            l.productId,
                                          )!,
                                          radius: 10,
                                        )
                                      : PvCoverBlock(
                                          hue: 268,
                                          name: l.name,
                                          radius: 10,
                                        ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: pvManrope(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: p.ink1,
                                        ),
                                      ),
                                      Text(
                                        '${l.qty} × ₹${PvProduct.groupRupees(l.unitPrice.round())}${l.size.isEmpty ? '' : ' · ${l.size}'}',
                                        style: pvManrope(
                                          fontSize: 12,
                                          color: p.ink3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${PvProduct.groupRupees(l.lineTotal.round())}',
                                  style: pvManrope(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: p.ink1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Divider(height: 12),
                        _sum(
                          p,
                          'Subtotal',
                          '₹${PvProduct.groupRupees(o.subtotal.round())}',
                        ),
                        _sum(
                          p,
                          'Delivery',
                          o.delivery == 0 ? 'Free' : '₹${o.delivery.round()}',
                        ),
                        _sum(
                          p,
                          'Total',
                          '₹${PvProduct.groupRupees(o.total.round())}',
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _box(
                    p,
                    'Delivering to',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.address.name,
                          style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: p.ink1,
                          ),
                        ),
                        Text(
                          o.address.oneLine,
                          style: pvManrope(
                            fontSize: 13,
                            height: 1.4,
                            color: p.ink2,
                          ),
                        ),
                        Text(
                          o.address.phone,
                          style: pvManrope(fontSize: 12.5, color: p.ink3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (o.paymentId.isNotEmpty)
                    _box(
                      p,
                      'Payment',
                      Text(
                        'Razorpay · ${o.paymentId}',
                        style: pvManrope(fontSize: 13, color: p.ink2),
                      ),
                    ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: o.reference));
                      pvSnack(
                        context,
                        'Reference ${o.reference} copied — quote it to support.',
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kPvLine),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            size: 18,
                            color: p.ink2,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Questions about this order? Copy the reference',
                              style: pvManrope(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: p.ink1,
                              ),
                            ),
                          ),
                          Icon(Icons.copy_rounded, size: 16, color: p.ink3),
                        ],
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

  Widget _status(V2Palette p, PvOrder o) {
    final preview = o.status == PvOrderStatus.preview;
    final paid = o.status == PvOrderStatus.paid;
    return PvWell(
      tint: preview ? p.surfaceAlt : const Color(0xFFE3F3EA),
      child: Row(
        children: [
          Icon(
            preview
                ? Icons.science_outlined
                : paid
                ? Icons.check_circle_rounded
                : Icons.schedule_rounded,
            size: 22,
            color: preview ? p.ink2 : pvToneColor(0),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.status.label,
                  style: pvManrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: p.ink1,
                  ),
                ),
                Text(
                  preview
                      ? 'A rehearsal — no money moved and nothing ships.'
                      : paid
                      ? 'Payment verified. Packing now; delivery in 3–6 days.'
                      : 'Waiting for the payment to confirm.',
                  style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(V2Palette p, String title, Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kPvLine),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: pvManrope(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: p.ink3,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );

  Widget _sum(V2Palette p, String k, String v, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            k,
            style: pvManrope(
              fontSize: 13.5,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: bold ? p.ink1 : p.ink2,
            ),
          ),
        ),
        Text(
          v,
          style: pvManrope(
            fontSize: bold ? 16 : 13.5,
            fontWeight: FontWeight.w800,
            color: p.ink1,
          ),
        ),
      ],
    ),
  );
}
