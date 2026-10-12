// The week's superfood opens a recipe (2026-10-10), and the Move door's yoga
// screen says which sessions are videos and which are live classes.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/nutrition/superfood_recipes.dart';
import 'package:parentveda/data/nutrition_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/prepare/prenatal_yoga_screen.dart';

void main() {
  test('every week with a superfood has a recipe behind it', () {
    final weeks = jsonDecode(File('lib/data/weekContent.json').readAsStringSync()) as List;
    var seen = 0;
    for (final w in weeks.cast<Map>()) {
      final sf = (w['nutrition'] as Map?)?['indianSuperfoodOfTheWeek'] as Map?;
      if (sf == null) continue;
      final food = sf['food'];
      final en = food is Map ? food['en'] as String : food as String;
      seen++;
      expect(recipeForSuperfood(en), isNotNull, reason: 'week ${w['week']}: $en');
    }
    expect(seen, greaterThan(30));
  });

  test('the superfood recipes are in the library, ids unique', () {
    for (final r in kSuperfoodRecipes) {
      expect(kRecipes.where((x) => x.id == r.id).length, 1, reason: r.id);
    }
  });

  test('the week page opens it (wiring)', () {
    final src = File('lib/screens/week_flow_screen.dart').readAsStringSync();
    expect(src, contains('recipeForSuperfood(sf.food.en)'));
    expect(src, contains('openRecipe(context, recipe, c,'));
    expect(src, contains('_MotherDetailScreen(w: w, lang: lang, controller: controller)'));
  });

  testWidgets('yoga: videos say self-guided, live classes say live and when', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: PrenatalYogaScreen(lang: AppLanguage.english)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('SELF-GUIDED VIDEOS'), findsOneWidget);
    expect(find.text('LIVE CLASS'), findsWidgets);
    expect(find.textContaining('8am IST'), findsOneWidget);
  });
}
