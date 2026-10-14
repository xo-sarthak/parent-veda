// =============================================================================
//  The team's product sheets in the store (2026-10-13):
//  lib/data/products/pv_sheet_products.dart, generated data from
//  tools/products/xlsx_to_dart.py, and the kids' book shelf.
//
//  The user's decisions, each checked on all of the data:
//    · shown as ParentVeda's shortlist: no invented price, link or photo;
//    · sheet picks LEAD a category the store already had, older ones below;
//    · toy scores rank the shelf and are shown;
//    · held shelves (fetal dopplers, herbal teas) appear nowhere;
//    · children's books on the parenting Reading shelf, by age.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/kids_books.dart';
import 'package:parentveda/data/products/pv_sheet_products.dart';
import 'package:parentveda/data/products/sheet/catalogue.dart';
import 'package:parentveda/data/products/sheet/toys.dart';
import 'package:parentveda/screens/book_companion_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_kids_books_shelf.dart';
import 'package:parentveda/screens/products/pv_product_screen.dart';
import 'package:parentveda/screens/products/pv_shelf_screen.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_catalog_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final store = PvCatalogStore.instance;
  final sheet = [for (final p in store.all) if (p.shortlist) p];

  group('the sheets in the catalogue', () {
    test('every live pick and every toy is in, with its category and sub', () {
      final live = kSheetPicks.where((p) => !p.held).length;
      expect(sheet, hasLength(live + kSheetToys.length));
      for (final p in sheet) {
        final c = store.category(p.categoryId);
        expect(c, isNotNull, reason: '${p.id}: no category ${p.categoryId}');
        expect(c!.subs.map((s) => s.id), contains(p.subId), reason: p.id);
      }
    });

    test('no invented price, link or photo', () {
      for (final p in sheet) {
        expect(p.price, 0, reason: p.id);
        expect(p.buyUrl, isNull, reason: p.id);
        expect(p.soldHere, isFalse, reason: p.id);
        expect(p.images, isEmpty, reason: p.id);
        expect(p.priceNote, 'Price varies', reason: p.id);
        expect(p.reco, isNull, reason: '${p.id}: no ParentVeda recommendation was written');
      }
    });

    test('ids are unique across the whole store', () {
      final ids = store.all.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('the held shelves appear nowhere', () {
      final held = {for (final p in kSheetPicks) if (p.held) p.id};
      expect(held, hasLength(20));
      expect(store.all.where((p) => held.contains(p.id)), isEmpty);
      for (final c in store.categories) {
        for (final s in c.subs) {
          expect(s.name, isNot(anyOf('Portable Fetal Dopplers', 'Herbal Anti-Nausea Teas')));
        }
      }
    });

    test('every sheet category draws a mark, never the fallback glyph', () {
      for (final c in store.categories.where((c) => c.id.startsWith('pvs_'))) {
        expect(kPvSheetCategoryMarks, contains(c.id), reason: c.name);
      }
    });

    test('a sheet sub joins the category it already was', () {
      final c = store.category('pregnancy_pillow')!;
      expect(c.subs.map((s) => s.name), contains('Ergonomic Pregnancy Pillows'));
      expect(c.guidanceFor(sheetSubId('Ergonomic Pregnancy Pillows'))!.lookFor, isNotEmpty);
    });
  });

  group('order and scores', () {
    test('sheet picks lead a shared category; the older products follow', () {
      final list = store.inCategory('pregnancy_pillow')..sort(pvShortlistFirst);
      final firstOld = list.indexWhere((p) => !p.shortlist);
      expect(firstOld, greaterThan(0), reason: 'both kinds are on this shelf');
      expect(list.skip(firstOld).any((p) => p.shortlist), isFalse);
    });

    test('toys rank by score, and the card says it', () {
      final toys = store.inCategory(kSheetToyCategoryId).where((p) => p.shortlist).toList()..sort(pvShortlistFirst);
      final scored = toys.where((t) => t.score != null).toList();
      for (var i = 1; i < scored.length; i++) {
        expect(scored[i - 1].score!, greaterThanOrEqualTo(scored[i].score!));
      }
      expect(toys.indexOf(scored.last), lessThan(toys.indexWhere((t) => t.score == null)));
    });

    testWidgets('the shelf card shows the score', (t) async {
      t.view.physicalSize = const Size(1170, 4000);
      t.view.devicePixelRatio = 3.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: PvShelfScreen(categoryId: kSheetToyCategoryId)));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('ParentVeda score'), findsWidgets);
      expect(t.takeException(), isNull);
    });
  });

  group('the product page', () {
    Future<void> open(WidgetTester t, String id) async {
      t.view.physicalSize = const Size(1200, 9000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: PvProductScreen(productId: id)));
      await t.pump(const Duration(milliseconds: 500));
    }

    testWidgets('a pick: the shortlist block, its week, what the team looked for, and no buy button', (t) async {
      final p = sheet.firstWhere((p) => p.stage == LifeStage.pregnancy && p.badge == 'Budget pick');
      await open(t, p.id);
      expect(find.byKey(const ValueKey('pv_shortlist_block')), findsOneWidget);
      expect(find.text('Good to have by week ${p.weekFrom}'), findsOneWidget);
      expect(find.textContaining('What the team looked for'), findsOneWidget);
      expect(find.byKey(const ValueKey('pv_shortlist_bar')), findsOneWidget);
      expect(find.text('Add to cart'), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('a scored toy: its score, its parts and its skills', (t) async {
      final p = sheet.firstWhere((p) => p.score != null && p.scoreParts.isNotEmpty);
      await open(t, p.id);
      expect(find.text('${p.score}'), findsOneWidget);
      expect(find.text(p.scoreParts.first.$1), findsOneWidget);
      expect(find.text(p.skills.first), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('a book pick with a companion opens the companion', (t) async {
      final p = sheet.firstWhere((p) => sheetBookCompanionFor(p) != null);
      await open(t, p.id);
      expect(find.byType(BookCompanionScreen), findsOneWidget);
    });

    test('only an exact companion title matches', () {
      final books = sheet.where((p) => p.badge == 'Book').toList();
      final matched = {for (final p in books) if (sheetBookCompanionFor(p) != null) p.name};
      expect(matched, contains("What to Expect When You're Expecting"));
      expect(matched.where((n) => n.startsWith('Expecting Better')), isNotEmpty);
    });
  });

  group('books to read with your child', () {
    test('285 books, each with an age, a theme and a way to read it', () {
      expect(kKidsBooks, hasLength(285));
      for (final b in kKidsBooks) {
        expect(b.ageMax, greaterThan(b.ageMin), reason: b.title);
        expect(b.theme, isNotEmpty, reason: b.title);
        expect(b.mode, anyOf('Read To Child', 'Read With Child'), reason: b.title);
      }
    });

    test('the shelf follows the child\'s age, and shows every book without one', () {
      expect(kidsBooksFor(null), hasLength(kKidsBooks.length));
      for (final b in kidsBooksFor(12)) {
        expect(b.suits(12), isTrue, reason: b.title);
      }
      final ranks = kidsBooksFor(40).map((b) => b.rank.index).toList();
      expect(ranks, orderedEquals([...ranks]..sort()), reason: 'Essentials first');
    });

    testWidgets('the shelf renders, and a book opens its sheet', (t) async {
      t.view.physicalSize = const Size(1170, 4000);
      t.view.devicePixelRatio = 3.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: PpKidsBooksShelf(p: pvStorePalette))),
      ));
      await t.pump();
      final first = kidsBooksFor(null).first;
      expect(find.text(first.title), findsOneWidget);
      await t.tap(find.text(first.title));
      await t.pumpAndSettle();
      expect(find.byKey(ValueKey('pp_kids_book_sheet_${first.id}')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    test('wired: the Reading home carries the shelf', () {
      expect(File('lib/screens/post_pregnancy/reading_home_screen.dart').readAsStringSync(),
          contains('PpKidsBooksShelf(p: p)'));
    });
  });
}
