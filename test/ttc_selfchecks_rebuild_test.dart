// =============================================================================
//  The four self-checks, rebuilt (2026-09-27): Weight and fertility (BMI),
//  PCOS symptom check, See a specialist?, Pre-pregnancy checklist
// -----------------------------------------------------------------------------
//  One test per defect a first-time user hit, each named for what she saw:
//    * BMI: a saved measurement could never be seen, checked or removed, and
//      the change note compared a number with itself the moment she saved it
//    * PCOS and See a specialist?: every visit was a blank form, so seeing a
//      result again meant answering everything again
//    * See a specialist?: "pick as many as apply" looked like single choice,
//      and a skipped question told a doctor "Nothing so far"
//    * the notes pages could only be screenshotted
//    * the checklist needed two taps and a scroll to mark one item done, and a
//      next step without a tool was a dead card
//  All at 360dp, the narrowest phone the app is walked on.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_bmi_screen.dart';
import 'package:parentveda/screens/ttc/ttc_ivf_readiness_screen.dart';
import 'package:parentveda/screens/ttc/ttc_pcos_stand_screen.dart';
import 'package:parentveda/screens/ttc/ttc_precheck_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_bmi_rules.dart';
import 'package:parentveda/ttc/ttc_bmi_store.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_ivf_readiness.dart';
import 'package:parentveda/ttc/ttc_pcos_stand.dart';
import 'package:parentveda/ttc/ttc_precheck_data.dart';
import 'package:parentveda/ttc/ttc_precheck_rules.dart';
import 'package:parentveda/ttc/ttc_precheck_store.dart';
import 'package:parentveda/ttc/ttc_selfcheck_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {double height = 5000}) async {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'overflow at 360dp');
}

/// Taps the widget found, scrolling it into view first.
Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

FontWeight? _weightOf(WidgetTester tester, Finder label) => tester
    .widget<AnimatedDefaultTextStyle>(find
        .ancestor(of: label, matching: find.byType(AnimatedDefaultTextStyle))
        .first)
    .style
    .fontWeight;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String? clipboard;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcSelfCheckStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    await TtcBmiStore.instance.load();
    await TtcBmiStore.instance.clearHistory();
    await TtcBmiStore.instance.setUnits(
        height: BmiHeightUnit.cm, weight: BmiWeightUnit.kg);
    await TtcPrecheckStore.instance.load();
    await TtcPrecheckStore.instance.reset();
    await TtcFertilityHelpStore.instance.reset();
    clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = (call.arguments as Map)['text'] as String?;
      }
      return null;
    });
  });

  // ===========================================================================
  group('Weight and fertility', () {
    Future<void> calculate(WidgetTester tester, String cm, String kg) async {
      await tester.enterText(find.byType(TextField).at(0), cm);
      await tester.enterText(find.byType(TextField).at(1), kg);
      // .last: with a saved one, the last-check card has its own button.
      await _tap(tester, find.text('See my result').last);
    }

    testWidgets('first open: the fields, no last check', (tester) async {
      await _pump(tester, const TtcBmiScreen());
      expect(find.text('Work out your BMI.'), findsOneWidget);
      expect(find.byType(TtcToolLastCheck), findsNothing);
    });

    testWidgets('a result says what it was worked out from, and saves to a '
        'list she can see', (tester) async {
      await _pump(tester, const TtcBmiScreen());
      await calculate(tester, '160', '55');
      expect(find.text('From 160 cm and 55.0 kg.'), findsOneWidget);
      expect(find.text('Your saved measurements'), findsNothing,
          reason: 'nothing saved yet');
      await _tap(tester, find.byKey(const ValueKey('ttc_bmi_save')));
      expect(TtcBmiStore.instance.history.length, 1);
      expect(find.text('Your saved measurements'), findsOneWidget);
      expect(find.text('BMI 21.5 · 55.0 kg'), findsOneWidget);
    });

    testWidgets('coming back: the last check card opens the saved result',
        (tester) async {
      await TtcBmiStore.instance.save(calculateBmi(const BmiInput(
          heightUnit: BmiHeightUnit.cm,
          weightUnit: BmiWeightUnit.kg,
          cm: 160,
          kg: 55))!);
      await _pump(tester, const TtcBmiScreen());
      expect(find.byKey(const ValueKey('ttc_bmi_last')), findsOneWidget);
      expect(find.textContaining('Your BMI was 21.5'), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('ttc_tool_last_see')));
      expect(find.text('Where your number sits.'), findsOneWidget);
      expect(find.textContaining('Saved ${ttcToolDate(DateTime.now())}.'),
          findsOneWidget);
      expect(find.text('Saved to your history and checklist'), findsOneWidget,
          reason: 'a saved result cannot be saved twice');
    });

    testWidgets('a saved measurement is removed with Undo', (tester) async {
      await TtcBmiStore.instance.save(calculateBmi(const BmiInput(
          heightUnit: BmiHeightUnit.cm,
          weightUnit: BmiWeightUnit.kg,
          cm: 160,
          kg: 55))!);
      await _pump(tester, const TtcBmiScreen());
      await _tap(tester, find.byKey(const ValueKey('ttc_tool_last_see')));
      await _tap(
          tester,
          find.descendant(
              of: find.byKey(const ValueKey('ttc_bmi_entry_0')),
              matching: find.byIcon(Icons.close_rounded)));
      expect(TtcBmiStore.instance.history, isEmpty);
      expect(find.text('Save this measurement'), findsOneWidget,
          reason: 'the number on screen is unsaved again, and can be saved');
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(TtcBmiStore.instance.history.length, 1);
    });

    testWidgets('the change note survives Save (it compared a number with '
        'itself)', (tester) async {
      await TtcBmiStore.instance.save(calculateBmi(const BmiInput(
          heightUnit: BmiHeightUnit.cm,
          weightUnit: BmiWeightUnit.kg,
          cm: 160,
          kg: 55))!);
      await _pump(tester, const TtcBmiScreen());
      await calculate(tester, '160', '65');
      const note = 'This is quite different from your last entry';
      expect(find.textContaining(note), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('ttc_bmi_save')));
      expect(find.textContaining(note), findsOneWidget,
          reason: 'still compared with the entry before, not with itself');
    });
  });

  // ===========================================================================
  group('PCOS symptom check', () {
    testWidgets('first open: no last check, nothing chosen', (tester) async {
      await _pump(tester, const TtcPcosStandScreen());
      expect(find.byKey(const ValueKey('ttc_pcos_stand_last')), findsNothing);
    });

    testWidgets('answers come back, filled in, under the last check',
        (tester) async {
      await _pump(tester, const TtcPcosStandScreen());
      await _tap(tester, find.text('Mostly 21 to 35 days'));
      await _tap(tester, find.byKey(const ValueKey('ttc_pcos_stand_see')));
      expect(find.text('What your cycle looks like'), findsOneWidget);
      expect(TtcSelfCheckStore.instance.pcosAnswers?.cycleLength,
          PcosCycleLength.typical);

      // "Change my answers" goes back to them.
      await _tap(tester, find.byKey(const ValueKey('ttc_pcos_stand_change')));
      expect(find.byKey(const ValueKey('ttc_pcos_stand_see')), findsOneWidget);

      // A new visit.
      await _pump(tester, const TtcPcosStandScreen());
      expect(find.byKey(const ValueKey('ttc_pcos_stand_last')), findsOneWidget);
      expect(_weightOf(tester, find.text('Mostly 21 to 35 days')),
          FontWeight.w800,
          reason: 'her answer is still chosen');
      await _tap(tester, find.byKey(const ValueKey('ttc_tool_last_see')));
      expect(find.text('What your cycle looks like'), findsOneWidget);
    });

    testWidgets('"Clear my answers" clears, and Undo brings them back',
        (tester) async {
      await TtcSelfCheckStore.instance
          .savePcos(PcosStandAnswers()..cycleLength = PcosCycleLength.longer);
      await _pump(tester, const TtcPcosStandScreen());
      expect(_weightOf(tester, find.text('Often longer than 35')),
          FontWeight.w800);
      await _tap(tester, find.byKey(const ValueKey('ttc_tool_last_again')));
      expect(TtcSelfCheckStore.instance.pcosAt, isNull);
      expect(_weightOf(tester, find.text('Often longer than 35')),
          FontWeight.w600);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(TtcSelfCheckStore.instance.pcosAt, isNotNull);
      expect(_weightOf(tester, find.text('Often longer than 35')),
          FontWeight.w800);
    });

    testWidgets('the notes copy to the clipboard', (tester) async {
      final r = pcosBuildStand(
          PcosStandAnswers()..cycleLength = PcosCycleLength.longer);
      await _pump(tester, TtcPcosChecklistScreen(result: r));
      await _tap(tester, find.byKey(const ValueKey('ttc_tool_copy_notes')));
      expect(clipboard, contains('My notes: PCOS symptom check'));
      expect(clipboard, contains(kPcosChecklistDisclaimer));
    });
  });

  // ===========================================================================
  group('See a specialist?', () {
    testWidgets('the several-answer question has ticks, and "None" taps off',
        (tester) async {
      await _pump(tester, const TtcIvfReadinessScreen());
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      await _tap(tester, find.text('None of these'));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await _tap(tester, find.text('Endometriosis'));
      await _tap(tester, find.text('PCOS'));
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2),
          reason: 'two conditions at once; "None" came off');
      // .first: the conditions question comes before his test's "Not sure".
      await _tap(tester, find.text('Not sure').first);
      await _tap(tester, find.text('Not sure').first);
      expect(find.byIcon(Icons.check_rounded), findsNothing,
          reason: 'a ticked answer taps off again');
    });

    testWidgets('answers come back on the next visit', (tester) async {
      await _pump(tester, const TtcIvfReadinessScreen());
      await _tap(tester, find.text('Yes, it was normal'));
      await _tap(tester, find.byKey(const ValueKey('ttc_ivf_see')));
      // Change 5 (2026-09-28). Was: find.text('What this adds up to.')
      expect(find.text('What your answers add up to.'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_ivf_change')), findsOneWidget);

      await _pump(tester, const TtcIvfReadinessScreen());
      expect(find.byKey(const ValueKey('ttc_ivf_last')), findsOneWidget);
      expect(_weightOf(tester, find.text('Yes, it was normal')),
          FontWeight.w800);
    });

    testWidgets('a later trying band from her logs wins over a stale one',
        (tester) async {
      await TtcSelfCheckStore.instance
          .saveIvf(IvfReadinessAnswers()..trying = IvfTrying.underSix);
      TtcStore.instance.setJourneyStart(
          DateTime.now().subtract(const Duration(days: 400)));
      await _pump(tester, const TtcIvfReadinessScreen());
      expect(_weightOf(tester, find.text('More than a year')), FontWeight.w800,
          reason: 'a saved "less than 6 months" must not hold back the '
              'twelve-month rule');
    });

    test('a skipped conditions question is "Not answered" in her notes', () {
      final r = ivfBuildReadiness(
          IvfReadinessAnswers(), TtcFertilityHelpStore.instance.context);
      expect(r.checklist.firstWhere((e) => e.label == 'Already known').value,
          'Not answered');
      final none = ivfBuildReadiness(
          IvfReadinessAnswers()..conditionsChecked = true,
          TtcFertilityHelpStore.instance.context);
      expect(
          none.checklist.firstWhere((e) => e.label == 'Already known').value,
          'Nothing so far');
    });

    testWidgets('the notes copy to the clipboard', (tester) async {
      final r = ivfBuildReadiness(
          IvfReadinessAnswers(), TtcFertilityHelpStore.instance.context);
      await _pump(tester, TtcIvfNotesScreen(result: r));
      await _tap(tester, find.byKey(const ValueKey('ttc_tool_copy_notes')));
      expect(clipboard, contains('My age: Not answered'));
    });
  });

  // ===========================================================================
  group('Pre-pregnancy checklist', () {
    testWidgets('one tap on the circle marks it done; a second takes it off, '
        'with Undo', (tester) async {
      await _pump(tester, const TtcPrecheckScreen());
      final mark = find.byKey(const ValueKey('ttc_precheck_folate_mark'));
      expect(mark, findsOneWidget, reason: 'the folate section opens first');
      final c = PrecheckContext.gather();

      await _tap(tester, mark);
      expect(TtcPrecheckStore.instance.statusOf('folate', c),
          PrecheckStatus.done);
      expect(find.text(precheckAskFor('folate').question), findsNothing,
          reason: 'marking did not open the item');

      await _tap(tester, mark);
      expect(TtcPrecheckStore.instance.statusOf('folate', c),
          PrecheckStatus.untouched);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(TtcPrecheckStore.instance.statusOf('folate', c),
          PrecheckStatus.done);
    });

    testWidgets('inside an item, the chosen answer taps off again',
        (tester) async {
      await _pump(tester, const TtcPrecheckScreen());
      // By its row's key (2026-09-29): "Folic acid" is also the first of
      // "Your next 3 steps" at the top of the list now. Kept for revert:
      // await _tap(tester, find.text('Folic acid'));
      await _tap(
          tester, find.byKey(const ValueKey('ttc_precheck_folate_open')));
      final c = PrecheckContext.gather();
      // The item's own answer block, not the row's status label.
      final needToDo = find.descendant(
          of: find.byType(TtcToolOptions),
          // Folic acid's own word (2026-09-30). Kept for revert:
          // 'Need to do'.
          matching: find.text(precheckAskFor('folate').need));
      await _tap(tester, needToDo);
      expect(TtcPrecheckStore.instance.statusOf('folate', c),
          PrecheckStatus.needsAttention);
      await _tap(tester, needToDo);
      expect(TtcPrecheckStore.instance.statusOf('folate', c),
          PrecheckStatus.untouched);
      // The doctor tick is a ticked block now, not a purple checkbox.
      expect(find.byIcon(Icons.check_box_outline_blank_rounded), findsNothing);
      await _tap(tester, find.text('I talked to my doctor about this'));
      expect(
          TtcPrecheckStore.instance.entryFor('folate')?.discussedWithDoctor,
          isTrue);
    });

    testWidgets('a next step with no tool comes back to the list, open',
        (tester) async {
      final s = TtcPrecheckStore.instance;
      await s.setStatus('folate', PrecheckStatus.done);
      await s.setStatus('cycle_tracking', PrecheckStatus.done);
      await s.setStatus('vaccines', PrecheckStatus.notRelevant);
      await s.setStatus('tobacco', PrecheckStatus.needsAttention);
      await _pump(tester, const TtcPrecheckScreen());
      // ⚠️ THE THREE STEPS HEAD THE LIST NOW (2026-09-29), and a step opens
      // its item in place. Kept for revert, when they lived on the summary:
      // await _tap(tester, find.byKey(const ValueKey('ttc_precheck_next_steps')));
      // expect(find.text('Your next 3 steps'), findsOneWidget);
      // await _tap(tester, find.text('You marked this to come back to.'));
      // expect(find.text('Your next 3 steps'), findsNothing,
      //     reason: 'back on the list, not a dead tap');
      // expect(find.text('Tobacco'), findsOneWidget);
      expect(find.text('Your next 3 steps'), findsOneWidget);
      expect(find.text(precheckAskFor('tobacco').question), findsNothing);
      // The step card for tobacco: the only one she marked to come back to.
      await _tap(tester,
          find.byKey(const ValueKey('ttc_precheck_step_tobacco')));
      expect(find.text(precheckAskFor('tobacco').question), findsOneWidget,
          reason: 'with the tobacco item open');
      // Its answer block for "Need to do" is the chosen one.
      expect(
          find.descendant(
              of: find.byType(TtcToolOptions),
              matching: find.text(precheckAskFor('tobacco').need)),
          findsOneWidget);
    });
  });

  // ===========================================================================
  test('wiring gate: the four are still reached from their tiles', () {
    final router =
        File('lib/screens/ttc/ttc_surface_router.dart').readAsStringSync();
    for (final line in [
      "'ttc_pcos_check' => const TtcPcosStandScreen(),",
      "'ttc_precheck' => const TtcPrecheckScreen(),",
      "'ttc_bmi' => const TtcBmiScreen(),",
      "'ttc_fertility_help' => const TtcIvfReadinessScreen(),",
    ]) {
      expect(router.contains(line), isTrue, reason: line);
    }
    // The PCOS door renders the body inline, so the saved answers show there.
    expect(
        File('lib/screens/ttc/ttc_pcos_stand_screen.dart')
            .readAsStringSync()
            .contains('ttcToolPad(TtcToolLastCheck('),
        isTrue);
  });
}

