// =============================================================================
//  The symptom logger, rebuilt into the tool shell (2026-09-27, night)
// -----------------------------------------------------------------------------
//  Holds what the rebuild fixed, every tap of it, at 360pt:
//    · first open: the tool's name, a question about the day, nothing saved;
//    · a tap is listed as saved, and its × takes it off with an Undo;
//    · a past day by arrow and by calendar, and a way back to today;
//    · weight and temperature say Add or Change, the sheet says which day,
//      nudges with − and +, saves with Save, removes with Undo;
//    · Done closes and says what was kept;
//    · hidden cards are said, and are remembered after a restart (the bug:
//      only the Show or hide page loaded them);
//    · Show or hide names what is in each card, says why the last switch is
//      locked, and "Show all" undoes it in one tap;
//    · the long disclaimer is a question she opens;
//    · the chart's bands come from the cycle palette.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_report_screen.dart'
    show TtcCycleReportScreen;
import 'package:parentveda/screens/ttc/ttc_edit_categories_screen.dart';
import 'package:parentveda/screens/ttc/ttc_symptom_log_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart' show TtcToolClose;
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_cycle_report.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcCategoryPrefs.instance.resetForTest();
  });

  DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  final today = dayOnly(DateTime.now());
  final yesterday = today.subtract(const Duration(days: 1));

  Future<void> pump(WidgetTester tester, Widget home,
      {double height = 5200}) async {
    tester.view.physicalSize = Size(360, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: home));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  /// Lets a snack time out so no timer is left pending.
  Future<void> drain(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
  }

  Set<String> fieldsOn(DateTime d) => TtcLogStore.instance
      .valuesOn(kTtcSymptomTracker, TtcLogStore.dayKey(d))
      .map((v) => v.field)
      .toSet();

  // ===========================================================================
  group('first open', () {
    testWidgets('names the tool, asks about today, and has nothing saved',
        (tester) async {
      await pump(tester, const TtcSymptomLogScreen());
      expect(find.text(kTtcLogEyebrow.toUpperCase()), findsOneWidget);
      expect(find.text('How is today going?'), findsOneWidget);
      expect(find.text(kTtcLogHowItWorks), findsOneWidget);
      // 2026-09-28: nothing saved says nothing at the top: no card, no
      // pill. Was: expect(find.text(ttcLogSavedLine(0)), findsOneWidget);
      expect(find.text(ttcLogSavedLine(0)), findsNothing);
      expect(find.byKey(const ValueKey('ttc_log_saved_card')), findsNothing);
      expect(find.byKey(const ValueKey('ttc_log_saved_pill')), findsNothing);
      // Both number cards say what a tap does.
      expect(find.byKey(const ValueKey('ttc_measure_action_kg')),
          findsOneWidget);
      // U2 (2026-09-28): Flo's card, the grey "Log your ..." line and a
      // pencil. Was: expect(find.text(kTtcMeasureAdd), findsNWidgets(2));
      expect(find.text(kTtcMeasureWeightHint), findsOneWidget);
      expect(find.text(kTtcMeasureTempHint), findsOneWidget);
      expect(find.text(kTtcMeasureViewChart), findsNWidgets(2));
      // One way out, and the report as a link.
      expect(find.byKey(const ValueKey('ttc_log_done')), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_log_open_report')), findsOneWidget);
    });

    testWidgets('lays out at phone height, all the way down', (tester) async {
      await pump(tester, const TtcSymptomLogScreen(), height: 780);
      for (var i = 0; i < 16; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 60));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('the long disclaimer is a question she can open',
        (tester) async {
      await pump(tester, const TtcSymptomLogScreen());
      expect(find.text(kTtcLogPregnancyQuestion), findsOneWidget);
      expect(find.textContaining('the same hormone'), findsNothing);
      await tester.tap(find.text(kTtcLogPregnancyQuestion));
      await tester.pump();
      expect(find.textContaining('the same hormone'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('add and remove', () {
    // 2026-09-28: the saved list moved from a card above the search into a
    // sheet behind the hero's "3 saved" pill. Was: a tap showed
    // ttcLogSavedLine(1) and a 'ttc_log_saved_calm' chip on the page.
    testWidgets('a tap is counted in the hero, and listed behind the pill',
        (tester) async {
      await pump(tester, const TtcSymptomLogScreen());
      await tester.tap(find.text('Calm'));
      await tester.pump();
      expect(find.text(ttcLogSavedPill(1)), findsOneWidget);
      expect(fieldsOn(today), contains('calm'));
      await tester.tap(find.byKey(const ValueKey('ttc_log_saved_pill')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_log_saved_sheet')), findsOneWidget);
      expect(find.text(ttcLogSavedSheetTitle('Today')), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_log_saved_calm')), findsOneWidget);
    });

    // Was: the × on the page's saved card, then an Undo in a snack. A snack
    // cannot be tapped under a sheet, so the Undo is in the row now.
    testWidgets('the × in the sheet takes it off, and Undo puts it back',
        (tester) async {
      TtcLogStore.instance.log(kTtcSymptomTracker, 'cramping', 1, on: today);
      await pump(tester, const TtcSymptomLogScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_log_saved_pill')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_log_saved_cramping')));
      await tester.pump();
      expect(fieldsOn(today), isNot(contains('cramping')));
      expect(find.text(ttcLogSavedLine(0)), findsOneWidget,
          reason: 'the sheet says what is left');
      await tester.tap(
          find.byKey(const ValueKey('ttc_log_saved_undo_cramping')));
      await tester.pump();
      expect(fieldsOn(today), contains('cramping'));
      expect(find.text(ttcLogSavedLine(1)), findsOneWidget);
    });

    testWidgets('the search is a white field with an ink edge, not a tinted '
        'pill', (tester) async {
      await pump(tester, const TtcSymptomLogScreen());
      final field = tester.widget<TextField>(
          find.byKey(const ValueKey('ttc_log_search')));
      final d = field.decoration!;
      expect(d.filled, isTrue);
      expect(d.fillColor, Colors.white);
      for (final b in [d.border, d.enabledBorder, d.focusedBorder]) {
        expect(b, isA<OutlineInputBorder>());
        final side = (b! as OutlineInputBorder).borderSide;
        expect(side.color, const Color(0xFF2F2C30), reason: 'ttcInk');
      }
      // No lavender (`ttcPanel`) box round it.
      expect(
          find.ancestor(
              of: find.byKey(const ValueKey('ttc_log_search')),
              matching: find.byWidgetPredicate((w) =>
                  w is Container &&
                  w.decoration is BoxDecoration &&
                  (w.decoration! as BoxDecoration).color ==
                      const Color(0xFFEDEAF0))),
          findsNothing);
    });

    testWidgets('a past day with things saved fits the close row at 360',
        (tester) async {
      final d = today.subtract(const Duration(days: 9));
      TtcLogStore.instance.log(kTtcSymptomTracker, 'calm', 1, on: d);
      TtcLogStore.instance.log(kTtcSymptomTracker, 'cramping', 1, on: d);
      TtcLogStore.instance.log(kTtcWeightTracker, kTtcWeightField, 61.5, on: d);
      await pump(tester, TtcSymptomLogScreen(day: d), height: 780);
      expect(find.text(ttcLogSavedPill(3)), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_log_back_to_today')),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the day sits in the close row: the name is above the title',
        (tester) async {
      await pump(tester, const TtcSymptomLogScreen());
      final name =
          tester.getRect(find.byKey(const ValueKey('ttc_log_day_name')));
      final title = tester.getRect(find.text('How is today going?'));
      final search =
          tester.getRect(find.byKey(const ValueKey('ttc_log_search')));
      expect(name.bottom, lessThan(title.top));
      // The day's row IS the close button's row: their middles line up.
      final close = tester.getRect(find.byType(TtcToolClose));
      expect((close.center.dy - name.center.dy).abs(), lessThan(24));
      // And the search is the first thing in the sheet. Measured in the test
      // font (every glyph a full em, so lines wrap sooner than on a phone):
      // 284 now, against roughly 440 with the picker band and the saved card.
      expect(search.top, lessThan(300));
    });
  });

  // ===========================================================================
  group('a past day', () {
    testWidgets('the arrow steps back, the tap lands there, and there is a '
        'way back to today', (tester) async {
      await pump(tester, const TtcSymptomLogScreen());
      expect(find.byKey(const ValueKey('ttc_log_back_to_today')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('ttc_log_day_back')));
      await tester.pump();
      expect(find.text('How was yesterday?'), findsOneWidget);
      await tester.tap(find.text('Calm'));
      await tester.pump();
      expect(fieldsOn(yesterday), contains('calm'));
      expect(fieldsOn(today), isEmpty);
      await tester.tap(find.byKey(const ValueKey('ttc_log_back_to_today')));
      await tester.pump();
      expect(find.text('How is today going?'), findsOneWidget);
    });

    testWidgets('an older day says its weekday', (tester) async {
      final d = today.subtract(const Duration(days: 9));
      await pump(tester, TtcSymptomLogScreen(day: d));
      const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      expect(find.textContaining(wd[d.weekday - 1]), findsWidgets);
    });

    testWidgets('the day name opens a calendar that stops at today',
        (tester) async {
      await pump(tester, const TtcSymptomLogScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_log_day_name')));
      await tester.pumpAndSettle();
      expect(find.text(kTtcLogPickDayTitle), findsOneWidget);
      // Cancelling leaves the day as it was.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('How is today going?'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('weight and temperature', () {
    testWidgets('the sheet says which day, nudges, and saves with Save',
        (tester) async {
      await pump(tester, const TtcSymptomLogScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_measure_action_kg')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_measure_for')), findsOneWidget);
      expect(find.text(ttcLogSheetFor('Today', null)), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_measure_remove')), findsNothing,
          reason: 'nothing to remove yet');
      await tester.tap(find.byKey(const ValueKey('ttc_measure_plus')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_measure_save')));
      await tester.pumpAndSettle();
      expect(
          TtcLogStore.instance
              .valueFor(kTtcWeightTracker, kTtcWeightField)
              ?.value,
          60.1);
      expect(find.text(ttcLogMeasureSaved('Weight', 'Today')), findsOneWidget);
      // U2 (2026-09-28): the card shows the number, a pencil and a bin.
      // Was: expect(find.text(kTtcMeasureChange), findsOneWidget);
      expect(find.text('60.1'), findsOneWidget);
      expect(find.byTooltip('Change Weight'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_measure_delete_kg')),
          findsOneWidget);
      await drain(tester);
    });

    testWidgets('a reading can be removed, and Undo brings it back',
        (tester) async {
      TtcLogStore.instance
          .log(kTtcWeightTracker, kTtcWeightField, 64.2, on: today);
      await pump(tester, const TtcSymptomLogScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_measure_action_kg')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_measure_remove')));
      await tester.pumpAndSettle();
      expect(
          TtcLogStore.instance.valueFor(kTtcWeightTracker, kTtcWeightField),
          isNull);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(
          TtcLogStore.instance
              .valueFor(kTtcWeightTracker, kTtcWeightField)
              ?.value,
          64.2);
      await drain(tester);
    });

    testWidgets('the bin on the card removes, and Undo brings it back',
        (tester) async {
      TtcLogStore.instance
          .log(kTtcWeightTracker, kTtcWeightField, 64.2, on: today);
      await pump(tester, const TtcSymptomLogScreen());
      expect(find.byKey(const ValueKey('ttc_measure_delete_°C')),
          findsNothing,
          reason: 'no bin on a card with nothing to remove');
      await tester.tap(find.byKey(const ValueKey('ttc_measure_delete_kg')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
          TtcLogStore.instance.valueFor(kTtcWeightTracker, kTtcWeightField),
          isNull);
      expect(find.text(kTtcMeasureWeightHint), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(
          TtcLogStore.instance
              .valueFor(kTtcWeightTracker, kTtcWeightField)
              ?.value,
          64.2);
      await drain(tester);
    });

    testWidgets('View chart opens the report on that number', (tester) async {
      await pump(tester, const TtcSymptomLogScreen());
      final chart = find.byKey(const ValueKey('ttc_measure_chart_°C'));
      await tester.ensureVisible(chart);
      await tester.tap(chart);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final report = tester
          .widget<TtcCycleReportScreen>(find.byType(TtcCycleReportScreen));
      expect(report.series, TtcMeasureKind.temperature);
    });

    testWidgets('the temperature sheet says how to take it', (tester) async {
      await pump(tester, const TtcSymptomLogScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_measure_action_°C')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_measure_temp_how_to')),
          findsOneWidget);
      await tester.tap(find.byTooltip('Close').last);
      await tester.pumpAndSettle();
    });
  });

  // ===========================================================================
  group('done', () {
    testWidgets('closes and says what was kept', (tester) async {
      TtcLogStore.instance.log(kTtcSymptomTracker, 'calm', 1, on: today);
      await pump(
          tester,
          Builder(
              builder: (c) => Scaffold(
                    body: Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(c).push(
                            MaterialPageRoute<void>(
                                builder: (_) => const TtcSymptomLogScreen())),
                        child: const Text('open'),
                      ),
                    ),
                  )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_log_done')));
      await tester.pumpAndSettle();
      expect(find.byType(TtcSymptomLogScreen), findsNothing);
      expect(find.text(ttcLogDoneLine(1, 'Today')), findsOneWidget);
      expect(ttcLogDoneLine(1, 'Today'), '1 thing saved for today');
      await drain(tester);
    });
  });

  // ===========================================================================
  group('show or hide', () {
    testWidgets('a hidden card is said, and remembered after a restart',
        (tester) async {
      // A restart: her choice is on disk and nothing has loaded it yet.
      SharedPreferences.setMockInitialValues({
        'ttc_hidden_symptom_categories': ['sex'],
      });
      TtcCategoryPrefs.instance.resetForTest();
      await pump(tester, const TtcSymptomLogScreen());
      await tester.pump(const Duration(milliseconds: 50));
      expect(TtcCategoryPrefs.instance.isHidden('sex'), isTrue,
          reason: 'the logger never loaded her choices');
      expect(find.text('Sex'), findsNothing);
      expect(find.text(ttcLogHiddenLine(1)), findsOneWidget);
    });

    testWidgets('rows say what is in each card, and Show all brings them back',
        (tester) async {
      await pump(tester, const TtcEditCategoriesScreen());
      expect(find.text(kTtcEditCategoriesTitle), findsOneWidget);
      final sex = kTtcCategoryGroups.firstWhere((g) => g.id == 'sex');
      expect(find.text(ttcCategorySample(sex)), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_categories_show_all')),
          findsNothing);
      await TtcCategoryPrefs.instance.setHidden('sex', true);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_categories_show_all')));
      await tester.pump();
      expect(TtcCategoryPrefs.instance.hidden, isEmpty);
    });

    testWidgets('the last switch on says why it will not turn off',
        (tester) async {
      await pump(tester, const TtcEditCategoriesScreen());
      final groups = kTtcCategoryGroups;
      for (final g in groups.skip(1)) {
        await TtcCategoryPrefs.instance.setHidden(g.id, true);
      }
      await tester.pump();
      expect(find.text(kTtcCategoriesKeepOne), findsOneWidget);
    });
  });

  // ===========================================================================
  test('the chart bands come from the cycle palette, not typed hues', () {
    final src =
        File('lib/screens/ttc/ttc_symptom_log_screen.dart').readAsStringSync();
    expect(src, contains('const periodTint = TtcCycleColours.periodTint;'));
    expect(src, contains('const fertileTint = TtcCycleColours.fertileTint;'));
  });

  test('the day words read the way people say them', () {
    expect(ttcLogTitle('Yesterday'), 'How was yesterday?');
    expect(ttcLogTitle('Wed 24 Sep'), 'How was Wed 24 Sep?');
    expect(ttcLogSheetFor('Today', 7), 'For today · Cycle day 7');
    expect(ttcLogDoneLine(3, 'Wed 24 Sep'), '3 things saved for Wed 24 Sep');
  });
}
