// Her age decides order, never what she sees (2026-10-21).
// See lib/ttc/ttc_age_rank.dart.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ttc/ttc_age_rank.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';

void main() {
  final items = [
    'How long getting pregnant usually takes',
    'Trying after 35',
    'When to see a doctor',
    'Egg reserve (AMH), explained',
    'The stage you are in',
  ];
  String id(String s) => s;

  test('35 to 37: age content first, the rest in its own order', () {
    final out = ttcAgeOrder(items, FertilityAgeBand.thirtyFiveTo37, id);
    expect(out.take(2), ['Trying after 35', 'Egg reserve (AMH), explained']);
    expect(out.skip(2), [
      'How long getting pregnant usually takes',
      'When to see a doctor',
      'The stage you are in',
    ], reason: '"stage" is not "age": whole words only');
  });

  test('under 35, or no age: nothing moves', () {
    expect(ttcAgeOrder(items, FertilityAgeBand.under35, id), items);
    expect(ttcAgeOrder(items, null, id), items);
  });

  test('never drops or adds an item', () {
    for (final b in FertilityAgeBand.values) {
      final out = ttcAgeOrder(items, b, id);
      expect(out.toSet(), items.toSet());
      expect(out.length, items.length);
    }
  });

  test('wiring gate: doors and Learn shelves use it', () {
    expect(File('lib/screens/ttc/doors/ttc_door_screen.dart').readAsStringSync(),
        contains('ttcAgeOrderSections('));
    expect(File('lib/screens/ttc/ttc_learn_screen.dart').readAsStringSync(),
        contains('ttcAgeOrder('));
  });

  // "For your age" (2026-10-22): the tag reads the same rule that lifts, so
  // the order and the tag can never disagree.
  test('the tag shows on what her age lifted, and never under 35', () {
    for (final b in [FertilityAgeBand.thirtyFiveTo37, FertilityAgeBand.over40]) {
      expect(ttcIsForAge('Trying after 35', b), isTrue, reason: b.name);
      expect(ttcIsForAge('When to see a doctor', b), isFalse, reason: b.name);
    }
    expect(ttcIsForAge('Trying after 35', FertilityAgeBand.under35), isFalse);
    expect(ttcIsForAge('Trying after 35', null), isFalse);
    for (final b in FertilityAgeBand.values) {
      for (final x in items) {
        final lifted = ttcAgeOrder(items, b, id).indexOf(x) <
            ttcAgeOrder(items, b, id)
                .where((y) => ttcIsForAge(y, b))
                .length;
        expect(ttcIsForAge(x, b), lifted, reason: '${b.name}: $x');
      }
    }
  });

  test('the door draws the tag on every kind of shelf', () {
    final src = File('lib/screens/ttc/doors/ttc_door_screen.dart')
        .readAsStringSync();
    // The wide single card, the grid and the rail.
    expect('_forAge('.allMatches(src).length, greaterThanOrEqualTo(4));
    expect(src, contains('kTtcForYourAge'));
  });
}
