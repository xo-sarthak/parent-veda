// =============================================================================
//  Store Track A, slice 1 (2026-10-28): the affiliate launch's honesty rules
// -----------------------------------------------------------------------------
//  Plan: ~/.claude/plans/if-you-actually-look-tingly-horizon.md, "Track A,
//  slice 1".
//
//   1. An Amazon or Flipkart price shows only when the server read it from
//      their API (priceCheckedAt). A hand-typed one breaks the Associates
//      agreement, so the catalogue clears it and says "See price on Amazon".
//   2. Parents' own reviews: the row the phone sends fits migration 0119,
//      the phone can never approve or verify its own review, and the label
//      is "says the parent", never "Verified purchase".
//   3. Wiring gate: the "Did you buy it?" prompt and the store's init are
//      reachable, not just correct.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/products/pv_affiliate.dart';
import 'package:parentveda/data/products/pv_catalog_adapters.dart';
import 'package:parentveda/models/pv_product.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_review_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

PvProduct _p({
  String retailer = 'Amazon',
  String? buyUrl = 'https://www.amazon.in/dp/B0TEST',
  int price = 349,
  DateTime? checkedAt,
  bool soldHere = false,
}) => PvProduct(
  id: 'test_item',
  stage: LifeStage.parenting.shopStage,
  categoryId: 'test',
  name: 'Test item',
  price: price,
  mrp: 499,
  retailer: retailer,
  buyUrl: buyUrl,
  soldHere: soldHere,
  priceCheckedAt: checkedAt,
  extRating: 4.2,
  extReviewCount: 2140,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Amazon / Flipkart prices only from their API', () {
    test('a hand-typed Amazon price is cleared', () {
      final g = pvGuardRetailerPrice(_p());
      expect(g.price, 0);
      expect(g.mrp, isNull);
      expect(g.extRating, 0, reason: 'their stars also come only from the API');
      expect(g.priceLabel, 'See price on Amazon');
      expect(pvAffiliatePriceNote(g), isNull);
    });

    test('a price the API read stays, with its date', () {
      final at = DateTime(2026, 10, 28);
      final g = pvGuardRetailerPrice(_p(checkedAt: at));
      expect(g.price, 349);
      expect(g.extRating, 4.2);
      expect(pvAffiliatePriceNote(g), 'Price on Amazon as of 28 Oct');
    });

    test('Flipkart and the amazon.in spelling are caught too', () {
      expect(
        pvGuardRetailerPrice(
          _p(retailer: 'Flipkart', buyUrl: 'https://dl.flipkart.com/x'),
        ).priceLabel,
        'See price on Flipkart',
      );
      expect(
        pvGuardRetailerPrice(_p(retailer: 'Amazon.in', buyUrl: null)).price,
        0,
      );
    });

    test('brand networks and our own products keep their price', () {
      expect(
        pvGuardRetailerPrice(
          _p(retailer: 'FirstCry', buyUrl: 'https://www.firstcry.com/x'),
        ).price,
        349,
      );
      expect(pvGuardRetailerPrice(_p(soldHere: true)).price, 349);
    });

    test('no Amazon or Flipkart item in the whole catalogue shows our number', () {
      final guarded = [
        for (final p in buildPvCatalog())
          if (pvApiPricedRetailer(p) != null) p,
      ];
      expect(guarded, isNotEmpty);
      for (final p in guarded) {
        if (p.priceCheckedAt != null) continue;
        expect(p.price, 0, reason: '${p.id} shows a hand-typed price');
        for (final v in p.variants) {
          expect(v.price, 0, reason: '${p.id} prices its size ${v.label}');
        }
        expect(p.extRating, 0, reason: '${p.id} shows hand-typed stars');
      }
    });

    test('the catalogue store guards server rows as well', () {
      final src = _read('lib/services/pv_catalog_store.dart');
      expect(src, contains('pvGuardRetailerPrice(r)'));
    });
  });

  group('parents\' own reviews (0119)', () {
    final sql = _read('supabase/migrations/0119_product_reviews.sql');

    test('every column the phone sends exists in the table', () {
      final row = PvStoreReview(
        id: 'rv_x',
        productId: 'p',
        rating: 5,
        createdAt: DateTime(2026),
      ).toRow();
      final start = sql.indexOf('create table if not exists public.product_reviews');
      final body = sql.substring(start, sql.indexOf(');', start));
      for (final k in row.keys) {
        expect(
          RegExp('^\\s*$k\\s', multiLine: true).hasMatch(body),
          isTrue,
          reason: 'product_reviews has no column $k',
        );
      }
      expect(row.containsKey('moderation_status'), isFalse);
      expect(row.containsKey('verified'), isFalse);
    });

    test('the phone can never approve or verify its own review', () {
      expect(sql, contains("new.moderation_status := 'pending'"));
      expect(sql, contains('new.verified := false'));
      expect(sql, contains("auth.role(), '') <> 'service_role'"));
      expect(sql, contains("moderation_status = 'approved'"));
    });

    test('a review says whose word it is, never "Verified purchase"', () {
      final r = PvStoreReview(
        id: 'rv_x',
        productId: 'p',
        rating: 4,
        boughtAt: 'Amazon',
        createdAt: DateTime(2026),
      );
      expect(pvReviewSourceLine(r), 'Bought on Amazon, says the parent');
      for (final f in [
        'lib/services/pv_review_store.dart',
        'lib/screens/products/pv_product_screen.dart',
      ]) {
        final code = _read(f)
            .split('\n')
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        expect(
          code.contains("'Verified purchase'"),
          isFalse,
          reason: '$f labels an unseen purchase as verified',
        );
      }
    });

    test('saved locally first, shown to her at once', () async {
      SharedPreferences.setMockInitialValues({});
      final s = PvReviewStore.instance..resetForTest();
      await s.init();
      await s.save(productId: 'p1', rating: 4, body: ' Good. ', boughtAt: 'Amazon');
      final mine = s.mineFor('p1')!;
      expect(mine.body, 'Good.');
      expect(mine.status, 'pending');
      expect(mine.sent, isFalse, reason: 'logged out: nothing confirmed it');
      expect(s.shownFor('p1').single.id, mine.id);

      // An edit keeps the id, so the cloud row is the same row.
      await s.save(productId: 'p1', rating: 2);
      expect(s.mineFor('p1')!.id, mine.id);
      expect(s.mineFor('p1')!.rating, 2);

      // And it survives a restart.
      s.resetForTest();
      await s.init();
      expect(s.mineFor('p1')!.rating, 2);
    });
  });

  group('wiring gate', () {
    test('"Did you buy it?" is asked on return and the rating is reachable', () {
      final src = _read('lib/screens/products/pv_product_screen.dart');
      expect(src, contains('WidgetsBinding.instance.addObserver(this)'));
      expect(src, contains('_awaitingBuy = p.id'));
      expect(src, contains('if (p != null) _askBought(p);'));
      expect(src, contains('onTap: () => _rate(product)'));
      expect(src, contains('PvReviewStore.instance.shownFor(product.id)'));
    });

    test('the review store starts with the app', () {
      expect(_read('lib/main.dart'), contains('PvReviewStore.instance.init()'));
    });
  });
}
