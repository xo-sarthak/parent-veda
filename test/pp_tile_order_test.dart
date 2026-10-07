// =============================================================================
//  The home's tiles by age and her priorities; every tile always there (P2)
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_tile_order.dart';
import 'package:parentveda/services/family_profile.dart';

const _ids = [
  'parenting_first_40', 'parenting_sleep', 'parenting_feeding', 'parenting_health',
  'parenting_development', 'parenting_behaviour', 'parenting_potty', 'parenting_early_learning',
  'parenting_traditional', 'parenting_maternal', 'parenting_buying', 'parenting_safety',
  'parenting_family', 'parenting_special_care', 'parenting_papers',
];

void main() {
  test('a newborn: First 40 days first; potty near the end', () {
    final o = ppTileOrder(_ids, ageInDays: 10);
    expect(o.first, 'parenting_first_40');
    expect(o.indexOf('parenting_potty'), greaterThan(o.length - 4));
  });

  test('a two-year-old: potty and behaviour rise, First 40 days drops', () {
    final o = ppTileOrder(_ids, ageInDays: 730);
    expect(o.indexOf('parenting_potty'), lessThan(o.indexOf('parenting_first_40')));
    expect(o.last, 'parenting_first_40');
  });

  test('her priority rises; a C-section brings You, Maa up early', () {
    final plain = ppTileOrder(_ids, ageInDays: 120);
    final sleepy = ppTileOrder(_ids, ageInDays: 120, priorities: {Priority.sleep});
    expect(sleepy.first, 'parenting_sleep');
    final cs = ppTileOrder(_ids, ageInDays: 20, birthMode: BirthMode.cSection);
    expect(cs.indexOf('parenting_maternal'), lessThan(plain.indexOf('parenting_maternal')));
    expect(cs.indexOf('parenting_maternal'), lessThan(3));
  });

  test('never drops or adds a tile', () {
    for (final d in [1, 60, 400, 1500]) {
      expect(ppTileOrder(_ids, ageInDays: d).toSet(), _ids.toSet());
    }
  });
}
