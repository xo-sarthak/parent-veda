// "What you need" and "Go further" (2026-10-23, global pass phase 2,
// prototype RAJsHJcLXYpJ6DrXyjfR9S approved by the user).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/pitch/pv_go_further.dart';

void main() {
  test('a need with nothing to buy is never a store link', () {
    expect(pvProductsFor(const PvNeed('Water nearby')), isEmpty);
  });

  test('the session row: a pillow from the store, a physio, a fitness course', () {
    final items = pvFurtherItems(
      needs: const [
        PvNeed('Yoga mat', words: ['yoga mat']),
        PvNeed('A bolster or pillow', categories: ['pregnancy_pillow']),
      ],
      offerings: const [
        ['physiotherapist'],
        ['trimester-safe fitness', 'fit & strong'],
      ],
    );
    expect(items.length, lessThanOrEqualTo(3));
    expect(items.where((i) => i.product != null).length, lessThanOrEqualTo(1),
        reason: 'one product, never a shelf');
    expect(items.any((i) => i.offering?.subtitle.contains('Physiotherapist') ?? false),
        isTrue);
  });

  test('the nutrition row reaches the dietitian', () {
    final items = pvFurtherItems(
      needs: const [kNutritionSupplementNeed],
      offerings: const [
        ['nutritionist', 'dietitian'],
      ],
    );
    expect(items.any((i) => i.offering?.subtitle.contains('Nutritionist') ?? false),
        isTrue);
  });

  test('Nutrition Today: the pitch sits under the plate, above More on food', () {
    final today = kNutritionDoor.sectionsOf(kDietTabToday);
    expect(today.first.inlineSurfaceId, kDietSurfaceForWeek);
    expect(today.first.heading, 'For your week');
  });

  test('wiring: the session screen and the door router draw the rows', () {
    final move = File('lib/screens/move/pv_move_today_screen.dart').readAsStringSync();
    expect(move.contains('PvWhatYouNeed('), isTrue);
    expect(move.contains('PvGoFurtherRail('), isTrue);
    final router = File('lib/screens/doors/pv_door_router.dart').readAsStringSync();
    expect(router.contains('kDietSurfaceForWeek => PvNutritionForWeek(pregnancy: c)'), isTrue);
    final widget = File('lib/screens/pitch/pv_go_further.dart').readAsStringSync();
    expect(widget.contains('your doctor decides the dose'), isTrue,
        reason: 'a supplement is never offered without the doctor line');
  });
}
