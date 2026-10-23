// The store ranks by where she is (2026-10-23, global pass phase 2).
//
// The user: "if a mother is in week 20, the products she sees should be week
// 20's... if she is not able to see them by herself, we are losing money."
// Every shelf now puts what fits her real week (or her child's real age)
// first. Ranking only: nothing leaves a shelf. And the week-20 placeholder,
// with no due date, is not a week.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/pv_catalog_store.dart';

void main() {
  test('no due date and no child: nothing claims to fit', () {
    final store = PvCatalogStore.instance;
    for (final p in store.all.take(50)) {
      expect(store.fitsNow(p), isNull, reason: p.id);
    }
  });

  test('every shelf goes through the hers-first ranking', () {
    final src = File('lib/services/pv_catalog_store.dart').readAsStringSync();
    expect('_hersFirst('.allMatches(src).length, greaterThanOrEqualTo(4),
        reason: 'inCategory, recommended and popular must all rank by her week');
    expect(src.contains('!c.isDueDateSet'), isTrue,
        reason: 'the week-20 placeholder must not count as her week');
  });
}
