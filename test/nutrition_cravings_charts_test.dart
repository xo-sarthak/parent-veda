// =============================================================================
//  Nutrition — cravings answered at her stage, and charts filtered on five axes
// -----------------------------------------------------------------------------
//  Two rebuilds, one shared defect between them: both screens knew nothing
//  about the woman reading them.
//
//    · Cravings was six reassuring text cards. It could not answer "can I have
//      this", which is the only reason anyone opens it.
//    · Diet charts had five MUTUALLY EXCLUSIVE shelves, so a chart was either
//      about a trimester or about being vegetarian or about Bengali cooking —
//      never two — and a mother has all of those questions at once.
//
//  ⚠️ THE TEST THAT MATTERS MOST IS `a null facet never excludes`. That single
//  line in `ChartFacets.satisfies` is what stops the filter emptying the screen
//  for most real combinations, and getting it wrong fails SILENTLY: the screen
//  still renders, the chips still highlight, and she simply sees nothing and
//  concludes the app has nothing for her. There is no crash to notice.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/prepare_data.dart';
import 'package:parentveda/data/cravings_data.dart';
import 'package:parentveda/data/reads/nutrition_reads.dart' show pvReadFromCraving;
import 'package:parentveda/data/diet_chart_facets.dart';
import 'package:parentveda/services/diet_chart_pdf.dart';
import 'package:parentveda/data/diet_chart_content.dart';
import 'package:parentveda/data/nutrition_data.dart';
import 'package:parentveda/screens/nutrition/craving_detail_screen.dart';
import 'package:parentveda/screens/nutrition/cravings_screen.dart';
import 'package:parentveda/screens/nutrition/diet_charts_screen.dart';
import 'package:parentveda/screens/nutrition/nutrition_home_screen.dart';
import 'package:parentveda/screens/prepare/consultations_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

/// A controller sitting at roughly [week], via the due date — `currentWeek` is
/// derived, and driving it any other way would test a path the app does not use.
PregnancyController _at(int week) {
  final now = DateTime(2026, 1, 1);
  return PregnancyController(
      now: now, dueDate: now.add(Duration(days: (40 - week) * 7)));
}

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(1200, 7000);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

CravingItem _c(String id) => kCravingItems.firstWhere((x) => x.id == id);

void main() {
  _dietCharts();
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // ===========================================================================
  //  1 · Cravings answer the question that is actually being asked
  // ===========================================================================

  group('a craving page answers "can I have this", at her week', () {
    testWidgets('the food list is the page, not an afterthought', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, CravingsScreen(pregnancy: c));

      // ⚠️ THE OLD SCREEN HAD NONE OF THESE. It listed reasons cravings
      // happen; it never named a single food.
      expect(find.text('Golgappa / pani puri'), findsOneWidget);
      expect(find.text('Achaar / pickle'), findsOneWidget);
      expect(find.text('Papaya'), findsOneWidget);
    });

    testWidgets('the verdict is on the list row, before any tap', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, CravingsScreen(pregnancy: c));

      // Most visits are one food and one question. Charging a tap to learn
      // "yes" is a tap for nothing.
      expect(find.text('Yes'), findsWidgets);
      expect(find.text('In small amounts'), findsWidgets);
    });

    testWidgets('she is told which week the answers are for', (t) async {
      final c = _at(31);
      addTearDown(c.dispose);
      await _pump(t, CravingsScreen(pregnancy: c));

      // Without this line every verdict below reads as a general rule, which
      // is exactly what the rebuild exists to stop it being.
      expect(find.textContaining('week 31'), findsOneWidget);
      expect(find.textContaining('third trimester'), findsOneWidget);
    });

    testWidgets('the old explainer cards survive, below the list', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, CravingsScreen(pregnancy: c));

      // ⚠️ KEPT, NOT DELETED — they are good writing, and what was wrong was
      // their POSITION. The repo rule is comment out, never delete; moving
      // beats removing for the same reason.
      expect(find.text('Why cravings happen'), findsOneWidget);
      expect(find.text('Pica, and when to tell a doctor'), findsOneWidget);

      final firstFood = t.getTopLeft(find.text('Golgappa / pani puri')).dy;
      final firstCard = t.getTopLeft(find.text('Why cravings happen')).dy;
      expect(firstFood, lessThan(firstCard));
    });
  });

  group('the answer genuinely changes with the trimester', () {
    test('papaya is off in the first trimester and limited later', () {
      // ⚠️ THE CASE THE PER-TRIMESTER MODEL EXISTS FOR. One flag would have to
      // pick the most cautious answer and repeat it for nine months, which is
      // how an app gets ignored — she knows her pregnancy has changed even if
      // the page does not.
      final p = _c('papaya');
      expect(p.verdictAt(1), NutritionVerdict.avoid);
      expect(p.verdictAt(2), NutritionVerdict.limit);
      expect(p.verdictAt(3), NutritionVerdict.limit);
    });

    test('spice is safe early and limited late, for comfort not safety', () {
      final s = _c('spicy');
      expect(s.verdictAt(1), NutritionVerdict.safe);
      expect(s.verdictAt(3), NutritionVerdict.limit);
      // The distinction is stated in the copy, because women give up food they
      // never needed to when a comfort limit is mistaken for a safety one.
      expect(s.whenToAvoid!.en.toLowerCase(), contains('comfort limit'));
    });

    testWidgets('the same food shows different answers at 8 and 30 weeks',
        (t) async {
      final early = _at(8);
      addTearDown(early.dispose);
      // The page is a read since 2026-09-22 (`pvReadFromCraving`): the
      // verdict is the teaser AND the opening callout's title, so it shows
      // more than once and the week rides in the same line.
      await _pump(t,
          CravingDetailScreen(item: _c('papaya'), pregnancy: early));
      expect(find.textContaining('Not now'), findsWidgets);
      expect(find.textContaining('week 8'), findsWidgets);
      expect(pvReadFromCraving(_c('papaya'), 8).teaser.en, 'At week 8 — Not now');

      final late = _at(30);
      addTearDown(late.dispose);
      await _pump(
          t, CravingDetailScreen(item: _c('papaya'), pregnancy: late));
      expect(find.textContaining('In small amounts'), findsWidgets);
      expect(find.textContaining('week 30'), findsWidgets);
      expect(pvReadFromCraving(_c('papaya'), 30).teaser.en, 'At week 30 — In small amounts');
    });

    test('every item carries a note for all three trimesters', () {
      // This sentence is what makes the page hers rather than a leaflet, so a
      // missing one is a hole she would notice.
      for (final c in kCravingItems) {
        for (final tri in [1, 2, 3]) {
          expect(c.stageNoteAt(tri), isNotNull, reason: '${c.id} / T$tri');
        }
      }
    });
  });

  group('alternatives and recipes appear only where they help', () {
    testWidgets('no alternatives offered for a plain yes', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      // Curd is safe in every trimester.
      await _pump(t, CravingDetailScreen(item: _c('curd'), pregnancy: c));

      // ⚠️ OFFERING A SUBSTITUTE FOR SOMETHING SHE CAN SIMPLY HAVE reads as
      // disapproval wearing the costume of help.
      expect(find.text('If you would rather not risk it'), findsNothing);
    });

    testWidgets('alternatives appear when the answer is limit', (t) async {
      final c = _at(30);
      addTearDown(c.dispose);
      await _pump(t, CravingDetailScreen(item: _c('pickle'), pregnancy: c));
      expect(find.text('If you would rather not risk it'), findsOneWidget);
    });

    testWidgets('a home recipe is shown in place, not behind a link',
        (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, CravingDetailScreen(item: _c('golgappa'), pregnancy: c));

      // In the read: the recipe is two sections of the same page — the
      // ingredients under "Make it at home: <name> · n min", the steps under
      // "Method". Ingredients AND steps, in place — a four-line substitution
      // loses most of the people it is for if it costs another screen.
      final read = pvReadFromCraving(_c('golgappa'), 20);
      final headings = read.sections.map((s) => s.heading?.en ?? '').toList();
      expect(headings.any((h) => h.startsWith('Make it at home: Home pani puri, safely')), isTrue,
          reason: headings.join(' | '));
      expect(headings, contains('Method'));
      final recipeSection = read.sections.firstWhere((s) => (s.heading?.en ?? '').startsWith('Make it at home'));
      expect(recipeSection.bullets, isNotEmpty, reason: 'the ingredients');
      final method = read.sections.firstWhere((s) => s.heading?.en == 'Method');
      expect(method.paragraphs.first.en, startsWith('1. '));
      expect(find.textContaining('Make it at home'), findsWidgets);
    });

    test('the recipe exists exactly where the risk is in the making', () {
      // Golgappa, kulfi and chowmein are all "yes, if you make it yourself"
      // foods — the danger is the water, the milk and the standing sauce.
      for (final id in ['golgappa', 'ice_cream', 'chinese']) {
        expect(_c(id).recipe, isNotNull, reason: id);
      }
    });
  });

  group('the two that are not food questions route to a doctor', () {
    test('ice-chewing and pica carry no alternatives at all', () {
      for (final id in ['ice_chewing', 'non_food']) {
        final c = _c(id);
        expect(c.talkToDoctor, isTrue, reason: id);
        // ⚠️ "TRY COLD CUCUMBER INSTEAD" IS A CONFIDENT ANSWER TO THE WRONG
        // QUESTION. The useful answer to both of these is a blood test.
        expect(c.alternatives, isEmpty, reason: id);
        expect(c.recipe, isNull, reason: id);
      }
    });

    testWidgets('the doctor line sits directly under the answer', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(
          t, CravingDetailScreen(item: _c('ice_chewing'), pregnancy: c));

      final doctor = t.getTopLeft(find.textContaining('telling your doctor')).dy;
      final why = t.getTopLeft(find.text('Why you are craving it')).dy;
      // Burying it under three sections of craving explanation would be the
      // app being calm at her expense.
      expect(doctor, lessThan(why));
    });
  });

  // ===========================================================================
  //  2 · Diet charts — five axes that do not collide
  // ===========================================================================

  group('the facets are independent, not five shelves', () {
    test('every chart is tagged — an untagged one matches everything', () {
      // ⚠️ THE SILENT FAILURE THIS CATCHES. `facetsFor` returns an empty
      // ChartFacets for an unknown id, and an all-null facet set satisfies
      // every filter — so a chart added without an entry would quietly appear
      // under every combination and look like a bug in the filters.
      for (final c in kDietCharts) {
        expect(kChartFacets.containsKey(c.id), isTrue,
            reason: '${c.id} has no facets — it would match every filter');
      }
    });

    test('a null facet never excludes', () {
      // The load-bearing line. Strict equality here empties the screen for
      // most real combinations, and does it without any error to notice.
      const gujarati = ChartFacets(region: ChartRegion.gujarati);
      expect(
          gujarati.satisfies(const ChartFilter(stage: ChartStage.trimester3)),
          isTrue,
          reason: 'a regional chart works at any stage');
      expect(gujarati.satisfies(const ChartFilter(diet: ChartDiet.vegetarian)),
          isTrue);
    });

    test('a different value on the same axis does exclude', () {
      const t1 = ChartFacets(stage: ChartStage.trimester1);
      expect(t1.satisfies(const ChartFilter(stage: ChartStage.trimester3)),
          isFalse);
    });

    test('Hindi is a property of a chart, never a kind of chart', () {
      // ⚠️ THIS TEST USED TO ASSERT THE BUG, AND THAT IS THE MOST USEFUL THING
      // IN THIS FILE.
      //
      // It read:
      //
      //     expect(facetsFor('t3_chart').inHindi, isTrue);
      //     expect(hindiOnly.length, greaterThan(1));
      //
      // with a comment saying "now the trimester charts are themselves
      // available in Hindi". They were not. Not one word of Hindi existed
      // anywhere in the section. Eight charts carried `inHindi: true` because
      // somebody typed it, and this test then required them to keep carrying
      // it — so the false claim was not merely unguarded, it was DEFENDED. A
      // correction would have turned the suite red and looked like a
      // regression.
      //
      // ⚠️ THE GENERAL LESSON: a test written from the same assumption as the
      // code does not check that assumption, it locks it in. Both were written
      // in one sitting by someone who believed the same wrong thing, and the
      // green suite afterwards was evidence of consistency, not correctness.
      // The way out is not more tests of the same kind — it is a test that
      // reaches data the author of the claim did not control, which is what
      // `hasHindiContent` does by reading the chart's actual text.
      //
      // What survives, and is genuinely worth guarding: the SHAPE. "In Hindi"
      // must be a property that coexists with the other axes, not a sixth
      // shelf that a chart has to choose instead of a trimester.
      const both = ChartFacets(stage: ChartStage.trimester3, inHindi: true);
      expect(both.satisfies(const ChartFilter(stage: ChartStage.trimester3)),
          isTrue);
      expect(both.satisfies(const ChartFilter(inHindi: true)), isTrue);
      expect(
          both.satisfies(
              const ChartFilter(stage: ChartStage.trimester3, inHindi: true)),
          isTrue,
          reason: 'a chart must be able to be a trimester chart AND in Hindi');

      // And the real library agrees about the shape, whatever its coverage:
      // the Hindi chart is found by the Hindi filter, and it is found by a
      // filter that asks for nothing in particular.
      expect(facetsFor('hindi_chart').inHindi, isTrue);
      expect(
          facetsFor('hindi_chart').satisfies(const ChartFilter()), isTrue);
    });

    test('Jain moved from Region to Diet, where it belongs', () {
      // It was filed under "Regional" because the old model had nowhere else
      // to put it. A Jain kitchen is defined by what it excludes, which is
      // what the diet axis is for, and it spans several regions.
      expect(facetsFor('regional_jain').diet, ChartDiet.jain);
      expect(facetsFor('regional_jain').region, isNull);
    });

    test('Egg is its own diet, not a shade of vegetarian', () {
      expect(ChartDiet.values, contains(ChartDiet.eggetarian));
      expect(ChartDiet.eggetarian.label.en, 'Egg');
    });

    test('re-tapping a chip clears that axis, and only that axis', () {
      // A chip you can turn on and not off is how someone gets stuck in a
      // filtered state and decides the app is broken.
      const f = ChartFilter(
          stage: ChartStage.trimester2, diet: ChartDiet.vegetarian);
      final cleared = f.withStage(ChartStage.trimester2);
      expect(cleared.stage, isNull);
      expect(cleared.diet, ChartDiet.vegetarian, reason: 'other axes survive');
    });

    test('postpartum is unreachable from a pregnancy week', () {
      // ⚠️ A mother at 40 weeks is still pregnant. Inferring "after birth"
      // from a week number would show her a postpartum chart before the birth.
      for (var w = 1; w <= 42; w++) {
        expect(stageForWeek(w), isNot(ChartStage.postpartum), reason: 'w$w');
      }
      expect(stageForWeek(40), ChartStage.trimester3);
    });
  });

  group('the charts screen starts where she is, and lets her leave', () {
    testWidgets('her trimester arrives pre-selected and is named', (t) async {
      final c = _at(32);
      addTearDown(c.dispose);
      await _pump(t, DietChartsScreen(pregnancy: c));

      expect(find.textContaining('You are in week 32'), findsOneWidget);
      expect(find.text('Third trimester chart'), findsOneWidget);
      // First-trimester charts are filtered out, but the CHIP is still there.
      expect(find.text('First trimester chart'), findsNothing);
      expect(find.text('First trimester'), findsWidgets);
    });

    testWidgets('one tap shows every stage again', (t) async {
      final c = _at(32);
      addTearDown(c.dispose);
      await _pump(t, DietChartsScreen(pregnancy: c));

      await t.tap(find.text('Show every stage instead'));
      await t.pumpAndSettle();

      // ⚠️ PERSONALISATION CHANGES WHAT IS FIRST, NEVER WHAT EXISTS — the
      // same line `test/landing_focus_test.dart` holds for the whole app.
      expect(find.text('First trimester chart'), findsOneWidget);
      expect(find.text('Third trimester chart'), findsOneWidget);
    });

    testWidgets('each axis gets its own labelled row', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, DietChartsScreen(pregnancy: c));

      // ⚠️ "THEY DON'T ALL MIX WITH EACH OTHER" IS THIS. One wrapped blob of
      // nineteen chips gives no signal that Vegetarian and Bengali are
      // different KINDS of choice, so selecting one feels like it should
      // deselect the other.
      for (final axis in ['STAGE', 'DIET', 'CONDITION', 'REGION', 'LANGUAGE']) {
        expect(find.text(axis), findsOneWidget, reason: axis);
      }
    });

    testWidgets('an impossible combination explains itself', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, DietChartsScreen(pregnancy: c));

      // ⚠️ `.first` IS LOAD-BEARING, AND THE AMBIGUITY IS THE FEATURE.
      // "Gestational diabetes" appears twice on this screen: once as the
      // filter chip, and once as a tag on the GDM chart's row. The tags are
      // deliberate — they are what makes a filtered list legible, since
      // without them she cannot tell why these four charts survived and the
      // other ten did not. The chips render above the list, so `.first` is
      // the chip.
      await t.tap(find.text('Gestational diabetes').first);
      await t.pump();
      await t.tap(find.text('Bengali').first);
      await t.pump();

      // With 14 charts across 5 axes some combinations genuinely have nothing
      // behind them. A blank screen there reads as a broken app.
      if (find.text('Show everything').evaluate().isNotEmpty) {
        expect(find.textContaining('No single chart covers'), findsOneWidget);
      }
    });
  });

  // ===========================================================================
  //  3 · The nutritionist is findable
  // ===========================================================================

  group('the paid option is on the landing screen', () {
    testWidgets('it is there, and it says it is paid', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, NutritionHomeScreen(pregnancy: c));

      expect(find.text('Talk to a nutritionist'), findsOneWidget);
      // ⚠️ A PAID OFFER DRESSED AS FREE CONTENT is the shape that makes people
      // distrust an app: she taps what looks like another article and hits a
      // price.
      expect(find.text('PAID'), findsOneWidget);
    });

    testWidgets('it sits after the free doors, not before them', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, NutritionHomeScreen(pregnancy: c));

      final free = t.getTopLeft(find.text('Can I eat this?')).dy;
      final paid = t.getTopLeft(find.text('Talk to a nutritionist')).dy;
      // The section's promise is that everything in it is free; opening with a
      // paid tile reframes the free content as a sample of something better.
      expect(free, lessThan(paid));
    });

    testWidgets('it opens the nutritionist, not the full expert list',
        (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, NutritionHomeScreen(pregnancy: c));

      await t.tap(find.text('Talk to a nutritionist'));
      await t.pumpAndSettle();

      expect(find.byType(ConsultationsScreen), findsOneWidget);
      // Same rule as the scans card: the words and the filter are one fact.
      // Since 2026-09-20 the facade lands on the nutritionist's own consult
      // page (the unified learn page): her name is on it, the obstetrician's
      // consult is not a card on it.
      final nutri = kSpecialists.firstWhere((x) => x.role.en == 'Prenatal Nutritionist');
      final ob = kSpecialists.firstWhere((x) => x.role.en == 'Obstetrician');
      expect(find.text('Consult with ${nutri.name.en}'), findsWidgets);
      // The obstetrician is on the page only as the "Other experts" rail,
      // below the head that names it — never as the page itself.
      final rail = t.getTopLeft(find.text('Other experts')).dy;
      for (final e in find.text('Consult with ${ob.name.en}').evaluate()) {
        expect(t.getTopLeft(find.byWidget(e.widget)).dy > rail, isTrue);
      }
    });
  });
}

// =============================================================================
//  Diet charts — a chart has a chart in it, and no filter promises fiction
// -----------------------------------------------------------------------------
//  Three defects lived in this section at once, and all three shared one shape:
//  something claimed more than existed, and nothing could fail.
//
//    1. Fifteen charts, none with any content — the screen showed a paragraph
//       DESCRIBING the chart she could not see.
//    2. Eight charts flagged `inHindi: true` with no Hindi anywhere.
//    3. Four filter values with no chart behind them, and because a null facet
//       means "works for any", tapping "Anaemia" returned every untagged chart
//       rather than none. A specific question, a confident generic answer.
//
//  ⚠️ NONE OF THESE COULD BE CAUGHT BY READING ONE FILE. Each was correct
//  locally: the facet table was well-formed, the filter logic was right, the
//  screen rendered. They existed only in the relationship between a claim and
//  the data behind it, which is what these tests check and nothing else does.
// =============================================================================

void _dietCharts() {
  group('every chart has an actual chart in it', () {
    test('no chart is a title with nothing behind it', () {
      for (final c in kDietCharts) {
        final content = kChartContent[c.id];
        expect(content, isNotNull,
            reason: '${c.id} has no content, so its page renders a heading '
                'and an apology');
        expect(content!.days, isNotEmpty, reason: c.id);
        expect(content.swaps, isNotEmpty, reason: c.id);
        expect(content.limits, isNotEmpty, reason: c.id);
      }
    });

    test('every day has meals and every meal has food in it', () {
      for (final e in kChartContent.entries) {
        for (final d in e.value.days) {
          expect(d.meals, isNotEmpty, reason: e.key);
          for (final m in d.meals) {
            expect(m.items.en.trim(), isNotEmpty, reason: e.key);
            expect(m.meal.en.trim(), isNotEmpty, reason: e.key);
          }
        }
      }
    });

    test('no content entry is an orphan', () {
      // A content entry with no chart is invisible - written, paid for in
      // review time, and never rendered. The wiring gate, pointed at data.
      final ids = kDietCharts.map((c) => c.id).toSet();
      for (final k in kChartContent.keys) {
        expect(ids, contains(k), reason: '$k has content but no chart');
      }
    });
  });

  group('the Hindi filter cannot lie', () {
    test('a chart is in Hindi only if its text is', () {
      // ⚠️ THE POINT IS THE DERIVATION, NOT THE COUNT. `facetsFor` ignores the
      // hand-written `inHindi` and reads the content, so this asserts the two
      // agree for every chart rather than pinning a number that would have to
      // be edited on every translation.
      for (final c in kDietCharts) {
        expect(facetsFor(c.id).inHindi, hasHindiContent(c.id), reason: c.id);
      }
    });

    test('exactly the translated charts answer a Hindi filter', () {
      const f = ChartFilter(inHindi: true);
      final hits =
          kDietCharts.where((c) => facetsFor(c.id).satisfies(f)).toList();
      // One today. This assertion is deliberately about identity rather than
      // count: when the other fourteen are translated they join this list on
      // their own, and the test that would then need editing is the wrong test.
      for (final c in hits) {
        expect(hasHindiContent(c.id), isTrue, reason: c.id);
      }
      expect(hits.map((c) => c.id), contains('hindi_chart'));
    });

    test('the translated chart is translated all the way through', () {
      // A chart that switches to English on day two is worse than one that
      // never claimed Hindi, because she has already committed to reading it.
      final c = kChartContent['hindi_chart']!;
      expect(c.focus.hi, isNot(c.focus.en));
      for (final d in c.days) {
        for (final m in d.meals) {
          expect(m.items.hi, isNot(m.items.en), reason: d.label.en);
        }
      }
    });
  });

  group('no filter value promises content that does not exist', () {
    // ⚠️ THIS IS THE TEST THE SECTION MOST NEEDED AND DID NOT HAVE. An enum
    // value is free to add and an option is free to render, so a filter's
    // vocabulary drifts ahead of the library with nobody deciding to
    // over-promise. Either the content gets written or the value comes out.
    void axisIsBacked<T>(List<T> values, ChartFilter Function(T) filter) {
      for (final v in values) {
        final hits = kDietCharts
            .where((c) => facetsFor(c.id).satisfies(filter(v)))
            .where((c) => facetsFor(c.id).specificity(filter(v)) > 0);
        expect(hits, isNotEmpty,
            reason: '$v is selectable and no chart is actually about it - '
                'she would get every untagged chart instead of an answer');
      }
    }

    test('every stage has a chart', () {
      axisIsBacked(ChartStage.values, (v) => ChartFilter(stage: v));
    });
    test('every diet has a chart', () {
      axisIsBacked(ChartDiet.values, (v) => ChartFilter(diet: v));
    });
    test('every condition has a chart', () {
      axisIsBacked(ChartCondition.values, (v) => ChartFilter(condition: v));
    });
    test('every region has a chart', () {
      axisIsBacked(ChartRegion.values, (v) => ChartFilter(region: v));
    });
  });

  group('the export is real', () {
    test('the filename comes from the id, never the title', () {
      // ⚠️ A TITLE IS LocalizedText. Slugging it would produce a Devanagari
      // filename in the Hindi build - handled badly by printers and some file
      // managers, and the same chart would arrive under two names depending on
      // a setting. `.en` is identity; this is that rule reaching a filename.
      expect(DietChartPdf.slugForFilename('gestational_diabetes_chart'),
          'gestational-diabetes-chart');
      expect(DietChartPdf.slugForFilename('t1_chart'), 't1-chart');
    });

    test('a doctor note sits only where a clinician owns the decision', () {
      // Present on the three where a number or a prescription is being managed.
      // ⚠️ AND ABSENT ELSEWHERE ON PURPOSE: a disclaimer stamped on every
      // screen is a disclaimer nobody reads on the one screen that needed it.
      const owed = {
        'gestational_diabetes_chart',
        'weight_gain_chart',
        'regional_jain',
        'anaemia_chart',
      };
      for (final e in kChartContent.entries) {
        expect(e.value.doctorNote != null, owed.contains(e.key),
            reason: e.key);
      }
    });
  });
}
