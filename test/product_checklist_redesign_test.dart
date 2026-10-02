// =============================================================================
//  The Product Checklist, freshened (2026-10-02).
//
//  The user: "it uses outdated emojis that are not used in the app, and glyphs
//  or marks that are not used any more. Update it, make sure it does not sound
//  bad, and use Mobbin to make it less confusing."
//
//  What this holds, on the real screens:
//    · no emoji is drawn anywhere in the tool (home, the starter sheet, a list,
//      the product picker): a product shows its photo or the family bag mark,
//      a list wears the TTC mark family, and the old hub-mark wells are gone;
//    · ticking is one tap with no dialog: it says what it did and offers Undo;
//    · ticked things sink into a "Got" group and the foot shows what is left;
//    · the foot is ONE action, "Add what's left to cart (n)", hidden when
//      nothing is left; "Save list" (which saved nothing) is gone;
//    · the words are the plainer ones, and "Affiliate" is not a word she sees.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/doors/pv_list_row.dart' show PvMarkWell;
import 'package:parentveda/screens/tools/product_checklist_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tool_marks.dart' show TtcMarkLeading;
import 'package:parentveda/screens/cart_screen.dart';
import 'package:parentveda/services/cart_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/product_checklist_store.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    // A trailing comment may name the old thing (kept for revert); only code counts.
    .map((l) => l.contains('//') ? l.substring(0, l.indexOf('//')) : l)
    .join('\n');

bool _isEmoji(int r) =>
    r >= 0x1F000 || (r >= 0x2600 && r <= 0x27BF && r != 0x2713 && r != 0x2714);

/// Every Text on screen that carries an emoji, so a failure names it.
List<String> _emojiTexts(WidgetTester t) => [
      for (final w in t.widgetList<Text>(find.byType(Text, skipOffstage: false)))
        if ((w.data ?? w.textSpan?.toPlainText() ?? '').runes.any(_isEmoji))
          w.data ?? w.textSpan!.toPlainText(),
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController c;
  late S s;
  final store = ProductChecklistStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 100)));
    await c.load();
    s = S(c.language);
    await store.init();
    for (final l in List.of(store.checklists)) {
      store.deleteChecklist(l.id);
    }
  });

  Future<void> pump(WidgetTester t, {double scale = 1.0, double width = 900}) async {
    t.view.physicalSize = Size(width, 3000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: ProductChecklistScreen(controller: c),
    ));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
  }

  /// Adopt a starter and open its list, as she would.
  Future<String> openStarter(WidgetTester t, {int index = 0}) async {
    final id = store.adoptCurated(kCuratedChecklists[index]);
    await pump(t);
    await t.tap(find.text(kCuratedChecklists[index].name).first);
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    return id;
  }

  group('the home', () {
    testWidgets('no emoji, no old hub wells; the TTC mark family instead', (t) async {
      await pump(t);
      expect(_emojiTexts(t), isEmpty);
      expect(find.byType(PvMarkWell, skipOffstage: false), findsNothing);
      // Each starter row and the empty card wear a family mark.
      expect(find.byType(TtcMarkLeading, skipOffstage: false), findsWidgets);
      for (final l in kCuratedChecklists) {
        expect(find.text(l.name), findsOneWidget);
      }
      expect(t.takeException(), isNull);
    });

    testWidgets('the plainer words', (t) async {
      await pump(t);
      expect(find.text('Starter lists'), findsOneWidget);
      expect(find.text('Curated starters'), findsNothing);
      expect(find.textContaining('Start from a ready-made list'), findsOneWidget);
      expect(find.textContaining('No lists yet'), findsOneWidget);
    });

    testWidgets('a starter opens a sheet with no emoji, and "Use this list"', (t) async {
      await pump(t);
      await t.tap(find.text(kCuratedChecklists.first.name));
      await t.pumpAndSettle();
      expect(find.text('Use this list'), findsOneWidget);
      expect(_emojiTexts(t), isEmpty);
      expect(find.byType(PvMarkWell, skipOffstage: false), findsNothing);
    });

    testWidgets('holds at 1.5x text on a narrow phone', (t) async {
      store.adoptCurated(kCuratedChecklists.first);
      await pump(t, scale: 1.5, width: 360);
      expect(t.takeException(), isNull);
    });
  });

  group('a list', () {
    testWidgets('no emoji; each item has a round tick; the foot is one action',
        (t) async {
      final id = await openStarter(t);
      final list = store.byId(id)!;
      expect(_emojiTexts(t), isEmpty);
      for (final it in list.items) {
        expect(find.byKey(ValueKey('pcl_tick_${it.id}')), findsOneWidget);
      }
      expect(find.byType(Checkbox), findsNothing);
      expect(find.byKey(const ValueKey('pcl_cart_bar')), findsOneWidget);
      expect(find.text("Add what's left to cart (3)"), findsOneWidget);
      // "Save list" saved nothing; it is gone, and the page says it saves.
      expect(find.text(s.pclSaveList), findsNothing);
      expect(find.byKey(const ValueKey('pcl_saved_auto')), findsOneWidget);
      expect(find.text('Saved as you go'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('a tick is one tap: no dialog, it says what it did, Undo works',
        (t) async {
      final id = await openStarter(t);
      final first = store.byId(id)!.items.first;
      await t.tap(find.byKey(ValueKey('pcl_tick_${first.id}')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      // No "Already got this?" dialog.
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(s.pclGotPromptTitle), findsNothing);
      expect(store.byId(id)!.items.first.checked, isTrue);
      // It says what it did and offers Undo.
      expect(find.text("Ticked off. It won't go in your cart."), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      // The ticked item sank into the Got group; the foot shows what is left.
      expect(find.byKey(const ValueKey('pcl_got_heading')), findsOneWidget);
      expect(find.text('GOT · 1'), findsOneWidget);
      expect(find.text("Add what's left to cart (2)"), findsOneWidget);
      expect(find.text('1 of 3 ticked off'), findsOneWidget);
      await t.tap(find.text('Undo'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(store.byId(id)!.items.first.checked, isFalse);
      expect(find.byKey(const ValueKey('pcl_got_heading')), findsNothing);
      expect(find.text("Add what's left to cart (3)"), findsOneWidget);
    });

    testWidgets('everything ticked: a calm line, and no foot', (t) async {
      final id = await openStarter(t);
      for (final it in store.byId(id)!.items) {
        await t.tap(find.byKey(ValueKey('pcl_tick_${it.id}')));
        await t.pump(const Duration(milliseconds: 300));
      }
      expect(find.byKey(const ValueKey('pcl_all_done')), findsOneWidget);
      expect(find.text('Everything on this list is ticked off.'), findsOneWidget);
      expect(find.byKey(const ValueKey('pcl_cart_bar')), findsNothing);
      expect(find.text('3 of 3 ticked off'), findsOneWidget);
    });

    testWidgets('an item with no note invites one, in plain words', (t) async {
      final id = store.createChecklist('Mine');
      store.addItem(id, kCuratedChecklists.first.items.first.productId);
      await pump(t);
      await t.tap(find.text('Mine'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Add a note'), findsOneWidget);
      expect(find.text('Add when'), findsNothing);
    });

    testWidgets('holds at 1.5x text on a narrow phone', (t) async {
      store.adoptCurated(kCuratedChecklists.first);
      await pump(t, scale: 1.5, width: 360);
      await t.tap(find.text(kCuratedChecklists.first.name).first);
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(t.takeException(), isNull);
    });
  });

  group('the picker', () {
    testWidgets('no emoji; one Done button with the count', (t) async {
      final id = store.createChecklist('Mine');
      await pump(t);
      await t.tap(find.text('Mine'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      await t.tap(find.byKey(const ValueKey('pcl_add_products')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(_emojiTexts(t), isEmpty);
      expect(find.byKey(const ValueKey('pcl_picker_done')), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Add your own item'), findsOneWidget);
      // Adding one updates the count on the button.
      store.addItem(id, kCuratedChecklists.first.items.first.productId);
      await t.pump();
      expect(find.text('Done · 1'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('pcl_picker_done')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('pcl_picker_done')), findsNothing);
    });
  });

  group('the cart it feeds', () {
    test('a cart line carries no emoji, in memory or saved', () {
      final line = CartItem(
        lineId: 'l',
        productId: 'p',
        name: 'Swaddle',
        unitPrice: 100,
        image: 'https://x/y.jpg',
      );
      expect(line.toJson().containsKey('e'), isFalse);
      expect(CartItem.fromJson(line.toJson()).image, 'https://x/y.jpg');
    });

    test('a cart saved before this (with its old emoji key) still loads', () {
      final old = CartItem.fromJson({
        'l': 'l',
        'p': 'p',
        'n': 'Swaddle',
        'e': '🛍️',
        'u': 100,
        'q': 2,
      });
      expect(old.name, 'Swaddle');
      expect(old.qty, 2);
      expect(old.lineTotal, 200);
      expect(old.toJson().containsKey('e'), isFalse);
    });

    testWidgets('the cart draws a mark or a photo for a line, never an emoji',
        (t) async {
      CartStore.instance.clear(kProductsCartId);
      CartStore.instance.add(kProductsCartId,
          productId: 'sw_overall', name: 'Swaddle', unitPrice: 1199);
      t.view.physicalSize = const Size(900, 2400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        home: CartScreen(
            controller: c, cartId: kProductsCartId, title: s.cartProductsTitle),
      ));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Swaddle'), findsWidgets);
      expect(_emojiTexts(t), isEmpty);
      expect(find.byType(TtcMarkLeading), findsWidgets);
      expect(t.takeException(), isNull);
      CartStore.instance.clear(kProductsCartId);
    });

    test('no live code passes or reads an emoji for a cart line', () {
      for (final f in [
        'lib/services/cart_store.dart',
        'lib/screens/cart_screen.dart',
        'lib/screens/products/pv_product_screen.dart',
        'lib/screens/tools/hospital_bag_screen.dart',
        'lib/screens/tools/hospital_bag_v2_screen.dart',
      ]) {
        final code = _code(f);
        expect(RegExp(r'emoji:\s').hasMatch(code) && code.contains('CartStore'),
            isFalse, reason: '$f hands the cart an emoji');
        expect(code, isNot(contains('it.emoji')), reason: f);
      }
    });
  });

  group('wiring', () {
    test('the live code draws no emoji and no old hub well, and the word '
        '"Affiliate" is not what she reads in English', () {
      final live = _code('lib/screens/tools/product_checklist_screen.dart');
      // No emoji at all, drawn or passed on (2026-10-02, "change it internally
      // as well"): the cart line takes the photo, not an emoji.
      expect(live.toLowerCase(), isNot(contains('emoji')));
      expect(live, contains('image: p.imageUrl'));
      expect(live, isNot(contains('PvMarkWell(')));
      expect(live, contains("'Via Amazon'"));
      expect(live, contains('_thumb('));
      expect(live, contains('_cartBar('));
      // The old two-button bars are defined but never built.
      expect(RegExp(RegExp.escape('_bottomBar(')).allMatches(live).length, 1);
    });
  });
}
