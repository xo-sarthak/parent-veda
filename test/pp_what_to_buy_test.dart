// =============================================================================
//  What to buy, held against its brief
// -----------------------------------------------------------------------------
//  `What_to_buy_parenting.pdf` as assertions. The brief is explicit that this
//  tile is a shop and not a door — no section, no tabs — so what is held is
//  the three link fixes, the one source for buying advice, the soft stage
//  sort, and the eight placeholder guides in the ledger. What fails silently
//  here: a "compare swaddles" link landing on an empty tray again; the
//  bottle offering the steriliser's guide; the skip link on the grid; a
//  third hand-written copy of the advice; a placeholder that opens.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_products_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/products_compare_screen.dart';
import 'package:parentveda/screens/product_guide/product_guide_data.dart';

Iterable<PpLink> _links(String section) sync* {
  for (final p in ppSectionFor(section)!.allPages) {
    for (final b in p.blocks) {
      if (b is PpLink) yield b;
    }
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the shop is not a door, on the brief', () {
    expect(ppDoorFor('parenting_buying'), isNull, reason: 'no section, no tabs: the two-door hub stays');
    expect(ppSectionFor('parenting_buying'), isNull);
  });

  group('fix 1: the compare tray arrives loaded', () {
    test('every compare link from Health and First 40 Days names a shelf', () {
      final compares = [
        for (final s in ['parenting_health', 'parenting_first_40'])
          for (final l in _links(s))
            if (l.surfaceId != null && l.surfaceId!.startsWith('pp_compare')) l,
      ];
      expect(compares, hasLength(7), reason: 'the seven the brief counts');
      for (final l in compares) {
        expect(l.surfaceId, startsWith('pp_compare/'), reason: l.label);
        final shelf = l.surfaceId!.substring('pp_compare/'.length);
        expect(productCatalog.any((p) => p.sub == shelf), isTrue, reason: '${l.label}: "$shelf" is not a shelf');
      }
    });

    test('the route seeds the tray with that shelf, and the bare route keeps the empty state', () {
      PpCompareStore.instance.clear();
      expect(ppScreenForSurface('pp_compare/Sleepwear & sacks'), isA<ProductsCompareScreen>());
      expect(PpCompareStore.instance.selected.map((p) => p.sub).toSet(), {'Sleepwear & sacks'});
      expect(PpCompareStore.instance.count, 2, reason: 'that shelf holds two; the tray takes two');
      expect(ppScreenForSurface('pp_compare/Rash creams'), isA<ProductsCompareScreen>());
      expect(PpCompareStore.instance.count, 1, reason: 'a one-product shelf: the "one" state, not empty');
      PpCompareStore.instance.clear();
      expect(ppScreenForSurface('pp_compare'), isA<ProductsCompareScreen>());
      expect(PpCompareStore.instance.count, 0);
    });
  });

  group('fix 2: the guide matcher', () {
    test('the bottle offers no guide; the steriliser offers its own; nothing matches on a shared word', () {
      expect(guideForProduct(id: 'bottle', name: 'Anti-Colic Feeding Bottle'), isNull);
      expect(guideForProduct(id: 'steriliser', name: 'Steam Steriliser')?.id, 'bottle_sterilizer');
      expect(guideForProduct(id: 'lotion', name: 'Soothe Baby Lotion')?.id, 'baby_lotion');
      expect(guideForProduct(id: 'thermometer', name: 'Forehead Thermometer'), isNull);
      expect(guideForProduct(name: 'something feeding related'), isNull, reason: 'no name matching');
    });
  });

  group('fix 3: the skip link', () {
    test('"things worth skipping" opens the guides, where skipping lives', () {
      final l = _links('parenting_development').firstWhere((l) => l.label.contains('worth skipping'));
      expect(l.surfaceId, 'pp_product_guide');
    });
  });

  group('one source for the buying advice', () {
    test('the compare panel reads the shelf guidance card', () {
      final g = compareGuideForShelf('Sleep', 'Soothers & white noise');
      expect(g.whatMatters, kPpGuides['Soothers & white noise']!.lookFor);
      final src = File('lib/screens/post_pregnancy/products_compare_screen.dart').readAsStringSync();
      final live = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
      expect(live.contains('compareGuideFor(a.category)'), isFalse, reason: 'the third copy is not read');
      expect(live.contains('compareGuideForShelf('), isTrue);
    });
  });

  group('the soft age rule', () {
    test('her stage is a default and a sort, never a filter', () {
      expect(ppStageForMonths(1), 'Newborn · 0–3m');
      expect(ppStageForMonths(8), '6–12 months');
      expect(ppStageForMonths(30), '2 years +');
      final src = File('lib/screens/post_pregnancy/products_discovery_screen.dart').readAsStringSync();
      expect(src.contains('ppStageCategories(ppStageForMonths('), isTrue);
      expect(src.contains("_stage = ppStageForMonths"), isFalse, reason: 'the filter is not pre-set; only the order changes');
    });
  });

  group('the eight placeholders', () {
    test('each holds its place, has no verdict to fake, and is in the ledger', () {
      final soon = kProductGuides.where((g) => g.comingSoon).toList();
      expect(soon.map((g) => g.id), containsAll([
        'before_baby_essentials', 'things_to_skip', 'car_seat', 'cot_mattress',
        'cloth_or_disposable', 'mosquito_protection', 'second_hand', 'season_born',
      ]));
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final g in soon) {
        expect(g.verdict, isEmpty, reason: '${g.id}: nothing written');
        expect(ledger.contains(g.id), isTrue, reason: '${g.id} is a placeholder nobody has logged as owed');
      }
    });

    test('the catalogue bottle still carries no buy button (IMS Act)', () {
      final bottle = productCatalog.firstWhere((p) => p.id == 'bottle');
      expect(ppCanBuy(bottle), isFalse, reason: 'information only, by law');
    });
  });
}
