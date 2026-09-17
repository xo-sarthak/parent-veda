// =============================================================================
//  PvProduct — ONE product shape for the whole app
// -----------------------------------------------------------------------------
//  Built 2026-09-17 from the Mobbin marketplace audit (docs/PRODUCTS-AUDIT.md).
//
//  Before this file there were three product models — `Product` (pregnancy),
//  `PpProduct` (parenting) and `TtcProduct` (trying to conceive) — plus a
//  fourth, `ProductGuide`, that carried the expert and research layer for a
//  few of them. Three models meant three shelves, three product pages, three
//  compare screens and three ideas of what a price is. The user's verdict:
//  *"every side of the app was made individually, so it's got its product
//  section, which makes no sense."*
//
//  The rule this file follows is the family model's (docs/FAMILY-MODEL.md):
//  **stage is a tag, never an owner.** A product belongs to the catalogue; it
//  is *tagged* with the stage it is most useful in, and that tag decides what
//  leads on the shelf — never what exists. The same shelf, the same product
//  page and the same checkout serve all three stages, the way H&M's WOMEN /
//  MEN / KIDS switch changes the storefront without changing the store.
//
//  ⚠️ NOTHING IN HERE IS DERIVED FROM A STAR RATING. `parentsPct` and
//  `expertsPct` are nullable and stay null unless an editor (or a source
//  catalogue that already showed them) supplied a figure. A percentage
//  computed from a rating is a number that looks measured and is not — the
//  parenting side's own header says so, and this model keeps that rule.
//
//  ⚠️ THE RECOMMENDATION BAND IS AN ENUM, NOT A NUMBER, and `skip` renders
//  with the same weight as `strong`. A marketplace has no vocabulary for
//  "generally not needed" because that sentence costs it money; we do.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../services/life_stage_store.dart';

/// How strongly ParentVeda stands behind a product. Visible ON THE SHELF.
enum PvRecoBand { strong, buy, consider, situational, skip }

extension PvRecoBandCopy on PvRecoBand {
  String get label => switch (this) {
        PvRecoBand.strong => 'Highly recommended',
        PvRecoBand.buy => 'Recommended',
        PvRecoBand.consider => 'Worth considering',
        PvRecoBand.situational => 'Only in some cases',
        PvRecoBand.skip => 'Generally not needed',
      };

  /// 0 = positive, 1 = neutral, 2 = cautious. The screen picks the colour.
  int get tone => switch (this) {
        PvRecoBand.strong || PvRecoBand.buy => 0,
        PvRecoBand.consider || PvRecoBand.situational => 1,
        PvRecoBand.skip => 2,
      };

  /// Strong first, skip last — and skip is still on the shelf.
  int get rank => index;

  /// Does this band earn the "ParentVeda recommends" mark? Only the top two.
  /// "Worth considering" is honest guidance, not an endorsement.
  bool get recommends => this == PvRecoBand.strong || this == PvRecoBand.buy;
}

/// How much is actually known about whether this helps (TTC's replacement for
/// a score out of 100 — kept, because for a supplement it is the truer fact).
enum PvEvidence { strong, mixed, thin }

extension PvEvidenceCopy on PvEvidence {
  String get label => switch (this) {
        PvEvidence.strong => 'Strong evidence',
        PvEvidence.mixed => 'Mixed evidence',
        PvEvidence.thin => 'Thin evidence',
      };
}

/// The "ParentVeda recommends" block — why we put our name next to this one.
///
/// Present on SOME products, never all. The user's brief: *"it's not for all
/// products but for some … this is our element, our differentiation, but we
/// are being honest and upfront."* A product with `reco == null` is on the
/// shelf as a product; a product with a `reco` carries our reason, and the
/// name of the person who reviewed it.
@immutable
class PvRecommend {
  const PvRecommend({
    required this.band,
    required this.reason,
    this.beforeYouBuy = '',
    this.reviewerName = '',
    this.reviewerRole = '',
  });

  final PvRecoBand band;

  /// One or two sentences: why ParentVeda recommends (or does not).
  final String reason;

  /// The one honest sentence BEFORE the recommendation — who does not need it.
  final String beforeYouBuy;

  /// Who stands behind the call. Empty = the editorial team.
  final String reviewerName;
  final String reviewerRole;
}

/// A named expert's take. Quote first; a film if we have one.
@immutable
class PvExpertVoice {
  const PvExpertVoice({
    required this.name,
    required this.role,
    required this.quote,
    this.videoId,
    this.duration = '',
  });
  final String name;
  final String role;
  final String quote;
  final String? videoId;
  final String duration;
}

/// A parent's review. `context` is the reviewer attribute Sephora puts under a
/// review ("Fair skin tone, Combination skin") — ours is "Week 32 → birth" or
/// "Winter · 4-month-old".
@immutable
class PvParentReview {
  const PvParentReview({
    required this.author,
    required this.context,
    required this.stars,
    required this.text,
    this.watchOut = '',
    this.wouldBuyAgain = true,
  });
  final String author;
  final String context;
  final int stars; // 1–5
  final String text;
  final String watchOut;
  final bool wouldBuyAgain;
  bool get positive => stars >= 4;
}

@immutable
class PvIngredient {
  const PvIngredient({
    required this.name,
    required this.purpose,
    required this.note,
    this.caution = '',
  });
  final String name;
  final String purpose;
  final String note;
  final String caution;
}

@immutable
class PvStudy {
  const PvStudy({
    required this.topic,
    required this.summary,
    required this.meaning,
    this.source = '',
    this.byMaker = false,
  });
  final String topic;
  final String summary;
  final String meaning;
  final String source;
  final bool byMaker;
}

/// A purchasable variant — a size, a pack, a shade. `price` is absolute (not a
/// delta) so the line in the cart carries the number she saw.
@immutable
class PvVariant {
  const PvVariant({required this.id, required this.label, required this.price});
  final String id;
  final String label;
  final int price;
}

/// A subcategory row under a category ("Soothers & white noise").
@immutable
class PvSub {
  const PvSub(this.id, this.name, {this.short = ''});
  final String id;
  final String name;
  final String short;
  String get shortName => short.isEmpty ? name : short;
}

/// The 20-second buying guidance that leads a shelf — the education layer.
@immutable
class PvGuidance {
  const PvGuidance({
    required this.line,
    this.lookFor = const [],
    this.avoid = const [],
  });
  final String line;
  final List<String> lookFor;
  final List<String> avoid;
}

/// A top-level category, tagged with the stage it belongs under.
@immutable
class PvCategory {
  const PvCategory({
    required this.id,
    required this.stage,
    required this.name,
    required this.hue,
    this.subs = const [],
    this.guidance,
    this.subGuidance = const {},
    this.fromWeek,
    this.toWeek,
  });
  final String id;
  final LifeStage stage;
  final String name;

  /// The category's colour, spent only in the icon well.
  final double hue;
  final List<PvSub> subs;

  /// Category-level guidance (pregnancy authored it per category).
  final PvGuidance? guidance;

  /// Sub-level guidance (parenting authored it per subcategory).
  final Map<String, PvGuidance> subGuidance;

  /// Pregnancy relevance window, when the category has one.
  final int? fromWeek;
  final int? toWeek;

  PvGuidance? guidanceFor(String? subId) =>
      (subId == null ? null : subGuidance[subId]) ?? guidance;
}

@immutable
class PvProduct {
  const PvProduct({
    required this.id,
    required this.stage,
    required this.categoryId,
    required this.name,
    this.subId,
    this.brand = '',
    this.summary = '',
    this.images = const [],
    this.price = 0,
    this.mrp,
    this.priceNote = '',
    this.retailer = '',
    this.buyUrl,
    this.soldHere = false,
    this.reviewOnly = false,
    this.rating = 0,
    this.reviewCount = 0,
    this.reco,
    this.evidence,
    this.goods = const [],
    this.watchOuts = const [],
    this.bestFor = const [],
    this.specs = const [],
    this.variants = const [],
    this.reviews = const [],
    this.experts = const [],
    this.parentsPct,
    this.expertsPct,
    this.ingredients = const [],
    this.studies = const [],
    this.weekFrom,
    this.weekTo,
    this.ageMinMonths = 0,
    this.ageMaxMonths = 72,
    this.forPartner = false,
    this.badge = '',
    this.bestseller = false,
    this.hue = 268,
    this.relatedIds = const [],
    this.compare = const {},
  });

  /// Unique across the whole catalogue. Source ids are kept where they were
  /// already unique (`pp_overall`, `dozy`); TTC ids take a `ttc_` prefix
  /// because `thermometer` existed on two sides.
  final String id;

  /// The stage this is MOST useful in — a tag for what leads, never a wall.
  final LifeStage stage;
  final String categoryId;
  final String? subId;
  final String name;
  final String brand;
  final String summary;

  /// Hero first. Empty = no photo yet → an honest cover block, never a stock
  /// photo of the wrong object.
  final List<String> images;

  /// Rupees. 0 = "price varies" (TTC ranges), shown via [priceNote].
  final int price;
  final int? mrp;
  final String priceNote;

  /// Where the buy happens. `soldHere` = ParentVeda fulfils → cart + checkout.
  /// Otherwise the retailer's page opens (affiliate) and the copy says so.
  final String retailer;
  final String? buyUrl;
  final bool soldHere;

  /// IMS Act: information only, no buy control. See pp_products_data.dart.
  final bool reviewOnly;

  final double rating;
  final int reviewCount;

  final PvRecommend? reco;
  final PvEvidence? evidence;

  /// What's good / worth considering — the shelf's two honest lists.
  final List<String> goods;
  final List<String> watchOuts;
  final List<String> bestFor;
  final List<(String, String)> specs;
  final List<PvVariant> variants;
  final List<PvParentReview> reviews;
  final List<PvExpertVoice> experts;

  /// Measured figures only. Null renders nothing.
  final int? parentsPct;
  final int? expertsPct;
  final List<PvIngredient> ingredients;
  final List<PvStudy> studies;

  /// Relevance windows: pregnancy weeks, child age in months.
  final int? weekFrom;
  final int? weekTo;
  final int ageMinMonths;
  final int ageMaxMonths;

  /// TTC: a product for him (semen analysis kit, zinc).
  final bool forPartner;

  /// 'Best overall' / 'Best value' / 'Premium' — the editorial chip.
  final String badge;
  final bool bestseller;

  /// Card-well hue when there is no photo.
  final double hue;
  final List<String> relatedIds;

  /// Category-specific compare facts — the rows the compare table draws.
  final Map<String, String> compare;

  // ---- derived -------------------------------------------------------------

  bool get hasImage => images.isNotEmpty;
  bool get canBuy => !reviewOnly && (soldHere || (buyUrl?.isNotEmpty ?? false));
  bool get recommends => reco?.band.recommends ?? false;
  bool get hasPrice => price > 0;

  int? get discountPct {
    final m = mrp;
    if (m == null || m <= price || price <= 0) return null;
    return ((m - price) * 100 / m).round();
  }

  String get priceLabel => hasPrice ? '₹${groupRupees(price)}' : priceNote;
  String get mrpLabel => mrp == null ? '' : '₹${groupRupees(mrp!)}';
  String get ratingLabel => rating <= 0 ? '' : rating.toStringAsFixed(1);

  bool suitsWeek(int week) =>
      (weekFrom == null || week >= weekFrom! - 2) &&
      (weekTo == null || week <= weekTo!);

  bool suitsAge(int months) => months >= ageMinMonths && months <= ageMaxMonths;

  /// Indian grouping: 1,499 · 12,999 · 1,20,000.
  static String groupRupees(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    var head = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (head.length > 2) {
      parts.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) parts.insert(0, head);
    return '${parts.join(',')},$last3';
  }
}

/// Stage copy for the storefront switch — one word each, like WOMAN / MAN /
/// KIDS. `LifeStage.skilling` is not a shop.
extension PvStageCopy on LifeStage {
  String get shopLabel => switch (this) {
        LifeStage.tryingToConceive => 'Trying',
        LifeStage.pregnancy => 'Pregnancy',
        LifeStage.parenting => 'Parenting',
        LifeStage.skilling => 'Parenting',
      };

  /// The three stages a shopper can switch between.
  static const List<LifeStage> shopStages = [
    LifeStage.tryingToConceive,
    LifeStage.pregnancy,
    LifeStage.parenting,
  ];

  /// Skilling shops the parenting shelf.
  LifeStage get shopStage =>
      this == LifeStage.skilling ? LifeStage.parenting : this;
}
