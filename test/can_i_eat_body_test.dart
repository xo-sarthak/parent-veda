// =============================================================================
//  Can I eat this? — the tab behaves the way the design says it does
// -----------------------------------------------------------------------------
//  The design (`Can I Eat This.dc.html`, 2026-09-11) makes four promises about
//  behaviour, and each is a test:
//
//    · a most-searched chip answers UNDER the chips, in place;
//    · a category opens its rows under the grid, and a row expands where it is;
//    · one search bar filters BOTH libraries, each in its own vocabulary;
//    · a craving's word follows her trimester.
//
//  And two promises about what is NOT there: nothing pushes a page, and the
//  two vocabularies never wear the same badge.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/cravings_data.dart';
import 'package:parentveda/data/nutrition_data.dart';
import 'package:parentveda/screens/nutrition/can_i_eat_body.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

Widget _host(PregnancyController c) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: CanIEatBody(pregnancy: c),
          ),
        ),
      ),
    );

/// A controller at a given week. The default (no due date) sits at week 20.
PregnancyController _at(int week) {
  final c = PregnancyController();
  c.setDueDate(DateTime.now().add(Duration(days: (40 - week) * 7)));
  return c;
}

/// Scroll a finder into the 800x600 test viewport before tapping it — this
/// body is a long column, and a tap below the viewport lands on nothing.
Future<void> _tap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f.first);
  await t.pumpAndSettle();
  await t.tap(f.first);
  await t.pumpAndSettle();
}

void main() {
  testWidgets('lands on chips and the category grid, not 64 rows',
      (tester) async {
    await tester.pumpWidget(_host(PregnancyController()));
    await tester.pumpAndSettle();

    expect(find.text('MOST SEARCHED'), findsOneWidget);
    expect(find.text('ALL FOODS'), findsOneWidget);
    expect(find.text('CRAVINGS'), findsOneWidget);
    // Eight category cards, each with its count.
    for (final cat in FoodCategory.values) {
      expect(find.text('${foodsByCategory(cat).length}'), findsWidgets,
          reason: cat.name);
    }
    // No food row is open yet — the 64 rows are folded.
    expect(find.text('Banana'), findsNothing);
  });

  testWidgets('a chip answers under the chips, in place', (tester) async {
    await tester.pumpWidget(_host(PregnancyController()));
    await tester.pumpAndSettle();

    await _tap(tester, find.text('Papaya'));

    final papaya = foodById('papaya')!;
    expect(find.text(papaya.lines.en), findsOneWidget);
    expect(find.text('HOW MUCH'), findsOneWidget);
    expect(find.text('WORTH KNOWING'), findsOneWidget,
        reason: 'the myth rides along — see the file header');
    // Papaya is also a craving, and the model says so through foodId.
    expect(find.text('Craving it? Answered for your week'), findsOneWidget);
    // Nothing was pushed.
    expect(find.byType(CanIEatBody), findsOneWidget);
  });

  testWidgets('a category opens its rows, and a row expands where it sits',
      (tester) async {
    await tester.pumpWidget(_host(PregnancyController()));
    await tester.pumpAndSettle();

    await _tap(tester, find.text('Fruits'));
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await _tap(tester, find.text('Banana'));
    expect(find.text(foodById('banana')!.lines.en), findsOneWidget);

    await _tap(tester, find.text('Close'));
    expect(find.text('Banana'), findsNothing);
  });

  testWidgets('one bar filters both libraries, each in its own words',
      (tester) async {
    await tester.pumpWidget(_host(PregnancyController()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'papaya');
    await tester.pumpAndSettle();

    // The grid and the chips are gone; results are rows.
    expect(find.text('MOST SEARCHED'), findsNothing);
    expect(find.text('Fruits'), findsNothing);
    expect(find.textContaining('in foods'), findsOneWidget);
    // Food vocabulary on the food row…
    expect(find.text('LIMIT'), findsOneWidget);
    // …and craving vocabulary on the craving row, for the same word.
    final papayaCraving = kCravingItems.firstWhere((c) => c.id == 'papaya');
    expect(find.text(papayaCraving.name.en), findsWidgets);
    expect(
        find.text('Yes').evaluate().isNotEmpty ||
            find.text('In small amounts').evaluate().isNotEmpty ||
            find.text('Not now').evaluate().isNotEmpty,
        isTrue,
        reason: 'the craving row carries a serif word, not a capsule');
  });

  testWidgets('a craving that has no food match says so, calmly',
      (tester) async {
    await tester.pumpWidget(_host(PregnancyController()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('Not in the food library yet'), findsOneWidget);
    expect(find.text('No craving by that name'), findsOneWidget);
  });

  testWidgets("a craving's word follows her trimester", (tester) async {
    // Find a craving whose answer actually moves between trimesters.
    final moving = kCravingItems.firstWhere(
        (c) => c.verdictByTrimester.values.toSet().length > 1 ||
            (c.verdictByTrimester.isNotEmpty &&
                c.verdictByTrimester.values.any((v) => v != c.verdict)));
    final t1 = moving.verdictAt(1);
    final t3 = moving.verdictAt(3);
    expect(t1 == t3, isFalse, reason: 'pick a craving whose answer moves');

    String word(NutritionVerdict v) => switch (v) {
          NutritionVerdict.safe => 'Yes',
          NutritionVerdict.limit => 'In small amounts',
          NutritionVerdict.avoid => 'Not now',
        };

    for (final (week, verdict) in [(8, t1), (34, t3)]) {
      await tester.pumpWidget(_host(_at(week)));
      await tester.pumpAndSettle();
      expect(find.text('WEEK $week'), findsWidgets);
      await tester.enterText(find.byType(TextField), moving.name.en);
      await tester.pumpAndSettle();
      expect(find.text(word(verdict)), findsWidgets,
          reason: '${moving.id} at week $week');
    }
  });

  testWidgets('never a capsule on a craving, never a serif word on a food',
      (tester) async {
    // ⚠️ THE SEAM, AS A RULE. Food verdicts are uppercase capsule words;
    // craving answers are sentence-case serif words. If either vocabulary
    // ever appears in the other's dress, the second list reads as the first
    // disagreeing with itself.
    await tester.pumpWidget(_host(PregnancyController()));
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Fruits'));
    expect(find.text('SAFE'), findsWidgets);
    expect(find.text('Safe'), findsNothing);
    expect(find.text('YES'), findsNothing);
  });
}
