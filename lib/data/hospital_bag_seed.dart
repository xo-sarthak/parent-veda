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
// The second argument is OPTIONAL because this file mixes two shapes: calls
// that were already `_t('English')` mirrors, and bare literals the glossary
// has just wrapped as `_t(en, hi)`. Anything still one-argument is English
// on both sides and therefore still visibly outstanding.
LocalizedText _t(String en, [String? hi]) => LocalizedText(en: en, hi: hi ?? en);

/// Identical in both languages BY NATURE - a brand, a drug name printed on
/// a packet, an acronym a mother reads in Latin either way. Distinct from
/// `_en()`, which means 'English for now, Hindi owed'. This one is finished
/// work, and saying so is what keeps tool/hindi_audit.py honest.
LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

/// A template for a default item (resolved into a [BagItem] at generation time).
class _Seed {
  const _Seed(this.id, this.category, this.name,
      {this.rec, this.onlyFor});
  final String id;
  final BagCategory category;
  final LocalizedText name;
  final BagRecommendation? rec;

  /// If set, the item is only added for this delivery type.
  final DeliveryType? onlyFor;
}

// ---------------------------------------------------------------------------
//  ParentVeda recommendations (trust layer) - placeholder prices.
// ---------------------------------------------------------------------------

final _recNursingBra = BagRecommendation(
  title: _t('Best Overall', 'सबसे बेहतर'),
  price: 799,
  why: [_t('Soft, breathable fabric', 'नरम, साँस लेने वाला कपड़ा'), _t('Easy one-hand nursing access', 'एक हाथ से खुलने वाली, दूध पिलाने में आसान'),
        _t('Loved by ParentVeda parents', 'ParentVeda के माता-पिता की पसंद')],
  consider: [_t('Size up from your usual', 'अपने रोज़ के नाप से एक बड़ा'), _t('Two or three help for rotation', 'दो-तीन रखिए तो बदलती रहेंगी')],
);
final _recBreastPads = BagRecommendation(
  title: _t('Best Overall', 'सबसे बेहतर'),
  price: 299,
  why: [_t('Super absorbent, stay-dry', 'ख़ूब सोखने वाले, सूखा रखने वाले'), _t('Gentle on sensitive skin', 'नाज़ुक त्वचा पर हल्के')],
  consider: [_t('Disposable vs reusable is a personal choice', 'एक बार के या धुलने वाले — यह आपकी पसंद है')],
);
final _recMaternityPads = BagRecommendation(
  price: 349,
  why: [_t('Extra-long, high absorbency', 'ज़्यादा लंबे, ज़्यादा सोखने वाले'), _t('Soft top layer for comfort', 'ऊपर की नरम परत, आराम के लिए'),
        _t('Made for post-delivery flow', 'डिलीवरी के बाद के दिनों के लिए बने')],
  consider: [_t('You will likely need more than you think', 'सोच से ज़्यादा लगेंगे')],
);
final _recNippleCream = BagRecommendation(
  price: 449,
  why: [_t('Soothes sore, sensitive skin', 'दुखती, नाज़ुक त्वचा को आराम'), _t('Safe for baby - no need to wipe off', 'शिशु के लिए सुरक्षित — पोंछने की ज़रूरत नहीं')],
  consider: [_t('A little goes a long way', 'थोड़ा सा ही बहुत है')],
);
final _recSwaddle = BagRecommendation(
  title: _t('Best Overall', 'सबसे बेहतर'),
  price: 599,
  why: [_t('Soft muslin, breathable', 'नरम मलमल, साँस लेने वाला'), _t('Keeps baby snug and calm', 'शिशु को लिपटा और शांत रखता है'),
        _t('Doubles as a nursing cover', 'दूध पिलाते वक़्त ओढ़नी का काम भी करता है')],
  consider: [_t('Muslin for warm weather, fleece for cold', 'गर्मी में मलमल, सर्दी में ऊनी')],
);
final _recBodysuits = BagRecommendation(
  price: 899,
  why: [_t('Gentle cotton on newborn skin', 'नवजात की त्वचा पर हल्का सूती'), _t('Easy snap changes', 'बटन से झट से बदलने वाला'),
        _t('A pack of everyday essentials', 'रोज़ की ज़रूरत का पूरा पैक')],
  consider: [_t('Newborn size is outgrown quickly - do not over-buy', 'नवजात का नाप जल्दी छोटा पड़ जाता है — ज़्यादा मत लीजिए')],
);
final _recDiapers = BagRecommendation(
  price: 499,
  why: [_t('Soft, snug newborn fit', 'नवजात पर नरम और ठीक बैठने वाली'), _t('Wetness indicator', 'गीलेपन का संकेत'), _t('Gentle on the cord stump', 'नाभि की ठूँठ पर हल्की')],
  consider: [_t('Newborn size lasts only a few weeks', 'नवजात का नाप कुछ ही हफ़्ते चलता है')],
);

// ---------------------------------------------------------------------------
//  The default bag.
// ---------------------------------------------------------------------------

final List<_Seed> _seed = [
  // For Me During Labour ----------------------------------------------------
  _Seed('labour_gown', BagCategory.labour, _t('Loose nightwear / birthing gown', 'ढीले कपड़े / प्रसव गाउन')),
  _Seed('labour_socks', BagCategory.labour, _t('Warm socks', 'गर्म मोज़े')),
  _Seed('labour_lipbalm', BagCategory.labour, _same('Lip balm')),
  _Seed('labour_hairties', BagCategory.labour, _t('Hair ties / clip', 'रबर बैंड / क्लिप')),
  _Seed('labour_water', BagCategory.labour, _t('Water bottle with straw', 'स्ट्रॉ वाली पानी की बोतल')),
  _Seed('labour_snacks', BagCategory.labour, _t('Light snacks / energy drinks', 'हल्का नाश्ता / energy drinks')),
  _Seed('labour_glasses', BagCategory.labour, _t('Glasses (if you wear them)', 'चश्मा (अगर आप लगाती हैं)')),
  _Seed('labour_music', BagCategory.labour, _t('Calming music / playlist', 'सुकून देने वाला संगीत / playlist')),

  // For Me After Delivery ---------------------------------------------------
  _Seed('after_pads', BagCategory.afterDelivery, _same('Maternity pads'), rec: _recMaternityPads),
  _Seed('after_underwear', BagCategory.afterDelivery, _t('Disposable / maternity underwear', 'एक बार के / maternity underwear')),
  _Seed('after_nursingbra', BagCategory.afterDelivery, _same('Nursing bra'), rec: _recNursingBra),
  _Seed('after_breastpads', BagCategory.afterDelivery, _same('Breast pads'), rec: _recBreastPads),
  _Seed('after_nipplecream', BagCategory.afterDelivery, _same('Nipple cream'), rec: _recNippleCream),
  _Seed('after_outfit', BagCategory.afterDelivery, _t('Comfortable going-home outfit', 'घर जाने के लिए आरामदेह कपड़े')),
  _Seed('after_toiletries', BagCategory.afterDelivery, _t('Toiletries (toothbrush, etc.)', 'रोज़ के सामान (ब्रश वग़ैरह)')),
  _Seed('after_towel', BagCategory.afterDelivery, _t('Towel', 'तौलिया')),
  _Seed('after_slippers', BagCategory.afterDelivery, _t('Slippers', 'चप्पल')),
  _Seed('after_binder', BagCategory.afterDelivery, _t('Abdominal binder (if advised)', 'पेट की बेल्ट (अगर डॉक्टर कहें)'),
      onlyFor: DeliveryType.csection),

  // For Baby ----------------------------------------------------------------
  _Seed('baby_bodysuits', BagCategory.baby, _t('Newborn bodysuits', 'नवजात के bodysuits'), rec: _recBodysuits),
  _Seed('baby_swaddle', BagCategory.baby, _t('Swaddle / receiving blanket', 'Swaddle / लपेटने वाला कपड़ा'), rec: _recSwaddle),
  _Seed('baby_mittens', BagCategory.baby, _t('Mittens & booties', 'दस्ताने और बूटी')),
  _Seed('baby_cap', BagCategory.baby, _t('Soft cap', 'नरम टोपी')),
  _Seed('baby_diapers', BagCategory.baby, _t('Newborn diapers', 'नवजात के diapers'), rec: _recDiapers),
  _Seed('baby_wipes', BagCategory.baby, _same('Baby wipes')),
  _Seed('baby_blanket', BagCategory.baby, _t('Soft baby blanket', 'नरम शिशु कंबल')),
  _Seed('baby_towel', BagCategory.baby, _t('Baby towel', 'शिशु का तौलिया')),
  _Seed('baby_lotion', BagCategory.baby, _t('Mild baby lotion / oil', 'हल्का baby lotion / तेल')),
  _Seed('baby_homeoutfit', BagCategory.baby, _t('Going-home outfit', 'घर जाने के कपड़े')),

  // For Partner -------------------------------------------------------------
  _Seed('partner_clothes', BagCategory.partner, _t('Change of clothes', 'बदलने के कपड़े')),
  _Seed('partner_snacks', BagCategory.partner, _t('Snacks', 'नाश्ता')),
  _Seed('partner_charger', BagCategory.partner, _t('Phone charger / power bank', 'फ़ोन चार्जर / power bank')),
  _Seed('partner_cash', BagCategory.partner, _t('Cash & cards', 'नक़द और कार्ड')),
  _Seed('partner_toiletries', BagCategory.partner, _t('Toiletries', 'रोज़ के सामान')),

  // Documents ---------------------------------------------------------------
  _Seed('docs_id', BagCategory.documents, _t('ID proof (Aadhaar / passport)', 'पहचान पत्र (Aadhaar / passport)')),
  _Seed('docs_admission', BagCategory.documents, _t('Hospital registration / admission papers', 'अस्पताल के registration / भर्ती के काग़ज़')),
  _Seed('docs_insurance', BagCategory.documents, _same('Insurance / TPA card')),
  _Seed('docs_records', BagCategory.documents, _t('Medical records & scan reports', 'इलाज के काग़ज़ और scan reports')),
  _Seed('docs_birthplan', BagCategory.documents, _t('Birth plan (if you have one)', 'Birth plan (अगर बनाया हो)')),
  _Seed('docs_contacts', BagCategory.documents, _t("Doctor's contact number", 'डॉक्टर का नंबर')),

  // Optional Comfort Items --------------------------------------------------
  _Seed('comfort_pillow', BagCategory.comfort, _t('Your own pillow', 'अपना तकिया')),
  _Seed('comfort_eyemask', BagCategory.comfort, _same('Eye mask')),
  _Seed('comfort_scent', BagCategory.comfort, _t('A familiar, comforting scent', 'कोई जानी-पहचानी, सुकून देने वाली ख़ुशबू')),
  _Seed('comfort_affirm', BagCategory.comfort, _t('Affirmation cards', 'हौसले के कार्ड')),
];

// ---------------------------------------------------------------------------
//  Suggested essentials ("Most mothers also pack") - optional add-ons.
// ---------------------------------------------------------------------------

final List<_Seed> _suggested = [
  _Seed('sugg_nursingpillow', BagCategory.afterDelivery, _same('Nursing pillow')),
  _Seed('sugg_extraoutfit', BagCategory.baby, _t('Extra newborn outfit', 'नवजात के लिए एक और जोड़ा')),
  _Seed('sugg_compsocks', BagCategory.afterDelivery, _same('Compression socks')),
  _Seed('sugg_handfan', BagCategory.labour, _t('Handheld fan', 'छोटा पंखा')),
  _Seed('sugg_speaker', BagCategory.comfort, _t('Portable speaker', 'छोटा speaker')),
  _Seed('sugg_journal', BagCategory.comfort, _t('Journal', 'डायरी')),
];

BagItem _itemFromSeed(_Seed s) => BagItem(
      id: s.id,
      category: s.category,
      name: s.name,
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

/// EVERY catalogue item (default + suggested) as fresh templates - for the
/// "Add items" browser, which shows them all and ticks the ones already in her
/// bag. (Delivery-specific items are included; the bag onboarding filters them.)
List<BagItem> allBagCatalogItems() =>
    [for (final s in [..._seed, ..._suggested]) _itemFromSeed(s)];

/// The catalogue grouped by section, in display order - for the browser.
Map<BagCategory, List<BagItem>> bagCatalogByCategory() {
  final out = <BagCategory, List<BagItem>>{};
  for (final s in [..._seed, ..._suggested]) {
    out.putIfAbsent(s.category, () => []).add(_itemFromSeed(s));
  }
  return out;
}
