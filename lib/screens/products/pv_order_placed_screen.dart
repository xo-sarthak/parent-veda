// =============================================================================
//  PvOrderPlacedScreen — "Thanks for your order" · View order
// -----------------------------------------------------------------------------
//  7-Eleven / adidas's confirmation: one line of thanks, the reference, what
//  happens next, one button. A PREVIEW order says so in the first sentence —
//  the payment stack was not reachable, no money moved, nothing ships — so a
//  rehearsal can never be mistaken for a purchase.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/pv_order_store.dart';
import '../../theme/pv_fonts.dart';
import 'pv_orders_screen.dart';
import '../v2/v2_palette.dart';
import 'pv_store_chrome.dart';

class PvOrderPlacedScreen extends StatelessWidget {
  const PvOrderPlacedScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final o = PvOrderStore.instance.order(orderId);
    final preview = o?.status == PvOrderStatus.preview;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: preview ? p.surfaceAlt : const Color(0xFFE3F3EA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  preview ? Icons.science_outlined : Icons.check_rounded,
                  size: 32,
                  color: preview ? p.ink2 : pvToneColor(0),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                preview
                    ? 'Preview order placed'
                    : 'Thank you — it\'s on its way',
                style: pvFraunces(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                preview
                    ? 'The payment service isn\'t reachable right now, so no money moved and nothing ships. The order is saved as a rehearsal so you can see the whole flow.'
                    : 'We\'ve confirmed the payment. Your order will be packed and delivered in 3–6 days, and you\'ll get a WhatsApp update when it leaves.',
                style: pvManrope(fontSize: 15, height: 1.5, color: p.ink2),
              ),
              const SizedBox(height: 22),
              if (o != null)
                PvWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _kv(p, 'Reference', o.reference),
                      _kv(p, 'Items', '${o.itemCount}'),
                      _kv(
                        p,
                        'Total',
                        '₹${PvProduct.groupRupees(o.total.round())}',
                      ),
                      _kv(
                        p,
                        'Deliver to',
                        '${o.address.name} · ${o.address.city} ${o.address.pin}',
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              PvCommit(
                label: 'View order',
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => PvOrdersScreen(openId: orderId),
                    settings: const RouteSettings(name: 'store/orders'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).popUntil(
                    (r) =>
                        r.isFirst ||
                        (r.settings.name ?? '').startsWith('store') == false,
                  ),
                  child: Text(
                    'Back to the store',
                    style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.ink2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(V2Palette p, String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(k, style: pvManrope(fontSize: 13, color: p.ink3)),
        ),
        Expanded(
          child: Text(
            v,
            style: pvManrope(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: p.ink1,
            ),
          ),
        ),
      ],
    ),
  );
}
