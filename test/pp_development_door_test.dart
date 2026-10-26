// =============================================================================
//  The Development door, held against its brief and its door plan
// -----------------------------------------------------------------------------
//  `Development_Parenting.pdf` (31 Aug 2026) as assertions, and since
//  2026-10-25 door plan `docs/pp-door-plans/04-development.md` (DV1 to DV10)
//  as well ("door 4: the plan, held"). What fails silently here: a second
//  tracker coming back; the calendar printing a date again; "Sit, crawl,
//  walk" still on the selector for a three-year-old; the activities slipping
//  back behind a card; an age band with a thin shelf; a link that reopens the
//  door; a toy on a worry page.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/data/products/sheet/toys.dart';
import 'package:parentveda/screens/doors/pv_door_rail.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_inline_tools.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/learning_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/leap_calendar_screen.dart';
import 'package:parentveda/screens/post_pregnancy/milestone_journey_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_milestones_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_milestones_screen.dart';
import 'package:parentveda/screens/post_pregnancy/phase_map_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_leaps_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/services/family_profile.dart';

PpSection get _dev => ppSectionFor('parenting_development')!;
PpArea _area(String id) => _dev.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _dev.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];
List<PpLink> _links(PpPage p) => p.blocks.whereType<PpLink>().toList();

const _badges = {
  'ARTICLE', 'SHORT ARTICLE', 'FLAGGED CALLOUT', 'CHART', 'STEP-LIST', 'CARDS',
  'VIDEO',
};

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

String _live(String path) => File(path)
    .readAsLinesSync()
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

Future<void> _pump(WidgetTester t, PpDoor door, int months,
    {List<String>? opened, String? tab}) async {
  _ageMonths(months);
  t.view.physicalSize = const Size(1200, 9000);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
      home: PpDoorScreen(
          key: ValueKey('dev_${months}_$tab'),
          door: door,
          initialTabId: tab,
          onSurface: (_, id) => opened?.add(id))));
  await t.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_development')!;
  PpDoorTab tab(String id) => door.tabs.firstWhere((t) => t.id == id);

  group('the map', () {
    test('four tabs, play first, and every area placed', () {
      expect([for (final t in door.tabs) t.id],
          ['what_to_do', 'on_track', 'when_will', 'talking']);
      expect([for (final t in door.tabs) t.label],
          // 'On track' became 'Milestones' (R10, 2026-10-26); the id stays.
          ['Play today', 'Milestones', 'Sit, crawl, walk', 'Talking']);
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _dev.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(door.hiddenAreaIds, isEmpty);
      for (final t in door.tabs) {
        expect(t.redFlagPageId, isNull, reason: 'no red-flag tab, by design');
      }
    });

    test('on track: the reassurance pages, the tracker, the check-in, then phases and what changed', () {
      expect(_listed('on_track'),
          ['dev_range_is_wide', 'dev_worth_checking', 'dev_movement_signs', 'dev_born_early']);
      expect(_page('dev_worth_checking').format, 'FLAGGED CALLOUT');
      expect(_page('dev_born_early').bands, isNot(contains('dev_2_3')), reason: 'only up to two years');
      final t = tab('on_track');
      expect(t.areaIds, ['on_track', 'age_by_age']);
      expect(t.tools.map((x) => x.surfaceId),
          ['pp_month_checklist', 'pp_milestones', 'pp_dev_checkin', 'pp_leaps', 'pp_what_changed']);
      // Read, then the tool for it: the user's call, 2026-09-13.
      expect(t.tools[1].afterPageId, 'dev_range_is_wide');
      expect(t.tools[2].afterPageId, 'dev_worth_checking');
      // The two tools from the retired tabs come after the reads (DV1).
      expect(t.tools[3].atEnd && t.tools[4].atEnd, isTrue);
      expect(t.footer, contains('not one your child has missed'));
      expect(ppScreenForSurface('pp_leaps'), isA<PhaseMapScreen>());
    });

    test('sit, crawl, walk: the eight reads, and the tab drops away after two', () {
      expect(_listed('when_will'), [
        'dev_rolling', 'dev_sitting', 'dev_crawling', 'dev_standing', 'dev_walking',
        'dev_gestures', 'dev_first_words', 'dev_self_feeding',
      ]);
      expect(tab('when_will').toMonths, 24);
      final walking = _page('dev_walking');
      expect(walking.blocks.whereType<PpCallout>().any((c) => c.title?.contains('walkers') ?? false), isTrue,
          reason: 'the no-baby-walkers note stays');
      for (final id in ['dev_crawling', 'dev_walking', 'dev_first_words']) {
        expect(_page(id).blocks.whereType<PpVideoSlot>(), isNotEmpty, reason: '$id has its film');
      }
    });

    test('talking: chart, two languages, how to help, the flagged callout', () {
      expect(_listed('speech_language'),
          ['dev_speech_by_age', 'dev_two_languages', 'dev_help_talk', 'dev_speech_flags']);
      expect(_page('dev_speech_by_age').format, 'CHART');
      expect(_page('dev_speech_flags').format, 'FLAGGED CALLOUT');
    });

    test('play today: the shelf in place, tummy time for the first year, the play reads', () {
      final t = tab('what_to_do');
      expect(t.areaIds, ['help_develop', 'feelings_play']);
      expect(t.inlineSurfaceId, kPpPlayTodayShelf);
      // The activities card became the shelf (D2).
      expect(t.tools.map((x) => x.surfaceId), ['pp_tummy_time']);
      expect(t.tools.single.bands, ['dev_0_6', 'dev_6_12']);
      expect(_listed('help_develop'), [
        'dev_play_builds_brain', 'dev_tummy_time', 'dev_everyday_play', 'dev_sensory_play',
        'dev_leaps_lens', // back, as phases (DV8)
      ]);
      final tummy = _page('dev_tummy_time');
      expect(tummy.format, 'VIDEO');
      expect(tummy.orderedBlocks.first, isA<PpVideoSlot>());
      expect(tummy.blocks.whereType<PpSteps>().single.steps, hasLength(6), reason: 'the steps stay under the film');
      final feelings = _page('dev_feelings_activities');
      expect(feelings.comingSoon, isFalse, reason: 'filled 2026-10-02');
    });

    test('every listed page wears a badge from the vocabulary', () {
      for (final p in _dev.allPages) {
        expect(_badges, contains(p.format), reason: '${p.id}: "${p.format}"');
      }
    });
  });

  group('single source', () {
    test('one tracker: both ids open the journey', () {
      // The one Milestones place since R10 (2026-10-26); was the journey.
      expect(ppScreenForSurface('pp_on_track'), isA<PpMilestonesScreen>());
      expect(ppScreenForSurface('pp_milestones'), isA<PpMilestonesScreen>());
      expect(ppScreenForSurface('pp_dev_checkin'), isNotNull);
      expect(_dev.tools.where((t) => t.surfaceId == 'pp_on_track'), isEmpty);
    });

    test('the calendar prints ages, never dates', () {
      for (final l in kLeaps) {
        expect(l.aroundLabel, startsWith('around '), reason: l.name);
        expect(RegExp(r'^around \d+(\.5)? to \d+(\.5)? (weeks|months)$').hasMatch(l.aroundLabel), isTrue, reason: l.aroundLabel);
      }
      final live = _live('lib/screens/post_pregnancy/leap_calendar_screen.dart');
      expect(live.contains('_fmt('), isFalse, reason: 'no date formatting on the live calendar');
      expect(live.contains('right now'), isFalse, reason: '"is in ... right now" became "may be in ... around now"');
    });

    test('every coming-soon scaffold is in the owed ledger', () {
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final p in _dev.allPages.where((p) => p.comingSoon)) {
        expect(ledger.contains(p.id), isTrue, reason: '${p.id} is a coming-soon card nobody has logged as owed');
      }
    });
  });

  group('door 4: the plan, held', () {
    tearDown(() => FamilyProfileStore.instance.setBirthDetails(early: false));

    test('DV1: play today first at every age, in the plan\'s order', () {
      expect(door.tabOrder, {
        'dev_0_6': ['what_to_do', 'on_track', 'when_will', 'talking'],
        'dev_6_12': ['what_to_do', 'when_will', 'talking', 'on_track'],
        'dev_1_2': ['what_to_do', 'talking', 'when_will', 'on_track'],
        'dev_2_3': ['what_to_do', 'talking', 'on_track'],
        'dev_3_5': ['what_to_do', 'talking', 'on_track'],
      });
      for (final b in kPpDevelopmentBands.bands) {
        expect(door.tabOrder[b.id], isNotNull, reason: b.id);
      }
    });

    test('DV3: one pool, at least 12 activities in every age band, a full shelf every month, no title twice', () {
      for (final b in kPpDevelopmentBands.bands) {
        final ids = {
          for (var m = b.fromMonths; m < b.toMonths && m < 60; m++)
            for (final a in activitiesForAge(m)) a.id,
        };
        expect(ids.length, greaterThanOrEqualTo(12), reason: '${b.id}: ${ids.length}');
      }
      for (var m = 0; m < 60; m++) {
        final list = activitiesForAge(m);
        expect(list.length, greaterThanOrEqualTo(kPpPlayTodayCount + 1), reason: '$m months: ${list.length}');
        final titles = [for (final a in list) a.title.toLowerCase().trim()];
        expect(titles.toSet().length, titles.length, reason: '$m months has a title twice');
      }
      expect(kDevActivityPool.length, greaterThan(140));
    });

    test('D2: six picks for his age, the same all day, from his age only', () {
      for (final m in [1, 7, 15, 30, 48]) {
        final day = DateTime(2026, 10, 25);
        final picks = ppPlayTodayPicks(day: day, months: m);
        expect(picks, hasLength(6), reason: '$m');
        final fit = {for (final a in activitiesForAge(m)) a.id};
        expect(picks.every((a) => fit.contains(a.id)), isTrue, reason: '$m');
        expect(ppPlayTodayPicks(day: day, months: m).map((a) => a.id), picks.map((a) => a.id));
        expect(picks.map((a) => a.areaId).toSet().length, greaterThan(2), reason: 'varied, $m');
      }
      final a = ppPlayTodayPicks(day: DateTime(2026, 10, 25), months: 7).map((x) => x.id).toList();
      final b = ppPlayTodayPicks(day: DateTime(2026, 10, 26), months: 7).map((x) => x.id).toList();
      expect(a, isNot(b), reason: 'a fresh pick each day');
    });

    test('DV4: a baby born at 32 weeks, 4 months old, is on the first-six-months band', () {
      FamilyProfileStore.instance.setBirthDetails(early: true, bornWeeks: 32);
      _ageMonths(4);
      expect(ChildProfileStore.instance.correctionWeeks, 8);
      expect(kPpDevelopmentBands.active.id, 'dev_0_6');
      expect(kPpDevelopmentBands.correctedClock, isTrue);
      FamilyProfileStore.instance.setBirthDetails(early: false);
      expect(kPpDevelopmentBands.active.id, 'dev_0_6', reason: 'at term, 4 months is still the first band');
      _ageMonths(7);
      expect(kPpDevelopmentBands.active.id, 'dev_6_12');
    });

    test('DV7: an expert or a class on every tab, each answered', () {
      expect(tab('on_track').expert!.surfaceId, 'pp_experts/Development expert');
      expect(tab('talking').expert!.surfaceId, 'pp_experts/Speech therapist');
      expect(tab('when_will').expert!.surfaceId, 'pp_experts/Paediatric physio');
      expect(tab('what_to_do').expert!.surfaceId, 'pp_learn/rc_playbrain');
      expect(ppSurfaceUnavailable('pp_experts/Speech therapist'), isNull);
      expect(ppSurfaceUnavailable('pp_experts/Development expert'), contains('joining soon'));
      expect(ppSurfaceUnavailable('pp_experts/Paediatric physio'),
          "We're adding paediatric physios. A paediatrician can check this first.");
      expect(kPpNearestExpert['Paediatric physio'], 'Pediatrician', reason: 'never her postnatal physio');
      expect(ppScreenForSurface('pp_learn/rc_playbrain'), isA<LearningDetailScreen>());
      expect(ppScreenForSurface('pp_learn/rc_specialneeds'), isA<LearningDetailScreen>(),
          reason: 'opening soon opens its own page');
      expect(ppSurfaceUnavailable('pp_learn/no_such_course'), contains("isn't open yet"));
      // Courses by id on the pages they fit (S8d: each exists).
      final courses = {
        for (final p in _dev.allPages)
          for (final l in _links(p))
            if (l.surfaceId?.startsWith('pp_learn/') ?? false) l.surfaceId!: p.id,
      };
      for (final c in courses.keys) {
        expect(ppSurfaceUnavailable(c), isNull, reason: c);
      }
      List<String> on(String page) => [
            for (final l in _links(_page(page)))
              if (l.surfaceId?.startsWith('pp_learn/') ?? false) l.surfaceId!,
          ];
      expect(on('dev_play_builds_brain'), ['pp_learn/rc_playbrain']);
      expect(on('dev_crawling'), ['pp_learn/rc_motor']);
      expect(on('dev_walking'), ['pp_learn/rc_motor']);
      expect(on('dev_help_talk'), ['pp_learn/rc_language']);
      // The worry page: the therapists and free help in India.
      final worth = _links(_page('dev_worth_checking')).map((l) => l.surfaceId).toList();
      expect(worth, contains('pp_experts/Special needs expert'));
      expect(worth, contains('pp_page/parenting_special_care/sc_help_india'));
      expect(ppScreenForSurface('pp_page/parenting_special_care/sc_help_india'), isNotNull);
    });

    test('DV6: toys last on Play today, copy first; one toy link on three pages, never on a worry page', () {
      final shop = tab('what_to_do').shop!;
      expect(shop.surfaceId, 'pp_toys');
      expect(shop.blurb, startsWith("You don't need to buy anything"));
      for (final t in door.tabs.where((t) => t.id != 'what_to_do')) {
        expect(t.shop, isNull, reason: t.id);
      }
      final toyPages = {
        for (final p in _dev.allPages)
          if (_links(p).any((l) => l.surfaceId?.startsWith('pp_toys') ?? false)) p.id,
      };
      expect(toyPages, {'dev_sensory_play', 'dev_walking', 'dev_help_talk'});
      for (final id in toyPages) {
        final toys = _links(_page(id)).where((l) => l.surfaceId!.startsWith('pp_toys/')).toList();
        expect(toys, hasLength(1), reason: 'one pitch per page, $id');
        expect(ppSurfaceUnavailable(toys.single.surfaceId!), isNull, reason: toys.single.surfaceId);
      }
      // Every age band has toys picked for it, so the card opens.
      for (final m in [2, 8, 18, 30, 48]) {
        expect(ppToysForAge(m), isNotEmpty, reason: '$m');
      }
      expect(ppSurfaceUnavailable('pp_toys/Moon boots'), contains('Everyday things at home'));
      expect(kSheetToys.where((t) => t.category == 'Gross Motor'), isNotEmpty);
    });

    test('DV8: the movement-signs page, the M-CHAT line, the phases rewrite', () {
      final m = _page('dev_movement_signs');
      expect(m.bands, ['dev_0_6', 'dev_6_12', 'dev_1_2', 'dev_2_3', 'dev_3_5']);
      expect(m.format, 'FLAGGED CALLOUT');
      expect(m.blocks.whereType<PpCards>().single.cards, hasLength(6));
      expect(m.blocks.whereType<PpCallout>().any((c) => c.kind == PpCalloutKind.doctor), isTrue);
      expect(m.blocks.whereType<PpConsult>().single.surface, 'pp_experts/Paediatric physio');
      final consultAt = m.blocks.indexWhere((b) => b is PpConsult);
      final doctorAt = m.blocks.indexWhere((b) => b is PpCallout && b.kind == PpCalloutKind.doctor);
      expect(consultAt, greaterThan(doctorAt), reason: 'the specialist after the doctor box');
      expect(_links(m).map((l) => l.surfaceId), contains('pp_page/parenting_special_care/sc_help_india'));
      expect(_links(m).any((l) => (l.surfaceId ?? '').startsWith('pp_toys')), isFalse);
      final src = File('lib/screens/post_pregnancy/pp_development_content.dart').readAsStringSync();
      final at = src.indexOf("id: 'dev_movement_signs'");
      expect(src.substring(at - 400, at), contains('REQUIRED_REVIEW'));

      final mchat = _page('dev_age_1_2').blocks.whereType<PpArticle>()
          .expand((a) => a.paragraphs).join(' ');
      expect(mchat, contains('M-CHAT'));
      expect(mchat, contains('not a test he can pass or fail'));

      final phases = _page('dev_leaps_lens');
      expect(phases.title, 'Fussy patches and new skills');
      expect(phases.linkedOnly, isFalse);
      expect(_links(phases).single.surfaceId, 'pp_leaps');
      final words = phases.blocks.map((b) => switch (b) {
            PpIntro(:final text) => text,
            PpArticle(:final paragraphs) => paragraphs.join(' '),
            PpCallout(:final text) => text,
            _ => '',
          }).join(' ').toLowerCase();
      expect(words.contains('leap'), isFalse, reason: 'the leaps are retired');
    });

    test('DV3: no link reopens the door, and the NICU papers land on the records', () {
      for (final f in [
        'lib/screens/post_pregnancy/pp_development_content.dart',
        'lib/screens/post_pregnancy/pp_early_learning_content.dart',
      ]) {
        expect(_live(f).contains("surfaceId: 'pp_development'"), isFalse, reason: f);
      }
      final nicu = _links(_page('dev_born_early'))
          .firstWhere((l) => l.label.contains('NICU'));
      expect(nicu.surfaceId, 'pp_page/parenting_health/rec_wallet');
      expect(ppScreenForSurface(nicu.surfaceId!), isNotNull);
      for (final p in _dev.allPages) {
        for (final l in _links(p)) {
          if (l.pageId case final id?) expect(_dev.pageById(id), isNotNull, reason: '${p.id} -> $id');
          if (l.surfaceId case final s?) {
            if (s.startsWith('pp_page/')) expect(ppScreenForSurface(s), isNotNull, reason: '${p.id} -> $s');
          }
        }
      }
    });
  });

  group('on screen', () {
    testWidgets('play today opens first at every age, on an activity of his age', (t) async {
      for (final m in [1, 7, 15, 30, 48]) {
        final opened = <String>[];
        await _pump(t, door, m, opened: opened);
        expect(find.descendant(of: find.byKey(pvDoorRailCardKey(0)), matching: find.text('Play today')),
            findsOneWidget, reason: '$m months');
        expect(find.byKey(const ValueKey('pp_play_today_shelf')), findsOneWidget);
        final fit = {for (final a in activitiesForAge(ChildProfileStore.instance.devAgeInMonths)) a.id};
        final first = ppPlayTodayPicks().first;
        expect(fit, contains(first.id));
        expect(find.byKey(ValueKey('pp_play_today_card_${first.id}')), findsOneWidget, reason: '$m');
        // "All activities" closes the shelf and opens them.
        await t.ensureVisible(find.byKey(const ValueKey('pp_play_today_all')));
        await t.tap(find.byKey(const ValueKey('pp_play_today_all')));
        await t.pumpAndSettle();
        expect(opened, ['pp_activities']);
        expect(find.byKey(const ValueKey('pp_door_tab_shop')), findsOneWidget);
        expect(find.text('Play and Brain'), findsOneWidget);
        expect(find.text('Tummy time'), m < 12 ? findsWidgets : findsNothing,
            reason: 'tummy time leads only the first year ($m)');
        expect(t.takeException(), isNull);
      }
    });

    testWidgets('a baby born early: the hero says which age it reads', (t) async {
      FamilyProfileStore.instance.setBirthDetails(early: true, bornWeeks: 32);
      addTearDown(() => FamilyProfileStore.instance.setBirthDetails(early: false));
      await _pump(t, door, 4);
      expect(find.textContaining('corrected age'), findsWidgets);
    });

    testWidgets('on track: read, tool, read, tool, then the new page and the born-early read', (t) async {
      await _pump(t, door, 12, tab: 'on_track');
      // Twice since R10: the tab is named Milestones too, so the tool card
      // is the last of the two.
      expect(find.text('Milestones'), findsNWidgets(2));
      expect(find.byKey(const ValueKey('pp_door_tab_expert')), findsOneWidget);
      double x(String s) => t.getTopLeft(find.text(s).last).dx;
      expect(x('The normal range is much wider than you think'), lessThan(x('Milestones')));
      expect(x('Milestones'), lessThan(x('When something is worth checking')));
      // 'A gentle check-in' became 'Questions for this age' (R10).
      expect(x('When something is worth checking'), lessThan(x('Questions for this age')));
      expect(x('Questions for this age'), lessThan(x('Movement signs worth showing a doctor')));
      // The phases and What changed come last on this rail (atEnd); a long
      // horizontal rail builds lazily, so they are held as data above.
    });

    testWidgets('a three-year-old: no "sit, crawl, walk", and On track keeps the phases', (t) async {
      await _pump(t, door, 36, tab: 'on_track');
      expect(find.text('Sit, crawl, walk'), findsNothing);
      expect(find.text('The leaps'), findsNothing);
      expect(find.text('Your child\'s phases'), findsOneWidget);
      expect(find.text('Talking'), findsWidgets);
    });

    // R10 (2026-10-26): "Usually settled by now ... Tap the circle" became
    // "Earlier milestones", folded, and the closer look moved into each
    // milestone's sheet ("Play ideas for this"). Was: 'Usually settled by
    // now', 'not a row he has missed', tap 'Thinking', 'Look closer at'.
    testWidgets('Milestones shows the earlier ones, folded, and the play ideas', (tester) async {
      _ageMonths(10);
      tester.view.physicalSize = const Size(1200, 9000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MilestoneJourneyScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Earlier milestones'), findsOneWidget);
      expect(find.textContaining('not one he has missed'), findsOneWidget);
      expect(find.textContaining('Tap the circle'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('pp_milestones_earlier')));
      await tester.pumpAndSettle();
      final first = MilestoneStore.instance.foundations.first;
      await tester.tap(find.byKey(ValueKey('pp_ms_soon_${first.id}')));
      await tester.pumpAndSettle();
      expect(find.text('Play ideas for this, at this age'), findsOneWidget);
    });

    testWidgets('the calendar leads with the caveat and an age, not a date', (tester) async {
      _ageMonths(5);
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: LeapCalendarScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('may be in'), findsOneWidget);
      expect(find.textContaining('Timings are approximate'), findsOneWidget);
      expect(find.textContaining('around '), findsWidgets);
      expect(find.textContaining(RegExp(r'\d+ (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)')), findsNothing);
    });
  });
}
