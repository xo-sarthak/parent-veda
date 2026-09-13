// =============================================================================
//  The Potty door, held against its brief
// -----------------------------------------------------------------------------
//  `Potty_Parenting.pdf` as assertions. What fails silently here: a tool or
//  a readiness quiz appearing on a section that refuses both; the widened
//  areas narrowing back to 1 to 3, stranding a five-year-old's mother; the
//  Indian-toilet film going; a coming-soon scaffold that is not in the owed
//  ledger; the mug technique taught twice again.
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

PpSection get _potty => ppSectionFor('parenting_potty')!;
PpArea _area(String id) => _potty.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _potty.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

const _badges = {
  'CHART-CARD', 'ARTICLE', 'SHORT ARTICLE', 'COMPARISON TABLE', 'STEP-LIST',
  'ACTIVITY', 'VIDEO', 'CARDS',
};

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_potty')!;

  group('the map', () {
    test('five tabs, every area placed once, no tools anywhere', () {
      expect([for (final t in door.tabs) t.id], ['how_long', 'su_su', 'starting_out', 'bumpy', 'dry']);
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _potty.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      for (final t in door.tabs) {
        expect(t.tools, isEmpty, reason: '${t.id}: "no tools, and no readiness quiz"');
        expect(t.redFlagPageId, isNull, reason: 'no red strip on the front');
      }
      expect(_potty.tools, isEmpty);
      expect(door.closing!.surfaceId, 'pp_experts/Pediatrician');
    });

    test('the timeline leads the first tab, pinned and for every stage', () {
      expect(door.tabs[0].areaIds, ['the_real_shape'], reason: 'the timeline alone; readiness locks with Starting out');
      expect(door.tabs[2].areaIds.first, 'getting_ready');
      expect(_area('the_real_shape').bands, isEmpty, reason: 'all stages');
      expect(_listed('the_real_shape'), ['honest_timeline']);
      expect(_page('honest_timeline').format, 'CHART-CARD');
    });

    test('every built card survives, and the four scaffolds sit where the brief puts them', () {
      expect(_listed('su_su_way'), ['what_is_su_su', 'reading_signals', 'grandmother_and_diapers', 'diaper_free_time']);
      expect(_listed('getting_ready'), ['readiness_signs', 'which_approach', 'no_star_charts']);
      expect(_listed('how_to_do_it'), [
        'introducing_potty', 'daily_routine', 'words_and_cues', 'indian_toilet', 'boys_and_girls', 'three_day_method', 'pull_ups',
      ]);
      expect(_listed('when_bumpy'), ['accidents_are_normal', 'regressions', 'withholding_constipation', 'potty_refusal', 'taking_longer']);
      expect(_listed('things_to_do'), hasLength(3));
      expect(_listed('staying_dry'), ['night_dryness', 'bedwetting', 'wiping_and_washing', 'school_and_public']);
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final id in ['no_star_charts', 'three_day_method', 'pull_ups', 'taking_longer']) {
        expect(_page(id).comingSoon, isTrue, reason: id);
        expect(ledger.contains(id), isTrue, reason: '$id is a coming-soon card nobody has logged as owed');
      }
    });

    test('the widen: readiness, starting out and accidents reach the 3 to 6 band', () {
      for (final id in ['getting_ready', 'how_to_do_it', 'when_bumpy']) {
        expect(_area(id).bands, ['learning', 'dry'], reason: id);
      }
      expect(_area('su_su_way').bands, ['su_su'], reason: 'su-su stays baby-only');
      expect(_area('staying_dry').bands, ['dry'], reason: 'dry nights stay 3 to 6');
      expect(_area('things_to_do').bands, ['learning']);
    });

    test('the Indian toilet leads with its film, and the mug is taught once', () {
      final toilet = _page('indian_toilet');
      expect(toilet.format, 'VIDEO');
      expect(toilet.orderedBlocks.first, isA<PpVideoSlot>());
      expect((toilet.orderedBlocks.first as PpVideoSlot).slotId, 'potty/indian_toilet');
      final wiping = _page('wiping_and_washing');
      expect(wiping.blocks.whereType<PpLink>().any((l) => l.pageId == 'indian_toilet'), isTrue,
          reason: 'the wiping page points at the film rather than repeating the technique');
    });

    test('the cross-links: rash pictures, constipation depth, regression triggers', () {
      final rash = _page('diaper_free_time').blocks.whereType<PpLink>().map((l) => l.surfaceId);
      expect(rash, contains('pp_page/parenting_health/skin_which_rash'));
      final hold = _page('withholding_constipation').blocks.whereType<PpLink>().map((l) => l.surfaceId);
      expect(hold, contains('pp_page/parenting_health/tummy_constipation'));
      expect(hold, contains('pp_what_changed'));
      final reg = _page('regressions').blocks.whereType<PpLink>().map((l) => l.surfaceId);
      expect(reg, contains('pp_section/parenting_behaviour'));
      expect(reg, contains('pp_page/parenting_development/dev_leaps_lens'));
      for (final s in ['pp_page/parenting_health/skin_which_rash', 'pp_page/parenting_health/tummy_constipation',
          'pp_page/parenting_development/dev_leaps_lens', 'pp_section/parenting_behaviour']) {
        expect(ppScreenForSurface(s), isNotNull, reason: s);
      }
    });

    test('every listed page wears a badge from the vocabulary', () {
      for (final p in _potty.allPages) {
        expect(_badges, contains(p.format), reason: '${p.id}: "${p.format}"');
      }
    });

    test('no star chart, no reward, no quiz in live copy', () {
      final src = File('lib/screens/post_pregnancy/pp_potty_content.dart').readAsStringSync();
      final live = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n').toLowerCase();
      expect(live.contains('quiz'), isFalse);
      expect(RegExp(r'reward (chart|tracker)').hasMatch(live), isFalse);
    });
  });

  group('the age rule', () {
    test('the section auto-scopes', () => expect(_potty.autoScope, isTrue));

    testWidgets('a baby\'s parent: two tabs open, three locked; a two-year-old\'s: su-su gone, dry nights locked', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageMonths(4);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(4), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('How long this actually takes'), findsOneWidget, reason: 'the pinned timeline, for every stage');
      expect(find.text('The signs she is ready'), findsNothing, reason: 'readiness is 1 to 6, locked with Starting out');
      expect(find.textContaining('From 1 year'), findsNWidgets(2), reason: 'Starting out, Accidents');
      expect(find.textContaining('From 3 years'), findsOneWidget, reason: 'Dry nights');
      expect(find.text('Talk to a paediatrician about it'), findsOneWidget);

      _ageMonths(24);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey(24), door: door, onSurface: (_, _) {}, initialTabId: 'starting_out')));
      await tester.pumpAndSettle();
      expect(find.text('Catching the su-su'), findsNothing, reason: 'grown past');
      expect(find.text('The signs she is ready'), findsOneWidget, reason: 'readiness leads Starting out');
      expect(find.textContaining('From 3 years'), findsOneWidget);

      _ageMonths(50);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey(50), door: door, onSurface: (_, _) {}, initialTabId: 'bumpy')));
      await tester.pumpAndSettle();
      expect(find.text('She is holding it in'), findsOneWidget, reason: 'a four-year-old\'s mother reaches the withholding page');
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });
  });
}
