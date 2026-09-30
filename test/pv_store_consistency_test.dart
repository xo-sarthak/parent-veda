// =============================================================================
//  The store, made one app with the rest (2026-09-29)
// -----------------------------------------------------------------------------
//  Holds the five points of the store pass:
//    1. Shop by need rows wear DRAWN marks, never a Material icon as row art.
//    2. The store top is Cart and Wishlist only; orders and bookings stay
//       reachable elsewhere (profile / More), and checkout points to orders.
//    3. The Bookings page: upcoming cards with who, when and Join, a folded
//       past, and an honest empty state.
//    4. One button ink (0xFF2F2C30), no violet, no tinted slab behind text.
//    5. The product page: pack size, short sections, a safety note, one
//       primary in the sticky bar, related products last.
//  and that none of the store's screens overflows at 360dp and 1.5x text.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/booking/booking_store.dart';
import 'package:parentveda/models/pv_product.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/learn/pv_learn_chrome.dart' show pvLearnInitials;
import 'package:parentveda/screens/learn/pv_my_learning_screen.dart';
import 'package:parentveda/screens/products/pv_cart_screen.dart';
import 'package:parentveda/screens/products/pv_checkout_screen.dart';
import 'package:parentveda/screens/products/pv_order_placed_screen.dart';
import 'package:parentveda/screens/products/pv_product_screen.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart';
import 'package:parentveda/screens/products/pv_store_marks.dart';
import 'package:parentveda/screens/products/pv_store_screen.dart';
import 'package:parentveda/screens/products/pv_wishlist_screen.dart';
import 'package:parentveda/services/cart_store.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_catalog_store.dart';
import 'package:parentveda/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _read(String p) => File(p).readAsStringSync().replaceAll('\r\n', '\n');

/// The code lines of a file: comments dropped, so a kept-for-revert note
/// never counts as live code.
String _code(String p) => _read(p)
    .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

List<File> _storeFiles() => [
  for (final e in Directory('lib/screens/products').listSync())
    if (e is File && e.path.endsWith('.dart')) e,
];

Future<void> _pump(
  WidgetTester tester,
  Widget w, {
  double width = 390,
  double height = 2600,
  double scale = 1,
  String? route,
}) async {
  tester.view.physicalSize = Size(width * 2, height * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      onGenerateRoute: (s) => MaterialPageRoute<void>(
        settings: RouteSettings(name: route ?? s.name),
        builder: (c) => MediaQuery(
          data: MediaQuery.of(c).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: w,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

/// Two upcoming bookings (one in its Join window, one in three days) and a
/// cancelled one in the past, on a TTC consult with a named expert.
({Booking soon, Booking later}) _seedBookings() {
  final store = BookingStore.instance..resetAll();
  final o = BookingCatalog.instance
      .offerings(stage: ServiceStage.tryingToConceive)
      .firstWhere(
        (o) =>
            o.kind == OfferingKind.consult &&
            PvLearnCatalog.instance.byOfferingId(o.id) != null,
      );
  for (var i = 0; i < 3; i++) {
    store.purchase(o);
  }
  final now = DateTime.now().toUtc();
  Slot s(String id, Duration d) => Slot(
    id: id,
    offeringId: o.id,
    expertId: o.expertId,
    startsUtc: now.add(d),
    durationMin: 30,
    capacity: 1,
    booked: 0,
  );
  final soon = store.book(s('t_soon', const Duration(minutes: 5)))!;
  final later = store.book(s('t_later', const Duration(days: 3)))!;
  final past = store.book(s('t_past', const Duration(days: -4)))!;
  store.cancel(past.id);
  return (soon: soon, later: later);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  tearDown(BookingStore.instance.resetAll);

  // ===========================================================================
  group('1. shop by need draws marks', () {
    testWidgets('every need row has a drawn mark and no Material icon art', (
      tester,
    ) async {
      await _pump(
        tester,
        const PvStoreScreen(
          chrome: PvStoreChrome.none,
          initialStage: LifeStage.tryingToConceive,
        ),
      );
      final rows = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('pv_store_need_') &&
            !(w.key! as ValueKey<String>).value.startsWith(
              'pv_store_need_mark_',
            ),
      );
      expect(rows, findsNWidgets(5));
      for (final e in rows.evaluate()) {
        final row = find.byWidget(e.widget);
        expect(
          find.descendant(of: row, matching: find.byType(PvStoreArt)),
          findsOneWidget,
          reason: 'a need row without its drawn mark',
        );
        // The only line icon left in a row is its chevron (a control).
        for (final i in tester.widgetList<Icon>(
          find.descendant(of: row, matching: find.byType(Icon)),
        )) {
          expect(
            i.icon,
            Icons.chevron_right_rounded,
            reason: 'a Material icon as row art: ${i.icon}',
          );
        }
      }
    });

    test('five needs, five different marks, one tint', () {
      final src = _code('lib/screens/products/pv_store_screen.dart');
      for (final m in PvStoreMark.values) {
        expect(src, contains('PvStoreMark.${m.name}'));
      }
      expect(src, contains('v2BlockTint(kPvStoreMarkHue, p)'));
    });
  });

  // ===========================================================================
  group('2. the store top: cart and wishlist only', () {
    test('no Orders or Bookings entry is live on the store top', () {
      final src = _code('lib/screens/products/pv_store_screen.dart');
      expect(src, isNot(contains('Icons.receipt_long_outlined')));
      expect(src, isNot(contains('PvMyLearningScreen')));
      expect(src, isNot(contains('MyBookingsScreen')));
      expect(src, isNot(contains("semanticLabel: 'Orders'")));
      expect(src, contains("semanticLabel: 'Cart'"));
      expect(src, contains("semanticLabel: 'Wishlist'"));
      // The pregnancy/parenting header keeps both too.
      expect(src, contains('onTap: _openWishlist'));
      expect(src, contains('onTap: _openCart'));
    });

    testWidgets('the storefront draws no orders circle', (tester) async {
      await _pump(
        tester,
        const PvStoreScreen(
          chrome: PvStoreChrome.none,
          initialStage: LifeStage.tryingToConceive,
        ),
      );
      expect(find.byIcon(Icons.receipt_long_outlined), findsNothing);
      expect(find.text('Bookings'), findsNothing);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
    });

    test('orders and bookings stay reachable, off the store', () {
      // Wherever the profile / More split puts them, some TTC or profile
      // screen opens both, under their load-bearing route names.
      final homes = [
        for (final d in ['lib/screens/ttc', 'lib/screens/profile'])
          for (final e in Directory(d).listSync())
            if (e is File && e.path.endsWith('.dart')) _code(e.path),
      ].join('\n');
      expect(homes, contains('PvOrdersScreen('));
      expect(homes, contains("'store/orders'"));
      expect(
        homes.contains('PvMyLearningScreen(') ||
            homes.contains('MyBookingsScreen('),
        isTrue,
        reason: 'nothing outside the store opens Bookings',
      );
      expect(homes, contains("'bookings'"));
      // And the moment after buying points to the orders.
      final placed = _code('lib/screens/products/pv_order_placed_screen.dart');
      expect(placed, contains("'See your orders'"));
      expect(placed, contains("RouteSettings(name: 'store/orders')"));
    });
  });

  // ===========================================================================
  group('3. the Bookings page', () {
    testWidgets('upcoming cards: who, when, one Join live in its window', (
      tester,
    ) async {
      final seeded = _seedBookings();
      await _pump(tester, const PvMyLearningScreen(), route: 'bookings');
      expect(find.text('Your bookings'), findsOneWidget);
      expect(find.byType(PvBookingCard), findsNWidgets(2));
      final v = PvLearnCatalog.instance.byOfferingId(seeded.soon.offeringId)!;
      expect(find.text(v.expert.name), findsNWidgets(2));
      // The monogram, never a photo.
      expect(find.text(pvLearnInitials(v.expert.name)), findsNWidgets(2));
      final soonJoin = tester.widget<PvCommit>(
        find.byKey(ValueKey('pv_booking_join_${seeded.soon.id}')),
      );
      expect(soonJoin.label, 'Join video call');
      expect(soonJoin.onTap, isNotNull);
      final laterJoin = tester.widget<PvCommit>(
        find.byKey(ValueKey('pv_booking_join_${seeded.later.id}')),
      );
      expect(laterJoin.onTap, isNull, reason: 'Join is live only near the time');
      expect(laterJoin.label, startsWith('Join from '));
      expect(
        find.byKey(ValueKey('pv_booking_cancel_${seeded.soon.id}')),
        findsOneWidget,
      );
    });

    testWidgets('past bookings are folded until opened', (tester) async {
      _seedBookings();
      await _pump(tester, const PvMyLearningScreen(), route: 'bookings');
      expect(find.text('Past bookings · 1'), findsOneWidget);
      expect(find.byKey(const ValueKey('pv_bookings_past_list')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('pv_bookings_past_fold')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('pv_bookings_past_list')),
        findsOneWidget,
      );
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('nothing booked: an honest empty state with a way to book', (
      tester,
    ) async {
      BookingStore.instance.resetAll();
      await _pump(tester, const PvMyLearningScreen(), route: 'bookings');
      expect(find.text('Nothing booked yet.'), findsOneWidget);
      expect(find.byKey(const ValueKey('pv_bookings_find')), findsOneWidget);
      expect(find.byType(PvBookingCard), findsNothing);
    });

    testWidgets('from the Learn bookmark it keeps its old title', (
      tester,
    ) async {
      await _pump(tester, const PvMyLearningScreen(), route: 'learn/mine');
      expect(find.text('Your learning'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('4. one ink, no violet, no slab', () {
    test('the ink is the switches\' black', () {
      expect(kPvInk, AppTheme.neutral900);
      expect(kPvInk, const Color(0xFF2F2C30));
    });

    testWidgets('a primary store button fills with the ink, white text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PvCommit(label: 'Add to cart', onTap: () {}),
          ),
        ),
      );
      final box = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PvCommit),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((box.decoration! as BoxDecoration).color, kPvInk);
      final t = tester.widget<Text>(find.text('Add to cart'));
      expect(t.style?.color, Colors.white);
    });

    test('store files: no other button kind, no violet, no slab', () {
      for (final f in _storeFiles()) {
        final src = _code(f.path);
        final name = f.path.replaceAll(r'\', '/');
        for (final bad in [
          'ElevatedButton',
          'FilledButton',
          'p.action',
          'pal.action',
          'v2BlockTint(268',
        ]) {
          expect(src.contains(bad), isFalse, reason: '$name uses $bad');
        }
        // PvWell is the lavender slab; only its own definition may remain.
        if (!name.endsWith('pv_store_chrome.dart')) {
          expect(
            src.contains('PvWell('),
            isFalse,
            reason: '$name draws text on a tinted slab (PvWell)',
          );
        }
      }
    });
  });

  // ===========================================================================
  group('5. the product page', () {
    PvProduct soldHere() => PvCatalogStore.instance.all.firstWhere(
      (p) => p.soldHere && !p.reviewOnly && p.variants.isEmpty,
    );

    testWidgets('sticky bar: the price and ONE primary, Add then Go to cart', (
      tester,
    ) async {
      CartStore.instance.clear(kProductsCartId);
      final prod = soldHere();
      await _pump(tester, PvProductScreen(productId: prod.id), height: 900);
      expect(find.byType(PvCommit), findsOneWidget);
      expect(find.byType(PvSecondary), findsNothing);
      expect(find.byKey(const ValueKey('pv_product_primary')), findsOneWidget);
      expect(find.text('Add to cart'), findsOneWidget);
      await tester.tap(find.text('Add to cart'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Go to cart'), findsOneWidget);
      CartStore.instance.clear(kProductsCartId);
    });

    testWidgets('an affiliate product: one primary to the retailer', (
      tester,
    ) async {
      final prod = PvCatalogStore.instance.byId('ttc_folic')!;
      await _pump(tester, PvProductScreen(productId: prod.id), height: 900);
      expect(find.byType(PvCommit), findsOneWidget);
      expect(find.textContaining('Buy on'), findsOneWidget);
    });

    testWidgets('pack size, short sections, safety note, related last', (
      tester,
    ) async {
      final prod = PvCatalogStore.instance.byId('ttc_folic')!;
      await _pump(tester, PvProductScreen(productId: prod.id), height: 9000);
      expect(find.byKey(const ValueKey('pv_product_pack')), findsOneWidget);
      expect(find.text('Why it helps'), findsOneWidget);
      expect(find.text('How to use'), findsOneWidget);
      expect(find.text('Worth knowing'), findsOneWidget);
      expect(find.text('Safety note'), findsOneWidget);
      // The clinical copy, word for word.
      expect(
        find.textContaining('If your doctor has told you something different'),
        findsOneWidget,
      );
      // Honest ratings: no seed numbers on a TTC product.
      expect(find.textContaining('No parent ratings yet'), findsOneWidget);
      final safety = tester.getRect(
        find.byKey(const ValueKey('pv_product_safety')),
      );
      final compare = tester.getRect(find.text('Compare with similar'));
      expect(compare.top, greaterThan(safety.bottom),
          reason: 'related products come last');
    });

    test('pack size is derived, never guessed', () {
      final folic = PvCatalogStore.instance.byId('ttc_folic')!;
      expect(pvPackSize(folic), folic.variants.first.label);
      final strips = PvCatalogStore.instance.byId('ttc_lh_strips')!;
      expect(pvPackSize(strips), '25 strips');
    });
  });

  // ===========================================================================
  group('no overflow at 360dp and 1.5x', () {
    final screens = <String, (Widget, String?)>{
      'store': (
        const PvStoreScreen(
          chrome: PvStoreChrome.none,
          initialStage: LifeStage.tryingToConceive,
        ),
        null,
      ),
      'product': (const PvProductScreen(productId: 'ttc_folic'), null),
      'cart': (const PvCartScreen(), null),
      'wishlist': (
        const PvWishlistScreen(stage: LifeStage.tryingToConceive),
        null,
      ),
      'checkout': (const PvCheckoutScreen(), null),
      'bookings': (const PvMyLearningScreen(), 'bookings'),
      'order placed': (const PvOrderPlacedScreen(orderId: 'none'), null),
    };
    for (final e in screens.entries) {
      testWidgets(e.key, (tester) async {
        if (e.key == 'bookings') _seedBookings();
        if (e.key == 'cart' || e.key == 'checkout') {
          final p = PvCatalogStore.instance.byId('ttc_folic')!;
          CartStore.instance.add(
            kProductsCartId,
            productId: p.id,
            name: p.name,
            emoji: '',
            unitPrice: 95,
            size: '30 tablets',
          );
        }
        await _pump(
          tester,
          e.value.$1,
          width: 360,
          height: 780,
          scale: 1.5,
          route: e.value.$2,
        );
        expect(tester.takeException(), isNull);
        CartStore.instance.clear(kProductsCartId);
      });
    }
  });
}
