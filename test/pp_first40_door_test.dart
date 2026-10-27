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
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_inline_tools.dart';
import 'package:parentveda/screens/post_pregnancy/pp_din_by_din.dart';
import 'package:parentveda/screens/post_pregnancy/pp_learning_data.dart' show programById;
import 'package:parentveda/screens/post_pregnancy/pp_page_read.dart' show kPpPageReadPrefix;
import 'package:parentveda/services/pv_read_store.dart';

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

    test('the three scaffolds in the ledger, the two windows into You, and the vaccines pointer', () {
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final id in ['f40_small_or_early']) {
        expect(_page(id).comingSoon, isFalse, reason: '$id filled 2026-10-02');
        expect(ledger.contains(id), isTrue, reason: '$id is a coming-soon card nobody has logged as owed');
      }
      // Filled 2026-10-02 from the parenting gap analysis.
      for (final id in ['f40_for_husband', 'f40_ceremonies']) {
        expect(_page(id).comingSoon, isFalse, reason: id);
        expect(_page(id).blocks.first, isA<PpIntro>(), reason: id);
      }
      // Breasts and pregnant-again were scaffolds until the You brief made
      // You, Maa the one home; they open its pages now (pp_you_maa_door_test).
      expect(_page('f40_breasts').toolSurfaceId, startsWith('pp_page/parenting_maternal/'));
      expect(_page('f40_pregnant_again').toolSurfaceId, startsWith('pp_page/parenting_maternal/'));
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
      // Since 2026-10-21 (Wave 4) a later band is reachable, not hidden: the
      // 40-day page waits under "Coming up next", after her own rails. Was
      // findsNothing ('the 40-day mark and after').
      expect(find.text('You made it to 40 days. What now?'), findsOneWidget);
      expect(find.text('Coming up next'), findsOneWidget, reason: 'it is shown as what comes next, not as hers yet');
      expect(find.text('For your husband, in the first 40 days'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing, reason: 'every tab is for the whole forty days');
      expect(find.text('Consult'), findsNothing, reason: 'no closing card');
      final labels = [for (final t in door.tabs) t.label];
      // 2026-10-07: tab label now English (was 'Maa ki dekhbhaal').
      expect(labels[2], 'Your recovery');

      _ageDays(50);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(50), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('You made it to 40 days. What now?'), findsOneWidget);
      expect(find.text('Days 1 to 7: the first week'), findsNothing);
    });
  });

  // ===========================================================================
  //  Door plan 06 (`docs/pp-door-plans/06-first40.md`), built 2026-10-25.
  // ===========================================================================
  group('door 6: the plan, held', () {
    List<String> shelf(int day) => [for (final x in ppFirst40TodayPicks(day: day)) x.id];
    List<PpLink> links(String id) => _page(id).blocks.whereType<PpLink>().toList();
    String words(String id) => [
          for (final b in _page(id).blocks)
            switch (b) {
              PpIntro x => x.text,
              PpArticle x => [x.heading ?? '', ...x.paragraphs].join(' '),
              PpCards x => [x.heading ?? '', for (final c in x.cards) '${c.title} ${c.line}'].join(' '),
              PpCallout x => '${x.title ?? ''} ${x.text}',
              PpChartCard x => [x.title, for (final r in x.rows) '${r.$1} ${r.$2}'].join(' '),
              PpLink x => x.label,
              _ => '',
            },
        ].join(' ');

    test('FD1: a shelf of how-tos for her week, pages that exist, named whole', () {
      expect(shelf(1), kPpFirst40WeekCards[0].$2);
      expect(shelf(7), ['f40_skin_to_skin', 'f40_latch', 'f40_cord_care', 'f40_nappy_poop', 'f40_burping']);
      expect(shelf(8), ['f40_first_bath', 'f40_swaddle', 'f40_soothing', 'f40_day_night', 'f40_burping']);
      expect(shelf(20), shelf(8));
      expect(shelf(21), ['f40_malish', 'f40_jhula', 'f40_soothing', 'f40_skin_to_skin', 'f40_first_bath']);
      expect(shelf(40), shelf(21));
      expect(shelf(41), ['f40_malish', 'f40_soothing'], reason: 'then the card on to Play today');
      for (final (_, ids) in kPpFirst40WeekCards) {
        expect(ids.length, inInclusiveRange(4, 6));
        for (final id in ids) {
          expect(_f40.pageById(id), isNotNull, reason: id);
          final name = kPpFirst40CardNames[id]!;
          expect(name.endsWith('.') || name.endsWith('…'), isFalse, reason: name);
          expect(name.length, lessThanOrEqualTo(24), reason: '$name fits its card whole');
        }
      }
      expect(ppScreenForSurface(kPpFirst40PlayToday), isNotNull);
      expect([for (final t in door.tabs) if (t.inlineSurfaceId != null) t.id], ['din_by_din']);
    });

    testWidgets('FD1: day 3 opens on the Day card, then the first week\'s shelf', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageDays(2);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_din_today')), findsOneWidget);
      expect(find.text('Try this today'), findsOneWidget);
      for (final id in shelf(3)) {
        expect(find.byKey(ValueKey('pp_f40_today_card_$id')), findsOneWidget, reason: id);
      }
      expect(find.byKey(const ValueKey('pp_din_after')), findsNothing);
    });

    test('FD2: both warning lists are pinned, so they lead their rails read or not', () {
      for (final id in ['f40_red_flags', 'f40_recovery_red_flags']) {
        expect(_page(id).pinned, isTrue, reason: id);
        expect(ppIsRedFlagPage(_page(id)), isTrue, reason: id);
      }
      expect(_listed('rush_to_doctor').first, 'f40_red_flags');
    });

    testWidgets('FD2: Go now is still the first card on When to rush after she has read it', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageDays(12);
      PvReadStore.instance.setProgress('${kPpPageReadPrefix}parenting_first_40_f40_red_flags', 1.0);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, initialTabId: 'rush', onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      final flag = tester.getTopLeft(find.text('When to rush to the doctor').first).dx;
      final crying = tester.getTopLeft(find.text("When the crying won't stop").first).dx;
      expect(flag, lessThan(crying));
      PvReadStore.instance.setProgress('${kPpPageReadPrefix}parenting_first_40_f40_red_flags', 0);
    });

    test('FD3: from two months the door opens on her recovery; before, on Day by day', () {
      expect(door.tabOrder['jaapa_after']!.first, 'maa');
      expect(door.tabOrder.containsKey('jaapa_first_month'), isFalse);
      expect(door.tabOrder.containsKey('jaapa_forty'), isFalse);
      expect(ppDinAfter(kPpDinTabId, day: 40), isFalse);
      expect(ppDinAfter(kPpDinTabId, day: 41), isTrue);
      expect([for (final (_, s) in kPpDinOnward) s], [
        'pp_section/parenting_feeding', 'pp_section/parenting_sleep', 'pp_section/parenting_development',
      ]);
      for (final (_, s) in kPpDinOnward) {
        expect(ppScreenForSurface(s), isNotNull, reason: s);
      }
    });

    testWidgets('FD3: day 45 points onward; at 10 weeks the door opens on Your recovery', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageDays(44);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(44), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_din_after')), findsOneWidget);
      expect(find.text('Your forty days are done.'), findsOneWidget);
      for (final (name, _) in kPpDinOnward) {
        expect(find.byKey(ValueKey('pp_din_onward_$name')), findsOneWidget, reason: name);
      }
      expect(find.byKey(const ValueKey('pp_f40_today_play')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_din_today')), findsNothing);

      _ageDays(70);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(70), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('When to call your own doctor'), findsWidgets, reason: 'Your recovery is open');
      expect(find.text('Talk to a gynaecologist'), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_din_after')), findsNothing, reason: 'Day by day is one tab away');
    });

    testWidgets('FD7: no birthday saved asks for one instead of "Day 1 of 40"', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      ChildProfileStore.instance.resetForTest();
      expect(ppDinKnown(), isFalse);
      expect(ppDinToday(kPpDinTabId), isNull);
      expect(ppFirst40TodayPicks(), isEmpty);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey('none'), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_din_no_birthday')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_din_add_birthday')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_din_today')), findsNothing);
      expect(find.text('Try this today'), findsNothing);
      expect(find.textContaining('OF 40'), findsNothing);
      expect(find.text('Days 1 to 7: the first week'), findsOneWidget, reason: 'everything else stays readable');
    });

    test('FD4: links land where they say', () {
      const want = {
        'f40_day_night': 'pp_page/parenting_sleep/back_to_sleep',
        'f40_safe_sleep': 'pp_page/parenting_sleep/back_to_sleep',
        'f40_newborn_sleep': 'pp_page/parenting_sleep/back_to_sleep',
        'f40_not_yourself': 'pp_page/parenting_maternal/mind_blues_vs_ppd',
        'f40_forty_mark': 'pp_section/parenting_maternal/your_body',
        'f40_jaundice': 'pp_page/parenting_health/ill_jaundice',
        'f40_latch': 'pp_page/parenting_feeding/bf_latch',
        'f40_swaddle': 'pp_page/parenting_sleep/swaddling',
        'f40_malish': 'pp_page/parenting_sleep/malish',
        'f40_folk_practices': 'pp_page/parenting_traditional/newborn_customs',
      };
      for (final MapEntry(key: id, value: surface) in want.entries) {
        expect(links(id).map((l) => l.surfaceId), contains(surface), reason: id);
        expect(ppScreenForSurface(surface), isNotNull, reason: surface);
      }
      expect(links('f40_ceremonies').map((l) => l.surfaceId), containsAll([
        'pp_page/parenting_traditional/chatti', 'pp_page/parenting_traditional/namkaran',
      ]));
      for (final p in _f40.allPages) {
        for (final l in p.blocks.whereType<PpLink>()) {
          if (l.label.toLowerCase().contains('safe')) {
            expect(l.surfaceId, isNot('pp_sleep'), reason: '${p.id}: a safe-sleep link opened the tracker');
          }
        }
      }
      expect(links('f40_not_yourself').map((l) => l.surfaceId), isNot(contains('pp_you_maa')));
      expect(links('f40_forty_mark').map((l) => l.surfaceId), isNot(contains('pp_you_maa')));
      expect(words('f40_days_1_7').contains('section home'), isFalse);
      expect(links('f40_days_1_7').any((l) => l.pageId == 'f40_red_flags'), isTrue);
      // Free help, any hour, and no paid block on the mood page.
      expect(words('f40_not_yourself'), contains('Tele-MANAS, 14416'));
      expect(_page('f40_not_yourself').blocks.whereType<PpConsult>(), isEmpty);
    });

    test('FD5: one stocked shelf a thing, an honest notice for the oil and the belt', () {
      expect([for (final l in links('f40_what_you_need')) l.surfaceId], [
        'pp_products/pvs_muslin_swaddle_cloths',
        'pp_products/pvs_graded_flow_maternity_pads',
        'pp_products/pvs_absorbent_breast_pads',
        'pp_products/Underarm thermometers',
        'pp_products/pvs_smart_cribs_and_bassinets',
        'pp_products/pvs_ergonomic_peri_bottles',
      ]);
      for (final l in links('f40_what_you_need')) {
        if (l.surfaceId!.startsWith('pp_products/pvs_')) {
          expect(ppSurfaceUnavailable(l.surfaceId!), isNull, reason: '${l.surfaceId} is stocked');
        }
      }
      expect(links('f40_which_swaddle').map((l) => l.surfaceId), contains('pp_products/pvs_muslin_swaddle_cloths'));
      expect(ppSurfaceUnavailable('pp_products/Baby massage oils'),
          "We haven't picked oils yet. A plain, fragrance-free coconut or sunflower oil from your "
          "kitchen is fine. See 'Which massage oil?'.");
      expect(ppSurfaceUnavailable('pp_products/Postpartum belts'), contains('Ask your doctor first after a C-section'));
      expect(links('f40_malish').map((l) => l.surfaceId), contains('pp_products/Baby massage oils'));
      expect(links('f40_rest_and_food').map((l) => l.surfaceId), contains('pp_products/Postpartum belts'));
      for (final p in _f40.allPages) {
        for (final l in p.blocks.whereType<PpLink>()) {
          expect(l.surfaceId, isNot('pp_products'), reason: '${p.id}: the unfiltered shop');
          expect(l.surfaceId, isNot('pp_courses'), reason: '${p.id}: Learn home');
          if (ppIsRedFlagPage(p)) {
            expect(l.surfaceId ?? '', isNot(startsWith('pp_products')), reason: '${p.id}: no product near a red flag');
          }
        }
      }
    });

    test('FD6: experts on three tabs, none on When to rush, the jaundice consult, the real class', () {
      final byId = {for (final t in door.tabs) t.id: t};
      expect(byId['rush']!.expert, isNull);
      expect(byId['maa']!.expert!.surfaceId, 'pp_experts/Gynecologist');
      expect(byId['samjho']!.expert!.surfaceId, 'pp_experts/Pediatrician');
      expect(byId['feeding_rest']!.expert!.surfaceId, 'pp_experts/Lactation expert');
      expect(byId['din_by_din']!.expert, isNull);
      for (final t in door.tabs) {
        if (t.expert case final e?) {
          expect(ppScreenForSurface(e.surfaceId), isNotNull, reason: e.surfaceId);
        }
      }
      for (final areaId in byId['rush']!.areaIds) {
        for (final p in _area(areaId).pages) {
          expect(p.blocks.whereType<PpConsult>(), isEmpty, reason: '${p.id}: When to rush carries no pitch');
        }
      }
      final consult = _page('f40_jaundice').blocks.whereType<PpConsult>().single;
      expect(consult.role, 'pediatrician');
      expect(door.closing, isNull, reason: 'still no closing card');
      final course = words('f40_course');
      expect(links('f40_course').map((l) => l.surfaceId), contains('pp_learn/mc_first40'));
      expect(course, contains(programById('mc_first40').price.replaceAll('₹', 'Rs ')));
      expect(course, contains('80-minute'));
      for (final gone in ['1,499', '2,999', 'Hindi', 'free first lesson']) {
        expect(course.contains(gone), isFalse, reason: gone);
      }
    });

    test('FD8, FD9, FD11, R1, R3: the new copy, each clinical line marked for review', () {
      expect(words('f40_days_1_7'), allOf(contains('BCG'), contains('OPV-0'), contains('Hepatitis B')));
      expect(links('f40_days_1_7').map((l) => l.surfaceId), contains('pp_vaccines'));
      expect(words('f40_days_8_15'), allOf(contains('Register the birth'), contains('21 days')));
      expect(links('f40_days_8_15').map((l) => l.surfaceId), contains('pp_page/parenting_papers/pm_birth_certificate')); // final review item 6
      final rest = _page('f40_rest_and_food');
      expect(words('f40_rest_and_food'), allOf(contains('JSY'), contains('JSSK'), contains('PMMVY')));
      final rules = rest.blocks.whereType<PpCarousel>().single;
      expect(rules.coverTitle, 'The old rules for you');
      expect(rules.cards, hasLength(4));
      expect(rules.cards.every((c) => c.myth), isTrue, reason: 'myth versus evidence');
      expect(rest.blocks.whereType<PpVideoSlot>().map((v) => v.slotId), contains('first40/recovery_basics'));
      // FD11.
      expect(_listed('din_by_din'), contains('f40_what_he_sees'));
      expect(_page('f40_what_he_sees').bands, ['jaapa_first_month', 'jaapa_forty']);
      expect(words('f40_what_he_sees'), contains('20 to 30 cm'));
      // R1: one poo page for the whole first year.
      expect(words('f40_nappy_poop'), contains('After the first weeks, and after solids'));
      expect(_page('f40_nappy_poop').bands, isEmpty, reason: 'every band of the section');
      expect(links('f40_nappy_poop').map((l) => l.surfaceId), contains('pp_page/parenting_health/tummy_diarrhoea'));
      // R3: the oil, one source.
      final oil = _page('f40_which_oil').blocks.whereType<PpTable>().single;
      final mustard = oil.rows.firstWhere((r) => r.first == 'Mustard');
      expect(mustard.last, contains("mother's massage"));
      expect(oil.rows.any((r) => r.first == 'Sunflower'), isTrue);
      final src = File('lib/screens/post_pregnancy/pp_first40_content.dart').readAsStringSync();
      for (final mark in ['FD8. REQUIRED_REVIEW', 'FD8. Myth versus evidence, never mocking. REQUIRED_REVIEW',
          'FD8. REQUIRED_REVIEW (legal)', 'REQUIRED_REVIEW: the scheme names', 'REQUIRED_REVIEW: Tele-MANAS',
          'R3: added with the one-source pass. REQUIRED_REVIEW', 'REQUIRED_REVIEW (paediatrician): every line of this part',
          'REQUIRED_REVIEW (paediatrician): the 20 to 30 cm']) {
        expect(src.contains(mark), isTrue, reason: mark);
      }
    });
  });
}
