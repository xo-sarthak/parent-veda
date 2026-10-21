// =============================================================================
//  pv_affiliate.dart — the retailer's own price and rating, by hand for now
// -----------------------------------------------------------------------------
//  The user (walk 2026-10-20): products should show real prices and real
//  reviews, "plug and play" for when the real affiliate links arrive. The
//  mismatch she saw (our ₹95 against a ₹1,000 listing) came from the buy link
//  being a SEARCH page: we priced one pack, the search showed another.
//
//  So an affiliate product carries an ASIN — the one exact listing — and the
//  price is the one read from that listing, with the date it was read. That
//  date is shown ("price on Amazon as of 21 Oct"): a cached retailer price
//  with no date is a promise we cannot keep, and Amazon's own terms ask for
//  the "as of" time on any price that is not live.
//
//  TWO SOURCES, ONE SHAPE:
//   · NOW — this map, filled by hand the day an exact listing is chosen.
//   · LATER — the `affiliate-refresh` edge function (Amazon Creators API,
//     which replaced PA-API 5 in 2026) writes the same five facts into the
//     `products` table (migration 0108). The app reads the table once the
//     product catalogue moves to the database (STILL-OPEN: products on hold
//     for the admin panel); until then this map is the source.
//
//  ⚠️ NEVER SCRAPED, NEVER INVENTED. An entry goes in only with a listing
//  someone opened. An empty map is the honest state: every affiliate page
//  then says "Our guide price · check today's price on Amazon".
//  Review TEXT is never copied — only the star rating and count, labelled as
//  Amazon's, and a link to read them there.
// =============================================================================

import '../../models/pv_product.dart';

/// One listing's facts, as read from the retailer on [checkedAt].
class PvAffiliateFacts {
  const PvAffiliateFacts({
    required this.asin,
    required this.price,
    required this.checkedAt,
    this.rating = 0,
    this.reviewCount = 0,
  });
  final String asin;

  /// Rupees, as the listing showed it.
  final int price;
  final DateTime checkedAt;
  final double rating;
  final int reviewCount;
}

/// Keyed by unified product id (`ttc_folic`, `dozy`, …). Example entry:
///   'ttc_lh_strips': PvAffiliateFacts(asin: 'B0XXXXXXXX', price: 349,
///       checkedAt: DateTime(2026, 10, 21), rating: 4.1, reviewCount: 2140),
final Map<String, PvAffiliateFacts> kPvAffiliateFacts = {};

/// The exact listing on Amazon India. The partner tag is added on the way
/// out by `openOutbound` (lib/brand/outbound.dart), the one door out, so it
/// is never typed twice.
String pvAmazonListingUrl(String asin) => 'https://www.amazon.in/dp/$asin';

const _kMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// The line under an affiliate price saying whose number it is, or null
/// when the price is ours (sold here), there is none, or it is info only.
String? pvAffiliatePriceNote(PvProduct p) {
  if (p.soldHere || p.reviewOnly || !p.hasPrice) return null;
  if ((p.buyUrl ?? '').isEmpty) return null; // nowhere to check it
  final shop = p.retailer.isEmpty ? 'the retailer' : p.retailer;
  final at = p.priceCheckedAt;
  if (at != null) {
    return 'Price on $shop as of ${at.day} ${_kMonths[at.month - 1]}';
  }
  return "Our guide price · check today's price on $shop";
}
