// Her age decides order, never what she sees (2026-10-21).
// See lib/ttc/ttc_age_rank.dart.
//
// Round 2 (2026-10-28, TTC-GAP 29): by id, not words in a title. The word
// tests this file held are replaced; the cases that made the change are
// pinned below (the recipe card "under 40 minutes", the glossary, his age).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ttc/ttc_age_rank.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

List<TtcTile> _allTiles() => [
      for (final p in kTtcFocusPages)
        for (final s in p.sections) ...s.tiles,
    ];

Iterable<TtcFocusSection> _allSections() =>
    [for (final p in kTtcFocusPages) ...p.sections];

void main() {
  const lifting = [
    FertilityAgeBand.thirtyFiveTo37,
    FertilityAgeBand.thirtyEightTo40,
    FertilityAgeBand.over40,
  ];

  test('every id in the lists exists, so a renamed card cannot drop out', () {
    final keys = {for (final t in _allTiles()) ttcTileKey(t)};
    for (final id in {...kTtcAgeCards40, ...kTtcChildAtHomeCards}) {
      expect(keys, contains(id), reason: id);
    }
    for (final id in kTtcAgeReads40) {
      expect(ttcReadById(id), isNotNull, reason: id);
    }
    final headings = {for (final s in _allSections()) s.heading};
    for (final h in {...kTtcAgeSections, ...kTtcChildAtHomeSections}) {
      expect(headings, contains(h), reason: h);
    }
  });

  test('the wrong lifts the word match made are gone', () {
    for (final b in lifting) {
      for (final t in _allTiles()) {
        if (t.title == 'Ten everyday recipes' ||
            t.title == 'Words your clinic uses' ||
            t.title == 'Does his age matter?') {
          expect(ttcIsForAge(t, b), isFalse, reason: '${b.name}: ${t.title}');
        }
      }
    }
  });

  test('the age pages are lifted, over 40 the over-40 page too', () {
    bool lifts(String title, FertilityAgeBand b) =>
        _allTiles().where((t) => t.title == title).every((t) => ttcIsForAge(t, b));
    for (final b in lifting) {
      expect(lifts('Trying after 35', b), isTrue, reason: b.name);
      expect(lifts('A low AMH result', b), isTrue, reason: b.name);
    }
    expect(lifts('Trying after 40', FertilityAgeBand.over40), isTrue);
    expect(
        _allTiles()
            .where((t) => t.title == 'Trying after 40')
            .any((t) => ttcIsForAge(t, FertilityAgeBand.thirtyFiveTo37)),
        isFalse);
  });

  test('under 35, or no age: nothing moves and nothing is tagged', () {
    for (final p in kTtcFocusPages) {
      expect(ttcAgeOrderSections(p.sections, FertilityAgeBand.under35),
          same(p.sections));
      expect(ttcAgeOrderSections(p.sections, null), same(p.sections));
    }
    for (final t in _allTiles()) {
      expect(ttcIsForAge(t, FertilityAgeBand.under35), isFalse);
      expect(ttcIsForAge(t, null), isFalse);
    }
  });

  test('never drops or adds a section or a card', () {
    for (final b in FertilityAgeBand.values) {
      for (final p in kTtcFocusPages) {
        final out = ttcAgeOrderSections(p.sections, b);
        expect(out.length, p.sections.length);
        expect({for (final s in out) s.heading},
            {for (final s in p.sections) s.heading});
        for (final s in out) {
          final was = p.sections.firstWhere((x) => x.heading == s.heading);
          expect(s.tiles.toSet(), was.tiles.toSet());
        }
      }
    }
  });

  test('an age section leads its tab, and the lifted card leads its section', () {
    final ivf = kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_infertility');
    final age = [for (final s in ivf.sections) if (s.group == 'age') s];
    final out = ttcAgeOrderSections(age, FertilityAgeBand.over40);
    expect(out.first.heading, 'Does age change things?');
    expect(ttcIsForAge(out.first.tiles.first, FertilityAgeBand.over40), isTrue);
  });

  test('Learn shelves lift by read id', () {
    final reads = [
      ttcReadById('ttc_read_how_long_it_takes')!,
      ttcReadById('ttc_read_age_after_40')!,
      ttcReadById('ttc_read_age_after_35')!,
    ];
    expect(ttcAgeOrderReads(reads, FertilityAgeBand.thirtyFiveTo37).first.id,
        'ttc_read_age_after_35');
    expect(ttcAgeOrderReads(reads, FertilityAgeBand.over40).take(2).map((r) => r.id),
        ['ttc_read_age_after_40', 'ttc_read_age_after_35']);
    expect(ttcAgeOrderReads(reads, FertilityAgeBand.under35), same(reads));
  });

  test('wiring gate: doors and Learn shelves use it', () {
    expect(File('lib/screens/ttc/doors/ttc_door_screen.dart').readAsStringSync(),
        contains('ttcAgeOrderSections('));
    expect(File('lib/screens/ttc/ttc_learn_screen.dart').readAsStringSync(),
        contains('ttcAgeOrderReads('));
  });

  test('the door draws the tag on every kind of shelf', () {
    final src = File('lib/screens/ttc/doors/ttc_door_screen.dart')
        .readAsStringSync();
    // The wide single card, the grid and the rail.
    expect('_forAge('.allMatches(src).length, greaterThanOrEqualTo(4));
    expect(src, contains('kTtcForYourAge'));
    expect(src, contains('kTtcWithChildAtHome'));
  });
}
