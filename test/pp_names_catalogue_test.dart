// The name catalogue: hundreds of Indian names across faiths and regions,
// every derived field filled, no duplicates, the hand-written ones first.
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_names_data.dart';

void main() {
  test('hundreds of names, no duplicates, authored ones first and intact', () {
    expect(kBabyNames.length, greaterThan(480));
    final names = kBabyNames.map((n) => n.name.toLowerCase()).toList();
    expect(names.toSet().length, names.length);
    for (var i = 0; i < kBabyNamesAuthored.length; i++) {
      expect(identical(kBabyNames[i], kBabyNamesAuthored[i]), isTrue);
    }
  });

  test('every faith and region is represented, for boys and for girls', () {
    for (final c in ['Hindu', 'Muslim', 'Sikh', 'Christian']) {
      expect(namesFiltered(gender: 'Boy', community: c).length, greaterThanOrEqualTo(15), reason: '$c boys');
      expect(namesFiltered(gender: 'Girl', community: c).length, greaterThanOrEqualTo(15), reason: '$c girls');
    }
    for (final r in ['North', 'South', 'East', 'West']) {
      expect(namesFiltered(region: r).length, greaterThanOrEqualTo(15), reason: r);
    }
  });

  test('every name has Devanagari, a meaning and three tradition fields', () {
    final deva = RegExp(r'[ऀ-ॿ]');
    for (final n in kBabyNames) {
      expect(deva.hasMatch(n.script), isTrue, reason: n.name);
      expect(n.meaningShort.trim(), isNotEmpty, reason: n.name);
      expect(n.nakshatra, isNotEmpty, reason: n.name);
      expect(n.numerology, inInclusiveRange(1, 9), reason: n.name);
      expect(n.syllables, greaterThan(0), reason: n.name);
    }
  });

  test('derived helpers', () {
    expect(ppNameSyllables('Aarav'), 2);
    expect(ppNamePron('Ishaan'), 'i-shaan');
    expect(ppRashiNote('Bhavya'), contains('Dhanu'));
    expect(ppRashiNote('Tara'), contains('or'), reason: 'two rashis named, not one guessed');
    expect(ppChaldean('Aarav'), inInclusiveRange(1, 9));
  });
}
