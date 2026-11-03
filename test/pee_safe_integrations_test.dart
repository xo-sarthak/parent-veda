// Pee Safe demo, the second pass (2026-11-03): the recovery kit in Tools,
// sponsored notes in Messages, and the Brand Studio's Pee Safe hero on the
// app's one look (no old purple).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_inbox.dart';
import 'package:parentveda/brand/brand_notifications.dart';
import 'package:parentveda/brand/brand_store.dart';
import 'package:parentveda/brand/brand_studio.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_brand.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_recovery_kit_screen.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_showcase_screen.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_store.dart';
import 'package:parentveda/data/products/pv_catalog_adapters.dart';
import 'package:parentveda/screens/brand_showcase_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';

String _src(String p) => File(p).readAsStringSync();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    BrandStudio.instance.allowInTests = true;
    BrandStudio.instance.enabled = true;
    BrandStudio.instance.resetCampaigns();
    BrandStudioStore.instance.resetAll();
    await BrandInbox.instance.reset();
  });

  tearDown(() {
    BrandStudioStore.instance.resetAll();
    BrandStudio.instance.demoMode = false;
    BrandStudio.instance.allowInTests = false;
  });

  group('the recovery kit is a tool', () {
    test('listed in Pregnancy and Parenting Tools, and found by search', () {
      expect(_src('lib/screens/tools_hub_screen.dart'), contains("_Tool('Recovery kit'"));
      expect(_src('lib/screens/post_pregnancy/pp_tools_tab.dart'), contains("'pp_recovery_kit'"));
      expect(_src('lib/screens/global_search.dart'), contains("_Dest('Recovery kit'"));
      expect(ppScreenForSurface('pp_recovery_kit'), isA<PeeSafeRecoveryKitScreen>());
    });

    test('TTC keeps tools only: the hygiene card stays withdrawn', () {
      expect(_src('lib/screens/ttc/ttc_tools_screen.dart'), isNot(contains("\n        TtcTool(\n          id: 'ps_hygiene'")));
    });
  });

  group('a sent note is in Messages, in ParentVeda\'s voice', () {
    test('a demo send is recorded, and Reset demo clears it', () async {
      BrandStudio.instance.demoMode = true;
      final id = kPeeSafeNotificationIds.first;
      expect(await BrandNotifications.instance.sendNow(id), isNotNull);
      expect(BrandInbox.instance.entries().map((e) => e.campaignId), [id]);
      await resetPeeSafeDemo();
      expect(BrandInbox.instance.entries(), isEmpty);
    });

    testWidgets('the row: the headline, then "With Pee Safe · Sponsored"', (tester) async {
      final id = kPeeSafeNotificationIds.first;
      await BrandInbox.instance.add(id, DateTime.now());
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: BrandInboxRows(p: V2PaletteStore.instance.current)),
      ));
      await tester.pump();
      expect(find.byKey(ValueKey('brand_inbox_$id')), findsOneWidget);
      expect(find.textContaining('With Pee Safe · Sponsored'), findsOneWidget);
    });

    test('all three Messages screens place the rows', () {
      for (final f in const [
        'lib/screens/post_pregnancy/pp_messages_screen.dart',
        'lib/screens/pregnancy/preg_messages_screen.dart',
        'lib/screens/ttc/ttc_messages_screen.dart',
      ]) {
        expect(_src(f), contains('BrandInboxRows('), reason: f);
      }
    });

    test('ParentVeda speaks; the partner is the disclosure', () {
      final n = _src('lib/brand/brand_notifications.dart');
      expect(n, contains(r"'$line\n\nWith ${c.brand.name} · Sponsored'"));
    });
  });

  group('the Brand Studio', () {
    testWidgets('opens on the Pee Safe hero, with the logo and both ways in', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: BrandShowcaseScreen()));
      await tester.pump();
      expect(find.byKey(const ValueKey('bs_pee_safe_hero')), findsOneWidget);
      expect(find.byKey(const ValueKey('bs_pee_safe_walk')), findsOneWidget);
      expect(find.byKey(const ValueKey('bs_pee_safe_page')), findsOneWidget);
      expect(find.byKey(const ValueKey('bs_pee_safe_chip')), findsWidgets);
    });

    test('no old purple left in the tour', () {
      final s = _src('lib/screens/brand_showcase_screen.dart');
      expect(s, isNot(contains('\nconst _purple = Color(0xFF6A30B6);')));
      expect(s, contains('const _purple = kPvInk;'));
    });
  });

  test('no Pee Safe surface says "coming soon"', () {
    final page = _src('lib/brand/brand_page_screen.dart');
    expect(page, isNot(contains("\n        _invitation(Icons.inventory_2_outlined, 'Products coming soon'")));
    expect(page, isNot(contains("child: Text('Film coming soon'")));
    expect(kPeeSafeDemo, isTrue);
  });

  group('on the live screens, not the retired ones', () {
    test('the store: 15 rows on real shelves, labelled, unrated, after our picks', () {
      final cat = buildPvCatalog();
      final shelves = {for (final c in buildPvCategories()) c.id: c};
      // The demo's rows (ps_ ids). The team's sheet already lists two Pee Safe
      // products as ParentVeda's own picks, unsponsored; they stay as they are.
      final ps = [for (final p in cat) if (p.id.startsWith('ps_')) p];
      expect(ps.length, peeSafeStoreProducts().length);
      expect(ps.length, 15);
      for (final p in ps) {
        expect(shelves[p.categoryId], isNotNull, reason: '${p.id} on a shelf that exists');
        final sub = p.subId;
        if (sub != null) {
          expect(shelves[p.categoryId]!.subs.map((s) => s.id), contains(sub), reason: p.id);
        }
        expect(p.badge, kPeeSafeStoreBadge, reason: p.id);
        expect(p.rating, 0, reason: 'no rating of ours: ${p.id}');
        expect(p.reviews, isEmpty, reason: p.id);
        expect(p.images.single, startsWith('assets/brand/pee_safe/'), reason: p.id);
        expect(File(p.images.single).existsSync(), isTrue, reason: p.images.single);
        expect(p.buyUrl, startsWith('https://www.peesafe.com/products/'), reason: p.id);
      }
      expect(cat.map((p) => p.id).toSet().length, cat.length, reason: 'ids stay unique');
      // After ParentVeda's own picks on each shelf: never first.
      for (final c in {for (final p in ps) p.categoryId}) {
        final shelf = [for (final p in cat) if (p.categoryId == c) p];
        if (shelf.any((p) => !p.id.startsWith('ps_'))) {
          expect(shelf.first.id, isNot(startsWith('ps_')), reason: c);
        }
      }
      expect(ps.where((p) => p.stage.name == 'tryingToConceive'), isEmpty, reason: 'not in TTC');
    });

    test('the bag rows are on the live bag, and the taps go there', () {
      expect(_src('lib/screens/tools/ready_for_birth_screen.dart'), contains('placement: PeeSafePlacement.hospitalBag'));
      final n = _src('lib/brand/pee_safe/pee_safe_notifications.dart');
      expect(n, contains('builder: (_) => ReadyForBirthScreen(controller: preg)'));
      final show = _src('lib/brand/pee_safe/pee_safe_showcase_screen.dart');
      expect(show, contains("_push(ReadyForBirthScreen(controller: preg), 'tools/hospital_bag')"));
      expect(show, isNot(contains("\n                  _push(const RecommendationsScreen()")));
    });

    test('parenting app-open moments run on the shell both homes sit in', () {
      final shell = _src('lib/screens/post_pregnancy/pp_home_version.dart');
      expect(shell, contains('const _PpOpenMoments()'));
      expect(shell, contains('showPeeSafePremiereAtOpen(context, stage: BrandStage.parenting)'));
      expect(shell, contains('BrandNotifications.instance.maybeSend(stage: BrandStage.parenting)'));
      // And not twice: the V1 home's copies are kept for revert only.
      final v1 = _src('lib/screens/post_pregnancy/my_child_screen.dart');
      expect(v1, isNot(contains('\n        BrandNotifications.instance.maybeSend(stage: BrandStage.parenting);')));
    });

    test('no purple ink or lavender ground left on Pee Safe surfaces', () {
      for (final f in const [
        'lib/brand/pee_safe/pee_safe_collab.dart',
        'lib/brand/pee_safe/pee_safe_reads.dart',
        'lib/brand/pee_safe/pee_safe_recovery_kit_screen.dart',
        'lib/brand/pee_safe/pee_safe_showcase_screen.dart',
        'lib/brand/launch_hub_screen.dart',
      ]) {
        final live = _src(f).split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
        for (final c in const ['const Color _ink = Color(0xFF2D144C)', 'const Color _bg = Color(0xFFFBF9FE)', 'const _bg = Color(0xFFFBF9FE)']) {
          expect(live, isNot(contains(c)), reason: '$f: $c');
        }
      }
    });
  });
}
