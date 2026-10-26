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
import 'package:parentveda/data/mind_mood_data.dart' show kCrisisHelplineName, kCrisisHelplineNumber;
import 'package:parentveda/widgets/pv_placeholders.dart';
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
      // All eight written 2026-10-02 (parenting gap analysis); skip_it and
      // mother_kept_apart await the user's tone sign-off, per the ledger.
      // TR-Q (door 10): the text was approved 2026-10-25 with two changes,
      // both made; the read on the phone is still owed, so the list stays.
      for (final id in soon) {
        expect(_page(id).comingSoon, isFalse, reason: id);
        expect(_page(id).blocks, isNotEmpty, reason: id);
        expect(ledger.contains(id), isTrue, reason: '$id stays in the ledger');
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
      // TR4: Feeding's first-foods page, not the whole door (was 'pp_feeding').
      expect(_links(_page('annaprashan_food')).map((l) => l.surfaceId),
          containsAll(['pp_page/parenting_feeding/solids_first_foods', 'pp_food']));
    });
  });

  group('the age rule', () {
    // TR1 (door 10): every ceremony page carries its age now; the areas stay
    // for every age. Was "only coming-up is banded", every other page
    // untagged, kept for revert in git.
    test('the section auto-scopes; the areas stay for every age', () {
      expect(_tr.autoScope, isTrue);
      for (final a in _tr.areas.where((a) => a.id != 'whats_now')) {
        expect(a.bands, isEmpty, reason: '${a.id} is for every age, so no tab locks');
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
      // 2026-10-07: title now English (was 'Coming up: birthday, mundan, ears').
      expect(find.text('Coming up: birthday, first head shaving, ears'), findsNothing);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      expect(find.text('Find a name'), findsOneWidget);
      expect(find.text('Consult'), findsNothing);

      _ageMonths(24);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(24), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Coming up: birthday, first head shaving, ears'), findsOneWidget);
      expect(find.text('The first months, in order'), findsNothing);

      // TR1: the newborn welcomes fold under "Earlier" at two; the every-age
      // faith pages still show in full. Was: aqiqah shown in full at 24
      // months ("every-age areas show in full").
      _ageMonths(24);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey('faiths'), door: door, onSurface: (_, _) {}, initialTabId: 'faiths')));
      await tester.pumpAndSettle();
      expect(find.text('Aqiqah, and naming in a Muslim family'), findsNothing, reason: 'folded under Earlier');
      expect(find.byKey(const ValueKey('pp_door_band_fold_newborn')), findsOneWidget);
      expect(find.text('The Sikh naming (Naam Karan), and uncut hair'), findsWidgets, reason: 'an every-age faith page shows');
    });
  });

  // ===========================================================================
  //  Door 10: the plan (`docs/pp-door-plans/10-traditions.md`), held
  // ===========================================================================
  group('door 10: the plan, held', () {
    Iterable<String?> surfaces(PpPage p) => _links(p).map((l) => l.surfaceId);
    String text(PpPage p) => [
          for (final b in p.blocks)
            if (b is PpIntro) b.text
            else if (b is PpArticle) ...[if (b.heading != null) b.heading!, ...b.paragraphs]
            else if (b is PpCards) ...[if (b.heading != null) b.heading!, for (final c in b.cards) '${c.title} ${c.line}']
            else if (b is PpCallout) '${b.title ?? ''} ${b.text}'
            else if (b is PpIndiaNote) b.text
            else if (b is PpChartCard) ...[for (final r in b.rows) '${r.$1} ${r.$2}', b.note ?? '']
            else if (b is PpScript) for (final l in b.lines) l.say,
        ].join(' ');

    test('TR1: every page\'s age, as the content file\'s §7 table', () {
      const tags = {
        'chatti': ['newborn'], 'namkaran': ['newborn'], 'jhula': ['newborn'], 'nishkramana': ['newborn'],
        'aqiqah': ['newborn'], 'tahneek': ['newborn'], 'christening': ['newborn'],
        'annaprashan': ['half_year'], 'annaprashan_food': ['half_year'],
        'mundan': ['half_year', 'first_years'], 'karnavedha': ['half_year', 'first_years'],
        'first_birthday': ['half_year', 'first_years'],
        'aksharabhyasam': ['first_years', 'older'],
        'now_newborn': ['newborn'], 'now_half_year': ['half_year'],
        'now_first_years': ['first_years'], 'now_older': ['older'],
      };
      for (final p in _tr.allPages) {
        // A new page fails here until it has a row: every age is a choice.
        expect(p.bands, tags[p.id] ?? isEmpty, reason: p.id);
      }
      // A page is never tagged outside its own area's ages (door 8).
      final bandIds = {for (final b in _tr.bandSet!.bands) b.id};
      for (final a in _tr.areas) {
        final areaBands = a.bands.isEmpty ? bandIds : a.bands.toSet();
        for (final p in a.pages) {
          expect(areaBands.containsAll(p.bands), isTrue, reason: '${a.id}/${p.id}');
        }
      }
    });

    test('TR1: the tab order for every age, Coming up now first', () {
      expect(door.tabOrder, {
        'newborn': ['coming_up', 'welcome', 'faiths', 'first_years', 'small_safe'],
        'half_year': ['coming_up', 'first_years', 'small_safe', 'faiths', 'welcome'],
        'first_years': ['coming_up', 'first_years', 'small_safe', 'faiths', 'welcome'],
        'older': ['coming_up', 'small_safe', 'first_years', 'faiths', 'welcome'],
      });
      expect(door.tabOrder.keys.toSet(), {for (final b in _tr.bandSet!.bands) b.id});
    });

    test('TR1/TR5: the 3 to 6 chart ends at six; Navjote and Dastar Bandi on the line under it', () {
      final chart = _page('now_older').blocks.whereType<PpChartCard>().single;
      expect(chart.rows.map((r) => r.$2).join(' '), isNot(contains('Navjote')));
      expect(chart.rows.map((r) => r.$2).join(' '), isNot(contains('Dastar')));
      expect(chart.note, startsWith('Later, at about 7 to 11: Navjote for Parsi children, Dastar Bandi for Sikh boys.'));
    });

    test('TR2: the jhula says what Sleep says, and the three jhula pages link each other', () {
      final all = [for (final p in _tr.allPages) text(p)].join(' ');
      expect(all, isNot(contains('as good a place to sleep')));
      expect(all, isNot(contains('cosleeping')), reason: 'Sleep\'s bed-sharing page owns it');
      expect(text(_page('jhula')), contains('Once your baby is deeply asleep and you\'re leaving the room'));
      expect(text(_page('jhula')), contains('a cot, a bassinet or a firm mattress on the floor'));
      expect(text(_page('newborn_customs')), contains('rocking in the jhula while you\'re with your baby'));
      final sleep = ppSectionFor('parenting_sleep')!.pageById('jhula_safety')!;
      final f40 = ppSectionFor('parenting_first_40')!.pageById('f40_jhula')!;
      expect(surfaces(_page('jhula')),
          containsAll(['pp_page/parenting_sleep/jhula_safety', 'pp_page/parenting_first_40/f40_jhula']));
      expect(surfaces(sleep),
          containsAll(['pp_page/parenting_traditional/jhula', 'pp_page/parenting_first_40/f40_jhula']));
      expect(surfaces(f40),
          containsAll(['pp_page/parenting_sleep/jhula_safety', 'pp_page/parenting_traditional/jhula']));
      final src = File('lib/screens/post_pregnancy/pp_traditions_content.dart').readAsStringSync();
      expect(src, contains('REQUIRED_REVIEW: the same paediatrician who reads Sleep\'s jhula'));
    });

    test('TR3: malish and the oil, with the one oil page and both how-tos', () {
      final p = _page('newborn_customs');
      final malish = p.blocks.whereType<PpCards>().singleWhere((c) => c.heading == 'Malish and the oil');
      final words = malish.cards.map((c) => '${c.title} ${c.line}').join(' ');
      expect(words, contains('Mustard oil is best kept off a newborn\'s skin'));
      expect(words, contains('cold-pressed coconut or sunflower oil'));
      expect(words, contains('Never in the ears, nose or eyes'));
      expect(words, contains('never on the stove'));
      // The oil comparison lives once, on First 40 (FD12), and says the same.
      final oil = ppSectionFor('parenting_first_40')!.pageById('f40_which_oil')!;
      final mustard = oil.blocks.whereType<PpTable>().first.rows.singleWhere((r) => r.first == 'Mustard');
      expect(mustard.last, contains('Best kept off a newborn\'s skin'));
      for (final target in const [
        'pp_page/parenting_first_40/f40_which_oil',
        'pp_page/parenting_sleep/malish',
        'pp_page/parenting_first_40/f40_malish',
      ]) {
        expect(surfaces(p), contains(target));
        expect(ppScreenForSurface(target), isNotNull, reason: target);
      }
    });

    test('TR4: the links land on the exact page, and the twins link back', () {
      const exact = {
        'namkaran': ['pp_page/parenting_papers/pm_birth_certificate', 'pp_page/parenting_first_40/f40_ceremonies'],
        'chatti': ['pp_page/parenting_first_40/f40_ceremonies'],
        'newborn_customs': ['pp_page/parenting_first_40/f40_folk_practices'],
        'now_half_year': ['pp_page/parenting_feeding/solids_first_foods'],
        'annaprashan': ['pp_page/parenting_feeding/solids_first_foods'],
        'annaprashan_food': ['pp_page/parenting_feeding/solids_first_foods'],
      };
      for (final MapEntry(key: id, value: targets) in exact.entries) {
        for (final target in targets) {
          expect(surfaces(_page(id)), contains(target), reason: id);
          expect(ppScreenForSurface(target), isNotNull, reason: target);
        }
      }
      // First 40's twins link back.
      final f40 = ppSectionFor('parenting_first_40')!;
      expect(surfaces(f40.pageById('f40_ceremonies')!), containsAll([
        'pp_page/parenting_traditional/chatti', 'pp_page/parenting_traditional/namkaran']));
      expect(surfaces(f40.pageById('f40_folk_practices')!), contains('pp_page/parenting_traditional/newborn_customs'));
      // No link opens the whole Feeding door or the unfiltered shop.
      for (final p in _tr.allPages) {
        expect(surfaces(p), isNot(contains('pp_feeding')), reason: p.id);
        expect(surfaces(p), isNot(contains('pp_products')), reason: '${p.id}: the whole shop');
      }
      // The one shop link left is a stocked shelf, the clothes for the day.
      final shop = [
        for (final p in _tr.allPages)
          for (final s in surfaces(p))
            if (s != null && s.startsWith('pp_products/')) s,
      ];
      expect(shop, ['pp_products/pvs_organic_cotton_onesies']);
      expect(ppSurfaceUnavailable(shop.single), isNull, reason: 'stocked');
      // The gentle festival list still links Safety's festivals page.
      expect(surfaces(_page('first_festivals')), contains('pp_page/parenting_safety/safety_festivals'));
    });

    test('TR5: the festivals, the Buddhist welcome, the regional line', () {
      final fest = _page('first_festivals').blocks.whereType<PpCards>().single.cards;
      final byTitle = {for (final c in fest) c.title: c.line};
      expect(byTitle['Holi'], contains('rinse with clean running water for several minutes'));
      expect(byTitle['Holi'], contains('See a doctor if the eye stays red or painful'));
      expect(byTitle['Makar Sankranti and kites'], contains('Keep small children off rooftops while kites fly'));
      expect(byTitle['Lohri and bonfires'], contains('well back and held'));
      expect(byTitle['Ramzan while breastfeeding'], contains('Talk to your doctor first'));
      expect(byTitle['Ramzan while breastfeeding'], contains('wet nappies drop'));
      expect(_page('jain_parsi').title, 'Jain, Parsi and Buddhist welcomes');
      expect(_page('jain_parsi').blocks.whereType<PpArticle>().map((a) => a.heading), contains('A Buddhist welcome'));
      expect(text(_page('how_date_chosen')),
          contains('Families from Odisha, Assam, Kashmir, Sindh, the Konkan coast'));
      final src = File('lib/screens/post_pregnancy/pp_traditions_content.dart').readAsStringSync();
      expect(src, contains('REQUIRED_REVIEW by a member of the community'));
      expect(src, contains('REQUIRED_REVIEW: Holi colour'));
    });

    test('TR6: the tool name, the thin page, the films', () {
      expect(door.tabs.last.tools.single.label, 'Home remedies, checked');
      // The user's word, 2026-10-26: was 'The first years'.
      expect(door.tabs.firstWhere((t) => t.id == 'first_years').label, 'The big firsts');
      expect(_tr.tools.map((t) => t.label), contains('Home remedies, checked'));
      final p = _page('someone_elses_ceremony');
      expect(p.blocks.whereType<PpCards>().map((c) => c.heading), containsAll([
        'If you\'re bringing your own baby', 'Feeding the new baby',
        'Smoke, crackers and the fire ritual (havan)', 'Leaving']));
      expect(text(p).length, greaterThan(1200), reason: 'was about 660 characters');
      final films = [for (final page in _tr.allPages) ...page.blocks.whereType<PpVideoSlot>()];
      expect(films, hasLength(17), reason: 'the slots stay; no intro until a film exists (S4)');
      for (final f in films) {
        expect(f.slotId, startsWith('traditions/'));
      }
    });

    testWidgets('TR6: a film says it is still being made', (t) async {
      final film = _page('jhula').blocks.whereType<PpVideoSlot>().single;
      await t.pumpWidget(MaterialApp(
          home: Scaffold(body: Center(child: SizedBox(width: 320, child: PpBlockView(block: film))))));
      await t.tap(find.byType(PvVideoPlaceholder));
      await t.pump();
      expect(find.text(kPvFilmPendingNote), findsOneWidget);
      await t.pump(const Duration(seconds: 6));
      await t.pumpAndSettle();
    });

    test('TR-Q: the user\'s two changes, and the helpline its own card', () {
      final p = _page('mother_kept_apart');
      expect(p.blocks.whereType<PpScript>().single.lines.single.say,
          contains('Can my husband or my mother sit with me and the baby in the evenings?'));
      final callouts = p.blocks.whereType<PpCallout>().toList();
      final doctor = callouts.singleWhere((c) => c.kind == PpCalloutKind.doctor);
      expect(doctor.text, isNot(contains(kCrisisHelplineNumber)), reason: 'never inside the doctor box');
      final help = callouts.singleWhere((c) => c.text.contains(kCrisisHelplineNumber));
      expect(help.kind, isNot(PpCalloutKind.doctor));
      expect(help.text, startsWith('Free, any hour: $kCrisisHelplineName, $kCrisisHelplineNumber.'));
      // The tone pages are not ours to change: skip_it as it stood.
      expect(_page('skip_it').blocks.whereType<PpIntro>().single.text,
          startsWith('Some families choose not to hold a naming'));
    });

    testWidgets('first view at 1, 8, 24 and 48 months: the opening tab and its first page', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      const firsts = {
        1: 'The first months, in order',
        8: 'Coming up: the first solid meal',
        24: 'Coming up: birthday, first head shaving, ears',
        48: 'Coming up: the start of learning',
      };
      for (final MapEntry(key: m, value: chart) in firsts.entries) {
        _ageMonths(m);
        await t.pumpWidget(MaterialApp(home: PpDoorScreen(key: ValueKey(m), door: door, onSurface: (_, _) {})));
        await t.pumpAndSettle();
        expect(find.text(chart), findsOneWidget, reason: '$m months');
      }
    });

    testWidgets('at 48 months the newborn ceremonies fold under Earlier; at one month they lead', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      _ageMonths(48);
      await t.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey('w48'), door: door, onSurface: (_, _) {}, initialTabId: 'welcome')));
      await t.pumpAndSettle();
      expect(find.text('The sixth-day welcome (chatti)'), findsNothing, reason: 'folded');
      expect(find.byKey(const ValueKey('pp_door_band_fold_newborn')), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('pp_door_band_fold_newborn')));
      await t.pumpAndSettle();
      expect(find.text('The sixth-day welcome (chatti)'), findsOneWidget, reason: 'never hidden');

      _ageMonths(1);
      await t.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey('w1'), door: door, onSurface: (_, _) {}, initialTabId: 'welcome')));
      await t.pumpAndSettle();
      expect(find.text('The sixth-day welcome (chatti)'), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_door_band_fold_newborn')), findsNothing);
    });
  });
}
