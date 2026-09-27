// =============================================================================
//  TTC tool rebuild (2026-09-27, night): the look-up tools
// -----------------------------------------------------------------------------
//  Medical tests, Can I...?, This week's food ideas, the Journey map and the
//  Family timeline were rebuilt from "old tools in new clothes" (shadowed
//  cards that grew in place) into lists that open a page, in this app's
//  current design. Each group pins one thing she can now do, or one defect
//  that is gone:
//
//    · a test or an answer opens as a read, with its way on right there;
//    · "Yes, with a limit" means one thing and names the limit;
//    · a food swap is kept, and can be undone;
//    · every milestone still ahead says how, and goes there;
//    · the timeline wears the tool shell, and its promise holds whichever way
//      she arrives.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/ttc/ttc_can_i_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart' show TtcCard, TtcBackBar;
import 'package:parentveda/screens/ttc/ttc_journey_map_screen.dart';
import 'package:parentveda/screens/ttc/ttc_nutrition_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart'
    show ttcScreenForSurface;
import 'package:parentveda/screens/ttc/ttc_tests_screen.dart';
import 'package:parentveda/screens/ttc/ttc_timeline_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/services/family_timeline.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_can_i_data.dart';
import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_lookup_reads.dart';
import 'package:parentveda/ttc/ttc_milestones.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';
import 'package:parentveda/ttc/ttc_tests_data.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(1200, 8000)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcJournalStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcSupplementsStore.instance.resetForTest();
    FamilyTimeline.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('Medical tests: a list, and a page per test', () {
    testWidgets('first open: search, the switch, headed rows, no old cards',
        (tester) async {
      await _pump(tester, const TtcTestsScreen());
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('EVERYDAY BLOOD TESTS'), findsOneWidget);
      expect(find.text('THE TUBE TEST'), findsOneWidget);
      expect(find.text('AMH'), findsOneWidget);
      // The when stays on the row: it is the fact that costs a month.
      final fsh = ttcTestById('fsh_lh')!;
      expect(find.text(fsh.when(false)), findsOneWidget);
      // Kept for revert: the V1 shadowed card was the row.
      expect(find.byType(TtcCard), findsNothing,
          reason: 'old-UI cards inside the new shell were the complaint');
    });

    testWidgets('search finds a name from the doctor\'s list, his too',
        (tester) async {
      await _pump(tester, const TtcTestsScreen());
      await tester.enterText(find.byType(TextField), 'semen');
      await tester.pumpAndSettle();
      expect(find.text('Semen analysis'), findsOneWidget);
      expect(find.text('AMH'), findsNothing);
      await tester.enterText(find.byType(TextField), 'zzqx');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_tests_ask_veda')), findsOneWidget);
    });

    testWidgets('a tap opens the test as a read, when first, then add',
        (tester) async {
      await _pump(tester, const TtcTestsScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_test_row_amh')));
      await tester.pumpAndSettle();
      expect(find.byType(PvReaderScreen), findsOneWidget);
      expect(find.text('When should I have it?'), findsOneWidget);
      expect(find.text(ttcTestById('amh')!.reading(false)), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('ttc_test_add_amh')));
      await tester.tap(find.byKey(const ValueKey('ttc_test_add_amh')));
      await tester.pumpAndSettle();
      expect(find.text('Add a result'), findsOneWidget,
          reason: 'Records opens on the add page with AMH chosen');
    });

    testWidgets('his side: his test and the report reader, as rows',
        (tester) async {
      await _pump(tester, const TtcTestsScreen());
      await tester.tap(find.text(const TtcS(false).testForHim));
      await tester.pumpAndSettle();
      expect(find.text('Semen analysis'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_tests_semen_reader')),
          findsOneWidget);
    });

    testWidgets('an Ask Veda pointer opens the test; Back is the whole list',
        (tester) async {
      await _pump(tester, const TtcTestsScreen(focusId: 'semen'));
      expect(find.byType(PvReaderScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_test_semen_reader')),
          findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      expect(find.text('Semen analysis'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_tests_semen_reader')),
          findsOneWidget,
          reason: 'the switch flipped to his side for his test');
    });

    test('every test read has the three questions and a way to add', () {
      for (final t in ttcTests) {
        final r = ttcTestAsRead(t);
        final heads = r.toc.map((h) => h.en).toList();
        expect(heads.first, 'When should I have it?', reason: t.id);
        expect(heads, contains('What does my result mean?'));
        expect(r.sections.any((s) => s.custom is TtcTestActionBlock), isTrue);
        for (final id in r.readNext) {
          expect(ttcTestReadById(id), isNotNull, reason: id);
        }
      }
    });
  });

  // ===========================================================================
  group('Can I: one meaning for "with a limit"', () {
    test('"In moderation" is gone; every limited answer names its limit', () {
      expect(TtcVerdict.moderate.label(false), 'Yes, with a limit');
      for (final e in ttcCanI) {
        if (e.verdict == TtcVerdict.moderate) {
          expect(e.limit(false), isNotNull, reason: e.id);
        } else {
          expect(e.limit(false), isNull, reason: e.id);
        }
      }
      // A number where the answer has one.
      expect(ttcCanIById('chai')!.limit(false), contains('200mg'));
    });

    testWidgets('each row shows the verdict word and its limit',
        (tester) async {
      await _pump(tester, const TtcCanIScreen());
      expect(
          find.textContaining('Yes, with a limit · about 200mg',
              findRichText: true),
          findsOneWidget);
      expect(find.byType(TtcCard), findsNothing);
      // The way to ask is always there, not only on an empty search.
      expect(find.byKey(const ValueKey('ttc_can_i_ask_veda_foot')),
          findsOneWidget);
    });

    testWidgets('a tap opens the answer as a read: verdict, short, why',
        (tester) async {
      await _pump(tester, const TtcCanIScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_can_i_row_chai')));
      await tester.pumpAndSettle();
      expect(find.byType(PvReaderScreen), findsOneWidget);
      expect(find.text('Yes, with a limit: about 200mg of caffeine a day.'),
          findsOneWidget);
      expect(find.text(ttcCanIById('chai')!.short(false)), findsOneWidget);
      expect(find.text('Why is that the answer?'), findsOneWidget);
    });

    test('every answer read resolves its read-next', () {
      for (final e in ttcCanI) {
        for (final id in ttcCanIAsRead(e).readNext) {
          expect(ttcCanIReadById(id), isNotNull, reason: id);
        }
      }
    });
  });

  // ===========================================================================
  group('Food ideas: one day at a time, and a swap that stays', () {
    testWidgets('a day strip opens today; a tap opens another day',
        (tester) async {
      await _pump(tester, const TtcNutritionScreen());
      final week = TtcNutritionScreen.weekFrom(DateTime.now());
      expect(find.byKey(const ValueKey('ttc_food_day_strip')), findsOneWidget);
      expect(find.text(week.first.$2.meal(false)), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_food_day_2')));
      await tester.pumpAndSettle();
      expect(find.text(week[2].$2.meal(false)), findsOneWidget);
    });

    testWidgets('swap is kept across visits, and can be undone',
        (tester) async {
      await _pump(tester, const TtcNutritionScreen());
      final first = TtcNutritionScreen.weekFrom(DateTime.now()).first.$2;
      await tester.tap(find.text('Swap this day'));
      await tester.pumpAndSettle();
      expect(find.text(first.meal(false)), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      final saved =
          jsonDecode(prefs.getString(kTtcFoodSwapsKey)!) as Map<String, dynamic>;
      expect(saved[ttcFoodDayKey(DateTime.now())], isNot(first.id));

      // A new visit still shows the swap.
      await _pump(tester, const TtcNutritionScreen());
      expect(find.text(first.meal(false)), findsNothing);
      await tester.tap(find.byKey(const ValueKey('ttc_food_unswap')));
      await tester.pumpAndSettle();
      expect(find.text(first.meal(false)), findsOneWidget);
    });
  });

  // ===========================================================================
  group('Journey map: still ahead says how, and goes there', () {
    test('every milestone has a way, and every way opens a live screen', () {
      for (final m in ttcMilestones) {
        expect(kTtcMilestoneWays.containsKey(m.id), isTrue, reason: m.id);
        final way = kTtcMilestoneWays[m.id]!;
        expect(way.action != null || way.byItself != null || m.id == 'journey_started',
            isTrue,
            reason: '${m.id} would be a row ahead with nothing to do');
        if (way.surface != null) {
          expect(ttcScreenForSurface(way.surface!), isNotNull,
              reason: '${m.id} -> ${way.surface}');
        }
      }
    });

    testWidgets('ahead rows name the action; done rows carry no count',
        (tester) async {
      TtcSupplementsStore.instance.add('Folic acid');
      await _pump(tester, const TtcJourneyMapScreen());
      expect(find.text('Write in the journal'), findsOneWidget);
      expect(find.text('Started your supplements'), findsOneWidget);
      expect(find.text('1'), findsNothing,
          reason: 'a number beside effort reads as a score');
      expect(find.byType(TtcCard), findsNothing);
    });
  });

  // ===========================================================================
  group('Family timeline', () {
    testWidgets('wears the tool shell, not the old back-bar page',
        (tester) async {
      await _pump(tester, const TtcTimelineScreen());
      expect(find.byType(TtcToolScaffold), findsOneWidget);
      expect(find.byType(TtcBackBar), findsNothing);
      expect(find.text('FAMILY TIMELINE'), findsOneWidget);
    });

    testWidgets('its promise holds without visiting the map first',
        (tester) async {
      // Before: a reached milestone reached the timeline only after the
      // Journey map had been opened.
      TtcSupplementsStore.instance.add('Folic acid');
      expect(FamilyTimeline.instance.count, 0);
      await _pump(tester, const TtcTimelineScreen());
      expect(find.text('Started your supplements'), findsOneWidget);
      // And the moment opens where it lives.
      expect(
          find.byKey(const ValueKey(
              'ttc_timeline_event_ttc_ms_supplements_started')),
          findsOneWidget);
      expect(ttcTimelineSurface('ttc_ms_supplements_started'),
          'ttc_supplements');
      expect(ttcTimelineSurface('ttc_positive_test'), isNull);
    });
  });

  // ===========================================================================
  group('no overflow at 360dp', () {
    for (final (name, screen) in <(String, Widget)>[
      ('tests', const TtcTestsScreen()),
      ('can i', const TtcCanIScreen()),
      ('food', const TtcNutritionScreen()),
      ('map', const TtcJourneyMapScreen()),
      ('timeline', const TtcTimelineScreen()),
    ]) {
      for (final hindi in const [false, true]) {
        testWidgets('$name (${hindi ? 'Hindi' : 'English'})', (tester) async {
          TtcLang.instance.hinglish = hindi;
          TtcSupplementsStore.instance.add('Folic acid');
          await _pump(tester, screen, size: const Size(360, 3000));
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('a test read and an answer read at 360dp', (tester) async {
      await _pump(tester, const TtcTestsScreen(focusId: 'fsh_lh'),
          size: const Size(360, 3000));
      expect(tester.takeException(), isNull);
      await _pump(tester, const TtcCanIScreen(focusId: 'hot_bath'),
          size: const Size(360, 3000));
      expect(tester.takeException(), isNull);
    });
  });
}
