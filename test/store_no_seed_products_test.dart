// =============================================================================
//  No fake products, and "Coming soon" where the sheet has a gap (2026-10-28).
//
//  The user: "no need to have fake situations in the app... show whatever we
//  have", then: "consider the sheet as the source of truth, and wherever a
//  product or category is essential and the sheet does not cover it, have it,
//  but say Coming soon on it, like marketplace apps do."
//
//  What this holds:
//    · the 47 invented seed products (24 pregnancy, 23 parenting) are out of
//      the default catalogue; the TTC seed and the team's sheet are all in;
//    · the product checklist's starters are named things with no product id,
//      and each name finds something real in the store (or its place-holder);
//      a list saved on a seed product reads as the group's plain name, with
//      no seed price;
//    · a cart from before loses its seed lines, and says so;
//    · each "Coming soon" place-holder: no brand, price, photo or link, never
//      sold here, last on its shelf, never on a rail, and it steps aside the
//      moment its shelf has a real product; none for bottles, sterilisers or
//      baby lotion.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/product_data.dart' as preg_data;
import 'package:parentveda/data/products/pv_catalog_adapters.dart';
import 'package:parentveda/data/products/pv_coming_soon.dart';
import 'package:parentveda/data/products/pv_sheet_products.dart';
import 'package:parentveda/models/pv_product.dart';
import 'package:parentveda/screens/post_pregnancy/pp_products_data.dart' as pp;
import 'package:parentveda/screens/products/pv_cart_screen.dart';
import 'package:parentveda/screens/products/pv_product_screen.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart'
    show PvComingSoonPill;
import 'package:parentveda/screens/tools/product_checklist_screen.dart';
import 'package:parentveda/services/cart_store.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/product_checklist_store.dart';
import 'package:parentveda/services/pv_catalog_store.dart';
import 'package:parentveda/ttc/ttc_products_data.dart' as ttc;

/// The 47 retired ids, written out: the test must not trust the code's own
/// list to say what it retired.
const _seedIds = {
  // pregnancy (product_data.dart kProducts)
  'pp_overall', 'pp_budget', 'pp_premium',
  'sc_overall', 'sc_sensitive', 'sc_budget',
  'mw_overall', 'mw_premium', 'mw_budget',
  'bb_overall', 'bb_budget', 'bb_premium',
  'cs_overall', 'cs_budget', 'cs_premium',
  'nb_overall', 'nb_budget', 'nb_premium',
  'bp_overall', 'bp_budget', 'bp_premium',
  'sw_overall', 'sw_budget', 'sw_premium',
  // parenting (pp_products_data.dart kPpProducts)
  'dozy', 'lull', 'hush', 'cloudtunes', 'cosysuit', 'merinosack',
  'hushcurtains', 'snugglesack', 'lotion', 'rashcream', 'babywash',
  'bottle', 'spoons', 'steriliser', 'playgym', 'clothbook', 'crinkle',
  'thermometer', 'cornerguard', 'firstaid', 'stroller', 'carrier', 'carseat',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final store = PvCatalogStore.instance;

  group('the seed is out', () {
    test('the written-out list is the bundled seed, all 47', () {
      expect(_seedIds.length, 47);
      expect(
        {
          for (final p in preg_data.kProducts) p.id,
          for (final p in pp.kPpProducts) p.id,
        },
        _seedIds,
      );
      expect(kPvRetiredSeedIds, _seedIds);
      expect(kPvShowSeedProducts, isFalse, reason: 'tests run without the demo define');
    });

    test('the default catalogue holds none of them', () {
      final ids = {for (final p in buildPvCatalog()) p.id};
      expect(ids.intersection(_seedIds), isEmpty);
      for (final id in _seedIds) {
        expect(store.byId(id), isNull, reason: id);
        expect(pvIsRetiredSeedId(id), isTrue, reason: id);
      }
      expect(store.byId('nb_overall'), isNull);
    });

    test('every TTC seed product and every sheet product is still there', () {
      final ids = {for (final p in buildPvCatalog()) p.id};
      for (final p in ttc.ttcProducts) {
        expect(ids, contains(pvIdForTtc(p.id)));
      }
      final sheet = sheetProducts();
      expect(sheet, isNotEmpty);
      for (final p in sheet) {
        expect(ids, contains(p.id));
      }
    });

    test('a retired seed id reads as its group, and nothing else does', () {
      expect(pvSeedGenericName('nb_overall'), 'Nursing bra');
      expect(pvSeedGenericName('sc_sensitive'), 'Stretch mark cream');
      expect(pvSeedGenericName('pvs_anything'), isNull);
      expect(pvIsRetiredSeedId('pvs_boppy_total_body_custom_pillow'), isFalse);
      expect(pvIsRetiredSeedId('ttc_folic'), isFalse);
    });
  });

  group('the product checklist', () {
    test('every starter item is a named thing with no product id', () {
      for (final l in kCuratedChecklists) {
        for (final i in l.items) {
          expect(i.productId, isEmpty, reason: '${l.name} / ${i.name}');
          expect(i.name.trim(), isNotEmpty);
        }
      }
    });

    test('every starter name finds something real in the store, or its '
        '"Coming soon" where the sheet has a gap; never an empty search', () {
      for (final l in kCuratedChecklists) {
        for (final i in l.items) {
          final hits = store.search(i.name).all;
          expect(hits, isNotEmpty, reason: i.name);
          final real = hits.where((p) => !p.comingSoon);
          if (real.isEmpty) {
            expect(hits.first.comingSoon, isTrue, reason: i.name);
          }
        }
      }
      // The band is the one starter the sheet does not cover yet.
      final band = store.search('Belly support band').all;
      expect(band.map((p) => p.id), contains('${kPvComingSoonPrefix}belly_band'));
      // The rest find real products.
      for (final n in [
        'Swaddles',
        'Nursing bras',
        'Breast pump',
        'Pregnancy pillow',
        'Compression socks',
        'Stretch mark cream',
        'Maternity leggings',
      ]) {
        expect(store.search(n).all.where((p) => !p.comingSoon), isNotEmpty,
            reason: n);
      }
    });

    test('adopting a starter makes named items, with her notes, not hers', () {
      final cl = ProductChecklistStore.instance;
      final id = cl.adoptCurated(kCuratedChecklists.first);
      final items = cl.byId(id)!.items;
      expect(items.length, kCuratedChecklists.first.items.length);
      for (final it in items) {
        expect(it.isCustom, isTrue);
        expect(it.isStarter, isTrue);
        expect(it.name, isNotEmpty);
        expect(it.note, isNotEmpty);
      }
      cl.deleteChecklist(id);
    });

    // Real async (prefs, the store's load) runs here, outside the widget
    // test's fake clock, where it would never finish.
    late PregnancyController c;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      c = PregnancyController(
          dueDate: DateTime.now().add(const Duration(days: 100)));
      await c.load();
      final cl = ProductChecklistStore.instance;
      await cl.init();
      for (final l in List.of(cl.checklists)) {
        cl.deleteChecklist(l.id);
      }
    });

    testWidgets('a list saved on a seed product reads as its group, with no '
        'seed price, and keeps its tick', (t) async {
      final cl = ProductChecklistStore.instance;
      final id = cl.createChecklist('Old list');
      cl.addItem(id, 'nb_overall', note: 'Day zero');
      cl.toggleChecked(id, 'nb_overall');
      final seed = preg_data.productById('nb_overall')!;
      t.view.physicalSize = const Size(900, 3000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: ProductChecklistScreen(controller: c)));
      await t.pump();
      await t.tap(find.text('Old list'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Nursing bra'), findsWidgets);
      expect(find.text(seed.name.en), findsNothing);
      expect(find.text(seed.price), findsNothing);
      expect(find.text('Day zero'), findsOneWidget);
      expect(find.textContaining('1 of 1'), findsOneWidget,
          reason: 'the tick stays');
      cl.deleteChecklist(id);
      await t.pump(const Duration(seconds: 5));
    });
  });

  group('the cart', () {
    testWidgets('a seed line from before is taken out, and she is told',
        (t) async {
      final cart = CartStore.instance;
      cart.clear(kProductsCartId);
      cart.add(kProductsCartId,
          productId: 'sw_overall', name: 'Swaddle', unitPrice: 1199);
      t.view.physicalSize = const Size(900, 2400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: PvCartScreen()));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(cart.items(kProductsCartId), isEmpty);
      expect(find.textContaining('no longer listed'), findsOneWidget);
      expect(find.text('Nothing in your cart yet.'), findsOneWidget);
      await t.pump(const Duration(seconds: 6));
    });
  });

  group('Coming soon', () {
    final soon = [for (final p in buildPvCatalog()) if (p.comingSoon) p];

    test('each place-holder is there, plain: no brand, price, photo or link',
        () {
      expect({for (final p in soon) p.id},
          {for (final e in kPvComingSoon) e.id});
      expect(soon.length, 11);
      for (final p in soon) {
        expect(p.id, startsWith(kPvComingSoonPrefix));
        expect(p.comingSoon, isTrue);
        expect(p.brand, isEmpty, reason: p.id);
        expect(p.price, 0, reason: p.id);
        expect(p.mrp, isNull, reason: p.id);
        expect(p.images, isEmpty, reason: p.id);
        expect(p.buyUrl, isNull, reason: p.id);
        expect(p.soldHere, isFalse, reason: p.id);
        expect(p.rating, 0, reason: p.id);
        expect(p.reviewCount, 0, reason: p.id);
        expect(p.reviews, isEmpty, reason: p.id);
        expect(p.specs, isEmpty, reason: p.id);
        expect(p.reco, isNull, reason: p.id);
        expect(store.category(p.categoryId)?.stage, p.stage, reason: p.id);
      }
    });

    test('they stand on the right shelves', () {
      String shelf(String id) => store.byId('$kPvComingSoonPrefix$id')!.categoryId;
      LifeStage stage(String id) => store.byId('$kPvComingSoonPrefix$id')!.stage;
      expect(shelf('belly_band'), 'belly_band');
      expect(shelf('maternity_wear'), 'maternity_wear');
      expect(stage('belly_band'), LifeStage.pregnancy);
      for (final id in ['white_noise', 'sleep_sack', 'blackout_curtains']) {
        expect(shelf(id), 'sleep');
        expect(stage(id), LifeStage.parenting);
      }
      expect(shelf('nappy_rash_cream'), 'skincare');
      expect(shelf('baby_wash'), 'skincare');
      expect(shelf('weaning_spoons'), 'feeding');
      expect(shelf('baby_proofing'), 'health_and_safety');
      expect(shelf('first_aid_kit'), 'health_and_safety');
      expect(shelf('stroller'), 'on_the_move');
    });

    test('none for bottles, sterilisers or baby lotion (IMS Act; NHS)', () {
      for (final e in kPvComingSoon) {
        expect(const {'bottle', 'steriliser', 'lotion'}.contains(e.seedId),
            isFalse, reason: e.id);
        final n = e.name.toLowerCase();
        for (final w in ['bottle', 'steril', 'lotion']) {
          expect(n.contains(w), isFalse, reason: e.name);
        }
      }
    });

    test('the step-aside rule: a real product on the shelf retires it', () {
      final band = soon.firstWhere((p) => p.id.endsWith('belly_band'));
      final other = soon.firstWhere((p) => p.id.endsWith('stroller'));
      expect(pvPlaceComingSoon([band, other]), [band, other]);
      final real = PvProduct(
        id: 'pvs_test_real_band',
        stage: band.stage,
        categoryId: band.categoryId,
        name: 'A real band',
        brand: 'Real',
        summary: '',
        images: const [],
        price: 999,
      );
      final placed = pvPlaceComingSoon([band, other, real]);
      expect(placed.map((p) => p.id), [other.id, real.id]);
      // Same shelf id on another stage does not count.
      final elsewhere = PvProduct(
        id: 'pvs_test_other_stage',
        stage: LifeStage.parenting,
        categoryId: band.categoryId,
        name: 'x',
        brand: '',
        summary: '',
        images: const [],
        price: 1,
      );
      expect(pvPlaceComingSoon([band, elsewhere]).map((p) => p.id),
          contains(band.id));
    });

    test('a sheet row that lands on the shelf retires it in the store too', () {
      final s = PvCatalogStore.instance;
      expect(s.byId('${kPvComingSoonPrefix}belly_band'), isNotNull);
      s.applyStoreRows([
        {
          'source_key': 'pvs_test_band_row',
          'stage': ['pregnancy'],
          'category': 'belly_band',
          'name': 'Support Band',
          'brand': 'Test',
          'buy_url': 'https://www.amazon.in/s?k=belly+band',
        },
      ]);
      expect(s.byId('pvs_test_band_row'), isNotNull);
      expect(s.byId('${kPvComingSoonPrefix}belly_band'), isNull);
      expect(s.byId('${kPvComingSoonPrefix}maternity_wear'), isNotNull,
          reason: 'only the filled shelf loses its place-holder');
      s.applyStoreRows(const []);
      expect(s.byId('${kPvComingSoonPrefix}belly_band'), isNotNull);
    });

    test('last on every shelf and in search, never on a rail', () {
      expect(pvComingSoonLast([soon.first, ...buildPvCatalog().take(2)]).last,
          soon.first);
      final hits = store.search('maternity').all;
      final firstSoon = hits.indexWhere((p) => p.comingSoon);
      if (firstSoon >= 0) {
        expect(hits.skip(firstSoon).every((p) => p.comingSoon), isTrue);
      }
      for (final c in store.categories) {
        final list = store.inCategory(c.id);
        final i = list.indexWhere((p) => p.comingSoon);
        if (i >= 0) {
          expect(list.skip(i).every((p) => p.comingSoon), isTrue, reason: c.id);
        }
      }
      for (final st in PvStageCopy.shopStages) {
        expect(store.forYou(st).where((p) => p.comingSoon), isEmpty, reason: '$st');
        expect(store.popular(st).where((p) => p.comingSoon), isEmpty, reason: '$st');
        expect(store.recommended(st).where((p) => p.comingSoon), isEmpty,
            reason: '$st');
      }
    });

    testWidgets('its page: the pill, one calm line, no buy and no price',
        (t) async {
      t.view.physicalSize = const Size(1170, 2532);
      t.view.devicePixelRatio = 3.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(
          home: PvProductScreen(productId: '${kPvComingSoonPrefix}belly_band')));
      await t.pump();
      expect(find.text('Belly support band'), findsOneWidget);
      expect(find.byType(PvComingSoonPill), findsOneWidget);
      expect(find.text(kPvComingSoonLine), findsOneWidget);
      expect(find.textContaining('₹'), findsNothing);
      expect(find.text('Add to cart'), findsNothing);
      expect(find.textContaining('Buy'), findsNothing);
      expect(t.takeException(), isNull);
    });
  });
}
