// =============================================================================
//  PvReviewsScreen — every parent review, sortable; Target's reviews page
// -----------------------------------------------------------------------------
//  The number, the would-buy-again figure when we have one, then the list
//  with Most helpful / Newest / Critical first. No distribution bars: we do
//  not hold per-star counts, and bars drawn from the handful of reviews we
//  show would look like a measurement of the whole. When the reviews table
//  lands the bars come with it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../theme/pv_fonts.dart';
import 'pv_product_screen.dart' show PvReviewCard;
import 'pv_store_chrome.dart';

enum _Sort { helpful, critical, positive }

class PvReviewsScreen extends StatefulWidget {
  const PvReviewsScreen({super.key, required this.product});
  final PvProduct product;

  @override
  State<PvReviewsScreen> createState() => _PvReviewsScreenState();
}

class _PvReviewsScreenState extends State<PvReviewsScreen> {
  _Sort _sort = _Sort.helpful;

  List<PvParentReview> get _list {
    final l = [...widget.product.reviews];
    switch (_sort) {
      case _Sort.helpful:
        break;
      case _Sort.critical:
        l.sort((a, b) => a.stars.compareTo(b.stars));
      case _Sort.positive:
        l.sort((a, b) => b.stars.compareTo(a.stars));
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final pr = widget.product;
    final list = _list;
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
                      'Reviews',
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pr.name,
                    style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.ink2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (pr.rating > 0)
                        Text(
                          pr.rating.toStringAsFixed(1),
                          style: pvFraunces(
                            fontSize: 48,
                            fontWeight: FontWeight.w500,
                            height: 1,
                            color: p.ink1,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pr.rating > 0)
                            Row(
                              children: [
                                for (var i = 1; i <= 5; i++)
                                  Icon(
                                    i <= pr.rating.round()
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 18,
                                    color: kPvStar,
                                  ),
                              ],
                            ),
                          Text(
                            pr.reviewCount > 0
                                ? '${pr.reviewCount} ratings · ${pr.reviews.length} written'
                                : '${pr.reviews.length} written reviews',
                            style: pvManrope(fontSize: 12.5, color: p.ink3),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (pr.parentsPct != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${pr.parentsPct}%',
                              style: pvFraunces(
                                fontSize: 26,
                                fontWeight: FontWeight.w500,
                                height: 1,
                                color: p.ink1,
                              ),
                            ),
                            Text(
                              'would buy again',
                              style: pvManrope(fontSize: 11.5, color: p.ink3),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      for (final (s, l) in const [
                        (_Sort.helpful, 'Most helpful'),
                        (_Sort.positive, 'Positive'),
                        (_Sort.critical, 'Critical'),
                      ]) ...[
                        PvChip(
                          label: l,
                          selected: _sort == s,
                          onTap: () => setState(() => _sort = s),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (list.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // A white card, not a slab (2026-09-29). Kept for revert: PvWell.
                child: PvCard(
                  child: Text(
                    'No written reviews yet. Parents who buy this on ParentVeda are asked for one two weeks after delivery.',
                    style: pvManrope(
                      fontSize: 13.5,
                      height: 1.5,
                      color: p.ink2,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => PvReviewCard(review: list[i]),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
