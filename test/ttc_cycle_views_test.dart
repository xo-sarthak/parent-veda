// =============================================================================
//  The cycle views rebuild (2026-09-27, night): one palette, and every "add"
//  with its button
// -----------------------------------------------------------------------------
//  The user on build 13: the cycle report said "add your temperature and
//  weight" with nothing to tap, and the cycle colours were "thrown around
//  randomly" (a blue hero, a green ring, a pink calendar, a violet window) and
//  faded. These hold the fixes:
//
//    * one palette (`ttc_cycle_palette.dart`) that every cycle view reads, and
//      a source scan so a stray hex or the old accents cannot come back;
//    * the report's numbers card opens the daily log;
//    * a period can be opened, changed and removed (with Undo) from the
//      Companion and from any bleeding day on the calendar;
//    * an appointment on the calendar's day card opens its own page;
//    * the report pages back to this cycle in one tap;
//    * all of it lays out at 360dp.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_appointments_screen.dart';
import 'package:parentveda/screens/ttc/ttc_calendar_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_companion.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_palette.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_report_screen.dart';
import 'package:parentveda/screens/ttc/ttc_symptom_log_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_cycle_report.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    TtcAppointmentsStore.instance.resetForTest();
  });

  DateTime ago(int days) {
    final n = DateTime.now().subtract(Duration(days: days));
    return DateTime(n.year, n.month, n.day);
  }

  void healthy() {
    CycleStore.instance
      ..logPeriodStart(ago(68))
      ..logPeriodStart(ago(40))
      ..logPeriodStart(ago(12));
  }

  Future<void> pumpTall(
    WidgetTester tester,
    Widget home, {
    double width = 400,
  }) async {
    tester.view.physicalSize = Size(width, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: home));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  // ===========================================================================
  group('one palette', () {
    double contrast(Color a, Color b) {
      final la = a.computeLuminance(), lb = b.computeLuminance();
      final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
      return (hi + 0.05) / (lo + 0.05);
    }

    test('four parts, four different fills', () {
      final fills = {for (final p in TtcPhase.values) TtcCycleColours.fill(p)};
      expect(fills.length, TtcPhase.values.length);
    });

    test('only the period and the fertile days carry a hue', () {
      for (final p in TtcPhase.values) {
        final s = HSLColor.fromColor(TtcCycleColours.fill(p)).saturation;
        final coloured =
            p == TtcPhase.period || p == TtcPhase.fertileWindow;
        expect(s > 0.4, coloured,
            reason: '${p.name}: colour only where it means something');
      }
    });

    test('nothing is blue any more', () {
      for (final p in TtcPhase.values) {
        final c = HSLColor.fromColor(TtcCycleColours.fill(p));
        final blue = c.hue > 185 && c.hue < 240 && c.saturation > 0.25;
        expect(blue, isFalse, reason: '${p.name} was blue (hue 206)');
        expect(TtcCycleColours.heroHue(p), isNot(206));
      }
    });

    test('the two colours are full enough to carry white numerals', () {
      expect(contrast(TtcCycleColours.period, Colors.white),
          greaterThanOrEqualTo(3.9));
      expect(contrast(TtcCycleColours.fertile, Colors.white),
          greaterThanOrEqualTo(4.5));
    });

    test('today is ink, never a cycle colour', () {
      for (final p in TtcPhase.values) {
        expect(TtcCycleColours.today, isNot(TtcCycleColours.fill(p)));
      }
      expect(TtcCycleColours.today, ttcTitleInk);
    });

    test('the calendar and the window grade fertile days in one ramp', () {
      for (final l in [
        FertilityLevel.medium,
        FertilityLevel.high,
        FertilityLevel.peak,
      ]) {
        expect(ttcFertilityTint(l), TtcCycleColours.fertileLevel(l));
        final h = HSLColor.fromColor(TtcCycleColours.fertileLevel(l)).hue;
        expect((h - TtcCycleColours.fertileHue).abs(), lessThan(12),
            reason: 'fertile days are violet everywhere, not pink');
      }
    });

    test('no stray colour in the cycle views', () {
      const files = [
        'lib/screens/ttc/ttc_cycle_companion.dart',
        'lib/screens/ttc/ttc_calendar_screen.dart',
        'lib/screens/ttc/ttc_cycle_report_screen.dart',
        'lib/screens/ttc/ttc_cycle_report_states.dart',
        'lib/screens/ttc/ttc_cycle_report_v3.dart',
        'lib/screens/ttc/ttc_window_screen.dart',
      ];
      // The destructive red on "Remove", and the window's tinted shadow.
      const allowed = ['0xFFB3261E', '0xFFF3DEDE', '0xFFD0C8DC'];
      final banned = RegExp(
          r'ttcPurple|ttcCoral|phase\.hue|ttcPhase(Band|Mark|Ink)\(|ttcBrown');
      final hex = RegExp(r'Color\((0x[0-9A-Fa-f]{8})\)');
      for (final f in files) {
        final lines = File(f).readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('//')) continue;
          expect(banned.hasMatch(line), isFalse,
              reason: '$f:${i + 1} uses an old accent: $line');
          for (final m in hex.allMatches(line)) {
            expect(allowed, contains(m.group(1)),
                reason: '$f:${i + 1} types a colour outside the palette');
          }
        }
      }
    });
  });

  // ===========================================================================
  group('the cycle report', () {
    testWidgets('the numbers card has the button it asks for', (tester) async {
      healthy();
      await pumpTall(tester, const TtcCycleReportScreen());
      final card = find.byKey(const ValueKey('ttc_report_numbers_empty'));
      await tester.ensureVisible(card);
      expect(card, findsOneWidget);
      // Kept for revert (2026-09-28, U2): the button used to push the whole
      // logger, scrolled to its foot.
      //   await tester.tap(find.byKey(const ValueKey('ttc_report_add_numbers')));
      //   await tester.pumpAndSettle();
      //   expect(find.byType(TtcSymptomLogScreen), findsOneWidget,
      //       reason: '"add your temperature and weight" had nowhere to go');
      expect(find.byKey(const ValueKey('ttc_report_add_numbers')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_report_add_temp')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('ttc_report_add_weight')), findsOneWidget);
    });

    // U2 (2026-09-28): "let the user add it there only, instead user is
    // taken to symptoms page bottom".
    testWidgets('a temperature is added in place, not in the logger',
        (tester) async {
      healthy();
      await pumpTall(tester, const TtcCycleReportScreen());
      final add = find.byKey(const ValueKey('ttc_report_add_temp'));
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(TtcSymptomLogScreen), findsNothing,
          reason: 'the report must not push the logger any more');
      // The logger's own sheet, over the report.
      expect(find.byKey(const ValueKey('ttc_measure_save')), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_measure_temp_how_to')),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_measure_save')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(
          TtcLogStore.instance
              .valueFor(kTtcTempTracker, kTtcTempField, on: DateTime.now())
              ?.value,
          36.5,
          reason: 'saved to the same store the logger reads');
      expect(find.byType(TtcCycleReportScreen), findsOneWidget);
    });

    testWidgets('a weight is added in place too', (tester) async {
      healthy();
      await pumpTall(tester, const TtcCycleReportScreen());
      final add = find.byKey(const ValueKey('ttc_report_add_weight'));
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(TtcSymptomLogScreen), findsNothing);
      await tester.tap(find.byKey(const ValueKey('ttc_measure_plus')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_measure_save')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(
          TtcLogStore.instance
              .valueFor(kTtcWeightTracker, kTtcWeightField, on: DateTime.now())
              ?.value,
          60.1);
    });

    testWidgets('the chart shows as soon as the second reading is saved',
        (tester) async {
      healthy();
      TtcLogStore.instance.log(kTtcTempTracker, kTtcTempField, 36.4,
          on: ago(1));
      await pumpTall(tester, const TtcCycleReportScreen());
      expect(find.byKey(const ValueKey('ttc_report_numbers_empty')),
          findsOneWidget);
      final add = find.byKey(const ValueKey('ttc_report_add_temp'));
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.byKey(const ValueKey('ttc_measure_save')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('ttc_report_numbers_empty')),
          findsNothing,
          reason: 'the report redraws the moment the sheet saves');
    });

    testWidgets('a cycle paged back comes home in one tap', (tester) async {
      healthy();
      await pumpTall(tester, const TtcCycleReportScreen());
      expect(find.byKey(const ValueKey('ttc_report_back_to_latest')),
          findsNothing);
      await tester.tap(find.byTooltip('Earlier cycle'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byTooltip('Earlier cycle'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byKey(const ValueKey('ttc_report_back_to_latest')));
      // The current part's dot breathes, so this never settles.
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('This cycle'), findsWidgets);
      expect(find.byKey(const ValueKey('ttc_report_back_to_latest')),
          findsNothing);
    });

    testWidgets('the days before the fertile days are named plainly',
        (tester) async {
      // Day 3 of a 28-day cycle sits in the period; day 8 before the window.
      CycleStore.instance
        ..logPeriodStart(ago(63))
        ..logPeriodStart(ago(35))
        ..logPeriodStart(ago(7));
      await pumpTall(tester, const TtcCycleReportScreen());
      expect(find.text("You're before your fertile window"), findsNothing);
    });
  });

  // ===========================================================================
  group('the Cycle companion', () {
    testWidgets('first open: one way to add a date', (tester) async {
      await pumpTall(tester, const TtcCycleCompanionScreen());
      expect(find.text('Add a period date'), findsOneWidget);
      await tester.tap(find.text('Add a period date'));
      await tester.pumpAndSettle();
      expect(find.text('When did it start?'), findsOneWidget);
    });

    testWidgets('adding says it saved', (tester) async {
      await pumpTall(
        tester,
        Scaffold(
          body: Builder(
            builder: (c) => TextButton(
              onPressed: () => showTtcPeriodLogSheet(c, initial: ago(3)),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save this period'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(CycleStore.instance.periodStarts, contains(ago(3)));
      expect(find.text('Period saved: started ${ttcShortDate(ago(3))}'),
          findsOneWidget);
    });

    testWidgets('a date opens its facts, then change or remove with Undo',
        (tester) async {
      healthy();
      CycleStore.instance.logBleedDays(ago(40), 5);
      await pumpTall(tester, const TtcCycleCompanionScreen());
      final edit = find.byKey(
        ValueKey('ttc_period_row_edit_${ago(40).toIso8601String()}'),
      );
      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      final facts = tester.widget<Text>(
          find.byKey(const ValueKey('ttc_period_action_facts')));
      expect(facts.data, contains('5 bleeding days'));
      expect(facts.data, contains('28-day cycle'));

      // Change opens the date sheet, replacing the menu, not stacking on it.
      await tester.tap(find.byKey(const ValueKey('ttc_period_action_change')));
      await tester.pumpAndSettle();
      expect(find.text('When did it really start?'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_period_action_facts')),
          findsNothing);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_period_action_remove')));
      await tester.pumpAndSettle();
      expect(CycleStore.instance.periodStarts, isNot(contains(ago(40))));
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(CycleStore.instance.periodStarts, contains(ago(40)));
      expect(CycleStore.instance.bleedDaysFor(ago(40)), 5,
          reason: 'Undo brings back what hung off the date');
    });

    testWidgets('"Add a date" is a pill she can hit', (tester) async {
      healthy();
      await pumpTall(tester, const TtcCycleCompanionScreen());
      final add = find.byKey(const ValueKey('ttc_companion_add_date'));
      await tester.ensureVisible(add);
      expect(tester.getSize(add).height, greaterThanOrEqualTo(36));
      await tester.tap(add);
      await tester.pumpAndSettle();
      expect(find.text('When did it start?'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the calendar', () {
    testWidgets('a bleeding day opens its period, and it can be removed',
        (tester) async {
      healthy();
      CycleStore.instance
        ..logPeriodStart(ago(2))
        ..logBleedDays(ago(2), 5);
      await pumpTall(tester, const TtcCalendarScreen());
      // Today is day three of that period: never "Log a period" inside it.
      expect(ttcCalendarPeriodOwning(ago(0)), ago(2));
      expect(find.text(kTtcCalendarLogPeriod), findsNothing);
      await tester.ensureVisible(find.text(kTtcCalendarChangePeriod));
      await tester.tap(find.text(kTtcCalendarChangePeriod));
      await tester.pumpAndSettle();
      expect(find.text('Started ${ttcLongDate(ago(2))}'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_period_action_remove')));
      await tester.pumpAndSettle();
      expect(CycleStore.instance.periodStarts, isNot(contains(ago(2))));
    });

    testWidgets('an appointment on the day opens its page', (tester) async {
      final now = DateTime.now();
      final a = TtcAppointmentsStore.instance.add(
        title: 'Follicle scan',
        startsLocal: DateTime(now.year, now.month, now.day, 23, 30),
      );
      await pumpTall(tester, const TtcCalendarScreen());
      final line = find.byKey(ValueKey('ttc_cal_appt_${a.id}'));
      await tester.ensureVisible(line);
      await tester.tap(line);
      await tester.pumpAndSettle();
      expect(find.byType(TtcAppointmentScreen), findsOneWidget);
    });

    test('a quiet day has no period to open', () {
      healthy();
      expect(ttcCalendarPeriodOwning(ago(20)), isNull);
    });
  });

  // ===========================================================================
  group('360dp', () {
    for (final (name, screen) in [
      ('companion', const TtcCycleCompanionScreen()),
      ('calendar', const TtcCalendarScreen()),
      ('report', const TtcCycleReportScreen()),
    ]) {
      testWidgets('$name lays out with a history', (tester) async {
        healthy();
        await pumpTall(tester, screen, width: 360);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
