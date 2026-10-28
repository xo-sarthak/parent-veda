// =============================================================================
//  Named product lists (store Track A, 2026-10-28) — PvListStore + wiring
// -----------------------------------------------------------------------------
//  The user: "name your own wish list like Amazon does". Lists are separate
//  from the heart; the wishlist's All shows both; a list name is unique; and
//  the same "Save to a list" action is on every product page.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/pv_list_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PvListStore.instance.resetForTest();
    await PvListStore.instance.init();
  });

  test('make, fill, rename, delete', () {
    final s = PvListStore.instance;
    final bag = s.create('  Hospital   bag ', firstProductId: 'p1')!;
    expect(bag.name, 'Hospital bag');
    expect(s.contains(bag.id, 'p1'), isTrue);

    expect(s.toggle(bag.id, 'p2'), isTrue);
    expect(s.toggle(bag.id, 'p1'), isFalse, reason: 'second tap takes it out');
    expect(s.byId(bag.id)!.productIds, ['p2']);

    final room = s.create("Baby's room")!;
    s.toggle(room.id, 'p2');
    expect(s.listsWith('p2').length, 2);
    expect(s.allProductIds, ['p2'], reason: 'once, however many lists');

    expect(s.rename(room.id, 'Nursery'), isTrue);
    expect(s.byId(room.id)!.name, 'Nursery');
    s.delete(room.id);
    expect(s.byId(room.id), isNull);
  });

  test('a blank or repeated name is refused', () {
    final s = PvListStore.instance;
    expect(s.create('   '), isNull);
    final a = s.create('Gifts')!;
    expect(s.create('gifts'), isNull, reason: 'names tell lists apart');
    final b = s.create('Other')!;
    expect(s.rename(b.id, 'GIFTS'), isFalse);
    expect(s.rename(a.id, 'Gifts'), isTrue, reason: 'its own name is fine');
  });

  test('lists survive a restart', () async {
    final s = PvListStore.instance;
    final l = s.create('Hospital bag', firstProductId: 'p9')!;
    await Future<void>.delayed(Duration.zero);
    s.resetForTest();
    await s.init();
    expect(s.byId(l.id)!.productIds, ['p9']);
  });

  group('wiring gate', () {
    test('every product page offers Save to a list', () {
      final src = _read('lib/screens/products/pv_product_screen.dart');
      expect(src, contains('showPvAddToListSheet(context, product)'));
    });
    test('the wishlist shows the lists, and All includes them', () {
      final src = _read('lib/screens/products/pv_wishlist_screen.dart');
      expect(src, contains('_chips(lists, picked)'));
      expect(src, contains('...PvListStore.instance.allProductIds'));
      expect(src, contains('showPvEditListSheet(context, picked)'));
    });
    test('the store starts with the app', () {
      expect(_read('lib/main.dart'), contains('PvListStore.instance.init()'));
    });
    test('an affiliate product has no cart button', () {
      final src = _read('lib/screens/products/pv_product_screen.dart');
      // The affiliate branch of the commit bar opens the retailer only.
      final i = src.indexOf('} else if (product.canBuy) {');
      final j = src.indexOf('} else {', i);
      final branch = src.substring(i, j);
      expect(branch, contains('_buyAffiliate(product)'));
      expect(branch.contains('_addToCart'), isFalse);
    });
  });
}
