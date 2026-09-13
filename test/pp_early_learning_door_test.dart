// =============================================================================
//  The Early Learning door, held against its brief
// -----------------------------------------------------------------------------
//  `Early_Learning_Parenting.pdf` as assertions. What fails silently here:
//  the activity picker coming back as a tool beside the rail that IS the
//  set; the stories going back behind the school tab; a habit page losing
//  its Behaviour twin; a coming-soon scaffold not in the owed ledger; the
//  old home's Prepare-for-school door landing on the whole library again.
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

PpSection get _el => ppSectionFor('parenting_early_learning')!;
PpArea _area(String id) => _el.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _el.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_early_learning')!;

  group('the map', () {
    test('five tabs, every area placed once, the everyday things at the front', () {
      expect([for (final t in door.tabs) t.id], ['today', 'stories', 'habits', 'before_letters', 'school']);
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _el.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(door.tabs.first.areaIds.first, 'today', reason: 'not behind a school button');
      for (final t in door.tabs) {
        expect(t.redFlagPageId, isNull, reason: 'no red-flag strip; no emergencies here');
      }
      expect(door.closing!.surfaceId, 'pp_experts/Early learning expert');
    });

    test('the activity set exists once: the rail, never also a tool', () {
      expect(_listed('today'), hasLength(36));
      for (final t in door.tabs) {
        expect(t.tools.map((x) => x.surfaceId), isNot(contains('pp_activities')), reason: t.id);
      }
      expect(door.tabs[0].tools.single.surfaceId, 'pp_recos');
      expect(door.tabs[3].tools.single.surfaceId, 'pp_milestones', reason: 'the one tracker, Development\'s');
      expect(door.tabs[4].tools.single.surfaceId, 'pp_courses');
    });

    test('stories and rhymes: the how-to, six collections, the new collection', () {
      expect(door.tabs[1].areaIds, [
        'story_time', 'bedtime_tales', 'panchatantra', 'jataka', 'birbal', 'tenali', 'world_tales', 'rhymes',
      ]);
      expect(_listed('bedtime_tales'), hasLength(10));
      expect(_listed('panchatantra'), hasLength(12));
      expect(_listed('jataka'), hasLength(10));
      expect(_listed('birbal'), hasLength(10));
      expect(_listed('tenali'), hasLength(6));
      expect(_listed('world_tales'), hasLength(10));
      expect(_page('rhymes_collection').comingSoon, isTrue);
      expect(_page('rhymes_collection').format, 'AUDIO LIBRARY');
    });

    test('the habits: fifteen, and the five twins link to their Behaviour page', () {
      expect(_listed('habits'), hasLength(15));
      const twins = {
        'hab_sharing': 'pp_page/parenting_behaviour/sharing',
        'hab_waiting': 'pp_page/parenting_behaviour/sharing',
        'hab_kindness': 'pp_page/parenting_behaviour/beh_friendships',
        'hab_truth': 'pp_page/parenting_behaviour/beh_older_lying',
        'hab_screens': 'pp_page/parenting_behaviour/beh_screen_ending',
      };
      for (final (id, target) in twins.entries.map((e) => (e.key, e.value))) {
        expect(_page(id).blocks.whereType<PpLink>().map((l) => l.surfaceId), contains(target), reason: id);
        expect(ppScreenForSurface(target), isNotNull, reason: target);
      }
    });

    test('before letters and starting school: the split, and the one new page', () {
      expect(_listed('early_skills'), ['skills_prewriting', 'skills_numeracy', 'skills_literacy', 'skills_colours_shapes', 'skills_language']);
      expect(_page('skills_language').comingSoon, isTrue);
      expect(_listed('school'), ['school_what_readiness', 'school_checklist', 'school_choosing', 'school_first_day', 'school_what_next']);
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final p in _el.allPages.where((p) => p.comingSoon)) {
        expect(ledger.contains(p.id), isTrue, reason: '${p.id} is a coming-soon card nobody has logged as owed');
      }
    });

    test('the anti-worksheet line survives in live copy', () {
      final src = File('lib/screens/post_pregnancy/pp_early_learning_content.dart').readAsStringSync();
      expect(src.contains('worksheets can wait'), isTrue);
    });

    test('the old home\'s Prepare-for-school door lands on the school tab', () {
      final src = File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
      expect(src.contains("kPpActSchoolReadiness: 'parenting_early_learning/school'"), isTrue);
      expect(door.tabFor('school')!.id, 'school');
    });
  });

  group('the age rule', () {
    test('the section auto-scopes', () => expect(_el.autoScope, isTrue));

    testWidgets('a baby\'s parent: today and stories open, habits from 1, before letters from 2, school from 3', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageMonths(5);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(5), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Peekaboo'), findsOneWidget, reason: 'a baby activity on the rail');
      expect(find.text('Playing sabzi shop'), findsNothing, reason: 'a two-year-old\'s');
      expect(find.textContaining('From 1 year'), findsOneWidget, reason: 'Good habits');
      expect(find.textContaining('From 2 years'), findsOneWidget, reason: 'Before letters and numbers');
      expect(find.textContaining('From 3 years'), findsOneWidget, reason: 'Starting school');
      expect(find.text('Talk to an early learning expert'), findsOneWidget);

      _ageMonths(40);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey(40), door: door, onSurface: (_, _) {}, initialTabId: 'stories')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      expect(find.text('Akbar and Birbal'), findsOneWidget, reason: 'a three-year-old\'s collection is on the rail');
      expect(find.text('Rhymes and songs'), findsWidgets);
    });
  });
}
