// =============================================================================
//  The TTC product flow — the rules that make it not a shop
// -----------------------------------------------------------------------------
//  ⚠️ THESE ARE NOT LAYOUT TESTS. Every one of them guards a promise that is
//  easy to break by being helpful: a shelf that quietly stops saying "do not
//  buy this", a page that grows an invented score, a caveat column that goes
//  empty because somebody had nothing to add.
//
//  Commerce surfaces drift toward selling. That is not cynicism about anyone
//  who edits this file later — it is what happens when every individual change
//  is reasonable and nobody is checking the direction.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_shop_v3.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/ttc/ttc_products_data.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pumpAndSettle();
}


/// Two products that share a shelf — the only pair a comparison is allowed to
/// hold, since a table of "not applicable" teaches nothing.
List<TtcProduct> _twoOnOneShelf() {
  for (final cat in {for (final p in ttcProducts) p.category}) {
    final inCat = ttcProducts.where((p) => p.category == cat).toList();
    if (inCat.length >= 2) return inCat.take(2).toList();
  }
  throw StateError('no shelf holds two products');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // ===========================================================================
  group('the catalogue can say no', () {
    test('at least one product is one we would tell her not to buy', () {
      // The file header has always claimed several entries exist to talk a
      // couple out of a purchase. Until 2026-09-03 none actually did, which
      // made the honesty structural rather than visible — a shelf where
      // nothing is ever "generally not needed" cannot be told apart from a
      // shelf that has no way to say it.
      expect(ttcProducts.where((p) => p.band == TtcRecoBand.skip), isNotEmpty,
          reason: 'nothing on this shelf is rated skip, so the band that '
              'exists to say "do not buy this" is decorative');
    });

    test('every product carries a caveat — a page without one is an advert', () {
      for (final p in ttcProducts) {
        final has = p.watchOuts.isNotEmpty || p.watchOut(false).trim().isNotEmpty;
        expect(has, isTrue, reason: '${p.id} has nothing in "worth considering"');
      }
    });

    test('every product says plainly how strong the evidence is', () {
      for (final p in ttcProducts) {
        expect(p.evidence.meaning.length, greaterThan(40), reason: p.id);
      }
    });

    test('the one with settled evidence is the cheap one, and it is marked', () {
      final folic = ttcProducts.firstWhere((p) => p.id == 'folic');
      expect(folic.band, TtcRecoBand.strong);
      expect(folic.evidence, TtcEvidence.strong);
    });

    test('ids are unique', () {
      final ids = ttcProducts.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every product sits in a real category', () {
      final known = ttcProductCategories.map((c) => c.$1).toSet();
      for (final p in ttcProducts) {
        expect(known, contains(p.category), reason: p.id);
      }
    });
  });

  // ===========================================================================
  //  ⚠️ THIS GROUP USED TO ASSERT THE ABSENCE OF A SCORE, A RATING AND A BUY
  //  BUTTON — because I had left all three out, and then wrote tests requiring
  //  them to stay out. That is how a decision nobody asked for becomes a rule
  //  with a test defending it.
  //
  //  The design has all three and they were asked for. So the guard moves to
  //  where the risk actually is: seed numbers must never contradict the band,
  //  and the buy sheet must never claim a commission we do not take.
  // ===========================================================================
  group('the seed numbers never contradict the recommendation', () {
    test('nothing we would not recommend scores well', () {
      for (final p in ttcProducts) {
        if (p.band == TtcRecoBand.skip || p.band == TtcRecoBand.situational) {
          expect(p.pvScore, lessThan(70),
              reason: '${p.id} is rated "${p.band.label}" and scores '
                  '${p.pvScore}. A page cannot say "generally not needed" and '
                  'print a good score beside it.');
        }
        if (p.band == TtcRecoBand.strong) {
          expect(p.pvScore, greaterThan(85), reason: p.id);
        }
      }
    });

    test('expert agreement tracks the evidence, not the marketing', () {
      for (final p in ttcProducts) {
        if (p.evidence == TtcEvidence.thin) {
          expect(p.expertsPct, lessThan(60),
              reason: '${p.id} has thin evidence and ${p.expertsPct}% of '
                  'experts saying buy — those two cannot both be true');
        }
        if (p.evidence == TtcEvidence.strong) {
          expect(p.expertsPct, greaterThan(80), reason: p.id);
        }
      }
    });

    test('every figure on the page has a value, so no slot renders blank', () {
      for (final p in ttcProducts) {
        expect(p.pvScore, greaterThan(0), reason: p.id);
        expect(p.parentsPct, greaterThan(0), reason: p.id);
        expect(p.expertsPct, greaterThan(0), reason: p.id);
        expect(p.rating, greaterThan(0), reason: p.id);
        expect(p.price, isNotEmpty, reason: p.id);
        expect(p.brand, isNotEmpty, reason: p.id);
        expect(p.retailer, isNotEmpty, reason: p.id);
        expect(p.retailerUrl, startsWith('https://'), reason: p.id);
      }
    });

    test('every product carries at least two voices, one of them critical', () {
      // A review block where nobody has a complaint is a testimonial wall.
      for (final p in ttcProducts) {
        expect(p.voices.length, greaterThanOrEqualTo(2), reason: p.id);
        expect(p.voices.any((v) => v.$2 <= 4), isTrue,
            reason: '${p.id} has nothing but five-star quotes');
      }
    });

    test('every product has real research attached, and a means-for-you line',
        () {
      for (final p in ttcProducts) {
        expect(p.studies, isNotEmpty, reason: p.id);
        for (final st in p.studies) {
          expect(st.$3, isNotEmpty,
              reason: '${p.id}: a study with no "what this means for you"');
          expect(st.$4, isNotEmpty,
              reason: '${p.id}: a study with no source');
        }
      }
    });

    testWidgets('the buy sheet does not claim a commission we do not take',
        (tester) async {
      await _pump(tester, const TtcProductPage(productId: 'folic'));
      // The in-page Buy pill sits below the score card, so it is off-screen at
      // test height. Scroll to it rather than tapping blind.
      // `scrollUntilVisible` cannot be used: the page has two scrollables (the
      // page and the horizontal "Read next" rail) and it demands exactly one.
      await tester.dragUntilVisible(
        find.text('Buy now').first,
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buy now').first);
      await tester.pumpAndSettle();

      // ⚠️ THE DESIGN'S THIRD SENTENCE IS THE POINT OF THIS SHEET. There is no
      // affiliate arrangement in this stage, so it says that rather than
      // borrowing the design's commission wording — and it still promises that
      // money would not change a rating if there ever were any.
      expect(find.textContaining('earns nothing'), findsOneWidget);
      expect(find.textContaining('never change what we recommend'),
          findsOneWidget);
      expect(find.textContaining('Continue to'), findsOneWidget);
      expect(find.text('Stay on this page'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the band is visible before anything is tapped', () {
    testWidgets('the shelf prints it on the card', (tester) async {
      await _pump(tester, const TtcShelfScreen(category: 'supplements'));
      expect(find.text(TtcRecoBand.strong.label.toUpperCase()), findsWidgets);
      expect(find.text(TtcRecoBand.skip.label.toUpperCase()), findsWidgets,
          reason: '"generally not needed" is not readable on the shelf, so it '
              'has been demoted to fine print');
    });

    testWidgets('and the default shelf hides nothing', (tester) async {
      await _pump(tester, const TtcShelfScreen(category: 'supplements'));
      // A shelf that opens already filtered has quietly become a shop again.
      // The chip row became a Filters button and a sheet — the design's own
      // arrangement — so the assertion moves to the thing that matters: no
      // filter is on, the badge is absent, and every item is listed.
      expect(find.text('Filters'), findsOneWidget);
      expect(find.textContaining('Sort:'), findsOneWidget);
      final all = ttcProductsIn('supplements').length;
      expect(find.textContaining('$all items'), findsOneWidget);
    });

    testWidgets('price is on the card, not one tap deeper', (tester) async {
      await _pump(tester, const TtcShelfScreen(category: 'supplements'));
      for (final p in ttcProductsIn('supplements')) {
        // The card shows the single figure; `priceEn` keeps the honest range
        // for the research copy and the details rows.
        expect(find.text(p.price), findsWidgets, reason: p.id);
      }
    });
  });

  // ===========================================================================
  group('it is reachable, and it opens what it names', () {
    test('the shop has a surface id the router resolves', () {
      expect(ttcScreenForSurface('ttc_shop'), isNotNull);
    });

    test('the old flat library is still routed and untouched', () {
      // Ask Veda's deep links land there. Retiring it is a separate decision.
      expect(ttcScreenForSurface('ttc_products'), isNotNull);
    });

    test('every product tile id on a focus page resolves to a product', () {
      // The wiring gate: an id that does not resolve renders perfectly and
      // does nothing.
      for (final p in ttcProducts) {
        expect(ttcProductById(p.id), isNotNull);
      }
      expect(ttcProductById('no_such_product'), isNull);
    });

    testWidgets('categories → shelf → product all build', (tester) async {
      await _pump(tester, const TtcShopScreen());
      await _pump(tester, const TtcShelfScreen(category: 'kits'));
      await _pump(tester, const TtcProductPage(productId: 'lh_strips'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unknown id opens a plain "gone", never another product',
        (tester) async {
      await _pump(tester, const TtcProductPage(productId: 'nonsense'));
      expect(find.text('That one is gone.'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the honest look never has an empty column', () {
    testWidgets('both blocks render for a product with both lists',
        (tester) async {
      await _pump(tester, const TtcProductPage(productId: 'folic'));
      expect(find.text('AN HONEST LOOK'), findsOneWidget);
      expect(find.text("WHAT'S GOOD"), findsOneWidget);
      // ⚠️ `findsWidgets`, NOT `findsOneWidget`, AND THE REASON IS A REAL
      // COLLISION IN THE DESIGN'S OWN VOCABULARY. The amber block is labelled
      // "Worth considering" and the `consider` recommendation band is ALSO
      // "Worth considering" — both straight from the design project. So on a
      // page whose "Read next" rail happens to include a `consider` product,
      // the same words render twice for two different meanings.
      //
      // Left as the design has it rather than renamed: these are the words
      // that were specified, and inventing a synonym is the exact habit that
      // caused four formats to ship wrong. Recorded in `docs/STILL-OPEN.md`
      // §24.8 as a naming question for the design, not a bug to patch here.
      expect(find.text('WORTH CONSIDERING'), findsWidgets);
    });

    testWidgets('and "before you buy" comes before the honest look',
        (tester) async {
      await _pump(tester, const TtcProductPage(productId: 'fertility_blend'));
      // Section eyebrows render uppercase — `ttcShopEyebrow`, the design
      // system's signature, Manrope 11/800 in the action violet.
      final before = tester.getTopLeft(find.text('BEFORE YOU BUY')).dy;
      final honest = tester.getTopLeft(find.text('AN HONEST LOOK')).dy;
      expect(before, lessThan(honest),
          reason: 'the sentence that narrows before anything sells must sit '
              'directly under the hero');
    });
  });

  // ===========================================================================
  //  The three defects that were visible on a device and invisible to the
  //  suite — 2026-09-04
  // ---------------------------------------------------------------------------
  //  ⚠️ ALL THREE SHIPPED PAST A GREEN RUN, AND THAT IS THE POINT OF THIS GROUP.
  //  Every test above asserts what the product SAYS. None of them asserted that
  //  a control could be tapped, that a field was painted the colour it was
  //  given, or that a widget had the ancestors Flutter needs to draw it. Those
  //  are exactly the failures a screenshot catches and a suite does not, so
  //  these are written against the mechanism rather than the appearance.
  // ===========================================================================
  group('drawn correctly, not just written correctly', () {
    setUp(TtcCompareTray.instance.clear);

    testWidgets('the compare bar sits under a Material, so its text is not '
        'struck through with amber', (tester) async {
      // The failure: the bar is a `Positioned` inside a `Stack` as a SIBLING of
      // the `Scaffold`, so nothing above it provides a `Material`. Flutter's
      // response to a `Text` with no `Material` ancestor is to draw a dashed
      // amber underline under every string — which is what was on screen, and
      // which I twice diagnosed as overflow because the two look similar in a
      // screenshot.
      //
      // Asserting the ancestor rather than the pixels is deliberate: it is the
      // cause, it survives a restyle, and it fails for the right reason.
      TtcCompareTray.instance.toggle(ttcProducts.first.id);
      TtcCompareTray.instance.toggle(ttcProducts[1].id);

      await _pump(tester,
          TtcShelfScreen(category: ttcProducts.first.category));

      final label = find.text('Compare');
      expect(label, findsWidgets);
      expect(
        find.ancestor(of: label.first, matching: find.byType(Material)),
        findsWidgets,
        reason: 'a Text with no Material ancestor draws amber underlines',
      );
    });

    testWidgets('the search field turns the global input theme off', (tester) async {
      // The failure: the app's `InputDecorationTheme` sets `filled: true` with
      // `surfaceContainer` and its own focused border. `border: InputBorder.none`
      // replaces only the FALLBACK border — `enabledBorder` and `focusedBorder`
      // still came from the theme, and `filled` was never touched at all. So a
      // field asked to be plain rendered as a lilac panel with a purple ring.
      //
      // The lesson generalises past this screen: a widget-level `border:` is not
      // an override of a theme, and any field that must look unstyled has to
      // turn off every slot the theme fills.
      await _pump(tester,
          TtcShelfScreen(category: ttcProducts.first.category));

      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields, isNotEmpty, reason: 'the shelf carries a search field');
      for (final f in fields) {
        final d = f.decoration!;
        expect(d.filled, isFalse);
        expect(d.enabledBorder, InputBorder.none);
        expect(d.focusedBorder, InputBorder.none);
      }
    });

    testWidgets('compare opens at every count, including none', (tester) async {
      // The failure: the shop entry's compare row was `picked.length < 2 ? null
      // : ...`. A row that looks tappable and is not reads as broken, and was
      // reported as exactly that.
      await _pump(tester, const TtcCompareScreen());
      expect(find.text('Nothing picked yet.'), findsOneWidget);

      TtcCompareTray.instance.toggle(ttcProducts.first.id);
      await tester.pumpAndSettle();
      expect(find.text('One picked. Pick one more.'), findsOneWidget);

      final second = ttcProducts
          .firstWhere((p) => p.category == ttcProducts.first.category
              && p.id != ttcProducts.first.id);
      TtcCompareTray.instance.toggle(second.id);
      await tester.pumpAndSettle();
      expect(find.text('Side by side.'), findsOneWidget);
    });

    testWidgets('the comparison shows the union of the two spec lists, not the '
        'intersection', (tester) async {
      // An intersection would hide the row where one product states a dose and
      // the other stays silent — which is the difference somebody came to find.
      // A dash is an answer; a missing row is a concealment.
      final pair = _twoOnOneShelf();
      for (final p in pair) {
        TtcCompareTray.instance.toggle(p.id);
      }
      await _pump(tester, const TtcCompareScreen());

      final keys = <String>{for (final p in pair) for (final s in p.specs) s.$1};
      for (final k in keys) {
        expect(find.text(k.toUpperCase()), findsWidgets,
            reason: '$k is stated by one of the pair, so it must have a row');
      }
    });

    testWidgets('the framing is above the table, never below it', (tester) async {
      // A two-column grid of ticks is persuasive furniture: it implies the
      // winner is whichever column has more of them. The line that says which
      // row matters has to be read BEFORE the grid, or it is a footnote.
      for (final p in _twoOnOneShelf()) {
        TtcCompareTray.instance.toggle(p.id);
      }
      await _pump(tester, const TtcCompareScreen());

      final framing = tester.getTopLeft(find.textContaining(
          'the evidence row matters more'));
      final firstRow = tester.getTopLeft(find.text('EVIDENCE').first);
      expect(framing.dy, lessThan(firstRow.dy));
    });
  });
}
