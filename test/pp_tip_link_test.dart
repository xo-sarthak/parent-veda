// =============================================================================
//  Age tips lead to a door page, hand-matched; none when nothing fits (gap P2)
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_daily_tips.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tip_links.dart';

void main() {
  test('every link is a real tip and a real page', () {
    final keys = {for (final t in kAgeTips) t.key};
    for (final e in kPpTipLinks.entries) {
      expect(keys, contains(e.key));
      expect(ppPageTitleForSurface(e.value), isNotNull, reason: '${e.key} -> ${e.value}');
    }
  });

  test('most tips have a page to read next', () {
    expect(kPpTipLinks.length, greaterThanOrEqualTo(kAgeTips.length * 0.7));
  });

  test('the known wrong matches stay fixed', () {
    final coo = kAgeTips.firstWhere((t) => t.tip.title == 'Coo back').key;
    expect(ppPageTitleForSurface(kPpTipLinks[coo]!), isNot(contains('week back')));
  });

  test('the home uses the hand-matched links and fills the pronoun', () {
    final home = File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
    expect(home, contains('line: ppFillChild(tip.body)'));
    expect(home, contains('kPpTipLinks[id.substring(5)]'));
  });
}
