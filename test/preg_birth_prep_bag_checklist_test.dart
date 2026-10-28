// =============================================================================
//  P4 birth prep: the Hospital bag and the Product checklist (2026-10-28)
// -----------------------------------------------------------------------------
//  docs/preg-ttc-tool-plans/P4-birth-prep.md. What this holds:
//    · H1 the emergency page names the red flags and dials 108, and no longer
//      promises "You have time";
//    · H2 baby lotion is out of the bag (NHS: nothing on newborn skin in the
//      first month), and an old bag drops it unless it is packed;
//    · H3 the season follows the due date's month, not today's;
//    · D4 after a loss the note shows and the Baby category steps aside;
//    · D1 "See it in the store" picks the product page, the store's search or
//      a tagged Amazon search, by one pure rule; the Amazon link is tagged;
//    · P3 the progress count is the Got group's rule (ticked or bought);
//    · P4 the checklist merges per item, and reads the old whole blob once.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/outbound.dart';
import 'package:parentveda/data/hospital_bag_catalog.dart';
import 'package:parentveda/data/hospital_bag_seed.dart';
import 'package:parentveda/data/ready_for_birth_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/tools/ready_for_birth_screen.dart';
import 'package:parentveda/services/hospital_bag_store.dart';
import 'package:parentveda/services/hospital_bag_v2_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/services/product_checklist_store.dart';
import 'package:parentveda/services/ready_birth_context_store.dart';
import 'package:parentveda/services/remote/cloud_merged_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  //  The checklist's per-item sync runs first: the store is a singleton and
  //  reads the old blob only on its first run in the process.
  // ---------------------------------------------------------------------------
  group('P4 the checklist merges per item', () {
    late Map<String, Map<String, dynamic>> server;
    late Map<String, Object?> legacy;
    var clock = 1000000;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      server = {};
      legacy = {};
      CloudMergeIo.isLoggedIn = () => true;
      CloudMergeIo.nowMs = () => clock;
      CloudMergeIo.loadLegacy = (k) async => legacy[k];
      CloudMergeIo.merge = (key, items) async {
        final merged = MergedItems.merge(
          server[key] ?? {},
          items,
          nowMs: clock,
        );
        server[key] = merged;
        return Map<String, dynamic>.from(merged);
      };
    });
    tearDown(CloudMergeIo.restore);

    Future<void> settle() async {
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
    }

    test('the old whole blob is read once, so nothing she made is lost; then '
        'items round-trip and two phones keep both ticks', () async {
      // What the old CloudSyncedStore kept under `product_checklists`.
      legacy['product_checklists'] = [
        {
          'id': 'cl_1',
          'name': 'Mine',
          'items': [
            {
              'id': 'sw_overall',
              'p': 'sw_overall',
              'n': 'From birth',
              'c': true,
            },
            {'id': 'custom_1', 'p': '', 'name': 'Muslin cloths', 'c': false},
          ],
        },
      ];
      final store = ProductChecklistStore.instance;
      await store.init();
      final l = store.byId('cl_1');
      expect(l, isNotNull, reason: 'the old blob became her list');
      expect(l!.name, 'Mine');
      expect([for (final i in l.items) i.id], ['sw_overall', 'custom_1']);
      expect(l.items.first.checked, isTrue);

      // On the server it is now items, one per thing two phones could change.
      final items = server['product_checklists:items']!;
      expect(items['list|cl_1']!['v'], {
        'name': 'Mine',
        'items': ['sw_overall', 'custom_1'],
      });
      expect(items['item|cl_1|sw_overall']!['v']['c'], true);
      expect(items['item|cl_1|custom_1']!['v']['name'], 'Muslin cloths');
      expect(items['order']!['v'], ['cl_1']);

      // Round trip: the live items rebuild the same list.
      final live = {
        for (final e in items.entries)
          if (e.value['d'] != true) e.key: e.value['v'],
      };
      store.applyCloudItems(live);
      expect(store.byId('cl_1')!.items.map((i) => i.id), [
        'sw_overall',
        'custom_1',
      ]);
      expect(store.byId('cl_1')!.items.last.name, 'Muslin cloths');

      // The other phone ticks the custom item; this phone adds a note to the
      // first. Both survive: each is its own item.
      clock += 10;
      items['item|cl_1|custom_1'] = {
        'v': {
          'id': 'custom_1',
          'p': '',
          'name': 'Muslin cloths',
          'link': '',
          'price': '',
          'n': '',
          'c': true,
        },
        't': clock,
      };
      clock += 10;
      store.setNote('cl_1', 'sw_overall', 'Day zero');
      await settle();
      await store.syncMergedFromCloud();
      final mine = store.byId('cl_1')!;
      expect(mine.items.firstWhere((i) => i.id == 'custom_1').checked, isTrue);
      expect(
        mine.items.firstWhere((i) => i.id == 'sw_overall').note,
        'Day zero',
      );

      // A removed list travels as removals, not as "never had it".
      clock += 10;
      store.deleteChecklist('cl_1');
      await settle();
      final after = server['product_checklists:items']!;
      expect(after['list|cl_1']!['d'], true);
      expect(after['item|cl_1|custom_1']!['d'], true);
    });

    test('an item whose list the order does not know still shows, after', () {
      final store = ProductChecklistStore.instance;
      store.applyCloudItems({
        'order': ['a'],
        'list|a': {'name': 'A', 'items': <String>[]},
        'list|b': {
          'name': 'B',
          'items': ['x'],
        },
        'item|b|x': {'id': 'x', 'p': 'nb_overall', 'c': false},
        'item|b|y': {'id': 'y', 'p': 'bp_overall', 'c': false},
        'item|gone|z': {'id': 'z', 'p': 'sw_overall', 'c': false},
      });
      // Newest first on screen, so b (unknown to the order) reads first.
      expect(store.checklists.map((l) => l.id), ['b', 'a']);
      expect(store.byId('b')!.items.map((i) => i.id), ['x', 'y']);
      store.applyCloudItems(const {});
      expect(store.isEmpty, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  group('P4 the hospital bag', () {
    setUp(() {
      PregnancyEndedStore.instance.resetForTest();
    });
    tearDown(() => PregnancyEndedStore.instance.resetForTest());

    Future<void> boot(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      try {
        await HospitalBagV2Store.instance.init();
      } catch (_) {
        /* offline in test */
      }
      await HospitalBagV2Store.instance.createBag(
        generateDefaultBag(DeliveryType.unsure),
        DeliveryType.unsure,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ReadyForBirthScreen(controller: PregnancyController()),
        ),
      );
      await tester.pump();
      for (var i = 0; i < 40; i++) {
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
        await tester.pump(const Duration(milliseconds: 25));
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets(
      'H1 the emergency page: red flags, a 108 button, no "You have time"',
      (tester) async {
        await boot(tester);
        expect(
          find.text(kHospitalBagTitle),
          findsWidgets,
          reason: 'H5 one name',
        );
        await tester.tap(find.text('Labour started?'));
        await tester.pumpAndSettle();
        expect(find.text(kLabourCallLine), findsOneWidget);
        expect(find.text(kLabourCallFirst), findsOneWidget);
        for (final f in kLabourRedFlags) {
          expect(find.text(f), findsOneWidget, reason: f);
        }
        expect(find.byKey(const ValueKey('rfb_call_108')), findsOneWidget);
        expect(find.text('Call 108'), findsOneWidget);
        expect(find.text('Call 102'), findsOneWidget);
        expect(find.textContaining('You have time'), findsNothing);
        expect(find.text('Take these first', skipOffstage: false), findsOneWidget, reason: 'kept');
        expect(tester.takeException(), isNull);
      },
    );

    test('the red flags are the NHS signs, each one "now"', () {
      expect(kLabourRedFlagsHeading, contains('108'));
      expect(kLabourRedFlagsHeading, contains('102'));
      expect(
        kLabourRedFlags.join(' ').toLowerCase(),
        allOf(
          contains('bleeding'),
          contains('green'),
          contains('moving less'),
          contains('severe pain'),
          contains('fever'),
          contains('push'),
        ),
      );
      expect(kAfterLossRedFlagsHeading, contains('108'));
      expect(kAfterLossRedFlagsHeading, contains('102'));
      expect(kAfterLossRedFlags, containsAll(['Heavy bleeding', 'A fever']));
      expect(
        kAfterLossRedFlags.join(' ').toLowerCase(),
        isNot(contains('baby')),
      );
    });

    test(
      'H2 baby lotion is out of the bag, the catalogue and the why lines',
      () {
        for (final d in DeliveryType.values) {
          expect(
            generateDefaultBag(d).map((i) => i.id),
            isNot(contains('baby_lotion')),
          );
        }
        expect(
          allBagCatalogItems().map((i) => i.id),
          isNot(contains('baby_lotion')),
        );
        expect(kWhyPack.containsKey('baby_lotion'), isFalse);
        expect(kRetiredBagIds, contains('baby_lotion'));
        // The safe-sleep lines.
        expect(
          kWhyPack['baby_swaddle']!.en,
          contains('never once your baby can roll'),
        );
        expect(
          kWhyPack['baby_cap']!.en,
          'For the ride home, not for sleep indoors.',
        );
        // The India documents are in the default bag.
        final docs = generateDefaultBag(
          DeliveryType.unsure,
        ).where((i) => i.category == BagCategory.documents).map((i) => i.id);
        expect(docs, containsAll(kAddedBagIds));
      },
    );

    test('H2/H5 an old bag drops an unpacked lotion, keeps a packed one, and '
        'gains the India papers without losing a tick', () async {
      SharedPreferences.setMockInitialValues({});
      final bag = HospitalBagV2Store.instance;
      final lotion = BagItem(
        id: 'baby_lotion',
        category: BagCategory.baby,
        name: const LocalizedText(en: 'Mild baby lotion / oil', hi: 'x'),
      );
      final old = [
        ...generateDefaultBag(
          DeliveryType.unsure,
        ).where((i) => !kAddedBagIds.contains(i.id)),
        lotion,
      ];
      old.first.packed = true;
      await bag.createBag(old, DeliveryType.unsure);
      final r = await bag.syncDefaults(
        wanted: bagSeedItems(kAddedBagIds),
        dropIfUnpacked: kRetiredBagIds,
      );
      expect(r.added, kAddedBagIds.length);
      expect(r.removed, 1);
      expect(bag.byId('baby_lotion'), isNull);
      expect(bag.byId(old.first.id)!.packed, isTrue, reason: 'ticks kept');
      // Idempotent.
      final again = await bag.syncDefaults(
        wanted: bagSeedItems(kAddedBagIds),
        dropIfUnpacked: kRetiredBagIds,
      );
      expect(again.added + again.removed, 0);

      // A packed lotion is hers to keep.
      final packed = BagItem(
        id: 'baby_lotion',
        category: BagCategory.baby,
        name: const LocalizedText(en: 'Mild baby lotion / oil', hi: 'x'),
        packed: true,
      );
      await bag.createBag([packed], DeliveryType.unsure);
      await bag.syncDefaults(dropIfUnpacked: kRetiredBagIds);
      expect(bag.byId('baby_lotion'), isNotNull);
    });

    test('H5 a new delivery type adds and removes only the caesarean items, '
        'ticks kept', () async {
      final bag = HospitalBagV2Store.instance;
      await bag.createBag(
        generateDefaultBag(DeliveryType.vaginal),
        DeliveryType.vaginal,
      );
      bag.items.first.packed = true;
      final only = bagDeliveryOnlyIds();
      expect(only, contains('after_binder'));
      var r = await bag.syncDefaults(
        wanted: [
          for (final i in generateDefaultBag(DeliveryType.csection))
            if (only.contains(i.id)) i,
        ],
        delivery: DeliveryType.csection,
      );
      expect(r.added, 1);
      expect(bag.byId('after_binder'), isNotNull);
      expect(bag.items.first.packed, isTrue);
      r = await bag.syncDefaults(
        dropIfUnpacked: only,
        delivery: DeliveryType.vaginal,
      );
      expect(r.removed, 1);
      expect(bag.byId('after_binder'), isNull);
      expect(bag.delivery, DeliveryType.vaginal);
    });

    test('H5 her own item can be removed with Undo, and renamed', () async {
      final bag = HospitalBagV2Store.instance;
      await bag.createBag(
        generateDefaultBag(DeliveryType.unsure),
        DeliveryType.unsure,
      );
      await bag.addCustomItem('Phone stand', BagCategory.custom);
      final mine = bag.items.last;
      expect(await bag.renameCustomItem(mine.id, 'Tablet stand'), isTrue);
      expect(bag.byId(mine.id)!.name.en, 'Tablet stand');
      expect(
        await bag.renameCustomItem('labour_gown', 'x'),
        isFalse,
        reason: 'catalogue names are ours',
      );
      final item = bag.byId(mine.id)!;
      final at = bag.indexOf(item.id);
      await bag.removeItem(item.id);
      expect(bag.byId(item.id), isNull);
      await bag.restoreItemAt(item, at);
      expect(bag.indexOf(item.id), at);
    });

    test('H3 the season follows the due date\'s month, not today\'s', () async {
      final ctx = ReadyBirthContextStore.instance;
      await ctx.setSeasonOverride(null);
      // Due in December, opened in July: winter, not the monsoon.
      expect(
        ctx.seasonFor(
          dueDate: DateTime(2027, 12, 10),
          today: DateTime(2027, 7, 1),
        ),
        Season.winter,
      );
      expect(
        ctx.seasonFor(
          dueDate: DateTime(2027, 4, 2),
          today: DateTime(2027, 1, 1),
        ),
        Season.summer,
      );
      // No due date yet: today's month.
      expect(ctx.seasonFor(today: DateTime(2027, 7, 1)), Season.monsoon);
      // Her own choice still wins.
      await ctx.setSeasonOverride(Season.pleasant);
      expect(ctx.seasonFor(dueDate: DateTime(2027, 12, 10)), Season.pleasant);
      await ctx.setSeasonOverride(null);
      // The live getter reads the pregnancy's due date.
      final c = PregnancyController(dueDate: DateTime(2027, 12, 10));
      final was = PregnancyController.current;
      PregnancyController.current = c;
      addTearDown(() => PregnancyController.current = was);
      if (c.isDueDateSet) expect(ctx.season, Season.winter);
    });

    test('D4 after a loss the Baby category and its insights step aside', () {
      expect(
        readyOrderFor(afterLoss: true),
        isNot(contains(ReadyCategory.baby)),
      );
      expect(readyOrderFor(afterLoss: false), contains(ReadyCategory.baby));
      final lines = readyInsights(
        week: 38,
        delivery: DeliveryType.unsure,
        season: Season.winter,
        twins: true,
        hospitalProvides: {'diapers'},
        afterLoss: true,
      ).map((i) => i.text.toLowerCase());
      expect(
        lines.where(
          (l) =>
              l.contains('baby') ||
              l.contains('twins') ||
              l.contains('newborn') ||
              l.contains('full term'),
        ),
        isEmpty,
      );
    });

    testWidgets(
      'D4 after a loss: the note shows, Baby is not a part, no week',
      (tester) async {
        await PregnancyEndedStore.instance.markEnded();
        await boot(tester);
        expect(
          find.text(kBagAfterLossNote, skipOffstage: false),
          findsOneWidget,
        );
        expect(find.text('Baby', skipOffstage: false), findsNothing);
        expect(find.text('Documents', skipOffstage: false), findsWidgets);
        expect(find.text('Labour started?'), findsNothing);
        // The emergency page after a loss is about her.
        await tester.tap(find.text('Going into hospital now?'));
        await tester.pumpAndSettle();
        expect(find.text(kAfterLossCallLine), findsOneWidget);
        for (final f in kAfterLossRedFlags) {
          expect(find.text(f), findsOneWidget, reason: f);
        }
        expect(find.text('Call 108'), findsOneWidget);
        expect(find.text('Call 102'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    test('the door tile can open the partner section', () {
      expect(readyCategoryFromName('partner'), ReadyCategory.partnerExtras);
      expect(readyCategoryFromName(null), isNull);
      expect(
        readCode('lib/screens/tools/ready_for_birth_screen.dart'),
        contains('final String? initialCategory;'),
      );
    });

    test('the father preview reads "For her" on her things', () {
      expect(
        readyCatBlurb(ReadyCategory.mom, father: true),
        startsWith('For her'),
      );
      expect(
        readyCatBlurb(ReadyCategory.mom, father: false),
        startsWith('For you'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('D1 "See it in the store"', () {
    bool none(String _) => false;
    bool all(String _) => true;

    test('a product the store knows opens its page', () {
      expect(
        getReadyStoreRoute(
          productId: 'nb_overall',
          query: 'SoftClip',
          storeHasId: all,
          storeSearchHits: all,
        ),
        GetReadyStoreRoute.productPage,
      );
    });

    test('else the store search when it finds anything', () {
      expect(
        getReadyStoreRoute(
          productId: 'gone',
          query: 'swaddle',
          storeHasId: none,
          storeSearchHits: all,
        ),
        GetReadyStoreRoute.storeSearch,
      );
      expect(
        getReadyStoreRoute(
          query: 'swaddle',
          storeHasId: all,
          storeSearchHits: all,
        ),
        GetReadyStoreRoute.storeSearch,
        reason: 'no product id (a bag item, her own item)',
      );
    });

    test('else a tagged Amazon search', () {
      expect(
        getReadyStoreRoute(
          productId: '',
          query: 'lip balm',
          storeHasId: none,
          storeSearchHits: none,
        ),
        GetReadyStoreRoute.amazonSearch,
      );
      expect(
        getReadyStoreRoute(query: '  ', storeHasId: none, storeSearchHits: all),
        GetReadyStoreRoute.amazonSearch,
      );
    });

    test('the Amazon link our code builds is tagged on the way out', () {
      final url = amazonSearchUrlFor('Nursing bra');
      expect(url, 'https://www.amazon.in/s?k=Nursing%20bra');
      final out = tagged(Uri.parse(url));
      expect(out.queryParameters['tag'], kPartnerTags['amazon.in']!['tag']);
      expect(out.queryParameters['k'], 'Nursing bra');
    });

    test('a link she typed without https:// is made openable', () {
      expect(
        normaliseOutboundLink('amazon.in/dp/B0X'),
        'https://amazon.in/dp/B0X',
      );
      expect(
        normaliseOutboundLink(' https://firstcry.com/x '),
        'https://firstcry.com/x',
      );
      expect(normaliseOutboundLink(''), '');
    });

    test('a bag item searches on short words, Amazon on its name', () {
      expect(bagStoreQuery('after_nursingbra', 'Nursing bra'), 'nursing bra');
      expect(
        bagAmazonQuery('Loose nightwear / birthing gown'),
        'Loose nightwear',
      );
      expect(bagAmazonQuery('Glasses (if you wear them)'), 'Glasses');
      expect(
        bagProductsFor('labour_gown'),
        isEmpty,
        reason: 'H4 no invented picks',
      );
    });

    test('the checklist and the bag never reach the preview checkout', () {
      final pcl = readCode('lib/screens/tools/product_checklist_screen.dart');
      expect(pcl, isNot(contains('showSingleItemBuyNow(')));
      expect(pcl, isNot(contains('bottomNavigationBar: _cartBar(')));
      expect(pcl, isNot(contains('launchUrl(')));
      expect(pcl, contains('openOutbound('));
      final rfb = readCode('lib/screens/tools/ready_for_birth_screen.dart');
      expect(rfb, contains('_openInStore(context, item)'));
      expect(rfb, isNot(contains('uiHaveTimeCallDoctor')));
    });
  });

  // ---------------------------------------------------------------------------
  group('P3 and P5 the checklist', () {
    test('the progress count is the Got rule: ticked or bought', () {
      final l = ProductChecklist(
        id: 'l',
        name: 'L',
        items: [
          ChecklistItem(id: 'a', productId: 'a', checked: true),
          ChecklistItem(id: 'b', productId: 'b'),
          ChecklistItem(id: 'c', productId: 'c'),
        ],
      );
      bool boughtB(ChecklistItem i) => i.productId == 'b';
      expect(l.gotCount, 1, reason: 'the old count missed bought');
      expect(l.ownedCount(boughtB), 2);
      final owned = [
        for (final i in l.items)
          if (i.checked || boughtB(i)) i,
      ];
      expect(l.ownedCount(boughtB), owned.length);
    });

    test('starter lists: the soonest-due first for her week; after a loss '
        'the newborn one steps aside', () {
      expect(kCuratedChecklists.first.name, kFeedingStarterName);
      expect(
        kCuratedChecklists.map((c) => c.name),
        isNot(contains('Newborn essentials')),
      );
      // Feeding is due at 30-34; bump comfort from 16-20.
      int tier(String id, int week) {
        final from = switch (id.split('_').first) {
          'sw' || 'bp' => 34,
          'nb' => 30,
          'pp' => 16,
          'bb' || 'cs' => 20,
          'sc' => 12,
          'mw' => 14,
          _ => null,
        };
        if (from == null) return 1;
        return (from - week).abs() <= 4 ? 0 : 2;
      }

      final early = curatedForHer(kCuratedChecklists, week: 17, tierOf: tier);
      expect(early.first.name, isNot(kFeedingStarterName));
      final late = curatedForHer(kCuratedChecklists, week: 33, tierOf: tier);
      expect(late.first.name, kFeedingStarterName);
      expect(
        curatedForHer(kCuratedChecklists).map((c) => c.name),
        kCuratedChecklists.map((c) => c.name),
        reason: 'no week, no reorder',
      );
      final lost = curatedForHer(kCuratedChecklists, afterLoss: true);
      expect(lost.where((c) => c.forNewborn), isEmpty);
      expect(lost, isNotEmpty);
    });
  });
}

/// Source with comment lines dropped: what the code does, not what it kept.
String readCode(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');
