// =============================================================================
//  WHO growth standards to five years
// -----------------------------------------------------------------------------
//  Pins the generated LMS table to values printed in the WHO's own
//  z-score/percentile tables, so a bad regeneration (wrong column, days read
//  as months, sexes swapped) fails here instead of shifting every child's
//  percentile without a sound.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_who_growth_lms.dart';

void main() {
  test('61 months per table, six tables', () {
    for (final t in [kWhoWeightBoys, kWhoWeightGirls, kWhoLengthBoys, kWhoLengthGirls, kWhoHeadBoys, kWhoHeadGirls]) {
      expect(t, hasLength(61));
    }
  });

  test('medians match the WHO printed tables', () {
    // WHO weight-for-age, boys: birth 3.3, 12 m 9.6, 24 m 12.2, 60 m 18.3.
    expect(whoLms(WhoIndicator.weight, true, 0).$2, closeTo(3.3, 0.05));
    expect(whoLms(WhoIndicator.weight, true, 12).$2, closeTo(9.6, 0.05));
    expect(whoLms(WhoIndicator.weight, true, 24).$2, closeTo(12.2, 0.05));
    expect(whoLms(WhoIndicator.weight, true, 60).$2, closeTo(18.3, 0.05));
    // Girls: birth 3.2, 12 m 8.9, 60 m 18.2.
    expect(whoLms(WhoIndicator.weight, false, 0).$2, closeTo(3.2, 0.05));
    expect(whoLms(WhoIndicator.weight, false, 12).$2, closeTo(8.9, 0.05));
    expect(whoLms(WhoIndicator.weight, false, 60).$2, closeTo(18.2, 0.05));
    // Length/height boys: birth 49.9, 24 m 87.8 (lying), 60 m 110.0.
    expect(whoLms(WhoIndicator.length, true, 0).$2, closeTo(49.9, 0.05));
    expect(whoLms(WhoIndicator.length, true, 60).$2, closeTo(110.0, 0.1));
    // Head boys at birth 34.5.
    expect(whoLms(WhoIndicator.head, true, 0).$2, closeTo(34.5, 0.05));
  });

  test('z-scores: the median is the 50th, and the WHO -2 SD weight is the 2nd', () {
    expect(whoPercentileOfZ(whoZ(WhoIndicator.weight, true, 12, whoLms(WhoIndicator.weight, true, 12).$2)), closeTo(50, 0.01));
    // WHO boys 12 m: -2 SD is 7.7 kg, +2 SD is 12.0 kg.
    expect(whoValueAt(WhoIndicator.weight, true, 12, -2), closeTo(7.7, 0.05));
    expect(whoValueAt(WhoIndicator.weight, true, 12, 2), closeTo(12.0, 0.05));
    expect(whoPercentileOfZ(-2), closeTo(2.28, 0.01));
  });

  test('expectedGrowth no longer stops at a year', () {
    expect(expectedGrowth(36).weightKg, greaterThan(expectedGrowth(12).weightKg + 3));
    expect(expectedGrowth(80).weightKg, expectedGrowth(60).weightKg, reason: 'held at five years');
  });

  test('the old clamp is gone from live code', () {
    final src = File('lib/screens/post_pregnancy/pp_child_profile.dart')
        .readAsStringSync()
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    expect(src.contains('months.clamp(0, 12)'), isFalse);
  });
}
