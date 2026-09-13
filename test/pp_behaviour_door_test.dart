// =============================================================================
//  The Behaviour door, held against its brief
// -----------------------------------------------------------------------------
//  `Behaviour_Parenting.pdf` (31 Aug 2026) as assertions. What fails silently
//  here: a second lying or listening page coming back; the crying-too-much
//  page growing prose around its step-through; a coming-soon scaffold that is
//  not in the owed ledger; the checker opening unfiltered from here; a
//  toddler tab on an infant's selector.
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
import 'package:parentveda/screens/post_pregnancy/scripts_library_screen.dart';
import 'package:parentveda/screens/post_pregnancy/what_changed_screen.dart';

PpSection get _beh => ppSectionFor('parenting_behaviour')!;
PpArea _area(String id) => _beh.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _beh.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

const _badges = {
  'ARTICLE', 'SHORT ARTICLE', 'CARDS', 'INTERACTIVE', 'FLAGGED CALLOUT',
  'STEP-LIST', 'CHART', 'ACTIVITY', 'ANIMATION', 'VIDEO',
};

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_behaviour')!;

  group('the map', () {
    test('five tabs, every area placed once, the dissolved area gone', () {
      expect([for (final t in door.tabs) t.id], ['crying', 'tantrums', 'this_one_thing', 'scared', 'calm']);
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _beh.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(_beh.areas.map((a) => a.id), isNot(contains('rules_and_others')), reason: 'folded into Three to six');
      for (final t in door.tabs) {
        expect(t.redFlagPageId, isNull, reason: 'no red-flag tab, by design');
      }
      expect(door.closing!.surfaceId, 'pp_experts/Child psychologist');
    });

    test('the infant area: six pages, the crying-too-much page is its step-through', () {
      expect(_listed('crying'), ['crying_normal', 'wont_settle', 'cant_spoil', 'temperament', 'crying_too_much', 'crying_doctor']);
      final p = _page('crying_too_much');
      expect(p.format, 'INTERACTIVE');
      expect(p.blocks.single, isA<PpInteractive>());
      final i = p.blocks.single as PpInteractive;
      expect(i.kind, PpInteractiveKind.night);
      expect(i.items.map((x) => x.title), contains('Never shake him, not even lightly'));
      expect(i.closing, contains('Tell your doctor today'));
      expect(_page('crying_doctor').format, 'FLAGGED CALLOUT');
    });

    test('the toddler areas keep every card', () {
      expect(_listed('ziddi'), ['beh_ziddi', 'beh_choices', 'beh_strict_or_soft']);
      expect(_listed('first_feelings'), [
        'first_tantrums', 'hitting_biting', 'separation', 'beh_tantrum_or_meltdown', 'beh_tantrum_steps', 'beh_tantrum_public',
      ]);
      expect(_listed('the_no_year'), ['defiance', 'sharing']);
      expect(_listed('specific_behaviours'), ['beh_throwing', 'beh_screaming', 'beh_anger', 'beh_not_listening', 'beh_whining']);
      expect(_listed('screen_time'), ['beh_screen_limits', 'beh_screen_ending', 'beh_screens_family']);
      expect(_listed('discipline'), ['beh_no_hitting', 'beh_consequences', 'beh_timeouts', 'beh_elders']);
      expect(_listed('calming'), [
        'beh_calm_corner', 'beh_balloon_breathing', 'beh_name_the_feeling', 'beh_calm_jar', 'beh_connection_games', 'beh_feelings_checkin',
      ]);
    });

    test('three to six: the merge, the reslot and the one written page', () {
      expect(_listed('older_child'), [
        'beh_big_feelings', 'beh_cooperation', 'beh_friendships', 'beh_older_lying', 'siblings', 'beh_back_talk',
      ]);
      final back = _page('beh_back_talk');
      expect(back.title, 'Back-talk, and "I hate you"');
      expect(back.bands, ['preschool']);
      expect(back.blocks.whereType<PpScript>().single.lines.first.say, 'You are allowed to be this angry with me.');
      expect(back.blocks.whereType<PpIndiaNote>().single.text, contains('dekho, kaise baat karta hai'));
      expect(back.blocks.whereType<PpSteps>().single.steps, hasLength(5));
    });

    test('the two new areas are scaffolds, every one in the ledger', () {
      expect(_listed('scared'), hasLength(6));
      expect(_listed('habits'), hasLength(5), reason: 'four from the brief plus the self-touching page, on the user\'s call');
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final id in [..._listed('scared'), ..._listed('habits')]) {
        expect(_page(id).comingSoon, isTrue, reason: id);
        expect(ledger.contains(id), isTrue, reason: '$id is a coming-soon card nobody has logged as owed');
      }
      expect(_page('beh_fear_worth_checking').format, 'FLAGGED CALLOUT');
    });

    test('the reformats', () {
      final balloon = _page('beh_balloon_breathing');
      expect(balloon.format, 'ANIMATION');
      expect((balloon.orderedBlocks.first as PpAnimation).kind, PpAnimationKind.breathing);
      expect(balloon.blocks.whereType<PpSteps>(), isNotEmpty, reason: 'the steps stay under the circle');
      final jar = _page('beh_calm_jar');
      expect(jar.format, 'VIDEO');
      expect(jar.orderedBlocks.first, isA<PpVideoSlot>());
      final chart = _page('beh_screen_limits').blocks.whereType<PpTable>().single;
      expect(chart.rowMonths, hasLength(chart.rows.length));
      expect(chart.herRow(30), 2, reason: 'a two-and-a-half-year-old leads with the 2 to 5 row');
    });

    test('every listed page wears a badge from the vocabulary', () {
      for (final p in _beh.allPages) {
        expect(_badges, contains(p.format), reason: '${p.id}: "${p.format}"');
      }
    });
  });

  group('single source', () {
    test('one lying page, one listening page', () {
      expect(_beh.pageById('lying'), isNull, reason: 'merged into beh_older_lying');
      final lying = _page('beh_older_lying');
      expect(lying.orderedBlocks.first, isA<PpVideoSlot>(), reason: 'the merged film');
      expect(lying.blocks.whereType<PpScript>(), isNotEmpty, reason: 'the merged script');
      final coop = _page('beh_cooperation');
      expect(coop.toolSurfaceId, 'pp_page/parenting_behaviour/beh_not_listening');
      expect(coop.blocks, isEmpty, reason: 'no second copy');
      expect(ppScreenForSurface(coop.toolSurfaceId!), isNotNull);
    });

    test('the aggression mechanism is written once and linked from the other two', () {
      for (final id in ['hitting_biting', 'beh_no_hitting']) {
        expect(_page(id).blocks.whereType<PpLink>().any((l) => l.pageId == 'beh_anger'), isTrue, reason: id);
      }
      expect(_page('defiance').blocks.whereType<PpLink>().any((l) => l.pageId == 'beh_ziddi'), isTrue,
          reason: 'the will-before-words explanation lives on the ziddi page');
    });

    test('the checker opens pre-filtered from here, and the scripts tool has no age chips', () {
      expect(door.tabs[2].tools.single.surfaceId, 'pp_what_changed/behaviour');
      final w = ppScreenForSurface('pp_what_changed/behaviour');
      expect(w, isA<WhatChangedScreen>());
      expect((w as WhatChangedScreen).initialCategories, ['Behaviour', 'Mood']);
      expect(door.tabs[1].tools.single.surfaceId, 'pp_scripts');
      final src = File('lib/screens/post_pregnancy/scripts_library_screen.dart').readAsStringSync();
      final live = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
      expect(live.contains('_pad(_bandRow())'), isFalse, reason: 'the band chips are off the live screen');
      expect(live.contains("'Show every age'"), isFalse);
    });
  });

  group('the age rule', () {
    test('the section auto-scopes', () => expect(_beh.autoScope, isTrue));

    testWidgets('an infant parent sees one tab; a four-year-old\'s sees four, without Crying', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageMonths(3);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(3), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Crying, the first year'), findsWidgets);
      expect(find.text('Tantrums and the ziddi years'), findsNothing);
      expect(find.text('Scared, shy or clingy'), findsNothing);
      expect(find.text('When the crying is too much'), findsOneWidget);

      _ageMonths(48);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(48), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Crying, the first year'), findsNothing);
      for (final t in door.tabs.skip(1)) {
        expect(find.text(t.label), findsWidgets, reason: t.id);
      }
      expect(find.text('What to say when…'), findsOneWidget);
      expect(find.text('Talk to a child psychologist'), findsOneWidget);
    });

    testWidgets('the scripts tool opens on his band with no chooser', (tester) async {
      _ageMonths(30);
      tester.view.physicalSize = const Size(1200, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: ScriptsLibraryScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 TO 3'), findsOneWidget);
      expect(find.text('Under 1'), findsNothing);
      expect(find.text('Show every age'), findsNothing);
    });
  });
}
