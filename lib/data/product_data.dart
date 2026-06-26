// =============================================================================
//  ParentVeda Products ❤️ — seed data (decision-engine prototype)
// -----------------------------------------------------------------------------
//  Pregnancy-stage-aware categories, each with a guidance card and 3 scored
//  ParentVeda Picks (Best Overall / Budget / Premium / etc.) carrying the
//  reasons-to-buy + things-to-consider. Prices and scores are illustrative,
//  pending real expert + parent data. English-first.
// =============================================================================

import '../models/product_models.dart';

const List<ProductCategory> kProductCategories = [
  ProductCategory(
    id: 'pregnancy_pillow',
    name: 'Pregnancy Pillow',
    emoji: '🛏️',
    guidance: 'A good pregnancy pillow supports your bump, back and knees at the same time.',
    lookFor: ['Full-body support', 'Washable cover', 'Holds its shape over time'],
    avoid: ['Pillows that flatten quickly', 'Very bulky designs for a small bed'],
    fromWeek: 16,
    toLabel: 'Birth',
    totalCount: 18,
  ),
  ProductCategory(
    id: 'stretch_care',
    name: 'Stretch Mark Care',
    emoji: '🧴',
    guidance: 'Daily moisturising keeps skin supple as your bump grows — consistency matters more than the brand.',
    lookFor: ['Deeply moisturising', 'Fragrance-free', 'Non-sticky finish'],
    avoid: ['Strong fragrances', 'Retinol-based creams'],
    fromWeek: 12,
    toLabel: 'Birth',
    totalCount: 14,
  ),
  ProductCategory(
    id: 'maternity_wear',
    name: 'Maternity Wear',
    emoji: '👗',
    guidance: 'Look for room to grow and soft, breathable fabric you can keep wearing past delivery.',
    lookFor: ['Stretchable over-bump fit', 'Breathable cotton', 'Nursing-friendly'],
    avoid: ['Tight elastic waistbands', 'Synthetic-only fabric'],
    fromWeek: 14,
    toLabel: 'Birth',
    totalCount: 22,
  ),
  ProductCategory(
    id: 'belly_band',
    name: 'Belly Support Band',
    emoji: '🤰',
    guidance: 'A support band can ease back and bump strain later on — fit and adjustability matter most.',
    lookFor: ['Adjustable gentle support', 'Breathable material', 'Eases back strain'],
    avoid: ['Bands that are too tight', 'Non-breathable nylon'],
    fromWeek: 20,
    toLabel: 'Birth',
    totalCount: 9,
  ),
  ProductCategory(
    id: 'compression_socks',
    name: 'Compression Socks',
    emoji: '🧦',
    guidance: 'Compression socks help with swelling and tired legs — graduated compression is the key feature.',
    lookFor: ['Graduated compression', 'Breathable knit', 'Easy to pull on'],
    avoid: ['Very tight tops', 'Rough seams'],
    fromWeek: 20,
    toLabel: 'Birth',
    totalCount: 7,
  ),
  ProductCategory(
    id: 'nursing_bra',
    name: 'Nursing Bra',
    emoji: '👚',
    guidance: 'Comfort and easy one-hand opening matter most — get sized later in pregnancy.',
    lookFor: ['Soft wireless support', 'Easy clip-down', 'Breathable fabric'],
    avoid: ['Underwire that digs in', 'Tight bands'],
    fromWeek: 30,
    toLabel: 'Postpartum',
    totalCount: 16,
  ),
  ProductCategory(
    id: 'breast_pump',
    name: 'Breast Pump',
    emoji: '🍼',
    guidance: 'Think about how often you will pump — occasional use suits manual, regular use suits electric.',
    lookFor: ['Comfortable flange fit', 'Quiet motor', 'Easy to clean'],
    avoid: ['Hard-to-clean parts', 'Very loud motors'],
    fromWeek: 34,
    toLabel: 'Postpartum',
    totalCount: 12,
  ),
  ProductCategory(
    id: 'swaddle',
    name: 'Swaddles',
    emoji: '👶',
    guidance: 'Soft, breathable fabric and the right size keep your newborn snug and safe.',
    lookFor: ['Breathable muslin or cotton', 'Right newborn size', 'Easy to wrap'],
    avoid: ['Thick, overheating fabric', 'Wraps that come loose'],
    fromWeek: 34,
    toLabel: 'Postpartum',
    totalCount: 11,
  ),
];

const List<Product> kProducts = [
  // --- Pregnancy Pillow ---
  Product(
    id: 'pp_overall',
    categoryId: 'pregnancy_pillow',
    name: 'ComfyBump Full-Body Pillow',
    emoji: '🛏️',
    summary: 'U-shaped support for bump, back and knees in one.',
    bestFor: 'Most mothers',
    price: '₹2,499',
    badge: ProductBadge.bestOverall,
    score: 9.1,
    why: ['Excellent full-body support', 'Soft, washable cover', 'Holds its shape over time'],
    consider: ['Takes more bed space', 'Slightly heavy to move'],
    reviewSummary: ReviewSummary(
      mostLoved: 'Excellent side-sleeping support.',
      praise: 'Comfortable and durable.',
      drawback: 'Needs a bit more bed space.',
      wouldBuyAgainPct: 92,
    ),
    reviews: [
      ProductReview(
        author: 'Neha',
        role: 'Mother of Aarav',
        usedDuring: 'Week 22 → Delivery',
        liked: 'Excellent support — my back pain eased a lot at night.',
        watchOut: 'Requires a larger bed.',
      ),
      ProductReview(
        author: 'Pooja',
        role: 'First-time mother',
        usedDuring: 'Week 24 → Delivery',
        liked: 'Stayed supportive right through pregnancy.',
        watchOut: 'Takes a few nights to get used to.',
      ),
    ],
  ),
  Product(
    id: 'pp_budget',
    categoryId: 'pregnancy_pillow',
    name: 'Snug Wedge Pillow',
    emoji: '🛏️',
    summary: 'Compact wedge that supports the bump where you need it.',
    bestFor: 'Small beds and budgets',
    price: '₹699',
    badge: ProductBadge.bestBudget,
    score: 8.2,
    why: ['Very affordable', 'Compact and light', 'Good targeted bump support'],
    consider: ['Less full-body support', 'Cover is not removable'],
  ),
  Product(
    id: 'pp_premium',
    categoryId: 'pregnancy_pillow',
    name: 'CloudNest Adjustable Pillow',
    emoji: '🛏️',
    summary: 'Adjustable filling and a premium cover for tailored support.',
    bestFor: 'Those who want the best',
    price: '₹4,299',
    badge: ProductBadge.bestPremium,
    score: 9.0,
    why: ['Adjustable firmness', 'Premium breathable cover', 'Very durable'],
    consider: ['Premium price', 'Large to store'],
  ),
  // --- Stretch Mark Care ---
  Product(
    id: 'sc_overall',
    categoryId: 'stretch_care',
    name: 'VedaGlow Belly Butter',
    emoji: '🧴',
    summary: 'Rich, fragrance-free butter that absorbs without stickiness.',
    bestFor: 'Daily use',
    price: '₹549',
    badge: ProductBadge.bestOverall,
    score: 8.9,
    why: ['Deeply moisturising', 'Fragrance-free', 'Non-sticky finish'],
    consider: ['Jar can be a little messy', 'Works best with daily use'],
    reviewSummary: ReviewSummary(
      mostLoved: 'How well it absorbs.',
      praise: 'Skin felt soft and supple.',
      drawback: 'You have to be consistent.',
      wouldBuyAgainPct: 90,
    ),
  ),
  Product(
    id: 'sc_sensitive',
    categoryId: 'stretch_care',
    name: 'PureSkin Calm Oil',
    emoji: '🧴',
    summary: 'Gentle plant oil for reactive, sensitive skin.',
    bestFor: 'Sensitive skin',
    price: '₹699',
    badge: ProductBadge.sensitiveSkin,
    score: 8.6,
    why: ['Minimal ingredients', 'Soothing on sensitive skin', 'Lightweight'],
    consider: ['Oily feel for some', 'Mild natural scent'],
  ),
  Product(
    id: 'sc_budget',
    categoryId: 'stretch_care',
    name: 'EverySoft Lotion',
    emoji: '🧴',
    summary: 'Everyday moisturiser at a friendly price.',
    bestFor: 'Budgets',
    price: '₹299',
    badge: ProductBadge.bestBudget,
    score: 8.0,
    why: ['Very affordable', 'Easy daily texture', 'Widely available'],
    consider: ['Lighter moisturisation', 'Contains a light fragrance'],
  ),
  // --- Maternity Wear ---
  Product(
    id: 'mw_overall',
    categoryId: 'maternity_wear',
    name: 'EasyGrow Maternity Leggings',
    emoji: '👗',
    summary: 'Soft over-bump leggings that stretch with you.',
    bestFor: 'Everyday comfort',
    price: '₹899',
    badge: ProductBadge.bestOverall,
    score: 8.8,
    why: ['Stretchy over-bump fit', 'Breathable cotton blend', 'Wearable after delivery too'],
    consider: ['Limited colours', 'May need a size up late on'],
  ),
  Product(
    id: 'mw_premium',
    categoryId: 'maternity_wear',
    name: 'Bloom Nursing Dress',
    emoji: '👗',
    summary: 'Elegant dress with discreet nursing access.',
    bestFor: 'Special days and nursing',
    price: '₹1,999',
    badge: ProductBadge.bestPremium,
    score: 8.7,
    why: ['Nursing-friendly', 'Premium fabric', 'Flattering fit'],
    consider: ['Higher price', 'Gentle wash only'],
  ),
  Product(
    id: 'mw_budget',
    categoryId: 'maternity_wear',
    name: 'DailyEase Maternity Kurti',
    emoji: '👗',
    summary: 'Roomy, breathable kurti for everyday wear.',
    bestFor: 'Budgets',
    price: '₹599',
    badge: ProductBadge.bestBudget,
    score: 8.1,
    why: ['Affordable', 'Airy and roomy', 'Easy to wash'],
    consider: ['Basic styling', 'Fabric thins over time'],
  ),
  // --- Belly Support Band ---
  Product(
    id: 'bb_overall',
    categoryId: 'belly_band',
    name: 'SteadyBump Support Band',
    emoji: '🤰',
    summary: 'Adjustable band that eases bump and back strain.',
    bestFor: 'Back relief',
    price: '₹799',
    badge: ProductBadge.bestOverall,
    score: 8.7,
    why: ['Adjustable gentle support', 'Breathable panel', 'Eases back strain'],
    consider: ['Visible under fitted clothes', 'Needs the right size'],
  ),
  Product(
    id: 'bb_budget',
    categoryId: 'belly_band',
    name: 'LiteHold Belly Band',
    emoji: '🤰',
    summary: 'Simple, low-cost everyday support.',
    bestFor: 'Budgets',
    price: '₹399',
    badge: ProductBadge.bestBudget,
    score: 7.9,
    why: ['Very affordable', 'Light and simple', 'Easy to wear'],
    consider: ['Less adjustable', 'Thinner material'],
  ),
  Product(
    id: 'bb_premium',
    categoryId: 'belly_band',
    name: 'FlexCore Maternity Belt',
    emoji: '🤰',
    summary: 'Firmer, contoured support for active days.',
    bestFor: 'Active mothers',
    price: '₹1,299',
    badge: ProductBadge.bestPremium,
    score: 8.6,
    why: ['Firm contoured support', 'Durable build', 'Good for activity'],
    consider: ['Warmer to wear', 'Premium price'],
  ),
  // --- Compression Socks ---
  Product(
    id: 'cs_overall',
    categoryId: 'compression_socks',
    name: 'FreshStep Compression Socks',
    emoji: '🧦',
    summary: 'Graduated compression for swelling and tired legs.',
    bestFor: 'Daily swelling',
    price: '₹599',
    badge: ProductBadge.bestOverall,
    score: 8.6,
    why: ['Graduated compression', 'Breathable knit', 'Easy to pull on'],
    consider: ['Snug to put on', 'Hand wash is best'],
  ),
  Product(
    id: 'cs_budget',
    categoryId: 'compression_socks',
    name: 'DayLite Support Socks',
    emoji: '🧦',
    summary: 'Light support at an easy price.',
    bestFor: 'Budgets',
    price: '₹299',
    badge: ProductBadge.bestBudget,
    score: 7.8,
    why: ['Affordable', 'Comfortable knit', 'Good for short days'],
    consider: ['Milder compression', 'Fewer sizes'],
  ),
  Product(
    id: 'cs_premium',
    categoryId: 'compression_socks',
    name: 'AeroFlow Medical Socks',
    emoji: '🧦',
    summary: 'Medical-grade compression for all-day wear.',
    bestFor: 'Long days on your feet',
    price: '₹1,099',
    badge: ProductBadge.bestPremium,
    score: 8.7,
    why: ['Strong graduated support', 'All-day comfort', 'Durable'],
    consider: ['Firmer to put on', 'Premium price'],
  ),
  // --- Nursing Bra ---
  Product(
    id: 'nb_overall',
    categoryId: 'nursing_bra',
    name: 'SoftClip Nursing Bra',
    emoji: '👚',
    summary: 'Wireless support with easy one-hand clips.',
    bestFor: 'Everyday comfort',
    price: '₹699',
    badge: ProductBadge.bestOverall,
    score: 8.8,
    why: ['Soft wireless support', 'Easy clip-down', 'Breathable cotton'],
    consider: ['Size changes after birth', 'Plain design'],
  ),
  Product(
    id: 'nb_budget',
    categoryId: 'nursing_bra',
    name: 'DayEase Nursing Bra',
    emoji: '👚',
    summary: 'Comfortable basics at a friendly price.',
    bestFor: 'Budgets',
    price: '₹399',
    badge: ProductBadge.bestBudget,
    score: 8.0,
    why: ['Affordable multipacks', 'Soft fabric', 'Easy care'],
    consider: ['Lighter support', 'Fewer sizes'],
  ),
  Product(
    id: 'nb_premium',
    categoryId: 'nursing_bra',
    name: 'Bloom Seamless Nursing Bra',
    emoji: '👚',
    summary: 'Seamless premium comfort for day and night.',
    bestFor: 'All-day wear',
    price: '₹1,199',
    badge: ProductBadge.bestPremium,
    score: 8.7,
    why: ['Seamless comfort', 'Great support', 'Soft premium fabric'],
    consider: ['Premium price', 'Hand wash preferred'],
  ),
  // --- Breast Pump ---
  Product(
    id: 'bp_overall',
    categoryId: 'breast_pump',
    name: 'GentleFlow Electric Pump',
    emoji: '🍼',
    summary: 'Quiet electric pump with a comfortable fit.',
    bestFor: 'Regular pumping',
    price: '₹4,999',
    badge: ProductBadge.bestOverall,
    score: 9.0,
    why: ['Quiet motor', 'Comfortable flange fit', 'Easy to clean'],
    consider: ['Higher price', 'Needs charging'],
    reviewSummary: ReviewSummary(
      mostLoved: 'How quiet it is.',
      praise: 'Comfortable and efficient.',
      drawback: 'Remember to keep it charged.',
      wouldBuyAgainPct: 88,
    ),
    reviews: [
      ProductReview(
        author: 'Simran',
        role: 'Working mother',
        usedDuring: 'Week 36 → Postpartum',
        liked: 'Quiet enough to pump discreetly at work.',
        watchOut: 'Carry the charger with you.',
      ),
    ],
  ),
  Product(
    id: 'bp_budget',
    categoryId: 'breast_pump',
    name: 'EasyHand Manual Pump',
    emoji: '🍼',
    summary: 'Simple manual pump for occasional use.',
    bestFor: 'Occasional use',
    price: '₹999',
    badge: ProductBadge.bestBudget,
    score: 8.3,
    why: ['Very affordable', 'No power needed', 'Light to carry'],
    consider: ['Manual effort', 'Slower than electric'],
  ),
  Product(
    id: 'bp_premium',
    categoryId: 'breast_pump',
    name: 'DualEase Double Pump',
    emoji: '🍼',
    summary: 'Hospital-grade double pump to save time.',
    bestFor: 'Frequent pumping',
    price: '₹8,999',
    badge: ProductBadge.bestPremium,
    score: 8.9,
    why: ['Double pumping saves time', 'Strong, adjustable suction', 'Durable'],
    consider: ['Expensive', 'More parts to clean'],
  ),
  // --- Swaddles ---
  Product(
    id: 'sw_overall',
    categoryId: 'swaddle',
    name: 'DreamWrap Muslin Swaddle',
    emoji: '👶',
    summary: 'Breathable muslin that keeps newborns snug.',
    bestFor: 'Newborns',
    price: '₹799',
    badge: ProductBadge.newborns,
    score: 8.9,
    why: ['Breathable muslin', 'Right newborn size', 'Soft on skin'],
    consider: ['Needs re-wrapping', 'Sold in small packs'],
  ),
  Product(
    id: 'sw_budget',
    categoryId: 'swaddle',
    name: 'CozyCotton Swaddle Pack',
    emoji: '👶',
    summary: 'Value pack of soft cotton swaddles.',
    bestFor: 'Budgets',
    price: '₹499',
    badge: ProductBadge.bestBudget,
    score: 8.1,
    why: ['Great value pack', 'Soft cotton', 'Machine washable'],
    consider: ['Slightly thicker', 'Fewer prints'],
  ),
  Product(
    id: 'sw_premium',
    categoryId: 'swaddle',
    name: 'SnugZip Swaddle Sack',
    emoji: '👶',
    summary: 'Zip swaddle for easy, secure wrapping.',
    bestFor: 'Easy wrapping',
    price: '₹999',
    badge: ProductBadge.bestPremium,
    score: 8.6,
    why: ['Easy zip wrapping', 'Secure fit', 'Soft fabric'],
    consider: ['Outgrown quickly', 'Premium price'],
  ),
];

// ---------------------------------------------------------------------------
//  Lookups
// ---------------------------------------------------------------------------
ProductCategory? productCategoryById(String id) {
  for (final c in kProductCategories) {
    if (c.id == id) return c;
  }
  return null;
}

Product? productById(String id) {
  for (final p in kProducts) {
    if (p.id == id) return p;
  }
  return null;
}

/// A real photo URL for [p]: its own [Product.imageUrl] if set, else a stable
/// placeholder photo (consistent per product) so cards show real images now.
/// Swap in exact product/Amazon image URLs on the model later.
String productImageUrl(Product p) => p.imageUrl.isNotEmpty
    ? p.imageUrl
    : 'https://picsum.photos/seed/pv_${p.id}/300/300';

/// An Amazon India search URL for [p] (used by affiliate Buy on Amazon).
String amazonSearchUrl(Product p) =>
    'https://www.amazon.in/s?k=${Uri.encodeComponent(p.name)}';

/// The ~half of the catalogue treated as AFFILIATE (bought on Amazon), spread
/// across every category; each category's `_overall` hero pick stays ParentVeda.
/// 12 of 24 products. (A product can also opt in via `Product.isAffiliate`.)
const Set<String> _kAffiliateProductIds = {
  'pp_budget', 'pp_premium',
  'sc_budget',
  'mw_premium', 'mw_budget',
  'bb_budget',
  'cs_premium',
  'nb_budget',
  'bp_budget', 'bp_premium',
  'sw_budget', 'sw_premium',
};

/// Is [p] an affiliate (Amazon) product, vs a ParentVeda (in-app cart) product?
bool productIsAffiliate(Product p) =>
    p.isAffiliate || _kAffiliateProductIds.contains(p.id);

List<Product> productsForCategory(String categoryId) =>
    kProducts.where((p) => p.categoryId == categoryId).toList();

Product? bestOverallFor(String categoryId) {
  final list = productsForCategory(categoryId);
  for (final p in list) {
    if (p.badge == ProductBadge.bestOverall || p.badge == ProductBadge.newborns) {
      return p;
    }
  }
  return list.isEmpty ? null : list.first;
}

/// Categories relevant at [week], soonest-starting first.
List<ProductCategory> recommendedCategories(int week) {
  final list = kProductCategories.where((c) => c.relevantAt(week)).toList();
  list.sort((a, b) => a.fromWeek.compareTo(b.fromWeek));
  return list;
}

List<Product> productSearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return kProducts
      .where((p) =>
          p.name.toLowerCase().contains(q) ||
          (productCategoryById(p.categoryId)?.name.toLowerCase().contains(q) ?? false))
      .toList();
}

List<ProductCategory> categorySearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return kProductCategories.where((c) => c.name.toLowerCase().contains(q)).toList();
}
