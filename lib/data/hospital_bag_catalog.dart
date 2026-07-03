// =============================================================================
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
  final String name;
  final int price; // ₹, placeholder
  final String emoji;
  final bool topPick; // ParentVeda "Best Overall"
  final List<String> why; // why ParentVeda recommends it
  final List<String> consider; // things to consider
  final String? imageUrl; // optional real photo (network)

  // Affiliate option (sold elsewhere, e.g. Amazon/FirstCry) → "Buy" opens the
  // external site, NO in-app cart — mirrors Product.isAffiliate in the product
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
  final String brand;
  final List<String> why;
  final List<String> consider;
}

const Map<String, _Cat> _catalog = {
  // For me during labour ----------------------------------------------------
  'labour_gown': _Cat('👗', 699, 'ParentVeda Birthing Gown',
      why: ['Soft, breathable cotton', 'Front-open for skin-to-skin & feeding'],
      consider: ['Darker shades hide stains']),
  'labour_socks': _Cat('🧦', 199, 'ParentVeda Grip Socks',
      why: ['Warm for cold labour rooms', 'Non-slip soles']),
  'labour_lipbalm': _Cat('🧴', 149, 'ParentVeda Lip Balm',
      why: ['Heavy breathing dries lips fast', 'Natural, safe ingredients']),
  'labour_hairties': _Cat('🎀', 99, 'ParentVeda Soft Scrunchies',
      why: ['Keeps hair off your face', 'Gentle, no-pull hold']),
  'labour_water': _Cat('🥤', 299, 'ParentVeda Straw Bottle',
      why: ['Sip lying down without spills', 'Stays cool for hours']),
  'labour_snacks': _Cat('🍫', 199, 'ParentVeda Energy Bites',
      why: ['Quick energy between contractions', 'Easy to digest'],
      consider: ['Check what your hospital allows']),

  // For me after delivery ---------------------------------------------------
  'after_pads': _Cat('🩸', 349, 'ParentVeda Maternity Pads',
      why: ['Extra-long, high absorbency', 'Soft top layer for comfort'],
      consider: ['You will need more than you think']),
  'after_underwear': _Cat('🩲', 399, 'ParentVeda Maternity Briefs',
      why: [
        'High-waist, won’t press on stitches',
        'Soft, breathable & disposable'
      ],
      consider: ['Size up for comfort']),
  'after_nursingbra': _Cat('👙', 799, 'ParentVeda Nursing Bra',
      why: ['Soft, breathable fabric', 'Easy one-hand nursing access'],
      consider: ['Size up from your usual']),
  'after_breastpads': _Cat('⚪', 299, 'ParentVeda Breast Pads',
      why: ['Super absorbent, stay-dry', 'Gentle on sensitive skin']),
  'after_nipplecream': _Cat('🧴', 449, 'ParentVeda Nipple Cream',
      why: ['Soothes sore skin', 'Safe for baby — no need to wipe off']),
  'after_outfit': _Cat('👗', 899, 'ParentVeda Going-Home Set',
      why: ['Loose & soft on a healing body', 'Easy nursing access']),
  'after_toiletries': _Cat('🪥', 299, 'ParentVeda Travel Kit',
      why: ['Hospital-ready travel sizes', 'Gentle, fragrance-free']),
  'after_towel': _Cat('🧖', 399, 'ParentVeda Soft Towel',
      why: ['Soft & quick-drying', 'Compact for the bag']),
  'after_slippers': _Cat('🥿', 299, 'ParentVeda Slip-ons',
      why: ['Easy slip-on, washable', 'Cushioned sole']),
  'after_binder': _Cat('🩹', 699, 'ParentVeda Belly Binder',
      why: ['Gentle support after a C-section', 'Adjustable fit'],
      consider: ['Use only if your doctor advises']),

  // For baby ----------------------------------------------------------------
  'baby_bodysuits': _Cat('👶', 899, 'ParentVeda Newborn Bodysuits',
      why: ['Gentle cotton on newborn skin', 'Easy snap changes'],
      consider: ['Newborn size is outgrown quickly']),
  'baby_swaddle': _Cat('🧣', 599, 'ParentVeda Muslin Swaddle',
      why: ['Soft muslin, breathable', 'Keeps baby snug & calm'],
      consider: ['Muslin for warm weather, fleece for cold']),
  'baby_mittens': _Cat('🧤', 299, 'ParentVeda Mittens & Booties',
      why: ['Keeps tiny hands & feet warm', 'Prevents face scratches']),
  'baby_cap': _Cat('🧢', 199, 'ParentVeda Soft Cap',
      why: ['Newborns lose heat from the head', 'Soft, seam-free']),
  'baby_diapers': _Cat('🧷', 499, 'ParentVeda Newborn Diapers',
      why: ['Soft, snug newborn fit', 'Wetness indicator', 'Gentle on the cord stump'],
      consider: ['Newborn size lasts only a few weeks']),
  'baby_wipes': _Cat('🧻', 249, 'ParentVeda Water Wipes',
      why: ['99% water, fragrance-free', 'Gentle on newborn skin']),
  'baby_blanket': _Cat('🛏️', 499, 'ParentVeda Baby Blanket',
      why: ['Cozy & breathable', 'Doubles as a cover']),
  'baby_towel': _Cat('🧖', 399, 'ParentVeda Hooded Towel',
      why: ['Hooded, soft on delicate skin', 'Quick-drying']),
  'baby_lotion': _Cat('🧴', 349, 'ParentVeda Baby Lotion',
      why: ['Gentle, hypoallergenic', 'Light & non-greasy'],
      consider: ['Patch-test first']),
  'baby_homeoutfit': _Cat('👕', 599, 'ParentVeda First Outfit',
      why: ['Soft first outfit for home & photos', 'Easy to put on'],
      consider: ['Newborn size']),

  // For partner -------------------------------------------------------------
  'partner_snacks': _Cat('🍪', 199, 'ParentVeda Snack Pack',
      why: ['Keeps your partner going', 'Long shelf life']),
  'partner_charger': _Cat('🔋', 999, 'ParentVeda Power Bank',
      why: ['Long cable for hospital beds', 'Backup power for long stays']),
  'partner_toiletries': _Cat('🧼', 249, 'ParentVeda Travel Kit',
      why: ['Travel-size basics', 'Compact & light']),

  // Comfort -----------------------------------------------------------------
  'comfort_eyemask': _Cat('😴', 199, 'ParentVeda Eye Mask',
      why: ['Blocks out bright hospital lights', 'Soft & gentle']),
  'comfort_affirm': _Cat('🃏', 299, 'ParentVeda Affirmation Cards',
      why: ['Gentle focus during labour', 'Written for Indian mothers']),

  // Suggested essentials ----------------------------------------------------
  'sugg_nursingpillow': _Cat('🛋️', 1299, 'ParentVeda Nursing Pillow',
      why: ['Supports baby at the breast', 'Eases arm & back strain']),
  'sugg_extraoutfit': _Cat('👕', 599, 'ParentVeda Extra Outfit',
      why: ['A spare for the inevitable changes', 'Soft newborn cotton']),
  'sugg_compsocks': _Cat('🧦', 399, 'ParentVeda Compression Socks',
      why: ['Eases swelling & aches', 'Comfortable all-day wear']),
  'sugg_handfan': _Cat('🌬️', 299, 'ParentVeda Mini Fan',
      why: ['Cooling relief during labour', 'USB-rechargeable']),
};

/// Items that are genuinely not products (no marketplace / no recommendation).
const Set<String> _nonSellable = {
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

String _valueName(String brand) => brand.startsWith('ParentVeda ')
    ? brand.replaceFirst('ParentVeda ', 'Everyday ')
    : 'Everyday option';

/// The product options for a sellable item: the ParentVeda "Best Overall" pick
/// plus a derived value option. Empty for non-sellable items.
List<BagProduct> bagProductsFor(String itemId, {bool isCustom = false}) {
  if (!bagIsSellable(itemId, isCustom: isCustom)) return const [];
  final c = _catalog[itemId];
  final emoji = c?.emoji ?? '🛍️';
  final base = c?.price ?? 399;
  final query = c?.brand ?? itemId.replaceAll('_', ' ');
  final out = <BagProduct>[];
  if (c == null) {
    // Sellable but uncatalogued — a gentle generic recommendation.
    out.add(BagProduct(
      id: '${itemId}_pv',
      name: 'ParentVeda pick',
      price: 399,
      emoji: '🛍️',
      topPick: true,
      why: const ['Chosen for quality & comfort', 'Trusted by ParentVeda parents'],
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
      why: const ['A simpler, budget-friendly option'],
    ));
  }
  // Affiliate options (sold elsewhere) — the same split as the product checklist.
  out.add(_affiliate(itemId, 'amazon', 'Amazon', (base * 1.05).round(), emoji, query));
  out.add(_affiliate(
      itemId, 'firstcry', 'FirstCry', (base * 0.95).round(), emoji, query));
  return out;
}

BagProduct _affiliate(
    String itemId, String key, String store, int price, String emoji, String query) {
  final q = Uri.encodeComponent(query);
  final url = store == 'Amazon'
      ? 'https://www.amazon.in/s?k=$q'
      : 'https://www.firstcry.com/search?q=$q';
  return BagProduct(
    id: '${itemId}_$key',
    name: store,
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
