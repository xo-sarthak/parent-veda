// =============================================================================
//  Parenting tools 25-28, the You, Maa family: the clinical lines and the
//  search, held (docs/pp-tool-plans/25-28-you-maa.md, 2026-10-25).
//
//  Can I...?:
//  · every red flag reads "See a doctor today", never "Ask your doctor first";
//  · one word, one verdict (D4);
//  · the search matches whole words, so "infant" no longer finds the AC;
//  · it agrees with Kegel Care and the door on the pelvic floor, alcohol and
//    fasting;
//  · a search with no answer offers Ask Veda; "In the first six weeks" shows
//    only in her first six weeks; the sources line is on the page;
//  · `pp_maa_can_i/<category>` opens on that chip.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_maa_can_i_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

Future<void> _pump(WidgetTester t, Widget screen) async {
  t.view.physicalSize = const Size(1080, 7200);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: screen));
  await t.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.resetForTest();
  });
  tearDown(() => ChildProfileStore.instance.resetForTest());

  group('Can I...? clinical lines', () {
    test('every red flag is urgent', () {
      for (final q in [
        'Wait out a fever after birth',
        'Wait out heavy bleeding',
        'Rest off a bad headache or blurred vision',
        'Ignore pain or swelling in one leg',
        'Ignore chest pain or breathlessness',
        'Ignore a red, hot or oozing wound',
        'Keep thoughts of harming myself or the baby to myself',
      ]) {
        expect(ppMaaCanIVerdictFor(q), 'See a doctor today', reason: q);
      }
    });

    // A medicine or a drink has one verdict wherever its name leads. Words
    // shared by genuinely different questions (a fever while breastfeeding,
    // and a fever after the birth) are allowed; the names of things she takes
    // are not.
    const oneVerdict = [
      'bp tablets', 'metformin', 'insulin', 'telmisartan', 'benadryl',
      'cough syrup', 'shatavari', 'amoxicillin', 'azithromycin', 'cetirizine',
      'sertraline', 'wine', 'beer', 'alcohol',
    ];
    test('one word, one verdict, for what she takes', () {
      final seen = <String, String>{};
      final clashes = <String>[];
      for (final (alias, verdict) in ppMaaCanIAliasVerdicts()
          .where((e) => oneVerdict.contains(e.$1))) {
        final before = seen[alias];
        if (before != null && before != verdict) {
          clashes.add('$alias: $before / $verdict');
        }
        seen[alias] = verdict;
      }
      expect(clashes, isEmpty);
    });

    test('it agrees with Kegel Care and the door', () {
      expect(ppMaaCanIVerdictFor('Do pelvic floor exercises'), 'Yes, with care');
      expect(ppMaaCanIVerdictFor('Drink alcohol'), 'Best avoided');
      expect(
          ppMaaCanIVerdictFor('Take telmisartan or losartan for blood pressure'),
          'Ask your doctor first');
      expect(ppMaaCanIVerdictFor('Take weight-loss or fat-burner pills'), 'Best avoided');
    });
  });

  group('Can I...? search', () {
    test('whole words: no alias hiding inside what she typed', () {
      expect(ppMaaCanISearch('infant').any((q) => q.contains('AC')), isFalse);
      // Only rows about a pillow, never the contraceptive pill.
      expect(ppMaaCanISearch('pillow').every((q) => q.toLowerCase().contains('pillow')), isTrue);
      expect(ppMaaCanISearch('until').any((q) => q.toLowerCase().contains('til')), isFalse);
      expect(ppMaaCanISearch('horse riding').any((q) => q.contains('ORS')), isFalse);
    });

    test('the start of a word still finds it, and a brand inside a phrase', () {
      expect(ppMaaCanISearch('cro'), isNotEmpty);
      expect(ppMaaCanISearch('crocin 650'), isNotEmpty);
      expect(ppMaaCanISearch('chai'), isNotEmpty);
      expect(ppMaaCanISearch('c'), isEmpty, reason: 'two characters at least');
    });

    testWidgets('no answer: Ask Veda with the question typed', (t) async {
      await _pump(t, const PpMaaCanIScreen(initialQuery: 'zzqx'));
      expect(find.byKey(const ValueKey('pp_maa_can_i_ask_veda')), findsOneWidget);
      expect(find.text('Ask Veda about zzqx'), findsOneWidget);
    });

    testWidgets('the sources line is on the page, and the intro promises no Hindi search',
        (t) async {
      await _pump(t, const PpMaaCanIScreen());
      expect(find.byKey(const ValueKey('pp_maa_can_i_sources'), skipOffstage: false),
          findsOneWidget);
      expect(find.textContaining('English or Hindi'), findsNothing);
    });
  });

  group('Can I...? for her week', () {
    Future<void> openStrength(WidgetTester t) async {
      await _pump(t, const PpMaaCanIScreen(initialQuery: 'strength'));
      await t.tap(find.byKey(
          const ValueKey('pp_maa_can_i_row_Do strength training at home')));
      await t.pumpAndSettle();
    }

    testWidgets('"In the first six weeks" shows at week 3', (t) async {
      ChildProfileStore.instance
          .debugSetDob(DateTime.now().subtract(const Duration(days: 21)));
      await openStrength(t);
      expect(find.textContaining('In the first six weeks'), findsOneWidget);
    });

    testWidgets('and not ten months on', (t) async {
      ChildProfileStore.instance
          .debugSetDob(DateTime.now().subtract(const Duration(days: 300)));
      await openStrength(t);
      expect(find.textContaining('In the first six weeks'), findsNothing);
    });

    testWidgets('a red flag offers the emergency numbers; the harm row the crisis path',
        (t) async {
      await _pump(t, const PpMaaCanIScreen(initialQuery: 'leg pain'));
      await t.tap(find.byKey(
          const ValueKey('pp_maa_can_i_row_Ignore pain or swelling in one leg')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_maa_can_i_emergency')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_maa_can_i_crisis')), findsNothing);
      // A fresh screen (same type at the same place would keep its state).
      await t.pumpWidget(const SizedBox());
      await _pump(t, const PpMaaCanIScreen(initialQuery: 'scary thoughts'));
      await t.tap(find.byKey(const ValueKey(
          'pp_maa_can_i_row_Keep thoughts of harming myself or the baby to myself')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_maa_can_i_crisis')), findsOneWidget);
    });
  });

  test('pp_maa_can_i/<category> opens on that chip; an unknown one opens plain', () {
    final med = ppScreenForSurface('pp_maa_can_i/medicines');
    expect(med, isA<PpMaaCanIScreen>());
    expect((med as PpMaaCanIScreen).initialCategory, 'medicines');
    final odd = ppScreenForSurface('pp_maa_can_i/nonsense') as PpMaaCanIScreen;
    expect(odd.initialCategory, isNull);
  });
}
