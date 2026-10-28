// =============================================================================
//  Store Track A, slice 2 (2026-10-28): the product sheet → `products` → app
// -----------------------------------------------------------------------------
//  1. tools/products/store_categories.json (what the importer accepts) is the
//     app's own category list. Regenerate after adding a category:
//        WRITE_STORE_CATEGORIES=1 flutter test test/store_sheet_feed_test.dart
//  2. Every column the app reads from a row exists in the migrations.
//  3. A row becomes a product; an unreadable row is skipped, never guessed;
//     a row over a built-in product keeps the app's editorial work; an
//     Amazon row with a hand-typed price is cleared by the guard.
//  4. Wiring gate: the store loads the rows at start.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/products/pv_affiliate.dart';
import 'package:parentveda/data/products/pv_catalog_adapters.dart';
import 'package:parentveda/data/products/pv_product_rows.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_catalog_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

const _stageWord = {
  LifeStage.tryingToConceive: 'ttc',
  LifeStage.pregnancy: 'pregnancy',
  LifeStage.parenting: 'parenting',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cats = buildPvCategories();
  final catIds = {for (final c in cats) c.id};

  test('the importer accepts exactly the app\'s categories', () {
    final want = [
      for (final c in cats)
        {'id': c.id, 'stage': _stageWord[c.stage] ?? c.stage.name, 'name': c.name},
    ];
    final f = File('tools/products/store_categories.json');
    if (Platform.environment['WRITE_STORE_CATEGORIES'] == '1') {
      f.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(want)}\n',
      );
    }
    final have = jsonDecode(f.readAsStringSync()) as List;
    expect(
      [for (final c in have) (c as Map)['id']],
      [for (final c in want) c['id']],
      reason: 'store_categories.json is stale: re-run with WRITE_STORE_CATEGORIES=1',
    );
  });

  // The converter (tools/products/convert_finalized_picks.py) matches a
  // team sheet's picks to products the app already has, by brand + name, so
  // a link lands on the product (keeping its category and notes) instead of
  // a duplicate. This is the list it matches against.
  test('the converter\'s catalogue index is the app\'s catalogue', () {
    final want = [
      for (final p in buildPvCatalog())
        {
          'id': p.id,
          'brand': p.brand,
          'name': p.name,
          'stage': _stageWord[p.stage] ?? p.stage.name,
          'category': p.categoryId,
          'sub': p.subId ?? '',
          'has_link': (p.buyUrl ?? '').isNotEmpty,
        },
    ];
    final f = File('tools/products/store_catalogue_index.json');
    if (Platform.environment['WRITE_STORE_CATEGORIES'] == '1') {
      f.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(want)}\n',
      );
    }
    final have = jsonDecode(f.readAsStringSync()) as List;
    expect(
      {for (final c in have) (c as Map)['id']},
      {for (final c in want) c['id']},
      reason: 'store_catalogue_index.json is stale: re-run with WRITE_STORE_CATEGORIES=1',
    );
  });

  test('every column the app reads exists in the migrations', () {
    final sql = [
      for (final m in [
        '0049_products.sql',
        '0083_products_unified_and_orders.sql',
        '0108_products_affiliate.sql',
        '0120_store_sheet_feed.sql',
      ])
        _read('supabase/migrations/$m'),
    ].join('\n');
    final src = _read('lib/data/products/pv_product_rows.dart');
    final read = RegExp(r"row\['([a-z_]+)'\]")
        .allMatches(src)
        .map((m) => m.group(1)!)
        .toSet();
    expect(read, isNotEmpty);
    for (final c in read) {
      expect(
        RegExp('(^|\\s)$c\\s', multiLine: true).hasMatch(sql),
        isTrue,
        reason: 'products has no column $c',
      );
    }
  });

  group('a row becomes a product', () {
    final cat = cats.firstWhere((c) => c.stage == LifeStage.pregnancy).id;
    Map<String, dynamic> row([Map<String, dynamic> over = const {}]) => {
      'source_key': 'pva_test_cream',
      'name': 'Test cream',
      'brand': 'Brand',
      'stage': ['pregnancy'],
      'category': cat,
      'programme': 'inrdeals',
      'buy_url': 'https://example.com/x',
      'price_inr': 549,
      'price_checked_at': '2026-10-28',
      'pros': ['Soft'],
      'cons': ['Pricey'],
      'images': <String>[],
      ...over,
    };

    test('a full row', () {
      final p = pvProductFromStoreRow(row(), categoryIds: catIds)!;
      expect(p.id, 'pva_test_cream');
      expect(p.stage, LifeStage.pregnancy);
      expect(p.price, 549);
      expect(p.goods, ['Soft']);
      expect(p.watchOuts, ['Pricey']);
      expect(pvAffiliatePriceNote(p), contains('as of 28 Oct'));
    });

    test('an unreadable row is skipped, never guessed', () {
      expect(pvProductFromStoreRow(row({'name': ''}), categoryIds: catIds), isNull);
      expect(pvProductFromStoreRow(row({'stage': ['space']}), categoryIds: catIds), isNull);
      expect(pvProductFromStoreRow(row({'category': 'nope'}), categoryIds: catIds), isNull);
    });

    test('placeholders give the honest fallback', () {
      final p = pvProductFromStoreRow(
        row({'buy_url': null, 'price_inr': 0, 'programme': 'amazon', 'retailer': ''}),
        categoryIds: catIds,
      )!;
      expect(p.canBuy, isFalse, reason: 'no link yet = no buy button');
      expect(p.priceLabel, 'See price on Amazon');
    });

    test('an Amazon row with a typed price is cleared by the guard', () {
      final p = pvProductFromStoreRow(
        row({'programme': 'amazon', 'buy_url': 'https://www.amazon.in/dp/B000000000', 'price_checked_at': null}),
        categoryIds: catIds,
      )!;
      expect(pvGuardRetailerPrice(p).price, 0);
    });

    test('a row over a built-in product keeps the app\'s editorial work', () {
      final base = buildPvCatalog().firstWhere((p) => p.reco != null);
      final r = pvProductFromStoreRow(
        row({
          'source_key': base.id,
          'category': base.categoryId,
          'stage': [_stageWord[base.stage]],
          'name': 'Renamed',
        }),
        categoryIds: catIds,
      )!;
      final merged = pvMergeStoreRows([base], [r]);
      expect(merged.single.name, 'Renamed');
      expect(merged.single.reco, same(base.reco));
      expect(merged.single.buyUrl, 'https://example.com/x');
    });

    test('a new id is added, the rest of the catalogue stays', () {
      final base = buildPvCatalog();
      final merged = pvMergeStoreRows(base, [
        pvProductFromStoreRow(row(), categoryIds: catIds)!,
      ]);
      expect(merged.length, base.length + 1);
      expect(merged.last.id, 'pva_test_cream');
    });

    test('the store applies rows and keeps them on the phone', () async {
      SharedPreferences.setMockInitialValues({});
      final store = PvCatalogStore.instance;
      store.applyStoreRows([row()]);
      expect(store.byId('pva_test_cream'), isNotNull);
      store.applyStoreRows(const []);
      expect(store.byId('pva_test_cream'), isNull, reason: 'archived = gone');
    });
  });

  test('wiring gate: the sheet rows load when the app starts', () {
    expect(
      _read('lib/main.dart'),
      contains('PvCatalogStore.instance.loadFromCloud()'),
    );
    expect(
      _read('lib/services/pv_catalog_store.dart'),
      contains("SupabaseRepo.selectPublicWhere(\n        'products',\n        'domain',\n        'store',"),
    );
  });
}
