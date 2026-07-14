// Smoke tests for the ParentVeda Product Guide: the hub lists guides, a guide
// page shows the decision hero + deep-dive, and the "which view?" chooser fires
// only for products that have a guide.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/product_guide/product_guide_chooser.dart';
import 'package:parentveda/screens/product_guide/product_guide_data.dart';
import 'package:parentveda/screens/product_guide/product_guide_hub_screen.dart';
import 'package:parentveda/screens/product_guide/product_guide_screen.dart';

void main() {
  void bigView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('Hub lists guides and opens one', (tester) async {
    bigView(tester);
    await tester.pumpWidget(const MaterialApp(home: ProductGuideHubScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Baby skincare'), findsWidgets);
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Fragrance-Free Baby Lotion'), 200, scrollable: scrollable, maxScrolls: 20);
    await tester.tap(find.text('Fragrance-Free Baby Lotion').first);
    await tester.pumpAndSettle();
    final guideScroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('BEFORE YOU BUY'), 250, scrollable: guideScroll, maxScrolls: 30);
    expect(find.text('BEFORE YOU BUY'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Why we like it'), 250, scrollable: guideScroll, maxScrolls: 30);
    expect(find.text('Why we like it'), findsOneWidget);
  });

  testWidgets('A guide page shows the decision hero and deep-dive', (tester) async {
    bigView(tester);
    await tester.pumpWidget(MaterialApp(home: ProductGuideScreen(guide: pgById('baby_lotion')!)));
    await tester.pumpAndSettle();

    expect(find.text('Highly recommended'), findsOneWidget);
    expect(find.text('BEST FOR'), findsOneWidget);
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Ingredients explained'), 250, scrollable: scrollable, maxScrolls: 30);
    expect(find.text('Ingredients explained'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Specifications'), 250, scrollable: scrollable, maxScrolls: 30);
    expect(find.text('Specifications'), findsOneWidget);
  });

  testWidgets('The chooser fires only for a product that has a guide', (tester) async {
    bigView(tester);
    var openedNormal = false;
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (c) {
      ctx = c;
      return const SizedBox.shrink();
    }))));

    // A matching name → the chooser sheet appears.
    openProductWithGuideCheck(ctx, name: 'A gentle baby lotion', onOpenNormal: () => openedNormal = true);
    await tester.pumpAndSettle();
    expect(find.text('How would you like to see this?'), findsOneWidget);
    expect(find.text('ParentVeda Product Guide'), findsWidgets);
    expect(openedNormal, isFalse);

    // Dismiss, then a non-matching product → straight to normal, no sheet.
    await tester.tapAt(const Offset(20, 20)); // tap scrim to dismiss
    await tester.pumpAndSettle();
    openProductWithGuideCheck(ctx, name: 'Random gadget 9000', onOpenNormal: () => openedNormal = true);
    await tester.pumpAndSettle();
    expect(openedNormal, isTrue);
    expect(find.text('How would you like to see this?'), findsNothing);
  });
}
