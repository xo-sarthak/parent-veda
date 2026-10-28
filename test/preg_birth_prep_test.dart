// =============================================================================
//  P4, birth prep: the shopping list, Tools wiring and Get ready after a loss
// -----------------------------------------------------------------------------
//  docs/preg-ttc-tool-plans/P4-birth-prep.md (2026-10-28). The food shopping
//  list reads its own store and never writes over a day she has not loaded
//  (S1, S2); its removals say what went and can be undone (S5); it is a Track
//  row, and "shopping list" finds it rather than the baby checklist (S3, S4).
//  After a loss every Get ready tool stays (D4), Garbh Sanskar does not (D2),
//  and the birth plan and Pregnancy's baby names say what has changed.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/ask_veda/pv_veda_links.dart';
import 'package:parentveda/data/nutrition/nutrition_plate.dart'
    show plateDateKey;
import 'package:parentveda/screens/nutrition/door/shopping_list_screen.dart';
import 'package:parentveda/screens/post_pregnancy/baby_naming_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_journey_shortlist_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_names_data.dart'
    show kBabyNames;
import 'package:parentveda/screens/post_pregnancy/pp_use_ask_card.dart';
import 'package:parentveda/screens/pregnancy/birth_plan_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_after_loss_note.dart';
import 'package:parentveda/screens/tools_hub_screen.dart';
import 'package:parentveda/services/birth_plan_store.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/nutrition_day_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/widgets/pv_toast.dart';

/// Source with comment lines dropped, so a "kept for revert" line never
/// satisfies or fails a check.
String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController c;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PregnancyEndedStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    c = PregnancyController(
      dueDate: DateTime.now().add(const Duration(days: 140)),
    );
    await c.load();
  });

  tearDown(() {
    PregnancyEndedStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
  });

  Future<void> pump(WidgetTester t, Widget w, {double height = 4000}) async {
    t.view.physicalSize = Size(400, height);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: Scaffold(body: w)));
    await t.pump(const Duration(milliseconds: 300));
  }

  Finder text(String s) => find.text(s, skipOffstage: false);
  final note = find.byKey(
    const ValueKey('preg_after_loss_note'),
    skipOffstage: false,
  );

  group('Tools hub', () {
    testWidgets(
      'after a loss every Get ready tool stays; Garbh Sanskar does not (D2, D4)',
      (t) async {
        await PregnancyEndedStore.instance.markEnded();
        await pump(t, ToolsHubScreen(controller: c));
        expect(t.takeException(), isNull);
        for (final title in [
          'Hospital bag',
          'Birth plan',
          'Contraction timer',
          'Product Checklist',
          'Baby names',
        ]) {
          expect(text(title), findsOneWidget, reason: title);
        }
        expect(text('Garbh Sanskar'), findsNothing);
        // The lines drop the baby.
        expect(
          text('What to take for you, if you go into hospital'),
          findsOneWidget,
        );
        expect(text('Your plan, kept as you left it'), findsOneWidget);
        expect(
          text('Time contractions, if your doctor has asked you to'),
          findsOneWidget,
        );
        expect(text("Your lists, and what you've bought"), findsOneWidget);
        expect(text('Your shortlist, kept'), findsOneWidget);
      },
    );

    testWidgets('the Shopping list is a Track row (S3, D3)', (t) async {
      await pump(t, ToolsHubScreen(controller: c));
      expect(text('Shopping list'), findsOneWidget);
      expect(
        text('What the recipes and diet chart days you picked need'),
        findsOneWidget,
      );
      final y = t.getTopLeft(text('Shopping list')).dy;
      expect(y, greaterThan(t.getTopLeft(text('TRACK')).dy));
      expect(y, lessThan(t.getTopLeft(text('GET READY')).dy));
      final hub = _code('lib/screens/tools_hub_screen.dart');
      expect(
        hub,
        contains("_open('nutrition/list', () => const ShoppingListScreen())"),
      );
      expect(hub, contains('BabyNamingHomeScreen(afterLossNote: true)'));
    });

    test('no Get ready row is gated on the loss any more', () {
      final hub = _code('lib/screens/tools_hub_screen.dart');
      for (final row in [
        "'Hospital bag'",
        "'Birth plan'",
        "'Contraction timer'",
        's.pclTitle',
        "'Baby names'",
      ]) {
        expect(
          RegExp(
            'if \\(!_ended\\)\\s*\\n\\s*_Tool\\(${RegExp.escape(row)}',
          ).hasMatch(hub),
          isFalse,
          reason: row,
        );
      }
      expect(
        RegExp(r'if \(!_ended\)\s*\n\s*_Tool\(s\.garbhToolTitle').hasMatch(hub),
        isTrue,
        reason: 'Garbh Sanskar stays hidden after a loss (D2)',
      );
    });
  });

  group('Ask Veda and search (S4)', () {
    test('"shopping list" is the food list; "baby things" the checklist', () {
      final food = pvVedaToolById('shopping_list')!;
      expect(food.route, 'nutrition/list');
      expect(food.build(c), isA<ShoppingListScreen>());
      expect(food.keywords, contains('shopping list'));
      final checklist = pvVedaToolById('product_checklist')!;
      expect(checklist.keywords, isNot(contains('shopping list')));
      expect(checklist.keywords, contains('baby things'));
      expect(pvVedaDocResolves(pvVedaToolId('shopping_list')), isTrue);
    });

    test('Get ready opens from Ask Veda after a loss', () async {
      await PregnancyEndedStore.instance.markEnded();
      for (final id in [
        'hospital_bag',
        'birth_plan',
        'contractions',
        'product_checklist',
        'due_date',
      ]) {
        expect(pvVedaToolStepsAside(id), isNull, reason: id);
      }
    });

    test(
      'global search: shopping finds the food list, the checklist keeps its words',
      () {
        final search = _code('lib/screens/global_search.dart');
        expect(
          search,
          contains(
            "_Dest('Shopping list', const ['shopping', 'shopping list', 'grocery'",
          ),
        );
        expect(
          search,
          contains(
            "_Dest(s.pclTitle, const ['checklist', 'product checklist', 'baby things', 'what to buy']",
          ),
        );
      },
    );
  });

  group('the shopping list store (S2)', () {
    final store = NutritionDayStore.instance;

    test(
      'an edit before the cache is read keeps the saved day and the list',
      () async {
        final today = plateDateKey(DateTime.now());
        SharedPreferences.setMockInitialValues({
          'nutrition_day_v1': jsonEncode({
            'days': {
              today: {
                'water': 5,
                'ticks': ['iron'],
                'swaps': {},
                'skipped': [],
              },
            },
            'shopping': [
              {'r': 'r1', 'n': 'ghee', 'd': true, 'o': 1},
            ],
          }),
        });
        store.resetUnreadForTest();
        store.addToList('r2', ['moong']);
        // Nothing was written over the blob before the read.
        final before = await SharedPreferences.getInstance();
        expect(before.getString('nutrition_day_v1'), contains('ghee'));
        await store.init();
        expect(store.today.water, 5);
        expect(store.ticked(DateTime.now(), 'iron'), isTrue);
        expect(
          store.shopping.map((s) => s.key),
          containsAll(['r1|ghee', 'r2|moong']),
        );
        final saved = (await SharedPreferences.getInstance()).getString(
          'nutrition_day_v1',
        )!;
        expect(saved, contains('ghee'));
        expect(saved, contains('moong'));
        expect(saved, contains('"water":5'));
      },
    );

    test('own items sit under "Your own" and sync per item', () {
      store.resetForTest();
      expect(store.addOwnItem('  Coconut water '), isTrue);
      expect(
        store.addOwnItem('Coconut water'),
        isFalse,
        reason: 'already on it',
      );
      expect(store.addOwnItem('   '), isFalse);
      expect(
        store.cloudItems().keys,
        contains('shop|$kOwnListId|Coconut water'),
      );
      expect(shoppingGroupTitle(kOwnListId), 'Your own');
    });

    test(
      'a removal hands back what it took; restore puts it back in place',
      () {
        store.resetForTest();
        store.addToList('r1', ['a', 'b', 'c']);
        final gone = store.removeItem(store.shopping[1])!;
        expect(store.shopping.map((s) => s.name), ['a', 'c']);
        store.restoreLines([gone]);
        expect(store.shopping.map((s) => s.name), ['a', 'b', 'c']);
      },
    );
  });

  group('the shopping list screen (S1, S5)', () {
    testWidgets('Clear bought says what went, and Undo brings it back', (
      t,
    ) async {
      final store = NutritionDayStore.instance;
      store.resetForTest();
      store.addToList('r1', ['ghee', 'moong']);
      store.toggleBought(store.shopping.first);
      await pump(t, const ShoppingListScreen());
      expect(text('Your shopping list'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('shop_clear_bought')));
      await t.pump(const Duration(milliseconds: 300));
      expect(store.shopping.map((s) => s.name), ['moong']);
      expect(find.text('Cleared 1 item you bought.'), findsOneWidget);
      await t.tap(find.text('Undo'));
      await t.pump(const Duration(milliseconds: 300));
      expect(store.shopping.map((s) => s.name), ['ghee', 'moong']);
      expect(
        store.shopping.first.done,
        isTrue,
        reason: 'back as it was, ticked',
      );
      PvToast.instance.dismiss();
      await t.pump(const Duration(milliseconds: 400));
    });

    testWidgets('one line comes off with Undo; her own item goes on', (
      t,
    ) async {
      final store = NutritionDayStore.instance;
      store.resetForTest();
      store.addToList('r1', ['ghee']);
      await pump(t, const ShoppingListScreen());
      await t.tap(find.byKey(const ValueKey('shop_remove_r1|ghee')));
      await t.pump(const Duration(milliseconds: 300));
      expect(store.shopping, isEmpty);
      expect(find.text('Removed ghee from your list.'), findsOneWidget);
      await t.tap(find.text('Undo'));
      await t.pump(const Duration(milliseconds: 300));
      expect(store.shopping.single.name, 'ghee');
      PvToast.instance.dismiss();
      await t.pump(const Duration(milliseconds: 400));

      await t.enterText(find.byKey(const ValueKey('shop_own_field')), 'Dates');
      await t.tap(find.byKey(const ValueKey('shop_own_add')));
      await t.pump(const Duration(milliseconds: 300));
      expect(store.itemOnList(kOwnListId, 'Dates'), isTrue);
      expect(text('Your own'), findsOneWidget);
      PvToast.instance.dismiss();
      await t.pump(const Duration(milliseconds: 400));
    });

    test('the screen reads its own store', () {
      expect(
        _code('lib/screens/nutrition/door/shopping_list_screen.dart'),
        contains('NutritionDayStore.instance.init()'),
      );
    });
  });

  group('the birth plan after a loss (D4)', () {
    setUp(() async {
      await BirthPlanStore.instance.clear();
      await BirthPlanStore.instance.toggle('support_person', 'partner');
    });

    testWidgets('pregnant: no note, the summary ask is there', (t) async {
      await pump(t, BirthPlanScreen(pregnancy: c), height: 6000);
      expect(note, findsNothing);
      expect(find.byType(PpUseAskCard, skipOffstage: false), findsOneWidget);
      expect(
        find.textContaining(
          'One page your hospital can read',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'after a loss: the note, the plan as she left it, no summary ask',
      (t) async {
        await PregnancyEndedStore.instance.markEnded();
        await pump(t, BirthPlanScreen(pregnancy: c), height: 6000);
        expect(note, findsOneWidget);
        expect(text(kAfterLossBirthPlan), findsOneWidget);
        expect(find.byType(PpUseAskCard, skipOffstage: false), findsNothing);
        expect(text('Your plan, as you left it.'), findsOneWidget);
        expect(find.textContaining('3am', skipOffstage: false), findsNothing);
        // Her answers stay.
        expect(
          BirthPlanStore.instance.isChosen('support_person', 'partner'),
          isTrue,
        );
      },
    );
  });

  group('baby names (shared with Parenting)', () {
    testWidgets('Pregnancy, after a loss, with the flag: the note', (t) async {
      LifeStageStore.instance.setStage(LifeStage.pregnancy);
      await PregnancyEndedStore.instance.markEnded();
      await pump(t, const BabyNamingHomeScreen(afterLossNote: true));
      expect(note, findsOneWidget);
      expect(text(kAfterLossNames), findsOneWidget);
    });

    testWidgets(
      'without the flag (Parenting\'s callers): no note, even after a loss',
      (t) async {
        LifeStageStore.instance.setStage(LifeStage.parenting);
        await PregnancyEndedStore.instance.markEnded();
        await pump(t, const BabyNamingHomeScreen());
        expect(note, findsNothing);
      },
    );

    testWidgets('the chosen name: no story offer after a loss in Pregnancy', (
      t,
    ) async {
      LifeStageStore.instance.setStage(LifeStage.pregnancy);
      await PregnancyEndedStore.instance.markEnded();
      await pump(t, NameChosenScreen(name: kBabyNames.first.name));
      expect(
        find.byKey(const ValueKey('pp_name_story_card'), skipOffstage: false),
        findsNothing,
      );
      expect(
        find.textContaining('Chapter One', skipOffstage: false),
        findsNothing,
      );
    });

    testWidgets('Parenting: the story offer is as before', (t) async {
      LifeStageStore.instance.setStage(LifeStage.parenting);
      await PregnancyEndedStore.instance.markEnded();
      await pump(t, NameChosenScreen(name: kBabyNames.first.name));
      expect(
        find.byKey(const ValueKey('pp_name_story_card'), skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.textContaining('Chapter One', skipOffstage: false),
        findsOneWidget,
      );
    });
  });
}
