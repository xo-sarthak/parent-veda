// =============================================================================
//  The Feeding door, held against its rebuild brief
// -----------------------------------------------------------------------------
//  `ParentVeda_Feeding_rebuild.pdf` as assertions, the way
//  `pp_sleep_door_test.dart` holds Sleep's. The things here that fail
//  silently: an age chooser creeping back into a tool, the merged collection
//  going missing from the tool that now owns it, a choking page shipping as
//  text, and a video page whose slot is not at the top.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/models/pv_read.dart' show PvCalloutTone;
import 'package:parentveda/screens/doors/pv_door_rail.dart' show pvDoorRailCardKey;
import 'package:parentveda/screens/doors/pv_shelf_card.dart' show PvShelfCard;
import 'package:parentveda/screens/post_pregnancy/pp_page_read.dart' show ppPageAsRead;
import 'package:parentveda/screens/reader/pv_read_offer.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_baby_food_check_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_feeding_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/pp_what_to_feed_screen.dart';

PpSection get _feeding => ppSectionFor('parenting_feeding')!;
PpArea _area(String id) => _feeding.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _feeding.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

const _badges = {
  'CHART', 'ANIMATION', 'TOOL', 'CAROUSEL', 'CARDS', 'TABLE', 'VIDEO',
  'INTERACTIVE', 'RED FLAG', 'ARTICLE', 'ILLUSTRATION', 'AUDIO LIBRARY',
  'STEPS',
};

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the map', () {
    test('the eight collections, in the brief\'s order', () {
      expect([for (final a in _feeding.areas) a.id], [
        'breastfeeding', 'formula', 'starting_solids', 'age_charts',
        'cooking', 'weight_gain', 'not_eating', 'safety',
      ]);
    });

    test('feeding at the breast: latch and positions are video, mastitis carries the red flag', () {
      expect(_page('bf_latch').format, 'VIDEO');
      expect(_page('bf_positions').format, 'VIDEO');
      for (final id in ['bf_latch', 'bf_positions']) {
        expect(_page(id).orderedBlocks.first, isA<PpVideoSlot>(), reason: id);
      }
      final mast = _page('bf_mastitis');
      expect(mast.blocks.whereType<PpCallout>().any((c) => c.kind == PpCalloutKind.doctor), isTrue);
      expect(_page('bf_low_supply').blocks.whereType<PpLink>().any((l) => l.surfaceId == 'pp_feeding'), isTrue,
          reason: '"not making enough" links to the feed tracker');
    });

    test('formula: the bottle is video, and the bottle side now has numbers', () {
      expect(_page('formula_prepare').format, 'VIDEO');
      expect(_page('formula_prepare').orderedBlocks.first, isA<PpVideoSlot>());
      final chart = _page('formula_amounts');
      expect(chart.format, 'CHART');
      final card = chart.blocks.whereType<PpChartCard>().single;
      expect(card.rowMonths, isNotNull, reason: 'her row leads');
      expect(_listed('formula').last, 'formula_amounts');
    });

    test('starting solids: textures are a picture, allergens are a tracker, two new pages', () {
      expect(_page('solids_textures').format, 'ILLUSTRATION');
      expect(_page('solids_textures').blocks.whereType<PpIllustration>().single.kind,
          PpIllustrationKind.solidsTextures);
      final tracker = _page('solids_allergens');
      expect(tracker.format, 'INTERACTIVE');
      expect(tracker.blocks, hasLength(1), reason: 'the page is its block');
      final i = tracker.blocks.single as PpInteractive;
      expect(i.kind, PpInteractiveKind.checklist);
      expect(i.items, hasLength(8), reason: 'the eight allergens');
      expect(_feeding.pageById(i.closingPageId!), isNotNull);
      expect(_page('solids_setup').format, 'ARTICLE');
      expect(_page('solids_constipation').blocks.whereType<PpLink>()
          .any((l) => l.surfaceId == 'pp_section/parenting_health'), isTrue,
          reason: 'constipation links to Health');
    });

    test('the growth-chart read is a reference into the Growth journey', () {
      final p = _page('weight_chart_reading');
      expect(p.toolSurfaceId, 'pp_growth');
      expect(p.blocks, isEmpty, reason: 'the article was a duplicate of the tracker\'s read');
    });

    test('keeping feeding safe: the three safety moves', () {
      expect(_page('safety_choking').format, 'ILLUSTRATION');
      expect(_page('safety_choking').blocks.whereType<PpIllustration>().single.kind,
          PpIllustrationKind.cutItThisWay);
      expect(_page('safety_allergy').format, 'ILLUSTRATION');
      expect(_page('safety_allergy').blocks.whereType<PpCallout>()
          .any((c) => c.kind == PpCalloutKind.doctor), isTrue, reason: 'the call-now block');
      // The choking response is canonical in Health now; Feeding's card
      // opens that page directly.
      final response = _page('safety_choking_response');
      expect(response.format, 'VIDEO');
      expect(response.toolSurfaceId, 'pp_page/parenting_health/health_choking_response');
      expect(ppScreenForSurface(response.toolSurfaceId!), isNotNull);
      final canonical = ppSectionFor('parenting_health')!.pageById('health_choking_response')!;
      expect(canonical.orderedBlocks.first, isA<PpVideoSlot>());
      expect(canonical.blocks.whereType<PpSteps>().single.steps.length, greaterThanOrEqualTo(6));
      final gag = _page('safety_gagging');
      expect(gag.format, 'CAROUSEL');
      expect(gag.blocks.single, isA<PpCarousel>());
      for (final c in (gag.blocks.single as PpCarousel).cards) {
        if (c.pageId != null) expect(_feeding.pageById(c.pageId!), isNotNull);
      }
      expect(_page('safety_vitamin_d').format, 'ARTICLE');
    });

    test('every listed page wears a badge from the brief\'s vocabulary', () {
      for (final p in _feeding.allPages) {
        expect(_badges, contains(p.format), reason: '${p.id}: "${p.format}"');
      }
    });

    test('a carousel or interactive page is only its block', () {
      for (final p in _feeding.allPages) {
        final f = p.format?.toUpperCase();
        if (f == 'CAROUSEL' || f == 'INTERACTIVE') {
          expect(p.blocks, hasLength(1), reason: p.id);
        }
      }
    });
  });

  group('the age rule', () {
    test('the section auto-scopes', () => expect(_feeding.autoScope, isTrue));

    test('no copy asks her to pick or enter an age', () {
      final banned = ['pick an age', 'pick that first', 'pick his age', 'enter his age', 'choose an age'];
      for (final p in _feeding.allPages) {
        for (final b in p.blocks) {
          for (final s in _strings(b)) {
            for (final w in banned) {
              expect(s.toLowerCase().contains(w), isFalse, reason: '${p.id}: "$s"');
            }
          }
        }
      }
      for (final t in _feeding.tools) {
        expect(t.blurb.toLowerCase().contains('age in'), isFalse, reason: t.label);
      }
    });

    test('the merged tool has a day of food for every band', () {
      for (final b in kPpFeedingBands.bands) {
        expect(ppChartPagesForBand(b.id).where((p) => p.bands.isNotEmpty), isNotEmpty,
            reason: '${b.id} has no chart page');
      }
      expect(ppScreenForSurface('pp_food_chart'), isA<PpWhatToFeedScreen>());
    });

    testWidgets('the merged tool draws no age chips and says which age it shows', (tester) async {
      _ageMonths(7);
      tester.view.physicalSize = const Size(1200, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: PpWhatToFeedScreen()));
      await tester.pumpAndSettle();
      for (final b in kPpFeedingBands.bands) {
        expect(find.widgetWithText(GestureDetector, b.label), findsNothing, reason: 'chip for ${b.id}');
      }
      expect(find.textContaining('FIRST FOODS, 6 TO 8 MONTHS'), findsOneWidget);
      expect(find.text('Is he getting enough?'), findsWidgets);
    });

    testWidgets('the food checker answers for his age without asking', (tester) async {
      _ageMonths(9);
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: PpBabyFoodCheckScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('pick that first'), findsNothing);
      expect(find.textContaining('8 TO 12 MONTHS'), findsOneWidget);
      for (final b in kPpChildFoodBands) {
        expect(find.widgetWithText(GestureDetector, b.$1), findsNothing, reason: 'chip ${b.$1}');
      }
    });
  });

  group('the door shell', () {
    final door = ppDoorFor('parenting_feeding')!;

    test('five tabs; every collection on one tab or named as merged', () {
      expect(door.tabs, hasLength(5));
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _feeding.areas) a.id});
      expect(placed, hasLength(placed.toSet().length), reason: 'no area twice');
      expect(door.hiddenAreaIds, ['age_charts'], reason: 'the merged collection, and only it');
    });

    test('the six landing tools survive as tool cards and the closing', () {
      final tools = [for (final t in door.tabs) ...t.tools];
      expect(tools.map((t) => t.surfaceId).toSet(),
          // + the care logs, 2026-10-07 (gap analysis P1, Behind · Logging).
          {'pp_feeding', 'pp_food_chart', 'pp_baby_food_check', 'pp_food', 'pp_growth',
           'pp_feed_timer', 'pp_nappies', 'pp_pump', 'pp_care_history'});
      for (final t in tools) {
        expect(ppScreenForSurface(t.surfaceId), isNotNull, reason: t.label);
      }
      expect(door.closing!.surfaceId, 'pp_experts/Lactation expert');
      expect(ppScreenForSurface(door.closing!.surfaceId), isNotNull);
    });

    test('two red flags: mastitis on Milk, the choking response on Safe', () {
      expect(door.tabs.firstWhere((t) => t.id == 'milk').redFlagPageId, 'bf_mastitis');
      expect(door.tabs.firstWhere((t) => t.id == 'safe').redFlagPageId, 'safety_choking_response');
    });

    test('the tile and section links open the door', () {
      expect(ppScreenForSurface('pp_section/parenting_feeding'), isA<PpDoorScreen>());
      final deep = ppScreenForSurface('pp_section/parenting_feeding/safety')! as PpDoorScreen;
      expect(deep.initialTabId, 'safe');
    });

    testWidgets('the shell renders for a newborn and for a toddler', (tester) async {
      for (final months in [1, 20]) {
        _ageMonths(months);
        tester.view.physicalSize = const Size(1200, 6000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        // On Milk feeds: a toddler now opens on Cooking (plan §2a).
        await tester.pumpWidget(MaterialApp(
            home: PpDoorScreen(
                key: ValueKey(months),
                door: door,
                initialTabId: 'milk',
                onSurface: (_, _) {})));
        await tester.pumpAndSettle();
        expect(find.text('Log a feed'), findsOneWidget, reason: 'month $months');
        // Milk feeds has its own expert row (D2), so its foot is the doctor
        // sentence, not a second consult. Was the closing card (step 0 · S3).
        expect(find.byKey(const ValueKey('pp_door_tab_expert')), findsOneWidget);
        expect(find.byKey(const ValueKey('pp_door_closing_card')), findsNothing);
        expect(find.byKey(const ValueKey('pp_door_closing_line')), findsOneWidget);
        expect(find.text('A hot, painful lump in the breast'), findsOneWidget, reason: 'the red flag');
      }
    });
  });

  // ===========================================================================
  //  Door 1 of the door-by-door pass (docs/pp-door-plans/01-feeding.md),
  //  built 2026-10-25. The plan's tables, as data.
  // ===========================================================================
  group('door 1: the plan, held', () {
    final door = ppDoorFor('parenting_feeding')!;
    PpDoorTab tab(String id) => door.tabs.firstWhere((t) => t.id == id);

    test('§2a: the tab order for every band', () {
      expect(door.tabOrder, {
        'milk': ['milk', 'growing', 'safe'],
        'first_foods': ['solids', 'milk', 'safe', 'cooking', 'growing'],
        'm8_12': ['solids', 'cooking', 'safe', 'milk', 'growing'],
        'tod': ['cooking', 'growing', 'safe', 'solids', 'milk'],
        'big': ['cooking', 'growing', 'safe', 'milk'],
      });
    });

    test('D1: "Growing well" reads "Eating and growing"', () {
      expect(tab('growing').label, 'Eating and growing');
    });

    test('§2d: every page carries the plan\'s band tags', () {
      const m = 'milk', f = 'first_foods', e = 'm8_12', t = 'tod', b = 'big';
      const want = <String, List<String>>{
        'bf_latch': [m, f], 'bf_positions': [m, f], 'bf_how_often': [m, f],
        'bf_supply': [m, f, e], 'bf_diet': [m, f, e, t], 'bf_pumping': [m, f, e, t],
        'bf_low_supply': [m, f, e], 'bf_oversupply': [m, f], 'bf_mastitis': [m, f, e, t],
        'bf_cracked': [m, f], 'bf_biting': [f, e, t, b], 'bf_refusing': [m, f, e],
        'bf_benefits': [m, f, e], 'bf_lactation_help': [m, f, e], 'bf_toddler': [t, b],
        'bf_relactation': [m, f], 'bf_exclusive_pumping': [m, f, e],
        'bf_special_situations': [m, f],
        'formula_fed_is_fine': [m, f], 'formula_choose': [m, f, e],
        'formula_prepare': [m, f, e], 'formula_brands': [m, f, e],
        'formula_switching': [m, f, e], 'formula_mixed': [m, f],
        'formula_bottle_refusal': [m, f, e], 'formula_weaning': [f, e, t, b],
        'formula_amounts': [m, f, e],
        'solids_when': [f], 'solids_first_foods': [f, e], 'solids_spoon_or_blw': [f, e],
        'solids_allergens': [f, e, t], 'solids_textures': [f, e, t],
        'solids_annaprashan': [f], 'solids_setup': [f], 'solids_constipation': [f, e],
        'recipes_by_age': [f, e, t, b], 'recipes_staples': [f, e, t, b],
        'recipes_by_need': [f, e, t, b], 'recipes_sick_days': [f, e, t, b],
        'recipes_batch': [f, e, t, b], 'recipes_meal_ideas': [f, e, t, b],
        'recipes_tiffin_snacks': [t, b],
        'weight_foods': [f, e, t, b], 'weight_fats': [f, e, t, b],
        'weight_too_thin': [], 'weight_chart_reading': [],
        'picky_not_eating': [e, t, b], 'picky_who_decides': [e, t, b],
        'picky_food_jags': [t, b], 'picky_battles': [e, t, b],
        'picky_sweet_packet': [t, b], 'picky_health_drinks': [t, b],
        'safety_choking': [f, e, t, b], 'safety_avoid_under_one': [f, e],
        'safety_allergy': [f, e, t], 'safety_iron': [f, e, t, b],
        'safety_water': [m, f, e, t], 'safety_choking_response': [f, e, t, b],
        'safety_gagging': [f, e, t], 'safety_vitamin_d': [m, f, e, t],
      };
      for (final MapEntry(:key, :value) in want.entries) {
        expect(_page(key).bands, value, reason: key);
      }
      // Every page on a tab is in the table: a new page has to be placed.
      for (final t in door.tabs) {
        for (final id in t.areaIds) {
          for (final p in _area(id).pages) {
            expect(want.containsKey(p.id), isTrue, reason: '${p.id} has no row');
          }
        }
      }
      expect(_area('starting_solids').bands, [f, e, t]);
      expect(_area('cooking').bands, [f, e, t, b]);
      expect(_area('not_eating').bands, [e, t, b]);
    });

    test('§2c: tools have ages and their places', () {
      final milk = {for (final x in tab('milk').tools) x.surfaceId: x};
      expect(tab('milk').tools.first.surfaceId, 'pp_feed_timer', reason: 'the timer leads');
      expect(milk['pp_feed_timer']!.bands, ['milk', 'first_foods']);
      expect(milk['pp_feeding']!.bands, ['milk', 'first_foods', 'm8_12', 'tod']);
      expect(milk['pp_nappies']!.bands, ['milk']);
      expect(milk['pp_nappies']!.afterPageId, 'bf_how_often');
      expect(milk['pp_pump']!.afterPageId, 'bf_pumping');
      expect(milk['pp_care_history']!.atEnd, isTrue);
      expect(tab('growing').tools.single.bands, isNull, reason: 'growth is every age');
      // One tool on two tabs: the food chart and the checker lead Cooking
      // from one, where Starting solids sinks or is gone.
      expect([for (final x in tab('cooking').tools) x.surfaceId].take(2),
          ['pp_food_chart', 'pp_baby_food_check']);
      for (final x in tab('cooking').tools.take(2)) {
        expect(x.bands, ['tod', 'big']);
      }
    });

    test('§2e: Starting solids pins the choking response and carries gagging', () {
      expect(tab('solids').redFlagPageId, 'safety_choking_response');
      expect(tab('solids').extraPageIds, ['safety_gagging']);
      expect(tab('safe').redFlagPageId, 'safety_choking_response');
      expect(tab('milk').redFlagPageId, 'bf_mastitis');
    });

    test('D2 / §3b: an expert on every help tab, none on Safe', () {
      expect(tab('milk').expert!.surfaceId, 'pp_experts/Lactation expert');
      for (final id in ['solids', 'cooking', 'growing']) {
        expect(tab(id).expert!.surfaceId, 'pp_experts/Nutritionist', reason: id);
      }
      expect(tab('safe').expert, isNull);
      for (final t in door.tabs) {
        if (t.expert case final x?) {
          expect(ppSurfaceUnavailable(x.surfaceId), isNull, reason: '${t.id}: a real category');
        }
      }
    });

    test('§3a: the problem pages carry a consult; urgent pages never do', () {
      bool hasConsult(String id) => _page(id).blocks.any((b) => b is PpConsult);
      for (final id in [
        'bf_latch', 'bf_low_supply', 'bf_oversupply', 'bf_mastitis', 'bf_cracked',
        'bf_refusing', 'formula_mixed', 'weight_too_thin', 'picky_battles',
        'safety_iron', 'bf_supply', 'bf_lactation_help', 'picky_not_eating',
        'picky_health_drinks',
      ]) {
        expect(hasConsult(id), isTrue, reason: id);
      }
      for (final id in ['safety_choking_response', 'safety_gagging', 'safety_allergy']) {
        expect(hasConsult(id), isFalse, reason: '$id is urgent: not sold to');
      }
    });

    test('D2: a page\'s own consult sits under its doctor box, once', () {
      final read = ppPageAsRead(_feeding, _page('bf_low_supply'));
      final own = pvReadOwnConsult(read);
      expect(own, isNotNull);
      // The role picks the expert, in the reader too (was the whole roster).
      expect(own!.surfaceId, 'pp_experts/Lactation expert');
      expect(read.sections[pvReadOwnConsultAfter(read)].callout?.tone,
          PvCalloutTone.urgent, reason: 'right under the doctor box');
      expect(pvReadOfferFor(read), isNull, reason: 'one pitch per page (S6)');
    });

    test('IMS Act: nothing in formula and bottles links to a shop', () {
      for (final p in _area('formula').pages) {
        for (final b in p.blocks.whereType<PpLink>()) {
          expect(b.surfaceId?.startsWith('pp_products') ?? false, isFalse, reason: p.id);
          expect(b.surfaceId == 'pp_product_guide', isFalse, reason: p.id);
        }
      }
    });

    test('S8: every shelf link opens its shelf or says we are still choosing', () {
      final shelves = [
        for (final p in _feeding.allPages)
          for (final b in p.blocks.whereType<PpLink>())
            if (b.surfaceId case final s? when s.startsWith('pp_products')) s,
      ];
      expect(shelves, isNot(contains('pp_products')), reason: 'no link to the whole shop');
      for (final s in [
        'pp_products/pvs_nursing_feeding_pillows', 'pp_products/pvs_electric_breast_pumps',
        'pp_products/pvs_natural_nipple_balms', 'pp_products/pvs_absorbent_breast_pads',
        'pp_products/pvs_wireless_nursing_bras', 'pp_products/weaning',
      ]) {
        expect(shelves, contains(s));
        expect(ppSurfaceUnavailable(s), isNull, reason: '$s is stocked');
      }
      expect(ppSurfaceUnavailable('pp_products/High chairs'), contains('still choosing'));
    });

    test('D6: the health drinks page and the three new sections are in', () {
      final drinks = _page('picky_health_drinks');
      expect(_listed('not_eating').last, 'picky_health_drinks');
      expect(drinks.blocks.whereType<PpCallout>().any((c) => c.kind == PpCalloutKind.doctor), isTrue);
      bool heads(String id, String h) =>
          _page(id).blocks.whereType<PpArticle>().any((a) => a.heading == h);
      expect(heads('bf_pumping', 'Milk at the daycare, or with a nanny'), isTrue);
      expect(heads('recipes_batch', 'Packing food for daycare'), isTrue);
      expect(heads('recipes_meal_ideas', 'Festivals, fasts and the prasad plate'), isTrue);
    });

    test('§4: the four new demos have slots', () {
      String? slot(String id) =>
          _page(id).blocks.whereType<PpVideoSlot>().firstOrNull?.slotId;
      expect(slot('formula_mixed'), 'feeding/paced_bottle_demo');
      expect(slot('solids_textures'), 'feeding/finger_foods_9m_demo');
      expect(slot('formula_weaning'), 'feeding/open_cup_demo');
      expect(slot('recipes_staples'), 'feeding/ragi_porridge_textures');
    });

    test('§5: the seven thin pages are thin no more', () {
      int chars(String id) => [
            for (final b in _page(id).blocks) ..._strings(b),
            for (final c in _page(id).blocks.whereType<PpConsult>()) ...[c.title, c.whoFor],
          ].join(' ').length;
      for (final id in [
        'bf_exclusive_pumping', 'bf_toddler', 'bf_lactation_help',
        'bf_special_situations', 'bf_relactation', 'recipes_tiffin_snacks',
      ]) {
        expect(chars(id), greaterThan(1000), reason: id);
      }
      // The seventh stays a short card page, by the plan: it gains the
      // without-guilt line and the way to "fed is fine", not length.
      final benefits = _page('bf_benefits');
      expect(benefits.blocks.whereType<PpCallout>().any((c) => c.title == 'Without the guilt'), isTrue);
      expect(benefits.blocks.whereType<PpLink>().any((l) => l.pageId == 'formula_fed_is_fine'), isTrue);
    });

    // What she sees first, at one age in each band (plan §6.5).
    for (final (months, tabLabel, firstCard, expert) in [
      (2, 'Milk feeds', 'Breastfeed timer', true),
      (7, 'Starting solids', 'What to feed at this age', true),
      (10, 'Starting solids', 'What to feed at this age', true),
      (18, 'Cooking for your child', 'What to feed at this age', true),
      (30, 'Cooking for your child', 'What to feed at this age', true),
    ]) {
      testWidgets('first view at $months months: $tabLabel, then $firstCard', (tester) async {
        _ageMonths(months);
        tester.view.physicalSize = const Size(1200, 6000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, onSurface: (_, _) {})));
        await tester.pumpAndSettle();
        expect(find.descendant(of: find.byKey(pvDoorRailCardKey(0)), matching: find.text(tabLabel)),
            findsOneWidget);
        expect(tester.widgetList<PvShelfCard>(find.byType(PvShelfCard)).first.title, firstCard);
        expect(find.byKey(const ValueKey('pp_door_tab_expert')), expert ? findsOneWidget : findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a toddler: newborn tools fold under Earlier; mastitis stays to two', (tester) async {
      _ageMonths(18);
      tester.view.physicalSize = const Size(1200, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(door: door, initialTabId: 'milk', onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Breastfeed timer'), findsNothing, reason: 'folded, not on his rail');
      expect(find.text('A hot, painful lump in the breast'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('pp_door_band_fold_milk')));
      await tester.pumpAndSettle();
      expect(find.text('Breastfeed timer'), findsOneWidget, reason: 'still reachable');
    });

    testWidgets('a three-year-old: no mastitis pin, no Starting solids', (tester) async {
      _ageMonths(36);
      tester.view.physicalSize = const Size(1200, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(door: door, initialTabId: 'milk', onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('A hot, painful lump in the breast'), findsNothing);
      expect(find.text('Starting solids'), findsNothing, reason: 'past for two and up');
    });

    testWidgets('seven months: the choking response and gagging are on Starting solids', (tester) async {
      _ageMonths(7);
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_door_flag_row')), findsOneWidget);
      expect(find.text(_page('safety_choking_response').title), findsOneWidget);
      expect(find.text(_page('safety_gagging').title), findsOneWidget);
    });
  });
}

Iterable<String> _strings(PpBlock b) {
  if (b is PpIntro) return [b.text];
  if (b is PpArticle) return [?b.heading, ...b.paragraphs];
  if (b is PpSteps) return [?b.heading, for (final s in b.steps) ...[s.title, ?s.detail]];
  if (b is PpCards) return [?b.heading, for (final c in b.cards) ...[c.title, c.line]];
  if (b is PpChartCard) return [b.title, ?b.subtitle, ?b.note];
  if (b is PpCallout) return [?b.title, b.text];
  if (b is PpWhenLine) return [b.text];
  if (b is PpIndiaNote) return [b.text];
  if (b is PpLink) return [b.label, ?b.blurb];
  if (b is PpCarousel) return [?b.coverTitle, ?b.coverBlurb, for (final c in b.cards) ...[c.title, c.body]];
  if (b is PpInteractive) return [b.title, ?b.blurb, ?b.closing, for (final i in b.items) ...[i.title, ?i.detail]];
  if (b is PpIllustration) return [b.title, ?b.caption, for (final l in b.labels) ...[l.title, ?l.detail]];
  return const [];
}
