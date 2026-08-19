// =============================================================================
//  The scan journey — the four promises a screen makes and then has to keep
// -----------------------------------------------------------------------------
//  Every test here guards a defect of the same SHAPE, and it is the shape
//  CLAUDE.md's wiring gate is about: the app tells the mother what is about to
//  happen, and then does something slightly different. None of these fail to
//  compile. None of them fail an existing test. The only place the symptom
//  surfaces is on her phone.
//
//    · the timeline says one scan is next          -> exactly one, and the right one
//    · a card names the report she is holding      -> that filter arrives pre-applied
//    · a card names a gynaecologist                -> the gynaecologist is who she gets
//    · a card promises the parameter table         -> nothing else is above it
//
//  ⚠️ THREE OF THE FOUR ARE ABOUT A PARAMETER THAT ALREADY EXISTED AND WAS NOT
//  PASSED. `ConsultationsScreen.onlyRole` had shipped, documented, with three
//  call sites using it correctly — and the scans card, which is the one whose
//  copy names an expert out loud, was not one of them. That is why these are
//  reachability tests rather than unit tests: the logic was never wrong, the
//  join was missing, and a test of the logic alone would have passed throughout.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/prepare_data.dart';
import 'package:parentveda/data/tests_scans_reports_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/brackets/scan_detail_screen.dart';
import 'package:parentveda/screens/brackets/scan_timeline_screen.dart';
import 'package:parentveda/screens/prepare/consultations_screen.dart';
import 'package:parentveda/screens/report_screen.dart';
import 'package:parentveda/screens/tools/tests_scans_reports_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/scans_store.dart';

/// A controller sitting at roughly [week], via the due date rather than a
/// setter — `currentWeek` is derived, and driving it any other way would be
/// testing a path the app does not use.
PregnancyController _at(int week) {
  final now = DateTime(2026, 1, 1);
  return PregnancyController(
    now: now,
    dueDate: now.add(Duration(days: (40 - week) * 7)),
  );
}

Future<void> _pump(WidgetTester t, Widget w) async {
  // Tall on purpose: these screens are long lists, and `findsOneWidget` on an
  // unbuilt off-screen row would fail for a reason that has nothing to do with
  // what is being asserted.
  t.view.physicalSize = const Size(1200, 6000);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

TestScanInfo _scan(String id) => kTestsScans.firstWhere((s) => s.id == id);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // ===========================================================================
  //  1 · The timeline points at exactly one scan
  // ===========================================================================

  group('the timeline marks one next scan, and it is the right one', () {
    testWidgets('exactly one NEXT UP, however long the run is', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, ScanTimelineScreen(pregnancy: c));

      // ⚠️ THE COUNT IS THE ASSERTION, not merely that one exists. The state
      // this replaced ("her week falls inside this scan's window") could mark
      // two rows at once — growth_scan spans 28–36 and doppler 30–40, so for
      // eight weeks the timeline had two answers to a question that has one.
      expect(find.text('NEXT UP'), findsOneWidget);
    });

    testWidgets('at week 30, where two windows overlap, still exactly one',
        (t) async {
      final c = _at(30);
      addTearDown(c.dispose);
      await _pump(t, ScanTimelineScreen(pregnancy: c));
      expect(find.text('NEXT UP'), findsOneWidget);
    });

    testWidgets('the three states are legible without reading the dots',
        (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, ScanTimelineScreen(pregnancy: c));

      // The legend is what turns a filled dot from "different" into "done".
      // Without it the visual states are a puzzle rather than an answer, which
      // is the whole thing the review asked to fix.
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
    });

    testWidgets('a scan whose window has gone by says "not marked", never '
        '"missed"', (t) async {
      // Week 39: every window except doppler (30–40) and gbs (35–37) is behind
      // her, and none are marked done.
      final c = _at(39);
      addTearDown(c.dispose);
      await _pump(t, ScanTimelineScreen(pregnancy: c));

      expect(find.text('Not marked as done'), findsWidgets);

      // ⚠️ THE WORD THAT MUST NOT APPEAR. We know only that nothing was
      // logged — not that she skipped anything — and "missed" turns a gap in
      // our own record into an accusation aimed at her. It would also be
      // wrong for every mother who had the scan and never opened this screen.
      expect(
          find.byWidgetPredicate((w) =>
              w is Text &&
              (w.data ?? '').toLowerCase().contains('missed')),
          findsNothing);
    });
  });

  // ===========================================================================
  //  2 · The decoder opens on the report she is holding
  // ===========================================================================

  group('the report decoder arrives pre-filtered', () {
    testWidgets('the scan she came from is the selected chip', (t) async {
      final c = _at(12);
      addTearDown(c.dispose);
      await _pump(
          t, ReportScreen(controller: c, initialReport: 'dating_scan'));

      // The heading swaps once a filter is on. Its presence is how we know the
      // filter was applied and not merely accepted and dropped.
      expect(find.text('Topics on these reports'), findsOneWidget);
      expect(find.text('All topics'), findsNothing);
    });

    testWidgets('every other report is still one tap away', (t) async {
      final c = _at(12);
      addTearDown(c.dispose);
      await _pump(
          t, ReportScreen(controller: c, initialReport: 'dating_scan'));

      // ⚠️ A FILTER, NOT A MODE. Pre-selecting saves her a tap; it must never
      // cost her a choice. "All" and the other eight reports stay on screen,
      // which is the same personalisation line the rest of the app holds —
      // order and emphasis may change, structure may not.
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Anomaly scan'), findsOneWidget);
      expect(find.text('NIPT'), findsOneWidget);
    });

    testWidgets('an id this screen cannot filter by shows everything',
        (t) async {
      final c = _at(12);
      addTearDown(c.dispose);
      // `gdm` is a CONDITION, not a report — a real id, and not one of the
      // nine. It must degrade to the full library rather than to an empty one.
      await _pump(t, ReportScreen(controller: c, initialReport: 'gdm'));

      expect(canFilterReport('gdm'), isFalse);
      expect(find.text('All topics'), findsOneWidget);
    });

    test('every scan in the run either filters, or is known not to', () {
      // ⚠️ THIS IS THE TEST THAT AGES WELL. A tenth scan added to `kScanRun`
      // with no matching report filter would silently start handing the
      // decoder an id it cannot use — the card would still open, she would
      // still see topics, and nothing would say the promise was dropped.
      const knownUnfilterable = <String>{};
      for (final (id, _, _) in kScanRun) {
        if (knownUnfilterable.contains(id)) continue;
        expect(canFilterReport(id), isTrue,
            reason: '$id is on the timeline but the decoder cannot filter by '
                'it — add a filter, or add it to knownUnfilterable with a '
                'reason.');
      }
    });
  });

  // ===========================================================================
  //  3 · The card names an expert, so the list opens on that expert
  // ===========================================================================

  group('the consult card keeps its word', () {
    test('the promised role exists', () {
      // A typo'd id fails soft — `onlyRole` falls back to everyone — so the id
      // itself has to be checked somewhere or the fallback hides the bug.
      expect(kSpecialists.any((s) => s.id == kScanConsultRole), isTrue);
    });

    testWidgets('only the gynaecologist is listed, and there is a way back out',
        (t) async {
      await _pump(
          t,
          const ConsultationsScreen(
              lang: AppLanguage.english, onlyRole: kScanConsultRole));

      final ob = kSpecialists.firstWhere((s) => s.id == kScanConsultRole);
      expect(find.text(ob.role.en), findsOneWidget);

      // Everyone else is off this view...
      for (final s in kSpecialists.where((x) => x.id != kScanConsultRole)) {
        expect(find.text(s.role.en), findsNothing, reason: s.id);
      }
      // ...and reachable, which is what stops a filter from being a wall.
      expect(find.text('See all experts'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  4 · "Your report, line by line" starts at the parameters
  // ===========================================================================

  group('the parameter arrival has nothing above it', () {
    testWidgets('the five preparation sections do not render', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(
          t,
          TestScanDetailScreen(
              info: _scan('anomaly_scan'),
              controller: c,
              openParameters: true));

      // ⚠️ NOT RENDERED, NOT MERELY COLLAPSED — and the difference is the
      // whole point of the second review pass. Collapsed still makes her
      // scroll past five rows about a day that has already happened to reach
      // the paper in her hand.
      final s = S(AppLanguage.english);
      for (final title in [
        s.uiWhat,
        s.uiWhySDone,
        s.uiWhen,
        s.uiPreparation,
        s.uiProcedure,
      ]) {
        expect(find.text(title), findsNothing, reason: title);
      }
    });

    testWidgets('the parameters section is there and open', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      final scan = _scan('anomaly_scan');
      await _pump(
          t,
          TestScanDetailScreen(
              info: scan, controller: c, openParameters: true));

      expect(find.text(S(AppLanguage.english).uiUnderstandingReportParameters),
          findsOneWidget);
      // Open, not just present: a parameter's name is only in the tree once
      // the section has expanded.
      if (scan.parameters.isNotEmpty) {
        expect(find.text(scan.parameters.first.name.en), findsOneWidget);
      }
    });

    testWidgets('the Tools-tab arrival is untouched', (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(
          t,
          TestScanDetailScreen(
              info: _scan('anomaly_scan'), controller: c));

      // ⚠️ THE OTHER HALF OF THE DECISION. Someone arriving before a scan
      // wants exactly those five sections. Removing them for her too would
      // have been the easy reading of the review and the wrong one — one
      // screen, two arrivals, and only one of them changed.
      final s = S(AppLanguage.english);
      expect(find.text(s.uiWhat), findsOneWidget);
      expect(find.text(s.uiPreparation), findsOneWidget);
      expect(find.text(s.uiProcedure), findsOneWidget);
    });
  });

  // ===========================================================================
  //  5 · The safety block invites a call rather than setting a deadline
  // ===========================================================================

  group('the red-flag heading names a person, not a deadline', () {
    testWidgets('it says who to call, and the old deadline framing is gone',
        (t) async {
      final c = _at(9);
      addTearDown(c.dispose);
      ScansStore.instance; // touch the singleton the screen listens to
      await _pump(
          t, ScanDetailScreen(scan: _scan('dating_scan'), pregnancy: c));

      expect(find.text('Call your gynaecologist if'), findsOneWidget);

      // ⚠️ "BEFORE YOUR NEXT APPOINTMENT" WAS THE PROBLEM, not the symptoms
      // under it. It framed the block as a countdown, which reads as *this is
      // already going wrong* — the opposite of what a safety net is for.
      expect(find.text('Call before your next appointment if'), findsNothing);
    });

    testWidgets('the symptoms themselves are unchanged', (t) async {
      final c = _at(9);
      addTearDown(c.dispose);
      await _pump(
          t, ScanDetailScreen(scan: _scan('dating_scan'), pregnancy: c));

      // ⚠️ SOFTENING THE FRAME IS RIGHT; SOFTENING A RED FLAG IS NOT. This is
      // the line the next person to "make it calmer" must not cross, so it is
      // pinned rather than left to judgement.
      expect(
          find.byWidgetPredicate((w) =>
              w is Text && (w.data ?? '').contains('Bleeding, or pain low')),
          findsOneWidget);
    });
  });
}
