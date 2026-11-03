// Pee Safe demo, item 7: product placements. Each placement resolves on its own
// key and nowhere else, there is exactly one featured pick, and that pick obeys
// the rank floor with its rating untouched.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_campaigns.dart';
import 'package:parentveda/brand/brand_context.dart';
import 'package:parentveda/brand/brand_models.dart';
import 'package:parentveda/brand/brand_store.dart';
import 'package:parentveda/brand/brand_studio.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_brand.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_collab.dart';
import 'package:parentveda/brand/rank_floor.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reco_data.dart';
import 'package:parentveda/screens/post_pregnancy/reco_collection_screen.dart';

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

  test('each placement resolves on its own key, as its own campaign', () {
    final ids = <String>{};
    for (final p in PeeSafePlacement.values) {
      final c = p.resolve();
      expect(c, isNotNull, reason: '${p.name} did not resolve');
      expect(c!.id, p.campaignId);
      expect(c.placementKey, p.key);
      expect(c.brand.id, kPeeSafe.id);
      ids.add(c.id);
      expect(p.products, isNotEmpty, reason: '${p.name} has no products');
      // Nowhere else: no other placement's key reaches this campaign.
      for (final other in PeeSafePlacement.values.where((o) => o.slot == p.slot && o != p)) {
        expect(BrandStudio.instance.resolve(p.slot, captureBrandContext(stage: p.stage), placementKey: other.key)?.id,
            isNot(p.campaignId));
      }
    }
    expect(ids.length, PeeSafePlacement.values.length, reason: 'two placements share a campaign');
    expect({for (final p in PeeSafePlacement.values) p.key}.length, PeeSafePlacement.values.length);
  });

  test('only one featured pick exists, and it is Pee Safe\'s', () {
    final featured = kBrandCampaigns.where((c) => c.slot == BrandSlot.recoFeatured).toList();
    expect(featured, hasLength(1));
    expect(featured.single.id, kPeeSafeFeaturedId);
    expect(featuredRecoId(), kPeeSafeFeaturedKey);
  });

  test('the featured pick respects the rank floor and keeps its rating', () {
    final item = kReco.firstWhere((r) => r.id == kPeeSafeFeaturedKey);
    expect(item.pvRating, 4.5, reason: 'a sponsored placement changed a rating');
    expect(clearsQualityFloor(item.pvRating), isTrue);

    final today = recommendedToday();
    final at = today.indexWhere((r) => r.id == kPeeSafeFeaturedKey);
    expect(at, greaterThan(0), reason: 'never slot 0, and it must be in the feed');
    expect(today.where((r) => r.id == kPeeSafeFeaturedKey), hasLength(1));
  });

  testWidgets('the After Birth Care collection shows products after its picks', (tester) async {
    final col = kRecoCollections.firstWhere((c) => c.id == kPeeSafeCollectionKey);
    expect(col.items, isNotEmpty);
    await tester.pumpWidget(MaterialApp(home: RecoCollectionScreen(collection: col)));
    await tester.pump();
    final shelf = find.byKey(const ValueKey('ps_collab_afterBirthCollection'), skipOffstage: false);
    expect(shelf, findsOneWidget);
    expect(find.byType(PeeSafeCollabLockup, skipOffstage: false), findsOneWidget);
    // Two disclosures: the header chip (PresentedBy) and the shelf's own label.
    expect(find.text('Presented by Pee Safe', skipOffstage: false), findsNWidgets(2));
    // Products come after the picks: the shelf sits below the last pick.
    final lastPick = find.text(col.items.last.title, skipOffstage: false);
    await tester.dragUntilVisible(shelf, find.byType(Scrollable).first, const Offset(0, -300));
    expect(tester.getTopLeft(shelf).dy, greaterThan(tester.getTopLeft(lastPick).dy));
  });
}
