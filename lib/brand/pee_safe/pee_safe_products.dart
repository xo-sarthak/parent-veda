// =============================================================================
//  Pee Safe — the product list for the stakeholder demo
// -----------------------------------------------------------------------------
//  DEMO ONLY (docs/PEE-SAFE-DEMO.md). Source: peesafe.com, 2026-11-02. Images
//  are each product's featured image, saved at 600px under
//  assets/brand/pee_safe/.
//
//  No price on purpose: a price copied into the app goes stale the day the
//  store changes it, and money is decided by the seller. The store page shows
//  the live price after the parent taps through.
//
//  Every link leaves through openOutbound(), the single door out, so a tap from
//  a campaign is attributed and a bad url is a no-op, never a crash.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../brand_models.dart';
import '../outbound.dart';

/// The moments a Pee Safe product is relevant to. Placement is by relevance,
/// not stage (P3), so Trying to Conceive is one of them.
enum PeeSafeMoment {
  tryingToConceive,
  pregnancy,
  hospitalBag,
  postpartum,
  periodsReturn,
  travel,
  outingsWithChild,
}

@immutable
class PeeSafeProduct {
  const PeeSafeProduct({
    required this.id,
    required this.name,
    required this.line,
    required this.slug,
    required this.image,
    required this.moments,
    this.alsoSlug,
  });

  final String id;
  final String name;

  /// One calm line on what it is for. ParentVeda's voice, not the brand's.
  final String line;

  /// The `peesafe.com/products/<slug>` path.
  final String slug;

  /// A second size or variant, when the store sells one.
  final String? alsoSlug;
  final String image;
  final Set<PeeSafeMoment> moments;

  String get url => 'https://www.peesafe.com/products/$slug';
  String? get alsoUrl => alsoSlug == null ? null : 'https://www.peesafe.com/products/$alsoSlug';

  /// Open the product on peesafe.com, attributed to [campaign] when the tap
  /// came from brand content.
  Future<bool> open({BrandCampaign? campaign}) => openOutbound(url, campaign: campaign, productId: id);
}

const String _img = 'assets/brand/pee_safe';

const List<PeeSafeProduct> kPeeSafeProducts = [
  PeeSafeProduct(
    id: 'ps_panty_liners',
    name: 'Aloe vera panty liners (50)',
    line: 'Thin daily liners for extra discharge in pregnancy, and for the taper after maternity pads.',
    slug: 'aloe-vera-panty-liners-50-liners',
    image: '$_img/panty_liners.jpg',
    moments: {PeeSafeMoment.pregnancy, PeeSafeMoment.postpartum},
  ),
  PeeSafeProduct(
    id: 'ps_night_pads',
    name: 'Comfort night pads XXXL',
    line: 'Long, high-absorbency pads for the heavier bleeding of the first weeks after birth.',
    slug: 'comfort-night-pads-xxxl-10n-1',
    alsoSlug: 'comfort-night-pads-xxxxl-8n-1',
    image: '$_img/night_pads.jpg',
    moments: {PeeSafeMoment.postpartum, PeeSafeMoment.hospitalBag},
  ),
  PeeSafeProduct(
    id: 'ps_all_night_kit',
    name: 'Comfort all-night kit',
    line: 'Night pads and period panties together, for the first weeks of recovery.',
    slug: 'comfort-all-night-kit',
    image: '$_img/all_night_kit.jpg',
    moments: {PeeSafeMoment.postpartum},
  ),
  PeeSafeProduct(
    id: 'ps_period_panty',
    name: 'Disposable period panty (4)',
    line: 'Pull-on protection for the hospital stay and after birth, including after a C-section.',
    slug: 'disposable-period-panty-m-l-pack-of-4',
    alsoSlug: 'disposable-period-panty-l-xl-pack-of-4',
    image: '$_img/period_panty.jpg',
    moments: {PeeSafeMoment.hospitalBag, PeeSafeMoment.postpartum},
  ),
  PeeSafeProduct(
    id: 'ps_intimate_wash',
    name: 'Natural intimate wash',
    line: 'A mild, pH-balanced external wash. Water alone is also fine.',
    slug: 'pee-safe-natural-intimate-wash-105-ml',
    image: '$_img/intimate_wash.jpg',
    moments: {PeeSafeMoment.pregnancy, PeeSafeMoment.tryingToConceive},
  ),
  PeeSafeProduct(
    id: 'ps_intimate_wipes',
    name: 'Natural intimate wipes',
    line: 'Gentle wipes for days away from your own bathroom.',
    slug: 'pee-safe-natural-intimate-wipes-set-of-4-40-wipes',
    image: '$_img/intimate_wipes.jpg',
    moments: {PeeSafeMoment.travel, PeeSafeMoment.hospitalBag},
  ),
  PeeSafeProduct(
    id: 'ps_seat_sanitizer',
    name: 'Toilet seat sanitizer spray',
    line: 'A quick spray for public toilets, when you need them more often in pregnancy.',
    slug: 'pee-safe-toilet-seat-sanitizer-spray-mint-50-ml',
    alsoSlug: 'mini-toilet-seat-sanitizer-spray-floral-25-ml',
    image: '$_img/seat_sanitizer.jpg',
    moments: {PeeSafeMoment.pregnancy, PeeSafeMoment.outingsWithChild, PeeSafeMoment.travel},
  ),
  PeeSafeProduct(
    id: 'ps_jet_spray',
    name: 'Portable jet spray',
    line: 'Gentle rinsing after birth, an alternative to a peri bottle; handy for travel too.',
    slug: 'portable-jet-spray',
    image: '$_img/jet_spray.jpg',
    moments: {PeeSafeMoment.postpartum, PeeSafeMoment.travel},
  ),
  PeeSafeProduct(
    id: 'ps_travels_kit',
    name: 'Safe Travels kit',
    line: 'Seat covers and sanitizer in one pouch, for a babymoon or a family trip.',
    slug: 'safe-travels-kit',
    image: '$_img/travels_kit.jpg',
    moments: {PeeSafeMoment.travel, PeeSafeMoment.pregnancy, PeeSafeMoment.outingsWithChild},
  ),
  PeeSafeProduct(
    id: 'ps_menstrual_cup',
    name: 'Reusable menstrual cup',
    line: 'A reusable option for period days while trying, or once periods return.',
    slug: 'reusable-menstrual-cup-medium',
    image: '$_img/menstrual_cup.jpg',
    moments: {PeeSafeMoment.tryingToConceive, PeeSafeMoment.periodsReturn},
  ),
  PeeSafeProduct(
    id: 'ps_cup_sterilizer',
    name: 'Menstrual cup steam sterilizer',
    line: 'Cleans a cup between cycles.',
    slug: 'pee-safe-menstrual-cup-steam-sterilizer',
    image: '$_img/cup_sterilizer.jpg',
    moments: {PeeSafeMoment.tryingToConceive, PeeSafeMoment.periodsReturn},
  ),
  PeeSafeProduct(
    id: 'ps_cramp_relief',
    name: 'Cramp relief roll-on',
    line: 'A roll-on with herbal extracts for period cramps. Severe pain is worth a word with your doctor.',
    slug: 'pee-safe-feminine-cramp-relief-roll-on-with-ayurveda-extracts-10-ml',
    alsoSlug: 'feminine-herbal-pain-relief-patch',
    image: '$_img/cramp_rollon.jpg',
    moments: {PeeSafeMoment.tryingToConceive, PeeSafeMoment.periodsReturn},
  ),
  PeeSafeProduct(
    id: 'ps_zero_period_kit',
    name: 'Zero Period kit',
    line: 'A starter set for when your periods come back after birth.',
    slug: 'zero-period-kit',
    image: '$_img/zero_period_kit.jpg',
    moments: {PeeSafeMoment.periodsReturn},
  ),
];

/// The products relevant to [moment], in list order.
List<PeeSafeProduct> peeSafeFor(PeeSafeMoment moment) =>
    [for (final p in kPeeSafeProducts) if (p.moments.contains(moment)) p];
