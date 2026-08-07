// =============================================================================
//  ParentVeda Products ❤️ - models (a trust-first decision engine)
// -----------------------------------------------------------------------------
//  Not a catalogue: the goal is a confident decision. Every category leads with
//  a 20-second guidance card, then ParentVeda Picks (scored, with the reasons to
//  buy and things to consider visible on the card), then reviews, then browse.
//  Recommendations are pregnancy-stage aware (each item has a "useful during"
//  week window). Commerce (Buy Now) is future affiliate - stubbed for now.
// =============================================================================

import 'package:flutter/foundation.dart';
import '../localization/app_language.dart';

/// The badge a pick carries (🏆 Best Overall, 💰 Best Budget, …).
enum ProductBadge { bestOverall, bestBudget, bestPremium, sensitiveSkin, newborns, none }

@immutable
class ProductReview {
  const ProductReview({
    required this.author,
    required this.role,
    required this.usedDuring,
    required this.liked,
    required this.watchOut,
    this.wouldBuyAgain = true,
  });
  final LocalizedText author;
  final LocalizedText role; // "Mother of Aarav", "First-time mother"
  final LocalizedText usedDuring; // "Week 22 → Delivery"
  final LocalizedText liked;
  final LocalizedText watchOut;
  final bool wouldBuyAgain;
}

@immutable
class ReviewSummary {
  const ReviewSummary({
    required this.mostLoved,
    required this.praise,
    required this.drawback,
    required this.wouldBuyAgainPct,
  });
  final LocalizedText mostLoved;
  final LocalizedText praise;
  final LocalizedText drawback;
  final int wouldBuyAgainPct;
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.emoji,
    required this.summary,
    required this.bestFor,
    required this.price,
    required this.badge,
    required this.score,
    this.why = const [],
    this.consider = const [],
    this.reviewSummary,
    this.reviews = const [],
    this.imageUrl = '',
    this.isAffiliate = false,
  });
  final String id;
  final String categoryId;
  final LocalizedText name;
  final String emoji;
  // Affiliate product (sold elsewhere, e.g. Amazon) → Buy opens the external
  // site, NO in-app cart. ParentVeda products (false) get Add-to-cart + Buy now.
  final bool isAffiliate;
  // Real product photo URL. Empty → callers fall back to a stable placeholder
  // photo (see productImageUrl) or the emoji.
  final String imageUrl;
  final LocalizedText summary; // one line
  final LocalizedText bestFor; // "Most mothers"
  final String price; // "₹1,899"
  final ProductBadge badge;
  final double score; // ParentVeda Score, x/10
  final List<LocalizedText> why; // ✓ up to 3
  final List<LocalizedText> consider; // • up to 2
  final ReviewSummary? reviewSummary;
  final List<ProductReview> reviews;
}

@immutable
class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.guidance,
    required this.lookFor,
    required this.avoid,
    required this.fromWeek,
    required this.toLabel,
    required this.totalCount,
  });
  final String id;
  final LocalizedText name;
  final String emoji;
  final LocalizedText guidance; // one-line decision help
  final List<LocalizedText> lookFor; // ✓
  final List<LocalizedText> avoid; // ✗
  final int fromWeek; // start of "useful during"
  final LocalizedText toLabel; // "Birth" / "Postpartum"
  final int totalCount; // "Browse all 18"

  /// Numeric end week for the relevance timeline.
  // .en: a comparison, not display. Once toLabel widened this read
  // `LocalizedText == String`, which is always false - so every postpartum
  // category quietly ended at week 40 instead of 44. The analyzer reported
  // it as an INFO, not an error, so nothing would have stopped it shipping.
  int get toWeek => toLabel.en == 'Postpartum' ? 44 : 40;

  /// Is this category relevant at [week]?
  bool relevantAt(int week) => week >= fromWeek - 2 && week <= toWeek;
}
