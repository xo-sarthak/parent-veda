// =============================================================================
//  Products - content model, catalog data + Compare selection store
// -----------------------------------------------------------------------------
//  Single source of truth for the parenting app's Products flow (discovery →
//  category → subcategory → detail → compare). The Sleep category is a faithful
//  build of Claude Design "post pregnancy app.dc.html" · S3 (v2). The other
//  categories carry a light placeholder catalog so every path stays populated
//  and the filters / Compare flow work everywhere. Static for now; a future
//  pass can back it with a CMS/DB. Isolated to the post_pregnancy module.
// =============================================================================

import 'package:flutter/material.dart';

// ---- model ------------------------------------------------------------------
class PpSub {
  const PpSub(this.name, this.short);
  final String name; // 'Soothers & white noise'
  final String short; // 'Soothers'
}

class PpCategory {
  const PpCategory(this.name, this.icon, this.subs);
  final String name;
  final IconData icon;
  final List<PpSub> subs;
}

/// A subcategory's "20-second" buying guidance - the one-liner that leads the
/// page, plus the LOOK FOR (green checks) and AVOID (red x) lists. This is the
/// education layer that matches the pregnancy app's ParentVeda Guidance card,
/// authored per subcategory so the advice is specific, not generic.
class PpGuide {
  const PpGuide({required this.line, required this.lookFor, required this.avoid});
  final String line; // the guidance one-liner
  final List<String> lookFor; // what to look for (checks)
  final List<String> avoid; // what to avoid (x)
}

class PpProduct {
  const PpProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.sub,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.retailer,
    this.verified = false,
    this.parentVeda = false,
    this.bestseller = false,
    this.sound,
    this.autoOff,
    this.volumeLock,
    this.power,
    this.summary = '',
    this.badge = '',
    this.bestFor = '',
    this.specs = const {},
    this.pros = const [],
    this.cons = const [],
  });

  final String id;
  final String name;
  final String brand;
  final String category; // 'Sleep'
  final String sub; // full sub name, e.g. 'Soothers & white noise'
  final double rating;
  final int reviews;
  final int price;
  final String retailer; // 'Amazon' / 'FirstCry'
  final bool verified;
  final bool parentVeda;
  final bool bestseller;

  // Optional compare specs (populated for soothers, per design).
  final String? sound;
  final bool? autoOff;
  final bool? volumeLock;
  final String? power;

  // Per-product compare content - every section is differentiated (no generic
  // shared text): a one-line summary, a category spec sheet, and this product's
  // own "what's right" / "worth knowing".
  final String summary;

  // A short editorial badge for the snapshot card (e.g. 'Best overall',
  // 'Best value', 'Premium', 'Gentle', 'Budget'). Empty = no badge.
  final String badge;

  // A one-line "who this suits" note (e.g. 'Noisy joint-family homes').
  final String bestFor;

  final Map<String, String> specs;
  final List<String> pros;
  final List<String> cons;

  String get priceLabel => '₹${_grouped(price)}';
  String get ratingLabel => '★ ${rating.toStringAsFixed(1)}';

  static String _grouped(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final head = s.substring(0, s.length - 3);
    return '$head,${s.substring(s.length - 3)}';
  }
}

// ---- categories -------------------------------------------------------------
const List<PpCategory> kPpCategories = [
  PpCategory('Sleep', Icons.bedtime_outlined, [
    PpSub('Soothers & white noise', 'Soothers'),
    PpSub('Sleepwear & sacks', 'Sleepwear'),
    PpSub('Bedding & blackout', 'Bedding'),
  ]),
  PpCategory('Skincare', Icons.spa_outlined, [
    PpSub('Lotions', 'Lotions'),
    PpSub('Rash creams', 'Rash creams'),
    PpSub('Bath', 'Bath'),
  ]),
  PpCategory('Feeding', Icons.local_drink_outlined, [
    PpSub('Bottles', 'Bottles'),
    PpSub('Weaning', 'Weaning'),
    PpSub('Sterilisers', 'Sterilisers'),
  ]),
  PpCategory('Play & Development', Icons.toys_outlined, [
    PpSub('Toys', 'Toys'),
    PpSub('Books', 'Books'),
    PpSub('Sensory', 'Sensory'),
  ]),
  PpCategory('Health & Safety', Icons.health_and_safety_outlined, [
    PpSub('Thermometers', 'Thermometers'),
    PpSub('Baby-proofing', 'Baby-proofing'),
    PpSub('First aid', 'First aid'),
  ]),
  PpCategory('On the move', Icons.directions_car_outlined, [
    PpSub('Strollers', 'Strollers'),
    PpSub('Carriers', 'Carriers'),
    PpSub('Car seats', 'Car seats'),
  ]),
];

// ---- catalog ----------------------------------------------------------------
const List<PpProduct> kPpProducts = [
  // -- Sleep · Soothers & white noise (faithful to design) --
  PpProduct(
      id: 'dozy',
      name: 'Dozy White-Noise Soother',
      brand: 'Dozy',
      category: 'Sleep',
      sub: 'Soothers & white noise',
      rating: 4.8,
      reviews: 214,
      price: 1499,
      retailer: 'Amazon',
      verified: true,
      bestseller: true,
      badge: 'Best overall',
      bestFor: 'Noisy joint-family homes',
      sound: 'True continuous white noise',
      autoOff: true,
      volumeLock: false,
      power: 'USB + power bank',
      summary: 'Our top soother - true continuous white noise that never loops.',
      specs: {
        'Sound': 'True continuous white noise',
        'Auto-off timer': 'Yes',
        'Volume lock': 'No',
        'Power': 'USB + power bank',
        'Warranty': '1 year',
      },
      pros: [
        'True non-looping white noise that stays steady all night',
        'Runs off a power bank - great for travel and power cuts',
        'ParentVeda-verified purchase reviews',
      ],
      cons: [
        'The priciest of the four',
        'No volume lock, so an older baby could nudge the level',
      ]),
  PpProduct(
      id: 'lull',
      name: 'Lull Portable Soother',
      brand: 'Lull',
      category: 'Sleep',
      sub: 'Soothers & white noise',
      rating: 4.5,
      reviews: 88,
      price: 999,
      retailer: 'FirstCry',
      verified: true,
      badge: 'Best value',
      bestFor: 'The diaper bag & travel',
      sound: 'Looping tracks (short loop)',
      autoOff: true,
      volumeLock: true,
      power: 'Rechargeable battery',
      summary: 'Compact and pocketable, with a handy volume lock.',
      specs: {
        'Sound': 'Looping tracks (short loop)',
        'Auto-off timer': 'Yes',
        'Volume lock': 'Yes',
        'Power': 'Rechargeable battery',
        'Warranty': '6 months',
      },
      pros: [
        'Volume lock stops little hands changing it',
        'Genuinely pocket-sized for the diaper bag',
        'Good value at under ₹1,000',
      ],
      cons: [
        'Tracks loop on a short cycle - some babies notice the repeat',
        'Battery-only; nothing to plug in overnight',
      ]),
  PpProduct(
      id: 'hush',
      name: 'Hush Mini Sound Machine',
      brand: 'Hushh',
      category: 'Sleep',
      sub: 'Soothers & white noise',
      rating: 4.4,
      reviews: 61,
      price: 749,
      retailer: 'Amazon',
      verified: true,
      badge: 'Budget',
      bestFor: 'A simple first soother',
      sound: 'Continuous white noise',
      autoOff: false,
      volumeLock: true,
      power: 'USB',
      summary: 'The budget pick - continuous noise, volume-locked.',
      specs: {
        'Sound': 'Continuous white noise',
        'Auto-off timer': 'No',
        'Volume lock': 'Yes',
        'Power': 'USB',
        'Warranty': '6 months',
      },
      pros: [
        'Continuous (non-looping) sound at the lowest price',
        'Volume lock included',
        'Simple, one-button operation',
      ],
      cons: [
        'No auto-off timer - it runs until you switch it off',
        'USB-only, so it needs a plug nearby',
      ]),
  PpProduct(
      id: 'cloudtunes',
      name: 'CloudTunes Soother',
      brand: 'CloudTunes',
      category: 'Sleep',
      sub: 'Soothers & white noise',
      rating: 4.1,
      reviews: 34,
      price: 599,
      retailer: 'FirstCry',
      badge: 'Gentle',
      bestFor: 'Babies who like a melody',
      sound: 'Melodies + white noise',
      autoOff: true,
      volumeLock: false,
      power: 'Battery',
      summary: 'Melodies plus white noise, cheapest of the four.',
      specs: {
        'Sound': 'Melodies + white noise',
        'Auto-off timer': 'Yes',
        'Volume lock': 'No',
        'Power': 'Battery (replaceable)',
        'Warranty': '-',
      },
      pros: [
        'Melodies and white noise in one device',
        'Cheapest option here',
        'Auto-off timer to save battery',
      ],
      cons: [
        'Lowest rating and review count of the four so far',
        'No volume lock; batteries are not rechargeable',
      ]),

  // -- Sleep · Sleepwear & sacks --
  PpProduct(
      id: 'cosysuit',
      name: 'Cosy Cotton Sleepsuit',
      brand: 'Dozy',
      category: 'Sleep',
      sub: 'Sleepwear & sacks',
      rating: 4.5,
      reviews: 72,
      price: 699,
      retailer: 'FirstCry',
      verified: true,
      badge: 'Best value',
      bestFor: 'Everyday cot nights',
      summary: 'A soft, breathable cotton sleepsuit for everyday cot nights.',
      pros: ['Breathable pure cotton', 'Roomy, hip-healthy cut', 'Easy nappy-change poppers'],
      cons: ['One weight only - layer for winter']),
  PpProduct(
      id: 'merinosack',
      name: 'Merino Sleep Sack',
      brand: 'SnuggleSack',
      category: 'Sleep',
      sub: 'Sleepwear & sacks',
      rating: 4.8,
      reviews: 51,
      price: 1499,
      retailer: 'Amazon',
      badge: 'Premium',
      bestFor: 'Cooler rooms & winter',
      summary: 'A temperature-regulating merino sack for cooler rooms.',
      pros: ['Merino regulates temperature', 'No loose blankets needed', 'Soft, non-itch weave'],
      cons: ['A premium price point', 'Hand-wash care']),

  // -- Sleep · Bedding & blackout --
  PpProduct(
      id: 'hushcurtains',
      name: 'Hush Blackout Curtains',
      brand: 'ParentVeda',
      category: 'Sleep',
      sub: 'Bedding & blackout',
      rating: 4.7,
      reviews: 96,
      price: 1299,
      retailer: 'In-app',
      parentVeda: true,
      badge: 'Best overall',
      bestFor: 'Bright rooms & day naps',
      summary: 'True blackout curtains that make day naps and early mornings easier.',
      pros: ['Genuine blackout, not just dimming', 'Made and backed by ParentVeda', 'Machine-washable'],
      cons: ['Needs the right rail width']),
  PpProduct(
      id: 'snugglesack',
      name: 'SnuggleSack Sleep Bag',
      brand: 'SnuggleSack',
      category: 'Sleep',
      sub: 'Bedding & blackout',
      rating: 4.6,
      reviews: 143,
      price: 899,
      retailer: 'FirstCry',
      verified: true,
      badge: 'Best value',
      bestFor: 'Blanket-free cot sleep',
      summary: 'A breathable sleep bag that keeps covers off through the night.',
      pros: ['Keeps a baby covered without blankets', 'Breathable, well-rated fabric', 'Zip-guard at the neck'],
      cons: ['Check the weight rating for your room']),

  // -- Skincare (light catalog) --
  PpProduct(
      id: 'lotion',
      name: 'Soothe Baby Lotion',
      brand: 'ParentVeda',
      category: 'Skincare',
      sub: 'Lotions',
      rating: 4.7,
      reviews: 128,
      price: 399,
      retailer: 'In-app',
      parentVeda: true,
      verified: true,
      badge: 'Best overall',
      bestFor: 'Everyday daily care',
      summary: 'A light, fragrance-free daily moisturiser for normal-to-dry skin.',
      specs: {
        'Suitable age': '0+ months',
        'Key ingredients': 'Glycerin, panthenol',
        'Free from': 'Fragrance, parabens',
        'Skin type': 'Normal to dry',
        'Size': '200 ml',
      },
      pros: [
        'Fragrance- and paraben-free',
        'Absorbs fast without a greasy film',
        'ParentVeda-made with verified reviews',
      ],
      cons: [
        'May feel light for very dry or eczema-prone skin',
      ]),
  PpProduct(
      id: 'rashcream',
      name: 'Calm Zinc Rash Cream',
      brand: 'Sebamed',
      category: 'Skincare',
      sub: 'Rash creams',
      rating: 4.6,
      reviews: 84,
      price: 299,
      retailer: 'Amazon',
      verified: true,
      badge: 'Best value',
      bestFor: 'Nappy rash flare-ups',
      summary: 'A zinc barrier cream for nappy rash and red patches.',
      specs: {
        'Suitable age': '0+ months',
        'Key ingredients': 'Zinc oxide, panthenol',
        'Free from': 'Fragrance, alkali',
        'Skin type': 'Sensitive, rash-prone',
        'Size': '100 g',
      },
      pros: [
        'Thick zinc barrier that calms nappy rash fast',
        'pH-balanced for sensitive skin',
        'A little goes a long way',
      ],
      cons: [
        'Thick texture takes a moment to spread',
        'Not a daily all-over moisturiser',
      ]),
  PpProduct(
      id: 'babywash',
      name: 'Gentle Top-to-Toe Wash',
      brand: 'Mustela',
      category: 'Skincare',
      sub: 'Bath',
      rating: 4.5,
      reviews: 61,
      price: 349,
      retailer: 'FirstCry',
      badge: 'Gentle',
      bestFor: 'Tear-free hair & body',
      summary: 'A tear-free wash for hair and body in one bottle.',
      specs: {
        'Suitable age': '0+ months',
        'Key ingredients': 'Mild surfactants, avocado',
        'Free from': 'Soap, parabens',
        'Skin type': 'Normal',
        'Size': '400 ml',
      },
      pros: [
        'Tear-free - hair and body in one bottle',
        'Big 400 ml pump lasts months',
        'Soap-free formula',
      ],
      cons: [
        'Lightly fragranced - not fully fragrance-free',
        'Pricier per wash than a plain cleanser',
      ]),

  // -- Feeding --
  PpProduct(
      id: 'bottle',
      name: 'Anti-Colic Feeding Bottle',
      brand: 'Philips',
      category: 'Feeding',
      sub: 'Bottles',
      rating: 4.6,
      reviews: 210,
      price: 599,
      retailer: 'Amazon',
      verified: true,
      badge: 'Best overall',
      bestFor: 'Gassy, colicky feeders',
      summary: 'An anti-colic bottle that vents air away from the milk to ease gas and fussing.',
      pros: [
        'Anti-colic vent reduces trapped air and gas',
        'BPA-free and easy to hold',
        'A widely trusted, well-reviewed design',
      ],
      cons: [
        'More parts to clean than a plain bottle',
        'One flow rate in the box',
      ]),
  PpProduct(
      id: 'spoons',
      name: 'First Spoons Weaning Set',
      brand: 'ParentVeda',
      category: 'Feeding',
      sub: 'Weaning',
      rating: 4.7,
      reviews: 47,
      price: 399,
      retailer: 'In-app',
      parentVeda: true,
      badge: 'Best value',
      bestFor: 'First tastes at weaning',
      summary: 'Soft-tipped first spoons sized for new gums and small hands at weaning.',
      pros: [
        'Soft, shallow tips are gentle on new gums',
        'BPA-free and dishwasher-safe',
        'Made and backed by ParentVeda',
      ],
      cons: [
        'Best for early weaning, not older toddlers',
      ]),
  PpProduct(
      id: 'steriliser',
      name: 'Steam Steriliser',
      brand: 'Philips',
      category: 'Feeding',
      sub: 'Sterilisers',
      rating: 4.5,
      reviews: 96,
      price: 2499,
      retailer: 'FirstCry',
      badge: 'Premium',
      bestFor: 'Busy bottle-feeding days',
      summary: 'A fast steam steriliser that clears germs from a full set of bottles at once.',
      pros: [
        'Steam-cleans a full load in minutes',
        'Holds several bottles and accessories',
        'No chemicals, just steam',
      ],
      cons: [
        'Takes up counter space',
        'Needs regular descaling',
      ]),

  // -- Play & Development --
  PpProduct(
      id: 'playgym',
      name: 'High-Contrast Play Gym',
      brand: 'Skip Hop',
      category: 'Play & Development',
      sub: 'Toys',
      rating: 4.8,
      reviews: 176,
      price: 1999,
      retailer: 'Amazon',
      verified: true,
      bestseller: true,
      badge: 'Best overall',
      bestFor: 'Tummy time & batting',
      summary: 'A high-contrast play gym for tummy time, batting and early reaching.',
      pros: [
        'High-contrast toys suit young eyes',
        'Encourages tummy time and reaching',
        'Folds away and wipes clean',
      ],
      cons: [
        'Baby grows past it within months',
        'Bulky to store flat',
      ]),
  PpProduct(
      id: 'clothbook',
      name: 'Peekaboo Cloth Book',
      brand: 'ParentVeda',
      category: 'Play & Development',
      sub: 'Books',
      rating: 4.7,
      reviews: 63,
      price: 399,
      retailer: 'In-app',
      parentVeda: true,
      badge: 'Gentle',
      bestFor: 'First shared reading',
      summary: 'A soft cloth book that survives little hands and mouths during first shared reading.',
      pros: [
        'Soft cloth pages are mouth- and tear-safe',
        'Simple, high-contrast peekaboo pages',
        'Machine-washable',
      ],
      cons: [
        'A short book - more for touch than story',
      ]),
  PpProduct(
      id: 'crinkle',
      name: 'Crinkle Sensory Set',
      brand: 'Fisher-Price',
      category: 'Play & Development',
      sub: 'Sensory',
      rating: 4.4,
      reviews: 52,
      price: 499,
      retailer: 'FirstCry',
      badge: 'Best value',
      bestFor: 'Grasp & sensory play',
      summary: 'A set of crinkle and texture toys for grasping and early sensory play.',
      pros: [
        'Varied textures and crinkle sounds',
        'Easy to grasp and mouth safely',
        'Light to pack for outings',
      ],
      cons: [
        'Fabric picks up dribble - wash it often',
      ]),

  // -- Health & Safety --
  PpProduct(
      id: 'thermometer',
      name: 'Forehead Thermometer',
      brand: 'Dr Trust',
      category: 'Health & Safety',
      sub: 'Thermometers',
      rating: 4.5,
      reviews: 140,
      price: 899,
      retailer: 'Amazon',
      verified: true,
      badge: 'Best overall',
      bestFor: 'Quick fever checks',
      summary: 'A quick no-contact forehead thermometer for calm fever checks, even while asleep.',
      pros: [
        'Fast, no-contact reading',
        "Won't wake a sleeping baby",
        'Simple one-button use',
      ],
      cons: [
        'Forehead readings can vary a little',
        'Needs the odd battery change',
      ]),
  PpProduct(
      id: 'cornerguard',
      name: 'Corner Guard Pack',
      brand: 'Safe-O-Kid',
      category: 'Health & Safety',
      sub: 'Baby-proofing',
      rating: 4.3,
      reviews: 88,
      price: 299,
      retailer: 'Amazon',
      badge: 'Best value',
      bestFor: 'Sharp table corners',
      summary: 'Soft corner guards that cushion sharp table and furniture edges once baby is mobile.',
      pros: [
        'Cushions hard, sharp corners',
        'Strong adhesive backing',
        'A good-value multi-pack',
      ],
      cons: [
        'Adhesive can mark some finishes',
        'A determined toddler may pull one off',
      ]),
  PpProduct(
      id: 'firstaid',
      name: 'Baby First-Aid Kit',
      brand: 'ParentVeda',
      category: 'Health & Safety',
      sub: 'First aid',
      rating: 4.7,
      reviews: 39,
      price: 799,
      retailer: 'In-app',
      parentVeda: true,
      badge: 'Premium',
      bestFor: 'Everyday baby scrapes',
      summary: 'A compact baby first-aid kit covering the everyday - fever, small cuts and a blocked nose.',
      pros: [
        'Covers the everyday basics in one case',
        'Baby-safe contents',
        'Compact enough to keep close',
      ],
      cons: [
        "You'll restock the plasters and saline",
      ]),

  // -- On the move --
  PpProduct(
      id: 'stroller',
      name: 'Featherlite Stroller',
      brand: 'LuvLap',
      category: 'On the move',
      sub: 'Strollers',
      rating: 4.5,
      reviews: 203,
      price: 8999,
      retailer: 'Amazon',
      verified: true,
      badge: 'Best overall',
      bestFor: 'Everyday city outings',
      summary: 'A lightweight, easy-fold stroller for everyday city outings and travel.',
      pros: [
        'Light and quick to fold one-handed',
        'Compact for car boots and buses',
        'Reclines for younger babies',
      ],
      cons: [
        'Smaller wheels prefer smooth paths',
        'Less padding than a heavy pram',
      ]),
  PpProduct(
      id: 'carrier',
      name: 'Ergo Baby Carrier',
      brand: 'Ergobaby',
      category: 'On the move',
      sub: 'Carriers',
      rating: 4.8,
      reviews: 154,
      price: 3999,
      retailer: 'FirstCry',
      bestseller: true,
      badge: 'Premium',
      bestFor: 'Hands-free from newborn',
      summary: "An ergonomic carrier that supports baby's hips and spreads the load across your back.",
      pros: [
        'Hip-healthy ergonomic seat',
        'Spreads weight comfortably across the back',
        'Adjustable to fit both parents',
      ],
      cons: [
        'A premium price point',
        'A learning curve to fit it snugly',
      ]),
  PpProduct(
      id: 'carseat',
      name: 'Infant Car Seat',
      brand: 'Chicco',
      category: 'On the move',
      sub: 'Car seats',
      rating: 4.6,
      reviews: 71,
      price: 6999,
      retailer: 'Amazon',
      verified: true,
      badge: 'Best overall',
      bestFor: 'Car travel from birth',
      summary: 'A rearward-facing infant car seat certified for safe travel from birth.',
      pros: [
        'Certified to current safety standards',
        'Rearward-facing for newborn safety',
        'Clicks into a compatible base',
      ],
      cons: [
        'A premium, non-negotiable safety buy',
        'Babies outgrow infant seats within a year',
      ]),
];

// ---- queries ----------------------------------------------------------------
PpCategory categoryByName(String name) =>
    kPpCategories.firstWhere((c) => c.name == name, orElse: () => kPpCategories.first);

PpProduct productById(String id) => kPpProducts.firstWhere((p) => p.id == id, orElse: () => kPpProducts.first);

// ---- discovery filters (per the Products brief) ------------------------------
// Problem / concern-based entry points → the categories that address them.
const List<(String, IconData, Set<String>)> kPpConcerns = [
  ('Rashes', Icons.healing_outlined, {'Skincare'}),
  ('Poor sleep', Icons.bedtime_outlined, {'Sleep'}),
  ('Colic & gas', Icons.child_care_outlined, {'Feeding', 'Sleep'}),
  ('Teething', Icons.emoji_emotions_outlined, {'Play & Development', 'Health & Safety'}),
  ('Dry skin', Icons.spa_outlined, {'Skincare'}),
  ('Fever', Icons.thermostat_outlined, {'Health & Safety'}),
  ('Feeding', Icons.local_drink_outlined, {'Feeding'}),
  ('Travel', Icons.directions_car_outlined, {'On the move'}),
];

// Life-stage entry points → the categories most relevant at that age.
const List<(String, Set<String>)> kPpStages = [
  ('Newborn · 0–3m', {'Sleep', 'Skincare', 'Feeding', 'Health & Safety'}),
  ('3–6 months', {'Sleep', 'Play & Development', 'Feeding'}),
  ('6–12 months', {'Feeding', 'Play & Development', 'On the move'}),
  ('1–2 years', {'Play & Development', 'On the move', 'Health & Safety'}),
  ('2 years +', {'Play & Development'}),
];

/// Distinct brands across the catalog, sorted - for the brand filter.
List<String> ppBrands() => kPpProducts.map((p) => p.brand).toSet().toList()..sort();

List<PpProduct> productsInSub(String category, String subName) =>
    kPpProducts.where((p) => p.category == category && p.sub == subName).toList();

// ---- per-subcategory buying guidance (the education layer) -------------------
//  The "20-second" guidance that leads each subcategory page - a one-liner plus
//  LOOK FOR (green checks) and AVOID (red x). Matches the pregnancy app's
//  ParentVeda Guidance card, authored per subcategory so the advice is specific.
//  Keyed by the full subcategory name (unique across the catalog).
const Map<String, PpGuide> kPpGuides = {
  'Soothers & white noise': PpGuide(
    line: 'Steady white noise - not looping lullabies - masks the household sounds that pull a baby out of light sleep.',
    lookFor: ['True continuous (non-looping) sound', 'An auto-off timer so it fades on its own', 'A volume you can keep gentle, about a soft shower'],
    avoid: ['Short loops a baby learns to notice and wake to', 'Anything you cannot turn down low enough', 'Bright lights or screens on the device'],
  ),
  'Sleepwear & sacks': PpGuide(
    line: 'A safe sleep sack replaces loose blankets - it keeps a baby covered all night with nothing near the face.',
    lookFor: ['A TOG rating matched to the room temperature', 'Breathable natural fabrics against the skin', 'A neck and armholes snug enough to stay put'],
    avoid: ['Loose blankets or quilts in the cot', 'Hoods, ties or anything near the face', 'A sack so large the baby can slip inside it'],
  ),
  'Bedding & blackout': PpGuide(
    line: 'A dark, calm room does more for naps and early mornings than any gadget - genuine blackout is the biggest single win.',
    lookFor: ['True blackout, not just dimming', 'A firm, flat mattress with a fitted sheet', 'Easy-wash fabrics for the inevitable spills'],
    avoid: ['Pillows, bumpers and soft toys in the cot', 'Gaps at the curtain edges that leak light', 'Heavy materials you cannot wash'],
  ),
  'Lotions': PpGuide(
    line: 'For a baby, gentler and simpler almost always wins - a short, fragrance-free formula suits new skin best.',
    lookFor: ['Fragrance-free for young or sensitive skin', 'A short, recognisable ingredient list', 'Matched to the skin type (normal / dry)'],
    avoid: ['Added fragrance or essential oils', 'Long lists of unfamiliar actives', '"Natural" claims with no ingredients to back them'],
  ),
  'Rash creams': PpGuide(
    line: 'A thick zinc barrier is what calms nappy rash - apply at the first hint of redness, not once it is already raw.',
    lookFor: ['A zinc-oxide barrier of about 10% or more', 'pH-balanced for sensitive skin', 'Fragrance- and alkali-free'],
    avoid: ['Fragranced or medicated creams for daily use', "Steroid creams without a doctor's say-so", 'Thin lotions that offer no real barrier'],
  ),
  'Bath': PpGuide(
    line: 'A tear-free, soap-free wash cleans hair and body gently without stripping new skin - you need very little of it.',
    lookFor: ['Tear-free and soap-free', 'A mild, pH-balanced formula', 'Fragrance-free if skin is reactive'],
    avoid: ['Adult soaps and strong cleansers', 'Heavy fragrance and bright colouring', 'Over-bathing, which dries the skin'],
  ),
  'Bottles': PpGuide(
    line: "The right bottle suits your baby's tummy - an anti-colic vent matters far more than the extras in the box.",
    lookFor: ['An anti-colic vent system if baby is gassy', 'BPA-free glass or PPSU you trust', "A flow rate that matches baby's age"],
    avoid: ['A fast flow too early for a young feeder', 'Bottles that are hard to clean fully', "Paying for accessories you won't use"],
  ),
  'Weaning': PpGuide(
    line: 'Weaning gear should be soft, safe and easy to clean - a shallow, soft-tipped spoon is gentler on new gums than a hard one.',
    lookFor: ['Soft, shallow first-spoon tips', 'BPA-free, dishwasher-safe materials', 'Sizes suited to small hands and mouths'],
    avoid: ['Hard metal spoons for first tastes', 'Anything small enough to be a choke risk', 'Batteries or loose parts in feeding gear'],
  ),
  'Sterilisers': PpGuide(
    line: 'Sterilising matters most in the early months - pick the method that fits your kitchen and bottle count, not the biggest machine.',
    lookFor: ['A capacity that fits your daily bottles', 'A cycle that suits your routine (steam / UV)', 'Easy to descale and keep clean'],
    avoid: ["Over-buying capacity you won't use", 'Units too bulky for your counter', 'Skipping the descaling the maker asks for'],
  ),
  'Toys': PpGuide(
    line: "The best toys are open-ended and match your baby's stage now - high contrast and simple cause-and-effect beat flashing lights.",
    lookFor: ["Right for baby's age and stage today", 'Genuinely engaging - contrast, texture, sound', 'Safe, with nothing small enough to swallow'],
    avoid: ['Battery-heavy, flashing "developmental" toys', 'Choosing by age-up features over now', 'Small parts or long cords'],
  ),
  'Books': PpGuide(
    line: 'Cloth and board books survive little hands and mouths - the reading matters more than the pictures, so pick sturdy and simple.',
    lookFor: ['Sturdy cloth or board pages', 'High-contrast or simple, bold images', 'Non-toxic, wipe-clean materials'],
    avoid: ['Thin paper pages that tear or cut', 'Tiny attached parts that can detach', 'Overwhelming, busy illustrations'],
  ),
  'Sensory': PpGuide(
    line: 'Sensory play is about variety, not volume - a few different textures and sounds do more than one busy, over-stimulating toy.',
    lookFor: ['A range of safe textures and sounds', 'Easy to grasp and mouth safely', 'Washable, non-toxic materials'],
    avoid: ['Over-stimulating, loud, flashing sets', 'Anything with small detachable parts', 'Cluttering baby with too much at once'],
  ),
  'Thermometers': PpGuide(
    line: "A thermometer you believe beats a long feature list - accuracy and a calm, quick reading matter most on a fussy baby.",
    lookFor: ['Accuracy and consistent readings', 'Quick and calm to use on a fussy baby', 'Easy to clean between uses'],
    avoid: ["The cheapest unit you'll second-guess", 'Slow readings that wake a sleeping baby', 'Forehead-only if you need core accuracy'],
  ),
  'Baby-proofing': PpGuide(
    line: 'Baby-proof for how your child actually moves - cover the sharp corners and sockets they can reach before they start pulling up.',
    lookFor: ['A strong, residue-free adhesive or fit', "Covers an adult can remove, a baby can't", 'The right size for your edges and sockets'],
    avoid: ['Guards that fall off within days', 'Covers a determined toddler can pry loose', 'Small parts that become a choke risk'],
  ),
  'First aid': PpGuide(
    line: 'A baby first-aid kit should cover the everyday - fever, small cuts, a blocked nose - and live where you can reach it in seconds.',
    lookFor: ['The everyday basics (thermometer, saline, plasters)', 'Baby-safe contents and doses', "A compact case you'll actually keep stocked"],
    avoid: ['Adult medicines or doses in a baby kit', "Kits missing the basics you'll reach for", 'Storing it out of easy reach'],
  ),
  'Strollers': PpGuide(
    line: "The stroller you'll actually use is the one that's light and folds easily - weight and fold beat cup-holders and extras.",
    lookFor: ["A weight and fold you'll happily carry", 'A secure 5-point harness', 'A recline suited to a young baby'],
    avoid: ['Big, feature-heavy models too bulky to use', "A seat that won't lie flat for a newborn", 'Choosing on extras over everyday ease'],
  ),
  'Carriers': PpGuide(
    line: "A good carrier supports your baby's hips in the 'M' position and spreads the load across your back - comfort for both is the point.",
    lookFor: ['Ergonomic, hip-healthy seated support', 'Weight spread evenly across your back', 'Head support for a young baby'],
    avoid: ['Narrow-based carriers that dangle the legs', "Anything that hunches baby's chin to chest", "A fit you can't adjust for both parents"],
  ),
  'Car seats': PpGuide(
    line: 'A car seat is the one thing never to buy used or budget - correct fit and a rearward-facing install keep it doing its job.',
    lookFor: ['Certified to the current safety standard', "A correct fit for your car and baby's size", 'Rearward-facing for as long as possible'],
    avoid: ['Second-hand seats with an unknown history', 'Loose or incorrect installation', 'Moving to forward-facing too early'],
  ),
};

/// The guidance for a subcategory, or a sensible generic fallback so every
/// subcategory page leads with a guidance card even before bespoke copy exists.
PpGuide ppGuideFor(String category, String sub) =>
    kPpGuides[sub] ??
    PpGuide(
      line: 'A short, ParentVeda-reviewed shortlist for ${sub.toLowerCase()} - chosen for everyday usefulness, safety and value.',
      lookFor: const ['Right for your baby\'s age and stage', 'Safe, well-made and easy to live with', 'Honest value, not just the lowest price'],
      avoid: const ['Buying on features you won\'t use', 'Anything with a real safety question mark', 'Paying a premium for the brand name alone'],
    );

// ---- buy routing (affiliate vs in-app) --------------------------------------
//  Amazon / FirstCry products are bought on the retailer's site (affiliate);
//  ParentVeda's own products (retailer 'In-app') are bought inside the app.
bool ppIsAffiliate(PpProduct p) => p.retailer != 'In-app';

/// The external search URL for an affiliate product on its retailer.
String ppBuyUrl(PpProduct p) {
  final q = Uri.encodeComponent(p.name);
  switch (p.retailer) {
    case 'FirstCry':
      return 'https://www.firstcry.com/search?q=$q';
    case 'Amazon':
    default:
      return 'https://www.amazon.in/s?k=$q';
  }
}

/// The buy-button label: an affiliate retailer, or an in-app buy.
String ppBuyLabel(PpProduct p) => ppIsAffiliate(p) ? 'Buy on ${p.retailer}' : 'Buy now';

// ---- snapshot-card helpers (with graceful fallbacks) ------------------------
String ppSummaryOf(PpProduct p) => p.summary.isNotEmpty ? p.summary : '${p.brand} - ${p.sub}';

String ppBestForOf(PpProduct p) {
  if (p.bestFor.isNotEmpty) return p.bestFor;
  if (p.parentVeda) return 'Parents who want a ParentVeda-made pick';
  if (p.bestseller) return 'A popular, well-reviewed choice';
  return 'Everyday ${p.sub.toLowerCase()}';
}

/// "Why ParentVeda recommends" rows - the product's own pros, else derived.
List<String> ppProsOf(PpProduct p) {
  if (p.pros.isNotEmpty) return p.pros;
  final l = <String>[];
  if (p.rating >= 4.6) l.add('Highly rated - ${p.ratingLabel} from ${p.reviews} reviews');
  if (p.parentVeda) l.add('Made by ParentVeda');
  if (p.verified) l.add('Verified purchase reviews');
  if (p.bestseller) l.add('A category bestseller');
  if (l.isEmpty) l.add('${p.ratingLabel} from ${p.reviews} reviews');
  return l;
}

/// "Things to consider" rows - the product's own cons, else derived.
List<String> ppConsOf(PpProduct p) {
  if (p.cons.isNotEmpty) return p.cons;
  final l = <String>[];
  if (p.price >= 2000) l.add('A premium price point');
  if (p.reviews < 60) l.add('Newer - fewer reviews so far');
  if (!p.verified && !p.parentVeda) l.add('Not yet ParentVeda-verified');
  if (l.isEmpty) l.add('Nothing major flagged by parents yet');
  return l;
}

/// The accent colour for a snapshot badge (Best overall / value / Premium / …).
/// Raw literals mirror the pp_common tokens (ppPurple / ppBrown / ppCoral /
/// ppSoft) so this data file stays free of a pp_common import cycle.
Color ppBadgeColor(String badge) {
  switch (badge) {
    case 'Best value':
      return const Color(0xFF1F8A5B); // green
    case 'Premium':
      return const Color(0xFF7A4600); // ppBrown
    case 'Gentle':
      return const Color(0xFFFF5A79); // ppCoral
    case 'Budget':
      return const Color(0xFF69636C); // ppSoft
    case 'Best overall':
    default:
      return const Color(0xFF6A30B6); // ppPurple
  }
}

/// A clean line icon for a snapshot badge (no decorative emoji).
IconData ppBadgeIcon(String badge) {
  switch (badge) {
    case 'Best value':
      return Icons.savings_outlined;
    case 'Premium':
      return Icons.auto_awesome_outlined;
    case 'Gentle':
      return Icons.spa_outlined;
    case 'Budget':
      return Icons.sell_outlined;
    case 'Best overall':
    default:
      return Icons.workspace_premium_outlined;
  }
}

/// The pregnancy-app emoji for a snapshot badge (mirrors products_screen's
/// _badgeVisual map - 🏆/💰/✨/🌿 - so both apps' product badges read the same).
String ppBadgeEmoji(String badge) {
  switch (badge) {
    case 'Best value':
    case 'Budget':
      return '💰';
    case 'Premium':
      return '✨';
    case 'Gentle':
      return '🌿';
    case 'Best overall':
    default:
      return '🏆';
  }
}

// ---- "Before you compare" - per-category buying guidance (the differentiator) --
//  Education before comparison: what actually matters for THIS category, what
//  usually doesn't, and a common mistake - so parents choose confidently.
class CompareGuide {
  const CompareGuide({required this.whatMatters, required this.oftenSkip, required this.mistake, this.contextTip});
  final List<String> whatMatters; // the 2-3 things that actually matter
  final String oftenSkip; // what usually doesn't matter
  final String mistake; // a common mistake / overlooked thing
  final String? contextTip; // an age/stage-aware nudge
}

const Map<String, CompareGuide> kCompareGuides = {
  'Sleep': CompareGuide(
    whatMatters: [
      'Continuous (non-looping) sound - babies notice a short loop',
      'A volume lock, so little hands can not crank it up',
      'How it is powered - a plug you can rely on overnight',
    ],
    oftenSkip: 'The number of melodies rarely matters; one steady sound is what soothes.',
    mistake: 'Buying loud. Keep white noise gentle, about the level of a soft shower.',
    contextTip: 'At four months, steady white noise helps most through the sleep shift.',
  ),
  'Skincare': CompareGuide(
    whatMatters: [
      'Fragrance-free for young or sensitive skin',
      'A short, recognisable ingredient list',
      'Matched to the skin type (normal / dry / rash-prone)',
    ],
    oftenSkip: 'Front-of-pack "natural" claims matter less than the actual ingredients.',
    mistake: 'Using a fragranced lotion on sensitive or eczema-prone skin.',
    contextTip: 'For a baby, gentler and simpler almost always wins.',
  ),
  'Feeding': CompareGuide(
    whatMatters: [
      'An anti-colic vent system if your baby is gassy',
      'A material you trust (BPA-free glass or PPSU)',
      'A flow rate that matches your baby\'s age',
    ],
    oftenSkip: 'Extra accessories in the box rarely change the daily experience.',
    mistake: 'Picking a fast flow too early; it can overwhelm a young feeder.',
  ),
  'Play & Development': CompareGuide(
    whatMatters: [
      'Right for your baby\'s age and stage',
      'Genuinely engaging (contrast, texture, sound)',
      'Safe, with nothing small enough to swallow',
    ],
    oftenSkip: 'Battery-heavy, flashing toys are not "more developmental".',
    mistake: 'Choosing by age-up features rather than what suits him now.',
    contextTip: 'At four months, high contrast and simple cause-and-effect win.',
  ),
  'Health & Safety': CompareGuide(
    whatMatters: [
      'Accuracy and consistency you can trust',
      'Quick and calm to use on a fussy baby',
      'Age-appropriate and easy to clean',
    ],
    oftenSkip: 'A long feature list matters less than a reading you believe.',
    mistake: 'Buying the cheapest thermometer, then second-guessing every reading.',
  ),
  'On the move': CompareGuide(
    whatMatters: [
      'Weight and fold - will you actually carry it?',
      'Safety standards and a secure harness',
      'Comfort for your baby on longer trips',
    ],
    oftenSkip: 'Cup holders and extras rarely decide daily happiness.',
    mistake: 'Buying big and feature-heavy, then finding it too bulky to use.',
  ),
};

CompareGuide compareGuideFor(String category) => kCompareGuides[category] ?? kCompareGuides['Sleep']!;

// =============================================================================
//  Compare Manager - the dynamic comparison engine for the Products ecosystem.
// -----------------------------------------------------------------------------
//  One source of truth for "what the parent is comparing right now". Every
//  product surface (grid cards, the detail page, recommendations) adds and
//  removes through here; the floating Compare bar and the Compare screen are
//  pure presentation on top - they hold NO product state of their own. Rules:
//  2-3 products, all of the SAME category (a lotion can't sit next to a
//  stroller). The selection lives for the app session, so nothing is lost when
//  the parent navigates away and comes back. Plain ChangeNotifier singleton.
// =============================================================================

/// The outcome of trying to add/toggle a product - lets each surface show the
/// right friendly message instead of silently dropping a tap.
enum PpCompareResult { added, removed, full, wrongCategory }

class PpCompareStore extends ChangeNotifier {
  PpCompareStore._();
  static final PpCompareStore instance = PpCompareStore._();

  /// A comparison holds exactly two products (minimum 2 to compare).
  static const int maxItems = 2;

  final List<PpProduct> _selected = [];
  List<PpProduct> get selected => List.unmodifiable(_selected);
  int get count => _selected.length;

  /// Enough picked to render a side-by-side comparison.
  bool get ready => _selected.length >= 2;
  bool get isFull => _selected.length >= maxItems;

  /// The category every selected product shares (null when nothing is picked).
  String? get category => _selected.isEmpty ? null : _selected.first.category;

  bool isSelected(PpProduct p) => _selected.any((x) => x.id == p.id);

  /// Whether [p] could be added right now - not full, and the same category as
  /// the running selection. Surfaces call this to pre-check the category rule.
  bool canAdd(PpProduct p) {
    if (isSelected(p)) return true; // toggling one back off is always allowed
    if (isFull) return false;
    return _selected.isEmpty || _selected.first.category == p.category;
  }

  /// Toggle a product in/out of the comparison, honouring the rules. Returns
  /// what happened so the caller can surface the right message.
  PpCompareResult toggle(PpProduct p) {
    final i = _selected.indexWhere((x) => x.id == p.id);
    if (i >= 0) {
      _selected.removeAt(i);
      notifyListeners();
      return PpCompareResult.removed;
    }
    if (isFull) return PpCompareResult.full;
    if (_selected.isNotEmpty && _selected.first.category != p.category) {
      return PpCompareResult.wrongCategory;
    }
    _selected.add(p);
    notifyListeners();
    return PpCompareResult.added;
  }

  /// Remove one product from the comparison.
  void remove(PpProduct p) {
    final i = _selected.indexWhere((x) => x.id == p.id);
    if (i < 0) return;
    _selected.removeAt(i);
    notifyListeners();
  }

  /// Swap [oldP] for [newP] in place (used by "Replace" in the Compare screen).
  /// [newP] must share the category with any remaining picks; else it's a no-op.
  void replace(PpProduct oldP, PpProduct newP) {
    final i = _selected.indexWhere((x) => x.id == oldP.id);
    if (i < 0 || isSelected(newP)) return;
    if (_selected.length > 1) {
      final otherCat = _selected.firstWhere((x) => x.id != oldP.id).category;
      if (otherCat != newP.category) return;
    }
    _selected[i] = newP;
    notifyListeners();
  }

  /// Start a fresh comparison anchored on [p] (clearing any other-category
  /// selection first). Used when "Compare" is tapped from a product whose
  /// category differs from the current list.
  void startWith(PpProduct p) {
    _selected
      ..clear()
      ..add(p);
    notifyListeners();
  }

  /// Other products in the same category that aren't picked yet - the pool for
  /// "Add another" and smart suggestions. Empty until something is selected.
  List<PpProduct> suggestions() {
    if (_selected.isEmpty) return const [];
    final cat = _selected.first.category;
    return kPpProducts.where((p) => p.category == cat && !isSelected(p)).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  void clear() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }
}
