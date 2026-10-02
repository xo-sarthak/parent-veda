// =============================================================================
//  TTC "This week's food ideas" rebuilt as a tool (2026-09-29)
// -----------------------------------------------------------------------------
//  The user on build 20: the tools look like "big blobs of text". The page is
//  now a day strip, the day's food idea as a photo card, the day's four meals
//  from the nutritionist's week of meals, her kitchen, and swaps that stay.
//  This file pins:
//    · the contract: every dish, eggless swap, Jain swap, non-veg note and
//      day line is the read's own words, so the tool cannot say something the
//      nutritionist did not write;
//    · the interactions: pick a day, pick a kitchen, swap a meal (and undo),
//      open the kitchen line, jump by nutrient, open the whole week;
//    · memory: her kitchen and her swaps survive a reload;
//    · no overflow at 360dp with 1.5x text;
//    · explicit labels on the icon-only controls.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/reads/read_images.dart' show readImageFor;
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/ttc/ttc_nutrition_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_meal_week_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart' show ttcReadById;

Future<void> _pump(WidgetTester tester,
    {Size size = const Size(420, 5200), double textScale = 1.0}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    key: UniqueKey(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: const TtcNutritionScreen(),
  ));
  await tester.pumpAndSettle();
}

/// The strip's index of the first day in the week that is plan day [planDay].
int _stripIndexFor(int planDay) {
  final week = TtcNutritionScreen.weekFrom(DateTime.now());
  return week.indexWhere((e) => ttcPlanDayFor(e.$1) == planDay);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('the week is the read, word for word', () {
    final read = ttcReadById(kTtcMealPlanReadId)!;
    final bullets = [
      for (final s in read.sections)
        for (final b in s.bullets) b.en,
    ];
    final paragraphs = [
      for (final s in read.sections)
        for (final para in s.paragraphs) para.en,
    ];

    test('28 dishes, one per day and meal', () {
      expect(kTtcPlanMeals.length, 28);
      for (var d = 1; d <= 7; d++) {
        for (final slot in TtcMealSlot.values) {
          expect(
              kTtcPlanMeals.where((m) => m.day == d && m.slot == slot).length,
              1,
              reason: 'day $d $slot');
        }
      }
    });

    test('every dish is a bullet of the read', () {
      for (final m in kTtcPlanMeals) {
        expect(bullets, contains(m.readBullet), reason: m.readBullet);
      }
    });

    test('the eggless dishes come from the read\'s own swaps', () {
      final swaps = bullets.where((b) => b.startsWith('Egg bhurji') ||
          b.startsWith('The omelette'));
      expect(swaps.length, 2);
      final bhurji = ttcPlanMeal(4, TtcMealSlot.breakfast);
      expect(bhurji.eggless, contains('Paneer bhurji or tofu bhurji'));
      expect(swaps.first, contains('paneer bhurji or tofu bhurji'));
      final omelette = ttcPlanMeal(6, TtcMealSlot.breakfast);
      expect(omelette.eggless, contains('moong dal chilla'));
      expect(omelette.eggless, contains('besan chilla with paneer inside'));
      // Only the two egg dishes carry a swap, and no eggless dish names egg.
      for (final m in kTtcPlanMeals) {
        final hasEgg = m.dish.toLowerCase().contains('egg');
        expect(m.eggless != null, hasEgg, reason: m.dish);
        if (m.eggless != null) {
          expect(m.eggless!.toLowerCase(), isNot(contains('egg')));
        }
      }
    });

    test('the Jain swaps, the non-veg note and the day lines are the read\'s',
        () {
      for (final s in kTtcJainSwaps) {
        expect(bullets, contains(s));
      }
      // The answer opens "Yes. " and then says the note word for word.
      expect(read.faqs.any((f) => f.answer.en == 'Yes. $kTtcNonVegNote'),
          isTrue);
      for (var d = 1; d <= 7; d++) {
        expect(paragraphs, contains(ttcPlanDayLine(d)), reason: 'day $d');
      }
    });

    test('Monday is day 1 and Sunday, the slower day, is day 7', () {
      expect(ttcPlanDayFor(DateTime(2026, 9, 28)), 1); // a Monday
      expect(ttcPlanDayFor(DateTime(2026, 10, 4)), 7); // a Sunday
    });

    test('every food idea has its photo, and all but one dish has one', () {
      for (final n in ttcNutrition) {
        expect(readImageFor('ttc_nutrition_${n.id}'), isNotNull,
            reason: n.id);
      }
      final missing = <String>{
        for (final m in kTtcPlanMeals)
          for (final k in TtcKitchen.values)
            if (ttcPlanMealPhoto(m, k) == null) m.dish,
      };
      // Owed (reported): a vegetable pulao photo. It draws the tool's bowl.
      expect(missing,
          {'Vegetable pulao with soya chunks, and cucumber raita.'});
      expect(readImageFor(kTtcMealPlanReadId), isNotNull);
    });

    test('a Jain swap is shown only where the dish names what it swaps', () {
      expect(ttcJainSwapFor('Bajra roti, methi aloo, and curd.'),
          kTtcJainSwaps[1]);
      expect(ttcJainSwapFor('Sprouted moong chaat with tomato and lemon.'),
          kTtcJainSwaps[2]);
      expect(ttcJainSwapFor('Dal paratha with curd.'), isNull);
    });
  });

  // ===========================================================================
  group('what she can do', () {
    testWidgets('today shows its idea and its four meals as cards',
        (tester) async {
      await _pump(tester);
      final today = DateTime.now();
      final idea = TtcNutritionScreen.weekFrom(today).first.$2;
      expect(find.text(idea.meal(false)), findsOneWidget);
      expect(find.text(idea.nutrient(false)), findsWidgets);
      for (final slot in TtcMealSlot.values) {
        expect(find.byKey(ValueKey('ttc_food_meal_${slot.name}')),
            findsOneWidget);
        expect(find.text(slot.label.toUpperCase()), findsOneWidget);
        expect(
            find.text(ttcPlanMeal(ttcPlanDayFor(today), slot)
                .dishFor(TtcKitchen.vegEggs)),
            findsOneWidget);
      }
      expect(find.text(ttcPlanDayLine(ttcPlanDayFor(today))), findsOneWidget);
      expect(
          find.text('MEALS FOR TODAY · DAY ${ttcPlanDayFor(today)} OF 7'),
          findsOneWidget);
    });

    testWidgets('the kitchen line folds open', (tester) async {
      await _pump(tester);
      final idea = TtcNutritionScreen.weekFrom(DateTime.now()).first.$2;
      expect(find.text(idea.indian(false)), findsNothing);
      await tester.tap(find.text('In an Indian kitchen'));
      await tester.pumpAndSettle();
      expect(find.text(idea.indian(false)), findsOneWidget);
    });

    testWidgets('picking No eggs swaps the egg dish, and is kept',
        (tester) async {
      await _pump(tester);
      final thu = _stripIndexFor(4);
      await tester.tap(find.byKey(ValueKey('ttc_food_day_$thu')));
      await tester.pumpAndSettle();
      final bhurji = ttcPlanMeal(4, TtcMealSlot.breakfast);
      expect(find.text(bhurji.dish), findsOneWidget);

      await tester.tap(find.text('Veg, no eggs'));
      await tester.pumpAndSettle();
      expect(find.text(bhurji.dish), findsNothing);
      expect(find.text(bhurji.eggless!), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kTtcFoodKitchenKey), 'noEggs');

      // A new visit keeps her kitchen.
      await _pump(tester);
      await tester.tap(find.byKey(ValueKey('ttc_food_day_$thu')));
      await tester.pumpAndSettle();
      expect(find.text(bhurji.eggless!), findsOneWidget);
    });

    testWidgets('Jain shows the swap a dish needs and the kitchen note',
        (tester) async {
      await _pump(tester);
      final thu = _stripIndexFor(4);
      await tester.tap(find.byKey(ValueKey('ttc_food_day_$thu')));
      await tester.tap(find.text('Jain'));
      await tester.pumpAndSettle();
      // Day 4 lunch is methi aloo.
      expect(find.byKey(const ValueKey('ttc_food_jain_lunch')), findsOneWidget);
      expect(find.text(kTtcJainSwaps[4]), findsNothing);
      await tester.tap(find.text('What changes in a Jain kitchen'));
      await tester.pumpAndSettle();
      for (final s in kTtcJainSwaps) {
        expect(find.text(s), findsOneWidget);
      }
      // A Jain plate has no eggs either.
      expect(find.text(ttcPlanMeal(4, TtcMealSlot.breakfast).eggless!),
          findsOneWidget);
    });

    testWidgets('Non-veg shows the read\'s note on meat and fish',
        (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Non-veg'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adding chicken, fish or eggs'));
      await tester.pumpAndSettle();
      expect(find.text(kTtcNonVegNote), findsOneWidget);
    });

    testWidgets('a meal swap picks from the week, is kept, and undoes',
        (tester) async {
      await _pump(tester);
      final today = DateTime.now();
      final own = ttcPlanMeal(ttcPlanDayFor(today), TtcMealSlot.dinner);
      final other = ttcPlanDayFor(today) == 1 ? 2 : 1;
      final pick = ttcPlanMeal(other, TtcMealSlot.dinner);

      await tester.tap(find.byKey(const ValueKey('ttc_food_swap_dinner')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_food_swap_sheet')), findsOneWidget);
      expect(find.text('Swap dinner'), findsOneWidget);
      await tester.tap(find.byKey(ValueKey('ttc_food_swap_option_$other')));
      await tester.pumpAndSettle();
      expect(find.text(pick.dish), findsOneWidget);
      expect(find.text(own.dish), findsNothing);
      expect(find.text('From day $other'), findsOneWidget);
      expect(find.text('Dinner swapped'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      final saved = jsonDecode(prefs.getString(kTtcFoodMealSwapsKey)!)
          as Map<String, dynamic>;
      expect(saved['${ttcFoodDayKey(today)}|dinner'], other);

      // Kept across a reload.
      await _pump(tester);
      expect(find.text(pick.dish), findsOneWidget);

      // Picking this day's own dish again goes back to the plan.
      await tester.tap(find.byKey(const ValueKey('ttc_food_swap_dinner')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(
          ValueKey('ttc_food_swap_option_${ttcPlanDayFor(today)}')));
      await tester.pumpAndSettle();
      expect(find.text(own.dish), findsOneWidget);
      expect(find.text('From day $other'), findsNothing);
      // And Undo puts the swap back.
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text(pick.dish), findsOneWidget);
    });

    testWidgets('a past day\'s meal swap is dropped on load', (tester) async {
      SharedPreferences.setMockInitialValues({
        kTtcFoodMealSwapsKey: jsonEncode({'2000-01-01|dinner': 3}),
      });
      await _pump(tester);
      final prefs = await SharedPreferences.getInstance();
      // Nothing written yet; the old key is simply not applied.
      expect(prefs.getString(kTtcFoodMealSwapsKey), contains('2000'));
      expect(find.text('From day 3'), findsNothing);
    });

    testWidgets('a nutrient pill opens the day it is on', (tester) async {
      await _pump(tester);
      final week = TtcNutritionScreen.weekFrom(DateTime.now());
      final last = week.last.$2;
      final firstDayWith =
          week.indexWhere((e) => e.$2.nutrient(false) == last.nutrient(false));
      await tester.tap(find.text(last.nutrient(false)).last);
      await tester.pumpAndSettle();
      expect(find.text(week[firstDayWith].$2.meal(false)), findsOneWidget);
    });

    testWidgets('the whole week opens as a read in the one reader',
        (tester) async {
      await _pump(tester);
      // The week's read is the "Read next" rail at the foot now (2026-10-02,
      // the user: the article on a tool screen is the reader's rail). Kept for
      // revert: tapping the row 'The whole week and the shopping list'.
      final title = ttcReadById(kTtcMealPlanReadId)!.title.en;
      final tile = find.descendant(
          of: find.byKey(const ValueKey('ttc_food_read_next')),
          matching: find.text(title));
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.byType(PvReaderScreen), findsOneWidget);
    });

    testWidgets('icon-only controls say what they do', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester);
      for (final slot in TtcMealSlot.values) {
        expect(find.bySemanticsLabel('Swap ${slot.label.toLowerCase()}'),
            findsOneWidget);
      }
      for (final k in TtcKitchen.values) {
        // The shared block announces its label (and its text again).
        expect(find.bySemanticsLabel(RegExp('^${RegExp.escape(k.label)}')),
            findsOneWidget);
      }
      expect(find.text('Your kitchen'), findsOneWidget);
      expect(find.bySemanticsLabel('Swap this food idea'), findsOneWidget);
      handle.dispose();
    });
  });

  // ===========================================================================
  group('no overflow at 360dp with 1.5x text', () {
    for (final k in TtcKitchen.values) {
      testWidgets(k.label, (tester) async {
        SharedPreferences.setMockInitialValues({kTtcFoodKitchenKey: k.name});
        await _pump(tester, size: const Size(360, 7000), textScale: 1.5);
        expect(tester.takeException(), isNull);
        // Every day, with the kitchen note and the idea's line open.
        for (var i = 0; i < 7; i++) {
          await tester.tap(find.byKey(ValueKey('ttc_food_day_$i')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('In an Indian kitchen'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'day $i');
        }
        await tester.tap(find.byKey(const ValueKey('ttc_food_swap_lunch')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'swap sheet');
      });
    }
  });
}
