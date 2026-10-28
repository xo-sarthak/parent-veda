// =============================================================================
//  pv_product_rows.dart — a `products` row (domain = 'store') → PvProduct
// -----------------------------------------------------------------------------
//  Store Track A, slice 2 (2026-10-28). The sheet importer
//  (tools/products/import_store_sheet.py) writes rows; PvCatalogStore reads
//  them and this file turns each into the same PvProduct every screen
//  already draws. So a product the team adds to the sheet appears without an
//  app release: PLUG AND PLAY.
//
//  ⚠️ A ROW THAT CANNOT BE READ IS SKIPPED, NEVER GUESSED. No id, no name, or
//  a stage or category the store does not have → null, and the built-in
//  product (if any) stays. A half-read product on a shelf is worse than the
//  old one.
//
//  The column names are pinned against the migrations by
//  test/store_sheet_feed_test.dart, because a renamed column would otherwise
//  read as empty without a sound.
// =============================================================================

import '../../models/pv_product.dart';
import '../../services/life_stage_store.dart';

/// The sheet's stage words → the store's stages. Several spellings, because
/// people type the sheet by hand.
const Map<String, LifeStage> kStoreStageWords = {
  'ttc': LifeStage.tryingToConceive,
  'trying': LifeStage.tryingToConceive,
  'trying_to_conceive': LifeStage.tryingToConceive,
  'pregnancy': LifeStage.pregnancy,
  'pregnant': LifeStage.pregnancy,
  'parenting': LifeStage.parenting,
  'baby': LifeStage.parenting,
};

/// Programme → the name the page says ("Buy on Amazon").
const Map<String, String> kStoreProgrammeShop = {
  'amazon': 'Amazon',
  'flipkart': 'Flipkart',
};

String _s(Object? v) => v is String ? v.trim() : '';
int? _i(Object? v) => v is num ? v.toInt() : int.tryParse(_s(v));
double? _d(Object? v) => v is num ? v.toDouble() : double.tryParse(_s(v));
List<String> _list(Object? v) => [
  if (v is List)
    for (final e in v)
      if (e is String && e.trim().isNotEmpty) e.trim(),
];

/// [row] as a product, or null when it cannot be read honestly.
/// [categoryIds] are the store's categories; a row naming any other is
/// skipped (the importer refuses it first; this is the second lock).
PvProduct? pvProductFromStoreRow(
  Map<String, dynamic> row, {
  required Set<String> categoryIds,
}) {
  final id = _s(row['source_key']);
  final name = _s(row['name']);
  final stages = _list(row['stage']);
  final stage = stages.isEmpty ? null : kStoreStageWords[stages.first];
  final category = _s(row['category']);
  if (id.isEmpty || name.isEmpty || stage == null) return null;
  if (!categoryIds.contains(category)) return null;

  final programme = _s(row['programme']);
  final retailer = _s(row['retailer']).isNotEmpty
      ? _s(row['retailer'])
      : (kStoreProgrammeShop[programme] ?? '');
  final buyUrl = _s(row['buy_url']);
  final extImage = _s(row['ext_image']);
  final ownImages = _list(row['images']);
  final sub = _s(row['sub_id']);

  return PvProduct(
    id: id,
    stage: stage,
    categoryId: category,
    subId: sub.isEmpty ? null : sub,
    name: name,
    brand: _s(row['brand']),
    summary: _s(row['summary']),
    // Amazon's own photo (from its API) leads when there is one; ours follow.
    images: [if (extImage.isNotEmpty) extImage, ...ownImages],
    price: _i(row['price_inr']) ?? 0,
    mrp: _i(row['mrp_inr']),
    priceNote: _s(row['price_note']).isNotEmpty
        ? _s(row['price_note'])
        : (retailer.isEmpty ? 'Price varies' : 'See price on $retailer'),
    retailer: retailer,
    buyUrl: buyUrl.isEmpty ? null : buyUrl,
    soldHere: row['sold_here'] == true,
    reviewOnly: row['review_only'] == true,
    asin: _s(row['asin']).isEmpty ? null : _s(row['asin']),
    priceCheckedAt: DateTime.tryParse(_s(row['price_checked_at'])),
    extRating: _d(row['ext_rating']) ?? 0,
    extReviewCount: _i(row['ext_review_count']) ?? 0,
    extFeatures: _list(row['ext_features']),
    goods: _list(row['pros']),
    watchOuts: _list(row['cons']),
    bestFor: [if (_s(row['best_for']).isNotEmpty) _s(row['best_for'])],
    weekFrom: _i(row['week_from']),
    weekTo: _i(row['week_to']),
    ageMinMonths: _i(row['age_min_months']) ?? 0,
    ageMaxMonths: _i(row['age_max_months']) ?? 72,
    forPartner: row['for_partner'] == true,
    badge: _s(row['badge']),
    bestseller: row['bestseller'] == true,
    hue: _d(row['hue']) ?? 268,
  );
}

/// The built-in catalogue with the sheet's rows laid over it: a row with a
/// built-in product's id takes its place; a new id is added at the end.
List<PvProduct> pvMergeStoreRows(List<PvProduct> base, List<PvProduct> rows) {
  if (rows.isEmpty) return base;
  final byId = {for (final r in rows) r.id: r};
  final merged = [
    for (final p in base)
      if (byId.remove(p.id) case final r?) _overlay(p, r) else p,
  ];
  return [...merged, ...byId.values];
}

/// The sheet owns what it carries (name, link, price, photos, where it
/// shows); the app's editorial work the sheet has no column for stays:
/// the recommendation, evidence, ingredients, studies, experts, reviews,
/// specs and comparisons. A list the sheet left empty keeps the app's.
PvProduct _overlay(PvProduct base, PvProduct r) => PvProduct(
  id: r.id,
  stage: r.stage,
  categoryId: r.categoryId,
  subId: r.subId ?? base.subId,
  name: r.name,
  brand: r.brand.isEmpty ? base.brand : r.brand,
  summary: r.summary.isEmpty ? base.summary : r.summary,
  images: r.images.isEmpty ? base.images : r.images,
  price: r.price,
  mrp: r.mrp,
  priceNote: r.priceNote,
  retailer: r.retailer.isEmpty ? base.retailer : r.retailer,
  buyUrl: r.buyUrl ?? base.buyUrl,
  soldHere: r.soldHere,
  reviewOnly: r.reviewOnly || base.reviewOnly,
  rating: base.rating,
  reviewCount: base.reviewCount,
  asin: r.asin,
  priceCheckedAt: r.priceCheckedAt,
  extRating: r.extRating,
  extReviewCount: r.extReviewCount,
  extFeatures: r.extFeatures,
  reco: base.reco,
  evidence: base.evidence,
  goods: r.goods.isEmpty ? base.goods : r.goods,
  watchOuts: r.watchOuts.isEmpty ? base.watchOuts : r.watchOuts,
  bestFor: r.bestFor.isEmpty ? base.bestFor : r.bestFor,
  specs: base.specs,
  variants: base.variants,
  reviews: base.reviews,
  experts: base.experts,
  parentsPct: base.parentsPct,
  expertsPct: base.expertsPct,
  ingredients: base.ingredients,
  studies: base.studies,
  weekFrom: r.weekFrom ?? base.weekFrom,
  weekTo: r.weekTo ?? base.weekTo,
  ageMinMonths: r.ageMinMonths,
  ageMaxMonths: r.ageMaxMonths,
  forPartner: r.forPartner || base.forPartner,
  badge: r.badge.isEmpty ? base.badge : r.badge,
  bestseller: r.bestseller || base.bestseller,
  hue: base.hue,
  relatedIds: base.relatedIds,
  compare: base.compare,
  shortlist: base.shortlist,
  score: base.score,
  confidence: base.confidence,
  scoreParts: base.scoreParts,
  skills: base.skills,
);
