// The retailer's own price and rating (walk 2026-10-20, pv_affiliate.dart):
// a guide price says so, a checked price carries its date, the exact listing
// replaces the search page, Amazon's stars stay Amazon's, and the pieces are
// wired (product page, migration 0108, the inert Creators API function).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/products/pv_affiliate.dart';
import 'package:parentveda/data/products/pv_catalog_adapters.dart';
import 'package:parentveda/models/pv_product.dart';

PvProduct _byId(String id) => buildPvCatalog().firstWhere((p) => p.id == id);

void main() {
  tearDown(kPvAffiliateFacts.clear);

  test('with no listing checked, an Amazon price is left to Amazon', () {
    // Superseded 2026-10-28 (pv_affiliate.dart, "AMAZON AND FLIPKART PRICES
    // COME ONLY FROM THEIR OWN API"): a hand-typed Amazon price may not be
    // shown, so the catalogue clears it and the page says "See price on
    // Amazon". There is then no price to put a note under.
    // Kept for revert: the "Our guide price" expectation:
    //   expect(pvAffiliatePriceNote(p),
    //       "Our guide price · check today's price on ${p.retailer}");
    final p = _byId('ttc_lh_strips');
    expect(p.soldHere, isFalse);
    expect(pvApiPricedRetailer(p), 'Amazon');
    expect(p.hasPrice, isFalse);
    expect(p.priceNote, 'See price on Amazon');
    expect(pvAffiliatePriceNote(p), isNull);
    expect(p.extRating, 0);
  });

  test('a brand-network product keeps its hand-checked guide price', () {
    // The rule is for Amazon and Flipkart only (their terms); FirstCry and
    // the like have none, so their guide price and its note stay.
    final guide = buildPvCatalog().where((p) =>
        pvApiPricedRetailer(p) == null &&
        !p.soldHere &&
        !p.reviewOnly &&
        p.hasPrice &&
        (p.buyUrl ?? '').isNotEmpty);
    for (final p in guide) {
      expect(pvAffiliatePriceNote(p),
          "Our guide price · check today's price on ${p.retailer}",
          reason: p.id);
    }
  });

  test('a product sold here, or with nowhere to check, has no note', () {
    // Every "sold here" product was an invented seed, retired 2026-10-28
    // (the user: no fake products), so there may be none to check. Kept
    // for revert: the two lookups below without `orElse` / the null checks.
    //   final here = buildPvCatalog().firstWhere((p) => p.soldHere && p.hasPrice);
    final here = buildPvCatalog()
        .where((p) => p.soldHere && p.hasPrice)
        .firstOrNull;
    if (here != null) expect(pvAffiliatePriceNote(here), isNull);
    final nowhere = buildPvCatalog()
        .where((p) =>
            !p.soldHere &&
            !p.reviewOnly &&
            p.hasPrice &&
            (p.buyUrl ?? '').isEmpty)
        .firstOrNull;
    if (nowhere != null) expect(pvAffiliatePriceNote(nowhere), isNull);
  });

  test('a hand-checked listing gives the exact link and ASIN, never a price',
      () {
    // Superseded 2026-10-28 (pv_catalog_adapters.dart `_enrich`): the hand
    // map's ASIN still gives the exact listing, but its price, date and stars
    // are NOT used; only the server's `affiliate-refresh` may stamp those.
    // Kept for revert: price 349, 'Price on Amazon as of 21 Oct', extRating
    // 4.1 and extReviewCount 2140 expectations.
    kPvAffiliateFacts['ttc_lh_strips'] = PvAffiliateFacts(
        asin: 'B0TESTASIN',
        price: 349,
        checkedAt: DateTime(2026, 10, 21),
        rating: 4.1,
        reviewCount: 2140);
    final p = _byId('ttc_lh_strips');
    expect(p.buyUrl, 'https://www.amazon.in/dp/B0TESTASIN');
    expect(p.price, 0, reason: 'a typed Amazon price is cleared');
    expect(p.priceNote, 'See price on Amazon');
    expect(p.priceCheckedAt, isNull);
    expect(p.retailer, 'Amazon');
    expect(p.asin, 'B0TESTASIN');
    expect(p.extRating, 0);
    expect(p.extReviewCount, 0);
    expect(p.rating, 0, reason: "Amazon's stars never become parents' stars");
    expect(pvAffiliatePriceNote(p), isNull);
  });

  test('no affiliate product shows a seed rating', () {
    for (final p in buildPvCatalog()) {
      if (p.soldHere || (p.buyUrl ?? '').isEmpty) continue;
      expect(p.rating, 0, reason: p.id);
    }
  });

  test('wiring: product page, migration, inert Creators API function', () {
    final page =
        File('lib/screens/products/pv_product_screen.dart').readAsStringSync();
    expect(page, contains('pvAffiliatePriceNote(product)'));
    expect(page, contains("'pv_product_ext_rating'"));
    expect(page, contains("'Read reviews on Amazon'"));

    final sql = File('supabase/migrations/0108_products_affiliate.sql')
        .readAsStringSync();
    for (final c in [
      'asin',
      'price_checked_at',
      'ext_rating',
      'ext_review_count'
    ]) {
      expect(sql, contains('add column if not exists $c'));
    }

    final fn = File('supabase/functions/affiliate-refresh/index.ts')
        .readAsStringSync();
    expect(fn, contains('creatorsapi.amazon/catalog/v1'));
    expect(fn, isNot(contains('webservices.amazon')),
        reason: 'PA-API 5 is retired');
    expect(fn, contains('skipped: true'));
  });
}
