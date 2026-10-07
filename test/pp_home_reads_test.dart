// =============================================================================
//  The home's reads come from the doors, in the child's band (gap P1)
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_reads.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PpLastPageStore.instance.debugReset();
  });

  void ageMonths(int m) =>
      ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(Duration(days: (m * 30.44).round() + 3)));

  test('five door pages, five different doors, none coming soon', () {
    ageMonths(4);
    final r = ppHomeDoorReads(5, day: 3);
    expect(r, hasLength(5));
    expect(r.map((x) => x.section.id).toSet(), hasLength(5), reason: 'one door at a time');
    for (final x in r) {
      expect(x.page.comingSoon, isFalse);
      expect(x.section.id, isNot('parenting_maternal'));
    }
  });

  test('every page fits the child\'s band in its door', () {
    for (final m in [1, 9, 20, 40]) {
      ageMonths(m);
      for (final x in ppHomeDoorReads(5, day: m)) {
        final band = x.section.bandSet?.active.id ?? '';
        expect(x.page.inBand(band), isTrue, reason: '${x.page.id} at $m months');
      }
    }
  });

  test('the rail changes with the day', () {
    ageMonths(6);
    final a = ppHomeDoorReads(5, day: 1).map((x) => x.page.id).toList();
    final b = ppHomeDoorReads(5, day: 2).map((x) => x.page.id).toList();
    expect(a, isNot(b));
  });

  test('continue reading remembers the last page opened', () {
    final first = ppHomeDoorReads(1, day: 1).single;
    PpLastPageStore.instance.opened(first.section.id, first.page.id);
    expect(PpLastPageStore.instance.last?.page.id, first.page.id);
  });

  test('wired: every page open records it; the home draws both', () {
    expect(File('lib/screens/post_pregnancy/pp_section_screen.dart').readAsStringSync(),
        contains('PpLastPageStore.instance.opened(section.id, page.id);'));
    final home = File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
    expect(home, contains('ppHomeDoorReads(5)'));
    expect(home, contains("title: 'Continue reading'"));
    expect(File('lib/main.dart').readAsStringSync(), contains('PpLastPageStore.instance.init()'));
  });
}
