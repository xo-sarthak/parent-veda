// =============================================================================
//  The Traditions door, held against its brief
// -----------------------------------------------------------------------------
//  `Traditions_Parenting.pdf` as assertions. What fails silently here: an age
//  chip coming back; "coming up now" showing every stage's chart instead of
//  hers; the newborn-gathering safety block or the blade rule losing its one
//  home; a red flag or a closing appearing on a door that refuses both; a
//  placeholder not in the ledger; a ceremony page dropping a card.
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

PpSection get _tr => ppSectionFor('parenting_traditional')!;
PpArea _area(String id) => _tr.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _tr.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

const _badges = {'CHART-CARD', 'CEREMONY', 'CARDS', 'STEP-LIST', 'SCRIPT BOX', 'ARTICLE', 'SHORT ARTICLE'};

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

Iterable<PpLink> _links(PpPage p) => p.blocks.whereType<PpLink>();

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_traditional')!;

  group('the map', () {
    test('five tabs, every area placed once, coming-up first, no red flag, no closing', () {
      expect([for (final t in door.tabs) t.id], ['coming_up', 'welcome', 'first_years', 'faiths', 'small_safe']);
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _tr.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(door.tabs.first.areaIds, ['whats_now'], reason: 'pinned to the top');
      for (final t in door.tabs) {
        expect(t.redFlagPageId, isNull, reason: 'the flags live on the pages that earn them');
      }
      expect(door.closing, isNull, reason: 'there is genuinely nobody to book');
      expect(door.tabs[0].tools.single.surfaceId, 'pp_names');
      expect(door.tabs[4].tools.single.surfaceId, 'pp_nuskhe');
    });

    test('every built ceremony page survives, each with its card set', () {
      expect(_listed('welcome'), ['chatti', 'namkaran', 'jhula', 'nishkramana']);
      expect(_listed('first_meal'), ['annaprashan', 'annaprashan_food']);
      expect(_listed('milestones'), ['mundan', 'karnavedha', 'first_birthday', 'aksharabhyasam']);
      expect(_listed('other_faiths'), ['aqiqah', 'tahneek', 'christening', 'sikh_naming', 'jain_parsi', 'interfaith_far_from_home']);
      expect(_listed('keep_it_small'), ['what_it_costs', 'keeping_it_small', 'family_pressure', 'skip_it', 'someone_elses_ceremony', 'twins_adopted_second']);
      expect(_listed('not_safe'), ['newborn_customs', 'ceremony_day_safety', 'mother_kept_apart']);
      expect(_listed('first_festivals'), ['first_festivals']);
      for (final id in ['chatti', 'namkaran', 'jhula', 'nishkramana', 'annaprashan', 'mundan', 'karnavedha', 'first_birthday', 'aksharabhyasam']) {
        expect(_page(id).format, 'CEREMONY', reason: id);
        expect(_page(id).blocks.whereType<PpSteps>(), isNotEmpty, reason: '$id keeps its step-list');
        expect(_page(id).blocks.whereType<PpCards>(), isNotEmpty, reason: '$id keeps its cards');
      }
    });

    test('the eight placeholders, each in the ledger; the two sensitive ones among them', () {
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      const soon = [
        'how_date_chosen', 'how_name_chosen', 'first_festivals', 'skip_it',
        'someone_elses_ceremony', 'twins_adopted_second', 'interfaith_far_from_home', 'mother_kept_apart',
      ];
      for (final id in soon) {
        expect(_page(id).comingSoon, isTrue, reason: id);
        expect(ledger.contains(id), isTrue, reason: '$id is a coming-soon card nobody has logged as owed');
      }
      expect(_listed('whats_now').sublist(4), ['how_date_chosen', 'how_name_chosen'], reason: 'next to what is coming up');
    });

    test('the newborn customs page keeps its cards and gains the picture', () {
      final p = _page('newborn_customs');
      expect(p.blocks.whereType<PpIllustration>().single.kind, PpIllustrationKind.newbornCustoms);
      expect(p.blocks.whereType<PpIllustration>().single.labels, hasLength(4));
      expect(p.blocks.whereType<PpCards>(), isNotEmpty, reason: 'the card text stays');
    });

    test('every listed page wears a badge from the vocabulary', () {
      for (final p in _tr.allPages) {
        expect(_badges, contains(p.format), reason: '${p.id}: "${p.format}"');
      }
    });
  });

  group('single source', () {
    test('the newborn-gathering block lives once, and eight pages point at it', () {
      for (final id in ['chatti', 'namkaran', 'nishkramana', 'aqiqah', 'tahneek', 'christening', 'sikh_naming', 'jain_parsi']) {
        expect(_links(_page(id)).any((l) => l.pageId == 'ceremony_day_safety'), isTrue, reason: id);
      }
      // The short in-context line stays, word for word.
      expect(_page('chatti').blocks.whereType<PpCallout>().any((c) => c.text.contains('100.4F')), isTrue);
      // And the canonical page points at Health's go-now list.
      expect(_links(_page('ceremony_day_safety')).any((l) => l.surfaceId == 'pp_page/parenting_health/health_go_now'), isTrue);
      expect(ppScreenForSurface('pp_page/parenting_health/health_go_now'), isNotNull);
    });

    test('the blade rule lives once; mundan and karnavedha point at it', () {
      for (final id in ['mundan', 'karnavedha']) {
        expect(_links(_page(id)).any((l) => l.pageId == 'ceremony_day_safety'), isTrue, reason: id);
      }
    });

    test('the cost chart owns the numbers; keeping it small points at it', () {
      expect(_links(_page('keeping_it_small')).any((l) => l.pageId == 'what_it_costs'), isTrue);
      expect(_links(_page('annaprashan_food')).map((l) => l.surfaceId), containsAll(['pp_feeding', 'pp_food']));
    });
  });

  group('the age rule', () {
    test('the section auto-scopes; only coming-up is banded', () {
      expect(_tr.autoScope, isTrue);
      for (final a in _tr.areas.where((a) => a.id != 'whats_now')) {
        expect(a.bands, isEmpty, reason: '${a.id} is for every age');
        for (final p in a.pages) {
          expect(p.bands, isEmpty, reason: '${p.id} is for every age');
        }
      }
    });

    testWidgets('a newborn\'s parent sees the first-months chart; a two-year-old\'s sees the birthday one; nothing locks', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageMonths(1);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(1), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('The first months, in order'), findsOneWidget);
      expect(find.text('Coming up: birthday, mundan, ears'), findsNothing);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      expect(find.text('Find a name'), findsOneWidget);
      expect(find.text('Consult'), findsNothing);

      _ageMonths(24);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(24), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Coming up: birthday, mundan, ears'), findsOneWidget);
      expect(find.text('The first months, in order'), findsNothing);

      _ageMonths(24);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey('faiths'), door: door, onSurface: (_, _) {}, initialTabId: 'faiths')));
      await tester.pumpAndSettle();
      expect(find.text('Aqiqah, and naming in a Muslim family'), findsOneWidget, reason: 'every-age areas show in full');
    });
  });
}
