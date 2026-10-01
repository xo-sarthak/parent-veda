// =============================================================================
//  The pre-pregnancy checklist as a tool (rebuild, 2026-09-29)
// -----------------------------------------------------------------------------
//  The user on build 20: the tools looked like "big blobs of text". The
//  rebuilt checklist leads with a ring and a count of her list, the next three
//  steps, and tickable rows that open in place; what was settled folds away,
//  and two items tick themselves from her own records (launch sanity D12).
//  These hold the interactions, the memory and the honesty rules of that.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_precheck_parts.dart';
import 'package:parentveda/screens/ttc/ttc_precheck_screen.dart';
import 'package:parentveda/screens/ttc/ttc_precheck_summary.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_precheck_data.dart';
import 'package:parentveda/ttc/ttc_precheck_rules.dart';
import 'package:parentveda/ttc/ttc_precheck_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';

PrecheckContext _ctx({
  bool takesFolate = false,
  bool liveImmunitySettled = false,
  bool liveVaccineOutstanding = false,
  int supplementCount = 0,
  int medicineCount = 0,
}) => PrecheckContext(
  loggedCycles: 0,
  cyclesLookIrregular: false,
  ranPcosCheck: false,
  pcosLevelAtLeastDiscuss: false,
  medicineCount: medicineCount,
  supplementCount: supplementCount,
  takesFolate: takesFolate,
  vaccinesRecorded: 0,
  liveVaccineOutstanding: liveVaccineOutstanding,
  daysTrying: null,
  liveImmunitySettled: liveImmunitySettled,
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double scale = 1.0,
  double height = 6000,
}) async {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: c!,
      ),
      home: child,
    ),
  );
  await tester.pumpAndSettle();
  expect(
    tester.takeException(),
    isNull,
    reason: 'threw or overflowed at 360dp, text x$scale',
  );
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Finder _key(String k) => find.byKey(ValueKey(k));

Future<void> _addFolicAcid(WidgetTester tester) async {
  // Touch the store and let its first load finish before seeding it, or the
  // load lands after the seed and wipes it.
  TtcSupplementsStore.instance;
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  TtcSupplementsStore.instance.resetForTest();
  TtcSupplementsStore.instance.addRawForTest(
    const TtcSupplement(id: 'fa', name: 'Folic acid 5', dose: '1 tablet'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcSupplementsStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    await TtcPrecheckStore.instance.load();
    await TtcPrecheckStore.instance.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
  });

  // ===========================================================================
  group('done from her own records (D12), and nothing else', () {
    test('only folic acid and vaccines may tick from her records', () {
      expect(kPrecheckFromRecords, {'folate', 'vaccines'});
      for (final id in ['medication_review', 'supplement_review']) {
        final item = precheckItemById(id)!;
        expect(
          precheckDerivedDone(
            item,
            _ctx(
              takesFolate: true,
              liveImmunitySettled: true,
              supplementCount: 4,
              medicineCount: 4,
            ),
          ),
          isFalse,
          reason: 'a list is not a review',
        );
      }
    });

    test('folic acid on her list ticks the item, and says where from', () {
      final item = precheckItemById('folate')!;
      final c = _ctx(takesFolate: true, supplementCount: 1);
      expect(precheckDerivedDone(item, c), isTrue);
      expect(precheckDoneSource(item, c)!.en, 'From your supplements');
      // Still not auto-completion: that rule and its test stand.
      expect(precheckAutoDone(item, c), isFalse);
      // And the dose line still shows on the row.
      expect(precheckEvidenceFor(item, c)!.en, contains('dose'));
    });

    test('vaccines tick only when every live vaccine is settled and none is '
        'outstanding', () {
      final item = precheckItemById('vaccines')!;
      expect(precheckDerivedDone(item, _ctx()), isFalse);
      expect(
        precheckDerivedDone(item, _ctx(liveImmunitySettled: true)),
        isTrue,
      );
      expect(
        precheckDerivedDone(
          item,
          _ctx(liveImmunitySettled: true, liveVaccineOutstanding: true),
        ),
        isFalse,
      );
    });

    test(
      'her answer wins over the derived tick, and undo restores it',
      () async {
        final s = TtcPrecheckStore.instance;
        final c = _ctx(takesFolate: true);
        expect(s.statusOf('folate', c), PrecheckStatus.done);
        await s.setStatus('folate', PrecheckStatus.untouched);
        expect(s.statusOf('folate', c), PrecheckStatus.untouched);
        await s.restore('folate', null);
        expect(s.entryFor('folate'), isNull);
        expect(s.statusOf('folate', c), PrecheckStatus.done);
      },
    );

    testWidgets('on screen: folded into Done, tagged, and one tap takes it '
        'off with Undo back to the app\'s tick', (tester) async {
      await _addFolicAcid(tester);
      await _pump(tester, const TtcPrecheckScreen());
      expect(
        _key('ttc_precheck_folate_mark'),
        findsNothing,
        reason: 'settled before she opened the list, so it is folded',
      );
      await _tap(tester, _key('ttc_precheck_fold_done'));
      expect(find.text('From your supplements'), findsOneWidget);
      await _tap(tester, _key('ttc_precheck_folate_mark'));
      final c = PrecheckContext.gather();
      expect(
        TtcPrecheckStore.instance.statusOf('folate', c),
        PrecheckStatus.untouched,
      );
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(TtcPrecheckStore.instance.entryFor('folate'), isNull);
      expect(
        TtcPrecheckStore.instance.statusOf('folate', c),
        PrecheckStatus.done,
      );
    });
  });

  // ===========================================================================
  group('the list counts what it draws', () {
    test('the hidden partner items are not counted or offered', () {
      final s = TtcPrecheckStore.instance;
      final c = _ctx();
      expect(s.counts(c).tracking, kPrecheckVisibleItems.length);
      expect(
        kPrecheckVisibleItems.any((i) => i.id == 'partner_health'),
        isFalse,
      );
      // Settle everything visible and core: the fallback must still not
      // reach into the hidden section.
      final p = precheckPriorities(
        c,
        (id) => kPrecheckVisibleItems.any((i) => i.id == id)
            ? PrecheckStatus.done
            : PrecheckStatus.untouched,
      );
      expect(p, isEmpty);
    });
  });

  // ===========================================================================
  group('the tool', () {
    testWidgets('no fraction before anything is done; a tick moves the ring '
        'and stays in place', (tester) async {
      await _pump(tester, const TtcPrecheckScreen());
      expect(find.text("Start with what you've already done"), findsOneWidget);
      final total = kPrecheckVisibleItems.length;
      await _tap(tester, _key('ttc_precheck_dental_mark'));
      expect(find.text('1 of $total done'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is PrecheckRing && w.done == 1),
        findsOneWidget,
      );
      // Ticked on this visit: still in its section, not folded.
      expect(_key('ttc_precheck_dental_mark'), findsOneWidget);
      expect(_key('ttc_precheck_fold_done'), findsNothing);
    });

    testWidgets('a step in "Your next 3 steps" opens its item in place', (
      tester,
    ) async {
      await _pump(tester, const TtcPrecheckScreen());
      // 2026-09-30: the item's own question replaced "WHERE YOU ARE".
      final folateAsk = precheckAskFor('folate').question;
      expect(find.text(folateAsk), findsNothing);
      // The step IS the item's row: drawn once, in the steps card.
      expect(find.text('Folic acid'), findsOneWidget);
      await _tap(tester, _key('ttc_precheck_step_folate'));
      expect(find.text(folateAsk), findsOneWidget);
      expect(find.text('ASK YOUR DOCTOR'), findsOneWidget);
      // Its link rows name where they go.
      expect(find.text('Open Supplements'), findsOneWidget);
      // Tapping the row again closes it.
      await _tap(tester, _key('ttc_precheck_folate_open'));
      expect(find.text(folateAsk), findsNothing);
    });

    // Kept for revert (2026-09-29): 'ticking a step takes it off the next
    // three' asserted the step vanished at once. The steps are the rows now
    // and stay put for the visit; the next visit chooses again.
    testWidgets('a ticked step stays for the visit; the next visit chooses '
        'again', (tester) async {
      await _pump(tester, const TtcPrecheckScreen());
      expect(_key('ttc_precheck_step_folate'), findsOneWidget);
      await _tap(tester, _key('ttc_precheck_folate_mark'));
      expect(_key('ttc_precheck_step_folate'), findsOneWidget);
      await _pump(tester, const TtcPrecheckScreen());
      expect(_key('ttc_precheck_step_folate'), findsNothing);
      expect(find.text('Done · 1'), findsOneWidget);
    });

    test('a repeated fallback reason is never said twice', () {
      final p = precheckPriorities(_ctx(), (_) => PrecheckStatus.untouched);
      final reasons = [for (final x in p) x.reason.en];
      expect(reasons.toSet().length, reasons.length, reason: '$reasons');
      final marked = precheckPriorities(
        _ctx(takesFolate: true),
        (id) => const {'tobacco', 'alcohol', 'sleep', 'caffeine'}.contains(id)
            ? PrecheckStatus.needsAttention
            : PrecheckStatus.untouched,
      );
      final r2 = [for (final x in marked) x.reason.en];
      expect(r2.toSet().length, r2.length, reason: '$r2');
    });

    testWidgets('state persists across a reload, and settled items fold away '
        'on the next visit', (tester) async {
      await _pump(tester, const TtcPrecheckScreen());
      await _tap(tester, _key('ttc_precheck_dental_mark'));
      await _tap(tester, _key('ttc_precheck_tobacco_open'));
      await _tap(
        tester,
        find.descendant(
          of: find.byType(TtcToolOptions),
          // Tobacco's own word for "not relevant" (2026-09-30). Kept for
          // revert: 'Not relevant to me'.
          matching: find.text(precheckAskFor('tobacco').notRelevant),
        ),
      );

      // A fresh launch: read back from the phone, not from memory.
      await TtcPrecheckStore.instance.reloadForTest();
      final c = PrecheckContext.gather();
      expect(
        TtcPrecheckStore.instance.statusOf('dental', c),
        PrecheckStatus.done,
      );
      expect(
        TtcPrecheckStore.instance.statusOf('tobacco', c),
        PrecheckStatus.notRelevant,
      );

      await _pump(tester, const TtcPrecheckScreen());
      expect(_key('ttc_precheck_dental_mark'), findsNothing);
      expect(find.text('Done · 1'), findsOneWidget);
      expect(find.text('Not relevant to me · 1'), findsOneWidget);
      await _tap(tester, _key('ttc_precheck_fold_done'));
      expect(_key('ttc_precheck_dental_mark'), findsOneWidget);
      // Not relevant leaves the count.
      expect(
        find.text('1 of ${kPrecheckVisibleItems.length - 1} done'),
        findsOneWidget,
      );
    });

    testWidgets('a door that names a section lands on it', (tester) async {
      await _pump(
        tester,
        const TtcPrecheckScreen(openSection: PrecheckSection.lifestyle),
        height: 800,
      );
      expect(find.text('Everyday habits'), findsOneWidget);
      final y = tester.getTopLeft(find.text('Everyday habits')).dy;
      expect(y, lessThan(800), reason: 'scrolled into view');
    });
  });

  // ===========================================================================
  group('Notes for my doctor', () {
    testWidgets('shows the questions the copy carries', (tester) async {
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String?;
            }
            return null;
          });
      await TtcPrecheckStore.instance.setStatus(
        'medication_review',
        PrecheckStatus.needsAttention,
      );
      await _pump(tester, const TtcPrecheckSummaryScreen());
      expect(find.text('Notes for my doctor'), findsOneWidget);
      const q =
          'Should any of my current medicines be reviewed before '
          'pregnancy?';
      expect(find.text('"$q"'), findsOneWidget);
      await _tap(tester, _key('ttc_precheck_copy'));
      expect(copied, contains('- $q'));
    });

    testWidgets('opened from the list by its named pill', (tester) async {
      await _pump(tester, const TtcPrecheckScreen());
      expect(find.text('Notes for my doctor'), findsOneWidget);
      await _tap(tester, _key('ttc_precheck_next_steps'));
      expect(find.text('Your questions'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('no overflow at 360dp', () {
    for (final scale in const [1.0, 1.5]) {
      for (final hindi in const [false, true]) {
        testWidgets('list with an item open, x$scale, hindi $hindi', (
          tester,
        ) async {
          TtcLang.instance.hinglish = hindi;
          await _addFolicAcid(tester);
          await TtcPrecheckStore.instance.setStatus(
            'tobacco',
            PrecheckStatus.notSure,
          );
          await TtcPrecheckStore.instance.setDiscussed(
            'medication_review',
            true,
          );
          await _pump(tester, const TtcPrecheckScreen(), scale: scale);
          await _tap(tester, _key('ttc_precheck_medication_review_open'));
          await _tap(tester, _key('ttc_precheck_known'));
          await _tap(tester, _key('ttc_precheck_fold_done'));
          expect(tester.takeException(), isNull);
        });
        testWidgets('notes page, x$scale, hindi $hindi', (tester) async {
          TtcLang.instance.hinglish = hindi;
          await TtcPrecheckStore.instance.setStatus(
            'vaccines',
            PrecheckStatus.done,
          );
          await _pump(tester, const TtcPrecheckSummaryScreen(), scale: scale);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  // ===========================================================================
  test('wiring gate: the Tools row still opens this screen', () {
    final tools = File(
      'lib/screens/ttc/ttc_tools_screen.dart',
    ).readAsStringSync();
    expect(tools, contains("openTtcSurface(c, 'ttc_precheck')"));
    final router = File(
      'lib/screens/ttc/ttc_surface_router.dart',
    ).readAsStringSync();
    expect(router, contains("'ttc_precheck' => const TtcPrecheckScreen(),"));
    expect(kPrecheckHue, 104, reason: 'the "Plan and check" group hue');
  });
}
