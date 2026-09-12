// =============================================================================
//  The Development door, held against its reissued brief
// -----------------------------------------------------------------------------
//  `Development_Parenting.pdf` (31 Aug 2026) as assertions. What fails
//  silently here: a second tracker coming back; the calendar printing a date
//  again; the "when will my baby" tab still on the selector for a
//  three-year-old; the one coming-soon scaffold falling out of the ledger; a
//  tab of tools alone drawing nothing.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/leap_calendar_screen.dart';
import 'package:parentveda/screens/post_pregnancy/milestone_journey_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_leaps_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

PpSection get _dev => ppSectionFor('parenting_development')!;
PpArea _area(String id) => _dev.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _dev.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

const _badges = {
  'ARTICLE', 'SHORT ARTICLE', 'FLAGGED CALLOUT', 'CHART', 'STEP-LIST', 'CARDS',
  'VIDEO',
};

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_development')!;

  group('the map', () {
    test('six tabs, on track first, and every area placed', () {
      expect([for (final t in door.tabs) t.id],
          ['on_track', 'when_will', 'talking', 'what_to_do', 'leaps', 'talk']);
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _dev.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(door.hiddenAreaIds, isEmpty);
      for (final t in door.tabs) {
        expect(t.redFlagPageId, isNull, reason: 'no red-flag tab, by design');
      }
    });

    test('on track: the reassurance pages, the one tracker, the check-in', () {
      expect(_listed('on_track'), ['dev_range_is_wide', 'dev_worth_checking', 'dev_born_early']);
      expect(_page('dev_worth_checking').format, 'FLAGGED CALLOUT');
      expect(_page('dev_born_early').bands, isNot(contains('dev_2_3')), reason: 'only up to two years');
      expect(door.tabs[0].tools.map((t) => t.surfaceId), ['pp_milestones', 'pp_dev_checkin']);
      expect(door.tabs[0].footer, contains('not one he has missed'));
    });

    test('when will my baby: the eight reads, and the tab drops away after two', () {
      expect(_listed('when_will'), [
        'dev_rolling', 'dev_sitting', 'dev_crawling', 'dev_standing', 'dev_walking',
        'dev_gestures', 'dev_first_words', 'dev_self_feeding',
      ]);
      expect(door.tabs[1].toMonths, 24);
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

    test('what to do: the activities beside the reassurance, tummy time as a film, the one new page', () {
      expect(door.tabs[3].areaIds, ['help_develop', 'feelings_play']);
      expect(door.tabs[3].tools.single.surfaceId, 'pp_development');
      expect(_listed('help_develop'), [
        'dev_play_builds_brain', 'dev_tummy_time', 'dev_everyday_play', 'dev_sensory_play', 'dev_leaps_lens',
      ]);
      final tummy = _page('dev_tummy_time');
      expect(tummy.format, 'VIDEO');
      expect(tummy.orderedBlocks.first, isA<PpVideoSlot>());
      expect(tummy.blocks.whereType<PpSteps>().single.steps, hasLength(6), reason: 'the steps stay under the film');
      final feelings = _page('dev_feelings_activities');
      expect(feelings.comingSoon, isTrue);
      expect(feelings.title, 'Activities for feelings and getting on with others');
    });

    test('the leaps and talk-and-check are tools alone, and the leaps drop after twenty months', () {
      expect(door.tabs[4].areaIds, isEmpty);
      expect(door.tabs[4].tools.single.surfaceId, 'pp_leaps');
      expect(door.tabs[4].toMonths, 20);
      expect(door.tabs[5].tools.single.surfaceId, 'pp_what_changed');
      expect(door.closing!.surfaceId, 'pp_experts/Development expert');
      expect(door.closing!.blurb, contains('mock for now'));
    });

    test('every listed page wears a badge from the vocabulary', () {
      for (final p in _dev.allPages) {
        expect(_badges, contains(p.format), reason: '${p.id}: "${p.format}"');
      }
    });
  });

  group('single source', () {
    test('one tracker: both ids open the journey', () {
      expect(ppScreenForSurface('pp_on_track'), isA<MilestoneJourneyScreen>());
      expect(ppScreenForSurface('pp_milestones'), isA<MilestoneJourneyScreen>());
      expect(ppScreenForSurface('pp_dev_checkin'), isNotNull);
      expect(_dev.tools.where((t) => t.surfaceId == 'pp_on_track'), isEmpty);
    });

    test('the calendar prints ages, never dates', () {
      for (final l in kLeaps) {
        expect(l.aroundLabel, startsWith('around '), reason: l.name);
        expect(RegExp(r'^around \d+(\.5)? to \d+(\.5)? (weeks|months)$').hasMatch(l.aroundLabel), isTrue, reason: l.aroundLabel);
      }
      final src = File('lib/screens/post_pregnancy/leap_calendar_screen.dart').readAsStringSync();
      final live = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
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

  group('the age rule', () {
    test('the section auto-scopes', () {
      expect(_dev.autoScope, isTrue);
    });
  });

  group('on screen', () {
    testWidgets('a one-year-old sees six cards; the tools-only tabs draw a rail', (tester) async {
      _ageMonths(12);
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      for (final t in door.tabs) {
        expect(find.text(t.label), findsWidgets, reason: t.id);
      }
      expect(find.text('Where he is right now'), findsOneWidget);
      expect(find.text('Talk to a specialist'), findsOneWidget);
      // Land on the leaps the way a deep link does.
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey('leaps'), door: door, onSurface: (_, _) {}, initialTabId: 'leaps')));
      await tester.pumpAndSettle();
      expect(find.text('Your baby\'s phase calendar'), findsOneWidget, reason: 'a tab of one tool still draws its rail');
      expect(find.textContaining('lens and never a law'), findsOneWidget);
    });

    testWidgets('a three-year-old sees four: no "when will my baby", no leaps', (tester) async {
      _ageMonths(36);
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('When will my baby...'), findsNothing);
      expect(find.text('The leaps'), findsNothing);
      expect(find.text('Talking'), findsWidgets);
    });

    testWidgets('the journey shows the settled group and the closer look', (tester) async {
      _ageMonths(10);
      tester.view.physicalSize = const Size(1200, 9000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MilestoneJourneyScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Usually settled by now'), findsOneWidget);
      expect(find.textContaining('not a row he has missed'), findsOneWidget);
      await tester.tap(find.text('Thinking'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Look closer at'), findsOneWidget);
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
