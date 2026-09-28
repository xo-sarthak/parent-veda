// =============================================================================
//  The unified catalogue — three source catalogues folded into one shape
// -----------------------------------------------------------------------------
//  ⚠️ THE OLD DATA FILES ARE THE SOURCE OF TRUTH, ON PURPOSE.
//
//  `product_data.dart` (24 pregnancy products), `pp_products_data.dart` (24
//  parenting products) and `ttc_products_data.dart` (11 TTC products) hold
//  roughly three thousand lines of authored copy — guidance, look-fors, honest
//  watch-outs, parent voices, studies. Rewriting that into a fourth file would
//  have been a week of transcription and a certain source of drift. So this
//  file ADAPTS: each old entry becomes one `PvProduct`, the `ProductGuide`
//  layer (experts, ingredients, studies) is merged in by id, and a small
//  overlay (`pv_product_extras.dart`) adds what none of the three had —
//  photographs, variants, and the "ParentVeda recommends" reasons.
//
//  Trade-off, stated: an adapter means the unified model can never carry a
//  field its sources lack without an overlay; the overlay means two files to
//  read for one product. Accepted, because the alternative — three live
//  catalogues plus a copy — is the drift this build exists to end. When the
//  catalogue moves to Supabase (migration 0083) the adapters become the
//  import script and the old files become seed history.
//
//  ⚠️ `.en` IS IDENTITY, `.now` IS DISPLAY. The pregnancy catalogue is
//  `LocalizedText`; this adapter reads `.en` because the unified store is
//  English-first (new work is English — CLAUDE.md) and because ids, search
//  keys and cart lines must not change when the language toggle flips.
// =============================================================================

import '../../models/product_models.dart' as preg;
import '../../models/pv_product.dart';
import '../../screens/post_pregnancy/pp_products_data.dart' as pp;
import '../../screens/product_guide/product_guide_data.dart' as guide;
import '../../services/life_stage_store.dart';
import '../../ttc/ttc_products_data.dart' as ttc;
import '../product_data.dart' as preg_data;
import 'pv_product_extras.dart';

// ---- categories -------------------------------------------------------------

/// Category hues, spent only in the icon well. Assigned by meaning: sleep is
/// the calm blue, skin the sand, feeding the peach, safety the clinical
/// blue-grey, movement the sage, play the rose. Same idea as V2BlockHues.
const double _hueSleep = 206;
const double _hueSkin = 42;
const double _hueFeed = 26;
const double _huePlay = 344;
const double _hueSafety = 200;
const double _hueMove = 104;
const double _hueWear = 320;
const double _hueSupp = 268;
const double _hueKit = 180;
const double _hueBook = 42;

PvGuidance _g(preg.ProductCategory c) => PvGuidance(
      line: c.guidance.en,
      lookFor: [for (final t in c.lookFor) t.en],
      avoid: [for (final t in c.avoid) t.en],
    );

PvGuidance _pg(pp.PpGuide g) =>
    PvGuidance(line: g.line, lookFor: g.lookFor, avoid: g.avoid);

/// Sub id = the sub's name slugged, so `productsInSub` and the guide map (both
/// keyed by the full name) can be reached from an id without a second table.
String pvSlug(String s) => s
    .toLowerCase()
    .replaceAll('&', 'and')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_|_$'), '');

const Map<String, double> _pregHue = {
  'pregnancy_pillow': _hueSleep,
  'stretch_care': _hueSkin,
  'maternity_wear': _hueWear,
  'belly_band': _hueWear,
  'compression_socks': _hueWear,
  'nursing_bra': _hueWear,
  'breast_pump': _hueFeed,
  'swaddle': _hueSleep,
};

const Map<String, double> _ppHue = {
  'Sleep': _hueSleep,
  'Skincare': _hueSkin,
  'Feeding': _hueFeed,
  'Play & Development': _huePlay,
  'Health & Safety': _hueSafety,
  'On the move': _hueMove,
};

const Map<String, double> _ttcHue = {
  'supplements': _hueSupp,
  'kits': _hueKit,
  'tests': _hueKit,
  'books': _hueBook,
  'wellness': _hueSkin,
};

/// Every category, all three stages, in shelf order.
List<PvCategory> buildPvCategories() => [
      // TTC — five flat categories.
      for (final (id, name, _) in ttc.ttcProductCategories)
        PvCategory(
          id: 'ttc_$id',
          stage: LifeStage.tryingToConceive,
          name: name,
          hue: _ttcHue[id] ?? _hueSupp,
          guidance: kTtcCategoryGuidance[id],
        ),
      // Pregnancy — eight categories with authored guidance and a week window.
      for (final c in preg_data.kProductCategories)
        PvCategory(
          id: c.id,
          stage: LifeStage.pregnancy,
          name: c.name.en,
          hue: _pregHue[c.id] ?? _hueWear,
          guidance: _g(c),
          fromWeek: c.fromWeek,
          toWeek: c.toWeek,
        ),
      // Parenting — six categories with subcategories, guidance per sub.
      for (final c in pp.kPpCategories)
        PvCategory(
          id: pvSlug(c.name),
          stage: LifeStage.parenting,
          name: c.name,
          hue: _ppHue[c.name] ?? _huePlay,
          subs: [
            for (final s in c.subs) PvSub(pvSlug(s.name), s.name, short: s.short)
          ],
          subGuidance: {
            for (final s in c.subs)
              if (pp.kPpGuides[s.name] != null)
                pvSlug(s.name): _pg(pp.kPpGuides[s.name]!),
          },
        ),
    ];

// ---- adapters ---------------------------------------------------------------

PvRecoBand _bandOfTtc(ttc.TtcRecoBand b) => PvRecoBand.values[b.index];
PvEvidence _evidenceOfTtc(ttc.TtcEvidence e) => PvEvidence.values[e.index];

PvRecoBand _bandOfGuide(guide.PgReco r) => switch (r) {
      guide.PgReco.highly => PvRecoBand.strong,
      guide.PgReco.recommended => PvRecoBand.buy,
      guide.PgReco.considerations => PvRecoBand.consider,
      guide.PgReco.specific => PvRecoBand.situational,
      guide.PgReco.notRecommended => PvRecoBand.skip,
    };

/// The pregnancy badge → the editorial chip word the other two sides use.
String _badgeOfPreg(preg.ProductBadge b) => switch (b) {
      preg.ProductBadge.bestOverall => 'Best overall',
      preg.ProductBadge.bestBudget => 'Best value',
      preg.ProductBadge.bestPremium => 'Premium',
      preg.ProductBadge.sensitiveSkin => 'Sensitive skin',
      preg.ProductBadge.newborns => 'For newborns',
      preg.ProductBadge.none => '',
    };

int _rupees(String s) =>
    int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

/// Pregnancy `Product` → `PvProduct`. Its `score /10` is not carried: the
/// unified model has no score field, by design (see the header).
PvProduct _fromPreg(preg.Product p) {
  final cat = preg_data.kProductCategories.firstWhere(
      (c) => c.id == p.categoryId,
      orElse: () => preg_data.kProductCategories.first);
  final rs = p.reviewSummary;
  return PvProduct(
    id: p.id,
    stage: LifeStage.pregnancy,
    categoryId: p.categoryId,
    name: p.name.en,
    brand: p.name.en.split(' ').first,
    summary: p.summary.en,
    images: [if (p.imageUrl.isNotEmpty) p.imageUrl],
    price: _rupees(p.price),
    retailer: p.isAffiliate ? 'Amazon' : 'ParentVeda',
    buyUrl: p.isAffiliate ? preg_data.amazonSearchUrl(p) : null,
    soldHere: !p.isAffiliate,
    rating: 0,
    reviewCount: p.reviews.length,
    goods: [for (final t in p.why) t.en],
    watchOuts: [for (final t in p.consider) t.en],
    bestFor: [p.bestFor.en],
    badge: _badgeOfPreg(p.badge),
    parentsPct: rs?.wouldBuyAgainPct,
    reviews: [
      for (final r in p.reviews)
        PvParentReview(
          author: r.author.en,
          context: '${r.role.en} · ${r.usedDuring.en}',
          stars: r.wouldBuyAgain ? 5 : 3,
          text: r.liked.en,
          watchOut: r.watchOut.en,
          wouldBuyAgain: r.wouldBuyAgain,
        ),
    ],
    weekFrom: cat.fromWeek,
    weekTo: cat.toWeek,
    hue: _pregHue[p.categoryId] ?? _hueWear,
  );
}

/// Parenting `PpProduct` → `PvProduct`, with its Guide merged in when it has
/// one (`kProductToGuide`). The Guide is where experts, ingredients and
/// studies lived; the product is where price, retailer and specs lived. One
/// page now shows both, which is what the Guide hub was for.
PvProduct _fromPp(pp.PpProduct p) {
  final g = guide.guideForProduct(id: p.id, name: p.name);
  return PvProduct(
    id: p.id,
    stage: LifeStage.parenting,
    categoryId: pvSlug(p.category),
    subId: pvSlug(p.sub),
    name: p.name,
    brand: p.brand,
    summary: p.summary.isNotEmpty ? p.summary : (g?.verdict ?? ''),
    images: p.images,
    price: p.price,
    retailer: p.retailer,
    buyUrl: p.buyUrl,
    soldHere: p.parentVeda || p.brand == 'ParentVeda',
    reviewOnly: p.reviewOnly,
    rating: p.rating,
    reviewCount: p.reviews,
    reco: g == null
        ? null
        : PvRecommend(
            band: _bandOfGuide(g.reco),
            reason: g.verdict,
            beforeYouBuy: g.beforeYouBuy,
          ),
    goods: pp.ppProsOf(p),
    watchOuts: pp.ppConsOf(p),
    bestFor: p.bestFor.isNotEmpty
        ? [p.bestFor, ...?g?.bestFor]
        : (g?.bestFor ?? const []),
    specs: [
      for (final e in p.specs.entries) (e.key, e.value),
      if (p.specs.isEmpty) ...[for (final s in g?.specs ?? const []) (s.label, s.value)],
    ],
    reviews: [
      for (final e in g?.experiences ?? const [])
        PvParentReview(
            author: e.author, context: e.context, stars: e.stars, text: e.text),
    ],
    experts: [
      for (final x in g?.experts ?? const [])
        PvExpertVoice(
            name: x.name,
            role: x.role,
            quote: x.hook,
            videoId: x.videoId,
            duration: x.duration),
    ],
    // The Guide already showed these on its own hub; carried, never derived
    // here. A product without a Guide gets nothing.
    parentsPct: p.parentsPct ?? g?.parentsPct,
    expertsPct: p.expertsPct ?? g?.expertsPct,
    ingredients: [
      for (final i in g?.ingredients ?? const [])
        PvIngredient(
            name: i.name, purpose: i.purpose, note: i.note, caution: i.caution),
    ],
    studies: [
      for (final s in g?.studies ?? const [])
        PvStudy(
            topic: s.topic,
            summary: s.summary,
            meaning: s.meaning,
            source: s.source,
            byMaker: s.byMaker),
    ],
    ageMinMonths: p.ageMin,
    ageMaxMonths: p.ageMax,
    badge: p.badge,
    bestseller: p.bestseller,
    hue: _ppHue[p.category] ?? _huePlay,
    relatedIds: g?.relatedIds ?? const [],
    compare: {
      if (p.sound != null) 'Sound': p.sound!,
      if (p.autoOff != null) 'Auto-off': p.autoOff! ? 'Yes' : 'No',
      if (p.volumeLock != null) 'Volume lock': p.volumeLock! ? 'Yes' : 'No',
      if (p.power != null) 'Power': p.power!,
      ...p.specs,
    },
  );
}

/// TTC `TtcProduct` → `PvProduct`. Ids take a `ttc_` prefix (`thermometer`
/// existed on the parenting side too). The band and evidence carry across
/// unchanged; the reason under "ParentVeda recommends" is the product's own
/// `why` line, which is what that copy already was.
PvProduct _fromTtc(ttc.TtcProduct p) {
  final price = _rupees(p.price);
  return PvProduct(
    id: 'ttc_${p.id}',
    stage: LifeStage.tryingToConceive,
    categoryId: 'ttc_${p.category}',
    name: p.nameEn,
    brand: p.brand == 'Various' ? '' : p.brand,
    summary: p.verdict.isNotEmpty ? p.verdict : p.whyEn,
    images: p.photos,
    price: price,
    priceNote: p.priceEn,
    retailer: p.retailer,
    buyUrl: p.retailerUrl.isNotEmpty ? p.retailerUrl : null,
    soldHere: false,
    // ⚠️ NO SEED REVIEWS ON SHOW (TTC launch walk, 2026-09-27). `rating`,
    // `reviews`, `voices`, `parentsPct`, `expertsPct` and `badge` are SEED
    // values (ttc_products_data.dart says they "MUST BE REPLACED BEFORE
    // LAUNCH", STILL-OPEN §24.2): star ratings, counts like "(9450)", quotes
    // from named parents and a "BESTSELLER" badge nobody earned. Until real
    // ones exist the store shows none; the editorial band, the reason, the
    // evidence and "before you buy" stay. Flip [kTtcShowSeedReviews] to
    // restore. Kept for revert: rating: p.rating, reviewCount: p.reviews,
    rating: kTtcShowSeedReviews ? p.rating : 0,
    reviewCount: kTtcShowSeedReviews ? p.reviews : 0,
    reco: PvRecommend(
      band: _bandOfTtc(p.band),
      reason: p.whyEn,
      beforeYouBuy: p.watchOutEn,
    ),
    evidence: _evidenceOfTtc(p.evidence),
    goods: p.goods.isNotEmpty ? p.goods : [p.lookForEn],
    watchOuts: p.watchOuts.isNotEmpty ? p.watchOuts : [p.watchOutEn],
    bestFor: [for (final (label, _) in p.bestFor) label],
    specs: p.specs,
    reviews: [
      if (kTtcShowSeedReviews)
        for (final (author, stars, context, text) in p.voices)
          PvParentReview(author: author, context: context, stars: stars, text: text),
    ],
    parentsPct: kTtcShowSeedReviews && p.parentsPct > 0 ? p.parentsPct : null,
    expertsPct: kTtcShowSeedReviews && p.expertsPct > 0 ? p.expertsPct : null,
    ingredients: [
      for (final (name, purpose, note, caution) in p.inside)
        PvIngredient(name: name, purpose: purpose, note: note, caution: caution),
    ],
    studies: [
      for (final (topic, summary, meaning, source, byMaker) in p.studies)
        PvStudy(
            topic: topic,
            summary: summary,
            meaning: meaning,
            source: source,
            byMaker: byMaker),
    ],
    forPartner: p.forPartner,
    badge: kTtcShowSeedReviews ? p.badge : '',
    hue: p.hue,
    compare: {for (final (k, v) in p.specs) k: v},
  );
}

/// Apply the overlay: photos, variants, recommends. Overlay wins on photos
/// ONLY when the source had none — a real product photo an editor placed in
/// the source file is never replaced by a stock one.
PvProduct _enrich(PvProduct p) {
  final x = kPvProductExtras[p.id];
  final photos = kPvProductPhotos[p.id] ?? const <String>[];
  if (x == null && photos.isEmpty) return p;
  final seedOk = pvShowsSeedVoices(p);
  return PvProduct(
    id: p.id,
    stage: p.stage,
    categoryId: p.categoryId,
    subId: p.subId,
    name: p.name,
    brand: x?.brand ?? p.brand,
    summary: p.summary,
    images: p.images.isNotEmpty ? [...p.images, ...photos] : photos,
    price: x?.price ?? p.price,
    mrp: x?.mrp ?? p.mrp,
    priceNote: p.priceNote,
    retailer: x?.retailer ?? p.retailer,
    buyUrl: x?.buyUrl ?? p.buyUrl,
    soldHere: x?.soldHere ?? p.soldHere,
    reviewOnly: p.reviewOnly,
    // ⚠️ THE OVERLAY'S SEED VOICES OBEY THE SAME TTC GATE (launch sanity H13,
    // 2026-09-28). `kTtcShowSeedReviews` hid the source file's seed ratings,
    // quotes and badges, but the overlay in pv_product_extras.dart added its
    // own: "What experts say" on Folic acid quoted "Dr. Meera Iyer,
    // Obstetrician", a seed persona, with a verified tick. On a TTC product
    // the overlay's experts, reviews, rating, count and experts' share now
    // show only with the flag on, exactly like the source's. Other stages
    // are unchanged. Kept for revert: the five lines without `seedOk`.
    rating: seedOk ? (x?.rating ?? p.rating) : p.rating,
    reviewCount: seedOk ? (x?.reviewCount ?? p.reviewCount) : p.reviewCount,
    reco: x?.reco ?? p.reco,
    evidence: p.evidence,
    goods: p.goods,
    watchOuts: p.watchOuts,
    bestFor: p.bestFor,
    specs: p.specs,
    variants: x?.variants ?? p.variants,
    reviews: [...p.reviews, if (seedOk) ...?x?.reviews],
    experts: [...p.experts, if (seedOk) ...?x?.experts],
    parentsPct: p.parentsPct,
    expertsPct: seedOk ? (x?.expertsPct ?? p.expertsPct) : p.expertsPct,
    ingredients: p.ingredients,
    studies: p.studies,
    weekFrom: p.weekFrom,
    weekTo: p.weekTo,
    ageMinMonths: p.ageMinMonths,
    ageMaxMonths: p.ageMaxMonths,
    forPartner: p.forPartner,
    badge: p.badge,
    bestseller: p.bestseller,
    hue: p.hue,
    relatedIds: p.relatedIds,
    compare: p.compare,
  );
}

/// The whole catalogue, every stage, enriched. Built once by the store.
List<PvProduct> buildPvCatalog() => [
      for (final p in ttc.ttcProducts) _enrich(_fromTtc(p)),
      for (final p in preg_data.kProducts) _enrich(_fromPreg(p)),
      for (final p in pp.productCatalog) _enrich(_fromPp(p)),
    ];

/// Ask Veda's TTC deep links carry the old id (`ttcprod_folic` → `folic`).
String pvIdForTtc(String oldId) => 'ttc_$oldId';

/// A Guide's product, for the retired Guide screen's facade: the parenting
/// product mapped to it in `kProductToGuide`, else the guide id itself (a few
/// guides ARE products on the pregnancy side), else nothing opens sensibly
/// and the product page shows its honest "no longer listed" state.
String pvProductIdForGuide(String guideId) {
  for (final e in guide.kProductToGuide.entries) {
    if (e.value == guideId) return e.key;
  }
  return guideId;
}

/// Whether the TTC shelf shows its SEED review numbers, quotes and badges.
/// Off until real reviews exist (TTC launch walk, 2026-09-27); a demo build
/// can turn it on with `--dart-define=PV_TTC_SEED_REVIEWS=true`.
const bool kTtcShowSeedReviews = bool.fromEnvironment('PV_TTC_SEED_REVIEWS');

/// Whether [p] may show SEED voices (ratings, counts, parent quotes, expert
/// quotes): always outside Trying to conceive, and on it only with
/// [kTtcShowSeedReviews] (H13, 2026-09-28). The day a real, signed expert
/// quote exists for a TTC product, it goes in the source record
/// (`p.experts`), which this gate never hides.
bool pvShowsSeedVoices(PvProduct p) =>
    p.stage != LifeStage.tryingToConceive || kTtcShowSeedReviews;
