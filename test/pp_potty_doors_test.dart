// =============================================================================
//  Two doors, two destinations — the third instance of one bug
// -----------------------------------------------------------------------------
//  ⚠️ THIS SHAPE HAS NOW APPEARED THREE TIMES IN ONE REVIEW: Nutrition's "what
//  should I eat" and "something has been flagged"; Development's "things to do
//  today" and "more activities by area"; and here, "is she ready" and "start
//  and manage potty training".
//
//  Every time the cause was identical. A hub door routes to a SECTION, sections
//  are easy to address, and the thing the door actually promises is one area
//  inside it. So two questions get one answer and the labels stop meaning
//  anything.
//
//  It is invisible to every other kind of test, because both taps work.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/hubs/parenting_hubs.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';

import 'dart:io';

String _read(String p) => File(p).readAsStringSync();

void main() {
  test('the two potty doors resolve to different areas', () {
    final home = _read('lib/screens/post_pregnancy/pp_home_v3.dart');
    final i = home.indexOf('const areaForAction = <String, String>{');
    expect(i, greaterThan(-1),
        reason: 'The per-door area map is gone, so both potty doors are back '
            'to opening the same section landing.');
    final block = home.substring(i, home.indexOf('};', i));

    expect(block.contains('kPpActPottyReadiness'), isTrue);
    expect(block.contains('kPpActPottyTraining'), isTrue);

    final readiness =
        RegExp(r"kPpActPottyReadiness: '([^']+)'").firstMatch(block)?.group(1);
    final training =
        RegExp(r"kPpActPottyTraining: '([^']+)'").firstMatch(block)?.group(1);
    expect(readiness, isNotNull);
    expect(training, isNotNull);
    expect(readiness, isNot(equals(training)),
        reason: 'Both potty doors point at the same place again.');
  });

  test('each door names an area that actually exists', () {
    // ⚠️ AN UNKNOWN AREA ID FAILS SILENTLY AT RUNTIME — the screen simply does
    // not deep-link and shows the landing, which is exactly what the bug
    // looked like before it was fixed. So the ids are checked here.
    final home = _read('lib/screens/post_pregnancy/pp_home_v3.dart');
    final i = home.indexOf('const areaForAction = <String, String>{');
    final block = home.substring(i, home.indexOf('};', i));

    for (final m in RegExp(r"'([a-z_]+)/([a-z_]+)'").allMatches(block)) {
      final section = ppSectionFor(m.group(1)!);
      expect(section, isNotNull, reason: 'unknown section "${m.group(1)}"');
      expect(section!.areas.any((a) => a.id == m.group(2)), isTrue,
          reason: '"${m.group(2)}" is not an area of ${m.group(1)}. The door '
              'will silently fall back to the section landing, which is the '
              'bug this test exists for.');
    }
  });

  test('the potty hub still has exactly the doors it had', () {
    // Guards against "fixing" the duplication by deleting a door.
    final actions = kPpPotty.needs.map((n) => n.action).toList();
    expect(actions, contains(kPpActPottyReadiness));
    expect(actions, contains(kPpActPottyTraining));
  });

  test('at most one pinned area per section', () {
    // Two pinned areas is just a second grid with a different card, which
    // defeats the point of pinning either. Convention, now checkable.
    for (final s in kPpSections) {
      final pinned = s.areas.where((a) => a.pinned).length;
      expect(pinned, lessThanOrEqualTo(1),
          reason: '${s.id} pins $pinned areas');
    }
  });
}
