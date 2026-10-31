// The pregnancy calendar sits top right on the home, as on trying to conceive
// (2026-10-10). It had lost its tab on 2026-09-29 and had no entrance there.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the home hands the hero a calendar, and the hero draws it', () {
    final home = File('lib/screens/home_v3_screen.dart').readAsStringSync();
    // His side passes null (2026-10-13): her calendar edits her appointments.
    expect(home, contains('onCalendar: him'));
    expect(home, contains(': () => Navigator.of(context).push(MaterialPageRoute<void>('));
    expect(home, contains('builder: (_) => CalendarScreen(controller: pregnancy)'));
    final hero = File('lib/screens/v2/v3_preg_hero.dart').readAsStringSync();
    expect(hero, contains("semantic: 'Calendar'"));
    expect(hero, contains('Icons.calendar_today_rounded'),
        reason: 'the same mark as the trying-to-conceive header');
  });

  // One header order on every home (2026-10-31): Search sits beside the
  // calendar on the right, and opens the whole-stage search.
  test('the hero draws Search beside the calendar and the home wires it', () {
    final home = File('lib/screens/home_v3_screen.dart').readAsStringSync();
    expect(home, contains('onSearch: () => openPvSearch(context, pregnancy)'));
    final hero = File('lib/screens/v2/v3_preg_hero.dart').readAsStringSync();
    expect(hero, contains("ValueKey('preg_hero_search')"));
    expect(hero, contains("semantic: 'Search'"));
    expect(hero.indexOf("ValueKey('preg_hero_search')"),
        lessThan(hero.indexOf("semantic: 'Calendar'")),
        reason: 'Search before Calendar');
  });
}
