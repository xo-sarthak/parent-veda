// =============================================================================
//  The Safety door, held against its plan (door 11)
// -----------------------------------------------------------------------------
//  `docs/pp-door-plans/11-safety.md`, SF1 to SF8, as assertions. What fails
//  silently here, and must not: the emergency strip, a number on it, or Get
//  help now's pin going missing on some tab at some age (SF8, the reason this
//  file exists); a number typed where its constant belongs; a call button
//  that stops dialling; a baby's page leading a four-year-old's tab; CPR
//  losing a half, or showing the baby's half first to a toddler's parent;
//  a link that passes because it lands on a whole door or the whole shop.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/data/mind_mood_data.dart'
    show
        kAmbulanceNumber,
        kEmergencyNumber,
        kMotherBabyAmbulanceNumber,
        kPoisonsHelplineNumber;
import 'package:parentveda/widgets/pv_placeholders.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

PpSection get _sf => ppSectionFor('parenting_safety')!;
PpPage _page(String id) => _sf.pageById(id)!;
Iterable<PpLink> _links(PpPage p) => p.blocks.whereType<PpLink>();
Iterable<String?> _surfaces(PpPage p) => _links(p).map((l) => l.surfaceId);

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

String _text(PpPage p) => [
      for (final b in p.blocks)
        if (b is PpIntro) b.text
        else if (b is PpArticle) ...[if (b.heading != null) b.heading!, ...b.paragraphs]
        else if (b is PpSteps) ...[if (b.heading != null) b.heading!, for (final s in b.steps) '${s.title} ${s.detail ?? ''}']
        else if (b is PpCards) ...[if (b.heading != null) b.heading!, for (final c in b.cards) '${c.title} ${c.line}']
        else if (b is PpCallout) '${b.title ?? ''} ${b.text}'
        else if (b is PpIndiaNote) b.text
        else if (b is PpWhenLine) b.text,
    ].join(' ');

Future<void> _pump(WidgetTester t, PpDoor door, {required int months, String? tab}) async {
  _ageMonths(months);
  await t.pumpWidget(MaterialApp(
      home: PpDoorScreen(
          key: ValueKey('$months/$tab'), door: door, onSurface: (_, _) {}, initialTabId: tab)));
  await t.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_safety')!;
  final e = door.emergency!;
  const ages = [3, 18, 30, 48]; // one in each of the four bands

  group('SF1 and SF8: the emergency, on every tab, at every age', () {
    test('the numbers come from their constants, and every row lands', () {
      expect([for (final c in e.calls) c.number],
          [kEmergencyNumber, kAmbulanceNumber, kPoisonsHelplineNumber]);
      expect(e.calls.first.label, 'Call $kEmergencyNumber');
      for (final n in [kEmergencyNumber, kAmbulanceNumber, kMotherBabyAmbulanceNumber, kPoisonsHelplineNumber]) {
        expect(e.numbersLine, contains(n), reason: 'written out, for a phone that cannot dial');
      }
      expect([for (final l in e.links) l.surfaceId], [
        'pp_page/parenting_health/health_choking_response',
        'pp_page/parenting_safety/safety_cpr',
      ]);
      expect(e.pin!.tabId, 'first_aid');
      expect(e.pin!.surfaceId, 'pp_page/parenting_health/health_go_now',
          reason: 'Get help now stays the one emergency list');
      for (final s in [...e.links.map((l) => l.surfaceId), e.pin!.surfaceId]) {
        expect(ppScreenForSurface(s), isNotNull, reason: s);
      }
      // The grey note it replaced is gone from First aid.
      expect(door.tabs.firstWhere((t) => t.id == 'first_aid').note, isNull);
    });

    test('the call buttons are wired to the one dial, and the dial opens tel:', () {
      final screen = File('lib/screens/post_pregnancy/doors/pp_door_screen.dart').readAsStringSync();
      expect(screen, contains('ppDoorDial = ppDialNumber;'));
      expect(screen, contains('ppDoorDial(c.number);'));
      final crisis = File('lib/screens/post_pregnancy/pp_crisis_path_screen.dart').readAsStringSync();
      expect(crisis, contains("Uri(scheme: 'tel', path: number.replaceAll('-', ''))"));
      expect(crisis, contains('Future<void> _dial(String number) => ppDialNumber(number);'),
          reason: 'one dial in the parenting stage');
    });

    test('no emergency number is typed in the door or its content', () {
      final numbers = RegExp(r'\b(112|108|102)\b|1800-116-117');
      for (final f in ['lib/screens/post_pregnancy/pp_safety_content.dart', 'lib/data/doors/pp_door_safety.dart']) {
        for (final (i, line) in File(f).readAsLinesSync().indexed) {
          if (line.trimLeft().startsWith('//')) continue;
          expect(numbers.hasMatch(line), isFalse, reason: '$f:${i + 1}: $line');
        }
      }
    });

    testWidgets('every tab, every age: the strip, the three buttons, the numbers; the pin on First aid', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      final dialled = <String>[];
      final was = ppDoorDial;
      ppDoorDial = (n) async => dialled.add(n);
      addTearDown(() => ppDoorDial = was);
      for (final m in ages) {
        for (final tab in door.tabs) {
          await _pump(t, door, months: m, tab: tab.id);
          final why = '${tab.id} at $m months';
          expect(find.byKey(const ValueKey('pp_door_emergency')), findsOneWidget, reason: why);
          for (final c in e.calls) {
            expect(find.byKey(ppDoorCallKey(c.number)), findsOneWidget, reason: '$why: ${c.number}');
          }
          expect(find.text(e.numbersLine), findsOneWidget, reason: why);
          final pinned = tab.id == 'first_aid';
          expect(find.byKey(const ValueKey('pp_door_emergency_pin')), pinned ? findsOneWidget : findsNothing, reason: why);
          expect(find.byKey(const ValueKey('pp_door_emergency_head')), pinned ? findsNothing : findsOneWidget,
              reason: '$why: one callout, never two stacked');
          expect(find.byKey(const ValueKey('pp_door_emergency_link_pp_page/parenting_health/health_choking_response')),
              findsOneWidget, reason: why);
        }
      }
      // A tap dials the button's own number.
      await _pump(t, door, months: 18, tab: 'house');
      for (final c in e.calls) {
        await t.tap(find.byKey(ppDoorCallKey(c.number)));
        await t.pump();
      }
      expect(dialled, [kEmergencyNumber, kAmbulanceNumber, kPoisonsHelplineNumber]);
    });

    testWidgets('the pin opens Get help now; CPR is not drawn twice on First aid', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      final opened = <String>[];
      _ageMonths(18);
      await t.pumpWidget(MaterialApp(
          home: PpDoorScreen(door: door, onSurface: (_, s) => opened.add(s), initialTabId: 'first_aid')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('pp_door_emergency_pin')));
      await t.pump();
      expect(opened, ['pp_page/parenting_health/health_go_now']);
      expect(find.byKey(const ValueKey('pp_door_emergency_link_pp_page/parenting_safety/safety_cpr')), findsNothing,
          reason: 'the CPR page is the first card on this tab');
      await _pump(t, door, months: 18, tab: 'water');
      expect(find.byKey(const ValueKey('pp_door_emergency_link_pp_page/parenting_safety/safety_cpr')), findsOneWidget);
    });
  });

  group('SF2: each age its own pages first', () {
    test('every page\'s age, and none outside its area\'s', () {
      const tags = {
        'safety_walkers': ['infant'],
        'safety_bath': ['infant'],
        'safety_crowds': ['preschool'],
        'safety_road_sense': ['toddler_1', 'toddler_2', 'preschool'],
        'safety_motion_sickness': ['toddler_2', 'preschool'],
        'safety_screens_online': ['toddler_2', 'preschool'],
      };
      for (final p in _sf.allPages) {
        // A new page fails here until it has a row: every age is a choice.
        expect(p.bands, tags[p.id] ?? isEmpty, reason: p.id);
      }
      final bandIds = {for (final b in _sf.bandSet!.bands) b.id};
      for (final a in _sf.areas) {
        final areaBands = a.bands.isEmpty ? bandIds : a.bands.toSet();
        for (final p in a.pages) {
          expect(areaBands.containsAll(p.bands), isTrue, reason: '${a.id}/${p.id}');
        }
      }
    });

    test('the tab order for every band', () {
      expect(door.tabOrder, {
        'infant': ['house', 'first_aid', 'water', 'road', 'body'],
        'toddler_1': ['house', 'water', 'first_aid', 'road', 'body'],
        'toddler_2': ['house', 'water', 'first_aid', 'road', 'body'],
        'preschool': ['road', 'body', 'house', 'water', 'first_aid'],
      });
      expect(door.tabOrder.keys.toSet(), {for (final b in _sf.bandSet!.bands) b.id});
    });

    testWidgets('first view: the opening tab\'s first page at 3 and 48 months; no baby page first at four', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await _pump(t, door, months: 3);
      expect(find.text('Making your home safe, room by room'), findsWidgets);
      await _pump(t, door, months: 48);
      expect(find.text('Car seats, and children on two-wheelers'), findsWidgets, reason: 'Travel and heat opens');
      expect(find.text('Fairs, malls and stations: if your child gets lost'), findsWidgets);
      await _pump(t, door, months: 48, tab: 'water');
      expect(find.text('Bath time, safely'), findsNothing, reason: 'folded under Earlier');
      expect(find.byKey(const ValueKey('pp_door_band_fold_infant')), findsOneWidget, reason: 'never hidden');
      await _pump(t, door, months: 48, tab: 'house');
      expect(find.text('Are baby walkers safe?'), findsNothing);
    });

    test('CPR keeps both halves; the child\'s comes first from one', () {
      List<String?> heads() => [
            for (final b in _page('safety_cpr').orderedBlocks)
              if (b is PpSteps) b.heading,
          ];
      _ageMonths(6);
      expect(heads(), ['For a baby under one', 'For a child over one']);
      _ageMonths(18);
      expect(heads(), ['For a child over one', 'For a baby under one']);
      _ageMonths(48);
      expect(heads(), ['For a child over one', 'For a baby under one']);
      // The authored list is untouched; only the order the reader meets moves.
      expect([for (final b in _page('safety_cpr').blocks) if (b is PpSteps) b.heading],
          ['For a baby under one', 'For a child over one']);
    });
  });

  group('SF3 to SF7: the plan, held', () {
    test('SF3: flights and the front seat; the two-wheeler rule agrees with the car seat page', () {
      final travel = _page('safety_travel');
      expect(travel.blocks.whereType<PpCards>().map((c) => c.heading),
          containsAll(['Flying with a baby or toddler', 'The front seat']));
      final words = _text(travel);
      for (final s in ['7 to 14 days', 'infant ticket', 'Swallowing eases the pressure',
          'birth certificate', 'approved car seat', 'until about 12', 'in front of an airbag']) {
        expect(words, contains(s));
      }
      for (final s in ['nine months', 'four years', '40 km/h']) {
        expect(words, contains(s), reason: 'travel');
        expect(_text(_page('safety_car_seat')), contains(s), reason: 'car seat page');
      }
      expect(_surfaces(travel), containsAll([
        'pp_page/parenting_papers/pm_birth_certificate', 'pp_page/parenting_papers/pm_passport']));
      expect(_surfaces(travel), contains('pp_page/parenting_safety/safety_car_seat'));
    });

    test('SF5: the gaps are written in', () {
      expect(_text(_page('safety_room_by_room')), contains('Socket covers'));
      expect(_text(_page('safety_room_by_room')), contains('Extension boards off the floor'));
      expect(_text(_page('safety_tip_overs')), contains('Curtain and blind cords up high'));
      expect(_text(_page('safety_choking_objects')), contains('makhana'));
      expect(_text(_page('safety_choking_objects')), contains('jelly cubes'));
      final poisons = _text(_page('safety_poisons'));
      for (final s in ['Harpic', 'phenyl', 'Kerosene', 'Naphthalene', 'repellent', 'Kapoor', 'paracetamol']) {
        expect(poisons, contains(s));
      }
      expect(poisons, contains(kPoisonsHelplineNumber));
      final burns = _text(_page('safety_burns_home'));
      expect(burns, contains('Oil lamps (diya)'));
      expect(burns, contains('never pass over a child\'s head'));
      expect(burns, contains('Switch off the mains first'));
      expect(_text(_page('safety_first_aid_kit')), contains(kMotherBabyAmbulanceNumber));
      expect(_text(_page('safety_motion_sickness')).length, greaterThan(1000), reason: 'was about 600 characters');
      expect(_text(_page('safety_motion_sickness')), contains('not for under two'));
    });

    test('SF5 single source: heat stroke, dengue and choking are Health\'s pages, linked', () {
      final heat = _page('safety_heat');
      expect(_surfaces(heat), containsAll([
        'pp_page/parenting_health/prev_heat', 'pp_page/parenting_health/ill_dengue']));
      expect(_text(heat), isNot(contains('dengue')), reason: 'not written twice');
      final health = ppSectionFor('parenting_health')!;
      expect(health.pageById('prev_heat')!.title, contains('heat stroke'));
      expect(health.pageById('ill_dengue')!.blocks.whereType<PpCards>().map((c) => c.heading),
          contains('Keeping the mosquito away'));
    });

    test('SF4: two CPR films, the baby one Health\'s own slot; a tap says still being made', () {
      final films = [for (final p in _sf.allPages) ...p.blocks.whereType<PpVideoSlot>()];
      expect(films.map((f) => f.slotId), ['health/infant_cpr', 'safety/child_cpr']);
      final healthFilm = ppSectionFor('parenting_health')!
          .pageById('health_choking_response')!
          .blocks
          .whereType<PpVideoSlot>()
          .singleWhere((v) => v.slotId == 'health/infant_cpr');
      expect(films.first.title, healthFilm.title, reason: 'one film, two places');
      expect(_surfaces(_page('safety_cpr')), contains('pp_page/parenting_health/health_choking_response'));
      expect(door.heroImageUrl, startsWith('https://images.unsplash.com/'));
    });

    testWidgets('SF4: the child CPR film answers a tap', (t) async {
      final film = _page('safety_cpr').blocks.whereType<PpVideoSlot>().last;
      await t.pumpWidget(MaterialApp(
          home: Scaffold(body: Center(child: SizedBox(width: 320, child: PpBlockView(block: film))))));
      await t.tap(find.byType(PvVideoPlaceholder));
      await t.pump();
      expect(find.text(kPvFilmPendingNote), findsOneWidget);
      await t.pump(const Duration(seconds: 6));
      await t.pumpAndSettle();
    });

    test('SF6: the shop links, exactly, and stocked; the guide, the class', () {
      final shop = [
        for (final p in _sf.allPages)
          for (final s in _surfaces(p))
            if (s != null && s.startsWith('pp_products')) s,
      ];
      expect(shop, ['pp_products/pvs_rear_facing_car_seats'], reason: 'no whole shop, nothing unstocked');
      expect(ppSurfaceUnavailable(shop.single), isNull, reason: 'stocked');
      expect(ppScreenForSurface(shop.single), isNotNull);
      final seat = _surfaces(_page('safety_car_seat'));
      expect(seat, contains('pp_buying_guides/car_seat'));
      expect(ppScreenForSurface('pp_buying_guides/car_seat'), isNotNull);
      expect(_surfaces(_page('safety_room_by_room')), contains('pp_learn/mc_babyproof'));
      expect(ppScreenForSurface('pp_learn/mc_babyproof'), isNotNull);
      // The first aid and CPR class is owed: First aid ends on the same one
      // Health's Get help now ends on, and it says "Tell me".
      final aid = door.tabs.firstWhere((t) => t.id == 'first_aid');
      final health = ppDoorFor('parenting_health')!.tabs.firstWhere((t) => t.id == 'help');
      expect(aid.closing!.surfaceId, health.closing!.surfaceId);
      expect(ppSurfaceUnavailable(aid.closing!.surfaceId), contains('Tell me'));
      for (final t in door.tabs.where((t) => t.id != 'first_aid')) {
        expect(t.closing, isNull, reason: '${t.id} ends on the paediatrician');
      }
    });

    test('SF7: every new link lands on its exact page; nothing opens the whole door', () {
      const exact = {
        'safety_falls': 'pp_page/parenting_health/ill_head_bump',
        'safety_room_by_room': 'pp_page/parenting_sleep/sleep_surface',
        'safety_poisons': 'pp_page/parenting_traditional/newborn_customs',
        'safety_heat': 'pp_page/parenting_health/ill_dengue',
      };
      for (final MapEntry(key: id, value: target) in exact.entries) {
        expect(_surfaces(_page(id)), contains(target), reason: id);
        expect(ppScreenForSurface(target), isNotNull, reason: target);
      }
      // Every link in the door resolves.
      for (final p in _sf.allPages) {
        for (final l in _links(p)) {
          if (l.pageId case final id?) expect(_sf.pageById(id), isNotNull, reason: '${p.id} -> $id');
          if (l.surfaceId case final s?) {
            expect(ppScreenForSurface(s) != null || ppSurfaceUnavailable(s) != null, isTrue, reason: '${p.id} -> $s');
          }
        }
      }
      // The four whole-door links now name a page.
      final health = ppSectionFor('parenting_health')!;
      expect(_surfaces(health.pageById('health_accidents')!), contains('pp_page/parenting_safety/safety_room_by_room'));
      expect(_surfaces(health.pageById('ill_head_bump')!), contains('pp_page/parenting_safety/safety_falls'));
      for (final f in ['lib/screens/post_pregnancy/pp_health_content.dart', 'lib/screens/post_pregnancy/pp_development_content.dart']) {
        final live = File(f).readAsLinesSync().where((l) => !l.trimLeft().startsWith('//'));
        expect(live.any((l) => l.contains("'pp_section/parenting_safety'")), isFalse, reason: f);
      }
      // Traditions' festivals still link this door's festivals page.
      expect(_surfaces(ppSectionFor('parenting_traditional')!.pageById('first_festivals')!),
          contains('pp_page/parenting_safety/safety_festivals'));
    });

    testWidgets('SF7: the closing names a paediatrician', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await _pump(t, door, months: 18, tab: 'house');
      expect(find.byKey(const ValueKey('pp_door_closing_card')), findsOneWidget);
      expect(find.text('Talk to a paediatrician'), findsOneWidget);
      expect(door.closing!.surfaceId, 'pp_experts/Pediatrician');
    });

    test('SF8: the tab names', () {
      expect([for (final t in door.tabs) t.label],
          ['Around the house', 'Bath time and water', 'Travel and heat', 'First aid', 'My body is mine']);
    });
  });
}
