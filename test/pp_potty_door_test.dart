// =============================================================================
//  The Potty door, held against its brief and its plan
// -----------------------------------------------------------------------------
//  `Potty_Parenting.pdf` as assertions, then door plan 05
//  (`docs/pp-door-plans/05-potty.md`, built 2026-10-25) as "door 5: the plan,
//  held". What fails silently here: a tool, a quiz or a score appearing on a
//  section that refuses all three; the widened areas narrowing back,
//  stranding a five-year-old's mother; a parent of a baby landing on the
//  timeline again; the shelf drawn twice on one tab; a shop link on a worry
//  page; the Indian-toilet film going; the mug technique taught twice again.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_rail.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_inline_tools.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_potty_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

PpSection get _potty => ppSectionFor('parenting_potty')!;
PpArea _area(String id) => _potty.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _potty.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];
Iterable<PpLink> _links(String id) => _page(id).blocks.whereType<PpLink>();
String _text(String id) => [
      for (final b in _page(id).blocks) ...switch (b) {
        PpIntro(:final text) => [text],
        PpArticle(:final paragraphs) => paragraphs,
        PpCallout(:final text, :final title) => [text, ?title],
        PpCards(:final cards, :final heading) => [?heading, for (final c in cards) '${c.title} ${c.line}'],
        PpSteps(:final steps, :final heading) => [?heading, for (final s in steps) '${s.title} ${s.detail ?? ''}'],
        PpIndiaNote(:final text) => [text],
        _ => const <String>[],
      },
    ].join(' ');

const _badges = {
  'CHART-CARD', 'ARTICLE', 'SHORT ARTICLE', 'COMPARISON TABLE', 'STEP-LIST',
  'ACTIVITY', 'VIDEO', 'CARDS',
};

/// The shelf by stage, as `05-potty-content.md` Part A gives it.
const _shelf = {
  'su_su': {'cue_at_waking', 'nappy_off_time', 'say_it_as_it_happens'},
  'pt_1_2': {'choose_the_potty', 'pants_down_up', 'flush_and_wave', 'say_it_as_it_happens'},
  'pt_2_3': {'after_waking_sit', 'wash_low_tap', 'big_kid_pants_day', 'routine_chart', 'sit_and_read', 'teach_the_toy'},
  'pt_3_4': {'wiping_practice', 'last_wee_before_bed', 'spare_clothes_bag', 'teach_the_toy'},
  'pt_4_6': {'wiping_practice', 'public_toilet_run', 'last_wee_before_bed', 'spare_clothes_bag'},
};

/// A month in each band, and the tab that band opens on (PT1).
const _opens = {2: 'su_su', 15: 'starting_out', 30: 'starting_out', 40: 'bumpy', 54: 'bumpy'};

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

Future<void> _pump(WidgetTester t, PpDoor door, int months,
    {List<String>? opened, String? tab}) async {
  _ageMonths(months);
  t.view.physicalSize = const Size(1200, 9000);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
      home: PpDoorScreen(
          key: ValueKey('potty_${months}_$tab'),
          door: door,
          initialTabId: tab,
          onSurface: (_, id) => opened?.add(id))));
  await t.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_potty')!;
  PpDoorTab tab(String id) => door.tabs.firstWhere((t) => t.id == id);

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

    test('the timeline is the first tab in the door, pinned and for every stage', () {
      expect(door.tabs[0].areaIds, ['the_real_shape']);
      expect(door.tabs[2].areaIds.first, 'getting_ready');
      expect(_area('the_real_shape').bands, isEmpty, reason: 'all stages');
      expect(_listed('the_real_shape'), ['honest_timeline']);
      expect(_page('honest_timeline').format, 'CHART-CARD');
    });

    test('every built card survives, and the new ones sit where the plan puts them', () {
      expect(_listed('su_su_way'), [
        'what_is_su_su', 'reading_signals', 'grandmother_and_diapers', 'diaper_free_time',
        'cue_at_waking', 'nappy_off_time', 'su_su_poo',
      ]);
      expect(_listed('getting_ready'), ['readiness_signs', 'which_approach', 'no_star_charts']);
      expect(_listed('how_to_do_it'), [
        'introducing_potty', 'daily_routine', 'words_and_cues', 'indian_toilet', 'boys_and_girls', 'three_day_method', 'pull_ups',
      ]);
      expect(_listed('when_bumpy'), ['accidents_are_normal', 'regressions', 'withholding_constipation', 'potty_refusal', 'taking_longer']);
      expect(_listed('things_to_do'), hasLength(14), reason: 'the 3 activities and 11 of the 13 of PT3 (the baby two are su-su)');
      expect(_listed('staying_dry'), ['night_dryness', 'bedwetting', 'wiping_and_washing', 'school_and_public']);
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final id in ['no_star_charts', 'three_day_method', 'pull_ups', 'taking_longer']) {
        expect(_page(id).comingSoon, isFalse, reason: '$id filled 2026-10-02');
        expect(ledger.contains(id), isTrue, reason: '$id is on the ledger');
      }
    });

    test('the Indian toilet leads with its film, and the mug is taught once', () {
      final toilet = _page('indian_toilet');
      expect(toilet.format, 'VIDEO');
      expect(toilet.orderedBlocks.first, isA<PpVideoSlot>());
      expect((toilet.orderedBlocks.first as PpVideoSlot).slotId, 'potty/indian_toilet');
      expect(_links('wiping_and_washing').any((l) => l.pageId == 'indian_toilet'), isTrue,
          reason: 'the wiping page points at the film rather than repeating the technique');
    });

    test('the cross-links: rash pictures, constipation depth, a new baby', () {
      expect(_links('diaper_free_time').map((l) => l.surfaceId), contains('pp_page/parenting_health/skin_which_rash'));
      final hold = _links('withholding_constipation').map((l) => l.surfaceId);
      expect(hold, contains('pp_page/parenting_health/tummy_constipation'));
      expect(hold, contains('pp_what_changed'));
      final reg = _links('regressions').map((l) => l.surfaceId);
      expect(reg, isNot(contains('pp_section/parenting_behaviour')), reason: 'PT6: not the whole door');
      expect(reg, contains('pp_page/parenting_family/fam_sibling_jealousy'));
      expect(reg, isNot(contains('pp_page/parenting_development/dev_leaps_lens')), reason: 'the leaps are retired');
      for (final s in ['pp_page/parenting_health/skin_which_rash', 'pp_page/parenting_health/tummy_constipation',
          'pp_page/parenting_family/fam_sibling_jealousy']) {
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

    test('the section auto-scopes', () => expect(_potty.autoScope, isTrue));
  });

  group('door 5: the plan, held', () {
    test('PT2: five bands that meet, and pages banded where they name an age', () {
      expect([for (final b in kPpPottyBands.bands) (b.id, b.fromMonths, b.toMonths)], [
        ('su_su', 0, 12), ('pt_1_2', 12, 24), ('pt_2_3', 24, 36), ('pt_3_4', 36, 48), ('pt_4_6', 48, 72),
      ]);
      const fromOne = ['pt_1_2', 'pt_2_3', 'pt_3_4', 'pt_4_6'];
      for (final id in ['getting_ready', 'how_to_do_it', 'when_bumpy']) {
        expect(_area(id).bands, fromOne, reason: '$id stays widened to six');
      }
      expect(_area('su_su_way').bands, ['su_su']);
      expect(_area('staying_dry').bands, ['pt_3_4', 'pt_4_6']);
      // From one: an all-ages area would open Starting out for a baby.
      expect(_area('things_to_do').bands, fromOne);
      expect(_page('three_day_method').bands, ['pt_2_3', 'pt_3_4', 'pt_4_6']);
      expect(_page('bedwetting').bands, ['pt_4_6']);
      expect(_page('taking_longer').bands, ['pt_3_4', 'pt_4_6']);
    });

    test('PT1: the tab order for each stage', () {
      expect(door.tabOrder, {
        'su_su': ['su_su', 'how_long', 'starting_out', 'bumpy', 'dry'],
        'pt_1_2': ['starting_out', 'how_long', 'bumpy', 'dry'],
        'pt_2_3': ['starting_out', 'bumpy', 'how_long', 'dry'],
        'pt_3_4': ['bumpy', 'dry', 'starting_out', 'how_long'],
        'pt_4_6': ['bumpy', 'dry', 'starting_out', 'how_long'],
      });
      expect(door.tabOrder.keys.toSet(), {for (final b in kPpPottyBands.bands) b.id});
      // From two, day by day leads Starting out: the age rail is the whole area.
      expect(tab('starting_out').ageRail['pt_2_3']!.pageIds, _listed('how_to_do_it'));
    });

    test('PT3: the shelf is his stage\'s activities, all of them, timed and never scored', () {
      for (final MapEntry(key: band, value: ids) in _shelf.entries) {
        final picks = ppPottyTodayPicks(band: band);
        expect({for (final x in picks) x.id}, ids, reason: band);
        expect(picks.length, inInclusiveRange(3, 6));
        for (final x in picks) {
          expect(x.format, 'ACTIVITY', reason: x.id);
          expect(kPpPottyActivityTimes[x.id], isNotNull, reason: '${x.id} shows a time');
          expect(x.blocks.whereType<PpInteractive>(), isEmpty, reason: '${x.id}: nothing to tick');
          expect(x.blocks.whereType<PpWhenLine>(), hasLength(1), reason: x.id);
        }
      }
      // Every activity is on a shelf, and every time belongs to one.
      final all = {for (final s in _shelf.values) ...s};
      expect(all, {..._listed('things_to_do'), 'cue_at_waking', 'nappy_off_time'});
      expect(kPpPottyActivityTimes.keys.toSet(), all);
      // A fresh order each day, the same all day.
      final day = DateTime(2026, 10, 25, 8);
      expect([for (final x in ppPottyTodayPicks(band: 'pt_2_3', day: day)) x.id],
          [for (final x in ppPottyTodayPicks(band: 'pt_2_3', day: day.add(const Duration(hours: 12)))) x.id]);
      // No store behind it: the shelf keeps nothing.
      final src = File('lib/screens/post_pregnancy/doors/pp_door_inline_tools.dart').readAsStringSync();
      final shelf = src.substring(src.indexOf('Potty: "Try this today"'), src.indexOf('Development: "Play with him today"'));
      for (final w in ['SharedPreferences', 'notifyListeners', 'setState', 'Checkbox', 'Store.instance.mark']) {
        expect(shelf.contains(w), isFalse, reason: 'the shelf keeps no "$w"');
      }
    });

    test('PT3: the shelf draws on the tab his stage opens, and nowhere else', () {
      for (final b in kPpPottyBands.bands) {
        final hosts = [
          for (final t in door.tabs)
            if (t.inlineSurfaceId case final id? when ppPottyShelfShows(id, band: b.id)) t.id,
        ];
        expect(hosts, [door.tabOrder[b.id]!.first], reason: b.id);
      }
    });

    test('PT5: an expert on every worry tab, the right person, and they open', () {
      expect(tab('su_su').expert, isNull, reason: 'a light stage');
      expect(tab('how_long').expert, isNull);
      expect(tab('starting_out').expert!.surfaceId, 'pp_experts/Child psychologist');
      expect(tab('bumpy').expert!.surfaceId, 'pp_experts/Pediatrician');
      expect(tab('dry').expert!.surfaceId, 'pp_experts/Pediatrician');
      for (final t in door.tabs) {
        if (t.expert case final e?) {
          expect(ppSurfaceUnavailable(e.surfaceId), isNull, reason: t.id);
          expect(ppScreenForSurface(e.surfaceId), isNotNull, reason: t.id);
        }
      }
    });

    test('PT5: a consult on every doctor-flag page that lacked one, and no shop on any of them', () {
      for (final id in ['accidents_are_normal', 'potty_refusal', 'taking_longer', 'wiping_and_washing',
          'regressions', 'withholding_constipation', 'bedwetting']) {
        final c = _page(id).blocks.whereType<PpConsult>();
        expect(c, hasLength(1), reason: '$id: one pitch');
        expect(c.single.surface, 'pp_experts/Pediatrician', reason: id);
      }
      bool shop(PpLink l) => (l.surfaceId ?? '').startsWith('pp_products') || (l.surfaceId ?? '').startsWith('pp_books');
      for (final p in _potty.allPages) {
        final links = p.blocks.whereType<PpLink>();
        if (p.blocks.any((b) => b is PpConsult)) {
          expect(links.where(shop), isEmpty, reason: '${p.id} is a worry page');
        }
        expect(links.where((l) => (l.surfaceId ?? '').startsWith('pp_products')).length, lessThanOrEqualTo(1),
            reason: '${p.id}: one product a page');
        expect(links.any((l) => l.surfaceId == 'pp_products' || l.surfaceId == 'pp_courses'), isFalse,
            reason: '${p.id}: an unfiltered shop or Learn home is a dead end');
      }
      // The masterclass is a class by id, and says it isn't open (S8d).
      final master = _links('which_approach').single;
      expect(master.surfaceId, 'pp_class/potty_masterclass');
      expect(master.blurb!.toLowerCase(), isNot(contains('paid')), reason: 'no paid wording until it exists');
      expect(ppSurfaceUnavailable(master.surfaceId!), contains('Tell me'));
      // The parents' room, at the foot of Accidents.
      final room = _links('accidents_are_normal').singleWhere((l) => l.surfaceId == 'pp_community/potty');
      expect(ppScreenForSurface(room.surfaceId!), isNotNull);
    });

    test('PT4: things to buy next to the step, each tap honest (S8c)', () {
      expect(_links('introducing_potty').map((l) => l.surfaceId), containsAll(['pp_products/Potties', 'pp_product_guide/Potties']));
      expect(_links('indian_toilet').map((l) => l.surfaceId), contains('pp_products/Travel potties'));
      expect(_links('night_dryness').map((l) => l.surfaceId), contains('pp_products/Baby Dry Sheets'));
      expect(_links('sit_and_read').map((l) => l.surfaceId), contains('pp_books/Potty'));
      expect(ppSurfaceUnavailable('pp_products/Potties'), contains('wide, stable base'));
      expect(ppSurfaceUnavailable('pp_products/Travel potties'), contains('folding'));
      expect(ppSurfaceUnavailable('pp_product_guide/Potties'), contains('on this page'));
      // PT13 (door 9 build): the books open on their own shelf. Was the toast
      // naming two from the list, kept for revert:
      // expect(ppSurfaceUnavailable('pp_books/Potty'), contains('Once Upon a Potty'));
      expect(ppSurfaceUnavailable('pp_books/Potty'), isNull);
      expect(ppScreenForSurface('pp_books/Potty'), isNotNull);
    });

    test('PT6: the content changes', () {
      // pull_ups rewritten, not thin.
      expect(_page('pull_ups').title, 'Pull-ups, cloth pants or a chaddi?');
      expect(_text('pull_ups').length, greaterThan(800), reason: 'was about 570');
      expect(_text('pull_ups'), allOf(contains('Cotton chaddi'), contains('Cloth trainer pants')));
      // night_dryness: a doctor line, bedwetting linked, the timeline once.
      final night = _page('night_dryness');
      expect(night.blocks.whereType<PpCallout>().where((c) => c.kind == PpCalloutKind.doctor), hasLength(1));
      expect(_links('night_dryness').map((l) => l.pageId), containsAll(['bedwetting', 'honest_timeline', 'no_star_charts']));
      expect(night.blocks.whereType<PpChartCard>(), isEmpty, reason: 'the timeline lives on honest_timeline');
      // indian_toilet: the doctor callout, all three washing tools.
      expect(_page('indian_toilet').blocks.whereType<PpCallout>().any((c) => c.kind == PpCalloutKind.doctor), isTrue);
      expect(_text('indian_toilet'), allOf(contains('health faucet'), contains('lota'), contains('bucket')));
      // bedwetting: named once, the alarm and the medicine, a doctor's choice.
      expect(_text('bedwetting'), allOf(contains('enuresis'), contains('alarm'), contains('desmopressin'), contains('chemist')));
      expect(_text('withholding_constipation'), contains('encopresis'));
      expect(_text('wiping_and_washing'), contains('pinworms'));
      expect(_text('school_and_public'), contains('is he toilet trained?'));
      expect(_links('what_is_su_su').map((l) => l.pageId), contains('reading_signals'));
      expect(_text('what_is_su_su'), isNot(contains('Read next')));
      // One source for the no-stars message.
      for (final id in ['daily_routine', 'routine_chart', 'night_dryness']) {
        expect(_links(id).map((l) => l.pageId), contains('no_star_charts'), reason: id);
      }
      // Every clinical addition is marked for the paediatrician's read.
      final src = File('lib/screens/post_pregnancy/pp_potty_content.dart').readAsStringSync();
      for (final w in ['enuresis', 'encopresis', 'It may be pinworms', 'When wet nights need a doctor', 'travel constipation needs a doctor']) {
        final at = src.indexOf(w);
        expect(at, greaterThan(-1), reason: w);
        expect(src.substring((at - 900).clamp(0, at), at).contains('REQUIRED_REVIEW'), isTrue, reason: w);
      }
    });

    test('PT7: the eight films stay, and the three shelf demos are slotted', () {
      final slots = {
        for (final p in _potty.allPages)
          for (final b in p.blocks.whereType<PpVideoSlot>()) b.slotId,
      };
      expect(slots, containsAll([
        'potty/real_timeline', 'potty/su_su_cue_demo', 'potty/readiness_signs', 'potty/routine_walkthrough',
        'potty/indian_toilet', 'potty/calm_through_accidents', 'potty/activities_together', 'potty/night_dryness',
        'potty/after_waking_sit', 'potty/hand_washing_low_tap', 'potty/seat_and_stool',
      ]));
    });

    test('PT11: the su-su tab opens First 40\'s poo page itself', () {
      final poo = _page('su_su_poo');
      expect(poo.toolSurfaceId, 'pp_page/parenting_first_40/f40_nappy_poop');
      expect(ppScreenForSurface(poo.toolSurfaceId!), isNotNull);
    });
  });

  group('on screen', () {
    testWidgets('every stage opens on its tab, on Try this today, with his activities', (t) async {
      for (final MapEntry(key: m, value: opens) in _opens.entries) {
        await _pump(t, door, m);
        final band = kPpPottyBands.active.id;
        expect(find.descendant(of: find.byKey(pvDoorRailCardKey(0)), matching: find.text(tab(opens).label)),
            findsOneWidget, reason: '$m months opens on $opens');
        expect(find.byKey(const ValueKey('pp_potty_today_shelf')), findsOneWidget, reason: '$m');
        for (final id in _shelf[band]!) {
          expect(find.byKey(ValueKey('pp_potty_today_card_$id')), findsOneWidget, reason: '$m: $id');
          // Never drawn twice on one tab: the rail skips the shelf.
          expect(find.text(_page(id).title), findsOneWidget, reason: '$m: ${_page(id).title} once');
        }
        expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
        expect(t.takeException(), isNull);
      }
    });

    testWidgets('a card opens its page in the reader', (t) async {
      await _pump(t, door, 30);
      final first = ppPottyTodayPicks().first;
      await t.tap(find.byKey(ValueKey('pp_potty_today_card_${first.id}')));
      await t.pumpAndSettle();
      expect(find.byType(PpDoorScreen), findsNothing, reason: 'the reader is on top');
      expect(find.text(first.title), findsWidgets);
    });

    testWidgets('the shelf is on the opening tab only; another tab is its rails', (t) async {
      await _pump(t, door, 30, tab: 'bumpy');
      expect(find.byKey(const ValueKey('pp_potty_today_shelf')), findsNothing);
      expect(find.text('Holding it in'), findsOneWidget);
      // At three, Starting out keeps the activities as a rail for a late starter.
      await _pump(t, door, 40, tab: 'starting_out');
      expect(find.byKey(const ValueKey('pp_potty_today_shelf')), findsNothing);
      expect(find.text('Things to do together'), findsOneWidget);
    });

    // Step 0 · S9 (2026-10-25): no tab locks; later tabs say "For later".
    testWidgets('a baby\'s parent: two tabs for now, three for later; a toddler\'s: su-su gone, dry nights for later', (t) async {
      await _pump(t, door, 4);
      expect(find.text('Try this today'), findsOneWidget);
      expect(find.text('For later'), findsNWidgets(3), reason: 'Starting out, Accidents, Dry nights');
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      expect(find.byKey(const ValueKey('pp_door_closing_card')), findsOneWidget, reason: 'no expert on su-su');

      await _pump(t, door, 24, tab: 'starting_out');
      expect(find.text('Catching the wee early'), findsNothing, reason: 'grown past');
      expect(find.text('Signs your child is ready'), findsOneWidget);
      expect(find.text('For later'), findsOneWidget, reason: 'Dry nights');
      expect(find.byKey(const ValueKey('pp_door_tab_expert')), findsOneWidget);

      await _pump(t, door, 50, tab: 'bumpy');
      expect(find.text('Holding it in'), findsOneWidget, reason: 'a four-year-old\'s mother reaches the withholding page');
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });

    testWidgets('PT8: a link into a later tab opens it with the "for later" line', (t) async {
      // Home's "Start and manage potty training" names Starting out.
      await _pump(t, door, 4, tab: door.tabFor('how_to_do_it')!.id);
      expect(find.textContaining('For later. This usually starts from 1 year'), findsOneWidget);
      expect(find.text('Introducing the potty'), findsOneWidget);
    });
  });
}
