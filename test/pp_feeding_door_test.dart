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
      final response = _page('safety_choking_response');
      expect(response.format, 'VIDEO');
      expect(response.orderedBlocks.first, isA<PpVideoSlot>());
      expect(response.blocks.whereType<PpSteps>().single.steps.length, greaterThanOrEqualTo(6));
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
          {'pp_feeding', 'pp_food_chart', 'pp_baby_food_check', 'pp_food', 'pp_growth'});
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
        await tester.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, onSurface: (_, _) {})));
        await tester.pumpAndSettle();
        expect(find.text('Log his feeds'), findsOneWidget, reason: 'month $months');
        expect(find.text('Talk to a lactation expert'), findsOneWidget);
        expect(find.text('A hot, painful lump in the breast'), findsOneWidget, reason: 'the red flag');
      }
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
