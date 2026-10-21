// Myth vs fact, plain and standalone (2026-10-21). The user: "this seems
// very ambiguous ... it should be made simple and value adding".

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';

void main() {
  test('every daily myth has a short fact and a why that stands alone', () {
    for (final m in ttcMyths) {
      expect(m.whyEn, isNotNull, reason: m.id);
      expect(m.truthEn.length, lessThan(120), reason: '${m.id}: one sentence');
      // A why that points back at a slide she has left is the old bug.
      for (final back in ['More than that', 'More often than that', 'That ', 'This ']) {
        expect(m.whyEn!.startsWith(back), isFalse, reason: '${m.id}: "$back"');
      }
    }
  });

  test('the story shows the why as its own slide', () {
    final s = File('lib/screens/ttc/ttc_daily_tip_open.dart').readAsStringSync();
    expect(s, contains('myth.whyEn'));
    expect(s, contains('kTtcMythWhySlide'));
  });
}
