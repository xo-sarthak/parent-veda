// =============================================================================
//  The First 40 Days door, held against its brief
// -----------------------------------------------------------------------------
//  `First_40_Days_Prompt.pdf` as assertions. What fails silently here: a
//  second crisis screen; a second latch, malish, swaddle or settling film;
//  the mother's tab sliding back down the order; a red strip or a closing
//  offer appearing on a door that refuses both; a coming-soon scaffold not in
//  the owed ledger; the oil advice written twice again.
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

PpSection get _f40 => ppSectionFor('parenting_first_40')!;
PpArea _area(String id) => _f40.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _f40.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

const _badges = {
  'DAY-SPINE CARD', 'SHORT ARTICLE', 'ARTICLE', 'FLAGGED QUICK-REFERENCE',
  'INTERACTIVE', 'STEP-LIST', 'VIDEO', 'CHART-CARD', 'CAROUSEL',
  'FLAGGED ARTICLE', 'ILLUSTRATION', 'COMPARISON TABLE', 'CARDS',
};

void _ageDays(int days) => ChildProfileStore.instance
    .debugSetDob(DateTime.now().subtract(Duration(days: days)));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_first_40')!;

  group('the map', () {
    test('five tabs, every area placed once, the mother third, no red strip, no closing', () {
      expect([for (final t in door.tabs) t.id], ['din_by_din', 'rush', 'maa', 'samjho', 'feeding_rest']);
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _f40.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(door.tabs[2].areaIds, ['maa_ki_dekhbhaal'], reason: 'lifted up, right after the emergency tab');
      for (final t in door.tabs) {
        expect(t.redFlagPageId, isNull, reason: 'no red strip on the front, on purpose');
      }
      expect(door.closing, isNull, reason: 'no "book someone" under exhaustion content');
      expect(door.closingLine, isNull);
    });

    test('the go-now list is the first card of the second tab, and the crying card is Behaviour\'s screen', () {
      expect(_listed('rush_to_doctor').first, 'f40_red_flags');
      final crying = _page('f40_crying_never_shake');
      expect(crying.format, 'INTERACTIVE');
      expect(crying.toolSurfaceId, 'pp_page/parenting_behaviour/crying_too_much');
      expect(crying.blocks, isEmpty, reason: 'one crisis screen, both sections point to it');
      expect(ppScreenForSurface(crying.toolSurfaceId!), isNotNull);
    });

    test('the reformats', () {
      expect(_page('f40_first_bath').format, 'VIDEO');
      expect(_page('f40_first_bath').orderedBlocks.first, isA<PpVideoSlot>());
      expect(_page('f40_nappy_poop').blocks.whereType<PpIllustration>().single.kind, PpIllustrationKind.poopColours);
      expect(_page('f40_nappy_poop').blocks.whereType<PpChartCard>(), isNotEmpty, reason: 'the chart stays beside the strip');
      expect(_page('f40_swaddle').format, 'VIDEO');
      for (final id in ['f40_newborn_skin', 'f40_newborn_noises']) {
        final p = _page(id);
        expect(p.format, 'CAROUSEL', reason: id);
        expect(p.blocks.single, isA<PpCarousel>(), reason: '$id is its one block');
      }
      expect((_page('f40_newborn_skin').blocks.single as PpCarousel).cards.map((c) => c.title),
          contains('Skin that needs a doctor'), reason: 'the doctor line rides the slides');
      expect(_page('f40_safe_sleep').format, 'ILLUSTRATION');
      expect(_page('f40_safe_sleep').blocks.whereType<PpIllustration>().single.kind, PpIllustrationKind.safeBedSetup);
      expect(_page('f40_soothing').format, 'VIDEO');
    });

    test('one film each: latch, malish, swaddle, settling share Feeding\'s and Sleep\'s slots', () {
      String slot(String id) => _page(id).blocks.whereType<PpVideoSlot>().first.slotId;
      expect(slot('f40_latch'), 'feeding/latch_demo');
      expect(slot('f40_malish'), 'sleep/malish_demo');
      expect(slot('f40_swaddle'), 'sleep/swaddle_demo');
      expect(slot('f40_soothing'), 'sleep/settling_demo');
    });

    test('single source: the oil advice and the why-he-wakes explanation live once', () {
      final malish = _page('f40_malish');
      expect(malish.blocks.whereType<PpCards>().any((c) => c.heading == 'Which oil'), isFalse);
      expect(malish.blocks.whereType<PpLink>().any((l) => l.pageId == 'f40_which_oil'), isTrue);
      final night = _page('f40_day_night');
      expect(night.blocks.whereType<PpLink>().any((l) => l.pageId == 'f40_newborn_sleep'), isTrue);
      final all = [for (final b in night.blocks) if (b is PpArticle) ...b.paragraphs].join(' ');
      expect(all.contains('short cycles'), isFalse, reason: 'the short-cycles explanation is Newborn sleep, honestly\'s');
    });

    test('the five scaffolds, each in the ledger, and the vaccines pointer', () {
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final id in ['f40_breasts', 'f40_pregnant_again', 'f40_small_or_early', 'f40_for_husband', 'f40_ceremonies']) {
        expect(_page(id).comingSoon, isTrue, reason: id);
        expect(ledger.contains(id), isTrue, reason: '$id is a coming-soon card nobody has logged as owed');
      }
      expect(_listed('maa_ki_dekhbhaal'), contains('f40_breasts'));
      expect(_listed('samjho'), contains('f40_small_or_early'));
      expect(_listed('din_by_din'), containsAll(['f40_for_husband', 'f40_ceremonies']));
      expect(_page('f40_forty_mark').blocks.whereType<PpLink>().any((l) => l.surfaceId == 'pp_vaccines'), isTrue);
    });

    test('every listed page wears a badge from the vocabulary', () {
      for (final p in _f40.allPages) {
        expect(_badges, contains(p.format), reason: '${p.id}: "${p.format}"');
      }
    });
  });

  group('the age rule', () {
    test('the section auto-scopes', () => expect(_f40.autoScope, isTrue));

    testWidgets('day 12: the first-month spine, the mother third, no closing; day 50: the 40-day page', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageDays(12);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(12), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Days 1 to 7: the first week'), findsOneWidget);
      expect(find.text('You made it to 40 days. What now?'), findsNothing, reason: 'the 40-day mark and after');
      expect(find.text('For your husband, in the first 40 days'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing, reason: 'every tab is for the whole forty days');
      expect(find.text('Consult'), findsNothing, reason: 'no closing card');
      final labels = [for (final t in door.tabs) t.label];
      expect(labels[2], 'Maa ki dekhbhaal');

      _ageDays(50);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(50), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('You made it to 40 days. What now?'), findsOneWidget);
      expect(find.text('Days 1 to 7: the first week'), findsNothing);
    });
  });
}
