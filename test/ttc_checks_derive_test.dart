// =============================================================================
//  The two checks fill in what the app already holds, and say where from
// -----------------------------------------------------------------------------
//  Launch sanity D9 and D18 (2026-09-28). "Derive, never ask": the PCOS
//  symptom check asked "How long are your cycles usually?" of a woman with a
//  logged cycle, and the fertility-help check asked about his semen test while
//  Records held one. Each prefill is selected and changeable, and says where
//  it came from, because a prefill she cannot see the source of is a claim.
//
//  Also D18's one name: the Tools row, the screen's eyebrow and the door card
//  all say "Should I seek fertility help?".
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_ivf_readiness_screen.dart';
import 'package:parentveda/screens/ttc/ttc_pcos_stand_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';
import 'package:parentveda/ttc/ttc_selfcheck_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(360, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'overflow at 360dp');
}

FontWeight? _weightOf(WidgetTester tester, Finder label) => tester
    .widget<AnimatedDefaultTextStyle>(find
        .ancestor(of: label, matching: find.byType(AnimatedDefaultTextStyle))
        .first)
    .style
    .fontWeight;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcSelfCheckStore.instance.resetForTest();
    TtcRecordsStore.instance.resetForTest();
    await TtcFertilityHelpStore.instance.load();
    await TtcFertilityHelpStore.instance.reset();
    TtcLang.instance.hinglish = false;
  });

  group('D9: the PCOS check fills in her cycle length', () {
    testWidgets('from one logged cycle, and says so', (tester) async {
      final now = DateTime.now();
      CycleStore.instance
        ..logPeriodStart(now.subtract(const Duration(days: 40)))
        ..logPeriodStart(now.subtract(const Duration(days: 10)));
      expect(CycleStore.instance.cycleLengths, [30]);

      await _pump(tester, const TtcPcosStandScreen());
      expect(_weightOf(tester, find.text('Mostly 21 to 35 days')),
          FontWeight.w800,
          reason: 'one 30-day cycle fills in "Mostly 21 to 35 days"');
      expect(find.textContaining('your one logged cycle, 30 days'),
          findsOneWidget);
    });

    testWidgets('from the usual length she gave, and says so',
        (tester) async {
      TtcStore.instance.setStatedCycleLength(38);
      await _pump(tester, const TtcPcosStandScreen());
      expect(_weightOf(tester, find.text('Often longer than 35')),
          FontWeight.w800);
      expect(find.textContaining('the usual length you gave us, about 38'),
          findsOneWidget);
    });

    testWidgets('with nothing to go on it is asked, with no source line',
        (tester) async {
      await _pump(tester, const TtcPcosStandScreen());
      expect(find.textContaining('Filled in from'), findsNothing);
    });

    testWidgets('how long she has been trying says where it came from',
        (tester) async {
      TtcStore.instance.setJourneyStart(
          DateTime.now().subtract(const Duration(days: 60)));
      await _pump(tester, const TtcPcosStandScreen());
      expect(_weightOf(tester, find.text('Less than 6 months')),
          FontWeight.w800);
      expect(find.textContaining('when you told us you started trying'),
          findsOneWidget);
    });
  });

  group('D18: the fertility-help check', () {
    test('has one name on the Tools row and the screen', () {
      expect(kTtcFertilityHelpName, 'Should I seek fertility help?');
      expect(ttcToolById('fertility_help')!.nameEn, kTtcFertilityHelpName);
    });

    testWidgets('the eyebrow is that name, and the old names are gone',
        (tester) async {
      await _pump(tester, const TtcIvfReadinessScreen());
      expect(find.text(kTtcFertilityHelpName.toUpperCase()), findsOneWidget);
      expect(find.text('SEE A SPECIALIST?'), findsNothing);
      expect(find.textContaining('Is it worth talking'), findsNothing);
    });

    testWidgets('his semen test in Records is named, with its date',
        (tester) async {
      TtcRecordsStore.instance.add(
        label: 'Semen analysis',
        testId: 'semen',
        takenOn: DateTime(2026, 9, 6),
        forPartner: true,
      );
      await _pump(tester, const TtcIvfReadinessScreen());
      expect(
          find.textContaining(
              'Your records hold his semen test from 6 Sep 2026'),
          findsOneWidget);
    });

    testWidgets('her saved age is filled in and says so', (tester) async {
      await TtcFertilityHelpStore.instance
          .setAgeBand(FertilityAgeBand.values.first);
      await _pump(tester, const TtcIvfReadinessScreen());
      expect(find.textContaining('Filled in from your earlier answer'),
          findsOneWidget);
    });
  });
}
