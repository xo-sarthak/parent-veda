// =============================================================================
import '../localization/app_language.dart';
//  Hospital bag product catalogue (English-first, placeholder prices)
// -----------------------------------------------------------------------------
//  Each *sellable* bag item is really a product CATEGORY: tapping it shows a
//  small marketplace of options, each with the ParentVeda "why we recommend it"
//  trust layer. Non-sellable items (documents, personal things) have no products
//  and just use the simple status sheet.
//
//  Images: each product carries an optional [imageUrl]; when null the UI shows a
//  soft emoji tile, so real photos/links can be dropped in later without code
//  changes.
// =============================================================================

LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

/// A purchasable product option shown under a sellable bag item.
class BagProduct {
  const BagProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    this.topPick = false,
    this.why = const [],
    this.consider = const [],
    this.imageUrl,
    this.isAffiliate = false,
    this.store = '',
    this.link = '',
  });

  final String id;
  final LocalizedText name;
  final int price; // ₹, placeholder
  final String emoji;
  final bool topPick; // ParentVeda "Best Overall"
  final List<LocalizedText> why; // why ParentVeda recommends it
  final List<LocalizedText> consider; // things to consider
  final String? imageUrl; // optional real photo (network)

  // Affiliate option (sold elsewhere, e.g. Amazon/FirstCry) → "Buy" opens the
  // external site, NO in-app cart - mirrors Product.isAffiliate in the product
  // checklist. ParentVeda picks (false) are chosen as her "buy from us" option.
  final bool isAffiliate;
  final String store; // 'Amazon' | 'FirstCry' (affiliate only)
  final String link; // external URL (affiliate only)
}

/// A best-overall product spec for a sellable item (the value option is derived).
class _Cat {
  const _Cat(this.emoji, this.price, this.brand,
      {this.why = const [], this.consider = const []});
  final String emoji;
  final int price;
  final LocalizedText brand;
  final List<LocalizedText> why;
  final List<LocalizedText> consider;
}

final Map<String, _Cat> _catalog = {
  // For me during labour ----------------------------------------------------
  'labour_gown': _Cat('👗', 699, _t('ParentVeda Birthing Gown', 'ParentVeda प्रसव गाउन'),
      why: [_t('Soft, breathable cotton', 'नरम, साँस लेने वाला सूती'), _t('Front-open for skin-to-skin & feeding', 'आगे से खुलने वाला — त्वचा से त्वचा और दूध पिलाने के लिए')],
      consider: [_t('Darker shades hide stains', 'गहरे रंग दाग़ छिपा लेते हैं')]),
  'labour_socks': _Cat('🧦', 199, _t('ParentVeda Grip Socks', 'ParentVeda पकड़ वाले मोज़े'),
      why: [_t('Warm for cold labour rooms', 'ठंडे प्रसव कक्ष में गर्म'), _t('Non-slip soles', 'न फिसलने वाले तले')]),
  'labour_lipbalm': _Cat('🧴', 149, _t('ParentVeda Lip Balm', 'ParentVeda Lip Balm'),
      why: [_t('Heavy breathing dries lips fast', 'तेज़ साँस से होंठ जल्दी सूखते हैं'), _t('Natural, safe ingredients', 'क़ुदरती, सुरक्षित सामग्री')]),
  'labour_hairties': _Cat('🎀', 99, _t('ParentVeda Soft Scrunchies', 'ParentVeda नरम Scrunchies'),
      why: [_t('Keeps hair off your face', 'बाल चेहरे से दूर रखता है'), _t('Gentle, no-pull hold', 'हल्की पकड़, बाल नहीं खींचती')]),
  'labour_water': _Cat('🥤', 299, _t('ParentVeda Straw Bottle', 'ParentVeda स्ट्रॉ वाली बोतल'),
      why: [_t('Sip lying down without spills', 'लेटे-लेटे घूँट, बिना गिराए'), _t('Stays cool for hours', 'घंटों ठंडा रहता है')]),
  'labour_snacks': _Cat('🍫', 199, _t('ParentVeda Energy Bites', 'ParentVeda Energy Bites'),
      why: [_t('Quick energy between contractions', 'संकुचन के बीच तुरंत ऊर्जा'), _t('Easy to digest', 'आसानी से पचने वाला')],
      consider: [_t('Check what your hospital allows', 'अपने अस्पताल से पूछ लीजिए क्या ले जा सकती हैं')]),

  // For me after delivery ---------------------------------------------------
  'after_pads': _Cat('🩸', 349, _t('ParentVeda Maternity Pads', 'ParentVeda Maternity Pads'),
      why: [_t('Extra-long, high absorbency', 'ज़्यादा लंबे, ज़्यादा सोखने वाले'), _t('Soft top layer for comfort', 'ऊपर की नरम परत, आराम के लिए')],
      consider: [_t('You will need more than you think', 'सोच से ज़्यादा लगेंगे')]),
  'after_underwear': _Cat('🩲', 399, _t('ParentVeda Maternity Briefs', 'ParentVeda Maternity Briefs'),
      why: [
        _t('High-waist, won’t press on stitches', 'ऊँची कमर, टाँकों पर दबाव नहीं'),
        _t('Soft, breathable & disposable', 'नरम, साँस लेने वाले और एक बार के')
      ],
      consider: [_t('Size up for comfort', 'आराम के लिए एक नाप बड़ा लीजिए')]),
  'after_nursingbra': _Cat('👙', 799, _t('ParentVeda Nursing Bra', 'ParentVeda Nursing Bra'),
      why: [_t('Soft, breathable fabric', 'नरम, साँस लेने वाला कपड़ा'), _t('Easy one-hand nursing access', 'एक हाथ से खुलने वाली, दूध पिलाने में आसान')],
      consider: [_t('Size up from your usual', 'अपने रोज़ के नाप से एक बड़ा')]),
  'after_breastpads': _Cat('⚪', 299, _t('ParentVeda Breast Pads', 'ParentVeda Breast Pads'),
      why: [_t('Super absorbent, stay-dry', 'ख़ूब सोखने वाले, सूखा रखने वाले'), _t('Gentle on sensitive skin', 'नाज़ुक त्वचा पर हल्के')]),
  'after_nipplecream': _Cat('🧴', 449, _t('ParentVeda Nipple Cream', 'ParentVeda Nipple Cream'),
      why: [_t('Soothes sore skin', 'दुखती त्वचा को आराम'), _t('Safe for baby - no need to wipe off', 'शिशु के लिए सुरक्षित — पोंछने की ज़रूरत नहीं')]),
  'after_outfit': _Cat('👗', 899, _t('ParentVeda Going-Home Set', 'ParentVeda घर जाने का सेट'),
      why: [_t('Loose & soft on a healing body', 'ठीक हो रहे शरीर पर ढीला और नरम'), _t('Easy nursing access', 'दूध पिलाने में आसान')]),
  'after_toiletries': _Cat('🪥', 299, _t('ParentVeda Travel Kit', 'ParentVeda सफ़र किट'),
      why: [_t('Hospital-ready travel sizes', 'अस्पताल के लिए छोटे पैक'), _t('Gentle, fragrance-free', 'हल्के, बिना ख़ुशबू के')]),
  'after_towel': _Cat('🧖', 399, _t('ParentVeda Soft Towel', 'ParentVeda नरम तौलिया'),
      why: [_t('Soft & quick-drying', 'नरम और जल्दी सूखने वाला'), _t('Compact for the bag', 'बैग में आसानी से समाने वाला')]),
  'after_slippers': _Cat('🥿', 299, _t('ParentVeda Slip-ons', 'ParentVeda आरामदेह चप्पल'),
      why: [_t('Easy slip-on, washable', 'झट से पहनने वाले, धुलने वाले'), _t('Cushioned sole', 'गद्देदार तला')]),
  'after_binder': _Cat('🩹', 699, _t('ParentVeda Belly Binder', 'ParentVeda पेट की बेल्ट'),
      why: [_t('Gentle support after a C-section', 'C-section के बाद हल्का सहारा'), _t('Adjustable fit', 'अपने हिसाब से कसा जा सकता है')],
      consider: [_t('Use only if your doctor advises', 'सिर्फ़ तब लीजिए जब डॉक्टर कहें')]),

  // For baby ----------------------------------------------------------------
  'baby_bodysuits': _Cat('👶', 899, _t('ParentVeda Newborn Bodysuits', 'ParentVeda नवजात Bodysuits'),
      why: [_t('Gentle cotton on newborn skin', 'नवजात की त्वचा पर हल्का सूती'), _t('Easy snap changes', 'बटन से झट से बदलने वाला')],
      consider: [_t('Newborn size is outgrown quickly', 'नवजात का नाप जल्दी छोटा पड़ जाता है')]),
  'baby_swaddle': _Cat('🧣', 599, _t('ParentVeda Muslin Swaddle', 'ParentVeda मलमल का Swaddle'),
      why: [_t('Soft muslin, breathable', 'नरम मलमल, साँस लेने वाला'), _t('Keeps baby snug & calm', 'शिशु को लिपटा और शांत रखता है')],
      consider: [_t('Muslin for warm weather, fleece for cold', 'गर्मी में मलमल, सर्दी में ऊनी')]),
  'baby_mittens': _Cat('🧤', 299, _t('ParentVeda Mittens & Booties', 'ParentVeda दस्ताने और बूटी'),
      why: [_t('Keeps tiny hands & feet warm', 'नन्हे हाथ-पैर गर्म रखते हैं'), _t('Prevents face scratches', 'चेहरे पर खरोंच नहीं लगने देते')]),
  'baby_cap': _Cat('🧢', 199, _t('ParentVeda Soft Cap', 'ParentVeda नरम टोपी'),
      why: [_t('Newborns lose heat from the head', 'नवजात सिर से गर्मी खोते हैं'), _t('Soft, seam-free', 'नरम, बिना सिलाई के')]),
  'baby_diapers': _Cat('🧷', 499, _t('ParentVeda Newborn Diapers', 'ParentVeda नवजात Diapers'),
      why: [_t('Soft, snug newborn fit', 'नवजात पर नरम और ठीक बैठने वाली'), _t('Wetness indicator', 'गीलेपन का संकेत'), _t('Gentle on the cord stump', 'नाभि की ठूँठ पर हल्की')],
      consider: [_t('Newborn size lasts only a few weeks', 'नवजात का नाप कुछ ही हफ़्ते चलता है')]),
  'baby_wipes': _Cat('🧻', 249, _t('ParentVeda Water Wipes', 'ParentVeda Water Wipes'),
      why: [_t('99% water, fragrance-free', '99% पानी, बिना ख़ुशबू के'), _t('Gentle on newborn skin', 'नवजात की त्वचा पर हल्के')]),
  'baby_blanket': _Cat('🛏️', 499, _t('ParentVeda Baby Blanket', 'ParentVeda शिशु कंबल'),
      why: [_t('Cozy & breathable', 'गर्म और साँस लेने वाला'), _t('Doubles as a cover', 'ओढ़नी के तौर पर भी काम आता है')]),
  'baby_towel': _Cat('🧖', 399, _t('ParentVeda Hooded Towel', 'ParentVeda टोपी वाला तौलिया'),
      why: [_t('Hooded, soft on delicate skin', 'टोपी वाला, नाज़ुक त्वचा पर नरम'), _t('Quick-drying', 'जल्दी सूखने वाला')]),
  'baby_lotion': _Cat('🧴', 349, _t('ParentVeda Baby Lotion', 'ParentVeda Baby Lotion'),
      why: [_t('Gentle, hypoallergenic', 'हल्का, एलर्जी की कम आशंका'), _t('Light & non-greasy', 'हल्का, चिपचिपा नहीं')],
      consider: [_t('Patch-test first', 'पहले थोड़ा सा लगाकर देख लीजिए')]),
  'baby_homeoutfit': _Cat('👕', 599, _t('ParentVeda First Outfit', 'ParentVeda पहला जोड़ा'),
      why: [_t('Soft first outfit for home & photos', 'घर और तस्वीरों के लिए पहला नरम जोड़ा'), _t('Easy to put on', 'पहनाने में आसान')],
      consider: [_t('Newborn size', 'नवजात का नाप')]),

  // For partner -------------------------------------------------------------
  'partner_snacks': _Cat('🍪', 199, _t('ParentVeda Snack Pack', 'ParentVeda नाश्ते का पैक'),
      why: [_t('Keeps your partner going', 'आपके पार्टनर को चलता रखता है'), _t('Long shelf life', 'लंबे समय तक ख़राब नहीं होता')]),
  'partner_charger': _Cat('🔋', 999, _t('ParentVeda Power Bank', 'ParentVeda Power Bank'),
      why: [_t('Long cable for hospital beds', 'अस्पताल के बिस्तर के लिए लंबी तार'), _t('Backup power for long stays', 'लंबे ठहराव के लिए बैकअप पावर')]),
  'partner_toiletries': _Cat('🧼', 249, _t('ParentVeda Travel Kit', 'ParentVeda सफ़र किट'),
      why: [_t('Travel-size basics', 'सफ़र के छोटे पैक'), _t('Compact & light', 'छोटा और हल्का')]),

  // Comfort -----------------------------------------------------------------
  'comfort_eyemask': _Cat('😴', 199, _t('ParentVeda Eye Mask', 'ParentVeda Eye Mask'),
      why: [_t('Blocks out bright hospital lights', 'अस्पताल की तेज़ रोशनी रोकता है'), _t('Soft & gentle', 'नरम और हल्का')]),
  'comfort_affirm': _Cat('🃏', 299, _t('ParentVeda Affirmation Cards', 'ParentVeda हौसले के कार्ड'),
      why: [_t('Gentle focus during labour', 'प्रसव के दौरान हल्का ध्यान'), _t('Written for Indian mothers', 'भारतीय माँओं के लिए लिखा गया')]),

  // Suggested essentials ----------------------------------------------------
  'sugg_nursingpillow': _Cat('🛋️', 1299, _t('ParentVeda Nursing Pillow', 'ParentVeda Nursing Pillow'),
      why: [_t('Supports baby at the breast', 'दूध पिलाते वक़्त शिशु को सहारा'), _t('Eases arm & back strain', 'बाँह और कमर का ज़ोर कम करता है')]),
  'sugg_extraoutfit': _Cat('👕', 599, _t('ParentVeda Extra Outfit', 'ParentVeda एक और जोड़ा'),
      why: [_t('A spare for the inevitable changes', 'एक अतिरिक्त, क्योंकि बदलना पड़ेगा ही'), _t('Soft newborn cotton', 'नवजात के लिए नरम सूती')]),
  'sugg_compsocks': _Cat('🧦', 399, _t('ParentVeda Compression Socks', 'ParentVeda Compression Socks'),
      why: [_t('Eases swelling & aches', 'सूजन और दर्द में आराम'), _t('Comfortable all-day wear', 'दिन भर पहनने में आरामदेह')]),
  'sugg_handfan': _Cat('🌬️', 299, _t('ParentVeda Mini Fan', 'ParentVeda छोटा पंखा'),
      why: [_t('Cooling relief during labour', 'प्रसव के दौरान ठंडक'), _t('USB-rechargeable', 'USB से चार्ज होने वाला')]),
};

/// Items that are genuinely not products (no marketplace / no recommendation).
final Set<String> _nonSellable = {
  'docs_id', 'docs_admission', 'docs_insurance', 'docs_records',
  'docs_birthplan', 'docs_contacts',
  'labour_glasses', 'labour_music',
  'partner_clothes', 'partner_cash',
  'comfort_pillow', 'comfort_scent',
  'sugg_speaker', 'sugg_journal',
};

/// True if a bag item should behave as a product category (marketplace + trust
/// layer). Custom and explicitly non-sellable items return false.
bool bagIsSellable(String itemId, {bool isCustom = false}) =>
    !isCustom && !_nonSellable.contains(itemId) && itemId.isNotEmpty;

/// Derives the budget option's name from the ParentVeda one.
///
/// This is the surgery that started the identity-vs-display lesson: it strips
/// a literal prefix off a product name. Now that `brand` is bilingual the
/// strip has to happen on BOTH halves independently - the prefix itself stays
/// Latin ("ParentVeda " is a brand), but the words spliced in front differ per
/// language, and running it on one half would leave the other unchanged.
LocalizedText _valueName(LocalizedText brand) {
  const prefix = 'ParentVeda ';
  if (!brand.en.startsWith(prefix)) {
    return _t('Everyday option', 'साधारण विकल्प');
  }
  return LocalizedText(
    // The trailing space is load-bearing: it separates the word from the
    // product name that follows.
    en: brand.en.replaceFirst(prefix, 'Everyday '),
    hi: brand.hi.replaceFirst(prefix, 'साधारण '),
  );
}

/// The product options for a sellable item: the ParentVeda "Best Overall" pick
/// plus a derived value option. Empty for non-sellable items.
List<BagProduct> bagProductsFor(String itemId, {bool isCustom = false}) {
  if (!bagIsSellable(itemId, isCustom: isCustom)) return const [];
  final c = _catalog[itemId];
  final emoji = c?.emoji ?? '🛍️';
  final base = c?.price ?? 399;
  // .en: this becomes a store search URL, so it identifies a product to an
  // external site rather than showing her anything.
  final query = c?.brand.en ?? itemId.replaceAll('_', ' ');
  final out = <BagProduct>[];
  if (c == null) {
    // Sellable but uncatalogued - a gentle generic recommendation.
    out.add(BagProduct(
      id: '${itemId}_pv',
      name: _t('ParentVeda pick', 'ParentVeda की पसंद'),
      price: 399,
      emoji: '🛍️',
      topPick: true,
      why: [_t('Chosen for quality & comfort', 'गुणवत्ता और आराम देखकर चुना गया'), _t('Trusted by ParentVeda parents', 'ParentVeda के माता-पिता का भरोसा')],
    ));
  } else {
    final valuePrice = ((c.price * 0.8) / 10).round() * 10;
    out.add(BagProduct(
      id: '${itemId}_pv',
      name: c.brand,
      price: c.price,
      emoji: c.emoji,
      topPick: true,
      why: c.why,
      consider: c.consider,
    ));
    out.add(BagProduct(
      id: '${itemId}_value',
      name: _valueName(c.brand),
      price: valuePrice,
      emoji: c.emoji,
      why: [_t('A simpler, budget-friendly option', 'एक सरल, कम दाम वाला विकल्प')],
    ));
  }
  // Affiliate options (sold elsewhere) - the same split as the product checklist.
  out.add(_affiliate(
        itemId, 'amazon', 'Amazon', (base * 1.05).round(), emoji, query));
  out.add(_affiliate(
      itemId, 'firstcry', 'FirstCry', (base * 0.95).round(), emoji, query));
  return out;
}

BagProduct _affiliate(String itemId, String key, String store, int price,
    String emoji, String query) {
  final q = Uri.encodeComponent(query);
  final url = store == 'Amazon'
      ? 'https://www.amazon.in/s?k=$q'
      : 'https://www.firstcry.com/search?q=$q';
  return BagProduct(
    id: '${itemId}_$key',
    // The store brand reads the same in both scripts.
    name: LocalizedText(en: store, hi: store),
    price: price,
    emoji: emoji,
    isAffiliate: true,
    store: store,
    link: url,
  );
}

/// The ParentVeda best-overall product for an item (or null if non-sellable).
BagProduct? bagBestProduct(String itemId, {bool isCustom = false}) {
  final ps = bagProductsFor(itemId, isCustom: isCustom);
  return ps.isEmpty ? null : ps.first;
}
