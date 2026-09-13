// =============================================================================
//  The You, Maa door, held against its brief
// -----------------------------------------------------------------------------
//  `You_Parenting_Maa_rebuild.pdf` as assertions. What fails silently here:
//  the frightening-thoughts route sliding down from the top; a tool or a
//  scored tracker appearing; the mother's path wired to the baby's checker;
//  the shop and circle links going dead again; Going back drawing an empty
//  card in the first six weeks; First 40 Days growing a second copy of the
//  bleeding page; weight-loss framing creeping into the food area.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

PpSection get _you => ppSectionFor('parenting_maternal')!;
PpArea _area(String id) => _you.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _you.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

void _ageDays(int days) => ChildProfileStore.instance
    .debugSetDob(DateTime.now().subtract(Duration(days: days)));

Iterable<String> _surfaces(PpPage p) => [
      for (final b in p.blocks)
        if (b is PpLink && b.surfaceId != null) b.surfaceId!,
    ];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_maternal')!;

  group('the map', () {
    test('five tabs, every area placed once, the triage first, no tools', () {
      expect([for (final t in door.tabs) t.id], ['today', 'body', 'moving_eating', 'people', 'going_back']);
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _you.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(door.tabs.first.areaIds.first, 'how_are_you');
      for (final t in door.tabs) {
        expect(t.tools, isEmpty, reason: '${t.id}: no tools, no scored tracker');
      }
      expect(_you.tools, isEmpty);
      expect(door.closing!.surfaceId, 'pp_experts/Maternal mental health');
    });

    test('the frightening-thoughts route is pinned at the very top and reaches the crisis path', () {
      expect(door.tabs[0].redFlagPageId, 'you_route_scary');
      expect(_listed('how_are_you').first, 'you_route_scary');
      expect(_surfaces(_page('you_route_scary')), contains('pp_crisis_path'));
      expect(ppScreenForSurface('pp_crisis_path'), isNotNull);
      expect(_listed('how_are_you'), hasLength(8), reason: 'eight routes');
    });

    test('the mother is never wired to the baby\'s checker', () {
      for (final p in _you.allPages) {
        expect(_surfaces(p), isNot(contains('pp_what_changed')), reason: p.id);
      }
      expect(door.tabs.every((t) => t.tools.every((x) => x.surfaceId != 'pp_what_changed')), isTrue);
    });

    test('the dead links are wired: the shop and the circle', () {
      final src = File('lib/screens/post_pregnancy/pp_you_maa_content.dart').readAsStringSync();
      final live = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
      expect(live.contains('_shopSurface = null'), isFalse);
      expect(live.contains('_circleSurface = null'), isFalse);
      expect(ppScreenForSurface('pp_products'), isNotNull);
      expect(ppScreenForSurface('pp_community/mothers_4th_trimester'), isNotNull);
      final all = [for (final p in _you.allPages) ..._surfaces(p)];
      expect(all.where((s) => s == 'pp_products').length, greaterThanOrEqualTo(6), reason: 'the ~8 shop links');
      expect(all.where((s) => s == 'pp_community/mothers_4th_trimester').length, greaterThanOrEqualTo(3));
    });

    test('the dead card: Going back is tagged out of the first six weeks', () {
      expect(_area('back_to_work').bands, isNot(contains('pp_0_6w')));
      expect(_area('back_to_work').bands, isNotEmpty);
    });

    test('the two scaffolds are in the ledger', () {
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final id in ['body_your_sleep', 'body_thyroid']) {
        expect(_page(id).comingSoon, isTrue, reason: id);
        expect(ledger.contains(id), isTrue, reason: '$id is a coming-soon card nobody has logged as owed');
      }
      expect(_listed('your_body'), containsAll(['body_your_sleep', 'body_thyroid']));
    });

    test('no weight-loss framing in the food area: never as a goal in a title or heading', () {
      // The body copy names the weight question in order to answer it honestly
      // once, and corrects a myth about it; what must never appear is weight
      // loss as the POINT of a page or a section. Titles and headings carry
      // the framing, so those are what is checked.
      final heads = <String>[];
      for (final a in ['feeding_yourself', 'healing_kitchen', 'movement']) {
        heads.add(_area(a).title);
        for (final p in _area(a).pages) {
          heads.add(p.title);
          for (final b in p.blocks) {
            if (b is PpArticle && b.heading != null) heads.add(b.heading!);
            if (b is PpSteps && b.heading != null) heads.add(b.heading!);
            if (b is PpCards && b.heading != null) heads.add(b.heading!);
          }
        }
      }
      final goal = RegExp(r'lose weight|weight loss|slim|get your body back', caseSensitive: false);
      for (final h in heads) {
        expect(goal.hasMatch(h), isFalse, reason: h);
      }
    });
  });

  group('single source: the one home for her recovery', () {
    test('First 40 Days\' acute pages and its breasts card are windows into You', () {
      final f40 = ppSectionFor('parenting_first_40')!;
      const windows = {
        'f40_lochia': 'pp_page/parenting_maternal/body_lochia',
        'f40_after_normal_delivery': 'pp_page/parenting_maternal/body_perineum',
        'f40_after_csection': 'pp_page/parenting_maternal/body_csection_early',
        'f40_breasts': 'pp_page/parenting_maternal/body_breasts',
        'f40_pregnant_again': 'pp_page/parenting_maternal/people_intimacy',
      };
      for (final e in windows.entries) {
        final p = f40.pageById(e.key)!;
        expect(p.toolSurfaceId, e.value, reason: e.key);
        expect(p.blocks, isEmpty, reason: '${e.key}: no second copy');
        expect(p.comingSoon, isFalse, reason: e.key);
        expect(ppScreenForSurface(e.value), isNotNull, reason: e.value);
      }
    });

    test('Feeding\'s mastitis flag links into the one breast-health page', () {
      final feeding = ppSectionFor('parenting_feeding')!.pageById('bf_mastitis')!;
      expect(_surfaces(feeding), contains('pp_page/parenting_maternal/body_breasts'));
    });
  });

  group('the age rule, on her timeline', () {
    test('the section auto-scopes on the postpartum bands', () {
      expect(_you.autoScope, isTrue);
      expect(_you.bandSet!.bands.first.id, 'pp_0_6w');
    });

    testWidgets('day 10: four tabs open, Going back locked; day 100: all five, no lock', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageDays(10);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(10), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('READ THIS ONE FIRST'), findsOneWidget);
      expect(find.text('I am having thoughts that frighten me'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(2), reason: 'Going back, badge and mark');
      expect(find.text('Talk to someone about your own recovery'), findsOneWidget);
      expect(find.textContaining('FOR YOU  '), findsOneWidget, reason: 'the hero speaks to her, not about the baby');
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey('locked'), door: door, onSurface: (_, _) {}, initialTabId: 'going_back')));
      await tester.pumpAndSettle();
      expect(find.text('This opens when you are 2 months in.'), findsOneWidget);

      _ageDays(100);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey(100), door: door, onSurface: (_, _) {}, initialTabId: 'going_back')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      expect(find.text('Planning your return, starting about four weeks out'), findsOneWidget);
    });
  });
}
