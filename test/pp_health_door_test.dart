// =============================================================================
//  The Health door, held against its rebuild brief
// -----------------------------------------------------------------------------
//  `ParentVeda_Health_rebuild.pdf` as assertions. What fails silently here:
//  the red-flag list growing a fourth copy; a coming-soon scaffold that is not
//  in the owed ledger (the card would hold its place forever with nobody
//  owing it); the dosing table quietly coming back; a merged page returning
//  to the rail beside the tool it merged into.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_health_red_flags.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

PpSection get _health => ppSectionFor('parenting_health')!;
PpArea _area(String id) => _health.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _health.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

const _badges = {
  'CHART', 'ANIMATION', 'TOOL', 'CAROUSEL', 'CARDS', 'TABLE', 'VIDEO',
  'INTERACTIVE', 'RED FLAG', 'ARTICLE', 'ILLUSTRATION', 'AUDIO LIBRARY',
  'STEPS', 'SCRIPT',
};

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_health')!;

  group('the map', () {
    test('six tabs, on the brief\'s call, and every collection placed or named as merged', () {
      expect(door.tabs, hasLength(6));
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _health.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(door.hiddenAreaIds, ['not_sure'], reason: 'the flow that IS the What Changed tool');
      expect([for (final t in door.tabs) t.id], ['wrong', 'help', 'shots', 'growing', 'well', 'records']);
    });

    test('get help now: the canonical list pinned, the signs film, the speeds as a story, the three new pieces', () {
      expect(door.tabs[1].redFlagPageId, 'health_go_now');
      expect(_listed('emergency'), [
        'health_go_now', 'health_signs_video', 'health_three_speeds', 'health_choking_response', 'health_fit', 'health_accidents',
      ]);
      // The door pins the first and keeps it off the rail.
      expect(door.tabs[1].redFlagPageId, 'health_go_now');
      expect(_page('health_go_now').format, 'RED FLAG');
      expect(_page('health_signs_video').orderedBlocks.first, isA<PpVideoSlot>());
      final speeds = _page('health_three_speeds');
      expect(speeds.format, 'INTERACTIVE');
      expect(speeds.blocks.single, isA<PpInteractive>());
      expect((speeds.blocks.single as PpInteractive).items, hasLength(9), reason: 'the nine rows of the table');
      expect(_page('health_choking_response').orderedBlocks.first, isA<PpVideoSlot>());
      expect(_page('health_fit').comingSoon, isTrue);
      expect(_page('health_accidents').comingSoon, isTrue);
      expect(door.tabs[1].footer, contains('believe yourself'));
      expect(door.tabs[0].jumpToTabId, 'help', reason: 'panic is one tap from the default tab');
    });

    test('something\'s wrong: the reformats', () {
      expect(_page('fever_reading').format, 'ILLUSTRATION');
      expect(_page('fever_reading').blocks.whereType<PpIllustration>().single.kind,
          PpIllustrationKind.thermometerRoutes);
      expect(_page('fever_reading').blocks.whereType<PpTable>(), isNotEmpty, reason: 'what is normal by route stays');
      expect(_page('fever_bringing_down').blocks.whereType<PpCarousel>().single.cards.every((c) => c.myth), isTrue,
          reason: 'the sponging myths as myth-vs-fact');
      expect(_page('cold_blocked_nose').format, 'VIDEO');
      expect(_page('tummy_ors').format, 'VIDEO');
      expect(_page('prev_medicine').format, 'VIDEO');
      for (final id in ['cold_blocked_nose', 'tummy_ors', 'prev_medicine']) {
        expect(_page(id).orderedBlocks.first, isA<PpVideoSlot>(), reason: id);
      }
      expect(_page('tummy_dehydration').blocks.whereType<PpIllustration>().single.kind,
          PpIllustrationKind.dehydrationSigns);
      expect(_page('skin_which_rash').blocks.whereType<PpIllustration>().single.kind,
          PpIllustrationKind.rashGrid);
      expect(_page('skin_which_rash').blocks.whereType<PpIllustration>().single.labels, hasLength(8));
      expect(_page('skin_which_rash').blocks.whereType<PpCallout>().any((c) => c.title == 'The glass test'), isTrue);
      expect(_page('ill_teething_fever').comingSoon, isTrue);
    });

    test('the dosing page is reframed: no numbers, the bottle and the mistakes', () {
      final p = _page('fever_dosing');
      expect(p.title, contains('reading the dose right'));
      expect(p.blocks.whereType<PpTable>(), isEmpty, reason: 'the mg-by-weight table must not render');
      expect(p.blocks.whereType<PpChartCard>(), isEmpty, reason: 'nor the ceilings card');
      final all = [for (final b in p.blocks) ..._strings(b)].join(' ');
      expect(RegExp(r'\d+ to \d+ mg').hasMatch(all), isFalse, reason: 'no dose range anywhere in live copy');
      expect(p.blocks.whereType<PpSteps>().single.heading, contains('bottle'));
      expect(p.blocks.whereType<PpCards>().any((c) => c.heading!.contains('overdose')), isTrue);
    });

    test('the merges are absences on the rail, with the tool leading', () {
      for (final id in ['vax_schedule', 'health_emergency_card', 'rec_wallet']) {
        expect(_page(id).linkedOnly, isTrue, reason: id);
        expect(_page(id).toolSurfaceId, isNotNull, reason: id);
      }
      expect(_listed('vaccines'), isNot(contains('vax_schedule')));
      expect(door.tabs[2].tools.single.surfaceId, 'pp_vaccines');
      expect(door.tabs[5].tools.map((t) => t.surfaceId).toSet(), {'pp_health_home', 'pp_emergency_card', 'pp_doctor_visit'});
      // the remedies pages open the one tool, filtered
      expect(_page('fever_remedies').toolSurfaceId, 'pp_nuskhe/Fever');
      expect(_page('cough_remedies').toolSurfaceId, 'pp_nuskhe/Cold & cough');
      expect(ppScreenForSurface('pp_nuskhe/Fever'), isNotNull);
    });

    test('every listed page wears a badge from the vocabulary', () {
      for (final p in _health.allPages) {
        expect(_badges, contains(p.format), reason: '${p.id}: "${p.format}"');
      }
    });
  });

  group('single source', () {
    test('the go-now list is one list, read by the page and the fever red flags', () {
      final go = _page('health_go_now').blocks.whereType<PpCallout>()
          .firstWhere((c) => c.kind == PpCalloutKind.doctor);
      for (final sign in kPpGoNowSigns) {
        expect(go.text, contains(sign), reason: 'go-now page: "$sign"');
      }
      final fever = _page('fever_red_flags').blocks.whereType<PpCallout>().map((c) => c.text).join(' ');
      for (final sign in kPpGoNowSigns) {
        expect(fever, contains(sign), reason: 'fever red flags: "$sign"');
      }
      // The fever check's gate is the same constant: a source check, since
      // the list there is private.
      final src = File('lib/screens/post_pregnancy/pp_fever_check_screen.dart').readAsStringSync();
      expect(src.contains('const List<String> _redFlags = kPpGoNowSigns;'), isTrue);
    });

    test('the choking response is canonical here and Feeding points at it', () {
      final feeding = ppSectionFor('parenting_feeding')!.pageById('safety_choking_response')!;
      expect(feeding.toolSurfaceId, 'pp_page/parenting_health/health_choking_response');
      expect(feeding.blocks, isEmpty, reason: 'no second copy');
      expect(ppScreenForSurface(feeding.toolSurfaceId!), isNotNull);
    });

    test('every coming-soon scaffold is in the owed ledger', () {
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final s in kPpSections) {
        for (final p in s.allPages.where((p) => p.comingSoon)) {
          expect(ledger.contains(p.id), isTrue,
              reason: '${s.id}/${p.id} is a coming-soon card nobody has logged as owed');
        }
      }
    });
  });

  group('the age rule', () {
    test('the section auto-scopes and the newborn-only pages are tagged', () {
      expect(_health.autoScope, isTrue);
      expect(_page('fever_under_3m').bands, ['hb_nb']);
      expect(_page('ill_jaundice').bands, ['hb_nb']);
    });
  });

  group('on screen', () {
    testWidgets('the door renders six cards, the jump, the tools and the closing', (tester) async {
      _ageMonths(8);
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      for (final t in door.tabs) {
        expect(find.text(t.label), findsWidgets, reason: t.id);
      }
      expect(find.text('Is this an emergency?'), findsOneWidget);
      expect(find.text('Fever check'), findsOneWidget);
      expect(find.text('Talk to a paediatrician'), findsOneWidget);
      expect(find.text('A fever in a baby under three months'), findsNothing,
          reason: 'an 8-month-old does not see the newborn page');
      // Tap the jump: the Get help now tab, with the red flag pinned.
      await tester.tap(find.text('Is this an emergency?'));
      await tester.pumpAndSettle();
      expect(find.text('Go to a hospital now'), findsWidgets);
      expect(find.textContaining('believe yourself'), findsOneWidget);
      expect(find.text('Coming soon'), findsWidgets, reason: 'the scaffolds hold their place');
    });
  });
}

Iterable<String> _strings(PpBlock b) {
  if (b is PpIntro) return [b.text];
  if (b is PpArticle) return [?b.heading, ...b.paragraphs];
  if (b is PpSteps) return [?b.heading, for (final s in b.steps) ...[s.title, ?s.detail]];
  if (b is PpCards) return [?b.heading, for (final c in b.cards) ...[c.title, c.line]];
  if (b is PpTable) return [?b.heading, ...b.columns, for (final r in b.rows) ...r];
  if (b is PpChartCard) return [b.title, ?b.subtitle, ?b.note, for (final (l, v) in b.rows) ...[l, v]];
  if (b is PpCallout) return [?b.title, b.text];
  if (b is PpWhenLine) return [b.text];
  if (b is PpIndiaNote) return [b.text];
  if (b is PpLink) return [b.label, ?b.blurb];
  return const [];
}
