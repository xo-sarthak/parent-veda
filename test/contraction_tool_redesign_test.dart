// =============================================================================
//  The contraction timer, redrawn around one control (2026-10-02).
//
//  The user: "the contraction timer tool seems very text heavy; run Mobbin and
//  figure out a good UI, UX and functionality for it."
//
//  What this holds, on the real screen:
//    · the DISC is the timer and the button, in all three phases, and nothing
//      else is pinned to the bottom;
//    · the paragraphs are FOLDED: the line that says what this is stays, its
//      body and "Understanding contractions" open on a tap;
//    · a calm reading is ONE LINE that opens its wording, and an URGENT one is
//      still the whole card, never folded (red stays where it means NOW);
//    · the table became two small charts, and the table is one tap away;
//    · and the clinical engine is untouched: its outputs are checked as they
//      were, so the redraw cannot have moved a reading.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/tools/contraction_tracker_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/tools_store.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

Contraction _c(int start, int dur, int interval) => Contraction(
      startIso: DateTime(2026, 10, 2, 3, 0).add(Duration(seconds: start)).toIso8601String(),
      endIso: DateTime(2026, 10, 2, 3, 0).add(Duration(seconds: start + dur)).toIso8601String(),
      durationSeconds: dur,
      intervalSeconds: interval,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController c;
  late S s;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 20)));
    await c.load();
    s = S(c.language);
  });

  Future<void> pump(WidgetTester t, {double scale = 1.0}) async {
    t.view.physicalSize = const Size(900, 2600);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: ContractionTrackerScreen(controller: c),
    ));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
  }

  /// Dispose the screen so its one-second timer does not outlive the test.
  Future<void> done(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump();
  }

  group('home', () {
    testWidgets('one disc to start, and nothing pinned under it', (t) async {
      await pump(t);
      expect(find.byKey(const ValueKey('ct_disc_home')), findsOneWidget);
      // The start words are in the disc once, not also on a bar.
      expect(find.text(s.contractionStartedCta), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(t.takeException(), isNull);
      await done(t);
    });

    testWidgets('the safety line stays; its body and the explainer are folded',
        (t) async {
      await pump(t);
      // Always on the page.
      expect(find.text(s.ctDisclaimerTitle), findsOneWidget);
      expect(find.text(s.ctAboutTitle), findsOneWidget);
      // Folded.
      expect(find.text(s.ctDisclaimerBody), findsNothing);
      expect(find.text(s.ctAboutBody), findsNothing);
      // One tap opens each.
      await t.ensureVisible(find.byKey(const ValueKey('ct_fold_toggle_disclaimer')));
      await t.tap(find.byKey(const ValueKey('ct_fold_toggle_disclaimer')));
      await t.pumpAndSettle();
      expect(find.text(s.ctDisclaimerBody), findsOneWidget);
      await t.ensureVisible(find.byKey(const ValueKey('ct_fold_toggle_about')));
      await t.tap(find.byKey(const ValueKey('ct_fold_toggle_about')));
      await t.pumpAndSettle();
      expect(find.text(s.ctAboutBody), findsOneWidget);
      await done(t);
    });

    testWidgets('the quick safety check is still on the page', (t) async {
      await pump(t);
      expect(find.text(s.safetyCheckTitle), findsOneWidget);
      expect(find.text(s.safetyUpdate), findsOneWidget);
      await done(t);
    });

    testWidgets('holds at 1.5x text', (t) async {
      await pump(t, scale: 1.5);
      expect(t.takeException(), isNull);
      await done(t);
    });
  });

  group('live', () {
    testWidgets('start: the disc counts and its caption names the contraction',
        (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('ct_disc_home')));
      await t.pump();
      expect(find.byKey(const ValueKey('ct_disc_active')), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.text(s.contractionEndedCta), findsOneWidget);
      expect(find.text(s.contractionNumber(1)), findsOneWidget);
      // While a contraction runs there is no chart, table or paragraph.
      expect(find.byKey(const ValueKey('ct_charts')), findsNothing);
      expect(find.byKey(const ValueKey('ct_assess_chip')), findsNothing);
      expect(t.takeException(), isNull);
      await done(t);
    });

    testWidgets('end: it rests, counts the gap, and shows the glance',
        (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('ct_disc_home')));
      await t.pump(const Duration(seconds: 3));
      await t.tap(find.byKey(const ValueKey('ct_disc_active')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const ValueKey('ct_disc_rest')), findsOneWidget);
      expect(find.text(s.timeSinceLast), findsOneWidget);
      expect(find.byKey(const ValueKey('ct_charts')), findsOneWidget);
      expect(find.byKey(const ValueKey('ct_chart_duration')), findsOneWidget);
      // The table is folded, one tap away, with the count.
      expect(find.byKey(const ValueKey('ct_fold_session')), findsOneWidget);
      expect(find.text(s.timeColumn), findsNothing);
      await t.ensureVisible(find.byKey(const ValueKey('ct_fold_toggle_session')));
      await t.tap(find.byKey(const ValueKey('ct_fold_toggle_session')));
      await t.pumpAndSettle();
      expect(find.text(s.timeColumn), findsOneWidget);
      expect(t.takeException(), isNull);
      await done(t);
    });

    testWidgets('a calm reading is one line that opens its wording', (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('ct_disc_home')));
      await t.pump(const Duration(seconds: 1));
      await t.tap(find.byKey(const ValueKey('ct_disc_active')));
      await t.pump(const Duration(milliseconds: 300));
      final chip = find.byKey(const ValueKey('ct_assess_chip'));
      expect(chip, findsOneWidget);
      expect(find.text(s.assessTitle('insufficient')), findsOneWidget);
      // The full summary is not on the page until she opens it.
      expect(find.text(s.assessSummary('insufficient')), findsNothing);
      await t.tap(chip);
      await t.pumpAndSettle();
      expect(find.text(s.assessSummary('insufficient')), findsOneWidget);
      // The line that always points to her doctor is in the wording.
      expect(find.text(s.ctAlwaysConsult), findsOneWidget);
      await done(t);
    });

    testWidgets('three contractions offer the summary', (t) async {
      await pump(t);
      for (var i = 0; i < 3; i++) {
        await t.tap(find.byKey(const ValueKey('ct_disc_home')).evaluate().isNotEmpty
            ? find.byKey(const ValueKey('ct_disc_home'))
            : find.byKey(const ValueKey('ct_disc_rest')));
        await t.pump(const Duration(seconds: 1));
        await t.tap(find.byKey(const ValueKey('ct_disc_active')));
        await t.pump(const Duration(milliseconds: 300));
      }
      await t.ensureVisible(find.text(s.viewSummaryCta));
      expect(find.text(s.viewSummaryCta), findsOneWidget);
      await t.tap(find.text(s.viewSummaryCta));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('ct_summary_charts')), findsOneWidget);
      await done(t);
    });

    testWidgets('holds at 1.5x text while resting', (t) async {
      await pump(t, scale: 1.5);
      await t.tap(find.byKey(const ValueKey('ct_disc_home')));
      await t.pump(const Duration(seconds: 1));
      await t.tap(find.byKey(const ValueKey('ct_disc_active')));
      await t.pump(const Duration(milliseconds: 300));
      expect(t.takeException(), isNull);
      await done(t);
    });
  });

  group('an urgent reading is never folded', () {
    testWidgets('after a symptom is reported, the whole red card is on the page',
        (t) async {
      await pump(t);
      await t.ensureVisible(find.text(s.safetyUpdate));
      await t.tap(find.text(s.safetyUpdate));
      await t.pumpAndSettle();
      // "Has your water broken?" Yes: the first "Yes" in the sheet.
      await t.tap(find.text(s.optYes).first);
      await t.pump();
      await t.tap(find.text(s.doneWord));
      await t.pumpAndSettle();
      expect(find.text(s.assessTitle('emergency')), findsOneWidget);
      expect(find.text(s.assessSummary('emergency')), findsOneWidget,
          reason: 'the urgent wording must be on the page, not behind a tap');
      expect(find.byKey(const ValueKey('ct_assess_chip')), findsNothing);
      await done(t);
    });
  });

  group('the engine is untouched', () {
    test('the same readings as before', () {
      // Fewer than three: not enough to read.
      expect(classifyContractions([_c(0, 40, 0), _c(400, 40, 400)]),
          LaborState.insufficient);
      // Three short, far apart: no clear pattern.
      expect(
          classifyContractions(
              [_c(0, 25, 0), _c(1200, 25, 1200), _c(2400, 25, 1200)]),
          LaborState.noPattern);
      // Eight long, close and even over a while: active labour likely.
      final steady = [
        for (var i = 0; i < 8; i++) _c(i * 280, 70, i == 0 ? 0 : 280),
      ];
      expect(classifyContractions(steady), LaborState.activeLabor);
      // Before 37 weeks a labour-like pattern is "preterm", not "active".
      expect(assessContractions(steady, 34, const ContractionSymptoms()),
          AssessLevel.preterm);
      expect(assessContractions(steady, 39, const ContractionSymptoms()),
          AssessLevel.activeLabor);
      // A reported symptom overrides everything.
      expect(
          assessContractions(
              steady, 39, const ContractionSymptoms(waterBroken: 'yes')),
          AssessLevel.emergency);
    });
  });

  group('wiring', () {
    test('the live build uses the disc and the folds, and the old views are '
        'kept but not built', () {
      final live = _code('lib/screens/tools/contraction_tracker_screen.dart');
      expect(live, contains('_homeViewV2(context)'));
      expect(live, contains('_liveView(context)'));
      expect(live, contains('_TimerDisc('));
      expect(live, contains('_FoldRow('));
      // Defined once, never called: kept for revert.
      for (final old in ['_homeView(', '_activeView(', '_restView(']) {
        expect(RegExp(RegExp.escape(old)).allMatches(live).length, 1,
            reason: '$old is built again');
      }
    });
  });
}
