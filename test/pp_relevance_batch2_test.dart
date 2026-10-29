// =============================================================================
//  Parenting relevance, Batch 2 (docs/door-relevance/PARENTING-GAP.md)
// -----------------------------------------------------------------------------
//  PP 2. One age for development content: tips, the reads fallback and
//  products follow the corrected age of a baby born early, like the
//  activities (Batch 1). Vaccines, growth and messages keep the birthday.
//
//  PP 3 and PP 5. The home and the phase page read the Store's catalogue,
//  keep only what suits the age, one per category, and never pad with a
//  product outside it. With nothing for the age, a row offers the Store.
//
//  PP 12. The Brain tab's "One thing, today" is the first of the home's three.
//
//  PP 17. "Continue reading" is kept per child.
//
//  Source scans pin the wiring: a correct helper nobody calls is the failure
//  this repo has hit.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_products.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_reads.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phase_page.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_catalog_store.dart';

String _src(String path) => File(path).readAsStringSync();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final home = _src('lib/screens/post_pregnancy/pp_home_v3.dart');

  // ==========================================================================
  //  PP 2. Corrected age for development content
  // ==========================================================================
  group('PP 2: one age for development content', () {
    test('tips, reads and products read the corrected age', () {
      expect(_src('lib/screens/post_pregnancy/pp_home_reads.dart'),
          contains('ageTipsFor(child.devAgeInWeeks.floor())'));
      // One picker with the morning message since PP 11 (`ageTipOn`), still
      // on the corrected age. Was: 'ageTipsFor(child.devAgeInWeeks.floor())'.
      expect(_src('lib/screens/post_pregnancy/pp_daily_tips.dart'),
          contains('ageTipOn(on ?? DateTime.now(), child.devAgeInWeeks.floor())'));
      expect(home, contains('_readsForAge(child.devAgeInMonths, 3)'));
      expect(home, contains('ppCatalogProducts(child.devAgeInMonths'));
      expect(_src('lib/services/pv_catalog_store.dart'),
          contains('return p.suitsAge(kids.devAgeInMonths);'));
    });
  });

  // ==========================================================================
  //  PP 3 and PP 5. One catalogue, only what fits
  // ==========================================================================
  group('PP 3 and PP 5: the rail is the Store\'s, and only what fits', () {
    test('a five-year-old\'s rail holds nothing outside the age', () {
      final items = ppCatalogProducts(60);
      expect(items.length, lessThanOrEqualTo(6));
      for (final p in items) {
        expect(p.suitsAge(60), isTrue, reason: p.name);
        expect(p.reviewOnly, isFalse, reason: p.name);
        expect(p.stage, LifeStage.parenting, reason: p.name);
      }
    });

    test('one product per category, so it reads as a shortlist', () {
      for (final m in [0, 6, 14, 30, 60]) {
        final cats = ppCatalogProducts(m).map((p) => p.categoryId).toList();
        expect(cats.toSet().length, cats.length, reason: 'month $m');
      }
    });

    test('the phase page uses the same rule at the phase\'s first month', () {
      for (final ph in kPhases) {
        final m = ph.startMonth.floor();
        expect(ppPhaseProducts(ph, 6).map((p) => p.id),
            ppCatalogProducts(m, limit: 6).map((p) => p.id),
            reason: ph.name);
      }
    });

    test('the home\'s rail is the Store\'s "For you" for the child on screen',
        () async {
      SharedPreferences.setMockInitialValues({});
      final kids = ChildProfileStore.instance..resetForTest();
      await kids.addChild(
          name: 'Aarav',
          isBoy: true,
          dob: DateTime.now().subtract(const Duration(days: 430)));
      expect(
          ppCatalogProducts(kids.devAgeInMonths, limit: 6)
              .map((p) => p.id)
              .toList(),
          PvCatalogStore.instance
              .forYou(LifeStage.parenting)
              .map((p) => p.id)
              .toList(),
          reason: 'the Store and the home must not disagree');
      kids.resetForTest();
    });

    test('the home and the phase page are wired to it, with an empty state',
        () {
      expect(home, contains('PpCatalogRail('));
      expect(home, contains("ValueKey('pp_home_products_empty')"));
      expect(home, contains("_openSurface(context, 'pp_products')"));
      expect(home, contains('PvCatalogStore.instance, // the store sheet'));
      final phase = _src('lib/screens/post_pregnancy/pp_phase_page.dart');
      expect(phase, contains('ppCatalogProducts(phase.startMonth.floor()'));
      expect(phase, contains("pp_phase_products_empty_"));
    });
  });

  // ==========================================================================
  //  PP 12. The Brain tab agrees with the home
  // ==========================================================================
  test('PP 12: the Brain tab shows the first of the home\'s three', () {
    final brain = _src('lib/screens/post_pregnancy/pp_brain_tab.dart');
    expect(brain, contains('.todays(months, childId: child.activeChildId)'));
    expect(brain, contains('three.isNotEmpty ? three.first'));
    expect(brain, contains('PpHomeActivitiesStore.instance, _search'));
    // The home asks the store the same question.
    expect(home,
        contains('.todays(child.devAgeInMonths, childId: child.activeChildId)'));
  });

  // ==========================================================================
  //  PP 17. Continue reading, per child
  // ==========================================================================
  group('PP 17: continue reading follows the child', () {
    final section = kPpSections.firstWhere((s) => s.allPages.length >= 2);
    final pageA = section.allPages[0].id, pageB = section.allPages[1].id;
    late ChildProfileStore kids;
    final store = PpLastPageStore.instance;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      kids = ChildProfileStore.instance..resetForTest();
      store.debugReset();
    });

    tearDown(() {
      kids.resetForTest();
      store.debugReset();
    });

    test('a page read for one child is not offered on the sibling\'s home',
        () async {
      final older = await kids.addChild(
          name: 'Aarav', isBoy: true, dob: DateTime(2023, 6, 1));
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final baby = await kids.addChild(
          name: 'Kiara', isBoy: false, dob: DateTime(2026, 8, 1));

      await kids.switchTo(older.id);
      store.opened(section.id, pageA);
      expect(store.last?.page.id, pageA);

      await kids.switchTo(baby.id);
      expect(store.last, isNull, reason: 'the baby has read nothing yet');
      store.opened(section.id, pageB);
      expect(store.last?.page.id, pageB);

      await kids.switchTo(older.id);
      expect(store.last?.page.id, pageA, reason: 'each child keeps its place');
    });

    test('each child is its own cloud item, and `last` stays', () async {
      final c = await kids.addChild(
          name: 'Aarav', isBoy: true, dob: DateTime(2025, 6, 1));
      store.opened(section.id, pageA);
      final items = store.cloudItems();
      expect(items.keys, containsAll(['last', 'child:${c.id}']));
    });

    test('a page saved before the change shows until the first new open',
        () async {
      await kids.addChild(name: 'Aarav', isBoy: true, dob: DateTime(2025, 6, 1));
      store.applyCloudItems({
        'last': {'s': section.id, 'p': pageA},
      });
      expect(store.last?.page.id, pageA);
    });

    test('the stand-in child has its own key', () {
      expect(PpLastPageStore.childKey(null), 'none');
      expect(PpLastPageStore.childKey(''), 'none');
      expect(PpLastPageStore.childKey('child_1'), 'child_1');
    });
  });
}
