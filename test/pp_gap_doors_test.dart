// The doors built 2026-10-02 from the parenting gap analysis (fork, taken
// 2026-10-07): Keeping your child safe, Family, Special care, Papers and money. Wiring gate for each: the
// home tile, the section and the door share one id, five tabs place every
// area once, every page is written, and every cross-link resolves.

import 'dart:io';
import 'package:parentveda/screens/post_pregnancy/pp_baby_food_check_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_maa_can_i_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/services/life_stage_store.dart';

const _ids = [
  'parenting_safety',
  'parenting_family',
  'parenting_special_care',
  'parenting_papers',
];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final id in _ids) {
    group(id, () {
      test('home tile, section, door and surface agree', () {
        expect(bracketsFor(LifeStage.parenting).map((b) => b.id), contains(id));
        expect(ppSectionFor(id), isNotNull);
        expect(ppDoorFor(id), isNotNull);
        expect(ppScreenForSurface('pp_section/$id'), isNotNull);
      });

      test('five tabs, every area placed once', () {
        final s = ppSectionFor(id)!;
        final door = ppDoorFor(id)!;
        expect(door.tabs, hasLength(5));
        final placed = [for (final t in door.tabs) ...t.areaIds];
        expect(placed.toSet(), {for (final a in s.areas) a.id});
        expect(placed, hasLength(placed.toSet().length));
      });

      test('every page is written and opens with an intro', () {
        for (final p in ppSectionFor(id)!.allPages) {
          expect(p.comingSoon, isFalse, reason: p.id);
          expect(p.blocks.first, isA<PpIntro>(), reason: p.id);
        }
      });

      test('every cross-link resolves', () {
        for (final p in ppSectionFor(id)!.allPages) {
          for (final l in p.blocks.whereType<PpLink>()) {
            expect(ppScreenForSurface(l.surfaceId!), isNotNull,
                reason: '${p.id} -> ${l.surfaceId}');
          }
        }
      });
    });
  }

  test('a page id is never in two sections', () {
    final seen = <String, String>{};
    for (final s in kPpSections) {
      for (final p in s.allPages) {
        expect(seen[p.id], isNull,
            reason: '${p.id} is in ${seen[p.id]} and ${s.id}');
        seen[p.id] = s.id;
      }
    }
  });

  // The food breadth and recipe checks from the fork come in with those
  // features (food wave), not with the doors.

  test("the mother's can-I lookup is reachable from the You, Maa door", () {
    expect(ppMaaCanICount, greaterThanOrEqualTo(330));
    expect(ppScreenForSurface('pp_maa_can_i'), isA<PpMaaCanIScreen>());
    final page = ppSectionFor('parenting_maternal')!.pageById('cani_search')!;
    expect(page.toolSurfaceId, 'pp_maa_can_i');
  });

  // Taken from the fork with the 289-food lookup and the 110 recipes (2026-10-07).
  test('the food lookup covers the Indian kitchen, for the child and for the mother', () {
    expect(ppBabyFoodCount, greaterThanOrEqualTo(285));
    expect(kPpMaaFoodDefault, isNotEmpty);
  });

  test('the food and can-I lookups stay Indian: no beef, pork, bacon or ham', () {
    final banned = RegExp(r"\b(beef|pork|bacon|ham|hot dog|veal|lard)\b", caseSensitive: false);
    for (final f in [
      'lib/screens/post_pregnancy/pp_baby_food_check_screen.dart',
      'lib/screens/post_pregnancy/pp_maa_can_i_screen.dart',
      'lib/screens/post_pregnancy/pp_food_data.dart',
    ]) {
      final hits = banned.allMatches(File(f).readAsStringSync()).map((m) => m[0]);
      expect(hits, isEmpty, reason: f);
    }
  });

  test('the recipe catalogue is big enough to browse, with no honey under one', () {
    expect(kFoodRecipes.length, greaterThanOrEqualTo(135));
    final ids = kFoodRecipes.map((r) => r.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final r in kFoodRecipes.where((r) => r.ageTag.startsWith('6'))) {
      expect(r.ingredients.join(' ').toLowerCase().contains('honey'), isFalse, reason: r.id);
    }
  });
}
