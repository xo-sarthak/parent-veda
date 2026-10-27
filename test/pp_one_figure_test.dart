// =============================================================================
//  One figure per fact, across the parenting doors (final review item 4,
//  2026-10-27)
// -----------------------------------------------------------------------------
//  ⚠️ The same fact was written in two doors with two figures: no urine for 12
//  hours on the go-now list, 8 on the Health pages, 6 in Feeding; a fever
//  under three months "go now" on one page and "today, not tomorrow" on the
//  next; a newborn room at 26 to 28 C in First 40 and 20 to 24 C in Sleep.
//  Twenty-three pairs in all. Each was settled by the door that owns the
//  topic, and the other page was changed to match.
//
//  Two figures shared by three or more pages became constants
//  (`kPpNoUrineHours`, `kPpRepellentAge`), so they cannot drift again. The
//  rest are held here as retired wordings: if one comes back, a door has
//  started disagreeing with its twin. Comments are skipped, because the old
//  wording is kept in them for revert.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_health_red_flags.dart';

const _dir = 'lib/screens/post_pregnancy';

/// The file's code with `//` lines and `/* */` blocks removed.
String _code(String file) {
  final src = File('$_dir/$file').readAsStringSync();
  final noBlocks = src.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return noBlocks
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('//'))
      .join('\n');
}

/// (file, a wording that disagreed with the owning door, which row).
const _retired = [
  ('pp_health_red_flags.dart', 'No urine for twelve hours', '4a'),
  ('pp_feeding_content.dart', 'no wet nappy in six hours', '4a'),
  ('pp_health_content.dart', 'today, not tomorrow', '4b'),
  ('pp_health_content.dart', 'is a same day hospital visit', '4b'),
  ('pp_first40_content.dart', 'three months needs a doctor the same day', '4b'),
  ('pp_health_content.dart', '36.4 C', '4c'),
  ('pp_health_content.dart', 'below 97.5 F', '4c'),
  ('pp_first40_content.dart', '97.5 F', '4c'),
  ('pp_health_content.dart', 'yellow on the tummy or legs', '4d'),
  ('pp_first40_content.dart', 'Jaundice after the first weeks', '4d'),
  ('pp_first40_content.dart', 'the first vaccines at six weeks', '4e'),
  ('pp_first40_content.dart', 'careful until the first vaccines', '4e'),
  ('pp_health_content.dart', "PpStep('The first vaccines'", '4e'),
  ('pp_first40_content.dart', '26 to 28 C', '4f'),
  ('pp_first40_content.dart', 'Fine for supervised naps', '4g'),
  ('pp_you_maa_content.dart', 'Call your doctor if you soak a maternity pad', '4h'),
  ('pp_health_content.dart', 'any repellent under two months', '4i'),
  ('pp_safety_content.dart', "PpStep('Go to a hospital the same day'", '4j'),
  ('pp_safety_content.dart', 'cool the child with water', '4l'),
  ('pp_special_care_content.dart', 'hours out on the counter', '4m'),
  ('pp_behaviour_bands.dart', 'no words at all by around two', '4n'),
  ('pp_development_content.dart', 'no words by about 16 months', '4n'),
  ('pp_traditions_content.dart', 'one to three weeks', '4o'),
  ('pp_feeding_content.dart', 'jaggery after one year', '4p'),
  ('pp_feeding_content.dart', 'jaggery and honey only after 12 months', '4p'),
  ('pp_development_content.dart', 'About 12 to 15 hours in 24', '4q'),
  ('pp_potty_content.dart', 'one in five five-year-olds', '4s'),
  ('pp_behaviour_content.dart', 'peaking through the second year', '4t'),
  ('pp_sleep_content.dart', 'Eighteen months and up: stories', '4u'),
  ('pp_sleep_content.dart', 'from about 18 months. Read slowly', '4u'),
  ('pp_sleep_content.dart', 'two to three feet away', '4v'),
  ('pp_sleep_content.dart', "PpCard('For two days'", '4w'),
];

void main() {
  test('no door has gone back to a figure its twin disagrees with', () {
    final back = [
      for (final (file, phrase, row) in _retired)
        if (_code(file).contains(phrase)) '$row $file: "$phrase"',
    ];
    expect(back, isEmpty,
        reason: 'These wordings were retired by final review item 4 because '
            'another door owns the fact. Change the page to match the owner '
            'instead.');
  });

  test('the no-urine sign is one figure, on the go-now list and every page',
      () {
    expect(kPpGoNowSigns.where((s) => s.contains(kPpNoUrineHours)), hasLength(1));
    expect(RegExp(r'\$kPpNoUrineHours').allMatches(_code('pp_health_content.dart')),
        hasLength(6));
    expect(_code('pp_feeding_content.dart'), contains(r'$kPpNoUrineHours'));
  });

  test('the repellent age floor is one figure on all three Health pages', () {
    expect(RegExp(r'\$kPpRepellentAge').allMatches(_code('pp_health_content.dart')),
        hasLength(3));
  });
}
