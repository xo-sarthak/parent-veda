// =============================================================================
//  TTC tools pass, trackers and logging (2026-09-27)
// -----------------------------------------------------------------------------
//  Holds the behaviour the pass added to the calendar, the Cycle companion,
//  the symptom logger, the cycle report and the tracker screen, from
//  docs/TTC-TOOLS-UX-NOTES.md ("Trackers: cycle, symptoms, reports, records")
//  and the simplicity addendum: say what the screen is first, a button does
//  what it says, and a tap is seen to save.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_calendar_screen.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_companion.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_report_screen.dart';
import 'package:parentveda/screens/ttc/ttc_mood_face.dart';
import 'package:parentveda/screens/ttc/ttc_symptom_log_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tracker_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_cycle_report.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';
import 'package:parentveda/ttc/ttc_trackers_data.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
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
  group('calendar', () {
    testWidgets('with no period it says how to fill it, and the button does', (
      tester,
    ) async {
      await pumpTall(tester, const TtcCalendarScreen());
      expect(find.text(kTtcCalendarIntroEmpty), findsOneWidget);
      await tester.tap(find.text(kTtcCalendarAddPeriod));
      await tester.pumpAndSettle();
      expect(
        find.text('When did your period start?' /* was 'When did it start?' */),
        findsOneWidget,
        reason: 'the empty calendar was a dead end with no way to fill it',
      );
    });

    testWidgets('with a history it says what the marks mean', (tester) async {
      healthy();
      await pumpTall(tester, const TtcCalendarScreen());
      expect(find.text(kTtcCalendarIntro), findsOneWidget);
      expect(find.text(kTtcCalendarAddPeriod), findsNothing);
    });

    testWidgets('the expected period says "Due" on the day itself', (
      tester,
    ) async {
      healthy();
      await pumpTall(tester, const TtcCalendarScreen());
      // The next period may fall in next month; look there if not here.
      if (find.byKey(const ValueKey('ttc_cal_due_mark')).evaluate().isEmpty) {
        await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(find.byKey(const ValueKey('ttc_cal_due_mark')), findsOneWidget);
    });

    test('the trigger injection carries its time', () {
      final on = DateTime.now().add(const Duration(days: 3));
      TtcTreatmentStore.instance.setDate(
        TtcTreatmentStep.trigger,
        DateTime(on.year, on.month, on.day, 22, 15),
      );
      final lines = ttcCalendarClinicLines(on);
      expect(
        lines.any((l) => l.contains('10:15pm')),
        isTrue,
        reason: 'the hour is the part of a trigger that matters',
      );
    });

    test('the day card names what she logged, not a retired screen', () {
      expect(
        ttcCalendarLoggedLine('symptoms', false),
        isNot(contains('Companion')),
      );
    });
  });

  // ===========================================================================
  group('Cycle companion', () {
    testWidgets('a date row opens change and remove on a tap', (tester) async {
      healthy();
      await pumpTall(tester, const TtcCycleCompanionScreen());
      final edit = find.byKey(
        ValueKey('ttc_period_row_edit_${ago(40).toIso8601String()}'),
      );
      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(find.text('Change this date'), findsOneWidget);
      await tester.tap(find.text('Remove this date'));
      await tester.pumpAndSettle();
      expect(CycleStore.instance.periodStarts, isNot(contains(ago(40))));
      // Remove is offered straight back.
      // The house notice's "Undo" pill since 2026-09-27 (was the dark
      // snackbar's 'UNDO').
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(CycleStore.instance.periodStarts, contains(ago(40)));
    });

    testWidgets('the four parts are named once, in plain words', (
      tester,
    ) async {
      healthy();
      await pumpTall(tester, const TtcCycleCompanionScreen());
      expect(find.text(kTtcFourPartsLine), findsOneWidget);
      expect(find.text(kTtcCirclePicture), findsOneWidget);
    });

    testWidgets('the log sheet opens on a day handed to it', (tester) async {
      await pumpTall(
        tester,
        Builder(
          builder: (c) => TextButton(
            onPressed: () => showTtcPeriodLogSheet(c, initial: ago(3)),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save this period'));
      await tester.pumpAndSettle();
      expect(CycleStore.instance.periodStarts, contains(ago(3)));
    });
  });

  // ===========================================================================
  group('symptom log', () {
    testWidgets('a tap is seen to save', (tester) async {
      await pumpTall(tester, const TtcSymptomLogScreen());
      // 2026-09-28: no "Nothing saved" line at the top any more; the count
      // is a pill in the hero once something is saved. Was:
      //   expect(find.text(ttcLogSavedLine(0)), findsOneWidget);
      expect(find.text(ttcLogSavedLine(0)), findsNothing);
      expect(find.text(kTtcLogHowItWorks), findsOneWidget);
      await tester.tap(find.text('Calm'));
      await tester.pump();
      // Was: expect(find.text(ttcLogSavedLine(1)), findsOneWidget);
      expect(find.text(ttcLogSavedPill(1)), findsOneWidget);
    });

    test('search finds the words she would type', () {
      TtcSymptom byId(String id) => kTtcSymptomGroups
          .expand((g) => g.symptoms)
          .firstWhere((s) => s.id == id);
      TtcSymptomGroup groupOf(String id) => kTtcSymptomGroups.firstWhere(
        (g) => g.symptoms.any((s) => s.id == id),
      );
      bool finds(String id, String q) =>
          ttcLogSearchMatches(groupOf(id), byId(id), q);
      expect(finds('insomnia', 'could not sleep'), isTrue);
      expect(finds('insomnia', 'sleep'), isTrue);
      expect(finds('cramping', 'cramps'), isTrue);
      expect(finds('disch_eggwhite', 'mucus'), isTrue);
      expect(finds('ov_positive', 'LH'), isTrue);
      expect(ttcLogNumberHint('BBT'), isNotNull);
    });

    testWidgets('the feelings can be searched', (tester) async {
      await pumpTall(tester, const TtcSymptomLogScreen());
      await tester.enterText(find.byType(TextField).first, 'worried');
      await tester.pump();
      expect(find.text('Anxious'), findsOneWidget);
    });

    testWidgets('a weight can be typed, not only scrolled', (tester) async {
      await pumpTall(tester, const TtcSymptomLogScreen());
      await tester.tap(find.text('Weight').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_measure_number')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('ttc_measure_type_field')),
        '68.4',
      );
      // The sheet's button says Save since the tool rebuild (2026-09-27);
      // "Done" is now the logger's own way out. Was:
      //   await tester.tap(find.text('Done'));
      await tester.tap(find.byKey(const ValueKey('ttc_measure_save')));
      await tester.pumpAndSettle();
      expect(
        TtcLogStore.instance
            .valueFor(kTtcWeightTracker, kTtcWeightField)
            ?.value,
        68.4,
      );
    });

    testWidgets('the temperature card says how to take it', (tester) async {
      await pumpTall(tester, const TtcSymptomLogScreen());
      expect(
        find.byKey(const ValueKey('ttc_temp_how_to'), skipOffstage: false),
        findsOneWidget,
      );
    });
  });

  // ===========================================================================
  group('cycle report', () {
    test('the picker says which cycle, and of how many', () {
      expect(ttcWhichCycle(0, 1), 'This cycle');
      expect(ttcWhichCycle(0, 3), 'This cycle · 3 of 3');
      expect(ttcWhichCycle(1, 3), 'Last cycle · 2 of 3');
      expect(ttcWhichCycle(2, 3), '2 cycles back · 1 of 3');
    });

    testWidgets('the i opens the same panel on a drawn cycle', (tester) async {
      healthy();
      await pumpTall(tester, const TtcCycleReportScreen());
      expect(find.byKey(const ValueKey('ttc_report_about')), findsNothing);
      await tester.tap(find.byIcon(Icons.info_outline_rounded).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('ttc_report_about')), findsOneWidget);
    });
  });

  // ===========================================================================
  group('tracker screen', () {
    testWidgets('a preset writes the usual value in one tap', (tester) async {
      await pumpTall(
        tester,
        TtcTrackerScreen(tracker: ttcTrackerById('habits')!),
      );
      await tester.tap(find.byKey(const ValueKey('ttc_preset_hours_7')));
      await tester.pump();
      expect(TtcLogStore.instance.valueFor('habits', 'hours')?.value, 7);
      expect(find.text(kTtcTrackerSaved), findsWidgets);
    });

    testWidgets('each heading appears once', (tester) async {
      await pumpTall(
        tester,
        TtcTrackerScreen(tracker: ttcTrackerById('habits')!),
      );
      // The group is a card with its name now (2026-10-02). Kept for revert:
      // the grey capitals 'SLEEP' and 'CUTTING DOWN'.
      expect(
        find.text('Sleep'),
        findsOneWidget,
        reason: '"In bed by about eleven" opened a second Sleep heading',
      );
      expect(find.text('Cutting down'), findsOneWidget);
    });

    testWidgets('his tracker says who fills it in', (tester) async {
      await pumpTall(
        tester,
        TtcTrackerScreen(tracker: ttcTrackerById('partner_health')!),
      );
      expect(find.text(kTtcTrackerPartnerWho), findsOneWidget);
    });
  });

  // ===========================================================================
  testWidgets('a mood face has a word for a screen reader', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: TtcMoodFace(mood: TtcMood.calm, size: 24, ink: Colors.black),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Calm'), findsOneWidget);
    handle.dispose();
  });
}
