// Pee Safe demo, item 6: the recovery kit opens from the brand page, its ticks
// persist on the device, and its sponsoredTool campaign resolves on its own
// placement only.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_context.dart';
import 'package:parentveda/brand/brand_models.dart';
import 'package:parentveda/brand/brand_page_screen.dart';
import 'package:parentveda/brand/brand_store.dart';
import 'package:parentveda/brand/brand_studio.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_brand.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_recovery_kit_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    RecoveryKitTicks.instance.debugUnload();
    BrandStudio.instance.allowInTests = true;
    BrandStudio.instance.enabled = true;
    BrandStudio.instance.resetCampaigns();
    BrandStudioStore.instance.resetAll();
  });

  tearDown(() => BrandStudio.instance.allowInTests = false);

  test('the kit campaign resolves on its own placement and nowhere else', () {
    final ctx = captureBrandContext(stage: BrandStage.parenting);
    final c = BrandStudio.instance.resolve(BrandSlot.sponsoredTool, ctx, placementKey: kPeeSafeKitPlacement);
    expect(c?.id, kPeeSafeKitToolId);
    expect(c?.brand.id, kPeeSafe.id);
    expect(BrandStudio.instance.resolve(BrandSlot.sponsoredTool, ctx, placementKey: 'sleep_journey')?.id,
        isNot(kPeeSafeKitToolId));
  });

  test('every item is generic and every product link resolves', () {
    for (final i in kRecoveryKitItems) {
      expect(i.title.toLowerCase(), isNot(contains('pee safe')), reason: 'the checklist names no brand');
      if (i.productId != null) expect(i.product, isNotNull, reason: '${i.id} -> ${i.productId}');
    }
  });

  testWidgets('opens from the brand page, ticks persist, products come after the list', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: BrandPageScreen(brand: kPeeSafe)));
    await tester.pump();
    final entry = find.byKey(const ValueKey('brand_page_kit'));
    await tester.ensureVisible(entry);
    await tester.pumpAndSettle();
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(find.byType(PeeSafeRecoveryKitScreen), findsOneWidget);
    final route = ModalRoute.of(tester.element(find.byType(PeeSafeRecoveryKitScreen)));
    expect(route?.settings.name, kPeeSafeKitRoute);
    expect(find.text('Presented by Pee Safe'), findsOneWidget);

    // Products sit below the doctor callout, which sits below the last item.
    // The list is lazy, so scroll down first; all three are then built.
    await tester.scrollUntilVisible(find.byKey(const ValueKey('ps_kit_products')), 300,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    final lastItem = tester.getTopLeft(find.byKey(ValueKey('ps_kit_item_${kRecoveryKitItems.last.id}'))).dy;
    final doctor = tester.getTopLeft(find.byKey(const ValueKey('ps_kit_doctor'))).dy;
    final products = tester.getTopLeft(find.byKey(const ValueKey('ps_kit_products'))).dy;
    expect(lastItem < doctor && doctor < products, isTrue);
    expect(find.text('Sponsored', skipOffstage: false), findsWidgets);

    final first = kRecoveryKitItems.first.id;
    await tester.scrollUntilVisible(find.byKey(ValueKey('ps_kit_item_$first')), -300,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('ps_kit_item_$first')));
    await tester.pumpAndSettle();
    expect(find.text('1 of ${kRecoveryKitItems.length} ready', skipOffstage: false), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('pee_safe_recovery_kit_ticks'), [first]);

    // A fresh load (as after an app restart) reads the tick back.
    RecoveryKitTicks.instance.debugUnload();
    expect(RecoveryKitTicks.instance.isTicked(first), isFalse);
    await RecoveryKitTicks.instance.load();
    expect(RecoveryKitTicks.instance.isTicked(first), isTrue);
  });
}
