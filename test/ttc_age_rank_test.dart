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
}
