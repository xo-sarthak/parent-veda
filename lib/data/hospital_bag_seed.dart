// =============================================================================
//  Hospital bag seed content (English-first)
// -----------------------------------------------------------------------------
//  The default "smart" bag and the optional "suggested essentials". Authored in
//  Dart so it's type-safe and easy to extend. English-first: names use
//  LocalizedText with hi == en for now, so Hindi can be filled in later without
//  restructuring. Prices are placeholders until a real catalogue/links exist.
// =============================================================================

import '../localization/app_language.dart';
import '../services/hospital_bag_store.dart';

/// English-first localized text (Hindi can be added later).
LocalizedText _t(String s) => LocalizedText(en: s, hi: s);

/// A template for a default item (resolved into a [BagItem] at generation time).
class _Seed {
  const _Seed(this.id, this.category, this.name,
      {this.rec, this.onlyFor});
  final String id;
  final BagCategory category;
  final String name;
  final BagRecommendation? rec;

  /// If set, the item is only added for this delivery type.
  final DeliveryType? onlyFor;
}

// ---------------------------------------------------------------------------
//  ParentVeda recommendations (trust layer) — placeholder prices.
// ---------------------------------------------------------------------------

const _recNursingBra = BagRecommendation(
  title: 'Best Overall',
  price: 799,
  why: ['Soft, breathable fabric', 'Easy one-hand nursing access',
        'Loved by ParentVeda parents'],
  consider: ['Size up from your usual', 'Two or three help for rotation'],
);
const _recBreastPads = BagRecommendation(
  title: 'Best Overall',
  price: 299,
  why: ['Super absorbent, stay-dry', 'Gentle on sensitive skin'],
  consider: ['Disposable vs reusable is a personal choice'],
);
const _recMaternityPads = BagRecommendation(
  price: 349,
  why: ['Extra-long, high absorbency', 'Soft top layer for comfort',
        'Made for post-delivery flow'],
  consider: ['You will likely need more than you think'],
);
const _recNippleCream = BagRecommendation(
  price: 449,
  why: ['Soothes sore, sensitive skin', 'Safe for baby — no need to wipe off'],
  consider: ['A little goes a long way'],
);
const _recSwaddle = BagRecommendation(
  title: 'Best Overall',
  price: 599,
  why: ['Soft muslin, breathable', 'Keeps baby snug and calm',
        'Doubles as a nursing cover'],
  consider: ['Muslin for warm weather, fleece for cold'],
);
const _recBodysuits = BagRecommendation(
  price: 899,
  why: ['Gentle cotton on newborn skin', 'Easy snap changes',
        'A pack of everyday essentials'],
  consider: ['Newborn size is outgrown quickly — do not over-buy'],
);
const _recDiapers = BagRecommendation(
  price: 499,
  why: ['Soft, snug newborn fit', 'Wetness indicator', 'Gentle on the cord stump'],
  consider: ['Newborn size lasts only a few weeks'],
);

// ---------------------------------------------------------------------------
//  The default bag.
// ---------------------------------------------------------------------------

const List<_Seed> _seed = [
  // For Me During Labour ----------------------------------------------------
  _Seed('labour_gown', BagCategory.labour, 'Loose nightwear / birthing gown'),
  _Seed('labour_socks', BagCategory.labour, 'Warm socks'),
  _Seed('labour_lipbalm', BagCategory.labour, 'Lip balm'),
  _Seed('labour_hairties', BagCategory.labour, 'Hair ties / clip'),
  _Seed('labour_water', BagCategory.labour, 'Water bottle with straw'),
  _Seed('labour_snacks', BagCategory.labour, 'Light snacks / energy drinks'),
  _Seed('labour_glasses', BagCategory.labour, 'Glasses (if you wear them)'),
  _Seed('labour_music', BagCategory.labour, 'Calming music / playlist'),

  // For Me After Delivery ---------------------------------------------------
  _Seed('after_pads', BagCategory.afterDelivery, 'Maternity pads', rec: _recMaternityPads),
  _Seed('after_underwear', BagCategory.afterDelivery, 'Disposable / maternity underwear'),
  _Seed('after_nursingbra', BagCategory.afterDelivery, 'Nursing bra', rec: _recNursingBra),
  _Seed('after_breastpads', BagCategory.afterDelivery, 'Breast pads', rec: _recBreastPads),
  _Seed('after_nipplecream', BagCategory.afterDelivery, 'Nipple cream', rec: _recNippleCream),
  _Seed('after_outfit', BagCategory.afterDelivery, 'Comfortable going-home outfit'),
  _Seed('after_toiletries', BagCategory.afterDelivery, 'Toiletries (toothbrush, etc.)'),
  _Seed('after_towel', BagCategory.afterDelivery, 'Towel'),
  _Seed('after_slippers', BagCategory.afterDelivery, 'Slippers'),
  _Seed('after_binder', BagCategory.afterDelivery, 'Abdominal binder (if advised)',
      onlyFor: DeliveryType.csection),

  // For Baby ----------------------------------------------------------------
  _Seed('baby_bodysuits', BagCategory.baby, 'Newborn bodysuits', rec: _recBodysuits),
  _Seed('baby_swaddle', BagCategory.baby, 'Swaddle / receiving blanket', rec: _recSwaddle),
  _Seed('baby_mittens', BagCategory.baby, 'Mittens & booties'),
  _Seed('baby_cap', BagCategory.baby, 'Soft cap'),
  _Seed('baby_diapers', BagCategory.baby, 'Newborn diapers', rec: _recDiapers),
  _Seed('baby_wipes', BagCategory.baby, 'Baby wipes'),
  _Seed('baby_blanket', BagCategory.baby, 'Soft baby blanket'),
  _Seed('baby_towel', BagCategory.baby, 'Baby towel'),
  _Seed('baby_lotion', BagCategory.baby, 'Mild baby lotion / oil'),
  _Seed('baby_homeoutfit', BagCategory.baby, 'Going-home outfit'),

  // For Partner -------------------------------------------------------------
  _Seed('partner_clothes', BagCategory.partner, 'Change of clothes'),
  _Seed('partner_snacks', BagCategory.partner, 'Snacks'),
  _Seed('partner_charger', BagCategory.partner, 'Phone charger / power bank'),
  _Seed('partner_cash', BagCategory.partner, 'Cash & cards'),
  _Seed('partner_toiletries', BagCategory.partner, 'Toiletries'),

  // Documents ---------------------------------------------------------------
  _Seed('docs_id', BagCategory.documents, 'ID proof (Aadhaar / passport)'),
  _Seed('docs_admission', BagCategory.documents, 'Hospital registration / admission papers'),
  _Seed('docs_insurance', BagCategory.documents, 'Insurance / TPA card'),
  _Seed('docs_records', BagCategory.documents, 'Medical records & scan reports'),
  _Seed('docs_birthplan', BagCategory.documents, 'Birth plan (if you have one)'),
  _Seed('docs_contacts', BagCategory.documents, "Doctor's contact number"),

  // Optional Comfort Items --------------------------------------------------
  _Seed('comfort_pillow', BagCategory.comfort, 'Your own pillow'),
  _Seed('comfort_eyemask', BagCategory.comfort, 'Eye mask'),
  _Seed('comfort_scent', BagCategory.comfort, 'A familiar, comforting scent'),
  _Seed('comfort_affirm', BagCategory.comfort, 'Affirmation cards'),
];

// ---------------------------------------------------------------------------
//  Suggested essentials ("Most mothers also pack") — optional add-ons.
// ---------------------------------------------------------------------------

const List<_Seed> _suggested = [
  _Seed('sugg_nursingpillow', BagCategory.afterDelivery, 'Nursing pillow'),
  _Seed('sugg_extraoutfit', BagCategory.baby, 'Extra newborn outfit'),
  _Seed('sugg_compsocks', BagCategory.afterDelivery, 'Compression socks'),
  _Seed('sugg_handfan', BagCategory.labour, 'Handheld fan'),
  _Seed('sugg_speaker', BagCategory.comfort, 'Portable speaker'),
  _Seed('sugg_journal', BagCategory.comfort, 'Journal'),
];

BagItem _itemFromSeed(_Seed s) => BagItem(
      id: s.id,
      category: s.category,
      name: _t(s.name),
      recommendation: s.rec,
    );

/// Build the default bag for a delivery type. Items flagged for a specific
/// delivery type are only included when it matches.
List<BagItem> generateDefaultBag(DeliveryType delivery) => [
      for (final s in _seed)
        if (s.onlyFor == null || s.onlyFor == delivery) _itemFromSeed(s),
    ];

/// The optional suggested-essentials a mother can tap to add.
List<BagItem> suggestedEssentials() =>
    [for (final s in _suggested) _itemFromSeed(s)];

/// EVERY catalogue item (default + suggested) as fresh templates — for the
/// "Add items" browser, which shows them all and ticks the ones already in her
/// bag. (Delivery-specific items are included; the bag onboarding filters them.)
List<BagItem> allBagCatalogItems() =>
    [for (final s in [..._seed, ..._suggested]) _itemFromSeed(s)];

/// The catalogue grouped by section, in display order — for the browser.
Map<BagCategory, List<BagItem>> bagCatalogByCategory() {
  final out = <BagCategory, List<BagItem>>{};
  for (final s in [..._seed, ..._suggested]) {
    out.putIfAbsent(s.category, () => []).add(_itemFromSeed(s));
  }
  return out;
}
