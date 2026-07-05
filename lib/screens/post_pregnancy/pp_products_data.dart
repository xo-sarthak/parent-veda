// =============================================================================
//  Products — content model, catalog data + Compare selection store
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
      sound: 'True continuous white noise',
      autoOff: true,
      volumeLock: false,
      power: 'USB + power bank'),
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
      sound: 'Looping tracks (short loop)',
      autoOff: true,
      volumeLock: true,
      power: 'Rechargeable battery'),
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
      sound: 'Continuous white noise',
      autoOff: false,
      volumeLock: true,
      power: 'USB'),
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
      sound: 'Melodies + white noise',
      autoOff: true,
      volumeLock: false,
      power: 'Battery'),

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
      verified: true),
  PpProduct(
      id: 'merinosack',
      name: 'Merino Sleep Sack',
      brand: 'SnuggleSack',
      category: 'Sleep',
      sub: 'Sleepwear & sacks',
      rating: 4.8,
      reviews: 51,
      price: 1499,
      retailer: 'Amazon'),

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
      parentVeda: true),
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
      verified: true),

  // -- Skincare (light catalog) --
  PpProduct(id: 'lotion', name: 'Soothe Baby Lotion', brand: 'ParentVeda', category: 'Skincare', sub: 'Lotions', rating: 4.7, reviews: 128, price: 399, retailer: 'In-app', parentVeda: true, verified: true),
  PpProduct(id: 'rashcream', name: 'Calm Zinc Rash Cream', brand: 'Sebamed', category: 'Skincare', sub: 'Rash creams', rating: 4.6, reviews: 84, price: 299, retailer: 'Amazon', verified: true),
  PpProduct(id: 'babywash', name: 'Gentle Top-to-Toe Wash', brand: 'Mustela', category: 'Skincare', sub: 'Bath', rating: 4.5, reviews: 61, price: 349, retailer: 'FirstCry'),

  // -- Feeding (light catalog) --
  PpProduct(id: 'bottle', name: 'Anti-Colic Feeding Bottle', brand: 'Philips', category: 'Feeding', sub: 'Bottles', rating: 4.6, reviews: 210, price: 599, retailer: 'Amazon', verified: true),
  PpProduct(id: 'spoons', name: 'First Spoons Weaning Set', brand: 'ParentVeda', category: 'Feeding', sub: 'Weaning', rating: 4.7, reviews: 47, price: 399, retailer: 'In-app', parentVeda: true),
  PpProduct(id: 'steriliser', name: 'Steam Steriliser', brand: 'Philips', category: 'Feeding', sub: 'Sterilisers', rating: 4.5, reviews: 96, price: 2499, retailer: 'FirstCry'),

  // -- Play & Development (light catalog) --
  PpProduct(id: 'playgym', name: 'High-Contrast Play Gym', brand: 'Skip Hop', category: 'Play & Development', sub: 'Toys', rating: 4.8, reviews: 176, price: 1999, retailer: 'Amazon', verified: true, bestseller: true),
  PpProduct(id: 'clothbook', name: 'Peekaboo Cloth Book', brand: 'ParentVeda', category: 'Play & Development', sub: 'Books', rating: 4.7, reviews: 63, price: 399, retailer: 'In-app', parentVeda: true),
  PpProduct(id: 'crinkle', name: 'Crinkle Sensory Set', brand: 'Fisher-Price', category: 'Play & Development', sub: 'Sensory', rating: 4.4, reviews: 52, price: 499, retailer: 'FirstCry'),

  // -- Health & Safety (light catalog) --
  PpProduct(id: 'thermometer', name: 'Forehead Thermometer', brand: 'Dr Trust', category: 'Health & Safety', sub: 'Thermometers', rating: 4.5, reviews: 140, price: 899, retailer: 'Amazon', verified: true),
  PpProduct(id: 'cornerguard', name: 'Corner Guard Pack', brand: 'Safe-O-Kid', category: 'Health & Safety', sub: 'Baby-proofing', rating: 4.3, reviews: 88, price: 299, retailer: 'Amazon'),
  PpProduct(id: 'firstaid', name: 'Baby First-Aid Kit', brand: 'ParentVeda', category: 'Health & Safety', sub: 'First aid', rating: 4.7, reviews: 39, price: 799, retailer: 'In-app', parentVeda: true),

  // -- On the move (light catalog) --
  PpProduct(id: 'stroller', name: 'Featherlite Stroller', brand: 'LuvLap', category: 'On the move', sub: 'Strollers', rating: 4.5, reviews: 203, price: 8999, retailer: 'Amazon', verified: true),
  PpProduct(id: 'carrier', name: 'Ergo Baby Carrier', brand: 'Ergobaby', category: 'On the move', sub: 'Carriers', rating: 4.8, reviews: 154, price: 3999, retailer: 'FirstCry', bestseller: true),
  PpProduct(id: 'carseat', name: 'Infant Car Seat', brand: 'Chicco', category: 'On the move', sub: 'Car seats', rating: 4.6, reviews: 71, price: 6999, retailer: 'Amazon', verified: true),
];

// ---- queries ----------------------------------------------------------------
PpCategory categoryByName(String name) =>
    kPpCategories.firstWhere((c) => c.name == name, orElse: () => kPpCategories.first);

List<PpProduct> productsInSub(String category, String subName) =>
    kPpProducts.where((p) => p.category == category && p.sub == subName).toList();

// =============================================================================
//  Compare selection store — pick up to two, drives the floating Compare button
//  and the Compare screen. Plain ChangeNotifier singleton (no Provider).
// =============================================================================
class PpCompareStore extends ChangeNotifier {
  PpCompareStore._();
  static final PpCompareStore instance = PpCompareStore._();

  final List<PpProduct> _selected = [];
  List<PpProduct> get selected => List.unmodifiable(_selected);
  int get count => _selected.length;
  bool get ready => _selected.length == 2;

  bool isSelected(PpProduct p) => _selected.any((x) => x.id == p.id);

  /// Toggle a product. Caps at two — adding a third drops the oldest.
  void toggle(PpProduct p) {
    final i = _selected.indexWhere((x) => x.id == p.id);
    if (i >= 0) {
      _selected.removeAt(i);
    } else {
      if (_selected.length >= 2) _selected.removeAt(0);
      _selected.add(p);
    }
    notifyListeners();
  }

  void clear() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }
}
