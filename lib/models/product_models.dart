// =============================================================================
//  ParentVeda Products ❤️ — models (a trust-first decision engine)
// -----------------------------------------------------------------------------
//  Not a catalogue: the goal is a confident decision. Every category leads with
//  a 20-second guidance card, then ParentVeda Picks (scored, with the reasons to
//  buy and things to consider visible on the card), then reviews, then browse.
//  Recommendations are pregnancy-stage aware (each item has a "useful during"
//  week window). Commerce (Buy Now) is future affiliate — stubbed for now.
// =============================================================================

import 'package:flutter/foundation.dart';

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
  final String author;
  final String role; // "Mother of Aarav", "First-time mother"
  final String usedDuring; // "Week 22 → Delivery"
  final String liked;
  final String watchOut;
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
  final String mostLoved;
  final String praise;
  final String drawback;
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
  });
  final String id;
  final String categoryId;
  final String name;
  final String emoji;
  final String summary; // one line
  final String bestFor; // "Most mothers"
  final String price; // "₹1,899"
  final ProductBadge badge;
  final double score; // ParentVeda Score, x/10
  final List<String> why; // ✓ up to 3
  final List<String> consider; // • up to 2
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
  final String name;
  final String emoji;
  final String guidance; // one-line decision help
  final List<String> lookFor; // ✓
  final List<String> avoid; // ✗
  final int fromWeek; // start of "useful during"
  final String toLabel; // "Birth" / "Postpartum"
  final int totalCount; // "Browse all 18"

  /// Numeric end week for the relevance timeline.
  int get toWeek => toLabel == 'Postpartum' ? 44 : 40;

  /// Is this category relevant at [week]?
  bool relevantAt(int week) => week >= fromWeek - 2 && week <= toWeek;
}
