// =============================================================================
//  Every parenting door in the TTC door format (2026-10-07)
// -----------------------------------------------------------------------------
//  The parenting gap pass: "keep the design consistent with TTC and pregnancy
//  on every screen you touch; it must look like ONE ParentVeda." The pregnancy
//  doors moved to TTC's format on 2026-10-02 and `pv_door_ttc_format_test.dart`
//  holds them; this holds the parenting door to the same pieces: the quiet hero
//  with the door's name and a search pill, the shared quiet rail (with a lock
//  for a tab the child has not reached), shelf cards that say what they are,
//  the folded red flag, and no "Video" on a page with no film.
//
//  Every door is pumped at a 360dp phone with 1.5x text, at three ages, and
//  must not overflow.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/brackets/hub/hub_intent_art.dart';
import 'package:parentveda/screens/doors/pv_door_rail.dart';
import 'package:parentveda/screens/doors/pv_shelf_card.dart';
import 'package:parentveda/screens/doors/pv_shelf_spec.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';

void _ageMonths(int months) {
  ChildProfileStore.instance
      .debugSetDob(DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));
}

Future<void> _pumpDoor(WidgetTester tester, PpDoor door) async {
  tester.view.physicalSize = const Size(360, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(360, 2400), textScaler: TextScaler.linear(1.5)),
      child: PpDoorScreen(door: door, onSurface: (_, _) {}),
    ),
  ));
  await tester.pump();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => ChildProfileStore.instance.resetForTest());

  test('the switch is on', () => expect(kPpDoorTtcFormat, isTrue));

  for (final months in [2, 20, 50]) {
    for (final door in kPpDoors) {
      testWidgets('${door.sectionId} at $months months: quiet hero, shared rail, shelf cards, no overflow',
          (tester) async {
        _ageMonths(months);
        await _pumpDoor(tester, door);
        expect(tester.takeException(), isNull, reason: 'no overflow at 360dp and 1.5x');
        expect(find.byKey(const ValueKey('pp_door_hero_title')), findsOneWidget);
        expect(find.byKey(const ValueKey('pp_door_search')), findsOneWidget);
        expect(find.byKey(kPvDoorRailKey), findsOneWidget);
        expect(find.byType(PvShelfCard).evaluate().isNotEmpty ||
                find.byIcon(Icons.lock_outline_rounded).evaluate().isNotEmpty,
            isTrue,
            reason: 'an open tab draws shelf cards; a locked one its panel');
        // No violet: the closing link and every card text is ink.
        expect(find.text('RED FLAG'), findsNothing, reason: 'the flag is folded into a row');
      });
    }
  }

  test('no card says "Video" while no parenting film exists', () {
    var videoPages = 0;
    for (final s in kPpSections) {
      for (final p in s.allPages) {
        final spec = ppShelfSpecFor(p);
        expect(spec.kind, isNot(PvShelfKind.video), reason: p.id);
        // A video SHELF that opens a tool is a Tool card, rightly.
        if ((p.format ?? '').toUpperCase().startsWith('VIDEO') && p.toolSurfaceId == null) {
          videoPages++;
          expect(spec.kind, PvShelfKind.read, reason: '${p.id}: an article until the film exists');
        }
      }
    }
    expect(videoPages, greaterThan(0), reason: 'the rule is tested on real video pages');
  });

  test('every page has a kind, and every article says its reading time', () {
    for (final s in kPpSections) {
      for (final p in s.allPages) {
        final spec = ppShelfSpecFor(p);
        if (spec.kind == PvShelfKind.read && spec.word == null) {
          expect(spec.fact, matches(RegExp(r'^\d+ min read$')), reason: p.id);
        }
      }
    }
  });

  test('every tab wears a drawn mark, not the fallback page', () {
    final fallback = <String>[];
    for (final d in kPpDoors) {
      for (final t in d.tabs) {
        if (ppTabMarkFor(t.icon) == IntentMark.pageMark) fallback.add('${d.sectionId}/${t.id}');
      }
    }
    expect(fallback, isEmpty, reason: 'map these tab icons in ppTabMarkFor');
  });

  test('the door is built on the shared pieces, at their numbers', () {
    final src = File('lib/screens/post_pregnancy/doors/pp_door_screen.dart').readAsStringSync();
    for (final piece in ['PvDoorRail(', 'PvShelfCard(', 'PvLiveSearchField(', 'PvDoorSheet(',
        'kPvDoorBlockGap', 'kPvDoorHeadingGap', 'kPvDoorHeroQuietHeight', 'pvShelfRailHeight(']) {
      expect(src, contains(piece), reason: piece);
    }
    expect(PvDoorRail.cardWidth, 150);
    expect(kPvShelfCardWidth, 148);
  });
}
