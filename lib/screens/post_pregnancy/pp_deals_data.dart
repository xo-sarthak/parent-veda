// =============================================================================
//  pp_deals_data - self-contained "Deals of the day" for Recommendations
// -----------------------------------------------------------------------------
//  A small, standalone set of illustrative deal entries used by the "Deals of
//  the day" block at the bottom of each Recommendations category view. This is
//  deliberately independent of the real Products catalogue (pp_products_data) -
//  it owns its own lightweight model so nothing here depends on PpProduct.
//  Prices are indicative/mock. Static for now; a real offers feed slots in
//  behind dealsForCategory() later.
// =============================================================================

/// One illustrative deal. [category] loosely maps to a Recommendations category
/// name (or 'General' for offers that suit any section).
class PpDeal {
  const PpDeal({
    required this.id,
    required this.title,
    required this.category,
    required this.retailer,
    required this.oldPrice,
    required this.dealPrice,
    required this.blurb,
    this.indian = false,
    this.tag,
  });

  final String id;
  final String title;
  final String category; // a kRecoCategories name, or 'General'
  final String retailer; // 'Amazon' / 'FirstCry' / 'Flipkart' / 'Hopscotch'
  final int oldPrice; // rupees, before the deal
  final int dealPrice; // rupees, the deal price
  final String blurb; // one calm line
  final bool indian; // a homegrown pick
  final String? tag; // tiny label e.g. 'Bestseller', 'Limited'

  int get discountPercent =>
      oldPrice <= 0 ? 0 : (((oldPrice - dealPrice) / oldPrice) * 100).round();

  String get oldPriceLabel => ppRupees(oldPrice);
  String get dealPriceLabel => ppRupees(dealPrice);
}

/// A tiny rupee formatter (single grouping comma is correct for our <100000
/// price range - e.g. 2999 -> ₹2,999).
String ppRupees(int n) {
  final s = n.abs().toString();
  if (s.length <= 3) return '₹$s';
  return '₹${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
}

// -----------------------------------------------------------------------------
//  The deals - a handful per commerce category, plus a general baby-care pool
//  that fills in for the non-commerce sections (Activities, Videos, Outdoor...).
// -----------------------------------------------------------------------------
const List<PpDeal> kPpDeals = [
  // ---- Books ----
  PpDeal(id: 'dl_bk_contrast', title: 'High-Contrast Newborn Book Set', category: 'Books', retailer: 'Amazon', oldPrice: 599, dealPrice: 349, blurb: 'Bold black-white-red pages for new eyes.', tag: 'Bestseller'),
  PpDeal(id: 'dl_bk_folk', title: 'Indian Folktales Board Book Box', category: 'Books', retailer: 'FirstCry', oldPrice: 899, dealPrice: 599, blurb: 'Panchatantra tales on sturdy board pages.', indian: true),
  PpDeal(id: 'dl_bk_cloth', title: 'Cloth Crinkle Book (2-pack)', category: 'Books', retailer: 'Amazon', oldPrice: 499, dealPrice: 299, blurb: 'Soft, washable and safe to chew.'),

  // ---- Toys ----
  PpDeal(id: 'dl_ty_stack', title: 'Wooden Stacking Rings', category: 'Toys', retailer: 'FirstCry', oldPrice: 799, dealPrice: 499, blurb: 'An open-ended classic that grows with him.', indian: true),
  PpDeal(id: 'dl_ty_teeth', title: 'Silicone Fruit Teether Set', category: 'Toys', retailer: 'Amazon', oldPrice: 449, dealPrice: 249, blurb: 'Soft on sore gums, easy to hold.', tag: 'Limited'),
  PpDeal(id: 'dl_ty_ball', title: 'Soft Sensory Ball Pack', category: 'Toys', retailer: 'Hopscotch', oldPrice: 699, dealPrice: 399, blurb: 'Textured balls made for little hands.'),

  // ---- Products ----
  PpDeal(id: 'dl_pr_sooth', title: 'Dozy White-Noise Soother', category: 'Products', retailer: 'Amazon', oldPrice: 2499, dealPrice: 1799, blurb: 'Steady womb-like sound, auto-off timer.', tag: 'Editor pick'),
  PpDeal(id: 'dl_pr_carrier', title: 'Ergonomic Baby Carrier', category: 'Products', retailer: 'FirstCry', oldPrice: 3499, dealPrice: 2799, blurb: 'A hip-healthy M-position seat.'),
  PpDeal(id: 'dl_pr_swaddle', title: 'Breathable Muslin Swaddles (3)', category: 'Products', retailer: 'Flipkart', oldPrice: 1299, dealPrice: 899, blurb: 'Airy cotton for calmer sleep.', indian: true),

  // ---- Music ----
  PpDeal(id: 'dl_mu_player', title: 'Gentle Lullaby Sound Player', category: 'Music', retailer: 'Amazon', oldPrice: 1499, dealPrice: 999, blurb: "Grandmother's lullabies on a soft-glow player.", indian: true),
  PpDeal(id: 'dl_mu_rhymes', title: 'Nursery Rhymes Song Book + Speaker', category: 'Music', retailer: 'Hopscotch', oldPrice: 1199, dealPrice: 799, blurb: 'Press a page, hear the song.'),

  // ---- Travel ----
  PpDeal(id: 'dl_tv_bag', title: 'Compact Travel Diaper Bag', category: 'Travel', retailer: 'FirstCry', oldPrice: 2199, dealPrice: 1499, blurb: 'Everything in its place, on the go.'),
  PpDeal(id: 'dl_tv_caddy', title: 'Stroller Organiser Caddy', category: 'Travel', retailer: 'Amazon', oldPrice: 899, dealPrice: 549, blurb: 'Bottles, wipes and phone within reach.'),

  // ---- Birthday Ideas ----
  PpDeal(id: 'dl_bd_decor', title: 'Pastel First-Birthday Decor Kit', category: 'Birthday Ideas', retailer: 'Hopscotch', oldPrice: 1299, dealPrice: 799, blurb: 'A gentle, non-plastic celebration set.'),
  PpDeal(id: 'dl_bd_frame', title: 'Wooden Keepsake Handprint Frame', category: 'Birthday Ideas', retailer: 'Amazon', oldPrice: 999, dealPrice: 649, blurb: 'Capture the year, not just the day.', indian: true),

  // ---- Learning ----
  PpDeal(id: 'dl_ln_cards', title: 'First-Words Flashcards (Bilingual)', category: 'Learning', retailer: 'FirstCry', oldPrice: 599, dealPrice: 349, blurb: 'Everyday words in Hindi and English.', indian: true),
  PpDeal(id: 'dl_ln_mat', title: 'Cloth Alphabet Play Mat', category: 'Learning', retailer: 'Amazon', oldPrice: 1499, dealPrice: 999, blurb: 'Soft letters to touch and name.'),

  // ---- General baby-care (fills the non-commerce sections) ----
  PpDeal(id: 'dl_gn_diapers', title: 'Ultra-Soft Diapers (Monthly Pack)', category: 'General', retailer: 'FirstCry', oldPrice: 1499, dealPrice: 1099, blurb: 'Gentle, rash-free days and nights.', tag: 'Bestseller'),
  PpDeal(id: 'dl_gn_wipes', title: 'Water Wipes (12-pack)', category: 'General', retailer: 'Amazon', oldPrice: 1199, dealPrice: 849, blurb: '99% water, kind to newborn skin.'),
  PpDeal(id: 'dl_gn_lotion', title: 'Organic Baby Lotion', category: 'General', retailer: 'Flipkart', oldPrice: 599, dealPrice: 399, blurb: 'Fragrance-free everyday care.', indian: true),
  PpDeal(id: 'dl_gn_muslin', title: 'Muslin Cloth Bundle (5)', category: 'General', retailer: 'Hopscotch', oldPrice: 899, dealPrice: 549, blurb: 'The most-used thing you own.'),
  PpDeal(id: 'dl_gn_bib', title: 'Silicone Bib & Bowl Set', category: 'General', retailer: 'Amazon', oldPrice: 799, dealPrice: 499, blurb: 'A catch-all bib and a suction bowl.'),
  PpDeal(id: 'dl_gn_lamp', title: 'Soft Night Lamp', category: 'General', retailer: 'FirstCry', oldPrice: 999, dealPrice: 649, blurb: 'A warm, dimmable glow for night feeds.'),
];

/// Deals relevant to [category]: exact-category matches first, then general
/// baby-care offers, then anything else - always returning at least a few so the
/// block is never empty. Capped by [limit].
List<PpDeal> dealsForCategory(String category, {int limit = 6}) {
  final out = <PpDeal>[];
  out.addAll(kPpDeals.where((d) => d.category == category));
  for (final d in kPpDeals.where((d) => d.category == 'General')) {
    if (out.length >= limit) break;
    out.add(d);
  }
  if (out.length < 3) {
    for (final d in kPpDeals) {
      if (out.length >= limit) break;
      if (!out.contains(d)) out.add(d);
    }
  }
  return out.take(limit).toList();
}

PpDeal dealById(String id) =>
    kPpDeals.firstWhere((d) => d.id == id, orElse: () => kPpDeals.first);
