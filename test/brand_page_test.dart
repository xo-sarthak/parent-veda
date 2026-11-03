// Pee Safe demo, item 4: the brand page renders for kPeeSafe and is reachable.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_page_screen.dart';
import 'package:parentveda/brand/brand_store.dart';
import 'package:parentveda/brand/brand_studio.dart';
import 'package:parentveda/brand/launch_hub_screen.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_brand.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_products.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    BrandStudio.instance.allowInTests = true;
    BrandStudio.instance.enabled = true;
    BrandStudio.instance.resetCampaigns();
    BrandStudioStore.instance.resetAll();
  });

  tearDown(() => BrandStudio.instance.allowInTests = false);

  testWidgets('the brand page renders for Pee Safe with disclosure, store, story and products', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    final launch = brandLaunchFor(kPeeSafe);
    expect(launch?.id, kPeeSafeLaunchId, reason: 'the page takes its story from the Pee Safe launch');

    await tester.pumpWidget(const MaterialApp(home: BrandPageScreen(brand: kPeeSafe)));
    await tester.pump();

    expect(find.text('Pee Safe'), findsWidgets);
    expect(find.text('ParentVeda partner'), findsOneWidget);
    expect(find.text('PRESENTED BY PEE SAFE'), findsOneWidget);
    expect(find.text('Visit Pee Safe store'), findsOneWidget);
    expect(find.text(launch!.independenceNote), findsOneWidget);

    // Every moment that has a product is offered, and filtering narrows the grid.
    // ensureVisible scrolls every enclosing scrollable (the page and the
    // moment strip), so no drag can land on the wrong one.
    await tester.ensureVisible(find.text('After birth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('After birth'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('${peeSafeFor(PeeSafeMoment.postpartum).length} products'), findsOneWidget);
    await tester.ensureVisible(find.text(peeSafeFor(PeeSafeMoment.postpartum).first.name));
    await tester.pumpAndSettle();
    expect(find.text('Buy'), findsWidgets);

    // Item 5 filled the shelf: no invitation, the reads instead.
    await tester.ensureVisible(find.text('READ WITH PEE SAFE'));
    await tester.pumpAndSettle();
    expect(find.text('Guides are on their way'), findsNothing);
    expect(find.text('Discharge in pregnancy'), findsOneWidget);
  });

  testWidgets('the launch opens the brand page under its route name', (tester) async {
    final launch = brandLaunchFor(kPeeSafe)!;
    final seen = <String?>[];
    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [_Names(seen)],
      home: LaunchDetailScreen(campaign: launch),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('launch_brand_link')));
    await tester.pumpAndSettle();

    expect(find.byType(BrandPageScreen), findsOneWidget);
    expect(seen.last, kBrandPageRoute);
  });

  test('the brand page has a call site (wiring gate)', () {
    final src = File('lib/brand/launch_hub_screen.dart').readAsStringSync();
    expect(src, contains('BrandPageScreen.route('));
  });

  test('the story splits around its photo', () {
    expect(splitStory('One. Two. Three. Four.'), ('One. Two.', 'Three. Four.'));
    expect(splitStory('Only one.'), ('Only one.', ''));
    expect(splitStory('A.\n\nB.'), ('A.', 'B.'));
  });
}

class _Names extends NavigatorObserver {
  _Names(this.seen);
  final List<String?> seen;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => seen.add(route.settings.name);
}
