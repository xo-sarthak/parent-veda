// =============================================================================
//  The Pre-pregnancy checklist after its tools review (2026-09-30): fixes
//  A to E in docs/TTC-TOOLS-WH-REVIEW.md. The user: "do A to E first."
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_precheck_screen.dart';
import 'package:parentveda/screens/ttc/ttc_precheck_summary.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_precheck_data.dart';
import 'package:parentveda/ttc/ttc_precheck_rules.dart';
import 'package:parentveda/ttc/ttc_precheck_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

Future<void> _pump(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(360, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: home));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() async {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    await TtcPrecheckStore.instance.reset();
    await TtcPrecheckStore.instance.markOpened();
  });

  testWidgets('A: no "N of M done" beside a section heading; the ring stays',
      (tester) async {
    await _pump(tester, const TtcPrecheckScreen());
    expect(find.textContaining(RegExp(r'^\d+ of \d+ done$')), findsNothing);
    // The one count is the ring's: "of 21" under its number.
    expect(find.textContaining('of '), findsWidgets);
  });

  group('B: the title follows where she is', () {
    testWidgets('a new arrival: "before trying"', (tester) async {
      await _pump(tester, const TtcPrecheckScreen());
      expect(find.text('Things to sort out before trying'), findsOneWidget);
    });

    testWidgets('a month in or more: "while you try"', (tester) async {
      TtcStore.instance.setJourneyStart(
          DateTime.now().subtract(Duration(days: kPrecheckWhileTryingDays)));
      await _pump(tester, const TtcPrecheckScreen());
      expect(find.text('Things to sort out while you try'), findsOneWidget);
      expect(find.text('Things to sort out before trying'), findsNothing);
    });
  });

  testWidgets('C: only "Core" is said, and the key is one line',
      (tester) async {
    await _pump(tester, const TtcPrecheckScreen());
    expect(find.text('Core'), findsWidgets);
    expect(find.text('Worth doing'), findsNothing);
    expect(find.text('Helpful if it applies'), findsNothing);
    expect(find.text('Core: most people should do this.'), findsOneWidget);
    expect(find.textContaining('Worth doing: helps most'), findsNothing);
  });

  testWidgets('D: the notes page has no "Not looked at" tile', (tester) async {
    await _pump(tester, const TtcPrecheckSummaryScreen());
    expect(find.text('Covered'), findsOneWidget);
    expect(find.text('Worth checking'), findsOneWidget);
    expect(find.text('Not looked at'), findsNothing);
  });

  test('E: a core item she has not looked at gives its own reason', () {
    final c = PrecheckContext(
      loggedCycles: 3,
      cyclesLookIrregular: false,
      ranPcosCheck: true,
      pcosLevelAtLeastDiscuss: false,
      medicineCount: 0,
      supplementCount: 1,
      takesFolate: true,
      vaccinesRecorded: 0,
      liveVaccineOutstanding: false,
      daysTrying: null,
      liveImmunitySettled: false,
    );
    final steps = precheckPriorities(c, (_) => PrecheckStatus.untouched);
    expect(steps, isNotEmpty);
    const generic = 'One of the few items here that applies to almost everyone.';
    for (final s in steps) {
      expect(s.reason.en, isNot(generic), reason: s.item.id);
      expect(s.reason.en.trim(), isNotEmpty);
      expect(s.reason.en.length, lessThan(160), reason: 'one line, not a blob');
    }
    // Not the same sentence twice.
    final reasons = steps.map((s) => s.reason.en).toList();
    expect(reasons.toSet().length, reasons.length);
  });
  // ===========================================================================
  //  Each item asks its own question (the user: "for every drop down the same
  //  question with the same options").
  // ===========================================================================
  group('each item asks its own question', () {
    test('every item has its own, not the generic one', () {
      for (final i in kPrecheckItems) {
        final a = precheckAskFor(i.id);
        expect(identical(a, kPrecheckGenericAsk), isFalse,
            reason: '${i.id} still asks the generic question');
        expect(a.question.endsWith('?'), isTrue, reason: i.id);
        final labels = [
          for (final s in const [
            PrecheckStatus.done,
            PrecheckStatus.needsAttention,
            PrecheckStatus.notSure,
            PrecheckStatus.notRelevant,
          ])
            a.labelFor(s),
        ];
        expect(labels.toSet().length, 4, reason: '${i.id}: a repeated answer');
        for (final l in labels) {
          expect(l.trim(), isNotEmpty, reason: i.id);
          expect(l.length, lessThanOrEqualTo(26),
              reason: '${i.id}: "$l" will not fit a block');
        }
        // The generic words are not the answers any more.
        expect(labels, isNot(contains('Done')), reason: i.id);
        expect(labels, isNot(contains('Need to do')), reason: i.id);
        expect(labels, isNot(contains('Not relevant to me')), reason: i.id);
      }
    });

    test('nothing in the map is for an item that does not exist', () {
      final ids = kPrecheckItems.map((i) => i.id).toSet();
      for (final k in kPrecheckAsks.keys) {
        expect(ids, contains(k));
      }
    });

    testWidgets('an opened item shows its own question and answers',
        (tester) async {
      await _pump(tester, const TtcPrecheckScreen());
      await tester.tap(find.text('Tobacco'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Do you use tobacco?'), findsOneWidget);
      expect(find.text("I've stopped"), findsOneWidget);
      expect(find.text('I want to stop'), findsOneWidget);
      expect(find.text('Where you are'), findsNothing);
      expect(find.text('Not relevant to me'), findsNothing);
    });

    testWidgets('choosing the own answer of an item stores the same status',
        (tester) async {
      await _pump(tester, const TtcPrecheckScreen());
      await tester.tap(find.text('Tobacco'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('I want to stop'));
      await tester.pumpAndSettle();
      expect(TtcPrecheckStore.instance.entryFor('tobacco')?.status,
          PrecheckStatus.needsAttention);
    });
  });
}
