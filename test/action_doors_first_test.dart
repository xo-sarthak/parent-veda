// Action doors lead with an action (2026-10-23, global pass phase 2).
//
// The user: "an action door requires a video... stuff the user can actually
// see and do", "baby name tool should be the first thing", and the Mind &
// body headings "need to be more action oriented".

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/move/pv_move_today_screen.dart';

void main() {
  test('Move: the first card on the first tab is something to do', () {
    final first = kMoveDoor.sectionsOf(kMoveDoor.groups.first.id).first;
    expect(first.heading, 'Move today');
    expect(first.tiles.first, isA<PvDoorToolTile>());
    expect((first.tiles.first as PvDoorToolTile).surfaceId, 'move/today');
  });

  test('Getting Ready: the name finder leads the names tab', () {
    final first = kGettingReadyDoor.sectionsOf(kReadyTabNames).first;
    expect(first.tiles.first, isA<PvDoorToolTile>());
    expect((first.tiles.first as PvDoorToolTile).surfaceId, kReadySurfaceNames);
  });

  test('every pregnancy week has a session, so Move never opens an article', () {
    for (var w = 4; w <= 42; w++) {
      expect(moveTodaySessionFor(w, DateTime(2026, 10, 23)), isNotNull,
          reason: 'week $w has no session');
    }
  });

  test('TTC Mind & body headings are actions, not questions', () {
    final src = File('lib/ttc/focus/ttc_focus_mind_body.dart').readAsStringSync();
    final headings = RegExp(r"heading: '([^']*)'")
        .allMatches(src)
        .map((m) => m.group(1)!)
        .toList();
    expect(headings, isNotEmpty);
    expect(headings.where((h) => h.endsWith('?')), isEmpty);
  });
}
