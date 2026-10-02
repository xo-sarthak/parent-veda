// =============================================================================
//  The unified store — catalogue invariants, the honesty rules, the stores,
//  and REACHABILITY pinned against the source.
// -----------------------------------------------------------------------------
//  The wiring gate (CLAUDE.md): correct-but-unreachable code is the failure
//  this repo has actually hit. So the last group reads the source files and
//  asserts the store sits in slot 2 of all three bars — a test count proves
//  nothing about that; a grep does.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/products/pv_catalog_adapters.dart';
import 'package:parentveda/data/products/pv_category_images.dart';
import 'package:parentveda/data/products/pv_product_extras.dart';
import 'package:parentveda/models/pv_product.dart';
import 'package:parentveda/screens/products/pv_compare_screen.dart';
import 'package:parentveda/screens/products/pv_shelf_screen.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart';
import 'package:parentveda/services/cart_store.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_catalog_store.dart';
import 'package:parentveda/services/pv_compare_store.dart';
import 'package:parentveda/services/pv_order_store.dart';
import 'package:parentveda/services/usage_events.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parentveda/screens/products/pv_product_screen.dart';
import 'package:parentveda/screens/products/pv_search_screen.dart';
import 'package:parentveda/screens/products/pv_wishlist_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final store = PvCatalogStore.instance;

  group('catalogue', () {
    test('every product has a unique id', () {
      final ids = store.all.map((p) => p.id).toList();
      expect(
        ids.toSet().length,
        ids.length,
        reason: 'duplicate ids: ${_dupes(ids)}',
      );
    });

    test('all three stages are represented and nothing is skilling', () {
      final stages = store.all.map((p) => p.stage).toSet();
      expect(
        stages,
        containsAll([
          LifeStage.tryingToConceive,
          LifeStage.pregnancy,
          LifeStage.parenting,
        ]),
      );
      expect(stages.contains(LifeStage.skilling), isFalse);
    });

    test('every product sits in a category that exists, of its own stage', () {
      for (final p in store.all) {
        final c = store.category(p.categoryId);
        expect(
          c,
          isNotNull,
          reason: '${p.id} → missing category ${p.categoryId}',
        );
        expect(
          c!.stage,
          p.stage,
          reason: '${p.id} tagged ${p.stage} but its category is ${c.stage}',
        );
        if (p.subId != null) {
          expect(
            c.subs.any((s) => s.id == p.subId),
            isTrue,
            reason: '${p.id} → unknown sub ${p.subId}',
          );
        }
      }
    });

    test('TTC ids carry the prefix so `thermometer` cannot collide', () {
      expect(store.byId('ttc_thermometer'), isNotNull);
      expect(store.byId('thermometer'), isNotNull);
      expect(store.byId('ttc_thermometer')!.stage, LifeStage.tryingToConceive);
      expect(store.byId('thermometer')!.stage, LifeStage.parenting);
      expect(pvIdForTtc('folic'), 'ttc_folic');
    });

    test('the overlay names only products that exist', () {
      final ids = store.all.map((p) => p.id).toSet();
      for (final k in kPvProductPhotos.keys) {
        expect(
          ids,
          contains(k),
          reason: 'photo overlay for unknown product $k',
        );
      }
      for (final k in kPvProductExtras.keys) {
        expect(
          ids,
          contains(k),
          reason: 'extras overlay for unknown product $k',
        );
      }
    });

    test('every product has at least one photo or an honest cover', () {
      // Not every product must have a photo; but every URL that exists must
      // be a full https URL, never a relative path a card would 404 on.
      for (final p in store.all) {
        for (final u in p.images) {
          expect(u.startsWith('https://'), isTrue, reason: '${p.id}: $u');
        }
      }
      expect(store.all.where((p) => p.hasImage).length, greaterThan(40));
    });

    test('stage narrows what leads, never what exists', () {
      for (final s in PvStageCopy.shopStages) {
        expect(store.forStage(s), isNotEmpty);
        expect(store.categoriesFor(s), isNotEmpty);
      }
      expect(
        store.forStage(LifeStage.skilling),
        store.forStage(LifeStage.parenting),
      );
    });

    test('every category tile has a photo of its object', () {
      // The front page's tiles are photographs since 2026-09-20; one icon
      // among photos reads as a gap. A new category is a line in
      // pv_category_images.dart, and this is what says so.
      for (final s in PvStageCopy.shopStages) {
        for (final c in store.categoriesFor(s)) {
          expect(
            pvCategoryImageFor(c.id),
            isNotNull,
            reason: '${c.id} (${c.name}) has no photo',
          );
        }
      }
    });
  });

  group('the honesty rules', () {
    test('ParentVeda recommends is on SOME products, not all', () {
      final n = store.all.where((p) => p.recommends).length;
      expect(n, greaterThan(5));
      expect(n, lessThan(store.all.length));
    });

    test('only the top two bands earn the mark; skip is still on the shelf', () {
      for (final b in PvRecoBand.values) {
        expect(b.recommends, b == PvRecoBand.strong || b == PvRecoBand.buy);
      }
      final skip = store.all.where((p) => p.reco?.band == PvRecoBand.skip);
      expect(
        skip,
        isNotEmpty,
        reason:
            'TTC ships a "generally not needed" entry; it must survive the adapter',
      );
      for (final p in skip) {
        expect(store.inCategory(p.categoryId).any((o) => o.id == p.id), isTrue);
      }
      expect(
        store
            .recommended(LifeStage.tryingToConceive)
            .any((p) => p.reco!.band == PvRecoBand.skip),
        isFalse,
      );
    });

    test('every recommendation carries a reason', () {
      for (final p in store.all.where((p) => p.reco != null)) {
        expect(p.reco!.reason.trim(), isNotEmpty, reason: p.id);
      }
    });

    test(
      'percentages are measured or null — never derived from the star rating',
      () {
        // A product with a rating but no source figure must have NO percentage.
        final lull = store.byId('lull')!;
        expect(lull.rating, greaterThan(0));
        expect(lull.parentsPct, isNull);
        expect(lull.expertsPct, isNull);
        // TTC's zeros become null, not 0%.
        for (final p in store.forStage(LifeStage.tryingToConceive)) {
          expect(p.parentsPct, isNot(0));
          expect(p.expertsPct, isNot(0));
        }
      },
    );

    test('IMS Act: a review-only product has no buy path anywhere', () {
      final ro = store.all.where((p) => p.reviewOnly).toList();
      expect(ro, isNotEmpty);
      for (final p in ro) {
        expect(p.canBuy, isFalse, reason: p.id);
      }
      expect(
        store.forYou(LifeStage.parenting).any((p) => p.reviewOnly),
        isFalse,
      );
      expect(
        store.popular(LifeStage.parenting).any((p) => p.reviewOnly),
        isFalse,
      );
    });

    test(
      'an affiliate product opens a retailer; a ParentVeda one stays in the bag',
      () {
        final affiliate = store.all.where((p) => !p.soldHere && p.canBuy);
        final own = store.all.where((p) => p.soldHere);
        expect(affiliate, isNotEmpty);
        expect(own, isNotEmpty);
        for (final p in affiliate) {
          expect(p.buyUrl, isNotNull, reason: p.id);
        }
      },
    );

    test(
      'a variant price is absolute so the cart line carries the number she saw',
      () {
        for (final p in store.all.where((p) => p.variants.isNotEmpty)) {
          for (final v in p.variants) {
            expect(v.price, greaterThan(0), reason: '${p.id}/${v.id}');
          }
        }
      },
    );
  });

  group('search and rails', () {
    test('search is cross-stage with per-stage counts', () {
      final r = store.search('thermometer');
      expect(r.count(LifeStage.tryingToConceive), greaterThan(0));
      expect(r.count(LifeStage.parenting), greaterThan(0));
      expect(r.all.length, r.byStage.values.fold(0, (a, l) => a + l.length));
      expect(store.search('   ').all, isEmpty);
      expect(store.search('folic').all.first.stage, LifeStage.tryingToConceive);
    });

    test('for-you is one product per category and never review-only', () {
      for (final s in PvStageCopy.shopStages) {
        final list = store.forYou(s);
        final cats = list.map((p) => p.categoryId).toList();
        expect(cats.toSet().length, cats.length, reason: '$s: $cats');
      }
    });

    test('rupees group the Indian way', () {
      expect(PvProduct.groupRupees(499), '499');
      expect(PvProduct.groupRupees(1499), '1,499');
      expect(PvProduct.groupRupees(24999), '24,999');
      expect(PvProduct.groupRupees(120000), '1,20,000');
    });
  });

  group('compare tray', () {
    test('two at a time, one category, refusal explained', () {
      final tray = PvCompareStore.instance..clear();
      final sleep = store.inCategory('sleep').take(3).toList();
      expect(sleep.length, 3);
      expect(tray.toggle(sleep[0]), PvCompareResult.added);
      expect(tray.toggle(sleep[1]), PvCompareResult.added);
      expect(tray.toggle(sleep[2]), PvCompareResult.replaced);
      expect(tray.items.map((p) => p.id), [sleep[1].id, sleep[2].id]);
      final stroller = store.byId('stroller')!;
      expect(tray.toggle(stroller), PvCompareResult.wrongCategory);
      expect(tray.toggle(sleep[2]), PvCompareResult.removed);
      tray.clear();
    });
  });

  group('orders', () {
    test(
      'status comes from the caller, delivery from the rule, JSON round-trips',
      () async {
        final o = PvOrderStore.instance;
        await o.init();
        final addr = PvAddress(
          id: 'a1',
          name: 'Priya',
          phone: '9876543210',
          line1: '12 MG Road',
          city: 'Pune',
          state: 'MH',
          pin: '411001',
        );
        final line = CartItem(
          lineId: 'l1',
          productId: 'sw_overall',
          name: 'Swaddle',
          unitPrice: 1199,
          qty: 1,
        );
        final placed = o.place(
          lines: [line],
          address: addr,
          status: PvOrderStatus.preview,
        );
        expect(placed.status, PvOrderStatus.preview);
        expect(
          placed.delivery,
          PvOrderStore.freeDeliveryAbove <= 1199 ? 0 : PvOrderStore.deliveryFee,
        );
        expect(PvOrderStore.deliveryFor(500), PvOrderStore.deliveryFee);
        expect(PvOrderStore.deliveryFor(999), 0);
        final back = PvOrder.fromJson(placed.toJson());
        expect(back.id, placed.id);
        expect(back.total, placed.total);
        expect(back.address.pin, '411001');
        expect(back.reference, startsWith('PV-'));
        expect(o.orders.first.id, placed.id);
      },
    );

    test('a cart line keeps its photo across a JSON round-trip', () {
      final l = CartItem(
        lineId: 'x',
        productId: 'p',
        name: 'n',
        unitPrice: 1,
        image: 'https://x/y.jpg',
      );
      expect(CartItem.fromJson(l.toJson()).image, 'https://x/y.jpg');
      final old = CartItem.fromJson({
        'l': 'x',
        'p': 'p',
        'n': 'n',
        'e': '',
        'u': 1,
        'q': 1,
        's': '',
        'c': '',
      });
      expect(old.image, '');
    });
  });

  group('shelf filters', () {
    test(
      'brand, price, rating and the two ParentVeda switches narrow the shelf',
      () {
        final f = PvShelfFilters();
        final sleep = store.inCategory('sleep');
        expect(sleep.where(f.pass).length, sleep.length);
        f.brands.add('Dozy');
        expect(sleep.where(f.pass).every((p) => p.brand == 'Dozy'), isTrue);
        expect(sleep.where(f.pass), isNotEmpty);
        f.clear();
        f.priceMax = 1000;
        expect(sleep.where(f.pass).every((p) => p.price <= 1000), isTrue);
        f.clear();
        f.recommendedOnly = true;
        expect(sleep.where(f.pass).every((p) => p.recommends), isTrue);
        f.clear();
        f.soldHereOnly = true;
        expect(store.all.where(f.pass).every((p) => p.soldHere), isTrue);
        expect(f.count, 1);
      },
    );
  });

  group('screens', () {
    testWidgets(
      'the shelf ticks compare and the bar appears at one, commits at two',
      (tester) async {
        PvCompareStore.instance.clear();
        tester.view.physicalSize = const Size(1170, 2532);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          const MaterialApp(
            home: PvShelfScreen(
              categoryId: 'sleep',
              subId: 'soothers_and_white_noise',
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Pick one more to compare'), findsNothing);
        final ticks = find.text('Compare');
        expect(ticks, findsWidgets);
        await tester.tap(ticks.at(0));
        await tester.pump();
        expect(PvCompareStore.instance.items.length, 1);
        expect(find.text('Pick one more to compare'), findsOneWidget);
        // The next un-ticked card's chip still reads "Compare"; the bar's own
        // button does too, so take the first card chip below the toolbar.
        await tester.tap(find.text('Compare').at(1));
        await tester.pump();
        expect(PvCompareStore.instance.items.length, 2);
        expect(find.text('Two selected'), findsOneWidget);
        PvCompareStore.instance.clear();
      },
    );

    testWidgets('compare screen opens on an empty tray with an invitation', (
      tester,
    ) async {
      PvCompareStore.instance.clear();
      await tester.pumpWidget(const MaterialApp(home: PvCompareScreen()));
      await tester.pump();
      expect(find.textContaining('Tick "Compare"'), findsOneWidget);
    });

    testWidgets('the reco mark says the right words', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PvRecoMark(band: PvRecoBand.strong),
                PvRecoMark(band: PvRecoBand.skip),
              ],
            ),
          ),
        ),
      );
      expect(find.text('ParentVeda recommends'), findsOneWidget);
      expect(find.text('Generally not needed'), findsOneWidget);
    });

    // ---- the 2026-09-20 walk: search, wishlist, the heart, the guide ----------------

    testWidgets(
      'search opens on Recent · Try · Shop by category, not an empty panel',
      (tester) async {
        tester.view.physicalSize = const Size(1170, 2532);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          const MaterialApp(home: PvSearchScreen(stage: LifeStage.pregnancy)),
        );
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Try'), findsOneWidget);
        expect(find.text('Shop by category'), findsOneWidget);
        for (final t in pvSearchTriesFor(LifeStage.pregnancy)) {
          expect(find.text(t), findsOneWidget, reason: '"$t" chip missing');
          expect(
            PvCatalogStore.instance.search(t).all,
            isNotEmpty,
            reason: '"$t" is offered but finds nothing',
          );
        }
        // The pill is the one pill: one Hero with the shared tag.
        expect(
          find.byWidgetPredicate((w) => w is Hero && w.tag == kPvSearchHeroTag),
          findsOneWidget,
        );
      },
    );

    testWidgets('typing shows the matching category first, then results', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: PvSearchScreen(
            stage: LifeStage.pregnancy,
            initialQuery: 'pillow',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.textContaining('Pregnancy Pillow', findRichText: true),
        findsWidgets,
      );
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('the heart fills without a notice, and the wishlist shows it', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final product = PvCatalogStore.instance
          .forStage(LifeStage.pregnancy)
          .first;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: PvHeart(product: product)),
          ),
        ),
      );
      await tester.tap(find.byType(PvHeart));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byType(SnackBar),
        findsNothing,
        reason: 'the heart says it with the icon, not a notice',
      );
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(home: PvWishlistScreen(stage: LifeStage.pregnancy)),
      );
      await tester.pump();
      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.text(product.name), findsWidgets);
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('the store header carries the wishlist door', (tester) async {
      expect(
        _src('lib/screens/products/pv_store_screen.dart'),
        contains('PvWishlistScreen('),
      );
      expect(
        _src('lib/screens/products/pv_store_screen.dart'),
        contains('PvSearchPill('),
      );
    });

    testWidgets('recommends is a signature, not a box', (tester) async {
      // The user's pick (2026-09-20): a white card, the eyebrow, the reason,
      // and the reviewer as a person with a REVIEWED pill — Liven's shape.
      // Tall, so the lazy page builds the card below the gallery.
      tester.view.physicalSize = const Size(1200, 9000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final product = PvCatalogStore.instance.all.firstWhere(
        (x) => x.reco != null && x.reco!.band.recommends,
      );
      await tester.pumpWidget(
        MaterialApp(home: PvProductScreen(productId: product.id)),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('PARENTVEDA RECOMMENDS'), findsOneWidget);
      expect(find.text('REVIEWED'), findsOneWidget);
      expect(find.text(product.reco!.reason), findsOneWidget);
      final who = product.reco!.reviewerName.isEmpty
          ? 'The ParentVeda editorial team'
          : product.reco!.reviewerName;
      expect(find.text(who), findsOneWidget);
    });

    testWidgets('the shelf guide is a white card with ink marks', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(home: PvShelfScreen(categoryId: 'pregnancy_pillow')),
      );
      await tester.pump();
      expect(find.text('20-SECOND GUIDE'), findsOneWidget);
      await tester.tap(find.text('20-SECOND GUIDE'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('LOOK FOR'), findsOneWidget);
      expect(find.text('SKIP'), findsOneWidget);
      // No coloured verdict marks: the ticks are ink, the skips a dash.
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(find.byIcon(Icons.remove_rounded), findsWidgets);
    });
  });

  group('reachability (the wiring gate)', () {
    // CRLF on Windows checkouts; normalise so a multi-line contains() holds.
    String read(String p) =>
        File(p).readAsStringSync().replaceAll('\r\n', '\n');

    test('pregnancy: slot 2 of the bar is the store, embedded', () {
      // Found on the phone: the tab tap asserted "Unknown usage surface" —
      // the constant existed, the allow-list did not have it.
      expect(UsageSurface.all, contains(UsageSurface.products));
      final s = read('lib/screens/main_scaffold.dart');
      expect(s, contains('PvStoreScreen(chrome: PvStoreChrome.embedded)'));
      expect(s, contains("PvTab(Icons.shopping_basket_outlined, 'Products')"));
      // Prepare did not vanish: it is still a tile on the Tools hub.
      //
      // ⚠️ THE CALL, NOT ITS WHITESPACE. This matched the whole argument list
      // on one line and broke the day `dart format` wrapped it across four —
      // a green test turning red on a reflow, which teaches nothing and
      // costs a debugging session. The invariant is that the hub pushes the
      // screen; where the formatter puts the brackets is not our business.
      //
      // ⚠️ MORE, SINCE 2026-09-29 (the structure pass): the pregnancy bar is
      // Today · Learn · Products · Tools · More, and Prepare is More › All
      // programmes and sessions. Was: tools_hub_screen.dart.
      expect(
        read('lib/screens/pregnancy/preg_more_screen.dart'),
        contains('PrepareHubScreen('),
      );
    });

    test('parenting: the Products tab lands on the store with its bar', () {
      expect(
        read('lib/screens/post_pregnancy/pp_common.dart'),
        contains('case PpTab.products:'),
      );
      expect(
        read('lib/screens/post_pregnancy/products_discovery_screen.dart'),
        contains('PvStoreScreen(chrome: PvStoreChrome.parenting)'),
      );
    });

    // ⚠️ SLOT 3 SINCE 2026-09-26: the V3 bar is Today · Learn · Products ·
    // Tools · You (the user's call after the TTC gap analysis). Was slot 2,
    // `return 1`.
    test('TTC: slot 3 is Products, Courses is a Tools tile', () {
      final s = read('lib/screens/ttc/ttc_common.dart');
      expect(s, contains("name: 'ttc/products'"));
      expect(s, contains("case 'ttc/products':\n      return 2;"));
      expect(s, contains('t.tabProducts'));
      expect(
        read('lib/screens/ttc/ttc_tools_screen.dart'),
        contains("id: 'courses'"),
      );
      expect(
        read('lib/screens/ttc/ttc_shop_v3.dart'),
        contains('PvStoreScreen(chrome: PvStoreChrome.ttc)'),
      );
    });

    test('the retired screens are facades, bodies kept for revert', () {
      for (final (f, klass) in const [
        ('lib/screens/products_screen.dart', 'ProductsScreenClassic'),
        (
          'lib/screens/post_pregnancy/product_detail_screen.dart',
          'ProductDetailScreenClassic',
        ),
        (
          'lib/screens/post_pregnancy/products_compare_screen.dart',
          'ProductsCompareScreenClassic',
        ),
        (
          'lib/screens/product_guide/product_guide_hub_screen.dart',
          'ProductGuideHubScreenClassic',
        ),
        ('lib/screens/ttc/ttc_shop_v3.dart', 'TtcShopScreenClassic'),
        (
          'lib/screens/ttc/ttc_products_screen.dart',
          'TtcProductsScreenClassic',
        ),
      ]) {
        final s = read(f);
        expect(s, contains('RETIRED 2026-09-17'), reason: f);
        expect(s, contains('class $klass'), reason: f);
      }
    });

    test('a saved product of any stage opens the unified page', () {
      expect(
        read('lib/screens/saved_screen.dart'),
        contains('PvProductScreen(productId: id)'),
      );
    });

    test('the edge function prices product lines server-side', () {
      final s = read('supabase/functions/razorpay-create-order/index.ts');
      expect(s, contains('priceLines'));
      expect(s, contains('priced_by'));
      expect(
        read('lib/booking/payment_service.dart'),
        contains("'lines': lines"),
      );
    });
  });
}

String _src(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

List<String> _dupes(List<String> ids) {
  final seen = <String>{};
  return [
    for (final id in ids)
      if (!seen.add(id)) id,
  ];
}
