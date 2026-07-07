// Functional test for the revised Products flow: the Compare Manager caps at
// three same-category products (and blocks a fourth / a cross-category pick),
// and the subcategory brand filter actually filters the grid.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_products_data.dart';
import 'package:parentveda/screens/post_pregnancy/products_compare_screen.dart';
import 'package:parentveda/screens/post_pregnancy/products_discovery_screen.dart';
import 'package:parentveda/screens/post_pregnancy/products_subcategory_screen.dart';

void main() {
  setUp(() => PpCompareStore.instance.clear());

  Future<void> pumpPhone(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: child));
    await tester.pump();
  }

  testWidgets('Compare ticks products and caps at three', (tester) async {
    await pumpPhone(tester, const ProductsSubcategoryScreen()); // Sleep · Soothers (4 items, same category)

    // Tick three. Each ticked card relabels to "Added", so always tap the first
    // remaining "Compare" chip.
    for (var i = 0; i < 3; i++) {
      final labels = find.text('Compare');
      await tester.ensureVisible(labels.at(0));
      await tester.pump();
      await tester.tap(labels.at(0));
      await tester.pump();
    }
    expect(PpCompareStore.instance.count, 3);

    // One card is still un-ticked - the list is full. (That a fourth tap is
    // refused is covered by the store unit test below.)
    expect(find.text('Compare'), findsOneWidget);
  });

  test('Compare Manager enforces same-category and a max of three', () {
    final store = PpCompareStore.instance..clear();

    expect(store.toggle(productById('dozy')), PpCompareResult.added); // Sleep
    expect(store.toggle(productById('lull')), PpCompareResult.added); // Sleep
    expect(store.category, 'Sleep');

    // a different category is refused (not silently added)
    expect(store.toggle(productById('lotion')), PpCompareResult.wrongCategory); // Skincare
    expect(store.count, 2);

    expect(store.toggle(productById('hush')), PpCompareResult.added); // 3rd Sleep
    expect(store.isFull, true);

    // a fourth (even same-category) is refused
    expect(store.toggle(productById('cloudtunes')), PpCompareResult.full);
    expect(store.count, 3);

    // suggestions are same-category and exclude what's already picked
    store
      ..clear()
      ..toggle(productById('dozy'));
    final sug = store.suggestions();
    expect(sug.every((p) => p.category == 'Sleep'), true);
    expect(sug.any((p) => p.id == 'dozy'), false);

    store.clear();
  });

  testWidgets('Brand filter narrows the grid', (tester) async {
    await pumpPhone(tester, const ProductsSubcategoryScreen());

    expect(find.text('CloudTunes Soother'), findsOneWidget);
    expect(find.text('Dozy White-Noise Soother'), findsOneWidget);

    await tester.tap(find.text('Dozy')); // brand chip
    await tester.pump();

    expect(find.text('Dozy White-Noise Soother'), findsOneWidget);
    expect(find.text('CloudTunes Soother'), findsNothing); // filtered out
  });

  testWidgets('Compare screen is dynamic - reflects the two picked products', (tester) async {
    PpCompareStore.instance
      ..toggle(productById('hush'))
      ..toggle(productById('lull'));

    await pumpPhone(tester, const ProductsCompareScreen());

    // both selected products render in the overview (the "Before you compare"
    // education section now sits above it, so scroll it into view first)
    await tester.scrollUntilVisible(
      find.text('Hush Mini Sound Machine'),
      200,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 20,
    );
    expect(find.text('Hush Mini Sound Machine'), findsWidgets);
    expect(find.text('Lull Portable Soother'), findsWidgets);

    // a differentiated, product-specific "worth knowing" point for Hush lives
    // further down in its own take card - scroll it into view
    await tester.scrollUntilVisible(
      find.textContaining('No auto-off timer'),
      300,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 20,
    );
    expect(find.textContaining('No auto-off timer'), findsOneWidget);
  });

  testWidgets('Filters button opens a sheet and narrows the home to a concern', (tester) async {
    await pumpPhone(tester, const ProductsDiscoveryScreen());

    // browse mode by default
    expect(find.text('Shop by category'), findsOneWidget);

    // open the filter sheet and pick a concern
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Poor sleep'));
    await tester.pump();

    // apply
    await tester.tap(find.textContaining('Show '));
    await tester.pumpAndSettle();

    // now in results mode: Sleep products show, Skincare products are filtered out
    expect(find.text('Shop by category'), findsNothing);
    expect(find.text('Dozy White-Noise Soother'), findsWidgets);
    expect(find.text('Soothe Baby Lotion'), findsNothing);
  });
}
