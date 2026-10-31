// =============================================================================
//  PartnerOfferCheckout — the partner offer on a checkout sheet (A4, 0149)
// -----------------------------------------------------------------------------
//  One widget for the three places a programme is bought (the Learn review
//  sheet, Parenting's booking sheet, TTC's Prepare page), so the words and the
//  rule are written once.
//
//  It shows ONLY what the server answered (`my_offer_quote`): the list price
//  struck through, the price she pays, "Partner offer applied · 15% off …",
//  and an "Apply offer" row opening her offers for this purchase, the best
//  marked. With no offer it takes no room, and checkout looks exactly as it
//  did before A4.
//
//  Her pick is held in OfferQuoteStore and sent with the order by
//  PaymentService.checkout; the server re-checks it. If the server takes a
//  different offer at Pay (hers ended a second ago), the Razorpay sheet opens
//  with the server's amount, never this widget's.
//
//  No partner colours (D1): ParentVeda ink and grey, passed in by the site so
//  it sits in that stage's palette.
// =============================================================================

import 'package:flutter/material.dart';

import '../booking/offer_quote.dart';
import '../theme/pv_fonts.dart';

/// The pay button's price: the applied offer's price when the server quoted
/// one, else [fallback] (the site's own list-price label).
String partnerOfferPayLabel(String offeringId, String fallback) {
  final m = OfferQuoteStore.instance.payMinorFor(offeringId);
  return m == null ? fallback : offerRupees(m);
}

/// "Partner offer applied · 15% off the back-to-work masterclass".
String partnerOfferAppliedLine(QuotedOffer o) {
  final what = (o.label ?? '').trim();
  return 'Partner offer applied · ${o.off}${what.isEmpty ? '' : ' $what'}';
}

class PartnerOfferCheckout extends StatefulWidget {
  const PartnerOfferCheckout({
    super.key,
    required this.offeringId,
    this.ink = const Color(0xFF201C24),
    this.soft = const Color(0xFF6E6873),
    this.line = const Color(0x1F000000),
    this.padding = EdgeInsets.zero,
  });

  final String offeringId;
  final Color ink;
  final Color soft;
  final Color line;
  final EdgeInsets padding;

  @override
  State<PartnerOfferCheckout> createState() => _PartnerOfferCheckoutState();
}

class _PartnerOfferCheckoutState extends State<PartnerOfferCheckout> {
  @override
  void initState() {
    super.initState();
    // Each opening re-asks: an offer may have started, ended or run out.
    OfferQuoteStore.instance.load(widget.offeringId);
  }

  @override
  Widget build(BuildContext context) {
    final store = OfferQuoteStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final q = store.quoteFor(widget.offeringId);
        final o = store.appliedFor(widget.offeringId);
        if (q == null || o == null) return const SizedBox.shrink();
        return Padding(
          key: const ValueKey('partner_offer_checkout'),
          padding: widget.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                children: [
                  Text(
                    offerRupees(q.listMinor),
                    key: const ValueKey('partner_offer_list_price'),
                    style: pvManrope(
                      fontSize: 13.5,
                      color: widget.soft,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    offerRupees(o.priceMinor),
                    key: const ValueKey('partner_offer_price'),
                    style: pvManrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: widget.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                partnerOfferAppliedLine(o),
                style: pvManrope(
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: widget.ink,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                key: const ValueKey('partner_offer_apply'),
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openList(context, q),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.line),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Apply offer',
                          style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: widget.ink,
                          ),
                        ),
                      ),
                      Text(
                        q.offers.length == 1
                            ? '1 offer'
                            : '${q.offers.length} offers',
                        style: pvManrope(fontSize: 12.5, color: widget.soft),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: widget.soft,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openList(BuildContext context, OfferQuote q) {
    final store = OfferQuoteStore.instance;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final applied = store.appliedFor(widget.offeringId);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your offers',
                  style: pvFraunces(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    color: widget.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'One offer per purchase. The best one is applied for you.',
                  style: pvManrope(fontSize: 12.5, color: widget.soft),
                ),
                const SizedBox(height: 12),
                for (final o in q.offers)
                  InkWell(
                    key: ValueKey('partner_offer_option_${o.code}'),
                    onTap: () {
                      store.pick(widget.offeringId, o.code);
                      Navigator.of(ctx).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            o.code == applied?.code
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 20,
                            color: widget.ink,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${o.off}${(o.label ?? '').isEmpty ? '' : ' ${o.label}'}',
                                  style: pvManrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: widget.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Saves ${offerRupees(o.savingMinor)} · '
                                  'you pay ${offerRupees(o.priceMinor)}',
                                  style: pvManrope(
                                    fontSize: 12.5,
                                    color: widget.soft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (o.code == q.bestCode)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: widget.line),
                              ),
                              child: Text(
                                'Best',
                                style: pvManrope(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: widget.ink,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
